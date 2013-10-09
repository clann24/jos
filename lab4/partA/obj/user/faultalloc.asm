
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800044:	c7 04 24 a0 12 80 00 	movl   $0x8012a0,(%esp)
  80004b:	e8 07 02 00 00       	call   800257 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 21 0d 00 00       	call   800d90 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 c0 12 80 	movl   $0x8012c0,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 aa 12 80 00 	movl   $0x8012aa,(%esp)
  800092:	e8 c5 00 00 00       	call   80015c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 ec 12 80 	movl   $0x8012ec,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 60 07 00 00       	call   800813 <snprintf>
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
  8000c6:	e8 31 0f 00 00       	call   800ffc <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 bc 12 80 00 	movl   $0x8012bc,(%esp)
  8000da:	e8 78 01 00 00       	call   800257 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 bc 12 80 00 	movl   $0x8012bc,(%esp)
  8000ee:	e8 64 01 00 00       	call   800257 <cprintf>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80010a:	e8 19 0c 00 00       	call   800d28 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	89 34 24             	mov    %esi,(%esp)
  800133:	e8 81 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
}
  80013d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800140:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 71 0b 00 00       	call   800ccb <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800164:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800167:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80016d:	e8 b6 0b 00 00       	call   800d28 <sys_getenvid>
  800172:	8b 55 0c             	mov    0xc(%ebp),%edx
  800175:	89 54 24 10          	mov    %edx,0x10(%esp)
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800180:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800184:	89 44 24 04          	mov    %eax,0x4(%esp)
  800188:	c7 04 24 18 13 80 00 	movl   $0x801318,(%esp)
  80018f:	e8 c3 00 00 00       	call   800257 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800194:	89 74 24 04          	mov    %esi,0x4(%esp)
  800198:	8b 45 10             	mov    0x10(%ebp),%eax
  80019b:	89 04 24             	mov    %eax,(%esp)
  80019e:	e8 53 00 00 00       	call   8001f6 <vcprintf>
	cprintf("\n");
  8001a3:	c7 04 24 be 12 80 00 	movl   $0x8012be,(%esp)
  8001aa:	e8 a8 00 00 00       	call   800257 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001af:	cc                   	int3   
  8001b0:	eb fd                	jmp    8001af <_panic+0x53>
	...

008001b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 14             	sub    $0x14,%esp
  8001bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001be:	8b 03                	mov    (%ebx),%eax
  8001c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c7:	83 c0 01             	add    $0x1,%eax
  8001ca:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001cc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d1:	75 19                	jne    8001ec <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001d3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001da:	00 
  8001db:	8d 43 08             	lea    0x8(%ebx),%eax
  8001de:	89 04 24             	mov    %eax,(%esp)
  8001e1:	e8 7e 0a 00 00       	call   800c64 <sys_cputs>
		b->idx = 0;
  8001e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ec:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f0:	83 c4 14             	add    $0x14,%esp
  8001f3:	5b                   	pop    %ebx
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ff:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800206:	00 00 00 
	b.cnt = 0;
  800209:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800210:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800213:	8b 45 0c             	mov    0xc(%ebp),%eax
  800216:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800221:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022b:	c7 04 24 b4 01 80 00 	movl   $0x8001b4,(%esp)
  800232:	e8 ea 01 00 00       	call   800421 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800237:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80023d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800241:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800247:	89 04 24             	mov    %eax,(%esp)
  80024a:	e8 15 0a 00 00       	call   800c64 <sys_cputs>

	return b.cnt;
}
  80024f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800260:	89 44 24 04          	mov    %eax,0x4(%esp)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	e8 87 ff ff ff       	call   8001f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80026f:	c9                   	leave  
  800270:	c3                   	ret    
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 4c             	sub    $0x4c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800294:	8b 55 0c             	mov    0xc(%ebp),%edx
  800297:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80029a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80029d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002a5:	39 d0                	cmp    %edx,%eax
  8002a7:	72 11                	jb     8002ba <printnum+0x3a>
  8002a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ac:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8002af:	76 09                	jbe    8002ba <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b1:	83 eb 01             	sub    $0x1,%ebx
  8002b4:	85 db                	test   %ebx,%ebx
  8002b6:	7f 5d                	jg     800315 <printnum+0x95>
  8002b8:	eb 6c                	jmp    800326 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ba:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002be:	83 eb 01             	sub    $0x1,%ebx
  8002c1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002cc:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002d0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002d7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8002da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002e1:	00 
  8002e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002e5:	89 14 24             	mov    %edx,(%esp)
  8002e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002ef:	e8 4c 0d 00 00       	call   801040 <__udivdi3>
  8002f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	89 54 24 04          	mov    %edx,0x4(%esp)
  800309:	89 f2                	mov    %esi,%edx
  80030b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030e:	e8 6d ff ff ff       	call   800280 <printnum>
  800313:	eb 11                	jmp    800326 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800315:	89 74 24 04          	mov    %esi,0x4(%esp)
  800319:	89 3c 24             	mov    %edi,(%esp)
  80031c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80031f:	83 eb 01             	sub    $0x1,%ebx
  800322:	85 db                	test   %ebx,%ebx
  800324:	7f ef                	jg     800315 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800326:	89 74 24 04          	mov    %esi,0x4(%esp)
  80032a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80032e:	8b 45 10             	mov    0x10(%ebp),%eax
  800331:	89 44 24 08          	mov    %eax,0x8(%esp)
  800335:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033c:	00 
  80033d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800340:	89 14 24             	mov    %edx,(%esp)
  800343:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800346:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80034a:	e8 01 0e 00 00       	call   801150 <__umoddi3>
  80034f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800353:	0f be 80 3b 13 80 00 	movsbl 0x80133b(%eax),%eax
  80035a:	89 04 24             	mov    %eax,(%esp)
  80035d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800360:	83 c4 4c             	add    $0x4c,%esp
  800363:	5b                   	pop    %ebx
  800364:	5e                   	pop    %esi
  800365:	5f                   	pop    %edi
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80036b:	83 fa 01             	cmp    $0x1,%edx
  80036e:	7e 0e                	jle    80037e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 08             	lea    0x8(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	8b 52 04             	mov    0x4(%edx),%edx
  80037c:	eb 22                	jmp    8003a0 <getuint+0x38>
	else if (lflag)
  80037e:	85 d2                	test   %edx,%edx
  800380:	74 10                	je     800392 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800382:	8b 10                	mov    (%eax),%edx
  800384:	8d 4a 04             	lea    0x4(%edx),%ecx
  800387:	89 08                	mov    %ecx,(%eax)
  800389:	8b 02                	mov    (%edx),%eax
  80038b:	ba 00 00 00 00       	mov    $0x0,%edx
  800390:	eb 0e                	jmp    8003a0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800392:	8b 10                	mov    (%eax),%edx
  800394:	8d 4a 04             	lea    0x4(%edx),%ecx
  800397:	89 08                	mov    %ecx,(%eax)
  800399:	8b 02                	mov    (%edx),%eax
  80039b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a5:	83 fa 01             	cmp    $0x1,%edx
  8003a8:	7e 0e                	jle    8003b8 <getint+0x16>
		return va_arg(*ap, long long);
  8003aa:	8b 10                	mov    (%eax),%edx
  8003ac:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003af:	89 08                	mov    %ecx,(%eax)
  8003b1:	8b 02                	mov    (%edx),%eax
  8003b3:	8b 52 04             	mov    0x4(%edx),%edx
  8003b6:	eb 22                	jmp    8003da <getint+0x38>
	else if (lflag)
  8003b8:	85 d2                	test   %edx,%edx
  8003ba:	74 10                	je     8003cc <getint+0x2a>
		return va_arg(*ap, long);
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 02                	mov    (%edx),%eax
  8003c5:	89 c2                	mov    %eax,%edx
  8003c7:	c1 fa 1f             	sar    $0x1f,%edx
  8003ca:	eb 0e                	jmp    8003da <getint+0x38>
	else
		return va_arg(*ap, int);
  8003cc:	8b 10                	mov    (%eax),%edx
  8003ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d1:	89 08                	mov    %ecx,(%eax)
  8003d3:	8b 02                	mov    (%edx),%eax
  8003d5:	89 c2                	mov    %eax,%edx
  8003d7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    

008003dc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e6:	8b 10                	mov    (%eax),%edx
  8003e8:	3b 50 04             	cmp    0x4(%eax),%edx
  8003eb:	73 0a                	jae    8003f7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f0:	88 0a                	mov    %cl,(%edx)
  8003f2:	83 c2 01             	add    $0x1,%edx
  8003f5:	89 10                	mov    %edx,(%eax)
}
  8003f7:	5d                   	pop    %ebp
  8003f8:	c3                   	ret    

