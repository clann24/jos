
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
f0100015:	b8 00 60 11 00       	mov    $0x116000,%eax
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
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5f 00 00 00       	call   f010009d <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
int backtrace(int argc, char **argv, struct Trapframe *tf);

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
f010004e:	c7 04 24 00 40 10 f0 	movl   $0xf0104000,(%esp)
f0100055:	e8 0c 2f 00 00       	call   f0102f66 <cprintf>
	if (x > 0)
f010005a:	85 db                	test   %ebx,%ebx
f010005c:	7e 0d                	jle    f010006b <test_backtrace+0x2b>
		test_backtrace(x-1);
f010005e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100061:	89 04 24             	mov    %eax,(%esp)
f0100064:	e8 d7 ff ff ff       	call   f0100040 <test_backtrace>
f0100069:	eb 1c                	jmp    f0100087 <test_backtrace+0x47>
	else
		backtrace(0, 0, 0);
f010006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100072:	00 
f0100073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010007a:	00 
f010007b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100082:	e8 d9 07 00 00       	call   f0100860 <backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 1c 40 10 f0 	movl   $0xf010401c,(%esp)
f0100092:	e8 cf 2e 00 00       	call   f0102f66 <cprintf>
}
f0100097:	83 c4 14             	add    $0x14,%esp
f010009a:	5b                   	pop    %ebx
f010009b:	5d                   	pop    %ebp
f010009c:	c3                   	ret    

f010009d <i386_init>:

void
i386_init(void)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a3:	b8 54 89 11 f0       	mov    $0xf0118954,%eax
f01000a8:	2d 00 83 11 f0       	sub    $0xf0118300,%eax
f01000ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000b8:	00 
f01000b9:	c7 04 24 00 83 11 f0 	movl   $0xf0118300,(%esp)
f01000c0:	e8 7c 3a 00 00       	call   f0103b41 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 b2 04 00 00       	call   f010057c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 37 40 10 f0 	movl   $0xf0104037,(%esp)
f01000d9:	e8 88 2e 00 00       	call   f0102f66 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000de:	e8 46 12 00 00       	call   f0101329 <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000ea:	e8 2a 08 00 00       	call   f0100919 <monitor>
f01000ef:	eb f2                	jmp    f01000e3 <i386_init+0x46>

f01000f1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f1:	55                   	push   %ebp
f01000f2:	89 e5                	mov    %esp,%ebp
f01000f4:	56                   	push   %esi
f01000f5:	53                   	push   %ebx
f01000f6:	83 ec 10             	sub    $0x10,%esp
f01000f9:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000fc:	83 3d 40 89 11 f0 00 	cmpl   $0x0,0xf0118940
f0100103:	75 3d                	jne    f0100142 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f0100105:	89 35 40 89 11 f0    	mov    %esi,0xf0118940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010010b:	fa                   	cli    
f010010c:	fc                   	cld    

	va_start(ap, fmt);
f010010d:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100110:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100113:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100117:	8b 45 08             	mov    0x8(%ebp),%eax
f010011a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010011e:	c7 04 24 52 40 10 f0 	movl   $0xf0104052,(%esp)
f0100125:	e8 3c 2e 00 00       	call   f0102f66 <cprintf>
	vcprintf(fmt, ap);
f010012a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010012e:	89 34 24             	mov    %esi,(%esp)
f0100131:	e8 fd 2d 00 00       	call   f0102f33 <vcprintf>
	cprintf("\n");
f0100136:	c7 04 24 da 4f 10 f0 	movl   $0xf0104fda,(%esp)
f010013d:	e8 24 2e 00 00       	call   f0102f66 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100142:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100149:	e8 cb 07 00 00       	call   f0100919 <monitor>
f010014e:	eb f2                	jmp    f0100142 <_panic+0x51>

f0100150 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100150:	55                   	push   %ebp
f0100151:	89 e5                	mov    %esp,%ebp
f0100153:	53                   	push   %ebx
f0100154:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100157:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010015a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010015d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100161:	8b 45 08             	mov    0x8(%ebp),%eax
f0100164:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100168:	c7 04 24 6a 40 10 f0 	movl   $0xf010406a,(%esp)
f010016f:	e8 f2 2d 00 00       	call   f0102f66 <cprintf>
	vcprintf(fmt, ap);
f0100174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100178:	8b 45 10             	mov    0x10(%ebp),%eax
f010017b:	89 04 24             	mov    %eax,(%esp)
f010017e:	e8 b0 2d 00 00       	call   f0102f33 <vcprintf>
	cprintf("\n");
f0100183:	c7 04 24 da 4f 10 f0 	movl   $0xf0104fda,(%esp)
f010018a:	e8 d7 2d 00 00       	call   f0102f66 <cprintf>
	va_end(ap);
}
f010018f:	83 c4 14             	add    $0x14,%esp
f0100192:	5b                   	pop    %ebx
f0100193:	5d                   	pop    %ebp
f0100194:	c3                   	ret    
	...

f01001a0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001a3:	ba 84 00 00 00       	mov    $0x84,%edx
f01001a8:	ec                   	in     (%dx),%al
f01001a9:	ec                   	in     (%dx),%al
f01001aa:	ec                   	in     (%dx),%al
f01001ab:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01001ac:	5d                   	pop    %ebp
f01001ad:	c3                   	ret    

f01001ae <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001ae:	55                   	push   %ebp
f01001af:	89 e5                	mov    %esp,%ebp
f01001b1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001b6:	ec                   	in     (%dx),%al
f01001b7:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001be:	f6 c2 01             	test   $0x1,%dl
f01001c1:	74 09                	je     f01001cc <serial_proc_data+0x1e>
f01001c3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001c8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001c9:	0f b6 c0             	movzbl %al,%eax
}
f01001cc:	5d                   	pop    %ebp
f01001cd:	c3                   	ret    

f01001ce <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ce:	55                   	push   %ebp
f01001cf:	89 e5                	mov    %esp,%ebp
f01001d1:	53                   	push   %ebx
f01001d2:	83 ec 04             	sub    $0x4,%esp
f01001d5:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001d7:	eb 25                	jmp    f01001fe <cons_intr+0x30>
		if (c == 0)
f01001d9:	85 c0                	test   %eax,%eax
f01001db:	74 21                	je     f01001fe <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f01001dd:	8b 15 24 85 11 f0    	mov    0xf0118524,%edx
f01001e3:	88 82 20 83 11 f0    	mov    %al,-0xfee7ce0(%edx)
f01001e9:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01001ec:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01001f1:	ba 00 00 00 00       	mov    $0x0,%edx
f01001f6:	0f 44 c2             	cmove  %edx,%eax
f01001f9:	a3 24 85 11 f0       	mov    %eax,0xf0118524
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001fe:	ff d3                	call   *%ebx
f0100200:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100203:	75 d4                	jne    f01001d9 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100205:	83 c4 04             	add    $0x4,%esp
f0100208:	5b                   	pop    %ebx
f0100209:	5d                   	pop    %ebp
f010020a:	c3                   	ret    

f010020b <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010020b:	55                   	push   %ebp
f010020c:	89 e5                	mov    %esp,%ebp
f010020e:	57                   	push   %edi
f010020f:	56                   	push   %esi
f0100210:	53                   	push   %ebx
f0100211:	83 ec 2c             	sub    $0x2c,%esp
f0100214:	89 c7                	mov    %eax,%edi
f0100216:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010021b:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010021c:	a8 20                	test   $0x20,%al
f010021e:	75 1b                	jne    f010023b <cons_putc+0x30>
f0100220:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100225:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010022a:	e8 71 ff ff ff       	call   f01001a0 <delay>
f010022f:	89 f2                	mov    %esi,%edx
f0100231:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100232:	a8 20                	test   $0x20,%al
f0100234:	75 05                	jne    f010023b <cons_putc+0x30>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100236:	83 eb 01             	sub    $0x1,%ebx
f0100239:	75 ef                	jne    f010022a <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010023b:	89 fa                	mov    %edi,%edx
f010023d:	89 f8                	mov    %edi,%eax
f010023f:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100242:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100247:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100248:	b2 79                	mov    $0x79,%dl
f010024a:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010024b:	84 c0                	test   %al,%al
f010024d:	78 21                	js     f0100270 <cons_putc+0x65>
f010024f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100254:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100259:	e8 42 ff ff ff       	call   f01001a0 <delay>
f010025e:	89 f2                	mov    %esi,%edx
f0100260:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100261:	84 c0                	test   %al,%al
f0100263:	78 0b                	js     f0100270 <cons_putc+0x65>
f0100265:	83 c3 01             	add    $0x1,%ebx
f0100268:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f010026e:	75 e9                	jne    f0100259 <cons_putc+0x4e>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100270:	ba 78 03 00 00       	mov    $0x378,%edx
f0100275:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100279:	ee                   	out    %al,(%dx)
f010027a:	b2 7a                	mov    $0x7a,%dl
f010027c:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100281:	ee                   	out    %al,(%dx)
f0100282:	b8 08 00 00 00       	mov    $0x8,%eax
f0100287:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!csa) csa = 0x0700;
f0100288:	83 3d 44 89 11 f0 00 	cmpl   $0x0,0xf0118944
f010028f:	75 0a                	jne    f010029b <cons_putc+0x90>
f0100291:	c7 05 44 89 11 f0 00 	movl   $0x700,0xf0118944
f0100298:	07 00 00 
	if (!(c & ~0xFF))
f010029b:	89 fa                	mov    %edi,%edx
f010029d:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= csa;
f01002a3:	89 f8                	mov    %edi,%eax
f01002a5:	0b 05 44 89 11 f0    	or     0xf0118944,%eax
f01002ab:	85 d2                	test   %edx,%edx
f01002ad:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01002b0:	89 f8                	mov    %edi,%eax
f01002b2:	25 ff 00 00 00       	and    $0xff,%eax
f01002b7:	83 f8 09             	cmp    $0x9,%eax
f01002ba:	74 7c                	je     f0100338 <cons_putc+0x12d>
f01002bc:	83 f8 09             	cmp    $0x9,%eax
f01002bf:	7f 0b                	jg     f01002cc <cons_putc+0xc1>
f01002c1:	83 f8 08             	cmp    $0x8,%eax
f01002c4:	0f 85 a2 00 00 00    	jne    f010036c <cons_putc+0x161>
f01002ca:	eb 16                	jmp    f01002e2 <cons_putc+0xd7>
f01002cc:	83 f8 0a             	cmp    $0xa,%eax
f01002cf:	90                   	nop
f01002d0:	74 40                	je     f0100312 <cons_putc+0x107>
f01002d2:	83 f8 0d             	cmp    $0xd,%eax
f01002d5:	0f 85 91 00 00 00    	jne    f010036c <cons_putc+0x161>
f01002db:	90                   	nop
f01002dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01002e0:	eb 38                	jmp    f010031a <cons_putc+0x10f>
	case '\b':
		if (crt_pos > 0) {
f01002e2:	0f b7 05 00 83 11 f0 	movzwl 0xf0118300,%eax
f01002e9:	66 85 c0             	test   %ax,%ax
f01002ec:	0f 84 e4 00 00 00    	je     f01003d6 <cons_putc+0x1cb>
			crt_pos--;
f01002f2:	83 e8 01             	sub    $0x1,%eax
f01002f5:	66 a3 00 83 11 f0    	mov    %ax,0xf0118300
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01002fb:	0f b7 c0             	movzwl %ax,%eax
f01002fe:	66 81 e7 00 ff       	and    $0xff00,%di
f0100303:	83 cf 20             	or     $0x20,%edi
f0100306:	8b 15 04 83 11 f0    	mov    0xf0118304,%edx
f010030c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100310:	eb 77                	jmp    f0100389 <cons_putc+0x17e>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100312:	66 83 05 00 83 11 f0 	addw   $0x50,0xf0118300
f0100319:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010031a:	0f b7 05 00 83 11 f0 	movzwl 0xf0118300,%eax
f0100321:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100327:	c1 e8 16             	shr    $0x16,%eax
f010032a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010032d:	c1 e0 04             	shl    $0x4,%eax
f0100330:	66 a3 00 83 11 f0    	mov    %ax,0xf0118300
f0100336:	eb 51                	jmp    f0100389 <cons_putc+0x17e>
		break;
	case '\t':
		cons_putc(' ');
f0100338:	b8 20 00 00 00       	mov    $0x20,%eax
f010033d:	e8 c9 fe ff ff       	call   f010020b <cons_putc>
		cons_putc(' ');
f0100342:	b8 20 00 00 00       	mov    $0x20,%eax
f0100347:	e8 bf fe ff ff       	call   f010020b <cons_putc>
		cons_putc(' ');
f010034c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100351:	e8 b5 fe ff ff       	call   f010020b <cons_putc>
		cons_putc(' ');
f0100356:	b8 20 00 00 00       	mov    $0x20,%eax
f010035b:	e8 ab fe ff ff       	call   f010020b <cons_putc>
		cons_putc(' ');
f0100360:	b8 20 00 00 00       	mov    $0x20,%eax
f0100365:	e8 a1 fe ff ff       	call   f010020b <cons_putc>
f010036a:	eb 1d                	jmp    f0100389 <cons_putc+0x17e>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010036c:	0f b7 05 00 83 11 f0 	movzwl 0xf0118300,%eax
f0100373:	0f b7 c8             	movzwl %ax,%ecx
f0100376:	8b 15 04 83 11 f0    	mov    0xf0118304,%edx
f010037c:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f0100380:	83 c0 01             	add    $0x1,%eax
f0100383:	66 a3 00 83 11 f0    	mov    %ax,0xf0118300
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100389:	66 81 3d 00 83 11 f0 	cmpw   $0x7cf,0xf0118300
f0100390:	cf 07 
f0100392:	76 42                	jbe    f01003d6 <cons_putc+0x1cb>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100394:	a1 04 83 11 f0       	mov    0xf0118304,%eax
f0100399:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01003a0:	00 
f01003a1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01003a7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01003ab:	89 04 24             	mov    %eax,(%esp)
f01003ae:	e8 ed 37 00 00       	call   f0103ba0 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01003b3:	8b 15 04 83 11 f0    	mov    0xf0118304,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01003b9:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01003be:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01003c4:	83 c0 01             	add    $0x1,%eax
f01003c7:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01003cc:	75 f0                	jne    f01003be <cons_putc+0x1b3>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01003ce:	66 83 2d 00 83 11 f0 	subw   $0x50,0xf0118300
f01003d5:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01003d6:	8b 0d 08 83 11 f0    	mov    0xf0118308,%ecx
f01003dc:	b8 0e 00 00 00       	mov    $0xe,%eax
f01003e1:	89 ca                	mov    %ecx,%edx
f01003e3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003e4:	0f b7 35 00 83 11 f0 	movzwl 0xf0118300,%esi
f01003eb:	8d 59 01             	lea    0x1(%ecx),%ebx
f01003ee:	89 f0                	mov    %esi,%eax
f01003f0:	66 c1 e8 08          	shr    $0x8,%ax
f01003f4:	89 da                	mov    %ebx,%edx
f01003f6:	ee                   	out    %al,(%dx)
f01003f7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01003fc:	89 ca                	mov    %ecx,%edx
f01003fe:	ee                   	out    %al,(%dx)
f01003ff:	89 f0                	mov    %esi,%eax
f0100401:	89 da                	mov    %ebx,%edx
f0100403:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100404:	83 c4 2c             	add    $0x2c,%esp
f0100407:	5b                   	pop    %ebx
f0100408:	5e                   	pop    %esi
f0100409:	5f                   	pop    %edi
f010040a:	5d                   	pop    %ebp
f010040b:	c3                   	ret    

f010040c <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010040c:	55                   	push   %ebp
f010040d:	89 e5                	mov    %esp,%ebp
f010040f:	53                   	push   %ebx
f0100410:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100413:	ba 64 00 00 00       	mov    $0x64,%edx
f0100418:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100419:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010041e:	a8 01                	test   $0x1,%al
f0100420:	0f 84 de 00 00 00    	je     f0100504 <kbd_proc_data+0xf8>
f0100426:	b2 60                	mov    $0x60,%dl
f0100428:	ec                   	in     (%dx),%al
f0100429:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010042b:	3c e0                	cmp    $0xe0,%al
f010042d:	75 11                	jne    f0100440 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f010042f:	83 0d 28 85 11 f0 40 	orl    $0x40,0xf0118528
		return 0;
f0100436:	bb 00 00 00 00       	mov    $0x0,%ebx
f010043b:	e9 c4 00 00 00       	jmp    f0100504 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f0100440:	84 c0                	test   %al,%al
f0100442:	79 37                	jns    f010047b <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100444:	8b 0d 28 85 11 f0    	mov    0xf0118528,%ecx
f010044a:	89 cb                	mov    %ecx,%ebx
f010044c:	83 e3 40             	and    $0x40,%ebx
f010044f:	83 e0 7f             	and    $0x7f,%eax
f0100452:	85 db                	test   %ebx,%ebx
f0100454:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100457:	0f b6 d2             	movzbl %dl,%edx
f010045a:	0f b6 82 c0 40 10 f0 	movzbl -0xfefbf40(%edx),%eax
f0100461:	83 c8 40             	or     $0x40,%eax
f0100464:	0f b6 c0             	movzbl %al,%eax
f0100467:	f7 d0                	not    %eax
f0100469:	21 c1                	and    %eax,%ecx
f010046b:	89 0d 28 85 11 f0    	mov    %ecx,0xf0118528
		return 0;
f0100471:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100476:	e9 89 00 00 00       	jmp    f0100504 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f010047b:	8b 0d 28 85 11 f0    	mov    0xf0118528,%ecx
f0100481:	f6 c1 40             	test   $0x40,%cl
f0100484:	74 0e                	je     f0100494 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100486:	89 c2                	mov    %eax,%edx
f0100488:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010048b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010048e:	89 0d 28 85 11 f0    	mov    %ecx,0xf0118528
	}

	shift |= shiftcode[data];
f0100494:	0f b6 d2             	movzbl %dl,%edx
f0100497:	0f b6 82 c0 40 10 f0 	movzbl -0xfefbf40(%edx),%eax
f010049e:	0b 05 28 85 11 f0    	or     0xf0118528,%eax
	shift ^= togglecode[data];
f01004a4:	0f b6 8a c0 41 10 f0 	movzbl -0xfefbe40(%edx),%ecx
f01004ab:	31 c8                	xor    %ecx,%eax
f01004ad:	a3 28 85 11 f0       	mov    %eax,0xf0118528

	c = charcode[shift & (CTL | SHIFT)][data];
f01004b2:	89 c1                	mov    %eax,%ecx
f01004b4:	83 e1 03             	and    $0x3,%ecx
f01004b7:	8b 0c 8d c0 42 10 f0 	mov    -0xfefbd40(,%ecx,4),%ecx
f01004be:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01004c2:	a8 08                	test   $0x8,%al
f01004c4:	74 19                	je     f01004df <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f01004c6:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01004c9:	83 fa 19             	cmp    $0x19,%edx
f01004cc:	77 05                	ja     f01004d3 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f01004ce:	83 eb 20             	sub    $0x20,%ebx
f01004d1:	eb 0c                	jmp    f01004df <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f01004d3:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f01004d6:	8d 53 20             	lea    0x20(%ebx),%edx
f01004d9:	83 f9 19             	cmp    $0x19,%ecx
f01004dc:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01004df:	f7 d0                	not    %eax
f01004e1:	a8 06                	test   $0x6,%al
f01004e3:	75 1f                	jne    f0100504 <kbd_proc_data+0xf8>
f01004e5:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01004eb:	75 17                	jne    f0100504 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f01004ed:	c7 04 24 84 40 10 f0 	movl   $0xf0104084,(%esp)
f01004f4:	e8 6d 2a 00 00       	call   f0102f66 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004f9:	ba 92 00 00 00       	mov    $0x92,%edx
f01004fe:	b8 03 00 00 00       	mov    $0x3,%eax
f0100503:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100504:	89 d8                	mov    %ebx,%eax
f0100506:	83 c4 14             	add    $0x14,%esp
f0100509:	5b                   	pop    %ebx
f010050a:	5d                   	pop    %ebp
f010050b:	c3                   	ret    

f010050c <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010050c:	55                   	push   %ebp
f010050d:	89 e5                	mov    %esp,%ebp
f010050f:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100512:	80 3d 0c 83 11 f0 00 	cmpb   $0x0,0xf011830c
f0100519:	74 0a                	je     f0100525 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010051b:	b8 ae 01 10 f0       	mov    $0xf01001ae,%eax
f0100520:	e8 a9 fc ff ff       	call   f01001ce <cons_intr>
}
f0100525:	c9                   	leave  
f0100526:	c3                   	ret    

f0100527 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100527:	55                   	push   %ebp
f0100528:	89 e5                	mov    %esp,%ebp
f010052a:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010052d:	b8 0c 04 10 f0       	mov    $0xf010040c,%eax
f0100532:	e8 97 fc ff ff       	call   f01001ce <cons_intr>
}
f0100537:	c9                   	leave  
f0100538:	c3                   	ret    

f0100539 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100539:	55                   	push   %ebp
f010053a:	89 e5                	mov    %esp,%ebp
f010053c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010053f:	e8 c8 ff ff ff       	call   f010050c <serial_intr>
	kbd_intr();
f0100544:	e8 de ff ff ff       	call   f0100527 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100549:	8b 15 20 85 11 f0    	mov    0xf0118520,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f010054f:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100554:	3b 15 24 85 11 f0    	cmp    0xf0118524,%edx
f010055a:	74 1e                	je     f010057a <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010055c:	0f b6 82 20 83 11 f0 	movzbl -0xfee7ce0(%edx),%eax
f0100563:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100566:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010056c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100571:	0f 44 d1             	cmove  %ecx,%edx
f0100574:	89 15 20 85 11 f0    	mov    %edx,0xf0118520
		return c;
	}
	return 0;
}
f010057a:	c9                   	leave  
f010057b:	c3                   	ret    

f010057c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010057c:	55                   	push   %ebp
f010057d:	89 e5                	mov    %esp,%ebp
f010057f:	57                   	push   %edi
f0100580:	56                   	push   %esi
f0100581:	53                   	push   %ebx
f0100582:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100585:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010058c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100593:	5a a5 
	if (*cp != 0xA55A) {
f0100595:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010059c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005a0:	74 11                	je     f01005b3 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01005a2:	c7 05 08 83 11 f0 b4 	movl   $0x3b4,0xf0118308
f01005a9:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005ac:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01005b1:	eb 16                	jmp    f01005c9 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01005b3:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005ba:	c7 05 08 83 11 f0 d4 	movl   $0x3d4,0xf0118308
f01005c1:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005c4:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005c9:	8b 0d 08 83 11 f0    	mov    0xf0118308,%ecx
f01005cf:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005d4:	89 ca                	mov    %ecx,%edx
f01005d6:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005d7:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005da:	89 da                	mov    %ebx,%edx
f01005dc:	ec                   	in     (%dx),%al
f01005dd:	0f b6 f8             	movzbl %al,%edi
f01005e0:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005e8:	89 ca                	mov    %ecx,%edx
f01005ea:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005eb:	89 da                	mov    %ebx,%edx
f01005ed:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005ee:	89 35 04 83 11 f0    	mov    %esi,0xf0118304

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005f4:	0f b6 d8             	movzbl %al,%ebx
f01005f7:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005f9:	66 89 3d 00 83 11 f0 	mov    %di,0xf0118300
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100600:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100605:	b8 00 00 00 00       	mov    $0x0,%eax
f010060a:	89 da                	mov    %ebx,%edx
f010060c:	ee                   	out    %al,(%dx)
f010060d:	b2 fb                	mov    $0xfb,%dl
f010060f:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100614:	ee                   	out    %al,(%dx)
f0100615:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010061a:	b8 0c 00 00 00       	mov    $0xc,%eax
f010061f:	89 ca                	mov    %ecx,%edx
f0100621:	ee                   	out    %al,(%dx)
f0100622:	b2 f9                	mov    $0xf9,%dl
f0100624:	b8 00 00 00 00       	mov    $0x0,%eax
f0100629:	ee                   	out    %al,(%dx)
f010062a:	b2 fb                	mov    $0xfb,%dl
f010062c:	b8 03 00 00 00       	mov    $0x3,%eax
f0100631:	ee                   	out    %al,(%dx)
f0100632:	b2 fc                	mov    $0xfc,%dl
f0100634:	b8 00 00 00 00       	mov    $0x0,%eax
f0100639:	ee                   	out    %al,(%dx)
f010063a:	b2 f9                	mov    $0xf9,%dl
f010063c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100641:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100642:	b2 fd                	mov    $0xfd,%dl
f0100644:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100645:	3c ff                	cmp    $0xff,%al
f0100647:	0f 95 c0             	setne  %al
f010064a:	89 c6                	mov    %eax,%esi
f010064c:	a2 0c 83 11 f0       	mov    %al,0xf011830c
f0100651:	89 da                	mov    %ebx,%edx
f0100653:	ec                   	in     (%dx),%al
f0100654:	89 ca                	mov    %ecx,%edx
f0100656:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100657:	89 f0                	mov    %esi,%eax
f0100659:	84 c0                	test   %al,%al
f010065b:	75 0c                	jne    f0100669 <cons_init+0xed>
		cprintf("Serial port does not exist!\n");
f010065d:	c7 04 24 90 40 10 f0 	movl   $0xf0104090,(%esp)
f0100664:	e8 fd 28 00 00       	call   f0102f66 <cprintf>
}
f0100669:	83 c4 1c             	add    $0x1c,%esp
f010066c:	5b                   	pop    %ebx
f010066d:	5e                   	pop    %esi
f010066e:	5f                   	pop    %edi
f010066f:	5d                   	pop    %ebp
f0100670:	c3                   	ret    

f0100671 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100671:	55                   	push   %ebp
f0100672:	89 e5                	mov    %esp,%ebp
f0100674:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100677:	8b 45 08             	mov    0x8(%ebp),%eax
f010067a:	e8 8c fb ff ff       	call   f010020b <cons_putc>
}
f010067f:	c9                   	leave  
f0100680:	c3                   	ret    

f0100681 <getchar>:

