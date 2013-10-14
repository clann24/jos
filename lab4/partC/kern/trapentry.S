/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps


#define ec(name, num)\
.data;\
	.long name;\
.text;\
	.globl name;\
	.type name, @function;\
	.align 2;\
name:\
	pushl $(num);\
	jmp _alltraps

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

#define zhanwei()\
.data;\
	.long 0

.data
	.p2align 2
	.globl funs
funs:
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
.data
	.space 60
.text
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
	noec(th48, 48)

/*
 * Lab 3: Your code here for _alltraps
 */
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













/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

	# TRAPHANDLER_NOEC(th0, 0)
	# TRAPHANDLER_NOEC(th1, 1)
	# TRAPHANDLER_NOEC(th3, 3)
	# TRAPHANDLER_NOEC(th4, 4)
	# TRAPHANDLER_NOEC(th5, 5)
	# TRAPHANDLER_NOEC(th6, 6)
	# TRAPHANDLER_NOEC(th7, 7)
	# TRAPHANDLER(th8, 8)
	# TRAPHANDLER_NOEC(th9, 9)
	# TRAPHANDLER(th10, 10)
	# TRAPHANDLER(th11, 11)
	# TRAPHANDLER(th12, 12)
	# TRAPHANDLER(th13, 13)
	# TRAPHANDLER(th14, 14)
	# TRAPHANDLER_NOEC(th16, 16)