008003f9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003f9:	55                   	push   %ebp
  8003fa:	89 e5                	mov    %esp,%ebp
  8003fc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ff:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800402:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800406:	8b 45 10             	mov    0x10(%ebp),%eax
  800409:	89 44 24 08          	mov    %eax,0x8(%esp)
  80040d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800410:	89 44 24 04          	mov    %eax,0x4(%esp)
  800414:	8b 45 08             	mov    0x8(%ebp),%eax
  800417:	89 04 24             	mov    %eax,(%esp)
  80041a:	e8 02 00 00 00       	call   800421 <vprintfmt>
	va_end(ap);
}
  80041f:	c9                   	leave  
  800420:	c3                   	ret    

00800421 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	57                   	push   %edi
  800425:	56                   	push   %esi
  800426:	53                   	push   %ebx
  800427:	83 ec 4c             	sub    $0x4c,%esp
  80042a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80042d:	eb 23                	jmp    800452 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80042f:	85 c0                	test   %eax,%eax
  800431:	75 12                	jne    800445 <vprintfmt+0x24>
				csa = 0x0700;
  800433:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80043a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80043d:	83 c4 4c             	add    $0x4c,%esp
  800440:	5b                   	pop    %ebx
  800441:	5e                   	pop    %esi
  800442:	5f                   	pop    %edi
  800443:	5d                   	pop    %ebp
  800444:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800445:	8b 55 0c             	mov    0xc(%ebp),%edx
  800448:	89 54 24 04          	mov    %edx,0x4(%esp)
  80044c:	89 04 24             	mov    %eax,(%esp)
  80044f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800452:	0f b6 07             	movzbl (%edi),%eax
  800455:	83 c7 01             	add    $0x1,%edi
  800458:	83 f8 25             	cmp    $0x25,%eax
  80045b:	75 d2                	jne    80042f <vprintfmt+0xe>
  80045d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800461:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800468:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80046d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800474:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800479:	be 00 00 00 00       	mov    $0x0,%esi
  80047e:	eb 14                	jmp    800494 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800480:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800484:	eb 0e                	jmp    800494 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800486:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80048a:	eb 08                	jmp    800494 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80048c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80048f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	0f b6 07             	movzbl (%edi),%eax
  800497:	0f b6 c8             	movzbl %al,%ecx
  80049a:	83 c7 01             	add    $0x1,%edi
  80049d:	83 e8 23             	sub    $0x23,%eax
  8004a0:	3c 55                	cmp    $0x55,%al
  8004a2:	0f 87 ed 02 00 00    	ja     800795 <vprintfmt+0x374>
  8004a8:	0f b6 c0             	movzbl %al,%eax
  8004ab:	ff 24 85 00 14 80 00 	jmp    *0x801400(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  8004b5:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004b8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004bb:	83 f9 09             	cmp    $0x9,%ecx
  8004be:	77 3c                	ja     8004fc <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004c3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8004c6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8004ca:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004cd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004d0:	83 f9 09             	cmp    $0x9,%ecx
  8004d3:	76 eb                	jbe    8004c0 <vprintfmt+0x9f>
  8004d5:	eb 25                	jmp    8004fc <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8d 48 04             	lea    0x4(%eax),%ecx
  8004dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004e0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  8004e2:	eb 18                	jmp    8004fc <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  8004e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004eb:	0f 48 c6             	cmovs  %esi,%eax
  8004ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004f1:	eb a1                	jmp    800494 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  8004f3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004fa:	eb 98                	jmp    800494 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  8004fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800500:	79 92                	jns    800494 <vprintfmt+0x73>
  800502:	eb 88                	jmp    80048c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800504:	83 c2 01             	add    $0x1,%edx
  800507:	eb 8b                	jmp    800494 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 50 04             	lea    0x4(%eax),%edx
  80050f:	89 55 14             	mov    %edx,0x14(%ebp)
  800512:	8b 55 0c             	mov    0xc(%ebp),%edx
  800515:	89 54 24 04          	mov    %edx,0x4(%esp)
  800519:	8b 00                	mov    (%eax),%eax
  80051b:	89 04 24             	mov    %eax,(%esp)
  80051e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800521:	e9 2c ff ff ff       	jmp    800452 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 50 04             	lea    0x4(%eax),%edx
  80052c:	89 55 14             	mov    %edx,0x14(%ebp)
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	89 c2                	mov    %eax,%edx
  800533:	c1 fa 1f             	sar    $0x1f,%edx
  800536:	31 d0                	xor    %edx,%eax
  800538:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053a:	83 f8 08             	cmp    $0x8,%eax
  80053d:	7f 0b                	jg     80054a <vprintfmt+0x129>
  80053f:	8b 14 85 60 15 80 00 	mov    0x801560(,%eax,4),%edx
  800546:	85 d2                	test   %edx,%edx
  800548:	75 23                	jne    80056d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80054a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80054e:	c7 44 24 08 53 13 80 	movl   $0x801353,0x8(%esp)
  800555:	00 
  800556:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800559:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055d:	8b 45 08             	mov    0x8(%ebp),%eax
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	e8 91 fe ff ff       	call   8003f9 <printfmt>
  800568:	e9 e5 fe ff ff       	jmp    800452 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80056d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800571:	c7 44 24 08 5c 13 80 	movl   $0x80135c,0x8(%esp)
  800578:	00 
  800579:	8b 55 0c             	mov    0xc(%ebp),%edx
  80057c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800580:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800583:	89 1c 24             	mov    %ebx,(%esp)
  800586:	e8 6e fe ff ff       	call   8003f9 <printfmt>
  80058b:	e9 c2 fe ff ff       	jmp    800452 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800590:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800593:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800596:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 50 04             	lea    0x4(%eax),%edx
  80059f:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a2:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005a4:	85 f6                	test   %esi,%esi
  8005a6:	ba 4c 13 80 00       	mov    $0x80134c,%edx
  8005ab:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005ae:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b2:	7e 06                	jle    8005ba <vprintfmt+0x199>
  8005b4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005b8:	75 13                	jne    8005cd <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ba:	0f be 06             	movsbl (%esi),%eax
  8005bd:	83 c6 01             	add    $0x1,%esi
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	0f 85 a2 00 00 00    	jne    80066a <vprintfmt+0x249>
  8005c8:	e9 92 00 00 00       	jmp    80065f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d1:	89 34 24             	mov    %esi,(%esp)
  8005d4:	e8 82 02 00 00       	call   80085b <strnlen>
  8005d9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005dc:	29 c2                	sub    %eax,%edx
  8005de:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005e1:	85 d2                	test   %edx,%edx
  8005e3:	7e d5                	jle    8005ba <vprintfmt+0x199>
					putch(padc, putdat);
  8005e5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8005e9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005ec:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005ef:	89 d3                	mov    %edx,%ebx
  8005f1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005f4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005f7:	89 c6                	mov    %eax,%esi
  8005f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fd:	89 34 24             	mov    %esi,(%esp)
  800600:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800603:	83 eb 01             	sub    $0x1,%ebx
  800606:	85 db                	test   %ebx,%ebx
  800608:	7f ef                	jg     8005f9 <vprintfmt+0x1d8>
  80060a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80060d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800610:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800613:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80061a:	eb 9e                	jmp    8005ba <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800620:	74 1b                	je     80063d <vprintfmt+0x21c>
  800622:	8d 50 e0             	lea    -0x20(%eax),%edx
  800625:	83 fa 5e             	cmp    $0x5e,%edx
  800628:	76 13                	jbe    80063d <vprintfmt+0x21c>
					putch('?', putdat);
  80062a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80062d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800631:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800638:	ff 55 08             	call   *0x8(%ebp)
  80063b:	eb 0d                	jmp    80064a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80063d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800640:	89 54 24 04          	mov    %edx,0x4(%esp)
  800644:	89 04 24             	mov    %eax,(%esp)
  800647:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064a:	83 ef 01             	sub    $0x1,%edi
  80064d:	0f be 06             	movsbl (%esi),%eax
  800650:	85 c0                	test   %eax,%eax
  800652:	74 05                	je     800659 <vprintfmt+0x238>
  800654:	83 c6 01             	add    $0x1,%esi
  800657:	eb 17                	jmp    800670 <vprintfmt+0x24f>
  800659:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80065c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800663:	7f 1c                	jg     800681 <vprintfmt+0x260>
  800665:	e9 e8 fd ff ff       	jmp    800452 <vprintfmt+0x31>
  80066a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800670:	85 db                	test   %ebx,%ebx
  800672:	78 a8                	js     80061c <vprintfmt+0x1fb>
  800674:	83 eb 01             	sub    $0x1,%ebx
  800677:	79 a3                	jns    80061c <vprintfmt+0x1fb>
  800679:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80067c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80067f:	eb de                	jmp    80065f <vprintfmt+0x23e>
  800681:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800684:	8b 7d 08             	mov    0x8(%ebp),%edi
  800687:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80068a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80068e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800695:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800697:	83 eb 01             	sub    $0x1,%ebx
  80069a:	85 db                	test   %ebx,%ebx
  80069c:	7f ec                	jg     80068a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006a1:	e9 ac fd ff ff       	jmp    800452 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 f4 fc ff ff       	call   8003a2 <getint>
  8006ae:	89 c3                	mov    %eax,%ebx
  8006b0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8006b2:	85 d2                	test   %edx,%edx
  8006b4:	78 0a                	js     8006c0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006bb:	e9 87 00 00 00       	jmp    800747 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ce:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006d1:	89 d8                	mov    %ebx,%eax
  8006d3:	89 f2                	mov    %esi,%edx
  8006d5:	f7 d8                	neg    %eax
  8006d7:	83 d2 00             	adc    $0x0,%edx
  8006da:	f7 da                	neg    %edx
			}
			base = 10;
  8006dc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e1:	eb 64                	jmp    800747 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 7d fc ff ff       	call   800368 <getuint>
			base = 10;
  8006eb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f0:	eb 55                	jmp    800747 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8006f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f5:	e8 6e fc ff ff       	call   800368 <getuint>
      base = 8;
  8006fa:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8006ff:	eb 46                	jmp    800747 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800701:	8b 55 0c             	mov    0xc(%ebp),%edx
  800704:	89 54 24 04          	mov    %edx,0x4(%esp)
  800708:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80070f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800712:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800715:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800719:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800720:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800723:	8b 45 14             	mov    0x14(%ebp),%eax
  800726:	8d 50 04             	lea    0x4(%eax),%edx
  800729:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072c:	8b 00                	mov    (%eax),%eax
  80072e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800733:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800738:	eb 0d                	jmp    800747 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80073a:	8d 45 14             	lea    0x14(%ebp),%eax
  80073d:	e8 26 fc ff ff       	call   800368 <getuint>
			base = 16;
  800742:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800747:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80074b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80074f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800752:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800756:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80075a:	89 04 24             	mov    %eax,(%esp)
  80075d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800761:	8b 55 0c             	mov    0xc(%ebp),%edx
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	e8 14 fb ff ff       	call   800280 <printnum>
			break;
  80076c:	e9 e1 fc ff ff       	jmp    800452 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800771:	8b 45 0c             	mov    0xc(%ebp),%eax
  800774:	89 44 24 04          	mov    %eax,0x4(%esp)
  800778:	89 0c 24             	mov    %ecx,(%esp)
  80077b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80077e:	e9 cf fc ff ff       	jmp    800452 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
  800786:	e8 17 fc ff ff       	call   8003a2 <getint>
			csa = num;
  80078b:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  800790:	e9 bd fc ff ff       	jmp    800452 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800795:	8b 55 0c             	mov    0xc(%ebp),%edx
  800798:	89 54 24 04          	mov    %edx,0x4(%esp)
  80079c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a6:	83 ef 01             	sub    $0x1,%edi
  8007a9:	eb 02                	jmp    8007ad <vprintfmt+0x38c>
  8007ab:	89 c7                	mov    %eax,%edi
  8007ad:	8d 47 ff             	lea    -0x1(%edi),%eax
  8007b0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007b4:	75 f5                	jne    8007ab <vprintfmt+0x38a>
  8007b6:	e9 97 fc ff ff       	jmp    800452 <vprintfmt+0x31>

