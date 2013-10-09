
obj/user/testbss:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 ef 00 00 00       	call   800120 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 80 12 80 00 	movl   $0x801280,(%esp)
  800041:	e8 39 02 00 00       	call   80027f <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800046:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  80004d:	75 11                	jne    800060 <umain+0x2c>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != 0)
  800054:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  80005b:	00 
  80005c:	74 27                	je     800085 <umain+0x51>
  80005e:	eb 05                	jmp    800065 <umain+0x31>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
  800065:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800069:	c7 44 24 08 fb 12 80 	movl   $0x8012fb,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 18 13 80 00 	movl   $0x801318,(%esp)
  800080:	e8 ff 00 00 00       	call   800184 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800085:	83 c0 01             	add    $0x1,%eax
  800088:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008d:	75 c5                	jne    800054 <umain+0x20>
  80008f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800094:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80009b:	83 c0 01             	add    $0x1,%eax
  80009e:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000a3:	75 ef                	jne    800094 <umain+0x60>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a5:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  8000ac:	75 10                	jne    8000be <umain+0x8a>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000ae:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != i)
  8000b3:	3b 04 85 20 20 80 00 	cmp    0x802020(,%eax,4),%eax
  8000ba:	74 27                	je     8000e3 <umain+0xaf>
  8000bc:	eb 05                	jmp    8000c3 <umain+0x8f>
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c7:	c7 44 24 08 a0 12 80 	movl   $0x8012a0,0x8(%esp)
  8000ce:	00 
  8000cf:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000d6:	00 
  8000d7:	c7 04 24 18 13 80 00 	movl   $0x801318,(%esp)
  8000de:	e8 a1 00 00 00       	call   800184 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000e3:	83 c0 01             	add    $0x1,%eax
  8000e6:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000eb:	75 c6                	jne    8000b3 <umain+0x7f>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000ed:	c7 04 24 c8 12 80 00 	movl   $0x8012c8,(%esp)
  8000f4:	e8 86 01 00 00       	call   80027f <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f9:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  800100:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800103:	c7 44 24 08 27 13 80 	movl   $0x801327,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 18 13 80 00 	movl   $0x801318,(%esp)
  80011a:	e8 65 00 00 00       	call   800184 <_panic>
	...

00800120 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 18             	sub    $0x18,%esp
  800126:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800129:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80012c:	8b 75 08             	mov    0x8(%ebp),%esi
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800132:	e8 11 0c 00 00       	call   800d48 <sys_getenvid>
  800137:	25 ff 03 00 00       	and    $0x3ff,%eax
  80013c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80013f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800144:	a3 20 20 c0 00       	mov    %eax,0xc02020
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800149:	85 f6                	test   %esi,%esi
  80014b:	7e 07                	jle    800154 <libmain+0x34>
		binaryname = argv[0];
  80014d:	8b 03                	mov    (%ebx),%eax
  80014f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800154:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800158:	89 34 24             	mov    %esi,(%esp)
  80015b:	e8 d4 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800160:	e8 0b 00 00 00       	call   800170 <exit>
}
  800165:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800168:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80016b:	89 ec                	mov    %ebp,%esp
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    
	...

00800170 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800176:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017d:	e8 69 0b 00 00       	call   800ceb <sys_env_destroy>
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80018c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800195:	e8 ae 0b 00 00       	call   800d48 <sys_getenvid>
  80019a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b0:	c7 04 24 48 13 80 00 	movl   $0x801348,(%esp)
  8001b7:	e8 c3 00 00 00       	call   80027f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c3:	89 04 24             	mov    %eax,(%esp)
  8001c6:	e8 53 00 00 00       	call   80021e <vcprintf>
	cprintf("\n");
  8001cb:	c7 04 24 16 13 80 00 	movl   $0x801316,(%esp)
  8001d2:	e8 a8 00 00 00       	call   80027f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x53>
	...

008001dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 14             	sub    $0x14,%esp
  8001e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e6:	8b 03                	mov    (%ebx),%eax
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ef:	83 c0 01             	add    $0x1,%eax
  8001f2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f9:	75 19                	jne    800214 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001fb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800202:	00 
  800203:	8d 43 08             	lea    0x8(%ebx),%eax
  800206:	89 04 24             	mov    %eax,(%esp)
  800209:	e8 76 0a 00 00       	call   800c84 <sys_cputs>
		b->idx = 0;
  80020e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800214:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800218:	83 c4 14             	add    $0x14,%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    

0080021e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800227:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022e:	00 00 00 
	b.cnt = 0;
  800231:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800238:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80023b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800242:	8b 45 08             	mov    0x8(%ebp),%eax
  800245:	89 44 24 08          	mov    %eax,0x8(%esp)
  800249:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800253:	c7 04 24 dc 01 80 00 	movl   $0x8001dc,(%esp)
  80025a:	e8 e2 01 00 00       	call   800441 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800265:	89 44 24 04          	mov    %eax,0x4(%esp)
  800269:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	e8 0d 0a 00 00       	call   800c84 <sys_cputs>

	return b.cnt;
}
  800277:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027d:	c9                   	leave  
  80027e:	c3                   	ret    

