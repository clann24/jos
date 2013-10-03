
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
f0100015:	b8 00 a0 11 00       	mov    $0x11a000,%eax
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
f0100034:	bc 00 a0 11 f0       	mov    $0xf011a000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5f 00 00 00       	call   f010009d <i386_init>

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
f010004e:	c7 04 24 40 4f 10 f0 	movl   $0xf0104f40,(%esp)
f0100055:	e8 90 39 00 00       	call   f01039ea <cprintf>
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
f0100082:	e8 39 06 00 00       	call   f01006c0 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 5c 4f 10 f0 	movl   $0xf0104f5c,(%esp)
f0100092:	e8 53 39 00 00       	call   f01039ea <cprintf>
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
f01000a3:	b8 74 fe 17 f0       	mov    $0xf017fe74,%eax
f01000a8:	2d 4a ef 17 f0       	sub    $0xf017ef4a,%eax
f01000ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000b8:	00 
f01000b9:	c7 04 24 4a ef 17 f0 	movl   $0xf017ef4a,(%esp)
f01000c0:	e8 ac 49 00 00       	call   f0104a71 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 d2 04 00 00       	call   f010059c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 77 4f 10 f0 	movl   $0xf0104f77,(%esp)
f01000d9:	e8 0c 39 00 00       	call   f01039ea <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000de:	e8 5a 14 00 00       	call   f010153d <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000e3:	e8 d7 32 00 00       	call   f01033bf <env_init>
	trap_init();
f01000e8:	e8 74 39 00 00       	call   f0103a61 <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f01000ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01000f4:	00 
f01000f5:	c7 44 24 04 45 78 00 	movl   $0x7845,0x4(%esp)
f01000fc:	00 
f01000fd:	c7 04 24 44 d3 11 f0 	movl   $0xf011d344,(%esp)
f0100104:	e8 83 34 00 00       	call   f010358c <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100109:	a1 98 f1 17 f0       	mov    0xf017f198,%eax
f010010e:	89 04 24             	mov    %eax,(%esp)
f0100111:	e8 0e 38 00 00       	call   f0103924 <env_run>

f0100116 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100116:	55                   	push   %ebp
f0100117:	89 e5                	mov    %esp,%ebp
f0100119:	56                   	push   %esi
f010011a:	53                   	push   %ebx
f010011b:	83 ec 10             	sub    $0x10,%esp
f010011e:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100121:	83 3d 60 fe 17 f0 00 	cmpl   $0x0,0xf017fe60
f0100128:	75 3d                	jne    f0100167 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f010012a:	89 35 60 fe 17 f0    	mov    %esi,0xf017fe60

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100130:	fa                   	cli    
f0100131:	fc                   	cld    

	va_start(ap, fmt);
f0100132:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100135:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100138:	89 44 24 08          	mov    %eax,0x8(%esp)
f010013c:	8b 45 08             	mov    0x8(%ebp),%eax
f010013f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100143:	c7 04 24 92 4f 10 f0 	movl   $0xf0104f92,(%esp)
f010014a:	e8 9b 38 00 00       	call   f01039ea <cprintf>
	vcprintf(fmt, ap);
f010014f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100153:	89 34 24             	mov    %esi,(%esp)
f0100156:	e8 5c 38 00 00       	call   f01039b7 <vcprintf>
	cprintf("\n");
f010015b:	c7 04 24 2e 59 10 f0 	movl   $0xf010592e,(%esp)
f0100162:	e8 83 38 00 00       	call   f01039ea <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100167:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010016e:	e8 80 07 00 00       	call   f01008f3 <monitor>
f0100173:	eb f2                	jmp    f0100167 <_panic+0x51>

f0100175 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100175:	55                   	push   %ebp
f0100176:	89 e5                	mov    %esp,%ebp
f0100178:	53                   	push   %ebx
f0100179:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010017c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010017f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100182:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100186:	8b 45 08             	mov    0x8(%ebp),%eax
f0100189:	89 44 24 04          	mov    %eax,0x4(%esp)
f010018d:	c7 04 24 aa 4f 10 f0 	movl   $0xf0104faa,(%esp)
f0100194:	e8 51 38 00 00       	call   f01039ea <cprintf>
	vcprintf(fmt, ap);
f0100199:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010019d:	8b 45 10             	mov    0x10(%ebp),%eax
f01001a0:	89 04 24             	mov    %eax,(%esp)
f01001a3:	e8 0f 38 00 00       	call   f01039b7 <vcprintf>
	cprintf("\n");
f01001a8:	c7 04 24 2e 59 10 f0 	movl   $0xf010592e,(%esp)
f01001af:	e8 36 38 00 00       	call   f01039ea <cprintf>
	va_end(ap);
}
f01001b4:	83 c4 14             	add    $0x14,%esp
f01001b7:	5b                   	pop    %ebx
f01001b8:	5d                   	pop    %ebp
f01001b9:	c3                   	ret    
f01001ba:	00 00                	add    %al,(%eax)
f01001bc:	00 00                	add    %al,(%eax)
	...

f01001c0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba 84 00 00 00       	mov    $0x84,%edx
f01001c8:	ec                   	in     (%dx),%al
f01001c9:	ec                   	in     (%dx),%al
f01001ca:	ec                   	in     (%dx),%al
f01001cb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01001cc:	5d                   	pop    %ebp
f01001cd:	c3                   	ret    

f01001ce <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001ce:	55                   	push   %ebp
f01001cf:	89 e5                	mov    %esp,%ebp
f01001d1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001d6:	ec                   	in     (%dx),%al
f01001d7:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001de:	f6 c2 01             	test   $0x1,%dl
f01001e1:	74 09                	je     f01001ec <serial_proc_data+0x1e>
f01001e3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001e8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001e9:	0f b6 c0             	movzbl %al,%eax
}
f01001ec:	5d                   	pop    %ebp
f01001ed:	c3                   	ret    

f01001ee <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ee:	55                   	push   %ebp
f01001ef:	89 e5                	mov    %esp,%ebp
f01001f1:	53                   	push   %ebx
f01001f2:	83 ec 04             	sub    $0x4,%esp
f01001f5:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001f7:	eb 25                	jmp    f010021e <cons_intr+0x30>
		if (c == 0)
f01001f9:	85 c0                	test   %eax,%eax
f01001fb:	74 21                	je     f010021e <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fd:	8b 15 84 f1 17 f0    	mov    0xf017f184,%edx
f0100203:	88 82 80 ef 17 f0    	mov    %al,-0xfe81080(%edx)
f0100209:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f010020c:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100211:	ba 00 00 00 00       	mov    $0x0,%edx
f0100216:	0f 44 c2             	cmove  %edx,%eax
f0100219:	a3 84 f1 17 f0       	mov    %eax,0xf017f184
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010021e:	ff d3                	call   *%ebx
f0100220:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100223:	75 d4                	jne    f01001f9 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100225:	83 c4 04             	add    $0x4,%esp
f0100228:	5b                   	pop    %ebx
f0100229:	5d                   	pop    %ebp
f010022a:	c3                   	ret    

f010022b <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010022b:	55                   	push   %ebp
f010022c:	89 e5                	mov    %esp,%ebp
f010022e:	57                   	push   %edi
f010022f:	56                   	push   %esi
f0100230:	53                   	push   %ebx
f0100231:	83 ec 2c             	sub    $0x2c,%esp
f0100234:	89 c7                	mov    %eax,%edi
f0100236:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010023b:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010023c:	a8 20                	test   $0x20,%al
f010023e:	75 1b                	jne    f010025b <cons_putc+0x30>
f0100240:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100245:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010024a:	e8 71 ff ff ff       	call   f01001c0 <delay>
f010024f:	89 f2                	mov    %esi,%edx
f0100251:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100252:	a8 20                	test   $0x20,%al
f0100254:	75 05                	jne    f010025b <cons_putc+0x30>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100256:	83 eb 01             	sub    $0x1,%ebx
f0100259:	75 ef                	jne    f010024a <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010025b:	89 fa                	mov    %edi,%edx
f010025d:	89 f8                	mov    %edi,%eax
f010025f:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100262:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100267:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100268:	b2 79                	mov    $0x79,%dl
f010026a:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010026b:	84 c0                	test   %al,%al
f010026d:	78 21                	js     f0100290 <cons_putc+0x65>
f010026f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100274:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100279:	e8 42 ff ff ff       	call   f01001c0 <delay>
f010027e:	89 f2                	mov    %esi,%edx
f0100280:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100281:	84 c0                	test   %al,%al
f0100283:	78 0b                	js     f0100290 <cons_putc+0x65>
f0100285:	83 c3 01             	add    $0x1,%ebx
f0100288:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f010028e:	75 e9                	jne    f0100279 <cons_putc+0x4e>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100290:	ba 78 03 00 00       	mov    $0x378,%edx
f0100295:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100299:	ee                   	out    %al,(%dx)
f010029a:	b2 7a                	mov    $0x7a,%dl
f010029c:	b8 0d 00 00 00       	mov    $0xd,%eax
f01002a1:	ee                   	out    %al,(%dx)
f01002a2:	b8 08 00 00 00       	mov    $0x8,%eax
f01002a7:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!csa) csa = 0x0700;
f01002a8:	83 3d 64 fe 17 f0 00 	cmpl   $0x0,0xf017fe64
f01002af:	75 0a                	jne    f01002bb <cons_putc+0x90>
f01002b1:	c7 05 64 fe 17 f0 00 	movl   $0x700,0xf017fe64
f01002b8:	07 00 00 
	if (!(c & ~0xFF))
f01002bb:	89 fa                	mov    %edi,%edx
f01002bd:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= csa;
f01002c3:	89 f8                	mov    %edi,%eax
f01002c5:	0b 05 64 fe 17 f0    	or     0xf017fe64,%eax
f01002cb:	85 d2                	test   %edx,%edx
f01002cd:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01002d0:	89 f8                	mov    %edi,%eax
f01002d2:	25 ff 00 00 00       	and    $0xff,%eax
f01002d7:	83 f8 09             	cmp    $0x9,%eax
f01002da:	74 7c                	je     f0100358 <cons_putc+0x12d>
f01002dc:	83 f8 09             	cmp    $0x9,%eax
f01002df:	7f 0b                	jg     f01002ec <cons_putc+0xc1>
f01002e1:	83 f8 08             	cmp    $0x8,%eax
f01002e4:	0f 85 a2 00 00 00    	jne    f010038c <cons_putc+0x161>
f01002ea:	eb 16                	jmp    f0100302 <cons_putc+0xd7>
f01002ec:	83 f8 0a             	cmp    $0xa,%eax
f01002ef:	90                   	nop
f01002f0:	74 40                	je     f0100332 <cons_putc+0x107>
f01002f2:	83 f8 0d             	cmp    $0xd,%eax
f01002f5:	0f 85 91 00 00 00    	jne    f010038c <cons_putc+0x161>
f01002fb:	90                   	nop
f01002fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100300:	eb 38                	jmp    f010033a <cons_putc+0x10f>
	case '\b':
		if (crt_pos > 0) {
f0100302:	0f b7 05 60 ef 17 f0 	movzwl 0xf017ef60,%eax
f0100309:	66 85 c0             	test   %ax,%ax
f010030c:	0f 84 e4 00 00 00    	je     f01003f6 <cons_putc+0x1cb>
			crt_pos--;
f0100312:	83 e8 01             	sub    $0x1,%eax
f0100315:	66 a3 60 ef 17 f0    	mov    %ax,0xf017ef60
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010031b:	0f b7 c0             	movzwl %ax,%eax
f010031e:	66 81 e7 00 ff       	and    $0xff00,%di
f0100323:	83 cf 20             	or     $0x20,%edi
f0100326:	8b 15 64 ef 17 f0    	mov    0xf017ef64,%edx
f010032c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100330:	eb 77                	jmp    f01003a9 <cons_putc+0x17e>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100332:	66 83 05 60 ef 17 f0 	addw   $0x50,0xf017ef60
f0100339:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010033a:	0f b7 05 60 ef 17 f0 	movzwl 0xf017ef60,%eax
f0100341:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100347:	c1 e8 16             	shr    $0x16,%eax
f010034a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010034d:	c1 e0 04             	shl    $0x4,%eax
f0100350:	66 a3 60 ef 17 f0    	mov    %ax,0xf017ef60
f0100356:	eb 51                	jmp    f01003a9 <cons_putc+0x17e>
		break;
	case '\t':
		cons_putc(' ');
f0100358:	b8 20 00 00 00       	mov    $0x20,%eax
f010035d:	e8 c9 fe ff ff       	call   f010022b <cons_putc>
		cons_putc(' ');
f0100362:	b8 20 00 00 00       	mov    $0x20,%eax
f0100367:	e8 bf fe ff ff       	call   f010022b <cons_putc>
		cons_putc(' ');
f010036c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100371:	e8 b5 fe ff ff       	call   f010022b <cons_putc>
		cons_putc(' ');
f0100376:	b8 20 00 00 00       	mov    $0x20,%eax
f010037b:	e8 ab fe ff ff       	call   f010022b <cons_putc>
		cons_putc(' ');
f0100380:	b8 20 00 00 00       	mov    $0x20,%eax
f0100385:	e8 a1 fe ff ff       	call   f010022b <cons_putc>
f010038a:	eb 1d                	jmp    f01003a9 <cons_putc+0x17e>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010038c:	0f b7 05 60 ef 17 f0 	movzwl 0xf017ef60,%eax
f0100393:	0f b7 c8             	movzwl %ax,%ecx
f0100396:	8b 15 64 ef 17 f0    	mov    0xf017ef64,%edx
f010039c:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f01003a0:	83 c0 01             	add    $0x1,%eax
f01003a3:	66 a3 60 ef 17 f0    	mov    %ax,0xf017ef60
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003a9:	66 81 3d 60 ef 17 f0 	cmpw   $0x7cf,0xf017ef60
f01003b0:	cf 07 
f01003b2:	76 42                	jbe    f01003f6 <cons_putc+0x1cb>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01003b4:	a1 64 ef 17 f0       	mov    0xf017ef64,%eax
f01003b9:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01003c0:	00 
f01003c1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01003c7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01003cb:	89 04 24             	mov    %eax,(%esp)
f01003ce:	e8 fd 46 00 00       	call   f0104ad0 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01003d3:	8b 15 64 ef 17 f0    	mov    0xf017ef64,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01003d9:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01003de:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01003e4:	83 c0 01             	add    $0x1,%eax
f01003e7:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01003ec:	75 f0                	jne    f01003de <cons_putc+0x1b3>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01003ee:	66 83 2d 60 ef 17 f0 	subw   $0x50,0xf017ef60
f01003f5:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01003f6:	8b 0d 68 ef 17 f0    	mov    0xf017ef68,%ecx
f01003fc:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100401:	89 ca                	mov    %ecx,%edx
f0100403:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100404:	0f b7 35 60 ef 17 f0 	movzwl 0xf017ef60,%esi
f010040b:	8d 59 01             	lea    0x1(%ecx),%ebx
f010040e:	89 f0                	mov    %esi,%eax
f0100410:	66 c1 e8 08          	shr    $0x8,%ax
f0100414:	89 da                	mov    %ebx,%edx
f0100416:	ee                   	out    %al,(%dx)
f0100417:	b8 0f 00 00 00       	mov    $0xf,%eax
f010041c:	89 ca                	mov    %ecx,%edx
f010041e:	ee                   	out    %al,(%dx)
f010041f:	89 f0                	mov    %esi,%eax
f0100421:	89 da                	mov    %ebx,%edx
f0100423:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100424:	83 c4 2c             	add    $0x2c,%esp
f0100427:	5b                   	pop    %ebx
f0100428:	5e                   	pop    %esi
f0100429:	5f                   	pop    %edi
f010042a:	5d                   	pop    %ebp
f010042b:	c3                   	ret    

f010042c <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010042c:	55                   	push   %ebp
f010042d:	89 e5                	mov    %esp,%ebp
f010042f:	53                   	push   %ebx
f0100430:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100433:	ba 64 00 00 00       	mov    $0x64,%edx
f0100438:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100439:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010043e:	a8 01                	test   $0x1,%al
f0100440:	0f 84 de 00 00 00    	je     f0100524 <kbd_proc_data+0xf8>
f0100446:	b2 60                	mov    $0x60,%dl
f0100448:	ec                   	in     (%dx),%al
f0100449:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010044b:	3c e0                	cmp    $0xe0,%al
f010044d:	75 11                	jne    f0100460 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f010044f:	83 0d 88 f1 17 f0 40 	orl    $0x40,0xf017f188
		return 0;
f0100456:	bb 00 00 00 00       	mov    $0x0,%ebx
f010045b:	e9 c4 00 00 00       	jmp    f0100524 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f0100460:	84 c0                	test   %al,%al
f0100462:	79 37                	jns    f010049b <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100464:	8b 0d 88 f1 17 f0    	mov    0xf017f188,%ecx
f010046a:	89 cb                	mov    %ecx,%ebx
f010046c:	83 e3 40             	and    $0x40,%ebx
f010046f:	83 e0 7f             	and    $0x7f,%eax
f0100472:	85 db                	test   %ebx,%ebx
f0100474:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100477:	0f b6 d2             	movzbl %dl,%edx
f010047a:	0f b6 82 00 50 10 f0 	movzbl -0xfefb000(%edx),%eax
f0100481:	83 c8 40             	or     $0x40,%eax
f0100484:	0f b6 c0             	movzbl %al,%eax
f0100487:	f7 d0                	not    %eax
f0100489:	21 c1                	and    %eax,%ecx
f010048b:	89 0d 88 f1 17 f0    	mov    %ecx,0xf017f188
		return 0;
f0100491:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100496:	e9 89 00 00 00       	jmp    f0100524 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f010049b:	8b 0d 88 f1 17 f0    	mov    0xf017f188,%ecx
f01004a1:	f6 c1 40             	test   $0x40,%cl
f01004a4:	74 0e                	je     f01004b4 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01004a6:	89 c2                	mov    %eax,%edx
f01004a8:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01004ab:	83 e1 bf             	and    $0xffffffbf,%ecx
f01004ae:	89 0d 88 f1 17 f0    	mov    %ecx,0xf017f188
	}

	shift |= shiftcode[data];
f01004b4:	0f b6 d2             	movzbl %dl,%edx
f01004b7:	0f b6 82 00 50 10 f0 	movzbl -0xfefb000(%edx),%eax
f01004be:	0b 05 88 f1 17 f0    	or     0xf017f188,%eax
	shift ^= togglecode[data];
f01004c4:	0f b6 8a 00 51 10 f0 	movzbl -0xfefaf00(%edx),%ecx
f01004cb:	31 c8                	xor    %ecx,%eax
f01004cd:	a3 88 f1 17 f0       	mov    %eax,0xf017f188

	c = charcode[shift & (CTL | SHIFT)][data];
f01004d2:	89 c1                	mov    %eax,%ecx
f01004d4:	83 e1 03             	and    $0x3,%ecx
f01004d7:	8b 0c 8d 00 52 10 f0 	mov    -0xfefae00(,%ecx,4),%ecx
f01004de:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01004e2:	a8 08                	test   $0x8,%al
f01004e4:	74 19                	je     f01004ff <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f01004e6:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01004e9:	83 fa 19             	cmp    $0x19,%edx
f01004ec:	77 05                	ja     f01004f3 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f01004ee:	83 eb 20             	sub    $0x20,%ebx
f01004f1:	eb 0c                	jmp    f01004ff <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f01004f3:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f01004f6:	8d 53 20             	lea    0x20(%ebx),%edx
f01004f9:	83 f9 19             	cmp    $0x19,%ecx
f01004fc:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01004ff:	f7 d0                	not    %eax
f0100501:	a8 06                	test   $0x6,%al
f0100503:	75 1f                	jne    f0100524 <kbd_proc_data+0xf8>
f0100505:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010050b:	75 17                	jne    f0100524 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f010050d:	c7 04 24 c4 4f 10 f0 	movl   $0xf0104fc4,(%esp)
f0100514:	e8 d1 34 00 00       	call   f01039ea <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100519:	ba 92 00 00 00       	mov    $0x92,%edx
f010051e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100523:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100524:	89 d8                	mov    %ebx,%eax
f0100526:	83 c4 14             	add    $0x14,%esp
f0100529:	5b                   	pop    %ebx
f010052a:	5d                   	pop    %ebp
f010052b:	c3                   	ret    

f010052c <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010052c:	55                   	push   %ebp
f010052d:	89 e5                	mov    %esp,%ebp
f010052f:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100532:	80 3d 6c ef 17 f0 00 	cmpb   $0x0,0xf017ef6c
f0100539:	74 0a                	je     f0100545 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010053b:	b8 ce 01 10 f0       	mov    $0xf01001ce,%eax
f0100540:	e8 a9 fc ff ff       	call   f01001ee <cons_intr>
}
f0100545:	c9                   	leave  
f0100546:	c3                   	ret    

f0100547 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100547:	55                   	push   %ebp
f0100548:	89 e5                	mov    %esp,%ebp
f010054a:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010054d:	b8 2c 04 10 f0       	mov    $0xf010042c,%eax
f0100552:	e8 97 fc ff ff       	call   f01001ee <cons_intr>
}
f0100557:	c9                   	leave  
f0100558:	c3                   	ret    

f0100559 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100559:	55                   	push   %ebp
f010055a:	89 e5                	mov    %esp,%ebp
f010055c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010055f:	e8 c8 ff ff ff       	call   f010052c <serial_intr>
	kbd_intr();
f0100564:	e8 de ff ff ff       	call   f0100547 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100569:	8b 15 80 f1 17 f0    	mov    0xf017f180,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f010056f:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100574:	3b 15 84 f1 17 f0    	cmp    0xf017f184,%edx
f010057a:	74 1e                	je     f010059a <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010057c:	0f b6 82 80 ef 17 f0 	movzbl -0xfe81080(%edx),%eax
f0100583:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100586:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010058c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100591:	0f 44 d1             	cmove  %ecx,%edx
f0100594:	89 15 80 f1 17 f0    	mov    %edx,0xf017f180
		return c;
	}
	return 0;
}
f010059a:	c9                   	leave  
f010059b:	c3                   	ret    

f010059c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010059c:	55                   	push   %ebp
f010059d:	89 e5                	mov    %esp,%ebp
f010059f:	57                   	push   %edi
f01005a0:	56                   	push   %esi
f01005a1:	53                   	push   %ebx
f01005a2:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01005a5:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005ac:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005b3:	5a a5 
	if (*cp != 0xA55A) {
f01005b5:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005bc:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005c0:	74 11                	je     f01005d3 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01005c2:	c7 05 68 ef 17 f0 b4 	movl   $0x3b4,0xf017ef68
f01005c9:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005cc:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01005d1:	eb 16                	jmp    f01005e9 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01005d3:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005da:	c7 05 68 ef 17 f0 d4 	movl   $0x3d4,0xf017ef68
f01005e1:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005e4:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005e9:	8b 0d 68 ef 17 f0    	mov    0xf017ef68,%ecx
f01005ef:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005f4:	89 ca                	mov    %ecx,%edx
f01005f6:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005f7:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005fa:	89 da                	mov    %ebx,%edx
f01005fc:	ec                   	in     (%dx),%al
f01005fd:	0f b6 f8             	movzbl %al,%edi
f0100600:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100603:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100608:	89 ca                	mov    %ecx,%edx
f010060a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010060b:	89 da                	mov    %ebx,%edx
f010060d:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010060e:	89 35 64 ef 17 f0    	mov    %esi,0xf017ef64

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100614:	0f b6 d8             	movzbl %al,%ebx
f0100617:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100619:	66 89 3d 60 ef 17 f0 	mov    %di,0xf017ef60
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100620:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100625:	b8 00 00 00 00       	mov    $0x0,%eax
f010062a:	89 da                	mov    %ebx,%edx
f010062c:	ee                   	out    %al,(%dx)
f010062d:	b2 fb                	mov    $0xfb,%dl
f010062f:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100634:	ee                   	out    %al,(%dx)
f0100635:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010063a:	b8 0c 00 00 00       	mov    $0xc,%eax
f010063f:	89 ca                	mov    %ecx,%edx
f0100641:	ee                   	out    %al,(%dx)
f0100642:	b2 f9                	mov    $0xf9,%dl
f0100644:	b8 00 00 00 00       	mov    $0x0,%eax
f0100649:	ee                   	out    %al,(%dx)
f010064a:	b2 fb                	mov    $0xfb,%dl
f010064c:	b8 03 00 00 00       	mov    $0x3,%eax
f0100651:	ee                   	out    %al,(%dx)
f0100652:	b2 fc                	mov    $0xfc,%dl
f0100654:	b8 00 00 00 00       	mov    $0x0,%eax
f0100659:	ee                   	out    %al,(%dx)
f010065a:	b2 f9                	mov    $0xf9,%dl
f010065c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100661:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100662:	b2 fd                	mov    $0xfd,%dl
f0100664:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100665:	3c ff                	cmp    $0xff,%al
f0100667:	0f 95 c0             	setne  %al
f010066a:	89 c6                	mov    %eax,%esi
f010066c:	a2 6c ef 17 f0       	mov    %al,0xf017ef6c
f0100671:	89 da                	mov    %ebx,%edx
f0100673:	ec                   	in     (%dx),%al
f0100674:	89 ca                	mov    %ecx,%edx
f0100676:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100677:	89 f0                	mov    %esi,%eax
f0100679:	84 c0                	test   %al,%al
f010067b:	75 0c                	jne    f0100689 <cons_init+0xed>
		cprintf("Serial port does not exist!\n");
f010067d:	c7 04 24 d0 4f 10 f0 	movl   $0xf0104fd0,(%esp)
f0100684:	e8 61 33 00 00       	call   f01039ea <cprintf>
}
f0100689:	83 c4 1c             	add    $0x1c,%esp
f010068c:	5b                   	pop    %ebx
f010068d:	5e                   	pop    %esi
f010068e:	5f                   	pop    %edi
f010068f:	5d                   	pop    %ebp
f0100690:	c3                   	ret    

f0100691 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100691:	55                   	push   %ebp
f0100692:	89 e5                	mov    %esp,%ebp
f0100694:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100697:	8b 45 08             	mov    0x8(%ebp),%eax
f010069a:	e8 8c fb ff ff       	call   f010022b <cons_putc>
}
f010069f:	c9                   	leave  
f01006a0:	c3                   	ret    

f01006a1 <getchar>:

int
getchar(void)
{
f01006a1:	55                   	push   %ebp
f01006a2:	89 e5                	mov    %esp,%ebp
f01006a4:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006a7:	e8 ad fe ff ff       	call   f0100559 <cons_getc>
f01006ac:	85 c0                	test   %eax,%eax
f01006ae:	74 f7                	je     f01006a7 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006b0:	c9                   	leave  
f01006b1:	c3                   	ret    

f01006b2 <iscons>:

int
iscons(int fdnum)
{
f01006b2:	55                   	push   %ebp
f01006b3:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006b5:	b8 01 00 00 00       	mov    $0x1,%eax
f01006ba:	5d                   	pop    %ebp
f01006bb:	c3                   	ret    
f01006bc:	00 00                	add    %al,(%eax)
	...

f01006c0 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01006c0:	55                   	push   %ebp
f01006c1:	89 e5                	mov    %esp,%ebp
f01006c3:	56                   	push   %esi
f01006c4:	53                   	push   %ebx
f01006c5:	83 ec 10             	sub    $0x10,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01006c8:	89 eb                	mov    %ebp,%ebx
	uint32_t* ebp = (uint32_t*) read_ebp();
f01006ca:	89 de                	mov    %ebx,%esi
	cprintf("Stack backtrace:\n");
f01006cc:	c7 04 24 10 52 10 f0 	movl   $0xf0105210,(%esp)
f01006d3:	e8 12 33 00 00       	call   f01039ea <cprintf>
	while (ebp) {
f01006d8:	85 db                	test   %ebx,%ebx
f01006da:	74 49                	je     f0100725 <mon_backtrace+0x65>
		cprintf("ebp %x  eip %x  args", ebp, ebp[1]);
f01006dc:	8b 46 04             	mov    0x4(%esi),%eax
f01006df:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006e3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01006e7:	c7 04 24 22 52 10 f0 	movl   $0xf0105222,(%esp)
f01006ee:	e8 f7 32 00 00       	call   f01039ea <cprintf>
		int i;
		for (i = 2; i <= 6; ++i)
f01006f3:	bb 02 00 00 00       	mov    $0x2,%ebx
			cprintf(" %08.x", ebp[i]);
f01006f8:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
f01006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006ff:	c7 04 24 37 52 10 f0 	movl   $0xf0105237,(%esp)
f0100706:	e8 df 32 00 00       	call   f01039ea <cprintf>
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
		cprintf("ebp %x  eip %x  args", ebp, ebp[1]);
		int i;
		for (i = 2; i <= 6; ++i)
f010070b:	83 c3 01             	add    $0x1,%ebx
f010070e:	83 fb 07             	cmp    $0x7,%ebx
f0100711:	75 e5                	jne    f01006f8 <mon_backtrace+0x38>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
f0100713:	c7 04 24 2e 59 10 f0 	movl   $0xf010592e,(%esp)
f010071a:	e8 cb 32 00 00       	call   f01039ea <cprintf>
		ebp = (uint32_t*) *ebp;
f010071f:	8b 36                	mov    (%esi),%esi
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f0100721:	85 f6                	test   %esi,%esi
f0100723:	75 b7                	jne    f01006dc <mon_backtrace+0x1c>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
		ebp = (uint32_t*) *ebp;
	}
	return 0;
}
f0100725:	b8 00 00 00 00       	mov    $0x0,%eax
f010072a:	83 c4 10             	add    $0x10,%esp
f010072d:	5b                   	pop    %ebx
f010072e:	5e                   	pop    %esi
f010072f:	5d                   	pop    %ebp
f0100730:	c3                   	ret    

f0100731 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100731:	55                   	push   %ebp
f0100732:	89 e5                	mov    %esp,%ebp
f0100734:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100737:	c7 04 24 3e 52 10 f0 	movl   $0xf010523e,(%esp)
f010073e:	e8 a7 32 00 00       	call   f01039ea <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100743:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010074a:	00 
f010074b:	c7 04 24 90 53 10 f0 	movl   $0xf0105390,(%esp)
f0100752:	e8 93 32 00 00       	call   f01039ea <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100757:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010075e:	00 
f010075f:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100766:	f0 
f0100767:	c7 04 24 b8 53 10 f0 	movl   $0xf01053b8,(%esp)
f010076e:	e8 77 32 00 00       	call   f01039ea <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100773:	c7 44 24 08 25 4f 10 	movl   $0x104f25,0x8(%esp)
f010077a:	00 
f010077b:	c7 44 24 04 25 4f 10 	movl   $0xf0104f25,0x4(%esp)
f0100782:	f0 
f0100783:	c7 04 24 dc 53 10 f0 	movl   $0xf01053dc,(%esp)
f010078a:	e8 5b 32 00 00       	call   f01039ea <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010078f:	c7 44 24 08 4a ef 17 	movl   $0x17ef4a,0x8(%esp)
f0100796:	00 
f0100797:	c7 44 24 04 4a ef 17 	movl   $0xf017ef4a,0x4(%esp)
f010079e:	f0 
f010079f:	c7 04 24 00 54 10 f0 	movl   $0xf0105400,(%esp)
f01007a6:	e8 3f 32 00 00       	call   f01039ea <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007ab:	c7 44 24 08 74 fe 17 	movl   $0x17fe74,0x8(%esp)
f01007b2:	00 
f01007b3:	c7 44 24 04 74 fe 17 	movl   $0xf017fe74,0x4(%esp)
f01007ba:	f0 
f01007bb:	c7 04 24 24 54 10 f0 	movl   $0xf0105424,(%esp)
f01007c2:	e8 23 32 00 00       	call   f01039ea <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01007c7:	b8 73 02 18 f0       	mov    $0xf0180273,%eax
f01007cc:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01007d1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007d6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007dc:	85 c0                	test   %eax,%eax
f01007de:	0f 48 c2             	cmovs  %edx,%eax
f01007e1:	c1 f8 0a             	sar    $0xa,%eax
f01007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007e8:	c7 04 24 48 54 10 f0 	movl   $0xf0105448,(%esp)
f01007ef:	e8 f6 31 00 00       	call   f01039ea <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01007f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f9:	c9                   	leave  
f01007fa:	c3                   	ret    

f01007fb <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007fb:	55                   	push   %ebp
f01007fc:	89 e5                	mov    %esp,%ebp
f01007fe:	53                   	push   %ebx
f01007ff:	83 ec 14             	sub    $0x14,%esp
f0100802:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100807:	8b 83 a4 55 10 f0    	mov    -0xfefaa5c(%ebx),%eax
f010080d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100811:	8b 83 a0 55 10 f0    	mov    -0xfefaa60(%ebx),%eax
f0100817:	89 44 24 04          	mov    %eax,0x4(%esp)
f010081b:	c7 04 24 57 52 10 f0 	movl   $0xf0105257,(%esp)
f0100822:	e8 c3 31 00 00       	call   f01039ea <cprintf>
f0100827:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f010082a:	83 fb 48             	cmp    $0x48,%ebx
f010082d:	75 d8                	jne    f0100807 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010082f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100834:	83 c4 14             	add    $0x14,%esp
f0100837:	5b                   	pop    %ebx
f0100838:	5d                   	pop    %ebp
f0100839:	c3                   	ret    

f010083a <csa_backtrace>:
	return 0;
}

int
csa_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010083a:	55                   	push   %ebp
f010083b:	89 e5                	mov    %esp,%ebp
f010083d:	57                   	push   %edi
f010083e:	56                   	push   %esi
f010083f:	53                   	push   %ebx
f0100840:	83 ec 4c             	sub    $0x4c,%esp
f0100843:	89 eb                	mov    %ebp,%ebx
	uint32_t* ebp = (uint32_t*) read_ebp();
f0100845:	89 de                	mov    %ebx,%esi
	cprintf("Stack backtrace:\n");
f0100847:	c7 04 24 10 52 10 f0 	movl   $0xf0105210,(%esp)
f010084e:	e8 97 31 00 00       	call   f01039ea <cprintf>
	while (ebp) {
f0100853:	85 db                	test   %ebx,%ebx
f0100855:	0f 84 8b 00 00 00    	je     f01008e6 <csa_backtrace+0xac>
		uint32_t eip = ebp[1];
f010085b:	8b 7e 04             	mov    0x4(%esi),%edi
		cprintf("ebp %x  eip %x  args", ebp, eip);
f010085e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100862:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100866:	c7 04 24 22 52 10 f0 	movl   $0xf0105222,(%esp)
f010086d:	e8 78 31 00 00       	call   f01039ea <cprintf>
		int i;
		for (i = 2; i <= 6; ++i)
f0100872:	bb 02 00 00 00       	mov    $0x2,%ebx
			cprintf(" %08.x", ebp[i]);
f0100877:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
f010087a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010087e:	c7 04 24 37 52 10 f0 	movl   $0xf0105237,(%esp)
f0100885:	e8 60 31 00 00       	call   f01039ea <cprintf>
	cprintf("Stack backtrace:\n");
	while (ebp) {
		uint32_t eip = ebp[1];
		cprintf("ebp %x  eip %x  args", ebp, eip);
		int i;
		for (i = 2; i <= 6; ++i)
f010088a:	83 c3 01             	add    $0x1,%ebx
f010088d:	83 fb 07             	cmp    $0x7,%ebx
f0100890:	75 e5                	jne    f0100877 <csa_backtrace+0x3d>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
f0100892:	c7 04 24 2e 59 10 f0 	movl   $0xf010592e,(%esp)
f0100899:	e8 4c 31 00 00       	call   f01039ea <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f010089e:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008a5:	89 3c 24             	mov    %edi,(%esp)
f01008a8:	e8 f9 36 00 00       	call   f0103fa6 <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n", 
f01008ad:	2b 7d e0             	sub    -0x20(%ebp),%edi
f01008b0:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01008b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01008b7:	89 44 24 10          	mov    %eax,0x10(%esp)
f01008bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01008be:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01008c2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01008c5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01008cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008d0:	c7 04 24 60 52 10 f0 	movl   $0xf0105260,(%esp)
f01008d7:	e8 0e 31 00 00       	call   f01039ea <cprintf>
			info.eip_file, info.eip_line,
			info.eip_fn_namelen, info.eip_fn_name,
			eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
		ebp = (uint32_t*) *ebp;
f01008dc:	8b 36                	mov    (%esi),%esi
int
csa_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f01008de:	85 f6                	test   %esi,%esi
f01008e0:	0f 85 75 ff ff ff    	jne    f010085b <csa_backtrace+0x21>
			eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
		ebp = (uint32_t*) *ebp;
	}
	return 0;
}
f01008e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01008eb:	83 c4 4c             	add    $0x4c,%esp
f01008ee:	5b                   	pop    %ebx
f01008ef:	5e                   	pop    %esi
f01008f0:	5f                   	pop    %edi
f01008f1:	5d                   	pop    %ebp
f01008f2:	c3                   	ret    

