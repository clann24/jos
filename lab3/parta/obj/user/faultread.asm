
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	a1 00 00 00 00       	mov    0x0,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 f8 0e 80 00 	movl   $0x800ef8,(%esp)
  80004a:	e8 f4 00 00 00       	call   800143 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	8b 45 08             	mov    0x8(%ebp),%eax
  80005d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800060:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800067:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 c0                	test   %eax,%eax
  80006c:	7e 08                	jle    800076 <libmain+0x22>
		binaryname = argv[0];
  80006e:	8b 0a                	mov    (%edx),%ecx
  800070:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800076:	89 54 24 04          	mov    %edx,0x4(%esp)
  80007a:	89 04 24             	mov    %eax,(%esp)
  80007d:	e8 b2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800082:	e8 05 00 00 00       	call   80008c <exit>
}
  800087:	c9                   	leave  
  800088:	c3                   	ret    
  800089:	00 00                	add    %al,(%eax)
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 0d 0b 00 00       	call   800bab <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	53                   	push   %ebx
  8000a4:	83 ec 14             	sub    $0x14,%esp
  8000a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000aa:	8b 03                	mov    (%ebx),%eax
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000b3:	83 c0 01             	add    $0x1,%eax
  8000b6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000bd:	75 19                	jne    8000d8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000bf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000c6:	00 
  8000c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ca:	89 04 24             	mov    %eax,(%esp)
  8000cd:	e8 72 0a 00 00       	call   800b44 <sys_cputs>
		b->idx = 0;
  8000d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000dc:	83 c4 14             	add    $0x14,%esp
  8000df:	5b                   	pop    %ebx
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000f2:	00 00 00 
	b.cnt = 0;
  8000f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800102:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800106:	8b 45 08             	mov    0x8(%ebp),%eax
  800109:	89 44 24 08          	mov    %eax,0x8(%esp)
  80010d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800113:	89 44 24 04          	mov    %eax,0x4(%esp)
  800117:	c7 04 24 a0 00 80 00 	movl   $0x8000a0,(%esp)
  80011e:	e8 de 01 00 00       	call   800301 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800123:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800129:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800133:	89 04 24             	mov    %eax,(%esp)
  800136:	e8 09 0a 00 00       	call   800b44 <sys_cputs>

	return b.cnt;
}
  80013b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800149:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800150:	8b 45 08             	mov    0x8(%ebp),%eax
  800153:	89 04 24             	mov    %eax,(%esp)
  800156:	e8 87 ff ff ff       	call   8000e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    
  80015d:	00 00                	add    %al,(%eax)
	...

00800160 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 4c             	sub    $0x4c,%esp
  800169:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80016c:	89 d6                	mov    %edx,%esi
  80016e:	8b 45 08             	mov    0x8(%ebp),%eax
  800171:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800174:	8b 55 0c             	mov    0xc(%ebp),%edx
  800177:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80017a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80017d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800180:	b8 00 00 00 00       	mov    $0x0,%eax
  800185:	39 d0                	cmp    %edx,%eax
  800187:	72 11                	jb     80019a <printnum+0x3a>
  800189:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80018c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  80018f:	76 09                	jbe    80019a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800191:	83 eb 01             	sub    $0x1,%ebx
  800194:	85 db                	test   %ebx,%ebx
  800196:	7f 5d                	jg     8001f5 <printnum+0x95>
  800198:	eb 6c                	jmp    800206 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80019e:	83 eb 01             	sub    $0x1,%ebx
  8001a1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ac:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001b0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001b7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8001ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001c1:	00 
  8001c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001c5:	89 14 24             	mov    %edx,(%esp)
  8001c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8001cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8001cf:	e8 cc 0a 00 00       	call   800ca0 <__udivdi3>
  8001d4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8001d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8001da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001de:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001e2:	89 04 24             	mov    %eax,(%esp)
  8001e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e9:	89 f2                	mov    %esi,%edx
  8001eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ee:	e8 6d ff ff ff       	call   800160 <printnum>
  8001f3:	eb 11                	jmp    800206 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f9:	89 3c 24             	mov    %edi,(%esp)
  8001fc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	85 db                	test   %ebx,%ebx
  800204:	7f ef                	jg     8001f5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800206:	89 74 24 04          	mov    %esi,0x4(%esp)
  80020a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80020e:	8b 45 10             	mov    0x10(%ebp),%eax
  800211:	89 44 24 08          	mov    %eax,0x8(%esp)
  800215:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021c:	00 
  80021d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800220:	89 14 24             	mov    %edx,(%esp)
  800223:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800226:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80022a:	e8 81 0b 00 00       	call   800db0 <__umoddi3>
  80022f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800233:	0f be 80 20 0f 80 00 	movsbl 0x800f20(%eax),%eax
  80023a:	89 04 24             	mov    %eax,(%esp)
  80023d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800240:	83 c4 4c             	add    $0x4c,%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024b:	83 fa 01             	cmp    $0x1,%edx
  80024e:	7e 0e                	jle    80025e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 08             	lea    0x8(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	8b 52 04             	mov    0x4(%edx),%edx
  80025c:	eb 22                	jmp    800280 <getuint+0x38>
	else if (lflag)
  80025e:	85 d2                	test   %edx,%edx
  800260:	74 10                	je     800272 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 04             	lea    0x4(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	ba 00 00 00 00       	mov    $0x0,%edx
  800270:	eb 0e                	jmp    800280 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800272:	8b 10                	mov    (%eax),%edx
  800274:	8d 4a 04             	lea    0x4(%edx),%ecx
  800277:	89 08                	mov    %ecx,(%eax)
  800279:	8b 02                	mov    (%edx),%eax
  80027b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800285:	83 fa 01             	cmp    $0x1,%edx
  800288:	7e 0e                	jle    800298 <getint+0x16>
		return va_arg(*ap, long long);
  80028a:	8b 10                	mov    (%eax),%edx
  80028c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028f:	89 08                	mov    %ecx,(%eax)
  800291:	8b 02                	mov    (%edx),%eax
  800293:	8b 52 04             	mov    0x4(%edx),%edx
  800296:	eb 22                	jmp    8002ba <getint+0x38>
	else if (lflag)
  800298:	85 d2                	test   %edx,%edx
  80029a:	74 10                	je     8002ac <getint+0x2a>
		return va_arg(*ap, long);
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 02                	mov    (%edx),%eax
  8002a5:	89 c2                	mov    %eax,%edx
  8002a7:	c1 fa 1f             	sar    $0x1f,%edx
  8002aa:	eb 0e                	jmp    8002ba <getint+0x38>
	else
		return va_arg(*ap, int);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	89 c2                	mov    %eax,%edx
  8002b7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cb:	73 0a                	jae    8002d7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d0:	88 0a                	mov    %cl,(%edx)
  8002d2:	83 c2 01             	add    $0x1,%edx
  8002d5:	89 10                	mov    %edx,(%eax)
}
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    

008002d9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002df:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f7:	89 04 24             	mov    %eax,(%esp)
  8002fa:	e8 02 00 00 00       	call   800301 <vprintfmt>
	va_end(ap);
}
  8002ff:	c9                   	leave  
  800300:	c3                   	ret    

