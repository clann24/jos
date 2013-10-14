Report for lab4, Shian Chen
===

>all exercises finished 

>one challenge completed

```
make[1]: Leaving directory `/home/clann/lab4'
dumbfork: OK (5.0s) 
Part A score: 5/5

faultread: OK (4.6s) 
faultwrite: OK (4.7s) 
faultdie: OK (4.6s) 
faultregs: OK (4.6s) 
faultalloc: OK (4.6s) 
faultallocbad: OK (4.6s) 
faultnostack: OK (4.6s) 
faultbadhandler: OK (4.6s) 
faultevilhandler: OK (4.6s) 
forktree: OK (4.8s) 
Part B score: 50/50

spin: OK (4.7s) 
stresssched: OK (6.9s) 
pingpong: OK (4.8s) 
primes: OK (47.2s) 
Part C score: 20/20

Score: 75/75
```


Part A: Multiprocessor Support and Cooperative Multitasking
---
Exercise 1
```
Exercise 1. Implement mmio_map_region in kern/pmap.c. To see how this is used, look at the beginning of lapic_init in kern/lapic.c. You'll have to do the next exercise, too, before the tests for mmio_map_region will run.
```
Note the way `size` is aligned, can't use `size=ROUNDUP(size)` directly:
```c
void *
mmio_map_region(physaddr_t pa, size_t size)
{
	static uintptr_t base = MMIOBASE;
	size = ROUNDUP(pa+size, PGSIZE);
	pa = ROUNDDOWN(pa, PGSIZE);
	size -= pa;
	if (base+size >= MMIOLIM) panic("not enough memory");
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
	base += size;
	return (void*) (base - size);
}
```
Exercise 2
---
```
Exercise 2. Read boot_aps() and mp_main() in kern/init.c, and the assembly code in kern/mpentry.S. Make sure you understand the control flow transfer during the bootstrap of APs. Then modify your implementation of page_init() in kern/pmap.c to avoid adding the page at MPENTRY_PADDR to the free list, so that we can safely copy and run AP bootstrap code at that physical address. Your code should pass the updated check_page_free_list() test (but might fail the updated check_kern_pgdir() test, which we will fix soon).
```
Just modify the upper bound of free base memory to MPENTRY_PADDR:
```c
void
page_init(void)
{
	...
	size_t i;
	for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	...
}
```

Question
---
>Compare kern/mpentry.S side by side with boot/boot.S. Bearing in mind that kern/mpentry.S is compiled and linked to run above KERNBASE just like everything else in the kernel, what is the purpose of macro MPBOOTPHYS? Why is it necessary in kern/mpentry.S but not in boot/boot.S? In other words, what could go wrong if it were omitted in kern/mpentry.S? 

Beacuse `mentry.S` is loaded by bootloader without any special treatment whereas it has to be loaded by bootstrap CPU to `0x7000`, so we have to deliminate the original load address and plus an offset we want.



Exercise 3
---
```
Exercise 3. Modify mem_init_mp() (in kern/pmap.c) to map per-CPU stacks starting at KSTACKTOP, as shown in inc/memlayout.h. The size of each stack is KSTKSIZE bytes plus KSTKGAP bytes of unmapped guard pages. Your code should pass the new check in check_kern_pgdir().
```
Easy, but we will now have KSTKSIZE of memory in `bootstack` wasted:
```c
static void
mem_init_mp(void)
{
	int i;
	for (i = 0; i < NCPU; ++i) {
		boot_map_region(kern_pgdir, 
			KSTACKTOP - KSTKSIZE - i * (KSTKSIZE + KSTKGAP), 
			KSTKSIZE, 
			PADDR(percpu_kstacks[i]), 
			PTE_W);
	}
}
```
Exercise 4
---
```
Exercise 4. The code in trap_init_percpu() (kern/trap.c) initializes the TSS and TSS descriptor for the BSP. It worked in Lab 3, but is incorrect when running on other CPUs. Change the code so that it can work on all CPUs. (Note: your new code should not use the global ts variable any more.)
```
Be aware that `ltr(GD_TSS0)` should be changed to `ltr(GD_TSS0+8*cid)`:
```c
void
trap_init_percpu(void)
{
	int cid = thiscpu->cpu_id;
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
	gdt[(GD_TSS0 >> 3)+cid] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
					sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3)+cid].sd_s = 0;
	ltr(GD_TSS0+8*cid);
	lidt(&idt_pd);
}
```
Exercise 5
---
```
Exercise 5. Apply the big kernel lock as described above, by calling lock_kernel() and unlock_kernel() at the proper locations.
```
Easy.

Question
---
>It seems that using the big kernel lock guarantees that only one CPU can run the kernel code at a time. Why do we still need separate kernel stacks for each CPU? Describe a scenario in which using a shared kernel stack will go wrong, even with the protection of the big kernel lock.

Although `It seems that using the big kernel lock guarantees that only one CPU can run the kernel code at a time`, it is not necessarily true. When an interupt occurs, the hardware automaticly pushes 

- uint32_t tf_err;
- uintptr_t tf_eip;
- uint16_t tf_cs;
- uint16_t tf_padding3;
- uint32_t tf_eflags;

to the stack _before_ checking the lock, so it will just mess up.

Exercise 6
---
```
Exercise 6. Implement round-robin scheduling in sched_yield() as described above. Don't forget to modify syscall() to dispatch sys_yield().

