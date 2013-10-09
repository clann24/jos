
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 20 12 80 00 	movl   $0x801220,(%esp)
  80004e:	e8 54 01 00 00       	call   8001a7 <cprintf>
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 4f 0c 00 00       	call   800cac <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 40 12 80 00 	movl   $0x801240,(%esp)
  800074:	e8 2e 01 00 00       	call   8001a7 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	83 c3 01             	add    $0x1,%ebx
  80007c:	83 fb 05             	cmp    $0x5,%ebx
  80007f:	75 d7                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800081:	a1 04 20 80 00       	mov    0x802004,%eax
  800086:	8b 40 48             	mov    0x48(%eax),%eax
  800089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008d:	c7 04 24 6c 12 80 00 	movl   $0x80126c,(%esp)
  800094:	e8 0e 01 00 00       	call   8001a7 <cprintf>
}
  800099:	83 c4 14             	add    $0x14,%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
  8000a6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000a9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  8000b2:	e8 c1 0b 00 00       	call   800c78 <sys_getenvid>
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c4:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c9:	85 f6                	test   %esi,%esi
  8000cb:	7e 07                	jle    8000d4 <libmain+0x34>
		binaryname = argv[0];
  8000cd:	8b 03                	mov    (%ebx),%eax
  8000cf:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d8:	89 34 24             	mov    %esi,(%esp)
  8000db:	e8 54 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e0:	e8 0b 00 00 00       	call   8000f0 <exit>
}
  8000e5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    
	...

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fd:	e8 19 0b 00 00       	call   800c1b <sys_env_destroy>
}
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	53                   	push   %ebx
  800108:	83 ec 14             	sub    $0x14,%esp
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010e:	8b 03                	mov    (%ebx),%eax
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800117:	83 c0 01             	add    $0x1,%eax
  80011a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80011c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800121:	75 19                	jne    80013c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800123:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80012a:	00 
  80012b:	8d 43 08             	lea    0x8(%ebx),%eax
  80012e:	89 04 24             	mov    %eax,(%esp)
  800131:	e8 7e 0a 00 00       	call   800bb4 <sys_cputs>
		b->idx = 0;
  800136:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80013c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800140:	83 c4 14             	add    $0x14,%esp
  800143:	5b                   	pop    %ebx
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80014f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800156:	00 00 00 
	b.cnt = 0;
  800159:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800160:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800163:	8b 45 0c             	mov    0xc(%ebp),%eax
  800166:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800171:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017b:	c7 04 24 04 01 80 00 	movl   $0x800104,(%esp)
  800182:	e8 ea 01 00 00       	call   800371 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800187:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80018d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800191:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800197:	89 04 24             	mov    %eax,(%esp)
  80019a:	e8 15 0a 00 00       	call   800bb4 <sys_cputs>

	return b.cnt;
}
  80019f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ad:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 87 ff ff ff       	call   800146 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    
	...

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 4c             	sub    $0x4c,%esp
  8001d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001dc:	89 d6                	mov    %edx,%esi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ed:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001f5:	39 d0                	cmp    %edx,%eax
  8001f7:	72 11                	jb     80020a <printnum+0x3a>
  8001f9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001fc:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8001ff:	76 09                	jbe    80020a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800201:	83 eb 01             	sub    $0x1,%ebx
  800204:	85 db                	test   %ebx,%ebx
  800206:	7f 5d                	jg     800265 <printnum+0x95>
  800208:	eb 6c                	jmp    800276 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80020e:	83 eb 01             	sub    $0x1,%ebx
  800211:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800215:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800218:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80021c:	8b 44 24 08          	mov    0x8(%esp),%eax
  800220:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800224:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800227:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80022a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800231:	00 
  800232:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800235:	89 14 24             	mov    %edx,(%esp)
  800238:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80023b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80023f:	e8 6c 0d 00 00       	call   800fb0 <__udivdi3>
  800244:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800247:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80024a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80024e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800252:	89 04 24             	mov    %eax,(%esp)
  800255:	89 54 24 04          	mov    %edx,0x4(%esp)
  800259:	89 f2                	mov    %esi,%edx
  80025b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80025e:	e8 6d ff ff ff       	call   8001d0 <printnum>
  800263:	eb 11                	jmp    800276 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800265:	89 74 24 04          	mov    %esi,0x4(%esp)
  800269:	89 3c 24             	mov    %edi,(%esp)
  80026c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026f:	83 eb 01             	sub    $0x1,%ebx
  800272:	85 db                	test   %ebx,%ebx
  800274:	7f ef                	jg     800265 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800276:	89 74 24 04          	mov    %esi,0x4(%esp)
  80027a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80027e:	8b 45 10             	mov    0x10(%ebp),%eax
  800281:	89 44 24 08          	mov    %eax,0x8(%esp)
  800285:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028c:	00 
  80028d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800290:	89 14 24             	mov    %edx,(%esp)
  800293:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800296:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80029a:	e8 21 0e 00 00       	call   8010c0 <__umoddi3>
  80029f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a3:	0f be 80 95 12 80 00 	movsbl 0x801295(%eax),%eax
  8002aa:	89 04 24             	mov    %eax,(%esp)
  8002ad:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002b0:	83 c4 4c             	add    $0x4c,%esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bb:	83 fa 01             	cmp    $0x1,%edx
  8002be:	7e 0e                	jle    8002ce <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	8b 52 04             	mov    0x4(%edx),%edx
  8002cc:	eb 22                	jmp    8002f0 <getuint+0x38>
	else if (lflag)
  8002ce:	85 d2                	test   %edx,%edx
  8002d0:	74 10                	je     8002e2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 02                	mov    (%edx),%eax
  8002db:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e0:	eb 0e                	jmp    8002f0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 02                	mov    (%edx),%eax
  8002eb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f5:	83 fa 01             	cmp    $0x1,%edx
  8002f8:	7e 0e                	jle    800308 <getint+0x16>
		return va_arg(*ap, long long);
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 02                	mov    (%edx),%eax
  800303:	8b 52 04             	mov    0x4(%edx),%edx
  800306:	eb 22                	jmp    80032a <getint+0x38>
	else if (lflag)
  800308:	85 d2                	test   %edx,%edx
  80030a:	74 10                	je     80031c <getint+0x2a>
		return va_arg(*ap, long);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	89 c2                	mov    %eax,%edx
  800317:	c1 fa 1f             	sar    $0x1f,%edx
  80031a:	eb 0e                	jmp    80032a <getint+0x38>
	else
		return va_arg(*ap, int);
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800321:	89 08                	mov    %ecx,(%eax)
  800323:	8b 02                	mov    (%edx),%eax
  800325:	89 c2                	mov    %eax,%edx
  800327:	c1 fa 1f             	sar    $0x1f,%edx
}
  80032a:	5d                   	pop    %ebp
  80032b:	c3                   	ret    

