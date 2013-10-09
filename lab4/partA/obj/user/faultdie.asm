
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800049:	8b 50 04             	mov    0x4(%eax),%edx
  80004c:	83 e2 07             	and    $0x7,%edx
  80004f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800053:	8b 00                	mov    (%eax),%eax
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 40 12 80 00 	movl   $0x801240,(%esp)
  800060:	e8 36 01 00 00       	call   80019b <cprintf>
	sys_env_destroy(sys_getenvid());
  800065:	e8 fe 0b 00 00       	call   800c68 <sys_getenvid>
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 99 0b 00 00       	call   800c0b <sys_env_destroy>
}
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <umain>:

void
umain(int argc, char **argv)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80007a:	c7 04 24 40 00 80 00 	movl   $0x800040,(%esp)
  800081:	e8 b6 0e 00 00       	call   800f3c <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800086:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  80008d:	00 00 00 
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
  80009a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80009d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  8000a6:	e8 bd 0b 00 00       	call   800c68 <sys_getenvid>
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b8:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bd:	85 f6                	test   %esi,%esi
  8000bf:	7e 07                	jle    8000c8 <libmain+0x34>
		binaryname = argv[0];
  8000c1:	8b 03                	mov    (%ebx),%eax
  8000c3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cc:	89 34 24             	mov    %esi,(%esp)
  8000cf:	e8 a0 ff ff ff       	call   800074 <umain>

	// exit gracefully
	exit();
  8000d4:	e8 0b 00 00 00       	call   8000e4 <exit>
}
  8000d9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000dc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000df:	89 ec                	mov    %ebp,%esp
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    
	...

008000e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f1:	e8 15 0b 00 00       	call   800c0b <sys_env_destroy>
}
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 14             	sub    $0x14,%esp
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800102:	8b 03                	mov    (%ebx),%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80010b:	83 c0 01             	add    $0x1,%eax
  80010e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800110:	3d ff 00 00 00       	cmp    $0xff,%eax
  800115:	75 19                	jne    800130 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800117:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80011e:	00 
  80011f:	8d 43 08             	lea    0x8(%ebx),%eax
  800122:	89 04 24             	mov    %eax,(%esp)
  800125:	e8 7a 0a 00 00       	call   800ba4 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800130:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800134:	83 c4 14             	add    $0x14,%esp
  800137:	5b                   	pop    %ebx
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800143:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014a:	00 00 00 
	b.cnt = 0;
  80014d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800154:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800157:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015e:	8b 45 08             	mov    0x8(%ebp),%eax
  800161:	89 44 24 08          	mov    %eax,0x8(%esp)
  800165:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016f:	c7 04 24 f8 00 80 00 	movl   $0x8000f8,(%esp)
  800176:	e8 e6 01 00 00       	call   800361 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018b:	89 04 24             	mov    %eax,(%esp)
  80018e:	e8 11 0a 00 00       	call   800ba4 <sys_cputs>

	return b.cnt;
}
  800193:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	e8 87 ff ff ff       	call   80013a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
	...

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 4c             	sub    $0x4c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d6                	mov    %edx,%esi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001dd:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	39 d0                	cmp    %edx,%eax
  8001e7:	72 11                	jb     8001fa <printnum+0x3a>
  8001e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001ec:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8001ef:	76 09                	jbe    8001fa <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f1:	83 eb 01             	sub    $0x1,%ebx
  8001f4:	85 db                	test   %ebx,%ebx
  8001f6:	7f 5d                	jg     800255 <printnum+0x95>
  8001f8:	eb 6c                	jmp    800266 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fa:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001fe:	83 eb 01             	sub    $0x1,%ebx
  800201:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800205:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800208:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80020c:	8b 44 24 08          	mov    0x8(%esp),%eax
  800210:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800214:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800217:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80021a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800221:	00 
  800222:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800225:	89 14 24             	mov    %edx,(%esp)
  800228:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80022b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80022f:	e8 9c 0d 00 00       	call   800fd0 <__udivdi3>
  800234:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800237:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80023a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80023e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	89 54 24 04          	mov    %edx,0x4(%esp)
  800249:	89 f2                	mov    %esi,%edx
  80024b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024e:	e8 6d ff ff ff       	call   8001c0 <printnum>
  800253:	eb 11                	jmp    800266 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800255:	89 74 24 04          	mov    %esi,0x4(%esp)
  800259:	89 3c 24             	mov    %edi,(%esp)
  80025c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025f:	83 eb 01             	sub    $0x1,%ebx
  800262:	85 db                	test   %ebx,%ebx
  800264:	7f ef                	jg     800255 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800266:	89 74 24 04          	mov    %esi,0x4(%esp)
  80026a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80026e:	8b 45 10             	mov    0x10(%ebp),%eax
  800271:	89 44 24 08          	mov    %eax,0x8(%esp)
  800275:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027c:	00 
  80027d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800280:	89 14 24             	mov    %edx,(%esp)
  800283:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800286:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80028a:	e8 51 0e 00 00       	call   8010e0 <__umoddi3>
  80028f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800293:	0f be 80 66 12 80 00 	movsbl 0x801266(%eax),%eax
  80029a:	89 04 24             	mov    %eax,(%esp)
  80029d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002a0:	83 c4 4c             	add    $0x4c,%esp
  8002a3:	5b                   	pop    %ebx
  8002a4:	5e                   	pop    %esi
  8002a5:	5f                   	pop    %edi
  8002a6:	5d                   	pop    %ebp
  8002a7:	c3                   	ret    

008002a8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ab:	83 fa 01             	cmp    $0x1,%edx
  8002ae:	7e 0e                	jle    8002be <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	8b 52 04             	mov    0x4(%edx),%edx
  8002bc:	eb 22                	jmp    8002e0 <getuint+0x38>
	else if (lflag)
  8002be:	85 d2                	test   %edx,%edx
  8002c0:	74 10                	je     8002d2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d0:	eb 0e                	jmp    8002e0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 02                	mov    (%edx),%eax
  8002db:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e5:	83 fa 01             	cmp    $0x1,%edx
  8002e8:	7e 0e                	jle    8002f8 <getint+0x16>
		return va_arg(*ap, long long);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	8b 52 04             	mov    0x4(%edx),%edx
  8002f6:	eb 22                	jmp    80031a <getint+0x38>
	else if (lflag)
  8002f8:	85 d2                	test   %edx,%edx
  8002fa:	74 10                	je     80030c <getint+0x2a>
		return va_arg(*ap, long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	89 c2                	mov    %eax,%edx
  800307:	c1 fa 1f             	sar    $0x1f,%edx
  80030a:	eb 0e                	jmp    80031a <getint+0x38>
	else
		return va_arg(*ap, int);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	89 c2                	mov    %eax,%edx
  800317:	c1 fa 1f             	sar    $0x1f,%edx
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800322:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800326:	8b 10                	mov    (%eax),%edx
  800328:	3b 50 04             	cmp    0x4(%eax),%edx
  80032b:	73 0a                	jae    800337 <sprintputch+0x1b>
		*b->buf++ = ch;
  80032d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800330:	88 0a                	mov    %cl,(%edx)
  800332:	83 c2 01             	add    $0x1,%edx
  800335:	89 10                	mov    %edx,(%eax)
}
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80033f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800342:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800346:	8b 45 10             	mov    0x10(%ebp),%eax
  800349:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	8b 45 08             	mov    0x8(%ebp),%eax
  800357:	89 04 24             	mov    %eax,(%esp)
  80035a:	e8 02 00 00 00       	call   800361 <vprintfmt>
	va_end(ap);
}
  80035f:	c9                   	leave  
  800360:	c3                   	ret    

