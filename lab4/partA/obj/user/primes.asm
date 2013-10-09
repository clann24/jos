
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 1f 01 00 00       	call   800150 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 38 10 00 00       	call   801090 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 80 13 80 00 	movl   $0x801380,(%esp)
  800071:	e8 39 02 00 00       	call   8002af <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 d1 0f 00 00       	call   80104c <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 8c 13 80 	movl   $0x80138c,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 95 13 80 00 	movl   $0x801395,(%esp)
  80009c:	e8 13 01 00 00       	call   8001b4 <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 d0 0f 00 00       	call   801090 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	89 c2                	mov    %eax,%edx
  8000c4:	c1 fa 1f             	sar    $0x1f,%edx
  8000c7:	f7 fb                	idiv   %ebx
  8000c9:	85 d2                	test   %edx,%edx
  8000cb:	74 db                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d4:	00 
  8000d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000dc:	00 
  8000dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000e1:	89 3c 24             	mov    %edi,(%esp)
  8000e4:	e8 c9 0f 00 00       	call   8010b2 <ipc_send>
  8000e9:	eb bd                	jmp    8000a8 <primeproc+0x74>

008000eb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000f3:	e8 54 0f 00 00       	call   80104c <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 8c 13 80 	movl   $0x80138c,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 95 13 80 00 	movl   $0x801395,(%esp)
  800119:	e8 96 00 00 00       	call   8001b4 <_panic>
	if (id == 0)
  80011e:	85 c0                	test   %eax,%eax
  800120:	75 05                	jne    800127 <umain+0x3c>
		primeproc();
  800122:	e8 0d ff ff ff       	call   800034 <primeproc>
	}
}

void
umain(int argc, char **argv)
{
  800127:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80013b:	00 
  80013c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800140:	89 34 24             	mov    %esi,(%esp)
  800143:	e8 6a 0f 00 00       	call   8010b2 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800148:	83 c3 01             	add    $0x1,%ebx
  80014b:	eb df                	jmp    80012c <umain+0x41>
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
  800156:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800159:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80015c:	8b 75 08             	mov    0x8(%ebp),%esi
  80015f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800162:	e8 11 0c 00 00       	call   800d78 <sys_getenvid>
  800167:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800174:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800179:	85 f6                	test   %esi,%esi
  80017b:	7e 07                	jle    800184 <libmain+0x34>
		binaryname = argv[0];
  80017d:	8b 03                	mov    (%ebx),%eax
  80017f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800184:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800188:	89 34 24             	mov    %esi,(%esp)
  80018b:	e8 5b ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  800190:	e8 0b 00 00 00       	call   8001a0 <exit>
}
  800195:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800198:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80019b:	89 ec                	mov    %ebp,%esp
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    
	...

008001a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ad:	e8 69 0b 00 00       	call   800d1b <sys_env_destroy>
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001bc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001bf:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001c5:	e8 ae 0b 00 00       	call   800d78 <sys_getenvid>
  8001ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e0:	c7 04 24 b0 13 80 00 	movl   $0x8013b0,(%esp)
  8001e7:	e8 c3 00 00 00       	call   8002af <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	e8 53 00 00 00       	call   80024e <vcprintf>
	cprintf("\n");
  8001fb:	c7 04 24 d4 13 80 00 	movl   $0x8013d4,(%esp)
  800202:	e8 a8 00 00 00       	call   8002af <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800207:	cc                   	int3   
  800208:	eb fd                	jmp    800207 <_panic+0x53>
	...

0080020c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	53                   	push   %ebx
  800210:	83 ec 14             	sub    $0x14,%esp
  800213:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800216:	8b 03                	mov    (%ebx),%eax
  800218:	8b 55 08             	mov    0x8(%ebp),%edx
  80021b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80021f:	83 c0 01             	add    $0x1,%eax
  800222:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800224:	3d ff 00 00 00       	cmp    $0xff,%eax
  800229:	75 19                	jne    800244 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80022b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800232:	00 
  800233:	8d 43 08             	lea    0x8(%ebx),%eax
  800236:	89 04 24             	mov    %eax,(%esp)
  800239:	e8 76 0a 00 00       	call   800cb4 <sys_cputs>
		b->idx = 0;
  80023e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800244:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800248:	83 c4 14             	add    $0x14,%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800257:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025e:	00 00 00 
	b.cnt = 0;
  800261:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800268:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80026b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800272:	8b 45 08             	mov    0x8(%ebp),%eax
  800275:	89 44 24 08          	mov    %eax,0x8(%esp)
  800279:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80027f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800283:	c7 04 24 0c 02 80 00 	movl   $0x80020c,(%esp)
  80028a:	e8 e2 01 00 00       	call   800471 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80028f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800295:	89 44 24 04          	mov    %eax,0x4(%esp)
  800299:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	e8 0d 0a 00 00       	call   800cb4 <sys_cputs>

	return b.cnt;
}
  8002a7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	e8 87 ff ff ff       	call   80024e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c7:	c9                   	leave  
  8002c8:	c3                   	ret    
  8002c9:	00 00                	add    %al,(%eax)
  8002cb:	00 00                	add    %al,(%eax)
  8002cd:	00 00                	add    %al,(%eax)
	...