00800301 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	57                   	push   %edi
  800305:	56                   	push   %esi
  800306:	53                   	push   %ebx
  800307:	83 ec 4c             	sub    $0x4c,%esp
  80030a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80030d:	eb 23                	jmp    800332 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80030f:	85 c0                	test   %eax,%eax
  800311:	75 12                	jne    800325 <vprintfmt+0x24>
				csa = 0x0700;
  800313:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80031a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80031d:	83 c4 4c             	add    $0x4c,%esp
  800320:	5b                   	pop    %ebx
  800321:	5e                   	pop    %esi
  800322:	5f                   	pop    %edi
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800325:	8b 55 0c             	mov    0xc(%ebp),%edx
  800328:	89 54 24 04          	mov    %edx,0x4(%esp)
  80032c:	89 04 24             	mov    %eax,(%esp)
  80032f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800332:	0f b6 07             	movzbl (%edi),%eax
  800335:	83 c7 01             	add    $0x1,%edi
  800338:	83 f8 25             	cmp    $0x25,%eax
  80033b:	75 d2                	jne    80030f <vprintfmt+0xe>
  80033d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800341:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800348:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80034d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800354:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800359:	be 00 00 00 00       	mov    $0x0,%esi
  80035e:	eb 14                	jmp    800374 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800360:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800364:	eb 0e                	jmp    800374 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800366:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80036a:	eb 08                	jmp    800374 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80036c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80036f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	0f b6 07             	movzbl (%edi),%eax
  800377:	0f b6 c8             	movzbl %al,%ecx
  80037a:	83 c7 01             	add    $0x1,%edi
  80037d:	83 e8 23             	sub    $0x23,%eax
  800380:	3c 55                	cmp    $0x55,%al
  800382:	0f 87 ed 02 00 00    	ja     800675 <vprintfmt+0x374>
  800388:	0f b6 c0             	movzbl %al,%eax
  80038b:	ff 24 85 b0 0f 80 00 	jmp    *0x800fb0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800392:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  800395:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800398:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80039b:	83 f9 09             	cmp    $0x9,%ecx
  80039e:	77 3c                	ja     8003dc <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8003a6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8003aa:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003ad:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003b0:	83 f9 09             	cmp    $0x9,%ecx
  8003b3:	76 eb                	jbe    8003a0 <vprintfmt+0x9f>
  8003b5:	eb 25                	jmp    8003dc <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	8d 48 04             	lea    0x4(%eax),%ecx
  8003bd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003c0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  8003c2:	eb 18                	jmp    8003dc <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  8003c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003cb:	0f 48 c6             	cmovs  %esi,%eax
  8003ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d1:	eb a1                	jmp    800374 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  8003d3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003da:	eb 98                	jmp    800374 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  8003dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e0:	79 92                	jns    800374 <vprintfmt+0x73>
  8003e2:	eb 88                	jmp    80036c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e4:	83 c2 01             	add    $0x1,%edx
  8003e7:	eb 8b                	jmp    800374 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 50 04             	lea    0x4(%eax),%edx
  8003ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003f9:	8b 00                	mov    (%eax),%eax
  8003fb:	89 04 24             	mov    %eax,(%esp)
  8003fe:	ff 55 08             	call   *0x8(%ebp)
			break;
  800401:	e9 2c ff ff ff       	jmp    800332 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	8d 50 04             	lea    0x4(%eax),%edx
  80040c:	89 55 14             	mov    %edx,0x14(%ebp)
  80040f:	8b 00                	mov    (%eax),%eax
  800411:	89 c2                	mov    %eax,%edx
  800413:	c1 fa 1f             	sar    $0x1f,%edx
  800416:	31 d0                	xor    %edx,%eax
  800418:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041a:	83 f8 06             	cmp    $0x6,%eax
  80041d:	7f 0b                	jg     80042a <vprintfmt+0x129>
  80041f:	8b 14 85 08 11 80 00 	mov    0x801108(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 23                	jne    80044d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80042a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042e:	c7 44 24 08 38 0f 80 	movl   $0x800f38,0x8(%esp)
  800435:	00 
  800436:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800439:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043d:	8b 45 08             	mov    0x8(%ebp),%eax
  800440:	89 04 24             	mov    %eax,(%esp)
  800443:	e8 91 fe ff ff       	call   8002d9 <printfmt>
  800448:	e9 e5 fe ff ff       	jmp    800332 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80044d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800451:	c7 44 24 08 41 0f 80 	movl   $0x800f41,0x8(%esp)
  800458:	00 
  800459:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800460:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800463:	89 1c 24             	mov    %ebx,(%esp)
  800466:	e8 6e fe ff ff       	call   8002d9 <printfmt>
  80046b:	e9 c2 fe ff ff       	jmp    800332 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800473:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800476:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	8d 50 04             	lea    0x4(%eax),%edx
  80047f:	89 55 14             	mov    %edx,0x14(%ebp)
  800482:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800484:	85 f6                	test   %esi,%esi
  800486:	ba 31 0f 80 00       	mov    $0x800f31,%edx
  80048b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80048e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800492:	7e 06                	jle    80049a <vprintfmt+0x199>
  800494:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800498:	75 13                	jne    8004ad <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049a:	0f be 06             	movsbl (%esi),%eax
  80049d:	83 c6 01             	add    $0x1,%esi
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	0f 85 a2 00 00 00    	jne    80054a <vprintfmt+0x249>
  8004a8:	e9 92 00 00 00       	jmp    80053f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b1:	89 34 24             	mov    %esi,(%esp)
  8004b4:	e8 82 02 00 00       	call   80073b <strnlen>
  8004b9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004bc:	29 c2                	sub    %eax,%edx
  8004be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004c1:	85 d2                	test   %edx,%edx
  8004c3:	7e d5                	jle    80049a <vprintfmt+0x199>
					putch(padc, putdat);
  8004c5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8004c9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004cc:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8004cf:	89 d3                	mov    %edx,%ebx
  8004d1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004d7:	89 c6                	mov    %eax,%esi
  8004d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004dd:	89 34 24             	mov    %esi,(%esp)
  8004e0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	83 eb 01             	sub    $0x1,%ebx
  8004e6:	85 db                	test   %ebx,%ebx
  8004e8:	7f ef                	jg     8004d9 <vprintfmt+0x1d8>
  8004ea:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004ed:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004fa:	eb 9e                	jmp    80049a <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800500:	74 1b                	je     80051d <vprintfmt+0x21c>
  800502:	8d 50 e0             	lea    -0x20(%eax),%edx
  800505:	83 fa 5e             	cmp    $0x5e,%edx
  800508:	76 13                	jbe    80051d <vprintfmt+0x21c>
					putch('?', putdat);
  80050a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80050d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800511:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800518:	ff 55 08             	call   *0x8(%ebp)
  80051b:	eb 0d                	jmp    80052a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80051d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800520:	89 54 24 04          	mov    %edx,0x4(%esp)
  800524:	89 04 24             	mov    %eax,(%esp)
  800527:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052a:	83 ef 01             	sub    $0x1,%edi
  80052d:	0f be 06             	movsbl (%esi),%eax
  800530:	85 c0                	test   %eax,%eax
  800532:	74 05                	je     800539 <vprintfmt+0x238>
  800534:	83 c6 01             	add    $0x1,%esi
  800537:	eb 17                	jmp    800550 <vprintfmt+0x24f>
  800539:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80053c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80053f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800543:	7f 1c                	jg     800561 <vprintfmt+0x260>
  800545:	e9 e8 fd ff ff       	jmp    800332 <vprintfmt+0x31>
  80054a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80054d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800550:	85 db                	test   %ebx,%ebx
  800552:	78 a8                	js     8004fc <vprintfmt+0x1fb>
  800554:	83 eb 01             	sub    $0x1,%ebx
  800557:	79 a3                	jns    8004fc <vprintfmt+0x1fb>
  800559:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80055c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80055f:	eb de                	jmp    80053f <vprintfmt+0x23e>
  800561:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800564:	8b 7d 08             	mov    0x8(%ebp),%edi
  800567:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80056e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800575:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800577:	83 eb 01             	sub    $0x1,%ebx
  80057a:	85 db                	test   %ebx,%ebx
  80057c:	7f ec                	jg     80056a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800581:	e9 ac fd ff ff       	jmp    800332 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800586:	8d 45 14             	lea    0x14(%ebp),%eax
  800589:	e8 f4 fc ff ff       	call   800282 <getint>
  80058e:	89 c3                	mov    %eax,%ebx
  800590:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800592:	85 d2                	test   %edx,%edx
  800594:	78 0a                	js     8005a0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800596:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80059b:	e9 87 00 00 00       	jmp    800627 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005ae:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005b1:	89 d8                	mov    %ebx,%eax
  8005b3:	89 f2                	mov    %esi,%edx
  8005b5:	f7 d8                	neg    %eax
  8005b7:	83 d2 00             	adc    $0x0,%edx
  8005ba:	f7 da                	neg    %edx
			}
			base = 10;
  8005bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c1:	eb 64                	jmp    800627 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c6:	e8 7d fc ff ff       	call   800248 <getuint>
			base = 10;
  8005cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d0:	eb 55                	jmp    800627 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d5:	e8 6e fc ff ff       	call   800248 <getuint>
      base = 8;
  8005da:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8005df:	eb 46                	jmp    800627 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005e8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005ef:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f9:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800600:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 50 04             	lea    0x4(%eax),%edx
  800609:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80060c:	8b 00                	mov    (%eax),%eax
  80060e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800613:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800618:	eb 0d                	jmp    800627 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80061a:	8d 45 14             	lea    0x14(%ebp),%eax
  80061d:	e8 26 fc ff ff       	call   800248 <getuint>
			base = 16;
  800622:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800627:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80062b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80062f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800632:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800636:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80063a:	89 04 24             	mov    %eax,(%esp)
  80063d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800641:	8b 55 0c             	mov    0xc(%ebp),%edx
  800644:	8b 45 08             	mov    0x8(%ebp),%eax
  800647:	e8 14 fb ff ff       	call   800160 <printnum>
			break;
  80064c:	e9 e1 fc ff ff       	jmp    800332 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800651:	8b 45 0c             	mov    0xc(%ebp),%eax
  800654:	89 44 24 04          	mov    %eax,0x4(%esp)
  800658:	89 0c 24             	mov    %ecx,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80065e:	e9 cf fc ff ff       	jmp    800332 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	e8 17 fc ff ff       	call   800282 <getint>
			csa = num;
  80066b:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  800670:	e9 bd fc ff ff       	jmp    800332 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800675:	8b 55 0c             	mov    0xc(%ebp),%edx
  800678:	89 54 24 04          	mov    %edx,0x4(%esp)
  80067c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800683:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800686:	83 ef 01             	sub    $0x1,%edi
  800689:	eb 02                	jmp    80068d <vprintfmt+0x38c>
  80068b:	89 c7                	mov    %eax,%edi
  80068d:	8d 47 ff             	lea    -0x1(%edi),%eax
  800690:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800694:	75 f5                	jne    80068b <vprintfmt+0x38a>
  800696:	e9 97 fc ff ff       	jmp    800332 <vprintfmt+0x31>

