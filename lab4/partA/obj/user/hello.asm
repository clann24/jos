
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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
  80003a:	c7 04 24 e0 11 80 00 	movl   $0x8011e0,(%esp)
  800041:	e8 39 01 00 00       	call   80017f <cprintf>
	cprintf("thisenv: %x\n", thisenv);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004f:	c7 04 24 ee 11 80 00 	movl   $0x8011ee,(%esp)
  800056:	e8 24 01 00 00       	call   80017f <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  80005b:	a1 04 20 80 00       	mov    0x802004,%eax
  800060:	8b 40 48             	mov    0x48(%eax),%eax
  800063:	89 44 24 04          	mov    %eax,0x4(%esp)
  800067:	c7 04 24 fb 11 80 00 	movl   $0x8011fb,(%esp)
  80006e:	e8 0c 01 00 00       	call   80017f <cprintf>
}
  800073:	c9                   	leave  
  800074:	c3                   	ret    
  800075:	00 00                	add    %al,(%eax)
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 75 08             	mov    0x8(%ebp),%esi
  800087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80008a:	e8 b9 0b 00 00       	call   800c48 <sys_getenvid>
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009c:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a1:	85 f6                	test   %esi,%esi
  8000a3:	7e 07                	jle    8000ac <libmain+0x34>
		binaryname = argv[0];
  8000a5:	8b 03                	mov    (%ebx),%eax
  8000a7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b0:	89 34 24             	mov    %esi,(%esp)
  8000b3:	e8 7c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 0b 00 00 00       	call   8000c8 <exit>
}
  8000bd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000c0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c3:	89 ec                	mov    %ebp,%esp
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    
	...

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d5:	e8 11 0b 00 00       	call   800beb <sys_env_destroy>
}
  8000da:	c9                   	leave  
  8000db:	c3                   	ret    

008000dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	53                   	push   %ebx
  8000e0:	83 ec 14             	sub    $0x14,%esp
  8000e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e6:	8b 03                	mov    (%ebx),%eax
  8000e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000eb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000ef:	83 c0 01             	add    $0x1,%eax
  8000f2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f9:	75 19                	jne    800114 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000fb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800102:	00 
  800103:	8d 43 08             	lea    0x8(%ebx),%eax
  800106:	89 04 24             	mov    %eax,(%esp)
  800109:	e8 76 0a 00 00       	call   800b84 <sys_cputs>
		b->idx = 0;
  80010e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800114:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800118:	83 c4 14             	add    $0x14,%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    

0080011e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800127:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012e:	00 00 00 
	b.cnt = 0;
  800131:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800138:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800142:	8b 45 08             	mov    0x8(%ebp),%eax
  800145:	89 44 24 08          	mov    %eax,0x8(%esp)
  800149:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800153:	c7 04 24 dc 00 80 00 	movl   $0x8000dc,(%esp)
  80015a:	e8 e2 01 00 00       	call   800341 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800165:	89 44 24 04          	mov    %eax,0x4(%esp)
  800169:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016f:	89 04 24             	mov    %eax,(%esp)
  800172:	e8 0d 0a 00 00       	call   800b84 <sys_cputs>

	return b.cnt;
}
  800177:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800185:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018c:	8b 45 08             	mov    0x8(%ebp),%eax
  80018f:	89 04 24             	mov    %eax,(%esp)
  800192:	e8 87 ff ff ff       	call   80011e <vcprintf>
	va_end(ap);

	return cnt;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    
  800199:	00 00                	add    %al,(%eax)
  80019b:	00 00                	add    %al,(%eax)
  80019d:	00 00                	add    %al,(%eax)
	...

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 4c             	sub    $0x4c,%esp
  8001a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001bd:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001c5:	39 d0                	cmp    %edx,%eax
  8001c7:	72 11                	jb     8001da <printnum+0x3a>
  8001c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001cc:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8001cf:	76 09                	jbe    8001da <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d1:	83 eb 01             	sub    $0x1,%ebx
  8001d4:	85 db                	test   %ebx,%ebx
  8001d6:	7f 5d                	jg     800235 <printnum+0x95>
  8001d8:	eb 6c                	jmp    800246 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001da:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001de:	83 eb 01             	sub    $0x1,%ebx
  8001e1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ec:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001f0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001f7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8001fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800201:	00 
  800202:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800205:	89 14 24             	mov    %edx,(%esp)
  800208:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80020b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80020f:	e8 6c 0d 00 00       	call   800f80 <__udivdi3>
  800214:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800217:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80021a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80021e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	89 54 24 04          	mov    %edx,0x4(%esp)
  800229:	89 f2                	mov    %esi,%edx
  80022b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022e:	e8 6d ff ff ff       	call   8001a0 <printnum>
  800233:	eb 11                	jmp    800246 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800235:	89 74 24 04          	mov    %esi,0x4(%esp)
  800239:	89 3c 24             	mov    %edi,(%esp)
  80023c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023f:	83 eb 01             	sub    $0x1,%ebx
  800242:	85 db                	test   %ebx,%ebx
  800244:	7f ef                	jg     800235 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800246:	89 74 24 04          	mov    %esi,0x4(%esp)
  80024a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80024e:	8b 45 10             	mov    0x10(%ebp),%eax
  800251:	89 44 24 08          	mov    %eax,0x8(%esp)
  800255:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025c:	00 
  80025d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800260:	89 14 24             	mov    %edx,(%esp)
  800263:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800266:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80026a:	e8 21 0e 00 00       	call   801090 <__umoddi3>
  80026f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800273:	0f be 80 1c 12 80 00 	movsbl 0x80121c(%eax),%eax
  80027a:	89 04 24             	mov    %eax,(%esp)
  80027d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800280:	83 c4 4c             	add    $0x4c,%esp
  800283:	5b                   	pop    %ebx
  800284:	5e                   	pop    %esi
  800285:	5f                   	pop    %edi
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80028b:	83 fa 01             	cmp    $0x1,%edx
  80028e:	7e 0e                	jle    80029e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 08             	lea    0x8(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	8b 52 04             	mov    0x4(%edx),%edx
  80029c:	eb 22                	jmp    8002c0 <getuint+0x38>
	else if (lflag)
  80029e:	85 d2                	test   %edx,%edx
  8002a0:	74 10                	je     8002b2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a2:	8b 10                	mov    (%eax),%edx
  8002a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a7:	89 08                	mov    %ecx,(%eax)
  8002a9:	8b 02                	mov    (%edx),%eax
  8002ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b0:	eb 0e                	jmp    8002c0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b2:	8b 10                	mov    (%eax),%edx
  8002b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b7:	89 08                	mov    %ecx,(%eax)
  8002b9:	8b 02                	mov    (%edx),%eax
  8002bb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c5:	83 fa 01             	cmp    $0x1,%edx
  8002c8:	7e 0e                	jle    8002d8 <getint+0x16>
		return va_arg(*ap, long long);
  8002ca:	8b 10                	mov    (%eax),%edx
  8002cc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cf:	89 08                	mov    %ecx,(%eax)
  8002d1:	8b 02                	mov    (%edx),%eax
  8002d3:	8b 52 04             	mov    0x4(%edx),%edx
  8002d6:	eb 22                	jmp    8002fa <getint+0x38>
	else if (lflag)
  8002d8:	85 d2                	test   %edx,%edx
  8002da:	74 10                	je     8002ec <getint+0x2a>
		return va_arg(*ap, long);
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e1:	89 08                	mov    %ecx,(%eax)
  8002e3:	8b 02                	mov    (%edx),%eax
  8002e5:	89 c2                	mov    %eax,%edx
  8002e7:	c1 fa 1f             	sar    $0x1f,%edx
  8002ea:	eb 0e                	jmp    8002fa <getint+0x38>
	else
		return va_arg(*ap, int);
  8002ec:	8b 10                	mov    (%eax),%edx
  8002ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f1:	89 08                	mov    %ecx,(%eax)
  8002f3:	8b 02                	mov    (%edx),%eax
  8002f5:	89 c2                	mov    %eax,%edx
  8002f7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800302:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800306:	8b 10                	mov    (%eax),%edx
  800308:	3b 50 04             	cmp    0x4(%eax),%edx
  80030b:	73 0a                	jae    800317 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800310:	88 0a                	mov    %cl,(%edx)
  800312:	83 c2 01             	add    $0x1,%edx
  800315:	89 10                	mov    %edx,(%eax)
}
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    

