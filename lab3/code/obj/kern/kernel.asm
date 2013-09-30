
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
f010004e:	c7 04 24 60 42 10 f0 	movl   $0xf0104260,(%esp)
f0100055:	e8 68 31 00 00       	call   f01031c2 <cprintf>
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
f0100082:	e8 93 07 00 00       	call   f010081a <backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 7c 42 10 f0 	movl   $0xf010427c,(%esp)
f0100092:	e8 2b 31 00 00       	call   f01031c2 <cprintf>
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
f01000c0:	e8 dc 3c 00 00       	call   f0103da1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 b2 04 00 00       	call   f010057c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 97 42 10 f0 	movl   $0xf0104297,(%esp)
f01000d9:	e8 e4 30 00 00       	call   f01031c2 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000de:	e8 4d 14 00 00       	call   f0101530 <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000ea:	e8 e4 07 00 00       	call   f01008d3 <monitor>
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
f010011e:	c7 04 24 b2 42 10 f0 	movl   $0xf01042b2,(%esp)
f0100125:	e8 98 30 00 00       	call   f01031c2 <cprintf>
	vcprintf(fmt, ap);
f010012a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010012e:	89 34 24             	mov    %esi,(%esp)
f0100131:	e8 59 30 00 00       	call   f010318f <vcprintf>
	cprintf("\n");
f0100136:	c7 04 24 b1 53 10 f0 	movl   $0xf01053b1,(%esp)
f010013d:	e8 80 30 00 00       	call   f01031c2 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100142:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100149:	e8 85 07 00 00       	call   f01008d3 <monitor>
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
f0100168:	c7 04 24 ca 42 10 f0 	movl   $0xf01042ca,(%esp)
f010016f:	e8 4e 30 00 00       	call   f01031c2 <cprintf>
	vcprintf(fmt, ap);
f0100174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100178:	8b 45 10             	mov    0x10(%ebp),%eax
f010017b:	89 04 24             	mov    %eax,(%esp)
f010017e:	e8 0c 30 00 00       	call   f010318f <vcprintf>
	cprintf("\n");
f0100183:	c7 04 24 b1 53 10 f0 	movl   $0xf01053b1,(%esp)
f010018a:	e8 33 30 00 00       	call   f01031c2 <cprintf>
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
f01003ae:	e8 4d 3a 00 00       	call   f0103e00 <memmove>
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
f010045a:	0f b6 82 20 43 10 f0 	movzbl -0xfefbce0(%edx),%eax
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
f0100497:	0f b6 82 20 43 10 f0 	movzbl -0xfefbce0(%edx),%eax
f010049e:	0b 05 28 85 11 f0    	or     0xf0118528,%eax
	shift ^= togglecode[data];
f01004a4:	0f b6 8a 20 44 10 f0 	movzbl -0xfefbbe0(%edx),%ecx
f01004ab:	31 c8                	xor    %ecx,%eax
f01004ad:	a3 28 85 11 f0       	mov    %eax,0xf0118528

	c = charcode[shift & (CTL | SHIFT)][data];
f01004b2:	89 c1                	mov    %eax,%ecx
f01004b4:	83 e1 03             	and    $0x3,%ecx
f01004b7:	8b 0c 8d 20 45 10 f0 	mov    -0xfefbae0(,%ecx,4),%ecx
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
f01004ed:	c7 04 24 e4 42 10 f0 	movl   $0xf01042e4,(%esp)
f01004f4:	e8 c9 2c 00 00       	call   f01031c2 <cprintf>
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
f010065d:	c7 04 24 f0 42 10 f0 	movl   $0xf01042f0,(%esp)
f0100664:	e8 59 2b 00 00       	call   f01031c2 <cprintf>
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
f01006ac:	c7 04 24 30 45 10 f0 	movl   $0xf0104530,(%esp)
f01006b3:	e8 0a 2b 00 00       	call   f01031c2 <cprintf>
	while (ebp) {
f01006b8:	85 db                	test   %ebx,%ebx
f01006ba:	74 49                	je     f0100705 <mon_backtrace+0x65>
		cprintf("ebp %x  eip %x  args", ebp, ebp[1]);
f01006bc:	8b 46 04             	mov    0x4(%esi),%eax
f01006bf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006c3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01006c7:	c7 04 24 42 45 10 f0 	movl   $0xf0104542,(%esp)
f01006ce:	e8 ef 2a 00 00       	call   f01031c2 <cprintf>
		int i;
		for (i = 2; i <= 6; ++i)
f01006d3:	bb 02 00 00 00       	mov    $0x2,%ebx
			cprintf(" %08.x", ebp[i]);
f01006d8:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
f01006db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006df:	c7 04 24 57 45 10 f0 	movl   $0xf0104557,(%esp)
f01006e6:	e8 d7 2a 00 00       	call   f01031c2 <cprintf>
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
f01006f3:	c7 04 24 b1 53 10 f0 	movl   $0xf01053b1,(%esp)
f01006fa:	e8 c3 2a 00 00       	call   f01031c2 <cprintf>
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
f0100717:	c7 04 24 5e 45 10 f0 	movl   $0xf010455e,(%esp)
f010071e:	e8 9f 2a 00 00       	call   f01031c2 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100723:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010072a:	00 
f010072b:	c7 04 24 a0 46 10 f0 	movl   $0xf01046a0,(%esp)
f0100732:	e8 8b 2a 00 00       	call   f01031c2 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100737:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010073e:	00 
f010073f:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100746:	f0 
f0100747:	c7 04 24 c8 46 10 f0 	movl   $0xf01046c8,(%esp)
f010074e:	e8 6f 2a 00 00       	call   f01031c2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100753:	c7 44 24 08 55 42 10 	movl   $0x104255,0x8(%esp)
f010075a:	00 
f010075b:	c7 44 24 04 55 42 10 	movl   $0xf0104255,0x4(%esp)
f0100762:	f0 
f0100763:	c7 04 24 ec 46 10 f0 	movl   $0xf01046ec,(%esp)
f010076a:	e8 53 2a 00 00       	call   f01031c2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010076f:	c7 44 24 08 00 83 11 	movl   $0x118300,0x8(%esp)
f0100776:	00 
f0100777:	c7 44 24 04 00 83 11 	movl   $0xf0118300,0x4(%esp)
f010077e:	f0 
f010077f:	c7 04 24 10 47 10 f0 	movl   $0xf0104710,(%esp)
f0100786:	e8 37 2a 00 00       	call   f01031c2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010078b:	c7 44 24 08 54 89 11 	movl   $0x118954,0x8(%esp)
f0100792:	00 
f0100793:	c7 44 24 04 54 89 11 	movl   $0xf0118954,0x4(%esp)
f010079a:	f0 
f010079b:	c7 04 24 34 47 10 f0 	movl   $0xf0104734,(%esp)
f01007a2:	e8 1b 2a 00 00       	call   f01031c2 <cprintf>
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
f01007c8:	c7 04 24 58 47 10 f0 	movl   $0xf0104758,(%esp)
f01007cf:	e8 ee 29 00 00       	call   f01031c2 <cprintf>
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
f01007de:	53                   	push   %ebx
f01007df:	83 ec 14             	sub    $0x14,%esp
f01007e2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007e7:	8b 83 c4 48 10 f0    	mov    -0xfefb73c(%ebx),%eax
f01007ed:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007f1:	8b 83 c0 48 10 f0    	mov    -0xfefb740(%ebx),%eax
f01007f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007fb:	c7 04 24 77 45 10 f0 	movl   $0xf0104577,(%esp)
f0100802:	e8 bb 29 00 00       	call   f01031c2 <cprintf>
f0100807:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f010080a:	83 fb 48             	cmp    $0x48,%ebx
f010080d:	75 d8                	jne    f01007e7 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010080f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100814:	83 c4 14             	add    $0x14,%esp
f0100817:	5b                   	pop    %ebx
f0100818:	5d                   	pop    %ebp
f0100819:	c3                   	ret    

f010081a <backtrace>:
	return 0;
}

int
backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010081a:	55                   	push   %ebp
f010081b:	89 e5                	mov    %esp,%ebp
f010081d:	57                   	push   %edi
f010081e:	56                   	push   %esi
f010081f:	53                   	push   %ebx
f0100820:	83 ec 4c             	sub    $0x4c,%esp
f0100823:	89 eb                	mov    %ebp,%ebx
	uint32_t* ebp = (uint32_t*) read_ebp();
f0100825:	89 de                	mov    %ebx,%esi
	cprintf("Stack backtrace:\n");
f0100827:	c7 04 24 30 45 10 f0 	movl   $0xf0104530,(%esp)
f010082e:	e8 8f 29 00 00       	call   f01031c2 <cprintf>
	while (ebp) {
f0100833:	85 db                	test   %ebx,%ebx
f0100835:	0f 84 8b 00 00 00    	je     f01008c6 <backtrace+0xac>
		uint32_t eip = ebp[1];
f010083b:	8b 7e 04             	mov    0x4(%esi),%edi
		cprintf("ebp %x  eip %x  args", ebp, eip);
f010083e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100842:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100846:	c7 04 24 42 45 10 f0 	movl   $0xf0104542,(%esp)
f010084d:	e8 70 29 00 00       	call   f01031c2 <cprintf>
		int i;
		for (i = 2; i <= 6; ++i)
f0100852:	bb 02 00 00 00       	mov    $0x2,%ebx
			cprintf(" %08.x", ebp[i]);
f0100857:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
f010085a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010085e:	c7 04 24 57 45 10 f0 	movl   $0xf0104557,(%esp)
f0100865:	e8 58 29 00 00       	call   f01031c2 <cprintf>
	cprintf("Stack backtrace:\n");
	while (ebp) {
		uint32_t eip = ebp[1];
		cprintf("ebp %x  eip %x  args", ebp, eip);
		int i;
		for (i = 2; i <= 6; ++i)
f010086a:	83 c3 01             	add    $0x1,%ebx
f010086d:	83 fb 07             	cmp    $0x7,%ebx
f0100870:	75 e5                	jne    f0100857 <backtrace+0x3d>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
f0100872:	c7 04 24 b1 53 10 f0 	movl   $0xf01053b1,(%esp)
f0100879:	e8 44 29 00 00       	call   f01031c2 <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f010087e:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100881:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100885:	89 3c 24             	mov    %edi,(%esp)
f0100888:	e8 81 2a 00 00       	call   f010330e <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n", 
f010088d:	2b 7d e0             	sub    -0x20(%ebp),%edi
f0100890:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0100894:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100897:	89 44 24 10          	mov    %eax,0x10(%esp)
f010089b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010089e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01008a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01008a5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01008ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008b0:	c7 04 24 80 45 10 f0 	movl   $0xf0104580,(%esp)
f01008b7:	e8 06 29 00 00       	call   f01031c2 <cprintf>
			info.eip_file, info.eip_line,
			info.eip_fn_namelen, info.eip_fn_name,
			eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
		ebp = (uint32_t*) *ebp;
f01008bc:	8b 36                	mov    (%esi),%esi
int
backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f01008be:	85 f6                	test   %esi,%esi
f01008c0:	0f 85 75 ff ff ff    	jne    f010083b <backtrace+0x21>
			eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
		ebp = (uint32_t*) *ebp;
	}
	return 0;
}
f01008c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01008cb:	83 c4 4c             	add    $0x4c,%esp
f01008ce:	5b                   	pop    %ebx
f01008cf:	5e                   	pop    %esi
f01008d0:	5f                   	pop    %edi
f01008d1:	5d                   	pop    %ebp
f01008d2:	c3                   	ret    

f01008d3 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008d3:	55                   	push   %ebp
f01008d4:	89 e5                	mov    %esp,%ebp
f01008d6:	57                   	push   %edi
f01008d7:	56                   	push   %esi
f01008d8:	53                   	push   %ebx
f01008d9:	83 ec 6c             	sub    $0x6c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008dc:	c7 04 24 84 47 10 f0 	movl   $0xf0104784,(%esp)
f01008e3:	e8 da 28 00 00       	call   f01031c2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008e8:	c7 04 24 a8 47 10 f0 	movl   $0xf01047a8,(%esp)
f01008ef:	e8 ce 28 00 00       	call   f01031c2 <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n", 
f01008f4:	c7 44 24 18 91 45 10 	movl   $0xf0104591,0x18(%esp)
f01008fb:	f0 
f01008fc:	c7 44 24 14 00 04 00 	movl   $0x400,0x14(%esp)
f0100903:	00 
f0100904:	c7 44 24 10 95 45 10 	movl   $0xf0104595,0x10(%esp)
f010090b:	f0 
f010090c:	c7 44 24 0c 00 02 00 	movl   $0x200,0xc(%esp)
f0100913:	00 
f0100914:	c7 44 24 08 9b 45 10 	movl   $0xf010459b,0x8(%esp)
f010091b:	f0 
f010091c:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
f0100923:	00 
f0100924:	c7 04 24 a0 45 10 f0 	movl   $0xf01045a0,(%esp)
f010092b:	e8 92 28 00 00       	call   f01031c2 <cprintf>
		0x0100, "blue", 0x0200, "green", 0x0400, "red");


	while (1) {
		buf = readline("K> ");
f0100930:	c7 04 24 b0 45 10 f0 	movl   $0xf01045b0,(%esp)
f0100937:	e8 c4 31 00 00       	call   f0103b00 <readline>
f010093c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010093e:	85 c0                	test   %eax,%eax
f0100940:	74 ee                	je     f0100930 <monitor+0x5d>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100942:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100949:	be 00 00 00 00       	mov    $0x0,%esi
f010094e:	eb 06                	jmp    f0100956 <monitor+0x83>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100950:	c6 03 00             	movb   $0x0,(%ebx)
f0100953:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100956:	0f b6 03             	movzbl (%ebx),%eax
f0100959:	84 c0                	test   %al,%al
f010095b:	74 6a                	je     f01009c7 <monitor+0xf4>
f010095d:	0f be c0             	movsbl %al,%eax
f0100960:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100964:	c7 04 24 b4 45 10 f0 	movl   $0xf01045b4,(%esp)
f010096b:	e8 d2 33 00 00       	call   f0103d42 <strchr>
f0100970:	85 c0                	test   %eax,%eax
f0100972:	75 dc                	jne    f0100950 <monitor+0x7d>
			*buf++ = 0;
		if (*buf == 0)
f0100974:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100977:	74 4e                	je     f01009c7 <monitor+0xf4>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100979:	83 fe 0f             	cmp    $0xf,%esi
f010097c:	75 16                	jne    f0100994 <monitor+0xc1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010097e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100985:	00 
f0100986:	c7 04 24 b9 45 10 f0 	movl   $0xf01045b9,(%esp)
f010098d:	e8 30 28 00 00       	call   f01031c2 <cprintf>
f0100992:	eb 9c                	jmp    f0100930 <monitor+0x5d>
			return 0;
		}
		argv[argc++] = buf;
f0100994:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100998:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010099b:	0f b6 03             	movzbl (%ebx),%eax
f010099e:	84 c0                	test   %al,%al
f01009a0:	75 0c                	jne    f01009ae <monitor+0xdb>
f01009a2:	eb b2                	jmp    f0100956 <monitor+0x83>
			buf++;
f01009a4:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009a7:	0f b6 03             	movzbl (%ebx),%eax
f01009aa:	84 c0                	test   %al,%al
f01009ac:	74 a8                	je     f0100956 <monitor+0x83>
f01009ae:	0f be c0             	movsbl %al,%eax
f01009b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009b5:	c7 04 24 b4 45 10 f0 	movl   $0xf01045b4,(%esp)
f01009bc:	e8 81 33 00 00       	call   f0103d42 <strchr>
f01009c1:	85 c0                	test   %eax,%eax
f01009c3:	74 df                	je     f01009a4 <monitor+0xd1>
f01009c5:	eb 8f                	jmp    f0100956 <monitor+0x83>
			buf++;
	}
	argv[argc] = 0;
f01009c7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009ce:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009cf:	85 f6                	test   %esi,%esi
f01009d1:	0f 84 59 ff ff ff    	je     f0100930 <monitor+0x5d>
f01009d7:	bb c0 48 10 f0       	mov    $0xf01048c0,%ebx
f01009dc:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009e1:	8b 03                	mov    (%ebx),%eax
f01009e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009e7:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009ea:	89 04 24             	mov    %eax,(%esp)
f01009ed:	e8 d6 32 00 00       	call   f0103cc8 <strcmp>
f01009f2:	85 c0                	test   %eax,%eax
f01009f4:	75 23                	jne    f0100a19 <monitor+0x146>
			return commands[i].func(argc, argv, tf);
f01009f6:	6b ff 0c             	imul   $0xc,%edi,%edi
f01009f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01009fc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a00:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100a03:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a07:	89 34 24             	mov    %esi,(%esp)
f0100a0a:	ff 97 c8 48 10 f0    	call   *-0xfefb738(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a10:	85 c0                	test   %eax,%eax
f0100a12:	78 28                	js     f0100a3c <monitor+0x169>
f0100a14:	e9 17 ff ff ff       	jmp    f0100930 <monitor+0x5d>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a19:	83 c7 01             	add    $0x1,%edi
f0100a1c:	83 c3 0c             	add    $0xc,%ebx
f0100a1f:	83 ff 06             	cmp    $0x6,%edi
f0100a22:	75 bd                	jne    f01009e1 <monitor+0x10e>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a24:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a27:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a2b:	c7 04 24 d6 45 10 f0 	movl   $0xf01045d6,(%esp)
f0100a32:	e8 8b 27 00 00       	call   f01031c2 <cprintf>
f0100a37:	e9 f4 fe ff ff       	jmp    f0100930 <monitor+0x5d>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a3c:	83 c4 6c             	add    $0x6c,%esp
f0100a3f:	5b                   	pop    %ebx
f0100a40:	5e                   	pop    %esi
f0100a41:	5f                   	pop    %edi
f0100a42:	5d                   	pop    %ebp
f0100a43:	c3                   	ret    

f0100a44 <xtoi>:

uint32_t xtoi(char* buf) {
f0100a44:	55                   	push   %ebp
f0100a45:	89 e5                	mov    %esp,%ebp
f0100a47:	8b 45 08             	mov    0x8(%ebp),%eax
	uint32_t res = 0;
	buf += 2; //0x...
f0100a4a:	8d 50 02             	lea    0x2(%eax),%edx
	while (*buf) { 
f0100a4d:	0f b6 48 02          	movzbl 0x2(%eax),%ecx
				break;
	}
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
f0100a51:	b8 00 00 00 00       	mov    $0x0,%eax
	buf += 2; //0x...
	while (*buf) { 
f0100a56:	84 c9                	test   %cl,%cl
f0100a58:	74 1e                	je     f0100a78 <xtoi+0x34>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
f0100a5a:	80 f9 60             	cmp    $0x60,%cl
f0100a5d:	7e 05                	jle    f0100a64 <xtoi+0x20>
f0100a5f:	83 e9 27             	sub    $0x27,%ecx
f0100a62:	88 0a                	mov    %cl,(%edx)
		res = res*16 + *buf - '0';
f0100a64:	c1 e0 04             	shl    $0x4,%eax
f0100a67:	0f be 0a             	movsbl (%edx),%ecx
f0100a6a:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
		++buf;
f0100a6e:	83 c2 01             	add    $0x1,%edx
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
	buf += 2; //0x...
	while (*buf) { 
f0100a71:	0f b6 0a             	movzbl (%edx),%ecx
f0100a74:	84 c9                	test   %cl,%cl
f0100a76:	75 e2                	jne    f0100a5a <xtoi+0x16>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
		res = res*16 + *buf - '0';
		++buf;
	}
	return res;
}
f0100a78:	5d                   	pop    %ebp
f0100a79:	c3                   	ret    

f0100a7a <pprint>:
void pprint(pte_t *pte) {
f0100a7a:	55                   	push   %ebp
f0100a7b:	89 e5                	mov    %esp,%ebp
f0100a7d:	83 ec 18             	sub    $0x18,%esp
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
f0100a80:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a83:	8b 00                	mov    (%eax),%eax
		++buf;
	}
	return res;
}
void pprint(pte_t *pte) {
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
f0100a85:	89 c2                	mov    %eax,%edx
f0100a87:	83 e2 04             	and    $0x4,%edx
f0100a8a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100a8e:	89 c2                	mov    %eax,%edx
f0100a90:	83 e2 02             	and    $0x2,%edx
f0100a93:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100a97:	83 e0 01             	and    $0x1,%eax
f0100a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a9e:	c7 04 24 d0 47 10 f0 	movl   $0xf01047d0,(%esp)
f0100aa5:	e8 18 27 00 00       	call   f01031c2 <cprintf>
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
}
f0100aaa:	c9                   	leave  
f0100aab:	c3                   	ret    

f0100aac <setm>:
		} else cprintf("page not exist: %x\n", begin);
	}
	return 0;
}

int setm(int argc, char **argv, struct Trapframe *tf) {
f0100aac:	55                   	push   %ebp
f0100aad:	89 e5                	mov    %esp,%ebp
f0100aaf:	83 ec 28             	sub    $0x28,%esp
f0100ab2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100ab5:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100ab8:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100abb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc == 1) {
f0100abe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100ac2:	75 11                	jne    f0100ad5 <setm+0x29>
		cprintf("Usage: setm 0xaddr [0|1 :clear or set] [P|W|U]\n");
f0100ac4:	c7 04 24 f4 47 10 f0 	movl   $0xf01047f4,(%esp)
f0100acb:	e8 f2 26 00 00       	call   f01031c2 <cprintf>
		return 0;
f0100ad0:	e9 88 00 00 00       	jmp    f0100b5d <setm+0xb1>
	}
	uint32_t addr = xtoi(argv[1]);
f0100ad5:	8b 43 04             	mov    0x4(%ebx),%eax
f0100ad8:	89 04 24             	mov    %eax,(%esp)
f0100adb:	e8 64 ff ff ff       	call   f0100a44 <xtoi>
f0100ae0:	89 c7                	mov    %eax,%edi
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
f0100ae2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100ae9:	00 
f0100aea:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aee:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0100af3:	89 04 24             	mov    %eax,(%esp)
f0100af6:	e8 8b 07 00 00       	call   f0101286 <pgdir_walk>
f0100afb:	89 c6                	mov    %eax,%esi
	cprintf("%x before setm: ", addr);
f0100afd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100b01:	c7 04 24 ec 45 10 f0 	movl   $0xf01045ec,(%esp)
f0100b08:	e8 b5 26 00 00       	call   f01031c2 <cprintf>
	pprint(pte);
f0100b0d:	89 34 24             	mov    %esi,(%esp)
f0100b10:	e8 65 ff ff ff       	call   f0100a7a <pprint>
	uint32_t perm = 0;
	if (argv[3][0] == 'P') perm = PTE_P;
f0100b15:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100b18:	0f b6 10             	movzbl (%eax),%edx
	if (argv[3][0] == 'W') perm = PTE_W;
f0100b1b:	b8 02 00 00 00       	mov    $0x2,%eax
f0100b20:	80 fa 57             	cmp    $0x57,%dl
f0100b23:	74 10                	je     f0100b35 <setm+0x89>
	if (argv[3][0] == 'U') perm = PTE_U;
f0100b25:	b0 04                	mov    $0x4,%al
f0100b27:	80 fa 55             	cmp    $0x55,%dl
f0100b2a:	74 09                	je     f0100b35 <setm+0x89>
	}
	uint32_t addr = xtoi(argv[1]);
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
	cprintf("%x before setm: ", addr);
	pprint(pte);
	uint32_t perm = 0;
f0100b2c:	80 fa 50             	cmp    $0x50,%dl
f0100b2f:	0f 94 c0             	sete   %al
f0100b32:	0f b6 c0             	movzbl %al,%eax
	if (argv[3][0] == 'P') perm = PTE_P;
	if (argv[3][0] == 'W') perm = PTE_W;
	if (argv[3][0] == 'U') perm = PTE_U;
	if (argv[2][0] == '0') 	//clear
f0100b35:	8b 53 08             	mov    0x8(%ebx),%edx
f0100b38:	80 3a 30             	cmpb   $0x30,(%edx)
f0100b3b:	75 06                	jne    f0100b43 <setm+0x97>
		*pte = *pte & ~perm;
f0100b3d:	f7 d0                	not    %eax
f0100b3f:	21 06                	and    %eax,(%esi)
f0100b41:	eb 02                	jmp    f0100b45 <setm+0x99>
	else 	//set
		*pte = *pte | perm;
f0100b43:	09 06                	or     %eax,(%esi)
	cprintf("%x after  setm: ", addr);
f0100b45:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100b49:	c7 04 24 fd 45 10 f0 	movl   $0xf01045fd,(%esp)
f0100b50:	e8 6d 26 00 00       	call   f01031c2 <cprintf>
	pprint(pte);
f0100b55:	89 34 24             	mov    %esi,(%esp)
f0100b58:	e8 1d ff ff ff       	call   f0100a7a <pprint>
	return 0;
}
f0100b5d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b62:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100b65:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100b68:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100b6b:	89 ec                	mov    %ebp,%esp
f0100b6d:	5d                   	pop    %ebp
f0100b6e:	c3                   	ret    

f0100b6f <showmappings>:
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
}
int
showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100b6f:	55                   	push   %ebp
f0100b70:	89 e5                	mov    %esp,%ebp
f0100b72:	57                   	push   %edi
f0100b73:	56                   	push   %esi
f0100b74:	53                   	push   %ebx
f0100b75:	83 ec 1c             	sub    $0x1c,%esp
f0100b78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc == 1) {
f0100b7b:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100b7f:	75 11                	jne    f0100b92 <showmappings+0x23>
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
f0100b81:	c7 04 24 24 48 10 f0 	movl   $0xf0104824,(%esp)
f0100b88:	e8 35 26 00 00       	call   f01031c2 <cprintf>
		return 0;
f0100b8d:	e9 a6 00 00 00       	jmp    f0100c38 <showmappings+0xc9>
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
f0100b92:	8b 43 04             	mov    0x4(%ebx),%eax
f0100b95:	89 04 24             	mov    %eax,(%esp)
f0100b98:	e8 a7 fe ff ff       	call   f0100a44 <xtoi>
f0100b9d:	89 c6                	mov    %eax,%esi
f0100b9f:	8b 43 08             	mov    0x8(%ebx),%eax
f0100ba2:	89 04 24             	mov    %eax,(%esp)
f0100ba5:	e8 9a fe ff ff       	call   f0100a44 <xtoi>
f0100baa:	89 c7                	mov    %eax,%edi
	cprintf("begin: %x, end: %x\n", begin, end);
f0100bac:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100bb0:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100bb4:	c7 04 24 0e 46 10 f0 	movl   $0xf010460e,(%esp)
f0100bbb:	e8 02 26 00 00       	call   f01031c2 <cprintf>
	for (; begin <= end; begin += PGSIZE) {
f0100bc0:	39 fe                	cmp    %edi,%esi
f0100bc2:	77 74                	ja     f0100c38 <showmappings+0xc9>
		pte_t *pte = pgdir_walk(kern_pgdir, (void *) begin, 1);	//create
f0100bc4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100bcb:	00 
f0100bcc:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100bd0:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0100bd5:	89 04 24             	mov    %eax,(%esp)
f0100bd8:	e8 a9 06 00 00       	call   f0101286 <pgdir_walk>
f0100bdd:	89 c3                	mov    %eax,%ebx
		if (!pte) panic("boot_map_region panic, out of memory");
f0100bdf:	85 c0                	test   %eax,%eax
f0100be1:	75 1c                	jne    f0100bff <showmappings+0x90>
f0100be3:	c7 44 24 08 54 48 10 	movl   $0xf0104854,0x8(%esp)
f0100bea:	f0 
f0100beb:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
f0100bf2:	00 
f0100bf3:	c7 04 24 22 46 10 f0 	movl   $0xf0104622,(%esp)
f0100bfa:	e8 f2 f4 ff ff       	call   f01000f1 <_panic>
		if (*pte & PTE_P) {
f0100bff:	f6 00 01             	testb  $0x1,(%eax)
f0100c02:	74 1a                	je     f0100c1e <showmappings+0xaf>
			cprintf("page %x with ", begin);
f0100c04:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c08:	c7 04 24 31 46 10 f0 	movl   $0xf0104631,(%esp)
f0100c0f:	e8 ae 25 00 00       	call   f01031c2 <cprintf>
			pprint(pte);
f0100c14:	89 1c 24             	mov    %ebx,(%esp)
f0100c17:	e8 5e fe ff ff       	call   f0100a7a <pprint>
f0100c1c:	eb 10                	jmp    f0100c2e <showmappings+0xbf>
		} else cprintf("page not exist: %x\n", begin);
f0100c1e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c22:	c7 04 24 3f 46 10 f0 	movl   $0xf010463f,(%esp)
f0100c29:	e8 94 25 00 00       	call   f01031c2 <cprintf>
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
		return 0;
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
	cprintf("begin: %x, end: %x\n", begin, end);
	for (; begin <= end; begin += PGSIZE) {
f0100c2e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100c34:	39 f7                	cmp    %esi,%edi
f0100c36:	73 8c                	jae    f0100bc4 <showmappings+0x55>
			cprintf("page %x with ", begin);
			pprint(pte);
		} else cprintf("page not exist: %x\n", begin);
	}
	return 0;
}
f0100c38:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c3d:	83 c4 1c             	add    $0x1c,%esp
f0100c40:	5b                   	pop    %ebx
f0100c41:	5e                   	pop    %esi
f0100c42:	5f                   	pop    %edi
f0100c43:	5d                   	pop    %ebp
f0100c44:	c3                   	ret    
f0100c45:	00 00                	add    %al,(%eax)
	...