0080069b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	83 ec 28             	sub    $0x28,%esp
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 30                	je     8006ec <vsnprintf+0x51>
  8006bc:	85 d2                	test   %edx,%edx
  8006be:	7e 2c                	jle    8006ec <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d5:	c7 04 24 bc 02 80 00 	movl   $0x8002bc,(%esp)
  8006dc:	e8 20 fc ff ff       	call   800301 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ea:	eb 05                	jmp    8006f1 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f1:	c9                   	leave  
  8006f2:	c3                   	ret    

008006f3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800700:	8b 45 10             	mov    0x10(%ebp),%eax
  800703:	89 44 24 08          	mov    %eax,0x8(%esp)
  800707:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070e:	8b 45 08             	mov    0x8(%ebp),%eax
  800711:	89 04 24             	mov    %eax,(%esp)
  800714:	e8 82 ff ff ff       	call   80069b <vsnprintf>
	va_end(ap);

	return rc;
}
  800719:	c9                   	leave  
  80071a:	c3                   	ret    
  80071b:	00 00                	add    %al,(%eax)
  80071d:	00 00                	add    %al,(%eax)
	...

00800720 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
  80072b:	80 3a 00             	cmpb   $0x0,(%edx)
  80072e:	74 09                	je     800739 <strlen+0x19>
		n++;
  800730:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800733:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800737:	75 f7                	jne    800730 <strlen+0x10>
		n++;
	return n;
}
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800741:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800744:	b8 00 00 00 00       	mov    $0x0,%eax
  800749:	85 d2                	test   %edx,%edx
  80074b:	74 12                	je     80075f <strnlen+0x24>
  80074d:	80 39 00             	cmpb   $0x0,(%ecx)
  800750:	74 0d                	je     80075f <strnlen+0x24>
		n++;
  800752:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800755:	39 d0                	cmp    %edx,%eax
  800757:	74 06                	je     80075f <strnlen+0x24>
  800759:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80075d:	75 f3                	jne    800752 <strnlen+0x17>
		n++;
	return n;
}
  80075f:	5d                   	pop    %ebp
  800760:	c3                   	ret    

