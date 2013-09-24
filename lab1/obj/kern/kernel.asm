
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
f010004b:	68 00 18 10 f0       	push   $0xf0101800
f0100050:	e8 7c 08 00 00       	call   f01008d1 <cprintf>
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
f0100076:	e8 aa 06 00 00       	call   f0100725 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 1c 18 10 f0       	push   $0xf010181c
f0100087:	e8 45 08 00 00       	call   f01008d1 <cprintf>
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
f01000ac:	e8 f8 12 00 00       	call   f01013a9 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 76 04 00 00       	call   f010052c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 37 18 10 f0       	push   $0xf0101837
f01000c3:	e8 09 08 00 00       	call   f01008d1 <cprintf>

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
f01000dc:	e8 4e 06 00 00       	call   f010072f <monitor>
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
f010010b:	68 52 18 10 f0       	push   $0xf0101852
f0100110:	e8 bc 07 00 00       	call   f01008d1 <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 8c 07 00 00       	call   f01008ab <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 8e 18 10 f0 	movl   $0xf010188e,(%esp)
f0100126:	e8 a6 07 00 00       	call   f01008d1 <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 f7 05 00 00       	call   f010072f <monitor>
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
f010014d:	68 6a 18 10 f0       	push   $0xf010186a
f0100152:	e8 7a 07 00 00       	call   f01008d1 <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 48 07 00 00       	call   f01008ab <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 8e 18 10 f0 	movl   $0xf010188e,(%esp)
f010016a:	e8 62 07 00 00       	call   f01008d1 <cprintf>
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
	if (MIGHTY_ME==0)
f010024f:	83 3d 44 89 11 f0 00 	cmpl   $0x0,0xf0118944
f0100256:	75 0a                	jne    f0100262 <cons_putc+0x7f>
		MIGHTY_ME = 0x0700;
f0100258:	c7 05 44 89 11 f0 00 	movl   $0x700,0xf0118944
f010025f:	07 00 00 
	if (!(c & ~0xFF))
f0100262:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f0100268:	75 06                	jne    f0100270 <cons_putc+0x8d>
		c |= MIGHTY_ME;
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
f0100362:	e8 8c 10 00 00       	call   f01013f3 <memmove>
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
f0100401:	8a 82 c0 18 10 f0    	mov    -0xfefe740(%edx),%al
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
f010043d:	0f b6 82 c0 18 10 f0 	movzbl -0xfefe740(%edx),%eax
f0100444:	0b 05 28 85 11 f0    	or     0xf0118528,%eax
	shift ^= togglecode[data];
f010044a:	0f b6 8a c0 19 10 f0 	movzbl -0xfefe640(%edx),%ecx
f0100451:	31 c8                	xor    %ecx,%eax
f0100453:	a3 28 85 11 f0       	mov    %eax,0xf0118528

	c = charcode[shift & (CTL | SHIFT)][data];
f0100458:	89 c1                	mov    %eax,%ecx
f010045a:	83 e1 03             	and    $0x3,%ecx
f010045d:	8b 0c 8d c0 1a 10 f0 	mov    -0xfefe540(,%ecx,4),%ecx
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
f0100495:	68 84 18 10 f0       	push   $0xf0101884
f010049a:	e8 32 04 00 00       	call   f01008d1 <cprintf>
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
f01005f6:	68 90 18 10 f0       	push   $0xf0101890
f01005fb:	e8 d1 02 00 00       	call   f01008d1 <cprintf>
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

f0100638 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100638:	55                   	push   %ebp
f0100639:	89 e5                	mov    %esp,%ebp
f010063b:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010063e:	68 d0 1a 10 f0       	push   $0xf0101ad0
f0100643:	e8 89 02 00 00       	call   f01008d1 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100648:	83 c4 08             	add    $0x8,%esp
f010064b:	68 0c 00 10 00       	push   $0x10000c
f0100650:	68 7c 1b 10 f0       	push   $0xf0101b7c
f0100655:	e8 77 02 00 00       	call   f01008d1 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010065a:	83 c4 0c             	add    $0xc,%esp
f010065d:	68 0c 00 10 00       	push   $0x10000c
f0100662:	68 0c 00 10 f0       	push   $0xf010000c
f0100667:	68 a4 1b 10 f0       	push   $0xf0101ba4
f010066c:	e8 60 02 00 00       	call   f01008d1 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100671:	83 c4 0c             	add    $0xc,%esp
f0100674:	68 f8 17 10 00       	push   $0x1017f8
f0100679:	68 f8 17 10 f0       	push   $0xf01017f8
f010067e:	68 c8 1b 10 f0       	push   $0xf0101bc8
f0100683:	e8 49 02 00 00       	call   f01008d1 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100688:	83 c4 0c             	add    $0xc,%esp
f010068b:	68 00 83 11 00       	push   $0x118300
f0100690:	68 00 83 11 f0       	push   $0xf0118300
f0100695:	68 ec 1b 10 f0       	push   $0xf0101bec
f010069a:	e8 32 02 00 00       	call   f01008d1 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010069f:	83 c4 0c             	add    $0xc,%esp
f01006a2:	68 48 89 11 00       	push   $0x118948
f01006a7:	68 48 89 11 f0       	push   $0xf0118948
f01006ac:	68 10 1c 10 f0       	push   $0xf0101c10
f01006b1:	e8 1b 02 00 00       	call   f01008d1 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006b6:	b8 47 8d 11 f0       	mov    $0xf0118d47,%eax
f01006bb:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006c0:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01006c3:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006c8:	89 c2                	mov    %eax,%edx
f01006ca:	85 c0                	test   %eax,%eax
f01006cc:	79 06                	jns    f01006d4 <mon_kerninfo+0x9c>
f01006ce:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006d4:	c1 fa 0a             	sar    $0xa,%edx
f01006d7:	52                   	push   %edx
f01006d8:	68 34 1c 10 f0       	push   $0xf0101c34
f01006dd:	e8 ef 01 00 00       	call   f01008d1 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e7:	c9                   	leave  
f01006e8:	c3                   	ret    

f01006e9 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006e9:	55                   	push   %ebp
f01006ea:	89 e5                	mov    %esp,%ebp
f01006ec:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006ef:	ff 35 d8 1c 10 f0    	pushl  0xf0101cd8
f01006f5:	ff 35 d4 1c 10 f0    	pushl  0xf0101cd4
f01006fb:	68 e9 1a 10 f0       	push   $0xf0101ae9
f0100700:	e8 cc 01 00 00       	call   f01008d1 <cprintf>
f0100705:	83 c4 0c             	add    $0xc,%esp
f0100708:	ff 35 e4 1c 10 f0    	pushl  0xf0101ce4
f010070e:	ff 35 e0 1c 10 f0    	pushl  0xf0101ce0
f0100714:	68 e9 1a 10 f0       	push   $0xf0101ae9
f0100719:	e8 b3 01 00 00       	call   f01008d1 <cprintf>
	return 0;
}
f010071e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100723:	c9                   	leave  
f0100724:	c3                   	ret    

f0100725 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100725:	55                   	push   %ebp
f0100726:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100728:	b8 00 00 00 00       	mov    $0x0,%eax
f010072d:	c9                   	leave  
f010072e:	c3                   	ret    

f010072f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010072f:	55                   	push   %ebp
f0100730:	89 e5                	mov    %esp,%ebp
f0100732:	57                   	push   %edi
f0100733:	56                   	push   %esi
f0100734:	53                   	push   %ebx
f0100735:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100738:	68 60 1c 10 f0       	push   $0xf0101c60
f010073d:	e8 8f 01 00 00       	call   f01008d1 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100742:	c7 04 24 84 1c 10 f0 	movl   $0xf0101c84,(%esp)
f0100749:	e8 83 01 00 00       	call   f01008d1 <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n", 
f010074e:	83 c4 0c             	add    $0xc,%esp
f0100751:	68 f2 1a 10 f0       	push   $0xf0101af2
f0100756:	68 00 04 00 00       	push   $0x400
f010075b:	68 f6 1a 10 f0       	push   $0xf0101af6
f0100760:	68 00 02 00 00       	push   $0x200
f0100765:	68 fc 1a 10 f0       	push   $0xf0101afc
f010076a:	68 00 01 00 00       	push   $0x100
f010076f:	68 01 1b 10 f0       	push   $0xf0101b01
f0100774:	e8 58 01 00 00       	call   f01008d1 <cprintf>
f0100779:	83 c4 20             	add    $0x20,%esp
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
f010077c:	8d 7d a8             	lea    -0x58(%ebp),%edi
	cprintf("Type 'help' for a list of commands.\n");
	cprintf("%m%s\n%m%s\n%m%s\n", 
					0x0100, "blue", 0x0200, "green", 0x0400, "red");

	while (1) {
		buf = readline("K> ");
f010077f:	83 ec 0c             	sub    $0xc,%esp
f0100782:	68 11 1b 10 f0       	push   $0xf0101b11
f0100787:	e8 84 09 00 00       	call   f0101110 <readline>
f010078c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010078e:	83 c4 10             	add    $0x10,%esp
f0100791:	85 c0                	test   %eax,%eax
f0100793:	74 ea                	je     f010077f <monitor+0x50>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100795:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010079c:	be 00 00 00 00       	mov    $0x0,%esi
f01007a1:	eb 04                	jmp    f01007a7 <monitor+0x78>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007a3:	c6 03 00             	movb   $0x0,(%ebx)
f01007a6:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007a7:	8a 03                	mov    (%ebx),%al
f01007a9:	84 c0                	test   %al,%al
f01007ab:	74 64                	je     f0100811 <monitor+0xe2>
f01007ad:	83 ec 08             	sub    $0x8,%esp
f01007b0:	0f be c0             	movsbl %al,%eax
f01007b3:	50                   	push   %eax
f01007b4:	68 15 1b 10 f0       	push   $0xf0101b15
f01007b9:	e8 9b 0b 00 00       	call   f0101359 <strchr>
f01007be:	83 c4 10             	add    $0x10,%esp
f01007c1:	85 c0                	test   %eax,%eax
f01007c3:	75 de                	jne    f01007a3 <monitor+0x74>
			*buf++ = 0;
		if (*buf == 0)
f01007c5:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007c8:	74 47                	je     f0100811 <monitor+0xe2>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007ca:	83 fe 0f             	cmp    $0xf,%esi
f01007cd:	75 14                	jne    f01007e3 <monitor+0xb4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007cf:	83 ec 08             	sub    $0x8,%esp
f01007d2:	6a 10                	push   $0x10
f01007d4:	68 1a 1b 10 f0       	push   $0xf0101b1a
f01007d9:	e8 f3 00 00 00       	call   f01008d1 <cprintf>
f01007de:	83 c4 10             	add    $0x10,%esp
f01007e1:	eb 9c                	jmp    f010077f <monitor+0x50>
			return 0;
		}
		argv[argc++] = buf;
f01007e3:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01007e7:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01007e8:	8a 03                	mov    (%ebx),%al
f01007ea:	84 c0                	test   %al,%al
f01007ec:	75 09                	jne    f01007f7 <monitor+0xc8>
f01007ee:	eb b7                	jmp    f01007a7 <monitor+0x78>
			buf++;
f01007f0:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01007f1:	8a 03                	mov    (%ebx),%al
f01007f3:	84 c0                	test   %al,%al
f01007f5:	74 b0                	je     f01007a7 <monitor+0x78>
f01007f7:	83 ec 08             	sub    $0x8,%esp
f01007fa:	0f be c0             	movsbl %al,%eax
f01007fd:	50                   	push   %eax
f01007fe:	68 15 1b 10 f0       	push   $0xf0101b15
f0100803:	e8 51 0b 00 00       	call   f0101359 <strchr>
f0100808:	83 c4 10             	add    $0x10,%esp
f010080b:	85 c0                	test   %eax,%eax
f010080d:	74 e1                	je     f01007f0 <monitor+0xc1>
f010080f:	eb 96                	jmp    f01007a7 <monitor+0x78>
			buf++;
	}
	argv[argc] = 0;
