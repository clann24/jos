
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 1b 01 00 00       	call   80014c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 cc 0f 00 00       	call   80100e <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004f:	e8 c4 0c 00 00       	call   800d18 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 80 13 80 00 	movl   $0x801380,(%esp)
  800063:	e8 eb 01 00 00       	call   800253 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 a8 0c 00 00       	call   800d18 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 9a 13 80 00 	movl   $0x80139a,(%esp)
  80007f:	e8 cf 01 00 00       	call   800253 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 ab 0f 00 00       	call   801052 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 6e 0f 00 00       	call   801030 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 3c 0c 00 00       	call   800d18 <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 b0 13 80 00 	movl   $0x8013b0,(%esp)
  8000fa:	e8 54 01 00 00       	call   800253 <cprintf>
		if (val == 10)
  8000ff:	a1 04 20 80 00       	mov    0x802004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 38                	je     800141 <umain+0x10d>
			return;
		++val;
  800109:	83 c0 01             	add    $0x1,%eax
  80010c:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 1e 0f 00 00       	call   801052 <ipc_send>
		if (val == 10)
  800134:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  80013b:	0f 85 66 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  800141:	83 c4 4c             	add    $0x4c,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
  800152:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800155:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800158:	8b 75 08             	mov    0x8(%ebp),%esi
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80015e:	e8 b5 0b 00 00       	call   800d18 <sys_getenvid>
  800163:	25 ff 03 00 00       	and    $0x3ff,%eax
  800168:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800170:	a3 08 20 80 00       	mov    %eax,0x802008
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800175:	85 f6                	test   %esi,%esi
  800177:	7e 07                	jle    800180 <libmain+0x34>
		binaryname = argv[0];
  800179:	8b 03                	mov    (%ebx),%eax
  80017b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800180:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800184:	89 34 24             	mov    %esi,(%esp)
  800187:	e8 a8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80018c:	e8 0b 00 00 00       	call   80019c <exit>
}
  800191:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800194:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800197:	89 ec                	mov    %ebp,%esp
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    
	...

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a9:	e8 0d 0b 00 00       	call   800cbb <sys_env_destroy>
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 14             	sub    $0x14,%esp
  8001b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ba:	8b 03                	mov    (%ebx),%eax
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c3:	83 c0 01             	add    $0x1,%eax
  8001c6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cd:	75 19                	jne    8001e8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001cf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d6:	00 
  8001d7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001da:	89 04 24             	mov    %eax,(%esp)
  8001dd:	e8 72 0a 00 00       	call   800c54 <sys_cputs>
		b->idx = 0;
  8001e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ec:	83 c4 14             	add    $0x14,%esp
  8001ef:	5b                   	pop    %ebx
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    

008001f2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800202:	00 00 00 
	b.cnt = 0;
  800205:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80020c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800212:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800216:	8b 45 08             	mov    0x8(%ebp),%eax
  800219:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800223:	89 44 24 04          	mov    %eax,0x4(%esp)
  800227:	c7 04 24 b0 01 80 00 	movl   $0x8001b0,(%esp)
  80022e:	e8 de 01 00 00       	call   800411 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800233:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800243:	89 04 24             	mov    %eax,(%esp)
  800246:	e8 09 0a 00 00       	call   800c54 <sys_cputs>

	return b.cnt;
}
  80024b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800251:	c9                   	leave  
  800252:	c3                   	ret    

