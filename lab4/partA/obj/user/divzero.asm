
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
  800059:	c7 04 24 e0 11 80 00 	movl   $0x8011e0,(%esp)
  800060:	e8 0a 01 00 00       	call   80016f <cprintf>
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
  80006e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800071:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800074:	8b 75 08             	mov    0x8(%ebp),%esi
  800077:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80007a:	e8 b9 0b 00 00       	call   800c38 <sys_getenvid>
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 08 20 80 00       	mov    %eax,0x802008
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800091:	85 f6                	test   %esi,%esi
  800093:	7e 07                	jle    80009c <libmain+0x34>
		binaryname = argv[0];
  800095:	8b 03                	mov    (%ebx),%eax
  800097:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a0:	89 34 24             	mov    %esi,(%esp)
  8000a3:	e8 8c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0b 00 00 00       	call   8000b8 <exit>
}
  8000ad:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000b0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000b3:	89 ec                	mov    %ebp,%esp
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    
	...

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c5:	e8 11 0b 00 00       	call   800bdb <sys_env_destroy>
}
  8000ca:	c9                   	leave  
  8000cb:	c3                   	ret    

008000cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	53                   	push   %ebx
  8000d0:	83 ec 14             	sub    $0x14,%esp
  8000d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d6:	8b 03                	mov    (%ebx),%eax
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000df:	83 c0 01             	add    $0x1,%eax
  8000e2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e9:	75 19                	jne    800104 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000eb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f2:	00 
  8000f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f6:	89 04 24             	mov    %eax,(%esp)
  8000f9:	e8 76 0a 00 00       	call   800b74 <sys_cputs>
		b->idx = 0;
  8000fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800104:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800108:	83 c4 14             	add    $0x14,%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800117:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011e:	00 00 00 
	b.cnt = 0;
  800121:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800128:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800132:	8b 45 08             	mov    0x8(%ebp),%eax
  800135:	89 44 24 08          	mov    %eax,0x8(%esp)
  800139:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800143:	c7 04 24 cc 00 80 00 	movl   $0x8000cc,(%esp)
  80014a:	e8 e2 01 00 00       	call   800331 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800155:	89 44 24 04          	mov    %eax,0x4(%esp)
  800159:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015f:	89 04 24             	mov    %eax,(%esp)
  800162:	e8 0d 0a 00 00       	call   800b74 <sys_cputs>

	return b.cnt;
}
  800167:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800175:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	8b 45 08             	mov    0x8(%ebp),%eax
  80017f:	89 04 24             	mov    %eax,(%esp)
  800182:	e8 87 ff ff ff       	call   80010e <vcprintf>
	va_end(ap);

	return cnt;
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    
  800189:	00 00                	add    %al,(%eax)
  80018b:	00 00                	add    %al,(%eax)
  80018d:	00 00                	add    %al,(%eax)
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 4c             	sub    $0x4c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d6                	mov    %edx,%esi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ad:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b5:	39 d0                	cmp    %edx,%eax
  8001b7:	72 11                	jb     8001ca <printnum+0x3a>
  8001b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001bc:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8001bf:	76 09                	jbe    8001ca <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c1:	83 eb 01             	sub    $0x1,%ebx
  8001c4:	85 db                	test   %ebx,%ebx
  8001c6:	7f 5d                	jg     800225 <printnum+0x95>
  8001c8:	eb 6c                	jmp    800236 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ca:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001ce:	83 eb 01             	sub    $0x1,%ebx
  8001d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001dc:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001e0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8001ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f1:	00 
  8001f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001f5:	89 14 24             	mov    %edx,(%esp)
  8001f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8001fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8001ff:	e8 6c 0d 00 00       	call   800f70 <__udivdi3>
  800204:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800207:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80020a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80020e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800212:	89 04 24             	mov    %eax,(%esp)
  800215:	89 54 24 04          	mov    %edx,0x4(%esp)
  800219:	89 f2                	mov    %esi,%edx
  80021b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021e:	e8 6d ff ff ff       	call   800190 <printnum>
  800223:	eb 11                	jmp    800236 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800225:	89 74 24 04          	mov    %esi,0x4(%esp)
  800229:	89 3c 24             	mov    %edi,(%esp)
  80022c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022f:	83 eb 01             	sub    $0x1,%ebx
  800232:	85 db                	test   %ebx,%ebx
  800234:	7f ef                	jg     800225 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800236:	89 74 24 04          	mov    %esi,0x4(%esp)
  80023a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80023e:	8b 45 10             	mov    0x10(%ebp),%eax
  800241:	89 44 24 08          	mov    %eax,0x8(%esp)
  800245:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024c:	00 
  80024d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800250:	89 14 24             	mov    %edx,(%esp)
  800253:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800256:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80025a:	e8 21 0e 00 00       	call   801080 <__umoddi3>
  80025f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800263:	0f be 80 f8 11 80 00 	movsbl 0x8011f8(%eax),%eax
  80026a:	89 04 24             	mov    %eax,(%esp)
  80026d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800270:	83 c4 4c             	add    $0x4c,%esp
  800273:	5b                   	pop    %ebx
  800274:	5e                   	pop    %esi
  800275:	5f                   	pop    %edi
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    