008007bb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	83 ec 28             	sub    $0x28,%esp
  8007c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ca:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ce:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	74 30                	je     80080c <vsnprintf+0x51>
  8007dc:	85 d2                	test   %edx,%edx
  8007de:	7e 2c                	jle    80080c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f5:	c7 04 24 dc 03 80 00 	movl   $0x8003dc,(%esp)
  8007fc:	e8 20 fc ff ff       	call   800421 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800801:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800804:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800807:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80080a:	eb 05                	jmp    800811 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80080c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800819:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800820:	8b 45 10             	mov    0x10(%ebp),%eax
  800823:	89 44 24 08          	mov    %eax,0x8(%esp)
  800827:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	89 04 24             	mov    %eax,(%esp)
  800834:	e8 82 ff ff ff       	call   8007bb <vsnprintf>
	va_end(ap);

	return rc;
}
  800839:	c9                   	leave  
  80083a:	c3                   	ret    
  80083b:	00 00                	add    %al,(%eax)
  80083d:	00 00                	add    %al,(%eax)
	...

00800840 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
  80084b:	80 3a 00             	cmpb   $0x0,(%edx)
  80084e:	74 09                	je     800859 <strlen+0x19>
		n++;
  800850:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800853:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800857:	75 f7                	jne    800850 <strlen+0x10>
		n++;
	return n;
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800864:	b8 00 00 00 00       	mov    $0x0,%eax
  800869:	85 d2                	test   %edx,%edx
  80086b:	74 12                	je     80087f <strnlen+0x24>
  80086d:	80 39 00             	cmpb   $0x0,(%ecx)
  800870:	74 0d                	je     80087f <strnlen+0x24>
		n++;
  800872:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800875:	39 d0                	cmp    %edx,%eax
  800877:	74 06                	je     80087f <strnlen+0x24>
  800879:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80087d:	75 f3                	jne    800872 <strnlen+0x17>
		n++;
	return n;
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	53                   	push   %ebx
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80088b:	ba 00 00 00 00       	mov    $0x0,%edx
  800890:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800894:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800897:	83 c2 01             	add    $0x1,%edx
  80089a:	84 c9                	test   %cl,%cl
  80089c:	75 f2                	jne    800890 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80089e:	5b                   	pop    %ebx
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	53                   	push   %ebx
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ab:	89 1c 24             	mov    %ebx,(%esp)
  8008ae:	e8 8d ff ff ff       	call   800840 <strlen>
	strcpy(dst + len, src);
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ba:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008bd:	89 04 24             	mov    %eax,(%esp)
  8008c0:	e8 bc ff ff ff       	call   800881 <strcpy>
	return dst;
}
  8008c5:	89 d8                	mov    %ebx,%eax
  8008c7:	83 c4 08             	add    $0x8,%esp
  8008ca:	5b                   	pop    %ebx
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008db:	85 f6                	test   %esi,%esi
  8008dd:	74 18                	je     8008f7 <strncpy+0x2a>
  8008df:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008e4:	0f b6 1a             	movzbl (%edx),%ebx
  8008e7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ea:	80 3a 01             	cmpb   $0x1,(%edx)
  8008ed:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f0:	83 c1 01             	add    $0x1,%ecx
  8008f3:	39 ce                	cmp    %ecx,%esi
  8008f5:	77 ed                	ja     8008e4 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5e                   	pop    %esi
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	8b 75 08             	mov    0x8(%ebp),%esi
  800903:	8b 55 0c             	mov    0xc(%ebp),%edx
  800906:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800909:	89 f0                	mov    %esi,%eax
  80090b:	85 c9                	test   %ecx,%ecx
  80090d:	74 23                	je     800932 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  80090f:	83 e9 01             	sub    $0x1,%ecx
  800912:	74 1b                	je     80092f <strlcpy+0x34>
  800914:	0f b6 1a             	movzbl (%edx),%ebx
  800917:	84 db                	test   %bl,%bl
  800919:	74 14                	je     80092f <strlcpy+0x34>
			*dst++ = *src++;
  80091b:	88 18                	mov    %bl,(%eax)
  80091d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800920:	83 e9 01             	sub    $0x1,%ecx
  800923:	74 0a                	je     80092f <strlcpy+0x34>
			*dst++ = *src++;
  800925:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800928:	0f b6 1a             	movzbl (%edx),%ebx
  80092b:	84 db                	test   %bl,%bl
  80092d:	75 ec                	jne    80091b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80092f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800932:	29 f0                	sub    %esi,%eax
}
  800934:	5b                   	pop    %ebx
  800935:	5e                   	pop    %esi
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800941:	0f b6 01             	movzbl (%ecx),%eax
  800944:	84 c0                	test   %al,%al
  800946:	74 15                	je     80095d <strcmp+0x25>
  800948:	3a 02                	cmp    (%edx),%al
  80094a:	75 11                	jne    80095d <strcmp+0x25>
		p++, q++;
  80094c:	83 c1 01             	add    $0x1,%ecx
  80094f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800952:	0f b6 01             	movzbl (%ecx),%eax
  800955:	84 c0                	test   %al,%al
  800957:	74 04                	je     80095d <strcmp+0x25>
  800959:	3a 02                	cmp    (%edx),%al
  80095b:	74 ef                	je     80094c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095d:	0f b6 c0             	movzbl %al,%eax
  800960:	0f b6 12             	movzbl (%edx),%edx
  800963:	29 d0                	sub    %edx,%eax
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800971:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800974:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800979:	85 d2                	test   %edx,%edx
  80097b:	74 28                	je     8009a5 <strncmp+0x3e>
  80097d:	0f b6 01             	movzbl (%ecx),%eax
  800980:	84 c0                	test   %al,%al
  800982:	74 24                	je     8009a8 <strncmp+0x41>
  800984:	3a 03                	cmp    (%ebx),%al
  800986:	75 20                	jne    8009a8 <strncmp+0x41>
  800988:	83 ea 01             	sub    $0x1,%edx
  80098b:	74 13                	je     8009a0 <strncmp+0x39>
		n--, p++, q++;
  80098d:	83 c1 01             	add    $0x1,%ecx
  800990:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800993:	0f b6 01             	movzbl (%ecx),%eax
  800996:	84 c0                	test   %al,%al
  800998:	74 0e                	je     8009a8 <strncmp+0x41>
  80099a:	3a 03                	cmp    (%ebx),%al
  80099c:	74 ea                	je     800988 <strncmp+0x21>
  80099e:	eb 08                	jmp    8009a8 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a5:	5b                   	pop    %ebx
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a8:	0f b6 01             	movzbl (%ecx),%eax
  8009ab:	0f b6 13             	movzbl (%ebx),%edx
  8009ae:	29 d0                	sub    %edx,%eax
  8009b0:	eb f3                	jmp    8009a5 <strncmp+0x3e>