008002d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 4c             	sub    $0x4c,%esp
  8002d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dc:	89 d6                	mov    %edx,%esi
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002ed:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f5:	39 d0                	cmp    %edx,%eax
  8002f7:	72 11                	jb     80030a <printnum+0x3a>
  8002f9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002fc:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8002ff:	76 09                	jbe    80030a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800301:	83 eb 01             	sub    $0x1,%ebx
  800304:	85 db                	test   %ebx,%ebx
  800306:	7f 5d                	jg     800365 <printnum+0x95>
  800308:	eb 6c                	jmp    800376 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80030a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80030e:	83 eb 01             	sub    $0x1,%ebx
  800311:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800315:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800318:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80031c:	8b 44 24 08          	mov    0x8(%esp),%eax
  800320:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800324:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800327:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80032a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800331:	00 
  800332:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800335:	89 14 24             	mov    %edx,(%esp)
  800338:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80033b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80033f:	e8 dc 0d 00 00       	call   801120 <__udivdi3>
  800344:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800347:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80034a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80034e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800352:	89 04 24             	mov    %eax,(%esp)
  800355:	89 54 24 04          	mov    %edx,0x4(%esp)
  800359:	89 f2                	mov    %esi,%edx
  80035b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80035e:	e8 6d ff ff ff       	call   8002d0 <printnum>
  800363:	eb 11                	jmp    800376 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800365:	89 74 24 04          	mov    %esi,0x4(%esp)
  800369:	89 3c 24             	mov    %edi,(%esp)
  80036c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80036f:	83 eb 01             	sub    $0x1,%ebx
  800372:	85 db                	test   %ebx,%ebx
  800374:	7f ef                	jg     800365 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800376:	89 74 24 04          	mov    %esi,0x4(%esp)
  80037a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80037e:	8b 45 10             	mov    0x10(%ebp),%eax
  800381:	89 44 24 08          	mov    %eax,0x8(%esp)
  800385:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038c:	00 
  80038d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800390:	89 14 24             	mov    %edx,(%esp)
  800393:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800396:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80039a:	e8 91 0e 00 00       	call   801230 <__umoddi3>
  80039f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a3:	0f be 80 d6 13 80 00 	movsbl 0x8013d6(%eax),%eax
  8003aa:	89 04 24             	mov    %eax,(%esp)
  8003ad:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003b0:	83 c4 4c             	add    $0x4c,%esp
  8003b3:	5b                   	pop    %ebx
  8003b4:	5e                   	pop    %esi
  8003b5:	5f                   	pop    %edi
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003bb:	83 fa 01             	cmp    $0x1,%edx
  8003be:	7e 0e                	jle    8003ce <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c5:	89 08                	mov    %ecx,(%eax)
  8003c7:	8b 02                	mov    (%edx),%eax
  8003c9:	8b 52 04             	mov    0x4(%edx),%edx
  8003cc:	eb 22                	jmp    8003f0 <getuint+0x38>
	else if (lflag)
  8003ce:	85 d2                	test   %edx,%edx
  8003d0:	74 10                	je     8003e2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003d2:	8b 10                	mov    (%eax),%edx
  8003d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d7:	89 08                	mov    %ecx,(%eax)
  8003d9:	8b 02                	mov    (%edx),%eax
  8003db:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e0:	eb 0e                	jmp    8003f0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003e2:	8b 10                	mov    (%eax),%edx
  8003e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e7:	89 08                	mov    %ecx,(%eax)
  8003e9:	8b 02                	mov    (%edx),%eax
  8003eb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f0:	5d                   	pop    %ebp
  8003f1:	c3                   	ret    

008003f2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003f5:	83 fa 01             	cmp    $0x1,%edx
  8003f8:	7e 0e                	jle    800408 <getint+0x16>
		return va_arg(*ap, long long);
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ff:	89 08                	mov    %ecx,(%eax)
  800401:	8b 02                	mov    (%edx),%eax
  800403:	8b 52 04             	mov    0x4(%edx),%edx
  800406:	eb 22                	jmp    80042a <getint+0x38>
	else if (lflag)
  800408:	85 d2                	test   %edx,%edx
  80040a:	74 10                	je     80041c <getint+0x2a>
		return va_arg(*ap, long);
  80040c:	8b 10                	mov    (%eax),%edx
  80040e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800411:	89 08                	mov    %ecx,(%eax)
  800413:	8b 02                	mov    (%edx),%eax
  800415:	89 c2                	mov    %eax,%edx
  800417:	c1 fa 1f             	sar    $0x1f,%edx
  80041a:	eb 0e                	jmp    80042a <getint+0x38>
	else
		return va_arg(*ap, int);
  80041c:	8b 10                	mov    (%eax),%edx
  80041e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800421:	89 08                	mov    %ecx,(%eax)
  800423:	8b 02                	mov    (%edx),%eax
  800425:	89 c2                	mov    %eax,%edx
  800427:	c1 fa 1f             	sar    $0x1f,%edx
}
  80042a:	5d                   	pop    %ebp
  80042b:	c3                   	ret    

0080042c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800432:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800436:	8b 10                	mov    (%eax),%edx
  800438:	3b 50 04             	cmp    0x4(%eax),%edx
  80043b:	73 0a                	jae    800447 <sprintputch+0x1b>
		*b->buf++ = ch;
  80043d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800440:	88 0a                	mov    %cl,(%edx)
  800442:	83 c2 01             	add    $0x1,%edx
  800445:	89 10                	mov    %edx,(%eax)
}
  800447:	5d                   	pop    %ebp
  800448:	c3                   	ret    

00800449 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800449:	55                   	push   %ebp
  80044a:	89 e5                	mov    %esp,%ebp
  80044c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80044f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800452:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800456:	8b 45 10             	mov    0x10(%ebp),%eax
  800459:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800460:	89 44 24 04          	mov    %eax,0x4(%esp)
  800464:	8b 45 08             	mov    0x8(%ebp),%eax
  800467:	89 04 24             	mov    %eax,(%esp)
  80046a:	e8 02 00 00 00       	call   800471 <vprintfmt>
	va_end(ap);
}
  80046f:	c9                   	leave  
  800470:	c3                   	ret    