int
getchar(void)
{
f0100681:	55                   	push   %ebp
f0100682:	89 e5                	mov    %esp,%ebp
f0100684:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100687:	e8 ad fe ff ff       	call   f0100539 <cons_getc>
f010068c:	85 c0                	test   %eax,%eax
f010068e:	74 f7                	je     f0100687 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100690:	c9                   	leave  
f0100691:	c3                   	ret    

f0100692 <iscons>:

int
iscons(int fdnum)
{
f0100692:	55                   	push   %ebp
f0100693:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100695:	b8 01 00 00 00       	mov    $0x1,%eax
f010069a:	5d                   	pop    %ebp
f010069b:	c3                   	ret    
f010069c:	00 00                	add    %al,(%eax)
	...

f01006a0 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01006a0:	55                   	push   %ebp
f01006a1:	89 e5                	mov    %esp,%ebp
f01006a3:	56                   	push   %esi
f01006a4:	53                   	push   %ebx
f01006a5:	83 ec 10             	sub    $0x10,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01006a8:	89 eb                	mov    %ebp,%ebx
	uint32_t* ebp = (uint32_t*) read_ebp();
f01006aa:	89 de                	mov    %ebx,%esi
	cprintf("Stack backtrace:\n");
f01006ac:	c7 04 24 d0 42 10 f0 	movl   $0xf01042d0,(%esp)
f01006b3:	e8 ae 28 00 00       	call   f0102f66 <cprintf>
	while (ebp) {
f01006b8:	85 db                	test   %ebx,%ebx
f01006ba:	74 49                	je     f0100705 <mon_backtrace+0x65>
		cprintf("ebp %x  eip %x  args", ebp, ebp[1]);
f01006bc:	8b 46 04             	mov    0x4(%esi),%eax
f01006bf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006c3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01006c7:	c7 04 24 e2 42 10 f0 	movl   $0xf01042e2,(%esp)
f01006ce:	e8 93 28 00 00       	call   f0102f66 <cprintf>
		int i;
		for (i = 2; i <= 6; ++i)
f01006d3:	bb 02 00 00 00       	mov    $0x2,%ebx
			cprintf(" %08.x", ebp[i]);
f01006d8:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
f01006db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006df:	c7 04 24 f7 42 10 f0 	movl   $0xf01042f7,(%esp)
f01006e6:	e8 7b 28 00 00       	call   f0102f66 <cprintf>
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
		cprintf("ebp %x  eip %x  args", ebp, ebp[1]);
		int i;
		for (i = 2; i <= 6; ++i)
f01006eb:	83 c3 01             	add    $0x1,%ebx
f01006ee:	83 fb 07             	cmp    $0x7,%ebx
f01006f1:	75 e5                	jne    f01006d8 <mon_backtrace+0x38>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
f01006f3:	c7 04 24 da 4f 10 f0 	movl   $0xf0104fda,(%esp)
f01006fa:	e8 67 28 00 00       	call   f0102f66 <cprintf>
		ebp = (uint32_t*) *ebp;
f01006ff:	8b 36                	mov    (%esi),%esi
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f0100701:	85 f6                	test   %esi,%esi
f0100703:	75 b7                	jne    f01006bc <mon_backtrace+0x1c>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
		ebp = (uint32_t*) *ebp;
	}
	return 0;
}
f0100705:	b8 00 00 00 00       	mov    $0x0,%eax
f010070a:	83 c4 10             	add    $0x10,%esp
f010070d:	5b                   	pop    %ebx
f010070e:	5e                   	pop    %esi
f010070f:	5d                   	pop    %ebp
f0100710:	c3                   	ret    

f0100711 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100711:	55                   	push   %ebp
f0100712:	89 e5                	mov    %esp,%ebp
f0100714:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100717:	c7 04 24 fe 42 10 f0 	movl   $0xf01042fe,(%esp)
f010071e:	e8 43 28 00 00       	call   f0102f66 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100723:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010072a:	00 
f010072b:	c7 04 24 c8 43 10 f0 	movl   $0xf01043c8,(%esp)
f0100732:	e8 2f 28 00 00       	call   f0102f66 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100737:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010073e:	00 
f010073f:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100746:	f0 
f0100747:	c7 04 24 f0 43 10 f0 	movl   $0xf01043f0,(%esp)
f010074e:	e8 13 28 00 00       	call   f0102f66 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100753:	c7 44 24 08 f5 3f 10 	movl   $0x103ff5,0x8(%esp)
f010075a:	00 
f010075b:	c7 44 24 04 f5 3f 10 	movl   $0xf0103ff5,0x4(%esp)
f0100762:	f0 
f0100763:	c7 04 24 14 44 10 f0 	movl   $0xf0104414,(%esp)
f010076a:	e8 f7 27 00 00       	call   f0102f66 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010076f:	c7 44 24 08 00 83 11 	movl   $0x118300,0x8(%esp)
f0100776:	00 
f0100777:	c7 44 24 04 00 83 11 	movl   $0xf0118300,0x4(%esp)
f010077e:	f0 
f010077f:	c7 04 24 38 44 10 f0 	movl   $0xf0104438,(%esp)
f0100786:	e8 db 27 00 00       	call   f0102f66 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010078b:	c7 44 24 08 54 89 11 	movl   $0x118954,0x8(%esp)
f0100792:	00 
f0100793:	c7 44 24 04 54 89 11 	movl   $0xf0118954,0x4(%esp)
f010079a:	f0 
f010079b:	c7 04 24 5c 44 10 f0 	movl   $0xf010445c,(%esp)
f01007a2:	e8 bf 27 00 00       	call   f0102f66 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01007a7:	b8 53 8d 11 f0       	mov    $0xf0118d53,%eax
f01007ac:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01007b1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007b6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007bc:	85 c0                	test   %eax,%eax
f01007be:	0f 48 c2             	cmovs  %edx,%eax
f01007c1:	c1 f8 0a             	sar    $0xa,%eax
f01007c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007c8:	c7 04 24 80 44 10 f0 	movl   $0xf0104480,(%esp)
f01007cf:	e8 92 27 00 00       	call   f0102f66 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01007d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01007d9:	c9                   	leave  
f01007da:	c3                   	ret    

f01007db <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007db:	55                   	push   %ebp
f01007dc:	89 e5                	mov    %esp,%ebp
f01007de:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007e1:	a1 24 45 10 f0       	mov    0xf0104524,%eax
f01007e6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007ea:	a1 20 45 10 f0       	mov    0xf0104520,%eax
f01007ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007f3:	c7 04 24 17 43 10 f0 	movl   $0xf0104317,(%esp)
f01007fa:	e8 67 27 00 00       	call   f0102f66 <cprintf>
f01007ff:	a1 30 45 10 f0       	mov    0xf0104530,%eax
f0100804:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100808:	a1 2c 45 10 f0       	mov    0xf010452c,%eax
f010080d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100811:	c7 04 24 17 43 10 f0 	movl   $0xf0104317,(%esp)
f0100818:	e8 49 27 00 00       	call   f0102f66 <cprintf>
f010081d:	a1 3c 45 10 f0       	mov    0xf010453c,%eax
f0100822:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100826:	a1 38 45 10 f0       	mov    0xf0104538,%eax
f010082b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010082f:	c7 04 24 17 43 10 f0 	movl   $0xf0104317,(%esp)
f0100836:	e8 2b 27 00 00       	call   f0102f66 <cprintf>
f010083b:	a1 48 45 10 f0       	mov    0xf0104548,%eax
f0100840:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100844:	a1 44 45 10 f0       	mov    0xf0104544,%eax
f0100849:	89 44 24 04          	mov    %eax,0x4(%esp)
f010084d:	c7 04 24 17 43 10 f0 	movl   $0xf0104317,(%esp)
f0100854:	e8 0d 27 00 00       	call   f0102f66 <cprintf>
	return 0;
}
f0100859:	b8 00 00 00 00       	mov    $0x0,%eax
f010085e:	c9                   	leave  
f010085f:	c3                   	ret    

f0100860 <backtrace>:
	return 0;
}

int
backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100860:	55                   	push   %ebp
f0100861:	89 e5                	mov    %esp,%ebp
f0100863:	57                   	push   %edi
f0100864:	56                   	push   %esi
f0100865:	53                   	push   %ebx
f0100866:	83 ec 4c             	sub    $0x4c,%esp
f0100869:	89 eb                	mov    %ebp,%ebx
	uint32_t* ebp = (uint32_t*) read_ebp();
f010086b:	89 de                	mov    %ebx,%esi
	cprintf("Stack backtrace:\n");
f010086d:	c7 04 24 d0 42 10 f0 	movl   $0xf01042d0,(%esp)
f0100874:	e8 ed 26 00 00       	call   f0102f66 <cprintf>
	while (ebp) {
f0100879:	85 db                	test   %ebx,%ebx
f010087b:	0f 84 8b 00 00 00    	je     f010090c <backtrace+0xac>
		uint32_t eip = ebp[1];
f0100881:	8b 7e 04             	mov    0x4(%esi),%edi
		cprintf("ebp %x  eip %x  args", ebp, eip);
f0100884:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100888:	89 74 24 04          	mov    %esi,0x4(%esp)
f010088c:	c7 04 24 e2 42 10 f0 	movl   $0xf01042e2,(%esp)
f0100893:	e8 ce 26 00 00       	call   f0102f66 <cprintf>
		int i;
		for (i = 2; i <= 6; ++i)
f0100898:	bb 02 00 00 00       	mov    $0x2,%ebx
			cprintf(" %08.x", ebp[i]);
f010089d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
f01008a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008a4:	c7 04 24 f7 42 10 f0 	movl   $0xf01042f7,(%esp)
f01008ab:	e8 b6 26 00 00       	call   f0102f66 <cprintf>
	cprintf("Stack backtrace:\n");
	while (ebp) {
		uint32_t eip = ebp[1];
		cprintf("ebp %x  eip %x  args", ebp, eip);
		int i;
		for (i = 2; i <= 6; ++i)
f01008b0:	83 c3 01             	add    $0x1,%ebx
f01008b3:	83 fb 07             	cmp    $0x7,%ebx
f01008b6:	75 e5                	jne    f010089d <backtrace+0x3d>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
f01008b8:	c7 04 24 da 4f 10 f0 	movl   $0xf0104fda,(%esp)
f01008bf:	e8 a2 26 00 00       	call   f0102f66 <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f01008c4:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008cb:	89 3c 24             	mov    %edi,(%esp)
f01008ce:	e8 db 27 00 00       	call   f01030ae <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n", 
f01008d3:	2b 7d e0             	sub    -0x20(%ebp),%edi
f01008d6:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01008da:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01008dd:	89 44 24 10          	mov    %eax,0x10(%esp)
f01008e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01008e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01008e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01008eb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01008f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008f6:	c7 04 24 20 43 10 f0 	movl   $0xf0104320,(%esp)
f01008fd:	e8 64 26 00 00       	call   f0102f66 <cprintf>
			info.eip_file, info.eip_line,
			info.eip_fn_namelen, info.eip_fn_name,
			eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
		ebp = (uint32_t*) *ebp;
f0100902:	8b 36                	mov    (%esi),%esi
int
backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f0100904:	85 f6                	test   %esi,%esi
f0100906:	0f 85 75 ff ff ff    	jne    f0100881 <backtrace+0x21>
			eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
		ebp = (uint32_t*) *ebp;
	}
	return 0;
}
f010090c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100911:	83 c4 4c             	add    $0x4c,%esp
f0100914:	5b                   	pop    %ebx
f0100915:	5e                   	pop    %esi
f0100916:	5f                   	pop    %edi
f0100917:	5d                   	pop    %ebp
f0100918:	c3                   	ret    

f0100919 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100919:	55                   	push   %ebp
f010091a:	89 e5                	mov    %esp,%ebp
f010091c:	57                   	push   %edi
f010091d:	56                   	push   %esi
f010091e:	53                   	push   %ebx
f010091f:	83 ec 6c             	sub    $0x6c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100922:	c7 04 24 ac 44 10 f0 	movl   $0xf01044ac,(%esp)
f0100929:	e8 38 26 00 00       	call   f0102f66 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010092e:	c7 04 24 d0 44 10 f0 	movl   $0xf01044d0,(%esp)
f0100935:	e8 2c 26 00 00       	call   f0102f66 <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n", 
f010093a:	c7 44 24 18 31 43 10 	movl   $0xf0104331,0x18(%esp)
f0100941:	f0 
f0100942:	c7 44 24 14 00 04 00 	movl   $0x400,0x14(%esp)
f0100949:	00 
f010094a:	c7 44 24 10 35 43 10 	movl   $0xf0104335,0x10(%esp)
f0100951:	f0 
f0100952:	c7 44 24 0c 00 02 00 	movl   $0x200,0xc(%esp)
f0100959:	00 
f010095a:	c7 44 24 08 3b 43 10 	movl   $0xf010433b,0x8(%esp)
f0100961:	f0 
f0100962:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
f0100969:	00 
f010096a:	c7 04 24 40 43 10 f0 	movl   $0xf0104340,(%esp)
f0100971:	e8 f0 25 00 00       	call   f0102f66 <cprintf>
		0x0100, "blue", 0x0200, "green", 0x0400, "red");


	while (1) {
		buf = readline("K> ");
f0100976:	c7 04 24 50 43 10 f0 	movl   $0xf0104350,(%esp)
f010097d:	e8 1e 2f 00 00       	call   f01038a0 <readline>
f0100982:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100984:	85 c0                	test   %eax,%eax
f0100986:	74 ee                	je     f0100976 <monitor+0x5d>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100988:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010098f:	be 00 00 00 00       	mov    $0x0,%esi
f0100994:	eb 06                	jmp    f010099c <monitor+0x83>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100996:	c6 03 00             	movb   $0x0,(%ebx)
f0100999:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010099c:	0f b6 03             	movzbl (%ebx),%eax
f010099f:	84 c0                	test   %al,%al
f01009a1:	74 6a                	je     f0100a0d <monitor+0xf4>
f01009a3:	0f be c0             	movsbl %al,%eax
f01009a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009aa:	c7 04 24 54 43 10 f0 	movl   $0xf0104354,(%esp)
f01009b1:	e8 2c 31 00 00       	call   f0103ae2 <strchr>
f01009b6:	85 c0                	test   %eax,%eax
f01009b8:	75 dc                	jne    f0100996 <monitor+0x7d>
			*buf++ = 0;
		if (*buf == 0)
f01009ba:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009bd:	74 4e                	je     f0100a0d <monitor+0xf4>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009bf:	83 fe 0f             	cmp    $0xf,%esi
f01009c2:	75 16                	jne    f01009da <monitor+0xc1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009c4:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01009cb:	00 
f01009cc:	c7 04 24 59 43 10 f0 	movl   $0xf0104359,(%esp)
f01009d3:	e8 8e 25 00 00       	call   f0102f66 <cprintf>
f01009d8:	eb 9c                	jmp    f0100976 <monitor+0x5d>
			return 0;
		}
		argv[argc++] = buf;
f01009da:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009de:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009e1:	0f b6 03             	movzbl (%ebx),%eax
f01009e4:	84 c0                	test   %al,%al
f01009e6:	75 0c                	jne    f01009f4 <monitor+0xdb>
f01009e8:	eb b2                	jmp    f010099c <monitor+0x83>
			buf++;
f01009ea:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009ed:	0f b6 03             	movzbl (%ebx),%eax
f01009f0:	84 c0                	test   %al,%al
f01009f2:	74 a8                	je     f010099c <monitor+0x83>
f01009f4:	0f be c0             	movsbl %al,%eax
f01009f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009fb:	c7 04 24 54 43 10 f0 	movl   $0xf0104354,(%esp)
f0100a02:	e8 db 30 00 00       	call   f0103ae2 <strchr>
f0100a07:	85 c0                	test   %eax,%eax
f0100a09:	74 df                	je     f01009ea <monitor+0xd1>
f0100a0b:	eb 8f                	jmp    f010099c <monitor+0x83>
			buf++;
	}
	argv[argc] = 0;
f0100a0d:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a14:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a15:	85 f6                	test   %esi,%esi
f0100a17:	0f 84 59 ff ff ff    	je     f0100976 <monitor+0x5d>
f0100a1d:	bb 20 45 10 f0       	mov    $0xf0104520,%ebx
f0100a22:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a27:	8b 03                	mov    (%ebx),%eax
f0100a29:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a2d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a30:	89 04 24             	mov    %eax,(%esp)
f0100a33:	e8 30 30 00 00       	call   f0103a68 <strcmp>
f0100a38:	85 c0                	test   %eax,%eax
f0100a3a:	75 23                	jne    f0100a5f <monitor+0x146>
			return commands[i].func(argc, argv, tf);
f0100a3c:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100a3f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a42:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a46:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100a49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a4d:	89 34 24             	mov    %esi,(%esp)
f0100a50:	ff 97 28 45 10 f0    	call   *-0xfefbad8(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a56:	85 c0                	test   %eax,%eax
f0100a58:	78 28                	js     f0100a82 <monitor+0x169>
f0100a5a:	e9 17 ff ff ff       	jmp    f0100976 <monitor+0x5d>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a5f:	83 c7 01             	add    $0x1,%edi
f0100a62:	83 c3 0c             	add    $0xc,%ebx
f0100a65:	83 ff 04             	cmp    $0x4,%edi
f0100a68:	75 bd                	jne    f0100a27 <monitor+0x10e>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a6a:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a6d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a71:	c7 04 24 76 43 10 f0 	movl   $0xf0104376,(%esp)
f0100a78:	e8 e9 24 00 00       	call   f0102f66 <cprintf>
f0100a7d:	e9 f4 fe ff ff       	jmp    f0100976 <monitor+0x5d>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a82:	83 c4 6c             	add    $0x6c,%esp
f0100a85:	5b                   	pop    %ebx
f0100a86:	5e                   	pop    %esi
f0100a87:	5f                   	pop    %edi
f0100a88:	5d                   	pop    %ebp
f0100a89:	c3                   	ret    
	...

f0100a8c <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a8c:	55                   	push   %ebp
f0100a8d:	89 e5                	mov    %esp,%ebp
f0100a8f:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100a92:	89 d1                	mov    %edx,%ecx
f0100a94:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100a97:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100a9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a9f:	f6 c1 01             	test   $0x1,%cl
f0100aa2:	74 57                	je     f0100afb <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100aa4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100aaa:	89 c8                	mov    %ecx,%eax
f0100aac:	c1 e8 0c             	shr    $0xc,%eax
f0100aaf:	3b 05 48 89 11 f0    	cmp    0xf0118948,%eax
f0100ab5:	72 20                	jb     f0100ad7 <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ab7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100abb:	c7 44 24 08 50 45 10 	movl   $0xf0104550,0x8(%esp)
f0100ac2:	f0 
f0100ac3:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f0100aca:	00 
f0100acb:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0100ad2:	e8 1a f6 ff ff       	call   f01000f1 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100ad7:	c1 ea 0c             	shr    $0xc,%edx
f0100ada:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ae0:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f0100ae7:	89 c2                	mov    %eax,%edx
f0100ae9:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100aec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100af1:	85 d2                	test   %edx,%edx
f0100af3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100af8:	0f 44 c2             	cmove  %edx,%eax
}
f0100afb:	c9                   	leave  
f0100afc:	c3                   	ret    

f0100afd <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100afd:	55                   	push   %ebp
f0100afe:	89 e5                	mov    %esp,%ebp
f0100b00:	53                   	push   %ebx
f0100b01:	83 ec 14             	sub    $0x14,%esp
f0100b04:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b06:	83 3d 34 85 11 f0 00 	cmpl   $0x0,0xf0118534
f0100b0d:	75 0f                	jne    f0100b1e <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b0f:	b8 53 99 11 f0       	mov    $0xf0119953,%eax
f0100b14:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b19:	a3 34 85 11 f0       	mov    %eax,0xf0118534
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
f0100b1e:	a1 34 85 11 f0       	mov    0xf0118534,%eax
f0100b23:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b27:	c7 04 24 a0 4c 10 f0 	movl   $0xf0104ca0,(%esp)
f0100b2e:	e8 33 24 00 00       	call   f0102f66 <cprintf>
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
f0100b33:	89 d8                	mov    %ebx,%eax
f0100b35:	03 05 34 85 11 f0    	add    0xf0118534,%eax
f0100b3b:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100b40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b45:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b49:	c7 04 24 b9 4c 10 f0 	movl   $0xf0104cb9,(%esp)
f0100b50:	e8 11 24 00 00       	call   f0102f66 <cprintf>
	if (n != 0) {
f0100b55:	85 db                	test   %ebx,%ebx
f0100b57:	74 1a                	je     f0100b73 <boot_alloc+0x76>
		char *next = nextfree;
f0100b59:	a1 34 85 11 f0       	mov    0xf0118534,%eax
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
f0100b5e:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100b65:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b6b:	89 15 34 85 11 f0    	mov    %edx,0xf0118534
		return next;
f0100b71:	eb 05                	jmp    f0100b78 <boot_alloc+0x7b>
	} else return nextfree;
f0100b73:	a1 34 85 11 f0       	mov    0xf0118534,%eax

	return NULL;
}
f0100b78:	83 c4 14             	add    $0x14,%esp
f0100b7b:	5b                   	pop    %ebx
f0100b7c:	5d                   	pop    %ebp
f0100b7d:	c3                   	ret    

f0100b7e <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b7e:	55                   	push   %ebp
f0100b7f:	89 e5                	mov    %esp,%ebp
f0100b81:	83 ec 18             	sub    $0x18,%esp
f0100b84:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100b87:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100b8a:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b8c:	89 04 24             	mov    %eax,(%esp)
f0100b8f:	e8 64 23 00 00       	call   f0102ef8 <mc146818_read>
f0100b94:	89 c6                	mov    %eax,%esi
f0100b96:	83 c3 01             	add    $0x1,%ebx
f0100b99:	89 1c 24             	mov    %ebx,(%esp)
f0100b9c:	e8 57 23 00 00       	call   f0102ef8 <mc146818_read>
f0100ba1:	c1 e0 08             	shl    $0x8,%eax
f0100ba4:	09 f0                	or     %esi,%eax
}
f0100ba6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100ba9:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100bac:	89 ec                	mov    %ebp,%esp
f0100bae:	5d                   	pop    %ebp
f0100baf:	c3                   	ret    

f0100bb0 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100bb0:	55                   	push   %ebp
f0100bb1:	89 e5                	mov    %esp,%ebp
f0100bb3:	57                   	push   %edi
f0100bb4:	56                   	push   %esi
f0100bb5:	53                   	push   %ebx
f0100bb6:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bb9:	3c 01                	cmp    $0x1,%al
f0100bbb:	19 f6                	sbb    %esi,%esi
f0100bbd:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100bc3:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100bc6:	8b 1d 2c 85 11 f0    	mov    0xf011852c,%ebx
f0100bcc:	85 db                	test   %ebx,%ebx
f0100bce:	75 1c                	jne    f0100bec <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0100bd0:	c7 44 24 08 74 45 10 	movl   $0xf0104574,0x8(%esp)
f0100bd7:	f0 
f0100bd8:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
f0100bdf:	00 
f0100be0:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0100be7:	e8 05 f5 ff ff       	call   f01000f1 <_panic>

	if (only_low_memory) {
f0100bec:	84 c0                	test   %al,%al
f0100bee:	74 50                	je     f0100c40 <check_page_free_list+0x90>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100bf0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100bf3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100bf6:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100bf9:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bfc:	89 d8                	mov    %ebx,%eax
f0100bfe:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f0100c04:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c07:	c1 e8 16             	shr    $0x16,%eax
f0100c0a:	39 c6                	cmp    %eax,%esi
f0100c0c:	0f 96 c0             	setbe  %al
f0100c0f:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100c12:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0100c16:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100c18:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c1c:	8b 1b                	mov    (%ebx),%ebx
f0100c1e:	85 db                	test   %ebx,%ebx
f0100c20:	75 da                	jne    f0100bfc <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c22:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c25:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c2b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100c2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c31:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c33:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100c36:	89 1d 2c 85 11 f0    	mov    %ebx,0xf011852c
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c3c:	85 db                	test   %ebx,%ebx
f0100c3e:	74 67                	je     f0100ca7 <check_page_free_list+0xf7>
f0100c40:	89 d8                	mov    %ebx,%eax
f0100c42:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f0100c48:	c1 f8 03             	sar    $0x3,%eax
f0100c4b:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c4e:	89 c2                	mov    %eax,%edx
f0100c50:	c1 ea 16             	shr    $0x16,%edx
f0100c53:	39 d6                	cmp    %edx,%esi
f0100c55:	76 4a                	jbe    f0100ca1 <check_page_free_list+0xf1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c57:	89 c2                	mov    %eax,%edx
f0100c59:	c1 ea 0c             	shr    $0xc,%edx
f0100c5c:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0100c62:	72 20                	jb     f0100c84 <check_page_free_list+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c64:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c68:	c7 44 24 08 50 45 10 	movl   $0xf0104550,0x8(%esp)
f0100c6f:	f0 
f0100c70:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100c77:	00 
f0100c78:	c7 04 24 cc 4c 10 f0 	movl   $0xf0104ccc,(%esp)
f0100c7f:	e8 6d f4 ff ff       	call   f01000f1 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c84:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100c8b:	00 
f0100c8c:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100c93:	00 
	return (void *)(pa + KERNBASE);
f0100c94:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c99:	89 04 24             	mov    %eax,(%esp)
f0100c9c:	e8 a0 2e 00 00       	call   f0103b41 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ca1:	8b 1b                	mov    (%ebx),%ebx
f0100ca3:	85 db                	test   %ebx,%ebx
f0100ca5:	75 99                	jne    f0100c40 <check_page_free_list+0x90>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ca7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cac:	e8 4c fe ff ff       	call   f0100afd <boot_alloc>
f0100cb1:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cb4:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f0100cba:	85 d2                	test   %edx,%edx
f0100cbc:	0f 84 f6 01 00 00    	je     f0100eb8 <check_page_free_list+0x308>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cc2:	8b 1d 50 89 11 f0    	mov    0xf0118950,%ebx
f0100cc8:	39 da                	cmp    %ebx,%edx
f0100cca:	72 4d                	jb     f0100d19 <check_page_free_list+0x169>
		assert(pp < pages + npages);
f0100ccc:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f0100cd1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100cd4:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0100cd7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100cda:	39 c2                	cmp    %eax,%edx
f0100cdc:	73 64                	jae    f0100d42 <check_page_free_list+0x192>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cde:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100ce1:	89 d0                	mov    %edx,%eax
f0100ce3:	29 d8                	sub    %ebx,%eax
f0100ce5:	a8 07                	test   $0x7,%al
f0100ce7:	0f 85 82 00 00 00    	jne    f0100d6f <check_page_free_list+0x1bf>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ced:	c1 f8 03             	sar    $0x3,%eax
f0100cf0:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cf3:	85 c0                	test   %eax,%eax
f0100cf5:	0f 84 a2 00 00 00    	je     f0100d9d <check_page_free_list+0x1ed>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cfb:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d00:	0f 84 c2 00 00 00    	je     f0100dc8 <check_page_free_list+0x218>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d06:	be 00 00 00 00       	mov    $0x0,%esi
f0100d0b:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d10:	e9 d7 00 00 00       	jmp    f0100dec <check_page_free_list+0x23c>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d15:	39 da                	cmp    %ebx,%edx
f0100d17:	73 24                	jae    f0100d3d <check_page_free_list+0x18d>
f0100d19:	c7 44 24 0c da 4c 10 	movl   $0xf0104cda,0xc(%esp)
f0100d20:	f0 
f0100d21:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0100d28:	f0 
f0100d29:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
f0100d30:	00 
f0100d31:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0100d38:	e8 b4 f3 ff ff       	call   f01000f1 <_panic>
		assert(pp < pages + npages);
f0100d3d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d40:	72 24                	jb     f0100d66 <check_page_free_list+0x1b6>
f0100d42:	c7 44 24 0c fb 4c 10 	movl   $0xf0104cfb,0xc(%esp)
f0100d49:	f0 
f0100d4a:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0100d51:	f0 
f0100d52:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
f0100d59:	00 
f0100d5a:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0100d61:	e8 8b f3 ff ff       	call   f01000f1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d66:	89 d0                	mov    %edx,%eax
f0100d68:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d6b:	a8 07                	test   $0x7,%al
f0100d6d:	74 24                	je     f0100d93 <check_page_free_list+0x1e3>
f0100d6f:	c7 44 24 0c 98 45 10 	movl   $0xf0104598,0xc(%esp)
f0100d76:	f0 
f0100d77:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0100d7e:	f0 
f0100d7f:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
f0100d86:	00 
f0100d87:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0100d8e:	e8 5e f3 ff ff       	call   f01000f1 <_panic>
f0100d93:	c1 f8 03             	sar    $0x3,%eax
f0100d96:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d99:	85 c0                	test   %eax,%eax
f0100d9b:	75 24                	jne    f0100dc1 <check_page_free_list+0x211>
f0100d9d:	c7 44 24 0c 0f 4d 10 	movl   $0xf0104d0f,0xc(%esp)
f0100da4:	f0 
f0100da5:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0100dac:	f0 
f0100dad:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
f0100db4:	00 
f0100db5:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0100dbc:	e8 30 f3 ff ff       	call   f01000f1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100dc1:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100dc6:	75 24                	jne    f0100dec <check_page_free_list+0x23c>
f0100dc8:	c7 44 24 0c 20 4d 10 	movl   $0xf0104d20,0xc(%esp)
f0100dcf:	f0 
f0100dd0:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0100dd7:	f0 
f0100dd8:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
f0100ddf:	00 
f0100de0:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0100de7:	e8 05 f3 ff ff       	call   f01000f1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100dec:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100df1:	75 24                	jne    f0100e17 <check_page_free_list+0x267>
f0100df3:	c7 44 24 0c cc 45 10 	movl   $0xf01045cc,0xc(%esp)
f0100dfa:	f0 
f0100dfb:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0100e02:	f0 
f0100e03:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
f0100e0a:	00 
f0100e0b:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0100e12:	e8 da f2 ff ff       	call   f01000f1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e17:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e1c:	75 24                	jne    f0100e42 <check_page_free_list+0x292>
f0100e1e:	c7 44 24 0c 39 4d 10 	movl   $0xf0104d39,0xc(%esp)
f0100e25:	f0 
f0100e26:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0100e2d:	f0 
f0100e2e:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
f0100e35:	00 
f0100e36:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0100e3d:	e8 af f2 ff ff       	call   f01000f1 <_panic>
f0100e42:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e44:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e49:	76 57                	jbe    f0100ea2 <check_page_free_list+0x2f2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e4b:	c1 e8 0c             	shr    $0xc,%eax
f0100e4e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100e51:	77 20                	ja     f0100e73 <check_page_free_list+0x2c3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e53:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100e57:	c7 44 24 08 50 45 10 	movl   $0xf0104550,0x8(%esp)
f0100e5e:	f0 
f0100e5f:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100e66:	00 
f0100e67:	c7 04 24 cc 4c 10 f0 	movl   $0xf0104ccc,(%esp)
f0100e6e:	e8 7e f2 ff ff       	call   f01000f1 <_panic>
	return (void *)(pa + KERNBASE);
f0100e73:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0100e79:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100e7c:	76 29                	jbe    f0100ea7 <check_page_free_list+0x2f7>
f0100e7e:	c7 44 24 0c f0 45 10 	movl   $0xf01045f0,0xc(%esp)
f0100e85:	f0 
f0100e86:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0100e8d:	f0 
f0100e8e:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
f0100e95:	00 
f0100e96:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0100e9d:	e8 4f f2 ff ff       	call   f01000f1 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100ea2:	83 c7 01             	add    $0x1,%edi
f0100ea5:	eb 03                	jmp    f0100eaa <check_page_free_list+0x2fa>
		else
			++nfree_extmem;
f0100ea7:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100eaa:	8b 12                	mov    (%edx),%edx
f0100eac:	85 d2                	test   %edx,%edx
f0100eae:	0f 85 61 fe ff ff    	jne    f0100d15 <check_page_free_list+0x165>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100eb4:	85 ff                	test   %edi,%edi
f0100eb6:	7f 24                	jg     f0100edc <check_page_free_list+0x32c>
f0100eb8:	c7 44 24 0c 53 4d 10 	movl   $0xf0104d53,0xc(%esp)
f0100ebf:	f0 
f0100ec0:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0100ec7:	f0 
f0100ec8:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
f0100ecf:	00 
f0100ed0:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0100ed7:	e8 15 f2 ff ff       	call   f01000f1 <_panic>
	assert(nfree_extmem > 0);
f0100edc:	85 f6                	test   %esi,%esi
f0100ede:	7f 24                	jg     f0100f04 <check_page_free_list+0x354>
f0100ee0:	c7 44 24 0c 65 4d 10 	movl   $0xf0104d65,0xc(%esp)
f0100ee7:	f0 
f0100ee8:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0100eef:	f0 
f0100ef0:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
f0100ef7:	00 
f0100ef8:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0100eff:	e8 ed f1 ff ff       	call   f01000f1 <_panic>
	cprintf("check_page_free_list done\n");
f0100f04:	c7 04 24 76 4d 10 f0 	movl   $0xf0104d76,(%esp)
f0100f0b:	e8 56 20 00 00       	call   f0102f66 <cprintf>
}
f0100f10:	83 c4 3c             	add    $0x3c,%esp
f0100f13:	5b                   	pop    %ebx
f0100f14:	5e                   	pop    %esi
f0100f15:	5f                   	pop    %edi
f0100f16:	5d                   	pop    %ebp
f0100f17:	c3                   	ret    

