
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 57 0c 00 00       	call   800c98 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 02 0f 00 00       	call   800f6c <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 c0 12 80 00 	movl   $0x8012c0,(%esp)
  80007c:	e8 4a 01 00 00       	call   8001cb <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 d1 12 80 00 	movl   $0x8012d1,(%esp)
  800097:	e8 2f 01 00 00       	call   8001cb <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a3:	00 
  8000a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ab:	00 
  8000ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b3:	00 
  8000b4:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 cd 0e 00 00       	call   800f8e <ipc_send>
  8000c1:	eb d9                	jmp    80009c <umain+0x68>
	...

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 18             	sub    $0x18,%esp
  8000ca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000cd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  8000d6:	e8 bd 0b 00 00       	call   800c98 <sys_getenvid>
  8000db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e8:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ed:	85 f6                	test   %esi,%esi
  8000ef:	7e 07                	jle    8000f8 <libmain+0x34>
		binaryname = argv[0];
  8000f1:	8b 03                	mov    (%ebx),%eax
  8000f3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000fc:	89 34 24             	mov    %esi,(%esp)
  8000ff:	e8 30 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800104:	e8 0b 00 00 00       	call   800114 <exit>
}
  800109:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80010c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80010f:	89 ec                	mov    %ebp,%esp
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
	...

00800114 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80011a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800121:	e8 15 0b 00 00       	call   800c3b <sys_env_destroy>
}
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	53                   	push   %ebx
  80012c:	83 ec 14             	sub    $0x14,%esp
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800132:	8b 03                	mov    (%ebx),%eax
  800134:	8b 55 08             	mov    0x8(%ebp),%edx
  800137:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80013b:	83 c0 01             	add    $0x1,%eax
  80013e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800140:	3d ff 00 00 00       	cmp    $0xff,%eax
  800145:	75 19                	jne    800160 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800147:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80014e:	00 
  80014f:	8d 43 08             	lea    0x8(%ebx),%eax
  800152:	89 04 24             	mov    %eax,(%esp)
  800155:	e8 7a 0a 00 00       	call   800bd4 <sys_cputs>
		b->idx = 0;
  80015a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800160:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800164:	83 c4 14             	add    $0x14,%esp
  800167:	5b                   	pop    %ebx
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800173:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017a:	00 00 00 
	b.cnt = 0;
  80017d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800184:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800187:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 44 24 08          	mov    %eax,0x8(%esp)
  800195:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019f:	c7 04 24 28 01 80 00 	movl   $0x800128,(%esp)
  8001a6:	e8 e6 01 00 00       	call   800391 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ab:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001bb:	89 04 24             	mov    %eax,(%esp)
  8001be:	e8 11 0a 00 00       	call   800bd4 <sys_cputs>

	return b.cnt;
}
  8001c3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001db:	89 04 24             	mov    %eax,(%esp)
  8001de:	e8 87 ff ff ff       	call   80016a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    
	...

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 4c             	sub    $0x4c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d6                	mov    %edx,%esi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800204:	8b 55 0c             	mov    0xc(%ebp),%edx
  800207:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80020a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80020d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800210:	b8 00 00 00 00       	mov    $0x0,%eax
  800215:	39 d0                	cmp    %edx,%eax
  800217:	72 11                	jb     80022a <printnum+0x3a>
  800219:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80021c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  80021f:	76 09                	jbe    80022a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800221:	83 eb 01             	sub    $0x1,%ebx
  800224:	85 db                	test   %ebx,%ebx
  800226:	7f 5d                	jg     800285 <printnum+0x95>
  800228:	eb 6c                	jmp    800296 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80022e:	83 eb 01             	sub    $0x1,%ebx
  800231:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800235:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800238:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80023c:	8b 44 24 08          	mov    0x8(%esp),%eax
  800240:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800244:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800247:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80024a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800251:	00 
  800252:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800255:	89 14 24             	mov    %edx,(%esp)
  800258:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80025b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80025f:	e8 ec 0d 00 00       	call   801050 <__udivdi3>
  800264:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800267:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80026a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80026e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800272:	89 04 24             	mov    %eax,(%esp)
  800275:	89 54 24 04          	mov    %edx,0x4(%esp)
  800279:	89 f2                	mov    %esi,%edx
  80027b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80027e:	e8 6d ff ff ff       	call   8001f0 <printnum>
  800283:	eb 11                	jmp    800296 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800285:	89 74 24 04          	mov    %esi,0x4(%esp)
  800289:	89 3c 24             	mov    %edi,(%esp)
  80028c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f ef                	jg     800285 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	89 74 24 04          	mov    %esi,0x4(%esp)
  80029a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80029e:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ac:	00 
  8002ad:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002b0:	89 14 24             	mov    %edx,(%esp)
  8002b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002ba:	e8 a1 0e 00 00       	call   801160 <__umoddi3>
  8002bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002c3:	0f be 80 f2 12 80 00 	movsbl 0x8012f2(%eax),%eax
  8002ca:	89 04 24             	mov    %eax,(%esp)
  8002cd:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002d0:	83 c4 4c             	add    $0x4c,%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002db:	83 fa 01             	cmp    $0x1,%edx
  8002de:	7e 0e                	jle    8002ee <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	8b 52 04             	mov    0x4(%edx),%edx
  8002ec:	eb 22                	jmp    800310 <getuint+0x38>
	else if (lflag)
  8002ee:	85 d2                	test   %edx,%edx
  8002f0:	74 10                	je     800302 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800300:	eb 0e                	jmp    800310 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800315:	83 fa 01             	cmp    $0x1,%edx
  800318:	7e 0e                	jle    800328 <getint+0x16>
		return va_arg(*ap, long long);
  80031a:	8b 10                	mov    (%eax),%edx
  80031c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80031f:	89 08                	mov    %ecx,(%eax)
  800321:	8b 02                	mov    (%edx),%eax
  800323:	8b 52 04             	mov    0x4(%edx),%edx
  800326:	eb 22                	jmp    80034a <getint+0x38>
	else if (lflag)
  800328:	85 d2                	test   %edx,%edx
  80032a:	74 10                	je     80033c <getint+0x2a>
		return va_arg(*ap, long);
  80032c:	8b 10                	mov    (%eax),%edx
  80032e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800331:	89 08                	mov    %ecx,(%eax)
  800333:	8b 02                	mov    (%edx),%eax
  800335:	89 c2                	mov    %eax,%edx
  800337:	c1 fa 1f             	sar    $0x1f,%edx
  80033a:	eb 0e                	jmp    80034a <getint+0x38>
	else
		return va_arg(*ap, int);
  80033c:	8b 10                	mov    (%eax),%edx
  80033e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800341:	89 08                	mov    %ecx,(%eax)
  800343:	8b 02                	mov    (%edx),%eax
  800345:	89 c2                	mov    %eax,%edx
  800347:	c1 fa 1f             	sar    $0x1f,%edx
}
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    