00800278 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027b:	83 fa 01             	cmp    $0x1,%edx
  80027e:	7e 0e                	jle    80028e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800280:	8b 10                	mov    (%eax),%edx
  800282:	8d 4a 08             	lea    0x8(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 02                	mov    (%edx),%eax
  800289:	8b 52 04             	mov    0x4(%edx),%edx
  80028c:	eb 22                	jmp    8002b0 <getuint+0x38>
	else if (lflag)
  80028e:	85 d2                	test   %edx,%edx
  800290:	74 10                	je     8002a2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800292:	8b 10                	mov    (%eax),%edx
  800294:	8d 4a 04             	lea    0x4(%edx),%ecx
  800297:	89 08                	mov    %ecx,(%eax)
  800299:	8b 02                	mov    (%edx),%eax
  80029b:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a0:	eb 0e                	jmp    8002b0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a2:	8b 10                	mov    (%eax),%edx
  8002a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a7:	89 08                	mov    %ecx,(%eax)
  8002a9:	8b 02                	mov    (%edx),%eax
  8002ab:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b5:	83 fa 01             	cmp    $0x1,%edx
  8002b8:	7e 0e                	jle    8002c8 <getint+0x16>
		return va_arg(*ap, long long);
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bf:	89 08                	mov    %ecx,(%eax)
  8002c1:	8b 02                	mov    (%edx),%eax
  8002c3:	8b 52 04             	mov    0x4(%edx),%edx
  8002c6:	eb 22                	jmp    8002ea <getint+0x38>
	else if (lflag)
  8002c8:	85 d2                	test   %edx,%edx
  8002ca:	74 10                	je     8002dc <getint+0x2a>
		return va_arg(*ap, long);
  8002cc:	8b 10                	mov    (%eax),%edx
  8002ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d1:	89 08                	mov    %ecx,(%eax)
  8002d3:	8b 02                	mov    (%edx),%eax
  8002d5:	89 c2                	mov    %eax,%edx
  8002d7:	c1 fa 1f             	sar    $0x1f,%edx
  8002da:	eb 0e                	jmp    8002ea <getint+0x38>
	else
		return va_arg(*ap, int);
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e1:	89 08                	mov    %ecx,(%eax)
  8002e3:	8b 02                	mov    (%edx),%eax
  8002e5:	89 c2                	mov    %eax,%edx
  8002e7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fb:	73 0a                	jae    800307 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800300:	88 0a                	mov    %cl,(%edx)
  800302:	83 c2 01             	add    $0x1,%edx
  800305:	89 10                	mov    %edx,(%eax)
}
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80030f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800312:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800316:	8b 45 10             	mov    0x10(%ebp),%eax
  800319:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800320:	89 44 24 04          	mov    %eax,0x4(%esp)
  800324:	8b 45 08             	mov    0x8(%ebp),%eax
  800327:	89 04 24             	mov    %eax,(%esp)
  80032a:	e8 02 00 00 00       	call   800331 <vprintfmt>
	va_end(ap);
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 4c             	sub    $0x4c,%esp
  80033a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033d:	eb 23                	jmp    800362 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80033f:	85 c0                	test   %eax,%eax
  800341:	75 12                	jne    800355 <vprintfmt+0x24>
				csa = 0x0700;
  800343:	c7 05 0c 20 80 00 00 	movl   $0x700,0x80200c
  80034a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80034d:	83 c4 4c             	add    $0x4c,%esp
  800350:	5b                   	pop    %ebx
  800351:	5e                   	pop    %esi
  800352:	5f                   	pop    %edi
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800355:	8b 55 0c             	mov    0xc(%ebp),%edx
  800358:	89 54 24 04          	mov    %edx,0x4(%esp)
  80035c:	89 04 24             	mov    %eax,(%esp)
  80035f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800362:	0f b6 07             	movzbl (%edi),%eax
  800365:	83 c7 01             	add    $0x1,%edi
  800368:	83 f8 25             	cmp    $0x25,%eax
  80036b:	75 d2                	jne    80033f <vprintfmt+0xe>
  80036d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800371:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800378:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80037d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800384:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800389:	be 00 00 00 00       	mov    $0x0,%esi
  80038e:	eb 14                	jmp    8003a4 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800390:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800394:	eb 0e                	jmp    8003a4 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800396:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80039a:	eb 08                	jmp    8003a4 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80039c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80039f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	0f b6 07             	movzbl (%edi),%eax
  8003a7:	0f b6 c8             	movzbl %al,%ecx
  8003aa:	83 c7 01             	add    $0x1,%edi
  8003ad:	83 e8 23             	sub    $0x23,%eax
  8003b0:	3c 55                	cmp    $0x55,%al
  8003b2:	0f 87 ed 02 00 00    	ja     8006a5 <vprintfmt+0x374>
  8003b8:	0f b6 c0             	movzbl %al,%eax
  8003bb:	ff 24 85 c0 12 80 00 	jmp    *0x8012c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  8003c5:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003c8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003cb:	83 f9 09             	cmp    $0x9,%ecx
  8003ce:	77 3c                	ja     80040c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003d3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8003d6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8003da:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003dd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003e0:	83 f9 09             	cmp    $0x9,%ecx
  8003e3:	76 eb                	jbe    8003d0 <vprintfmt+0x9f>
  8003e5:	eb 25                	jmp    80040c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ea:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ed:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  8003f2:	eb 18                	jmp    80040c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  8003f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003fb:	0f 48 c6             	cmovs  %esi,%eax
  8003fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800401:	eb a1                	jmp    8003a4 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  800403:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80040a:	eb 98                	jmp    8003a4 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  80040c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800410:	79 92                	jns    8003a4 <vprintfmt+0x73>
  800412:	eb 88                	jmp    80039c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800414:	83 c2 01             	add    $0x1,%edx
  800417:	eb 8b                	jmp    8003a4 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800419:	8b 45 14             	mov    0x14(%ebp),%eax
  80041c:	8d 50 04             	lea    0x4(%eax),%edx
  80041f:	89 55 14             	mov    %edx,0x14(%ebp)
  800422:	8b 55 0c             	mov    0xc(%ebp),%edx
  800425:	89 54 24 04          	mov    %edx,0x4(%esp)
  800429:	8b 00                	mov    (%eax),%eax
  80042b:	89 04 24             	mov    %eax,(%esp)
  80042e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800431:	e9 2c ff ff ff       	jmp    800362 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 50 04             	lea    0x4(%eax),%edx
  80043c:	89 55 14             	mov    %edx,0x14(%ebp)
  80043f:	8b 00                	mov    (%eax),%eax
  800441:	89 c2                	mov    %eax,%edx
  800443:	c1 fa 1f             	sar    $0x1f,%edx
  800446:	31 d0                	xor    %edx,%eax
  800448:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044a:	83 f8 08             	cmp    $0x8,%eax
  80044d:	7f 0b                	jg     80045a <vprintfmt+0x129>
  80044f:	8b 14 85 20 14 80 00 	mov    0x801420(,%eax,4),%edx
  800456:	85 d2                	test   %edx,%edx
  800458:	75 23                	jne    80047d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80045a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045e:	c7 44 24 08 10 12 80 	movl   $0x801210,0x8(%esp)
  800465:	00 
  800466:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800469:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80046d:	8b 45 08             	mov    0x8(%ebp),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	e8 91 fe ff ff       	call   800309 <printfmt>
  800478:	e9 e5 fe ff ff       	jmp    800362 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80047d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800481:	c7 44 24 08 19 12 80 	movl   $0x801219,0x8(%esp)
  800488:	00 
  800489:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800490:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800493:	89 1c 24             	mov    %ebx,(%esp)
  800496:	e8 6e fe ff ff       	call   800309 <printfmt>
  80049b:	e9 c2 fe ff ff       	jmp    800362 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004b4:	85 f6                	test   %esi,%esi
  8004b6:	ba 09 12 80 00       	mov    $0x801209,%edx
  8004bb:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8004be:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c2:	7e 06                	jle    8004ca <vprintfmt+0x199>
  8004c4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004c8:	75 13                	jne    8004dd <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ca:	0f be 06             	movsbl (%esi),%eax
  8004cd:	83 c6 01             	add    $0x1,%esi
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	0f 85 a2 00 00 00    	jne    80057a <vprintfmt+0x249>
  8004d8:	e9 92 00 00 00       	jmp    80056f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e1:	89 34 24             	mov    %esi,(%esp)
  8004e4:	e8 82 02 00 00       	call   80076b <strnlen>
  8004e9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004ec:	29 c2                	sub    %eax,%edx
  8004ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004f1:	85 d2                	test   %edx,%edx
  8004f3:	7e d5                	jle    8004ca <vprintfmt+0x199>
					putch(padc, putdat);
  8004f5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8004f9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004fc:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8004ff:	89 d3                	mov    %edx,%ebx
  800501:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800504:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800507:	89 c6                	mov    %eax,%esi
  800509:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80050d:	89 34 24             	mov    %esi,(%esp)
  800510:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800513:	83 eb 01             	sub    $0x1,%ebx
  800516:	85 db                	test   %ebx,%ebx
  800518:	7f ef                	jg     800509 <vprintfmt+0x1d8>
  80051a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80051d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800520:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800523:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80052a:	eb 9e                	jmp    8004ca <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800530:	74 1b                	je     80054d <vprintfmt+0x21c>
  800532:	8d 50 e0             	lea    -0x20(%eax),%edx
  800535:	83 fa 5e             	cmp    $0x5e,%edx
  800538:	76 13                	jbe    80054d <vprintfmt+0x21c>
					putch('?', putdat);
  80053a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80053d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800541:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800548:	ff 55 08             	call   *0x8(%ebp)
  80054b:	eb 0d                	jmp    80055a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80054d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800550:	89 54 24 04          	mov    %edx,0x4(%esp)
  800554:	89 04 24             	mov    %eax,(%esp)
  800557:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055a:	83 ef 01             	sub    $0x1,%edi
  80055d:	0f be 06             	movsbl (%esi),%eax
  800560:	85 c0                	test   %eax,%eax
  800562:	74 05                	je     800569 <vprintfmt+0x238>
  800564:	83 c6 01             	add    $0x1,%esi
  800567:	eb 17                	jmp    800580 <vprintfmt+0x24f>
  800569:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80056c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800573:	7f 1c                	jg     800591 <vprintfmt+0x260>
  800575:	e9 e8 fd ff ff       	jmp    800362 <vprintfmt+0x31>
  80057a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80057d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800580:	85 db                	test   %ebx,%ebx
  800582:	78 a8                	js     80052c <vprintfmt+0x1fb>
  800584:	83 eb 01             	sub    $0x1,%ebx
  800587:	79 a3                	jns    80052c <vprintfmt+0x1fb>
  800589:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80058c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80058f:	eb de                	jmp    80056f <vprintfmt+0x23e>
  800591:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800594:	8b 7d 08             	mov    0x8(%ebp),%edi
  800597:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a7:	83 eb 01             	sub    $0x1,%ebx
  8005aa:	85 db                	test   %ebx,%ebx
  8005ac:	7f ec                	jg     80059a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ae:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005b1:	e9 ac fd ff ff       	jmp    800362 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b9:	e8 f4 fc ff ff       	call   8002b2 <getint>
  8005be:	89 c3                	mov    %eax,%ebx
  8005c0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005c2:	85 d2                	test   %edx,%edx
  8005c4:	78 0a                	js     8005d0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005cb:	e9 87 00 00 00       	jmp    800657 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005de:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005e1:	89 d8                	mov    %ebx,%eax
  8005e3:	89 f2                	mov    %esi,%edx
  8005e5:	f7 d8                	neg    %eax
  8005e7:	83 d2 00             	adc    $0x0,%edx
  8005ea:	f7 da                	neg    %edx
			}
			base = 10;
  8005ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005f1:	eb 64                	jmp    800657 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 7d fc ff ff       	call   800278 <getuint>
			base = 10;
  8005fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800600:	eb 55                	jmp    800657 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
  800605:	e8 6e fc ff ff       	call   800278 <getuint>
      base = 8;
  80060a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80060f:	eb 46                	jmp    800657 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800611:	8b 55 0c             	mov    0xc(%ebp),%edx
  800614:	89 54 24 04          	mov    %edx,0x4(%esp)
  800618:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800622:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800625:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800629:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800630:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8d 50 04             	lea    0x4(%eax),%edx
  800639:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063c:	8b 00                	mov    (%eax),%eax
  80063e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800643:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800648:	eb 0d                	jmp    800657 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064a:	8d 45 14             	lea    0x14(%ebp),%eax
  80064d:	e8 26 fc ff ff       	call   800278 <getuint>
			base = 16;
  800652:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800657:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80065b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80065f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800662:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800666:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80066a:	89 04 24             	mov    %eax,(%esp)
  80066d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800671:	8b 55 0c             	mov    0xc(%ebp),%edx
  800674:	8b 45 08             	mov    0x8(%ebp),%eax
  800677:	e8 14 fb ff ff       	call   800190 <printnum>
			break;
  80067c:	e9 e1 fc ff ff       	jmp    800362 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800681:	8b 45 0c             	mov    0xc(%ebp),%eax
  800684:	89 44 24 04          	mov    %eax,0x4(%esp)
  800688:	89 0c 24             	mov    %ecx,(%esp)
  80068b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80068e:	e9 cf fc ff ff       	jmp    800362 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
  800696:	e8 17 fc ff ff       	call   8002b2 <getint>
			csa = num;
  80069b:	a3 0c 20 80 00       	mov    %eax,0x80200c
			break;
  8006a0:	e9 bd fc ff ff       	jmp    800362 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ac:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b6:	83 ef 01             	sub    $0x1,%edi
  8006b9:	eb 02                	jmp    8006bd <vprintfmt+0x38c>
  8006bb:	89 c7                	mov    %eax,%edi
  8006bd:	8d 47 ff             	lea    -0x1(%edi),%eax
  8006c0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c4:	75 f5                	jne    8006bb <vprintfmt+0x38a>
  8006c6:	e9 97 fc ff ff       	jmp    800362 <vprintfmt+0x31>

