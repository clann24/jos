
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 ef 00 00 00       	call   800120 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 c8 0f 80 00 	movl   $0x800fc8,(%esp)
  800041:	e8 21 02 00 00       	call   800267 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800046:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  80004d:	75 11                	jne    800060 <umain+0x2c>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != 0)
  800054:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  80005b:	00 
  80005c:	74 27                	je     800085 <umain+0x51>
  80005e:	eb 05                	jmp    800065 <umain+0x31>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
  800065:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800069:	c7 44 24 08 43 10 80 	movl   $0x801043,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 60 10 80 00 	movl   $0x801060,(%esp)
  800080:	e8 e7 00 00 00       	call   80016c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800085:	83 c0 01             	add    $0x1,%eax
  800088:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008d:	75 c5                	jne    800054 <umain+0x20>
  80008f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800094:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80009b:	83 c0 01             	add    $0x1,%eax
  80009e:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000a3:	75 ef                	jne    800094 <umain+0x60>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a5:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  8000ac:	75 10                	jne    8000be <umain+0x8a>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000ae:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != i)
  8000b3:	3b 04 85 20 20 80 00 	cmp    0x802020(,%eax,4),%eax
  8000ba:	74 27                	je     8000e3 <umain+0xaf>
  8000bc:	eb 05                	jmp    8000c3 <umain+0x8f>
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c7:	c7 44 24 08 e8 0f 80 	movl   $0x800fe8,0x8(%esp)
  8000ce:	00 
  8000cf:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000d6:	00 
  8000d7:	c7 04 24 60 10 80 00 	movl   $0x801060,(%esp)
  8000de:	e8 89 00 00 00       	call   80016c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000e3:	83 c0 01             	add    $0x1,%eax
  8000e6:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000eb:	75 c6                	jne    8000b3 <umain+0x7f>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000ed:	c7 04 24 10 10 80 00 	movl   $0x801010,(%esp)
  8000f4:	e8 6e 01 00 00       	call   800267 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f9:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  800100:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800103:	c7 44 24 08 6f 10 80 	movl   $0x80106f,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 60 10 80 00 	movl   $0x801060,(%esp)
  80011a:	e8 4d 00 00 00       	call   80016c <_panic>
	...

00800120 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 18             	sub    $0x18,%esp
  800126:	8b 45 08             	mov    0x8(%ebp),%eax
  800129:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80012c:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  800133:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	85 c0                	test   %eax,%eax
  800138:	7e 08                	jle    800142 <libmain+0x22>
		binaryname = argv[0];
  80013a:	8b 0a                	mov    (%edx),%ecx
  80013c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800142:	89 54 24 04          	mov    %edx,0x4(%esp)
  800146:	89 04 24             	mov    %eax,(%esp)
  800149:	e8 e6 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80014e:	e8 05 00 00 00       	call   800158 <exit>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    
  800155:	00 00                	add    %al,(%eax)
	...

00800158 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80015e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800165:	e8 71 0b 00 00       	call   800cdb <sys_env_destroy>
}
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
  800171:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800174:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800177:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80017d:	e8 b6 0b 00 00       	call   800d38 <sys_getenvid>
  800182:	8b 55 0c             	mov    0xc(%ebp),%edx
  800185:	89 54 24 10          	mov    %edx,0x10(%esp)
  800189:	8b 55 08             	mov    0x8(%ebp),%edx
  80018c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800190:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800194:	89 44 24 04          	mov    %eax,0x4(%esp)
  800198:	c7 04 24 90 10 80 00 	movl   $0x801090,(%esp)
  80019f:	e8 c3 00 00 00       	call   800267 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	e8 53 00 00 00       	call   800206 <vcprintf>
	cprintf("\n");
  8001b3:	c7 04 24 5e 10 80 00 	movl   $0x80105e,(%esp)
  8001ba:	e8 a8 00 00 00       	call   800267 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bf:	cc                   	int3   
  8001c0:	eb fd                	jmp    8001bf <_panic+0x53>
	...

008001c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	53                   	push   %ebx
  8001c8:	83 ec 14             	sub    $0x14,%esp
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ce:	8b 03                	mov    (%ebx),%eax
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d7:	83 c0 01             	add    $0x1,%eax
  8001da:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e1:	75 19                	jne    8001fc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001e3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ea:	00 
  8001eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ee:	89 04 24             	mov    %eax,(%esp)
  8001f1:	e8 7e 0a 00 00       	call   800c74 <sys_cputs>
		b->idx = 0;
  8001f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001fc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800200:	83 c4 14             	add    $0x14,%esp
  800203:	5b                   	pop    %ebx
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80020f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800216:	00 00 00 
	b.cnt = 0;
  800219:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800220:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800223:	8b 45 0c             	mov    0xc(%ebp),%eax
  800226:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800231:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023b:	c7 04 24 c4 01 80 00 	movl   $0x8001c4,(%esp)
  800242:	e8 ea 01 00 00       	call   800431 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800247:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800251:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	e8 15 0a 00 00       	call   800c74 <sys_cputs>

	return b.cnt;
}
  80025f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800265:	c9                   	leave  
  800266:	c3                   	ret    