0080032c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800332:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800336:	8b 10                	mov    (%eax),%edx
  800338:	3b 50 04             	cmp    0x4(%eax),%edx
  80033b:	73 0a                	jae    800347 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800340:	88 0a                	mov    %cl,(%edx)
  800342:	83 c2 01             	add    $0x1,%edx
  800345:	89 10                	mov    %edx,(%eax)
}
  800347:	5d                   	pop    %ebp
  800348:	c3                   	ret    

00800349 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80034f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800352:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800356:	8b 45 10             	mov    0x10(%ebp),%eax
  800359:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800360:	89 44 24 04          	mov    %eax,0x4(%esp)
  800364:	8b 45 08             	mov    0x8(%ebp),%eax
  800367:	89 04 24             	mov    %eax,(%esp)
  80036a:	e8 02 00 00 00       	call   800371 <vprintfmt>
	va_end(ap);
}
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	57                   	push   %edi
  800375:	56                   	push   %esi
  800376:	53                   	push   %ebx
  800377:	83 ec 4c             	sub    $0x4c,%esp
  80037a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037d:	eb 23                	jmp    8003a2 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80037f:	85 c0                	test   %eax,%eax
  800381:	75 12                	jne    800395 <vprintfmt+0x24>
				csa = 0x0700;
  800383:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80038a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80038d:	83 c4 4c             	add    $0x4c,%esp
  800390:	5b                   	pop    %ebx
  800391:	5e                   	pop    %esi
  800392:	5f                   	pop    %edi
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 54 24 04          	mov    %edx,0x4(%esp)
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a2:	0f b6 07             	movzbl (%edi),%eax
  8003a5:	83 c7 01             	add    $0x1,%edi
  8003a8:	83 f8 25             	cmp    $0x25,%eax
  8003ab:	75 d2                	jne    80037f <vprintfmt+0xe>
  8003ad:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003b1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003b8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8003bd:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003c4:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c9:	be 00 00 00 00       	mov    $0x0,%esi
  8003ce:	eb 14                	jmp    8003e4 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003d4:	eb 0e                	jmp    8003e4 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d6:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003da:	eb 08                	jmp    8003e4 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003dc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003df:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	0f b6 07             	movzbl (%edi),%eax
  8003e7:	0f b6 c8             	movzbl %al,%ecx
  8003ea:	83 c7 01             	add    $0x1,%edi
  8003ed:	83 e8 23             	sub    $0x23,%eax
  8003f0:	3c 55                	cmp    $0x55,%al
  8003f2:	0f 87 ed 02 00 00    	ja     8006e5 <vprintfmt+0x374>
  8003f8:	0f b6 c0             	movzbl %al,%eax
  8003fb:	ff 24 85 60 13 80 00 	jmp    *0x801360(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800402:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  800405:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800408:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80040b:	83 f9 09             	cmp    $0x9,%ecx
  80040e:	77 3c                	ja     80044c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800410:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800413:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  800416:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  80041a:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80041d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800420:	83 f9 09             	cmp    $0x9,%ecx
  800423:	76 eb                	jbe    800410 <vprintfmt+0x9f>
  800425:	eb 25                	jmp    80044c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800427:	8b 45 14             	mov    0x14(%ebp),%eax
  80042a:	8d 48 04             	lea    0x4(%eax),%ecx
  80042d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800430:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  800432:	eb 18                	jmp    80044c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  800434:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800438:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80043b:	0f 48 c6             	cmovs  %esi,%eax
  80043e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800441:	eb a1                	jmp    8003e4 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  800443:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80044a:	eb 98                	jmp    8003e4 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  80044c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800450:	79 92                	jns    8003e4 <vprintfmt+0x73>
  800452:	eb 88                	jmp    8003dc <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800454:	83 c2 01             	add    $0x1,%edx
  800457:	eb 8b                	jmp    8003e4 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8d 50 04             	lea    0x4(%eax),%edx
  80045f:	89 55 14             	mov    %edx,0x14(%ebp)
  800462:	8b 55 0c             	mov    0xc(%ebp),%edx
  800465:	89 54 24 04          	mov    %edx,0x4(%esp)
  800469:	8b 00                	mov    (%eax),%eax
  80046b:	89 04 24             	mov    %eax,(%esp)
  80046e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800471:	e9 2c ff ff ff       	jmp    8003a2 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 50 04             	lea    0x4(%eax),%edx
  80047c:	89 55 14             	mov    %edx,0x14(%ebp)
  80047f:	8b 00                	mov    (%eax),%eax
  800481:	89 c2                	mov    %eax,%edx
  800483:	c1 fa 1f             	sar    $0x1f,%edx
  800486:	31 d0                	xor    %edx,%eax
  800488:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048a:	83 f8 08             	cmp    $0x8,%eax
  80048d:	7f 0b                	jg     80049a <vprintfmt+0x129>
  80048f:	8b 14 85 c0 14 80 00 	mov    0x8014c0(,%eax,4),%edx
  800496:	85 d2                	test   %edx,%edx
  800498:	75 23                	jne    8004bd <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80049a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049e:	c7 44 24 08 ad 12 80 	movl   $0x8012ad,0x8(%esp)
  8004a5:	00 
  8004a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b0:	89 04 24             	mov    %eax,(%esp)
  8004b3:	e8 91 fe ff ff       	call   800349 <printfmt>
  8004b8:	e9 e5 fe ff ff       	jmp    8003a2 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8004bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004c1:	c7 44 24 08 b6 12 80 	movl   $0x8012b6,0x8(%esp)
  8004c8:	00 
  8004c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004d3:	89 1c 24             	mov    %ebx,(%esp)
  8004d6:	e8 6e fe ff ff       	call   800349 <printfmt>
  8004db:	e9 c2 fe ff ff       	jmp    8003a2 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8d 50 04             	lea    0x4(%eax),%edx
  8004ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f2:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004f4:	85 f6                	test   %esi,%esi
  8004f6:	ba a6 12 80 00       	mov    $0x8012a6,%edx
  8004fb:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8004fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800502:	7e 06                	jle    80050a <vprintfmt+0x199>
  800504:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800508:	75 13                	jne    80051d <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050a:	0f be 06             	movsbl (%esi),%eax
  80050d:	83 c6 01             	add    $0x1,%esi
  800510:	85 c0                	test   %eax,%eax
  800512:	0f 85 a2 00 00 00    	jne    8005ba <vprintfmt+0x249>
  800518:	e9 92 00 00 00       	jmp    8005af <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800521:	89 34 24             	mov    %esi,(%esp)
  800524:	e8 82 02 00 00       	call   8007ab <strnlen>
  800529:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80052c:	29 c2                	sub    %eax,%edx
  80052e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800531:	85 d2                	test   %edx,%edx
  800533:	7e d5                	jle    80050a <vprintfmt+0x199>
					putch(padc, putdat);
  800535:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800539:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80053c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80053f:	89 d3                	mov    %edx,%ebx
  800541:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800544:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800547:	89 c6                	mov    %eax,%esi
  800549:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054d:	89 34 24             	mov    %esi,(%esp)
  800550:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800553:	83 eb 01             	sub    $0x1,%ebx
  800556:	85 db                	test   %ebx,%ebx
  800558:	7f ef                	jg     800549 <vprintfmt+0x1d8>
  80055a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80055d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800560:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800563:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80056a:	eb 9e                	jmp    80050a <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80056c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800570:	74 1b                	je     80058d <vprintfmt+0x21c>
  800572:	8d 50 e0             	lea    -0x20(%eax),%edx
  800575:	83 fa 5e             	cmp    $0x5e,%edx
  800578:	76 13                	jbe    80058d <vprintfmt+0x21c>
					putch('?', putdat);
  80057a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80057d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800581:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800588:	ff 55 08             	call   *0x8(%ebp)
  80058b:	eb 0d                	jmp    80059a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80058d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800590:	89 54 24 04          	mov    %edx,0x4(%esp)
  800594:	89 04 24             	mov    %eax,(%esp)
  800597:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059a:	83 ef 01             	sub    $0x1,%edi
  80059d:	0f be 06             	movsbl (%esi),%eax
  8005a0:	85 c0                	test   %eax,%eax
  8005a2:	74 05                	je     8005a9 <vprintfmt+0x238>
  8005a4:	83 c6 01             	add    $0x1,%esi
  8005a7:	eb 17                	jmp    8005c0 <vprintfmt+0x24f>
  8005a9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005ac:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b3:	7f 1c                	jg     8005d1 <vprintfmt+0x260>
  8005b5:	e9 e8 fd ff ff       	jmp    8003a2 <vprintfmt+0x31>
  8005ba:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8005bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c0:	85 db                	test   %ebx,%ebx
  8005c2:	78 a8                	js     80056c <vprintfmt+0x1fb>
  8005c4:	83 eb 01             	sub    $0x1,%ebx
  8005c7:	79 a3                	jns    80056c <vprintfmt+0x1fb>
  8005c9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005cc:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005cf:	eb de                	jmp    8005af <vprintfmt+0x23e>
  8005d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d7:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005e5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e7:	83 eb 01             	sub    $0x1,%ebx
  8005ea:	85 db                	test   %ebx,%ebx
  8005ec:	7f ec                	jg     8005da <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005f1:	e9 ac fd ff ff       	jmp    8003a2 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f9:	e8 f4 fc ff ff       	call   8002f2 <getint>
  8005fe:	89 c3                	mov    %eax,%ebx
  800600:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800602:	85 d2                	test   %edx,%edx
  800604:	78 0a                	js     800610 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800606:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80060b:	e9 87 00 00 00       	jmp    800697 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800610:	8b 45 0c             	mov    0xc(%ebp),%eax
  800613:	89 44 24 04          	mov    %eax,0x4(%esp)
  800617:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80061e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800621:	89 d8                	mov    %ebx,%eax
  800623:	89 f2                	mov    %esi,%edx
  800625:	f7 d8                	neg    %eax
  800627:	83 d2 00             	adc    $0x0,%edx
  80062a:	f7 da                	neg    %edx
			}
			base = 10;
  80062c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800631:	eb 64                	jmp    800697 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 7d fc ff ff       	call   8002b8 <getuint>
			base = 10;
  80063b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800640:	eb 55                	jmp    800697 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
  800645:	e8 6e fc ff ff       	call   8002b8 <getuint>
      base = 8;
  80064a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80064f:	eb 46                	jmp    800697 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800651:	8b 55 0c             	mov    0xc(%ebp),%edx
  800654:	89 54 24 04          	mov    %edx,0x4(%esp)
  800658:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80065f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800662:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800665:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800669:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800670:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8d 50 04             	lea    0x4(%eax),%edx
  800679:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067c:	8b 00                	mov    (%eax),%eax
  80067e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800683:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800688:	eb 0d                	jmp    800697 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068a:	8d 45 14             	lea    0x14(%ebp),%eax
  80068d:	e8 26 fc ff ff       	call   8002b8 <getuint>
			base = 16;
  800692:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800697:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80069b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80069f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006a6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006aa:	89 04 24             	mov    %eax,(%esp)
  8006ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	e8 14 fb ff ff       	call   8001d0 <printnum>
			break;
  8006bc:	e9 e1 fc ff ff       	jmp    8003a2 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c8:	89 0c 24             	mov    %ecx,(%esp)
  8006cb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006ce:	e9 cf fc ff ff       	jmp    8003a2 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d6:	e8 17 fc ff ff       	call   8002f2 <getint>
			csa = num;
  8006db:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  8006e0:	e9 bd fc ff ff       	jmp    8003a2 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ec:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006f3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f6:	83 ef 01             	sub    $0x1,%edi
  8006f9:	eb 02                	jmp    8006fd <vprintfmt+0x38c>
  8006fb:	89 c7                	mov    %eax,%edi
  8006fd:	8d 47 ff             	lea    -0x1(%edi),%eax
  800700:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800704:	75 f5                	jne    8006fb <vprintfmt+0x38a>
  800706:	e9 97 fc ff ff       	jmp    8003a2 <vprintfmt+0x31>