008006cb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	83 ec 28             	sub    $0x28,%esp
  8006d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006da:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006de:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	74 30                	je     80071c <vsnprintf+0x51>
  8006ec:	85 d2                	test   %edx,%edx
  8006ee:	7e 2c                	jle    80071c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800701:	89 44 24 04          	mov    %eax,0x4(%esp)
  800705:	c7 04 24 ec 02 80 00 	movl   $0x8002ec,(%esp)
  80070c:	e8 20 fc ff ff       	call   800331 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800711:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800714:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071a:	eb 05                	jmp    800721 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800730:	8b 45 10             	mov    0x10(%ebp),%eax
  800733:	89 44 24 08          	mov    %eax,0x8(%esp)
  800737:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	89 04 24             	mov    %eax,(%esp)
  800744:	e8 82 ff ff ff       	call   8006cb <vsnprintf>
	va_end(ap);

	return rc;
}
  800749:	c9                   	leave  
  80074a:	c3                   	ret    
  80074b:	00 00                	add    %al,(%eax)
  80074d:	00 00                	add    %al,(%eax)
	...

00800750 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
  80075b:	80 3a 00             	cmpb   $0x0,(%edx)
  80075e:	74 09                	je     800769 <strlen+0x19>
		n++;
  800760:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800763:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800767:	75 f7                	jne    800760 <strlen+0x10>
		n++;
	return n;
}
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800771:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800774:	b8 00 00 00 00       	mov    $0x0,%eax
  800779:	85 d2                	test   %edx,%edx
  80077b:	74 12                	je     80078f <strnlen+0x24>
  80077d:	80 39 00             	cmpb   $0x0,(%ecx)
  800780:	74 0d                	je     80078f <strnlen+0x24>
		n++;
  800782:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800785:	39 d0                	cmp    %edx,%eax
  800787:	74 06                	je     80078f <strnlen+0x24>
  800789:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80078d:	75 f3                	jne    800782 <strnlen+0x17>
		n++;
	return n;
}
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	53                   	push   %ebx
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079b:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007a4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007a7:	83 c2 01             	add    $0x1,%edx
  8007aa:	84 c9                	test   %cl,%cl
  8007ac:	75 f2                	jne    8007a0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007ae:	5b                   	pop    %ebx
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bb:	89 1c 24             	mov    %ebx,(%esp)
  8007be:	e8 8d ff ff ff       	call   800750 <strlen>
	strcpy(dst + len, src);
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ca:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007cd:	89 04 24             	mov    %eax,(%esp)
  8007d0:	e8 bc ff ff ff       	call   800791 <strcpy>
	return dst;
}
  8007d5:	89 d8                	mov    %ebx,%eax
  8007d7:	83 c4 08             	add    $0x8,%esp
  8007da:	5b                   	pop    %ebx
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	56                   	push   %esi
  8007e1:	53                   	push   %ebx
  8007e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007eb:	85 f6                	test   %esi,%esi
  8007ed:	74 18                	je     800807 <strncpy+0x2a>
  8007ef:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007f4:	0f b6 1a             	movzbl (%edx),%ebx
  8007f7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fa:	80 3a 01             	cmpb   $0x1,(%edx)
  8007fd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800800:	83 c1 01             	add    $0x1,%ecx
  800803:	39 ce                	cmp    %ecx,%esi
  800805:	77 ed                	ja     8007f4 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800807:	5b                   	pop    %ebx
  800808:	5e                   	pop    %esi
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	56                   	push   %esi
  80080f:	53                   	push   %ebx
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 55 0c             	mov    0xc(%ebp),%edx
  800816:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800819:	89 f0                	mov    %esi,%eax
  80081b:	85 c9                	test   %ecx,%ecx
  80081d:	74 23                	je     800842 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  80081f:	83 e9 01             	sub    $0x1,%ecx
  800822:	74 1b                	je     80083f <strlcpy+0x34>
  800824:	0f b6 1a             	movzbl (%edx),%ebx
  800827:	84 db                	test   %bl,%bl
  800829:	74 14                	je     80083f <strlcpy+0x34>
			*dst++ = *src++;
  80082b:	88 18                	mov    %bl,(%eax)
  80082d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800830:	83 e9 01             	sub    $0x1,%ecx
  800833:	74 0a                	je     80083f <strlcpy+0x34>
			*dst++ = *src++;
  800835:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800838:	0f b6 1a             	movzbl (%edx),%ebx
  80083b:	84 db                	test   %bl,%bl
  80083d:	75 ec                	jne    80082b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80083f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800842:	29 f0                	sub    %esi,%eax
}
  800844:	5b                   	pop    %ebx
  800845:	5e                   	pop    %esi
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800851:	0f b6 01             	movzbl (%ecx),%eax
  800854:	84 c0                	test   %al,%al
  800856:	74 15                	je     80086d <strcmp+0x25>
  800858:	3a 02                	cmp    (%edx),%al
  80085a:	75 11                	jne    80086d <strcmp+0x25>
		p++, q++;
  80085c:	83 c1 01             	add    $0x1,%ecx
  80085f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800862:	0f b6 01             	movzbl (%ecx),%eax
  800865:	84 c0                	test   %al,%al
  800867:	74 04                	je     80086d <strcmp+0x25>
  800869:	3a 02                	cmp    (%edx),%al
  80086b:	74 ef                	je     80085c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086d:	0f b6 c0             	movzbl %al,%eax
  800870:	0f b6 12             	movzbl (%edx),%edx
  800873:	29 d0                	sub    %edx,%eax
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800881:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800889:	85 d2                	test   %edx,%edx
  80088b:	74 28                	je     8008b5 <strncmp+0x3e>
  80088d:	0f b6 01             	movzbl (%ecx),%eax
  800890:	84 c0                	test   %al,%al
  800892:	74 24                	je     8008b8 <strncmp+0x41>
  800894:	3a 03                	cmp    (%ebx),%al
  800896:	75 20                	jne    8008b8 <strncmp+0x41>
  800898:	83 ea 01             	sub    $0x1,%edx
  80089b:	74 13                	je     8008b0 <strncmp+0x39>
		n--, p++, q++;
  80089d:	83 c1 01             	add    $0x1,%ecx
  8008a0:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a3:	0f b6 01             	movzbl (%ecx),%eax
  8008a6:	84 c0                	test   %al,%al
  8008a8:	74 0e                	je     8008b8 <strncmp+0x41>
  8008aa:	3a 03                	cmp    (%ebx),%al
  8008ac:	74 ea                	je     800898 <strncmp+0x21>
  8008ae:	eb 08                	jmp    8008b8 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b5:	5b                   	pop    %ebx
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 01             	movzbl (%ecx),%eax
  8008bb:	0f b6 13             	movzbl (%ebx),%edx
  8008be:	29 d0                	sub    %edx,%eax
  8008c0:	eb f3                	jmp    8008b5 <strncmp+0x3e>

