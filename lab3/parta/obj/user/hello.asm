
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 08 0f 80 00 	movl   $0x800f08,(%esp)
  800041:	e8 09 01 00 00       	call   80014f <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 16 0f 80 00 	movl   $0x800f16,(%esp)
  800059:	e8 f1 00 00 00       	call   80014f <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	8b 45 08             	mov    0x8(%ebp),%eax
  800069:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800073:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 c0                	test   %eax,%eax
  800078:	7e 08                	jle    800082 <libmain+0x22>
		binaryname = argv[0];
  80007a:	8b 0a                	mov    (%edx),%ecx
  80007c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800082:	89 54 24 04          	mov    %edx,0x4(%esp)
  800086:	89 04 24             	mov    %eax,(%esp)
  800089:	e8 a6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008e:	e8 05 00 00 00       	call   800098 <exit>
}
  800093:	c9                   	leave  
  800094:	c3                   	ret    
  800095:	00 00                	add    %al,(%eax)
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 11 0b 00 00       	call   800bbb <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	53                   	push   %ebx
  8000b0:	83 ec 14             	sub    $0x14,%esp
  8000b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b6:	8b 03                	mov    (%ebx),%eax
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000bf:	83 c0 01             	add    $0x1,%eax
  8000c2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c9:	75 19                	jne    8000e4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000cb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000d2:	00 
  8000d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d6:	89 04 24             	mov    %eax,(%esp)
  8000d9:	e8 76 0a 00 00       	call   800b54 <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000e4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e8:	83 c4 14             	add    $0x14,%esp
  8000eb:	5b                   	pop    %ebx
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fe:	00 00 00 
	b.cnt = 0;
  800101:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800108:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800112:	8b 45 08             	mov    0x8(%ebp),%eax
  800115:	89 44 24 08          	mov    %eax,0x8(%esp)
  800119:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800123:	c7 04 24 ac 00 80 00 	movl   $0x8000ac,(%esp)
  80012a:	e8 e2 01 00 00       	call   800311 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800135:	89 44 24 04          	mov    %eax,0x4(%esp)
  800139:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013f:	89 04 24             	mov    %eax,(%esp)
  800142:	e8 0d 0a 00 00       	call   800b54 <sys_cputs>

	return b.cnt;
}
  800147:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800155:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015c:	8b 45 08             	mov    0x8(%ebp),%eax
  80015f:	89 04 24             	mov    %eax,(%esp)
  800162:	e8 87 ff ff ff       	call   8000ee <vcprintf>
	va_end(ap);

	return cnt;
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    
  800169:	00 00                	add    %al,(%eax)
  80016b:	00 00                	add    %al,(%eax)
  80016d:	00 00                	add    %al,(%eax)
	...

00800170 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 4c             	sub    $0x4c,%esp
  800179:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80017c:	89 d6                	mov    %edx,%esi
  80017e:	8b 45 08             	mov    0x8(%ebp),%eax
  800181:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800184:	8b 55 0c             	mov    0xc(%ebp),%edx
  800187:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80018a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80018d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800190:	b8 00 00 00 00       	mov    $0x0,%eax
  800195:	39 d0                	cmp    %edx,%eax
  800197:	72 11                	jb     8001aa <printnum+0x3a>
  800199:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80019c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  80019f:	76 09                	jbe    8001aa <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001a1:	83 eb 01             	sub    $0x1,%ebx
  8001a4:	85 db                	test   %ebx,%ebx
  8001a6:	7f 5d                	jg     800205 <printnum+0x95>
  8001a8:	eb 6c                	jmp    800216 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001aa:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001ae:	83 eb 01             	sub    $0x1,%ebx
  8001b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001bc:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001c0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001c7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8001ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d1:	00 
  8001d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001d5:	89 14 24             	mov    %edx,(%esp)
  8001d8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8001db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8001df:	e8 cc 0a 00 00       	call   800cb0 <__udivdi3>
  8001e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8001e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8001ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001ee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001f2:	89 04 24             	mov    %eax,(%esp)
  8001f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f9:	89 f2                	mov    %esi,%edx
  8001fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001fe:	e8 6d ff ff ff       	call   800170 <printnum>
  800203:	eb 11                	jmp    800216 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800205:	89 74 24 04          	mov    %esi,0x4(%esp)
  800209:	89 3c 24             	mov    %edi,(%esp)
  80020c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020f:	83 eb 01             	sub    $0x1,%ebx
  800212:	85 db                	test   %ebx,%ebx
  800214:	7f ef                	jg     800205 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80021a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80021e:	8b 45 10             	mov    0x10(%ebp),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022c:	00 
  80022d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800230:	89 14 24             	mov    %edx,(%esp)
  800233:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800236:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80023a:	e8 81 0b 00 00       	call   800dc0 <__umoddi3>
  80023f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800243:	0f be 80 37 0f 80 00 	movsbl 0x800f37(%eax),%eax
  80024a:	89 04 24             	mov    %eax,(%esp)
  80024d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800250:	83 c4 4c             	add    $0x4c,%esp
  800253:	5b                   	pop    %ebx
  800254:	5e                   	pop    %esi
  800255:	5f                   	pop    %edi
  800256:	5d                   	pop    %ebp
  800257:	c3                   	ret    

