
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
  800043:	c7 04 24 c0 11 80 00 	movl   $0x8011c0,(%esp)
  80004a:	e8 0c 01 00 00       	call   80015b <cprintf>
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
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800066:	e8 bd 0b 00 00       	call   800c28 <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800088:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 15 0b 00 00       	call   800bcb <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 14             	sub    $0x14,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 03                	mov    (%ebx),%eax
  8000c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000cb:	83 c0 01             	add    $0x1,%eax
  8000ce:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d5:	75 19                	jne    8000f0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000d7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000de:	00 
  8000df:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e2:	89 04 24             	mov    %eax,(%esp)
  8000e5:	e8 7a 0a 00 00       	call   800b64 <sys_cputs>
		b->idx = 0;
  8000ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f4:	83 c4 14             	add    $0x14,%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010a:	00 00 00 
	b.cnt = 0;
  80010d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800117:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011e:	8b 45 08             	mov    0x8(%ebp),%eax
  800121:	89 44 24 08          	mov    %eax,0x8(%esp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012f:	c7 04 24 b8 00 80 00 	movl   $0x8000b8,(%esp)
  800136:	e8 e6 01 00 00       	call   800321 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800141:	89 44 24 04          	mov    %eax,0x4(%esp)
  800145:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014b:	89 04 24             	mov    %eax,(%esp)
  80014e:	e8 11 0a 00 00       	call   800b64 <sys_cputs>

	return b.cnt;
}
  800153:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800161:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800164:	89 44 24 04          	mov    %eax,0x4(%esp)
  800168:	8b 45 08             	mov    0x8(%ebp),%eax
  80016b:	89 04 24             	mov    %eax,(%esp)
  80016e:	e8 87 ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  800173:	c9                   	leave  
  800174:	c3                   	ret    
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
  8001ef:	e8 6c 0d 00 00       	call   800f60 <__udivdi3>
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
  80024a:	e8 21 0e 00 00       	call   801070 <__umoddi3>
  80024f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800253:	0f be 80 e8 11 80 00 	movsbl 0x8011e8(%eax),%eax
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
  800333:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
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
  8003ab:	ff 24 85 a0 12 80 00 	jmp    *0x8012a0(,%eax,4)
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
  80043a:	83 f8 08             	cmp    $0x8,%eax
  80043d:	7f 0b                	jg     80044a <vprintfmt+0x129>
  80043f:	8b 14 85 00 14 80 00 	mov    0x801400(,%eax,4),%edx
  800446:	85 d2                	test   %edx,%edx
  800448:	75 23                	jne    80046d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80044a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044e:	c7 44 24 08 00 12 80 	movl   $0x801200,0x8(%esp)
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
  800471:	c7 44 24 08 09 12 80 	movl   $0x801209,0x8(%esp)
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
  8004a6:	ba f9 11 80 00       	mov    $0x8011f9,%edx
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
  80068b:	a3 08 20 80 00       	mov    %eax,0x802008
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
  800bff:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800c06:	00 
  800c07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c0e:	00 
  800c0f:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800c16:	e8 e1 02 00 00       	call   800efc <_panic>

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
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800c4d:	8b 1c 24             	mov    (%esp),%ebx
  800c50:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c54:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c58:	89 ec                	mov    %ebp,%esp
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_yield>:

void
sys_yield(void)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	89 1c 24             	mov    %ebx,(%esp)
  800c65:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c69:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c72:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c77:	89 d1                	mov    %edx,%ecx
  800c79:	89 d3                	mov    %edx,%ebx
  800c7b:	89 d7                	mov    %edx,%edi
  800c7d:	89 d6                	mov    %edx,%esi
  800c7f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c81:	8b 1c 24             	mov    (%esp),%ebx
  800c84:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c88:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c8c:	89 ec                	mov    %ebp,%esp
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	83 ec 38             	sub    $0x38,%esp
  800c96:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c99:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c9c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	be 00 00 00 00       	mov    $0x0,%esi
  800ca4:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 f7                	mov    %esi,%edi
  800cb4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 28                	jle    800ce2 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbe:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cc5:	00 
  800cc6:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800ccd:	00 
  800cce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd5:	00 
  800cd6:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800cdd:	e8 1a 02 00 00       	call   800efc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ceb:	89 ec                	mov    %ebp,%esp
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	83 ec 38             	sub    $0x38,%esp
  800cf5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	b8 05 00 00 00       	mov    $0x5,%eax
  800d03:	8b 75 18             	mov    0x18(%ebp),%esi
  800d06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d14:	85 c0                	test   %eax,%eax
  800d16:	7e 28                	jle    800d40 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d23:	00 
  800d24:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800d2b:	00 
  800d2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d33:	00 
  800d34:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800d3b:	e8 bc 01 00 00       	call   800efc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d40:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d43:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d46:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d49:	89 ec                	mov    %ebp,%esp
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	83 ec 38             	sub    $0x38,%esp
  800d53:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d56:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d59:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d61:	b8 06 00 00 00       	mov    $0x6,%eax
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	89 df                	mov    %ebx,%edi
  800d6e:	89 de                	mov    %ebx,%esi
  800d70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7e 28                	jle    800d9e <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d81:	00 
  800d82:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800d89:	00 
  800d8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d91:	00 
  800d92:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800d99:	e8 5e 01 00 00       	call   800efc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d9e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da7:	89 ec                	mov    %ebp,%esp
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	83 ec 38             	sub    $0x38,%esp
  800db1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbf:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dca:	89 df                	mov    %ebx,%edi
  800dcc:	89 de                	mov    %ebx,%esi
  800dce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	7e 28                	jle    800dfc <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd8:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ddf:	00 
  800de0:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800de7:	00 
  800de8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800def:	00 
  800df0:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800df7:	e8 00 01 00 00       	call   800efc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dfc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dff:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e02:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e05:	89 ec                	mov    %ebp,%esp
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	83 ec 38             	sub    $0x38,%esp
  800e0f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e12:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e15:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e25:	8b 55 08             	mov    0x8(%ebp),%edx
  800e28:	89 df                	mov    %ebx,%edi
  800e2a:	89 de                	mov    %ebx,%esi
  800e2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2e:	85 c0                	test   %eax,%eax
  800e30:	7e 28                	jle    800e5a <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e32:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e36:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800e45:	00 
  800e46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4d:	00 
  800e4e:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800e55:	e8 a2 00 00 00       	call   800efc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e5a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e5d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e60:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e63:	89 ec                	mov    %ebp,%esp
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	83 ec 0c             	sub    $0xc,%esp
  800e6d:	89 1c 24             	mov    %ebx,(%esp)
  800e70:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e74:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e78:	be 00 00 00 00       	mov    $0x0,%esi
  800e7d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e90:	8b 1c 24             	mov    (%esp),%ebx
  800e93:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e97:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e9b:	89 ec                	mov    %ebp,%esp
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	83 ec 38             	sub    $0x38,%esp
  800ea5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eab:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebb:	89 cb                	mov    %ecx,%ebx
  800ebd:	89 cf                	mov    %ecx,%edi
  800ebf:	89 ce                	mov    %ecx,%esi
  800ec1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	7e 28                	jle    800eef <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecb:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ed2:	00 
  800ed3:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800eda:	00 
  800edb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee2:	00 
  800ee3:	c7 04 24 41 14 80 00 	movl   $0x801441,(%esp)
  800eea:	e8 0d 00 00 00       	call   800efc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef8:	89 ec                	mov    %ebp,%esp
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800f04:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f07:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f0d:	e8 16 fd ff ff       	call   800c28 <sys_getenvid>
  800f12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f15:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f19:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f20:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f28:	c7 04 24 50 14 80 00 	movl   $0x801450,(%esp)
  800f2f:	e8 27 f2 ff ff       	call   80015b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f34:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f38:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3b:	89 04 24             	mov    %eax,(%esp)
  800f3e:	e8 b7 f1 ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  800f43:	c7 04 24 dc 11 80 00 	movl   $0x8011dc,(%esp)
  800f4a:	e8 0c f2 ff ff       	call   80015b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f4f:	cc                   	int3   
  800f50:	eb fd                	jmp    800f4f <_panic+0x53>
	...