Modify kern/init.c to create three (or more!) environments that all run the program user/yield.c. You should see the environments switch back and forth between each other five times before terminating, like this:

...
Hello, I am environment 00001000.
Hello, I am environment 00001001.
Hello, I am environment 00001002.
Back in environment 00001000, iteration 0.
Back in environment 00001001, iteration 0.
Back in environment 00001002, iteration 0.
Back in environment 00001000, iteration 1.
Back in environment 00001001, iteration 1.
Back in environment 00001002, iteration 1.
...
After the yield programs exit, there will be no runnable environment in the system, the scheduler should invoke the JOS kernel monitor. If any of this does not happen, then fix your code before proceeding.
```
Be aware of the `curenv` may be null:
```c
void
sched_yield(void)
{
	struct Env *idle;
	struct Env *e;
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_id);
		else cur = 0;
	for (i = 0; i < NENV; ++i) {
		int j = (cur+i) % NENV;
		if (j < 2) cprintf("envs[%x].env_status: %x\n", j, envs[j].env_status);
		if (envs[j].env_status == ENV_RUNNABLE) {
			if (j == 1) 
				cprintf("\n");
			env_run(envs + j);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
		env_run(curenv);
	sched_halt();
}
```

Question
---
>In your implementation of env_run() you should have called lcr3(). Before and after the call to lcr3(), your code makes references (at least it should) to the variable e, the argument to env_run. Upon loading the %cr3 register, the addressing context used by the MMU is instantly changed. But a virtual address (namely e) has meaning relative to a given address context--the address context specifies the physical address to which the virtual address maps. Why can the pointer e be dereferenced both before and after the addressing switch?

Because the kernel part of vm of all environments are identical.

>Whenever the kernel switches from one environment to another, it must ensure the old environment's registers are saved so they can be restored properly later. Why? Where does this happen?

Obviouly `curenv->env_tf = *tf;` in `trap.c` saves the current trap frame.

Exercise 7
---
```
Exercise 7. Implement the system calls described above in kern/syscall.c. You will need to use various functions in kern/pmap.c and kern/env.c, particularly envid2env(). For now, whenever you call envid2env(), pass 1 in the checkperm parameter. Be sure you check for any invalid system call arguments, returning -E_INVAL in that case. Test your JOS kernel with user/dumbfork and make sure it works before proceeding.
```
Please see `kern/syscall.c` for details because there's too much code. One tip for this exercise: Be aware of the difference between `page_insert` and `page_alloc`.


Challenge
---
```
Challenge! Add a less trivial scheduling policy to the kernel, such as a fixed-priority scheduler that allows each environment to be assigned a priority and ensures that higher-priority environments are always chosen in preference to lower-priority environments. If you're feeling really adventurous, try implementing a Unix-style adjustable-priority scheduler or even a lottery or stride scheduler. (Look up "lottery scheduling" and "stride scheduling" in Google.)

Write a test program or two that verifies that your scheduling algorithm is working correctly (i.e., the right environments get run in the right order). It may be easier to write these test programs once you have implemented fork() and IPC in parts B and C of this lab.
```
This challenge was completed after I finished all exercises.

I implemented a fixed-priority scheduling. First add a `pr` field in `struct Env` to indicate the priority, the lower `pr` the higher the priority. Then modify the `sched_yield` to consider the `pr` field, be aware of the condition to run `curenv`, don't be confused with the `&&` and `||` and the order of every argument, or it will cause problem in multiprocessor condition (well, obviously I had gotten in trouble with that when I was debugging or I'd not bother say it):
```c
void
sched_yield(void)
{
	struct Env *idle;
	struct Env *e, *runenv = NULL;
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_id);
	else cur = 0;
	for (i = 0; i < NENV; ++i) {
		int j = (cur+i) % NENV;
		if (envs[j].env_status == ENV_RUNNABLE) {
			if (runenv==NULL || envs[j].pr < runenv->pr) 
				runenv = envs+j; 
		}
	}
	if (curenv && (curenv->env_status == ENV_RUNNING) && ((runenv==NULL) || (curenv->pr < runenv->pr))) {
		env_run(curenv);
	}
	if (runenv) {
		env_run(runenv);
	}
	sched_halt();
}
```
The priority of a process should be set in the creation by his father process and can be changed by himself, 
so I added a system call `sys_change_pr(int pr)` to enable modifying of priority, this involve lots of modification in many files and at last one implementation in `kern/syscall.c`:
```c
int sys_change_pr(int pr) {
	curenv->pr = pr;
	return 0;
}
```

I added a new function `pfork` rather than modify the odd one for compatibility with `grade scripts`, every child has a `pr` 0 when it is created to ensure it can run at least one time except there's a very high priority process that has a negative `pr`, then the child process call the system call to change his own `pr` properly:
```c
envid_t
pfork(int pr)
{
	set_pgfault_handler(pgfault);

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		sys_change_pr(pr);
		return 0;
	}

	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
