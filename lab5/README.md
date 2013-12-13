Report for lab5, Shian Chen
===

>All exercises finished

>One challenge completed


```
make[1]: Leaving directory `/home/clann/lab'
internal FS tests: OK (4.9s) 
  fs i/o: OK 
  check_super: OK 
spawn via spawnhello: OK (4.7s) 
PTE_SHARE [testpteshare]: OK (4.7s) 
PTE_SHARE [testfdsharing]: OK (4.7s) 
start the shell [icode]: OK (4.7s) 
testshell: OK (8.1s) 
primespipe: OK (16.1s) 
Score: 75/75
```

Exercise 1
---
```
Exercise 1. i386_init identifies the file system environment by passing the type ENV_TYPE_FS to your environment creation function, env_create. Modify env_create in env.c, so that it gives the file system environment I/O privilege, but never gives that privilege to any other environment.
```
Trivial:
```c
	if (type == ENV_TYPE_FS) {
		penv->env_type = ENV_TYPE_FS;
		penv->env_tf.tf_eflags |= FL_IOPL_MASK;
	}
```

Question

>Do you have to do anything else to ensure that this I/O privilege setting is saved and restored properly when you subsequently switch from one environment to another? Why?

No, it is saved by hardware and restored by `iret` in `env_pop_tf`.

Exercise 2
---
```
Exercise 2. Implement the bc_pgfault functions in fs/bc.c. bc_pgfault is a page fault handler, just like the one your wrote in the previous lab for copy-on-write fork, except that its job is to load pages in from the disk in response to a page fault. When writing this, keep in mind that (1) addr may not be aligned to a block boundary and (2) ide_read operates in sectors, not blocks.
```
Trivial:
```c
	addr = ROUNDDOWN(addr, PGSIZE);
	sys_page_alloc(0, addr, PTE_W|PTE_U|PTE_P);
	if ((r = ide_read(blockno*BLKSECTS, addr, BLKSECTS)) < 0) 
		panic("ide_read: %e", r);
```

Exercise 3
---
```
Exercise 3. spawn relies on the new syscall sys_env_set_trapframe to initialize the state of the newly created environment. Implement sys_env_set_trapframe. Test your code by running the user/spawnhello program from kern/init.c, which will attempt to spawn /hello from the file system.
```
I have really nothing to explain:
```c
static int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
	if (ret) return ret;
	user_mem_assert(e, tf, sizeof(struct Trapframe), PTE_U);
	e->env_tf = *tf;
	e->env_tf.tf_eflags |= FL_IF;
	e->env_tf.tf_cs = GD_UT | 3;
	return 0;
}
```

Challenge
---
```
Challenge! Implement Unix-style exec.
```
It's not easy to implement user-level exec because we can't replace memory in use, so we'd better create a temporary region to read and store infomation we need and employ a system call to finish the replacement job.
`ETEMP` is defined in `inc/csa.h` as `0xe0000000` indicating the beginning of our temporary region, 

By consulting the implementation of `spawn`, we can easily build the `exec` except we should be aware of the temporary region:
```c
	uint32_t tmp = ETEMP;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(0, PGOFF(ph->p_va) + tmp, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		tmp += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
```

Then we need to implement `sys_exec` (the implementation of `load_icode` and `bootmain` is helpful). The `execl` is almost the same as `spawnl`. The `init_stack` should be modified to support the temporary region (or we can implement a new one, but it's not nessesary).

Try `exec hello` and we get:
```
i am parent environment 00001001
superblock is good
tf_esp: 0
stack: e007000
hello, world
thisenv: eec0007c
i am environment 00001001
```
The last line indicates the env_id of `hello` is `00001001` (not `00001002`), so the implementation succeeds.


Exercise 4
---
```
Exercise 4. Change duppage in lib/fork.c to follow the new convention. If the page table entry has the PTE_SHARE bit set, just copy the mapping directly. (You should use PTE_SYSCALL, not 0xfff, to mask out the relevant bits from the page table entry. 0xfff picks up the accessed and dirty bits as well.)
```
Just add an `if` before checking `COW`:
```c
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// LAB 4: Your code here.
	// cprintf("1\n");
	void *addr = (void*) (pn*PGSIZE);
	if (uvpt[pn] & PTE_SHARE) {
		sys_page_map(0, addr, envid, addr, uvpt[pn]&PTE_SYSCALL);
	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
		if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
			panic("2");
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
			panic("3");
	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
	// cprintf("2\n");
	return 0;
	panic("duppage not implemented");
}
```
Exercise 5
--
```
Exercise 5. In your kern/trap.c, call kbd_intr to handle trap IRQ_OFFSET+IRQ_KBD and serial_intr to handle trap IRQ_OFFSET+IRQ_SERIAL.
```
Just dispatch it, and the `echo` and `shell` runs well.


Question
---
>How long approximately did it take you to do this lab?

Less than 5 hours for the exercises, 10 hours for the challenge.

>We simplified the file system this year with the goal of making more time for the final project. Do you feel like you gained a basic understanding of the file I/O in JOS? Feel free to suggest things we could improve.

Maybe, but I will try to read lab assignments in 2011 to see what I've missed.

This completes the lab. 
===