00800319 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80031f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800322:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800326:	8b 45 10             	mov    0x10(%ebp),%eax
  800329:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800330:	89 44 24 04          	mov    %eax,0x4(%esp)
  800334:	8b 45 08             	mov    0x8(%ebp),%eax
  800337:	89 04 24             	mov    %eax,(%esp)
  80033a:	e8 02 00 00 00       	call   800341 <vprintfmt>
	va_end(ap);
}
  80033f:	c9                   	leave  
  800340:	c3                   	ret    

00800341 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	57                   	push   %edi
  800345:	56                   	push   %esi
  800346:	53                   	push   %ebx
  800347:	83 ec 4c             	sub    $0x4c,%esp
  80034a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034d:	eb 23                	jmp    800372 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80034f:	85 c0                	test   %eax,%eax
  800351:	75 12                	jne    800365 <vprintfmt+0x24>
				csa = 0x0700;
  800353:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80035a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80035d:	83 c4 4c             	add    $0x4c,%esp
  800360:	5b                   	pop    %ebx
  800361:	5e                   	pop    %esi
  800362:	5f                   	pop    %edi
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800365:	8b 55 0c             	mov    0xc(%ebp),%edx
  800368:	89 54 24 04          	mov    %edx,0x4(%esp)
  80036c:	89 04 24             	mov    %eax,(%esp)
  80036f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800372:	0f b6 07             	movzbl (%edi),%eax
  800375:	83 c7 01             	add    $0x1,%edi
  800378:	83 f8 25             	cmp    $0x25,%eax
  80037b:	75 d2                	jne    80034f <vprintfmt+0xe>
  80037d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800381:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800388:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80038d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800394:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800399:	be 00 00 00 00       	mov    $0x0,%esi
  80039e:	eb 14                	jmp    8003b4 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003a4:	eb 0e                	jmp    8003b4 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a6:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003aa:	eb 08                	jmp    8003b4 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003ac:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003af:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	0f b6 07             	movzbl (%edi),%eax
  8003b7:	0f b6 c8             	movzbl %al,%ecx
  8003ba:	83 c7 01             	add    $0x1,%edi
  8003bd:	83 e8 23             	sub    $0x23,%eax
  8003c0:	3c 55                	cmp    $0x55,%al
  8003c2:	0f 87 ed 02 00 00    	ja     8006b5 <vprintfmt+0x374>
  8003c8:	0f b6 c0             	movzbl %al,%eax
  8003cb:	ff 24 85 e0 12 80 00 	jmp    *0x8012e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  8003d5:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003d8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003db:	83 f9 09             	cmp    $0x9,%ecx
  8003de:	77 3c                	ja     80041c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003e3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8003e6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8003ea:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003ed:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003f0:	83 f9 09             	cmp    $0x9,%ecx
  8003f3:	76 eb                	jbe    8003e0 <vprintfmt+0x9f>
  8003f5:	eb 25                	jmp    80041c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800400:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  800402:	eb 18                	jmp    80041c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  800404:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800408:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80040b:	0f 48 c6             	cmovs  %esi,%eax
  80040e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800411:	eb a1                	jmp    8003b4 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  800413:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80041a:	eb 98                	jmp    8003b4 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  80041c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800420:	79 92                	jns    8003b4 <vprintfmt+0x73>
  800422:	eb 88                	jmp    8003ac <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800424:	83 c2 01             	add    $0x1,%edx
  800427:	eb 8b                	jmp    8003b4 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8d 50 04             	lea    0x4(%eax),%edx
  80042f:	89 55 14             	mov    %edx,0x14(%ebp)
  800432:	8b 55 0c             	mov    0xc(%ebp),%edx
  800435:	89 54 24 04          	mov    %edx,0x4(%esp)
  800439:	8b 00                	mov    (%eax),%eax
  80043b:	89 04 24             	mov    %eax,(%esp)
  80043e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800441:	e9 2c ff ff ff       	jmp    800372 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	8d 50 04             	lea    0x4(%eax),%edx
  80044c:	89 55 14             	mov    %edx,0x14(%ebp)
  80044f:	8b 00                	mov    (%eax),%eax
  800451:	89 c2                	mov    %eax,%edx
  800453:	c1 fa 1f             	sar    $0x1f,%edx
  800456:	31 d0                	xor    %edx,%eax
  800458:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045a:	83 f8 08             	cmp    $0x8,%eax
  80045d:	7f 0b                	jg     80046a <vprintfmt+0x129>
  80045f:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 23                	jne    80048d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80046a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046e:	c7 44 24 08 34 12 80 	movl   $0x801234,0x8(%esp)
  800475:	00 
  800476:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800479:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80047d:	8b 45 08             	mov    0x8(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 91 fe ff ff       	call   800319 <printfmt>
  800488:	e9 e5 fe ff ff       	jmp    800372 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80048d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800491:	c7 44 24 08 3d 12 80 	movl   $0x80123d,0x8(%esp)
  800498:	00 
  800499:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004a3:	89 1c 24             	mov    %ebx,(%esp)
  8004a6:	e8 6e fe ff ff       	call   800319 <printfmt>
  8004ab:	e9 c2 fe ff ff       	jmp    800372 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8d 50 04             	lea    0x4(%eax),%edx
  8004bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c2:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004c4:	85 f6                	test   %esi,%esi
  8004c6:	ba 2d 12 80 00       	mov    $0x80122d,%edx
  8004cb:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8004ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d2:	7e 06                	jle    8004da <vprintfmt+0x199>
  8004d4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004d8:	75 13                	jne    8004ed <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	0f be 06             	movsbl (%esi),%eax
  8004dd:	83 c6 01             	add    $0x1,%esi
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	0f 85 a2 00 00 00    	jne    80058a <vprintfmt+0x249>
  8004e8:	e9 92 00 00 00       	jmp    80057f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f1:	89 34 24             	mov    %esi,(%esp)
  8004f4:	e8 82 02 00 00       	call   80077b <strnlen>
  8004f9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004fc:	29 c2                	sub    %eax,%edx
  8004fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800501:	85 d2                	test   %edx,%edx
  800503:	7e d5                	jle    8004da <vprintfmt+0x199>
					putch(padc, putdat);
  800505:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800509:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80050c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80050f:	89 d3                	mov    %edx,%ebx
  800511:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800514:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800517:	89 c6                	mov    %eax,%esi
  800519:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051d:	89 34 24             	mov    %esi,(%esp)
  800520:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	83 eb 01             	sub    $0x1,%ebx
  800526:	85 db                	test   %ebx,%ebx
  800528:	7f ef                	jg     800519 <vprintfmt+0x1d8>
  80052a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80052d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800533:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80053a:	eb 9e                	jmp    8004da <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800540:	74 1b                	je     80055d <vprintfmt+0x21c>
  800542:	8d 50 e0             	lea    -0x20(%eax),%edx
  800545:	83 fa 5e             	cmp    $0x5e,%edx
  800548:	76 13                	jbe    80055d <vprintfmt+0x21c>
					putch('?', putdat);
  80054a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800551:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800558:	ff 55 08             	call   *0x8(%ebp)
  80055b:	eb 0d                	jmp    80056a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80055d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800560:	89 54 24 04          	mov    %edx,0x4(%esp)
  800564:	89 04 24             	mov    %eax,(%esp)
  800567:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056a:	83 ef 01             	sub    $0x1,%edi
  80056d:	0f be 06             	movsbl (%esi),%eax
  800570:	85 c0                	test   %eax,%eax
  800572:	74 05                	je     800579 <vprintfmt+0x238>
  800574:	83 c6 01             	add    $0x1,%esi
  800577:	eb 17                	jmp    800590 <vprintfmt+0x24f>
  800579:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80057c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800583:	7f 1c                	jg     8005a1 <vprintfmt+0x260>
  800585:	e9 e8 fd ff ff       	jmp    800372 <vprintfmt+0x31>
  80058a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800590:	85 db                	test   %ebx,%ebx
  800592:	78 a8                	js     80053c <vprintfmt+0x1fb>
  800594:	83 eb 01             	sub    $0x1,%ebx
  800597:	79 a3                	jns    80053c <vprintfmt+0x1fb>
  800599:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80059c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80059f:	eb de                	jmp    80057f <vprintfmt+0x23e>
  8005a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005a7:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005b5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b7:	83 eb 01             	sub    $0x1,%ebx
  8005ba:	85 db                	test   %ebx,%ebx
  8005bc:	7f ec                	jg     8005aa <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c1:	e9 ac fd ff ff       	jmp    800372 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c9:	e8 f4 fc ff ff       	call   8002c2 <getint>
  8005ce:	89 c3                	mov    %eax,%ebx
  8005d0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005d2:	85 d2                	test   %edx,%edx
  8005d4:	78 0a                	js     8005e0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005db:	e9 87 00 00 00       	jmp    800667 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005ee:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005f1:	89 d8                	mov    %ebx,%eax
  8005f3:	89 f2                	mov    %esi,%edx
  8005f5:	f7 d8                	neg    %eax
  8005f7:	83 d2 00             	adc    $0x0,%edx
  8005fa:	f7 da                	neg    %edx
			}
			base = 10;
  8005fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800601:	eb 64                	jmp    800667 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800603:	8d 45 14             	lea    0x14(%ebp),%eax
  800606:	e8 7d fc ff ff       	call   800288 <getuint>
			base = 10;
  80060b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800610:	eb 55                	jmp    800667 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800612:	8d 45 14             	lea    0x14(%ebp),%eax
  800615:	e8 6e fc ff ff       	call   800288 <getuint>
      base = 8;
  80061a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80061f:	eb 46                	jmp    800667 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800621:	8b 55 0c             	mov    0xc(%ebp),%edx
  800624:	89 54 24 04          	mov    %edx,0x4(%esp)
  800628:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80062f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800632:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800635:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800639:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800640:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 50 04             	lea    0x4(%eax),%edx
  800649:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80064c:	8b 00                	mov    (%eax),%eax
  80064e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800653:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800658:	eb 0d                	jmp    800667 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	e8 26 fc ff ff       	call   800288 <getuint>
			base = 16;
  800662:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800667:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80066b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80066f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800672:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800676:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80067a:	89 04 24             	mov    %eax,(%esp)
  80067d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800681:	8b 55 0c             	mov    0xc(%ebp),%edx
  800684:	8b 45 08             	mov    0x8(%ebp),%eax
  800687:	e8 14 fb ff ff       	call   8001a0 <printnum>
			break;
  80068c:	e9 e1 fc ff ff       	jmp    800372 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800691:	8b 45 0c             	mov    0xc(%ebp),%eax
  800694:	89 44 24 04          	mov    %eax,0x4(%esp)
  800698:	89 0c 24             	mov    %ecx,(%esp)
  80069b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80069e:	e9 cf fc ff ff       	jmp    800372 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 17 fc ff ff       	call   8002c2 <getint>
			csa = num;
  8006ab:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  8006b0:	e9 bd fc ff ff       	jmp    800372 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006bc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c6:	83 ef 01             	sub    $0x1,%edi
  8006c9:	eb 02                	jmp    8006cd <vprintfmt+0x38c>
  8006cb:	89 c7                	mov    %eax,%edi
  8006cd:	8d 47 ff             	lea    -0x1(%edi),%eax
  8006d0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d4:	75 f5                	jne    8006cb <vprintfmt+0x38a>
  8006d6:	e9 97 fc ff ff       	jmp    800372 <vprintfmt+0x31>