f0100c48 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100c48:	55                   	push   %ebp
f0100c49:	89 e5                	mov    %esp,%ebp
f0100c4b:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100c4e:	89 d1                	mov    %edx,%ecx
f0100c50:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100c53:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100c56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100c5b:	f6 c1 01             	test   $0x1,%cl
f0100c5e:	74 57                	je     f0100cb7 <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100c60:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c66:	89 c8                	mov    %ecx,%eax
f0100c68:	c1 e8 0c             	shr    $0xc,%eax
f0100c6b:	3b 05 48 89 11 f0    	cmp    0xf0118948,%eax
f0100c71:	72 20                	jb     f0100c93 <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c73:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100c77:	c7 44 24 08 08 49 10 	movl   $0xf0104908,0x8(%esp)
f0100c7e:	f0 
f0100c7f:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0100c86:	00 
f0100c87:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0100c8e:	e8 5e f4 ff ff       	call   f01000f1 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100c93:	c1 ea 0c             	shr    $0xc,%edx
f0100c96:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c9c:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f0100ca3:	89 c2                	mov    %eax,%edx
f0100ca5:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ca8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100cad:	85 d2                	test   %edx,%edx
f0100caf:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100cb4:	0f 44 c2             	cmove  %edx,%eax
}
f0100cb7:	c9                   	leave  
f0100cb8:	c3                   	ret    

f0100cb9 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100cb9:	55                   	push   %ebp
f0100cba:	89 e5                	mov    %esp,%ebp
f0100cbc:	53                   	push   %ebx
f0100cbd:	83 ec 14             	sub    $0x14,%esp
f0100cc0:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100cc2:	83 3d 34 85 11 f0 00 	cmpl   $0x0,0xf0118534
f0100cc9:	75 0f                	jne    f0100cda <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ccb:	b8 53 99 11 f0       	mov    $0xf0119953,%eax
f0100cd0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100cd5:	a3 34 85 11 f0       	mov    %eax,0xf0118534
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
f0100cda:	a1 34 85 11 f0       	mov    0xf0118534,%eax
f0100cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ce3:	c7 04 24 64 50 10 f0 	movl   $0xf0105064,(%esp)
f0100cea:	e8 d3 24 00 00       	call   f01031c2 <cprintf>
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
f0100cef:	89 d8                	mov    %ebx,%eax
f0100cf1:	03 05 34 85 11 f0    	add    0xf0118534,%eax
f0100cf7:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100cfc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d01:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d05:	c7 04 24 7d 50 10 f0 	movl   $0xf010507d,(%esp)
f0100d0c:	e8 b1 24 00 00       	call   f01031c2 <cprintf>
	if (n != 0) {
f0100d11:	85 db                	test   %ebx,%ebx
f0100d13:	74 1a                	je     f0100d2f <boot_alloc+0x76>
		char *next = nextfree;
f0100d15:	a1 34 85 11 f0       	mov    0xf0118534,%eax
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
f0100d1a:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100d21:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100d27:	89 15 34 85 11 f0    	mov    %edx,0xf0118534
		return next;
f0100d2d:	eb 05                	jmp    f0100d34 <boot_alloc+0x7b>
	} else return nextfree;
f0100d2f:	a1 34 85 11 f0       	mov    0xf0118534,%eax

	return NULL;
}
f0100d34:	83 c4 14             	add    $0x14,%esp
f0100d37:	5b                   	pop    %ebx
f0100d38:	5d                   	pop    %ebp
f0100d39:	c3                   	ret    

f0100d3a <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100d3a:	55                   	push   %ebp
f0100d3b:	89 e5                	mov    %esp,%ebp
f0100d3d:	83 ec 18             	sub    $0x18,%esp
f0100d40:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100d43:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100d46:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100d48:	89 04 24             	mov    %eax,(%esp)
f0100d4b:	e8 04 24 00 00       	call   f0103154 <mc146818_read>
f0100d50:	89 c6                	mov    %eax,%esi
f0100d52:	83 c3 01             	add    $0x1,%ebx
f0100d55:	89 1c 24             	mov    %ebx,(%esp)
f0100d58:	e8 f7 23 00 00       	call   f0103154 <mc146818_read>
f0100d5d:	c1 e0 08             	shl    $0x8,%eax
f0100d60:	09 f0                	or     %esi,%eax
}
f0100d62:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100d65:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100d68:	89 ec                	mov    %ebp,%esp
f0100d6a:	5d                   	pop    %ebp
f0100d6b:	c3                   	ret    

f0100d6c <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100d6c:	55                   	push   %ebp
f0100d6d:	89 e5                	mov    %esp,%ebp
f0100d6f:	57                   	push   %edi
f0100d70:	56                   	push   %esi
f0100d71:	53                   	push   %ebx
f0100d72:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d75:	3c 01                	cmp    $0x1,%al
f0100d77:	19 f6                	sbb    %esi,%esi
f0100d79:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100d7f:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d82:	8b 1d 2c 85 11 f0    	mov    0xf011852c,%ebx
f0100d88:	85 db                	test   %ebx,%ebx
f0100d8a:	75 1c                	jne    f0100da8 <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0100d8c:	c7 44 24 08 2c 49 10 	movl   $0xf010492c,0x8(%esp)
f0100d93:	f0 
f0100d94:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
f0100d9b:	00 
f0100d9c:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0100da3:	e8 49 f3 ff ff       	call   f01000f1 <_panic>

	if (only_low_memory) {
f0100da8:	84 c0                	test   %al,%al
f0100daa:	74 50                	je     f0100dfc <check_page_free_list+0x90>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100dac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100daf:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100db2:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100db5:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100db8:	89 d8                	mov    %ebx,%eax
f0100dba:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f0100dc0:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100dc3:	c1 e8 16             	shr    $0x16,%eax
f0100dc6:	39 c6                	cmp    %eax,%esi
f0100dc8:	0f 96 c0             	setbe  %al
f0100dcb:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100dce:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0100dd2:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100dd4:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dd8:	8b 1b                	mov    (%ebx),%ebx
f0100dda:	85 db                	test   %ebx,%ebx
f0100ddc:	75 da                	jne    f0100db8 <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100dde:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100de1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100de7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100dea:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ded:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100def:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100df2:	89 1d 2c 85 11 f0    	mov    %ebx,0xf011852c
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100df8:	85 db                	test   %ebx,%ebx
f0100dfa:	74 67                	je     f0100e63 <check_page_free_list+0xf7>
f0100dfc:	89 d8                	mov    %ebx,%eax
f0100dfe:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f0100e04:	c1 f8 03             	sar    $0x3,%eax
f0100e07:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100e0a:	89 c2                	mov    %eax,%edx
f0100e0c:	c1 ea 16             	shr    $0x16,%edx
f0100e0f:	39 d6                	cmp    %edx,%esi
f0100e11:	76 4a                	jbe    f0100e5d <check_page_free_list+0xf1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e13:	89 c2                	mov    %eax,%edx
f0100e15:	c1 ea 0c             	shr    $0xc,%edx
f0100e18:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0100e1e:	72 20                	jb     f0100e40 <check_page_free_list+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e20:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e24:	c7 44 24 08 08 49 10 	movl   $0xf0104908,0x8(%esp)
f0100e2b:	f0 
f0100e2c:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100e33:	00 
f0100e34:	c7 04 24 90 50 10 f0 	movl   $0xf0105090,(%esp)
f0100e3b:	e8 b1 f2 ff ff       	call   f01000f1 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100e40:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100e47:	00 
f0100e48:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100e4f:	00 
	return (void *)(pa + KERNBASE);
f0100e50:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e55:	89 04 24             	mov    %eax,(%esp)
f0100e58:	e8 44 2f 00 00       	call   f0103da1 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e5d:	8b 1b                	mov    (%ebx),%ebx
f0100e5f:	85 db                	test   %ebx,%ebx
f0100e61:	75 99                	jne    f0100dfc <check_page_free_list+0x90>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100e63:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e68:	e8 4c fe ff ff       	call   f0100cb9 <boot_alloc>
f0100e6d:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e70:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f0100e76:	85 d2                	test   %edx,%edx
f0100e78:	0f 84 f6 01 00 00    	je     f0101074 <check_page_free_list+0x308>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100e7e:	8b 1d 50 89 11 f0    	mov    0xf0118950,%ebx
f0100e84:	39 da                	cmp    %ebx,%edx
f0100e86:	72 4d                	jb     f0100ed5 <check_page_free_list+0x169>
		assert(pp < pages + npages);
f0100e88:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f0100e8d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100e90:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0100e93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100e96:	39 c2                	cmp    %eax,%edx
f0100e98:	73 64                	jae    f0100efe <check_page_free_list+0x192>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e9a:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100e9d:	89 d0                	mov    %edx,%eax
f0100e9f:	29 d8                	sub    %ebx,%eax
f0100ea1:	a8 07                	test   $0x7,%al
f0100ea3:	0f 85 82 00 00 00    	jne    f0100f2b <check_page_free_list+0x1bf>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ea9:	c1 f8 03             	sar    $0x3,%eax
f0100eac:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100eaf:	85 c0                	test   %eax,%eax
f0100eb1:	0f 84 a2 00 00 00    	je     f0100f59 <check_page_free_list+0x1ed>
		assert(page2pa(pp) != IOPHYSMEM);
f0100eb7:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ebc:	0f 84 c2 00 00 00    	je     f0100f84 <check_page_free_list+0x218>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ec2:	be 00 00 00 00       	mov    $0x0,%esi
f0100ec7:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ecc:	e9 d7 00 00 00       	jmp    f0100fa8 <check_page_free_list+0x23c>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ed1:	39 da                	cmp    %ebx,%edx
f0100ed3:	73 24                	jae    f0100ef9 <check_page_free_list+0x18d>
f0100ed5:	c7 44 24 0c 9e 50 10 	movl   $0xf010509e,0xc(%esp)
f0100edc:	f0 
f0100edd:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0100ee4:	f0 
f0100ee5:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
f0100eec:	00 
f0100eed:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0100ef4:	e8 f8 f1 ff ff       	call   f01000f1 <_panic>
		assert(pp < pages + npages);
f0100ef9:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100efc:	72 24                	jb     f0100f22 <check_page_free_list+0x1b6>
f0100efe:	c7 44 24 0c bf 50 10 	movl   $0xf01050bf,0xc(%esp)
f0100f05:	f0 
f0100f06:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0100f0d:	f0 
f0100f0e:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
f0100f15:	00 
f0100f16:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0100f1d:	e8 cf f1 ff ff       	call   f01000f1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f22:	89 d0                	mov    %edx,%eax
f0100f24:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100f27:	a8 07                	test   $0x7,%al
f0100f29:	74 24                	je     f0100f4f <check_page_free_list+0x1e3>
f0100f2b:	c7 44 24 0c 50 49 10 	movl   $0xf0104950,0xc(%esp)
f0100f32:	f0 
f0100f33:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0100f3a:	f0 
f0100f3b:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
f0100f42:	00 
f0100f43:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0100f4a:	e8 a2 f1 ff ff       	call   f01000f1 <_panic>
f0100f4f:	c1 f8 03             	sar    $0x3,%eax
f0100f52:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100f55:	85 c0                	test   %eax,%eax
f0100f57:	75 24                	jne    f0100f7d <check_page_free_list+0x211>
f0100f59:	c7 44 24 0c d3 50 10 	movl   $0xf01050d3,0xc(%esp)
f0100f60:	f0 
f0100f61:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0100f68:	f0 
f0100f69:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
f0100f70:	00 
f0100f71:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0100f78:	e8 74 f1 ff ff       	call   f01000f1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100f7d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100f82:	75 24                	jne    f0100fa8 <check_page_free_list+0x23c>
f0100f84:	c7 44 24 0c e4 50 10 	movl   $0xf01050e4,0xc(%esp)
f0100f8b:	f0 
f0100f8c:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0100f93:	f0 
f0100f94:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
f0100f9b:	00 
f0100f9c:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0100fa3:	e8 49 f1 ff ff       	call   f01000f1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100fa8:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100fad:	75 24                	jne    f0100fd3 <check_page_free_list+0x267>
f0100faf:	c7 44 24 0c 84 49 10 	movl   $0xf0104984,0xc(%esp)
f0100fb6:	f0 
f0100fb7:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0100fbe:	f0 
f0100fbf:	c7 44 24 04 36 02 00 	movl   $0x236,0x4(%esp)
f0100fc6:	00 
f0100fc7:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0100fce:	e8 1e f1 ff ff       	call   f01000f1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100fd3:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100fd8:	75 24                	jne    f0100ffe <check_page_free_list+0x292>
f0100fda:	c7 44 24 0c fd 50 10 	movl   $0xf01050fd,0xc(%esp)
f0100fe1:	f0 
f0100fe2:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0100fe9:	f0 
f0100fea:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
f0100ff1:	00 
f0100ff2:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0100ff9:	e8 f3 f0 ff ff       	call   f01000f1 <_panic>
f0100ffe:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101000:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101005:	76 57                	jbe    f010105e <check_page_free_list+0x2f2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101007:	c1 e8 0c             	shr    $0xc,%eax
f010100a:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010100d:	77 20                	ja     f010102f <check_page_free_list+0x2c3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010100f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101013:	c7 44 24 08 08 49 10 	movl   $0xf0104908,0x8(%esp)
f010101a:	f0 
f010101b:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101022:	00 
f0101023:	c7 04 24 90 50 10 f0 	movl   $0xf0105090,(%esp)
f010102a:	e8 c2 f0 ff ff       	call   f01000f1 <_panic>
	return (void *)(pa + KERNBASE);
f010102f:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101035:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0101038:	76 29                	jbe    f0101063 <check_page_free_list+0x2f7>
f010103a:	c7 44 24 0c a8 49 10 	movl   $0xf01049a8,0xc(%esp)
f0101041:	f0 
f0101042:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101049:	f0 
f010104a:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
f0101051:	00 
f0101052:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101059:	e8 93 f0 ff ff       	call   f01000f1 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f010105e:	83 c7 01             	add    $0x1,%edi
f0101061:	eb 03                	jmp    f0101066 <check_page_free_list+0x2fa>
		else
			++nfree_extmem;
f0101063:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101066:	8b 12                	mov    (%edx),%edx
f0101068:	85 d2                	test   %edx,%edx
f010106a:	0f 85 61 fe ff ff    	jne    f0100ed1 <check_page_free_list+0x165>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101070:	85 ff                	test   %edi,%edi
f0101072:	7f 24                	jg     f0101098 <check_page_free_list+0x32c>
f0101074:	c7 44 24 0c 17 51 10 	movl   $0xf0105117,0xc(%esp)
f010107b:	f0 
f010107c:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101083:	f0 
f0101084:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
f010108b:	00 
f010108c:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101093:	e8 59 f0 ff ff       	call   f01000f1 <_panic>
	assert(nfree_extmem > 0);
f0101098:	85 f6                	test   %esi,%esi
f010109a:	7f 24                	jg     f01010c0 <check_page_free_list+0x354>
f010109c:	c7 44 24 0c 29 51 10 	movl   $0xf0105129,0xc(%esp)
f01010a3:	f0 
f01010a4:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01010ab:	f0 
f01010ac:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
f01010b3:	00 
f01010b4:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01010bb:	e8 31 f0 ff ff       	call   f01000f1 <_panic>
	cprintf("check_page_free_list done\n");
f01010c0:	c7 04 24 3a 51 10 f0 	movl   $0xf010513a,(%esp)
f01010c7:	e8 f6 20 00 00       	call   f01031c2 <cprintf>
}
f01010cc:	83 c4 3c             	add    $0x3c,%esp
f01010cf:	5b                   	pop    %ebx
f01010d0:	5e                   	pop    %esi
f01010d1:	5f                   	pop    %edi
f01010d2:	5d                   	pop    %ebp
f01010d3:	c3                   	ret    

f01010d4 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01010d4:	55                   	push   %ebp
f01010d5:	89 e5                	mov    %esp,%ebp
f01010d7:	56                   	push   %esi
f01010d8:	53                   	push   %ebx
f01010d9:	83 ec 10             	sub    $0x10,%esp
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f01010dc:	8b 35 30 85 11 f0    	mov    0xf0118530,%esi
f01010e2:	83 fe 01             	cmp    $0x1,%esi
f01010e5:	76 37                	jbe    f010111e <page_init+0x4a>
f01010e7:	8b 1d 2c 85 11 f0    	mov    0xf011852c,%ebx
f01010ed:	b8 01 00 00 00       	mov    $0x1,%eax
f01010f2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f01010f9:	89 d1                	mov    %edx,%ecx
f01010fb:	03 0d 50 89 11 f0    	add    0xf0118950,%ecx
f0101101:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101107:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0101109:	89 d3                	mov    %edx,%ebx
f010110b:	03 1d 50 89 11 f0    	add    0xf0118950,%ebx
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0101111:	83 c0 01             	add    $0x1,%eax
f0101114:	39 c6                	cmp    %eax,%esi
f0101116:	77 da                	ja     f01010f2 <page_init+0x1e>
f0101118:	89 1d 2c 85 11 f0    	mov    %ebx,0xf011852c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	int med = (int)ROUNDUP(((char*)pages) + (sizeof(struct PageInfo) * npages) - 0xf0000000, PGSIZE)/PGSIZE;
f010111e:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f0101123:	8d 04 c5 00 00 00 10 	lea    0x10000000(,%eax,8),%eax
f010112a:	03 05 50 89 11 f0    	add    0xf0118950,%eax
f0101130:	05 ff 0f 00 00       	add    $0xfff,%eax
f0101135:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010113a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101140:	85 c0                	test   %eax,%eax
f0101142:	0f 49 d8             	cmovns %eax,%ebx
f0101145:	c1 fb 0c             	sar    $0xc,%ebx
	cprintf("pageinfo size: %d\n", sizeof(struct PageInfo));
f0101148:	c7 44 24 04 08 00 00 	movl   $0x8,0x4(%esp)
f010114f:	00 
f0101150:	c7 04 24 55 51 10 f0 	movl   $0xf0105155,(%esp)
f0101157:	e8 66 20 00 00       	call   f01031c2 <cprintf>
	cprintf("%x\n", ((char*)pages) + (sizeof(struct PageInfo) * npages));
f010115c:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f0101161:	c1 e0 03             	shl    $0x3,%eax
f0101164:	03 05 50 89 11 f0    	add    0xf0118950,%eax
f010116a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010116e:	c7 04 24 d5 53 10 f0 	movl   $0xf01053d5,(%esp)
f0101175:	e8 48 20 00 00       	call   f01031c2 <cprintf>
	cprintf("med=%d\n", med);
f010117a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010117e:	c7 04 24 68 51 10 f0 	movl   $0xf0105168,(%esp)
f0101185:	e8 38 20 00 00       	call   f01031c2 <cprintf>
	for (i = med; i < npages; i++) {
f010118a:	89 d8                	mov    %ebx,%eax
f010118c:	3b 1d 48 89 11 f0    	cmp    0xf0118948,%ebx
f0101192:	73 35                	jae    f01011c9 <page_init+0xf5>
f0101194:	8b 0d 2c 85 11 f0    	mov    0xf011852c,%ecx
f010119a:	c1 e3 03             	shl    $0x3,%ebx
		pages[i].pp_ref = 0;
f010119d:	89 da                	mov    %ebx,%edx
f010119f:	03 15 50 89 11 f0    	add    0xf0118950,%edx
f01011a5:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f01011ab:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f01011ad:	89 d9                	mov    %ebx,%ecx
f01011af:	03 0d 50 89 11 f0    	add    0xf0118950,%ecx
	}
	int med = (int)ROUNDUP(((char*)pages) + (sizeof(struct PageInfo) * npages) - 0xf0000000, PGSIZE)/PGSIZE;
	cprintf("pageinfo size: %d\n", sizeof(struct PageInfo));
	cprintf("%x\n", ((char*)pages) + (sizeof(struct PageInfo) * npages));
	cprintf("med=%d\n", med);
	for (i = med; i < npages; i++) {
f01011b5:	83 c0 01             	add    $0x1,%eax
f01011b8:	83 c3 08             	add    $0x8,%ebx
f01011bb:	39 05 48 89 11 f0    	cmp    %eax,0xf0118948
f01011c1:	77 da                	ja     f010119d <page_init+0xc9>
f01011c3:	89 0d 2c 85 11 f0    	mov    %ecx,0xf011852c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f01011c9:	83 c4 10             	add    $0x10,%esp
f01011cc:	5b                   	pop    %ebx
f01011cd:	5e                   	pop    %esi
f01011ce:	5d                   	pop    %ebp
f01011cf:	c3                   	ret    

f01011d0 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01011d0:	55                   	push   %ebp
f01011d1:	89 e5                	mov    %esp,%ebp
f01011d3:	53                   	push   %ebx
f01011d4:	83 ec 14             	sub    $0x14,%esp
	if (page_free_list) {
f01011d7:	8b 1d 2c 85 11 f0    	mov    0xf011852c,%ebx
f01011dd:	85 db                	test   %ebx,%ebx
f01011df:	74 65                	je     f0101246 <page_alloc+0x76>
		struct PageInfo *ret = page_free_list;
		page_free_list = page_free_list->pp_link;
f01011e1:	8b 03                	mov    (%ebx),%eax
f01011e3:	a3 2c 85 11 f0       	mov    %eax,0xf011852c
		if (alloc_flags & ALLOC_ZERO) 
f01011e8:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01011ec:	74 58                	je     f0101246 <page_alloc+0x76>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011ee:	89 d8                	mov    %ebx,%eax
f01011f0:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f01011f6:	c1 f8 03             	sar    $0x3,%eax
f01011f9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011fc:	89 c2                	mov    %eax,%edx
f01011fe:	c1 ea 0c             	shr    $0xc,%edx
f0101201:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0101207:	72 20                	jb     f0101229 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101209:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010120d:	c7 44 24 08 08 49 10 	movl   $0xf0104908,0x8(%esp)
f0101214:	f0 
f0101215:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010121c:	00 
f010121d:	c7 04 24 90 50 10 f0 	movl   $0xf0105090,(%esp)
f0101224:	e8 c8 ee ff ff       	call   f01000f1 <_panic>
			memset(page2kva(ret), 0, PGSIZE);
f0101229:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101230:	00 
f0101231:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101238:	00 
	return (void *)(pa + KERNBASE);
f0101239:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010123e:	89 04 24             	mov    %eax,(%esp)
f0101241:	e8 5b 2b 00 00       	call   f0103da1 <memset>
		return ret;
	}
	return NULL;
}
f0101246:	89 d8                	mov    %ebx,%eax
f0101248:	83 c4 14             	add    $0x14,%esp
f010124b:	5b                   	pop    %ebx
f010124c:	5d                   	pop    %ebp
f010124d:	c3                   	ret    

f010124e <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010124e:	55                   	push   %ebp
f010124f:	89 e5                	mov    %esp,%ebp
f0101251:	8b 45 08             	mov    0x8(%ebp),%eax
	pp->pp_link = page_free_list;
f0101254:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f010125a:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010125c:	a3 2c 85 11 f0       	mov    %eax,0xf011852c
}
f0101261:	5d                   	pop    %ebp
f0101262:	c3                   	ret    

f0101263 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101263:	55                   	push   %ebp
f0101264:	89 e5                	mov    %esp,%ebp
f0101266:	83 ec 04             	sub    $0x4,%esp
f0101269:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010126c:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0101270:	83 ea 01             	sub    $0x1,%edx
f0101273:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101277:	66 85 d2             	test   %dx,%dx
f010127a:	75 08                	jne    f0101284 <page_decref+0x21>
		page_free(pp);
f010127c:	89 04 24             	mov    %eax,(%esp)
f010127f:	e8 ca ff ff ff       	call   f010124e <page_free>
}
f0101284:	c9                   	leave  
f0101285:	c3                   	ret    

f0101286 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101286:	55                   	push   %ebp
f0101287:	89 e5                	mov    %esp,%ebp
f0101289:	83 ec 18             	sub    $0x18,%esp
f010128c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010128f:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101292:	8b 75 0c             	mov    0xc(%ebp),%esi
	int dindex = PDX(va), tindex = PTX(va);
f0101295:	89 f3                	mov    %esi,%ebx
f0101297:	c1 eb 16             	shr    $0x16,%ebx
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
f010129a:	c1 e3 02             	shl    $0x2,%ebx
f010129d:	03 5d 08             	add    0x8(%ebp),%ebx
f01012a0:	f6 03 01             	testb  $0x1,(%ebx)
f01012a3:	75 31                	jne    f01012d6 <pgdir_walk+0x50>
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
			pg->pp_ref++;
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
		} else return NULL;
f01012a5:	b8 00 00 00 00       	mov    $0x0,%eax
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
f01012aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01012ae:	74 71                	je     f0101321 <pgdir_walk+0x9b>
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
f01012b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01012b7:	e8 14 ff ff ff       	call   f01011d0 <page_alloc>
			if (!pg) return NULL;	//allocation fails
f01012bc:	85 c0                	test   %eax,%eax
f01012be:	74 5c                	je     f010131c <pgdir_walk+0x96>
			pg->pp_ref++;