0080034c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800352:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800356:	8b 10                	mov    (%eax),%edx
  800358:	3b 50 04             	cmp    0x4(%eax),%edx
  80035b:	73 0a                	jae    800367 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800360:	88 0a                	mov    %cl,(%edx)
  800362:	83 c2 01             	add    $0x1,%edx
  800365:	89 10                	mov    %edx,(%eax)
}
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80036f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800372:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800376:	8b 45 10             	mov    0x10(%ebp),%eax
  800379:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800380:	89 44 24 04          	mov    %eax,0x4(%esp)
  800384:	8b 45 08             	mov    0x8(%ebp),%eax
  800387:	89 04 24             	mov    %eax,(%esp)
  80038a:	e8 02 00 00 00       	call   800391 <vprintfmt>
	va_end(ap);
}
  80038f:	c9                   	leave  
  800390:	c3                   	ret    

00800391 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	57                   	push   %edi
  800395:	56                   	push   %esi
  800396:	53                   	push   %ebx
  800397:	83 ec 4c             	sub    $0x4c,%esp
  80039a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039d:	eb 23                	jmp    8003c2 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80039f:	85 c0                	test   %eax,%eax
  8003a1:	75 12                	jne    8003b5 <vprintfmt+0x24>
				csa = 0x0700;
  8003a3:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  8003aa:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8003ad:	83 c4 4c             	add    $0x4c,%esp
  8003b0:	5b                   	pop    %ebx
  8003b1:	5e                   	pop    %esi
  8003b2:	5f                   	pop    %edi
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  8003b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c2:	0f b6 07             	movzbl (%edi),%eax
  8003c5:	83 c7 01             	add    $0x1,%edi
  8003c8:	83 f8 25             	cmp    $0x25,%eax
  8003cb:	75 d2                	jne    80039f <vprintfmt+0xe>
  8003cd:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003d1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003d8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8003dd:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003e4:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003e9:	be 00 00 00 00       	mov    $0x0,%esi
  8003ee:	eb 14                	jmp    800404 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003f4:	eb 0e                	jmp    800404 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f6:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003fa:	eb 08                	jmp    800404 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003fc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ff:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	0f b6 07             	movzbl (%edi),%eax
  800407:	0f b6 c8             	movzbl %al,%ecx
  80040a:	83 c7 01             	add    $0x1,%edi
  80040d:	83 e8 23             	sub    $0x23,%eax
  800410:	3c 55                	cmp    $0x55,%al
  800412:	0f 87 ed 02 00 00    	ja     800705 <vprintfmt+0x374>
  800418:	0f b6 c0             	movzbl %al,%eax
  80041b:	ff 24 85 c0 13 80 00 	jmp    *0x8013c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800422:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  800425:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800428:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80042b:	83 f9 09             	cmp    $0x9,%ecx
  80042e:	77 3c                	ja     80046c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800430:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800433:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  800436:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  80043a:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80043d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800440:	83 f9 09             	cmp    $0x9,%ecx
  800443:	76 eb                	jbe    800430 <vprintfmt+0x9f>
  800445:	eb 25                	jmp    80046c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 48 04             	lea    0x4(%eax),%ecx
  80044d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800450:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  800452:	eb 18                	jmp    80046c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  800454:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800458:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80045b:	0f 48 c6             	cmovs  %esi,%eax
  80045e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800461:	eb a1                	jmp    800404 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  800463:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80046a:	eb 98                	jmp    800404 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  80046c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800470:	79 92                	jns    800404 <vprintfmt+0x73>
  800472:	eb 88                	jmp    8003fc <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800474:	83 c2 01             	add    $0x1,%edx
  800477:	eb 8b                	jmp    800404 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	8d 50 04             	lea    0x4(%eax),%edx
  80047f:	89 55 14             	mov    %edx,0x14(%ebp)
  800482:	8b 55 0c             	mov    0xc(%ebp),%edx
  800485:	89 54 24 04          	mov    %edx,0x4(%esp)
  800489:	8b 00                	mov    (%eax),%eax
  80048b:	89 04 24             	mov    %eax,(%esp)
  80048e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800491:	e9 2c ff ff ff       	jmp    8003c2 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8d 50 04             	lea    0x4(%eax),%edx
  80049c:	89 55 14             	mov    %edx,0x14(%ebp)
  80049f:	8b 00                	mov    (%eax),%eax
  8004a1:	89 c2                	mov    %eax,%edx
  8004a3:	c1 fa 1f             	sar    $0x1f,%edx
  8004a6:	31 d0                	xor    %edx,%eax
  8004a8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004aa:	83 f8 08             	cmp    $0x8,%eax
  8004ad:	7f 0b                	jg     8004ba <vprintfmt+0x129>
  8004af:	8b 14 85 20 15 80 00 	mov    0x801520(,%eax,4),%edx
  8004b6:	85 d2                	test   %edx,%edx
  8004b8:	75 23                	jne    8004dd <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  8004ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004be:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  8004c5:	00 
  8004c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d0:	89 04 24             	mov    %eax,(%esp)
  8004d3:	e8 91 fe ff ff       	call   800369 <printfmt>
  8004d8:	e9 e5 fe ff ff       	jmp    8003c2 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8004dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e1:	c7 44 24 08 13 13 80 	movl   $0x801313,0x8(%esp)
  8004e8:	00 
  8004e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004f3:	89 1c 24             	mov    %ebx,(%esp)
  8004f6:	e8 6e fe ff ff       	call   800369 <printfmt>
  8004fb:	e9 c2 fe ff ff       	jmp    8003c2 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800503:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800506:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 50 04             	lea    0x4(%eax),%edx
  80050f:	89 55 14             	mov    %edx,0x14(%ebp)
  800512:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800514:	85 f6                	test   %esi,%esi
  800516:	ba 03 13 80 00       	mov    $0x801303,%edx
  80051b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80051e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800522:	7e 06                	jle    80052a <vprintfmt+0x199>
  800524:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800528:	75 13                	jne    80053d <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052a:	0f be 06             	movsbl (%esi),%eax
  80052d:	83 c6 01             	add    $0x1,%esi
  800530:	85 c0                	test   %eax,%eax
  800532:	0f 85 a2 00 00 00    	jne    8005da <vprintfmt+0x249>
  800538:	e9 92 00 00 00       	jmp    8005cf <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800541:	89 34 24             	mov    %esi,(%esp)
  800544:	e8 82 02 00 00       	call   8007cb <strnlen>
  800549:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80054c:	29 c2                	sub    %eax,%edx
  80054e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800551:	85 d2                	test   %edx,%edx
  800553:	7e d5                	jle    80052a <vprintfmt+0x199>
					putch(padc, putdat);
  800555:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800559:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80055c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80055f:	89 d3                	mov    %edx,%ebx
  800561:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800564:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800567:	89 c6                	mov    %eax,%esi
  800569:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056d:	89 34 24             	mov    %esi,(%esp)
  800570:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800573:	83 eb 01             	sub    $0x1,%ebx
  800576:	85 db                	test   %ebx,%ebx
  800578:	7f ef                	jg     800569 <vprintfmt+0x1d8>
  80057a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80057d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800580:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800583:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80058a:	eb 9e                	jmp    80052a <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80058c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800590:	74 1b                	je     8005ad <vprintfmt+0x21c>
  800592:	8d 50 e0             	lea    -0x20(%eax),%edx
  800595:	83 fa 5e             	cmp    $0x5e,%edx
  800598:	76 13                	jbe    8005ad <vprintfmt+0x21c>
					putch('?', putdat);
  80059a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80059d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005a1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a8:	ff 55 08             	call   *0x8(%ebp)
  8005ab:	eb 0d                	jmp    8005ba <vprintfmt+0x229>
				else
					putch(ch, putdat);
  8005ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005b0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005b4:	89 04 24             	mov    %eax,(%esp)
  8005b7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ba:	83 ef 01             	sub    $0x1,%edi
  8005bd:	0f be 06             	movsbl (%esi),%eax
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	74 05                	je     8005c9 <vprintfmt+0x238>
  8005c4:	83 c6 01             	add    $0x1,%esi
  8005c7:	eb 17                	jmp    8005e0 <vprintfmt+0x24f>
  8005c9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005cc:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d3:	7f 1c                	jg     8005f1 <vprintfmt+0x260>
  8005d5:	e9 e8 fd ff ff       	jmp    8003c2 <vprintfmt+0x31>
  8005da:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8005dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e0:	85 db                	test   %ebx,%ebx
  8005e2:	78 a8                	js     80058c <vprintfmt+0x1fb>
  8005e4:	83 eb 01             	sub    $0x1,%ebx
  8005e7:	79 a3                	jns    80058c <vprintfmt+0x1fb>
  8005e9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005ec:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005ef:	eb de                	jmp    8005cf <vprintfmt+0x23e>
  8005f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f7:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005fe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800605:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800607:	83 eb 01             	sub    $0x1,%ebx
  80060a:	85 db                	test   %ebx,%ebx
  80060c:	7f ec                	jg     8005fa <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800611:	e9 ac fd ff ff       	jmp    8003c2 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800616:	8d 45 14             	lea    0x14(%ebp),%eax
  800619:	e8 f4 fc ff ff       	call   800312 <getint>
  80061e:	89 c3                	mov    %eax,%ebx
  800620:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800622:	85 d2                	test   %edx,%edx
  800624:	78 0a                	js     800630 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800626:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062b:	e9 87 00 00 00       	jmp    8006b7 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800630:	8b 45 0c             	mov    0xc(%ebp),%eax
  800633:	89 44 24 04          	mov    %eax,0x4(%esp)
  800637:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80063e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800641:	89 d8                	mov    %ebx,%eax
  800643:	89 f2                	mov    %esi,%edx
  800645:	f7 d8                	neg    %eax
  800647:	83 d2 00             	adc    $0x0,%edx
  80064a:	f7 da                	neg    %edx
			}
			base = 10;
  80064c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800651:	eb 64                	jmp    8006b7 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 7d fc ff ff       	call   8002d8 <getuint>
			base = 10;
  80065b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800660:	eb 55                	jmp    8006b7 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800662:	8d 45 14             	lea    0x14(%ebp),%eax
  800665:	e8 6e fc ff ff       	call   8002d8 <getuint>
      base = 8;
  80066a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80066f:	eb 46                	jmp    8006b7 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800671:	8b 55 0c             	mov    0xc(%ebp),%edx
  800674:	89 54 24 04          	mov    %edx,0x4(%esp)
  800678:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80067f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800682:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800685:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800689:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800690:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8d 50 04             	lea    0x4(%eax),%edx
  800699:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069c:	8b 00                	mov    (%eax),%eax
  80069e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a8:	eb 0d                	jmp    8006b7 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ad:	e8 26 fc ff ff       	call   8002d8 <getuint>
			base = 16;
  8006b2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b7:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006bb:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8006bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006c2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006c6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006ca:	89 04 24             	mov    %eax,(%esp)
  8006cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d7:	e8 14 fb ff ff       	call   8001f0 <printnum>
			break;
  8006dc:	e9 e1 fc ff ff       	jmp    8003c2 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e8:	89 0c 24             	mov    %ecx,(%esp)
  8006eb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006ee:	e9 cf fc ff ff       	jmp    8003c2 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  8006f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f6:	e8 17 fc ff ff       	call   800312 <getint>
			csa = num;
  8006fb:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  800700:	e9 bd fc ff ff       	jmp    8003c2 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800705:	8b 55 0c             	mov    0xc(%ebp),%edx
  800708:	89 54 24 04          	mov    %edx,0x4(%esp)
  80070c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800713:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800716:	83 ef 01             	sub    $0x1,%edi
  800719:	eb 02                	jmp    80071d <vprintfmt+0x38c>
  80071b:	89 c7                	mov    %eax,%edi
  80071d:	8d 47 ff             	lea    -0x1(%edi),%eax
  800720:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800724:	75 f5                	jne    80071b <vprintfmt+0x38a>
  800726:	e9 97 fc ff ff       	jmp    8003c2 <vprintfmt+0x31>