008009b2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009bc:	0f b6 10             	movzbl (%eax),%edx
  8009bf:	84 d2                	test   %dl,%dl
  8009c1:	74 20                	je     8009e3 <strchr+0x31>
		if (*s == c)
  8009c3:	38 ca                	cmp    %cl,%dl
  8009c5:	75 0b                	jne    8009d2 <strchr+0x20>
  8009c7:	eb 1f                	jmp    8009e8 <strchr+0x36>
  8009c9:	38 ca                	cmp    %cl,%dl
  8009cb:	90                   	nop
  8009cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009d0:	74 16                	je     8009e8 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d2:	83 c0 01             	add    $0x1,%eax
  8009d5:	0f b6 10             	movzbl (%eax),%edx
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	75 ed                	jne    8009c9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e1:	eb 05                	jmp    8009e8 <strchr+0x36>
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f4:	0f b6 10             	movzbl (%eax),%edx
  8009f7:	84 d2                	test   %dl,%dl
  8009f9:	74 14                	je     800a0f <strfind+0x25>
		if (*s == c)
  8009fb:	38 ca                	cmp    %cl,%dl
  8009fd:	75 06                	jne    800a05 <strfind+0x1b>
  8009ff:	eb 0e                	jmp    800a0f <strfind+0x25>
  800a01:	38 ca                	cmp    %cl,%dl
  800a03:	74 0a                	je     800a0f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a05:	83 c0 01             	add    $0x1,%eax
  800a08:	0f b6 10             	movzbl (%eax),%edx
  800a0b:	84 d2                	test   %dl,%dl
  800a0d:	75 f2                	jne    800a01 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	83 ec 0c             	sub    $0xc,%esp
  800a17:	89 1c 24             	mov    %ebx,(%esp)
  800a1a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a22:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a2b:	85 c9                	test   %ecx,%ecx
  800a2d:	74 30                	je     800a5f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a35:	75 25                	jne    800a5c <memset+0x4b>
  800a37:	f6 c1 03             	test   $0x3,%cl
  800a3a:	75 20                	jne    800a5c <memset+0x4b>
		c &= 0xFF;
  800a3c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a3f:	89 d3                	mov    %edx,%ebx
  800a41:	c1 e3 08             	shl    $0x8,%ebx
  800a44:	89 d6                	mov    %edx,%esi
  800a46:	c1 e6 18             	shl    $0x18,%esi
  800a49:	89 d0                	mov    %edx,%eax
  800a4b:	c1 e0 10             	shl    $0x10,%eax
  800a4e:	09 f0                	or     %esi,%eax
  800a50:	09 d0                	or     %edx,%eax
  800a52:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a54:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a57:	fc                   	cld    
  800a58:	f3 ab                	rep stos %eax,%es:(%edi)
  800a5a:	eb 03                	jmp    800a5f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a5c:	fc                   	cld    
  800a5d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a5f:	89 f8                	mov    %edi,%eax
  800a61:	8b 1c 24             	mov    (%esp),%ebx
  800a64:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a68:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a6c:	89 ec                	mov    %ebp,%esp
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	83 ec 08             	sub    $0x8,%esp
  800a76:	89 34 24             	mov    %esi,(%esp)
  800a79:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a83:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a86:	39 c6                	cmp    %eax,%esi
  800a88:	73 36                	jae    800ac0 <memmove+0x50>
  800a8a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a8d:	39 d0                	cmp    %edx,%eax
  800a8f:	73 2f                	jae    800ac0 <memmove+0x50>
		s += n;
		d += n;
  800a91:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a94:	f6 c2 03             	test   $0x3,%dl
  800a97:	75 1b                	jne    800ab4 <memmove+0x44>
  800a99:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9f:	75 13                	jne    800ab4 <memmove+0x44>
  800aa1:	f6 c1 03             	test   $0x3,%cl
  800aa4:	75 0e                	jne    800ab4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa6:	83 ef 04             	sub    $0x4,%edi
  800aa9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aac:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aaf:	fd                   	std    
  800ab0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab2:	eb 09                	jmp    800abd <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ab4:	83 ef 01             	sub    $0x1,%edi
  800ab7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aba:	fd                   	std    
  800abb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800abd:	fc                   	cld    
  800abe:	eb 20                	jmp    800ae0 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ac6:	75 13                	jne    800adb <memmove+0x6b>
  800ac8:	a8 03                	test   $0x3,%al
  800aca:	75 0f                	jne    800adb <memmove+0x6b>
  800acc:	f6 c1 03             	test   $0x3,%cl
  800acf:	75 0a                	jne    800adb <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ad4:	89 c7                	mov    %eax,%edi
  800ad6:	fc                   	cld    
  800ad7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad9:	eb 05                	jmp    800ae0 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800adb:	89 c7                	mov    %eax,%edi
  800add:	fc                   	cld    
  800ade:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae0:	8b 34 24             	mov    (%esp),%esi
  800ae3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ae7:	89 ec                	mov    %ebp,%esp
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800af1:	8b 45 10             	mov    0x10(%ebp),%eax
  800af4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	89 04 24             	mov    %eax,(%esp)
  800b05:	e8 66 ff ff ff       	call   800a70 <memmove>
}
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b18:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b20:	85 ff                	test   %edi,%edi
  800b22:	74 38                	je     800b5c <memcmp+0x50>
		if (*s1 != *s2)
  800b24:	0f b6 03             	movzbl (%ebx),%eax
  800b27:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2a:	83 ef 01             	sub    $0x1,%edi
  800b2d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b32:	38 c8                	cmp    %cl,%al
  800b34:	74 1d                	je     800b53 <memcmp+0x47>
  800b36:	eb 11                	jmp    800b49 <memcmp+0x3d>
  800b38:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b3d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800b42:	83 c2 01             	add    $0x1,%edx
  800b45:	38 c8                	cmp    %cl,%al
  800b47:	74 0a                	je     800b53 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800b49:	0f b6 c0             	movzbl %al,%eax
  800b4c:	0f b6 c9             	movzbl %cl,%ecx
  800b4f:	29 c8                	sub    %ecx,%eax
  800b51:	eb 09                	jmp    800b5c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b53:	39 fa                	cmp    %edi,%edx
  800b55:	75 e1                	jne    800b38 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b67:	89 c2                	mov    %eax,%edx
  800b69:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b6c:	39 d0                	cmp    %edx,%eax
  800b6e:	73 15                	jae    800b85 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b74:	38 08                	cmp    %cl,(%eax)
  800b76:	75 06                	jne    800b7e <memfind+0x1d>
  800b78:	eb 0b                	jmp    800b85 <memfind+0x24>
  800b7a:	38 08                	cmp    %cl,(%eax)
  800b7c:	74 07                	je     800b85 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b7e:	83 c0 01             	add    $0x1,%eax
  800b81:	39 c2                	cmp    %eax,%edx
  800b83:	77 f5                	ja     800b7a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
  800b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b93:	0f b6 02             	movzbl (%edx),%eax
  800b96:	3c 20                	cmp    $0x20,%al
  800b98:	74 04                	je     800b9e <strtol+0x17>
  800b9a:	3c 09                	cmp    $0x9,%al
  800b9c:	75 0e                	jne    800bac <strtol+0x25>
		s++;
  800b9e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba1:	0f b6 02             	movzbl (%edx),%eax
  800ba4:	3c 20                	cmp    $0x20,%al
  800ba6:	74 f6                	je     800b9e <strtol+0x17>
  800ba8:	3c 09                	cmp    $0x9,%al
  800baa:	74 f2                	je     800b9e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bac:	3c 2b                	cmp    $0x2b,%al
  800bae:	75 0a                	jne    800bba <strtol+0x33>
		s++;
  800bb0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bb3:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb8:	eb 10                	jmp    800bca <strtol+0x43>
  800bba:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bbf:	3c 2d                	cmp    $0x2d,%al
  800bc1:	75 07                	jne    800bca <strtol+0x43>
		s++, neg = 1;
  800bc3:	83 c2 01             	add    $0x1,%edx
  800bc6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bca:	85 db                	test   %ebx,%ebx
  800bcc:	0f 94 c0             	sete   %al
  800bcf:	74 05                	je     800bd6 <strtol+0x4f>
  800bd1:	83 fb 10             	cmp    $0x10,%ebx
  800bd4:	75 15                	jne    800beb <strtol+0x64>
  800bd6:	80 3a 30             	cmpb   $0x30,(%edx)
  800bd9:	75 10                	jne    800beb <strtol+0x64>
  800bdb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bdf:	75 0a                	jne    800beb <strtol+0x64>
		s += 2, base = 16;
  800be1:	83 c2 02             	add    $0x2,%edx
  800be4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be9:	eb 13                	jmp    800bfe <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800beb:	84 c0                	test   %al,%al
  800bed:	74 0f                	je     800bfe <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bef:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bf7:	75 05                	jne    800bfe <strtol+0x77>
		s++, base = 8;
  800bf9:	83 c2 01             	add    $0x1,%edx
  800bfc:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800bfe:	b8 00 00 00 00       	mov    $0x0,%eax
  800c03:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c05:	0f b6 0a             	movzbl (%edx),%ecx
  800c08:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c0b:	80 fb 09             	cmp    $0x9,%bl
  800c0e:	77 08                	ja     800c18 <strtol+0x91>
			dig = *s - '0';
  800c10:	0f be c9             	movsbl %cl,%ecx
  800c13:	83 e9 30             	sub    $0x30,%ecx
  800c16:	eb 1e                	jmp    800c36 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c18:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c1b:	80 fb 19             	cmp    $0x19,%bl
  800c1e:	77 08                	ja     800c28 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c20:	0f be c9             	movsbl %cl,%ecx
  800c23:	83 e9 57             	sub    $0x57,%ecx
  800c26:	eb 0e                	jmp    800c36 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c28:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c2b:	80 fb 19             	cmp    $0x19,%bl
  800c2e:	77 15                	ja     800c45 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800c30:	0f be c9             	movsbl %cl,%ecx
  800c33:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c36:	39 f1                	cmp    %esi,%ecx
  800c38:	7d 0f                	jge    800c49 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800c3a:	83 c2 01             	add    $0x1,%edx
  800c3d:	0f af c6             	imul   %esi,%eax
  800c40:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c43:	eb c0                	jmp    800c05 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c45:	89 c1                	mov    %eax,%ecx
  800c47:	eb 02                	jmp    800c4b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c49:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c4b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4f:	74 05                	je     800c56 <strtol+0xcf>
		*endptr = (char *) s;
  800c51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c54:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c56:	89 ca                	mov    %ecx,%edx
  800c58:	f7 da                	neg    %edx
  800c5a:	85 ff                	test   %edi,%edi
  800c5c:	0f 45 c2             	cmovne %edx,%eax
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	89 1c 24             	mov    %ebx,(%esp)
  800c6d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c71:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c75:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	89 c3                	mov    %eax,%ebx
  800c82:	89 c7                	mov    %eax,%edi
  800c84:	89 c6                	mov    %eax,%esi
  800c86:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c88:	8b 1c 24             	mov    (%esp),%ebx
  800c8b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c8f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c93:	89 ec                	mov    %ebp,%esp
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 0c             	sub    $0xc,%esp
  800c9d:	89 1c 24             	mov    %ebx,(%esp)
  800ca0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cad:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb2:	89 d1                	mov    %edx,%ecx
  800cb4:	89 d3                	mov    %edx,%ebx
  800cb6:	89 d7                	mov    %edx,%edi
  800cb8:	89 d6                	mov    %edx,%esi
  800cba:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cbc:	8b 1c 24             	mov    (%esp),%ebx
  800cbf:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cc3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cc7:	89 ec                	mov    %ebp,%esp
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 38             	sub    $0x38,%esp
  800cd1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	89 cb                	mov    %ecx,%ebx
  800ce9:	89 cf                	mov    %ecx,%edi
  800ceb:	89 ce                	mov    %ecx,%esi
  800ced:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	7e 28                	jle    800d1b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cfe:	00 
  800cff:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800d06:	00 
  800d07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d0e:	00 
  800d0f:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800d16:	e8 41 f4 ff ff       	call   80015c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d1b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d1e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d21:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d24:	89 ec                	mov    %ebp,%esp
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	89 1c 24             	mov    %ebx,(%esp)
  800d31:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d35:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d43:	89 d1                	mov    %edx,%ecx
  800d45:	89 d3                	mov    %edx,%ebx
  800d47:	89 d7                	mov    %edx,%edi
  800d49:	89 d6                	mov    %edx,%esi
  800d4b:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800d4d:	8b 1c 24             	mov    (%esp),%ebx
  800d50:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d54:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d58:	89 ec                	mov    %ebp,%esp
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_yield>:

void
sys_yield(void)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	89 1c 24             	mov    %ebx,(%esp)
  800d65:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d69:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d72:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d77:	89 d1                	mov    %edx,%ecx
  800d79:	89 d3                	mov    %edx,%ebx
  800d7b:	89 d7                	mov    %edx,%edi
  800d7d:	89 d6                	mov    %edx,%esi
  800d7f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d81:	8b 1c 24             	mov    (%esp),%ebx
  800d84:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d88:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d8c:	89 ec                	mov    %ebp,%esp
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	83 ec 38             	sub    $0x38,%esp
  800d96:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d99:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d9c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9f:	be 00 00 00 00       	mov    $0x0,%esi
  800da4:	b8 04 00 00 00       	mov    $0x4,%eax
  800da9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daf:	8b 55 08             	mov    0x8(%ebp),%edx
  800db2:	89 f7                	mov    %esi,%edi
  800db4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db6:	85 c0                	test   %eax,%eax
  800db8:	7e 28                	jle    800de2 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbe:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800dc5:	00 
  800dc6:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800dcd:	00 
  800dce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd5:	00 
  800dd6:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800ddd:	e8 7a f3 ff ff       	call   80015c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800de2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800deb:	89 ec                	mov    %ebp,%esp
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 38             	sub    $0x38,%esp
  800df5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfe:	b8 05 00 00 00       	mov    $0x5,%eax
  800e03:	8b 75 18             	mov    0x18(%ebp),%esi
  800e06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e14:	85 c0                	test   %eax,%eax
  800e16:	7e 28                	jle    800e40 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e23:	00 
  800e24:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800e2b:	00 
  800e2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e33:	00 
  800e34:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800e3b:	e8 1c f3 ff ff       	call   80015c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e40:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e43:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e46:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e49:	89 ec                	mov    %ebp,%esp
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	83 ec 38             	sub    $0x38,%esp
  800e53:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e56:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e59:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e61:	b8 06 00 00 00       	mov    $0x6,%eax
  800e66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	89 df                	mov    %ebx,%edi
  800e6e:	89 de                	mov    %ebx,%esi
  800e70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7e 28                	jle    800e9e <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e81:	00 
  800e82:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e91:	00 
  800e92:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800e99:	e8 be f2 ff ff       	call   80015c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e9e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea7:	89 ec                	mov    %ebp,%esp
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	83 ec 38             	sub    $0x38,%esp
  800eb1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebf:	b8 08 00 00 00       	mov    $0x8,%eax
  800ec4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eca:	89 df                	mov    %ebx,%edi
  800ecc:	89 de                	mov    %ebx,%esi
  800ece:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	7e 28                	jle    800efc <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed8:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800edf:	00 
  800ee0:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800ee7:	00 
  800ee8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eef:	00 
  800ef0:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800ef7:	e8 60 f2 ff ff       	call   80015c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800efc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eff:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f02:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f05:	89 ec                	mov    %ebp,%esp
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	83 ec 38             	sub    $0x38,%esp
  800f0f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f12:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f15:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1d:	b8 09 00 00 00       	mov    $0x9,%eax
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	89 df                	mov    %ebx,%edi
  800f2a:	89 de                	mov    %ebx,%esi
  800f2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	7e 28                	jle    800f5a <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f32:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f36:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f3d:	00 
  800f3e:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800f45:	00 
  800f46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4d:	00 
  800f4e:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800f55:	e8 02 f2 ff ff       	call   80015c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f5a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f5d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f60:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f63:	89 ec                	mov    %ebp,%esp
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	83 ec 0c             	sub    $0xc,%esp
  800f6d:	89 1c 24             	mov    %ebx,(%esp)
  800f70:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f74:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f78:	be 00 00 00 00       	mov    $0x0,%esi
  800f7d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f90:	8b 1c 24             	mov    (%esp),%ebx
  800f93:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f97:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f9b:	89 ec                	mov    %ebp,%esp
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    