00800258 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025b:	83 fa 01             	cmp    $0x1,%edx
  80025e:	7e 0e                	jle    80026e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 08             	lea    0x8(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	8b 52 04             	mov    0x4(%edx),%edx
  80026c:	eb 22                	jmp    800290 <getuint+0x38>
	else if (lflag)
  80026e:	85 d2                	test   %edx,%edx
  800270:	74 10                	je     800282 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800272:	8b 10                	mov    (%eax),%edx
  800274:	8d 4a 04             	lea    0x4(%edx),%ecx
  800277:	89 08                	mov    %ecx,(%eax)
  800279:	8b 02                	mov    (%edx),%eax
  80027b:	ba 00 00 00 00       	mov    $0x0,%edx
  800280:	eb 0e                	jmp    800290 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800282:	8b 10                	mov    (%eax),%edx
  800284:	8d 4a 04             	lea    0x4(%edx),%ecx
  800287:	89 08                	mov    %ecx,(%eax)
  800289:	8b 02                	mov    (%edx),%eax
  80028b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    

00800292 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800295:	83 fa 01             	cmp    $0x1,%edx
  800298:	7e 0e                	jle    8002a8 <getint+0x16>
		return va_arg(*ap, long long);
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029f:	89 08                	mov    %ecx,(%eax)
  8002a1:	8b 02                	mov    (%edx),%eax
  8002a3:	8b 52 04             	mov    0x4(%edx),%edx
  8002a6:	eb 22                	jmp    8002ca <getint+0x38>
	else if (lflag)
  8002a8:	85 d2                	test   %edx,%edx
  8002aa:	74 10                	je     8002bc <getint+0x2a>
		return va_arg(*ap, long);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	89 c2                	mov    %eax,%edx
  8002b7:	c1 fa 1f             	sar    $0x1f,%edx
  8002ba:	eb 0e                	jmp    8002ca <getint+0x38>
	else
		return va_arg(*ap, int);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	89 c2                	mov    %eax,%edx
  8002c7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002db:	73 0a                	jae    8002e7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e0:	88 0a                	mov    %cl,(%edx)
  8002e2:	83 c2 01             	add    $0x1,%edx
  8002e5:	89 10                	mov    %edx,(%eax)
}
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ef:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800300:	89 44 24 04          	mov    %eax,0x4(%esp)
  800304:	8b 45 08             	mov    0x8(%ebp),%eax
  800307:	89 04 24             	mov    %eax,(%esp)
  80030a:	e8 02 00 00 00       	call   800311 <vprintfmt>
	va_end(ap);
}
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	57                   	push   %edi
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
  800317:	83 ec 4c             	sub    $0x4c,%esp
  80031a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031d:	eb 23                	jmp    800342 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80031f:	85 c0                	test   %eax,%eax
  800321:	75 12                	jne    800335 <vprintfmt+0x24>
				csa = 0x0700;
  800323:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80032a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80032d:	83 c4 4c             	add    $0x4c,%esp
  800330:	5b                   	pop    %ebx
  800331:	5e                   	pop    %esi
  800332:	5f                   	pop    %edi
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800335:	8b 55 0c             	mov    0xc(%ebp),%edx
  800338:	89 54 24 04          	mov    %edx,0x4(%esp)
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800342:	0f b6 07             	movzbl (%edi),%eax
  800345:	83 c7 01             	add    $0x1,%edi
  800348:	83 f8 25             	cmp    $0x25,%eax
  80034b:	75 d2                	jne    80031f <vprintfmt+0xe>
  80034d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800351:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800358:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80035d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800364:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800369:	be 00 00 00 00       	mov    $0x0,%esi
  80036e:	eb 14                	jmp    800384 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800370:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800374:	eb 0e                	jmp    800384 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800376:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80037a:	eb 08                	jmp    800384 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80037c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80037f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	0f b6 07             	movzbl (%edi),%eax
  800387:	0f b6 c8             	movzbl %al,%ecx
  80038a:	83 c7 01             	add    $0x1,%edi
  80038d:	83 e8 23             	sub    $0x23,%eax
  800390:	3c 55                	cmp    $0x55,%al
  800392:	0f 87 ed 02 00 00    	ja     800685 <vprintfmt+0x374>
  800398:	0f b6 c0             	movzbl %al,%eax
  80039b:	ff 24 85 c4 0f 80 00 	jmp    *0x800fc4(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  8003a5:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003a8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003ab:	83 f9 09             	cmp    $0x9,%ecx
  8003ae:	77 3c                	ja     8003ec <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003b3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8003b6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8003ba:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003bd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003c0:	83 f9 09             	cmp    $0x9,%ecx
  8003c3:	76 eb                	jbe    8003b0 <vprintfmt+0x9f>
  8003c5:	eb 25                	jmp    8003ec <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ca:	8d 48 04             	lea    0x4(%eax),%ecx
  8003cd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  8003d2:	eb 18                	jmp    8003ec <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  8003d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003db:	0f 48 c6             	cmovs  %esi,%eax
  8003de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e1:	eb a1                	jmp    800384 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  8003e3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003ea:	eb 98                	jmp    800384 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  8003ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f0:	79 92                	jns    800384 <vprintfmt+0x73>
  8003f2:	eb 88                	jmp    80037c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f4:	83 c2 01             	add    $0x1,%edx
  8003f7:	eb 8b                	jmp    800384 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 50 04             	lea    0x4(%eax),%edx
  8003ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 54 24 04          	mov    %edx,0x4(%esp)
  800409:	8b 00                	mov    (%eax),%eax
  80040b:	89 04 24             	mov    %eax,(%esp)
  80040e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800411:	e9 2c ff ff ff       	jmp    800342 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 50 04             	lea    0x4(%eax),%edx
  80041c:	89 55 14             	mov    %edx,0x14(%ebp)
  80041f:	8b 00                	mov    (%eax),%eax
  800421:	89 c2                	mov    %eax,%edx
  800423:	c1 fa 1f             	sar    $0x1f,%edx
  800426:	31 d0                	xor    %edx,%eax
  800428:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042a:	83 f8 06             	cmp    $0x6,%eax
  80042d:	7f 0b                	jg     80043a <vprintfmt+0x129>
  80042f:	8b 14 85 1c 11 80 00 	mov    0x80111c(,%eax,4),%edx
  800436:	85 d2                	test   %edx,%edx
  800438:	75 23                	jne    80045d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80043a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043e:	c7 44 24 08 4f 0f 80 	movl   $0x800f4f,0x8(%esp)
  800445:	00 
  800446:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800449:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044d:	8b 45 08             	mov    0x8(%ebp),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	e8 91 fe ff ff       	call   8002e9 <printfmt>
  800458:	e9 e5 fe ff ff       	jmp    800342 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80045d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800461:	c7 44 24 08 58 0f 80 	movl   $0x800f58,0x8(%esp)
  800468:	00 
  800469:	8b 55 0c             	mov    0xc(%ebp),%edx
  80046c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800470:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800473:	89 1c 24             	mov    %ebx,(%esp)
  800476:	e8 6e fe ff ff       	call   8002e9 <printfmt>
  80047b:	e9 c2 fe ff ff       	jmp    800342 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800480:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800483:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800486:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	8d 50 04             	lea    0x4(%eax),%edx
  80048f:	89 55 14             	mov    %edx,0x14(%ebp)
  800492:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800494:	85 f6                	test   %esi,%esi
  800496:	ba 48 0f 80 00       	mov    $0x800f48,%edx
  80049b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80049e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a2:	7e 06                	jle    8004aa <vprintfmt+0x199>
  8004a4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004a8:	75 13                	jne    8004bd <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004aa:	0f be 06             	movsbl (%esi),%eax
  8004ad:	83 c6 01             	add    $0x1,%esi
  8004b0:	85 c0                	test   %eax,%eax
  8004b2:	0f 85 a2 00 00 00    	jne    80055a <vprintfmt+0x249>
  8004b8:	e9 92 00 00 00       	jmp    80054f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c1:	89 34 24             	mov    %esi,(%esp)
  8004c4:	e8 82 02 00 00       	call   80074b <strnlen>
  8004c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004cc:	29 c2                	sub    %eax,%edx
  8004ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004d1:	85 d2                	test   %edx,%edx
  8004d3:	7e d5                	jle    8004aa <vprintfmt+0x199>
					putch(padc, putdat);
  8004d5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8004d9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004dc:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8004df:	89 d3                	mov    %edx,%ebx
  8004e1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004e4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004e7:	89 c6                	mov    %eax,%esi
  8004e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ed:	89 34 24             	mov    %esi,(%esp)
  8004f0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	83 eb 01             	sub    $0x1,%ebx
  8004f6:	85 db                	test   %ebx,%ebx
  8004f8:	7f ef                	jg     8004e9 <vprintfmt+0x1d8>
  8004fa:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004fd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800503:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80050a:	eb 9e                	jmp    8004aa <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800510:	74 1b                	je     80052d <vprintfmt+0x21c>
  800512:	8d 50 e0             	lea    -0x20(%eax),%edx
  800515:	83 fa 5e             	cmp    $0x5e,%edx
  800518:	76 13                	jbe    80052d <vprintfmt+0x21c>
					putch('?', putdat);
  80051a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80051d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800521:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800528:	ff 55 08             	call   *0x8(%ebp)
  80052b:	eb 0d                	jmp    80053a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80052d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800530:	89 54 24 04          	mov    %edx,0x4(%esp)
  800534:	89 04 24             	mov    %eax,(%esp)
  800537:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053a:	83 ef 01             	sub    $0x1,%edi
  80053d:	0f be 06             	movsbl (%esi),%eax
  800540:	85 c0                	test   %eax,%eax
  800542:	74 05                	je     800549 <vprintfmt+0x238>
  800544:	83 c6 01             	add    $0x1,%esi
  800547:	eb 17                	jmp    800560 <vprintfmt+0x24f>
  800549:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80054c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800553:	7f 1c                	jg     800571 <vprintfmt+0x260>
  800555:	e9 e8 fd ff ff       	jmp    800342 <vprintfmt+0x31>
  80055a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80055d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800560:	85 db                	test   %ebx,%ebx
  800562:	78 a8                	js     80050c <vprintfmt+0x1fb>
  800564:	83 eb 01             	sub    $0x1,%ebx
  800567:	79 a3                	jns    80050c <vprintfmt+0x1fb>
  800569:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80056c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80056f:	eb de                	jmp    80054f <vprintfmt+0x23e>
  800571:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800574:	8b 7d 08             	mov    0x8(%ebp),%edi
  800577:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800585:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800587:	83 eb 01             	sub    $0x1,%ebx
  80058a:	85 db                	test   %ebx,%ebx
  80058c:	7f ec                	jg     80057a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800591:	e9 ac fd ff ff       	jmp    800342 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800596:	8d 45 14             	lea    0x14(%ebp),%eax
  800599:	e8 f4 fc ff ff       	call   800292 <getint>
  80059e:	89 c3                	mov    %eax,%ebx
  8005a0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005a2:	85 d2                	test   %edx,%edx
  8005a4:	78 0a                	js     8005b0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ab:	e9 87 00 00 00       	jmp    800637 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005be:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005c1:	89 d8                	mov    %ebx,%eax
  8005c3:	89 f2                	mov    %esi,%edx
  8005c5:	f7 d8                	neg    %eax
  8005c7:	83 d2 00             	adc    $0x0,%edx
  8005ca:	f7 da                	neg    %edx
			}
			base = 10;
  8005cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005d1:	eb 64                	jmp    800637 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d6:	e8 7d fc ff ff       	call   800258 <getuint>
			base = 10;
  8005db:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005e0:	eb 55                	jmp    800637 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8005e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e5:	e8 6e fc ff ff       	call   800258 <getuint>
      base = 8;
  8005ea:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8005ef:	eb 46                	jmp    800637 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005ff:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800602:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800605:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800609:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800610:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8d 50 04             	lea    0x4(%eax),%edx
  800619:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80061c:	8b 00                	mov    (%eax),%eax
  80061e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800623:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800628:	eb 0d                	jmp    800637 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	e8 26 fc ff ff       	call   800258 <getuint>
			base = 16;
  800632:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800637:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80063b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80063f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800642:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800646:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80064a:	89 04 24             	mov    %eax,(%esp)
  80064d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800651:	8b 55 0c             	mov    0xc(%ebp),%edx
  800654:	8b 45 08             	mov    0x8(%ebp),%eax
  800657:	e8 14 fb ff ff       	call   800170 <printnum>
			break;
  80065c:	e9 e1 fc ff ff       	jmp    800342 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800661:	8b 45 0c             	mov    0xc(%ebp),%eax
  800664:	89 44 24 04          	mov    %eax,0x4(%esp)
  800668:	89 0c 24             	mov    %ecx,(%esp)
  80066b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80066e:	e9 cf fc ff ff       	jmp    800342 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800673:	8d 45 14             	lea    0x14(%ebp),%eax
  800676:	e8 17 fc ff ff       	call   800292 <getint>
			csa = num;
  80067b:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  800680:	e9 bd fc ff ff       	jmp    800342 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800685:	8b 55 0c             	mov    0xc(%ebp),%edx
  800688:	89 54 24 04          	mov    %edx,0x4(%esp)
  80068c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800693:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800696:	83 ef 01             	sub    $0x1,%edi
  800699:	eb 02                	jmp    80069d <vprintfmt+0x38c>
  80069b:	89 c7                	mov    %eax,%edi
  80069d:	8d 47 ff             	lea    -0x1(%edi),%eax
  8006a0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a4:	75 f5                	jne    80069b <vprintfmt+0x38a>
  8006a6:	e9 97 fc ff ff       	jmp    800342 <vprintfmt+0x31>