0080072b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	83 ec 28             	sub    $0x28,%esp
  800731:	8b 45 08             	mov    0x8(%ebp),%eax
  800734:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800737:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800741:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800748:	85 c0                	test   %eax,%eax
  80074a:	74 30                	je     80077c <vsnprintf+0x51>
  80074c:	85 d2                	test   %edx,%edx
  80074e:	7e 2c                	jle    80077c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800757:	8b 45 10             	mov    0x10(%ebp),%eax
  80075a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800761:	89 44 24 04          	mov    %eax,0x4(%esp)
  800765:	c7 04 24 4c 03 80 00 	movl   $0x80034c,(%esp)
  80076c:	e8 20 fc ff ff       	call   800391 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800771:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800774:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800777:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077a:	eb 05                	jmp    800781 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80077c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800781:	c9                   	leave  
  800782:	c3                   	ret    

00800783 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800789:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800790:	8b 45 10             	mov    0x10(%ebp),%eax
  800793:	89 44 24 08          	mov    %eax,0x8(%esp)
  800797:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	89 04 24             	mov    %eax,(%esp)
  8007a4:	e8 82 ff ff ff       	call   80072b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    
  8007ab:	00 00                	add    %al,(%eax)
  8007ad:	00 00                	add    %al,(%eax)
	...

