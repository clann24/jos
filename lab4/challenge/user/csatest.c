// Fork a binary tree of processes and display their structure.

#include <inc/lib.h>



void
umain(int argc, char **argv)
{
	int i;
	for (i = 0; i < 5; ++i) {
		int pid = fork1(i);
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

