
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 85 0c 00 00       	call   800cc8 <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 a0 12 80 00 	movl   $0x8012a0,(%esp)
  800052:	e8 ac 01 00 00       	call   800203 <cprintf>

	forkchild(cur, '0');
  800057:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005e:	00 
  80005f:	89 1c 24             	mov    %ebx,(%esp)
  800062:	e8 16 00 00 00       	call   80007d <forkchild>
	forkchild(cur, '1');
  800067:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006e:	00 
  80006f:	89 1c 24             	mov    %ebx,(%esp)
  800072:	e8 06 00 00 00       	call   80007d <forkchild>
}
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5d                   	pop    %ebp
  80007c:	c3                   	ret    

0080007d <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	83 ec 38             	sub    $0x38,%esp
  800083:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800086:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800089:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80008c:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  800090:	89 1c 24             	mov    %ebx,(%esp)
  800093:	e8 48 07 00 00       	call   8007e0 <strlen>
  800098:	83 f8 02             	cmp    $0x2,%eax
  80009b:	7f 41                	jg     8000de <forkchild+0x61>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009d:	89 f0                	mov    %esi,%eax
  80009f:	0f be f0             	movsbl %al,%esi
  8000a2:	89 74 24 10          	mov    %esi,0x10(%esp)
  8000a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000aa:	c7 44 24 08 b1 12 80 	movl   $0x8012b1,0x8(%esp)
  8000b1:	00 
  8000b2:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b9:	00 
  8000ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000bd:	89 04 24             	mov    %eax,(%esp)
  8000c0:	e8 ee 06 00 00       	call   8007b3 <snprintf>
	if (fork() == 0) {
  8000c5:	e8 d2 0e 00 00       	call   800f9c <fork>
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	75 10                	jne    8000de <forkchild+0x61>
		forktree(nxt);
  8000ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000d1:	89 04 24             	mov    %eax,(%esp)
  8000d4:	e8 5b ff ff ff       	call   800034 <forktree>
		exit();
  8000d9:	e8 6e 00 00 00       	call   80014c <exit>
	}
}
  8000de:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e1:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000e4:	89 ec                	mov    %ebp,%esp
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000ee:	c7 04 24 b0 12 80 00 	movl   $0x8012b0,(%esp)
  8000f5:	e8 3a ff ff ff       	call   800034 <forktree>
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 18             	sub    $0x18,%esp
  800102:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800105:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800108:	8b 75 08             	mov    0x8(%ebp),%esi
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80010e:	e8 b5 0b 00 00       	call   800cc8 <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800120:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 f6                	test   %esi,%esi
  800127:	7e 07                	jle    800130 <libmain+0x34>
		binaryname = argv[0];
  800129:	8b 03                	mov    (%ebx),%eax
  80012b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800130:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800134:	89 34 24             	mov    %esi,(%esp)
  800137:	e8 ac ff ff ff       	call   8000e8 <umain>

	// exit gracefully
	exit();
  80013c:	e8 0b 00 00 00       	call   80014c <exit>
}
  800141:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800144:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800147:	89 ec                	mov    %ebp,%esp
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800159:	e8 0d 0b 00 00       	call   800c6b <sys_env_destroy>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	53                   	push   %ebx
  800164:	83 ec 14             	sub    $0x14,%esp
  800167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016a:	8b 03                	mov    (%ebx),%eax
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800173:	83 c0 01             	add    $0x1,%eax
  800176:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800178:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017d:	75 19                	jne    800198 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80017f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800186:	00 
  800187:	8d 43 08             	lea    0x8(%ebx),%eax
  80018a:	89 04 24             	mov    %eax,(%esp)
  80018d:	e8 72 0a 00 00       	call   800c04 <sys_cputs>
		b->idx = 0;
  800192:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800198:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019c:	83 c4 14             	add    $0x14,%esp
  80019f:	5b                   	pop    %ebx
  8001a0:	5d                   	pop    %ebp
  8001a1:	c3                   	ret    