0080070b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	83 ec 28             	sub    $0x28,%esp
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800717:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800721:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800728:	85 c0                	test   %eax,%eax
  80072a:	74 30                	je     80075c <vsnprintf+0x51>
  80072c:	85 d2                	test   %edx,%edx
  80072e:	7e 2c                	jle    80075c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800737:	8b 45 10             	mov    0x10(%ebp),%eax
  80073a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800741:	89 44 24 04          	mov    %eax,0x4(%esp)
  800745:	c7 04 24 2c 03 80 00 	movl   $0x80032c,(%esp)
  80074c:	e8 20 fc ff ff       	call   800371 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800751:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800754:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075a:	eb 05                	jmp    800761 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800769:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800770:	8b 45 10             	mov    0x10(%ebp),%eax
  800773:	89 44 24 08          	mov    %eax,0x8(%esp)
  800777:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	89 04 24             	mov    %eax,(%esp)
  800784:	e8 82 ff ff ff       	call   80070b <vsnprintf>
	va_end(ap);

	return rc;
}
  800789:	c9                   	leave  
  80078a:	c3                   	ret    
  80078b:	00 00                	add    %al,(%eax)
  80078d:	00 00                	add    %al,(%eax)
	...

00800790 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
  80079b:	80 3a 00             	cmpb   $0x0,(%edx)
  80079e:	74 09                	je     8007a9 <strlen+0x19>
		n++;
  8007a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a7:	75 f7                	jne    8007a0 <strlen+0x10>
		n++;
	return n;
}
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b9:	85 d2                	test   %edx,%edx
  8007bb:	74 12                	je     8007cf <strnlen+0x24>
  8007bd:	80 39 00             	cmpb   $0x0,(%ecx)
  8007c0:	74 0d                	je     8007cf <strnlen+0x24>
		n++;
  8007c2:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	39 d0                	cmp    %edx,%eax
  8007c7:	74 06                	je     8007cf <strnlen+0x24>
  8007c9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007cd:	75 f3                	jne    8007c2 <strnlen+0x17>
		n++;
	return n;
}
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	53                   	push   %ebx
  8007d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007db:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007e4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007e7:	83 c2 01             	add    $0x1,%edx
  8007ea:	84 c9                	test   %cl,%cl
  8007ec:	75 f2                	jne    8007e0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007ee:	5b                   	pop    %ebx
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fb:	89 1c 24             	mov    %ebx,(%esp)
  8007fe:	e8 8d ff ff ff       	call   800790 <strlen>
	strcpy(dst + len, src);
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	89 54 24 04          	mov    %edx,0x4(%esp)
  80080a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80080d:	89 04 24             	mov    %eax,(%esp)
  800810:	e8 bc ff ff ff       	call   8007d1 <strcpy>
	return dst;
}
  800815:	89 d8                	mov    %ebx,%eax
  800817:	83 c4 08             	add    $0x8,%esp
  80081a:	5b                   	pop    %ebx
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	56                   	push   %esi
  800821:	53                   	push   %ebx
  800822:	8b 45 08             	mov    0x8(%ebp),%eax
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
  800828:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082b:	85 f6                	test   %esi,%esi
  80082d:	74 18                	je     800847 <strncpy+0x2a>
  80082f:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800834:	0f b6 1a             	movzbl (%edx),%ebx
  800837:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083a:	80 3a 01             	cmpb   $0x1,(%edx)
  80083d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800840:	83 c1 01             	add    $0x1,%ecx
  800843:	39 ce                	cmp    %ecx,%esi
  800845:	77 ed                	ja     800834 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800847:	5b                   	pop    %ebx
  800848:	5e                   	pop    %esi
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	8b 75 08             	mov    0x8(%ebp),%esi
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
  800856:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800859:	89 f0                	mov    %esi,%eax
  80085b:	85 c9                	test   %ecx,%ecx
  80085d:	74 23                	je     800882 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  80085f:	83 e9 01             	sub    $0x1,%ecx
  800862:	74 1b                	je     80087f <strlcpy+0x34>
  800864:	0f b6 1a             	movzbl (%edx),%ebx
  800867:	84 db                	test   %bl,%bl
  800869:	74 14                	je     80087f <strlcpy+0x34>
			*dst++ = *src++;
  80086b:	88 18                	mov    %bl,(%eax)
  80086d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800870:	83 e9 01             	sub    $0x1,%ecx
  800873:	74 0a                	je     80087f <strlcpy+0x34>
			*dst++ = *src++;
  800875:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800878:	0f b6 1a             	movzbl (%edx),%ebx
  80087b:	84 db                	test   %bl,%bl
  80087d:	75 ec                	jne    80086b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80087f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800882:	29 f0                	sub    %esi,%eax
}
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800891:	0f b6 01             	movzbl (%ecx),%eax
  800894:	84 c0                	test   %al,%al
  800896:	74 15                	je     8008ad <strcmp+0x25>
  800898:	3a 02                	cmp    (%edx),%al
  80089a:	75 11                	jne    8008ad <strcmp+0x25>
		p++, q++;
  80089c:	83 c1 01             	add    $0x1,%ecx
  80089f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a2:	0f b6 01             	movzbl (%ecx),%eax
  8008a5:	84 c0                	test   %al,%al
  8008a7:	74 04                	je     8008ad <strcmp+0x25>
  8008a9:	3a 02                	cmp    (%edx),%al
  8008ab:	74 ef                	je     80089c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ad:	0f b6 c0             	movzbl %al,%eax
  8008b0:	0f b6 12             	movzbl (%edx),%edx
  8008b3:	29 d0                	sub    %edx,%eax
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008c1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c4:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c9:	85 d2                	test   %edx,%edx
  8008cb:	74 28                	je     8008f5 <strncmp+0x3e>
  8008cd:	0f b6 01             	movzbl (%ecx),%eax
  8008d0:	84 c0                	test   %al,%al
  8008d2:	74 24                	je     8008f8 <strncmp+0x41>
  8008d4:	3a 03                	cmp    (%ebx),%al
  8008d6:	75 20                	jne    8008f8 <strncmp+0x41>
  8008d8:	83 ea 01             	sub    $0x1,%edx
  8008db:	74 13                	je     8008f0 <strncmp+0x39>
		n--, p++, q++;
  8008dd:	83 c1 01             	add    $0x1,%ecx
  8008e0:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e3:	0f b6 01             	movzbl (%ecx),%eax
  8008e6:	84 c0                	test   %al,%al
  8008e8:	74 0e                	je     8008f8 <strncmp+0x41>
  8008ea:	3a 03                	cmp    (%ebx),%al
  8008ec:	74 ea                	je     8008d8 <strncmp+0x21>
  8008ee:	eb 08                	jmp    8008f8 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f5:	5b                   	pop    %ebx
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f8:	0f b6 01             	movzbl (%ecx),%eax
  8008fb:	0f b6 13             	movzbl (%ebx),%edx
  8008fe:	29 d0                	sub    %edx,%eax
  800900:	eb f3                	jmp    8008f5 <strncmp+0x3e>