f0100f18 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100f18:	55                   	push   %ebp
f0100f19:	89 e5                	mov    %esp,%ebp
f0100f1b:	56                   	push   %esi
f0100f1c:	53                   	push   %ebx
f0100f1d:	83 ec 10             	sub    $0x10,%esp
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0100f20:	8b 35 30 85 11 f0    	mov    0xf0118530,%esi
f0100f26:	83 fe 01             	cmp    $0x1,%esi
f0100f29:	76 37                	jbe    f0100f62 <page_init+0x4a>
f0100f2b:	8b 1d 2c 85 11 f0    	mov    0xf011852c,%ebx
f0100f31:	b8 01 00 00 00       	mov    $0x1,%eax
f0100f36:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100f3d:	89 d1                	mov    %edx,%ecx
f0100f3f:	03 0d 50 89 11 f0    	add    0xf0118950,%ecx
f0100f45:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100f4b:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100f4d:	89 d3                	mov    %edx,%ebx
f0100f4f:	03 1d 50 89 11 f0    	add    0xf0118950,%ebx
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0100f55:	83 c0 01             	add    $0x1,%eax
f0100f58:	39 c6                	cmp    %eax,%esi
f0100f5a:	77 da                	ja     f0100f36 <page_init+0x1e>
f0100f5c:	89 1d 2c 85 11 f0    	mov    %ebx,0xf011852c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	int med = (int)ROUNDUP(((char*)pages) + (sizeof(struct PageInfo) * npages) - 0xf0000000, PGSIZE)/PGSIZE;
f0100f62:	8b 15 50 89 11 f0    	mov    0xf0118950,%edx
f0100f68:	8b 0d 48 89 11 f0    	mov    0xf0118948,%ecx
f0100f6e:	8d 84 ca ff 0f 00 10 	lea    0x10000fff(%edx,%ecx,8),%eax
f0100f75:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f7a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0100f80:	85 c0                	test   %eax,%eax
f0100f82:	0f 49 d8             	cmovns %eax,%ebx
f0100f85:	c1 fb 0c             	sar    $0xc,%ebx
	cprintf("%x\n", ((char*)pages) + (sizeof(struct PageInfo) * npages));
f0100f88:	8d 04 ca             	lea    (%edx,%ecx,8),%eax
f0100f8b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f8f:	c7 04 24 23 4f 10 f0 	movl   $0xf0104f23,(%esp)
f0100f96:	e8 cb 1f 00 00       	call   f0102f66 <cprintf>
	cprintf("med=%d\n", med);
f0100f9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f9f:	c7 04 24 91 4d 10 f0 	movl   $0xf0104d91,(%esp)
f0100fa6:	e8 bb 1f 00 00       	call   f0102f66 <cprintf>
	for (i = med; i < npages; i++) {
f0100fab:	89 d8                	mov    %ebx,%eax
f0100fad:	3b 1d 48 89 11 f0    	cmp    0xf0118948,%ebx
f0100fb3:	73 35                	jae    f0100fea <page_init+0xd2>
f0100fb5:	8b 0d 2c 85 11 f0    	mov    0xf011852c,%ecx
f0100fbb:	c1 e3 03             	shl    $0x3,%ebx
		pages[i].pp_ref = 0;
f0100fbe:	89 da                	mov    %ebx,%edx
f0100fc0:	03 15 50 89 11 f0    	add    0xf0118950,%edx
f0100fc6:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100fcc:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100fce:	89 d9                	mov    %ebx,%ecx
f0100fd0:	03 0d 50 89 11 f0    	add    0xf0118950,%ecx
		page_free_list = &pages[i];
	}
	int med = (int)ROUNDUP(((char*)pages) + (sizeof(struct PageInfo) * npages) - 0xf0000000, PGSIZE)/PGSIZE;
	cprintf("%x\n", ((char*)pages) + (sizeof(struct PageInfo) * npages));
	cprintf("med=%d\n", med);
	for (i = med; i < npages; i++) {
f0100fd6:	83 c0 01             	add    $0x1,%eax
f0100fd9:	83 c3 08             	add    $0x8,%ebx
f0100fdc:	39 05 48 89 11 f0    	cmp    %eax,0xf0118948
f0100fe2:	77 da                	ja     f0100fbe <page_init+0xa6>
f0100fe4:	89 0d 2c 85 11 f0    	mov    %ecx,0xf011852c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100fea:	83 c4 10             	add    $0x10,%esp
f0100fed:	5b                   	pop    %ebx
f0100fee:	5e                   	pop    %esi
f0100fef:	5d                   	pop    %ebp
f0100ff0:	c3                   	ret    

f0100ff1 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100ff1:	55                   	push   %ebp
f0100ff2:	89 e5                	mov    %esp,%ebp
f0100ff4:	53                   	push   %ebx
f0100ff5:	83 ec 14             	sub    $0x14,%esp
	if (page_free_list) {
f0100ff8:	8b 1d 2c 85 11 f0    	mov    0xf011852c,%ebx
f0100ffe:	85 db                	test   %ebx,%ebx
f0101000:	74 65                	je     f0101067 <page_alloc+0x76>
		struct PageInfo *ret = page_free_list;
		page_free_list = page_free_list->pp_link;
f0101002:	8b 03                	mov    (%ebx),%eax
f0101004:	a3 2c 85 11 f0       	mov    %eax,0xf011852c
		if (alloc_flags & ALLOC_ZERO) 
f0101009:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010100d:	74 58                	je     f0101067 <page_alloc+0x76>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010100f:	89 d8                	mov    %ebx,%eax
f0101011:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f0101017:	c1 f8 03             	sar    $0x3,%eax
f010101a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010101d:	89 c2                	mov    %eax,%edx
f010101f:	c1 ea 0c             	shr    $0xc,%edx
f0101022:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0101028:	72 20                	jb     f010104a <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010102a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010102e:	c7 44 24 08 50 45 10 	movl   $0xf0104550,0x8(%esp)
f0101035:	f0 
f0101036:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010103d:	00 
f010103e:	c7 04 24 cc 4c 10 f0 	movl   $0xf0104ccc,(%esp)
f0101045:	e8 a7 f0 ff ff       	call   f01000f1 <_panic>
			memset(page2kva(ret), 0, PGSIZE);
f010104a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101051:	00 
f0101052:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101059:	00 
	return (void *)(pa + KERNBASE);
f010105a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010105f:	89 04 24             	mov    %eax,(%esp)
f0101062:	e8 da 2a 00 00       	call   f0103b41 <memset>
		return ret;
	}
	return NULL;
}
f0101067:	89 d8                	mov    %ebx,%eax
f0101069:	83 c4 14             	add    $0x14,%esp
f010106c:	5b                   	pop    %ebx
f010106d:	5d                   	pop    %ebp
f010106e:	c3                   	ret    

f010106f <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010106f:	55                   	push   %ebp
f0101070:	89 e5                	mov    %esp,%ebp
f0101072:	8b 45 08             	mov    0x8(%ebp),%eax
	pp->pp_link = page_free_list;
f0101075:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f010107b:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010107d:	a3 2c 85 11 f0       	mov    %eax,0xf011852c
}
f0101082:	5d                   	pop    %ebp
f0101083:	c3                   	ret    

f0101084 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101084:	55                   	push   %ebp
f0101085:	89 e5                	mov    %esp,%ebp
f0101087:	83 ec 04             	sub    $0x4,%esp
f010108a:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010108d:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0101091:	83 ea 01             	sub    $0x1,%edx
f0101094:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101098:	66 85 d2             	test   %dx,%dx
f010109b:	75 08                	jne    f01010a5 <page_decref+0x21>
		page_free(pp);
f010109d:	89 04 24             	mov    %eax,(%esp)
f01010a0:	e8 ca ff ff ff       	call   f010106f <page_free>
}
f01010a5:	c9                   	leave  
f01010a6:	c3                   	ret    

f01010a7 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01010a7:	55                   	push   %ebp
f01010a8:	89 e5                	mov    %esp,%ebp
f01010aa:	83 ec 18             	sub    $0x18,%esp
f01010ad:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01010b0:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01010b3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int dindex = PDX(va), tindex = PTX(va);
f01010b6:	89 f3                	mov    %esi,%ebx
f01010b8:	c1 eb 16             	shr    $0x16,%ebx
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
f01010bb:	c1 e3 02             	shl    $0x2,%ebx
f01010be:	03 5d 08             	add    0x8(%ebp),%ebx
f01010c1:	f6 03 01             	testb  $0x1,(%ebx)
f01010c4:	75 31                	jne    f01010f7 <pgdir_walk+0x50>
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
			pg->pp_ref++;
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
		} else return NULL;
f01010c6:	b8 00 00 00 00       	mov    $0x0,%eax
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
f01010cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010cf:	74 71                	je     f0101142 <pgdir_walk+0x9b>
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
f01010d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01010d8:	e8 14 ff ff ff       	call   f0100ff1 <page_alloc>
			if (!pg) return NULL;	//allocation fails
f01010dd:	85 c0                	test   %eax,%eax
f01010df:	74 5c                	je     f010113d <pgdir_walk+0x96>
			pg->pp_ref++;
f01010e1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010e6:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f01010ec:	c1 f8 03             	sar    $0x3,%eax
f01010ef:	c1 e0 0c             	shl    $0xc,%eax
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
f01010f2:	83 c8 07             	or     $0x7,%eax
f01010f5:	89 03                	mov    %eax,(%ebx)
		} else return NULL;
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));
f01010f7:	8b 03                	mov    (%ebx),%eax
f01010f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010fe:	89 c2                	mov    %eax,%edx
f0101100:	c1 ea 0c             	shr    $0xc,%edx
f0101103:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0101109:	72 20                	jb     f010112b <pgdir_walk+0x84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010110b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010110f:	c7 44 24 08 50 45 10 	movl   $0xf0104550,0x8(%esp)
f0101116:	f0 
f0101117:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f010111e:	00 
f010111f:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101126:	e8 c6 ef ff ff       	call   f01000f1 <_panic>
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	int dindex = PDX(va), tindex = PTX(va);
f010112b:	c1 ee 0a             	shr    $0xa,%esi
	// 		struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
f010112e:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101134:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f010113b:	eb 05                	jmp    f0101142 <pgdir_walk+0x9b>
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
f010113d:	b8 00 00 00 00       	mov    $0x0,%eax
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
}
f0101142:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101145:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101148:	89 ec                	mov    %ebp,%esp
f010114a:	5d                   	pop    %ebp
f010114b:	c3                   	ret    

f010114c <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010114c:	55                   	push   %ebp
f010114d:	89 e5                	mov    %esp,%ebp
f010114f:	57                   	push   %edi
f0101150:	56                   	push   %esi
f0101151:	53                   	push   %ebx
f0101152:	83 ec 2c             	sub    $0x2c,%esp
f0101155:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101158:	89 d3                	mov    %edx,%ebx
f010115a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f010115d:	c1 e9 0c             	shr    $0xc,%ecx
f0101160:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101163:	85 c9                	test   %ecx,%ecx
f0101165:	74 62                	je     f01011c9 <boot_map_region+0x7d>
f0101167:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
f010116c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010116f:	83 c8 01             	or     $0x1,%eax
f0101172:	89 45 dc             	mov    %eax,-0x24(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f0101175:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010117c:	00 
f010117d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101181:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101184:	89 04 24             	mov    %eax,(%esp)
f0101187:	e8 1b ff ff ff       	call   f01010a7 <pgdir_walk>
		if (!pte) panic("boot_map_region panic, out of memory");
f010118c:	85 c0                	test   %eax,%eax
f010118e:	75 1c                	jne    f01011ac <boot_map_region+0x60>
f0101190:	c7 44 24 08 38 46 10 	movl   $0xf0104638,0x8(%esp)
f0101197:	f0 
f0101198:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
f010119f:	00 
f01011a0:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01011a7:	e8 45 ef ff ff       	call   f01000f1 <_panic>
		*pte = pa | perm | PTE_P;
f01011ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01011af:	09 fa                	or     %edi,%edx
f01011b1:	89 10                	mov    %edx,(%eax)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01011b3:	83 c6 01             	add    $0x1,%esi
f01011b6:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01011b9:	73 0e                	jae    f01011c9 <boot_map_region+0x7d>
f01011bb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01011c1:	81 c7 00 10 00 00    	add    $0x1000,%edi
f01011c7:	eb ac                	jmp    f0101175 <boot_map_region+0x29>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
	}
}
f01011c9:	83 c4 2c             	add    $0x2c,%esp
f01011cc:	5b                   	pop    %ebx
f01011cd:	5e                   	pop    %esi
f01011ce:	5f                   	pop    %edi
f01011cf:	5d                   	pop    %ebp
f01011d0:	c3                   	ret    

f01011d1 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01011d1:	55                   	push   %ebp
f01011d2:	89 e5                	mov    %esp,%ebp
f01011d4:	53                   	push   %ebx
f01011d5:	83 ec 14             	sub    $0x14,%esp
f01011d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
f01011db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01011e2:	00 
f01011e3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01011ed:	89 04 24             	mov    %eax,(%esp)
f01011f0:	e8 b2 fe ff ff       	call   f01010a7 <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f01011f5:	ba 00 00 00 00       	mov    $0x0,%edx
f01011fa:	85 c0                	test   %eax,%eax
f01011fc:	74 44                	je     f0101242 <page_lookup+0x71>
f01011fe:	f6 00 01             	testb  $0x1,(%eax)
f0101201:	74 3a                	je     f010123d <page_lookup+0x6c>
	if (pte_store)
f0101203:	85 db                	test   %ebx,%ebx
f0101205:	74 02                	je     f0101209 <page_lookup+0x38>
		*pte_store = pte;	//found and set
f0101207:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*pte));		
f0101209:	8b 10                	mov    (%eax),%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010120b:	c1 ea 0c             	shr    $0xc,%edx
f010120e:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0101214:	72 1c                	jb     f0101232 <page_lookup+0x61>
		panic("pa2page called with invalid pa");
f0101216:	c7 44 24 08 60 46 10 	movl   $0xf0104660,0x8(%esp)
f010121d:	f0 
f010121e:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0101225:	00 
f0101226:	c7 04 24 cc 4c 10 f0 	movl   $0xf0104ccc,(%esp)
f010122d:	e8 bf ee ff ff       	call   f01000f1 <_panic>
	return &pages[PGNUM(pa)];
f0101232:	c1 e2 03             	shl    $0x3,%edx
f0101235:	03 15 50 89 11 f0    	add    0xf0118950,%edx
f010123b:	eb 05                	jmp    f0101242 <page_lookup+0x71>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f010123d:	ba 00 00 00 00       	mov    $0x0,%edx
	if (pte_store)
		*pte_store = pte;	//found and set
	return pa2page(PTE_ADDR(*pte));		
}
f0101242:	89 d0                	mov    %edx,%eax
f0101244:	83 c4 14             	add    $0x14,%esp
f0101247:	5b                   	pop    %ebx
f0101248:	5d                   	pop    %ebp
f0101249:	c3                   	ret    

f010124a <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010124a:	55                   	push   %ebp
f010124b:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010124d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101250:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101253:	5d                   	pop    %ebp
f0101254:	c3                   	ret    

f0101255 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101255:	55                   	push   %ebp
f0101256:	89 e5                	mov    %esp,%ebp
f0101258:	83 ec 28             	sub    $0x28,%esp
f010125b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010125e:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101261:	8b 75 08             	mov    0x8(%ebp),%esi
f0101264:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte;
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f0101267:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010126a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010126e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101272:	89 34 24             	mov    %esi,(%esp)
f0101275:	e8 57 ff ff ff       	call   f01011d1 <page_lookup>
	if (!pg || !(*pte & PTE_P)) return;	//page not exist
f010127a:	85 c0                	test   %eax,%eax
f010127c:	74 25                	je     f01012a3 <page_remove+0x4e>
f010127e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101281:	f6 02 01             	testb  $0x1,(%edx)
f0101284:	74 1d                	je     f01012a3 <page_remove+0x4e>
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
	page_decref(pg);
f0101286:	89 04 24             	mov    %eax,(%esp)
f0101289:	e8 f6 fd ff ff       	call   f0101084 <page_decref>
//   - The pg table entry corresponding to 'va' should be set to 0.
	*pte = 0;
f010128e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101291:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
//   - The TLB must be invalidated if you remove an entry from
//     the page table.
	tlb_invalidate(pgdir, va);
f0101297:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010129b:	89 34 24             	mov    %esi,(%esp)
f010129e:	e8 a7 ff ff ff       	call   f010124a <tlb_invalidate>
}
f01012a3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01012a6:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01012a9:	89 ec                	mov    %ebp,%esp
f01012ab:	5d                   	pop    %ebp
f01012ac:	c3                   	ret    

f01012ad <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01012ad:	55                   	push   %ebp
f01012ae:	89 e5                	mov    %esp,%ebp
f01012b0:	83 ec 28             	sub    $0x28,%esp
f01012b3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01012b6:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01012b9:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01012bc:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
f01012c2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01012c9:	00 
f01012ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01012d1:	89 04 24             	mov    %eax,(%esp)
f01012d4:	e8 ce fd ff ff       	call   f01010a7 <pgdir_walk>
f01012d9:	89 c3                	mov    %eax,%ebx
	if (!pte) 	//page table not allocated
		return -E_NO_MEM;	
f01012db:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
	if (!pte) 	//page table not allocated
f01012e0:	85 db                	test   %ebx,%ebx
f01012e2:	74 38                	je     f010131c <page_insert+0x6f>
		return -E_NO_MEM;	
	//increase ref count to avoid the corner case that pp is freed before it is inserted.
	pp->pp_ref++;	
f01012e4:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
f01012e9:	f6 03 01             	testb  $0x1,(%ebx)
f01012ec:	74 0f                	je     f01012fd <page_insert+0x50>
		page_remove(pgdir, va);
f01012ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01012f5:	89 04 24             	mov    %eax,(%esp)
f01012f8:	e8 58 ff ff ff       	call   f0101255 <page_remove>
	*pte = page2pa(pp) | perm | PTE_P;
f01012fd:	8b 55 14             	mov    0x14(%ebp),%edx
f0101300:	83 ca 01             	or     $0x1,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101303:	2b 35 50 89 11 f0    	sub    0xf0118950,%esi
f0101309:	c1 fe 03             	sar    $0x3,%esi
f010130c:	89 f0                	mov    %esi,%eax
f010130e:	c1 e0 0c             	shl    $0xc,%eax
f0101311:	89 d6                	mov    %edx,%esi
f0101313:	09 c6                	or     %eax,%esi
f0101315:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101317:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010131c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010131f:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101322:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101325:	89 ec                	mov    %ebp,%esp
f0101327:	5d                   	pop    %ebp
f0101328:	c3                   	ret    

f0101329 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101329:	55                   	push   %ebp
f010132a:	89 e5                	mov    %esp,%ebp
f010132c:	57                   	push   %edi
f010132d:	56                   	push   %esi
f010132e:	53                   	push   %ebx
f010132f:	83 ec 4c             	sub    $0x4c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101332:	b8 15 00 00 00       	mov    $0x15,%eax
f0101337:	e8 42 f8 ff ff       	call   f0100b7e <nvram_read>
f010133c:	c1 e0 0a             	shl    $0xa,%eax
f010133f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101345:	85 c0                	test   %eax,%eax
f0101347:	0f 48 c2             	cmovs  %edx,%eax
f010134a:	c1 f8 0c             	sar    $0xc,%eax
f010134d:	a3 30 85 11 f0       	mov    %eax,0xf0118530
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101352:	b8 17 00 00 00       	mov    $0x17,%eax
f0101357:	e8 22 f8 ff ff       	call   f0100b7e <nvram_read>
f010135c:	c1 e0 0a             	shl    $0xa,%eax
f010135f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101365:	85 c0                	test   %eax,%eax
f0101367:	0f 48 c2             	cmovs  %edx,%eax
f010136a:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010136d:	85 c0                	test   %eax,%eax
f010136f:	74 0e                	je     f010137f <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101371:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101377:	89 15 48 89 11 f0    	mov    %edx,0xf0118948
f010137d:	eb 0c                	jmp    f010138b <mem_init+0x62>
	else
		npages = npages_basemem;
f010137f:	8b 15 30 85 11 f0    	mov    0xf0118530,%edx
f0101385:	89 15 48 89 11 f0    	mov    %edx,0xf0118948

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010138b:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010138e:	c1 e8 0a             	shr    $0xa,%eax
f0101391:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101395:	a1 30 85 11 f0       	mov    0xf0118530,%eax
f010139a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010139d:	c1 e8 0a             	shr    $0xa,%eax
f01013a0:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01013a4:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f01013a9:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013ac:	c1 e8 0a             	shr    $0xa,%eax
f01013af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013b3:	c7 04 24 80 46 10 f0 	movl   $0xf0104680,(%esp)
f01013ba:	e8 a7 1b 00 00       	call   f0102f66 <cprintf>
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013bf:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013c4:	e8 34 f7 ff ff       	call   f0100afd <boot_alloc>
f01013c9:	a3 4c 89 11 f0       	mov    %eax,0xf011894c
	memset(kern_pgdir, 0, PGSIZE);
f01013ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013d5:	00 
f01013d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01013dd:	00 
f01013de:	89 04 24             	mov    %eax,(%esp)
f01013e1:	e8 5b 27 00 00       	call   f0103b41 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013e6:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013eb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013f0:	77 20                	ja     f0101412 <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013f6:	c7 44 24 08 bc 46 10 	movl   $0xf01046bc,0x8(%esp)
f01013fd:	f0 
f01013fe:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
f0101405:	00 
f0101406:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f010140d:	e8 df ec ff ff       	call   f01000f1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101412:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101418:	83 ca 05             	or     $0x5,%edx
f010141b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f0101421:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f0101426:	c1 e0 03             	shl    $0x3,%eax
f0101429:	e8 cf f6 ff ff       	call   f0100afd <boot_alloc>
f010142e:	a3 50 89 11 f0       	mov    %eax,0xf0118950

	cprintf("npages: %d\n", npages);
f0101433:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f0101438:	89 44 24 04          	mov    %eax,0x4(%esp)
f010143c:	c7 04 24 99 4d 10 f0 	movl   $0xf0104d99,(%esp)
f0101443:	e8 1e 1b 00 00       	call   f0102f66 <cprintf>
	cprintf("npages_basemem: %d\n", npages_basemem);
f0101448:	a1 30 85 11 f0       	mov    0xf0118530,%eax
f010144d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101451:	c7 04 24 a5 4d 10 f0 	movl   $0xf0104da5,(%esp)
f0101458:	e8 09 1b 00 00       	call   f0102f66 <cprintf>
	cprintf("pages: %x\n", pages);
f010145d:	a1 50 89 11 f0       	mov    0xf0118950,%eax
f0101462:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101466:	c7 04 24 b9 4d 10 f0 	movl   $0xf0104db9,(%esp)
f010146d:	e8 f4 1a 00 00       	call   f0102f66 <cprintf>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101472:	e8 a1 fa ff ff       	call   f0100f18 <page_init>

	check_page_free_list(1);
f0101477:	b8 01 00 00 00       	mov    $0x1,%eax
f010147c:	e8 2f f7 ff ff       	call   f0100bb0 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101481:	83 3d 50 89 11 f0 00 	cmpl   $0x0,0xf0118950
f0101488:	75 1c                	jne    f01014a6 <mem_init+0x17d>
		panic("'pages' is a null pointer!");
f010148a:	c7 44 24 08 c4 4d 10 	movl   $0xf0104dc4,0x8(%esp)
f0101491:	f0 
f0101492:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
f0101499:	00 
f010149a:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01014a1:	e8 4b ec ff ff       	call   f01000f1 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014a6:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f01014ab:	bb 00 00 00 00       	mov    $0x0,%ebx
f01014b0:	85 c0                	test   %eax,%eax
f01014b2:	74 09                	je     f01014bd <mem_init+0x194>
		++nfree;
f01014b4:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014b7:	8b 00                	mov    (%eax),%eax
f01014b9:	85 c0                	test   %eax,%eax
f01014bb:	75 f7                	jne    f01014b4 <mem_init+0x18b>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014c4:	e8 28 fb ff ff       	call   f0100ff1 <page_alloc>
f01014c9:	89 c6                	mov    %eax,%esi
f01014cb:	85 c0                	test   %eax,%eax
f01014cd:	75 24                	jne    f01014f3 <mem_init+0x1ca>
f01014cf:	c7 44 24 0c df 4d 10 	movl   $0xf0104ddf,0xc(%esp)
f01014d6:	f0 
f01014d7:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01014de:	f0 
f01014df:	c7 44 24 04 57 02 00 	movl   $0x257,0x4(%esp)
f01014e6:	00 
f01014e7:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01014ee:	e8 fe eb ff ff       	call   f01000f1 <_panic>
	assert((pp1 = page_alloc(0)));
f01014f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014fa:	e8 f2 fa ff ff       	call   f0100ff1 <page_alloc>
f01014ff:	89 c7                	mov    %eax,%edi
f0101501:	85 c0                	test   %eax,%eax
f0101503:	75 24                	jne    f0101529 <mem_init+0x200>
f0101505:	c7 44 24 0c f5 4d 10 	movl   $0xf0104df5,0xc(%esp)
f010150c:	f0 
f010150d:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101514:	f0 
f0101515:	c7 44 24 04 58 02 00 	movl   $0x258,0x4(%esp)
f010151c:	00 
f010151d:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101524:	e8 c8 eb ff ff       	call   f01000f1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101529:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101530:	e8 bc fa ff ff       	call   f0100ff1 <page_alloc>
f0101535:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101538:	85 c0                	test   %eax,%eax
f010153a:	75 24                	jne    f0101560 <mem_init+0x237>
f010153c:	c7 44 24 0c 0b 4e 10 	movl   $0xf0104e0b,0xc(%esp)
f0101543:	f0 
f0101544:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f010154b:	f0 
f010154c:	c7 44 24 04 59 02 00 	movl   $0x259,0x4(%esp)
f0101553:	00 
f0101554:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f010155b:	e8 91 eb ff ff       	call   f01000f1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101560:	39 fe                	cmp    %edi,%esi
f0101562:	75 24                	jne    f0101588 <mem_init+0x25f>
f0101564:	c7 44 24 0c 21 4e 10 	movl   $0xf0104e21,0xc(%esp)
f010156b:	f0 
f010156c:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101573:	f0 
f0101574:	c7 44 24 04 5c 02 00 	movl   $0x25c,0x4(%esp)
f010157b:	00 
f010157c:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101583:	e8 69 eb ff ff       	call   f01000f1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101588:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010158b:	74 05                	je     f0101592 <mem_init+0x269>
f010158d:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101590:	75 24                	jne    f01015b6 <mem_init+0x28d>
f0101592:	c7 44 24 0c e0 46 10 	movl   $0xf01046e0,0xc(%esp)
f0101599:	f0 
f010159a:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01015a1:	f0 
f01015a2:	c7 44 24 04 5d 02 00 	movl   $0x25d,0x4(%esp)
f01015a9:	00 
f01015aa:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01015b1:	e8 3b eb ff ff       	call   f01000f1 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015b6:	8b 15 50 89 11 f0    	mov    0xf0118950,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01015bc:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f01015c1:	c1 e0 0c             	shl    $0xc,%eax
f01015c4:	89 f1                	mov    %esi,%ecx
f01015c6:	29 d1                	sub    %edx,%ecx
f01015c8:	c1 f9 03             	sar    $0x3,%ecx
f01015cb:	c1 e1 0c             	shl    $0xc,%ecx
f01015ce:	39 c1                	cmp    %eax,%ecx
f01015d0:	72 24                	jb     f01015f6 <mem_init+0x2cd>
f01015d2:	c7 44 24 0c 33 4e 10 	movl   $0xf0104e33,0xc(%esp)
f01015d9:	f0 
f01015da:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01015e1:	f0 
f01015e2:	c7 44 24 04 5e 02 00 	movl   $0x25e,0x4(%esp)
f01015e9:	00 
f01015ea:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01015f1:	e8 fb ea ff ff       	call   f01000f1 <_panic>
f01015f6:	89 f9                	mov    %edi,%ecx
f01015f8:	29 d1                	sub    %edx,%ecx
f01015fa:	c1 f9 03             	sar    $0x3,%ecx
f01015fd:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101600:	39 c8                	cmp    %ecx,%eax
f0101602:	77 24                	ja     f0101628 <mem_init+0x2ff>
f0101604:	c7 44 24 0c 50 4e 10 	movl   $0xf0104e50,0xc(%esp)
f010160b:	f0 
f010160c:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101613:	f0 
f0101614:	c7 44 24 04 5f 02 00 	movl   $0x25f,0x4(%esp)
f010161b:	00 
f010161c:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101623:	e8 c9 ea ff ff       	call   f01000f1 <_panic>
f0101628:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010162b:	29 d1                	sub    %edx,%ecx
f010162d:	89 ca                	mov    %ecx,%edx
f010162f:	c1 fa 03             	sar    $0x3,%edx
f0101632:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101635:	39 d0                	cmp    %edx,%eax
f0101637:	77 24                	ja     f010165d <mem_init+0x334>
f0101639:	c7 44 24 0c 6d 4e 10 	movl   $0xf0104e6d,0xc(%esp)
f0101640:	f0 
f0101641:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101648:	f0 
f0101649:	c7 44 24 04 60 02 00 	movl   $0x260,0x4(%esp)
f0101650:	00 
f0101651:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101658:	e8 94 ea ff ff       	call   f01000f1 <_panic>


	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010165d:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f0101662:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101665:	c7 05 2c 85 11 f0 00 	movl   $0x0,0xf011852c
