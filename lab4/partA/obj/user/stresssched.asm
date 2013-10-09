
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 fb 00 00 00       	call   80012c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 0b 0d 00 00       	call   800d58 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800054:	e8 d3 0f 00 00       	call   80102c <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 2a                	jmp    800091 <umain+0x51>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 25                	je     800091 <umain+0x51>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	6b c6 7c             	imul   $0x7c,%esi,%eax
  800075:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  80007a:	8b 40 50             	mov    0x50(%eax),%eax
  80007d:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800080:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  800086:	bb 00 00 00 00       	mov    $0x0,%ebx
  80008b:	85 c0                	test   %eax,%eax
  80008d:	75 0c                	jne    80009b <umain+0x5b>
  80008f:	eb 18                	jmp    8000a9 <umain+0x69>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  800091:	e8 f6 0c 00 00       	call   800d8c <sys_yield>
		return;
  800096:	e9 89 00 00 00       	jmp    800124 <umain+0xe4>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  80009b:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80009d:	8b 42 50             	mov    0x50(%edx),%eax
  8000a0:	85 c0                	test   %eax,%eax
  8000a2:	75 f7                	jne    80009b <umain+0x5b>
  8000a4:	bb 00 00 00 00       	mov    $0x0,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  8000a9:	e8 de 0c 00 00       	call   800d8c <sys_yield>
		for (j = 0; j < 10000; j++)
  8000ae:	b8 00 00 00 00       	mov    $0x0,%eax
			counter++;
  8000b3:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000b9:	83 c2 01             	add    $0x1,%edx
  8000bc:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000c2:	83 c0 01             	add    $0x1,%eax
  8000c5:	3d 10 27 00 00       	cmp    $0x2710,%eax
  8000ca:	75 e7                	jne    8000b3 <umain+0x73>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000cc:	83 c3 01             	add    $0x1,%ebx
  8000cf:	83 fb 0a             	cmp    $0xa,%ebx
  8000d2:	75 d5                	jne    8000a9 <umain+0x69>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000d4:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d9:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000de:	74 25                	je     800105 <umain+0xc5>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000e0:	a1 04 20 80 00       	mov    0x802004,%eax
  8000e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e9:	c7 44 24 08 e0 12 80 	movl   $0x8012e0,0x8(%esp)
  8000f0:	00 
  8000f1:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000f8:	00 
  8000f9:	c7 04 24 08 13 80 00 	movl   $0x801308,(%esp)
  800100:	e8 8b 00 00 00       	call   800190 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  800105:	a1 08 20 80 00       	mov    0x802008,%eax
  80010a:	8b 50 5c             	mov    0x5c(%eax),%edx
  80010d:	8b 40 48             	mov    0x48(%eax),%eax
  800110:	89 54 24 08          	mov    %edx,0x8(%esp)
  800114:	89 44 24 04          	mov    %eax,0x4(%esp)
  800118:	c7 04 24 1b 13 80 00 	movl   $0x80131b,(%esp)
  80011f:	e8 67 01 00 00       	call   80028b <cprintf>

}
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    
	...

0080012c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	83 ec 18             	sub    $0x18,%esp
  800132:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800135:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800138:	8b 75 08             	mov    0x8(%ebp),%esi
  80013b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80013e:	e8 15 0c 00 00       	call   800d58 <sys_getenvid>
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800150:	a3 08 20 80 00       	mov    %eax,0x802008
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800155:	85 f6                	test   %esi,%esi
  800157:	7e 07                	jle    800160 <libmain+0x34>
		binaryname = argv[0];
  800159:	8b 03                	mov    (%ebx),%eax
  80015b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800160:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800164:	89 34 24             	mov    %esi,(%esp)
  800167:	e8 d4 fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80016c:	e8 0b 00 00 00       	call   80017c <exit>
}
  800171:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800174:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800177:	89 ec                	mov    %ebp,%esp
  800179:	5d                   	pop    %ebp
  80017a:	c3                   	ret    
	...

0080017c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800182:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800189:	e8 6d 0b 00 00       	call   800cfb <sys_env_destroy>
}
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	56                   	push   %esi
  800194:	53                   	push   %ebx
  800195:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001a1:	e8 b2 0b 00 00       	call   800d58 <sys_getenvid>
  8001a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bc:	c7 04 24 44 13 80 00 	movl   $0x801344,(%esp)
  8001c3:	e8 c3 00 00 00       	call   80028b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cf:	89 04 24             	mov    %eax,(%esp)
  8001d2:	e8 53 00 00 00       	call   80022a <vcprintf>
	cprintf("\n");
  8001d7:	c7 04 24 37 13 80 00 	movl   $0x801337,(%esp)
  8001de:	e8 a8 00 00 00       	call   80028b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e3:	cc                   	int3   
  8001e4:	eb fd                	jmp    8001e3 <_panic+0x53>
	...

008001e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	53                   	push   %ebx
  8001ec:	83 ec 14             	sub    $0x14,%esp
  8001ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f2:	8b 03                	mov    (%ebx),%eax
  8001f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001fb:	83 c0 01             	add    $0x1,%eax
  8001fe:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800200:	3d ff 00 00 00       	cmp    $0xff,%eax
  800205:	75 19                	jne    800220 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800207:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80020e:	00 
  80020f:	8d 43 08             	lea    0x8(%ebx),%eax
  800212:	89 04 24             	mov    %eax,(%esp)
  800215:	e8 7a 0a 00 00       	call   800c94 <sys_cputs>
		b->idx = 0;
  80021a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800220:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800224:	83 c4 14             	add    $0x14,%esp
  800227:	5b                   	pop    %ebx
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800233:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023a:	00 00 00 
	b.cnt = 0;
  80023d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800244:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800247:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	89 44 24 08          	mov    %eax,0x8(%esp)
  800255:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025f:	c7 04 24 e8 01 80 00 	movl   $0x8001e8,(%esp)
  800266:	e8 e6 01 00 00       	call   800451 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800271:	89 44 24 04          	mov    %eax,0x4(%esp)
  800275:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027b:	89 04 24             	mov    %eax,(%esp)
  80027e:	e8 11 0a 00 00       	call   800c94 <sys_cputs>

	return b.cnt;
}
  800283:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800291:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800294:	89 44 24 04          	mov    %eax,0x4(%esp)
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
  80029b:	89 04 24             	mov    %eax,(%esp)
  80029e:	e8 87 ff ff ff       	call   80022a <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    
	...

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 4c             	sub    $0x4c,%esp
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	89 d6                	mov    %edx,%esi
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002cd:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d5:	39 d0                	cmp    %edx,%eax
  8002d7:	72 11                	jb     8002ea <printnum+0x3a>
  8002d9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002dc:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8002df:	76 09                	jbe    8002ea <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e1:	83 eb 01             	sub    $0x1,%ebx
  8002e4:	85 db                	test   %ebx,%ebx
  8002e6:	7f 5d                	jg     800345 <printnum+0x95>
  8002e8:	eb 6c                	jmp    800356 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ea:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002ee:	83 eb 01             	sub    $0x1,%ebx
  8002f1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002fc:	8b 44 24 08          	mov    0x8(%esp),%eax
  800300:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800304:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800307:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80030a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800311:	00 
  800312:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800315:	89 14 24             	mov    %edx,(%esp)
  800318:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80031b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80031f:	e8 4c 0d 00 00       	call   801070 <__udivdi3>
  800324:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800327:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80032a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80032e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800332:	89 04 24             	mov    %eax,(%esp)
  800335:	89 54 24 04          	mov    %edx,0x4(%esp)
  800339:	89 f2                	mov    %esi,%edx
  80033b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033e:	e8 6d ff ff ff       	call   8002b0 <printnum>
  800343:	eb 11                	jmp    800356 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800345:	89 74 24 04          	mov    %esi,0x4(%esp)
  800349:	89 3c 24             	mov    %edi,(%esp)
  80034c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034f:	83 eb 01             	sub    $0x1,%ebx
  800352:	85 db                	test   %ebx,%ebx
  800354:	7f ef                	jg     800345 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800356:	89 74 24 04          	mov    %esi,0x4(%esp)
  80035a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80035e:	8b 45 10             	mov    0x10(%ebp),%eax
  800361:	89 44 24 08          	mov    %eax,0x8(%esp)
  800365:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80036c:	00 
  80036d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800370:	89 14 24             	mov    %edx,(%esp)
  800373:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800376:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80037a:	e8 01 0e 00 00       	call   801180 <__umoddi3>
  80037f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800383:	0f be 80 68 13 80 00 	movsbl 0x801368(%eax),%eax
  80038a:	89 04 24             	mov    %eax,(%esp)
  80038d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800390:	83 c4 4c             	add    $0x4c,%esp
  800393:	5b                   	pop    %ebx
  800394:	5e                   	pop    %esi
  800395:	5f                   	pop    %edi
  800396:	5d                   	pop    %ebp
  800397:	c3                   	ret    