008008c2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cc:	0f b6 10             	movzbl (%eax),%edx
  8008cf:	84 d2                	test   %dl,%dl
  8008d1:	74 20                	je     8008f3 <strchr+0x31>
		if (*s == c)
  8008d3:	38 ca                	cmp    %cl,%dl
  8008d5:	75 0b                	jne    8008e2 <strchr+0x20>
  8008d7:	eb 1f                	jmp    8008f8 <strchr+0x36>
  8008d9:	38 ca                	cmp    %cl,%dl
  8008db:	90                   	nop
  8008dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8008e0:	74 16                	je     8008f8 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e2:	83 c0 01             	add    $0x1,%eax
  8008e5:	0f b6 10             	movzbl (%eax),%edx
  8008e8:	84 d2                	test   %dl,%dl
  8008ea:	75 ed                	jne    8008d9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f1:	eb 05                	jmp    8008f8 <strchr+0x36>
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	0f b6 10             	movzbl (%eax),%edx
  800907:	84 d2                	test   %dl,%dl
  800909:	74 14                	je     80091f <strfind+0x25>
		if (*s == c)
  80090b:	38 ca                	cmp    %cl,%dl
  80090d:	75 06                	jne    800915 <strfind+0x1b>
  80090f:	eb 0e                	jmp    80091f <strfind+0x25>
  800911:	38 ca                	cmp    %cl,%dl
  800913:	74 0a                	je     80091f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	0f b6 10             	movzbl (%eax),%edx
  80091b:	84 d2                	test   %dl,%dl
  80091d:	75 f2                	jne    800911 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	83 ec 0c             	sub    $0xc,%esp
  800927:	89 1c 24             	mov    %ebx,(%esp)
  80092a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80092e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800932:	8b 7d 08             	mov    0x8(%ebp),%edi
  800935:	8b 45 0c             	mov    0xc(%ebp),%eax
  800938:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093b:	85 c9                	test   %ecx,%ecx
  80093d:	74 30                	je     80096f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800945:	75 25                	jne    80096c <memset+0x4b>
  800947:	f6 c1 03             	test   $0x3,%cl
  80094a:	75 20                	jne    80096c <memset+0x4b>
		c &= 0xFF;
  80094c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094f:	89 d3                	mov    %edx,%ebx
  800951:	c1 e3 08             	shl    $0x8,%ebx
  800954:	89 d6                	mov    %edx,%esi
  800956:	c1 e6 18             	shl    $0x18,%esi
  800959:	89 d0                	mov    %edx,%eax
  80095b:	c1 e0 10             	shl    $0x10,%eax
  80095e:	09 f0                	or     %esi,%eax
  800960:	09 d0                	or     %edx,%eax
  800962:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800964:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800967:	fc                   	cld    
  800968:	f3 ab                	rep stos %eax,%es:(%edi)
  80096a:	eb 03                	jmp    80096f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096c:	fc                   	cld    
  80096d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096f:	89 f8                	mov    %edi,%eax
  800971:	8b 1c 24             	mov    (%esp),%ebx
  800974:	8b 74 24 04          	mov    0x4(%esp),%esi
  800978:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80097c:	89 ec                	mov    %ebp,%esp
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	83 ec 08             	sub    $0x8,%esp
  800986:	89 34 24             	mov    %esi,(%esp)
  800989:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 75 0c             	mov    0xc(%ebp),%esi
  800993:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800996:	39 c6                	cmp    %eax,%esi
  800998:	73 36                	jae    8009d0 <memmove+0x50>
  80099a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099d:	39 d0                	cmp    %edx,%eax
  80099f:	73 2f                	jae    8009d0 <memmove+0x50>
		s += n;
		d += n;
  8009a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f6 c2 03             	test   $0x3,%dl
  8009a7:	75 1b                	jne    8009c4 <memmove+0x44>
  8009a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009af:	75 13                	jne    8009c4 <memmove+0x44>
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 0e                	jne    8009c4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b6:	83 ef 04             	sub    $0x4,%edi
  8009b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009bf:	fd                   	std    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb 09                	jmp    8009cd <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c4:	83 ef 01             	sub    $0x1,%edi
  8009c7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ca:	fd                   	std    
  8009cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cd:	fc                   	cld    
  8009ce:	eb 20                	jmp    8009f0 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d6:	75 13                	jne    8009eb <memmove+0x6b>
  8009d8:	a8 03                	test   $0x3,%al
  8009da:	75 0f                	jne    8009eb <memmove+0x6b>
  8009dc:	f6 c1 03             	test   $0x3,%cl
  8009df:	75 0a                	jne    8009eb <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e4:	89 c7                	mov    %eax,%edi
  8009e6:	fc                   	cld    
  8009e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e9:	eb 05                	jmp    8009f0 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009eb:	89 c7                	mov    %eax,%edi
  8009ed:	fc                   	cld    
  8009ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f0:	8b 34 24             	mov    (%esp),%esi
  8009f3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8009f7:	89 ec                	mov    %ebp,%esp
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a01:	8b 45 10             	mov    0x10(%ebp),%eax
  800a04:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	89 04 24             	mov    %eax,(%esp)
  800a15:	e8 66 ff ff ff       	call   800980 <memmove>
}
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a28:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a30:	85 ff                	test   %edi,%edi
  800a32:	74 38                	je     800a6c <memcmp+0x50>
		if (*s1 != *s2)
  800a34:	0f b6 03             	movzbl (%ebx),%eax
  800a37:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3a:	83 ef 01             	sub    $0x1,%edi
  800a3d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a42:	38 c8                	cmp    %cl,%al
  800a44:	74 1d                	je     800a63 <memcmp+0x47>
  800a46:	eb 11                	jmp    800a59 <memcmp+0x3d>
  800a48:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a4d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800a52:	83 c2 01             	add    $0x1,%edx
  800a55:	38 c8                	cmp    %cl,%al
  800a57:	74 0a                	je     800a63 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800a59:	0f b6 c0             	movzbl %al,%eax
  800a5c:	0f b6 c9             	movzbl %cl,%ecx
  800a5f:	29 c8                	sub    %ecx,%eax
  800a61:	eb 09                	jmp    800a6c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a63:	39 fa                	cmp    %edi,%edx
  800a65:	75 e1                	jne    800a48 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5f                   	pop    %edi
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a77:	89 c2                	mov    %eax,%edx
  800a79:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a7c:	39 d0                	cmp    %edx,%eax
  800a7e:	73 15                	jae    800a95 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a84:	38 08                	cmp    %cl,(%eax)
  800a86:	75 06                	jne    800a8e <memfind+0x1d>
  800a88:	eb 0b                	jmp    800a95 <memfind+0x24>
  800a8a:	38 08                	cmp    %cl,(%eax)
  800a8c:	74 07                	je     800a95 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8e:	83 c0 01             	add    $0x1,%eax
  800a91:	39 c2                	cmp    %eax,%edx
  800a93:	77 f5                	ja     800a8a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa3:	0f b6 02             	movzbl (%edx),%eax
  800aa6:	3c 20                	cmp    $0x20,%al
  800aa8:	74 04                	je     800aae <strtol+0x17>
  800aaa:	3c 09                	cmp    $0x9,%al
  800aac:	75 0e                	jne    800abc <strtol+0x25>
		s++;
  800aae:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab1:	0f b6 02             	movzbl (%edx),%eax
  800ab4:	3c 20                	cmp    $0x20,%al
  800ab6:	74 f6                	je     800aae <strtol+0x17>
  800ab8:	3c 09                	cmp    $0x9,%al
  800aba:	74 f2                	je     800aae <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800abc:	3c 2b                	cmp    $0x2b,%al
  800abe:	75 0a                	jne    800aca <strtol+0x33>
		s++;
  800ac0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac8:	eb 10                	jmp    800ada <strtol+0x43>
  800aca:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800acf:	3c 2d                	cmp    $0x2d,%al
  800ad1:	75 07                	jne    800ada <strtol+0x43>
		s++, neg = 1;
  800ad3:	83 c2 01             	add    $0x1,%edx
  800ad6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ada:	85 db                	test   %ebx,%ebx
  800adc:	0f 94 c0             	sete   %al
  800adf:	74 05                	je     800ae6 <strtol+0x4f>
  800ae1:	83 fb 10             	cmp    $0x10,%ebx
  800ae4:	75 15                	jne    800afb <strtol+0x64>
  800ae6:	80 3a 30             	cmpb   $0x30,(%edx)
  800ae9:	75 10                	jne    800afb <strtol+0x64>
  800aeb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aef:	75 0a                	jne    800afb <strtol+0x64>
		s += 2, base = 16;
  800af1:	83 c2 02             	add    $0x2,%edx
  800af4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af9:	eb 13                	jmp    800b0e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800afb:	84 c0                	test   %al,%al
  800afd:	74 0f                	je     800b0e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aff:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b04:	80 3a 30             	cmpb   $0x30,(%edx)
  800b07:	75 05                	jne    800b0e <strtol+0x77>
		s++, base = 8;
  800b09:	83 c2 01             	add    $0x1,%edx
  800b0c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b13:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b15:	0f b6 0a             	movzbl (%edx),%ecx
  800b18:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b1b:	80 fb 09             	cmp    $0x9,%bl
  800b1e:	77 08                	ja     800b28 <strtol+0x91>
			dig = *s - '0';
  800b20:	0f be c9             	movsbl %cl,%ecx
  800b23:	83 e9 30             	sub    $0x30,%ecx
  800b26:	eb 1e                	jmp    800b46 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b28:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b2b:	80 fb 19             	cmp    $0x19,%bl
  800b2e:	77 08                	ja     800b38 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b30:	0f be c9             	movsbl %cl,%ecx
  800b33:	83 e9 57             	sub    $0x57,%ecx
  800b36:	eb 0e                	jmp    800b46 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b38:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b3b:	80 fb 19             	cmp    $0x19,%bl
  800b3e:	77 15                	ja     800b55 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800b40:	0f be c9             	movsbl %cl,%ecx
  800b43:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b46:	39 f1                	cmp    %esi,%ecx
  800b48:	7d 0f                	jge    800b59 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800b4a:	83 c2 01             	add    $0x1,%edx
  800b4d:	0f af c6             	imul   %esi,%eax
  800b50:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b53:	eb c0                	jmp    800b15 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b55:	89 c1                	mov    %eax,%ecx
  800b57:	eb 02                	jmp    800b5b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b59:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5f:	74 05                	je     800b66 <strtol+0xcf>
		*endptr = (char *) s;
  800b61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b64:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b66:	89 ca                	mov    %ecx,%edx
  800b68:	f7 da                	neg    %edx
  800b6a:	85 ff                	test   %edi,%edi
  800b6c:	0f 45 c2             	cmovne %edx,%eax
}
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	83 ec 0c             	sub    $0xc,%esp
  800b7a:	89 1c 24             	mov    %ebx,(%esp)
  800b7d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b81:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b90:	89 c3                	mov    %eax,%ebx
  800b92:	89 c7                	mov    %eax,%edi
  800b94:	89 c6                	mov    %eax,%esi
  800b96:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b98:	8b 1c 24             	mov    (%esp),%ebx
  800b9b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b9f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ba3:	89 ec                	mov    %ebp,%esp
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	83 ec 0c             	sub    $0xc,%esp
  800bad:	89 1c 24             	mov    %ebx,(%esp)
  800bb0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bb4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc2:	89 d1                	mov    %edx,%ecx
  800bc4:	89 d3                	mov    %edx,%ebx
  800bc6:	89 d7                	mov    %edx,%edi
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bcc:	8b 1c 24             	mov    (%esp),%ebx
  800bcf:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bd3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bd7:	89 ec                	mov    %ebp,%esp
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	83 ec 38             	sub    $0x38,%esp
  800be1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800be4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800be7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bef:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	89 cb                	mov    %ecx,%ebx
  800bf9:	89 cf                	mov    %ecx,%edi
  800bfb:	89 ce                	mov    %ecx,%esi
  800bfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7e 28                	jle    800c2b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c07:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c0e:	00 
  800c0f:	c7 44 24 08 44 14 80 	movl   $0x801444,0x8(%esp)
  800c16:	00 
  800c17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c1e:	00 
  800c1f:	c7 04 24 61 14 80 00 	movl   $0x801461,(%esp)
  800c26:	e8 e1 02 00 00       	call   800f0c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c2b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c2e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c31:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c34:	89 ec                	mov    %ebp,%esp
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	83 ec 0c             	sub    $0xc,%esp
  800c3e:	89 1c 24             	mov    %ebx,(%esp)
  800c41:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c45:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c53:	89 d1                	mov    %edx,%ecx
  800c55:	89 d3                	mov    %edx,%ebx
  800c57:	89 d7                	mov    %edx,%edi
  800c59:	89 d6                	mov    %edx,%esi
  800c5b:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800c5d:	8b 1c 24             	mov    (%esp),%ebx
  800c60:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c64:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c68:	89 ec                	mov    %ebp,%esp
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <sys_yield>:

void
sys_yield(void)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	83 ec 0c             	sub    $0xc,%esp
  800c72:	89 1c 24             	mov    %ebx,(%esp)
  800c75:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c79:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c82:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c87:	89 d1                	mov    %edx,%ecx
  800c89:	89 d3                	mov    %edx,%ebx
  800c8b:	89 d7                	mov    %edx,%edi
  800c8d:	89 d6                	mov    %edx,%esi
  800c8f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c91:	8b 1c 24             	mov    (%esp),%ebx
  800c94:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c98:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c9c:	89 ec                	mov    %ebp,%esp
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	83 ec 38             	sub    $0x38,%esp
  800ca6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ca9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cac:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	be 00 00 00 00       	mov    $0x0,%esi
  800cb4:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	89 f7                	mov    %esi,%edi
  800cc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 28                	jle    800cf2 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cce:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cd5:	00 
  800cd6:	c7 44 24 08 44 14 80 	movl   $0x801444,0x8(%esp)
  800cdd:	00 
  800cde:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce5:	00 
  800ce6:	c7 04 24 61 14 80 00 	movl   $0x801461,(%esp)
  800ced:	e8 1a 02 00 00       	call   800f0c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cfb:	89 ec                	mov    %ebp,%esp
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 38             	sub    $0x38,%esp
  800d05:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d08:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d0b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d13:	8b 75 18             	mov    0x18(%ebp),%esi
  800d16:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	7e 28                	jle    800d50 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d33:	00 
  800d34:	c7 44 24 08 44 14 80 	movl   $0x801444,0x8(%esp)
  800d3b:	00 
  800d3c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d43:	00 
  800d44:	c7 04 24 61 14 80 00 	movl   $0x801461,(%esp)
  800d4b:	e8 bc 01 00 00       	call   800f0c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d50:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d53:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d56:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d59:	89 ec                	mov    %ebp,%esp
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	83 ec 38             	sub    $0x38,%esp
  800d63:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d66:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d69:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d71:	b8 06 00 00 00       	mov    $0x6,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 df                	mov    %ebx,%edi
  800d7e:	89 de                	mov    %ebx,%esi
  800d80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 28                	jle    800dae <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d91:	00 
  800d92:	c7 44 24 08 44 14 80 	movl   $0x801444,0x8(%esp)
  800d99:	00 
  800d9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da1:	00 
  800da2:	c7 04 24 61 14 80 00 	movl   $0x801461,(%esp)
  800da9:	e8 5e 01 00 00       	call   800f0c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dae:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db7:	89 ec                	mov    %ebp,%esp
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	83 ec 38             	sub    $0x38,%esp
  800dc1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dc7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcf:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 df                	mov    %ebx,%edi
  800ddc:	89 de                	mov    %ebx,%esi
  800dde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de0:	85 c0                	test   %eax,%eax
  800de2:	7e 28                	jle    800e0c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de8:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800def:	00 
  800df0:	c7 44 24 08 44 14 80 	movl   $0x801444,0x8(%esp)
  800df7:	00 
  800df8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dff:	00 
  800e00:	c7 04 24 61 14 80 00 	movl   $0x801461,(%esp)
  800e07:	e8 00 01 00 00       	call   800f0c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e0f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e12:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e15:	89 ec                	mov    %ebp,%esp
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	83 ec 38             	sub    $0x38,%esp
  800e1f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e22:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e25:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e35:	8b 55 08             	mov    0x8(%ebp),%edx
  800e38:	89 df                	mov    %ebx,%edi
  800e3a:	89 de                	mov    %ebx,%esi
  800e3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	7e 28                	jle    800e6a <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e42:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e46:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e4d:	00 
  800e4e:	c7 44 24 08 44 14 80 	movl   $0x801444,0x8(%esp)
  800e55:	00 
  800e56:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5d:	00 
  800e5e:	c7 04 24 61 14 80 00 	movl   $0x801461,(%esp)
  800e65:	e8 a2 00 00 00       	call   800f0c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e6a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e6d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e70:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e73:	89 ec                	mov    %ebp,%esp
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	83 ec 0c             	sub    $0xc,%esp
  800e7d:	89 1c 24             	mov    %ebx,(%esp)
  800e80:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e84:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e88:	be 00 00 00 00       	mov    $0x0,%esi
  800e8d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea0:	8b 1c 24             	mov    (%esp),%ebx
  800ea3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ea7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800eab:	89 ec                	mov    %ebp,%esp
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	83 ec 38             	sub    $0x38,%esp
  800eb5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ebb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	89 cb                	mov    %ecx,%ebx
  800ecd:	89 cf                	mov    %ecx,%edi
  800ecf:	89 ce                	mov    %ecx,%esi
  800ed1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	7e 28                	jle    800eff <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edb:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 08 44 14 80 	movl   $0x801444,0x8(%esp)
  800eea:	00 
  800eeb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef2:	00 
  800ef3:	c7 04 24 61 14 80 00 	movl   $0x801461,(%esp)
  800efa:	e8 0d 00 00 00       	call   800f0c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f08:	89 ec                	mov    %ebp,%esp
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	56                   	push   %esi
  800f10:	53                   	push   %ebx
  800f11:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800f14:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f17:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f1d:	e8 16 fd ff ff       	call   800c38 <sys_getenvid>
  800f22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f25:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f29:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f30:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f38:	c7 04 24 70 14 80 00 	movl   $0x801470,(%esp)
  800f3f:	e8 2b f2 ff ff       	call   80016f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f48:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4b:	89 04 24             	mov    %eax,(%esp)
  800f4e:	e8 bb f1 ff ff       	call   80010e <vcprintf>
	cprintf("\n");
  800f53:	c7 04 24 ec 11 80 00 	movl   $0x8011ec,(%esp)
  800f5a:	e8 10 f2 ff ff       	call   80016f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f5f:	cc                   	int3   
  800f60:	eb fd                	jmp    800f5f <_panic+0x53>
	...