00800267 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800270:	89 44 24 04          	mov    %eax,0x4(%esp)
  800274:	8b 45 08             	mov    0x8(%ebp),%eax
  800277:	89 04 24             	mov    %eax,(%esp)
  80027a:	e8 87 ff ff ff       	call   800206 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    
	...

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 4c             	sub    $0x4c,%esp
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	89 d6                	mov    %edx,%esi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002ad:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b5:	39 d0                	cmp    %edx,%eax
  8002b7:	72 11                	jb     8002ca <printnum+0x3a>
  8002b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002bc:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8002bf:	76 09                	jbe    8002ca <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c1:	83 eb 01             	sub    $0x1,%ebx
  8002c4:	85 db                	test   %ebx,%ebx
  8002c6:	7f 5d                	jg     800325 <printnum+0x95>
  8002c8:	eb 6c                	jmp    800336 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ca:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002ce:	83 eb 01             	sub    $0x1,%ebx
  8002d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002dc:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002e0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8002ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002f1:	00 
  8002f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002f5:	89 14 24             	mov    %edx,(%esp)
  8002f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002ff:	e8 6c 0a 00 00       	call   800d70 <__udivdi3>
  800304:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800307:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80030a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80030e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800312:	89 04 24             	mov    %eax,(%esp)
  800315:	89 54 24 04          	mov    %edx,0x4(%esp)
  800319:	89 f2                	mov    %esi,%edx
  80031b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80031e:	e8 6d ff ff ff       	call   800290 <printnum>
  800323:	eb 11                	jmp    800336 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800325:	89 74 24 04          	mov    %esi,0x4(%esp)
  800329:	89 3c 24             	mov    %edi,(%esp)
  80032c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80032f:	83 eb 01             	sub    $0x1,%ebx
  800332:	85 db                	test   %ebx,%ebx
  800334:	7f ef                	jg     800325 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80033a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80033e:	8b 45 10             	mov    0x10(%ebp),%eax
  800341:	89 44 24 08          	mov    %eax,0x8(%esp)
  800345:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034c:	00 
  80034d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800350:	89 14 24             	mov    %edx,(%esp)
  800353:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800356:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80035a:	e8 21 0b 00 00       	call   800e80 <__umoddi3>
  80035f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800363:	0f be 80 b4 10 80 00 	movsbl 0x8010b4(%eax),%eax
  80036a:	89 04 24             	mov    %eax,(%esp)
  80036d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800370:	83 c4 4c             	add    $0x4c,%esp
  800373:	5b                   	pop    %ebx
  800374:	5e                   	pop    %esi
  800375:	5f                   	pop    %edi
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037b:	83 fa 01             	cmp    $0x1,%edx
  80037e:	7e 0e                	jle    80038e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800380:	8b 10                	mov    (%eax),%edx
  800382:	8d 4a 08             	lea    0x8(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 02                	mov    (%edx),%eax
  800389:	8b 52 04             	mov    0x4(%edx),%edx
  80038c:	eb 22                	jmp    8003b0 <getuint+0x38>
	else if (lflag)
  80038e:	85 d2                	test   %edx,%edx
  800390:	74 10                	je     8003a2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800392:	8b 10                	mov    (%eax),%edx
  800394:	8d 4a 04             	lea    0x4(%edx),%ecx
  800397:	89 08                	mov    %ecx,(%eax)
  800399:	8b 02                	mov    (%edx),%eax
  80039b:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a0:	eb 0e                	jmp    8003b0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a2:	8b 10                	mov    (%eax),%edx
  8003a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a7:	89 08                	mov    %ecx,(%eax)
  8003a9:	8b 02                	mov    (%edx),%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b0:	5d                   	pop    %ebp
  8003b1:	c3                   	ret    

008003b2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b5:	83 fa 01             	cmp    $0x1,%edx
  8003b8:	7e 0e                	jle    8003c8 <getint+0x16>
		return va_arg(*ap, long long);
  8003ba:	8b 10                	mov    (%eax),%edx
  8003bc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003bf:	89 08                	mov    %ecx,(%eax)
  8003c1:	8b 02                	mov    (%edx),%eax
  8003c3:	8b 52 04             	mov    0x4(%edx),%edx
  8003c6:	eb 22                	jmp    8003ea <getint+0x38>
	else if (lflag)
  8003c8:	85 d2                	test   %edx,%edx
  8003ca:	74 10                	je     8003dc <getint+0x2a>
		return va_arg(*ap, long);
  8003cc:	8b 10                	mov    (%eax),%edx
  8003ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d1:	89 08                	mov    %ecx,(%eax)
  8003d3:	8b 02                	mov    (%edx),%eax
  8003d5:	89 c2                	mov    %eax,%edx
  8003d7:	c1 fa 1f             	sar    $0x1f,%edx
  8003da:	eb 0e                	jmp    8003ea <getint+0x38>
	else
		return va_arg(*ap, int);
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e1:	89 08                	mov    %ecx,(%eax)
  8003e3:	8b 02                	mov    (%edx),%eax
  8003e5:	89 c2                	mov    %eax,%edx
  8003e7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f6:	8b 10                	mov    (%eax),%edx
  8003f8:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fb:	73 0a                	jae    800407 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800400:	88 0a                	mov    %cl,(%edx)
  800402:	83 c2 01             	add    $0x1,%edx
  800405:	89 10                	mov    %edx,(%eax)
}
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    

00800409 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80040f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800412:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800416:	8b 45 10             	mov    0x10(%ebp),%eax
  800419:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800420:	89 44 24 04          	mov    %eax,0x4(%esp)
  800424:	8b 45 08             	mov    0x8(%ebp),%eax
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	e8 02 00 00 00       	call   800431 <vprintfmt>
	va_end(ap);
}
  80042f:	c9                   	leave  
  800430:	c3                   	ret    