00800902 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090c:	0f b6 10             	movzbl (%eax),%edx
  80090f:	84 d2                	test   %dl,%dl
  800911:	74 20                	je     800933 <strchr+0x31>
		if (*s == c)
  800913:	38 ca                	cmp    %cl,%dl
  800915:	75 0b                	jne    800922 <strchr+0x20>
  800917:	eb 1f                	jmp    800938 <strchr+0x36>
  800919:	38 ca                	cmp    %cl,%dl
  80091b:	90                   	nop
  80091c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800920:	74 16                	je     800938 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800922:	83 c0 01             	add    $0x1,%eax
  800925:	0f b6 10             	movzbl (%eax),%edx
  800928:	84 d2                	test   %dl,%dl
  80092a:	75 ed                	jne    800919 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
  800931:	eb 05                	jmp    800938 <strchr+0x36>
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800944:	0f b6 10             	movzbl (%eax),%edx
  800947:	84 d2                	test   %dl,%dl
  800949:	74 14                	je     80095f <strfind+0x25>
		if (*s == c)
  80094b:	38 ca                	cmp    %cl,%dl
  80094d:	75 06                	jne    800955 <strfind+0x1b>
  80094f:	eb 0e                	jmp    80095f <strfind+0x25>
  800951:	38 ca                	cmp    %cl,%dl
  800953:	74 0a                	je     80095f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	0f b6 10             	movzbl (%eax),%edx
  80095b:	84 d2                	test   %dl,%dl
  80095d:	75 f2                	jne    800951 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	83 ec 0c             	sub    $0xc,%esp
  800967:	89 1c 24             	mov    %ebx,(%esp)
  80096a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80096e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800972:	8b 7d 08             	mov    0x8(%ebp),%edi
  800975:	8b 45 0c             	mov    0xc(%ebp),%eax
  800978:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80097b:	85 c9                	test   %ecx,%ecx
  80097d:	74 30                	je     8009af <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800985:	75 25                	jne    8009ac <memset+0x4b>
  800987:	f6 c1 03             	test   $0x3,%cl
  80098a:	75 20                	jne    8009ac <memset+0x4b>
		c &= 0xFF;
  80098c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80098f:	89 d3                	mov    %edx,%ebx
  800991:	c1 e3 08             	shl    $0x8,%ebx
  800994:	89 d6                	mov    %edx,%esi
  800996:	c1 e6 18             	shl    $0x18,%esi
  800999:	89 d0                	mov    %edx,%eax
  80099b:	c1 e0 10             	shl    $0x10,%eax
  80099e:	09 f0                	or     %esi,%eax
  8009a0:	09 d0                	or     %edx,%eax
  8009a2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009a4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009a7:	fc                   	cld    
  8009a8:	f3 ab                	rep stos %eax,%es:(%edi)
  8009aa:	eb 03                	jmp    8009af <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ac:	fc                   	cld    
  8009ad:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009af:	89 f8                	mov    %edi,%eax
  8009b1:	8b 1c 24             	mov    (%esp),%ebx
  8009b4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009b8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8009bc:	89 ec                	mov    %ebp,%esp
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	83 ec 08             	sub    $0x8,%esp
  8009c6:	89 34 24             	mov    %esi,(%esp)
  8009c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d6:	39 c6                	cmp    %eax,%esi
  8009d8:	73 36                	jae    800a10 <memmove+0x50>
  8009da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009dd:	39 d0                	cmp    %edx,%eax
  8009df:	73 2f                	jae    800a10 <memmove+0x50>
		s += n;
		d += n;
  8009e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e4:	f6 c2 03             	test   $0x3,%dl
  8009e7:	75 1b                	jne    800a04 <memmove+0x44>
  8009e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ef:	75 13                	jne    800a04 <memmove+0x44>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 0e                	jne    800a04 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009f6:	83 ef 04             	sub    $0x4,%edi
  8009f9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ff:	fd                   	std    
  800a00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a02:	eb 09                	jmp    800a0d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a04:	83 ef 01             	sub    $0x1,%edi
  800a07:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a0a:	fd                   	std    
  800a0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0d:	fc                   	cld    
  800a0e:	eb 20                	jmp    800a30 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a10:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a16:	75 13                	jne    800a2b <memmove+0x6b>
  800a18:	a8 03                	test   $0x3,%al
  800a1a:	75 0f                	jne    800a2b <memmove+0x6b>
  800a1c:	f6 c1 03             	test   $0x3,%cl
  800a1f:	75 0a                	jne    800a2b <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a21:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a24:	89 c7                	mov    %eax,%edi
  800a26:	fc                   	cld    
  800a27:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a29:	eb 05                	jmp    800a30 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a2b:	89 c7                	mov    %eax,%edi
  800a2d:	fc                   	cld    
  800a2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a30:	8b 34 24             	mov    (%esp),%esi
  800a33:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a37:	89 ec                	mov    %ebp,%esp
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a41:	8b 45 10             	mov    0x10(%ebp),%eax
  800a44:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	89 04 24             	mov    %eax,(%esp)
  800a55:	e8 66 ff ff ff       	call   8009c0 <memmove>
}
  800a5a:	c9                   	leave  
  800a5b:	c3                   	ret    