00800f70 <__udivdi3>:
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	57                   	push   %edi
  800f74:	56                   	push   %esi
  800f75:	83 ec 10             	sub    $0x10,%esp
  800f78:	8b 75 14             	mov    0x14(%ebp),%esi
  800f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f81:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f84:	85 f6                	test   %esi,%esi
  800f86:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f89:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f8f:	75 2f                	jne    800fc0 <__udivdi3+0x50>
  800f91:	39 f9                	cmp    %edi,%ecx
  800f93:	77 5b                	ja     800ff0 <__udivdi3+0x80>
  800f95:	85 c9                	test   %ecx,%ecx
  800f97:	75 0b                	jne    800fa4 <__udivdi3+0x34>
  800f99:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9e:	31 d2                	xor    %edx,%edx
  800fa0:	f7 f1                	div    %ecx
  800fa2:	89 c1                	mov    %eax,%ecx
  800fa4:	89 f8                	mov    %edi,%eax
  800fa6:	31 d2                	xor    %edx,%edx
  800fa8:	f7 f1                	div    %ecx
  800faa:	89 c7                	mov    %eax,%edi
  800fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800faf:	f7 f1                	div    %ecx
  800fb1:	89 fa                	mov    %edi,%edx
  800fb3:	83 c4 10             	add    $0x10,%esp
  800fb6:	5e                   	pop    %esi
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    
  800fba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc0:	31 d2                	xor    %edx,%edx
  800fc2:	31 c0                	xor    %eax,%eax
  800fc4:	39 fe                	cmp    %edi,%esi
  800fc6:	77 eb                	ja     800fb3 <__udivdi3+0x43>
  800fc8:	0f bd d6             	bsr    %esi,%edx
  800fcb:	83 f2 1f             	xor    $0x1f,%edx
  800fce:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fd1:	75 2d                	jne    801000 <__udivdi3+0x90>
  800fd3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800fd6:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  800fd9:	76 06                	jbe    800fe1 <__udivdi3+0x71>
  800fdb:	39 fe                	cmp    %edi,%esi
  800fdd:	89 c2                	mov    %eax,%edx
  800fdf:	73 d2                	jae    800fb3 <__udivdi3+0x43>
  800fe1:	31 d2                	xor    %edx,%edx
  800fe3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe8:	eb c9                	jmp    800fb3 <__udivdi3+0x43>
  800fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ff0:	89 fa                	mov    %edi,%edx
  800ff2:	f7 f1                	div    %ecx
  800ff4:	31 d2                	xor    %edx,%edx
  800ff6:	83 c4 10             	add    $0x10,%esp
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    
  800ffd:	8d 76 00             	lea    0x0(%esi),%esi
  801000:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801004:	b8 20 00 00 00       	mov    $0x20,%eax
  801009:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80100c:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80100f:	d3 e6                	shl    %cl,%esi
  801011:	89 c1                	mov    %eax,%ecx
  801013:	d3 ea                	shr    %cl,%edx
  801015:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801019:	09 f2                	or     %esi,%edx
  80101b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  80101e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801021:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801024:	d3 e2                	shl    %cl,%edx
  801026:	89 c1                	mov    %eax,%ecx
  801028:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80102b:	89 fa                	mov    %edi,%edx
  80102d:	d3 ea                	shr    %cl,%edx
  80102f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801033:	d3 e7                	shl    %cl,%edi
  801035:	89 c1                	mov    %eax,%ecx
  801037:	d3 ee                	shr    %cl,%esi
  801039:	09 fe                	or     %edi,%esi
  80103b:	89 f0                	mov    %esi,%eax
  80103d:	f7 75 e8             	divl   -0x18(%ebp)
  801040:	89 d7                	mov    %edx,%edi
  801042:	89 c6                	mov    %eax,%esi
  801044:	f7 65 f0             	mull   -0x10(%ebp)
  801047:	39 d7                	cmp    %edx,%edi
  801049:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80104c:	72 22                	jb     801070 <__udivdi3+0x100>
  80104e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801051:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801055:	d3 e2                	shl    %cl,%edx
  801057:	39 c2                	cmp    %eax,%edx
  801059:	73 05                	jae    801060 <__udivdi3+0xf0>
  80105b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80105e:	74 10                	je     801070 <__udivdi3+0x100>
  801060:	89 f0                	mov    %esi,%eax
  801062:	31 d2                	xor    %edx,%edx
  801064:	e9 4a ff ff ff       	jmp    800fb3 <__udivdi3+0x43>
  801069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801070:	8d 46 ff             	lea    -0x1(%esi),%eax
  801073:	31 d2                	xor    %edx,%edx
  801075:	83 c4 10             	add    $0x10,%esp
  801078:	5e                   	pop    %esi
  801079:	5f                   	pop    %edi
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    
  80107c:	00 00                	add    %al,(%eax)
	...