00800253 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800259:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800260:	8b 45 08             	mov    0x8(%ebp),%eax
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	e8 87 ff ff ff       	call   8001f2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    
  80026d:	00 00                	add    %al,(%eax)
	...

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 4c             	sub    $0x4c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d6                	mov    %edx,%esi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800284:	8b 55 0c             	mov    0xc(%ebp),%edx
  800287:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80028a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80028d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800290:	b8 00 00 00 00       	mov    $0x0,%eax
  800295:	39 d0                	cmp    %edx,%eax
  800297:	72 11                	jb     8002aa <printnum+0x3a>
  800299:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80029c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  80029f:	76 09                	jbe    8002aa <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	83 eb 01             	sub    $0x1,%ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f 5d                	jg     800305 <printnum+0x95>
  8002a8:	eb 6c                	jmp    800316 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002aa:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002ae:	83 eb 01             	sub    $0x1,%ebx
  8002b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002bc:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002c0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002c7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8002ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d1:	00 
  8002d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002d5:	89 14 24             	mov    %edx,(%esp)
  8002d8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002df:	e8 3c 0e 00 00       	call   801120 <__udivdi3>
  8002e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fe:	e8 6d ff ff ff       	call   800270 <printnum>
  800303:	eb 11                	jmp    800316 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800305:	89 74 24 04          	mov    %esi,0x4(%esp)
  800309:	89 3c 24             	mov    %edi,(%esp)
  80030c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030f:	83 eb 01             	sub    $0x1,%ebx
  800312:	85 db                	test   %ebx,%ebx
  800314:	7f ef                	jg     800305 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800316:	89 74 24 04          	mov    %esi,0x4(%esp)
  80031a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80031e:	8b 45 10             	mov    0x10(%ebp),%eax
  800321:	89 44 24 08          	mov    %eax,0x8(%esp)
  800325:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032c:	00 
  80032d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800330:	89 14 24             	mov    %edx,(%esp)
  800333:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800336:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80033a:	e8 f1 0e 00 00       	call   801230 <__umoddi3>
  80033f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800343:	0f be 80 e0 13 80 00 	movsbl 0x8013e0(%eax),%eax
  80034a:	89 04 24             	mov    %eax,(%esp)
  80034d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800350:	83 c4 4c             	add    $0x4c,%esp
  800353:	5b                   	pop    %ebx
  800354:	5e                   	pop    %esi
  800355:	5f                   	pop    %edi
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80035b:	83 fa 01             	cmp    $0x1,%edx
  80035e:	7e 0e                	jle    80036e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 08             	lea    0x8(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	8b 52 04             	mov    0x4(%edx),%edx
  80036c:	eb 22                	jmp    800390 <getuint+0x38>
	else if (lflag)
  80036e:	85 d2                	test   %edx,%edx
  800370:	74 10                	je     800382 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800372:	8b 10                	mov    (%eax),%edx
  800374:	8d 4a 04             	lea    0x4(%edx),%ecx
  800377:	89 08                	mov    %ecx,(%eax)
  800379:	8b 02                	mov    (%edx),%eax
  80037b:	ba 00 00 00 00       	mov    $0x0,%edx
  800380:	eb 0e                	jmp    800390 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800382:	8b 10                	mov    (%eax),%edx
  800384:	8d 4a 04             	lea    0x4(%edx),%ecx
  800387:	89 08                	mov    %ecx,(%eax)
  800389:	8b 02                	mov    (%edx),%eax
  80038b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    

00800392 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800395:	83 fa 01             	cmp    $0x1,%edx
  800398:	7e 0e                	jle    8003a8 <getint+0x16>
		return va_arg(*ap, long long);
  80039a:	8b 10                	mov    (%eax),%edx
  80039c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80039f:	89 08                	mov    %ecx,(%eax)
  8003a1:	8b 02                	mov    (%edx),%eax
  8003a3:	8b 52 04             	mov    0x4(%edx),%edx
  8003a6:	eb 22                	jmp    8003ca <getint+0x38>
	else if (lflag)
  8003a8:	85 d2                	test   %edx,%edx
  8003aa:	74 10                	je     8003bc <getint+0x2a>
		return va_arg(*ap, long);
  8003ac:	8b 10                	mov    (%eax),%edx
  8003ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b1:	89 08                	mov    %ecx,(%eax)
  8003b3:	8b 02                	mov    (%edx),%eax
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 fa 1f             	sar    $0x1f,%edx
  8003ba:	eb 0e                	jmp    8003ca <getint+0x38>
	else
		return va_arg(*ap, int);
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 02                	mov    (%edx),%eax
  8003c5:	89 c2                	mov    %eax,%edx
  8003c7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8003ca:	5d                   	pop    %ebp
  8003cb:	c3                   	ret    

008003cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d6:	8b 10                	mov    (%eax),%edx
  8003d8:	3b 50 04             	cmp    0x4(%eax),%edx
  8003db:	73 0a                	jae    8003e7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e0:	88 0a                	mov    %cl,(%edx)
  8003e2:	83 c2 01             	add    $0x1,%edx
  8003e5:	89 10                	mov    %edx,(%eax)
}
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ef:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800400:	89 44 24 04          	mov    %eax,0x4(%esp)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	89 04 24             	mov    %eax,(%esp)
  80040a:	e8 02 00 00 00       	call   800411 <vprintfmt>
	va_end(ap);
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 4c             	sub    $0x4c,%esp
  80041a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80041d:	eb 23                	jmp    800442 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80041f:	85 c0                	test   %eax,%eax
  800421:	75 12                	jne    800435 <vprintfmt+0x24>
				csa = 0x0700;
  800423:	c7 05 0c 20 80 00 00 	movl   $0x700,0x80200c
  80042a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80042d:	83 c4 4c             	add    $0x4c,%esp
  800430:	5b                   	pop    %ebx
  800431:	5e                   	pop    %esi
  800432:	5f                   	pop    %edi
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800435:	8b 55 0c             	mov    0xc(%ebp),%edx
  800438:	89 54 24 04          	mov    %edx,0x4(%esp)
  80043c:	89 04 24             	mov    %eax,(%esp)
  80043f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800442:	0f b6 07             	movzbl (%edi),%eax
  800445:	83 c7 01             	add    $0x1,%edi
  800448:	83 f8 25             	cmp    $0x25,%eax
  80044b:	75 d2                	jne    80041f <vprintfmt+0xe>
  80044d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800451:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800458:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80045d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800464:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800469:	be 00 00 00 00       	mov    $0x0,%esi
  80046e:	eb 14                	jmp    800484 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800470:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800474:	eb 0e                	jmp    800484 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800476:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80047a:	eb 08                	jmp    800484 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80047c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80047f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	0f b6 07             	movzbl (%edi),%eax
  800487:	0f b6 c8             	movzbl %al,%ecx
  80048a:	83 c7 01             	add    $0x1,%edi
  80048d:	83 e8 23             	sub    $0x23,%eax
  800490:	3c 55                	cmp    $0x55,%al
  800492:	0f 87 ed 02 00 00    	ja     800785 <vprintfmt+0x374>
  800498:	0f b6 c0             	movzbl %al,%eax
  80049b:	ff 24 85 a0 14 80 00 	jmp    *0x8014a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  8004a5:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004a8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004ab:	83 f9 09             	cmp    $0x9,%ecx
  8004ae:	77 3c                	ja     8004ec <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004b3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8004b6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8004ba:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004bd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004c0:	83 f9 09             	cmp    $0x9,%ecx
  8004c3:	76 eb                	jbe    8004b0 <vprintfmt+0x9f>
  8004c5:	eb 25                	jmp    8004ec <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 48 04             	lea    0x4(%eax),%ecx
  8004cd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  8004d2:	eb 18                	jmp    8004ec <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  8004d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004db:	0f 48 c6             	cmovs  %esi,%eax
  8004de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004e1:	eb a1                	jmp    800484 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  8004e3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004ea:	eb 98                	jmp    800484 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  8004ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f0:	79 92                	jns    800484 <vprintfmt+0x73>
  8004f2:	eb 88                	jmp    80047c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f4:	83 c2 01             	add    $0x1,%edx
  8004f7:	eb 8b                	jmp    800484 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 50 04             	lea    0x4(%eax),%edx
  8004ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800502:	8b 55 0c             	mov    0xc(%ebp),%edx
  800505:	89 54 24 04          	mov    %edx,0x4(%esp)
  800509:	8b 00                	mov    (%eax),%eax
  80050b:	89 04 24             	mov    %eax,(%esp)
  80050e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800511:	e9 2c ff ff ff       	jmp    800442 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 50 04             	lea    0x4(%eax),%edx
  80051c:	89 55 14             	mov    %edx,0x14(%ebp)
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 c2                	mov    %eax,%edx
  800523:	c1 fa 1f             	sar    $0x1f,%edx
  800526:	31 d0                	xor    %edx,%eax
  800528:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80052a:	83 f8 08             	cmp    $0x8,%eax
  80052d:	7f 0b                	jg     80053a <vprintfmt+0x129>
  80052f:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  800536:	85 d2                	test   %edx,%edx
  800538:	75 23                	jne    80055d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80053a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053e:	c7 44 24 08 f8 13 80 	movl   $0x8013f8,0x8(%esp)
  800545:	00 
  800546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800549:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054d:	8b 45 08             	mov    0x8(%ebp),%eax
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	e8 91 fe ff ff       	call   8003e9 <printfmt>
  800558:	e9 e5 fe ff ff       	jmp    800442 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80055d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800561:	c7 44 24 08 01 14 80 	movl   $0x801401,0x8(%esp)
  800568:	00 
  800569:	8b 55 0c             	mov    0xc(%ebp),%edx
  80056c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800570:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800573:	89 1c 24             	mov    %ebx,(%esp)
  800576:	e8 6e fe ff ff       	call   8003e9 <printfmt>
  80057b:	e9 c2 fe ff ff       	jmp    800442 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800580:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800583:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 50 04             	lea    0x4(%eax),%edx
  80058f:	89 55 14             	mov    %edx,0x14(%ebp)
  800592:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800594:	85 f6                	test   %esi,%esi
  800596:	ba f1 13 80 00       	mov    $0x8013f1,%edx
  80059b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80059e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a2:	7e 06                	jle    8005aa <vprintfmt+0x199>
  8005a4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005a8:	75 13                	jne    8005bd <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005aa:	0f be 06             	movsbl (%esi),%eax
  8005ad:	83 c6 01             	add    $0x1,%esi
  8005b0:	85 c0                	test   %eax,%eax
  8005b2:	0f 85 a2 00 00 00    	jne    80065a <vprintfmt+0x249>
  8005b8:	e9 92 00 00 00       	jmp    80064f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c1:	89 34 24             	mov    %esi,(%esp)
  8005c4:	e8 82 02 00 00       	call   80084b <strnlen>
  8005c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005cc:	29 c2                	sub    %eax,%edx
  8005ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005d1:	85 d2                	test   %edx,%edx
  8005d3:	7e d5                	jle    8005aa <vprintfmt+0x199>
					putch(padc, putdat);
  8005d5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8005d9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005dc:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005df:	89 d3                	mov    %edx,%ebx
  8005e1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005e4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005e7:	89 c6                	mov    %eax,%esi
  8005e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ed:	89 34 24             	mov    %esi,(%esp)
  8005f0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f3:	83 eb 01             	sub    $0x1,%ebx
  8005f6:	85 db                	test   %ebx,%ebx
  8005f8:	7f ef                	jg     8005e9 <vprintfmt+0x1d8>
  8005fa:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005fd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800600:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800603:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80060a:	eb 9e                	jmp    8005aa <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800610:	74 1b                	je     80062d <vprintfmt+0x21c>
  800612:	8d 50 e0             	lea    -0x20(%eax),%edx
  800615:	83 fa 5e             	cmp    $0x5e,%edx
  800618:	76 13                	jbe    80062d <vprintfmt+0x21c>
					putch('?', putdat);
  80061a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80061d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800621:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800628:	ff 55 08             	call   *0x8(%ebp)
  80062b:	eb 0d                	jmp    80063a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80062d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800630:	89 54 24 04          	mov    %edx,0x4(%esp)
  800634:	89 04 24             	mov    %eax,(%esp)
  800637:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063a:	83 ef 01             	sub    $0x1,%edi
  80063d:	0f be 06             	movsbl (%esi),%eax
  800640:	85 c0                	test   %eax,%eax
  800642:	74 05                	je     800649 <vprintfmt+0x238>
  800644:	83 c6 01             	add    $0x1,%esi
  800647:	eb 17                	jmp    800660 <vprintfmt+0x24f>
  800649:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80064c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80064f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800653:	7f 1c                	jg     800671 <vprintfmt+0x260>
  800655:	e9 e8 fd ff ff       	jmp    800442 <vprintfmt+0x31>
  80065a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80065d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800660:	85 db                	test   %ebx,%ebx
  800662:	78 a8                	js     80060c <vprintfmt+0x1fb>
  800664:	83 eb 01             	sub    $0x1,%ebx
  800667:	79 a3                	jns    80060c <vprintfmt+0x1fb>
  800669:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80066c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80066f:	eb de                	jmp    80064f <vprintfmt+0x23e>
  800671:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800674:	8b 7d 08             	mov    0x8(%ebp),%edi
  800677:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80067e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800685:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800687:	83 eb 01             	sub    $0x1,%ebx
  80068a:	85 db                	test   %ebx,%ebx
  80068c:	7f ec                	jg     80067a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800691:	e9 ac fd ff ff       	jmp    800442 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800696:	8d 45 14             	lea    0x14(%ebp),%eax
  800699:	e8 f4 fc ff ff       	call   800392 <getint>
  80069e:	89 c3                	mov    %eax,%ebx
  8006a0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8006a2:	85 d2                	test   %edx,%edx
  8006a4:	78 0a                	js     8006b0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006ab:	e9 87 00 00 00       	jmp    800737 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006be:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006c1:	89 d8                	mov    %ebx,%eax
  8006c3:	89 f2                	mov    %esi,%edx
  8006c5:	f7 d8                	neg    %eax
  8006c7:	83 d2 00             	adc    $0x0,%edx
  8006ca:	f7 da                	neg    %edx
			}
			base = 10;
  8006cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006d1:	eb 64                	jmp    800737 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d6:	e8 7d fc ff ff       	call   800358 <getuint>
			base = 10;
  8006db:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006e0:	eb 55                	jmp    800737 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8006e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e5:	e8 6e fc ff ff       	call   800358 <getuint>
      base = 8;
  8006ea:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8006ef:	eb 46                	jmp    800737 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  8006f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006f8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006ff:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800702:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800705:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800709:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800710:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8d 50 04             	lea    0x4(%eax),%edx
  800719:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80071c:	8b 00                	mov    (%eax),%eax
  80071e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800723:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800728:	eb 0d                	jmp    800737 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80072a:	8d 45 14             	lea    0x14(%ebp),%eax
  80072d:	e8 26 fc ff ff       	call   800358 <getuint>
			base = 16;
  800732:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800737:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80073b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80073f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800742:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800746:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80074a:	89 04 24             	mov    %eax,(%esp)
  80074d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800751:	8b 55 0c             	mov    0xc(%ebp),%edx
  800754:	8b 45 08             	mov    0x8(%ebp),%eax
  800757:	e8 14 fb ff ff       	call   800270 <printnum>
			break;
  80075c:	e9 e1 fc ff ff       	jmp    800442 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800761:	8b 45 0c             	mov    0xc(%ebp),%eax
  800764:	89 44 24 04          	mov    %eax,0x4(%esp)
  800768:	89 0c 24             	mov    %ecx,(%esp)
  80076b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80076e:	e9 cf fc ff ff       	jmp    800442 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
  800776:	e8 17 fc ff ff       	call   800392 <getint>
			csa = num;
  80077b:	a3 0c 20 80 00       	mov    %eax,0x80200c
			break;
  800780:	e9 bd fc ff ff       	jmp    800442 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
  800788:	89 54 24 04          	mov    %edx,0x4(%esp)
  80078c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800796:	83 ef 01             	sub    $0x1,%edi
  800799:	eb 02                	jmp    80079d <vprintfmt+0x38c>
  80079b:	89 c7                	mov    %eax,%edi
  80079d:	8d 47 ff             	lea    -0x1(%edi),%eax
  8007a0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a4:	75 f5                	jne    80079b <vprintfmt+0x38a>
  8007a6:	e9 97 fc ff ff       	jmp    800442 <vprintfmt+0x31>

