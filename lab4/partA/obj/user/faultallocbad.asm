
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 80 12 80 00 	movl   $0x801280,(%esp)
  80004b:	e8 f3 01 00 00       	call   800243 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 01 0d 00 00       	call   800d70 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 a0 12 80 	movl   $0x8012a0,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 8a 12 80 00 	movl   $0x80128a,(%esp)
  800092:	e8 b1 00 00 00       	call   800148 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 cc 12 80 	movl   $0x8012cc,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 40 07 00 00       	call   8007f3 <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 11 0f 00 00       	call   800fdc <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 65 0b 00 00       	call   800c44 <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
  8000ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  8000f6:	e8 0d 0c 00 00       	call   800d08 <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 f6                	test   %esi,%esi
  80010f:	7e 07                	jle    800118 <libmain+0x34>
		binaryname = argv[0];
  800111:	8b 03                	mov    (%ebx),%eax
  800113:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800118:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80011c:	89 34 24             	mov    %esi,(%esp)
  80011f:	e8 95 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800124:	e8 0b 00 00 00       	call   800134 <exit>
}
  800129:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80012c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80012f:	89 ec                	mov    %ebp,%esp
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    
	...

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80013a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800141:	e8 65 0b 00 00       	call   800cab <sys_env_destroy>
}
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800150:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800153:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800159:	e8 aa 0b 00 00       	call   800d08 <sys_getenvid>
  80015e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800161:	89 54 24 10          	mov    %edx,0x10(%esp)
  800165:	8b 55 08             	mov    0x8(%ebp),%edx
  800168:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80016c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800170:	89 44 24 04          	mov    %eax,0x4(%esp)
  800174:	c7 04 24 f8 12 80 00 	movl   $0x8012f8,(%esp)
  80017b:	e8 c3 00 00 00       	call   800243 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	89 74 24 04          	mov    %esi,0x4(%esp)
  800184:	8b 45 10             	mov    0x10(%ebp),%eax
  800187:	89 04 24             	mov    %eax,(%esp)
  80018a:	e8 53 00 00 00       	call   8001e2 <vcprintf>
	cprintf("\n");
  80018f:	c7 04 24 88 12 80 00 	movl   $0x801288,(%esp)
  800196:	e8 a8 00 00 00       	call   800243 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x53>
	...

008001a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 14             	sub    $0x14,%esp
  8001a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001aa:	8b 03                	mov    (%ebx),%eax
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b3:	83 c0 01             	add    $0x1,%eax
  8001b6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bd:	75 19                	jne    8001d8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001bf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c6:	00 
  8001c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ca:	89 04 24             	mov    %eax,(%esp)
  8001cd:	e8 72 0a 00 00       	call   800c44 <sys_cputs>
		b->idx = 0;
  8001d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001dc:	83 c4 14             	add    $0x14,%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5d                   	pop    %ebp
  8001e1:	c3                   	ret    

008001e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f2:	00 00 00 
	b.cnt = 0;
  8001f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800202:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800206:	8b 45 08             	mov    0x8(%ebp),%eax
  800209:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800213:	89 44 24 04          	mov    %eax,0x4(%esp)
  800217:	c7 04 24 a0 01 80 00 	movl   $0x8001a0,(%esp)
  80021e:	e8 de 01 00 00       	call   800401 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800223:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800233:	89 04 24             	mov    %eax,(%esp)
  800236:	e8 09 0a 00 00       	call   800c44 <sys_cputs>

	return b.cnt;
}
  80023b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800249:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800250:	8b 45 08             	mov    0x8(%ebp),%eax
  800253:	89 04 24             	mov    %eax,(%esp)
  800256:	e8 87 ff ff ff       	call   8001e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025b:	c9                   	leave  
  80025c:	c3                   	ret    
  80025d:	00 00                	add    %al,(%eax)
	...

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 4c             	sub    $0x4c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d6                	mov    %edx,%esi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800274:	8b 55 0c             	mov    0xc(%ebp),%edx
  800277:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80027d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800280:	b8 00 00 00 00       	mov    $0x0,%eax
  800285:	39 d0                	cmp    %edx,%eax
  800287:	72 11                	jb     80029a <printnum+0x3a>
  800289:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80028c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  80028f:	76 09                	jbe    80029a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800291:	83 eb 01             	sub    $0x1,%ebx
  800294:	85 db                	test   %ebx,%ebx
  800296:	7f 5d                	jg     8002f5 <printnum+0x95>
  800298:	eb 6c                	jmp    800306 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80029e:	83 eb 01             	sub    $0x1,%ebx
  8002a1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ac:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002b0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002b7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8002ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c1:	00 
  8002c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002c5:	89 14 24             	mov    %edx,(%esp)
  8002c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002cf:	e8 4c 0d 00 00       	call   801020 <__udivdi3>
  8002d4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002de:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002e2:	89 04 24             	mov    %eax,(%esp)
  8002e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e9:	89 f2                	mov    %esi,%edx
  8002eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ee:	e8 6d ff ff ff       	call   800260 <printnum>
  8002f3:	eb 11                	jmp    800306 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f9:	89 3c 24             	mov    %edi,(%esp)
  8002fc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ff:	83 eb 01             	sub    $0x1,%ebx
  800302:	85 db                	test   %ebx,%ebx
  800304:	7f ef                	jg     8002f5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800306:	89 74 24 04          	mov    %esi,0x4(%esp)
  80030a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80030e:	8b 45 10             	mov    0x10(%ebp),%eax
  800311:	89 44 24 08          	mov    %eax,0x8(%esp)
  800315:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031c:	00 
  80031d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800320:	89 14 24             	mov    %edx,(%esp)
  800323:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800326:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80032a:	e8 01 0e 00 00       	call   801130 <__umoddi3>
  80032f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800333:	0f be 80 1b 13 80 00 	movsbl 0x80131b(%eax),%eax
  80033a:	89 04 24             	mov    %eax,(%esp)
  80033d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800340:	83 c4 4c             	add    $0x4c,%esp
  800343:	5b                   	pop    %ebx
  800344:	5e                   	pop    %esi
  800345:	5f                   	pop    %edi
  800346:	5d                   	pop    %ebp
  800347:	c3                   	ret    