00800361 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	57                   	push   %edi
  800365:	56                   	push   %esi
  800366:	53                   	push   %ebx
  800367:	83 ec 4c             	sub    $0x4c,%esp
  80036a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036d:	eb 23                	jmp    800392 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80036f:	85 c0                	test   %eax,%eax
  800371:	75 12                	jne    800385 <vprintfmt+0x24>
				csa = 0x0700;
  800373:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80037a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80037d:	83 c4 4c             	add    $0x4c,%esp
  800380:	5b                   	pop    %ebx
  800381:	5e                   	pop    %esi
  800382:	5f                   	pop    %edi
  800383:	5d                   	pop    %ebp
  800384:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800385:	8b 55 0c             	mov    0xc(%ebp),%edx
  800388:	89 54 24 04          	mov    %edx,0x4(%esp)
  80038c:	89 04 24             	mov    %eax,(%esp)
  80038f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800392:	0f b6 07             	movzbl (%edi),%eax
  800395:	83 c7 01             	add    $0x1,%edi
  800398:	83 f8 25             	cmp    $0x25,%eax
  80039b:	75 d2                	jne    80036f <vprintfmt+0xe>
  80039d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003a1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003a8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8003ad:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003b4:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003b9:	be 00 00 00 00       	mov    $0x0,%esi
  8003be:	eb 14                	jmp    8003d4 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003c4:	eb 0e                	jmp    8003d4 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c6:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003ca:	eb 08                	jmp    8003d4 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003cf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	0f b6 07             	movzbl (%edi),%eax
  8003d7:	0f b6 c8             	movzbl %al,%ecx
  8003da:	83 c7 01             	add    $0x1,%edi
  8003dd:	83 e8 23             	sub    $0x23,%eax
  8003e0:	3c 55                	cmp    $0x55,%al
  8003e2:	0f 87 ed 02 00 00    	ja     8006d5 <vprintfmt+0x374>
  8003e8:	0f b6 c0             	movzbl %al,%eax
  8003eb:	ff 24 85 20 13 80 00 	jmp    *0x801320(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  8003f5:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003f8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003fb:	83 f9 09             	cmp    $0x9,%ecx
  8003fe:	77 3c                	ja     80043c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800400:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800403:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  800406:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  80040a:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80040d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800410:	83 f9 09             	cmp    $0x9,%ecx
  800413:	76 eb                	jbe    800400 <vprintfmt+0x9f>
  800415:	eb 25                	jmp    80043c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 48 04             	lea    0x4(%eax),%ecx
  80041d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800420:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  800422:	eb 18                	jmp    80043c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  800424:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800428:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80042b:	0f 48 c6             	cmovs  %esi,%eax
  80042e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800431:	eb a1                	jmp    8003d4 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  800433:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80043a:	eb 98                	jmp    8003d4 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  80043c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800440:	79 92                	jns    8003d4 <vprintfmt+0x73>
  800442:	eb 88                	jmp    8003cc <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800444:	83 c2 01             	add    $0x1,%edx
  800447:	eb 8b                	jmp    8003d4 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 50 04             	lea    0x4(%eax),%edx
  80044f:	89 55 14             	mov    %edx,0x14(%ebp)
  800452:	8b 55 0c             	mov    0xc(%ebp),%edx
  800455:	89 54 24 04          	mov    %edx,0x4(%esp)
  800459:	8b 00                	mov    (%eax),%eax
  80045b:	89 04 24             	mov    %eax,(%esp)
  80045e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800461:	e9 2c ff ff ff       	jmp    800392 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	89 c2                	mov    %eax,%edx
  800473:	c1 fa 1f             	sar    $0x1f,%edx
  800476:	31 d0                	xor    %edx,%eax
  800478:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047a:	83 f8 08             	cmp    $0x8,%eax
  80047d:	7f 0b                	jg     80048a <vprintfmt+0x129>
  80047f:	8b 14 85 80 14 80 00 	mov    0x801480(,%eax,4),%edx
  800486:	85 d2                	test   %edx,%edx
  800488:	75 23                	jne    8004ad <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80048a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048e:	c7 44 24 08 7e 12 80 	movl   $0x80127e,0x8(%esp)
  800495:	00 
  800496:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800499:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049d:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 91 fe ff ff       	call   800339 <printfmt>
  8004a8:	e9 e5 fe ff ff       	jmp    800392 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8004ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b1:	c7 44 24 08 87 12 80 	movl   $0x801287,0x8(%esp)
  8004b8:	00 
  8004b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004c3:	89 1c 24             	mov    %ebx,(%esp)
  8004c6:	e8 6e fe ff ff       	call   800339 <printfmt>
  8004cb:	e9 c2 fe ff ff       	jmp    800392 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8d 50 04             	lea    0x4(%eax),%edx
  8004df:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e2:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004e4:	85 f6                	test   %esi,%esi
  8004e6:	ba 77 12 80 00       	mov    $0x801277,%edx
  8004eb:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8004ee:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f2:	7e 06                	jle    8004fa <vprintfmt+0x199>
  8004f4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004f8:	75 13                	jne    80050d <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fa:	0f be 06             	movsbl (%esi),%eax
  8004fd:	83 c6 01             	add    $0x1,%esi
  800500:	85 c0                	test   %eax,%eax
  800502:	0f 85 a2 00 00 00    	jne    8005aa <vprintfmt+0x249>
  800508:	e9 92 00 00 00       	jmp    80059f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800511:	89 34 24             	mov    %esi,(%esp)
  800514:	e8 82 02 00 00       	call   80079b <strnlen>
  800519:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80051c:	29 c2                	sub    %eax,%edx
  80051e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800521:	85 d2                	test   %edx,%edx
  800523:	7e d5                	jle    8004fa <vprintfmt+0x199>
					putch(padc, putdat);
  800525:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800529:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80052c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80052f:	89 d3                	mov    %edx,%ebx
  800531:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800534:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800537:	89 c6                	mov    %eax,%esi
  800539:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053d:	89 34 24             	mov    %esi,(%esp)
  800540:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800543:	83 eb 01             	sub    $0x1,%ebx
  800546:	85 db                	test   %ebx,%ebx
  800548:	7f ef                	jg     800539 <vprintfmt+0x1d8>
  80054a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80054d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800550:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800553:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80055a:	eb 9e                	jmp    8004fa <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800560:	74 1b                	je     80057d <vprintfmt+0x21c>
  800562:	8d 50 e0             	lea    -0x20(%eax),%edx
  800565:	83 fa 5e             	cmp    $0x5e,%edx
  800568:	76 13                	jbe    80057d <vprintfmt+0x21c>
					putch('?', putdat);
  80056a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80056d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800571:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800578:	ff 55 08             	call   *0x8(%ebp)
  80057b:	eb 0d                	jmp    80058a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80057d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800580:	89 54 24 04          	mov    %edx,0x4(%esp)
  800584:	89 04 24             	mov    %eax,(%esp)
  800587:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058a:	83 ef 01             	sub    $0x1,%edi
  80058d:	0f be 06             	movsbl (%esi),%eax
  800590:	85 c0                	test   %eax,%eax
  800592:	74 05                	je     800599 <vprintfmt+0x238>
  800594:	83 c6 01             	add    $0x1,%esi
  800597:	eb 17                	jmp    8005b0 <vprintfmt+0x24f>
  800599:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80059c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a3:	7f 1c                	jg     8005c1 <vprintfmt+0x260>
  8005a5:	e9 e8 fd ff ff       	jmp    800392 <vprintfmt+0x31>
  8005aa:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8005ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b0:	85 db                	test   %ebx,%ebx
  8005b2:	78 a8                	js     80055c <vprintfmt+0x1fb>
  8005b4:	83 eb 01             	sub    $0x1,%ebx
  8005b7:	79 a3                	jns    80055c <vprintfmt+0x1fb>
  8005b9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005bc:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005bf:	eb de                	jmp    80059f <vprintfmt+0x23e>
  8005c1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005c7:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ce:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005d5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d7:	83 eb 01             	sub    $0x1,%ebx
  8005da:	85 db                	test   %ebx,%ebx
  8005dc:	7f ec                	jg     8005ca <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005e1:	e9 ac fd ff ff       	jmp    800392 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e9:	e8 f4 fc ff ff       	call   8002e2 <getint>
  8005ee:	89 c3                	mov    %eax,%ebx
  8005f0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005f2:	85 d2                	test   %edx,%edx
  8005f4:	78 0a                	js     800600 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005fb:	e9 87 00 00 00       	jmp    800687 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800600:	8b 45 0c             	mov    0xc(%ebp),%eax
  800603:	89 44 24 04          	mov    %eax,0x4(%esp)
  800607:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800611:	89 d8                	mov    %ebx,%eax
  800613:	89 f2                	mov    %esi,%edx
  800615:	f7 d8                	neg    %eax
  800617:	83 d2 00             	adc    $0x0,%edx
  80061a:	f7 da                	neg    %edx
			}
			base = 10;
  80061c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800621:	eb 64                	jmp    800687 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800623:	8d 45 14             	lea    0x14(%ebp),%eax
  800626:	e8 7d fc ff ff       	call   8002a8 <getuint>
			base = 10;
  80062b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800630:	eb 55                	jmp    800687 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800632:	8d 45 14             	lea    0x14(%ebp),%eax
  800635:	e8 6e fc ff ff       	call   8002a8 <getuint>
      base = 8;
  80063a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80063f:	eb 46                	jmp    800687 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800641:	8b 55 0c             	mov    0xc(%ebp),%edx
  800644:	89 54 24 04          	mov    %edx,0x4(%esp)
  800648:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80064f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800652:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800655:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800659:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800660:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8d 50 04             	lea    0x4(%eax),%edx
  800669:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066c:	8b 00                	mov    (%eax),%eax
  80066e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800673:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800678:	eb 0d                	jmp    800687 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067a:	8d 45 14             	lea    0x14(%ebp),%eax
  80067d:	e8 26 fc ff ff       	call   8002a8 <getuint>
			base = 16;
  800682:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800687:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80068b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80068f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800692:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800696:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80069a:	89 04 24             	mov    %eax,(%esp)
  80069d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	e8 14 fb ff ff       	call   8001c0 <printnum>
			break;
  8006ac:	e9 e1 fc ff ff       	jmp    800392 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b8:	89 0c 24             	mov    %ecx,(%esp)
  8006bb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006be:	e9 cf fc ff ff       	jmp    800392 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  8006c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c6:	e8 17 fc ff ff       	call   8002e2 <getint>
			csa = num;
  8006cb:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  8006d0:	e9 bd fc ff ff       	jmp    800392 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006d8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006e3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e6:	83 ef 01             	sub    $0x1,%edi
  8006e9:	eb 02                	jmp    8006ed <vprintfmt+0x38c>
  8006eb:	89 c7                	mov    %eax,%edi
  8006ed:	8d 47 ff             	lea    -0x1(%edi),%eax
  8006f0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f4:	75 f5                	jne    8006eb <vprintfmt+0x38a>
  8006f6:	e9 97 fc ff ff       	jmp    800392 <vprintfmt+0x31>

