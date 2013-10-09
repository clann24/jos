// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	cprintf("hello, world\n");
	cprintf("thisenv: %x\n", thisenv);
	cprintf("i am environment %08x\n", thisenv->env_id);
}