008007ab <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	83 ec 28             	sub    $0x28,%esp
  8007b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ba:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007be:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c8:	85 c0                	test   %eax,%eax
  8007ca:	74 30                	je     8007fc <vsnprintf+0x51>
  8007cc:	85 d2                	test   %edx,%edx
  8007ce:	7e 2c                	jle    8007fc <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e5:	c7 04 24 cc 03 80 00 	movl   $0x8003cc,(%esp)
  8007ec:	e8 20 fc ff ff       	call   800411 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fa:	eb 05                	jmp    800801 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800809:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800810:	8b 45 10             	mov    0x10(%ebp),%eax
  800813:	89 44 24 08          	mov    %eax,0x8(%esp)
  800817:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081e:	8b 45 08             	mov    0x8(%ebp),%eax
  800821:	89 04 24             	mov    %eax,(%esp)
  800824:	e8 82 ff ff ff       	call   8007ab <vsnprintf>
	va_end(ap);

	return rc;
}
  800829:	c9                   	leave  
  80082a:	c3                   	ret    
  80082b:	00 00                	add    %al,(%eax)
  80082d:	00 00                	add    %al,(%eax)
	...

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	80 3a 00             	cmpb   $0x0,(%edx)
  80083e:	74 09                	je     800849 <strlen+0x19>
		n++;
  800840:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800843:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800847:	75 f7                	jne    800840 <strlen+0x10>
		n++;
	return n;
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800851:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800854:	b8 00 00 00 00       	mov    $0x0,%eax
  800859:	85 d2                	test   %edx,%edx
  80085b:	74 12                	je     80086f <strnlen+0x24>
  80085d:	80 39 00             	cmpb   $0x0,(%ecx)
  800860:	74 0d                	je     80086f <strnlen+0x24>
		n++;
  800862:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800865:	39 d0                	cmp    %edx,%eax
  800867:	74 06                	je     80086f <strnlen+0x24>
  800869:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80086d:	75 f3                	jne    800862 <strnlen+0x17>
		n++;
	return n;
}
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	53                   	push   %ebx
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80087b:	ba 00 00 00 00       	mov    $0x0,%edx
  800880:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800884:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800887:	83 c2 01             	add    $0x1,%edx
  80088a:	84 c9                	test   %cl,%cl
  80088c:	75 f2                	jne    800880 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80088e:	5b                   	pop    %ebx
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	53                   	push   %ebx
  800895:	83 ec 08             	sub    $0x8,%esp
  800898:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089b:	89 1c 24             	mov    %ebx,(%esp)
  80089e:	e8 8d ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008aa:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008ad:	89 04 24             	mov    %eax,(%esp)
  8008b0:	e8 bc ff ff ff       	call   800871 <strcpy>
	return dst;
}
  8008b5:	89 d8                	mov    %ebx,%eax
  8008b7:	83 c4 08             	add    $0x8,%esp
  8008ba:	5b                   	pop    %ebx
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008cb:	85 f6                	test   %esi,%esi
  8008cd:	74 18                	je     8008e7 <strncpy+0x2a>
  8008cf:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008d4:	0f b6 1a             	movzbl (%edx),%ebx
  8008d7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008da:	80 3a 01             	cmpb   $0x1,(%edx)
  8008dd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e0:	83 c1 01             	add    $0x1,%ecx
  8008e3:	39 ce                	cmp    %ecx,%esi
  8008e5:	77 ed                	ja     8008d4 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e7:	5b                   	pop    %ebx
  8008e8:	5e                   	pop    %esi
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	56                   	push   %esi
  8008ef:	53                   	push   %ebx
  8008f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f9:	89 f0                	mov    %esi,%eax
  8008fb:	85 c9                	test   %ecx,%ecx
  8008fd:	74 23                	je     800922 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  8008ff:	83 e9 01             	sub    $0x1,%ecx
  800902:	74 1b                	je     80091f <strlcpy+0x34>
  800904:	0f b6 1a             	movzbl (%edx),%ebx
  800907:	84 db                	test   %bl,%bl
  800909:	74 14                	je     80091f <strlcpy+0x34>
			*dst++ = *src++;
  80090b:	88 18                	mov    %bl,(%eax)
  80090d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800910:	83 e9 01             	sub    $0x1,%ecx
  800913:	74 0a                	je     80091f <strlcpy+0x34>
			*dst++ = *src++;
  800915:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800918:	0f b6 1a             	movzbl (%edx),%ebx
  80091b:	84 db                	test   %bl,%bl
  80091d:	75 ec                	jne    80090b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80091f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800922:	29 f0                	sub    %esi,%eax
}
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800931:	0f b6 01             	movzbl (%ecx),%eax
  800934:	84 c0                	test   %al,%al
  800936:	74 15                	je     80094d <strcmp+0x25>
  800938:	3a 02                	cmp    (%edx),%al
  80093a:	75 11                	jne    80094d <strcmp+0x25>
		p++, q++;
  80093c:	83 c1 01             	add    $0x1,%ecx
  80093f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800942:	0f b6 01             	movzbl (%ecx),%eax
  800945:	84 c0                	test   %al,%al
  800947:	74 04                	je     80094d <strcmp+0x25>
  800949:	3a 02                	cmp    (%edx),%al
  80094b:	74 ef                	je     80093c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80094d:	0f b6 c0             	movzbl %al,%eax
  800950:	0f b6 12             	movzbl (%edx),%edx
  800953:	29 d0                	sub    %edx,%eax
}
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	53                   	push   %ebx
  80095b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800961:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800969:	85 d2                	test   %edx,%edx
  80096b:	74 28                	je     800995 <strncmp+0x3e>
  80096d:	0f b6 01             	movzbl (%ecx),%eax
  800970:	84 c0                	test   %al,%al
  800972:	74 24                	je     800998 <strncmp+0x41>
  800974:	3a 03                	cmp    (%ebx),%al
  800976:	75 20                	jne    800998 <strncmp+0x41>
  800978:	83 ea 01             	sub    $0x1,%edx
  80097b:	74 13                	je     800990 <strncmp+0x39>
		n--, p++, q++;
  80097d:	83 c1 01             	add    $0x1,%ecx
  800980:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800983:	0f b6 01             	movzbl (%ecx),%eax
  800986:	84 c0                	test   %al,%al
  800988:	74 0e                	je     800998 <strncmp+0x41>
  80098a:	3a 03                	cmp    (%ebx),%al
  80098c:	74 ea                	je     800978 <strncmp+0x21>
  80098e:	eb 08                	jmp    800998 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800995:	5b                   	pop    %ebx
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 01             	movzbl (%ecx),%eax
  80099b:	0f b6 13             	movzbl (%ebx),%edx
  80099e:	29 d0                	sub    %edx,%eax
  8009a0:	eb f3                	jmp    800995 <strncmp+0x3e>

