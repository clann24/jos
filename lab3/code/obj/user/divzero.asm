
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 c2                	mov    %eax,%edx
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 18 0f 80 00 	movl   $0x800f18,(%esp)
  800060:	e8 f2 00 00 00       	call   800157 <cprintf>
}
  800065:	c9                   	leave  
  800066:	c3                   	ret    
	...

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
  80006e:	8b 45 08             	mov    0x8(%ebp),%eax
  800071:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800074:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80007b:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 c0                	test   %eax,%eax
  800080:	7e 08                	jle    80008a <libmain+0x22>
		binaryname = argv[0];
  800082:	8b 0a                	mov    (%edx),%ecx
  800084:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80008a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80008e:	89 04 24             	mov    %eax,(%esp)
  800091:	e8 9e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800096:	e8 05 00 00 00       	call   8000a0 <exit>
}
  80009b:	c9                   	leave  
  80009c:	c3                   	ret    
  80009d:	00 00                	add    %al,(%eax)
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 19 0b 00 00       	call   800bcb <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	53                   	push   %ebx
  8000b8:	83 ec 14             	sub    $0x14,%esp
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000be:	8b 03                	mov    (%ebx),%eax
  8000c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000c7:	83 c0 01             	add    $0x1,%eax
  8000ca:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000cc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d1:	75 19                	jne    8000ec <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000d3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000da:	00 
  8000db:	8d 43 08             	lea    0x8(%ebx),%eax
  8000de:	89 04 24             	mov    %eax,(%esp)
  8000e1:	e8 7e 0a 00 00       	call   800b64 <sys_cputs>
		b->idx = 0;
  8000e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000ec:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f0:	83 c4 14             	add    $0x14,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    

008000f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000ff:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800106:	00 00 00 
	b.cnt = 0;
  800109:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800110:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800113:	8b 45 0c             	mov    0xc(%ebp),%eax
  800116:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011a:	8b 45 08             	mov    0x8(%ebp),%eax
  80011d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800121:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800127:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012b:	c7 04 24 b4 00 80 00 	movl   $0x8000b4,(%esp)
  800132:	e8 ea 01 00 00       	call   800321 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800137:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80013d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800141:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800147:	89 04 24             	mov    %eax,(%esp)
  80014a:	e8 15 0a 00 00       	call   800b64 <sys_cputs>

	return b.cnt;
}
  80014f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800160:	89 44 24 04          	mov    %eax,0x4(%esp)
  800164:	8b 45 08             	mov    0x8(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 87 ff ff ff       	call   8000f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016f:	c9                   	leave  
  800170:	c3                   	ret    
	...

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 4c             	sub    $0x4c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d6                	mov    %edx,%esi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800194:	8b 55 0c             	mov    0xc(%ebp),%edx
  800197:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80019a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80019d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a5:	39 d0                	cmp    %edx,%eax
  8001a7:	72 11                	jb     8001ba <printnum+0x3a>
  8001a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001ac:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8001af:	76 09                	jbe    8001ba <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b1:	83 eb 01             	sub    $0x1,%ebx
  8001b4:	85 db                	test   %ebx,%ebx
  8001b6:	7f 5d                	jg     800215 <printnum+0x95>
  8001b8:	eb 6c                	jmp    800226 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ba:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001be:	83 eb 01             	sub    $0x1,%ebx
  8001c1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001cc:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001d0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001d7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8001da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001e1:	00 
  8001e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001e5:	89 14 24             	mov    %edx,(%esp)
  8001e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8001eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8001ef:	e8 cc 0a 00 00       	call   800cc0 <__udivdi3>
  8001f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8001f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8001fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800202:	89 04 24             	mov    %eax,(%esp)
  800205:	89 54 24 04          	mov    %edx,0x4(%esp)
  800209:	89 f2                	mov    %esi,%edx
  80020b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020e:	e8 6d ff ff ff       	call   800180 <printnum>
  800213:	eb 11                	jmp    800226 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800215:	89 74 24 04          	mov    %esi,0x4(%esp)
  800219:	89 3c 24             	mov    %edi,(%esp)
  80021c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021f:	83 eb 01             	sub    $0x1,%ebx
  800222:	85 db                	test   %ebx,%ebx
  800224:	7f ef                	jg     800215 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800226:	89 74 24 04          	mov    %esi,0x4(%esp)
  80022a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80022e:	8b 45 10             	mov    0x10(%ebp),%eax
  800231:	89 44 24 08          	mov    %eax,0x8(%esp)
  800235:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023c:	00 
  80023d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800240:	89 14 24             	mov    %edx,(%esp)
  800243:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800246:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80024a:	e8 81 0b 00 00       	call   800dd0 <__umoddi3>
  80024f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800253:	0f be 80 30 0f 80 00 	movsbl 0x800f30(%eax),%eax
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800260:	83 c4 4c             	add    $0x4c,%esp
  800263:	5b                   	pop    %ebx
  800264:	5e                   	pop    %esi
  800265:	5f                   	pop    %edi
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    

00800268 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026b:	83 fa 01             	cmp    $0x1,%edx
  80026e:	7e 0e                	jle    80027e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800270:	8b 10                	mov    (%eax),%edx
  800272:	8d 4a 08             	lea    0x8(%edx),%ecx
  800275:	89 08                	mov    %ecx,(%eax)
  800277:	8b 02                	mov    (%edx),%eax
  800279:	8b 52 04             	mov    0x4(%edx),%edx
  80027c:	eb 22                	jmp    8002a0 <getuint+0x38>
	else if (lflag)
  80027e:	85 d2                	test   %edx,%edx
  800280:	74 10                	je     800292 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800282:	8b 10                	mov    (%eax),%edx
  800284:	8d 4a 04             	lea    0x4(%edx),%ecx
  800287:	89 08                	mov    %ecx,(%eax)
  800289:	8b 02                	mov    (%edx),%eax
  80028b:	ba 00 00 00 00       	mov    $0x0,%edx
  800290:	eb 0e                	jmp    8002a0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800292:	8b 10                	mov    (%eax),%edx
  800294:	8d 4a 04             	lea    0x4(%edx),%ecx
  800297:	89 08                	mov    %ecx,(%eax)
  800299:	8b 02                	mov    (%edx),%eax
  80029b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a5:	83 fa 01             	cmp    $0x1,%edx
  8002a8:	7e 0e                	jle    8002b8 <getint+0x16>
		return va_arg(*ap, long long);
  8002aa:	8b 10                	mov    (%eax),%edx
  8002ac:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002af:	89 08                	mov    %ecx,(%eax)
  8002b1:	8b 02                	mov    (%edx),%eax
  8002b3:	8b 52 04             	mov    0x4(%edx),%edx
  8002b6:	eb 22                	jmp    8002da <getint+0x38>
	else if (lflag)
  8002b8:	85 d2                	test   %edx,%edx
  8002ba:	74 10                	je     8002cc <getint+0x2a>
		return va_arg(*ap, long);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	89 c2                	mov    %eax,%edx
  8002c7:	c1 fa 1f             	sar    $0x1f,%edx
  8002ca:	eb 0e                	jmp    8002da <getint+0x38>
	else
		return va_arg(*ap, int);
  8002cc:	8b 10                	mov    (%eax),%edx
  8002ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d1:	89 08                	mov    %ecx,(%eax)
  8002d3:	8b 02                	mov    (%edx),%eax
  8002d5:	89 c2                	mov    %eax,%edx
  8002d7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    

008002dc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e6:	8b 10                	mov    (%eax),%edx
  8002e8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002eb:	73 0a                	jae    8002f7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f0:	88 0a                	mov    %cl,(%edx)
  8002f2:	83 c2 01             	add    $0x1,%edx
  8002f5:	89 10                	mov    %edx,(%eax)
}
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ff:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800302:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800306:	8b 45 10             	mov    0x10(%ebp),%eax
  800309:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	8b 45 08             	mov    0x8(%ebp),%eax
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	e8 02 00 00 00       	call   800321 <vprintfmt>
	va_end(ap);
}
  80031f:	c9                   	leave  
  800320:	c3                   	ret    