008006fb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	83 ec 28             	sub    $0x28,%esp
  800701:	8b 45 08             	mov    0x8(%ebp),%eax
  800704:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800707:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800711:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800718:	85 c0                	test   %eax,%eax
  80071a:	74 30                	je     80074c <vsnprintf+0x51>
  80071c:	85 d2                	test   %edx,%edx
  80071e:	7e 2c                	jle    80074c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800727:	8b 45 10             	mov    0x10(%ebp),%eax
  80072a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800731:	89 44 24 04          	mov    %eax,0x4(%esp)
  800735:	c7 04 24 1c 03 80 00 	movl   $0x80031c,(%esp)
  80073c:	e8 20 fc ff ff       	call   800361 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800741:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800744:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800747:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074a:	eb 05                	jmp    800751 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800759:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800760:	8b 45 10             	mov    0x10(%ebp),%eax
  800763:	89 44 24 08          	mov    %eax,0x8(%esp)
  800767:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	89 04 24             	mov    %eax,(%esp)
  800774:	e8 82 ff ff ff       	call   8006fb <vsnprintf>
	va_end(ap);

	return rc;
}
  800779:	c9                   	leave  
  80077a:	c3                   	ret    
  80077b:	00 00                	add    %al,(%eax)
  80077d:	00 00                	add    %al,(%eax)
	...

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	80 3a 00             	cmpb   $0x0,(%edx)
  80078e:	74 09                	je     800799 <strlen+0x19>
		n++;
  800790:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800793:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800797:	75 f7                	jne    800790 <strlen+0x10>
		n++;
	return n;
}
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a9:	85 d2                	test   %edx,%edx
  8007ab:	74 12                	je     8007bf <strnlen+0x24>
  8007ad:	80 39 00             	cmpb   $0x0,(%ecx)
  8007b0:	74 0d                	je     8007bf <strnlen+0x24>
		n++;
  8007b2:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b5:	39 d0                	cmp    %edx,%eax
  8007b7:	74 06                	je     8007bf <strnlen+0x24>
  8007b9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007bd:	75 f3                	jne    8007b2 <strnlen+0x17>
		n++;
	return n;
}
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	53                   	push   %ebx
  8007c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007d4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007d7:	83 c2 01             	add    $0x1,%edx
  8007da:	84 c9                	test   %cl,%cl
  8007dc:	75 f2                	jne    8007d0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007de:	5b                   	pop    %ebx
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	83 ec 08             	sub    $0x8,%esp
  8007e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007eb:	89 1c 24             	mov    %ebx,(%esp)
  8007ee:	e8 8d ff ff ff       	call   800780 <strlen>
	strcpy(dst + len, src);
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fa:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007fd:	89 04 24             	mov    %eax,(%esp)
  800800:	e8 bc ff ff ff       	call   8007c1 <strcpy>
	return dst;
}
  800805:	89 d8                	mov    %ebx,%eax
  800807:	83 c4 08             	add    $0x8,%esp
  80080a:	5b                   	pop    %ebx
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	56                   	push   %esi
  800811:	53                   	push   %ebx
  800812:	8b 45 08             	mov    0x8(%ebp),%eax
  800815:	8b 55 0c             	mov    0xc(%ebp),%edx
  800818:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	85 f6                	test   %esi,%esi
  80081d:	74 18                	je     800837 <strncpy+0x2a>
  80081f:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800824:	0f b6 1a             	movzbl (%edx),%ebx
  800827:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082a:	80 3a 01             	cmpb   $0x1,(%edx)
  80082d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800830:	83 c1 01             	add    $0x1,%ecx
  800833:	39 ce                	cmp    %ecx,%esi
  800835:	77 ed                	ja     800824 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800837:	5b                   	pop    %ebx
  800838:	5e                   	pop    %esi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
  800840:	8b 75 08             	mov    0x8(%ebp),%esi
  800843:	8b 55 0c             	mov    0xc(%ebp),%edx
  800846:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800849:	89 f0                	mov    %esi,%eax
  80084b:	85 c9                	test   %ecx,%ecx
  80084d:	74 23                	je     800872 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  80084f:	83 e9 01             	sub    $0x1,%ecx
  800852:	74 1b                	je     80086f <strlcpy+0x34>
  800854:	0f b6 1a             	movzbl (%edx),%ebx
  800857:	84 db                	test   %bl,%bl
  800859:	74 14                	je     80086f <strlcpy+0x34>
			*dst++ = *src++;
  80085b:	88 18                	mov    %bl,(%eax)
  80085d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800860:	83 e9 01             	sub    $0x1,%ecx
  800863:	74 0a                	je     80086f <strlcpy+0x34>
			*dst++ = *src++;
  800865:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800868:	0f b6 1a             	movzbl (%edx),%ebx
  80086b:	84 db                	test   %bl,%bl
  80086d:	75 ec                	jne    80085b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80086f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800872:	29 f0                	sub    %esi,%eax
}
  800874:	5b                   	pop    %ebx
  800875:	5e                   	pop    %esi
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800881:	0f b6 01             	movzbl (%ecx),%eax
  800884:	84 c0                	test   %al,%al
  800886:	74 15                	je     80089d <strcmp+0x25>
  800888:	3a 02                	cmp    (%edx),%al
  80088a:	75 11                	jne    80089d <strcmp+0x25>
		p++, q++;
  80088c:	83 c1 01             	add    $0x1,%ecx
  80088f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800892:	0f b6 01             	movzbl (%ecx),%eax
  800895:	84 c0                	test   %al,%al
  800897:	74 04                	je     80089d <strcmp+0x25>
  800899:	3a 02                	cmp    (%edx),%al
  80089b:	74 ef                	je     80088c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089d:	0f b6 c0             	movzbl %al,%eax
  8008a0:	0f b6 12             	movzbl (%edx),%edx
  8008a3:	29 d0                	sub    %edx,%eax
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008b1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b9:	85 d2                	test   %edx,%edx
  8008bb:	74 28                	je     8008e5 <strncmp+0x3e>
  8008bd:	0f b6 01             	movzbl (%ecx),%eax
  8008c0:	84 c0                	test   %al,%al
  8008c2:	74 24                	je     8008e8 <strncmp+0x41>
  8008c4:	3a 03                	cmp    (%ebx),%al
  8008c6:	75 20                	jne    8008e8 <strncmp+0x41>
  8008c8:	83 ea 01             	sub    $0x1,%edx
  8008cb:	74 13                	je     8008e0 <strncmp+0x39>
		n--, p++, q++;
  8008cd:	83 c1 01             	add    $0x1,%ecx
  8008d0:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d3:	0f b6 01             	movzbl (%ecx),%eax
  8008d6:	84 c0                	test   %al,%al
  8008d8:	74 0e                	je     8008e8 <strncmp+0x41>
  8008da:	3a 03                	cmp    (%ebx),%al
  8008dc:	74 ea                	je     8008c8 <strncmp+0x21>
  8008de:	eb 08                	jmp    8008e8 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e5:	5b                   	pop    %ebx
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 01             	movzbl (%ecx),%eax
  8008eb:	0f b6 13             	movzbl (%ebx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
  8008f0:	eb f3                	jmp    8008e5 <strncmp+0x3e>

008008f2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fc:	0f b6 10             	movzbl (%eax),%edx
  8008ff:	84 d2                	test   %dl,%dl
  800901:	74 20                	je     800923 <strchr+0x31>
		if (*s == c)
  800903:	38 ca                	cmp    %cl,%dl
  800905:	75 0b                	jne    800912 <strchr+0x20>
  800907:	eb 1f                	jmp    800928 <strchr+0x36>
  800909:	38 ca                	cmp    %cl,%dl
  80090b:	90                   	nop
  80090c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800910:	74 16                	je     800928 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800912:	83 c0 01             	add    $0x1,%eax
  800915:	0f b6 10             	movzbl (%eax),%edx
  800918:	84 d2                	test   %dl,%dl
  80091a:	75 ed                	jne    800909 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
  800921:	eb 05                	jmp    800928 <strchr+0x36>
  800923:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800934:	0f b6 10             	movzbl (%eax),%edx
  800937:	84 d2                	test   %dl,%dl
  800939:	74 14                	je     80094f <strfind+0x25>
		if (*s == c)
  80093b:	38 ca                	cmp    %cl,%dl
  80093d:	75 06                	jne    800945 <strfind+0x1b>
  80093f:	eb 0e                	jmp    80094f <strfind+0x25>
  800941:	38 ca                	cmp    %cl,%dl
  800943:	74 0a                	je     80094f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800945:	83 c0 01             	add    $0x1,%eax
  800948:	0f b6 10             	movzbl (%eax),%edx
  80094b:	84 d2                	test   %dl,%dl
  80094d:	75 f2                	jne    800941 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 0c             	sub    $0xc,%esp
  800957:	89 1c 24             	mov    %ebx,(%esp)
  80095a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80095e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800962:	8b 7d 08             	mov    0x8(%ebp),%edi
  800965:	8b 45 0c             	mov    0xc(%ebp),%eax
  800968:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80096b:	85 c9                	test   %ecx,%ecx
  80096d:	74 30                	je     80099f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800975:	75 25                	jne    80099c <memset+0x4b>
  800977:	f6 c1 03             	test   $0x3,%cl
  80097a:	75 20                	jne    80099c <memset+0x4b>
		c &= 0xFF;
  80097c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097f:	89 d3                	mov    %edx,%ebx
  800981:	c1 e3 08             	shl    $0x8,%ebx
  800984:	89 d6                	mov    %edx,%esi
  800986:	c1 e6 18             	shl    $0x18,%esi
  800989:	89 d0                	mov    %edx,%eax
  80098b:	c1 e0 10             	shl    $0x10,%eax
  80098e:	09 f0                	or     %esi,%eax
  800990:	09 d0                	or     %edx,%eax
  800992:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800994:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800997:	fc                   	cld    
  800998:	f3 ab                	rep stos %eax,%es:(%edi)
  80099a:	eb 03                	jmp    80099f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099c:	fc                   	cld    
  80099d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099f:	89 f8                	mov    %edi,%eax
  8009a1:	8b 1c 24             	mov    (%esp),%ebx
  8009a4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009a8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8009ac:	89 ec                	mov    %ebp,%esp
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	83 ec 08             	sub    $0x8,%esp
  8009b6:	89 34 24             	mov    %esi,(%esp)
  8009b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c6:	39 c6                	cmp    %eax,%esi
  8009c8:	73 36                	jae    800a00 <memmove+0x50>
  8009ca:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009cd:	39 d0                	cmp    %edx,%eax
  8009cf:	73 2f                	jae    800a00 <memmove+0x50>
		s += n;
		d += n;
  8009d1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d4:	f6 c2 03             	test   $0x3,%dl
  8009d7:	75 1b                	jne    8009f4 <memmove+0x44>
  8009d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009df:	75 13                	jne    8009f4 <memmove+0x44>
  8009e1:	f6 c1 03             	test   $0x3,%cl
  8009e4:	75 0e                	jne    8009f4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009e6:	83 ef 04             	sub    $0x4,%edi
  8009e9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ec:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ef:	fd                   	std    
  8009f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f2:	eb 09                	jmp    8009fd <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f4:	83 ef 01             	sub    $0x1,%edi
  8009f7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009fa:	fd                   	std    
  8009fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009fd:	fc                   	cld    
  8009fe:	eb 20                	jmp    800a20 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a00:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a06:	75 13                	jne    800a1b <memmove+0x6b>
  800a08:	a8 03                	test   $0x3,%al
  800a0a:	75 0f                	jne    800a1b <memmove+0x6b>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	75 0a                	jne    800a1b <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a11:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a14:	89 c7                	mov    %eax,%edi
  800a16:	fc                   	cld    
  800a17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a19:	eb 05                	jmp    800a20 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a1b:	89 c7                	mov    %eax,%edi
  800a1d:	fc                   	cld    
  800a1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a20:	8b 34 24             	mov    (%esp),%esi
  800a23:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a27:	89 ec                	mov    %ebp,%esp
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a31:	8b 45 10             	mov    0x10(%ebp),%eax
  800a34:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	89 04 24             	mov    %eax,(%esp)
  800a45:	e8 66 ff ff ff       	call   8009b0 <memmove>
}
  800a4a:	c9                   	leave  
  800a4b:	c3                   	ret    