0080027f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800285:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	8b 45 08             	mov    0x8(%ebp),%eax
  80028f:	89 04 24             	mov    %eax,(%esp)
  800292:	e8 87 ff ff ff       	call   80021e <vcprintf>
	va_end(ap);

	return cnt;
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    
  800299:	00 00                	add    %al,(%eax)
  80029b:	00 00                	add    %al,(%eax)
  80029d:	00 00                	add    %al,(%eax)
	...

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 4c             	sub    $0x4c,%esp
  8002a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ac:	89 d6                	mov    %edx,%esi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002bd:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c5:	39 d0                	cmp    %edx,%eax
  8002c7:	72 11                	jb     8002da <printnum+0x3a>
  8002c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002cc:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8002cf:	76 09                	jbe    8002da <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d1:	83 eb 01             	sub    $0x1,%ebx
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7f 5d                	jg     800335 <printnum+0x95>
  8002d8:	eb 6c                	jmp    800346 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002da:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002de:	83 eb 01             	sub    $0x1,%ebx
  8002e1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ec:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002f0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002f7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8002fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800301:	00 
  800302:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800305:	89 14 24             	mov    %edx,(%esp)
  800308:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80030b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80030f:	e8 0c 0d 00 00       	call   801020 <__udivdi3>
  800314:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800317:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80031a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80031e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	89 54 24 04          	mov    %edx,0x4(%esp)
  800329:	89 f2                	mov    %esi,%edx
  80032b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80032e:	e8 6d ff ff ff       	call   8002a0 <printnum>
  800333:	eb 11                	jmp    800346 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800335:	89 74 24 04          	mov    %esi,0x4(%esp)
  800339:	89 3c 24             	mov    %edi,(%esp)
  80033c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033f:	83 eb 01             	sub    $0x1,%ebx
  800342:	85 db                	test   %ebx,%ebx
  800344:	7f ef                	jg     800335 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800346:	89 74 24 04          	mov    %esi,0x4(%esp)
  80034a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80034e:	8b 45 10             	mov    0x10(%ebp),%eax
  800351:	89 44 24 08          	mov    %eax,0x8(%esp)
  800355:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035c:	00 
  80035d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800360:	89 14 24             	mov    %edx,(%esp)
  800363:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800366:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80036a:	e8 c1 0d 00 00       	call   801130 <__umoddi3>
  80036f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800373:	0f be 80 6c 13 80 00 	movsbl 0x80136c(%eax),%eax
  80037a:	89 04 24             	mov    %eax,(%esp)
  80037d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800380:	83 c4 4c             	add    $0x4c,%esp
  800383:	5b                   	pop    %ebx
  800384:	5e                   	pop    %esi
  800385:	5f                   	pop    %edi
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038b:	83 fa 01             	cmp    $0x1,%edx
  80038e:	7e 0e                	jle    80039e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800390:	8b 10                	mov    (%eax),%edx
  800392:	8d 4a 08             	lea    0x8(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 02                	mov    (%edx),%eax
  800399:	8b 52 04             	mov    0x4(%edx),%edx
  80039c:	eb 22                	jmp    8003c0 <getuint+0x38>
	else if (lflag)
  80039e:	85 d2                	test   %edx,%edx
  8003a0:	74 10                	je     8003b2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a2:	8b 10                	mov    (%eax),%edx
  8003a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a7:	89 08                	mov    %ecx,(%eax)
  8003a9:	8b 02                	mov    (%edx),%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	eb 0e                	jmp    8003c0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b2:	8b 10                	mov    (%eax),%edx
  8003b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b7:	89 08                	mov    %ecx,(%eax)
  8003b9:	8b 02                	mov    (%edx),%eax
  8003bb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c0:	5d                   	pop    %ebp
  8003c1:	c3                   	ret    

008003c2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c5:	83 fa 01             	cmp    $0x1,%edx
  8003c8:	7e 0e                	jle    8003d8 <getint+0x16>
		return va_arg(*ap, long long);
  8003ca:	8b 10                	mov    (%eax),%edx
  8003cc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003cf:	89 08                	mov    %ecx,(%eax)
  8003d1:	8b 02                	mov    (%edx),%eax
  8003d3:	8b 52 04             	mov    0x4(%edx),%edx
  8003d6:	eb 22                	jmp    8003fa <getint+0x38>
	else if (lflag)
  8003d8:	85 d2                	test   %edx,%edx
  8003da:	74 10                	je     8003ec <getint+0x2a>
		return va_arg(*ap, long);
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e1:	89 08                	mov    %ecx,(%eax)
  8003e3:	8b 02                	mov    (%edx),%eax
  8003e5:	89 c2                	mov    %eax,%edx
  8003e7:	c1 fa 1f             	sar    $0x1f,%edx
  8003ea:	eb 0e                	jmp    8003fa <getint+0x38>
	else
		return va_arg(*ap, int);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800402:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800406:	8b 10                	mov    (%eax),%edx
  800408:	3b 50 04             	cmp    0x4(%eax),%edx
  80040b:	73 0a                	jae    800417 <sprintputch+0x1b>
		*b->buf++ = ch;
  80040d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800410:	88 0a                	mov    %cl,(%edx)
  800412:	83 c2 01             	add    $0x1,%edx
  800415:	89 10                	mov    %edx,(%eax)
}
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    

00800419 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80041f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800422:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800426:	8b 45 10             	mov    0x10(%ebp),%eax
  800429:	89 44 24 08          	mov    %eax,0x8(%esp)
  80042d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800430:	89 44 24 04          	mov    %eax,0x4(%esp)
  800434:	8b 45 08             	mov    0x8(%ebp),%eax
  800437:	89 04 24             	mov    %eax,(%esp)
  80043a:	e8 02 00 00 00       	call   800441 <vprintfmt>
	va_end(ap);
}
  80043f:	c9                   	leave  
  800440:	c3                   	ret    