00800431 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	57                   	push   %edi
  800435:	56                   	push   %esi
  800436:	53                   	push   %ebx
  800437:	83 ec 4c             	sub    $0x4c,%esp
  80043a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043d:	eb 23                	jmp    800462 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80043f:	85 c0                	test   %eax,%eax
  800441:	75 12                	jne    800455 <vprintfmt+0x24>
				csa = 0x0700;
  800443:	c7 05 24 20 c0 00 00 	movl   $0x700,0xc02024
  80044a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80044d:	83 c4 4c             	add    $0x4c,%esp
  800450:	5b                   	pop    %ebx
  800451:	5e                   	pop    %esi
  800452:	5f                   	pop    %edi
  800453:	5d                   	pop    %ebp
  800454:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800455:	8b 55 0c             	mov    0xc(%ebp),%edx
  800458:	89 54 24 04          	mov    %edx,0x4(%esp)
  80045c:	89 04 24             	mov    %eax,(%esp)
  80045f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800462:	0f b6 07             	movzbl (%edi),%eax
  800465:	83 c7 01             	add    $0x1,%edi
  800468:	83 f8 25             	cmp    $0x25,%eax
  80046b:	75 d2                	jne    80043f <vprintfmt+0xe>
  80046d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800471:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800478:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80047d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800484:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800489:	be 00 00 00 00       	mov    $0x0,%esi
  80048e:	eb 14                	jmp    8004a4 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800490:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800494:	eb 0e                	jmp    8004a4 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800496:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80049a:	eb 08                	jmp    8004a4 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80049c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80049f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	0f b6 07             	movzbl (%edi),%eax
  8004a7:	0f b6 c8             	movzbl %al,%ecx
  8004aa:	83 c7 01             	add    $0x1,%edi
  8004ad:	83 e8 23             	sub    $0x23,%eax
  8004b0:	3c 55                	cmp    $0x55,%al
  8004b2:	0f 87 ed 02 00 00    	ja     8007a5 <vprintfmt+0x374>
  8004b8:	0f b6 c0             	movzbl %al,%eax
  8004bb:	ff 24 85 44 11 80 00 	jmp    *0x801144(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  8004c5:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004c8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004cb:	83 f9 09             	cmp    $0x9,%ecx
  8004ce:	77 3c                	ja     80050c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004d3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8004d6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8004da:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004dd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004e0:	83 f9 09             	cmp    $0x9,%ecx
  8004e3:	76 eb                	jbe    8004d0 <vprintfmt+0x9f>
  8004e5:	eb 25                	jmp    80050c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ed:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  8004f2:	eb 18                	jmp    80050c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  8004f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004fb:	0f 48 c6             	cmovs  %esi,%eax
  8004fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800501:	eb a1                	jmp    8004a4 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  800503:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80050a:	eb 98                	jmp    8004a4 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  80050c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800510:	79 92                	jns    8004a4 <vprintfmt+0x73>
  800512:	eb 88                	jmp    80049c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800514:	83 c2 01             	add    $0x1,%edx
  800517:	eb 8b                	jmp    8004a4 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 50 04             	lea    0x4(%eax),%edx
  80051f:	89 55 14             	mov    %edx,0x14(%ebp)
  800522:	8b 55 0c             	mov    0xc(%ebp),%edx
  800525:	89 54 24 04          	mov    %edx,0x4(%esp)
  800529:	8b 00                	mov    (%eax),%eax
  80052b:	89 04 24             	mov    %eax,(%esp)
  80052e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800531:	e9 2c ff ff ff       	jmp    800462 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8d 50 04             	lea    0x4(%eax),%edx
  80053c:	89 55 14             	mov    %edx,0x14(%ebp)
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 c2                	mov    %eax,%edx
  800543:	c1 fa 1f             	sar    $0x1f,%edx
  800546:	31 d0                	xor    %edx,%eax
  800548:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054a:	83 f8 06             	cmp    $0x6,%eax
  80054d:	7f 0b                	jg     80055a <vprintfmt+0x129>
  80054f:	8b 14 85 9c 12 80 00 	mov    0x80129c(,%eax,4),%edx
  800556:	85 d2                	test   %edx,%edx
  800558:	75 23                	jne    80057d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80055a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055e:	c7 44 24 08 cc 10 80 	movl   $0x8010cc,0x8(%esp)
  800565:	00 
  800566:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800569:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056d:	8b 45 08             	mov    0x8(%ebp),%eax
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	e8 91 fe ff ff       	call   800409 <printfmt>
  800578:	e9 e5 fe ff ff       	jmp    800462 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80057d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800581:	c7 44 24 08 d5 10 80 	movl   $0x8010d5,0x8(%esp)
  800588:	00 
  800589:	8b 55 0c             	mov    0xc(%ebp),%edx
  80058c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800590:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800593:	89 1c 24             	mov    %ebx,(%esp)
  800596:	e8 6e fe ff ff       	call   800409 <printfmt>
  80059b:	e9 c2 fe ff ff       	jmp    800462 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 50 04             	lea    0x4(%eax),%edx
  8005af:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b2:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005b4:	85 f6                	test   %esi,%esi
  8005b6:	ba c5 10 80 00       	mov    $0x8010c5,%edx
  8005bb:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005be:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c2:	7e 06                	jle    8005ca <vprintfmt+0x199>
  8005c4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005c8:	75 13                	jne    8005dd <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ca:	0f be 06             	movsbl (%esi),%eax
  8005cd:	83 c6 01             	add    $0x1,%esi
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	0f 85 a2 00 00 00    	jne    80067a <vprintfmt+0x249>
  8005d8:	e9 92 00 00 00       	jmp    80066f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e1:	89 34 24             	mov    %esi,(%esp)
  8005e4:	e8 82 02 00 00       	call   80086b <strnlen>
  8005e9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ec:	29 c2                	sub    %eax,%edx
  8005ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f1:	85 d2                	test   %edx,%edx
  8005f3:	7e d5                	jle    8005ca <vprintfmt+0x199>
					putch(padc, putdat);
  8005f5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8005f9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005fc:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005ff:	89 d3                	mov    %edx,%ebx
  800601:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800604:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800607:	89 c6                	mov    %eax,%esi
  800609:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060d:	89 34 24             	mov    %esi,(%esp)
  800610:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800613:	83 eb 01             	sub    $0x1,%ebx
  800616:	85 db                	test   %ebx,%ebx
  800618:	7f ef                	jg     800609 <vprintfmt+0x1d8>
  80061a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80061d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800623:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80062a:	eb 9e                	jmp    8005ca <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80062c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800630:	74 1b                	je     80064d <vprintfmt+0x21c>
  800632:	8d 50 e0             	lea    -0x20(%eax),%edx
  800635:	83 fa 5e             	cmp    $0x5e,%edx
  800638:	76 13                	jbe    80064d <vprintfmt+0x21c>
					putch('?', putdat);
  80063a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80063d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800641:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
  80064b:	eb 0d                	jmp    80065a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80064d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800650:	89 54 24 04          	mov    %edx,0x4(%esp)
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065a:	83 ef 01             	sub    $0x1,%edi
  80065d:	0f be 06             	movsbl (%esi),%eax
  800660:	85 c0                	test   %eax,%eax
  800662:	74 05                	je     800669 <vprintfmt+0x238>
  800664:	83 c6 01             	add    $0x1,%esi
  800667:	eb 17                	jmp    800680 <vprintfmt+0x24f>
  800669:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80066c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800673:	7f 1c                	jg     800691 <vprintfmt+0x260>
  800675:	e9 e8 fd ff ff       	jmp    800462 <vprintfmt+0x31>
  80067a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80067d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800680:	85 db                	test   %ebx,%ebx
  800682:	78 a8                	js     80062c <vprintfmt+0x1fb>
  800684:	83 eb 01             	sub    $0x1,%ebx
  800687:	79 a3                	jns    80062c <vprintfmt+0x1fb>
  800689:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80068c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80068f:	eb de                	jmp    80066f <vprintfmt+0x23e>
  800691:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800694:	8b 7d 08             	mov    0x8(%ebp),%edi
  800697:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80069e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006a5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a7:	83 eb 01             	sub    $0x1,%ebx
  8006aa:	85 db                	test   %ebx,%ebx
  8006ac:	7f ec                	jg     80069a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b1:	e9 ac fd ff ff       	jmp    800462 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b9:	e8 f4 fc ff ff       	call   8003b2 <getint>
  8006be:	89 c3                	mov    %eax,%ebx
  8006c0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8006c2:	85 d2                	test   %edx,%edx
  8006c4:	78 0a                	js     8006d0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006cb:	e9 87 00 00 00       	jmp    800757 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006de:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006e1:	89 d8                	mov    %ebx,%eax
  8006e3:	89 f2                	mov    %esi,%edx
  8006e5:	f7 d8                	neg    %eax
  8006e7:	83 d2 00             	adc    $0x0,%edx
  8006ea:	f7 da                	neg    %edx
			}
			base = 10;
  8006ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f1:	eb 64                	jmp    800757 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f6:	e8 7d fc ff ff       	call   800378 <getuint>
			base = 10;
  8006fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800700:	eb 55                	jmp    800757 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800702:	8d 45 14             	lea    0x14(%ebp),%eax
  800705:	e8 6e fc ff ff       	call   800378 <getuint>
      base = 8;
  80070a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80070f:	eb 46                	jmp    800757 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800711:	8b 55 0c             	mov    0xc(%ebp),%edx
  800714:	89 54 24 04          	mov    %edx,0x4(%esp)
  800718:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800722:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800725:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800729:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800730:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8d 50 04             	lea    0x4(%eax),%edx
  800739:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80073c:	8b 00                	mov    (%eax),%eax
  80073e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800743:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800748:	eb 0d                	jmp    800757 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80074a:	8d 45 14             	lea    0x14(%ebp),%eax
  80074d:	e8 26 fc ff ff       	call   800378 <getuint>
			base = 16;
  800752:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800757:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80075b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80075f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800762:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800766:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80076a:	89 04 24             	mov    %eax,(%esp)
  80076d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800771:	8b 55 0c             	mov    0xc(%ebp),%edx
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	e8 14 fb ff ff       	call   800290 <printnum>
			break;
  80077c:	e9 e1 fc ff ff       	jmp    800462 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800781:	8b 45 0c             	mov    0xc(%ebp),%eax
  800784:	89 44 24 04          	mov    %eax,0x4(%esp)
  800788:	89 0c 24             	mov    %ecx,(%esp)
  80078b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80078e:	e9 cf fc ff ff       	jmp    800462 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800793:	8d 45 14             	lea    0x14(%ebp),%eax
  800796:	e8 17 fc ff ff       	call   8003b2 <getint>
			csa = num;
  80079b:	a3 24 20 c0 00       	mov    %eax,0xc02024
			break;
  8007a0:	e9 bd fc ff ff       	jmp    800462 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ac:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007b3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b6:	83 ef 01             	sub    $0x1,%edi
  8007b9:	eb 02                	jmp    8007bd <vprintfmt+0x38c>
  8007bb:	89 c7                	mov    %eax,%edi
  8007bd:	8d 47 ff             	lea    -0x1(%edi),%eax
  8007c0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c4:	75 f5                	jne    8007bb <vprintfmt+0x38a>
  8007c6:	e9 97 fc ff ff       	jmp    800462 <vprintfmt+0x31>