00800321 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	57                   	push   %edi
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
  800327:	83 ec 4c             	sub    $0x4c,%esp
  80032a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032d:	eb 23                	jmp    800352 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80032f:	85 c0                	test   %eax,%eax
  800331:	75 12                	jne    800345 <vprintfmt+0x24>
				csa = 0x0700;
  800333:	c7 05 0c 20 80 00 00 	movl   $0x700,0x80200c
  80033a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80033d:	83 c4 4c             	add    $0x4c,%esp
  800340:	5b                   	pop    %ebx
  800341:	5e                   	pop    %esi
  800342:	5f                   	pop    %edi
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800345:	8b 55 0c             	mov    0xc(%ebp),%edx
  800348:	89 54 24 04          	mov    %edx,0x4(%esp)
  80034c:	89 04 24             	mov    %eax,(%esp)
  80034f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800352:	0f b6 07             	movzbl (%edi),%eax
  800355:	83 c7 01             	add    $0x1,%edi
  800358:	83 f8 25             	cmp    $0x25,%eax
  80035b:	75 d2                	jne    80032f <vprintfmt+0xe>
  80035d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800361:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800368:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80036d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800374:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800379:	be 00 00 00 00       	mov    $0x0,%esi
  80037e:	eb 14                	jmp    800394 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800380:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800384:	eb 0e                	jmp    800394 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800386:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80038a:	eb 08                	jmp    800394 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80038c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80038f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	0f b6 07             	movzbl (%edi),%eax
  800397:	0f b6 c8             	movzbl %al,%ecx
  80039a:	83 c7 01             	add    $0x1,%edi
  80039d:	83 e8 23             	sub    $0x23,%eax
  8003a0:	3c 55                	cmp    $0x55,%al
  8003a2:	0f 87 ed 02 00 00    	ja     800695 <vprintfmt+0x374>
  8003a8:	0f b6 c0             	movzbl %al,%eax
  8003ab:	ff 24 85 c0 0f 80 00 	jmp    *0x800fc0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  8003b5:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003b8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003bb:	83 f9 09             	cmp    $0x9,%ecx
  8003be:	77 3c                	ja     8003fc <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003c3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8003c6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8003ca:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003cd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003d0:	83 f9 09             	cmp    $0x9,%ecx
  8003d3:	76 eb                	jbe    8003c0 <vprintfmt+0x9f>
  8003d5:	eb 25                	jmp    8003fc <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 48 04             	lea    0x4(%eax),%ecx
  8003dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  8003e2:	eb 18                	jmp    8003fc <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  8003e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003eb:	0f 48 c6             	cmovs  %esi,%eax
  8003ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f1:	eb a1                	jmp    800394 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  8003f3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003fa:	eb 98                	jmp    800394 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  8003fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800400:	79 92                	jns    800394 <vprintfmt+0x73>
  800402:	eb 88                	jmp    80038c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800404:	83 c2 01             	add    $0x1,%edx
  800407:	eb 8b                	jmp    800394 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 50 04             	lea    0x4(%eax),%edx
  80040f:	89 55 14             	mov    %edx,0x14(%ebp)
  800412:	8b 55 0c             	mov    0xc(%ebp),%edx
  800415:	89 54 24 04          	mov    %edx,0x4(%esp)
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	89 04 24             	mov    %eax,(%esp)
  80041e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800421:	e9 2c ff ff ff       	jmp    800352 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 50 04             	lea    0x4(%eax),%edx
  80042c:	89 55 14             	mov    %edx,0x14(%ebp)
  80042f:	8b 00                	mov    (%eax),%eax
  800431:	89 c2                	mov    %eax,%edx
  800433:	c1 fa 1f             	sar    $0x1f,%edx
  800436:	31 d0                	xor    %edx,%eax
  800438:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043a:	83 f8 06             	cmp    $0x6,%eax
  80043d:	7f 0b                	jg     80044a <vprintfmt+0x129>
  80043f:	8b 14 85 18 11 80 00 	mov    0x801118(,%eax,4),%edx
  800446:	85 d2                	test   %edx,%edx
  800448:	75 23                	jne    80046d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80044a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044e:	c7 44 24 08 48 0f 80 	movl   $0x800f48,0x8(%esp)
  800455:	00 
  800456:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800459:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80045d:	8b 45 08             	mov    0x8(%ebp),%eax
  800460:	89 04 24             	mov    %eax,(%esp)
  800463:	e8 91 fe ff ff       	call   8002f9 <printfmt>
  800468:	e9 e5 fe ff ff       	jmp    800352 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80046d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800471:	c7 44 24 08 51 0f 80 	movl   $0x800f51,0x8(%esp)
  800478:	00 
  800479:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800480:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800483:	89 1c 24             	mov    %ebx,(%esp)
  800486:	e8 6e fe ff ff       	call   8002f9 <printfmt>
  80048b:	e9 c2 fe ff ff       	jmp    800352 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800493:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800496:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	8d 50 04             	lea    0x4(%eax),%edx
  80049f:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a2:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004a4:	85 f6                	test   %esi,%esi
  8004a6:	ba 41 0f 80 00       	mov    $0x800f41,%edx
  8004ab:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8004ae:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b2:	7e 06                	jle    8004ba <vprintfmt+0x199>
  8004b4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004b8:	75 13                	jne    8004cd <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ba:	0f be 06             	movsbl (%esi),%eax
  8004bd:	83 c6 01             	add    $0x1,%esi
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	0f 85 a2 00 00 00    	jne    80056a <vprintfmt+0x249>
  8004c8:	e9 92 00 00 00       	jmp    80055f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d1:	89 34 24             	mov    %esi,(%esp)
  8004d4:	e8 82 02 00 00       	call   80075b <strnlen>
  8004d9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004dc:	29 c2                	sub    %eax,%edx
  8004de:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004e1:	85 d2                	test   %edx,%edx
  8004e3:	7e d5                	jle    8004ba <vprintfmt+0x199>
					putch(padc, putdat);
  8004e5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8004e9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004ec:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8004ef:	89 d3                	mov    %edx,%ebx
  8004f1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004f4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004f7:	89 c6                	mov    %eax,%esi
  8004f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004fd:	89 34 24             	mov    %esi,(%esp)
  800500:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 eb 01             	sub    $0x1,%ebx
  800506:	85 db                	test   %ebx,%ebx
  800508:	7f ef                	jg     8004f9 <vprintfmt+0x1d8>
  80050a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80050d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800510:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800513:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80051a:	eb 9e                	jmp    8004ba <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800520:	74 1b                	je     80053d <vprintfmt+0x21c>
  800522:	8d 50 e0             	lea    -0x20(%eax),%edx
  800525:	83 fa 5e             	cmp    $0x5e,%edx
  800528:	76 13                	jbe    80053d <vprintfmt+0x21c>
					putch('?', putdat);
  80052a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80052d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800531:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800538:	ff 55 08             	call   *0x8(%ebp)
  80053b:	eb 0d                	jmp    80054a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80053d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800540:	89 54 24 04          	mov    %edx,0x4(%esp)
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054a:	83 ef 01             	sub    $0x1,%edi
  80054d:	0f be 06             	movsbl (%esi),%eax
  800550:	85 c0                	test   %eax,%eax
  800552:	74 05                	je     800559 <vprintfmt+0x238>
  800554:	83 c6 01             	add    $0x1,%esi
  800557:	eb 17                	jmp    800570 <vprintfmt+0x24f>
  800559:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80055c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800563:	7f 1c                	jg     800581 <vprintfmt+0x260>
  800565:	e9 e8 fd ff ff       	jmp    800352 <vprintfmt+0x31>
  80056a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800570:	85 db                	test   %ebx,%ebx
  800572:	78 a8                	js     80051c <vprintfmt+0x1fb>
  800574:	83 eb 01             	sub    $0x1,%ebx
  800577:	79 a3                	jns    80051c <vprintfmt+0x1fb>
  800579:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80057c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80057f:	eb de                	jmp    80055f <vprintfmt+0x23e>
  800581:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800584:	8b 7d 08             	mov    0x8(%ebp),%edi
  800587:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80058e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800595:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	83 eb 01             	sub    $0x1,%ebx
  80059a:	85 db                	test   %ebx,%ebx
  80059c:	7f ec                	jg     80058a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005a1:	e9 ac fd ff ff       	jmp    800352 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a9:	e8 f4 fc ff ff       	call   8002a2 <getint>
  8005ae:	89 c3                	mov    %eax,%ebx
  8005b0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005b2:	85 d2                	test   %edx,%edx
  8005b4:	78 0a                	js     8005c0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005bb:	e9 87 00 00 00       	jmp    800647 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005ce:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005d1:	89 d8                	mov    %ebx,%eax
  8005d3:	89 f2                	mov    %esi,%edx
  8005d5:	f7 d8                	neg    %eax
  8005d7:	83 d2 00             	adc    $0x0,%edx
  8005da:	f7 da                	neg    %edx
			}
			base = 10;
  8005dc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e1:	eb 64                	jmp    800647 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e6:	e8 7d fc ff ff       	call   800268 <getuint>
			base = 10;
  8005eb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f0:	eb 55                	jmp    800647 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8005f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f5:	e8 6e fc ff ff       	call   800268 <getuint>
      base = 8;
  8005fa:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8005ff:	eb 46                	jmp    800647 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800601:	8b 55 0c             	mov    0xc(%ebp),%edx
  800604:	89 54 24 04          	mov    %edx,0x4(%esp)
  800608:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80060f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800612:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800615:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800619:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800620:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 04             	lea    0x4(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800633:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800638:	eb 0d                	jmp    800647 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 26 fc ff ff       	call   800268 <getuint>
			base = 16;
  800642:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800647:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80064b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80064f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800652:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800656:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80065a:	89 04 24             	mov    %eax,(%esp)
  80065d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800661:	8b 55 0c             	mov    0xc(%ebp),%edx
  800664:	8b 45 08             	mov    0x8(%ebp),%eax
  800667:	e8 14 fb ff ff       	call   800180 <printnum>
			break;
  80066c:	e9 e1 fc ff ff       	jmp    800352 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800671:	8b 45 0c             	mov    0xc(%ebp),%eax
  800674:	89 44 24 04          	mov    %eax,0x4(%esp)
  800678:	89 0c 24             	mov    %ecx,(%esp)
  80067b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80067e:	e9 cf fc ff ff       	jmp    800352 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 17 fc ff ff       	call   8002a2 <getint>
			csa = num;
  80068b:	a3 0c 20 80 00       	mov    %eax,0x80200c
			break;
  800690:	e9 bd fc ff ff       	jmp    800352 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800695:	8b 55 0c             	mov    0xc(%ebp),%edx
  800698:	89 54 24 04          	mov    %edx,0x4(%esp)
  80069c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006a3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a6:	83 ef 01             	sub    $0x1,%edi
  8006a9:	eb 02                	jmp    8006ad <vprintfmt+0x38c>
  8006ab:	89 c7                	mov    %eax,%edi
  8006ad:	8d 47 ff             	lea    -0x1(%edi),%eax
  8006b0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006b4:	75 f5                	jne    8006ab <vprintfmt+0x38a>
  8006b6:	e9 97 fc ff ff       	jmp    800352 <vprintfmt+0x31>

008006bb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	83 ec 28             	sub    $0x28,%esp
  8006c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ca:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ce:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	74 30                	je     80070c <vsnprintf+0x51>
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	7e 2c                	jle    80070c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f5:	c7 04 24 dc 02 80 00 	movl   $0x8002dc,(%esp)
  8006fc:	e8 20 fc ff ff       	call   800321 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800701:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800704:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800707:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070a:	eb 05                	jmp    800711 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80070c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800711:	c9                   	leave  
  800712:	c3                   	ret    

00800713 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800719:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800720:	8b 45 10             	mov    0x10(%ebp),%eax
  800723:	89 44 24 08          	mov    %eax,0x8(%esp)
  800727:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072e:	8b 45 08             	mov    0x8(%ebp),%eax
  800731:	89 04 24             	mov    %eax,(%esp)
  800734:	e8 82 ff ff ff       	call   8006bb <vsnprintf>
	va_end(ap);

	return rc;
}
  800739:	c9                   	leave  
  80073a:	c3                   	ret    
  80073b:	00 00                	add    %al,(%eax)
  80073d:	00 00                	add    %al,(%eax)
	...

