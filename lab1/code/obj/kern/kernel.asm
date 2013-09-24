
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
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 80 18 10 f0       	push   $0xf0101880
f0100050:	e8 e0 08 00 00       	call   f0100935 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 bd 05 00 00       	call   f0100638 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 9c 18 10 f0       	push   $0xf010189c
f0100087:	e8 a9 08 00 00       	call   f0100935 <cprintf>
f010008c:	83 c4 10             	add    $0x10,%esp
}
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 48 89 11 f0       	mov    $0xf0118948,%eax
f010009f:	2d 00 83 11 f0       	sub    $0xf0118300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 83 11 f0       	push   $0xf0118300
f01000ac:	e8 7c 13 00 00       	call   f010142d <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 76 04 00 00       	call   f010052c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 b7 18 10 f0       	push   $0xf01018b7
f01000c3:	e8 6d 08 00 00       	call   f0100935 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 f0 06 00 00       	call   f01007d1 <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 40 89 11 f0 00 	cmpl   $0x0,0xf0118940
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 40 89 11 f0    	mov    %esi,0xf0118940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 d2 18 10 f0       	push   $0xf01018d2
f0100110:	e8 20 08 00 00       	call   f0100935 <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 f0 07 00 00       	call   f010090f <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 0e 19 10 f0 	movl   $0xf010190e,(%esp)
f0100126:	e8 0a 08 00 00       	call   f0100935 <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 99 06 00 00       	call   f01007d1 <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 ea 18 10 f0       	push   $0xf01018ea
f0100152:	e8 de 07 00 00       	call   f0100935 <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 ac 07 00 00       	call   f010090f <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 0e 19 10 f0 	movl   $0xf010190e,(%esp)
f010016a:	e8 c6 07 00 00       	call   f0100935 <cprintf>
	va_end(ap);
f010016f:	83 c4 10             	add    $0x10,%esp
}
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    
	...

f0100178 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100178:	55                   	push   %ebp
f0100179:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017b:	ba 84 00 00 00       	mov    $0x84,%edx
f0100180:	ec                   	in     (%dx),%al
f0100181:	ec                   	in     (%dx),%al
f0100182:	ec                   	in     (%dx),%al
f0100183:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100184:	c9                   	leave  
f0100185:	c3                   	ret    

f0100186 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100186:	55                   	push   %ebp
f0100187:	89 e5                	mov    %esp,%ebp
f0100189:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010018e:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010018f:	a8 01                	test   $0x1,%al
f0100191:	74 08                	je     f010019b <serial_proc_data+0x15>
f0100193:	b2 f8                	mov    $0xf8,%dl
f0100195:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100196:	0f b6 c0             	movzbl %al,%eax
f0100199:	eb 05                	jmp    f01001a0 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010019b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001a0:	c9                   	leave  
f01001a1:	c3                   	ret    

f01001a2 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001a2:	55                   	push   %ebp
f01001a3:	89 e5                	mov    %esp,%ebp
f01001a5:	53                   	push   %ebx
f01001a6:	83 ec 04             	sub    $0x4,%esp
f01001a9:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001ab:	eb 29                	jmp    f01001d6 <cons_intr+0x34>
		if (c == 0)
f01001ad:	85 c0                	test   %eax,%eax
f01001af:	74 25                	je     f01001d6 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f01001b1:	8b 15 24 85 11 f0    	mov    0xf0118524,%edx
f01001b7:	88 82 20 83 11 f0    	mov    %al,-0xfee7ce0(%edx)
f01001bd:	8d 42 01             	lea    0x1(%edx),%eax
f01001c0:	a3 24 85 11 f0       	mov    %eax,0xf0118524
		if (cons.wpos == CONSBUFSIZE)
f01001c5:	3d 00 02 00 00       	cmp    $0x200,%eax
f01001ca:	75 0a                	jne    f01001d6 <cons_intr+0x34>
			cons.wpos = 0;
f01001cc:	c7 05 24 85 11 f0 00 	movl   $0x0,0xf0118524
f01001d3:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001d6:	ff d3                	call   *%ebx
f01001d8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001db:	75 d0                	jne    f01001ad <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001dd:	83 c4 04             	add    $0x4,%esp
f01001e0:	5b                   	pop    %ebx
f01001e1:	c9                   	leave  
f01001e2:	c3                   	ret    

f01001e3 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001e3:	55                   	push   %ebp
f01001e4:	89 e5                	mov    %esp,%ebp
f01001e6:	57                   	push   %edi
f01001e7:	56                   	push   %esi
f01001e8:	53                   	push   %ebx
f01001e9:	83 ec 0c             	sub    $0xc,%esp
f01001ec:	89 c6                	mov    %eax,%esi
f01001ee:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001f3:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001f4:	a8 20                	test   $0x20,%al
f01001f6:	75 19                	jne    f0100211 <cons_putc+0x2e>
f01001f8:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01001fd:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100202:	e8 71 ff ff ff       	call   f0100178 <delay>
f0100207:	89 fa                	mov    %edi,%edx
f0100209:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010020a:	a8 20                	test   $0x20,%al
f010020c:	75 03                	jne    f0100211 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010020e:	4b                   	dec    %ebx
f010020f:	75 f1                	jne    f0100202 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100211:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100213:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100218:	89 f0                	mov    %esi,%eax
f010021a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010021b:	b2 79                	mov    $0x79,%dl
f010021d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010021e:	84 c0                	test   %al,%al
f0100220:	78 1d                	js     f010023f <cons_putc+0x5c>
f0100222:	bb 00 00 00 00       	mov    $0x0,%ebx
		delay();
f0100227:	e8 4c ff ff ff       	call   f0100178 <delay>
f010022c:	ba 79 03 00 00       	mov    $0x379,%edx
f0100231:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100232:	84 c0                	test   %al,%al
f0100234:	78 09                	js     f010023f <cons_putc+0x5c>
f0100236:	43                   	inc    %ebx
f0100237:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f010023d:	75 e8                	jne    f0100227 <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010023f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100244:	89 f8                	mov    %edi,%eax
f0100246:	ee                   	out    %al,(%dx)
f0100247:	b2 7a                	mov    $0x7a,%dl
f0100249:	b0 0d                	mov    $0xd,%al
f010024b:	ee                   	out    %al,(%dx)
f010024c:	b0 08                	mov    $0x8,%al
f010024e:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!csa) csa = 0x0700;
f010024f:	83 3d 44 89 11 f0 00 	cmpl   $0x0,0xf0118944
f0100256:	75 0a                	jne    f0100262 <cons_putc+0x7f>
f0100258:	c7 05 44 89 11 f0 00 	movl   $0x700,0xf0118944
f010025f:	07 00 00 
	if (!(c & ~0xFF))
f0100262:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f0100268:	75 06                	jne    f0100270 <cons_putc+0x8d>
		c |= csa;
f010026a:	0b 35 44 89 11 f0    	or     0xf0118944,%esi

	switch (c & 0xff) {
f0100270:	89 f0                	mov    %esi,%eax
f0100272:	25 ff 00 00 00       	and    $0xff,%eax
f0100277:	83 f8 09             	cmp    $0x9,%eax
f010027a:	74 78                	je     f01002f4 <cons_putc+0x111>
f010027c:	83 f8 09             	cmp    $0x9,%eax
f010027f:	7f 0b                	jg     f010028c <cons_putc+0xa9>
f0100281:	83 f8 08             	cmp    $0x8,%eax
f0100284:	0f 85 9e 00 00 00    	jne    f0100328 <cons_putc+0x145>
f010028a:	eb 10                	jmp    f010029c <cons_putc+0xb9>
f010028c:	83 f8 0a             	cmp    $0xa,%eax
f010028f:	74 39                	je     f01002ca <cons_putc+0xe7>
f0100291:	83 f8 0d             	cmp    $0xd,%eax
f0100294:	0f 85 8e 00 00 00    	jne    f0100328 <cons_putc+0x145>
f010029a:	eb 36                	jmp    f01002d2 <cons_putc+0xef>
	case '\b':
		if (crt_pos > 0) {
f010029c:	66 a1 00 83 11 f0    	mov    0xf0118300,%ax
f01002a2:	66 85 c0             	test   %ax,%ax
f01002a5:	0f 84 e0 00 00 00    	je     f010038b <cons_putc+0x1a8>
			crt_pos--;
f01002ab:	48                   	dec    %eax
f01002ac:	66 a3 00 83 11 f0    	mov    %ax,0xf0118300
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01002b2:	0f b7 c0             	movzwl %ax,%eax
f01002b5:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f01002bb:	83 ce 20             	or     $0x20,%esi
f01002be:	8b 15 04 83 11 f0    	mov    0xf0118304,%edx
f01002c4:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01002c8:	eb 78                	jmp    f0100342 <cons_putc+0x15f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002ca:	66 83 05 00 83 11 f0 	addw   $0x50,0xf0118300
f01002d1:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002d2:	66 8b 0d 00 83 11 f0 	mov    0xf0118300,%cx
f01002d9:	bb 50 00 00 00       	mov    $0x50,%ebx
f01002de:	89 c8                	mov    %ecx,%eax
f01002e0:	ba 00 00 00 00       	mov    $0x0,%edx
f01002e5:	66 f7 f3             	div    %bx
f01002e8:	66 29 d1             	sub    %dx,%cx
f01002eb:	66 89 0d 00 83 11 f0 	mov    %cx,0xf0118300
f01002f2:	eb 4e                	jmp    f0100342 <cons_putc+0x15f>
		break;
	case '\t':
		cons_putc(' ');
f01002f4:	b8 20 00 00 00       	mov    $0x20,%eax
f01002f9:	e8 e5 fe ff ff       	call   f01001e3 <cons_putc>
		cons_putc(' ');
f01002fe:	b8 20 00 00 00       	mov    $0x20,%eax
f0100303:	e8 db fe ff ff       	call   f01001e3 <cons_putc>
		cons_putc(' ');
f0100308:	b8 20 00 00 00       	mov    $0x20,%eax
f010030d:	e8 d1 fe ff ff       	call   f01001e3 <cons_putc>
		cons_putc(' ');
f0100312:	b8 20 00 00 00       	mov    $0x20,%eax
f0100317:	e8 c7 fe ff ff       	call   f01001e3 <cons_putc>
		cons_putc(' ');
f010031c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100321:	e8 bd fe ff ff       	call   f01001e3 <cons_putc>
f0100326:	eb 1a                	jmp    f0100342 <cons_putc+0x15f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100328:	66 a1 00 83 11 f0    	mov    0xf0118300,%ax
f010032e:	0f b7 c8             	movzwl %ax,%ecx
f0100331:	8b 15 04 83 11 f0    	mov    0xf0118304,%edx
f0100337:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f010033b:	40                   	inc    %eax
f010033c:	66 a3 00 83 11 f0    	mov    %ax,0xf0118300
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100342:	66 81 3d 00 83 11 f0 	cmpw   $0x7cf,0xf0118300
f0100349:	cf 07 
f010034b:	76 3e                	jbe    f010038b <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010034d:	a1 04 83 11 f0       	mov    0xf0118304,%eax
f0100352:	83 ec 04             	sub    $0x4,%esp
f0100355:	68 00 0f 00 00       	push   $0xf00
f010035a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100360:	52                   	push   %edx
f0100361:	50                   	push   %eax
f0100362:	e8 10 11 00 00       	call   f0101477 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100367:	8b 15 04 83 11 f0    	mov    0xf0118304,%edx
f010036d:	83 c4 10             	add    $0x10,%esp
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100370:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100375:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010037b:	40                   	inc    %eax
f010037c:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100381:	75 f2                	jne    f0100375 <cons_putc+0x192>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100383:	66 83 2d 00 83 11 f0 	subw   $0x50,0xf0118300
f010038a:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010038b:	8b 0d 08 83 11 f0    	mov    0xf0118308,%ecx
f0100391:	b0 0e                	mov    $0xe,%al
f0100393:	89 ca                	mov    %ecx,%edx
f0100395:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100396:	66 8b 35 00 83 11 f0 	mov    0xf0118300,%si
f010039d:	8d 59 01             	lea    0x1(%ecx),%ebx
f01003a0:	89 f0                	mov    %esi,%eax
f01003a2:	66 c1 e8 08          	shr    $0x8,%ax
f01003a6:	89 da                	mov    %ebx,%edx
f01003a8:	ee                   	out    %al,(%dx)
f01003a9:	b0 0f                	mov    $0xf,%al
f01003ab:	89 ca                	mov    %ecx,%edx
f01003ad:	ee                   	out    %al,(%dx)
f01003ae:	89 f0                	mov    %esi,%eax
f01003b0:	89 da                	mov    %ebx,%edx
f01003b2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01003b6:	5b                   	pop    %ebx
f01003b7:	5e                   	pop    %esi
f01003b8:	5f                   	pop    %edi
f01003b9:	c9                   	leave  
f01003ba:	c3                   	ret    

f01003bb <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003bb:	55                   	push   %ebp
f01003bc:	89 e5                	mov    %esp,%ebp
f01003be:	53                   	push   %ebx
f01003bf:	83 ec 04             	sub    $0x4,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003c2:	ba 64 00 00 00       	mov    $0x64,%edx
f01003c7:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003c8:	a8 01                	test   $0x1,%al
f01003ca:	0f 84 dc 00 00 00    	je     f01004ac <kbd_proc_data+0xf1>
f01003d0:	b2 60                	mov    $0x60,%dl
f01003d2:	ec                   	in     (%dx),%al
f01003d3:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003d5:	3c e0                	cmp    $0xe0,%al
f01003d7:	75 11                	jne    f01003ea <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01003d9:	83 0d 28 85 11 f0 40 	orl    $0x40,0xf0118528
		return 0;
f01003e0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003e5:	e9 c7 00 00 00       	jmp    f01004b1 <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f01003ea:	84 c0                	test   %al,%al
f01003ec:	79 33                	jns    f0100421 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003ee:	8b 0d 28 85 11 f0    	mov    0xf0118528,%ecx
f01003f4:	f6 c1 40             	test   $0x40,%cl
f01003f7:	75 05                	jne    f01003fe <kbd_proc_data+0x43>
f01003f9:	88 c2                	mov    %al,%dl
f01003fb:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003fe:	0f b6 d2             	movzbl %dl,%edx
f0100401:	8a 82 40 19 10 f0    	mov    -0xfefe6c0(%edx),%al
f0100407:	83 c8 40             	or     $0x40,%eax
f010040a:	0f b6 c0             	movzbl %al,%eax
f010040d:	f7 d0                	not    %eax
f010040f:	21 c1                	and    %eax,%ecx
f0100411:	89 0d 28 85 11 f0    	mov    %ecx,0xf0118528
		return 0;
f0100417:	bb 00 00 00 00       	mov    $0x0,%ebx
f010041c:	e9 90 00 00 00       	jmp    f01004b1 <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f0100421:	8b 0d 28 85 11 f0    	mov    0xf0118528,%ecx
f0100427:	f6 c1 40             	test   $0x40,%cl
f010042a:	74 0e                	je     f010043a <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010042c:	88 c2                	mov    %al,%dl
f010042e:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100431:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100434:	89 0d 28 85 11 f0    	mov    %ecx,0xf0118528
	}

	shift |= shiftcode[data];
f010043a:	0f b6 d2             	movzbl %dl,%edx
f010043d:	0f b6 82 40 19 10 f0 	movzbl -0xfefe6c0(%edx),%eax
f0100444:	0b 05 28 85 11 f0    	or     0xf0118528,%eax
	shift ^= togglecode[data];
f010044a:	0f b6 8a 40 1a 10 f0 	movzbl -0xfefe5c0(%edx),%ecx
f0100451:	31 c8                	xor    %ecx,%eax
f0100453:	a3 28 85 11 f0       	mov    %eax,0xf0118528

	c = charcode[shift & (CTL | SHIFT)][data];
f0100458:	89 c1                	mov    %eax,%ecx
f010045a:	83 e1 03             	and    $0x3,%ecx
f010045d:	8b 0c 8d 40 1b 10 f0 	mov    -0xfefe4c0(,%ecx,4),%ecx
f0100464:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100468:	a8 08                	test   $0x8,%al
f010046a:	74 18                	je     f0100484 <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f010046c:	8d 53 9f             	lea    -0x61(%ebx),%edx
f010046f:	83 fa 19             	cmp    $0x19,%edx
f0100472:	77 05                	ja     f0100479 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f0100474:	83 eb 20             	sub    $0x20,%ebx
f0100477:	eb 0b                	jmp    f0100484 <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f0100479:	8d 53 bf             	lea    -0x41(%ebx),%edx
f010047c:	83 fa 19             	cmp    $0x19,%edx
f010047f:	77 03                	ja     f0100484 <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f0100481:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100484:	f7 d0                	not    %eax
f0100486:	a8 06                	test   $0x6,%al
f0100488:	75 27                	jne    f01004b1 <kbd_proc_data+0xf6>
f010048a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100490:	75 1f                	jne    f01004b1 <kbd_proc_data+0xf6>
		cprintf("Rebooting!\n");
f0100492:	83 ec 0c             	sub    $0xc,%esp
f0100495:	68 04 19 10 f0       	push   $0xf0101904
f010049a:	e8 96 04 00 00       	call   f0100935 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010049f:	ba 92 00 00 00       	mov    $0x92,%edx
f01004a4:	b0 03                	mov    $0x3,%al
f01004a6:	ee                   	out    %al,(%dx)
f01004a7:	83 c4 10             	add    $0x10,%esp
f01004aa:	eb 05                	jmp    f01004b1 <kbd_proc_data+0xf6>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01004ac:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004b1:	89 d8                	mov    %ebx,%eax
f01004b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01004b6:	c9                   	leave  
f01004b7:	c3                   	ret    

f01004b8 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004b8:	55                   	push   %ebp
f01004b9:	89 e5                	mov    %esp,%ebp
f01004bb:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01004be:	80 3d 0c 83 11 f0 00 	cmpb   $0x0,0xf011830c
f01004c5:	74 0a                	je     f01004d1 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004c7:	b8 86 01 10 f0       	mov    $0xf0100186,%eax
f01004cc:	e8 d1 fc ff ff       	call   f01001a2 <cons_intr>
}
f01004d1:	c9                   	leave  
f01004d2:	c3                   	ret    