f0100811:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100818:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100819:	85 f6                	test   %esi,%esi
f010081b:	0f 84 5e ff ff ff    	je     f010077f <monitor+0x50>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100821:	83 ec 08             	sub    $0x8,%esp
f0100824:	ff 35 d4 1c 10 f0    	pushl  0xf0101cd4
f010082a:	ff 75 a8             	pushl  -0x58(%ebp)
f010082d:	e8 b9 0a 00 00       	call   f01012eb <strcmp>
f0100832:	83 c4 10             	add    $0x10,%esp
f0100835:	85 c0                	test   %eax,%eax
f0100837:	74 1c                	je     f0100855 <monitor+0x126>
f0100839:	83 ec 08             	sub    $0x8,%esp
f010083c:	ff 35 e0 1c 10 f0    	pushl  0xf0101ce0
f0100842:	ff 75 a8             	pushl  -0x58(%ebp)
f0100845:	e8 a1 0a 00 00       	call   f01012eb <strcmp>
f010084a:	83 c4 10             	add    $0x10,%esp
f010084d:	85 c0                	test   %eax,%eax
f010084f:	75 26                	jne    f0100877 <monitor+0x148>
f0100851:	b0 01                	mov    $0x1,%al
f0100853:	eb 05                	jmp    f010085a <monitor+0x12b>
f0100855:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f010085a:	83 ec 04             	sub    $0x4,%esp
f010085d:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100860:	ff 75 08             	pushl  0x8(%ebp)
f0100863:	57                   	push   %edi
f0100864:	56                   	push   %esi
f0100865:	ff 90 dc 1c 10 f0    	call   *-0xfefe324(%eax)
					0x0100, "blue", 0x0200, "green", 0x0400, "red");

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010086b:	83 c4 10             	add    $0x10,%esp
f010086e:	85 c0                	test   %eax,%eax
f0100870:	78 1d                	js     f010088f <monitor+0x160>
f0100872:	e9 08 ff ff ff       	jmp    f010077f <monitor+0x50>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100877:	83 ec 08             	sub    $0x8,%esp
f010087a:	ff 75 a8             	pushl  -0x58(%ebp)
f010087d:	68 37 1b 10 f0       	push   $0xf0101b37
f0100882:	e8 4a 00 00 00       	call   f01008d1 <cprintf>
f0100887:	83 c4 10             	add    $0x10,%esp
f010088a:	e9 f0 fe ff ff       	jmp    f010077f <monitor+0x50>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010088f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100892:	5b                   	pop    %ebx
f0100893:	5e                   	pop    %esi
f0100894:	5f                   	pop    %edi
f0100895:	c9                   	leave  
f0100896:	c3                   	ret    
	...

f0100898 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100898:	55                   	push   %ebp
f0100899:	89 e5                	mov    %esp,%ebp
f010089b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010089e:	ff 75 08             	pushl  0x8(%ebp)
f01008a1:	e8 65 fd ff ff       	call   f010060b <cputchar>
f01008a6:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f01008a9:	c9                   	leave  
f01008aa:	c3                   	ret    

f01008ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01008ab:	55                   	push   %ebp
f01008ac:	89 e5                	mov    %esp,%ebp
f01008ae:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01008b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01008b8:	ff 75 0c             	pushl  0xc(%ebp)
f01008bb:	ff 75 08             	pushl  0x8(%ebp)
f01008be:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01008c1:	50                   	push   %eax
f01008c2:	68 98 08 10 f0       	push   $0xf0100898
f01008c7:	e8 59 04 00 00       	call   f0100d25 <vprintfmt>
	return cnt;
}
f01008cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01008cf:	c9                   	leave  
f01008d0:	c3                   	ret    

f01008d1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01008d1:	55                   	push   %ebp
f01008d2:	89 e5                	mov    %esp,%ebp
f01008d4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01008d7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01008da:	50                   	push   %eax
f01008db:	ff 75 08             	pushl  0x8(%ebp)
f01008de:	e8 c8 ff ff ff       	call   f01008ab <vcprintf>
	va_end(ap);

	return cnt;
}
f01008e3:	c9                   	leave  
f01008e4:	c3                   	ret    
f01008e5:	00 00                	add    %al,(%eax)
	...

f01008e8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01008e8:	55                   	push   %ebp
f01008e9:	89 e5                	mov    %esp,%ebp
f01008eb:	57                   	push   %edi
f01008ec:	56                   	push   %esi
f01008ed:	53                   	push   %ebx
f01008ee:	83 ec 14             	sub    $0x14,%esp
f01008f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01008f4:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01008f7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01008fa:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01008fd:	8b 1a                	mov    (%edx),%ebx
f01008ff:	8b 01                	mov    (%ecx),%eax
f0100901:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0100904:	39 c3                	cmp    %eax,%ebx
f0100906:	0f 8f 97 00 00 00    	jg     f01009a3 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f010090c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0100913:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100916:	01 d8                	add    %ebx,%eax
f0100918:	89 c7                	mov    %eax,%edi
f010091a:	c1 ef 1f             	shr    $0x1f,%edi
f010091d:	01 c7                	add    %eax,%edi
f010091f:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100921:	39 df                	cmp    %ebx,%edi
f0100923:	7c 31                	jl     f0100956 <stab_binsearch+0x6e>
f0100925:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100928:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010092b:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0100930:	39 f0                	cmp    %esi,%eax
f0100932:	0f 84 b3 00 00 00    	je     f01009eb <stab_binsearch+0x103>
f0100938:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010093c:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0100940:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100942:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100943:	39 d8                	cmp    %ebx,%eax
f0100945:	7c 0f                	jl     f0100956 <stab_binsearch+0x6e>
f0100947:	0f b6 0a             	movzbl (%edx),%ecx
f010094a:	83 ea 0c             	sub    $0xc,%edx
f010094d:	39 f1                	cmp    %esi,%ecx
f010094f:	75 f1                	jne    f0100942 <stab_binsearch+0x5a>
f0100951:	e9 97 00 00 00       	jmp    f01009ed <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100956:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100959:	eb 39                	jmp    f0100994 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010095b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010095e:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0100960:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100963:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010096a:	eb 28                	jmp    f0100994 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010096c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010096f:	76 12                	jbe    f0100983 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0100971:	48                   	dec    %eax
f0100972:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100975:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100978:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010097a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100981:	eb 11                	jmp    f0100994 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100983:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100986:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0100988:	ff 45 0c             	incl   0xc(%ebp)
f010098b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010098d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100994:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0100997:	0f 8d 76 ff ff ff    	jge    f0100913 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010099d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01009a1:	75 0d                	jne    f01009b0 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f01009a3:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01009a6:	8b 03                	mov    (%ebx),%eax
f01009a8:	48                   	dec    %eax
f01009a9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01009ac:	89 02                	mov    %eax,(%edx)
f01009ae:	eb 55                	jmp    f0100a05 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01009b3:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01009b5:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01009b8:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009ba:	39 c1                	cmp    %eax,%ecx
f01009bc:	7d 26                	jge    f01009e4 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f01009be:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009c1:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01009c4:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01009c9:	39 f2                	cmp    %esi,%edx
f01009cb:	74 17                	je     f01009e4 <stab_binsearch+0xfc>
f01009cd:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01009d1:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01009d5:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009d6:	39 c1                	cmp    %eax,%ecx
f01009d8:	7d 0a                	jge    f01009e4 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f01009da:	0f b6 1a             	movzbl (%edx),%ebx
f01009dd:	83 ea 0c             	sub    $0xc,%edx
f01009e0:	39 f3                	cmp    %esi,%ebx
f01009e2:	75 f1                	jne    f01009d5 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f01009e4:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01009e7:	89 02                	mov    %eax,(%edx)
f01009e9:	eb 1a                	jmp    f0100a05 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01009eb:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009ed:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009f0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01009f3:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01009f7:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01009fa:	0f 82 5b ff ff ff    	jb     f010095b <stab_binsearch+0x73>
f0100a00:	e9 67 ff ff ff       	jmp    f010096c <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100a05:	83 c4 14             	add    $0x14,%esp
f0100a08:	5b                   	pop    %ebx
f0100a09:	5e                   	pop    %esi
f0100a0a:	5f                   	pop    %edi
f0100a0b:	c9                   	leave  
f0100a0c:	c3                   	ret    

f0100a0d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a0d:	55                   	push   %ebp
f0100a0e:	89 e5                	mov    %esp,%ebp
f0100a10:	57                   	push   %edi
f0100a11:	56                   	push   %esi
f0100a12:	53                   	push   %ebx
f0100a13:	83 ec 2c             	sub    $0x2c,%esp
f0100a16:	8b 75 08             	mov    0x8(%ebp),%esi
f0100a19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a1c:	c7 03 ec 1c 10 f0    	movl   $0xf0101cec,(%ebx)
	info->eip_line = 0;
f0100a22:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100a29:	c7 43 08 ec 1c 10 f0 	movl   $0xf0101cec,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100a30:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100a37:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100a3a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100a41:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100a47:	76 12                	jbe    f0100a5b <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a49:	b8 25 d7 10 f0       	mov    $0xf010d725,%eax
f0100a4e:	3d 25 64 10 f0       	cmp    $0xf0106425,%eax
f0100a53:	0f 86 4b 01 00 00    	jbe    f0100ba4 <debuginfo_eip+0x197>
f0100a59:	eb 14                	jmp    f0100a6f <debuginfo_eip+0x62>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100a5b:	83 ec 04             	sub    $0x4,%esp
f0100a5e:	68 f6 1c 10 f0       	push   $0xf0101cf6
f0100a63:	6a 7f                	push   $0x7f
f0100a65:	68 03 1d 10 f0       	push   $0xf0101d03
f0100a6a:	e8 77 f6 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100a6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a74:	80 3d 24 d7 10 f0 00 	cmpb   $0x0,0xf010d724
f0100a7b:	0f 85 2f 01 00 00    	jne    f0100bb0 <debuginfo_eip+0x1a3>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100a81:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100a88:	b8 24 64 10 f0       	mov    $0xf0106424,%eax
f0100a8d:	2d 24 1f 10 f0       	sub    $0xf0101f24,%eax
f0100a92:	c1 f8 02             	sar    $0x2,%eax
f0100a95:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100a9b:	48                   	dec    %eax
f0100a9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100a9f:	83 ec 08             	sub    $0x8,%esp
f0100aa2:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100aa5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100aa8:	56                   	push   %esi
f0100aa9:	6a 64                	push   $0x64
f0100aab:	b8 24 1f 10 f0       	mov    $0xf0101f24,%eax
f0100ab0:	e8 33 fe ff ff       	call   f01008e8 <stab_binsearch>
	if (lfile == 0)
f0100ab5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ab8:	83 c4 10             	add    $0x10,%esp
		return -1;