f01008f3 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008f3:	55                   	push   %ebp
f01008f4:	89 e5                	mov    %esp,%ebp
f01008f6:	57                   	push   %edi
f01008f7:	56                   	push   %esi
f01008f8:	53                   	push   %ebx
f01008f9:	83 ec 6c             	sub    $0x6c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008fc:	c7 04 24 74 54 10 f0 	movl   $0xf0105474,(%esp)
f0100903:	e8 e2 30 00 00       	call   f01039ea <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100908:	c7 04 24 98 54 10 f0 	movl   $0xf0105498,(%esp)
f010090f:	e8 d6 30 00 00       	call   f01039ea <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n", 
f0100914:	c7 44 24 18 71 52 10 	movl   $0xf0105271,0x18(%esp)
f010091b:	f0 
f010091c:	c7 44 24 14 00 04 00 	movl   $0x400,0x14(%esp)
f0100923:	00 
f0100924:	c7 44 24 10 75 52 10 	movl   $0xf0105275,0x10(%esp)
f010092b:	f0 
f010092c:	c7 44 24 0c 00 02 00 	movl   $0x200,0xc(%esp)
f0100933:	00 
f0100934:	c7 44 24 08 7b 52 10 	movl   $0xf010527b,0x8(%esp)
f010093b:	f0 
f010093c:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
f0100943:	00 
f0100944:	c7 04 24 80 52 10 f0 	movl   $0xf0105280,(%esp)
f010094b:	e8 9a 30 00 00       	call   f01039ea <cprintf>
		0x0100, "blue", 0x0200, "green", 0x0400, "red");

	if (tf != NULL)
f0100950:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100954:	74 0b                	je     f0100961 <monitor+0x6e>
		print_trapframe(tf);
f0100956:	8b 45 08             	mov    0x8(%ebp),%eax
f0100959:	89 04 24             	mov    %eax,(%esp)
f010095c:	e8 f3 31 00 00       	call   f0103b54 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100961:	c7 04 24 90 52 10 f0 	movl   $0xf0105290,(%esp)
f0100968:	e8 63 3e 00 00       	call   f01047d0 <readline>
f010096d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010096f:	85 c0                	test   %eax,%eax
f0100971:	74 ee                	je     f0100961 <monitor+0x6e>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100973:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010097a:	be 00 00 00 00       	mov    $0x0,%esi
f010097f:	eb 06                	jmp    f0100987 <monitor+0x94>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100981:	c6 03 00             	movb   $0x0,(%ebx)
f0100984:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100987:	0f b6 03             	movzbl (%ebx),%eax
f010098a:	84 c0                	test   %al,%al
f010098c:	74 6d                	je     f01009fb <monitor+0x108>
f010098e:	0f be c0             	movsbl %al,%eax
f0100991:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100995:	c7 04 24 94 52 10 f0 	movl   $0xf0105294,(%esp)
f010099c:	e8 71 40 00 00       	call   f0104a12 <strchr>
f01009a1:	85 c0                	test   %eax,%eax
f01009a3:	75 dc                	jne    f0100981 <monitor+0x8e>
			*buf++ = 0;
		if (*buf == 0)
f01009a5:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009a8:	74 51                	je     f01009fb <monitor+0x108>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009aa:	83 fe 0f             	cmp    $0xf,%esi
f01009ad:	8d 76 00             	lea    0x0(%esi),%esi
f01009b0:	75 16                	jne    f01009c8 <monitor+0xd5>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009b2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01009b9:	00 
f01009ba:	c7 04 24 99 52 10 f0 	movl   $0xf0105299,(%esp)
f01009c1:	e8 24 30 00 00       	call   f01039ea <cprintf>
f01009c6:	eb 99                	jmp    f0100961 <monitor+0x6e>
			return 0;
		}
		argv[argc++] = buf;
f01009c8:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009cc:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009cf:	0f b6 03             	movzbl (%ebx),%eax
f01009d2:	84 c0                	test   %al,%al
f01009d4:	75 0c                	jne    f01009e2 <monitor+0xef>
f01009d6:	eb af                	jmp    f0100987 <monitor+0x94>
			buf++;
f01009d8:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009db:	0f b6 03             	movzbl (%ebx),%eax
f01009de:	84 c0                	test   %al,%al
f01009e0:	74 a5                	je     f0100987 <monitor+0x94>
f01009e2:	0f be c0             	movsbl %al,%eax
f01009e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009e9:	c7 04 24 94 52 10 f0 	movl   $0xf0105294,(%esp)
f01009f0:	e8 1d 40 00 00       	call   f0104a12 <strchr>
f01009f5:	85 c0                	test   %eax,%eax
f01009f7:	74 df                	je     f01009d8 <monitor+0xe5>
f01009f9:	eb 8c                	jmp    f0100987 <monitor+0x94>
			buf++;
	}
	argv[argc] = 0;
f01009fb:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a02:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a03:	85 f6                	test   %esi,%esi
f0100a05:	0f 84 56 ff ff ff    	je     f0100961 <monitor+0x6e>
f0100a0b:	bb a0 55 10 f0       	mov    $0xf01055a0,%ebx
f0100a10:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a15:	8b 03                	mov    (%ebx),%eax
f0100a17:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a1b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a1e:	89 04 24             	mov    %eax,(%esp)
f0100a21:	e8 72 3f 00 00       	call   f0104998 <strcmp>
f0100a26:	85 c0                	test   %eax,%eax
f0100a28:	75 23                	jne    f0100a4d <monitor+0x15a>
			return commands[i].func(argc, argv, tf);
f0100a2a:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100a2d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a30:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a34:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100a37:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a3b:	89 34 24             	mov    %esi,(%esp)
f0100a3e:	ff 97 a8 55 10 f0    	call   *-0xfefaa58(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a44:	85 c0                	test   %eax,%eax
f0100a46:	78 28                	js     f0100a70 <monitor+0x17d>
f0100a48:	e9 14 ff ff ff       	jmp    f0100961 <monitor+0x6e>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a4d:	83 c7 01             	add    $0x1,%edi
f0100a50:	83 c3 0c             	add    $0xc,%ebx
f0100a53:	83 ff 06             	cmp    $0x6,%edi
f0100a56:	75 bd                	jne    f0100a15 <monitor+0x122>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a58:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a5f:	c7 04 24 b6 52 10 f0 	movl   $0xf01052b6,(%esp)
f0100a66:	e8 7f 2f 00 00       	call   f01039ea <cprintf>
f0100a6b:	e9 f1 fe ff ff       	jmp    f0100961 <monitor+0x6e>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a70:	83 c4 6c             	add    $0x6c,%esp
f0100a73:	5b                   	pop    %ebx
f0100a74:	5e                   	pop    %esi
f0100a75:	5f                   	pop    %edi
f0100a76:	5d                   	pop    %ebp
f0100a77:	c3                   	ret    

f0100a78 <xtoi>:

uint32_t xtoi(char* buf) {
f0100a78:	55                   	push   %ebp
f0100a79:	89 e5                	mov    %esp,%ebp
f0100a7b:	8b 45 08             	mov    0x8(%ebp),%eax
	uint32_t res = 0;
	buf += 2; //0x...
f0100a7e:	8d 50 02             	lea    0x2(%eax),%edx
	while (*buf) { 
f0100a81:	0f b6 48 02          	movzbl 0x2(%eax),%ecx
				break;
	}
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
f0100a85:	b8 00 00 00 00       	mov    $0x0,%eax
	buf += 2; //0x...
	while (*buf) { 
f0100a8a:	84 c9                	test   %cl,%cl
f0100a8c:	74 1e                	je     f0100aac <xtoi+0x34>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
f0100a8e:	80 f9 60             	cmp    $0x60,%cl
f0100a91:	7e 05                	jle    f0100a98 <xtoi+0x20>
f0100a93:	83 e9 27             	sub    $0x27,%ecx
f0100a96:	88 0a                	mov    %cl,(%edx)
		res = res*16 + *buf - '0';
f0100a98:	c1 e0 04             	shl    $0x4,%eax
f0100a9b:	0f be 0a             	movsbl (%edx),%ecx
f0100a9e:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
		++buf;
f0100aa2:	83 c2 01             	add    $0x1,%edx
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
	buf += 2; //0x...
	while (*buf) { 
f0100aa5:	0f b6 0a             	movzbl (%edx),%ecx
f0100aa8:	84 c9                	test   %cl,%cl
f0100aaa:	75 e2                	jne    f0100a8e <xtoi+0x16>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
		res = res*16 + *buf - '0';
		++buf;
	}
	return res;
}
f0100aac:	5d                   	pop    %ebp
f0100aad:	c3                   	ret    

f0100aae <pprint>:
void pprint(pte_t *pte) {
f0100aae:	55                   	push   %ebp
f0100aaf:	89 e5                	mov    %esp,%ebp
f0100ab1:	83 ec 18             	sub    $0x18,%esp
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
f0100ab4:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ab7:	8b 00                	mov    (%eax),%eax
		++buf;
	}
	return res;
}
void pprint(pte_t *pte) {
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
f0100ab9:	89 c2                	mov    %eax,%edx
f0100abb:	83 e2 04             	and    $0x4,%edx
f0100abe:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100ac2:	89 c2                	mov    %eax,%edx
f0100ac4:	83 e2 02             	and    $0x2,%edx
f0100ac7:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100acb:	83 e0 01             	and    $0x1,%eax
f0100ace:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ad2:	c7 04 24 c0 54 10 f0 	movl   $0xf01054c0,(%esp)
f0100ad9:	e8 0c 2f 00 00       	call   f01039ea <cprintf>
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
}
f0100ade:	c9                   	leave  
f0100adf:	c3                   	ret    

f0100ae0 <setm>:
		} else cprintf("page not exist: %x\n", begin);
	}
	return 0;
}

int setm(int argc, char **argv, struct Trapframe *tf) {
f0100ae0:	55                   	push   %ebp
f0100ae1:	89 e5                	mov    %esp,%ebp
f0100ae3:	83 ec 28             	sub    $0x28,%esp
f0100ae6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100ae9:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100aec:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100aef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc == 1) {
f0100af2:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100af6:	75 11                	jne    f0100b09 <setm+0x29>
		cprintf("Usage: setm 0xaddr [0|1 :clear or set] [P|W|U]\n");
f0100af8:	c7 04 24 e4 54 10 f0 	movl   $0xf01054e4,(%esp)
f0100aff:	e8 e6 2e 00 00       	call   f01039ea <cprintf>
		return 0;
f0100b04:	e9 88 00 00 00       	jmp    f0100b91 <setm+0xb1>
	}
	uint32_t addr = xtoi(argv[1]);
f0100b09:	8b 43 04             	mov    0x4(%ebx),%eax
f0100b0c:	89 04 24             	mov    %eax,(%esp)
f0100b0f:	e8 64 ff ff ff       	call   f0100a78 <xtoi>
f0100b14:	89 c7                	mov    %eax,%edi
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
f0100b16:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100b1d:	00 
f0100b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b22:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0100b27:	89 04 24             	mov    %eax,(%esp)
f0100b2a:	e8 64 07 00 00       	call   f0101293 <pgdir_walk>
f0100b2f:	89 c6                	mov    %eax,%esi
	cprintf("%x before setm: ", addr);
f0100b31:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100b35:	c7 04 24 cc 52 10 f0 	movl   $0xf01052cc,(%esp)
f0100b3c:	e8 a9 2e 00 00       	call   f01039ea <cprintf>
	pprint(pte);
f0100b41:	89 34 24             	mov    %esi,(%esp)
f0100b44:	e8 65 ff ff ff       	call   f0100aae <pprint>
	uint32_t perm = 0;
	if (argv[3][0] == 'P') perm = PTE_P;
f0100b49:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100b4c:	0f b6 10             	movzbl (%eax),%edx
	if (argv[3][0] == 'W') perm = PTE_W;
f0100b4f:	b8 02 00 00 00       	mov    $0x2,%eax
f0100b54:	80 fa 57             	cmp    $0x57,%dl
f0100b57:	74 10                	je     f0100b69 <setm+0x89>
	if (argv[3][0] == 'U') perm = PTE_U;
f0100b59:	b0 04                	mov    $0x4,%al
f0100b5b:	80 fa 55             	cmp    $0x55,%dl
f0100b5e:	74 09                	je     f0100b69 <setm+0x89>
	}
	uint32_t addr = xtoi(argv[1]);
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
	cprintf("%x before setm: ", addr);
	pprint(pte);
	uint32_t perm = 0;
f0100b60:	80 fa 50             	cmp    $0x50,%dl
f0100b63:	0f 94 c0             	sete   %al
f0100b66:	0f b6 c0             	movzbl %al,%eax
	if (argv[3][0] == 'P') perm = PTE_P;
	if (argv[3][0] == 'W') perm = PTE_W;
	if (argv[3][0] == 'U') perm = PTE_U;
	if (argv[2][0] == '0') 	//clear
f0100b69:	8b 53 08             	mov    0x8(%ebx),%edx
f0100b6c:	80 3a 30             	cmpb   $0x30,(%edx)
f0100b6f:	75 06                	jne    f0100b77 <setm+0x97>
		*pte = *pte & ~perm;
f0100b71:	f7 d0                	not    %eax
f0100b73:	21 06                	and    %eax,(%esi)
f0100b75:	eb 02                	jmp    f0100b79 <setm+0x99>
	else 	//set
		*pte = *pte | perm;
f0100b77:	09 06                	or     %eax,(%esi)
	cprintf("%x after  setm: ", addr);
f0100b79:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100b7d:	c7 04 24 dd 52 10 f0 	movl   $0xf01052dd,(%esp)
f0100b84:	e8 61 2e 00 00       	call   f01039ea <cprintf>
	pprint(pte);
f0100b89:	89 34 24             	mov    %esi,(%esp)
f0100b8c:	e8 1d ff ff ff       	call   f0100aae <pprint>
	return 0;
}
f0100b91:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b96:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100b99:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100b9c:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100b9f:	89 ec                	mov    %ebp,%esp
f0100ba1:	5d                   	pop    %ebp
f0100ba2:	c3                   	ret    

f0100ba3 <showmappings>:
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
}
int
showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100ba3:	55                   	push   %ebp
f0100ba4:	89 e5                	mov    %esp,%ebp
f0100ba6:	57                   	push   %edi
f0100ba7:	56                   	push   %esi
f0100ba8:	53                   	push   %ebx
f0100ba9:	83 ec 1c             	sub    $0x1c,%esp
f0100bac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc == 1) {
f0100baf:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100bb3:	75 11                	jne    f0100bc6 <showmappings+0x23>
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
f0100bb5:	c7 04 24 14 55 10 f0 	movl   $0xf0105514,(%esp)
f0100bbc:	e8 29 2e 00 00       	call   f01039ea <cprintf>
		return 0;
f0100bc1:	e9 a6 00 00 00       	jmp    f0100c6c <showmappings+0xc9>
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
f0100bc6:	8b 43 04             	mov    0x4(%ebx),%eax
f0100bc9:	89 04 24             	mov    %eax,(%esp)
f0100bcc:	e8 a7 fe ff ff       	call   f0100a78 <xtoi>
f0100bd1:	89 c6                	mov    %eax,%esi
f0100bd3:	8b 43 08             	mov    0x8(%ebx),%eax
f0100bd6:	89 04 24             	mov    %eax,(%esp)
f0100bd9:	e8 9a fe ff ff       	call   f0100a78 <xtoi>
f0100bde:	89 c7                	mov    %eax,%edi
	cprintf("begin: %x, end: %x\n", begin, end);
f0100be0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100be4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100be8:	c7 04 24 ee 52 10 f0 	movl   $0xf01052ee,(%esp)
f0100bef:	e8 f6 2d 00 00       	call   f01039ea <cprintf>
	for (; begin <= end; begin += PGSIZE) {
f0100bf4:	39 fe                	cmp    %edi,%esi
f0100bf6:	77 74                	ja     f0100c6c <showmappings+0xc9>
		pte_t *pte = pgdir_walk(kern_pgdir, (void *) begin, 1);	//create
f0100bf8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100bff:	00 
f0100c00:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c04:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0100c09:	89 04 24             	mov    %eax,(%esp)
f0100c0c:	e8 82 06 00 00       	call   f0101293 <pgdir_walk>
f0100c11:	89 c3                	mov    %eax,%ebx
		if (!pte) panic("boot_map_region panic, out of memory");
f0100c13:	85 c0                	test   %eax,%eax
f0100c15:	75 1c                	jne    f0100c33 <showmappings+0x90>
f0100c17:	c7 44 24 08 44 55 10 	movl   $0xf0105544,0x8(%esp)
f0100c1e:	f0 
f0100c1f:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
f0100c26:	00 
f0100c27:	c7 04 24 02 53 10 f0 	movl   $0xf0105302,(%esp)
f0100c2e:	e8 e3 f4 ff ff       	call   f0100116 <_panic>
		if (*pte & PTE_P) {
f0100c33:	f6 00 01             	testb  $0x1,(%eax)
f0100c36:	74 1a                	je     f0100c52 <showmappings+0xaf>
			cprintf("page %x with ", begin);
f0100c38:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c3c:	c7 04 24 11 53 10 f0 	movl   $0xf0105311,(%esp)
f0100c43:	e8 a2 2d 00 00       	call   f01039ea <cprintf>
			pprint(pte);
f0100c48:	89 1c 24             	mov    %ebx,(%esp)
f0100c4b:	e8 5e fe ff ff       	call   f0100aae <pprint>
f0100c50:	eb 10                	jmp    f0100c62 <showmappings+0xbf>
		} else cprintf("page not exist: %x\n", begin);
f0100c52:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c56:	c7 04 24 1f 53 10 f0 	movl   $0xf010531f,(%esp)
f0100c5d:	e8 88 2d 00 00       	call   f01039ea <cprintf>
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
		return 0;
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
	cprintf("begin: %x, end: %x\n", begin, end);
	for (; begin <= end; begin += PGSIZE) {
f0100c62:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100c68:	39 f7                	cmp    %esi,%edi
f0100c6a:	73 8c                	jae    f0100bf8 <showmappings+0x55>
			cprintf("page %x with ", begin);
			pprint(pte);
		} else cprintf("page not exist: %x\n", begin);
	}
	return 0;
}
f0100c6c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c71:	83 c4 1c             	add    $0x1c,%esp
f0100c74:	5b                   	pop    %ebx
f0100c75:	5e                   	pop    %esi
f0100c76:	5f                   	pop    %edi
f0100c77:	5d                   	pop    %ebp
f0100c78:	c3                   	ret    
f0100c79:	00 00                	add    %al,(%eax)
	...

f0100c7c <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100c7c:	55                   	push   %ebp
f0100c7d:	89 e5                	mov    %esp,%ebp
f0100c7f:	53                   	push   %ebx
f0100c80:	83 ec 14             	sub    $0x14,%esp
f0100c83:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100c85:	83 3d 94 f1 17 f0 00 	cmpl   $0x0,0xf017f194
f0100c8c:	75 0f                	jne    f0100c9d <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100c8e:	b8 73 0e 18 f0       	mov    $0xf0180e73,%eax
f0100c93:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c98:	a3 94 f1 17 f0       	mov    %eax,0xf017f194
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
f0100c9d:	a1 94 f1 17 f0       	mov    0xf017f194,%eax
f0100ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ca6:	c7 04 24 e8 55 10 f0 	movl   $0xf01055e8,(%esp)
f0100cad:	e8 38 2d 00 00       	call   f01039ea <cprintf>
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
f0100cb2:	89 d8                	mov    %ebx,%eax
f0100cb4:	03 05 94 f1 17 f0    	add    0xf017f194,%eax
f0100cba:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100cbf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100cc4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cc8:	c7 04 24 01 56 10 f0 	movl   $0xf0105601,(%esp)
f0100ccf:	e8 16 2d 00 00       	call   f01039ea <cprintf>
	if (n != 0) {
f0100cd4:	85 db                	test   %ebx,%ebx
f0100cd6:	74 1a                	je     f0100cf2 <boot_alloc+0x76>
		char *next = nextfree;
f0100cd8:	a1 94 f1 17 f0       	mov    0xf017f194,%eax
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
f0100cdd:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100ce4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100cea:	89 15 94 f1 17 f0    	mov    %edx,0xf017f194
		return next;
f0100cf0:	eb 05                	jmp    f0100cf7 <boot_alloc+0x7b>
	} else return nextfree;
f0100cf2:	a1 94 f1 17 f0       	mov    0xf017f194,%eax

	return NULL;
}
f0100cf7:	83 c4 14             	add    $0x14,%esp
f0100cfa:	5b                   	pop    %ebx
f0100cfb:	5d                   	pop    %ebp
f0100cfc:	c3                   	ret    

f0100cfd <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100cfd:	55                   	push   %ebp
f0100cfe:	89 e5                	mov    %esp,%ebp
f0100d00:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100d03:	89 d1                	mov    %edx,%ecx
f0100d05:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100d08:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100d0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100d10:	f6 c1 01             	test   $0x1,%cl
f0100d13:	74 57                	je     f0100d6c <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100d15:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d1b:	89 c8                	mov    %ecx,%eax
f0100d1d:	c1 e8 0c             	shr    $0xc,%eax
f0100d20:	3b 05 68 fe 17 f0    	cmp    0xf017fe68,%eax
f0100d26:	72 20                	jb     f0100d48 <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d28:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100d2c:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f0100d33:	f0 
f0100d34:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0100d3b:	00 
f0100d3c:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0100d43:	e8 ce f3 ff ff       	call   f0100116 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100d48:	c1 ea 0c             	shr    $0xc,%edx
f0100d4b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100d51:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f0100d58:	89 c2                	mov    %eax,%edx
f0100d5a:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100d5d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d62:	85 d2                	test   %edx,%edx
f0100d64:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100d69:	0f 44 c2             	cmove  %edx,%eax
}
f0100d6c:	c9                   	leave  
f0100d6d:	c3                   	ret    

f0100d6e <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100d6e:	55                   	push   %ebp
f0100d6f:	89 e5                	mov    %esp,%ebp
f0100d71:	83 ec 18             	sub    $0x18,%esp
f0100d74:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100d77:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100d7a:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100d7c:	89 04 24             	mov    %eax,(%esp)
f0100d7f:	e8 f8 2b 00 00       	call   f010397c <mc146818_read>
f0100d84:	89 c6                	mov    %eax,%esi
f0100d86:	83 c3 01             	add    $0x1,%ebx
f0100d89:	89 1c 24             	mov    %ebx,(%esp)
f0100d8c:	e8 eb 2b 00 00       	call   f010397c <mc146818_read>
f0100d91:	c1 e0 08             	shl    $0x8,%eax
f0100d94:	09 f0                	or     %esi,%eax
}
f0100d96:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100d99:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100d9c:	89 ec                	mov    %ebp,%esp
f0100d9e:	5d                   	pop    %ebp
f0100d9f:	c3                   	ret    

f0100da0 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100da0:	55                   	push   %ebp
f0100da1:	89 e5                	mov    %esp,%ebp
f0100da3:	57                   	push   %edi
f0100da4:	56                   	push   %esi
f0100da5:	53                   	push   %ebx
f0100da6:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100da9:	3c 01                	cmp    $0x1,%al
f0100dab:	19 f6                	sbb    %esi,%esi
f0100dad:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100db3:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100db6:	8b 1d 8c f1 17 f0    	mov    0xf017f18c,%ebx
f0100dbc:	85 db                	test   %ebx,%ebx
f0100dbe:	75 1c                	jne    f0100ddc <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0100dc0:	c7 44 24 08 ac 59 10 	movl   $0xf01059ac,0x8(%esp)
f0100dc7:	f0 
f0100dc8:	c7 44 24 04 54 02 00 	movl   $0x254,0x4(%esp)
f0100dcf:	00 
f0100dd0:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0100dd7:	e8 3a f3 ff ff       	call   f0100116 <_panic>

	if (only_low_memory) {
f0100ddc:	84 c0                	test   %al,%al
f0100dde:	74 50                	je     f0100e30 <check_page_free_list+0x90>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100de0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100de3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100de6:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100de9:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100dec:	89 d8                	mov    %ebx,%eax
f0100dee:	2b 05 70 fe 17 f0    	sub    0xf017fe70,%eax
f0100df4:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100df7:	c1 e8 16             	shr    $0x16,%eax
f0100dfa:	39 c6                	cmp    %eax,%esi
f0100dfc:	0f 96 c0             	setbe  %al
f0100dff:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100e02:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0100e06:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100e08:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e0c:	8b 1b                	mov    (%ebx),%ebx
f0100e0e:	85 db                	test   %ebx,%ebx
f0100e10:	75 da                	jne    f0100dec <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100e12:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100e15:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e1b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100e1e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e21:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e23:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100e26:	89 1d 8c f1 17 f0    	mov    %ebx,0xf017f18c
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e2c:	85 db                	test   %ebx,%ebx
f0100e2e:	74 67                	je     f0100e97 <check_page_free_list+0xf7>
f0100e30:	89 d8                	mov    %ebx,%eax
f0100e32:	2b 05 70 fe 17 f0    	sub    0xf017fe70,%eax
f0100e38:	c1 f8 03             	sar    $0x3,%eax
f0100e3b:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100e3e:	89 c2                	mov    %eax,%edx
f0100e40:	c1 ea 16             	shr    $0x16,%edx
f0100e43:	39 d6                	cmp    %edx,%esi
f0100e45:	76 4a                	jbe    f0100e91 <check_page_free_list+0xf1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e47:	89 c2                	mov    %eax,%edx
f0100e49:	c1 ea 0c             	shr    $0xc,%edx
f0100e4c:	3b 15 68 fe 17 f0    	cmp    0xf017fe68,%edx
f0100e52:	72 20                	jb     f0100e74 <check_page_free_list+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e54:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e58:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f0100e5f:	f0 
f0100e60:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100e67:	00 
f0100e68:	c7 04 24 20 56 10 f0 	movl   $0xf0105620,(%esp)
f0100e6f:	e8 a2 f2 ff ff       	call   f0100116 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100e74:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100e7b:	00 
f0100e7c:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100e83:	00 
	return (void *)(pa + KERNBASE);
f0100e84:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e89:	89 04 24             	mov    %eax,(%esp)
f0100e8c:	e8 e0 3b 00 00       	call   f0104a71 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e91:	8b 1b                	mov    (%ebx),%ebx
f0100e93:	85 db                	test   %ebx,%ebx
f0100e95:	75 99                	jne    f0100e30 <check_page_free_list+0x90>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100e97:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e9c:	e8 db fd ff ff       	call   f0100c7c <boot_alloc>
f0100ea1:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ea4:	8b 15 8c f1 17 f0    	mov    0xf017f18c,%edx
f0100eaa:	85 d2                	test   %edx,%edx
f0100eac:	0f 84 f6 01 00 00    	je     f01010a8 <check_page_free_list+0x308>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100eb2:	8b 1d 70 fe 17 f0    	mov    0xf017fe70,%ebx
f0100eb8:	39 da                	cmp    %ebx,%edx
f0100eba:	72 4d                	jb     f0100f09 <check_page_free_list+0x169>
		assert(pp < pages + npages);
f0100ebc:	a1 68 fe 17 f0       	mov    0xf017fe68,%eax
f0100ec1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100ec4:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0100ec7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100eca:	39 c2                	cmp    %eax,%edx
f0100ecc:	73 64                	jae    f0100f32 <check_page_free_list+0x192>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ece:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100ed1:	89 d0                	mov    %edx,%eax
f0100ed3:	29 d8                	sub    %ebx,%eax
f0100ed5:	a8 07                	test   $0x7,%al
f0100ed7:	0f 85 82 00 00 00    	jne    f0100f5f <check_page_free_list+0x1bf>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100edd:	c1 f8 03             	sar    $0x3,%eax
f0100ee0:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100ee3:	85 c0                	test   %eax,%eax
f0100ee5:	0f 84 a2 00 00 00    	je     f0100f8d <check_page_free_list+0x1ed>
		assert(page2pa(pp) != IOPHYSMEM);
f0100eeb:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ef0:	0f 84 c2 00 00 00    	je     f0100fb8 <check_page_free_list+0x218>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ef6:	be 00 00 00 00       	mov    $0x0,%esi
f0100efb:	bf 00 00 00 00       	mov    $0x0,%edi
f0100f00:	e9 d7 00 00 00       	jmp    f0100fdc <check_page_free_list+0x23c>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100f05:	39 da                	cmp    %ebx,%edx
f0100f07:	73 24                	jae    f0100f2d <check_page_free_list+0x18d>
f0100f09:	c7 44 24 0c 2e 56 10 	movl   $0xf010562e,0xc(%esp)
f0100f10:	f0 
f0100f11:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0100f18:	f0 
f0100f19:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
f0100f20:	00 
f0100f21:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0100f28:	e8 e9 f1 ff ff       	call   f0100116 <_panic>
		assert(pp < pages + npages);
f0100f2d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100f30:	72 24                	jb     f0100f56 <check_page_free_list+0x1b6>
f0100f32:	c7 44 24 0c 4f 56 10 	movl   $0xf010564f,0xc(%esp)
f0100f39:	f0 
f0100f3a:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0100f41:	f0 
f0100f42:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
f0100f49:	00 
f0100f4a:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0100f51:	e8 c0 f1 ff ff       	call   f0100116 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f56:	89 d0                	mov    %edx,%eax
f0100f58:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100f5b:	a8 07                	test   $0x7,%al
f0100f5d:	74 24                	je     f0100f83 <check_page_free_list+0x1e3>
f0100f5f:	c7 44 24 0c d0 59 10 	movl   $0xf01059d0,0xc(%esp)
f0100f66:	f0 
f0100f67:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0100f6e:	f0 
f0100f6f:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
f0100f76:	00 
f0100f77:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0100f7e:	e8 93 f1 ff ff       	call   f0100116 <_panic>
f0100f83:	c1 f8 03             	sar    $0x3,%eax
f0100f86:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100f89:	85 c0                	test   %eax,%eax
f0100f8b:	75 24                	jne    f0100fb1 <check_page_free_list+0x211>
f0100f8d:	c7 44 24 0c 63 56 10 	movl   $0xf0105663,0xc(%esp)
f0100f94:	f0 
f0100f95:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0100f9c:	f0 
f0100f9d:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
f0100fa4:	00 
f0100fa5:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0100fac:	e8 65 f1 ff ff       	call   f0100116 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100fb1:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100fb6:	75 24                	jne    f0100fdc <check_page_free_list+0x23c>
f0100fb8:	c7 44 24 0c 74 56 10 	movl   $0xf0105674,0xc(%esp)
f0100fbf:	f0 
f0100fc0:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0100fc7:	f0 
f0100fc8:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
f0100fcf:	00 
f0100fd0:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0100fd7:	e8 3a f1 ff ff       	call   f0100116 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100fdc:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100fe1:	75 24                	jne    f0101007 <check_page_free_list+0x267>
f0100fe3:	c7 44 24 0c 04 5a 10 	movl   $0xf0105a04,0xc(%esp)
f0100fea:	f0 
f0100feb:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0100ff2:	f0 
f0100ff3:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f0100ffa:	00 
f0100ffb:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101002:	e8 0f f1 ff ff       	call   f0100116 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101007:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010100c:	75 24                	jne    f0101032 <check_page_free_list+0x292>
f010100e:	c7 44 24 0c 8d 56 10 	movl   $0xf010568d,0xc(%esp)
f0101015:	f0 
f0101016:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f010101d:	f0 
f010101e:	c7 44 24 04 76 02 00 	movl   $0x276,0x4(%esp)
f0101025:	00 
f0101026:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f010102d:	e8 e4 f0 ff ff       	call   f0100116 <_panic>
f0101032:	89 c1                	mov    %eax,%ecx
		// cprintf("pp: %x, page2pa(pp): %x, page2kva(pp): %x, first_free_page: %x\n",
		// 	pp, page2pa(pp), page2kva(pp), first_free_page);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101034:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101039:	76 57                	jbe    f0101092 <check_page_free_list+0x2f2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010103b:	c1 e8 0c             	shr    $0xc,%eax
f010103e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101041:	77 20                	ja     f0101063 <check_page_free_list+0x2c3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101043:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101047:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f010104e:	f0 
f010104f:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101056:	00 
f0101057:	c7 04 24 20 56 10 f0 	movl   $0xf0105620,(%esp)
f010105e:	e8 b3 f0 ff ff       	call   f0100116 <_panic>
	return (void *)(pa + KERNBASE);
f0101063:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101069:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f010106c:	76 29                	jbe    f0101097 <check_page_free_list+0x2f7>
f010106e:	c7 44 24 0c 28 5a 10 	movl   $0xf0105a28,0xc(%esp)
f0101075:	f0 
f0101076:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f010107d:	f0 
f010107e:	c7 44 24 04 79 02 00 	movl   $0x279,0x4(%esp)
f0101085:	00 
f0101086:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f010108d:	e8 84 f0 ff ff       	call   f0100116 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101092:	83 c7 01             	add    $0x1,%edi
f0101095:	eb 03                	jmp    f010109a <check_page_free_list+0x2fa>
		else
			++nfree_extmem;
f0101097:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010109a:	8b 12                	mov    (%edx),%edx
f010109c:	85 d2                	test   %edx,%edx
f010109e:	0f 85 61 fe ff ff    	jne    f0100f05 <check_page_free_list+0x165>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01010a4:	85 ff                	test   %edi,%edi
f01010a6:	7f 24                	jg     f01010cc <check_page_free_list+0x32c>
f01010a8:	c7 44 24 0c a7 56 10 	movl   $0xf01056a7,0xc(%esp)
f01010af:	f0 
f01010b0:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01010b7:	f0 
f01010b8:	c7 44 24 04 81 02 00 	movl   $0x281,0x4(%esp)
f01010bf:	00 
f01010c0:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01010c7:	e8 4a f0 ff ff       	call   f0100116 <_panic>
	assert(nfree_extmem > 0);
f01010cc:	85 f6                	test   %esi,%esi
f01010ce:	7f 24                	jg     f01010f4 <check_page_free_list+0x354>
f01010d0:	c7 44 24 0c b9 56 10 	movl   $0xf01056b9,0xc(%esp)
f01010d7:	f0 
f01010d8:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01010df:	f0 
f01010e0:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
f01010e7:	00 
f01010e8:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01010ef:	e8 22 f0 ff ff       	call   f0100116 <_panic>
	cprintf("check_page_free_list done\n");
f01010f4:	c7 04 24 ca 56 10 f0 	movl   $0xf01056ca,(%esp)
f01010fb:	e8 ea 28 00 00       	call   f01039ea <cprintf>
}
f0101100:	83 c4 3c             	add    $0x3c,%esp
f0101103:	5b                   	pop    %ebx
f0101104:	5e                   	pop    %esi
f0101105:	5f                   	pop    %edi
f0101106:	5d                   	pop    %ebp
f0101107:	c3                   	ret    

f0101108 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101108:	55                   	push   %ebp
f0101109:	89 e5                	mov    %esp,%ebp
f010110b:	56                   	push   %esi
f010110c:	53                   	push   %ebx
f010110d:	83 ec 10             	sub    $0x10,%esp
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0101110:	8b 35 90 f1 17 f0    	mov    0xf017f190,%esi
f0101116:	83 fe 01             	cmp    $0x1,%esi
f0101119:	76 37                	jbe    f0101152 <page_init+0x4a>
f010111b:	8b 1d 8c f1 17 f0    	mov    0xf017f18c,%ebx
f0101121:	b8 01 00 00 00       	mov    $0x1,%eax
f0101126:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f010112d:	89 d1                	mov    %edx,%ecx
f010112f:	03 0d 70 fe 17 f0    	add    0xf017fe70,%ecx
f0101135:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f010113b:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f010113d:	89 d3                	mov    %edx,%ebx
f010113f:	03 1d 70 fe 17 f0    	add    0xf017fe70,%ebx
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0101145:	83 c0 01             	add    $0x1,%eax
f0101148:	39 c6                	cmp    %eax,%esi
f010114a:	77 da                	ja     f0101126 <page_init+0x1e>
f010114c:	89 1d 8c f1 17 f0    	mov    %ebx,0xf017f18c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
f0101152:	8b 15 98 f1 17 f0    	mov    0xf017f198,%edx
f0101158:	8d 82 ff 8f 01 10    	lea    0x10018fff(%edx),%eax
f010115e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101163:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101169:	85 c0                	test   %eax,%eax
f010116b:	0f 49 d8             	cmovns %eax,%ebx
f010116e:	c1 fb 0c             	sar    $0xc,%ebx
	cprintf("%x\n", ((char*)envs) + (sizeof(struct Env) * NENV));
f0101171:	81 c2 00 80 01 00    	add    $0x18000,%edx
f0101177:	89 54 24 04          	mov    %edx,0x4(%esp)
f010117b:	c7 04 24 52 59 10 f0 	movl   $0xf0105952,(%esp)
f0101182:	e8 63 28 00 00       	call   f01039ea <cprintf>
	cprintf("med=%d\n", med);