008006db <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	83 ec 28             	sub    $0x28,%esp
  8006e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ea:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ee:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	74 30                	je     80072c <vsnprintf+0x51>
  8006fc:	85 d2                	test   %edx,%edx
  8006fe:	7e 2c                	jle    80072c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800707:	8b 45 10             	mov    0x10(%ebp),%eax
  80070a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800711:	89 44 24 04          	mov    %eax,0x4(%esp)
  800715:	c7 04 24 fc 02 80 00 	movl   $0x8002fc,(%esp)
  80071c:	e8 20 fc ff ff       	call   800341 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800721:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800724:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800727:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072a:	eb 05                	jmp    800731 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800731:	c9                   	leave  
  800732:	c3                   	ret    

00800733 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800739:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800740:	8b 45 10             	mov    0x10(%ebp),%eax
  800743:	89 44 24 08          	mov    %eax,0x8(%esp)
  800747:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	89 04 24             	mov    %eax,(%esp)
  800754:	e8 82 ff ff ff       	call   8006db <vsnprintf>
	va_end(ap);

	return rc;
}
  800759:	c9                   	leave  
  80075a:	c3                   	ret    
  80075b:	00 00                	add    %al,(%eax)
  80075d:	00 00                	add    %al,(%eax)
	...

00800760 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
  80076b:	80 3a 00             	cmpb   $0x0,(%edx)
  80076e:	74 09                	je     800779 <strlen+0x19>
		n++;
  800770:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800773:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800777:	75 f7                	jne    800770 <strlen+0x10>
		n++;
	return n;
}
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800781:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
  800789:	85 d2                	test   %edx,%edx
  80078b:	74 12                	je     80079f <strnlen+0x24>
  80078d:	80 39 00             	cmpb   $0x0,(%ecx)
  800790:	74 0d                	je     80079f <strnlen+0x24>
		n++;
  800792:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800795:	39 d0                	cmp    %edx,%eax
  800797:	74 06                	je     80079f <strnlen+0x24>
  800799:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80079d:	75 f3                	jne    800792 <strnlen+0x17>
		n++;
	return n;
}
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	53                   	push   %ebx
  8007a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007b4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007b7:	83 c2 01             	add    $0x1,%edx
  8007ba:	84 c9                	test   %cl,%cl
  8007bc:	75 f2                	jne    8007b0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007be:	5b                   	pop    %ebx
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	53                   	push   %ebx
  8007c5:	83 ec 08             	sub    $0x8,%esp
  8007c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007cb:	89 1c 24             	mov    %ebx,(%esp)
  8007ce:	e8 8d ff ff ff       	call   800760 <strlen>
	strcpy(dst + len, src);
  8007d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007da:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007dd:	89 04 24             	mov    %eax,(%esp)
  8007e0:	e8 bc ff ff ff       	call   8007a1 <strcpy>
	return dst;
}
  8007e5:	89 d8                	mov    %ebx,%eax
  8007e7:	83 c4 08             	add    $0x8,%esp
  8007ea:	5b                   	pop    %ebx
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	56                   	push   %esi
  8007f1:	53                   	push   %ebx
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fb:	85 f6                	test   %esi,%esi
  8007fd:	74 18                	je     800817 <strncpy+0x2a>
  8007ff:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800804:	0f b6 1a             	movzbl (%edx),%ebx
  800807:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080a:	80 3a 01             	cmpb   $0x1,(%edx)
  80080d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	83 c1 01             	add    $0x1,%ecx
  800813:	39 ce                	cmp    %ecx,%esi
  800815:	77 ed                	ja     800804 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800817:	5b                   	pop    %ebx
  800818:	5e                   	pop    %esi
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 75 08             	mov    0x8(%ebp),%esi
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
  800826:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800829:	89 f0                	mov    %esi,%eax
  80082b:	85 c9                	test   %ecx,%ecx
  80082d:	74 23                	je     800852 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  80082f:	83 e9 01             	sub    $0x1,%ecx
  800832:	74 1b                	je     80084f <strlcpy+0x34>
  800834:	0f b6 1a             	movzbl (%edx),%ebx
  800837:	84 db                	test   %bl,%bl
  800839:	74 14                	je     80084f <strlcpy+0x34>
			*dst++ = *src++;
  80083b:	88 18                	mov    %bl,(%eax)
  80083d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800840:	83 e9 01             	sub    $0x1,%ecx
  800843:	74 0a                	je     80084f <strlcpy+0x34>
			*dst++ = *src++;
  800845:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800848:	0f b6 1a             	movzbl (%edx),%ebx
  80084b:	84 db                	test   %bl,%bl
  80084d:	75 ec                	jne    80083b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80084f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800852:	29 f0                	sub    %esi,%eax
}
  800854:	5b                   	pop    %ebx
  800855:	5e                   	pop    %esi
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800861:	0f b6 01             	movzbl (%ecx),%eax
  800864:	84 c0                	test   %al,%al
  800866:	74 15                	je     80087d <strcmp+0x25>
  800868:	3a 02                	cmp    (%edx),%al
  80086a:	75 11                	jne    80087d <strcmp+0x25>
		p++, q++;
  80086c:	83 c1 01             	add    $0x1,%ecx
  80086f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800872:	0f b6 01             	movzbl (%ecx),%eax
  800875:	84 c0                	test   %al,%al
  800877:	74 04                	je     80087d <strcmp+0x25>
  800879:	3a 02                	cmp    (%edx),%al
  80087b:	74 ef                	je     80086c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087d:	0f b6 c0             	movzbl %al,%eax
  800880:	0f b6 12             	movzbl (%edx),%edx
  800883:	29 d0                	sub    %edx,%eax
}
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800891:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800899:	85 d2                	test   %edx,%edx
  80089b:	74 28                	je     8008c5 <strncmp+0x3e>
  80089d:	0f b6 01             	movzbl (%ecx),%eax
  8008a0:	84 c0                	test   %al,%al
  8008a2:	74 24                	je     8008c8 <strncmp+0x41>
  8008a4:	3a 03                	cmp    (%ebx),%al
  8008a6:	75 20                	jne    8008c8 <strncmp+0x41>
  8008a8:	83 ea 01             	sub    $0x1,%edx
  8008ab:	74 13                	je     8008c0 <strncmp+0x39>
		n--, p++, q++;
  8008ad:	83 c1 01             	add    $0x1,%ecx
  8008b0:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b3:	0f b6 01             	movzbl (%ecx),%eax
  8008b6:	84 c0                	test   %al,%al
  8008b8:	74 0e                	je     8008c8 <strncmp+0x41>
  8008ba:	3a 03                	cmp    (%ebx),%al
  8008bc:	74 ea                	je     8008a8 <strncmp+0x21>
  8008be:	eb 08                	jmp    8008c8 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c5:	5b                   	pop    %ebx
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c8:	0f b6 01             	movzbl (%ecx),%eax
  8008cb:	0f b6 13             	movzbl (%ebx),%edx
  8008ce:	29 d0                	sub    %edx,%eax
  8008d0:	eb f3                	jmp    8008c5 <strncmp+0x3e>