00800348 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034b:	83 fa 01             	cmp    $0x1,%edx
  80034e:	7e 0e                	jle    80035e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 08             	lea    0x8(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	8b 52 04             	mov    0x4(%edx),%edx
  80035c:	eb 22                	jmp    800380 <getuint+0x38>
	else if (lflag)
  80035e:	85 d2                	test   %edx,%edx
  800360:	74 10                	je     800372 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800362:	8b 10                	mov    (%eax),%edx
  800364:	8d 4a 04             	lea    0x4(%edx),%ecx
  800367:	89 08                	mov    %ecx,(%eax)
  800369:	8b 02                	mov    (%edx),%eax
  80036b:	ba 00 00 00 00       	mov    $0x0,%edx
  800370:	eb 0e                	jmp    800380 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800372:	8b 10                	mov    (%eax),%edx
  800374:	8d 4a 04             	lea    0x4(%edx),%ecx
  800377:	89 08                	mov    %ecx,(%eax)
  800379:	8b 02                	mov    (%edx),%eax
  80037b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800385:	83 fa 01             	cmp    $0x1,%edx
  800388:	7e 0e                	jle    800398 <getint+0x16>
		return va_arg(*ap, long long);
  80038a:	8b 10                	mov    (%eax),%edx
  80038c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038f:	89 08                	mov    %ecx,(%eax)
  800391:	8b 02                	mov    (%edx),%eax
  800393:	8b 52 04             	mov    0x4(%edx),%edx
  800396:	eb 22                	jmp    8003ba <getint+0x38>
	else if (lflag)
  800398:	85 d2                	test   %edx,%edx
  80039a:	74 10                	je     8003ac <getint+0x2a>
		return va_arg(*ap, long);
  80039c:	8b 10                	mov    (%eax),%edx
  80039e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a1:	89 08                	mov    %ecx,(%eax)
  8003a3:	8b 02                	mov    (%edx),%eax
  8003a5:	89 c2                	mov    %eax,%edx
  8003a7:	c1 fa 1f             	sar    $0x1f,%edx
  8003aa:	eb 0e                	jmp    8003ba <getint+0x38>
	else
		return va_arg(*ap, int);
  8003ac:	8b 10                	mov    (%eax),%edx
  8003ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b1:	89 08                	mov    %ecx,(%eax)
  8003b3:	8b 02                	mov    (%edx),%eax
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c6:	8b 10                	mov    (%eax),%edx
  8003c8:	3b 50 04             	cmp    0x4(%eax),%edx
  8003cb:	73 0a                	jae    8003d7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d0:	88 0a                	mov    %cl,(%edx)
  8003d2:	83 c2 01             	add    $0x1,%edx
  8003d5:	89 10                	mov    %edx,(%eax)
}
  8003d7:	5d                   	pop    %ebp
  8003d8:	c3                   	ret    

008003d9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d9:	55                   	push   %ebp
  8003da:	89 e5                	mov    %esp,%ebp
  8003dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003df:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f7:	89 04 24             	mov    %eax,(%esp)
  8003fa:	e8 02 00 00 00       	call   800401 <vprintfmt>
	va_end(ap);
}
  8003ff:	c9                   	leave  
  800400:	c3                   	ret    

