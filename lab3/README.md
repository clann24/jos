Report for lab3, Shian Chen
===

>all exercises finished 

>one challenge completed

```
make[1]: Leaving directory `/home/clann/lab3'
divzero: OK (5.4s) 
softint: OK (4.6s) 
badsegment: OK (4.6s) 
Part A score: 30/30

faultread: OK (4.6s) 
faultreadkernel: OK (4.6s) 
faultwrite: OK (4.6s) 
faultwritekernel: OK (4.6s) 
breakpoint: OK (4.6s) 
testbss: OK (4.7s) 
hello: OK (4.6s) 
buggyhello: OK (4.6s) 
buggyhello2: OK (4.6s) 
    (Old jos.out.buggyhello2 failure log removed)
evilhello: OK (4.6s) 
Part B score: 50/50

Score: 80/80
```

Part A: User Environments and Exception Handling
===

Exercise 1
---
```
Exercise 1. Modify mem_init() in kern/pmap.c to allocate and map the envs array. This array consists of exactly NENV instances of the Env structure allocated much like how you allocated the pages array. Also like the pages array, the memory backing envs should also be mapped user read-only at UENVS (defined in inc/memlayout.h) so user processes can read from this array.
```
Kid's stuff. Just add the following code to `pmap.c`. 
```c
pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
...
envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
...
boot_map_region(kern_pgdir,
	UENVS,
	PTSIZE,
	PADDR(envs),
	PTE_U);