f0101187:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010118b:	c7 04 24 e5 56 10 f0 	movl   $0xf01056e5,(%esp)
f0101192:	e8 53 28 00 00       	call   f01039ea <cprintf>
	for (i = med; i < npages; i++) {
f0101197:	89 d8                	mov    %ebx,%eax
f0101199:	3b 1d 68 fe 17 f0    	cmp    0xf017fe68,%ebx
f010119f:	73 35                	jae    f01011d6 <page_init+0xce>
f01011a1:	8b 0d 8c f1 17 f0    	mov    0xf017f18c,%ecx
f01011a7:	c1 e3 03             	shl    $0x3,%ebx
		pages[i].pp_ref = 0;
f01011aa:	89 da                	mov    %ebx,%edx
f01011ac:	03 15 70 fe 17 f0    	add    0xf017fe70,%edx
f01011b2:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f01011b8:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f01011ba:	89 d9                	mov    %ebx,%ecx
f01011bc:	03 0d 70 fe 17 f0    	add    0xf017fe70,%ecx
		page_free_list = &pages[i];
	}
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
	cprintf("%x\n", ((char*)envs) + (sizeof(struct Env) * NENV));
	cprintf("med=%d\n", med);
	for (i = med; i < npages; i++) {
f01011c2:	83 c0 01             	add    $0x1,%eax
f01011c5:	83 c3 08             	add    $0x8,%ebx
f01011c8:	39 05 68 fe 17 f0    	cmp    %eax,0xf017fe68
f01011ce:	77 da                	ja     f01011aa <page_init+0xa2>
f01011d0:	89 0d 8c f1 17 f0    	mov    %ecx,0xf017f18c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f01011d6:	83 c4 10             	add    $0x10,%esp
f01011d9:	5b                   	pop    %ebx
f01011da:	5e                   	pop    %esi
f01011db:	5d                   	pop    %ebp
f01011dc:	c3                   	ret    

f01011dd <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01011dd:	55                   	push   %ebp
f01011de:	89 e5                	mov    %esp,%ebp
f01011e0:	53                   	push   %ebx
f01011e1:	83 ec 14             	sub    $0x14,%esp
	if (page_free_list) {
f01011e4:	8b 1d 8c f1 17 f0    	mov    0xf017f18c,%ebx
f01011ea:	85 db                	test   %ebx,%ebx
f01011ec:	74 65                	je     f0101253 <page_alloc+0x76>
		struct PageInfo *ret = page_free_list;
		page_free_list = page_free_list->pp_link;
f01011ee:	8b 03                	mov    (%ebx),%eax
f01011f0:	a3 8c f1 17 f0       	mov    %eax,0xf017f18c
		if (alloc_flags & ALLOC_ZERO) 
f01011f5:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01011f9:	74 58                	je     f0101253 <page_alloc+0x76>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011fb:	89 d8                	mov    %ebx,%eax
f01011fd:	2b 05 70 fe 17 f0    	sub    0xf017fe70,%eax
f0101203:	c1 f8 03             	sar    $0x3,%eax
f0101206:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101209:	89 c2                	mov    %eax,%edx
f010120b:	c1 ea 0c             	shr    $0xc,%edx
f010120e:	3b 15 68 fe 17 f0    	cmp    0xf017fe68,%edx
f0101214:	72 20                	jb     f0101236 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101216:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010121a:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f0101221:	f0 
f0101222:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101229:	00 
f010122a:	c7 04 24 20 56 10 f0 	movl   $0xf0105620,(%esp)
f0101231:	e8 e0 ee ff ff       	call   f0100116 <_panic>
			memset(page2kva(ret), 0, PGSIZE);
f0101236:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010123d:	00 
f010123e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101245:	00 
	return (void *)(pa + KERNBASE);
f0101246:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010124b:	89 04 24             	mov    %eax,(%esp)
f010124e:	e8 1e 38 00 00       	call   f0104a71 <memset>
		return ret;
	}
	return NULL;
}
f0101253:	89 d8                	mov    %ebx,%eax
f0101255:	83 c4 14             	add    $0x14,%esp
f0101258:	5b                   	pop    %ebx
f0101259:	5d                   	pop    %ebp
f010125a:	c3                   	ret    

f010125b <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010125b:	55                   	push   %ebp
f010125c:	89 e5                	mov    %esp,%ebp
f010125e:	8b 45 08             	mov    0x8(%ebp),%eax
	pp->pp_link = page_free_list;
f0101261:	8b 15 8c f1 17 f0    	mov    0xf017f18c,%edx
f0101267:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101269:	a3 8c f1 17 f0       	mov    %eax,0xf017f18c
}
f010126e:	5d                   	pop    %ebp
f010126f:	c3                   	ret    

f0101270 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101270:	55                   	push   %ebp
f0101271:	89 e5                	mov    %esp,%ebp
f0101273:	83 ec 04             	sub    $0x4,%esp
f0101276:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101279:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f010127d:	83 ea 01             	sub    $0x1,%edx
f0101280:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101284:	66 85 d2             	test   %dx,%dx
f0101287:	75 08                	jne    f0101291 <page_decref+0x21>
		page_free(pp);
f0101289:	89 04 24             	mov    %eax,(%esp)
f010128c:	e8 ca ff ff ff       	call   f010125b <page_free>
}
f0101291:	c9                   	leave  
f0101292:	c3                   	ret    

f0101293 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101293:	55                   	push   %ebp
f0101294:	89 e5                	mov    %esp,%ebp
f0101296:	83 ec 18             	sub    $0x18,%esp
f0101299:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010129c:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010129f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int dindex = PDX(va), tindex = PTX(va);
f01012a2:	89 f3                	mov    %esi,%ebx
f01012a4:	c1 eb 16             	shr    $0x16,%ebx
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
f01012a7:	c1 e3 02             	shl    $0x2,%ebx
f01012aa:	03 5d 08             	add    0x8(%ebp),%ebx
f01012ad:	f6 03 01             	testb  $0x1,(%ebx)
f01012b0:	75 31                	jne    f01012e3 <pgdir_walk+0x50>
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
			pg->pp_ref++;
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
		} else return NULL;
f01012b2:	b8 00 00 00 00       	mov    $0x0,%eax
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
f01012b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01012bb:	74 71                	je     f010132e <pgdir_walk+0x9b>
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
f01012bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01012c4:	e8 14 ff ff ff       	call   f01011dd <page_alloc>
			if (!pg) return NULL;	//allocation fails
f01012c9:	85 c0                	test   %eax,%eax
f01012cb:	74 5c                	je     f0101329 <pgdir_walk+0x96>
			pg->pp_ref++;
f01012cd:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012d2:	2b 05 70 fe 17 f0    	sub    0xf017fe70,%eax
f01012d8:	c1 f8 03             	sar    $0x3,%eax
f01012db:	c1 e0 0c             	shl    $0xc,%eax
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
f01012de:	83 c8 07             	or     $0x7,%eax
f01012e1:	89 03                	mov    %eax,(%ebx)
		} else return NULL;
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));
f01012e3:	8b 03                	mov    (%ebx),%eax
f01012e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012ea:	89 c2                	mov    %eax,%edx
f01012ec:	c1 ea 0c             	shr    $0xc,%edx
f01012ef:	3b 15 68 fe 17 f0    	cmp    0xf017fe68,%edx
f01012f5:	72 20                	jb     f0101317 <pgdir_walk+0x84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012fb:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f0101302:	f0 
f0101303:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
f010130a:	00 
f010130b:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101312:	e8 ff ed ff ff       	call   f0100116 <_panic>
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	int dindex = PDX(va), tindex = PTX(va);
f0101317:	c1 ee 0a             	shr    $0xa,%esi
	// 		struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
f010131a:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101320:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101327:	eb 05                	jmp    f010132e <pgdir_walk+0x9b>
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
f0101329:	b8 00 00 00 00       	mov    $0x0,%eax
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
}
f010132e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101331:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101334:	89 ec                	mov    %ebp,%esp
f0101336:	5d                   	pop    %ebp
f0101337:	c3                   	ret    

f0101338 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101338:	55                   	push   %ebp
f0101339:	89 e5                	mov    %esp,%ebp
f010133b:	57                   	push   %edi
f010133c:	56                   	push   %esi
f010133d:	53                   	push   %ebx
f010133e:	83 ec 2c             	sub    $0x2c,%esp
f0101341:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101344:	89 d3                	mov    %edx,%ebx
f0101346:	89 cf                	mov    %ecx,%edi
f0101348:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
f010134b:	89 74 24 08          	mov    %esi,0x8(%esp)
f010134f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101353:	c7 04 24 70 5a 10 f0 	movl   $0xf0105a70,(%esp)
f010135a:	e8 8b 26 00 00       	call   f01039ea <cprintf>
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f010135f:	c1 ef 0c             	shr    $0xc,%edi
f0101362:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0101365:	85 ff                	test   %edi,%edi
f0101367:	74 60                	je     f01013c9 <boot_map_region+0x91>
f0101369:	bf 00 00 00 00       	mov    $0x0,%edi
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
f010136e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101371:	83 c8 01             	or     $0x1,%eax
f0101374:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f0101377:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010137e:	00 
f010137f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101383:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101386:	89 04 24             	mov    %eax,(%esp)
f0101389:	e8 05 ff ff ff       	call   f0101293 <pgdir_walk>
		if (!pte) panic("boot_map_region panic, out of memory");
f010138e:	85 c0                	test   %eax,%eax
f0101390:	75 1c                	jne    f01013ae <boot_map_region+0x76>
f0101392:	c7 44 24 08 44 55 10 	movl   $0xf0105544,0x8(%esp)
f0101399:	f0 
f010139a:	c7 44 24 04 a9 01 00 	movl   $0x1a9,0x4(%esp)
f01013a1:	00 
f01013a2:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01013a9:	e8 68 ed ff ff       	call   f0100116 <_panic>
		*pte = pa | perm | PTE_P;
f01013ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01013b1:	09 f2                	or     %esi,%edx
f01013b3:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01013b5:	83 c7 01             	add    $0x1,%edi
f01013b8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01013be:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01013c4:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f01013c7:	72 ae                	jb     f0101377 <boot_map_region+0x3f>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
	}
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
f01013c9:	89 74 24 08          	mov    %esi,0x8(%esp)
f01013cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01013d1:	c7 04 24 70 5a 10 f0 	movl   $0xf0105a70,(%esp)
f01013d8:	e8 0d 26 00 00       	call   f01039ea <cprintf>
}
f01013dd:	83 c4 2c             	add    $0x2c,%esp
f01013e0:	5b                   	pop    %ebx
f01013e1:	5e                   	pop    %esi
f01013e2:	5f                   	pop    %edi
f01013e3:	5d                   	pop    %ebp
f01013e4:	c3                   	ret    

f01013e5 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01013e5:	55                   	push   %ebp
f01013e6:	89 e5                	mov    %esp,%ebp
f01013e8:	53                   	push   %ebx
f01013e9:	83 ec 14             	sub    $0x14,%esp
f01013ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
f01013ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01013f6:	00 
f01013f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0101401:	89 04 24             	mov    %eax,(%esp)
f0101404:	e8 8a fe ff ff       	call   f0101293 <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f0101409:	ba 00 00 00 00       	mov    $0x0,%edx
f010140e:	85 c0                	test   %eax,%eax
f0101410:	74 44                	je     f0101456 <page_lookup+0x71>
f0101412:	f6 00 01             	testb  $0x1,(%eax)
f0101415:	74 3a                	je     f0101451 <page_lookup+0x6c>
	if (pte_store)
f0101417:	85 db                	test   %ebx,%ebx
f0101419:	74 02                	je     f010141d <page_lookup+0x38>
		*pte_store = pte;	//found and set
f010141b:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*pte));		
f010141d:	8b 10                	mov    (%eax),%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010141f:	c1 ea 0c             	shr    $0xc,%edx
f0101422:	3b 15 68 fe 17 f0    	cmp    0xf017fe68,%edx
f0101428:	72 1c                	jb     f0101446 <page_lookup+0x61>
		panic("pa2page called with invalid pa");
f010142a:	c7 44 24 08 a4 5a 10 	movl   $0xf0105aa4,0x8(%esp)
f0101431:	f0 
f0101432:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101439:	00 
f010143a:	c7 04 24 20 56 10 f0 	movl   $0xf0105620,(%esp)
f0101441:	e8 d0 ec ff ff       	call   f0100116 <_panic>
	return &pages[PGNUM(pa)];
f0101446:	c1 e2 03             	shl    $0x3,%edx
f0101449:	03 15 70 fe 17 f0    	add    0xf017fe70,%edx
f010144f:	eb 05                	jmp    f0101456 <page_lookup+0x71>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f0101451:	ba 00 00 00 00       	mov    $0x0,%edx
	if (pte_store)
		*pte_store = pte;	//found and set
	return pa2page(PTE_ADDR(*pte));		
}
f0101456:	89 d0                	mov    %edx,%eax
f0101458:	83 c4 14             	add    $0x14,%esp
f010145b:	5b                   	pop    %ebx
f010145c:	5d                   	pop    %ebp
f010145d:	c3                   	ret    

f010145e <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010145e:	55                   	push   %ebp
f010145f:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101461:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101464:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101467:	5d                   	pop    %ebp
f0101468:	c3                   	ret    

f0101469 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101469:	55                   	push   %ebp
f010146a:	89 e5                	mov    %esp,%ebp
f010146c:	83 ec 28             	sub    $0x28,%esp
f010146f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101472:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101475:	8b 75 08             	mov    0x8(%ebp),%esi
f0101478:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte;
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f010147b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010147e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101482:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101486:	89 34 24             	mov    %esi,(%esp)
f0101489:	e8 57 ff ff ff       	call   f01013e5 <page_lookup>
	if (!pg || !(*pte & PTE_P)) return;	//page not exist
f010148e:	85 c0                	test   %eax,%eax
f0101490:	74 25                	je     f01014b7 <page_remove+0x4e>
f0101492:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101495:	f6 02 01             	testb  $0x1,(%edx)
f0101498:	74 1d                	je     f01014b7 <page_remove+0x4e>
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
	page_decref(pg);
f010149a:	89 04 24             	mov    %eax,(%esp)
f010149d:	e8 ce fd ff ff       	call   f0101270 <page_decref>
//   - The pg table entry corresponding to 'va' should be set to 0.
	*pte = 0;
f01014a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01014a5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
//   - The TLB must be invalidated if you remove an entry from
//     the page table.
	tlb_invalidate(pgdir, va);
f01014ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01014af:	89 34 24             	mov    %esi,(%esp)
f01014b2:	e8 a7 ff ff ff       	call   f010145e <tlb_invalidate>
}
f01014b7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01014ba:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01014bd:	89 ec                	mov    %ebp,%esp
f01014bf:	5d                   	pop    %ebp
f01014c0:	c3                   	ret    

f01014c1 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01014c1:	55                   	push   %ebp
f01014c2:	89 e5                	mov    %esp,%ebp
f01014c4:	83 ec 28             	sub    $0x28,%esp
f01014c7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01014ca:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01014cd:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01014d0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014d3:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
f01014d6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01014dd:	00 
f01014de:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01014e2:	8b 45 08             	mov    0x8(%ebp),%eax
f01014e5:	89 04 24             	mov    %eax,(%esp)
f01014e8:	e8 a6 fd ff ff       	call   f0101293 <pgdir_walk>
f01014ed:	89 c3                	mov    %eax,%ebx
	if (!pte) 	//page table not allocated
		return -E_NO_MEM;	
f01014ef:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
	if (!pte) 	//page table not allocated
f01014f4:	85 db                	test   %ebx,%ebx
f01014f6:	74 38                	je     f0101530 <page_insert+0x6f>
		return -E_NO_MEM;	
	//increase ref count to avoid the corner case that pp is freed before it is inserted.
	pp->pp_ref++;	
f01014f8:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
f01014fd:	f6 03 01             	testb  $0x1,(%ebx)
f0101500:	74 0f                	je     f0101511 <page_insert+0x50>
		page_remove(pgdir, va);
f0101502:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101506:	8b 45 08             	mov    0x8(%ebp),%eax
f0101509:	89 04 24             	mov    %eax,(%esp)
f010150c:	e8 58 ff ff ff       	call   f0101469 <page_remove>
	*pte = page2pa(pp) | perm | PTE_P;
f0101511:	8b 55 14             	mov    0x14(%ebp),%edx
f0101514:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101517:	2b 35 70 fe 17 f0    	sub    0xf017fe70,%esi
f010151d:	c1 fe 03             	sar    $0x3,%esi
f0101520:	89 f0                	mov    %esi,%eax
f0101522:	c1 e0 0c             	shl    $0xc,%eax
f0101525:	89 d6                	mov    %edx,%esi
f0101527:	09 c6                	or     %eax,%esi
f0101529:	89 33                	mov    %esi,(%ebx)
	return 0;
f010152b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101530:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101533:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101536:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101539:	89 ec                	mov    %ebp,%esp
f010153b:	5d                   	pop    %ebp
f010153c:	c3                   	ret    

f010153d <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010153d:	55                   	push   %ebp
f010153e:	89 e5                	mov    %esp,%ebp
f0101540:	57                   	push   %edi
f0101541:	56                   	push   %esi
f0101542:	53                   	push   %ebx
f0101543:	83 ec 4c             	sub    $0x4c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101546:	b8 15 00 00 00       	mov    $0x15,%eax
f010154b:	e8 1e f8 ff ff       	call   f0100d6e <nvram_read>
f0101550:	c1 e0 0a             	shl    $0xa,%eax
f0101553:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101559:	85 c0                	test   %eax,%eax
f010155b:	0f 48 c2             	cmovs  %edx,%eax
f010155e:	c1 f8 0c             	sar    $0xc,%eax
f0101561:	a3 90 f1 17 f0       	mov    %eax,0xf017f190
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101566:	b8 17 00 00 00       	mov    $0x17,%eax
f010156b:	e8 fe f7 ff ff       	call   f0100d6e <nvram_read>
f0101570:	c1 e0 0a             	shl    $0xa,%eax
f0101573:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101579:	85 c0                	test   %eax,%eax
f010157b:	0f 48 c2             	cmovs  %edx,%eax
f010157e:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101581:	85 c0                	test   %eax,%eax
f0101583:	74 0e                	je     f0101593 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101585:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010158b:	89 15 68 fe 17 f0    	mov    %edx,0xf017fe68
f0101591:	eb 0c                	jmp    f010159f <mem_init+0x62>
	else
		npages = npages_basemem;
f0101593:	8b 15 90 f1 17 f0    	mov    0xf017f190,%edx
f0101599:	89 15 68 fe 17 f0    	mov    %edx,0xf017fe68

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010159f:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015a2:	c1 e8 0a             	shr    $0xa,%eax
f01015a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01015a9:	a1 90 f1 17 f0       	mov    0xf017f190,%eax
f01015ae:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015b1:	c1 e8 0a             	shr    $0xa,%eax
f01015b4:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01015b8:	a1 68 fe 17 f0       	mov    0xf017fe68,%eax
f01015bd:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015c0:	c1 e8 0a             	shr    $0xa,%eax
f01015c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015c7:	c7 04 24 c4 5a 10 f0 	movl   $0xf0105ac4,(%esp)
f01015ce:	e8 17 24 00 00       	call   f01039ea <cprintf>
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01015d3:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015d8:	e8 9f f6 ff ff       	call   f0100c7c <boot_alloc>
f01015dd:	a3 6c fe 17 f0       	mov    %eax,0xf017fe6c
	memset(kern_pgdir, 0, PGSIZE);
f01015e2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01015e9:	00 
f01015ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01015f1:	00 
f01015f2:	89 04 24             	mov    %eax,(%esp)
f01015f5:	e8 77 34 00 00       	call   f0104a71 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01015fa:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01015ff:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101604:	77 20                	ja     f0101626 <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101606:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010160a:	c7 44 24 08 00 5b 10 	movl   $0xf0105b00,0x8(%esp)
f0101611:	f0 
f0101612:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f0101619:	00 
f010161a:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101621:	e8 f0 ea ff ff       	call   f0100116 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101626:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010162c:	83 ca 05             	or     $0x5,%edx
f010162f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f0101635:	a1 68 fe 17 f0       	mov    0xf017fe68,%eax
f010163a:	c1 e0 03             	shl    $0x3,%eax
f010163d:	e8 3a f6 ff ff       	call   f0100c7c <boot_alloc>
f0101642:	a3 70 fe 17 f0       	mov    %eax,0xf017fe70

	cprintf("npages: %d\n", npages);
f0101647:	a1 68 fe 17 f0       	mov    0xf017fe68,%eax
f010164c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101650:	c7 04 24 ed 56 10 f0 	movl   $0xf01056ed,(%esp)
f0101657:	e8 8e 23 00 00       	call   f01039ea <cprintf>
	cprintf("npages_basemem: %d\n", npages_basemem);
f010165c:	a1 90 f1 17 f0       	mov    0xf017f190,%eax
f0101661:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101665:	c7 04 24 f9 56 10 f0 	movl   $0xf01056f9,(%esp)
f010166c:	e8 79 23 00 00       	call   f01039ea <cprintf>
	cprintf("pages: %x\n", pages);
f0101671:	a1 70 fe 17 f0       	mov    0xf017fe70,%eax
f0101676:	89 44 24 04          	mov    %eax,0x4(%esp)
f010167a:	c7 04 24 0d 57 10 f0 	movl   $0xf010570d,(%esp)
f0101681:	e8 64 23 00 00       	call   f01039ea <cprintf>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f0101686:	b8 00 80 01 00       	mov    $0x18000,%eax
f010168b:	e8 ec f5 ff ff       	call   f0100c7c <boot_alloc>
f0101690:	a3 98 f1 17 f0       	mov    %eax,0xf017f198
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101695:	e8 6e fa ff ff       	call   f0101108 <page_init>

	check_page_free_list(1);
f010169a:	b8 01 00 00 00       	mov    $0x1,%eax
f010169f:	e8 fc f6 ff ff       	call   f0100da0 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01016a4:	83 3d 70 fe 17 f0 00 	cmpl   $0x0,0xf017fe70
f01016ab:	75 1c                	jne    f01016c9 <mem_init+0x18c>
		panic("'pages' is a null pointer!");
f01016ad:	c7 44 24 08 18 57 10 	movl   $0xf0105718,0x8(%esp)
f01016b4:	f0 
f01016b5:	c7 44 24 04 94 02 00 	movl   $0x294,0x4(%esp)
f01016bc:	00 
f01016bd:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01016c4:	e8 4d ea ff ff       	call   f0100116 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016c9:	a1 8c f1 17 f0       	mov    0xf017f18c,%eax
f01016ce:	bb 00 00 00 00       	mov    $0x0,%ebx
f01016d3:	85 c0                	test   %eax,%eax
f01016d5:	74 09                	je     f01016e0 <mem_init+0x1a3>
		++nfree;
f01016d7:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016da:	8b 00                	mov    (%eax),%eax
f01016dc:	85 c0                	test   %eax,%eax
f01016de:	75 f7                	jne    f01016d7 <mem_init+0x19a>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016e7:	e8 f1 fa ff ff       	call   f01011dd <page_alloc>
f01016ec:	89 c6                	mov    %eax,%esi
f01016ee:	85 c0                	test   %eax,%eax
f01016f0:	75 24                	jne    f0101716 <mem_init+0x1d9>
f01016f2:	c7 44 24 0c 33 57 10 	movl   $0xf0105733,0xc(%esp)
f01016f9:	f0 
f01016fa:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101701:	f0 
f0101702:	c7 44 24 04 9c 02 00 	movl   $0x29c,0x4(%esp)
f0101709:	00 
f010170a:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101711:	e8 00 ea ff ff       	call   f0100116 <_panic>
	assert((pp1 = page_alloc(0)));
f0101716:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010171d:	e8 bb fa ff ff       	call   f01011dd <page_alloc>
f0101722:	89 c7                	mov    %eax,%edi
f0101724:	85 c0                	test   %eax,%eax
f0101726:	75 24                	jne    f010174c <mem_init+0x20f>
f0101728:	c7 44 24 0c 49 57 10 	movl   $0xf0105749,0xc(%esp)
f010172f:	f0 
f0101730:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101737:	f0 
f0101738:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
f010173f:	00 
f0101740:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101747:	e8 ca e9 ff ff       	call   f0100116 <_panic>
	assert((pp2 = page_alloc(0)));
f010174c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101753:	e8 85 fa ff ff       	call   f01011dd <page_alloc>
f0101758:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010175b:	85 c0                	test   %eax,%eax
f010175d:	75 24                	jne    f0101783 <mem_init+0x246>
f010175f:	c7 44 24 0c 5f 57 10 	movl   $0xf010575f,0xc(%esp)
f0101766:	f0 
f0101767:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f010176e:	f0 
f010176f:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f0101776:	00 
f0101777:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f010177e:	e8 93 e9 ff ff       	call   f0100116 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101783:	39 fe                	cmp    %edi,%esi
f0101785:	75 24                	jne    f01017ab <mem_init+0x26e>
f0101787:	c7 44 24 0c 75 57 10 	movl   $0xf0105775,0xc(%esp)
f010178e:	f0 
f010178f:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101796:	f0 
f0101797:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
f010179e:	00 
f010179f:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01017a6:	e8 6b e9 ff ff       	call   f0100116 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017ab:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01017ae:	74 05                	je     f01017b5 <mem_init+0x278>
f01017b0:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01017b3:	75 24                	jne    f01017d9 <mem_init+0x29c>
f01017b5:	c7 44 24 0c 24 5b 10 	movl   $0xf0105b24,0xc(%esp)
f01017bc:	f0 
f01017bd:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01017c4:	f0 
f01017c5:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
f01017cc:	00 
f01017cd:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01017d4:	e8 3d e9 ff ff       	call   f0100116 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017d9:	8b 15 70 fe 17 f0    	mov    0xf017fe70,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01017df:	a1 68 fe 17 f0       	mov    0xf017fe68,%eax
f01017e4:	c1 e0 0c             	shl    $0xc,%eax
f01017e7:	89 f1                	mov    %esi,%ecx
f01017e9:	29 d1                	sub    %edx,%ecx
f01017eb:	c1 f9 03             	sar    $0x3,%ecx
f01017ee:	c1 e1 0c             	shl    $0xc,%ecx
f01017f1:	39 c1                	cmp    %eax,%ecx
f01017f3:	72 24                	jb     f0101819 <mem_init+0x2dc>
f01017f5:	c7 44 24 0c 87 57 10 	movl   $0xf0105787,0xc(%esp)
f01017fc:	f0 
f01017fd:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101804:	f0 
f0101805:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
f010180c:	00 
f010180d:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101814:	e8 fd e8 ff ff       	call   f0100116 <_panic>
f0101819:	89 f9                	mov    %edi,%ecx
f010181b:	29 d1                	sub    %edx,%ecx
f010181d:	c1 f9 03             	sar    $0x3,%ecx
f0101820:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101823:	39 c8                	cmp    %ecx,%eax
f0101825:	77 24                	ja     f010184b <mem_init+0x30e>
f0101827:	c7 44 24 0c a4 57 10 	movl   $0xf01057a4,0xc(%esp)
f010182e:	f0 
f010182f:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101836:	f0 
f0101837:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
f010183e:	00 
f010183f:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101846:	e8 cb e8 ff ff       	call   f0100116 <_panic>
f010184b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010184e:	29 d1                	sub    %edx,%ecx
f0101850:	89 ca                	mov    %ecx,%edx
f0101852:	c1 fa 03             	sar    $0x3,%edx
f0101855:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101858:	39 d0                	cmp    %edx,%eax
f010185a:	77 24                	ja     f0101880 <mem_init+0x343>
f010185c:	c7 44 24 0c c1 57 10 	movl   $0xf01057c1,0xc(%esp)
f0101863:	f0 
f0101864:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f010186b:	f0 
f010186c:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
f0101873:	00 
f0101874:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f010187b:	e8 96 e8 ff ff       	call   f0100116 <_panic>


	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101880:	a1 8c f1 17 f0       	mov    0xf017f18c,%eax
f0101885:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101888:	c7 05 8c f1 17 f0 00 	movl   $0x0,0xf017f18c
f010188f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101892:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101899:	e8 3f f9 ff ff       	call   f01011dd <page_alloc>
f010189e:	85 c0                	test   %eax,%eax
f01018a0:	74 24                	je     f01018c6 <mem_init+0x389>
f01018a2:	c7 44 24 0c de 57 10 	movl   $0xf01057de,0xc(%esp)
f01018a9:	f0 
f01018aa:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01018b1:	f0 
f01018b2:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
f01018b9:	00 
f01018ba:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01018c1:	e8 50 e8 ff ff       	call   f0100116 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01018c6:	89 34 24             	mov    %esi,(%esp)
f01018c9:	e8 8d f9 ff ff       	call   f010125b <page_free>
	page_free(pp1);
f01018ce:	89 3c 24             	mov    %edi,(%esp)
f01018d1:	e8 85 f9 ff ff       	call   f010125b <page_free>
	page_free(pp2);
f01018d6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01018d9:	89 14 24             	mov    %edx,(%esp)
f01018dc:	e8 7a f9 ff ff       	call   f010125b <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018e8:	e8 f0 f8 ff ff       	call   f01011dd <page_alloc>
f01018ed:	89 c6                	mov    %eax,%esi
f01018ef:	85 c0                	test   %eax,%eax
f01018f1:	75 24                	jne    f0101917 <mem_init+0x3da>
f01018f3:	c7 44 24 0c 33 57 10 	movl   $0xf0105733,0xc(%esp)
f01018fa:	f0 
f01018fb:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101902:	f0 
f0101903:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f010190a:	00 
f010190b:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101912:	e8 ff e7 ff ff       	call   f0100116 <_panic>
	assert((pp1 = page_alloc(0)));
f0101917:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010191e:	e8 ba f8 ff ff       	call   f01011dd <page_alloc>
f0101923:	89 c7                	mov    %eax,%edi
f0101925:	85 c0                	test   %eax,%eax
f0101927:	75 24                	jne    f010194d <mem_init+0x410>
f0101929:	c7 44 24 0c 49 57 10 	movl   $0xf0105749,0xc(%esp)
f0101930:	f0 
f0101931:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101938:	f0 
f0101939:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
f0101940:	00 
f0101941:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101948:	e8 c9 e7 ff ff       	call   f0100116 <_panic>
	assert((pp2 = page_alloc(0)));
f010194d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101954:	e8 84 f8 ff ff       	call   f01011dd <page_alloc>
f0101959:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010195c:	85 c0                	test   %eax,%eax
f010195e:	75 24                	jne    f0101984 <mem_init+0x447>
f0101960:	c7 44 24 0c 5f 57 10 	movl   $0xf010575f,0xc(%esp)
f0101967:	f0 
f0101968:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f010196f:	f0 
f0101970:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
f0101977:	00 
f0101978:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f010197f:	e8 92 e7 ff ff       	call   f0100116 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101984:	39 fe                	cmp    %edi,%esi
f0101986:	75 24                	jne    f01019ac <mem_init+0x46f>
f0101988:	c7 44 24 0c 75 57 10 	movl   $0xf0105775,0xc(%esp)
f010198f:	f0 
f0101990:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101997:	f0 
f0101998:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
f010199f:	00 
f01019a0:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01019a7:	e8 6a e7 ff ff       	call   f0100116 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019ac:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01019af:	74 05                	je     f01019b6 <mem_init+0x479>
f01019b1:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01019b4:	75 24                	jne    f01019da <mem_init+0x49d>
f01019b6:	c7 44 24 0c 24 5b 10 	movl   $0xf0105b24,0xc(%esp)
f01019bd:	f0 
f01019be:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01019c5:	f0 
f01019c6:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f01019cd:	00 
f01019ce:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01019d5:	e8 3c e7 ff ff       	call   f0100116 <_panic>
	assert(!page_alloc(0));
f01019da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019e1:	e8 f7 f7 ff ff       	call   f01011dd <page_alloc>
f01019e6:	85 c0                	test   %eax,%eax
f01019e8:	74 24                	je     f0101a0e <mem_init+0x4d1>
f01019ea:	c7 44 24 0c de 57 10 	movl   $0xf01057de,0xc(%esp)
f01019f1:	f0 
f01019f2:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01019f9:	f0 
f01019fa:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f0101a01:	00 
f0101a02:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101a09:	e8 08 e7 ff ff       	call   f0100116 <_panic>
f0101a0e:	89 f0                	mov    %esi,%eax
f0101a10:	2b 05 70 fe 17 f0    	sub    0xf017fe70,%eax
f0101a16:	c1 f8 03             	sar    $0x3,%eax
f0101a19:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a1c:	89 c2                	mov    %eax,%edx
f0101a1e:	c1 ea 0c             	shr    $0xc,%edx
f0101a21:	3b 15 68 fe 17 f0    	cmp    0xf017fe68,%edx
f0101a27:	72 20                	jb     f0101a49 <mem_init+0x50c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a29:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101a2d:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f0101a34:	f0 
f0101a35:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101a3c:	00 
f0101a3d:	c7 04 24 20 56 10 f0 	movl   $0xf0105620,(%esp)
f0101a44:	e8 cd e6 ff ff       	call   f0100116 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101a49:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a50:	00 
f0101a51:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101a58:	00 
	return (void *)(pa + KERNBASE);
f0101a59:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a5e:	89 04 24             	mov    %eax,(%esp)
f0101a61:	e8 0b 30 00 00       	call   f0104a71 <memset>
	page_free(pp0);
f0101a66:	89 34 24             	mov    %esi,(%esp)
f0101a69:	e8 ed f7 ff ff       	call   f010125b <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a75:	e8 63 f7 ff ff       	call   f01011dd <page_alloc>
f0101a7a:	85 c0                	test   %eax,%eax
f0101a7c:	75 24                	jne    f0101aa2 <mem_init+0x565>
f0101a7e:	c7 44 24 0c ed 57 10 	movl   $0xf01057ed,0xc(%esp)
f0101a85:	f0 
f0101a86:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101a8d:	f0 
f0101a8e:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
f0101a95:	00 
f0101a96:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101a9d:	e8 74 e6 ff ff       	call   f0100116 <_panic>
	assert(pp && pp0 == pp);
f0101aa2:	39 c6                	cmp    %eax,%esi
f0101aa4:	74 24                	je     f0101aca <mem_init+0x58d>
f0101aa6:	c7 44 24 0c 0b 58 10 	movl   $0xf010580b,0xc(%esp)
f0101aad:	f0 
f0101aae:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101ab5:	f0 
f0101ab6:	c7 44 24 04 c0 02 00 	movl   $0x2c0,0x4(%esp)
f0101abd:	00 
f0101abe:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101ac5:	e8 4c e6 ff ff       	call   f0100116 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101aca:	89 f2                	mov    %esi,%edx
f0101acc:	2b 15 70 fe 17 f0    	sub    0xf017fe70,%edx
f0101ad2:	c1 fa 03             	sar    $0x3,%edx
f0101ad5:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ad8:	89 d0                	mov    %edx,%eax
f0101ada:	c1 e8 0c             	shr    $0xc,%eax
f0101add:	3b 05 68 fe 17 f0    	cmp    0xf017fe68,%eax
f0101ae3:	72 20                	jb     f0101b05 <mem_init+0x5c8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ae5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101ae9:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f0101af0:	f0 
f0101af1:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101af8:	00 
f0101af9:	c7 04 24 20 56 10 f0 	movl   $0xf0105620,(%esp)
f0101b00:	e8 11 e6 ff ff       	call   f0100116 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b05:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101b0c:	75 11                	jne    f0101b1f <mem_init+0x5e2>
f0101b0e:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101b14:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b1a:	80 38 00             	cmpb   $0x0,(%eax)
f0101b1d:	74 24                	je     f0101b43 <mem_init+0x606>
f0101b1f:	c7 44 24 0c 1b 58 10 	movl   $0xf010581b,0xc(%esp)
f0101b26:	f0 
f0101b27:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101b2e:	f0 
f0101b2f:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
f0101b36:	00 
f0101b37:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101b3e:	e8 d3 e5 ff ff       	call   f0100116 <_panic>
f0101b43:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101b46:	39 d0                	cmp    %edx,%eax
f0101b48:	75 d0                	jne    f0101b1a <mem_init+0x5dd>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101b4a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101b4d:	89 0d 8c f1 17 f0    	mov    %ecx,0xf017f18c

	// free the pages we took
	page_free(pp0);
f0101b53:	89 34 24             	mov    %esi,(%esp)
f0101b56:	e8 00 f7 ff ff       	call   f010125b <page_free>
	page_free(pp1);
f0101b5b:	89 3c 24             	mov    %edi,(%esp)
f0101b5e:	e8 f8 f6 ff ff       	call   f010125b <page_free>
	page_free(pp2);