00800401 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	57                   	push   %edi
  800405:	56                   	push   %esi
  800406:	53                   	push   %ebx
  800407:	83 ec 4c             	sub    $0x4c,%esp
  80040a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80040d:	eb 23                	jmp    800432 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80040f:	85 c0                	test   %eax,%eax
  800411:	75 12                	jne    800425 <vprintfmt+0x24>
				csa = 0x0700;
  800413:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80041a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80041d:	83 c4 4c             	add    $0x4c,%esp
  800420:	5b                   	pop    %ebx
  800421:	5e                   	pop    %esi
  800422:	5f                   	pop    %edi
  800423:	5d                   	pop    %ebp
  800424:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800425:	8b 55 0c             	mov    0xc(%ebp),%edx
  800428:	89 54 24 04          	mov    %edx,0x4(%esp)
  80042c:	89 04 24             	mov    %eax,(%esp)
  80042f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800432:	0f b6 07             	movzbl (%edi),%eax
  800435:	83 c7 01             	add    $0x1,%edi
  800438:	83 f8 25             	cmp    $0x25,%eax
  80043b:	75 d2                	jne    80040f <vprintfmt+0xe>
  80043d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800441:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800448:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80044d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800454:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800459:	be 00 00 00 00       	mov    $0x0,%esi
  80045e:	eb 14                	jmp    800474 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800460:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800464:	eb 0e                	jmp    800474 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800466:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80046a:	eb 08                	jmp    800474 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80046c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80046f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	0f b6 07             	movzbl (%edi),%eax
  800477:	0f b6 c8             	movzbl %al,%ecx
  80047a:	83 c7 01             	add    $0x1,%edi
  80047d:	83 e8 23             	sub    $0x23,%eax
  800480:	3c 55                	cmp    $0x55,%al
  800482:	0f 87 ed 02 00 00    	ja     800775 <vprintfmt+0x374>
  800488:	0f b6 c0             	movzbl %al,%eax
  80048b:	ff 24 85 e0 13 80 00 	jmp    *0x8013e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800492:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  800495:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800498:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80049b:	83 f9 09             	cmp    $0x9,%ecx
  80049e:	77 3c                	ja     8004dc <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004a3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8004a6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8004aa:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004ad:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004b0:	83 f9 09             	cmp    $0x9,%ecx
  8004b3:	76 eb                	jbe    8004a0 <vprintfmt+0x9f>
  8004b5:	eb 25                	jmp    8004dc <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8d 48 04             	lea    0x4(%eax),%ecx
  8004bd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004c0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  8004c2:	eb 18                	jmp    8004dc <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  8004c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004cb:	0f 48 c6             	cmovs  %esi,%eax
  8004ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004d1:	eb a1                	jmp    800474 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  8004d3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004da:	eb 98                	jmp    800474 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  8004dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e0:	79 92                	jns    800474 <vprintfmt+0x73>
  8004e2:	eb 88                	jmp    80046c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e4:	83 c2 01             	add    $0x1,%edx
  8004e7:	eb 8b                	jmp    800474 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8d 50 04             	lea    0x4(%eax),%edx
  8004ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004f9:	8b 00                	mov    (%eax),%eax
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	ff 55 08             	call   *0x8(%ebp)
			break;
  800501:	e9 2c ff ff ff       	jmp    800432 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 50 04             	lea    0x4(%eax),%edx
  80050c:	89 55 14             	mov    %edx,0x14(%ebp)
  80050f:	8b 00                	mov    (%eax),%eax
  800511:	89 c2                	mov    %eax,%edx
  800513:	c1 fa 1f             	sar    $0x1f,%edx
  800516:	31 d0                	xor    %edx,%eax
  800518:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051a:	83 f8 08             	cmp    $0x8,%eax
  80051d:	7f 0b                	jg     80052a <vprintfmt+0x129>
  80051f:	8b 14 85 40 15 80 00 	mov    0x801540(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 23                	jne    80054d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80052a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052e:	c7 44 24 08 33 13 80 	movl   $0x801333,0x8(%esp)
  800535:	00 
  800536:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800539:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053d:	8b 45 08             	mov    0x8(%ebp),%eax
  800540:	89 04 24             	mov    %eax,(%esp)
  800543:	e8 91 fe ff ff       	call   8003d9 <printfmt>
  800548:	e9 e5 fe ff ff       	jmp    800432 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80054d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800551:	c7 44 24 08 3c 13 80 	movl   $0x80133c,0x8(%esp)
  800558:	00 
  800559:	8b 55 0c             	mov    0xc(%ebp),%edx
  80055c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800560:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800563:	89 1c 24             	mov    %ebx,(%esp)
  800566:	e8 6e fe ff ff       	call   8003d9 <printfmt>
  80056b:	e9 c2 fe ff ff       	jmp    800432 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800573:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 50 04             	lea    0x4(%eax),%edx
  80057f:	89 55 14             	mov    %edx,0x14(%ebp)
  800582:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800584:	85 f6                	test   %esi,%esi
  800586:	ba 2c 13 80 00       	mov    $0x80132c,%edx
  80058b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80058e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800592:	7e 06                	jle    80059a <vprintfmt+0x199>
  800594:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800598:	75 13                	jne    8005ad <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059a:	0f be 06             	movsbl (%esi),%eax
  80059d:	83 c6 01             	add    $0x1,%esi
  8005a0:	85 c0                	test   %eax,%eax
  8005a2:	0f 85 a2 00 00 00    	jne    80064a <vprintfmt+0x249>
  8005a8:	e9 92 00 00 00       	jmp    80063f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b1:	89 34 24             	mov    %esi,(%esp)
  8005b4:	e8 82 02 00 00       	call   80083b <strnlen>
  8005b9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bc:	29 c2                	sub    %eax,%edx
  8005be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005c1:	85 d2                	test   %edx,%edx
  8005c3:	7e d5                	jle    80059a <vprintfmt+0x199>
					putch(padc, putdat);
  8005c5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8005c9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005cc:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005cf:	89 d3                	mov    %edx,%ebx
  8005d1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005d7:	89 c6                	mov    %eax,%esi
  8005d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005dd:	89 34 24             	mov    %esi,(%esp)
  8005e0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e3:	83 eb 01             	sub    $0x1,%ebx
  8005e6:	85 db                	test   %ebx,%ebx
  8005e8:	7f ef                	jg     8005d9 <vprintfmt+0x1d8>
  8005ea:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005ed:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005fa:	eb 9e                	jmp    80059a <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800600:	74 1b                	je     80061d <vprintfmt+0x21c>
  800602:	8d 50 e0             	lea    -0x20(%eax),%edx
  800605:	83 fa 5e             	cmp    $0x5e,%edx
  800608:	76 13                	jbe    80061d <vprintfmt+0x21c>
					putch('?', putdat);
  80060a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80060d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800611:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800618:	ff 55 08             	call   *0x8(%ebp)
  80061b:	eb 0d                	jmp    80062a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80061d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800620:	89 54 24 04          	mov    %edx,0x4(%esp)
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062a:	83 ef 01             	sub    $0x1,%edi
  80062d:	0f be 06             	movsbl (%esi),%eax
  800630:	85 c0                	test   %eax,%eax
  800632:	74 05                	je     800639 <vprintfmt+0x238>
  800634:	83 c6 01             	add    $0x1,%esi
  800637:	eb 17                	jmp    800650 <vprintfmt+0x24f>
  800639:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80063c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80063f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800643:	7f 1c                	jg     800661 <vprintfmt+0x260>
  800645:	e9 e8 fd ff ff       	jmp    800432 <vprintfmt+0x31>
  80064a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80064d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800650:	85 db                	test   %ebx,%ebx
  800652:	78 a8                	js     8005fc <vprintfmt+0x1fb>
  800654:	83 eb 01             	sub    $0x1,%ebx
  800657:	79 a3                	jns    8005fc <vprintfmt+0x1fb>
  800659:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80065c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80065f:	eb de                	jmp    80063f <vprintfmt+0x23e>
  800661:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800664:	8b 7d 08             	mov    0x8(%ebp),%edi
  800667:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80066a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80066e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800675:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800677:	83 eb 01             	sub    $0x1,%ebx
  80067a:	85 db                	test   %ebx,%ebx
  80067c:	7f ec                	jg     80066a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800681:	e9 ac fd ff ff       	jmp    800432 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
  800689:	e8 f4 fc ff ff       	call   800382 <getint>
  80068e:	89 c3                	mov    %eax,%ebx
  800690:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800692:	85 d2                	test   %edx,%edx
  800694:	78 0a                	js     8006a0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800696:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80069b:	e9 87 00 00 00       	jmp    800727 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ae:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006b1:	89 d8                	mov    %ebx,%eax
  8006b3:	89 f2                	mov    %esi,%edx
  8006b5:	f7 d8                	neg    %eax
  8006b7:	83 d2 00             	adc    $0x0,%edx
  8006ba:	f7 da                	neg    %edx
			}
			base = 10;
  8006bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006c1:	eb 64                	jmp    800727 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c6:	e8 7d fc ff ff       	call   800348 <getuint>
			base = 10;
  8006cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006d0:	eb 55                	jmp    800727 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8006d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d5:	e8 6e fc ff ff       	call   800348 <getuint>
      base = 8;
  8006da:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8006df:	eb 46                	jmp    800727 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006e4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006ef:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f9:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800700:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8d 50 04             	lea    0x4(%eax),%edx
  800709:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80070c:	8b 00                	mov    (%eax),%eax
  80070e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800713:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800718:	eb 0d                	jmp    800727 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80071a:	8d 45 14             	lea    0x14(%ebp),%eax
  80071d:	e8 26 fc ff ff       	call   800348 <getuint>
			base = 16;
  800722:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800727:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80072b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80072f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800732:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800736:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80073a:	89 04 24             	mov    %eax,(%esp)
  80073d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800741:	8b 55 0c             	mov    0xc(%ebp),%edx
  800744:	8b 45 08             	mov    0x8(%ebp),%eax
  800747:	e8 14 fb ff ff       	call   800260 <printnum>
			break;
  80074c:	e9 e1 fc ff ff       	jmp    800432 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800751:	8b 45 0c             	mov    0xc(%ebp),%eax
  800754:	89 44 24 04          	mov    %eax,0x4(%esp)
  800758:	89 0c 24             	mov    %ecx,(%esp)
  80075b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80075e:	e9 cf fc ff ff       	jmp    800432 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800763:	8d 45 14             	lea    0x14(%ebp),%eax
  800766:	e8 17 fc ff ff       	call   800382 <getint>
			csa = num;
  80076b:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  800770:	e9 bd fc ff ff       	jmp    800432 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800775:	8b 55 0c             	mov    0xc(%ebp),%edx
  800778:	89 54 24 04          	mov    %edx,0x4(%esp)
  80077c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800783:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800786:	83 ef 01             	sub    $0x1,%edi
  800789:	eb 02                	jmp    80078d <vprintfmt+0x38c>
  80078b:	89 c7                	mov    %eax,%edi
  80078d:	8d 47 ff             	lea    -0x1(%edi),%eax
  800790:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800794:	75 f5                	jne    80078b <vprintfmt+0x38a>
  800796:	e9 97 fc ff ff       	jmp    800432 <vprintfmt+0x31>