00800398 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80039b:	83 fa 01             	cmp    $0x1,%edx
  80039e:	7e 0e                	jle    8003ae <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003a0:	8b 10                	mov    (%eax),%edx
  8003a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a5:	89 08                	mov    %ecx,(%eax)
  8003a7:	8b 02                	mov    (%edx),%eax
  8003a9:	8b 52 04             	mov    0x4(%edx),%edx
  8003ac:	eb 22                	jmp    8003d0 <getuint+0x38>
	else if (lflag)
  8003ae:	85 d2                	test   %edx,%edx
  8003b0:	74 10                	je     8003c2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b2:	8b 10                	mov    (%eax),%edx
  8003b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b7:	89 08                	mov    %ecx,(%eax)
  8003b9:	8b 02                	mov    (%edx),%eax
  8003bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c0:	eb 0e                	jmp    8003d0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c2:	8b 10                	mov    (%eax),%edx
  8003c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c7:	89 08                	mov    %ecx,(%eax)
  8003c9:	8b 02                	mov    (%edx),%eax
  8003cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d5:	83 fa 01             	cmp    $0x1,%edx
  8003d8:	7e 0e                	jle    8003e8 <getint+0x16>
		return va_arg(*ap, long long);
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 02                	mov    (%edx),%eax
  8003e3:	8b 52 04             	mov    0x4(%edx),%edx
  8003e6:	eb 22                	jmp    80040a <getint+0x38>
	else if (lflag)
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	74 10                	je     8003fc <getint+0x2a>
		return va_arg(*ap, long);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 fa 1f             	sar    $0x1f,%edx
  8003fa:	eb 0e                	jmp    80040a <getint+0x38>
	else
		return va_arg(*ap, int);
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800401:	89 08                	mov    %ecx,(%eax)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	89 c2                	mov    %eax,%edx
  800407:	c1 fa 1f             	sar    $0x1f,%edx
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800412:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800416:	8b 10                	mov    (%eax),%edx
  800418:	3b 50 04             	cmp    0x4(%eax),%edx
  80041b:	73 0a                	jae    800427 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800420:	88 0a                	mov    %cl,(%edx)
  800422:	83 c2 01             	add    $0x1,%edx
  800425:	89 10                	mov    %edx,(%eax)
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80042f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800432:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800436:	8b 45 10             	mov    0x10(%ebp),%eax
  800439:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800440:	89 44 24 04          	mov    %eax,0x4(%esp)
  800444:	8b 45 08             	mov    0x8(%ebp),%eax
  800447:	89 04 24             	mov    %eax,(%esp)
  80044a:	e8 02 00 00 00       	call   800451 <vprintfmt>
	va_end(ap);
}
  80044f:	c9                   	leave  
  800450:	c3                   	ret    