00800740 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	b8 00 00 00 00       	mov    $0x0,%eax
  80074b:	80 3a 00             	cmpb   $0x0,(%edx)
  80074e:	74 09                	je     800759 <strlen+0x19>
		n++;
  800750:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800753:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800757:	75 f7                	jne    800750 <strlen+0x10>
		n++;
	return n;
}
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800761:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800764:	b8 00 00 00 00       	mov    $0x0,%eax
  800769:	85 d2                	test   %edx,%edx
  80076b:	74 12                	je     80077f <strnlen+0x24>
  80076d:	80 39 00             	cmpb   $0x0,(%ecx)
  800770:	74 0d                	je     80077f <strnlen+0x24>
		n++;
  800772:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800775:	39 d0                	cmp    %edx,%eax
  800777:	74 06                	je     80077f <strnlen+0x24>
  800779:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80077d:	75 f3                	jne    800772 <strnlen+0x17>
		n++;
	return n;
}
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	53                   	push   %ebx
  800785:	8b 45 08             	mov    0x8(%ebp),%eax
  800788:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078b:	ba 00 00 00 00       	mov    $0x0,%edx
  800790:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800794:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800797:	83 c2 01             	add    $0x1,%edx
  80079a:	84 c9                	test   %cl,%cl
  80079c:	75 f2                	jne    800790 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80079e:	5b                   	pop    %ebx
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	53                   	push   %ebx
  8007a5:	83 ec 08             	sub    $0x8,%esp
  8007a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ab:	89 1c 24             	mov    %ebx,(%esp)
  8007ae:	e8 8d ff ff ff       	call   800740 <strlen>
	strcpy(dst + len, src);
  8007b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ba:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007bd:	89 04 24             	mov    %eax,(%esp)
  8007c0:	e8 bc ff ff ff       	call   800781 <strcpy>
	return dst;
}
  8007c5:	89 d8                	mov    %ebx,%eax
  8007c7:	83 c4 08             	add    $0x8,%esp
  8007ca:	5b                   	pop    %ebx
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	56                   	push   %esi
  8007d1:	53                   	push   %ebx
  8007d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007db:	85 f6                	test   %esi,%esi
  8007dd:	74 18                	je     8007f7 <strncpy+0x2a>
  8007df:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007e4:	0f b6 1a             	movzbl (%edx),%ebx
  8007e7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ea:	80 3a 01             	cmpb   $0x1,(%edx)
  8007ed:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f0:	83 c1 01             	add    $0x1,%ecx
  8007f3:	39 ce                	cmp    %ecx,%esi
  8007f5:	77 ed                	ja     8007e4 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f7:	5b                   	pop    %ebx
  8007f8:	5e                   	pop    %esi
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 75 08             	mov    0x8(%ebp),%esi
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800809:	89 f0                	mov    %esi,%eax
  80080b:	85 c9                	test   %ecx,%ecx
  80080d:	74 23                	je     800832 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  80080f:	83 e9 01             	sub    $0x1,%ecx
  800812:	74 1b                	je     80082f <strlcpy+0x34>
  800814:	0f b6 1a             	movzbl (%edx),%ebx
  800817:	84 db                	test   %bl,%bl
  800819:	74 14                	je     80082f <strlcpy+0x34>
			*dst++ = *src++;
  80081b:	88 18                	mov    %bl,(%eax)
  80081d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800820:	83 e9 01             	sub    $0x1,%ecx
  800823:	74 0a                	je     80082f <strlcpy+0x34>
			*dst++ = *src++;
  800825:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800828:	0f b6 1a             	movzbl (%edx),%ebx
  80082b:	84 db                	test   %bl,%bl
  80082d:	75 ec                	jne    80081b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80082f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800832:	29 f0                	sub    %esi,%eax
}
  800834:	5b                   	pop    %ebx
  800835:	5e                   	pop    %esi
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800841:	0f b6 01             	movzbl (%ecx),%eax
  800844:	84 c0                	test   %al,%al
  800846:	74 15                	je     80085d <strcmp+0x25>
  800848:	3a 02                	cmp    (%edx),%al
  80084a:	75 11                	jne    80085d <strcmp+0x25>
		p++, q++;
  80084c:	83 c1 01             	add    $0x1,%ecx
  80084f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800852:	0f b6 01             	movzbl (%ecx),%eax
  800855:	84 c0                	test   %al,%al
  800857:	74 04                	je     80085d <strcmp+0x25>
  800859:	3a 02                	cmp    (%edx),%al
  80085b:	74 ef                	je     80084c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085d:	0f b6 c0             	movzbl %al,%eax
  800860:	0f b6 12             	movzbl (%edx),%edx
  800863:	29 d0                	sub    %edx,%eax
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800871:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800879:	85 d2                	test   %edx,%edx
  80087b:	74 28                	je     8008a5 <strncmp+0x3e>
  80087d:	0f b6 01             	movzbl (%ecx),%eax
  800880:	84 c0                	test   %al,%al
  800882:	74 24                	je     8008a8 <strncmp+0x41>
  800884:	3a 03                	cmp    (%ebx),%al
  800886:	75 20                	jne    8008a8 <strncmp+0x41>
  800888:	83 ea 01             	sub    $0x1,%edx
  80088b:	74 13                	je     8008a0 <strncmp+0x39>
		n--, p++, q++;
  80088d:	83 c1 01             	add    $0x1,%ecx
  800890:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800893:	0f b6 01             	movzbl (%ecx),%eax
  800896:	84 c0                	test   %al,%al
  800898:	74 0e                	je     8008a8 <strncmp+0x41>
  80089a:	3a 03                	cmp    (%ebx),%al
  80089c:	74 ea                	je     800888 <strncmp+0x21>
  80089e:	eb 08                	jmp    8008a8 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a5:	5b                   	pop    %ebx
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a8:	0f b6 01             	movzbl (%ecx),%eax
  8008ab:	0f b6 13             	movzbl (%ebx),%edx
  8008ae:	29 d0                	sub    %edx,%eax
  8008b0:	eb f3                	jmp    8008a5 <strncmp+0x3e>