008009a2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ac:	0f b6 10             	movzbl (%eax),%edx
  8009af:	84 d2                	test   %dl,%dl
  8009b1:	74 20                	je     8009d3 <strchr+0x31>
		if (*s == c)
  8009b3:	38 ca                	cmp    %cl,%dl
  8009b5:	75 0b                	jne    8009c2 <strchr+0x20>
  8009b7:	eb 1f                	jmp    8009d8 <strchr+0x36>
  8009b9:	38 ca                	cmp    %cl,%dl
  8009bb:	90                   	nop
  8009bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009c0:	74 16                	je     8009d8 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	0f b6 10             	movzbl (%eax),%edx
  8009c8:	84 d2                	test   %dl,%dl
  8009ca:	75 ed                	jne    8009b9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d1:	eb 05                	jmp    8009d8 <strchr+0x36>
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e4:	0f b6 10             	movzbl (%eax),%edx
  8009e7:	84 d2                	test   %dl,%dl
  8009e9:	74 14                	je     8009ff <strfind+0x25>
		if (*s == c)
  8009eb:	38 ca                	cmp    %cl,%dl
  8009ed:	75 06                	jne    8009f5 <strfind+0x1b>
  8009ef:	eb 0e                	jmp    8009ff <strfind+0x25>
  8009f1:	38 ca                	cmp    %cl,%dl
  8009f3:	74 0a                	je     8009ff <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	0f b6 10             	movzbl (%eax),%edx
  8009fb:	84 d2                	test   %dl,%dl
  8009fd:	75 f2                	jne    8009f1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	83 ec 0c             	sub    $0xc,%esp
  800a07:	89 1c 24             	mov    %ebx,(%esp)
  800a0a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a0e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a12:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a1b:	85 c9                	test   %ecx,%ecx
  800a1d:	74 30                	je     800a4f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a25:	75 25                	jne    800a4c <memset+0x4b>
  800a27:	f6 c1 03             	test   $0x3,%cl
  800a2a:	75 20                	jne    800a4c <memset+0x4b>
		c &= 0xFF;
  800a2c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a2f:	89 d3                	mov    %edx,%ebx
  800a31:	c1 e3 08             	shl    $0x8,%ebx
  800a34:	89 d6                	mov    %edx,%esi
  800a36:	c1 e6 18             	shl    $0x18,%esi
  800a39:	89 d0                	mov    %edx,%eax
  800a3b:	c1 e0 10             	shl    $0x10,%eax
  800a3e:	09 f0                	or     %esi,%eax
  800a40:	09 d0                	or     %edx,%eax
  800a42:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a44:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a47:	fc                   	cld    
  800a48:	f3 ab                	rep stos %eax,%es:(%edi)
  800a4a:	eb 03                	jmp    800a4f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a4c:	fc                   	cld    
  800a4d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4f:	89 f8                	mov    %edi,%eax
  800a51:	8b 1c 24             	mov    (%esp),%ebx
  800a54:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a58:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a5c:	89 ec                	mov    %ebp,%esp
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	83 ec 08             	sub    $0x8,%esp
  800a66:	89 34 24             	mov    %esi,(%esp)
  800a69:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a73:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a76:	39 c6                	cmp    %eax,%esi
  800a78:	73 36                	jae    800ab0 <memmove+0x50>
  800a7a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a7d:	39 d0                	cmp    %edx,%eax
  800a7f:	73 2f                	jae    800ab0 <memmove+0x50>
		s += n;
		d += n;
  800a81:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a84:	f6 c2 03             	test   $0x3,%dl
  800a87:	75 1b                	jne    800aa4 <memmove+0x44>
  800a89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8f:	75 13                	jne    800aa4 <memmove+0x44>
  800a91:	f6 c1 03             	test   $0x3,%cl
  800a94:	75 0e                	jne    800aa4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a96:	83 ef 04             	sub    $0x4,%edi
  800a99:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a9c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a9f:	fd                   	std    
  800aa0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa2:	eb 09                	jmp    800aad <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa4:	83 ef 01             	sub    $0x1,%edi
  800aa7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aaa:	fd                   	std    
  800aab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aad:	fc                   	cld    
  800aae:	eb 20                	jmp    800ad0 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab6:	75 13                	jne    800acb <memmove+0x6b>
  800ab8:	a8 03                	test   $0x3,%al
  800aba:	75 0f                	jne    800acb <memmove+0x6b>
  800abc:	f6 c1 03             	test   $0x3,%cl
  800abf:	75 0a                	jne    800acb <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ac4:	89 c7                	mov    %eax,%edi
  800ac6:	fc                   	cld    
  800ac7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac9:	eb 05                	jmp    800ad0 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800acb:	89 c7                	mov    %eax,%edi
  800acd:	fc                   	cld    
  800ace:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad0:	8b 34 24             	mov    (%esp),%esi
  800ad3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ad7:	89 ec                	mov    %ebp,%esp
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ae1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	89 04 24             	mov    %eax,(%esp)
  800af5:	e8 66 ff ff ff       	call   800a60 <memmove>
}
  800afa:	c9                   	leave  
  800afb:	c3                   	ret    