00800a4c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a58:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a5b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a60:	85 ff                	test   %edi,%edi
  800a62:	74 38                	je     800a9c <memcmp+0x50>
		if (*s1 != *s2)
  800a64:	0f b6 03             	movzbl (%ebx),%eax
  800a67:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6a:	83 ef 01             	sub    $0x1,%edi
  800a6d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a72:	38 c8                	cmp    %cl,%al
  800a74:	74 1d                	je     800a93 <memcmp+0x47>
  800a76:	eb 11                	jmp    800a89 <memcmp+0x3d>
  800a78:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a7d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800a82:	83 c2 01             	add    $0x1,%edx
  800a85:	38 c8                	cmp    %cl,%al
  800a87:	74 0a                	je     800a93 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800a89:	0f b6 c0             	movzbl %al,%eax
  800a8c:	0f b6 c9             	movzbl %cl,%ecx
  800a8f:	29 c8                	sub    %ecx,%eax
  800a91:	eb 09                	jmp    800a9c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	39 fa                	cmp    %edi,%edx
  800a95:	75 e1                	jne    800a78 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aa7:	89 c2                	mov    %eax,%edx
  800aa9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aac:	39 d0                	cmp    %edx,%eax
  800aae:	73 15                	jae    800ac5 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ab4:	38 08                	cmp    %cl,(%eax)
  800ab6:	75 06                	jne    800abe <memfind+0x1d>
  800ab8:	eb 0b                	jmp    800ac5 <memfind+0x24>
  800aba:	38 08                	cmp    %cl,(%eax)
  800abc:	74 07                	je     800ac5 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800abe:	83 c0 01             	add    $0x1,%eax
  800ac1:	39 c2                	cmp    %eax,%edx
  800ac3:	77 f5                	ja     800aba <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad3:	0f b6 02             	movzbl (%edx),%eax
  800ad6:	3c 20                	cmp    $0x20,%al
  800ad8:	74 04                	je     800ade <strtol+0x17>
  800ada:	3c 09                	cmp    $0x9,%al
  800adc:	75 0e                	jne    800aec <strtol+0x25>
		s++;
  800ade:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae1:	0f b6 02             	movzbl (%edx),%eax
  800ae4:	3c 20                	cmp    $0x20,%al
  800ae6:	74 f6                	je     800ade <strtol+0x17>
  800ae8:	3c 09                	cmp    $0x9,%al
  800aea:	74 f2                	je     800ade <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aec:	3c 2b                	cmp    $0x2b,%al
  800aee:	75 0a                	jne    800afa <strtol+0x33>
		s++;
  800af0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af3:	bf 00 00 00 00       	mov    $0x0,%edi
  800af8:	eb 10                	jmp    800b0a <strtol+0x43>
  800afa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aff:	3c 2d                	cmp    $0x2d,%al
  800b01:	75 07                	jne    800b0a <strtol+0x43>
		s++, neg = 1;
  800b03:	83 c2 01             	add    $0x1,%edx
  800b06:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0a:	85 db                	test   %ebx,%ebx
  800b0c:	0f 94 c0             	sete   %al
  800b0f:	74 05                	je     800b16 <strtol+0x4f>
  800b11:	83 fb 10             	cmp    $0x10,%ebx
  800b14:	75 15                	jne    800b2b <strtol+0x64>
  800b16:	80 3a 30             	cmpb   $0x30,(%edx)
  800b19:	75 10                	jne    800b2b <strtol+0x64>
  800b1b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b1f:	75 0a                	jne    800b2b <strtol+0x64>
		s += 2, base = 16;
  800b21:	83 c2 02             	add    $0x2,%edx
  800b24:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b29:	eb 13                	jmp    800b3e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800b2b:	84 c0                	test   %al,%al
  800b2d:	74 0f                	je     800b3e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b2f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b34:	80 3a 30             	cmpb   $0x30,(%edx)
  800b37:	75 05                	jne    800b3e <strtol+0x77>
		s++, base = 8;
  800b39:	83 c2 01             	add    $0x1,%edx
  800b3c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b43:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b45:	0f b6 0a             	movzbl (%edx),%ecx
  800b48:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b4b:	80 fb 09             	cmp    $0x9,%bl
  800b4e:	77 08                	ja     800b58 <strtol+0x91>
			dig = *s - '0';
  800b50:	0f be c9             	movsbl %cl,%ecx
  800b53:	83 e9 30             	sub    $0x30,%ecx
  800b56:	eb 1e                	jmp    800b76 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b58:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b5b:	80 fb 19             	cmp    $0x19,%bl
  800b5e:	77 08                	ja     800b68 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b60:	0f be c9             	movsbl %cl,%ecx
  800b63:	83 e9 57             	sub    $0x57,%ecx
  800b66:	eb 0e                	jmp    800b76 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b68:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b6b:	80 fb 19             	cmp    $0x19,%bl
  800b6e:	77 15                	ja     800b85 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800b70:	0f be c9             	movsbl %cl,%ecx
  800b73:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b76:	39 f1                	cmp    %esi,%ecx
  800b78:	7d 0f                	jge    800b89 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800b7a:	83 c2 01             	add    $0x1,%edx
  800b7d:	0f af c6             	imul   %esi,%eax
  800b80:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b83:	eb c0                	jmp    800b45 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b85:	89 c1                	mov    %eax,%ecx
  800b87:	eb 02                	jmp    800b8b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b89:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b8b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b8f:	74 05                	je     800b96 <strtol+0xcf>
		*endptr = (char *) s;
  800b91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b94:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b96:	89 ca                	mov    %ecx,%edx
  800b98:	f7 da                	neg    %edx
  800b9a:	85 ff                	test   %edi,%edi
  800b9c:	0f 45 c2             	cmovne %edx,%eax
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	89 1c 24             	mov    %ebx,(%esp)
  800bad:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bb1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc0:	89 c3                	mov    %eax,%ebx
  800bc2:	89 c7                	mov    %eax,%edi
  800bc4:	89 c6                	mov    %eax,%esi
  800bc6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bc8:	8b 1c 24             	mov    (%esp),%ebx
  800bcb:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bcf:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bd3:	89 ec                	mov    %ebp,%esp
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	89 1c 24             	mov    %ebx,(%esp)
  800be0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bed:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf2:	89 d1                	mov    %edx,%ecx
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	89 d7                	mov    %edx,%edi
  800bf8:	89 d6                	mov    %edx,%esi
  800bfa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bfc:	8b 1c 24             	mov    (%esp),%ebx
  800bff:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c03:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c07:	89 ec                	mov    %ebp,%esp
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	83 ec 38             	sub    $0x38,%esp
  800c11:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c14:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c17:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	89 cb                	mov    %ecx,%ebx
  800c29:	89 cf                	mov    %ecx,%edi
  800c2b:	89 ce                	mov    %ecx,%esi
  800c2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	7e 28                	jle    800c5b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c37:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c3e:	00 
  800c3f:	c7 44 24 08 a4 14 80 	movl   $0x8014a4,0x8(%esp)
  800c46:	00 
  800c47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4e:	00 
  800c4f:	c7 04 24 c1 14 80 00 	movl   $0x8014c1,(%esp)
  800c56:	e8 19 03 00 00       	call   800f74 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c5b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c5e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c61:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c64:	89 ec                	mov    %ebp,%esp
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	89 1c 24             	mov    %ebx,(%esp)
  800c71:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c75:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c79:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c83:	89 d1                	mov    %edx,%ecx
  800c85:	89 d3                	mov    %edx,%ebx
  800c87:	89 d7                	mov    %edx,%edi
  800c89:	89 d6                	mov    %edx,%esi
  800c8b:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800c8d:	8b 1c 24             	mov    (%esp),%ebx
  800c90:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c94:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c98:	89 ec                	mov    %ebp,%esp
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_yield>:

void
sys_yield(void)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	89 1c 24             	mov    %ebx,(%esp)
  800ca5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cad:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb7:	89 d1                	mov    %edx,%ecx
  800cb9:	89 d3                	mov    %edx,%ebx
  800cbb:	89 d7                	mov    %edx,%edi
  800cbd:	89 d6                	mov    %edx,%esi
  800cbf:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cc1:	8b 1c 24             	mov    (%esp),%ebx
  800cc4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cc8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ccc:	89 ec                	mov    %ebp,%esp
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	83 ec 38             	sub    $0x38,%esp
  800cd6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cdc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	be 00 00 00 00       	mov    $0x0,%esi
  800ce4:	b8 04 00 00 00       	mov    $0x4,%eax
  800ce9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	89 f7                	mov    %esi,%edi
  800cf4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7e 28                	jle    800d22 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfe:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d05:	00 
  800d06:	c7 44 24 08 a4 14 80 	movl   $0x8014a4,0x8(%esp)
  800d0d:	00 
  800d0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d15:	00 
  800d16:	c7 04 24 c1 14 80 00 	movl   $0x8014c1,(%esp)
  800d1d:	e8 52 02 00 00       	call   800f74 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d22:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d25:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d28:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d2b:	89 ec                	mov    %ebp,%esp
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	83 ec 38             	sub    $0x38,%esp
  800d35:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d38:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d3b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d43:	8b 75 18             	mov    0x18(%ebp),%esi
  800d46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d54:	85 c0                	test   %eax,%eax
  800d56:	7e 28                	jle    800d80 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d58:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d63:	00 
  800d64:	c7 44 24 08 a4 14 80 	movl   $0x8014a4,0x8(%esp)
  800d6b:	00 
  800d6c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d73:	00 
  800d74:	c7 04 24 c1 14 80 00 	movl   $0x8014c1,(%esp)
  800d7b:	e8 f4 01 00 00       	call   800f74 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d80:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d83:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d86:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d89:	89 ec                	mov    %ebp,%esp
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	83 ec 38             	sub    $0x38,%esp
  800d93:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d96:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d99:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da1:	b8 06 00 00 00       	mov    $0x6,%eax
  800da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	89 df                	mov    %ebx,%edi
  800dae:	89 de                	mov    %ebx,%esi
  800db0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db2:	85 c0                	test   %eax,%eax
  800db4:	7e 28                	jle    800dde <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dba:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dc1:	00 
  800dc2:	c7 44 24 08 a4 14 80 	movl   $0x8014a4,0x8(%esp)
  800dc9:	00 
  800dca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd1:	00 
  800dd2:	c7 04 24 c1 14 80 00 	movl   $0x8014c1,(%esp)
  800dd9:	e8 96 01 00 00       	call   800f74 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dde:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de7:	89 ec                	mov    %ebp,%esp
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	83 ec 38             	sub    $0x38,%esp
  800df1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800df7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dff:	b8 08 00 00 00       	mov    $0x8,%eax
  800e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e07:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0a:	89 df                	mov    %ebx,%edi
  800e0c:	89 de                	mov    %ebx,%esi
  800e0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e10:	85 c0                	test   %eax,%eax
  800e12:	7e 28                	jle    800e3c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e14:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e18:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e1f:	00 
  800e20:	c7 44 24 08 a4 14 80 	movl   $0x8014a4,0x8(%esp)
  800e27:	00 
  800e28:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2f:	00 
  800e30:	c7 04 24 c1 14 80 00 	movl   $0x8014c1,(%esp)
  800e37:	e8 38 01 00 00       	call   800f74 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e3c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e3f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e42:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e45:	89 ec                	mov    %ebp,%esp
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	83 ec 38             	sub    $0x38,%esp
  800e4f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e52:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e55:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e65:	8b 55 08             	mov    0x8(%ebp),%edx
  800e68:	89 df                	mov    %ebx,%edi
  800e6a:	89 de                	mov    %ebx,%esi
  800e6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	7e 28                	jle    800e9a <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e76:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 08 a4 14 80 	movl   $0x8014a4,0x8(%esp)
  800e85:	00 
  800e86:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8d:	00 
  800e8e:	c7 04 24 c1 14 80 00 	movl   $0x8014c1,(%esp)
  800e95:	e8 da 00 00 00       	call   800f74 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e9a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e9d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea3:	89 ec                	mov    %ebp,%esp
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	83 ec 0c             	sub    $0xc,%esp
  800ead:	89 1c 24             	mov    %ebx,(%esp)
  800eb0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eb4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb8:	be 00 00 00 00       	mov    $0x0,%esi
  800ebd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ec2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ece:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed0:	8b 1c 24             	mov    (%esp),%ebx
  800ed3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ed7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800edb:	89 ec                	mov    %ebp,%esp
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	83 ec 38             	sub    $0x38,%esp
  800ee5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eeb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ef8:	8b 55 08             	mov    0x8(%ebp),%edx
  800efb:	89 cb                	mov    %ecx,%ebx
  800efd:	89 cf                	mov    %ecx,%edi
  800eff:	89 ce                	mov    %ecx,%esi
  800f01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f03:	85 c0                	test   %eax,%eax
  800f05:	7e 28                	jle    800f2f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f12:	00 
  800f13:	c7 44 24 08 a4 14 80 	movl   $0x8014a4,0x8(%esp)
  800f1a:	00 
  800f1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f22:	00 
  800f23:	c7 04 24 c1 14 80 00 	movl   $0x8014c1,(%esp)
  800f2a:	e8 45 00 00 00       	call   800f74 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f38:	89 ec                	mov    %ebp,%esp
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f42:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800f49:	75 1c                	jne    800f67 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800f4b:	c7 44 24 08 d0 14 80 	movl   $0x8014d0,0x8(%esp)
  800f52:	00 
  800f53:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800f5a:	00 
  800f5b:	c7 04 24 f4 14 80 00 	movl   $0x8014f4,(%esp)
  800f62:	e8 0d 00 00 00       	call   800f74 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f67:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6a:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    
  800f71:	00 00                	add    %al,(%eax)
	...