f01004d3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004d3:	55                   	push   %ebp
f01004d4:	89 e5                	mov    %esp,%ebp
f01004d6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004d9:	b8 bb 03 10 f0       	mov    $0xf01003bb,%eax
f01004de:	e8 bf fc ff ff       	call   f01001a2 <cons_intr>
}
f01004e3:	c9                   	leave  
f01004e4:	c3                   	ret    

f01004e5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004e5:	55                   	push   %ebp
f01004e6:	89 e5                	mov    %esp,%ebp
f01004e8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004eb:	e8 c8 ff ff ff       	call   f01004b8 <serial_intr>
	kbd_intr();
f01004f0:	e8 de ff ff ff       	call   f01004d3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004f5:	8b 15 20 85 11 f0    	mov    0xf0118520,%edx
f01004fb:	3b 15 24 85 11 f0    	cmp    0xf0118524,%edx
f0100501:	74 22                	je     f0100525 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f0100503:	0f b6 82 20 83 11 f0 	movzbl -0xfee7ce0(%edx),%eax
f010050a:	42                   	inc    %edx
f010050b:	89 15 20 85 11 f0    	mov    %edx,0xf0118520
		if (cons.rpos == CONSBUFSIZE)
f0100511:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100517:	75 11                	jne    f010052a <cons_getc+0x45>
			cons.rpos = 0;
f0100519:	c7 05 20 85 11 f0 00 	movl   $0x0,0xf0118520
f0100520:	00 00 00 
f0100523:	eb 05                	jmp    f010052a <cons_getc+0x45>
		return c;
	}
	return 0;
f0100525:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010052a:	c9                   	leave  
f010052b:	c3                   	ret    

f010052c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010052c:	55                   	push   %ebp
f010052d:	89 e5                	mov    %esp,%ebp
f010052f:	57                   	push   %edi
f0100530:	56                   	push   %esi
f0100531:	53                   	push   %ebx
f0100532:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100535:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f010053c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100543:	5a a5 
	if (*cp != 0xA55A) {
f0100545:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010054b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010054f:	74 11                	je     f0100562 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100551:	c7 05 08 83 11 f0 b4 	movl   $0x3b4,0xf0118308
f0100558:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010055b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100560:	eb 16                	jmp    f0100578 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100562:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100569:	c7 05 08 83 11 f0 d4 	movl   $0x3d4,0xf0118308
f0100570:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100573:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100578:	8b 0d 08 83 11 f0    	mov    0xf0118308,%ecx
f010057e:	b0 0e                	mov    $0xe,%al
f0100580:	89 ca                	mov    %ecx,%edx
f0100582:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100583:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100586:	89 da                	mov    %ebx,%edx
f0100588:	ec                   	in     (%dx),%al
f0100589:	0f b6 f8             	movzbl %al,%edi
f010058c:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010058f:	b0 0f                	mov    $0xf,%al
f0100591:	89 ca                	mov    %ecx,%edx
f0100593:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100594:	89 da                	mov    %ebx,%edx
f0100596:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100597:	89 35 04 83 11 f0    	mov    %esi,0xf0118304

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010059d:	0f b6 d8             	movzbl %al,%ebx
f01005a0:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005a2:	66 89 3d 00 83 11 f0 	mov    %di,0xf0118300
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005a9:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005ae:	b0 00                	mov    $0x0,%al
f01005b0:	89 da                	mov    %ebx,%edx
f01005b2:	ee                   	out    %al,(%dx)
f01005b3:	b2 fb                	mov    $0xfb,%dl
f01005b5:	b0 80                	mov    $0x80,%al
f01005b7:	ee                   	out    %al,(%dx)
f01005b8:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01005bd:	b0 0c                	mov    $0xc,%al
f01005bf:	89 ca                	mov    %ecx,%edx
f01005c1:	ee                   	out    %al,(%dx)
f01005c2:	b2 f9                	mov    $0xf9,%dl
f01005c4:	b0 00                	mov    $0x0,%al
f01005c6:	ee                   	out    %al,(%dx)
f01005c7:	b2 fb                	mov    $0xfb,%dl
f01005c9:	b0 03                	mov    $0x3,%al
f01005cb:	ee                   	out    %al,(%dx)
f01005cc:	b2 fc                	mov    $0xfc,%dl
f01005ce:	b0 00                	mov    $0x0,%al
f01005d0:	ee                   	out    %al,(%dx)
f01005d1:	b2 f9                	mov    $0xf9,%dl
f01005d3:	b0 01                	mov    $0x1,%al
f01005d5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d6:	b2 fd                	mov    $0xfd,%dl
f01005d8:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005d9:	3c ff                	cmp    $0xff,%al
f01005db:	0f 95 45 e7          	setne  -0x19(%ebp)
f01005df:	8a 45 e7             	mov    -0x19(%ebp),%al
f01005e2:	a2 0c 83 11 f0       	mov    %al,0xf011830c
f01005e7:	89 da                	mov    %ebx,%edx
f01005e9:	ec                   	in     (%dx),%al
f01005ea:	89 ca                	mov    %ecx,%edx
f01005ec:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005ed:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01005f1:	75 10                	jne    f0100603 <cons_init+0xd7>
		cprintf("Serial port does not exist!\n");
f01005f3:	83 ec 0c             	sub    $0xc,%esp
f01005f6:	68 10 19 10 f0       	push   $0xf0101910
f01005fb:	e8 35 03 00 00       	call   f0100935 <cprintf>
f0100600:	83 c4 10             	add    $0x10,%esp
}
f0100603:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100606:	5b                   	pop    %ebx
f0100607:	5e                   	pop    %esi
f0100608:	5f                   	pop    %edi
f0100609:	c9                   	leave  
f010060a:	c3                   	ret    

f010060b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010060b:	55                   	push   %ebp
f010060c:	89 e5                	mov    %esp,%ebp
f010060e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100611:	8b 45 08             	mov    0x8(%ebp),%eax
f0100614:	e8 ca fb ff ff       	call   f01001e3 <cons_putc>
}
f0100619:	c9                   	leave  
f010061a:	c3                   	ret    

f010061b <getchar>:

int
getchar(void)
{
f010061b:	55                   	push   %ebp
f010061c:	89 e5                	mov    %esp,%ebp
f010061e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100621:	e8 bf fe ff ff       	call   f01004e5 <cons_getc>
f0100626:	85 c0                	test   %eax,%eax
f0100628:	74 f7                	je     f0100621 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010062a:	c9                   	leave  
f010062b:	c3                   	ret    

f010062c <iscons>:

int
iscons(int fdnum)
{
f010062c:	55                   	push   %ebp
f010062d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010062f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100634:	c9                   	leave  
f0100635:	c3                   	ret    
	...

f0100638 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100638:	55                   	push   %ebp
f0100639:	89 e5                	mov    %esp,%ebp
f010063b:	56                   	push   %esi
f010063c:	53                   	push   %ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010063d:	89 ee                	mov    %ebp,%esi
	uint32_t* ebp = (uint32_t*) read_ebp();
f010063f:	89 f3                	mov    %esi,%ebx
	cprintf("Stack backtrace:\n");
f0100641:	83 ec 0c             	sub    $0xc,%esp
f0100644:	68 50 1b 10 f0       	push   $0xf0101b50
f0100649:	e8 e7 02 00 00       	call   f0100935 <cprintf>
	while (ebp) {
f010064e:	83 c4 10             	add    $0x10,%esp
f0100651:	85 f6                	test   %esi,%esi
f0100653:	74 6a                	je     f01006bf <mon_backtrace+0x87>
		cprintf("ebp %x  eip %x  args", ebp, *(ebp+1));
f0100655:	83 ec 04             	sub    $0x4,%esp
f0100658:	ff 73 04             	pushl  0x4(%ebx)
f010065b:	53                   	push   %ebx
f010065c:	68 62 1b 10 f0       	push   $0xf0101b62
f0100661:	e8 cf 02 00 00       	call   f0100935 <cprintf>
		cprintf(" %x", *(ebp+2));
f0100666:	83 c4 08             	add    $0x8,%esp
f0100669:	ff 73 08             	pushl  0x8(%ebx)
f010066c:	68 77 1b 10 f0       	push   $0xf0101b77
f0100671:	e8 bf 02 00 00       	call   f0100935 <cprintf>
		cprintf(" %x", *(ebp+3));
f0100676:	83 c4 08             	add    $0x8,%esp
f0100679:	ff 73 0c             	pushl  0xc(%ebx)
f010067c:	68 77 1b 10 f0       	push   $0xf0101b77
f0100681:	e8 af 02 00 00       	call   f0100935 <cprintf>
		cprintf(" %x", *(ebp+4));
f0100686:	83 c4 08             	add    $0x8,%esp
f0100689:	ff 73 10             	pushl  0x10(%ebx)
f010068c:	68 77 1b 10 f0       	push   $0xf0101b77
f0100691:	e8 9f 02 00 00       	call   f0100935 <cprintf>
		cprintf(" %x", *(ebp+5));
f0100696:	83 c4 08             	add    $0x8,%esp
f0100699:	ff 73 14             	pushl  0x14(%ebx)
f010069c:	68 77 1b 10 f0       	push   $0xf0101b77
f01006a1:	e8 8f 02 00 00       	call   f0100935 <cprintf>
		cprintf(" %x\n", *(ebp+6));
f01006a6:	83 c4 08             	add    $0x8,%esp
f01006a9:	ff 73 18             	pushl  0x18(%ebx)
f01006ac:	68 7b 1b 10 f0       	push   $0xf0101b7b
f01006b1:	e8 7f 02 00 00       	call   f0100935 <cprintf>
		ebp = (uint32_t*) *ebp;
f01006b6:	8b 1b                	mov    (%ebx),%ebx
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f01006b8:	83 c4 10             	add    $0x10,%esp
f01006bb:	85 db                	test   %ebx,%ebx
f01006bd:	75 96                	jne    f0100655 <mon_backtrace+0x1d>
		cprintf(" %x\n", *(ebp+6));
		ebp = (uint32_t*) *ebp;
  //ebp f0109e58  eip f0100a62  args 00000001 f0109e80 f0109e98 f0100ed2 00000031
	}
	return 0;
}
f01006bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01006c7:	5b                   	pop    %ebx
f01006c8:	5e                   	pop    %esi
f01006c9:	c9                   	leave  
f01006ca:	c3                   	ret    

f01006cb <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006cb:	55                   	push   %ebp
f01006cc:	89 e5                	mov    %esp,%ebp
f01006ce:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006d1:	68 80 1b 10 f0       	push   $0xf0101b80
f01006d6:	e8 5a 02 00 00       	call   f0100935 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006db:	83 c4 08             	add    $0x8,%esp
f01006de:	68 0c 00 10 00       	push   $0x10000c
f01006e3:	68 18 1c 10 f0       	push   $0xf0101c18
f01006e8:	e8 48 02 00 00       	call   f0100935 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006ed:	83 c4 0c             	add    $0xc,%esp
f01006f0:	68 0c 00 10 00       	push   $0x10000c
f01006f5:	68 0c 00 10 f0       	push   $0xf010000c
f01006fa:	68 40 1c 10 f0       	push   $0xf0101c40
f01006ff:	e8 31 02 00 00       	call   f0100935 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100704:	83 c4 0c             	add    $0xc,%esp
f0100707:	68 7c 18 10 00       	push   $0x10187c
f010070c:	68 7c 18 10 f0       	push   $0xf010187c
f0100711:	68 64 1c 10 f0       	push   $0xf0101c64
f0100716:	e8 1a 02 00 00       	call   f0100935 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010071b:	83 c4 0c             	add    $0xc,%esp
f010071e:	68 00 83 11 00       	push   $0x118300
f0100723:	68 00 83 11 f0       	push   $0xf0118300
f0100728:	68 88 1c 10 f0       	push   $0xf0101c88
f010072d:	e8 03 02 00 00       	call   f0100935 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100732:	83 c4 0c             	add    $0xc,%esp
f0100735:	68 48 89 11 00       	push   $0x118948
f010073a:	68 48 89 11 f0       	push   $0xf0118948
f010073f:	68 ac 1c 10 f0       	push   $0xf0101cac
f0100744:	e8 ec 01 00 00       	call   f0100935 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100749:	b8 47 8d 11 f0       	mov    $0xf0118d47,%eax
f010074e:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100753:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100756:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010075b:	89 c2                	mov    %eax,%edx
f010075d:	85 c0                	test   %eax,%eax
f010075f:	79 06                	jns    f0100767 <mon_kerninfo+0x9c>
f0100761:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100767:	c1 fa 0a             	sar    $0xa,%edx
f010076a:	52                   	push   %edx
f010076b:	68 d0 1c 10 f0       	push   $0xf0101cd0
f0100770:	e8 c0 01 00 00       	call   f0100935 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100775:	b8 00 00 00 00       	mov    $0x0,%eax
f010077a:	c9                   	leave  
f010077b:	c3                   	ret    

f010077c <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010077c:	55                   	push   %ebp
f010077d:	89 e5                	mov    %esp,%ebp
f010077f:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100782:	ff 35 84 1d 10 f0    	pushl  0xf0101d84
f0100788:	ff 35 80 1d 10 f0    	pushl  0xf0101d80
f010078e:	68 99 1b 10 f0       	push   $0xf0101b99
f0100793:	e8 9d 01 00 00       	call   f0100935 <cprintf>
f0100798:	83 c4 0c             	add    $0xc,%esp
f010079b:	ff 35 90 1d 10 f0    	pushl  0xf0101d90
f01007a1:	ff 35 8c 1d 10 f0    	pushl  0xf0101d8c
f01007a7:	68 99 1b 10 f0       	push   $0xf0101b99
f01007ac:	e8 84 01 00 00       	call   f0100935 <cprintf>
f01007b1:	83 c4 0c             	add    $0xc,%esp
f01007b4:	ff 35 9c 1d 10 f0    	pushl  0xf0101d9c
f01007ba:	ff 35 98 1d 10 f0    	pushl  0xf0101d98
f01007c0:	68 99 1b 10 f0       	push   $0xf0101b99
f01007c5:	e8 6b 01 00 00       	call   f0100935 <cprintf>
	return 0;
}
f01007ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01007cf:	c9                   	leave  
f01007d0:	c3                   	ret    