008008d2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008dc:	0f b6 10             	movzbl (%eax),%edx
  8008df:	84 d2                	test   %dl,%dl
  8008e1:	74 20                	je     800903 <strchr+0x31>
		if (*s == c)
  8008e3:	38 ca                	cmp    %cl,%dl
  8008e5:	75 0b                	jne    8008f2 <strchr+0x20>
  8008e7:	eb 1f                	jmp    800908 <strchr+0x36>
  8008e9:	38 ca                	cmp    %cl,%dl
  8008eb:	90                   	nop
  8008ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8008f0:	74 16                	je     800908 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	0f b6 10             	movzbl (%eax),%edx
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	75 ed                	jne    8008e9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800901:	eb 05                	jmp    800908 <strchr+0x36>
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800914:	0f b6 10             	movzbl (%eax),%edx
  800917:	84 d2                	test   %dl,%dl
  800919:	74 14                	je     80092f <strfind+0x25>
		if (*s == c)
  80091b:	38 ca                	cmp    %cl,%dl
  80091d:	75 06                	jne    800925 <strfind+0x1b>
  80091f:	eb 0e                	jmp    80092f <strfind+0x25>
  800921:	38 ca                	cmp    %cl,%dl
  800923:	74 0a                	je     80092f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800925:	83 c0 01             	add    $0x1,%eax
  800928:	0f b6 10             	movzbl (%eax),%edx
  80092b:	84 d2                	test   %dl,%dl
  80092d:	75 f2                	jne    800921 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	83 ec 0c             	sub    $0xc,%esp
  800937:	89 1c 24             	mov    %ebx,(%esp)
  80093a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80093e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800942:	8b 7d 08             	mov    0x8(%ebp),%edi
  800945:	8b 45 0c             	mov    0xc(%ebp),%eax
  800948:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094b:	85 c9                	test   %ecx,%ecx
  80094d:	74 30                	je     80097f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800955:	75 25                	jne    80097c <memset+0x4b>
  800957:	f6 c1 03             	test   $0x3,%cl
  80095a:	75 20                	jne    80097c <memset+0x4b>
		c &= 0xFF;
  80095c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095f:	89 d3                	mov    %edx,%ebx
  800961:	c1 e3 08             	shl    $0x8,%ebx
  800964:	89 d6                	mov    %edx,%esi
  800966:	c1 e6 18             	shl    $0x18,%esi
  800969:	89 d0                	mov    %edx,%eax
  80096b:	c1 e0 10             	shl    $0x10,%eax
  80096e:	09 f0                	or     %esi,%eax
  800970:	09 d0                	or     %edx,%eax
  800972:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800974:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800977:	fc                   	cld    
  800978:	f3 ab                	rep stos %eax,%es:(%edi)
  80097a:	eb 03                	jmp    80097f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097c:	fc                   	cld    
  80097d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097f:	89 f8                	mov    %edi,%eax
  800981:	8b 1c 24             	mov    (%esp),%ebx
  800984:	8b 74 24 04          	mov    0x4(%esp),%esi
  800988:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80098c:	89 ec                	mov    %ebp,%esp
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	83 ec 08             	sub    $0x8,%esp
  800996:	89 34 24             	mov    %esi,(%esp)
  800999:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a6:	39 c6                	cmp    %eax,%esi
  8009a8:	73 36                	jae    8009e0 <memmove+0x50>
  8009aa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ad:	39 d0                	cmp    %edx,%eax
  8009af:	73 2f                	jae    8009e0 <memmove+0x50>
		s += n;
		d += n;
  8009b1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b4:	f6 c2 03             	test   $0x3,%dl
  8009b7:	75 1b                	jne    8009d4 <memmove+0x44>
  8009b9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bf:	75 13                	jne    8009d4 <memmove+0x44>
  8009c1:	f6 c1 03             	test   $0x3,%cl
  8009c4:	75 0e                	jne    8009d4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c6:	83 ef 04             	sub    $0x4,%edi
  8009c9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009cf:	fd                   	std    
  8009d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d2:	eb 09                	jmp    8009dd <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d4:	83 ef 01             	sub    $0x1,%edi
  8009d7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009da:	fd                   	std    
  8009db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009dd:	fc                   	cld    
  8009de:	eb 20                	jmp    800a00 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e6:	75 13                	jne    8009fb <memmove+0x6b>
  8009e8:	a8 03                	test   $0x3,%al
  8009ea:	75 0f                	jne    8009fb <memmove+0x6b>
  8009ec:	f6 c1 03             	test   $0x3,%cl
  8009ef:	75 0a                	jne    8009fb <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009f4:	89 c7                	mov    %eax,%edi
  8009f6:	fc                   	cld    
  8009f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f9:	eb 05                	jmp    800a00 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009fb:	89 c7                	mov    %eax,%edi
  8009fd:	fc                   	cld    
  8009fe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a00:	8b 34 24             	mov    (%esp),%esi
  800a03:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a07:	89 ec                	mov    %ebp,%esp
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a11:	8b 45 10             	mov    0x10(%ebp),%eax
  800a14:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	89 04 24             	mov    %eax,(%esp)
  800a25:	e8 66 ff ff ff       	call   800990 <memmove>
}
  800a2a:	c9                   	leave  
  800a2b:	c3                   	ret    