00800a5c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a68:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a70:	85 ff                	test   %edi,%edi
  800a72:	74 38                	je     800aac <memcmp+0x50>
		if (*s1 != *s2)
  800a74:	0f b6 03             	movzbl (%ebx),%eax
  800a77:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7a:	83 ef 01             	sub    $0x1,%edi
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a82:	38 c8                	cmp    %cl,%al
  800a84:	74 1d                	je     800aa3 <memcmp+0x47>
  800a86:	eb 11                	jmp    800a99 <memcmp+0x3d>
  800a88:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a8d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800a92:	83 c2 01             	add    $0x1,%edx
  800a95:	38 c8                	cmp    %cl,%al
  800a97:	74 0a                	je     800aa3 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800a99:	0f b6 c0             	movzbl %al,%eax
  800a9c:	0f b6 c9             	movzbl %cl,%ecx
  800a9f:	29 c8                	sub    %ecx,%eax
  800aa1:	eb 09                	jmp    800aac <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa3:	39 fa                	cmp    %edi,%edx
  800aa5:	75 e1                	jne    800a88 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ab7:	89 c2                	mov    %eax,%edx
  800ab9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800abc:	39 d0                	cmp    %edx,%eax
  800abe:	73 15                	jae    800ad5 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ac4:	38 08                	cmp    %cl,(%eax)
  800ac6:	75 06                	jne    800ace <memfind+0x1d>
  800ac8:	eb 0b                	jmp    800ad5 <memfind+0x24>
  800aca:	38 08                	cmp    %cl,(%eax)
  800acc:	74 07                	je     800ad5 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ace:	83 c0 01             	add    $0x1,%eax
  800ad1:	39 c2                	cmp    %eax,%edx
  800ad3:	77 f5                	ja     800aca <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
  800add:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae3:	0f b6 02             	movzbl (%edx),%eax
  800ae6:	3c 20                	cmp    $0x20,%al
  800ae8:	74 04                	je     800aee <strtol+0x17>
  800aea:	3c 09                	cmp    $0x9,%al
  800aec:	75 0e                	jne    800afc <strtol+0x25>
		s++;
  800aee:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af1:	0f b6 02             	movzbl (%edx),%eax
  800af4:	3c 20                	cmp    $0x20,%al
  800af6:	74 f6                	je     800aee <strtol+0x17>
  800af8:	3c 09                	cmp    $0x9,%al
  800afa:	74 f2                	je     800aee <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800afc:	3c 2b                	cmp    $0x2b,%al
  800afe:	75 0a                	jne    800b0a <strtol+0x33>
		s++;
  800b00:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b03:	bf 00 00 00 00       	mov    $0x0,%edi
  800b08:	eb 10                	jmp    800b1a <strtol+0x43>
  800b0a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0f:	3c 2d                	cmp    $0x2d,%al
  800b11:	75 07                	jne    800b1a <strtol+0x43>
		s++, neg = 1;
  800b13:	83 c2 01             	add    $0x1,%edx
  800b16:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1a:	85 db                	test   %ebx,%ebx
  800b1c:	0f 94 c0             	sete   %al
  800b1f:	74 05                	je     800b26 <strtol+0x4f>
  800b21:	83 fb 10             	cmp    $0x10,%ebx
  800b24:	75 15                	jne    800b3b <strtol+0x64>
  800b26:	80 3a 30             	cmpb   $0x30,(%edx)
  800b29:	75 10                	jne    800b3b <strtol+0x64>
  800b2b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b2f:	75 0a                	jne    800b3b <strtol+0x64>
		s += 2, base = 16;
  800b31:	83 c2 02             	add    $0x2,%edx
  800b34:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b39:	eb 13                	jmp    800b4e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800b3b:	84 c0                	test   %al,%al
  800b3d:	74 0f                	je     800b4e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b44:	80 3a 30             	cmpb   $0x30,(%edx)
  800b47:	75 05                	jne    800b4e <strtol+0x77>
		s++, base = 8;
  800b49:	83 c2 01             	add    $0x1,%edx
  800b4c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b53:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b55:	0f b6 0a             	movzbl (%edx),%ecx
  800b58:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b5b:	80 fb 09             	cmp    $0x9,%bl
  800b5e:	77 08                	ja     800b68 <strtol+0x91>
			dig = *s - '0';
  800b60:	0f be c9             	movsbl %cl,%ecx
  800b63:	83 e9 30             	sub    $0x30,%ecx
  800b66:	eb 1e                	jmp    800b86 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b68:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b6b:	80 fb 19             	cmp    $0x19,%bl
  800b6e:	77 08                	ja     800b78 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b70:	0f be c9             	movsbl %cl,%ecx
  800b73:	83 e9 57             	sub    $0x57,%ecx
  800b76:	eb 0e                	jmp    800b86 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b78:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b7b:	80 fb 19             	cmp    $0x19,%bl
  800b7e:	77 15                	ja     800b95 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800b80:	0f be c9             	movsbl %cl,%ecx
  800b83:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b86:	39 f1                	cmp    %esi,%ecx
  800b88:	7d 0f                	jge    800b99 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800b8a:	83 c2 01             	add    $0x1,%edx
  800b8d:	0f af c6             	imul   %esi,%eax
  800b90:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b93:	eb c0                	jmp    800b55 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b95:	89 c1                	mov    %eax,%ecx
  800b97:	eb 02                	jmp    800b9b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b99:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9f:	74 05                	je     800ba6 <strtol+0xcf>
		*endptr = (char *) s;
  800ba1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba4:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ba6:	89 ca                	mov    %ecx,%edx
  800ba8:	f7 da                	neg    %edx
  800baa:	85 ff                	test   %edi,%edi
  800bac:	0f 45 c2             	cmovne %edx,%eax
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	89 1c 24             	mov    %ebx,(%esp)
  800bbd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bc1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	89 c3                	mov    %eax,%ebx
  800bd2:	89 c7                	mov    %eax,%edi
  800bd4:	89 c6                	mov    %eax,%esi
  800bd6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd8:	8b 1c 24             	mov    (%esp),%ebx
  800bdb:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bdf:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800be3:	89 ec                	mov    %ebp,%esp
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	83 ec 0c             	sub    $0xc,%esp
  800bed:	89 1c 24             	mov    %ebx,(%esp)
  800bf0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfd:	b8 01 00 00 00       	mov    $0x1,%eax
  800c02:	89 d1                	mov    %edx,%ecx
  800c04:	89 d3                	mov    %edx,%ebx
  800c06:	89 d7                	mov    %edx,%edi
  800c08:	89 d6                	mov    %edx,%esi
  800c0a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c0c:	8b 1c 24             	mov    (%esp),%ebx
  800c0f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c13:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c17:	89 ec                	mov    %ebp,%esp
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	83 ec 38             	sub    $0x38,%esp
  800c21:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c24:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c27:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 cb                	mov    %ecx,%ebx
  800c39:	89 cf                	mov    %ecx,%edi
  800c3b:	89 ce                	mov    %ecx,%esi
  800c3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	7e 28                	jle    800c6b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c43:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c47:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c4e:	00 
  800c4f:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800c56:	00 
  800c57:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c5e:	00 
  800c5f:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800c66:	e8 e1 02 00 00       	call   800f4c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c6b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c6e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c71:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c74:	89 ec                	mov    %ebp,%esp
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	83 ec 0c             	sub    $0xc,%esp
  800c7e:	89 1c 24             	mov    %ebx,(%esp)
  800c81:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c85:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c93:	89 d1                	mov    %edx,%ecx
  800c95:	89 d3                	mov    %edx,%ebx
  800c97:	89 d7                	mov    %edx,%edi
  800c99:	89 d6                	mov    %edx,%esi
  800c9b:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800c9d:	8b 1c 24             	mov    (%esp),%ebx
  800ca0:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ca4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ca8:	89 ec                	mov    %ebp,%esp
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_yield>:

void
sys_yield(void)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 0c             	sub    $0xc,%esp
  800cb2:	89 1c 24             	mov    %ebx,(%esp)
  800cb5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cb9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc7:	89 d1                	mov    %edx,%ecx
  800cc9:	89 d3                	mov    %edx,%ebx
  800ccb:	89 d7                	mov    %edx,%edi
  800ccd:	89 d6                	mov    %edx,%esi
  800ccf:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cd1:	8b 1c 24             	mov    (%esp),%ebx
  800cd4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cd8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cdc:	89 ec                	mov    %ebp,%esp
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 38             	sub    $0x38,%esp
  800ce6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ce9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cec:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	be 00 00 00 00       	mov    $0x0,%esi
  800cf4:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 f7                	mov    %esi,%edi
  800d04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 28                	jle    800d32 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d15:	00 
  800d16:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d25:	00 
  800d26:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800d2d:	e8 1a 02 00 00       	call   800f4c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d32:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d35:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d38:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d3b:	89 ec                	mov    %ebp,%esp
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	83 ec 38             	sub    $0x38,%esp
  800d45:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d48:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d4b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d53:	8b 75 18             	mov    0x18(%ebp),%esi
  800d56:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d64:	85 c0                	test   %eax,%eax
  800d66:	7e 28                	jle    800d90 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d68:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d73:	00 
  800d74:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800d7b:	00 
  800d7c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d83:	00 
  800d84:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800d8b:	e8 bc 01 00 00       	call   800f4c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d90:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d93:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d96:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d99:	89 ec                	mov    %ebp,%esp
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	83 ec 38             	sub    $0x38,%esp
  800da3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800da6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800da9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db1:	b8 06 00 00 00       	mov    $0x6,%eax
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	89 df                	mov    %ebx,%edi
  800dbe:	89 de                	mov    %ebx,%esi
  800dc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	7e 28                	jle    800dee <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dca:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dd1:	00 
  800dd2:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800dd9:	00 
  800dda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de1:	00 
  800de2:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800de9:	e8 5e 01 00 00       	call   800f4c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df7:	89 ec                	mov    %ebp,%esp
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	83 ec 38             	sub    $0x38,%esp
  800e01:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e04:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e07:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0f:	b8 08 00 00 00       	mov    $0x8,%eax
  800e14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e17:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1a:	89 df                	mov    %ebx,%edi
  800e1c:	89 de                	mov    %ebx,%esi
  800e1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e20:	85 c0                	test   %eax,%eax
  800e22:	7e 28                	jle    800e4c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e28:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e2f:	00 
  800e30:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800e37:	00 
  800e38:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3f:	00 
  800e40:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800e47:	e8 00 01 00 00       	call   800f4c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e4c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e4f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e52:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e55:	89 ec                	mov    %ebp,%esp
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	83 ec 38             	sub    $0x38,%esp
  800e5f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e62:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e65:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e75:	8b 55 08             	mov    0x8(%ebp),%edx
  800e78:	89 df                	mov    %ebx,%edi
  800e7a:	89 de                	mov    %ebx,%esi
  800e7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	7e 28                	jle    800eaa <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e86:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e8d:	00 
  800e8e:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800e95:	00 
  800e96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9d:	00 
  800e9e:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800ea5:	e8 a2 00 00 00       	call   800f4c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eaa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ead:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eb3:	89 ec                	mov    %ebp,%esp
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 0c             	sub    $0xc,%esp
  800ebd:	89 1c 24             	mov    %ebx,(%esp)
  800ec0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ec4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec8:	be 00 00 00 00       	mov    $0x0,%esi
  800ecd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ed2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ede:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ee0:	8b 1c 24             	mov    (%esp),%ebx
  800ee3:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ee7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800eeb:	89 ec                	mov    %ebp,%esp
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 38             	sub    $0x38,%esp
  800ef5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800efb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f03:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f08:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0b:	89 cb                	mov    %ecx,%ebx
  800f0d:	89 cf                	mov    %ecx,%edi
  800f0f:	89 ce                	mov    %ecx,%esi
  800f11:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f13:	85 c0                	test   %eax,%eax
  800f15:	7e 28                	jle    800f3f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f22:	00 
  800f23:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800f2a:	00 
  800f2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f32:	00 
  800f33:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800f3a:	e8 0d 00 00 00       	call   800f4c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f48:	89 ec                	mov    %ebp,%esp
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
  800f51:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800f54:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f57:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f5d:	e8 16 fd ff ff       	call   800c78 <sys_getenvid>
  800f62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f65:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f69:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f70:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f78:	c7 04 24 10 15 80 00 	movl   $0x801510,(%esp)
  800f7f:	e8 23 f2 ff ff       	call   8001a7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f84:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f88:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8b:	89 04 24             	mov    %eax,(%esp)
  800f8e:	e8 b3 f1 ff ff       	call   800146 <vcprintf>
	cprintf("\n");
  800f93:	c7 04 24 34 15 80 00 	movl   $0x801534,(%esp)
  800f9a:	e8 08 f2 ff ff       	call   8001a7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f9f:	cc                   	int3   
  800fa0:	eb fd                	jmp    800f9f <_panic+0x53>
	...