f01007d1 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007d1:	55                   	push   %ebp
f01007d2:	89 e5                	mov    %esp,%ebp
f01007d4:	57                   	push   %edi
f01007d5:	56                   	push   %esi
f01007d6:	53                   	push   %ebx
f01007d7:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007da:	68 fc 1c 10 f0       	push   $0xf0101cfc
f01007df:	e8 51 01 00 00       	call   f0100935 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007e4:	c7 04 24 20 1d 10 f0 	movl   $0xf0101d20,(%esp)
f01007eb:	e8 45 01 00 00       	call   f0100935 <cprintf>
f01007f0:	83 c4 10             	add    $0x10,%esp
	//cprintf("%m%s\n%m%s\n%m%s\n", 
		//0x0100, "blue", 0x0200, "green", 0x0400, "red");


	while (1) {
		buf = readline("K> ");
f01007f3:	83 ec 0c             	sub    $0xc,%esp
f01007f6:	68 a2 1b 10 f0       	push   $0xf0101ba2
f01007fb:	e8 94 09 00 00       	call   f0101194 <readline>
f0100800:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100802:	83 c4 10             	add    $0x10,%esp
f0100805:	85 c0                	test   %eax,%eax
f0100807:	74 ea                	je     f01007f3 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100809:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100810:	be 00 00 00 00       	mov    $0x0,%esi
f0100815:	eb 04                	jmp    f010081b <monitor+0x4a>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100817:	c6 03 00             	movb   $0x0,(%ebx)
f010081a:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010081b:	8a 03                	mov    (%ebx),%al
f010081d:	84 c0                	test   %al,%al
f010081f:	74 64                	je     f0100885 <monitor+0xb4>
f0100821:	83 ec 08             	sub    $0x8,%esp
f0100824:	0f be c0             	movsbl %al,%eax
f0100827:	50                   	push   %eax
f0100828:	68 a6 1b 10 f0       	push   $0xf0101ba6
f010082d:	e8 ab 0b 00 00       	call   f01013dd <strchr>
f0100832:	83 c4 10             	add    $0x10,%esp
f0100835:	85 c0                	test   %eax,%eax
f0100837:	75 de                	jne    f0100817 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100839:	80 3b 00             	cmpb   $0x0,(%ebx)
f010083c:	74 47                	je     f0100885 <monitor+0xb4>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010083e:	83 fe 0f             	cmp    $0xf,%esi
f0100841:	75 14                	jne    f0100857 <monitor+0x86>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100843:	83 ec 08             	sub    $0x8,%esp
f0100846:	6a 10                	push   $0x10
f0100848:	68 ab 1b 10 f0       	push   $0xf0101bab
f010084d:	e8 e3 00 00 00       	call   f0100935 <cprintf>
f0100852:	83 c4 10             	add    $0x10,%esp
f0100855:	eb 9c                	jmp    f01007f3 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100857:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010085b:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010085c:	8a 03                	mov    (%ebx),%al
f010085e:	84 c0                	test   %al,%al
f0100860:	75 09                	jne    f010086b <monitor+0x9a>
f0100862:	eb b7                	jmp    f010081b <monitor+0x4a>
			buf++;
f0100864:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100865:	8a 03                	mov    (%ebx),%al
f0100867:	84 c0                	test   %al,%al
f0100869:	74 b0                	je     f010081b <monitor+0x4a>
f010086b:	83 ec 08             	sub    $0x8,%esp
f010086e:	0f be c0             	movsbl %al,%eax
f0100871:	50                   	push   %eax
f0100872:	68 a6 1b 10 f0       	push   $0xf0101ba6
f0100877:	e8 61 0b 00 00       	call   f01013dd <strchr>
f010087c:	83 c4 10             	add    $0x10,%esp
f010087f:	85 c0                	test   %eax,%eax
f0100881:	74 e1                	je     f0100864 <monitor+0x93>
f0100883:	eb 96                	jmp    f010081b <monitor+0x4a>
			buf++;
	}
	argv[argc] = 0;
f0100885:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010088c:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010088d:	85 f6                	test   %esi,%esi
f010088f:	0f 84 5e ff ff ff    	je     f01007f3 <monitor+0x22>
f0100895:	bb 80 1d 10 f0       	mov    $0xf0101d80,%ebx
f010089a:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010089f:	83 ec 08             	sub    $0x8,%esp
f01008a2:	ff 33                	pushl  (%ebx)
f01008a4:	ff 75 a8             	pushl  -0x58(%ebp)
f01008a7:	e8 c3 0a 00 00       	call   f010136f <strcmp>
f01008ac:	83 c4 10             	add    $0x10,%esp
f01008af:	85 c0                	test   %eax,%eax
f01008b1:	75 20                	jne    f01008d3 <monitor+0x102>
			return commands[i].func(argc, argv, tf);
f01008b3:	83 ec 04             	sub    $0x4,%esp
f01008b6:	6b ff 0c             	imul   $0xc,%edi,%edi
f01008b9:	ff 75 08             	pushl  0x8(%ebp)
f01008bc:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01008bf:	50                   	push   %eax
f01008c0:	56                   	push   %esi
f01008c1:	ff 97 88 1d 10 f0    	call   *-0xfefe278(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008c7:	83 c4 10             	add    $0x10,%esp
f01008ca:	85 c0                	test   %eax,%eax
f01008cc:	78 26                	js     f01008f4 <monitor+0x123>
f01008ce:	e9 20 ff ff ff       	jmp    f01007f3 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008d3:	47                   	inc    %edi
f01008d4:	83 c3 0c             	add    $0xc,%ebx
f01008d7:	83 ff 03             	cmp    $0x3,%edi
f01008da:	75 c3                	jne    f010089f <monitor+0xce>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008dc:	83 ec 08             	sub    $0x8,%esp
f01008df:	ff 75 a8             	pushl  -0x58(%ebp)
f01008e2:	68 c8 1b 10 f0       	push   $0xf0101bc8
f01008e7:	e8 49 00 00 00       	call   f0100935 <cprintf>
f01008ec:	83 c4 10             	add    $0x10,%esp
f01008ef:	e9 ff fe ff ff       	jmp    f01007f3 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008f7:	5b                   	pop    %ebx
f01008f8:	5e                   	pop    %esi
f01008f9:	5f                   	pop    %edi
f01008fa:	c9                   	leave  
f01008fb:	c3                   	ret    

f01008fc <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01008fc:	55                   	push   %ebp
f01008fd:	89 e5                	mov    %esp,%ebp
f01008ff:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100902:	ff 75 08             	pushl  0x8(%ebp)
f0100905:	e8 01 fd ff ff       	call   f010060b <cputchar>
f010090a:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f010090d:	c9                   	leave  
f010090e:	c3                   	ret    

f010090f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010090f:	55                   	push   %ebp
f0100910:	89 e5                	mov    %esp,%ebp
f0100912:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100915:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010091c:	ff 75 0c             	pushl  0xc(%ebp)
f010091f:	ff 75 08             	pushl  0x8(%ebp)
f0100922:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100925:	50                   	push   %eax
f0100926:	68 fc 08 10 f0       	push   $0xf01008fc
f010092b:	e8 59 04 00 00       	call   f0100d89 <vprintfmt>
	return cnt;
}
f0100930:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100933:	c9                   	leave  
f0100934:	c3                   	ret    

f0100935 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100935:	55                   	push   %ebp
f0100936:	89 e5                	mov    %esp,%ebp
f0100938:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010093b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010093e:	50                   	push   %eax
f010093f:	ff 75 08             	pushl  0x8(%ebp)
f0100942:	e8 c8 ff ff ff       	call   f010090f <vcprintf>
	va_end(ap);

	return cnt;
}
f0100947:	c9                   	leave  
f0100948:	c3                   	ret    
f0100949:	00 00                	add    %al,(%eax)
	...

f010094c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010094c:	55                   	push   %ebp
f010094d:	89 e5                	mov    %esp,%ebp
f010094f:	57                   	push   %edi
f0100950:	56                   	push   %esi
f0100951:	53                   	push   %ebx
f0100952:	83 ec 14             	sub    $0x14,%esp
f0100955:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100958:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010095b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010095e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100961:	8b 1a                	mov    (%edx),%ebx
f0100963:	8b 01                	mov    (%ecx),%eax
f0100965:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0100968:	39 c3                	cmp    %eax,%ebx
f010096a:	0f 8f 97 00 00 00    	jg     f0100a07 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0100970:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0100977:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010097a:	01 d8                	add    %ebx,%eax
f010097c:	89 c7                	mov    %eax,%edi
f010097e:	c1 ef 1f             	shr    $0x1f,%edi
f0100981:	01 c7                	add    %eax,%edi
f0100983:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100985:	39 df                	cmp    %ebx,%edi
f0100987:	7c 31                	jl     f01009ba <stab_binsearch+0x6e>
f0100989:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010098c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010098f:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0100994:	39 f0                	cmp    %esi,%eax
f0100996:	0f 84 b3 00 00 00    	je     f0100a4f <stab_binsearch+0x103>
f010099c:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01009a0:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01009a4:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01009a6:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009a7:	39 d8                	cmp    %ebx,%eax
f01009a9:	7c 0f                	jl     f01009ba <stab_binsearch+0x6e>
f01009ab:	0f b6 0a             	movzbl (%edx),%ecx
f01009ae:	83 ea 0c             	sub    $0xc,%edx
f01009b1:	39 f1                	cmp    %esi,%ecx
f01009b3:	75 f1                	jne    f01009a6 <stab_binsearch+0x5a>
f01009b5:	e9 97 00 00 00       	jmp    f0100a51 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01009ba:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01009bd:	eb 39                	jmp    f01009f8 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01009bf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01009c2:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f01009c4:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009c7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01009ce:	eb 28                	jmp    f01009f8 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01009d0:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01009d3:	76 12                	jbe    f01009e7 <stab_binsearch+0x9b>
			*region_right = m - 1;
f01009d5:	48                   	dec    %eax
f01009d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01009d9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01009dc:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009de:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01009e5:	eb 11                	jmp    f01009f8 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01009e7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01009ea:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f01009ec:	ff 45 0c             	incl   0xc(%ebp)
f01009ef:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009f1:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01009f8:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f01009fb:	0f 8d 76 ff ff ff    	jge    f0100977 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a01:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100a05:	75 0d                	jne    f0100a14 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0100a07:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100a0a:	8b 03                	mov    (%ebx),%eax
f0100a0c:	48                   	dec    %eax
f0100a0d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100a10:	89 02                	mov    %eax,(%edx)
f0100a12:	eb 55                	jmp    f0100a69 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a14:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100a17:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a19:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100a1c:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a1e:	39 c1                	cmp    %eax,%ecx
f0100a20:	7d 26                	jge    f0100a48 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0100a22:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a25:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0100a28:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0100a2d:	39 f2                	cmp    %esi,%edx
f0100a2f:	74 17                	je     f0100a48 <stab_binsearch+0xfc>
f0100a31:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100a35:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a39:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a3a:	39 c1                	cmp    %eax,%ecx
f0100a3c:	7d 0a                	jge    f0100a48 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0100a3e:	0f b6 1a             	movzbl (%edx),%ebx
f0100a41:	83 ea 0c             	sub    $0xc,%edx
f0100a44:	39 f3                	cmp    %esi,%ebx
f0100a46:	75 f1                	jne    f0100a39 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a48:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a4b:	89 02                	mov    %eax,(%edx)
f0100a4d:	eb 1a                	jmp    f0100a69 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0100a4f:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a51:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a54:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0100a57:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a5b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100a5e:	0f 82 5b ff ff ff    	jb     f01009bf <stab_binsearch+0x73>
f0100a64:	e9 67 ff ff ff       	jmp    f01009d0 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100a69:	83 c4 14             	add    $0x14,%esp
f0100a6c:	5b                   	pop    %ebx
f0100a6d:	5e                   	pop    %esi
f0100a6e:	5f                   	pop    %edi
f0100a6f:	c9                   	leave  
f0100a70:	c3                   	ret    