f010166c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010166f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101676:	e8 76 f9 ff ff       	call   f0100ff1 <page_alloc>
f010167b:	85 c0                	test   %eax,%eax
f010167d:	74 24                	je     f01016a3 <mem_init+0x37a>
f010167f:	c7 44 24 0c 8a 4e 10 	movl   $0xf0104e8a,0xc(%esp)
f0101686:	f0 
f0101687:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f010168e:	f0 
f010168f:	c7 44 24 04 68 02 00 	movl   $0x268,0x4(%esp)
f0101696:	00 
f0101697:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f010169e:	e8 4e ea ff ff       	call   f01000f1 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01016a3:	89 34 24             	mov    %esi,(%esp)
f01016a6:	e8 c4 f9 ff ff       	call   f010106f <page_free>
	page_free(pp1);
f01016ab:	89 3c 24             	mov    %edi,(%esp)
f01016ae:	e8 bc f9 ff ff       	call   f010106f <page_free>
	page_free(pp2);
f01016b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01016b6:	89 14 24             	mov    %edx,(%esp)
f01016b9:	e8 b1 f9 ff ff       	call   f010106f <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016c5:	e8 27 f9 ff ff       	call   f0100ff1 <page_alloc>
f01016ca:	89 c6                	mov    %eax,%esi
f01016cc:	85 c0                	test   %eax,%eax
f01016ce:	75 24                	jne    f01016f4 <mem_init+0x3cb>
f01016d0:	c7 44 24 0c df 4d 10 	movl   $0xf0104ddf,0xc(%esp)
f01016d7:	f0 
f01016d8:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01016df:	f0 
f01016e0:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
f01016e7:	00 
f01016e8:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01016ef:	e8 fd e9 ff ff       	call   f01000f1 <_panic>
	assert((pp1 = page_alloc(0)));
f01016f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016fb:	e8 f1 f8 ff ff       	call   f0100ff1 <page_alloc>
f0101700:	89 c7                	mov    %eax,%edi
f0101702:	85 c0                	test   %eax,%eax
f0101704:	75 24                	jne    f010172a <mem_init+0x401>
f0101706:	c7 44 24 0c f5 4d 10 	movl   $0xf0104df5,0xc(%esp)
f010170d:	f0 
f010170e:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101715:	f0 
f0101716:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
f010171d:	00 
f010171e:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101725:	e8 c7 e9 ff ff       	call   f01000f1 <_panic>
	assert((pp2 = page_alloc(0)));
f010172a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101731:	e8 bb f8 ff ff       	call   f0100ff1 <page_alloc>
f0101736:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101739:	85 c0                	test   %eax,%eax
f010173b:	75 24                	jne    f0101761 <mem_init+0x438>
f010173d:	c7 44 24 0c 0b 4e 10 	movl   $0xf0104e0b,0xc(%esp)
f0101744:	f0 
f0101745:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f010174c:	f0 
f010174d:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
f0101754:	00 
f0101755:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f010175c:	e8 90 e9 ff ff       	call   f01000f1 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101761:	39 fe                	cmp    %edi,%esi
f0101763:	75 24                	jne    f0101789 <mem_init+0x460>
f0101765:	c7 44 24 0c 21 4e 10 	movl   $0xf0104e21,0xc(%esp)
f010176c:	f0 
f010176d:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101774:	f0 
f0101775:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
f010177c:	00 
f010177d:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101784:	e8 68 e9 ff ff       	call   f01000f1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101789:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010178c:	74 05                	je     f0101793 <mem_init+0x46a>
f010178e:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101791:	75 24                	jne    f01017b7 <mem_init+0x48e>
f0101793:	c7 44 24 0c e0 46 10 	movl   $0xf01046e0,0xc(%esp)
f010179a:	f0 
f010179b:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01017a2:	f0 
f01017a3:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
f01017aa:	00 
f01017ab:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01017b2:	e8 3a e9 ff ff       	call   f01000f1 <_panic>
	assert(!page_alloc(0));
f01017b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017be:	e8 2e f8 ff ff       	call   f0100ff1 <page_alloc>
f01017c3:	85 c0                	test   %eax,%eax
f01017c5:	74 24                	je     f01017eb <mem_init+0x4c2>
f01017c7:	c7 44 24 0c 8a 4e 10 	movl   $0xf0104e8a,0xc(%esp)
f01017ce:	f0 
f01017cf:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01017d6:	f0 
f01017d7:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f01017de:	00 
f01017df:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01017e6:	e8 06 e9 ff ff       	call   f01000f1 <_panic>
f01017eb:	89 f0                	mov    %esi,%eax
f01017ed:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f01017f3:	c1 f8 03             	sar    $0x3,%eax
f01017f6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017f9:	89 c2                	mov    %eax,%edx
f01017fb:	c1 ea 0c             	shr    $0xc,%edx
f01017fe:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0101804:	72 20                	jb     f0101826 <mem_init+0x4fd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101806:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010180a:	c7 44 24 08 50 45 10 	movl   $0xf0104550,0x8(%esp)
f0101811:	f0 
f0101812:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101819:	00 
f010181a:	c7 04 24 cc 4c 10 f0 	movl   $0xf0104ccc,(%esp)
f0101821:	e8 cb e8 ff ff       	call   f01000f1 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101826:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010182d:	00 
f010182e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101835:	00 
	return (void *)(pa + KERNBASE);
f0101836:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010183b:	89 04 24             	mov    %eax,(%esp)
f010183e:	e8 fe 22 00 00       	call   f0103b41 <memset>
	page_free(pp0);
f0101843:	89 34 24             	mov    %esi,(%esp)
f0101846:	e8 24 f8 ff ff       	call   f010106f <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010184b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101852:	e8 9a f7 ff ff       	call   f0100ff1 <page_alloc>
f0101857:	85 c0                	test   %eax,%eax
f0101859:	75 24                	jne    f010187f <mem_init+0x556>
f010185b:	c7 44 24 0c 99 4e 10 	movl   $0xf0104e99,0xc(%esp)
f0101862:	f0 
f0101863:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f010186a:	f0 
f010186b:	c7 44 24 04 7a 02 00 	movl   $0x27a,0x4(%esp)
f0101872:	00 
f0101873:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f010187a:	e8 72 e8 ff ff       	call   f01000f1 <_panic>
	assert(pp && pp0 == pp);
f010187f:	39 c6                	cmp    %eax,%esi
f0101881:	74 24                	je     f01018a7 <mem_init+0x57e>
f0101883:	c7 44 24 0c b7 4e 10 	movl   $0xf0104eb7,0xc(%esp)
f010188a:	f0 
f010188b:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101892:	f0 
f0101893:	c7 44 24 04 7b 02 00 	movl   $0x27b,0x4(%esp)
f010189a:	00 
f010189b:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01018a2:	e8 4a e8 ff ff       	call   f01000f1 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018a7:	89 f2                	mov    %esi,%edx
f01018a9:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f01018af:	c1 fa 03             	sar    $0x3,%edx
f01018b2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018b5:	89 d0                	mov    %edx,%eax
f01018b7:	c1 e8 0c             	shr    $0xc,%eax
f01018ba:	3b 05 48 89 11 f0    	cmp    0xf0118948,%eax
f01018c0:	72 20                	jb     f01018e2 <mem_init+0x5b9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018c2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01018c6:	c7 44 24 08 50 45 10 	movl   $0xf0104550,0x8(%esp)
f01018cd:	f0 
f01018ce:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01018d5:	00 
f01018d6:	c7 04 24 cc 4c 10 f0 	movl   $0xf0104ccc,(%esp)
f01018dd:	e8 0f e8 ff ff       	call   f01000f1 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018e2:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f01018e9:	75 11                	jne    f01018fc <mem_init+0x5d3>
f01018eb:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01018f1:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018f7:	80 38 00             	cmpb   $0x0,(%eax)
f01018fa:	74 24                	je     f0101920 <mem_init+0x5f7>
f01018fc:	c7 44 24 0c c7 4e 10 	movl   $0xf0104ec7,0xc(%esp)
f0101903:	f0 
f0101904:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f010190b:	f0 
f010190c:	c7 44 24 04 7e 02 00 	movl   $0x27e,0x4(%esp)
f0101913:	00 
f0101914:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f010191b:	e8 d1 e7 ff ff       	call   f01000f1 <_panic>
f0101920:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101923:	39 d0                	cmp    %edx,%eax
f0101925:	75 d0                	jne    f01018f7 <mem_init+0x5ce>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101927:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010192a:	89 0d 2c 85 11 f0    	mov    %ecx,0xf011852c

	// free the pages we took
	page_free(pp0);
f0101930:	89 34 24             	mov    %esi,(%esp)
f0101933:	e8 37 f7 ff ff       	call   f010106f <page_free>
	page_free(pp1);
f0101938:	89 3c 24             	mov    %edi,(%esp)
f010193b:	e8 2f f7 ff ff       	call   f010106f <page_free>
	page_free(pp2);
f0101940:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101943:	89 34 24             	mov    %esi,(%esp)
f0101946:	e8 24 f7 ff ff       	call   f010106f <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010194b:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f0101950:	85 c0                	test   %eax,%eax
f0101952:	74 09                	je     f010195d <mem_init+0x634>
		--nfree;
f0101954:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101957:	8b 00                	mov    (%eax),%eax
f0101959:	85 c0                	test   %eax,%eax
f010195b:	75 f7                	jne    f0101954 <mem_init+0x62b>
		--nfree;
	assert(nfree == 0);
f010195d:	85 db                	test   %ebx,%ebx
f010195f:	74 24                	je     f0101985 <mem_init+0x65c>
f0101961:	c7 44 24 0c d1 4e 10 	movl   $0xf0104ed1,0xc(%esp)
f0101968:	f0 
f0101969:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101970:	f0 
f0101971:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f0101978:	00 
f0101979:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101980:	e8 6c e7 ff ff       	call   f01000f1 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101985:	c7 04 24 00 47 10 f0 	movl   $0xf0104700,(%esp)
f010198c:	e8 d5 15 00 00       	call   f0102f66 <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	cprintf("so far so good\n");
f0101991:	c7 04 24 dc 4e 10 f0 	movl   $0xf0104edc,(%esp)
f0101998:	e8 c9 15 00 00       	call   f0102f66 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010199d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019a4:	e8 48 f6 ff ff       	call   f0100ff1 <page_alloc>
f01019a9:	89 c6                	mov    %eax,%esi
f01019ab:	85 c0                	test   %eax,%eax
f01019ad:	75 24                	jne    f01019d3 <mem_init+0x6aa>
f01019af:	c7 44 24 0c df 4d 10 	movl   $0xf0104ddf,0xc(%esp)
f01019b6:	f0 
f01019b7:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01019be:	f0 
f01019bf:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f01019c6:	00 
f01019c7:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01019ce:	e8 1e e7 ff ff       	call   f01000f1 <_panic>
	assert((pp1 = page_alloc(0)));
f01019d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019da:	e8 12 f6 ff ff       	call   f0100ff1 <page_alloc>
f01019df:	89 c7                	mov    %eax,%edi
f01019e1:	85 c0                	test   %eax,%eax
f01019e3:	75 24                	jne    f0101a09 <mem_init+0x6e0>
f01019e5:	c7 44 24 0c f5 4d 10 	movl   $0xf0104df5,0xc(%esp)
f01019ec:	f0 
f01019ed:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01019f4:	f0 
f01019f5:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f01019fc:	00 
f01019fd:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101a04:	e8 e8 e6 ff ff       	call   f01000f1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a10:	e8 dc f5 ff ff       	call   f0100ff1 <page_alloc>
f0101a15:	89 c3                	mov    %eax,%ebx
f0101a17:	85 c0                	test   %eax,%eax
f0101a19:	75 24                	jne    f0101a3f <mem_init+0x716>
f0101a1b:	c7 44 24 0c 0b 4e 10 	movl   $0xf0104e0b,0xc(%esp)
f0101a22:	f0 
f0101a23:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101a2a:	f0 
f0101a2b:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f0101a32:	00 
f0101a33:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101a3a:	e8 b2 e6 ff ff       	call   f01000f1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a3f:	39 fe                	cmp    %edi,%esi
f0101a41:	75 24                	jne    f0101a67 <mem_init+0x73e>
f0101a43:	c7 44 24 0c 21 4e 10 	movl   $0xf0104e21,0xc(%esp)
f0101a4a:	f0 
f0101a4b:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101a52:	f0 
f0101a53:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0101a5a:	00 
f0101a5b:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101a62:	e8 8a e6 ff ff       	call   f01000f1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a67:	39 c7                	cmp    %eax,%edi
f0101a69:	74 04                	je     f0101a6f <mem_init+0x746>
f0101a6b:	39 c6                	cmp    %eax,%esi
f0101a6d:	75 24                	jne    f0101a93 <mem_init+0x76a>
f0101a6f:	c7 44 24 0c e0 46 10 	movl   $0xf01046e0,0xc(%esp)
f0101a76:	f0 
f0101a77:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101a7e:	f0 
f0101a7f:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f0101a86:	00 
f0101a87:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101a8e:	e8 5e e6 ff ff       	call   f01000f1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a93:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f0101a98:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	page_free_list = 0;
f0101a9b:	c7 05 2c 85 11 f0 00 	movl   $0x0,0xf011852c
f0101aa2:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101aa5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101aac:	e8 40 f5 ff ff       	call   f0100ff1 <page_alloc>
f0101ab1:	85 c0                	test   %eax,%eax
f0101ab3:	74 24                	je     f0101ad9 <mem_init+0x7b0>
f0101ab5:	c7 44 24 0c 8a 4e 10 	movl   $0xf0104e8a,0xc(%esp)
f0101abc:	f0 
f0101abd:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101ac4:	f0 
f0101ac5:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0101acc:	00 
f0101acd:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101ad4:	e8 18 e6 ff ff       	call   f01000f1 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ad9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101adc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ae0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101ae7:	00 
f0101ae8:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101aed:	89 04 24             	mov    %eax,(%esp)
f0101af0:	e8 dc f6 ff ff       	call   f01011d1 <page_lookup>
f0101af5:	85 c0                	test   %eax,%eax
f0101af7:	74 24                	je     f0101b1d <mem_init+0x7f4>
f0101af9:	c7 44 24 0c 20 47 10 	movl   $0xf0104720,0xc(%esp)
f0101b00:	f0 
f0101b01:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101b08:	f0 
f0101b09:	c7 44 24 04 f3 02 00 	movl   $0x2f3,0x4(%esp)
f0101b10:	00 
f0101b11:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101b18:	e8 d4 e5 ff ff       	call   f01000f1 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b1d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b24:	00 
f0101b25:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b2c:	00 
f0101b2d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101b31:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101b36:	89 04 24             	mov    %eax,(%esp)
f0101b39:	e8 6f f7 ff ff       	call   f01012ad <page_insert>
f0101b3e:	85 c0                	test   %eax,%eax
f0101b40:	78 24                	js     f0101b66 <mem_init+0x83d>
f0101b42:	c7 44 24 0c 58 47 10 	movl   $0xf0104758,0xc(%esp)
f0101b49:	f0 
f0101b4a:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101b51:	f0 
f0101b52:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f0101b59:	00 
f0101b5a:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101b61:	e8 8b e5 ff ff       	call   f01000f1 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b66:	89 34 24             	mov    %esi,(%esp)
f0101b69:	e8 01 f5 ff ff       	call   f010106f <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b6e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b75:	00 
f0101b76:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b7d:	00 
f0101b7e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101b82:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101b87:	89 04 24             	mov    %eax,(%esp)
f0101b8a:	e8 1e f7 ff ff       	call   f01012ad <page_insert>
f0101b8f:	85 c0                	test   %eax,%eax
f0101b91:	74 24                	je     f0101bb7 <mem_init+0x88e>
f0101b93:	c7 44 24 0c 88 47 10 	movl   $0xf0104788,0xc(%esp)
f0101b9a:	f0 
f0101b9b:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101ba2:	f0 
f0101ba3:	c7 44 24 04 fa 02 00 	movl   $0x2fa,0x4(%esp)
f0101baa:	00 
f0101bab:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101bb2:	e8 3a e5 ff ff       	call   f01000f1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101bb7:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101bbc:	8b 08                	mov    (%eax),%ecx
f0101bbe:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101bc4:	89 f2                	mov    %esi,%edx
f0101bc6:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0101bcc:	c1 fa 03             	sar    $0x3,%edx
f0101bcf:	c1 e2 0c             	shl    $0xc,%edx
f0101bd2:	39 d1                	cmp    %edx,%ecx
f0101bd4:	74 24                	je     f0101bfa <mem_init+0x8d1>
f0101bd6:	c7 44 24 0c b8 47 10 	movl   $0xf01047b8,0xc(%esp)
f0101bdd:	f0 
f0101bde:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101be5:	f0 
f0101be6:	c7 44 24 04 fb 02 00 	movl   $0x2fb,0x4(%esp)
f0101bed:	00 
f0101bee:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101bf5:	e8 f7 e4 ff ff       	call   f01000f1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101bfa:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bff:	e8 88 ee ff ff       	call   f0100a8c <check_va2pa>
f0101c04:	89 fa                	mov    %edi,%edx
f0101c06:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0101c0c:	c1 fa 03             	sar    $0x3,%edx
f0101c0f:	c1 e2 0c             	shl    $0xc,%edx
f0101c12:	39 d0                	cmp    %edx,%eax
f0101c14:	74 24                	je     f0101c3a <mem_init+0x911>
f0101c16:	c7 44 24 0c e0 47 10 	movl   $0xf01047e0,0xc(%esp)
f0101c1d:	f0 
f0101c1e:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101c25:	f0 
f0101c26:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f0101c2d:	00 
f0101c2e:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101c35:	e8 b7 e4 ff ff       	call   f01000f1 <_panic>
	assert(pp1->pp_ref == 1);
f0101c3a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c3f:	74 24                	je     f0101c65 <mem_init+0x93c>
f0101c41:	c7 44 24 0c ec 4e 10 	movl   $0xf0104eec,0xc(%esp)
f0101c48:	f0 
f0101c49:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101c50:	f0 
f0101c51:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0101c58:	00 
f0101c59:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101c60:	e8 8c e4 ff ff       	call   f01000f1 <_panic>
	assert(pp0->pp_ref == 1);
f0101c65:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c6a:	74 24                	je     f0101c90 <mem_init+0x967>
f0101c6c:	c7 44 24 0c fd 4e 10 	movl   $0xf0104efd,0xc(%esp)
f0101c73:	f0 
f0101c74:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101c7b:	f0 
f0101c7c:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f0101c83:	00 
f0101c84:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101c8b:	e8 61 e4 ff ff       	call   f01000f1 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c90:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c97:	00 
f0101c98:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c9f:	00 
f0101ca0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ca4:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101ca9:	89 04 24             	mov    %eax,(%esp)
f0101cac:	e8 fc f5 ff ff       	call   f01012ad <page_insert>
f0101cb1:	85 c0                	test   %eax,%eax
f0101cb3:	74 24                	je     f0101cd9 <mem_init+0x9b0>
f0101cb5:	c7 44 24 0c 10 48 10 	movl   $0xf0104810,0xc(%esp)
f0101cbc:	f0 
f0101cbd:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101cc4:	f0 
f0101cc5:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0101ccc:	00 
f0101ccd:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101cd4:	e8 18 e4 ff ff       	call   f01000f1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cd9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cde:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101ce3:	e8 a4 ed ff ff       	call   f0100a8c <check_va2pa>
f0101ce8:	89 da                	mov    %ebx,%edx
f0101cea:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0101cf0:	c1 fa 03             	sar    $0x3,%edx
f0101cf3:	c1 e2 0c             	shl    $0xc,%edx
f0101cf6:	39 d0                	cmp    %edx,%eax
f0101cf8:	74 24                	je     f0101d1e <mem_init+0x9f5>
f0101cfa:	c7 44 24 0c 4c 48 10 	movl   $0xf010484c,0xc(%esp)
f0101d01:	f0 
f0101d02:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101d09:	f0 
f0101d0a:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0101d11:	00 
f0101d12:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101d19:	e8 d3 e3 ff ff       	call   f01000f1 <_panic>
	assert(pp2->pp_ref == 1);
f0101d1e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d23:	74 24                	je     f0101d49 <mem_init+0xa20>
f0101d25:	c7 44 24 0c 0e 4f 10 	movl   $0xf0104f0e,0xc(%esp)
f0101d2c:	f0 
f0101d2d:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101d34:	f0 
f0101d35:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0101d3c:	00 
f0101d3d:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101d44:	e8 a8 e3 ff ff       	call   f01000f1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d50:	e8 9c f2 ff ff       	call   f0100ff1 <page_alloc>
f0101d55:	85 c0                	test   %eax,%eax
f0101d57:	74 24                	je     f0101d7d <mem_init+0xa54>
f0101d59:	c7 44 24 0c 8a 4e 10 	movl   $0xf0104e8a,0xc(%esp)
f0101d60:	f0 
f0101d61:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101d68:	f0 
f0101d69:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0101d70:	00 
f0101d71:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101d78:	e8 74 e3 ff ff       	call   f01000f1 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d7d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d84:	00 
f0101d85:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d8c:	00 
f0101d8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d91:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101d96:	89 04 24             	mov    %eax,(%esp)
f0101d99:	e8 0f f5 ff ff       	call   f01012ad <page_insert>
f0101d9e:	85 c0                	test   %eax,%eax
f0101da0:	74 24                	je     f0101dc6 <mem_init+0xa9d>
f0101da2:	c7 44 24 0c 10 48 10 	movl   $0xf0104810,0xc(%esp)
f0101da9:	f0 
f0101daa:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101db1:	f0 
f0101db2:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f0101db9:	00 
f0101dba:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101dc1:	e8 2b e3 ff ff       	call   f01000f1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dc6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dcb:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101dd0:	e8 b7 ec ff ff       	call   f0100a8c <check_va2pa>
f0101dd5:	89 da                	mov    %ebx,%edx
f0101dd7:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0101ddd:	c1 fa 03             	sar    $0x3,%edx
f0101de0:	c1 e2 0c             	shl    $0xc,%edx
f0101de3:	39 d0                	cmp    %edx,%eax
f0101de5:	74 24                	je     f0101e0b <mem_init+0xae2>
f0101de7:	c7 44 24 0c 4c 48 10 	movl   $0xf010484c,0xc(%esp)
f0101dee:	f0 
f0101def:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101df6:	f0 
f0101df7:	c7 44 24 04 0a 03 00 	movl   $0x30a,0x4(%esp)
f0101dfe:	00 
f0101dff:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101e06:	e8 e6 e2 ff ff       	call   f01000f1 <_panic>
	assert(pp2->pp_ref == 1);
f0101e0b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e10:	74 24                	je     f0101e36 <mem_init+0xb0d>
f0101e12:	c7 44 24 0c 0e 4f 10 	movl   $0xf0104f0e,0xc(%esp)
f0101e19:	f0 
f0101e1a:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101e21:	f0 
f0101e22:	c7 44 24 04 0b 03 00 	movl   $0x30b,0x4(%esp)
f0101e29:	00 
f0101e2a:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101e31:	e8 bb e2 ff ff       	call   f01000f1 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e3d:	e8 af f1 ff ff       	call   f0100ff1 <page_alloc>
f0101e42:	85 c0                	test   %eax,%eax
f0101e44:	74 24                	je     f0101e6a <mem_init+0xb41>
f0101e46:	c7 44 24 0c 8a 4e 10 	movl   $0xf0104e8a,0xc(%esp)
f0101e4d:	f0 
f0101e4e:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101e55:	f0 
f0101e56:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0101e5d:	00 
f0101e5e:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101e65:	e8 87 e2 ff ff       	call   f01000f1 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e6a:	8b 15 4c 89 11 f0    	mov    0xf011894c,%edx
f0101e70:	8b 02                	mov    (%edx),%eax
f0101e72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e77:	89 c1                	mov    %eax,%ecx
f0101e79:	c1 e9 0c             	shr    $0xc,%ecx
f0101e7c:	3b 0d 48 89 11 f0    	cmp    0xf0118948,%ecx
f0101e82:	72 20                	jb     f0101ea4 <mem_init+0xb7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e84:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e88:	c7 44 24 08 50 45 10 	movl   $0xf0104550,0x8(%esp)
f0101e8f:	f0 
f0101e90:	c7 44 24 04 12 03 00 	movl   $0x312,0x4(%esp)
f0101e97:	00 
f0101e98:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101e9f:	e8 4d e2 ff ff       	call   f01000f1 <_panic>
	return (void *)(pa + KERNBASE);
f0101ea4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ea9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101eac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101eb3:	00 
f0101eb4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ebb:	00 
f0101ebc:	89 14 24             	mov    %edx,(%esp)
f0101ebf:	e8 e3 f1 ff ff       	call   f01010a7 <pgdir_walk>
f0101ec4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101ec7:	83 c2 04             	add    $0x4,%edx
f0101eca:	39 d0                	cmp    %edx,%eax
f0101ecc:	74 24                	je     f0101ef2 <mem_init+0xbc9>
f0101ece:	c7 44 24 0c 7c 48 10 	movl   $0xf010487c,0xc(%esp)
f0101ed5:	f0 
f0101ed6:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101edd:	f0 
f0101ede:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f0101ee5:	00 
f0101ee6:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101eed:	e8 ff e1 ff ff       	call   f01000f1 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ef2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101ef9:	00 
f0101efa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f01:	00 
f0101f02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f06:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101f0b:	89 04 24             	mov    %eax,(%esp)
f0101f0e:	e8 9a f3 ff ff       	call   f01012ad <page_insert>
f0101f13:	85 c0                	test   %eax,%eax
f0101f15:	74 24                	je     f0101f3b <mem_init+0xc12>
f0101f17:	c7 44 24 0c bc 48 10 	movl   $0xf01048bc,0xc(%esp)
f0101f1e:	f0 
f0101f1f:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101f26:	f0 
f0101f27:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f0101f2e:	00 
f0101f2f:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101f36:	e8 b6 e1 ff ff       	call   f01000f1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f3b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f40:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101f45:	e8 42 eb ff ff       	call   f0100a8c <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f4a:	89 da                	mov    %ebx,%edx
f0101f4c:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0101f52:	c1 fa 03             	sar    $0x3,%edx
f0101f55:	c1 e2 0c             	shl    $0xc,%edx
f0101f58:	39 d0                	cmp    %edx,%eax
f0101f5a:	74 24                	je     f0101f80 <mem_init+0xc57>
f0101f5c:	c7 44 24 0c 4c 48 10 	movl   $0xf010484c,0xc(%esp)
f0101f63:	f0 
f0101f64:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101f6b:	f0 
f0101f6c:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f0101f73:	00 
f0101f74:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101f7b:	e8 71 e1 ff ff       	call   f01000f1 <_panic>
	assert(pp2->pp_ref == 1);