00800441 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
  800444:	57                   	push   %edi
  800445:	56                   	push   %esi
  800446:	53                   	push   %ebx
  800447:	83 ec 4c             	sub    $0x4c,%esp
  80044a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80044d:	eb 23                	jmp    800472 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80044f:	85 c0                	test   %eax,%eax
  800451:	75 12                	jne    800465 <vprintfmt+0x24>
				csa = 0x0700;
  800453:	c7 05 24 20 c0 00 00 	movl   $0x700,0xc02024
  80045a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80045d:	83 c4 4c             	add    $0x4c,%esp
  800460:	5b                   	pop    %ebx
  800461:	5e                   	pop    %esi
  800462:	5f                   	pop    %edi
  800463:	5d                   	pop    %ebp
  800464:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800465:	8b 55 0c             	mov    0xc(%ebp),%edx
  800468:	89 54 24 04          	mov    %edx,0x4(%esp)
  80046c:	89 04 24             	mov    %eax,(%esp)
  80046f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800472:	0f b6 07             	movzbl (%edi),%eax
  800475:	83 c7 01             	add    $0x1,%edi
  800478:	83 f8 25             	cmp    $0x25,%eax
  80047b:	75 d2                	jne    80044f <vprintfmt+0xe>
  80047d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800481:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800488:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80048d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800494:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800499:	be 00 00 00 00       	mov    $0x0,%esi
  80049e:	eb 14                	jmp    8004b4 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8004a4:	eb 0e                	jmp    8004b4 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a6:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8004aa:	eb 08                	jmp    8004b4 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004ac:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004af:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	0f b6 07             	movzbl (%edi),%eax
  8004b7:	0f b6 c8             	movzbl %al,%ecx
  8004ba:	83 c7 01             	add    $0x1,%edi
  8004bd:	83 e8 23             	sub    $0x23,%eax
  8004c0:	3c 55                	cmp    $0x55,%al
  8004c2:	0f 87 ed 02 00 00    	ja     8007b5 <vprintfmt+0x374>
  8004c8:	0f b6 c0             	movzbl %al,%eax
  8004cb:	ff 24 85 40 14 80 00 	jmp    *0x801440(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  8004d5:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004d8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004db:	83 f9 09             	cmp    $0x9,%ecx
  8004de:	77 3c                	ja     80051c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004e3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8004e6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8004ea:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004ed:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004f0:	83 f9 09             	cmp    $0x9,%ecx
  8004f3:	76 eb                	jbe    8004e0 <vprintfmt+0x9f>
  8004f5:	eb 25                	jmp    80051c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 48 04             	lea    0x4(%eax),%ecx
  8004fd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800500:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  800502:	eb 18                	jmp    80051c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  800504:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800508:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050b:	0f 48 c6             	cmovs  %esi,%eax
  80050e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800511:	eb a1                	jmp    8004b4 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  800513:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80051a:	eb 98                	jmp    8004b4 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  80051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800520:	79 92                	jns    8004b4 <vprintfmt+0x73>
  800522:	eb 88                	jmp    8004ac <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800524:	83 c2 01             	add    $0x1,%edx
  800527:	eb 8b                	jmp    8004b4 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8d 50 04             	lea    0x4(%eax),%edx
  80052f:	89 55 14             	mov    %edx,0x14(%ebp)
  800532:	8b 55 0c             	mov    0xc(%ebp),%edx
  800535:	89 54 24 04          	mov    %edx,0x4(%esp)
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	89 04 24             	mov    %eax,(%esp)
  80053e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800541:	e9 2c ff ff ff       	jmp    800472 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8d 50 04             	lea    0x4(%eax),%edx
  80054c:	89 55 14             	mov    %edx,0x14(%ebp)
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 c2                	mov    %eax,%edx
  800553:	c1 fa 1f             	sar    $0x1f,%edx
  800556:	31 d0                	xor    %edx,%eax
  800558:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055a:	83 f8 08             	cmp    $0x8,%eax
  80055d:	7f 0b                	jg     80056a <vprintfmt+0x129>
  80055f:	8b 14 85 a0 15 80 00 	mov    0x8015a0(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 23                	jne    80058d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80056a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056e:	c7 44 24 08 84 13 80 	movl   $0x801384,0x8(%esp)
  800575:	00 
  800576:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800579:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057d:	8b 45 08             	mov    0x8(%ebp),%eax
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	e8 91 fe ff ff       	call   800419 <printfmt>
  800588:	e9 e5 fe ff ff       	jmp    800472 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80058d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800591:	c7 44 24 08 8d 13 80 	movl   $0x80138d,0x8(%esp)
  800598:	00 
  800599:	8b 55 0c             	mov    0xc(%ebp),%edx
  80059c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005a3:	89 1c 24             	mov    %ebx,(%esp)
  8005a6:	e8 6e fe ff ff       	call   800419 <printfmt>
  8005ab:	e9 c2 fe ff ff       	jmp    800472 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 50 04             	lea    0x4(%eax),%edx
  8005bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c2:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005c4:	85 f6                	test   %esi,%esi
  8005c6:	ba 7d 13 80 00       	mov    $0x80137d,%edx
  8005cb:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005d2:	7e 06                	jle    8005da <vprintfmt+0x199>
  8005d4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005d8:	75 13                	jne    8005ed <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005da:	0f be 06             	movsbl (%esi),%eax
  8005dd:	83 c6 01             	add    $0x1,%esi
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	0f 85 a2 00 00 00    	jne    80068a <vprintfmt+0x249>
  8005e8:	e9 92 00 00 00       	jmp    80067f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f1:	89 34 24             	mov    %esi,(%esp)
  8005f4:	e8 82 02 00 00       	call   80087b <strnlen>
  8005f9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fc:	29 c2                	sub    %eax,%edx
  8005fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800601:	85 d2                	test   %edx,%edx
  800603:	7e d5                	jle    8005da <vprintfmt+0x199>
					putch(padc, putdat);
  800605:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800609:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80060c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80060f:	89 d3                	mov    %edx,%ebx
  800611:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800614:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800617:	89 c6                	mov    %eax,%esi
  800619:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061d:	89 34 24             	mov    %esi,(%esp)
  800620:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800623:	83 eb 01             	sub    $0x1,%ebx
  800626:	85 db                	test   %ebx,%ebx
  800628:	7f ef                	jg     800619 <vprintfmt+0x1d8>
  80062a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80062d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800630:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800633:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80063a:	eb 9e                	jmp    8005da <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800640:	74 1b                	je     80065d <vprintfmt+0x21c>
  800642:	8d 50 e0             	lea    -0x20(%eax),%edx
  800645:	83 fa 5e             	cmp    $0x5e,%edx
  800648:	76 13                	jbe    80065d <vprintfmt+0x21c>
					putch('?', putdat);
  80064a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80064d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800651:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800658:	ff 55 08             	call   *0x8(%ebp)
  80065b:	eb 0d                	jmp    80066a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80065d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800660:	89 54 24 04          	mov    %edx,0x4(%esp)
  800664:	89 04 24             	mov    %eax,(%esp)
  800667:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066a:	83 ef 01             	sub    $0x1,%edi
  80066d:	0f be 06             	movsbl (%esi),%eax
  800670:	85 c0                	test   %eax,%eax
  800672:	74 05                	je     800679 <vprintfmt+0x238>
  800674:	83 c6 01             	add    $0x1,%esi
  800677:	eb 17                	jmp    800690 <vprintfmt+0x24f>
  800679:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80067c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800683:	7f 1c                	jg     8006a1 <vprintfmt+0x260>
  800685:	e9 e8 fd ff ff       	jmp    800472 <vprintfmt+0x31>
  80068a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80068d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800690:	85 db                	test   %ebx,%ebx
  800692:	78 a8                	js     80063c <vprintfmt+0x1fb>
  800694:	83 eb 01             	sub    $0x1,%ebx
  800697:	79 a3                	jns    80063c <vprintfmt+0x1fb>
  800699:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80069c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80069f:	eb de                	jmp    80067f <vprintfmt+0x23e>
  8006a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a7:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006b5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b7:	83 eb 01             	sub    $0x1,%ebx
  8006ba:	85 db                	test   %ebx,%ebx
  8006bc:	7f ec                	jg     8006aa <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006c1:	e9 ac fd ff ff       	jmp    800472 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c9:	e8 f4 fc ff ff       	call   8003c2 <getint>
  8006ce:	89 c3                	mov    %eax,%ebx
  8006d0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8006d2:	85 d2                	test   %edx,%edx
  8006d4:	78 0a                	js     8006e0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006db:	e9 87 00 00 00       	jmp    800767 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ee:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f1:	89 d8                	mov    %ebx,%eax
  8006f3:	89 f2                	mov    %esi,%edx
  8006f5:	f7 d8                	neg    %eax
  8006f7:	83 d2 00             	adc    $0x0,%edx
  8006fa:	f7 da                	neg    %edx
			}
			base = 10;
  8006fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800701:	eb 64                	jmp    800767 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 7d fc ff ff       	call   800388 <getuint>
			base = 10;
  80070b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800710:	eb 55                	jmp    800767 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800712:	8d 45 14             	lea    0x14(%ebp),%eax
  800715:	e8 6e fc ff ff       	call   800388 <getuint>
      base = 8;
  80071a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80071f:	eb 46                	jmp    800767 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800721:	8b 55 0c             	mov    0xc(%ebp),%edx
  800724:	89 54 24 04          	mov    %edx,0x4(%esp)
  800728:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800732:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800735:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800739:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800740:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8d 50 04             	lea    0x4(%eax),%edx
  800749:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80074c:	8b 00                	mov    (%eax),%eax
  80074e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800753:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800758:	eb 0d                	jmp    800767 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
  80075d:	e8 26 fc ff ff       	call   800388 <getuint>
			base = 16;
  800762:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800767:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80076b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80076f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800772:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800776:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80077a:	89 04 24             	mov    %eax,(%esp)
  80077d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800781:	8b 55 0c             	mov    0xc(%ebp),%edx
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	e8 14 fb ff ff       	call   8002a0 <printnum>
			break;
  80078c:	e9 e1 fc ff ff       	jmp    800472 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800791:	8b 45 0c             	mov    0xc(%ebp),%eax
  800794:	89 44 24 04          	mov    %eax,0x4(%esp)
  800798:	89 0c 24             	mov    %ecx,(%esp)
  80079b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80079e:	e9 cf fc ff ff       	jmp    800472 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a6:	e8 17 fc ff ff       	call   8003c2 <getint>
			csa = num;
  8007ab:	a3 24 20 c0 00       	mov    %eax,0xc02024
			break;
  8007b0:	e9 bd fc ff ff       	jmp    800472 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007bc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c6:	83 ef 01             	sub    $0x1,%edi
  8007c9:	eb 02                	jmp    8007cd <vprintfmt+0x38c>
  8007cb:	89 c7                	mov    %eax,%edi
  8007cd:	8d 47 ff             	lea    -0x1(%edi),%eax
  8007d0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007d4:	75 f5                	jne    8007cb <vprintfmt+0x38a>
  8007d6:	e9 97 fc ff ff       	jmp    800472 <vprintfmt+0x31>

008007db <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	83 ec 28             	sub    $0x28,%esp
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ea:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ee:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f8:	85 c0                	test   %eax,%eax
  8007fa:	74 30                	je     80082c <vsnprintf+0x51>
  8007fc:	85 d2                	test   %edx,%edx
  8007fe:	7e 2c                	jle    80082c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800807:	8b 45 10             	mov    0x10(%ebp),%eax
  80080a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800811:	89 44 24 04          	mov    %eax,0x4(%esp)
  800815:	c7 04 24 fc 03 80 00 	movl   $0x8003fc,(%esp)
  80081c:	e8 20 fc ff ff       	call   800441 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800821:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800824:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800827:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082a:	eb 05                	jmp    800831 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80082c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800839:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800840:	8b 45 10             	mov    0x10(%ebp),%eax
  800843:	89 44 24 08          	mov    %eax,0x8(%esp)
  800847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	89 04 24             	mov    %eax,(%esp)
  800854:	e8 82 ff ff ff       	call   8007db <vsnprintf>
	va_end(ap);

	return rc;
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    
  80085b:	00 00                	add    %al,(%eax)
  80085d:	00 00                	add    %al,(%eax)
	...

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	80 3a 00             	cmpb   $0x0,(%edx)
  80086e:	74 09                	je     800879 <strlen+0x19>
		n++;
  800870:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800873:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800877:	75 f7                	jne    800870 <strlen+0x10>
		n++;
	return n;
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
  800889:	85 d2                	test   %edx,%edx
  80088b:	74 12                	je     80089f <strnlen+0x24>
  80088d:	80 39 00             	cmpb   $0x0,(%ecx)
  800890:	74 0d                	je     80089f <strnlen+0x24>
		n++;
  800892:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800895:	39 d0                	cmp    %edx,%eax
  800897:	74 06                	je     80089f <strnlen+0x24>
  800899:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80089d:	75 f3                	jne    800892 <strnlen+0x17>
		n++;
	return n;
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	53                   	push   %ebx
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008b4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008b7:	83 c2 01             	add    $0x1,%edx
  8008ba:	84 c9                	test   %cl,%cl
  8008bc:	75 f2                	jne    8008b0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	53                   	push   %ebx
  8008c5:	83 ec 08             	sub    $0x8,%esp
  8008c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008cb:	89 1c 24             	mov    %ebx,(%esp)
  8008ce:	e8 8d ff ff ff       	call   800860 <strlen>
	strcpy(dst + len, src);
  8008d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008da:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008dd:	89 04 24             	mov    %eax,(%esp)
  8008e0:	e8 bc ff ff ff       	call   8008a1 <strcpy>
	return dst;
}
  8008e5:	89 d8                	mov    %ebx,%eax
  8008e7:	83 c4 08             	add    $0x8,%esp
  8008ea:	5b                   	pop    %ebx
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	56                   	push   %esi
  8008f1:	53                   	push   %ebx
  8008f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fb:	85 f6                	test   %esi,%esi
  8008fd:	74 18                	je     800917 <strncpy+0x2a>
  8008ff:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800904:	0f b6 1a             	movzbl (%edx),%ebx
  800907:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090a:	80 3a 01             	cmpb   $0x1,(%edx)
  80090d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800910:	83 c1 01             	add    $0x1,%ecx
  800913:	39 ce                	cmp    %ecx,%esi
  800915:	77 ed                	ja     800904 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 75 08             	mov    0x8(%ebp),%esi
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
  800926:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800929:	89 f0                	mov    %esi,%eax
  80092b:	85 c9                	test   %ecx,%ecx
  80092d:	74 23                	je     800952 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  80092f:	83 e9 01             	sub    $0x1,%ecx
  800932:	74 1b                	je     80094f <strlcpy+0x34>
  800934:	0f b6 1a             	movzbl (%edx),%ebx
  800937:	84 db                	test   %bl,%bl
  800939:	74 14                	je     80094f <strlcpy+0x34>
			*dst++ = *src++;
  80093b:	88 18                	mov    %bl,(%eax)
  80093d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800940:	83 e9 01             	sub    $0x1,%ecx
  800943:	74 0a                	je     80094f <strlcpy+0x34>
			*dst++ = *src++;
  800945:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800948:	0f b6 1a             	movzbl (%edx),%ebx
  80094b:	84 db                	test   %bl,%bl
  80094d:	75 ec                	jne    80093b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80094f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800952:	29 f0                	sub    %esi,%eax
}
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800961:	0f b6 01             	movzbl (%ecx),%eax
  800964:	84 c0                	test   %al,%al
  800966:	74 15                	je     80097d <strcmp+0x25>
  800968:	3a 02                	cmp    (%edx),%al
  80096a:	75 11                	jne    80097d <strcmp+0x25>
		p++, q++;
  80096c:	83 c1 01             	add    $0x1,%ecx
  80096f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800972:	0f b6 01             	movzbl (%ecx),%eax
  800975:	84 c0                	test   %al,%al
  800977:	74 04                	je     80097d <strcmp+0x25>
  800979:	3a 02                	cmp    (%edx),%al
  80097b:	74 ef                	je     80096c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097d:	0f b6 c0             	movzbl %al,%eax
  800980:	0f b6 12             	movzbl (%edx),%edx
  800983:	29 d0                	sub    %edx,%eax
}
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800991:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800999:	85 d2                	test   %edx,%edx
  80099b:	74 28                	je     8009c5 <strncmp+0x3e>
  80099d:	0f b6 01             	movzbl (%ecx),%eax
  8009a0:	84 c0                	test   %al,%al
  8009a2:	74 24                	je     8009c8 <strncmp+0x41>
  8009a4:	3a 03                	cmp    (%ebx),%al
  8009a6:	75 20                	jne    8009c8 <strncmp+0x41>
  8009a8:	83 ea 01             	sub    $0x1,%edx
  8009ab:	74 13                	je     8009c0 <strncmp+0x39>
		n--, p++, q++;
  8009ad:	83 c1 01             	add    $0x1,%ecx
  8009b0:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009b3:	0f b6 01             	movzbl (%ecx),%eax
  8009b6:	84 c0                	test   %al,%al
  8009b8:	74 0e                	je     8009c8 <strncmp+0x41>
  8009ba:	3a 03                	cmp    (%ebx),%al
  8009bc:	74 ea                	je     8009a8 <strncmp+0x21>
  8009be:	eb 08                	jmp    8009c8 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c8:	0f b6 01             	movzbl (%ecx),%eax
  8009cb:	0f b6 13             	movzbl (%ebx),%edx
  8009ce:	29 d0                	sub    %edx,%eax
  8009d0:	eb f3                	jmp    8009c5 <strncmp+0x3e>