00801080 <__umoddi3>:
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	57                   	push   %edi
  801084:	56                   	push   %esi
  801085:	83 ec 20             	sub    $0x20,%esp
  801088:	8b 7d 14             	mov    0x14(%ebp),%edi
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
  80108e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801091:	8b 75 0c             	mov    0xc(%ebp),%esi
  801094:	85 ff                	test   %edi,%edi
  801096:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801099:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80109c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80109f:	89 f2                	mov    %esi,%edx
  8010a1:	75 15                	jne    8010b8 <__umoddi3+0x38>
  8010a3:	39 f1                	cmp    %esi,%ecx
  8010a5:	76 41                	jbe    8010e8 <__umoddi3+0x68>
  8010a7:	f7 f1                	div    %ecx
  8010a9:	89 d0                	mov    %edx,%eax
  8010ab:	31 d2                	xor    %edx,%edx
  8010ad:	83 c4 20             	add    $0x20,%esp
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    
  8010b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010b8:	39 f7                	cmp    %esi,%edi
  8010ba:	77 4c                	ja     801108 <__umoddi3+0x88>
  8010bc:	0f bd c7             	bsr    %edi,%eax
  8010bf:	83 f0 1f             	xor    $0x1f,%eax
  8010c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010c5:	75 51                	jne    801118 <__umoddi3+0x98>
  8010c7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8010ca:	0f 87 e8 00 00 00    	ja     8011b8 <__umoddi3+0x138>
  8010d0:	89 f2                	mov    %esi,%edx
  8010d2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8010d5:	29 ce                	sub    %ecx,%esi
  8010d7:	19 fa                	sbb    %edi,%edx
  8010d9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8010dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010df:	83 c4 20             	add    $0x20,%esp
  8010e2:	5e                   	pop    %esi
  8010e3:	5f                   	pop    %edi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    
  8010e6:	66 90                	xchg   %ax,%ax
  8010e8:	85 c9                	test   %ecx,%ecx
  8010ea:	75 0b                	jne    8010f7 <__umoddi3+0x77>
  8010ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f1:	31 d2                	xor    %edx,%edx
  8010f3:	f7 f1                	div    %ecx
  8010f5:	89 c1                	mov    %eax,%ecx
  8010f7:	89 f0                	mov    %esi,%eax
  8010f9:	31 d2                	xor    %edx,%edx
  8010fb:	f7 f1                	div    %ecx
  8010fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801100:	eb a5                	jmp    8010a7 <__umoddi3+0x27>
  801102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801108:	89 f2                	mov    %esi,%edx
  80110a:	83 c4 20             	add    $0x20,%esp
  80110d:	5e                   	pop    %esi
  80110e:	5f                   	pop    %edi
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    
  801111:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801118:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80111c:	89 f2                	mov    %esi,%edx
  80111e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801121:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801128:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80112b:	d3 e7                	shl    %cl,%edi
  80112d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801130:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801134:	d3 e8                	shr    %cl,%eax
  801136:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80113a:	09 f8                	or     %edi,%eax
  80113c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80113f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801142:	d3 e0                	shl    %cl,%eax
  801144:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801148:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80114b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80114e:	d3 ea                	shr    %cl,%edx
  801150:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801154:	d3 e6                	shl    %cl,%esi
  801156:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80115a:	d3 e8                	shr    %cl,%eax
  80115c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801160:	09 f0                	or     %esi,%eax
  801162:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801165:	f7 75 e4             	divl   -0x1c(%ebp)
  801168:	d3 e6                	shl    %cl,%esi
  80116a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80116d:	89 d6                	mov    %edx,%esi
  80116f:	f7 65 f4             	mull   -0xc(%ebp)
  801172:	89 d7                	mov    %edx,%edi
  801174:	89 c2                	mov    %eax,%edx
  801176:	39 fe                	cmp    %edi,%esi
  801178:	89 f9                	mov    %edi,%ecx
  80117a:	72 30                	jb     8011ac <__umoddi3+0x12c>
  80117c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80117f:	72 27                	jb     8011a8 <__umoddi3+0x128>
  801181:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801184:	29 d0                	sub    %edx,%eax
  801186:	19 ce                	sbb    %ecx,%esi
  801188:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80118c:	89 f2                	mov    %esi,%edx
  80118e:	d3 e8                	shr    %cl,%eax
  801190:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801194:	d3 e2                	shl    %cl,%edx
  801196:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80119a:	09 d0                	or     %edx,%eax
  80119c:	89 f2                	mov    %esi,%edx
  80119e:	d3 ea                	shr    %cl,%edx
  8011a0:	83 c4 20             	add    $0x20,%esp
  8011a3:	5e                   	pop    %esi
  8011a4:	5f                   	pop    %edi
  8011a5:	5d                   	pop    %ebp
  8011a6:	c3                   	ret    
  8011a7:	90                   	nop
  8011a8:	39 fe                	cmp    %edi,%esi
  8011aa:	75 d5                	jne    801181 <__umoddi3+0x101>
  8011ac:	89 f9                	mov    %edi,%ecx
  8011ae:	89 c2                	mov    %eax,%edx
  8011b0:	2b 55 f4             	sub    -0xc(%ebp),%edx
  8011b3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011b6:	eb c9                	jmp    801181 <__umoddi3+0x101>
  8011b8:	39 f7                	cmp    %esi,%edi
  8011ba:	0f 82 10 ff ff ff    	jb     8010d0 <__umoddi3+0x50>
  8011c0:	e9 17 ff ff ff       	jmp    8010dc <__umoddi3+0x5c>