008006ab <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	83 ec 28             	sub    $0x28,%esp
  8006b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ba:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006be:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	74 30                	je     8006fc <vsnprintf+0x51>
  8006cc:	85 d2                	test   %edx,%edx
  8006ce:	7e 2c                	jle    8006fc <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e5:	c7 04 24 cc 02 80 00 	movl   $0x8002cc,(%esp)
  8006ec:	e8 20 fc ff ff       	call   800311 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fa:	eb 05                	jmp    800701 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800701:	c9                   	leave  
  800702:	c3                   	ret    

00800703 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800709:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800710:	8b 45 10             	mov    0x10(%ebp),%eax
  800713:	89 44 24 08          	mov    %eax,0x8(%esp)
  800717:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	89 04 24             	mov    %eax,(%esp)
  800724:	e8 82 ff ff ff       	call   8006ab <vsnprintf>
	va_end(ap);

	return rc;
}
  800729:	c9                   	leave  
  80072a:	c3                   	ret    
  80072b:	00 00                	add    %al,(%eax)
  80072d:	00 00                	add    %al,(%eax)
	...

00800730 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	b8 00 00 00 00       	mov    $0x0,%eax
  80073b:	80 3a 00             	cmpb   $0x0,(%edx)
  80073e:	74 09                	je     800749 <strlen+0x19>
		n++;
  800740:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800743:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800747:	75 f7                	jne    800740 <strlen+0x10>
		n++;
	return n;
}
  800749:	5d                   	pop    %ebp
  80074a:	c3                   	ret    