f01012c0:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012c5:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f01012cb:	c1 f8 03             	sar    $0x3,%eax
f01012ce:	c1 e0 0c             	shl    $0xc,%eax
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
f01012d1:	83 c8 07             	or     $0x7,%eax
f01012d4:	89 03                	mov    %eax,(%ebx)
		} else return NULL;
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));
f01012d6:	8b 03                	mov    (%ebx),%eax
f01012d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012dd:	89 c2                	mov    %eax,%edx
f01012df:	c1 ea 0c             	shr    $0xc,%edx
f01012e2:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f01012e8:	72 20                	jb     f010130a <pgdir_walk+0x84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012ee:	c7 44 24 08 08 49 10 	movl   $0xf0104908,0x8(%esp)
f01012f5:	f0 
f01012f6:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
f01012fd:	00 
f01012fe:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101305:	e8 e7 ed ff ff       	call   f01000f1 <_panic>
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	int dindex = PDX(va), tindex = PTX(va);
f010130a:	c1 ee 0a             	shr    $0xa,%esi
	// 		struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
f010130d:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101313:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f010131a:	eb 05                	jmp    f0101321 <pgdir_walk+0x9b>
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
f010131c:	b8 00 00 00 00       	mov    $0x0,%eax
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
}
f0101321:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101324:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101327:	89 ec                	mov    %ebp,%esp
f0101329:	5d                   	pop    %ebp
f010132a:	c3                   	ret    

f010132b <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010132b:	55                   	push   %ebp
f010132c:	89 e5                	mov    %esp,%ebp
f010132e:	57                   	push   %edi
f010132f:	56                   	push   %esi
f0101330:	53                   	push   %ebx
f0101331:	83 ec 2c             	sub    $0x2c,%esp
f0101334:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101337:	89 d3                	mov    %edx,%ebx
f0101339:	89 cf                	mov    %ecx,%edi
f010133b:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
f010133e:	89 74 24 08          	mov    %esi,0x8(%esp)
f0101342:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101346:	c7 04 24 f0 49 10 f0 	movl   $0xf01049f0,(%esp)
f010134d:	e8 70 1e 00 00       	call   f01031c2 <cprintf>
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101352:	c1 ef 0c             	shr    $0xc,%edi
f0101355:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0101358:	85 ff                	test   %edi,%edi
f010135a:	74 60                	je     f01013bc <boot_map_region+0x91>
f010135c:	bf 00 00 00 00       	mov    $0x0,%edi
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
f0101361:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101364:	83 c8 01             	or     $0x1,%eax
f0101367:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f010136a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101371:	00 
f0101372:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101376:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101379:	89 04 24             	mov    %eax,(%esp)
f010137c:	e8 05 ff ff ff       	call   f0101286 <pgdir_walk>
		if (!pte) panic("boot_map_region panic, out of memory");
f0101381:	85 c0                	test   %eax,%eax
f0101383:	75 1c                	jne    f01013a1 <boot_map_region+0x76>
f0101385:	c7 44 24 08 54 48 10 	movl   $0xf0104854,0x8(%esp)
f010138c:	f0 
f010138d:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f0101394:	00 
f0101395:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010139c:	e8 50 ed ff ff       	call   f01000f1 <_panic>
		*pte = pa | perm | PTE_P;
f01013a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01013a4:	09 f2                	or     %esi,%edx
f01013a6:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01013a8:	83 c7 01             	add    $0x1,%edi
f01013ab:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01013b1:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01013b7:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f01013ba:	72 ae                	jb     f010136a <boot_map_region+0x3f>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
	}
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
f01013bc:	89 74 24 08          	mov    %esi,0x8(%esp)
f01013c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01013c4:	c7 04 24 f0 49 10 f0 	movl   $0xf01049f0,(%esp)
f01013cb:	e8 f2 1d 00 00       	call   f01031c2 <cprintf>
}
f01013d0:	83 c4 2c             	add    $0x2c,%esp
f01013d3:	5b                   	pop    %ebx
f01013d4:	5e                   	pop    %esi
f01013d5:	5f                   	pop    %edi
f01013d6:	5d                   	pop    %ebp
f01013d7:	c3                   	ret    

f01013d8 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01013d8:	55                   	push   %ebp
f01013d9:	89 e5                	mov    %esp,%ebp
f01013db:	53                   	push   %ebx
f01013dc:	83 ec 14             	sub    $0x14,%esp
f01013df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
f01013e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01013e9:	00 
f01013ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01013f4:	89 04 24             	mov    %eax,(%esp)
f01013f7:	e8 8a fe ff ff       	call   f0101286 <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f01013fc:	ba 00 00 00 00       	mov    $0x0,%edx
f0101401:	85 c0                	test   %eax,%eax
f0101403:	74 44                	je     f0101449 <page_lookup+0x71>
f0101405:	f6 00 01             	testb  $0x1,(%eax)
f0101408:	74 3a                	je     f0101444 <page_lookup+0x6c>
	if (pte_store)
f010140a:	85 db                	test   %ebx,%ebx
f010140c:	74 02                	je     f0101410 <page_lookup+0x38>
		*pte_store = pte;	//found and set
f010140e:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*pte));		
f0101410:	8b 10                	mov    (%eax),%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101412:	c1 ea 0c             	shr    $0xc,%edx
f0101415:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f010141b:	72 1c                	jb     f0101439 <page_lookup+0x61>
		panic("pa2page called with invalid pa");
f010141d:	c7 44 24 08 24 4a 10 	movl   $0xf0104a24,0x8(%esp)
f0101424:	f0 
f0101425:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f010142c:	00 
f010142d:	c7 04 24 90 50 10 f0 	movl   $0xf0105090,(%esp)
f0101434:	e8 b8 ec ff ff       	call   f01000f1 <_panic>
	return &pages[PGNUM(pa)];
f0101439:	c1 e2 03             	shl    $0x3,%edx
f010143c:	03 15 50 89 11 f0    	add    0xf0118950,%edx
f0101442:	eb 05                	jmp    f0101449 <page_lookup+0x71>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f0101444:	ba 00 00 00 00       	mov    $0x0,%edx
	if (pte_store)
		*pte_store = pte;	//found and set
	return pa2page(PTE_ADDR(*pte));		
}
f0101449:	89 d0                	mov    %edx,%eax
f010144b:	83 c4 14             	add    $0x14,%esp
f010144e:	5b                   	pop    %ebx
f010144f:	5d                   	pop    %ebp
f0101450:	c3                   	ret    

f0101451 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101451:	55                   	push   %ebp
f0101452:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101454:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101457:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010145a:	5d                   	pop    %ebp
f010145b:	c3                   	ret    

f010145c <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010145c:	55                   	push   %ebp
f010145d:	89 e5                	mov    %esp,%ebp
f010145f:	83 ec 28             	sub    $0x28,%esp
f0101462:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101465:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101468:	8b 75 08             	mov    0x8(%ebp),%esi
f010146b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte;
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f010146e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101471:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101475:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101479:	89 34 24             	mov    %esi,(%esp)
f010147c:	e8 57 ff ff ff       	call   f01013d8 <page_lookup>
	if (!pg || !(*pte & PTE_P)) return;	//page not exist
f0101481:	85 c0                	test   %eax,%eax
f0101483:	74 25                	je     f01014aa <page_remove+0x4e>
f0101485:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101488:	f6 02 01             	testb  $0x1,(%edx)
f010148b:	74 1d                	je     f01014aa <page_remove+0x4e>
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
	page_decref(pg);
f010148d:	89 04 24             	mov    %eax,(%esp)
f0101490:	e8 ce fd ff ff       	call   f0101263 <page_decref>
//   - The pg table entry corresponding to 'va' should be set to 0.
	*pte = 0;
f0101495:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101498:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
//   - The TLB must be invalidated if you remove an entry from
//     the page table.
	tlb_invalidate(pgdir, va);
f010149e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01014a2:	89 34 24             	mov    %esi,(%esp)
f01014a5:	e8 a7 ff ff ff       	call   f0101451 <tlb_invalidate>
}
f01014aa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01014ad:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01014b0:	89 ec                	mov    %ebp,%esp
f01014b2:	5d                   	pop    %ebp
f01014b3:	c3                   	ret    

f01014b4 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01014b4:	55                   	push   %ebp
f01014b5:	89 e5                	mov    %esp,%ebp
f01014b7:	83 ec 28             	sub    $0x28,%esp
f01014ba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01014bd:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01014c0:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01014c3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014c6:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
f01014c9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01014d0:	00 
f01014d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01014d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01014d8:	89 04 24             	mov    %eax,(%esp)
f01014db:	e8 a6 fd ff ff       	call   f0101286 <pgdir_walk>
f01014e0:	89 c3                	mov    %eax,%ebx
	if (!pte) 	//page table not allocated
		return -E_NO_MEM;	
f01014e2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
	if (!pte) 	//page table not allocated
f01014e7:	85 db                	test   %ebx,%ebx
f01014e9:	74 38                	je     f0101523 <page_insert+0x6f>
		return -E_NO_MEM;	
	//increase ref count to avoid the corner case that pp is freed before it is inserted.
	pp->pp_ref++;	
f01014eb:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
f01014f0:	f6 03 01             	testb  $0x1,(%ebx)
f01014f3:	74 0f                	je     f0101504 <page_insert+0x50>
		page_remove(pgdir, va);
f01014f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01014f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01014fc:	89 04 24             	mov    %eax,(%esp)
f01014ff:	e8 58 ff ff ff       	call   f010145c <page_remove>
	*pte = page2pa(pp) | perm | PTE_P;
f0101504:	8b 55 14             	mov    0x14(%ebp),%edx
f0101507:	83 ca 01             	or     $0x1,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010150a:	2b 35 50 89 11 f0    	sub    0xf0118950,%esi
f0101510:	c1 fe 03             	sar    $0x3,%esi
f0101513:	89 f0                	mov    %esi,%eax
f0101515:	c1 e0 0c             	shl    $0xc,%eax
f0101518:	89 d6                	mov    %edx,%esi
f010151a:	09 c6                	or     %eax,%esi
f010151c:	89 33                	mov    %esi,(%ebx)
	return 0;
f010151e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101523:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101526:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101529:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010152c:	89 ec                	mov    %ebp,%esp
f010152e:	5d                   	pop    %ebp
f010152f:	c3                   	ret    

f0101530 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101530:	55                   	push   %ebp
f0101531:	89 e5                	mov    %esp,%ebp
f0101533:	57                   	push   %edi
f0101534:	56                   	push   %esi
f0101535:	53                   	push   %ebx
f0101536:	83 ec 4c             	sub    $0x4c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101539:	b8 15 00 00 00       	mov    $0x15,%eax
f010153e:	e8 f7 f7 ff ff       	call   f0100d3a <nvram_read>
f0101543:	c1 e0 0a             	shl    $0xa,%eax
f0101546:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010154c:	85 c0                	test   %eax,%eax
f010154e:	0f 48 c2             	cmovs  %edx,%eax
f0101551:	c1 f8 0c             	sar    $0xc,%eax
f0101554:	a3 30 85 11 f0       	mov    %eax,0xf0118530
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101559:	b8 17 00 00 00       	mov    $0x17,%eax
f010155e:	e8 d7 f7 ff ff       	call   f0100d3a <nvram_read>
f0101563:	c1 e0 0a             	shl    $0xa,%eax
f0101566:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010156c:	85 c0                	test   %eax,%eax
f010156e:	0f 48 c2             	cmovs  %edx,%eax
f0101571:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101574:	85 c0                	test   %eax,%eax
f0101576:	74 0e                	je     f0101586 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101578:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010157e:	89 15 48 89 11 f0    	mov    %edx,0xf0118948
f0101584:	eb 0c                	jmp    f0101592 <mem_init+0x62>
	else
		npages = npages_basemem;
f0101586:	8b 15 30 85 11 f0    	mov    0xf0118530,%edx
f010158c:	89 15 48 89 11 f0    	mov    %edx,0xf0118948

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101592:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101595:	c1 e8 0a             	shr    $0xa,%eax
f0101598:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f010159c:	a1 30 85 11 f0       	mov    0xf0118530,%eax
f01015a1:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015a4:	c1 e8 0a             	shr    $0xa,%eax
f01015a7:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01015ab:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f01015b0:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015b3:	c1 e8 0a             	shr    $0xa,%eax
f01015b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015ba:	c7 04 24 44 4a 10 f0 	movl   $0xf0104a44,(%esp)
f01015c1:	e8 fc 1b 00 00       	call   f01031c2 <cprintf>
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01015c6:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015cb:	e8 e9 f6 ff ff       	call   f0100cb9 <boot_alloc>
f01015d0:	a3 4c 89 11 f0       	mov    %eax,0xf011894c
	memset(kern_pgdir, 0, PGSIZE);
f01015d5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01015dc:	00 
f01015dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01015e4:	00 
f01015e5:	89 04 24             	mov    %eax,(%esp)
f01015e8:	e8 b4 27 00 00       	call   f0103da1 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01015ed:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01015f2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01015f7:	77 20                	ja     f0101619 <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01015f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015fd:	c7 44 24 08 80 4a 10 	movl   $0xf0104a80,0x8(%esp)
f0101604:	f0 
f0101605:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
f010160c:	00 
f010160d:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101614:	e8 d8 ea ff ff       	call   f01000f1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101619:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010161f:	83 ca 05             	or     $0x5,%edx
f0101622:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f0101628:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f010162d:	c1 e0 03             	shl    $0x3,%eax
f0101630:	e8 84 f6 ff ff       	call   f0100cb9 <boot_alloc>
f0101635:	a3 50 89 11 f0       	mov    %eax,0xf0118950

	cprintf("npages: %d\n", npages);
f010163a:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f010163f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101643:	c7 04 24 70 51 10 f0 	movl   $0xf0105170,(%esp)
f010164a:	e8 73 1b 00 00       	call   f01031c2 <cprintf>
	cprintf("npages_basemem: %d\n", npages_basemem);
f010164f:	a1 30 85 11 f0       	mov    0xf0118530,%eax
f0101654:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101658:	c7 04 24 7c 51 10 f0 	movl   $0xf010517c,(%esp)
f010165f:	e8 5e 1b 00 00       	call   f01031c2 <cprintf>
	cprintf("pages: %x\n", pages);
f0101664:	a1 50 89 11 f0       	mov    0xf0118950,%eax
f0101669:	89 44 24 04          	mov    %eax,0x4(%esp)
f010166d:	c7 04 24 90 51 10 f0 	movl   $0xf0105190,(%esp)
f0101674:	e8 49 1b 00 00       	call   f01031c2 <cprintf>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101679:	e8 56 fa ff ff       	call   f01010d4 <page_init>

	check_page_free_list(1);
f010167e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101683:	e8 e4 f6 ff ff       	call   f0100d6c <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101688:	83 3d 50 89 11 f0 00 	cmpl   $0x0,0xf0118950
f010168f:	75 1c                	jne    f01016ad <mem_init+0x17d>
		panic("'pages' is a null pointer!");
f0101691:	c7 44 24 08 9b 51 10 	movl   $0xf010519b,0x8(%esp)
f0101698:	f0 
f0101699:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
f01016a0:	00 
f01016a1:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01016a8:	e8 44 ea ff ff       	call   f01000f1 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016ad:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f01016b2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01016b7:	85 c0                	test   %eax,%eax
f01016b9:	74 09                	je     f01016c4 <mem_init+0x194>
		++nfree;
f01016bb:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016be:	8b 00                	mov    (%eax),%eax
f01016c0:	85 c0                	test   %eax,%eax
f01016c2:	75 f7                	jne    f01016bb <mem_init+0x18b>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016cb:	e8 00 fb ff ff       	call   f01011d0 <page_alloc>
f01016d0:	89 c6                	mov    %eax,%esi
f01016d2:	85 c0                	test   %eax,%eax
f01016d4:	75 24                	jne    f01016fa <mem_init+0x1ca>
f01016d6:	c7 44 24 0c b6 51 10 	movl   $0xf01051b6,0xc(%esp)
f01016dd:	f0 
f01016de:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01016e5:	f0 
f01016e6:	c7 44 24 04 5b 02 00 	movl   $0x25b,0x4(%esp)
f01016ed:	00 
f01016ee:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01016f5:	e8 f7 e9 ff ff       	call   f01000f1 <_panic>
	assert((pp1 = page_alloc(0)));
f01016fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101701:	e8 ca fa ff ff       	call   f01011d0 <page_alloc>
f0101706:	89 c7                	mov    %eax,%edi
f0101708:	85 c0                	test   %eax,%eax
f010170a:	75 24                	jne    f0101730 <mem_init+0x200>
f010170c:	c7 44 24 0c cc 51 10 	movl   $0xf01051cc,0xc(%esp)
f0101713:	f0 
f0101714:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010171b:	f0 
f010171c:	c7 44 24 04 5c 02 00 	movl   $0x25c,0x4(%esp)
f0101723:	00 
f0101724:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010172b:	e8 c1 e9 ff ff       	call   f01000f1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101730:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101737:	e8 94 fa ff ff       	call   f01011d0 <page_alloc>
f010173c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010173f:	85 c0                	test   %eax,%eax
f0101741:	75 24                	jne    f0101767 <mem_init+0x237>
f0101743:	c7 44 24 0c e2 51 10 	movl   $0xf01051e2,0xc(%esp)
f010174a:	f0 
f010174b:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101752:	f0 
f0101753:	c7 44 24 04 5d 02 00 	movl   $0x25d,0x4(%esp)
f010175a:	00 
f010175b:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101762:	e8 8a e9 ff ff       	call   f01000f1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101767:	39 fe                	cmp    %edi,%esi
f0101769:	75 24                	jne    f010178f <mem_init+0x25f>
f010176b:	c7 44 24 0c f8 51 10 	movl   $0xf01051f8,0xc(%esp)
f0101772:	f0 
f0101773:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010177a:	f0 
f010177b:	c7 44 24 04 60 02 00 	movl   $0x260,0x4(%esp)
f0101782:	00 
f0101783:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010178a:	e8 62 e9 ff ff       	call   f01000f1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010178f:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101792:	74 05                	je     f0101799 <mem_init+0x269>
f0101794:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101797:	75 24                	jne    f01017bd <mem_init+0x28d>
f0101799:	c7 44 24 0c a4 4a 10 	movl   $0xf0104aa4,0xc(%esp)
f01017a0:	f0 
f01017a1:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01017a8:	f0 
f01017a9:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
f01017b0:	00 
f01017b1:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01017b8:	e8 34 e9 ff ff       	call   f01000f1 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017bd:	8b 15 50 89 11 f0    	mov    0xf0118950,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01017c3:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f01017c8:	c1 e0 0c             	shl    $0xc,%eax
f01017cb:	89 f1                	mov    %esi,%ecx
f01017cd:	29 d1                	sub    %edx,%ecx
f01017cf:	c1 f9 03             	sar    $0x3,%ecx
f01017d2:	c1 e1 0c             	shl    $0xc,%ecx
f01017d5:	39 c1                	cmp    %eax,%ecx
f01017d7:	72 24                	jb     f01017fd <mem_init+0x2cd>
f01017d9:	c7 44 24 0c 0a 52 10 	movl   $0xf010520a,0xc(%esp)
f01017e0:	f0 
f01017e1:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01017e8:	f0 
f01017e9:	c7 44 24 04 62 02 00 	movl   $0x262,0x4(%esp)
f01017f0:	00 
f01017f1:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01017f8:	e8 f4 e8 ff ff       	call   f01000f1 <_panic>
f01017fd:	89 f9                	mov    %edi,%ecx
f01017ff:	29 d1                	sub    %edx,%ecx
f0101801:	c1 f9 03             	sar    $0x3,%ecx
f0101804:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101807:	39 c8                	cmp    %ecx,%eax
f0101809:	77 24                	ja     f010182f <mem_init+0x2ff>
f010180b:	c7 44 24 0c 27 52 10 	movl   $0xf0105227,0xc(%esp)
f0101812:	f0 
f0101813:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010181a:	f0 
f010181b:	c7 44 24 04 63 02 00 	movl   $0x263,0x4(%esp)
f0101822:	00 
f0101823:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010182a:	e8 c2 e8 ff ff       	call   f01000f1 <_panic>
f010182f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101832:	29 d1                	sub    %edx,%ecx
f0101834:	89 ca                	mov    %ecx,%edx
f0101836:	c1 fa 03             	sar    $0x3,%edx
f0101839:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010183c:	39 d0                	cmp    %edx,%eax
f010183e:	77 24                	ja     f0101864 <mem_init+0x334>
f0101840:	c7 44 24 0c 44 52 10 	movl   $0xf0105244,0xc(%esp)
f0101847:	f0 
f0101848:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010184f:	f0 
f0101850:	c7 44 24 04 64 02 00 	movl   $0x264,0x4(%esp)
f0101857:	00 
f0101858:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010185f:	e8 8d e8 ff ff       	call   f01000f1 <_panic>


	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101864:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f0101869:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010186c:	c7 05 2c 85 11 f0 00 	movl   $0x0,0xf011852c
f0101873:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101876:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010187d:	e8 4e f9 ff ff       	call   f01011d0 <page_alloc>
f0101882:	85 c0                	test   %eax,%eax
f0101884:	74 24                	je     f01018aa <mem_init+0x37a>
f0101886:	c7 44 24 0c 61 52 10 	movl   $0xf0105261,0xc(%esp)
f010188d:	f0 
f010188e:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101895:	f0 
f0101896:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
f010189d:	00 
f010189e:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01018a5:	e8 47 e8 ff ff       	call   f01000f1 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01018aa:	89 34 24             	mov    %esi,(%esp)
f01018ad:	e8 9c f9 ff ff       	call   f010124e <page_free>
	page_free(pp1);
f01018b2:	89 3c 24             	mov    %edi,(%esp)
f01018b5:	e8 94 f9 ff ff       	call   f010124e <page_free>
	page_free(pp2);
f01018ba:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01018bd:	89 14 24             	mov    %edx,(%esp)
f01018c0:	e8 89 f9 ff ff       	call   f010124e <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018cc:	e8 ff f8 ff ff       	call   f01011d0 <page_alloc>
f01018d1:	89 c6                	mov    %eax,%esi
f01018d3:	85 c0                	test   %eax,%eax
f01018d5:	75 24                	jne    f01018fb <mem_init+0x3cb>
f01018d7:	c7 44 24 0c b6 51 10 	movl   $0xf01051b6,0xc(%esp)
f01018de:	f0 
f01018df:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01018e6:	f0 
f01018e7:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
f01018ee:	00 
f01018ef:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01018f6:	e8 f6 e7 ff ff       	call   f01000f1 <_panic>
	assert((pp1 = page_alloc(0)));
f01018fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101902:	e8 c9 f8 ff ff       	call   f01011d0 <page_alloc>
f0101907:	89 c7                	mov    %eax,%edi
f0101909:	85 c0                	test   %eax,%eax
f010190b:	75 24                	jne    f0101931 <mem_init+0x401>
f010190d:	c7 44 24 0c cc 51 10 	movl   $0xf01051cc,0xc(%esp)
f0101914:	f0 
f0101915:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010191c:	f0 
f010191d:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
f0101924:	00 
f0101925:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010192c:	e8 c0 e7 ff ff       	call   f01000f1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101931:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101938:	e8 93 f8 ff ff       	call   f01011d0 <page_alloc>
f010193d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101940:	85 c0                	test   %eax,%eax
f0101942:	75 24                	jne    f0101968 <mem_init+0x438>
f0101944:	c7 44 24 0c e2 51 10 	movl   $0xf01051e2,0xc(%esp)
f010194b:	f0 
f010194c:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101953:	f0 
f0101954:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f010195b:	00 
f010195c:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101963:	e8 89 e7 ff ff       	call   f01000f1 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101968:	39 fe                	cmp    %edi,%esi
f010196a:	75 24                	jne    f0101990 <mem_init+0x460>
f010196c:	c7 44 24 0c f8 51 10 	movl   $0xf01051f8,0xc(%esp)
f0101973:	f0 
f0101974:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010197b:	f0 
f010197c:	c7 44 24 04 77 02 00 	movl   $0x277,0x4(%esp)
f0101983:	00 
f0101984:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010198b:	e8 61 e7 ff ff       	call   f01000f1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101990:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101993:	74 05                	je     f010199a <mem_init+0x46a>
f0101995:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101998:	75 24                	jne    f01019be <mem_init+0x48e>
f010199a:	c7 44 24 0c a4 4a 10 	movl   $0xf0104aa4,0xc(%esp)
f01019a1:	f0 
f01019a2:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01019a9:	f0 
f01019aa:	c7 44 24 04 78 02 00 	movl   $0x278,0x4(%esp)
f01019b1:	00 
f01019b2:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01019b9:	e8 33 e7 ff ff       	call   f01000f1 <_panic>
	assert(!page_alloc(0));
f01019be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019c5:	e8 06 f8 ff ff       	call   f01011d0 <page_alloc>
f01019ca:	85 c0                	test   %eax,%eax
f01019cc:	74 24                	je     f01019f2 <mem_init+0x4c2>
f01019ce:	c7 44 24 0c 61 52 10 	movl   $0xf0105261,0xc(%esp)
f01019d5:	f0 
f01019d6:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01019dd:	f0 
f01019de:	c7 44 24 04 79 02 00 	movl   $0x279,0x4(%esp)
f01019e5:	00 
f01019e6:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01019ed:	e8 ff e6 ff ff       	call   f01000f1 <_panic>
f01019f2:	89 f0                	mov    %esi,%eax
f01019f4:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f01019fa:	c1 f8 03             	sar    $0x3,%eax
f01019fd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a00:	89 c2                	mov    %eax,%edx
f0101a02:	c1 ea 0c             	shr    $0xc,%edx
f0101a05:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0101a0b:	72 20                	jb     f0101a2d <mem_init+0x4fd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101a11:	c7 44 24 08 08 49 10 	movl   $0xf0104908,0x8(%esp)
f0101a18:	f0 
f0101a19:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101a20:	00 
f0101a21:	c7 04 24 90 50 10 f0 	movl   $0xf0105090,(%esp)
f0101a28:	e8 c4 e6 ff ff       	call   f01000f1 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101a2d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a34:	00 
f0101a35:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101a3c:	00 
	return (void *)(pa + KERNBASE);
f0101a3d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a42:	89 04 24             	mov    %eax,(%esp)
f0101a45:	e8 57 23 00 00       	call   f0103da1 <memset>
	page_free(pp0);
f0101a4a:	89 34 24             	mov    %esi,(%esp)
f0101a4d:	e8 fc f7 ff ff       	call   f010124e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a52:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a59:	e8 72 f7 ff ff       	call   f01011d0 <page_alloc>
f0101a5e:	85 c0                	test   %eax,%eax
f0101a60:	75 24                	jne    f0101a86 <mem_init+0x556>
f0101a62:	c7 44 24 0c 70 52 10 	movl   $0xf0105270,0xc(%esp)
f0101a69:	f0 
f0101a6a:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101a71:	f0 
f0101a72:	c7 44 24 04 7e 02 00 	movl   $0x27e,0x4(%esp)
f0101a79:	00 
f0101a7a:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101a81:	e8 6b e6 ff ff       	call   f01000f1 <_panic>
	assert(pp && pp0 == pp);