008009d2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009dc:	0f b6 10             	movzbl (%eax),%edx
  8009df:	84 d2                	test   %dl,%dl
  8009e1:	74 20                	je     800a03 <strchr+0x31>
		if (*s == c)
  8009e3:	38 ca                	cmp    %cl,%dl
  8009e5:	75 0b                	jne    8009f2 <strchr+0x20>
  8009e7:	eb 1f                	jmp    800a08 <strchr+0x36>
  8009e9:	38 ca                	cmp    %cl,%dl
  8009eb:	90                   	nop
  8009ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009f0:	74 16                	je     800a08 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f2:	83 c0 01             	add    $0x1,%eax
  8009f5:	0f b6 10             	movzbl (%eax),%edx
  8009f8:	84 d2                	test   %dl,%dl
  8009fa:	75 ed                	jne    8009e9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800a01:	eb 05                	jmp    800a08 <strchr+0x36>
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a14:	0f b6 10             	movzbl (%eax),%edx
  800a17:	84 d2                	test   %dl,%dl
  800a19:	74 14                	je     800a2f <strfind+0x25>
		if (*s == c)
  800a1b:	38 ca                	cmp    %cl,%dl
  800a1d:	75 06                	jne    800a25 <strfind+0x1b>
  800a1f:	eb 0e                	jmp    800a2f <strfind+0x25>
  800a21:	38 ca                	cmp    %cl,%dl
  800a23:	74 0a                	je     800a2f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	0f b6 10             	movzbl (%eax),%edx
  800a2b:	84 d2                	test   %dl,%dl
  800a2d:	75 f2                	jne    800a21 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	83 ec 0c             	sub    $0xc,%esp
  800a37:	89 1c 24             	mov    %ebx,(%esp)
  800a3a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a42:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a48:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a4b:	85 c9                	test   %ecx,%ecx
  800a4d:	74 30                	je     800a7f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a55:	75 25                	jne    800a7c <memset+0x4b>
  800a57:	f6 c1 03             	test   $0x3,%cl
  800a5a:	75 20                	jne    800a7c <memset+0x4b>
		c &= 0xFF;
  800a5c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5f:	89 d3                	mov    %edx,%ebx
  800a61:	c1 e3 08             	shl    $0x8,%ebx
  800a64:	89 d6                	mov    %edx,%esi
  800a66:	c1 e6 18             	shl    $0x18,%esi
  800a69:	89 d0                	mov    %edx,%eax
  800a6b:	c1 e0 10             	shl    $0x10,%eax
  800a6e:	09 f0                	or     %esi,%eax
  800a70:	09 d0                	or     %edx,%eax
  800a72:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a74:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a77:	fc                   	cld    
  800a78:	f3 ab                	rep stos %eax,%es:(%edi)
  800a7a:	eb 03                	jmp    800a7f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7c:	fc                   	cld    
  800a7d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a7f:	89 f8                	mov    %edi,%eax
  800a81:	8b 1c 24             	mov    (%esp),%ebx
  800a84:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a88:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a8c:	89 ec                	mov    %ebp,%esp
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	83 ec 08             	sub    $0x8,%esp
  800a96:	89 34 24             	mov    %esi,(%esp)
  800a99:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa6:	39 c6                	cmp    %eax,%esi
  800aa8:	73 36                	jae    800ae0 <memmove+0x50>
  800aaa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aad:	39 d0                	cmp    %edx,%eax
  800aaf:	73 2f                	jae    800ae0 <memmove+0x50>
		s += n;
		d += n;
  800ab1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab4:	f6 c2 03             	test   $0x3,%dl
  800ab7:	75 1b                	jne    800ad4 <memmove+0x44>
  800ab9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800abf:	75 13                	jne    800ad4 <memmove+0x44>
  800ac1:	f6 c1 03             	test   $0x3,%cl
  800ac4:	75 0e                	jne    800ad4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac6:	83 ef 04             	sub    $0x4,%edi
  800ac9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800acc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800acf:	fd                   	std    
  800ad0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad2:	eb 09                	jmp    800add <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ad4:	83 ef 01             	sub    $0x1,%edi
  800ad7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ada:	fd                   	std    
  800adb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800add:	fc                   	cld    
  800ade:	eb 20                	jmp    800b00 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae6:	75 13                	jne    800afb <memmove+0x6b>
  800ae8:	a8 03                	test   $0x3,%al
  800aea:	75 0f                	jne    800afb <memmove+0x6b>
  800aec:	f6 c1 03             	test   $0x3,%cl
  800aef:	75 0a                	jne    800afb <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800af1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800af4:	89 c7                	mov    %eax,%edi
  800af6:	fc                   	cld    
  800af7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af9:	eb 05                	jmp    800b00 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800afb:	89 c7                	mov    %eax,%edi
  800afd:	fc                   	cld    
  800afe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b00:	8b 34 24             	mov    (%esp),%esi
  800b03:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b07:	89 ec                	mov    %ebp,%esp
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b11:	8b 45 10             	mov    0x10(%ebp),%eax
  800b14:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	89 04 24             	mov    %eax,(%esp)
  800b25:	e8 66 ff ff ff       	call   800a90 <memmove>
}
  800b2a:	c9                   	leave  
  800b2b:	c3                   	ret    