00800fb0 <__udivdi3>:
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	83 ec 10             	sub    $0x10,%esp
  800fb8:	8b 75 14             	mov    0x14(%ebp),%esi
  800fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fc1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fc4:	85 f6                	test   %esi,%esi
  800fc6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fc9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800fcc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800fcf:	75 2f                	jne    801000 <__udivdi3+0x50>
  800fd1:	39 f9                	cmp    %edi,%ecx
  800fd3:	77 5b                	ja     801030 <__udivdi3+0x80>
  800fd5:	85 c9                	test   %ecx,%ecx
  800fd7:	75 0b                	jne    800fe4 <__udivdi3+0x34>
  800fd9:	b8 01 00 00 00       	mov    $0x1,%eax
  800fde:	31 d2                	xor    %edx,%edx
  800fe0:	f7 f1                	div    %ecx
  800fe2:	89 c1                	mov    %eax,%ecx
  800fe4:	89 f8                	mov    %edi,%eax
  800fe6:	31 d2                	xor    %edx,%edx
  800fe8:	f7 f1                	div    %ecx
  800fea:	89 c7                	mov    %eax,%edi
  800fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fef:	f7 f1                	div    %ecx
  800ff1:	89 fa                	mov    %edi,%edx
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	5e                   	pop    %esi
  800ff7:	5f                   	pop    %edi
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    
  800ffa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801000:	31 d2                	xor    %edx,%edx
  801002:	31 c0                	xor    %eax,%eax
  801004:	39 fe                	cmp    %edi,%esi
  801006:	77 eb                	ja     800ff3 <__udivdi3+0x43>
  801008:	0f bd d6             	bsr    %esi,%edx
  80100b:	83 f2 1f             	xor    $0x1f,%edx
  80100e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801011:	75 2d                	jne    801040 <__udivdi3+0x90>
  801013:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801016:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  801019:	76 06                	jbe    801021 <__udivdi3+0x71>
  80101b:	39 fe                	cmp    %edi,%esi
  80101d:	89 c2                	mov    %eax,%edx
  80101f:	73 d2                	jae    800ff3 <__udivdi3+0x43>
  801021:	31 d2                	xor    %edx,%edx
  801023:	b8 01 00 00 00       	mov    $0x1,%eax
  801028:	eb c9                	jmp    800ff3 <__udivdi3+0x43>
  80102a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801030:	89 fa                	mov    %edi,%edx
  801032:	f7 f1                	div    %ecx
  801034:	31 d2                	xor    %edx,%edx
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    
  80103d:	8d 76 00             	lea    0x0(%esi),%esi
  801040:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801044:	b8 20 00 00 00       	mov    $0x20,%eax
  801049:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80104c:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80104f:	d3 e6                	shl    %cl,%esi
  801051:	89 c1                	mov    %eax,%ecx
  801053:	d3 ea                	shr    %cl,%edx
  801055:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801059:	09 f2                	or     %esi,%edx
  80105b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  80105e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801061:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801064:	d3 e2                	shl    %cl,%edx
  801066:	89 c1                	mov    %eax,%ecx
  801068:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80106b:	89 fa                	mov    %edi,%edx
  80106d:	d3 ea                	shr    %cl,%edx
  80106f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801073:	d3 e7                	shl    %cl,%edi
  801075:	89 c1                	mov    %eax,%ecx
  801077:	d3 ee                	shr    %cl,%esi
  801079:	09 fe                	or     %edi,%esi
  80107b:	89 f0                	mov    %esi,%eax
  80107d:	f7 75 e8             	divl   -0x18(%ebp)
  801080:	89 d7                	mov    %edx,%edi
  801082:	89 c6                	mov    %eax,%esi
  801084:	f7 65 f0             	mull   -0x10(%ebp)
  801087:	39 d7                	cmp    %edx,%edi
  801089:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80108c:	72 22                	jb     8010b0 <__udivdi3+0x100>
  80108e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801091:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801095:	d3 e2                	shl    %cl,%edx
  801097:	39 c2                	cmp    %eax,%edx
  801099:	73 05                	jae    8010a0 <__udivdi3+0xf0>
  80109b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80109e:	74 10                	je     8010b0 <__udivdi3+0x100>
  8010a0:	89 f0                	mov    %esi,%eax
  8010a2:	31 d2                	xor    %edx,%edx
  8010a4:	e9 4a ff ff ff       	jmp    800ff3 <__udivdi3+0x43>
  8010a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010b0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8010b3:	31 d2                	xor    %edx,%edx
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	5e                   	pop    %esi
  8010b9:	5f                   	pop    %edi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    
  8010bc:	00 00                	add    %al,(%eax)
	...