008007cb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	83 ec 28             	sub    $0x28,%esp
  8007d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007da:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007de:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	74 30                	je     80081c <vsnprintf+0x51>
  8007ec:	85 d2                	test   %edx,%edx
  8007ee:	7e 2c                	jle    80081c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800801:	89 44 24 04          	mov    %eax,0x4(%esp)
  800805:	c7 04 24 ec 03 80 00 	movl   $0x8003ec,(%esp)
  80080c:	e8 20 fc ff ff       	call   800431 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800811:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800814:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800817:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80081a:	eb 05                	jmp    800821 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800829:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800830:	8b 45 10             	mov    0x10(%ebp),%eax
  800833:	89 44 24 08          	mov    %eax,0x8(%esp)
  800837:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	89 04 24             	mov    %eax,(%esp)
  800844:	e8 82 ff ff ff       	call   8007cb <vsnprintf>
	va_end(ap);

	return rc;
}
  800849:	c9                   	leave  
  80084a:	c3                   	ret    
  80084b:	00 00                	add    %al,(%eax)
  80084d:	00 00                	add    %al,(%eax)
	...

00800850 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
  80085b:	80 3a 00             	cmpb   $0x0,(%edx)
  80085e:	74 09                	je     800869 <strlen+0x19>
		n++;
  800860:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800863:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800867:	75 f7                	jne    800860 <strlen+0x10>
		n++;
	return n;
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
  800879:	85 d2                	test   %edx,%edx
  80087b:	74 12                	je     80088f <strnlen+0x24>
  80087d:	80 39 00             	cmpb   $0x0,(%ecx)
  800880:	74 0d                	je     80088f <strnlen+0x24>
		n++;
  800882:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800885:	39 d0                	cmp    %edx,%eax
  800887:	74 06                	je     80088f <strnlen+0x24>
  800889:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80088d:	75 f3                	jne    800882 <strnlen+0x17>
		n++;
	return n;
}
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	53                   	push   %ebx
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089b:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008a4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008a7:	83 c2 01             	add    $0x1,%edx
  8008aa:	84 c9                	test   %cl,%cl
  8008ac:	75 f2                	jne    8008a0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ae:	5b                   	pop    %ebx
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	53                   	push   %ebx
  8008b5:	83 ec 08             	sub    $0x8,%esp
  8008b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008bb:	89 1c 24             	mov    %ebx,(%esp)
  8008be:	e8 8d ff ff ff       	call   800850 <strlen>
	strcpy(dst + len, src);
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ca:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008cd:	89 04 24             	mov    %eax,(%esp)
  8008d0:	e8 bc ff ff ff       	call   800891 <strcpy>
	return dst;
}
  8008d5:	89 d8                	mov    %ebx,%eax
  8008d7:	83 c4 08             	add    $0x8,%esp
  8008da:	5b                   	pop    %ebx
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008eb:	85 f6                	test   %esi,%esi
  8008ed:	74 18                	je     800907 <strncpy+0x2a>
  8008ef:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008f4:	0f b6 1a             	movzbl (%edx),%ebx
  8008f7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008fa:	80 3a 01             	cmpb   $0x1,(%edx)
  8008fd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800900:	83 c1 01             	add    $0x1,%ecx
  800903:	39 ce                	cmp    %ecx,%esi
  800905:	77 ed                	ja     8008f4 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	56                   	push   %esi
  80090f:	53                   	push   %ebx
  800910:	8b 75 08             	mov    0x8(%ebp),%esi
  800913:	8b 55 0c             	mov    0xc(%ebp),%edx
  800916:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800919:	89 f0                	mov    %esi,%eax
  80091b:	85 c9                	test   %ecx,%ecx
  80091d:	74 23                	je     800942 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  80091f:	83 e9 01             	sub    $0x1,%ecx
  800922:	74 1b                	je     80093f <strlcpy+0x34>
  800924:	0f b6 1a             	movzbl (%edx),%ebx
  800927:	84 db                	test   %bl,%bl
  800929:	74 14                	je     80093f <strlcpy+0x34>
			*dst++ = *src++;
  80092b:	88 18                	mov    %bl,(%eax)
  80092d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800930:	83 e9 01             	sub    $0x1,%ecx
  800933:	74 0a                	je     80093f <strlcpy+0x34>
			*dst++ = *src++;
  800935:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800938:	0f b6 1a             	movzbl (%edx),%ebx
  80093b:	84 db                	test   %bl,%bl
  80093d:	75 ec                	jne    80092b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80093f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800942:	29 f0                	sub    %esi,%eax
}
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800951:	0f b6 01             	movzbl (%ecx),%eax
  800954:	84 c0                	test   %al,%al
  800956:	74 15                	je     80096d <strcmp+0x25>
  800958:	3a 02                	cmp    (%edx),%al
  80095a:	75 11                	jne    80096d <strcmp+0x25>
		p++, q++;
  80095c:	83 c1 01             	add    $0x1,%ecx
  80095f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800962:	0f b6 01             	movzbl (%ecx),%eax
  800965:	84 c0                	test   %al,%al
  800967:	74 04                	je     80096d <strcmp+0x25>
  800969:	3a 02                	cmp    (%edx),%al
  80096b:	74 ef                	je     80095c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80096d:	0f b6 c0             	movzbl %al,%eax
  800970:	0f b6 12             	movzbl (%edx),%edx
  800973:	29 d0                	sub    %edx,%eax
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	53                   	push   %ebx
  80097b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800981:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800984:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800989:	85 d2                	test   %edx,%edx
  80098b:	74 28                	je     8009b5 <strncmp+0x3e>
  80098d:	0f b6 01             	movzbl (%ecx),%eax
  800990:	84 c0                	test   %al,%al
  800992:	74 24                	je     8009b8 <strncmp+0x41>
  800994:	3a 03                	cmp    (%ebx),%al
  800996:	75 20                	jne    8009b8 <strncmp+0x41>
  800998:	83 ea 01             	sub    $0x1,%edx
  80099b:	74 13                	je     8009b0 <strncmp+0x39>
		n--, p++, q++;
  80099d:	83 c1 01             	add    $0x1,%ecx
  8009a0:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a3:	0f b6 01             	movzbl (%ecx),%eax
  8009a6:	84 c0                	test   %al,%al
  8009a8:	74 0e                	je     8009b8 <strncmp+0x41>
  8009aa:	3a 03                	cmp    (%ebx),%al
  8009ac:	74 ea                	je     800998 <strncmp+0x21>
  8009ae:	eb 08                	jmp    8009b8 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009b5:	5b                   	pop    %ebx
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b8:	0f b6 01             	movzbl (%ecx),%eax
  8009bb:	0f b6 13             	movzbl (%ebx),%edx
  8009be:	29 d0                	sub    %edx,%eax
  8009c0:	eb f3                	jmp    8009b5 <strncmp+0x3e>