00800b2c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b38:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b40:	85 ff                	test   %edi,%edi
  800b42:	74 38                	je     800b7c <memcmp+0x50>
		if (*s1 != *s2)
  800b44:	0f b6 03             	movzbl (%ebx),%eax
  800b47:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4a:	83 ef 01             	sub    $0x1,%edi
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b52:	38 c8                	cmp    %cl,%al
  800b54:	74 1d                	je     800b73 <memcmp+0x47>
  800b56:	eb 11                	jmp    800b69 <memcmp+0x3d>
  800b58:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b5d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800b62:	83 c2 01             	add    $0x1,%edx
  800b65:	38 c8                	cmp    %cl,%al
  800b67:	74 0a                	je     800b73 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800b69:	0f b6 c0             	movzbl %al,%eax
  800b6c:	0f b6 c9             	movzbl %cl,%ecx
  800b6f:	29 c8                	sub    %ecx,%eax
  800b71:	eb 09                	jmp    800b7c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b73:	39 fa                	cmp    %edi,%edx
  800b75:	75 e1                	jne    800b58 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b87:	89 c2                	mov    %eax,%edx
  800b89:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b8c:	39 d0                	cmp    %edx,%eax
  800b8e:	73 15                	jae    800ba5 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b94:	38 08                	cmp    %cl,(%eax)
  800b96:	75 06                	jne    800b9e <memfind+0x1d>
  800b98:	eb 0b                	jmp    800ba5 <memfind+0x24>
  800b9a:	38 08                	cmp    %cl,(%eax)
  800b9c:	74 07                	je     800ba5 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9e:	83 c0 01             	add    $0x1,%eax
  800ba1:	39 c2                	cmp    %eax,%edx
  800ba3:	77 f5                	ja     800b9a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb3:	0f b6 02             	movzbl (%edx),%eax
  800bb6:	3c 20                	cmp    $0x20,%al
  800bb8:	74 04                	je     800bbe <strtol+0x17>
  800bba:	3c 09                	cmp    $0x9,%al
  800bbc:	75 0e                	jne    800bcc <strtol+0x25>
		s++;
  800bbe:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc1:	0f b6 02             	movzbl (%edx),%eax
  800bc4:	3c 20                	cmp    $0x20,%al
  800bc6:	74 f6                	je     800bbe <strtol+0x17>
  800bc8:	3c 09                	cmp    $0x9,%al
  800bca:	74 f2                	je     800bbe <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bcc:	3c 2b                	cmp    $0x2b,%al
  800bce:	75 0a                	jne    800bda <strtol+0x33>
		s++;
  800bd0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bd3:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd8:	eb 10                	jmp    800bea <strtol+0x43>
  800bda:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bdf:	3c 2d                	cmp    $0x2d,%al
  800be1:	75 07                	jne    800bea <strtol+0x43>
		s++, neg = 1;
  800be3:	83 c2 01             	add    $0x1,%edx
  800be6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bea:	85 db                	test   %ebx,%ebx
  800bec:	0f 94 c0             	sete   %al
  800bef:	74 05                	je     800bf6 <strtol+0x4f>
  800bf1:	83 fb 10             	cmp    $0x10,%ebx
  800bf4:	75 15                	jne    800c0b <strtol+0x64>
  800bf6:	80 3a 30             	cmpb   $0x30,(%edx)
  800bf9:	75 10                	jne    800c0b <strtol+0x64>
  800bfb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bff:	75 0a                	jne    800c0b <strtol+0x64>
		s += 2, base = 16;
  800c01:	83 c2 02             	add    $0x2,%edx
  800c04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c09:	eb 13                	jmp    800c1e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c0b:	84 c0                	test   %al,%al
  800c0d:	74 0f                	je     800c1e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c0f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c14:	80 3a 30             	cmpb   $0x30,(%edx)
  800c17:	75 05                	jne    800c1e <strtol+0x77>
		s++, base = 8;
  800c19:	83 c2 01             	add    $0x1,%edx
  800c1c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c23:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c25:	0f b6 0a             	movzbl (%edx),%ecx
  800c28:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c2b:	80 fb 09             	cmp    $0x9,%bl
  800c2e:	77 08                	ja     800c38 <strtol+0x91>
			dig = *s - '0';
  800c30:	0f be c9             	movsbl %cl,%ecx
  800c33:	83 e9 30             	sub    $0x30,%ecx
  800c36:	eb 1e                	jmp    800c56 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c38:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c3b:	80 fb 19             	cmp    $0x19,%bl
  800c3e:	77 08                	ja     800c48 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c40:	0f be c9             	movsbl %cl,%ecx
  800c43:	83 e9 57             	sub    $0x57,%ecx
  800c46:	eb 0e                	jmp    800c56 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c48:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c4b:	80 fb 19             	cmp    $0x19,%bl
  800c4e:	77 15                	ja     800c65 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800c50:	0f be c9             	movsbl %cl,%ecx
  800c53:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c56:	39 f1                	cmp    %esi,%ecx
  800c58:	7d 0f                	jge    800c69 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800c5a:	83 c2 01             	add    $0x1,%edx
  800c5d:	0f af c6             	imul   %esi,%eax
  800c60:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c63:	eb c0                	jmp    800c25 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c65:	89 c1                	mov    %eax,%ecx
  800c67:	eb 02                	jmp    800c6b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c69:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6f:	74 05                	je     800c76 <strtol+0xcf>
		*endptr = (char *) s;
  800c71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c74:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c76:	89 ca                	mov    %ecx,%edx
  800c78:	f7 da                	neg    %edx
  800c7a:	85 ff                	test   %edi,%edi
  800c7c:	0f 45 c2             	cmovne %edx,%eax
}
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	89 1c 24             	mov    %ebx,(%esp)
  800c8d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c91:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c95:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	89 c3                	mov    %eax,%ebx
  800ca2:	89 c7                	mov    %eax,%edi
  800ca4:	89 c6                	mov    %eax,%esi
  800ca6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca8:	8b 1c 24             	mov    (%esp),%ebx
  800cab:	8b 74 24 04          	mov    0x4(%esp),%esi
  800caf:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cb3:	89 ec                	mov    %ebp,%esp
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	89 1c 24             	mov    %ebx,(%esp)
  800cc0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cc4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccd:	b8 01 00 00 00       	mov    $0x1,%eax
  800cd2:	89 d1                	mov    %edx,%ecx
  800cd4:	89 d3                	mov    %edx,%ebx
  800cd6:	89 d7                	mov    %edx,%edi
  800cd8:	89 d6                	mov    %edx,%esi
  800cda:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cdc:	8b 1c 24             	mov    (%esp),%ebx
  800cdf:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ce3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ce7:	89 ec                	mov    %ebp,%esp
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	83 ec 38             	sub    $0x38,%esp
  800cf1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cf7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cff:	b8 03 00 00 00       	mov    $0x3,%eax
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 cb                	mov    %ecx,%ebx
  800d09:	89 cf                	mov    %ecx,%edi
  800d0b:	89 ce                	mov    %ecx,%esi
  800d0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7e 28                	jle    800d3b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d17:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d1e:	00 
  800d1f:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800d26:	00 
  800d27:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2e:	00 
  800d2f:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800d36:	e8 49 f4 ff ff       	call   800184 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d3b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d3e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d41:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d44:	89 ec                	mov    %ebp,%esp
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	89 1c 24             	mov    %ebx,(%esp)
  800d51:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d55:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d59:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d63:	89 d1                	mov    %edx,%ecx
  800d65:	89 d3                	mov    %edx,%ebx
  800d67:	89 d7                	mov    %edx,%edi
  800d69:	89 d6                	mov    %edx,%esi
  800d6b:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800d6d:	8b 1c 24             	mov    (%esp),%ebx
  800d70:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d74:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d78:	89 ec                	mov    %ebp,%esp
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_yield>:

void
sys_yield(void)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	89 1c 24             	mov    %ebx,(%esp)
  800d85:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d89:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d97:	89 d1                	mov    %edx,%ecx
  800d99:	89 d3                	mov    %edx,%ebx
  800d9b:	89 d7                	mov    %edx,%edi
  800d9d:	89 d6                	mov    %edx,%esi
  800d9f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800da1:	8b 1c 24             	mov    (%esp),%ebx
  800da4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800da8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dac:	89 ec                	mov    %ebp,%esp
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	83 ec 38             	sub    $0x38,%esp
  800db6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dbc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	be 00 00 00 00       	mov    $0x0,%esi
  800dc4:	b8 04 00 00 00       	mov    $0x4,%eax
  800dc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd2:	89 f7                	mov    %esi,%edi
  800dd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7e 28                	jle    800e02 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dde:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800de5:	00 
  800de6:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800ded:	00 
  800dee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df5:	00 
  800df6:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800dfd:	e8 82 f3 ff ff       	call   800184 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e0b:	89 ec                	mov    %ebp,%esp
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	83 ec 38             	sub    $0x38,%esp
  800e15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1e:	b8 05 00 00 00       	mov    $0x5,%eax
  800e23:	8b 75 18             	mov    0x18(%ebp),%esi
  800e26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e34:	85 c0                	test   %eax,%eax
  800e36:	7e 28                	jle    800e60 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e38:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e43:	00 
  800e44:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800e4b:	00 
  800e4c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e53:	00 
  800e54:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800e5b:	e8 24 f3 ff ff       	call   800184 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e60:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e63:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e66:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e69:	89 ec                	mov    %ebp,%esp
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	83 ec 38             	sub    $0x38,%esp
  800e73:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e76:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e79:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e81:	b8 06 00 00 00       	mov    $0x6,%eax
  800e86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e89:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8c:	89 df                	mov    %ebx,%edi
  800e8e:	89 de                	mov    %ebx,%esi
  800e90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e92:	85 c0                	test   %eax,%eax
  800e94:	7e 28                	jle    800ebe <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ea1:	00 
  800ea2:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800ea9:	00 
  800eaa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb1:	00 
  800eb2:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800eb9:	e8 c6 f2 ff ff       	call   800184 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ebe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ec1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ec4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec7:	89 ec                	mov    %ebp,%esp
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 38             	sub    $0x38,%esp
  800ed1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ed4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edf:	b8 08 00 00 00       	mov    $0x8,%eax
  800ee4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eea:	89 df                	mov    %ebx,%edi
  800eec:	89 de                	mov    %ebx,%esi
  800eee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	7e 28                	jle    800f1c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef8:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800eff:	00 
  800f00:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800f07:	00 
  800f08:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0f:	00 
  800f10:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800f17:	e8 68 f2 ff ff       	call   800184 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f1c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f1f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f22:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f25:	89 ec                	mov    %ebp,%esp
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	83 ec 38             	sub    $0x38,%esp
  800f2f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f32:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f35:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3d:	b8 09 00 00 00       	mov    $0x9,%eax
  800f42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f45:	8b 55 08             	mov    0x8(%ebp),%edx
  800f48:	89 df                	mov    %ebx,%edi
  800f4a:	89 de                	mov    %ebx,%esi
  800f4c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	7e 28                	jle    800f7a <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f52:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f56:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f5d:	00 
  800f5e:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800f65:	00 
  800f66:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f6d:	00 
  800f6e:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  800f75:	e8 0a f2 ff ff       	call   800184 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f7a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f7d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f80:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f83:	89 ec                	mov    %ebp,%esp
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	89 1c 24             	mov    %ebx,(%esp)
  800f90:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f94:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f98:	be 00 00 00 00       	mov    $0x0,%esi
  800f9d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fa2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fab:	8b 55 08             	mov    0x8(%ebp),%edx
  800fae:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fb0:	8b 1c 24             	mov    (%esp),%ebx
  800fb3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fb7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fbb:	89 ec                	mov    %ebp,%esp
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    