00800761 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	53                   	push   %ebx
  800765:	8b 45 08             	mov    0x8(%ebp),%eax
  800768:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076b:	ba 00 00 00 00       	mov    $0x0,%edx
  800770:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800774:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800777:	83 c2 01             	add    $0x1,%edx
  80077a:	84 c9                	test   %cl,%cl
  80077c:	75 f2                	jne    800770 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80077e:	5b                   	pop    %ebx
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	53                   	push   %ebx
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078b:	89 1c 24             	mov    %ebx,(%esp)
  80078e:	e8 8d ff ff ff       	call   800720 <strlen>
	strcpy(dst + len, src);
  800793:	8b 55 0c             	mov    0xc(%ebp),%edx
  800796:	89 54 24 04          	mov    %edx,0x4(%esp)
  80079a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80079d:	89 04 24             	mov    %eax,(%esp)
  8007a0:	e8 bc ff ff ff       	call   800761 <strcpy>
	return dst;
}
  8007a5:	89 d8                	mov    %ebx,%eax
  8007a7:	83 c4 08             	add    $0x8,%esp
  8007aa:	5b                   	pop    %ebx
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	56                   	push   %esi
  8007b1:	53                   	push   %ebx
  8007b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bb:	85 f6                	test   %esi,%esi
  8007bd:	74 18                	je     8007d7 <strncpy+0x2a>
  8007bf:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007c4:	0f b6 1a             	movzbl (%edx),%ebx
  8007c7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ca:	80 3a 01             	cmpb   $0x1,(%edx)
  8007cd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d0:	83 c1 01             	add    $0x1,%ecx
  8007d3:	39 ce                	cmp    %ecx,%esi
  8007d5:	77 ed                	ja     8007c4 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d7:	5b                   	pop    %ebx
  8007d8:	5e                   	pop    %esi
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	56                   	push   %esi
  8007df:	53                   	push   %ebx
  8007e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e9:	89 f0                	mov    %esi,%eax
  8007eb:	85 c9                	test   %ecx,%ecx
  8007ed:	74 23                	je     800812 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  8007ef:	83 e9 01             	sub    $0x1,%ecx
  8007f2:	74 1b                	je     80080f <strlcpy+0x34>
  8007f4:	0f b6 1a             	movzbl (%edx),%ebx
  8007f7:	84 db                	test   %bl,%bl
  8007f9:	74 14                	je     80080f <strlcpy+0x34>
			*dst++ = *src++;
  8007fb:	88 18                	mov    %bl,(%eax)
  8007fd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800800:	83 e9 01             	sub    $0x1,%ecx
  800803:	74 0a                	je     80080f <strlcpy+0x34>
			*dst++ = *src++;
  800805:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800808:	0f b6 1a             	movzbl (%edx),%ebx
  80080b:	84 db                	test   %bl,%bl
  80080d:	75 ec                	jne    8007fb <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80080f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800812:	29 f0                	sub    %esi,%eax
}
  800814:	5b                   	pop    %ebx
  800815:	5e                   	pop    %esi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800821:	0f b6 01             	movzbl (%ecx),%eax
  800824:	84 c0                	test   %al,%al
  800826:	74 15                	je     80083d <strcmp+0x25>
  800828:	3a 02                	cmp    (%edx),%al
  80082a:	75 11                	jne    80083d <strcmp+0x25>
		p++, q++;
  80082c:	83 c1 01             	add    $0x1,%ecx
  80082f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800832:	0f b6 01             	movzbl (%ecx),%eax
  800835:	84 c0                	test   %al,%al
  800837:	74 04                	je     80083d <strcmp+0x25>
  800839:	3a 02                	cmp    (%edx),%al
  80083b:	74 ef                	je     80082c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083d:	0f b6 c0             	movzbl %al,%eax
  800840:	0f b6 12             	movzbl (%edx),%edx
  800843:	29 d0                	sub    %edx,%eax
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800851:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800854:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800859:	85 d2                	test   %edx,%edx
  80085b:	74 28                	je     800885 <strncmp+0x3e>
  80085d:	0f b6 01             	movzbl (%ecx),%eax
  800860:	84 c0                	test   %al,%al
  800862:	74 24                	je     800888 <strncmp+0x41>
  800864:	3a 03                	cmp    (%ebx),%al
  800866:	75 20                	jne    800888 <strncmp+0x41>
  800868:	83 ea 01             	sub    $0x1,%edx
  80086b:	74 13                	je     800880 <strncmp+0x39>
		n--, p++, q++;
  80086d:	83 c1 01             	add    $0x1,%ecx
  800870:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800873:	0f b6 01             	movzbl (%ecx),%eax
  800876:	84 c0                	test   %al,%al
  800878:	74 0e                	je     800888 <strncmp+0x41>
  80087a:	3a 03                	cmp    (%ebx),%al
  80087c:	74 ea                	je     800868 <strncmp+0x21>
  80087e:	eb 08                	jmp    800888 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800885:	5b                   	pop    %ebx
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800888:	0f b6 01             	movzbl (%ecx),%eax
  80088b:	0f b6 13             	movzbl (%ebx),%edx
  80088e:	29 d0                	sub    %edx,%eax
  800890:	eb f3                	jmp    800885 <strncmp+0x3e>