008009c2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009cc:	0f b6 10             	movzbl (%eax),%edx
  8009cf:	84 d2                	test   %dl,%dl
  8009d1:	74 20                	je     8009f3 <strchr+0x31>
		if (*s == c)
  8009d3:	38 ca                	cmp    %cl,%dl
  8009d5:	75 0b                	jne    8009e2 <strchr+0x20>
  8009d7:	eb 1f                	jmp    8009f8 <strchr+0x36>
  8009d9:	38 ca                	cmp    %cl,%dl
  8009db:	90                   	nop
  8009dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009e0:	74 16                	je     8009f8 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009e2:	83 c0 01             	add    $0x1,%eax
  8009e5:	0f b6 10             	movzbl (%eax),%edx
  8009e8:	84 d2                	test   %dl,%dl
  8009ea:	75 ed                	jne    8009d9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f1:	eb 05                	jmp    8009f8 <strchr+0x36>
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a04:	0f b6 10             	movzbl (%eax),%edx
  800a07:	84 d2                	test   %dl,%dl
  800a09:	74 14                	je     800a1f <strfind+0x25>
		if (*s == c)
  800a0b:	38 ca                	cmp    %cl,%dl
  800a0d:	75 06                	jne    800a15 <strfind+0x1b>
  800a0f:	eb 0e                	jmp    800a1f <strfind+0x25>
  800a11:	38 ca                	cmp    %cl,%dl
  800a13:	74 0a                	je     800a1f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	0f b6 10             	movzbl (%eax),%edx
  800a1b:	84 d2                	test   %dl,%dl
  800a1d:	75 f2                	jne    800a11 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	83 ec 0c             	sub    $0xc,%esp
  800a27:	89 1c 24             	mov    %ebx,(%esp)
  800a2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a2e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a32:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a38:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3b:	85 c9                	test   %ecx,%ecx
  800a3d:	74 30                	je     800a6f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a45:	75 25                	jne    800a6c <memset+0x4b>
  800a47:	f6 c1 03             	test   $0x3,%cl
  800a4a:	75 20                	jne    800a6c <memset+0x4b>
		c &= 0xFF;
  800a4c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4f:	89 d3                	mov    %edx,%ebx
  800a51:	c1 e3 08             	shl    $0x8,%ebx
  800a54:	89 d6                	mov    %edx,%esi
  800a56:	c1 e6 18             	shl    $0x18,%esi
  800a59:	89 d0                	mov    %edx,%eax
  800a5b:	c1 e0 10             	shl    $0x10,%eax
  800a5e:	09 f0                	or     %esi,%eax
  800a60:	09 d0                	or     %edx,%eax
  800a62:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a64:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a67:	fc                   	cld    
  800a68:	f3 ab                	rep stos %eax,%es:(%edi)
  800a6a:	eb 03                	jmp    800a6f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a6c:	fc                   	cld    
  800a6d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a6f:	89 f8                	mov    %edi,%eax
  800a71:	8b 1c 24             	mov    (%esp),%ebx
  800a74:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a78:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a7c:	89 ec                	mov    %ebp,%esp
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	83 ec 08             	sub    $0x8,%esp
  800a86:	89 34 24             	mov    %esi,(%esp)
  800a89:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a96:	39 c6                	cmp    %eax,%esi
  800a98:	73 36                	jae    800ad0 <memmove+0x50>
  800a9a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9d:	39 d0                	cmp    %edx,%eax
  800a9f:	73 2f                	jae    800ad0 <memmove+0x50>
		s += n;
		d += n;
  800aa1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa4:	f6 c2 03             	test   $0x3,%dl
  800aa7:	75 1b                	jne    800ac4 <memmove+0x44>
  800aa9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aaf:	75 13                	jne    800ac4 <memmove+0x44>
  800ab1:	f6 c1 03             	test   $0x3,%cl
  800ab4:	75 0e                	jne    800ac4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab6:	83 ef 04             	sub    $0x4,%edi
  800ab9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800abf:	fd                   	std    
  800ac0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac2:	eb 09                	jmp    800acd <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ac4:	83 ef 01             	sub    $0x1,%edi
  800ac7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aca:	fd                   	std    
  800acb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800acd:	fc                   	cld    
  800ace:	eb 20                	jmp    800af0 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad6:	75 13                	jne    800aeb <memmove+0x6b>
  800ad8:	a8 03                	test   $0x3,%al
  800ada:	75 0f                	jne    800aeb <memmove+0x6b>
  800adc:	f6 c1 03             	test   $0x3,%cl
  800adf:	75 0a                	jne    800aeb <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ae1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ae4:	89 c7                	mov    %eax,%edi
  800ae6:	fc                   	cld    
  800ae7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae9:	eb 05                	jmp    800af0 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aeb:	89 c7                	mov    %eax,%edi
  800aed:	fc                   	cld    
  800aee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af0:	8b 34 24             	mov    (%esp),%esi
  800af3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800af7:	89 ec                	mov    %ebp,%esp
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b01:	8b 45 10             	mov    0x10(%ebp),%eax
  800b04:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	89 04 24             	mov    %eax,(%esp)
  800b15:	e8 66 ff ff ff       	call   800a80 <memmove>
}
  800b1a:	c9                   	leave  
  800b1b:	c3                   	ret    