00800f9f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	83 ec 38             	sub    $0x38,%esp
  800fa5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fab:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbb:	89 cb                	mov    %ecx,%ebx
  800fbd:	89 cf                	mov    %ecx,%edi
  800fbf:	89 ce                	mov    %ecx,%esi
  800fc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	7e 28                	jle    800fef <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fcb:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800fd2:	00 
  800fd3:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800fda:	00 
  800fdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe2:	00 
  800fe3:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800fea:	e8 6d f1 ff ff       	call   80015c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff8:	89 ec                	mov    %ebp,%esp
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801002:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801009:	75 1c                	jne    801027 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  80100b:	c7 44 24 08 b0 15 80 	movl   $0x8015b0,0x8(%esp)
  801012:	00 
  801013:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80101a:	00 
  80101b:	c7 04 24 d4 15 80 00 	movl   $0x8015d4,(%esp)
  801022:	e8 35 f1 ff ff       	call   80015c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801027:	8b 45 08             	mov    0x8(%ebp),%eax
  80102a:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80102f:	c9                   	leave  
  801030:	c3                   	ret    
	...

00801040 <__udivdi3>:
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	57                   	push   %edi
  801044:	56                   	push   %esi
  801045:	83 ec 10             	sub    $0x10,%esp
  801048:	8b 75 14             	mov    0x14(%ebp),%esi
  80104b:	8b 45 08             	mov    0x8(%ebp),%eax
  80104e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801051:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801054:	85 f6                	test   %esi,%esi
  801056:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801059:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80105c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80105f:	75 2f                	jne    801090 <__udivdi3+0x50>
  801061:	39 f9                	cmp    %edi,%ecx
  801063:	77 5b                	ja     8010c0 <__udivdi3+0x80>
  801065:	85 c9                	test   %ecx,%ecx
  801067:	75 0b                	jne    801074 <__udivdi3+0x34>
  801069:	b8 01 00 00 00       	mov    $0x1,%eax
  80106e:	31 d2                	xor    %edx,%edx
  801070:	f7 f1                	div    %ecx
  801072:	89 c1                	mov    %eax,%ecx
  801074:	89 f8                	mov    %edi,%eax
  801076:	31 d2                	xor    %edx,%edx
  801078:	f7 f1                	div    %ecx
  80107a:	89 c7                	mov    %eax,%edi
  80107c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80107f:	f7 f1                	div    %ecx
  801081:	89 fa                	mov    %edi,%edx
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	5e                   	pop    %esi
  801087:	5f                   	pop    %edi
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    
  80108a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801090:	31 d2                	xor    %edx,%edx
  801092:	31 c0                	xor    %eax,%eax
  801094:	39 fe                	cmp    %edi,%esi
  801096:	77 eb                	ja     801083 <__udivdi3+0x43>
  801098:	0f bd d6             	bsr    %esi,%edx
  80109b:	83 f2 1f             	xor    $0x1f,%edx
  80109e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010a1:	75 2d                	jne    8010d0 <__udivdi3+0x90>
  8010a3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  8010a6:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  8010a9:	76 06                	jbe    8010b1 <__udivdi3+0x71>
  8010ab:	39 fe                	cmp    %edi,%esi
  8010ad:	89 c2                	mov    %eax,%edx
  8010af:	73 d2                	jae    801083 <__udivdi3+0x43>
  8010b1:	31 d2                	xor    %edx,%edx
  8010b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010b8:	eb c9                	jmp    801083 <__udivdi3+0x43>
  8010ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010c0:	89 fa                	mov    %edi,%edx
  8010c2:	f7 f1                	div    %ecx
  8010c4:	31 d2                	xor    %edx,%edx
  8010c6:	83 c4 10             	add    $0x10,%esp
  8010c9:	5e                   	pop    %esi
  8010ca:	5f                   	pop    %edi
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    
  8010cd:	8d 76 00             	lea    0x0(%esi),%esi
  8010d0:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010d4:	b8 20 00 00 00       	mov    $0x20,%eax
  8010d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010dc:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8010df:	d3 e6                	shl    %cl,%esi
  8010e1:	89 c1                	mov    %eax,%ecx
  8010e3:	d3 ea                	shr    %cl,%edx
  8010e5:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010e9:	09 f2                	or     %esi,%edx
  8010eb:	8b 75 ec             	mov    -0x14(%ebp),%esi
  8010ee:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8010f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010f4:	d3 e2                	shl    %cl,%edx
  8010f6:	89 c1                	mov    %eax,%ecx
  8010f8:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8010fb:	89 fa                	mov    %edi,%edx
  8010fd:	d3 ea                	shr    %cl,%edx
  8010ff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801103:	d3 e7                	shl    %cl,%edi
  801105:	89 c1                	mov    %eax,%ecx
  801107:	d3 ee                	shr    %cl,%esi
  801109:	09 fe                	or     %edi,%esi
  80110b:	89 f0                	mov    %esi,%eax
  80110d:	f7 75 e8             	divl   -0x18(%ebp)
  801110:	89 d7                	mov    %edx,%edi
  801112:	89 c6                	mov    %eax,%esi
  801114:	f7 65 f0             	mull   -0x10(%ebp)
  801117:	39 d7                	cmp    %edx,%edi
  801119:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80111c:	72 22                	jb     801140 <__udivdi3+0x100>
  80111e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801121:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801125:	d3 e2                	shl    %cl,%edx
  801127:	39 c2                	cmp    %eax,%edx
  801129:	73 05                	jae    801130 <__udivdi3+0xf0>
  80112b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80112e:	74 10                	je     801140 <__udivdi3+0x100>
  801130:	89 f0                	mov    %esi,%eax
  801132:	31 d2                	xor    %edx,%edx
  801134:	e9 4a ff ff ff       	jmp    801083 <__udivdi3+0x43>
  801139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801140:	8d 46 ff             	lea    -0x1(%esi),%eax
  801143:	31 d2                	xor    %edx,%edx
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	5e                   	pop    %esi
  801149:	5f                   	pop    %edi
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    
  80114c:	00 00                	add    %al,(%eax)
	...

