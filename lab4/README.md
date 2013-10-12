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


Part B
---


