008007b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007be:	74 09                	je     8007c9 <strlen+0x19>
		n++;
  8007c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c7:	75 f7                	jne    8007c0 <strlen+0x10>
		n++;
	return n;
}
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	74 12                	je     8007ef <strnlen+0x24>
  8007dd:	80 39 00             	cmpb   $0x0,(%ecx)
  8007e0:	74 0d                	je     8007ef <strnlen+0x24>
		n++;
  8007e2:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e5:	39 d0                	cmp    %edx,%eax
  8007e7:	74 06                	je     8007ef <strnlen+0x24>
  8007e9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ed:	75 f3                	jne    8007e2 <strnlen+0x17>
		n++;
	return n;
}
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800800:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800804:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800807:	83 c2 01             	add    $0x1,%edx
  80080a:	84 c9                	test   %cl,%cl
  80080c:	75 f2                	jne    800800 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80080e:	5b                   	pop    %ebx
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	53                   	push   %ebx
  800815:	83 ec 08             	sub    $0x8,%esp
  800818:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081b:	89 1c 24             	mov    %ebx,(%esp)
  80081e:	e8 8d ff ff ff       	call   8007b0 <strlen>
	strcpy(dst + len, src);
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
  800826:	89 54 24 04          	mov    %edx,0x4(%esp)
  80082a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80082d:	89 04 24             	mov    %eax,(%esp)
  800830:	e8 bc ff ff ff       	call   8007f1 <strcpy>
	return dst;
}
  800835:	89 d8                	mov    %ebx,%eax
  800837:	83 c4 08             	add    $0x8,%esp
  80083a:	5b                   	pop    %ebx
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	56                   	push   %esi
  800841:	53                   	push   %ebx
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
  800848:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084b:	85 f6                	test   %esi,%esi
  80084d:	74 18                	je     800867 <strncpy+0x2a>
  80084f:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800854:	0f b6 1a             	movzbl (%edx),%ebx
  800857:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085a:	80 3a 01             	cmpb   $0x1,(%edx)
  80085d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800860:	83 c1 01             	add    $0x1,%ecx
  800863:	39 ce                	cmp    %ecx,%esi
  800865:	77 ed                	ja     800854 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800867:	5b                   	pop    %ebx
  800868:	5e                   	pop    %esi
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	56                   	push   %esi
  80086f:	53                   	push   %ebx
  800870:	8b 75 08             	mov    0x8(%ebp),%esi
  800873:	8b 55 0c             	mov    0xc(%ebp),%edx
  800876:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800879:	89 f0                	mov    %esi,%eax
  80087b:	85 c9                	test   %ecx,%ecx
  80087d:	74 23                	je     8008a2 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  80087f:	83 e9 01             	sub    $0x1,%ecx
  800882:	74 1b                	je     80089f <strlcpy+0x34>
  800884:	0f b6 1a             	movzbl (%edx),%ebx
  800887:	84 db                	test   %bl,%bl
  800889:	74 14                	je     80089f <strlcpy+0x34>
			*dst++ = *src++;
  80088b:	88 18                	mov    %bl,(%eax)
  80088d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800890:	83 e9 01             	sub    $0x1,%ecx
  800893:	74 0a                	je     80089f <strlcpy+0x34>
			*dst++ = *src++;
  800895:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800898:	0f b6 1a             	movzbl (%edx),%ebx
  80089b:	84 db                	test   %bl,%bl
  80089d:	75 ec                	jne    80088b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80089f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a2:	29 f0                	sub    %esi,%eax
}
  8008a4:	5b                   	pop    %ebx
  8008a5:	5e                   	pop    %esi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b1:	0f b6 01             	movzbl (%ecx),%eax
  8008b4:	84 c0                	test   %al,%al
  8008b6:	74 15                	je     8008cd <strcmp+0x25>
  8008b8:	3a 02                	cmp    (%edx),%al
  8008ba:	75 11                	jne    8008cd <strcmp+0x25>
		p++, q++;
  8008bc:	83 c1 01             	add    $0x1,%ecx
  8008bf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c2:	0f b6 01             	movzbl (%ecx),%eax
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 04                	je     8008cd <strcmp+0x25>
  8008c9:	3a 02                	cmp    (%edx),%al
  8008cb:	74 ef                	je     8008bc <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 c0             	movzbl %al,%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008e1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e9:	85 d2                	test   %edx,%edx
  8008eb:	74 28                	je     800915 <strncmp+0x3e>
  8008ed:	0f b6 01             	movzbl (%ecx),%eax
  8008f0:	84 c0                	test   %al,%al
  8008f2:	74 24                	je     800918 <strncmp+0x41>
  8008f4:	3a 03                	cmp    (%ebx),%al
  8008f6:	75 20                	jne    800918 <strncmp+0x41>
  8008f8:	83 ea 01             	sub    $0x1,%edx
  8008fb:	74 13                	je     800910 <strncmp+0x39>
		n--, p++, q++;
  8008fd:	83 c1 01             	add    $0x1,%ecx
  800900:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800903:	0f b6 01             	movzbl (%ecx),%eax
  800906:	84 c0                	test   %al,%al
  800908:	74 0e                	je     800918 <strncmp+0x41>
  80090a:	3a 03                	cmp    (%ebx),%al
  80090c:	74 ea                	je     8008f8 <strncmp+0x21>
  80090e:	eb 08                	jmp    800918 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800915:	5b                   	pop    %ebx
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800918:	0f b6 01             	movzbl (%ecx),%eax
  80091b:	0f b6 13             	movzbl (%ebx),%edx
  80091e:	29 d0                	sub    %edx,%eax
  800920:	eb f3                	jmp    800915 <strncmp+0x3e>