00800afc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
  800b02:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b08:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b10:	85 ff                	test   %edi,%edi
  800b12:	74 38                	je     800b4c <memcmp+0x50>
		if (*s1 != *s2)
  800b14:	0f b6 03             	movzbl (%ebx),%eax
  800b17:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1a:	83 ef 01             	sub    $0x1,%edi
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b22:	38 c8                	cmp    %cl,%al
  800b24:	74 1d                	je     800b43 <memcmp+0x47>
  800b26:	eb 11                	jmp    800b39 <memcmp+0x3d>
  800b28:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b2d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800b32:	83 c2 01             	add    $0x1,%edx
  800b35:	38 c8                	cmp    %cl,%al
  800b37:	74 0a                	je     800b43 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800b39:	0f b6 c0             	movzbl %al,%eax
  800b3c:	0f b6 c9             	movzbl %cl,%ecx
  800b3f:	29 c8                	sub    %ecx,%eax
  800b41:	eb 09                	jmp    800b4c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b43:	39 fa                	cmp    %edi,%edx
  800b45:	75 e1                	jne    800b28 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b57:	89 c2                	mov    %eax,%edx
  800b59:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b5c:	39 d0                	cmp    %edx,%eax
  800b5e:	73 15                	jae    800b75 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b64:	38 08                	cmp    %cl,(%eax)
  800b66:	75 06                	jne    800b6e <memfind+0x1d>
  800b68:	eb 0b                	jmp    800b75 <memfind+0x24>
  800b6a:	38 08                	cmp    %cl,(%eax)
  800b6c:	74 07                	je     800b75 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b6e:	83 c0 01             	add    $0x1,%eax
  800b71:	39 c2                	cmp    %eax,%edx
  800b73:	77 f5                	ja     800b6a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
  800b7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b83:	0f b6 02             	movzbl (%edx),%eax
  800b86:	3c 20                	cmp    $0x20,%al
  800b88:	74 04                	je     800b8e <strtol+0x17>
  800b8a:	3c 09                	cmp    $0x9,%al
  800b8c:	75 0e                	jne    800b9c <strtol+0x25>
		s++;
  800b8e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b91:	0f b6 02             	movzbl (%edx),%eax
  800b94:	3c 20                	cmp    $0x20,%al
  800b96:	74 f6                	je     800b8e <strtol+0x17>
  800b98:	3c 09                	cmp    $0x9,%al
  800b9a:	74 f2                	je     800b8e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b9c:	3c 2b                	cmp    $0x2b,%al
  800b9e:	75 0a                	jne    800baa <strtol+0x33>
		s++;
  800ba0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba8:	eb 10                	jmp    800bba <strtol+0x43>
  800baa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800baf:	3c 2d                	cmp    $0x2d,%al
  800bb1:	75 07                	jne    800bba <strtol+0x43>
		s++, neg = 1;
  800bb3:	83 c2 01             	add    $0x1,%edx
  800bb6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bba:	85 db                	test   %ebx,%ebx
  800bbc:	0f 94 c0             	sete   %al
  800bbf:	74 05                	je     800bc6 <strtol+0x4f>
  800bc1:	83 fb 10             	cmp    $0x10,%ebx
  800bc4:	75 15                	jne    800bdb <strtol+0x64>
  800bc6:	80 3a 30             	cmpb   $0x30,(%edx)
  800bc9:	75 10                	jne    800bdb <strtol+0x64>
  800bcb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bcf:	75 0a                	jne    800bdb <strtol+0x64>
		s += 2, base = 16;
  800bd1:	83 c2 02             	add    $0x2,%edx
  800bd4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd9:	eb 13                	jmp    800bee <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800bdb:	84 c0                	test   %al,%al
  800bdd:	74 0f                	je     800bee <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bdf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be4:	80 3a 30             	cmpb   $0x30,(%edx)
  800be7:	75 05                	jne    800bee <strtol+0x77>
		s++, base = 8;
  800be9:	83 c2 01             	add    $0x1,%edx
  800bec:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800bee:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf3:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf5:	0f b6 0a             	movzbl (%edx),%ecx
  800bf8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bfb:	80 fb 09             	cmp    $0x9,%bl
  800bfe:	77 08                	ja     800c08 <strtol+0x91>
			dig = *s - '0';
  800c00:	0f be c9             	movsbl %cl,%ecx
  800c03:	83 e9 30             	sub    $0x30,%ecx
  800c06:	eb 1e                	jmp    800c26 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c08:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c0b:	80 fb 19             	cmp    $0x19,%bl
  800c0e:	77 08                	ja     800c18 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c10:	0f be c9             	movsbl %cl,%ecx
  800c13:	83 e9 57             	sub    $0x57,%ecx
  800c16:	eb 0e                	jmp    800c26 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c18:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c1b:	80 fb 19             	cmp    $0x19,%bl
  800c1e:	77 15                	ja     800c35 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800c20:	0f be c9             	movsbl %cl,%ecx
  800c23:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c26:	39 f1                	cmp    %esi,%ecx
  800c28:	7d 0f                	jge    800c39 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800c2a:	83 c2 01             	add    $0x1,%edx
  800c2d:	0f af c6             	imul   %esi,%eax
  800c30:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c33:	eb c0                	jmp    800bf5 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c35:	89 c1                	mov    %eax,%ecx
  800c37:	eb 02                	jmp    800c3b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c39:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c3b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c3f:	74 05                	je     800c46 <strtol+0xcf>
		*endptr = (char *) s;
  800c41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c44:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c46:	89 ca                	mov    %ecx,%edx
  800c48:	f7 da                	neg    %edx
  800c4a:	85 ff                	test   %edi,%edi
  800c4c:	0f 45 c2             	cmovne %edx,%eax
}
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	89 1c 24             	mov    %ebx,(%esp)
  800c5d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c61:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 c3                	mov    %eax,%ebx
  800c72:	89 c7                	mov    %eax,%edi
  800c74:	89 c6                	mov    %eax,%esi
  800c76:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c78:	8b 1c 24             	mov    (%esp),%ebx
  800c7b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c7f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c83:	89 ec                	mov    %ebp,%esp
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	83 ec 0c             	sub    $0xc,%esp
  800c8d:	89 1c 24             	mov    %ebx,(%esp)
  800c90:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c94:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca2:	89 d1                	mov    %edx,%ecx
  800ca4:	89 d3                	mov    %edx,%ebx
  800ca6:	89 d7                	mov    %edx,%edi
  800ca8:	89 d6                	mov    %edx,%esi
  800caa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cac:	8b 1c 24             	mov    (%esp),%ebx
  800caf:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cb3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cb7:	89 ec                	mov    %ebp,%esp
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	83 ec 38             	sub    $0x38,%esp
  800cc1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cc7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ccf:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	89 cb                	mov    %ecx,%ebx
  800cd9:	89 cf                	mov    %ecx,%edi
  800cdb:	89 ce                	mov    %ecx,%esi
  800cdd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	7e 28                	jle    800d0b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cee:	00 
  800cef:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800cf6:	00 
  800cf7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfe:	00 
  800cff:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800d06:	e8 b1 03 00 00       	call   8010bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d0b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d0e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d11:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d14:	89 ec                	mov    %ebp,%esp
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	89 1c 24             	mov    %ebx,(%esp)
  800d21:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d25:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d29:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d33:	89 d1                	mov    %edx,%ecx
  800d35:	89 d3                	mov    %edx,%ebx
  800d37:	89 d7                	mov    %edx,%edi
  800d39:	89 d6                	mov    %edx,%esi
  800d3b:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800d3d:	8b 1c 24             	mov    (%esp),%ebx
  800d40:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d44:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d48:	89 ec                	mov    %ebp,%esp
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_yield>:

void
sys_yield(void)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 0c             	sub    $0xc,%esp
  800d52:	89 1c 24             	mov    %ebx,(%esp)
  800d55:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d59:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d62:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d67:	89 d1                	mov    %edx,%ecx
  800d69:	89 d3                	mov    %edx,%ebx
  800d6b:	89 d7                	mov    %edx,%edi
  800d6d:	89 d6                	mov    %edx,%esi
  800d6f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d71:	8b 1c 24             	mov    (%esp),%ebx
  800d74:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d78:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d7c:	89 ec                	mov    %ebp,%esp
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	83 ec 38             	sub    $0x38,%esp
  800d86:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d89:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d8c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	be 00 00 00 00       	mov    $0x0,%esi
  800d94:	b8 04 00 00 00       	mov    $0x4,%eax
  800d99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	89 f7                	mov    %esi,%edi
  800da4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da6:	85 c0                	test   %eax,%eax
  800da8:	7e 28                	jle    800dd2 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dae:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800db5:	00 
  800db6:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800dbd:	00 
  800dbe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc5:	00 
  800dc6:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800dcd:	e8 ea 02 00 00       	call   8010bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dd2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ddb:	89 ec                	mov    %ebp,%esp
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	83 ec 38             	sub    $0x38,%esp
  800de5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800deb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dee:	b8 05 00 00 00       	mov    $0x5,%eax
  800df3:	8b 75 18             	mov    0x18(%ebp),%esi
  800df6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dff:	8b 55 08             	mov    0x8(%ebp),%edx
  800e02:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e04:	85 c0                	test   %eax,%eax
  800e06:	7e 28                	jle    800e30 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e08:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e13:	00 
  800e14:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800e1b:	00 
  800e1c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e23:	00 
  800e24:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800e2b:	e8 8c 02 00 00       	call   8010bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e30:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e33:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e36:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e39:	89 ec                	mov    %ebp,%esp
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	83 ec 38             	sub    $0x38,%esp
  800e43:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e46:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e49:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e51:	b8 06 00 00 00       	mov    $0x6,%eax
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 df                	mov    %ebx,%edi
  800e5e:	89 de                	mov    %ebx,%esi
  800e60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e62:	85 c0                	test   %eax,%eax
  800e64:	7e 28                	jle    800e8e <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e66:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e71:	00 
  800e72:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800e79:	00 
  800e7a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e81:	00 
  800e82:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800e89:	e8 2e 02 00 00       	call   8010bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e8e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e91:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e94:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e97:	89 ec                	mov    %ebp,%esp
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	83 ec 38             	sub    $0x38,%esp
  800ea1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eaf:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eba:	89 df                	mov    %ebx,%edi
  800ebc:	89 de                	mov    %ebx,%esi
  800ebe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	7e 28                	jle    800eec <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec8:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ecf:	00 
  800ed0:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800ed7:	00 
  800ed8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800edf:	00 
  800ee0:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800ee7:	e8 d0 01 00 00       	call   8010bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800eec:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eef:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef5:	89 ec                	mov    %ebp,%esp
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	83 ec 38             	sub    $0x38,%esp
  800eff:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f02:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f05:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0d:	b8 09 00 00 00       	mov    $0x9,%eax
  800f12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f15:	8b 55 08             	mov    0x8(%ebp),%edx
  800f18:	89 df                	mov    %ebx,%edi
  800f1a:	89 de                	mov    %ebx,%esi
  800f1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	7e 28                	jle    800f4a <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f22:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f26:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f2d:	00 
  800f2e:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800f35:	00 
  800f36:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3d:	00 
  800f3e:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800f45:	e8 72 01 00 00       	call   8010bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f4a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f4d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f50:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f53:	89 ec                	mov    %ebp,%esp
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    