00800a2c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
  800a32:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a38:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a40:	85 ff                	test   %edi,%edi
  800a42:	74 38                	je     800a7c <memcmp+0x50>
		if (*s1 != *s2)
  800a44:	0f b6 03             	movzbl (%ebx),%eax
  800a47:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4a:	83 ef 01             	sub    $0x1,%edi
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a52:	38 c8                	cmp    %cl,%al
  800a54:	74 1d                	je     800a73 <memcmp+0x47>
  800a56:	eb 11                	jmp    800a69 <memcmp+0x3d>
  800a58:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a5d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800a62:	83 c2 01             	add    $0x1,%edx
  800a65:	38 c8                	cmp    %cl,%al
  800a67:	74 0a                	je     800a73 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800a69:	0f b6 c0             	movzbl %al,%eax
  800a6c:	0f b6 c9             	movzbl %cl,%ecx
  800a6f:	29 c8                	sub    %ecx,%eax
  800a71:	eb 09                	jmp    800a7c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a73:	39 fa                	cmp    %edi,%edx
  800a75:	75 e1                	jne    800a58 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a87:	89 c2                	mov    %eax,%edx
  800a89:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a8c:	39 d0                	cmp    %edx,%eax
  800a8e:	73 15                	jae    800aa5 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a94:	38 08                	cmp    %cl,(%eax)
  800a96:	75 06                	jne    800a9e <memfind+0x1d>
  800a98:	eb 0b                	jmp    800aa5 <memfind+0x24>
  800a9a:	38 08                	cmp    %cl,(%eax)
  800a9c:	74 07                	je     800aa5 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a9e:	83 c0 01             	add    $0x1,%eax
  800aa1:	39 c2                	cmp    %eax,%edx
  800aa3:	77 f5                	ja     800a9a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	57                   	push   %edi
  800aab:	56                   	push   %esi
  800aac:	53                   	push   %ebx
  800aad:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab3:	0f b6 02             	movzbl (%edx),%eax
  800ab6:	3c 20                	cmp    $0x20,%al
  800ab8:	74 04                	je     800abe <strtol+0x17>
  800aba:	3c 09                	cmp    $0x9,%al
  800abc:	75 0e                	jne    800acc <strtol+0x25>
		s++;
  800abe:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac1:	0f b6 02             	movzbl (%edx),%eax
  800ac4:	3c 20                	cmp    $0x20,%al
  800ac6:	74 f6                	je     800abe <strtol+0x17>
  800ac8:	3c 09                	cmp    $0x9,%al
  800aca:	74 f2                	je     800abe <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800acc:	3c 2b                	cmp    $0x2b,%al
  800ace:	75 0a                	jne    800ada <strtol+0x33>
		s++;
  800ad0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad8:	eb 10                	jmp    800aea <strtol+0x43>
  800ada:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800adf:	3c 2d                	cmp    $0x2d,%al
  800ae1:	75 07                	jne    800aea <strtol+0x43>
		s++, neg = 1;
  800ae3:	83 c2 01             	add    $0x1,%edx
  800ae6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aea:	85 db                	test   %ebx,%ebx
  800aec:	0f 94 c0             	sete   %al
  800aef:	74 05                	je     800af6 <strtol+0x4f>
  800af1:	83 fb 10             	cmp    $0x10,%ebx
  800af4:	75 15                	jne    800b0b <strtol+0x64>
  800af6:	80 3a 30             	cmpb   $0x30,(%edx)
  800af9:	75 10                	jne    800b0b <strtol+0x64>
  800afb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aff:	75 0a                	jne    800b0b <strtol+0x64>
		s += 2, base = 16;
  800b01:	83 c2 02             	add    $0x2,%edx
  800b04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b09:	eb 13                	jmp    800b1e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800b0b:	84 c0                	test   %al,%al
  800b0d:	74 0f                	je     800b1e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b0f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b14:	80 3a 30             	cmpb   $0x30,(%edx)
  800b17:	75 05                	jne    800b1e <strtol+0x77>
		s++, base = 8;
  800b19:	83 c2 01             	add    $0x1,%edx
  800b1c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b23:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b25:	0f b6 0a             	movzbl (%edx),%ecx
  800b28:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b2b:	80 fb 09             	cmp    $0x9,%bl
  800b2e:	77 08                	ja     800b38 <strtol+0x91>
			dig = *s - '0';
  800b30:	0f be c9             	movsbl %cl,%ecx
  800b33:	83 e9 30             	sub    $0x30,%ecx
  800b36:	eb 1e                	jmp    800b56 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b38:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b3b:	80 fb 19             	cmp    $0x19,%bl
  800b3e:	77 08                	ja     800b48 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b40:	0f be c9             	movsbl %cl,%ecx
  800b43:	83 e9 57             	sub    $0x57,%ecx
  800b46:	eb 0e                	jmp    800b56 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b48:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b4b:	80 fb 19             	cmp    $0x19,%bl
  800b4e:	77 15                	ja     800b65 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800b50:	0f be c9             	movsbl %cl,%ecx
  800b53:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b56:	39 f1                	cmp    %esi,%ecx
  800b58:	7d 0f                	jge    800b69 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800b5a:	83 c2 01             	add    $0x1,%edx
  800b5d:	0f af c6             	imul   %esi,%eax
  800b60:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b63:	eb c0                	jmp    800b25 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b65:	89 c1                	mov    %eax,%ecx
  800b67:	eb 02                	jmp    800b6b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b69:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6f:	74 05                	je     800b76 <strtol+0xcf>
		*endptr = (char *) s;
  800b71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b74:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b76:	89 ca                	mov    %ecx,%edx
  800b78:	f7 da                	neg    %edx
  800b7a:	85 ff                	test   %edi,%edi
  800b7c:	0f 45 c2             	cmovne %edx,%eax
}
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	89 1c 24             	mov    %ebx,(%esp)
  800b8d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b91:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba0:	89 c3                	mov    %eax,%ebx
  800ba2:	89 c7                	mov    %eax,%edi
  800ba4:	89 c6                	mov    %eax,%esi
  800ba6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba8:	8b 1c 24             	mov    (%esp),%ebx
  800bab:	8b 74 24 04          	mov    0x4(%esp),%esi
  800baf:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bb3:	89 ec                	mov    %ebp,%esp
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	83 ec 0c             	sub    $0xc,%esp
  800bbd:	89 1c 24             	mov    %ebx,(%esp)
  800bc0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bc4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcd:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd2:	89 d1                	mov    %edx,%ecx
  800bd4:	89 d3                	mov    %edx,%ebx
  800bd6:	89 d7                	mov    %edx,%edi
  800bd8:	89 d6                	mov    %edx,%esi
  800bda:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bdc:	8b 1c 24             	mov    (%esp),%ebx
  800bdf:	8b 74 24 04          	mov    0x4(%esp),%esi
  800be3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800be7:	89 ec                	mov    %ebp,%esp
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	83 ec 38             	sub    $0x38,%esp
  800bf1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bf4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bf7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bff:	b8 03 00 00 00       	mov    $0x3,%eax
  800c04:	8b 55 08             	mov    0x8(%ebp),%edx
  800c07:	89 cb                	mov    %ecx,%ebx
  800c09:	89 cf                	mov    %ecx,%edi
  800c0b:	89 ce                	mov    %ecx,%esi
  800c0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	7e 28                	jle    800c3b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c17:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c1e:	00 
  800c1f:	c7 44 24 08 64 14 80 	movl   $0x801464,0x8(%esp)
  800c26:	00 
  800c27:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2e:	00 
  800c2f:	c7 04 24 81 14 80 00 	movl   $0x801481,(%esp)
  800c36:	e8 e1 02 00 00       	call   800f1c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c3e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c41:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c44:	89 ec                	mov    %ebp,%esp
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	83 ec 0c             	sub    $0xc,%esp
  800c4e:	89 1c 24             	mov    %ebx,(%esp)
  800c51:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c55:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c59:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c63:	89 d1                	mov    %edx,%ecx
  800c65:	89 d3                	mov    %edx,%ebx
  800c67:	89 d7                	mov    %edx,%edi
  800c69:	89 d6                	mov    %edx,%esi
  800c6b:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800c6d:	8b 1c 24             	mov    (%esp),%ebx
  800c70:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c74:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c78:	89 ec                	mov    %ebp,%esp
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_yield>:

void
sys_yield(void)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	89 1c 24             	mov    %ebx,(%esp)
  800c85:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c89:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	89 d3                	mov    %edx,%ebx
  800c9b:	89 d7                	mov    %edx,%edi
  800c9d:	89 d6                	mov    %edx,%esi
  800c9f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca1:	8b 1c 24             	mov    (%esp),%ebx
  800ca4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ca8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cac:	89 ec                	mov    %ebp,%esp
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 38             	sub    $0x38,%esp
  800cb6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cb9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cbc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	be 00 00 00 00       	mov    $0x0,%esi
  800cc4:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	89 f7                	mov    %esi,%edi
  800cd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 28                	jle    800d02 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cde:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ce5:	00 
  800ce6:	c7 44 24 08 64 14 80 	movl   $0x801464,0x8(%esp)
  800ced:	00 
  800cee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf5:	00 
  800cf6:	c7 04 24 81 14 80 00 	movl   $0x801481,(%esp)
  800cfd:	e8 1a 02 00 00       	call   800f1c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d0b:	89 ec                	mov    %ebp,%esp
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	83 ec 38             	sub    $0x38,%esp
  800d15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d23:	8b 75 18             	mov    0x18(%ebp),%esi
  800d26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d34:	85 c0                	test   %eax,%eax
  800d36:	7e 28                	jle    800d60 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d43:	00 
  800d44:	c7 44 24 08 64 14 80 	movl   $0x801464,0x8(%esp)
  800d4b:	00 
  800d4c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d53:	00 
  800d54:	c7 04 24 81 14 80 00 	movl   $0x801481,(%esp)
  800d5b:	e8 bc 01 00 00       	call   800f1c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d60:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d63:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d66:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d69:	89 ec                	mov    %ebp,%esp
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	83 ec 38             	sub    $0x38,%esp
  800d73:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d76:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d79:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d81:	b8 06 00 00 00       	mov    $0x6,%eax
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	89 df                	mov    %ebx,%edi
  800d8e:	89 de                	mov    %ebx,%esi
  800d90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7e 28                	jle    800dbe <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800da1:	00 
  800da2:	c7 44 24 08 64 14 80 	movl   $0x801464,0x8(%esp)
  800da9:	00 
  800daa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db1:	00 
  800db2:	c7 04 24 81 14 80 00 	movl   $0x801481,(%esp)
  800db9:	e8 5e 01 00 00       	call   800f1c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dbe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dc4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dc7:	89 ec                	mov    %ebp,%esp
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	83 ec 38             	sub    $0x38,%esp
  800dd1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dd7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddf:	b8 08 00 00 00       	mov    $0x8,%eax
  800de4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dea:	89 df                	mov    %ebx,%edi
  800dec:	89 de                	mov    %ebx,%esi
  800dee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df0:	85 c0                	test   %eax,%eax
  800df2:	7e 28                	jle    800e1c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df8:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dff:	00 
  800e00:	c7 44 24 08 64 14 80 	movl   $0x801464,0x8(%esp)
  800e07:	00 
  800e08:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0f:	00 
  800e10:	c7 04 24 81 14 80 00 	movl   $0x801481,(%esp)
  800e17:	e8 00 01 00 00       	call   800f1c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e1c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e1f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e22:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e25:	89 ec                	mov    %ebp,%esp
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 38             	sub    $0x38,%esp
  800e2f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e32:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e35:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	89 df                	mov    %ebx,%edi
  800e4a:	89 de                	mov    %ebx,%esi
  800e4c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	7e 28                	jle    800e7a <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e52:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e56:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e5d:	00 
  800e5e:	c7 44 24 08 64 14 80 	movl   $0x801464,0x8(%esp)
  800e65:	00 
  800e66:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6d:	00 
  800e6e:	c7 04 24 81 14 80 00 	movl   $0x801481,(%esp)
  800e75:	e8 a2 00 00 00       	call   800f1c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e7d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e80:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e83:	89 ec                	mov    %ebp,%esp
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    