00801150 <__umoddi3>:
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	57                   	push   %edi
  801154:	56                   	push   %esi
  801155:	83 ec 20             	sub    $0x20,%esp
  801158:	8b 7d 14             	mov    0x14(%ebp),%edi
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
  80115e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801161:	8b 75 0c             	mov    0xc(%ebp),%esi
  801164:	85 ff                	test   %edi,%edi
  801166:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801169:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80116c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80116f:	89 f2                	mov    %esi,%edx
  801171:	75 15                	jne    801188 <__umoddi3+0x38>
  801173:	39 f1                	cmp    %esi,%ecx
  801175:	76 41                	jbe    8011b8 <__umoddi3+0x68>
  801177:	f7 f1                	div    %ecx
  801179:	89 d0                	mov    %edx,%eax
  80117b:	31 d2                	xor    %edx,%edx
  80117d:	83 c4 20             	add    $0x20,%esp
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    
  801184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801188:	39 f7                	cmp    %esi,%edi
  80118a:	77 4c                	ja     8011d8 <__umoddi3+0x88>
  80118c:	0f bd c7             	bsr    %edi,%eax
  80118f:	83 f0 1f             	xor    $0x1f,%eax
  801192:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801195:	75 51                	jne    8011e8 <__umoddi3+0x98>
  801197:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80119a:	0f 87 e8 00 00 00    	ja     801288 <__umoddi3+0x138>
  8011a0:	89 f2                	mov    %esi,%edx
  8011a2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011a5:	29 ce                	sub    %ecx,%esi
  8011a7:	19 fa                	sbb    %edi,%edx
  8011a9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8011ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011af:	83 c4 20             	add    $0x20,%esp
  8011b2:	5e                   	pop    %esi
  8011b3:	5f                   	pop    %edi
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    
  8011b6:	66 90                	xchg   %ax,%ax
  8011b8:	85 c9                	test   %ecx,%ecx
  8011ba:	75 0b                	jne    8011c7 <__umoddi3+0x77>
  8011bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c1:	31 d2                	xor    %edx,%edx
  8011c3:	f7 f1                	div    %ecx
  8011c5:	89 c1                	mov    %eax,%ecx
  8011c7:	89 f0                	mov    %esi,%eax
  8011c9:	31 d2                	xor    %edx,%edx
  8011cb:	f7 f1                	div    %ecx
  8011cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d0:	eb a5                	jmp    801177 <__umoddi3+0x27>
  8011d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011d8:	89 f2                	mov    %esi,%edx
  8011da:	83 c4 20             	add    $0x20,%esp
  8011dd:	5e                   	pop    %esi
  8011de:	5f                   	pop    %edi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    
  8011e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011e8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011ec:	89 f2                	mov    %esi,%edx
  8011ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011f1:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  8011f8:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8011fb:	d3 e7                	shl    %cl,%edi
  8011fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801200:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801204:	d3 e8                	shr    %cl,%eax
  801206:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80120a:	09 f8                	or     %edi,%eax
  80120c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80120f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801212:	d3 e0                	shl    %cl,%eax
  801214:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80121b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80121e:	d3 ea                	shr    %cl,%edx
  801220:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801224:	d3 e6                	shl    %cl,%esi
  801226:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80122a:	d3 e8                	shr    %cl,%eax
  80122c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801230:	09 f0                	or     %esi,%eax
  801232:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801235:	f7 75 e4             	divl   -0x1c(%ebp)
  801238:	d3 e6                	shl    %cl,%esi
  80123a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80123d:	89 d6                	mov    %edx,%esi
  80123f:	f7 65 f4             	mull   -0xc(%ebp)
  801242:	89 d7                	mov    %edx,%edi
  801244:	89 c2                	mov    %eax,%edx
  801246:	39 fe                	cmp    %edi,%esi
  801248:	89 f9                	mov    %edi,%ecx
  80124a:	72 30                	jb     80127c <__umoddi3+0x12c>
  80124c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80124f:	72 27                	jb     801278 <__umoddi3+0x128>
  801251:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801254:	29 d0                	sub    %edx,%eax
  801256:	19 ce                	sbb    %ecx,%esi
  801258:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80125c:	89 f2                	mov    %esi,%edx
  80125e:	d3 e8                	shr    %cl,%eax
  801260:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801264:	d3 e2                	shl    %cl,%edx
  801266:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80126a:	09 d0                	or     %edx,%eax
  80126c:	89 f2                	mov    %esi,%edx
  80126e:	d3 ea                	shr    %cl,%edx
  801270:	83 c4 20             	add    $0x20,%esp
  801273:	5e                   	pop    %esi
  801274:	5f                   	pop    %edi
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    
  801277:	90                   	nop
  801278:	39 fe                	cmp    %edi,%esi
  80127a:	75 d5                	jne    801251 <__umoddi3+0x101>
  80127c:	89 f9                	mov    %edi,%ecx
  80127e:	89 c2                	mov    %eax,%edx
  801280:	2b 55 f4             	sub    -0xc(%ebp),%edx
  801283:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801286:	eb c9                	jmp    801251 <__umoddi3+0x101>
  801288:	39 f7                	cmp    %esi,%edi
  80128a:	0f 82 10 ff ff ff    	jb     8011a0 <__umoddi3+0x50>
  801290:	e9 17 ff ff ff       	jmp    8011ac <__umoddi3+0x5c>