00800f57 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 0c             	sub    $0xc,%esp
  800f5d:	89 1c 24             	mov    %ebx,(%esp)
  800f60:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f64:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f68:	be 00 00 00 00       	mov    $0x0,%esi
  800f6d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f80:	8b 1c 24             	mov    (%esp),%ebx
  800f83:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f87:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f8b:	89 ec                	mov    %ebp,%esp
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 38             	sub    $0x38,%esp
  800f95:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f98:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f9b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fab:	89 cb                	mov    %ecx,%ebx
  800fad:	89 cf                	mov    %ecx,%edi
  800faf:	89 ce                	mov    %ecx,%esi
  800fb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	7e 28                	jle    800fdf <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fbb:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800fc2:	00 
  800fc3:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800fca:	00 
  800fcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd2:	00 
  800fd3:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800fda:	e8 dd 00 00 00       	call   8010bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fdf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fe2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fe5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe8:	89 ec                	mov    %ebp,%esp
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800ff2:	c7 44 24 08 5b 16 80 	movl   $0x80165b,0x8(%esp)
  800ff9:	00 
  800ffa:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801001:	00 
  801002:	c7 04 24 4f 16 80 00 	movl   $0x80164f,(%esp)
  801009:	e8 ae 00 00 00       	call   8010bc <_panic>

0080100e <sfork>:
}

// Challenge!
int
sfork(void)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801014:	c7 44 24 08 5a 16 80 	movl   $0x80165a,0x8(%esp)
  80101b:	00 
  80101c:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801023:	00 
  801024:	c7 04 24 4f 16 80 00 	movl   $0x80164f,(%esp)
  80102b:	e8 8c 00 00 00       	call   8010bc <_panic>

00801030 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  801036:	c7 44 24 08 70 16 80 	movl   $0x801670,0x8(%esp)
  80103d:	00 
  80103e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  801045:	00 
  801046:	c7 04 24 89 16 80 00 	movl   $0x801689,(%esp)
  80104d:	e8 6a 00 00 00       	call   8010bc <_panic>

00801052 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801058:	c7 44 24 08 93 16 80 	movl   $0x801693,0x8(%esp)
  80105f:	00 
  801060:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801067:	00 
  801068:	c7 04 24 89 16 80 00 	movl   $0x801689,(%esp)
  80106f:	e8 48 00 00 00       	call   8010bc <_panic>

00801074 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80107a:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801080:	74 17                	je     801099 <ipc_find_env+0x25>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801082:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801087:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80108a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801090:	8b 52 50             	mov    0x50(%edx),%edx
  801093:	39 ca                	cmp    %ecx,%edx
  801095:	75 14                	jne    8010ab <ipc_find_env+0x37>
  801097:	eb 05                	jmp    80109e <ipc_find_env+0x2a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801099:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80109e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010a1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8010a6:	8b 40 40             	mov    0x40(%eax),%eax
  8010a9:	eb 0e                	jmp    8010b9 <ipc_find_env+0x45>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010ab:	83 c0 01             	add    $0x1,%eax
  8010ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010b3:	75 d2                	jne    801087 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010b5:	66 b8 00 00          	mov    $0x0,%ax
}
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    
	...

008010bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	56                   	push   %esi
  8010c0:	53                   	push   %ebx
  8010c1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8010c4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010c7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8010cd:	e8 46 fc ff ff       	call   800d18 <sys_getenvid>
  8010d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e8:	c7 04 24 ac 16 80 00 	movl   $0x8016ac,(%esp)
  8010ef:	e8 5f f1 ff ff       	call   800253 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8010fb:	89 04 24             	mov    %eax,(%esp)
  8010fe:	e8 ef f0 ff ff       	call   8001f2 <vcprintf>
	cprintf("\n");
  801103:	c7 04 24 98 13 80 00 	movl   $0x801398,(%esp)
  80110a:	e8 44 f1 ff ff       	call   800253 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80110f:	cc                   	int3   
  801110:	eb fd                	jmp    80110f <_panic+0x53>
	...

00801120 <__udivdi3>:
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	57                   	push   %edi
  801124:	56                   	push   %esi
  801125:	83 ec 10             	sub    $0x10,%esp
  801128:	8b 75 14             	mov    0x14(%ebp),%esi
  80112b:	8b 45 08             	mov    0x8(%ebp),%eax
  80112e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801131:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801134:	85 f6                	test   %esi,%esi
  801136:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801139:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80113c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80113f:	75 2f                	jne    801170 <__udivdi3+0x50>
  801141:	39 f9                	cmp    %edi,%ecx
  801143:	77 5b                	ja     8011a0 <__udivdi3+0x80>
  801145:	85 c9                	test   %ecx,%ecx
  801147:	75 0b                	jne    801154 <__udivdi3+0x34>
  801149:	b8 01 00 00 00       	mov    $0x1,%eax
  80114e:	31 d2                	xor    %edx,%edx
  801150:	f7 f1                	div    %ecx
  801152:	89 c1                	mov    %eax,%ecx
  801154:	89 f8                	mov    %edi,%eax
  801156:	31 d2                	xor    %edx,%edx
  801158:	f7 f1                	div    %ecx
  80115a:	89 c7                	mov    %eax,%edi
  80115c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115f:	f7 f1                	div    %ecx
  801161:	89 fa                	mov    %edi,%edx
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	5e                   	pop    %esi
  801167:	5f                   	pop    %edi
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    
  80116a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801170:	31 d2                	xor    %edx,%edx
  801172:	31 c0                	xor    %eax,%eax
  801174:	39 fe                	cmp    %edi,%esi
  801176:	77 eb                	ja     801163 <__udivdi3+0x43>
  801178:	0f bd d6             	bsr    %esi,%edx
  80117b:	83 f2 1f             	xor    $0x1f,%edx
  80117e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801181:	75 2d                	jne    8011b0 <__udivdi3+0x90>
  801183:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801186:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  801189:	76 06                	jbe    801191 <__udivdi3+0x71>
  80118b:	39 fe                	cmp    %edi,%esi
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	73 d2                	jae    801163 <__udivdi3+0x43>
  801191:	31 d2                	xor    %edx,%edx
  801193:	b8 01 00 00 00       	mov    $0x1,%eax
  801198:	eb c9                	jmp    801163 <__udivdi3+0x43>
  80119a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011a0:	89 fa                	mov    %edi,%edx
  8011a2:	f7 f1                	div    %ecx
  8011a4:	31 d2                	xor    %edx,%edx
  8011a6:	83 c4 10             	add    $0x10,%esp
  8011a9:	5e                   	pop    %esi
  8011aa:	5f                   	pop    %edi
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    
  8011ad:	8d 76 00             	lea    0x0(%esi),%esi
  8011b0:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011b4:	b8 20 00 00 00       	mov    $0x20,%eax
  8011b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011bc:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8011bf:	d3 e6                	shl    %cl,%esi
  8011c1:	89 c1                	mov    %eax,%ecx
  8011c3:	d3 ea                	shr    %cl,%edx
  8011c5:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011c9:	09 f2                	or     %esi,%edx
  8011cb:	8b 75 ec             	mov    -0x14(%ebp),%esi
  8011ce:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8011d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011d4:	d3 e2                	shl    %cl,%edx
  8011d6:	89 c1                	mov    %eax,%ecx
  8011d8:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8011db:	89 fa                	mov    %edi,%edx
  8011dd:	d3 ea                	shr    %cl,%edx
  8011df:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011e3:	d3 e7                	shl    %cl,%edi
  8011e5:	89 c1                	mov    %eax,%ecx
  8011e7:	d3 ee                	shr    %cl,%esi
  8011e9:	09 fe                	or     %edi,%esi
  8011eb:	89 f0                	mov    %esi,%eax
  8011ed:	f7 75 e8             	divl   -0x18(%ebp)
  8011f0:	89 d7                	mov    %edx,%edi
  8011f2:	89 c6                	mov    %eax,%esi
  8011f4:	f7 65 f0             	mull   -0x10(%ebp)
  8011f7:	39 d7                	cmp    %edx,%edi
  8011f9:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8011fc:	72 22                	jb     801220 <__udivdi3+0x100>
  8011fe:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801201:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801205:	d3 e2                	shl    %cl,%edx
  801207:	39 c2                	cmp    %eax,%edx
  801209:	73 05                	jae    801210 <__udivdi3+0xf0>
  80120b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80120e:	74 10                	je     801220 <__udivdi3+0x100>
  801210:	89 f0                	mov    %esi,%eax
  801212:	31 d2                	xor    %edx,%edx
  801214:	e9 4a ff ff ff       	jmp    801163 <__udivdi3+0x43>
  801219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801220:	8d 46 ff             	lea    -0x1(%esi),%eax
  801223:	31 d2                	xor    %edx,%edx
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	5e                   	pop    %esi
  801229:	5f                   	pop    %edi
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    
  80122c:	00 00                	add    %al,(%eax)
	...