00800922 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092c:	0f b6 10             	movzbl (%eax),%edx
  80092f:	84 d2                	test   %dl,%dl
  800931:	74 20                	je     800953 <strchr+0x31>
		if (*s == c)
  800933:	38 ca                	cmp    %cl,%dl
  800935:	75 0b                	jne    800942 <strchr+0x20>
  800937:	eb 1f                	jmp    800958 <strchr+0x36>
  800939:	38 ca                	cmp    %cl,%dl
  80093b:	90                   	nop
  80093c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800940:	74 16                	je     800958 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800942:	83 c0 01             	add    $0x1,%eax
  800945:	0f b6 10             	movzbl (%eax),%edx
  800948:	84 d2                	test   %dl,%dl
  80094a:	75 ed                	jne    800939 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax
  800951:	eb 05                	jmp    800958 <strchr+0x36>
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800964:	0f b6 10             	movzbl (%eax),%edx
  800967:	84 d2                	test   %dl,%dl
  800969:	74 14                	je     80097f <strfind+0x25>
		if (*s == c)
  80096b:	38 ca                	cmp    %cl,%dl
  80096d:	75 06                	jne    800975 <strfind+0x1b>
  80096f:	eb 0e                	jmp    80097f <strfind+0x25>
  800971:	38 ca                	cmp    %cl,%dl
  800973:	74 0a                	je     80097f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	0f b6 10             	movzbl (%eax),%edx
  80097b:	84 d2                	test   %dl,%dl
  80097d:	75 f2                	jne    800971 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	83 ec 0c             	sub    $0xc,%esp
  800987:	89 1c 24             	mov    %ebx,(%esp)
  80098a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80098e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800992:	8b 7d 08             	mov    0x8(%ebp),%edi
  800995:	8b 45 0c             	mov    0xc(%ebp),%eax
  800998:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099b:	85 c9                	test   %ecx,%ecx
  80099d:	74 30                	je     8009cf <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80099f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a5:	75 25                	jne    8009cc <memset+0x4b>
  8009a7:	f6 c1 03             	test   $0x3,%cl
  8009aa:	75 20                	jne    8009cc <memset+0x4b>
		c &= 0xFF;
  8009ac:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009af:	89 d3                	mov    %edx,%ebx
  8009b1:	c1 e3 08             	shl    $0x8,%ebx
  8009b4:	89 d6                	mov    %edx,%esi
  8009b6:	c1 e6 18             	shl    $0x18,%esi
  8009b9:	89 d0                	mov    %edx,%eax
  8009bb:	c1 e0 10             	shl    $0x10,%eax
  8009be:	09 f0                	or     %esi,%eax
  8009c0:	09 d0                	or     %edx,%eax
  8009c2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009c7:	fc                   	cld    
  8009c8:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ca:	eb 03                	jmp    8009cf <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009cc:	fc                   	cld    
  8009cd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009cf:	89 f8                	mov    %edi,%eax
  8009d1:	8b 1c 24             	mov    (%esp),%ebx
  8009d4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009d8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8009dc:	89 ec                	mov    %ebp,%esp
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	83 ec 08             	sub    $0x8,%esp
  8009e6:	89 34 24             	mov    %esi,(%esp)
  8009e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f6:	39 c6                	cmp    %eax,%esi
  8009f8:	73 36                	jae    800a30 <memmove+0x50>
  8009fa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009fd:	39 d0                	cmp    %edx,%eax
  8009ff:	73 2f                	jae    800a30 <memmove+0x50>
		s += n;
		d += n;
  800a01:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a04:	f6 c2 03             	test   $0x3,%dl
  800a07:	75 1b                	jne    800a24 <memmove+0x44>
  800a09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0f:	75 13                	jne    800a24 <memmove+0x44>
  800a11:	f6 c1 03             	test   $0x3,%cl
  800a14:	75 0e                	jne    800a24 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a16:	83 ef 04             	sub    $0x4,%edi
  800a19:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a1f:	fd                   	std    
  800a20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a22:	eb 09                	jmp    800a2d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a24:	83 ef 01             	sub    $0x1,%edi
  800a27:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a2a:	fd                   	std    
  800a2b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2d:	fc                   	cld    
  800a2e:	eb 20                	jmp    800a50 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a30:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a36:	75 13                	jne    800a4b <memmove+0x6b>
  800a38:	a8 03                	test   $0x3,%al
  800a3a:	75 0f                	jne    800a4b <memmove+0x6b>
  800a3c:	f6 c1 03             	test   $0x3,%cl
  800a3f:	75 0a                	jne    800a4b <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a41:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a44:	89 c7                	mov    %eax,%edi
  800a46:	fc                   	cld    
  800a47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a49:	eb 05                	jmp    800a50 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a4b:	89 c7                	mov    %eax,%edi
  800a4d:	fc                   	cld    
  800a4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a50:	8b 34 24             	mov    (%esp),%esi
  800a53:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a57:	89 ec                	mov    %ebp,%esp
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a61:	8b 45 10             	mov    0x10(%ebp),%eax
  800a64:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	89 04 24             	mov    %eax,(%esp)
  800a75:	e8 66 ff ff ff       	call   8009e0 <memmove>
}
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a88:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a90:	85 ff                	test   %edi,%edi
  800a92:	74 38                	je     800acc <memcmp+0x50>
		if (*s1 != *s2)
  800a94:	0f b6 03             	movzbl (%ebx),%eax
  800a97:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9a:	83 ef 01             	sub    $0x1,%edi
  800a9d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800aa2:	38 c8                	cmp    %cl,%al
  800aa4:	74 1d                	je     800ac3 <memcmp+0x47>
  800aa6:	eb 11                	jmp    800ab9 <memcmp+0x3d>
  800aa8:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800aad:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800ab2:	83 c2 01             	add    $0x1,%edx
  800ab5:	38 c8                	cmp    %cl,%al
  800ab7:	74 0a                	je     800ac3 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800ab9:	0f b6 c0             	movzbl %al,%eax
  800abc:	0f b6 c9             	movzbl %cl,%ecx
  800abf:	29 c8                	sub    %ecx,%eax
  800ac1:	eb 09                	jmp    800acc <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac3:	39 fa                	cmp    %edi,%edx
  800ac5:	75 e1                	jne    800aa8 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ad7:	89 c2                	mov    %eax,%edx
  800ad9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800adc:	39 d0                	cmp    %edx,%eax
  800ade:	73 15                	jae    800af5 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ae4:	38 08                	cmp    %cl,(%eax)
  800ae6:	75 06                	jne    800aee <memfind+0x1d>
  800ae8:	eb 0b                	jmp    800af5 <memfind+0x24>
  800aea:	38 08                	cmp    %cl,(%eax)
  800aec:	74 07                	je     800af5 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aee:	83 c0 01             	add    $0x1,%eax
  800af1:	39 c2                	cmp    %eax,%edx
  800af3:	77 f5                	ja     800aea <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	8b 55 08             	mov    0x8(%ebp),%edx
  800b00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b03:	0f b6 02             	movzbl (%edx),%eax
  800b06:	3c 20                	cmp    $0x20,%al
  800b08:	74 04                	je     800b0e <strtol+0x17>
  800b0a:	3c 09                	cmp    $0x9,%al
  800b0c:	75 0e                	jne    800b1c <strtol+0x25>
		s++;
  800b0e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b11:	0f b6 02             	movzbl (%edx),%eax
  800b14:	3c 20                	cmp    $0x20,%al
  800b16:	74 f6                	je     800b0e <strtol+0x17>
  800b18:	3c 09                	cmp    $0x9,%al
  800b1a:	74 f2                	je     800b0e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b1c:	3c 2b                	cmp    $0x2b,%al
  800b1e:	75 0a                	jne    800b2a <strtol+0x33>
		s++;
  800b20:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b23:	bf 00 00 00 00       	mov    $0x0,%edi
  800b28:	eb 10                	jmp    800b3a <strtol+0x43>
  800b2a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b2f:	3c 2d                	cmp    $0x2d,%al
  800b31:	75 07                	jne    800b3a <strtol+0x43>
		s++, neg = 1;
  800b33:	83 c2 01             	add    $0x1,%edx
  800b36:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3a:	85 db                	test   %ebx,%ebx
  800b3c:	0f 94 c0             	sete   %al
  800b3f:	74 05                	je     800b46 <strtol+0x4f>
  800b41:	83 fb 10             	cmp    $0x10,%ebx
  800b44:	75 15                	jne    800b5b <strtol+0x64>
  800b46:	80 3a 30             	cmpb   $0x30,(%edx)
  800b49:	75 10                	jne    800b5b <strtol+0x64>
  800b4b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b4f:	75 0a                	jne    800b5b <strtol+0x64>
		s += 2, base = 16;
  800b51:	83 c2 02             	add    $0x2,%edx
  800b54:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b59:	eb 13                	jmp    800b6e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800b5b:	84 c0                	test   %al,%al
  800b5d:	74 0f                	je     800b6e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b64:	80 3a 30             	cmpb   $0x30,(%edx)
  800b67:	75 05                	jne    800b6e <strtol+0x77>
		s++, base = 8;
  800b69:	83 c2 01             	add    $0x1,%edx
  800b6c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b73:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b75:	0f b6 0a             	movzbl (%edx),%ecx
  800b78:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b7b:	80 fb 09             	cmp    $0x9,%bl
  800b7e:	77 08                	ja     800b88 <strtol+0x91>
			dig = *s - '0';
  800b80:	0f be c9             	movsbl %cl,%ecx
  800b83:	83 e9 30             	sub    $0x30,%ecx
  800b86:	eb 1e                	jmp    800ba6 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b88:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b8b:	80 fb 19             	cmp    $0x19,%bl
  800b8e:	77 08                	ja     800b98 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b90:	0f be c9             	movsbl %cl,%ecx
  800b93:	83 e9 57             	sub    $0x57,%ecx
  800b96:	eb 0e                	jmp    800ba6 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b98:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b9b:	80 fb 19             	cmp    $0x19,%bl
  800b9e:	77 15                	ja     800bb5 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800ba0:	0f be c9             	movsbl %cl,%ecx
  800ba3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ba6:	39 f1                	cmp    %esi,%ecx
  800ba8:	7d 0f                	jge    800bb9 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800baa:	83 c2 01             	add    $0x1,%edx
  800bad:	0f af c6             	imul   %esi,%eax
  800bb0:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800bb3:	eb c0                	jmp    800b75 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bb5:	89 c1                	mov    %eax,%ecx
  800bb7:	eb 02                	jmp    800bbb <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bb9:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bbb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbf:	74 05                	je     800bc6 <strtol+0xcf>
		*endptr = (char *) s;
  800bc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bc4:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bc6:	89 ca                	mov    %ecx,%edx
  800bc8:	f7 da                	neg    %edx
  800bca:	85 ff                	test   %edi,%edi
  800bcc:	0f 45 c2             	cmovne %edx,%eax
}
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	83 ec 0c             	sub    $0xc,%esp
  800bda:	89 1c 24             	mov    %ebx,(%esp)
  800bdd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bed:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf0:	89 c3                	mov    %eax,%ebx
  800bf2:	89 c7                	mov    %eax,%edi
  800bf4:	89 c6                	mov    %eax,%esi
  800bf6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf8:	8b 1c 24             	mov    (%esp),%ebx
  800bfb:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bff:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c03:	89 ec                	mov    %ebp,%esp
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	89 1c 24             	mov    %ebx,(%esp)
  800c10:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c14:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c22:	89 d1                	mov    %edx,%ecx
  800c24:	89 d3                	mov    %edx,%ebx
  800c26:	89 d7                	mov    %edx,%edi
  800c28:	89 d6                	mov    %edx,%esi
  800c2a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c2c:	8b 1c 24             	mov    (%esp),%ebx
  800c2f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c33:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c37:	89 ec                	mov    %ebp,%esp
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	83 ec 38             	sub    $0x38,%esp
  800c41:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c44:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c47:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c4f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	89 cb                	mov    %ecx,%ebx
  800c59:	89 cf                	mov    %ecx,%edi
  800c5b:	89 ce                	mov    %ecx,%esi
  800c5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 28                	jle    800c8b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c67:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800c76:	00 
  800c77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7e:	00 
  800c7f:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800c86:	e8 6d 03 00 00       	call   800ff8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c8b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c8e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c91:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c94:	89 ec                	mov    %ebp,%esp
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	89 1c 24             	mov    %ebx,(%esp)
  800ca1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cae:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb3:	89 d1                	mov    %edx,%ecx
  800cb5:	89 d3                	mov    %edx,%ebx
  800cb7:	89 d7                	mov    %edx,%edi
  800cb9:	89 d6                	mov    %edx,%esi
  800cbb:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800cbd:	8b 1c 24             	mov    (%esp),%ebx
  800cc0:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cc4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cc8:	89 ec                	mov    %ebp,%esp
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_yield>:

void
sys_yield(void)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	89 1c 24             	mov    %ebx,(%esp)
  800cd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce7:	89 d1                	mov    %edx,%ecx
  800ce9:	89 d3                	mov    %edx,%ebx
  800ceb:	89 d7                	mov    %edx,%edi
  800ced:	89 d6                	mov    %edx,%esi
  800cef:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf1:	8b 1c 24             	mov    (%esp),%ebx
  800cf4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cf8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cfc:	89 ec                	mov    %ebp,%esp
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	83 ec 38             	sub    $0x38,%esp
  800d06:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d09:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d0c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	be 00 00 00 00       	mov    $0x0,%esi
  800d14:	b8 04 00 00 00       	mov    $0x4,%eax
  800d19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	89 f7                	mov    %esi,%edi
  800d24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 28                	jle    800d52 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d35:	00 
  800d36:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d45:	00 
  800d46:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800d4d:	e8 a6 02 00 00       	call   800ff8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d5b:	89 ec                	mov    %ebp,%esp
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	83 ec 38             	sub    $0x38,%esp
  800d65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d73:	8b 75 18             	mov    0x18(%ebp),%esi
  800d76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d84:	85 c0                	test   %eax,%eax
  800d86:	7e 28                	jle    800db0 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d93:	00 
  800d94:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800d9b:	00 
  800d9c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da3:	00 
  800da4:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800dab:	e8 48 02 00 00       	call   800ff8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800db0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db9:	89 ec                	mov    %ebp,%esp
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	83 ec 38             	sub    $0x38,%esp
  800dc3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dc9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd1:	b8 06 00 00 00       	mov    $0x6,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	89 df                	mov    %ebx,%edi
  800dde:	89 de                	mov    %ebx,%esi
  800de0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 28                	jle    800e0e <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dea:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800df1:	00 
  800df2:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e01:	00 
  800e02:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800e09:	e8 ea 01 00 00       	call   800ff8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e0e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e11:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e14:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e17:	89 ec                	mov    %ebp,%esp
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	83 ec 38             	sub    $0x38,%esp
  800e21:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e24:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e27:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2f:	b8 08 00 00 00       	mov    $0x8,%eax
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	89 df                	mov    %ebx,%edi
  800e3c:	89 de                	mov    %ebx,%esi
  800e3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e40:	85 c0                	test   %eax,%eax
  800e42:	7e 28                	jle    800e6c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e44:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e48:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e4f:	00 
  800e50:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800e57:	00 
  800e58:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5f:	00 
  800e60:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800e67:	e8 8c 01 00 00       	call   800ff8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e6c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e6f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e72:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e75:	89 ec                	mov    %ebp,%esp
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 38             	sub    $0x38,%esp
  800e7f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e82:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e85:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e95:	8b 55 08             	mov    0x8(%ebp),%edx
  800e98:	89 df                	mov    %ebx,%edi
  800e9a:	89 de                	mov    %ebx,%esi
  800e9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	7e 28                	jle    800eca <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea6:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ead:	00 
  800eae:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800eb5:	00 
  800eb6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebd:	00 
  800ebe:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800ec5:	e8 2e 01 00 00       	call   800ff8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ecd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed3:	89 ec                	mov    %ebp,%esp
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	83 ec 0c             	sub    $0xc,%esp
  800edd:	89 1c 24             	mov    %ebx,(%esp)
  800ee0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ee4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee8:	be 00 00 00 00       	mov    $0x0,%esi
  800eed:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ef2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f00:	8b 1c 24             	mov    (%esp),%ebx
  800f03:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f07:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f0b:	89 ec                	mov    %ebp,%esp
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    