f0101b63:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101b66:	89 34 24             	mov    %esi,(%esp)
f0101b69:	e8 ed f6 ff ff       	call   f010125b <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b6e:	a1 8c f1 17 f0       	mov    0xf017f18c,%eax
f0101b73:	85 c0                	test   %eax,%eax
f0101b75:	74 09                	je     f0101b80 <mem_init+0x643>
		--nfree;
f0101b77:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b7a:	8b 00                	mov    (%eax),%eax
f0101b7c:	85 c0                	test   %eax,%eax
f0101b7e:	75 f7                	jne    f0101b77 <mem_init+0x63a>
		--nfree;
	assert(nfree == 0);
f0101b80:	85 db                	test   %ebx,%ebx
f0101b82:	74 24                	je     f0101ba8 <mem_init+0x66b>
f0101b84:	c7 44 24 0c 25 58 10 	movl   $0xf0105825,0xc(%esp)
f0101b8b:	f0 
f0101b8c:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101b93:	f0 
f0101b94:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f0101b9b:	00 
f0101b9c:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101ba3:	e8 6e e5 ff ff       	call   f0100116 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101ba8:	c7 04 24 44 5b 10 f0 	movl   $0xf0105b44,(%esp)
f0101baf:	e8 36 1e 00 00       	call   f01039ea <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	cprintf("so far so good\n");
f0101bb4:	c7 04 24 30 58 10 f0 	movl   $0xf0105830,(%esp)
f0101bbb:	e8 2a 1e 00 00       	call   f01039ea <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101bc0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bc7:	e8 11 f6 ff ff       	call   f01011dd <page_alloc>
f0101bcc:	89 c6                	mov    %eax,%esi
f0101bce:	85 c0                	test   %eax,%eax
f0101bd0:	75 24                	jne    f0101bf6 <mem_init+0x6b9>
f0101bd2:	c7 44 24 0c 33 57 10 	movl   $0xf0105733,0xc(%esp)
f0101bd9:	f0 
f0101bda:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101be1:	f0 
f0101be2:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0101be9:	00 
f0101bea:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101bf1:	e8 20 e5 ff ff       	call   f0100116 <_panic>
	assert((pp1 = page_alloc(0)));
f0101bf6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bfd:	e8 db f5 ff ff       	call   f01011dd <page_alloc>
f0101c02:	89 c7                	mov    %eax,%edi
f0101c04:	85 c0                	test   %eax,%eax
f0101c06:	75 24                	jne    f0101c2c <mem_init+0x6ef>
f0101c08:	c7 44 24 0c 49 57 10 	movl   $0xf0105749,0xc(%esp)
f0101c0f:	f0 
f0101c10:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101c17:	f0 
f0101c18:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f0101c1f:	00 
f0101c20:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101c27:	e8 ea e4 ff ff       	call   f0100116 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c33:	e8 a5 f5 ff ff       	call   f01011dd <page_alloc>
f0101c38:	89 c3                	mov    %eax,%ebx
f0101c3a:	85 c0                	test   %eax,%eax
f0101c3c:	75 24                	jne    f0101c62 <mem_init+0x725>
f0101c3e:	c7 44 24 0c 5f 57 10 	movl   $0xf010575f,0xc(%esp)
f0101c45:	f0 
f0101c46:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101c4d:	f0 
f0101c4e:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0101c55:	00 
f0101c56:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101c5d:	e8 b4 e4 ff ff       	call   f0100116 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c62:	39 fe                	cmp    %edi,%esi
f0101c64:	75 24                	jne    f0101c8a <mem_init+0x74d>
f0101c66:	c7 44 24 0c 75 57 10 	movl   $0xf0105775,0xc(%esp)
f0101c6d:	f0 
f0101c6e:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101c75:	f0 
f0101c76:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f0101c7d:	00 
f0101c7e:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101c85:	e8 8c e4 ff ff       	call   f0100116 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c8a:	39 c7                	cmp    %eax,%edi
f0101c8c:	74 04                	je     f0101c92 <mem_init+0x755>
f0101c8e:	39 c6                	cmp    %eax,%esi
f0101c90:	75 24                	jne    f0101cb6 <mem_init+0x779>
f0101c92:	c7 44 24 0c 24 5b 10 	movl   $0xf0105b24,0xc(%esp)
f0101c99:	f0 
f0101c9a:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101ca1:	f0 
f0101ca2:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f0101ca9:	00 
f0101caa:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101cb1:	e8 60 e4 ff ff       	call   f0100116 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101cb6:	a1 8c f1 17 f0       	mov    0xf017f18c,%eax
f0101cbb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	page_free_list = 0;
f0101cbe:	c7 05 8c f1 17 f0 00 	movl   $0x0,0xf017f18c
f0101cc5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101cc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ccf:	e8 09 f5 ff ff       	call   f01011dd <page_alloc>
f0101cd4:	85 c0                	test   %eax,%eax
f0101cd6:	74 24                	je     f0101cfc <mem_init+0x7bf>
f0101cd8:	c7 44 24 0c de 57 10 	movl   $0xf01057de,0xc(%esp)
f0101cdf:	f0 
f0101ce0:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101ce7:	f0 
f0101ce8:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f0101cef:	00 
f0101cf0:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101cf7:	e8 1a e4 ff ff       	call   f0100116 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101cfc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101cff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101d03:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101d0a:	00 
f0101d0b:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0101d10:	89 04 24             	mov    %eax,(%esp)
f0101d13:	e8 cd f6 ff ff       	call   f01013e5 <page_lookup>
f0101d18:	85 c0                	test   %eax,%eax
f0101d1a:	74 24                	je     f0101d40 <mem_init+0x803>
f0101d1c:	c7 44 24 0c 64 5b 10 	movl   $0xf0105b64,0xc(%esp)
f0101d23:	f0 
f0101d24:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101d2b:	f0 
f0101d2c:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f0101d33:	00 
f0101d34:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101d3b:	e8 d6 e3 ff ff       	call   f0100116 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d40:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d47:	00 
f0101d48:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d4f:	00 
f0101d50:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101d54:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0101d59:	89 04 24             	mov    %eax,(%esp)
f0101d5c:	e8 60 f7 ff ff       	call   f01014c1 <page_insert>
f0101d61:	85 c0                	test   %eax,%eax
f0101d63:	78 24                	js     f0101d89 <mem_init+0x84c>
f0101d65:	c7 44 24 0c 9c 5b 10 	movl   $0xf0105b9c,0xc(%esp)
f0101d6c:	f0 
f0101d6d:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101d74:	f0 
f0101d75:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101d7c:	00 
f0101d7d:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101d84:	e8 8d e3 ff ff       	call   f0100116 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d89:	89 34 24             	mov    %esi,(%esp)
f0101d8c:	e8 ca f4 ff ff       	call   f010125b <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d91:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d98:	00 
f0101d99:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101da0:	00 
f0101da1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101da5:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0101daa:	89 04 24             	mov    %eax,(%esp)
f0101dad:	e8 0f f7 ff ff       	call   f01014c1 <page_insert>
f0101db2:	85 c0                	test   %eax,%eax
f0101db4:	74 24                	je     f0101dda <mem_init+0x89d>
f0101db6:	c7 44 24 0c cc 5b 10 	movl   $0xf0105bcc,0xc(%esp)
f0101dbd:	f0 
f0101dbe:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101dc5:	f0 
f0101dc6:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f0101dcd:	00 
f0101dce:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101dd5:	e8 3c e3 ff ff       	call   f0100116 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101dda:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0101ddf:	8b 08                	mov    (%eax),%ecx
f0101de1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101de7:	89 f2                	mov    %esi,%edx
f0101de9:	2b 15 70 fe 17 f0    	sub    0xf017fe70,%edx
f0101def:	c1 fa 03             	sar    $0x3,%edx
f0101df2:	c1 e2 0c             	shl    $0xc,%edx
f0101df5:	39 d1                	cmp    %edx,%ecx
f0101df7:	74 24                	je     f0101e1d <mem_init+0x8e0>
f0101df9:	c7 44 24 0c fc 5b 10 	movl   $0xf0105bfc,0xc(%esp)
f0101e00:	f0 
f0101e01:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101e08:	f0 
f0101e09:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f0101e10:	00 
f0101e11:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101e18:	e8 f9 e2 ff ff       	call   f0100116 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101e1d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e22:	e8 d6 ee ff ff       	call   f0100cfd <check_va2pa>
f0101e27:	89 fa                	mov    %edi,%edx
f0101e29:	2b 15 70 fe 17 f0    	sub    0xf017fe70,%edx
f0101e2f:	c1 fa 03             	sar    $0x3,%edx
f0101e32:	c1 e2 0c             	shl    $0xc,%edx
f0101e35:	39 d0                	cmp    %edx,%eax
f0101e37:	74 24                	je     f0101e5d <mem_init+0x920>
f0101e39:	c7 44 24 0c 24 5c 10 	movl   $0xf0105c24,0xc(%esp)
f0101e40:	f0 
f0101e41:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101e48:	f0 
f0101e49:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f0101e50:	00 
f0101e51:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101e58:	e8 b9 e2 ff ff       	call   f0100116 <_panic>
	assert(pp1->pp_ref == 1);
f0101e5d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e62:	74 24                	je     f0101e88 <mem_init+0x94b>
f0101e64:	c7 44 24 0c 40 58 10 	movl   $0xf0105840,0xc(%esp)
f0101e6b:	f0 
f0101e6c:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101e73:	f0 
f0101e74:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0101e7b:	00 
f0101e7c:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101e83:	e8 8e e2 ff ff       	call   f0100116 <_panic>
	assert(pp0->pp_ref == 1);
f0101e88:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e8d:	74 24                	je     f0101eb3 <mem_init+0x976>
f0101e8f:	c7 44 24 0c 51 58 10 	movl   $0xf0105851,0xc(%esp)
f0101e96:	f0 
f0101e97:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101e9e:	f0 
f0101e9f:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f0101ea6:	00 
f0101ea7:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101eae:	e8 63 e2 ff ff       	call   f0100116 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101eb3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101eba:	00 
f0101ebb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ec2:	00 
f0101ec3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ec7:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0101ecc:	89 04 24             	mov    %eax,(%esp)
f0101ecf:	e8 ed f5 ff ff       	call   f01014c1 <page_insert>
f0101ed4:	85 c0                	test   %eax,%eax
f0101ed6:	74 24                	je     f0101efc <mem_init+0x9bf>
f0101ed8:	c7 44 24 0c 54 5c 10 	movl   $0xf0105c54,0xc(%esp)
f0101edf:	f0 
f0101ee0:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101ee7:	f0 
f0101ee8:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0101eef:	00 
f0101ef0:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101ef7:	e8 1a e2 ff ff       	call   f0100116 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101efc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f01:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0101f06:	e8 f2 ed ff ff       	call   f0100cfd <check_va2pa>
f0101f0b:	89 da                	mov    %ebx,%edx
f0101f0d:	2b 15 70 fe 17 f0    	sub    0xf017fe70,%edx
f0101f13:	c1 fa 03             	sar    $0x3,%edx
f0101f16:	c1 e2 0c             	shl    $0xc,%edx
f0101f19:	39 d0                	cmp    %edx,%eax
f0101f1b:	74 24                	je     f0101f41 <mem_init+0xa04>
f0101f1d:	c7 44 24 0c 90 5c 10 	movl   $0xf0105c90,0xc(%esp)
f0101f24:	f0 
f0101f25:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101f2c:	f0 
f0101f2d:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0101f34:	00 
f0101f35:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101f3c:	e8 d5 e1 ff ff       	call   f0100116 <_panic>
	assert(pp2->pp_ref == 1);
f0101f41:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f46:	74 24                	je     f0101f6c <mem_init+0xa2f>
f0101f48:	c7 44 24 0c 62 58 10 	movl   $0xf0105862,0xc(%esp)
f0101f4f:	f0 
f0101f50:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101f57:	f0 
f0101f58:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0101f5f:	00 
f0101f60:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101f67:	e8 aa e1 ff ff       	call   f0100116 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f73:	e8 65 f2 ff ff       	call   f01011dd <page_alloc>
f0101f78:	85 c0                	test   %eax,%eax
f0101f7a:	74 24                	je     f0101fa0 <mem_init+0xa63>
f0101f7c:	c7 44 24 0c de 57 10 	movl   $0xf01057de,0xc(%esp)
f0101f83:	f0 
f0101f84:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101f8b:	f0 
f0101f8c:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f0101f93:	00 
f0101f94:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101f9b:	e8 76 e1 ff ff       	call   f0100116 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101fa0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101fa7:	00 
f0101fa8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101faf:	00 
f0101fb0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101fb4:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0101fb9:	89 04 24             	mov    %eax,(%esp)
f0101fbc:	e8 00 f5 ff ff       	call   f01014c1 <page_insert>
f0101fc1:	85 c0                	test   %eax,%eax
f0101fc3:	74 24                	je     f0101fe9 <mem_init+0xaac>
f0101fc5:	c7 44 24 0c 54 5c 10 	movl   $0xf0105c54,0xc(%esp)
f0101fcc:	f0 
f0101fcd:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0101fd4:	f0 
f0101fd5:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0101fdc:	00 
f0101fdd:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0101fe4:	e8 2d e1 ff ff       	call   f0100116 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fe9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fee:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0101ff3:	e8 05 ed ff ff       	call   f0100cfd <check_va2pa>
f0101ff8:	89 da                	mov    %ebx,%edx
f0101ffa:	2b 15 70 fe 17 f0    	sub    0xf017fe70,%edx
f0102000:	c1 fa 03             	sar    $0x3,%edx
f0102003:	c1 e2 0c             	shl    $0xc,%edx
f0102006:	39 d0                	cmp    %edx,%eax
f0102008:	74 24                	je     f010202e <mem_init+0xaf1>
f010200a:	c7 44 24 0c 90 5c 10 	movl   $0xf0105c90,0xc(%esp)
f0102011:	f0 
f0102012:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102019:	f0 
f010201a:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0102021:	00 
f0102022:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102029:	e8 e8 e0 ff ff       	call   f0100116 <_panic>
	assert(pp2->pp_ref == 1);
f010202e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102033:	74 24                	je     f0102059 <mem_init+0xb1c>
f0102035:	c7 44 24 0c 62 58 10 	movl   $0xf0105862,0xc(%esp)
f010203c:	f0 
f010203d:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102044:	f0 
f0102045:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f010204c:	00 
f010204d:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102054:	e8 bd e0 ff ff       	call   f0100116 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102059:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102060:	e8 78 f1 ff ff       	call   f01011dd <page_alloc>
f0102065:	85 c0                	test   %eax,%eax
f0102067:	74 24                	je     f010208d <mem_init+0xb50>
f0102069:	c7 44 24 0c de 57 10 	movl   $0xf01057de,0xc(%esp)
f0102070:	f0 
f0102071:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102078:	f0 
f0102079:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0102080:	00 
f0102081:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102088:	e8 89 e0 ff ff       	call   f0100116 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010208d:	8b 15 6c fe 17 f0    	mov    0xf017fe6c,%edx
f0102093:	8b 02                	mov    (%edx),%eax
f0102095:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010209a:	89 c1                	mov    %eax,%ecx
f010209c:	c1 e9 0c             	shr    $0xc,%ecx
f010209f:	3b 0d 68 fe 17 f0    	cmp    0xf017fe68,%ecx
f01020a5:	72 20                	jb     f01020c7 <mem_init+0xb8a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01020ab:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f01020b2:	f0 
f01020b3:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f01020ba:	00 
f01020bb:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01020c2:	e8 4f e0 ff ff       	call   f0100116 <_panic>
	return (void *)(pa + KERNBASE);
f01020c7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01020cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020d6:	00 
f01020d7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020de:	00 
f01020df:	89 14 24             	mov    %edx,(%esp)
f01020e2:	e8 ac f1 ff ff       	call   f0101293 <pgdir_walk>
f01020e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01020ea:	83 c2 04             	add    $0x4,%edx
f01020ed:	39 d0                	cmp    %edx,%eax
f01020ef:	74 24                	je     f0102115 <mem_init+0xbd8>
f01020f1:	c7 44 24 0c c0 5c 10 	movl   $0xf0105cc0,0xc(%esp)
f01020f8:	f0 
f01020f9:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102100:	f0 
f0102101:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0102108:	00 
f0102109:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102110:	e8 01 e0 ff ff       	call   f0100116 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102115:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010211c:	00 
f010211d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102124:	00 
f0102125:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102129:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f010212e:	89 04 24             	mov    %eax,(%esp)
f0102131:	e8 8b f3 ff ff       	call   f01014c1 <page_insert>
f0102136:	85 c0                	test   %eax,%eax
f0102138:	74 24                	je     f010215e <mem_init+0xc21>
f010213a:	c7 44 24 0c 00 5d 10 	movl   $0xf0105d00,0xc(%esp)
f0102141:	f0 
f0102142:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102149:	f0 
f010214a:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0102151:	00 
f0102152:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102159:	e8 b8 df ff ff       	call   f0100116 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010215e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102163:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102168:	e8 90 eb ff ff       	call   f0100cfd <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010216d:	89 da                	mov    %ebx,%edx
f010216f:	2b 15 70 fe 17 f0    	sub    0xf017fe70,%edx
f0102175:	c1 fa 03             	sar    $0x3,%edx
f0102178:	c1 e2 0c             	shl    $0xc,%edx
f010217b:	39 d0                	cmp    %edx,%eax
f010217d:	74 24                	je     f01021a3 <mem_init+0xc66>
f010217f:	c7 44 24 0c 90 5c 10 	movl   $0xf0105c90,0xc(%esp)
f0102186:	f0 
f0102187:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f010218e:	f0 
f010218f:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0102196:	00 
f0102197:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f010219e:	e8 73 df ff ff       	call   f0100116 <_panic>
	assert(pp2->pp_ref == 1);
f01021a3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01021a8:	74 24                	je     f01021ce <mem_init+0xc91>
f01021aa:	c7 44 24 0c 62 58 10 	movl   $0xf0105862,0xc(%esp)
f01021b1:	f0 
f01021b2:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01021b9:	f0 
f01021ba:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f01021c1:	00 
f01021c2:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01021c9:	e8 48 df ff ff       	call   f0100116 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01021ce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021d5:	00 
f01021d6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021dd:	00 
f01021de:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f01021e3:	89 04 24             	mov    %eax,(%esp)
f01021e6:	e8 a8 f0 ff ff       	call   f0101293 <pgdir_walk>
f01021eb:	f6 00 04             	testb  $0x4,(%eax)
f01021ee:	75 24                	jne    f0102214 <mem_init+0xcd7>
f01021f0:	c7 44 24 0c 40 5d 10 	movl   $0xf0105d40,0xc(%esp)
f01021f7:	f0 
f01021f8:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01021ff:	f0 
f0102200:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0102207:	00 
f0102208:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f010220f:	e8 02 df ff ff       	call   f0100116 <_panic>
	cprintf("pp2 %x\n", pp2);
f0102214:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102218:	c7 04 24 73 58 10 f0 	movl   $0xf0105873,(%esp)
f010221f:	e8 c6 17 00 00       	call   f01039ea <cprintf>
	cprintf("kern_pgdir %x\n", kern_pgdir);
f0102224:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102229:	89 44 24 04          	mov    %eax,0x4(%esp)
f010222d:	c7 04 24 7b 58 10 f0 	movl   $0xf010587b,(%esp)
f0102234:	e8 b1 17 00 00       	call   f01039ea <cprintf>
	cprintf("kern_pgdir[0] is %x\n", kern_pgdir[0]);
f0102239:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f010223e:	8b 00                	mov    (%eax),%eax
f0102240:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102244:	c7 04 24 8a 58 10 f0 	movl   $0xf010588a,(%esp)
f010224b:	e8 9a 17 00 00       	call   f01039ea <cprintf>
	assert(kern_pgdir[0] & PTE_U);
f0102250:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102255:	f6 00 04             	testb  $0x4,(%eax)
f0102258:	75 24                	jne    f010227e <mem_init+0xd41>
f010225a:	c7 44 24 0c 9f 58 10 	movl   $0xf010589f,0xc(%esp)
f0102261:	f0 
f0102262:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102269:	f0 
f010226a:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102271:	00 
f0102272:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102279:	e8 98 de ff ff       	call   f0100116 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010227e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102285:	00 
f0102286:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010228d:	00 
f010228e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102292:	89 04 24             	mov    %eax,(%esp)
f0102295:	e8 27 f2 ff ff       	call   f01014c1 <page_insert>
f010229a:	85 c0                	test   %eax,%eax
f010229c:	74 24                	je     f01022c2 <mem_init+0xd85>
f010229e:	c7 44 24 0c 54 5c 10 	movl   $0xf0105c54,0xc(%esp)
f01022a5:	f0 
f01022a6:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01022ad:	f0 
f01022ae:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f01022b5:	00 
f01022b6:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01022bd:	e8 54 de ff ff       	call   f0100116 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01022c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022c9:	00 
f01022ca:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022d1:	00 
f01022d2:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f01022d7:	89 04 24             	mov    %eax,(%esp)
f01022da:	e8 b4 ef ff ff       	call   f0101293 <pgdir_walk>
f01022df:	f6 00 02             	testb  $0x2,(%eax)
f01022e2:	75 24                	jne    f0102308 <mem_init+0xdcb>
f01022e4:	c7 44 24 0c 74 5d 10 	movl   $0xf0105d74,0xc(%esp)
f01022eb:	f0 
f01022ec:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01022f3:	f0 
f01022f4:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f01022fb:	00 
f01022fc:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102303:	e8 0e de ff ff       	call   f0100116 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102308:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010230f:	00 
f0102310:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102317:	00 
f0102318:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f010231d:	89 04 24             	mov    %eax,(%esp)
f0102320:	e8 6e ef ff ff       	call   f0101293 <pgdir_walk>
f0102325:	f6 00 04             	testb  $0x4,(%eax)
f0102328:	74 24                	je     f010234e <mem_init+0xe11>
f010232a:	c7 44 24 0c a8 5d 10 	movl   $0xf0105da8,0xc(%esp)
f0102331:	f0 
f0102332:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102339:	f0 
f010233a:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0102341:	00 
f0102342:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102349:	e8 c8 dd ff ff       	call   f0100116 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010234e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102355:	00 
f0102356:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010235d:	00 
f010235e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102362:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102367:	89 04 24             	mov    %eax,(%esp)
f010236a:	e8 52 f1 ff ff       	call   f01014c1 <page_insert>
f010236f:	85 c0                	test   %eax,%eax
f0102371:	78 24                	js     f0102397 <mem_init+0xe5a>
f0102373:	c7 44 24 0c e0 5d 10 	movl   $0xf0105de0,0xc(%esp)
f010237a:	f0 
f010237b:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102382:	f0 
f0102383:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f010238a:	00 
f010238b:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102392:	e8 7f dd ff ff       	call   f0100116 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102397:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010239e:	00 
f010239f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023a6:	00 
f01023a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01023ab:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f01023b0:	89 04 24             	mov    %eax,(%esp)
f01023b3:	e8 09 f1 ff ff       	call   f01014c1 <page_insert>
f01023b8:	85 c0                	test   %eax,%eax
f01023ba:	74 24                	je     f01023e0 <mem_init+0xea3>
f01023bc:	c7 44 24 0c 18 5e 10 	movl   $0xf0105e18,0xc(%esp)
f01023c3:	f0 
f01023c4:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01023cb:	f0 
f01023cc:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f01023d3:	00 
f01023d4:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01023db:	e8 36 dd ff ff       	call   f0100116 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01023e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023e7:	00 
f01023e8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023ef:	00 
f01023f0:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f01023f5:	89 04 24             	mov    %eax,(%esp)
f01023f8:	e8 96 ee ff ff       	call   f0101293 <pgdir_walk>
f01023fd:	f6 00 04             	testb  $0x4,(%eax)
f0102400:	74 24                	je     f0102426 <mem_init+0xee9>
f0102402:	c7 44 24 0c a8 5d 10 	movl   $0xf0105da8,0xc(%esp)
f0102409:	f0 
f010240a:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102411:	f0 
f0102412:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0102419:	00 
f010241a:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102421:	e8 f0 dc ff ff       	call   f0100116 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102426:	ba 00 00 00 00       	mov    $0x0,%edx
f010242b:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102430:	e8 c8 e8 ff ff       	call   f0100cfd <check_va2pa>
f0102435:	89 fa                	mov    %edi,%edx
f0102437:	2b 15 70 fe 17 f0    	sub    0xf017fe70,%edx
f010243d:	c1 fa 03             	sar    $0x3,%edx
f0102440:	c1 e2 0c             	shl    $0xc,%edx
f0102443:	39 d0                	cmp    %edx,%eax
f0102445:	74 24                	je     f010246b <mem_init+0xf2e>
f0102447:	c7 44 24 0c 54 5e 10 	movl   $0xf0105e54,0xc(%esp)
f010244e:	f0 
f010244f:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102456:	f0 
f0102457:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f010245e:	00 
f010245f:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102466:	e8 ab dc ff ff       	call   f0100116 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010246b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102470:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102475:	e8 83 e8 ff ff       	call   f0100cfd <check_va2pa>
f010247a:	89 fa                	mov    %edi,%edx
f010247c:	2b 15 70 fe 17 f0    	sub    0xf017fe70,%edx
f0102482:	c1 fa 03             	sar    $0x3,%edx
f0102485:	c1 e2 0c             	shl    $0xc,%edx
f0102488:	39 d0                	cmp    %edx,%eax
f010248a:	74 24                	je     f01024b0 <mem_init+0xf73>
f010248c:	c7 44 24 0c 80 5e 10 	movl   $0xf0105e80,0xc(%esp)
f0102493:	f0 
f0102494:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f010249b:	f0 
f010249c:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f01024a3:	00 
f01024a4:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01024ab:	e8 66 dc ff ff       	call   f0100116 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01024b0:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f01024b5:	74 24                	je     f01024db <mem_init+0xf9e>
f01024b7:	c7 44 24 0c b5 58 10 	movl   $0xf01058b5,0xc(%esp)
f01024be:	f0 
f01024bf:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01024c6:	f0 
f01024c7:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f01024ce:	00 
f01024cf:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01024d6:	e8 3b dc ff ff       	call   f0100116 <_panic>
	assert(pp2->pp_ref == 0);
f01024db:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024e0:	74 24                	je     f0102506 <mem_init+0xfc9>
f01024e2:	c7 44 24 0c c6 58 10 	movl   $0xf01058c6,0xc(%esp)
f01024e9:	f0 
f01024ea:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01024f1:	f0 
f01024f2:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f01024f9:	00 
f01024fa:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102501:	e8 10 dc ff ff       	call   f0100116 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102506:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010250d:	e8 cb ec ff ff       	call   f01011dd <page_alloc>
f0102512:	85 c0                	test   %eax,%eax
f0102514:	74 04                	je     f010251a <mem_init+0xfdd>
f0102516:	39 c3                	cmp    %eax,%ebx
f0102518:	74 24                	je     f010253e <mem_init+0x1001>
f010251a:	c7 44 24 0c b0 5e 10 	movl   $0xf0105eb0,0xc(%esp)
f0102521:	f0 
f0102522:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102529:	f0 
f010252a:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0102531:	00 
f0102532:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102539:	e8 d8 db ff ff       	call   f0100116 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010253e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102545:	00 
f0102546:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f010254b:	89 04 24             	mov    %eax,(%esp)
f010254e:	e8 16 ef ff ff       	call   f0101469 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102553:	ba 00 00 00 00       	mov    $0x0,%edx
f0102558:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f010255d:	e8 9b e7 ff ff       	call   f0100cfd <check_va2pa>
f0102562:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102565:	74 24                	je     f010258b <mem_init+0x104e>
f0102567:	c7 44 24 0c d4 5e 10 	movl   $0xf0105ed4,0xc(%esp)
f010256e:	f0 
f010256f:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102576:	f0 
f0102577:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f010257e:	00 
f010257f:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102586:	e8 8b db ff ff       	call   f0100116 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010258b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102590:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102595:	e8 63 e7 ff ff       	call   f0100cfd <check_va2pa>
f010259a:	89 fa                	mov    %edi,%edx
f010259c:	2b 15 70 fe 17 f0    	sub    0xf017fe70,%edx
f01025a2:	c1 fa 03             	sar    $0x3,%edx
f01025a5:	c1 e2 0c             	shl    $0xc,%edx
f01025a8:	39 d0                	cmp    %edx,%eax
f01025aa:	74 24                	je     f01025d0 <mem_init+0x1093>
f01025ac:	c7 44 24 0c 80 5e 10 	movl   $0xf0105e80,0xc(%esp)
f01025b3:	f0 
f01025b4:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01025bb:	f0 
f01025bc:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f01025c3:	00 
f01025c4:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01025cb:	e8 46 db ff ff       	call   f0100116 <_panic>
	assert(pp1->pp_ref == 1);
f01025d0:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025d5:	74 24                	je     f01025fb <mem_init+0x10be>
f01025d7:	c7 44 24 0c 40 58 10 	movl   $0xf0105840,0xc(%esp)
f01025de:	f0 
f01025df:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01025e6:	f0 
f01025e7:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f01025ee:	00 
f01025ef:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01025f6:	e8 1b db ff ff       	call   f0100116 <_panic>
	assert(pp2->pp_ref == 0);
f01025fb:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102600:	74 24                	je     f0102626 <mem_init+0x10e9>
f0102602:	c7 44 24 0c c6 58 10 	movl   $0xf01058c6,0xc(%esp)
f0102609:	f0 
f010260a:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102611:	f0 
f0102612:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102619:	00 
f010261a:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102621:	e8 f0 da ff ff       	call   f0100116 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102626:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010262d:	00 
f010262e:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102633:	89 04 24             	mov    %eax,(%esp)
f0102636:	e8 2e ee ff ff       	call   f0101469 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010263b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102640:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102645:	e8 b3 e6 ff ff       	call   f0100cfd <check_va2pa>
f010264a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010264d:	74 24                	je     f0102673 <mem_init+0x1136>
f010264f:	c7 44 24 0c d4 5e 10 	movl   $0xf0105ed4,0xc(%esp)
f0102656:	f0 
f0102657:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f010265e:	f0 
f010265f:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0102666:	00 
f0102667:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f010266e:	e8 a3 da ff ff       	call   f0100116 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102673:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102678:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f010267d:	e8 7b e6 ff ff       	call   f0100cfd <check_va2pa>
f0102682:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102685:	74 24                	je     f01026ab <mem_init+0x116e>
f0102687:	c7 44 24 0c f8 5e 10 	movl   $0xf0105ef8,0xc(%esp)
f010268e:	f0 
f010268f:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102696:	f0 
f0102697:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f010269e:	00 
f010269f:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01026a6:	e8 6b da ff ff       	call   f0100116 <_panic>
	assert(pp1->pp_ref == 0);
f01026ab:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01026b0:	74 24                	je     f01026d6 <mem_init+0x1199>
f01026b2:	c7 44 24 0c d7 58 10 	movl   $0xf01058d7,0xc(%esp)
f01026b9:	f0 
f01026ba:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01026c1:	f0 
f01026c2:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f01026c9:	00 
f01026ca:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01026d1:	e8 40 da ff ff       	call   f0100116 <_panic>
	assert(pp2->pp_ref == 0);
f01026d6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01026db:	74 24                	je     f0102701 <mem_init+0x11c4>
f01026dd:	c7 44 24 0c c6 58 10 	movl   $0xf01058c6,0xc(%esp)
f01026e4:	f0 
f01026e5:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01026ec:	f0 
f01026ed:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f01026f4:	00 
f01026f5:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01026fc:	e8 15 da ff ff       	call   f0100116 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102701:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102708:	e8 d0 ea ff ff       	call   f01011dd <page_alloc>
f010270d:	85 c0                	test   %eax,%eax
f010270f:	74 04                	je     f0102715 <mem_init+0x11d8>
f0102711:	39 c7                	cmp    %eax,%edi
f0102713:	74 24                	je     f0102739 <mem_init+0x11fc>
f0102715:	c7 44 24 0c 20 5f 10 	movl   $0xf0105f20,0xc(%esp)
f010271c:	f0 
f010271d:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102724:	f0 
f0102725:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f010272c:	00 
f010272d:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102734:	e8 dd d9 ff ff       	call   f0100116 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102739:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102740:	e8 98 ea ff ff       	call   f01011dd <page_alloc>
f0102745:	85 c0                	test   %eax,%eax
f0102747:	74 24                	je     f010276d <mem_init+0x1230>
f0102749:	c7 44 24 0c de 57 10 	movl   $0xf01057de,0xc(%esp)
f0102750:	f0 
f0102751:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102758:	f0 
f0102759:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0102760:	00 
f0102761:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102768:	e8 a9 d9 ff ff       	call   f0100116 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010276d:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102772:	8b 08                	mov    (%eax),%ecx
f0102774:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010277a:	89 f2                	mov    %esi,%edx
f010277c:	2b 15 70 fe 17 f0    	sub    0xf017fe70,%edx
f0102782:	c1 fa 03             	sar    $0x3,%edx
f0102785:	c1 e2 0c             	shl    $0xc,%edx
f0102788:	39 d1                	cmp    %edx,%ecx
f010278a:	74 24                	je     f01027b0 <mem_init+0x1273>
f010278c:	c7 44 24 0c fc 5b 10 	movl   $0xf0105bfc,0xc(%esp)
f0102793:	f0 
f0102794:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f010279b:	f0 
f010279c:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f01027a3:	00 
f01027a4:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01027ab:	e8 66 d9 ff ff       	call   f0100116 <_panic>
	kern_pgdir[0] = 0;
f01027b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01027b6:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01027bb:	74 24                	je     f01027e1 <mem_init+0x12a4>
f01027bd:	c7 44 24 0c 51 58 10 	movl   $0xf0105851,0xc(%esp)
f01027c4:	f0 
f01027c5:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01027cc:	f0 
f01027cd:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f01027d4:	00 
f01027d5:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01027dc:	e8 35 d9 ff ff       	call   f0100116 <_panic>
	pp0->pp_ref = 0;
f01027e1:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01027e7:	89 34 24             	mov    %esi,(%esp)
f01027ea:	e8 6c ea ff ff       	call   f010125b <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01027ef:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01027f6:	00 
f01027f7:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01027fe:	00 
f01027ff:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102804:	89 04 24             	mov    %eax,(%esp)
f0102807:	e8 87 ea ff ff       	call   f0101293 <pgdir_walk>
f010280c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010280f:	8b 0d 6c fe 17 f0    	mov    0xf017fe6c,%ecx
f0102815:	8b 51 04             	mov    0x4(%ecx),%edx
f0102818:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010281e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102821:	c1 ea 0c             	shr    $0xc,%edx
f0102824:	3b 15 68 fe 17 f0    	cmp    0xf017fe68,%edx
f010282a:	72 23                	jb     f010284f <mem_init+0x1312>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010282c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010282f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102833:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f010283a:	f0 
f010283b:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0102842:	00 
f0102843:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f010284a:	e8 c7 d8 ff ff       	call   f0100116 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010284f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102852:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102858:	39 d0                	cmp    %edx,%eax
f010285a:	74 24                	je     f0102880 <mem_init+0x1343>
f010285c:	c7 44 24 0c e8 58 10 	movl   $0xf01058e8,0xc(%esp)
f0102863:	f0 
f0102864:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f010286b:	f0 
f010286c:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0102873:	00 
f0102874:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f010287b:	e8 96 d8 ff ff       	call   f0100116 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102880:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102887:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010288d:	89 f0                	mov    %esi,%eax
f010288f:	2b 05 70 fe 17 f0    	sub    0xf017fe70,%eax
f0102895:	c1 f8 03             	sar    $0x3,%eax
f0102898:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010289b:	89 c2                	mov    %eax,%edx
f010289d:	c1 ea 0c             	shr    $0xc,%edx
f01028a0:	3b 15 68 fe 17 f0    	cmp    0xf017fe68,%edx
f01028a6:	72 20                	jb     f01028c8 <mem_init+0x138b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028ac:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f01028b3:	f0 
f01028b4:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01028bb:	00 
f01028bc:	c7 04 24 20 56 10 f0 	movl   $0xf0105620,(%esp)
f01028c3:	e8 4e d8 ff ff       	call   f0100116 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01028c8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01028cf:	00 
f01028d0:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01028d7:	00 
	return (void *)(pa + KERNBASE);
f01028d8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01028dd:	89 04 24             	mov    %eax,(%esp)
f01028e0:	e8 8c 21 00 00       	call   f0104a71 <memset>
	page_free(pp0);