00800471 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800471:	55                   	push   %ebp
  800472:	89 e5                	mov    %esp,%ebp
  800474:	57                   	push   %edi
  800475:	56                   	push   %esi
  800476:	53                   	push   %ebx
  800477:	83 ec 4c             	sub    $0x4c,%esp
  80047a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80047d:	eb 23                	jmp    8004a2 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80047f:	85 c0                	test   %eax,%eax
  800481:	75 12                	jne    800495 <vprintfmt+0x24>
				csa = 0x0700;
  800483:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80048a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80048d:	83 c4 4c             	add    $0x4c,%esp
  800490:	5b                   	pop    %ebx
  800491:	5e                   	pop    %esi
  800492:	5f                   	pop    %edi
  800493:	5d                   	pop    %ebp
  800494:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800495:	8b 55 0c             	mov    0xc(%ebp),%edx
  800498:	89 54 24 04          	mov    %edx,0x4(%esp)
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a2:	0f b6 07             	movzbl (%edi),%eax
  8004a5:	83 c7 01             	add    $0x1,%edi
  8004a8:	83 f8 25             	cmp    $0x25,%eax
  8004ab:	75 d2                	jne    80047f <vprintfmt+0xe>
  8004ad:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8004b1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004b8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8004bd:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004c4:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004c9:	be 00 00 00 00       	mov    $0x0,%esi
  8004ce:	eb 14                	jmp    8004e4 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8004d4:	eb 0e                	jmp    8004e4 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d6:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8004da:	eb 08                	jmp    8004e4 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004dc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004df:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	0f b6 07             	movzbl (%edi),%eax
  8004e7:	0f b6 c8             	movzbl %al,%ecx
  8004ea:	83 c7 01             	add    $0x1,%edi
  8004ed:	83 e8 23             	sub    $0x23,%eax
  8004f0:	3c 55                	cmp    $0x55,%al
  8004f2:	0f 87 ed 02 00 00    	ja     8007e5 <vprintfmt+0x374>
  8004f8:	0f b6 c0             	movzbl %al,%eax
  8004fb:	ff 24 85 a0 14 80 00 	jmp    *0x8014a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800502:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  800505:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800508:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80050b:	83 f9 09             	cmp    $0x9,%ecx
  80050e:	77 3c                	ja     80054c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800510:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800513:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  800516:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  80051a:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80051d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800520:	83 f9 09             	cmp    $0x9,%ecx
  800523:	76 eb                	jbe    800510 <vprintfmt+0x9f>
  800525:	eb 25                	jmp    80054c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8d 48 04             	lea    0x4(%eax),%ecx
  80052d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800530:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  800532:	eb 18                	jmp    80054c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  800534:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800538:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053b:	0f 48 c6             	cmovs  %esi,%eax
  80053e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800541:	eb a1                	jmp    8004e4 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  800543:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80054a:	eb 98                	jmp    8004e4 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  80054c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800550:	79 92                	jns    8004e4 <vprintfmt+0x73>
  800552:	eb 88                	jmp    8004dc <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800554:	83 c2 01             	add    $0x1,%edx
  800557:	eb 8b                	jmp    8004e4 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 50 04             	lea    0x4(%eax),%edx
  80055f:	89 55 14             	mov    %edx,0x14(%ebp)
  800562:	8b 55 0c             	mov    0xc(%ebp),%edx
  800565:	89 54 24 04          	mov    %edx,0x4(%esp)
  800569:	8b 00                	mov    (%eax),%eax
  80056b:	89 04 24             	mov    %eax,(%esp)
  80056e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800571:	e9 2c ff ff ff       	jmp    8004a2 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 c2                	mov    %eax,%edx
  800583:	c1 fa 1f             	sar    $0x1f,%edx
  800586:	31 d0                	xor    %edx,%eax
  800588:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80058a:	83 f8 08             	cmp    $0x8,%eax
  80058d:	7f 0b                	jg     80059a <vprintfmt+0x129>
  80058f:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  800596:	85 d2                	test   %edx,%edx
  800598:	75 23                	jne    8005bd <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80059a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80059e:	c7 44 24 08 ee 13 80 	movl   $0x8013ee,0x8(%esp)
  8005a5:	00 
  8005a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	e8 91 fe ff ff       	call   800449 <printfmt>
  8005b8:	e9 e5 fe ff ff       	jmp    8004a2 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8005bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c1:	c7 44 24 08 f7 13 80 	movl   $0x8013f7,0x8(%esp)
  8005c8:	00 
  8005c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005d3:	89 1c 24             	mov    %ebx,(%esp)
  8005d6:	e8 6e fe ff ff       	call   800449 <printfmt>
  8005db:	e9 c2 fe ff ff       	jmp    8004a2 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 50 04             	lea    0x4(%eax),%edx
  8005ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f2:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005f4:	85 f6                	test   %esi,%esi
  8005f6:	ba e7 13 80 00       	mov    $0x8013e7,%edx
  8005fb:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800602:	7e 06                	jle    80060a <vprintfmt+0x199>
  800604:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800608:	75 13                	jne    80061d <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060a:	0f be 06             	movsbl (%esi),%eax
  80060d:	83 c6 01             	add    $0x1,%esi
  800610:	85 c0                	test   %eax,%eax
  800612:	0f 85 a2 00 00 00    	jne    8006ba <vprintfmt+0x249>
  800618:	e9 92 00 00 00       	jmp    8006af <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800621:	89 34 24             	mov    %esi,(%esp)
  800624:	e8 82 02 00 00       	call   8008ab <strnlen>
  800629:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80062c:	29 c2                	sub    %eax,%edx
  80062e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800631:	85 d2                	test   %edx,%edx
  800633:	7e d5                	jle    80060a <vprintfmt+0x199>
					putch(padc, putdat);
  800635:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800639:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80063c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80063f:	89 d3                	mov    %edx,%ebx
  800641:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800644:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800647:	89 c6                	mov    %eax,%esi
  800649:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064d:	89 34 24             	mov    %esi,(%esp)
  800650:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800653:	83 eb 01             	sub    $0x1,%ebx
  800656:	85 db                	test   %ebx,%ebx
  800658:	7f ef                	jg     800649 <vprintfmt+0x1d8>
  80065a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80065d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800660:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800663:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80066a:	eb 9e                	jmp    80060a <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80066c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800670:	74 1b                	je     80068d <vprintfmt+0x21c>
  800672:	8d 50 e0             	lea    -0x20(%eax),%edx
  800675:	83 fa 5e             	cmp    $0x5e,%edx
  800678:	76 13                	jbe    80068d <vprintfmt+0x21c>
					putch('?', putdat);
  80067a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80067d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800681:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800688:	ff 55 08             	call   *0x8(%ebp)
  80068b:	eb 0d                	jmp    80069a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80068d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800690:	89 54 24 04          	mov    %edx,0x4(%esp)
  800694:	89 04 24             	mov    %eax,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069a:	83 ef 01             	sub    $0x1,%edi
  80069d:	0f be 06             	movsbl (%esi),%eax
  8006a0:	85 c0                	test   %eax,%eax
  8006a2:	74 05                	je     8006a9 <vprintfmt+0x238>
  8006a4:	83 c6 01             	add    $0x1,%esi
  8006a7:	eb 17                	jmp    8006c0 <vprintfmt+0x24f>
  8006a9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006ac:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b3:	7f 1c                	jg     8006d1 <vprintfmt+0x260>
  8006b5:	e9 e8 fd ff ff       	jmp    8004a2 <vprintfmt+0x31>
  8006ba:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8006bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c0:	85 db                	test   %ebx,%ebx
  8006c2:	78 a8                	js     80066c <vprintfmt+0x1fb>
  8006c4:	83 eb 01             	sub    $0x1,%ebx
  8006c7:	79 a3                	jns    80066c <vprintfmt+0x1fb>
  8006c9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006cc:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006cf:	eb de                	jmp    8006af <vprintfmt+0x23e>
  8006d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d7:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006e5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e7:	83 eb 01             	sub    $0x1,%ebx
  8006ea:	85 db                	test   %ebx,%ebx
  8006ec:	7f ec                	jg     8006da <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ee:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f1:	e9 ac fd ff ff       	jmp    8004a2 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f9:	e8 f4 fc ff ff       	call   8003f2 <getint>
  8006fe:	89 c3                	mov    %eax,%ebx
  800700:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800702:	85 d2                	test   %edx,%edx
  800704:	78 0a                	js     800710 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800706:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80070b:	e9 87 00 00 00       	jmp    800797 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800710:	8b 45 0c             	mov    0xc(%ebp),%eax
  800713:	89 44 24 04          	mov    %eax,0x4(%esp)
  800717:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80071e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800721:	89 d8                	mov    %ebx,%eax
  800723:	89 f2                	mov    %esi,%edx
  800725:	f7 d8                	neg    %eax
  800727:	83 d2 00             	adc    $0x0,%edx
  80072a:	f7 da                	neg    %edx
			}
			base = 10;
  80072c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800731:	eb 64                	jmp    800797 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
  800736:	e8 7d fc ff ff       	call   8003b8 <getuint>
			base = 10;
  80073b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800740:	eb 55                	jmp    800797 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800742:	8d 45 14             	lea    0x14(%ebp),%eax
  800745:	e8 6e fc ff ff       	call   8003b8 <getuint>
      base = 8;
  80074a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80074f:	eb 46                	jmp    800797 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800751:	8b 55 0c             	mov    0xc(%ebp),%edx
  800754:	89 54 24 04          	mov    %edx,0x4(%esp)
  800758:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80075f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800762:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800765:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800769:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800770:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	8d 50 04             	lea    0x4(%eax),%edx
  800779:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077c:	8b 00                	mov    (%eax),%eax
  80077e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800783:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800788:	eb 0d                	jmp    800797 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
  80078d:	e8 26 fc ff ff       	call   8003b8 <getuint>
			base = 16;
  800792:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800797:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80079b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80079f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007a6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007aa:	89 04 24             	mov    %eax,(%esp)
  8007ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	e8 14 fb ff ff       	call   8002d0 <printnum>
			break;
  8007bc:	e9 e1 fc ff ff       	jmp    8004a2 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c8:	89 0c 24             	mov    %ecx,(%esp)
  8007cb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007ce:	e9 cf fc ff ff       	jmp    8004a2 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  8007d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d6:	e8 17 fc ff ff       	call   8003f2 <getint>
			csa = num;
  8007db:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  8007e0:	e9 bd fc ff ff       	jmp    8004a2 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ec:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007f3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f6:	83 ef 01             	sub    $0x1,%edi
  8007f9:	eb 02                	jmp    8007fd <vprintfmt+0x38c>
  8007fb:	89 c7                	mov    %eax,%edi
  8007fd:	8d 47 ff             	lea    -0x1(%edi),%eax
  800800:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800804:	75 f5                	jne    8007fb <vprintfmt+0x38a>
  800806:	e9 97 fc ff ff       	jmp    8004a2 <vprintfmt+0x31>