f0100a71 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a71:	55                   	push   %ebp
f0100a72:	89 e5                	mov    %esp,%ebp
f0100a74:	57                   	push   %edi
f0100a75:	56                   	push   %esi
f0100a76:	53                   	push   %ebx
f0100a77:	83 ec 2c             	sub    $0x2c,%esp
f0100a7a:	8b 75 08             	mov    0x8(%ebp),%esi
f0100a7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a80:	c7 03 a4 1d 10 f0    	movl   $0xf0101da4,(%ebx)
	info->eip_line = 0;
f0100a86:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100a8d:	c7 43 08 a4 1d 10 f0 	movl   $0xf0101da4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100a94:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100a9b:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100a9e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100aa5:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100aab:	76 12                	jbe    f0100abf <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100aad:	b8 7a d8 10 f0       	mov    $0xf010d87a,%eax
f0100ab2:	3d 6d 65 10 f0       	cmp    $0xf010656d,%eax
f0100ab7:	0f 86 4b 01 00 00    	jbe    f0100c08 <debuginfo_eip+0x197>
f0100abd:	eb 14                	jmp    f0100ad3 <debuginfo_eip+0x62>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100abf:	83 ec 04             	sub    $0x4,%esp
f0100ac2:	68 ae 1d 10 f0       	push   $0xf0101dae
f0100ac7:	6a 7f                	push   $0x7f
f0100ac9:	68 bb 1d 10 f0       	push   $0xf0101dbb
f0100ace:	e8 13 f6 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100ad3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ad8:	80 3d 79 d8 10 f0 00 	cmpb   $0x0,0xf010d879
f0100adf:	0f 85 2f 01 00 00    	jne    f0100c14 <debuginfo_eip+0x1a3>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100ae5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100aec:	b8 6c 65 10 f0       	mov    $0xf010656c,%eax
f0100af1:	2d dc 1f 10 f0       	sub    $0xf0101fdc,%eax
f0100af6:	c1 f8 02             	sar    $0x2,%eax
f0100af9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100aff:	48                   	dec    %eax
f0100b00:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b03:	83 ec 08             	sub    $0x8,%esp
f0100b06:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b09:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b0c:	56                   	push   %esi
f0100b0d:	6a 64                	push   $0x64
f0100b0f:	b8 dc 1f 10 f0       	mov    $0xf0101fdc,%eax
f0100b14:	e8 33 fe ff ff       	call   f010094c <stab_binsearch>
	if (lfile == 0)
f0100b19:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100b1c:	83 c4 10             	add    $0x10,%esp
		return -1;
f0100b1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0100b24:	85 d2                	test   %edx,%edx
f0100b26:	0f 84 e8 00 00 00    	je     f0100c14 <debuginfo_eip+0x1a3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b2c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0100b2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b32:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b35:	83 ec 08             	sub    $0x8,%esp
f0100b38:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b3b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b3e:	56                   	push   %esi
f0100b3f:	6a 24                	push   $0x24
f0100b41:	b8 dc 1f 10 f0       	mov    $0xf0101fdc,%eax
f0100b46:	e8 01 fe ff ff       	call   f010094c <stab_binsearch>

	if (lfun <= rfun) {
f0100b4b:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100b4e:	83 c4 10             	add    $0x10,%esp
f0100b51:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0100b54:	7f 30                	jg     f0100b86 <debuginfo_eip+0x115>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b56:	89 fa                	mov    %edi,%edx
f0100b58:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100b5b:	8b 80 dc 1f 10 f0    	mov    -0xfefe024(%eax),%eax
f0100b61:	b9 7a d8 10 f0       	mov    $0xf010d87a,%ecx
f0100b66:	81 e9 6d 65 10 f0    	sub    $0xf010656d,%ecx
f0100b6c:	39 c8                	cmp    %ecx,%eax
f0100b6e:	73 08                	jae    f0100b78 <debuginfo_eip+0x107>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b70:	05 6d 65 10 f0       	add    $0xf010656d,%eax
f0100b75:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b78:	6b c2 0c             	imul   $0xc,%edx,%eax
f0100b7b:	8b 80 e4 1f 10 f0    	mov    -0xfefe01c(%eax),%eax
f0100b81:	89 43 10             	mov    %eax,0x10(%ebx)
f0100b84:	eb 06                	jmp    f0100b8c <debuginfo_eip+0x11b>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b86:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100b89:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b8c:	83 ec 08             	sub    $0x8,%esp
f0100b8f:	6a 3a                	push   $0x3a
f0100b91:	ff 73 08             	pushl  0x8(%ebx)
f0100b94:	e8 72 08 00 00       	call   f010140b <strfind>
f0100b99:	2b 43 08             	sub    0x8(%ebx),%eax
f0100b9c:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b9f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0100ba2:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100ba5:	05 e4 1f 10 f0       	add    $0xf0101fe4,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100baa:	83 c4 10             	add    $0x10,%esp
f0100bad:	eb 04                	jmp    f0100bb3 <debuginfo_eip+0x142>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100baf:	4f                   	dec    %edi
f0100bb0:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100bb3:	39 cf                	cmp    %ecx,%edi
f0100bb5:	7c 1b                	jl     f0100bd2 <debuginfo_eip+0x161>
	       && stabs[lline].n_type != N_SOL
f0100bb7:	8a 50 fc             	mov    -0x4(%eax),%dl
f0100bba:	80 fa 84             	cmp    $0x84,%dl
f0100bbd:	74 5d                	je     f0100c1c <debuginfo_eip+0x1ab>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100bbf:	80 fa 64             	cmp    $0x64,%dl
f0100bc2:	75 eb                	jne    f0100baf <debuginfo_eip+0x13e>
f0100bc4:	83 38 00             	cmpl   $0x0,(%eax)
f0100bc7:	74 e6                	je     f0100baf <debuginfo_eip+0x13e>
f0100bc9:	eb 51                	jmp    f0100c1c <debuginfo_eip+0x1ab>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100bcb:	05 6d 65 10 f0       	add    $0xf010656d,%eax
f0100bd0:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100bd2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100bd5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100bd8:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100bdd:	39 f2                	cmp    %esi,%edx
f0100bdf:	7d 33                	jge    f0100c14 <debuginfo_eip+0x1a3>
		for (lline = lfun + 1;
f0100be1:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0100be4:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100be7:	81 c2 e0 1f 10 f0    	add    $0xf0101fe0,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100bed:	eb 04                	jmp    f0100bf3 <debuginfo_eip+0x182>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100bef:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100bf2:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100bf3:	39 f0                	cmp    %esi,%eax
f0100bf5:	7d 18                	jge    f0100c0f <debuginfo_eip+0x19e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100bf7:	8a 0a                	mov    (%edx),%cl
f0100bf9:	83 c2 0c             	add    $0xc,%edx
f0100bfc:	80 f9 a0             	cmp    $0xa0,%cl
f0100bff:	74 ee                	je     f0100bef <debuginfo_eip+0x17e>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c01:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c06:	eb 0c                	jmp    f0100c14 <debuginfo_eip+0x1a3>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c0d:	eb 05                	jmp    f0100c14 <debuginfo_eip+0x1a3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c17:	5b                   	pop    %ebx
f0100c18:	5e                   	pop    %esi
f0100c19:	5f                   	pop    %edi
f0100c1a:	c9                   	leave  
f0100c1b:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c1c:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100c1f:	8b 87 dc 1f 10 f0    	mov    -0xfefe024(%edi),%eax
f0100c25:	ba 7a d8 10 f0       	mov    $0xf010d87a,%edx
f0100c2a:	81 ea 6d 65 10 f0    	sub    $0xf010656d,%edx
f0100c30:	39 d0                	cmp    %edx,%eax
f0100c32:	72 97                	jb     f0100bcb <debuginfo_eip+0x15a>
f0100c34:	eb 9c                	jmp    f0100bd2 <debuginfo_eip+0x161>
	...

f0100c38 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100c38:	55                   	push   %ebp
f0100c39:	89 e5                	mov    %esp,%ebp
f0100c3b:	57                   	push   %edi
f0100c3c:	56                   	push   %esi
f0100c3d:	53                   	push   %ebx
f0100c3e:	83 ec 2c             	sub    $0x2c,%esp
f0100c41:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100c44:	89 d6                	mov    %edx,%esi
f0100c46:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c49:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100c4c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100c4f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100c52:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c55:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100c58:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100c5b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c5e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100c65:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0100c68:	72 0c                	jb     f0100c76 <printnum+0x3e>
f0100c6a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100c6d:	76 07                	jbe    f0100c76 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100c6f:	4b                   	dec    %ebx
f0100c70:	85 db                	test   %ebx,%ebx
f0100c72:	7f 31                	jg     f0100ca5 <printnum+0x6d>
f0100c74:	eb 3f                	jmp    f0100cb5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100c76:	83 ec 0c             	sub    $0xc,%esp
f0100c79:	57                   	push   %edi
f0100c7a:	4b                   	dec    %ebx
f0100c7b:	53                   	push   %ebx
f0100c7c:	50                   	push   %eax
f0100c7d:	83 ec 08             	sub    $0x8,%esp
f0100c80:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100c83:	ff 75 d0             	pushl  -0x30(%ebp)
f0100c86:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c89:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c8c:	e8 a3 09 00 00       	call   f0101634 <__udivdi3>
f0100c91:	83 c4 18             	add    $0x18,%esp
f0100c94:	52                   	push   %edx
f0100c95:	50                   	push   %eax
f0100c96:	89 f2                	mov    %esi,%edx
f0100c98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c9b:	e8 98 ff ff ff       	call   f0100c38 <printnum>
f0100ca0:	83 c4 20             	add    $0x20,%esp
f0100ca3:	eb 10                	jmp    f0100cb5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100ca5:	83 ec 08             	sub    $0x8,%esp
f0100ca8:	56                   	push   %esi
f0100ca9:	57                   	push   %edi
f0100caa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100cad:	4b                   	dec    %ebx
f0100cae:	83 c4 10             	add    $0x10,%esp
f0100cb1:	85 db                	test   %ebx,%ebx
f0100cb3:	7f f0                	jg     f0100ca5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100cb5:	83 ec 08             	sub    $0x8,%esp
f0100cb8:	56                   	push   %esi
f0100cb9:	83 ec 04             	sub    $0x4,%esp
f0100cbc:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100cbf:	ff 75 d0             	pushl  -0x30(%ebp)
f0100cc2:	ff 75 dc             	pushl  -0x24(%ebp)
f0100cc5:	ff 75 d8             	pushl  -0x28(%ebp)
f0100cc8:	e8 83 0a 00 00       	call   f0101750 <__umoddi3>
f0100ccd:	83 c4 14             	add    $0x14,%esp
f0100cd0:	0f be 80 c9 1d 10 f0 	movsbl -0xfefe237(%eax),%eax
f0100cd7:	50                   	push   %eax
f0100cd8:	ff 55 e4             	call   *-0x1c(%ebp)
f0100cdb:	83 c4 10             	add    $0x10,%esp
}
f0100cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ce1:	5b                   	pop    %ebx
f0100ce2:	5e                   	pop    %esi
f0100ce3:	5f                   	pop    %edi
f0100ce4:	c9                   	leave  
f0100ce5:	c3                   	ret    

f0100ce6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100ce6:	55                   	push   %ebp
f0100ce7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100ce9:	83 fa 01             	cmp    $0x1,%edx
f0100cec:	7e 0e                	jle    f0100cfc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100cee:	8b 10                	mov    (%eax),%edx
f0100cf0:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100cf3:	89 08                	mov    %ecx,(%eax)
f0100cf5:	8b 02                	mov    (%edx),%eax
f0100cf7:	8b 52 04             	mov    0x4(%edx),%edx
f0100cfa:	eb 22                	jmp    f0100d1e <getuint+0x38>
	else if (lflag)
f0100cfc:	85 d2                	test   %edx,%edx
f0100cfe:	74 10                	je     f0100d10 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d00:	8b 10                	mov    (%eax),%edx
f0100d02:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d05:	89 08                	mov    %ecx,(%eax)
f0100d07:	8b 02                	mov    (%edx),%eax
f0100d09:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d0e:	eb 0e                	jmp    f0100d1e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100d10:	8b 10                	mov    (%eax),%edx
f0100d12:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d15:	89 08                	mov    %ecx,(%eax)
f0100d17:	8b 02                	mov    (%edx),%eax
f0100d19:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100d1e:	c9                   	leave  
f0100d1f:	c3                   	ret    

f0100d20 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0100d20:	55                   	push   %ebp
f0100d21:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d23:	83 fa 01             	cmp    $0x1,%edx
f0100d26:	7e 0e                	jle    f0100d36 <getint+0x16>
		return va_arg(*ap, long long);
f0100d28:	8b 10                	mov    (%eax),%edx
f0100d2a:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d2d:	89 08                	mov    %ecx,(%eax)
f0100d2f:	8b 02                	mov    (%edx),%eax
f0100d31:	8b 52 04             	mov    0x4(%edx),%edx
f0100d34:	eb 1a                	jmp    f0100d50 <getint+0x30>
	else if (lflag)
f0100d36:	85 d2                	test   %edx,%edx
f0100d38:	74 0c                	je     f0100d46 <getint+0x26>
		return va_arg(*ap, long);
f0100d3a:	8b 10                	mov    (%eax),%edx
f0100d3c:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d3f:	89 08                	mov    %ecx,(%eax)
f0100d41:	8b 02                	mov    (%edx),%eax
f0100d43:	99                   	cltd   
f0100d44:	eb 0a                	jmp    f0100d50 <getint+0x30>
	else
		return va_arg(*ap, int);
f0100d46:	8b 10                	mov    (%eax),%edx
f0100d48:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d4b:	89 08                	mov    %ecx,(%eax)
f0100d4d:	8b 02                	mov    (%edx),%eax
f0100d4f:	99                   	cltd   
}
f0100d50:	c9                   	leave  
f0100d51:	c3                   	ret    

f0100d52 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d52:	55                   	push   %ebp
f0100d53:	89 e5                	mov    %esp,%ebp
f0100d55:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d58:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100d5b:	8b 10                	mov    (%eax),%edx
f0100d5d:	3b 50 04             	cmp    0x4(%eax),%edx
f0100d60:	73 08                	jae    f0100d6a <sprintputch+0x18>
		*b->buf++ = ch;
f0100d62:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100d65:	88 0a                	mov    %cl,(%edx)
f0100d67:	42                   	inc    %edx
f0100d68:	89 10                	mov    %edx,(%eax)
}
f0100d6a:	c9                   	leave  
f0100d6b:	c3                   	ret    