00800e87 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	89 1c 24             	mov    %ebx,(%esp)
  800e90:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e94:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e98:	be 00 00 00 00       	mov    $0x0,%esi
  800e9d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ea2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eab:	8b 55 08             	mov    0x8(%ebp),%edx
  800eae:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eb0:	8b 1c 24             	mov    (%esp),%ebx
  800eb3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eb7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ebb:	89 ec                	mov    %ebp,%esp
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	83 ec 38             	sub    $0x38,%esp
  800ec5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ecb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ece:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ed8:	8b 55 08             	mov    0x8(%ebp),%edx
  800edb:	89 cb                	mov    %ecx,%ebx
  800edd:	89 cf                	mov    %ecx,%edi
  800edf:	89 ce                	mov    %ecx,%esi
  800ee1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	7e 28                	jle    800f0f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eeb:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ef2:	00 
  800ef3:	c7 44 24 08 64 14 80 	movl   $0x801464,0x8(%esp)
  800efa:	00 
  800efb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f02:	00 
  800f03:	c7 04 24 81 14 80 00 	movl   $0x801481,(%esp)
  800f0a:	e8 0d 00 00 00       	call   800f1c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f18:	89 ec                	mov    %ebp,%esp
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	56                   	push   %esi
  800f20:	53                   	push   %ebx
  800f21:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800f24:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f27:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f2d:	e8 16 fd ff ff       	call   800c48 <sys_getenvid>
  800f32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f35:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f39:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f40:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f48:	c7 04 24 90 14 80 00 	movl   $0x801490,(%esp)
  800f4f:	e8 2b f2 ff ff       	call   80017f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f54:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f58:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5b:	89 04 24             	mov    %eax,(%esp)
  800f5e:	e8 bb f1 ff ff       	call   80011e <vcprintf>
	cprintf("\n");
  800f63:	c7 04 24 ec 11 80 00 	movl   $0x8011ec,(%esp)
  800f6a:	e8 10 f2 ff ff       	call   80017f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f6f:	cc                   	int3   
  800f70:	eb fd                	jmp    800f6f <_panic+0x53>
	...

00800f80 <__udivdi3>:
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	57                   	push   %edi
  800f84:	56                   	push   %esi
  800f85:	83 ec 10             	sub    $0x10,%esp
  800f88:	8b 75 14             	mov    0x14(%ebp),%esi
  800f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f91:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f94:	85 f6                	test   %esi,%esi
  800f96:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f99:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f9f:	75 2f                	jne    800fd0 <__udivdi3+0x50>
  800fa1:	39 f9                	cmp    %edi,%ecx
  800fa3:	77 5b                	ja     801000 <__udivdi3+0x80>
  800fa5:	85 c9                	test   %ecx,%ecx
  800fa7:	75 0b                	jne    800fb4 <__udivdi3+0x34>
  800fa9:	b8 01 00 00 00       	mov    $0x1,%eax
  800fae:	31 d2                	xor    %edx,%edx
  800fb0:	f7 f1                	div    %ecx
  800fb2:	89 c1                	mov    %eax,%ecx
  800fb4:	89 f8                	mov    %edi,%eax
  800fb6:	31 d2                	xor    %edx,%edx
  800fb8:	f7 f1                	div    %ecx
  800fba:	89 c7                	mov    %eax,%edi
  800fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fbf:	f7 f1                	div    %ecx
  800fc1:	89 fa                	mov    %edi,%edx
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    
  800fca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fd0:	31 d2                	xor    %edx,%edx
  800fd2:	31 c0                	xor    %eax,%eax
  800fd4:	39 fe                	cmp    %edi,%esi
  800fd6:	77 eb                	ja     800fc3 <__udivdi3+0x43>
  800fd8:	0f bd d6             	bsr    %esi,%edx
  800fdb:	83 f2 1f             	xor    $0x1f,%edx
  800fde:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fe1:	75 2d                	jne    801010 <__udivdi3+0x90>
  800fe3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800fe6:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  800fe9:	76 06                	jbe    800ff1 <__udivdi3+0x71>
  800feb:	39 fe                	cmp    %edi,%esi
  800fed:	89 c2                	mov    %eax,%edx
  800fef:	73 d2                	jae    800fc3 <__udivdi3+0x43>
  800ff1:	31 d2                	xor    %edx,%edx
  800ff3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff8:	eb c9                	jmp    800fc3 <__udivdi3+0x43>
  800ffa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801000:	89 fa                	mov    %edi,%edx
  801002:	f7 f1                	div    %ecx
  801004:	31 d2                	xor    %edx,%edx
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801014:	b8 20 00 00 00       	mov    $0x20,%eax
  801019:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80101c:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80101f:	d3 e6                	shl    %cl,%esi
  801021:	89 c1                	mov    %eax,%ecx
  801023:	d3 ea                	shr    %cl,%edx
  801025:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801029:	09 f2                	or     %esi,%edx
  80102b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  80102e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801031:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801034:	d3 e2                	shl    %cl,%edx
  801036:	89 c1                	mov    %eax,%ecx
  801038:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80103b:	89 fa                	mov    %edi,%edx
  80103d:	d3 ea                	shr    %cl,%edx
  80103f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801043:	d3 e7                	shl    %cl,%edi
  801045:	89 c1                	mov    %eax,%ecx
  801047:	d3 ee                	shr    %cl,%esi
  801049:	09 fe                	or     %edi,%esi
  80104b:	89 f0                	mov    %esi,%eax
  80104d:	f7 75 e8             	divl   -0x18(%ebp)
  801050:	89 d7                	mov    %edx,%edi
  801052:	89 c6                	mov    %eax,%esi
  801054:	f7 65 f0             	mull   -0x10(%ebp)
  801057:	39 d7                	cmp    %edx,%edi
  801059:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80105c:	72 22                	jb     801080 <__udivdi3+0x100>
  80105e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801061:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801065:	d3 e2                	shl    %cl,%edx
  801067:	39 c2                	cmp    %eax,%edx
  801069:	73 05                	jae    801070 <__udivdi3+0xf0>
  80106b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80106e:	74 10                	je     801080 <__udivdi3+0x100>
  801070:	89 f0                	mov    %esi,%eax
  801072:	31 d2                	xor    %edx,%edx
  801074:	e9 4a ff ff ff       	jmp    800fc3 <__udivdi3+0x43>
  801079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801080:	8d 46 ff             	lea    -0x1(%esi),%eax
  801083:	31 d2                	xor    %edx,%edx
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	5e                   	pop    %esi
  801089:	5f                   	pop    %edi
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    
  80108c:	00 00                	add    %al,(%eax)
	...