0080080b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	83 ec 28             	sub    $0x28,%esp
  800811:	8b 45 08             	mov    0x8(%ebp),%eax
  800814:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800817:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80081a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800821:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800828:	85 c0                	test   %eax,%eax
  80082a:	74 30                	je     80085c <vsnprintf+0x51>
  80082c:	85 d2                	test   %edx,%edx
  80082e:	7e 2c                	jle    80085c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800830:	8b 45 14             	mov    0x14(%ebp),%eax
  800833:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800837:	8b 45 10             	mov    0x10(%ebp),%eax
  80083a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800841:	89 44 24 04          	mov    %eax,0x4(%esp)
  800845:	c7 04 24 2c 04 80 00 	movl   $0x80042c,(%esp)
  80084c:	e8 20 fc ff ff       	call   800471 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800851:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800854:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800857:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085a:	eb 05                	jmp    800861 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80085c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800861:	c9                   	leave  
  800862:	c3                   	ret    

00800863 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800869:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800870:	8b 45 10             	mov    0x10(%ebp),%eax
  800873:	89 44 24 08          	mov    %eax,0x8(%esp)
  800877:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	89 04 24             	mov    %eax,(%esp)
  800884:	e8 82 ff ff ff       	call   80080b <vsnprintf>
	va_end(ap);

	return rc;
}
  800889:	c9                   	leave  
  80088a:	c3                   	ret    
  80088b:	00 00                	add    %al,(%eax)
  80088d:	00 00                	add    %al,(%eax)
	...