f0100abb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0100ac0:	85 d2                	test   %edx,%edx
f0100ac2:	0f 84 e8 00 00 00    	je     f0100bb0 <debuginfo_eip+0x1a3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100ac8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0100acb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ace:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100ad1:	83 ec 08             	sub    $0x8,%esp
f0100ad4:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100ad7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ada:	56                   	push   %esi
f0100adb:	6a 24                	push   $0x24
f0100add:	b8 24 1f 10 f0       	mov    $0xf0101f24,%eax
f0100ae2:	e8 01 fe ff ff       	call   f01008e8 <stab_binsearch>

	if (lfun <= rfun) {
f0100ae7:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100aea:	83 c4 10             	add    $0x10,%esp
f0100aed:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0100af0:	7f 30                	jg     f0100b22 <debuginfo_eip+0x115>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100af2:	89 fa                	mov    %edi,%edx
f0100af4:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100af7:	8b 80 24 1f 10 f0    	mov    -0xfefe0dc(%eax),%eax
f0100afd:	b9 25 d7 10 f0       	mov    $0xf010d725,%ecx
f0100b02:	81 e9 25 64 10 f0    	sub    $0xf0106425,%ecx
f0100b08:	39 c8                	cmp    %ecx,%eax
f0100b0a:	73 08                	jae    f0100b14 <debuginfo_eip+0x107>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b0c:	05 25 64 10 f0       	add    $0xf0106425,%eax
f0100b11:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b14:	6b c2 0c             	imul   $0xc,%edx,%eax
f0100b17:	8b 80 2c 1f 10 f0    	mov    -0xfefe0d4(%eax),%eax
f0100b1d:	89 43 10             	mov    %eax,0x10(%ebx)
f0100b20:	eb 06                	jmp    f0100b28 <debuginfo_eip+0x11b>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b22:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100b25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b28:	83 ec 08             	sub    $0x8,%esp
f0100b2b:	6a 3a                	push   $0x3a
f0100b2d:	ff 73 08             	pushl  0x8(%ebx)
f0100b30:	e8 52 08 00 00       	call   f0101387 <strfind>
f0100b35:	2b 43 08             	sub    0x8(%ebx),%eax
f0100b38:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b3b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0100b3e:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100b41:	05 2c 1f 10 f0       	add    $0xf0101f2c,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b46:	83 c4 10             	add    $0x10,%esp
f0100b49:	eb 04                	jmp    f0100b4f <debuginfo_eip+0x142>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100b4b:	4f                   	dec    %edi
f0100b4c:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b4f:	39 cf                	cmp    %ecx,%edi
f0100b51:	7c 1b                	jl     f0100b6e <debuginfo_eip+0x161>
	       && stabs[lline].n_type != N_SOL
f0100b53:	8a 50 fc             	mov    -0x4(%eax),%dl
f0100b56:	80 fa 84             	cmp    $0x84,%dl
f0100b59:	74 5d                	je     f0100bb8 <debuginfo_eip+0x1ab>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100b5b:	80 fa 64             	cmp    $0x64,%dl
f0100b5e:	75 eb                	jne    f0100b4b <debuginfo_eip+0x13e>
f0100b60:	83 38 00             	cmpl   $0x0,(%eax)
f0100b63:	74 e6                	je     f0100b4b <debuginfo_eip+0x13e>
f0100b65:	eb 51                	jmp    f0100bb8 <debuginfo_eip+0x1ab>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100b67:	05 25 64 10 f0       	add    $0xf0106425,%eax
f0100b6c:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b6e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b71:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100b74:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b79:	39 f2                	cmp    %esi,%edx
f0100b7b:	7d 33                	jge    f0100bb0 <debuginfo_eip+0x1a3>
		for (lline = lfun + 1;
f0100b7d:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0100b80:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100b83:	81 c2 28 1f 10 f0    	add    $0xf0101f28,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100b89:	eb 04                	jmp    f0100b8f <debuginfo_eip+0x182>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100b8b:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100b8e:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100b8f:	39 f0                	cmp    %esi,%eax
f0100b91:	7d 18                	jge    f0100bab <debuginfo_eip+0x19e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100b93:	8a 0a                	mov    (%edx),%cl
f0100b95:	83 c2 0c             	add    $0xc,%edx
f0100b98:	80 f9 a0             	cmp    $0xa0,%cl
f0100b9b:	74 ee                	je     f0100b8b <debuginfo_eip+0x17e>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100b9d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ba2:	eb 0c                	jmp    f0100bb0 <debuginfo_eip+0x1a3>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100ba4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ba9:	eb 05                	jmp    f0100bb0 <debuginfo_eip+0x1a3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100bab:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100bb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bb3:	5b                   	pop    %ebx
f0100bb4:	5e                   	pop    %esi
f0100bb5:	5f                   	pop    %edi
f0100bb6:	c9                   	leave  
f0100bb7:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100bb8:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100bbb:	8b 87 24 1f 10 f0    	mov    -0xfefe0dc(%edi),%eax
f0100bc1:	ba 25 d7 10 f0       	mov    $0xf010d725,%edx
f0100bc6:	81 ea 25 64 10 f0    	sub    $0xf0106425,%edx
f0100bcc:	39 d0                	cmp    %edx,%eax
f0100bce:	72 97                	jb     f0100b67 <debuginfo_eip+0x15a>
f0100bd0:	eb 9c                	jmp    f0100b6e <debuginfo_eip+0x161>
	...

f0100bd4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100bd4:	55                   	push   %ebp
f0100bd5:	89 e5                	mov    %esp,%ebp
f0100bd7:	57                   	push   %edi
f0100bd8:	56                   	push   %esi
f0100bd9:	53                   	push   %ebx
f0100bda:	83 ec 2c             	sub    $0x2c,%esp
f0100bdd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100be0:	89 d6                	mov    %edx,%esi
f0100be2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100be5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100be8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100beb:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100bee:	8b 45 10             	mov    0x10(%ebp),%eax
f0100bf1:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100bf4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100bf7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100bfa:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100c01:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0100c04:	72 0c                	jb     f0100c12 <printnum+0x3e>
f0100c06:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100c09:	76 07                	jbe    f0100c12 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100c0b:	4b                   	dec    %ebx
f0100c0c:	85 db                	test   %ebx,%ebx
f0100c0e:	7f 31                	jg     f0100c41 <printnum+0x6d>
f0100c10:	eb 3f                	jmp    f0100c51 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100c12:	83 ec 0c             	sub    $0xc,%esp
f0100c15:	57                   	push   %edi
f0100c16:	4b                   	dec    %ebx
f0100c17:	53                   	push   %ebx
f0100c18:	50                   	push   %eax
f0100c19:	83 ec 08             	sub    $0x8,%esp
f0100c1c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100c1f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100c22:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c25:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c28:	e8 83 09 00 00       	call   f01015b0 <__udivdi3>
f0100c2d:	83 c4 18             	add    $0x18,%esp
f0100c30:	52                   	push   %edx
f0100c31:	50                   	push   %eax
f0100c32:	89 f2                	mov    %esi,%edx
f0100c34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c37:	e8 98 ff ff ff       	call   f0100bd4 <printnum>
f0100c3c:	83 c4 20             	add    $0x20,%esp
f0100c3f:	eb 10                	jmp    f0100c51 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100c41:	83 ec 08             	sub    $0x8,%esp
f0100c44:	56                   	push   %esi
f0100c45:	57                   	push   %edi
f0100c46:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100c49:	4b                   	dec    %ebx
f0100c4a:	83 c4 10             	add    $0x10,%esp
f0100c4d:	85 db                	test   %ebx,%ebx
f0100c4f:	7f f0                	jg     f0100c41 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100c51:	83 ec 08             	sub    $0x8,%esp
f0100c54:	56                   	push   %esi
f0100c55:	83 ec 04             	sub    $0x4,%esp
f0100c58:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100c5b:	ff 75 d0             	pushl  -0x30(%ebp)
f0100c5e:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c61:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c64:	e8 63 0a 00 00       	call   f01016cc <__umoddi3>
f0100c69:	83 c4 14             	add    $0x14,%esp
f0100c6c:	0f be 80 11 1d 10 f0 	movsbl -0xfefe2ef(%eax),%eax
f0100c73:	50                   	push   %eax
f0100c74:	ff 55 e4             	call   *-0x1c(%ebp)
f0100c77:	83 c4 10             	add    $0x10,%esp
}
f0100c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c7d:	5b                   	pop    %ebx
f0100c7e:	5e                   	pop    %esi
f0100c7f:	5f                   	pop    %edi
f0100c80:	c9                   	leave  
f0100c81:	c3                   	ret    

f0100c82 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100c82:	55                   	push   %ebp
f0100c83:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100c85:	83 fa 01             	cmp    $0x1,%edx
f0100c88:	7e 0e                	jle    f0100c98 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100c8a:	8b 10                	mov    (%eax),%edx
f0100c8c:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100c8f:	89 08                	mov    %ecx,(%eax)
f0100c91:	8b 02                	mov    (%edx),%eax
f0100c93:	8b 52 04             	mov    0x4(%edx),%edx
f0100c96:	eb 22                	jmp    f0100cba <getuint+0x38>
	else if (lflag)
f0100c98:	85 d2                	test   %edx,%edx
f0100c9a:	74 10                	je     f0100cac <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100c9c:	8b 10                	mov    (%eax),%edx
f0100c9e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100ca1:	89 08                	mov    %ecx,(%eax)
f0100ca3:	8b 02                	mov    (%edx),%eax
f0100ca5:	ba 00 00 00 00       	mov    $0x0,%edx
f0100caa:	eb 0e                	jmp    f0100cba <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100cac:	8b 10                	mov    (%eax),%edx
f0100cae:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100cb1:	89 08                	mov    %ecx,(%eax)
f0100cb3:	8b 02                	mov    (%edx),%eax
f0100cb5:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100cba:	c9                   	leave  
f0100cbb:	c3                   	ret    

f0100cbc <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0100cbc:	55                   	push   %ebp
f0100cbd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100cbf:	83 fa 01             	cmp    $0x1,%edx
f0100cc2:	7e 0e                	jle    f0100cd2 <getint+0x16>
		return va_arg(*ap, long long);
f0100cc4:	8b 10                	mov    (%eax),%edx
f0100cc6:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100cc9:	89 08                	mov    %ecx,(%eax)
f0100ccb:	8b 02                	mov    (%edx),%eax
f0100ccd:	8b 52 04             	mov    0x4(%edx),%edx
f0100cd0:	eb 1a                	jmp    f0100cec <getint+0x30>
	else if (lflag)
f0100cd2:	85 d2                	test   %edx,%edx
f0100cd4:	74 0c                	je     f0100ce2 <getint+0x26>
		return va_arg(*ap, long);
f0100cd6:	8b 10                	mov    (%eax),%edx
f0100cd8:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100cdb:	89 08                	mov    %ecx,(%eax)
f0100cdd:	8b 02                	mov    (%edx),%eax
f0100cdf:	99                   	cltd   
f0100ce0:	eb 0a                	jmp    f0100cec <getint+0x30>
	else
		return va_arg(*ap, int);
f0100ce2:	8b 10                	mov    (%eax),%edx
f0100ce4:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100ce7:	89 08                	mov    %ecx,(%eax)
f0100ce9:	8b 02                	mov    (%edx),%eax
f0100ceb:	99                   	cltd   
}
f0100cec:	c9                   	leave  
f0100ced:	c3                   	ret    

f0100cee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100cee:	55                   	push   %ebp
f0100cef:	89 e5                	mov    %esp,%ebp
f0100cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100cf4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100cf7:	8b 10                	mov    (%eax),%edx
f0100cf9:	3b 50 04             	cmp    0x4(%eax),%edx
f0100cfc:	73 08                	jae    f0100d06 <sprintputch+0x18>
		*b->buf++ = ch;
f0100cfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100d01:	88 0a                	mov    %cl,(%edx)
f0100d03:	42                   	inc    %edx
f0100d04:	89 10                	mov    %edx,(%eax)
}
f0100d06:	c9                   	leave  
f0100d07:	c3                   	ret    

f0100d08 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100d08:	55                   	push   %ebp
f0100d09:	89 e5                	mov    %esp,%ebp
f0100d0b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100d0e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100d11:	50                   	push   %eax
f0100d12:	ff 75 10             	pushl  0x10(%ebp)
f0100d15:	ff 75 0c             	pushl  0xc(%ebp)
f0100d18:	ff 75 08             	pushl  0x8(%ebp)
f0100d1b:	e8 05 00 00 00       	call   f0100d25 <vprintfmt>
	va_end(ap);
