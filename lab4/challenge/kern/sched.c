#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/spinlock.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
	struct Env *idle;

	// Implement simple round-robin scheduling.
	//
	// Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env this CPU was
	// last running.  Switch to the first such environment found.
	//
	// If no envs are runnable, but the environment previously
	// running on this CPU is still ENV_RUNNING, it's okay to
	// choose that environment.
	//
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	struct Env *e, *runenv = NULL;
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_id);
	else cur = 0;
	// cprintf("runenv: %x\n", runenv);
	for (i = 0; i < NENV; ++i) {
		int j = (cur+i) % NENV;
		if (envs[j].env_status == ENV_RUNNABLE) {
			// cprintf("envs[%x].pr: %x\n", j, envs[j].pr);
			if (runenv==NULL || envs[j].pr < runenv->pr) 
				runenv = envs+j; 
		}
	}
// cprintf("runenv: %x\n", runenv);
	if (curenv && (curenv->env_status == ENV_RUNNING) && ((runenv==NULL) || (curenv->pr < runenv->pr))) {
		// cprintf("envs[%x].pr: %x\n", ENVX(curenv->env_id), curenv->pr);
		env_run(curenv);
	}
// cprintf("runenv: %x\n", runenv);
	if (runenv) {
		// cprintf("envs[%x].pr: %x\n", ENVX(runenv->env_id), runenv->pr);
		env_run(runenv);
	}

// cprintf("runenv: %x\n", runenv);
	// sched_halt never returns
	// cprintf("Nothing runnable\n");
	sched_halt();
}

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
		for (i = 0; i < 2; ++i)
			cprintf("envs[%x].env_status: %x\n", i, envs[i].env_status);
		cprintf("No runnable environments in the system!\n");
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
	lcr3(PADDR(kern_pgdir));

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
		"movl $0, %%ebp\n"
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}