00800b1c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b28:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b2b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b30:	85 ff                	test   %edi,%edi
  800b32:	74 38                	je     800b6c <memcmp+0x50>
		if (*s1 != *s2)
  800b34:	0f b6 03             	movzbl (%ebx),%eax
  800b37:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3a:	83 ef 01             	sub    $0x1,%edi
  800b3d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b42:	38 c8                	cmp    %cl,%al
  800b44:	74 1d                	je     800b63 <memcmp+0x47>
  800b46:	eb 11                	jmp    800b59 <memcmp+0x3d>
  800b48:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b4d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800b52:	83 c2 01             	add    $0x1,%edx
  800b55:	38 c8                	cmp    %cl,%al
  800b57:	74 0a                	je     800b63 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800b59:	0f b6 c0             	movzbl %al,%eax
  800b5c:	0f b6 c9             	movzbl %cl,%ecx
  800b5f:	29 c8                	sub    %ecx,%eax
  800b61:	eb 09                	jmp    800b6c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b63:	39 fa                	cmp    %edi,%edx
  800b65:	75 e1                	jne    800b48 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b77:	89 c2                	mov    %eax,%edx
  800b79:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b7c:	39 d0                	cmp    %edx,%eax
  800b7e:	73 15                	jae    800b95 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b84:	38 08                	cmp    %cl,(%eax)
  800b86:	75 06                	jne    800b8e <memfind+0x1d>
  800b88:	eb 0b                	jmp    800b95 <memfind+0x24>
  800b8a:	38 08                	cmp    %cl,(%eax)
  800b8c:	74 07                	je     800b95 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b8e:	83 c0 01             	add    $0x1,%eax
  800b91:	39 c2                	cmp    %eax,%edx
  800b93:	77 f5                	ja     800b8a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba3:	0f b6 02             	movzbl (%edx),%eax
  800ba6:	3c 20                	cmp    $0x20,%al
  800ba8:	74 04                	je     800bae <strtol+0x17>
  800baa:	3c 09                	cmp    $0x9,%al
  800bac:	75 0e                	jne    800bbc <strtol+0x25>
		s++;
  800bae:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb1:	0f b6 02             	movzbl (%edx),%eax
  800bb4:	3c 20                	cmp    $0x20,%al
  800bb6:	74 f6                	je     800bae <strtol+0x17>
  800bb8:	3c 09                	cmp    $0x9,%al
  800bba:	74 f2                	je     800bae <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bbc:	3c 2b                	cmp    $0x2b,%al
  800bbe:	75 0a                	jne    800bca <strtol+0x33>
		s++;
  800bc0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bc3:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc8:	eb 10                	jmp    800bda <strtol+0x43>
  800bca:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bcf:	3c 2d                	cmp    $0x2d,%al
  800bd1:	75 07                	jne    800bda <strtol+0x43>
		s++, neg = 1;
  800bd3:	83 c2 01             	add    $0x1,%edx
  800bd6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bda:	85 db                	test   %ebx,%ebx
  800bdc:	0f 94 c0             	sete   %al
  800bdf:	74 05                	je     800be6 <strtol+0x4f>
  800be1:	83 fb 10             	cmp    $0x10,%ebx
  800be4:	75 15                	jne    800bfb <strtol+0x64>
  800be6:	80 3a 30             	cmpb   $0x30,(%edx)
  800be9:	75 10                	jne    800bfb <strtol+0x64>
  800beb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bef:	75 0a                	jne    800bfb <strtol+0x64>
		s += 2, base = 16;
  800bf1:	83 c2 02             	add    $0x2,%edx
  800bf4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bf9:	eb 13                	jmp    800c0e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800bfb:	84 c0                	test   %al,%al
  800bfd:	74 0f                	je     800c0e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bff:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c04:	80 3a 30             	cmpb   $0x30,(%edx)
  800c07:	75 05                	jne    800c0e <strtol+0x77>
		s++, base = 8;
  800c09:	83 c2 01             	add    $0x1,%edx
  800c0c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c13:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c15:	0f b6 0a             	movzbl (%edx),%ecx
  800c18:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c1b:	80 fb 09             	cmp    $0x9,%bl
  800c1e:	77 08                	ja     800c28 <strtol+0x91>
			dig = *s - '0';
  800c20:	0f be c9             	movsbl %cl,%ecx
  800c23:	83 e9 30             	sub    $0x30,%ecx
  800c26:	eb 1e                	jmp    800c46 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c28:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c2b:	80 fb 19             	cmp    $0x19,%bl
  800c2e:	77 08                	ja     800c38 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c30:	0f be c9             	movsbl %cl,%ecx
  800c33:	83 e9 57             	sub    $0x57,%ecx
  800c36:	eb 0e                	jmp    800c46 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c38:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c3b:	80 fb 19             	cmp    $0x19,%bl
  800c3e:	77 15                	ja     800c55 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800c40:	0f be c9             	movsbl %cl,%ecx
  800c43:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c46:	39 f1                	cmp    %esi,%ecx
  800c48:	7d 0f                	jge    800c59 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800c4a:	83 c2 01             	add    $0x1,%edx
  800c4d:	0f af c6             	imul   %esi,%eax
  800c50:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c53:	eb c0                	jmp    800c15 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c55:	89 c1                	mov    %eax,%ecx
  800c57:	eb 02                	jmp    800c5b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c59:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c5f:	74 05                	je     800c66 <strtol+0xcf>
		*endptr = (char *) s;
  800c61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c64:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c66:	89 ca                	mov    %ecx,%edx
  800c68:	f7 da                	neg    %edx
  800c6a:	85 ff                	test   %edi,%edi
  800c6c:	0f 45 c2             	cmovne %edx,%eax
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	89 1c 24             	mov    %ebx,(%esp)
  800c7d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c81:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c85:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	89 c3                	mov    %eax,%ebx
  800c92:	89 c7                	mov    %eax,%edi
  800c94:	89 c6                	mov    %eax,%esi
  800c96:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c98:	8b 1c 24             	mov    (%esp),%ebx
  800c9b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c9f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ca3:	89 ec                	mov    %ebp,%esp
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	89 1c 24             	mov    %ebx,(%esp)
  800cb0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cb4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbd:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc2:	89 d1                	mov    %edx,%ecx
  800cc4:	89 d3                	mov    %edx,%ebx
  800cc6:	89 d7                	mov    %edx,%edi
  800cc8:	89 d6                	mov    %edx,%esi
  800cca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ccc:	8b 1c 24             	mov    (%esp),%ebx
  800ccf:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cd3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cd7:	89 ec                	mov    %ebp,%esp
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	83 ec 38             	sub    $0x38,%esp
  800ce1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ce4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ce7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cef:	b8 03 00 00 00       	mov    $0x3,%eax
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	89 cb                	mov    %ecx,%ebx
  800cf9:	89 cf                	mov    %ecx,%edi
  800cfb:	89 ce                	mov    %ecx,%esi
  800cfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7e 28                	jle    800d2b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d07:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d0e:	00 
  800d0f:	c7 44 24 08 b8 12 80 	movl   $0x8012b8,0x8(%esp)
  800d16:	00 
  800d17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1e:	00 
  800d1f:	c7 04 24 d5 12 80 00 	movl   $0x8012d5,(%esp)
  800d26:	e8 41 f4 ff ff       	call   80016c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d2b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d2e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d31:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d34:	89 ec                	mov    %ebp,%esp
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	83 ec 0c             	sub    $0xc,%esp
  800d3e:	89 1c 24             	mov    %ebx,(%esp)
  800d41:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d45:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d53:	89 d1                	mov    %edx,%ecx
  800d55:	89 d3                	mov    %edx,%ebx
  800d57:	89 d7                	mov    %edx,%edi
  800d59:	89 d6                	mov    %edx,%esi
  800d5b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d5d:	8b 1c 24             	mov    (%esp),%ebx
  800d60:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d64:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d68:	89 ec                	mov    %ebp,%esp
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    
  800d6c:	00 00                	add    %al,(%eax)
	...

