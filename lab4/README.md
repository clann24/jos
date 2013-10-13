Report for lab4, Shian Chen
===

>well


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

Part C
---
Part C: Preemptive Multitasking and Inter-Process communication (IPC)