008008b2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bc:	0f b6 10             	movzbl (%eax),%edx
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	74 20                	je     8008e3 <strchr+0x31>
		if (*s == c)
  8008c3:	38 ca                	cmp    %cl,%dl
  8008c5:	75 0b                	jne    8008d2 <strchr+0x20>
  8008c7:	eb 1f                	jmp    8008e8 <strchr+0x36>
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	90                   	nop
  8008cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8008d0:	74 16                	je     8008e8 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d2:	83 c0 01             	add    $0x1,%eax
  8008d5:	0f b6 10             	movzbl (%eax),%edx
  8008d8:	84 d2                	test   %dl,%dl
  8008da:	75 ed                	jne    8008c9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e1:	eb 05                	jmp    8008e8 <strchr+0x36>
  8008e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f4:	0f b6 10             	movzbl (%eax),%edx
  8008f7:	84 d2                	test   %dl,%dl
  8008f9:	74 14                	je     80090f <strfind+0x25>
		if (*s == c)
  8008fb:	38 ca                	cmp    %cl,%dl
  8008fd:	75 06                	jne    800905 <strfind+0x1b>
  8008ff:	eb 0e                	jmp    80090f <strfind+0x25>
  800901:	38 ca                	cmp    %cl,%dl
  800903:	74 0a                	je     80090f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800905:	83 c0 01             	add    $0x1,%eax
  800908:	0f b6 10             	movzbl (%eax),%edx
  80090b:	84 d2                	test   %dl,%dl
  80090d:	75 f2                	jne    800901 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	83 ec 0c             	sub    $0xc,%esp
  800917:	89 1c 24             	mov    %ebx,(%esp)
  80091a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80091e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800922:	8b 7d 08             	mov    0x8(%ebp),%edi
  800925:	8b 45 0c             	mov    0xc(%ebp),%eax
  800928:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092b:	85 c9                	test   %ecx,%ecx
  80092d:	74 30                	je     80095f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800935:	75 25                	jne    80095c <memset+0x4b>
  800937:	f6 c1 03             	test   $0x3,%cl
  80093a:	75 20                	jne    80095c <memset+0x4b>
		c &= 0xFF;
  80093c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093f:	89 d3                	mov    %edx,%ebx
  800941:	c1 e3 08             	shl    $0x8,%ebx
  800944:	89 d6                	mov    %edx,%esi
  800946:	c1 e6 18             	shl    $0x18,%esi
  800949:	89 d0                	mov    %edx,%eax
  80094b:	c1 e0 10             	shl    $0x10,%eax
  80094e:	09 f0                	or     %esi,%eax
  800950:	09 d0                	or     %edx,%eax
  800952:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800954:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800957:	fc                   	cld    
  800958:	f3 ab                	rep stos %eax,%es:(%edi)
  80095a:	eb 03                	jmp    80095f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095c:	fc                   	cld    
  80095d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095f:	89 f8                	mov    %edi,%eax
  800961:	8b 1c 24             	mov    (%esp),%ebx
  800964:	8b 74 24 04          	mov    0x4(%esp),%esi
  800968:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80096c:	89 ec                	mov    %ebp,%esp
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	83 ec 08             	sub    $0x8,%esp
  800976:	89 34 24             	mov    %esi,(%esp)
  800979:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8b 75 0c             	mov    0xc(%ebp),%esi
  800983:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800986:	39 c6                	cmp    %eax,%esi
  800988:	73 36                	jae    8009c0 <memmove+0x50>
  80098a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098d:	39 d0                	cmp    %edx,%eax
  80098f:	73 2f                	jae    8009c0 <memmove+0x50>
		s += n;
		d += n;
  800991:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800994:	f6 c2 03             	test   $0x3,%dl
  800997:	75 1b                	jne    8009b4 <memmove+0x44>
  800999:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099f:	75 13                	jne    8009b4 <memmove+0x44>
  8009a1:	f6 c1 03             	test   $0x3,%cl
  8009a4:	75 0e                	jne    8009b4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a6:	83 ef 04             	sub    $0x4,%edi
  8009a9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ac:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009af:	fd                   	std    
  8009b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b2:	eb 09                	jmp    8009bd <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b4:	83 ef 01             	sub    $0x1,%edi
  8009b7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ba:	fd                   	std    
  8009bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009bd:	fc                   	cld    
  8009be:	eb 20                	jmp    8009e0 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c6:	75 13                	jne    8009db <memmove+0x6b>
  8009c8:	a8 03                	test   $0x3,%al
  8009ca:	75 0f                	jne    8009db <memmove+0x6b>
  8009cc:	f6 c1 03             	test   $0x3,%cl
  8009cf:	75 0a                	jne    8009db <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009d4:	89 c7                	mov    %eax,%edi
  8009d6:	fc                   	cld    
  8009d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d9:	eb 05                	jmp    8009e0 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009db:	89 c7                	mov    %eax,%edi
  8009dd:	fc                   	cld    
  8009de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e0:	8b 34 24             	mov    (%esp),%esi
  8009e3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8009e7:	89 ec                	mov    %ebp,%esp
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	89 04 24             	mov    %eax,(%esp)
  800a05:	e8 66 ff ff ff       	call   800970 <memmove>
}
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a18:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a20:	85 ff                	test   %edi,%edi
  800a22:	74 38                	je     800a5c <memcmp+0x50>
		if (*s1 != *s2)
  800a24:	0f b6 03             	movzbl (%ebx),%eax
  800a27:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2a:	83 ef 01             	sub    $0x1,%edi
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a32:	38 c8                	cmp    %cl,%al
  800a34:	74 1d                	je     800a53 <memcmp+0x47>
  800a36:	eb 11                	jmp    800a49 <memcmp+0x3d>
  800a38:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a3d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800a42:	83 c2 01             	add    $0x1,%edx
  800a45:	38 c8                	cmp    %cl,%al
  800a47:	74 0a                	je     800a53 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800a49:	0f b6 c0             	movzbl %al,%eax
  800a4c:	0f b6 c9             	movzbl %cl,%ecx
  800a4f:	29 c8                	sub    %ecx,%eax
  800a51:	eb 09                	jmp    800a5c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a53:	39 fa                	cmp    %edi,%edx
  800a55:	75 e1                	jne    800a38 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a67:	89 c2                	mov    %eax,%edx
  800a69:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a6c:	39 d0                	cmp    %edx,%eax
  800a6e:	73 15                	jae    800a85 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a74:	38 08                	cmp    %cl,(%eax)
  800a76:	75 06                	jne    800a7e <memfind+0x1d>
  800a78:	eb 0b                	jmp    800a85 <memfind+0x24>
  800a7a:	38 08                	cmp    %cl,(%eax)
  800a7c:	74 07                	je     800a85 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a7e:	83 c0 01             	add    $0x1,%eax
  800a81:	39 c2                	cmp    %eax,%edx
  800a83:	77 f5                	ja     800a7a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a93:	0f b6 02             	movzbl (%edx),%eax
  800a96:	3c 20                	cmp    $0x20,%al
  800a98:	74 04                	je     800a9e <strtol+0x17>
  800a9a:	3c 09                	cmp    $0x9,%al
  800a9c:	75 0e                	jne    800aac <strtol+0x25>
		s++;
  800a9e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa1:	0f b6 02             	movzbl (%edx),%eax
  800aa4:	3c 20                	cmp    $0x20,%al
  800aa6:	74 f6                	je     800a9e <strtol+0x17>
  800aa8:	3c 09                	cmp    $0x9,%al
  800aaa:	74 f2                	je     800a9e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aac:	3c 2b                	cmp    $0x2b,%al
  800aae:	75 0a                	jne    800aba <strtol+0x33>
		s++;
  800ab0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab8:	eb 10                	jmp    800aca <strtol+0x43>
  800aba:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800abf:	3c 2d                	cmp    $0x2d,%al
  800ac1:	75 07                	jne    800aca <strtol+0x43>
		s++, neg = 1;
  800ac3:	83 c2 01             	add    $0x1,%edx
  800ac6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aca:	85 db                	test   %ebx,%ebx
  800acc:	0f 94 c0             	sete   %al
  800acf:	74 05                	je     800ad6 <strtol+0x4f>
  800ad1:	83 fb 10             	cmp    $0x10,%ebx
  800ad4:	75 15                	jne    800aeb <strtol+0x64>
  800ad6:	80 3a 30             	cmpb   $0x30,(%edx)
  800ad9:	75 10                	jne    800aeb <strtol+0x64>
  800adb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800adf:	75 0a                	jne    800aeb <strtol+0x64>
		s += 2, base = 16;
  800ae1:	83 c2 02             	add    $0x2,%edx
  800ae4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae9:	eb 13                	jmp    800afe <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800aeb:	84 c0                	test   %al,%al
  800aed:	74 0f                	je     800afe <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aef:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af4:	80 3a 30             	cmpb   $0x30,(%edx)
  800af7:	75 05                	jne    800afe <strtol+0x77>
		s++, base = 8;
  800af9:	83 c2 01             	add    $0x1,%edx
  800afc:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800afe:	b8 00 00 00 00       	mov    $0x0,%eax
  800b03:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b05:	0f b6 0a             	movzbl (%edx),%ecx
  800b08:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b0b:	80 fb 09             	cmp    $0x9,%bl
  800b0e:	77 08                	ja     800b18 <strtol+0x91>
			dig = *s - '0';
  800b10:	0f be c9             	movsbl %cl,%ecx
  800b13:	83 e9 30             	sub    $0x30,%ecx
  800b16:	eb 1e                	jmp    800b36 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b18:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b1b:	80 fb 19             	cmp    $0x19,%bl
  800b1e:	77 08                	ja     800b28 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b20:	0f be c9             	movsbl %cl,%ecx
  800b23:	83 e9 57             	sub    $0x57,%ecx
  800b26:	eb 0e                	jmp    800b36 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b28:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b2b:	80 fb 19             	cmp    $0x19,%bl
  800b2e:	77 15                	ja     800b45 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800b30:	0f be c9             	movsbl %cl,%ecx
  800b33:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b36:	39 f1                	cmp    %esi,%ecx
  800b38:	7d 0f                	jge    800b49 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800b3a:	83 c2 01             	add    $0x1,%edx
  800b3d:	0f af c6             	imul   %esi,%eax
  800b40:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b43:	eb c0                	jmp    800b05 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b45:	89 c1                	mov    %eax,%ecx
  800b47:	eb 02                	jmp    800b4b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b49:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b4b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b4f:	74 05                	je     800b56 <strtol+0xcf>
		*endptr = (char *) s;
  800b51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b54:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b56:	89 ca                	mov    %ecx,%edx
  800b58:	f7 da                	neg    %edx
  800b5a:	85 ff                	test   %edi,%edi
  800b5c:	0f 45 c2             	cmovne %edx,%eax
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	83 ec 0c             	sub    $0xc,%esp
  800b6a:	89 1c 24             	mov    %ebx,(%esp)
  800b6d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b71:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b80:	89 c3                	mov    %eax,%ebx
  800b82:	89 c7                	mov    %eax,%edi
  800b84:	89 c6                	mov    %eax,%esi
  800b86:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b88:	8b 1c 24             	mov    (%esp),%ebx
  800b8b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b8f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b93:	89 ec                	mov    %ebp,%esp
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	89 1c 24             	mov    %ebx,(%esp)
  800ba0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ba4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bad:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb2:	89 d1                	mov    %edx,%ecx
  800bb4:	89 d3                	mov    %edx,%ebx
  800bb6:	89 d7                	mov    %edx,%edi
  800bb8:	89 d6                	mov    %edx,%esi
  800bba:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bbc:	8b 1c 24             	mov    (%esp),%ebx
  800bbf:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bc3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bc7:	89 ec                	mov    %ebp,%esp
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	83 ec 38             	sub    $0x38,%esp
  800bd1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bd4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bd7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdf:	b8 03 00 00 00       	mov    $0x3,%eax
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	89 cb                	mov    %ecx,%ebx
  800be9:	89 cf                	mov    %ecx,%edi
  800beb:	89 ce                	mov    %ecx,%esi
  800bed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	7e 28                	jle    800c1b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bfe:	00 
  800bff:	c7 44 24 08 34 11 80 	movl   $0x801134,0x8(%esp)
  800c06:	00 
  800c07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c0e:	00 
  800c0f:	c7 04 24 51 11 80 00 	movl   $0x801151,(%esp)
  800c16:	e8 41 00 00 00       	call   800c5c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c1e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c21:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c24:	89 ec                	mov    %ebp,%esp
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	83 ec 0c             	sub    $0xc,%esp
  800c2e:	89 1c 24             	mov    %ebx,(%esp)
  800c31:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c35:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c39:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c43:	89 d1                	mov    %edx,%ecx
  800c45:	89 d3                	mov    %edx,%ebx
  800c47:	89 d7                	mov    %edx,%edi
  800c49:	89 d6                	mov    %edx,%esi
  800c4b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c4d:	8b 1c 24             	mov    (%esp),%ebx
  800c50:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c54:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c58:	89 ec                	mov    %ebp,%esp
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800c64:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c67:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c6d:	e8 b6 ff ff ff       	call   800c28 <sys_getenvid>
  800c72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c75:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c80:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c88:	c7 04 24 60 11 80 00 	movl   $0x801160,(%esp)
  800c8f:	e8 c3 f4 ff ff       	call   800157 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c98:	8b 45 10             	mov    0x10(%ebp),%eax
  800c9b:	89 04 24             	mov    %eax,(%esp)
  800c9e:	e8 53 f4 ff ff       	call   8000f6 <vcprintf>
	cprintf("\n");
  800ca3:	c7 04 24 24 0f 80 00 	movl   $0x800f24,(%esp)
  800caa:	e8 a8 f4 ff ff       	call   800157 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800caf:	cc                   	int3   
  800cb0:	eb fd                	jmp    800caf <_panic+0x53>
	...