00800451 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	57                   	push   %edi
  800455:	56                   	push   %esi
  800456:	53                   	push   %ebx
  800457:	83 ec 4c             	sub    $0x4c,%esp
  80045a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80045d:	eb 23                	jmp    800482 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80045f:	85 c0                	test   %eax,%eax
  800461:	75 12                	jne    800475 <vprintfmt+0x24>
				csa = 0x0700;
  800463:	c7 05 0c 20 80 00 00 	movl   $0x700,0x80200c
  80046a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80046d:	83 c4 4c             	add    $0x4c,%esp
  800470:	5b                   	pop    %ebx
  800471:	5e                   	pop    %esi
  800472:	5f                   	pop    %edi
  800473:	5d                   	pop    %ebp
  800474:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800475:	8b 55 0c             	mov    0xc(%ebp),%edx
  800478:	89 54 24 04          	mov    %edx,0x4(%esp)
  80047c:	89 04 24             	mov    %eax,(%esp)
  80047f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800482:	0f b6 07             	movzbl (%edi),%eax
  800485:	83 c7 01             	add    $0x1,%edi
  800488:	83 f8 25             	cmp    $0x25,%eax
  80048b:	75 d2                	jne    80045f <vprintfmt+0xe>
  80048d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800491:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800498:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80049d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004a4:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004a9:	be 00 00 00 00       	mov    $0x0,%esi
  8004ae:	eb 14                	jmp    8004c4 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  8004b0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8004b4:	eb 0e                	jmp    8004c4 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b6:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8004ba:	eb 08                	jmp    8004c4 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004bc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004bf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	0f b6 07             	movzbl (%edi),%eax
  8004c7:	0f b6 c8             	movzbl %al,%ecx
  8004ca:	83 c7 01             	add    $0x1,%edi
  8004cd:	83 e8 23             	sub    $0x23,%eax
  8004d0:	3c 55                	cmp    $0x55,%al
  8004d2:	0f 87 ed 02 00 00    	ja     8007c5 <vprintfmt+0x374>
  8004d8:	0f b6 c0             	movzbl %al,%eax
  8004db:	ff 24 85 20 14 80 00 	jmp    *0x801420(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  8004e5:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004e8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004eb:	83 f9 09             	cmp    $0x9,%ecx
  8004ee:	77 3c                	ja     80052c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004f3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8004f6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8004fa:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004fd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800500:	83 f9 09             	cmp    $0x9,%ecx
  800503:	76 eb                	jbe    8004f0 <vprintfmt+0x9f>
  800505:	eb 25                	jmp    80052c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800507:	8b 45 14             	mov    0x14(%ebp),%eax
  80050a:	8d 48 04             	lea    0x4(%eax),%ecx
  80050d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800510:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  800512:	eb 18                	jmp    80052c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  800514:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800518:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051b:	0f 48 c6             	cmovs  %esi,%eax
  80051e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800521:	eb a1                	jmp    8004c4 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  800523:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80052a:	eb 98                	jmp    8004c4 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  80052c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800530:	79 92                	jns    8004c4 <vprintfmt+0x73>
  800532:	eb 88                	jmp    8004bc <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800534:	83 c2 01             	add    $0x1,%edx
  800537:	eb 8b                	jmp    8004c4 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 50 04             	lea    0x4(%eax),%edx
  80053f:	89 55 14             	mov    %edx,0x14(%ebp)
  800542:	8b 55 0c             	mov    0xc(%ebp),%edx
  800545:	89 54 24 04          	mov    %edx,0x4(%esp)
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	89 04 24             	mov    %eax,(%esp)
  80054e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800551:	e9 2c ff ff ff       	jmp    800482 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 04             	lea    0x4(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	89 c2                	mov    %eax,%edx
  800563:	c1 fa 1f             	sar    $0x1f,%edx
  800566:	31 d0                	xor    %edx,%eax
  800568:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056a:	83 f8 08             	cmp    $0x8,%eax
  80056d:	7f 0b                	jg     80057a <vprintfmt+0x129>
  80056f:	8b 14 85 80 15 80 00 	mov    0x801580(,%eax,4),%edx
  800576:	85 d2                	test   %edx,%edx
  800578:	75 23                	jne    80059d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80057a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057e:	c7 44 24 08 80 13 80 	movl   $0x801380,0x8(%esp)
  800585:	00 
  800586:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800589:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058d:	8b 45 08             	mov    0x8(%ebp),%eax
  800590:	89 04 24             	mov    %eax,(%esp)
  800593:	e8 91 fe ff ff       	call   800429 <printfmt>
  800598:	e9 e5 fe ff ff       	jmp    800482 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80059d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a1:	c7 44 24 08 89 13 80 	movl   $0x801389,0x8(%esp)
  8005a8:	00 
  8005a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005b3:	89 1c 24             	mov    %ebx,(%esp)
  8005b6:	e8 6e fe ff ff       	call   800429 <printfmt>
  8005bb:	e9 c2 fe ff ff       	jmp    800482 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 50 04             	lea    0x4(%eax),%edx
  8005cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d2:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005d4:	85 f6                	test   %esi,%esi
  8005d6:	ba 79 13 80 00       	mov    $0x801379,%edx
  8005db:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005de:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e2:	7e 06                	jle    8005ea <vprintfmt+0x199>
  8005e4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005e8:	75 13                	jne    8005fd <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ea:	0f be 06             	movsbl (%esi),%eax
  8005ed:	83 c6 01             	add    $0x1,%esi
  8005f0:	85 c0                	test   %eax,%eax
  8005f2:	0f 85 a2 00 00 00    	jne    80069a <vprintfmt+0x249>
  8005f8:	e9 92 00 00 00       	jmp    80068f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800601:	89 34 24             	mov    %esi,(%esp)
  800604:	e8 82 02 00 00       	call   80088b <strnlen>
  800609:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80060c:	29 c2                	sub    %eax,%edx
  80060e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800611:	85 d2                	test   %edx,%edx
  800613:	7e d5                	jle    8005ea <vprintfmt+0x199>
					putch(padc, putdat);
  800615:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800619:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80061c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80061f:	89 d3                	mov    %edx,%ebx
  800621:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800624:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800627:	89 c6                	mov    %eax,%esi
  800629:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062d:	89 34 24             	mov    %esi,(%esp)
  800630:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800633:	83 eb 01             	sub    $0x1,%ebx
  800636:	85 db                	test   %ebx,%ebx
  800638:	7f ef                	jg     800629 <vprintfmt+0x1d8>
  80063a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80063d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800643:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80064a:	eb 9e                	jmp    8005ea <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80064c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800650:	74 1b                	je     80066d <vprintfmt+0x21c>
  800652:	8d 50 e0             	lea    -0x20(%eax),%edx
  800655:	83 fa 5e             	cmp    $0x5e,%edx
  800658:	76 13                	jbe    80066d <vprintfmt+0x21c>
					putch('?', putdat);
  80065a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80065d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800661:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800668:	ff 55 08             	call   *0x8(%ebp)
  80066b:	eb 0d                	jmp    80067a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80066d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800670:	89 54 24 04          	mov    %edx,0x4(%esp)
  800674:	89 04 24             	mov    %eax,(%esp)
  800677:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067a:	83 ef 01             	sub    $0x1,%edi
  80067d:	0f be 06             	movsbl (%esi),%eax
  800680:	85 c0                	test   %eax,%eax
  800682:	74 05                	je     800689 <vprintfmt+0x238>
  800684:	83 c6 01             	add    $0x1,%esi
  800687:	eb 17                	jmp    8006a0 <vprintfmt+0x24f>
  800689:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80068c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800693:	7f 1c                	jg     8006b1 <vprintfmt+0x260>
  800695:	e9 e8 fd ff ff       	jmp    800482 <vprintfmt+0x31>
  80069a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80069d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a0:	85 db                	test   %ebx,%ebx
  8006a2:	78 a8                	js     80064c <vprintfmt+0x1fb>
  8006a4:	83 eb 01             	sub    $0x1,%ebx
  8006a7:	79 a3                	jns    80064c <vprintfmt+0x1fb>
  8006a9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006ac:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006af:	eb de                	jmp    80068f <vprintfmt+0x23e>
  8006b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b7:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006be:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c7:	83 eb 01             	sub    $0x1,%ebx
  8006ca:	85 db                	test   %ebx,%ebx
  8006cc:	7f ec                	jg     8006ba <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ce:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006d1:	e9 ac fd ff ff       	jmp    800482 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d9:	e8 f4 fc ff ff       	call   8003d2 <getint>
  8006de:	89 c3                	mov    %eax,%ebx
  8006e0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8006e2:	85 d2                	test   %edx,%edx
  8006e4:	78 0a                	js     8006f0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006eb:	e9 87 00 00 00       	jmp    800777 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006fe:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800701:	89 d8                	mov    %ebx,%eax
  800703:	89 f2                	mov    %esi,%edx
  800705:	f7 d8                	neg    %eax
  800707:	83 d2 00             	adc    $0x0,%edx
  80070a:	f7 da                	neg    %edx
			}
			base = 10;
  80070c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800711:	eb 64                	jmp    800777 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
  800716:	e8 7d fc ff ff       	call   800398 <getuint>
			base = 10;
  80071b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800720:	eb 55                	jmp    800777 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800722:	8d 45 14             	lea    0x14(%ebp),%eax
  800725:	e8 6e fc ff ff       	call   800398 <getuint>
      base = 8;
  80072a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80072f:	eb 46                	jmp    800777 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800731:	8b 55 0c             	mov    0xc(%ebp),%edx
  800734:	89 54 24 04          	mov    %edx,0x4(%esp)
  800738:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80073f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800742:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800745:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800749:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800750:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8d 50 04             	lea    0x4(%eax),%edx
  800759:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80075c:	8b 00                	mov    (%eax),%eax
  80075e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800763:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800768:	eb 0d                	jmp    800777 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
  80076d:	e8 26 fc ff ff       	call   800398 <getuint>
			base = 16;
  800772:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800777:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80077b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80077f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800782:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800786:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80078a:	89 04 24             	mov    %eax,(%esp)
  80078d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800791:	8b 55 0c             	mov    0xc(%ebp),%edx
  800794:	8b 45 08             	mov    0x8(%ebp),%eax
  800797:	e8 14 fb ff ff       	call   8002b0 <printnum>
			break;
  80079c:	e9 e1 fc ff ff       	jmp    800482 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a8:	89 0c 24             	mov    %ecx,(%esp)
  8007ab:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007ae:	e9 cf fc ff ff       	jmp    800482 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  8007b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b6:	e8 17 fc ff ff       	call   8003d2 <getint>
			csa = num;
  8007bb:	a3 0c 20 80 00       	mov    %eax,0x80200c
			break;
  8007c0:	e9 bd fc ff ff       	jmp    800482 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007cc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007d3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d6:	83 ef 01             	sub    $0x1,%edi
  8007d9:	eb 02                	jmp    8007dd <vprintfmt+0x38c>
  8007db:	89 c7                	mov    %eax,%edi
  8007dd:	8d 47 ff             	lea    -0x1(%edi),%eax
  8007e0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e4:	75 f5                	jne    8007db <vprintfmt+0x38a>
  8007e6:	e9 97 fc ff ff       	jmp    800482 <vprintfmt+0x31>

008007eb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	83 ec 28             	sub    $0x28,%esp
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007fe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800801:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800808:	85 c0                	test   %eax,%eax
  80080a:	74 30                	je     80083c <vsnprintf+0x51>
  80080c:	85 d2                	test   %edx,%edx
  80080e:	7e 2c                	jle    80083c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800817:	8b 45 10             	mov    0x10(%ebp),%eax
  80081a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800821:	89 44 24 04          	mov    %eax,0x4(%esp)
  800825:	c7 04 24 0c 04 80 00 	movl   $0x80040c,(%esp)
  80082c:	e8 20 fc ff ff       	call   800451 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800831:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800834:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083a:	eb 05                	jmp    800841 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800849:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800850:	8b 45 10             	mov    0x10(%ebp),%eax
  800853:	89 44 24 08          	mov    %eax,0x8(%esp)
  800857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	89 04 24             	mov    %eax,(%esp)
  800864:	e8 82 ff ff ff       	call   8007eb <vsnprintf>
	va_end(ap);

	return rc;
}
  800869:	c9                   	leave  
  80086a:	c3                   	ret    
  80086b:	00 00                	add    %al,(%eax)
  80086d:	00 00                	add    %al,(%eax)
	...