f0101f80:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f85:	74 24                	je     f0101fab <mem_init+0xc82>
f0101f87:	c7 44 24 0c 0e 4f 10 	movl   $0xf0104f0e,0xc(%esp)
f0101f8e:	f0 
f0101f8f:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101f96:	f0 
f0101f97:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f0101f9e:	00 
f0101f9f:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101fa6:	e8 46 e1 ff ff       	call   f01000f1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101fab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fb2:	00 
f0101fb3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fba:	00 
f0101fbb:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101fc0:	89 04 24             	mov    %eax,(%esp)
f0101fc3:	e8 df f0 ff ff       	call   f01010a7 <pgdir_walk>
f0101fc8:	f6 00 04             	testb  $0x4,(%eax)
f0101fcb:	75 24                	jne    f0101ff1 <mem_init+0xcc8>
f0101fcd:	c7 44 24 0c fc 48 10 	movl   $0xf01048fc,0xc(%esp)
f0101fd4:	f0 
f0101fd5:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0101fdc:	f0 
f0101fdd:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f0101fe4:	00 
f0101fe5:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0101fec:	e8 00 e1 ff ff       	call   f01000f1 <_panic>
	cprintf("pp2 %x\n", pp2);
f0101ff1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ff5:	c7 04 24 1f 4f 10 f0 	movl   $0xf0104f1f,(%esp)
f0101ffc:	e8 65 0f 00 00       	call   f0102f66 <cprintf>
	cprintf("kern_pgdir %x\n", kern_pgdir);
f0102001:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102006:	89 44 24 04          	mov    %eax,0x4(%esp)
f010200a:	c7 04 24 27 4f 10 f0 	movl   $0xf0104f27,(%esp)
f0102011:	e8 50 0f 00 00       	call   f0102f66 <cprintf>
	cprintf("kern_pgdir[0] is %x\n", kern_pgdir[0]);
f0102016:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f010201b:	8b 00                	mov    (%eax),%eax
f010201d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102021:	c7 04 24 36 4f 10 f0 	movl   $0xf0104f36,(%esp)
f0102028:	e8 39 0f 00 00       	call   f0102f66 <cprintf>
	assert(kern_pgdir[0] & PTE_U);
f010202d:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102032:	f6 00 04             	testb  $0x4,(%eax)
f0102035:	75 24                	jne    f010205b <mem_init+0xd32>
f0102037:	c7 44 24 0c 4b 4f 10 	movl   $0xf0104f4b,0xc(%esp)
f010203e:	f0 
f010203f:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102046:	f0 
f0102047:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f010204e:	00 
f010204f:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102056:	e8 96 e0 ff ff       	call   f01000f1 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010205b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102062:	00 
f0102063:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010206a:	00 
f010206b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010206f:	89 04 24             	mov    %eax,(%esp)
f0102072:	e8 36 f2 ff ff       	call   f01012ad <page_insert>
f0102077:	85 c0                	test   %eax,%eax
f0102079:	74 24                	je     f010209f <mem_init+0xd76>
f010207b:	c7 44 24 0c 10 48 10 	movl   $0xf0104810,0xc(%esp)
f0102082:	f0 
f0102083:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f010208a:	f0 
f010208b:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0102092:	00 
f0102093:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f010209a:	e8 52 e0 ff ff       	call   f01000f1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010209f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020a6:	00 
f01020a7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020ae:	00 
f01020af:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f01020b4:	89 04 24             	mov    %eax,(%esp)
f01020b7:	e8 eb ef ff ff       	call   f01010a7 <pgdir_walk>
f01020bc:	f6 00 02             	testb  $0x2,(%eax)
f01020bf:	75 24                	jne    f01020e5 <mem_init+0xdbc>
f01020c1:	c7 44 24 0c 30 49 10 	movl   $0xf0104930,0xc(%esp)
f01020c8:	f0 
f01020c9:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01020d0:	f0 
f01020d1:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f01020d8:	00 
f01020d9:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01020e0:	e8 0c e0 ff ff       	call   f01000f1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020ec:	00 
f01020ed:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020f4:	00 
f01020f5:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f01020fa:	89 04 24             	mov    %eax,(%esp)
f01020fd:	e8 a5 ef ff ff       	call   f01010a7 <pgdir_walk>
f0102102:	f6 00 04             	testb  $0x4,(%eax)
f0102105:	74 24                	je     f010212b <mem_init+0xe02>
f0102107:	c7 44 24 0c 64 49 10 	movl   $0xf0104964,0xc(%esp)
f010210e:	f0 
f010210f:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102116:	f0 
f0102117:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f010211e:	00 
f010211f:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102126:	e8 c6 df ff ff       	call   f01000f1 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010212b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102132:	00 
f0102133:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010213a:	00 
f010213b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010213f:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102144:	89 04 24             	mov    %eax,(%esp)
f0102147:	e8 61 f1 ff ff       	call   f01012ad <page_insert>
f010214c:	85 c0                	test   %eax,%eax
f010214e:	78 24                	js     f0102174 <mem_init+0xe4b>
f0102150:	c7 44 24 0c 9c 49 10 	movl   $0xf010499c,0xc(%esp)
f0102157:	f0 
f0102158:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f010215f:	f0 
f0102160:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0102167:	00 
f0102168:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f010216f:	e8 7d df ff ff       	call   f01000f1 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102174:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010217b:	00 
f010217c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102183:	00 
f0102184:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102188:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f010218d:	89 04 24             	mov    %eax,(%esp)
f0102190:	e8 18 f1 ff ff       	call   f01012ad <page_insert>
f0102195:	85 c0                	test   %eax,%eax
f0102197:	74 24                	je     f01021bd <mem_init+0xe94>
f0102199:	c7 44 24 0c d4 49 10 	movl   $0xf01049d4,0xc(%esp)
f01021a0:	f0 
f01021a1:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01021a8:	f0 
f01021a9:	c7 44 24 04 28 03 00 	movl   $0x328,0x4(%esp)
f01021b0:	00 
f01021b1:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01021b8:	e8 34 df ff ff       	call   f01000f1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021c4:	00 
f01021c5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021cc:	00 
f01021cd:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f01021d2:	89 04 24             	mov    %eax,(%esp)
f01021d5:	e8 cd ee ff ff       	call   f01010a7 <pgdir_walk>
f01021da:	f6 00 04             	testb  $0x4,(%eax)
f01021dd:	74 24                	je     f0102203 <mem_init+0xeda>
f01021df:	c7 44 24 0c 64 49 10 	movl   $0xf0104964,0xc(%esp)
f01021e6:	f0 
f01021e7:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01021ee:	f0 
f01021ef:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f01021f6:	00 
f01021f7:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01021fe:	e8 ee de ff ff       	call   f01000f1 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102203:	ba 00 00 00 00       	mov    $0x0,%edx
f0102208:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f010220d:	e8 7a e8 ff ff       	call   f0100a8c <check_va2pa>
f0102212:	89 fa                	mov    %edi,%edx
f0102214:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f010221a:	c1 fa 03             	sar    $0x3,%edx
f010221d:	c1 e2 0c             	shl    $0xc,%edx
f0102220:	39 d0                	cmp    %edx,%eax
f0102222:	74 24                	je     f0102248 <mem_init+0xf1f>
f0102224:	c7 44 24 0c 10 4a 10 	movl   $0xf0104a10,0xc(%esp)
f010222b:	f0 
f010222c:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102233:	f0 
f0102234:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f010223b:	00 
f010223c:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102243:	e8 a9 de ff ff       	call   f01000f1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102248:	ba 00 10 00 00       	mov    $0x1000,%edx
f010224d:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102252:	e8 35 e8 ff ff       	call   f0100a8c <check_va2pa>
f0102257:	89 fa                	mov    %edi,%edx
f0102259:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f010225f:	c1 fa 03             	sar    $0x3,%edx
f0102262:	c1 e2 0c             	shl    $0xc,%edx
f0102265:	39 d0                	cmp    %edx,%eax
f0102267:	74 24                	je     f010228d <mem_init+0xf64>
f0102269:	c7 44 24 0c 3c 4a 10 	movl   $0xf0104a3c,0xc(%esp)
f0102270:	f0 
f0102271:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102278:	f0 
f0102279:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f0102280:	00 
f0102281:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102288:	e8 64 de ff ff       	call   f01000f1 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010228d:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102292:	74 24                	je     f01022b8 <mem_init+0xf8f>
f0102294:	c7 44 24 0c 61 4f 10 	movl   $0xf0104f61,0xc(%esp)
f010229b:	f0 
f010229c:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01022a3:	f0 
f01022a4:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f01022ab:	00 
f01022ac:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01022b3:	e8 39 de ff ff       	call   f01000f1 <_panic>
	assert(pp2->pp_ref == 0);
f01022b8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022bd:	74 24                	je     f01022e3 <mem_init+0xfba>
f01022bf:	c7 44 24 0c 72 4f 10 	movl   $0xf0104f72,0xc(%esp)
f01022c6:	f0 
f01022c7:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01022ce:	f0 
f01022cf:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f01022d6:	00 
f01022d7:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01022de:	e8 0e de ff ff       	call   f01000f1 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01022e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022ea:	e8 02 ed ff ff       	call   f0100ff1 <page_alloc>
f01022ef:	85 c0                	test   %eax,%eax
f01022f1:	74 04                	je     f01022f7 <mem_init+0xfce>
f01022f3:	39 c3                	cmp    %eax,%ebx
f01022f5:	74 24                	je     f010231b <mem_init+0xff2>
f01022f7:	c7 44 24 0c 6c 4a 10 	movl   $0xf0104a6c,0xc(%esp)
f01022fe:	f0 
f01022ff:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102306:	f0 
f0102307:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f010230e:	00 
f010230f:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102316:	e8 d6 dd ff ff       	call   f01000f1 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010231b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102322:	00 
f0102323:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102328:	89 04 24             	mov    %eax,(%esp)
f010232b:	e8 25 ef ff ff       	call   f0101255 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102330:	ba 00 00 00 00       	mov    $0x0,%edx
f0102335:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f010233a:	e8 4d e7 ff ff       	call   f0100a8c <check_va2pa>
f010233f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102342:	74 24                	je     f0102368 <mem_init+0x103f>
f0102344:	c7 44 24 0c 90 4a 10 	movl   $0xf0104a90,0xc(%esp)
f010234b:	f0 
f010234c:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102353:	f0 
f0102354:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f010235b:	00 
f010235c:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102363:	e8 89 dd ff ff       	call   f01000f1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102368:	ba 00 10 00 00       	mov    $0x1000,%edx
f010236d:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102372:	e8 15 e7 ff ff       	call   f0100a8c <check_va2pa>
f0102377:	89 fa                	mov    %edi,%edx
f0102379:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f010237f:	c1 fa 03             	sar    $0x3,%edx
f0102382:	c1 e2 0c             	shl    $0xc,%edx
f0102385:	39 d0                	cmp    %edx,%eax
f0102387:	74 24                	je     f01023ad <mem_init+0x1084>
f0102389:	c7 44 24 0c 3c 4a 10 	movl   $0xf0104a3c,0xc(%esp)
f0102390:	f0 
f0102391:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102398:	f0 
f0102399:	c7 44 24 04 38 03 00 	movl   $0x338,0x4(%esp)
f01023a0:	00 
f01023a1:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01023a8:	e8 44 dd ff ff       	call   f01000f1 <_panic>
	assert(pp1->pp_ref == 1);
f01023ad:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01023b2:	74 24                	je     f01023d8 <mem_init+0x10af>
f01023b4:	c7 44 24 0c ec 4e 10 	movl   $0xf0104eec,0xc(%esp)
f01023bb:	f0 
f01023bc:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01023c3:	f0 
f01023c4:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f01023cb:	00 
f01023cc:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01023d3:	e8 19 dd ff ff       	call   f01000f1 <_panic>
	assert(pp2->pp_ref == 0);
f01023d8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023dd:	74 24                	je     f0102403 <mem_init+0x10da>
f01023df:	c7 44 24 0c 72 4f 10 	movl   $0xf0104f72,0xc(%esp)
f01023e6:	f0 
f01023e7:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01023ee:	f0 
f01023ef:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f01023f6:	00 
f01023f7:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01023fe:	e8 ee dc ff ff       	call   f01000f1 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102403:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010240a:	00 
f010240b:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102410:	89 04 24             	mov    %eax,(%esp)
f0102413:	e8 3d ee ff ff       	call   f0101255 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102418:	ba 00 00 00 00       	mov    $0x0,%edx
f010241d:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102422:	e8 65 e6 ff ff       	call   f0100a8c <check_va2pa>
f0102427:	83 f8 ff             	cmp    $0xffffffff,%eax
f010242a:	74 24                	je     f0102450 <mem_init+0x1127>
f010242c:	c7 44 24 0c 90 4a 10 	movl   $0xf0104a90,0xc(%esp)
f0102433:	f0 
f0102434:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f010243b:	f0 
f010243c:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f0102443:	00 
f0102444:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f010244b:	e8 a1 dc ff ff       	call   f01000f1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102450:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102455:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f010245a:	e8 2d e6 ff ff       	call   f0100a8c <check_va2pa>
f010245f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102462:	74 24                	je     f0102488 <mem_init+0x115f>
f0102464:	c7 44 24 0c b4 4a 10 	movl   $0xf0104ab4,0xc(%esp)
f010246b:	f0 
f010246c:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102473:	f0 
f0102474:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f010247b:	00 
f010247c:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102483:	e8 69 dc ff ff       	call   f01000f1 <_panic>
	assert(pp1->pp_ref == 0);
f0102488:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010248d:	74 24                	je     f01024b3 <mem_init+0x118a>
f010248f:	c7 44 24 0c 83 4f 10 	movl   $0xf0104f83,0xc(%esp)
f0102496:	f0 
f0102497:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f010249e:	f0 
f010249f:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f01024a6:	00 
f01024a7:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01024ae:	e8 3e dc ff ff       	call   f01000f1 <_panic>
	assert(pp2->pp_ref == 0);
f01024b3:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024b8:	74 24                	je     f01024de <mem_init+0x11b5>
f01024ba:	c7 44 24 0c 72 4f 10 	movl   $0xf0104f72,0xc(%esp)
f01024c1:	f0 
f01024c2:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01024c9:	f0 
f01024ca:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f01024d1:	00 
f01024d2:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01024d9:	e8 13 dc ff ff       	call   f01000f1 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01024de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024e5:	e8 07 eb ff ff       	call   f0100ff1 <page_alloc>
f01024ea:	85 c0                	test   %eax,%eax
f01024ec:	74 04                	je     f01024f2 <mem_init+0x11c9>
f01024ee:	39 c7                	cmp    %eax,%edi
f01024f0:	74 24                	je     f0102516 <mem_init+0x11ed>
f01024f2:	c7 44 24 0c dc 4a 10 	movl   $0xf0104adc,0xc(%esp)
f01024f9:	f0 
f01024fa:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102501:	f0 
f0102502:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f0102509:	00 
f010250a:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102511:	e8 db db ff ff       	call   f01000f1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102516:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010251d:	e8 cf ea ff ff       	call   f0100ff1 <page_alloc>
f0102522:	85 c0                	test   %eax,%eax
f0102524:	74 24                	je     f010254a <mem_init+0x1221>
f0102526:	c7 44 24 0c 8a 4e 10 	movl   $0xf0104e8a,0xc(%esp)
f010252d:	f0 
f010252e:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102535:	f0 
f0102536:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f010253d:	00 
f010253e:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102545:	e8 a7 db ff ff       	call   f01000f1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010254a:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f010254f:	8b 08                	mov    (%eax),%ecx
f0102551:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102557:	89 f2                	mov    %esi,%edx
f0102559:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f010255f:	c1 fa 03             	sar    $0x3,%edx
f0102562:	c1 e2 0c             	shl    $0xc,%edx
f0102565:	39 d1                	cmp    %edx,%ecx
f0102567:	74 24                	je     f010258d <mem_init+0x1264>
f0102569:	c7 44 24 0c b8 47 10 	movl   $0xf01047b8,0xc(%esp)
f0102570:	f0 
f0102571:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102578:	f0 
f0102579:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f0102580:	00 
f0102581:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102588:	e8 64 db ff ff       	call   f01000f1 <_panic>
	kern_pgdir[0] = 0;
f010258d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102593:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102598:	74 24                	je     f01025be <mem_init+0x1295>
f010259a:	c7 44 24 0c fd 4e 10 	movl   $0xf0104efd,0xc(%esp)
f01025a1:	f0 
f01025a2:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01025a9:	f0 
f01025aa:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f01025b1:	00 
f01025b2:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01025b9:	e8 33 db ff ff       	call   f01000f1 <_panic>
	pp0->pp_ref = 0;
f01025be:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01025c4:	89 34 24             	mov    %esi,(%esp)
f01025c7:	e8 a3 ea ff ff       	call   f010106f <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01025cc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01025d3:	00 
f01025d4:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01025db:	00 
f01025dc:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f01025e1:	89 04 24             	mov    %eax,(%esp)
f01025e4:	e8 be ea ff ff       	call   f01010a7 <pgdir_walk>
f01025e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01025ec:	8b 0d 4c 89 11 f0    	mov    0xf011894c,%ecx
f01025f2:	8b 51 04             	mov    0x4(%ecx),%edx
f01025f5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01025fb:	89 55 c4             	mov    %edx,-0x3c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025fe:	c1 ea 0c             	shr    $0xc,%edx
f0102601:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0102607:	72 23                	jb     f010262c <mem_init+0x1303>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102609:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010260c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102610:	c7 44 24 08 50 45 10 	movl   $0xf0104550,0x8(%esp)
f0102617:	f0 
f0102618:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f010261f:	00 
f0102620:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102627:	e8 c5 da ff ff       	call   f01000f1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010262c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010262f:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102635:	39 d0                	cmp    %edx,%eax
f0102637:	74 24                	je     f010265d <mem_init+0x1334>
f0102639:	c7 44 24 0c 94 4f 10 	movl   $0xf0104f94,0xc(%esp)
f0102640:	f0 
f0102641:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102648:	f0 
f0102649:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0102650:	00 
f0102651:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102658:	e8 94 da ff ff       	call   f01000f1 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010265d:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102664:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010266a:	89 f0                	mov    %esi,%eax
f010266c:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f0102672:	c1 f8 03             	sar    $0x3,%eax
f0102675:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102678:	89 c2                	mov    %eax,%edx
f010267a:	c1 ea 0c             	shr    $0xc,%edx
f010267d:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0102683:	72 20                	jb     f01026a5 <mem_init+0x137c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102685:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102689:	c7 44 24 08 50 45 10 	movl   $0xf0104550,0x8(%esp)
f0102690:	f0 
f0102691:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102698:	00 
f0102699:	c7 04 24 cc 4c 10 f0 	movl   $0xf0104ccc,(%esp)
f01026a0:	e8 4c da ff ff       	call   f01000f1 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01026a5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01026ac:	00 
f01026ad:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01026b4:	00 
	return (void *)(pa + KERNBASE);
f01026b5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026ba:	89 04 24             	mov    %eax,(%esp)
f01026bd:	e8 7f 14 00 00       	call   f0103b41 <memset>
	page_free(pp0);
f01026c2:	89 34 24             	mov    %esi,(%esp)
f01026c5:	e8 a5 e9 ff ff       	call   f010106f <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01026ca:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01026d1:	00 
f01026d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01026d9:	00 
f01026da:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f01026df:	89 04 24             	mov    %eax,(%esp)
f01026e2:	e8 c0 e9 ff ff       	call   f01010a7 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026e7:	89 f2                	mov    %esi,%edx
f01026e9:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f01026ef:	c1 fa 03             	sar    $0x3,%edx
f01026f2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026f5:	89 d0                	mov    %edx,%eax
f01026f7:	c1 e8 0c             	shr    $0xc,%eax
f01026fa:	3b 05 48 89 11 f0    	cmp    0xf0118948,%eax
f0102700:	72 20                	jb     f0102722 <mem_init+0x13f9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102702:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102706:	c7 44 24 08 50 45 10 	movl   $0xf0104550,0x8(%esp)
f010270d:	f0 
f010270e:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102715:	00 
f0102716:	c7 04 24 cc 4c 10 f0 	movl   $0xf0104ccc,(%esp)
f010271d:	e8 cf d9 ff ff       	call   f01000f1 <_panic>
	return (void *)(pa + KERNBASE);
f0102722:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102728:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010272b:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102732:	75 11                	jne    f0102745 <mem_init+0x141c>
f0102734:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010273a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102740:	f6 00 01             	testb  $0x1,(%eax)
f0102743:	74 24                	je     f0102769 <mem_init+0x1440>
f0102745:	c7 44 24 0c ac 4f 10 	movl   $0xf0104fac,0xc(%esp)
f010274c:	f0 
f010274d:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102754:	f0 
f0102755:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f010275c:	00 
f010275d:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102764:	e8 88 d9 ff ff       	call   f01000f1 <_panic>
f0102769:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010276c:	39 d0                	cmp    %edx,%eax
f010276e:	75 d0                	jne    f0102740 <mem_init+0x1417>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102770:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102775:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010277b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102781:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102784:	89 0d 2c 85 11 f0    	mov    %ecx,0xf011852c

	// free the pages we took
	page_free(pp0);
f010278a:	89 34 24             	mov    %esi,(%esp)
f010278d:	e8 dd e8 ff ff       	call   f010106f <page_free>
	page_free(pp1);
f0102792:	89 3c 24             	mov    %edi,(%esp)
f0102795:	e8 d5 e8 ff ff       	call   f010106f <page_free>
	page_free(pp2);
f010279a:	89 1c 24             	mov    %ebx,(%esp)
f010279d:	e8 cd e8 ff ff       	call   f010106f <page_free>

	cprintf("check_page() succeeded!\n");
f01027a2:	c7 04 24 c3 4f 10 f0 	movl   $0xf0104fc3,(%esp)
f01027a9:	e8 b8 07 00 00       	call   f0102f66 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f01027ae:	a1 50 89 11 f0       	mov    0xf0118950,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027b8:	77 20                	ja     f01027da <mem_init+0x14b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027be:	c7 44 24 08 bc 46 10 	movl   $0xf01046bc,0x8(%esp)
f01027c5:	f0 
f01027c6:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
f01027cd:	00 
f01027ce:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01027d5:	e8 17 d9 ff ff       	call   f01000f1 <_panic>
f01027da:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f01027e1:	00 
	return (physaddr_t)kva - KERNBASE;
f01027e2:	05 00 00 00 10       	add    $0x10000000,%eax
f01027e7:	89 04 24             	mov    %eax,(%esp)
f01027ea:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01027ef:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01027f4:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f01027f9:	e8 4e e9 ff ff       	call   f010114c <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027fe:	be 00 e0 10 f0       	mov    $0xf010e000,%esi
f0102803:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102809:	77 20                	ja     f010282b <mem_init+0x1502>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010280b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010280f:	c7 44 24 08 bc 46 10 	movl   $0xf01046bc,0x8(%esp)
f0102816:	f0 
f0102817:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f010281e:	00 
f010281f:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102826:	e8 c6 d8 ff ff       	call   f01000f1 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f010282b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102832:	00 
f0102833:	c7 04 24 00 e0 10 00 	movl   $0x10e000,(%esp)
f010283a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010283f:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102844:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102849:	e8 fe e8 ff ff       	call   f010114c <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f010284e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102855:	00 
f0102856:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010285d:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102862:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102867:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f010286c:	e8 db e8 ff ff       	call   f010114c <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102871:	8b 1d 4c 89 11 f0    	mov    0xf011894c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102877:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f010287c:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102883:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102889:	74 79                	je     f0102904 <mem_init+0x15db>
f010288b:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102890:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102896:	89 d8                	mov    %ebx,%eax
f0102898:	e8 ef e1 ff ff       	call   f0100a8c <check_va2pa>
f010289d:	8b 15 50 89 11 f0    	mov    0xf0118950,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028a3:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01028a9:	77 20                	ja     f01028cb <mem_init+0x15a2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01028af:	c7 44 24 08 bc 46 10 	movl   $0xf01046bc,0x8(%esp)
f01028b6:	f0 
f01028b7:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
f01028be:	00 
f01028bf:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01028c6:	e8 26 d8 ff ff       	call   f01000f1 <_panic>
f01028cb:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01028d2:	39 d0                	cmp    %edx,%eax
f01028d4:	74 24                	je     f01028fa <mem_init+0x15d1>
f01028d6:	c7 44 24 0c 00 4b 10 	movl   $0xf0104b00,0xc(%esp)
f01028dd:	f0 
f01028de:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01028e5:	f0 
f01028e6:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
f01028ed:	00 
f01028ee:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01028f5:	e8 f7 d7 ff ff       	call   f01000f1 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01028fa:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102900:	39 f7                	cmp    %esi,%edi
f0102902:	77 8c                	ja     f0102890 <mem_init+0x1567>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102904:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f0102909:	c1 e0 0c             	shl    $0xc,%eax
f010290c:	85 c0                	test   %eax,%eax
f010290e:	74 4c                	je     f010295c <mem_init+0x1633>
f0102910:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102915:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f010291b:	89 d8                	mov    %ebx,%eax
f010291d:	e8 6a e1 ff ff       	call   f0100a8c <check_va2pa>
f0102922:	39 c6                	cmp    %eax,%esi
f0102924:	74 24                	je     f010294a <mem_init+0x1621>
f0102926:	c7 44 24 0c 34 4b 10 	movl   $0xf0104b34,0xc(%esp)
f010292d:	f0 
f010292e:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102935:	f0 
f0102936:	c7 44 24 04 a7 02 00 	movl   $0x2a7,0x4(%esp)
f010293d:	00 
f010293e:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102945:	e8 a7 d7 ff ff       	call   f01000f1 <_panic>
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010294a:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102950:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f0102955:	c1 e0 0c             	shl    $0xc,%eax
f0102958:	39 c6                	cmp    %eax,%esi
f010295a:	72 b9                	jb     f0102915 <mem_init+0x15ec>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010295c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102961:	89 d8                	mov    %ebx,%eax
f0102963:	e8 24 e1 ff ff       	call   f0100a8c <check_va2pa>
f0102968:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010296d:	bf 00 e0 10 f0       	mov    $0xf010e000,%edi
f0102972:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102978:	8d 14 37             	lea    (%edi,%esi,1),%edx
f010297b:	39 d0                	cmp    %edx,%eax
f010297d:	74 24                	je     f01029a3 <mem_init+0x167a>
f010297f:	c7 44 24 0c 5c 4b 10 	movl   $0xf0104b5c,0xc(%esp)
f0102986:	f0 
f0102987:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f010298e:	f0 
f010298f:	c7 44 24 04 ab 02 00 	movl   $0x2ab,0x4(%esp)
f0102996:	00 
f0102997:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f010299e:	e8 4e d7 ff ff       	call   f01000f1 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029a3:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01029a9:	0f 85 34 05 00 00    	jne    f0102ee3 <mem_init+0x1bba>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01029af:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01029b4:	89 d8                	mov    %ebx,%eax
f01029b6:	e8 d1 e0 ff ff       	call   f0100a8c <check_va2pa>
f01029bb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029be:	74 24                	je     f01029e4 <mem_init+0x16bb>
f01029c0:	c7 44 24 0c a4 4b 10 	movl   $0xf0104ba4,0xc(%esp)
f01029c7:	f0 
f01029c8:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f01029cf:	f0 
f01029d0:	c7 44 24 04 ac 02 00 	movl   $0x2ac,0x4(%esp)
f01029d7:	00 
f01029d8:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f01029df:	e8 0d d7 ff ff       	call   f01000f1 <_panic>
f01029e4:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01029e9:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
f01029ee:	8d 88 44 fc ff ff    	lea    -0x3bc(%eax),%ecx
f01029f4:	83 f9 03             	cmp    $0x3,%ecx
f01029f7:	77 36                	ja     f0102a2f <mem_init+0x1706>
f01029f9:	89 d6                	mov    %edx,%esi
f01029fb:	d3 e6                	shl    %cl,%esi
f01029fd:	85 f6                	test   %esi,%esi
f01029ff:	79 2e                	jns    f0102a2f <mem_init+0x1706>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102a01:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102a05:	0f 85 aa 00 00 00    	jne    f0102ab5 <mem_init+0x178c>
f0102a0b:	c7 44 24 0c dc 4f 10 	movl   $0xf0104fdc,0xc(%esp)
f0102a12:	f0 
f0102a13:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102a1a:	f0 
f0102a1b:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f0102a22:	00 
f0102a23:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102a2a:	e8 c2 d6 ff ff       	call   f01000f1 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102a2f:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a34:	76 55                	jbe    f0102a8b <mem_init+0x1762>
				assert(pgdir[i] & PTE_P);
f0102a36:	8b 0c 83             	mov    (%ebx,%eax,4),%ecx
f0102a39:	f6 c1 01             	test   $0x1,%cl
f0102a3c:	75 24                	jne    f0102a62 <mem_init+0x1739>
f0102a3e:	c7 44 24 0c dc 4f 10 	movl   $0xf0104fdc,0xc(%esp)
f0102a45:	f0 
f0102a46:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102a4d:	f0 
f0102a4e:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
f0102a55:	00 
f0102a56:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102a5d:	e8 8f d6 ff ff       	call   f01000f1 <_panic>
				assert(pgdir[i] & PTE_W);