f01028e5:	89 34 24             	mov    %esi,(%esp)
f01028e8:	e8 6e e9 ff ff       	call   f010125b <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01028ed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01028f4:	00 
f01028f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01028fc:	00 
f01028fd:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102902:	89 04 24             	mov    %eax,(%esp)
f0102905:	e8 89 e9 ff ff       	call   f0101293 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010290a:	89 f2                	mov    %esi,%edx
f010290c:	2b 15 70 fe 17 f0    	sub    0xf017fe70,%edx
f0102912:	c1 fa 03             	sar    $0x3,%edx
f0102915:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102918:	89 d0                	mov    %edx,%eax
f010291a:	c1 e8 0c             	shr    $0xc,%eax
f010291d:	3b 05 68 fe 17 f0    	cmp    0xf017fe68,%eax
f0102923:	72 20                	jb     f0102945 <mem_init+0x1408>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102925:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102929:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f0102930:	f0 
f0102931:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102938:	00 
f0102939:	c7 04 24 20 56 10 f0 	movl   $0xf0105620,(%esp)
f0102940:	e8 d1 d7 ff ff       	call   f0100116 <_panic>
	return (void *)(pa + KERNBASE);
f0102945:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010294b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010294e:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102955:	75 11                	jne    f0102968 <mem_init+0x142b>
f0102957:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010295d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102963:	f6 00 01             	testb  $0x1,(%eax)
f0102966:	74 24                	je     f010298c <mem_init+0x144f>
f0102968:	c7 44 24 0c 00 59 10 	movl   $0xf0105900,0xc(%esp)
f010296f:	f0 
f0102970:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102977:	f0 
f0102978:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f010297f:	00 
f0102980:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102987:	e8 8a d7 ff ff       	call   f0100116 <_panic>
f010298c:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010298f:	39 d0                	cmp    %edx,%eax
f0102991:	75 d0                	jne    f0102963 <mem_init+0x1426>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102993:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102998:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010299e:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f01029a4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01029a7:	89 0d 8c f1 17 f0    	mov    %ecx,0xf017f18c

	// free the pages we took
	page_free(pp0);
f01029ad:	89 34 24             	mov    %esi,(%esp)
f01029b0:	e8 a6 e8 ff ff       	call   f010125b <page_free>
	page_free(pp1);
f01029b5:	89 3c 24             	mov    %edi,(%esp)
f01029b8:	e8 9e e8 ff ff       	call   f010125b <page_free>
	page_free(pp2);
f01029bd:	89 1c 24             	mov    %ebx,(%esp)
f01029c0:	e8 96 e8 ff ff       	call   f010125b <page_free>

	cprintf("check_page() succeeded!\n");
f01029c5:	c7 04 24 17 59 10 f0 	movl   $0xf0105917,(%esp)
f01029cc:	e8 19 10 00 00       	call   f01039ea <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f01029d1:	a1 70 fe 17 f0       	mov    0xf017fe70,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029d6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029db:	77 20                	ja     f01029fd <mem_init+0x14c0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029e1:	c7 44 24 08 00 5b 10 	movl   $0xf0105b00,0x8(%esp)
f01029e8:	f0 
f01029e9:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
f01029f0:	00 
f01029f1:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01029f8:	e8 19 d7 ff ff       	call   f0100116 <_panic>
f01029fd:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102a04:	00 
	return (physaddr_t)kva - KERNBASE;
f0102a05:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a0a:	89 04 24             	mov    %eax,(%esp)
f0102a0d:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102a12:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102a17:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102a1c:	e8 17 e9 ff ff       	call   f0101338 <boot_map_region>
		UPAGES, 
		PTSIZE, 
		PADDR(pages), 
		PTE_U);
	cprintf("PADDR(pages) %x\n", PADDR(pages));
f0102a21:	a1 70 fe 17 f0       	mov    0xf017fe70,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a26:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a2b:	77 20                	ja     f0102a4d <mem_init+0x1510>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a31:	c7 44 24 08 00 5b 10 	movl   $0xf0105b00,0x8(%esp)
f0102a38:	f0 
f0102a39:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f0102a40:	00 
f0102a41:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102a48:	e8 c9 d6 ff ff       	call   f0100116 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102a4d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a52:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102a56:	c7 04 24 30 59 10 f0 	movl   $0xf0105930,(%esp)
f0102a5d:	e8 88 0f 00 00       	call   f01039ea <cprintf>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,
f0102a62:	a1 98 f1 17 f0       	mov    0xf017f198,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a67:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a6c:	77 20                	ja     f0102a8e <mem_init+0x1551>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a72:	c7 44 24 08 00 5b 10 	movl   $0xf0105b00,0x8(%esp)
f0102a79:	f0 
f0102a7a:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
f0102a81:	00 
f0102a82:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102a89:	e8 88 d6 ff ff       	call   f0100116 <_panic>
f0102a8e:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102a95:	00 
	return (physaddr_t)kva - KERNBASE;
f0102a96:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a9b:	89 04 24             	mov    %eax,(%esp)
f0102a9e:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102aa3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102aa8:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102aad:	e8 86 e8 ff ff       	call   f0101338 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ab2:	be 00 20 11 f0       	mov    $0xf0112000,%esi
f0102ab7:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102abd:	77 20                	ja     f0102adf <mem_init+0x15a2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102abf:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102ac3:	c7 44 24 08 00 5b 10 	movl   $0xf0105b00,0x8(%esp)
f0102aca:	f0 
f0102acb:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
f0102ad2:	00 
f0102ad3:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102ada:	e8 37 d6 ff ff       	call   f0100116 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0102adf:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102ae6:	00 
f0102ae7:	c7 04 24 00 20 11 00 	movl   $0x112000,(%esp)
f0102aee:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102af3:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102af8:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102afd:	e8 36 e8 ff ff       	call   f0101338 <boot_map_region>
		KSTACKTOP-KSTKSIZE, 
		KSTKSIZE, 
		PADDR(bootstack), 
		PTE_W);
	cprintf("PADDR(bootstack) %x\n", PADDR(bootstack));
f0102b02:	c7 44 24 04 00 20 11 	movl   $0x112000,0x4(%esp)
f0102b09:	00 
f0102b0a:	c7 04 24 41 59 10 f0 	movl   $0xf0105941,(%esp)
f0102b11:	e8 d4 0e 00 00       	call   f01039ea <cprintf>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0102b16:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102b1d:	00 
f0102b1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b25:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102b2a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102b2f:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102b34:	e8 ff e7 ff ff       	call   f0101338 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102b39:	8b 1d 6c fe 17 f0    	mov    0xf017fe6c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102b3f:	a1 68 fe 17 f0       	mov    0xf017fe68,%eax
f0102b44:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102b4b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102b51:	74 79                	je     f0102bcc <mem_init+0x168f>
f0102b53:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102b58:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102b5e:	89 d8                	mov    %ebx,%eax
f0102b60:	e8 98 e1 ff ff       	call   f0100cfd <check_va2pa>
f0102b65:	8b 15 70 fe 17 f0    	mov    0xf017fe70,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b6b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102b71:	77 20                	ja     f0102b93 <mem_init+0x1656>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b73:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102b77:	c7 44 24 08 00 5b 10 	movl   $0xf0105b00,0x8(%esp)
f0102b7e:	f0 
f0102b7f:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0102b86:	00 
f0102b87:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102b8e:	e8 83 d5 ff ff       	call   f0100116 <_panic>
f0102b93:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102b9a:	39 d0                	cmp    %edx,%eax
f0102b9c:	74 24                	je     f0102bc2 <mem_init+0x1685>
f0102b9e:	c7 44 24 0c 44 5f 10 	movl   $0xf0105f44,0xc(%esp)
f0102ba5:	f0 
f0102ba6:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102bad:	f0 
f0102bae:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0102bb5:	00 
f0102bb6:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102bbd:	e8 54 d5 ff ff       	call   f0100116 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102bc2:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102bc8:	39 f7                	cmp    %esi,%edi
f0102bca:	77 8c                	ja     f0102b58 <mem_init+0x161b>
f0102bcc:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102bd1:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f0102bd7:	89 d8                	mov    %ebx,%eax
f0102bd9:	e8 1f e1 ff ff       	call   f0100cfd <check_va2pa>
f0102bde:	8b 15 98 f1 17 f0    	mov    0xf017f198,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102be4:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102bea:	77 20                	ja     f0102c0c <mem_init+0x16cf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bec:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102bf0:	c7 44 24 08 00 5b 10 	movl   $0xf0105b00,0x8(%esp)
f0102bf7:	f0 
f0102bf8:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f0102bff:	00 
f0102c00:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102c07:	e8 0a d5 ff ff       	call   f0100116 <_panic>
f0102c0c:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102c13:	39 d0                	cmp    %edx,%eax
f0102c15:	74 24                	je     f0102c3b <mem_init+0x16fe>
f0102c17:	c7 44 24 0c 78 5f 10 	movl   $0xf0105f78,0xc(%esp)
f0102c1e:	f0 
f0102c1f:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102c26:	f0 
f0102c27:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f0102c2e:	00 
f0102c2f:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102c36:	e8 db d4 ff ff       	call   f0100116 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102c3b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102c41:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f0102c47:	75 88                	jne    f0102bd1 <mem_init+0x1694>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c49:	a1 68 fe 17 f0       	mov    0xf017fe68,%eax
f0102c4e:	c1 e0 0c             	shl    $0xc,%eax
f0102c51:	85 c0                	test   %eax,%eax
f0102c53:	74 4c                	je     f0102ca1 <mem_init+0x1764>
f0102c55:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102c5a:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102c60:	89 d8                	mov    %ebx,%eax
f0102c62:	e8 96 e0 ff ff       	call   f0100cfd <check_va2pa>
f0102c67:	39 c6                	cmp    %eax,%esi
f0102c69:	74 24                	je     f0102c8f <mem_init+0x1752>
f0102c6b:	c7 44 24 0c ac 5f 10 	movl   $0xf0105fac,0xc(%esp)
f0102c72:	f0 
f0102c73:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102c7a:	f0 
f0102c7b:	c7 44 24 04 f1 02 00 	movl   $0x2f1,0x4(%esp)
f0102c82:	00 
f0102c83:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102c8a:	e8 87 d4 ff ff       	call   f0100116 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c8f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102c95:	a1 68 fe 17 f0       	mov    0xf017fe68,%eax
f0102c9a:	c1 e0 0c             	shl    $0xc,%eax
f0102c9d:	39 c6                	cmp    %eax,%esi
f0102c9f:	72 b9                	jb     f0102c5a <mem_init+0x171d>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102ca1:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102ca6:	89 d8                	mov    %ebx,%eax
f0102ca8:	e8 50 e0 ff ff       	call   f0100cfd <check_va2pa>
f0102cad:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102cb2:	bf 00 20 11 f0       	mov    $0xf0112000,%edi
f0102cb7:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102cbd:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102cc0:	39 c2                	cmp    %eax,%edx
f0102cc2:	74 24                	je     f0102ce8 <mem_init+0x17ab>
f0102cc4:	c7 44 24 0c d4 5f 10 	movl   $0xf0105fd4,0xc(%esp)
f0102ccb:	f0 
f0102ccc:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102cd3:	f0 
f0102cd4:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f0102cdb:	00 
f0102cdc:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102ce3:	e8 2e d4 ff ff       	call   f0100116 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102ce8:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102cee:	0f 85 34 05 00 00    	jne    f0103228 <mem_init+0x1ceb>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102cf4:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102cf9:	89 d8                	mov    %ebx,%eax
f0102cfb:	e8 fd df ff ff       	call   f0100cfd <check_va2pa>
f0102d00:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102d03:	74 24                	je     f0102d29 <mem_init+0x17ec>
f0102d05:	c7 44 24 0c 1c 60 10 	movl   $0xf010601c,0xc(%esp)
f0102d0c:	f0 
f0102d0d:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102d14:	f0 
f0102d15:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f0102d1c:	00 
f0102d1d:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102d24:	e8 ed d3 ff ff       	call   f0100116 <_panic>
f0102d29:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102d2e:	ba 00 00 00 e8       	mov    $0xe8000000,%edx
f0102d33:	8d 88 45 fc ff ff    	lea    -0x3bb(%eax),%ecx
f0102d39:	83 f9 04             	cmp    $0x4,%ecx
f0102d3c:	77 36                	ja     f0102d74 <mem_init+0x1837>
f0102d3e:	89 d6                	mov    %edx,%esi
f0102d40:	d3 e6                	shl    %cl,%esi
f0102d42:	85 f6                	test   %esi,%esi
f0102d44:	79 2e                	jns    f0102d74 <mem_init+0x1837>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102d46:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102d4a:	0f 85 aa 00 00 00    	jne    f0102dfa <mem_init+0x18bd>
f0102d50:	c7 44 24 0c 56 59 10 	movl   $0xf0105956,0xc(%esp)
f0102d57:	f0 
f0102d58:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102d5f:	f0 
f0102d60:	c7 44 24 04 ff 02 00 	movl   $0x2ff,0x4(%esp)
f0102d67:	00 
f0102d68:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102d6f:	e8 a2 d3 ff ff       	call   f0100116 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102d74:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102d79:	76 55                	jbe    f0102dd0 <mem_init+0x1893>
				assert(pgdir[i] & PTE_P);
f0102d7b:	8b 0c 83             	mov    (%ebx,%eax,4),%ecx
f0102d7e:	f6 c1 01             	test   $0x1,%cl
f0102d81:	75 24                	jne    f0102da7 <mem_init+0x186a>
f0102d83:	c7 44 24 0c 56 59 10 	movl   $0xf0105956,0xc(%esp)
f0102d8a:	f0 
f0102d8b:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102d92:	f0 
f0102d93:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0102d9a:	00 
f0102d9b:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102da2:	e8 6f d3 ff ff       	call   f0100116 <_panic>
				assert(pgdir[i] & PTE_W);
f0102da7:	f6 c1 02             	test   $0x2,%cl
f0102daa:	75 4e                	jne    f0102dfa <mem_init+0x18bd>
f0102dac:	c7 44 24 0c 67 59 10 	movl   $0xf0105967,0xc(%esp)
f0102db3:	f0 
f0102db4:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102dbb:	f0 
f0102dbc:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f0102dc3:	00 
f0102dc4:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102dcb:	e8 46 d3 ff ff       	call   f0100116 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102dd0:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102dd4:	74 24                	je     f0102dfa <mem_init+0x18bd>
f0102dd6:	c7 44 24 0c 78 59 10 	movl   $0xf0105978,0xc(%esp)
f0102ddd:	f0 
f0102dde:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102de5:	f0 
f0102de6:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0102ded:	00 
f0102dee:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102df5:	e8 1c d3 ff ff       	call   f0100116 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102dfa:	83 c0 01             	add    $0x1,%eax
f0102dfd:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102e02:	0f 85 2b ff ff ff    	jne    f0102d33 <mem_init+0x17f6>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102e08:	c7 04 24 4c 60 10 f0 	movl   $0xf010604c,(%esp)
f0102e0f:	e8 d6 0b 00 00       	call   f01039ea <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102e14:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e19:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e1e:	77 20                	ja     f0102e40 <mem_init+0x1903>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e20:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e24:	c7 44 24 08 00 5b 10 	movl   $0xf0105b00,0x8(%esp)
f0102e2b:	f0 
f0102e2c:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
f0102e33:	00 
f0102e34:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102e3b:	e8 d6 d2 ff ff       	call   f0100116 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102e40:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102e45:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102e48:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e4d:	e8 4e df ff ff       	call   f0100da0 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102e52:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102e55:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102e5a:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102e5d:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102e60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e67:	e8 71 e3 ff ff       	call   f01011dd <page_alloc>
f0102e6c:	89 c6                	mov    %eax,%esi
f0102e6e:	85 c0                	test   %eax,%eax
f0102e70:	75 24                	jne    f0102e96 <mem_init+0x1959>
f0102e72:	c7 44 24 0c 33 57 10 	movl   $0xf0105733,0xc(%esp)
f0102e79:	f0 
f0102e7a:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102e81:	f0 
f0102e82:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0102e89:	00 
f0102e8a:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102e91:	e8 80 d2 ff ff       	call   f0100116 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e9d:	e8 3b e3 ff ff       	call   f01011dd <page_alloc>
f0102ea2:	89 c7                	mov    %eax,%edi
f0102ea4:	85 c0                	test   %eax,%eax
f0102ea6:	75 24                	jne    f0102ecc <mem_init+0x198f>
f0102ea8:	c7 44 24 0c 49 57 10 	movl   $0xf0105749,0xc(%esp)
f0102eaf:	f0 
f0102eb0:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102eb7:	f0 
f0102eb8:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0102ebf:	00 
f0102ec0:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102ec7:	e8 4a d2 ff ff       	call   f0100116 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ecc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ed3:	e8 05 e3 ff ff       	call   f01011dd <page_alloc>
f0102ed8:	89 c3                	mov    %eax,%ebx
f0102eda:	85 c0                	test   %eax,%eax
f0102edc:	75 24                	jne    f0102f02 <mem_init+0x19c5>
f0102ede:	c7 44 24 0c 5f 57 10 	movl   $0xf010575f,0xc(%esp)
f0102ee5:	f0 
f0102ee6:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102eed:	f0 
f0102eee:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0102ef5:	00 
f0102ef6:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102efd:	e8 14 d2 ff ff       	call   f0100116 <_panic>
	page_free(pp0);
f0102f02:	89 34 24             	mov    %esi,(%esp)
f0102f05:	e8 51 e3 ff ff       	call   f010125b <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f0a:	89 f8                	mov    %edi,%eax
f0102f0c:	2b 05 70 fe 17 f0    	sub    0xf017fe70,%eax
f0102f12:	c1 f8 03             	sar    $0x3,%eax
f0102f15:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f18:	89 c2                	mov    %eax,%edx
f0102f1a:	c1 ea 0c             	shr    $0xc,%edx
f0102f1d:	3b 15 68 fe 17 f0    	cmp    0xf017fe68,%edx
f0102f23:	72 20                	jb     f0102f45 <mem_init+0x1a08>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f25:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f29:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f0102f30:	f0 
f0102f31:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102f38:	00 
f0102f39:	c7 04 24 20 56 10 f0 	movl   $0xf0105620,(%esp)
f0102f40:	e8 d1 d1 ff ff       	call   f0100116 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102f45:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102f4c:	00 
f0102f4d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102f54:	00 
	return (void *)(pa + KERNBASE);
f0102f55:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f5a:	89 04 24             	mov    %eax,(%esp)
f0102f5d:	e8 0f 1b 00 00       	call   f0104a71 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f62:	89 d8                	mov    %ebx,%eax
f0102f64:	2b 05 70 fe 17 f0    	sub    0xf017fe70,%eax
f0102f6a:	c1 f8 03             	sar    $0x3,%eax
f0102f6d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f70:	89 c2                	mov    %eax,%edx
f0102f72:	c1 ea 0c             	shr    $0xc,%edx
f0102f75:	3b 15 68 fe 17 f0    	cmp    0xf017fe68,%edx
f0102f7b:	72 20                	jb     f0102f9d <mem_init+0x1a60>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f81:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f0102f88:	f0 
f0102f89:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102f90:	00 
f0102f91:	c7 04 24 20 56 10 f0 	movl   $0xf0105620,(%esp)
f0102f98:	e8 79 d1 ff ff       	call   f0100116 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102f9d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102fa4:	00 
f0102fa5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102fac:	00 
	return (void *)(pa + KERNBASE);
f0102fad:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102fb2:	89 04 24             	mov    %eax,(%esp)
f0102fb5:	e8 b7 1a 00 00       	call   f0104a71 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102fba:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102fc1:	00 
f0102fc2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102fc9:	00 
f0102fca:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102fce:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0102fd3:	89 04 24             	mov    %eax,(%esp)
f0102fd6:	e8 e6 e4 ff ff       	call   f01014c1 <page_insert>
	assert(pp1->pp_ref == 1);
f0102fdb:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102fe0:	74 24                	je     f0103006 <mem_init+0x1ac9>
f0102fe2:	c7 44 24 0c 40 58 10 	movl   $0xf0105840,0xc(%esp)
f0102fe9:	f0 
f0102fea:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0102ff1:	f0 
f0102ff2:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0102ff9:	00 
f0102ffa:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0103001:	e8 10 d1 ff ff       	call   f0100116 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103006:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010300d:	01 01 01 
f0103010:	74 24                	je     f0103036 <mem_init+0x1af9>
f0103012:	c7 44 24 0c 6c 60 10 	movl   $0xf010606c,0xc(%esp)
f0103019:	f0 
f010301a:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0103021:	f0 
f0103022:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0103029:	00 
f010302a:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0103031:	e8 e0 d0 ff ff       	call   f0100116 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103036:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010303d:	00 
f010303e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103045:	00 
f0103046:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010304a:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f010304f:	89 04 24             	mov    %eax,(%esp)
f0103052:	e8 6a e4 ff ff       	call   f01014c1 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103057:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010305e:	02 02 02 
f0103061:	74 24                	je     f0103087 <mem_init+0x1b4a>
f0103063:	c7 44 24 0c 90 60 10 	movl   $0xf0106090,0xc(%esp)
f010306a:	f0 
f010306b:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0103072:	f0 
f0103073:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f010307a:	00 
f010307b:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0103082:	e8 8f d0 ff ff       	call   f0100116 <_panic>
	assert(pp2->pp_ref == 1);
f0103087:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010308c:	74 24                	je     f01030b2 <mem_init+0x1b75>
f010308e:	c7 44 24 0c 62 58 10 	movl   $0xf0105862,0xc(%esp)
f0103095:	f0 
f0103096:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f010309d:	f0 
f010309e:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f01030a5:	00 
f01030a6:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01030ad:	e8 64 d0 ff ff       	call   f0100116 <_panic>
	assert(pp1->pp_ref == 0);
f01030b2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01030b7:	74 24                	je     f01030dd <mem_init+0x1ba0>
f01030b9:	c7 44 24 0c d7 58 10 	movl   $0xf01058d7,0xc(%esp)
f01030c0:	f0 
f01030c1:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01030c8:	f0 
f01030c9:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f01030d0:	00 
f01030d1:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01030d8:	e8 39 d0 ff ff       	call   f0100116 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01030dd:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01030e4:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01030e7:	89 d8                	mov    %ebx,%eax
f01030e9:	2b 05 70 fe 17 f0    	sub    0xf017fe70,%eax
f01030ef:	c1 f8 03             	sar    $0x3,%eax
f01030f2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01030f5:	89 c2                	mov    %eax,%edx
f01030f7:	c1 ea 0c             	shr    $0xc,%edx
f01030fa:	3b 15 68 fe 17 f0    	cmp    0xf017fe68,%edx
f0103100:	72 20                	jb     f0103122 <mem_init+0x1be5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103102:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103106:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f010310d:	f0 
f010310e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103115:	00 
f0103116:	c7 04 24 20 56 10 f0 	movl   $0xf0105620,(%esp)
f010311d:	e8 f4 cf ff ff       	call   f0100116 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103122:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103129:	03 03 03 
f010312c:	74 24                	je     f0103152 <mem_init+0x1c15>
f010312e:	c7 44 24 0c b4 60 10 	movl   $0xf01060b4,0xc(%esp)
f0103135:	f0 
f0103136:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f010313d:	f0 
f010313e:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0103145:	00 
f0103146:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f010314d:	e8 c4 cf ff ff       	call   f0100116 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103152:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103159:	00 
f010315a:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f010315f:	89 04 24             	mov    %eax,(%esp)
f0103162:	e8 02 e3 ff ff       	call   f0101469 <page_remove>
	assert(pp2->pp_ref == 0);
f0103167:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010316c:	74 24                	je     f0103192 <mem_init+0x1c55>
f010316e:	c7 44 24 0c c6 58 10 	movl   $0xf01058c6,0xc(%esp)
f0103175:	f0 
f0103176:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f010317d:	f0 
f010317e:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0103185:	00 
f0103186:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f010318d:	e8 84 cf ff ff       	call   f0100116 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103192:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
f0103197:	8b 08                	mov    (%eax),%ecx
f0103199:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010319f:	89 f2                	mov    %esi,%edx
f01031a1:	2b 15 70 fe 17 f0    	sub    0xf017fe70,%edx
f01031a7:	c1 fa 03             	sar    $0x3,%edx
f01031aa:	c1 e2 0c             	shl    $0xc,%edx
f01031ad:	39 d1                	cmp    %edx,%ecx
f01031af:	74 24                	je     f01031d5 <mem_init+0x1c98>
f01031b1:	c7 44 24 0c fc 5b 10 	movl   $0xf0105bfc,0xc(%esp)
f01031b8:	f0 
f01031b9:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01031c0:	f0 
f01031c1:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f01031c8:	00 
f01031c9:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f01031d0:	e8 41 cf ff ff       	call   f0100116 <_panic>
	kern_pgdir[0] = 0;
f01031d5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01031db:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01031e0:	74 24                	je     f0103206 <mem_init+0x1cc9>
f01031e2:	c7 44 24 0c 51 58 10 	movl   $0xf0105851,0xc(%esp)
f01031e9:	f0 
f01031ea:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f01031f1:	f0 
f01031f2:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f01031f9:	00 
f01031fa:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0103201:	e8 10 cf ff ff       	call   f0100116 <_panic>
	pp0->pp_ref = 0;
f0103206:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010320c:	89 34 24             	mov    %esi,(%esp)
f010320f:	e8 47 e0 ff ff       	call   f010125b <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103214:	c7 04 24 e0 60 10 f0 	movl   $0xf01060e0,(%esp)
f010321b:	e8 ca 07 00 00       	call   f01039ea <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103220:	83 c4 4c             	add    $0x4c,%esp
f0103223:	5b                   	pop    %ebx
f0103224:	5e                   	pop    %esi
f0103225:	5f                   	pop    %edi
f0103226:	5d                   	pop    %ebp
f0103227:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0103228:	89 f2                	mov    %esi,%edx
f010322a:	89 d8                	mov    %ebx,%eax
f010322c:	e8 cc da ff ff       	call   f0100cfd <check_va2pa>
f0103231:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103237:	e9 81 fa ff ff       	jmp    f0102cbd <mem_init+0x1780>

f010323c <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010323c:	55                   	push   %ebp
f010323d:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f010323f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103244:	5d                   	pop    %ebp
f0103245:	c3                   	ret    

f0103246 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103246:	55                   	push   %ebp
f0103247:	89 e5                	mov    %esp,%ebp
f0103249:	53                   	push   %ebx
f010324a:	83 ec 14             	sub    $0x14,%esp
f010324d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103250:	8b 45 14             	mov    0x14(%ebp),%eax
f0103253:	83 c8 04             	or     $0x4,%eax
f0103256:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010325a:	8b 45 10             	mov    0x10(%ebp),%eax
f010325d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103261:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103264:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103268:	89 1c 24             	mov    %ebx,(%esp)
f010326b:	e8 cc ff ff ff       	call   f010323c <user_mem_check>
f0103270:	85 c0                	test   %eax,%eax
f0103272:	79 23                	jns    f0103297 <user_mem_assert+0x51>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103274:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010327b:	00 
f010327c:	8b 43 48             	mov    0x48(%ebx),%eax
f010327f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103283:	c7 04 24 0c 61 10 f0 	movl   $0xf010610c,(%esp)
f010328a:	e8 5b 07 00 00       	call   f01039ea <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010328f:	89 1c 24             	mov    %ebx,(%esp)
f0103292:	e8 36 06 00 00       	call   f01038cd <env_destroy>
	}
}
f0103297:	83 c4 14             	add    $0x14,%esp
f010329a:	5b                   	pop    %ebx
f010329b:	5d                   	pop    %ebp
f010329c:	c3                   	ret    
f010329d:	00 00                	add    %al,(%eax)
	...

f01032a0 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01032a0:	55                   	push   %ebp
f01032a1:	89 e5                	mov    %esp,%ebp
f01032a3:	57                   	push   %edi
f01032a4:	56                   	push   %esi
f01032a5:	53                   	push   %ebx
f01032a6:	83 ec 1c             	sub    $0x1c,%esp
f01032a9:	89 c6                	mov    %eax,%esi
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
f01032ab:	89 d3                	mov    %edx,%ebx
f01032ad:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01032b3:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f01032ba:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (; begin < end; begin += PGSIZE) {
f01032c0:	39 fb                	cmp    %edi,%ebx
f01032c2:	73 51                	jae    f0103315 <region_alloc+0x75>
		struct PageInfo *pg = page_alloc(0);
f01032c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01032cb:	e8 0d df ff ff       	call   f01011dd <page_alloc>
		if (!pg) panic("region_alloc failed!");
f01032d0:	85 c0                	test   %eax,%eax
f01032d2:	75 1c                	jne    f01032f0 <region_alloc+0x50>
f01032d4:	c7 44 24 08 41 61 10 	movl   $0xf0106141,0x8(%esp)
f01032db:	f0 
f01032dc:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
f01032e3:	00 
f01032e4:	c7 04 24 56 61 10 f0 	movl   $0xf0106156,(%esp)
f01032eb:	e8 26 ce ff ff       	call   f0100116 <_panic>
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
f01032f0:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01032f7:	00 
f01032f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01032fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103300:	8b 46 5c             	mov    0x5c(%esi),%eax
f0103303:	89 04 24             	mov    %eax,(%esp)
f0103306:	e8 b6 e1 ff ff       	call   f01014c1 <page_insert>
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
	for (; begin < end; begin += PGSIZE) {
f010330b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103311:	39 df                	cmp    %ebx,%edi
f0103313:	77 af                	ja     f01032c4 <region_alloc+0x24>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0103315:	83 c4 1c             	add    $0x1c,%esp
f0103318:	5b                   	pop    %ebx
f0103319:	5e                   	pop    %esi
f010331a:	5f                   	pop    %edi
f010331b:	5d                   	pop    %ebp
f010331c:	c3                   	ret    

f010331d <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010331d:	55                   	push   %ebp
f010331e:	89 e5                	mov    %esp,%ebp
f0103320:	53                   	push   %ebx
f0103321:	8b 45 08             	mov    0x8(%ebp),%eax
f0103324:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103327:	0f b6 5d 10          	movzbl 0x10(%ebp),%ebx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010332b:	85 c0                	test   %eax,%eax
f010332d:	75 0e                	jne    f010333d <envid2env+0x20>
		*env_store = curenv;
f010332f:	a1 9c f1 17 f0       	mov    0xf017f19c,%eax
f0103334:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103336:	b8 00 00 00 00       	mov    $0x0,%eax
f010333b:	eb 55                	jmp    f0103392 <envid2env+0x75>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010333d:	89 c2                	mov    %eax,%edx
f010333f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103345:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103348:	c1 e2 05             	shl    $0x5,%edx
f010334b:	03 15 98 f1 17 f0    	add    0xf017f198,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103351:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0103355:	74 05                	je     f010335c <envid2env+0x3f>
f0103357:	39 42 48             	cmp    %eax,0x48(%edx)
f010335a:	74 0d                	je     f0103369 <envid2env+0x4c>
		*env_store = 0;
f010335c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0103362:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103367:	eb 29                	jmp    f0103392 <envid2env+0x75>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103369:	84 db                	test   %bl,%bl
f010336b:	74 1e                	je     f010338b <envid2env+0x6e>
f010336d:	a1 9c f1 17 f0       	mov    0xf017f19c,%eax
f0103372:	39 c2                	cmp    %eax,%edx
f0103374:	74 15                	je     f010338b <envid2env+0x6e>
f0103376:	8b 58 48             	mov    0x48(%eax),%ebx
f0103379:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f010337c:	74 0d                	je     f010338b <envid2env+0x6e>
		*env_store = 0;
f010337e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0103384:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103389:	eb 07                	jmp    f0103392 <envid2env+0x75>
	}

	*env_store = e;
f010338b:	89 11                	mov    %edx,(%ecx)
	return 0;
f010338d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103392:	5b                   	pop    %ebx
f0103393:	5d                   	pop    %ebp
f0103394:	c3                   	ret    

f0103395 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103395:	55                   	push   %ebp
f0103396:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103398:	b8 30 c3 11 f0       	mov    $0xf011c330,%eax
f010339d:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01033a0:	b8 23 00 00 00       	mov    $0x23,%eax
f01033a5:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01033a7:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01033a9:	b0 10                	mov    $0x10,%al
f01033ab:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01033ad:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01033af:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01033b1:	ea b8 33 10 f0 08 00 	ljmp   $0x8,$0xf01033b8
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01033b8:	b0 00                	mov    $0x0,%al
f01033ba:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01033bd:	5d                   	pop    %ebp
f01033be:	c3                   	ret    

f01033bf <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01033bf:	55                   	push   %ebp
f01033c0:	89 e5                	mov    %esp,%ebp
f01033c2:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV;i >= 0; --i) {
		envs[i].env_id = 0;
f01033c3:	8b 1d 98 f1 17 f0    	mov    0xf017f198,%ebx
f01033c9:	8b 0d a0 f1 17 f0    	mov    0xf017f1a0,%ecx
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f01033cf:	8d 83 00 80 01 00    	lea    0x18000(%ebx),%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV;i >= 0; --i) {
f01033d5:	ba 00 04 00 00       	mov    $0x400,%edx
		envs[i].env_id = 0;
f01033da:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01033e1:	89 48 44             	mov    %ecx,0x44(%eax)
f01033e4:	89 c1                	mov    %eax,%ecx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV;i >= 0; --i) {
f01033e6:	83 ea 01             	sub    $0x1,%edx
f01033e9:	83 e8 60             	sub    $0x60,%eax
f01033ec:	83 fa ff             	cmp    $0xffffffff,%edx
f01033ef:	75 e9                	jne    f01033da <env_init+0x1b>
f01033f1:	89 1d a0 f1 17 f0    	mov    %ebx,0xf017f1a0
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = envs+i;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f01033f7:	e8 99 ff ff ff       	call   f0103395 <env_init_percpu>
}
f01033fc:	5b                   	pop    %ebx
f01033fd:	5d                   	pop    %ebp
f01033fe:	c3                   	ret    

f01033ff <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01033ff:	55                   	push   %ebp
f0103400:	89 e5                	mov    %esp,%ebp
f0103402:	53                   	push   %ebx
f0103403:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103406:	8b 1d a0 f1 17 f0    	mov    0xf017f1a0,%ebx
f010340c:	85 db                	test   %ebx,%ebx
f010340e:	0f 84 66 01 00 00    	je     f010357a <env_alloc+0x17b>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103414:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010341b:	e8 bd dd ff ff       	call   f01011dd <page_alloc>
f0103420:	85 c0                	test   %eax,%eax
f0103422:	0f 84 59 01 00 00    	je     f0103581 <env_alloc+0x182>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0103428:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010342d:	2b 05 70 fe 17 f0    	sub    0xf017fe70,%eax
f0103433:	c1 f8 03             	sar    $0x3,%eax
f0103436:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103439:	89 c2                	mov    %eax,%edx
f010343b:	c1 ea 0c             	shr    $0xc,%edx
f010343e:	3b 15 68 fe 17 f0    	cmp    0xf017fe68,%edx
f0103444:	72 20                	jb     f0103466 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103446:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010344a:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f0103451:	f0 
f0103452:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103459:	00 
f010345a:	c7 04 24 20 56 10 f0 	movl   $0xf0105620,(%esp)
f0103461:	e8 b0 cc ff ff       	call   f0100116 <_panic>
	return (void *)(pa + KERNBASE);