00800890 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
  80089b:	80 3a 00             	cmpb   $0x0,(%edx)
  80089e:	74 09                	je     8008a9 <strlen+0x19>
		n++;
  8008a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a7:	75 f7                	jne    8008a0 <strlen+0x10>
		n++;
	return n;
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b9:	85 d2                	test   %edx,%edx
  8008bb:	74 12                	je     8008cf <strnlen+0x24>
  8008bd:	80 39 00             	cmpb   $0x0,(%ecx)
  8008c0:	74 0d                	je     8008cf <strnlen+0x24>
		n++;
  8008c2:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c5:	39 d0                	cmp    %edx,%eax
  8008c7:	74 06                	je     8008cf <strnlen+0x24>
  8008c9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008cd:	75 f3                	jne    8008c2 <strnlen+0x17>
		n++;
	return n;
}
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	53                   	push   %ebx
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008db:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008e4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008e7:	83 c2 01             	add    $0x1,%edx
  8008ea:	84 c9                	test   %cl,%cl
  8008ec:	75 f2                	jne    8008e0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ee:	5b                   	pop    %ebx
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	53                   	push   %ebx
  8008f5:	83 ec 08             	sub    $0x8,%esp
  8008f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008fb:	89 1c 24             	mov    %ebx,(%esp)
  8008fe:	e8 8d ff ff ff       	call   800890 <strlen>
	strcpy(dst + len, src);
  800903:	8b 55 0c             	mov    0xc(%ebp),%edx
  800906:	89 54 24 04          	mov    %edx,0x4(%esp)
  80090a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80090d:	89 04 24             	mov    %eax,(%esp)
  800910:	e8 bc ff ff ff       	call   8008d1 <strcpy>
	return dst;
}
  800915:	89 d8                	mov    %ebx,%eax
  800917:	83 c4 08             	add    $0x8,%esp
  80091a:	5b                   	pop    %ebx
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	56                   	push   %esi
  800921:	53                   	push   %ebx
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	8b 55 0c             	mov    0xc(%ebp),%edx
  800928:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092b:	85 f6                	test   %esi,%esi
  80092d:	74 18                	je     800947 <strncpy+0x2a>
  80092f:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800934:	0f b6 1a             	movzbl (%edx),%ebx
  800937:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80093a:	80 3a 01             	cmpb   $0x1,(%edx)
  80093d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800940:	83 c1 01             	add    $0x1,%ecx
  800943:	39 ce                	cmp    %ecx,%esi
  800945:	77 ed                	ja     800934 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800947:	5b                   	pop    %ebx
  800948:	5e                   	pop    %esi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	8b 75 08             	mov    0x8(%ebp),%esi
  800953:	8b 55 0c             	mov    0xc(%ebp),%edx
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800959:	89 f0                	mov    %esi,%eax
  80095b:	85 c9                	test   %ecx,%ecx
  80095d:	74 23                	je     800982 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  80095f:	83 e9 01             	sub    $0x1,%ecx
  800962:	74 1b                	je     80097f <strlcpy+0x34>
  800964:	0f b6 1a             	movzbl (%edx),%ebx
  800967:	84 db                	test   %bl,%bl
  800969:	74 14                	je     80097f <strlcpy+0x34>
			*dst++ = *src++;
  80096b:	88 18                	mov    %bl,(%eax)
  80096d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800970:	83 e9 01             	sub    $0x1,%ecx
  800973:	74 0a                	je     80097f <strlcpy+0x34>
			*dst++ = *src++;
  800975:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800978:	0f b6 1a             	movzbl (%edx),%ebx
  80097b:	84 db                	test   %bl,%bl
  80097d:	75 ec                	jne    80096b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80097f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800982:	29 f0                	sub    %esi,%eax
}
  800984:	5b                   	pop    %ebx
  800985:	5e                   	pop    %esi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800991:	0f b6 01             	movzbl (%ecx),%eax
  800994:	84 c0                	test   %al,%al
  800996:	74 15                	je     8009ad <strcmp+0x25>
  800998:	3a 02                	cmp    (%edx),%al
  80099a:	75 11                	jne    8009ad <strcmp+0x25>
		p++, q++;
  80099c:	83 c1 01             	add    $0x1,%ecx
  80099f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a2:	0f b6 01             	movzbl (%ecx),%eax
  8009a5:	84 c0                	test   %al,%al
  8009a7:	74 04                	je     8009ad <strcmp+0x25>
  8009a9:	3a 02                	cmp    (%edx),%al
  8009ab:	74 ef                	je     80099c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ad:	0f b6 c0             	movzbl %al,%eax
  8009b0:	0f b6 12             	movzbl (%edx),%edx
  8009b3:	29 d0                	sub    %edx,%eax
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	53                   	push   %ebx
  8009bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009c1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c9:	85 d2                	test   %edx,%edx
  8009cb:	74 28                	je     8009f5 <strncmp+0x3e>
  8009cd:	0f b6 01             	movzbl (%ecx),%eax
  8009d0:	84 c0                	test   %al,%al
  8009d2:	74 24                	je     8009f8 <strncmp+0x41>
  8009d4:	3a 03                	cmp    (%ebx),%al
  8009d6:	75 20                	jne    8009f8 <strncmp+0x41>
  8009d8:	83 ea 01             	sub    $0x1,%edx
  8009db:	74 13                	je     8009f0 <strncmp+0x39>
		n--, p++, q++;
  8009dd:	83 c1 01             	add    $0x1,%ecx
  8009e0:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e3:	0f b6 01             	movzbl (%ecx),%eax
  8009e6:	84 c0                	test   %al,%al
  8009e8:	74 0e                	je     8009f8 <strncmp+0x41>
  8009ea:	3a 03                	cmp    (%ebx),%al
  8009ec:	74 ea                	je     8009d8 <strncmp+0x21>
  8009ee:	eb 08                	jmp    8009f8 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009f5:	5b                   	pop    %ebx
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f8:	0f b6 01             	movzbl (%ecx),%eax
  8009fb:	0f b6 13             	movzbl (%ebx),%edx
  8009fe:	29 d0                	sub    %edx,%eax
  800a00:	eb f3                	jmp    8009f5 <strncmp+0x3e>