f0101a86:	39 c6                	cmp    %eax,%esi
f0101a88:	74 24                	je     f0101aae <mem_init+0x57e>
f0101a8a:	c7 44 24 0c 8e 52 10 	movl   $0xf010528e,0xc(%esp)
f0101a91:	f0 
f0101a92:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101a99:	f0 
f0101a9a:	c7 44 24 04 7f 02 00 	movl   $0x27f,0x4(%esp)
f0101aa1:	00 
f0101aa2:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101aa9:	e8 43 e6 ff ff       	call   f01000f1 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101aae:	89 f2                	mov    %esi,%edx
f0101ab0:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0101ab6:	c1 fa 03             	sar    $0x3,%edx
f0101ab9:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101abc:	89 d0                	mov    %edx,%eax
f0101abe:	c1 e8 0c             	shr    $0xc,%eax
f0101ac1:	3b 05 48 89 11 f0    	cmp    0xf0118948,%eax
f0101ac7:	72 20                	jb     f0101ae9 <mem_init+0x5b9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ac9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101acd:	c7 44 24 08 08 49 10 	movl   $0xf0104908,0x8(%esp)
f0101ad4:	f0 
f0101ad5:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101adc:	00 
f0101add:	c7 04 24 90 50 10 f0 	movl   $0xf0105090,(%esp)
f0101ae4:	e8 08 e6 ff ff       	call   f01000f1 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101ae9:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101af0:	75 11                	jne    f0101b03 <mem_init+0x5d3>
f0101af2:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101af8:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101afe:	80 38 00             	cmpb   $0x0,(%eax)
f0101b01:	74 24                	je     f0101b27 <mem_init+0x5f7>
f0101b03:	c7 44 24 0c 9e 52 10 	movl   $0xf010529e,0xc(%esp)
f0101b0a:	f0 
f0101b0b:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101b12:	f0 
f0101b13:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
f0101b1a:	00 
f0101b1b:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101b22:	e8 ca e5 ff ff       	call   f01000f1 <_panic>
f0101b27:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101b2a:	39 d0                	cmp    %edx,%eax
f0101b2c:	75 d0                	jne    f0101afe <mem_init+0x5ce>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101b2e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101b31:	89 0d 2c 85 11 f0    	mov    %ecx,0xf011852c

	// free the pages we took
	page_free(pp0);
f0101b37:	89 34 24             	mov    %esi,(%esp)
f0101b3a:	e8 0f f7 ff ff       	call   f010124e <page_free>
	page_free(pp1);
f0101b3f:	89 3c 24             	mov    %edi,(%esp)
f0101b42:	e8 07 f7 ff ff       	call   f010124e <page_free>
	page_free(pp2);
f0101b47:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101b4a:	89 34 24             	mov    %esi,(%esp)
f0101b4d:	e8 fc f6 ff ff       	call   f010124e <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b52:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f0101b57:	85 c0                	test   %eax,%eax
f0101b59:	74 09                	je     f0101b64 <mem_init+0x634>
		--nfree;
f0101b5b:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b5e:	8b 00                	mov    (%eax),%eax
f0101b60:	85 c0                	test   %eax,%eax
f0101b62:	75 f7                	jne    f0101b5b <mem_init+0x62b>
		--nfree;
	assert(nfree == 0);
f0101b64:	85 db                	test   %ebx,%ebx
f0101b66:	74 24                	je     f0101b8c <mem_init+0x65c>
f0101b68:	c7 44 24 0c a8 52 10 	movl   $0xf01052a8,0xc(%esp)
f0101b6f:	f0 
f0101b70:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101b77:	f0 
f0101b78:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f0101b7f:	00 
f0101b80:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101b87:	e8 65 e5 ff ff       	call   f01000f1 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101b8c:	c7 04 24 c4 4a 10 f0 	movl   $0xf0104ac4,(%esp)
f0101b93:	e8 2a 16 00 00       	call   f01031c2 <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	cprintf("so far so good\n");
f0101b98:	c7 04 24 b3 52 10 f0 	movl   $0xf01052b3,(%esp)
f0101b9f:	e8 1e 16 00 00       	call   f01031c2 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ba4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bab:	e8 20 f6 ff ff       	call   f01011d0 <page_alloc>
f0101bb0:	89 c6                	mov    %eax,%esi
f0101bb2:	85 c0                	test   %eax,%eax
f0101bb4:	75 24                	jne    f0101bda <mem_init+0x6aa>
f0101bb6:	c7 44 24 0c b6 51 10 	movl   $0xf01051b6,0xc(%esp)
f0101bbd:	f0 
f0101bbe:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101bc5:	f0 
f0101bc6:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f0101bcd:	00 
f0101bce:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101bd5:	e8 17 e5 ff ff       	call   f01000f1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101bda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101be1:	e8 ea f5 ff ff       	call   f01011d0 <page_alloc>
f0101be6:	89 c7                	mov    %eax,%edi
f0101be8:	85 c0                	test   %eax,%eax
f0101bea:	75 24                	jne    f0101c10 <mem_init+0x6e0>
f0101bec:	c7 44 24 0c cc 51 10 	movl   $0xf01051cc,0xc(%esp)
f0101bf3:	f0 
f0101bf4:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101bfb:	f0 
f0101bfc:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0101c03:	00 
f0101c04:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101c0b:	e8 e1 e4 ff ff       	call   f01000f1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c17:	e8 b4 f5 ff ff       	call   f01011d0 <page_alloc>
f0101c1c:	89 c3                	mov    %eax,%ebx
f0101c1e:	85 c0                	test   %eax,%eax
f0101c20:	75 24                	jne    f0101c46 <mem_init+0x716>
f0101c22:	c7 44 24 0c e2 51 10 	movl   $0xf01051e2,0xc(%esp)
f0101c29:	f0 
f0101c2a:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101c31:	f0 
f0101c32:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f0101c39:	00 
f0101c3a:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101c41:	e8 ab e4 ff ff       	call   f01000f1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c46:	39 fe                	cmp    %edi,%esi
f0101c48:	75 24                	jne    f0101c6e <mem_init+0x73e>
f0101c4a:	c7 44 24 0c f8 51 10 	movl   $0xf01051f8,0xc(%esp)
f0101c51:	f0 
f0101c52:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101c59:	f0 
f0101c5a:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0101c61:	00 
f0101c62:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101c69:	e8 83 e4 ff ff       	call   f01000f1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c6e:	39 c7                	cmp    %eax,%edi
f0101c70:	74 04                	je     f0101c76 <mem_init+0x746>
f0101c72:	39 c6                	cmp    %eax,%esi
f0101c74:	75 24                	jne    f0101c9a <mem_init+0x76a>
f0101c76:	c7 44 24 0c a4 4a 10 	movl   $0xf0104aa4,0xc(%esp)
f0101c7d:	f0 
f0101c7e:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101c85:	f0 
f0101c86:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f0101c8d:	00 
f0101c8e:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101c95:	e8 57 e4 ff ff       	call   f01000f1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c9a:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f0101c9f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	page_free_list = 0;
f0101ca2:	c7 05 2c 85 11 f0 00 	movl   $0x0,0xf011852c
f0101ca9:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101cac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cb3:	e8 18 f5 ff ff       	call   f01011d0 <page_alloc>
f0101cb8:	85 c0                	test   %eax,%eax
f0101cba:	74 24                	je     f0101ce0 <mem_init+0x7b0>
f0101cbc:	c7 44 24 0c 61 52 10 	movl   $0xf0105261,0xc(%esp)
f0101cc3:	f0 
f0101cc4:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101ccb:	f0 
f0101ccc:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0101cd3:	00 
f0101cd4:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101cdb:	e8 11 e4 ff ff       	call   f01000f1 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ce0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ce3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ce7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101cee:	00 
f0101cef:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101cf4:	89 04 24             	mov    %eax,(%esp)
f0101cf7:	e8 dc f6 ff ff       	call   f01013d8 <page_lookup>
f0101cfc:	85 c0                	test   %eax,%eax
f0101cfe:	74 24                	je     f0101d24 <mem_init+0x7f4>
f0101d00:	c7 44 24 0c e4 4a 10 	movl   $0xf0104ae4,0xc(%esp)
f0101d07:	f0 
f0101d08:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101d0f:	f0 
f0101d10:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f0101d17:	00 
f0101d18:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101d1f:	e8 cd e3 ff ff       	call   f01000f1 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d24:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d2b:	00 
f0101d2c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d33:	00 
f0101d34:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101d38:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101d3d:	89 04 24             	mov    %eax,(%esp)
f0101d40:	e8 6f f7 ff ff       	call   f01014b4 <page_insert>
f0101d45:	85 c0                	test   %eax,%eax
f0101d47:	78 24                	js     f0101d6d <mem_init+0x83d>
f0101d49:	c7 44 24 0c 1c 4b 10 	movl   $0xf0104b1c,0xc(%esp)
f0101d50:	f0 
f0101d51:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101d58:	f0 
f0101d59:	c7 44 24 04 fa 02 00 	movl   $0x2fa,0x4(%esp)
f0101d60:	00 
f0101d61:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101d68:	e8 84 e3 ff ff       	call   f01000f1 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d6d:	89 34 24             	mov    %esi,(%esp)
f0101d70:	e8 d9 f4 ff ff       	call   f010124e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d75:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d7c:	00 
f0101d7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d84:	00 
f0101d85:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101d89:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101d8e:	89 04 24             	mov    %eax,(%esp)
f0101d91:	e8 1e f7 ff ff       	call   f01014b4 <page_insert>
f0101d96:	85 c0                	test   %eax,%eax
f0101d98:	74 24                	je     f0101dbe <mem_init+0x88e>
f0101d9a:	c7 44 24 0c 4c 4b 10 	movl   $0xf0104b4c,0xc(%esp)
f0101da1:	f0 
f0101da2:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101da9:	f0 
f0101daa:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f0101db1:	00 
f0101db2:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101db9:	e8 33 e3 ff ff       	call   f01000f1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101dbe:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101dc3:	8b 08                	mov    (%eax),%ecx
f0101dc5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101dcb:	89 f2                	mov    %esi,%edx
f0101dcd:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0101dd3:	c1 fa 03             	sar    $0x3,%edx
f0101dd6:	c1 e2 0c             	shl    $0xc,%edx
f0101dd9:	39 d1                	cmp    %edx,%ecx
f0101ddb:	74 24                	je     f0101e01 <mem_init+0x8d1>
f0101ddd:	c7 44 24 0c 7c 4b 10 	movl   $0xf0104b7c,0xc(%esp)
f0101de4:	f0 
f0101de5:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101dec:	f0 
f0101ded:	c7 44 24 04 ff 02 00 	movl   $0x2ff,0x4(%esp)
f0101df4:	00 
f0101df5:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101dfc:	e8 f0 e2 ff ff       	call   f01000f1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101e01:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e06:	e8 3d ee ff ff       	call   f0100c48 <check_va2pa>
f0101e0b:	89 fa                	mov    %edi,%edx
f0101e0d:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0101e13:	c1 fa 03             	sar    $0x3,%edx
f0101e16:	c1 e2 0c             	shl    $0xc,%edx
f0101e19:	39 d0                	cmp    %edx,%eax
f0101e1b:	74 24                	je     f0101e41 <mem_init+0x911>
f0101e1d:	c7 44 24 0c a4 4b 10 	movl   $0xf0104ba4,0xc(%esp)
f0101e24:	f0 
f0101e25:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101e2c:	f0 
f0101e2d:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f0101e34:	00 
f0101e35:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101e3c:	e8 b0 e2 ff ff       	call   f01000f1 <_panic>
	assert(pp1->pp_ref == 1);
f0101e41:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e46:	74 24                	je     f0101e6c <mem_init+0x93c>
f0101e48:	c7 44 24 0c c3 52 10 	movl   $0xf01052c3,0xc(%esp)
f0101e4f:	f0 
f0101e50:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101e57:	f0 
f0101e58:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0101e5f:	00 
f0101e60:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101e67:	e8 85 e2 ff ff       	call   f01000f1 <_panic>
	assert(pp0->pp_ref == 1);
f0101e6c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e71:	74 24                	je     f0101e97 <mem_init+0x967>
f0101e73:	c7 44 24 0c d4 52 10 	movl   $0xf01052d4,0xc(%esp)
f0101e7a:	f0 
f0101e7b:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101e82:	f0 
f0101e83:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0101e8a:	00 
f0101e8b:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101e92:	e8 5a e2 ff ff       	call   f01000f1 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e97:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e9e:	00 
f0101e9f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ea6:	00 
f0101ea7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101eab:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101eb0:	89 04 24             	mov    %eax,(%esp)
f0101eb3:	e8 fc f5 ff ff       	call   f01014b4 <page_insert>
f0101eb8:	85 c0                	test   %eax,%eax
f0101eba:	74 24                	je     f0101ee0 <mem_init+0x9b0>
f0101ebc:	c7 44 24 0c d4 4b 10 	movl   $0xf0104bd4,0xc(%esp)
f0101ec3:	f0 
f0101ec4:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101ecb:	f0 
f0101ecc:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0101ed3:	00 
f0101ed4:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101edb:	e8 11 e2 ff ff       	call   f01000f1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ee0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ee5:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101eea:	e8 59 ed ff ff       	call   f0100c48 <check_va2pa>
f0101eef:	89 da                	mov    %ebx,%edx
f0101ef1:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0101ef7:	c1 fa 03             	sar    $0x3,%edx
f0101efa:	c1 e2 0c             	shl    $0xc,%edx
f0101efd:	39 d0                	cmp    %edx,%eax
f0101eff:	74 24                	je     f0101f25 <mem_init+0x9f5>
f0101f01:	c7 44 24 0c 10 4c 10 	movl   $0xf0104c10,0xc(%esp)
f0101f08:	f0 
f0101f09:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101f10:	f0 
f0101f11:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0101f18:	00 
f0101f19:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101f20:	e8 cc e1 ff ff       	call   f01000f1 <_panic>
	assert(pp2->pp_ref == 1);
f0101f25:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f2a:	74 24                	je     f0101f50 <mem_init+0xa20>
f0101f2c:	c7 44 24 0c e5 52 10 	movl   $0xf01052e5,0xc(%esp)
f0101f33:	f0 
f0101f34:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101f3b:	f0 
f0101f3c:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0101f43:	00 
f0101f44:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101f4b:	e8 a1 e1 ff ff       	call   f01000f1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f57:	e8 74 f2 ff ff       	call   f01011d0 <page_alloc>
f0101f5c:	85 c0                	test   %eax,%eax
f0101f5e:	74 24                	je     f0101f84 <mem_init+0xa54>
f0101f60:	c7 44 24 0c 61 52 10 	movl   $0xf0105261,0xc(%esp)
f0101f67:	f0 
f0101f68:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101f6f:	f0 
f0101f70:	c7 44 24 04 0a 03 00 	movl   $0x30a,0x4(%esp)
f0101f77:	00 
f0101f78:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101f7f:	e8 6d e1 ff ff       	call   f01000f1 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f84:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f8b:	00 
f0101f8c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f93:	00 
f0101f94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f98:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101f9d:	89 04 24             	mov    %eax,(%esp)
f0101fa0:	e8 0f f5 ff ff       	call   f01014b4 <page_insert>
f0101fa5:	85 c0                	test   %eax,%eax
f0101fa7:	74 24                	je     f0101fcd <mem_init+0xa9d>
f0101fa9:	c7 44 24 0c d4 4b 10 	movl   $0xf0104bd4,0xc(%esp)
f0101fb0:	f0 
f0101fb1:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101fb8:	f0 
f0101fb9:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f0101fc0:	00 
f0101fc1:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0101fc8:	e8 24 e1 ff ff       	call   f01000f1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fcd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fd2:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0101fd7:	e8 6c ec ff ff       	call   f0100c48 <check_va2pa>
f0101fdc:	89 da                	mov    %ebx,%edx
f0101fde:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0101fe4:	c1 fa 03             	sar    $0x3,%edx
f0101fe7:	c1 e2 0c             	shl    $0xc,%edx
f0101fea:	39 d0                	cmp    %edx,%eax
f0101fec:	74 24                	je     f0102012 <mem_init+0xae2>
f0101fee:	c7 44 24 0c 10 4c 10 	movl   $0xf0104c10,0xc(%esp)
f0101ff5:	f0 
f0101ff6:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0101ffd:	f0 
f0101ffe:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f0102005:	00 
f0102006:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010200d:	e8 df e0 ff ff       	call   f01000f1 <_panic>
	assert(pp2->pp_ref == 1);
f0102012:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102017:	74 24                	je     f010203d <mem_init+0xb0d>
f0102019:	c7 44 24 0c e5 52 10 	movl   $0xf01052e5,0xc(%esp)
f0102020:	f0 
f0102021:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102028:	f0 
f0102029:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0102030:	00 
f0102031:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102038:	e8 b4 e0 ff ff       	call   f01000f1 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010203d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102044:	e8 87 f1 ff ff       	call   f01011d0 <page_alloc>
f0102049:	85 c0                	test   %eax,%eax
f010204b:	74 24                	je     f0102071 <mem_init+0xb41>
f010204d:	c7 44 24 0c 61 52 10 	movl   $0xf0105261,0xc(%esp)
f0102054:	f0 
f0102055:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010205c:	f0 
f010205d:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f0102064:	00 
f0102065:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010206c:	e8 80 e0 ff ff       	call   f01000f1 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102071:	8b 15 4c 89 11 f0    	mov    0xf011894c,%edx
f0102077:	8b 02                	mov    (%edx),%eax
f0102079:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010207e:	89 c1                	mov    %eax,%ecx
f0102080:	c1 e9 0c             	shr    $0xc,%ecx
f0102083:	3b 0d 48 89 11 f0    	cmp    0xf0118948,%ecx
f0102089:	72 20                	jb     f01020ab <mem_init+0xb7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010208b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010208f:	c7 44 24 08 08 49 10 	movl   $0xf0104908,0x8(%esp)
f0102096:	f0 
f0102097:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f010209e:	00 
f010209f:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01020a6:	e8 46 e0 ff ff       	call   f01000f1 <_panic>
	return (void *)(pa + KERNBASE);
f01020ab:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01020b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020ba:	00 
f01020bb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020c2:	00 
f01020c3:	89 14 24             	mov    %edx,(%esp)
f01020c6:	e8 bb f1 ff ff       	call   f0101286 <pgdir_walk>
f01020cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01020ce:	83 c2 04             	add    $0x4,%edx
f01020d1:	39 d0                	cmp    %edx,%eax
f01020d3:	74 24                	je     f01020f9 <mem_init+0xbc9>
f01020d5:	c7 44 24 0c 40 4c 10 	movl   $0xf0104c40,0xc(%esp)
f01020dc:	f0 
f01020dd:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01020e4:	f0 
f01020e5:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f01020ec:	00 
f01020ed:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01020f4:	e8 f8 df ff ff       	call   f01000f1 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01020f9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102100:	00 
f0102101:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102108:	00 
f0102109:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010210d:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102112:	89 04 24             	mov    %eax,(%esp)
f0102115:	e8 9a f3 ff ff       	call   f01014b4 <page_insert>
f010211a:	85 c0                	test   %eax,%eax
f010211c:	74 24                	je     f0102142 <mem_init+0xc12>
f010211e:	c7 44 24 0c 80 4c 10 	movl   $0xf0104c80,0xc(%esp)
f0102125:	f0 
f0102126:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010212d:	f0 
f010212e:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0102135:	00 
f0102136:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010213d:	e8 af df ff ff       	call   f01000f1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102142:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102147:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f010214c:	e8 f7 ea ff ff       	call   f0100c48 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102151:	89 da                	mov    %ebx,%edx
f0102153:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0102159:	c1 fa 03             	sar    $0x3,%edx
f010215c:	c1 e2 0c             	shl    $0xc,%edx
f010215f:	39 d0                	cmp    %edx,%eax
f0102161:	74 24                	je     f0102187 <mem_init+0xc57>
f0102163:	c7 44 24 0c 10 4c 10 	movl   $0xf0104c10,0xc(%esp)
f010216a:	f0 
f010216b:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102172:	f0 
f0102173:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f010217a:	00 
f010217b:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102182:	e8 6a df ff ff       	call   f01000f1 <_panic>
	assert(pp2->pp_ref == 1);
f0102187:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010218c:	74 24                	je     f01021b2 <mem_init+0xc82>
f010218e:	c7 44 24 0c e5 52 10 	movl   $0xf01052e5,0xc(%esp)
f0102195:	f0 
f0102196:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010219d:	f0 
f010219e:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f01021a5:	00 
f01021a6:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01021ad:	e8 3f df ff ff       	call   f01000f1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01021b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021b9:	00 
f01021ba:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021c1:	00 
f01021c2:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f01021c7:	89 04 24             	mov    %eax,(%esp)
f01021ca:	e8 b7 f0 ff ff       	call   f0101286 <pgdir_walk>
f01021cf:	f6 00 04             	testb  $0x4,(%eax)
f01021d2:	75 24                	jne    f01021f8 <mem_init+0xcc8>
f01021d4:	c7 44 24 0c c0 4c 10 	movl   $0xf0104cc0,0xc(%esp)
f01021db:	f0 
f01021dc:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01021e3:	f0 
f01021e4:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f01021eb:	00 
f01021ec:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01021f3:	e8 f9 de ff ff       	call   f01000f1 <_panic>
	cprintf("pp2 %x\n", pp2);
f01021f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01021fc:	c7 04 24 f6 52 10 f0 	movl   $0xf01052f6,(%esp)
f0102203:	e8 ba 0f 00 00       	call   f01031c2 <cprintf>
	cprintf("kern_pgdir %x\n", kern_pgdir);
f0102208:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f010220d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102211:	c7 04 24 fe 52 10 f0 	movl   $0xf01052fe,(%esp)
f0102218:	e8 a5 0f 00 00       	call   f01031c2 <cprintf>
	cprintf("kern_pgdir[0] is %x\n", kern_pgdir[0]);
f010221d:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102222:	8b 00                	mov    (%eax),%eax
f0102224:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102228:	c7 04 24 0d 53 10 f0 	movl   $0xf010530d,(%esp)
f010222f:	e8 8e 0f 00 00       	call   f01031c2 <cprintf>
	assert(kern_pgdir[0] & PTE_U);
f0102234:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102239:	f6 00 04             	testb  $0x4,(%eax)
f010223c:	75 24                	jne    f0102262 <mem_init+0xd32>
f010223e:	c7 44 24 0c 22 53 10 	movl   $0xf0105322,0xc(%esp)
f0102245:	f0 
f0102246:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010224d:	f0 
f010224e:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0102255:	00 
f0102256:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010225d:	e8 8f de ff ff       	call   f01000f1 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102262:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102269:	00 
f010226a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102271:	00 
f0102272:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102276:	89 04 24             	mov    %eax,(%esp)
f0102279:	e8 36 f2 ff ff       	call   f01014b4 <page_insert>
f010227e:	85 c0                	test   %eax,%eax
f0102280:	74 24                	je     f01022a6 <mem_init+0xd76>
f0102282:	c7 44 24 0c d4 4b 10 	movl   $0xf0104bd4,0xc(%esp)
f0102289:	f0 
f010228a:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102291:	f0 
f0102292:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0102299:	00 
f010229a:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01022a1:	e8 4b de ff ff       	call   f01000f1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01022a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022ad:	00 
f01022ae:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022b5:	00 
f01022b6:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f01022bb:	89 04 24             	mov    %eax,(%esp)
f01022be:	e8 c3 ef ff ff       	call   f0101286 <pgdir_walk>
f01022c3:	f6 00 02             	testb  $0x2,(%eax)
f01022c6:	75 24                	jne    f01022ec <mem_init+0xdbc>
f01022c8:	c7 44 24 0c f4 4c 10 	movl   $0xf0104cf4,0xc(%esp)
f01022cf:	f0 
f01022d0:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01022d7:	f0 
f01022d8:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f01022df:	00 
f01022e0:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01022e7:	e8 05 de ff ff       	call   f01000f1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01022ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022f3:	00 
f01022f4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022fb:	00 
f01022fc:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102301:	89 04 24             	mov    %eax,(%esp)
f0102304:	e8 7d ef ff ff       	call   f0101286 <pgdir_walk>
f0102309:	f6 00 04             	testb  $0x4,(%eax)
f010230c:	74 24                	je     f0102332 <mem_init+0xe02>
f010230e:	c7 44 24 0c 28 4d 10 	movl   $0xf0104d28,0xc(%esp)
f0102315:	f0 
f0102316:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010231d:	f0 
f010231e:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0102325:	00 
f0102326:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010232d:	e8 bf dd ff ff       	call   f01000f1 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102332:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102339:	00 
f010233a:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102341:	00 
f0102342:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102346:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f010234b:	89 04 24             	mov    %eax,(%esp)
f010234e:	e8 61 f1 ff ff       	call   f01014b4 <page_insert>
f0102353:	85 c0                	test   %eax,%eax
f0102355:	78 24                	js     f010237b <mem_init+0xe4b>
f0102357:	c7 44 24 0c 60 4d 10 	movl   $0xf0104d60,0xc(%esp)
f010235e:	f0 
f010235f:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102366:	f0 
f0102367:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f010236e:	00 
f010236f:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102376:	e8 76 dd ff ff       	call   f01000f1 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010237b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102382:	00 
f0102383:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010238a:	00 
f010238b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010238f:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102394:	89 04 24             	mov    %eax,(%esp)
f0102397:	e8 18 f1 ff ff       	call   f01014b4 <page_insert>
f010239c:	85 c0                	test   %eax,%eax
f010239e:	74 24                	je     f01023c4 <mem_init+0xe94>
f01023a0:	c7 44 24 0c 98 4d 10 	movl   $0xf0104d98,0xc(%esp)
f01023a7:	f0 
f01023a8:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01023af:	f0 
f01023b0:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f01023b7:	00 
f01023b8:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01023bf:	e8 2d dd ff ff       	call   f01000f1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01023c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023cb:	00 
f01023cc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023d3:	00 
f01023d4:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f01023d9:	89 04 24             	mov    %eax,(%esp)
f01023dc:	e8 a5 ee ff ff       	call   f0101286 <pgdir_walk>
f01023e1:	f6 00 04             	testb  $0x4,(%eax)
f01023e4:	74 24                	je     f010240a <mem_init+0xeda>
f01023e6:	c7 44 24 0c 28 4d 10 	movl   $0xf0104d28,0xc(%esp)
f01023ed:	f0 
f01023ee:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01023f5:	f0 
f01023f6:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f01023fd:	00 
f01023fe:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102405:	e8 e7 dc ff ff       	call   f01000f1 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010240a:	ba 00 00 00 00       	mov    $0x0,%edx
f010240f:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102414:	e8 2f e8 ff ff       	call   f0100c48 <check_va2pa>
f0102419:	89 fa                	mov    %edi,%edx
f010241b:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0102421:	c1 fa 03             	sar    $0x3,%edx
f0102424:	c1 e2 0c             	shl    $0xc,%edx
f0102427:	39 d0                	cmp    %edx,%eax
f0102429:	74 24                	je     f010244f <mem_init+0xf1f>
f010242b:	c7 44 24 0c d4 4d 10 	movl   $0xf0104dd4,0xc(%esp)
f0102432:	f0 
f0102433:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010243a:	f0 
f010243b:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0102442:	00 
f0102443:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010244a:	e8 a2 dc ff ff       	call   f01000f1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010244f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102454:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102459:	e8 ea e7 ff ff       	call   f0100c48 <check_va2pa>
f010245e:	89 fa                	mov    %edi,%edx
f0102460:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0102466:	c1 fa 03             	sar    $0x3,%edx
f0102469:	c1 e2 0c             	shl    $0xc,%edx
f010246c:	39 d0                	cmp    %edx,%eax
f010246e:	74 24                	je     f0102494 <mem_init+0xf64>
f0102470:	c7 44 24 0c 00 4e 10 	movl   $0xf0104e00,0xc(%esp)
f0102477:	f0 
f0102478:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010247f:	f0 
f0102480:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0102487:	00 
f0102488:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010248f:	e8 5d dc ff ff       	call   f01000f1 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102494:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102499:	74 24                	je     f01024bf <mem_init+0xf8f>
f010249b:	c7 44 24 0c 38 53 10 	movl   $0xf0105338,0xc(%esp)
f01024a2:	f0 
f01024a3:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01024aa:	f0 
f01024ab:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f01024b2:	00 
f01024b3:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01024ba:	e8 32 dc ff ff       	call   f01000f1 <_panic>
	assert(pp2->pp_ref == 0);