00800f60 <__udivdi3>:
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	57                   	push   %edi
  800f64:	56                   	push   %esi
  800f65:	83 ec 10             	sub    $0x10,%esp
  800f68:	8b 75 14             	mov    0x14(%ebp),%esi
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f71:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f74:	85 f6                	test   %esi,%esi
  800f76:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f79:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f7f:	75 2f                	jne    800fb0 <__udivdi3+0x50>
  800f81:	39 f9                	cmp    %edi,%ecx
  800f83:	77 5b                	ja     800fe0 <__udivdi3+0x80>
  800f85:	85 c9                	test   %ecx,%ecx
  800f87:	75 0b                	jne    800f94 <__udivdi3+0x34>
  800f89:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8e:	31 d2                	xor    %edx,%edx
  800f90:	f7 f1                	div    %ecx
  800f92:	89 c1                	mov    %eax,%ecx
  800f94:	89 f8                	mov    %edi,%eax
  800f96:	31 d2                	xor    %edx,%edx
  800f98:	f7 f1                	div    %ecx
  800f9a:	89 c7                	mov    %eax,%edi
  800f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9f:	f7 f1                	div    %ecx
  800fa1:	89 fa                	mov    %edi,%edx
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    
  800faa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fb0:	31 d2                	xor    %edx,%edx
  800fb2:	31 c0                	xor    %eax,%eax
  800fb4:	39 fe                	cmp    %edi,%esi
  800fb6:	77 eb                	ja     800fa3 <__udivdi3+0x43>
  800fb8:	0f bd d6             	bsr    %esi,%edx
  800fbb:	83 f2 1f             	xor    $0x1f,%edx
  800fbe:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fc1:	75 2d                	jne    800ff0 <__udivdi3+0x90>
  800fc3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800fc6:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  800fc9:	76 06                	jbe    800fd1 <__udivdi3+0x71>
  800fcb:	39 fe                	cmp    %edi,%esi
  800fcd:	89 c2                	mov    %eax,%edx
  800fcf:	73 d2                	jae    800fa3 <__udivdi3+0x43>
  800fd1:	31 d2                	xor    %edx,%edx
  800fd3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd8:	eb c9                	jmp    800fa3 <__udivdi3+0x43>
  800fda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fe0:	89 fa                	mov    %edi,%edx
  800fe2:	f7 f1                	div    %ecx
  800fe4:	31 d2                	xor    %edx,%edx
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    
  800fed:	8d 76 00             	lea    0x0(%esi),%esi
  800ff0:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800ff4:	b8 20 00 00 00       	mov    $0x20,%eax
  800ff9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ffc:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800fff:	d3 e6                	shl    %cl,%esi
  801001:	89 c1                	mov    %eax,%ecx
  801003:	d3 ea                	shr    %cl,%edx
  801005:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801009:	09 f2                	or     %esi,%edx
  80100b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  80100e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801011:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801014:	d3 e2                	shl    %cl,%edx
  801016:	89 c1                	mov    %eax,%ecx
  801018:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80101b:	89 fa                	mov    %edi,%edx
  80101d:	d3 ea                	shr    %cl,%edx
  80101f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801023:	d3 e7                	shl    %cl,%edi
  801025:	89 c1                	mov    %eax,%ecx
  801027:	d3 ee                	shr    %cl,%esi
  801029:	09 fe                	or     %edi,%esi
  80102b:	89 f0                	mov    %esi,%eax
  80102d:	f7 75 e8             	divl   -0x18(%ebp)
  801030:	89 d7                	mov    %edx,%edi
  801032:	89 c6                	mov    %eax,%esi
  801034:	f7 65 f0             	mull   -0x10(%ebp)
  801037:	39 d7                	cmp    %edx,%edi
  801039:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80103c:	72 22                	jb     801060 <__udivdi3+0x100>
  80103e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801041:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801045:	d3 e2                	shl    %cl,%edx
  801047:	39 c2                	cmp    %eax,%edx
  801049:	73 05                	jae    801050 <__udivdi3+0xf0>
  80104b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80104e:	74 10                	je     801060 <__udivdi3+0x100>
  801050:	89 f0                	mov    %esi,%eax
  801052:	31 d2                	xor    %edx,%edx
  801054:	e9 4a ff ff ff       	jmp    800fa3 <__udivdi3+0x43>
  801059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801060:	8d 46 ff             	lea    -0x1(%esi),%eax
  801063:	31 d2                	xor    %edx,%edx
  801065:	83 c4 10             	add    $0x10,%esp
  801068:	5e                   	pop    %esi
  801069:	5f                   	pop    %edi
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    
  80106c:	00 00                	add    %al,(%eax)
	...