0080074b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800751:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800754:	b8 00 00 00 00       	mov    $0x0,%eax
  800759:	85 d2                	test   %edx,%edx
  80075b:	74 12                	je     80076f <strnlen+0x24>
  80075d:	80 39 00             	cmpb   $0x0,(%ecx)
  800760:	74 0d                	je     80076f <strnlen+0x24>
		n++;
  800762:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800765:	39 d0                	cmp    %edx,%eax
  800767:	74 06                	je     80076f <strnlen+0x24>
  800769:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80076d:	75 f3                	jne    800762 <strnlen+0x17>
		n++;
	return n;
}
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	53                   	push   %ebx
  800775:	8b 45 08             	mov    0x8(%ebp),%eax
  800778:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077b:	ba 00 00 00 00       	mov    $0x0,%edx
  800780:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800784:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800787:	83 c2 01             	add    $0x1,%edx
  80078a:	84 c9                	test   %cl,%cl
  80078c:	75 f2                	jne    800780 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80078e:	5b                   	pop    %ebx
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	53                   	push   %ebx
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079b:	89 1c 24             	mov    %ebx,(%esp)
  80079e:	e8 8d ff ff ff       	call   800730 <strlen>
	strcpy(dst + len, src);
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007aa:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007ad:	89 04 24             	mov    %eax,(%esp)
  8007b0:	e8 bc ff ff ff       	call   800771 <strcpy>
	return dst;
}
  8007b5:	89 d8                	mov    %ebx,%eax
  8007b7:	83 c4 08             	add    $0x8,%esp
  8007ba:	5b                   	pop    %ebx
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	56                   	push   %esi
  8007c1:	53                   	push   %ebx
  8007c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cb:	85 f6                	test   %esi,%esi
  8007cd:	74 18                	je     8007e7 <strncpy+0x2a>
  8007cf:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007d4:	0f b6 1a             	movzbl (%edx),%ebx
  8007d7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007da:	80 3a 01             	cmpb   $0x1,(%edx)
  8007dd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e0:	83 c1 01             	add    $0x1,%ecx
  8007e3:	39 ce                	cmp    %ecx,%esi
  8007e5:	77 ed                	ja     8007d4 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e7:	5b                   	pop    %ebx
  8007e8:	5e                   	pop    %esi
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	56                   	push   %esi
  8007ef:	53                   	push   %ebx
  8007f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f9:	89 f0                	mov    %esi,%eax
  8007fb:	85 c9                	test   %ecx,%ecx
  8007fd:	74 23                	je     800822 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  8007ff:	83 e9 01             	sub    $0x1,%ecx
  800802:	74 1b                	je     80081f <strlcpy+0x34>
  800804:	0f b6 1a             	movzbl (%edx),%ebx
  800807:	84 db                	test   %bl,%bl
  800809:	74 14                	je     80081f <strlcpy+0x34>
			*dst++ = *src++;
  80080b:	88 18                	mov    %bl,(%eax)
  80080d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800810:	83 e9 01             	sub    $0x1,%ecx
  800813:	74 0a                	je     80081f <strlcpy+0x34>
			*dst++ = *src++;
  800815:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800818:	0f b6 1a             	movzbl (%edx),%ebx
  80081b:	84 db                	test   %bl,%bl
  80081d:	75 ec                	jne    80080b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80081f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800822:	29 f0                	sub    %esi,%eax
}
  800824:	5b                   	pop    %ebx
  800825:	5e                   	pop    %esi
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800831:	0f b6 01             	movzbl (%ecx),%eax
  800834:	84 c0                	test   %al,%al
  800836:	74 15                	je     80084d <strcmp+0x25>
  800838:	3a 02                	cmp    (%edx),%al
  80083a:	75 11                	jne    80084d <strcmp+0x25>
		p++, q++;
  80083c:	83 c1 01             	add    $0x1,%ecx
  80083f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800842:	0f b6 01             	movzbl (%ecx),%eax
  800845:	84 c0                	test   %al,%al
  800847:	74 04                	je     80084d <strcmp+0x25>
  800849:	3a 02                	cmp    (%edx),%al
  80084b:	74 ef                	je     80083c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084d:	0f b6 c0             	movzbl %al,%eax
  800850:	0f b6 12             	movzbl (%edx),%edx
  800853:	29 d0                	sub    %edx,%eax
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800861:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800864:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800869:	85 d2                	test   %edx,%edx
  80086b:	74 28                	je     800895 <strncmp+0x3e>
  80086d:	0f b6 01             	movzbl (%ecx),%eax
  800870:	84 c0                	test   %al,%al
  800872:	74 24                	je     800898 <strncmp+0x41>
  800874:	3a 03                	cmp    (%ebx),%al
  800876:	75 20                	jne    800898 <strncmp+0x41>
  800878:	83 ea 01             	sub    $0x1,%edx
  80087b:	74 13                	je     800890 <strncmp+0x39>
		n--, p++, q++;
  80087d:	83 c1 01             	add    $0x1,%ecx
  800880:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800883:	0f b6 01             	movzbl (%ecx),%eax
  800886:	84 c0                	test   %al,%al
  800888:	74 0e                	je     800898 <strncmp+0x41>
  80088a:	3a 03                	cmp    (%ebx),%al
  80088c:	74 ea                	je     800878 <strncmp+0x21>
  80088e:	eb 08                	jmp    800898 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800890:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800895:	5b                   	pop    %ebx
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800898:	0f b6 01             	movzbl (%ecx),%eax
  80089b:	0f b6 13             	movzbl (%ebx),%edx
  80089e:	29 d0                	sub    %edx,%eax
  8008a0:	eb f3                	jmp    800895 <strncmp+0x3e>