f01024bf:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024c4:	74 24                	je     f01024ea <mem_init+0xfba>
f01024c6:	c7 44 24 0c 49 53 10 	movl   $0xf0105349,0xc(%esp)
f01024cd:	f0 
f01024ce:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01024d5:	f0 
f01024d6:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f01024dd:	00 
f01024de:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01024e5:	e8 07 dc ff ff       	call   f01000f1 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01024ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024f1:	e8 da ec ff ff       	call   f01011d0 <page_alloc>
f01024f6:	85 c0                	test   %eax,%eax
f01024f8:	74 04                	je     f01024fe <mem_init+0xfce>
f01024fa:	39 c3                	cmp    %eax,%ebx
f01024fc:	74 24                	je     f0102522 <mem_init+0xff2>
f01024fe:	c7 44 24 0c 30 4e 10 	movl   $0xf0104e30,0xc(%esp)
f0102505:	f0 
f0102506:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010250d:	f0 
f010250e:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f0102515:	00 
f0102516:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010251d:	e8 cf db ff ff       	call   f01000f1 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102522:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102529:	00 
f010252a:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f010252f:	89 04 24             	mov    %eax,(%esp)
f0102532:	e8 25 ef ff ff       	call   f010145c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102537:	ba 00 00 00 00       	mov    $0x0,%edx
f010253c:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102541:	e8 02 e7 ff ff       	call   f0100c48 <check_va2pa>
f0102546:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102549:	74 24                	je     f010256f <mem_init+0x103f>
f010254b:	c7 44 24 0c 54 4e 10 	movl   $0xf0104e54,0xc(%esp)
f0102552:	f0 
f0102553:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010255a:	f0 
f010255b:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f0102562:	00 
f0102563:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010256a:	e8 82 db ff ff       	call   f01000f1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010256f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102574:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102579:	e8 ca e6 ff ff       	call   f0100c48 <check_va2pa>
f010257e:	89 fa                	mov    %edi,%edx
f0102580:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0102586:	c1 fa 03             	sar    $0x3,%edx
f0102589:	c1 e2 0c             	shl    $0xc,%edx
f010258c:	39 d0                	cmp    %edx,%eax
f010258e:	74 24                	je     f01025b4 <mem_init+0x1084>
f0102590:	c7 44 24 0c 00 4e 10 	movl   $0xf0104e00,0xc(%esp)
f0102597:	f0 
f0102598:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010259f:	f0 
f01025a0:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f01025a7:	00 
f01025a8:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01025af:	e8 3d db ff ff       	call   f01000f1 <_panic>
	assert(pp1->pp_ref == 1);
f01025b4:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025b9:	74 24                	je     f01025df <mem_init+0x10af>
f01025bb:	c7 44 24 0c c3 52 10 	movl   $0xf01052c3,0xc(%esp)
f01025c2:	f0 
f01025c3:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01025ca:	f0 
f01025cb:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f01025d2:	00 
f01025d3:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01025da:	e8 12 db ff ff       	call   f01000f1 <_panic>
	assert(pp2->pp_ref == 0);
f01025df:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01025e4:	74 24                	je     f010260a <mem_init+0x10da>
f01025e6:	c7 44 24 0c 49 53 10 	movl   $0xf0105349,0xc(%esp)
f01025ed:	f0 
f01025ee:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01025f5:	f0 
f01025f6:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f01025fd:	00 
f01025fe:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102605:	e8 e7 da ff ff       	call   f01000f1 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010260a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102611:	00 
f0102612:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102617:	89 04 24             	mov    %eax,(%esp)
f010261a:	e8 3d ee ff ff       	call   f010145c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010261f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102624:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102629:	e8 1a e6 ff ff       	call   f0100c48 <check_va2pa>
f010262e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102631:	74 24                	je     f0102657 <mem_init+0x1127>
f0102633:	c7 44 24 0c 54 4e 10 	movl   $0xf0104e54,0xc(%esp)
f010263a:	f0 
f010263b:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102642:	f0 
f0102643:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f010264a:	00 
f010264b:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102652:	e8 9a da ff ff       	call   f01000f1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102657:	ba 00 10 00 00       	mov    $0x1000,%edx
f010265c:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102661:	e8 e2 e5 ff ff       	call   f0100c48 <check_va2pa>
f0102666:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102669:	74 24                	je     f010268f <mem_init+0x115f>
f010266b:	c7 44 24 0c 78 4e 10 	movl   $0xf0104e78,0xc(%esp)
f0102672:	f0 
f0102673:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010267a:	f0 
f010267b:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f0102682:	00 
f0102683:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010268a:	e8 62 da ff ff       	call   f01000f1 <_panic>
	assert(pp1->pp_ref == 0);
f010268f:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102694:	74 24                	je     f01026ba <mem_init+0x118a>
f0102696:	c7 44 24 0c 5a 53 10 	movl   $0xf010535a,0xc(%esp)
f010269d:	f0 
f010269e:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01026a5:	f0 
f01026a6:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f01026ad:	00 
f01026ae:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01026b5:	e8 37 da ff ff       	call   f01000f1 <_panic>
	assert(pp2->pp_ref == 0);
f01026ba:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01026bf:	74 24                	je     f01026e5 <mem_init+0x11b5>
f01026c1:	c7 44 24 0c 49 53 10 	movl   $0xf0105349,0xc(%esp)
f01026c8:	f0 
f01026c9:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01026d0:	f0 
f01026d1:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f01026d8:	00 
f01026d9:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01026e0:	e8 0c da ff ff       	call   f01000f1 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01026e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026ec:	e8 df ea ff ff       	call   f01011d0 <page_alloc>
f01026f1:	85 c0                	test   %eax,%eax
f01026f3:	74 04                	je     f01026f9 <mem_init+0x11c9>
f01026f5:	39 c7                	cmp    %eax,%edi
f01026f7:	74 24                	je     f010271d <mem_init+0x11ed>
f01026f9:	c7 44 24 0c a0 4e 10 	movl   $0xf0104ea0,0xc(%esp)
f0102700:	f0 
f0102701:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102708:	f0 
f0102709:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0102710:	00 
f0102711:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102718:	e8 d4 d9 ff ff       	call   f01000f1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010271d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102724:	e8 a7 ea ff ff       	call   f01011d0 <page_alloc>
f0102729:	85 c0                	test   %eax,%eax
f010272b:	74 24                	je     f0102751 <mem_init+0x1221>
f010272d:	c7 44 24 0c 61 52 10 	movl   $0xf0105261,0xc(%esp)
f0102734:	f0 
f0102735:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010273c:	f0 
f010273d:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0102744:	00 
f0102745:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010274c:	e8 a0 d9 ff ff       	call   f01000f1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102751:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102756:	8b 08                	mov    (%eax),%ecx
f0102758:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010275e:	89 f2                	mov    %esi,%edx
f0102760:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f0102766:	c1 fa 03             	sar    $0x3,%edx
f0102769:	c1 e2 0c             	shl    $0xc,%edx
f010276c:	39 d1                	cmp    %edx,%ecx
f010276e:	74 24                	je     f0102794 <mem_init+0x1264>
f0102770:	c7 44 24 0c 7c 4b 10 	movl   $0xf0104b7c,0xc(%esp)
f0102777:	f0 
f0102778:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010277f:	f0 
f0102780:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0102787:	00 
f0102788:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010278f:	e8 5d d9 ff ff       	call   f01000f1 <_panic>
	kern_pgdir[0] = 0;
f0102794:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010279a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010279f:	74 24                	je     f01027c5 <mem_init+0x1295>
f01027a1:	c7 44 24 0c d4 52 10 	movl   $0xf01052d4,0xc(%esp)
f01027a8:	f0 
f01027a9:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01027b0:	f0 
f01027b1:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f01027b8:	00 
f01027b9:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01027c0:	e8 2c d9 ff ff       	call   f01000f1 <_panic>
	pp0->pp_ref = 0;
f01027c5:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01027cb:	89 34 24             	mov    %esi,(%esp)
f01027ce:	e8 7b ea ff ff       	call   f010124e <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01027d3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01027da:	00 
f01027db:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01027e2:	00 
f01027e3:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f01027e8:	89 04 24             	mov    %eax,(%esp)
f01027eb:	e8 96 ea ff ff       	call   f0101286 <pgdir_walk>
f01027f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01027f3:	8b 0d 4c 89 11 f0    	mov    0xf011894c,%ecx
f01027f9:	8b 51 04             	mov    0x4(%ecx),%edx
f01027fc:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102802:	89 55 c4             	mov    %edx,-0x3c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102805:	c1 ea 0c             	shr    $0xc,%edx
f0102808:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f010280e:	72 23                	jb     f0102833 <mem_init+0x1303>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102810:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102813:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102817:	c7 44 24 08 08 49 10 	movl   $0xf0104908,0x8(%esp)
f010281e:	f0 
f010281f:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0102826:	00 
f0102827:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010282e:	e8 be d8 ff ff       	call   f01000f1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102833:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102836:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010283c:	39 d0                	cmp    %edx,%eax
f010283e:	74 24                	je     f0102864 <mem_init+0x1334>
f0102840:	c7 44 24 0c 6b 53 10 	movl   $0xf010536b,0xc(%esp)
f0102847:	f0 
f0102848:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010284f:	f0 
f0102850:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0102857:	00 
f0102858:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010285f:	e8 8d d8 ff ff       	call   f01000f1 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102864:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f010286b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102871:	89 f0                	mov    %esi,%eax
f0102873:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f0102879:	c1 f8 03             	sar    $0x3,%eax
f010287c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010287f:	89 c2                	mov    %eax,%edx
f0102881:	c1 ea 0c             	shr    $0xc,%edx
f0102884:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f010288a:	72 20                	jb     f01028ac <mem_init+0x137c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010288c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102890:	c7 44 24 08 08 49 10 	movl   $0xf0104908,0x8(%esp)
f0102897:	f0 
f0102898:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010289f:	00 
f01028a0:	c7 04 24 90 50 10 f0 	movl   $0xf0105090,(%esp)
f01028a7:	e8 45 d8 ff ff       	call   f01000f1 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01028ac:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01028b3:	00 
f01028b4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01028bb:	00 
	return (void *)(pa + KERNBASE);
f01028bc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01028c1:	89 04 24             	mov    %eax,(%esp)
f01028c4:	e8 d8 14 00 00       	call   f0103da1 <memset>
	page_free(pp0);
f01028c9:	89 34 24             	mov    %esi,(%esp)
f01028cc:	e8 7d e9 ff ff       	call   f010124e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01028d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01028d8:	00 
f01028d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01028e0:	00 
f01028e1:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f01028e6:	89 04 24             	mov    %eax,(%esp)
f01028e9:	e8 98 e9 ff ff       	call   f0101286 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01028ee:	89 f2                	mov    %esi,%edx
f01028f0:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f01028f6:	c1 fa 03             	sar    $0x3,%edx
f01028f9:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028fc:	89 d0                	mov    %edx,%eax
f01028fe:	c1 e8 0c             	shr    $0xc,%eax
f0102901:	3b 05 48 89 11 f0    	cmp    0xf0118948,%eax
f0102907:	72 20                	jb     f0102929 <mem_init+0x13f9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102909:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010290d:	c7 44 24 08 08 49 10 	movl   $0xf0104908,0x8(%esp)
f0102914:	f0 
f0102915:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010291c:	00 
f010291d:	c7 04 24 90 50 10 f0 	movl   $0xf0105090,(%esp)
f0102924:	e8 c8 d7 ff ff       	call   f01000f1 <_panic>
	return (void *)(pa + KERNBASE);
f0102929:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010292f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102932:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102939:	75 11                	jne    f010294c <mem_init+0x141c>
f010293b:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102941:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102947:	f6 00 01             	testb  $0x1,(%eax)
f010294a:	74 24                	je     f0102970 <mem_init+0x1440>
f010294c:	c7 44 24 0c 83 53 10 	movl   $0xf0105383,0xc(%esp)
f0102953:	f0 
f0102954:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f010295b:	f0 
f010295c:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0102963:	00 
f0102964:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f010296b:	e8 81 d7 ff ff       	call   f01000f1 <_panic>
f0102970:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102973:	39 d0                	cmp    %edx,%eax
f0102975:	75 d0                	jne    f0102947 <mem_init+0x1417>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102977:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f010297c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102982:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102988:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010298b:	89 0d 2c 85 11 f0    	mov    %ecx,0xf011852c

	// free the pages we took
	page_free(pp0);
f0102991:	89 34 24             	mov    %esi,(%esp)
f0102994:	e8 b5 e8 ff ff       	call   f010124e <page_free>
	page_free(pp1);
f0102999:	89 3c 24             	mov    %edi,(%esp)
f010299c:	e8 ad e8 ff ff       	call   f010124e <page_free>
	page_free(pp2);
f01029a1:	89 1c 24             	mov    %ebx,(%esp)
f01029a4:	e8 a5 e8 ff ff       	call   f010124e <page_free>

	cprintf("check_page() succeeded!\n");
f01029a9:	c7 04 24 9a 53 10 f0 	movl   $0xf010539a,(%esp)
f01029b0:	e8 0d 08 00 00       	call   f01031c2 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f01029b5:	a1 50 89 11 f0       	mov    0xf0118950,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029ba:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029bf:	77 20                	ja     f01029e1 <mem_init+0x14b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029c5:	c7 44 24 08 80 4a 10 	movl   $0xf0104a80,0x8(%esp)
f01029cc:	f0 
f01029cd:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
f01029d4:	00 
f01029d5:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01029dc:	e8 10 d7 ff ff       	call   f01000f1 <_panic>
f01029e1:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f01029e8:	00 
	return (physaddr_t)kva - KERNBASE;
f01029e9:	05 00 00 00 10       	add    $0x10000000,%eax
f01029ee:	89 04 24             	mov    %eax,(%esp)
f01029f1:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01029f6:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01029fb:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102a00:	e8 26 e9 ff ff       	call   f010132b <boot_map_region>
		UPAGES, 
		PTSIZE, 
		PADDR(pages), 
		PTE_U);
	cprintf("PADDR(pages) %x\n", PADDR(pages));
f0102a05:	a1 50 89 11 f0       	mov    0xf0118950,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a0a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a0f:	77 20                	ja     f0102a31 <mem_init+0x1501>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a11:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a15:	c7 44 24 08 80 4a 10 	movl   $0xf0104a80,0x8(%esp)
f0102a1c:	f0 
f0102a1d:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
f0102a24:	00 
f0102a25:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102a2c:	e8 c0 d6 ff ff       	call   f01000f1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102a31:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a36:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102a3a:	c7 04 24 b3 53 10 f0 	movl   $0xf01053b3,(%esp)
f0102a41:	e8 7c 07 00 00       	call   f01031c2 <cprintf>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a46:	be 00 e0 10 f0       	mov    $0xf010e000,%esi
f0102a4b:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102a51:	77 20                	ja     f0102a73 <mem_init+0x1543>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a53:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102a57:	c7 44 24 08 80 4a 10 	movl   $0xf0104a80,0x8(%esp)
f0102a5e:	f0 
f0102a5f:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f0102a66:	00 
f0102a67:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102a6e:	e8 7e d6 ff ff       	call   f01000f1 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0102a73:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102a7a:	00 
f0102a7b:	c7 04 24 00 e0 10 00 	movl   $0x10e000,(%esp)
f0102a82:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102a87:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102a8c:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102a91:	e8 95 e8 ff ff       	call   f010132b <boot_map_region>
		KSTACKTOP-KSTKSIZE, 
		KSTKSIZE, 
		PADDR(bootstack), 
		PTE_W);
	cprintf("PADDR(bootstack) %x\n", PADDR(bootstack));
f0102a96:	c7 44 24 04 00 e0 10 	movl   $0x10e000,0x4(%esp)
f0102a9d:	00 
f0102a9e:	c7 04 24 c4 53 10 f0 	movl   $0xf01053c4,(%esp)
f0102aa5:	e8 18 07 00 00       	call   f01031c2 <cprintf>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0102aaa:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102ab1:	00 
f0102ab2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ab9:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102abe:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102ac3:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102ac8:	e8 5e e8 ff ff       	call   f010132b <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102acd:	8b 1d 4c 89 11 f0    	mov    0xf011894c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102ad3:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f0102ad8:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102adf:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102ae5:	74 79                	je     f0102b60 <mem_init+0x1630>
f0102ae7:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102aec:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102af2:	89 d8                	mov    %ebx,%eax
f0102af4:	e8 4f e1 ff ff       	call   f0100c48 <check_va2pa>
f0102af9:	8b 15 50 89 11 f0    	mov    0xf0118950,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102aff:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102b05:	77 20                	ja     f0102b27 <mem_init+0x15f7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b07:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102b0b:	c7 44 24 08 80 4a 10 	movl   $0xf0104a80,0x8(%esp)
f0102b12:	f0 
f0102b13:	c7 44 24 04 a7 02 00 	movl   $0x2a7,0x4(%esp)
f0102b1a:	00 
f0102b1b:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102b22:	e8 ca d5 ff ff       	call   f01000f1 <_panic>
f0102b27:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102b2e:	39 d0                	cmp    %edx,%eax
f0102b30:	74 24                	je     f0102b56 <mem_init+0x1626>
f0102b32:	c7 44 24 0c c4 4e 10 	movl   $0xf0104ec4,0xc(%esp)
f0102b39:	f0 
f0102b3a:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102b41:	f0 
f0102b42:	c7 44 24 04 a7 02 00 	movl   $0x2a7,0x4(%esp)
f0102b49:	00 
f0102b4a:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102b51:	e8 9b d5 ff ff       	call   f01000f1 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102b56:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102b5c:	39 f7                	cmp    %esi,%edi
f0102b5e:	77 8c                	ja     f0102aec <mem_init+0x15bc>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102b60:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f0102b65:	c1 e0 0c             	shl    $0xc,%eax
f0102b68:	85 c0                	test   %eax,%eax
f0102b6a:	74 4c                	je     f0102bb8 <mem_init+0x1688>
f0102b6c:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102b71:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102b77:	89 d8                	mov    %ebx,%eax
f0102b79:	e8 ca e0 ff ff       	call   f0100c48 <check_va2pa>
f0102b7e:	39 c6                	cmp    %eax,%esi
f0102b80:	74 24                	je     f0102ba6 <mem_init+0x1676>
f0102b82:	c7 44 24 0c f8 4e 10 	movl   $0xf0104ef8,0xc(%esp)
f0102b89:	f0 
f0102b8a:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102b91:	f0 
f0102b92:	c7 44 24 04 ab 02 00 	movl   $0x2ab,0x4(%esp)
f0102b99:	00 
f0102b9a:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102ba1:	e8 4b d5 ff ff       	call   f01000f1 <_panic>
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ba6:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102bac:	a1 48 89 11 f0       	mov    0xf0118948,%eax
f0102bb1:	c1 e0 0c             	shl    $0xc,%eax
f0102bb4:	39 c6                	cmp    %eax,%esi
f0102bb6:	72 b9                	jb     f0102b71 <mem_init+0x1641>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102bb8:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102bbd:	89 d8                	mov    %ebx,%eax
f0102bbf:	e8 84 e0 ff ff       	call   f0100c48 <check_va2pa>
f0102bc4:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102bc9:	bf 00 e0 10 f0       	mov    $0xf010e000,%edi
f0102bce:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102bd4:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102bd7:	39 d0                	cmp    %edx,%eax
f0102bd9:	74 24                	je     f0102bff <mem_init+0x16cf>
f0102bdb:	c7 44 24 0c 20 4f 10 	movl   $0xf0104f20,0xc(%esp)
f0102be2:	f0 
f0102be3:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102bea:	f0 
f0102beb:	c7 44 24 04 af 02 00 	movl   $0x2af,0x4(%esp)
f0102bf2:	00 
f0102bf3:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102bfa:	e8 f2 d4 ff ff       	call   f01000f1 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102bff:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102c05:	0f 85 34 05 00 00    	jne    f010313f <mem_init+0x1c0f>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102c0b:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102c10:	89 d8                	mov    %ebx,%eax
f0102c12:	e8 31 e0 ff ff       	call   f0100c48 <check_va2pa>
f0102c17:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c1a:	74 24                	je     f0102c40 <mem_init+0x1710>
f0102c1c:	c7 44 24 0c 68 4f 10 	movl   $0xf0104f68,0xc(%esp)
f0102c23:	f0 
f0102c24:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102c2b:	f0 
f0102c2c:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f0102c33:	00 
f0102c34:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102c3b:	e8 b1 d4 ff ff       	call   f01000f1 <_panic>
f0102c40:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102c45:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
f0102c4a:	8d 88 44 fc ff ff    	lea    -0x3bc(%eax),%ecx
f0102c50:	83 f9 03             	cmp    $0x3,%ecx
f0102c53:	77 36                	ja     f0102c8b <mem_init+0x175b>
f0102c55:	89 d6                	mov    %edx,%esi
f0102c57:	d3 e6                	shl    %cl,%esi
f0102c59:	85 f6                	test   %esi,%esi
f0102c5b:	79 2e                	jns    f0102c8b <mem_init+0x175b>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102c5d:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102c61:	0f 85 aa 00 00 00    	jne    f0102d11 <mem_init+0x17e1>
f0102c67:	c7 44 24 0c d9 53 10 	movl   $0xf01053d9,0xc(%esp)
f0102c6e:	f0 
f0102c6f:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102c76:	f0 
f0102c77:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
f0102c7e:	00 
f0102c7f:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102c86:	e8 66 d4 ff ff       	call   f01000f1 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102c8b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102c90:	76 55                	jbe    f0102ce7 <mem_init+0x17b7>
				assert(pgdir[i] & PTE_P);
f0102c92:	8b 0c 83             	mov    (%ebx,%eax,4),%ecx
f0102c95:	f6 c1 01             	test   $0x1,%cl
f0102c98:	75 24                	jne    f0102cbe <mem_init+0x178e>
f0102c9a:	c7 44 24 0c d9 53 10 	movl   $0xf01053d9,0xc(%esp)
f0102ca1:	f0 
f0102ca2:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102ca9:	f0 
f0102caa:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f0102cb1:	00 
f0102cb2:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102cb9:	e8 33 d4 ff ff       	call   f01000f1 <_panic>
				assert(pgdir[i] & PTE_W);
f0102cbe:	f6 c1 02             	test   $0x2,%cl
f0102cc1:	75 4e                	jne    f0102d11 <mem_init+0x17e1>
f0102cc3:	c7 44 24 0c ea 53 10 	movl   $0xf01053ea,0xc(%esp)
f0102cca:	f0 
f0102ccb:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102cd2:	f0 
f0102cd3:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
f0102cda:	00 
f0102cdb:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102ce2:	e8 0a d4 ff ff       	call   f01000f1 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102ce7:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102ceb:	74 24                	je     f0102d11 <mem_init+0x17e1>
f0102ced:	c7 44 24 0c fb 53 10 	movl   $0xf01053fb,0xc(%esp)
f0102cf4:	f0 
f0102cf5:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102cfc:	f0 
f0102cfd:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
f0102d04:	00 
f0102d05:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102d0c:	e8 e0 d3 ff ff       	call   f01000f1 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102d11:	83 c0 01             	add    $0x1,%eax
f0102d14:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102d19:	0f 85 2b ff ff ff    	jne    f0102c4a <mem_init+0x171a>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102d1f:	c7 04 24 98 4f 10 f0 	movl   $0xf0104f98,(%esp)
f0102d26:	e8 97 04 00 00       	call   f01031c2 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102d2b:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d30:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d35:	77 20                	ja     f0102d57 <mem_init+0x1827>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d37:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d3b:	c7 44 24 08 80 4a 10 	movl   $0xf0104a80,0x8(%esp)
f0102d42:	f0 
f0102d43:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
f0102d4a:	00 
f0102d4b:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102d52:	e8 9a d3 ff ff       	call   f01000f1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102d57:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102d5c:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102d5f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d64:	e8 03 e0 ff ff       	call   f0100d6c <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102d69:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102d6c:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102d71:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102d74:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102d77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d7e:	e8 4d e4 ff ff       	call   f01011d0 <page_alloc>
f0102d83:	89 c6                	mov    %eax,%esi
f0102d85:	85 c0                	test   %eax,%eax
f0102d87:	75 24                	jne    f0102dad <mem_init+0x187d>
f0102d89:	c7 44 24 0c b6 51 10 	movl   $0xf01051b6,0xc(%esp)
f0102d90:	f0 
f0102d91:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102d98:	f0 
f0102d99:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0102da0:	00 
f0102da1:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102da8:	e8 44 d3 ff ff       	call   f01000f1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102dad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102db4:	e8 17 e4 ff ff       	call   f01011d0 <page_alloc>
f0102db9:	89 c7                	mov    %eax,%edi
f0102dbb:	85 c0                	test   %eax,%eax
f0102dbd:	75 24                	jne    f0102de3 <mem_init+0x18b3>
f0102dbf:	c7 44 24 0c cc 51 10 	movl   $0xf01051cc,0xc(%esp)
f0102dc6:	f0 
f0102dc7:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102dce:	f0 
f0102dcf:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0102dd6:	00 
f0102dd7:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102dde:	e8 0e d3 ff ff       	call   f01000f1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102de3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102dea:	e8 e1 e3 ff ff       	call   f01011d0 <page_alloc>
f0102def:	89 c3                	mov    %eax,%ebx
f0102df1:	85 c0                	test   %eax,%eax
f0102df3:	75 24                	jne    f0102e19 <mem_init+0x18e9>
f0102df5:	c7 44 24 0c e2 51 10 	movl   $0xf01051e2,0xc(%esp)
f0102dfc:	f0 
f0102dfd:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102e04:	f0 
f0102e05:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0102e0c:	00 
f0102e0d:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102e14:	e8 d8 d2 ff ff       	call   f01000f1 <_panic>
	page_free(pp0);
f0102e19:	89 34 24             	mov    %esi,(%esp)
f0102e1c:	e8 2d e4 ff ff       	call   f010124e <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e21:	89 f8                	mov    %edi,%eax
f0102e23:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f0102e29:	c1 f8 03             	sar    $0x3,%eax
f0102e2c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e2f:	89 c2                	mov    %eax,%edx
f0102e31:	c1 ea 0c             	shr    $0xc,%edx
f0102e34:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0102e3a:	72 20                	jb     f0102e5c <mem_init+0x192c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e3c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e40:	c7 44 24 08 08 49 10 	movl   $0xf0104908,0x8(%esp)
f0102e47:	f0 
f0102e48:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102e4f:	00 
f0102e50:	c7 04 24 90 50 10 f0 	movl   $0xf0105090,(%esp)
f0102e57:	e8 95 d2 ff ff       	call   f01000f1 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102e5c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102e63:	00 
f0102e64:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102e6b:	00 
	return (void *)(pa + KERNBASE);