00801070 <__umoddi3>:
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	83 ec 20             	sub    $0x20,%esp
  801078:	8b 7d 14             	mov    0x14(%ebp),%edi
  80107b:	8b 45 08             	mov    0x8(%ebp),%eax
  80107e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801081:	8b 75 0c             	mov    0xc(%ebp),%esi
  801084:	85 ff                	test   %edi,%edi
  801086:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801089:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80108c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80108f:	89 f2                	mov    %esi,%edx
  801091:	75 15                	jne    8010a8 <__umoddi3+0x38>
  801093:	39 f1                	cmp    %esi,%ecx
  801095:	76 41                	jbe    8010d8 <__umoddi3+0x68>
  801097:	f7 f1                	div    %ecx
  801099:	89 d0                	mov    %edx,%eax
  80109b:	31 d2                	xor    %edx,%edx
  80109d:	83 c4 20             	add    $0x20,%esp
  8010a0:	5e                   	pop    %esi
  8010a1:	5f                   	pop    %edi
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    
  8010a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010a8:	39 f7                	cmp    %esi,%edi
  8010aa:	77 4c                	ja     8010f8 <__umoddi3+0x88>
  8010ac:	0f bd c7             	bsr    %edi,%eax
  8010af:	83 f0 1f             	xor    $0x1f,%eax
  8010b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010b5:	75 51                	jne    801108 <__umoddi3+0x98>
  8010b7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8010ba:	0f 87 e8 00 00 00    	ja     8011a8 <__umoddi3+0x138>
  8010c0:	89 f2                	mov    %esi,%edx
  8010c2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8010c5:	29 ce                	sub    %ecx,%esi
  8010c7:	19 fa                	sbb    %edi,%edx
  8010c9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8010cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cf:	83 c4 20             	add    $0x20,%esp
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    
  8010d6:	66 90                	xchg   %ax,%ax
  8010d8:	85 c9                	test   %ecx,%ecx
  8010da:	75 0b                	jne    8010e7 <__umoddi3+0x77>
  8010dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e1:	31 d2                	xor    %edx,%edx
  8010e3:	f7 f1                	div    %ecx
  8010e5:	89 c1                	mov    %eax,%ecx
  8010e7:	89 f0                	mov    %esi,%eax
  8010e9:	31 d2                	xor    %edx,%edx
  8010eb:	f7 f1                	div    %ecx
  8010ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f0:	eb a5                	jmp    801097 <__umoddi3+0x27>
  8010f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010f8:	89 f2                	mov    %esi,%edx
  8010fa:	83 c4 20             	add    $0x20,%esp
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    
  801101:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801108:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80110c:	89 f2                	mov    %esi,%edx
  80110e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801111:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801118:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80111b:	d3 e7                	shl    %cl,%edi
  80111d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801120:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801124:	d3 e8                	shr    %cl,%eax
  801126:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80112a:	09 f8                	or     %edi,%eax
  80112c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80112f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801132:	d3 e0                	shl    %cl,%eax
  801134:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801138:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80113b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80113e:	d3 ea                	shr    %cl,%edx
  801140:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801144:	d3 e6                	shl    %cl,%esi
  801146:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80114a:	d3 e8                	shr    %cl,%eax
  80114c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801150:	09 f0                	or     %esi,%eax
  801152:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801155:	f7 75 e4             	divl   -0x1c(%ebp)
  801158:	d3 e6                	shl    %cl,%esi
  80115a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80115d:	89 d6                	mov    %edx,%esi
  80115f:	f7 65 f4             	mull   -0xc(%ebp)
  801162:	89 d7                	mov    %edx,%edi
  801164:	89 c2                	mov    %eax,%edx
  801166:	39 fe                	cmp    %edi,%esi
  801168:	89 f9                	mov    %edi,%ecx
  80116a:	72 30                	jb     80119c <__umoddi3+0x12c>
  80116c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80116f:	72 27                	jb     801198 <__umoddi3+0x128>
  801171:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801174:	29 d0                	sub    %edx,%eax
  801176:	19 ce                	sbb    %ecx,%esi
  801178:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80117c:	89 f2                	mov    %esi,%edx
  80117e:	d3 e8                	shr    %cl,%eax
  801180:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801184:	d3 e2                	shl    %cl,%edx
  801186:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80118a:	09 d0                	or     %edx,%eax
  80118c:	89 f2                	mov    %esi,%edx
  80118e:	d3 ea                	shr    %cl,%edx
  801190:	83 c4 20             	add    $0x20,%esp
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    
  801197:	90                   	nop
  801198:	39 fe                	cmp    %edi,%esi
  80119a:	75 d5                	jne    801171 <__umoddi3+0x101>
  80119c:	89 f9                	mov    %edi,%ecx
  80119e:	89 c2                	mov    %eax,%edx
  8011a0:	2b 55 f4             	sub    -0xc(%ebp),%edx
  8011a3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011a6:	eb c9                	jmp    801171 <__umoddi3+0x101>
  8011a8:	39 f7                	cmp    %esi,%edi
  8011aa:	0f 82 10 ff ff ff    	jb     8010c0 <__umoddi3+0x50>
  8011b0:	e9 17 ff ff ff       	jmp    8010cc <__umoddi3+0x5c>