00800cc0 <__udivdi3>:
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	83 ec 10             	sub    $0x10,%esp
  800cc8:	8b 75 14             	mov    0x14(%ebp),%esi
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cd1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cd4:	85 f6                	test   %esi,%esi
  800cd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cd9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800cdf:	75 2f                	jne    800d10 <__udivdi3+0x50>
  800ce1:	39 f9                	cmp    %edi,%ecx
  800ce3:	77 5b                	ja     800d40 <__udivdi3+0x80>
  800ce5:	85 c9                	test   %ecx,%ecx
  800ce7:	75 0b                	jne    800cf4 <__udivdi3+0x34>
  800ce9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cee:	31 d2                	xor    %edx,%edx
  800cf0:	f7 f1                	div    %ecx
  800cf2:	89 c1                	mov    %eax,%ecx
  800cf4:	89 f8                	mov    %edi,%eax
  800cf6:	31 d2                	xor    %edx,%edx
  800cf8:	f7 f1                	div    %ecx
  800cfa:	89 c7                	mov    %eax,%edi
  800cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cff:	f7 f1                	div    %ecx
  800d01:	89 fa                	mov    %edi,%edx
  800d03:	83 c4 10             	add    $0x10,%esp
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    
  800d0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d10:	31 d2                	xor    %edx,%edx
  800d12:	31 c0                	xor    %eax,%eax
  800d14:	39 fe                	cmp    %edi,%esi
  800d16:	77 eb                	ja     800d03 <__udivdi3+0x43>
  800d18:	0f bd d6             	bsr    %esi,%edx
  800d1b:	83 f2 1f             	xor    $0x1f,%edx
  800d1e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800d21:	75 2d                	jne    800d50 <__udivdi3+0x90>
  800d23:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800d26:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  800d29:	76 06                	jbe    800d31 <__udivdi3+0x71>
  800d2b:	39 fe                	cmp    %edi,%esi
  800d2d:	89 c2                	mov    %eax,%edx
  800d2f:	73 d2                	jae    800d03 <__udivdi3+0x43>
  800d31:	31 d2                	xor    %edx,%edx
  800d33:	b8 01 00 00 00       	mov    $0x1,%eax
  800d38:	eb c9                	jmp    800d03 <__udivdi3+0x43>
  800d3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d40:	89 fa                	mov    %edi,%edx
  800d42:	f7 f1                	div    %ecx
  800d44:	31 d2                	xor    %edx,%edx
  800d46:	83 c4 10             	add    $0x10,%esp
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    
  800d4d:	8d 76 00             	lea    0x0(%esi),%esi
  800d50:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d54:	b8 20 00 00 00       	mov    $0x20,%eax
  800d59:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d5c:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800d5f:	d3 e6                	shl    %cl,%esi
  800d61:	89 c1                	mov    %eax,%ecx
  800d63:	d3 ea                	shr    %cl,%edx
  800d65:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d69:	09 f2                	or     %esi,%edx
  800d6b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  800d6e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d71:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d74:	d3 e2                	shl    %cl,%edx
  800d76:	89 c1                	mov    %eax,%ecx
  800d78:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800d7b:	89 fa                	mov    %edi,%edx
  800d7d:	d3 ea                	shr    %cl,%edx
  800d7f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d83:	d3 e7                	shl    %cl,%edi
  800d85:	89 c1                	mov    %eax,%ecx
  800d87:	d3 ee                	shr    %cl,%esi
  800d89:	09 fe                	or     %edi,%esi
  800d8b:	89 f0                	mov    %esi,%eax
  800d8d:	f7 75 e8             	divl   -0x18(%ebp)
  800d90:	89 d7                	mov    %edx,%edi
  800d92:	89 c6                	mov    %eax,%esi
  800d94:	f7 65 f0             	mull   -0x10(%ebp)
  800d97:	39 d7                	cmp    %edx,%edi
  800d99:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800d9c:	72 22                	jb     800dc0 <__udivdi3+0x100>
  800d9e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800da1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800da5:	d3 e2                	shl    %cl,%edx
  800da7:	39 c2                	cmp    %eax,%edx
  800da9:	73 05                	jae    800db0 <__udivdi3+0xf0>
  800dab:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  800dae:	74 10                	je     800dc0 <__udivdi3+0x100>
  800db0:	89 f0                	mov    %esi,%eax
  800db2:	31 d2                	xor    %edx,%edx
  800db4:	e9 4a ff ff ff       	jmp    800d03 <__udivdi3+0x43>
  800db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800dc3:	31 d2                	xor    %edx,%edx
  800dc5:	83 c4 10             	add    $0x10,%esp
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    
  800dcc:	00 00                	add    %al,(%eax)
	...