f0102a62:	f6 c1 02             	test   $0x2,%cl
f0102a65:	75 4e                	jne    f0102ab5 <mem_init+0x178c>
f0102a67:	c7 44 24 0c ed 4f 10 	movl   $0xf0104fed,0xc(%esp)
f0102a6e:	f0 
f0102a6f:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102a76:	f0 
f0102a77:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f0102a7e:	00 
f0102a7f:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102a86:	e8 66 d6 ff ff       	call   f01000f1 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102a8b:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102a8f:	74 24                	je     f0102ab5 <mem_init+0x178c>
f0102a91:	c7 44 24 0c fe 4f 10 	movl   $0xf0104ffe,0xc(%esp)
f0102a98:	f0 
f0102a99:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102aa0:	f0 
f0102aa1:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f0102aa8:	00 
f0102aa9:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102ab0:	e8 3c d6 ff ff       	call   f01000f1 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102ab5:	83 c0 01             	add    $0x1,%eax
f0102ab8:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102abd:	0f 85 2b ff ff ff    	jne    f01029ee <mem_init+0x16c5>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102ac3:	c7 04 24 d4 4b 10 f0 	movl   $0xf0104bd4,(%esp)
f0102aca:	e8 97 04 00 00       	call   f0102f66 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102acf:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ad4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ad9:	77 20                	ja     f0102afb <mem_init+0x17d2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102adb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102adf:	c7 44 24 08 bc 46 10 	movl   $0xf01046bc,0x8(%esp)
f0102ae6:	f0 
f0102ae7:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
f0102aee:	00 
f0102aef:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102af6:	e8 f6 d5 ff ff       	call   f01000f1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102afb:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102b00:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102b03:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b08:	e8 a3 e0 ff ff       	call   f0100bb0 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102b0d:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102b10:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b15:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102b18:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b22:	e8 ca e4 ff ff       	call   f0100ff1 <page_alloc>
f0102b27:	89 c6                	mov    %eax,%esi
f0102b29:	85 c0                	test   %eax,%eax
f0102b2b:	75 24                	jne    f0102b51 <mem_init+0x1828>
f0102b2d:	c7 44 24 0c df 4d 10 	movl   $0xf0104ddf,0xc(%esp)
f0102b34:	f0 
f0102b35:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102b3c:	f0 
f0102b3d:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102b44:	00 
f0102b45:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102b4c:	e8 a0 d5 ff ff       	call   f01000f1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b58:	e8 94 e4 ff ff       	call   f0100ff1 <page_alloc>
f0102b5d:	89 c7                	mov    %eax,%edi
f0102b5f:	85 c0                	test   %eax,%eax
f0102b61:	75 24                	jne    f0102b87 <mem_init+0x185e>
f0102b63:	c7 44 24 0c f5 4d 10 	movl   $0xf0104df5,0xc(%esp)
f0102b6a:	f0 
f0102b6b:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102b72:	f0 
f0102b73:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0102b7a:	00 
f0102b7b:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102b82:	e8 6a d5 ff ff       	call   f01000f1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102b87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b8e:	e8 5e e4 ff ff       	call   f0100ff1 <page_alloc>
f0102b93:	89 c3                	mov    %eax,%ebx
f0102b95:	85 c0                	test   %eax,%eax
f0102b97:	75 24                	jne    f0102bbd <mem_init+0x1894>
f0102b99:	c7 44 24 0c 0b 4e 10 	movl   $0xf0104e0b,0xc(%esp)
f0102ba0:	f0 
f0102ba1:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102ba8:	f0 
f0102ba9:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0102bb0:	00 
f0102bb1:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102bb8:	e8 34 d5 ff ff       	call   f01000f1 <_panic>
	page_free(pp0);
f0102bbd:	89 34 24             	mov    %esi,(%esp)
f0102bc0:	e8 aa e4 ff ff       	call   f010106f <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bc5:	89 f8                	mov    %edi,%eax
f0102bc7:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f0102bcd:	c1 f8 03             	sar    $0x3,%eax
f0102bd0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bd3:	89 c2                	mov    %eax,%edx
f0102bd5:	c1 ea 0c             	shr    $0xc,%edx
f0102bd8:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0102bde:	72 20                	jb     f0102c00 <mem_init+0x18d7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102be0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102be4:	c7 44 24 08 50 45 10 	movl   $0xf0104550,0x8(%esp)
f0102beb:	f0 
f0102bec:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102bf3:	00 
f0102bf4:	c7 04 24 cc 4c 10 f0 	movl   $0xf0104ccc,(%esp)
f0102bfb:	e8 f1 d4 ff ff       	call   f01000f1 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c00:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c07:	00 
f0102c08:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102c0f:	00 
	return (void *)(pa + KERNBASE);
f0102c10:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c15:	89 04 24             	mov    %eax,(%esp)
f0102c18:	e8 24 0f 00 00       	call   f0103b41 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c1d:	89 d8                	mov    %ebx,%eax
f0102c1f:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f0102c25:	c1 f8 03             	sar    $0x3,%eax
f0102c28:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c2b:	89 c2                	mov    %eax,%edx
f0102c2d:	c1 ea 0c             	shr    $0xc,%edx
f0102c30:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0102c36:	72 20                	jb     f0102c58 <mem_init+0x192f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c38:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c3c:	c7 44 24 08 50 45 10 	movl   $0xf0104550,0x8(%esp)
f0102c43:	f0 
f0102c44:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102c4b:	00 
f0102c4c:	c7 04 24 cc 4c 10 f0 	movl   $0xf0104ccc,(%esp)
f0102c53:	e8 99 d4 ff ff       	call   f01000f1 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c58:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c5f:	00 
f0102c60:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102c67:	00 
	return (void *)(pa + KERNBASE);
f0102c68:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c6d:	89 04 24             	mov    %eax,(%esp)
f0102c70:	e8 cc 0e 00 00       	call   f0103b41 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c75:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102c7c:	00 
f0102c7d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c84:	00 
f0102c85:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102c89:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102c8e:	89 04 24             	mov    %eax,(%esp)
f0102c91:	e8 17 e6 ff ff       	call   f01012ad <page_insert>
	assert(pp1->pp_ref == 1);
f0102c96:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c9b:	74 24                	je     f0102cc1 <mem_init+0x1998>
f0102c9d:	c7 44 24 0c ec 4e 10 	movl   $0xf0104eec,0xc(%esp)
f0102ca4:	f0 
f0102ca5:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102cac:	f0 
f0102cad:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0102cb4:	00 
f0102cb5:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102cbc:	e8 30 d4 ff ff       	call   f01000f1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cc1:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cc8:	01 01 01 
f0102ccb:	74 24                	je     f0102cf1 <mem_init+0x19c8>
f0102ccd:	c7 44 24 0c f4 4b 10 	movl   $0xf0104bf4,0xc(%esp)
f0102cd4:	f0 
f0102cd5:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102cdc:	f0 
f0102cdd:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0102ce4:	00 
f0102ce5:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102cec:	e8 00 d4 ff ff       	call   f01000f1 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102cf1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102cf8:	00 
f0102cf9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102d00:	00 
f0102d01:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102d05:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102d0a:	89 04 24             	mov    %eax,(%esp)
f0102d0d:	e8 9b e5 ff ff       	call   f01012ad <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d12:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d19:	02 02 02 
f0102d1c:	74 24                	je     f0102d42 <mem_init+0x1a19>
f0102d1e:	c7 44 24 0c 18 4c 10 	movl   $0xf0104c18,0xc(%esp)
f0102d25:	f0 
f0102d26:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102d2d:	f0 
f0102d2e:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f0102d35:	00 
f0102d36:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102d3d:	e8 af d3 ff ff       	call   f01000f1 <_panic>
	assert(pp2->pp_ref == 1);
f0102d42:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d47:	74 24                	je     f0102d6d <mem_init+0x1a44>
f0102d49:	c7 44 24 0c 0e 4f 10 	movl   $0xf0104f0e,0xc(%esp)
f0102d50:	f0 
f0102d51:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102d58:	f0 
f0102d59:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0102d60:	00 
f0102d61:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102d68:	e8 84 d3 ff ff       	call   f01000f1 <_panic>
	assert(pp1->pp_ref == 0);
f0102d6d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d72:	74 24                	je     f0102d98 <mem_init+0x1a6f>
f0102d74:	c7 44 24 0c 83 4f 10 	movl   $0xf0104f83,0xc(%esp)
f0102d7b:	f0 
f0102d7c:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102d83:	f0 
f0102d84:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102d8b:	00 
f0102d8c:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102d93:	e8 59 d3 ff ff       	call   f01000f1 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d98:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d9f:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102da2:	89 d8                	mov    %ebx,%eax
f0102da4:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f0102daa:	c1 f8 03             	sar    $0x3,%eax
f0102dad:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102db0:	89 c2                	mov    %eax,%edx
f0102db2:	c1 ea 0c             	shr    $0xc,%edx
f0102db5:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0102dbb:	72 20                	jb     f0102ddd <mem_init+0x1ab4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102dbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102dc1:	c7 44 24 08 50 45 10 	movl   $0xf0104550,0x8(%esp)
f0102dc8:	f0 
f0102dc9:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102dd0:	00 
f0102dd1:	c7 04 24 cc 4c 10 f0 	movl   $0xf0104ccc,(%esp)
f0102dd8:	e8 14 d3 ff ff       	call   f01000f1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ddd:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102de4:	03 03 03 
f0102de7:	74 24                	je     f0102e0d <mem_init+0x1ae4>
f0102de9:	c7 44 24 0c 3c 4c 10 	movl   $0xf0104c3c,0xc(%esp)
f0102df0:	f0 
f0102df1:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102df8:	f0 
f0102df9:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0102e00:	00 
f0102e01:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102e08:	e8 e4 d2 ff ff       	call   f01000f1 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e0d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102e14:	00 
f0102e15:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102e1a:	89 04 24             	mov    %eax,(%esp)
f0102e1d:	e8 33 e4 ff ff       	call   f0101255 <page_remove>
	assert(pp2->pp_ref == 0);
f0102e22:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102e27:	74 24                	je     f0102e4d <mem_init+0x1b24>
f0102e29:	c7 44 24 0c 72 4f 10 	movl   $0xf0104f72,0xc(%esp)
f0102e30:	f0 
f0102e31:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102e38:	f0 
f0102e39:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0102e40:	00 
f0102e41:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102e48:	e8 a4 d2 ff ff       	call   f01000f1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e4d:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102e52:	8b 08                	mov    (%eax),%ecx
f0102e54:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e5a:	89 f2                	mov    %esi,%edx
f0102e5c:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0102e62:	c1 fa 03             	sar    $0x3,%edx
f0102e65:	c1 e2 0c             	shl    $0xc,%edx
f0102e68:	39 d1                	cmp    %edx,%ecx
f0102e6a:	74 24                	je     f0102e90 <mem_init+0x1b67>
f0102e6c:	c7 44 24 0c b8 47 10 	movl   $0xf01047b8,0xc(%esp)
f0102e73:	f0 
f0102e74:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102e7b:	f0 
f0102e7c:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0102e83:	00 
f0102e84:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102e8b:	e8 61 d2 ff ff       	call   f01000f1 <_panic>
	kern_pgdir[0] = 0;
f0102e90:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102e96:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e9b:	74 24                	je     f0102ec1 <mem_init+0x1b98>
f0102e9d:	c7 44 24 0c fd 4e 10 	movl   $0xf0104efd,0xc(%esp)
f0102ea4:	f0 
f0102ea5:	c7 44 24 08 e6 4c 10 	movl   $0xf0104ce6,0x8(%esp)
f0102eac:	f0 
f0102ead:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f0102eb4:	00 
f0102eb5:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0102ebc:	e8 30 d2 ff ff       	call   f01000f1 <_panic>
	pp0->pp_ref = 0;
f0102ec1:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102ec7:	89 34 24             	mov    %esi,(%esp)
f0102eca:	e8 a0 e1 ff ff       	call   f010106f <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102ecf:	c7 04 24 68 4c 10 f0 	movl   $0xf0104c68,(%esp)
f0102ed6:	e8 8b 00 00 00       	call   f0102f66 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102edb:	83 c4 4c             	add    $0x4c,%esp
f0102ede:	5b                   	pop    %ebx
f0102edf:	5e                   	pop    %esi
f0102ee0:	5f                   	pop    %edi
f0102ee1:	5d                   	pop    %ebp
f0102ee2:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102ee3:	89 f2                	mov    %esi,%edx
f0102ee5:	89 d8                	mov    %ebx,%eax
f0102ee7:	e8 a0 db ff ff       	call   f0100a8c <check_va2pa>
f0102eec:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102ef2:	e9 81 fa ff ff       	jmp    f0102978 <mem_init+0x164f>
	...

f0102ef8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102ef8:	55                   	push   %ebp
f0102ef9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102efb:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f00:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f03:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102f04:	b2 71                	mov    $0x71,%dl
f0102f06:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102f07:	0f b6 c0             	movzbl %al,%eax
}
f0102f0a:	5d                   	pop    %ebp
f0102f0b:	c3                   	ret    

f0102f0c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102f0c:	55                   	push   %ebp
f0102f0d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f0f:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f14:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f17:	ee                   	out    %al,(%dx)
f0102f18:	b2 71                	mov    $0x71,%dl
f0102f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f1d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102f1e:	5d                   	pop    %ebp
f0102f1f:	c3                   	ret    

f0102f20 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102f20:	55                   	push   %ebp
f0102f21:	89 e5                	mov    %esp,%ebp
f0102f23:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102f26:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f29:	89 04 24             	mov    %eax,(%esp)
f0102f2c:	e8 40 d7 ff ff       	call   f0100671 <cputchar>
	*cnt++;
}
f0102f31:	c9                   	leave  
f0102f32:	c3                   	ret    

f0102f33 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102f33:	55                   	push   %ebp
f0102f34:	89 e5                	mov    %esp,%ebp
f0102f36:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102f39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102f40:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f43:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f47:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f4a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102f51:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f55:	c7 04 24 20 2f 10 f0 	movl   $0xf0102f20,(%esp)
f0102f5c:	e8 20 05 00 00       	call   f0103481 <vprintfmt>
	return cnt;
}
f0102f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f64:	c9                   	leave  
f0102f65:	c3                   	ret    

f0102f66 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102f66:	55                   	push   %ebp
f0102f67:	89 e5                	mov    %esp,%ebp
f0102f69:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102f6c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f73:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f76:	89 04 24             	mov    %eax,(%esp)
f0102f79:	e8 b5 ff ff ff       	call   f0102f33 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102f7e:	c9                   	leave  
f0102f7f:	c3                   	ret    

f0102f80 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102f80:	55                   	push   %ebp
f0102f81:	89 e5                	mov    %esp,%ebp
f0102f83:	57                   	push   %edi
f0102f84:	56                   	push   %esi
f0102f85:	53                   	push   %ebx
f0102f86:	83 ec 14             	sub    $0x14,%esp
f0102f89:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102f8c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102f8f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102f92:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102f95:	8b 1a                	mov    (%edx),%ebx
f0102f97:	8b 01                	mov    (%ecx),%eax
f0102f99:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0102f9c:	39 c3                	cmp    %eax,%ebx
f0102f9e:	0f 8f 9c 00 00 00    	jg     f0103040 <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0102fa4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102fab:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102fae:	01 d8                	add    %ebx,%eax
f0102fb0:	89 c7                	mov    %eax,%edi
f0102fb2:	c1 ef 1f             	shr    $0x1f,%edi
f0102fb5:	01 c7                	add    %eax,%edi
f0102fb7:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102fb9:	39 df                	cmp    %ebx,%edi
f0102fbb:	7c 33                	jl     f0102ff0 <stab_binsearch+0x70>
f0102fbd:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0102fc0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102fc3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0102fc8:	39 f0                	cmp    %esi,%eax
f0102fca:	0f 84 bc 00 00 00    	je     f010308c <stab_binsearch+0x10c>
f0102fd0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102fd4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102fd8:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102fda:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102fdd:	39 d8                	cmp    %ebx,%eax
f0102fdf:	7c 0f                	jl     f0102ff0 <stab_binsearch+0x70>
f0102fe1:	0f b6 0a             	movzbl (%edx),%ecx
f0102fe4:	83 ea 0c             	sub    $0xc,%edx
f0102fe7:	39 f1                	cmp    %esi,%ecx
f0102fe9:	75 ef                	jne    f0102fda <stab_binsearch+0x5a>
f0102feb:	e9 9e 00 00 00       	jmp    f010308e <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102ff0:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0102ff3:	eb 3c                	jmp    f0103031 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102ff5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102ff8:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0102ffa:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102ffd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103004:	eb 2b                	jmp    f0103031 <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103006:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103009:	76 14                	jbe    f010301f <stab_binsearch+0x9f>
			*region_right = m - 1;
f010300b:	83 e8 01             	sub    $0x1,%eax
f010300e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103011:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103014:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103016:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010301d:	eb 12                	jmp    f0103031 <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010301f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103022:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103024:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103028:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010302a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103031:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103034:	0f 8d 71 ff ff ff    	jge    f0102fab <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010303a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010303e:	75 0f                	jne    f010304f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0103040:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103043:	8b 03                	mov    (%ebx),%eax
f0103045:	83 e8 01             	sub    $0x1,%eax
f0103048:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010304b:	89 02                	mov    %eax,(%edx)
f010304d:	eb 57                	jmp    f01030a6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010304f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103052:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103054:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103057:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103059:	39 c1                	cmp    %eax,%ecx
f010305b:	7d 28                	jge    f0103085 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010305d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103060:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103063:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0103068:	39 f2                	cmp    %esi,%edx
f010306a:	74 19                	je     f0103085 <stab_binsearch+0x105>
f010306c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103070:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103074:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103077:	39 c1                	cmp    %eax,%ecx
f0103079:	7d 0a                	jge    f0103085 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010307b:	0f b6 1a             	movzbl (%edx),%ebx
f010307e:	83 ea 0c             	sub    $0xc,%edx
f0103081:	39 f3                	cmp    %esi,%ebx
f0103083:	75 ef                	jne    f0103074 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103085:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103088:	89 02                	mov    %eax,(%edx)
f010308a:	eb 1a                	jmp    f01030a6 <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010308c:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010308e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103091:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103094:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103098:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010309b:	0f 82 54 ff ff ff    	jb     f0102ff5 <stab_binsearch+0x75>
f01030a1:	e9 60 ff ff ff       	jmp    f0103006 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01030a6:	83 c4 14             	add    $0x14,%esp
f01030a9:	5b                   	pop    %ebx
f01030aa:	5e                   	pop    %esi
f01030ab:	5f                   	pop    %edi
f01030ac:	5d                   	pop    %ebp
f01030ad:	c3                   	ret    

f01030ae <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01030ae:	55                   	push   %ebp
f01030af:	89 e5                	mov    %esp,%ebp
f01030b1:	83 ec 58             	sub    $0x58,%esp
f01030b4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01030b7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01030ba:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01030bd:	8b 75 08             	mov    0x8(%ebp),%esi
f01030c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01030c3:	c7 03 0c 50 10 f0    	movl   $0xf010500c,(%ebx)
	info->eip_line = 0;
f01030c9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01030d0:	c7 43 08 0c 50 10 f0 	movl   $0xf010500c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01030d7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01030de:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01030e1:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01030e8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01030ee:	76 12                	jbe    f0103102 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01030f0:	b8 e2 d3 10 f0       	mov    $0xf010d3e2,%eax
f01030f5:	3d 65 b5 10 f0       	cmp    $0xf010b565,%eax
f01030fa:	0f 86 a9 01 00 00    	jbe    f01032a9 <debuginfo_eip+0x1fb>
f0103100:	eb 1c                	jmp    f010311e <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0103102:	c7 44 24 08 16 50 10 	movl   $0xf0105016,0x8(%esp)
f0103109:	f0 
f010310a:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0103111:	00 
f0103112:	c7 04 24 23 50 10 f0 	movl   $0xf0105023,(%esp)
f0103119:	e8 d3 cf ff ff       	call   f01000f1 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010311e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103123:	80 3d e1 d3 10 f0 00 	cmpb   $0x0,0xf010d3e1
f010312a:	0f 85 85 01 00 00    	jne    f01032b5 <debuginfo_eip+0x207>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103130:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103137:	b8 64 b5 10 f0       	mov    $0xf010b564,%eax
f010313c:	2d 40 52 10 f0       	sub    $0xf0105240,%eax
f0103141:	c1 f8 02             	sar    $0x2,%eax
f0103144:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010314a:	83 e8 01             	sub    $0x1,%eax
f010314d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103150:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103154:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010315b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010315e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103161:	b8 40 52 10 f0       	mov    $0xf0105240,%eax
f0103166:	e8 15 fe ff ff       	call   f0102f80 <stab_binsearch>
	if (lfile == 0)
f010316b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f010316e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0103173:	85 d2                	test   %edx,%edx
f0103175:	0f 84 3a 01 00 00    	je     f01032b5 <debuginfo_eip+0x207>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010317b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f010317e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103181:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103184:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103188:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010318f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103192:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103195:	b8 40 52 10 f0       	mov    $0xf0105240,%eax
f010319a:	e8 e1 fd ff ff       	call   f0102f80 <stab_binsearch>

	if (lfun <= rfun) {
f010319f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01031a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01031a5:	39 d0                	cmp    %edx,%eax
f01031a7:	7f 3a                	jg     f01031e3 <debuginfo_eip+0x135>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01031a9:	6b c8 0c             	imul   $0xc,%eax,%ecx
f01031ac:	8b 89 40 52 10 f0    	mov    -0xfefadc0(%ecx),%ecx
f01031b2:	bf e2 d3 10 f0       	mov    $0xf010d3e2,%edi
f01031b7:	81 ef 65 b5 10 f0    	sub    $0xf010b565,%edi
f01031bd:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01031c0:	39 f9                	cmp    %edi,%ecx
f01031c2:	73 09                	jae    f01031cd <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01031c4:	81 c1 65 b5 10 f0    	add    $0xf010b565,%ecx
f01031ca:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01031cd:	6b c8 0c             	imul   $0xc,%eax,%ecx
f01031d0:	8b 89 48 52 10 f0    	mov    -0xfefadb8(%ecx),%ecx
f01031d6:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01031d9:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01031db:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01031de:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01031e1:	eb 0f                	jmp    f01031f2 <debuginfo_eip+0x144>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01031e3:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01031e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01031ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01031ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01031f2:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01031f9:	00 
f01031fa:	8b 43 08             	mov    0x8(%ebx),%eax
f01031fd:	89 04 24             	mov    %eax,(%esp)
f0103200:	e8 15 09 00 00       	call   f0103b1a <strfind>
f0103205:	2b 43 08             	sub    0x8(%ebx),%eax
f0103208:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010320b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010320f:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0103216:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103219:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010321c:	b8 40 52 10 f0       	mov    $0xf0105240,%eax
f0103221:	e8 5a fd ff ff       	call   f0102f80 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0103226:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103229:	6b d0 0c             	imul   $0xc,%eax,%edx
f010322c:	0f b7 8a 46 52 10 f0 	movzwl -0xfefadba(%edx),%ecx
f0103233:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103236:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103239:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010323c:	81 c2 48 52 10 f0    	add    $0xf0105248,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103242:	eb 06                	jmp    f010324a <debuginfo_eip+0x19c>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103244:	83 e8 01             	sub    $0x1,%eax
f0103247:	83 ea 0c             	sub    $0xc,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010324a:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f010324d:	7f 1e                	jg     f010326d <debuginfo_eip+0x1bf>
	       && stabs[lline].n_type != N_SOL
f010324f:	0f b6 72 fc          	movzbl -0x4(%edx),%esi
f0103253:	89 f1                	mov    %esi,%ecx
f0103255:	80 f9 84             	cmp    $0x84,%cl
f0103258:	74 68                	je     f01032c2 <debuginfo_eip+0x214>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010325a:	80 f9 64             	cmp    $0x64,%cl
f010325d:	75 e5                	jne    f0103244 <debuginfo_eip+0x196>
f010325f:	83 3a 00             	cmpl   $0x0,(%edx)
f0103262:	74 e0                	je     f0103244 <debuginfo_eip+0x196>
f0103264:	eb 5c                	jmp    f01032c2 <debuginfo_eip+0x214>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103266:	05 65 b5 10 f0       	add    $0xf010b565,%eax
f010326b:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010326d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103270:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103273:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103278:	39 fa                	cmp    %edi,%edx
f010327a:	7d 39                	jge    f01032b5 <debuginfo_eip+0x207>
		for (lline = lfun + 1;
f010327c:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010327f:	6b d0 0c             	imul   $0xc,%eax,%edx
f0103282:	81 c2 44 52 10 f0    	add    $0xf0105244,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103288:	eb 07                	jmp    f0103291 <debuginfo_eip+0x1e3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010328a:	83 43 14 01          	addl   $0x1,0x14(%ebx)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010328e:	83 c0 01             	add    $0x1,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103291:	39 c7                	cmp    %eax,%edi
f0103293:	7e 1b                	jle    f01032b0 <debuginfo_eip+0x202>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103295:	0f b6 32             	movzbl (%edx),%esi
f0103298:	83 c2 0c             	add    $0xc,%edx
f010329b:	89 f1                	mov    %esi,%ecx
f010329d:	80 f9 a0             	cmp    $0xa0,%cl
f01032a0:	74 e8                	je     f010328a <debuginfo_eip+0x1dc>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01032a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01032a7:	eb 0c                	jmp    f01032b5 <debuginfo_eip+0x207>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01032a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01032ae:	eb 05                	jmp    f01032b5 <debuginfo_eip+0x207>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01032b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032b5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01032b8:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01032bb:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01032be:	89 ec                	mov    %ebp,%esp
f01032c0:	5d                   	pop    %ebp
f01032c1:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01032c2:	6b c0 0c             	imul   $0xc,%eax,%eax
f01032c5:	8b 80 40 52 10 f0    	mov    -0xfefadc0(%eax),%eax
f01032cb:	ba e2 d3 10 f0       	mov    $0xf010d3e2,%edx
f01032d0:	81 ea 65 b5 10 f0    	sub    $0xf010b565,%edx
f01032d6:	39 d0                	cmp    %edx,%eax
f01032d8:	72 8c                	jb     f0103266 <debuginfo_eip+0x1b8>
f01032da:	eb 91                	jmp    f010326d <debuginfo_eip+0x1bf>
f01032dc:	00 00                	add    %al,(%eax)
	...

f01032e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01032e0:	55                   	push   %ebp
f01032e1:	89 e5                	mov    %esp,%ebp
f01032e3:	57                   	push   %edi
f01032e4:	56                   	push   %esi
f01032e5:	53                   	push   %ebx
f01032e6:	83 ec 4c             	sub    $0x4c,%esp
f01032e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01032ec:	89 d6                	mov    %edx,%esi
f01032ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01032f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01032f4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01032f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01032fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01032fd:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103300:	b8 00 00 00 00       	mov    $0x0,%eax
f0103305:	39 d0                	cmp    %edx,%eax
f0103307:	72 11                	jb     f010331a <printnum+0x3a>
f0103309:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010330c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
f010330f:	76 09                	jbe    f010331a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103311:	83 eb 01             	sub    $0x1,%ebx
f0103314:	85 db                	test   %ebx,%ebx
f0103316:	7f 5d                	jg     f0103375 <printnum+0x95>
f0103318:	eb 6c                	jmp    f0103386 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010331a:	89 7c 24 10          	mov    %edi,0x10(%esp)
f010331e:	83 eb 01             	sub    $0x1,%ebx
f0103321:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103325:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0103328:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010332c:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103330:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0103334:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103337:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010333a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103341:	00 
f0103342:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103345:	89 14 24             	mov    %edx,(%esp)
f0103348:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010334b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010334f:	e8 4c 0a 00 00       	call   f0103da0 <__udivdi3>
f0103354:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103357:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010335a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010335e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103362:	89 04 24             	mov    %eax,(%esp)
f0103365:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103369:	89 f2                	mov    %esi,%edx
f010336b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010336e:	e8 6d ff ff ff       	call   f01032e0 <printnum>
f0103373:	eb 11                	jmp    f0103386 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103375:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103379:	89 3c 24             	mov    %edi,(%esp)
f010337c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010337f:	83 eb 01             	sub    $0x1,%ebx
f0103382:	85 db                	test   %ebx,%ebx
f0103384:	7f ef                	jg     f0103375 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103386:	89 74 24 04          	mov    %esi,0x4(%esp)
f010338a:	8b 74 24 04          	mov    0x4(%esp),%esi
f010338e:	8b 45 10             	mov    0x10(%ebp),%eax
f0103391:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103395:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010339c:	00 
f010339d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01033a0:	89 14 24             	mov    %edx,(%esp)
f01033a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01033a6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01033aa:	e8 01 0b 00 00       	call   f0103eb0 <__umoddi3>
f01033af:	89 74 24 04          	mov    %esi,0x4(%esp)
f01033b3:	0f be 80 31 50 10 f0 	movsbl -0xfefafcf(%eax),%eax
f01033ba:	89 04 24             	mov    %eax,(%esp)
f01033bd:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01033c0:	83 c4 4c             	add    $0x4c,%esp
f01033c3:	5b                   	pop    %ebx
f01033c4:	5e                   	pop    %esi
f01033c5:	5f                   	pop    %edi
f01033c6:	5d                   	pop    %ebp
f01033c7:	c3                   	ret    

f01033c8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01033c8:	55                   	push   %ebp
f01033c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01033cb:	83 fa 01             	cmp    $0x1,%edx
f01033ce:	7e 0e                	jle    f01033de <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01033d0:	8b 10                	mov    (%eax),%edx
f01033d2:	8d 4a 08             	lea    0x8(%edx),%ecx
f01033d5:	89 08                	mov    %ecx,(%eax)
f01033d7:	8b 02                	mov    (%edx),%eax
f01033d9:	8b 52 04             	mov    0x4(%edx),%edx
f01033dc:	eb 22                	jmp    f0103400 <getuint+0x38>
	else if (lflag)
f01033de:	85 d2                	test   %edx,%edx
f01033e0:	74 10                	je     f01033f2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01033e2:	8b 10                	mov    (%eax),%edx
f01033e4:	8d 4a 04             	lea    0x4(%edx),%ecx
f01033e7:	89 08                	mov    %ecx,(%eax)
f01033e9:	8b 02                	mov    (%edx),%eax
f01033eb:	ba 00 00 00 00       	mov    $0x0,%edx
f01033f0:	eb 0e                	jmp    f0103400 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01033f2:	8b 10                	mov    (%eax),%edx
f01033f4:	8d 4a 04             	lea    0x4(%edx),%ecx
f01033f7:	89 08                	mov    %ecx,(%eax)
f01033f9:	8b 02                	mov    (%edx),%eax
f01033fb:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103400:	5d                   	pop    %ebp
f0103401:	c3                   	ret    

f0103402 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103402:	55                   	push   %ebp
f0103403:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103405:	83 fa 01             	cmp    $0x1,%edx
f0103408:	7e 0e                	jle    f0103418 <getint+0x16>
		return va_arg(*ap, long long);
f010340a:	8b 10                	mov    (%eax),%edx
f010340c:	8d 4a 08             	lea    0x8(%edx),%ecx
f010340f:	89 08                	mov    %ecx,(%eax)
f0103411:	8b 02                	mov    (%edx),%eax
f0103413:	8b 52 04             	mov    0x4(%edx),%edx
f0103416:	eb 22                	jmp    f010343a <getint+0x38>
	else if (lflag)
f0103418:	85 d2                	test   %edx,%edx
f010341a:	74 10                	je     f010342c <getint+0x2a>
		return va_arg(*ap, long);
f010341c:	8b 10                	mov    (%eax),%edx
f010341e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103421:	89 08                	mov    %ecx,(%eax)
f0103423:	8b 02                	mov    (%edx),%eax
f0103425:	89 c2                	mov    %eax,%edx
f0103427:	c1 fa 1f             	sar    $0x1f,%edx
f010342a:	eb 0e                	jmp    f010343a <getint+0x38>
	else
		return va_arg(*ap, int);
f010342c:	8b 10                	mov    (%eax),%edx
f010342e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103431:	89 08                	mov    %ecx,(%eax)
f0103433:	8b 02                	mov    (%edx),%eax
f0103435:	89 c2                	mov    %eax,%edx
f0103437:	c1 fa 1f             	sar    $0x1f,%edx
}
f010343a:	5d                   	pop    %ebp
f010343b:	c3                   	ret    

f010343c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010343c:	55                   	push   %ebp
f010343d:	89 e5                	mov    %esp,%ebp
f010343f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103442:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103446:	8b 10                	mov    (%eax),%edx
f0103448:	3b 50 04             	cmp    0x4(%eax),%edx
f010344b:	73 0a                	jae    f0103457 <sprintputch+0x1b>
		*b->buf++ = ch;
f010344d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103450:	88 0a                	mov    %cl,(%edx)
f0103452:	83 c2 01             	add    $0x1,%edx
f0103455:	89 10                	mov    %edx,(%eax)
}
f0103457:	5d                   	pop    %ebp
f0103458:	c3                   	ret    