00800870 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
  80087b:	80 3a 00             	cmpb   $0x0,(%edx)
  80087e:	74 09                	je     800889 <strlen+0x19>
		n++;
  800880:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800883:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800887:	75 f7                	jne    800880 <strlen+0x10>
		n++;
	return n;
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
  800899:	85 d2                	test   %edx,%edx
  80089b:	74 12                	je     8008af <strnlen+0x24>
  80089d:	80 39 00             	cmpb   $0x0,(%ecx)
  8008a0:	74 0d                	je     8008af <strnlen+0x24>
		n++;
  8008a2:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a5:	39 d0                	cmp    %edx,%eax
  8008a7:	74 06                	je     8008af <strnlen+0x24>
  8008a9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ad:	75 f3                	jne    8008a2 <strnlen+0x17>
		n++;
	return n;
}
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	53                   	push   %ebx
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008c4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008c7:	83 c2 01             	add    $0x1,%edx
  8008ca:	84 c9                	test   %cl,%cl
  8008cc:	75 f2                	jne    8008c0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ce:	5b                   	pop    %ebx
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	53                   	push   %ebx
  8008d5:	83 ec 08             	sub    $0x8,%esp
  8008d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008db:	89 1c 24             	mov    %ebx,(%esp)
  8008de:	e8 8d ff ff ff       	call   800870 <strlen>
	strcpy(dst + len, src);
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ea:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008ed:	89 04 24             	mov    %eax,(%esp)
  8008f0:	e8 bc ff ff ff       	call   8008b1 <strcpy>
	return dst;
}
  8008f5:	89 d8                	mov    %ebx,%eax
  8008f7:	83 c4 08             	add    $0x8,%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	56                   	push   %esi
  800901:	53                   	push   %ebx
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	8b 55 0c             	mov    0xc(%ebp),%edx
  800908:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090b:	85 f6                	test   %esi,%esi
  80090d:	74 18                	je     800927 <strncpy+0x2a>
  80090f:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800914:	0f b6 1a             	movzbl (%edx),%ebx
  800917:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091a:	80 3a 01             	cmpb   $0x1,(%edx)
  80091d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800920:	83 c1 01             	add    $0x1,%ecx
  800923:	39 ce                	cmp    %ecx,%esi
  800925:	77 ed                	ja     800914 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800927:	5b                   	pop    %ebx
  800928:	5e                   	pop    %esi
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	56                   	push   %esi
  80092f:	53                   	push   %ebx
  800930:	8b 75 08             	mov    0x8(%ebp),%esi
  800933:	8b 55 0c             	mov    0xc(%ebp),%edx
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800939:	89 f0                	mov    %esi,%eax
  80093b:	85 c9                	test   %ecx,%ecx
  80093d:	74 23                	je     800962 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  80093f:	83 e9 01             	sub    $0x1,%ecx
  800942:	74 1b                	je     80095f <strlcpy+0x34>
  800944:	0f b6 1a             	movzbl (%edx),%ebx
  800947:	84 db                	test   %bl,%bl
  800949:	74 14                	je     80095f <strlcpy+0x34>
			*dst++ = *src++;
  80094b:	88 18                	mov    %bl,(%eax)
  80094d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800950:	83 e9 01             	sub    $0x1,%ecx
  800953:	74 0a                	je     80095f <strlcpy+0x34>
			*dst++ = *src++;
  800955:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800958:	0f b6 1a             	movzbl (%edx),%ebx
  80095b:	84 db                	test   %bl,%bl
  80095d:	75 ec                	jne    80094b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80095f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800962:	29 f0                	sub    %esi,%eax
}
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800971:	0f b6 01             	movzbl (%ecx),%eax
  800974:	84 c0                	test   %al,%al
  800976:	74 15                	je     80098d <strcmp+0x25>
  800978:	3a 02                	cmp    (%edx),%al
  80097a:	75 11                	jne    80098d <strcmp+0x25>
		p++, q++;
  80097c:	83 c1 01             	add    $0x1,%ecx
  80097f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800982:	0f b6 01             	movzbl (%ecx),%eax
  800985:	84 c0                	test   %al,%al
  800987:	74 04                	je     80098d <strcmp+0x25>
  800989:	3a 02                	cmp    (%edx),%al
  80098b:	74 ef                	je     80097c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80098d:	0f b6 c0             	movzbl %al,%eax
  800990:	0f b6 12             	movzbl (%edx),%edx
  800993:	29 d0                	sub    %edx,%eax
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	53                   	push   %ebx
  80099b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009a1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a9:	85 d2                	test   %edx,%edx
  8009ab:	74 28                	je     8009d5 <strncmp+0x3e>
  8009ad:	0f b6 01             	movzbl (%ecx),%eax
  8009b0:	84 c0                	test   %al,%al
  8009b2:	74 24                	je     8009d8 <strncmp+0x41>
  8009b4:	3a 03                	cmp    (%ebx),%al
  8009b6:	75 20                	jne    8009d8 <strncmp+0x41>
  8009b8:	83 ea 01             	sub    $0x1,%edx
  8009bb:	74 13                	je     8009d0 <strncmp+0x39>
		n--, p++, q++;
  8009bd:	83 c1 01             	add    $0x1,%ecx
  8009c0:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c3:	0f b6 01             	movzbl (%ecx),%eax
  8009c6:	84 c0                	test   %al,%al
  8009c8:	74 0e                	je     8009d8 <strncmp+0x41>
  8009ca:	3a 03                	cmp    (%ebx),%al
  8009cc:	74 ea                	je     8009b8 <strncmp+0x21>
  8009ce:	eb 08                	jmp    8009d8 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009d5:	5b                   	pop    %ebx
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d8:	0f b6 01             	movzbl (%ecx),%eax
  8009db:	0f b6 13             	movzbl (%ebx),%edx
  8009de:	29 d0                	sub    %edx,%eax
  8009e0:	eb f3                	jmp    8009d5 <strncmp+0x3e>