f0102e6c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e71:	89 04 24             	mov    %eax,(%esp)
f0102e74:	e8 28 0f 00 00       	call   f0103da1 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e79:	89 d8                	mov    %ebx,%eax
f0102e7b:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f0102e81:	c1 f8 03             	sar    $0x3,%eax
f0102e84:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e87:	89 c2                	mov    %eax,%edx
f0102e89:	c1 ea 0c             	shr    $0xc,%edx
f0102e8c:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0102e92:	72 20                	jb     f0102eb4 <mem_init+0x1984>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e94:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e98:	c7 44 24 08 08 49 10 	movl   $0xf0104908,0x8(%esp)
f0102e9f:	f0 
f0102ea0:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102ea7:	00 
f0102ea8:	c7 04 24 90 50 10 f0 	movl   $0xf0105090,(%esp)
f0102eaf:	e8 3d d2 ff ff       	call   f01000f1 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102eb4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102ebb:	00 
f0102ebc:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102ec3:	00 
	return (void *)(pa + KERNBASE);
f0102ec4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ec9:	89 04 24             	mov    %eax,(%esp)
f0102ecc:	e8 d0 0e 00 00       	call   f0103da1 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102ed1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102ed8:	00 
f0102ed9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102ee0:	00 
f0102ee1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102ee5:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102eea:	89 04 24             	mov    %eax,(%esp)
f0102eed:	e8 c2 e5 ff ff       	call   f01014b4 <page_insert>
	assert(pp1->pp_ref == 1);
f0102ef2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ef7:	74 24                	je     f0102f1d <mem_init+0x19ed>
f0102ef9:	c7 44 24 0c c3 52 10 	movl   $0xf01052c3,0xc(%esp)
f0102f00:	f0 
f0102f01:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102f08:	f0 
f0102f09:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0102f10:	00 
f0102f11:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102f18:	e8 d4 d1 ff ff       	call   f01000f1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f1d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102f24:	01 01 01 
f0102f27:	74 24                	je     f0102f4d <mem_init+0x1a1d>
f0102f29:	c7 44 24 0c b8 4f 10 	movl   $0xf0104fb8,0xc(%esp)
f0102f30:	f0 
f0102f31:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102f38:	f0 
f0102f39:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102f40:	00 
f0102f41:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102f48:	e8 a4 d1 ff ff       	call   f01000f1 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102f4d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102f54:	00 
f0102f55:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102f5c:	00 
f0102f5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102f61:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0102f66:	89 04 24             	mov    %eax,(%esp)
f0102f69:	e8 46 e5 ff ff       	call   f01014b4 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102f6e:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102f75:	02 02 02 
f0102f78:	74 24                	je     f0102f9e <mem_init+0x1a6e>
f0102f7a:	c7 44 24 0c dc 4f 10 	movl   $0xf0104fdc,0xc(%esp)
f0102f81:	f0 
f0102f82:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102f89:	f0 
f0102f8a:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0102f91:	00 
f0102f92:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102f99:	e8 53 d1 ff ff       	call   f01000f1 <_panic>
	assert(pp2->pp_ref == 1);
f0102f9e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102fa3:	74 24                	je     f0102fc9 <mem_init+0x1a99>
f0102fa5:	c7 44 24 0c e5 52 10 	movl   $0xf01052e5,0xc(%esp)
f0102fac:	f0 
f0102fad:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102fb4:	f0 
f0102fb5:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0102fbc:	00 
f0102fbd:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102fc4:	e8 28 d1 ff ff       	call   f01000f1 <_panic>
	assert(pp1->pp_ref == 0);
f0102fc9:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102fce:	74 24                	je     f0102ff4 <mem_init+0x1ac4>
f0102fd0:	c7 44 24 0c 5a 53 10 	movl   $0xf010535a,0xc(%esp)
f0102fd7:	f0 
f0102fd8:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0102fdf:	f0 
f0102fe0:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0102fe7:	00 
f0102fe8:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0102fef:	e8 fd d0 ff ff       	call   f01000f1 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102ff4:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102ffb:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ffe:	89 d8                	mov    %ebx,%eax
f0103000:	2b 05 50 89 11 f0    	sub    0xf0118950,%eax
f0103006:	c1 f8 03             	sar    $0x3,%eax
f0103009:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010300c:	89 c2                	mov    %eax,%edx
f010300e:	c1 ea 0c             	shr    $0xc,%edx
f0103011:	3b 15 48 89 11 f0    	cmp    0xf0118948,%edx
f0103017:	72 20                	jb     f0103039 <mem_init+0x1b09>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103019:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010301d:	c7 44 24 08 08 49 10 	movl   $0xf0104908,0x8(%esp)
f0103024:	f0 
f0103025:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010302c:	00 
f010302d:	c7 04 24 90 50 10 f0 	movl   $0xf0105090,(%esp)
f0103034:	e8 b8 d0 ff ff       	call   f01000f1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103039:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103040:	03 03 03 
f0103043:	74 24                	je     f0103069 <mem_init+0x1b39>
f0103045:	c7 44 24 0c 00 50 10 	movl   $0xf0105000,0xc(%esp)
f010304c:	f0 
f010304d:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0103054:	f0 
f0103055:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f010305c:	00 
f010305d:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0103064:	e8 88 d0 ff ff       	call   f01000f1 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103069:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103070:	00 
f0103071:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f0103076:	89 04 24             	mov    %eax,(%esp)
f0103079:	e8 de e3 ff ff       	call   f010145c <page_remove>
	assert(pp2->pp_ref == 0);
f010307e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103083:	74 24                	je     f01030a9 <mem_init+0x1b79>
f0103085:	c7 44 24 0c 49 53 10 	movl   $0xf0105349,0xc(%esp)
f010308c:	f0 
f010308d:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0103094:	f0 
f0103095:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f010309c:	00 
f010309d:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01030a4:	e8 48 d0 ff ff       	call   f01000f1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01030a9:	a1 4c 89 11 f0       	mov    0xf011894c,%eax
f01030ae:	8b 08                	mov    (%eax),%ecx
f01030b0:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01030b6:	89 f2                	mov    %esi,%edx
f01030b8:	2b 15 50 89 11 f0    	sub    0xf0118950,%edx
f01030be:	c1 fa 03             	sar    $0x3,%edx
f01030c1:	c1 e2 0c             	shl    $0xc,%edx
f01030c4:	39 d1                	cmp    %edx,%ecx
f01030c6:	74 24                	je     f01030ec <mem_init+0x1bbc>
f01030c8:	c7 44 24 0c 7c 4b 10 	movl   $0xf0104b7c,0xc(%esp)
f01030cf:	f0 
f01030d0:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f01030d7:	f0 
f01030d8:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f01030df:	00 
f01030e0:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f01030e7:	e8 05 d0 ff ff       	call   f01000f1 <_panic>
	kern_pgdir[0] = 0;
f01030ec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01030f2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01030f7:	74 24                	je     f010311d <mem_init+0x1bed>
f01030f9:	c7 44 24 0c d4 52 10 	movl   $0xf01052d4,0xc(%esp)
f0103100:	f0 
f0103101:	c7 44 24 08 aa 50 10 	movl   $0xf01050aa,0x8(%esp)
f0103108:	f0 
f0103109:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0103110:	00 
f0103111:	c7 04 24 58 50 10 f0 	movl   $0xf0105058,(%esp)
f0103118:	e8 d4 cf ff ff       	call   f01000f1 <_panic>
	pp0->pp_ref = 0;
f010311d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103123:	89 34 24             	mov    %esi,(%esp)
f0103126:	e8 23 e1 ff ff       	call   f010124e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010312b:	c7 04 24 2c 50 10 f0 	movl   $0xf010502c,(%esp)
f0103132:	e8 8b 00 00 00       	call   f01031c2 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103137:	83 c4 4c             	add    $0x4c,%esp
f010313a:	5b                   	pop    %ebx
f010313b:	5e                   	pop    %esi
f010313c:	5f                   	pop    %edi
f010313d:	5d                   	pop    %ebp
f010313e:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010313f:	89 f2                	mov    %esi,%edx
f0103141:	89 d8                	mov    %ebx,%eax
f0103143:	e8 00 db ff ff       	call   f0100c48 <check_va2pa>
f0103148:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010314e:	e9 81 fa ff ff       	jmp    f0102bd4 <mem_init+0x16a4>
	...

f0103154 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103154:	55                   	push   %ebp
f0103155:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103157:	ba 70 00 00 00       	mov    $0x70,%edx
f010315c:	8b 45 08             	mov    0x8(%ebp),%eax
f010315f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103160:	b2 71                	mov    $0x71,%dl
f0103162:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103163:	0f b6 c0             	movzbl %al,%eax
}
f0103166:	5d                   	pop    %ebp
f0103167:	c3                   	ret    

f0103168 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103168:	55                   	push   %ebp
f0103169:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010316b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103170:	8b 45 08             	mov    0x8(%ebp),%eax
f0103173:	ee                   	out    %al,(%dx)
f0103174:	b2 71                	mov    $0x71,%dl
f0103176:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103179:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010317a:	5d                   	pop    %ebp
f010317b:	c3                   	ret    

f010317c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010317c:	55                   	push   %ebp
f010317d:	89 e5                	mov    %esp,%ebp
f010317f:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103182:	8b 45 08             	mov    0x8(%ebp),%eax
f0103185:	89 04 24             	mov    %eax,(%esp)
f0103188:	e8 e4 d4 ff ff       	call   f0100671 <cputchar>
	*cnt++;
}
f010318d:	c9                   	leave  
f010318e:	c3                   	ret    

f010318f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010318f:	55                   	push   %ebp
f0103190:	89 e5                	mov    %esp,%ebp
f0103192:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103195:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010319c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010319f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01031a6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01031aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01031ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031b1:	c7 04 24 7c 31 10 f0 	movl   $0xf010317c,(%esp)
f01031b8:	e8 24 05 00 00       	call   f01036e1 <vprintfmt>
	return cnt;
}
f01031bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01031c0:	c9                   	leave  
f01031c1:	c3                   	ret    

f01031c2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01031c2:	55                   	push   %ebp
f01031c3:	89 e5                	mov    %esp,%ebp
f01031c5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01031c8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01031cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01031d2:	89 04 24             	mov    %eax,(%esp)
f01031d5:	e8 b5 ff ff ff       	call   f010318f <vcprintf>
	va_end(ap);

	return cnt;
}
f01031da:	c9                   	leave  
f01031db:	c3                   	ret    
f01031dc:	00 00                	add    %al,(%eax)
	...

f01031e0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01031e0:	55                   	push   %ebp
f01031e1:	89 e5                	mov    %esp,%ebp
f01031e3:	57                   	push   %edi
f01031e4:	56                   	push   %esi
f01031e5:	53                   	push   %ebx
f01031e6:	83 ec 14             	sub    $0x14,%esp
f01031e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01031ec:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01031ef:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01031f2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01031f5:	8b 1a                	mov    (%edx),%ebx
f01031f7:	8b 01                	mov    (%ecx),%eax
f01031f9:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f01031fc:	39 c3                	cmp    %eax,%ebx
f01031fe:	0f 8f 9c 00 00 00    	jg     f01032a0 <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0103204:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010320b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010320e:	01 d8                	add    %ebx,%eax
f0103210:	89 c7                	mov    %eax,%edi
f0103212:	c1 ef 1f             	shr    $0x1f,%edi
f0103215:	01 c7                	add    %eax,%edi
f0103217:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103219:	39 df                	cmp    %ebx,%edi
f010321b:	7c 33                	jl     f0103250 <stab_binsearch+0x70>
f010321d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103220:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103223:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103228:	39 f0                	cmp    %esi,%eax
f010322a:	0f 84 bc 00 00 00    	je     f01032ec <stab_binsearch+0x10c>
f0103230:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103234:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103238:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010323a:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010323d:	39 d8                	cmp    %ebx,%eax
f010323f:	7c 0f                	jl     f0103250 <stab_binsearch+0x70>
f0103241:	0f b6 0a             	movzbl (%edx),%ecx
f0103244:	83 ea 0c             	sub    $0xc,%edx
f0103247:	39 f1                	cmp    %esi,%ecx
f0103249:	75 ef                	jne    f010323a <stab_binsearch+0x5a>
f010324b:	e9 9e 00 00 00       	jmp    f01032ee <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103250:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103253:	eb 3c                	jmp    f0103291 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103255:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103258:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f010325a:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010325d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103264:	eb 2b                	jmp    f0103291 <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103266:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103269:	76 14                	jbe    f010327f <stab_binsearch+0x9f>
			*region_right = m - 1;
f010326b:	83 e8 01             	sub    $0x1,%eax
f010326e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103271:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103274:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103276:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010327d:	eb 12                	jmp    f0103291 <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010327f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103282:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103284:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103288:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010328a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103291:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103294:	0f 8d 71 ff ff ff    	jge    f010320b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010329a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010329e:	75 0f                	jne    f01032af <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f01032a0:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01032a3:	8b 03                	mov    (%ebx),%eax
f01032a5:	83 e8 01             	sub    $0x1,%eax
f01032a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01032ab:	89 02                	mov    %eax,(%edx)
f01032ad:	eb 57                	jmp    f0103306 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01032af:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01032b2:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01032b4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01032b7:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01032b9:	39 c1                	cmp    %eax,%ecx
f01032bb:	7d 28                	jge    f01032e5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01032bd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01032c0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01032c3:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01032c8:	39 f2                	cmp    %esi,%edx
f01032ca:	74 19                	je     f01032e5 <stab_binsearch+0x105>
f01032cc:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01032d0:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01032d4:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01032d7:	39 c1                	cmp    %eax,%ecx
f01032d9:	7d 0a                	jge    f01032e5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01032db:	0f b6 1a             	movzbl (%edx),%ebx
f01032de:	83 ea 0c             	sub    $0xc,%edx
f01032e1:	39 f3                	cmp    %esi,%ebx
f01032e3:	75 ef                	jne    f01032d4 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f01032e5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01032e8:	89 02                	mov    %eax,(%edx)
f01032ea:	eb 1a                	jmp    f0103306 <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01032ec:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01032ee:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01032f1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01032f4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01032f8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01032fb:	0f 82 54 ff ff ff    	jb     f0103255 <stab_binsearch+0x75>
f0103301:	e9 60 ff ff ff       	jmp    f0103266 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103306:	83 c4 14             	add    $0x14,%esp
f0103309:	5b                   	pop    %ebx
f010330a:	5e                   	pop    %esi
f010330b:	5f                   	pop    %edi
f010330c:	5d                   	pop    %ebp
f010330d:	c3                   	ret    

f010330e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010330e:	55                   	push   %ebp
f010330f:	89 e5                	mov    %esp,%ebp
f0103311:	83 ec 58             	sub    $0x58,%esp
f0103314:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103317:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010331a:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010331d:	8b 75 08             	mov    0x8(%ebp),%esi
f0103320:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103323:	c7 03 09 54 10 f0    	movl   $0xf0105409,(%ebx)
	info->eip_line = 0;
f0103329:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103330:	c7 43 08 09 54 10 f0 	movl   $0xf0105409,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103337:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010333e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103341:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103348:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010334e:	76 12                	jbe    f0103362 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103350:	b8 f3 dc 10 f0       	mov    $0xf010dcf3,%eax
f0103355:	3d c9 bd 10 f0       	cmp    $0xf010bdc9,%eax
f010335a:	0f 86 a9 01 00 00    	jbe    f0103509 <debuginfo_eip+0x1fb>
f0103360:	eb 1c                	jmp    f010337e <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0103362:	c7 44 24 08 13 54 10 	movl   $0xf0105413,0x8(%esp)
f0103369:	f0 
f010336a:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0103371:	00 
f0103372:	c7 04 24 20 54 10 f0 	movl   $0xf0105420,(%esp)
f0103379:	e8 73 cd ff ff       	call   f01000f1 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010337e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103383:	80 3d f2 dc 10 f0 00 	cmpb   $0x0,0xf010dcf2
f010338a:	0f 85 85 01 00 00    	jne    f0103515 <debuginfo_eip+0x207>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103390:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103397:	b8 c8 bd 10 f0       	mov    $0xf010bdc8,%eax
f010339c:	2d 3c 56 10 f0       	sub    $0xf010563c,%eax
f01033a1:	c1 f8 02             	sar    $0x2,%eax
f01033a4:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01033aa:	83 e8 01             	sub    $0x1,%eax
f01033ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01033b0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01033b4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01033bb:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01033be:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01033c1:	b8 3c 56 10 f0       	mov    $0xf010563c,%eax
f01033c6:	e8 15 fe ff ff       	call   f01031e0 <stab_binsearch>
	if (lfile == 0)
f01033cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f01033ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01033d3:	85 d2                	test   %edx,%edx
f01033d5:	0f 84 3a 01 00 00    	je     f0103515 <debuginfo_eip+0x207>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01033db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01033de:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01033e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01033e4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01033e8:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01033ef:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01033f2:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01033f5:	b8 3c 56 10 f0       	mov    $0xf010563c,%eax
f01033fa:	e8 e1 fd ff ff       	call   f01031e0 <stab_binsearch>

	if (lfun <= rfun) {
f01033ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103402:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103405:	39 d0                	cmp    %edx,%eax
f0103407:	7f 3a                	jg     f0103443 <debuginfo_eip+0x135>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103409:	6b c8 0c             	imul   $0xc,%eax,%ecx
f010340c:	8b 89 3c 56 10 f0    	mov    -0xfefa9c4(%ecx),%ecx
f0103412:	bf f3 dc 10 f0       	mov    $0xf010dcf3,%edi
f0103417:	81 ef c9 bd 10 f0    	sub    $0xf010bdc9,%edi
f010341d:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0103420:	39 f9                	cmp    %edi,%ecx
f0103422:	73 09                	jae    f010342d <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103424:	81 c1 c9 bd 10 f0    	add    $0xf010bdc9,%ecx
f010342a:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010342d:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0103430:	8b 89 44 56 10 f0    	mov    -0xfefa9bc(%ecx),%ecx
f0103436:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103439:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010343b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010343e:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103441:	eb 0f                	jmp    f0103452 <debuginfo_eip+0x144>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103443:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103446:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103449:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010344c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010344f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103452:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0103459:	00 
f010345a:	8b 43 08             	mov    0x8(%ebx),%eax
f010345d:	89 04 24             	mov    %eax,(%esp)
f0103460:	e8 15 09 00 00       	call   f0103d7a <strfind>
f0103465:	2b 43 08             	sub    0x8(%ebx),%eax
f0103468:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010346b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010346f:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0103476:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103479:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010347c:	b8 3c 56 10 f0       	mov    $0xf010563c,%eax
f0103481:	e8 5a fd ff ff       	call   f01031e0 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0103486:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103489:	6b d0 0c             	imul   $0xc,%eax,%edx
f010348c:	0f b7 8a 42 56 10 f0 	movzwl -0xfefa9be(%edx),%ecx
f0103493:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103496:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103499:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010349c:	81 c2 44 56 10 f0    	add    $0xf0105644,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01034a2:	eb 06                	jmp    f01034aa <debuginfo_eip+0x19c>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01034a4:	83 e8 01             	sub    $0x1,%eax
f01034a7:	83 ea 0c             	sub    $0xc,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01034aa:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f01034ad:	7f 1e                	jg     f01034cd <debuginfo_eip+0x1bf>
	       && stabs[lline].n_type != N_SOL
f01034af:	0f b6 72 fc          	movzbl -0x4(%edx),%esi
f01034b3:	89 f1                	mov    %esi,%ecx
f01034b5:	80 f9 84             	cmp    $0x84,%cl
f01034b8:	74 68                	je     f0103522 <debuginfo_eip+0x214>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01034ba:	80 f9 64             	cmp    $0x64,%cl
f01034bd:	75 e5                	jne    f01034a4 <debuginfo_eip+0x196>
f01034bf:	83 3a 00             	cmpl   $0x0,(%edx)
f01034c2:	74 e0                	je     f01034a4 <debuginfo_eip+0x196>
f01034c4:	eb 5c                	jmp    f0103522 <debuginfo_eip+0x214>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01034c6:	05 c9 bd 10 f0       	add    $0xf010bdc9,%eax
f01034cb:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01034cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034d0:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01034d3:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01034d8:	39 fa                	cmp    %edi,%edx
f01034da:	7d 39                	jge    f0103515 <debuginfo_eip+0x207>
		for (lline = lfun + 1;
f01034dc:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01034df:	6b d0 0c             	imul   $0xc,%eax,%edx
f01034e2:	81 c2 40 56 10 f0    	add    $0xf0105640,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01034e8:	eb 07                	jmp    f01034f1 <debuginfo_eip+0x1e3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01034ea:	83 43 14 01          	addl   $0x1,0x14(%ebx)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01034ee:	83 c0 01             	add    $0x1,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01034f1:	39 c7                	cmp    %eax,%edi
f01034f3:	7e 1b                	jle    f0103510 <debuginfo_eip+0x202>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01034f5:	0f b6 32             	movzbl (%edx),%esi
f01034f8:	83 c2 0c             	add    $0xc,%edx
f01034fb:	89 f1                	mov    %esi,%ecx
f01034fd:	80 f9 a0             	cmp    $0xa0,%cl
f0103500:	74 e8                	je     f01034ea <debuginfo_eip+0x1dc>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103502:	b8 00 00 00 00       	mov    $0x0,%eax
f0103507:	eb 0c                	jmp    f0103515 <debuginfo_eip+0x207>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103509:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010350e:	eb 05                	jmp    f0103515 <debuginfo_eip+0x207>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103510:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103515:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103518:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010351b:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010351e:	89 ec                	mov    %ebp,%esp
f0103520:	5d                   	pop    %ebp
f0103521:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103522:	6b c0 0c             	imul   $0xc,%eax,%eax
f0103525:	8b 80 3c 56 10 f0    	mov    -0xfefa9c4(%eax),%eax
f010352b:	ba f3 dc 10 f0       	mov    $0xf010dcf3,%edx
f0103530:	81 ea c9 bd 10 f0    	sub    $0xf010bdc9,%edx
f0103536:	39 d0                	cmp    %edx,%eax
f0103538:	72 8c                	jb     f01034c6 <debuginfo_eip+0x1b8>
f010353a:	eb 91                	jmp    f01034cd <debuginfo_eip+0x1bf>
f010353c:	00 00                	add    %al,(%eax)
	...

f0103540 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103540:	55                   	push   %ebp
f0103541:	89 e5                	mov    %esp,%ebp
f0103543:	57                   	push   %edi
f0103544:	56                   	push   %esi
f0103545:	53                   	push   %ebx
f0103546:	83 ec 4c             	sub    $0x4c,%esp
f0103549:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010354c:	89 d6                	mov    %edx,%esi
f010354e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103551:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103554:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103557:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010355a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010355d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103560:	b8 00 00 00 00       	mov    $0x0,%eax
f0103565:	39 d0                	cmp    %edx,%eax
f0103567:	72 11                	jb     f010357a <printnum+0x3a>
f0103569:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010356c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
f010356f:	76 09                	jbe    f010357a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103571:	83 eb 01             	sub    $0x1,%ebx
f0103574:	85 db                	test   %ebx,%ebx
f0103576:	7f 5d                	jg     f01035d5 <printnum+0x95>
f0103578:	eb 6c                	jmp    f01035e6 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010357a:	89 7c 24 10          	mov    %edi,0x10(%esp)
f010357e:	83 eb 01             	sub    $0x1,%ebx
f0103581:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103585:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0103588:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010358c:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103590:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0103594:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103597:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010359a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01035a1:	00 
f01035a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035a5:	89 14 24             	mov    %edx,(%esp)
f01035a8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01035ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01035af:	e8 4c 0a 00 00       	call   f0104000 <__udivdi3>
f01035b4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01035b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01035ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01035be:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01035c2:	89 04 24             	mov    %eax,(%esp)
f01035c5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01035c9:	89 f2                	mov    %esi,%edx
f01035cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035ce:	e8 6d ff ff ff       	call   f0103540 <printnum>
f01035d3:	eb 11                	jmp    f01035e6 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01035d5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01035d9:	89 3c 24             	mov    %edi,(%esp)
f01035dc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01035df:	83 eb 01             	sub    $0x1,%ebx
f01035e2:	85 db                	test   %ebx,%ebx
f01035e4:	7f ef                	jg     f01035d5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01035e6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01035ea:	8b 74 24 04          	mov    0x4(%esp),%esi
f01035ee:	8b 45 10             	mov    0x10(%ebp),%eax
f01035f1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035f5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01035fc:	00 
f01035fd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103600:	89 14 24             	mov    %edx,(%esp)
f0103603:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103606:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010360a:	e8 01 0b 00 00       	call   f0104110 <__umoddi3>
f010360f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103613:	0f be 80 2e 54 10 f0 	movsbl -0xfefabd2(%eax),%eax
f010361a:	89 04 24             	mov    %eax,(%esp)
f010361d:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0103620:	83 c4 4c             	add    $0x4c,%esp
f0103623:	5b                   	pop    %ebx
f0103624:	5e                   	pop    %esi
f0103625:	5f                   	pop    %edi
f0103626:	5d                   	pop    %ebp
f0103627:	c3                   	ret    

f0103628 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103628:	55                   	push   %ebp
f0103629:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010362b:	83 fa 01             	cmp    $0x1,%edx
f010362e:	7e 0e                	jle    f010363e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103630:	8b 10                	mov    (%eax),%edx
f0103632:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103635:	89 08                	mov    %ecx,(%eax)
f0103637:	8b 02                	mov    (%edx),%eax
f0103639:	8b 52 04             	mov    0x4(%edx),%edx
f010363c:	eb 22                	jmp    f0103660 <getuint+0x38>
	else if (lflag)
f010363e:	85 d2                	test   %edx,%edx
f0103640:	74 10                	je     f0103652 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103642:	8b 10                	mov    (%eax),%edx
f0103644:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103647:	89 08                	mov    %ecx,(%eax)
f0103649:	8b 02                	mov    (%edx),%eax
f010364b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103650:	eb 0e                	jmp    f0103660 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103652:	8b 10                	mov    (%eax),%edx
f0103654:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103657:	89 08                	mov    %ecx,(%eax)
f0103659:	8b 02                	mov    (%edx),%eax
f010365b:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103660:	5d                   	pop    %ebp
f0103661:	c3                   	ret    

f0103662 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103662:	55                   	push   %ebp
f0103663:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103665:	83 fa 01             	cmp    $0x1,%edx
f0103668:	7e 0e                	jle    f0103678 <getint+0x16>
		return va_arg(*ap, long long);
f010366a:	8b 10                	mov    (%eax),%edx
f010366c:	8d 4a 08             	lea    0x8(%edx),%ecx
f010366f:	89 08                	mov    %ecx,(%eax)
f0103671:	8b 02                	mov    (%edx),%eax
f0103673:	8b 52 04             	mov    0x4(%edx),%edx
f0103676:	eb 22                	jmp    f010369a <getint+0x38>
	else if (lflag)
f0103678:	85 d2                	test   %edx,%edx
f010367a:	74 10                	je     f010368c <getint+0x2a>
		return va_arg(*ap, long);
f010367c:	8b 10                	mov    (%eax),%edx
f010367e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103681:	89 08                	mov    %ecx,(%eax)
f0103683:	8b 02                	mov    (%edx),%eax
f0103685:	89 c2                	mov    %eax,%edx
f0103687:	c1 fa 1f             	sar    $0x1f,%edx
f010368a:	eb 0e                	jmp    f010369a <getint+0x38>
	else
		return va_arg(*ap, int);
f010368c:	8b 10                	mov    (%eax),%edx
f010368e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103691:	89 08                	mov    %ecx,(%eax)
f0103693:	8b 02                	mov    (%edx),%eax
f0103695:	89 c2                	mov    %eax,%edx
f0103697:	c1 fa 1f             	sar    $0x1f,%edx
}
f010369a:	5d                   	pop    %ebp
f010369b:	c3                   	ret    

f010369c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010369c:	55                   	push   %ebp
f010369d:	89 e5                	mov    %esp,%ebp
f010369f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01036a2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01036a6:	8b 10                	mov    (%eax),%edx
f01036a8:	3b 50 04             	cmp    0x4(%eax),%edx
f01036ab:	73 0a                	jae    f01036b7 <sprintputch+0x1b>
		*b->buf++ = ch;
f01036ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01036b0:	88 0a                	mov    %cl,(%edx)
f01036b2:	83 c2 01             	add    $0x1,%edx
f01036b5:	89 10                	mov    %edx,(%eax)
}
f01036b7:	5d                   	pop    %ebp
f01036b8:	c3                   	ret    