0080079b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	83 ec 28             	sub    $0x28,%esp
  8007a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b8:	85 c0                	test   %eax,%eax
  8007ba:	74 30                	je     8007ec <vsnprintf+0x51>
  8007bc:	85 d2                	test   %edx,%edx
  8007be:	7e 2c                	jle    8007ec <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d5:	c7 04 24 bc 03 80 00 	movl   $0x8003bc,(%esp)
  8007dc:	e8 20 fc ff ff       	call   800401 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ea:	eb 05                	jmp    8007f1 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007f1:	c9                   	leave  
  8007f2:	c3                   	ret    

008007f3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800800:	8b 45 10             	mov    0x10(%ebp),%eax
  800803:	89 44 24 08          	mov    %eax,0x8(%esp)
  800807:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	89 04 24             	mov    %eax,(%esp)
  800814:	e8 82 ff ff ff       	call   80079b <vsnprintf>
	va_end(ap);

	return rc;
}
  800819:	c9                   	leave  
  80081a:	c3                   	ret    
  80081b:	00 00                	add    %al,(%eax)
  80081d:	00 00                	add    %al,(%eax)
	...

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	80 3a 00             	cmpb   $0x0,(%edx)
  80082e:	74 09                	je     800839 <strlen+0x19>
		n++;
  800830:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800833:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800837:	75 f7                	jne    800830 <strlen+0x10>
		n++;
	return n;
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800841:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800844:	b8 00 00 00 00       	mov    $0x0,%eax
  800849:	85 d2                	test   %edx,%edx
  80084b:	74 12                	je     80085f <strnlen+0x24>
  80084d:	80 39 00             	cmpb   $0x0,(%ecx)
  800850:	74 0d                	je     80085f <strnlen+0x24>
		n++;
  800852:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800855:	39 d0                	cmp    %edx,%eax
  800857:	74 06                	je     80085f <strnlen+0x24>
  800859:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80085d:	75 f3                	jne    800852 <strnlen+0x17>
		n++;
	return n;
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80086b:	ba 00 00 00 00       	mov    $0x0,%edx
  800870:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800874:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800877:	83 c2 01             	add    $0x1,%edx
  80087a:	84 c9                	test   %cl,%cl
  80087c:	75 f2                	jne    800870 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80087e:	5b                   	pop    %ebx
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	53                   	push   %ebx
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088b:	89 1c 24             	mov    %ebx,(%esp)
  80088e:	e8 8d ff ff ff       	call   800820 <strlen>
	strcpy(dst + len, src);
  800893:	8b 55 0c             	mov    0xc(%ebp),%edx
  800896:	89 54 24 04          	mov    %edx,0x4(%esp)
  80089a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80089d:	89 04 24             	mov    %eax,(%esp)
  8008a0:	e8 bc ff ff ff       	call   800861 <strcpy>
	return dst;
}
  8008a5:	89 d8                	mov    %ebx,%eax
  8008a7:	83 c4 08             	add    $0x8,%esp
  8008aa:	5b                   	pop    %ebx
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	56                   	push   %esi
  8008b1:	53                   	push   %ebx
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008bb:	85 f6                	test   %esi,%esi
  8008bd:	74 18                	je     8008d7 <strncpy+0x2a>
  8008bf:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008c4:	0f b6 1a             	movzbl (%edx),%ebx
  8008c7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ca:	80 3a 01             	cmpb   $0x1,(%edx)
  8008cd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d0:	83 c1 01             	add    $0x1,%ecx
  8008d3:	39 ce                	cmp    %ecx,%esi
  8008d5:	77 ed                	ja     8008c4 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d7:	5b                   	pop    %ebx
  8008d8:	5e                   	pop    %esi
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e9:	89 f0                	mov    %esi,%eax
  8008eb:	85 c9                	test   %ecx,%ecx
  8008ed:	74 23                	je     800912 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  8008ef:	83 e9 01             	sub    $0x1,%ecx
  8008f2:	74 1b                	je     80090f <strlcpy+0x34>
  8008f4:	0f b6 1a             	movzbl (%edx),%ebx
  8008f7:	84 db                	test   %bl,%bl
  8008f9:	74 14                	je     80090f <strlcpy+0x34>
			*dst++ = *src++;
  8008fb:	88 18                	mov    %bl,(%eax)
  8008fd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800900:	83 e9 01             	sub    $0x1,%ecx
  800903:	74 0a                	je     80090f <strlcpy+0x34>
			*dst++ = *src++;
  800905:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800908:	0f b6 1a             	movzbl (%edx),%ebx
  80090b:	84 db                	test   %bl,%bl
  80090d:	75 ec                	jne    8008fb <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80090f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800912:	29 f0                	sub    %esi,%eax
}
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800921:	0f b6 01             	movzbl (%ecx),%eax
  800924:	84 c0                	test   %al,%al
  800926:	74 15                	je     80093d <strcmp+0x25>
  800928:	3a 02                	cmp    (%edx),%al
  80092a:	75 11                	jne    80093d <strcmp+0x25>
		p++, q++;
  80092c:	83 c1 01             	add    $0x1,%ecx
  80092f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800932:	0f b6 01             	movzbl (%ecx),%eax
  800935:	84 c0                	test   %al,%al
  800937:	74 04                	je     80093d <strcmp+0x25>
  800939:	3a 02                	cmp    (%edx),%al
  80093b:	74 ef                	je     80092c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093d:	0f b6 c0             	movzbl %al,%eax
  800940:	0f b6 12             	movzbl (%edx),%edx
  800943:	29 d0                	sub    %edx,%eax
}
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	53                   	push   %ebx
  80094b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800951:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800959:	85 d2                	test   %edx,%edx
  80095b:	74 28                	je     800985 <strncmp+0x3e>
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	84 c0                	test   %al,%al
  800962:	74 24                	je     800988 <strncmp+0x41>
  800964:	3a 03                	cmp    (%ebx),%al
  800966:	75 20                	jne    800988 <strncmp+0x41>
  800968:	83 ea 01             	sub    $0x1,%edx
  80096b:	74 13                	je     800980 <strncmp+0x39>
		n--, p++, q++;
  80096d:	83 c1 01             	add    $0x1,%ecx
  800970:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800973:	0f b6 01             	movzbl (%ecx),%eax
  800976:	84 c0                	test   %al,%al
  800978:	74 0e                	je     800988 <strncmp+0x41>
  80097a:	3a 03                	cmp    (%ebx),%al
  80097c:	74 ea                	je     800968 <strncmp+0x21>
  80097e:	eb 08                	jmp    800988 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800980:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800985:	5b                   	pop    %ebx
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800988:	0f b6 01             	movzbl (%ecx),%eax
  80098b:	0f b6 13             	movzbl (%ebx),%edx
  80098e:	29 d0                	sub    %edx,%eax
  800990:	eb f3                	jmp    800985 <strncmp+0x3e>