00800dd0 <__umoddi3>:
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	83 ec 20             	sub    $0x20,%esp
  800dd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dde:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800de1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de4:	85 ff                	test   %edi,%edi
  800de6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800de9:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800dec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800def:	89 f2                	mov    %esi,%edx
  800df1:	75 15                	jne    800e08 <__umoddi3+0x38>
  800df3:	39 f1                	cmp    %esi,%ecx
  800df5:	76 41                	jbe    800e38 <__umoddi3+0x68>
  800df7:	f7 f1                	div    %ecx
  800df9:	89 d0                	mov    %edx,%eax
  800dfb:	31 d2                	xor    %edx,%edx
  800dfd:	83 c4 20             	add    $0x20,%esp
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    
  800e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e08:	39 f7                	cmp    %esi,%edi
  800e0a:	77 4c                	ja     800e58 <__umoddi3+0x88>
  800e0c:	0f bd c7             	bsr    %edi,%eax
  800e0f:	83 f0 1f             	xor    $0x1f,%eax
  800e12:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e15:	75 51                	jne    800e68 <__umoddi3+0x98>
  800e17:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800e1a:	0f 87 e8 00 00 00    	ja     800f08 <__umoddi3+0x138>
  800e20:	89 f2                	mov    %esi,%edx
  800e22:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e25:	29 ce                	sub    %ecx,%esi
  800e27:	19 fa                	sbb    %edi,%edx
  800e29:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2f:	83 c4 20             	add    $0x20,%esp
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    
  800e36:	66 90                	xchg   %ax,%ax
  800e38:	85 c9                	test   %ecx,%ecx
  800e3a:	75 0b                	jne    800e47 <__umoddi3+0x77>
  800e3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e41:	31 d2                	xor    %edx,%edx
  800e43:	f7 f1                	div    %ecx
  800e45:	89 c1                	mov    %eax,%ecx
  800e47:	89 f0                	mov    %esi,%eax
  800e49:	31 d2                	xor    %edx,%edx
  800e4b:	f7 f1                	div    %ecx
  800e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e50:	eb a5                	jmp    800df7 <__umoddi3+0x27>
  800e52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e58:	89 f2                	mov    %esi,%edx
  800e5a:	83 c4 20             	add    $0x20,%esp
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    
  800e61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e68:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e6c:	89 f2                	mov    %esi,%edx
  800e6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e71:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  800e78:	29 45 f0             	sub    %eax,-0x10(%ebp)
  800e7b:	d3 e7                	shl    %cl,%edi
  800e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e80:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e84:	d3 e8                	shr    %cl,%eax
  800e86:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e8a:	09 f8                	or     %edi,%eax
  800e8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e92:	d3 e0                	shl    %cl,%eax
  800e94:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e98:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e9e:	d3 ea                	shr    %cl,%edx
  800ea0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800ea4:	d3 e6                	shl    %cl,%esi
  800ea6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800eaa:	d3 e8                	shr    %cl,%eax
  800eac:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800eb0:	09 f0                	or     %esi,%eax
  800eb2:	8b 75 e8             	mov    -0x18(%ebp),%esi
  800eb5:	f7 75 e4             	divl   -0x1c(%ebp)
  800eb8:	d3 e6                	shl    %cl,%esi
  800eba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800ebd:	89 d6                	mov    %edx,%esi
  800ebf:	f7 65 f4             	mull   -0xc(%ebp)
  800ec2:	89 d7                	mov    %edx,%edi
  800ec4:	89 c2                	mov    %eax,%edx
  800ec6:	39 fe                	cmp    %edi,%esi
  800ec8:	89 f9                	mov    %edi,%ecx
  800eca:	72 30                	jb     800efc <__umoddi3+0x12c>
  800ecc:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800ecf:	72 27                	jb     800ef8 <__umoddi3+0x128>
  800ed1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ed4:	29 d0                	sub    %edx,%eax
  800ed6:	19 ce                	sbb    %ecx,%esi
  800ed8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800edc:	89 f2                	mov    %esi,%edx
  800ede:	d3 e8                	shr    %cl,%eax
  800ee0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800ee4:	d3 e2                	shl    %cl,%edx
  800ee6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800eea:	09 d0                	or     %edx,%eax
  800eec:	89 f2                	mov    %esi,%edx
  800eee:	d3 ea                	shr    %cl,%edx
  800ef0:	83 c4 20             	add    $0x20,%esp
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    
  800ef7:	90                   	nop
  800ef8:	39 fe                	cmp    %edi,%esi
  800efa:	75 d5                	jne    800ed1 <__umoddi3+0x101>
  800efc:	89 f9                	mov    %edi,%ecx
  800efe:	89 c2                	mov    %eax,%edx
  800f00:	2b 55 f4             	sub    -0xc(%ebp),%edx
  800f03:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800f06:	eb c9                	jmp    800ed1 <__umoddi3+0x101>
  800f08:	39 f7                	cmp    %esi,%edi
  800f0a:	0f 82 10 ff ff ff    	jb     800e20 <__umoddi3+0x50>
  800f10:	e9 17 ff ff ff       	jmp    800e2c <__umoddi3+0x5c>