f01036b9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01036b9:	55                   	push   %ebp
f01036ba:	89 e5                	mov    %esp,%ebp
f01036bc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01036bf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01036c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036c6:	8b 45 10             	mov    0x10(%ebp),%eax
f01036c9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01036cd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01036d7:	89 04 24             	mov    %eax,(%esp)
f01036da:	e8 02 00 00 00       	call   f01036e1 <vprintfmt>
	va_end(ap);
}
f01036df:	c9                   	leave  
f01036e0:	c3                   	ret    

f01036e1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01036e1:	55                   	push   %ebp
f01036e2:	89 e5                	mov    %esp,%ebp
f01036e4:	57                   	push   %edi
f01036e5:	56                   	push   %esi
f01036e6:	53                   	push   %ebx
f01036e7:	83 ec 4c             	sub    $0x4c,%esp
f01036ea:	8b 7d 10             	mov    0x10(%ebp),%edi
f01036ed:	eb 23                	jmp    f0103712 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
f01036ef:	85 c0                	test   %eax,%eax
f01036f1:	75 12                	jne    f0103705 <vprintfmt+0x24>
				csa = 0x0700;
f01036f3:	c7 05 44 89 11 f0 00 	movl   $0x700,0xf0118944
f01036fa:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f01036fd:	83 c4 4c             	add    $0x4c,%esp
f0103700:	5b                   	pop    %ebx
f0103701:	5e                   	pop    %esi
f0103702:	5f                   	pop    %edi
f0103703:	5d                   	pop    %ebp
f0103704:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
f0103705:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103708:	89 54 24 04          	mov    %edx,0x4(%esp)
f010370c:	89 04 24             	mov    %eax,(%esp)
f010370f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103712:	0f b6 07             	movzbl (%edi),%eax
f0103715:	83 c7 01             	add    $0x1,%edi
f0103718:	83 f8 25             	cmp    $0x25,%eax
f010371b:	75 d2                	jne    f01036ef <vprintfmt+0xe>
f010371d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0103721:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103728:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010372d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0103734:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103739:	be 00 00 00 00       	mov    $0x0,%esi
f010373e:	eb 14                	jmp    f0103754 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
f0103740:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0103744:	eb 0e                	jmp    f0103754 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103746:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f010374a:	eb 08                	jmp    f0103754 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f010374c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010374f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103754:	0f b6 07             	movzbl (%edi),%eax
f0103757:	0f b6 c8             	movzbl %al,%ecx
f010375a:	83 c7 01             	add    $0x1,%edi
f010375d:	83 e8 23             	sub    $0x23,%eax
f0103760:	3c 55                	cmp    $0x55,%al
f0103762:	0f 87 ed 02 00 00    	ja     f0103a55 <vprintfmt+0x374>
f0103768:	0f b6 c0             	movzbl %al,%eax
f010376b:	ff 24 85 b8 54 10 f0 	jmp    *-0xfefab48(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103772:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
f0103775:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0103778:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010377b:	83 f9 09             	cmp    $0x9,%ecx
f010377e:	77 3c                	ja     f01037bc <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103780:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0103783:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
f0103786:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
f010378a:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f010378d:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0103790:	83 f9 09             	cmp    $0x9,%ecx
f0103793:	76 eb                	jbe    f0103780 <vprintfmt+0x9f>
f0103795:	eb 25                	jmp    f01037bc <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103797:	8b 45 14             	mov    0x14(%ebp),%eax
f010379a:	8d 48 04             	lea    0x4(%eax),%ecx
f010379d:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01037a0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
f01037a2:	eb 18                	jmp    f01037bc <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
f01037a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01037a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01037ab:	0f 48 c6             	cmovs  %esi,%eax
f01037ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01037b1:	eb a1                	jmp    f0103754 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
f01037b3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f01037ba:	eb 98                	jmp    f0103754 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
f01037bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01037c0:	79 92                	jns    f0103754 <vprintfmt+0x73>
f01037c2:	eb 88                	jmp    f010374c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01037c4:	83 c2 01             	add    $0x1,%edx
f01037c7:	eb 8b                	jmp    f0103754 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01037c9:	8b 45 14             	mov    0x14(%ebp),%eax
f01037cc:	8d 50 04             	lea    0x4(%eax),%edx
f01037cf:	89 55 14             	mov    %edx,0x14(%ebp)
f01037d2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01037d5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01037d9:	8b 00                	mov    (%eax),%eax
f01037db:	89 04 24             	mov    %eax,(%esp)
f01037de:	ff 55 08             	call   *0x8(%ebp)
			break;
f01037e1:	e9 2c ff ff ff       	jmp    f0103712 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01037e6:	8b 45 14             	mov    0x14(%ebp),%eax
f01037e9:	8d 50 04             	lea    0x4(%eax),%edx
f01037ec:	89 55 14             	mov    %edx,0x14(%ebp)
f01037ef:	8b 00                	mov    (%eax),%eax
f01037f1:	89 c2                	mov    %eax,%edx
f01037f3:	c1 fa 1f             	sar    $0x1f,%edx
f01037f6:	31 d0                	xor    %edx,%eax
f01037f8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01037fa:	83 f8 06             	cmp    $0x6,%eax
f01037fd:	7f 0b                	jg     f010380a <vprintfmt+0x129>
f01037ff:	8b 14 85 10 56 10 f0 	mov    -0xfefa9f0(,%eax,4),%edx
f0103806:	85 d2                	test   %edx,%edx
f0103808:	75 23                	jne    f010382d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
f010380a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010380e:	c7 44 24 08 46 54 10 	movl   $0xf0105446,0x8(%esp)
f0103815:	f0 
f0103816:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103819:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010381d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103820:	89 04 24             	mov    %eax,(%esp)
f0103823:	e8 91 fe ff ff       	call   f01036b9 <printfmt>
f0103828:	e9 e5 fe ff ff       	jmp    f0103712 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
f010382d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103831:	c7 44 24 08 bc 50 10 	movl   $0xf01050bc,0x8(%esp)
f0103838:	f0 
f0103839:	8b 55 0c             	mov    0xc(%ebp),%edx
f010383c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103840:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103843:	89 1c 24             	mov    %ebx,(%esp)
f0103846:	e8 6e fe ff ff       	call   f01036b9 <printfmt>
f010384b:	e9 c2 fe ff ff       	jmp    f0103712 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103850:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103853:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103856:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103859:	8b 45 14             	mov    0x14(%ebp),%eax
f010385c:	8d 50 04             	lea    0x4(%eax),%edx
f010385f:	89 55 14             	mov    %edx,0x14(%ebp)
f0103862:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0103864:	85 f6                	test   %esi,%esi
f0103866:	ba 3f 54 10 f0       	mov    $0xf010543f,%edx
f010386b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f010386e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103872:	7e 06                	jle    f010387a <vprintfmt+0x199>
f0103874:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0103878:	75 13                	jne    f010388d <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010387a:	0f be 06             	movsbl (%esi),%eax
f010387d:	83 c6 01             	add    $0x1,%esi
f0103880:	85 c0                	test   %eax,%eax
f0103882:	0f 85 a2 00 00 00    	jne    f010392a <vprintfmt+0x249>
f0103888:	e9 92 00 00 00       	jmp    f010391f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010388d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103891:	89 34 24             	mov    %esi,(%esp)
f0103894:	e8 52 03 00 00       	call   f0103beb <strnlen>
f0103899:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010389c:	29 c2                	sub    %eax,%edx
f010389e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01038a1:	85 d2                	test   %edx,%edx
f01038a3:	7e d5                	jle    f010387a <vprintfmt+0x199>
					putch(padc, putdat);
f01038a5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
f01038a9:	89 75 d8             	mov    %esi,-0x28(%ebp)
f01038ac:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f01038af:	89 d3                	mov    %edx,%ebx
f01038b1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01038b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01038b7:	89 c6                	mov    %eax,%esi
f01038b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01038bd:	89 34 24             	mov    %esi,(%esp)
f01038c0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01038c3:	83 eb 01             	sub    $0x1,%ebx
f01038c6:	85 db                	test   %ebx,%ebx
f01038c8:	7f ef                	jg     f01038b9 <vprintfmt+0x1d8>
f01038ca:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01038cd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01038d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01038d3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01038da:	eb 9e                	jmp    f010387a <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01038dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01038e0:	74 1b                	je     f01038fd <vprintfmt+0x21c>
f01038e2:	8d 50 e0             	lea    -0x20(%eax),%edx
f01038e5:	83 fa 5e             	cmp    $0x5e,%edx
f01038e8:	76 13                	jbe    f01038fd <vprintfmt+0x21c>
					putch('?', putdat);
f01038ea:	8b 55 0c             	mov    0xc(%ebp),%edx
f01038ed:	89 54 24 04          	mov    %edx,0x4(%esp)
f01038f1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01038f8:	ff 55 08             	call   *0x8(%ebp)
f01038fb:	eb 0d                	jmp    f010390a <vprintfmt+0x229>
				else
					putch(ch, putdat);
f01038fd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103900:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103904:	89 04 24             	mov    %eax,(%esp)
f0103907:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010390a:	83 ef 01             	sub    $0x1,%edi
f010390d:	0f be 06             	movsbl (%esi),%eax
f0103910:	85 c0                	test   %eax,%eax
f0103912:	74 05                	je     f0103919 <vprintfmt+0x238>
f0103914:	83 c6 01             	add    $0x1,%esi
f0103917:	eb 17                	jmp    f0103930 <vprintfmt+0x24f>
f0103919:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f010391c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010391f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103923:	7f 1c                	jg     f0103941 <vprintfmt+0x260>
f0103925:	e9 e8 fd ff ff       	jmp    f0103712 <vprintfmt+0x31>
f010392a:	89 7d dc             	mov    %edi,-0x24(%ebp)
f010392d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103930:	85 db                	test   %ebx,%ebx
f0103932:	78 a8                	js     f01038dc <vprintfmt+0x1fb>
f0103934:	83 eb 01             	sub    $0x1,%ebx
f0103937:	79 a3                	jns    f01038dc <vprintfmt+0x1fb>
f0103939:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f010393c:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010393f:	eb de                	jmp    f010391f <vprintfmt+0x23e>
f0103941:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103944:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103947:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010394a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010394e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103955:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103957:	83 eb 01             	sub    $0x1,%ebx
f010395a:	85 db                	test   %ebx,%ebx
f010395c:	7f ec                	jg     f010394a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010395e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103961:	e9 ac fd ff ff       	jmp    f0103712 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103966:	8d 45 14             	lea    0x14(%ebp),%eax
f0103969:	e8 f4 fc ff ff       	call   f0103662 <getint>
f010396e:	89 c3                	mov    %eax,%ebx
f0103970:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0103972:	85 d2                	test   %edx,%edx
f0103974:	78 0a                	js     f0103980 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103976:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010397b:	e9 87 00 00 00       	jmp    f0103a07 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0103980:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103983:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103987:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010398e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103991:	89 d8                	mov    %ebx,%eax
f0103993:	89 f2                	mov    %esi,%edx
f0103995:	f7 d8                	neg    %eax
f0103997:	83 d2 00             	adc    $0x0,%edx
f010399a:	f7 da                	neg    %edx
			}
			base = 10;
f010399c:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01039a1:	eb 64                	jmp    f0103a07 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01039a3:	8d 45 14             	lea    0x14(%ebp),%eax
f01039a6:	e8 7d fc ff ff       	call   f0103628 <getuint>
			base = 10;
f01039ab:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01039b0:	eb 55                	jmp    f0103a07 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
f01039b2:	8d 45 14             	lea    0x14(%ebp),%eax
f01039b5:	e8 6e fc ff ff       	call   f0103628 <getuint>
      base = 8;
f01039ba:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
f01039bf:	eb 46                	jmp    f0103a07 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
f01039c1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01039c4:	89 54 24 04          	mov    %edx,0x4(%esp)
f01039c8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01039cf:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01039d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01039d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01039d9:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01039e0:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01039e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01039e6:	8d 50 04             	lea    0x4(%eax),%edx
f01039e9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01039ec:	8b 00                	mov    (%eax),%eax
f01039ee:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01039f3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01039f8:	eb 0d                	jmp    f0103a07 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01039fa:	8d 45 14             	lea    0x14(%ebp),%eax
f01039fd:	e8 26 fc ff ff       	call   f0103628 <getuint>
			base = 16;
f0103a02:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103a07:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0103a0b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0103a0f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103a12:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103a16:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103a1a:	89 04 24             	mov    %eax,(%esp)
f0103a1d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103a21:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a24:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a27:	e8 14 fb ff ff       	call   f0103540 <printnum>
			break;
f0103a2c:	e9 e1 fc ff ff       	jmp    f0103712 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103a31:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a34:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a38:	89 0c 24             	mov    %ecx,(%esp)
f0103a3b:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103a3e:	e9 cf fc ff ff       	jmp    f0103712 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
f0103a43:	8d 45 14             	lea    0x14(%ebp),%eax
f0103a46:	e8 17 fc ff ff       	call   f0103662 <getint>
			csa = num;
f0103a4b:	a3 44 89 11 f0       	mov    %eax,0xf0118944
			break;
f0103a50:	e9 bd fc ff ff       	jmp    f0103712 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103a55:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a58:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103a5c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103a63:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103a66:	83 ef 01             	sub    $0x1,%edi
f0103a69:	eb 02                	jmp    f0103a6d <vprintfmt+0x38c>
f0103a6b:	89 c7                	mov    %eax,%edi
f0103a6d:	8d 47 ff             	lea    -0x1(%edi),%eax
f0103a70:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103a74:	75 f5                	jne    f0103a6b <vprintfmt+0x38a>
f0103a76:	e9 97 fc ff ff       	jmp    f0103712 <vprintfmt+0x31>

f0103a7b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103a7b:	55                   	push   %ebp
f0103a7c:	89 e5                	mov    %esp,%ebp
f0103a7e:	83 ec 28             	sub    $0x28,%esp
f0103a81:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a84:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103a87:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103a8a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103a8e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103a91:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103a98:	85 c0                	test   %eax,%eax
f0103a9a:	74 30                	je     f0103acc <vsnprintf+0x51>
f0103a9c:	85 d2                	test   %edx,%edx
f0103a9e:	7e 2c                	jle    f0103acc <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103aa0:	8b 45 14             	mov    0x14(%ebp),%eax
f0103aa3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103aa7:	8b 45 10             	mov    0x10(%ebp),%eax
f0103aaa:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103aae:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ab5:	c7 04 24 9c 36 10 f0 	movl   $0xf010369c,(%esp)
f0103abc:	e8 20 fc ff ff       	call   f01036e1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103ac1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103ac4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103aca:	eb 05                	jmp    f0103ad1 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103acc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103ad1:	c9                   	leave  
f0103ad2:	c3                   	ret    

f0103ad3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103ad3:	55                   	push   %ebp
f0103ad4:	89 e5                	mov    %esp,%ebp
f0103ad6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103ad9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103adc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ae0:	8b 45 10             	mov    0x10(%ebp),%eax
f0103ae3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103aea:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103aee:	8b 45 08             	mov    0x8(%ebp),%eax
f0103af1:	89 04 24             	mov    %eax,(%esp)
f0103af4:	e8 82 ff ff ff       	call   f0103a7b <vsnprintf>
	va_end(ap);

	return rc;
}
f0103af9:	c9                   	leave  
f0103afa:	c3                   	ret    
f0103afb:	00 00                	add    %al,(%eax)
f0103afd:	00 00                	add    %al,(%eax)
	...

f0103b00 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103b00:	55                   	push   %ebp
f0103b01:	89 e5                	mov    %esp,%ebp
f0103b03:	57                   	push   %edi
f0103b04:	56                   	push   %esi
f0103b05:	53                   	push   %ebx
f0103b06:	83 ec 1c             	sub    $0x1c,%esp
f0103b09:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103b0c:	85 c0                	test   %eax,%eax
f0103b0e:	74 10                	je     f0103b20 <readline+0x20>
		cprintf("%s", prompt);
f0103b10:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b14:	c7 04 24 bc 50 10 f0 	movl   $0xf01050bc,(%esp)
f0103b1b:	e8 a2 f6 ff ff       	call   f01031c2 <cprintf>

	i = 0;
	echoing = iscons(0);
f0103b20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103b27:	e8 66 cb ff ff       	call   f0100692 <iscons>
f0103b2c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103b2e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103b33:	e8 49 cb ff ff       	call   f0100681 <getchar>
f0103b38:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103b3a:	85 c0                	test   %eax,%eax
f0103b3c:	79 17                	jns    f0103b55 <readline+0x55>
			cprintf("read error: %e\n", c);
f0103b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b42:	c7 04 24 2c 56 10 f0 	movl   $0xf010562c,(%esp)
f0103b49:	e8 74 f6 ff ff       	call   f01031c2 <cprintf>
			return NULL;
f0103b4e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b53:	eb 6d                	jmp    f0103bc2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103b55:	83 f8 08             	cmp    $0x8,%eax
f0103b58:	74 05                	je     f0103b5f <readline+0x5f>
f0103b5a:	83 f8 7f             	cmp    $0x7f,%eax
f0103b5d:	75 19                	jne    f0103b78 <readline+0x78>
f0103b5f:	85 f6                	test   %esi,%esi
f0103b61:	7e 15                	jle    f0103b78 <readline+0x78>
			if (echoing)
f0103b63:	85 ff                	test   %edi,%edi
f0103b65:	74 0c                	je     f0103b73 <readline+0x73>
				cputchar('\b');
f0103b67:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0103b6e:	e8 fe ca ff ff       	call   f0100671 <cputchar>
			i--;
f0103b73:	83 ee 01             	sub    $0x1,%esi
f0103b76:	eb bb                	jmp    f0103b33 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103b78:	83 fb 1f             	cmp    $0x1f,%ebx
f0103b7b:	7e 1f                	jle    f0103b9c <readline+0x9c>
f0103b7d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103b83:	7f 17                	jg     f0103b9c <readline+0x9c>
			if (echoing)
f0103b85:	85 ff                	test   %edi,%edi
f0103b87:	74 08                	je     f0103b91 <readline+0x91>
				cputchar(c);
f0103b89:	89 1c 24             	mov    %ebx,(%esp)
f0103b8c:	e8 e0 ca ff ff       	call   f0100671 <cputchar>
			buf[i++] = c;
f0103b91:	88 9e 40 85 11 f0    	mov    %bl,-0xfee7ac0(%esi)
f0103b97:	83 c6 01             	add    $0x1,%esi
f0103b9a:	eb 97                	jmp    f0103b33 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0103b9c:	83 fb 0a             	cmp    $0xa,%ebx
f0103b9f:	74 05                	je     f0103ba6 <readline+0xa6>
f0103ba1:	83 fb 0d             	cmp    $0xd,%ebx
f0103ba4:	75 8d                	jne    f0103b33 <readline+0x33>
			if (echoing)
f0103ba6:	85 ff                	test   %edi,%edi
f0103ba8:	74 0c                	je     f0103bb6 <readline+0xb6>
				cputchar('\n');
f0103baa:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0103bb1:	e8 bb ca ff ff       	call   f0100671 <cputchar>
			buf[i] = 0;
f0103bb6:	c6 86 40 85 11 f0 00 	movb   $0x0,-0xfee7ac0(%esi)
			return buf;
f0103bbd:	b8 40 85 11 f0       	mov    $0xf0118540,%eax
		}
	}
}
f0103bc2:	83 c4 1c             	add    $0x1c,%esp
f0103bc5:	5b                   	pop    %ebx
f0103bc6:	5e                   	pop    %esi
f0103bc7:	5f                   	pop    %edi
f0103bc8:	5d                   	pop    %ebp
f0103bc9:	c3                   	ret    
f0103bca:	00 00                	add    %al,(%eax)
f0103bcc:	00 00                	add    %al,(%eax)
	...

f0103bd0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103bd0:	55                   	push   %ebp
f0103bd1:	89 e5                	mov    %esp,%ebp
f0103bd3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103bd6:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bdb:	80 3a 00             	cmpb   $0x0,(%edx)
f0103bde:	74 09                	je     f0103be9 <strlen+0x19>
		n++;
f0103be0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103be3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103be7:	75 f7                	jne    f0103be0 <strlen+0x10>
		n++;
	return n;
}
f0103be9:	5d                   	pop    %ebp
f0103bea:	c3                   	ret    

f0103beb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103beb:	55                   	push   %ebp
f0103bec:	89 e5                	mov    %esp,%ebp
f0103bee:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103bf1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103bf4:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bf9:	85 d2                	test   %edx,%edx
f0103bfb:	74 12                	je     f0103c0f <strnlen+0x24>
f0103bfd:	80 39 00             	cmpb   $0x0,(%ecx)
f0103c00:	74 0d                	je     f0103c0f <strnlen+0x24>
		n++;
f0103c02:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103c05:	39 d0                	cmp    %edx,%eax
f0103c07:	74 06                	je     f0103c0f <strnlen+0x24>
f0103c09:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103c0d:	75 f3                	jne    f0103c02 <strnlen+0x17>
		n++;
	return n;
}
f0103c0f:	5d                   	pop    %ebp
f0103c10:	c3                   	ret    

f0103c11 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103c11:	55                   	push   %ebp
f0103c12:	89 e5                	mov    %esp,%ebp
f0103c14:	53                   	push   %ebx
f0103c15:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103c1b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103c20:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0103c24:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103c27:	83 c2 01             	add    $0x1,%edx
f0103c2a:	84 c9                	test   %cl,%cl
f0103c2c:	75 f2                	jne    f0103c20 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103c2e:	5b                   	pop    %ebx
f0103c2f:	5d                   	pop    %ebp
f0103c30:	c3                   	ret    

f0103c31 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103c31:	55                   	push   %ebp
f0103c32:	89 e5                	mov    %esp,%ebp
f0103c34:	53                   	push   %ebx
f0103c35:	83 ec 08             	sub    $0x8,%esp
f0103c38:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103c3b:	89 1c 24             	mov    %ebx,(%esp)
f0103c3e:	e8 8d ff ff ff       	call   f0103bd0 <strlen>
	strcpy(dst + len, src);
f0103c43:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103c46:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103c4a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0103c4d:	89 04 24             	mov    %eax,(%esp)
f0103c50:	e8 bc ff ff ff       	call   f0103c11 <strcpy>
	return dst;
}
f0103c55:	89 d8                	mov    %ebx,%eax
f0103c57:	83 c4 08             	add    $0x8,%esp
f0103c5a:	5b                   	pop    %ebx
f0103c5b:	5d                   	pop    %ebp
f0103c5c:	c3                   	ret    

f0103c5d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103c5d:	55                   	push   %ebp
f0103c5e:	89 e5                	mov    %esp,%ebp
f0103c60:	56                   	push   %esi
f0103c61:	53                   	push   %ebx
f0103c62:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c65:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103c68:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103c6b:	85 f6                	test   %esi,%esi
f0103c6d:	74 18                	je     f0103c87 <strncpy+0x2a>
f0103c6f:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103c74:	0f b6 1a             	movzbl (%edx),%ebx
f0103c77:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103c7a:	80 3a 01             	cmpb   $0x1,(%edx)
f0103c7d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103c80:	83 c1 01             	add    $0x1,%ecx
f0103c83:	39 ce                	cmp    %ecx,%esi
f0103c85:	77 ed                	ja     f0103c74 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103c87:	5b                   	pop    %ebx
f0103c88:	5e                   	pop    %esi
f0103c89:	5d                   	pop    %ebp
f0103c8a:	c3                   	ret    

f0103c8b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103c8b:	55                   	push   %ebp
f0103c8c:	89 e5                	mov    %esp,%ebp
f0103c8e:	56                   	push   %esi
f0103c8f:	53                   	push   %ebx
f0103c90:	8b 75 08             	mov    0x8(%ebp),%esi
f0103c93:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103c96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103c99:	89 f0                	mov    %esi,%eax
f0103c9b:	85 c9                	test   %ecx,%ecx
f0103c9d:	74 23                	je     f0103cc2 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
f0103c9f:	83 e9 01             	sub    $0x1,%ecx
f0103ca2:	74 1b                	je     f0103cbf <strlcpy+0x34>
f0103ca4:	0f b6 1a             	movzbl (%edx),%ebx
f0103ca7:	84 db                	test   %bl,%bl
f0103ca9:	74 14                	je     f0103cbf <strlcpy+0x34>
			*dst++ = *src++;
f0103cab:	88 18                	mov    %bl,(%eax)
f0103cad:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103cb0:	83 e9 01             	sub    $0x1,%ecx
f0103cb3:	74 0a                	je     f0103cbf <strlcpy+0x34>
			*dst++ = *src++;
f0103cb5:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103cb8:	0f b6 1a             	movzbl (%edx),%ebx
f0103cbb:	84 db                	test   %bl,%bl
f0103cbd:	75 ec                	jne    f0103cab <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
f0103cbf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103cc2:	29 f0                	sub    %esi,%eax
}
f0103cc4:	5b                   	pop    %ebx
f0103cc5:	5e                   	pop    %esi
f0103cc6:	5d                   	pop    %ebp
f0103cc7:	c3                   	ret    

f0103cc8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103cc8:	55                   	push   %ebp
f0103cc9:	89 e5                	mov    %esp,%ebp
f0103ccb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103cce:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103cd1:	0f b6 01             	movzbl (%ecx),%eax
f0103cd4:	84 c0                	test   %al,%al
f0103cd6:	74 15                	je     f0103ced <strcmp+0x25>
f0103cd8:	3a 02                	cmp    (%edx),%al
f0103cda:	75 11                	jne    f0103ced <strcmp+0x25>
		p++, q++;
f0103cdc:	83 c1 01             	add    $0x1,%ecx
f0103cdf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103ce2:	0f b6 01             	movzbl (%ecx),%eax
f0103ce5:	84 c0                	test   %al,%al
f0103ce7:	74 04                	je     f0103ced <strcmp+0x25>
f0103ce9:	3a 02                	cmp    (%edx),%al
f0103ceb:	74 ef                	je     f0103cdc <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103ced:	0f b6 c0             	movzbl %al,%eax
f0103cf0:	0f b6 12             	movzbl (%edx),%edx
f0103cf3:	29 d0                	sub    %edx,%eax
}
f0103cf5:	5d                   	pop    %ebp
f0103cf6:	c3                   	ret    

f0103cf7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103cf7:	55                   	push   %ebp
f0103cf8:	89 e5                	mov    %esp,%ebp
f0103cfa:	53                   	push   %ebx
f0103cfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103cfe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103d01:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103d04:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103d09:	85 d2                	test   %edx,%edx
f0103d0b:	74 28                	je     f0103d35 <strncmp+0x3e>
f0103d0d:	0f b6 01             	movzbl (%ecx),%eax
f0103d10:	84 c0                	test   %al,%al
f0103d12:	74 24                	je     f0103d38 <strncmp+0x41>
f0103d14:	3a 03                	cmp    (%ebx),%al
f0103d16:	75 20                	jne    f0103d38 <strncmp+0x41>
f0103d18:	83 ea 01             	sub    $0x1,%edx
f0103d1b:	74 13                	je     f0103d30 <strncmp+0x39>
		n--, p++, q++;