f0100d20:	83 c4 10             	add    $0x10,%esp
}
f0100d23:	c9                   	leave  
f0100d24:	c3                   	ret    

f0100d25 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100d25:	55                   	push   %ebp
f0100d26:	89 e5                	mov    %esp,%ebp
f0100d28:	57                   	push   %edi
f0100d29:	56                   	push   %esi
f0100d2a:	53                   	push   %ebx
f0100d2b:	83 ec 2c             	sub    $0x2c,%esp
f0100d2e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100d31:	8b 75 10             	mov    0x10(%ebp),%esi
f0100d34:	eb 21                	jmp    f0100d57 <vprintfmt+0x32>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
f0100d36:	85 c0                	test   %eax,%eax
f0100d38:	75 12                	jne    f0100d4c <vprintfmt+0x27>
				MIGHTY_ME = 0x0700;
f0100d3a:	c7 05 44 89 11 f0 00 	movl   $0x700,0xf0118944
f0100d41:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f0100d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d47:	5b                   	pop    %ebx
f0100d48:	5e                   	pop    %esi
f0100d49:	5f                   	pop    %edi
f0100d4a:	c9                   	leave  
f0100d4b:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				MIGHTY_ME = 0x0700;
				return;
			}
			putch(ch, putdat);
f0100d4c:	83 ec 08             	sub    $0x8,%esp
f0100d4f:	57                   	push   %edi
f0100d50:	50                   	push   %eax
f0100d51:	ff 55 08             	call   *0x8(%ebp)
f0100d54:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100d57:	0f b6 06             	movzbl (%esi),%eax
f0100d5a:	46                   	inc    %esi
f0100d5b:	83 f8 25             	cmp    $0x25,%eax
f0100d5e:	75 d6                	jne    f0100d36 <vprintfmt+0x11>
f0100d60:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0100d64:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100d6b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0100d72:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100d79:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d7e:	eb 28                	jmp    f0100da8 <vprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d80:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100d82:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0100d86:	eb 20                	jmp    f0100da8 <vprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d88:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100d8a:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0100d8e:	eb 18                	jmp    f0100da8 <vprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d90:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0100d92:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100d99:	eb 0d                	jmp    f0100da8 <vprintfmt+0x83>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100d9b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100da1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100da8:	8a 06                	mov    (%esi),%al
f0100daa:	0f b6 c8             	movzbl %al,%ecx
f0100dad:	8d 5e 01             	lea    0x1(%esi),%ebx
f0100db0:	83 e8 23             	sub    $0x23,%eax
f0100db3:	3c 55                	cmp    $0x55,%al
f0100db5:	0f 87 c7 02 00 00    	ja     f0101082 <vprintfmt+0x35d>
f0100dbb:	0f b6 c0             	movzbl %al,%eax
f0100dbe:	ff 24 85 a0 1d 10 f0 	jmp    *-0xfefe260(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100dc5:	83 e9 30             	sub    $0x30,%ecx
f0100dc8:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
				ch = *fmt;
f0100dcb:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0100dce:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0100dd1:	83 f9 09             	cmp    $0x9,%ecx
f0100dd4:	77 44                	ja     f0100e1a <vprintfmt+0xf5>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dd6:	89 de                	mov    %ebx,%esi
f0100dd8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100ddb:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0100ddc:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0100ddf:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0100de3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0100de6:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0100de9:	83 fb 09             	cmp    $0x9,%ebx
f0100dec:	76 ed                	jbe    f0100ddb <vprintfmt+0xb6>
f0100dee:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100df1:	eb 29                	jmp    f0100e1c <vprintfmt+0xf7>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100df3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100df6:	8d 48 04             	lea    0x4(%eax),%ecx
f0100df9:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100dfc:	8b 00                	mov    (%eax),%eax
f0100dfe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e01:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100e03:	eb 17                	jmp    f0100e1c <vprintfmt+0xf7>

		case '.':
			if (width < 0)
f0100e05:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100e09:	78 85                	js     f0100d90 <vprintfmt+0x6b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e0b:	89 de                	mov    %ebx,%esi
f0100e0d:	eb 99                	jmp    f0100da8 <vprintfmt+0x83>
f0100e0f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100e11:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0100e18:	eb 8e                	jmp    f0100da8 <vprintfmt+0x83>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e1a:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100e1c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100e20:	79 86                	jns    f0100da8 <vprintfmt+0x83>
f0100e22:	e9 74 ff ff ff       	jmp    f0100d9b <vprintfmt+0x76>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100e27:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e28:	89 de                	mov    %ebx,%esi
f0100e2a:	e9 79 ff ff ff       	jmp    f0100da8 <vprintfmt+0x83>
f0100e2f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100e32:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e35:	8d 50 04             	lea    0x4(%eax),%edx
f0100e38:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e3b:	83 ec 08             	sub    $0x8,%esp
f0100e3e:	57                   	push   %edi
f0100e3f:	ff 30                	pushl  (%eax)
f0100e41:	ff 55 08             	call   *0x8(%ebp)
			break;
f0100e44:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e47:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100e4a:	e9 08 ff ff ff       	jmp    f0100d57 <vprintfmt+0x32>
f0100e4f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100e52:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e55:	8d 50 04             	lea    0x4(%eax),%edx
f0100e58:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e5b:	8b 00                	mov    (%eax),%eax
f0100e5d:	85 c0                	test   %eax,%eax
f0100e5f:	79 02                	jns    f0100e63 <vprintfmt+0x13e>
f0100e61:	f7 d8                	neg    %eax
f0100e63:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100e65:	83 f8 06             	cmp    $0x6,%eax
f0100e68:	7f 0b                	jg     f0100e75 <vprintfmt+0x150>
f0100e6a:	8b 04 85 f8 1e 10 f0 	mov    -0xfefe108(,%eax,4),%eax
f0100e71:	85 c0                	test   %eax,%eax
f0100e73:	75 1a                	jne    f0100e8f <vprintfmt+0x16a>
				printfmt(putch, putdat, "error %d", err);
f0100e75:	52                   	push   %edx
f0100e76:	68 29 1d 10 f0       	push   $0xf0101d29
f0100e7b:	57                   	push   %edi
f0100e7c:	ff 75 08             	pushl  0x8(%ebp)
f0100e7f:	e8 84 fe ff ff       	call   f0100d08 <printfmt>
f0100e84:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e87:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100e8a:	e9 c8 fe ff ff       	jmp    f0100d57 <vprintfmt+0x32>
			else
				printfmt(putch, putdat, "%s", p);
f0100e8f:	50                   	push   %eax
f0100e90:	68 32 1d 10 f0       	push   $0xf0101d32
f0100e95:	57                   	push   %edi
f0100e96:	ff 75 08             	pushl  0x8(%ebp)
f0100e99:	e8 6a fe ff ff       	call   f0100d08 <printfmt>
f0100e9e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ea1:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0100ea4:	e9 ae fe ff ff       	jmp    f0100d57 <vprintfmt+0x32>
f0100ea9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0100eac:	89 de                	mov    %ebx,%esi
f0100eae:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100eb1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100eb4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eb7:	8d 50 04             	lea    0x4(%eax),%edx
f0100eba:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ebd:	8b 00                	mov    (%eax),%eax
f0100ebf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100ec2:	85 c0                	test   %eax,%eax
f0100ec4:	75 07                	jne    f0100ecd <vprintfmt+0x1a8>
				p = "(null)";
f0100ec6:	c7 45 d0 22 1d 10 f0 	movl   $0xf0101d22,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0100ecd:	85 db                	test   %ebx,%ebx
f0100ecf:	7e 42                	jle    f0100f13 <vprintfmt+0x1ee>
f0100ed1:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0100ed5:	74 3c                	je     f0100f13 <vprintfmt+0x1ee>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ed7:	83 ec 08             	sub    $0x8,%esp
f0100eda:	51                   	push   %ecx
f0100edb:	ff 75 d0             	pushl  -0x30(%ebp)
f0100ede:	e8 1d 03 00 00       	call   f0101200 <strnlen>
f0100ee3:	29 c3                	sub    %eax,%ebx
f0100ee5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100ee8:	83 c4 10             	add    $0x10,%esp
f0100eeb:	85 db                	test   %ebx,%ebx
f0100eed:	7e 24                	jle    f0100f13 <vprintfmt+0x1ee>
					putch(padc, putdat);
f0100eef:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0100ef3:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0100ef6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ef9:	83 ec 08             	sub    $0x8,%esp
f0100efc:	57                   	push   %edi
f0100efd:	53                   	push   %ebx
f0100efe:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f01:	4e                   	dec    %esi
f0100f02:	83 c4 10             	add    $0x10,%esp
f0100f05:	85 f6                	test   %esi,%esi
f0100f07:	7f f0                	jg     f0100ef9 <vprintfmt+0x1d4>
f0100f09:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100f0c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f13:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100f16:	0f be 02             	movsbl (%edx),%eax
f0100f19:	85 c0                	test   %eax,%eax
f0100f1b:	75 47                	jne    f0100f64 <vprintfmt+0x23f>
f0100f1d:	eb 37                	jmp    f0100f56 <vprintfmt+0x231>
				if (altflag && (ch < ' ' || ch > '~'))
f0100f1f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f23:	74 16                	je     f0100f3b <vprintfmt+0x216>
f0100f25:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100f28:	83 fa 5e             	cmp    $0x5e,%edx
f0100f2b:	76 0e                	jbe    f0100f3b <vprintfmt+0x216>
					putch('?', putdat);
f0100f2d:	83 ec 08             	sub    $0x8,%esp
f0100f30:	57                   	push   %edi
f0100f31:	6a 3f                	push   $0x3f
f0100f33:	ff 55 08             	call   *0x8(%ebp)
f0100f36:	83 c4 10             	add    $0x10,%esp
f0100f39:	eb 0b                	jmp    f0100f46 <vprintfmt+0x221>
				else
					putch(ch, putdat);
f0100f3b:	83 ec 08             	sub    $0x8,%esp
f0100f3e:	57                   	push   %edi
f0100f3f:	50                   	push   %eax
f0100f40:	ff 55 08             	call   *0x8(%ebp)
f0100f43:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f46:	ff 4d e4             	decl   -0x1c(%ebp)
f0100f49:	0f be 03             	movsbl (%ebx),%eax
f0100f4c:	85 c0                	test   %eax,%eax
f0100f4e:	74 03                	je     f0100f53 <vprintfmt+0x22e>
f0100f50:	43                   	inc    %ebx
f0100f51:	eb 1b                	jmp    f0100f6e <vprintfmt+0x249>
f0100f53:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100f56:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100f5a:	7f 1e                	jg     f0100f7a <vprintfmt+0x255>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f5c:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0100f5f:	e9 f3 fd ff ff       	jmp    f0100d57 <vprintfmt+0x32>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f64:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100f67:	43                   	inc    %ebx
f0100f68:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0100f6b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0100f6e:	85 f6                	test   %esi,%esi
f0100f70:	78 ad                	js     f0100f1f <vprintfmt+0x1fa>
f0100f72:	4e                   	dec    %esi
f0100f73:	79 aa                	jns    f0100f1f <vprintfmt+0x1fa>
f0100f75:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100f78:	eb dc                	jmp    f0100f56 <vprintfmt+0x231>
f0100f7a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100f7d:	83 ec 08             	sub    $0x8,%esp
f0100f80:	57                   	push   %edi
f0100f81:	6a 20                	push   $0x20
f0100f83:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100f86:	4b                   	dec    %ebx
f0100f87:	83 c4 10             	add    $0x10,%esp
f0100f8a:	85 db                	test   %ebx,%ebx
f0100f8c:	7f ef                	jg     f0100f7d <vprintfmt+0x258>
f0100f8e:	e9 c4 fd ff ff       	jmp    f0100d57 <vprintfmt+0x32>
f0100f93:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0100f96:	8d 45 14             	lea    0x14(%ebp),%eax
f0100f99:	e8 1e fd ff ff       	call   f0100cbc <getint>
f0100f9e:	89 c3                	mov    %eax,%ebx
f0100fa0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0100fa2:	85 d2                	test   %edx,%edx
f0100fa4:	78 0a                	js     f0100fb0 <vprintfmt+0x28b>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0100fa6:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0100fab:	e9 81 00 00 00       	jmp    f0101031 <vprintfmt+0x30c>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0100fb0:	83 ec 08             	sub    $0x8,%esp
f0100fb3:	57                   	push   %edi
f0100fb4:	6a 2d                	push   $0x2d
f0100fb6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0100fb9:	89 d8                	mov    %ebx,%eax
f0100fbb:	89 f2                	mov    %esi,%edx
f0100fbd:	f7 d8                	neg    %eax
f0100fbf:	83 d2 00             	adc    $0x0,%edx
f0100fc2:	f7 da                	neg    %edx
f0100fc4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0100fc7:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0100fcc:	eb 63                	jmp    f0101031 <vprintfmt+0x30c>
f0100fce:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0100fd1:	8d 45 14             	lea    0x14(%ebp),%eax
f0100fd4:	e8 a9 fc ff ff       	call   f0100c82 <getuint>
			base = 10;
f0100fd9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0100fde:	eb 51                	jmp    f0101031 <vprintfmt+0x30c>
f0100fe0:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
    case 'o':
      num = getuint(&ap, lflag);
f0100fe3:	8d 45 14             	lea    0x14(%ebp),%eax
f0100fe6:	e8 97 fc ff ff       	call   f0100c82 <getuint>
      base = 8;
f0100feb:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
f0100ff0:	eb 3f                	jmp    f0101031 <vprintfmt+0x30c>
f0100ff2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0100ff5:	83 ec 08             	sub    $0x8,%esp
f0100ff8:	57                   	push   %edi
f0100ff9:	6a 30                	push   $0x30
f0100ffb:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0100ffe:	83 c4 08             	add    $0x8,%esp
f0101001:	57                   	push   %edi
f0101002:	6a 78                	push   $0x78
f0101004:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101007:	8b 45 14             	mov    0x14(%ebp),%eax
f010100a:	8d 50 04             	lea    0x4(%eax),%edx
f010100d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101010:	8b 00                	mov    (%eax),%eax
f0101012:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101017:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010101a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010101f:	eb 10                	jmp    f0101031 <vprintfmt+0x30c>
f0101021:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101024:	8d 45 14             	lea    0x14(%ebp),%eax
f0101027:	e8 56 fc ff ff       	call   f0100c82 <getuint>
			base = 16;
f010102c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101031:	83 ec 0c             	sub    $0xc,%esp
f0101034:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0101038:	53                   	push   %ebx
f0101039:	ff 75 e4             	pushl  -0x1c(%ebp)
f010103c:	51                   	push   %ecx
f010103d:	52                   	push   %edx
f010103e:	50                   	push   %eax
f010103f:	89 fa                	mov    %edi,%edx
f0101041:	8b 45 08             	mov    0x8(%ebp),%eax
f0101044:	e8 8b fb ff ff       	call   f0100bd4 <printnum>
			break;
f0101049:	83 c4 20             	add    $0x20,%esp
f010104c:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010104f:	e9 03 fd ff ff       	jmp    f0100d57 <vprintfmt+0x32>
f0101054:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101057:	83 ec 08             	sub    $0x8,%esp
f010105a:	57                   	push   %edi
f010105b:	51                   	push   %ecx
f010105c:	ff 55 08             	call   *0x8(%ebp)
			break;
f010105f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101062:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101065:	e9 ed fc ff ff       	jmp    f0100d57 <vprintfmt+0x32>
f010106a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		case 'm':
			num = getint(&ap, lflag);
f010106d:	8d 45 14             	lea    0x14(%ebp),%eax
f0101070:	e8 47 fc ff ff       	call   f0100cbc <getint>
			MIGHTY_ME=num;
f0101075:	a3 44 89 11 f0       	mov    %eax,0xf0118944
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010107a:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		case 'm':
			num = getint(&ap, lflag);
			MIGHTY_ME=num;
			break;
f010107d:	e9 d5 fc ff ff       	jmp    f0100d57 <vprintfmt+0x32>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101082:	83 ec 08             	sub    $0x8,%esp
f0101085:	57                   	push   %edi
f0101086:	6a 25                	push   $0x25
f0101088:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010108b:	83 c4 10             	add    $0x10,%esp
f010108e:	eb 02                	jmp    f0101092 <vprintfmt+0x36d>
f0101090:	89 c6                	mov    %eax,%esi
f0101092:	8d 46 ff             	lea    -0x1(%esi),%eax
f0101095:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101099:	75 f5                	jne    f0101090 <vprintfmt+0x36b>
f010109b:	e9 b7 fc ff ff       	jmp    f0100d57 <vprintfmt+0x32>

f01010a0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01010a0:	55                   	push   %ebp
f01010a1:	89 e5                	mov    %esp,%ebp
f01010a3:	83 ec 18             	sub    $0x18,%esp
f01010a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01010a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01010ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01010af:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01010b3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01010b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01010bd:	85 c0                	test   %eax,%eax
f01010bf:	74 26                	je     f01010e7 <vsnprintf+0x47>
f01010c1:	85 d2                	test   %edx,%edx
f01010c3:	7e 29                	jle    f01010ee <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01010c5:	ff 75 14             	pushl  0x14(%ebp)
f01010c8:	ff 75 10             	pushl  0x10(%ebp)
f01010cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01010ce:	50                   	push   %eax
f01010cf:	68 ee 0c 10 f0       	push   $0xf0100cee
f01010d4:	e8 4c fc ff ff       	call   f0100d25 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01010d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01010dc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01010df:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01010e2:	83 c4 10             	add    $0x10,%esp
f01010e5:	eb 0c                	jmp    f01010f3 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01010e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01010ec:	eb 05                	jmp    f01010f3 <vsnprintf+0x53>
f01010ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01010f3:	c9                   	leave  
f01010f4:	c3                   	ret    

f01010f5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01010f5:	55                   	push   %ebp
f01010f6:	89 e5                	mov    %esp,%ebp
f01010f8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01010fb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01010fe:	50                   	push   %eax
f01010ff:	ff 75 10             	pushl  0x10(%ebp)
f0101102:	ff 75 0c             	pushl  0xc(%ebp)
f0101105:	ff 75 08             	pushl  0x8(%ebp)
f0101108:	e8 93 ff ff ff       	call   f01010a0 <vsnprintf>
	va_end(ap);

	return rc;
}
f010110d:	c9                   	leave  
f010110e:	c3                   	ret    
	...