00800fbf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	83 ec 38             	sub    $0x38,%esp
  800fc5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fc8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fcb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdb:	89 cb                	mov    %ecx,%ebx
  800fdd:	89 cf                	mov    %ecx,%edi
  800fdf:	89 ce                	mov    %ecx,%esi
  800fe1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	7e 28                	jle    80100f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800feb:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ff2:	00 
  800ff3:	c7 44 24 08 c4 15 80 	movl   $0x8015c4,0x8(%esp)
  800ffa:	00 
  800ffb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801002:	00 
  801003:	c7 04 24 e1 15 80 00 	movl   $0x8015e1,(%esp)
  80100a:	e8 75 f1 ff ff       	call   800184 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80100f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801012:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801015:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801018:	89 ec                	mov    %ebp,%esp
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    
  80101c:	00 00                	add    %al,(%eax)
	...

00801020 <__udivdi3>:
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	57                   	push   %edi
  801024:	56                   	push   %esi
  801025:	83 ec 10             	sub    $0x10,%esp
  801028:	8b 75 14             	mov    0x14(%ebp),%esi
  80102b:	8b 45 08             	mov    0x8(%ebp),%eax
  80102e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801031:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801034:	85 f6                	test   %esi,%esi
  801036:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801039:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80103c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80103f:	75 2f                	jne    801070 <__udivdi3+0x50>
  801041:	39 f9                	cmp    %edi,%ecx
  801043:	77 5b                	ja     8010a0 <__udivdi3+0x80>
  801045:	85 c9                	test   %ecx,%ecx
  801047:	75 0b                	jne    801054 <__udivdi3+0x34>
  801049:	b8 01 00 00 00       	mov    $0x1,%eax
  80104e:	31 d2                	xor    %edx,%edx
  801050:	f7 f1                	div    %ecx
  801052:	89 c1                	mov    %eax,%ecx
  801054:	89 f8                	mov    %edi,%eax
  801056:	31 d2                	xor    %edx,%edx
  801058:	f7 f1                	div    %ecx
  80105a:	89 c7                	mov    %eax,%edi
  80105c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105f:	f7 f1                	div    %ecx
  801061:	89 fa                	mov    %edi,%edx
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	5e                   	pop    %esi
  801067:	5f                   	pop    %edi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    
  80106a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801070:	31 d2                	xor    %edx,%edx
  801072:	31 c0                	xor    %eax,%eax
  801074:	39 fe                	cmp    %edi,%esi
  801076:	77 eb                	ja     801063 <__udivdi3+0x43>
  801078:	0f bd d6             	bsr    %esi,%edx
  80107b:	83 f2 1f             	xor    $0x1f,%edx
  80107e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801081:	75 2d                	jne    8010b0 <__udivdi3+0x90>
  801083:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801086:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  801089:	76 06                	jbe    801091 <__udivdi3+0x71>
  80108b:	39 fe                	cmp    %edi,%esi
  80108d:	89 c2                	mov    %eax,%edx
  80108f:	73 d2                	jae    801063 <__udivdi3+0x43>
  801091:	31 d2                	xor    %edx,%edx
  801093:	b8 01 00 00 00       	mov    $0x1,%eax
  801098:	eb c9                	jmp    801063 <__udivdi3+0x43>
  80109a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010a0:	89 fa                	mov    %edi,%edx
  8010a2:	f7 f1                	div    %ecx
  8010a4:	31 d2                	xor    %edx,%edx
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	5e                   	pop    %esi
  8010aa:	5f                   	pop    %edi
  8010ab:	5d                   	pop    %ebp
  8010ac:	c3                   	ret    
  8010ad:	8d 76 00             	lea    0x0(%esi),%esi
  8010b0:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010b4:	b8 20 00 00 00       	mov    $0x20,%eax
  8010b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010bc:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8010bf:	d3 e6                	shl    %cl,%esi
  8010c1:	89 c1                	mov    %eax,%ecx
  8010c3:	d3 ea                	shr    %cl,%edx
  8010c5:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010c9:	09 f2                	or     %esi,%edx
  8010cb:	8b 75 ec             	mov    -0x14(%ebp),%esi
  8010ce:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8010d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010d4:	d3 e2                	shl    %cl,%edx
  8010d6:	89 c1                	mov    %eax,%ecx
  8010d8:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8010db:	89 fa                	mov    %edi,%edx
  8010dd:	d3 ea                	shr    %cl,%edx
  8010df:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010e3:	d3 e7                	shl    %cl,%edi
  8010e5:	89 c1                	mov    %eax,%ecx
  8010e7:	d3 ee                	shr    %cl,%esi
  8010e9:	09 fe                	or     %edi,%esi
  8010eb:	89 f0                	mov    %esi,%eax
  8010ed:	f7 75 e8             	divl   -0x18(%ebp)
  8010f0:	89 d7                	mov    %edx,%edi
  8010f2:	89 c6                	mov    %eax,%esi
  8010f4:	f7 65 f0             	mull   -0x10(%ebp)
  8010f7:	39 d7                	cmp    %edx,%edi
  8010f9:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8010fc:	72 22                	jb     801120 <__udivdi3+0x100>
  8010fe:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801101:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801105:	d3 e2                	shl    %cl,%edx
  801107:	39 c2                	cmp    %eax,%edx
  801109:	73 05                	jae    801110 <__udivdi3+0xf0>
  80110b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80110e:	74 10                	je     801120 <__udivdi3+0x100>
  801110:	89 f0                	mov    %esi,%eax
  801112:	31 d2                	xor    %edx,%edx
  801114:	e9 4a ff ff ff       	jmp    801063 <__udivdi3+0x43>
  801119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801120:	8d 46 ff             	lea    -0x1(%esi),%eax
  801123:	31 d2                	xor    %edx,%edx
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	5e                   	pop    %esi
  801129:	5f                   	pop    %edi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    
  80112c:	00 00                	add    %al,(%eax)
	...