008008a2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ac:	0f b6 10             	movzbl (%eax),%edx
  8008af:	84 d2                	test   %dl,%dl
  8008b1:	74 20                	je     8008d3 <strchr+0x31>
		if (*s == c)
  8008b3:	38 ca                	cmp    %cl,%dl
  8008b5:	75 0b                	jne    8008c2 <strchr+0x20>
  8008b7:	eb 1f                	jmp    8008d8 <strchr+0x36>
  8008b9:	38 ca                	cmp    %cl,%dl
  8008bb:	90                   	nop
  8008bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8008c0:	74 16                	je     8008d8 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c2:	83 c0 01             	add    $0x1,%eax
  8008c5:	0f b6 10             	movzbl (%eax),%edx
  8008c8:	84 d2                	test   %dl,%dl
  8008ca:	75 ed                	jne    8008b9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d1:	eb 05                	jmp    8008d8 <strchr+0x36>
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e4:	0f b6 10             	movzbl (%eax),%edx
  8008e7:	84 d2                	test   %dl,%dl
  8008e9:	74 14                	je     8008ff <strfind+0x25>
		if (*s == c)
  8008eb:	38 ca                	cmp    %cl,%dl
  8008ed:	75 06                	jne    8008f5 <strfind+0x1b>
  8008ef:	eb 0e                	jmp    8008ff <strfind+0x25>
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	74 0a                	je     8008ff <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	0f b6 10             	movzbl (%eax),%edx
  8008fb:	84 d2                	test   %dl,%dl
  8008fd:	75 f2                	jne    8008f1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	83 ec 0c             	sub    $0xc,%esp
  800907:	89 1c 24             	mov    %ebx,(%esp)
  80090a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80090e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800912:	8b 7d 08             	mov    0x8(%ebp),%edi
  800915:	8b 45 0c             	mov    0xc(%ebp),%eax
  800918:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091b:	85 c9                	test   %ecx,%ecx
  80091d:	74 30                	je     80094f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800925:	75 25                	jne    80094c <memset+0x4b>
  800927:	f6 c1 03             	test   $0x3,%cl
  80092a:	75 20                	jne    80094c <memset+0x4b>
		c &= 0xFF;
  80092c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092f:	89 d3                	mov    %edx,%ebx
  800931:	c1 e3 08             	shl    $0x8,%ebx
  800934:	89 d6                	mov    %edx,%esi
  800936:	c1 e6 18             	shl    $0x18,%esi
  800939:	89 d0                	mov    %edx,%eax
  80093b:	c1 e0 10             	shl    $0x10,%eax
  80093e:	09 f0                	or     %esi,%eax
  800940:	09 d0                	or     %edx,%eax
  800942:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800944:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800947:	fc                   	cld    
  800948:	f3 ab                	rep stos %eax,%es:(%edi)
  80094a:	eb 03                	jmp    80094f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094c:	fc                   	cld    
  80094d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094f:	89 f8                	mov    %edi,%eax
  800951:	8b 1c 24             	mov    (%esp),%ebx
  800954:	8b 74 24 04          	mov    0x4(%esp),%esi
  800958:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80095c:	89 ec                	mov    %ebp,%esp
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	83 ec 08             	sub    $0x8,%esp
  800966:	89 34 24             	mov    %esi,(%esp)
  800969:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 75 0c             	mov    0xc(%ebp),%esi
  800973:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800976:	39 c6                	cmp    %eax,%esi
  800978:	73 36                	jae    8009b0 <memmove+0x50>
  80097a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097d:	39 d0                	cmp    %edx,%eax
  80097f:	73 2f                	jae    8009b0 <memmove+0x50>
		s += n;
		d += n;
  800981:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	f6 c2 03             	test   $0x3,%dl
  800987:	75 1b                	jne    8009a4 <memmove+0x44>
  800989:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098f:	75 13                	jne    8009a4 <memmove+0x44>
  800991:	f6 c1 03             	test   $0x3,%cl
  800994:	75 0e                	jne    8009a4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800996:	83 ef 04             	sub    $0x4,%edi
  800999:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80099f:	fd                   	std    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb 09                	jmp    8009ad <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a4:	83 ef 01             	sub    $0x1,%edi
  8009a7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009aa:	fd                   	std    
  8009ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ad:	fc                   	cld    
  8009ae:	eb 20                	jmp    8009d0 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b6:	75 13                	jne    8009cb <memmove+0x6b>
  8009b8:	a8 03                	test   $0x3,%al
  8009ba:	75 0f                	jne    8009cb <memmove+0x6b>
  8009bc:	f6 c1 03             	test   $0x3,%cl
  8009bf:	75 0a                	jne    8009cb <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009c4:	89 c7                	mov    %eax,%edi
  8009c6:	fc                   	cld    
  8009c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c9:	eb 05                	jmp    8009d0 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009cb:	89 c7                	mov    %eax,%edi
  8009cd:	fc                   	cld    
  8009ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d0:	8b 34 24             	mov    (%esp),%esi
  8009d3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8009d7:	89 ec                	mov    %ebp,%esp
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	89 04 24             	mov    %eax,(%esp)
  8009f5:	e8 66 ff ff ff       	call   800960 <memmove>
}
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    