f0101110 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101110:	55                   	push   %ebp
f0101111:	89 e5                	mov    %esp,%ebp
f0101113:	57                   	push   %edi
f0101114:	56                   	push   %esi
f0101115:	53                   	push   %ebx
f0101116:	83 ec 0c             	sub    $0xc,%esp
f0101119:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010111c:	85 c0                	test   %eax,%eax
f010111e:	74 11                	je     f0101131 <readline+0x21>
		cprintf("%s", prompt);
f0101120:	83 ec 08             	sub    $0x8,%esp
f0101123:	50                   	push   %eax
f0101124:	68 32 1d 10 f0       	push   $0xf0101d32
f0101129:	e8 a3 f7 ff ff       	call   f01008d1 <cprintf>
f010112e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101131:	83 ec 0c             	sub    $0xc,%esp
f0101134:	6a 00                	push   $0x0
f0101136:	e8 f1 f4 ff ff       	call   f010062c <iscons>
f010113b:	89 c7                	mov    %eax,%edi
f010113d:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101140:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101145:	e8 d1 f4 ff ff       	call   f010061b <getchar>
f010114a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010114c:	85 c0                	test   %eax,%eax
f010114e:	79 18                	jns    f0101168 <readline+0x58>
			cprintf("read error: %e\n", c);
f0101150:	83 ec 08             	sub    $0x8,%esp
f0101153:	50                   	push   %eax
f0101154:	68 14 1f 10 f0       	push   $0xf0101f14
f0101159:	e8 73 f7 ff ff       	call   f01008d1 <cprintf>
			return NULL;
f010115e:	83 c4 10             	add    $0x10,%esp
f0101161:	b8 00 00 00 00       	mov    $0x0,%eax
f0101166:	eb 6f                	jmp    f01011d7 <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101168:	83 f8 08             	cmp    $0x8,%eax
f010116b:	74 05                	je     f0101172 <readline+0x62>
f010116d:	83 f8 7f             	cmp    $0x7f,%eax
f0101170:	75 18                	jne    f010118a <readline+0x7a>
f0101172:	85 f6                	test   %esi,%esi
f0101174:	7e 14                	jle    f010118a <readline+0x7a>
			if (echoing)
f0101176:	85 ff                	test   %edi,%edi
f0101178:	74 0d                	je     f0101187 <readline+0x77>
				cputchar('\b');
f010117a:	83 ec 0c             	sub    $0xc,%esp
f010117d:	6a 08                	push   $0x8
f010117f:	e8 87 f4 ff ff       	call   f010060b <cputchar>
f0101184:	83 c4 10             	add    $0x10,%esp
			i--;
f0101187:	4e                   	dec    %esi
f0101188:	eb bb                	jmp    f0101145 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010118a:	83 fb 1f             	cmp    $0x1f,%ebx
f010118d:	7e 21                	jle    f01011b0 <readline+0xa0>
f010118f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101195:	7f 19                	jg     f01011b0 <readline+0xa0>
			if (echoing)
f0101197:	85 ff                	test   %edi,%edi
f0101199:	74 0c                	je     f01011a7 <readline+0x97>
				cputchar(c);
f010119b:	83 ec 0c             	sub    $0xc,%esp
f010119e:	53                   	push   %ebx
f010119f:	e8 67 f4 ff ff       	call   f010060b <cputchar>
f01011a4:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01011a7:	88 9e 40 85 11 f0    	mov    %bl,-0xfee7ac0(%esi)
f01011ad:	46                   	inc    %esi
f01011ae:	eb 95                	jmp    f0101145 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01011b0:	83 fb 0a             	cmp    $0xa,%ebx
f01011b3:	74 05                	je     f01011ba <readline+0xaa>
f01011b5:	83 fb 0d             	cmp    $0xd,%ebx
f01011b8:	75 8b                	jne    f0101145 <readline+0x35>
			if (echoing)
f01011ba:	85 ff                	test   %edi,%edi
f01011bc:	74 0d                	je     f01011cb <readline+0xbb>
				cputchar('\n');
f01011be:	83 ec 0c             	sub    $0xc,%esp
f01011c1:	6a 0a                	push   $0xa
f01011c3:	e8 43 f4 ff ff       	call   f010060b <cputchar>
f01011c8:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01011cb:	c6 86 40 85 11 f0 00 	movb   $0x0,-0xfee7ac0(%esi)
			return buf;
f01011d2:	b8 40 85 11 f0       	mov    $0xf0118540,%eax
		}
	}
}
f01011d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011da:	5b                   	pop    %ebx
f01011db:	5e                   	pop    %esi
f01011dc:	5f                   	pop    %edi
f01011dd:	c9                   	leave  
f01011de:	c3                   	ret    
	...