f0103d1d:	83 c1 01             	add    $0x1,%ecx
f0103d20:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103d23:	0f b6 01             	movzbl (%ecx),%eax
f0103d26:	84 c0                	test   %al,%al
f0103d28:	74 0e                	je     f0103d38 <strncmp+0x41>
f0103d2a:	3a 03                	cmp    (%ebx),%al
f0103d2c:	74 ea                	je     f0103d18 <strncmp+0x21>
f0103d2e:	eb 08                	jmp    f0103d38 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103d30:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103d35:	5b                   	pop    %ebx
f0103d36:	5d                   	pop    %ebp
f0103d37:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103d38:	0f b6 01             	movzbl (%ecx),%eax
f0103d3b:	0f b6 13             	movzbl (%ebx),%edx
f0103d3e:	29 d0                	sub    %edx,%eax
f0103d40:	eb f3                	jmp    f0103d35 <strncmp+0x3e>

f0103d42 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103d42:	55                   	push   %ebp
f0103d43:	89 e5                	mov    %esp,%ebp
f0103d45:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d48:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103d4c:	0f b6 10             	movzbl (%eax),%edx
f0103d4f:	84 d2                	test   %dl,%dl
f0103d51:	74 20                	je     f0103d73 <strchr+0x31>
		if (*s == c)
f0103d53:	38 ca                	cmp    %cl,%dl
f0103d55:	75 0b                	jne    f0103d62 <strchr+0x20>
f0103d57:	eb 1f                	jmp    f0103d78 <strchr+0x36>
f0103d59:	38 ca                	cmp    %cl,%dl
f0103d5b:	90                   	nop
f0103d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103d60:	74 16                	je     f0103d78 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103d62:	83 c0 01             	add    $0x1,%eax
f0103d65:	0f b6 10             	movzbl (%eax),%edx
f0103d68:	84 d2                	test   %dl,%dl
f0103d6a:	75 ed                	jne    f0103d59 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0103d6c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d71:	eb 05                	jmp    f0103d78 <strchr+0x36>
f0103d73:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d78:	5d                   	pop    %ebp
f0103d79:	c3                   	ret    

f0103d7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103d7a:	55                   	push   %ebp
f0103d7b:	89 e5                	mov    %esp,%ebp
f0103d7d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103d84:	0f b6 10             	movzbl (%eax),%edx
f0103d87:	84 d2                	test   %dl,%dl
f0103d89:	74 14                	je     f0103d9f <strfind+0x25>
		if (*s == c)
f0103d8b:	38 ca                	cmp    %cl,%dl
f0103d8d:	75 06                	jne    f0103d95 <strfind+0x1b>
f0103d8f:	eb 0e                	jmp    f0103d9f <strfind+0x25>
f0103d91:	38 ca                	cmp    %cl,%dl
f0103d93:	74 0a                	je     f0103d9f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103d95:	83 c0 01             	add    $0x1,%eax
f0103d98:	0f b6 10             	movzbl (%eax),%edx
f0103d9b:	84 d2                	test   %dl,%dl
f0103d9d:	75 f2                	jne    f0103d91 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0103d9f:	5d                   	pop    %ebp
f0103da0:	c3                   	ret    

f0103da1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103da1:	55                   	push   %ebp
f0103da2:	89 e5                	mov    %esp,%ebp
f0103da4:	83 ec 0c             	sub    $0xc,%esp
f0103da7:	89 1c 24             	mov    %ebx,(%esp)
f0103daa:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103dae:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103db2:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103db5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103db8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103dbb:	85 c9                	test   %ecx,%ecx
f0103dbd:	74 30                	je     f0103def <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103dbf:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103dc5:	75 25                	jne    f0103dec <memset+0x4b>
f0103dc7:	f6 c1 03             	test   $0x3,%cl
f0103dca:	75 20                	jne    f0103dec <memset+0x4b>
		c &= 0xFF;
f0103dcc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103dcf:	89 d3                	mov    %edx,%ebx
f0103dd1:	c1 e3 08             	shl    $0x8,%ebx
f0103dd4:	89 d6                	mov    %edx,%esi
f0103dd6:	c1 e6 18             	shl    $0x18,%esi
f0103dd9:	89 d0                	mov    %edx,%eax
f0103ddb:	c1 e0 10             	shl    $0x10,%eax
f0103dde:	09 f0                	or     %esi,%eax
f0103de0:	09 d0                	or     %edx,%eax
f0103de2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103de4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103de7:	fc                   	cld    
f0103de8:	f3 ab                	rep stos %eax,%es:(%edi)
f0103dea:	eb 03                	jmp    f0103def <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103dec:	fc                   	cld    
f0103ded:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103def:	89 f8                	mov    %edi,%eax
f0103df1:	8b 1c 24             	mov    (%esp),%ebx
f0103df4:	8b 74 24 04          	mov    0x4(%esp),%esi
f0103df8:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0103dfc:	89 ec                	mov    %ebp,%esp
f0103dfe:	5d                   	pop    %ebp
f0103dff:	c3                   	ret    

f0103e00 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103e00:	55                   	push   %ebp
f0103e01:	89 e5                	mov    %esp,%ebp
f0103e03:	83 ec 08             	sub    $0x8,%esp
f0103e06:	89 34 24             	mov    %esi,(%esp)
f0103e09:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103e0d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e10:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103e13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103e16:	39 c6                	cmp    %eax,%esi
f0103e18:	73 36                	jae    f0103e50 <memmove+0x50>
f0103e1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103e1d:	39 d0                	cmp    %edx,%eax
f0103e1f:	73 2f                	jae    f0103e50 <memmove+0x50>
		s += n;
		d += n;
f0103e21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103e24:	f6 c2 03             	test   $0x3,%dl
f0103e27:	75 1b                	jne    f0103e44 <memmove+0x44>
f0103e29:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103e2f:	75 13                	jne    f0103e44 <memmove+0x44>
f0103e31:	f6 c1 03             	test   $0x3,%cl
f0103e34:	75 0e                	jne    f0103e44 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103e36:	83 ef 04             	sub    $0x4,%edi
f0103e39:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103e3c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0103e3f:	fd                   	std    
f0103e40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103e42:	eb 09                	jmp    f0103e4d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103e44:	83 ef 01             	sub    $0x1,%edi
f0103e47:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103e4a:	fd                   	std    
f0103e4b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103e4d:	fc                   	cld    
f0103e4e:	eb 20                	jmp    f0103e70 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103e50:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103e56:	75 13                	jne    f0103e6b <memmove+0x6b>
f0103e58:	a8 03                	test   $0x3,%al
f0103e5a:	75 0f                	jne    f0103e6b <memmove+0x6b>
f0103e5c:	f6 c1 03             	test   $0x3,%cl
f0103e5f:	75 0a                	jne    f0103e6b <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103e61:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0103e64:	89 c7                	mov    %eax,%edi
f0103e66:	fc                   	cld    
f0103e67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103e69:	eb 05                	jmp    f0103e70 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103e6b:	89 c7                	mov    %eax,%edi
f0103e6d:	fc                   	cld    
f0103e6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103e70:	8b 34 24             	mov    (%esp),%esi
f0103e73:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103e77:	89 ec                	mov    %ebp,%esp
f0103e79:	5d                   	pop    %ebp
f0103e7a:	c3                   	ret    

f0103e7b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103e7b:	55                   	push   %ebp
f0103e7c:	89 e5                	mov    %esp,%ebp
f0103e7e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103e81:	8b 45 10             	mov    0x10(%ebp),%eax
f0103e84:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e88:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e8f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e92:	89 04 24             	mov    %eax,(%esp)
f0103e95:	e8 66 ff ff ff       	call   f0103e00 <memmove>
}
f0103e9a:	c9                   	leave  
f0103e9b:	c3                   	ret    

f0103e9c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103e9c:	55                   	push   %ebp
f0103e9d:	89 e5                	mov    %esp,%ebp
f0103e9f:	57                   	push   %edi
f0103ea0:	56                   	push   %esi
f0103ea1:	53                   	push   %ebx
f0103ea2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103ea5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103ea8:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103eab:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103eb0:	85 ff                	test   %edi,%edi
f0103eb2:	74 38                	je     f0103eec <memcmp+0x50>
		if (*s1 != *s2)
f0103eb4:	0f b6 03             	movzbl (%ebx),%eax
f0103eb7:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103eba:	83 ef 01             	sub    $0x1,%edi
f0103ebd:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0103ec2:	38 c8                	cmp    %cl,%al
f0103ec4:	74 1d                	je     f0103ee3 <memcmp+0x47>
f0103ec6:	eb 11                	jmp    f0103ed9 <memcmp+0x3d>
f0103ec8:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0103ecd:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
f0103ed2:	83 c2 01             	add    $0x1,%edx
f0103ed5:	38 c8                	cmp    %cl,%al
f0103ed7:	74 0a                	je     f0103ee3 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
f0103ed9:	0f b6 c0             	movzbl %al,%eax
f0103edc:	0f b6 c9             	movzbl %cl,%ecx
f0103edf:	29 c8                	sub    %ecx,%eax
f0103ee1:	eb 09                	jmp    f0103eec <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103ee3:	39 fa                	cmp    %edi,%edx
f0103ee5:	75 e1                	jne    f0103ec8 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103ee7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103eec:	5b                   	pop    %ebx
f0103eed:	5e                   	pop    %esi
f0103eee:	5f                   	pop    %edi
f0103eef:	5d                   	pop    %ebp
f0103ef0:	c3                   	ret    

f0103ef1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103ef1:	55                   	push   %ebp
f0103ef2:	89 e5                	mov    %esp,%ebp
f0103ef4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103ef7:	89 c2                	mov    %eax,%edx
f0103ef9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103efc:	39 d0                	cmp    %edx,%eax
f0103efe:	73 15                	jae    f0103f15 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103f00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0103f04:	38 08                	cmp    %cl,(%eax)
f0103f06:	75 06                	jne    f0103f0e <memfind+0x1d>
f0103f08:	eb 0b                	jmp    f0103f15 <memfind+0x24>
f0103f0a:	38 08                	cmp    %cl,(%eax)
f0103f0c:	74 07                	je     f0103f15 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103f0e:	83 c0 01             	add    $0x1,%eax
f0103f11:	39 c2                	cmp    %eax,%edx
f0103f13:	77 f5                	ja     f0103f0a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103f15:	5d                   	pop    %ebp
f0103f16:	c3                   	ret    

f0103f17 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103f17:	55                   	push   %ebp
f0103f18:	89 e5                	mov    %esp,%ebp
f0103f1a:	57                   	push   %edi
f0103f1b:	56                   	push   %esi
f0103f1c:	53                   	push   %ebx
f0103f1d:	8b 55 08             	mov    0x8(%ebp),%edx
f0103f20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103f23:	0f b6 02             	movzbl (%edx),%eax
f0103f26:	3c 20                	cmp    $0x20,%al
f0103f28:	74 04                	je     f0103f2e <strtol+0x17>
f0103f2a:	3c 09                	cmp    $0x9,%al
f0103f2c:	75 0e                	jne    f0103f3c <strtol+0x25>
		s++;
f0103f2e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103f31:	0f b6 02             	movzbl (%edx),%eax
f0103f34:	3c 20                	cmp    $0x20,%al
f0103f36:	74 f6                	je     f0103f2e <strtol+0x17>
f0103f38:	3c 09                	cmp    $0x9,%al
f0103f3a:	74 f2                	je     f0103f2e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103f3c:	3c 2b                	cmp    $0x2b,%al
f0103f3e:	75 0a                	jne    f0103f4a <strtol+0x33>
		s++;
f0103f40:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103f43:	bf 00 00 00 00       	mov    $0x0,%edi
f0103f48:	eb 10                	jmp    f0103f5a <strtol+0x43>
f0103f4a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103f4f:	3c 2d                	cmp    $0x2d,%al
f0103f51:	75 07                	jne    f0103f5a <strtol+0x43>
		s++, neg = 1;
f0103f53:	83 c2 01             	add    $0x1,%edx
f0103f56:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103f5a:	85 db                	test   %ebx,%ebx
f0103f5c:	0f 94 c0             	sete   %al
f0103f5f:	74 05                	je     f0103f66 <strtol+0x4f>
f0103f61:	83 fb 10             	cmp    $0x10,%ebx
f0103f64:	75 15                	jne    f0103f7b <strtol+0x64>
f0103f66:	80 3a 30             	cmpb   $0x30,(%edx)
f0103f69:	75 10                	jne    f0103f7b <strtol+0x64>
f0103f6b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103f6f:	75 0a                	jne    f0103f7b <strtol+0x64>
		s += 2, base = 16;
f0103f71:	83 c2 02             	add    $0x2,%edx
f0103f74:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103f79:	eb 13                	jmp    f0103f8e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0103f7b:	84 c0                	test   %al,%al
f0103f7d:	74 0f                	je     f0103f8e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103f7f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103f84:	80 3a 30             	cmpb   $0x30,(%edx)
f0103f87:	75 05                	jne    f0103f8e <strtol+0x77>
		s++, base = 8;
f0103f89:	83 c2 01             	add    $0x1,%edx
f0103f8c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0103f8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f93:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103f95:	0f b6 0a             	movzbl (%edx),%ecx
f0103f98:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0103f9b:	80 fb 09             	cmp    $0x9,%bl
f0103f9e:	77 08                	ja     f0103fa8 <strtol+0x91>
			dig = *s - '0';
f0103fa0:	0f be c9             	movsbl %cl,%ecx
f0103fa3:	83 e9 30             	sub    $0x30,%ecx
f0103fa6:	eb 1e                	jmp    f0103fc6 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0103fa8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0103fab:	80 fb 19             	cmp    $0x19,%bl
f0103fae:	77 08                	ja     f0103fb8 <strtol+0xa1>
			dig = *s - 'a' + 10;
f0103fb0:	0f be c9             	movsbl %cl,%ecx
f0103fb3:	83 e9 57             	sub    $0x57,%ecx
f0103fb6:	eb 0e                	jmp    f0103fc6 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0103fb8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0103fbb:	80 fb 19             	cmp    $0x19,%bl
f0103fbe:	77 15                	ja     f0103fd5 <strtol+0xbe>
			dig = *s - 'A' + 10;
f0103fc0:	0f be c9             	movsbl %cl,%ecx
f0103fc3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0103fc6:	39 f1                	cmp    %esi,%ecx
f0103fc8:	7d 0f                	jge    f0103fd9 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
f0103fca:	83 c2 01             	add    $0x1,%edx
f0103fcd:	0f af c6             	imul   %esi,%eax
f0103fd0:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0103fd3:	eb c0                	jmp    f0103f95 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0103fd5:	89 c1                	mov    %eax,%ecx
f0103fd7:	eb 02                	jmp    f0103fdb <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103fd9:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0103fdb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103fdf:	74 05                	je     f0103fe6 <strtol+0xcf>
		*endptr = (char *) s;
f0103fe1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103fe4:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0103fe6:	89 ca                	mov    %ecx,%edx
f0103fe8:	f7 da                	neg    %edx
f0103fea:	85 ff                	test   %edi,%edi
f0103fec:	0f 45 c2             	cmovne %edx,%eax
}
f0103fef:	5b                   	pop    %ebx
f0103ff0:	5e                   	pop    %esi
f0103ff1:	5f                   	pop    %edi
f0103ff2:	5d                   	pop    %ebp
f0103ff3:	c3                   	ret    
	...

f0104000 <__udivdi3>:
f0104000:	55                   	push   %ebp
f0104001:	89 e5                	mov    %esp,%ebp
f0104003:	57                   	push   %edi
f0104004:	56                   	push   %esi
f0104005:	83 ec 10             	sub    $0x10,%esp
f0104008:	8b 75 14             	mov    0x14(%ebp),%esi
f010400b:	8b 45 08             	mov    0x8(%ebp),%eax
f010400e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104011:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104014:	85 f6                	test   %esi,%esi
f0104016:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104019:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010401c:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010401f:	75 2f                	jne    f0104050 <__udivdi3+0x50>
f0104021:	39 f9                	cmp    %edi,%ecx
f0104023:	77 5b                	ja     f0104080 <__udivdi3+0x80>
f0104025:	85 c9                	test   %ecx,%ecx
f0104027:	75 0b                	jne    f0104034 <__udivdi3+0x34>
f0104029:	b8 01 00 00 00       	mov    $0x1,%eax
f010402e:	31 d2                	xor    %edx,%edx
f0104030:	f7 f1                	div    %ecx
f0104032:	89 c1                	mov    %eax,%ecx
f0104034:	89 f8                	mov    %edi,%eax
f0104036:	31 d2                	xor    %edx,%edx
f0104038:	f7 f1                	div    %ecx
f010403a:	89 c7                	mov    %eax,%edi
f010403c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010403f:	f7 f1                	div    %ecx
f0104041:	89 fa                	mov    %edi,%edx
f0104043:	83 c4 10             	add    $0x10,%esp
f0104046:	5e                   	pop    %esi
f0104047:	5f                   	pop    %edi
f0104048:	5d                   	pop    %ebp
f0104049:	c3                   	ret    
f010404a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104050:	31 d2                	xor    %edx,%edx
f0104052:	31 c0                	xor    %eax,%eax
f0104054:	39 fe                	cmp    %edi,%esi
f0104056:	77 eb                	ja     f0104043 <__udivdi3+0x43>
f0104058:	0f bd d6             	bsr    %esi,%edx
f010405b:	83 f2 1f             	xor    $0x1f,%edx
f010405e:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0104061:	75 2d                	jne    f0104090 <__udivdi3+0x90>
f0104063:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104066:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
f0104069:	76 06                	jbe    f0104071 <__udivdi3+0x71>
f010406b:	39 fe                	cmp    %edi,%esi
f010406d:	89 c2                	mov    %eax,%edx
f010406f:	73 d2                	jae    f0104043 <__udivdi3+0x43>
f0104071:	31 d2                	xor    %edx,%edx
f0104073:	b8 01 00 00 00       	mov    $0x1,%eax
f0104078:	eb c9                	jmp    f0104043 <__udivdi3+0x43>
f010407a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104080:	89 fa                	mov    %edi,%edx
f0104082:	f7 f1                	div    %ecx
f0104084:	31 d2                	xor    %edx,%edx
f0104086:	83 c4 10             	add    $0x10,%esp
f0104089:	5e                   	pop    %esi
f010408a:	5f                   	pop    %edi
f010408b:	5d                   	pop    %ebp
f010408c:	c3                   	ret    
f010408d:	8d 76 00             	lea    0x0(%esi),%esi
f0104090:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0104094:	b8 20 00 00 00       	mov    $0x20,%eax
f0104099:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010409c:	2b 45 f4             	sub    -0xc(%ebp),%eax
f010409f:	d3 e6                	shl    %cl,%esi
f01040a1:	89 c1                	mov    %eax,%ecx
f01040a3:	d3 ea                	shr    %cl,%edx
f01040a5:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01040a9:	09 f2                	or     %esi,%edx
f01040ab:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01040ae:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01040b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01040b4:	d3 e2                	shl    %cl,%edx
f01040b6:	89 c1                	mov    %eax,%ecx
f01040b8:	89 55 f0             	mov    %edx,-0x10(%ebp)
f01040bb:	89 fa                	mov    %edi,%edx
f01040bd:	d3 ea                	shr    %cl,%edx
f01040bf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01040c3:	d3 e7                	shl    %cl,%edi
f01040c5:	89 c1                	mov    %eax,%ecx
f01040c7:	d3 ee                	shr    %cl,%esi
f01040c9:	09 fe                	or     %edi,%esi
f01040cb:	89 f0                	mov    %esi,%eax
f01040cd:	f7 75 e8             	divl   -0x18(%ebp)
f01040d0:	89 d7                	mov    %edx,%edi
f01040d2:	89 c6                	mov    %eax,%esi
f01040d4:	f7 65 f0             	mull   -0x10(%ebp)
f01040d7:	39 d7                	cmp    %edx,%edi
f01040d9:	89 55 f0             	mov    %edx,-0x10(%ebp)
f01040dc:	72 22                	jb     f0104100 <__udivdi3+0x100>
f01040de:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01040e1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01040e5:	d3 e2                	shl    %cl,%edx
f01040e7:	39 c2                	cmp    %eax,%edx
f01040e9:	73 05                	jae    f01040f0 <__udivdi3+0xf0>
f01040eb:	3b 7d f0             	cmp    -0x10(%ebp),%edi
f01040ee:	74 10                	je     f0104100 <__udivdi3+0x100>
f01040f0:	89 f0                	mov    %esi,%eax
f01040f2:	31 d2                	xor    %edx,%edx
f01040f4:	e9 4a ff ff ff       	jmp    f0104043 <__udivdi3+0x43>
f01040f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104100:	8d 46 ff             	lea    -0x1(%esi),%eax
f0104103:	31 d2                	xor    %edx,%edx
f0104105:	83 c4 10             	add    $0x10,%esp
f0104108:	5e                   	pop    %esi
f0104109:	5f                   	pop    %edi
f010410a:	5d                   	pop    %ebp
f010410b:	c3                   	ret    
f010410c:	00 00                	add    %al,(%eax)
	...

f0104110 <__umoddi3>:
f0104110:	55                   	push   %ebp
f0104111:	89 e5                	mov    %esp,%ebp
f0104113:	57                   	push   %edi
f0104114:	56                   	push   %esi
f0104115:	83 ec 20             	sub    $0x20,%esp
f0104118:	8b 7d 14             	mov    0x14(%ebp),%edi
f010411b:	8b 45 08             	mov    0x8(%ebp),%eax
f010411e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104121:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104124:	85 ff                	test   %edi,%edi
f0104126:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0104129:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010412c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010412f:	89 f2                	mov    %esi,%edx
f0104131:	75 15                	jne    f0104148 <__umoddi3+0x38>
f0104133:	39 f1                	cmp    %esi,%ecx
f0104135:	76 41                	jbe    f0104178 <__umoddi3+0x68>
f0104137:	f7 f1                	div    %ecx
f0104139:	89 d0                	mov    %edx,%eax
f010413b:	31 d2                	xor    %edx,%edx
f010413d:	83 c4 20             	add    $0x20,%esp
f0104140:	5e                   	pop    %esi
f0104141:	5f                   	pop    %edi
f0104142:	5d                   	pop    %ebp
f0104143:	c3                   	ret    
f0104144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104148:	39 f7                	cmp    %esi,%edi
f010414a:	77 4c                	ja     f0104198 <__umoddi3+0x88>
f010414c:	0f bd c7             	bsr    %edi,%eax
f010414f:	83 f0 1f             	xor    $0x1f,%eax
f0104152:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104155:	75 51                	jne    f01041a8 <__umoddi3+0x98>
f0104157:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f010415a:	0f 87 e8 00 00 00    	ja     f0104248 <__umoddi3+0x138>
f0104160:	89 f2                	mov    %esi,%edx
f0104162:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0104165:	29 ce                	sub    %ecx,%esi
f0104167:	19 fa                	sbb    %edi,%edx
f0104169:	89 75 f0             	mov    %esi,-0x10(%ebp)
f010416c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010416f:	83 c4 20             	add    $0x20,%esp
f0104172:	5e                   	pop    %esi
f0104173:	5f                   	pop    %edi
f0104174:	5d                   	pop    %ebp
f0104175:	c3                   	ret    
f0104176:	66 90                	xchg   %ax,%ax
f0104178:	85 c9                	test   %ecx,%ecx
f010417a:	75 0b                	jne    f0104187 <__umoddi3+0x77>
f010417c:	b8 01 00 00 00       	mov    $0x1,%eax
f0104181:	31 d2                	xor    %edx,%edx
f0104183:	f7 f1                	div    %ecx
f0104185:	89 c1                	mov    %eax,%ecx
f0104187:	89 f0                	mov    %esi,%eax
f0104189:	31 d2                	xor    %edx,%edx
f010418b:	f7 f1                	div    %ecx
f010418d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104190:	eb a5                	jmp    f0104137 <__umoddi3+0x27>
f0104192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104198:	89 f2                	mov    %esi,%edx
f010419a:	83 c4 20             	add    $0x20,%esp
f010419d:	5e                   	pop    %esi
f010419e:	5f                   	pop    %edi
f010419f:	5d                   	pop    %ebp
f01041a0:	c3                   	ret    
f01041a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01041a8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01041ac:	89 f2                	mov    %esi,%edx
f01041ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01041b1:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
f01041b8:	29 45 f0             	sub    %eax,-0x10(%ebp)
f01041bb:	d3 e7                	shl    %cl,%edi
f01041bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01041c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01041c4:	d3 e8                	shr    %cl,%eax
f01041c6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01041ca:	09 f8                	or     %edi,%eax
f01041cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01041cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01041d2:	d3 e0                	shl    %cl,%eax
f01041d4:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01041d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01041db:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01041de:	d3 ea                	shr    %cl,%edx
f01041e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01041e4:	d3 e6                	shl    %cl,%esi
f01041e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01041ea:	d3 e8                	shr    %cl,%eax
f01041ec:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01041f0:	09 f0                	or     %esi,%eax
f01041f2:	8b 75 e8             	mov    -0x18(%ebp),%esi
f01041f5:	f7 75 e4             	divl   -0x1c(%ebp)
f01041f8:	d3 e6                	shl    %cl,%esi
f01041fa:	89 75 e8             	mov    %esi,-0x18(%ebp)
f01041fd:	89 d6                	mov    %edx,%esi
f01041ff:	f7 65 f4             	mull   -0xc(%ebp)
f0104202:	89 d7                	mov    %edx,%edi
f0104204:	89 c2                	mov    %eax,%edx
f0104206:	39 fe                	cmp    %edi,%esi
f0104208:	89 f9                	mov    %edi,%ecx
f010420a:	72 30                	jb     f010423c <__umoddi3+0x12c>
f010420c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
f010420f:	72 27                	jb     f0104238 <__umoddi3+0x128>
f0104211:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104214:	29 d0                	sub    %edx,%eax
f0104216:	19 ce                	sbb    %ecx,%esi
f0104218:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f010421c:	89 f2                	mov    %esi,%edx
f010421e:	d3 e8                	shr    %cl,%eax
f0104220:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0104224:	d3 e2                	shl    %cl,%edx
f0104226:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f010422a:	09 d0                	or     %edx,%eax
f010422c:	89 f2                	mov    %esi,%edx
f010422e:	d3 ea                	shr    %cl,%edx
f0104230:	83 c4 20             	add    $0x20,%esp
f0104233:	5e                   	pop    %esi
f0104234:	5f                   	pop    %edi
f0104235:	5d                   	pop    %ebp
f0104236:	c3                   	ret    
f0104237:	90                   	nop
f0104238:	39 fe                	cmp    %edi,%esi
f010423a:	75 d5                	jne    f0104211 <__umoddi3+0x101>
f010423c:	89 f9                	mov    %edi,%ecx
f010423e:	89 c2                	mov    %eax,%edx
f0104240:	2b 55 f4             	sub    -0xc(%ebp),%edx
f0104243:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0104246:	eb c9                	jmp    f0104211 <__umoddi3+0x101>
f0104248:	39 f7                	cmp    %esi,%edi
f010424a:	0f 82 10 ff ff ff    	jb     f0104160 <__umoddi3+0x50>
f0104250:	e9 17 ff ff ff       	jmp    f010416c <__umoddi3+0x5c>
