// test user-level fault handler -- alloc pages to fix faults

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
	int r;
	void *addr = (void*)utf->utf_fault_va;

	cprintf("fault %x\n", addr);
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	// cprintf("addr: %x\n", *((char*)addr+100));
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
	// cprintf("good\n");
}

void
umain(int argc, char **argv)
{
	set_pgfault_handler(handler);
	cprintf("%s\n", (char*)0xDeadBeef);
	cprintf("%s\n", (char*)0xCafeBffe);
}