00800f74 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
  800f79:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800f7c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f7f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f85:	e8 de fc ff ff       	call   800c68 <sys_getenvid>
  800f8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f91:	8b 55 08             	mov    0x8(%ebp),%edx
  800f94:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f98:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa0:	c7 04 24 04 15 80 00 	movl   $0x801504,(%esp)
  800fa7:	e8 ef f1 ff ff       	call   80019b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fac:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fb0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fb3:	89 04 24             	mov    %eax,(%esp)
  800fb6:	e8 7f f1 ff ff       	call   80013a <vcprintf>
	cprintf("\n");
  800fbb:	c7 04 24 5a 12 80 00 	movl   $0x80125a,(%esp)
  800fc2:	e8 d4 f1 ff ff       	call   80019b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fc7:	cc                   	int3   
  800fc8:	eb fd                	jmp    800fc7 <_panic+0x53>
  800fca:	00 00                	add    %al,(%eax)
  800fcc:	00 00                	add    %al,(%eax)
	...

00800fd0 <__udivdi3>:
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	83 ec 10             	sub    $0x10,%esp
  800fd8:	8b 75 14             	mov    0x14(%ebp),%esi
  800fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fde:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fe1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fe4:	85 f6                	test   %esi,%esi
  800fe6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fe9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800fec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800fef:	75 2f                	jne    801020 <__udivdi3+0x50>
  800ff1:	39 f9                	cmp    %edi,%ecx
  800ff3:	77 5b                	ja     801050 <__udivdi3+0x80>
  800ff5:	85 c9                	test   %ecx,%ecx
  800ff7:	75 0b                	jne    801004 <__udivdi3+0x34>
  800ff9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ffe:	31 d2                	xor    %edx,%edx
  801000:	f7 f1                	div    %ecx
  801002:	89 c1                	mov    %eax,%ecx
  801004:	89 f8                	mov    %edi,%eax
  801006:	31 d2                	xor    %edx,%edx
  801008:	f7 f1                	div    %ecx
  80100a:	89 c7                	mov    %eax,%edi
  80100c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100f:	f7 f1                	div    %ecx
  801011:	89 fa                	mov    %edi,%edx
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    
  80101a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801020:	31 d2                	xor    %edx,%edx
  801022:	31 c0                	xor    %eax,%eax
  801024:	39 fe                	cmp    %edi,%esi
  801026:	77 eb                	ja     801013 <__udivdi3+0x43>
  801028:	0f bd d6             	bsr    %esi,%edx
  80102b:	83 f2 1f             	xor    $0x1f,%edx
  80102e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801031:	75 2d                	jne    801060 <__udivdi3+0x90>
  801033:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801036:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  801039:	76 06                	jbe    801041 <__udivdi3+0x71>
  80103b:	39 fe                	cmp    %edi,%esi
  80103d:	89 c2                	mov    %eax,%edx
  80103f:	73 d2                	jae    801013 <__udivdi3+0x43>
  801041:	31 d2                	xor    %edx,%edx
  801043:	b8 01 00 00 00       	mov    $0x1,%eax
  801048:	eb c9                	jmp    801013 <__udivdi3+0x43>
  80104a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801050:	89 fa                	mov    %edi,%edx
  801052:	f7 f1                	div    %ecx
  801054:	31 d2                	xor    %edx,%edx
  801056:	83 c4 10             	add    $0x10,%esp
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    
  80105d:	8d 76 00             	lea    0x0(%esi),%esi
  801060:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801064:	b8 20 00 00 00       	mov    $0x20,%eax
  801069:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80106c:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80106f:	d3 e6                	shl    %cl,%esi
  801071:	89 c1                	mov    %eax,%ecx
  801073:	d3 ea                	shr    %cl,%edx
  801075:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801079:	09 f2                	or     %esi,%edx
  80107b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  80107e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801081:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801084:	d3 e2                	shl    %cl,%edx
  801086:	89 c1                	mov    %eax,%ecx
  801088:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80108b:	89 fa                	mov    %edi,%edx
  80108d:	d3 ea                	shr    %cl,%edx
  80108f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801093:	d3 e7                	shl    %cl,%edi
  801095:	89 c1                	mov    %eax,%ecx
  801097:	d3 ee                	shr    %cl,%esi
  801099:	09 fe                	or     %edi,%esi
  80109b:	89 f0                	mov    %esi,%eax
  80109d:	f7 75 e8             	divl   -0x18(%ebp)
  8010a0:	89 d7                	mov    %edx,%edi
  8010a2:	89 c6                	mov    %eax,%esi
  8010a4:	f7 65 f0             	mull   -0x10(%ebp)
  8010a7:	39 d7                	cmp    %edx,%edi
  8010a9:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8010ac:	72 22                	jb     8010d0 <__udivdi3+0x100>
  8010ae:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8010b1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010b5:	d3 e2                	shl    %cl,%edx
  8010b7:	39 c2                	cmp    %eax,%edx
  8010b9:	73 05                	jae    8010c0 <__udivdi3+0xf0>
  8010bb:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  8010be:	74 10                	je     8010d0 <__udivdi3+0x100>
  8010c0:	89 f0                	mov    %esi,%eax
  8010c2:	31 d2                	xor    %edx,%edx
  8010c4:	e9 4a ff ff ff       	jmp    801013 <__udivdi3+0x43>
  8010c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010d0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8010d3:	31 d2                	xor    %edx,%edx
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    
  8010dc:	00 00                	add    %al,(%eax)
	...