00800a02 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0c:	0f b6 10             	movzbl (%eax),%edx
  800a0f:	84 d2                	test   %dl,%dl
  800a11:	74 20                	je     800a33 <strchr+0x31>
		if (*s == c)
  800a13:	38 ca                	cmp    %cl,%dl
  800a15:	75 0b                	jne    800a22 <strchr+0x20>
  800a17:	eb 1f                	jmp    800a38 <strchr+0x36>
  800a19:	38 ca                	cmp    %cl,%dl
  800a1b:	90                   	nop
  800a1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a20:	74 16                	je     800a38 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a22:	83 c0 01             	add    $0x1,%eax
  800a25:	0f b6 10             	movzbl (%eax),%edx
  800a28:	84 d2                	test   %dl,%dl
  800a2a:	75 ed                	jne    800a19 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a31:	eb 05                	jmp    800a38 <strchr+0x36>
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a44:	0f b6 10             	movzbl (%eax),%edx
  800a47:	84 d2                	test   %dl,%dl
  800a49:	74 14                	je     800a5f <strfind+0x25>
		if (*s == c)
  800a4b:	38 ca                	cmp    %cl,%dl
  800a4d:	75 06                	jne    800a55 <strfind+0x1b>
  800a4f:	eb 0e                	jmp    800a5f <strfind+0x25>
  800a51:	38 ca                	cmp    %cl,%dl
  800a53:	74 0a                	je     800a5f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a55:	83 c0 01             	add    $0x1,%eax
  800a58:	0f b6 10             	movzbl (%eax),%edx
  800a5b:	84 d2                	test   %dl,%dl
  800a5d:	75 f2                	jne    800a51 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	83 ec 0c             	sub    $0xc,%esp
  800a67:	89 1c 24             	mov    %ebx,(%esp)
  800a6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a6e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a72:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a78:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a7b:	85 c9                	test   %ecx,%ecx
  800a7d:	74 30                	je     800aaf <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a85:	75 25                	jne    800aac <memset+0x4b>
  800a87:	f6 c1 03             	test   $0x3,%cl
  800a8a:	75 20                	jne    800aac <memset+0x4b>
		c &= 0xFF;
  800a8c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a8f:	89 d3                	mov    %edx,%ebx
  800a91:	c1 e3 08             	shl    $0x8,%ebx
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	c1 e6 18             	shl    $0x18,%esi
  800a99:	89 d0                	mov    %edx,%eax
  800a9b:	c1 e0 10             	shl    $0x10,%eax
  800a9e:	09 f0                	or     %esi,%eax
  800aa0:	09 d0                	or     %edx,%eax
  800aa2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aa4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aa7:	fc                   	cld    
  800aa8:	f3 ab                	rep stos %eax,%es:(%edi)
  800aaa:	eb 03                	jmp    800aaf <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aac:	fc                   	cld    
  800aad:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aaf:	89 f8                	mov    %edi,%eax
  800ab1:	8b 1c 24             	mov    (%esp),%ebx
  800ab4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ab8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800abc:	89 ec                	mov    %ebp,%esp
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	83 ec 08             	sub    $0x8,%esp
  800ac6:	89 34 24             	mov    %esi,(%esp)
  800ac9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ad6:	39 c6                	cmp    %eax,%esi
  800ad8:	73 36                	jae    800b10 <memmove+0x50>
  800ada:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800add:	39 d0                	cmp    %edx,%eax
  800adf:	73 2f                	jae    800b10 <memmove+0x50>
		s += n;
		d += n;
  800ae1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae4:	f6 c2 03             	test   $0x3,%dl
  800ae7:	75 1b                	jne    800b04 <memmove+0x44>
  800ae9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aef:	75 13                	jne    800b04 <memmove+0x44>
  800af1:	f6 c1 03             	test   $0x3,%cl
  800af4:	75 0e                	jne    800b04 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af6:	83 ef 04             	sub    $0x4,%edi
  800af9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800afc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aff:	fd                   	std    
  800b00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b02:	eb 09                	jmp    800b0d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b04:	83 ef 01             	sub    $0x1,%edi
  800b07:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b0a:	fd                   	std    
  800b0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b0d:	fc                   	cld    
  800b0e:	eb 20                	jmp    800b30 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b10:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b16:	75 13                	jne    800b2b <memmove+0x6b>
  800b18:	a8 03                	test   $0x3,%al
  800b1a:	75 0f                	jne    800b2b <memmove+0x6b>
  800b1c:	f6 c1 03             	test   $0x3,%cl
  800b1f:	75 0a                	jne    800b2b <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b21:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b24:	89 c7                	mov    %eax,%edi
  800b26:	fc                   	cld    
  800b27:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b29:	eb 05                	jmp    800b30 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b2b:	89 c7                	mov    %eax,%edi
  800b2d:	fc                   	cld    
  800b2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b30:	8b 34 24             	mov    (%esp),%esi
  800b33:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b37:	89 ec                	mov    %ebp,%esp
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b41:	8b 45 10             	mov    0x10(%ebp),%eax
  800b44:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b52:	89 04 24             	mov    %eax,(%esp)
  800b55:	e8 66 ff ff ff       	call   800ac0 <memmove>
}
  800b5a:	c9                   	leave  
  800b5b:	c3                   	ret    