00801230 <__umoddi3>:
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	57                   	push   %edi
  801234:	56                   	push   %esi
  801235:	83 ec 20             	sub    $0x20,%esp
  801238:	8b 7d 14             	mov    0x14(%ebp),%edi
  80123b:	8b 45 08             	mov    0x8(%ebp),%eax
  80123e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801241:	8b 75 0c             	mov    0xc(%ebp),%esi
  801244:	85 ff                	test   %edi,%edi
  801246:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801249:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80124c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80124f:	89 f2                	mov    %esi,%edx
  801251:	75 15                	jne    801268 <__umoddi3+0x38>
  801253:	39 f1                	cmp    %esi,%ecx
  801255:	76 41                	jbe    801298 <__umoddi3+0x68>
  801257:	f7 f1                	div    %ecx
  801259:	89 d0                	mov    %edx,%eax
  80125b:	31 d2                	xor    %edx,%edx
  80125d:	83 c4 20             	add    $0x20,%esp
  801260:	5e                   	pop    %esi
  801261:	5f                   	pop    %edi
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    
  801264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801268:	39 f7                	cmp    %esi,%edi
  80126a:	77 4c                	ja     8012b8 <__umoddi3+0x88>
  80126c:	0f bd c7             	bsr    %edi,%eax
  80126f:	83 f0 1f             	xor    $0x1f,%eax
  801272:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801275:	75 51                	jne    8012c8 <__umoddi3+0x98>
  801277:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80127a:	0f 87 e8 00 00 00    	ja     801368 <__umoddi3+0x138>
  801280:	89 f2                	mov    %esi,%edx
  801282:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801285:	29 ce                	sub    %ecx,%esi
  801287:	19 fa                	sbb    %edi,%edx
  801289:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80128c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128f:	83 c4 20             	add    $0x20,%esp
  801292:	5e                   	pop    %esi
  801293:	5f                   	pop    %edi
  801294:	5d                   	pop    %ebp
  801295:	c3                   	ret    
  801296:	66 90                	xchg   %ax,%ax
  801298:	85 c9                	test   %ecx,%ecx
  80129a:	75 0b                	jne    8012a7 <__umoddi3+0x77>
  80129c:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a1:	31 d2                	xor    %edx,%edx
  8012a3:	f7 f1                	div    %ecx
  8012a5:	89 c1                	mov    %eax,%ecx
  8012a7:	89 f0                	mov    %esi,%eax
  8012a9:	31 d2                	xor    %edx,%edx
  8012ab:	f7 f1                	div    %ecx
  8012ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b0:	eb a5                	jmp    801257 <__umoddi3+0x27>
  8012b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012b8:	89 f2                	mov    %esi,%edx
  8012ba:	83 c4 20             	add    $0x20,%esp
  8012bd:	5e                   	pop    %esi
  8012be:	5f                   	pop    %edi
  8012bf:	5d                   	pop    %ebp
  8012c0:	c3                   	ret    
  8012c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012cc:	89 f2                	mov    %esi,%edx
  8012ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8012d1:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  8012d8:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8012db:	d3 e7                	shl    %cl,%edi
  8012dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012e4:	d3 e8                	shr    %cl,%eax
  8012e6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012ea:	09 f8                	or     %edi,%eax
  8012ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f2:	d3 e0                	shl    %cl,%eax
  8012f4:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8012fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8012fe:	d3 ea                	shr    %cl,%edx
  801300:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801304:	d3 e6                	shl    %cl,%esi
  801306:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80130a:	d3 e8                	shr    %cl,%eax
  80130c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801310:	09 f0                	or     %esi,%eax
  801312:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801315:	f7 75 e4             	divl   -0x1c(%ebp)
  801318:	d3 e6                	shl    %cl,%esi
  80131a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80131d:	89 d6                	mov    %edx,%esi
  80131f:	f7 65 f4             	mull   -0xc(%ebp)
  801322:	89 d7                	mov    %edx,%edi
  801324:	89 c2                	mov    %eax,%edx
  801326:	39 fe                	cmp    %edi,%esi
  801328:	89 f9                	mov    %edi,%ecx
  80132a:	72 30                	jb     80135c <__umoddi3+0x12c>
  80132c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80132f:	72 27                	jb     801358 <__umoddi3+0x128>
  801331:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801334:	29 d0                	sub    %edx,%eax
  801336:	19 ce                	sbb    %ecx,%esi
  801338:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80133c:	89 f2                	mov    %esi,%edx
  80133e:	d3 e8                	shr    %cl,%eax
  801340:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801344:	d3 e2                	shl    %cl,%edx
  801346:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80134a:	09 d0                	or     %edx,%eax
  80134c:	89 f2                	mov    %esi,%edx
  80134e:	d3 ea                	shr    %cl,%edx
  801350:	83 c4 20             	add    $0x20,%esp
  801353:	5e                   	pop    %esi
  801354:	5f                   	pop    %edi
  801355:	5d                   	pop    %ebp
  801356:	c3                   	ret    
  801357:	90                   	nop
  801358:	39 fe                	cmp    %edi,%esi
  80135a:	75 d5                	jne    801331 <__umoddi3+0x101>
  80135c:	89 f9                	mov    %edi,%ecx
  80135e:	89 c2                	mov    %eax,%edx
  801360:	2b 55 f4             	sub    -0xc(%ebp),%edx
  801363:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801366:	eb c9                	jmp    801331 <__umoddi3+0x101>
  801368:	39 f7                	cmp    %esi,%edi
  80136a:	0f 82 10 ff ff ff    	jb     801280 <__umoddi3+0x50>
  801370:	e9 17 ff ff ff       	jmp    80128c <__umoddi3+0x5c>