f01011e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01011e0:	55                   	push   %ebp
f01011e1:	89 e5                	mov    %esp,%ebp
f01011e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01011e6:	80 3a 00             	cmpb   $0x0,(%edx)
f01011e9:	74 0e                	je     f01011f9 <strlen+0x19>
f01011eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01011f0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01011f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01011f5:	75 f9                	jne    f01011f0 <strlen+0x10>
f01011f7:	eb 05                	jmp    f01011fe <strlen+0x1e>
f01011f9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01011fe:	c9                   	leave  
f01011ff:	c3                   	ret    

f0101200 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101200:	55                   	push   %ebp
f0101201:	89 e5                	mov    %esp,%ebp
f0101203:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101206:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101209:	85 d2                	test   %edx,%edx
f010120b:	74 17                	je     f0101224 <strnlen+0x24>
f010120d:	80 39 00             	cmpb   $0x0,(%ecx)
f0101210:	74 19                	je     f010122b <strnlen+0x2b>
f0101212:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101217:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101218:	39 d0                	cmp    %edx,%eax
f010121a:	74 14                	je     f0101230 <strnlen+0x30>
f010121c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101220:	75 f5                	jne    f0101217 <strnlen+0x17>
f0101222:	eb 0c                	jmp    f0101230 <strnlen+0x30>
f0101224:	b8 00 00 00 00       	mov    $0x0,%eax
f0101229:	eb 05                	jmp    f0101230 <strnlen+0x30>
f010122b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101230:	c9                   	leave  
f0101231:	c3                   	ret    

f0101232 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101232:	55                   	push   %ebp
f0101233:	89 e5                	mov    %esp,%ebp
f0101235:	53                   	push   %ebx
f0101236:	8b 45 08             	mov    0x8(%ebp),%eax
f0101239:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010123c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101241:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0101244:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101247:	42                   	inc    %edx
f0101248:	84 c9                	test   %cl,%cl
f010124a:	75 f5                	jne    f0101241 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010124c:	5b                   	pop    %ebx
f010124d:	c9                   	leave  
f010124e:	c3                   	ret    

f010124f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010124f:	55                   	push   %ebp
f0101250:	89 e5                	mov    %esp,%ebp
f0101252:	53                   	push   %ebx
f0101253:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101256:	53                   	push   %ebx
f0101257:	e8 84 ff ff ff       	call   f01011e0 <strlen>
f010125c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010125f:	ff 75 0c             	pushl  0xc(%ebp)
f0101262:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0101265:	50                   	push   %eax
f0101266:	e8 c7 ff ff ff       	call   f0101232 <strcpy>
	return dst;
}
f010126b:	89 d8                	mov    %ebx,%eax
f010126d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101270:	c9                   	leave  
f0101271:	c3                   	ret    

f0101272 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101272:	55                   	push   %ebp
f0101273:	89 e5                	mov    %esp,%ebp
f0101275:	56                   	push   %esi
f0101276:	53                   	push   %ebx
f0101277:	8b 45 08             	mov    0x8(%ebp),%eax
f010127a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010127d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101280:	85 f6                	test   %esi,%esi
f0101282:	74 15                	je     f0101299 <strncpy+0x27>
f0101284:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101289:	8a 1a                	mov    (%edx),%bl
f010128b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010128e:	80 3a 01             	cmpb   $0x1,(%edx)
f0101291:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101294:	41                   	inc    %ecx
f0101295:	39 ce                	cmp    %ecx,%esi
f0101297:	77 f0                	ja     f0101289 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101299:	5b                   	pop    %ebx
f010129a:	5e                   	pop    %esi
f010129b:	c9                   	leave  
f010129c:	c3                   	ret    

f010129d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010129d:	55                   	push   %ebp
f010129e:	89 e5                	mov    %esp,%ebp
f01012a0:	57                   	push   %edi
f01012a1:	56                   	push   %esi
f01012a2:	53                   	push   %ebx
f01012a3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01012a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012a9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01012ac:	85 f6                	test   %esi,%esi
f01012ae:	74 32                	je     f01012e2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f01012b0:	83 fe 01             	cmp    $0x1,%esi
f01012b3:	74 22                	je     f01012d7 <strlcpy+0x3a>
f01012b5:	8a 0b                	mov    (%ebx),%cl
f01012b7:	84 c9                	test   %cl,%cl
f01012b9:	74 20                	je     f01012db <strlcpy+0x3e>
f01012bb:	89 f8                	mov    %edi,%eax
f01012bd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01012c2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01012c5:	88 08                	mov    %cl,(%eax)
f01012c7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01012c8:	39 f2                	cmp    %esi,%edx
f01012ca:	74 11                	je     f01012dd <strlcpy+0x40>
f01012cc:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f01012d0:	42                   	inc    %edx
f01012d1:	84 c9                	test   %cl,%cl
f01012d3:	75 f0                	jne    f01012c5 <strlcpy+0x28>
f01012d5:	eb 06                	jmp    f01012dd <strlcpy+0x40>
f01012d7:	89 f8                	mov    %edi,%eax
f01012d9:	eb 02                	jmp    f01012dd <strlcpy+0x40>
f01012db:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01012dd:	c6 00 00             	movb   $0x0,(%eax)
f01012e0:	eb 02                	jmp    f01012e4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01012e2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f01012e4:	29 f8                	sub    %edi,%eax
}
f01012e6:	5b                   	pop    %ebx
f01012e7:	5e                   	pop    %esi
f01012e8:	5f                   	pop    %edi
f01012e9:	c9                   	leave  
f01012ea:	c3                   	ret    

f01012eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01012eb:	55                   	push   %ebp
f01012ec:	89 e5                	mov    %esp,%ebp
f01012ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01012f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01012f4:	8a 01                	mov    (%ecx),%al
f01012f6:	84 c0                	test   %al,%al
f01012f8:	74 10                	je     f010130a <strcmp+0x1f>
f01012fa:	3a 02                	cmp    (%edx),%al
f01012fc:	75 0c                	jne    f010130a <strcmp+0x1f>
		p++, q++;
f01012fe:	41                   	inc    %ecx
f01012ff:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101300:	8a 01                	mov    (%ecx),%al
f0101302:	84 c0                	test   %al,%al
f0101304:	74 04                	je     f010130a <strcmp+0x1f>
f0101306:	3a 02                	cmp    (%edx),%al
f0101308:	74 f4                	je     f01012fe <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010130a:	0f b6 c0             	movzbl %al,%eax
f010130d:	0f b6 12             	movzbl (%edx),%edx
f0101310:	29 d0                	sub    %edx,%eax
}
f0101312:	c9                   	leave  
f0101313:	c3                   	ret    

f0101314 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101314:	55                   	push   %ebp
f0101315:	89 e5                	mov    %esp,%ebp
f0101317:	53                   	push   %ebx
f0101318:	8b 55 08             	mov    0x8(%ebp),%edx
f010131b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010131e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0101321:	85 c0                	test   %eax,%eax
f0101323:	74 1b                	je     f0101340 <strncmp+0x2c>
f0101325:	8a 1a                	mov    (%edx),%bl
f0101327:	84 db                	test   %bl,%bl
f0101329:	74 24                	je     f010134f <strncmp+0x3b>
f010132b:	3a 19                	cmp    (%ecx),%bl
f010132d:	75 20                	jne    f010134f <strncmp+0x3b>
f010132f:	48                   	dec    %eax
f0101330:	74 15                	je     f0101347 <strncmp+0x33>
		n--, p++, q++;
f0101332:	42                   	inc    %edx
f0101333:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101334:	8a 1a                	mov    (%edx),%bl
f0101336:	84 db                	test   %bl,%bl
f0101338:	74 15                	je     f010134f <strncmp+0x3b>
f010133a:	3a 19                	cmp    (%ecx),%bl
f010133c:	74 f1                	je     f010132f <strncmp+0x1b>
f010133e:	eb 0f                	jmp    f010134f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101340:	b8 00 00 00 00       	mov    $0x0,%eax
f0101345:	eb 05                	jmp    f010134c <strncmp+0x38>
f0101347:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010134c:	5b                   	pop    %ebx
f010134d:	c9                   	leave  
f010134e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010134f:	0f b6 02             	movzbl (%edx),%eax
f0101352:	0f b6 11             	movzbl (%ecx),%edx
f0101355:	29 d0                	sub    %edx,%eax
f0101357:	eb f3                	jmp    f010134c <strncmp+0x38>

f0101359 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101359:	55                   	push   %ebp
f010135a:	89 e5                	mov    %esp,%ebp
f010135c:	8b 45 08             	mov    0x8(%ebp),%eax
f010135f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0101362:	8a 10                	mov    (%eax),%dl
f0101364:	84 d2                	test   %dl,%dl
f0101366:	74 18                	je     f0101380 <strchr+0x27>
		if (*s == c)
f0101368:	38 ca                	cmp    %cl,%dl
f010136a:	75 06                	jne    f0101372 <strchr+0x19>
f010136c:	eb 17                	jmp    f0101385 <strchr+0x2c>
f010136e:	38 ca                	cmp    %cl,%dl
f0101370:	74 13                	je     f0101385 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101372:	40                   	inc    %eax
f0101373:	8a 10                	mov    (%eax),%dl
f0101375:	84 d2                	test   %dl,%dl
f0101377:	75 f5                	jne    f010136e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0101379:	b8 00 00 00 00       	mov    $0x0,%eax
f010137e:	eb 05                	jmp    f0101385 <strchr+0x2c>
f0101380:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101385:	c9                   	leave  
f0101386:	c3                   	ret    

f0101387 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101387:	55                   	push   %ebp
f0101388:	89 e5                	mov    %esp,%ebp
f010138a:	8b 45 08             	mov    0x8(%ebp),%eax
f010138d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0101390:	8a 10                	mov    (%eax),%dl
f0101392:	84 d2                	test   %dl,%dl
f0101394:	74 11                	je     f01013a7 <strfind+0x20>
		if (*s == c)
f0101396:	38 ca                	cmp    %cl,%dl
f0101398:	75 06                	jne    f01013a0 <strfind+0x19>
f010139a:	eb 0b                	jmp    f01013a7 <strfind+0x20>
f010139c:	38 ca                	cmp    %cl,%dl
f010139e:	74 07                	je     f01013a7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01013a0:	40                   	inc    %eax
f01013a1:	8a 10                	mov    (%eax),%dl
f01013a3:	84 d2                	test   %dl,%dl
f01013a5:	75 f5                	jne    f010139c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f01013a7:	c9                   	leave  
f01013a8:	c3                   	ret    

f01013a9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01013a9:	55                   	push   %ebp
f01013aa:	89 e5                	mov    %esp,%ebp
f01013ac:	57                   	push   %edi
f01013ad:	56                   	push   %esi
f01013ae:	53                   	push   %ebx
f01013af:	8b 7d 08             	mov    0x8(%ebp),%edi
f01013b2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01013b8:	85 c9                	test   %ecx,%ecx
f01013ba:	74 30                	je     f01013ec <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01013bc:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01013c2:	75 25                	jne    f01013e9 <memset+0x40>
f01013c4:	f6 c1 03             	test   $0x3,%cl
f01013c7:	75 20                	jne    f01013e9 <memset+0x40>
		c &= 0xFF;
f01013c9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01013cc:	89 d3                	mov    %edx,%ebx
f01013ce:	c1 e3 08             	shl    $0x8,%ebx
f01013d1:	89 d6                	mov    %edx,%esi
f01013d3:	c1 e6 18             	shl    $0x18,%esi
f01013d6:	89 d0                	mov    %edx,%eax
f01013d8:	c1 e0 10             	shl    $0x10,%eax
f01013db:	09 f0                	or     %esi,%eax
f01013dd:	09 d0                	or     %edx,%eax
f01013df:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01013e1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01013e4:	fc                   	cld    
f01013e5:	f3 ab                	rep stos %eax,%es:(%edi)
f01013e7:	eb 03                	jmp    f01013ec <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01013e9:	fc                   	cld    
f01013ea:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01013ec:	89 f8                	mov    %edi,%eax
f01013ee:	5b                   	pop    %ebx
f01013ef:	5e                   	pop    %esi
f01013f0:	5f                   	pop    %edi
f01013f1:	c9                   	leave  
f01013f2:	c3                   	ret    