```
But unfortunately I failed in `check_page_free_list` due to my previous implementation of `page_init`:
```c
void
page_init(void)
{
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	int med = (int)ROUNDUP(((char*)pages) + (sizeof(struct PageInfo) * npages) - 0xf0000000, PGSIZE)/PGSIZE;
	cprintf("%x\n", ((char*)pages) + (sizeof(struct PageInfo) * npages));
	cprintf("med=%d\n", med);
	for (i = med; i < npages; i++) {
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
```
I calculated the free physical pages using the end address of `pages`, but now it should be `envs`:
```c
void
page_init(void)
{
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
	cprintf("%x\n", ((char*)envs) + (sizeof(struct Env) * NENV));
	cprintf("med=%d\n", med);
	for (i = med; i < npages; i++) {
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
``` 
And this finished the first exercise.

Exercise 2
---
```
Exercise 2. In the file env.c, finish coding the following functions:

env_init()
env_setup_vm()
region_alloc()
load_icode()
env_create()
env_run()
```
env_init:
```c
void
env_init(void)
{
	int i;
	for (i = NENV;i >= 0; --i) {
	//initialize backwards to maintain the order
		envs[i].env_id = 0;
		//normal link-list routine
		envs[i].env_link = env_free_list;
		env_free_list = envs+i;
	}
	env_init_percpu();
}
```
env_setup_vm:
```c
static int
env_setup_vm(struct Env *e)
{
	int i;
	struct PageInfo *p = NULL;
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
	p->pp_ref++;	//reference count
	e->env_pgdir = (pde_t *) page2kva(p);
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
	//we can just copy pgdir because everything is kern_gpdir is static
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
	return 0;
}
```
region_alloc:
```c
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
	//round to align
	for (; begin < end; begin += PGSIZE) {
		struct PageInfo *pg = page_alloc(0);	//not initialized
		if (!pg) panic("region_alloc failed!");
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
	}
}
```

```c

static void
load_icode(struct Env *e, uint8_t *binary, size_t size)
{
	struct Elf *ELFHDR = (struct Elf *) binary;
	struct Proghdr *ph, *eph;

	if (ELFHDR->e_magic != ELF_MAGIC)
		panic("Not executable!");
	
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	
	//here above is just as same as main.c

	lcr3(PADDR(e->env_pgdir));
	//it's silly to use kern_pgdir here.

	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
			memset((void *)ph->p_va, 0, ph->p_memsz);
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
		}

	//we can use this because kern_pgdir is a subset of e->env_pgdir
	lcr3(PADDR(kern_pgdir));

	e->env_tf.tf_eip = ELFHDR->e_entry;
	//we should set eip to make sure env_pop_tf runs correctly

	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
}
```
env_create, simple:
```c
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
	struct Env *penv;
	env_alloc(&penv, 0);
	load_icode(penv, binary, size);
}
```
env_run, simply follow the guidelines:
```c
void
env_run(struct Env *e)
{
	if (e->env_status == ENV_RUNNING)
		e->env_status = ENV_RUNNABLE;
	curenv = e;
	e->env_status = ENV_RUNNING;
	e->env_runs++;
	lcr3(PADDR(e->env_pgdir));
	env_pop_tf(&e->env_tf);
}
```
Now use gdb to see if it works well:
```
+ symbol-file obj/kern/kernel
(gdb) b env_pop_tf
Breakpoint 1 at 0xf01038de: file kern/env.c, line 456.
(gdb) c
Continuing.
The target architecture is assumed to be i386
=> 0xf01038de <env_pop_tf>:	push   %ebp

Breakpoint 1, env_pop_tf (tf=0xf01a1000) at kern/env.c:456
456	{
(gdb) s
=> 0xf01038e4 <env_pop_tf+6>:	mov    0x8(%ebp),%esp
(gdb) si
=> 0xf01038e7 <env_pop_tf+9>:	popa   
(gdb) 
=> 0xf01038e8 <env_pop_tf+10>:	pop    %es
(gdb) 
=> 0xf01038e9 <env_pop_tf+11>:	pop    %ds
(gdb) 
=> 0xf01038ea <env_pop_tf+12>:	add    $0x8,%esp
(gdb) 
=> 0xf01038ed <env_pop_tf+15>:	iret   
(gdb) 
=> 0x800020:	cmp    $0xeebfe000,%esp
0x00800020 in ?? ()
(gdb) 
=> 0x800026:	jne    0x80002c
0x00800026 in ?? ()
(gdb) 
=> 0x800028:	push   $0x0
0x00800028 in ?? ()
(gdb) 
=> 0x80002a:	push   $0x0
0x0080002a in ?? ()
(gdb) 
``` 
So far so good, let's move on.

Exercise 4
---
```
Exercise 4. Edit trapentry.S and trap.c and implement the features described above. The macros TRAPHANDLER and TRAPHANDLER_NOEC in trapentry.S should help you, as well as the T_* defines in inc/trap.h. You will need to add an entry point in trapentry.S (using those macros) for each trap defined in inc/trap.h, and you'll have to provide _alltraps which the TRAPHANDLER macros refer to. You will also need to modify trap_init() to initialize the idt to point to each of these entry points defined in trapentry.S; the SETGATE macro will be helpful here.

Your _alltraps should:

push values to make the stack look like a struct Trapframe
load GD_KD into %ds and %es
pushl %esp to pass a pointer to the Trapframe as an argument to trap()
call trap (can trap ever return?)
Consider using the pushal instruction; it fits nicely with the layout of the struct Trapframe.

Test your trap handling code using some of the test programs in the user directory that cause exceptions before making any system calls, such as user/divzero. You should be able to get make grade to succeed on the divzero, softint, and badsegment tests at this point.
```
Here's the infomation about whether CPU pushes EC to the stack quoted from the i386 reference:
```
Table 9-7. Error-Code Summary

Description                       Interrupt     Error Code
Number

Divide error                       0            No
Debug exceptions                   1            No
Breakpoint                         3            No
Overflow                           4            No
Bounds check                       5            No
Invalid opcode                     6            No
Coprocessor not available          7            No
System error                       8            Yes (always 0)
Coprocessor Segment Overrun        9            No
Invalid TSS                       10            Yes
Segment not present               11            Yes
Stack exception                   12            Yes
General protection fault          13            Yes
Page fault                        14            Yes
Coprocessor error                 16            No
Two-byte SW interrupt             0-255         No
```
So just add corresponding function generator in the text segment:
```
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	TRAPHANDLER_NOEC(th0, 0)
	TRAPHANDLER_NOEC(th1, 1)
	TRAPHANDLER_NOEC(th3, 3)
	TRAPHANDLER_NOEC(th4, 4)
	TRAPHANDLER_NOEC(th5, 5)
	TRAPHANDLER_NOEC(th6, 6)
	TRAPHANDLER_NOEC(th7, 7)
	TRAPHANDLER(th8, 8)
	TRAPHANDLER_NOEC(th9, 9)
	TRAPHANDLER(th10, 10)
	TRAPHANDLER(th11, 11)
	TRAPHANDLER(th12, 12)
	TRAPHANDLER(th13, 13)
	TRAPHANDLER(th14, 14)
	TRAPHANDLER_NOEC(th16, 16)
```
And according to `inc/trap.h`, we should push %ds %es after `tf_trapno` is pushed:
```c
struct Trapframe {
	struct PushRegs tf_regs;
	uint16_t tf_es;
	uint16_t tf_padding1;
	uint16_t tf_ds;
	uint16_t tf_padding2;
	uint32_t tf_trapno;
	/* below here defined by x86 hardware */
	uint32_t tf_err;
	uintptr_t tf_eip;
	uint16_t tf_cs;
	uint16_t tf_padding3;
	uint32_t tf_eflags;
	/* below here only when crossing rings, such as from user to kernel */
	uintptr_t tf_esp;
	uint16_t tf_ss;
	uint16_t tf_padding4;
} __attribute__((packed));
```
and then load GD_KD into %ds and %es
```
_alltraps:
	pushl %ds
	pushl %es
	pushal
	pushl $GD_KD
	popl %ds
	pushl $GD_KD
	popl %es
	pushl %esp
	call trap
```
and set corresponding idt entries to install the handlers:
```
void
trap_init(void)
{
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	void th0();
	void th1();
	void th3();
	void th4();
	void th5();
	void th6();
	void th7();
	void th8();
	void th9();
	void th10();
	void th11();
	void th12();
	void th13();
	void th14();
	void th16();
	SETGATE(idt[0], 0, GD_KT, th0, 0);
	SETGATE(idt[1], 0, GD_KT, th1, 0);
	SETGATE(idt[3], 0, GD_KT, th3, 0);
	SETGATE(idt[4], 0, GD_KT, th4, 0);
	SETGATE(idt[5], 0, GD_KT, th5, 0);
	SETGATE(idt[6], 0, GD_KT, th6, 0);
	SETGATE(idt[7], 0, GD_KT, th7, 0);
	SETGATE(idt[8], 0, GD_KT, th8, 0);
	SETGATE(idt[9], 0, GD_KT, th9, 0);
	SETGATE(idt[10], 0, GD_KT, th10, 0);
	SETGATE(idt[11], 0, GD_KT, th11, 0);
	SETGATE(idt[12], 0, GD_KT, th12, 0);
	SETGATE(idt[13], 0, GD_KT, th13, 0);
	SETGATE(idt[14], 0, GD_KT, th14, 0);
	SETGATE(idt[16], 0, GD_KT, th16, 0);

	// Per-CPU setup 
	trap_init_percpu();
}
```
Type `make grade` and it gives:
```
divzero: OK (5.2s) 
softint: OK (4.6s) 
    (Old jos.out.softint failure log removed)
badsegment: OK (4.6s) 
Part A score: 30/30
```

Challenge
---
```
Challenge! You probably have a lot of very similar code right now, between the lists of TRAPHANDLER in trapentry.S and their installations in trap.c. Clean this up. Change the macros in trapentry.S to automatically generate a table for trap.c to use. Note that you can switch between laying down code and data in the assembler by using the directives .text and .data.
```
Let's define a function array in `trapentry.S`:
```
.data
	.p2align 2
	.globl funs
funs:
```
so we can just use a `for` loop to install the handler funcionts:
```c
void
trap_init(void)
{
	extern struct Segdesc gdt[];
	// Challenge:
	extern void (*funs[])();
	void (*fun)() = funs[0];
	cprintf("%p\n", fun);
	int i;
	for (i = 0; i <= 16; ++i)
		if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	// Per-CPU setup 
	trap_init_percpu();
}
```
We have to define our own macro `noec` and `ec`, for example, every time a `noec` is called, `text` segment defines a funtion and `data` segment increase 4-byte to save the function entry:
```
#define noec(name, num)\
.data;\
	.long name;\
.text;\
	.globl name;\
	.type name, @function;\
	.align 2;\
name:\
	pushl $0;\
	pushl $(num);\
	jmp _alltraps
```
and then the main definition should be like this:
```
.text
/*
 * Challenge: my code here
 */
	noec(th0, 0)
	noec(th1, 1)
	#no 2 here
	noec(th3, 3)
	noec(th4, 4)
	noec(th5, 5)
	noec(th6, 6)
	noec(th7, 7)
	noec(th9, 9)
	ec(th10, 10)
	ec(th11, 11)
	ec(th12, 12)
	ec(th13, 13)
	ec(th14, 14)
	#no 15 here
	noec(th16, 16)
```
But unfortunately it's wrong and it takes me one hour to figure out why, because the code `noec(th3, 3)` will install the `funs[2]` entry rather than the third one thus makes a bloody shift in the array(another shift if `noec(16, 16)`), so we have to fix it by adding paddings:
```
#define zhanwei()\
.data;\
	.long 0

...

.text
/*
 * Challenge: my code here
 */
	noec(th0, 0)
	noec(th1, 1)
	zhanwei()
	noec(th3, 3)
	noec(th4, 4)
	noec(th5, 5)
	noec(th6, 6)
	noec(th7, 7)
	ec(th8, 8)
	noec(th9, 9)
	ec(th10, 10)
	ec(th11, 11)
	ec(th12, 12)
	ec(th13, 13)
	ec(th14, 14)
	zhanwei()
	noec(th16, 16)
```
then it correctly passes the grading script (you can't imagine how ugly is `trapentry.S` now).

Questions
---
```
What is the purpose of having an individual handler function for each exception/interrupt? (i.e., if all exceptions/interrupts were delivered to the same handler, what feature that exists in the current implementation could not be provided?)
```
We can't easily provide protection then.

```
Did you have to do anything to make the user/softint program behave correctly? The grade script expects it to produce a general protection fault (trap 13), but softint's code says int $14. Why should this produce interrupt vector 13? What happens if the kernel actually allows softint's int $14 instruction to invoke the kernel's page fault handler (which is interrupt vector 14)?
```
We should set the dpl to 3 to allow users invoke `int $14`:
```
SETGATE(idt[i], 0, GD_KT, funs[i], 3);
```
but this will let user interfere with memory management which is not what we want.

This finishes Part A
---
Part B: Page Faults, Breakpoints Exceptions, and System Calls
---
Exercise 5
---
```
Exercise 5. Modify trap_dispatch() to dispatch page fault exceptions to page_fault_handler(). You should now be able to get make grade to succeed on the faultread, faultreadkernel, faultwrite, and faultwritekernel tests. If any of them don't work, figure out why and fix them. Remember that you can boot JOS into a particular user program using make run-x or make run-x-nox.
```
Just add this to `trap_dispatch`:
```c
	// LAB 3: Your code here.
	if (tf->tf_trapno == T_PGFLT) {
		page_fault_handler(tf);
		return;
	}
```
and then we can get `50/80` grades by `make grade`.

Exercise 6
---
```
Exercise 6. Modify trap_dispatch() to make breakpoint exceptions invoke the kernel monitor. You should now be able to get make grade to succeed on the breakpoint test.
```
Again we can just add an `if` to `trap.c`:
```c
if (tf->tf_trapno == T_BRKPT) {
	monitor(tf);
	return;
}
```
and we also have to modify the `dpl` of `T_BRKPT` to allow users to invoke breakpoint exceptions:
```c
for (i = 0; i <= 16; ++i)
	if (i==T_BRKPT)
		SETGATE(idt[i], 0, GD_KT, funs[i], 3)
	else if (i!=2 && i!=15) {
		SETGATE(idt[i], 0, GD_KT, funs[i], 0);
	}
```
Challenge
---
```
Challenge! Modify the JOS kernel monitor so that you can 'continue' execution from the current location (e.g., after the int3, if the kernel monitor was invoked via the breakpoint exception), and so that you can single-step one instruction at a time. You will need to understand certain bits of the EFLAGS register in order to implement single-stepping
```
Maybe I'll do this later...

Questions
---
```
The break point test case will either generate a break point exception or a general protection fault depending on how you initialized the break point entry in the IDT (i.e., your call to SETGATE from trap_init). Why? How do you need to set it up in order to get the breakpoint exception to work as specified above and what incorrect setup would cause it to trigger a general protection fault?
```
Just set the `dpl` that enables user-invoking.
```
What do you think is the point of these mechanisms, particularly in light of what the user/softint test program does?
```
Protection.

Exercise 7
---
```
Exercise 7. Add a handler in the kernel for interrupt vector T_SYSCALL. You will have to edit kern/trapentry.S and kern/trap.c's trap_init(). You also need to change trap_dispatch() to handle the system call interrupt by calling syscall() (defined in kern/syscall.c) with the appropriate arguments, and then arranging for the return value to be passed back to the user process in %eax. Finally, you need to implement syscall() in kern/syscall.c. Make sure syscall() returns -E_INVAL if the system call number is invalid. You should read and understand lib/syscall.c (especially the inline assembly routine) in order to confirm your understanding of the system call interface. You may also find it helpful to read inc/syscall.h.
```
Just be aware of the arguments:
```c
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int ret = 0;
	switch (syscallno) {
		case SYS_cputs: 
			sys_cputs((char*)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
		case SYS_env_destroy:
			sys_env_destroy(a1);
			ret = 0;
			break;
		default:
			ret = -E_INVAL;
	}
	// cprintf("ret: %x\n", ret);
	return ret;
	panic("syscall not implemented");
}
```
Here's the tricky point, we have to assign the `syscall` return value to `tf->tf_regs.reg_eax` as the return value of the trap (well, another hour to figure it out when doing exercise 8):
```c
tf->tf_regs.reg_eax = 
	syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
			tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
```
```c
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if (tf->tf_trapno == T_PGFLT) {
		cprintf("PAGE FAULT\n");
		page_fault_handler(tf);
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
		cprintf("BREAK POINT\n");
		monitor(tf);
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
		cprintf("SYSTEM CALL\n");
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
	if (tf->tf_cs == GD_KT)
		panic("unhandled trap in kernel");
	else {
		env_destroy(curenv);
		return;
	}
}
```

Exercise 8
---
```
Exercise 8. Add the required code to the user library, then boot your kernel. You should see user/hello print "hello, world" and then print "i am environment 00001000". user/hello then attempts to "exit" by calling sys_env_destroy() (see lib/libmain.c and lib/exit.c). Since the kernel currently only supports one user environment, it should report that it has destroyed the only environment and then drop into the kernel monitor. You should be able to get make grade to succeed on the hello test.
```
Just one line `thisenv = envs+ENVX(sys_getenvid());` in libmain

Exercise 9
---
```
Exercise 9. Change kern/trap.c to panic if a page fault happens in kernel mode.

Hint: to determine whether a fault happened in user mode or in kernel mode, check the low bits of the tf_cs.

Read user_mem_assert in kern/pmap.c and implement user_mem_check in that same file.

Change kern/syscall.c to sanity check arguments to system calls.

Boot your kernel, running user/buggyhello. The environment should be destroyed, and the kernel should not panic. You should see:

	[00001000] user_mem_check assertion failure for va 00000001
	[00001000] free env 00001000
	Destroyed the only environment - nothing more to do!
	
```
Just panic when page fault occur in kernel mode:
```c
	if ((tf->tf_cs&3) == 0)
		panic("Kernel page fault!");
```
In `user_mem_check`, we should first test whether `i` is above ULIM, test whether `pte` and `*pte` is valid, then the `perm`:
```c
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
		pprint(pte);
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
			return -E_FAULT;
		}
	}
	cprintf("user_mem_check success va: %x, len: %x\n", va, len);
	return 0;
}
```

```
Finally, change debuginfo_eip in kern/kdebug.c to call user_mem_check on usd, stabs, and stabstr. If you now run user/breakpoint, you should be able to run backtrace from the kernel monitor and see the backtrace traverse into lib/libmain.c before the kernel panics with a page fault. What causes this page fault? You don't need to fix it, but you should understand why it happens.
```
Add the checking code to the `kdebug.c` to avoid kernel page fault:
```c
	if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
		return -1;
		
	...

	if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
		return -1;

	if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
		return -1;