008009e2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ec:	0f b6 10             	movzbl (%eax),%edx
  8009ef:	84 d2                	test   %dl,%dl
  8009f1:	74 20                	je     800a13 <strchr+0x31>
		if (*s == c)
  8009f3:	38 ca                	cmp    %cl,%dl
  8009f5:	75 0b                	jne    800a02 <strchr+0x20>
  8009f7:	eb 1f                	jmp    800a18 <strchr+0x36>
  8009f9:	38 ca                	cmp    %cl,%dl
  8009fb:	90                   	nop
  8009fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a00:	74 16                	je     800a18 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	0f b6 10             	movzbl (%eax),%edx
  800a08:	84 d2                	test   %dl,%dl
  800a0a:	75 ed                	jne    8009f9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a11:	eb 05                	jmp    800a18 <strchr+0x36>
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a24:	0f b6 10             	movzbl (%eax),%edx
  800a27:	84 d2                	test   %dl,%dl
  800a29:	74 14                	je     800a3f <strfind+0x25>
		if (*s == c)
  800a2b:	38 ca                	cmp    %cl,%dl
  800a2d:	75 06                	jne    800a35 <strfind+0x1b>
  800a2f:	eb 0e                	jmp    800a3f <strfind+0x25>
  800a31:	38 ca                	cmp    %cl,%dl
  800a33:	74 0a                	je     800a3f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a35:	83 c0 01             	add    $0x1,%eax
  800a38:	0f b6 10             	movzbl (%eax),%edx
  800a3b:	84 d2                	test   %dl,%dl
  800a3d:	75 f2                	jne    800a31 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	83 ec 0c             	sub    $0xc,%esp
  800a47:	89 1c 24             	mov    %ebx,(%esp)
  800a4a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a4e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a52:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a58:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a5b:	85 c9                	test   %ecx,%ecx
  800a5d:	74 30                	je     800a8f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a65:	75 25                	jne    800a8c <memset+0x4b>
  800a67:	f6 c1 03             	test   $0x3,%cl
  800a6a:	75 20                	jne    800a8c <memset+0x4b>
		c &= 0xFF;
  800a6c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a6f:	89 d3                	mov    %edx,%ebx
  800a71:	c1 e3 08             	shl    $0x8,%ebx
  800a74:	89 d6                	mov    %edx,%esi
  800a76:	c1 e6 18             	shl    $0x18,%esi
  800a79:	89 d0                	mov    %edx,%eax
  800a7b:	c1 e0 10             	shl    $0x10,%eax
  800a7e:	09 f0                	or     %esi,%eax
  800a80:	09 d0                	or     %edx,%eax
  800a82:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a84:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a87:	fc                   	cld    
  800a88:	f3 ab                	rep stos %eax,%es:(%edi)
  800a8a:	eb 03                	jmp    800a8f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a8c:	fc                   	cld    
  800a8d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8f:	89 f8                	mov    %edi,%eax
  800a91:	8b 1c 24             	mov    (%esp),%ebx
  800a94:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a98:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a9c:	89 ec                	mov    %ebp,%esp
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	83 ec 08             	sub    $0x8,%esp
  800aa6:	89 34 24             	mov    %esi,(%esp)
  800aa9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab6:	39 c6                	cmp    %eax,%esi
  800ab8:	73 36                	jae    800af0 <memmove+0x50>
  800aba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800abd:	39 d0                	cmp    %edx,%eax
  800abf:	73 2f                	jae    800af0 <memmove+0x50>
		s += n;
		d += n;
  800ac1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac4:	f6 c2 03             	test   $0x3,%dl
  800ac7:	75 1b                	jne    800ae4 <memmove+0x44>
  800ac9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acf:	75 13                	jne    800ae4 <memmove+0x44>
  800ad1:	f6 c1 03             	test   $0x3,%cl
  800ad4:	75 0e                	jne    800ae4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad6:	83 ef 04             	sub    $0x4,%edi
  800ad9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800adc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800adf:	fd                   	std    
  800ae0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae2:	eb 09                	jmp    800aed <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae4:	83 ef 01             	sub    $0x1,%edi
  800ae7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aea:	fd                   	std    
  800aeb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aed:	fc                   	cld    
  800aee:	eb 20                	jmp    800b10 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af6:	75 13                	jne    800b0b <memmove+0x6b>
  800af8:	a8 03                	test   $0x3,%al
  800afa:	75 0f                	jne    800b0b <memmove+0x6b>
  800afc:	f6 c1 03             	test   $0x3,%cl
  800aff:	75 0a                	jne    800b0b <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b01:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b04:	89 c7                	mov    %eax,%edi
  800b06:	fc                   	cld    
  800b07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b09:	eb 05                	jmp    800b10 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	fc                   	cld    
  800b0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b10:	8b 34 24             	mov    (%esp),%esi
  800b13:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b17:	89 ec                	mov    %ebp,%esp
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b21:	8b 45 10             	mov    0x10(%ebp),%eax
  800b24:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	89 04 24             	mov    %eax,(%esp)
  800b35:	e8 66 ff ff ff       	call   800aa0 <memmove>
}
  800b3a:	c9                   	leave  
  800b3b:	c3                   	ret    

