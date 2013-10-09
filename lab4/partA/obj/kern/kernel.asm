
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 4f 01 00 00       	call   f010018d <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:


// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010004e:	c7 04 24 40 6c 10 f0 	movl   $0xf0106c40,(%esp)
f0100055:	e8 c4 43 00 00       	call   f010441e <cprintf>
	if (x > 0)
f010005a:	85 db                	test   %ebx,%ebx
f010005c:	7e 0d                	jle    f010006b <test_backtrace+0x2b>
		test_backtrace(x-1);
f010005e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100061:	89 04 24             	mov    %eax,(%esp)
f0100064:	e8 d7 ff ff ff       	call   f0100040 <test_backtrace>
f0100069:	eb 1c                	jmp    f0100087 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100072:	00 
f0100073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010007a:	00 
f010007b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100082:	e8 79 08 00 00       	call   f0100900 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 5c 6c 10 f0 	movl   $0xf0106c5c,(%esp)
f0100092:	e8 87 43 00 00       	call   f010441e <cprintf>
}
f0100097:	83 c4 14             	add    $0x14,%esp
f010009a:	5b                   	pop    %ebx
f010009b:	5d                   	pop    %ebp
f010009c:	c3                   	ret    

f010009d <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	56                   	push   %esi
f01000a1:	53                   	push   %ebx
f01000a2:	83 ec 10             	sub    $0x10,%esp
f01000a5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000a8:	83 3d 80 5e 22 f0 00 	cmpl   $0x0,0xf0225e80
f01000af:	75 46                	jne    f01000f7 <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f01000b1:	89 35 80 5e 22 f0    	mov    %esi,0xf0225e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000b7:	fa                   	cli    
f01000b8:	fc                   	cld    

	va_start(ap, fmt);
f01000b9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000bc:	e8 83 64 00 00       	call   f0106544 <cpunum>
f01000c1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01000c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01000c8:	8b 55 08             	mov    0x8(%ebp),%edx
f01000cb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01000cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000d3:	c7 04 24 48 6d 10 f0 	movl   $0xf0106d48,(%esp)
f01000da:	e8 3f 43 00 00       	call   f010441e <cprintf>
	vcprintf(fmt, ap);
f01000df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000e3:	89 34 24             	mov    %esi,(%esp)
f01000e6:	e8 00 43 00 00       	call   f01043eb <vcprintf>
	cprintf("\n");
f01000eb:	c7 04 24 e9 6c 10 f0 	movl   $0xf0106ce9,(%esp)
f01000f2:	e8 27 43 00 00       	call   f010441e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000fe:	e8 30 0a 00 00       	call   f0100b33 <monitor>
f0100103:	eb f2                	jmp    f01000f7 <_panic+0x5a>

f0100105 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f0100105:	55                   	push   %ebp
f0100106:	89 e5                	mov    %esp,%ebp
f0100108:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f010010b:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100110:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100115:	77 20                	ja     f0100137 <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100117:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010011b:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f0100122:	f0 
f0100123:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
f010012a:	00 
f010012b:	c7 04 24 77 6c 10 f0 	movl   $0xf0106c77,(%esp)
f0100132:	e8 66 ff ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100137:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010013c:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010013f:	e8 00 64 00 00       	call   f0106544 <cpunum>
f0100144:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100148:	c7 04 24 83 6c 10 f0 	movl   $0xf0106c83,(%esp)
f010014f:	e8 ca 42 00 00       	call   f010441e <cprintf>

	lapic_init();
f0100154:	e8 05 64 00 00       	call   f010655e <lapic_init>
	// cprintf("lapic_init done\n");
	env_init_percpu();
f0100159:	e8 6f 3a 00 00       	call   f0103bcd <env_init_percpu>
	// cprintf("env_init_percpu done\n");
	trap_init_percpu();
f010015e:	66 90                	xchg   %ax,%ax
f0100160:	e8 db 42 00 00       	call   f0104440 <trap_init_percpu>
	// cprintf("trap_init_percpu done\n");
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100165:	e8 da 63 00 00       	call   f0106544 <cpunum>
f010016a:	6b d0 74             	imul   $0x74,%eax,%edx
f010016d:	81 c2 20 60 22 f0    	add    $0xf0226020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100173:	b8 01 00 00 00       	mov    $0x1,%eax
f0100178:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010017c:	c7 04 24 60 24 12 f0 	movl   $0xf0122460,(%esp)
f0100183:	e8 70 66 00 00       	call   f01067f8 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100188:	e8 29 4b 00 00       	call   f0104cb6 <sched_yield>

f010018d <i386_init>:
	cprintf("leaving test_backtrace %d\n", x);
}

void
i386_init(void)
{
f010018d:	55                   	push   %ebp
f010018e:	89 e5                	mov    %esp,%ebp
f0100190:	56                   	push   %esi
f0100191:	53                   	push   %ebx
f0100192:	83 ec 10             	sub    $0x10,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100195:	b8 08 70 26 f0       	mov    $0xf0267008,%eax
f010019a:	2d 2a 42 22 f0       	sub    $0xf022422a,%eax
f010019f:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001aa:	00 
f01001ab:	c7 04 24 2a 42 22 f0 	movl   $0xf022422a,(%esp)
f01001b2:	e8 fa 5c 00 00       	call   f0105eb1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01001b7:	e8 00 06 00 00       	call   f01007bc <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01001bc:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01001c3:	00 
f01001c4:	c7 04 24 99 6c 10 f0 	movl   $0xf0106c99,(%esp)
f01001cb:	e8 4e 42 00 00       	call   f010441e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01001d0:	e8 49 17 00 00       	call   f010191e <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01001d5:	e8 1d 3a 00 00       	call   f0103bf7 <env_init>
	trap_init();
f01001da:	e8 2c 43 00 00       	call   f010450b <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01001df:	90                   	nop
f01001e0:	e8 7c 60 00 00       	call   f0106261 <mp_init>
	lapic_init();
f01001e5:	e8 74 63 00 00       	call   f010655e <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01001ea:	e8 5e 41 00 00       	call   f010434d <pic_init>
f01001ef:	c7 04 24 60 24 12 f0 	movl   $0xf0122460,(%esp)
f01001f6:	e8 fd 65 00 00       	call   f01067f8 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001fb:	83 3d 90 5e 22 f0 07 	cmpl   $0x7,0xf0225e90
f0100202:	77 24                	ja     f0100228 <i386_init+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100204:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f010020b:	00 
f010020c:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0100213:	f0 
f0100214:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
f010021b:	00 
f010021c:	c7 04 24 77 6c 10 f0 	movl   $0xf0106c77,(%esp)
f0100223:	e8 75 fe ff ff       	call   f010009d <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100228:	b8 7e 61 10 f0       	mov    $0xf010617e,%eax
f010022d:	2d 04 61 10 f0       	sub    $0xf0106104,%eax
f0100232:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100236:	c7 44 24 04 04 61 10 	movl   $0xf0106104,0x4(%esp)
f010023d:	f0 
f010023e:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100245:	e8 c6 5c 00 00       	call   f0105f10 <memmove>
	cprintf("code addr: %x, mpentry_start addr: %x\n",
f010024a:	c7 44 24 08 04 61 10 	movl   $0xf0106104,0x8(%esp)
f0100251:	f0 
f0100252:	c7 44 24 04 00 70 00 	movl   $0xf0007000,0x4(%esp)
f0100259:	f0 
f010025a:	c7 04 24 b4 6d 10 f0 	movl   $0xf0106db4,(%esp)
f0100261:	e8 b8 41 00 00       	call   f010441e <cprintf>
		code, mpentry_start);
	// Boot each AP one at a time
	cprintf("boot_aps:cpus: %x\n", cpus);
f0100266:	c7 44 24 04 20 60 22 	movl   $0xf0226020,0x4(%esp)
f010026d:	f0 
f010026e:	c7 04 24 b4 6c 10 f0 	movl   $0xf0106cb4,(%esp)
f0100275:	e8 a4 41 00 00       	call   f010441e <cprintf>
	cprintf("ncpu: %x, CpuInfo size: %x\n", ncpu, sizeof(struct CpuInfo));
f010027a:	c7 44 24 08 74 00 00 	movl   $0x74,0x8(%esp)
f0100281:	00 
f0100282:	a1 c4 63 22 f0       	mov    0xf02263c4,%eax
f0100287:	89 44 24 04          	mov    %eax,0x4(%esp)
f010028b:	c7 04 24 c7 6c 10 f0 	movl   $0xf0106cc7,(%esp)
f0100292:	e8 87 41 00 00       	call   f010441e <cprintf>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100297:	6b 05 c4 63 22 f0 74 	imul   $0x74,0xf02263c4,%eax
f010029e:	05 20 60 22 f0       	add    $0xf0226020,%eax
f01002a3:	3d 20 60 22 f0       	cmp    $0xf0226020,%eax
f01002a8:	0f 86 c0 00 00 00    	jbe    f010036e <i386_init+0x1e1>
f01002ae:	bb 20 60 22 f0       	mov    $0xf0226020,%ebx
		cprintf("c: %x\n\n", c-cpus);
f01002b3:	89 de                	mov    %ebx,%esi
f01002b5:	81 ee 20 60 22 f0    	sub    $0xf0226020,%esi
f01002bb:	c1 fe 02             	sar    $0x2,%esi
f01002be:	69 f6 35 c2 72 4f    	imul   $0x4f72c235,%esi,%esi
f01002c4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01002c8:	c7 04 24 e3 6c 10 f0 	movl   $0xf0106ce3,(%esp)
f01002cf:	e8 4a 41 00 00       	call   f010441e <cprintf>
		if (c == cpus + cpunum())  // We've started already.
f01002d4:	e8 6b 62 00 00       	call   f0106544 <cpunum>
f01002d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01002dc:	05 20 60 22 f0       	add    $0xf0226020,%eax
f01002e1:	39 c3                	cmp    %eax,%ebx
f01002e3:	74 72                	je     f0100357 <i386_init+0x1ca>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01002e5:	89 f0                	mov    %esi,%eax
f01002e7:	c1 e0 0f             	shl    $0xf,%eax
f01002ea:	8d 80 00 f0 22 f0    	lea    -0xfdd1000(%eax),%eax
f01002f0:	a3 84 5e 22 f0       	mov    %eax,0xf0225e84
		cprintf("mpentry_kstack: %x\n", mpentry_kstack);
f01002f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002f9:	c7 04 24 eb 6c 10 f0 	movl   $0xf0106ceb,(%esp)
f0100300:	e8 19 41 00 00       	call   f010441e <cprintf>
		// Start the CPU at mpentry_start
		cprintf("code: %x\n", code);
f0100305:	c7 44 24 04 00 70 00 	movl   $0xf0007000,0x4(%esp)
f010030c:	f0 
f010030d:	c7 04 24 ff 6c 10 f0 	movl   $0xf0106cff,(%esp)
f0100314:	e8 05 41 00 00       	call   f010441e <cprintf>
		lapic_startap(c->cpu_id, PADDR(code));
f0100319:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100320:	00 
f0100321:	0f b6 03             	movzbl (%ebx),%eax
f0100324:	89 04 24             	mov    %eax,(%esp)
f0100327:	e8 82 63 00 00       	call   f01066ae <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		cprintf("c->cpu_status: %x\n", c->cpu_status);
f010032c:	8b 43 04             	mov    0x4(%ebx),%eax
f010032f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100333:	c7 04 24 09 6d 10 f0 	movl   $0xf0106d09,(%esp)
f010033a:	e8 df 40 00 00       	call   f010441e <cprintf>
		while(c->cpu_status != CPU_STARTED)
f010033f:	8b 43 04             	mov    0x4(%ebx),%eax
f0100342:	83 f8 01             	cmp    $0x1,%eax
f0100345:	75 f8                	jne    f010033f <i386_init+0x1b2>
			;
		cprintf("cpu %x started\n", c-cpus);
f0100347:	89 74 24 04          	mov    %esi,0x4(%esp)
f010034b:	c7 04 24 1c 6d 10 f0 	movl   $0xf0106d1c,(%esp)
f0100352:	e8 c7 40 00 00       	call   f010441e <cprintf>
	cprintf("code addr: %x, mpentry_start addr: %x\n",
		code, mpentry_start);
	// Boot each AP one at a time
	cprintf("boot_aps:cpus: %x\n", cpus);
	cprintf("ncpu: %x, CpuInfo size: %x\n", ncpu, sizeof(struct CpuInfo));
	for (c = cpus; c < cpus + ncpu; c++) {
f0100357:	83 c3 74             	add    $0x74,%ebx
f010035a:	6b 05 c4 63 22 f0 74 	imul   $0x74,0xf02263c4,%eax
f0100361:	05 20 60 22 f0       	add    $0xf0226020,%eax
f0100366:	39 c3                	cmp    %eax,%ebx
f0100368:	0f 82 45 ff ff ff    	jb     f01002b3 <i386_init+0x126>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010036e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100375:	00 
f0100376:	c7 44 24 04 4a 89 00 	movl   $0x894a,0x4(%esp)
f010037d:	00 
f010037e:	c7 04 24 71 f8 16 f0 	movl   $0xf016f871,(%esp)
f0100385:	e8 88 3a 00 00       	call   f0103e12 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f010038a:	e8 27 49 00 00       	call   f0104cb6 <sched_yield>

f010038f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010038f:	55                   	push   %ebp
f0100390:	89 e5                	mov    %esp,%ebp
f0100392:	53                   	push   %ebx
f0100393:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100396:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100399:	8b 45 0c             	mov    0xc(%ebp),%eax
f010039c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01003a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01003a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01003a7:	c7 04 24 2c 6d 10 f0 	movl   $0xf0106d2c,(%esp)
f01003ae:	e8 6b 40 00 00       	call   f010441e <cprintf>
	vcprintf(fmt, ap);
f01003b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01003b7:	8b 45 10             	mov    0x10(%ebp),%eax
f01003ba:	89 04 24             	mov    %eax,(%esp)
f01003bd:	e8 29 40 00 00       	call   f01043eb <vcprintf>
	cprintf("\n");
f01003c2:	c7 04 24 e9 6c 10 f0 	movl   $0xf0106ce9,(%esp)
f01003c9:	e8 50 40 00 00       	call   f010441e <cprintf>
	va_end(ap);
}
f01003ce:	83 c4 14             	add    $0x14,%esp
f01003d1:	5b                   	pop    %ebx
f01003d2:	5d                   	pop    %ebp
f01003d3:	c3                   	ret    
	...

f01003e0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01003e0:	55                   	push   %ebp
f01003e1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003e3:	ba 84 00 00 00       	mov    $0x84,%edx
f01003e8:	ec                   	in     (%dx),%al
f01003e9:	ec                   	in     (%dx),%al
f01003ea:	ec                   	in     (%dx),%al
f01003eb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01003ec:	5d                   	pop    %ebp
f01003ed:	c3                   	ret    

f01003ee <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01003ee:	55                   	push   %ebp
f01003ef:	89 e5                	mov    %esp,%ebp
f01003f1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003f6:	ec                   	in     (%dx),%al
f01003f7:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01003f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01003fe:	f6 c2 01             	test   $0x1,%dl
f0100401:	74 09                	je     f010040c <serial_proc_data+0x1e>
f0100403:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100408:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100409:	0f b6 c0             	movzbl %al,%eax
}
f010040c:	5d                   	pop    %ebp
f010040d:	c3                   	ret    

f010040e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010040e:	55                   	push   %ebp
f010040f:	89 e5                	mov    %esp,%ebp
f0100411:	53                   	push   %ebx
f0100412:	83 ec 04             	sub    $0x4,%esp
f0100415:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100417:	eb 25                	jmp    f010043e <cons_intr+0x30>
		if (c == 0)
f0100419:	85 c0                	test   %eax,%eax
f010041b:	74 21                	je     f010043e <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f010041d:	8b 15 24 52 22 f0    	mov    0xf0225224,%edx
f0100423:	88 82 20 50 22 f0    	mov    %al,-0xfddafe0(%edx)
f0100429:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f010042c:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100431:	ba 00 00 00 00       	mov    $0x0,%edx
f0100436:	0f 44 c2             	cmove  %edx,%eax
f0100439:	a3 24 52 22 f0       	mov    %eax,0xf0225224
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010043e:	ff d3                	call   *%ebx
f0100440:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100443:	75 d4                	jne    f0100419 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100445:	83 c4 04             	add    $0x4,%esp
f0100448:	5b                   	pop    %ebx
f0100449:	5d                   	pop    %ebp
f010044a:	c3                   	ret    

f010044b <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010044b:	55                   	push   %ebp
f010044c:	89 e5                	mov    %esp,%ebp
f010044e:	57                   	push   %edi
f010044f:	56                   	push   %esi
f0100450:	53                   	push   %ebx
f0100451:	83 ec 2c             	sub    $0x2c,%esp
f0100454:	89 c7                	mov    %eax,%edi
f0100456:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010045b:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010045c:	a8 20                	test   $0x20,%al
f010045e:	75 1b                	jne    f010047b <cons_putc+0x30>
f0100460:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100465:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010046a:	e8 71 ff ff ff       	call   f01003e0 <delay>
f010046f:	89 f2                	mov    %esi,%edx
f0100471:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100472:	a8 20                	test   $0x20,%al
f0100474:	75 05                	jne    f010047b <cons_putc+0x30>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100476:	83 eb 01             	sub    $0x1,%ebx
f0100479:	75 ef                	jne    f010046a <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010047b:	89 fa                	mov    %edi,%edx
f010047d:	89 f8                	mov    %edi,%eax
f010047f:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100482:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100487:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100488:	b2 79                	mov    $0x79,%dl
f010048a:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010048b:	84 c0                	test   %al,%al
f010048d:	78 21                	js     f01004b0 <cons_putc+0x65>
f010048f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100494:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100499:	e8 42 ff ff ff       	call   f01003e0 <delay>
f010049e:	89 f2                	mov    %esi,%edx
f01004a0:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01004a1:	84 c0                	test   %al,%al
f01004a3:	78 0b                	js     f01004b0 <cons_putc+0x65>
f01004a5:	83 c3 01             	add    $0x1,%ebx
f01004a8:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01004ae:	75 e9                	jne    f0100499 <cons_putc+0x4e>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004b0:	ba 78 03 00 00       	mov    $0x378,%edx
f01004b5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01004b9:	ee                   	out    %al,(%dx)
f01004ba:	b2 7a                	mov    $0x7a,%dl
f01004bc:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004c1:	ee                   	out    %al,(%dx)
f01004c2:	b8 08 00 00 00       	mov    $0x8,%eax
f01004c7:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!csa) csa = 0x0700;
f01004c8:	83 3d 88 5e 22 f0 00 	cmpl   $0x0,0xf0225e88
f01004cf:	75 0a                	jne    f01004db <cons_putc+0x90>
f01004d1:	c7 05 88 5e 22 f0 00 	movl   $0x700,0xf0225e88
f01004d8:	07 00 00 
	if (!(c & ~0xFF))
f01004db:	89 fa                	mov    %edi,%edx
f01004dd:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= csa;
f01004e3:	89 f8                	mov    %edi,%eax
f01004e5:	0b 05 88 5e 22 f0    	or     0xf0225e88,%eax
f01004eb:	85 d2                	test   %edx,%edx
f01004ed:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004f0:	89 f8                	mov    %edi,%eax
f01004f2:	25 ff 00 00 00       	and    $0xff,%eax
f01004f7:	83 f8 09             	cmp    $0x9,%eax
f01004fa:	74 7c                	je     f0100578 <cons_putc+0x12d>
f01004fc:	83 f8 09             	cmp    $0x9,%eax
f01004ff:	7f 0b                	jg     f010050c <cons_putc+0xc1>
f0100501:	83 f8 08             	cmp    $0x8,%eax
f0100504:	0f 85 a2 00 00 00    	jne    f01005ac <cons_putc+0x161>
f010050a:	eb 16                	jmp    f0100522 <cons_putc+0xd7>
f010050c:	83 f8 0a             	cmp    $0xa,%eax
f010050f:	90                   	nop
f0100510:	74 40                	je     f0100552 <cons_putc+0x107>
f0100512:	83 f8 0d             	cmp    $0xd,%eax
f0100515:	0f 85 91 00 00 00    	jne    f01005ac <cons_putc+0x161>
f010051b:	90                   	nop
f010051c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100520:	eb 38                	jmp    f010055a <cons_putc+0x10f>
	case '\b':
		if (crt_pos > 0) {
f0100522:	0f b7 05 00 50 22 f0 	movzwl 0xf0225000,%eax
f0100529:	66 85 c0             	test   %ax,%ax
f010052c:	0f 84 e4 00 00 00    	je     f0100616 <cons_putc+0x1cb>
			crt_pos--;
f0100532:	83 e8 01             	sub    $0x1,%eax
f0100535:	66 a3 00 50 22 f0    	mov    %ax,0xf0225000
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010053b:	0f b7 c0             	movzwl %ax,%eax
f010053e:	66 81 e7 00 ff       	and    $0xff00,%di
f0100543:	83 cf 20             	or     $0x20,%edi
f0100546:	8b 15 04 50 22 f0    	mov    0xf0225004,%edx
f010054c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100550:	eb 77                	jmp    f01005c9 <cons_putc+0x17e>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100552:	66 83 05 00 50 22 f0 	addw   $0x50,0xf0225000
f0100559:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010055a:	0f b7 05 00 50 22 f0 	movzwl 0xf0225000,%eax
f0100561:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100567:	c1 e8 16             	shr    $0x16,%eax
f010056a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010056d:	c1 e0 04             	shl    $0x4,%eax
f0100570:	66 a3 00 50 22 f0    	mov    %ax,0xf0225000
f0100576:	eb 51                	jmp    f01005c9 <cons_putc+0x17e>
		break;
	case '\t':
		cons_putc(' ');
f0100578:	b8 20 00 00 00       	mov    $0x20,%eax
f010057d:	e8 c9 fe ff ff       	call   f010044b <cons_putc>
		cons_putc(' ');
f0100582:	b8 20 00 00 00       	mov    $0x20,%eax
f0100587:	e8 bf fe ff ff       	call   f010044b <cons_putc>
		cons_putc(' ');
f010058c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100591:	e8 b5 fe ff ff       	call   f010044b <cons_putc>
		cons_putc(' ');
f0100596:	b8 20 00 00 00       	mov    $0x20,%eax
f010059b:	e8 ab fe ff ff       	call   f010044b <cons_putc>
		cons_putc(' ');
f01005a0:	b8 20 00 00 00       	mov    $0x20,%eax
f01005a5:	e8 a1 fe ff ff       	call   f010044b <cons_putc>
f01005aa:	eb 1d                	jmp    f01005c9 <cons_putc+0x17e>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01005ac:	0f b7 05 00 50 22 f0 	movzwl 0xf0225000,%eax
f01005b3:	0f b7 c8             	movzwl %ax,%ecx
f01005b6:	8b 15 04 50 22 f0    	mov    0xf0225004,%edx
f01005bc:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f01005c0:	83 c0 01             	add    $0x1,%eax
f01005c3:	66 a3 00 50 22 f0    	mov    %ax,0xf0225000
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005c9:	66 81 3d 00 50 22 f0 	cmpw   $0x7cf,0xf0225000
f01005d0:	cf 07 
f01005d2:	76 42                	jbe    f0100616 <cons_putc+0x1cb>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005d4:	a1 04 50 22 f0       	mov    0xf0225004,%eax
f01005d9:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005e0:	00 
f01005e1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005e7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005eb:	89 04 24             	mov    %eax,(%esp)
f01005ee:	e8 1d 59 00 00       	call   f0105f10 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005f3:	8b 15 04 50 22 f0    	mov    0xf0225004,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005f9:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005fe:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100604:	83 c0 01             	add    $0x1,%eax
f0100607:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010060c:	75 f0                	jne    f01005fe <cons_putc+0x1b3>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010060e:	66 83 2d 00 50 22 f0 	subw   $0x50,0xf0225000
f0100615:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100616:	8b 0d 08 50 22 f0    	mov    0xf0225008,%ecx
f010061c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100621:	89 ca                	mov    %ecx,%edx
f0100623:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100624:	0f b7 35 00 50 22 f0 	movzwl 0xf0225000,%esi
f010062b:	8d 59 01             	lea    0x1(%ecx),%ebx
f010062e:	89 f0                	mov    %esi,%eax
f0100630:	66 c1 e8 08          	shr    $0x8,%ax
f0100634:	89 da                	mov    %ebx,%edx
f0100636:	ee                   	out    %al,(%dx)
f0100637:	b8 0f 00 00 00       	mov    $0xf,%eax
f010063c:	89 ca                	mov    %ecx,%edx
f010063e:	ee                   	out    %al,(%dx)
f010063f:	89 f0                	mov    %esi,%eax
f0100641:	89 da                	mov    %ebx,%edx
f0100643:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100644:	83 c4 2c             	add    $0x2c,%esp
f0100647:	5b                   	pop    %ebx
f0100648:	5e                   	pop    %esi
f0100649:	5f                   	pop    %edi
f010064a:	5d                   	pop    %ebp
f010064b:	c3                   	ret    

f010064c <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010064c:	55                   	push   %ebp
f010064d:	89 e5                	mov    %esp,%ebp
f010064f:	53                   	push   %ebx
f0100650:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100653:	ba 64 00 00 00       	mov    $0x64,%edx
f0100658:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100659:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010065e:	a8 01                	test   $0x1,%al
f0100660:	0f 84 de 00 00 00    	je     f0100744 <kbd_proc_data+0xf8>
f0100666:	b2 60                	mov    $0x60,%dl
f0100668:	ec                   	in     (%dx),%al
f0100669:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010066b:	3c e0                	cmp    $0xe0,%al
f010066d:	75 11                	jne    f0100680 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f010066f:	83 0d 28 52 22 f0 40 	orl    $0x40,0xf0225228
		return 0;
f0100676:	bb 00 00 00 00       	mov    $0x0,%ebx
f010067b:	e9 c4 00 00 00       	jmp    f0100744 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f0100680:	84 c0                	test   %al,%al
f0100682:	79 37                	jns    f01006bb <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100684:	8b 0d 28 52 22 f0    	mov    0xf0225228,%ecx
f010068a:	89 cb                	mov    %ecx,%ebx
f010068c:	83 e3 40             	and    $0x40,%ebx
f010068f:	83 e0 7f             	and    $0x7f,%eax
f0100692:	85 db                	test   %ebx,%ebx
f0100694:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100697:	0f b6 d2             	movzbl %dl,%edx
f010069a:	0f b6 82 20 6e 10 f0 	movzbl -0xfef91e0(%edx),%eax
f01006a1:	83 c8 40             	or     $0x40,%eax
f01006a4:	0f b6 c0             	movzbl %al,%eax
f01006a7:	f7 d0                	not    %eax
f01006a9:	21 c1                	and    %eax,%ecx
f01006ab:	89 0d 28 52 22 f0    	mov    %ecx,0xf0225228
		return 0;
f01006b1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006b6:	e9 89 00 00 00       	jmp    f0100744 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01006bb:	8b 0d 28 52 22 f0    	mov    0xf0225228,%ecx
f01006c1:	f6 c1 40             	test   $0x40,%cl
f01006c4:	74 0e                	je     f01006d4 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01006c6:	89 c2                	mov    %eax,%edx
f01006c8:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01006cb:	83 e1 bf             	and    $0xffffffbf,%ecx
f01006ce:	89 0d 28 52 22 f0    	mov    %ecx,0xf0225228
	}

	shift |= shiftcode[data];
f01006d4:	0f b6 d2             	movzbl %dl,%edx
f01006d7:	0f b6 82 20 6e 10 f0 	movzbl -0xfef91e0(%edx),%eax
f01006de:	0b 05 28 52 22 f0    	or     0xf0225228,%eax
	shift ^= togglecode[data];
f01006e4:	0f b6 8a 20 6f 10 f0 	movzbl -0xfef90e0(%edx),%ecx
f01006eb:	31 c8                	xor    %ecx,%eax
f01006ed:	a3 28 52 22 f0       	mov    %eax,0xf0225228

	c = charcode[shift & (CTL | SHIFT)][data];
f01006f2:	89 c1                	mov    %eax,%ecx
f01006f4:	83 e1 03             	and    $0x3,%ecx
f01006f7:	8b 0c 8d 20 70 10 f0 	mov    -0xfef8fe0(,%ecx,4),%ecx
f01006fe:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100702:	a8 08                	test   $0x8,%al
f0100704:	74 19                	je     f010071f <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f0100706:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100709:	83 fa 19             	cmp    $0x19,%edx
f010070c:	77 05                	ja     f0100713 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f010070e:	83 eb 20             	sub    $0x20,%ebx
f0100711:	eb 0c                	jmp    f010071f <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f0100713:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f0100716:	8d 53 20             	lea    0x20(%ebx),%edx
f0100719:	83 f9 19             	cmp    $0x19,%ecx
f010071c:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010071f:	f7 d0                	not    %eax
f0100721:	a8 06                	test   $0x6,%al
f0100723:	75 1f                	jne    f0100744 <kbd_proc_data+0xf8>
f0100725:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010072b:	75 17                	jne    f0100744 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f010072d:	c7 04 24 db 6d 10 f0 	movl   $0xf0106ddb,(%esp)
f0100734:	e8 e5 3c 00 00       	call   f010441e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100739:	ba 92 00 00 00       	mov    $0x92,%edx
f010073e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100743:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100744:	89 d8                	mov    %ebx,%eax
f0100746:	83 c4 14             	add    $0x14,%esp
f0100749:	5b                   	pop    %ebx
f010074a:	5d                   	pop    %ebp
f010074b:	c3                   	ret    

f010074c <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010074c:	55                   	push   %ebp
f010074d:	89 e5                	mov    %esp,%ebp
f010074f:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100752:	80 3d 0c 50 22 f0 00 	cmpb   $0x0,0xf022500c
f0100759:	74 0a                	je     f0100765 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010075b:	b8 ee 03 10 f0       	mov    $0xf01003ee,%eax
f0100760:	e8 a9 fc ff ff       	call   f010040e <cons_intr>
}
f0100765:	c9                   	leave  
f0100766:	c3                   	ret    

f0100767 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100767:	55                   	push   %ebp
f0100768:	89 e5                	mov    %esp,%ebp
f010076a:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010076d:	b8 4c 06 10 f0       	mov    $0xf010064c,%eax
f0100772:	e8 97 fc ff ff       	call   f010040e <cons_intr>
}
f0100777:	c9                   	leave  
f0100778:	c3                   	ret    

f0100779 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100779:	55                   	push   %ebp
f010077a:	89 e5                	mov    %esp,%ebp
f010077c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010077f:	e8 c8 ff ff ff       	call   f010074c <serial_intr>
	kbd_intr();
f0100784:	e8 de ff ff ff       	call   f0100767 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100789:	8b 15 20 52 22 f0    	mov    0xf0225220,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f010078f:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100794:	3b 15 24 52 22 f0    	cmp    0xf0225224,%edx
f010079a:	74 1e                	je     f01007ba <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010079c:	0f b6 82 20 50 22 f0 	movzbl -0xfddafe0(%edx),%eax
f01007a3:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f01007a6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01007ac:	b9 00 00 00 00       	mov    $0x0,%ecx
f01007b1:	0f 44 d1             	cmove  %ecx,%edx
f01007b4:	89 15 20 52 22 f0    	mov    %edx,0xf0225220
		return c;
	}
	return 0;
}
f01007ba:	c9                   	leave  
f01007bb:	c3                   	ret    

f01007bc <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01007bc:	55                   	push   %ebp
f01007bd:	89 e5                	mov    %esp,%ebp
f01007bf:	57                   	push   %edi
f01007c0:	56                   	push   %esi
f01007c1:	53                   	push   %ebx
f01007c2:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01007c5:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01007cc:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01007d3:	5a a5 
	if (*cp != 0xA55A) {
f01007d5:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01007dc:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01007e0:	74 11                	je     f01007f3 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01007e2:	c7 05 08 50 22 f0 b4 	movl   $0x3b4,0xf0225008
f01007e9:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01007ec:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01007f1:	eb 16                	jmp    f0100809 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01007f3:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01007fa:	c7 05 08 50 22 f0 d4 	movl   $0x3d4,0xf0225008
f0100801:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100804:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100809:	8b 0d 08 50 22 f0    	mov    0xf0225008,%ecx
f010080f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100814:	89 ca                	mov    %ecx,%edx
f0100816:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100817:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010081a:	89 da                	mov    %ebx,%edx
f010081c:	ec                   	in     (%dx),%al
f010081d:	0f b6 f8             	movzbl %al,%edi
f0100820:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100823:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100828:	89 ca                	mov    %ecx,%edx
f010082a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010082b:	89 da                	mov    %ebx,%edx
f010082d:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010082e:	89 35 04 50 22 f0    	mov    %esi,0xf0225004

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100834:	0f b6 d8             	movzbl %al,%ebx
f0100837:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100839:	66 89 3d 00 50 22 f0 	mov    %di,0xf0225000

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100840:	e8 22 ff ff ff       	call   f0100767 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100845:	0f b7 05 90 23 12 f0 	movzwl 0xf0122390,%eax
f010084c:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100851:	89 04 24             	mov    %eax,(%esp)
f0100854:	e8 83 3a 00 00       	call   f01042dc <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100859:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010085e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100863:	89 da                	mov    %ebx,%edx
f0100865:	ee                   	out    %al,(%dx)
f0100866:	b2 fb                	mov    $0xfb,%dl
f0100868:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010086d:	ee                   	out    %al,(%dx)
f010086e:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100873:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100878:	89 ca                	mov    %ecx,%edx
f010087a:	ee                   	out    %al,(%dx)
f010087b:	b2 f9                	mov    $0xf9,%dl
f010087d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100882:	ee                   	out    %al,(%dx)
f0100883:	b2 fb                	mov    $0xfb,%dl
f0100885:	b8 03 00 00 00       	mov    $0x3,%eax
f010088a:	ee                   	out    %al,(%dx)
f010088b:	b2 fc                	mov    $0xfc,%dl
f010088d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100892:	ee                   	out    %al,(%dx)
f0100893:	b2 f9                	mov    $0xf9,%dl
f0100895:	b8 01 00 00 00       	mov    $0x1,%eax
f010089a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010089b:	b2 fd                	mov    $0xfd,%dl
f010089d:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010089e:	3c ff                	cmp    $0xff,%al
f01008a0:	0f 95 c0             	setne  %al
f01008a3:	89 c6                	mov    %eax,%esi
f01008a5:	a2 0c 50 22 f0       	mov    %al,0xf022500c
f01008aa:	89 da                	mov    %ebx,%edx
f01008ac:	ec                   	in     (%dx),%al
f01008ad:	89 ca                	mov    %ecx,%edx
f01008af:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01008b0:	89 f0                	mov    %esi,%eax
f01008b2:	84 c0                	test   %al,%al
f01008b4:	75 0c                	jne    f01008c2 <cons_init+0x106>
		cprintf("Serial port does not exist!\n");
f01008b6:	c7 04 24 e7 6d 10 f0 	movl   $0xf0106de7,(%esp)
f01008bd:	e8 5c 3b 00 00       	call   f010441e <cprintf>
}
f01008c2:	83 c4 1c             	add    $0x1c,%esp
f01008c5:	5b                   	pop    %ebx
f01008c6:	5e                   	pop    %esi
f01008c7:	5f                   	pop    %edi
f01008c8:	5d                   	pop    %ebp
f01008c9:	c3                   	ret    

f01008ca <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01008ca:	55                   	push   %ebp
f01008cb:	89 e5                	mov    %esp,%ebp
f01008cd:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01008d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01008d3:	e8 73 fb ff ff       	call   f010044b <cons_putc>
}
f01008d8:	c9                   	leave  
f01008d9:	c3                   	ret    

f01008da <getchar>:

int
getchar(void)
{
f01008da:	55                   	push   %ebp
f01008db:	89 e5                	mov    %esp,%ebp
f01008dd:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01008e0:	e8 94 fe ff ff       	call   f0100779 <cons_getc>
f01008e5:	85 c0                	test   %eax,%eax
f01008e7:	74 f7                	je     f01008e0 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01008e9:	c9                   	leave  
f01008ea:	c3                   	ret    

f01008eb <iscons>:

int
iscons(int fdnum)
{
f01008eb:	55                   	push   %ebp
f01008ec:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01008ee:	b8 01 00 00 00       	mov    $0x1,%eax
f01008f3:	5d                   	pop    %ebp
f01008f4:	c3                   	ret    
	...

f0100900 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100900:	55                   	push   %ebp
f0100901:	89 e5                	mov    %esp,%ebp
f0100903:	56                   	push   %esi
f0100904:	53                   	push   %ebx
f0100905:	83 ec 10             	sub    $0x10,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100908:	89 eb                	mov    %ebp,%ebx
	uint32_t* ebp = (uint32_t*) read_ebp();
f010090a:	89 de                	mov    %ebx,%esi
	cprintf("Stack backtrace:\n");
f010090c:	c7 04 24 30 70 10 f0 	movl   $0xf0107030,(%esp)
f0100913:	e8 06 3b 00 00       	call   f010441e <cprintf>
	while (ebp) {
f0100918:	85 db                	test   %ebx,%ebx
f010091a:	74 49                	je     f0100965 <mon_backtrace+0x65>
		cprintf("ebp %x  eip %x  args", ebp, ebp[1]);
f010091c:	8b 46 04             	mov    0x4(%esi),%eax
f010091f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100923:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100927:	c7 04 24 42 70 10 f0 	movl   $0xf0107042,(%esp)
f010092e:	e8 eb 3a 00 00       	call   f010441e <cprintf>
		int i;
		for (i = 2; i <= 6; ++i)
f0100933:	bb 02 00 00 00       	mov    $0x2,%ebx
			cprintf(" %08.x", ebp[i]);
f0100938:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
f010093b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010093f:	c7 04 24 57 70 10 f0 	movl   $0xf0107057,(%esp)
f0100946:	e8 d3 3a 00 00       	call   f010441e <cprintf>
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
		cprintf("ebp %x  eip %x  args", ebp, ebp[1]);
		int i;
		for (i = 2; i <= 6; ++i)
f010094b:	83 c3 01             	add    $0x1,%ebx
f010094e:	83 fb 07             	cmp    $0x7,%ebx
f0100951:	75 e5                	jne    f0100938 <mon_backtrace+0x38>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
f0100953:	c7 04 24 e9 6c 10 f0 	movl   $0xf0106ce9,(%esp)
f010095a:	e8 bf 3a 00 00       	call   f010441e <cprintf>
		ebp = (uint32_t*) *ebp;
f010095f:	8b 36                	mov    (%esi),%esi
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f0100961:	85 f6                	test   %esi,%esi
f0100963:	75 b7                	jne    f010091c <mon_backtrace+0x1c>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
		ebp = (uint32_t*) *ebp;
	}
	return 0;
}
f0100965:	b8 00 00 00 00       	mov    $0x0,%eax
f010096a:	83 c4 10             	add    $0x10,%esp
f010096d:	5b                   	pop    %ebx
f010096e:	5e                   	pop    %esi
f010096f:	5d                   	pop    %ebp
f0100970:	c3                   	ret    

f0100971 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100971:	55                   	push   %ebp
f0100972:	89 e5                	mov    %esp,%ebp
f0100974:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100977:	c7 04 24 5e 70 10 f0 	movl   $0xf010705e,(%esp)
f010097e:	e8 9b 3a 00 00       	call   f010441e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100983:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010098a:	00 
f010098b:	c7 04 24 e4 71 10 f0 	movl   $0xf01071e4,(%esp)
f0100992:	e8 87 3a 00 00       	call   f010441e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100997:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010099e:	00 
f010099f:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01009a6:	f0 
f01009a7:	c7 04 24 0c 72 10 f0 	movl   $0xf010720c,(%esp)
f01009ae:	e8 6b 3a 00 00       	call   f010441e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01009b3:	c7 44 24 08 35 6c 10 	movl   $0x106c35,0x8(%esp)
f01009ba:	00 
f01009bb:	c7 44 24 04 35 6c 10 	movl   $0xf0106c35,0x4(%esp)
f01009c2:	f0 
f01009c3:	c7 04 24 30 72 10 f0 	movl   $0xf0107230,(%esp)
f01009ca:	e8 4f 3a 00 00       	call   f010441e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01009cf:	c7 44 24 08 2a 42 22 	movl   $0x22422a,0x8(%esp)
f01009d6:	00 
f01009d7:	c7 44 24 04 2a 42 22 	movl   $0xf022422a,0x4(%esp)
f01009de:	f0 
f01009df:	c7 04 24 54 72 10 f0 	movl   $0xf0107254,(%esp)
f01009e6:	e8 33 3a 00 00       	call   f010441e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01009eb:	c7 44 24 08 08 70 26 	movl   $0x267008,0x8(%esp)
f01009f2:	00 
f01009f3:	c7 44 24 04 08 70 26 	movl   $0xf0267008,0x4(%esp)
f01009fa:	f0 
f01009fb:	c7 04 24 78 72 10 f0 	movl   $0xf0107278,(%esp)
f0100a02:	e8 17 3a 00 00       	call   f010441e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100a07:	b8 07 74 26 f0       	mov    $0xf0267407,%eax
f0100a0c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100a11:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100a16:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100a1c:	85 c0                	test   %eax,%eax
f0100a1e:	0f 48 c2             	cmovs  %edx,%eax
f0100a21:	c1 f8 0a             	sar    $0xa,%eax
f0100a24:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a28:	c7 04 24 9c 72 10 f0 	movl   $0xf010729c,(%esp)
f0100a2f:	e8 ea 39 00 00       	call   f010441e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100a34:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a39:	c9                   	leave  
f0100a3a:	c3                   	ret    

f0100a3b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100a3b:	55                   	push   %ebp
f0100a3c:	89 e5                	mov    %esp,%ebp
f0100a3e:	53                   	push   %ebx
f0100a3f:	83 ec 14             	sub    $0x14,%esp
f0100a42:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100a47:	8b 83 04 74 10 f0    	mov    -0xfef8bfc(%ebx),%eax
f0100a4d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a51:	8b 83 00 74 10 f0    	mov    -0xfef8c00(%ebx),%eax
f0100a57:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a5b:	c7 04 24 77 70 10 f0 	movl   $0xf0107077,(%esp)
f0100a62:	e8 b7 39 00 00       	call   f010441e <cprintf>
f0100a67:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100a6a:	83 fb 6c             	cmp    $0x6c,%ebx
f0100a6d:	75 d8                	jne    f0100a47 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100a6f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a74:	83 c4 14             	add    $0x14,%esp
f0100a77:	5b                   	pop    %ebx
f0100a78:	5d                   	pop    %ebp
f0100a79:	c3                   	ret    

f0100a7a <csa_backtrace>:
	return 0;
}

int
csa_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100a7a:	55                   	push   %ebp
f0100a7b:	89 e5                	mov    %esp,%ebp
f0100a7d:	57                   	push   %edi
f0100a7e:	56                   	push   %esi
f0100a7f:	53                   	push   %ebx
f0100a80:	83 ec 4c             	sub    $0x4c,%esp
f0100a83:	89 eb                	mov    %ebp,%ebx
	uint32_t* ebp = (uint32_t*) read_ebp();
f0100a85:	89 de                	mov    %ebx,%esi
	cprintf("Stack backtrace:\n");
f0100a87:	c7 04 24 30 70 10 f0 	movl   $0xf0107030,(%esp)
f0100a8e:	e8 8b 39 00 00       	call   f010441e <cprintf>
	while (ebp) {
f0100a93:	85 db                	test   %ebx,%ebx
f0100a95:	0f 84 8b 00 00 00    	je     f0100b26 <csa_backtrace+0xac>
		uint32_t eip = ebp[1];
f0100a9b:	8b 7e 04             	mov    0x4(%esi),%edi
		cprintf("ebp %x  eip %x  args", ebp, eip);
f0100a9e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100aa2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100aa6:	c7 04 24 42 70 10 f0 	movl   $0xf0107042,(%esp)
f0100aad:	e8 6c 39 00 00       	call   f010441e <cprintf>
		int i;
		for (i = 2; i <= 6; ++i)
f0100ab2:	bb 02 00 00 00       	mov    $0x2,%ebx
			cprintf(" %08.x", ebp[i]);
f0100ab7:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
f0100aba:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100abe:	c7 04 24 57 70 10 f0 	movl   $0xf0107057,(%esp)
f0100ac5:	e8 54 39 00 00       	call   f010441e <cprintf>
	cprintf("Stack backtrace:\n");
	while (ebp) {
		uint32_t eip = ebp[1];
		cprintf("ebp %x  eip %x  args", ebp, eip);
		int i;
		for (i = 2; i <= 6; ++i)
f0100aca:	83 c3 01             	add    $0x1,%ebx
f0100acd:	83 fb 07             	cmp    $0x7,%ebx
f0100ad0:	75 e5                	jne    f0100ab7 <csa_backtrace+0x3d>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
f0100ad2:	c7 04 24 e9 6c 10 f0 	movl   $0xf0106ce9,(%esp)
f0100ad9:	e8 40 39 00 00       	call   f010441e <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f0100ade:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ae5:	89 3c 24             	mov    %edi,(%esp)
f0100ae8:	e8 35 48 00 00       	call   f0105322 <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n", 
f0100aed:	2b 7d e0             	sub    -0x20(%ebp),%edi
f0100af0:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0100af4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100af7:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100afb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100afe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b02:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100b05:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b09:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b10:	c7 04 24 80 70 10 f0 	movl   $0xf0107080,(%esp)
f0100b17:	e8 02 39 00 00       	call   f010441e <cprintf>
			info.eip_file, info.eip_line,
			info.eip_fn_namelen, info.eip_fn_name,
			eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
		ebp = (uint32_t*) *ebp;
f0100b1c:	8b 36                	mov    (%esi),%esi
int
csa_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f0100b1e:	85 f6                	test   %esi,%esi
f0100b20:	0f 85 75 ff ff ff    	jne    f0100a9b <csa_backtrace+0x21>
			eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
		ebp = (uint32_t*) *ebp;
	}
	return 0;
}
f0100b26:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b2b:	83 c4 4c             	add    $0x4c,%esp
f0100b2e:	5b                   	pop    %ebx
f0100b2f:	5e                   	pop    %esi
f0100b30:	5f                   	pop    %edi
f0100b31:	5d                   	pop    %ebp
f0100b32:	c3                   	ret    

f0100b33 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100b33:	55                   	push   %ebp
f0100b34:	89 e5                	mov    %esp,%ebp
f0100b36:	57                   	push   %edi
f0100b37:	56                   	push   %esi
f0100b38:	53                   	push   %ebx
f0100b39:	83 ec 6c             	sub    $0x6c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100b3c:	c7 04 24 c8 72 10 f0 	movl   $0xf01072c8,(%esp)
f0100b43:	e8 d6 38 00 00       	call   f010441e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100b48:	c7 04 24 ec 72 10 f0 	movl   $0xf01072ec,(%esp)
f0100b4f:	e8 ca 38 00 00       	call   f010441e <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n", 
f0100b54:	c7 44 24 18 91 70 10 	movl   $0xf0107091,0x18(%esp)
f0100b5b:	f0 
f0100b5c:	c7 44 24 14 00 04 00 	movl   $0x400,0x14(%esp)
f0100b63:	00 
f0100b64:	c7 44 24 10 95 70 10 	movl   $0xf0107095,0x10(%esp)
f0100b6b:	f0 
f0100b6c:	c7 44 24 0c 00 02 00 	movl   $0x200,0xc(%esp)
f0100b73:	00 
f0100b74:	c7 44 24 08 9b 70 10 	movl   $0xf010709b,0x8(%esp)
f0100b7b:	f0 
f0100b7c:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
f0100b83:	00 
f0100b84:	c7 04 24 a0 70 10 f0 	movl   $0xf01070a0,(%esp)
f0100b8b:	e8 8e 38 00 00       	call   f010441e <cprintf>
		0x0100, "blue", 0x0200, "green", 0x0400, "red");

	if (tf != NULL)
f0100b90:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100b94:	74 0b                	je     f0100ba1 <monitor+0x6e>
		print_trapframe(tf);
f0100b96:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b99:	89 04 24             	mov    %eax,(%esp)
f0100b9c:	e8 16 3b 00 00       	call   f01046b7 <print_trapframe>
	// asm volatile("or $0x0100, %%eax\n":::);
	// asm volatile("\tpushl %%eax\n":::);
	// asm volatile("\tpopf\n":::);
	// asm volatile("\tjmp *%0\n":: "g" (&tf->tf_eip): "memory");
	while (1) {
		buf = readline("K> ");
f0100ba1:	c7 04 24 b0 70 10 f0 	movl   $0xf01070b0,(%esp)
f0100ba8:	e8 63 50 00 00       	call   f0105c10 <readline>
f0100bad:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100baf:	85 c0                	test   %eax,%eax
f0100bb1:	74 ee                	je     f0100ba1 <monitor+0x6e>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100bb3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100bba:	be 00 00 00 00       	mov    $0x0,%esi
f0100bbf:	eb 06                	jmp    f0100bc7 <monitor+0x94>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100bc1:	c6 03 00             	movb   $0x0,(%ebx)
f0100bc4:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100bc7:	0f b6 03             	movzbl (%ebx),%eax
f0100bca:	84 c0                	test   %al,%al
f0100bcc:	74 6d                	je     f0100c3b <monitor+0x108>
f0100bce:	0f be c0             	movsbl %al,%eax
f0100bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bd5:	c7 04 24 b4 70 10 f0 	movl   $0xf01070b4,(%esp)
f0100bdc:	e8 71 52 00 00       	call   f0105e52 <strchr>
f0100be1:	85 c0                	test   %eax,%eax
f0100be3:	75 dc                	jne    f0100bc1 <monitor+0x8e>
			*buf++ = 0;
		if (*buf == 0)
f0100be5:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100be8:	74 51                	je     f0100c3b <monitor+0x108>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100bea:	83 fe 0f             	cmp    $0xf,%esi
f0100bed:	8d 76 00             	lea    0x0(%esi),%esi
f0100bf0:	75 16                	jne    f0100c08 <monitor+0xd5>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100bf2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100bf9:	00 
f0100bfa:	c7 04 24 b9 70 10 f0 	movl   $0xf01070b9,(%esp)
f0100c01:	e8 18 38 00 00       	call   f010441e <cprintf>
f0100c06:	eb 99                	jmp    f0100ba1 <monitor+0x6e>
			return 0;
		}
		argv[argc++] = buf;
f0100c08:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100c0c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100c0f:	0f b6 03             	movzbl (%ebx),%eax
f0100c12:	84 c0                	test   %al,%al
f0100c14:	75 0c                	jne    f0100c22 <monitor+0xef>
f0100c16:	eb af                	jmp    f0100bc7 <monitor+0x94>
			buf++;
f0100c18:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100c1b:	0f b6 03             	movzbl (%ebx),%eax
f0100c1e:	84 c0                	test   %al,%al
f0100c20:	74 a5                	je     f0100bc7 <monitor+0x94>
f0100c22:	0f be c0             	movsbl %al,%eax
f0100c25:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c29:	c7 04 24 b4 70 10 f0 	movl   $0xf01070b4,(%esp)
f0100c30:	e8 1d 52 00 00       	call   f0105e52 <strchr>
f0100c35:	85 c0                	test   %eax,%eax
f0100c37:	74 df                	je     f0100c18 <monitor+0xe5>
f0100c39:	eb 8c                	jmp    f0100bc7 <monitor+0x94>
			buf++;
	}
	argv[argc] = 0;
f0100c3b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100c42:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100c43:	85 f6                	test   %esi,%esi
f0100c45:	0f 84 56 ff ff ff    	je     f0100ba1 <monitor+0x6e>
f0100c4b:	bb 00 74 10 f0       	mov    $0xf0107400,%ebx
f0100c50:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100c55:	8b 03                	mov    (%ebx),%eax
f0100c57:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c5b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c5e:	89 04 24             	mov    %eax,(%esp)
f0100c61:	e8 72 51 00 00       	call   f0105dd8 <strcmp>
f0100c66:	85 c0                	test   %eax,%eax
f0100c68:	75 23                	jne    f0100c8d <monitor+0x15a>
			return commands[i].func(argc, argv, tf);
f0100c6a:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100c6d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c70:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c74:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100c77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c7b:	89 34 24             	mov    %esi,(%esp)
f0100c7e:	ff 97 08 74 10 f0    	call   *-0xfef8bf8(%edi)
	// asm volatile("\tpopf\n":::);
	// asm volatile("\tjmp *%0\n":: "g" (&tf->tf_eip): "memory");
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100c84:	85 c0                	test   %eax,%eax
f0100c86:	78 28                	js     f0100cb0 <monitor+0x17d>
f0100c88:	e9 14 ff ff ff       	jmp    f0100ba1 <monitor+0x6e>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100c8d:	83 c7 01             	add    $0x1,%edi
f0100c90:	83 c3 0c             	add    $0xc,%ebx
f0100c93:	83 ff 09             	cmp    $0x9,%edi
f0100c96:	75 bd                	jne    f0100c55 <monitor+0x122>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100c98:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c9f:	c7 04 24 d6 70 10 f0 	movl   $0xf01070d6,(%esp)
f0100ca6:	e8 73 37 00 00       	call   f010441e <cprintf>
f0100cab:	e9 f1 fe ff ff       	jmp    f0100ba1 <monitor+0x6e>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100cb0:	83 c4 6c             	add    $0x6c,%esp
f0100cb3:	5b                   	pop    %ebx
f0100cb4:	5e                   	pop    %esi
f0100cb5:	5f                   	pop    %edi
f0100cb6:	5d                   	pop    %ebp
f0100cb7:	c3                   	ret    

f0100cb8 <xtoi>:

uint32_t xtoi(char* buf) {
f0100cb8:	55                   	push   %ebp
f0100cb9:	89 e5                	mov    %esp,%ebp
f0100cbb:	8b 45 08             	mov    0x8(%ebp),%eax
	uint32_t res = 0;
	buf += 2; //0x...
f0100cbe:	8d 50 02             	lea    0x2(%eax),%edx
	while (*buf) { 
f0100cc1:	0f b6 48 02          	movzbl 0x2(%eax),%ecx
				break;
	}
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
f0100cc5:	b8 00 00 00 00       	mov    $0x0,%eax
	buf += 2; //0x...
	while (*buf) { 
f0100cca:	84 c9                	test   %cl,%cl
f0100ccc:	74 1e                	je     f0100cec <xtoi+0x34>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
f0100cce:	80 f9 60             	cmp    $0x60,%cl
f0100cd1:	7e 05                	jle    f0100cd8 <xtoi+0x20>
f0100cd3:	83 e9 27             	sub    $0x27,%ecx
f0100cd6:	88 0a                	mov    %cl,(%edx)
		res = res*16 + *buf - '0';
f0100cd8:	c1 e0 04             	shl    $0x4,%eax
f0100cdb:	0f be 0a             	movsbl (%edx),%ecx
f0100cde:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
		++buf;
f0100ce2:	83 c2 01             	add    $0x1,%edx
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
	buf += 2; //0x...
	while (*buf) { 
f0100ce5:	0f b6 0a             	movzbl (%edx),%ecx
f0100ce8:	84 c9                	test   %cl,%cl
f0100cea:	75 e2                	jne    f0100cce <xtoi+0x16>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
		res = res*16 + *buf - '0';
		++buf;
	}
	return res;
}
f0100cec:	5d                   	pop    %ebp
f0100ced:	c3                   	ret    

f0100cee <showvm>:
	cprintf("%x after  setm: ", addr);
	pprint(pte);
	return 0;
}

int showvm(int argc, char **argv, struct Trapframe *tf) {
f0100cee:	55                   	push   %ebp
f0100cef:	89 e5                	mov    %esp,%ebp
f0100cf1:	57                   	push   %edi
f0100cf2:	56                   	push   %esi
f0100cf3:	53                   	push   %ebx
f0100cf4:	83 ec 1c             	sub    $0x1c,%esp
f0100cf7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc == 1) {
f0100cfa:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100cfe:	75 0e                	jne    f0100d0e <showvm+0x20>
		cprintf("Usage: showvm 0xaddr 0xn\n");
f0100d00:	c7 04 24 ec 70 10 f0 	movl   $0xf01070ec,(%esp)
f0100d07:	e8 12 37 00 00       	call   f010441e <cprintf>
		return 0;
f0100d0c:	eb 4a                	jmp    f0100d58 <showvm+0x6a>
	}
	void** addr = (void**) xtoi(argv[1]);
f0100d0e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100d11:	89 04 24             	mov    %eax,(%esp)
f0100d14:	e8 9f ff ff ff       	call   f0100cb8 <xtoi>
f0100d19:	89 c6                	mov    %eax,%esi
	uint32_t n = xtoi(argv[2]);
f0100d1b:	8b 43 08             	mov    0x8(%ebx),%eax
f0100d1e:	89 04 24             	mov    %eax,(%esp)
f0100d21:	e8 92 ff ff ff       	call   f0100cb8 <xtoi>
f0100d26:	89 c7                	mov    %eax,%edi
	int i;
	for (i = 0; i < n; ++i)
f0100d28:	85 c0                	test   %eax,%eax
f0100d2a:	74 2c                	je     f0100d58 <showvm+0x6a>
f0100d2c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d31:	bb 00 00 00 00       	mov    $0x0,%ebx
		cprintf("VM at %x is %x\n", addr+i, addr[i]);
f0100d36:	8d 04 86             	lea    (%esi,%eax,4),%eax
f0100d39:	8b 10                	mov    (%eax),%edx
f0100d3b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d43:	c7 04 24 06 71 10 f0 	movl   $0xf0107106,(%esp)
f0100d4a:	e8 cf 36 00 00       	call   f010441e <cprintf>
		return 0;
	}
	void** addr = (void**) xtoi(argv[1]);
	uint32_t n = xtoi(argv[2]);
	int i;
	for (i = 0; i < n; ++i)
f0100d4f:	83 c3 01             	add    $0x1,%ebx
f0100d52:	89 d8                	mov    %ebx,%eax
f0100d54:	39 df                	cmp    %ebx,%edi
f0100d56:	77 de                	ja     f0100d36 <showvm+0x48>
		cprintf("VM at %x is %x\n", addr+i, addr[i]);
	return 0;
}
f0100d58:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d5d:	83 c4 1c             	add    $0x1c,%esp
f0100d60:	5b                   	pop    %ebx
f0100d61:	5e                   	pop    %esi
f0100d62:	5f                   	pop    %edi
f0100d63:	5d                   	pop    %ebp
f0100d64:	c3                   	ret    

f0100d65 <pprint>:
		res = res*16 + *buf - '0';
		++buf;
	}
	return res;
}
void pprint(pte_t *pte) {
f0100d65:	55                   	push   %ebp
f0100d66:	89 e5                	mov    %esp,%ebp
f0100d68:	83 ec 18             	sub    $0x18,%esp
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
f0100d6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d6e:	8b 00                	mov    (%eax),%eax
		++buf;
	}
	return res;
}
void pprint(pte_t *pte) {
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
f0100d70:	89 c2                	mov    %eax,%edx
f0100d72:	83 e2 04             	and    $0x4,%edx
f0100d75:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d79:	89 c2                	mov    %eax,%edx
f0100d7b:	83 e2 02             	and    $0x2,%edx
f0100d7e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100d82:	83 e0 01             	and    $0x1,%eax
f0100d85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d89:	c7 04 24 14 73 10 f0 	movl   $0xf0107314,(%esp)
f0100d90:	e8 89 36 00 00       	call   f010441e <cprintf>
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
}
f0100d95:	c9                   	leave  
f0100d96:	c3                   	ret    

f0100d97 <setm>:
		} else cprintf("page not exist: %x\n", begin);
	}
	return 0;
}

int setm(int argc, char **argv, struct Trapframe *tf) {
f0100d97:	55                   	push   %ebp
f0100d98:	89 e5                	mov    %esp,%ebp
f0100d9a:	83 ec 28             	sub    $0x28,%esp
f0100d9d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100da0:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100da3:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100da6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc == 1) {
f0100da9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100dad:	75 11                	jne    f0100dc0 <setm+0x29>
		cprintf("Usage: setm 0xaddr [0|1 :clear or set] [P|W|U]\n");
f0100daf:	c7 04 24 38 73 10 f0 	movl   $0xf0107338,(%esp)
f0100db6:	e8 63 36 00 00       	call   f010441e <cprintf>
		return 0;
f0100dbb:	e9 88 00 00 00       	jmp    f0100e48 <setm+0xb1>
	}
	uint32_t addr = xtoi(argv[1]);
f0100dc0:	8b 43 04             	mov    0x4(%ebx),%eax
f0100dc3:	89 04 24             	mov    %eax,(%esp)
f0100dc6:	e8 ed fe ff ff       	call   f0100cb8 <xtoi>
f0100dcb:	89 c7                	mov    %eax,%edi
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
f0100dcd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100dd4:	00 
f0100dd5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dd9:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0100dde:	89 04 24             	mov    %eax,(%esp)
f0100de1:	e8 e0 07 00 00       	call   f01015c6 <pgdir_walk>
f0100de6:	89 c6                	mov    %eax,%esi
	cprintf("%x before setm: ", addr);
f0100de8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100dec:	c7 04 24 16 71 10 f0 	movl   $0xf0107116,(%esp)
f0100df3:	e8 26 36 00 00       	call   f010441e <cprintf>
	pprint(pte);
f0100df8:	89 34 24             	mov    %esi,(%esp)
f0100dfb:	e8 65 ff ff ff       	call   f0100d65 <pprint>
	uint32_t perm = 0;
	if (argv[3][0] == 'P') perm = PTE_P;
f0100e00:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100e03:	0f b6 10             	movzbl (%eax),%edx
	if (argv[3][0] == 'W') perm = PTE_W;
f0100e06:	b8 02 00 00 00       	mov    $0x2,%eax
f0100e0b:	80 fa 57             	cmp    $0x57,%dl
f0100e0e:	74 10                	je     f0100e20 <setm+0x89>
	if (argv[3][0] == 'U') perm = PTE_U;
f0100e10:	b0 04                	mov    $0x4,%al
f0100e12:	80 fa 55             	cmp    $0x55,%dl
f0100e15:	74 09                	je     f0100e20 <setm+0x89>
	}
	uint32_t addr = xtoi(argv[1]);
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
	cprintf("%x before setm: ", addr);
	pprint(pte);
	uint32_t perm = 0;
f0100e17:	80 fa 50             	cmp    $0x50,%dl
f0100e1a:	0f 94 c0             	sete   %al
f0100e1d:	0f b6 c0             	movzbl %al,%eax
	if (argv[3][0] == 'P') perm = PTE_P;
	if (argv[3][0] == 'W') perm = PTE_W;
	if (argv[3][0] == 'U') perm = PTE_U;
	if (argv[2][0] == '0') 	//clear
f0100e20:	8b 53 08             	mov    0x8(%ebx),%edx
f0100e23:	80 3a 30             	cmpb   $0x30,(%edx)
f0100e26:	75 06                	jne    f0100e2e <setm+0x97>
		*pte = *pte & ~perm;
f0100e28:	f7 d0                	not    %eax
f0100e2a:	21 06                	and    %eax,(%esi)
f0100e2c:	eb 02                	jmp    f0100e30 <setm+0x99>
	else 	//set
		*pte = *pte | perm;
f0100e2e:	09 06                	or     %eax,(%esi)
	cprintf("%x after  setm: ", addr);
f0100e30:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e34:	c7 04 24 27 71 10 f0 	movl   $0xf0107127,(%esp)
f0100e3b:	e8 de 35 00 00       	call   f010441e <cprintf>
	pprint(pte);
f0100e40:	89 34 24             	mov    %esi,(%esp)
f0100e43:	e8 1d ff ff ff       	call   f0100d65 <pprint>
	return 0;
}
f0100e48:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e4d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100e50:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100e53:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100e56:	89 ec                	mov    %ebp,%esp
f0100e58:	5d                   	pop    %ebp
f0100e59:	c3                   	ret    

f0100e5a <showmappings>:
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
}
int
showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100e5a:	55                   	push   %ebp
f0100e5b:	89 e5                	mov    %esp,%ebp
f0100e5d:	57                   	push   %edi
f0100e5e:	56                   	push   %esi
f0100e5f:	53                   	push   %ebx
f0100e60:	83 ec 1c             	sub    $0x1c,%esp
f0100e63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc == 1) {
f0100e66:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100e6a:	75 11                	jne    f0100e7d <showmappings+0x23>
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
f0100e6c:	c7 04 24 68 73 10 f0 	movl   $0xf0107368,(%esp)
f0100e73:	e8 a6 35 00 00       	call   f010441e <cprintf>
		return 0;
f0100e78:	e9 a6 00 00 00       	jmp    f0100f23 <showmappings+0xc9>
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
f0100e7d:	8b 43 04             	mov    0x4(%ebx),%eax
f0100e80:	89 04 24             	mov    %eax,(%esp)
f0100e83:	e8 30 fe ff ff       	call   f0100cb8 <xtoi>
f0100e88:	89 c6                	mov    %eax,%esi
f0100e8a:	8b 43 08             	mov    0x8(%ebx),%eax
f0100e8d:	89 04 24             	mov    %eax,(%esp)
f0100e90:	e8 23 fe ff ff       	call   f0100cb8 <xtoi>
f0100e95:	89 c7                	mov    %eax,%edi
	cprintf("begin: %x, end: %x\n", begin, end);
f0100e97:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e9b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e9f:	c7 04 24 38 71 10 f0 	movl   $0xf0107138,(%esp)
f0100ea6:	e8 73 35 00 00       	call   f010441e <cprintf>
	for (; begin <= end; begin += PGSIZE) {
f0100eab:	39 fe                	cmp    %edi,%esi
f0100ead:	77 74                	ja     f0100f23 <showmappings+0xc9>
		pte_t *pte = pgdir_walk(kern_pgdir, (void *) begin, 1);	//create
f0100eaf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100eb6:	00 
f0100eb7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ebb:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0100ec0:	89 04 24             	mov    %eax,(%esp)
f0100ec3:	e8 fe 06 00 00       	call   f01015c6 <pgdir_walk>
f0100ec8:	89 c3                	mov    %eax,%ebx
		if (!pte) panic("boot_map_region panic, out of memory");
f0100eca:	85 c0                	test   %eax,%eax
f0100ecc:	75 1c                	jne    f0100eea <showmappings+0x90>
f0100ece:	c7 44 24 08 98 73 10 	movl   $0xf0107398,0x8(%esp)
f0100ed5:	f0 
f0100ed6:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
f0100edd:	00 
f0100ede:	c7 04 24 4c 71 10 f0 	movl   $0xf010714c,(%esp)
f0100ee5:	e8 b3 f1 ff ff       	call   f010009d <_panic>
		if (*pte & PTE_P) {
f0100eea:	f6 00 01             	testb  $0x1,(%eax)
f0100eed:	74 1a                	je     f0100f09 <showmappings+0xaf>
			cprintf("page %x with ", begin);
f0100eef:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ef3:	c7 04 24 5b 71 10 f0 	movl   $0xf010715b,(%esp)
f0100efa:	e8 1f 35 00 00       	call   f010441e <cprintf>
			pprint(pte);
f0100eff:	89 1c 24             	mov    %ebx,(%esp)
f0100f02:	e8 5e fe ff ff       	call   f0100d65 <pprint>
f0100f07:	eb 10                	jmp    f0100f19 <showmappings+0xbf>
		} else cprintf("page not exist: %x\n", begin);
f0100f09:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f0d:	c7 04 24 69 71 10 f0 	movl   $0xf0107169,(%esp)
f0100f14:	e8 05 35 00 00       	call   f010441e <cprintf>
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
		return 0;
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
	cprintf("begin: %x, end: %x\n", begin, end);
	for (; begin <= end; begin += PGSIZE) {
f0100f19:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100f1f:	39 f7                	cmp    %esi,%edi
f0100f21:	73 8c                	jae    f0100eaf <showmappings+0x55>
			cprintf("page %x with ", begin);
			pprint(pte);
		} else cprintf("page not exist: %x\n", begin);
	}
	return 0;
}
f0100f23:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f28:	83 c4 1c             	add    $0x1c,%esp
f0100f2b:	5b                   	pop    %ebx
f0100f2c:	5e                   	pop    %esi
f0100f2d:	5f                   	pop    %edi
f0100f2e:	5d                   	pop    %ebp
f0100f2f:	c3                   	ret    

f0100f30 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100f30:	55                   	push   %ebp
f0100f31:	89 e5                	mov    %esp,%ebp
f0100f33:	53                   	push   %ebx
f0100f34:	83 ec 14             	sub    $0x14,%esp
f0100f37:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100f39:	83 3d 38 52 22 f0 00 	cmpl   $0x0,0xf0225238
f0100f40:	75 0f                	jne    f0100f51 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100f42:	b8 07 80 26 f0       	mov    $0xf0268007,%eax
f0100f47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f4c:	a3 38 52 22 f0       	mov    %eax,0xf0225238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
f0100f51:	a1 38 52 22 f0       	mov    0xf0225238,%eax
f0100f56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f5a:	c7 04 24 6c 74 10 f0 	movl   $0xf010746c,(%esp)
f0100f61:	e8 b8 34 00 00       	call   f010441e <cprintf>
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
f0100f66:	89 d8                	mov    %ebx,%eax
f0100f68:	03 05 38 52 22 f0    	add    0xf0225238,%eax
f0100f6e:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100f73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f7c:	c7 04 24 85 74 10 f0 	movl   $0xf0107485,(%esp)
f0100f83:	e8 96 34 00 00       	call   f010441e <cprintf>
	if (n != 0) {
f0100f88:	85 db                	test   %ebx,%ebx
f0100f8a:	74 1a                	je     f0100fa6 <boot_alloc+0x76>
		char *next = nextfree;
f0100f8c:	a1 38 52 22 f0       	mov    0xf0225238,%eax
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
f0100f91:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100f98:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f9e:	89 15 38 52 22 f0    	mov    %edx,0xf0225238
		return next;
f0100fa4:	eb 05                	jmp    f0100fab <boot_alloc+0x7b>
	} else return nextfree;
f0100fa6:	a1 38 52 22 f0       	mov    0xf0225238,%eax

	return NULL;
}
f0100fab:	83 c4 14             	add    $0x14,%esp
f0100fae:	5b                   	pop    %ebx
f0100faf:	5d                   	pop    %ebp
f0100fb0:	c3                   	ret    

f0100fb1 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100fb1:	55                   	push   %ebp
f0100fb2:	89 e5                	mov    %esp,%ebp
f0100fb4:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100fb7:	89 d1                	mov    %edx,%ecx
f0100fb9:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100fbc:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100fbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100fc4:	f6 c1 01             	test   $0x1,%cl
f0100fc7:	74 57                	je     f0101020 <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100fc9:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fcf:	89 c8                	mov    %ecx,%eax
f0100fd1:	c1 e8 0c             	shr    $0xc,%eax
f0100fd4:	3b 05 90 5e 22 f0    	cmp    0xf0225e90,%eax
f0100fda:	72 20                	jb     f0100ffc <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fdc:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100fe0:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0100fe7:	f0 
f0100fe8:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0100fef:	00 
f0100ff0:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0100ff7:	e8 a1 f0 ff ff       	call   f010009d <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100ffc:	c1 ea 0c             	shr    $0xc,%edx
f0100fff:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101005:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f010100c:	89 c2                	mov    %eax,%edx
f010100e:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101011:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101016:	85 d2                	test   %edx,%edx
f0101018:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010101d:	0f 44 c2             	cmove  %edx,%eax
}
f0101020:	c9                   	leave  
f0101021:	c3                   	ret    

f0101022 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0101022:	55                   	push   %ebp
f0101023:	89 e5                	mov    %esp,%ebp
f0101025:	83 ec 18             	sub    $0x18,%esp
f0101028:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010102b:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010102e:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101030:	89 04 24             	mov    %eax,(%esp)
f0101033:	e8 7c 32 00 00       	call   f01042b4 <mc146818_read>
f0101038:	89 c6                	mov    %eax,%esi
f010103a:	83 c3 01             	add    $0x1,%ebx
f010103d:	89 1c 24             	mov    %ebx,(%esp)
f0101040:	e8 6f 32 00 00       	call   f01042b4 <mc146818_read>
f0101045:	c1 e0 08             	shl    $0x8,%eax
f0101048:	09 f0                	or     %esi,%eax
}
f010104a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010104d:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101050:	89 ec                	mov    %ebp,%esp
f0101052:	5d                   	pop    %ebp
f0101053:	c3                   	ret    

f0101054 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101054:	55                   	push   %ebp
f0101055:	89 e5                	mov    %esp,%ebp
f0101057:	57                   	push   %edi
f0101058:	56                   	push   %esi
f0101059:	53                   	push   %ebx
f010105a:	83 ec 5c             	sub    $0x5c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010105d:	3c 01                	cmp    $0x1,%al
f010105f:	19 f6                	sbb    %esi,%esi
f0101061:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101067:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f010106a:	8b 1d 30 52 22 f0    	mov    0xf0225230,%ebx
f0101070:	85 db                	test   %ebx,%ebx
f0101072:	75 1c                	jne    f0101090 <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0101074:	c7 44 24 08 c8 78 10 	movl   $0xf01078c8,0x8(%esp)
f010107b:	f0 
f010107c:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
f0101083:	00 
f0101084:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010108b:	e8 0d f0 ff ff       	call   f010009d <_panic>

	if (only_low_memory) {
f0101090:	84 c0                	test   %al,%al
f0101092:	74 50                	je     f01010e4 <check_page_free_list+0x90>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101094:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101097:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010109a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010109d:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010a0:	89 d8                	mov    %ebx,%eax
f01010a2:	2b 05 98 5e 22 f0    	sub    0xf0225e98,%eax
f01010a8:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01010ab:	c1 e8 16             	shr    $0x16,%eax
f01010ae:	39 c6                	cmp    %eax,%esi
f01010b0:	0f 96 c0             	setbe  %al
f01010b3:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f01010b6:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f01010ba:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f01010bc:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010c0:	8b 1b                	mov    (%ebx),%ebx
f01010c2:	85 db                	test   %ebx,%ebx
f01010c4:	75 da                	jne    f01010a0 <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01010c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01010c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01010cf:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01010d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010d5:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01010d7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01010da:	89 1d 30 52 22 f0    	mov    %ebx,0xf0225230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010e0:	85 db                	test   %ebx,%ebx
f01010e2:	74 67                	je     f010114b <check_page_free_list+0xf7>
f01010e4:	89 d8                	mov    %ebx,%eax
f01010e6:	2b 05 98 5e 22 f0    	sub    0xf0225e98,%eax
f01010ec:	c1 f8 03             	sar    $0x3,%eax
f01010ef:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01010f2:	89 c2                	mov    %eax,%edx
f01010f4:	c1 ea 16             	shr    $0x16,%edx
f01010f7:	39 d6                	cmp    %edx,%esi
f01010f9:	76 4a                	jbe    f0101145 <check_page_free_list+0xf1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010fb:	89 c2                	mov    %eax,%edx
f01010fd:	c1 ea 0c             	shr    $0xc,%edx
f0101100:	3b 15 90 5e 22 f0    	cmp    0xf0225e90,%edx
f0101106:	72 20                	jb     f0101128 <check_page_free_list+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101108:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010110c:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0101113:	f0 
f0101114:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010111b:	00 
f010111c:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f0101123:	e8 75 ef ff ff       	call   f010009d <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101128:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010112f:	00 
f0101130:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101137:	00 
	return (void *)(pa + KERNBASE);
f0101138:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010113d:	89 04 24             	mov    %eax,(%esp)
f0101140:	e8 6c 4d 00 00       	call   f0105eb1 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101145:	8b 1b                	mov    (%ebx),%ebx
f0101147:	85 db                	test   %ebx,%ebx
f0101149:	75 99                	jne    f01010e4 <check_page_free_list+0x90>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f010114b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101150:	e8 db fd ff ff       	call   f0100f30 <boot_alloc>
f0101155:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101158:	8b 15 30 52 22 f0    	mov    0xf0225230,%edx
f010115e:	85 d2                	test   %edx,%edx
f0101160:	0f 84 2f 02 00 00    	je     f0101395 <check_page_free_list+0x341>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101166:	8b 1d 98 5e 22 f0    	mov    0xf0225e98,%ebx
f010116c:	39 da                	cmp    %ebx,%edx
f010116e:	72 51                	jb     f01011c1 <check_page_free_list+0x16d>
		assert(pp < pages + npages);
f0101170:	a1 90 5e 22 f0       	mov    0xf0225e90,%eax
f0101175:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101178:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f010117b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010117e:	39 c2                	cmp    %eax,%edx
f0101180:	73 68                	jae    f01011ea <check_page_free_list+0x196>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101182:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101185:	89 d0                	mov    %edx,%eax
f0101187:	29 d8                	sub    %ebx,%eax
f0101189:	a8 07                	test   $0x7,%al
f010118b:	0f 85 86 00 00 00    	jne    f0101217 <check_page_free_list+0x1c3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101191:	c1 f8 03             	sar    $0x3,%eax
f0101194:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101197:	85 c0                	test   %eax,%eax
f0101199:	0f 84 a6 00 00 00    	je     f0101245 <check_page_free_list+0x1f1>
		assert(page2pa(pp) != IOPHYSMEM);
f010119f:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01011a4:	0f 84 c6 00 00 00    	je     f0101270 <check_page_free_list+0x21c>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01011aa:	be 00 00 00 00       	mov    $0x0,%esi
f01011af:	bf 00 00 00 00       	mov    $0x0,%edi
f01011b4:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f01011b7:	e9 d8 00 00 00       	jmp    f0101294 <check_page_free_list+0x240>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01011bc:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
f01011bf:	73 24                	jae    f01011e5 <check_page_free_list+0x191>
f01011c1:	c7 44 24 0c b2 74 10 	movl   $0xf01074b2,0xc(%esp)
f01011c8:	f0 
f01011c9:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01011d0:	f0 
f01011d1:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f01011d8:	00 
f01011d9:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01011e0:	e8 b8 ee ff ff       	call   f010009d <_panic>
		assert(pp < pages + npages);
f01011e5:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01011e8:	72 24                	jb     f010120e <check_page_free_list+0x1ba>
f01011ea:	c7 44 24 0c d3 74 10 	movl   $0xf01074d3,0xc(%esp)
f01011f1:	f0 
f01011f2:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01011f9:	f0 
f01011fa:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
f0101201:	00 
f0101202:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101209:	e8 8f ee ff ff       	call   f010009d <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010120e:	89 d0                	mov    %edx,%eax
f0101210:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0101213:	a8 07                	test   $0x7,%al
f0101215:	74 24                	je     f010123b <check_page_free_list+0x1e7>
f0101217:	c7 44 24 0c ec 78 10 	movl   $0xf01078ec,0xc(%esp)
f010121e:	f0 
f010121f:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101226:	f0 
f0101227:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f010122e:	00 
f010122f:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101236:	e8 62 ee ff ff       	call   f010009d <_panic>
f010123b:	c1 f8 03             	sar    $0x3,%eax
f010123e:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101241:	85 c0                	test   %eax,%eax
f0101243:	75 24                	jne    f0101269 <check_page_free_list+0x215>
f0101245:	c7 44 24 0c e7 74 10 	movl   $0xf01074e7,0xc(%esp)
f010124c:	f0 
f010124d:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101254:	f0 
f0101255:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f010125c:	00 
f010125d:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101264:	e8 34 ee ff ff       	call   f010009d <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101269:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010126e:	75 24                	jne    f0101294 <check_page_free_list+0x240>
f0101270:	c7 44 24 0c f8 74 10 	movl   $0xf01074f8,0xc(%esp)
f0101277:	f0 
f0101278:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010127f:	f0 
f0101280:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0101287:	00 
f0101288:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010128f:	e8 09 ee ff ff       	call   f010009d <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101294:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101299:	75 24                	jne    f01012bf <check_page_free_list+0x26b>
f010129b:	c7 44 24 0c 20 79 10 	movl   $0xf0107920,0xc(%esp)
f01012a2:	f0 
f01012a3:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01012aa:	f0 
f01012ab:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f01012b2:	00 
f01012b3:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01012ba:	e8 de ed ff ff       	call   f010009d <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01012bf:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01012c4:	75 24                	jne    f01012ea <check_page_free_list+0x296>
f01012c6:	c7 44 24 0c 11 75 10 	movl   $0xf0107511,0xc(%esp)
f01012cd:	f0 
f01012ce:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01012d5:	f0 
f01012d6:	c7 44 24 04 e0 02 00 	movl   $0x2e0,0x4(%esp)
f01012dd:	00 
f01012de:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01012e5:	e8 b3 ed ff ff       	call   f010009d <_panic>
f01012ea:	89 c1                	mov    %eax,%ecx
		// cprintf("pp: %x, page2pa(pp): %x, page2kva(pp): %x, first_free_page: %x\n",
		// 	pp, page2pa(pp), page2kva(pp), first_free_page);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01012ec:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01012f1:	76 59                	jbe    f010134c <check_page_free_list+0x2f8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012f3:	89 c3                	mov    %eax,%ebx
f01012f5:	c1 eb 0c             	shr    $0xc,%ebx
f01012f8:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f01012fb:	77 20                	ja     f010131d <check_page_free_list+0x2c9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101301:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0101308:	f0 
f0101309:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101310:	00 
f0101311:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f0101318:	e8 80 ed ff ff       	call   f010009d <_panic>
	return (void *)(pa + KERNBASE);
f010131d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0101323:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0101326:	76 24                	jbe    f010134c <check_page_free_list+0x2f8>
f0101328:	c7 44 24 0c 44 79 10 	movl   $0xf0107944,0xc(%esp)
f010132f:	f0 
f0101330:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101337:	f0 
f0101338:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f010133f:	00 
f0101340:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101347:	e8 51 ed ff ff       	call   f010009d <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010134c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101351:	75 24                	jne    f0101377 <check_page_free_list+0x323>
f0101353:	c7 44 24 0c 2b 75 10 	movl   $0xf010752b,0xc(%esp)
f010135a:	f0 
f010135b:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101362:	f0 
f0101363:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f010136a:	00 
f010136b:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101372:	e8 26 ed ff ff       	call   f010009d <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0101377:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f010137d:	77 05                	ja     f0101384 <check_page_free_list+0x330>
			++nfree_basemem;
f010137f:	83 c7 01             	add    $0x1,%edi
f0101382:	eb 03                	jmp    f0101387 <check_page_free_list+0x333>
		else
			++nfree_extmem;
f0101384:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101387:	8b 12                	mov    (%edx),%edx
f0101389:	85 d2                	test   %edx,%edx
f010138b:	0f 85 2b fe ff ff    	jne    f01011bc <check_page_free_list+0x168>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101391:	85 ff                	test   %edi,%edi
f0101393:	7f 24                	jg     f01013b9 <check_page_free_list+0x365>
f0101395:	c7 44 24 0c 48 75 10 	movl   $0xf0107548,0xc(%esp)
f010139c:	f0 
f010139d:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01013a4:	f0 
f01013a5:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f01013ac:	00 
f01013ad:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01013b4:	e8 e4 ec ff ff       	call   f010009d <_panic>
	assert(nfree_extmem > 0);
f01013b9:	85 f6                	test   %esi,%esi
f01013bb:	7f 24                	jg     f01013e1 <check_page_free_list+0x38d>
f01013bd:	c7 44 24 0c 5a 75 10 	movl   $0xf010755a,0xc(%esp)
f01013c4:	f0 
f01013c5:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01013cc:	f0 
f01013cd:	c7 44 24 04 ee 02 00 	movl   $0x2ee,0x4(%esp)
f01013d4:	00 
f01013d5:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01013dc:	e8 bc ec ff ff       	call   f010009d <_panic>
	cprintf("check_page_free_list done\n");
f01013e1:	c7 04 24 6b 75 10 f0 	movl   $0xf010756b,(%esp)
f01013e8:	e8 31 30 00 00       	call   f010441e <cprintf>
}
f01013ed:	83 c4 5c             	add    $0x5c,%esp
f01013f0:	5b                   	pop    %ebx
f01013f1:	5e                   	pop    %esi
f01013f2:	5f                   	pop    %edi
f01013f3:	5d                   	pop    %ebp
f01013f4:	c3                   	ret    

f01013f5 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01013f5:	55                   	push   %ebp
f01013f6:	89 e5                	mov    %esp,%ebp
f01013f8:	53                   	push   %ebx
f01013f9:	83 ec 14             	sub    $0x14,%esp
	//     page tables and other data structures?
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	cprintf("MPENTRY_PADDR: %x\n", MPENTRY_PADDR);
f01013fc:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0101403:	00 
f0101404:	c7 04 24 86 75 10 f0 	movl   $0xf0107586,(%esp)
f010140b:	e8 0e 30 00 00       	call   f010441e <cprintf>
	cprintf("npages_basemem: %x\n", npages_basemem);
f0101410:	a1 34 52 22 f0       	mov    0xf0225234,%eax
f0101415:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101419:	c7 04 24 99 75 10 f0 	movl   $0xf0107599,(%esp)
f0101420:	e8 f9 2f 00 00       	call   f010441e <cprintf>
f0101425:	8b 0d 30 52 22 f0    	mov    0xf0225230,%ecx
f010142b:	b8 08 00 00 00       	mov    $0x8,%eax
	size_t i;
	for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0101430:	89 c2                	mov    %eax,%edx
f0101432:	03 15 98 5e 22 f0    	add    0xf0225e98,%edx
f0101438:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f010143e:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0101440:	89 c1                	mov    %eax,%ecx
f0101442:	03 0d 98 5e 22 f0    	add    0xf0225e98,%ecx
f0101448:	83 c0 08             	add    $0x8,%eax
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	cprintf("MPENTRY_PADDR: %x\n", MPENTRY_PADDR);
	cprintf("npages_basemem: %x\n", npages_basemem);
	size_t i;
	for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
f010144b:	83 f8 38             	cmp    $0x38,%eax
f010144e:	75 e0                	jne    f0101430 <page_init+0x3b>
f0101450:	89 0d 30 52 22 f0    	mov    %ecx,0xf0225230
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	// int med = (int)ROUNDUP(kern_top - 0xf0000000, PGSIZE)/PGSIZE;
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
f0101456:	a1 3c 52 22 f0       	mov    0xf022523c,%eax
f010145b:	05 ff ff 01 10       	add    $0x1001ffff,%eax
f0101460:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101465:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010146b:	85 c0                	test   %eax,%eax
f010146d:	0f 49 d8             	cmovns %eax,%ebx
f0101470:	c1 fb 0c             	sar    $0xc,%ebx
	// med = (int) percpu_kstacks[NCPU-1];
	cprintf("med: %x\n", med);
f0101473:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101477:	c7 04 24 ad 75 10 f0 	movl   $0xf01075ad,(%esp)
f010147e:	e8 9b 2f 00 00       	call   f010441e <cprintf>
	for (i = med; i < npages; i++) {
f0101483:	89 d8                	mov    %ebx,%eax
f0101485:	3b 1d 90 5e 22 f0    	cmp    0xf0225e90,%ebx
f010148b:	73 35                	jae    f01014c2 <page_init+0xcd>
f010148d:	8b 0d 30 52 22 f0    	mov    0xf0225230,%ecx
f0101493:	c1 e3 03             	shl    $0x3,%ebx
		pages[i].pp_ref = 0;
f0101496:	89 da                	mov    %ebx,%edx
f0101498:	03 15 98 5e 22 f0    	add    0xf0225e98,%edx
f010149e:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f01014a4:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f01014a6:	89 d9                	mov    %ebx,%ecx
f01014a8:	03 0d 98 5e 22 f0    	add    0xf0225e98,%ecx
	}
	// int med = (int)ROUNDUP(kern_top - 0xf0000000, PGSIZE)/PGSIZE;
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
	// med = (int) percpu_kstacks[NCPU-1];
	cprintf("med: %x\n", med);
	for (i = med; i < npages; i++) {
f01014ae:	83 c0 01             	add    $0x1,%eax
f01014b1:	83 c3 08             	add    $0x8,%ebx
f01014b4:	39 05 90 5e 22 f0    	cmp    %eax,0xf0225e90
f01014ba:	77 da                	ja     f0101496 <page_init+0xa1>
f01014bc:	89 0d 30 52 22 f0    	mov    %ecx,0xf0225230
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f01014c2:	83 c4 14             	add    $0x14,%esp
f01014c5:	5b                   	pop    %ebx
f01014c6:	5d                   	pop    %ebp
f01014c7:	c3                   	ret    

f01014c8 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01014c8:	55                   	push   %ebp
f01014c9:	89 e5                	mov    %esp,%ebp
f01014cb:	53                   	push   %ebx
f01014cc:	83 ec 14             	sub    $0x14,%esp
	if (page_free_list) {
f01014cf:	8b 1d 30 52 22 f0    	mov    0xf0225230,%ebx
f01014d5:	85 db                	test   %ebx,%ebx
f01014d7:	0f 84 83 00 00 00    	je     f0101560 <page_alloc+0x98>
		struct PageInfo *ret = page_free_list;
		page_free_list = page_free_list->pp_link;
f01014dd:	8b 03                	mov    (%ebx),%eax
f01014df:	a3 30 52 22 f0       	mov    %eax,0xf0225230
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014e4:	89 d8                	mov    %ebx,%eax
f01014e6:	2b 05 98 5e 22 f0    	sub    0xf0225e98,%eax
f01014ec:	c1 f8 03             	sar    $0x3,%eax
f01014ef:	c1 e0 0c             	shl    $0xc,%eax
		cprintf("alocccccccccccccc pa: %x\n", page2pa(ret));
f01014f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014f6:	c7 04 24 b6 75 10 f0 	movl   $0xf01075b6,(%esp)
f01014fd:	e8 1c 2f 00 00       	call   f010441e <cprintf>
		if (alloc_flags & ALLOC_ZERO) 
f0101502:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101506:	74 58                	je     f0101560 <page_alloc+0x98>
f0101508:	89 d8                	mov    %ebx,%eax
f010150a:	2b 05 98 5e 22 f0    	sub    0xf0225e98,%eax
f0101510:	c1 f8 03             	sar    $0x3,%eax
f0101513:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101516:	89 c2                	mov    %eax,%edx
f0101518:	c1 ea 0c             	shr    $0xc,%edx
f010151b:	3b 15 90 5e 22 f0    	cmp    0xf0225e90,%edx
f0101521:	72 20                	jb     f0101543 <page_alloc+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101523:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101527:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f010152e:	f0 
f010152f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101536:	00 
f0101537:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f010153e:	e8 5a eb ff ff       	call   f010009d <_panic>
			memset(page2kva(ret), 0, PGSIZE);
f0101543:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010154a:	00 
f010154b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101552:	00 
	return (void *)(pa + KERNBASE);
f0101553:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101558:	89 04 24             	mov    %eax,(%esp)
f010155b:	e8 51 49 00 00       	call   f0105eb1 <memset>
		return ret;
	}
	return NULL;
}
f0101560:	89 d8                	mov    %ebx,%eax
f0101562:	83 c4 14             	add    $0x14,%esp
f0101565:	5b                   	pop    %ebx
f0101566:	5d                   	pop    %ebp
f0101567:	c3                   	ret    

f0101568 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101568:	55                   	push   %ebp
f0101569:	89 e5                	mov    %esp,%ebp
f010156b:	53                   	push   %ebx
f010156c:	83 ec 14             	sub    $0x14,%esp
f010156f:	8b 5d 08             	mov    0x8(%ebp),%ebx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101572:	89 d8                	mov    %ebx,%eax
f0101574:	2b 05 98 5e 22 f0    	sub    0xf0225e98,%eax
f010157a:	c1 f8 03             	sar    $0x3,%eax
f010157d:	c1 e0 0c             	shl    $0xc,%eax
	cprintf("freeeeeeeeeee pa: %x\n", page2pa(pp));
f0101580:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101584:	c7 04 24 d0 75 10 f0 	movl   $0xf01075d0,(%esp)
f010158b:	e8 8e 2e 00 00       	call   f010441e <cprintf>
	pp->pp_link = page_free_list;
f0101590:	a1 30 52 22 f0       	mov    0xf0225230,%eax
f0101595:	89 03                	mov    %eax,(%ebx)
	page_free_list = pp;
f0101597:	89 1d 30 52 22 f0    	mov    %ebx,0xf0225230
}
f010159d:	83 c4 14             	add    $0x14,%esp
f01015a0:	5b                   	pop    %ebx
f01015a1:	5d                   	pop    %ebp
f01015a2:	c3                   	ret    

f01015a3 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01015a3:	55                   	push   %ebp
f01015a4:	89 e5                	mov    %esp,%ebp
f01015a6:	83 ec 18             	sub    $0x18,%esp
f01015a9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01015ac:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f01015b0:	83 ea 01             	sub    $0x1,%edx
f01015b3:	66 89 50 04          	mov    %dx,0x4(%eax)
f01015b7:	66 85 d2             	test   %dx,%dx
f01015ba:	75 08                	jne    f01015c4 <page_decref+0x21>
		page_free(pp);
f01015bc:	89 04 24             	mov    %eax,(%esp)
f01015bf:	e8 a4 ff ff ff       	call   f0101568 <page_free>
}
f01015c4:	c9                   	leave  
f01015c5:	c3                   	ret    

f01015c6 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01015c6:	55                   	push   %ebp
f01015c7:	89 e5                	mov    %esp,%ebp
f01015c9:	83 ec 18             	sub    $0x18,%esp
f01015cc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01015cf:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01015d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int dindex = PDX(va), tindex = PTX(va);
f01015d5:	89 f3                	mov    %esi,%ebx
f01015d7:	c1 eb 16             	shr    $0x16,%ebx
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
f01015da:	c1 e3 02             	shl    $0x2,%ebx
f01015dd:	03 5d 08             	add    0x8(%ebp),%ebx
f01015e0:	f6 03 01             	testb  $0x1,(%ebx)
f01015e3:	75 31                	jne    f0101616 <pgdir_walk+0x50>
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
			pg->pp_ref++;
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
		} else return NULL;
f01015e5:	b8 00 00 00 00       	mov    $0x0,%eax
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
f01015ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01015ee:	74 71                	je     f0101661 <pgdir_walk+0x9b>
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
f01015f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015f7:	e8 cc fe ff ff       	call   f01014c8 <page_alloc>
			if (!pg) return NULL;	//allocation fails
f01015fc:	85 c0                	test   %eax,%eax
f01015fe:	74 5c                	je     f010165c <pgdir_walk+0x96>
			pg->pp_ref++;
f0101600:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0101605:	2b 05 98 5e 22 f0    	sub    0xf0225e98,%eax
f010160b:	c1 f8 03             	sar    $0x3,%eax
f010160e:	c1 e0 0c             	shl    $0xc,%eax
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
f0101611:	83 c8 07             	or     $0x7,%eax
f0101614:	89 03                	mov    %eax,(%ebx)
		} else return NULL;
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));
f0101616:	8b 03                	mov    (%ebx),%eax
f0101618:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010161d:	89 c2                	mov    %eax,%edx
f010161f:	c1 ea 0c             	shr    $0xc,%edx
f0101622:	3b 15 90 5e 22 f0    	cmp    0xf0225e90,%edx
f0101628:	72 20                	jb     f010164a <pgdir_walk+0x84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010162a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010162e:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0101635:	f0 
f0101636:	c7 44 24 04 be 01 00 	movl   $0x1be,0x4(%esp)
f010163d:	00 
f010163e:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101645:	e8 53 ea ff ff       	call   f010009d <_panic>
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	int dindex = PDX(va), tindex = PTX(va);
f010164a:	c1 ee 0a             	shr    $0xa,%esi
	// 		struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
f010164d:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101653:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f010165a:	eb 05                	jmp    f0101661 <pgdir_walk+0x9b>
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
f010165c:	b8 00 00 00 00       	mov    $0x0,%eax
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
}
f0101661:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101664:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101667:	89 ec                	mov    %ebp,%esp
f0101669:	5d                   	pop    %ebp
f010166a:	c3                   	ret    

f010166b <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010166b:	55                   	push   %ebp
f010166c:	89 e5                	mov    %esp,%ebp
f010166e:	57                   	push   %edi
f010166f:	56                   	push   %esi
f0101670:	53                   	push   %ebx
f0101671:	83 ec 2c             	sub    $0x2c,%esp
f0101674:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101677:	89 d3                	mov    %edx,%ebx
f0101679:	89 ce                	mov    %ecx,%esi
f010167b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	cprintf("thiscpu: %x\n", thiscpu);
f010167e:	e8 c1 4e 00 00       	call   f0106544 <cpunum>
f0101683:	6b c0 74             	imul   $0x74,%eax,%eax
f0101686:	05 20 60 22 f0       	add    $0xf0226020,%eax
f010168b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010168f:	c7 04 24 e6 75 10 f0 	movl   $0xf01075e6,(%esp)
f0101696:	e8 83 2d 00 00       	call   f010441e <cprintf>
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
f010169b:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010169f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016a3:	c7 04 24 8c 79 10 f0 	movl   $0xf010798c,(%esp)
f01016aa:	e8 6f 2d 00 00       	call   f010441e <cprintf>
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01016af:	c1 ee 0c             	shr    $0xc,%esi
f01016b2:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f01016b5:	85 f6                	test   %esi,%esi
f01016b7:	74 62                	je     f010171b <boot_map_region+0xb0>
f01016b9:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
f01016be:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016c1:	83 c8 01             	or     $0x1,%eax
f01016c4:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	int i;
	cprintf("thiscpu: %x\n", thiscpu);
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f01016c7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01016ce:	00 
f01016cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01016d6:	89 04 24             	mov    %eax,(%esp)
f01016d9:	e8 e8 fe ff ff       	call   f01015c6 <pgdir_walk>
		if (!pte) panic("boot_map_region panic, out of memory");
f01016de:	85 c0                	test   %eax,%eax
f01016e0:	75 1c                	jne    f01016fe <boot_map_region+0x93>
f01016e2:	c7 44 24 08 98 73 10 	movl   $0xf0107398,0x8(%esp)
f01016e9:	f0 
f01016ea:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
f01016f1:	00 
f01016f2:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01016f9:	e8 9f e9 ff ff       	call   f010009d <_panic>
		*pte = pa | perm | PTE_P;
f01016fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101701:	09 fa                	or     %edi,%edx
f0101703:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("thiscpu: %x\n", thiscpu);
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101705:	83 c6 01             	add    $0x1,%esi
f0101708:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010170b:	73 0e                	jae    f010171b <boot_map_region+0xb0>
f010170d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101713:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0101719:	eb ac                	jmp    f01016c7 <boot_map_region+0x5c>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
	}
}
f010171b:	83 c4 2c             	add    $0x2c,%esp
f010171e:	5b                   	pop    %ebx
f010171f:	5e                   	pop    %esi
f0101720:	5f                   	pop    %edi
f0101721:	5d                   	pop    %ebp
f0101722:	c3                   	ret    

f0101723 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101723:	55                   	push   %ebp
f0101724:	89 e5                	mov    %esp,%ebp
f0101726:	53                   	push   %ebx
f0101727:	83 ec 14             	sub    $0x14,%esp
f010172a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
f010172d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101734:	00 
f0101735:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101738:	89 44 24 04          	mov    %eax,0x4(%esp)
f010173c:	8b 45 08             	mov    0x8(%ebp),%eax
f010173f:	89 04 24             	mov    %eax,(%esp)
f0101742:	e8 7f fe ff ff       	call   f01015c6 <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f0101747:	ba 00 00 00 00       	mov    $0x0,%edx
f010174c:	85 c0                	test   %eax,%eax
f010174e:	74 44                	je     f0101794 <page_lookup+0x71>
f0101750:	f6 00 01             	testb  $0x1,(%eax)
f0101753:	74 3a                	je     f010178f <page_lookup+0x6c>
	if (pte_store)
f0101755:	85 db                	test   %ebx,%ebx
f0101757:	74 02                	je     f010175b <page_lookup+0x38>
		*pte_store = pte;	//found and set
f0101759:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*pte));		
f010175b:	8b 10                	mov    (%eax),%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010175d:	c1 ea 0c             	shr    $0xc,%edx
f0101760:	3b 15 90 5e 22 f0    	cmp    0xf0225e90,%edx
f0101766:	72 1c                	jb     f0101784 <page_lookup+0x61>
		panic("pa2page called with invalid pa");
f0101768:	c7 44 24 08 c0 79 10 	movl   $0xf01079c0,0x8(%esp)
f010176f:	f0 
f0101770:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101777:	00 
f0101778:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f010177f:	e8 19 e9 ff ff       	call   f010009d <_panic>
	return &pages[PGNUM(pa)];
f0101784:	c1 e2 03             	shl    $0x3,%edx
f0101787:	03 15 98 5e 22 f0    	add    0xf0225e98,%edx
f010178d:	eb 05                	jmp    f0101794 <page_lookup+0x71>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f010178f:	ba 00 00 00 00       	mov    $0x0,%edx
	if (pte_store)
		*pte_store = pte;	//found and set
	return pa2page(PTE_ADDR(*pte));		
}
f0101794:	89 d0                	mov    %edx,%eax
f0101796:	83 c4 14             	add    $0x14,%esp
f0101799:	5b                   	pop    %ebx
f010179a:	5d                   	pop    %ebp
f010179b:	c3                   	ret    

f010179c <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010179c:	55                   	push   %ebp
f010179d:	89 e5                	mov    %esp,%ebp
f010179f:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01017a2:	e8 9d 4d 00 00       	call   f0106544 <cpunum>
f01017a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01017aa:	83 b8 28 60 22 f0 00 	cmpl   $0x0,-0xfdd9fd8(%eax)
f01017b1:	74 16                	je     f01017c9 <tlb_invalidate+0x2d>
f01017b3:	e8 8c 4d 00 00       	call   f0106544 <cpunum>
f01017b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01017bb:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f01017c1:	8b 55 08             	mov    0x8(%ebp),%edx
f01017c4:	39 50 60             	cmp    %edx,0x60(%eax)
f01017c7:	75 06                	jne    f01017cf <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01017c9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017cc:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01017cf:	c9                   	leave  
f01017d0:	c3                   	ret    

f01017d1 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01017d1:	55                   	push   %ebp
f01017d2:	89 e5                	mov    %esp,%ebp
f01017d4:	83 ec 28             	sub    $0x28,%esp
f01017d7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01017da:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01017dd:	8b 75 08             	mov    0x8(%ebp),%esi
f01017e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte;
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f01017e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01017e6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01017ee:	89 34 24             	mov    %esi,(%esp)
f01017f1:	e8 2d ff ff ff       	call   f0101723 <page_lookup>
	if (!pg || !(*pte & PTE_P)) return;	//page not exist
f01017f6:	85 c0                	test   %eax,%eax
f01017f8:	74 25                	je     f010181f <page_remove+0x4e>
f01017fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01017fd:	f6 02 01             	testb  $0x1,(%edx)
f0101800:	74 1d                	je     f010181f <page_remove+0x4e>
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
	page_decref(pg);
f0101802:	89 04 24             	mov    %eax,(%esp)
f0101805:	e8 99 fd ff ff       	call   f01015a3 <page_decref>
//   - The pg table entry corresponding to 'va' should be set to 0.
	*pte = 0;
f010180a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010180d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
//   - The TLB must be invalidated if you remove an entry from
//     the page table.
	tlb_invalidate(pgdir, va);
f0101813:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101817:	89 34 24             	mov    %esi,(%esp)
f010181a:	e8 7d ff ff ff       	call   f010179c <tlb_invalidate>
}
f010181f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101822:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101825:	89 ec                	mov    %ebp,%esp
f0101827:	5d                   	pop    %ebp
f0101828:	c3                   	ret    

f0101829 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101829:	55                   	push   %ebp
f010182a:	89 e5                	mov    %esp,%ebp
f010182c:	83 ec 28             	sub    $0x28,%esp
f010182f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101832:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101835:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101838:	8b 75 0c             	mov    0xc(%ebp),%esi
f010183b:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
f010183e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101845:	00 
f0101846:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010184a:	8b 45 08             	mov    0x8(%ebp),%eax
f010184d:	89 04 24             	mov    %eax,(%esp)
f0101850:	e8 71 fd ff ff       	call   f01015c6 <pgdir_walk>
f0101855:	89 c3                	mov    %eax,%ebx
	if (!pte) 	//page table not allocated
		return -E_NO_MEM;	
f0101857:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
	if (!pte) 	//page table not allocated
f010185c:	85 db                	test   %ebx,%ebx
f010185e:	74 38                	je     f0101898 <page_insert+0x6f>
		return -E_NO_MEM;	
	//increase ref count to avoid the corner case that pp is freed before it is inserted.
	pp->pp_ref++;	
f0101860:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
f0101865:	f6 03 01             	testb  $0x1,(%ebx)
f0101868:	74 0f                	je     f0101879 <page_insert+0x50>
		page_remove(pgdir, va);
f010186a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010186e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101871:	89 04 24             	mov    %eax,(%esp)
f0101874:	e8 58 ff ff ff       	call   f01017d1 <page_remove>
	*pte = page2pa(pp) | perm | PTE_P;
f0101879:	8b 55 14             	mov    0x14(%ebp),%edx
f010187c:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010187f:	2b 35 98 5e 22 f0    	sub    0xf0225e98,%esi
f0101885:	c1 fe 03             	sar    $0x3,%esi
f0101888:	89 f0                	mov    %esi,%eax
f010188a:	c1 e0 0c             	shl    $0xc,%eax
f010188d:	89 d6                	mov    %edx,%esi
f010188f:	09 c6                	or     %eax,%esi
f0101891:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101893:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101898:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010189b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010189e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01018a1:	89 ec                	mov    %ebp,%esp
f01018a3:	5d                   	pop    %ebp
f01018a4:	c3                   	ret    

f01018a5 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01018a5:	55                   	push   %ebp
f01018a6:	89 e5                	mov    %esp,%ebp
f01018a8:	53                   	push   %ebx
f01018a9:	83 ec 14             	sub    $0x14,%esp
f01018ac:	8b 45 08             	mov    0x8(%ebp),%eax
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(pa+size, PGSIZE);
f01018af:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01018b5:	03 5d 0c             	add    0xc(%ebp),%ebx
f01018b8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
f01018be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	size -= pa;
f01018c3:	29 c3                	sub    %eax,%ebx
	if (base+size >= MMIOLIM) panic("not enough memory");
f01018c5:	8b 15 00 23 12 f0    	mov    0xf0122300,%edx
f01018cb:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f01018ce:	81 f9 ff ff bf ef    	cmp    $0xefbfffff,%ecx
f01018d4:	76 1c                	jbe    f01018f2 <mmio_map_region+0x4d>
f01018d6:	c7 44 24 08 f3 75 10 	movl   $0xf01075f3,0x8(%esp)
f01018dd:	f0 
f01018de:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
f01018e5:	00 
f01018e6:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01018ed:	e8 ab e7 ff ff       	call   f010009d <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f01018f2:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f01018f9:	00 
f01018fa:	89 04 24             	mov    %eax,(%esp)
f01018fd:	89 d9                	mov    %ebx,%ecx
f01018ff:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0101904:	e8 62 fd ff ff       	call   f010166b <boot_map_region>
	base += size;
f0101909:	89 d8                	mov    %ebx,%eax
f010190b:	03 05 00 23 12 f0    	add    0xf0122300,%eax
f0101911:	a3 00 23 12 f0       	mov    %eax,0xf0122300
	return (void*) (base - size);
f0101916:	29 d8                	sub    %ebx,%eax
	// panic("mmio_map_region not implemented");
}
f0101918:	83 c4 14             	add    $0x14,%esp
f010191b:	5b                   	pop    %ebx
f010191c:	5d                   	pop    %ebp
f010191d:	c3                   	ret    

f010191e <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010191e:	55                   	push   %ebp
f010191f:	89 e5                	mov    %esp,%ebp
f0101921:	57                   	push   %edi
f0101922:	56                   	push   %esi
f0101923:	53                   	push   %ebx
f0101924:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101927:	b8 15 00 00 00       	mov    $0x15,%eax
f010192c:	e8 f1 f6 ff ff       	call   f0101022 <nvram_read>
f0101931:	c1 e0 0a             	shl    $0xa,%eax
f0101934:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010193a:	85 c0                	test   %eax,%eax
f010193c:	0f 48 c2             	cmovs  %edx,%eax
f010193f:	c1 f8 0c             	sar    $0xc,%eax
f0101942:	a3 34 52 22 f0       	mov    %eax,0xf0225234
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101947:	b8 17 00 00 00       	mov    $0x17,%eax
f010194c:	e8 d1 f6 ff ff       	call   f0101022 <nvram_read>
f0101951:	c1 e0 0a             	shl    $0xa,%eax
f0101954:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010195a:	85 c0                	test   %eax,%eax
f010195c:	0f 48 c2             	cmovs  %edx,%eax
f010195f:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101962:	85 c0                	test   %eax,%eax
f0101964:	74 0e                	je     f0101974 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101966:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010196c:	89 15 90 5e 22 f0    	mov    %edx,0xf0225e90
f0101972:	eb 0c                	jmp    f0101980 <mem_init+0x62>
	else
		npages = npages_basemem;
f0101974:	8b 15 34 52 22 f0    	mov    0xf0225234,%edx
f010197a:	89 15 90 5e 22 f0    	mov    %edx,0xf0225e90

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101980:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101983:	c1 e8 0a             	shr    $0xa,%eax
f0101986:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f010198a:	a1 34 52 22 f0       	mov    0xf0225234,%eax
f010198f:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101992:	c1 e8 0a             	shr    $0xa,%eax
f0101995:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101999:	a1 90 5e 22 f0       	mov    0xf0225e90,%eax
f010199e:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01019a1:	c1 e8 0a             	shr    $0xa,%eax
f01019a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01019a8:	c7 04 24 e0 79 10 f0 	movl   $0xf01079e0,(%esp)
f01019af:	e8 6a 2a 00 00       	call   f010441e <cprintf>
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01019b4:	b8 00 10 00 00       	mov    $0x1000,%eax
f01019b9:	e8 72 f5 ff ff       	call   f0100f30 <boot_alloc>
f01019be:	a3 94 5e 22 f0       	mov    %eax,0xf0225e94
	memset(kern_pgdir, 0, PGSIZE);
f01019c3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01019ca:	00 
f01019cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01019d2:	00 
f01019d3:	89 04 24             	mov    %eax,(%esp)
f01019d6:	e8 d6 44 00 00       	call   f0105eb1 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01019db:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01019e0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01019e5:	77 20                	ja     f0101a07 <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01019e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019eb:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f01019f2:	f0 
f01019f3:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
f01019fa:	00 
f01019fb:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101a02:	e8 96 e6 ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101a07:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101a0d:	83 ca 05             	or     $0x5,%edx
f0101a10:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f0101a16:	a1 90 5e 22 f0       	mov    0xf0225e90,%eax
f0101a1b:	c1 e0 03             	shl    $0x3,%eax
f0101a1e:	e8 0d f5 ff ff       	call   f0100f30 <boot_alloc>
f0101a23:	a3 98 5e 22 f0       	mov    %eax,0xf0225e98

	cprintf("npages: %d\n", npages);
f0101a28:	a1 90 5e 22 f0       	mov    0xf0225e90,%eax
f0101a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a31:	c7 04 24 05 76 10 f0 	movl   $0xf0107605,(%esp)
f0101a38:	e8 e1 29 00 00       	call   f010441e <cprintf>
	cprintf("npages_basemem: %d\n", npages_basemem);
f0101a3d:	a1 34 52 22 f0       	mov    0xf0225234,%eax
f0101a42:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a46:	c7 04 24 11 76 10 f0 	movl   $0xf0107611,(%esp)
f0101a4d:	e8 cc 29 00 00       	call   f010441e <cprintf>
	cprintf("pages: %x\n", pages);
f0101a52:	a1 98 5e 22 f0       	mov    0xf0225e98,%eax
f0101a57:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a5b:	c7 04 24 25 76 10 f0 	movl   $0xf0107625,(%esp)
f0101a62:	e8 b7 29 00 00       	call   f010441e <cprintf>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f0101a67:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101a6c:	e8 bf f4 ff ff       	call   f0100f30 <boot_alloc>
f0101a71:	a3 3c 52 22 f0       	mov    %eax,0xf022523c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101a76:	e8 7a f9 ff ff       	call   f01013f5 <page_init>

	check_page_free_list(1);
f0101a7b:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a80:	e8 cf f5 ff ff       	call   f0101054 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101a85:	83 3d 98 5e 22 f0 00 	cmpl   $0x0,0xf0225e98
f0101a8c:	75 1c                	jne    f0101aaa <mem_init+0x18c>
		panic("'pages' is a null pointer!");
f0101a8e:	c7 44 24 08 30 76 10 	movl   $0xf0107630,0x8(%esp)
f0101a95:	f0 
f0101a96:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f0101a9d:	00 
f0101a9e:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101aa5:	e8 f3 e5 ff ff       	call   f010009d <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101aaa:	a1 30 52 22 f0       	mov    0xf0225230,%eax
f0101aaf:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101ab4:	85 c0                	test   %eax,%eax
f0101ab6:	74 09                	je     f0101ac1 <mem_init+0x1a3>
		++nfree;
f0101ab8:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101abb:	8b 00                	mov    (%eax),%eax
f0101abd:	85 c0                	test   %eax,%eax
f0101abf:	75 f7                	jne    f0101ab8 <mem_init+0x19a>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ac1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ac8:	e8 fb f9 ff ff       	call   f01014c8 <page_alloc>
f0101acd:	89 c6                	mov    %eax,%esi
f0101acf:	85 c0                	test   %eax,%eax
f0101ad1:	75 24                	jne    f0101af7 <mem_init+0x1d9>
f0101ad3:	c7 44 24 0c 4b 76 10 	movl   $0xf010764b,0xc(%esp)
f0101ada:	f0 
f0101adb:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101ae2:	f0 
f0101ae3:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f0101aea:	00 
f0101aeb:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101af2:	e8 a6 e5 ff ff       	call   f010009d <_panic>
	assert((pp1 = page_alloc(0)));
f0101af7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101afe:	e8 c5 f9 ff ff       	call   f01014c8 <page_alloc>
f0101b03:	89 c7                	mov    %eax,%edi
f0101b05:	85 c0                	test   %eax,%eax
f0101b07:	75 24                	jne    f0101b2d <mem_init+0x20f>
f0101b09:	c7 44 24 0c 61 76 10 	movl   $0xf0107661,0xc(%esp)
f0101b10:	f0 
f0101b11:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101b18:	f0 
f0101b19:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f0101b20:	00 
f0101b21:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101b28:	e8 70 e5 ff ff       	call   f010009d <_panic>
	assert((pp2 = page_alloc(0)));
f0101b2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b34:	e8 8f f9 ff ff       	call   f01014c8 <page_alloc>
f0101b39:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b3c:	85 c0                	test   %eax,%eax
f0101b3e:	75 24                	jne    f0101b64 <mem_init+0x246>
f0101b40:	c7 44 24 0c 77 76 10 	movl   $0xf0107677,0xc(%esp)
f0101b47:	f0 
f0101b48:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101b4f:	f0 
f0101b50:	c7 44 24 04 0a 03 00 	movl   $0x30a,0x4(%esp)
f0101b57:	00 
f0101b58:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101b5f:	e8 39 e5 ff ff       	call   f010009d <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b64:	39 fe                	cmp    %edi,%esi
f0101b66:	75 24                	jne    f0101b8c <mem_init+0x26e>
f0101b68:	c7 44 24 0c 8d 76 10 	movl   $0xf010768d,0xc(%esp)
f0101b6f:	f0 
f0101b70:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101b77:	f0 
f0101b78:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f0101b7f:	00 
f0101b80:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101b87:	e8 11 e5 ff ff       	call   f010009d <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b8c:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101b8f:	74 05                	je     f0101b96 <mem_init+0x278>
f0101b91:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101b94:	75 24                	jne    f0101bba <mem_init+0x29c>
f0101b96:	c7 44 24 0c 1c 7a 10 	movl   $0xf0107a1c,0xc(%esp)
f0101b9d:	f0 
f0101b9e:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101ba5:	f0 
f0101ba6:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f0101bad:	00 
f0101bae:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101bb5:	e8 e3 e4 ff ff       	call   f010009d <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101bba:	8b 15 98 5e 22 f0    	mov    0xf0225e98,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101bc0:	a1 90 5e 22 f0       	mov    0xf0225e90,%eax
f0101bc5:	c1 e0 0c             	shl    $0xc,%eax
f0101bc8:	89 f1                	mov    %esi,%ecx
f0101bca:	29 d1                	sub    %edx,%ecx
f0101bcc:	c1 f9 03             	sar    $0x3,%ecx
f0101bcf:	c1 e1 0c             	shl    $0xc,%ecx
f0101bd2:	39 c1                	cmp    %eax,%ecx
f0101bd4:	72 24                	jb     f0101bfa <mem_init+0x2dc>
f0101bd6:	c7 44 24 0c 9f 76 10 	movl   $0xf010769f,0xc(%esp)
f0101bdd:	f0 
f0101bde:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101be5:	f0 
f0101be6:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0101bed:	00 
f0101bee:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101bf5:	e8 a3 e4 ff ff       	call   f010009d <_panic>
f0101bfa:	89 f9                	mov    %edi,%ecx
f0101bfc:	29 d1                	sub    %edx,%ecx
f0101bfe:	c1 f9 03             	sar    $0x3,%ecx
f0101c01:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101c04:	39 c8                	cmp    %ecx,%eax
f0101c06:	77 24                	ja     f0101c2c <mem_init+0x30e>
f0101c08:	c7 44 24 0c bc 76 10 	movl   $0xf01076bc,0xc(%esp)
f0101c0f:	f0 
f0101c10:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101c17:	f0 
f0101c18:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f0101c1f:	00 
f0101c20:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101c27:	e8 71 e4 ff ff       	call   f010009d <_panic>
f0101c2c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101c2f:	29 d1                	sub    %edx,%ecx
f0101c31:	89 ca                	mov    %ecx,%edx
f0101c33:	c1 fa 03             	sar    $0x3,%edx
f0101c36:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101c39:	39 d0                	cmp    %edx,%eax
f0101c3b:	77 24                	ja     f0101c61 <mem_init+0x343>
f0101c3d:	c7 44 24 0c d9 76 10 	movl   $0xf01076d9,0xc(%esp)
f0101c44:	f0 
f0101c45:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101c4c:	f0 
f0101c4d:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f0101c54:	00 
f0101c55:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101c5c:	e8 3c e4 ff ff       	call   f010009d <_panic>


	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c61:	a1 30 52 22 f0       	mov    0xf0225230,%eax
f0101c66:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101c69:	c7 05 30 52 22 f0 00 	movl   $0x0,0xf0225230
f0101c70:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c7a:	e8 49 f8 ff ff       	call   f01014c8 <page_alloc>
f0101c7f:	85 c0                	test   %eax,%eax
f0101c81:	74 24                	je     f0101ca7 <mem_init+0x389>
f0101c83:	c7 44 24 0c f6 76 10 	movl   $0xf01076f6,0xc(%esp)
f0101c8a:	f0 
f0101c8b:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101c92:	f0 
f0101c93:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f0101c9a:	00 
f0101c9b:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101ca2:	e8 f6 e3 ff ff       	call   f010009d <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101ca7:	89 34 24             	mov    %esi,(%esp)
f0101caa:	e8 b9 f8 ff ff       	call   f0101568 <page_free>
	page_free(pp1);
f0101caf:	89 3c 24             	mov    %edi,(%esp)
f0101cb2:	e8 b1 f8 ff ff       	call   f0101568 <page_free>
	page_free(pp2);
f0101cb7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101cba:	89 14 24             	mov    %edx,(%esp)
f0101cbd:	e8 a6 f8 ff ff       	call   f0101568 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101cc2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cc9:	e8 fa f7 ff ff       	call   f01014c8 <page_alloc>
f0101cce:	89 c6                	mov    %eax,%esi
f0101cd0:	85 c0                	test   %eax,%eax
f0101cd2:	75 24                	jne    f0101cf8 <mem_init+0x3da>
f0101cd4:	c7 44 24 0c 4b 76 10 	movl   $0xf010764b,0xc(%esp)
f0101cdb:	f0 
f0101cdc:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101ce3:	f0 
f0101ce4:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0101ceb:	00 
f0101cec:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101cf3:	e8 a5 e3 ff ff       	call   f010009d <_panic>
	assert((pp1 = page_alloc(0)));
f0101cf8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cff:	e8 c4 f7 ff ff       	call   f01014c8 <page_alloc>
f0101d04:	89 c7                	mov    %eax,%edi
f0101d06:	85 c0                	test   %eax,%eax
f0101d08:	75 24                	jne    f0101d2e <mem_init+0x410>
f0101d0a:	c7 44 24 0c 61 76 10 	movl   $0xf0107661,0xc(%esp)
f0101d11:	f0 
f0101d12:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101d19:	f0 
f0101d1a:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0101d21:	00 
f0101d22:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101d29:	e8 6f e3 ff ff       	call   f010009d <_panic>
	assert((pp2 = page_alloc(0)));
f0101d2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d35:	e8 8e f7 ff ff       	call   f01014c8 <page_alloc>
f0101d3a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d3d:	85 c0                	test   %eax,%eax
f0101d3f:	75 24                	jne    f0101d65 <mem_init+0x447>
f0101d41:	c7 44 24 0c 77 76 10 	movl   $0xf0107677,0xc(%esp)
f0101d48:	f0 
f0101d49:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101d50:	f0 
f0101d51:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f0101d58:	00 
f0101d59:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101d60:	e8 38 e3 ff ff       	call   f010009d <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101d65:	39 fe                	cmp    %edi,%esi
f0101d67:	75 24                	jne    f0101d8d <mem_init+0x46f>
f0101d69:	c7 44 24 0c 8d 76 10 	movl   $0xf010768d,0xc(%esp)
f0101d70:	f0 
f0101d71:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101d78:	f0 
f0101d79:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0101d80:	00 
f0101d81:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101d88:	e8 10 e3 ff ff       	call   f010009d <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d8d:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101d90:	74 05                	je     f0101d97 <mem_init+0x479>
f0101d92:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101d95:	75 24                	jne    f0101dbb <mem_init+0x49d>
f0101d97:	c7 44 24 0c 1c 7a 10 	movl   $0xf0107a1c,0xc(%esp)
f0101d9e:	f0 
f0101d9f:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101da6:	f0 
f0101da7:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0101dae:	00 
f0101daf:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101db6:	e8 e2 e2 ff ff       	call   f010009d <_panic>
	assert(!page_alloc(0));
f0101dbb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101dc2:	e8 01 f7 ff ff       	call   f01014c8 <page_alloc>
f0101dc7:	85 c0                	test   %eax,%eax
f0101dc9:	74 24                	je     f0101def <mem_init+0x4d1>
f0101dcb:	c7 44 24 0c f6 76 10 	movl   $0xf01076f6,0xc(%esp)
f0101dd2:	f0 
f0101dd3:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101dda:	f0 
f0101ddb:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0101de2:	00 
f0101de3:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101dea:	e8 ae e2 ff ff       	call   f010009d <_panic>
f0101def:	89 f0                	mov    %esi,%eax
f0101df1:	2b 05 98 5e 22 f0    	sub    0xf0225e98,%eax
f0101df7:	c1 f8 03             	sar    $0x3,%eax
f0101dfa:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101dfd:	89 c2                	mov    %eax,%edx
f0101dff:	c1 ea 0c             	shr    $0xc,%edx
f0101e02:	3b 15 90 5e 22 f0    	cmp    0xf0225e90,%edx
f0101e08:	72 20                	jb     f0101e2a <mem_init+0x50c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e0e:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0101e15:	f0 
f0101e16:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101e1d:	00 
f0101e1e:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f0101e25:	e8 73 e2 ff ff       	call   f010009d <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101e2a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e31:	00 
f0101e32:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101e39:	00 
	return (void *)(pa + KERNBASE);
f0101e3a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e3f:	89 04 24             	mov    %eax,(%esp)
f0101e42:	e8 6a 40 00 00       	call   f0105eb1 <memset>
	page_free(pp0);
f0101e47:	89 34 24             	mov    %esi,(%esp)
f0101e4a:	e8 19 f7 ff ff       	call   f0101568 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101e4f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101e56:	e8 6d f6 ff ff       	call   f01014c8 <page_alloc>
f0101e5b:	85 c0                	test   %eax,%eax
f0101e5d:	75 24                	jne    f0101e83 <mem_init+0x565>
f0101e5f:	c7 44 24 0c 05 77 10 	movl   $0xf0107705,0xc(%esp)
f0101e66:	f0 
f0101e67:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101e6e:	f0 
f0101e6f:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0101e76:	00 
f0101e77:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101e7e:	e8 1a e2 ff ff       	call   f010009d <_panic>
	assert(pp && pp0 == pp);
f0101e83:	39 c6                	cmp    %eax,%esi
f0101e85:	74 24                	je     f0101eab <mem_init+0x58d>
f0101e87:	c7 44 24 0c 23 77 10 	movl   $0xf0107723,0xc(%esp)
f0101e8e:	f0 
f0101e8f:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101e96:	f0 
f0101e97:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f0101e9e:	00 
f0101e9f:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101ea6:	e8 f2 e1 ff ff       	call   f010009d <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101eab:	89 f2                	mov    %esi,%edx
f0101ead:	2b 15 98 5e 22 f0    	sub    0xf0225e98,%edx
f0101eb3:	c1 fa 03             	sar    $0x3,%edx
f0101eb6:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101eb9:	89 d0                	mov    %edx,%eax
f0101ebb:	c1 e8 0c             	shr    $0xc,%eax
f0101ebe:	3b 05 90 5e 22 f0    	cmp    0xf0225e90,%eax
f0101ec4:	72 20                	jb     f0101ee6 <mem_init+0x5c8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ec6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101eca:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0101ed1:	f0 
f0101ed2:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101ed9:	00 
f0101eda:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f0101ee1:	e8 b7 e1 ff ff       	call   f010009d <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101ee6:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101eed:	75 11                	jne    f0101f00 <mem_init+0x5e2>
f0101eef:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101ef5:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101efb:	80 38 00             	cmpb   $0x0,(%eax)
f0101efe:	74 24                	je     f0101f24 <mem_init+0x606>
f0101f00:	c7 44 24 0c 33 77 10 	movl   $0xf0107733,0xc(%esp)
f0101f07:	f0 
f0101f08:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101f0f:	f0 
f0101f10:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f0101f17:	00 
f0101f18:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101f1f:	e8 79 e1 ff ff       	call   f010009d <_panic>
f0101f24:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101f27:	39 d0                	cmp    %edx,%eax
f0101f29:	75 d0                	jne    f0101efb <mem_init+0x5dd>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101f2b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101f2e:	89 0d 30 52 22 f0    	mov    %ecx,0xf0225230

	// free the pages we took
	page_free(pp0);
f0101f34:	89 34 24             	mov    %esi,(%esp)
f0101f37:	e8 2c f6 ff ff       	call   f0101568 <page_free>
	page_free(pp1);
f0101f3c:	89 3c 24             	mov    %edi,(%esp)
f0101f3f:	e8 24 f6 ff ff       	call   f0101568 <page_free>
	page_free(pp2);
f0101f44:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f47:	89 04 24             	mov    %eax,(%esp)
f0101f4a:	e8 19 f6 ff ff       	call   f0101568 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f4f:	a1 30 52 22 f0       	mov    0xf0225230,%eax
f0101f54:	85 c0                	test   %eax,%eax
f0101f56:	74 09                	je     f0101f61 <mem_init+0x643>
		--nfree;
f0101f58:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f5b:	8b 00                	mov    (%eax),%eax
f0101f5d:	85 c0                	test   %eax,%eax
f0101f5f:	75 f7                	jne    f0101f58 <mem_init+0x63a>
		--nfree;
	assert(nfree == 0);
f0101f61:	85 db                	test   %ebx,%ebx
f0101f63:	74 24                	je     f0101f89 <mem_init+0x66b>
f0101f65:	c7 44 24 0c 3d 77 10 	movl   $0xf010773d,0xc(%esp)
f0101f6c:	f0 
f0101f6d:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101f74:	f0 
f0101f75:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f0101f7c:	00 
f0101f7d:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101f84:	e8 14 e1 ff ff       	call   f010009d <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101f89:	c7 04 24 3c 7a 10 f0 	movl   $0xf0107a3c,(%esp)
f0101f90:	e8 89 24 00 00       	call   f010441e <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	cprintf("so far so good\n");
f0101f95:	c7 04 24 48 77 10 f0 	movl   $0xf0107748,(%esp)
f0101f9c:	e8 7d 24 00 00       	call   f010441e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101fa1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fa8:	e8 1b f5 ff ff       	call   f01014c8 <page_alloc>
f0101fad:	89 c6                	mov    %eax,%esi
f0101faf:	85 c0                	test   %eax,%eax
f0101fb1:	75 24                	jne    f0101fd7 <mem_init+0x6b9>
f0101fb3:	c7 44 24 0c 4b 76 10 	movl   $0xf010764b,0xc(%esp)
f0101fba:	f0 
f0101fbb:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101fc2:	f0 
f0101fc3:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0101fca:	00 
f0101fcb:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0101fd2:	e8 c6 e0 ff ff       	call   f010009d <_panic>
	assert((pp1 = page_alloc(0)));
f0101fd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fde:	e8 e5 f4 ff ff       	call   f01014c8 <page_alloc>
f0101fe3:	89 c7                	mov    %eax,%edi
f0101fe5:	85 c0                	test   %eax,%eax
f0101fe7:	75 24                	jne    f010200d <mem_init+0x6ef>
f0101fe9:	c7 44 24 0c 61 76 10 	movl   $0xf0107661,0xc(%esp)
f0101ff0:	f0 
f0101ff1:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0101ff8:	f0 
f0101ff9:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0102000:	00 
f0102001:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102008:	e8 90 e0 ff ff       	call   f010009d <_panic>
	assert((pp2 = page_alloc(0)));
f010200d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102014:	e8 af f4 ff ff       	call   f01014c8 <page_alloc>
f0102019:	89 c3                	mov    %eax,%ebx
f010201b:	85 c0                	test   %eax,%eax
f010201d:	75 24                	jne    f0102043 <mem_init+0x725>
f010201f:	c7 44 24 0c 77 76 10 	movl   $0xf0107677,0xc(%esp)
f0102026:	f0 
f0102027:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010202e:	f0 
f010202f:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102036:	00 
f0102037:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010203e:	e8 5a e0 ff ff       	call   f010009d <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102043:	39 fe                	cmp    %edi,%esi
f0102045:	75 24                	jne    f010206b <mem_init+0x74d>
f0102047:	c7 44 24 0c 8d 76 10 	movl   $0xf010768d,0xc(%esp)
f010204e:	f0 
f010204f:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102056:	f0 
f0102057:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f010205e:	00 
f010205f:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102066:	e8 32 e0 ff ff       	call   f010009d <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010206b:	39 c7                	cmp    %eax,%edi
f010206d:	74 04                	je     f0102073 <mem_init+0x755>
f010206f:	39 c6                	cmp    %eax,%esi
f0102071:	75 24                	jne    f0102097 <mem_init+0x779>
f0102073:	c7 44 24 0c 1c 7a 10 	movl   $0xf0107a1c,0xc(%esp)
f010207a:	f0 
f010207b:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102082:	f0 
f0102083:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f010208a:	00 
f010208b:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102092:	e8 06 e0 ff ff       	call   f010009d <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102097:	8b 15 30 52 22 f0    	mov    0xf0225230,%edx
f010209d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	page_free_list = 0;
f01020a0:	c7 05 30 52 22 f0 00 	movl   $0x0,0xf0225230
f01020a7:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01020aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020b1:	e8 12 f4 ff ff       	call   f01014c8 <page_alloc>
f01020b6:	85 c0                	test   %eax,%eax
f01020b8:	74 24                	je     f01020de <mem_init+0x7c0>
f01020ba:	c7 44 24 0c f6 76 10 	movl   $0xf01076f6,0xc(%esp)
f01020c1:	f0 
f01020c2:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01020c9:	f0 
f01020ca:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f01020d1:	00 
f01020d2:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01020d9:	e8 bf df ff ff       	call   f010009d <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01020de:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01020e1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01020e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020ec:	00 
f01020ed:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f01020f2:	89 04 24             	mov    %eax,(%esp)
f01020f5:	e8 29 f6 ff ff       	call   f0101723 <page_lookup>
f01020fa:	85 c0                	test   %eax,%eax
f01020fc:	74 24                	je     f0102122 <mem_init+0x804>
f01020fe:	c7 44 24 0c 5c 7a 10 	movl   $0xf0107a5c,0xc(%esp)
f0102105:	f0 
f0102106:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010210d:	f0 
f010210e:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0102115:	00 
f0102116:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010211d:	e8 7b df ff ff       	call   f010009d <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102122:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102129:	00 
f010212a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102131:	00 
f0102132:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102136:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f010213b:	89 04 24             	mov    %eax,(%esp)
f010213e:	e8 e6 f6 ff ff       	call   f0101829 <page_insert>
f0102143:	85 c0                	test   %eax,%eax
f0102145:	78 24                	js     f010216b <mem_init+0x84d>
f0102147:	c7 44 24 0c 94 7a 10 	movl   $0xf0107a94,0xc(%esp)
f010214e:	f0 
f010214f:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102156:	f0 
f0102157:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f010215e:	00 
f010215f:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102166:	e8 32 df ff ff       	call   f010009d <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010216b:	89 34 24             	mov    %esi,(%esp)
f010216e:	e8 f5 f3 ff ff       	call   f0101568 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102173:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010217a:	00 
f010217b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102182:	00 
f0102183:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102187:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f010218c:	89 04 24             	mov    %eax,(%esp)
f010218f:	e8 95 f6 ff ff       	call   f0101829 <page_insert>
f0102194:	85 c0                	test   %eax,%eax
f0102196:	74 24                	je     f01021bc <mem_init+0x89e>
f0102198:	c7 44 24 0c c4 7a 10 	movl   $0xf0107ac4,0xc(%esp)
f010219f:	f0 
f01021a0:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01021a7:	f0 
f01021a8:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f01021af:	00 
f01021b0:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01021b7:	e8 e1 de ff ff       	call   f010009d <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01021bc:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f01021c1:	8b 08                	mov    (%eax),%ecx
f01021c3:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01021c9:	89 f2                	mov    %esi,%edx
f01021cb:	2b 15 98 5e 22 f0    	sub    0xf0225e98,%edx
f01021d1:	c1 fa 03             	sar    $0x3,%edx
f01021d4:	c1 e2 0c             	shl    $0xc,%edx
f01021d7:	39 d1                	cmp    %edx,%ecx
f01021d9:	74 24                	je     f01021ff <mem_init+0x8e1>
f01021db:	c7 44 24 0c f4 7a 10 	movl   $0xf0107af4,0xc(%esp)
f01021e2:	f0 
f01021e3:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01021ea:	f0 
f01021eb:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f01021f2:	00 
f01021f3:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01021fa:	e8 9e de ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01021ff:	ba 00 00 00 00       	mov    $0x0,%edx
f0102204:	e8 a8 ed ff ff       	call   f0100fb1 <check_va2pa>
f0102209:	89 fa                	mov    %edi,%edx
f010220b:	2b 15 98 5e 22 f0    	sub    0xf0225e98,%edx
f0102211:	c1 fa 03             	sar    $0x3,%edx
f0102214:	c1 e2 0c             	shl    $0xc,%edx
f0102217:	39 d0                	cmp    %edx,%eax
f0102219:	74 24                	je     f010223f <mem_init+0x921>
f010221b:	c7 44 24 0c 1c 7b 10 	movl   $0xf0107b1c,0xc(%esp)
f0102222:	f0 
f0102223:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010222a:	f0 
f010222b:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0102232:	00 
f0102233:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010223a:	e8 5e de ff ff       	call   f010009d <_panic>
	assert(pp1->pp_ref == 1);
f010223f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102244:	74 24                	je     f010226a <mem_init+0x94c>
f0102246:	c7 44 24 0c 58 77 10 	movl   $0xf0107758,0xc(%esp)
f010224d:	f0 
f010224e:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102255:	f0 
f0102256:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f010225d:	00 
f010225e:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102265:	e8 33 de ff ff       	call   f010009d <_panic>
	assert(pp0->pp_ref == 1);
f010226a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010226f:	74 24                	je     f0102295 <mem_init+0x977>
f0102271:	c7 44 24 0c 69 77 10 	movl   $0xf0107769,0xc(%esp)
f0102278:	f0 
f0102279:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102280:	f0 
f0102281:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0102288:	00 
f0102289:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102290:	e8 08 de ff ff       	call   f010009d <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102295:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010229c:	00 
f010229d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022a4:	00 
f01022a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01022a9:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f01022ae:	89 04 24             	mov    %eax,(%esp)
f01022b1:	e8 73 f5 ff ff       	call   f0101829 <page_insert>
f01022b6:	85 c0                	test   %eax,%eax
f01022b8:	74 24                	je     f01022de <mem_init+0x9c0>
f01022ba:	c7 44 24 0c 4c 7b 10 	movl   $0xf0107b4c,0xc(%esp)
f01022c1:	f0 
f01022c2:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01022c9:	f0 
f01022ca:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f01022d1:	00 
f01022d2:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01022d9:	e8 bf dd ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022de:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022e3:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f01022e8:	e8 c4 ec ff ff       	call   f0100fb1 <check_va2pa>
f01022ed:	89 da                	mov    %ebx,%edx
f01022ef:	2b 15 98 5e 22 f0    	sub    0xf0225e98,%edx
f01022f5:	c1 fa 03             	sar    $0x3,%edx
f01022f8:	c1 e2 0c             	shl    $0xc,%edx
f01022fb:	39 d0                	cmp    %edx,%eax
f01022fd:	74 24                	je     f0102323 <mem_init+0xa05>
f01022ff:	c7 44 24 0c 88 7b 10 	movl   $0xf0107b88,0xc(%esp)
f0102306:	f0 
f0102307:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010230e:	f0 
f010230f:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0102316:	00 
f0102317:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010231e:	e8 7a dd ff ff       	call   f010009d <_panic>
	assert(pp2->pp_ref == 1);
f0102323:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102328:	74 24                	je     f010234e <mem_init+0xa30>
f010232a:	c7 44 24 0c 7a 77 10 	movl   $0xf010777a,0xc(%esp)
f0102331:	f0 
f0102332:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102339:	f0 
f010233a:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0102341:	00 
f0102342:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102349:	e8 4f dd ff ff       	call   f010009d <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010234e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102355:	e8 6e f1 ff ff       	call   f01014c8 <page_alloc>
f010235a:	85 c0                	test   %eax,%eax
f010235c:	74 24                	je     f0102382 <mem_init+0xa64>
f010235e:	c7 44 24 0c f6 76 10 	movl   $0xf01076f6,0xc(%esp)
f0102365:	f0 
f0102366:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010236d:	f0 
f010236e:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0102375:	00 
f0102376:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010237d:	e8 1b dd ff ff       	call   f010009d <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102382:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102389:	00 
f010238a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102391:	00 
f0102392:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102396:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f010239b:	89 04 24             	mov    %eax,(%esp)
f010239e:	e8 86 f4 ff ff       	call   f0101829 <page_insert>
f01023a3:	85 c0                	test   %eax,%eax
f01023a5:	74 24                	je     f01023cb <mem_init+0xaad>
f01023a7:	c7 44 24 0c 4c 7b 10 	movl   $0xf0107b4c,0xc(%esp)
f01023ae:	f0 
f01023af:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01023b6:	f0 
f01023b7:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f01023be:	00 
f01023bf:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01023c6:	e8 d2 dc ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023cb:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023d0:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f01023d5:	e8 d7 eb ff ff       	call   f0100fb1 <check_va2pa>
f01023da:	89 da                	mov    %ebx,%edx
f01023dc:	2b 15 98 5e 22 f0    	sub    0xf0225e98,%edx
f01023e2:	c1 fa 03             	sar    $0x3,%edx
f01023e5:	c1 e2 0c             	shl    $0xc,%edx
f01023e8:	39 d0                	cmp    %edx,%eax
f01023ea:	74 24                	je     f0102410 <mem_init+0xaf2>
f01023ec:	c7 44 24 0c 88 7b 10 	movl   $0xf0107b88,0xc(%esp)
f01023f3:	f0 
f01023f4:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01023fb:	f0 
f01023fc:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0102403:	00 
f0102404:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010240b:	e8 8d dc ff ff       	call   f010009d <_panic>
	assert(pp2->pp_ref == 1);
f0102410:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102415:	74 24                	je     f010243b <mem_init+0xb1d>
f0102417:	c7 44 24 0c 7a 77 10 	movl   $0xf010777a,0xc(%esp)
f010241e:	f0 
f010241f:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102426:	f0 
f0102427:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f010242e:	00 
f010242f:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102436:	e8 62 dc ff ff       	call   f010009d <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010243b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102442:	e8 81 f0 ff ff       	call   f01014c8 <page_alloc>
f0102447:	85 c0                	test   %eax,%eax
f0102449:	74 24                	je     f010246f <mem_init+0xb51>
f010244b:	c7 44 24 0c f6 76 10 	movl   $0xf01076f6,0xc(%esp)
f0102452:	f0 
f0102453:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010245a:	f0 
f010245b:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f0102462:	00 
f0102463:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010246a:	e8 2e dc ff ff       	call   f010009d <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010246f:	8b 15 94 5e 22 f0    	mov    0xf0225e94,%edx
f0102475:	8b 02                	mov    (%edx),%eax
f0102477:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010247c:	89 c1                	mov    %eax,%ecx
f010247e:	c1 e9 0c             	shr    $0xc,%ecx
f0102481:	3b 0d 90 5e 22 f0    	cmp    0xf0225e90,%ecx
f0102487:	72 20                	jb     f01024a9 <mem_init+0xb8b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102489:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010248d:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0102494:	f0 
f0102495:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f010249c:	00 
f010249d:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01024a4:	e8 f4 db ff ff       	call   f010009d <_panic>
	return (void *)(pa + KERNBASE);
f01024a9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01024b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01024b8:	00 
f01024b9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024c0:	00 
f01024c1:	89 14 24             	mov    %edx,(%esp)
f01024c4:	e8 fd f0 ff ff       	call   f01015c6 <pgdir_walk>
f01024c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01024cc:	83 c2 04             	add    $0x4,%edx
f01024cf:	39 d0                	cmp    %edx,%eax
f01024d1:	74 24                	je     f01024f7 <mem_init+0xbd9>
f01024d3:	c7 44 24 0c b8 7b 10 	movl   $0xf0107bb8,0xc(%esp)
f01024da:	f0 
f01024db:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01024e2:	f0 
f01024e3:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f01024ea:	00 
f01024eb:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01024f2:	e8 a6 db ff ff       	call   f010009d <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01024f7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01024fe:	00 
f01024ff:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102506:	00 
f0102507:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010250b:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102510:	89 04 24             	mov    %eax,(%esp)
f0102513:	e8 11 f3 ff ff       	call   f0101829 <page_insert>
f0102518:	85 c0                	test   %eax,%eax
f010251a:	74 24                	je     f0102540 <mem_init+0xc22>
f010251c:	c7 44 24 0c f8 7b 10 	movl   $0xf0107bf8,0xc(%esp)
f0102523:	f0 
f0102524:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010252b:	f0 
f010252c:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0102533:	00 
f0102534:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010253b:	e8 5d db ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102540:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102545:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f010254a:	e8 62 ea ff ff       	call   f0100fb1 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010254f:	89 da                	mov    %ebx,%edx
f0102551:	2b 15 98 5e 22 f0    	sub    0xf0225e98,%edx
f0102557:	c1 fa 03             	sar    $0x3,%edx
f010255a:	c1 e2 0c             	shl    $0xc,%edx
f010255d:	39 d0                	cmp    %edx,%eax
f010255f:	74 24                	je     f0102585 <mem_init+0xc67>
f0102561:	c7 44 24 0c 88 7b 10 	movl   $0xf0107b88,0xc(%esp)
f0102568:	f0 
f0102569:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102570:	f0 
f0102571:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0102578:	00 
f0102579:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102580:	e8 18 db ff ff       	call   f010009d <_panic>
	assert(pp2->pp_ref == 1);
f0102585:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010258a:	74 24                	je     f01025b0 <mem_init+0xc92>
f010258c:	c7 44 24 0c 7a 77 10 	movl   $0xf010777a,0xc(%esp)
f0102593:	f0 
f0102594:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010259b:	f0 
f010259c:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f01025a3:	00 
f01025a4:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01025ab:	e8 ed da ff ff       	call   f010009d <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01025b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01025b7:	00 
f01025b8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025bf:	00 
f01025c0:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f01025c5:	89 04 24             	mov    %eax,(%esp)
f01025c8:	e8 f9 ef ff ff       	call   f01015c6 <pgdir_walk>
f01025cd:	f6 00 04             	testb  $0x4,(%eax)
f01025d0:	75 24                	jne    f01025f6 <mem_init+0xcd8>
f01025d2:	c7 44 24 0c 38 7c 10 	movl   $0xf0107c38,0xc(%esp)
f01025d9:	f0 
f01025da:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01025e1:	f0 
f01025e2:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f01025e9:	00 
f01025ea:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01025f1:	e8 a7 da ff ff       	call   f010009d <_panic>
	cprintf("pp2 %x\n", pp2);
f01025f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01025fa:	c7 04 24 8b 77 10 f0 	movl   $0xf010778b,(%esp)
f0102601:	e8 18 1e 00 00       	call   f010441e <cprintf>
	cprintf("kern_pgdir %x\n", kern_pgdir);
f0102606:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f010260b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010260f:	c7 04 24 93 77 10 f0 	movl   $0xf0107793,(%esp)
f0102616:	e8 03 1e 00 00       	call   f010441e <cprintf>
	cprintf("kern_pgdir[0] is %x\n", kern_pgdir[0]);
f010261b:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102620:	8b 00                	mov    (%eax),%eax
f0102622:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102626:	c7 04 24 a2 77 10 f0 	movl   $0xf01077a2,(%esp)
f010262d:	e8 ec 1d 00 00       	call   f010441e <cprintf>
	assert(kern_pgdir[0] & PTE_U);
f0102632:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102637:	f6 00 04             	testb  $0x4,(%eax)
f010263a:	75 24                	jne    f0102660 <mem_init+0xd42>
f010263c:	c7 44 24 0c b7 77 10 	movl   $0xf01077b7,0xc(%esp)
f0102643:	f0 
f0102644:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010264b:	f0 
f010264c:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0102653:	00 
f0102654:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010265b:	e8 3d da ff ff       	call   f010009d <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102660:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102667:	00 
f0102668:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010266f:	00 
f0102670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102674:	89 04 24             	mov    %eax,(%esp)
f0102677:	e8 ad f1 ff ff       	call   f0101829 <page_insert>
f010267c:	85 c0                	test   %eax,%eax
f010267e:	74 24                	je     f01026a4 <mem_init+0xd86>
f0102680:	c7 44 24 0c 4c 7b 10 	movl   $0xf0107b4c,0xc(%esp)
f0102687:	f0 
f0102688:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010268f:	f0 
f0102690:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0102697:	00 
f0102698:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010269f:	e8 f9 d9 ff ff       	call   f010009d <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01026a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026ab:	00 
f01026ac:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026b3:	00 
f01026b4:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f01026b9:	89 04 24             	mov    %eax,(%esp)
f01026bc:	e8 05 ef ff ff       	call   f01015c6 <pgdir_walk>
f01026c1:	f6 00 02             	testb  $0x2,(%eax)
f01026c4:	75 24                	jne    f01026ea <mem_init+0xdcc>
f01026c6:	c7 44 24 0c 6c 7c 10 	movl   $0xf0107c6c,0xc(%esp)
f01026cd:	f0 
f01026ce:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01026d5:	f0 
f01026d6:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f01026dd:	00 
f01026de:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01026e5:	e8 b3 d9 ff ff       	call   f010009d <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026f1:	00 
f01026f2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026f9:	00 
f01026fa:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f01026ff:	89 04 24             	mov    %eax,(%esp)
f0102702:	e8 bf ee ff ff       	call   f01015c6 <pgdir_walk>
f0102707:	f6 00 04             	testb  $0x4,(%eax)
f010270a:	74 24                	je     f0102730 <mem_init+0xe12>
f010270c:	c7 44 24 0c a0 7c 10 	movl   $0xf0107ca0,0xc(%esp)
f0102713:	f0 
f0102714:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010271b:	f0 
f010271c:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0102723:	00 
f0102724:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010272b:	e8 6d d9 ff ff       	call   f010009d <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102730:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102737:	00 
f0102738:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010273f:	00 
f0102740:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102744:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102749:	89 04 24             	mov    %eax,(%esp)
f010274c:	e8 d8 f0 ff ff       	call   f0101829 <page_insert>
f0102751:	85 c0                	test   %eax,%eax
f0102753:	78 24                	js     f0102779 <mem_init+0xe5b>
f0102755:	c7 44 24 0c d8 7c 10 	movl   $0xf0107cd8,0xc(%esp)
f010275c:	f0 
f010275d:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102764:	f0 
f0102765:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f010276c:	00 
f010276d:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102774:	e8 24 d9 ff ff       	call   f010009d <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102779:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102780:	00 
f0102781:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102788:	00 
f0102789:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010278d:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102792:	89 04 24             	mov    %eax,(%esp)
f0102795:	e8 8f f0 ff ff       	call   f0101829 <page_insert>
f010279a:	85 c0                	test   %eax,%eax
f010279c:	74 24                	je     f01027c2 <mem_init+0xea4>
f010279e:	c7 44 24 0c 10 7d 10 	movl   $0xf0107d10,0xc(%esp)
f01027a5:	f0 
f01027a6:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01027ad:	f0 
f01027ae:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f01027b5:	00 
f01027b6:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01027bd:	e8 db d8 ff ff       	call   f010009d <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01027c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01027c9:	00 
f01027ca:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01027d1:	00 
f01027d2:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f01027d7:	89 04 24             	mov    %eax,(%esp)
f01027da:	e8 e7 ed ff ff       	call   f01015c6 <pgdir_walk>
f01027df:	f6 00 04             	testb  $0x4,(%eax)
f01027e2:	74 24                	je     f0102808 <mem_init+0xeea>
f01027e4:	c7 44 24 0c a0 7c 10 	movl   $0xf0107ca0,0xc(%esp)
f01027eb:	f0 
f01027ec:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01027f3:	f0 
f01027f4:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f01027fb:	00 
f01027fc:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102803:	e8 95 d8 ff ff       	call   f010009d <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102808:	ba 00 00 00 00       	mov    $0x0,%edx
f010280d:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102812:	e8 9a e7 ff ff       	call   f0100fb1 <check_va2pa>
f0102817:	89 fa                	mov    %edi,%edx
f0102819:	2b 15 98 5e 22 f0    	sub    0xf0225e98,%edx
f010281f:	c1 fa 03             	sar    $0x3,%edx
f0102822:	c1 e2 0c             	shl    $0xc,%edx
f0102825:	39 d0                	cmp    %edx,%eax
f0102827:	74 24                	je     f010284d <mem_init+0xf2f>
f0102829:	c7 44 24 0c 4c 7d 10 	movl   $0xf0107d4c,0xc(%esp)
f0102830:	f0 
f0102831:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102838:	f0 
f0102839:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0102840:	00 
f0102841:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102848:	e8 50 d8 ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010284d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102852:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102857:	e8 55 e7 ff ff       	call   f0100fb1 <check_va2pa>
f010285c:	89 fa                	mov    %edi,%edx
f010285e:	2b 15 98 5e 22 f0    	sub    0xf0225e98,%edx
f0102864:	c1 fa 03             	sar    $0x3,%edx
f0102867:	c1 e2 0c             	shl    $0xc,%edx
f010286a:	39 d0                	cmp    %edx,%eax
f010286c:	74 24                	je     f0102892 <mem_init+0xf74>
f010286e:	c7 44 24 0c 78 7d 10 	movl   $0xf0107d78,0xc(%esp)
f0102875:	f0 
f0102876:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010287d:	f0 
f010287e:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0102885:	00 
f0102886:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010288d:	e8 0b d8 ff ff       	call   f010009d <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102892:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102897:	74 24                	je     f01028bd <mem_init+0xf9f>
f0102899:	c7 44 24 0c cd 77 10 	movl   $0xf01077cd,0xc(%esp)
f01028a0:	f0 
f01028a1:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01028a8:	f0 
f01028a9:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f01028b0:	00 
f01028b1:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01028b8:	e8 e0 d7 ff ff       	call   f010009d <_panic>
	assert(pp2->pp_ref == 0);
f01028bd:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01028c2:	74 24                	je     f01028e8 <mem_init+0xfca>
f01028c4:	c7 44 24 0c de 77 10 	movl   $0xf01077de,0xc(%esp)
f01028cb:	f0 
f01028cc:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01028d3:	f0 
f01028d4:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f01028db:	00 
f01028dc:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01028e3:	e8 b5 d7 ff ff       	call   f010009d <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01028e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028ef:	e8 d4 eb ff ff       	call   f01014c8 <page_alloc>
f01028f4:	85 c0                	test   %eax,%eax
f01028f6:	74 04                	je     f01028fc <mem_init+0xfde>
f01028f8:	39 c3                	cmp    %eax,%ebx
f01028fa:	74 24                	je     f0102920 <mem_init+0x1002>
f01028fc:	c7 44 24 0c a8 7d 10 	movl   $0xf0107da8,0xc(%esp)
f0102903:	f0 
f0102904:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010290b:	f0 
f010290c:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102913:	00 
f0102914:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010291b:	e8 7d d7 ff ff       	call   f010009d <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102920:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102927:	00 
f0102928:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f010292d:	89 04 24             	mov    %eax,(%esp)
f0102930:	e8 9c ee ff ff       	call   f01017d1 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102935:	ba 00 00 00 00       	mov    $0x0,%edx
f010293a:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f010293f:	e8 6d e6 ff ff       	call   f0100fb1 <check_va2pa>
f0102944:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102947:	74 24                	je     f010296d <mem_init+0x104f>
f0102949:	c7 44 24 0c cc 7d 10 	movl   $0xf0107dcc,0xc(%esp)
f0102950:	f0 
f0102951:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102958:	f0 
f0102959:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f0102960:	00 
f0102961:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102968:	e8 30 d7 ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010296d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102972:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102977:	e8 35 e6 ff ff       	call   f0100fb1 <check_va2pa>
f010297c:	89 fa                	mov    %edi,%edx
f010297e:	2b 15 98 5e 22 f0    	sub    0xf0225e98,%edx
f0102984:	c1 fa 03             	sar    $0x3,%edx
f0102987:	c1 e2 0c             	shl    $0xc,%edx
f010298a:	39 d0                	cmp    %edx,%eax
f010298c:	74 24                	je     f01029b2 <mem_init+0x1094>
f010298e:	c7 44 24 0c 78 7d 10 	movl   $0xf0107d78,0xc(%esp)
f0102995:	f0 
f0102996:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010299d:	f0 
f010299e:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f01029a5:	00 
f01029a6:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01029ad:	e8 eb d6 ff ff       	call   f010009d <_panic>
	assert(pp1->pp_ref == 1);
f01029b2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01029b7:	74 24                	je     f01029dd <mem_init+0x10bf>
f01029b9:	c7 44 24 0c 58 77 10 	movl   $0xf0107758,0xc(%esp)
f01029c0:	f0 
f01029c1:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01029c8:	f0 
f01029c9:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f01029d0:	00 
f01029d1:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01029d8:	e8 c0 d6 ff ff       	call   f010009d <_panic>
	assert(pp2->pp_ref == 0);
f01029dd:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01029e2:	74 24                	je     f0102a08 <mem_init+0x10ea>
f01029e4:	c7 44 24 0c de 77 10 	movl   $0xf01077de,0xc(%esp)
f01029eb:	f0 
f01029ec:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01029f3:	f0 
f01029f4:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f01029fb:	00 
f01029fc:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102a03:	e8 95 d6 ff ff       	call   f010009d <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102a08:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102a0f:	00 
f0102a10:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102a15:	89 04 24             	mov    %eax,(%esp)
f0102a18:	e8 b4 ed ff ff       	call   f01017d1 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102a1d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102a22:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102a27:	e8 85 e5 ff ff       	call   f0100fb1 <check_va2pa>
f0102a2c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a2f:	74 24                	je     f0102a55 <mem_init+0x1137>
f0102a31:	c7 44 24 0c cc 7d 10 	movl   $0xf0107dcc,0xc(%esp)
f0102a38:	f0 
f0102a39:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102a40:	f0 
f0102a41:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0102a48:	00 
f0102a49:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102a50:	e8 48 d6 ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102a55:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a5a:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102a5f:	e8 4d e5 ff ff       	call   f0100fb1 <check_va2pa>
f0102a64:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a67:	74 24                	je     f0102a8d <mem_init+0x116f>
f0102a69:	c7 44 24 0c f0 7d 10 	movl   $0xf0107df0,0xc(%esp)
f0102a70:	f0 
f0102a71:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102a78:	f0 
f0102a79:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0102a80:	00 
f0102a81:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102a88:	e8 10 d6 ff ff       	call   f010009d <_panic>
	assert(pp1->pp_ref == 0);
f0102a8d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102a92:	74 24                	je     f0102ab8 <mem_init+0x119a>
f0102a94:	c7 44 24 0c ef 77 10 	movl   $0xf01077ef,0xc(%esp)
f0102a9b:	f0 
f0102a9c:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102aa3:	f0 
f0102aa4:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0102aab:	00 
f0102aac:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102ab3:	e8 e5 d5 ff ff       	call   f010009d <_panic>
	assert(pp2->pp_ref == 0);
f0102ab8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102abd:	74 24                	je     f0102ae3 <mem_init+0x11c5>
f0102abf:	c7 44 24 0c de 77 10 	movl   $0xf01077de,0xc(%esp)
f0102ac6:	f0 
f0102ac7:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102ace:	f0 
f0102acf:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f0102ad6:	00 
f0102ad7:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102ade:	e8 ba d5 ff ff       	call   f010009d <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102ae3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102aea:	e8 d9 e9 ff ff       	call   f01014c8 <page_alloc>
f0102aef:	85 c0                	test   %eax,%eax
f0102af1:	74 04                	je     f0102af7 <mem_init+0x11d9>
f0102af3:	39 c7                	cmp    %eax,%edi
f0102af5:	74 24                	je     f0102b1b <mem_init+0x11fd>
f0102af7:	c7 44 24 0c 18 7e 10 	movl   $0xf0107e18,0xc(%esp)
f0102afe:	f0 
f0102aff:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102b06:	f0 
f0102b07:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0102b0e:	00 
f0102b0f:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102b16:	e8 82 d5 ff ff       	call   f010009d <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102b1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b22:	e8 a1 e9 ff ff       	call   f01014c8 <page_alloc>
f0102b27:	85 c0                	test   %eax,%eax
f0102b29:	74 24                	je     f0102b4f <mem_init+0x1231>
f0102b2b:	c7 44 24 0c f6 76 10 	movl   $0xf01076f6,0xc(%esp)
f0102b32:	f0 
f0102b33:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102b3a:	f0 
f0102b3b:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102b42:	00 
f0102b43:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102b4a:	e8 4e d5 ff ff       	call   f010009d <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b4f:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102b54:	8b 08                	mov    (%eax),%ecx
f0102b56:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102b5c:	89 f2                	mov    %esi,%edx
f0102b5e:	2b 15 98 5e 22 f0    	sub    0xf0225e98,%edx
f0102b64:	c1 fa 03             	sar    $0x3,%edx
f0102b67:	c1 e2 0c             	shl    $0xc,%edx
f0102b6a:	39 d1                	cmp    %edx,%ecx
f0102b6c:	74 24                	je     f0102b92 <mem_init+0x1274>
f0102b6e:	c7 44 24 0c f4 7a 10 	movl   $0xf0107af4,0xc(%esp)
f0102b75:	f0 
f0102b76:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102b7d:	f0 
f0102b7e:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f0102b85:	00 
f0102b86:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102b8d:	e8 0b d5 ff ff       	call   f010009d <_panic>
	kern_pgdir[0] = 0;
f0102b92:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102b98:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102b9d:	74 24                	je     f0102bc3 <mem_init+0x12a5>
f0102b9f:	c7 44 24 0c 69 77 10 	movl   $0xf0107769,0xc(%esp)
f0102ba6:	f0 
f0102ba7:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102bae:	f0 
f0102baf:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f0102bb6:	00 
f0102bb7:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102bbe:	e8 da d4 ff ff       	call   f010009d <_panic>
	pp0->pp_ref = 0;
f0102bc3:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102bc9:	89 34 24             	mov    %esi,(%esp)
f0102bcc:	e8 97 e9 ff ff       	call   f0101568 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102bd1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102bd8:	00 
f0102bd9:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102be0:	00 
f0102be1:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102be6:	89 04 24             	mov    %eax,(%esp)
f0102be9:	e8 d8 e9 ff ff       	call   f01015c6 <pgdir_walk>
f0102bee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102bf1:	8b 0d 94 5e 22 f0    	mov    0xf0225e94,%ecx
f0102bf7:	8b 51 04             	mov    0x4(%ecx),%edx
f0102bfa:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102c00:	89 55 cc             	mov    %edx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c03:	c1 ea 0c             	shr    $0xc,%edx
f0102c06:	3b 15 90 5e 22 f0    	cmp    0xf0225e90,%edx
f0102c0c:	72 23                	jb     f0102c31 <mem_init+0x1313>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c0e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102c11:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102c15:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0102c1c:	f0 
f0102c1d:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f0102c24:	00 
f0102c25:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102c2c:	e8 6c d4 ff ff       	call   f010009d <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102c31:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102c34:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102c3a:	39 d0                	cmp    %edx,%eax
f0102c3c:	74 24                	je     f0102c62 <mem_init+0x1344>
f0102c3e:	c7 44 24 0c 00 78 10 	movl   $0xf0107800,0xc(%esp)
f0102c45:	f0 
f0102c46:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102c4d:	f0 
f0102c4e:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f0102c55:	00 
f0102c56:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102c5d:	e8 3b d4 ff ff       	call   f010009d <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102c62:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102c69:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c6f:	89 f0                	mov    %esi,%eax
f0102c71:	2b 05 98 5e 22 f0    	sub    0xf0225e98,%eax
f0102c77:	c1 f8 03             	sar    $0x3,%eax
f0102c7a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c7d:	89 c2                	mov    %eax,%edx
f0102c7f:	c1 ea 0c             	shr    $0xc,%edx
f0102c82:	3b 15 90 5e 22 f0    	cmp    0xf0225e90,%edx
f0102c88:	72 20                	jb     f0102caa <mem_init+0x138c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c8e:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0102c95:	f0 
f0102c96:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102c9d:	00 
f0102c9e:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f0102ca5:	e8 f3 d3 ff ff       	call   f010009d <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102caa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102cb1:	00 
f0102cb2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102cb9:	00 
	return (void *)(pa + KERNBASE);
f0102cba:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102cbf:	89 04 24             	mov    %eax,(%esp)
f0102cc2:	e8 ea 31 00 00       	call   f0105eb1 <memset>
	page_free(pp0);
f0102cc7:	89 34 24             	mov    %esi,(%esp)
f0102cca:	e8 99 e8 ff ff       	call   f0101568 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102ccf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102cd6:	00 
f0102cd7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102cde:	00 
f0102cdf:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102ce4:	89 04 24             	mov    %eax,(%esp)
f0102ce7:	e8 da e8 ff ff       	call   f01015c6 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cec:	89 f2                	mov    %esi,%edx
f0102cee:	2b 15 98 5e 22 f0    	sub    0xf0225e98,%edx
f0102cf4:	c1 fa 03             	sar    $0x3,%edx
f0102cf7:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cfa:	89 d0                	mov    %edx,%eax
f0102cfc:	c1 e8 0c             	shr    $0xc,%eax
f0102cff:	3b 05 90 5e 22 f0    	cmp    0xf0225e90,%eax
f0102d05:	72 20                	jb     f0102d27 <mem_init+0x1409>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d07:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d0b:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0102d12:	f0 
f0102d13:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102d1a:	00 
f0102d1b:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f0102d22:	e8 76 d3 ff ff       	call   f010009d <_panic>
	return (void *)(pa + KERNBASE);
f0102d27:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102d2d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102d30:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102d37:	75 11                	jne    f0102d4a <mem_init+0x142c>
f0102d39:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d3f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102d45:	f6 00 01             	testb  $0x1,(%eax)
f0102d48:	74 24                	je     f0102d6e <mem_init+0x1450>
f0102d4a:	c7 44 24 0c 18 78 10 	movl   $0xf0107818,0xc(%esp)
f0102d51:	f0 
f0102d52:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102d59:	f0 
f0102d5a:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f0102d61:	00 
f0102d62:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102d69:	e8 2f d3 ff ff       	call   f010009d <_panic>
f0102d6e:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102d71:	39 d0                	cmp    %edx,%eax
f0102d73:	75 d0                	jne    f0102d45 <mem_init+0x1427>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102d75:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102d7a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102d80:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102d86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d89:	a3 30 52 22 f0       	mov    %eax,0xf0225230

	// free the pages we took
	page_free(pp0);
f0102d8e:	89 34 24             	mov    %esi,(%esp)
f0102d91:	e8 d2 e7 ff ff       	call   f0101568 <page_free>
	page_free(pp1);
f0102d96:	89 3c 24             	mov    %edi,(%esp)
f0102d99:	e8 ca e7 ff ff       	call   f0101568 <page_free>
	page_free(pp2);
f0102d9e:	89 1c 24             	mov    %ebx,(%esp)
f0102da1:	e8 c2 e7 ff ff       	call   f0101568 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102da6:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102dad:	00 
f0102dae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102db5:	e8 eb ea ff ff       	call   f01018a5 <mmio_map_region>
f0102dba:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102dbc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102dc3:	00 
f0102dc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102dcb:	e8 d5 ea ff ff       	call   f01018a5 <mmio_map_region>
f0102dd0:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102dd2:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102dd8:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102dde:	76 07                	jbe    f0102de7 <mem_init+0x14c9>
f0102de0:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102de5:	76 24                	jbe    f0102e0b <mem_init+0x14ed>
f0102de7:	c7 44 24 0c 3c 7e 10 	movl   $0xf0107e3c,0xc(%esp)
f0102dee:	f0 
f0102def:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102df6:	f0 
f0102df7:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f0102dfe:	00 
f0102dff:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102e06:	e8 92 d2 ff ff       	call   f010009d <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102e0b:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102e11:	76 0e                	jbe    f0102e21 <mem_init+0x1503>
f0102e13:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102e19:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102e1f:	76 24                	jbe    f0102e45 <mem_init+0x1527>
f0102e21:	c7 44 24 0c 64 7e 10 	movl   $0xf0107e64,0xc(%esp)
f0102e28:	f0 
f0102e29:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102e30:	f0 
f0102e31:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f0102e38:	00 
f0102e39:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102e40:	e8 58 d2 ff ff       	call   f010009d <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e45:	89 da                	mov    %ebx,%edx
f0102e47:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102e49:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102e4f:	74 24                	je     f0102e75 <mem_init+0x1557>
f0102e51:	c7 44 24 0c 8c 7e 10 	movl   $0xf0107e8c,0xc(%esp)
f0102e58:	f0 
f0102e59:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102e60:	f0 
f0102e61:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102e68:	00 
f0102e69:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102e70:	e8 28 d2 ff ff       	call   f010009d <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102e75:	39 c6                	cmp    %eax,%esi
f0102e77:	73 24                	jae    f0102e9d <mem_init+0x157f>
f0102e79:	c7 44 24 0c 2f 78 10 	movl   $0xf010782f,0xc(%esp)
f0102e80:	f0 
f0102e81:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102e88:	f0 
f0102e89:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f0102e90:	00 
f0102e91:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102e98:	e8 00 d2 ff ff       	call   f010009d <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102e9d:	89 da                	mov    %ebx,%edx
f0102e9f:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102ea4:	e8 08 e1 ff ff       	call   f0100fb1 <check_va2pa>
f0102ea9:	85 c0                	test   %eax,%eax
f0102eab:	74 24                	je     f0102ed1 <mem_init+0x15b3>
f0102ead:	c7 44 24 0c b4 7e 10 	movl   $0xf0107eb4,0xc(%esp)
f0102eb4:	f0 
f0102eb5:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102ebc:	f0 
f0102ebd:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f0102ec4:	00 
f0102ec5:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102ecc:	e8 cc d1 ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102ed1:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
f0102ed7:	89 fa                	mov    %edi,%edx
f0102ed9:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102ede:	e8 ce e0 ff ff       	call   f0100fb1 <check_va2pa>
f0102ee3:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102ee8:	74 24                	je     f0102f0e <mem_init+0x15f0>
f0102eea:	c7 44 24 0c d8 7e 10 	movl   $0xf0107ed8,0xc(%esp)
f0102ef1:	f0 
f0102ef2:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102ef9:	f0 
f0102efa:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f0102f01:	00 
f0102f02:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102f09:	e8 8f d1 ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102f0e:	89 f2                	mov    %esi,%edx
f0102f10:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102f15:	e8 97 e0 ff ff       	call   f0100fb1 <check_va2pa>
f0102f1a:	85 c0                	test   %eax,%eax
f0102f1c:	74 24                	je     f0102f42 <mem_init+0x1624>
f0102f1e:	c7 44 24 0c 08 7f 10 	movl   $0xf0107f08,0xc(%esp)
f0102f25:	f0 
f0102f26:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102f2d:	f0 
f0102f2e:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f0102f35:	00 
f0102f36:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102f3d:	e8 5b d1 ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102f42:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102f48:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102f4d:	e8 5f e0 ff ff       	call   f0100fb1 <check_va2pa>
f0102f52:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f55:	74 24                	je     f0102f7b <mem_init+0x165d>
f0102f57:	c7 44 24 0c 2c 7f 10 	movl   $0xf0107f2c,0xc(%esp)
f0102f5e:	f0 
f0102f5f:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102f66:	f0 
f0102f67:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f0102f6e:	00 
f0102f6f:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102f76:	e8 22 d1 ff ff       	call   f010009d <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102f7b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f82:	00 
f0102f83:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102f87:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102f8c:	89 04 24             	mov    %eax,(%esp)
f0102f8f:	e8 32 e6 ff ff       	call   f01015c6 <pgdir_walk>
f0102f94:	f6 00 1a             	testb  $0x1a,(%eax)
f0102f97:	75 24                	jne    f0102fbd <mem_init+0x169f>
f0102f99:	c7 44 24 0c 58 7f 10 	movl   $0xf0107f58,0xc(%esp)
f0102fa0:	f0 
f0102fa1:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102fa8:	f0 
f0102fa9:	c7 44 24 04 3e 04 00 	movl   $0x43e,0x4(%esp)
f0102fb0:	00 
f0102fb1:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102fb8:	e8 e0 d0 ff ff       	call   f010009d <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102fbd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102fc4:	00 
f0102fc5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102fc9:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0102fce:	89 04 24             	mov    %eax,(%esp)
f0102fd1:	e8 f0 e5 ff ff       	call   f01015c6 <pgdir_walk>
f0102fd6:	f6 00 04             	testb  $0x4,(%eax)
f0102fd9:	74 24                	je     f0102fff <mem_init+0x16e1>
f0102fdb:	c7 44 24 0c 9c 7f 10 	movl   $0xf0107f9c,0xc(%esp)
f0102fe2:	f0 
f0102fe3:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0102fea:	f0 
f0102feb:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0102ff2:	00 
f0102ff3:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0102ffa:	e8 9e d0 ff ff       	call   f010009d <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102fff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103006:	00 
f0103007:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010300b:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0103010:	89 04 24             	mov    %eax,(%esp)
f0103013:	e8 ae e5 ff ff       	call   f01015c6 <pgdir_walk>
f0103018:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010301e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103025:	00 
f0103026:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010302a:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f010302f:	89 04 24             	mov    %eax,(%esp)
f0103032:	e8 8f e5 ff ff       	call   f01015c6 <pgdir_walk>
f0103037:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010303d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103044:	00 
f0103045:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103049:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f010304e:	89 04 24             	mov    %eax,(%esp)
f0103051:	e8 70 e5 ff ff       	call   f01015c6 <pgdir_walk>
f0103056:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010305c:	c7 04 24 41 78 10 f0 	movl   $0xf0107841,(%esp)
f0103063:	e8 b6 13 00 00       	call   f010441e <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f0103068:	a1 98 5e 22 f0       	mov    0xf0225e98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010306d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103072:	77 20                	ja     f0103094 <mem_init+0x1776>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103074:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103078:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f010307f:	f0 
f0103080:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
f0103087:	00 
f0103088:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010308f:	e8 09 d0 ff ff       	call   f010009d <_panic>
f0103094:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f010309b:	00 
	return (physaddr_t)kva - KERNBASE;
f010309c:	05 00 00 00 10       	add    $0x10000000,%eax
f01030a1:	89 04 24             	mov    %eax,(%esp)
f01030a4:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01030a9:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01030ae:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f01030b3:	e8 b3 e5 ff ff       	call   f010166b <boot_map_region>
		UPAGES, 
		PTSIZE, 
		PADDR(pages), 
		PTE_U);
	cprintf("PADDR(pages) %x\n", PADDR(pages));
f01030b8:	a1 98 5e 22 f0       	mov    0xf0225e98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030bd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030c2:	77 20                	ja     f01030e4 <mem_init+0x17c6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030c8:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f01030cf:	f0 
f01030d0:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
f01030d7:	00 
f01030d8:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01030df:	e8 b9 cf ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f01030e4:	05 00 00 00 10       	add    $0x10000000,%eax
f01030e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030ed:	c7 04 24 5a 78 10 f0 	movl   $0xf010785a,(%esp)
f01030f4:	e8 25 13 00 00       	call   f010441e <cprintf>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,
f01030f9:	a1 3c 52 22 f0       	mov    0xf022523c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030fe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103103:	77 20                	ja     f0103125 <mem_init+0x1807>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103105:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103109:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f0103110:	f0 
f0103111:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
f0103118:	00 
f0103119:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103120:	e8 78 cf ff ff       	call   f010009d <_panic>
f0103125:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f010312c:	00 
	return (physaddr_t)kva - KERNBASE;
f010312d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103132:	89 04 24             	mov    %eax,(%esp)
f0103135:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010313a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010313f:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0103144:	e8 22 e5 ff ff       	call   f010166b <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103149:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f010314e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103153:	77 20                	ja     f0103175 <mem_init+0x1857>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103155:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103159:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f0103160:	f0 
f0103161:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
f0103168:	00 
f0103169:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103170:	e8 28 cf ff ff       	call   f010009d <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0103175:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010317c:	00 
f010317d:	c7 04 24 00 80 11 00 	movl   $0x118000,(%esp)
f0103184:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103189:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010318e:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0103193:	e8 d3 e4 ff ff       	call   f010166b <boot_map_region>
		KSTACKTOP-KSTKSIZE, 
		KSTKSIZE, 
		PADDR(bootstack), 
		PTE_W);
	cprintf("PADDR(bootstack) %x\n", PADDR(bootstack));
f0103198:	c7 44 24 04 00 80 11 	movl   $0x118000,0x4(%esp)
f010319f:	00 
f01031a0:	c7 04 24 6b 78 10 f0 	movl   $0xf010786b,(%esp)
f01031a7:	e8 72 12 00 00       	call   f010441e <cprintf>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f01031ac:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01031b3:	00 
f01031b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031bb:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01031c0:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01031c5:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f01031ca:	e8 9c e4 ff ff       	call   f010166b <boot_map_region>
f01031cf:	c7 45 d0 00 70 22 f0 	movl   $0xf0227000,-0x30(%ebp)
f01031d6:	bb 00 70 22 f0       	mov    $0xf0227000,%ebx
f01031db:	bf 00 80 ff ef       	mov    $0xefff8000,%edi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; ++i) {
f01031e0:	be 00 00 00 00       	mov    $0x0,%esi
		cprintf("percpu_kstacks[%d]: %x\n", i, percpu_kstacks[i]);
f01031e5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01031e9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01031ed:	c7 04 24 80 78 10 f0 	movl   $0xf0107880,(%esp)
f01031f4:	e8 25 12 00 00       	call   f010441e <cprintf>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031f9:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01031ff:	77 20                	ja     f0103221 <mem_init+0x1903>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103201:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103205:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f010320c:	f0 
f010320d:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
f0103214:	00 
f0103215:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010321c:	e8 7c ce ff ff       	call   f010009d <_panic>
		boot_map_region(kern_pgdir, 
f0103221:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103228:	00 
	return (physaddr_t)kva - KERNBASE;
f0103229:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010322f:	89 04 24             	mov    %eax,(%esp)
f0103232:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103237:	89 fa                	mov    %edi,%edx
f0103239:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f010323e:	e8 28 e4 ff ff       	call   f010166b <boot_map_region>
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; ++i) {
f0103243:	83 c6 01             	add    $0x1,%esi
f0103246:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010324c:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0103252:	83 fe 08             	cmp    $0x8,%esi
f0103255:	75 8e                	jne    f01031e5 <mem_init+0x18c7>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0103257:	8b 35 94 5e 22 f0    	mov    0xf0225e94,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010325d:	a1 90 5e 22 f0       	mov    0xf0225e90,%eax
f0103262:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0103269:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f010326f:	74 79                	je     f01032ea <mem_init+0x19cc>
f0103271:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103276:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010327c:	89 f0                	mov    %esi,%eax
f010327e:	e8 2e dd ff ff       	call   f0100fb1 <check_va2pa>
f0103283:	8b 15 98 5e 22 f0    	mov    0xf0225e98,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103289:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010328f:	77 20                	ja     f01032b1 <mem_init+0x1993>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103291:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103295:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f010329c:	f0 
f010329d:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f01032a4:	00 
f01032a5:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01032ac:	e8 ec cd ff ff       	call   f010009d <_panic>
f01032b1:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f01032b8:	39 d0                	cmp    %edx,%eax
f01032ba:	74 24                	je     f01032e0 <mem_init+0x19c2>
f01032bc:	c7 44 24 0c d0 7f 10 	movl   $0xf0107fd0,0xc(%esp)
f01032c3:	f0 
f01032c4:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01032cb:	f0 
f01032cc:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f01032d3:	00 
f01032d4:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01032db:	e8 bd cd ff ff       	call   f010009d <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01032e0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01032e6:	39 df                	cmp    %ebx,%edi
f01032e8:	77 8c                	ja     f0103276 <mem_init+0x1958>
f01032ea:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01032ef:	8d 93 00 00 c0 ee    	lea    -0x11400000(%ebx),%edx
f01032f5:	89 f0                	mov    %esi,%eax
f01032f7:	e8 b5 dc ff ff       	call   f0100fb1 <check_va2pa>
f01032fc:	8b 15 3c 52 22 f0    	mov    0xf022523c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103302:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103308:	77 20                	ja     f010332a <mem_init+0x1a0c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010330a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010330e:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f0103315:	f0 
f0103316:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f010331d:	00 
f010331e:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103325:	e8 73 cd ff ff       	call   f010009d <_panic>
f010332a:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0103331:	39 d0                	cmp    %edx,%eax
f0103333:	74 24                	je     f0103359 <mem_init+0x1a3b>
f0103335:	c7 44 24 0c 04 80 10 	movl   $0xf0108004,0xc(%esp)
f010333c:	f0 
f010333d:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0103344:	f0 
f0103345:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f010334c:	00 
f010334d:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103354:	e8 44 cd ff ff       	call   f010009d <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103359:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010335f:	81 fb 00 f0 01 00    	cmp    $0x1f000,%ebx
f0103365:	75 88                	jne    f01032ef <mem_init+0x19d1>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103367:	a1 90 5e 22 f0       	mov    0xf0225e90,%eax
f010336c:	c1 e0 0c             	shl    $0xc,%eax
f010336f:	85 c0                	test   %eax,%eax
f0103371:	74 4c                	je     f01033bf <mem_init+0x1aa1>
f0103373:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103378:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010337e:	89 f0                	mov    %esi,%eax
f0103380:	e8 2c dc ff ff       	call   f0100fb1 <check_va2pa>
f0103385:	39 c3                	cmp    %eax,%ebx
f0103387:	74 24                	je     f01033ad <mem_init+0x1a8f>
f0103389:	c7 44 24 0c 38 80 10 	movl   $0xf0108038,0xc(%esp)
f0103390:	f0 
f0103391:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0103398:	f0 
f0103399:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f01033a0:	00 
f01033a1:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01033a8:	e8 f0 cc ff ff       	call   f010009d <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01033ad:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01033b3:	a1 90 5e 22 f0       	mov    0xf0225e90,%eax
f01033b8:	c1 e0 0c             	shl    $0xc,%eax
f01033bb:	39 c3                	cmp    %eax,%ebx
f01033bd:	72 b9                	jb     f0103378 <mem_init+0x1a5a>
f01033bf:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f01033c4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	return (physaddr_t)kva - KERNBASE;
f01033c7:	89 da                	mov    %ebx,%edx
f01033c9:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01033cf:	89 55 cc             	mov    %edx,-0x34(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01033d2:	8d 97 00 80 00 00    	lea    0x8000(%edi),%edx
			// check_va2pa(pgdir, base + KSTKGAP + i));

		// cprintf("PADDR(percpu_kstacks[n]) + i: %x\n", 
		//	PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01033d8:	89 f0                	mov    %esi,%eax
f01033da:	e8 d2 db ff ff       	call   f0100fb1 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033df:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01033e6:	77 20                	ja     f0103408 <mem_init+0x1aea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033e8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01033ec:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f01033f3:	f0 
f01033f4:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f01033fb:	00 
f01033fc:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103403:	e8 95 cc ff ff       	call   f010009d <_panic>
		// cprintf("check_va2pa(pgdir, base + KSTKGAP + i): %x\n", 
			// check_va2pa(pgdir, base + KSTKGAP + i));

		// cprintf("PADDR(percpu_kstacks[n]) + i: %x\n", 
		//	PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103408:	bb 00 00 00 00       	mov    $0x0,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010340d:	8d 8f 00 80 00 00    	lea    0x8000(%edi),%ecx
f0103413:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103416:	89 7d c8             	mov    %edi,-0x38(%ebp)
f0103419:	8b 7d cc             	mov    -0x34(%ebp),%edi
			// check_va2pa(pgdir, base + KSTKGAP + i));

		// cprintf("PADDR(percpu_kstacks[n]) + i: %x\n", 
		//	PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010341c:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f010341f:	39 c2                	cmp    %eax,%edx
f0103421:	74 24                	je     f0103447 <mem_init+0x1b29>
f0103423:	c7 44 24 0c 60 80 10 	movl   $0xf0108060,0xc(%esp)
f010342a:	f0 
f010342b:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0103432:	f0 
f0103433:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f010343a:	00 
f010343b:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103442:	e8 56 cc ff ff       	call   f010009d <_panic>
		// cprintf("check_va2pa(pgdir, base + KSTKGAP + i): %x\n", 
			// check_va2pa(pgdir, base + KSTKGAP + i));

		// cprintf("PADDR(percpu_kstacks[n]) + i: %x\n", 
		//	PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103447:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010344d:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0103453:	0f 85 53 05 00 00    	jne    f01039ac <mem_init+0x208e>
f0103459:	8b 7d c8             	mov    -0x38(%ebp),%edi
f010345c:	66 bb 00 00          	mov    $0x0,%bx
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0103460:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0103463:	89 f0                	mov    %esi,%eax
f0103465:	e8 47 db ff ff       	call   f0100fb1 <check_va2pa>
f010346a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010346d:	74 24                	je     f0103493 <mem_init+0x1b75>
f010346f:	c7 44 24 0c a8 80 10 	movl   $0xf01080a8,0xc(%esp)
f0103476:	f0 
f0103477:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010347e:	f0 
f010347f:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f0103486:	00 
f0103487:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010348e:	e8 0a cc ff ff       	call   f010009d <_panic>
		// cprintf("PADDR(percpu_kstacks[n]) + i: %x\n", 
		//	PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0103493:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103499:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f010349f:	75 bf                	jne    f0103460 <mem_init+0x1b42>
f01034a1:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f01034a8:	81 ef 00 00 01 00    	sub    $0x10000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01034ae:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f01034b4:	0f 85 0a ff ff ff    	jne    f01033c4 <mem_init+0x1aa6>
f01034ba:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01034bf:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01034c5:	83 fa 04             	cmp    $0x4,%edx
f01034c8:	77 2e                	ja     f01034f8 <mem_init+0x1bda>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f01034ca:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f01034ce:	0f 85 aa 00 00 00    	jne    f010357e <mem_init+0x1c60>
f01034d4:	c7 44 24 0c 98 78 10 	movl   $0xf0107898,0xc(%esp)
f01034db:	f0 
f01034dc:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01034e3:	f0 
f01034e4:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f01034eb:	00 
f01034ec:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01034f3:	e8 a5 cb ff ff       	call   f010009d <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01034f8:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01034fd:	76 55                	jbe    f0103554 <mem_init+0x1c36>
				assert(pgdir[i] & PTE_P);
f01034ff:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0103502:	f6 c2 01             	test   $0x1,%dl
f0103505:	75 24                	jne    f010352b <mem_init+0x1c0d>
f0103507:	c7 44 24 0c 98 78 10 	movl   $0xf0107898,0xc(%esp)
f010350e:	f0 
f010350f:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0103516:	f0 
f0103517:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f010351e:	00 
f010351f:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103526:	e8 72 cb ff ff       	call   f010009d <_panic>
				assert(pgdir[i] & PTE_W);
f010352b:	f6 c2 02             	test   $0x2,%dl
f010352e:	75 4e                	jne    f010357e <mem_init+0x1c60>
f0103530:	c7 44 24 0c a9 78 10 	movl   $0xf01078a9,0xc(%esp)
f0103537:	f0 
f0103538:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010353f:	f0 
f0103540:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0103547:	00 
f0103548:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010354f:	e8 49 cb ff ff       	call   f010009d <_panic>
			} else
				assert(pgdir[i] == 0);
f0103554:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0103558:	74 24                	je     f010357e <mem_init+0x1c60>
f010355a:	c7 44 24 0c ba 78 10 	movl   $0xf01078ba,0xc(%esp)
f0103561:	f0 
f0103562:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0103569:	f0 
f010356a:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0103571:	00 
f0103572:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103579:	e8 1f cb ff ff       	call   f010009d <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010357e:	83 c0 01             	add    $0x1,%eax
f0103581:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103586:	0f 85 33 ff ff ff    	jne    f01034bf <mem_init+0x1ba1>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010358c:	c7 04 24 cc 80 10 f0 	movl   $0xf01080cc,(%esp)
f0103593:	e8 86 0e 00 00       	call   f010441e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103598:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010359d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035a2:	77 20                	ja     f01035c4 <mem_init+0x1ca6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035a8:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f01035af:	f0 
f01035b0:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
f01035b7:	00 
f01035b8:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01035bf:	e8 d9 ca ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f01035c4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01035c9:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01035cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01035d1:	e8 7e da ff ff       	call   f0101054 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01035d6:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01035d9:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01035de:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01035e1:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01035e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035eb:	e8 d8 de ff ff       	call   f01014c8 <page_alloc>
f01035f0:	89 c6                	mov    %eax,%esi
f01035f2:	85 c0                	test   %eax,%eax
f01035f4:	75 24                	jne    f010361a <mem_init+0x1cfc>
f01035f6:	c7 44 24 0c 4b 76 10 	movl   $0xf010764b,0xc(%esp)
f01035fd:	f0 
f01035fe:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0103605:	f0 
f0103606:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f010360d:	00 
f010360e:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103615:	e8 83 ca ff ff       	call   f010009d <_panic>
	assert((pp1 = page_alloc(0)));
f010361a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103621:	e8 a2 de ff ff       	call   f01014c8 <page_alloc>
f0103626:	89 c7                	mov    %eax,%edi
f0103628:	85 c0                	test   %eax,%eax
f010362a:	75 24                	jne    f0103650 <mem_init+0x1d32>
f010362c:	c7 44 24 0c 61 76 10 	movl   $0xf0107661,0xc(%esp)
f0103633:	f0 
f0103634:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010363b:	f0 
f010363c:	c7 44 24 04 55 04 00 	movl   $0x455,0x4(%esp)
f0103643:	00 
f0103644:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010364b:	e8 4d ca ff ff       	call   f010009d <_panic>
	assert((pp2 = page_alloc(0)));
f0103650:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103657:	e8 6c de ff ff       	call   f01014c8 <page_alloc>
f010365c:	89 c3                	mov    %eax,%ebx
f010365e:	85 c0                	test   %eax,%eax
f0103660:	75 24                	jne    f0103686 <mem_init+0x1d68>
f0103662:	c7 44 24 0c 77 76 10 	movl   $0xf0107677,0xc(%esp)
f0103669:	f0 
f010366a:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0103671:	f0 
f0103672:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f0103679:	00 
f010367a:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103681:	e8 17 ca ff ff       	call   f010009d <_panic>
	page_free(pp0);
f0103686:	89 34 24             	mov    %esi,(%esp)
f0103689:	e8 da de ff ff       	call   f0101568 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010368e:	89 f8                	mov    %edi,%eax
f0103690:	2b 05 98 5e 22 f0    	sub    0xf0225e98,%eax
f0103696:	c1 f8 03             	sar    $0x3,%eax
f0103699:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010369c:	89 c2                	mov    %eax,%edx
f010369e:	c1 ea 0c             	shr    $0xc,%edx
f01036a1:	3b 15 90 5e 22 f0    	cmp    0xf0225e90,%edx
f01036a7:	72 20                	jb     f01036c9 <mem_init+0x1dab>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01036a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036ad:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f01036b4:	f0 
f01036b5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01036bc:	00 
f01036bd:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f01036c4:	e8 d4 c9 ff ff       	call   f010009d <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01036c9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01036d0:	00 
f01036d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01036d8:	00 
	return (void *)(pa + KERNBASE);
f01036d9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01036de:	89 04 24             	mov    %eax,(%esp)
f01036e1:	e8 cb 27 00 00       	call   f0105eb1 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01036e6:	89 d8                	mov    %ebx,%eax
f01036e8:	2b 05 98 5e 22 f0    	sub    0xf0225e98,%eax
f01036ee:	c1 f8 03             	sar    $0x3,%eax
f01036f1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01036f4:	89 c2                	mov    %eax,%edx
f01036f6:	c1 ea 0c             	shr    $0xc,%edx
f01036f9:	3b 15 90 5e 22 f0    	cmp    0xf0225e90,%edx
f01036ff:	72 20                	jb     f0103721 <mem_init+0x1e03>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103701:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103705:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f010370c:	f0 
f010370d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103714:	00 
f0103715:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f010371c:	e8 7c c9 ff ff       	call   f010009d <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103721:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103728:	00 
f0103729:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103730:	00 
	return (void *)(pa + KERNBASE);
f0103731:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103736:	89 04 24             	mov    %eax,(%esp)
f0103739:	e8 73 27 00 00       	call   f0105eb1 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010373e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103745:	00 
f0103746:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010374d:	00 
f010374e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103752:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f0103757:	89 04 24             	mov    %eax,(%esp)
f010375a:	e8 ca e0 ff ff       	call   f0101829 <page_insert>
	assert(pp1->pp_ref == 1);
f010375f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103764:	74 24                	je     f010378a <mem_init+0x1e6c>
f0103766:	c7 44 24 0c 58 77 10 	movl   $0xf0107758,0xc(%esp)
f010376d:	f0 
f010376e:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0103775:	f0 
f0103776:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f010377d:	00 
f010377e:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103785:	e8 13 c9 ff ff       	call   f010009d <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010378a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103791:	01 01 01 
f0103794:	74 24                	je     f01037ba <mem_init+0x1e9c>
f0103796:	c7 44 24 0c ec 80 10 	movl   $0xf01080ec,0xc(%esp)
f010379d:	f0 
f010379e:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01037a5:	f0 
f01037a6:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f01037ad:	00 
f01037ae:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01037b5:	e8 e3 c8 ff ff       	call   f010009d <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01037ba:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01037c1:	00 
f01037c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037c9:	00 
f01037ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01037ce:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f01037d3:	89 04 24             	mov    %eax,(%esp)
f01037d6:	e8 4e e0 ff ff       	call   f0101829 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01037db:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01037e2:	02 02 02 
f01037e5:	74 24                	je     f010380b <mem_init+0x1eed>
f01037e7:	c7 44 24 0c 10 81 10 	movl   $0xf0108110,0xc(%esp)
f01037ee:	f0 
f01037ef:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01037f6:	f0 
f01037f7:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f01037fe:	00 
f01037ff:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103806:	e8 92 c8 ff ff       	call   f010009d <_panic>
	assert(pp2->pp_ref == 1);
f010380b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103810:	74 24                	je     f0103836 <mem_init+0x1f18>
f0103812:	c7 44 24 0c 7a 77 10 	movl   $0xf010777a,0xc(%esp)
f0103819:	f0 
f010381a:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0103821:	f0 
f0103822:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f0103829:	00 
f010382a:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103831:	e8 67 c8 ff ff       	call   f010009d <_panic>
	assert(pp1->pp_ref == 0);
f0103836:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010383b:	74 24                	je     f0103861 <mem_init+0x1f43>
f010383d:	c7 44 24 0c ef 77 10 	movl   $0xf01077ef,0xc(%esp)
f0103844:	f0 
f0103845:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010384c:	f0 
f010384d:	c7 44 24 04 60 04 00 	movl   $0x460,0x4(%esp)
f0103854:	00 
f0103855:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f010385c:	e8 3c c8 ff ff       	call   f010009d <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103861:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103868:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010386b:	89 d8                	mov    %ebx,%eax
f010386d:	2b 05 98 5e 22 f0    	sub    0xf0225e98,%eax
f0103873:	c1 f8 03             	sar    $0x3,%eax
f0103876:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103879:	89 c2                	mov    %eax,%edx
f010387b:	c1 ea 0c             	shr    $0xc,%edx
f010387e:	3b 15 90 5e 22 f0    	cmp    0xf0225e90,%edx
f0103884:	72 20                	jb     f01038a6 <mem_init+0x1f88>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103886:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010388a:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0103891:	f0 
f0103892:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103899:	00 
f010389a:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f01038a1:	e8 f7 c7 ff ff       	call   f010009d <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01038a6:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01038ad:	03 03 03 
f01038b0:	74 24                	je     f01038d6 <mem_init+0x1fb8>
f01038b2:	c7 44 24 0c 34 81 10 	movl   $0xf0108134,0xc(%esp)
f01038b9:	f0 
f01038ba:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f01038c1:	f0 
f01038c2:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f01038c9:	00 
f01038ca:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f01038d1:	e8 c7 c7 ff ff       	call   f010009d <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01038d6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01038dd:	00 
f01038de:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f01038e3:	89 04 24             	mov    %eax,(%esp)
f01038e6:	e8 e6 de ff ff       	call   f01017d1 <page_remove>
	assert(pp2->pp_ref == 0);
f01038eb:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01038f0:	74 24                	je     f0103916 <mem_init+0x1ff8>
f01038f2:	c7 44 24 0c de 77 10 	movl   $0xf01077de,0xc(%esp)
f01038f9:	f0 
f01038fa:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0103901:	f0 
f0103902:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f0103909:	00 
f010390a:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103911:	e8 87 c7 ff ff       	call   f010009d <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103916:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
f010391b:	8b 08                	mov    (%eax),%ecx
f010391d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103923:	89 f2                	mov    %esi,%edx
f0103925:	2b 15 98 5e 22 f0    	sub    0xf0225e98,%edx
f010392b:	c1 fa 03             	sar    $0x3,%edx
f010392e:	c1 e2 0c             	shl    $0xc,%edx
f0103931:	39 d1                	cmp    %edx,%ecx
f0103933:	74 24                	je     f0103959 <mem_init+0x203b>
f0103935:	c7 44 24 0c f4 7a 10 	movl   $0xf0107af4,0xc(%esp)
f010393c:	f0 
f010393d:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0103944:	f0 
f0103945:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f010394c:	00 
f010394d:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103954:	e8 44 c7 ff ff       	call   f010009d <_panic>
	kern_pgdir[0] = 0;
f0103959:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010395f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103964:	74 24                	je     f010398a <mem_init+0x206c>
f0103966:	c7 44 24 0c 69 77 10 	movl   $0xf0107769,0xc(%esp)
f010396d:	f0 
f010396e:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0103975:	f0 
f0103976:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f010397d:	00 
f010397e:	c7 04 24 98 74 10 f0 	movl   $0xf0107498,(%esp)
f0103985:	e8 13 c7 ff ff       	call   f010009d <_panic>
	pp0->pp_ref = 0;
f010398a:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103990:	89 34 24             	mov    %esi,(%esp)
f0103993:	e8 d0 db ff ff       	call   f0101568 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103998:	c7 04 24 60 81 10 f0 	movl   $0xf0108160,(%esp)
f010399f:	e8 7a 0a 00 00       	call   f010441e <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01039a4:	83 c4 3c             	add    $0x3c,%esp
f01039a7:	5b                   	pop    %ebx
f01039a8:	5e                   	pop    %esi
f01039a9:	5f                   	pop    %edi
f01039aa:	5d                   	pop    %ebp
f01039ab:	c3                   	ret    
			// check_va2pa(pgdir, base + KSTKGAP + i));

		// cprintf("PADDR(percpu_kstacks[n]) + i: %x\n", 
		//	PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01039ac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01039af:	01 da                	add    %ebx,%edx
f01039b1:	89 f0                	mov    %esi,%eax
f01039b3:	e8 f9 d5 ff ff       	call   f0100fb1 <check_va2pa>
f01039b8:	e9 5f fa ff ff       	jmp    f010341c <mem_init+0x1afe>

f01039bd <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01039bd:	55                   	push   %ebp
f01039be:	89 e5                	mov    %esp,%ebp
f01039c0:	57                   	push   %edi
f01039c1:	56                   	push   %esi
f01039c2:	53                   	push   %ebx
f01039c3:	83 ec 2c             	sub    $0x2c,%esp
f01039c6:	8b 75 08             	mov    0x8(%ebp),%esi
f01039c9:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
	// cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f01039cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01039cf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f01039d5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039d8:	03 45 10             	add    0x10(%ebp),%eax
f01039db:	05 ff 0f 00 00       	add    $0xfff,%eax
f01039e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01039e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
			return -E_FAULT;
		}
	}
	// cprintf("user_mem_check success va: %x, len: %x\n", va, len);
	return 0;
f01039e8:	b8 00 00 00 00       	mov    $0x0,%eax
	// LAB 3: Your code here.
	// cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f01039ed:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01039f0:	73 53                	jae    f0103a45 <user_mem_check+0x88>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f01039f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01039f9:	00 
f01039fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01039fe:	8b 46 60             	mov    0x60(%esi),%eax
f0103a01:	89 04 24             	mov    %eax,(%esp)
f0103a04:	e8 bd db ff ff       	call   f01015c6 <pgdir_walk>
		// pprint(pte);
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0103a09:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103a0f:	77 10                	ja     f0103a21 <user_mem_check+0x64>
f0103a11:	85 c0                	test   %eax,%eax
f0103a13:	74 0c                	je     f0103a21 <user_mem_check+0x64>
f0103a15:	8b 00                	mov    (%eax),%eax
f0103a17:	a8 01                	test   $0x1,%al
f0103a19:	74 06                	je     f0103a21 <user_mem_check+0x64>
f0103a1b:	21 f8                	and    %edi,%eax
f0103a1d:	39 c7                	cmp    %eax,%edi
f0103a1f:	74 14                	je     f0103a35 <user_mem_check+0x78>
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f0103a21:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103a24:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0103a28:	89 1d 2c 52 22 f0    	mov    %ebx,0xf022522c
			return -E_FAULT;
f0103a2e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103a33:	eb 10                	jmp    f0103a45 <user_mem_check+0x88>
	// LAB 3: Your code here.
	// cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0103a35:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103a3b:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0103a3e:	77 b2                	ja     f01039f2 <user_mem_check+0x35>
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
			return -E_FAULT;
		}
	}
	// cprintf("user_mem_check success va: %x, len: %x\n", va, len);
	return 0;
f0103a40:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103a45:	83 c4 2c             	add    $0x2c,%esp
f0103a48:	5b                   	pop    %ebx
f0103a49:	5e                   	pop    %esi
f0103a4a:	5f                   	pop    %edi
f0103a4b:	5d                   	pop    %ebp
f0103a4c:	c3                   	ret    

f0103a4d <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103a4d:	55                   	push   %ebp
f0103a4e:	89 e5                	mov    %esp,%ebp
f0103a50:	53                   	push   %ebx
f0103a51:	83 ec 14             	sub    $0x14,%esp
f0103a54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103a57:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a5a:	83 c8 04             	or     $0x4,%eax
f0103a5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a61:	8b 45 10             	mov    0x10(%ebp),%eax
f0103a64:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a68:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a6f:	89 1c 24             	mov    %ebx,(%esp)
f0103a72:	e8 46 ff ff ff       	call   f01039bd <user_mem_check>
f0103a77:	85 c0                	test   %eax,%eax
f0103a79:	79 24                	jns    f0103a9f <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103a7b:	a1 2c 52 22 f0       	mov    0xf022522c,%eax
f0103a80:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a84:	8b 43 48             	mov    0x48(%ebx),%eax
f0103a87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a8b:	c7 04 24 8c 81 10 f0 	movl   $0xf010818c,(%esp)
f0103a92:	e8 87 09 00 00       	call   f010441e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103a97:	89 1c 24             	mov    %ebx,(%esp)
f0103a9a:	e8 b9 06 00 00       	call   f0104158 <env_destroy>
	}
}
f0103a9f:	83 c4 14             	add    $0x14,%esp
f0103aa2:	5b                   	pop    %ebx
f0103aa3:	5d                   	pop    %ebp
f0103aa4:	c3                   	ret    
f0103aa5:	00 00                	add    %al,(%eax)
	...

f0103aa8 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103aa8:	55                   	push   %ebp
f0103aa9:	89 e5                	mov    %esp,%ebp
f0103aab:	57                   	push   %edi
f0103aac:	56                   	push   %esi
f0103aad:	53                   	push   %ebx
f0103aae:	83 ec 1c             	sub    $0x1c,%esp
f0103ab1:	89 c6                	mov    %eax,%esi
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
f0103ab3:	89 d3                	mov    %edx,%ebx
f0103ab5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103abb:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0103ac2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (; begin < end; begin += PGSIZE) {
f0103ac8:	39 fb                	cmp    %edi,%ebx
f0103aca:	73 51                	jae    f0103b1d <region_alloc+0x75>
		struct PageInfo *pg = page_alloc(0);
f0103acc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103ad3:	e8 f0 d9 ff ff       	call   f01014c8 <page_alloc>
		if (!pg) panic("region_alloc failed!");
f0103ad8:	85 c0                	test   %eax,%eax
f0103ada:	75 1c                	jne    f0103af8 <region_alloc+0x50>
f0103adc:	c7 44 24 08 c1 81 10 	movl   $0xf01081c1,0x8(%esp)
f0103ae3:	f0 
f0103ae4:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
f0103aeb:	00 
f0103aec:	c7 04 24 d6 81 10 f0 	movl   $0xf01081d6,(%esp)
f0103af3:	e8 a5 c5 ff ff       	call   f010009d <_panic>
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
f0103af8:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103aff:	00 
f0103b00:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103b04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b08:	8b 46 60             	mov    0x60(%esi),%eax
f0103b0b:	89 04 24             	mov    %eax,(%esp)
f0103b0e:	e8 16 dd ff ff       	call   f0101829 <page_insert>
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
	for (; begin < end; begin += PGSIZE) {
f0103b13:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103b19:	39 df                	cmp    %ebx,%edi
f0103b1b:	77 af                	ja     f0103acc <region_alloc+0x24>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0103b1d:	83 c4 1c             	add    $0x1c,%esp
f0103b20:	5b                   	pop    %ebx
f0103b21:	5e                   	pop    %esi
f0103b22:	5f                   	pop    %edi
f0103b23:	5d                   	pop    %ebp
f0103b24:	c3                   	ret    

f0103b25 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103b25:	55                   	push   %ebp
f0103b26:	89 e5                	mov    %esp,%ebp
f0103b28:	83 ec 18             	sub    $0x18,%esp
f0103b2b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103b2e:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103b31:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103b34:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b37:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103b3a:	0f b6 55 10          	movzbl 0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103b3e:	85 c0                	test   %eax,%eax
f0103b40:	75 17                	jne    f0103b59 <envid2env+0x34>
		*env_store = curenv;
f0103b42:	e8 fd 29 00 00       	call   f0106544 <cpunum>
f0103b47:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b4a:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0103b50:	89 06                	mov    %eax,(%esi)
		return 0;
f0103b52:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b57:	eb 67                	jmp    f0103bc0 <envid2env+0x9b>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103b59:	89 c3                	mov    %eax,%ebx
f0103b5b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103b61:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103b64:	03 1d 3c 52 22 f0    	add    0xf022523c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103b6a:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103b6e:	74 05                	je     f0103b75 <envid2env+0x50>
f0103b70:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103b73:	74 0d                	je     f0103b82 <envid2env+0x5d>
		*env_store = 0;
f0103b75:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103b7b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103b80:	eb 3e                	jmp    f0103bc0 <envid2env+0x9b>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103b82:	84 d2                	test   %dl,%dl
f0103b84:	74 33                	je     f0103bb9 <envid2env+0x94>
f0103b86:	e8 b9 29 00 00       	call   f0106544 <cpunum>
f0103b8b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b8e:	39 98 28 60 22 f0    	cmp    %ebx,-0xfdd9fd8(%eax)
f0103b94:	74 23                	je     f0103bb9 <envid2env+0x94>
f0103b96:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103b99:	e8 a6 29 00 00       	call   f0106544 <cpunum>
f0103b9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ba1:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0103ba7:	3b 78 48             	cmp    0x48(%eax),%edi
f0103baa:	74 0d                	je     f0103bb9 <envid2env+0x94>
		*env_store = 0;
f0103bac:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103bb2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103bb7:	eb 07                	jmp    f0103bc0 <envid2env+0x9b>
	}

	*env_store = e;
f0103bb9:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0103bbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103bc0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103bc3:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103bc6:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103bc9:	89 ec                	mov    %ebp,%esp
f0103bcb:	5d                   	pop    %ebp
f0103bcc:	c3                   	ret    

f0103bcd <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103bcd:	55                   	push   %ebp
f0103bce:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103bd0:	b8 88 23 12 f0       	mov    $0xf0122388,%eax
f0103bd5:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103bd8:	b8 23 00 00 00       	mov    $0x23,%eax
f0103bdd:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103bdf:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103be1:	b0 10                	mov    $0x10,%al
f0103be3:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103be5:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103be7:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103be9:	ea f0 3b 10 f0 08 00 	ljmp   $0x8,$0xf0103bf0
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103bf0:	b0 00                	mov    $0x0,%al
f0103bf2:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103bf5:	5d                   	pop    %ebp
f0103bf6:	c3                   	ret    

f0103bf7 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103bf7:	55                   	push   %ebp
f0103bf8:	89 e5                	mov    %esp,%ebp
f0103bfa:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
		envs[i].env_id = 0;
f0103bfb:	8b 1d 3c 52 22 f0    	mov    0xf022523c,%ebx
f0103c01:	8b 0d 40 52 22 f0    	mov    0xf0225240,%ecx
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103c07:	8d 83 84 ef 01 00    	lea    0x1ef84(%ebx),%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
f0103c0d:	ba ff 03 00 00       	mov    $0x3ff,%edx
		envs[i].env_id = 0;
f0103c12:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103c19:	89 48 44             	mov    %ecx,0x44(%eax)
f0103c1c:	89 c1                	mov    %eax,%ecx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
f0103c1e:	83 ea 01             	sub    $0x1,%edx
f0103c21:	83 e8 7c             	sub    $0x7c,%eax
f0103c24:	83 fa ff             	cmp    $0xffffffff,%edx
f0103c27:	75 e9                	jne    f0103c12 <env_init+0x1b>
f0103c29:	89 1d 40 52 22 f0    	mov    %ebx,0xf0225240
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = envs+i;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0103c2f:	e8 99 ff ff ff       	call   f0103bcd <env_init_percpu>
}
f0103c34:	5b                   	pop    %ebx
f0103c35:	5d                   	pop    %ebp
f0103c36:	c3                   	ret    

f0103c37 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103c37:	55                   	push   %ebp
f0103c38:	89 e5                	mov    %esp,%ebp
f0103c3a:	53                   	push   %ebx
f0103c3b:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103c3e:	8b 1d 40 52 22 f0    	mov    0xf0225240,%ebx
f0103c44:	85 db                	test   %ebx,%ebx
f0103c46:	0f 84 b4 01 00 00    	je     f0103e00 <env_alloc+0x1c9>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103c4c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103c53:	e8 70 d8 ff ff       	call   f01014c8 <page_alloc>
f0103c58:	85 c0                	test   %eax,%eax
f0103c5a:	0f 84 a7 01 00 00    	je     f0103e07 <env_alloc+0x1d0>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0103c60:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103c65:	2b 05 98 5e 22 f0    	sub    0xf0225e98,%eax
f0103c6b:	c1 f8 03             	sar    $0x3,%eax
f0103c6e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c71:	89 c2                	mov    %eax,%edx
f0103c73:	c1 ea 0c             	shr    $0xc,%edx
f0103c76:	3b 15 90 5e 22 f0    	cmp    0xf0225e90,%edx
f0103c7c:	72 20                	jb     f0103c9e <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103c7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c82:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0103c89:	f0 
f0103c8a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103c91:	00 
f0103c92:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f0103c99:	e8 ff c3 ff ff       	call   f010009d <_panic>
	return (void *)(pa + KERNBASE);
f0103c9e:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *) page2kva(p);
f0103ca3:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103ca6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103cad:	00 
f0103cae:	8b 15 94 5e 22 f0    	mov    0xf0225e94,%edx
f0103cb4:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103cb8:	89 04 24             	mov    %eax,(%esp)
f0103cbb:	e8 cb 22 00 00       	call   f0105f8b <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103cc0:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103cc3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103cc8:	77 20                	ja     f0103cea <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103cca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103cce:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f0103cd5:	f0 
f0103cd6:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
f0103cdd:	00 
f0103cde:	c7 04 24 d6 81 10 f0 	movl   $0xf01081d6,(%esp)
f0103ce5:	e8 b3 c3 ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103cea:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103cf0:	83 ca 05             	or     $0x5,%edx
f0103cf3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103cf9:	8b 43 48             	mov    0x48(%ebx),%eax
f0103cfc:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103d01:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103d06:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103d0b:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103d0e:	8b 15 3c 52 22 f0    	mov    0xf022523c,%edx
f0103d14:	89 d9                	mov    %ebx,%ecx
f0103d16:	29 d1                	sub    %edx,%ecx
f0103d18:	c1 f9 02             	sar    $0x2,%ecx
f0103d1b:	69 c9 df 7b ef bd    	imul   $0xbdef7bdf,%ecx,%ecx
f0103d21:	09 c8                	or     %ecx,%eax
f0103d23:	89 43 48             	mov    %eax,0x48(%ebx)
	cprintf("envs: %x, e: %x, e->env_id: %x\n", envs, e, e->env_id);
f0103d26:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d2a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103d2e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d32:	c7 04 24 34 82 10 f0 	movl   $0xf0108234,(%esp)
f0103d39:	e8 e0 06 00 00       	call   f010441e <cprintf>

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103d3e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d41:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103d44:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103d4b:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103d52:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103d59:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103d60:	00 
f0103d61:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103d68:	00 
f0103d69:	89 1c 24             	mov    %ebx,(%esp)
f0103d6c:	e8 40 21 00 00       	call   f0105eb1 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103d71:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103d77:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103d7d:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103d83:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103d8a:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103d90:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103d97:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103d9b:	8b 43 44             	mov    0x44(%ebx),%eax
f0103d9e:	a3 40 52 22 f0       	mov    %eax,0xf0225240
	*newenv_store = e;
f0103da3:	8b 45 08             	mov    0x8(%ebp),%eax
f0103da6:	89 18                	mov    %ebx,(%eax)

	cprintf("env_id, %x\n", e->env_id);
f0103da8:	8b 43 48             	mov    0x48(%ebx),%eax
f0103dab:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103daf:	c7 04 24 e1 81 10 f0 	movl   $0xf01081e1,(%esp)
f0103db6:	e8 63 06 00 00       	call   f010441e <cprintf>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103dbb:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103dbe:	e8 81 27 00 00       	call   f0106544 <cpunum>
f0103dc3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dc6:	ba 00 00 00 00       	mov    $0x0,%edx
f0103dcb:	83 b8 28 60 22 f0 00 	cmpl   $0x0,-0xfdd9fd8(%eax)
f0103dd2:	74 11                	je     f0103de5 <env_alloc+0x1ae>
f0103dd4:	e8 6b 27 00 00       	call   f0106544 <cpunum>
f0103dd9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ddc:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0103de2:	8b 50 48             	mov    0x48(%eax),%edx
f0103de5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103de9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103ded:	c7 04 24 ed 81 10 f0 	movl   $0xf01081ed,(%esp)
f0103df4:	e8 25 06 00 00       	call   f010441e <cprintf>
	return 0;
f0103df9:	b8 00 00 00 00       	mov    $0x0,%eax
f0103dfe:	eb 0c                	jmp    f0103e0c <env_alloc+0x1d5>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103e00:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103e05:	eb 05                	jmp    f0103e0c <env_alloc+0x1d5>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103e07:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	*newenv_store = e;

	cprintf("env_id, %x\n", e->env_id);
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103e0c:	83 c4 14             	add    $0x14,%esp
f0103e0f:	5b                   	pop    %ebx
f0103e10:	5d                   	pop    %ebp
f0103e11:	c3                   	ret    

f0103e12 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103e12:	55                   	push   %ebp
f0103e13:	89 e5                	mov    %esp,%ebp
f0103e15:	57                   	push   %edi
f0103e16:	56                   	push   %esi
f0103e17:	53                   	push   %ebx
f0103e18:	83 ec 3c             	sub    $0x3c,%esp
f0103e1b:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *penv;
	env_alloc(&penv, 0);
f0103e1e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103e25:	00 
f0103e26:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103e29:	89 04 24             	mov    %eax,(%esp)
f0103e2c:	e8 06 fe ff ff       	call   f0103c37 <env_alloc>
	load_icode(penv, binary, size);
f0103e31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103e34:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Elf *ELFHDR = (struct Elf *) binary;
	struct Proghdr *ph, *eph;

	if (ELFHDR->e_magic != ELF_MAGIC)
f0103e37:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103e3d:	74 1c                	je     f0103e5b <env_create+0x49>
		panic("Not executable!");
f0103e3f:	c7 44 24 08 02 82 10 	movl   $0xf0108202,0x8(%esp)
f0103e46:	f0 
f0103e47:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
f0103e4e:	00 
f0103e4f:	c7 04 24 d6 81 10 f0 	movl   $0xf01081d6,(%esp)
f0103e56:	e8 42 c2 ff ff       	call   f010009d <_panic>
	
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0103e5b:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0103e5e:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
	//  The ph->p_filesz bytes from the ELF binary, starting at
	//  'binary + ph->p_offset', should be copied to virtual address
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
f0103e62:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103e65:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e68:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e6d:	77 20                	ja     f0103e8f <env_create+0x7d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e73:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f0103e7a:	f0 
f0103e7b:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
f0103e82:	00 
f0103e83:	c7 04 24 d6 81 10 f0 	movl   $0xf01081d6,(%esp)
f0103e8a:	e8 0e c2 ff ff       	call   f010009d <_panic>
	struct Proghdr *ph, *eph;

	if (ELFHDR->e_magic != ELF_MAGIC)
		panic("Not executable!");
	
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0103e8f:	8d 1c 1f             	lea    (%edi,%ebx,1),%ebx
	eph = ph + ELFHDR->e_phnum;
f0103e92:	0f b7 f6             	movzwl %si,%esi
f0103e95:	c1 e6 05             	shl    $0x5,%esi
f0103e98:	8d 34 33             	lea    (%ebx,%esi,1),%esi
	return (physaddr_t)kva - KERNBASE;
f0103e9b:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103ea0:	0f 22 d8             	mov    %eax,%cr3
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
	//it's silly to use kern_pgdir here.
	for (; ph < eph; ph++)
f0103ea3:	39 f3                	cmp    %esi,%ebx
f0103ea5:	73 4f                	jae    f0103ef6 <env_create+0xe4>
		if (ph->p_type == ELF_PROG_LOAD) {
f0103ea7:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103eaa:	75 43                	jne    f0103eef <env_create+0xdd>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103eac:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103eaf:	8b 53 08             	mov    0x8(%ebx),%edx
f0103eb2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103eb5:	e8 ee fb ff ff       	call   f0103aa8 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0103eba:	8b 43 14             	mov    0x14(%ebx),%eax
f0103ebd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ec1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103ec8:	00 
f0103ec9:	8b 43 08             	mov    0x8(%ebx),%eax
f0103ecc:	89 04 24             	mov    %eax,(%esp)
f0103ecf:	e8 dd 1f 00 00       	call   f0105eb1 <memset>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0103ed4:	8b 43 10             	mov    0x10(%ebx),%eax
f0103ed7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103edb:	89 f8                	mov    %edi,%eax
f0103edd:	03 43 04             	add    0x4(%ebx),%eax
f0103ee0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ee4:	8b 43 08             	mov    0x8(%ebx),%eax
f0103ee7:	89 04 24             	mov    %eax,(%esp)
f0103eea:	e8 9c 20 00 00       	call   f0105f8b <memcpy>
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
	//it's silly to use kern_pgdir here.
	for (; ph < eph; ph++)
f0103eef:	83 c3 20             	add    $0x20,%ebx
f0103ef2:	39 de                	cmp    %ebx,%esi
f0103ef4:	77 b1                	ja     f0103ea7 <env_create+0x95>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
			//but I'm curious about how exactly p_memsz and p_filesz differs
			// cprintf("p_memsz: %x, p_filesz: %x\n", ph->p_memsz, ph->p_filesz);
		}
	//we can use this because kern_pgdir is a subset of e->env_pgdir
	lcr3(PADDR(kern_pgdir));
f0103ef6:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103efb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f00:	77 20                	ja     f0103f22 <env_create+0x110>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f02:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f06:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f0103f0d:	f0 
f0103f0e:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f0103f15:	00 
f0103f16:	c7 04 24 d6 81 10 f0 	movl   $0xf01081d6,(%esp)
f0103f1d:	e8 7b c1 ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103f22:	05 00 00 00 10       	add    $0x10000000,%eax
f0103f27:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0103f2a:	8b 47 18             	mov    0x18(%edi),%eax
f0103f2d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103f30:	89 42 30             	mov    %eax,0x30(%edx)
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0103f33:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103f38:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103f3d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103f40:	e8 63 fb ff ff       	call   f0103aa8 <region_alloc>
{
	// LAB 3: Your code here.
	struct Env *penv;
	env_alloc(&penv, 0);
	load_icode(penv, binary, size);
}
f0103f45:	83 c4 3c             	add    $0x3c,%esp
f0103f48:	5b                   	pop    %ebx
f0103f49:	5e                   	pop    %esi
f0103f4a:	5f                   	pop    %edi
f0103f4b:	5d                   	pop    %ebp
f0103f4c:	c3                   	ret    

f0103f4d <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103f4d:	55                   	push   %ebp
f0103f4e:	89 e5                	mov    %esp,%ebp
f0103f50:	57                   	push   %edi
f0103f51:	56                   	push   %esi
f0103f52:	53                   	push   %ebx
f0103f53:	83 ec 2c             	sub    $0x2c,%esp
f0103f56:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103f59:	e8 e6 25 00 00       	call   f0106544 <cpunum>
f0103f5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f61:	39 b8 28 60 22 f0    	cmp    %edi,-0xfdd9fd8(%eax)
f0103f67:	75 34                	jne    f0103f9d <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103f69:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f6e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f73:	77 20                	ja     f0103f95 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f75:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f79:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f0103f80:	f0 
f0103f81:	c7 44 24 04 9b 01 00 	movl   $0x19b,0x4(%esp)
f0103f88:	00 
f0103f89:	c7 04 24 d6 81 10 f0 	movl   $0xf01081d6,(%esp)
f0103f90:	e8 08 c1 ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103f95:	05 00 00 00 10       	add    $0x10000000,%eax
f0103f9a:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103f9d:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103fa0:	e8 9f 25 00 00       	call   f0106544 <cpunum>
f0103fa5:	6b d0 74             	imul   $0x74,%eax,%edx
f0103fa8:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fad:	83 ba 28 60 22 f0 00 	cmpl   $0x0,-0xfdd9fd8(%edx)
f0103fb4:	74 11                	je     f0103fc7 <env_free+0x7a>
f0103fb6:	e8 89 25 00 00       	call   f0106544 <cpunum>
f0103fbb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fbe:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0103fc4:	8b 40 48             	mov    0x48(%eax),%eax
f0103fc7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103fcb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fcf:	c7 04 24 12 82 10 f0 	movl   $0xf0108212,(%esp)
f0103fd6:	e8 43 04 00 00       	call   f010441e <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103fdb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103fe2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103fe5:	c1 e0 02             	shl    $0x2,%eax
f0103fe8:	89 45 d8             	mov    %eax,-0x28(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103feb:	8b 47 60             	mov    0x60(%edi),%eax
f0103fee:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103ff1:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103ff4:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103ffa:	0f 84 bc 00 00 00    	je     f01040bc <env_free+0x16f>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0104000:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104006:	89 f0                	mov    %esi,%eax
f0104008:	c1 e8 0c             	shr    $0xc,%eax
f010400b:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010400e:	3b 05 90 5e 22 f0    	cmp    0xf0225e90,%eax
f0104014:	72 20                	jb     f0104036 <env_free+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104016:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010401a:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0104021:	f0 
f0104022:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
f0104029:	00 
f010402a:	c7 04 24 d6 81 10 f0 	movl   $0xf01081d6,(%esp)
f0104031:	e8 67 c0 ff ff       	call   f010009d <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104036:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104039:	c1 e2 16             	shl    $0x16,%edx
f010403c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010403f:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0104044:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010404b:	01 
f010404c:	74 17                	je     f0104065 <env_free+0x118>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010404e:	89 d8                	mov    %ebx,%eax
f0104050:	c1 e0 0c             	shl    $0xc,%eax
f0104053:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0104056:	89 44 24 04          	mov    %eax,0x4(%esp)
f010405a:	8b 47 60             	mov    0x60(%edi),%eax
f010405d:	89 04 24             	mov    %eax,(%esp)
f0104060:	e8 6c d7 ff ff       	call   f01017d1 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104065:	83 c3 01             	add    $0x1,%ebx
f0104068:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010406e:	75 d4                	jne    f0104044 <env_free+0xf7>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0104070:	8b 47 60             	mov    0x60(%edi),%eax
f0104073:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104076:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010407d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104080:	3b 05 90 5e 22 f0    	cmp    0xf0225e90,%eax
f0104086:	72 1c                	jb     f01040a4 <env_free+0x157>
		panic("pa2page called with invalid pa");
f0104088:	c7 44 24 08 c0 79 10 	movl   $0xf01079c0,0x8(%esp)
f010408f:	f0 
f0104090:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0104097:	00 
f0104098:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f010409f:	e8 f9 bf ff ff       	call   f010009d <_panic>
	return &pages[PGNUM(pa)];
f01040a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01040a7:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f01040ae:	03 05 98 5e 22 f0    	add    0xf0225e98,%eax
		page_decref(pa2page(pa));
f01040b4:	89 04 24             	mov    %eax,(%esp)
f01040b7:	e8 e7 d4 ff ff       	call   f01015a3 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01040bc:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01040c0:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01040c7:	0f 85 15 ff ff ff    	jne    f0103fe2 <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01040cd:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01040d0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01040d5:	77 20                	ja     f01040f7 <env_free+0x1aa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01040d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040db:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f01040e2:	f0 
f01040e3:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
f01040ea:	00 
f01040eb:	c7 04 24 d6 81 10 f0 	movl   $0xf01081d6,(%esp)
f01040f2:	e8 a6 bf ff ff       	call   f010009d <_panic>
	e->env_pgdir = 0;
f01040f7:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01040fe:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104103:	c1 e8 0c             	shr    $0xc,%eax
f0104106:	3b 05 90 5e 22 f0    	cmp    0xf0225e90,%eax
f010410c:	72 1c                	jb     f010412a <env_free+0x1dd>
		panic("pa2page called with invalid pa");
f010410e:	c7 44 24 08 c0 79 10 	movl   $0xf01079c0,0x8(%esp)
f0104115:	f0 
f0104116:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010411d:	00 
f010411e:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f0104125:	e8 73 bf ff ff       	call   f010009d <_panic>
	return &pages[PGNUM(pa)];
f010412a:	c1 e0 03             	shl    $0x3,%eax
f010412d:	03 05 98 5e 22 f0    	add    0xf0225e98,%eax
	page_decref(pa2page(pa));
f0104133:	89 04 24             	mov    %eax,(%esp)
f0104136:	e8 68 d4 ff ff       	call   f01015a3 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010413b:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0104142:	a1 40 52 22 f0       	mov    0xf0225240,%eax
f0104147:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010414a:	89 3d 40 52 22 f0    	mov    %edi,0xf0225240
}
f0104150:	83 c4 2c             	add    $0x2c,%esp
f0104153:	5b                   	pop    %ebx
f0104154:	5e                   	pop    %esi
f0104155:	5f                   	pop    %edi
f0104156:	5d                   	pop    %ebp
f0104157:	c3                   	ret    

f0104158 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0104158:	55                   	push   %ebp
f0104159:	89 e5                	mov    %esp,%ebp
f010415b:	53                   	push   %ebx
f010415c:	83 ec 14             	sub    $0x14,%esp
f010415f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0104162:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0104166:	75 19                	jne    f0104181 <env_destroy+0x29>
f0104168:	e8 d7 23 00 00       	call   f0106544 <cpunum>
f010416d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104170:	39 98 28 60 22 f0    	cmp    %ebx,-0xfdd9fd8(%eax)
f0104176:	74 09                	je     f0104181 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0104178:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010417f:	eb 2f                	jmp    f01041b0 <env_destroy+0x58>
	}

	env_free(e);
f0104181:	89 1c 24             	mov    %ebx,(%esp)
f0104184:	e8 c4 fd ff ff       	call   f0103f4d <env_free>

	if (curenv == e) {
f0104189:	e8 b6 23 00 00       	call   f0106544 <cpunum>
f010418e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104191:	39 98 28 60 22 f0    	cmp    %ebx,-0xfdd9fd8(%eax)
f0104197:	75 17                	jne    f01041b0 <env_destroy+0x58>
		curenv = NULL;
f0104199:	e8 a6 23 00 00       	call   f0106544 <cpunum>
f010419e:	6b c0 74             	imul   $0x74,%eax,%eax
f01041a1:	c7 80 28 60 22 f0 00 	movl   $0x0,-0xfdd9fd8(%eax)
f01041a8:	00 00 00 
		sched_yield();
f01041ab:	e8 06 0b 00 00       	call   f0104cb6 <sched_yield>
	}
}
f01041b0:	83 c4 14             	add    $0x14,%esp
f01041b3:	5b                   	pop    %ebx
f01041b4:	5d                   	pop    %ebp
f01041b5:	c3                   	ret    

f01041b6 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01041b6:	55                   	push   %ebp
f01041b7:	89 e5                	mov    %esp,%ebp
f01041b9:	53                   	push   %ebx
f01041ba:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01041bd:	e8 82 23 00 00       	call   f0106544 <cpunum>
f01041c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01041c5:	8b 98 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%ebx
f01041cb:	e8 74 23 00 00       	call   f0106544 <cpunum>
f01041d0:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f01041d3:	8b 65 08             	mov    0x8(%ebp),%esp
f01041d6:	61                   	popa   
f01041d7:	07                   	pop    %es
f01041d8:	1f                   	pop    %ds
f01041d9:	83 c4 08             	add    $0x8,%esp
f01041dc:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01041dd:	c7 44 24 08 28 82 10 	movl   $0xf0108228,0x8(%esp)
f01041e4:	f0 
f01041e5:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
f01041ec:	00 
f01041ed:	c7 04 24 d6 81 10 f0 	movl   $0xf01081d6,(%esp)
f01041f4:	e8 a4 be ff ff       	call   f010009d <_panic>

f01041f9 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01041f9:	55                   	push   %ebp
f01041fa:	89 e5                	mov    %esp,%ebp
f01041fc:	53                   	push   %ebx
f01041fd:	83 ec 14             	sub    $0x14,%esp
f0104200:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// cprintf("curenv: %x, e: %x\n", curenv, e);
	// cprintf("\n");
	if (curenv != e) {
f0104203:	e8 3c 23 00 00       	call   f0106544 <cpunum>
f0104208:	6b c0 74             	imul   $0x74,%eax,%eax
f010420b:	39 98 28 60 22 f0    	cmp    %ebx,-0xfdd9fd8(%eax)
f0104211:	0f 84 85 00 00 00    	je     f010429c <env_run+0xa3>
		if (curenv && curenv->env_status == ENV_RUNNING)
f0104217:	e8 28 23 00 00       	call   f0106544 <cpunum>
f010421c:	6b c0 74             	imul   $0x74,%eax,%eax
f010421f:	83 b8 28 60 22 f0 00 	cmpl   $0x0,-0xfdd9fd8(%eax)
f0104226:	74 29                	je     f0104251 <env_run+0x58>
f0104228:	e8 17 23 00 00       	call   f0106544 <cpunum>
f010422d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104230:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104236:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010423a:	75 15                	jne    f0104251 <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f010423c:	e8 03 23 00 00       	call   f0106544 <cpunum>
f0104241:	6b c0 74             	imul   $0x74,%eax,%eax
f0104244:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f010424a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv = e;
f0104251:	e8 ee 22 00 00       	call   f0106544 <cpunum>
f0104256:	6b c0 74             	imul   $0x74,%eax,%eax
f0104259:	89 98 28 60 22 f0    	mov    %ebx,-0xfdd9fd8(%eax)
		e->env_status = ENV_RUNNING;
f010425f:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		e->env_runs++;
f0104266:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		lcr3(PADDR(e->env_pgdir));
f010426a:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010426d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104272:	77 20                	ja     f0104294 <env_run+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104274:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104278:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f010427f:	f0 
f0104280:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
f0104287:	00 
f0104288:	c7 04 24 d6 81 10 f0 	movl   $0xf01081d6,(%esp)
f010428f:	e8 09 be ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104294:	05 00 00 00 10       	add    $0x10000000,%eax
f0104299:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010429c:	c7 04 24 60 24 12 f0 	movl   $0xf0122460,(%esp)
f01042a3:	e8 13 26 00 00       	call   f01068bb <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01042a8:	f3 90                	pause  
	}
	unlock_kernel();
	env_pop_tf(&e->env_tf);
f01042aa:	89 1c 24             	mov    %ebx,(%esp)
f01042ad:	e8 04 ff ff ff       	call   f01041b6 <env_pop_tf>
	...

f01042b4 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01042b4:	55                   	push   %ebp
f01042b5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01042b7:	ba 70 00 00 00       	mov    $0x70,%edx
f01042bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01042bf:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01042c0:	b2 71                	mov    $0x71,%dl
f01042c2:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01042c3:	0f b6 c0             	movzbl %al,%eax
}
f01042c6:	5d                   	pop    %ebp
f01042c7:	c3                   	ret    

f01042c8 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01042c8:	55                   	push   %ebp
f01042c9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01042cb:	ba 70 00 00 00       	mov    $0x70,%edx
f01042d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01042d3:	ee                   	out    %al,(%dx)
f01042d4:	b2 71                	mov    $0x71,%dl
f01042d6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042d9:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01042da:	5d                   	pop    %ebp
f01042db:	c3                   	ret    

f01042dc <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01042dc:	55                   	push   %ebp
f01042dd:	89 e5                	mov    %esp,%ebp
f01042df:	56                   	push   %esi
f01042e0:	53                   	push   %ebx
f01042e1:	83 ec 10             	sub    $0x10,%esp
f01042e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01042e7:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01042e9:	66 a3 90 23 12 f0    	mov    %ax,0xf0122390
	if (!didinit)
f01042ef:	80 3d 44 52 22 f0 00 	cmpb   $0x0,0xf0225244
f01042f6:	74 4e                	je     f0104346 <irq_setmask_8259A+0x6a>
f01042f8:	ba 21 00 00 00       	mov    $0x21,%edx
f01042fd:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f01042fe:	89 f0                	mov    %esi,%eax
f0104300:	66 c1 e8 08          	shr    $0x8,%ax
f0104304:	b2 a1                	mov    $0xa1,%dl
f0104306:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0104307:	c7 04 24 54 82 10 f0 	movl   $0xf0108254,(%esp)
f010430e:	e8 0b 01 00 00       	call   f010441e <cprintf>
	for (i = 0; i < 16; i++)
f0104313:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0104318:	0f b7 f6             	movzwl %si,%esi
f010431b:	f7 d6                	not    %esi
f010431d:	0f a3 de             	bt     %ebx,%esi
f0104320:	73 10                	jae    f0104332 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f0104322:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104326:	c7 04 24 af 87 10 f0 	movl   $0xf01087af,(%esp)
f010432d:	e8 ec 00 00 00       	call   f010441e <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0104332:	83 c3 01             	add    $0x1,%ebx
f0104335:	83 fb 10             	cmp    $0x10,%ebx
f0104338:	75 e3                	jne    f010431d <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010433a:	c7 04 24 e9 6c 10 f0 	movl   $0xf0106ce9,(%esp)
f0104341:	e8 d8 00 00 00       	call   f010441e <cprintf>
}
f0104346:	83 c4 10             	add    $0x10,%esp
f0104349:	5b                   	pop    %ebx
f010434a:	5e                   	pop    %esi
f010434b:	5d                   	pop    %ebp
f010434c:	c3                   	ret    

f010434d <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010434d:	55                   	push   %ebp
f010434e:	89 e5                	mov    %esp,%ebp
f0104350:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0104353:	c6 05 44 52 22 f0 01 	movb   $0x1,0xf0225244
f010435a:	ba 21 00 00 00       	mov    $0x21,%edx
f010435f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104364:	ee                   	out    %al,(%dx)
f0104365:	b2 a1                	mov    $0xa1,%dl
f0104367:	ee                   	out    %al,(%dx)
f0104368:	b2 20                	mov    $0x20,%dl
f010436a:	b8 11 00 00 00       	mov    $0x11,%eax
f010436f:	ee                   	out    %al,(%dx)
f0104370:	b2 21                	mov    $0x21,%dl
f0104372:	b8 20 00 00 00       	mov    $0x20,%eax
f0104377:	ee                   	out    %al,(%dx)
f0104378:	b8 04 00 00 00       	mov    $0x4,%eax
f010437d:	ee                   	out    %al,(%dx)
f010437e:	b8 03 00 00 00       	mov    $0x3,%eax
f0104383:	ee                   	out    %al,(%dx)
f0104384:	b2 a0                	mov    $0xa0,%dl
f0104386:	b8 11 00 00 00       	mov    $0x11,%eax
f010438b:	ee                   	out    %al,(%dx)
f010438c:	b2 a1                	mov    $0xa1,%dl
f010438e:	b8 28 00 00 00       	mov    $0x28,%eax
f0104393:	ee                   	out    %al,(%dx)
f0104394:	b8 02 00 00 00       	mov    $0x2,%eax
f0104399:	ee                   	out    %al,(%dx)
f010439a:	b8 01 00 00 00       	mov    $0x1,%eax
f010439f:	ee                   	out    %al,(%dx)
f01043a0:	b2 20                	mov    $0x20,%dl
f01043a2:	b8 68 00 00 00       	mov    $0x68,%eax
f01043a7:	ee                   	out    %al,(%dx)
f01043a8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01043ad:	ee                   	out    %al,(%dx)
f01043ae:	b2 a0                	mov    $0xa0,%dl
f01043b0:	b8 68 00 00 00       	mov    $0x68,%eax
f01043b5:	ee                   	out    %al,(%dx)
f01043b6:	b8 0a 00 00 00       	mov    $0xa,%eax
f01043bb:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01043bc:	0f b7 05 90 23 12 f0 	movzwl 0xf0122390,%eax
f01043c3:	66 83 f8 ff          	cmp    $0xffff,%ax
f01043c7:	74 0b                	je     f01043d4 <pic_init+0x87>
		irq_setmask_8259A(irq_mask_8259A);
f01043c9:	0f b7 c0             	movzwl %ax,%eax
f01043cc:	89 04 24             	mov    %eax,(%esp)
f01043cf:	e8 08 ff ff ff       	call   f01042dc <irq_setmask_8259A>
}
f01043d4:	c9                   	leave  
f01043d5:	c3                   	ret    
	...

f01043d8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01043d8:	55                   	push   %ebp
f01043d9:	89 e5                	mov    %esp,%ebp
f01043db:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01043de:	8b 45 08             	mov    0x8(%ebp),%eax
f01043e1:	89 04 24             	mov    %eax,(%esp)
f01043e4:	e8 e1 c4 ff ff       	call   f01008ca <cputchar>
	*cnt++;
}
f01043e9:	c9                   	leave  
f01043ea:	c3                   	ret    

f01043eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01043eb:	55                   	push   %ebp
f01043ec:	89 e5                	mov    %esp,%ebp
f01043ee:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01043f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01043f8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01043ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0104402:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104406:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104409:	89 44 24 04          	mov    %eax,0x4(%esp)
f010440d:	c7 04 24 d8 43 10 f0 	movl   $0xf01043d8,(%esp)
f0104414:	e8 d8 13 00 00       	call   f01057f1 <vprintfmt>
	return cnt;
}
f0104419:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010441c:	c9                   	leave  
f010441d:	c3                   	ret    

f010441e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010441e:	55                   	push   %ebp
f010441f:	89 e5                	mov    %esp,%ebp
f0104421:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104424:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0104427:	89 44 24 04          	mov    %eax,0x4(%esp)
f010442b:	8b 45 08             	mov    0x8(%ebp),%eax
f010442e:	89 04 24             	mov    %eax,(%esp)
f0104431:	e8 b5 ff ff ff       	call   f01043eb <vcprintf>
	va_end(ap);

	return cnt;
}
f0104436:	c9                   	leave  
f0104437:	c3                   	ret    
	...

f0104440 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104440:	55                   	push   %ebp
f0104441:	89 e5                	mov    %esp,%ebp
f0104443:	83 ec 18             	sub    $0x18,%esp
f0104446:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104449:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010444c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int cid = thiscpu->cpu_id;
f010444f:	e8 f0 20 00 00       	call   f0106544 <cpunum>
f0104454:	6b c0 74             	imul   $0x74,%eax,%eax
f0104457:	0f b6 98 20 60 22 f0 	movzbl -0xfdd9fe0(%eax),%ebx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f010445e:	e8 e1 20 00 00       	call   f0106544 <cpunum>
f0104463:	6b c0 74             	imul   $0x74,%eax,%eax
f0104466:	89 da                	mov    %ebx,%edx
f0104468:	f7 da                	neg    %edx
f010446a:	c1 e2 10             	shl    $0x10,%edx
f010446d:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0104473:	89 90 30 60 22 f0    	mov    %edx,-0xfdd9fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104479:	e8 c6 20 00 00       	call   f0106544 <cpunum>
f010447e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104481:	66 c7 80 34 60 22 f0 	movw   $0x10,-0xfdd9fcc(%eax)
f0104488:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+cid] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f010448a:	83 c3 05             	add    $0x5,%ebx
f010448d:	e8 b2 20 00 00       	call   f0106544 <cpunum>
f0104492:	89 c6                	mov    %eax,%esi
f0104494:	e8 ab 20 00 00       	call   f0106544 <cpunum>
f0104499:	89 c7                	mov    %eax,%edi
f010449b:	e8 a4 20 00 00       	call   f0106544 <cpunum>
f01044a0:	66 c7 04 dd 20 23 12 	movw   $0x68,-0xfeddce0(,%ebx,8)
f01044a7:	f0 68 00 
f01044aa:	6b f6 74             	imul   $0x74,%esi,%esi
f01044ad:	81 c6 2c 60 22 f0    	add    $0xf022602c,%esi
f01044b3:	66 89 34 dd 22 23 12 	mov    %si,-0xfeddcde(,%ebx,8)
f01044ba:	f0 
f01044bb:	6b d7 74             	imul   $0x74,%edi,%edx
f01044be:	81 c2 2c 60 22 f0    	add    $0xf022602c,%edx
f01044c4:	c1 ea 10             	shr    $0x10,%edx
f01044c7:	88 14 dd 24 23 12 f0 	mov    %dl,-0xfeddcdc(,%ebx,8)
f01044ce:	c6 04 dd 26 23 12 f0 	movb   $0x40,-0xfeddcda(,%ebx,8)
f01044d5:	40 
f01044d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01044d9:	05 2c 60 22 f0       	add    $0xf022602c,%eax
f01044de:	c1 e8 18             	shr    $0x18,%eax
f01044e1:	88 04 dd 27 23 12 f0 	mov    %al,-0xfeddcd9(,%ebx,8)
					sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3)+cid].sd_s = 0;
f01044e8:	c6 04 dd 25 23 12 f0 	movb   $0x89,-0xfeddcdb(,%ebx,8)
f01044ef:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+8*cid);
f01044f0:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01044f3:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01044f6:	b8 94 23 12 f0       	mov    $0xf0122394,%eax
f01044fb:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f01044fe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104501:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104504:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104507:	89 ec                	mov    %ebp,%esp
f0104509:	5d                   	pop    %ebp
f010450a:	c3                   	ret    

f010450b <trap_init>:



void
trap_init(void)
{
f010450b:	55                   	push   %ebp
f010450c:	89 e5                	mov    %esp,%ebp
f010450e:	53                   	push   %ebx
f010450f:	83 ec 14             	sub    $0x14,%esp
	// SETGATE(idt[14], 0, GD_KT, th14, 0);
	// SETGATE(idt[16], 0, GD_KT, th16, 0);

	// Challenge:
	extern void (*funs[])();
	cprintf("funs %x\n", funs);
f0104512:	c7 44 24 04 9c 23 12 	movl   $0xf012239c,0x4(%esp)
f0104519:	f0 
f010451a:	c7 04 24 68 82 10 f0 	movl   $0xf0108268,(%esp)
f0104521:	e8 f8 fe ff ff       	call   f010441e <cprintf>
	cprintf("funs[0] %x\n", funs[0]);
f0104526:	a1 9c 23 12 f0       	mov    0xf012239c,%eax
f010452b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010452f:	c7 04 24 71 82 10 f0 	movl   $0xf0108271,(%esp)
f0104536:	e8 e3 fe ff ff       	call   f010441e <cprintf>
	cprintf("funs[48] %x\n", funs[48]);
f010453b:	a1 5c 24 12 f0       	mov    0xf012245c,%eax
f0104540:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104544:	c7 04 24 7d 82 10 f0 	movl   $0xf010827d,(%esp)
f010454b:	e8 ce fe ff ff       	call   f010441e <cprintf>
f0104550:	b9 01 00 00 00       	mov    $0x1,%ecx
f0104555:	b8 00 00 00 00       	mov    $0x0,%eax
f010455a:	eb 06                	jmp    f0104562 <trap_init+0x57>
f010455c:	83 c0 01             	add    $0x1,%eax
f010455f:	83 c1 01             	add    $0x1,%ecx
	int i;
	for (i = 0; i <= 16; ++i)
		if (i==T_BRKPT)
f0104562:	83 f8 03             	cmp    $0x3,%eax
f0104565:	75 30                	jne    f0104597 <trap_init+0x8c>
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
f0104567:	8b 15 a8 23 12 f0    	mov    0xf01223a8,%edx
f010456d:	66 89 15 78 52 22 f0 	mov    %dx,0xf0225278
f0104574:	66 c7 05 7a 52 22 f0 	movw   $0x8,0xf022527a
f010457b:	08 00 
f010457d:	c6 05 7c 52 22 f0 00 	movb   $0x0,0xf022527c
f0104584:	c6 05 7d 52 22 f0 ee 	movb   $0xee,0xf022527d
f010458b:	c1 ea 10             	shr    $0x10,%edx
f010458e:	66 89 15 7e 52 22 f0 	mov    %dx,0xf022527e
f0104595:	eb c5                	jmp    f010455c <trap_init+0x51>
		else if (i!=2 && i!=15) {
f0104597:	83 f8 02             	cmp    $0x2,%eax
f010459a:	74 39                	je     f01045d5 <trap_init+0xca>
f010459c:	83 f8 0f             	cmp    $0xf,%eax
f010459f:	74 34                	je     f01045d5 <trap_init+0xca>
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
f01045a1:	8b 1c 85 9c 23 12 f0 	mov    -0xfeddc64(,%eax,4),%ebx
f01045a8:	66 89 1c c5 60 52 22 	mov    %bx,-0xfddada0(,%eax,8)
f01045af:	f0 
f01045b0:	66 c7 04 c5 62 52 22 	movw   $0x8,-0xfddad9e(,%eax,8)
f01045b7:	f0 08 00 
f01045ba:	c6 04 c5 64 52 22 f0 	movb   $0x0,-0xfddad9c(,%eax,8)
f01045c1:	00 
f01045c2:	c6 04 c5 65 52 22 f0 	movb   $0x8e,-0xfddad9b(,%eax,8)
f01045c9:	8e 
f01045ca:	c1 eb 10             	shr    $0x10,%ebx
f01045cd:	66 89 1c c5 66 52 22 	mov    %bx,-0xfddad9a(,%eax,8)
f01045d4:	f0 
	extern void (*funs[])();
	cprintf("funs %x\n", funs);
	cprintf("funs[0] %x\n", funs[0]);
	cprintf("funs[48] %x\n", funs[48]);
	int i;
	for (i = 0; i <= 16; ++i)
f01045d5:	83 f9 10             	cmp    $0x10,%ecx
f01045d8:	7e 82                	jle    f010455c <trap_init+0x51>
		if (i==T_BRKPT)
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
		else if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	SETGATE(idt[48], 0, GD_KT, funs[48], 3);
f01045da:	a1 5c 24 12 f0       	mov    0xf012245c,%eax
f01045df:	66 a3 e0 53 22 f0    	mov    %ax,0xf02253e0
f01045e5:	66 c7 05 e2 53 22 f0 	movw   $0x8,0xf02253e2
f01045ec:	08 00 
f01045ee:	c6 05 e4 53 22 f0 00 	movb   $0x0,0xf02253e4
f01045f5:	c6 05 e5 53 22 f0 ee 	movb   $0xee,0xf02253e5
f01045fc:	c1 e8 10             	shr    $0x10,%eax
f01045ff:	66 a3 e6 53 22 f0    	mov    %ax,0xf02253e6
	// Per-CPU setup 
	trap_init_percpu();
f0104605:	e8 36 fe ff ff       	call   f0104440 <trap_init_percpu>
}
f010460a:	83 c4 14             	add    $0x14,%esp
f010460d:	5b                   	pop    %ebx
f010460e:	5d                   	pop    %ebp
f010460f:	c3                   	ret    

f0104610 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104610:	55                   	push   %ebp
f0104611:	89 e5                	mov    %esp,%ebp
f0104613:	53                   	push   %ebx
f0104614:	83 ec 14             	sub    $0x14,%esp
f0104617:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010461a:	8b 03                	mov    (%ebx),%eax
f010461c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104620:	c7 04 24 8a 82 10 f0 	movl   $0xf010828a,(%esp)
f0104627:	e8 f2 fd ff ff       	call   f010441e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010462c:	8b 43 04             	mov    0x4(%ebx),%eax
f010462f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104633:	c7 04 24 99 82 10 f0 	movl   $0xf0108299,(%esp)
f010463a:	e8 df fd ff ff       	call   f010441e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010463f:	8b 43 08             	mov    0x8(%ebx),%eax
f0104642:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104646:	c7 04 24 a8 82 10 f0 	movl   $0xf01082a8,(%esp)
f010464d:	e8 cc fd ff ff       	call   f010441e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104652:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104655:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104659:	c7 04 24 b7 82 10 f0 	movl   $0xf01082b7,(%esp)
f0104660:	e8 b9 fd ff ff       	call   f010441e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104665:	8b 43 10             	mov    0x10(%ebx),%eax
f0104668:	89 44 24 04          	mov    %eax,0x4(%esp)
f010466c:	c7 04 24 c6 82 10 f0 	movl   $0xf01082c6,(%esp)
f0104673:	e8 a6 fd ff ff       	call   f010441e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104678:	8b 43 14             	mov    0x14(%ebx),%eax
f010467b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010467f:	c7 04 24 d5 82 10 f0 	movl   $0xf01082d5,(%esp)
f0104686:	e8 93 fd ff ff       	call   f010441e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010468b:	8b 43 18             	mov    0x18(%ebx),%eax
f010468e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104692:	c7 04 24 e4 82 10 f0 	movl   $0xf01082e4,(%esp)
f0104699:	e8 80 fd ff ff       	call   f010441e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010469e:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01046a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046a5:	c7 04 24 f3 82 10 f0 	movl   $0xf01082f3,(%esp)
f01046ac:	e8 6d fd ff ff       	call   f010441e <cprintf>
}
f01046b1:	83 c4 14             	add    $0x14,%esp
f01046b4:	5b                   	pop    %ebx
f01046b5:	5d                   	pop    %ebp
f01046b6:	c3                   	ret    

f01046b7 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01046b7:	55                   	push   %ebp
f01046b8:	89 e5                	mov    %esp,%ebp
f01046ba:	56                   	push   %esi
f01046bb:	53                   	push   %ebx
f01046bc:	83 ec 10             	sub    $0x10,%esp
f01046bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01046c2:	e8 7d 1e 00 00       	call   f0106544 <cpunum>
f01046c7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01046cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01046cf:	c7 04 24 57 83 10 f0 	movl   $0xf0108357,(%esp)
f01046d6:	e8 43 fd ff ff       	call   f010441e <cprintf>
	print_regs(&tf->tf_regs);
f01046db:	89 1c 24             	mov    %ebx,(%esp)
f01046de:	e8 2d ff ff ff       	call   f0104610 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01046e3:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01046e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046eb:	c7 04 24 75 83 10 f0 	movl   $0xf0108375,(%esp)
f01046f2:	e8 27 fd ff ff       	call   f010441e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01046f7:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01046fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ff:	c7 04 24 88 83 10 f0 	movl   $0xf0108388,(%esp)
f0104706:	e8 13 fd ff ff       	call   f010441e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010470b:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010470e:	83 f8 13             	cmp    $0x13,%eax
f0104711:	77 09                	ja     f010471c <print_trapframe+0x65>
		return excnames[trapno];
f0104713:	8b 14 85 40 86 10 f0 	mov    -0xfef79c0(,%eax,4),%edx
f010471a:	eb 1d                	jmp    f0104739 <print_trapframe+0x82>
	if (trapno == T_SYSCALL)
		return "System call";
f010471c:	ba 02 83 10 f0       	mov    $0xf0108302,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f0104721:	83 f8 30             	cmp    $0x30,%eax
f0104724:	74 13                	je     f0104739 <print_trapframe+0x82>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104726:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104729:	83 fa 0f             	cmp    $0xf,%edx
f010472c:	ba 0e 83 10 f0       	mov    $0xf010830e,%edx
f0104731:	b9 21 83 10 f0       	mov    $0xf0108321,%ecx
f0104736:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104739:	89 54 24 08          	mov    %edx,0x8(%esp)
f010473d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104741:	c7 04 24 9b 83 10 f0 	movl   $0xf010839b,(%esp)
f0104748:	e8 d1 fc ff ff       	call   f010441e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010474d:	3b 1d 60 5a 22 f0    	cmp    0xf0225a60,%ebx
f0104753:	75 19                	jne    f010476e <print_trapframe+0xb7>
f0104755:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104759:	75 13                	jne    f010476e <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010475b:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010475e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104762:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0104769:	e8 b0 fc ff ff       	call   f010441e <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010476e:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104771:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104775:	c7 04 24 bc 83 10 f0 	movl   $0xf01083bc,(%esp)
f010477c:	e8 9d fc ff ff       	call   f010441e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104781:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104785:	75 51                	jne    f01047d8 <print_trapframe+0x121>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104787:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010478a:	89 c2                	mov    %eax,%edx
f010478c:	83 e2 01             	and    $0x1,%edx
f010478f:	ba 30 83 10 f0       	mov    $0xf0108330,%edx
f0104794:	b9 3b 83 10 f0       	mov    $0xf010833b,%ecx
f0104799:	0f 45 ca             	cmovne %edx,%ecx
f010479c:	89 c2                	mov    %eax,%edx
f010479e:	83 e2 02             	and    $0x2,%edx
f01047a1:	ba 47 83 10 f0       	mov    $0xf0108347,%edx
f01047a6:	be 4d 83 10 f0       	mov    $0xf010834d,%esi
f01047ab:	0f 44 d6             	cmove  %esi,%edx
f01047ae:	83 e0 04             	and    $0x4,%eax
f01047b1:	b8 52 83 10 f0       	mov    $0xf0108352,%eax
f01047b6:	be c1 84 10 f0       	mov    $0xf01084c1,%esi
f01047bb:	0f 44 c6             	cmove  %esi,%eax
f01047be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01047c2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01047c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047ca:	c7 04 24 ca 83 10 f0 	movl   $0xf01083ca,(%esp)
f01047d1:	e8 48 fc ff ff       	call   f010441e <cprintf>
f01047d6:	eb 0c                	jmp    f01047e4 <print_trapframe+0x12d>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01047d8:	c7 04 24 e9 6c 10 f0 	movl   $0xf0106ce9,(%esp)
f01047df:	e8 3a fc ff ff       	call   f010441e <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01047e4:	8b 43 30             	mov    0x30(%ebx),%eax
f01047e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047eb:	c7 04 24 d9 83 10 f0 	movl   $0xf01083d9,(%esp)
f01047f2:	e8 27 fc ff ff       	call   f010441e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01047f7:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01047fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047ff:	c7 04 24 e8 83 10 f0 	movl   $0xf01083e8,(%esp)
f0104806:	e8 13 fc ff ff       	call   f010441e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010480b:	8b 43 38             	mov    0x38(%ebx),%eax
f010480e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104812:	c7 04 24 fb 83 10 f0 	movl   $0xf01083fb,(%esp)
f0104819:	e8 00 fc ff ff       	call   f010441e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010481e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104822:	74 27                	je     f010484b <print_trapframe+0x194>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104824:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104827:	89 44 24 04          	mov    %eax,0x4(%esp)
f010482b:	c7 04 24 0a 84 10 f0 	movl   $0xf010840a,(%esp)
f0104832:	e8 e7 fb ff ff       	call   f010441e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104837:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010483b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010483f:	c7 04 24 19 84 10 f0 	movl   $0xf0108419,(%esp)
f0104846:	e8 d3 fb ff ff       	call   f010441e <cprintf>
	}
}
f010484b:	83 c4 10             	add    $0x10,%esp
f010484e:	5b                   	pop    %ebx
f010484f:	5e                   	pop    %esi
f0104850:	5d                   	pop    %ebp
f0104851:	c3                   	ret    

f0104852 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104852:	55                   	push   %ebp
f0104853:	89 e5                	mov    %esp,%ebp
f0104855:	83 ec 28             	sub    $0x28,%esp
f0104858:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010485b:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010485e:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104861:	8b 75 08             	mov    0x8(%ebp),%esi
f0104864:	0f 20 d3             	mov    %cr2,%ebx
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
	cprintf("fault_va: %x\n", fault_va);
f0104867:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010486b:	c7 04 24 2c 84 10 f0 	movl   $0xf010842c,(%esp)
f0104872:	e8 a7 fb ff ff       	call   f010441e <cprintf>

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs&3) == 0) {
f0104877:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f010487b:	75 1c                	jne    f0104899 <page_fault_handler+0x47>
		panic("Kernel page fault!");
f010487d:	c7 44 24 08 3a 84 10 	movl   $0xf010843a,0x8(%esp)
f0104884:	f0 
f0104885:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
f010488c:	00 
f010488d:	c7 04 24 4d 84 10 f0 	movl   $0xf010844d,(%esp)
f0104894:	e8 04 b8 ff ff       	call   f010009d <_panic>
	// the page fault happened in user mode.

	// Call the environment's page fault upcall, if one exists.  Set up a
	// page fault stack frame on the user exception stack (below
	// UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
	if (curenv->env_pgfault_upcall) {
f0104899:	e8 a6 1c 00 00       	call   f0106544 <cpunum>

		// LAB 4: Your code here.
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010489e:	8b 7e 30             	mov    0x30(%esi),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01048a1:	e8 9e 1c 00 00       	call   f0106544 <cpunum>

		// LAB 4: Your code here.
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01048a6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01048aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f01048ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01048b1:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax

		// LAB 4: Your code here.
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01048b7:	8b 40 48             	mov    0x48(%eax),%eax
f01048ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048be:	c7 04 24 0c 86 10 f0 	movl   $0xf010860c,(%esp)
f01048c5:	e8 54 fb ff ff       	call   f010441e <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01048ca:	89 34 24             	mov    %esi,(%esp)
f01048cd:	e8 e5 fd ff ff       	call   f01046b7 <print_trapframe>
	env_destroy(curenv);
f01048d2:	e8 6d 1c 00 00       	call   f0106544 <cpunum>
f01048d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01048da:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f01048e0:	89 04 24             	mov    %eax,(%esp)
f01048e3:	e8 70 f8 ff ff       	call   f0104158 <env_destroy>
}
f01048e8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01048eb:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01048ee:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01048f1:	89 ec                	mov    %ebp,%esp
f01048f3:	5d                   	pop    %ebp
f01048f4:	c3                   	ret    

f01048f5 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01048f5:	55                   	push   %ebp
f01048f6:	89 e5                	mov    %esp,%ebp
f01048f8:	57                   	push   %edi
f01048f9:	56                   	push   %esi
f01048fa:	83 ec 20             	sub    $0x20,%esp
f01048fd:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104900:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104901:	83 3d 80 5e 22 f0 00 	cmpl   $0x0,0xf0225e80
f0104908:	74 01                	je     f010490b <trap+0x16>
		asm volatile("hlt");
f010490a:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010490b:	e8 34 1c 00 00       	call   f0106544 <cpunum>
f0104910:	6b d0 74             	imul   $0x74,%eax,%edx
f0104913:	81 c2 20 60 22 f0    	add    $0xf0226020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104919:	b8 01 00 00 00       	mov    $0x1,%eax
f010491e:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104922:	83 f8 02             	cmp    $0x2,%eax
f0104925:	75 0c                	jne    f0104933 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104927:	c7 04 24 60 24 12 f0 	movl   $0xf0122460,(%esp)
f010492e:	e8 c5 1e 00 00       	call   f01067f8 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104933:	9c                   	pushf  
f0104934:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104935:	f6 c4 02             	test   $0x2,%ah
f0104938:	74 24                	je     f010495e <trap+0x69>
f010493a:	c7 44 24 0c 59 84 10 	movl   $0xf0108459,0xc(%esp)
f0104941:	f0 
f0104942:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f0104949:	f0 
f010494a:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
f0104951:	00 
f0104952:	c7 04 24 4d 84 10 f0 	movl   $0xf010844d,(%esp)
f0104959:	e8 3f b7 ff ff       	call   f010009d <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010495e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104962:	83 e0 03             	and    $0x3,%eax
f0104965:	83 f8 03             	cmp    $0x3,%eax
f0104968:	0f 85 a7 00 00 00    	jne    f0104a15 <trap+0x120>
f010496e:	c7 04 24 60 24 12 f0 	movl   $0xf0122460,(%esp)
f0104975:	e8 7e 1e 00 00       	call   f01067f8 <spin_lock>
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();

		assert(curenv);
f010497a:	e8 c5 1b 00 00       	call   f0106544 <cpunum>
f010497f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104982:	83 b8 28 60 22 f0 00 	cmpl   $0x0,-0xfdd9fd8(%eax)
f0104989:	75 24                	jne    f01049af <trap+0xba>
f010498b:	c7 44 24 0c 72 84 10 	movl   $0xf0108472,0xc(%esp)
f0104992:	f0 
f0104993:	c7 44 24 08 be 74 10 	movl   $0xf01074be,0x8(%esp)
f010499a:	f0 
f010499b:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f01049a2:	00 
f01049a3:	c7 04 24 4d 84 10 f0 	movl   $0xf010844d,(%esp)
f01049aa:	e8 ee b6 ff ff       	call   f010009d <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01049af:	e8 90 1b 00 00       	call   f0106544 <cpunum>
f01049b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b7:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f01049bd:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01049c1:	75 2d                	jne    f01049f0 <trap+0xfb>
			env_free(curenv);
f01049c3:	e8 7c 1b 00 00       	call   f0106544 <cpunum>
f01049c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01049cb:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f01049d1:	89 04 24             	mov    %eax,(%esp)
f01049d4:	e8 74 f5 ff ff       	call   f0103f4d <env_free>
			curenv = NULL;
f01049d9:	e8 66 1b 00 00       	call   f0106544 <cpunum>
f01049de:	6b c0 74             	imul   $0x74,%eax,%eax
f01049e1:	c7 80 28 60 22 f0 00 	movl   $0x0,-0xfdd9fd8(%eax)
f01049e8:	00 00 00 
			sched_yield();
f01049eb:	e8 c6 02 00 00       	call   f0104cb6 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01049f0:	e8 4f 1b 00 00       	call   f0106544 <cpunum>
f01049f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01049f8:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f01049fe:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104a03:	89 c7                	mov    %eax,%edi
f0104a05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104a07:	e8 38 1b 00 00       	call   f0106544 <cpunum>
f0104a0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a0f:	8b b0 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104a15:	89 35 60 5a 22 f0    	mov    %esi,0xf0225a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	if (tf->tf_trapno == T_PGFLT) {
f0104a1b:	8b 46 28             	mov    0x28(%esi),%eax
f0104a1e:	83 f8 0e             	cmp    $0xe,%eax
f0104a21:	75 19                	jne    f0104a3c <trap+0x147>
		cprintf("PAGE FAULT\n");
f0104a23:	c7 04 24 79 84 10 f0 	movl   $0xf0108479,(%esp)
f0104a2a:	e8 ef f9 ff ff       	call   f010441e <cprintf>
		page_fault_handler(tf);
f0104a2f:	89 34 24             	mov    %esi,(%esp)
f0104a32:	e8 1b fe ff ff       	call   f0104852 <page_fault_handler>
f0104a37:	e9 b4 00 00 00       	jmp    f0104af0 <trap+0x1fb>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f0104a3c:	83 f8 03             	cmp    $0x3,%eax
f0104a3f:	90                   	nop
f0104a40:	75 19                	jne    f0104a5b <trap+0x166>
		cprintf("BREAK POINT\n");
f0104a42:	c7 04 24 85 84 10 f0 	movl   $0xf0108485,(%esp)
f0104a49:	e8 d0 f9 ff ff       	call   f010441e <cprintf>
		monitor(tf);
f0104a4e:	89 34 24             	mov    %esi,(%esp)
f0104a51:	e8 dd c0 ff ff       	call   f0100b33 <monitor>
f0104a56:	e9 95 00 00 00       	jmp    f0104af0 <trap+0x1fb>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f0104a5b:	83 f8 30             	cmp    $0x30,%eax
f0104a5e:	66 90                	xchg   %ax,%ax
f0104a60:	75 32                	jne    f0104a94 <trap+0x19f>
		// cprintf("SYSTEM CALL\n");
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104a62:	8b 46 04             	mov    0x4(%esi),%eax
f0104a65:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104a69:	8b 06                	mov    (%esi),%eax
f0104a6b:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104a6f:	8b 46 10             	mov    0x10(%esi),%eax
f0104a72:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a76:	8b 46 18             	mov    0x18(%esi),%eax
f0104a79:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a7d:	8b 46 14             	mov    0x14(%esi),%eax
f0104a80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a84:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104a87:	89 04 24             	mov    %eax,(%esp)
f0104a8a:	e8 4a 03 00 00       	call   f0104dd9 <syscall>
		monitor(tf);
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
		// cprintf("SYSTEM CALL\n");
		tf->tf_regs.reg_eax = 
f0104a8f:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104a92:	eb 5c                	jmp    f0104af0 <trap+0x1fb>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104a94:	83 f8 27             	cmp    $0x27,%eax
f0104a97:	75 16                	jne    f0104aaf <trap+0x1ba>
		cprintf("Spurious interrupt on irq 7\n");
f0104a99:	c7 04 24 92 84 10 f0 	movl   $0xf0108492,(%esp)
f0104aa0:	e8 79 f9 ff ff       	call   f010441e <cprintf>
		print_trapframe(tf);
f0104aa5:	89 34 24             	mov    %esi,(%esp)
f0104aa8:	e8 0a fc ff ff       	call   f01046b7 <print_trapframe>
f0104aad:	eb 41                	jmp    f0104af0 <trap+0x1fb>
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.


	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104aaf:	89 34 24             	mov    %esi,(%esp)
f0104ab2:	e8 00 fc ff ff       	call   f01046b7 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104ab7:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104abc:	75 1c                	jne    f0104ada <trap+0x1e5>
		panic("unhandled trap in kernel");
f0104abe:	c7 44 24 08 af 84 10 	movl   $0xf01084af,0x8(%esp)
f0104ac5:	f0 
f0104ac6:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
f0104acd:	00 
f0104ace:	c7 04 24 4d 84 10 f0 	movl   $0xf010844d,(%esp)
f0104ad5:	e8 c3 b5 ff ff       	call   f010009d <_panic>
	else {
		env_destroy(curenv);
f0104ada:	e8 65 1a 00 00       	call   f0106544 <cpunum>
f0104adf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae2:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104ae8:	89 04 24             	mov    %eax,(%esp)
f0104aeb:	e8 68 f6 ff ff       	call   f0104158 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104af0:	e8 4f 1a 00 00       	call   f0106544 <cpunum>
f0104af5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104af8:	83 b8 28 60 22 f0 00 	cmpl   $0x0,-0xfdd9fd8(%eax)
f0104aff:	74 2a                	je     f0104b2b <trap+0x236>
f0104b01:	e8 3e 1a 00 00       	call   f0106544 <cpunum>
f0104b06:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b09:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104b0f:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104b13:	75 16                	jne    f0104b2b <trap+0x236>
		env_run(curenv);
f0104b15:	e8 2a 1a 00 00       	call   f0106544 <cpunum>
f0104b1a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b1d:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104b23:	89 04 24             	mov    %eax,(%esp)
f0104b26:	e8 ce f6 ff ff       	call   f01041f9 <env_run>
	else
		sched_yield();
f0104b2b:	e8 86 01 00 00       	call   f0104cb6 <sched_yield>

f0104b30 <th0>:
funs:
.text
/*
 * Challenge: my code here
 */
	noec(th0, 0)
f0104b30:	6a 00                	push   $0x0
f0104b32:	6a 00                	push   $0x0
f0104b34:	eb 4e                	jmp    f0104b84 <_alltraps>

f0104b36 <th1>:
	noec(th1, 1)
f0104b36:	6a 00                	push   $0x0
f0104b38:	6a 01                	push   $0x1
f0104b3a:	eb 48                	jmp    f0104b84 <_alltraps>

f0104b3c <th3>:
	zhanwei()
	noec(th3, 3)
f0104b3c:	6a 00                	push   $0x0
f0104b3e:	6a 03                	push   $0x3
f0104b40:	eb 42                	jmp    f0104b84 <_alltraps>

f0104b42 <th4>:
	noec(th4, 4)
f0104b42:	6a 00                	push   $0x0
f0104b44:	6a 04                	push   $0x4
f0104b46:	eb 3c                	jmp    f0104b84 <_alltraps>

f0104b48 <th5>:
	noec(th5, 5)
f0104b48:	6a 00                	push   $0x0
f0104b4a:	6a 05                	push   $0x5
f0104b4c:	eb 36                	jmp    f0104b84 <_alltraps>

f0104b4e <th6>:
	noec(th6, 6)
f0104b4e:	6a 00                	push   $0x0
f0104b50:	6a 06                	push   $0x6
f0104b52:	eb 30                	jmp    f0104b84 <_alltraps>

f0104b54 <th7>:
	noec(th7, 7)
f0104b54:	6a 00                	push   $0x0
f0104b56:	6a 07                	push   $0x7
f0104b58:	eb 2a                	jmp    f0104b84 <_alltraps>

f0104b5a <th8>:
	ec(th8, 8)
f0104b5a:	6a 08                	push   $0x8
f0104b5c:	eb 26                	jmp    f0104b84 <_alltraps>

f0104b5e <th9>:
	noec(th9, 9)
f0104b5e:	6a 00                	push   $0x0
f0104b60:	6a 09                	push   $0x9
f0104b62:	eb 20                	jmp    f0104b84 <_alltraps>

f0104b64 <th10>:
	ec(th10, 10)
f0104b64:	6a 0a                	push   $0xa
f0104b66:	eb 1c                	jmp    f0104b84 <_alltraps>

f0104b68 <th11>:
	ec(th11, 11)
f0104b68:	6a 0b                	push   $0xb
f0104b6a:	eb 18                	jmp    f0104b84 <_alltraps>

f0104b6c <th12>:
	ec(th12, 12)
f0104b6c:	6a 0c                	push   $0xc
f0104b6e:	eb 14                	jmp    f0104b84 <_alltraps>

f0104b70 <th13>:
	ec(th13, 13)
f0104b70:	6a 0d                	push   $0xd
f0104b72:	eb 10                	jmp    f0104b84 <_alltraps>

f0104b74 <th14>:
	ec(th14, 14)
f0104b74:	6a 0e                	push   $0xe
f0104b76:	eb 0c                	jmp    f0104b84 <_alltraps>

f0104b78 <th16>:
	zhanwei()
	noec(th16, 16)
f0104b78:	6a 00                	push   $0x0
f0104b7a:	6a 10                	push   $0x10
f0104b7c:	eb 06                	jmp    f0104b84 <_alltraps>

f0104b7e <th48>:
.data
	.space 124
.text
	noec(th48, 48)
f0104b7e:	6a 00                	push   $0x0
f0104b80:	6a 30                	push   $0x30
f0104b82:	eb 00                	jmp    f0104b84 <_alltraps>

f0104b84 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0104b84:	1e                   	push   %ds
	pushl %es
f0104b85:	06                   	push   %es
	pushal
f0104b86:	60                   	pusha  
	pushl $GD_KD
f0104b87:	6a 10                	push   $0x10
	popl %ds
f0104b89:	1f                   	pop    %ds
	pushl $GD_KD
f0104b8a:	6a 10                	push   $0x10
	popl %es
f0104b8c:	07                   	pop    %es
	pushl %esp
f0104b8d:	54                   	push   %esp
	call trap
f0104b8e:	e8 62 fd ff ff       	call   f01048f5 <trap>
	...

f0104b94 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104b94:	55                   	push   %ebp
f0104b95:	89 e5                	mov    %esp,%ebp
f0104b97:	53                   	push   %ebx
f0104b98:	83 ec 14             	sub    $0x14,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104b9b:	8b 15 3c 52 22 f0    	mov    0xf022523c,%edx
f0104ba1:	8b 5a 54             	mov    0x54(%edx),%ebx
f0104ba4:	8d 43 fe             	lea    -0x2(%ebx),%eax
f0104ba7:	83 f8 01             	cmp    $0x1,%eax
f0104baa:	76 7e                	jbe    f0104c2a <sched_halt+0x96>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104bac:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104bb1:	8b 8a d0 00 00 00    	mov    0xd0(%edx),%ecx
f0104bb7:	83 e9 02             	sub    $0x2,%ecx
f0104bba:	83 f9 01             	cmp    $0x1,%ecx
f0104bbd:	76 0f                	jbe    f0104bce <sched_halt+0x3a>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104bbf:	83 c0 01             	add    $0x1,%eax
f0104bc2:	83 c2 7c             	add    $0x7c,%edx
f0104bc5:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104bca:	75 e5                	jne    f0104bb1 <sched_halt+0x1d>
f0104bcc:	eb 07                	jmp    f0104bd5 <sched_halt+0x41>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0104bce:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104bd3:	75 55                	jne    f0104c2a <sched_halt+0x96>
		for (i = 0; i < 2; ++i)
			cprintf("envs[%x].env_status: %x\n", i, envs[i].env_status);
f0104bd5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104bd9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104be0:	00 
f0104be1:	c7 04 24 90 86 10 f0 	movl   $0xf0108690,(%esp)
f0104be8:	e8 31 f8 ff ff       	call   f010441e <cprintf>
f0104bed:	a1 3c 52 22 f0       	mov    0xf022523c,%eax
f0104bf2:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
f0104bf8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104bfc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0104c03:	00 
f0104c04:	c7 04 24 90 86 10 f0 	movl   $0xf0108690,(%esp)
f0104c0b:	e8 0e f8 ff ff       	call   f010441e <cprintf>
		cprintf("No runnable environments in the system!\n");
f0104c10:	c7 04 24 b8 86 10 f0 	movl   $0xf01086b8,(%esp)
f0104c17:	e8 02 f8 ff ff       	call   f010441e <cprintf>
		while (1)
			monitor(NULL);
f0104c1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104c23:	e8 0b bf ff ff       	call   f0100b33 <monitor>
f0104c28:	eb f2                	jmp    f0104c1c <sched_halt+0x88>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104c2a:	e8 15 19 00 00       	call   f0106544 <cpunum>
f0104c2f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c32:	c7 80 28 60 22 f0 00 	movl   $0x0,-0xfdd9fd8(%eax)
f0104c39:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104c3c:	a1 94 5e 22 f0       	mov    0xf0225e94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104c41:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104c46:	77 20                	ja     f0104c68 <sched_halt+0xd4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104c48:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104c4c:	c7 44 24 08 6c 6d 10 	movl   $0xf0106d6c,0x8(%esp)
f0104c53:	f0 
f0104c54:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0104c5b:	00 
f0104c5c:	c7 04 24 a9 86 10 f0 	movl   $0xf01086a9,(%esp)
f0104c63:	e8 35 b4 ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104c68:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104c6d:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104c70:	e8 cf 18 00 00       	call   f0106544 <cpunum>
f0104c75:	6b d0 74             	imul   $0x74,%eax,%edx
f0104c78:	81 c2 20 60 22 f0    	add    $0xf0226020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104c7e:	b8 02 00 00 00       	mov    $0x2,%eax
f0104c83:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104c87:	c7 04 24 60 24 12 f0 	movl   $0xf0122460,(%esp)
f0104c8e:	e8 28 1c 00 00       	call   f01068bb <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104c93:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104c95:	e8 aa 18 00 00       	call   f0106544 <cpunum>
f0104c9a:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104c9d:	8b 80 30 60 22 f0    	mov    -0xfdd9fd0(%eax),%eax
f0104ca3:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104ca8:	89 c4                	mov    %eax,%esp
f0104caa:	6a 00                	push   $0x0
f0104cac:	6a 00                	push   $0x0
f0104cae:	fb                   	sti    
f0104caf:	f4                   	hlt    
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104cb0:	83 c4 14             	add    $0x14,%esp
f0104cb3:	5b                   	pop    %ebx
f0104cb4:	5d                   	pop    %ebp
f0104cb5:	c3                   	ret    

f0104cb6 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104cb6:	55                   	push   %ebp
f0104cb7:	89 e5                	mov    %esp,%ebp
f0104cb9:	57                   	push   %edi
f0104cba:	56                   	push   %esi
f0104cbb:	53                   	push   %ebx
f0104cbc:	83 ec 2c             	sub    $0x2c,%esp

	// LAB 4: Your code here.
	struct Env *e;
	// cprintf("curenv: %x\n", curenv);
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_id);
f0104cbf:	e8 80 18 00 00       	call   f0106544 <cpunum>
f0104cc4:	6b c0 74             	imul   $0x74,%eax,%eax
		else cur = 0;
f0104cc7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	// LAB 4: Your code here.
	struct Env *e;
	// cprintf("curenv: %x\n", curenv);
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_id);
f0104cce:	83 b8 28 60 22 f0 00 	cmpl   $0x0,-0xfdd9fd8(%eax)
f0104cd5:	74 19                	je     f0104cf0 <sched_yield+0x3a>
f0104cd7:	e8 68 18 00 00       	call   f0106544 <cpunum>
f0104cdc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cdf:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104ce5:	8b 40 48             	mov    0x48(%eax),%eax
f0104ce8:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104ced:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		else cur = 0;
	// cprintf("cur: %x, thiscpu: %x\n", cur, thiscpu->cpu_id);
	for (i = 0; i < NENV; ++i) {
f0104cf0:	bb 00 00 00 00       	mov    $0x0,%ebx

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
f0104cf5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104cf8:	8d 34 33             	lea    (%ebx,%esi,1),%esi
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_id);
		else cur = 0;
	// cprintf("cur: %x, thiscpu: %x\n", cur, thiscpu->cpu_id);
	for (i = 0; i < NENV; ++i) {
		int j = (cur+i) % NENV;
f0104cfb:	89 f0                	mov    %esi,%eax
f0104cfd:	c1 f8 1f             	sar    $0x1f,%eax
f0104d00:	c1 e8 16             	shr    $0x16,%eax
f0104d03:	01 c6                	add    %eax,%esi
f0104d05:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0104d0b:	29 c6                	sub    %eax,%esi
f0104d0d:	89 75 e0             	mov    %esi,-0x20(%ebp)
		if (j < 2) cprintf("envs[%x].env_status: %x\n", j, envs[j].env_status);
f0104d10:	83 fe 01             	cmp    $0x1,%esi
f0104d13:	7f 20                	jg     f0104d35 <sched_yield+0x7f>
f0104d15:	6b c6 7c             	imul   $0x7c,%esi,%eax
f0104d18:	03 05 3c 52 22 f0    	add    0xf022523c,%eax
f0104d1e:	8b 40 54             	mov    0x54(%eax),%eax
f0104d21:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d25:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104d29:	c7 04 24 90 86 10 f0 	movl   $0xf0108690,(%esp)
f0104d30:	e8 e9 f6 ff ff       	call   f010441e <cprintf>
		if (envs[j].env_status == ENV_RUNNABLE) {
f0104d35:	6b f6 7c             	imul   $0x7c,%esi,%esi
f0104d38:	89 f7                	mov    %esi,%edi
f0104d3a:	a1 3c 52 22 f0       	mov    0xf022523c,%eax
f0104d3f:	83 7c 30 54 02       	cmpl   $0x2,0x54(%eax,%esi,1)
f0104d44:	75 20                	jne    f0104d66 <sched_yield+0xb0>
			if (j == 1) 
f0104d46:	83 7d e0 01          	cmpl   $0x1,-0x20(%ebp)
f0104d4a:	75 0c                	jne    f0104d58 <sched_yield+0xa2>
				cprintf("\n");
f0104d4c:	c7 04 24 e9 6c 10 f0 	movl   $0xf0106ce9,(%esp)
f0104d53:	e8 c6 f6 ff ff       	call   f010441e <cprintf>
			env_run(envs + j);
f0104d58:	03 3d 3c 52 22 f0    	add    0xf022523c,%edi
f0104d5e:	89 3c 24             	mov    %edi,(%esp)
f0104d61:	e8 93 f4 ff ff       	call   f01041f9 <env_run>
	// cprintf("curenv: %x\n", curenv);
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_id);
		else cur = 0;
	// cprintf("cur: %x, thiscpu: %x\n", cur, thiscpu->cpu_id);
	for (i = 0; i < NENV; ++i) {
f0104d66:	83 c3 01             	add    $0x1,%ebx
f0104d69:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0104d6f:	75 84                	jne    f0104cf5 <sched_yield+0x3f>
			if (j == 1) 
				cprintf("\n");
			env_run(envs + j);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104d71:	e8 ce 17 00 00       	call   f0106544 <cpunum>
f0104d76:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d79:	83 b8 28 60 22 f0 00 	cmpl   $0x0,-0xfdd9fd8(%eax)
f0104d80:	74 2a                	je     f0104dac <sched_yield+0xf6>
f0104d82:	e8 bd 17 00 00       	call   f0106544 <cpunum>
f0104d87:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d8a:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104d90:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104d94:	75 16                	jne    f0104dac <sched_yield+0xf6>
		env_run(curenv);
f0104d96:	e8 a9 17 00 00       	call   f0106544 <cpunum>
f0104d9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d9e:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104da4:	89 04 24             	mov    %eax,(%esp)
f0104da7:	e8 4d f4 ff ff       	call   f01041f9 <env_run>

	// sched_halt never returns
	// cprintf("Nothing runnable\n");
	sched_halt();
f0104dac:	e8 e3 fd ff ff       	call   f0104b94 <sched_halt>
}
f0104db1:	83 c4 2c             	add    $0x2c,%esp
f0104db4:	5b                   	pop    %ebx
f0104db5:	5e                   	pop    %esi
f0104db6:	5f                   	pop    %edi
f0104db7:	5d                   	pop    %ebp
f0104db8:	c3                   	ret    
f0104db9:	00 00                	add    %al,(%eax)
f0104dbb:	00 00                	add    %al,(%eax)
f0104dbd:	00 00                	add    %al,(%eax)
	...

f0104dc0 <sys_getenvid>:
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f0104dc0:	55                   	push   %ebp
f0104dc1:	89 e5                	mov    %esp,%ebp
f0104dc3:	83 ec 08             	sub    $0x8,%esp
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f0104dc6:	e8 79 17 00 00       	call   f0106544 <cpunum>
f0104dcb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dce:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104dd4:	8b 40 48             	mov    0x48(%eax),%eax
}
f0104dd7:	c9                   	leave  
f0104dd8:	c3                   	ret    

f0104dd9 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104dd9:	55                   	push   %ebp
f0104dda:	89 e5                	mov    %esp,%ebp
f0104ddc:	83 ec 48             	sub    $0x48,%esp
f0104ddf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104de2:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104de5:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104de8:	8b 45 08             	mov    0x8(%ebp),%eax
f0104deb:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104dee:	8b 5d 10             	mov    0x10(%ebp),%ebx
			break;
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
			break;
		default:
			ret = -E_INVAL;
f0104df1:	be fd ff ff ff       	mov    $0xfffffffd,%esi
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int ret = 0;
	switch (syscallno) {
f0104df6:	83 f8 0a             	cmp    $0xa,%eax
f0104df9:	0f 87 e6 03 00 00    	ja     f01051e5 <syscall+0x40c>
f0104dff:	ff 24 85 5c 87 10 f0 	jmp    *-0xfef78a4(,%eax,4)
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f0104e06:	e8 b5 ff ff ff       	call   f0104dc0 <sys_getenvid>
f0104e0b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e12:	00 
f0104e13:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e16:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104e1a:	89 04 24             	mov    %eax,(%esp)
f0104e1d:	e8 03 ed ff ff       	call   f0103b25 <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f0104e22:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104e29:	00 
f0104e2a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104e2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104e32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e35:	89 04 24             	mov    %eax,(%esp)
f0104e38:	e8 10 ec ff ff       	call   f0103a4d <user_mem_assert>
	//user_mem_check(struct Env *env, const void *va, size_t len, int perm)

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104e3d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104e41:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104e45:	c7 04 24 e1 86 10 f0 	movl   $0xf01086e1,(%esp)
f0104e4c:	e8 cd f5 ff ff       	call   f010441e <cprintf>
	// LAB 3: Your code here.
	int ret = 0;
	switch (syscallno) {
		case SYS_cputs: 
			sys_cputs((char*)a1, a2);
			ret = 0;
f0104e51:	be 00 00 00 00       	mov    $0x0,%esi
f0104e56:	e9 8a 03 00 00       	jmp    f01051e5 <syscall+0x40c>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104e5b:	e8 19 b9 ff ff       	call   f0100779 <cons_getc>
f0104e60:	89 c6                	mov    %eax,%esi
			sys_cputs((char*)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
f0104e62:	e9 7e 03 00 00       	jmp    f01051e5 <syscall+0x40c>
		case SYS_getenvid:
			ret = sys_getenvid();
f0104e67:	e8 54 ff ff ff       	call   f0104dc0 <sys_getenvid>
f0104e6c:	89 c6                	mov    %eax,%esi
			break;
f0104e6e:	66 90                	xchg   %ax,%ax
f0104e70:	e9 70 03 00 00       	jmp    f01051e5 <syscall+0x40c>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104e75:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e7c:	00 
f0104e7d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e84:	89 3c 24             	mov    %edi,(%esp)
f0104e87:	e8 99 ec ff ff       	call   f0103b25 <envid2env>
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
		case SYS_env_destroy:
			sys_env_destroy(a1);
			ret = 0;
f0104e8c:	be 00 00 00 00       	mov    $0x0,%esi
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104e91:	85 c0                	test   %eax,%eax
f0104e93:	0f 88 4c 03 00 00    	js     f01051e5 <syscall+0x40c>
		return r;
	if (e == curenv)
f0104e99:	e8 a6 16 00 00       	call   f0106544 <cpunum>
f0104e9e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ea1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ea4:	39 90 28 60 22 f0    	cmp    %edx,-0xfdd9fd8(%eax)
f0104eaa:	75 23                	jne    f0104ecf <syscall+0xf6>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104eac:	e8 93 16 00 00       	call   f0106544 <cpunum>
f0104eb1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eb4:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104eba:	8b 40 48             	mov    0x48(%eax),%eax
f0104ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ec1:	c7 04 24 e6 86 10 f0 	movl   $0xf01086e6,(%esp)
f0104ec8:	e8 51 f5 ff ff       	call   f010441e <cprintf>
f0104ecd:	eb 28                	jmp    f0104ef7 <syscall+0x11e>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104ecf:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104ed2:	e8 6d 16 00 00       	call   f0106544 <cpunum>
f0104ed7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104edb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ede:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104ee4:	8b 40 48             	mov    0x48(%eax),%eax
f0104ee7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eeb:	c7 04 24 01 87 10 f0 	movl   $0xf0108701,(%esp)
f0104ef2:	e8 27 f5 ff ff       	call   f010441e <cprintf>
	env_destroy(e);
f0104ef7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104efa:	89 04 24             	mov    %eax,(%esp)
f0104efd:	e8 56 f2 ff ff       	call   f0104158 <env_destroy>
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
		case SYS_env_destroy:
			sys_env_destroy(a1);
			ret = 0;
f0104f02:	be 00 00 00 00       	mov    $0x0,%esi
f0104f07:	e9 d9 02 00 00       	jmp    f01051e5 <syscall+0x40c>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104f0c:	e8 a5 fd ff ff       	call   f0104cb6 <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.

	struct Env *e;
	int ret = env_alloc(&e, curenv->env_id);
f0104f11:	e8 2e 16 00 00       	call   f0106544 <cpunum>
f0104f16:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f19:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104f1f:	8b 40 48             	mov    0x48(%eax),%eax
f0104f22:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f26:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f29:	89 04 24             	mov    %eax,(%esp)
f0104f2c:	e8 06 ed ff ff       	call   f0103c37 <env_alloc>
f0104f31:	89 c6                	mov    %eax,%esi
	if (ret) return ret;
f0104f33:	85 c0                	test   %eax,%eax
f0104f35:	0f 85 aa 02 00 00    	jne    f01051e5 <syscall+0x40c>
	e->env_tf = curenv->env_tf;
f0104f3b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104f3e:	e8 01 16 00 00       	call   f0106544 <cpunum>
f0104f43:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f46:	8b b0 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%esi
f0104f4c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104f51:	89 df                	mov    %ebx,%edi
f0104f53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_status = ENV_NOT_RUNNABLE;
f0104f55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f58:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0104f5f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	cprintf("e pgdir: %x\n", e, e->env_pgdir);
f0104f66:	8b 50 60             	mov    0x60(%eax),%edx
f0104f69:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104f6d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f71:	c7 04 24 19 87 10 f0 	movl   $0xf0108719,(%esp)
f0104f78:	e8 a1 f4 ff ff       	call   f010441e <cprintf>

	return e->env_id;
f0104f7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f80:	8b 70 48             	mov    0x48(%eax),%esi
			break;
		case SYS_yield:
			sys_yield();
			break;
		case SYS_exofork:
			return sys_exofork();
f0104f83:	e9 5d 02 00 00       	jmp    f01051e5 <syscall+0x40c>
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
f0104f88:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f8f:	00 
f0104f90:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f93:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f97:	89 3c 24             	mov    %edi,(%esp)
f0104f9a:	e8 86 eb ff ff       	call   f0103b25 <envid2env>
f0104f9f:	89 c6                	mov    %eax,%esi
	if (ret) return ret;	//bad_env
f0104fa1:	85 c0                	test   %eax,%eax
f0104fa3:	0f 85 3c 02 00 00    	jne    f01051e5 <syscall+0x40c>

	if (va >= (void*)UTOP) return -E_INVAL;
f0104fa9:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104fae:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104fb4:	0f 87 2b 02 00 00    	ja     f01051e5 <syscall+0x40c>
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
f0104fba:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fbd:	83 e0 05             	and    $0x5,%eax
f0104fc0:	83 f8 05             	cmp    $0x5,%eax
f0104fc3:	0f 85 1c 02 00 00    	jne    f01051e5 <syscall+0x40c>

	struct PageInfo *pg = page_alloc(1);//init to zero
f0104fc9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104fd0:	e8 f3 c4 ff ff       	call   f01014c8 <page_alloc>
f0104fd5:	89 c7                	mov    %eax,%edi
	if (!pg) return -E_NO_MEM;
f0104fd7:	66 be fc ff          	mov    $0xfffc,%si
f0104fdb:	85 c0                	test   %eax,%eax
f0104fdd:	0f 84 02 02 00 00    	je     f01051e5 <syscall+0x40c>
	pg->pp_ref++;
f0104fe3:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	ret = page_insert(e->env_pgdir, pg, va, perm);
f0104fe8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104feb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104fef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104ff3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104ff7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ffa:	8b 40 60             	mov    0x60(%eax),%eax
f0104ffd:	89 04 24             	mov    %eax,(%esp)
f0105000:	e8 24 c8 ff ff       	call   f0101829 <page_insert>
f0105005:	89 c6                	mov    %eax,%esi
	if (ret) {
f0105007:	85 c0                	test   %eax,%eax
f0105009:	0f 84 d6 01 00 00    	je     f01051e5 <syscall+0x40c>
		page_free(pg);
f010500f:	89 3c 24             	mov    %edi,(%esp)
f0105012:	e8 51 c5 ff ff       	call   f0101568 <page_free>
f0105017:	e9 c9 01 00 00       	jmp    f01051e5 <syscall+0x40c>

	// LAB 4: Your code here.
	//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
	//		or the caller doesn't have permission to change one of them.
	struct Env *se, *de;
	int ret = envid2env(srcenvid, &se, 1);
f010501c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105023:	00 
f0105024:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105027:	89 44 24 04          	mov    %eax,0x4(%esp)
f010502b:	89 3c 24             	mov    %edi,(%esp)
f010502e:	e8 f2 ea ff ff       	call   f0103b25 <envid2env>
f0105033:	89 c6                	mov    %eax,%esi
	if (ret) return ret;	//bad_env
f0105035:	85 c0                	test   %eax,%eax
f0105037:	0f 85 a8 01 00 00    	jne    f01051e5 <syscall+0x40c>
	ret = envid2env(dstenvid, &de, 1);
f010503d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105044:	00 
f0105045:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105048:	89 44 24 04          	mov    %eax,0x4(%esp)
f010504c:	8b 55 14             	mov    0x14(%ebp),%edx
f010504f:	89 14 24             	mov    %edx,(%esp)
f0105052:	e8 ce ea ff ff       	call   f0103b25 <envid2env>
f0105057:	89 c6                	mov    %eax,%esi
	if (ret) return ret;	//bad_env
f0105059:	85 c0                	test   %eax,%eax
f010505b:	0f 85 84 01 00 00    	jne    f01051e5 <syscall+0x40c>
	cprintf("src env: %x, dst env: %x, src va: %x, dst va: %x\n", 
f0105061:	8b 45 18             	mov    0x18(%ebp),%eax
f0105064:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105068:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010506c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010506f:	8b 40 48             	mov    0x48(%eax),%eax
f0105072:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105076:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105079:	8b 40 48             	mov    0x48(%eax),%eax
f010507c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105080:	c7 04 24 28 87 10 f0 	movl   $0xf0108728,(%esp)
f0105087:	e8 92 f3 ff ff       	call   f010441e <cprintf>
		se->env_id, de->env_id, srcva, dstva);

	//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
f010508c:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105092:	0f 87 9b 00 00 00    	ja     f0105133 <syscall+0x35a>
f0105098:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010509f:	0f 87 8e 00 00 00    	ja     f0105133 <syscall+0x35a>
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
f01050a5:	89 d8                	mov    %ebx,%eax
f01050a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		return -E_INVAL;
f01050ac:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	cprintf("src env: %x, dst env: %x, src va: %x, dst va: %x\n", 
		se->env_id, de->env_id, srcva, dstva);

	//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
f01050b1:	39 c3                	cmp    %eax,%ebx
f01050b3:	0f 85 2c 01 00 00    	jne    f01051e5 <syscall+0x40c>
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
f01050b9:	8b 45 18             	mov    0x18(%ebp),%eax
f01050bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01050c1:	39 45 18             	cmp    %eax,0x18(%ebp)
f01050c4:	0f 85 1b 01 00 00    	jne    f01051e5 <syscall+0x40c>
		return -E_INVAL;

	//	-E_INVAL is srcva is not mapped in srcenvid's address space.
	pte_t *pte;
	struct PageInfo *pg = page_lookup(se->env_pgdir, srcva, &pte);
f01050ca:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01050cd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01050d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050d8:	8b 40 60             	mov    0x60(%eax),%eax
f01050db:	89 04 24             	mov    %eax,(%esp)
f01050de:	e8 40 c6 ff ff       	call   f0101723 <page_lookup>
	if (!pg) return -E_INVAL;
f01050e3:	85 c0                	test   %eax,%eax
f01050e5:	0f 84 fa 00 00 00    	je     f01051e5 <syscall+0x40c>

	//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
f01050eb:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01050ee:	83 e2 05             	and    $0x5,%edx
f01050f1:	83 fa 05             	cmp    $0x5,%edx
f01050f4:	0f 85 eb 00 00 00    	jne    f01051e5 <syscall+0x40c>

	//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
	//		address space.
	if (((*pte&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL;
f01050fa:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01050fd:	f6 02 02             	testb  $0x2,(%edx)
f0105100:	75 0a                	jne    f010510c <syscall+0x333>
f0105102:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0105106:	0f 85 d9 00 00 00    	jne    f01051e5 <syscall+0x40c>

	//	-E_NO_MEM if there's no memory to allocate any necessary page tables.

	ret = page_insert(de->env_pgdir, pg, dstva, perm);
f010510c:	8b 55 1c             	mov    0x1c(%ebp),%edx
f010510f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105113:	8b 55 18             	mov    0x18(%ebp),%edx
f0105116:	89 54 24 08          	mov    %edx,0x8(%esp)
f010511a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010511e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105121:	8b 40 60             	mov    0x60(%eax),%eax
f0105124:	89 04 24             	mov    %eax,(%esp)
f0105127:	e8 fd c6 ff ff       	call   f0101829 <page_insert>
f010512c:	89 c6                	mov    %eax,%esi
f010512e:	e9 b2 00 00 00       	jmp    f01051e5 <syscall+0x40c>

	//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
		return -E_INVAL;
f0105133:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105138:	e9 a8 00 00 00       	jmp    f01051e5 <syscall+0x40c>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va>=(void*)UTOP || ROUNDDOWN(va,PGSIZE)!=va)
		return -E_INVAL;
f010513d:	be fd ff ff ff       	mov    $0xfffffffd,%esi
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va>=(void*)UTOP || ROUNDDOWN(va,PGSIZE)!=va)
f0105142:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105148:	0f 87 97 00 00 00    	ja     f01051e5 <syscall+0x40c>
f010514e:	89 d8                	mov    %ebx,%eax
f0105150:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105155:	39 c3                	cmp    %eax,%ebx
f0105157:	0f 85 88 00 00 00    	jne    f01051e5 <syscall+0x40c>
		return -E_INVAL;
	struct Env *e;
	int ret = envid2env(envid, &e, 1);
f010515d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105164:	00 
f0105165:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105168:	89 44 24 04          	mov    %eax,0x4(%esp)
f010516c:	89 3c 24             	mov    %edi,(%esp)
f010516f:	e8 b1 e9 ff ff       	call   f0103b25 <envid2env>
f0105174:	89 c6                	mov    %eax,%esi
	if (ret) return ret;	//bad_env
f0105176:	85 c0                	test   %eax,%eax
f0105178:	75 6b                	jne    f01051e5 <syscall+0x40c>
	page_remove(e->env_pgdir, va);
f010517a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010517e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105181:	8b 40 60             	mov    0x60(%eax),%eax
f0105184:	89 04 24             	mov    %eax,(%esp)
f0105187:	e8 45 c6 ff ff       	call   f01017d1 <page_remove>
f010518c:	eb 57                	jmp    f01051e5 <syscall+0x40c>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;
f010518e:	83 fb 04             	cmp    $0x4,%ebx
f0105191:	74 0a                	je     f010519d <syscall+0x3c4>
f0105193:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105198:	83 fb 02             	cmp    $0x2,%ebx
f010519b:	75 48                	jne    f01051e5 <syscall+0x40c>
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
f010519d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051a4:	00 
f01051a5:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01051a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051ac:	89 3c 24             	mov    %edi,(%esp)
f01051af:	e8 71 e9 ff ff       	call   f0103b25 <envid2env>
f01051b4:	89 c6                	mov    %eax,%esi
	if (ret) return ret;	//bad_env
f01051b6:	85 c0                	test   %eax,%eax
f01051b8:	75 2b                	jne    f01051e5 <syscall+0x40c>
	e->env_status = status;
f01051ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01051bd:	89 58 54             	mov    %ebx,0x54(%eax)
f01051c0:	eb 23                	jmp    f01051e5 <syscall+0x40c>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
f01051c2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051c9:	00 
f01051ca:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01051cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051d1:	89 3c 24             	mov    %edi,(%esp)
f01051d4:	e8 4c e9 ff ff       	call   f0103b25 <envid2env>
f01051d9:	89 c6                	mov    %eax,%esi
	if (ret) return ret;	//bad_env
f01051db:	85 c0                	test   %eax,%eax
f01051dd:	75 06                	jne    f01051e5 <syscall+0x40c>
	e->env_pgfault_upcall = func;
f01051df:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01051e2:	89 58 64             	mov    %ebx,0x64(%eax)
			ret = -E_INVAL;
	}
	// cprintf("ret: %x\n", ret);
	return ret;
	panic("syscall not implemented");
}
f01051e5:	89 f0                	mov    %esi,%eax
f01051e7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01051ea:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01051ed:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01051f0:	89 ec                	mov    %ebp,%esp
f01051f2:	5d                   	pop    %ebp
f01051f3:	c3                   	ret    

f01051f4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01051f4:	55                   	push   %ebp
f01051f5:	89 e5                	mov    %esp,%ebp
f01051f7:	57                   	push   %edi
f01051f8:	56                   	push   %esi
f01051f9:	53                   	push   %ebx
f01051fa:	83 ec 14             	sub    $0x14,%esp
f01051fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105200:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0105203:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105206:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105209:	8b 1a                	mov    (%edx),%ebx
f010520b:	8b 01                	mov    (%ecx),%eax
f010520d:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0105210:	39 c3                	cmp    %eax,%ebx
f0105212:	0f 8f 9c 00 00 00    	jg     f01052b4 <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0105218:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010521f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105222:	01 d8                	add    %ebx,%eax
f0105224:	89 c7                	mov    %eax,%edi
f0105226:	c1 ef 1f             	shr    $0x1f,%edi
f0105229:	01 c7                	add    %eax,%edi
f010522b:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010522d:	39 df                	cmp    %ebx,%edi
f010522f:	7c 33                	jl     f0105264 <stab_binsearch+0x70>
f0105231:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105234:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0105237:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f010523c:	39 f0                	cmp    %esi,%eax
f010523e:	0f 84 bc 00 00 00    	je     f0105300 <stab_binsearch+0x10c>
f0105244:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105248:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010524c:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010524e:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105251:	39 d8                	cmp    %ebx,%eax
f0105253:	7c 0f                	jl     f0105264 <stab_binsearch+0x70>
f0105255:	0f b6 0a             	movzbl (%edx),%ecx
f0105258:	83 ea 0c             	sub    $0xc,%edx
f010525b:	39 f1                	cmp    %esi,%ecx
f010525d:	75 ef                	jne    f010524e <stab_binsearch+0x5a>
f010525f:	e9 9e 00 00 00       	jmp    f0105302 <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105264:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105267:	eb 3c                	jmp    f01052a5 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0105269:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010526c:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f010526e:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105271:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105278:	eb 2b                	jmp    f01052a5 <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010527a:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010527d:	76 14                	jbe    f0105293 <stab_binsearch+0x9f>
			*region_right = m - 1;
f010527f:	83 e8 01             	sub    $0x1,%eax
f0105282:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105285:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105288:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010528a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105291:	eb 12                	jmp    f01052a5 <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105293:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0105296:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0105298:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010529c:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010529e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01052a5:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f01052a8:	0f 8d 71 ff ff ff    	jge    f010521f <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01052ae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01052b2:	75 0f                	jne    f01052c3 <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f01052b4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01052b7:	8b 03                	mov    (%ebx),%eax
f01052b9:	83 e8 01             	sub    $0x1,%eax
f01052bc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01052bf:	89 02                	mov    %eax,(%edx)
f01052c1:	eb 57                	jmp    f010531a <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01052c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01052c6:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01052c8:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01052cb:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01052cd:	39 c1                	cmp    %eax,%ecx
f01052cf:	7d 28                	jge    f01052f9 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01052d1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01052d4:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01052d7:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01052dc:	39 f2                	cmp    %esi,%edx
f01052de:	74 19                	je     f01052f9 <stab_binsearch+0x105>
f01052e0:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01052e4:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01052e8:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01052eb:	39 c1                	cmp    %eax,%ecx
f01052ed:	7d 0a                	jge    f01052f9 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01052ef:	0f b6 1a             	movzbl (%edx),%ebx
f01052f2:	83 ea 0c             	sub    $0xc,%edx
f01052f5:	39 f3                	cmp    %esi,%ebx
f01052f7:	75 ef                	jne    f01052e8 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f01052f9:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01052fc:	89 02                	mov    %eax,(%edx)
f01052fe:	eb 1a                	jmp    f010531a <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105300:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105302:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105305:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0105308:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010530c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010530f:	0f 82 54 ff ff ff    	jb     f0105269 <stab_binsearch+0x75>
f0105315:	e9 60 ff ff ff       	jmp    f010527a <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f010531a:	83 c4 14             	add    $0x14,%esp
f010531d:	5b                   	pop    %ebx
f010531e:	5e                   	pop    %esi
f010531f:	5f                   	pop    %edi
f0105320:	5d                   	pop    %ebp
f0105321:	c3                   	ret    

f0105322 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105322:	55                   	push   %ebp
f0105323:	89 e5                	mov    %esp,%ebp
f0105325:	83 ec 68             	sub    $0x68,%esp
f0105328:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010532b:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010532e:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105331:	8b 75 08             	mov    0x8(%ebp),%esi
f0105334:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105337:	c7 03 88 87 10 f0    	movl   $0xf0108788,(%ebx)
	info->eip_line = 0;
f010533d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105344:	c7 43 08 88 87 10 f0 	movl   $0xf0108788,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010534b:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105352:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105355:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010535c:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105362:	0f 87 ca 00 00 00    	ja     f0105432 <debuginfo_eip+0x110>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0105368:	e8 d7 11 00 00       	call   f0106544 <cpunum>
f010536d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105374:	00 
f0105375:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010537c:	00 
f010537d:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105384:	00 
f0105385:	6b c0 74             	imul   $0x74,%eax,%eax
f0105388:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f010538e:	89 04 24             	mov    %eax,(%esp)
f0105391:	e8 27 e6 ff ff       	call   f01039bd <user_mem_check>
f0105396:	85 c0                	test   %eax,%eax
f0105398:	0f 85 82 02 00 00    	jne    f0105620 <debuginfo_eip+0x2fe>
			return -1;

		stabs = usd->stabs;
f010539e:	a1 00 00 20 00       	mov    0x200000,%eax
f01053a3:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f01053a6:	8b 15 04 00 20 00    	mov    0x200004,%edx
f01053ac:	89 55 bc             	mov    %edx,-0x44(%ebp)
		stabstr = usd->stabstr;
f01053af:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f01053b5:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		stabstr_end = usd->stabstr_end;
f01053b8:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f01053be:	e8 81 11 00 00       	call   f0106544 <cpunum>
f01053c3:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01053ca:	00 
f01053cb:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f01053d2:	00 
f01053d3:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01053d6:	89 54 24 04          	mov    %edx,0x4(%esp)
f01053da:	6b c0 74             	imul   $0x74,%eax,%eax
f01053dd:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f01053e3:	89 04 24             	mov    %eax,(%esp)
f01053e6:	e8 d2 e5 ff ff       	call   f01039bd <user_mem_check>
f01053eb:	85 c0                	test   %eax,%eax
f01053ed:	0f 85 34 02 00 00    	jne    f0105627 <debuginfo_eip+0x305>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f01053f3:	e8 4c 11 00 00       	call   f0106544 <cpunum>
f01053f8:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01053ff:	00 
f0105400:	89 fa                	mov    %edi,%edx
f0105402:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f0105405:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105409:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010540c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105410:	6b c0 74             	imul   $0x74,%eax,%eax
f0105413:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0105419:	89 04 24             	mov    %eax,(%esp)
f010541c:	e8 9c e5 ff ff       	call   f01039bd <user_mem_check>
f0105421:	89 c2                	mov    %eax,%edx
			return -1;
f0105423:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0105428:	85 d2                	test   %edx,%edx
f010542a:	0f 85 0a 02 00 00    	jne    f010563a <debuginfo_eip+0x318>
f0105430:	eb 1a                	jmp    f010544c <debuginfo_eip+0x12a>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105432:	bf 5e 74 11 f0       	mov    $0xf011745e,%edi
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105437:	c7 45 c4 89 3b 11 f0 	movl   $0xf0113b89,-0x3c(%ebp)
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010543e:	c7 45 bc 88 3b 11 f0 	movl   $0xf0113b88,-0x44(%ebp)
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105445:	c7 45 c0 74 8c 10 f0 	movl   $0xf0108c74,-0x40(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010544c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105451:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0105454:	0f 83 e0 01 00 00    	jae    f010563a <debuginfo_eip+0x318>
f010545a:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f010545e:	0f 85 ca 01 00 00    	jne    f010562e <debuginfo_eip+0x30c>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105464:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010546b:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010546e:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0105471:	c1 f8 02             	sar    $0x2,%eax
f0105474:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010547a:	83 e8 01             	sub    $0x1,%eax
f010547d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105480:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105484:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010548b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010548e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105491:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105494:	e8 5b fd ff ff       	call   f01051f4 <stab_binsearch>
	if (lfile == 0)
f0105499:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f010549c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01054a1:	85 d2                	test   %edx,%edx
f01054a3:	0f 84 91 01 00 00    	je     f010563a <debuginfo_eip+0x318>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01054a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01054ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054af:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01054b2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01054b6:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01054bd:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01054c0:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01054c3:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01054c6:	e8 29 fd ff ff       	call   f01051f4 <stab_binsearch>

	if (lfun <= rfun) {
f01054cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01054ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01054d1:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f01054d4:	39 c2                	cmp    %eax,%edx
f01054d6:	7f 31                	jg     f0105509 <debuginfo_eip+0x1e7>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01054d8:	6b c2 0c             	imul   $0xc,%edx,%eax
f01054db:	03 45 c0             	add    -0x40(%ebp),%eax
f01054de:	8b 08                	mov    (%eax),%ecx
f01054e0:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f01054e3:	89 f9                	mov    %edi,%ecx
f01054e5:	2b 4d c4             	sub    -0x3c(%ebp),%ecx
f01054e8:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f01054eb:	73 09                	jae    f01054f6 <debuginfo_eip+0x1d4>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01054ed:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01054f0:	03 4d bc             	add    -0x44(%ebp),%ecx
f01054f3:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01054f6:	8b 40 08             	mov    0x8(%eax),%eax
f01054f9:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01054fc:	29 c6                	sub    %eax,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01054fe:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0105501:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0105504:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105507:	eb 0f                	jmp    f0105518 <debuginfo_eip+0x1f6>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105509:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010550c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010550f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105512:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105515:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105518:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010551f:	00 
f0105520:	8b 43 08             	mov    0x8(%ebx),%eax
f0105523:	89 04 24             	mov    %eax,(%esp)
f0105526:	e8 5f 09 00 00       	call   f0105e8a <strfind>
f010552b:	2b 43 08             	sub    0x8(%ebx),%eax
f010552e:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105531:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105535:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f010553c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010553f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105542:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105545:	e8 aa fc ff ff       	call   f01051f4 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f010554a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010554d:	6b c6 0c             	imul   $0xc,%esi,%eax
f0105550:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105553:	0f b7 44 02 06       	movzwl 0x6(%edx,%eax,1),%eax
f0105558:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010555b:	89 f0                	mov    %esi,%eax
f010555d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105560:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f0105563:	39 ce                	cmp    %ecx,%esi
f0105565:	7c 66                	jl     f01055cd <debuginfo_eip+0x2ab>
	       && stabs[lline].n_type != N_SOL
f0105567:	6b d6 0c             	imul   $0xc,%esi,%edx
f010556a:	03 55 c0             	add    -0x40(%ebp),%edx
f010556d:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0105570:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105574:	80 f9 84             	cmp    $0x84,%cl
f0105577:	74 3f                	je     f01055b8 <debuginfo_eip+0x296>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105579:	8d 56 ff             	lea    -0x1(%esi),%edx
f010557c:	6b d2 0c             	imul   $0xc,%edx,%edx
f010557f:	03 55 c0             	add    -0x40(%ebp),%edx
f0105582:	eb 1e                	jmp    f01055a2 <debuginfo_eip+0x280>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105584:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105587:	3b 45 b8             	cmp    -0x48(%ebp),%eax
f010558a:	7c 41                	jl     f01055cd <debuginfo_eip+0x2ab>
f010558c:	89 55 bc             	mov    %edx,-0x44(%ebp)
	       && stabs[lline].n_type != N_SOL
f010558f:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105593:	83 ea 0c             	sub    $0xc,%edx
f0105596:	80 f9 84             	cmp    $0x84,%cl
f0105599:	75 05                	jne    f01055a0 <debuginfo_eip+0x27e>
f010559b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010559e:	eb 18                	jmp    f01055b8 <debuginfo_eip+0x296>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01055a0:	89 c6                	mov    %eax,%esi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01055a2:	80 f9 64             	cmp    $0x64,%cl
f01055a5:	75 dd                	jne    f0105584 <debuginfo_eip+0x262>
f01055a7:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f01055aa:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f01055ae:	74 d4                	je     f0105584 <debuginfo_eip+0x262>
f01055b0:	89 75 d4             	mov    %esi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01055b3:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f01055b6:	7f 15                	jg     f01055cd <debuginfo_eip+0x2ab>
f01055b8:	6b c0 0c             	imul   $0xc,%eax,%eax
f01055bb:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01055be:	8b 04 02             	mov    (%edx,%eax,1),%eax
f01055c1:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f01055c4:	39 f8                	cmp    %edi,%eax
f01055c6:	73 05                	jae    f01055cd <debuginfo_eip+0x2ab>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01055c8:	03 45 c4             	add    -0x3c(%ebp),%eax
f01055cb:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01055cd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01055d0:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f01055d3:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01055d6:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01055db:	39 f1                	cmp    %esi,%ecx
f01055dd:	7d 5b                	jge    f010563a <debuginfo_eip+0x318>
		for (lline = lfun + 1;
f01055df:	89 ca                	mov    %ecx,%edx
f01055e1:	83 c2 01             	add    $0x1,%edx
f01055e4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01055e7:	39 d6                	cmp    %edx,%esi
f01055e9:	7e 4f                	jle    f010563a <debuginfo_eip+0x318>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01055eb:	6b fa 0c             	imul   $0xc,%edx,%edi
f01055ee:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01055f1:	80 7c 39 04 a0       	cmpb   $0xa0,0x4(%ecx,%edi,1)
f01055f6:	75 42                	jne    f010563a <debuginfo_eip+0x318>
f01055f8:	6b 4d bc 0c          	imul   $0xc,-0x44(%ebp),%ecx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01055fc:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01055ff:	8d 44 0f 1c          	lea    0x1c(%edi,%ecx,1),%eax
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105603:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0105607:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010560a:	39 d6                	cmp    %edx,%esi
f010560c:	7e 27                	jle    f0105635 <debuginfo_eip+0x313>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010560e:	0f b6 08             	movzbl (%eax),%ecx
f0105611:	83 c0 0c             	add    $0xc,%eax
f0105614:	80 f9 a0             	cmp    $0xa0,%cl
f0105617:	74 ea                	je     f0105603 <debuginfo_eip+0x2e1>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105619:	b8 00 00 00 00       	mov    $0x0,%eax
f010561e:	eb 1a                	jmp    f010563a <debuginfo_eip+0x318>
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0105620:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105625:	eb 13                	jmp    f010563a <debuginfo_eip+0x318>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f0105627:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010562c:	eb 0c                	jmp    f010563a <debuginfo_eip+0x318>
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010562e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105633:	eb 05                	jmp    f010563a <debuginfo_eip+0x318>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105635:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010563a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010563d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105640:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105643:	89 ec                	mov    %ebp,%esp
f0105645:	5d                   	pop    %ebp
f0105646:	c3                   	ret    
	...

f0105650 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105650:	55                   	push   %ebp
f0105651:	89 e5                	mov    %esp,%ebp
f0105653:	57                   	push   %edi
f0105654:	56                   	push   %esi
f0105655:	53                   	push   %ebx
f0105656:	83 ec 4c             	sub    $0x4c,%esp
f0105659:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010565c:	89 d6                	mov    %edx,%esi
f010565e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105661:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105664:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105667:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010566a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010566d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105670:	b8 00 00 00 00       	mov    $0x0,%eax
f0105675:	39 d0                	cmp    %edx,%eax
f0105677:	72 11                	jb     f010568a <printnum+0x3a>
f0105679:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010567c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
f010567f:	76 09                	jbe    f010568a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105681:	83 eb 01             	sub    $0x1,%ebx
f0105684:	85 db                	test   %ebx,%ebx
f0105686:	7f 5d                	jg     f01056e5 <printnum+0x95>
f0105688:	eb 6c                	jmp    f01056f6 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010568a:	89 7c 24 10          	mov    %edi,0x10(%esp)
f010568e:	83 eb 01             	sub    $0x1,%ebx
f0105691:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105695:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105698:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010569c:	8b 44 24 08          	mov    0x8(%esp),%eax
f01056a0:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01056a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01056a7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01056aa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01056b1:	00 
f01056b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01056b5:	89 14 24             	mov    %edx,(%esp)
f01056b8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01056bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01056bf:	e8 1c 13 00 00       	call   f01069e0 <__udivdi3>
f01056c4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01056c7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01056ca:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01056ce:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01056d2:	89 04 24             	mov    %eax,(%esp)
f01056d5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01056d9:	89 f2                	mov    %esi,%edx
f01056db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056de:	e8 6d ff ff ff       	call   f0105650 <printnum>
f01056e3:	eb 11                	jmp    f01056f6 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01056e5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01056e9:	89 3c 24             	mov    %edi,(%esp)
f01056ec:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01056ef:	83 eb 01             	sub    $0x1,%ebx
f01056f2:	85 db                	test   %ebx,%ebx
f01056f4:	7f ef                	jg     f01056e5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01056f6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01056fa:	8b 74 24 04          	mov    0x4(%esp),%esi
f01056fe:	8b 45 10             	mov    0x10(%ebp),%eax
f0105701:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105705:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010570c:	00 
f010570d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105710:	89 14 24             	mov    %edx,(%esp)
f0105713:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105716:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010571a:	e8 d1 13 00 00       	call   f0106af0 <__umoddi3>
f010571f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105723:	0f be 80 92 87 10 f0 	movsbl -0xfef786e(%eax),%eax
f010572a:	89 04 24             	mov    %eax,(%esp)
f010572d:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105730:	83 c4 4c             	add    $0x4c,%esp
f0105733:	5b                   	pop    %ebx
f0105734:	5e                   	pop    %esi
f0105735:	5f                   	pop    %edi
f0105736:	5d                   	pop    %ebp
f0105737:	c3                   	ret    

f0105738 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105738:	55                   	push   %ebp
f0105739:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010573b:	83 fa 01             	cmp    $0x1,%edx
f010573e:	7e 0e                	jle    f010574e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105740:	8b 10                	mov    (%eax),%edx
f0105742:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105745:	89 08                	mov    %ecx,(%eax)
f0105747:	8b 02                	mov    (%edx),%eax
f0105749:	8b 52 04             	mov    0x4(%edx),%edx
f010574c:	eb 22                	jmp    f0105770 <getuint+0x38>
	else if (lflag)
f010574e:	85 d2                	test   %edx,%edx
f0105750:	74 10                	je     f0105762 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105752:	8b 10                	mov    (%eax),%edx
f0105754:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105757:	89 08                	mov    %ecx,(%eax)
f0105759:	8b 02                	mov    (%edx),%eax
f010575b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105760:	eb 0e                	jmp    f0105770 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105762:	8b 10                	mov    (%eax),%edx
f0105764:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105767:	89 08                	mov    %ecx,(%eax)
f0105769:	8b 02                	mov    (%edx),%eax
f010576b:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105770:	5d                   	pop    %ebp
f0105771:	c3                   	ret    

f0105772 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0105772:	55                   	push   %ebp
f0105773:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105775:	83 fa 01             	cmp    $0x1,%edx
f0105778:	7e 0e                	jle    f0105788 <getint+0x16>
		return va_arg(*ap, long long);
f010577a:	8b 10                	mov    (%eax),%edx
f010577c:	8d 4a 08             	lea    0x8(%edx),%ecx
f010577f:	89 08                	mov    %ecx,(%eax)
f0105781:	8b 02                	mov    (%edx),%eax
f0105783:	8b 52 04             	mov    0x4(%edx),%edx
f0105786:	eb 22                	jmp    f01057aa <getint+0x38>
	else if (lflag)
f0105788:	85 d2                	test   %edx,%edx
f010578a:	74 10                	je     f010579c <getint+0x2a>
		return va_arg(*ap, long);
f010578c:	8b 10                	mov    (%eax),%edx
f010578e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105791:	89 08                	mov    %ecx,(%eax)
f0105793:	8b 02                	mov    (%edx),%eax
f0105795:	89 c2                	mov    %eax,%edx
f0105797:	c1 fa 1f             	sar    $0x1f,%edx
f010579a:	eb 0e                	jmp    f01057aa <getint+0x38>
	else
		return va_arg(*ap, int);
f010579c:	8b 10                	mov    (%eax),%edx
f010579e:	8d 4a 04             	lea    0x4(%edx),%ecx
f01057a1:	89 08                	mov    %ecx,(%eax)
f01057a3:	8b 02                	mov    (%edx),%eax
f01057a5:	89 c2                	mov    %eax,%edx
f01057a7:	c1 fa 1f             	sar    $0x1f,%edx
}
f01057aa:	5d                   	pop    %ebp
f01057ab:	c3                   	ret    

f01057ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01057ac:	55                   	push   %ebp
f01057ad:	89 e5                	mov    %esp,%ebp
f01057af:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01057b2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01057b6:	8b 10                	mov    (%eax),%edx
f01057b8:	3b 50 04             	cmp    0x4(%eax),%edx
f01057bb:	73 0a                	jae    f01057c7 <sprintputch+0x1b>
		*b->buf++ = ch;
f01057bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01057c0:	88 0a                	mov    %cl,(%edx)
f01057c2:	83 c2 01             	add    $0x1,%edx
f01057c5:	89 10                	mov    %edx,(%eax)
}
f01057c7:	5d                   	pop    %ebp
f01057c8:	c3                   	ret    

f01057c9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01057c9:	55                   	push   %ebp
f01057ca:	89 e5                	mov    %esp,%ebp
f01057cc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01057cf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01057d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01057d6:	8b 45 10             	mov    0x10(%ebp),%eax
f01057d9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01057dd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01057e7:	89 04 24             	mov    %eax,(%esp)
f01057ea:	e8 02 00 00 00       	call   f01057f1 <vprintfmt>
	va_end(ap);
}
f01057ef:	c9                   	leave  
f01057f0:	c3                   	ret    

f01057f1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01057f1:	55                   	push   %ebp
f01057f2:	89 e5                	mov    %esp,%ebp
f01057f4:	57                   	push   %edi
f01057f5:	56                   	push   %esi
f01057f6:	53                   	push   %ebx
f01057f7:	83 ec 4c             	sub    $0x4c,%esp
f01057fa:	8b 7d 10             	mov    0x10(%ebp),%edi
f01057fd:	eb 23                	jmp    f0105822 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
f01057ff:	85 c0                	test   %eax,%eax
f0105801:	75 12                	jne    f0105815 <vprintfmt+0x24>
				csa = 0x0700;
f0105803:	c7 05 88 5e 22 f0 00 	movl   $0x700,0xf0225e88
f010580a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f010580d:	83 c4 4c             	add    $0x4c,%esp
f0105810:	5b                   	pop    %ebx
f0105811:	5e                   	pop    %esi
f0105812:	5f                   	pop    %edi
f0105813:	5d                   	pop    %ebp
f0105814:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
f0105815:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105818:	89 54 24 04          	mov    %edx,0x4(%esp)
f010581c:	89 04 24             	mov    %eax,(%esp)
f010581f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105822:	0f b6 07             	movzbl (%edi),%eax
f0105825:	83 c7 01             	add    $0x1,%edi
f0105828:	83 f8 25             	cmp    $0x25,%eax
f010582b:	75 d2                	jne    f01057ff <vprintfmt+0xe>
f010582d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0105831:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105838:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010583d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105844:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105849:	be 00 00 00 00       	mov    $0x0,%esi
f010584e:	eb 14                	jmp    f0105864 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
f0105850:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0105854:	eb 0e                	jmp    f0105864 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105856:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f010585a:	eb 08                	jmp    f0105864 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f010585c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010585f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105864:	0f b6 07             	movzbl (%edi),%eax
f0105867:	0f b6 c8             	movzbl %al,%ecx
f010586a:	83 c7 01             	add    $0x1,%edi
f010586d:	83 e8 23             	sub    $0x23,%eax
f0105870:	3c 55                	cmp    $0x55,%al
f0105872:	0f 87 ed 02 00 00    	ja     f0105b65 <vprintfmt+0x374>
f0105878:	0f b6 c0             	movzbl %al,%eax
f010587b:	ff 24 85 60 88 10 f0 	jmp    *-0xfef77a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105882:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
f0105885:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0105888:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010588b:	83 f9 09             	cmp    $0x9,%ecx
f010588e:	77 3c                	ja     f01058cc <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105890:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0105893:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
f0105896:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
f010589a:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f010589d:	8d 48 d0             	lea    -0x30(%eax),%ecx
f01058a0:	83 f9 09             	cmp    $0x9,%ecx
f01058a3:	76 eb                	jbe    f0105890 <vprintfmt+0x9f>
f01058a5:	eb 25                	jmp    f01058cc <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01058a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01058aa:	8d 48 04             	lea    0x4(%eax),%ecx
f01058ad:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01058b0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
f01058b2:	eb 18                	jmp    f01058cc <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
f01058b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01058b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058bb:	0f 48 c6             	cmovs  %esi,%eax
f01058be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01058c1:	eb a1                	jmp    f0105864 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
f01058c3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f01058ca:	eb 98                	jmp    f0105864 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
f01058cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01058d0:	79 92                	jns    f0105864 <vprintfmt+0x73>
f01058d2:	eb 88                	jmp    f010585c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01058d4:	83 c2 01             	add    $0x1,%edx
f01058d7:	eb 8b                	jmp    f0105864 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01058d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01058dc:	8d 50 04             	lea    0x4(%eax),%edx
f01058df:	89 55 14             	mov    %edx,0x14(%ebp)
f01058e2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01058e5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01058e9:	8b 00                	mov    (%eax),%eax
f01058eb:	89 04 24             	mov    %eax,(%esp)
f01058ee:	ff 55 08             	call   *0x8(%ebp)
			break;
f01058f1:	e9 2c ff ff ff       	jmp    f0105822 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01058f6:	8b 45 14             	mov    0x14(%ebp),%eax
f01058f9:	8d 50 04             	lea    0x4(%eax),%edx
f01058fc:	89 55 14             	mov    %edx,0x14(%ebp)
f01058ff:	8b 00                	mov    (%eax),%eax
f0105901:	89 c2                	mov    %eax,%edx
f0105903:	c1 fa 1f             	sar    $0x1f,%edx
f0105906:	31 d0                	xor    %edx,%eax
f0105908:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010590a:	83 f8 08             	cmp    $0x8,%eax
f010590d:	7f 0b                	jg     f010591a <vprintfmt+0x129>
f010590f:	8b 14 85 c0 89 10 f0 	mov    -0xfef7640(,%eax,4),%edx
f0105916:	85 d2                	test   %edx,%edx
f0105918:	75 23                	jne    f010593d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
f010591a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010591e:	c7 44 24 08 aa 87 10 	movl   $0xf01087aa,0x8(%esp)
f0105925:	f0 
f0105926:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105929:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010592d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105930:	89 04 24             	mov    %eax,(%esp)
f0105933:	e8 91 fe ff ff       	call   f01057c9 <printfmt>
f0105938:	e9 e5 fe ff ff       	jmp    f0105822 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
f010593d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105941:	c7 44 24 08 d0 74 10 	movl   $0xf01074d0,0x8(%esp)
f0105948:	f0 
f0105949:	8b 55 0c             	mov    0xc(%ebp),%edx
f010594c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105950:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105953:	89 1c 24             	mov    %ebx,(%esp)
f0105956:	e8 6e fe ff ff       	call   f01057c9 <printfmt>
f010595b:	e9 c2 fe ff ff       	jmp    f0105822 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105960:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105963:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105966:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105969:	8b 45 14             	mov    0x14(%ebp),%eax
f010596c:	8d 50 04             	lea    0x4(%eax),%edx
f010596f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105972:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0105974:	85 f6                	test   %esi,%esi
f0105976:	ba a3 87 10 f0       	mov    $0xf01087a3,%edx
f010597b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f010597e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105982:	7e 06                	jle    f010598a <vprintfmt+0x199>
f0105984:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0105988:	75 13                	jne    f010599d <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010598a:	0f be 06             	movsbl (%esi),%eax
f010598d:	83 c6 01             	add    $0x1,%esi
f0105990:	85 c0                	test   %eax,%eax
f0105992:	0f 85 a2 00 00 00    	jne    f0105a3a <vprintfmt+0x249>
f0105998:	e9 92 00 00 00       	jmp    f0105a2f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010599d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01059a1:	89 34 24             	mov    %esi,(%esp)
f01059a4:	e8 52 03 00 00       	call   f0105cfb <strnlen>
f01059a9:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01059ac:	29 c2                	sub    %eax,%edx
f01059ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01059b1:	85 d2                	test   %edx,%edx
f01059b3:	7e d5                	jle    f010598a <vprintfmt+0x199>
					putch(padc, putdat);
f01059b5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
f01059b9:	89 75 d8             	mov    %esi,-0x28(%ebp)
f01059bc:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f01059bf:	89 d3                	mov    %edx,%ebx
f01059c1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01059c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01059c7:	89 c6                	mov    %eax,%esi
f01059c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01059cd:	89 34 24             	mov    %esi,(%esp)
f01059d0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01059d3:	83 eb 01             	sub    $0x1,%ebx
f01059d6:	85 db                	test   %ebx,%ebx
f01059d8:	7f ef                	jg     f01059c9 <vprintfmt+0x1d8>
f01059da:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01059dd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01059e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01059e3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01059ea:	eb 9e                	jmp    f010598a <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01059ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01059f0:	74 1b                	je     f0105a0d <vprintfmt+0x21c>
f01059f2:	8d 50 e0             	lea    -0x20(%eax),%edx
f01059f5:	83 fa 5e             	cmp    $0x5e,%edx
f01059f8:	76 13                	jbe    f0105a0d <vprintfmt+0x21c>
					putch('?', putdat);
f01059fa:	8b 55 0c             	mov    0xc(%ebp),%edx
f01059fd:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105a01:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105a08:	ff 55 08             	call   *0x8(%ebp)
f0105a0b:	eb 0d                	jmp    f0105a1a <vprintfmt+0x229>
				else
					putch(ch, putdat);
f0105a0d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105a10:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105a14:	89 04 24             	mov    %eax,(%esp)
f0105a17:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105a1a:	83 ef 01             	sub    $0x1,%edi
f0105a1d:	0f be 06             	movsbl (%esi),%eax
f0105a20:	85 c0                	test   %eax,%eax
f0105a22:	74 05                	je     f0105a29 <vprintfmt+0x238>
f0105a24:	83 c6 01             	add    $0x1,%esi
f0105a27:	eb 17                	jmp    f0105a40 <vprintfmt+0x24f>
f0105a29:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105a2c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105a2f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105a33:	7f 1c                	jg     f0105a51 <vprintfmt+0x260>
f0105a35:	e9 e8 fd ff ff       	jmp    f0105822 <vprintfmt+0x31>
f0105a3a:	89 7d dc             	mov    %edi,-0x24(%ebp)
f0105a3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105a40:	85 db                	test   %ebx,%ebx
f0105a42:	78 a8                	js     f01059ec <vprintfmt+0x1fb>
f0105a44:	83 eb 01             	sub    $0x1,%ebx
f0105a47:	79 a3                	jns    f01059ec <vprintfmt+0x1fb>
f0105a49:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105a4c:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105a4f:	eb de                	jmp    f0105a2f <vprintfmt+0x23e>
f0105a51:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105a54:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105a57:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105a5a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105a5e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105a65:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105a67:	83 eb 01             	sub    $0x1,%ebx
f0105a6a:	85 db                	test   %ebx,%ebx
f0105a6c:	7f ec                	jg     f0105a5a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a6e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105a71:	e9 ac fd ff ff       	jmp    f0105822 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105a76:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a79:	e8 f4 fc ff ff       	call   f0105772 <getint>
f0105a7e:	89 c3                	mov    %eax,%ebx
f0105a80:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0105a82:	85 d2                	test   %edx,%edx
f0105a84:	78 0a                	js     f0105a90 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105a86:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105a8b:	e9 87 00 00 00       	jmp    f0105b17 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105a90:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105a93:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a97:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105a9e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105aa1:	89 d8                	mov    %ebx,%eax
f0105aa3:	89 f2                	mov    %esi,%edx
f0105aa5:	f7 d8                	neg    %eax
f0105aa7:	83 d2 00             	adc    $0x0,%edx
f0105aaa:	f7 da                	neg    %edx
			}
			base = 10;
f0105aac:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105ab1:	eb 64                	jmp    f0105b17 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105ab3:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ab6:	e8 7d fc ff ff       	call   f0105738 <getuint>
			base = 10;
f0105abb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105ac0:	eb 55                	jmp    f0105b17 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
f0105ac2:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ac5:	e8 6e fc ff ff       	call   f0105738 <getuint>
      base = 8;
f0105aca:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
f0105acf:	eb 46                	jmp    f0105b17 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
f0105ad1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ad4:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ad8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105adf:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105ae2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105ae5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ae9:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105af0:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105af3:	8b 45 14             	mov    0x14(%ebp),%eax
f0105af6:	8d 50 04             	lea    0x4(%eax),%edx
f0105af9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105afc:	8b 00                	mov    (%eax),%eax
f0105afe:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105b03:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105b08:	eb 0d                	jmp    f0105b17 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105b0a:	8d 45 14             	lea    0x14(%ebp),%eax
f0105b0d:	e8 26 fc ff ff       	call   f0105738 <getuint>
			base = 16;
f0105b12:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105b17:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0105b1b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0105b1f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105b22:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105b26:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105b2a:	89 04 24             	mov    %eax,(%esp)
f0105b2d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105b31:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b34:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b37:	e8 14 fb ff ff       	call   f0105650 <printnum>
			break;
f0105b3c:	e9 e1 fc ff ff       	jmp    f0105822 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105b41:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b44:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b48:	89 0c 24             	mov    %ecx,(%esp)
f0105b4b:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105b4e:	e9 cf fc ff ff       	jmp    f0105822 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
f0105b53:	8d 45 14             	lea    0x14(%ebp),%eax
f0105b56:	e8 17 fc ff ff       	call   f0105772 <getint>
			csa = num;
f0105b5b:	a3 88 5e 22 f0       	mov    %eax,0xf0225e88
			break;
f0105b60:	e9 bd fc ff ff       	jmp    f0105822 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105b65:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b68:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105b6c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105b73:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105b76:	83 ef 01             	sub    $0x1,%edi
f0105b79:	eb 02                	jmp    f0105b7d <vprintfmt+0x38c>
f0105b7b:	89 c7                	mov    %eax,%edi
f0105b7d:	8d 47 ff             	lea    -0x1(%edi),%eax
f0105b80:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105b84:	75 f5                	jne    f0105b7b <vprintfmt+0x38a>
f0105b86:	e9 97 fc ff ff       	jmp    f0105822 <vprintfmt+0x31>

f0105b8b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105b8b:	55                   	push   %ebp
f0105b8c:	89 e5                	mov    %esp,%ebp
f0105b8e:	83 ec 28             	sub    $0x28,%esp
f0105b91:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b94:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105b97:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105b9a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105b9e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105ba1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105ba8:	85 c0                	test   %eax,%eax
f0105baa:	74 30                	je     f0105bdc <vsnprintf+0x51>
f0105bac:	85 d2                	test   %edx,%edx
f0105bae:	7e 2c                	jle    f0105bdc <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105bb0:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105bb7:	8b 45 10             	mov    0x10(%ebp),%eax
f0105bba:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105bbe:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bc5:	c7 04 24 ac 57 10 f0 	movl   $0xf01057ac,(%esp)
f0105bcc:	e8 20 fc ff ff       	call   f01057f1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105bd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105bd4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105bda:	eb 05                	jmp    f0105be1 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105bdc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105be1:	c9                   	leave  
f0105be2:	c3                   	ret    

f0105be3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105be3:	55                   	push   %ebp
f0105be4:	89 e5                	mov    %esp,%ebp
f0105be6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105be9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105bec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105bf0:	8b 45 10             	mov    0x10(%ebp),%eax
f0105bf3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105bf7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bfe:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c01:	89 04 24             	mov    %eax,(%esp)
f0105c04:	e8 82 ff ff ff       	call   f0105b8b <vsnprintf>
	va_end(ap);

	return rc;
}
f0105c09:	c9                   	leave  
f0105c0a:	c3                   	ret    
f0105c0b:	00 00                	add    %al,(%eax)
f0105c0d:	00 00                	add    %al,(%eax)
	...

f0105c10 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105c10:	55                   	push   %ebp
f0105c11:	89 e5                	mov    %esp,%ebp
f0105c13:	57                   	push   %edi
f0105c14:	56                   	push   %esi
f0105c15:	53                   	push   %ebx
f0105c16:	83 ec 1c             	sub    $0x1c,%esp
f0105c19:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105c1c:	85 c0                	test   %eax,%eax
f0105c1e:	74 10                	je     f0105c30 <readline+0x20>
		cprintf("%s", prompt);
f0105c20:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c24:	c7 04 24 d0 74 10 f0 	movl   $0xf01074d0,(%esp)
f0105c2b:	e8 ee e7 ff ff       	call   f010441e <cprintf>

	i = 0;
	echoing = iscons(0);
f0105c30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105c37:	e8 af ac ff ff       	call   f01008eb <iscons>
f0105c3c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105c3e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105c43:	e8 92 ac ff ff       	call   f01008da <getchar>
f0105c48:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105c4a:	85 c0                	test   %eax,%eax
f0105c4c:	79 17                	jns    f0105c65 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c52:	c7 04 24 e4 89 10 f0 	movl   $0xf01089e4,(%esp)
f0105c59:	e8 c0 e7 ff ff       	call   f010441e <cprintf>
			return NULL;
f0105c5e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c63:	eb 6d                	jmp    f0105cd2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105c65:	83 f8 08             	cmp    $0x8,%eax
f0105c68:	74 05                	je     f0105c6f <readline+0x5f>
f0105c6a:	83 f8 7f             	cmp    $0x7f,%eax
f0105c6d:	75 19                	jne    f0105c88 <readline+0x78>
f0105c6f:	85 f6                	test   %esi,%esi
f0105c71:	7e 15                	jle    f0105c88 <readline+0x78>
			if (echoing)
f0105c73:	85 ff                	test   %edi,%edi
f0105c75:	74 0c                	je     f0105c83 <readline+0x73>
				cputchar('\b');
f0105c77:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105c7e:	e8 47 ac ff ff       	call   f01008ca <cputchar>
			i--;
f0105c83:	83 ee 01             	sub    $0x1,%esi
f0105c86:	eb bb                	jmp    f0105c43 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105c88:	83 fb 1f             	cmp    $0x1f,%ebx
f0105c8b:	7e 1f                	jle    f0105cac <readline+0x9c>
f0105c8d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105c93:	7f 17                	jg     f0105cac <readline+0x9c>
			if (echoing)
f0105c95:	85 ff                	test   %edi,%edi
f0105c97:	74 08                	je     f0105ca1 <readline+0x91>
				cputchar(c);
f0105c99:	89 1c 24             	mov    %ebx,(%esp)
f0105c9c:	e8 29 ac ff ff       	call   f01008ca <cputchar>
			buf[i++] = c;
f0105ca1:	88 9e 80 5a 22 f0    	mov    %bl,-0xfdda580(%esi)
f0105ca7:	83 c6 01             	add    $0x1,%esi
f0105caa:	eb 97                	jmp    f0105c43 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105cac:	83 fb 0a             	cmp    $0xa,%ebx
f0105caf:	74 05                	je     f0105cb6 <readline+0xa6>
f0105cb1:	83 fb 0d             	cmp    $0xd,%ebx
f0105cb4:	75 8d                	jne    f0105c43 <readline+0x33>
			if (echoing)
f0105cb6:	85 ff                	test   %edi,%edi
f0105cb8:	74 0c                	je     f0105cc6 <readline+0xb6>
				cputchar('\n');
f0105cba:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105cc1:	e8 04 ac ff ff       	call   f01008ca <cputchar>
			buf[i] = 0;
f0105cc6:	c6 86 80 5a 22 f0 00 	movb   $0x0,-0xfdda580(%esi)
			return buf;
f0105ccd:	b8 80 5a 22 f0       	mov    $0xf0225a80,%eax
		}
	}
}
f0105cd2:	83 c4 1c             	add    $0x1c,%esp
f0105cd5:	5b                   	pop    %ebx
f0105cd6:	5e                   	pop    %esi
f0105cd7:	5f                   	pop    %edi
f0105cd8:	5d                   	pop    %ebp
f0105cd9:	c3                   	ret    
f0105cda:	00 00                	add    %al,(%eax)
f0105cdc:	00 00                	add    %al,(%eax)
	...

f0105ce0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105ce0:	55                   	push   %ebp
f0105ce1:	89 e5                	mov    %esp,%ebp
f0105ce3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105ce6:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ceb:	80 3a 00             	cmpb   $0x0,(%edx)
f0105cee:	74 09                	je     f0105cf9 <strlen+0x19>
		n++;
f0105cf0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105cf3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105cf7:	75 f7                	jne    f0105cf0 <strlen+0x10>
		n++;
	return n;
}
f0105cf9:	5d                   	pop    %ebp
f0105cfa:	c3                   	ret    

f0105cfb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105cfb:	55                   	push   %ebp
f0105cfc:	89 e5                	mov    %esp,%ebp
f0105cfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105d01:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105d04:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d09:	85 d2                	test   %edx,%edx
f0105d0b:	74 12                	je     f0105d1f <strnlen+0x24>
f0105d0d:	80 39 00             	cmpb   $0x0,(%ecx)
f0105d10:	74 0d                	je     f0105d1f <strnlen+0x24>
		n++;
f0105d12:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105d15:	39 d0                	cmp    %edx,%eax
f0105d17:	74 06                	je     f0105d1f <strnlen+0x24>
f0105d19:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105d1d:	75 f3                	jne    f0105d12 <strnlen+0x17>
		n++;
	return n;
}
f0105d1f:	5d                   	pop    %ebp
f0105d20:	c3                   	ret    

f0105d21 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105d21:	55                   	push   %ebp
f0105d22:	89 e5                	mov    %esp,%ebp
f0105d24:	53                   	push   %ebx
f0105d25:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105d2b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d30:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105d34:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105d37:	83 c2 01             	add    $0x1,%edx
f0105d3a:	84 c9                	test   %cl,%cl
f0105d3c:	75 f2                	jne    f0105d30 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105d3e:	5b                   	pop    %ebx
f0105d3f:	5d                   	pop    %ebp
f0105d40:	c3                   	ret    

f0105d41 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105d41:	55                   	push   %ebp
f0105d42:	89 e5                	mov    %esp,%ebp
f0105d44:	53                   	push   %ebx
f0105d45:	83 ec 08             	sub    $0x8,%esp
f0105d48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105d4b:	89 1c 24             	mov    %ebx,(%esp)
f0105d4e:	e8 8d ff ff ff       	call   f0105ce0 <strlen>
	strcpy(dst + len, src);
f0105d53:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105d56:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105d5a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0105d5d:	89 04 24             	mov    %eax,(%esp)
f0105d60:	e8 bc ff ff ff       	call   f0105d21 <strcpy>
	return dst;
}
f0105d65:	89 d8                	mov    %ebx,%eax
f0105d67:	83 c4 08             	add    $0x8,%esp
f0105d6a:	5b                   	pop    %ebx
f0105d6b:	5d                   	pop    %ebp
f0105d6c:	c3                   	ret    

f0105d6d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105d6d:	55                   	push   %ebp
f0105d6e:	89 e5                	mov    %esp,%ebp
f0105d70:	56                   	push   %esi
f0105d71:	53                   	push   %ebx
f0105d72:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d75:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105d78:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105d7b:	85 f6                	test   %esi,%esi
f0105d7d:	74 18                	je     f0105d97 <strncpy+0x2a>
f0105d7f:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0105d84:	0f b6 1a             	movzbl (%edx),%ebx
f0105d87:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105d8a:	80 3a 01             	cmpb   $0x1,(%edx)
f0105d8d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105d90:	83 c1 01             	add    $0x1,%ecx
f0105d93:	39 ce                	cmp    %ecx,%esi
f0105d95:	77 ed                	ja     f0105d84 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105d97:	5b                   	pop    %ebx
f0105d98:	5e                   	pop    %esi
f0105d99:	5d                   	pop    %ebp
f0105d9a:	c3                   	ret    

f0105d9b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105d9b:	55                   	push   %ebp
f0105d9c:	89 e5                	mov    %esp,%ebp
f0105d9e:	56                   	push   %esi
f0105d9f:	53                   	push   %ebx
f0105da0:	8b 75 08             	mov    0x8(%ebp),%esi
f0105da3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105da6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105da9:	89 f0                	mov    %esi,%eax
f0105dab:	85 c9                	test   %ecx,%ecx
f0105dad:	74 23                	je     f0105dd2 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
f0105daf:	83 e9 01             	sub    $0x1,%ecx
f0105db2:	74 1b                	je     f0105dcf <strlcpy+0x34>
f0105db4:	0f b6 1a             	movzbl (%edx),%ebx
f0105db7:	84 db                	test   %bl,%bl
f0105db9:	74 14                	je     f0105dcf <strlcpy+0x34>
			*dst++ = *src++;
f0105dbb:	88 18                	mov    %bl,(%eax)
f0105dbd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105dc0:	83 e9 01             	sub    $0x1,%ecx
f0105dc3:	74 0a                	je     f0105dcf <strlcpy+0x34>
			*dst++ = *src++;
f0105dc5:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105dc8:	0f b6 1a             	movzbl (%edx),%ebx
f0105dcb:	84 db                	test   %bl,%bl
f0105dcd:	75 ec                	jne    f0105dbb <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
f0105dcf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105dd2:	29 f0                	sub    %esi,%eax
}
f0105dd4:	5b                   	pop    %ebx
f0105dd5:	5e                   	pop    %esi
f0105dd6:	5d                   	pop    %ebp
f0105dd7:	c3                   	ret    

f0105dd8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105dd8:	55                   	push   %ebp
f0105dd9:	89 e5                	mov    %esp,%ebp
f0105ddb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105dde:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105de1:	0f b6 01             	movzbl (%ecx),%eax
f0105de4:	84 c0                	test   %al,%al
f0105de6:	74 15                	je     f0105dfd <strcmp+0x25>
f0105de8:	3a 02                	cmp    (%edx),%al
f0105dea:	75 11                	jne    f0105dfd <strcmp+0x25>
		p++, q++;
f0105dec:	83 c1 01             	add    $0x1,%ecx
f0105def:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105df2:	0f b6 01             	movzbl (%ecx),%eax
f0105df5:	84 c0                	test   %al,%al
f0105df7:	74 04                	je     f0105dfd <strcmp+0x25>
f0105df9:	3a 02                	cmp    (%edx),%al
f0105dfb:	74 ef                	je     f0105dec <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105dfd:	0f b6 c0             	movzbl %al,%eax
f0105e00:	0f b6 12             	movzbl (%edx),%edx
f0105e03:	29 d0                	sub    %edx,%eax
}
f0105e05:	5d                   	pop    %ebp
f0105e06:	c3                   	ret    

f0105e07 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105e07:	55                   	push   %ebp
f0105e08:	89 e5                	mov    %esp,%ebp
f0105e0a:	53                   	push   %ebx
f0105e0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105e0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105e11:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105e14:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105e19:	85 d2                	test   %edx,%edx
f0105e1b:	74 28                	je     f0105e45 <strncmp+0x3e>
f0105e1d:	0f b6 01             	movzbl (%ecx),%eax
f0105e20:	84 c0                	test   %al,%al
f0105e22:	74 24                	je     f0105e48 <strncmp+0x41>
f0105e24:	3a 03                	cmp    (%ebx),%al
f0105e26:	75 20                	jne    f0105e48 <strncmp+0x41>
f0105e28:	83 ea 01             	sub    $0x1,%edx
f0105e2b:	74 13                	je     f0105e40 <strncmp+0x39>
		n--, p++, q++;
f0105e2d:	83 c1 01             	add    $0x1,%ecx
f0105e30:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105e33:	0f b6 01             	movzbl (%ecx),%eax
f0105e36:	84 c0                	test   %al,%al
f0105e38:	74 0e                	je     f0105e48 <strncmp+0x41>
f0105e3a:	3a 03                	cmp    (%ebx),%al
f0105e3c:	74 ea                	je     f0105e28 <strncmp+0x21>
f0105e3e:	eb 08                	jmp    f0105e48 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105e40:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105e45:	5b                   	pop    %ebx
f0105e46:	5d                   	pop    %ebp
f0105e47:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105e48:	0f b6 01             	movzbl (%ecx),%eax
f0105e4b:	0f b6 13             	movzbl (%ebx),%edx
f0105e4e:	29 d0                	sub    %edx,%eax
f0105e50:	eb f3                	jmp    f0105e45 <strncmp+0x3e>

f0105e52 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105e52:	55                   	push   %ebp
f0105e53:	89 e5                	mov    %esp,%ebp
f0105e55:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e58:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105e5c:	0f b6 10             	movzbl (%eax),%edx
f0105e5f:	84 d2                	test   %dl,%dl
f0105e61:	74 20                	je     f0105e83 <strchr+0x31>
		if (*s == c)
f0105e63:	38 ca                	cmp    %cl,%dl
f0105e65:	75 0b                	jne    f0105e72 <strchr+0x20>
f0105e67:	eb 1f                	jmp    f0105e88 <strchr+0x36>
f0105e69:	38 ca                	cmp    %cl,%dl
f0105e6b:	90                   	nop
f0105e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105e70:	74 16                	je     f0105e88 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105e72:	83 c0 01             	add    $0x1,%eax
f0105e75:	0f b6 10             	movzbl (%eax),%edx
f0105e78:	84 d2                	test   %dl,%dl
f0105e7a:	75 ed                	jne    f0105e69 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0105e7c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e81:	eb 05                	jmp    f0105e88 <strchr+0x36>
f0105e83:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e88:	5d                   	pop    %ebp
f0105e89:	c3                   	ret    

f0105e8a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105e8a:	55                   	push   %ebp
f0105e8b:	89 e5                	mov    %esp,%ebp
f0105e8d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105e94:	0f b6 10             	movzbl (%eax),%edx
f0105e97:	84 d2                	test   %dl,%dl
f0105e99:	74 14                	je     f0105eaf <strfind+0x25>
		if (*s == c)
f0105e9b:	38 ca                	cmp    %cl,%dl
f0105e9d:	75 06                	jne    f0105ea5 <strfind+0x1b>
f0105e9f:	eb 0e                	jmp    f0105eaf <strfind+0x25>
f0105ea1:	38 ca                	cmp    %cl,%dl
f0105ea3:	74 0a                	je     f0105eaf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105ea5:	83 c0 01             	add    $0x1,%eax
f0105ea8:	0f b6 10             	movzbl (%eax),%edx
f0105eab:	84 d2                	test   %dl,%dl
f0105ead:	75 f2                	jne    f0105ea1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0105eaf:	5d                   	pop    %ebp
f0105eb0:	c3                   	ret    

f0105eb1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105eb1:	55                   	push   %ebp
f0105eb2:	89 e5                	mov    %esp,%ebp
f0105eb4:	83 ec 0c             	sub    $0xc,%esp
f0105eb7:	89 1c 24             	mov    %ebx,(%esp)
f0105eba:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105ebe:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105ec2:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105ec5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ec8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105ecb:	85 c9                	test   %ecx,%ecx
f0105ecd:	74 30                	je     f0105eff <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105ecf:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105ed5:	75 25                	jne    f0105efc <memset+0x4b>
f0105ed7:	f6 c1 03             	test   $0x3,%cl
f0105eda:	75 20                	jne    f0105efc <memset+0x4b>
		c &= 0xFF;
f0105edc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105edf:	89 d3                	mov    %edx,%ebx
f0105ee1:	c1 e3 08             	shl    $0x8,%ebx
f0105ee4:	89 d6                	mov    %edx,%esi
f0105ee6:	c1 e6 18             	shl    $0x18,%esi
f0105ee9:	89 d0                	mov    %edx,%eax
f0105eeb:	c1 e0 10             	shl    $0x10,%eax
f0105eee:	09 f0                	or     %esi,%eax
f0105ef0:	09 d0                	or     %edx,%eax
f0105ef2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105ef4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105ef7:	fc                   	cld    
f0105ef8:	f3 ab                	rep stos %eax,%es:(%edi)
f0105efa:	eb 03                	jmp    f0105eff <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105efc:	fc                   	cld    
f0105efd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105eff:	89 f8                	mov    %edi,%eax
f0105f01:	8b 1c 24             	mov    (%esp),%ebx
f0105f04:	8b 74 24 04          	mov    0x4(%esp),%esi
f0105f08:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0105f0c:	89 ec                	mov    %ebp,%esp
f0105f0e:	5d                   	pop    %ebp
f0105f0f:	c3                   	ret    

f0105f10 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105f10:	55                   	push   %ebp
f0105f11:	89 e5                	mov    %esp,%ebp
f0105f13:	83 ec 08             	sub    $0x8,%esp
f0105f16:	89 34 24             	mov    %esi,(%esp)
f0105f19:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f20:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105f23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105f26:	39 c6                	cmp    %eax,%esi
f0105f28:	73 36                	jae    f0105f60 <memmove+0x50>
f0105f2a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105f2d:	39 d0                	cmp    %edx,%eax
f0105f2f:	73 2f                	jae    f0105f60 <memmove+0x50>
		s += n;
		d += n;
f0105f31:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105f34:	f6 c2 03             	test   $0x3,%dl
f0105f37:	75 1b                	jne    f0105f54 <memmove+0x44>
f0105f39:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105f3f:	75 13                	jne    f0105f54 <memmove+0x44>
f0105f41:	f6 c1 03             	test   $0x3,%cl
f0105f44:	75 0e                	jne    f0105f54 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105f46:	83 ef 04             	sub    $0x4,%edi
f0105f49:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105f4c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105f4f:	fd                   	std    
f0105f50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105f52:	eb 09                	jmp    f0105f5d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105f54:	83 ef 01             	sub    $0x1,%edi
f0105f57:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105f5a:	fd                   	std    
f0105f5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105f5d:	fc                   	cld    
f0105f5e:	eb 20                	jmp    f0105f80 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105f60:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105f66:	75 13                	jne    f0105f7b <memmove+0x6b>
f0105f68:	a8 03                	test   $0x3,%al
f0105f6a:	75 0f                	jne    f0105f7b <memmove+0x6b>
f0105f6c:	f6 c1 03             	test   $0x3,%cl
f0105f6f:	75 0a                	jne    f0105f7b <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105f71:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105f74:	89 c7                	mov    %eax,%edi
f0105f76:	fc                   	cld    
f0105f77:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105f79:	eb 05                	jmp    f0105f80 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105f7b:	89 c7                	mov    %eax,%edi
f0105f7d:	fc                   	cld    
f0105f7e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105f80:	8b 34 24             	mov    (%esp),%esi
f0105f83:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105f87:	89 ec                	mov    %ebp,%esp
f0105f89:	5d                   	pop    %ebp
f0105f8a:	c3                   	ret    

f0105f8b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105f8b:	55                   	push   %ebp
f0105f8c:	89 e5                	mov    %esp,%ebp
f0105f8e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105f91:	8b 45 10             	mov    0x10(%ebp),%eax
f0105f94:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105f98:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f9f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fa2:	89 04 24             	mov    %eax,(%esp)
f0105fa5:	e8 66 ff ff ff       	call   f0105f10 <memmove>
}
f0105faa:	c9                   	leave  
f0105fab:	c3                   	ret    

f0105fac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105fac:	55                   	push   %ebp
f0105fad:	89 e5                	mov    %esp,%ebp
f0105faf:	57                   	push   %edi
f0105fb0:	56                   	push   %esi
f0105fb1:	53                   	push   %ebx
f0105fb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105fb5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105fb8:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105fbb:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105fc0:	85 ff                	test   %edi,%edi
f0105fc2:	74 38                	je     f0105ffc <memcmp+0x50>
		if (*s1 != *s2)
f0105fc4:	0f b6 03             	movzbl (%ebx),%eax
f0105fc7:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105fca:	83 ef 01             	sub    $0x1,%edi
f0105fcd:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0105fd2:	38 c8                	cmp    %cl,%al
f0105fd4:	74 1d                	je     f0105ff3 <memcmp+0x47>
f0105fd6:	eb 11                	jmp    f0105fe9 <memcmp+0x3d>
f0105fd8:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0105fdd:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
f0105fe2:	83 c2 01             	add    $0x1,%edx
f0105fe5:	38 c8                	cmp    %cl,%al
f0105fe7:	74 0a                	je     f0105ff3 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
f0105fe9:	0f b6 c0             	movzbl %al,%eax
f0105fec:	0f b6 c9             	movzbl %cl,%ecx
f0105fef:	29 c8                	sub    %ecx,%eax
f0105ff1:	eb 09                	jmp    f0105ffc <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105ff3:	39 fa                	cmp    %edi,%edx
f0105ff5:	75 e1                	jne    f0105fd8 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105ff7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ffc:	5b                   	pop    %ebx
f0105ffd:	5e                   	pop    %esi
f0105ffe:	5f                   	pop    %edi
f0105fff:	5d                   	pop    %ebp
f0106000:	c3                   	ret    

f0106001 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106001:	55                   	push   %ebp
f0106002:	89 e5                	mov    %esp,%ebp
f0106004:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0106007:	89 c2                	mov    %eax,%edx
f0106009:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010600c:	39 d0                	cmp    %edx,%eax
f010600e:	73 15                	jae    f0106025 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106010:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0106014:	38 08                	cmp    %cl,(%eax)
f0106016:	75 06                	jne    f010601e <memfind+0x1d>
f0106018:	eb 0b                	jmp    f0106025 <memfind+0x24>
f010601a:	38 08                	cmp    %cl,(%eax)
f010601c:	74 07                	je     f0106025 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010601e:	83 c0 01             	add    $0x1,%eax
f0106021:	39 c2                	cmp    %eax,%edx
f0106023:	77 f5                	ja     f010601a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106025:	5d                   	pop    %ebp
f0106026:	c3                   	ret    

f0106027 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106027:	55                   	push   %ebp
f0106028:	89 e5                	mov    %esp,%ebp
f010602a:	57                   	push   %edi
f010602b:	56                   	push   %esi
f010602c:	53                   	push   %ebx
f010602d:	8b 55 08             	mov    0x8(%ebp),%edx
f0106030:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106033:	0f b6 02             	movzbl (%edx),%eax
f0106036:	3c 20                	cmp    $0x20,%al
f0106038:	74 04                	je     f010603e <strtol+0x17>
f010603a:	3c 09                	cmp    $0x9,%al
f010603c:	75 0e                	jne    f010604c <strtol+0x25>
		s++;
f010603e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106041:	0f b6 02             	movzbl (%edx),%eax
f0106044:	3c 20                	cmp    $0x20,%al
f0106046:	74 f6                	je     f010603e <strtol+0x17>
f0106048:	3c 09                	cmp    $0x9,%al
f010604a:	74 f2                	je     f010603e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f010604c:	3c 2b                	cmp    $0x2b,%al
f010604e:	75 0a                	jne    f010605a <strtol+0x33>
		s++;
f0106050:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106053:	bf 00 00 00 00       	mov    $0x0,%edi
f0106058:	eb 10                	jmp    f010606a <strtol+0x43>
f010605a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010605f:	3c 2d                	cmp    $0x2d,%al
f0106061:	75 07                	jne    f010606a <strtol+0x43>
		s++, neg = 1;
f0106063:	83 c2 01             	add    $0x1,%edx
f0106066:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010606a:	85 db                	test   %ebx,%ebx
f010606c:	0f 94 c0             	sete   %al
f010606f:	74 05                	je     f0106076 <strtol+0x4f>
f0106071:	83 fb 10             	cmp    $0x10,%ebx
f0106074:	75 15                	jne    f010608b <strtol+0x64>
f0106076:	80 3a 30             	cmpb   $0x30,(%edx)
f0106079:	75 10                	jne    f010608b <strtol+0x64>
f010607b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010607f:	75 0a                	jne    f010608b <strtol+0x64>
		s += 2, base = 16;
f0106081:	83 c2 02             	add    $0x2,%edx
f0106084:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106089:	eb 13                	jmp    f010609e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f010608b:	84 c0                	test   %al,%al
f010608d:	74 0f                	je     f010609e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010608f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106094:	80 3a 30             	cmpb   $0x30,(%edx)
f0106097:	75 05                	jne    f010609e <strtol+0x77>
		s++, base = 8;
f0106099:	83 c2 01             	add    $0x1,%edx
f010609c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f010609e:	b8 00 00 00 00       	mov    $0x0,%eax
f01060a3:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01060a5:	0f b6 0a             	movzbl (%edx),%ecx
f01060a8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01060ab:	80 fb 09             	cmp    $0x9,%bl
f01060ae:	77 08                	ja     f01060b8 <strtol+0x91>
			dig = *s - '0';
f01060b0:	0f be c9             	movsbl %cl,%ecx
f01060b3:	83 e9 30             	sub    $0x30,%ecx
f01060b6:	eb 1e                	jmp    f01060d6 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f01060b8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01060bb:	80 fb 19             	cmp    $0x19,%bl
f01060be:	77 08                	ja     f01060c8 <strtol+0xa1>
			dig = *s - 'a' + 10;
f01060c0:	0f be c9             	movsbl %cl,%ecx
f01060c3:	83 e9 57             	sub    $0x57,%ecx
f01060c6:	eb 0e                	jmp    f01060d6 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f01060c8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01060cb:	80 fb 19             	cmp    $0x19,%bl
f01060ce:	77 15                	ja     f01060e5 <strtol+0xbe>
			dig = *s - 'A' + 10;
f01060d0:	0f be c9             	movsbl %cl,%ecx
f01060d3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01060d6:	39 f1                	cmp    %esi,%ecx
f01060d8:	7d 0f                	jge    f01060e9 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
f01060da:	83 c2 01             	add    $0x1,%edx
f01060dd:	0f af c6             	imul   %esi,%eax
f01060e0:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f01060e3:	eb c0                	jmp    f01060a5 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01060e5:	89 c1                	mov    %eax,%ecx
f01060e7:	eb 02                	jmp    f01060eb <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01060e9:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01060eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01060ef:	74 05                	je     f01060f6 <strtol+0xcf>
		*endptr = (char *) s;
f01060f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01060f4:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01060f6:	89 ca                	mov    %ecx,%edx
f01060f8:	f7 da                	neg    %edx
f01060fa:	85 ff                	test   %edi,%edi
f01060fc:	0f 45 c2             	cmovne %edx,%eax
}
f01060ff:	5b                   	pop    %ebx
f0106100:	5e                   	pop    %esi
f0106101:	5f                   	pop    %edi
f0106102:	5d                   	pop    %ebp
f0106103:	c3                   	ret    

f0106104 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106104:	fa                   	cli    

	xorw    %ax, %ax
f0106105:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106107:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106109:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010610b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f010610d:	0f 01 16             	lgdtl  (%esi)
f0106110:	74 70                	je     f0106182 <sum+0x2>
	movl    %cr0, %eax
f0106112:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106115:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106119:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f010611c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106122:	08 00                	or     %al,(%eax)

f0106124 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106124:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106128:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010612a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010612c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010612e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106132:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106134:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106136:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f010613b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010613e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106141:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106146:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106149:	8b 25 84 5e 22 f0    	mov    0xf0225e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010614f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106154:	b8 05 01 10 f0       	mov    $0xf0100105,%eax
	call    *%eax
f0106159:	ff d0                	call   *%eax

f010615b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010615b:	eb fe                	jmp    f010615b <spin>
f010615d:	8d 76 00             	lea    0x0(%esi),%esi

f0106160 <gdt>:
	...
f0106168:	ff                   	(bad)  
f0106169:	ff 00                	incl   (%eax)
f010616b:	00 00                	add    %al,(%eax)
f010616d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106174:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106178 <gdtdesc>:
f0106178:	17                   	pop    %ss
f0106179:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010617e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010617e:	90                   	nop
	...

f0106180 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0106180:	55                   	push   %ebp
f0106181:	89 e5                	mov    %esp,%ebp
f0106183:	56                   	push   %esi
f0106184:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0106185:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f010618a:	85 d2                	test   %edx,%edx
f010618c:	7e 12                	jle    f01061a0 <sum+0x20>
f010618e:	b9 00 00 00 00       	mov    $0x0,%ecx
		sum += ((uint8_t *)addr)[i];
f0106193:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0106197:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106199:	83 c1 01             	add    $0x1,%ecx
f010619c:	39 d1                	cmp    %edx,%ecx
f010619e:	75 f3                	jne    f0106193 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f01061a0:	89 d8                	mov    %ebx,%eax
f01061a2:	5b                   	pop    %ebx
f01061a3:	5e                   	pop    %esi
f01061a4:	5d                   	pop    %ebp
f01061a5:	c3                   	ret    

f01061a6 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01061a6:	55                   	push   %ebp
f01061a7:	89 e5                	mov    %esp,%ebp
f01061a9:	56                   	push   %esi
f01061aa:	53                   	push   %ebx
f01061ab:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01061ae:	8b 0d 90 5e 22 f0    	mov    0xf0225e90,%ecx
f01061b4:	89 c3                	mov    %eax,%ebx
f01061b6:	c1 eb 0c             	shr    $0xc,%ebx
f01061b9:	39 cb                	cmp    %ecx,%ebx
f01061bb:	72 20                	jb     f01061dd <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01061bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01061c1:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f01061c8:	f0 
f01061c9:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01061d0:	00 
f01061d1:	c7 04 24 81 8b 10 f0 	movl   $0xf0108b81,(%esp)
f01061d8:	e8 c0 9e ff ff       	call   f010009d <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01061dd:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01061e0:	89 f2                	mov    %esi,%edx
f01061e2:	c1 ea 0c             	shr    $0xc,%edx
f01061e5:	39 d1                	cmp    %edx,%ecx
f01061e7:	77 20                	ja     f0106209 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01061e9:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01061ed:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f01061f4:	f0 
f01061f5:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01061fc:	00 
f01061fd:	c7 04 24 81 8b 10 f0 	movl   $0xf0108b81,(%esp)
f0106204:	e8 94 9e ff ff       	call   f010009d <_panic>
	return (void *)(pa + KERNBASE);
f0106209:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010620f:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106215:	39 f3                	cmp    %esi,%ebx
f0106217:	73 3a                	jae    f0106253 <mpsearch1+0xad>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106219:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106220:	00 
f0106221:	c7 44 24 04 91 8b 10 	movl   $0xf0108b91,0x4(%esp)
f0106228:	f0 
f0106229:	89 1c 24             	mov    %ebx,(%esp)
f010622c:	e8 7b fd ff ff       	call   f0105fac <memcmp>
f0106231:	85 c0                	test   %eax,%eax
f0106233:	75 10                	jne    f0106245 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0106235:	ba 10 00 00 00       	mov    $0x10,%edx
f010623a:	89 d8                	mov    %ebx,%eax
f010623c:	e8 3f ff ff ff       	call   f0106180 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106241:	84 c0                	test   %al,%al
f0106243:	74 13                	je     f0106258 <mpsearch1+0xb2>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106245:	83 c3 10             	add    $0x10,%ebx
f0106248:	39 de                	cmp    %ebx,%esi
f010624a:	77 cd                	ja     f0106219 <mpsearch1+0x73>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010624c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106251:	eb 05                	jmp    f0106258 <mpsearch1+0xb2>
f0106253:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106258:	89 d8                	mov    %ebx,%eax
f010625a:	83 c4 10             	add    $0x10,%esp
f010625d:	5b                   	pop    %ebx
f010625e:	5e                   	pop    %esi
f010625f:	5d                   	pop    %ebp
f0106260:	c3                   	ret    

f0106261 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106261:	55                   	push   %ebp
f0106262:	89 e5                	mov    %esp,%ebp
f0106264:	57                   	push   %edi
f0106265:	56                   	push   %esi
f0106266:	53                   	push   %ebx
f0106267:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010626a:	c7 05 c0 63 22 f0 20 	movl   $0xf0226020,0xf02263c0
f0106271:	60 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106274:	83 3d 90 5e 22 f0 00 	cmpl   $0x0,0xf0225e90
f010627b:	75 24                	jne    f01062a1 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010627d:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106284:	00 
f0106285:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f010628c:	f0 
f010628d:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106294:	00 
f0106295:	c7 04 24 81 8b 10 f0 	movl   $0xf0108b81,(%esp)
f010629c:	e8 fc 9d ff ff       	call   f010009d <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01062a1:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01062a8:	85 c0                	test   %eax,%eax
f01062aa:	74 16                	je     f01062c2 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f01062ac:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01062af:	ba 00 04 00 00       	mov    $0x400,%edx
f01062b4:	e8 ed fe ff ff       	call   f01061a6 <mpsearch1>
f01062b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01062bc:	85 c0                	test   %eax,%eax
f01062be:	75 3c                	jne    f01062fc <mp_init+0x9b>
f01062c0:	eb 20                	jmp    f01062e2 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01062c2:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01062c9:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01062cc:	2d 00 04 00 00       	sub    $0x400,%eax
f01062d1:	ba 00 04 00 00       	mov    $0x400,%edx
f01062d6:	e8 cb fe ff ff       	call   f01061a6 <mpsearch1>
f01062db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01062de:	85 c0                	test   %eax,%eax
f01062e0:	75 1a                	jne    f01062fc <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01062e2:	ba 00 00 01 00       	mov    $0x10000,%edx
f01062e7:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01062ec:	e8 b5 fe ff ff       	call   f01061a6 <mpsearch1>
f01062f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01062f4:	85 c0                	test   %eax,%eax
f01062f6:	0f 84 26 02 00 00    	je     f0106522 <mp_init+0x2c1>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01062fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01062ff:	8b 78 04             	mov    0x4(%eax),%edi
f0106302:	85 ff                	test   %edi,%edi
f0106304:	74 06                	je     f010630c <mp_init+0xab>
f0106306:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010630a:	74 11                	je     f010631d <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f010630c:	c7 04 24 f4 89 10 f0 	movl   $0xf01089f4,(%esp)
f0106313:	e8 06 e1 ff ff       	call   f010441e <cprintf>
f0106318:	e9 05 02 00 00       	jmp    f0106522 <mp_init+0x2c1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010631d:	89 f8                	mov    %edi,%eax
f010631f:	c1 e8 0c             	shr    $0xc,%eax
f0106322:	3b 05 90 5e 22 f0    	cmp    0xf0225e90,%eax
f0106328:	72 20                	jb     f010634a <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010632a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010632e:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f0106335:	f0 
f0106336:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f010633d:	00 
f010633e:	c7 04 24 81 8b 10 f0 	movl   $0xf0108b81,(%esp)
f0106345:	e8 53 9d ff ff       	call   f010009d <_panic>
	return (void *)(pa + KERNBASE);
f010634a:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106350:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106357:	00 
f0106358:	c7 44 24 04 96 8b 10 	movl   $0xf0108b96,0x4(%esp)
f010635f:	f0 
f0106360:	89 3c 24             	mov    %edi,(%esp)
f0106363:	e8 44 fc ff ff       	call   f0105fac <memcmp>
f0106368:	85 c0                	test   %eax,%eax
f010636a:	74 11                	je     f010637d <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010636c:	c7 04 24 24 8a 10 f0 	movl   $0xf0108a24,(%esp)
f0106373:	e8 a6 e0 ff ff       	call   f010441e <cprintf>
f0106378:	e9 a5 01 00 00       	jmp    f0106522 <mp_init+0x2c1>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010637d:	0f b7 5f 04          	movzwl 0x4(%edi),%ebx
f0106381:	0f b7 d3             	movzwl %bx,%edx
f0106384:	89 f8                	mov    %edi,%eax
f0106386:	e8 f5 fd ff ff       	call   f0106180 <sum>
f010638b:	84 c0                	test   %al,%al
f010638d:	74 11                	je     f01063a0 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f010638f:	c7 04 24 58 8a 10 f0 	movl   $0xf0108a58,(%esp)
f0106396:	e8 83 e0 ff ff       	call   f010441e <cprintf>
f010639b:	e9 82 01 00 00       	jmp    f0106522 <mp_init+0x2c1>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01063a0:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f01063a4:	3c 01                	cmp    $0x1,%al
f01063a6:	74 1c                	je     f01063c4 <mp_init+0x163>
f01063a8:	3c 04                	cmp    $0x4,%al
f01063aa:	74 18                	je     f01063c4 <mp_init+0x163>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01063ac:	0f b6 c0             	movzbl %al,%eax
f01063af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01063b3:	c7 04 24 7c 8a 10 f0 	movl   $0xf0108a7c,(%esp)
f01063ba:	e8 5f e0 ff ff       	call   f010441e <cprintf>
f01063bf:	e9 5e 01 00 00       	jmp    f0106522 <mp_init+0x2c1>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f01063c4:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f01063c8:	0f b7 c3             	movzwl %bx,%eax
f01063cb:	8d 04 07             	lea    (%edi,%eax,1),%eax
f01063ce:	e8 ad fd ff ff       	call   f0106180 <sum>
f01063d3:	3a 47 2a             	cmp    0x2a(%edi),%al
f01063d6:	74 11                	je     f01063e9 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01063d8:	c7 04 24 9c 8a 10 f0 	movl   $0xf0108a9c,(%esp)
f01063df:	e8 3a e0 ff ff       	call   f010441e <cprintf>
f01063e4:	e9 39 01 00 00       	jmp    f0106522 <mp_init+0x2c1>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01063e9:	85 ff                	test   %edi,%edi
f01063eb:	0f 84 31 01 00 00    	je     f0106522 <mp_init+0x2c1>
		return;
	ismp = 1;
f01063f1:	c7 05 00 60 22 f0 01 	movl   $0x1,0xf0226000
f01063f8:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01063fb:	8b 47 24             	mov    0x24(%edi),%eax
f01063fe:	a3 00 70 26 f0       	mov    %eax,0xf0267000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106403:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f0106408:	0f 84 99 00 00 00    	je     f01064a7 <mp_init+0x246>
f010640e:	8d 5f 2c             	lea    0x2c(%edi),%ebx
f0106411:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f0106416:	0f b6 03             	movzbl (%ebx),%eax
f0106419:	84 c0                	test   %al,%al
f010641b:	74 06                	je     f0106423 <mp_init+0x1c2>
f010641d:	3c 04                	cmp    $0x4,%al
f010641f:	77 56                	ja     f0106477 <mp_init+0x216>
f0106421:	eb 4f                	jmp    f0106472 <mp_init+0x211>
		case MPPROC:
			proc = (struct mpproc *)p;
f0106423:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f0106425:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f0106429:	74 11                	je     f010643c <mp_init+0x1db>
				bootcpu = &cpus[ncpu];
f010642b:	6b 05 c4 63 22 f0 74 	imul   $0x74,0xf02263c4,%eax
f0106432:	05 20 60 22 f0       	add    $0xf0226020,%eax
f0106437:	a3 c0 63 22 f0       	mov    %eax,0xf02263c0
			if (ncpu < NCPU) {
f010643c:	a1 c4 63 22 f0       	mov    0xf02263c4,%eax
f0106441:	83 f8 07             	cmp    $0x7,%eax
f0106444:	7f 13                	jg     f0106459 <mp_init+0x1f8>
				cpus[ncpu].cpu_id = ncpu;
f0106446:	6b d0 74             	imul   $0x74,%eax,%edx
f0106449:	88 82 20 60 22 f0    	mov    %al,-0xfdd9fe0(%edx)
				ncpu++;
f010644f:	83 c0 01             	add    $0x1,%eax
f0106452:	a3 c4 63 22 f0       	mov    %eax,0xf02263c4
f0106457:	eb 14                	jmp    f010646d <mp_init+0x20c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106459:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f010645d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106461:	c7 04 24 cc 8a 10 f0 	movl   $0xf0108acc,(%esp)
f0106468:	e8 b1 df ff ff       	call   f010441e <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010646d:	83 c3 14             	add    $0x14,%ebx
			continue;
f0106470:	eb 26                	jmp    f0106498 <mp_init+0x237>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106472:	83 c3 08             	add    $0x8,%ebx
			continue;
f0106475:	eb 21                	jmp    f0106498 <mp_init+0x237>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106477:	0f b6 c0             	movzbl %al,%eax
f010647a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010647e:	c7 04 24 f4 8a 10 f0 	movl   $0xf0108af4,(%esp)
f0106485:	e8 94 df ff ff       	call   f010441e <cprintf>
			ismp = 0;
f010648a:	c7 05 00 60 22 f0 00 	movl   $0x0,0xf0226000
f0106491:	00 00 00 
			i = conf->entry;
f0106494:	0f b7 77 22          	movzwl 0x22(%edi),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106498:	83 c6 01             	add    $0x1,%esi
f010649b:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f010649f:	39 f0                	cmp    %esi,%eax
f01064a1:	0f 87 6f ff ff ff    	ja     f0106416 <mp_init+0x1b5>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01064a7:	a1 c0 63 22 f0       	mov    0xf02263c0,%eax
f01064ac:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01064b3:	83 3d 00 60 22 f0 00 	cmpl   $0x0,0xf0226000
f01064ba:	75 22                	jne    f01064de <mp_init+0x27d>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01064bc:	c7 05 c4 63 22 f0 01 	movl   $0x1,0xf02263c4
f01064c3:	00 00 00 
		lapicaddr = 0;
f01064c6:	c7 05 00 70 26 f0 00 	movl   $0x0,0xf0267000
f01064cd:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01064d0:	c7 04 24 14 8b 10 f0 	movl   $0xf0108b14,(%esp)
f01064d7:	e8 42 df ff ff       	call   f010441e <cprintf>
		return;
f01064dc:	eb 44                	jmp    f0106522 <mp_init+0x2c1>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01064de:	8b 15 c4 63 22 f0    	mov    0xf02263c4,%edx
f01064e4:	89 54 24 08          	mov    %edx,0x8(%esp)
f01064e8:	0f b6 00             	movzbl (%eax),%eax
f01064eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064ef:	c7 04 24 9b 8b 10 f0 	movl   $0xf0108b9b,(%esp)
f01064f6:	e8 23 df ff ff       	call   f010441e <cprintf>

	if (mp->imcrp) {
f01064fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01064fe:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106502:	74 1e                	je     f0106522 <mp_init+0x2c1>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106504:	c7 04 24 40 8b 10 f0 	movl   $0xf0108b40,(%esp)
f010650b:	e8 0e df ff ff       	call   f010441e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106510:	ba 22 00 00 00       	mov    $0x22,%edx
f0106515:	b8 70 00 00 00       	mov    $0x70,%eax
f010651a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010651b:	b2 23                	mov    $0x23,%dl
f010651d:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010651e:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106521:	ee                   	out    %al,(%dx)
	}
}
f0106522:	83 c4 2c             	add    $0x2c,%esp
f0106525:	5b                   	pop    %ebx
f0106526:	5e                   	pop    %esi
f0106527:	5f                   	pop    %edi
f0106528:	5d                   	pop    %ebp
f0106529:	c3                   	ret    
	...

f010652c <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010652c:	55                   	push   %ebp
f010652d:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010652f:	c1 e0 02             	shl    $0x2,%eax
f0106532:	03 05 04 70 26 f0    	add    0xf0267004,%eax
f0106538:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010653a:	a1 04 70 26 f0       	mov    0xf0267004,%eax
f010653f:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106542:	5d                   	pop    %ebp
f0106543:	c3                   	ret    

f0106544 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106544:	55                   	push   %ebp
f0106545:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106547:	8b 15 04 70 26 f0    	mov    0xf0267004,%edx
		return lapic[ID] >> 24;
	return 0;
f010654d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
cpunum(void)
{
	if (lapic)
f0106552:	85 d2                	test   %edx,%edx
f0106554:	74 06                	je     f010655c <cpunum+0x18>
		return lapic[ID] >> 24;
f0106556:	8b 42 20             	mov    0x20(%edx),%eax
f0106559:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f010655c:	5d                   	pop    %ebp
f010655d:	c3                   	ret    

f010655e <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010655e:	55                   	push   %ebp
f010655f:	89 e5                	mov    %esp,%ebp
f0106561:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0106564:	a1 00 70 26 f0       	mov    0xf0267000,%eax
f0106569:	85 c0                	test   %eax,%eax
f010656b:	0f 84 1e 01 00 00    	je     f010668f <lapic_init+0x131>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106571:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106578:	00 
f0106579:	89 04 24             	mov    %eax,(%esp)
f010657c:	e8 24 b3 ff ff       	call   f01018a5 <mmio_map_region>
f0106581:	a3 04 70 26 f0       	mov    %eax,0xf0267004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106586:	ba 27 01 00 00       	mov    $0x127,%edx
f010658b:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106590:	e8 97 ff ff ff       	call   f010652c <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106595:	ba 0b 00 00 00       	mov    $0xb,%edx
f010659a:	b8 f8 00 00 00       	mov    $0xf8,%eax
f010659f:	e8 88 ff ff ff       	call   f010652c <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01065a4:	ba 20 00 02 00       	mov    $0x20020,%edx
f01065a9:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01065ae:	e8 79 ff ff ff       	call   f010652c <lapicw>
	lapicw(TICR, 10000000); 
f01065b3:	ba 80 96 98 00       	mov    $0x989680,%edx
f01065b8:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01065bd:	e8 6a ff ff ff       	call   f010652c <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)//mask every cpu other than bootcpu
f01065c2:	e8 7d ff ff ff       	call   f0106544 <cpunum>
f01065c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01065ca:	05 20 60 22 f0       	add    $0xf0226020,%eax
f01065cf:	39 05 c0 63 22 f0    	cmp    %eax,0xf02263c0
f01065d5:	74 0f                	je     f01065e6 <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f01065d7:	ba 00 00 01 00       	mov    $0x10000,%edx
f01065dc:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01065e1:	e8 46 ff ff ff       	call   f010652c <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);//why?
f01065e6:	ba 00 00 01 00       	mov    $0x10000,%edx
f01065eb:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01065f0:	e8 37 ff ff ff       	call   f010652c <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01065f5:	a1 04 70 26 f0       	mov    0xf0267004,%eax
f01065fa:	8b 40 30             	mov    0x30(%eax),%eax
f01065fd:	c1 e8 10             	shr    $0x10,%eax
f0106600:	3c 03                	cmp    $0x3,%al
f0106602:	76 0f                	jbe    f0106613 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0106604:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106609:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010660e:	e8 19 ff ff ff       	call   f010652c <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106613:	ba 33 00 00 00       	mov    $0x33,%edx
f0106618:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010661d:	e8 0a ff ff ff       	call   f010652c <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106622:	ba 00 00 00 00       	mov    $0x0,%edx
f0106627:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010662c:	e8 fb fe ff ff       	call   f010652c <lapicw>
	lapicw(ESR, 0);
f0106631:	ba 00 00 00 00       	mov    $0x0,%edx
f0106636:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010663b:	e8 ec fe ff ff       	call   f010652c <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106640:	ba 00 00 00 00       	mov    $0x0,%edx
f0106645:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010664a:	e8 dd fe ff ff       	call   f010652c <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010664f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106654:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106659:	e8 ce fe ff ff       	call   f010652c <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010665e:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106663:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106668:	e8 bf fe ff ff       	call   f010652c <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010666d:	8b 15 04 70 26 f0    	mov    0xf0267004,%edx
f0106673:	81 c2 00 03 00 00    	add    $0x300,%edx
f0106679:	8b 02                	mov    (%edx),%eax
f010667b:	f6 c4 10             	test   $0x10,%ah
f010667e:	75 f9                	jne    f0106679 <lapic_init+0x11b>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106680:	ba 00 00 00 00       	mov    $0x0,%edx
f0106685:	b8 20 00 00 00       	mov    $0x20,%eax
f010668a:	e8 9d fe ff ff       	call   f010652c <lapicw>
}
f010668f:	c9                   	leave  
f0106690:	c3                   	ret    

f0106691 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106691:	55                   	push   %ebp
f0106692:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106694:	83 3d 04 70 26 f0 00 	cmpl   $0x0,0xf0267004
f010669b:	74 0f                	je     f01066ac <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f010669d:	ba 00 00 00 00       	mov    $0x0,%edx
f01066a2:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01066a7:	e8 80 fe ff ff       	call   f010652c <lapicw>
}
f01066ac:	5d                   	pop    %ebp
f01066ad:	c3                   	ret    

f01066ae <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01066ae:	55                   	push   %ebp
f01066af:	89 e5                	mov    %esp,%ebp
f01066b1:	56                   	push   %esi
f01066b2:	53                   	push   %ebx
f01066b3:	83 ec 10             	sub    $0x10,%esp
f01066b6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01066b9:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f01066bd:	ba 70 00 00 00       	mov    $0x70,%edx
f01066c2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01066c7:	ee                   	out    %al,(%dx)
f01066c8:	b2 71                	mov    $0x71,%dl
f01066ca:	b8 0a 00 00 00       	mov    $0xa,%eax
f01066cf:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01066d0:	83 3d 90 5e 22 f0 00 	cmpl   $0x0,0xf0225e90
f01066d7:	75 24                	jne    f01066fd <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01066d9:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01066e0:	00 
f01066e1:	c7 44 24 08 90 6d 10 	movl   $0xf0106d90,0x8(%esp)
f01066e8:	f0 
f01066e9:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01066f0:	00 
f01066f1:	c7 04 24 b8 8b 10 f0 	movl   $0xf0108bb8,(%esp)
f01066f8:	e8 a0 99 ff ff       	call   f010009d <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01066fd:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106704:	00 00 
	wrv[1] = addr >> 4;
f0106706:	89 f0                	mov    %esi,%eax
f0106708:	c1 e8 04             	shr    $0x4,%eax
f010670b:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106711:	c1 e3 18             	shl    $0x18,%ebx
f0106714:	89 da                	mov    %ebx,%edx
f0106716:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010671b:	e8 0c fe ff ff       	call   f010652c <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106720:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106725:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010672a:	e8 fd fd ff ff       	call   f010652c <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010672f:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106734:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106739:	e8 ee fd ff ff       	call   f010652c <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010673e:	c1 ee 0c             	shr    $0xc,%esi
f0106741:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106747:	89 da                	mov    %ebx,%edx
f0106749:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010674e:	e8 d9 fd ff ff       	call   f010652c <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106753:	89 f2                	mov    %esi,%edx
f0106755:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010675a:	e8 cd fd ff ff       	call   f010652c <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010675f:	89 da                	mov    %ebx,%edx
f0106761:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106766:	e8 c1 fd ff ff       	call   f010652c <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010676b:	89 f2                	mov    %esi,%edx
f010676d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106772:	e8 b5 fd ff ff       	call   f010652c <lapicw>
		microdelay(200);
	}
}
f0106777:	83 c4 10             	add    $0x10,%esp
f010677a:	5b                   	pop    %ebx
f010677b:	5e                   	pop    %esi
f010677c:	5d                   	pop    %ebp
f010677d:	c3                   	ret    

f010677e <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010677e:	55                   	push   %ebp
f010677f:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106781:	8b 55 08             	mov    0x8(%ebp),%edx
f0106784:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010678a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010678f:	e8 98 fd ff ff       	call   f010652c <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106794:	8b 15 04 70 26 f0    	mov    0xf0267004,%edx
f010679a:	81 c2 00 03 00 00    	add    $0x300,%edx
f01067a0:	8b 02                	mov    (%edx),%eax
f01067a2:	f6 c4 10             	test   $0x10,%ah
f01067a5:	75 f9                	jne    f01067a0 <lapic_ipi+0x22>
		;
}
f01067a7:	5d                   	pop    %ebp
f01067a8:	c3                   	ret    
f01067a9:	00 00                	add    %al,(%eax)
	...

f01067ac <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01067ac:	55                   	push   %ebp
f01067ad:	89 e5                	mov    %esp,%ebp
f01067af:	53                   	push   %ebx
f01067b0:	83 ec 04             	sub    $0x4,%esp
f01067b3:	89 c2                	mov    %eax,%edx
	return lock->locked && lock->cpu == thiscpu;
f01067b5:	b8 00 00 00 00       	mov    $0x0,%eax
f01067ba:	83 3a 00             	cmpl   $0x0,(%edx)
f01067bd:	74 18                	je     f01067d7 <holding+0x2b>
f01067bf:	8b 5a 08             	mov    0x8(%edx),%ebx
f01067c2:	e8 7d fd ff ff       	call   f0106544 <cpunum>
f01067c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01067ca:	05 20 60 22 f0       	add    $0xf0226020,%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f01067cf:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f01067d1:	0f 94 c0             	sete   %al
f01067d4:	0f b6 c0             	movzbl %al,%eax
}
f01067d7:	83 c4 04             	add    $0x4,%esp
f01067da:	5b                   	pop    %ebx
f01067db:	5d                   	pop    %ebp
f01067dc:	c3                   	ret    

f01067dd <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01067dd:	55                   	push   %ebp
f01067de:	89 e5                	mov    %esp,%ebp
f01067e0:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01067e3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01067e9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01067ec:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01067ef:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01067f6:	5d                   	pop    %ebp
f01067f7:	c3                   	ret    

f01067f8 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01067f8:	55                   	push   %ebp
f01067f9:	89 e5                	mov    %esp,%ebp
f01067fb:	53                   	push   %ebx
f01067fc:	83 ec 24             	sub    $0x24,%esp
f01067ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106802:	89 d8                	mov    %ebx,%eax
f0106804:	e8 a3 ff ff ff       	call   f01067ac <holding>
f0106809:	85 c0                	test   %eax,%eax
f010680b:	75 12                	jne    f010681f <spin_lock+0x27>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010680d:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010680f:	b0 01                	mov    $0x1,%al
f0106811:	f0 87 03             	lock xchg %eax,(%ebx)
f0106814:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106819:	85 c0                	test   %eax,%eax
f010681b:	75 2e                	jne    f010684b <spin_lock+0x53>
f010681d:	eb 37                	jmp    f0106856 <spin_lock+0x5e>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010681f:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106822:	e8 1d fd ff ff       	call   f0106544 <cpunum>
f0106827:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f010682b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010682f:	c7 44 24 08 c8 8b 10 	movl   $0xf0108bc8,0x8(%esp)
f0106836:	f0 
f0106837:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f010683e:	00 
f010683f:	c7 04 24 2c 8c 10 f0 	movl   $0xf0108c2c,(%esp)
f0106846:	e8 52 98 ff ff       	call   f010009d <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010684b:	f3 90                	pause  
f010684d:	89 c8                	mov    %ecx,%eax
f010684f:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106852:	85 c0                	test   %eax,%eax
f0106854:	75 f5                	jne    f010684b <spin_lock+0x53>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106856:	e8 e9 fc ff ff       	call   f0106544 <cpunum>
f010685b:	6b c0 74             	imul   $0x74,%eax,%eax
f010685e:	05 20 60 22 f0       	add    $0xf0226020,%eax
f0106863:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106866:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0106869:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010686b:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0106870:	77 34                	ja     f01068a6 <spin_lock+0xae>
f0106872:	eb 2b                	jmp    f010689f <spin_lock+0xa7>
f0106874:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010687a:	76 12                	jbe    f010688e <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f010687c:	8b 5a 04             	mov    0x4(%edx),%ebx
f010687f:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106882:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106884:	83 c0 01             	add    $0x1,%eax
f0106887:	83 f8 0a             	cmp    $0xa,%eax
f010688a:	75 e8                	jne    f0106874 <spin_lock+0x7c>
f010688c:	eb 27                	jmp    f01068b5 <spin_lock+0xbd>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010688e:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106895:	83 c0 01             	add    $0x1,%eax
f0106898:	83 f8 09             	cmp    $0x9,%eax
f010689b:	7e f1                	jle    f010688e <spin_lock+0x96>
f010689d:	eb 16                	jmp    f01068b5 <spin_lock+0xbd>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010689f:	b8 00 00 00 00       	mov    $0x0,%eax
f01068a4:	eb e8                	jmp    f010688e <spin_lock+0x96>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01068a6:	8b 50 04             	mov    0x4(%eax),%edx
f01068a9:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01068ac:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01068ae:	b8 01 00 00 00       	mov    $0x1,%eax
f01068b3:	eb bf                	jmp    f0106874 <spin_lock+0x7c>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01068b5:	83 c4 24             	add    $0x24,%esp
f01068b8:	5b                   	pop    %ebx
f01068b9:	5d                   	pop    %ebp
f01068ba:	c3                   	ret    

f01068bb <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01068bb:	55                   	push   %ebp
f01068bc:	89 e5                	mov    %esp,%ebp
f01068be:	83 ec 78             	sub    $0x78,%esp
f01068c1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01068c4:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01068c7:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01068ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01068cd:	89 d8                	mov    %ebx,%eax
f01068cf:	e8 d8 fe ff ff       	call   f01067ac <holding>
f01068d4:	85 c0                	test   %eax,%eax
f01068d6:	0f 85 d5 00 00 00    	jne    f01069b1 <spin_unlock+0xf6>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01068dc:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01068e3:	00 
f01068e4:	8d 43 0c             	lea    0xc(%ebx),%eax
f01068e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01068eb:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01068ee:	89 04 24             	mov    %eax,(%esp)
f01068f1:	e8 1a f6 ff ff       	call   f0105f10 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01068f6:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01068f9:	0f b6 30             	movzbl (%eax),%esi
f01068fc:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01068ff:	e8 40 fc ff ff       	call   f0106544 <cpunum>
f0106904:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106908:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010690c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106910:	c7 04 24 f4 8b 10 f0 	movl   $0xf0108bf4,(%esp)
f0106917:	e8 02 db ff ff       	call   f010441e <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010691c:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010691f:	85 c0                	test   %eax,%eax
f0106921:	74 72                	je     f0106995 <spin_unlock+0xda>
f0106923:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106926:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106929:	8d 75 d0             	lea    -0x30(%ebp),%esi
f010692c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106930:	89 04 24             	mov    %eax,(%esp)
f0106933:	e8 ea e9 ff ff       	call   f0105322 <debuginfo_eip>
f0106938:	85 c0                	test   %eax,%eax
f010693a:	78 39                	js     f0106975 <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010693c:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010693e:	89 c2                	mov    %eax,%edx
f0106940:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106943:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106947:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010694a:	89 54 24 14          	mov    %edx,0x14(%esp)
f010694e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106951:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106955:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106958:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010695c:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010695f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106963:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106967:	c7 04 24 3c 8c 10 f0 	movl   $0xf0108c3c,(%esp)
f010696e:	e8 ab da ff ff       	call   f010441e <cprintf>
f0106973:	eb 12                	jmp    f0106987 <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106975:	8b 03                	mov    (%ebx),%eax
f0106977:	89 44 24 04          	mov    %eax,0x4(%esp)
f010697b:	c7 04 24 53 8c 10 f0 	movl   $0xf0108c53,(%esp)
f0106982:	e8 97 da ff ff       	call   f010441e <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106987:	39 fb                	cmp    %edi,%ebx
f0106989:	74 0a                	je     f0106995 <spin_unlock+0xda>
f010698b:	8b 43 04             	mov    0x4(%ebx),%eax
f010698e:	83 c3 04             	add    $0x4,%ebx
f0106991:	85 c0                	test   %eax,%eax
f0106993:	75 97                	jne    f010692c <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106995:	c7 44 24 08 5b 8c 10 	movl   $0xf0108c5b,0x8(%esp)
f010699c:	f0 
f010699d:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f01069a4:	00 
f01069a5:	c7 04 24 2c 8c 10 f0 	movl   $0xf0108c2c,(%esp)
f01069ac:	e8 ec 96 ff ff       	call   f010009d <_panic>
	}

	lk->pcs[0] = 0;
f01069b1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f01069b8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01069bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01069c4:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f01069c7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01069ca:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01069cd:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01069d0:	89 ec                	mov    %ebp,%esp
f01069d2:	5d                   	pop    %ebp
f01069d3:	c3                   	ret    
	...

f01069e0 <__udivdi3>:
f01069e0:	55                   	push   %ebp
f01069e1:	89 e5                	mov    %esp,%ebp
f01069e3:	57                   	push   %edi
f01069e4:	56                   	push   %esi
f01069e5:	83 ec 10             	sub    $0x10,%esp
f01069e8:	8b 75 14             	mov    0x14(%ebp),%esi
f01069eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01069ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01069f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01069f4:	85 f6                	test   %esi,%esi
f01069f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01069f9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01069fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01069ff:	75 2f                	jne    f0106a30 <__udivdi3+0x50>
f0106a01:	39 f9                	cmp    %edi,%ecx
f0106a03:	77 5b                	ja     f0106a60 <__udivdi3+0x80>
f0106a05:	85 c9                	test   %ecx,%ecx
f0106a07:	75 0b                	jne    f0106a14 <__udivdi3+0x34>
f0106a09:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a0e:	31 d2                	xor    %edx,%edx
f0106a10:	f7 f1                	div    %ecx
f0106a12:	89 c1                	mov    %eax,%ecx
f0106a14:	89 f8                	mov    %edi,%eax
f0106a16:	31 d2                	xor    %edx,%edx
f0106a18:	f7 f1                	div    %ecx
f0106a1a:	89 c7                	mov    %eax,%edi
f0106a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106a1f:	f7 f1                	div    %ecx
f0106a21:	89 fa                	mov    %edi,%edx
f0106a23:	83 c4 10             	add    $0x10,%esp
f0106a26:	5e                   	pop    %esi
f0106a27:	5f                   	pop    %edi
f0106a28:	5d                   	pop    %ebp
f0106a29:	c3                   	ret    
f0106a2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106a30:	31 d2                	xor    %edx,%edx
f0106a32:	31 c0                	xor    %eax,%eax
f0106a34:	39 fe                	cmp    %edi,%esi
f0106a36:	77 eb                	ja     f0106a23 <__udivdi3+0x43>
f0106a38:	0f bd d6             	bsr    %esi,%edx
f0106a3b:	83 f2 1f             	xor    $0x1f,%edx
f0106a3e:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0106a41:	75 2d                	jne    f0106a70 <__udivdi3+0x90>
f0106a43:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0106a46:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
f0106a49:	76 06                	jbe    f0106a51 <__udivdi3+0x71>
f0106a4b:	39 fe                	cmp    %edi,%esi
f0106a4d:	89 c2                	mov    %eax,%edx
f0106a4f:	73 d2                	jae    f0106a23 <__udivdi3+0x43>
f0106a51:	31 d2                	xor    %edx,%edx
f0106a53:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a58:	eb c9                	jmp    f0106a23 <__udivdi3+0x43>
f0106a5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106a60:	89 fa                	mov    %edi,%edx
f0106a62:	f7 f1                	div    %ecx
f0106a64:	31 d2                	xor    %edx,%edx
f0106a66:	83 c4 10             	add    $0x10,%esp
f0106a69:	5e                   	pop    %esi
f0106a6a:	5f                   	pop    %edi
f0106a6b:	5d                   	pop    %ebp
f0106a6c:	c3                   	ret    
f0106a6d:	8d 76 00             	lea    0x0(%esi),%esi
f0106a70:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0106a74:	b8 20 00 00 00       	mov    $0x20,%eax
f0106a79:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106a7c:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0106a7f:	d3 e6                	shl    %cl,%esi
f0106a81:	89 c1                	mov    %eax,%ecx
f0106a83:	d3 ea                	shr    %cl,%edx
f0106a85:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0106a89:	09 f2                	or     %esi,%edx
f0106a8b:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0106a8e:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0106a91:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106a94:	d3 e2                	shl    %cl,%edx
f0106a96:	89 c1                	mov    %eax,%ecx
f0106a98:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0106a9b:	89 fa                	mov    %edi,%edx
f0106a9d:	d3 ea                	shr    %cl,%edx
f0106a9f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0106aa3:	d3 e7                	shl    %cl,%edi
f0106aa5:	89 c1                	mov    %eax,%ecx
f0106aa7:	d3 ee                	shr    %cl,%esi
f0106aa9:	09 fe                	or     %edi,%esi
f0106aab:	89 f0                	mov    %esi,%eax
f0106aad:	f7 75 e8             	divl   -0x18(%ebp)
f0106ab0:	89 d7                	mov    %edx,%edi
f0106ab2:	89 c6                	mov    %eax,%esi
f0106ab4:	f7 65 f0             	mull   -0x10(%ebp)
f0106ab7:	39 d7                	cmp    %edx,%edi
f0106ab9:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0106abc:	72 22                	jb     f0106ae0 <__udivdi3+0x100>
f0106abe:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0106ac1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0106ac5:	d3 e2                	shl    %cl,%edx
f0106ac7:	39 c2                	cmp    %eax,%edx
f0106ac9:	73 05                	jae    f0106ad0 <__udivdi3+0xf0>
f0106acb:	3b 7d f0             	cmp    -0x10(%ebp),%edi
f0106ace:	74 10                	je     f0106ae0 <__udivdi3+0x100>
f0106ad0:	89 f0                	mov    %esi,%eax
f0106ad2:	31 d2                	xor    %edx,%edx
f0106ad4:	e9 4a ff ff ff       	jmp    f0106a23 <__udivdi3+0x43>
f0106ad9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106ae0:	8d 46 ff             	lea    -0x1(%esi),%eax
f0106ae3:	31 d2                	xor    %edx,%edx
f0106ae5:	83 c4 10             	add    $0x10,%esp
f0106ae8:	5e                   	pop    %esi
f0106ae9:	5f                   	pop    %edi
f0106aea:	5d                   	pop    %ebp
f0106aeb:	c3                   	ret    
f0106aec:	00 00                	add    %al,(%eax)
	...

f0106af0 <__umoddi3>:
f0106af0:	55                   	push   %ebp
f0106af1:	89 e5                	mov    %esp,%ebp
f0106af3:	57                   	push   %edi
f0106af4:	56                   	push   %esi
f0106af5:	83 ec 20             	sub    $0x20,%esp
f0106af8:	8b 7d 14             	mov    0x14(%ebp),%edi
f0106afb:	8b 45 08             	mov    0x8(%ebp),%eax
f0106afe:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0106b01:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106b04:	85 ff                	test   %edi,%edi
f0106b06:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106b09:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0106b0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106b0f:	89 f2                	mov    %esi,%edx
f0106b11:	75 15                	jne    f0106b28 <__umoddi3+0x38>
f0106b13:	39 f1                	cmp    %esi,%ecx
f0106b15:	76 41                	jbe    f0106b58 <__umoddi3+0x68>
f0106b17:	f7 f1                	div    %ecx
f0106b19:	89 d0                	mov    %edx,%eax
f0106b1b:	31 d2                	xor    %edx,%edx
f0106b1d:	83 c4 20             	add    $0x20,%esp
f0106b20:	5e                   	pop    %esi
f0106b21:	5f                   	pop    %edi
f0106b22:	5d                   	pop    %ebp
f0106b23:	c3                   	ret    
f0106b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106b28:	39 f7                	cmp    %esi,%edi
f0106b2a:	77 4c                	ja     f0106b78 <__umoddi3+0x88>
f0106b2c:	0f bd c7             	bsr    %edi,%eax
f0106b2f:	83 f0 1f             	xor    $0x1f,%eax
f0106b32:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106b35:	75 51                	jne    f0106b88 <__umoddi3+0x98>
f0106b37:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0106b3a:	0f 87 e8 00 00 00    	ja     f0106c28 <__umoddi3+0x138>
f0106b40:	89 f2                	mov    %esi,%edx
f0106b42:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0106b45:	29 ce                	sub    %ecx,%esi
f0106b47:	19 fa                	sbb    %edi,%edx
f0106b49:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0106b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106b4f:	83 c4 20             	add    $0x20,%esp
f0106b52:	5e                   	pop    %esi
f0106b53:	5f                   	pop    %edi
f0106b54:	5d                   	pop    %ebp
f0106b55:	c3                   	ret    
f0106b56:	66 90                	xchg   %ax,%ax
f0106b58:	85 c9                	test   %ecx,%ecx
f0106b5a:	75 0b                	jne    f0106b67 <__umoddi3+0x77>
f0106b5c:	b8 01 00 00 00       	mov    $0x1,%eax
f0106b61:	31 d2                	xor    %edx,%edx
f0106b63:	f7 f1                	div    %ecx
f0106b65:	89 c1                	mov    %eax,%ecx
f0106b67:	89 f0                	mov    %esi,%eax
f0106b69:	31 d2                	xor    %edx,%edx
f0106b6b:	f7 f1                	div    %ecx
f0106b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106b70:	eb a5                	jmp    f0106b17 <__umoddi3+0x27>
f0106b72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106b78:	89 f2                	mov    %esi,%edx
f0106b7a:	83 c4 20             	add    $0x20,%esp
f0106b7d:	5e                   	pop    %esi
f0106b7e:	5f                   	pop    %edi
f0106b7f:	5d                   	pop    %ebp
f0106b80:	c3                   	ret    
f0106b81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106b88:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106b8c:	89 f2                	mov    %esi,%edx
f0106b8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106b91:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
f0106b98:	29 45 f0             	sub    %eax,-0x10(%ebp)
f0106b9b:	d3 e7                	shl    %cl,%edi
f0106b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106ba0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106ba4:	d3 e8                	shr    %cl,%eax
f0106ba6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106baa:	09 f8                	or     %edi,%eax
f0106bac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106bb2:	d3 e0                	shl    %cl,%eax
f0106bb4:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106bb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106bbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106bbe:	d3 ea                	shr    %cl,%edx
f0106bc0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106bc4:	d3 e6                	shl    %cl,%esi
f0106bc6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106bca:	d3 e8                	shr    %cl,%eax
f0106bcc:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106bd0:	09 f0                	or     %esi,%eax
f0106bd2:	8b 75 e8             	mov    -0x18(%ebp),%esi
f0106bd5:	f7 75 e4             	divl   -0x1c(%ebp)
f0106bd8:	d3 e6                	shl    %cl,%esi
f0106bda:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0106bdd:	89 d6                	mov    %edx,%esi
f0106bdf:	f7 65 f4             	mull   -0xc(%ebp)
f0106be2:	89 d7                	mov    %edx,%edi
f0106be4:	89 c2                	mov    %eax,%edx
f0106be6:	39 fe                	cmp    %edi,%esi
f0106be8:	89 f9                	mov    %edi,%ecx
f0106bea:	72 30                	jb     f0106c1c <__umoddi3+0x12c>
f0106bec:	39 45 e8             	cmp    %eax,-0x18(%ebp)
f0106bef:	72 27                	jb     f0106c18 <__umoddi3+0x128>
f0106bf1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106bf4:	29 d0                	sub    %edx,%eax
f0106bf6:	19 ce                	sbb    %ecx,%esi
f0106bf8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106bfc:	89 f2                	mov    %esi,%edx
f0106bfe:	d3 e8                	shr    %cl,%eax
f0106c00:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106c04:	d3 e2                	shl    %cl,%edx
f0106c06:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106c0a:	09 d0                	or     %edx,%eax
f0106c0c:	89 f2                	mov    %esi,%edx
f0106c0e:	d3 ea                	shr    %cl,%edx
f0106c10:	83 c4 20             	add    $0x20,%esp
f0106c13:	5e                   	pop    %esi
f0106c14:	5f                   	pop    %edi
f0106c15:	5d                   	pop    %ebp
f0106c16:	c3                   	ret    
f0106c17:	90                   	nop
f0106c18:	39 fe                	cmp    %edi,%esi
f0106c1a:	75 d5                	jne    f0106bf1 <__umoddi3+0x101>
f0106c1c:	89 f9                	mov    %edi,%ecx
f0106c1e:	89 c2                	mov    %eax,%edx
f0106c20:	2b 55 f4             	sub    -0xc(%ebp),%edx
f0106c23:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0106c26:	eb c9                	jmp    f0106bf1 <__umoddi3+0x101>
f0106c28:	39 f7                	cmp    %esi,%edi
f0106c2a:	0f 82 10 ff ff ff    	jb     f0106b40 <__umoddi3+0x50>
f0106c30:	e9 17 ff ff ff       	jmp    f0106b4c <__umoddi3+0x5c>