f0103459 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103459:	55                   	push   %ebp
f010345a:	89 e5                	mov    %esp,%ebp
f010345c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010345f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103462:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103466:	8b 45 10             	mov    0x10(%ebp),%eax
f0103469:	89 44 24 08          	mov    %eax,0x8(%esp)
f010346d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103470:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103474:	8b 45 08             	mov    0x8(%ebp),%eax
f0103477:	89 04 24             	mov    %eax,(%esp)
f010347a:	e8 02 00 00 00       	call   f0103481 <vprintfmt>
	va_end(ap);
}
f010347f:	c9                   	leave  
f0103480:	c3                   	ret    

f0103481 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103481:	55                   	push   %ebp
f0103482:	89 e5                	mov    %esp,%ebp
f0103484:	57                   	push   %edi
f0103485:	56                   	push   %esi
f0103486:	53                   	push   %ebx
f0103487:	83 ec 4c             	sub    $0x4c,%esp
f010348a:	8b 7d 10             	mov    0x10(%ebp),%edi
f010348d:	eb 23                	jmp    f01034b2 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
f010348f:	85 c0                	test   %eax,%eax
f0103491:	75 12                	jne    f01034a5 <vprintfmt+0x24>
				csa = 0x0700;
f0103493:	c7 05 44 89 11 f0 00 	movl   $0x700,0xf0118944
f010349a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f010349d:	83 c4 4c             	add    $0x4c,%esp
f01034a0:	5b                   	pop    %ebx
f01034a1:	5e                   	pop    %esi
f01034a2:	5f                   	pop    %edi
f01034a3:	5d                   	pop    %ebp
f01034a4:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
f01034a5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01034a8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01034ac:	89 04 24             	mov    %eax,(%esp)
f01034af:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01034b2:	0f b6 07             	movzbl (%edi),%eax
f01034b5:	83 c7 01             	add    $0x1,%edi
f01034b8:	83 f8 25             	cmp    $0x25,%eax
f01034bb:	75 d2                	jne    f010348f <vprintfmt+0xe>
f01034bd:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f01034c1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01034c8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01034cd:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01034d4:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01034d9:	be 00 00 00 00       	mov    $0x0,%esi
f01034de:	eb 14                	jmp    f01034f4 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
f01034e0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f01034e4:	eb 0e                	jmp    f01034f4 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01034e6:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f01034ea:	eb 08                	jmp    f01034f4 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01034ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01034ef:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01034f4:	0f b6 07             	movzbl (%edi),%eax
f01034f7:	0f b6 c8             	movzbl %al,%ecx
f01034fa:	83 c7 01             	add    $0x1,%edi
f01034fd:	83 e8 23             	sub    $0x23,%eax
f0103500:	3c 55                	cmp    $0x55,%al
f0103502:	0f 87 ed 02 00 00    	ja     f01037f5 <vprintfmt+0x374>
f0103508:	0f b6 c0             	movzbl %al,%eax
f010350b:	ff 24 85 bc 50 10 f0 	jmp    *-0xfefaf44(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103512:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
f0103515:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0103518:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010351b:	83 f9 09             	cmp    $0x9,%ecx
f010351e:	77 3c                	ja     f010355c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103520:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0103523:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
f0103526:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
f010352a:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f010352d:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0103530:	83 f9 09             	cmp    $0x9,%ecx
f0103533:	76 eb                	jbe    f0103520 <vprintfmt+0x9f>
f0103535:	eb 25                	jmp    f010355c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103537:	8b 45 14             	mov    0x14(%ebp),%eax
f010353a:	8d 48 04             	lea    0x4(%eax),%ecx
f010353d:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103540:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
f0103542:	eb 18                	jmp    f010355c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
f0103544:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103548:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010354b:	0f 48 c6             	cmovs  %esi,%eax
f010354e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103551:	eb a1                	jmp    f01034f4 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
f0103553:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f010355a:	eb 98                	jmp    f01034f4 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
f010355c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103560:	79 92                	jns    f01034f4 <vprintfmt+0x73>
f0103562:	eb 88                	jmp    f01034ec <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103564:	83 c2 01             	add    $0x1,%edx
f0103567:	eb 8b                	jmp    f01034f4 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103569:	8b 45 14             	mov    0x14(%ebp),%eax
f010356c:	8d 50 04             	lea    0x4(%eax),%edx
f010356f:	89 55 14             	mov    %edx,0x14(%ebp)
f0103572:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103575:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103579:	8b 00                	mov    (%eax),%eax
f010357b:	89 04 24             	mov    %eax,(%esp)
f010357e:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103581:	e9 2c ff ff ff       	jmp    f01034b2 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103586:	8b 45 14             	mov    0x14(%ebp),%eax
f0103589:	8d 50 04             	lea    0x4(%eax),%edx
f010358c:	89 55 14             	mov    %edx,0x14(%ebp)
f010358f:	8b 00                	mov    (%eax),%eax
f0103591:	89 c2                	mov    %eax,%edx
f0103593:	c1 fa 1f             	sar    $0x1f,%edx
f0103596:	31 d0                	xor    %edx,%eax
f0103598:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010359a:	83 f8 06             	cmp    $0x6,%eax
f010359d:	7f 0b                	jg     f01035aa <vprintfmt+0x129>
f010359f:	8b 14 85 14 52 10 f0 	mov    -0xfefadec(,%eax,4),%edx
f01035a6:	85 d2                	test   %edx,%edx
f01035a8:	75 23                	jne    f01035cd <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
f01035aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035ae:	c7 44 24 08 49 50 10 	movl   $0xf0105049,0x8(%esp)
f01035b5:	f0 
f01035b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01035b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01035bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01035c0:	89 04 24             	mov    %eax,(%esp)
f01035c3:	e8 91 fe ff ff       	call   f0103459 <printfmt>
f01035c8:	e9 e5 fe ff ff       	jmp    f01034b2 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
f01035cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01035d1:	c7 44 24 08 f8 4c 10 	movl   $0xf0104cf8,0x8(%esp)
f01035d8:	f0 
f01035d9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01035dc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01035e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01035e3:	89 1c 24             	mov    %ebx,(%esp)
f01035e6:	e8 6e fe ff ff       	call   f0103459 <printfmt>
f01035eb:	e9 c2 fe ff ff       	jmp    f01034b2 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01035f0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01035f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01035f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01035fc:	8d 50 04             	lea    0x4(%eax),%edx
f01035ff:	89 55 14             	mov    %edx,0x14(%ebp)
f0103602:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0103604:	85 f6                	test   %esi,%esi
f0103606:	ba 42 50 10 f0       	mov    $0xf0105042,%edx
f010360b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f010360e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103612:	7e 06                	jle    f010361a <vprintfmt+0x199>
f0103614:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0103618:	75 13                	jne    f010362d <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010361a:	0f be 06             	movsbl (%esi),%eax
f010361d:	83 c6 01             	add    $0x1,%esi
f0103620:	85 c0                	test   %eax,%eax
f0103622:	0f 85 a2 00 00 00    	jne    f01036ca <vprintfmt+0x249>
f0103628:	e9 92 00 00 00       	jmp    f01036bf <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010362d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103631:	89 34 24             	mov    %esi,(%esp)
f0103634:	e8 52 03 00 00       	call   f010398b <strnlen>
f0103639:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010363c:	29 c2                	sub    %eax,%edx
f010363e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103641:	85 d2                	test   %edx,%edx
f0103643:	7e d5                	jle    f010361a <vprintfmt+0x199>
					putch(padc, putdat);
f0103645:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
f0103649:	89 75 d8             	mov    %esi,-0x28(%ebp)
f010364c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010364f:	89 d3                	mov    %edx,%ebx
f0103651:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0103654:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103657:	89 c6                	mov    %eax,%esi
f0103659:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010365d:	89 34 24             	mov    %esi,(%esp)
f0103660:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103663:	83 eb 01             	sub    $0x1,%ebx
f0103666:	85 db                	test   %ebx,%ebx
f0103668:	7f ef                	jg     f0103659 <vprintfmt+0x1d8>
f010366a:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010366d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103670:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103673:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010367a:	eb 9e                	jmp    f010361a <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010367c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103680:	74 1b                	je     f010369d <vprintfmt+0x21c>
f0103682:	8d 50 e0             	lea    -0x20(%eax),%edx
f0103685:	83 fa 5e             	cmp    $0x5e,%edx
f0103688:	76 13                	jbe    f010369d <vprintfmt+0x21c>
					putch('?', putdat);
f010368a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010368d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103691:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0103698:	ff 55 08             	call   *0x8(%ebp)
f010369b:	eb 0d                	jmp    f01036aa <vprintfmt+0x229>
				else
					putch(ch, putdat);
f010369d:	8b 55 0c             	mov    0xc(%ebp),%edx
f01036a0:	89 54 24 04          	mov    %edx,0x4(%esp)
f01036a4:	89 04 24             	mov    %eax,(%esp)
f01036a7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01036aa:	83 ef 01             	sub    $0x1,%edi
f01036ad:	0f be 06             	movsbl (%esi),%eax
f01036b0:	85 c0                	test   %eax,%eax
f01036b2:	74 05                	je     f01036b9 <vprintfmt+0x238>
f01036b4:	83 c6 01             	add    $0x1,%esi
f01036b7:	eb 17                	jmp    f01036d0 <vprintfmt+0x24f>
f01036b9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01036bc:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01036bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01036c3:	7f 1c                	jg     f01036e1 <vprintfmt+0x260>
f01036c5:	e9 e8 fd ff ff       	jmp    f01034b2 <vprintfmt+0x31>
f01036ca:	89 7d dc             	mov    %edi,-0x24(%ebp)
f01036cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01036d0:	85 db                	test   %ebx,%ebx
f01036d2:	78 a8                	js     f010367c <vprintfmt+0x1fb>
f01036d4:	83 eb 01             	sub    $0x1,%ebx
f01036d7:	79 a3                	jns    f010367c <vprintfmt+0x1fb>
f01036d9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01036dc:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01036df:	eb de                	jmp    f01036bf <vprintfmt+0x23e>
f01036e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01036e4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01036e7:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01036ea:	89 74 24 04          	mov    %esi,0x4(%esp)
f01036ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01036f5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01036f7:	83 eb 01             	sub    $0x1,%ebx
f01036fa:	85 db                	test   %ebx,%ebx
f01036fc:	7f ec                	jg     f01036ea <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01036fe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103701:	e9 ac fd ff ff       	jmp    f01034b2 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103706:	8d 45 14             	lea    0x14(%ebp),%eax
f0103709:	e8 f4 fc ff ff       	call   f0103402 <getint>
f010370e:	89 c3                	mov    %eax,%ebx
f0103710:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0103712:	85 d2                	test   %edx,%edx
f0103714:	78 0a                	js     f0103720 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103716:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010371b:	e9 87 00 00 00       	jmp    f01037a7 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0103720:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103723:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103727:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010372e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103731:	89 d8                	mov    %ebx,%eax
f0103733:	89 f2                	mov    %esi,%edx
f0103735:	f7 d8                	neg    %eax
f0103737:	83 d2 00             	adc    $0x0,%edx
f010373a:	f7 da                	neg    %edx
			}
			base = 10;
f010373c:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103741:	eb 64                	jmp    f01037a7 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103743:	8d 45 14             	lea    0x14(%ebp),%eax
f0103746:	e8 7d fc ff ff       	call   f01033c8 <getuint>
			base = 10;
f010374b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0103750:	eb 55                	jmp    f01037a7 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
f0103752:	8d 45 14             	lea    0x14(%ebp),%eax
f0103755:	e8 6e fc ff ff       	call   f01033c8 <getuint>
      base = 8;
f010375a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
f010375f:	eb 46                	jmp    f01037a7 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
f0103761:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103764:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103768:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010376f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103772:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103775:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103779:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103780:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103783:	8b 45 14             	mov    0x14(%ebp),%eax
f0103786:	8d 50 04             	lea    0x4(%eax),%edx
f0103789:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010378c:	8b 00                	mov    (%eax),%eax
f010378e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103793:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0103798:	eb 0d                	jmp    f01037a7 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010379a:	8d 45 14             	lea    0x14(%ebp),%eax
f010379d:	e8 26 fc ff ff       	call   f01033c8 <getuint>
			base = 16;
f01037a2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01037a7:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f01037ab:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01037af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01037b2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01037b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01037ba:	89 04 24             	mov    %eax,(%esp)
f01037bd:	89 54 24 04          	mov    %edx,0x4(%esp)
f01037c1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01037c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01037c7:	e8 14 fb ff ff       	call   f01032e0 <printnum>
			break;
f01037cc:	e9 e1 fc ff ff       	jmp    f01034b2 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01037d1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037d8:	89 0c 24             	mov    %ecx,(%esp)
f01037db:	ff 55 08             	call   *0x8(%ebp)
			break;
f01037de:	e9 cf fc ff ff       	jmp    f01034b2 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
f01037e3:	8d 45 14             	lea    0x14(%ebp),%eax
f01037e6:	e8 17 fc ff ff       	call   f0103402 <getint>
			csa = num;
f01037eb:	a3 44 89 11 f0       	mov    %eax,0xf0118944
			break;
f01037f0:	e9 bd fc ff ff       	jmp    f01034b2 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01037f5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01037f8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01037fc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103803:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103806:	83 ef 01             	sub    $0x1,%edi
f0103809:	eb 02                	jmp    f010380d <vprintfmt+0x38c>
f010380b:	89 c7                	mov    %eax,%edi
f010380d:	8d 47 ff             	lea    -0x1(%edi),%eax
f0103810:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103814:	75 f5                	jne    f010380b <vprintfmt+0x38a>
f0103816:	e9 97 fc ff ff       	jmp    f01034b2 <vprintfmt+0x31>

f010381b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010381b:	55                   	push   %ebp
f010381c:	89 e5                	mov    %esp,%ebp
f010381e:	83 ec 28             	sub    $0x28,%esp
f0103821:	8b 45 08             	mov    0x8(%ebp),%eax
f0103824:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103827:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010382a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010382e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103831:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103838:	85 c0                	test   %eax,%eax
f010383a:	74 30                	je     f010386c <vsnprintf+0x51>
f010383c:	85 d2                	test   %edx,%edx
f010383e:	7e 2c                	jle    f010386c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103840:	8b 45 14             	mov    0x14(%ebp),%eax
f0103843:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103847:	8b 45 10             	mov    0x10(%ebp),%eax
f010384a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010384e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103851:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103855:	c7 04 24 3c 34 10 f0 	movl   $0xf010343c,(%esp)
f010385c:	e8 20 fc ff ff       	call   f0103481 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103861:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103864:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103867:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010386a:	eb 05                	jmp    f0103871 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010386c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103871:	c9                   	leave  
f0103872:	c3                   	ret    

f0103873 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103873:	55                   	push   %ebp
f0103874:	89 e5                	mov    %esp,%ebp
f0103876:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103879:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010387c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103880:	8b 45 10             	mov    0x10(%ebp),%eax
f0103883:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103887:	8b 45 0c             	mov    0xc(%ebp),%eax
f010388a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010388e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103891:	89 04 24             	mov    %eax,(%esp)
f0103894:	e8 82 ff ff ff       	call   f010381b <vsnprintf>
	va_end(ap);

	return rc;
}
f0103899:	c9                   	leave  
f010389a:	c3                   	ret    
f010389b:	00 00                	add    %al,(%eax)
f010389d:	00 00                	add    %al,(%eax)
	...

f01038a0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01038a0:	55                   	push   %ebp
f01038a1:	89 e5                	mov    %esp,%ebp
f01038a3:	57                   	push   %edi
f01038a4:	56                   	push   %esi
f01038a5:	53                   	push   %ebx
f01038a6:	83 ec 1c             	sub    $0x1c,%esp
f01038a9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01038ac:	85 c0                	test   %eax,%eax
f01038ae:	74 10                	je     f01038c0 <readline+0x20>
		cprintf("%s", prompt);
f01038b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038b4:	c7 04 24 f8 4c 10 f0 	movl   $0xf0104cf8,(%esp)
f01038bb:	e8 a6 f6 ff ff       	call   f0102f66 <cprintf>

	i = 0;
	echoing = iscons(0);
f01038c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01038c7:	e8 c6 cd ff ff       	call   f0100692 <iscons>
f01038cc:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01038ce:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01038d3:	e8 a9 cd ff ff       	call   f0100681 <getchar>
f01038d8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01038da:	85 c0                	test   %eax,%eax
f01038dc:	79 17                	jns    f01038f5 <readline+0x55>
			cprintf("read error: %e\n", c);
f01038de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038e2:	c7 04 24 30 52 10 f0 	movl   $0xf0105230,(%esp)
f01038e9:	e8 78 f6 ff ff       	call   f0102f66 <cprintf>
			return NULL;
f01038ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01038f3:	eb 6d                	jmp    f0103962 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01038f5:	83 f8 08             	cmp    $0x8,%eax
f01038f8:	74 05                	je     f01038ff <readline+0x5f>
f01038fa:	83 f8 7f             	cmp    $0x7f,%eax
f01038fd:	75 19                	jne    f0103918 <readline+0x78>
f01038ff:	85 f6                	test   %esi,%esi
f0103901:	7e 15                	jle    f0103918 <readline+0x78>
			if (echoing)
f0103903:	85 ff                	test   %edi,%edi
f0103905:	74 0c                	je     f0103913 <readline+0x73>
				cputchar('\b');
f0103907:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010390e:	e8 5e cd ff ff       	call   f0100671 <cputchar>
			i--;
f0103913:	83 ee 01             	sub    $0x1,%esi
f0103916:	eb bb                	jmp    f01038d3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103918:	83 fb 1f             	cmp    $0x1f,%ebx
f010391b:	7e 1f                	jle    f010393c <readline+0x9c>
f010391d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103923:	7f 17                	jg     f010393c <readline+0x9c>
			if (echoing)
f0103925:	85 ff                	test   %edi,%edi
f0103927:	74 08                	je     f0103931 <readline+0x91>
				cputchar(c);
f0103929:	89 1c 24             	mov    %ebx,(%esp)
f010392c:	e8 40 cd ff ff       	call   f0100671 <cputchar>
			buf[i++] = c;
f0103931:	88 9e 40 85 11 f0    	mov    %bl,-0xfee7ac0(%esi)
f0103937:	83 c6 01             	add    $0x1,%esi
f010393a:	eb 97                	jmp    f01038d3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010393c:	83 fb 0a             	cmp    $0xa,%ebx
f010393f:	74 05                	je     f0103946 <readline+0xa6>
f0103941:	83 fb 0d             	cmp    $0xd,%ebx
f0103944:	75 8d                	jne    f01038d3 <readline+0x33>
			if (echoing)
f0103946:	85 ff                	test   %edi,%edi
f0103948:	74 0c                	je     f0103956 <readline+0xb6>
				cputchar('\n');
f010394a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0103951:	e8 1b cd ff ff       	call   f0100671 <cputchar>
			buf[i] = 0;
f0103956:	c6 86 40 85 11 f0 00 	movb   $0x0,-0xfee7ac0(%esi)
			return buf;
f010395d:	b8 40 85 11 f0       	mov    $0xf0118540,%eax
		}
	}
}
f0103962:	83 c4 1c             	add    $0x1c,%esp
f0103965:	5b                   	pop    %ebx
f0103966:	5e                   	pop    %esi
f0103967:	5f                   	pop    %edi
f0103968:	5d                   	pop    %ebp
f0103969:	c3                   	ret    
f010396a:	00 00                	add    %al,(%eax)
f010396c:	00 00                	add    %al,(%eax)
	...

f0103970 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103970:	55                   	push   %ebp
f0103971:	89 e5                	mov    %esp,%ebp
f0103973:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103976:	b8 00 00 00 00       	mov    $0x0,%eax
f010397b:	80 3a 00             	cmpb   $0x0,(%edx)
f010397e:	74 09                	je     f0103989 <strlen+0x19>
		n++;
f0103980:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103983:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103987:	75 f7                	jne    f0103980 <strlen+0x10>
		n++;
	return n;
}
f0103989:	5d                   	pop    %ebp
f010398a:	c3                   	ret    

f010398b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010398b:	55                   	push   %ebp
f010398c:	89 e5                	mov    %esp,%ebp
f010398e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103991:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103994:	b8 00 00 00 00       	mov    $0x0,%eax
f0103999:	85 d2                	test   %edx,%edx
f010399b:	74 12                	je     f01039af <strnlen+0x24>
f010399d:	80 39 00             	cmpb   $0x0,(%ecx)
f01039a0:	74 0d                	je     f01039af <strnlen+0x24>
		n++;
f01039a2:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01039a5:	39 d0                	cmp    %edx,%eax
f01039a7:	74 06                	je     f01039af <strnlen+0x24>
f01039a9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01039ad:	75 f3                	jne    f01039a2 <strnlen+0x17>
		n++;
	return n;
}
f01039af:	5d                   	pop    %ebp
f01039b0:	c3                   	ret    

f01039b1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01039b1:	55                   	push   %ebp
f01039b2:	89 e5                	mov    %esp,%ebp
f01039b4:	53                   	push   %ebx
f01039b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01039b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01039bb:	ba 00 00 00 00       	mov    $0x0,%edx
f01039c0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01039c4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01039c7:	83 c2 01             	add    $0x1,%edx
f01039ca:	84 c9                	test   %cl,%cl
f01039cc:	75 f2                	jne    f01039c0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01039ce:	5b                   	pop    %ebx
f01039cf:	5d                   	pop    %ebp
f01039d0:	c3                   	ret    

f01039d1 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01039d1:	55                   	push   %ebp
f01039d2:	89 e5                	mov    %esp,%ebp
f01039d4:	53                   	push   %ebx
f01039d5:	83 ec 08             	sub    $0x8,%esp
f01039d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01039db:	89 1c 24             	mov    %ebx,(%esp)
f01039de:	e8 8d ff ff ff       	call   f0103970 <strlen>
	strcpy(dst + len, src);
f01039e3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01039e6:	89 54 24 04          	mov    %edx,0x4(%esp)
f01039ea:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f01039ed:	89 04 24             	mov    %eax,(%esp)
f01039f0:	e8 bc ff ff ff       	call   f01039b1 <strcpy>
	return dst;
}
f01039f5:	89 d8                	mov    %ebx,%eax
f01039f7:	83 c4 08             	add    $0x8,%esp
f01039fa:	5b                   	pop    %ebx
f01039fb:	5d                   	pop    %ebp
f01039fc:	c3                   	ret    

f01039fd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01039fd:	55                   	push   %ebp
f01039fe:	89 e5                	mov    %esp,%ebp
f0103a00:	56                   	push   %esi
f0103a01:	53                   	push   %ebx
f0103a02:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a05:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a08:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103a0b:	85 f6                	test   %esi,%esi
f0103a0d:	74 18                	je     f0103a27 <strncpy+0x2a>
f0103a0f:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103a14:	0f b6 1a             	movzbl (%edx),%ebx
f0103a17:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103a1a:	80 3a 01             	cmpb   $0x1,(%edx)
f0103a1d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103a20:	83 c1 01             	add    $0x1,%ecx
f0103a23:	39 ce                	cmp    %ecx,%esi
f0103a25:	77 ed                	ja     f0103a14 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103a27:	5b                   	pop    %ebx
f0103a28:	5e                   	pop    %esi
f0103a29:	5d                   	pop    %ebp
f0103a2a:	c3                   	ret    

f0103a2b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103a2b:	55                   	push   %ebp
f0103a2c:	89 e5                	mov    %esp,%ebp
f0103a2e:	56                   	push   %esi
f0103a2f:	53                   	push   %ebx
f0103a30:	8b 75 08             	mov    0x8(%ebp),%esi
f0103a33:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103a39:	89 f0                	mov    %esi,%eax
f0103a3b:	85 c9                	test   %ecx,%ecx
f0103a3d:	74 23                	je     f0103a62 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
f0103a3f:	83 e9 01             	sub    $0x1,%ecx
f0103a42:	74 1b                	je     f0103a5f <strlcpy+0x34>
f0103a44:	0f b6 1a             	movzbl (%edx),%ebx
f0103a47:	84 db                	test   %bl,%bl
f0103a49:	74 14                	je     f0103a5f <strlcpy+0x34>
			*dst++ = *src++;
f0103a4b:	88 18                	mov    %bl,(%eax)
f0103a4d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103a50:	83 e9 01             	sub    $0x1,%ecx
f0103a53:	74 0a                	je     f0103a5f <strlcpy+0x34>
			*dst++ = *src++;
f0103a55:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103a58:	0f b6 1a             	movzbl (%edx),%ebx
f0103a5b:	84 db                	test   %bl,%bl
f0103a5d:	75 ec                	jne    f0103a4b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
f0103a5f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103a62:	29 f0                	sub    %esi,%eax
}
f0103a64:	5b                   	pop    %ebx
f0103a65:	5e                   	pop    %esi
f0103a66:	5d                   	pop    %ebp
f0103a67:	c3                   	ret    

f0103a68 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103a68:	55                   	push   %ebp
f0103a69:	89 e5                	mov    %esp,%ebp
f0103a6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103a71:	0f b6 01             	movzbl (%ecx),%eax
f0103a74:	84 c0                	test   %al,%al
f0103a76:	74 15                	je     f0103a8d <strcmp+0x25>
f0103a78:	3a 02                	cmp    (%edx),%al
f0103a7a:	75 11                	jne    f0103a8d <strcmp+0x25>
		p++, q++;