008010e0 <__umoddi3>:
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	57                   	push   %edi
  8010e4:	56                   	push   %esi
  8010e5:	83 ec 20             	sub    $0x20,%esp
  8010e8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010f4:	85 ff                	test   %edi,%edi
  8010f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8010f9:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8010fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8010ff:	89 f2                	mov    %esi,%edx
  801101:	75 15                	jne    801118 <__umoddi3+0x38>
  801103:	39 f1                	cmp    %esi,%ecx
  801105:	76 41                	jbe    801148 <__umoddi3+0x68>
  801107:	f7 f1                	div    %ecx
  801109:	89 d0                	mov    %edx,%eax
  80110b:	31 d2                	xor    %edx,%edx
  80110d:	83 c4 20             	add    $0x20,%esp
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    
  801114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801118:	39 f7                	cmp    %esi,%edi
  80111a:	77 4c                	ja     801168 <__umoddi3+0x88>
  80111c:	0f bd c7             	bsr    %edi,%eax
  80111f:	83 f0 1f             	xor    $0x1f,%eax
  801122:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801125:	75 51                	jne    801178 <__umoddi3+0x98>
  801127:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80112a:	0f 87 e8 00 00 00    	ja     801218 <__umoddi3+0x138>
  801130:	89 f2                	mov    %esi,%edx
  801132:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801135:	29 ce                	sub    %ecx,%esi
  801137:	19 fa                	sbb    %edi,%edx
  801139:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80113c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113f:	83 c4 20             	add    $0x20,%esp
  801142:	5e                   	pop    %esi
  801143:	5f                   	pop    %edi
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    
  801146:	66 90                	xchg   %ax,%ax
  801148:	85 c9                	test   %ecx,%ecx
  80114a:	75 0b                	jne    801157 <__umoddi3+0x77>
  80114c:	b8 01 00 00 00       	mov    $0x1,%eax
  801151:	31 d2                	xor    %edx,%edx
  801153:	f7 f1                	div    %ecx
  801155:	89 c1                	mov    %eax,%ecx
  801157:	89 f0                	mov    %esi,%eax
  801159:	31 d2                	xor    %edx,%edx
  80115b:	f7 f1                	div    %ecx
  80115d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801160:	eb a5                	jmp    801107 <__umoddi3+0x27>
  801162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801168:	89 f2                	mov    %esi,%edx
  80116a:	83 c4 20             	add    $0x20,%esp
  80116d:	5e                   	pop    %esi
  80116e:	5f                   	pop    %edi
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    
  801171:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801178:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80117c:	89 f2                	mov    %esi,%edx
  80117e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801181:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801188:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80118b:	d3 e7                	shl    %cl,%edi
  80118d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801190:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801194:	d3 e8                	shr    %cl,%eax
  801196:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80119a:	09 f8                	or     %edi,%eax
  80119c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80119f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a2:	d3 e0                	shl    %cl,%eax
  8011a4:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8011ae:	d3 ea                	shr    %cl,%edx
  8011b0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011b4:	d3 e6                	shl    %cl,%esi
  8011b6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011ba:	d3 e8                	shr    %cl,%eax
  8011bc:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011c0:	09 f0                	or     %esi,%eax
  8011c2:	8b 75 e8             	mov    -0x18(%ebp),%esi
  8011c5:	f7 75 e4             	divl   -0x1c(%ebp)
  8011c8:	d3 e6                	shl    %cl,%esi
  8011ca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8011cd:	89 d6                	mov    %edx,%esi
  8011cf:	f7 65 f4             	mull   -0xc(%ebp)
  8011d2:	89 d7                	mov    %edx,%edi
  8011d4:	89 c2                	mov    %eax,%edx
  8011d6:	39 fe                	cmp    %edi,%esi
  8011d8:	89 f9                	mov    %edi,%ecx
  8011da:	72 30                	jb     80120c <__umoddi3+0x12c>
  8011dc:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8011df:	72 27                	jb     801208 <__umoddi3+0x128>
  8011e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8011e4:	29 d0                	sub    %edx,%eax
  8011e6:	19 ce                	sbb    %ecx,%esi
  8011e8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011ec:	89 f2                	mov    %esi,%edx
  8011ee:	d3 e8                	shr    %cl,%eax
  8011f0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011f4:	d3 e2                	shl    %cl,%edx
  8011f6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011fa:	09 d0                	or     %edx,%eax
  8011fc:	89 f2                	mov    %esi,%edx
  8011fe:	d3 ea                	shr    %cl,%edx
  801200:	83 c4 20             	add    $0x20,%esp
  801203:	5e                   	pop    %esi
  801204:	5f                   	pop    %edi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    
  801207:	90                   	nop
  801208:	39 fe                	cmp    %edi,%esi
  80120a:	75 d5                	jne    8011e1 <__umoddi3+0x101>
  80120c:	89 f9                	mov    %edi,%ecx
  80120e:	89 c2                	mov    %eax,%edx
  801210:	2b 55 f4             	sub    -0xc(%ebp),%edx
  801213:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801216:	eb c9                	jmp    8011e1 <__umoddi3+0x101>
  801218:	39 f7                	cmp    %esi,%edi
  80121a:	0f 82 10 ff ff ff    	jb     801130 <__umoddi3+0x50>
  801220:	e9 17 ff ff ff       	jmp    80113c <__umoddi3+0x5c>