00800d70 <__udivdi3>:
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	83 ec 10             	sub    $0x10,%esp
  800d78:	8b 75 14             	mov    0x14(%ebp),%esi
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d81:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d84:	85 f6                	test   %esi,%esi
  800d86:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d89:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d8f:	75 2f                	jne    800dc0 <__udivdi3+0x50>
  800d91:	39 f9                	cmp    %edi,%ecx
  800d93:	77 5b                	ja     800df0 <__udivdi3+0x80>
  800d95:	85 c9                	test   %ecx,%ecx
  800d97:	75 0b                	jne    800da4 <__udivdi3+0x34>
  800d99:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9e:	31 d2                	xor    %edx,%edx
  800da0:	f7 f1                	div    %ecx
  800da2:	89 c1                	mov    %eax,%ecx
  800da4:	89 f8                	mov    %edi,%eax
  800da6:	31 d2                	xor    %edx,%edx
  800da8:	f7 f1                	div    %ecx
  800daa:	89 c7                	mov    %eax,%edi
  800dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800daf:	f7 f1                	div    %ecx
  800db1:	89 fa                	mov    %edi,%edx
  800db3:	83 c4 10             	add    $0x10,%esp
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    
  800dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dc0:	31 d2                	xor    %edx,%edx
  800dc2:	31 c0                	xor    %eax,%eax
  800dc4:	39 fe                	cmp    %edi,%esi
  800dc6:	77 eb                	ja     800db3 <__udivdi3+0x43>
  800dc8:	0f bd d6             	bsr    %esi,%edx
  800dcb:	83 f2 1f             	xor    $0x1f,%edx
  800dce:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800dd1:	75 2d                	jne    800e00 <__udivdi3+0x90>
  800dd3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800dd6:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  800dd9:	76 06                	jbe    800de1 <__udivdi3+0x71>
  800ddb:	39 fe                	cmp    %edi,%esi
  800ddd:	89 c2                	mov    %eax,%edx
  800ddf:	73 d2                	jae    800db3 <__udivdi3+0x43>
  800de1:	31 d2                	xor    %edx,%edx
  800de3:	b8 01 00 00 00       	mov    $0x1,%eax
  800de8:	eb c9                	jmp    800db3 <__udivdi3+0x43>
  800dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df0:	89 fa                	mov    %edi,%edx
  800df2:	f7 f1                	div    %ecx
  800df4:	31 d2                	xor    %edx,%edx
  800df6:	83 c4 10             	add    $0x10,%esp
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    
  800dfd:	8d 76 00             	lea    0x0(%esi),%esi
  800e00:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800e04:	b8 20 00 00 00       	mov    $0x20,%eax
  800e09:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e0c:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800e0f:	d3 e6                	shl    %cl,%esi
  800e11:	89 c1                	mov    %eax,%ecx
  800e13:	d3 ea                	shr    %cl,%edx
  800e15:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800e19:	09 f2                	or     %esi,%edx
  800e1b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  800e1e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e21:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e24:	d3 e2                	shl    %cl,%edx
  800e26:	89 c1                	mov    %eax,%ecx
  800e28:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800e2b:	89 fa                	mov    %edi,%edx
  800e2d:	d3 ea                	shr    %cl,%edx
  800e2f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800e33:	d3 e7                	shl    %cl,%edi
  800e35:	89 c1                	mov    %eax,%ecx
  800e37:	d3 ee                	shr    %cl,%esi
  800e39:	09 fe                	or     %edi,%esi
  800e3b:	89 f0                	mov    %esi,%eax
  800e3d:	f7 75 e8             	divl   -0x18(%ebp)
  800e40:	89 d7                	mov    %edx,%edi
  800e42:	89 c6                	mov    %eax,%esi
  800e44:	f7 65 f0             	mull   -0x10(%ebp)
  800e47:	39 d7                	cmp    %edx,%edi
  800e49:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800e4c:	72 22                	jb     800e70 <__udivdi3+0x100>
  800e4e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e51:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800e55:	d3 e2                	shl    %cl,%edx
  800e57:	39 c2                	cmp    %eax,%edx
  800e59:	73 05                	jae    800e60 <__udivdi3+0xf0>
  800e5b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  800e5e:	74 10                	je     800e70 <__udivdi3+0x100>
  800e60:	89 f0                	mov    %esi,%eax
  800e62:	31 d2                	xor    %edx,%edx
  800e64:	e9 4a ff ff ff       	jmp    800db3 <__udivdi3+0x43>
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	8d 46 ff             	lea    -0x1(%esi),%eax
  800e73:	31 d2                	xor    %edx,%edx
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    
  800e7c:	00 00                	add    %al,(%eax)
	...