f0103a7c:	83 c1 01             	add    $0x1,%ecx
f0103a7f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103a82:	0f b6 01             	movzbl (%ecx),%eax
f0103a85:	84 c0                	test   %al,%al
f0103a87:	74 04                	je     f0103a8d <strcmp+0x25>
f0103a89:	3a 02                	cmp    (%edx),%al
f0103a8b:	74 ef                	je     f0103a7c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103a8d:	0f b6 c0             	movzbl %al,%eax
f0103a90:	0f b6 12             	movzbl (%edx),%edx
f0103a93:	29 d0                	sub    %edx,%eax
}
f0103a95:	5d                   	pop    %ebp
f0103a96:	c3                   	ret    

f0103a97 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103a97:	55                   	push   %ebp
f0103a98:	89 e5                	mov    %esp,%ebp
f0103a9a:	53                   	push   %ebx
f0103a9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103a9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103aa1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103aa9:	85 d2                	test   %edx,%edx
f0103aab:	74 28                	je     f0103ad5 <strncmp+0x3e>
f0103aad:	0f b6 01             	movzbl (%ecx),%eax
f0103ab0:	84 c0                	test   %al,%al
f0103ab2:	74 24                	je     f0103ad8 <strncmp+0x41>
f0103ab4:	3a 03                	cmp    (%ebx),%al
f0103ab6:	75 20                	jne    f0103ad8 <strncmp+0x41>
f0103ab8:	83 ea 01             	sub    $0x1,%edx
f0103abb:	74 13                	je     f0103ad0 <strncmp+0x39>
		n--, p++, q++;
f0103abd:	83 c1 01             	add    $0x1,%ecx
f0103ac0:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103ac3:	0f b6 01             	movzbl (%ecx),%eax
f0103ac6:	84 c0                	test   %al,%al
f0103ac8:	74 0e                	je     f0103ad8 <strncmp+0x41>
f0103aca:	3a 03                	cmp    (%ebx),%al
f0103acc:	74 ea                	je     f0103ab8 <strncmp+0x21>
f0103ace:	eb 08                	jmp    f0103ad8 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103ad0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103ad5:	5b                   	pop    %ebx
f0103ad6:	5d                   	pop    %ebp
f0103ad7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103ad8:	0f b6 01             	movzbl (%ecx),%eax
f0103adb:	0f b6 13             	movzbl (%ebx),%edx
f0103ade:	29 d0                	sub    %edx,%eax
f0103ae0:	eb f3                	jmp    f0103ad5 <strncmp+0x3e>

f0103ae2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103ae2:	55                   	push   %ebp
f0103ae3:	89 e5                	mov    %esp,%ebp
f0103ae5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ae8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103aec:	0f b6 10             	movzbl (%eax),%edx
f0103aef:	84 d2                	test   %dl,%dl
f0103af1:	74 20                	je     f0103b13 <strchr+0x31>
		if (*s == c)
f0103af3:	38 ca                	cmp    %cl,%dl
f0103af5:	75 0b                	jne    f0103b02 <strchr+0x20>
f0103af7:	eb 1f                	jmp    f0103b18 <strchr+0x36>
f0103af9:	38 ca                	cmp    %cl,%dl
f0103afb:	90                   	nop
f0103afc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103b00:	74 16                	je     f0103b18 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103b02:	83 c0 01             	add    $0x1,%eax
f0103b05:	0f b6 10             	movzbl (%eax),%edx
f0103b08:	84 d2                	test   %dl,%dl
f0103b0a:	75 ed                	jne    f0103af9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0103b0c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b11:	eb 05                	jmp    f0103b18 <strchr+0x36>
f0103b13:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103b18:	5d                   	pop    %ebp
f0103b19:	c3                   	ret    

f0103b1a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103b1a:	55                   	push   %ebp
f0103b1b:	89 e5                	mov    %esp,%ebp
f0103b1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103b24:	0f b6 10             	movzbl (%eax),%edx
f0103b27:	84 d2                	test   %dl,%dl
f0103b29:	74 14                	je     f0103b3f <strfind+0x25>
		if (*s == c)
f0103b2b:	38 ca                	cmp    %cl,%dl
f0103b2d:	75 06                	jne    f0103b35 <strfind+0x1b>
f0103b2f:	eb 0e                	jmp    f0103b3f <strfind+0x25>
f0103b31:	38 ca                	cmp    %cl,%dl
f0103b33:	74 0a                	je     f0103b3f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103b35:	83 c0 01             	add    $0x1,%eax
f0103b38:	0f b6 10             	movzbl (%eax),%edx
f0103b3b:	84 d2                	test   %dl,%dl
f0103b3d:	75 f2                	jne    f0103b31 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0103b3f:	5d                   	pop    %ebp
f0103b40:	c3                   	ret    

f0103b41 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103b41:	55                   	push   %ebp
f0103b42:	89 e5                	mov    %esp,%ebp
f0103b44:	83 ec 0c             	sub    $0xc,%esp
f0103b47:	89 1c 24             	mov    %ebx,(%esp)
f0103b4a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103b4e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103b52:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103b55:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b58:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103b5b:	85 c9                	test   %ecx,%ecx
f0103b5d:	74 30                	je     f0103b8f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103b5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103b65:	75 25                	jne    f0103b8c <memset+0x4b>
f0103b67:	f6 c1 03             	test   $0x3,%cl
f0103b6a:	75 20                	jne    f0103b8c <memset+0x4b>
		c &= 0xFF;
f0103b6c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103b6f:	89 d3                	mov    %edx,%ebx
f0103b71:	c1 e3 08             	shl    $0x8,%ebx
f0103b74:	89 d6                	mov    %edx,%esi
f0103b76:	c1 e6 18             	shl    $0x18,%esi
f0103b79:	89 d0                	mov    %edx,%eax
f0103b7b:	c1 e0 10             	shl    $0x10,%eax
f0103b7e:	09 f0                	or     %esi,%eax
f0103b80:	09 d0                	or     %edx,%eax
f0103b82:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103b84:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103b87:	fc                   	cld    
f0103b88:	f3 ab                	rep stos %eax,%es:(%edi)
f0103b8a:	eb 03                	jmp    f0103b8f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103b8c:	fc                   	cld    
f0103b8d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103b8f:	89 f8                	mov    %edi,%eax
f0103b91:	8b 1c 24             	mov    (%esp),%ebx
f0103b94:	8b 74 24 04          	mov    0x4(%esp),%esi
f0103b98:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0103b9c:	89 ec                	mov    %ebp,%esp
f0103b9e:	5d                   	pop    %ebp
f0103b9f:	c3                   	ret    

f0103ba0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103ba0:	55                   	push   %ebp
f0103ba1:	89 e5                	mov    %esp,%ebp
f0103ba3:	83 ec 08             	sub    $0x8,%esp
f0103ba6:	89 34 24             	mov    %esi,(%esp)
f0103ba9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103bad:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bb0:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103bb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103bb6:	39 c6                	cmp    %eax,%esi
f0103bb8:	73 36                	jae    f0103bf0 <memmove+0x50>
f0103bba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103bbd:	39 d0                	cmp    %edx,%eax
f0103bbf:	73 2f                	jae    f0103bf0 <memmove+0x50>
		s += n;
		d += n;
f0103bc1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103bc4:	f6 c2 03             	test   $0x3,%dl
f0103bc7:	75 1b                	jne    f0103be4 <memmove+0x44>
f0103bc9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103bcf:	75 13                	jne    f0103be4 <memmove+0x44>
f0103bd1:	f6 c1 03             	test   $0x3,%cl
f0103bd4:	75 0e                	jne    f0103be4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103bd6:	83 ef 04             	sub    $0x4,%edi
f0103bd9:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103bdc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0103bdf:	fd                   	std    
f0103be0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103be2:	eb 09                	jmp    f0103bed <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103be4:	83 ef 01             	sub    $0x1,%edi
f0103be7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103bea:	fd                   	std    
f0103beb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103bed:	fc                   	cld    
f0103bee:	eb 20                	jmp    f0103c10 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103bf0:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103bf6:	75 13                	jne    f0103c0b <memmove+0x6b>
f0103bf8:	a8 03                	test   $0x3,%al
f0103bfa:	75 0f                	jne    f0103c0b <memmove+0x6b>
f0103bfc:	f6 c1 03             	test   $0x3,%cl
f0103bff:	75 0a                	jne    f0103c0b <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103c01:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0103c04:	89 c7                	mov    %eax,%edi
f0103c06:	fc                   	cld    
f0103c07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103c09:	eb 05                	jmp    f0103c10 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103c0b:	89 c7                	mov    %eax,%edi
f0103c0d:	fc                   	cld    
f0103c0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103c10:	8b 34 24             	mov    (%esp),%esi
f0103c13:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103c17:	89 ec                	mov    %ebp,%esp
f0103c19:	5d                   	pop    %ebp
f0103c1a:	c3                   	ret    

f0103c1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103c1b:	55                   	push   %ebp
f0103c1c:	89 e5                	mov    %esp,%ebp
f0103c1e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103c21:	8b 45 10             	mov    0x10(%ebp),%eax
f0103c24:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c28:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c2f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c32:	89 04 24             	mov    %eax,(%esp)
f0103c35:	e8 66 ff ff ff       	call   f0103ba0 <memmove>
}
f0103c3a:	c9                   	leave  
f0103c3b:	c3                   	ret    

f0103c3c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103c3c:	55                   	push   %ebp
f0103c3d:	89 e5                	mov    %esp,%ebp
f0103c3f:	57                   	push   %edi
f0103c40:	56                   	push   %esi
f0103c41:	53                   	push   %ebx
f0103c42:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103c45:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103c48:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103c4b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103c50:	85 ff                	test   %edi,%edi
f0103c52:	74 38                	je     f0103c8c <memcmp+0x50>
		if (*s1 != *s2)
f0103c54:	0f b6 03             	movzbl (%ebx),%eax
f0103c57:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103c5a:	83 ef 01             	sub    $0x1,%edi
f0103c5d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0103c62:	38 c8                	cmp    %cl,%al
f0103c64:	74 1d                	je     f0103c83 <memcmp+0x47>
f0103c66:	eb 11                	jmp    f0103c79 <memcmp+0x3d>
f0103c68:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0103c6d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
f0103c72:	83 c2 01             	add    $0x1,%edx
f0103c75:	38 c8                	cmp    %cl,%al
f0103c77:	74 0a                	je     f0103c83 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
f0103c79:	0f b6 c0             	movzbl %al,%eax
f0103c7c:	0f b6 c9             	movzbl %cl,%ecx
f0103c7f:	29 c8                	sub    %ecx,%eax
f0103c81:	eb 09                	jmp    f0103c8c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103c83:	39 fa                	cmp    %edi,%edx
f0103c85:	75 e1                	jne    f0103c68 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103c87:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103c8c:	5b                   	pop    %ebx
f0103c8d:	5e                   	pop    %esi
f0103c8e:	5f                   	pop    %edi
f0103c8f:	5d                   	pop    %ebp
f0103c90:	c3                   	ret    

f0103c91 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103c91:	55                   	push   %ebp
f0103c92:	89 e5                	mov    %esp,%ebp
f0103c94:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103c97:	89 c2                	mov    %eax,%edx
f0103c99:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103c9c:	39 d0                	cmp    %edx,%eax
f0103c9e:	73 15                	jae    f0103cb5 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103ca0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0103ca4:	38 08                	cmp    %cl,(%eax)
f0103ca6:	75 06                	jne    f0103cae <memfind+0x1d>
f0103ca8:	eb 0b                	jmp    f0103cb5 <memfind+0x24>
f0103caa:	38 08                	cmp    %cl,(%eax)
f0103cac:	74 07                	je     f0103cb5 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103cae:	83 c0 01             	add    $0x1,%eax
f0103cb1:	39 c2                	cmp    %eax,%edx
f0103cb3:	77 f5                	ja     f0103caa <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103cb5:	5d                   	pop    %ebp
f0103cb6:	c3                   	ret    

f0103cb7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103cb7:	55                   	push   %ebp
f0103cb8:	89 e5                	mov    %esp,%ebp
f0103cba:	57                   	push   %edi
f0103cbb:	56                   	push   %esi
f0103cbc:	53                   	push   %ebx
f0103cbd:	8b 55 08             	mov    0x8(%ebp),%edx
f0103cc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103cc3:	0f b6 02             	movzbl (%edx),%eax
f0103cc6:	3c 20                	cmp    $0x20,%al
f0103cc8:	74 04                	je     f0103cce <strtol+0x17>
f0103cca:	3c 09                	cmp    $0x9,%al
f0103ccc:	75 0e                	jne    f0103cdc <strtol+0x25>
		s++;
f0103cce:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103cd1:	0f b6 02             	movzbl (%edx),%eax
f0103cd4:	3c 20                	cmp    $0x20,%al
f0103cd6:	74 f6                	je     f0103cce <strtol+0x17>
f0103cd8:	3c 09                	cmp    $0x9,%al
f0103cda:	74 f2                	je     f0103cce <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103cdc:	3c 2b                	cmp    $0x2b,%al
f0103cde:	75 0a                	jne    f0103cea <strtol+0x33>
		s++;
f0103ce0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103ce3:	bf 00 00 00 00       	mov    $0x0,%edi
f0103ce8:	eb 10                	jmp    f0103cfa <strtol+0x43>
f0103cea:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103cef:	3c 2d                	cmp    $0x2d,%al
f0103cf1:	75 07                	jne    f0103cfa <strtol+0x43>
		s++, neg = 1;
f0103cf3:	83 c2 01             	add    $0x1,%edx
f0103cf6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103cfa:	85 db                	test   %ebx,%ebx
f0103cfc:	0f 94 c0             	sete   %al
f0103cff:	74 05                	je     f0103d06 <strtol+0x4f>
f0103d01:	83 fb 10             	cmp    $0x10,%ebx
f0103d04:	75 15                	jne    f0103d1b <strtol+0x64>
f0103d06:	80 3a 30             	cmpb   $0x30,(%edx)
f0103d09:	75 10                	jne    f0103d1b <strtol+0x64>
f0103d0b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103d0f:	75 0a                	jne    f0103d1b <strtol+0x64>
		s += 2, base = 16;
f0103d11:	83 c2 02             	add    $0x2,%edx
f0103d14:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103d19:	eb 13                	jmp    f0103d2e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0103d1b:	84 c0                	test   %al,%al
f0103d1d:	74 0f                	je     f0103d2e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103d1f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103d24:	80 3a 30             	cmpb   $0x30,(%edx)
f0103d27:	75 05                	jne    f0103d2e <strtol+0x77>
		s++, base = 8;
f0103d29:	83 c2 01             	add    $0x1,%edx
f0103d2c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0103d2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d33:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103d35:	0f b6 0a             	movzbl (%edx),%ecx
f0103d38:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0103d3b:	80 fb 09             	cmp    $0x9,%bl
f0103d3e:	77 08                	ja     f0103d48 <strtol+0x91>
			dig = *s - '0';
f0103d40:	0f be c9             	movsbl %cl,%ecx
f0103d43:	83 e9 30             	sub    $0x30,%ecx
f0103d46:	eb 1e                	jmp    f0103d66 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0103d48:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0103d4b:	80 fb 19             	cmp    $0x19,%bl
f0103d4e:	77 08                	ja     f0103d58 <strtol+0xa1>
			dig = *s - 'a' + 10;
f0103d50:	0f be c9             	movsbl %cl,%ecx
f0103d53:	83 e9 57             	sub    $0x57,%ecx
f0103d56:	eb 0e                	jmp    f0103d66 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0103d58:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0103d5b:	80 fb 19             	cmp    $0x19,%bl
f0103d5e:	77 15                	ja     f0103d75 <strtol+0xbe>
			dig = *s - 'A' + 10;
f0103d60:	0f be c9             	movsbl %cl,%ecx
f0103d63:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0103d66:	39 f1                	cmp    %esi,%ecx
f0103d68:	7d 0f                	jge    f0103d79 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
f0103d6a:	83 c2 01             	add    $0x1,%edx
f0103d6d:	0f af c6             	imul   %esi,%eax
f0103d70:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0103d73:	eb c0                	jmp    f0103d35 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0103d75:	89 c1                	mov    %eax,%ecx
f0103d77:	eb 02                	jmp    f0103d7b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103d79:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0103d7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103d7f:	74 05                	je     f0103d86 <strtol+0xcf>
		*endptr = (char *) s;
f0103d81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103d84:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0103d86:	89 ca                	mov    %ecx,%edx
f0103d88:	f7 da                	neg    %edx
f0103d8a:	85 ff                	test   %edi,%edi
f0103d8c:	0f 45 c2             	cmovne %edx,%eax
}
f0103d8f:	5b                   	pop    %ebx
f0103d90:	5e                   	pop    %esi
f0103d91:	5f                   	pop    %edi
f0103d92:	5d                   	pop    %ebp
f0103d93:	c3                   	ret    
	...

f0103da0 <__udivdi3>:
f0103da0:	55                   	push   %ebp
f0103da1:	89 e5                	mov    %esp,%ebp
f0103da3:	57                   	push   %edi
f0103da4:	56                   	push   %esi
f0103da5:	83 ec 10             	sub    $0x10,%esp
f0103da8:	8b 75 14             	mov    0x14(%ebp),%esi
f0103dab:	8b 45 08             	mov    0x8(%ebp),%eax
f0103dae:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103db1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103db4:	85 f6                	test   %esi,%esi
f0103db6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103db9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103dbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0103dbf:	75 2f                	jne    f0103df0 <__udivdi3+0x50>
f0103dc1:	39 f9                	cmp    %edi,%ecx
f0103dc3:	77 5b                	ja     f0103e20 <__udivdi3+0x80>
f0103dc5:	85 c9                	test   %ecx,%ecx
f0103dc7:	75 0b                	jne    f0103dd4 <__udivdi3+0x34>
f0103dc9:	b8 01 00 00 00       	mov    $0x1,%eax
f0103dce:	31 d2                	xor    %edx,%edx
f0103dd0:	f7 f1                	div    %ecx
f0103dd2:	89 c1                	mov    %eax,%ecx
f0103dd4:	89 f8                	mov    %edi,%eax
f0103dd6:	31 d2                	xor    %edx,%edx
f0103dd8:	f7 f1                	div    %ecx
f0103dda:	89 c7                	mov    %eax,%edi
f0103ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ddf:	f7 f1                	div    %ecx
f0103de1:	89 fa                	mov    %edi,%edx
f0103de3:	83 c4 10             	add    $0x10,%esp
f0103de6:	5e                   	pop    %esi
f0103de7:	5f                   	pop    %edi
f0103de8:	5d                   	pop    %ebp
f0103de9:	c3                   	ret    
f0103dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103df0:	31 d2                	xor    %edx,%edx
f0103df2:	31 c0                	xor    %eax,%eax
f0103df4:	39 fe                	cmp    %edi,%esi
f0103df6:	77 eb                	ja     f0103de3 <__udivdi3+0x43>
f0103df8:	0f bd d6             	bsr    %esi,%edx
f0103dfb:	83 f2 1f             	xor    $0x1f,%edx
f0103dfe:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0103e01:	75 2d                	jne    f0103e30 <__udivdi3+0x90>
f0103e03:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103e06:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
f0103e09:	76 06                	jbe    f0103e11 <__udivdi3+0x71>
f0103e0b:	39 fe                	cmp    %edi,%esi
f0103e0d:	89 c2                	mov    %eax,%edx
f0103e0f:	73 d2                	jae    f0103de3 <__udivdi3+0x43>
f0103e11:	31 d2                	xor    %edx,%edx
f0103e13:	b8 01 00 00 00       	mov    $0x1,%eax
f0103e18:	eb c9                	jmp    f0103de3 <__udivdi3+0x43>
f0103e1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103e20:	89 fa                	mov    %edi,%edx
f0103e22:	f7 f1                	div    %ecx
f0103e24:	31 d2                	xor    %edx,%edx
f0103e26:	83 c4 10             	add    $0x10,%esp
f0103e29:	5e                   	pop    %esi
f0103e2a:	5f                   	pop    %edi
f0103e2b:	5d                   	pop    %ebp
f0103e2c:	c3                   	ret    
f0103e2d:	8d 76 00             	lea    0x0(%esi),%esi
f0103e30:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0103e34:	b8 20 00 00 00       	mov    $0x20,%eax
f0103e39:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103e3c:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0103e3f:	d3 e6                	shl    %cl,%esi
f0103e41:	89 c1                	mov    %eax,%ecx
f0103e43:	d3 ea                	shr    %cl,%edx
f0103e45:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0103e49:	09 f2                	or     %esi,%edx
f0103e4b:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0103e4e:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103e51:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103e54:	d3 e2                	shl    %cl,%edx
f0103e56:	89 c1                	mov    %eax,%ecx
f0103e58:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0103e5b:	89 fa                	mov    %edi,%edx
f0103e5d:	d3 ea                	shr    %cl,%edx
f0103e5f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0103e63:	d3 e7                	shl    %cl,%edi
f0103e65:	89 c1                	mov    %eax,%ecx
f0103e67:	d3 ee                	shr    %cl,%esi
f0103e69:	09 fe                	or     %edi,%esi
f0103e6b:	89 f0                	mov    %esi,%eax
f0103e6d:	f7 75 e8             	divl   -0x18(%ebp)
f0103e70:	89 d7                	mov    %edx,%edi
f0103e72:	89 c6                	mov    %eax,%esi
f0103e74:	f7 65 f0             	mull   -0x10(%ebp)
f0103e77:	39 d7                	cmp    %edx,%edi
f0103e79:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0103e7c:	72 22                	jb     f0103ea0 <__udivdi3+0x100>
f0103e7e:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0103e81:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0103e85:	d3 e2                	shl    %cl,%edx
f0103e87:	39 c2                	cmp    %eax,%edx
f0103e89:	73 05                	jae    f0103e90 <__udivdi3+0xf0>
f0103e8b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
f0103e8e:	74 10                	je     f0103ea0 <__udivdi3+0x100>
f0103e90:	89 f0                	mov    %esi,%eax
f0103e92:	31 d2                	xor    %edx,%edx
f0103e94:	e9 4a ff ff ff       	jmp    f0103de3 <__udivdi3+0x43>
f0103e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103ea0:	8d 46 ff             	lea    -0x1(%esi),%eax
f0103ea3:	31 d2                	xor    %edx,%edx
f0103ea5:	83 c4 10             	add    $0x10,%esp
f0103ea8:	5e                   	pop    %esi
f0103ea9:	5f                   	pop    %edi
f0103eaa:	5d                   	pop    %ebp
f0103eab:	c3                   	ret    
f0103eac:	00 00                	add    %al,(%eax)
	...

f0103eb0 <__umoddi3>:
f0103eb0:	55                   	push   %ebp
f0103eb1:	89 e5                	mov    %esp,%ebp
f0103eb3:	57                   	push   %edi
f0103eb4:	56                   	push   %esi
f0103eb5:	83 ec 20             	sub    $0x20,%esp
f0103eb8:	8b 7d 14             	mov    0x14(%ebp),%edi
f0103ebb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ebe:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103ec1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103ec4:	85 ff                	test   %edi,%edi
f0103ec6:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0103ec9:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0103ecc:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103ecf:	89 f2                	mov    %esi,%edx
f0103ed1:	75 15                	jne    f0103ee8 <__umoddi3+0x38>
f0103ed3:	39 f1                	cmp    %esi,%ecx
f0103ed5:	76 41                	jbe    f0103f18 <__umoddi3+0x68>
f0103ed7:	f7 f1                	div    %ecx
f0103ed9:	89 d0                	mov    %edx,%eax
f0103edb:	31 d2                	xor    %edx,%edx
f0103edd:	83 c4 20             	add    $0x20,%esp
f0103ee0:	5e                   	pop    %esi
f0103ee1:	5f                   	pop    %edi
f0103ee2:	5d                   	pop    %ebp
f0103ee3:	c3                   	ret    
f0103ee4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103ee8:	39 f7                	cmp    %esi,%edi
f0103eea:	77 4c                	ja     f0103f38 <__umoddi3+0x88>
f0103eec:	0f bd c7             	bsr    %edi,%eax
f0103eef:	83 f0 1f             	xor    $0x1f,%eax
f0103ef2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103ef5:	75 51                	jne    f0103f48 <__umoddi3+0x98>
f0103ef7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0103efa:	0f 87 e8 00 00 00    	ja     f0103fe8 <__umoddi3+0x138>
f0103f00:	89 f2                	mov    %esi,%edx
f0103f02:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0103f05:	29 ce                	sub    %ecx,%esi
f0103f07:	19 fa                	sbb    %edi,%edx
f0103f09:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0103f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103f0f:	83 c4 20             	add    $0x20,%esp
f0103f12:	5e                   	pop    %esi
f0103f13:	5f                   	pop    %edi
f0103f14:	5d                   	pop    %ebp
f0103f15:	c3                   	ret    
f0103f16:	66 90                	xchg   %ax,%ax
f0103f18:	85 c9                	test   %ecx,%ecx
f0103f1a:	75 0b                	jne    f0103f27 <__umoddi3+0x77>
f0103f1c:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f21:	31 d2                	xor    %edx,%edx
f0103f23:	f7 f1                	div    %ecx
f0103f25:	89 c1                	mov    %eax,%ecx
f0103f27:	89 f0                	mov    %esi,%eax
f0103f29:	31 d2                	xor    %edx,%edx
f0103f2b:	f7 f1                	div    %ecx
f0103f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103f30:	eb a5                	jmp    f0103ed7 <__umoddi3+0x27>
f0103f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103f38:	89 f2                	mov    %esi,%edx
f0103f3a:	83 c4 20             	add    $0x20,%esp
f0103f3d:	5e                   	pop    %esi
f0103f3e:	5f                   	pop    %edi
f0103f3f:	5d                   	pop    %ebp
f0103f40:	c3                   	ret    
f0103f41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103f48:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0103f4c:	89 f2                	mov    %esi,%edx
f0103f4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103f51:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
f0103f58:	29 45 f0             	sub    %eax,-0x10(%ebp)
f0103f5b:	d3 e7                	shl    %cl,%edi
f0103f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f60:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0103f64:	d3 e8                	shr    %cl,%eax
f0103f66:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0103f6a:	09 f8                	or     %edi,%eax
f0103f6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f72:	d3 e0                	shl    %cl,%eax
f0103f74:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0103f78:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0103f7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103f7e:	d3 ea                	shr    %cl,%edx
f0103f80:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0103f84:	d3 e6                	shl    %cl,%esi
f0103f86:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0103f8a:	d3 e8                	shr    %cl,%eax
f0103f8c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0103f90:	09 f0                	or     %esi,%eax
f0103f92:	8b 75 e8             	mov    -0x18(%ebp),%esi
f0103f95:	f7 75 e4             	divl   -0x1c(%ebp)
f0103f98:	d3 e6                	shl    %cl,%esi
f0103f9a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0103f9d:	89 d6                	mov    %edx,%esi
f0103f9f:	f7 65 f4             	mull   -0xc(%ebp)
f0103fa2:	89 d7                	mov    %edx,%edi
f0103fa4:	89 c2                	mov    %eax,%edx
f0103fa6:	39 fe                	cmp    %edi,%esi
f0103fa8:	89 f9                	mov    %edi,%ecx
f0103faa:	72 30                	jb     f0103fdc <__umoddi3+0x12c>
f0103fac:	39 45 e8             	cmp    %eax,-0x18(%ebp)
f0103faf:	72 27                	jb     f0103fd8 <__umoddi3+0x128>
f0103fb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103fb4:	29 d0                	sub    %edx,%eax
f0103fb6:	19 ce                	sbb    %ecx,%esi
f0103fb8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0103fbc:	89 f2                	mov    %esi,%edx
f0103fbe:	d3 e8                	shr    %cl,%eax
f0103fc0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0103fc4:	d3 e2                	shl    %cl,%edx
f0103fc6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0103fca:	09 d0                	or     %edx,%eax
f0103fcc:	89 f2                	mov    %esi,%edx
f0103fce:	d3 ea                	shr    %cl,%edx
f0103fd0:	83 c4 20             	add    $0x20,%esp
f0103fd3:	5e                   	pop    %esi
f0103fd4:	5f                   	pop    %edi
f0103fd5:	5d                   	pop    %ebp
f0103fd6:	c3                   	ret    
f0103fd7:	90                   	nop
f0103fd8:	39 fe                	cmp    %edi,%esi
f0103fda:	75 d5                	jne    f0103fb1 <__umoddi3+0x101>
f0103fdc:	89 f9                	mov    %edi,%ecx
f0103fde:	89 c2                	mov    %eax,%edx
f0103fe0:	2b 55 f4             	sub    -0xc(%ebp),%edx
f0103fe3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0103fe6:	eb c9                	jmp    f0103fb1 <__umoddi3+0x101>
f0103fe8:	39 f7                	cmp    %esi,%edi
f0103fea:	0f 82 10 ff ff ff    	jb     f0103f00 <__umoddi3+0x50>
f0103ff0:	e9 17 ff ff ff       	jmp    f0103f0c <__umoddi3+0x5c>