00800b3c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b48:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b50:	85 ff                	test   %edi,%edi
  800b52:	74 38                	je     800b8c <memcmp+0x50>
		if (*s1 != *s2)
  800b54:	0f b6 03             	movzbl (%ebx),%eax
  800b57:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5a:	83 ef 01             	sub    $0x1,%edi
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b62:	38 c8                	cmp    %cl,%al
  800b64:	74 1d                	je     800b83 <memcmp+0x47>
  800b66:	eb 11                	jmp    800b79 <memcmp+0x3d>
  800b68:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b6d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800b72:	83 c2 01             	add    $0x1,%edx
  800b75:	38 c8                	cmp    %cl,%al
  800b77:	74 0a                	je     800b83 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800b79:	0f b6 c0             	movzbl %al,%eax
  800b7c:	0f b6 c9             	movzbl %cl,%ecx
  800b7f:	29 c8                	sub    %ecx,%eax
  800b81:	eb 09                	jmp    800b8c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b83:	39 fa                	cmp    %edi,%edx
  800b85:	75 e1                	jne    800b68 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b97:	89 c2                	mov    %eax,%edx
  800b99:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b9c:	39 d0                	cmp    %edx,%eax
  800b9e:	73 15                	jae    800bb5 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ba4:	38 08                	cmp    %cl,(%eax)
  800ba6:	75 06                	jne    800bae <memfind+0x1d>
  800ba8:	eb 0b                	jmp    800bb5 <memfind+0x24>
  800baa:	38 08                	cmp    %cl,(%eax)
  800bac:	74 07                	je     800bb5 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bae:	83 c0 01             	add    $0x1,%eax
  800bb1:	39 c2                	cmp    %eax,%edx
  800bb3:	77 f5                	ja     800baa <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
  800bbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc3:	0f b6 02             	movzbl (%edx),%eax
  800bc6:	3c 20                	cmp    $0x20,%al
  800bc8:	74 04                	je     800bce <strtol+0x17>
  800bca:	3c 09                	cmp    $0x9,%al
  800bcc:	75 0e                	jne    800bdc <strtol+0x25>
		s++;
  800bce:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd1:	0f b6 02             	movzbl (%edx),%eax
  800bd4:	3c 20                	cmp    $0x20,%al
  800bd6:	74 f6                	je     800bce <strtol+0x17>
  800bd8:	3c 09                	cmp    $0x9,%al
  800bda:	74 f2                	je     800bce <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bdc:	3c 2b                	cmp    $0x2b,%al
  800bde:	75 0a                	jne    800bea <strtol+0x33>
		s++;
  800be0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be3:	bf 00 00 00 00       	mov    $0x0,%edi
  800be8:	eb 10                	jmp    800bfa <strtol+0x43>
  800bea:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bef:	3c 2d                	cmp    $0x2d,%al
  800bf1:	75 07                	jne    800bfa <strtol+0x43>
		s++, neg = 1;
  800bf3:	83 c2 01             	add    $0x1,%edx
  800bf6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bfa:	85 db                	test   %ebx,%ebx
  800bfc:	0f 94 c0             	sete   %al
  800bff:	74 05                	je     800c06 <strtol+0x4f>
  800c01:	83 fb 10             	cmp    $0x10,%ebx
  800c04:	75 15                	jne    800c1b <strtol+0x64>
  800c06:	80 3a 30             	cmpb   $0x30,(%edx)
  800c09:	75 10                	jne    800c1b <strtol+0x64>
  800c0b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c0f:	75 0a                	jne    800c1b <strtol+0x64>
		s += 2, base = 16;
  800c11:	83 c2 02             	add    $0x2,%edx
  800c14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c19:	eb 13                	jmp    800c2e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c1b:	84 c0                	test   %al,%al
  800c1d:	74 0f                	je     800c2e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c1f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c24:	80 3a 30             	cmpb   $0x30,(%edx)
  800c27:	75 05                	jne    800c2e <strtol+0x77>
		s++, base = 8;
  800c29:	83 c2 01             	add    $0x1,%edx
  800c2c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c33:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c35:	0f b6 0a             	movzbl (%edx),%ecx
  800c38:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c3b:	80 fb 09             	cmp    $0x9,%bl
  800c3e:	77 08                	ja     800c48 <strtol+0x91>
			dig = *s - '0';
  800c40:	0f be c9             	movsbl %cl,%ecx
  800c43:	83 e9 30             	sub    $0x30,%ecx
  800c46:	eb 1e                	jmp    800c66 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c48:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c4b:	80 fb 19             	cmp    $0x19,%bl
  800c4e:	77 08                	ja     800c58 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c50:	0f be c9             	movsbl %cl,%ecx
  800c53:	83 e9 57             	sub    $0x57,%ecx
  800c56:	eb 0e                	jmp    800c66 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c58:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c5b:	80 fb 19             	cmp    $0x19,%bl
  800c5e:	77 15                	ja     800c75 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800c60:	0f be c9             	movsbl %cl,%ecx
  800c63:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c66:	39 f1                	cmp    %esi,%ecx
  800c68:	7d 0f                	jge    800c79 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800c6a:	83 c2 01             	add    $0x1,%edx
  800c6d:	0f af c6             	imul   %esi,%eax
  800c70:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c73:	eb c0                	jmp    800c35 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c75:	89 c1                	mov    %eax,%ecx
  800c77:	eb 02                	jmp    800c7b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c79:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c7f:	74 05                	je     800c86 <strtol+0xcf>
		*endptr = (char *) s;
  800c81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c84:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c86:	89 ca                	mov    %ecx,%edx
  800c88:	f7 da                	neg    %edx
  800c8a:	85 ff                	test   %edi,%edi
  800c8c:	0f 45 c2             	cmovne %edx,%eax
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 0c             	sub    $0xc,%esp
  800c9a:	89 1c 24             	mov    %ebx,(%esp)
  800c9d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	b8 00 00 00 00       	mov    $0x0,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	89 c3                	mov    %eax,%ebx
  800cb2:	89 c7                	mov    %eax,%edi
  800cb4:	89 c6                	mov    %eax,%esi
  800cb6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cb8:	8b 1c 24             	mov    (%esp),%ebx
  800cbb:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cbf:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cc3:	89 ec                	mov    %ebp,%esp
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	89 1c 24             	mov    %ebx,(%esp)
  800cd0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce2:	89 d1                	mov    %edx,%ecx
  800ce4:	89 d3                	mov    %edx,%ebx
  800ce6:	89 d7                	mov    %edx,%edi
  800ce8:	89 d6                	mov    %edx,%esi
  800cea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cec:	8b 1c 24             	mov    (%esp),%ebx
  800cef:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cf3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cf7:	89 ec                	mov    %ebp,%esp
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	83 ec 38             	sub    $0x38,%esp
  800d01:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d04:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d07:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0f:	b8 03 00 00 00       	mov    $0x3,%eax
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 cb                	mov    %ecx,%ebx
  800d19:	89 cf                	mov    %ecx,%edi
  800d1b:	89 ce                	mov    %ecx,%esi
  800d1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 28                	jle    800d4b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d27:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d2e:	00 
  800d2f:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  800d36:	00 
  800d37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3e:	00 
  800d3f:	c7 04 24 c1 15 80 00 	movl   $0x8015c1,(%esp)
  800d46:	e8 45 f4 ff ff       	call   800190 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d4b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d4e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d51:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d54:	89 ec                	mov    %ebp,%esp
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	83 ec 0c             	sub    $0xc,%esp
  800d5e:	89 1c 24             	mov    %ebx,(%esp)
  800d61:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d65:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d73:	89 d1                	mov    %edx,%ecx
  800d75:	89 d3                	mov    %edx,%ebx
  800d77:	89 d7                	mov    %edx,%edi
  800d79:	89 d6                	mov    %edx,%esi
  800d7b:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800d7d:	8b 1c 24             	mov    (%esp),%ebx
  800d80:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d84:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d88:	89 ec                	mov    %ebp,%esp
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_yield>:

void
sys_yield(void)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	89 1c 24             	mov    %ebx,(%esp)
  800d95:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d99:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800da2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da7:	89 d1                	mov    %edx,%ecx
  800da9:	89 d3                	mov    %edx,%ebx
  800dab:	89 d7                	mov    %edx,%edi
  800dad:	89 d6                	mov    %edx,%esi
  800daf:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800db1:	8b 1c 24             	mov    (%esp),%ebx
  800db4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800db8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dbc:	89 ec                	mov    %ebp,%esp
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	83 ec 38             	sub    $0x38,%esp
  800dc6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dcc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	be 00 00 00 00       	mov    $0x0,%esi
  800dd4:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddf:	8b 55 08             	mov    0x8(%ebp),%edx
  800de2:	89 f7                	mov    %esi,%edi
  800de4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de6:	85 c0                	test   %eax,%eax
  800de8:	7e 28                	jle    800e12 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dee:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800df5:	00 
  800df6:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  800dfd:	00 
  800dfe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e05:	00 
  800e06:	c7 04 24 c1 15 80 00 	movl   $0x8015c1,(%esp)
  800e0d:	e8 7e f3 ff ff       	call   800190 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e1b:	89 ec                	mov    %ebp,%esp
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	83 ec 38             	sub    $0x38,%esp
  800e25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	b8 05 00 00 00       	mov    $0x5,%eax
  800e33:	8b 75 18             	mov    0x18(%ebp),%esi
  800e36:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e44:	85 c0                	test   %eax,%eax
  800e46:	7e 28                	jle    800e70 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e48:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e53:	00 
  800e54:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  800e5b:	00 
  800e5c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e63:	00 
  800e64:	c7 04 24 c1 15 80 00 	movl   $0x8015c1,(%esp)
  800e6b:	e8 20 f3 ff ff       	call   800190 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e70:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e73:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e76:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e79:	89 ec                	mov    %ebp,%esp
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	83 ec 38             	sub    $0x38,%esp
  800e83:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e86:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e89:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e91:	b8 06 00 00 00       	mov    $0x6,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	89 df                	mov    %ebx,%edi
  800e9e:	89 de                	mov    %ebx,%esi
  800ea0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	7e 28                	jle    800ece <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eaa:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800eb1:	00 
  800eb2:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  800eb9:	00 
  800eba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec1:	00 
  800ec2:	c7 04 24 c1 15 80 00 	movl   $0x8015c1,(%esp)
  800ec9:	e8 c2 f2 ff ff       	call   800190 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ece:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed7:	89 ec                	mov    %ebp,%esp
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	83 ec 38             	sub    $0x38,%esp
  800ee1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eef:	b8 08 00 00 00       	mov    $0x8,%eax
  800ef4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef7:	8b 55 08             	mov    0x8(%ebp),%edx
  800efa:	89 df                	mov    %ebx,%edi
  800efc:	89 de                	mov    %ebx,%esi
  800efe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f00:	85 c0                	test   %eax,%eax
  800f02:	7e 28                	jle    800f2c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f04:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f08:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f0f:	00 
  800f10:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  800f17:	00 
  800f18:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1f:	00 
  800f20:	c7 04 24 c1 15 80 00 	movl   $0x8015c1,(%esp)
  800f27:	e8 64 f2 ff ff       	call   800190 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f2c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f2f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f32:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f35:	89 ec                	mov    %ebp,%esp
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	83 ec 38             	sub    $0x38,%esp
  800f3f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f42:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f45:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4d:	b8 09 00 00 00       	mov    $0x9,%eax
  800f52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f55:	8b 55 08             	mov    0x8(%ebp),%edx
  800f58:	89 df                	mov    %ebx,%edi
  800f5a:	89 de                	mov    %ebx,%esi
  800f5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	7e 28                	jle    800f8a <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f62:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f66:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f6d:	00 
  800f6e:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  800f75:	00 
  800f76:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7d:	00 
  800f7e:	c7 04 24 c1 15 80 00 	movl   $0x8015c1,(%esp)
  800f85:	e8 06 f2 ff ff       	call   800190 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f8a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f8d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f90:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f93:	89 ec                	mov    %ebp,%esp
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    

00800f97 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	83 ec 0c             	sub    $0xc,%esp
  800f9d:	89 1c 24             	mov    %ebx,(%esp)
  800fa0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa8:	be 00 00 00 00       	mov    $0x0,%esi
  800fad:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fc0:	8b 1c 24             	mov    (%esp),%ebx
  800fc3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fc7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fcb:	89 ec                	mov    %ebp,%esp
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	83 ec 38             	sub    $0x38,%esp
  800fd5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fdb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fde:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fe8:	8b 55 08             	mov    0x8(%ebp),%edx
  800feb:	89 cb                	mov    %ecx,%ebx
  800fed:	89 cf                	mov    %ecx,%edi
  800fef:	89 ce                	mov    %ecx,%esi
  800ff1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	7e 28                	jle    80101f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ffb:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801002:	00 
  801003:	c7 44 24 08 a4 15 80 	movl   $0x8015a4,0x8(%esp)
  80100a:	00 
  80100b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801012:	00 
  801013:	c7 04 24 c1 15 80 00 	movl   $0x8015c1,(%esp)
  80101a:	e8 71 f1 ff ff       	call   800190 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80101f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801022:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801025:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801028:	89 ec                	mov    %ebp,%esp
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  801032:	c7 44 24 08 db 15 80 	movl   $0x8015db,0x8(%esp)
  801039:	00 
  80103a:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801041:	00 
  801042:	c7 04 24 cf 15 80 00 	movl   $0x8015cf,(%esp)
  801049:	e8 42 f1 ff ff       	call   800190 <_panic>

0080104e <sfork>:
}

// Challenge!
int
sfork(void)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801054:	c7 44 24 08 da 15 80 	movl   $0x8015da,0x8(%esp)
  80105b:	00 
  80105c:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801063:	00 
  801064:	c7 04 24 cf 15 80 00 	movl   $0x8015cf,(%esp)
  80106b:	e8 20 f1 ff ff       	call   800190 <_panic>

00801070 <__udivdi3>:
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	83 ec 10             	sub    $0x10,%esp
  801078:	8b 75 14             	mov    0x14(%ebp),%esi
  80107b:	8b 45 08             	mov    0x8(%ebp),%eax
  80107e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801081:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801084:	85 f6                	test   %esi,%esi
  801086:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801089:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80108c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80108f:	75 2f                	jne    8010c0 <__udivdi3+0x50>
  801091:	39 f9                	cmp    %edi,%ecx
  801093:	77 5b                	ja     8010f0 <__udivdi3+0x80>
  801095:	85 c9                	test   %ecx,%ecx
  801097:	75 0b                	jne    8010a4 <__udivdi3+0x34>
  801099:	b8 01 00 00 00       	mov    $0x1,%eax
  80109e:	31 d2                	xor    %edx,%edx
  8010a0:	f7 f1                	div    %ecx
  8010a2:	89 c1                	mov    %eax,%ecx
  8010a4:	89 f8                	mov    %edi,%eax
  8010a6:	31 d2                	xor    %edx,%edx
  8010a8:	f7 f1                	div    %ecx
  8010aa:	89 c7                	mov    %eax,%edi
  8010ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010af:	f7 f1                	div    %ecx
  8010b1:	89 fa                	mov    %edi,%edx
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	5e                   	pop    %esi
  8010b7:	5f                   	pop    %edi
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    
  8010ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010c0:	31 d2                	xor    %edx,%edx
  8010c2:	31 c0                	xor    %eax,%eax
  8010c4:	39 fe                	cmp    %edi,%esi
  8010c6:	77 eb                	ja     8010b3 <__udivdi3+0x43>
  8010c8:	0f bd d6             	bsr    %esi,%edx
  8010cb:	83 f2 1f             	xor    $0x1f,%edx
  8010ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010d1:	75 2d                	jne    801100 <__udivdi3+0x90>
  8010d3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  8010d6:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  8010d9:	76 06                	jbe    8010e1 <__udivdi3+0x71>
  8010db:	39 fe                	cmp    %edi,%esi
  8010dd:	89 c2                	mov    %eax,%edx
  8010df:	73 d2                	jae    8010b3 <__udivdi3+0x43>
  8010e1:	31 d2                	xor    %edx,%edx
  8010e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e8:	eb c9                	jmp    8010b3 <__udivdi3+0x43>
  8010ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010f0:	89 fa                	mov    %edi,%edx
  8010f2:	f7 f1                	div    %ecx
  8010f4:	31 d2                	xor    %edx,%edx
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	5e                   	pop    %esi
  8010fa:	5f                   	pop    %edi
  8010fb:	5d                   	pop    %ebp
  8010fc:	c3                   	ret    
  8010fd:	8d 76 00             	lea    0x0(%esi),%esi
  801100:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801104:	b8 20 00 00 00       	mov    $0x20,%eax
  801109:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80110c:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80110f:	d3 e6                	shl    %cl,%esi
  801111:	89 c1                	mov    %eax,%ecx
  801113:	d3 ea                	shr    %cl,%edx
  801115:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801119:	09 f2                	or     %esi,%edx
  80111b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  80111e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801121:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801124:	d3 e2                	shl    %cl,%edx
  801126:	89 c1                	mov    %eax,%ecx
  801128:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80112b:	89 fa                	mov    %edi,%edx
  80112d:	d3 ea                	shr    %cl,%edx
  80112f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801133:	d3 e7                	shl    %cl,%edi
  801135:	89 c1                	mov    %eax,%ecx
  801137:	d3 ee                	shr    %cl,%esi
  801139:	09 fe                	or     %edi,%esi
  80113b:	89 f0                	mov    %esi,%eax
  80113d:	f7 75 e8             	divl   -0x18(%ebp)
  801140:	89 d7                	mov    %edx,%edi
  801142:	89 c6                	mov    %eax,%esi
  801144:	f7 65 f0             	mull   -0x10(%ebp)
  801147:	39 d7                	cmp    %edx,%edi
  801149:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80114c:	72 22                	jb     801170 <__udivdi3+0x100>
  80114e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801151:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801155:	d3 e2                	shl    %cl,%edx
  801157:	39 c2                	cmp    %eax,%edx
  801159:	73 05                	jae    801160 <__udivdi3+0xf0>
  80115b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80115e:	74 10                	je     801170 <__udivdi3+0x100>
  801160:	89 f0                	mov    %esi,%eax
  801162:	31 d2                	xor    %edx,%edx
  801164:	e9 4a ff ff ff       	jmp    8010b3 <__udivdi3+0x43>
  801169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801170:	8d 46 ff             	lea    -0x1(%esi),%eax
  801173:	31 d2                	xor    %edx,%edx
  801175:	83 c4 10             	add    $0x10,%esp
  801178:	5e                   	pop    %esi
  801179:	5f                   	pop    %edi
  80117a:	5d                   	pop    %ebp
  80117b:	c3                   	ret    
  80117c:	00 00                	add    %al,(%eax)
	...