00800b5c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b68:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b70:	85 ff                	test   %edi,%edi
  800b72:	74 38                	je     800bac <memcmp+0x50>
		if (*s1 != *s2)
  800b74:	0f b6 03             	movzbl (%ebx),%eax
  800b77:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7a:	83 ef 01             	sub    $0x1,%edi
  800b7d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b82:	38 c8                	cmp    %cl,%al
  800b84:	74 1d                	je     800ba3 <memcmp+0x47>
  800b86:	eb 11                	jmp    800b99 <memcmp+0x3d>
  800b88:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b8d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800b92:	83 c2 01             	add    $0x1,%edx
  800b95:	38 c8                	cmp    %cl,%al
  800b97:	74 0a                	je     800ba3 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800b99:	0f b6 c0             	movzbl %al,%eax
  800b9c:	0f b6 c9             	movzbl %cl,%ecx
  800b9f:	29 c8                	sub    %ecx,%eax
  800ba1:	eb 09                	jmp    800bac <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba3:	39 fa                	cmp    %edi,%edx
  800ba5:	75 e1                	jne    800b88 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bb7:	89 c2                	mov    %eax,%edx
  800bb9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bbc:	39 d0                	cmp    %edx,%eax
  800bbe:	73 15                	jae    800bd5 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800bc4:	38 08                	cmp    %cl,(%eax)
  800bc6:	75 06                	jne    800bce <memfind+0x1d>
  800bc8:	eb 0b                	jmp    800bd5 <memfind+0x24>
  800bca:	38 08                	cmp    %cl,(%eax)
  800bcc:	74 07                	je     800bd5 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bce:	83 c0 01             	add    $0x1,%eax
  800bd1:	39 c2                	cmp    %eax,%edx
  800bd3:	77 f5                	ja     800bca <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800be0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be3:	0f b6 02             	movzbl (%edx),%eax
  800be6:	3c 20                	cmp    $0x20,%al
  800be8:	74 04                	je     800bee <strtol+0x17>
  800bea:	3c 09                	cmp    $0x9,%al
  800bec:	75 0e                	jne    800bfc <strtol+0x25>
		s++;
  800bee:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf1:	0f b6 02             	movzbl (%edx),%eax
  800bf4:	3c 20                	cmp    $0x20,%al
  800bf6:	74 f6                	je     800bee <strtol+0x17>
  800bf8:	3c 09                	cmp    $0x9,%al
  800bfa:	74 f2                	je     800bee <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bfc:	3c 2b                	cmp    $0x2b,%al
  800bfe:	75 0a                	jne    800c0a <strtol+0x33>
		s++;
  800c00:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c03:	bf 00 00 00 00       	mov    $0x0,%edi
  800c08:	eb 10                	jmp    800c1a <strtol+0x43>
  800c0a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c0f:	3c 2d                	cmp    $0x2d,%al
  800c11:	75 07                	jne    800c1a <strtol+0x43>
		s++, neg = 1;
  800c13:	83 c2 01             	add    $0x1,%edx
  800c16:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1a:	85 db                	test   %ebx,%ebx
  800c1c:	0f 94 c0             	sete   %al
  800c1f:	74 05                	je     800c26 <strtol+0x4f>
  800c21:	83 fb 10             	cmp    $0x10,%ebx
  800c24:	75 15                	jne    800c3b <strtol+0x64>
  800c26:	80 3a 30             	cmpb   $0x30,(%edx)
  800c29:	75 10                	jne    800c3b <strtol+0x64>
  800c2b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c2f:	75 0a                	jne    800c3b <strtol+0x64>
		s += 2, base = 16;
  800c31:	83 c2 02             	add    $0x2,%edx
  800c34:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c39:	eb 13                	jmp    800c4e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c3b:	84 c0                	test   %al,%al
  800c3d:	74 0f                	je     800c4e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c3f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c44:	80 3a 30             	cmpb   $0x30,(%edx)
  800c47:	75 05                	jne    800c4e <strtol+0x77>
		s++, base = 8;
  800c49:	83 c2 01             	add    $0x1,%edx
  800c4c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c53:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c55:	0f b6 0a             	movzbl (%edx),%ecx
  800c58:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c5b:	80 fb 09             	cmp    $0x9,%bl
  800c5e:	77 08                	ja     800c68 <strtol+0x91>
			dig = *s - '0';
  800c60:	0f be c9             	movsbl %cl,%ecx
  800c63:	83 e9 30             	sub    $0x30,%ecx
  800c66:	eb 1e                	jmp    800c86 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c68:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c6b:	80 fb 19             	cmp    $0x19,%bl
  800c6e:	77 08                	ja     800c78 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c70:	0f be c9             	movsbl %cl,%ecx
  800c73:	83 e9 57             	sub    $0x57,%ecx
  800c76:	eb 0e                	jmp    800c86 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c78:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c7b:	80 fb 19             	cmp    $0x19,%bl
  800c7e:	77 15                	ja     800c95 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800c80:	0f be c9             	movsbl %cl,%ecx
  800c83:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c86:	39 f1                	cmp    %esi,%ecx
  800c88:	7d 0f                	jge    800c99 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800c8a:	83 c2 01             	add    $0x1,%edx
  800c8d:	0f af c6             	imul   %esi,%eax
  800c90:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c93:	eb c0                	jmp    800c55 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c95:	89 c1                	mov    %eax,%ecx
  800c97:	eb 02                	jmp    800c9b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c99:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9f:	74 05                	je     800ca6 <strtol+0xcf>
		*endptr = (char *) s;
  800ca1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca4:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ca6:	89 ca                	mov    %ecx,%edx
  800ca8:	f7 da                	neg    %edx
  800caa:	85 ff                	test   %edi,%edi
  800cac:	0f 45 c2             	cmovne %edx,%eax
}
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	89 1c 24             	mov    %ebx,(%esp)
  800cbd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cc1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 c3                	mov    %eax,%ebx
  800cd2:	89 c7                	mov    %eax,%edi
  800cd4:	89 c6                	mov    %eax,%esi
  800cd6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd8:	8b 1c 24             	mov    (%esp),%ebx
  800cdb:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cdf:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ce3:	89 ec                	mov    %ebp,%esp
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	83 ec 0c             	sub    $0xc,%esp
  800ced:	89 1c 24             	mov    %ebx,(%esp)
  800cf0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cf4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfd:	b8 01 00 00 00       	mov    $0x1,%eax
  800d02:	89 d1                	mov    %edx,%ecx
  800d04:	89 d3                	mov    %edx,%ebx
  800d06:	89 d7                	mov    %edx,%edi
  800d08:	89 d6                	mov    %edx,%esi
  800d0a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d0c:	8b 1c 24             	mov    (%esp),%ebx
  800d0f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d13:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d17:	89 ec                	mov    %ebp,%esp
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	83 ec 38             	sub    $0x38,%esp
  800d21:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d24:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d27:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2f:	b8 03 00 00 00       	mov    $0x3,%eax
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	89 cb                	mov    %ecx,%ebx
  800d39:	89 cf                	mov    %ecx,%edi
  800d3b:	89 ce                	mov    %ecx,%esi
  800d3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7e 28                	jle    800d6b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d43:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d47:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d4e:	00 
  800d4f:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800d56:	00 
  800d57:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5e:	00 
  800d5f:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800d66:	e8 49 f4 ff ff       	call   8001b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d6b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d6e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d71:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d74:	89 ec                	mov    %ebp,%esp
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	83 ec 0c             	sub    $0xc,%esp
  800d7e:	89 1c 24             	mov    %ebx,(%esp)
  800d81:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d85:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d89:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d93:	89 d1                	mov    %edx,%ecx
  800d95:	89 d3                	mov    %edx,%ebx
  800d97:	89 d7                	mov    %edx,%edi
  800d99:	89 d6                	mov    %edx,%esi
  800d9b:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800d9d:	8b 1c 24             	mov    (%esp),%ebx
  800da0:	8b 74 24 04          	mov    0x4(%esp),%esi
  800da4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800da8:	89 ec                	mov    %ebp,%esp
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_yield>:

void
sys_yield(void)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	89 1c 24             	mov    %ebx,(%esp)
  800db5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dc7:	89 d1                	mov    %edx,%ecx
  800dc9:	89 d3                	mov    %edx,%ebx
  800dcb:	89 d7                	mov    %edx,%edi
  800dcd:	89 d6                	mov    %edx,%esi
  800dcf:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dd1:	8b 1c 24             	mov    (%esp),%ebx
  800dd4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dd8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ddc:	89 ec                	mov    %ebp,%esp
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	83 ec 38             	sub    $0x38,%esp
  800de6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dec:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800def:	be 00 00 00 00       	mov    $0x0,%esi
  800df4:	b8 04 00 00 00       	mov    $0x4,%eax
  800df9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dff:	8b 55 08             	mov    0x8(%ebp),%edx
  800e02:	89 f7                	mov    %esi,%edi
  800e04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 28                	jle    800e32 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e15:	00 
  800e16:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800e1d:	00 
  800e1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e25:	00 
  800e26:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800e2d:	e8 82 f3 ff ff       	call   8001b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e32:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e35:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e38:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e3b:	89 ec                	mov    %ebp,%esp
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	83 ec 38             	sub    $0x38,%esp
  800e45:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e48:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e4b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4e:	b8 05 00 00 00       	mov    $0x5,%eax
  800e53:	8b 75 18             	mov    0x18(%ebp),%esi
  800e56:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e64:	85 c0                	test   %eax,%eax
  800e66:	7e 28                	jle    800e90 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e68:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e73:	00 
  800e74:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800e7b:	00 
  800e7c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e83:	00 
  800e84:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800e8b:	e8 24 f3 ff ff       	call   8001b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e90:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e93:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e96:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e99:	89 ec                	mov    %ebp,%esp
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	83 ec 38             	sub    $0x38,%esp
  800ea3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb1:	b8 06 00 00 00       	mov    $0x6,%eax
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	89 df                	mov    %ebx,%edi
  800ebe:	89 de                	mov    %ebx,%esi
  800ec0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	7e 28                	jle    800eee <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eca:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800ed9:	00 
  800eda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee1:	00 
  800ee2:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800ee9:	e8 c6 f2 ff ff       	call   8001b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef7:	89 ec                	mov    %ebp,%esp
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 38             	sub    $0x38,%esp
  800f01:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f04:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f07:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0f:	b8 08 00 00 00       	mov    $0x8,%eax
  800f14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f17:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1a:	89 df                	mov    %ebx,%edi
  800f1c:	89 de                	mov    %ebx,%esi
  800f1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f20:	85 c0                	test   %eax,%eax
  800f22:	7e 28                	jle    800f4c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f28:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f2f:	00 
  800f30:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800f37:	00 
  800f38:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3f:	00 
  800f40:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800f47:	e8 68 f2 ff ff       	call   8001b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f4c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f4f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f52:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f55:	89 ec                	mov    %ebp,%esp
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	83 ec 38             	sub    $0x38,%esp
  800f5f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f62:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f65:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6d:	b8 09 00 00 00       	mov    $0x9,%eax
  800f72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f75:	8b 55 08             	mov    0x8(%ebp),%edx
  800f78:	89 df                	mov    %ebx,%edi
  800f7a:	89 de                	mov    %ebx,%esi
  800f7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	7e 28                	jle    800faa <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f86:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800f95:	00 
  800f96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9d:	00 
  800f9e:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800fa5:	e8 0a f2 ff ff       	call   8001b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800faa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fb0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb3:	89 ec                	mov    %ebp,%esp
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 0c             	sub    $0xc,%esp
  800fbd:	89 1c 24             	mov    %ebx,(%esp)
  800fc0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fc4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc8:	be 00 00 00 00       	mov    $0x0,%esi
  800fcd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fde:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fe0:	8b 1c 24             	mov    (%esp),%ebx
  800fe3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fe7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800feb:	89 ec                	mov    %ebp,%esp
  800fed:	5d                   	pop    %ebp
  800fee:	c3                   	ret    

00800fef <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	83 ec 38             	sub    $0x38,%esp
  800ff5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ff8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ffb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801003:	b8 0c 00 00 00       	mov    $0xc,%eax
  801008:	8b 55 08             	mov    0x8(%ebp),%edx
  80100b:	89 cb                	mov    %ecx,%ebx
  80100d:	89 cf                	mov    %ecx,%edi
  80100f:	89 ce                	mov    %ecx,%esi
  801011:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801013:	85 c0                	test   %eax,%eax
  801015:	7e 28                	jle    80103f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801017:	89 44 24 10          	mov    %eax,0x10(%esp)
  80101b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801022:	00 
  801023:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  80102a:	00 
  80102b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801032:	00 
  801033:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  80103a:	e8 75 f1 ff ff       	call   8001b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80103f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801042:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801045:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801048:	89 ec                	mov    %ebp,%esp
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    

0080104c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  801052:	c7 44 24 08 5b 16 80 	movl   $0x80165b,0x8(%esp)
  801059:	00 
  80105a:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801061:	00 
  801062:	c7 04 24 4f 16 80 00 	movl   $0x80164f,(%esp)
  801069:	e8 46 f1 ff ff       	call   8001b4 <_panic>

0080106e <sfork>:
}

// Challenge!
int
sfork(void)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801074:	c7 44 24 08 5a 16 80 	movl   $0x80165a,0x8(%esp)
  80107b:	00 
  80107c:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801083:	00 
  801084:	c7 04 24 4f 16 80 00 	movl   $0x80164f,(%esp)
  80108b:	e8 24 f1 ff ff       	call   8001b4 <_panic>

00801090 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  801096:	c7 44 24 08 70 16 80 	movl   $0x801670,0x8(%esp)
  80109d:	00 
  80109e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8010a5:	00 
  8010a6:	c7 04 24 89 16 80 00 	movl   $0x801689,(%esp)
  8010ad:	e8 02 f1 ff ff       	call   8001b4 <_panic>

008010b2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  8010b8:	c7 44 24 08 93 16 80 	movl   $0x801693,0x8(%esp)
  8010bf:	00 
  8010c0:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8010c7:	00 
  8010c8:	c7 04 24 89 16 80 00 	movl   $0x801689,(%esp)
  8010cf:	e8 e0 f0 ff ff       	call   8001b4 <_panic>

008010d4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8010da:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  8010e0:	74 17                	je     8010f9 <ipc_find_env+0x25>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010e2:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8010e7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010ea:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010f0:	8b 52 50             	mov    0x50(%edx),%edx
  8010f3:	39 ca                	cmp    %ecx,%edx
  8010f5:	75 14                	jne    80110b <ipc_find_env+0x37>
  8010f7:	eb 05                	jmp    8010fe <ipc_find_env+0x2a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010f9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8010fe:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801101:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801106:	8b 40 40             	mov    0x40(%eax),%eax
  801109:	eb 0e                	jmp    801119 <ipc_find_env+0x45>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80110b:	83 c0 01             	add    $0x1,%eax
  80110e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801113:	75 d2                	jne    8010e7 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801115:	66 b8 00 00          	mov    $0x0,%ax
}
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    
  80111b:	00 00                	add    %al,(%eax)
  80111d:	00 00                	add    %al,(%eax)
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
