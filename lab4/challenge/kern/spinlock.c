// Mutual exclusion spin locks.

#include <inc/types.h>
#include <inc/assert.h>
#include <inc/x86.h>
#include <inc/memlayout.h>
#include <inc/string.h>
#include <kern/cpu.h>
#include <kern/spinlock.h>
#include <kern/kdebug.h>

// The big kernel lock
struct spinlock kernel_lock = {
#ifdef DEBUG_SPINLOCK
	.name = "kernel_lock"
#endif
};

#ifdef DEBUG_SPINLOCK
// Record the current call stack in pcs[] by following the %ebp chain.
static void
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
	lk->locked = 0;
#ifdef DEBUG_SPINLOCK
	lk->name = name;
	lk->cpu = 0;
#endif
}

// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
	lk->cpu = 0;
#endif

	// The xchg serializes, so that reads before release are 
	// not reordered after it.  The 1996 PentiumPro manual (Volume 3,
	// 7.2) says reads can be carried out speculatively and in
	// any order, which implies we need to serialize here.
	// But the 2007 Intel 64 Architecture Memory Ordering White
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