00800e80 <__umoddi3>:
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	83 ec 20             	sub    $0x20,%esp
  800e88:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e91:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e94:	85 ff                	test   %edi,%edi
  800e96:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800e99:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e9f:	89 f2                	mov    %esi,%edx
  800ea1:	75 15                	jne    800eb8 <__umoddi3+0x38>
  800ea3:	39 f1                	cmp    %esi,%ecx
  800ea5:	76 41                	jbe    800ee8 <__umoddi3+0x68>
  800ea7:	f7 f1                	div    %ecx
  800ea9:	89 d0                	mov    %edx,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	83 c4 20             	add    $0x20,%esp
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    
  800eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	39 f7                	cmp    %esi,%edi
  800eba:	77 4c                	ja     800f08 <__umoddi3+0x88>
  800ebc:	0f bd c7             	bsr    %edi,%eax
  800ebf:	83 f0 1f             	xor    $0x1f,%eax
  800ec2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ec5:	75 51                	jne    800f18 <__umoddi3+0x98>
  800ec7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800eca:	0f 87 e8 00 00 00    	ja     800fb8 <__umoddi3+0x138>
  800ed0:	89 f2                	mov    %esi,%edx
  800ed2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800ed5:	29 ce                	sub    %ecx,%esi
  800ed7:	19 fa                	sbb    %edi,%edx
  800ed9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800edf:	83 c4 20             	add    $0x20,%esp
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    
  800ee6:	66 90                	xchg   %ax,%ax
  800ee8:	85 c9                	test   %ecx,%ecx
  800eea:	75 0b                	jne    800ef7 <__umoddi3+0x77>
  800eec:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef1:	31 d2                	xor    %edx,%edx
  800ef3:	f7 f1                	div    %ecx
  800ef5:	89 c1                	mov    %eax,%ecx
  800ef7:	89 f0                	mov    %esi,%eax
  800ef9:	31 d2                	xor    %edx,%edx
  800efb:	f7 f1                	div    %ecx
  800efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f00:	eb a5                	jmp    800ea7 <__umoddi3+0x27>
  800f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f08:	89 f2                	mov    %esi,%edx
  800f0a:	83 c4 20             	add    $0x20,%esp
  800f0d:	5e                   	pop    %esi
  800f0e:	5f                   	pop    %edi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    
  800f11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f18:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800f1c:	89 f2                	mov    %esi,%edx
  800f1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f21:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  800f28:	29 45 f0             	sub    %eax,-0x10(%ebp)
  800f2b:	d3 e7                	shl    %cl,%edi
  800f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f30:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800f34:	d3 e8                	shr    %cl,%eax
  800f36:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800f3a:	09 f8                	or     %edi,%eax
  800f3c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f42:	d3 e0                	shl    %cl,%eax
  800f44:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800f48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f4e:	d3 ea                	shr    %cl,%edx
  800f50:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800f54:	d3 e6                	shl    %cl,%esi
  800f56:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800f5a:	d3 e8                	shr    %cl,%eax
  800f5c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800f60:	09 f0                	or     %esi,%eax
  800f62:	8b 75 e8             	mov    -0x18(%ebp),%esi
  800f65:	f7 75 e4             	divl   -0x1c(%ebp)
  800f68:	d3 e6                	shl    %cl,%esi
  800f6a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800f6d:	89 d6                	mov    %edx,%esi
  800f6f:	f7 65 f4             	mull   -0xc(%ebp)
  800f72:	89 d7                	mov    %edx,%edi
  800f74:	89 c2                	mov    %eax,%edx
  800f76:	39 fe                	cmp    %edi,%esi
  800f78:	89 f9                	mov    %edi,%ecx
  800f7a:	72 30                	jb     800fac <__umoddi3+0x12c>
  800f7c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800f7f:	72 27                	jb     800fa8 <__umoddi3+0x128>
  800f81:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f84:	29 d0                	sub    %edx,%eax
  800f86:	19 ce                	sbb    %ecx,%esi
  800f88:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800f8c:	89 f2                	mov    %esi,%edx
  800f8e:	d3 e8                	shr    %cl,%eax
  800f90:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800f94:	d3 e2                	shl    %cl,%edx
  800f96:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800f9a:	09 d0                	or     %edx,%eax
  800f9c:	89 f2                	mov    %esi,%edx
  800f9e:	d3 ea                	shr    %cl,%edx
  800fa0:	83 c4 20             	add    $0x20,%esp
  800fa3:	5e                   	pop    %esi
  800fa4:	5f                   	pop    %edi
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    
  800fa7:	90                   	nop
  800fa8:	39 fe                	cmp    %edi,%esi
  800faa:	75 d5                	jne    800f81 <__umoddi3+0x101>
  800fac:	89 f9                	mov    %edi,%ecx
  800fae:	89 c2                	mov    %eax,%edx
  800fb0:	2b 55 f4             	sub    -0xc(%ebp),%edx
  800fb3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800fb6:	eb c9                	jmp    800f81 <__umoddi3+0x101>
  800fb8:	39 f7                	cmp    %esi,%edi
  800fba:	0f 82 10 ff ff ff    	jb     800ed0 <__umoddi3+0x50>
  800fc0:	e9 17 ff ff ff       	jmp    800edc <__umoddi3+0x5c>