008001a2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ab:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b2:	00 00 00 
	b.cnt = 0;
  8001b5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d7:	c7 04 24 60 01 80 00 	movl   $0x800160,(%esp)
  8001de:	e8 de 01 00 00       	call   8003c1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ed:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	e8 09 0a 00 00       	call   800c04 <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800210:	8b 45 08             	mov    0x8(%ebp),%eax
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	e8 87 ff ff ff       	call   8001a2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    
  80021d:	00 00                	add    %al,(%eax)
	...

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 4c             	sub    $0x4c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d6                	mov    %edx,%esi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800234:	8b 55 0c             	mov    0xc(%ebp),%edx
  800237:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80023d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800240:	b8 00 00 00 00       	mov    $0x0,%eax
  800245:	39 d0                	cmp    %edx,%eax
  800247:	72 11                	jb     80025a <printnum+0x3a>
  800249:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80024c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  80024f:	76 09                	jbe    80025a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800251:	83 eb 01             	sub    $0x1,%ebx
  800254:	85 db                	test   %ebx,%ebx
  800256:	7f 5d                	jg     8002b5 <printnum+0x95>
  800258:	eb 6c                	jmp    8002c6 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80025e:	83 eb 01             	sub    $0x1,%ebx
  800261:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800265:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800268:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80026c:	8b 44 24 08          	mov    0x8(%esp),%eax
  800270:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800274:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800277:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80027a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800281:	00 
  800282:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800285:	89 14 24             	mov    %edx,(%esp)
  800288:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80028b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80028f:	e8 ac 0d 00 00       	call   801040 <__udivdi3>
  800294:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800297:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80029a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80029e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a2:	89 04 24             	mov    %eax,(%esp)
  8002a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002a9:	89 f2                	mov    %esi,%edx
  8002ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ae:	e8 6d ff ff ff       	call   800220 <printnum>
  8002b3:	eb 11                	jmp    8002c6 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b9:	89 3c 24             	mov    %edi,(%esp)
  8002bc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bf:	83 eb 01             	sub    $0x1,%ebx
  8002c2:	85 db                	test   %ebx,%ebx
  8002c4:	7f ef                	jg     8002b5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ca:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002dc:	00 
  8002dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002e0:	89 14 24             	mov    %edx,(%esp)
  8002e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002e6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002ea:	e8 61 0e 00 00       	call   801150 <__umoddi3>
  8002ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f3:	0f be 80 c0 12 80 00 	movsbl 0x8012c0(%eax),%eax
  8002fa:	89 04 24             	mov    %eax,(%esp)
  8002fd:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800300:	83 c4 4c             	add    $0x4c,%esp
  800303:	5b                   	pop    %ebx
  800304:	5e                   	pop    %esi
  800305:	5f                   	pop    %edi
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030b:	83 fa 01             	cmp    $0x1,%edx
  80030e:	7e 0e                	jle    80031e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 08             	lea    0x8(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	8b 52 04             	mov    0x4(%edx),%edx
  80031c:	eb 22                	jmp    800340 <getuint+0x38>
	else if (lflag)
  80031e:	85 d2                	test   %edx,%edx
  800320:	74 10                	je     800332 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800322:	8b 10                	mov    (%eax),%edx
  800324:	8d 4a 04             	lea    0x4(%edx),%ecx
  800327:	89 08                	mov    %ecx,(%eax)
  800329:	8b 02                	mov    (%edx),%eax
  80032b:	ba 00 00 00 00       	mov    $0x0,%edx
  800330:	eb 0e                	jmp    800340 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 04             	lea    0x4(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800345:	83 fa 01             	cmp    $0x1,%edx
  800348:	7e 0e                	jle    800358 <getint+0x16>
		return va_arg(*ap, long long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	8b 52 04             	mov    0x4(%edx),%edx
  800356:	eb 22                	jmp    80037a <getint+0x38>
	else if (lflag)
  800358:	85 d2                	test   %edx,%edx
  80035a:	74 10                	je     80036c <getint+0x2a>
		return va_arg(*ap, long);
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 02                	mov    (%edx),%eax
  800365:	89 c2                	mov    %eax,%edx
  800367:	c1 fa 1f             	sar    $0x1f,%edx
  80036a:	eb 0e                	jmp    80037a <getint+0x38>
	else
		return va_arg(*ap, int);
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800371:	89 08                	mov    %ecx,(%eax)
  800373:	8b 02                	mov    (%edx),%eax
  800375:	89 c2                	mov    %eax,%edx
  800377:	c1 fa 1f             	sar    $0x1f,%edx
}
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800382:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800386:	8b 10                	mov    (%eax),%edx
  800388:	3b 50 04             	cmp    0x4(%eax),%edx
  80038b:	73 0a                	jae    800397 <sprintputch+0x1b>
		*b->buf++ = ch;
  80038d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800390:	88 0a                	mov    %cl,(%edx)
  800392:	83 c2 01             	add    $0x1,%edx
  800395:	89 10                	mov    %edx,(%eax)
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80039f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b7:	89 04 24             	mov    %eax,(%esp)
  8003ba:	e8 02 00 00 00       	call   8003c1 <vprintfmt>
	va_end(ap);
}
  8003bf:	c9                   	leave  
  8003c0:	c3                   	ret    

008003c1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	57                   	push   %edi
  8003c5:	56                   	push   %esi
  8003c6:	53                   	push   %ebx
  8003c7:	83 ec 4c             	sub    $0x4c,%esp
  8003ca:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003cd:	eb 23                	jmp    8003f2 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	75 12                	jne    8003e5 <vprintfmt+0x24>
				csa = 0x0700;
  8003d3:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  8003da:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8003dd:	83 c4 4c             	add    $0x4c,%esp
  8003e0:	5b                   	pop    %ebx
  8003e1:	5e                   	pop    %esi
  8003e2:	5f                   	pop    %edi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  8003e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003ec:	89 04 24             	mov    %eax,(%esp)
  8003ef:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f2:	0f b6 07             	movzbl (%edi),%eax
  8003f5:	83 c7 01             	add    $0x1,%edi
  8003f8:	83 f8 25             	cmp    $0x25,%eax
  8003fb:	75 d2                	jne    8003cf <vprintfmt+0xe>
  8003fd:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800401:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800408:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80040d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800414:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800419:	be 00 00 00 00       	mov    $0x0,%esi
  80041e:	eb 14                	jmp    800434 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800420:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800424:	eb 0e                	jmp    800434 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800426:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80042a:	eb 08                	jmp    800434 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80042f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	0f b6 07             	movzbl (%edi),%eax
  800437:	0f b6 c8             	movzbl %al,%ecx
  80043a:	83 c7 01             	add    $0x1,%edi
  80043d:	83 e8 23             	sub    $0x23,%eax
  800440:	3c 55                	cmp    $0x55,%al
  800442:	0f 87 ed 02 00 00    	ja     800735 <vprintfmt+0x374>
  800448:	0f b6 c0             	movzbl %al,%eax
  80044b:	ff 24 85 80 13 80 00 	jmp    *0x801380(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800452:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  800455:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800458:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80045b:	83 f9 09             	cmp    $0x9,%ecx
  80045e:	77 3c                	ja     80049c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800460:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800463:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  800466:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  80046a:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80046d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800470:	83 f9 09             	cmp    $0x9,%ecx
  800473:	76 eb                	jbe    800460 <vprintfmt+0x9f>
  800475:	eb 25                	jmp    80049c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	8d 48 04             	lea    0x4(%eax),%ecx
  80047d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800480:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  800482:	eb 18                	jmp    80049c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  800484:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800488:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80048b:	0f 48 c6             	cmovs  %esi,%eax
  80048e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800491:	eb a1                	jmp    800434 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  800493:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80049a:	eb 98                	jmp    800434 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  80049c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a0:	79 92                	jns    800434 <vprintfmt+0x73>
  8004a2:	eb 88                	jmp    80042c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a4:	83 c2 01             	add    $0x1,%edx
  8004a7:	eb 8b                	jmp    800434 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	89 04 24             	mov    %eax,(%esp)
  8004be:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004c1:	e9 2c ff ff ff       	jmp    8003f2 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 50 04             	lea    0x4(%eax),%edx
  8004cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	89 c2                	mov    %eax,%edx
  8004d3:	c1 fa 1f             	sar    $0x1f,%edx
  8004d6:	31 d0                	xor    %edx,%eax
  8004d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004da:	83 f8 08             	cmp    $0x8,%eax
  8004dd:	7f 0b                	jg     8004ea <vprintfmt+0x129>
  8004df:	8b 14 85 e0 14 80 00 	mov    0x8014e0(,%eax,4),%edx
  8004e6:	85 d2                	test   %edx,%edx
  8004e8:	75 23                	jne    80050d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  8004ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ee:	c7 44 24 08 d8 12 80 	movl   $0x8012d8,0x8(%esp)
  8004f5:	00 
  8004f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800500:	89 04 24             	mov    %eax,(%esp)
  800503:	e8 91 fe ff ff       	call   800399 <printfmt>
  800508:	e9 e5 fe ff ff       	jmp    8003f2 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80050d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800511:	c7 44 24 08 e1 12 80 	movl   $0x8012e1,0x8(%esp)
  800518:	00 
  800519:	8b 55 0c             	mov    0xc(%ebp),%edx
  80051c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800520:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800523:	89 1c 24             	mov    %ebx,(%esp)
  800526:	e8 6e fe ff ff       	call   800399 <printfmt>
  80052b:	e9 c2 fe ff ff       	jmp    8003f2 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800533:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800536:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 50 04             	lea    0x4(%eax),%edx
  80053f:	89 55 14             	mov    %edx,0x14(%ebp)
  800542:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800544:	85 f6                	test   %esi,%esi
  800546:	ba d1 12 80 00       	mov    $0x8012d1,%edx
  80054b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80054e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800552:	7e 06                	jle    80055a <vprintfmt+0x199>
  800554:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800558:	75 13                	jne    80056d <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055a:	0f be 06             	movsbl (%esi),%eax
  80055d:	83 c6 01             	add    $0x1,%esi
  800560:	85 c0                	test   %eax,%eax
  800562:	0f 85 a2 00 00 00    	jne    80060a <vprintfmt+0x249>
  800568:	e9 92 00 00 00       	jmp    8005ff <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800571:	89 34 24             	mov    %esi,(%esp)
  800574:	e8 82 02 00 00       	call   8007fb <strnlen>
  800579:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057c:	29 c2                	sub    %eax,%edx
  80057e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800581:	85 d2                	test   %edx,%edx
  800583:	7e d5                	jle    80055a <vprintfmt+0x199>
					putch(padc, putdat);
  800585:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800589:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80058c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80058f:	89 d3                	mov    %edx,%ebx
  800591:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800594:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800597:	89 c6                	mov    %eax,%esi
  800599:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80059d:	89 34 24             	mov    %esi,(%esp)
  8005a0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a3:	83 eb 01             	sub    $0x1,%ebx
  8005a6:	85 db                	test   %ebx,%ebx
  8005a8:	7f ef                	jg     800599 <vprintfmt+0x1d8>
  8005aa:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005ad:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005ba:	eb 9e                	jmp    80055a <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005bc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c0:	74 1b                	je     8005dd <vprintfmt+0x21c>
  8005c2:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005c5:	83 fa 5e             	cmp    $0x5e,%edx
  8005c8:	76 13                	jbe    8005dd <vprintfmt+0x21c>
					putch('?', putdat);
  8005ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d8:	ff 55 08             	call   *0x8(%ebp)
  8005db:	eb 0d                	jmp    8005ea <vprintfmt+0x229>
				else
					putch(ch, putdat);
  8005dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005e4:	89 04 24             	mov    %eax,(%esp)
  8005e7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ea:	83 ef 01             	sub    $0x1,%edi
  8005ed:	0f be 06             	movsbl (%esi),%eax
  8005f0:	85 c0                	test   %eax,%eax
  8005f2:	74 05                	je     8005f9 <vprintfmt+0x238>
  8005f4:	83 c6 01             	add    $0x1,%esi
  8005f7:	eb 17                	jmp    800610 <vprintfmt+0x24f>
  8005f9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005fc:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800603:	7f 1c                	jg     800621 <vprintfmt+0x260>
  800605:	e9 e8 fd ff ff       	jmp    8003f2 <vprintfmt+0x31>
  80060a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80060d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800610:	85 db                	test   %ebx,%ebx
  800612:	78 a8                	js     8005bc <vprintfmt+0x1fb>
  800614:	83 eb 01             	sub    $0x1,%ebx
  800617:	79 a3                	jns    8005bc <vprintfmt+0x1fb>
  800619:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80061c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80061f:	eb de                	jmp    8005ff <vprintfmt+0x23e>
  800621:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800624:	8b 7d 08             	mov    0x8(%ebp),%edi
  800627:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80062a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80062e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800635:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800637:	83 eb 01             	sub    $0x1,%ebx
  80063a:	85 db                	test   %ebx,%ebx
  80063c:	7f ec                	jg     80062a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800641:	e9 ac fd ff ff       	jmp    8003f2 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800646:	8d 45 14             	lea    0x14(%ebp),%eax
  800649:	e8 f4 fc ff ff       	call   800342 <getint>
  80064e:	89 c3                	mov    %eax,%ebx
  800650:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800652:	85 d2                	test   %edx,%edx
  800654:	78 0a                	js     800660 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800656:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80065b:	e9 87 00 00 00       	jmp    8006e7 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800660:	8b 45 0c             	mov    0xc(%ebp),%eax
  800663:	89 44 24 04          	mov    %eax,0x4(%esp)
  800667:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800671:	89 d8                	mov    %ebx,%eax
  800673:	89 f2                	mov    %esi,%edx
  800675:	f7 d8                	neg    %eax
  800677:	83 d2 00             	adc    $0x0,%edx
  80067a:	f7 da                	neg    %edx
			}
			base = 10;
  80067c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800681:	eb 64                	jmp    8006e7 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 7d fc ff ff       	call   800308 <getuint>
			base = 10;
  80068b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800690:	eb 55                	jmp    8006e7 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800692:	8d 45 14             	lea    0x14(%ebp),%eax
  800695:	e8 6e fc ff ff       	call   800308 <getuint>
      base = 8;
  80069a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80069f:	eb 46                	jmp    8006e7 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006a4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006af:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b9:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c0:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 50 04             	lea    0x4(%eax),%edx
  8006c9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cc:	8b 00                	mov    (%eax),%eax
  8006ce:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006d8:	eb 0d                	jmp    8006e7 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006da:	8d 45 14             	lea    0x14(%ebp),%eax
  8006dd:	e8 26 fc ff ff       	call   800308 <getuint>
			base = 16;
  8006e2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e7:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006eb:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8006ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006f2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006fa:	89 04 24             	mov    %eax,(%esp)
  8006fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800701:	8b 55 0c             	mov    0xc(%ebp),%edx
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	e8 14 fb ff ff       	call   800220 <printnum>
			break;
  80070c:	e9 e1 fc ff ff       	jmp    8003f2 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800711:	8b 45 0c             	mov    0xc(%ebp),%eax
  800714:	89 44 24 04          	mov    %eax,0x4(%esp)
  800718:	89 0c 24             	mov    %ecx,(%esp)
  80071b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80071e:	e9 cf fc ff ff       	jmp    8003f2 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800723:	8d 45 14             	lea    0x14(%ebp),%eax
  800726:	e8 17 fc ff ff       	call   800342 <getint>
			csa = num;
  80072b:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  800730:	e9 bd fc ff ff       	jmp    8003f2 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800735:	8b 55 0c             	mov    0xc(%ebp),%edx
  800738:	89 54 24 04          	mov    %edx,0x4(%esp)
  80073c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800743:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800746:	83 ef 01             	sub    $0x1,%edi
  800749:	eb 02                	jmp    80074d <vprintfmt+0x38c>
  80074b:	89 c7                	mov    %eax,%edi
  80074d:	8d 47 ff             	lea    -0x1(%edi),%eax
  800750:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800754:	75 f5                	jne    80074b <vprintfmt+0x38a>
  800756:	e9 97 fc ff ff       	jmp    8003f2 <vprintfmt+0x31>

0080075b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	83 ec 28             	sub    $0x28,%esp
  800761:	8b 45 08             	mov    0x8(%ebp),%eax
  800764:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800767:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800771:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800778:	85 c0                	test   %eax,%eax
  80077a:	74 30                	je     8007ac <vsnprintf+0x51>
  80077c:	85 d2                	test   %edx,%edx
  80077e:	7e 2c                	jle    8007ac <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800787:	8b 45 10             	mov    0x10(%ebp),%eax
  80078a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800791:	89 44 24 04          	mov    %eax,0x4(%esp)
  800795:	c7 04 24 7c 03 80 00 	movl   $0x80037c,(%esp)
  80079c:	e8 20 fc ff ff       	call   8003c1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007aa:	eb 05                	jmp    8007b1 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b1:	c9                   	leave  
  8007b2:	c3                   	ret    

008007b3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d1:	89 04 24             	mov    %eax,(%esp)
  8007d4:	e8 82 ff ff ff       	call   80075b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d9:	c9                   	leave  
  8007da:	c3                   	ret    
  8007db:	00 00                	add    %al,(%eax)
  8007dd:	00 00                	add    %al,(%eax)
	...

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ee:	74 09                	je     8007f9 <strlen+0x19>
		n++;
  8007f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f7:	75 f7                	jne    8007f0 <strlen+0x10>
		n++;
	return n;
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800801:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800804:	b8 00 00 00 00       	mov    $0x0,%eax
  800809:	85 d2                	test   %edx,%edx
  80080b:	74 12                	je     80081f <strnlen+0x24>
  80080d:	80 39 00             	cmpb   $0x0,(%ecx)
  800810:	74 0d                	je     80081f <strnlen+0x24>
		n++;
  800812:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800815:	39 d0                	cmp    %edx,%eax
  800817:	74 06                	je     80081f <strnlen+0x24>
  800819:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80081d:	75 f3                	jne    800812 <strnlen+0x17>
		n++;
	return n;
}
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	53                   	push   %ebx
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082b:	ba 00 00 00 00       	mov    $0x0,%edx
  800830:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800834:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800837:	83 c2 01             	add    $0x1,%edx
  80083a:	84 c9                	test   %cl,%cl
  80083c:	75 f2                	jne    800830 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80083e:	5b                   	pop    %ebx
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	53                   	push   %ebx
  800845:	83 ec 08             	sub    $0x8,%esp
  800848:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084b:	89 1c 24             	mov    %ebx,(%esp)
  80084e:	e8 8d ff ff ff       	call   8007e0 <strlen>
	strcpy(dst + len, src);
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
  800856:	89 54 24 04          	mov    %edx,0x4(%esp)
  80085a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80085d:	89 04 24             	mov    %eax,(%esp)
  800860:	e8 bc ff ff ff       	call   800821 <strcpy>
	return dst;
}
  800865:	89 d8                	mov    %ebx,%eax
  800867:	83 c4 08             	add    $0x8,%esp
  80086a:	5b                   	pop    %ebx
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	56                   	push   %esi
  800871:	53                   	push   %ebx
  800872:	8b 45 08             	mov    0x8(%ebp),%eax
  800875:	8b 55 0c             	mov    0xc(%ebp),%edx
  800878:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087b:	85 f6                	test   %esi,%esi
  80087d:	74 18                	je     800897 <strncpy+0x2a>
  80087f:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800884:	0f b6 1a             	movzbl (%edx),%ebx
  800887:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088a:	80 3a 01             	cmpb   $0x1,(%edx)
  80088d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800890:	83 c1 01             	add    $0x1,%ecx
  800893:	39 ce                	cmp    %ecx,%esi
  800895:	77 ed                	ja     800884 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a9:	89 f0                	mov    %esi,%eax
  8008ab:	85 c9                	test   %ecx,%ecx
  8008ad:	74 23                	je     8008d2 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  8008af:	83 e9 01             	sub    $0x1,%ecx
  8008b2:	74 1b                	je     8008cf <strlcpy+0x34>
  8008b4:	0f b6 1a             	movzbl (%edx),%ebx
  8008b7:	84 db                	test   %bl,%bl
  8008b9:	74 14                	je     8008cf <strlcpy+0x34>
			*dst++ = *src++;
  8008bb:	88 18                	mov    %bl,(%eax)
  8008bd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c0:	83 e9 01             	sub    $0x1,%ecx
  8008c3:	74 0a                	je     8008cf <strlcpy+0x34>
			*dst++ = *src++;
  8008c5:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c8:	0f b6 1a             	movzbl (%edx),%ebx
  8008cb:	84 db                	test   %bl,%bl
  8008cd:	75 ec                	jne    8008bb <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  8008cf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d2:	29 f0                	sub    %esi,%eax
}
  8008d4:	5b                   	pop    %ebx
  8008d5:	5e                   	pop    %esi
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e1:	0f b6 01             	movzbl (%ecx),%eax
  8008e4:	84 c0                	test   %al,%al
  8008e6:	74 15                	je     8008fd <strcmp+0x25>
  8008e8:	3a 02                	cmp    (%edx),%al
  8008ea:	75 11                	jne    8008fd <strcmp+0x25>
		p++, q++;
  8008ec:	83 c1 01             	add    $0x1,%ecx
  8008ef:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f2:	0f b6 01             	movzbl (%ecx),%eax
  8008f5:	84 c0                	test   %al,%al
  8008f7:	74 04                	je     8008fd <strcmp+0x25>
  8008f9:	3a 02                	cmp    (%edx),%al
  8008fb:	74 ef                	je     8008ec <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fd:	0f b6 c0             	movzbl %al,%eax
  800900:	0f b6 12             	movzbl (%edx),%edx
  800903:	29 d0                	sub    %edx,%eax
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	53                   	push   %ebx
  80090b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800911:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800919:	85 d2                	test   %edx,%edx
  80091b:	74 28                	je     800945 <strncmp+0x3e>
  80091d:	0f b6 01             	movzbl (%ecx),%eax
  800920:	84 c0                	test   %al,%al
  800922:	74 24                	je     800948 <strncmp+0x41>
  800924:	3a 03                	cmp    (%ebx),%al
  800926:	75 20                	jne    800948 <strncmp+0x41>
  800928:	83 ea 01             	sub    $0x1,%edx
  80092b:	74 13                	je     800940 <strncmp+0x39>
		n--, p++, q++;
  80092d:	83 c1 01             	add    $0x1,%ecx
  800930:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800933:	0f b6 01             	movzbl (%ecx),%eax
  800936:	84 c0                	test   %al,%al
  800938:	74 0e                	je     800948 <strncmp+0x41>
  80093a:	3a 03                	cmp    (%ebx),%al
  80093c:	74 ea                	je     800928 <strncmp+0x21>
  80093e:	eb 08                	jmp    800948 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800940:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800945:	5b                   	pop    %ebx
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800948:	0f b6 01             	movzbl (%ecx),%eax
  80094b:	0f b6 13             	movzbl (%ebx),%edx
  80094e:	29 d0                	sub    %edx,%eax
  800950:	eb f3                	jmp    800945 <strncmp+0x3e>