f0103466:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *) page2kva(p);
f010346b:	89 43 5c             	mov    %eax,0x5c(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f010346e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103475:	00 
f0103476:	8b 15 6c fe 17 f0    	mov    0xf017fe6c,%edx
f010347c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103480:	89 04 24             	mov    %eax,(%esp)
f0103483:	e8 c3 16 00 00       	call   f0104b4b <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103488:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010348b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103490:	77 20                	ja     f01034b2 <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103492:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103496:	c7 44 24 08 00 5b 10 	movl   $0xf0105b00,0x8(%esp)
f010349d:	f0 
f010349e:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
f01034a5:	00 
f01034a6:	c7 04 24 56 61 10 f0 	movl   $0xf0106156,(%esp)
f01034ad:	e8 64 cc ff ff       	call   f0100116 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01034b2:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01034b8:	83 ca 05             	or     $0x5,%edx
f01034bb:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01034c1:	8b 43 48             	mov    0x48(%ebx),%eax
f01034c4:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01034c9:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01034ce:	ba 00 10 00 00       	mov    $0x1000,%edx
f01034d3:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01034d6:	89 da                	mov    %ebx,%edx
f01034d8:	2b 15 98 f1 17 f0    	sub    0xf017f198,%edx
f01034de:	c1 fa 05             	sar    $0x5,%edx
f01034e1:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01034e7:	09 d0                	or     %edx,%eax
f01034e9:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01034ec:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034ef:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01034f2:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01034f9:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103500:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103507:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010350e:	00 
f010350f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103516:	00 
f0103517:	89 1c 24             	mov    %ebx,(%esp)
f010351a:	e8 52 15 00 00       	call   f0104a71 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010351f:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103525:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010352b:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103531:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103538:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f010353e:	8b 43 44             	mov    0x44(%ebx),%eax
f0103541:	a3 a0 f1 17 f0       	mov    %eax,0xf017f1a0
	*newenv_store = e;
f0103546:	8b 45 08             	mov    0x8(%ebp),%eax
f0103549:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010354b:	8b 4b 48             	mov    0x48(%ebx),%ecx
f010354e:	a1 9c f1 17 f0       	mov    0xf017f19c,%eax
f0103553:	ba 00 00 00 00       	mov    $0x0,%edx
f0103558:	85 c0                	test   %eax,%eax
f010355a:	74 03                	je     f010355f <env_alloc+0x160>
f010355c:	8b 50 48             	mov    0x48(%eax),%edx
f010355f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103563:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103567:	c7 04 24 61 61 10 f0 	movl   $0xf0106161,(%esp)
f010356e:	e8 77 04 00 00       	call   f01039ea <cprintf>
	return 0;
f0103573:	b8 00 00 00 00       	mov    $0x0,%eax
f0103578:	eb 0c                	jmp    f0103586 <env_alloc+0x187>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010357a:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010357f:	eb 05                	jmp    f0103586 <env_alloc+0x187>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103581:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103586:	83 c4 14             	add    $0x14,%esp
f0103589:	5b                   	pop    %ebx
f010358a:	5d                   	pop    %ebp
f010358b:	c3                   	ret    

f010358c <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f010358c:	55                   	push   %ebp
f010358d:	89 e5                	mov    %esp,%ebp
f010358f:	57                   	push   %edi
f0103590:	56                   	push   %esi
f0103591:	53                   	push   %ebx
f0103592:	83 ec 3c             	sub    $0x3c,%esp
f0103595:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *penv;
	env_alloc(&penv, 0);
f0103598:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010359f:	00 
f01035a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01035a3:	89 04 24             	mov    %eax,(%esp)
f01035a6:	e8 54 fe ff ff       	call   f01033ff <env_alloc>
	load_icode(penv, binary, size);
f01035ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Elf *ELFHDR = (struct Elf *) binary;
	struct Proghdr *ph, *eph;

	if (ELFHDR->e_magic != ELF_MAGIC)
f01035b1:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01035b7:	74 1c                	je     f01035d5 <env_create+0x49>
		panic("Not executable!");
f01035b9:	c7 44 24 08 76 61 10 	movl   $0xf0106176,0x8(%esp)
f01035c0:	f0 
f01035c1:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
f01035c8:	00 
f01035c9:	c7 04 24 56 61 10 f0 	movl   $0xf0106156,(%esp)
f01035d0:	e8 41 cb ff ff       	call   f0100116 <_panic>
	
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f01035d5:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f01035d8:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
	//  The ph->p_filesz bytes from the ELF binary, starting at
	//  'binary + ph->p_offset', should be copied to virtual address
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
f01035dc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01035df:	8b 42 5c             	mov    0x5c(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035e2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035e7:	77 20                	ja     f0103609 <env_create+0x7d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035ed:	c7 44 24 08 00 5b 10 	movl   $0xf0105b00,0x8(%esp)
f01035f4:	f0 
f01035f5:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
f01035fc:	00 
f01035fd:	c7 04 24 56 61 10 f0 	movl   $0xf0106156,(%esp)
f0103604:	e8 0d cb ff ff       	call   f0100116 <_panic>
	struct Proghdr *ph, *eph;

	if (ELFHDR->e_magic != ELF_MAGIC)
		panic("Not executable!");
	
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0103609:	8d 1c 1f             	lea    (%edi,%ebx,1),%ebx
	eph = ph + ELFHDR->e_phnum;
f010360c:	0f b7 f6             	movzwl %si,%esi
f010360f:	c1 e6 05             	shl    $0x5,%esi
f0103612:	8d 34 33             	lea    (%ebx,%esi,1),%esi
	return (physaddr_t)kva - KERNBASE;
f0103615:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010361a:	0f 22 d8             	mov    %eax,%cr3
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
	//it's silly to use kern_pgdir here.
	for (; ph < eph; ph++)
f010361d:	39 f3                	cmp    %esi,%ebx
f010361f:	73 69                	jae    f010368a <env_create+0xfe>
		if (ph->p_type == ELF_PROG_LOAD) {
f0103621:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103624:	75 5d                	jne    f0103683 <env_create+0xf7>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103626:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103629:	8b 53 08             	mov    0x8(%ebx),%edx
f010362c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010362f:	e8 6c fc ff ff       	call   f01032a0 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0103634:	8b 43 14             	mov    0x14(%ebx),%eax
f0103637:	89 44 24 08          	mov    %eax,0x8(%esp)
f010363b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103642:	00 
f0103643:	8b 43 08             	mov    0x8(%ebx),%eax
f0103646:	89 04 24             	mov    %eax,(%esp)
f0103649:	e8 23 14 00 00       	call   f0104a71 <memset>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f010364e:	8b 43 10             	mov    0x10(%ebx),%eax
f0103651:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103655:	89 f8                	mov    %edi,%eax
f0103657:	03 43 04             	add    0x4(%ebx),%eax
f010365a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010365e:	8b 43 08             	mov    0x8(%ebx),%eax
f0103661:	89 04 24             	mov    %eax,(%esp)
f0103664:	e8 e2 14 00 00       	call   f0104b4b <memcpy>
			//but I'm curious about how exactly p_memsz and p_filesz differs
			cprintf("p_memsz: %x, p_filesz: %x\n", ph->p_memsz, ph->p_filesz);
f0103669:	8b 43 10             	mov    0x10(%ebx),%eax
f010366c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103670:	8b 43 14             	mov    0x14(%ebx),%eax
f0103673:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103677:	c7 04 24 86 61 10 f0 	movl   $0xf0106186,(%esp)
f010367e:	e8 67 03 00 00       	call   f01039ea <cprintf>
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
	//it's silly to use kern_pgdir here.
	for (; ph < eph; ph++)
f0103683:	83 c3 20             	add    $0x20,%ebx
f0103686:	39 de                	cmp    %ebx,%esi
f0103688:	77 97                	ja     f0103621 <env_create+0x95>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
			//but I'm curious about how exactly p_memsz and p_filesz differs
			cprintf("p_memsz: %x, p_filesz: %x\n", ph->p_memsz, ph->p_filesz);
		}
	//we can use this because kern_pgdir is a subset of e->env_pgdir
	lcr3(PADDR(kern_pgdir));
f010368a:	a1 6c fe 17 f0       	mov    0xf017fe6c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010368f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103694:	77 20                	ja     f01036b6 <env_create+0x12a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103696:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010369a:	c7 44 24 08 00 5b 10 	movl   $0xf0105b00,0x8(%esp)
f01036a1:	f0 
f01036a2:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
f01036a9:	00 
f01036aa:	c7 04 24 56 61 10 f0 	movl   $0xf0106156,(%esp)
f01036b1:	e8 60 ca ff ff       	call   f0100116 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01036b6:	05 00 00 00 10       	add    $0x10000000,%eax
f01036bb:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	e->env_tf.tf_eip = ELFHDR->e_entry;
f01036be:	8b 47 18             	mov    0x18(%edi),%eax
f01036c1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01036c4:	89 42 30             	mov    %eax,0x30(%edx)
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f01036c7:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01036cc:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01036d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01036d4:	e8 c7 fb ff ff       	call   f01032a0 <region_alloc>
{
	// LAB 3: Your code here.
	struct Env *penv;
	env_alloc(&penv, 0);
	load_icode(penv, binary, size);
}
f01036d9:	83 c4 3c             	add    $0x3c,%esp
f01036dc:	5b                   	pop    %ebx
f01036dd:	5e                   	pop    %esi
f01036de:	5f                   	pop    %edi
f01036df:	5d                   	pop    %ebp
f01036e0:	c3                   	ret    

f01036e1 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01036e1:	55                   	push   %ebp
f01036e2:	89 e5                	mov    %esp,%ebp
f01036e4:	57                   	push   %edi
f01036e5:	56                   	push   %esi
f01036e6:	53                   	push   %ebx
f01036e7:	83 ec 2c             	sub    $0x2c,%esp
f01036ea:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01036ed:	a1 9c f1 17 f0       	mov    0xf017f19c,%eax
f01036f2:	39 c7                	cmp    %eax,%edi
f01036f4:	75 37                	jne    f010372d <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f01036f6:	8b 15 6c fe 17 f0    	mov    0xf017fe6c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036fc:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103702:	77 20                	ja     f0103724 <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103704:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103708:	c7 44 24 08 00 5b 10 	movl   $0xf0105b00,0x8(%esp)
f010370f:	f0 
f0103710:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
f0103717:	00 
f0103718:	c7 04 24 56 61 10 f0 	movl   $0xf0106156,(%esp)
f010371f:	e8 f2 c9 ff ff       	call   f0100116 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103724:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010372a:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010372d:	8b 4f 48             	mov    0x48(%edi),%ecx
f0103730:	ba 00 00 00 00       	mov    $0x0,%edx
f0103735:	85 c0                	test   %eax,%eax
f0103737:	74 03                	je     f010373c <env_free+0x5b>
f0103739:	8b 50 48             	mov    0x48(%eax),%edx
f010373c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103740:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103744:	c7 04 24 a1 61 10 f0 	movl   $0xf01061a1,(%esp)
f010374b:	e8 9a 02 00 00       	call   f01039ea <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103750:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103757:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010375a:	c1 e0 02             	shl    $0x2,%eax
f010375d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103760:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103763:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103766:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103769:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010376f:	0f 84 bc 00 00 00    	je     f0103831 <env_free+0x150>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103775:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010377b:	89 f0                	mov    %esi,%eax
f010377d:	c1 e8 0c             	shr    $0xc,%eax
f0103780:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103783:	3b 05 68 fe 17 f0    	cmp    0xf017fe68,%eax
f0103789:	72 20                	jb     f01037ab <env_free+0xca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010378b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010378f:	c7 44 24 08 88 59 10 	movl   $0xf0105988,0x8(%esp)
f0103796:	f0 
f0103797:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
f010379e:	00 
f010379f:	c7 04 24 56 61 10 f0 	movl   $0xf0106156,(%esp)
f01037a6:	e8 6b c9 ff ff       	call   f0100116 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01037ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01037ae:	c1 e2 16             	shl    $0x16,%edx
f01037b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01037b4:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01037b9:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01037c0:	01 
f01037c1:	74 17                	je     f01037da <env_free+0xf9>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01037c3:	89 d8                	mov    %ebx,%eax
f01037c5:	c1 e0 0c             	shl    $0xc,%eax
f01037c8:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01037cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037cf:	8b 47 5c             	mov    0x5c(%edi),%eax
f01037d2:	89 04 24             	mov    %eax,(%esp)
f01037d5:	e8 8f dc ff ff       	call   f0101469 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01037da:	83 c3 01             	add    $0x1,%ebx
f01037dd:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01037e3:	75 d4                	jne    f01037b9 <env_free+0xd8>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01037e5:	8b 47 5c             	mov    0x5c(%edi),%eax
f01037e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01037eb:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01037f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01037f5:	3b 05 68 fe 17 f0    	cmp    0xf017fe68,%eax
f01037fb:	72 1c                	jb     f0103819 <env_free+0x138>
		panic("pa2page called with invalid pa");
f01037fd:	c7 44 24 08 a4 5a 10 	movl   $0xf0105aa4,0x8(%esp)
f0103804:	f0 
f0103805:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010380c:	00 
f010380d:	c7 04 24 20 56 10 f0 	movl   $0xf0105620,(%esp)
f0103814:	e8 fd c8 ff ff       	call   f0100116 <_panic>
	return &pages[PGNUM(pa)];
f0103819:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010381c:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0103823:	03 05 70 fe 17 f0    	add    0xf017fe70,%eax
		page_decref(pa2page(pa));
f0103829:	89 04 24             	mov    %eax,(%esp)
f010382c:	e8 3f da ff ff       	call   f0101270 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103831:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103835:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f010383c:	0f 85 15 ff ff ff    	jne    f0103757 <env_free+0x76>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103842:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103845:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010384a:	77 20                	ja     f010386c <env_free+0x18b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010384c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103850:	c7 44 24 08 00 5b 10 	movl   $0xf0105b00,0x8(%esp)
f0103857:	f0 
f0103858:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
f010385f:	00 
f0103860:	c7 04 24 56 61 10 f0 	movl   $0xf0106156,(%esp)
f0103867:	e8 aa c8 ff ff       	call   f0100116 <_panic>
	e->env_pgdir = 0;
f010386c:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103873:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103878:	c1 e8 0c             	shr    $0xc,%eax
f010387b:	3b 05 68 fe 17 f0    	cmp    0xf017fe68,%eax
f0103881:	72 1c                	jb     f010389f <env_free+0x1be>
		panic("pa2page called with invalid pa");
f0103883:	c7 44 24 08 a4 5a 10 	movl   $0xf0105aa4,0x8(%esp)
f010388a:	f0 
f010388b:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103892:	00 
f0103893:	c7 04 24 20 56 10 f0 	movl   $0xf0105620,(%esp)
f010389a:	e8 77 c8 ff ff       	call   f0100116 <_panic>
	return &pages[PGNUM(pa)];
f010389f:	c1 e0 03             	shl    $0x3,%eax
f01038a2:	03 05 70 fe 17 f0    	add    0xf017fe70,%eax
	page_decref(pa2page(pa));
f01038a8:	89 04 24             	mov    %eax,(%esp)
f01038ab:	e8 c0 d9 ff ff       	call   f0101270 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01038b0:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01038b7:	a1 a0 f1 17 f0       	mov    0xf017f1a0,%eax
f01038bc:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01038bf:	89 3d a0 f1 17 f0    	mov    %edi,0xf017f1a0
}
f01038c5:	83 c4 2c             	add    $0x2c,%esp
f01038c8:	5b                   	pop    %ebx
f01038c9:	5e                   	pop    %esi
f01038ca:	5f                   	pop    %edi
f01038cb:	5d                   	pop    %ebp
f01038cc:	c3                   	ret    

f01038cd <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01038cd:	55                   	push   %ebp
f01038ce:	89 e5                	mov    %esp,%ebp
f01038d0:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f01038d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01038d6:	89 04 24             	mov    %eax,(%esp)
f01038d9:	e8 03 fe ff ff       	call   f01036e1 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01038de:	c7 04 24 c4 61 10 f0 	movl   $0xf01061c4,(%esp)
f01038e5:	e8 00 01 00 00       	call   f01039ea <cprintf>
	while (1)
		monitor(NULL);
f01038ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01038f1:	e8 fd cf ff ff       	call   f01008f3 <monitor>
f01038f6:	eb f2                	jmp    f01038ea <env_destroy+0x1d>

f01038f8 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01038f8:	55                   	push   %ebp
f01038f9:	89 e5                	mov    %esp,%ebp
f01038fb:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f01038fe:	8b 65 08             	mov    0x8(%ebp),%esp
f0103901:	61                   	popa   
f0103902:	07                   	pop    %es
f0103903:	1f                   	pop    %ds
f0103904:	83 c4 08             	add    $0x8,%esp
f0103907:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103908:	c7 44 24 08 b7 61 10 	movl   $0xf01061b7,0x8(%esp)
f010390f:	f0 
f0103910:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
f0103917:	00 
f0103918:	c7 04 24 56 61 10 f0 	movl   $0xf0106156,(%esp)
f010391f:	e8 f2 c7 ff ff       	call   f0100116 <_panic>

f0103924 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103924:	55                   	push   %ebp
f0103925:	89 e5                	mov    %esp,%ebp
f0103927:	83 ec 18             	sub    $0x18,%esp
f010392a:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (e->env_status == ENV_RUNNING)
		e->env_status = ENV_RUNNABLE;
	curenv = e;
f010392d:	a3 9c f1 17 f0       	mov    %eax,0xf017f19c
	e->env_status = ENV_RUNNING;
f0103932:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	e->env_runs++;
f0103939:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(e->env_pgdir));
f010393d:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103940:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103946:	77 20                	ja     f0103968 <env_run+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103948:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010394c:	c7 44 24 08 00 5b 10 	movl   $0xf0105b00,0x8(%esp)
f0103953:	f0 
f0103954:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
f010395b:	00 
f010395c:	c7 04 24 56 61 10 f0 	movl   $0xf0106156,(%esp)
f0103963:	e8 ae c7 ff ff       	call   f0100116 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103968:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010396e:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(&e->env_tf);
f0103971:	89 04 24             	mov    %eax,(%esp)
f0103974:	e8 7f ff ff ff       	call   f01038f8 <env_pop_tf>
f0103979:	00 00                	add    %al,(%eax)
	...

f010397c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010397c:	55                   	push   %ebp
f010397d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010397f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103984:	8b 45 08             	mov    0x8(%ebp),%eax
f0103987:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103988:	b2 71                	mov    $0x71,%dl
f010398a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010398b:	0f b6 c0             	movzbl %al,%eax
}
f010398e:	5d                   	pop    %ebp
f010398f:	c3                   	ret    

f0103990 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103990:	55                   	push   %ebp
f0103991:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103993:	ba 70 00 00 00       	mov    $0x70,%edx
f0103998:	8b 45 08             	mov    0x8(%ebp),%eax
f010399b:	ee                   	out    %al,(%dx)
f010399c:	b2 71                	mov    $0x71,%dl
f010399e:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039a1:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01039a2:	5d                   	pop    %ebp
f01039a3:	c3                   	ret    

f01039a4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01039a4:	55                   	push   %ebp
f01039a5:	89 e5                	mov    %esp,%ebp
f01039a7:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01039aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01039ad:	89 04 24             	mov    %eax,(%esp)
f01039b0:	e8 dc cc ff ff       	call   f0100691 <cputchar>
	*cnt++;
}
f01039b5:	c9                   	leave  
f01039b6:	c3                   	ret    

f01039b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01039b7:	55                   	push   %ebp
f01039b8:	89 e5                	mov    %esp,%ebp
f01039ba:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01039bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01039c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01039ce:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01039d5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039d9:	c7 04 24 a4 39 10 f0 	movl   $0xf01039a4,(%esp)
f01039e0:	e8 cc 09 00 00       	call   f01043b1 <vprintfmt>
	return cnt;
}
f01039e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01039e8:	c9                   	leave  
f01039e9:	c3                   	ret    

f01039ea <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01039ea:	55                   	push   %ebp
f01039eb:	89 e5                	mov    %esp,%ebp
f01039ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01039f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01039f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01039fa:	89 04 24             	mov    %eax,(%esp)
f01039fd:	e8 b5 ff ff ff       	call   f01039b7 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103a02:	c9                   	leave  
f0103a03:	c3                   	ret    

f0103a04 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103a04:	55                   	push   %ebp
f0103a05:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103a07:	c7 05 e4 f9 17 f0 00 	movl   $0xf0000000,0xf017f9e4
f0103a0e:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103a11:	66 c7 05 e8 f9 17 f0 	movw   $0x10,0xf017f9e8
f0103a18:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103a1a:	66 c7 05 28 c3 11 f0 	movw   $0x68,0xf011c328
f0103a21:	68 00 
f0103a23:	b8 e0 f9 17 f0       	mov    $0xf017f9e0,%eax
f0103a28:	66 a3 2a c3 11 f0    	mov    %ax,0xf011c32a
f0103a2e:	89 c2                	mov    %eax,%edx
f0103a30:	c1 ea 10             	shr    $0x10,%edx
f0103a33:	88 15 2c c3 11 f0    	mov    %dl,0xf011c32c
f0103a39:	c6 05 2e c3 11 f0 40 	movb   $0x40,0xf011c32e
f0103a40:	c1 e8 18             	shr    $0x18,%eax
f0103a43:	a2 2f c3 11 f0       	mov    %al,0xf011c32f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103a48:	c6 05 2d c3 11 f0 89 	movb   $0x89,0xf011c32d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103a4f:	b8 28 00 00 00       	mov    $0x28,%eax
f0103a54:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103a57:	b8 38 c3 11 f0       	mov    $0xf011c338,%eax
f0103a5c:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103a5f:	5d                   	pop    %ebp
f0103a60:	c3                   	ret    

f0103a61 <trap_init>:


extern char funs[];
void
trap_init(void)
{
f0103a61:	55                   	push   %ebp
f0103a62:	89 e5                	mov    %esp,%ebp
f0103a64:	83 ec 18             	sub    $0x18,%esp
	SETGATE(idt[13], 0, GD_KT, th13, 0);
	SETGATE(idt[14], 0, GD_KT, th14, 0);
	SETGATE(idt[16], 0, GD_KT, th16, 0);
*/
	// Challenge:
	cprintf("funs: %p\n", funs);
f0103a67:	c7 44 24 04 40 c3 11 	movl   $0xf011c340,0x4(%esp)
f0103a6e:	f0 
f0103a6f:	c7 04 24 fa 61 10 f0 	movl   $0xf01061fa,(%esp)
f0103a76:	e8 6f ff ff ff       	call   f01039ea <cprintf>
	SETGATE(idt[0], 0, GD_KT, ((void **)funs)[0], 0);
f0103a7b:	a1 40 c3 11 f0       	mov    0xf011c340,%eax
f0103a80:	66 a3 c0 f1 17 f0    	mov    %ax,0xf017f1c0
f0103a86:	66 c7 05 c2 f1 17 f0 	movw   $0x8,0xf017f1c2
f0103a8d:	08 00 
f0103a8f:	c6 05 c4 f1 17 f0 00 	movb   $0x0,0xf017f1c4
f0103a96:	c6 05 c5 f1 17 f0 8e 	movb   $0x8e,0xf017f1c5
f0103a9d:	c1 e8 10             	shr    $0x10,%eax
f0103aa0:	66 a3 c6 f1 17 f0    	mov    %ax,0xf017f1c6
	// Per-CPU setup 
	trap_init_percpu();
f0103aa6:	e8 59 ff ff ff       	call   f0103a04 <trap_init_percpu>
}
f0103aab:	c9                   	leave  
f0103aac:	c3                   	ret    

f0103aad <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103aad:	55                   	push   %ebp
f0103aae:	89 e5                	mov    %esp,%ebp
f0103ab0:	53                   	push   %ebx
f0103ab1:	83 ec 14             	sub    $0x14,%esp
f0103ab4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103ab7:	8b 03                	mov    (%ebx),%eax
f0103ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103abd:	c7 04 24 04 62 10 f0 	movl   $0xf0106204,(%esp)
f0103ac4:	e8 21 ff ff ff       	call   f01039ea <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103ac9:	8b 43 04             	mov    0x4(%ebx),%eax
f0103acc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ad0:	c7 04 24 13 62 10 f0 	movl   $0xf0106213,(%esp)
f0103ad7:	e8 0e ff ff ff       	call   f01039ea <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103adc:	8b 43 08             	mov    0x8(%ebx),%eax
f0103adf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ae3:	c7 04 24 22 62 10 f0 	movl   $0xf0106222,(%esp)
f0103aea:	e8 fb fe ff ff       	call   f01039ea <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103aef:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103af2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103af6:	c7 04 24 31 62 10 f0 	movl   $0xf0106231,(%esp)
f0103afd:	e8 e8 fe ff ff       	call   f01039ea <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103b02:	8b 43 10             	mov    0x10(%ebx),%eax
f0103b05:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b09:	c7 04 24 40 62 10 f0 	movl   $0xf0106240,(%esp)
f0103b10:	e8 d5 fe ff ff       	call   f01039ea <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103b15:	8b 43 14             	mov    0x14(%ebx),%eax
f0103b18:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b1c:	c7 04 24 4f 62 10 f0 	movl   $0xf010624f,(%esp)
f0103b23:	e8 c2 fe ff ff       	call   f01039ea <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103b28:	8b 43 18             	mov    0x18(%ebx),%eax
f0103b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b2f:	c7 04 24 5e 62 10 f0 	movl   $0xf010625e,(%esp)
f0103b36:	e8 af fe ff ff       	call   f01039ea <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103b3b:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b42:	c7 04 24 6d 62 10 f0 	movl   $0xf010626d,(%esp)
f0103b49:	e8 9c fe ff ff       	call   f01039ea <cprintf>
}
f0103b4e:	83 c4 14             	add    $0x14,%esp
f0103b51:	5b                   	pop    %ebx
f0103b52:	5d                   	pop    %ebp
f0103b53:	c3                   	ret    

f0103b54 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103b54:	55                   	push   %ebp
f0103b55:	89 e5                	mov    %esp,%ebp
f0103b57:	56                   	push   %esi
f0103b58:	53                   	push   %ebx
f0103b59:	83 ec 10             	sub    $0x10,%esp
f0103b5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103b5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103b63:	c7 04 24 a3 63 10 f0 	movl   $0xf01063a3,(%esp)
f0103b6a:	e8 7b fe ff ff       	call   f01039ea <cprintf>
	print_regs(&tf->tf_regs);
f0103b6f:	89 1c 24             	mov    %ebx,(%esp)
f0103b72:	e8 36 ff ff ff       	call   f0103aad <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103b77:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b7f:	c7 04 24 be 62 10 f0 	movl   $0xf01062be,(%esp)
f0103b86:	e8 5f fe ff ff       	call   f01039ea <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103b8b:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103b8f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b93:	c7 04 24 d1 62 10 f0 	movl   $0xf01062d1,(%esp)
f0103b9a:	e8 4b fe ff ff       	call   f01039ea <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103b9f:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103ba2:	83 f8 13             	cmp    $0x13,%eax
f0103ba5:	77 09                	ja     f0103bb0 <print_trapframe+0x5c>
		return excnames[trapno];
f0103ba7:	8b 14 85 80 65 10 f0 	mov    -0xfef9a80(,%eax,4),%edx
f0103bae:	eb 10                	jmp    f0103bc0 <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
		return "System call";
f0103bb0:	83 f8 30             	cmp    $0x30,%eax
f0103bb3:	ba 7c 62 10 f0       	mov    $0xf010627c,%edx
f0103bb8:	b9 88 62 10 f0       	mov    $0xf0106288,%ecx
f0103bbd:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103bc0:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103bc4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bc8:	c7 04 24 e4 62 10 f0 	movl   $0xf01062e4,(%esp)
f0103bcf:	e8 16 fe ff ff       	call   f01039ea <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103bd4:	3b 1d c0 f9 17 f0    	cmp    0xf017f9c0,%ebx
f0103bda:	75 19                	jne    f0103bf5 <print_trapframe+0xa1>
f0103bdc:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103be0:	75 13                	jne    f0103bf5 <print_trapframe+0xa1>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103be2:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103be5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103be9:	c7 04 24 f6 62 10 f0 	movl   $0xf01062f6,(%esp)
f0103bf0:	e8 f5 fd ff ff       	call   f01039ea <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0103bf5:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bfc:	c7 04 24 05 63 10 f0 	movl   $0xf0106305,(%esp)
f0103c03:	e8 e2 fd ff ff       	call   f01039ea <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103c08:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103c0c:	75 51                	jne    f0103c5f <print_trapframe+0x10b>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103c0e:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103c11:	89 c2                	mov    %eax,%edx
f0103c13:	83 e2 01             	and    $0x1,%edx
f0103c16:	ba 97 62 10 f0       	mov    $0xf0106297,%edx
f0103c1b:	b9 a2 62 10 f0       	mov    $0xf01062a2,%ecx
f0103c20:	0f 45 ca             	cmovne %edx,%ecx
f0103c23:	89 c2                	mov    %eax,%edx
f0103c25:	83 e2 02             	and    $0x2,%edx
f0103c28:	ba ae 62 10 f0       	mov    $0xf01062ae,%edx
f0103c2d:	be b4 62 10 f0       	mov    $0xf01062b4,%esi
f0103c32:	0f 44 d6             	cmove  %esi,%edx
f0103c35:	83 e0 04             	and    $0x4,%eax
f0103c38:	b8 b9 62 10 f0       	mov    $0xf01062b9,%eax
f0103c3d:	be ce 63 10 f0       	mov    $0xf01063ce,%esi
f0103c42:	0f 44 c6             	cmove  %esi,%eax
f0103c45:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103c49:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c51:	c7 04 24 13 63 10 f0 	movl   $0xf0106313,(%esp)
f0103c58:	e8 8d fd ff ff       	call   f01039ea <cprintf>
f0103c5d:	eb 0c                	jmp    f0103c6b <print_trapframe+0x117>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103c5f:	c7 04 24 2e 59 10 f0 	movl   $0xf010592e,(%esp)
f0103c66:	e8 7f fd ff ff       	call   f01039ea <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103c6b:	8b 43 30             	mov    0x30(%ebx),%eax
f0103c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c72:	c7 04 24 22 63 10 f0 	movl   $0xf0106322,(%esp)
f0103c79:	e8 6c fd ff ff       	call   f01039ea <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103c7e:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103c82:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c86:	c7 04 24 31 63 10 f0 	movl   $0xf0106331,(%esp)
f0103c8d:	e8 58 fd ff ff       	call   f01039ea <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103c92:	8b 43 38             	mov    0x38(%ebx),%eax
f0103c95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c99:	c7 04 24 44 63 10 f0 	movl   $0xf0106344,(%esp)
f0103ca0:	e8 45 fd ff ff       	call   f01039ea <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103ca5:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103ca9:	74 27                	je     f0103cd2 <print_trapframe+0x17e>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103cab:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103cae:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cb2:	c7 04 24 53 63 10 f0 	movl   $0xf0106353,(%esp)
f0103cb9:	e8 2c fd ff ff       	call   f01039ea <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103cbe:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103cc2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cc6:	c7 04 24 62 63 10 f0 	movl   $0xf0106362,(%esp)
f0103ccd:	e8 18 fd ff ff       	call   f01039ea <cprintf>
	}
}
f0103cd2:	83 c4 10             	add    $0x10,%esp
f0103cd5:	5b                   	pop    %ebx
f0103cd6:	5e                   	pop    %esi
f0103cd7:	5d                   	pop    %ebp
f0103cd8:	c3                   	ret    

f0103cd9 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103cd9:	55                   	push   %ebp
f0103cda:	89 e5                	mov    %esp,%ebp
f0103cdc:	57                   	push   %edi
f0103cdd:	56                   	push   %esi
f0103cde:	83 ec 10             	sub    $0x10,%esp
f0103ce1:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103ce4:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103ce5:	9c                   	pushf  
f0103ce6:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103ce7:	f6 c4 02             	test   $0x2,%ah
f0103cea:	74 24                	je     f0103d10 <trap+0x37>
f0103cec:	c7 44 24 0c 75 63 10 	movl   $0xf0106375,0xc(%esp)
f0103cf3:	f0 
f0103cf4:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0103cfb:	f0 
f0103cfc:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f0103d03:	00 
f0103d04:	c7 04 24 8e 63 10 f0 	movl   $0xf010638e,(%esp)
f0103d0b:	e8 06 c4 ff ff       	call   f0100116 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103d10:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103d14:	c7 04 24 9a 63 10 f0 	movl   $0xf010639a,(%esp)
f0103d1b:	e8 ca fc ff ff       	call   f01039ea <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103d20:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103d24:	83 e0 03             	and    $0x3,%eax
f0103d27:	83 f8 03             	cmp    $0x3,%eax
f0103d2a:	75 3c                	jne    f0103d68 <trap+0x8f>
		// Trapped from user mode.
		assert(curenv);
f0103d2c:	a1 9c f1 17 f0       	mov    0xf017f19c,%eax
f0103d31:	85 c0                	test   %eax,%eax
f0103d33:	75 24                	jne    f0103d59 <trap+0x80>
f0103d35:	c7 44 24 0c b5 63 10 	movl   $0xf01063b5,0xc(%esp)
f0103d3c:	f0 
f0103d3d:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0103d44:	f0 
f0103d45:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
f0103d4c:	00 
f0103d4d:	c7 04 24 8e 63 10 f0 	movl   $0xf010638e,(%esp)
f0103d54:	e8 bd c3 ff ff       	call   f0100116 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103d59:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103d5e:	89 c7                	mov    %eax,%edi
f0103d60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103d62:	8b 35 9c f1 17 f0    	mov    0xf017f19c,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103d68:	89 35 c0 f9 17 f0    	mov    %esi,0xf017f9c0
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103d6e:	89 34 24             	mov    %esi,(%esp)
f0103d71:	e8 de fd ff ff       	call   f0103b54 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103d76:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103d7b:	75 1c                	jne    f0103d99 <trap+0xc0>
		panic("unhandled trap in kernel");
f0103d7d:	c7 44 24 08 bc 63 10 	movl   $0xf01063bc,0x8(%esp)
f0103d84:	f0 
f0103d85:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
f0103d8c:	00 
f0103d8d:	c7 04 24 8e 63 10 f0 	movl   $0xf010638e,(%esp)
f0103d94:	e8 7d c3 ff ff       	call   f0100116 <_panic>
	else {
		env_destroy(curenv);
f0103d99:	a1 9c f1 17 f0       	mov    0xf017f19c,%eax
f0103d9e:	89 04 24             	mov    %eax,(%esp)
f0103da1:	e8 27 fb ff ff       	call   f01038cd <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103da6:	a1 9c f1 17 f0       	mov    0xf017f19c,%eax
f0103dab:	85 c0                	test   %eax,%eax
f0103dad:	74 06                	je     f0103db5 <trap+0xdc>
f0103daf:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103db3:	74 24                	je     f0103dd9 <trap+0x100>
f0103db5:	c7 44 24 0c 18 65 10 	movl   $0xf0106518,0xc(%esp)
f0103dbc:	f0 
f0103dbd:	c7 44 24 08 3a 56 10 	movl   $0xf010563a,0x8(%esp)
f0103dc4:	f0 
f0103dc5:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
f0103dcc:	00 
f0103dcd:	c7 04 24 8e 63 10 f0 	movl   $0xf010638e,(%esp)
f0103dd4:	e8 3d c3 ff ff       	call   f0100116 <_panic>
	env_run(curenv);
f0103dd9:	89 04 24             	mov    %eax,(%esp)
f0103ddc:	e8 43 fb ff ff       	call   f0103924 <env_run>

f0103de1 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103de1:	55                   	push   %ebp
f0103de2:	89 e5                	mov    %esp,%ebp
f0103de4:	53                   	push   %ebx
f0103de5:	83 ec 14             	sub    $0x14,%esp
f0103de8:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103deb:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103dee:	8b 53 30             	mov    0x30(%ebx),%edx
f0103df1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103df5:	89 44 24 08          	mov    %eax,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0103df9:	a1 9c f1 17 f0       	mov    0xf017f19c,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103dfe:	8b 40 48             	mov    0x48(%eax),%eax
f0103e01:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e05:	c7 04 24 44 65 10 f0 	movl   $0xf0106544,(%esp)
f0103e0c:	e8 d9 fb ff ff       	call   f01039ea <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103e11:	89 1c 24             	mov    %ebx,(%esp)
f0103e14:	e8 3b fd ff ff       	call   f0103b54 <print_trapframe>
	env_destroy(curenv);
f0103e19:	a1 9c f1 17 f0       	mov    0xf017f19c,%eax
f0103e1e:	89 04 24             	mov    %eax,(%esp)
f0103e21:	e8 a7 fa ff ff       	call   f01038cd <env_destroy>
}
f0103e26:	83 c4 14             	add    $0x14,%esp
f0103e29:	5b                   	pop    %ebx
f0103e2a:	5d                   	pop    %ebp
f0103e2b:	c3                   	ret    

/*
 * Challenge: my code here
 */
	#CSA_NOEC(th0, 0)					
	movl funs, %eax;
f0103e2c:	a1 40 c3 11 f0       	mov    0xf011c340,%eax
	movl th0, %ecx;
f0103e31:	8b 0d 3e 3e 10 f0    	mov    0xf0103e3e,%ecx
	movl $1000, (%eax);
f0103e37:	c7 00 e8 03 00 00    	movl   $0x3e8,(%eax)
f0103e3d:	90                   	nop

f0103e3e <th0>:
	.globl th0;							
	.type th0, @function;						
	.align 2;							
th0:								
	pushl $0;							
f0103e3e:	6a 00                	push   $0x0
	pushl $0;		
f0103e40:	6a 00                	push   $0x0
	jmp _alltraps
f0103e42:	eb 00                	jmp    f0103e44 <_alltraps>

f0103e44 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0103e44:	1e                   	push   %ds
	pushl %es
f0103e45:	06                   	push   %es
	pushal
f0103e46:	60                   	pusha  
	pushl $GD_KD
f0103e47:	6a 10                	push   $0x10
	popl %ds
f0103e49:	1f                   	pop    %ds
	pushl $GD_KD
f0103e4a:	6a 10                	push   $0x10
	popl %es
f0103e4c:	07                   	pop    %es
	pushl %esp
f0103e4d:	54                   	push   %esp
	call trap
f0103e4e:	e8 86 fe ff ff       	call   f0103cd9 <trap>
	...

f0103e54 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103e54:	55                   	push   %ebp
f0103e55:	89 e5                	mov    %esp,%ebp
f0103e57:	83 ec 18             	sub    $0x18,%esp
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	panic("syscall not implemented");
f0103e5a:	c7 44 24 08 d0 65 10 	movl   $0xf01065d0,0x8(%esp)
f0103e61:	f0 
f0103e62:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
f0103e69:	00 
f0103e6a:	c7 04 24 e8 65 10 f0 	movl   $0xf01065e8,(%esp)
f0103e71:	e8 a0 c2 ff ff       	call   f0100116 <_panic>
	...