008009fc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a08:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a10:	85 ff                	test   %edi,%edi
  800a12:	74 38                	je     800a4c <memcmp+0x50>
		if (*s1 != *s2)
  800a14:	0f b6 03             	movzbl (%ebx),%eax
  800a17:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1a:	83 ef 01             	sub    $0x1,%edi
  800a1d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a22:	38 c8                	cmp    %cl,%al
  800a24:	74 1d                	je     800a43 <memcmp+0x47>
  800a26:	eb 11                	jmp    800a39 <memcmp+0x3d>
  800a28:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a2d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800a32:	83 c2 01             	add    $0x1,%edx
  800a35:	38 c8                	cmp    %cl,%al
  800a37:	74 0a                	je     800a43 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800a39:	0f b6 c0             	movzbl %al,%eax
  800a3c:	0f b6 c9             	movzbl %cl,%ecx
  800a3f:	29 c8                	sub    %ecx,%eax
  800a41:	eb 09                	jmp    800a4c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a43:	39 fa                	cmp    %edi,%edx
  800a45:	75 e1                	jne    800a28 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5f                   	pop    %edi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a57:	89 c2                	mov    %eax,%edx
  800a59:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5c:	39 d0                	cmp    %edx,%eax
  800a5e:	73 15                	jae    800a75 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a64:	38 08                	cmp    %cl,(%eax)
  800a66:	75 06                	jne    800a6e <memfind+0x1d>
  800a68:	eb 0b                	jmp    800a75 <memfind+0x24>
  800a6a:	38 08                	cmp    %cl,(%eax)
  800a6c:	74 07                	je     800a75 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6e:	83 c0 01             	add    $0x1,%eax
  800a71:	39 c2                	cmp    %eax,%edx
  800a73:	77 f5                	ja     800a6a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a83:	0f b6 02             	movzbl (%edx),%eax
  800a86:	3c 20                	cmp    $0x20,%al
  800a88:	74 04                	je     800a8e <strtol+0x17>
  800a8a:	3c 09                	cmp    $0x9,%al
  800a8c:	75 0e                	jne    800a9c <strtol+0x25>
		s++;
  800a8e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a91:	0f b6 02             	movzbl (%edx),%eax
  800a94:	3c 20                	cmp    $0x20,%al
  800a96:	74 f6                	je     800a8e <strtol+0x17>
  800a98:	3c 09                	cmp    $0x9,%al
  800a9a:	74 f2                	je     800a8e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a9c:	3c 2b                	cmp    $0x2b,%al
  800a9e:	75 0a                	jne    800aaa <strtol+0x33>
		s++;
  800aa0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa3:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa8:	eb 10                	jmp    800aba <strtol+0x43>
  800aaa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aaf:	3c 2d                	cmp    $0x2d,%al
  800ab1:	75 07                	jne    800aba <strtol+0x43>
		s++, neg = 1;
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aba:	85 db                	test   %ebx,%ebx
  800abc:	0f 94 c0             	sete   %al
  800abf:	74 05                	je     800ac6 <strtol+0x4f>
  800ac1:	83 fb 10             	cmp    $0x10,%ebx
  800ac4:	75 15                	jne    800adb <strtol+0x64>
  800ac6:	80 3a 30             	cmpb   $0x30,(%edx)
  800ac9:	75 10                	jne    800adb <strtol+0x64>
  800acb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800acf:	75 0a                	jne    800adb <strtol+0x64>
		s += 2, base = 16;
  800ad1:	83 c2 02             	add    $0x2,%edx
  800ad4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad9:	eb 13                	jmp    800aee <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800adb:	84 c0                	test   %al,%al
  800add:	74 0f                	je     800aee <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800adf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ae7:	75 05                	jne    800aee <strtol+0x77>
		s++, base = 8;
  800ae9:	83 c2 01             	add    $0x1,%edx
  800aec:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
  800af3:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af5:	0f b6 0a             	movzbl (%edx),%ecx
  800af8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800afb:	80 fb 09             	cmp    $0x9,%bl
  800afe:	77 08                	ja     800b08 <strtol+0x91>
			dig = *s - '0';
  800b00:	0f be c9             	movsbl %cl,%ecx
  800b03:	83 e9 30             	sub    $0x30,%ecx
  800b06:	eb 1e                	jmp    800b26 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b08:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b0b:	80 fb 19             	cmp    $0x19,%bl
  800b0e:	77 08                	ja     800b18 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b10:	0f be c9             	movsbl %cl,%ecx
  800b13:	83 e9 57             	sub    $0x57,%ecx
  800b16:	eb 0e                	jmp    800b26 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b18:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b1b:	80 fb 19             	cmp    $0x19,%bl
  800b1e:	77 15                	ja     800b35 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800b20:	0f be c9             	movsbl %cl,%ecx
  800b23:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b26:	39 f1                	cmp    %esi,%ecx
  800b28:	7d 0f                	jge    800b39 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800b2a:	83 c2 01             	add    $0x1,%edx
  800b2d:	0f af c6             	imul   %esi,%eax
  800b30:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b33:	eb c0                	jmp    800af5 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b35:	89 c1                	mov    %eax,%ecx
  800b37:	eb 02                	jmp    800b3b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b39:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b3b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3f:	74 05                	je     800b46 <strtol+0xcf>
		*endptr = (char *) s;
  800b41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b44:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b46:	89 ca                	mov    %ecx,%edx
  800b48:	f7 da                	neg    %edx
  800b4a:	85 ff                	test   %edi,%edi
  800b4c:	0f 45 c2             	cmovne %edx,%eax
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	83 ec 0c             	sub    $0xc,%esp
  800b5a:	89 1c 24             	mov    %ebx,(%esp)
  800b5d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b61:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	89 c3                	mov    %eax,%ebx
  800b72:	89 c7                	mov    %eax,%edi
  800b74:	89 c6                	mov    %eax,%esi
  800b76:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b78:	8b 1c 24             	mov    (%esp),%ebx
  800b7b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b7f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b83:	89 ec                	mov    %ebp,%esp
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	89 1c 24             	mov    %ebx,(%esp)
  800b90:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b94:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b98:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba2:	89 d1                	mov    %edx,%ecx
  800ba4:	89 d3                	mov    %edx,%ebx
  800ba6:	89 d7                	mov    %edx,%edi
  800ba8:	89 d6                	mov    %edx,%esi
  800baa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bac:	8b 1c 24             	mov    (%esp),%ebx
  800baf:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bb3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bb7:	89 ec                	mov    %ebp,%esp
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	83 ec 38             	sub    $0x38,%esp
  800bc1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bc4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bc7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bcf:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	89 cb                	mov    %ecx,%ebx
  800bd9:	89 cf                	mov    %ecx,%edi
  800bdb:	89 ce                	mov    %ecx,%esi
  800bdd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	7e 28                	jle    800c0b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bee:	00 
  800bef:	c7 44 24 08 38 11 80 	movl   $0x801138,0x8(%esp)
  800bf6:	00 
  800bf7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bfe:	00 
  800bff:	c7 04 24 55 11 80 00 	movl   $0x801155,(%esp)
  800c06:	e8 41 00 00 00       	call   800c4c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c0b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c0e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c11:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c14:	89 ec                	mov    %ebp,%esp
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	83 ec 0c             	sub    $0xc,%esp
  800c1e:	89 1c 24             	mov    %ebx,(%esp)
  800c21:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c25:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c33:	89 d1                	mov    %edx,%ecx
  800c35:	89 d3                	mov    %edx,%ebx
  800c37:	89 d7                	mov    %edx,%edi
  800c39:	89 d6                	mov    %edx,%esi
  800c3b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3d:	8b 1c 24             	mov    (%esp),%ebx
  800c40:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c44:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c48:	89 ec                	mov    %ebp,%esp
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800c54:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c57:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c5d:	e8 b6 ff ff ff       	call   800c18 <sys_getenvid>
  800c62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c65:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c70:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c78:	c7 04 24 64 11 80 00 	movl   $0x801164,(%esp)
  800c7f:	e8 cb f4 ff ff       	call   80014f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c84:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c88:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8b:	89 04 24             	mov    %eax,(%esp)
  800c8e:	e8 5b f4 ff ff       	call   8000ee <vcprintf>
	cprintf("\n");
  800c93:	c7 04 24 14 0f 80 00 	movl   $0x800f14,(%esp)
  800c9a:	e8 b0 f4 ff ff       	call   80014f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c9f:	cc                   	int3   
  800ca0:	eb fd                	jmp    800c9f <_panic+0x53>
	...