00800952 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095c:	0f b6 10             	movzbl (%eax),%edx
  80095f:	84 d2                	test   %dl,%dl
  800961:	74 20                	je     800983 <strchr+0x31>
		if (*s == c)
  800963:	38 ca                	cmp    %cl,%dl
  800965:	75 0b                	jne    800972 <strchr+0x20>
  800967:	eb 1f                	jmp    800988 <strchr+0x36>
  800969:	38 ca                	cmp    %cl,%dl
  80096b:	90                   	nop
  80096c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800970:	74 16                	je     800988 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800972:	83 c0 01             	add    $0x1,%eax
  800975:	0f b6 10             	movzbl (%eax),%edx
  800978:	84 d2                	test   %dl,%dl
  80097a:	75 ed                	jne    800969 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
  800981:	eb 05                	jmp    800988 <strchr+0x36>
  800983:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800994:	0f b6 10             	movzbl (%eax),%edx
  800997:	84 d2                	test   %dl,%dl
  800999:	74 14                	je     8009af <strfind+0x25>
		if (*s == c)
  80099b:	38 ca                	cmp    %cl,%dl
  80099d:	75 06                	jne    8009a5 <strfind+0x1b>
  80099f:	eb 0e                	jmp    8009af <strfind+0x25>
  8009a1:	38 ca                	cmp    %cl,%dl
  8009a3:	74 0a                	je     8009af <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009a5:	83 c0 01             	add    $0x1,%eax
  8009a8:	0f b6 10             	movzbl (%eax),%edx
  8009ab:	84 d2                	test   %dl,%dl
  8009ad:	75 f2                	jne    8009a1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	83 ec 0c             	sub    $0xc,%esp
  8009b7:	89 1c 24             	mov    %ebx,(%esp)
  8009ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009cb:	85 c9                	test   %ecx,%ecx
  8009cd:	74 30                	je     8009ff <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d5:	75 25                	jne    8009fc <memset+0x4b>
  8009d7:	f6 c1 03             	test   $0x3,%cl
  8009da:	75 20                	jne    8009fc <memset+0x4b>
		c &= 0xFF;
  8009dc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009df:	89 d3                	mov    %edx,%ebx
  8009e1:	c1 e3 08             	shl    $0x8,%ebx
  8009e4:	89 d6                	mov    %edx,%esi
  8009e6:	c1 e6 18             	shl    $0x18,%esi
  8009e9:	89 d0                	mov    %edx,%eax
  8009eb:	c1 e0 10             	shl    $0x10,%eax
  8009ee:	09 f0                	or     %esi,%eax
  8009f0:	09 d0                	or     %edx,%eax
  8009f2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009f4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009f7:	fc                   	cld    
  8009f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8009fa:	eb 03                	jmp    8009ff <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fc:	fc                   	cld    
  8009fd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ff:	89 f8                	mov    %edi,%eax
  800a01:	8b 1c 24             	mov    (%esp),%ebx
  800a04:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a08:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a0c:	89 ec                	mov    %ebp,%esp
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	89 34 24             	mov    %esi,(%esp)
  800a19:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a26:	39 c6                	cmp    %eax,%esi
  800a28:	73 36                	jae    800a60 <memmove+0x50>
  800a2a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a2d:	39 d0                	cmp    %edx,%eax
  800a2f:	73 2f                	jae    800a60 <memmove+0x50>
		s += n;
		d += n;
  800a31:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a34:	f6 c2 03             	test   $0x3,%dl
  800a37:	75 1b                	jne    800a54 <memmove+0x44>
  800a39:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3f:	75 13                	jne    800a54 <memmove+0x44>
  800a41:	f6 c1 03             	test   $0x3,%cl
  800a44:	75 0e                	jne    800a54 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a46:	83 ef 04             	sub    $0x4,%edi
  800a49:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a4c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a4f:	fd                   	std    
  800a50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a52:	eb 09                	jmp    800a5d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a54:	83 ef 01             	sub    $0x1,%edi
  800a57:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a5a:	fd                   	std    
  800a5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a5d:	fc                   	cld    
  800a5e:	eb 20                	jmp    800a80 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a60:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a66:	75 13                	jne    800a7b <memmove+0x6b>
  800a68:	a8 03                	test   $0x3,%al
  800a6a:	75 0f                	jne    800a7b <memmove+0x6b>
  800a6c:	f6 c1 03             	test   $0x3,%cl
  800a6f:	75 0a                	jne    800a7b <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a71:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a74:	89 c7                	mov    %eax,%edi
  800a76:	fc                   	cld    
  800a77:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a79:	eb 05                	jmp    800a80 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a7b:	89 c7                	mov    %eax,%edi
  800a7d:	fc                   	cld    
  800a7e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a80:	8b 34 24             	mov    (%esp),%esi
  800a83:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a87:	89 ec                	mov    %ebp,%esp
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a91:	8b 45 10             	mov    0x10(%ebp),%eax
  800a94:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	89 04 24             	mov    %eax,(%esp)
  800aa5:	e8 66 ff ff ff       	call   800a10 <memmove>
}
  800aaa:	c9                   	leave  
  800aab:	c3                   	ret    