f0100d6c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100d6c:	55                   	push   %ebp
f0100d6d:	89 e5                	mov    %esp,%ebp
f0100d6f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100d72:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100d75:	50                   	push   %eax
f0100d76:	ff 75 10             	pushl  0x10(%ebp)
f0100d79:	ff 75 0c             	pushl  0xc(%ebp)
f0100d7c:	ff 75 08             	pushl  0x8(%ebp)
f0100d7f:	e8 05 00 00 00       	call   f0100d89 <vprintfmt>
	va_end(ap);
f0100d84:	83 c4 10             	add    $0x10,%esp
}
f0100d87:	c9                   	leave  
f0100d88:	c3                   	ret    

f0100d89 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100d89:	55                   	push   %ebp
f0100d8a:	89 e5                	mov    %esp,%ebp
f0100d8c:	57                   	push   %edi
f0100d8d:	56                   	push   %esi
f0100d8e:	53                   	push   %ebx
f0100d8f:	83 ec 2c             	sub    $0x2c,%esp
f0100d92:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100d95:	8b 75 10             	mov    0x10(%ebp),%esi
f0100d98:	eb 21                	jmp    f0100dbb <vprintfmt+0x32>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
f0100d9a:	85 c0                	test   %eax,%eax
f0100d9c:	75 12                	jne    f0100db0 <vprintfmt+0x27>
				csa = 0x0700;