f01013f3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01013f3:	55                   	push   %ebp
f01013f4:	89 e5                	mov    %esp,%ebp
f01013f6:	57                   	push   %edi
f01013f7:	56                   	push   %esi
f01013f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01013fb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01013fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101401:	39 c6                	cmp    %eax,%esi
f0101403:	73 34                	jae    f0101439 <memmove+0x46>
f0101405:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101408:	39 d0                	cmp    %edx,%eax
f010140a:	73 2d                	jae    f0101439 <memmove+0x46>
		s += n;
		d += n;
f010140c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010140f:	f6 c2 03             	test   $0x3,%dl
f0101412:	75 1b                	jne    f010142f <memmove+0x3c>
f0101414:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010141a:	75 13                	jne    f010142f <memmove+0x3c>
f010141c:	f6 c1 03             	test   $0x3,%cl
f010141f:	75 0e                	jne    f010142f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101421:	83 ef 04             	sub    $0x4,%edi
f0101424:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101427:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010142a:	fd                   	std    
f010142b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010142d:	eb 07                	jmp    f0101436 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010142f:	4f                   	dec    %edi
f0101430:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101433:	fd                   	std    
f0101434:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101436:	fc                   	cld    
f0101437:	eb 20                	jmp    f0101459 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101439:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010143f:	75 13                	jne    f0101454 <memmove+0x61>
f0101441:	a8 03                	test   $0x3,%al
f0101443:	75 0f                	jne    f0101454 <memmove+0x61>
f0101445:	f6 c1 03             	test   $0x3,%cl
f0101448:	75 0a                	jne    f0101454 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010144a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010144d:	89 c7                	mov    %eax,%edi
f010144f:	fc                   	cld    
f0101450:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101452:	eb 05                	jmp    f0101459 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101454:	89 c7                	mov    %eax,%edi
f0101456:	fc                   	cld    
f0101457:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101459:	5e                   	pop    %esi
f010145a:	5f                   	pop    %edi
f010145b:	c9                   	leave  
f010145c:	c3                   	ret    

f010145d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010145d:	55                   	push   %ebp
f010145e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101460:	ff 75 10             	pushl  0x10(%ebp)
f0101463:	ff 75 0c             	pushl  0xc(%ebp)
f0101466:	ff 75 08             	pushl  0x8(%ebp)
f0101469:	e8 85 ff ff ff       	call   f01013f3 <memmove>
}
f010146e:	c9                   	leave  
f010146f:	c3                   	ret    

f0101470 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101470:	55                   	push   %ebp
f0101471:	89 e5                	mov    %esp,%ebp
f0101473:	57                   	push   %edi
f0101474:	56                   	push   %esi
f0101475:	53                   	push   %ebx
f0101476:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101479:	8b 75 0c             	mov    0xc(%ebp),%esi
f010147c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010147f:	85 ff                	test   %edi,%edi
f0101481:	74 32                	je     f01014b5 <memcmp+0x45>
		if (*s1 != *s2)
f0101483:	8a 03                	mov    (%ebx),%al
f0101485:	8a 0e                	mov    (%esi),%cl
f0101487:	38 c8                	cmp    %cl,%al
f0101489:	74 19                	je     f01014a4 <memcmp+0x34>
f010148b:	eb 0d                	jmp    f010149a <memcmp+0x2a>
f010148d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0101491:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f0101495:	42                   	inc    %edx
f0101496:	38 c8                	cmp    %cl,%al
f0101498:	74 10                	je     f01014aa <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f010149a:	0f b6 c0             	movzbl %al,%eax
f010149d:	0f b6 c9             	movzbl %cl,%ecx
f01014a0:	29 c8                	sub    %ecx,%eax
f01014a2:	eb 16                	jmp    f01014ba <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014a4:	4f                   	dec    %edi
f01014a5:	ba 00 00 00 00       	mov    $0x0,%edx
f01014aa:	39 fa                	cmp    %edi,%edx
f01014ac:	75 df                	jne    f010148d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01014ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01014b3:	eb 05                	jmp    f01014ba <memcmp+0x4a>
f01014b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014ba:	5b                   	pop    %ebx
f01014bb:	5e                   	pop    %esi
f01014bc:	5f                   	pop    %edi
f01014bd:	c9                   	leave  
f01014be:	c3                   	ret    

f01014bf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01014bf:	55                   	push   %ebp
f01014c0:	89 e5                	mov    %esp,%ebp
f01014c2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01014c5:	89 c2                	mov    %eax,%edx
f01014c7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01014ca:	39 d0                	cmp    %edx,%eax
f01014cc:	73 12                	jae    f01014e0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f01014ce:	8a 4d 0c             	mov    0xc(%ebp),%cl
f01014d1:	38 08                	cmp    %cl,(%eax)
f01014d3:	75 06                	jne    f01014db <memfind+0x1c>
f01014d5:	eb 09                	jmp    f01014e0 <memfind+0x21>
f01014d7:	38 08                	cmp    %cl,(%eax)
f01014d9:	74 05                	je     f01014e0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01014db:	40                   	inc    %eax
f01014dc:	39 c2                	cmp    %eax,%edx
f01014de:	77 f7                	ja     f01014d7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01014e0:	c9                   	leave  
f01014e1:	c3                   	ret    

f01014e2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01014e2:	55                   	push   %ebp
f01014e3:	89 e5                	mov    %esp,%ebp
f01014e5:	57                   	push   %edi
f01014e6:	56                   	push   %esi
f01014e7:	53                   	push   %ebx
f01014e8:	8b 55 08             	mov    0x8(%ebp),%edx
f01014eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01014ee:	eb 01                	jmp    f01014f1 <strtol+0xf>
		s++;
f01014f0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01014f1:	8a 02                	mov    (%edx),%al
f01014f3:	3c 20                	cmp    $0x20,%al
f01014f5:	74 f9                	je     f01014f0 <strtol+0xe>
f01014f7:	3c 09                	cmp    $0x9,%al
f01014f9:	74 f5                	je     f01014f0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01014fb:	3c 2b                	cmp    $0x2b,%al
f01014fd:	75 08                	jne    f0101507 <strtol+0x25>
		s++;
f01014ff:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101500:	bf 00 00 00 00       	mov    $0x0,%edi
f0101505:	eb 13                	jmp    f010151a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101507:	3c 2d                	cmp    $0x2d,%al
f0101509:	75 0a                	jne    f0101515 <strtol+0x33>
		s++, neg = 1;
f010150b:	8d 52 01             	lea    0x1(%edx),%edx
f010150e:	bf 01 00 00 00       	mov    $0x1,%edi
f0101513:	eb 05                	jmp    f010151a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101515:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010151a:	85 db                	test   %ebx,%ebx
f010151c:	74 05                	je     f0101523 <strtol+0x41>
f010151e:	83 fb 10             	cmp    $0x10,%ebx
f0101521:	75 28                	jne    f010154b <strtol+0x69>
f0101523:	8a 02                	mov    (%edx),%al
f0101525:	3c 30                	cmp    $0x30,%al
f0101527:	75 10                	jne    f0101539 <strtol+0x57>
f0101529:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010152d:	75 0a                	jne    f0101539 <strtol+0x57>
		s += 2, base = 16;
f010152f:	83 c2 02             	add    $0x2,%edx
f0101532:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101537:	eb 12                	jmp    f010154b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0101539:	85 db                	test   %ebx,%ebx
f010153b:	75 0e                	jne    f010154b <strtol+0x69>
f010153d:	3c 30                	cmp    $0x30,%al
f010153f:	75 05                	jne    f0101546 <strtol+0x64>
		s++, base = 8;
f0101541:	42                   	inc    %edx
f0101542:	b3 08                	mov    $0x8,%bl
f0101544:	eb 05                	jmp    f010154b <strtol+0x69>
	else if (base == 0)
		base = 10;
f0101546:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010154b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101550:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101552:	8a 0a                	mov    (%edx),%cl
f0101554:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101557:	80 fb 09             	cmp    $0x9,%bl
f010155a:	77 08                	ja     f0101564 <strtol+0x82>
			dig = *s - '0';
f010155c:	0f be c9             	movsbl %cl,%ecx
f010155f:	83 e9 30             	sub    $0x30,%ecx
f0101562:	eb 1e                	jmp    f0101582 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0101564:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0101567:	80 fb 19             	cmp    $0x19,%bl
f010156a:	77 08                	ja     f0101574 <strtol+0x92>
			dig = *s - 'a' + 10;
f010156c:	0f be c9             	movsbl %cl,%ecx
f010156f:	83 e9 57             	sub    $0x57,%ecx
f0101572:	eb 0e                	jmp    f0101582 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0101574:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0101577:	80 fb 19             	cmp    $0x19,%bl
f010157a:	77 13                	ja     f010158f <strtol+0xad>
			dig = *s - 'A' + 10;
f010157c:	0f be c9             	movsbl %cl,%ecx
f010157f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101582:	39 f1                	cmp    %esi,%ecx
f0101584:	7d 0d                	jge    f0101593 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f0101586:	42                   	inc    %edx
f0101587:	0f af c6             	imul   %esi,%eax
f010158a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f010158d:	eb c3                	jmp    f0101552 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010158f:	89 c1                	mov    %eax,%ecx
f0101591:	eb 02                	jmp    f0101595 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101593:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0101595:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101599:	74 05                	je     f01015a0 <strtol+0xbe>
		*endptr = (char *) s;
f010159b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010159e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01015a0:	85 ff                	test   %edi,%edi
f01015a2:	74 04                	je     f01015a8 <strtol+0xc6>
f01015a4:	89 c8                	mov    %ecx,%eax
f01015a6:	f7 d8                	neg    %eax
}
f01015a8:	5b                   	pop    %ebx
f01015a9:	5e                   	pop    %esi
f01015aa:	5f                   	pop    %edi
f01015ab:	c9                   	leave  
f01015ac:	c3                   	ret    
f01015ad:	00 00                	add    %al,(%eax)
	...