00801180 <__umoddi3>:
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	57                   	push   %edi
  801184:	56                   	push   %esi
  801185:	83 ec 20             	sub    $0x20,%esp
  801188:	8b 7d 14             	mov    0x14(%ebp),%edi
  80118b:	8b 45 08             	mov    0x8(%ebp),%eax
  80118e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801191:	8b 75 0c             	mov    0xc(%ebp),%esi
  801194:	85 ff                	test   %edi,%edi
  801196:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801199:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80119c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80119f:	89 f2                	mov    %esi,%edx
  8011a1:	75 15                	jne    8011b8 <__umoddi3+0x38>
  8011a3:	39 f1                	cmp    %esi,%ecx
  8011a5:	76 41                	jbe    8011e8 <__umoddi3+0x68>
  8011a7:	f7 f1                	div    %ecx
  8011a9:	89 d0                	mov    %edx,%eax
  8011ab:	31 d2                	xor    %edx,%edx
  8011ad:	83 c4 20             	add    $0x20,%esp
  8011b0:	5e                   	pop    %esi
  8011b1:	5f                   	pop    %edi
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    
  8011b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b8:	39 f7                	cmp    %esi,%edi
  8011ba:	77 4c                	ja     801208 <__umoddi3+0x88>
  8011bc:	0f bd c7             	bsr    %edi,%eax
  8011bf:	83 f0 1f             	xor    $0x1f,%eax
  8011c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011c5:	75 51                	jne    801218 <__umoddi3+0x98>
  8011c7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8011ca:	0f 87 e8 00 00 00    	ja     8012b8 <__umoddi3+0x138>
  8011d0:	89 f2                	mov    %esi,%edx
  8011d2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011d5:	29 ce                	sub    %ecx,%esi
  8011d7:	19 fa                	sbb    %edi,%edx
  8011d9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8011dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011df:	83 c4 20             	add    $0x20,%esp
  8011e2:	5e                   	pop    %esi
  8011e3:	5f                   	pop    %edi
  8011e4:	5d                   	pop    %ebp
  8011e5:	c3                   	ret    
  8011e6:	66 90                	xchg   %ax,%ax
  8011e8:	85 c9                	test   %ecx,%ecx
  8011ea:	75 0b                	jne    8011f7 <__umoddi3+0x77>
  8011ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f1:	31 d2                	xor    %edx,%edx
  8011f3:	f7 f1                	div    %ecx
  8011f5:	89 c1                	mov    %eax,%ecx
  8011f7:	89 f0                	mov    %esi,%eax
  8011f9:	31 d2                	xor    %edx,%edx
  8011fb:	f7 f1                	div    %ecx
  8011fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801200:	eb a5                	jmp    8011a7 <__umoddi3+0x27>
  801202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801208:	89 f2                	mov    %esi,%edx
  80120a:	83 c4 20             	add    $0x20,%esp
  80120d:	5e                   	pop    %esi
  80120e:	5f                   	pop    %edi
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    
  801211:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801218:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80121c:	89 f2                	mov    %esi,%edx
  80121e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801221:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801228:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80122b:	d3 e7                	shl    %cl,%edi
  80122d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801230:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801234:	d3 e8                	shr    %cl,%eax
  801236:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80123a:	09 f8                	or     %edi,%eax
  80123c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80123f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801242:	d3 e0                	shl    %cl,%eax
  801244:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801248:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80124b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80124e:	d3 ea                	shr    %cl,%edx
  801250:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801254:	d3 e6                	shl    %cl,%esi
  801256:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80125a:	d3 e8                	shr    %cl,%eax
  80125c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801260:	09 f0                	or     %esi,%eax
  801262:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801265:	f7 75 e4             	divl   -0x1c(%ebp)
  801268:	d3 e6                	shl    %cl,%esi
  80126a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80126d:	89 d6                	mov    %edx,%esi
  80126f:	f7 65 f4             	mull   -0xc(%ebp)
  801272:	89 d7                	mov    %edx,%edi
  801274:	89 c2                	mov    %eax,%edx
  801276:	39 fe                	cmp    %edi,%esi
  801278:	89 f9                	mov    %edi,%ecx
  80127a:	72 30                	jb     8012ac <__umoddi3+0x12c>
  80127c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80127f:	72 27                	jb     8012a8 <__umoddi3+0x128>
  801281:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801284:	29 d0                	sub    %edx,%eax
  801286:	19 ce                	sbb    %ecx,%esi
  801288:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80128c:	89 f2                	mov    %esi,%edx
  80128e:	d3 e8                	shr    %cl,%eax
  801290:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801294:	d3 e2                	shl    %cl,%edx
  801296:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80129a:	09 d0                	or     %edx,%eax
  80129c:	89 f2                	mov    %esi,%edx
  80129e:	d3 ea                	shr    %cl,%edx
  8012a0:	83 c4 20             	add    $0x20,%esp
  8012a3:	5e                   	pop    %esi
  8012a4:	5f                   	pop    %edi
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    
  8012a7:	90                   	nop
  8012a8:	39 fe                	cmp    %edi,%esi
  8012aa:	75 d5                	jne    801281 <__umoddi3+0x101>
  8012ac:	89 f9                	mov    %edi,%ecx
  8012ae:	89 c2                	mov    %eax,%edx
  8012b0:	2b 55 f4             	sub    -0xc(%ebp),%edx
  8012b3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8012b6:	eb c9                	jmp    801281 <__umoddi3+0x101>
  8012b8:	39 f7                	cmp    %esi,%edi
  8012ba:	0f 82 10 ff ff ff    	jb     8011d0 <__umoddi3+0x50>
  8012c0:	e9 17 ff ff ff       	jmp    8011dc <__umoddi3+0x5c>