00800aac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ab5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab8:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac0:	85 ff                	test   %edi,%edi
  800ac2:	74 38                	je     800afc <memcmp+0x50>
		if (*s1 != *s2)
  800ac4:	0f b6 03             	movzbl (%ebx),%eax
  800ac7:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aca:	83 ef 01             	sub    $0x1,%edi
  800acd:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800ad2:	38 c8                	cmp    %cl,%al
  800ad4:	74 1d                	je     800af3 <memcmp+0x47>
  800ad6:	eb 11                	jmp    800ae9 <memcmp+0x3d>
  800ad8:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800add:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800ae2:	83 c2 01             	add    $0x1,%edx
  800ae5:	38 c8                	cmp    %cl,%al
  800ae7:	74 0a                	je     800af3 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800ae9:	0f b6 c0             	movzbl %al,%eax
  800aec:	0f b6 c9             	movzbl %cl,%ecx
  800aef:	29 c8                	sub    %ecx,%eax
  800af1:	eb 09                	jmp    800afc <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af3:	39 fa                	cmp    %edi,%edx
  800af5:	75 e1                	jne    800ad8 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800af7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b07:	89 c2                	mov    %eax,%edx
  800b09:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b0c:	39 d0                	cmp    %edx,%eax
  800b0e:	73 15                	jae    800b25 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b14:	38 08                	cmp    %cl,(%eax)
  800b16:	75 06                	jne    800b1e <memfind+0x1d>
  800b18:	eb 0b                	jmp    800b25 <memfind+0x24>
  800b1a:	38 08                	cmp    %cl,(%eax)
  800b1c:	74 07                	je     800b25 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b1e:	83 c0 01             	add    $0x1,%eax
  800b21:	39 c2                	cmp    %eax,%edx
  800b23:	77 f5                	ja     800b1a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b33:	0f b6 02             	movzbl (%edx),%eax
  800b36:	3c 20                	cmp    $0x20,%al
  800b38:	74 04                	je     800b3e <strtol+0x17>
  800b3a:	3c 09                	cmp    $0x9,%al
  800b3c:	75 0e                	jne    800b4c <strtol+0x25>
		s++;
  800b3e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b41:	0f b6 02             	movzbl (%edx),%eax
  800b44:	3c 20                	cmp    $0x20,%al
  800b46:	74 f6                	je     800b3e <strtol+0x17>
  800b48:	3c 09                	cmp    $0x9,%al
  800b4a:	74 f2                	je     800b3e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b4c:	3c 2b                	cmp    $0x2b,%al
  800b4e:	75 0a                	jne    800b5a <strtol+0x33>
		s++;
  800b50:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b53:	bf 00 00 00 00       	mov    $0x0,%edi
  800b58:	eb 10                	jmp    800b6a <strtol+0x43>
  800b5a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b5f:	3c 2d                	cmp    $0x2d,%al
  800b61:	75 07                	jne    800b6a <strtol+0x43>
		s++, neg = 1;
  800b63:	83 c2 01             	add    $0x1,%edx
  800b66:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6a:	85 db                	test   %ebx,%ebx
  800b6c:	0f 94 c0             	sete   %al
  800b6f:	74 05                	je     800b76 <strtol+0x4f>
  800b71:	83 fb 10             	cmp    $0x10,%ebx
  800b74:	75 15                	jne    800b8b <strtol+0x64>
  800b76:	80 3a 30             	cmpb   $0x30,(%edx)
  800b79:	75 10                	jne    800b8b <strtol+0x64>
  800b7b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b7f:	75 0a                	jne    800b8b <strtol+0x64>
		s += 2, base = 16;
  800b81:	83 c2 02             	add    $0x2,%edx
  800b84:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b89:	eb 13                	jmp    800b9e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800b8b:	84 c0                	test   %al,%al
  800b8d:	74 0f                	je     800b9e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b8f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b94:	80 3a 30             	cmpb   $0x30,(%edx)
  800b97:	75 05                	jne    800b9e <strtol+0x77>
		s++, base = 8;
  800b99:	83 c2 01             	add    $0x1,%edx
  800b9c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba3:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ba5:	0f b6 0a             	movzbl (%edx),%ecx
  800ba8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bab:	80 fb 09             	cmp    $0x9,%bl
  800bae:	77 08                	ja     800bb8 <strtol+0x91>
			dig = *s - '0';
  800bb0:	0f be c9             	movsbl %cl,%ecx
  800bb3:	83 e9 30             	sub    $0x30,%ecx
  800bb6:	eb 1e                	jmp    800bd6 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800bb8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bbb:	80 fb 19             	cmp    $0x19,%bl
  800bbe:	77 08                	ja     800bc8 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800bc0:	0f be c9             	movsbl %cl,%ecx
  800bc3:	83 e9 57             	sub    $0x57,%ecx
  800bc6:	eb 0e                	jmp    800bd6 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800bc8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bcb:	80 fb 19             	cmp    $0x19,%bl
  800bce:	77 15                	ja     800be5 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800bd0:	0f be c9             	movsbl %cl,%ecx
  800bd3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bd6:	39 f1                	cmp    %esi,%ecx
  800bd8:	7d 0f                	jge    800be9 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800bda:	83 c2 01             	add    $0x1,%edx
  800bdd:	0f af c6             	imul   %esi,%eax
  800be0:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800be3:	eb c0                	jmp    800ba5 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800be5:	89 c1                	mov    %eax,%ecx
  800be7:	eb 02                	jmp    800beb <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800be9:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800beb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bef:	74 05                	je     800bf6 <strtol+0xcf>
		*endptr = (char *) s;
  800bf1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf4:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bf6:	89 ca                	mov    %ecx,%edx
  800bf8:	f7 da                	neg    %edx
  800bfa:	85 ff                	test   %edi,%edi
  800bfc:	0f 45 c2             	cmovne %edx,%eax
}
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	89 1c 24             	mov    %ebx,(%esp)
  800c0d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c11:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c15:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	89 c3                	mov    %eax,%ebx
  800c22:	89 c7                	mov    %eax,%edi
  800c24:	89 c6                	mov    %eax,%esi
  800c26:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c28:	8b 1c 24             	mov    (%esp),%ebx
  800c2b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c2f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c33:	89 ec                	mov    %ebp,%esp
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	83 ec 0c             	sub    $0xc,%esp
  800c3d:	89 1c 24             	mov    %ebx,(%esp)
  800c40:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c44:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c52:	89 d1                	mov    %edx,%ecx
  800c54:	89 d3                	mov    %edx,%ebx
  800c56:	89 d7                	mov    %edx,%edi
  800c58:	89 d6                	mov    %edx,%esi
  800c5a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c5c:	8b 1c 24             	mov    (%esp),%ebx
  800c5f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c63:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c67:	89 ec                	mov    %ebp,%esp
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 38             	sub    $0x38,%esp
  800c71:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c74:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c77:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	89 cb                	mov    %ecx,%ebx
  800c89:	89 cf                	mov    %ecx,%edi
  800c8b:	89 ce                	mov    %ecx,%esi
  800c8d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7e 28                	jle    800cbb <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c97:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c9e:	00 
  800c9f:	c7 44 24 08 04 15 80 	movl   $0x801504,0x8(%esp)
  800ca6:	00 
  800ca7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cae:	00 
  800caf:	c7 04 24 21 15 80 00 	movl   $0x801521,(%esp)
  800cb6:	e8 25 03 00 00       	call   800fe0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cbb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cbe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cc4:	89 ec                	mov    %ebp,%esp
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	83 ec 0c             	sub    $0xc,%esp
  800cce:	89 1c 24             	mov    %ebx,(%esp)
  800cd1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cde:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce3:	89 d1                	mov    %edx,%ecx
  800ce5:	89 d3                	mov    %edx,%ebx
  800ce7:	89 d7                	mov    %edx,%edi
  800ce9:	89 d6                	mov    %edx,%esi
  800ceb:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800ced:	8b 1c 24             	mov    (%esp),%ebx
  800cf0:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cf4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cf8:	89 ec                	mov    %ebp,%esp
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_yield>:

void
sys_yield(void)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 0c             	sub    $0xc,%esp
  800d02:	89 1c 24             	mov    %ebx,(%esp)
  800d05:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d09:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d12:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d17:	89 d1                	mov    %edx,%ecx
  800d19:	89 d3                	mov    %edx,%ebx
  800d1b:	89 d7                	mov    %edx,%edi
  800d1d:	89 d6                	mov    %edx,%esi
  800d1f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d21:	8b 1c 24             	mov    (%esp),%ebx
  800d24:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d28:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d2c:	89 ec                	mov    %ebp,%esp
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 38             	sub    $0x38,%esp
  800d36:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	be 00 00 00 00       	mov    $0x0,%esi
  800d44:	b8 04 00 00 00       	mov    $0x4,%eax
  800d49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	89 f7                	mov    %esi,%edi
  800d54:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d56:	85 c0                	test   %eax,%eax
  800d58:	7e 28                	jle    800d82 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d65:	00 
  800d66:	c7 44 24 08 04 15 80 	movl   $0x801504,0x8(%esp)
  800d6d:	00 
  800d6e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d75:	00 
  800d76:	c7 04 24 21 15 80 00 	movl   $0x801521,(%esp)
  800d7d:	e8 5e 02 00 00       	call   800fe0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d82:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d85:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d88:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d8b:	89 ec                	mov    %ebp,%esp
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	83 ec 38             	sub    $0x38,%esp
  800d95:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d98:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d9b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	b8 05 00 00 00       	mov    $0x5,%eax
  800da3:	8b 75 18             	mov    0x18(%ebp),%esi
  800da6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daf:	8b 55 08             	mov    0x8(%ebp),%edx
  800db2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db4:	85 c0                	test   %eax,%eax
  800db6:	7e 28                	jle    800de0 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 08 04 15 80 	movl   $0x801504,0x8(%esp)
  800dcb:	00 
  800dcc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd3:	00 
  800dd4:	c7 04 24 21 15 80 00 	movl   $0x801521,(%esp)
  800ddb:	e8 00 02 00 00       	call   800fe0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800de0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de9:	89 ec                	mov    %ebp,%esp
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	83 ec 38             	sub    $0x38,%esp
  800df3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800df9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e01:	b8 06 00 00 00       	mov    $0x6,%eax
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	89 df                	mov    %ebx,%edi
  800e0e:	89 de                	mov    %ebx,%esi
  800e10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e12:	85 c0                	test   %eax,%eax
  800e14:	7e 28                	jle    800e3e <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e21:	00 
  800e22:	c7 44 24 08 04 15 80 	movl   $0x801504,0x8(%esp)
  800e29:	00 
  800e2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e31:	00 
  800e32:	c7 04 24 21 15 80 00 	movl   $0x801521,(%esp)
  800e39:	e8 a2 01 00 00       	call   800fe0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e3e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e41:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e44:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e47:	89 ec                	mov    %ebp,%esp
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	83 ec 38             	sub    $0x38,%esp
  800e51:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e54:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e57:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5f:	b8 08 00 00 00       	mov    $0x8,%eax
  800e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e67:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6a:	89 df                	mov    %ebx,%edi
  800e6c:	89 de                	mov    %ebx,%esi
  800e6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e70:	85 c0                	test   %eax,%eax
  800e72:	7e 28                	jle    800e9c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e74:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e78:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e7f:	00 
  800e80:	c7 44 24 08 04 15 80 	movl   $0x801504,0x8(%esp)
  800e87:	00 
  800e88:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8f:	00 
  800e90:	c7 04 24 21 15 80 00 	movl   $0x801521,(%esp)
  800e97:	e8 44 01 00 00       	call   800fe0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e9c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e9f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea5:	89 ec                	mov    %ebp,%esp
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	83 ec 38             	sub    $0x38,%esp
  800eaf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebd:	b8 09 00 00 00       	mov    $0x9,%eax
  800ec2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec8:	89 df                	mov    %ebx,%edi
  800eca:	89 de                	mov    %ebx,%esi
  800ecc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	7e 28                	jle    800efa <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed6:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800edd:	00 
  800ede:	c7 44 24 08 04 15 80 	movl   $0x801504,0x8(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eed:	00 
  800eee:	c7 04 24 21 15 80 00 	movl   $0x801521,(%esp)
  800ef5:	e8 e6 00 00 00       	call   800fe0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800efa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800efd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f00:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f03:	89 ec                	mov    %ebp,%esp
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	89 1c 24             	mov    %ebx,(%esp)
  800f10:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f14:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f18:	be 00 00 00 00       	mov    $0x0,%esi
  800f1d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f22:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f30:	8b 1c 24             	mov    (%esp),%ebx
  800f33:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f37:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f3b:	89 ec                	mov    %ebp,%esp
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	83 ec 38             	sub    $0x38,%esp
  800f45:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f48:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f4b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f58:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5b:	89 cb                	mov    %ecx,%ebx
  800f5d:	89 cf                	mov    %ecx,%edi
  800f5f:	89 ce                	mov    %ecx,%esi
  800f61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f63:	85 c0                	test   %eax,%eax
  800f65:	7e 28                	jle    800f8f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f72:	00 
  800f73:	c7 44 24 08 04 15 80 	movl   $0x801504,0x8(%esp)
  800f7a:	00 
  800f7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f82:	00 
  800f83:	c7 04 24 21 15 80 00 	movl   $0x801521,(%esp)
  800f8a:	e8 51 00 00 00       	call   800fe0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f98:	89 ec                	mov    %ebp,%esp
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800fa2:	c7 44 24 08 3b 15 80 	movl   $0x80153b,0x8(%esp)
  800fa9:	00 
  800faa:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  800fb1:	00 
  800fb2:	c7 04 24 2f 15 80 00 	movl   $0x80152f,(%esp)
  800fb9:	e8 22 00 00 00       	call   800fe0 <_panic>

00800fbe <sfork>:
}