00800892 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089c:	0f b6 10             	movzbl (%eax),%edx
  80089f:	84 d2                	test   %dl,%dl
  8008a1:	74 20                	je     8008c3 <strchr+0x31>
		if (*s == c)
  8008a3:	38 ca                	cmp    %cl,%dl
  8008a5:	75 0b                	jne    8008b2 <strchr+0x20>
  8008a7:	eb 1f                	jmp    8008c8 <strchr+0x36>
  8008a9:	38 ca                	cmp    %cl,%dl
  8008ab:	90                   	nop
  8008ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8008b0:	74 16                	je     8008c8 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	0f b6 10             	movzbl (%eax),%edx
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	75 ed                	jne    8008a9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c1:	eb 05                	jmp    8008c8 <strchr+0x36>
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d4:	0f b6 10             	movzbl (%eax),%edx
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	74 14                	je     8008ef <strfind+0x25>
		if (*s == c)
  8008db:	38 ca                	cmp    %cl,%dl
  8008dd:	75 06                	jne    8008e5 <strfind+0x1b>
  8008df:	eb 0e                	jmp    8008ef <strfind+0x25>
  8008e1:	38 ca                	cmp    %cl,%dl
  8008e3:	74 0a                	je     8008ef <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008e5:	83 c0 01             	add    $0x1,%eax
  8008e8:	0f b6 10             	movzbl (%eax),%edx
  8008eb:	84 d2                	test   %dl,%dl
  8008ed:	75 f2                	jne    8008e1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	83 ec 0c             	sub    $0xc,%esp
  8008f7:	89 1c 24             	mov    %ebx,(%esp)
  8008fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800902:	8b 7d 08             	mov    0x8(%ebp),%edi
  800905:	8b 45 0c             	mov    0xc(%ebp),%eax
  800908:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090b:	85 c9                	test   %ecx,%ecx
  80090d:	74 30                	je     80093f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800915:	75 25                	jne    80093c <memset+0x4b>
  800917:	f6 c1 03             	test   $0x3,%cl
  80091a:	75 20                	jne    80093c <memset+0x4b>
		c &= 0xFF;
  80091c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091f:	89 d3                	mov    %edx,%ebx
  800921:	c1 e3 08             	shl    $0x8,%ebx
  800924:	89 d6                	mov    %edx,%esi
  800926:	c1 e6 18             	shl    $0x18,%esi
  800929:	89 d0                	mov    %edx,%eax
  80092b:	c1 e0 10             	shl    $0x10,%eax
  80092e:	09 f0                	or     %esi,%eax
  800930:	09 d0                	or     %edx,%eax
  800932:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800934:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800937:	fc                   	cld    
  800938:	f3 ab                	rep stos %eax,%es:(%edi)
  80093a:	eb 03                	jmp    80093f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093c:	fc                   	cld    
  80093d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093f:	89 f8                	mov    %edi,%eax
  800941:	8b 1c 24             	mov    (%esp),%ebx
  800944:	8b 74 24 04          	mov    0x4(%esp),%esi
  800948:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80094c:	89 ec                	mov    %ebp,%esp
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	83 ec 08             	sub    $0x8,%esp
  800956:	89 34 24             	mov    %esi,(%esp)
  800959:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	8b 75 0c             	mov    0xc(%ebp),%esi
  800963:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800966:	39 c6                	cmp    %eax,%esi
  800968:	73 36                	jae    8009a0 <memmove+0x50>
  80096a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096d:	39 d0                	cmp    %edx,%eax
  80096f:	73 2f                	jae    8009a0 <memmove+0x50>
		s += n;
		d += n;
  800971:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800974:	f6 c2 03             	test   $0x3,%dl
  800977:	75 1b                	jne    800994 <memmove+0x44>
  800979:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097f:	75 13                	jne    800994 <memmove+0x44>
  800981:	f6 c1 03             	test   $0x3,%cl
  800984:	75 0e                	jne    800994 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800986:	83 ef 04             	sub    $0x4,%edi
  800989:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80098f:	fd                   	std    
  800990:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800992:	eb 09                	jmp    80099d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800994:	83 ef 01             	sub    $0x1,%edi
  800997:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80099a:	fd                   	std    
  80099b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099d:	fc                   	cld    
  80099e:	eb 20                	jmp    8009c0 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a6:	75 13                	jne    8009bb <memmove+0x6b>
  8009a8:	a8 03                	test   $0x3,%al
  8009aa:	75 0f                	jne    8009bb <memmove+0x6b>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0a                	jne    8009bb <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009b4:	89 c7                	mov    %eax,%edi
  8009b6:	fc                   	cld    
  8009b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b9:	eb 05                	jmp    8009c0 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009bb:	89 c7                	mov    %eax,%edi
  8009bd:	fc                   	cld    
  8009be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c0:	8b 34 24             	mov    (%esp),%esi
  8009c3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8009c7:	89 ec                	mov    %ebp,%esp
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	89 04 24             	mov    %eax,(%esp)
  8009e5:	e8 66 ff ff ff       	call   800950 <memmove>
}
  8009ea:	c9                   	leave  
  8009eb:	c3                   	ret    