f0103e78 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103e78:	55                   	push   %ebp
f0103e79:	89 e5                	mov    %esp,%ebp
f0103e7b:	57                   	push   %edi
f0103e7c:	56                   	push   %esi
f0103e7d:	53                   	push   %ebx
f0103e7e:	83 ec 14             	sub    $0x14,%esp
f0103e81:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103e84:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103e87:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103e8a:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103e8d:	8b 1a                	mov    (%edx),%ebx
f0103e8f:	8b 01                	mov    (%ecx),%eax
f0103e91:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0103e94:	39 c3                	cmp    %eax,%ebx
f0103e96:	0f 8f 9c 00 00 00    	jg     f0103f38 <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0103e9c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103ea3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103ea6:	01 d8                	add    %ebx,%eax
f0103ea8:	89 c7                	mov    %eax,%edi
f0103eaa:	c1 ef 1f             	shr    $0x1f,%edi
f0103ead:	01 c7                	add    %eax,%edi
f0103eaf:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103eb1:	39 df                	cmp    %ebx,%edi
f0103eb3:	7c 33                	jl     f0103ee8 <stab_binsearch+0x70>
f0103eb5:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103eb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103ebb:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103ec0:	39 f0                	cmp    %esi,%eax
f0103ec2:	0f 84 bc 00 00 00    	je     f0103f84 <stab_binsearch+0x10c>
f0103ec8:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103ecc:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103ed0:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103ed2:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103ed5:	39 d8                	cmp    %ebx,%eax
f0103ed7:	7c 0f                	jl     f0103ee8 <stab_binsearch+0x70>
f0103ed9:	0f b6 0a             	movzbl (%edx),%ecx
f0103edc:	83 ea 0c             	sub    $0xc,%edx
f0103edf:	39 f1                	cmp    %esi,%ecx
f0103ee1:	75 ef                	jne    f0103ed2 <stab_binsearch+0x5a>
f0103ee3:	e9 9e 00 00 00       	jmp    f0103f86 <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103ee8:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103eeb:	eb 3c                	jmp    f0103f29 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103eed:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103ef0:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0103ef2:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103ef5:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103efc:	eb 2b                	jmp    f0103f29 <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103efe:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103f01:	76 14                	jbe    f0103f17 <stab_binsearch+0x9f>
			*region_right = m - 1;
f0103f03:	83 e8 01             	sub    $0x1,%eax
f0103f06:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103f09:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103f0c:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103f0e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103f15:	eb 12                	jmp    f0103f29 <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103f17:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103f1a:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103f1c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103f20:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103f22:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103f29:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103f2c:	0f 8d 71 ff ff ff    	jge    f0103ea3 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103f32:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103f36:	75 0f                	jne    f0103f47 <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0103f38:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103f3b:	8b 03                	mov    (%ebx),%eax
f0103f3d:	83 e8 01             	sub    $0x1,%eax
f0103f40:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103f43:	89 02                	mov    %eax,(%edx)
f0103f45:	eb 57                	jmp    f0103f9e <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103f47:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103f4a:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103f4c:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103f4f:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103f51:	39 c1                	cmp    %eax,%ecx
f0103f53:	7d 28                	jge    f0103f7d <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0103f55:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103f58:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103f5b:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0103f60:	39 f2                	cmp    %esi,%edx
f0103f62:	74 19                	je     f0103f7d <stab_binsearch+0x105>
f0103f64:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103f68:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103f6c:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103f6f:	39 c1                	cmp    %eax,%ecx
f0103f71:	7d 0a                	jge    f0103f7d <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0103f73:	0f b6 1a             	movzbl (%edx),%ebx
f0103f76:	83 ea 0c             	sub    $0xc,%edx
f0103f79:	39 f3                	cmp    %esi,%ebx
f0103f7b:	75 ef                	jne    f0103f6c <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103f7d:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103f80:	89 02                	mov    %eax,(%edx)
f0103f82:	eb 1a                	jmp    f0103f9e <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103f84:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103f86:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103f89:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103f8c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103f90:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103f93:	0f 82 54 ff ff ff    	jb     f0103eed <stab_binsearch+0x75>
f0103f99:	e9 60 ff ff ff       	jmp    f0103efe <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103f9e:	83 c4 14             	add    $0x14,%esp
f0103fa1:	5b                   	pop    %ebx
f0103fa2:	5e                   	pop    %esi
f0103fa3:	5f                   	pop    %edi
f0103fa4:	5d                   	pop    %ebp
f0103fa5:	c3                   	ret    

f0103fa6 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103fa6:	55                   	push   %ebp
f0103fa7:	89 e5                	mov    %esp,%ebp
f0103fa9:	83 ec 68             	sub    $0x68,%esp
f0103fac:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103faf:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103fb2:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103fb5:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103fb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103fbb:	c7 03 f7 65 10 f0    	movl   $0xf01065f7,(%ebx)
	info->eip_line = 0;
f0103fc1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103fc8:	c7 43 08 f7 65 10 f0 	movl   $0xf01065f7,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103fcf:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103fd6:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103fd9:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103fe0:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0103fe6:	77 1f                	ja     f0104007 <debuginfo_eip+0x61>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103fe8:	a1 00 00 20 00       	mov    0x200000,%eax
f0103fed:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0103ff0:	8b 15 04 00 20 00    	mov    0x200004,%edx
		stabstr = usd->stabstr;
f0103ff6:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0103ffc:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103fff:	8b 35 0c 00 20 00    	mov    0x20000c,%esi
f0104005:	eb 18                	jmp    f010401f <debuginfo_eip+0x79>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104007:	be 5b 17 11 f0       	mov    $0xf011175b,%esi
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010400c:	c7 45 c4 81 eb 10 f0 	movl   $0xf010eb81,-0x3c(%ebp)
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104013:	ba 80 eb 10 f0       	mov    $0xf010eb80,%edx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104018:	c7 45 c0 10 68 10 f0 	movl   $0xf0106810,-0x40(%ebp)
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010401f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104024:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0104027:	0f 83 d5 01 00 00    	jae    f0104202 <debuginfo_eip+0x25c>
f010402d:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f0104031:	0f 85 bf 01 00 00    	jne    f01041f6 <debuginfo_eip+0x250>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104037:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010403e:	89 d0                	mov    %edx,%eax
f0104040:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0104043:	c1 f8 02             	sar    $0x2,%eax
f0104046:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010404c:	83 e8 01             	sub    $0x1,%eax
f010404f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104052:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104056:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010405d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104060:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104063:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104066:	e8 0d fe ff ff       	call   f0103e78 <stab_binsearch>
	if (lfile == 0)
f010406b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f010406e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0104073:	85 d2                	test   %edx,%edx
f0104075:	0f 84 87 01 00 00    	je     f0104202 <debuginfo_eip+0x25c>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010407b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f010407e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104081:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104084:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104088:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010408f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104092:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104095:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104098:	e8 db fd ff ff       	call   f0103e78 <stab_binsearch>

	if (lfun <= rfun) {
f010409d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01040a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01040a3:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f01040a6:	39 c2                	cmp    %eax,%edx
f01040a8:	7f 31                	jg     f01040db <debuginfo_eip+0x135>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01040aa:	6b c2 0c             	imul   $0xc,%edx,%eax
f01040ad:	03 45 c0             	add    -0x40(%ebp),%eax
f01040b0:	8b 08                	mov    (%eax),%ecx
f01040b2:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f01040b5:	89 f1                	mov    %esi,%ecx
f01040b7:	2b 4d c4             	sub    -0x3c(%ebp),%ecx
f01040ba:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f01040bd:	73 09                	jae    f01040c8 <debuginfo_eip+0x122>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01040bf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01040c2:	03 4d bc             	add    -0x44(%ebp),%ecx
f01040c5:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01040c8:	8b 40 08             	mov    0x8(%eax),%eax
f01040cb:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01040ce:	29 c7                	sub    %eax,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f01040d0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f01040d3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f01040d6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01040d9:	eb 0f                	jmp    f01040ea <debuginfo_eip+0x144>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01040db:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f01040de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01040e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01040e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01040e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01040ea:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01040f1:	00 
f01040f2:	8b 43 08             	mov    0x8(%ebx),%eax
f01040f5:	89 04 24             	mov    %eax,(%esp)
f01040f8:	e8 4d 09 00 00       	call   f0104a4a <strfind>
f01040fd:	2b 43 08             	sub    0x8(%ebx),%eax
f0104100:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104103:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104107:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f010410e:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104111:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104114:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104117:	e8 5c fd ff ff       	call   f0103e78 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f010411c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010411f:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0104122:	6b c2 0c             	imul   $0xc,%edx,%eax
f0104125:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104128:	0f b7 44 01 06       	movzwl 0x6(%ecx,%eax,1),%eax
f010412d:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104130:	89 d0                	mov    %edx,%eax
f0104132:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104135:	89 7d b8             	mov    %edi,-0x48(%ebp)
f0104138:	39 fa                	cmp    %edi,%edx
f010413a:	7c 68                	jl     f01041a4 <debuginfo_eip+0x1fe>
	       && stabs[lline].n_type != N_SOL
f010413c:	6b fa 0c             	imul   $0xc,%edx,%edi
f010413f:	01 cf                	add    %ecx,%edi
f0104141:	0f b6 4f 04          	movzbl 0x4(%edi),%ecx
f0104145:	80 f9 84             	cmp    $0x84,%cl
f0104148:	74 45                	je     f010418f <debuginfo_eip+0x1e9>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010414a:	8d 52 ff             	lea    -0x1(%edx),%edx
f010414d:	6b d2 0c             	imul   $0xc,%edx,%edx
f0104150:	03 55 c0             	add    -0x40(%ebp),%edx
f0104153:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0104156:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0104159:	eb 1e                	jmp    f0104179 <debuginfo_eip+0x1d3>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010415b:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010415e:	3b 45 b8             	cmp    -0x48(%ebp),%eax
f0104161:	7c 41                	jl     f01041a4 <debuginfo_eip+0x1fe>
f0104163:	89 d7                	mov    %edx,%edi
	       && stabs[lline].n_type != N_SOL
f0104165:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104169:	83 ea 0c             	sub    $0xc,%edx
f010416c:	80 f9 84             	cmp    $0x84,%cl
f010416f:	75 05                	jne    f0104176 <debuginfo_eip+0x1d0>
f0104171:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104174:	eb 19                	jmp    f010418f <debuginfo_eip+0x1e9>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104176:	89 45 bc             	mov    %eax,-0x44(%ebp)
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104179:	80 f9 64             	cmp    $0x64,%cl
f010417c:	75 dd                	jne    f010415b <debuginfo_eip+0x1b5>
f010417e:	83 7f 08 00          	cmpl   $0x0,0x8(%edi)
f0104182:	74 d7                	je     f010415b <debuginfo_eip+0x1b5>
f0104184:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104187:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010418a:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f010418d:	7f 15                	jg     f01041a4 <debuginfo_eip+0x1fe>
f010418f:	6b c0 0c             	imul   $0xc,%eax,%eax
f0104192:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104195:	8b 04 07             	mov    (%edi,%eax,1),%eax
f0104198:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f010419b:	39 f0                	cmp    %esi,%eax
f010419d:	73 05                	jae    f01041a4 <debuginfo_eip+0x1fe>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010419f:	03 45 c4             	add    -0x3c(%ebp),%eax
f01041a2:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01041a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01041a7:	89 45 bc             	mov    %eax,-0x44(%ebp)
f01041aa:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01041ad:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01041b2:	39 75 bc             	cmp    %esi,-0x44(%ebp)
f01041b5:	7d 4b                	jge    f0104202 <debuginfo_eip+0x25c>
		for (lline = lfun + 1;
f01041b7:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01041ba:	83 c2 01             	add    $0x1,%edx
f01041bd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01041c0:	39 d6                	cmp    %edx,%esi
f01041c2:	7e 3e                	jle    f0104202 <debuginfo_eip+0x25c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01041c4:	6b ca 0c             	imul   $0xc,%edx,%ecx
f01041c7:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01041ca:	80 7c 0f 04 a0       	cmpb   $0xa0,0x4(%edi,%ecx,1)
f01041cf:	75 31                	jne    f0104202 <debuginfo_eip+0x25c>
f01041d1:	6b 4d bc 0c          	imul   $0xc,-0x44(%ebp),%ecx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01041d5:	8d 44 0f 1c          	lea    0x1c(%edi,%ecx,1),%eax
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01041d9:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01041dd:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01041e0:	39 d6                	cmp    %edx,%esi
f01041e2:	7e 19                	jle    f01041fd <debuginfo_eip+0x257>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01041e4:	0f b6 08             	movzbl (%eax),%ecx
f01041e7:	83 c0 0c             	add    $0xc,%eax
f01041ea:	80 f9 a0             	cmp    $0xa0,%cl
f01041ed:	74 ea                	je     f01041d9 <debuginfo_eip+0x233>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01041ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01041f4:	eb 0c                	jmp    f0104202 <debuginfo_eip+0x25c>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01041f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01041fb:	eb 05                	jmp    f0104202 <debuginfo_eip+0x25c>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01041fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104202:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104205:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104208:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010420b:	89 ec                	mov    %ebp,%esp
f010420d:	5d                   	pop    %ebp
f010420e:	c3                   	ret    
	...

f0104210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104210:	55                   	push   %ebp
f0104211:	89 e5                	mov    %esp,%ebp
f0104213:	57                   	push   %edi
f0104214:	56                   	push   %esi
f0104215:	53                   	push   %ebx
f0104216:	83 ec 4c             	sub    $0x4c,%esp
f0104219:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010421c:	89 d6                	mov    %edx,%esi
f010421e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104221:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104224:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104227:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010422a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010422d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104230:	b8 00 00 00 00       	mov    $0x0,%eax
f0104235:	39 d0                	cmp    %edx,%eax
f0104237:	72 11                	jb     f010424a <printnum+0x3a>
f0104239:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010423c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
f010423f:	76 09                	jbe    f010424a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104241:	83 eb 01             	sub    $0x1,%ebx
f0104244:	85 db                	test   %ebx,%ebx
f0104246:	7f 5d                	jg     f01042a5 <printnum+0x95>
f0104248:	eb 6c                	jmp    f01042b6 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010424a:	89 7c 24 10          	mov    %edi,0x10(%esp)
f010424e:	83 eb 01             	sub    $0x1,%ebx
f0104251:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104255:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104258:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010425c:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104260:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0104264:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104267:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010426a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104271:	00 
f0104272:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104275:	89 14 24             	mov    %edx,(%esp)
f0104278:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010427b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010427f:	e8 4c 0a 00 00       	call   f0104cd0 <__udivdi3>
f0104284:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104287:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010428a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010428e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104292:	89 04 24             	mov    %eax,(%esp)
f0104295:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104299:	89 f2                	mov    %esi,%edx
f010429b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010429e:	e8 6d ff ff ff       	call   f0104210 <printnum>
f01042a3:	eb 11                	jmp    f01042b6 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01042a5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01042a9:	89 3c 24             	mov    %edi,(%esp)
f01042ac:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01042af:	83 eb 01             	sub    $0x1,%ebx
f01042b2:	85 db                	test   %ebx,%ebx
f01042b4:	7f ef                	jg     f01042a5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01042b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01042ba:	8b 74 24 04          	mov    0x4(%esp),%esi
f01042be:	8b 45 10             	mov    0x10(%ebp),%eax
f01042c1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01042c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01042cc:	00 
f01042cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01042d0:	89 14 24             	mov    %edx,(%esp)
f01042d3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01042d6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01042da:	e8 01 0b 00 00       	call   f0104de0 <__umoddi3>
f01042df:	89 74 24 04          	mov    %esi,0x4(%esp)
f01042e3:	0f be 80 01 66 10 f0 	movsbl -0xfef99ff(%eax),%eax
f01042ea:	89 04 24             	mov    %eax,(%esp)
f01042ed:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01042f0:	83 c4 4c             	add    $0x4c,%esp
f01042f3:	5b                   	pop    %ebx
f01042f4:	5e                   	pop    %esi
f01042f5:	5f                   	pop    %edi
f01042f6:	5d                   	pop    %ebp
f01042f7:	c3                   	ret    

f01042f8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01042f8:	55                   	push   %ebp
f01042f9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01042fb:	83 fa 01             	cmp    $0x1,%edx
f01042fe:	7e 0e                	jle    f010430e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104300:	8b 10                	mov    (%eax),%edx
f0104302:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104305:	89 08                	mov    %ecx,(%eax)
f0104307:	8b 02                	mov    (%edx),%eax
f0104309:	8b 52 04             	mov    0x4(%edx),%edx
f010430c:	eb 22                	jmp    f0104330 <getuint+0x38>
	else if (lflag)
f010430e:	85 d2                	test   %edx,%edx
f0104310:	74 10                	je     f0104322 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104312:	8b 10                	mov    (%eax),%edx
f0104314:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104317:	89 08                	mov    %ecx,(%eax)
f0104319:	8b 02                	mov    (%edx),%eax
f010431b:	ba 00 00 00 00       	mov    $0x0,%edx
f0104320:	eb 0e                	jmp    f0104330 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104322:	8b 10                	mov    (%eax),%edx
f0104324:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104327:	89 08                	mov    %ecx,(%eax)
f0104329:	8b 02                	mov    (%edx),%eax
f010432b:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104330:	5d                   	pop    %ebp
f0104331:	c3                   	ret    

f0104332 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0104332:	55                   	push   %ebp
f0104333:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104335:	83 fa 01             	cmp    $0x1,%edx
f0104338:	7e 0e                	jle    f0104348 <getint+0x16>
		return va_arg(*ap, long long);
f010433a:	8b 10                	mov    (%eax),%edx
f010433c:	8d 4a 08             	lea    0x8(%edx),%ecx
f010433f:	89 08                	mov    %ecx,(%eax)
f0104341:	8b 02                	mov    (%edx),%eax
f0104343:	8b 52 04             	mov    0x4(%edx),%edx
f0104346:	eb 22                	jmp    f010436a <getint+0x38>
	else if (lflag)
f0104348:	85 d2                	test   %edx,%edx
f010434a:	74 10                	je     f010435c <getint+0x2a>
		return va_arg(*ap, long);
f010434c:	8b 10                	mov    (%eax),%edx
f010434e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104351:	89 08                	mov    %ecx,(%eax)
f0104353:	8b 02                	mov    (%edx),%eax
f0104355:	89 c2                	mov    %eax,%edx
f0104357:	c1 fa 1f             	sar    $0x1f,%edx
f010435a:	eb 0e                	jmp    f010436a <getint+0x38>
	else
		return va_arg(*ap, int);
f010435c:	8b 10                	mov    (%eax),%edx
f010435e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104361:	89 08                	mov    %ecx,(%eax)
f0104363:	8b 02                	mov    (%edx),%eax
f0104365:	89 c2                	mov    %eax,%edx
f0104367:	c1 fa 1f             	sar    $0x1f,%edx
}
f010436a:	5d                   	pop    %ebp
f010436b:	c3                   	ret    

f010436c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010436c:	55                   	push   %ebp
f010436d:	89 e5                	mov    %esp,%ebp
f010436f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104372:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104376:	8b 10                	mov    (%eax),%edx
f0104378:	3b 50 04             	cmp    0x4(%eax),%edx
f010437b:	73 0a                	jae    f0104387 <sprintputch+0x1b>
		*b->buf++ = ch;
f010437d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104380:	88 0a                	mov    %cl,(%edx)
f0104382:	83 c2 01             	add    $0x1,%edx
f0104385:	89 10                	mov    %edx,(%eax)
}
f0104387:	5d                   	pop    %ebp
f0104388:	c3                   	ret    

f0104389 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104389:	55                   	push   %ebp
f010438a:	89 e5                	mov    %esp,%ebp
f010438c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010438f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104392:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104396:	8b 45 10             	mov    0x10(%ebp),%eax
f0104399:	89 44 24 08          	mov    %eax,0x8(%esp)
f010439d:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01043a7:	89 04 24             	mov    %eax,(%esp)
f01043aa:	e8 02 00 00 00       	call   f01043b1 <vprintfmt>
	va_end(ap);
}
f01043af:	c9                   	leave  
f01043b0:	c3                   	ret    

f01043b1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01043b1:	55                   	push   %ebp
f01043b2:	89 e5                	mov    %esp,%ebp
f01043b4:	57                   	push   %edi
f01043b5:	56                   	push   %esi
f01043b6:	53                   	push   %ebx
f01043b7:	83 ec 4c             	sub    $0x4c,%esp
f01043ba:	8b 7d 10             	mov    0x10(%ebp),%edi
f01043bd:	eb 23                	jmp    f01043e2 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
f01043bf:	85 c0                	test   %eax,%eax
f01043c1:	75 12                	jne    f01043d5 <vprintfmt+0x24>
				csa = 0x0700;
f01043c3:	c7 05 64 fe 17 f0 00 	movl   $0x700,0xf017fe64
f01043ca:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f01043cd:	83 c4 4c             	add    $0x4c,%esp
f01043d0:	5b                   	pop    %ebx
f01043d1:	5e                   	pop    %esi
f01043d2:	5f                   	pop    %edi
f01043d3:	5d                   	pop    %ebp
f01043d4:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
f01043d5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01043d8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01043dc:	89 04 24             	mov    %eax,(%esp)
f01043df:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01043e2:	0f b6 07             	movzbl (%edi),%eax
f01043e5:	83 c7 01             	add    $0x1,%edi
f01043e8:	83 f8 25             	cmp    $0x25,%eax
f01043eb:	75 d2                	jne    f01043bf <vprintfmt+0xe>
f01043ed:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f01043f1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01043f8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01043fd:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0104404:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0104409:	be 00 00 00 00       	mov    $0x0,%esi
f010440e:	eb 14                	jmp    f0104424 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
f0104410:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0104414:	eb 0e                	jmp    f0104424 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104416:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f010441a:	eb 08                	jmp    f0104424 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f010441c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010441f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104424:	0f b6 07             	movzbl (%edi),%eax
f0104427:	0f b6 c8             	movzbl %al,%ecx
f010442a:	83 c7 01             	add    $0x1,%edi
f010442d:	83 e8 23             	sub    $0x23,%eax
f0104430:	3c 55                	cmp    $0x55,%al
f0104432:	0f 87 ed 02 00 00    	ja     f0104725 <vprintfmt+0x374>
f0104438:	0f b6 c0             	movzbl %al,%eax
f010443b:	ff 24 85 8c 66 10 f0 	jmp    *-0xfef9974(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104442:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
f0104445:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0104448:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010444b:	83 f9 09             	cmp    $0x9,%ecx
f010444e:	77 3c                	ja     f010448c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104450:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104453:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
f0104456:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
f010445a:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f010445d:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0104460:	83 f9 09             	cmp    $0x9,%ecx
f0104463:	76 eb                	jbe    f0104450 <vprintfmt+0x9f>
f0104465:	eb 25                	jmp    f010448c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104467:	8b 45 14             	mov    0x14(%ebp),%eax
f010446a:	8d 48 04             	lea    0x4(%eax),%ecx
f010446d:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104470:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
f0104472:	eb 18                	jmp    f010448c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
f0104474:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104478:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010447b:	0f 48 c6             	cmovs  %esi,%eax
f010447e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104481:	eb a1                	jmp    f0104424 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
f0104483:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f010448a:	eb 98                	jmp    f0104424 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
f010448c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104490:	79 92                	jns    f0104424 <vprintfmt+0x73>
f0104492:	eb 88                	jmp    f010441c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104494:	83 c2 01             	add    $0x1,%edx
f0104497:	eb 8b                	jmp    f0104424 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104499:	8b 45 14             	mov    0x14(%ebp),%eax
f010449c:	8d 50 04             	lea    0x4(%eax),%edx
f010449f:	89 55 14             	mov    %edx,0x14(%ebp)
f01044a2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01044a5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01044a9:	8b 00                	mov    (%eax),%eax
f01044ab:	89 04 24             	mov    %eax,(%esp)
f01044ae:	ff 55 08             	call   *0x8(%ebp)
			break;
f01044b1:	e9 2c ff ff ff       	jmp    f01043e2 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01044b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01044b9:	8d 50 04             	lea    0x4(%eax),%edx
f01044bc:	89 55 14             	mov    %edx,0x14(%ebp)
f01044bf:	8b 00                	mov    (%eax),%eax
f01044c1:	89 c2                	mov    %eax,%edx
f01044c3:	c1 fa 1f             	sar    $0x1f,%edx
f01044c6:	31 d0                	xor    %edx,%eax
f01044c8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01044ca:	83 f8 06             	cmp    $0x6,%eax
f01044cd:	7f 0b                	jg     f01044da <vprintfmt+0x129>
f01044cf:	8b 14 85 e4 67 10 f0 	mov    -0xfef981c(,%eax,4),%edx
f01044d6:	85 d2                	test   %edx,%edx
f01044d8:	75 23                	jne    f01044fd <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
f01044da:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01044de:	c7 44 24 08 19 66 10 	movl   $0xf0106619,0x8(%esp)
f01044e5:	f0 
f01044e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01044e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01044f0:	89 04 24             	mov    %eax,(%esp)
f01044f3:	e8 91 fe ff ff       	call   f0104389 <printfmt>
f01044f8:	e9 e5 fe ff ff       	jmp    f01043e2 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
f01044fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104501:	c7 44 24 08 4c 56 10 	movl   $0xf010564c,0x8(%esp)
f0104508:	f0 
f0104509:	8b 55 0c             	mov    0xc(%ebp),%edx
f010450c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104510:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104513:	89 1c 24             	mov    %ebx,(%esp)
f0104516:	e8 6e fe ff ff       	call   f0104389 <printfmt>
f010451b:	e9 c2 fe ff ff       	jmp    f01043e2 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104520:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104523:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104526:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104529:	8b 45 14             	mov    0x14(%ebp),%eax
f010452c:	8d 50 04             	lea    0x4(%eax),%edx
f010452f:	89 55 14             	mov    %edx,0x14(%ebp)
f0104532:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0104534:	85 f6                	test   %esi,%esi
f0104536:	ba 12 66 10 f0       	mov    $0xf0106612,%edx
f010453b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f010453e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104542:	7e 06                	jle    f010454a <vprintfmt+0x199>
f0104544:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0104548:	75 13                	jne    f010455d <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010454a:	0f be 06             	movsbl (%esi),%eax
f010454d:	83 c6 01             	add    $0x1,%esi
f0104550:	85 c0                	test   %eax,%eax
f0104552:	0f 85 a2 00 00 00    	jne    f01045fa <vprintfmt+0x249>
f0104558:	e9 92 00 00 00       	jmp    f01045ef <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010455d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104561:	89 34 24             	mov    %esi,(%esp)
f0104564:	e8 52 03 00 00       	call   f01048bb <strnlen>
f0104569:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010456c:	29 c2                	sub    %eax,%edx
f010456e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104571:	85 d2                	test   %edx,%edx
f0104573:	7e d5                	jle    f010454a <vprintfmt+0x199>
					putch(padc, putdat);
f0104575:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
f0104579:	89 75 d8             	mov    %esi,-0x28(%ebp)
f010457c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010457f:	89 d3                	mov    %edx,%ebx
f0104581:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0104584:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104587:	89 c6                	mov    %eax,%esi
f0104589:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010458d:	89 34 24             	mov    %esi,(%esp)
f0104590:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104593:	83 eb 01             	sub    $0x1,%ebx
f0104596:	85 db                	test   %ebx,%ebx
f0104598:	7f ef                	jg     f0104589 <vprintfmt+0x1d8>
f010459a:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010459d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01045a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01045a3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01045aa:	eb 9e                	jmp    f010454a <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01045ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01045b0:	74 1b                	je     f01045cd <vprintfmt+0x21c>
f01045b2:	8d 50 e0             	lea    -0x20(%eax),%edx
f01045b5:	83 fa 5e             	cmp    $0x5e,%edx
f01045b8:	76 13                	jbe    f01045cd <vprintfmt+0x21c>
					putch('?', putdat);
f01045ba:	8b 55 0c             	mov    0xc(%ebp),%edx
f01045bd:	89 54 24 04          	mov    %edx,0x4(%esp)
f01045c1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01045c8:	ff 55 08             	call   *0x8(%ebp)
f01045cb:	eb 0d                	jmp    f01045da <vprintfmt+0x229>
				else
					putch(ch, putdat);
f01045cd:	8b 55 0c             	mov    0xc(%ebp),%edx
f01045d0:	89 54 24 04          	mov    %edx,0x4(%esp)
f01045d4:	89 04 24             	mov    %eax,(%esp)
f01045d7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01045da:	83 ef 01             	sub    $0x1,%edi
f01045dd:	0f be 06             	movsbl (%esi),%eax
f01045e0:	85 c0                	test   %eax,%eax
f01045e2:	74 05                	je     f01045e9 <vprintfmt+0x238>
f01045e4:	83 c6 01             	add    $0x1,%esi
f01045e7:	eb 17                	jmp    f0104600 <vprintfmt+0x24f>
f01045e9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01045ec:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01045ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01045f3:	7f 1c                	jg     f0104611 <vprintfmt+0x260>
f01045f5:	e9 e8 fd ff ff       	jmp    f01043e2 <vprintfmt+0x31>
f01045fa:	89 7d dc             	mov    %edi,-0x24(%ebp)
f01045fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104600:	85 db                	test   %ebx,%ebx
f0104602:	78 a8                	js     f01045ac <vprintfmt+0x1fb>
f0104604:	83 eb 01             	sub    $0x1,%ebx
f0104607:	79 a3                	jns    f01045ac <vprintfmt+0x1fb>
f0104609:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f010460c:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010460f:	eb de                	jmp    f01045ef <vprintfmt+0x23e>
f0104611:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104614:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104617:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010461a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010461e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104625:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104627:	83 eb 01             	sub    $0x1,%ebx
f010462a:	85 db                	test   %ebx,%ebx
f010462c:	7f ec                	jg     f010461a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010462e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104631:	e9 ac fd ff ff       	jmp    f01043e2 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104636:	8d 45 14             	lea    0x14(%ebp),%eax
f0104639:	e8 f4 fc ff ff       	call   f0104332 <getint>
f010463e:	89 c3                	mov    %eax,%ebx
f0104640:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0104642:	85 d2                	test   %edx,%edx
f0104644:	78 0a                	js     f0104650 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104646:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010464b:	e9 87 00 00 00       	jmp    f01046d7 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0104650:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104653:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104657:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010465e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104661:	89 d8                	mov    %ebx,%eax
f0104663:	89 f2                	mov    %esi,%edx
f0104665:	f7 d8                	neg    %eax
f0104667:	83 d2 00             	adc    $0x0,%edx
f010466a:	f7 da                	neg    %edx
			}
			base = 10;
f010466c:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0104671:	eb 64                	jmp    f01046d7 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104673:	8d 45 14             	lea    0x14(%ebp),%eax
f0104676:	e8 7d fc ff ff       	call   f01042f8 <getuint>
			base = 10;
f010467b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0104680:	eb 55                	jmp    f01046d7 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
f0104682:	8d 45 14             	lea    0x14(%ebp),%eax
f0104685:	e8 6e fc ff ff       	call   f01042f8 <getuint>
      base = 8;
f010468a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
f010468f:	eb 46                	jmp    f01046d7 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
f0104691:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104694:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104698:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010469f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01046a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01046a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01046a9:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01046b0:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01046b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01046b6:	8d 50 04             	lea    0x4(%eax),%edx
f01046b9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01046bc:	8b 00                	mov    (%eax),%eax
f01046be:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01046c3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01046c8:	eb 0d                	jmp    f01046d7 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01046ca:	8d 45 14             	lea    0x14(%ebp),%eax
f01046cd:	e8 26 fc ff ff       	call   f01042f8 <getuint>
			base = 16;
f01046d2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01046d7:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f01046db:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01046df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01046e2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01046e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01046ea:	89 04 24             	mov    %eax,(%esp)
f01046ed:	89 54 24 04          	mov    %edx,0x4(%esp)
f01046f1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01046f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01046f7:	e8 14 fb ff ff       	call   f0104210 <printnum>
			break;
f01046fc:	e9 e1 fc ff ff       	jmp    f01043e2 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104701:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104704:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104708:	89 0c 24             	mov    %ecx,(%esp)
f010470b:	ff 55 08             	call   *0x8(%ebp)
			break;
f010470e:	e9 cf fc ff ff       	jmp    f01043e2 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
f0104713:	8d 45 14             	lea    0x14(%ebp),%eax
f0104716:	e8 17 fc ff ff       	call   f0104332 <getint>
			csa = num;
f010471b:	a3 64 fe 17 f0       	mov    %eax,0xf017fe64
			break;
f0104720:	e9 bd fc ff ff       	jmp    f01043e2 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104725:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104728:	89 54 24 04          	mov    %edx,0x4(%esp)
f010472c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0104733:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104736:	83 ef 01             	sub    $0x1,%edi
f0104739:	eb 02                	jmp    f010473d <vprintfmt+0x38c>
f010473b:	89 c7                	mov    %eax,%edi
f010473d:	8d 47 ff             	lea    -0x1(%edi),%eax
f0104740:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104744:	75 f5                	jne    f010473b <vprintfmt+0x38a>
f0104746:	e9 97 fc ff ff       	jmp    f01043e2 <vprintfmt+0x31>

f010474b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010474b:	55                   	push   %ebp
f010474c:	89 e5                	mov    %esp,%ebp
f010474e:	83 ec 28             	sub    $0x28,%esp
f0104751:	8b 45 08             	mov    0x8(%ebp),%eax
f0104754:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104757:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010475a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010475e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104761:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104768:	85 c0                	test   %eax,%eax
f010476a:	74 30                	je     f010479c <vsnprintf+0x51>
f010476c:	85 d2                	test   %edx,%edx
f010476e:	7e 2c                	jle    f010479c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104770:	8b 45 14             	mov    0x14(%ebp),%eax
f0104773:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104777:	8b 45 10             	mov    0x10(%ebp),%eax
f010477a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010477e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104781:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104785:	c7 04 24 6c 43 10 f0 	movl   $0xf010436c,(%esp)
f010478c:	e8 20 fc ff ff       	call   f01043b1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104791:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104794:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104797:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010479a:	eb 05                	jmp    f01047a1 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010479c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01047a1:	c9                   	leave  
f01047a2:	c3                   	ret    

f01047a3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01047a3:	55                   	push   %ebp
f01047a4:	89 e5                	mov    %esp,%ebp
f01047a6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01047a9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01047ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01047b0:	8b 45 10             	mov    0x10(%ebp),%eax
f01047b3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01047b7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047be:	8b 45 08             	mov    0x8(%ebp),%eax
f01047c1:	89 04 24             	mov    %eax,(%esp)
f01047c4:	e8 82 ff ff ff       	call   f010474b <vsnprintf>
	va_end(ap);

	return rc;
}
f01047c9:	c9                   	leave  
f01047ca:	c3                   	ret    
f01047cb:	00 00                	add    %al,(%eax)
f01047cd:	00 00                	add    %al,(%eax)
	...

f01047d0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01047d0:	55                   	push   %ebp
f01047d1:	89 e5                	mov    %esp,%ebp
f01047d3:	57                   	push   %edi
f01047d4:	56                   	push   %esi
f01047d5:	53                   	push   %ebx
f01047d6:	83 ec 1c             	sub    $0x1c,%esp
f01047d9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01047dc:	85 c0                	test   %eax,%eax
f01047de:	74 10                	je     f01047f0 <readline+0x20>
		cprintf("%s", prompt);
f01047e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047e4:	c7 04 24 4c 56 10 f0 	movl   $0xf010564c,(%esp)
f01047eb:	e8 fa f1 ff ff       	call   f01039ea <cprintf>

	i = 0;
	echoing = iscons(0);
f01047f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01047f7:	e8 b6 be ff ff       	call   f01006b2 <iscons>
f01047fc:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01047fe:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104803:	e8 99 be ff ff       	call   f01006a1 <getchar>
f0104808:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010480a:	85 c0                	test   %eax,%eax
f010480c:	79 17                	jns    f0104825 <readline+0x55>
			cprintf("read error: %e\n", c);
f010480e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104812:	c7 04 24 00 68 10 f0 	movl   $0xf0106800,(%esp)
f0104819:	e8 cc f1 ff ff       	call   f01039ea <cprintf>
			return NULL;
f010481e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104823:	eb 6d                	jmp    f0104892 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104825:	83 f8 08             	cmp    $0x8,%eax
f0104828:	74 05                	je     f010482f <readline+0x5f>
f010482a:	83 f8 7f             	cmp    $0x7f,%eax
f010482d:	75 19                	jne    f0104848 <readline+0x78>
f010482f:	85 f6                	test   %esi,%esi
f0104831:	7e 15                	jle    f0104848 <readline+0x78>
			if (echoing)