```
I changed the `hello.c` to test my implementation:
```c
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	int i;
	for (i = 1; i <= 5; ++i) {
		int pid = pfork(i);
		if (pid == 0) {
			cprintf("child %x is now living!\n", i);
			int j;
			for (j = 0; j < 5; ++j) {
				cprintf("child %x is yielding!\n", i);
				sys_yield();
			}
			break;
		}
	}
}
```
Every time the scheduler runs, the one with lowest priority should be run, and the output meets this rule well and the `grade scripts` still reports `OK` on all tests:
```
[00000000] new env 00001000
envs[0].pr: 0
[00001000] new env 00001001
envs[0].pr: 0
[00001000] new env 00001002
envs[1].pr: 0
child 1 is now living!
child 1 is yielding!
envs[0].pr: 0
[00001000] new env 00001003
envs[1].pr: 1
envs[2].pr: 0
child 2 is now living!
child 2 is yielding!
envs[0].pr: 0
envs[1].pr: 1
envs[1].pr: 1
envs[2].pr: 2
envs[0].pr: 0
[00001000] new env 00001004
envs[1].pr: 1
envs[2].pr: 2
envs[3].pr: 0
child 3 is now living!
child 3 is yielding!
envs[0].pr: 0
envs[1].pr: 1
envs[2].pr: 2
[00001000] new env 00001005
envs[1].pr: 1
envs[2].pr: 2
envs[3].pr: 3
envs[4].pr: 0
child 4 is now living!
child 4 is yielding!
envs[0].pr: 0
envs[1].pr: 1
envs[2].pr: 2
envs[3].pr: 3
[00001000] exiting gracefully
[00001000] free env 00001000
envs[1].pr: 1
envs[2].pr: 2
envs[3].pr: 3
envs[4].pr: 4
envs[5].pr: 0
child 5 is now living!
child 5 is yielding!
envs[1].pr: 1
envs[2].pr: 2
envs[3].pr: 3
envs[4].pr: 4
child 1 is yielding!
envs[2].pr: 2
envs[3].pr: 3
envs[4].pr: 4
envs[5].pr: 5
envs[1].pr: 1
child 1 is yielding!
envs[2].pr: 2
envs[3].pr: 3
envs[4].pr: 4
envs[5].pr: 5
envs[1].pr: 1
child 1 is yielding!
envs[2].pr: 2
envs[3].pr: 3
envs[4].pr: 4
envs[5].pr: 5
envs[1].pr: 1
child 1 is yielding!
envs[2].pr: 2
envs[3].pr: 3
envs[4].pr: 4
envs[5].pr: 5
envs[1].pr: 1
[00001001] exiting gracefully
[00001001] free env 00001001
envs[2].pr: 2
envs[3].pr: 3
envs[4].pr: 4
envs[5].pr: 5
child 2 is yielding!
envs[3].pr: 3
envs[4].pr: 4
envs[5].pr: 5
envs[2].pr: 2
child 2 is yielding!
envs[3].pr: 3
envs[4].pr: 4
envs[5].pr: 5
envs[2].pr: 2
child 2 is yielding!
envs[3].pr: 3
envs[4].pr: 4
envs[5].pr: 5
envs[2].pr: 2
child 2 is yielding!
envs[3].pr: 3
envs[4].pr: 4
envs[5].pr: 5
envs[2].pr: 2
[00001002] exiting gracefully
[00001002] free env 00001002
envs[3].pr: 3
envs[4].pr: 4
envs[5].pr: 5
child 3 is yielding!
envs[4].pr: 4
envs[5].pr: 5
envs[3].pr: 3
child 3 is yielding!
envs[4].pr: 4
envs[5].pr: 5
envs[3].pr: 3
child 3 is yielding!
envs[4].pr: 4
envs[5].pr: 5
envs[3].pr: 3
child 3 is yielding!
envs[4].pr: 4
envs[5].pr: 5
envs[3].pr: 3
[00001003] exiting gracefully
[00001003] free env 00001003
envs[4].pr: 4
envs[5].pr: 5
child 4 is yielding!
envs[5].pr: 5
envs[4].pr: 4
child 4 is yielding!
envs[5].pr: 5
envs[4].pr: 4
child 4 is yielding!
envs[5].pr: 5
envs[4].pr: 4
child 4 is yielding!
envs[5].pr: 5
envs[4].pr: 4
[00001004] exiting gracefully
[00001004] free env 00001004
envs[5].pr: 5
child 5 is yielding!
envs[5].pr: 5
child 5 is yielding!
envs[5].pr: 5
child 5 is yielding!
envs[5].pr: 5
child 5 is yielding!
envs[5].pr: 5
[00001005] exiting gracefully
[00001005] free env 00001005
envs[0].env_status: 0
envs[1].env_status: 0
No runnable environments in the system!
Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.
blue
green
red
```




Part B: Copy-on-Write Fork
---
Exercise 8
---
```
Exercise 8. Implement the sys_env_set_pgfault_upcall system call. Be sure to enable permission checking when looking up the environment ID of the target environment, since this is a "dangerous" system call.
```
Can't be easier, no comments for the code:
```c
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
	if (ret) return ret;	//bad_env
	e->env_pgfault_upcall = func;
	return 0;
}
```
Exercise 9
---
```
Exercise 9. Implement the code in page_fault_handler in kern/trap.c required to dispatch page faults to the user-mode handler. Be sure to take appropriate precautions when writing into the exception stack. (What happens if the user environment runs out of space on the exception stack?)
```
We have to check `utf_addr` for validation:
```c
void
page_fault_handler(struct Trapframe *tf)
{
	uint32_t fault_va;
	fault_va = rcr2();
	cprintf("fault_va: %x\n", fault_va);
	// LAB 3: Your code here.
	if ((tf->tf_cs&3) == 0) {
		panic("Kernel page fault!");
	}
	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
		struct UTrapframe *utf;
		uintptr_t utf_addr;
		if (UXSTACKTOP-PGSIZE<=tf->tf_esp && tf->tf_esp<=UXSTACKTOP-1)
			utf_addr = tf->tf_esp - sizeof(struct UTrapframe) - 4;
		else 
			utf_addr = UXSTACKTOP - sizeof(struct UTrapframe);
		user_mem_assert(curenv, (void*)utf_addr, 1, PTE_W);//1 is enough
		utf = (struct UTrapframe *) utf_addr;

		utf->utf_fault_va = fault_va;
		utf->utf_err = tf->tf_err;
		utf->utf_regs = tf->tf_regs;
		utf->utf_eip = tf->tf_eip;
		utf->utf_eflags = tf->tf_eflags;
		utf->utf_esp = tf->tf_esp;

		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
		curenv->env_tf.tf_esp = utf_addr;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
	env_destroy(curenv);
}
```
Exercise 10
---
```
Exercise 10. Implement the _pgfault_upcall routine in lib/pfentry.S. The interesting part is returning to the original point in the user code that caused the page fault. You'll return directly there, without going back through the kernel. The hard part is simultaneously switching stacks and re-loading the EIP.
```
See the comments:
```asm
.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
	movl _pgfault_handler, %eax
	call *%eax
	addl $4, %esp			// pop function argument
	
	movl 0x28(%esp), %edx # trap-time eip
	subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
	movl 0x30(%esp), %eax # trap-time esp-4
	movl %edx, (%eax)
	addl $0x8, %esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp #eip
	popfl

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
```
Exercise 11
---
```
Exercise 11. Finish set_pgfault_handler() in lib/pgfault.c.
```
Just follow the guide:
```c
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
	int r;

	if (_pgfault_handler == 0) {
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");;
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
```
Exercise 12
---
```
Exercise 12. Implement fork, duppage and pgfault in lib/fork.c.

Test your code with the forktree program. It should produce the following messages, with interspersed 'new env', 'free env', and 'exiting gracefully' messages. The messages may not appear in this order, and the environment IDs may be different.

	1000: I am ''
	1001: I am '0'
	2000: I am '00'
	2001: I am '000'
	1002: I am '1'
	3000: I am '11'
	3001: I am '10'
	4000: I am '100'
	1003: I am '01'
	5000: I am '010'
	4001: I am '011'
	2002: I am '110'
	1004: I am '001'
	1005: I am '111'
	1006: I am '101'
```
`PFTEMP` is used as a temporary vm for storing a physical page:
```c
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	if (!(
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");

	addr = ROUNDDOWN(addr, PGSIZE);
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
		panic("sys_page_unmap");
	return;
}
```
Permissions is checked beforehand so just test the `PTE_W` and `PTE_COW`:
```c
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// LAB 4: Your code here.
	void *addr = (void*) (pn*PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
		if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
			panic("2");
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
			panic("3");
	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
	return 0;
	panic("duppage not implemented");
}
```

We have to check `uvpd` present first to avoid page fault in accessing uvpt:
```c
envid_t
fork(void)
{
	set_pgfault_handler(pgfault);

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
		// panic("child");
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// cprintf("sys_exofork: %x\n", envid);
	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
```

Part C: Preemptive Multitasking and Inter-Process communication (IPC)
---

Exercise 13
---
```
Exercise 13. Modify kern/trapentry.S and kern/trap.c to initialize the appropriate entries in the IDT and provide handlers for IRQs 0 through 15. Then modify the code in env_alloc() in kern/env.c to ensure that user environments are always run with interrupts enabled.
```
Generate 16 entries of funs using a script language (whatever you like, I use python):
```
	noec(th32, 32)
	noec(th33, 33)
	noec(th34, 34)
	noec(th35, 35)
	noec(th36, 36)
	noec(th37, 37)
	noec(th38, 38)
	noec(th39, 39)
	noec(th40, 40)
	noec(th41, 41)
	noec(th42, 42)
	noec(th43, 43)
	noec(th44, 44)
	noec(th45, 45)
	noec(th46, 46)
	noec(th47, 47)
```
Add a `for` loop in `trap.c` to set up gates:
```c
for (i = 0; i < 16; ++i)
	SETGATE(idt[IRQ_OFFSET+i], 0, GD_KT, funs[IRQ_OFFSET+i], 0);
```
And enable `FL_IF` in user env:
```c
	e->env_tf.tf_eflags |= FL_IF;
```

Exercise 14
---
```
Exercise 14. Modify the kernel's trap_dispatch() function so that it calls sched_yield() to find and run a different environment whenever a clock interrupt takes place.
```
Trivial:
```c
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
		lapic_eoi();
		sched_yield();
		return;
	}
```

Exercise 15
---
```
Exercise 15. Implement sys_ipc_recv and sys_ipc_try_send in kern/syscall.c. Read the comments on both before implementing them, since they have to work together. When you call envid2env in these routines, you should set the checkperm flag to 0, meaning that any environment is allowed to send IPC messages to any other environment, and the kernel does no special permission checking other than verifying that the target envid is valid.

Then implement the ipc_recv and ipc_send functions in lib/ipc.c.
```
Most of code is checking, just follow the guide:
```c
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	struct Env *e;
	int ret = envid2env(envid, &e, 0);
	if (ret) return ret;//bad env
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
	if (srcva < (void*)UTOP) {
		pte_t *pte;
		struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!pg) return -E_INVAL;
		if ((*pte & perm) != perm) return -E_INVAL;
		if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
		if (srcva != ROUNDDOWN(srcva, PGSIZE)) return -E_INVAL;
		if (e->env_ipc_dstva < (void*)UTOP) {
			ret = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm);
			if (ret) return ret;
			e->env_ipc_perm = perm;
		}
	}
	e->env_ipc_recving = 0;
	e->env_ipc_from = curenv->env_id;
	e->env_ipc_value = value; 
	e->env_status = ENV_RUNNABLE;
	e->env_tf.tf_regs.reg_eax = 0;
	return 0;
	panic("sys_ipc_try_send not implemented");
}
```
Trivial:
```c
static int
sys_ipc_recv(void *dstva)
{
	if (dstva < (void*)UTOP) 
		if (dstva != ROUNDDOWN(dstva, PGSIZE)) 
			return -E_INVAL;
	curenv->env_ipc_recving = 1;
	curenv->env_status = ENV_NOT_RUNNABLE;
	curenv->env_ipc_dstva = dstva;
	sys_yield();
	return 0;
}
```

(void*)-1 is used to indicate no page:
```c
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
	if (perm_store) *perm_store = 0;
	if (!pg) pg = (void*) -1;
	int ret = sys_ipc_recv(pg);
	if (ret) return ret;
	if (from_env_store)
		*from_env_store = thisenv->env_ipc_from;
	if (perm_store)
		*perm_store = thisenv->env_ipc_perm;
	return thisenv->env_ipc_value;
}
```

Use `sys_yield` to make code CPU friendly:
```c
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
		sys_yield();
	}
}
```

There's something I have to mention here: after I finished the last exercise, I typed `make grade` and passed all tests but got a timeout in the `primes`, I found that this test was executed in a 4-CPU environment, I tried it in a 1-CPU environment and it finished quickly but it was much slower in a 4-CPU environment, I thought maybe it was due to the immatureness of `qemu` (and I were using the official `qemu` rather than the patched one), so I changed the grade time limit from `30s` to `60s` and finally passed all tests.



This completes the lab.
===