f0100d9e:	c7 05 44 89 11 f0 00 	movl   $0x700,0xf0118944
f0100da5:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f0100da8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dab:	5b                   	pop    %ebx
f0100dac:	5e                   	pop    %esi
f0100dad:	5f                   	pop    %edi
f0100dae:	c9                   	leave  
f0100daf:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
f0100db0:	83 ec 08             	sub    $0x8,%esp
f0100db3:	57                   	push   %edi
f0100db4:	50                   	push   %eax
f0100db5:	ff 55 08             	call   *0x8(%ebp)
f0100db8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100dbb:	0f b6 06             	movzbl (%esi),%eax
f0100dbe:	46                   	inc    %esi
f0100dbf:	83 f8 25             	cmp    $0x25,%eax
f0100dc2:	75 d6                	jne    f0100d9a <vprintfmt+0x11>
f0100dc4:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0100dc8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100dcf:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0100dd6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100ddd:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100de2:	eb 28                	jmp    f0100e0c <vprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100de4:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100de6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0100dea:	eb 20                	jmp    f0100e0c <vprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dec:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100dee:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0100df2:	eb 18                	jmp    f0100e0c <vprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100df4:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0100df6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100dfd:	eb 0d                	jmp    f0100e0c <vprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100dff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e05:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e0c:	8a 06                	mov    (%esi),%al
f0100e0e:	0f b6 d0             	movzbl %al,%edx
f0100e11:	8d 5e 01             	lea    0x1(%esi),%ebx
f0100e14:	83 e8 23             	sub    $0x23,%eax
f0100e17:	3c 55                	cmp    $0x55,%al
f0100e19:	0f 87 e6 02 00 00    	ja     f0101105 <vprintfmt+0x37c>
f0100e1f:	0f b6 c0             	movzbl %al,%eax
f0100e22:	ff 24 85 58 1e 10 f0 	jmp    *-0xfefe1a8(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e29:	83 ea 30             	sub    $0x30,%edx
f0100e2c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0100e2f:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0100e32:	8d 50 d0             	lea    -0x30(%eax),%edx
f0100e35:	83 fa 09             	cmp    $0x9,%edx
f0100e38:	77 44                	ja     f0100e7e <vprintfmt+0xf5>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e3a:	89 de                	mov    %ebx,%esi
f0100e3c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e3f:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0100e40:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0100e43:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0100e47:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0100e4a:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0100e4d:	83 fb 09             	cmp    $0x9,%ebx
f0100e50:	76 ed                	jbe    f0100e3f <vprintfmt+0xb6>
f0100e52:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0100e55:	eb 29                	jmp    f0100e80 <vprintfmt+0xf7>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e57:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e5a:	8d 50 04             	lea    0x4(%eax),%edx
f0100e5d:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e60:	8b 00                	mov    (%eax),%eax
f0100e62:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e65:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100e67:	eb 17                	jmp    f0100e80 <vprintfmt+0xf7>

		case '.':
			if (width < 0)
f0100e69:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100e6d:	78 85                	js     f0100df4 <vprintfmt+0x6b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e6f:	89 de                	mov    %ebx,%esi
f0100e71:	eb 99                	jmp    f0100e0c <vprintfmt+0x83>
f0100e73:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100e75:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0100e7c:	eb 8e                	jmp    f0100e0c <vprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e7e:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100e80:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100e84:	79 86                	jns    f0100e0c <vprintfmt+0x83>
f0100e86:	e9 74 ff ff ff       	jmp    f0100dff <vprintfmt+0x76>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100e8b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e8c:	89 de                	mov    %ebx,%esi
f0100e8e:	e9 79 ff ff ff       	jmp    f0100e0c <vprintfmt+0x83>
f0100e93:	89 5d dc             	mov    %ebx,-0x24(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100e96:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e99:	8d 50 04             	lea    0x4(%eax),%edx
f0100e9c:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e9f:	83 ec 08             	sub    $0x8,%esp
f0100ea2:	57                   	push   %edi
f0100ea3:	ff 30                	pushl  (%eax)
f0100ea5:	ff 55 08             	call   *0x8(%ebp)
			break;
f0100ea8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eab:	8b 75 dc             	mov    -0x24(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100eae:	e9 08 ff ff ff       	jmp    f0100dbb <vprintfmt+0x32>
f0100eb3:	89 5d dc             	mov    %ebx,-0x24(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100eb6:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eb9:	8d 50 04             	lea    0x4(%eax),%edx
f0100ebc:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ebf:	8b 00                	mov    (%eax),%eax
f0100ec1:	85 c0                	test   %eax,%eax
f0100ec3:	79 02                	jns    f0100ec7 <vprintfmt+0x13e>
f0100ec5:	f7 d8                	neg    %eax
f0100ec7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100ec9:	83 f8 06             	cmp    $0x6,%eax
f0100ecc:	7f 0b                	jg     f0100ed9 <vprintfmt+0x150>
f0100ece:	8b 04 85 b0 1f 10 f0 	mov    -0xfefe050(,%eax,4),%eax
f0100ed5:	85 c0                	test   %eax,%eax
f0100ed7:	75 1a                	jne    f0100ef3 <vprintfmt+0x16a>
				printfmt(putch, putdat, "error %d", err);
f0100ed9:	52                   	push   %edx
f0100eda:	68 e1 1d 10 f0       	push   $0xf0101de1
f0100edf:	57                   	push   %edi
f0100ee0:	ff 75 08             	pushl  0x8(%ebp)
f0100ee3:	e8 84 fe ff ff       	call   f0100d6c <printfmt>
f0100ee8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eeb:	8b 75 dc             	mov    -0x24(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100eee:	e9 c8 fe ff ff       	jmp    f0100dbb <vprintfmt+0x32>
			else
				printfmt(putch, putdat, "%s", p);
f0100ef3:	50                   	push   %eax
f0100ef4:	68 ea 1d 10 f0       	push   $0xf0101dea
f0100ef9:	57                   	push   %edi
f0100efa:	ff 75 08             	pushl  0x8(%ebp)
f0100efd:	e8 6a fe ff ff       	call   f0100d6c <printfmt>
f0100f02:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f05:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100f08:	e9 ae fe ff ff       	jmp    f0100dbb <vprintfmt+0x32>
f0100f0d:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100f10:	89 de                	mov    %ebx,%esi
f0100f12:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100f15:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f18:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f1b:	8d 50 04             	lea    0x4(%eax),%edx
f0100f1e:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f21:	8b 00                	mov    (%eax),%eax
f0100f23:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f26:	85 c0                	test   %eax,%eax
f0100f28:	75 07                	jne    f0100f31 <vprintfmt+0x1a8>
				p = "(null)";
f0100f2a:	c7 45 d0 da 1d 10 f0 	movl   $0xf0101dda,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0100f31:	85 db                	test   %ebx,%ebx
f0100f33:	7e 42                	jle    f0100f77 <vprintfmt+0x1ee>
f0100f35:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0100f39:	74 3c                	je     f0100f77 <vprintfmt+0x1ee>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f3b:	83 ec 08             	sub    $0x8,%esp
f0100f3e:	51                   	push   %ecx
f0100f3f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f42:	e8 3d 03 00 00       	call   f0101284 <strnlen>
f0100f47:	29 c3                	sub    %eax,%ebx
f0100f49:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100f4c:	83 c4 10             	add    $0x10,%esp
f0100f4f:	85 db                	test   %ebx,%ebx
f0100f51:	7e 24                	jle    f0100f77 <vprintfmt+0x1ee>
					putch(padc, putdat);
f0100f53:	0f be 5d d8          	movsbl -0x28(%ebp),%ebx
f0100f57:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0100f5a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100f5d:	83 ec 08             	sub    $0x8,%esp
f0100f60:	57                   	push   %edi
f0100f61:	53                   	push   %ebx
f0100f62:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f65:	4e                   	dec    %esi
f0100f66:	83 c4 10             	add    $0x10,%esp
f0100f69:	85 f6                	test   %esi,%esi
f0100f6b:	7f f0                	jg     f0100f5d <vprintfmt+0x1d4>
f0100f6d:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0100f70:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f77:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100f7a:	0f be 02             	movsbl (%edx),%eax
f0100f7d:	85 c0                	test   %eax,%eax
f0100f7f:	75 47                	jne    f0100fc8 <vprintfmt+0x23f>
f0100f81:	eb 37                	jmp    f0100fba <vprintfmt+0x231>
				if (altflag && (ch < ' ' || ch > '~'))
f0100f83:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f87:	74 16                	je     f0100f9f <vprintfmt+0x216>
f0100f89:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100f8c:	83 fa 5e             	cmp    $0x5e,%edx
f0100f8f:	76 0e                	jbe    f0100f9f <vprintfmt+0x216>
					putch('?', putdat);
f0100f91:	83 ec 08             	sub    $0x8,%esp
f0100f94:	57                   	push   %edi
f0100f95:	6a 3f                	push   $0x3f
f0100f97:	ff 55 08             	call   *0x8(%ebp)
f0100f9a:	83 c4 10             	add    $0x10,%esp
f0100f9d:	eb 0b                	jmp    f0100faa <vprintfmt+0x221>
				else
					putch(ch, putdat);
f0100f9f:	83 ec 08             	sub    $0x8,%esp
f0100fa2:	57                   	push   %edi
f0100fa3:	50                   	push   %eax
f0100fa4:	ff 55 08             	call   *0x8(%ebp)
f0100fa7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100faa:	ff 4d e4             	decl   -0x1c(%ebp)
f0100fad:	0f be 03             	movsbl (%ebx),%eax
f0100fb0:	85 c0                	test   %eax,%eax
f0100fb2:	74 03                	je     f0100fb7 <vprintfmt+0x22e>
f0100fb4:	43                   	inc    %ebx
f0100fb5:	eb 1b                	jmp    f0100fd2 <vprintfmt+0x249>
f0100fb7:	8b 75 d8             	mov    -0x28(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100fba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100fbe:	7f 1e                	jg     f0100fde <vprintfmt+0x255>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fc0:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100fc3:	e9 f3 fd ff ff       	jmp    f0100dbb <vprintfmt+0x32>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100fc8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100fcb:	43                   	inc    %ebx
f0100fcc:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0100fcf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0100fd2:	85 f6                	test   %esi,%esi
f0100fd4:	78 ad                	js     f0100f83 <vprintfmt+0x1fa>
f0100fd6:	4e                   	dec    %esi
f0100fd7:	79 aa                	jns    f0100f83 <vprintfmt+0x1fa>
f0100fd9:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0100fdc:	eb dc                	jmp    f0100fba <vprintfmt+0x231>
f0100fde:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100fe1:	83 ec 08             	sub    $0x8,%esp
f0100fe4:	57                   	push   %edi
f0100fe5:	6a 20                	push   $0x20
f0100fe7:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100fea:	4b                   	dec    %ebx
f0100feb:	83 c4 10             	add    $0x10,%esp
f0100fee:	85 db                	test   %ebx,%ebx
f0100ff0:	7f ef                	jg     f0100fe1 <vprintfmt+0x258>
f0100ff2:	e9 c4 fd ff ff       	jmp    f0100dbb <vprintfmt+0x32>
f0100ff7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0100ffa:	89 ca                	mov    %ecx,%edx
f0100ffc:	8d 45 14             	lea    0x14(%ebp),%eax
f0100fff:	e8 1c fd ff ff       	call   f0100d20 <getint>
f0101004:	89 c3                	mov    %eax,%ebx
f0101006:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0101008:	85 d2                	test   %edx,%edx
f010100a:	78 0a                	js     f0101016 <vprintfmt+0x28d>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010100c:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101011:	e9 9c 00 00 00       	jmp    f01010b2 <vprintfmt+0x329>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0101016:	83 ec 08             	sub    $0x8,%esp
f0101019:	57                   	push   %edi
f010101a:	6a 2d                	push   $0x2d
f010101c:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010101f:	89 d8                	mov    %ebx,%eax
f0101021:	89 f2                	mov    %esi,%edx
f0101023:	f7 d8                	neg    %eax
f0101025:	83 d2 00             	adc    $0x0,%edx
f0101028:	f7 da                	neg    %edx
f010102a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010102d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101032:	eb 7e                	jmp    f01010b2 <vprintfmt+0x329>
f0101034:	89 5d dc             	mov    %ebx,-0x24(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101037:	89 ca                	mov    %ecx,%edx
f0101039:	8d 45 14             	lea    0x14(%ebp),%eax
f010103c:	e8 a5 fc ff ff       	call   f0100ce6 <getuint>
			base = 10;
f0101041:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101046:	eb 6a                	jmp    f01010b2 <vprintfmt+0x329>
f0101048:	89 5d dc             	mov    %ebx,-0x24(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010104b:	83 ec 08             	sub    $0x8,%esp
f010104e:	57                   	push   %edi
f010104f:	6a 58                	push   $0x58
f0101051:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0101054:	83 c4 08             	add    $0x8,%esp
f0101057:	57                   	push   %edi
f0101058:	6a 58                	push   $0x58
f010105a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f010105d:	83 c4 08             	add    $0x8,%esp
f0101060:	57                   	push   %edi
f0101061:	6a 58                	push   $0x58
f0101063:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101066:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101069:	8b 75 dc             	mov    -0x24(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f010106c:	e9 4a fd ff ff       	jmp    f0100dbb <vprintfmt+0x32>
f0101071:	89 5d dc             	mov    %ebx,-0x24(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0101074:	83 ec 08             	sub    $0x8,%esp
f0101077:	57                   	push   %edi
f0101078:	6a 30                	push   $0x30
f010107a:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010107d:	83 c4 08             	add    $0x8,%esp
f0101080:	57                   	push   %edi
f0101081:	6a 78                	push   $0x78
f0101083:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101086:	8b 45 14             	mov    0x14(%ebp),%eax
f0101089:	8d 50 04             	lea    0x4(%eax),%edx
f010108c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010108f:	8b 00                	mov    (%eax),%eax
f0101091:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101096:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101099:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010109e:	eb 12                	jmp    f01010b2 <vprintfmt+0x329>
f01010a0:	89 5d dc             	mov    %ebx,-0x24(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01010a3:	89 ca                	mov    %ecx,%edx
f01010a5:	8d 45 14             	lea    0x14(%ebp),%eax
f01010a8:	e8 39 fc ff ff       	call   f0100ce6 <getuint>
			base = 16;
f01010ad:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01010b2:	83 ec 0c             	sub    $0xc,%esp
f01010b5:	0f be 5d d8          	movsbl -0x28(%ebp),%ebx
f01010b9:	53                   	push   %ebx
f01010ba:	ff 75 e4             	pushl  -0x1c(%ebp)
f01010bd:	51                   	push   %ecx
f01010be:	52                   	push   %edx
f01010bf:	50                   	push   %eax
f01010c0:	89 fa                	mov    %edi,%edx
f01010c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01010c5:	e8 6e fb ff ff       	call   f0100c38 <printnum>
			break;
f01010ca:	83 c4 20             	add    $0x20,%esp
f01010cd:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01010d0:	e9 e6 fc ff ff       	jmp    f0100dbb <vprintfmt+0x32>
f01010d5:	89 5d dc             	mov    %ebx,-0x24(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01010d8:	83 ec 08             	sub    $0x8,%esp
f01010db:	57                   	push   %edi
f01010dc:	52                   	push   %edx
f01010dd:	ff 55 08             	call   *0x8(%ebp)
			break;
f01010e0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010e3:	8b 75 dc             	mov    -0x24(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01010e6:	e9 d0 fc ff ff       	jmp    f0100dbb <vprintfmt+0x32>
f01010eb:	89 5d dc             	mov    %ebx,-0x24(%ebp)

		case 'm':
			num = getint(&ap, lflag);
f01010ee:	89 ca                	mov    %ecx,%edx
f01010f0:	8d 45 14             	lea    0x14(%ebp),%eax
f01010f3:	e8 28 fc ff ff       	call   f0100d20 <getint>
			csa = num;
f01010f8:	a3 44 89 11 f0       	mov    %eax,0xf0118944
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010fd:	8b 75 dc             	mov    -0x24(%ebp),%esi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
f0101100:	e9 b6 fc ff ff       	jmp    f0100dbb <vprintfmt+0x32>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101105:	83 ec 08             	sub    $0x8,%esp
f0101108:	57                   	push   %edi
f0101109:	6a 25                	push   $0x25
f010110b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010110e:	83 c4 10             	add    $0x10,%esp
f0101111:	eb 02                	jmp    f0101115 <vprintfmt+0x38c>
f0101113:	89 c6                	mov    %eax,%esi
f0101115:	8d 46 ff             	lea    -0x1(%esi),%eax
f0101118:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010111c:	75 f5                	jne    f0101113 <vprintfmt+0x38a>
f010111e:	e9 98 fc ff ff       	jmp    f0100dbb <vprintfmt+0x32>

f0101123 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101123:	55                   	push   %ebp
f0101124:	89 e5                	mov    %esp,%ebp
f0101126:	83 ec 18             	sub    $0x18,%esp
f0101129:	8b 45 08             	mov    0x8(%ebp),%eax
f010112c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010112f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101132:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101136:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101139:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101140:	85 c0                	test   %eax,%eax
f0101142:	74 26                	je     f010116a <vsnprintf+0x47>
f0101144:	85 d2                	test   %edx,%edx
f0101146:	7e 29                	jle    f0101171 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101148:	ff 75 14             	pushl  0x14(%ebp)
f010114b:	ff 75 10             	pushl  0x10(%ebp)
f010114e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101151:	50                   	push   %eax
f0101152:	68 52 0d 10 f0       	push   $0xf0100d52
f0101157:	e8 2d fc ff ff       	call   f0100d89 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010115c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010115f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101162:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101165:	83 c4 10             	add    $0x10,%esp
f0101168:	eb 0c                	jmp    f0101176 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010116a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010116f:	eb 05                	jmp    f0101176 <vsnprintf+0x53>
f0101171:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101176:	c9                   	leave  
f0101177:	c3                   	ret    

f0101178 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101178:	55                   	push   %ebp
f0101179:	89 e5                	mov    %esp,%ebp
f010117b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010117e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101181:	50                   	push   %eax
f0101182:	ff 75 10             	pushl  0x10(%ebp)
f0101185:	ff 75 0c             	pushl  0xc(%ebp)
f0101188:	ff 75 08             	pushl  0x8(%ebp)
f010118b:	e8 93 ff ff ff       	call   f0101123 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101190:	c9                   	leave  
f0101191:	c3                   	ret    
	...

f0101194 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101194:	55                   	push   %ebp
f0101195:	89 e5                	mov    %esp,%ebp
f0101197:	57                   	push   %edi
f0101198:	56                   	push   %esi
f0101199:	53                   	push   %ebx
f010119a:	83 ec 0c             	sub    $0xc,%esp
f010119d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01011a0:	85 c0                	test   %eax,%eax
f01011a2:	74 11                	je     f01011b5 <readline+0x21>
		cprintf("%s", prompt);
f01011a4:	83 ec 08             	sub    $0x8,%esp
f01011a7:	50                   	push   %eax
f01011a8:	68 ea 1d 10 f0       	push   $0xf0101dea
f01011ad:	e8 83 f7 ff ff       	call   f0100935 <cprintf>
f01011b2:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01011b5:	83 ec 0c             	sub    $0xc,%esp
f01011b8:	6a 00                	push   $0x0
f01011ba:	e8 6d f4 ff ff       	call   f010062c <iscons>
f01011bf:	89 c7                	mov    %eax,%edi
f01011c1:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01011c4:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01011c9:	e8 4d f4 ff ff       	call   f010061b <getchar>
f01011ce:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01011d0:	85 c0                	test   %eax,%eax
f01011d2:	79 18                	jns    f01011ec <readline+0x58>
			cprintf("read error: %e\n", c);
f01011d4:	83 ec 08             	sub    $0x8,%esp
f01011d7:	50                   	push   %eax
f01011d8:	68 cc 1f 10 f0       	push   $0xf0101fcc
f01011dd:	e8 53 f7 ff ff       	call   f0100935 <cprintf>
			return NULL;
f01011e2:	83 c4 10             	add    $0x10,%esp
f01011e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01011ea:	eb 6f                	jmp    f010125b <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01011ec:	83 f8 08             	cmp    $0x8,%eax
f01011ef:	74 05                	je     f01011f6 <readline+0x62>
f01011f1:	83 f8 7f             	cmp    $0x7f,%eax
f01011f4:	75 18                	jne    f010120e <readline+0x7a>
f01011f6:	85 f6                	test   %esi,%esi
f01011f8:	7e 14                	jle    f010120e <readline+0x7a>
			if (echoing)
f01011fa:	85 ff                	test   %edi,%edi
f01011fc:	74 0d                	je     f010120b <readline+0x77>
				cputchar('\b');
f01011fe:	83 ec 0c             	sub    $0xc,%esp
f0101201:	6a 08                	push   $0x8
f0101203:	e8 03 f4 ff ff       	call   f010060b <cputchar>
f0101208:	83 c4 10             	add    $0x10,%esp
			i--;
f010120b:	4e                   	dec    %esi
f010120c:	eb bb                	jmp    f01011c9 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010120e:	83 fb 1f             	cmp    $0x1f,%ebx
f0101211:	7e 21                	jle    f0101234 <readline+0xa0>
f0101213:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101219:	7f 19                	jg     f0101234 <readline+0xa0>
			if (echoing)
f010121b:	85 ff                	test   %edi,%edi
f010121d:	74 0c                	je     f010122b <readline+0x97>
				cputchar(c);
f010121f:	83 ec 0c             	sub    $0xc,%esp
f0101222:	53                   	push   %ebx
f0101223:	e8 e3 f3 ff ff       	call   f010060b <cputchar>
f0101228:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010122b:	88 9e 40 85 11 f0    	mov    %bl,-0xfee7ac0(%esi)
f0101231:	46                   	inc    %esi
f0101232:	eb 95                	jmp    f01011c9 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101234:	83 fb 0a             	cmp    $0xa,%ebx
f0101237:	74 05                	je     f010123e <readline+0xaa>
f0101239:	83 fb 0d             	cmp    $0xd,%ebx
f010123c:	75 8b                	jne    f01011c9 <readline+0x35>
			if (echoing)
f010123e:	85 ff                	test   %edi,%edi
f0101240:	74 0d                	je     f010124f <readline+0xbb>
				cputchar('\n');
f0101242:	83 ec 0c             	sub    $0xc,%esp
f0101245:	6a 0a                	push   $0xa
f0101247:	e8 bf f3 ff ff       	call   f010060b <cputchar>
f010124c:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010124f:	c6 86 40 85 11 f0 00 	movb   $0x0,-0xfee7ac0(%esi)
			return buf;
f0101256:	b8 40 85 11 f0       	mov    $0xf0118540,%eax
		}
	}
}
f010125b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010125e:	5b                   	pop    %ebx
f010125f:	5e                   	pop    %esi
f0101260:	5f                   	pop    %edi
f0101261:	c9                   	leave  
f0101262:	c3                   	ret    
	...

f0101264 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101264:	55                   	push   %ebp
f0101265:	89 e5                	mov    %esp,%ebp
f0101267:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010126a:	80 3a 00             	cmpb   $0x0,(%edx)
f010126d:	74 0e                	je     f010127d <strlen+0x19>
f010126f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101274:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101275:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101279:	75 f9                	jne    f0101274 <strlen+0x10>
f010127b:	eb 05                	jmp    f0101282 <strlen+0x1e>
f010127d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101282:	c9                   	leave  
f0101283:	c3                   	ret    

f0101284 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101284:	55                   	push   %ebp
f0101285:	89 e5                	mov    %esp,%ebp
f0101287:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010128a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010128d:	85 d2                	test   %edx,%edx
f010128f:	74 17                	je     f01012a8 <strnlen+0x24>
f0101291:	80 39 00             	cmpb   $0x0,(%ecx)
f0101294:	74 19                	je     f01012af <strnlen+0x2b>
f0101296:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f010129b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010129c:	39 d0                	cmp    %edx,%eax
f010129e:	74 14                	je     f01012b4 <strnlen+0x30>
f01012a0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01012a4:	75 f5                	jne    f010129b <strnlen+0x17>
f01012a6:	eb 0c                	jmp    f01012b4 <strnlen+0x30>
f01012a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01012ad:	eb 05                	jmp    f01012b4 <strnlen+0x30>
f01012af:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01012b4:	c9                   	leave  
f01012b5:	c3                   	ret    

f01012b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01012b6:	55                   	push   %ebp
f01012b7:	89 e5                	mov    %esp,%ebp
f01012b9:	53                   	push   %ebx
f01012ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01012bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01012c0:	ba 00 00 00 00       	mov    $0x0,%edx
f01012c5:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01012c8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01012cb:	42                   	inc    %edx
f01012cc:	84 c9                	test   %cl,%cl
f01012ce:	75 f5                	jne    f01012c5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01012d0:	5b                   	pop    %ebx
f01012d1:	c9                   	leave  
f01012d2:	c3                   	ret    

f01012d3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01012d3:	55                   	push   %ebp
f01012d4:	89 e5                	mov    %esp,%ebp
f01012d6:	53                   	push   %ebx
f01012d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01012da:	53                   	push   %ebx
f01012db:	e8 84 ff ff ff       	call   f0101264 <strlen>
f01012e0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01012e3:	ff 75 0c             	pushl  0xc(%ebp)
f01012e6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f01012e9:	50                   	push   %eax
f01012ea:	e8 c7 ff ff ff       	call   f01012b6 <strcpy>
	return dst;
}
f01012ef:	89 d8                	mov    %ebx,%eax
f01012f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012f4:	c9                   	leave  
f01012f5:	c3                   	ret    

f01012f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01012f6:	55                   	push   %ebp
f01012f7:	89 e5                	mov    %esp,%ebp
f01012f9:	56                   	push   %esi
f01012fa:	53                   	push   %ebx
f01012fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01012fe:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101301:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101304:	85 f6                	test   %esi,%esi
f0101306:	74 15                	je     f010131d <strncpy+0x27>
f0101308:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010130d:	8a 1a                	mov    (%edx),%bl
f010130f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101312:	80 3a 01             	cmpb   $0x1,(%edx)
f0101315:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101318:	41                   	inc    %ecx
f0101319:	39 ce                	cmp    %ecx,%esi
f010131b:	77 f0                	ja     f010130d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010131d:	5b                   	pop    %ebx
f010131e:	5e                   	pop    %esi
f010131f:	c9                   	leave  
f0101320:	c3                   	ret    

f0101321 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101321:	55                   	push   %ebp
f0101322:	89 e5                	mov    %esp,%ebp
f0101324:	57                   	push   %edi
f0101325:	56                   	push   %esi
f0101326:	53                   	push   %ebx
f0101327:	8b 7d 08             	mov    0x8(%ebp),%edi
f010132a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010132d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101330:	85 f6                	test   %esi,%esi
f0101332:	74 32                	je     f0101366 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0101334:	83 fe 01             	cmp    $0x1,%esi
f0101337:	74 22                	je     f010135b <strlcpy+0x3a>
f0101339:	8a 0b                	mov    (%ebx),%cl
f010133b:	84 c9                	test   %cl,%cl
f010133d:	74 20                	je     f010135f <strlcpy+0x3e>
f010133f:	89 f8                	mov    %edi,%eax
f0101341:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0101346:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101349:	88 08                	mov    %cl,(%eax)
f010134b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010134c:	39 f2                	cmp    %esi,%edx
f010134e:	74 11                	je     f0101361 <strlcpy+0x40>
f0101350:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0101354:	42                   	inc    %edx
f0101355:	84 c9                	test   %cl,%cl
f0101357:	75 f0                	jne    f0101349 <strlcpy+0x28>
f0101359:	eb 06                	jmp    f0101361 <strlcpy+0x40>
f010135b:	89 f8                	mov    %edi,%eax
f010135d:	eb 02                	jmp    f0101361 <strlcpy+0x40>
f010135f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101361:	c6 00 00             	movb   $0x0,(%eax)
f0101364:	eb 02                	jmp    f0101368 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101366:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0101368:	29 f8                	sub    %edi,%eax
}
f010136a:	5b                   	pop    %ebx
f010136b:	5e                   	pop    %esi
f010136c:	5f                   	pop    %edi
f010136d:	c9                   	leave  
f010136e:	c3                   	ret    

f010136f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010136f:	55                   	push   %ebp
f0101370:	89 e5                	mov    %esp,%ebp
f0101372:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101375:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101378:	8a 01                	mov    (%ecx),%al
f010137a:	84 c0                	test   %al,%al
f010137c:	74 10                	je     f010138e <strcmp+0x1f>
f010137e:	3a 02                	cmp    (%edx),%al
f0101380:	75 0c                	jne    f010138e <strcmp+0x1f>
		p++, q++;
f0101382:	41                   	inc    %ecx
f0101383:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101384:	8a 01                	mov    (%ecx),%al
f0101386:	84 c0                	test   %al,%al
f0101388:	74 04                	je     f010138e <strcmp+0x1f>
f010138a:	3a 02                	cmp    (%edx),%al
f010138c:	74 f4                	je     f0101382 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010138e:	0f b6 c0             	movzbl %al,%eax
f0101391:	0f b6 12             	movzbl (%edx),%edx
f0101394:	29 d0                	sub    %edx,%eax
}
f0101396:	c9                   	leave  
f0101397:	c3                   	ret    

f0101398 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101398:	55                   	push   %ebp
f0101399:	89 e5                	mov    %esp,%ebp
f010139b:	53                   	push   %ebx
f010139c:	8b 55 08             	mov    0x8(%ebp),%edx
f010139f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013a2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01013a5:	85 c0                	test   %eax,%eax
f01013a7:	74 1b                	je     f01013c4 <strncmp+0x2c>
f01013a9:	8a 1a                	mov    (%edx),%bl
f01013ab:	84 db                	test   %bl,%bl
f01013ad:	74 24                	je     f01013d3 <strncmp+0x3b>
f01013af:	3a 19                	cmp    (%ecx),%bl
f01013b1:	75 20                	jne    f01013d3 <strncmp+0x3b>
f01013b3:	48                   	dec    %eax
f01013b4:	74 15                	je     f01013cb <strncmp+0x33>
		n--, p++, q++;
f01013b6:	42                   	inc    %edx
f01013b7:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01013b8:	8a 1a                	mov    (%edx),%bl
f01013ba:	84 db                	test   %bl,%bl
f01013bc:	74 15                	je     f01013d3 <strncmp+0x3b>
f01013be:	3a 19                	cmp    (%ecx),%bl
f01013c0:	74 f1                	je     f01013b3 <strncmp+0x1b>
f01013c2:	eb 0f                	jmp    f01013d3 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01013c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01013c9:	eb 05                	jmp    f01013d0 <strncmp+0x38>
f01013cb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01013d0:	5b                   	pop    %ebx
f01013d1:	c9                   	leave  
f01013d2:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01013d3:	0f b6 02             	movzbl (%edx),%eax
f01013d6:	0f b6 11             	movzbl (%ecx),%edx
f01013d9:	29 d0                	sub    %edx,%eax
f01013db:	eb f3                	jmp    f01013d0 <strncmp+0x38>

f01013dd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01013dd:	55                   	push   %ebp
f01013de:	89 e5                	mov    %esp,%ebp
f01013e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01013e3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01013e6:	8a 10                	mov    (%eax),%dl
f01013e8:	84 d2                	test   %dl,%dl
f01013ea:	74 18                	je     f0101404 <strchr+0x27>
		if (*s == c)
f01013ec:	38 ca                	cmp    %cl,%dl
f01013ee:	75 06                	jne    f01013f6 <strchr+0x19>
f01013f0:	eb 17                	jmp    f0101409 <strchr+0x2c>
f01013f2:	38 ca                	cmp    %cl,%dl
f01013f4:	74 13                	je     f0101409 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01013f6:	40                   	inc    %eax
f01013f7:	8a 10                	mov    (%eax),%dl
f01013f9:	84 d2                	test   %dl,%dl
f01013fb:	75 f5                	jne    f01013f2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f01013fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0101402:	eb 05                	jmp    f0101409 <strchr+0x2c>
f0101404:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101409:	c9                   	leave  
f010140a:	c3                   	ret    

f010140b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010140b:	55                   	push   %ebp
f010140c:	89 e5                	mov    %esp,%ebp
f010140e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101411:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0101414:	8a 10                	mov    (%eax),%dl
f0101416:	84 d2                	test   %dl,%dl
f0101418:	74 11                	je     f010142b <strfind+0x20>
		if (*s == c)
f010141a:	38 ca                	cmp    %cl,%dl
f010141c:	75 06                	jne    f0101424 <strfind+0x19>
f010141e:	eb 0b                	jmp    f010142b <strfind+0x20>
f0101420:	38 ca                	cmp    %cl,%dl
f0101422:	74 07                	je     f010142b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101424:	40                   	inc    %eax
f0101425:	8a 10                	mov    (%eax),%dl
f0101427:	84 d2                	test   %dl,%dl
f0101429:	75 f5                	jne    f0101420 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f010142b:	c9                   	leave  
f010142c:	c3                   	ret    

f010142d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010142d:	55                   	push   %ebp
f010142e:	89 e5                	mov    %esp,%ebp
f0101430:	57                   	push   %edi
f0101431:	56                   	push   %esi
f0101432:	53                   	push   %ebx
f0101433:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101436:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101439:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010143c:	85 c9                	test   %ecx,%ecx
f010143e:	74 30                	je     f0101470 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101440:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101446:	75 25                	jne    f010146d <memset+0x40>
f0101448:	f6 c1 03             	test   $0x3,%cl
f010144b:	75 20                	jne    f010146d <memset+0x40>
		c &= 0xFF;
f010144d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101450:	89 d3                	mov    %edx,%ebx
f0101452:	c1 e3 08             	shl    $0x8,%ebx
f0101455:	89 d6                	mov    %edx,%esi
f0101457:	c1 e6 18             	shl    $0x18,%esi
f010145a:	89 d0                	mov    %edx,%eax
f010145c:	c1 e0 10             	shl    $0x10,%eax
f010145f:	09 f0                	or     %esi,%eax
f0101461:	09 d0                	or     %edx,%eax
f0101463:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101465:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101468:	fc                   	cld    
f0101469:	f3 ab                	rep stos %eax,%es:(%edi)
f010146b:	eb 03                	jmp    f0101470 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010146d:	fc                   	cld    
f010146e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101470:	89 f8                	mov    %edi,%eax
f0101472:	5b                   	pop    %ebx
f0101473:	5e                   	pop    %esi
f0101474:	5f                   	pop    %edi
f0101475:	c9                   	leave  
f0101476:	c3                   	ret    

f0101477 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101477:	55                   	push   %ebp
f0101478:	89 e5                	mov    %esp,%ebp
f010147a:	57                   	push   %edi
f010147b:	56                   	push   %esi
f010147c:	8b 45 08             	mov    0x8(%ebp),%eax
f010147f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101482:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101485:	39 c6                	cmp    %eax,%esi
f0101487:	73 34                	jae    f01014bd <memmove+0x46>
f0101489:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010148c:	39 d0                	cmp    %edx,%eax
f010148e:	73 2d                	jae    f01014bd <memmove+0x46>
		s += n;
		d += n;
f0101490:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101493:	f6 c2 03             	test   $0x3,%dl
f0101496:	75 1b                	jne    f01014b3 <memmove+0x3c>
f0101498:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010149e:	75 13                	jne    f01014b3 <memmove+0x3c>
f01014a0:	f6 c1 03             	test   $0x3,%cl
f01014a3:	75 0e                	jne    f01014b3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01014a5:	83 ef 04             	sub    $0x4,%edi
f01014a8:	8d 72 fc             	lea    -0x4(%edx),%esi
f01014ab:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01014ae:	fd                   	std    
f01014af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014b1:	eb 07                	jmp    f01014ba <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01014b3:	4f                   	dec    %edi
f01014b4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01014b7:	fd                   	std    
f01014b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01014ba:	fc                   	cld    
f01014bb:	eb 20                	jmp    f01014dd <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014bd:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01014c3:	75 13                	jne    f01014d8 <memmove+0x61>
f01014c5:	a8 03                	test   $0x3,%al
f01014c7:	75 0f                	jne    f01014d8 <memmove+0x61>
f01014c9:	f6 c1 03             	test   $0x3,%cl
f01014cc:	75 0a                	jne    f01014d8 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01014ce:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01014d1:	89 c7                	mov    %eax,%edi
f01014d3:	fc                   	cld    
f01014d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014d6:	eb 05                	jmp    f01014dd <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01014d8:	89 c7                	mov    %eax,%edi
f01014da:	fc                   	cld    
f01014db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01014dd:	5e                   	pop    %esi
f01014de:	5f                   	pop    %edi
f01014df:	c9                   	leave  
f01014e0:	c3                   	ret    

f01014e1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01014e1:	55                   	push   %ebp
f01014e2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01014e4:	ff 75 10             	pushl  0x10(%ebp)
f01014e7:	ff 75 0c             	pushl  0xc(%ebp)
f01014ea:	ff 75 08             	pushl  0x8(%ebp)
f01014ed:	e8 85 ff ff ff       	call   f0101477 <memmove>
}
f01014f2:	c9                   	leave  
f01014f3:	c3                   	ret    

f01014f4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01014f4:	55                   	push   %ebp
f01014f5:	89 e5                	mov    %esp,%ebp
f01014f7:	57                   	push   %edi
f01014f8:	56                   	push   %esi
f01014f9:	53                   	push   %ebx
f01014fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01014fd:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101500:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101503:	85 ff                	test   %edi,%edi
f0101505:	74 32                	je     f0101539 <memcmp+0x45>
		if (*s1 != *s2)
f0101507:	8a 03                	mov    (%ebx),%al
f0101509:	8a 0e                	mov    (%esi),%cl
f010150b:	38 c8                	cmp    %cl,%al
f010150d:	74 19                	je     f0101528 <memcmp+0x34>
f010150f:	eb 0d                	jmp    f010151e <memcmp+0x2a>
f0101511:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0101515:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f0101519:	42                   	inc    %edx
f010151a:	38 c8                	cmp    %cl,%al
f010151c:	74 10                	je     f010152e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f010151e:	0f b6 c0             	movzbl %al,%eax
f0101521:	0f b6 c9             	movzbl %cl,%ecx
f0101524:	29 c8                	sub    %ecx,%eax
f0101526:	eb 16                	jmp    f010153e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101528:	4f                   	dec    %edi
f0101529:	ba 00 00 00 00       	mov    $0x0,%edx
f010152e:	39 fa                	cmp    %edi,%edx
f0101530:	75 df                	jne    f0101511 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101532:	b8 00 00 00 00       	mov    $0x0,%eax
f0101537:	eb 05                	jmp    f010153e <memcmp+0x4a>
f0101539:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010153e:	5b                   	pop    %ebx
f010153f:	5e                   	pop    %esi
f0101540:	5f                   	pop    %edi
f0101541:	c9                   	leave  
f0101542:	c3                   	ret    

f0101543 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101543:	55                   	push   %ebp
f0101544:	89 e5                	mov    %esp,%ebp
f0101546:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101549:	89 c2                	mov    %eax,%edx
f010154b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010154e:	39 d0                	cmp    %edx,%eax
f0101550:	73 12                	jae    f0101564 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101552:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0101555:	38 08                	cmp    %cl,(%eax)
f0101557:	75 06                	jne    f010155f <memfind+0x1c>
f0101559:	eb 09                	jmp    f0101564 <memfind+0x21>
f010155b:	38 08                	cmp    %cl,(%eax)
f010155d:	74 05                	je     f0101564 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010155f:	40                   	inc    %eax
f0101560:	39 c2                	cmp    %eax,%edx
f0101562:	77 f7                	ja     f010155b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101564:	c9                   	leave  
f0101565:	c3                   	ret    

f0101566 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101566:	55                   	push   %ebp
f0101567:	89 e5                	mov    %esp,%ebp
f0101569:	57                   	push   %edi
f010156a:	56                   	push   %esi
f010156b:	53                   	push   %ebx
f010156c:	8b 55 08             	mov    0x8(%ebp),%edx
f010156f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101572:	eb 01                	jmp    f0101575 <strtol+0xf>
		s++;
f0101574:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101575:	8a 02                	mov    (%edx),%al
f0101577:	3c 20                	cmp    $0x20,%al
f0101579:	74 f9                	je     f0101574 <strtol+0xe>
f010157b:	3c 09                	cmp    $0x9,%al
f010157d:	74 f5                	je     f0101574 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010157f:	3c 2b                	cmp    $0x2b,%al
f0101581:	75 08                	jne    f010158b <strtol+0x25>
		s++;
f0101583:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101584:	bf 00 00 00 00       	mov    $0x0,%edi
f0101589:	eb 13                	jmp    f010159e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010158b:	3c 2d                	cmp    $0x2d,%al
f010158d:	75 0a                	jne    f0101599 <strtol+0x33>
		s++, neg = 1;
f010158f:	8d 52 01             	lea    0x1(%edx),%edx
f0101592:	bf 01 00 00 00       	mov    $0x1,%edi
f0101597:	eb 05                	jmp    f010159e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101599:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010159e:	85 db                	test   %ebx,%ebx
f01015a0:	74 05                	je     f01015a7 <strtol+0x41>
f01015a2:	83 fb 10             	cmp    $0x10,%ebx
f01015a5:	75 28                	jne    f01015cf <strtol+0x69>
f01015a7:	8a 02                	mov    (%edx),%al
f01015a9:	3c 30                	cmp    $0x30,%al
f01015ab:	75 10                	jne    f01015bd <strtol+0x57>
f01015ad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01015b1:	75 0a                	jne    f01015bd <strtol+0x57>
		s += 2, base = 16;
f01015b3:	83 c2 02             	add    $0x2,%edx
f01015b6:	bb 10 00 00 00       	mov    $0x10,%ebx
f01015bb:	eb 12                	jmp    f01015cf <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01015bd:	85 db                	test   %ebx,%ebx
f01015bf:	75 0e                	jne    f01015cf <strtol+0x69>
f01015c1:	3c 30                	cmp    $0x30,%al
f01015c3:	75 05                	jne    f01015ca <strtol+0x64>
		s++, base = 8;
f01015c5:	42                   	inc    %edx
f01015c6:	b3 08                	mov    $0x8,%bl
f01015c8:	eb 05                	jmp    f01015cf <strtol+0x69>
	else if (base == 0)
		base = 10;
f01015ca:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01015cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01015d4:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01015d6:	8a 0a                	mov    (%edx),%cl
f01015d8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01015db:	80 fb 09             	cmp    $0x9,%bl
f01015de:	77 08                	ja     f01015e8 <strtol+0x82>
			dig = *s - '0';
f01015e0:	0f be c9             	movsbl %cl,%ecx
f01015e3:	83 e9 30             	sub    $0x30,%ecx
f01015e6:	eb 1e                	jmp    f0101606 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01015e8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01015eb:	80 fb 19             	cmp    $0x19,%bl
f01015ee:	77 08                	ja     f01015f8 <strtol+0x92>
			dig = *s - 'a' + 10;
f01015f0:	0f be c9             	movsbl %cl,%ecx
f01015f3:	83 e9 57             	sub    $0x57,%ecx
f01015f6:	eb 0e                	jmp    f0101606 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01015f8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01015fb:	80 fb 19             	cmp    $0x19,%bl
f01015fe:	77 13                	ja     f0101613 <strtol+0xad>
			dig = *s - 'A' + 10;
f0101600:	0f be c9             	movsbl %cl,%ecx
f0101603:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101606:	39 f1                	cmp    %esi,%ecx
f0101608:	7d 0d                	jge    f0101617 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f010160a:	42                   	inc    %edx
f010160b:	0f af c6             	imul   %esi,%eax
f010160e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101611:	eb c3                	jmp    f01015d6 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0101613:	89 c1                	mov    %eax,%ecx
f0101615:	eb 02                	jmp    f0101619 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101617:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0101619:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010161d:	74 05                	je     f0101624 <strtol+0xbe>
		*endptr = (char *) s;
f010161f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101622:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101624:	85 ff                	test   %edi,%edi
f0101626:	74 04                	je     f010162c <strtol+0xc6>
f0101628:	89 c8                	mov    %ecx,%eax
f010162a:	f7 d8                	neg    %eax
}
f010162c:	5b                   	pop    %ebx
f010162d:	5e                   	pop    %esi
f010162e:	5f                   	pop    %edi
f010162f:	c9                   	leave  
f0101630:	c3                   	ret    
f0101631:	00 00                	add    %al,(%eax)
	...

f0101634 <__udivdi3>:
f0101634:	55                   	push   %ebp
f0101635:	89 e5                	mov    %esp,%ebp
f0101637:	57                   	push   %edi
f0101638:	56                   	push   %esi
f0101639:	83 ec 10             	sub    $0x10,%esp
f010163c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010163f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101642:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0101645:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101648:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010164b:	8b 45 14             	mov    0x14(%ebp),%eax
f010164e:	85 c0                	test   %eax,%eax
f0101650:	75 2e                	jne    f0101680 <__udivdi3+0x4c>
f0101652:	39 f1                	cmp    %esi,%ecx
f0101654:	77 5a                	ja     f01016b0 <__udivdi3+0x7c>
f0101656:	85 c9                	test   %ecx,%ecx
f0101658:	75 0b                	jne    f0101665 <__udivdi3+0x31>
f010165a:	b8 01 00 00 00       	mov    $0x1,%eax
f010165f:	31 d2                	xor    %edx,%edx
f0101661:	f7 f1                	div    %ecx
f0101663:	89 c1                	mov    %eax,%ecx
f0101665:	31 d2                	xor    %edx,%edx
f0101667:	89 f0                	mov    %esi,%eax
f0101669:	f7 f1                	div    %ecx
f010166b:	89 c6                	mov    %eax,%esi
f010166d:	89 f8                	mov    %edi,%eax
f010166f:	f7 f1                	div    %ecx
f0101671:	89 c7                	mov    %eax,%edi
f0101673:	89 f8                	mov    %edi,%eax
f0101675:	89 f2                	mov    %esi,%edx
f0101677:	83 c4 10             	add    $0x10,%esp
f010167a:	5e                   	pop    %esi
f010167b:	5f                   	pop    %edi
f010167c:	c9                   	leave  
f010167d:	c3                   	ret    
f010167e:	66 90                	xchg   %ax,%ax
f0101680:	39 f0                	cmp    %esi,%eax
f0101682:	77 1c                	ja     f01016a0 <__udivdi3+0x6c>
f0101684:	0f bd f8             	bsr    %eax,%edi
f0101687:	83 f7 1f             	xor    $0x1f,%edi
f010168a:	75 3c                	jne    f01016c8 <__udivdi3+0x94>
f010168c:	39 f0                	cmp    %esi,%eax
f010168e:	0f 82 90 00 00 00    	jb     f0101724 <__udivdi3+0xf0>
f0101694:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101697:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f010169a:	0f 86 84 00 00 00    	jbe    f0101724 <__udivdi3+0xf0>
f01016a0:	31 f6                	xor    %esi,%esi
f01016a2:	31 ff                	xor    %edi,%edi
f01016a4:	89 f8                	mov    %edi,%eax
f01016a6:	89 f2                	mov    %esi,%edx
f01016a8:	83 c4 10             	add    $0x10,%esp
f01016ab:	5e                   	pop    %esi
f01016ac:	5f                   	pop    %edi
f01016ad:	c9                   	leave  
f01016ae:	c3                   	ret    
f01016af:	90                   	nop
f01016b0:	89 f2                	mov    %esi,%edx
f01016b2:	89 f8                	mov    %edi,%eax
f01016b4:	f7 f1                	div    %ecx
f01016b6:	89 c7                	mov    %eax,%edi
f01016b8:	31 f6                	xor    %esi,%esi
f01016ba:	89 f8                	mov    %edi,%eax
f01016bc:	89 f2                	mov    %esi,%edx
f01016be:	83 c4 10             	add    $0x10,%esp
f01016c1:	5e                   	pop    %esi
f01016c2:	5f                   	pop    %edi
f01016c3:	c9                   	leave  
f01016c4:	c3                   	ret    
f01016c5:	8d 76 00             	lea    0x0(%esi),%esi
f01016c8:	89 f9                	mov    %edi,%ecx
f01016ca:	d3 e0                	shl    %cl,%eax
f01016cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01016cf:	b8 20 00 00 00       	mov    $0x20,%eax
f01016d4:	29 f8                	sub    %edi,%eax
f01016d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01016d9:	88 c1                	mov    %al,%cl
f01016db:	d3 ea                	shr    %cl,%edx
f01016dd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01016e0:	09 ca                	or     %ecx,%edx
f01016e2:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01016e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01016e8:	89 f9                	mov    %edi,%ecx
f01016ea:	d3 e2                	shl    %cl,%edx
f01016ec:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01016ef:	89 f2                	mov    %esi,%edx
f01016f1:	88 c1                	mov    %al,%cl
f01016f3:	d3 ea                	shr    %cl,%edx
f01016f5:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01016f8:	89 f2                	mov    %esi,%edx
f01016fa:	89 f9                	mov    %edi,%ecx
f01016fc:	d3 e2                	shl    %cl,%edx
f01016fe:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0101701:	88 c1                	mov    %al,%cl
f0101703:	d3 ee                	shr    %cl,%esi
f0101705:	09 d6                	or     %edx,%esi
f0101707:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010170a:	89 f0                	mov    %esi,%eax
f010170c:	89 ca                	mov    %ecx,%edx
f010170e:	f7 75 ec             	divl   -0x14(%ebp)
f0101711:	89 d1                	mov    %edx,%ecx
f0101713:	89 c6                	mov    %eax,%esi
f0101715:	f7 65 f4             	mull   -0xc(%ebp)
f0101718:	39 d1                	cmp    %edx,%ecx
f010171a:	72 28                	jb     f0101744 <__udivdi3+0x110>
f010171c:	74 1a                	je     f0101738 <__udivdi3+0x104>
f010171e:	89 f7                	mov    %esi,%edi
f0101720:	31 f6                	xor    %esi,%esi
f0101722:	eb 80                	jmp    f01016a4 <__udivdi3+0x70>
f0101724:	31 f6                	xor    %esi,%esi
f0101726:	bf 01 00 00 00       	mov    $0x1,%edi
f010172b:	89 f8                	mov    %edi,%eax
f010172d:	89 f2                	mov    %esi,%edx
f010172f:	83 c4 10             	add    $0x10,%esp
f0101732:	5e                   	pop    %esi
f0101733:	5f                   	pop    %edi
f0101734:	c9                   	leave  
f0101735:	c3                   	ret    
f0101736:	66 90                	xchg   %ax,%ax
f0101738:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010173b:	89 f9                	mov    %edi,%ecx
f010173d:	d3 e2                	shl    %cl,%edx
f010173f:	39 c2                	cmp    %eax,%edx
f0101741:	73 db                	jae    f010171e <__udivdi3+0xea>
f0101743:	90                   	nop
f0101744:	8d 7e ff             	lea    -0x1(%esi),%edi
f0101747:	31 f6                	xor    %esi,%esi
f0101749:	e9 56 ff ff ff       	jmp    f01016a4 <__udivdi3+0x70>
	...

f0101750 <__umoddi3>:
f0101750:	55                   	push   %ebp
f0101751:	89 e5                	mov    %esp,%ebp
f0101753:	57                   	push   %edi
f0101754:	56                   	push   %esi
f0101755:	83 ec 20             	sub    $0x20,%esp
f0101758:	8b 45 08             	mov    0x8(%ebp),%eax
f010175b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010175e:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0101761:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101764:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0101767:	8b 7d 14             	mov    0x14(%ebp),%edi
f010176a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010176d:	89 f2                	mov    %esi,%edx
f010176f:	85 ff                	test   %edi,%edi
f0101771:	75 15                	jne    f0101788 <__umoddi3+0x38>
f0101773:	39 f1                	cmp    %esi,%ecx
f0101775:	0f 86 99 00 00 00    	jbe    f0101814 <__umoddi3+0xc4>
f010177b:	f7 f1                	div    %ecx
f010177d:	89 d0                	mov    %edx,%eax
f010177f:	31 d2                	xor    %edx,%edx
f0101781:	83 c4 20             	add    $0x20,%esp
f0101784:	5e                   	pop    %esi
f0101785:	5f                   	pop    %edi
f0101786:	c9                   	leave  
f0101787:	c3                   	ret    
f0101788:	39 f7                	cmp    %esi,%edi
f010178a:	0f 87 a4 00 00 00    	ja     f0101834 <__umoddi3+0xe4>
f0101790:	0f bd c7             	bsr    %edi,%eax
f0101793:	83 f0 1f             	xor    $0x1f,%eax
f0101796:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101799:	0f 84 a1 00 00 00    	je     f0101840 <__umoddi3+0xf0>
f010179f:	89 f8                	mov    %edi,%eax
f01017a1:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01017a4:	d3 e0                	shl    %cl,%eax
f01017a6:	bf 20 00 00 00       	mov    $0x20,%edi
f01017ab:	2b 7d ec             	sub    -0x14(%ebp),%edi
f01017ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01017b1:	89 f9                	mov    %edi,%ecx
f01017b3:	d3 ea                	shr    %cl,%edx
f01017b5:	09 c2                	or     %eax,%edx
f01017b7:	89 55 f0             	mov    %edx,-0x10(%ebp)
f01017ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01017bd:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01017c0:	d3 e0                	shl    %cl,%eax
f01017c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01017c5:	89 f2                	mov    %esi,%edx
f01017c7:	d3 e2                	shl    %cl,%edx
f01017c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01017cc:	d3 e0                	shl    %cl,%eax
f01017ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01017d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01017d4:	89 f9                	mov    %edi,%ecx
f01017d6:	d3 e8                	shr    %cl,%eax
f01017d8:	09 d0                	or     %edx,%eax
f01017da:	d3 ee                	shr    %cl,%esi
f01017dc:	89 f2                	mov    %esi,%edx
f01017de:	f7 75 f0             	divl   -0x10(%ebp)
f01017e1:	89 d6                	mov    %edx,%esi
f01017e3:	f7 65 f4             	mull   -0xc(%ebp)
f01017e6:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01017e9:	89 c1                	mov    %eax,%ecx
f01017eb:	39 d6                	cmp    %edx,%esi
f01017ed:	72 71                	jb     f0101860 <__umoddi3+0x110>
f01017ef:	74 7f                	je     f0101870 <__umoddi3+0x120>
f01017f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01017f4:	29 c8                	sub    %ecx,%eax
f01017f6:	19 d6                	sbb    %edx,%esi
f01017f8:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01017fb:	d3 e8                	shr    %cl,%eax
f01017fd:	89 f2                	mov    %esi,%edx
f01017ff:	89 f9                	mov    %edi,%ecx
f0101801:	d3 e2                	shl    %cl,%edx
f0101803:	09 d0                	or     %edx,%eax
f0101805:	89 f2                	mov    %esi,%edx
f0101807:	8a 4d ec             	mov    -0x14(%ebp),%cl
f010180a:	d3 ea                	shr    %cl,%edx
f010180c:	83 c4 20             	add    $0x20,%esp
f010180f:	5e                   	pop    %esi
f0101810:	5f                   	pop    %edi
f0101811:	c9                   	leave  
f0101812:	c3                   	ret    
f0101813:	90                   	nop
f0101814:	85 c9                	test   %ecx,%ecx
f0101816:	75 0b                	jne    f0101823 <__umoddi3+0xd3>
f0101818:	b8 01 00 00 00       	mov    $0x1,%eax
f010181d:	31 d2                	xor    %edx,%edx
f010181f:	f7 f1                	div    %ecx
f0101821:	89 c1                	mov    %eax,%ecx
f0101823:	89 f0                	mov    %esi,%eax
f0101825:	31 d2                	xor    %edx,%edx
f0101827:	f7 f1                	div    %ecx
f0101829:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010182c:	f7 f1                	div    %ecx
f010182e:	e9 4a ff ff ff       	jmp    f010177d <__umoddi3+0x2d>
f0101833:	90                   	nop
f0101834:	89 f2                	mov    %esi,%edx
f0101836:	83 c4 20             	add    $0x20,%esp
f0101839:	5e                   	pop    %esi
f010183a:	5f                   	pop    %edi
f010183b:	c9                   	leave  
f010183c:	c3                   	ret    
f010183d:	8d 76 00             	lea    0x0(%esi),%esi
f0101840:	39 f7                	cmp    %esi,%edi
f0101842:	72 05                	jb     f0101849 <__umoddi3+0xf9>
f0101844:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0101847:	77 0c                	ja     f0101855 <__umoddi3+0x105>
f0101849:	89 f2                	mov    %esi,%edx
f010184b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010184e:	29 c8                	sub    %ecx,%eax
f0101850:	19 fa                	sbb    %edi,%edx
f0101852:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101855:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101858:	83 c4 20             	add    $0x20,%esp
f010185b:	5e                   	pop    %esi
f010185c:	5f                   	pop    %edi
f010185d:	c9                   	leave  
f010185e:	c3                   	ret    
f010185f:	90                   	nop
f0101860:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101863:	89 c1                	mov    %eax,%ecx
f0101865:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0101868:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f010186b:	eb 84                	jmp    f01017f1 <__umoddi3+0xa1>
f010186d:	8d 76 00             	lea    0x0(%esi),%esi
f0101870:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0101873:	72 eb                	jb     f0101860 <__umoddi3+0x110>
f0101875:	89 f2                	mov    %esi,%edx
f0101877:	e9 75 ff ff ff       	jmp    f01017f1 <__umoddi3+0xa1>