f01015b0 <__udivdi3>:
f01015b0:	55                   	push   %ebp
f01015b1:	89 e5                	mov    %esp,%ebp
f01015b3:	57                   	push   %edi
f01015b4:	56                   	push   %esi
f01015b5:	83 ec 10             	sub    $0x10,%esp
f01015b8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01015bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01015be:	89 7d f0             	mov    %edi,-0x10(%ebp)
f01015c1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015c4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01015c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01015ca:	85 c0                	test   %eax,%eax
f01015cc:	75 2e                	jne    f01015fc <__udivdi3+0x4c>
f01015ce:	39 f1                	cmp    %esi,%ecx
f01015d0:	77 5a                	ja     f010162c <__udivdi3+0x7c>
f01015d2:	85 c9                	test   %ecx,%ecx
f01015d4:	75 0b                	jne    f01015e1 <__udivdi3+0x31>
f01015d6:	b8 01 00 00 00       	mov    $0x1,%eax
f01015db:	31 d2                	xor    %edx,%edx
f01015dd:	f7 f1                	div    %ecx
f01015df:	89 c1                	mov    %eax,%ecx
f01015e1:	31 d2                	xor    %edx,%edx
f01015e3:	89 f0                	mov    %esi,%eax
f01015e5:	f7 f1                	div    %ecx
f01015e7:	89 c6                	mov    %eax,%esi
f01015e9:	89 f8                	mov    %edi,%eax
f01015eb:	f7 f1                	div    %ecx
f01015ed:	89 c7                	mov    %eax,%edi
f01015ef:	89 f8                	mov    %edi,%eax
f01015f1:	89 f2                	mov    %esi,%edx
f01015f3:	83 c4 10             	add    $0x10,%esp
f01015f6:	5e                   	pop    %esi
f01015f7:	5f                   	pop    %edi
f01015f8:	c9                   	leave  
f01015f9:	c3                   	ret    
f01015fa:	66 90                	xchg   %ax,%ax
f01015fc:	39 f0                	cmp    %esi,%eax
f01015fe:	77 1c                	ja     f010161c <__udivdi3+0x6c>
f0101600:	0f bd f8             	bsr    %eax,%edi
f0101603:	83 f7 1f             	xor    $0x1f,%edi
f0101606:	75 3c                	jne    f0101644 <__udivdi3+0x94>
f0101608:	39 f0                	cmp    %esi,%eax
f010160a:	0f 82 90 00 00 00    	jb     f01016a0 <__udivdi3+0xf0>
f0101610:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101613:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f0101616:	0f 86 84 00 00 00    	jbe    f01016a0 <__udivdi3+0xf0>
f010161c:	31 f6                	xor    %esi,%esi
f010161e:	31 ff                	xor    %edi,%edi
f0101620:	89 f8                	mov    %edi,%eax
f0101622:	89 f2                	mov    %esi,%edx
f0101624:	83 c4 10             	add    $0x10,%esp
f0101627:	5e                   	pop    %esi
f0101628:	5f                   	pop    %edi
f0101629:	c9                   	leave  
f010162a:	c3                   	ret    
f010162b:	90                   	nop
f010162c:	89 f2                	mov    %esi,%edx
f010162e:	89 f8                	mov    %edi,%eax
f0101630:	f7 f1                	div    %ecx
f0101632:	89 c7                	mov    %eax,%edi
f0101634:	31 f6                	xor    %esi,%esi
f0101636:	89 f8                	mov    %edi,%eax
f0101638:	89 f2                	mov    %esi,%edx
f010163a:	83 c4 10             	add    $0x10,%esp
f010163d:	5e                   	pop    %esi
f010163e:	5f                   	pop    %edi
f010163f:	c9                   	leave  
f0101640:	c3                   	ret    
f0101641:	8d 76 00             	lea    0x0(%esi),%esi
f0101644:	89 f9                	mov    %edi,%ecx
f0101646:	d3 e0                	shl    %cl,%eax
f0101648:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010164b:	b8 20 00 00 00       	mov    $0x20,%eax
f0101650:	29 f8                	sub    %edi,%eax
f0101652:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101655:	88 c1                	mov    %al,%cl
f0101657:	d3 ea                	shr    %cl,%edx
f0101659:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010165c:	09 ca                	or     %ecx,%edx
f010165e:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101661:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101664:	89 f9                	mov    %edi,%ecx
f0101666:	d3 e2                	shl    %cl,%edx
f0101668:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010166b:	89 f2                	mov    %esi,%edx
f010166d:	88 c1                	mov    %al,%cl
f010166f:	d3 ea                	shr    %cl,%edx
f0101671:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0101674:	89 f2                	mov    %esi,%edx
f0101676:	89 f9                	mov    %edi,%ecx
f0101678:	d3 e2                	shl    %cl,%edx
f010167a:	8b 75 f0             	mov    -0x10(%ebp),%esi
f010167d:	88 c1                	mov    %al,%cl
f010167f:	d3 ee                	shr    %cl,%esi
f0101681:	09 d6                	or     %edx,%esi
f0101683:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101686:	89 f0                	mov    %esi,%eax
f0101688:	89 ca                	mov    %ecx,%edx
f010168a:	f7 75 ec             	divl   -0x14(%ebp)
f010168d:	89 d1                	mov    %edx,%ecx
f010168f:	89 c6                	mov    %eax,%esi
f0101691:	f7 65 f4             	mull   -0xc(%ebp)
f0101694:	39 d1                	cmp    %edx,%ecx
f0101696:	72 28                	jb     f01016c0 <__udivdi3+0x110>
f0101698:	74 1a                	je     f01016b4 <__udivdi3+0x104>
f010169a:	89 f7                	mov    %esi,%edi
f010169c:	31 f6                	xor    %esi,%esi
f010169e:	eb 80                	jmp    f0101620 <__udivdi3+0x70>
f01016a0:	31 f6                	xor    %esi,%esi
f01016a2:	bf 01 00 00 00       	mov    $0x1,%edi
f01016a7:	89 f8                	mov    %edi,%eax
f01016a9:	89 f2                	mov    %esi,%edx
f01016ab:	83 c4 10             	add    $0x10,%esp
f01016ae:	5e                   	pop    %esi
f01016af:	5f                   	pop    %edi
f01016b0:	c9                   	leave  
f01016b1:	c3                   	ret    
f01016b2:	66 90                	xchg   %ax,%ax
f01016b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01016b7:	89 f9                	mov    %edi,%ecx
f01016b9:	d3 e2                	shl    %cl,%edx
f01016bb:	39 c2                	cmp    %eax,%edx
f01016bd:	73 db                	jae    f010169a <__udivdi3+0xea>
f01016bf:	90                   	nop
f01016c0:	8d 7e ff             	lea    -0x1(%esi),%edi
f01016c3:	31 f6                	xor    %esi,%esi
f01016c5:	e9 56 ff ff ff       	jmp    f0101620 <__udivdi3+0x70>
	...

f01016cc <__umoddi3>:
f01016cc:	55                   	push   %ebp
f01016cd:	89 e5                	mov    %esp,%ebp
f01016cf:	57                   	push   %edi
f01016d0:	56                   	push   %esi
f01016d1:	83 ec 20             	sub    $0x20,%esp
f01016d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01016d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01016da:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01016dd:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016e0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01016e3:	8b 7d 14             	mov    0x14(%ebp),%edi
f01016e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01016e9:	89 f2                	mov    %esi,%edx
f01016eb:	85 ff                	test   %edi,%edi
f01016ed:	75 15                	jne    f0101704 <__umoddi3+0x38>
f01016ef:	39 f1                	cmp    %esi,%ecx
f01016f1:	0f 86 99 00 00 00    	jbe    f0101790 <__umoddi3+0xc4>
f01016f7:	f7 f1                	div    %ecx
f01016f9:	89 d0                	mov    %edx,%eax
f01016fb:	31 d2                	xor    %edx,%edx
f01016fd:	83 c4 20             	add    $0x20,%esp
f0101700:	5e                   	pop    %esi
f0101701:	5f                   	pop    %edi
f0101702:	c9                   	leave  
f0101703:	c3                   	ret    
f0101704:	39 f7                	cmp    %esi,%edi
f0101706:	0f 87 a4 00 00 00    	ja     f01017b0 <__umoddi3+0xe4>
f010170c:	0f bd c7             	bsr    %edi,%eax
f010170f:	83 f0 1f             	xor    $0x1f,%eax
f0101712:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101715:	0f 84 a1 00 00 00    	je     f01017bc <__umoddi3+0xf0>
f010171b:	89 f8                	mov    %edi,%eax
f010171d:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0101720:	d3 e0                	shl    %cl,%eax
f0101722:	bf 20 00 00 00       	mov    $0x20,%edi
f0101727:	2b 7d ec             	sub    -0x14(%ebp),%edi
f010172a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010172d:	89 f9                	mov    %edi,%ecx
f010172f:	d3 ea                	shr    %cl,%edx
f0101731:	09 c2                	or     %eax,%edx
f0101733:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0101736:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101739:	8a 4d ec             	mov    -0x14(%ebp),%cl
f010173c:	d3 e0                	shl    %cl,%eax
f010173e:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101741:	89 f2                	mov    %esi,%edx
f0101743:	d3 e2                	shl    %cl,%edx
f0101745:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101748:	d3 e0                	shl    %cl,%eax
f010174a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010174d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101750:	89 f9                	mov    %edi,%ecx
f0101752:	d3 e8                	shr    %cl,%eax
f0101754:	09 d0                	or     %edx,%eax
f0101756:	d3 ee                	shr    %cl,%esi
f0101758:	89 f2                	mov    %esi,%edx
f010175a:	f7 75 f0             	divl   -0x10(%ebp)
f010175d:	89 d6                	mov    %edx,%esi
f010175f:	f7 65 f4             	mull   -0xc(%ebp)
f0101762:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0101765:	89 c1                	mov    %eax,%ecx
f0101767:	39 d6                	cmp    %edx,%esi
f0101769:	72 71                	jb     f01017dc <__umoddi3+0x110>
f010176b:	74 7f                	je     f01017ec <__umoddi3+0x120>
f010176d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101770:	29 c8                	sub    %ecx,%eax
f0101772:	19 d6                	sbb    %edx,%esi
f0101774:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0101777:	d3 e8                	shr    %cl,%eax
f0101779:	89 f2                	mov    %esi,%edx
f010177b:	89 f9                	mov    %edi,%ecx
f010177d:	d3 e2                	shl    %cl,%edx
f010177f:	09 d0                	or     %edx,%eax
f0101781:	89 f2                	mov    %esi,%edx
f0101783:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0101786:	d3 ea                	shr    %cl,%edx
f0101788:	83 c4 20             	add    $0x20,%esp
f010178b:	5e                   	pop    %esi
f010178c:	5f                   	pop    %edi
f010178d:	c9                   	leave  
f010178e:	c3                   	ret    
f010178f:	90                   	nop
f0101790:	85 c9                	test   %ecx,%ecx
f0101792:	75 0b                	jne    f010179f <__umoddi3+0xd3>
f0101794:	b8 01 00 00 00       	mov    $0x1,%eax
f0101799:	31 d2                	xor    %edx,%edx
f010179b:	f7 f1                	div    %ecx
f010179d:	89 c1                	mov    %eax,%ecx
f010179f:	89 f0                	mov    %esi,%eax
f01017a1:	31 d2                	xor    %edx,%edx
f01017a3:	f7 f1                	div    %ecx
f01017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01017a8:	f7 f1                	div    %ecx
f01017aa:	e9 4a ff ff ff       	jmp    f01016f9 <__umoddi3+0x2d>
f01017af:	90                   	nop
f01017b0:	89 f2                	mov    %esi,%edx
f01017b2:	83 c4 20             	add    $0x20,%esp
f01017b5:	5e                   	pop    %esi
f01017b6:	5f                   	pop    %edi
f01017b7:	c9                   	leave  
f01017b8:	c3                   	ret    
f01017b9:	8d 76 00             	lea    0x0(%esi),%esi
f01017bc:	39 f7                	cmp    %esi,%edi
f01017be:	72 05                	jb     f01017c5 <__umoddi3+0xf9>
f01017c0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f01017c3:	77 0c                	ja     f01017d1 <__umoddi3+0x105>
f01017c5:	89 f2                	mov    %esi,%edx
f01017c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01017ca:	29 c8                	sub    %ecx,%eax
f01017cc:	19 fa                	sbb    %edi,%edx
f01017ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01017d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01017d4:	83 c4 20             	add    $0x20,%esp
f01017d7:	5e                   	pop    %esi
f01017d8:	5f                   	pop    %edi
f01017d9:	c9                   	leave  
f01017da:	c3                   	ret    
f01017db:	90                   	nop
f01017dc:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01017df:	89 c1                	mov    %eax,%ecx
f01017e1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f01017e4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f01017e7:	eb 84                	jmp    f010176d <__umoddi3+0xa1>
f01017e9:	8d 76 00             	lea    0x0(%esi),%esi
f01017ec:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f01017ef:	72 eb                	jb     f01017dc <__umoddi3+0x110>
f01017f1:	89 f2                	mov    %esi,%edx
f01017f3:	e9 75 ff ff ff       	jmp    f010176d <__umoddi3+0xa1>