008010c0 <__umoddi3>:
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	57                   	push   %edi
  8010c4:	56                   	push   %esi
  8010c5:	83 ec 20             	sub    $0x20,%esp
  8010c8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010d4:	85 ff                	test   %edi,%edi
  8010d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8010d9:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8010dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8010df:	89 f2                	mov    %esi,%edx
  8010e1:	75 15                	jne    8010f8 <__umoddi3+0x38>
  8010e3:	39 f1                	cmp    %esi,%ecx
  8010e5:	76 41                	jbe    801128 <__umoddi3+0x68>
  8010e7:	f7 f1                	div    %ecx
  8010e9:	89 d0                	mov    %edx,%eax
  8010eb:	31 d2                	xor    %edx,%edx
  8010ed:	83 c4 20             	add    $0x20,%esp
  8010f0:	5e                   	pop    %esi
  8010f1:	5f                   	pop    %edi
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    
  8010f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	39 f7                	cmp    %esi,%edi
  8010fa:	77 4c                	ja     801148 <__umoddi3+0x88>
  8010fc:	0f bd c7             	bsr    %edi,%eax
  8010ff:	83 f0 1f             	xor    $0x1f,%eax
  801102:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801105:	75 51                	jne    801158 <__umoddi3+0x98>
  801107:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80110a:	0f 87 e8 00 00 00    	ja     8011f8 <__umoddi3+0x138>
  801110:	89 f2                	mov    %esi,%edx
  801112:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801115:	29 ce                	sub    %ecx,%esi
  801117:	19 fa                	sbb    %edi,%edx
  801119:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80111c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111f:	83 c4 20             	add    $0x20,%esp
  801122:	5e                   	pop    %esi
  801123:	5f                   	pop    %edi
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    
  801126:	66 90                	xchg   %ax,%ax
  801128:	85 c9                	test   %ecx,%ecx
  80112a:	75 0b                	jne    801137 <__umoddi3+0x77>
  80112c:	b8 01 00 00 00       	mov    $0x1,%eax
  801131:	31 d2                	xor    %edx,%edx
  801133:	f7 f1                	div    %ecx
  801135:	89 c1                	mov    %eax,%ecx
  801137:	89 f0                	mov    %esi,%eax
  801139:	31 d2                	xor    %edx,%edx
  80113b:	f7 f1                	div    %ecx
  80113d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801140:	eb a5                	jmp    8010e7 <__umoddi3+0x27>
  801142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801148:	89 f2                	mov    %esi,%edx
  80114a:	83 c4 20             	add    $0x20,%esp
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    
  801151:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801158:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80115c:	89 f2                	mov    %esi,%edx
  80115e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801161:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801168:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80116b:	d3 e7                	shl    %cl,%edi
  80116d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801170:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801174:	d3 e8                	shr    %cl,%eax
  801176:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80117a:	09 f8                	or     %edi,%eax
  80117c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80117f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801182:	d3 e0                	shl    %cl,%eax
  801184:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801188:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80118b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80118e:	d3 ea                	shr    %cl,%edx
  801190:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801194:	d3 e6                	shl    %cl,%esi
  801196:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80119a:	d3 e8                	shr    %cl,%eax
  80119c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011a0:	09 f0                	or     %esi,%eax
  8011a2:	8b 75 e8             	mov    -0x18(%ebp),%esi
  8011a5:	f7 75 e4             	divl   -0x1c(%ebp)
  8011a8:	d3 e6                	shl    %cl,%esi
  8011aa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8011ad:	89 d6                	mov    %edx,%esi
  8011af:	f7 65 f4             	mull   -0xc(%ebp)
  8011b2:	89 d7                	mov    %edx,%edi
  8011b4:	89 c2                	mov    %eax,%edx
  8011b6:	39 fe                	cmp    %edi,%esi
  8011b8:	89 f9                	mov    %edi,%ecx
  8011ba:	72 30                	jb     8011ec <__umoddi3+0x12c>
  8011bc:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8011bf:	72 27                	jb     8011e8 <__umoddi3+0x128>
  8011c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8011c4:	29 d0                	sub    %edx,%eax
  8011c6:	19 ce                	sbb    %ecx,%esi
  8011c8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011cc:	89 f2                	mov    %esi,%edx
  8011ce:	d3 e8                	shr    %cl,%eax
  8011d0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011d4:	d3 e2                	shl    %cl,%edx
  8011d6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011da:	09 d0                	or     %edx,%eax
  8011dc:	89 f2                	mov    %esi,%edx
  8011de:	d3 ea                	shr    %cl,%edx
  8011e0:	83 c4 20             	add    $0x20,%esp
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    
  8011e7:	90                   	nop
  8011e8:	39 fe                	cmp    %edi,%esi
  8011ea:	75 d5                	jne    8011c1 <__umoddi3+0x101>
  8011ec:	89 f9                	mov    %edi,%ecx
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	2b 55 f4             	sub    -0xc(%ebp),%edx
  8011f3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011f6:	eb c9                	jmp    8011c1 <__umoddi3+0x101>
  8011f8:	39 f7                	cmp    %esi,%edi
  8011fa:	0f 82 10 ff ff ff    	jb     801110 <__umoddi3+0x50>
  801200:	e9 17 ff ff ff       	jmp    80111c <__umoddi3+0x5c>