008009ec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	57                   	push   %edi
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f8:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a00:	85 ff                	test   %edi,%edi
  800a02:	74 38                	je     800a3c <memcmp+0x50>
		if (*s1 != *s2)
  800a04:	0f b6 03             	movzbl (%ebx),%eax
  800a07:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0a:	83 ef 01             	sub    $0x1,%edi
  800a0d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a12:	38 c8                	cmp    %cl,%al
  800a14:	74 1d                	je     800a33 <memcmp+0x47>
  800a16:	eb 11                	jmp    800a29 <memcmp+0x3d>
  800a18:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a1d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800a22:	83 c2 01             	add    $0x1,%edx
  800a25:	38 c8                	cmp    %cl,%al
  800a27:	74 0a                	je     800a33 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800a29:	0f b6 c0             	movzbl %al,%eax
  800a2c:	0f b6 c9             	movzbl %cl,%ecx
  800a2f:	29 c8                	sub    %ecx,%eax
  800a31:	eb 09                	jmp    800a3c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a33:	39 fa                	cmp    %edi,%edx
  800a35:	75 e1                	jne    800a18 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	5e                   	pop    %esi
  800a3e:	5f                   	pop    %edi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a47:	89 c2                	mov    %eax,%edx
  800a49:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a4c:	39 d0                	cmp    %edx,%eax
  800a4e:	73 15                	jae    800a65 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a54:	38 08                	cmp    %cl,(%eax)
  800a56:	75 06                	jne    800a5e <memfind+0x1d>
  800a58:	eb 0b                	jmp    800a65 <memfind+0x24>
  800a5a:	38 08                	cmp    %cl,(%eax)
  800a5c:	74 07                	je     800a65 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5e:	83 c0 01             	add    $0x1,%eax
  800a61:	39 c2                	cmp    %eax,%edx
  800a63:	77 f5                	ja     800a5a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a73:	0f b6 02             	movzbl (%edx),%eax
  800a76:	3c 20                	cmp    $0x20,%al
  800a78:	74 04                	je     800a7e <strtol+0x17>
  800a7a:	3c 09                	cmp    $0x9,%al
  800a7c:	75 0e                	jne    800a8c <strtol+0x25>
		s++;
  800a7e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a81:	0f b6 02             	movzbl (%edx),%eax
  800a84:	3c 20                	cmp    $0x20,%al
  800a86:	74 f6                	je     800a7e <strtol+0x17>
  800a88:	3c 09                	cmp    $0x9,%al
  800a8a:	74 f2                	je     800a7e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8c:	3c 2b                	cmp    $0x2b,%al
  800a8e:	75 0a                	jne    800a9a <strtol+0x33>
		s++;
  800a90:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a93:	bf 00 00 00 00       	mov    $0x0,%edi
  800a98:	eb 10                	jmp    800aaa <strtol+0x43>
  800a9a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9f:	3c 2d                	cmp    $0x2d,%al
  800aa1:	75 07                	jne    800aaa <strtol+0x43>
		s++, neg = 1;
  800aa3:	83 c2 01             	add    $0x1,%edx
  800aa6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aaa:	85 db                	test   %ebx,%ebx
  800aac:	0f 94 c0             	sete   %al
  800aaf:	74 05                	je     800ab6 <strtol+0x4f>
  800ab1:	83 fb 10             	cmp    $0x10,%ebx
  800ab4:	75 15                	jne    800acb <strtol+0x64>
  800ab6:	80 3a 30             	cmpb   $0x30,(%edx)
  800ab9:	75 10                	jne    800acb <strtol+0x64>
  800abb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800abf:	75 0a                	jne    800acb <strtol+0x64>
		s += 2, base = 16;
  800ac1:	83 c2 02             	add    $0x2,%edx
  800ac4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac9:	eb 13                	jmp    800ade <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800acb:	84 c0                	test   %al,%al
  800acd:	74 0f                	je     800ade <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800acf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ad7:	75 05                	jne    800ade <strtol+0x77>
		s++, base = 8;
  800ad9:	83 c2 01             	add    $0x1,%edx
  800adc:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae5:	0f b6 0a             	movzbl (%edx),%ecx
  800ae8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aeb:	80 fb 09             	cmp    $0x9,%bl
  800aee:	77 08                	ja     800af8 <strtol+0x91>
			dig = *s - '0';
  800af0:	0f be c9             	movsbl %cl,%ecx
  800af3:	83 e9 30             	sub    $0x30,%ecx
  800af6:	eb 1e                	jmp    800b16 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800af8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800afb:	80 fb 19             	cmp    $0x19,%bl
  800afe:	77 08                	ja     800b08 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b00:	0f be c9             	movsbl %cl,%ecx
  800b03:	83 e9 57             	sub    $0x57,%ecx
  800b06:	eb 0e                	jmp    800b16 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b08:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b0b:	80 fb 19             	cmp    $0x19,%bl
  800b0e:	77 15                	ja     800b25 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800b10:	0f be c9             	movsbl %cl,%ecx
  800b13:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b16:	39 f1                	cmp    %esi,%ecx
  800b18:	7d 0f                	jge    800b29 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800b1a:	83 c2 01             	add    $0x1,%edx
  800b1d:	0f af c6             	imul   %esi,%eax
  800b20:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b23:	eb c0                	jmp    800ae5 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b25:	89 c1                	mov    %eax,%ecx
  800b27:	eb 02                	jmp    800b2b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b29:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2f:	74 05                	je     800b36 <strtol+0xcf>
		*endptr = (char *) s;
  800b31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b34:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b36:	89 ca                	mov    %ecx,%edx
  800b38:	f7 da                	neg    %edx
  800b3a:	85 ff                	test   %edi,%edi
  800b3c:	0f 45 c2             	cmovne %edx,%eax
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	89 1c 24             	mov    %ebx,(%esp)
  800b4d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b51:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b55:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b60:	89 c3                	mov    %eax,%ebx
  800b62:	89 c7                	mov    %eax,%edi
  800b64:	89 c6                	mov    %eax,%esi
  800b66:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b68:	8b 1c 24             	mov    (%esp),%ebx
  800b6b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b6f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b73:	89 ec                	mov    %ebp,%esp
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	83 ec 0c             	sub    $0xc,%esp
  800b7d:	89 1c 24             	mov    %ebx,(%esp)
  800b80:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b84:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b92:	89 d1                	mov    %edx,%ecx
  800b94:	89 d3                	mov    %edx,%ebx
  800b96:	89 d7                	mov    %edx,%edi
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9c:	8b 1c 24             	mov    (%esp),%ebx
  800b9f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ba3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ba7:	89 ec                	mov    %ebp,%esp
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	83 ec 38             	sub    $0x38,%esp
  800bb1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bb4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bb7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbf:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	89 cb                	mov    %ecx,%ebx
  800bc9:	89 cf                	mov    %ecx,%edi
  800bcb:	89 ce                	mov    %ecx,%esi
  800bcd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	7e 28                	jle    800bfb <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bde:	00 
  800bdf:	c7 44 24 08 24 11 80 	movl   $0x801124,0x8(%esp)
  800be6:	00 
  800be7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bee:	00 
  800bef:	c7 04 24 41 11 80 00 	movl   $0x801141,(%esp)
  800bf6:	e8 41 00 00 00       	call   800c3c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bfe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c01:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c04:	89 ec                	mov    %ebp,%esp
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	89 1c 24             	mov    %ebx,(%esp)
  800c11:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c15:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c19:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c23:	89 d1                	mov    %edx,%ecx
  800c25:	89 d3                	mov    %edx,%ebx
  800c27:	89 d7                	mov    %edx,%edi
  800c29:	89 d6                	mov    %edx,%esi
  800c2b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c2d:	8b 1c 24             	mov    (%esp),%ebx
  800c30:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c34:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c38:	89 ec                	mov    %ebp,%esp
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800c44:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c47:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c4d:	e8 b6 ff ff ff       	call   800c08 <sys_getenvid>
  800c52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c55:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c60:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c68:	c7 04 24 50 11 80 00 	movl   $0x801150,(%esp)
  800c6f:	e8 cf f4 ff ff       	call   800143 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c74:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c78:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7b:	89 04 24             	mov    %eax,(%esp)
  800c7e:	e8 5f f4 ff ff       	call   8000e2 <vcprintf>
	cprintf("\n");
  800c83:	c7 04 24 14 0f 80 00 	movl   $0x800f14,(%esp)
  800c8a:	e8 b4 f4 ff ff       	call   800143 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c8f:	cc                   	int3   
  800c90:	eb fd                	jmp    800c8f <_panic+0x53>
	...