00800f0f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	83 ec 38             	sub    $0x38,%esp
  800f15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f23:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f28:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2b:	89 cb                	mov    %ecx,%ebx
  800f2d:	89 cf                	mov    %ecx,%edi
  800f2f:	89 ce                	mov    %ecx,%esi
  800f31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f33:	85 c0                	test   %eax,%eax
  800f35:	7e 28                	jle    800f5f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f42:	00 
  800f43:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800f4a:	00 
  800f4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f52:	00 
  800f53:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800f5a:	e8 99 00 00 00       	call   800ff8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f68:	89 ec                	mov    %ebp,%esp
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800f72:	c7 44 24 08 6f 15 80 	movl   $0x80156f,0x8(%esp)
  800f79:	00 
  800f7a:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800f81:	00 
  800f82:	c7 04 24 88 15 80 00 	movl   $0x801588,(%esp)
  800f89:	e8 6a 00 00 00       	call   800ff8 <_panic>

00800f8e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800f94:	c7 44 24 08 92 15 80 	movl   $0x801592,0x8(%esp)
  800f9b:	00 
  800f9c:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800fa3:	00 
  800fa4:	c7 04 24 88 15 80 00 	movl   $0x801588,(%esp)
  800fab:	e8 48 00 00 00       	call   800ff8 <_panic>

00800fb0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  800fb6:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  800fbc:	74 17                	je     800fd5 <ipc_find_env+0x25>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800fbe:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  800fc3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800fc6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800fcc:	8b 52 50             	mov    0x50(%edx),%edx
  800fcf:	39 ca                	cmp    %ecx,%edx
  800fd1:	75 14                	jne    800fe7 <ipc_find_env+0x37>
  800fd3:	eb 05                	jmp    800fda <ipc_find_env+0x2a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800fd5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  800fda:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fdd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800fe2:	8b 40 40             	mov    0x40(%eax),%eax
  800fe5:	eb 0e                	jmp    800ff5 <ipc_find_env+0x45>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800fe7:	83 c0 01             	add    $0x1,%eax
  800fea:	3d 00 04 00 00       	cmp    $0x400,%eax
  800fef:	75 d2                	jne    800fc3 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800ff1:	66 b8 00 00          	mov    $0x0,%ax
}
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    
	...

00800ff8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
  800ffd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801000:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801003:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801009:	e8 8a fc ff ff       	call   800c98 <sys_getenvid>
  80100e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801011:	89 54 24 10          	mov    %edx,0x10(%esp)
  801015:	8b 55 08             	mov    0x8(%ebp),%edx
  801018:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80101c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801020:	89 44 24 04          	mov    %eax,0x4(%esp)
  801024:	c7 04 24 ac 15 80 00 	movl   $0x8015ac,(%esp)
  80102b:	e8 9b f1 ff ff       	call   8001cb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801030:	89 74 24 04          	mov    %esi,0x4(%esp)
  801034:	8b 45 10             	mov    0x10(%ebp),%eax
  801037:	89 04 24             	mov    %eax,(%esp)
  80103a:	e8 2b f1 ff ff       	call   80016a <vcprintf>
	cprintf("\n");
  80103f:	c7 04 24 cf 12 80 00 	movl   $0x8012cf,(%esp)
  801046:	e8 80 f1 ff ff       	call   8001cb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80104b:	cc                   	int3   
  80104c:	eb fd                	jmp    80104b <_panic+0x53>
	...

00801050 <__udivdi3>:
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	83 ec 10             	sub    $0x10,%esp
  801058:	8b 75 14             	mov    0x14(%ebp),%esi
  80105b:	8b 45 08             	mov    0x8(%ebp),%eax
  80105e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801061:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801064:	85 f6                	test   %esi,%esi
  801066:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801069:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80106c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80106f:	75 2f                	jne    8010a0 <__udivdi3+0x50>
  801071:	39 f9                	cmp    %edi,%ecx
  801073:	77 5b                	ja     8010d0 <__udivdi3+0x80>
  801075:	85 c9                	test   %ecx,%ecx
  801077:	75 0b                	jne    801084 <__udivdi3+0x34>
  801079:	b8 01 00 00 00       	mov    $0x1,%eax
  80107e:	31 d2                	xor    %edx,%edx
  801080:	f7 f1                	div    %ecx
  801082:	89 c1                	mov    %eax,%ecx
  801084:	89 f8                	mov    %edi,%eax
  801086:	31 d2                	xor    %edx,%edx
  801088:	f7 f1                	div    %ecx
  80108a:	89 c7                	mov    %eax,%edi
  80108c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108f:	f7 f1                	div    %ecx
  801091:	89 fa                	mov    %edi,%edx
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	5e                   	pop    %esi
  801097:	5f                   	pop    %edi
  801098:	5d                   	pop    %ebp
  801099:	c3                   	ret    
  80109a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010a0:	31 d2                	xor    %edx,%edx
  8010a2:	31 c0                	xor    %eax,%eax
  8010a4:	39 fe                	cmp    %edi,%esi
  8010a6:	77 eb                	ja     801093 <__udivdi3+0x43>
  8010a8:	0f bd d6             	bsr    %esi,%edx
  8010ab:	83 f2 1f             	xor    $0x1f,%edx
  8010ae:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010b1:	75 2d                	jne    8010e0 <__udivdi3+0x90>
  8010b3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  8010b6:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  8010b9:	76 06                	jbe    8010c1 <__udivdi3+0x71>
  8010bb:	39 fe                	cmp    %edi,%esi
  8010bd:	89 c2                	mov    %eax,%edx
  8010bf:	73 d2                	jae    801093 <__udivdi3+0x43>
  8010c1:	31 d2                	xor    %edx,%edx
  8010c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c8:	eb c9                	jmp    801093 <__udivdi3+0x43>
  8010ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010d0:	89 fa                	mov    %edi,%edx
  8010d2:	f7 f1                	div    %ecx
  8010d4:	31 d2                	xor    %edx,%edx
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    
  8010dd:	8d 76 00             	lea    0x0(%esi),%esi
  8010e0:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010e4:	b8 20 00 00 00       	mov    $0x20,%eax
  8010e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ec:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8010ef:	d3 e6                	shl    %cl,%esi
  8010f1:	89 c1                	mov    %eax,%ecx
  8010f3:	d3 ea                	shr    %cl,%edx
  8010f5:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010f9:	09 f2                	or     %esi,%edx
  8010fb:	8b 75 ec             	mov    -0x14(%ebp),%esi
  8010fe:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801101:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801104:	d3 e2                	shl    %cl,%edx
  801106:	89 c1                	mov    %eax,%ecx
  801108:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80110b:	89 fa                	mov    %edi,%edx
  80110d:	d3 ea                	shr    %cl,%edx
  80110f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801113:	d3 e7                	shl    %cl,%edi
  801115:	89 c1                	mov    %eax,%ecx
  801117:	d3 ee                	shr    %cl,%esi
  801119:	09 fe                	or     %edi,%esi
  80111b:	89 f0                	mov    %esi,%eax
  80111d:	f7 75 e8             	divl   -0x18(%ebp)
  801120:	89 d7                	mov    %edx,%edi
  801122:	89 c6                	mov    %eax,%esi
  801124:	f7 65 f0             	mull   -0x10(%ebp)
  801127:	39 d7                	cmp    %edx,%edi
  801129:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80112c:	72 22                	jb     801150 <__udivdi3+0x100>
  80112e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801131:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801135:	d3 e2                	shl    %cl,%edx
  801137:	39 c2                	cmp    %eax,%edx
  801139:	73 05                	jae    801140 <__udivdi3+0xf0>
  80113b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80113e:	74 10                	je     801150 <__udivdi3+0x100>
  801140:	89 f0                	mov    %esi,%eax
  801142:	31 d2                	xor    %edx,%edx
  801144:	e9 4a ff ff ff       	jmp    801093 <__udivdi3+0x43>
  801149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801150:	8d 46 ff             	lea    -0x1(%esi),%eax
  801153:	31 d2                	xor    %edx,%edx
  801155:	83 c4 10             	add    $0x10,%esp
  801158:	5e                   	pop    %esi
  801159:	5f                   	pop    %edi
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    
  80115c:	00 00                	add    %al,(%eax)
	...