00801130 <__umoddi3>:
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	57                   	push   %edi
  801134:	56                   	push   %esi
  801135:	83 ec 20             	sub    $0x20,%esp
  801138:	8b 7d 14             	mov    0x14(%ebp),%edi
  80113b:	8b 45 08             	mov    0x8(%ebp),%eax
  80113e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801141:	8b 75 0c             	mov    0xc(%ebp),%esi
  801144:	85 ff                	test   %edi,%edi
  801146:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801149:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80114c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80114f:	89 f2                	mov    %esi,%edx
  801151:	75 15                	jne    801168 <__umoddi3+0x38>
  801153:	39 f1                	cmp    %esi,%ecx
  801155:	76 41                	jbe    801198 <__umoddi3+0x68>
  801157:	f7 f1                	div    %ecx
  801159:	89 d0                	mov    %edx,%eax
  80115b:	31 d2                	xor    %edx,%edx
  80115d:	83 c4 20             	add    $0x20,%esp
  801160:	5e                   	pop    %esi
  801161:	5f                   	pop    %edi
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    
  801164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801168:	39 f7                	cmp    %esi,%edi
  80116a:	77 4c                	ja     8011b8 <__umoddi3+0x88>
  80116c:	0f bd c7             	bsr    %edi,%eax
  80116f:	83 f0 1f             	xor    $0x1f,%eax
  801172:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801175:	75 51                	jne    8011c8 <__umoddi3+0x98>
  801177:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80117a:	0f 87 e8 00 00 00    	ja     801268 <__umoddi3+0x138>
  801180:	89 f2                	mov    %esi,%edx
  801182:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801185:	29 ce                	sub    %ecx,%esi
  801187:	19 fa                	sbb    %edi,%edx
  801189:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80118c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118f:	83 c4 20             	add    $0x20,%esp
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    
  801196:	66 90                	xchg   %ax,%ax
  801198:	85 c9                	test   %ecx,%ecx
  80119a:	75 0b                	jne    8011a7 <__umoddi3+0x77>
  80119c:	b8 01 00 00 00       	mov    $0x1,%eax
  8011a1:	31 d2                	xor    %edx,%edx
  8011a3:	f7 f1                	div    %ecx
  8011a5:	89 c1                	mov    %eax,%ecx
  8011a7:	89 f0                	mov    %esi,%eax
  8011a9:	31 d2                	xor    %edx,%edx
  8011ab:	f7 f1                	div    %ecx
  8011ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b0:	eb a5                	jmp    801157 <__umoddi3+0x27>
  8011b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011b8:	89 f2                	mov    %esi,%edx
  8011ba:	83 c4 20             	add    $0x20,%esp
  8011bd:	5e                   	pop    %esi
  8011be:	5f                   	pop    %edi
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    
  8011c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011cc:	89 f2                	mov    %esi,%edx
  8011ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011d1:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  8011d8:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8011db:	d3 e7                	shl    %cl,%edi
  8011dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011e4:	d3 e8                	shr    %cl,%eax
  8011e6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011ea:	09 f8                	or     %edi,%eax
  8011ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f2:	d3 e0                	shl    %cl,%eax
  8011f4:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8011fe:	d3 ea                	shr    %cl,%edx
  801200:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801204:	d3 e6                	shl    %cl,%esi
  801206:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80120a:	d3 e8                	shr    %cl,%eax
  80120c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801210:	09 f0                	or     %esi,%eax
  801212:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801215:	f7 75 e4             	divl   -0x1c(%ebp)
  801218:	d3 e6                	shl    %cl,%esi
  80121a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80121d:	89 d6                	mov    %edx,%esi
  80121f:	f7 65 f4             	mull   -0xc(%ebp)
  801222:	89 d7                	mov    %edx,%edi
  801224:	89 c2                	mov    %eax,%edx
  801226:	39 fe                	cmp    %edi,%esi
  801228:	89 f9                	mov    %edi,%ecx
  80122a:	72 30                	jb     80125c <__umoddi3+0x12c>
  80122c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80122f:	72 27                	jb     801258 <__umoddi3+0x128>
  801231:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801234:	29 d0                	sub    %edx,%eax
  801236:	19 ce                	sbb    %ecx,%esi
  801238:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80123c:	89 f2                	mov    %esi,%edx
  80123e:	d3 e8                	shr    %cl,%eax
  801240:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801244:	d3 e2                	shl    %cl,%edx
  801246:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80124a:	09 d0                	or     %edx,%eax
  80124c:	89 f2                	mov    %esi,%edx
  80124e:	d3 ea                	shr    %cl,%edx
  801250:	83 c4 20             	add    $0x20,%esp
  801253:	5e                   	pop    %esi
  801254:	5f                   	pop    %edi
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    
  801257:	90                   	nop
  801258:	39 fe                	cmp    %edi,%esi
  80125a:	75 d5                	jne    801231 <__umoddi3+0x101>
  80125c:	89 f9                	mov    %edi,%ecx
  80125e:	89 c2                	mov    %eax,%edx
  801260:	2b 55 f4             	sub    -0xc(%ebp),%edx
  801263:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801266:	eb c9                	jmp    801231 <__umoddi3+0x101>
  801268:	39 f7                	cmp    %esi,%edi
  80126a:	0f 82 10 ff ff ff    	jb     801180 <__umoddi3+0x50>
  801270:	e9 17 ff ff ff       	jmp    80118c <__umoddi3+0x5c>