00800cb0 <__udivdi3>:
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	83 ec 10             	sub    $0x10,%esp
  800cb8:	8b 75 14             	mov    0x14(%ebp),%esi
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cc1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cc4:	85 f6                	test   %esi,%esi
  800cc6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cc9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ccc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ccf:	75 2f                	jne    800d00 <__udivdi3+0x50>
  800cd1:	39 f9                	cmp    %edi,%ecx
  800cd3:	77 5b                	ja     800d30 <__udivdi3+0x80>
  800cd5:	85 c9                	test   %ecx,%ecx
  800cd7:	75 0b                	jne    800ce4 <__udivdi3+0x34>
  800cd9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cde:	31 d2                	xor    %edx,%edx
  800ce0:	f7 f1                	div    %ecx
  800ce2:	89 c1                	mov    %eax,%ecx
  800ce4:	89 f8                	mov    %edi,%eax
  800ce6:	31 d2                	xor    %edx,%edx
  800ce8:	f7 f1                	div    %ecx
  800cea:	89 c7                	mov    %eax,%edi
  800cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cef:	f7 f1                	div    %ecx
  800cf1:	89 fa                	mov    %edi,%edx
  800cf3:	83 c4 10             	add    $0x10,%esp
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    
  800cfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d00:	31 d2                	xor    %edx,%edx
  800d02:	31 c0                	xor    %eax,%eax
  800d04:	39 fe                	cmp    %edi,%esi
  800d06:	77 eb                	ja     800cf3 <__udivdi3+0x43>
  800d08:	0f bd d6             	bsr    %esi,%edx
  800d0b:	83 f2 1f             	xor    $0x1f,%edx
  800d0e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800d11:	75 2d                	jne    800d40 <__udivdi3+0x90>
  800d13:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800d16:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  800d19:	76 06                	jbe    800d21 <__udivdi3+0x71>
  800d1b:	39 fe                	cmp    %edi,%esi
  800d1d:	89 c2                	mov    %eax,%edx
  800d1f:	73 d2                	jae    800cf3 <__udivdi3+0x43>
  800d21:	31 d2                	xor    %edx,%edx
  800d23:	b8 01 00 00 00       	mov    $0x1,%eax
  800d28:	eb c9                	jmp    800cf3 <__udivdi3+0x43>
  800d2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d30:	89 fa                	mov    %edi,%edx
  800d32:	f7 f1                	div    %ecx
  800d34:	31 d2                	xor    %edx,%edx
  800d36:	83 c4 10             	add    $0x10,%esp
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    
  800d3d:	8d 76 00             	lea    0x0(%esi),%esi
  800d40:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d44:	b8 20 00 00 00       	mov    $0x20,%eax
  800d49:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d4c:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800d4f:	d3 e6                	shl    %cl,%esi
  800d51:	89 c1                	mov    %eax,%ecx
  800d53:	d3 ea                	shr    %cl,%edx
  800d55:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d59:	09 f2                	or     %esi,%edx
  800d5b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  800d5e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d61:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d64:	d3 e2                	shl    %cl,%edx
  800d66:	89 c1                	mov    %eax,%ecx
  800d68:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800d6b:	89 fa                	mov    %edi,%edx
  800d6d:	d3 ea                	shr    %cl,%edx
  800d6f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d73:	d3 e7                	shl    %cl,%edi
  800d75:	89 c1                	mov    %eax,%ecx
  800d77:	d3 ee                	shr    %cl,%esi
  800d79:	09 fe                	or     %edi,%esi
  800d7b:	89 f0                	mov    %esi,%eax
  800d7d:	f7 75 e8             	divl   -0x18(%ebp)
  800d80:	89 d7                	mov    %edx,%edi
  800d82:	89 c6                	mov    %eax,%esi
  800d84:	f7 65 f0             	mull   -0x10(%ebp)
  800d87:	39 d7                	cmp    %edx,%edi
  800d89:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800d8c:	72 22                	jb     800db0 <__udivdi3+0x100>
  800d8e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d91:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d95:	d3 e2                	shl    %cl,%edx
  800d97:	39 c2                	cmp    %eax,%edx
  800d99:	73 05                	jae    800da0 <__udivdi3+0xf0>
  800d9b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  800d9e:	74 10                	je     800db0 <__udivdi3+0x100>
  800da0:	89 f0                	mov    %esi,%eax
  800da2:	31 d2                	xor    %edx,%edx
  800da4:	e9 4a ff ff ff       	jmp    800cf3 <__udivdi3+0x43>
  800da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800db3:	31 d2                	xor    %edx,%edx
  800db5:	83 c4 10             	add    $0x10,%esp
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    
  800dbc:	00 00                	add    %al,(%eax)
	...