00801160 <__umoddi3>:
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	57                   	push   %edi
  801164:	56                   	push   %esi
  801165:	83 ec 20             	sub    $0x20,%esp
  801168:	8b 7d 14             	mov    0x14(%ebp),%edi
  80116b:	8b 45 08             	mov    0x8(%ebp),%eax
  80116e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801171:	8b 75 0c             	mov    0xc(%ebp),%esi
  801174:	85 ff                	test   %edi,%edi
  801176:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801179:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80117c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80117f:	89 f2                	mov    %esi,%edx
  801181:	75 15                	jne    801198 <__umoddi3+0x38>
  801183:	39 f1                	cmp    %esi,%ecx
  801185:	76 41                	jbe    8011c8 <__umoddi3+0x68>
  801187:	f7 f1                	div    %ecx
  801189:	89 d0                	mov    %edx,%eax
  80118b:	31 d2                	xor    %edx,%edx
  80118d:	83 c4 20             	add    $0x20,%esp
  801190:	5e                   	pop    %esi
  801191:	5f                   	pop    %edi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    
  801194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801198:	39 f7                	cmp    %esi,%edi
  80119a:	77 4c                	ja     8011e8 <__umoddi3+0x88>
  80119c:	0f bd c7             	bsr    %edi,%eax
  80119f:	83 f0 1f             	xor    $0x1f,%eax
  8011a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011a5:	75 51                	jne    8011f8 <__umoddi3+0x98>
  8011a7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8011aa:	0f 87 e8 00 00 00    	ja     801298 <__umoddi3+0x138>
  8011b0:	89 f2                	mov    %esi,%edx
  8011b2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011b5:	29 ce                	sub    %ecx,%esi
  8011b7:	19 fa                	sbb    %edi,%edx
  8011b9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8011bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bf:	83 c4 20             	add    $0x20,%esp
  8011c2:	5e                   	pop    %esi
  8011c3:	5f                   	pop    %edi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    
  8011c6:	66 90                	xchg   %ax,%ax
  8011c8:	85 c9                	test   %ecx,%ecx
  8011ca:	75 0b                	jne    8011d7 <__umoddi3+0x77>
  8011cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d1:	31 d2                	xor    %edx,%edx
  8011d3:	f7 f1                	div    %ecx
  8011d5:	89 c1                	mov    %eax,%ecx
  8011d7:	89 f0                	mov    %esi,%eax
  8011d9:	31 d2                	xor    %edx,%edx
  8011db:	f7 f1                	div    %ecx
  8011dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e0:	eb a5                	jmp    801187 <__umoddi3+0x27>
  8011e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011e8:	89 f2                	mov    %esi,%edx
  8011ea:	83 c4 20             	add    $0x20,%esp
  8011ed:	5e                   	pop    %esi
  8011ee:	5f                   	pop    %edi
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    
  8011f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011f8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011fc:	89 f2                	mov    %esi,%edx
  8011fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801201:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801208:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80120b:	d3 e7                	shl    %cl,%edi
  80120d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801210:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801214:	d3 e8                	shr    %cl,%eax
  801216:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80121a:	09 f8                	or     %edi,%eax
  80121c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80121f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801222:	d3 e0                	shl    %cl,%eax
  801224:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801228:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80122b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80122e:	d3 ea                	shr    %cl,%edx
  801230:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801234:	d3 e6                	shl    %cl,%esi
  801236:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80123a:	d3 e8                	shr    %cl,%eax
  80123c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801240:	09 f0                	or     %esi,%eax
  801242:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801245:	f7 75 e4             	divl   -0x1c(%ebp)
  801248:	d3 e6                	shl    %cl,%esi
  80124a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80124d:	89 d6                	mov    %edx,%esi
  80124f:	f7 65 f4             	mull   -0xc(%ebp)
  801252:	89 d7                	mov    %edx,%edi
  801254:	89 c2                	mov    %eax,%edx
  801256:	39 fe                	cmp    %edi,%esi
  801258:	89 f9                	mov    %edi,%ecx
  80125a:	72 30                	jb     80128c <__umoddi3+0x12c>
  80125c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80125f:	72 27                	jb     801288 <__umoddi3+0x128>
  801261:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801264:	29 d0                	sub    %edx,%eax
  801266:	19 ce                	sbb    %ecx,%esi
  801268:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80126c:	89 f2                	mov    %esi,%edx
  80126e:	d3 e8                	shr    %cl,%eax
  801270:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801274:	d3 e2                	shl    %cl,%edx
  801276:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80127a:	09 d0                	or     %edx,%eax
  80127c:	89 f2                	mov    %esi,%edx
  80127e:	d3 ea                	shr    %cl,%edx
  801280:	83 c4 20             	add    $0x20,%esp
  801283:	5e                   	pop    %esi
  801284:	5f                   	pop    %edi
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    
  801287:	90                   	nop
  801288:	39 fe                	cmp    %edi,%esi
  80128a:	75 d5                	jne    801261 <__umoddi3+0x101>
  80128c:	89 f9                	mov    %edi,%ecx
  80128e:	89 c2                	mov    %eax,%edx
  801290:	2b 55 f4             	sub    -0xc(%ebp),%edx
  801293:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801296:	eb c9                	jmp    801261 <__umoddi3+0x101>
  801298:	39 f7                	cmp    %esi,%edi
  80129a:	0f 82 10 ff ff ff    	jb     8011b0 <__umoddi3+0x50>
  8012a0:	e9 17 ff ff ff       	jmp    8011bc <__umoddi3+0x5c>