00801090 <__umoddi3>:
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	83 ec 20             	sub    $0x20,%esp
  801098:	8b 7d 14             	mov    0x14(%ebp),%edi
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
  80109e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010a4:	85 ff                	test   %edi,%edi
  8010a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8010a9:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8010ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8010af:	89 f2                	mov    %esi,%edx
  8010b1:	75 15                	jne    8010c8 <__umoddi3+0x38>
  8010b3:	39 f1                	cmp    %esi,%ecx
  8010b5:	76 41                	jbe    8010f8 <__umoddi3+0x68>
  8010b7:	f7 f1                	div    %ecx
  8010b9:	89 d0                	mov    %edx,%eax
  8010bb:	31 d2                	xor    %edx,%edx
  8010bd:	83 c4 20             	add    $0x20,%esp
  8010c0:	5e                   	pop    %esi
  8010c1:	5f                   	pop    %edi
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    
  8010c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	39 f7                	cmp    %esi,%edi
  8010ca:	77 4c                	ja     801118 <__umoddi3+0x88>
  8010cc:	0f bd c7             	bsr    %edi,%eax
  8010cf:	83 f0 1f             	xor    $0x1f,%eax
  8010d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010d5:	75 51                	jne    801128 <__umoddi3+0x98>
  8010d7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8010da:	0f 87 e8 00 00 00    	ja     8011c8 <__umoddi3+0x138>
  8010e0:	89 f2                	mov    %esi,%edx
  8010e2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8010e5:	29 ce                	sub    %ecx,%esi
  8010e7:	19 fa                	sbb    %edi,%edx
  8010e9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8010ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ef:	83 c4 20             	add    $0x20,%esp
  8010f2:	5e                   	pop    %esi
  8010f3:	5f                   	pop    %edi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    
  8010f6:	66 90                	xchg   %ax,%ax
  8010f8:	85 c9                	test   %ecx,%ecx
  8010fa:	75 0b                	jne    801107 <__umoddi3+0x77>
  8010fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801101:	31 d2                	xor    %edx,%edx
  801103:	f7 f1                	div    %ecx
  801105:	89 c1                	mov    %eax,%ecx
  801107:	89 f0                	mov    %esi,%eax
  801109:	31 d2                	xor    %edx,%edx
  80110b:	f7 f1                	div    %ecx
  80110d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801110:	eb a5                	jmp    8010b7 <__umoddi3+0x27>
  801112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801118:	89 f2                	mov    %esi,%edx
  80111a:	83 c4 20             	add    $0x20,%esp
  80111d:	5e                   	pop    %esi
  80111e:	5f                   	pop    %edi
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    
  801121:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801128:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80112c:	89 f2                	mov    %esi,%edx
  80112e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801131:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801138:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80113b:	d3 e7                	shl    %cl,%edi
  80113d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801140:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801144:	d3 e8                	shr    %cl,%eax
  801146:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80114a:	09 f8                	or     %edi,%eax
  80114c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80114f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801152:	d3 e0                	shl    %cl,%eax
  801154:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801158:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80115b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80115e:	d3 ea                	shr    %cl,%edx
  801160:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801164:	d3 e6                	shl    %cl,%esi
  801166:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80116a:	d3 e8                	shr    %cl,%eax
  80116c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801170:	09 f0                	or     %esi,%eax
  801172:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801175:	f7 75 e4             	divl   -0x1c(%ebp)
  801178:	d3 e6                	shl    %cl,%esi
  80117a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80117d:	89 d6                	mov    %edx,%esi
  80117f:	f7 65 f4             	mull   -0xc(%ebp)
  801182:	89 d7                	mov    %edx,%edi
  801184:	89 c2                	mov    %eax,%edx
  801186:	39 fe                	cmp    %edi,%esi
  801188:	89 f9                	mov    %edi,%ecx
  80118a:	72 30                	jb     8011bc <__umoddi3+0x12c>
  80118c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80118f:	72 27                	jb     8011b8 <__umoddi3+0x128>
  801191:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801194:	29 d0                	sub    %edx,%eax
  801196:	19 ce                	sbb    %ecx,%esi
  801198:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80119c:	89 f2                	mov    %esi,%edx
  80119e:	d3 e8                	shr    %cl,%eax
  8011a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011a4:	d3 e2                	shl    %cl,%edx
  8011a6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011aa:	09 d0                	or     %edx,%eax
  8011ac:	89 f2                	mov    %esi,%edx
  8011ae:	d3 ea                	shr    %cl,%edx
  8011b0:	83 c4 20             	add    $0x20,%esp
  8011b3:	5e                   	pop    %esi
  8011b4:	5f                   	pop    %edi
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    
  8011b7:	90                   	nop
  8011b8:	39 fe                	cmp    %edi,%esi
  8011ba:	75 d5                	jne    801191 <__umoddi3+0x101>
  8011bc:	89 f9                	mov    %edi,%ecx
  8011be:	89 c2                	mov    %eax,%edx
  8011c0:	2b 55 f4             	sub    -0xc(%ebp),%edx
  8011c3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011c6:	eb c9                	jmp    801191 <__umoddi3+0x101>
  8011c8:	39 f7                	cmp    %esi,%edi
  8011ca:	0f 82 10 ff ff ff    	jb     8010e0 <__umoddi3+0x50>
  8011d0:	e9 17 ff ff ff       	jmp    8010ec <__umoddi3+0x5c>