00800ca0 <__udivdi3>:
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	83 ec 10             	sub    $0x10,%esp
  800ca8:	8b 75 14             	mov    0x14(%ebp),%esi
  800cab:	8b 45 08             	mov    0x8(%ebp),%eax
  800cae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cb1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cb4:	85 f6                	test   %esi,%esi
  800cb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cb9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800cbf:	75 2f                	jne    800cf0 <__udivdi3+0x50>
  800cc1:	39 f9                	cmp    %edi,%ecx
  800cc3:	77 5b                	ja     800d20 <__udivdi3+0x80>
  800cc5:	85 c9                	test   %ecx,%ecx
  800cc7:	75 0b                	jne    800cd4 <__udivdi3+0x34>
  800cc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cce:	31 d2                	xor    %edx,%edx
  800cd0:	f7 f1                	div    %ecx
  800cd2:	89 c1                	mov    %eax,%ecx
  800cd4:	89 f8                	mov    %edi,%eax
  800cd6:	31 d2                	xor    %edx,%edx
  800cd8:	f7 f1                	div    %ecx
  800cda:	89 c7                	mov    %eax,%edi
  800cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cdf:	f7 f1                	div    %ecx
  800ce1:	89 fa                	mov    %edi,%edx
  800ce3:	83 c4 10             	add    $0x10,%esp
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    
  800cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cf0:	31 d2                	xor    %edx,%edx
  800cf2:	31 c0                	xor    %eax,%eax
  800cf4:	39 fe                	cmp    %edi,%esi
  800cf6:	77 eb                	ja     800ce3 <__udivdi3+0x43>
  800cf8:	0f bd d6             	bsr    %esi,%edx
  800cfb:	83 f2 1f             	xor    $0x1f,%edx
  800cfe:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800d01:	75 2d                	jne    800d30 <__udivdi3+0x90>
  800d03:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800d06:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  800d09:	76 06                	jbe    800d11 <__udivdi3+0x71>
  800d0b:	39 fe                	cmp    %edi,%esi
  800d0d:	89 c2                	mov    %eax,%edx
  800d0f:	73 d2                	jae    800ce3 <__udivdi3+0x43>
  800d11:	31 d2                	xor    %edx,%edx
  800d13:	b8 01 00 00 00       	mov    $0x1,%eax
  800d18:	eb c9                	jmp    800ce3 <__udivdi3+0x43>
  800d1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d20:	89 fa                	mov    %edi,%edx
  800d22:	f7 f1                	div    %ecx
  800d24:	31 d2                	xor    %edx,%edx
  800d26:	83 c4 10             	add    $0x10,%esp
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    
  800d2d:	8d 76 00             	lea    0x0(%esi),%esi
  800d30:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d34:	b8 20 00 00 00       	mov    $0x20,%eax
  800d39:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d3c:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800d3f:	d3 e6                	shl    %cl,%esi
  800d41:	89 c1                	mov    %eax,%ecx
  800d43:	d3 ea                	shr    %cl,%edx
  800d45:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d49:	09 f2                	or     %esi,%edx
  800d4b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  800d4e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d51:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d54:	d3 e2                	shl    %cl,%edx
  800d56:	89 c1                	mov    %eax,%ecx
  800d58:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800d5b:	89 fa                	mov    %edi,%edx
  800d5d:	d3 ea                	shr    %cl,%edx
  800d5f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d63:	d3 e7                	shl    %cl,%edi
  800d65:	89 c1                	mov    %eax,%ecx
  800d67:	d3 ee                	shr    %cl,%esi
  800d69:	09 fe                	or     %edi,%esi
  800d6b:	89 f0                	mov    %esi,%eax
  800d6d:	f7 75 e8             	divl   -0x18(%ebp)
  800d70:	89 d7                	mov    %edx,%edi
  800d72:	89 c6                	mov    %eax,%esi
  800d74:	f7 65 f0             	mull   -0x10(%ebp)
  800d77:	39 d7                	cmp    %edx,%edi
  800d79:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800d7c:	72 22                	jb     800da0 <__udivdi3+0x100>
  800d7e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d81:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d85:	d3 e2                	shl    %cl,%edx
  800d87:	39 c2                	cmp    %eax,%edx
  800d89:	73 05                	jae    800d90 <__udivdi3+0xf0>
  800d8b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  800d8e:	74 10                	je     800da0 <__udivdi3+0x100>
  800d90:	89 f0                	mov    %esi,%eax
  800d92:	31 d2                	xor    %edx,%edx
  800d94:	e9 4a ff ff ff       	jmp    800ce3 <__udivdi3+0x43>
  800d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800da3:	31 d2                	xor    %edx,%edx
  800da5:	83 c4 10             	add    $0x10,%esp
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    
  800dac:	00 00                	add    %al,(%eax)
	...