00800992 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099c:	0f b6 10             	movzbl (%eax),%edx
  80099f:	84 d2                	test   %dl,%dl
  8009a1:	74 20                	je     8009c3 <strchr+0x31>
		if (*s == c)
  8009a3:	38 ca                	cmp    %cl,%dl
  8009a5:	75 0b                	jne    8009b2 <strchr+0x20>
  8009a7:	eb 1f                	jmp    8009c8 <strchr+0x36>
  8009a9:	38 ca                	cmp    %cl,%dl
  8009ab:	90                   	nop
  8009ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009b0:	74 16                	je     8009c8 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	75 ed                	jne    8009a9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c1:	eb 05                	jmp    8009c8 <strchr+0x36>
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d4:	0f b6 10             	movzbl (%eax),%edx
  8009d7:	84 d2                	test   %dl,%dl
  8009d9:	74 14                	je     8009ef <strfind+0x25>
		if (*s == c)
  8009db:	38 ca                	cmp    %cl,%dl
  8009dd:	75 06                	jne    8009e5 <strfind+0x1b>
  8009df:	eb 0e                	jmp    8009ef <strfind+0x25>
  8009e1:	38 ca                	cmp    %cl,%dl
  8009e3:	74 0a                	je     8009ef <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009e5:	83 c0 01             	add    $0x1,%eax
  8009e8:	0f b6 10             	movzbl (%eax),%edx
  8009eb:	84 d2                	test   %dl,%dl
  8009ed:	75 f2                	jne    8009e1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	83 ec 0c             	sub    $0xc,%esp
  8009f7:	89 1c 24             	mov    %ebx,(%esp)
  8009fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a02:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a0b:	85 c9                	test   %ecx,%ecx
  800a0d:	74 30                	je     800a3f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a15:	75 25                	jne    800a3c <memset+0x4b>
  800a17:	f6 c1 03             	test   $0x3,%cl
  800a1a:	75 20                	jne    800a3c <memset+0x4b>
		c &= 0xFF;
  800a1c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1f:	89 d3                	mov    %edx,%ebx
  800a21:	c1 e3 08             	shl    $0x8,%ebx
  800a24:	89 d6                	mov    %edx,%esi
  800a26:	c1 e6 18             	shl    $0x18,%esi
  800a29:	89 d0                	mov    %edx,%eax
  800a2b:	c1 e0 10             	shl    $0x10,%eax
  800a2e:	09 f0                	or     %esi,%eax
  800a30:	09 d0                	or     %edx,%eax
  800a32:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a34:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a37:	fc                   	cld    
  800a38:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3a:	eb 03                	jmp    800a3f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3c:	fc                   	cld    
  800a3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3f:	89 f8                	mov    %edi,%eax
  800a41:	8b 1c 24             	mov    (%esp),%ebx
  800a44:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a48:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a4c:	89 ec                	mov    %ebp,%esp
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	83 ec 08             	sub    $0x8,%esp
  800a56:	89 34 24             	mov    %esi,(%esp)
  800a59:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a63:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a66:	39 c6                	cmp    %eax,%esi
  800a68:	73 36                	jae    800aa0 <memmove+0x50>
  800a6a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a6d:	39 d0                	cmp    %edx,%eax
  800a6f:	73 2f                	jae    800aa0 <memmove+0x50>
		s += n;
		d += n;
  800a71:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a74:	f6 c2 03             	test   $0x3,%dl
  800a77:	75 1b                	jne    800a94 <memmove+0x44>
  800a79:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7f:	75 13                	jne    800a94 <memmove+0x44>
  800a81:	f6 c1 03             	test   $0x3,%cl
  800a84:	75 0e                	jne    800a94 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a86:	83 ef 04             	sub    $0x4,%edi
  800a89:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a8c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a8f:	fd                   	std    
  800a90:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a92:	eb 09                	jmp    800a9d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a94:	83 ef 01             	sub    $0x1,%edi
  800a97:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a9a:	fd                   	std    
  800a9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a9d:	fc                   	cld    
  800a9e:	eb 20                	jmp    800ac0 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa6:	75 13                	jne    800abb <memmove+0x6b>
  800aa8:	a8 03                	test   $0x3,%al
  800aaa:	75 0f                	jne    800abb <memmove+0x6b>
  800aac:	f6 c1 03             	test   $0x3,%cl
  800aaf:	75 0a                	jne    800abb <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ab1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ab4:	89 c7                	mov    %eax,%edi
  800ab6:	fc                   	cld    
  800ab7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab9:	eb 05                	jmp    800ac0 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800abb:	89 c7                	mov    %eax,%edi
  800abd:	fc                   	cld    
  800abe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac0:	8b 34 24             	mov    (%esp),%esi
  800ac3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ac7:	89 ec                	mov    %ebp,%esp
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	89 04 24             	mov    %eax,(%esp)
  800ae5:	e8 66 ff ff ff       	call   800a50 <memmove>
}
  800aea:	c9                   	leave  
  800aeb:	c3                   	ret    