// Challenge!
int
sfork(void)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800fc4:	c7 44 24 08 3a 15 80 	movl   $0x80153a,0x8(%esp)
  800fcb:	00 
  800fcc:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  800fd3:	00 
  800fd4:	c7 04 24 2f 15 80 00 	movl   $0x80152f,(%esp)
  800fdb:	e8 00 00 00 00       	call   800fe0 <_panic>

00800fe0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	56                   	push   %esi
  800fe4:	53                   	push   %ebx
  800fe5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800fe8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800feb:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800ff1:	e8 d2 fc ff ff       	call   800cc8 <sys_getenvid>
  800ff6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff9:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ffd:	8b 55 08             	mov    0x8(%ebp),%edx
  801000:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801004:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801008:	89 44 24 04          	mov    %eax,0x4(%esp)
  80100c:	c7 04 24 50 15 80 00 	movl   $0x801550,(%esp)
  801013:	e8 eb f1 ff ff       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801018:	89 74 24 04          	mov    %esi,0x4(%esp)
  80101c:	8b 45 10             	mov    0x10(%ebp),%eax
  80101f:	89 04 24             	mov    %eax,(%esp)
  801022:	e8 7b f1 ff ff       	call   8001a2 <vcprintf>
	cprintf("\n");
  801027:	c7 04 24 af 12 80 00 	movl   $0x8012af,(%esp)
  80102e:	e8 d0 f1 ff ff       	call   800203 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801033:	cc                   	int3   
  801034:	eb fd                	jmp    801033 <_panic+0x53>
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