00800db0 <__umoddi3>:
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	57                   	push   %edi
  800db4:	56                   	push   %esi
  800db5:	83 ec 20             	sub    $0x20,%esp
  800db8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800dc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dc4:	85 ff                	test   %edi,%edi
  800dc6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800dc9:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800dcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800dcf:	89 f2                	mov    %esi,%edx
  800dd1:	75 15                	jne    800de8 <__umoddi3+0x38>
  800dd3:	39 f1                	cmp    %esi,%ecx
  800dd5:	76 41                	jbe    800e18 <__umoddi3+0x68>
  800dd7:	f7 f1                	div    %ecx
  800dd9:	89 d0                	mov    %edx,%eax
  800ddb:	31 d2                	xor    %edx,%edx
  800ddd:	83 c4 20             	add    $0x20,%esp
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    
  800de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800de8:	39 f7                	cmp    %esi,%edi
  800dea:	77 4c                	ja     800e38 <__umoddi3+0x88>
  800dec:	0f bd c7             	bsr    %edi,%eax
  800def:	83 f0 1f             	xor    $0x1f,%eax
  800df2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800df5:	75 51                	jne    800e48 <__umoddi3+0x98>
  800df7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800dfa:	0f 87 e8 00 00 00    	ja     800ee8 <__umoddi3+0x138>
  800e00:	89 f2                	mov    %esi,%edx
  800e02:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e05:	29 ce                	sub    %ecx,%esi
  800e07:	19 fa                	sbb    %edi,%edx
  800e09:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0f:	83 c4 20             	add    $0x20,%esp
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	85 c9                	test   %ecx,%ecx
  800e1a:	75 0b                	jne    800e27 <__umoddi3+0x77>
  800e1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e21:	31 d2                	xor    %edx,%edx
  800e23:	f7 f1                	div    %ecx
  800e25:	89 c1                	mov    %eax,%ecx
  800e27:	89 f0                	mov    %esi,%eax
  800e29:	31 d2                	xor    %edx,%edx
  800e2b:	f7 f1                	div    %ecx
  800e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e30:	eb a5                	jmp    800dd7 <__umoddi3+0x27>
  800e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e38:	89 f2                	mov    %esi,%edx
  800e3a:	83 c4 20             	add    $0x20,%esp
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    
  800e41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e48:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e4c:	89 f2                	mov    %esi,%edx
  800e4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e51:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  800e58:	29 45 f0             	sub    %eax,-0x10(%ebp)
  800e5b:	d3 e7                	shl    %cl,%edi
  800e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e60:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e64:	d3 e8                	shr    %cl,%eax
  800e66:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e6a:	09 f8                	or     %edi,%eax
  800e6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e72:	d3 e0                	shl    %cl,%eax
  800e74:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e7e:	d3 ea                	shr    %cl,%edx
  800e80:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e84:	d3 e6                	shl    %cl,%esi
  800e86:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e8a:	d3 e8                	shr    %cl,%eax
  800e8c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e90:	09 f0                	or     %esi,%eax
  800e92:	8b 75 e8             	mov    -0x18(%ebp),%esi
  800e95:	f7 75 e4             	divl   -0x1c(%ebp)
  800e98:	d3 e6                	shl    %cl,%esi
  800e9a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800e9d:	89 d6                	mov    %edx,%esi
  800e9f:	f7 65 f4             	mull   -0xc(%ebp)
  800ea2:	89 d7                	mov    %edx,%edi
  800ea4:	89 c2                	mov    %eax,%edx
  800ea6:	39 fe                	cmp    %edi,%esi
  800ea8:	89 f9                	mov    %edi,%ecx
  800eaa:	72 30                	jb     800edc <__umoddi3+0x12c>
  800eac:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800eaf:	72 27                	jb     800ed8 <__umoddi3+0x128>
  800eb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800eb4:	29 d0                	sub    %edx,%eax
  800eb6:	19 ce                	sbb    %ecx,%esi
  800eb8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800ebc:	89 f2                	mov    %esi,%edx
  800ebe:	d3 e8                	shr    %cl,%eax
  800ec0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800ec4:	d3 e2                	shl    %cl,%edx
  800ec6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800eca:	09 d0                	or     %edx,%eax
  800ecc:	89 f2                	mov    %esi,%edx
  800ece:	d3 ea                	shr    %cl,%edx
  800ed0:	83 c4 20             	add    $0x20,%esp
  800ed3:	5e                   	pop    %esi
  800ed4:	5f                   	pop    %edi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    
  800ed7:	90                   	nop
  800ed8:	39 fe                	cmp    %edi,%esi
  800eda:	75 d5                	jne    800eb1 <__umoddi3+0x101>
  800edc:	89 f9                	mov    %edi,%ecx
  800ede:	89 c2                	mov    %eax,%edx
  800ee0:	2b 55 f4             	sub    -0xc(%ebp),%edx
  800ee3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800ee6:	eb c9                	jmp    800eb1 <__umoddi3+0x101>
  800ee8:	39 f7                	cmp    %esi,%edi
  800eea:	0f 82 10 ff ff ff    	jb     800e00 <__umoddi3+0x50>
  800ef0:	e9 17 ff ff ff       	jmp    800e0c <__umoddi3+0x5c>