f0104833:	85 ff                	test   %edi,%edi
f0104835:	74 0c                	je     f0104843 <readline+0x73>
				cputchar('\b');
f0104837:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010483e:	e8 4e be ff ff       	call   f0100691 <cputchar>
			i--;
f0104843:	83 ee 01             	sub    $0x1,%esi
f0104846:	eb bb                	jmp    f0104803 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104848:	83 fb 1f             	cmp    $0x1f,%ebx
f010484b:	7e 1f                	jle    f010486c <readline+0x9c>
f010484d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104853:	7f 17                	jg     f010486c <readline+0x9c>
			if (echoing)
f0104855:	85 ff                	test   %edi,%edi
f0104857:	74 08                	je     f0104861 <readline+0x91>
				cputchar(c);
f0104859:	89 1c 24             	mov    %ebx,(%esp)
f010485c:	e8 30 be ff ff       	call   f0100691 <cputchar>
			buf[i++] = c;
f0104861:	88 9e 60 fa 17 f0    	mov    %bl,-0xfe805a0(%esi)
f0104867:	83 c6 01             	add    $0x1,%esi
f010486a:	eb 97                	jmp    f0104803 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010486c:	83 fb 0a             	cmp    $0xa,%ebx
f010486f:	74 05                	je     f0104876 <readline+0xa6>
f0104871:	83 fb 0d             	cmp    $0xd,%ebx
f0104874:	75 8d                	jne    f0104803 <readline+0x33>
			if (echoing)
f0104876:	85 ff                	test   %edi,%edi
f0104878:	74 0c                	je     f0104886 <readline+0xb6>
				cputchar('\n');
f010487a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104881:	e8 0b be ff ff       	call   f0100691 <cputchar>
			buf[i] = 0;
f0104886:	c6 86 60 fa 17 f0 00 	movb   $0x0,-0xfe805a0(%esi)
			return buf;
f010488d:	b8 60 fa 17 f0       	mov    $0xf017fa60,%eax
		}
	}
}
f0104892:	83 c4 1c             	add    $0x1c,%esp
f0104895:	5b                   	pop    %ebx
f0104896:	5e                   	pop    %esi
f0104897:	5f                   	pop    %edi
f0104898:	5d                   	pop    %ebp
f0104899:	c3                   	ret    
f010489a:	00 00                	add    %al,(%eax)
f010489c:	00 00                	add    %al,(%eax)
	...

f01048a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01048a0:	55                   	push   %ebp
f01048a1:	89 e5                	mov    %esp,%ebp
f01048a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01048a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01048ab:	80 3a 00             	cmpb   $0x0,(%edx)
f01048ae:	74 09                	je     f01048b9 <strlen+0x19>
		n++;
f01048b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01048b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01048b7:	75 f7                	jne    f01048b0 <strlen+0x10>
		n++;
	return n;
}
f01048b9:	5d                   	pop    %ebp
f01048ba:	c3                   	ret    

f01048bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01048bb:	55                   	push   %ebp
f01048bc:	89 e5                	mov    %esp,%ebp
f01048be:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01048c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01048c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01048c9:	85 d2                	test   %edx,%edx
f01048cb:	74 12                	je     f01048df <strnlen+0x24>
f01048cd:	80 39 00             	cmpb   $0x0,(%ecx)
f01048d0:	74 0d                	je     f01048df <strnlen+0x24>
		n++;
f01048d2:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01048d5:	39 d0                	cmp    %edx,%eax
f01048d7:	74 06                	je     f01048df <strnlen+0x24>
f01048d9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01048dd:	75 f3                	jne    f01048d2 <strnlen+0x17>
		n++;
	return n;
}
f01048df:	5d                   	pop    %ebp
f01048e0:	c3                   	ret    

f01048e1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01048e1:	55                   	push   %ebp
f01048e2:	89 e5                	mov    %esp,%ebp
f01048e4:	53                   	push   %ebx
f01048e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01048e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01048eb:	ba 00 00 00 00       	mov    $0x0,%edx
f01048f0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01048f4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01048f7:	83 c2 01             	add    $0x1,%edx
f01048fa:	84 c9                	test   %cl,%cl
f01048fc:	75 f2                	jne    f01048f0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01048fe:	5b                   	pop    %ebx
f01048ff:	5d                   	pop    %ebp
f0104900:	c3                   	ret    

f0104901 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104901:	55                   	push   %ebp
f0104902:	89 e5                	mov    %esp,%ebp
f0104904:	53                   	push   %ebx
f0104905:	83 ec 08             	sub    $0x8,%esp
f0104908:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010490b:	89 1c 24             	mov    %ebx,(%esp)
f010490e:	e8 8d ff ff ff       	call   f01048a0 <strlen>
	strcpy(dst + len, src);
f0104913:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104916:	89 54 24 04          	mov    %edx,0x4(%esp)
f010491a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f010491d:	89 04 24             	mov    %eax,(%esp)
f0104920:	e8 bc ff ff ff       	call   f01048e1 <strcpy>
	return dst;
}
f0104925:	89 d8                	mov    %ebx,%eax
f0104927:	83 c4 08             	add    $0x8,%esp
f010492a:	5b                   	pop    %ebx
f010492b:	5d                   	pop    %ebp
f010492c:	c3                   	ret    

f010492d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010492d:	55                   	push   %ebp
f010492e:	89 e5                	mov    %esp,%ebp
f0104930:	56                   	push   %esi
f0104931:	53                   	push   %ebx
f0104932:	8b 45 08             	mov    0x8(%ebp),%eax
f0104935:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104938:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010493b:	85 f6                	test   %esi,%esi
f010493d:	74 18                	je     f0104957 <strncpy+0x2a>
f010493f:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0104944:	0f b6 1a             	movzbl (%edx),%ebx
f0104947:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010494a:	80 3a 01             	cmpb   $0x1,(%edx)
f010494d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104950:	83 c1 01             	add    $0x1,%ecx
f0104953:	39 ce                	cmp    %ecx,%esi
f0104955:	77 ed                	ja     f0104944 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104957:	5b                   	pop    %ebx
f0104958:	5e                   	pop    %esi
f0104959:	5d                   	pop    %ebp
f010495a:	c3                   	ret    

f010495b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010495b:	55                   	push   %ebp
f010495c:	89 e5                	mov    %esp,%ebp
f010495e:	56                   	push   %esi
f010495f:	53                   	push   %ebx
f0104960:	8b 75 08             	mov    0x8(%ebp),%esi
f0104963:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104966:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104969:	89 f0                	mov    %esi,%eax
f010496b:	85 c9                	test   %ecx,%ecx
f010496d:	74 23                	je     f0104992 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
f010496f:	83 e9 01             	sub    $0x1,%ecx
f0104972:	74 1b                	je     f010498f <strlcpy+0x34>
f0104974:	0f b6 1a             	movzbl (%edx),%ebx
f0104977:	84 db                	test   %bl,%bl
f0104979:	74 14                	je     f010498f <strlcpy+0x34>
			*dst++ = *src++;
f010497b:	88 18                	mov    %bl,(%eax)
f010497d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104980:	83 e9 01             	sub    $0x1,%ecx
f0104983:	74 0a                	je     f010498f <strlcpy+0x34>
			*dst++ = *src++;
f0104985:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104988:	0f b6 1a             	movzbl (%edx),%ebx
f010498b:	84 db                	test   %bl,%bl
f010498d:	75 ec                	jne    f010497b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
f010498f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104992:	29 f0                	sub    %esi,%eax
}
f0104994:	5b                   	pop    %ebx
f0104995:	5e                   	pop    %esi
f0104996:	5d                   	pop    %ebp
f0104997:	c3                   	ret    

f0104998 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104998:	55                   	push   %ebp
f0104999:	89 e5                	mov    %esp,%ebp
f010499b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010499e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01049a1:	0f b6 01             	movzbl (%ecx),%eax
f01049a4:	84 c0                	test   %al,%al
f01049a6:	74 15                	je     f01049bd <strcmp+0x25>
f01049a8:	3a 02                	cmp    (%edx),%al
f01049aa:	75 11                	jne    f01049bd <strcmp+0x25>
		p++, q++;
f01049ac:	83 c1 01             	add    $0x1,%ecx
f01049af:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01049b2:	0f b6 01             	movzbl (%ecx),%eax
f01049b5:	84 c0                	test   %al,%al
f01049b7:	74 04                	je     f01049bd <strcmp+0x25>
f01049b9:	3a 02                	cmp    (%edx),%al
f01049bb:	74 ef                	je     f01049ac <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01049bd:	0f b6 c0             	movzbl %al,%eax
f01049c0:	0f b6 12             	movzbl (%edx),%edx
f01049c3:	29 d0                	sub    %edx,%eax
}
f01049c5:	5d                   	pop    %ebp
f01049c6:	c3                   	ret    

f01049c7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01049c7:	55                   	push   %ebp
f01049c8:	89 e5                	mov    %esp,%ebp
f01049ca:	53                   	push   %ebx
f01049cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01049ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01049d1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01049d4:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01049d9:	85 d2                	test   %edx,%edx
f01049db:	74 28                	je     f0104a05 <strncmp+0x3e>
f01049dd:	0f b6 01             	movzbl (%ecx),%eax
f01049e0:	84 c0                	test   %al,%al
f01049e2:	74 24                	je     f0104a08 <strncmp+0x41>
f01049e4:	3a 03                	cmp    (%ebx),%al
f01049e6:	75 20                	jne    f0104a08 <strncmp+0x41>
f01049e8:	83 ea 01             	sub    $0x1,%edx
f01049eb:	74 13                	je     f0104a00 <strncmp+0x39>
		n--, p++, q++;
f01049ed:	83 c1 01             	add    $0x1,%ecx
f01049f0:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01049f3:	0f b6 01             	movzbl (%ecx),%eax
f01049f6:	84 c0                	test   %al,%al
f01049f8:	74 0e                	je     f0104a08 <strncmp+0x41>
f01049fa:	3a 03                	cmp    (%ebx),%al
f01049fc:	74 ea                	je     f01049e8 <strncmp+0x21>
f01049fe:	eb 08                	jmp    f0104a08 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104a00:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104a05:	5b                   	pop    %ebx
f0104a06:	5d                   	pop    %ebp
f0104a07:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104a08:	0f b6 01             	movzbl (%ecx),%eax
f0104a0b:	0f b6 13             	movzbl (%ebx),%edx
f0104a0e:	29 d0                	sub    %edx,%eax
f0104a10:	eb f3                	jmp    f0104a05 <strncmp+0x3e>

f0104a12 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104a12:	55                   	push   %ebp
f0104a13:	89 e5                	mov    %esp,%ebp
f0104a15:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a18:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104a1c:	0f b6 10             	movzbl (%eax),%edx
f0104a1f:	84 d2                	test   %dl,%dl
f0104a21:	74 20                	je     f0104a43 <strchr+0x31>
		if (*s == c)
f0104a23:	38 ca                	cmp    %cl,%dl
f0104a25:	75 0b                	jne    f0104a32 <strchr+0x20>
f0104a27:	eb 1f                	jmp    f0104a48 <strchr+0x36>
f0104a29:	38 ca                	cmp    %cl,%dl
f0104a2b:	90                   	nop
f0104a2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104a30:	74 16                	je     f0104a48 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104a32:	83 c0 01             	add    $0x1,%eax
f0104a35:	0f b6 10             	movzbl (%eax),%edx
f0104a38:	84 d2                	test   %dl,%dl
f0104a3a:	75 ed                	jne    f0104a29 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0104a3c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a41:	eb 05                	jmp    f0104a48 <strchr+0x36>
f0104a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104a48:	5d                   	pop    %ebp
f0104a49:	c3                   	ret    

f0104a4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104a4a:	55                   	push   %ebp
f0104a4b:	89 e5                	mov    %esp,%ebp
f0104a4d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104a54:	0f b6 10             	movzbl (%eax),%edx
f0104a57:	84 d2                	test   %dl,%dl
f0104a59:	74 14                	je     f0104a6f <strfind+0x25>
		if (*s == c)
f0104a5b:	38 ca                	cmp    %cl,%dl
f0104a5d:	75 06                	jne    f0104a65 <strfind+0x1b>
f0104a5f:	eb 0e                	jmp    f0104a6f <strfind+0x25>
f0104a61:	38 ca                	cmp    %cl,%dl
f0104a63:	74 0a                	je     f0104a6f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104a65:	83 c0 01             	add    $0x1,%eax
f0104a68:	0f b6 10             	movzbl (%eax),%edx
f0104a6b:	84 d2                	test   %dl,%dl
f0104a6d:	75 f2                	jne    f0104a61 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0104a6f:	5d                   	pop    %ebp
f0104a70:	c3                   	ret    

f0104a71 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104a71:	55                   	push   %ebp
f0104a72:	89 e5                	mov    %esp,%ebp
f0104a74:	83 ec 0c             	sub    $0xc,%esp
f0104a77:	89 1c 24             	mov    %ebx,(%esp)
f0104a7a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104a7e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104a82:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104a85:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104a88:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104a8b:	85 c9                	test   %ecx,%ecx
f0104a8d:	74 30                	je     f0104abf <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104a8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104a95:	75 25                	jne    f0104abc <memset+0x4b>
f0104a97:	f6 c1 03             	test   $0x3,%cl
f0104a9a:	75 20                	jne    f0104abc <memset+0x4b>
		c &= 0xFF;
f0104a9c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104a9f:	89 d3                	mov    %edx,%ebx
f0104aa1:	c1 e3 08             	shl    $0x8,%ebx
f0104aa4:	89 d6                	mov    %edx,%esi
f0104aa6:	c1 e6 18             	shl    $0x18,%esi
f0104aa9:	89 d0                	mov    %edx,%eax
f0104aab:	c1 e0 10             	shl    $0x10,%eax
f0104aae:	09 f0                	or     %esi,%eax
f0104ab0:	09 d0                	or     %edx,%eax
f0104ab2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104ab4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104ab7:	fc                   	cld    
f0104ab8:	f3 ab                	rep stos %eax,%es:(%edi)
f0104aba:	eb 03                	jmp    f0104abf <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104abc:	fc                   	cld    
f0104abd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104abf:	89 f8                	mov    %edi,%eax
f0104ac1:	8b 1c 24             	mov    (%esp),%ebx
f0104ac4:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104ac8:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0104acc:	89 ec                	mov    %ebp,%esp
f0104ace:	5d                   	pop    %ebp
f0104acf:	c3                   	ret    

f0104ad0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104ad0:	55                   	push   %ebp
f0104ad1:	89 e5                	mov    %esp,%ebp
f0104ad3:	83 ec 08             	sub    $0x8,%esp
f0104ad6:	89 34 24             	mov    %esi,(%esp)
f0104ad9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104add:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104ae3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104ae6:	39 c6                	cmp    %eax,%esi
f0104ae8:	73 36                	jae    f0104b20 <memmove+0x50>
f0104aea:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104aed:	39 d0                	cmp    %edx,%eax
f0104aef:	73 2f                	jae    f0104b20 <memmove+0x50>
		s += n;
		d += n;
f0104af1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104af4:	f6 c2 03             	test   $0x3,%dl
f0104af7:	75 1b                	jne    f0104b14 <memmove+0x44>
f0104af9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104aff:	75 13                	jne    f0104b14 <memmove+0x44>
f0104b01:	f6 c1 03             	test   $0x3,%cl
f0104b04:	75 0e                	jne    f0104b14 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104b06:	83 ef 04             	sub    $0x4,%edi
f0104b09:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104b0c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104b0f:	fd                   	std    
f0104b10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104b12:	eb 09                	jmp    f0104b1d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104b14:	83 ef 01             	sub    $0x1,%edi
f0104b17:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104b1a:	fd                   	std    
f0104b1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104b1d:	fc                   	cld    
f0104b1e:	eb 20                	jmp    f0104b40 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104b20:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104b26:	75 13                	jne    f0104b3b <memmove+0x6b>
f0104b28:	a8 03                	test   $0x3,%al
f0104b2a:	75 0f                	jne    f0104b3b <memmove+0x6b>
f0104b2c:	f6 c1 03             	test   $0x3,%cl
f0104b2f:	75 0a                	jne    f0104b3b <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104b31:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104b34:	89 c7                	mov    %eax,%edi
f0104b36:	fc                   	cld    
f0104b37:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104b39:	eb 05                	jmp    f0104b40 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104b3b:	89 c7                	mov    %eax,%edi
f0104b3d:	fc                   	cld    
f0104b3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104b40:	8b 34 24             	mov    (%esp),%esi
f0104b43:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104b47:	89 ec                	mov    %ebp,%esp
f0104b49:	5d                   	pop    %ebp
f0104b4a:	c3                   	ret    

f0104b4b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104b4b:	55                   	push   %ebp
f0104b4c:	89 e5                	mov    %esp,%ebp
f0104b4e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104b51:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b54:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b58:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104b5b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b62:	89 04 24             	mov    %eax,(%esp)
f0104b65:	e8 66 ff ff ff       	call   f0104ad0 <memmove>
}
f0104b6a:	c9                   	leave  
f0104b6b:	c3                   	ret    

f0104b6c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104b6c:	55                   	push   %ebp
f0104b6d:	89 e5                	mov    %esp,%ebp
f0104b6f:	57                   	push   %edi
f0104b70:	56                   	push   %esi
f0104b71:	53                   	push   %ebx
f0104b72:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104b75:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104b78:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104b7b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104b80:	85 ff                	test   %edi,%edi
f0104b82:	74 38                	je     f0104bbc <memcmp+0x50>
		if (*s1 != *s2)
f0104b84:	0f b6 03             	movzbl (%ebx),%eax
f0104b87:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104b8a:	83 ef 01             	sub    $0x1,%edi
f0104b8d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0104b92:	38 c8                	cmp    %cl,%al
f0104b94:	74 1d                	je     f0104bb3 <memcmp+0x47>
f0104b96:	eb 11                	jmp    f0104ba9 <memcmp+0x3d>
f0104b98:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0104b9d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
f0104ba2:	83 c2 01             	add    $0x1,%edx
f0104ba5:	38 c8                	cmp    %cl,%al
f0104ba7:	74 0a                	je     f0104bb3 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
f0104ba9:	0f b6 c0             	movzbl %al,%eax
f0104bac:	0f b6 c9             	movzbl %cl,%ecx
f0104baf:	29 c8                	sub    %ecx,%eax
f0104bb1:	eb 09                	jmp    f0104bbc <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104bb3:	39 fa                	cmp    %edi,%edx
f0104bb5:	75 e1                	jne    f0104b98 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104bb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104bbc:	5b                   	pop    %ebx
f0104bbd:	5e                   	pop    %esi
f0104bbe:	5f                   	pop    %edi
f0104bbf:	5d                   	pop    %ebp
f0104bc0:	c3                   	ret    

f0104bc1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104bc1:	55                   	push   %ebp
f0104bc2:	89 e5                	mov    %esp,%ebp
f0104bc4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104bc7:	89 c2                	mov    %eax,%edx
f0104bc9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104bcc:	39 d0                	cmp    %edx,%eax
f0104bce:	73 15                	jae    f0104be5 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104bd0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0104bd4:	38 08                	cmp    %cl,(%eax)
f0104bd6:	75 06                	jne    f0104bde <memfind+0x1d>
f0104bd8:	eb 0b                	jmp    f0104be5 <memfind+0x24>
f0104bda:	38 08                	cmp    %cl,(%eax)
f0104bdc:	74 07                	je     f0104be5 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104bde:	83 c0 01             	add    $0x1,%eax
f0104be1:	39 c2                	cmp    %eax,%edx
f0104be3:	77 f5                	ja     f0104bda <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104be5:	5d                   	pop    %ebp
f0104be6:	c3                   	ret    

f0104be7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104be7:	55                   	push   %ebp
f0104be8:	89 e5                	mov    %esp,%ebp
f0104bea:	57                   	push   %edi
f0104beb:	56                   	push   %esi
f0104bec:	53                   	push   %ebx
f0104bed:	8b 55 08             	mov    0x8(%ebp),%edx
f0104bf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104bf3:	0f b6 02             	movzbl (%edx),%eax
f0104bf6:	3c 20                	cmp    $0x20,%al
f0104bf8:	74 04                	je     f0104bfe <strtol+0x17>
f0104bfa:	3c 09                	cmp    $0x9,%al
f0104bfc:	75 0e                	jne    f0104c0c <strtol+0x25>
		s++;
f0104bfe:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104c01:	0f b6 02             	movzbl (%edx),%eax
f0104c04:	3c 20                	cmp    $0x20,%al
f0104c06:	74 f6                	je     f0104bfe <strtol+0x17>
f0104c08:	3c 09                	cmp    $0x9,%al
f0104c0a:	74 f2                	je     f0104bfe <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104c0c:	3c 2b                	cmp    $0x2b,%al
f0104c0e:	75 0a                	jne    f0104c1a <strtol+0x33>
		s++;
f0104c10:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104c13:	bf 00 00 00 00       	mov    $0x0,%edi
f0104c18:	eb 10                	jmp    f0104c2a <strtol+0x43>
f0104c1a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104c1f:	3c 2d                	cmp    $0x2d,%al
f0104c21:	75 07                	jne    f0104c2a <strtol+0x43>
		s++, neg = 1;
f0104c23:	83 c2 01             	add    $0x1,%edx
f0104c26:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104c2a:	85 db                	test   %ebx,%ebx
f0104c2c:	0f 94 c0             	sete   %al
f0104c2f:	74 05                	je     f0104c36 <strtol+0x4f>
f0104c31:	83 fb 10             	cmp    $0x10,%ebx
f0104c34:	75 15                	jne    f0104c4b <strtol+0x64>
f0104c36:	80 3a 30             	cmpb   $0x30,(%edx)
f0104c39:	75 10                	jne    f0104c4b <strtol+0x64>
f0104c3b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104c3f:	75 0a                	jne    f0104c4b <strtol+0x64>
		s += 2, base = 16;
f0104c41:	83 c2 02             	add    $0x2,%edx
f0104c44:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104c49:	eb 13                	jmp    f0104c5e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0104c4b:	84 c0                	test   %al,%al
f0104c4d:	74 0f                	je     f0104c5e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104c4f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104c54:	80 3a 30             	cmpb   $0x30,(%edx)
f0104c57:	75 05                	jne    f0104c5e <strtol+0x77>
		s++, base = 8;
f0104c59:	83 c2 01             	add    $0x1,%edx
f0104c5c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0104c5e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c63:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104c65:	0f b6 0a             	movzbl (%edx),%ecx
f0104c68:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104c6b:	80 fb 09             	cmp    $0x9,%bl
f0104c6e:	77 08                	ja     f0104c78 <strtol+0x91>
			dig = *s - '0';
f0104c70:	0f be c9             	movsbl %cl,%ecx
f0104c73:	83 e9 30             	sub    $0x30,%ecx
f0104c76:	eb 1e                	jmp    f0104c96 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0104c78:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0104c7b:	80 fb 19             	cmp    $0x19,%bl
f0104c7e:	77 08                	ja     f0104c88 <strtol+0xa1>
			dig = *s - 'a' + 10;
f0104c80:	0f be c9             	movsbl %cl,%ecx
f0104c83:	83 e9 57             	sub    $0x57,%ecx
f0104c86:	eb 0e                	jmp    f0104c96 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0104c88:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0104c8b:	80 fb 19             	cmp    $0x19,%bl
f0104c8e:	77 15                	ja     f0104ca5 <strtol+0xbe>
			dig = *s - 'A' + 10;
f0104c90:	0f be c9             	movsbl %cl,%ecx
f0104c93:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104c96:	39 f1                	cmp    %esi,%ecx
f0104c98:	7d 0f                	jge    f0104ca9 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
f0104c9a:	83 c2 01             	add    $0x1,%edx
f0104c9d:	0f af c6             	imul   %esi,%eax
f0104ca0:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0104ca3:	eb c0                	jmp    f0104c65 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0104ca5:	89 c1                	mov    %eax,%ecx
f0104ca7:	eb 02                	jmp    f0104cab <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104ca9:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104cab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104caf:	74 05                	je     f0104cb6 <strtol+0xcf>
		*endptr = (char *) s;
f0104cb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cb4:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104cb6:	89 ca                	mov    %ecx,%edx
f0104cb8:	f7 da                	neg    %edx
f0104cba:	85 ff                	test   %edi,%edi
f0104cbc:	0f 45 c2             	cmovne %edx,%eax
}
f0104cbf:	5b                   	pop    %ebx
f0104cc0:	5e                   	pop    %esi
f0104cc1:	5f                   	pop    %edi
f0104cc2:	5d                   	pop    %ebp
f0104cc3:	c3                   	ret    
	...

f0104cd0 <__udivdi3>:
f0104cd0:	55                   	push   %ebp
f0104cd1:	89 e5                	mov    %esp,%ebp
f0104cd3:	57                   	push   %edi
f0104cd4:	56                   	push   %esi
f0104cd5:	83 ec 10             	sub    $0x10,%esp
f0104cd8:	8b 75 14             	mov    0x14(%ebp),%esi
f0104cdb:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cde:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104ce1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104ce4:	85 f6                	test   %esi,%esi
f0104ce6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ce9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104cec:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0104cef:	75 2f                	jne    f0104d20 <__udivdi3+0x50>
f0104cf1:	39 f9                	cmp    %edi,%ecx
f0104cf3:	77 5b                	ja     f0104d50 <__udivdi3+0x80>
f0104cf5:	85 c9                	test   %ecx,%ecx
f0104cf7:	75 0b                	jne    f0104d04 <__udivdi3+0x34>
f0104cf9:	b8 01 00 00 00       	mov    $0x1,%eax
f0104cfe:	31 d2                	xor    %edx,%edx
f0104d00:	f7 f1                	div    %ecx
f0104d02:	89 c1                	mov    %eax,%ecx
f0104d04:	89 f8                	mov    %edi,%eax
f0104d06:	31 d2                	xor    %edx,%edx
f0104d08:	f7 f1                	div    %ecx
f0104d0a:	89 c7                	mov    %eax,%edi
f0104d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104d0f:	f7 f1                	div    %ecx
f0104d11:	89 fa                	mov    %edi,%edx
f0104d13:	83 c4 10             	add    $0x10,%esp
f0104d16:	5e                   	pop    %esi
f0104d17:	5f                   	pop    %edi
f0104d18:	5d                   	pop    %ebp
f0104d19:	c3                   	ret    
f0104d1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104d20:	31 d2                	xor    %edx,%edx
f0104d22:	31 c0                	xor    %eax,%eax
f0104d24:	39 fe                	cmp    %edi,%esi
f0104d26:	77 eb                	ja     f0104d13 <__udivdi3+0x43>
f0104d28:	0f bd d6             	bsr    %esi,%edx
f0104d2b:	83 f2 1f             	xor    $0x1f,%edx
f0104d2e:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0104d31:	75 2d                	jne    f0104d60 <__udivdi3+0x90>
f0104d33:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104d36:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
f0104d39:	76 06                	jbe    f0104d41 <__udivdi3+0x71>
f0104d3b:	39 fe                	cmp    %edi,%esi
f0104d3d:	89 c2                	mov    %eax,%edx
f0104d3f:	73 d2                	jae    f0104d13 <__udivdi3+0x43>
f0104d41:	31 d2                	xor    %edx,%edx
f0104d43:	b8 01 00 00 00       	mov    $0x1,%eax
f0104d48:	eb c9                	jmp    f0104d13 <__udivdi3+0x43>
f0104d4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104d50:	89 fa                	mov    %edi,%edx
f0104d52:	f7 f1                	div    %ecx
f0104d54:	31 d2                	xor    %edx,%edx
f0104d56:	83 c4 10             	add    $0x10,%esp
f0104d59:	5e                   	pop    %esi
f0104d5a:	5f                   	pop    %edi
f0104d5b:	5d                   	pop    %ebp
f0104d5c:	c3                   	ret    
f0104d5d:	8d 76 00             	lea    0x0(%esi),%esi
f0104d60:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0104d64:	b8 20 00 00 00       	mov    $0x20,%eax
f0104d69:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104d6c:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0104d6f:	d3 e6                	shl    %cl,%esi
f0104d71:	89 c1                	mov    %eax,%ecx
f0104d73:	d3 ea                	shr    %cl,%edx
f0104d75:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0104d79:	09 f2                	or     %esi,%edx
f0104d7b:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104d7e:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0104d81:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104d84:	d3 e2                	shl    %cl,%edx
f0104d86:	89 c1                	mov    %eax,%ecx
f0104d88:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0104d8b:	89 fa                	mov    %edi,%edx
f0104d8d:	d3 ea                	shr    %cl,%edx
f0104d8f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0104d93:	d3 e7                	shl    %cl,%edi
f0104d95:	89 c1                	mov    %eax,%ecx
f0104d97:	d3 ee                	shr    %cl,%esi
f0104d99:	09 fe                	or     %edi,%esi
f0104d9b:	89 f0                	mov    %esi,%eax
f0104d9d:	f7 75 e8             	divl   -0x18(%ebp)
f0104da0:	89 d7                	mov    %edx,%edi
f0104da2:	89 c6                	mov    %eax,%esi
f0104da4:	f7 65 f0             	mull   -0x10(%ebp)
f0104da7:	39 d7                	cmp    %edx,%edi
f0104da9:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0104dac:	72 22                	jb     f0104dd0 <__udivdi3+0x100>
f0104dae:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0104db1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0104db5:	d3 e2                	shl    %cl,%edx
f0104db7:	39 c2                	cmp    %eax,%edx
f0104db9:	73 05                	jae    f0104dc0 <__udivdi3+0xf0>
f0104dbb:	3b 7d f0             	cmp    -0x10(%ebp),%edi
f0104dbe:	74 10                	je     f0104dd0 <__udivdi3+0x100>
f0104dc0:	89 f0                	mov    %esi,%eax
f0104dc2:	31 d2                	xor    %edx,%edx
f0104dc4:	e9 4a ff ff ff       	jmp    f0104d13 <__udivdi3+0x43>
f0104dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104dd0:	8d 46 ff             	lea    -0x1(%esi),%eax
f0104dd3:	31 d2                	xor    %edx,%edx
f0104dd5:	83 c4 10             	add    $0x10,%esp
f0104dd8:	5e                   	pop    %esi
f0104dd9:	5f                   	pop    %edi
f0104dda:	5d                   	pop    %ebp
f0104ddb:	c3                   	ret    
f0104ddc:	00 00                	add    %al,(%eax)
	...

f0104de0 <__umoddi3>:
f0104de0:	55                   	push   %ebp
f0104de1:	89 e5                	mov    %esp,%ebp
f0104de3:	57                   	push   %edi
f0104de4:	56                   	push   %esi
f0104de5:	83 ec 20             	sub    $0x20,%esp
f0104de8:	8b 7d 14             	mov    0x14(%ebp),%edi
f0104deb:	8b 45 08             	mov    0x8(%ebp),%eax
f0104dee:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104df1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104df4:	85 ff                	test   %edi,%edi
f0104df6:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0104df9:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0104dfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104dff:	89 f2                	mov    %esi,%edx
f0104e01:	75 15                	jne    f0104e18 <__umoddi3+0x38>
f0104e03:	39 f1                	cmp    %esi,%ecx
f0104e05:	76 41                	jbe    f0104e48 <__umoddi3+0x68>
f0104e07:	f7 f1                	div    %ecx
f0104e09:	89 d0                	mov    %edx,%eax
f0104e0b:	31 d2                	xor    %edx,%edx
f0104e0d:	83 c4 20             	add    $0x20,%esp
f0104e10:	5e                   	pop    %esi
f0104e11:	5f                   	pop    %edi
f0104e12:	5d                   	pop    %ebp
f0104e13:	c3                   	ret    
f0104e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104e18:	39 f7                	cmp    %esi,%edi
f0104e1a:	77 4c                	ja     f0104e68 <__umoddi3+0x88>
f0104e1c:	0f bd c7             	bsr    %edi,%eax
f0104e1f:	83 f0 1f             	xor    $0x1f,%eax
f0104e22:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104e25:	75 51                	jne    f0104e78 <__umoddi3+0x98>
f0104e27:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0104e2a:	0f 87 e8 00 00 00    	ja     f0104f18 <__umoddi3+0x138>
f0104e30:	89 f2                	mov    %esi,%edx
f0104e32:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0104e35:	29 ce                	sub    %ecx,%esi
f0104e37:	19 fa                	sbb    %edi,%edx
f0104e39:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0104e3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e3f:	83 c4 20             	add    $0x20,%esp
f0104e42:	5e                   	pop    %esi
f0104e43:	5f                   	pop    %edi
f0104e44:	5d                   	pop    %ebp
f0104e45:	c3                   	ret    
f0104e46:	66 90                	xchg   %ax,%ax
f0104e48:	85 c9                	test   %ecx,%ecx
f0104e4a:	75 0b                	jne    f0104e57 <__umoddi3+0x77>
f0104e4c:	b8 01 00 00 00       	mov    $0x1,%eax
f0104e51:	31 d2                	xor    %edx,%edx
f0104e53:	f7 f1                	div    %ecx
f0104e55:	89 c1                	mov    %eax,%ecx
f0104e57:	89 f0                	mov    %esi,%eax
f0104e59:	31 d2                	xor    %edx,%edx
f0104e5b:	f7 f1                	div    %ecx
f0104e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e60:	eb a5                	jmp    f0104e07 <__umoddi3+0x27>
f0104e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104e68:	89 f2                	mov    %esi,%edx
f0104e6a:	83 c4 20             	add    $0x20,%esp
f0104e6d:	5e                   	pop    %esi
f0104e6e:	5f                   	pop    %edi
f0104e6f:	5d                   	pop    %ebp
f0104e70:	c3                   	ret    
f0104e71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104e78:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0104e7c:	89 f2                	mov    %esi,%edx
f0104e7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104e81:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
f0104e88:	29 45 f0             	sub    %eax,-0x10(%ebp)
f0104e8b:	d3 e7                	shl    %cl,%edi
f0104e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e90:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0104e94:	d3 e8                	shr    %cl,%eax
f0104e96:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0104e9a:	09 f8                	or     %edi,%eax
f0104e9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ea2:	d3 e0                	shl    %cl,%eax
f0104ea4:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0104ea8:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0104eab:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104eae:	d3 ea                	shr    %cl,%edx
f0104eb0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0104eb4:	d3 e6                	shl    %cl,%esi
f0104eb6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0104eba:	d3 e8                	shr    %cl,%eax
f0104ebc:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0104ec0:	09 f0                	or     %esi,%eax
f0104ec2:	8b 75 e8             	mov    -0x18(%ebp),%esi
f0104ec5:	f7 75 e4             	divl   -0x1c(%ebp)
f0104ec8:	d3 e6                	shl    %cl,%esi
f0104eca:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0104ecd:	89 d6                	mov    %edx,%esi
f0104ecf:	f7 65 f4             	mull   -0xc(%ebp)
f0104ed2:	89 d7                	mov    %edx,%edi
f0104ed4:	89 c2                	mov    %eax,%edx
f0104ed6:	39 fe                	cmp    %edi,%esi
f0104ed8:	89 f9                	mov    %edi,%ecx
f0104eda:	72 30                	jb     f0104f0c <__umoddi3+0x12c>
f0104edc:	39 45 e8             	cmp    %eax,-0x18(%ebp)
f0104edf:	72 27                	jb     f0104f08 <__umoddi3+0x128>
f0104ee1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104ee4:	29 d0                	sub    %edx,%eax
f0104ee6:	19 ce                	sbb    %ecx,%esi
f0104ee8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0104eec:	89 f2                	mov    %esi,%edx
f0104eee:	d3 e8                	shr    %cl,%eax
f0104ef0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0104ef4:	d3 e2                	shl    %cl,%edx
f0104ef6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0104efa:	09 d0                	or     %edx,%eax
f0104efc:	89 f2                	mov    %esi,%edx
f0104efe:	d3 ea                	shr    %cl,%edx
f0104f00:	83 c4 20             	add    $0x20,%esp
f0104f03:	5e                   	pop    %esi
f0104f04:	5f                   	pop    %edi
f0104f05:	5d                   	pop    %ebp
f0104f06:	c3                   	ret    
f0104f07:	90                   	nop
f0104f08:	39 fe                	cmp    %edi,%esi
f0104f0a:	75 d5                	jne    f0104ee1 <__umoddi3+0x101>
f0104f0c:	89 f9                	mov    %edi,%ecx
f0104f0e:	89 c2                	mov    %eax,%edx
f0104f10:	2b 55 f4             	sub    -0xc(%ebp),%edx
f0104f13:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0104f16:	eb c9                	jmp    f0104ee1 <__umoddi3+0x101>
f0104f18:	39 f7                	cmp    %esi,%edi
f0104f1a:	0f 82 10 ff ff ff    	jb     f0104e30 <__umoddi3+0x50>
f0104f20:	e9 17 ff ff ff       	jmp    f0104e3c <__umoddi3+0x5c>