```

When I call `backtrace` I get a `PAGE FAULT`, it is easy to see that the PF is caused by accessing memory `0xeebfe000`, which is beyond the user stack:
```
K> csa_backtrace
Stack backtrace:
ebp efffff00  eip f0100a44  args 00000001 efffff28 f01a2000 00000200 f0105675
	     kern/monitor.c:177: monitor+337
ebp efffff80  eip f010402a  args f01a2000 efffffbc 00000014 00000000 00000000
	     kern/trap.c:197: trap+207
ebp efffffb0  eip f0104147  args efffffbc 00000000 00000000 eebfdfd0 efffffdc
	     kern/trapentry.S:114: <unknown>+0
ebp eebfdfd0  eip 80007f  args 00000000 00000000 00000000 00000000 00000000
	     lib/libmain.c:30: libmain+67
ebp eebfdff0  eip 800031  args 00000000 00000000Incoming TRAP frame at 0xeffffe6c
PAGE FAULT
```

Exercise 10
---
```
Exercise 10. Boot your kernel, running user/evilhello. The environment should be destroyed, and the kernel should not panic. You should see:

	[00000000] new env 00001000
	[00001000] user_mem_check assertion failure for va f0100020
	[00001000] free env 00001000
```
This test passes automaticly after Exercise 9 is finished.


This completes the lab.
===