00800dc0 <__umoddi3>:
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	83 ec 20             	sub    $0x20,%esp
  800dc8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800dd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd4:	85 ff                	test   %edi,%edi
  800dd6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800dd9:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ddc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ddf:	89 f2                	mov    %esi,%edx
  800de1:	75 15                	jne    800df8 <__umoddi3+0x38>
  800de3:	39 f1                	cmp    %esi,%ecx
  800de5:	76 41                	jbe    800e28 <__umoddi3+0x68>
  800de7:	f7 f1                	div    %ecx
  800de9:	89 d0                	mov    %edx,%eax
  800deb:	31 d2                	xor    %edx,%edx
  800ded:	83 c4 20             	add    $0x20,%esp
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    
  800df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df8:	39 f7                	cmp    %esi,%edi
  800dfa:	77 4c                	ja     800e48 <__umoddi3+0x88>
  800dfc:	0f bd c7             	bsr    %edi,%eax
  800dff:	83 f0 1f             	xor    $0x1f,%eax
  800e02:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e05:	75 51                	jne    800e58 <__umoddi3+0x98>
  800e07:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800e0a:	0f 87 e8 00 00 00    	ja     800ef8 <__umoddi3+0x138>
  800e10:	89 f2                	mov    %esi,%edx
  800e12:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e15:	29 ce                	sub    %ecx,%esi
  800e17:	19 fa                	sbb    %edi,%edx
  800e19:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1f:	83 c4 20             	add    $0x20,%esp
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    
  800e26:	66 90                	xchg   %ax,%ax
  800e28:	85 c9                	test   %ecx,%ecx
  800e2a:	75 0b                	jne    800e37 <__umoddi3+0x77>
  800e2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e31:	31 d2                	xor    %edx,%edx
  800e33:	f7 f1                	div    %ecx
  800e35:	89 c1                	mov    %eax,%ecx
  800e37:	89 f0                	mov    %esi,%eax
  800e39:	31 d2                	xor    %edx,%edx
  800e3b:	f7 f1                	div    %ecx
  800e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e40:	eb a5                	jmp    800de7 <__umoddi3+0x27>
  800e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e48:	89 f2                	mov    %esi,%edx
  800e4a:	83 c4 20             	add    $0x20,%esp
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    
  800e51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e58:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e5c:	89 f2                	mov    %esi,%edx
  800e5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e61:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  800e68:	29 45 f0             	sub    %eax,-0x10(%ebp)
  800e6b:	d3 e7                	shl    %cl,%edi
  800e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e70:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e74:	d3 e8                	shr    %cl,%eax
  800e76:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e7a:	09 f8                	or     %edi,%eax
  800e7c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e82:	d3 e0                	shl    %cl,%eax
  800e84:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e88:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e8e:	d3 ea                	shr    %cl,%edx
  800e90:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e94:	d3 e6                	shl    %cl,%esi
  800e96:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e9a:	d3 e8                	shr    %cl,%eax
  800e9c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800ea0:	09 f0                	or     %esi,%eax
  800ea2:	8b 75 e8             	mov    -0x18(%ebp),%esi
  800ea5:	f7 75 e4             	divl   -0x1c(%ebp)
  800ea8:	d3 e6                	shl    %cl,%esi
  800eaa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800ead:	89 d6                	mov    %edx,%esi
  800eaf:	f7 65 f4             	mull   -0xc(%ebp)
  800eb2:	89 d7                	mov    %edx,%edi
  800eb4:	89 c2                	mov    %eax,%edx
  800eb6:	39 fe                	cmp    %edi,%esi
  800eb8:	89 f9                	mov    %edi,%ecx
  800eba:	72 30                	jb     800eec <__umoddi3+0x12c>
  800ebc:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800ebf:	72 27                	jb     800ee8 <__umoddi3+0x128>
  800ec1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ec4:	29 d0                	sub    %edx,%eax
  800ec6:	19 ce                	sbb    %ecx,%esi
  800ec8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800ecc:	89 f2                	mov    %esi,%edx
  800ece:	d3 e8                	shr    %cl,%eax
  800ed0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800ed4:	d3 e2                	shl    %cl,%edx
  800ed6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800eda:	09 d0                	or     %edx,%eax
  800edc:	89 f2                	mov    %esi,%edx
  800ede:	d3 ea                	shr    %cl,%edx
  800ee0:	83 c4 20             	add    $0x20,%esp
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    
  800ee7:	90                   	nop
  800ee8:	39 fe                	cmp    %edi,%esi
  800eea:	75 d5                	jne    800ec1 <__umoddi3+0x101>
  800eec:	89 f9                	mov    %edi,%ecx
  800eee:	89 c2                	mov    %eax,%edx
  800ef0:	2b 55 f4             	sub    -0xc(%ebp),%edx
  800ef3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800ef6:	eb c9                	jmp    800ec1 <__umoddi3+0x101>
  800ef8:	39 f7                	cmp    %esi,%edi
  800efa:	0f 82 10 ff ff ff    	jb     800e10 <__umoddi3+0x50>
  800f00:	e9 17 ff ff ff       	jmp    800e1c <__umoddi3+0x5c>