00800aec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800af5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af8:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afb:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b00:	85 ff                	test   %edi,%edi
  800b02:	74 38                	je     800b3c <memcmp+0x50>
		if (*s1 != *s2)
  800b04:	0f b6 03             	movzbl (%ebx),%eax
  800b07:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0a:	83 ef 01             	sub    $0x1,%edi
  800b0d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b12:	38 c8                	cmp    %cl,%al
  800b14:	74 1d                	je     800b33 <memcmp+0x47>
  800b16:	eb 11                	jmp    800b29 <memcmp+0x3d>
  800b18:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b1d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800b22:	83 c2 01             	add    $0x1,%edx
  800b25:	38 c8                	cmp    %cl,%al
  800b27:	74 0a                	je     800b33 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800b29:	0f b6 c0             	movzbl %al,%eax
  800b2c:	0f b6 c9             	movzbl %cl,%ecx
  800b2f:	29 c8                	sub    %ecx,%eax
  800b31:	eb 09                	jmp    800b3c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b33:	39 fa                	cmp    %edi,%edx
  800b35:	75 e1                	jne    800b18 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b47:	89 c2                	mov    %eax,%edx
  800b49:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b4c:	39 d0                	cmp    %edx,%eax
  800b4e:	73 15                	jae    800b65 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b54:	38 08                	cmp    %cl,(%eax)
  800b56:	75 06                	jne    800b5e <memfind+0x1d>
  800b58:	eb 0b                	jmp    800b65 <memfind+0x24>
  800b5a:	38 08                	cmp    %cl,(%eax)
  800b5c:	74 07                	je     800b65 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b5e:	83 c0 01             	add    $0x1,%eax
  800b61:	39 c2                	cmp    %eax,%edx
  800b63:	77 f5                	ja     800b5a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b73:	0f b6 02             	movzbl (%edx),%eax
  800b76:	3c 20                	cmp    $0x20,%al
  800b78:	74 04                	je     800b7e <strtol+0x17>
  800b7a:	3c 09                	cmp    $0x9,%al
  800b7c:	75 0e                	jne    800b8c <strtol+0x25>
		s++;
  800b7e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b81:	0f b6 02             	movzbl (%edx),%eax
  800b84:	3c 20                	cmp    $0x20,%al
  800b86:	74 f6                	je     800b7e <strtol+0x17>
  800b88:	3c 09                	cmp    $0x9,%al
  800b8a:	74 f2                	je     800b7e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b8c:	3c 2b                	cmp    $0x2b,%al
  800b8e:	75 0a                	jne    800b9a <strtol+0x33>
		s++;
  800b90:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b93:	bf 00 00 00 00       	mov    $0x0,%edi
  800b98:	eb 10                	jmp    800baa <strtol+0x43>
  800b9a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b9f:	3c 2d                	cmp    $0x2d,%al
  800ba1:	75 07                	jne    800baa <strtol+0x43>
		s++, neg = 1;
  800ba3:	83 c2 01             	add    $0x1,%edx
  800ba6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800baa:	85 db                	test   %ebx,%ebx
  800bac:	0f 94 c0             	sete   %al
  800baf:	74 05                	je     800bb6 <strtol+0x4f>
  800bb1:	83 fb 10             	cmp    $0x10,%ebx
  800bb4:	75 15                	jne    800bcb <strtol+0x64>
  800bb6:	80 3a 30             	cmpb   $0x30,(%edx)
  800bb9:	75 10                	jne    800bcb <strtol+0x64>
  800bbb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bbf:	75 0a                	jne    800bcb <strtol+0x64>
		s += 2, base = 16;
  800bc1:	83 c2 02             	add    $0x2,%edx
  800bc4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc9:	eb 13                	jmp    800bde <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800bcb:	84 c0                	test   %al,%al
  800bcd:	74 0f                	je     800bde <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bcf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bd7:	75 05                	jne    800bde <strtol+0x77>
		s++, base = 8;
  800bd9:	83 c2 01             	add    $0x1,%edx
  800bdc:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800bde:	b8 00 00 00 00       	mov    $0x0,%eax
  800be3:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be5:	0f b6 0a             	movzbl (%edx),%ecx
  800be8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800beb:	80 fb 09             	cmp    $0x9,%bl
  800bee:	77 08                	ja     800bf8 <strtol+0x91>
			dig = *s - '0';
  800bf0:	0f be c9             	movsbl %cl,%ecx
  800bf3:	83 e9 30             	sub    $0x30,%ecx
  800bf6:	eb 1e                	jmp    800c16 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800bf8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bfb:	80 fb 19             	cmp    $0x19,%bl
  800bfe:	77 08                	ja     800c08 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c00:	0f be c9             	movsbl %cl,%ecx
  800c03:	83 e9 57             	sub    $0x57,%ecx
  800c06:	eb 0e                	jmp    800c16 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c08:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c0b:	80 fb 19             	cmp    $0x19,%bl
  800c0e:	77 15                	ja     800c25 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800c10:	0f be c9             	movsbl %cl,%ecx
  800c13:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c16:	39 f1                	cmp    %esi,%ecx
  800c18:	7d 0f                	jge    800c29 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800c1a:	83 c2 01             	add    $0x1,%edx
  800c1d:	0f af c6             	imul   %esi,%eax
  800c20:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c23:	eb c0                	jmp    800be5 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c25:	89 c1                	mov    %eax,%ecx
  800c27:	eb 02                	jmp    800c2b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c29:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c2b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c2f:	74 05                	je     800c36 <strtol+0xcf>
		*endptr = (char *) s;
  800c31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c34:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c36:	89 ca                	mov    %ecx,%edx
  800c38:	f7 da                	neg    %edx
  800c3a:	85 ff                	test   %edi,%edi
  800c3c:	0f 45 c2             	cmovne %edx,%eax
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	83 ec 0c             	sub    $0xc,%esp
  800c4a:	89 1c 24             	mov    %ebx,(%esp)
  800c4d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c51:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	89 c3                	mov    %eax,%ebx
  800c62:	89 c7                	mov    %eax,%edi
  800c64:	89 c6                	mov    %eax,%esi
  800c66:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c68:	8b 1c 24             	mov    (%esp),%ebx
  800c6b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c6f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c73:	89 ec                	mov    %ebp,%esp
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	89 1c 24             	mov    %ebx,(%esp)
  800c80:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c84:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c92:	89 d1                	mov    %edx,%ecx
  800c94:	89 d3                	mov    %edx,%ebx
  800c96:	89 d7                	mov    %edx,%edi
  800c98:	89 d6                	mov    %edx,%esi
  800c9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c9c:	8b 1c 24             	mov    (%esp),%ebx
  800c9f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ca3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ca7:	89 ec                	mov    %ebp,%esp
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	83 ec 38             	sub    $0x38,%esp
  800cb1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cb4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cb7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbf:	b8 03 00 00 00       	mov    $0x3,%eax
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	89 cb                	mov    %ecx,%ebx
  800cc9:	89 cf                	mov    %ecx,%edi
  800ccb:	89 ce                	mov    %ecx,%esi
  800ccd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	7e 28                	jle    800cfb <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cde:	00 
  800cdf:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800ce6:	00 
  800ce7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cee:	00 
  800cef:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800cf6:	e8 4d f4 ff ff       	call   800148 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cfb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cfe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d01:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d04:	89 ec                	mov    %ebp,%esp
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	89 1c 24             	mov    %ebx,(%esp)
  800d11:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d15:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d23:	89 d1                	mov    %edx,%ecx
  800d25:	89 d3                	mov    %edx,%ebx
  800d27:	89 d7                	mov    %edx,%edi
  800d29:	89 d6                	mov    %edx,%esi
  800d2b:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800d2d:	8b 1c 24             	mov    (%esp),%ebx
  800d30:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d34:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d38:	89 ec                	mov    %ebp,%esp
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_yield>:

void
sys_yield(void)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	89 1c 24             	mov    %ebx,(%esp)
  800d45:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d49:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d52:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d57:	89 d1                	mov    %edx,%ecx
  800d59:	89 d3                	mov    %edx,%ebx
  800d5b:	89 d7                	mov    %edx,%edi
  800d5d:	89 d6                	mov    %edx,%esi
  800d5f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d61:	8b 1c 24             	mov    (%esp),%ebx
  800d64:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d68:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d6c:	89 ec                	mov    %ebp,%esp
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	83 ec 38             	sub    $0x38,%esp
  800d76:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d79:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d7c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7f:	be 00 00 00 00       	mov    $0x0,%esi
  800d84:	b8 04 00 00 00       	mov    $0x4,%eax
  800d89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	89 f7                	mov    %esi,%edi
  800d94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d96:	85 c0                	test   %eax,%eax
  800d98:	7e 28                	jle    800dc2 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800da5:	00 
  800da6:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800dad:	00 
  800dae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db5:	00 
  800db6:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800dbd:	e8 86 f3 ff ff       	call   800148 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dc2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dc8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dcb:	89 ec                	mov    %ebp,%esp
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	83 ec 38             	sub    $0x38,%esp
  800dd5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ddb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dde:	b8 05 00 00 00       	mov    $0x5,%eax
  800de3:	8b 75 18             	mov    0x18(%ebp),%esi
  800de6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800def:	8b 55 08             	mov    0x8(%ebp),%edx
  800df2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df4:	85 c0                	test   %eax,%eax
  800df6:	7e 28                	jle    800e20 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e03:	00 
  800e04:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800e0b:	00 
  800e0c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e13:	00 
  800e14:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800e1b:	e8 28 f3 ff ff       	call   800148 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e20:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e23:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e26:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e29:	89 ec                	mov    %ebp,%esp
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	83 ec 38             	sub    $0x38,%esp
  800e33:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e36:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e39:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e41:	b8 06 00 00 00       	mov    $0x6,%eax
  800e46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	89 df                	mov    %ebx,%edi
  800e4e:	89 de                	mov    %ebx,%esi
  800e50:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e52:	85 c0                	test   %eax,%eax
  800e54:	7e 28                	jle    800e7e <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e56:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e61:	00 
  800e62:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800e69:	00 
  800e6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e71:	00 
  800e72:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800e79:	e8 ca f2 ff ff       	call   800148 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e7e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e81:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e84:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e87:	89 ec                	mov    %ebp,%esp
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 38             	sub    $0x38,%esp
  800e91:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e94:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e97:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9f:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaa:	89 df                	mov    %ebx,%edi
  800eac:	89 de                	mov    %ebx,%esi
  800eae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	7e 28                	jle    800edc <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb8:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ebf:	00 
  800ec0:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800ec7:	00 
  800ec8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecf:	00 
  800ed0:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800ed7:	e8 6c f2 ff ff       	call   800148 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800edc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800edf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee5:	89 ec                	mov    %ebp,%esp
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	83 ec 38             	sub    $0x38,%esp
  800eef:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efd:	b8 09 00 00 00       	mov    $0x9,%eax
  800f02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f05:	8b 55 08             	mov    0x8(%ebp),%edx
  800f08:	89 df                	mov    %ebx,%edi
  800f0a:	89 de                	mov    %ebx,%esi
  800f0c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	7e 28                	jle    800f3a <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f12:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f16:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f1d:	00 
  800f1e:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800f25:	00 
  800f26:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2d:	00 
  800f2e:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800f35:	e8 0e f2 ff ff       	call   800148 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f3a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f3d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f40:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f43:	89 ec                	mov    %ebp,%esp
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	89 1c 24             	mov    %ebx,(%esp)
  800f50:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f54:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f58:	be 00 00 00 00       	mov    $0x0,%esi
  800f5d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f70:	8b 1c 24             	mov    (%esp),%ebx
  800f73:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f77:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f7b:	89 ec                	mov    %ebp,%esp
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    

00800f7f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 38             	sub    $0x38,%esp
  800f85:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f88:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f8b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f93:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f98:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9b:	89 cb                	mov    %ecx,%ebx
  800f9d:	89 cf                	mov    %ecx,%edi
  800f9f:	89 ce                	mov    %ecx,%esi
  800fa1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	7e 28                	jle    800fcf <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fab:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800fb2:	00 
  800fb3:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800fba:	00 
  800fbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc2:	00 
  800fc3:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800fca:	e8 79 f1 ff ff       	call   800148 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fcf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd8:	89 ec                	mov    %ebp,%esp
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fe2:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800fe9:	75 1c                	jne    801007 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800feb:	c7 44 24 08 90 15 80 	movl   $0x801590,0x8(%esp)
  800ff2:	00 
  800ff3:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800ffa:	00 
  800ffb:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  801002:	e8 41 f1 ff ff       	call   800148 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801007:	8b 45 08             	mov    0x8(%ebp),%eax
  80100a:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80100f:	c9                   	leave  
  801010:	c3                   	ret    
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
