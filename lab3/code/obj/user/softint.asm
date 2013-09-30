
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	83 ec 18             	sub    $0x18,%esp
  800042:	8b 45 08             	mov    0x8(%ebp),%eax
  800045:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800048:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004f:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800052:	85 c0                	test   %eax,%eax
  800054:	7e 08                	jle    80005e <libmain+0x22>
		binaryname = argv[0];
  800056:	8b 0a                	mov    (%edx),%ecx
  800058:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80005e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800062:	89 04 24             	mov    %eax,(%esp)
  800065:	e8 ca ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80006a:	e8 05 00 00 00       	call   800074 <exit>
}
  80006f:	c9                   	leave  
  800070:	c3                   	ret    
  800071:	00 00                	add    %al,(%eax)
	...

00800074 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80007a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800081:	e8 69 00 00 00       	call   8000ef <sys_env_destroy>
}
  800086:	c9                   	leave  
  800087:	c3                   	ret    

00800088 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 1c 24             	mov    %ebx,(%esp)
  800091:	89 74 24 04          	mov    %esi,0x4(%esp)
  800095:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800099:	b8 00 00 00 00       	mov    $0x0,%eax
  80009e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a4:	89 c3                	mov    %eax,%ebx
  8000a6:	89 c7                	mov    %eax,%edi
  8000a8:	89 c6                	mov    %eax,%esi
  8000aa:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ac:	8b 1c 24             	mov    (%esp),%ebx
  8000af:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000b3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000b7:	89 ec                	mov    %ebp,%esp
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    

008000bb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	83 ec 0c             	sub    $0xc,%esp
  8000c1:	89 1c 24             	mov    %ebx,(%esp)
  8000c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c8:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d6:	89 d1                	mov    %edx,%ecx
  8000d8:	89 d3                	mov    %edx,%ebx
  8000da:	89 d7                	mov    %edx,%edi
  8000dc:	89 d6                	mov    %edx,%esi
  8000de:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e0:	8b 1c 24             	mov    (%esp),%ebx
  8000e3:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000e7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    

008000ef <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	83 ec 38             	sub    $0x38,%esp
  8000f5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000fb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800103:	b8 03 00 00 00       	mov    $0x3,%eax
  800108:	8b 55 08             	mov    0x8(%ebp),%edx
  80010b:	89 cb                	mov    %ecx,%ebx
  80010d:	89 cf                	mov    %ecx,%edi
  80010f:	89 ce                	mov    %ecx,%esi
  800111:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800113:	85 c0                	test   %eax,%eax
  800115:	7e 28                	jle    80013f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800117:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800122:	00 
  800123:	c7 44 24 08 f2 0e 80 	movl   $0x800ef2,0x8(%esp)
  80012a:	00 
  80012b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800132:	00 
  800133:	c7 04 24 0f 0f 80 00 	movl   $0x800f0f,(%esp)
  80013a:	e8 41 00 00 00       	call   800180 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800142:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800145:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800148:	89 ec                	mov    %ebp,%esp
  80014a:	5d                   	pop    %ebp
  80014b:	c3                   	ret    

0080014c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	89 1c 24             	mov    %ebx,(%esp)
  800155:	89 74 24 04          	mov    %esi,0x4(%esp)
  800159:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015d:	ba 00 00 00 00       	mov    $0x0,%edx
  800162:	b8 02 00 00 00       	mov    $0x2,%eax
  800167:	89 d1                	mov    %edx,%ecx
  800169:	89 d3                	mov    %edx,%ebx
  80016b:	89 d7                	mov    %edx,%edi
  80016d:	89 d6                	mov    %edx,%esi
  80016f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800171:	8b 1c 24             	mov    (%esp),%ebx
  800174:	8b 74 24 04          	mov    0x4(%esp),%esi
  800178:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80017c:	89 ec                	mov    %ebp,%esp
  80017e:	5d                   	pop    %ebp
  80017f:	c3                   	ret    

00800180 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800188:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800191:	e8 b6 ff ff ff       	call   80014c <sys_getenvid>
  800196:	8b 55 0c             	mov    0xc(%ebp),%edx
  800199:	89 54 24 10          	mov    %edx,0x10(%esp)
  80019d:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ac:	c7 04 24 20 0f 80 00 	movl   $0x800f20,(%esp)
  8001b3:	e8 c3 00 00 00       	call   80027b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 53 00 00 00       	call   80021a <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 44 0f 80 00 	movl   $0x800f44,(%esp)
  8001ce:	e8 a8 00 00 00       	call   80027b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d3:	cc                   	int3   
  8001d4:	eb fd                	jmp    8001d3 <_panic+0x53>
	...

008001d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	53                   	push   %ebx
  8001dc:	83 ec 14             	sub    $0x14,%esp
  8001df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e2:	8b 03                	mov    (%ebx),%eax
  8001e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001eb:	83 c0 01             	add    $0x1,%eax
  8001ee:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f5:	75 19                	jne    800210 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001f7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001fe:	00 
  8001ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800202:	89 04 24             	mov    %eax,(%esp)
  800205:	e8 7e fe ff ff       	call   800088 <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800210:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800214:	83 c4 14             	add    $0x14,%esp
  800217:	5b                   	pop    %ebx
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    

0080021a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800223:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022a:	00 00 00 
	b.cnt = 0;
  80022d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800234:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800237:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	89 44 24 08          	mov    %eax,0x8(%esp)
  800245:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	c7 04 24 d8 01 80 00 	movl   $0x8001d8,(%esp)
  800256:	e8 e6 01 00 00       	call   800441 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800261:	89 44 24 04          	mov    %eax,0x4(%esp)
  800265:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	e8 15 fe ff ff       	call   800088 <sys_cputs>

	return b.cnt;
}
  800273:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800281:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800284:	89 44 24 04          	mov    %eax,0x4(%esp)
  800288:	8b 45 08             	mov    0x8(%ebp),%eax
  80028b:	89 04 24             	mov    %eax,(%esp)
  80028e:	e8 87 ff ff ff       	call   80021a <vcprintf>
	va_end(ap);

	return cnt;
}
  800293:	c9                   	leave  
  800294:	c3                   	ret    
	...

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 4c             	sub    $0x4c,%esp
  8002a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ac:	89 d6                	mov    %edx,%esi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002bd:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c5:	39 d0                	cmp    %edx,%eax
  8002c7:	72 11                	jb     8002da <printnum+0x3a>
  8002c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002cc:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8002cf:	76 09                	jbe    8002da <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d1:	83 eb 01             	sub    $0x1,%ebx
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7f 5d                	jg     800335 <printnum+0x95>
  8002d8:	eb 6c                	jmp    800346 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002da:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002de:	83 eb 01             	sub    $0x1,%ebx
  8002e1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ec:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002f0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002f7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8002fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800301:	00 
  800302:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800305:	89 14 24             	mov    %edx,(%esp)
  800308:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80030b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80030f:	e8 7c 09 00 00       	call   800c90 <__udivdi3>
  800314:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800317:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80031a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80031e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	89 54 24 04          	mov    %edx,0x4(%esp)
  800329:	89 f2                	mov    %esi,%edx
  80032b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80032e:	e8 6d ff ff ff       	call   8002a0 <printnum>
  800333:	eb 11                	jmp    800346 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800335:	89 74 24 04          	mov    %esi,0x4(%esp)
  800339:	89 3c 24             	mov    %edi,(%esp)
  80033c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033f:	83 eb 01             	sub    $0x1,%ebx
  800342:	85 db                	test   %ebx,%ebx
  800344:	7f ef                	jg     800335 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800346:	89 74 24 04          	mov    %esi,0x4(%esp)
  80034a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80034e:	8b 45 10             	mov    0x10(%ebp),%eax
  800351:	89 44 24 08          	mov    %eax,0x8(%esp)
  800355:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035c:	00 
  80035d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800360:	89 14 24             	mov    %edx,(%esp)
  800363:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800366:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80036a:	e8 31 0a 00 00       	call   800da0 <__umoddi3>
  80036f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800373:	0f be 80 46 0f 80 00 	movsbl 0x800f46(%eax),%eax
  80037a:	89 04 24             	mov    %eax,(%esp)
  80037d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800380:	83 c4 4c             	add    $0x4c,%esp
  800383:	5b                   	pop    %ebx
  800384:	5e                   	pop    %esi
  800385:	5f                   	pop    %edi
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038b:	83 fa 01             	cmp    $0x1,%edx
  80038e:	7e 0e                	jle    80039e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800390:	8b 10                	mov    (%eax),%edx
  800392:	8d 4a 08             	lea    0x8(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 02                	mov    (%edx),%eax
  800399:	8b 52 04             	mov    0x4(%edx),%edx
  80039c:	eb 22                	jmp    8003c0 <getuint+0x38>
	else if (lflag)
  80039e:	85 d2                	test   %edx,%edx
  8003a0:	74 10                	je     8003b2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a2:	8b 10                	mov    (%eax),%edx
  8003a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a7:	89 08                	mov    %ecx,(%eax)
  8003a9:	8b 02                	mov    (%edx),%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	eb 0e                	jmp    8003c0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b2:	8b 10                	mov    (%eax),%edx
  8003b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b7:	89 08                	mov    %ecx,(%eax)
  8003b9:	8b 02                	mov    (%edx),%eax
  8003bb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c0:	5d                   	pop    %ebp
  8003c1:	c3                   	ret    

008003c2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c5:	83 fa 01             	cmp    $0x1,%edx
  8003c8:	7e 0e                	jle    8003d8 <getint+0x16>
		return va_arg(*ap, long long);
  8003ca:	8b 10                	mov    (%eax),%edx
  8003cc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003cf:	89 08                	mov    %ecx,(%eax)
  8003d1:	8b 02                	mov    (%edx),%eax
  8003d3:	8b 52 04             	mov    0x4(%edx),%edx
  8003d6:	eb 22                	jmp    8003fa <getint+0x38>
	else if (lflag)
  8003d8:	85 d2                	test   %edx,%edx
  8003da:	74 10                	je     8003ec <getint+0x2a>
		return va_arg(*ap, long);
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e1:	89 08                	mov    %ecx,(%eax)
  8003e3:	8b 02                	mov    (%edx),%eax
  8003e5:	89 c2                	mov    %eax,%edx
  8003e7:	c1 fa 1f             	sar    $0x1f,%edx
  8003ea:	eb 0e                	jmp    8003fa <getint+0x38>
	else
		return va_arg(*ap, int);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800402:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800406:	8b 10                	mov    (%eax),%edx
  800408:	3b 50 04             	cmp    0x4(%eax),%edx
  80040b:	73 0a                	jae    800417 <sprintputch+0x1b>
		*b->buf++ = ch;
  80040d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800410:	88 0a                	mov    %cl,(%edx)
  800412:	83 c2 01             	add    $0x1,%edx
  800415:	89 10                	mov    %edx,(%eax)
}
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    

00800419 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80041f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800422:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800426:	8b 45 10             	mov    0x10(%ebp),%eax
  800429:	89 44 24 08          	mov    %eax,0x8(%esp)
  80042d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800430:	89 44 24 04          	mov    %eax,0x4(%esp)
  800434:	8b 45 08             	mov    0x8(%ebp),%eax
  800437:	89 04 24             	mov    %eax,(%esp)
  80043a:	e8 02 00 00 00       	call   800441 <vprintfmt>
	va_end(ap);
}
  80043f:	c9                   	leave  
  800440:	c3                   	ret    

00800441 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
  800444:	57                   	push   %edi
  800445:	56                   	push   %esi
  800446:	53                   	push   %ebx
  800447:	83 ec 4c             	sub    $0x4c,%esp
  80044a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80044d:	eb 23                	jmp    800472 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80044f:	85 c0                	test   %eax,%eax
  800451:	75 12                	jne    800465 <vprintfmt+0x24>
				csa = 0x0700;
  800453:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80045a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80045d:	83 c4 4c             	add    $0x4c,%esp
  800460:	5b                   	pop    %ebx
  800461:	5e                   	pop    %esi
  800462:	5f                   	pop    %edi
  800463:	5d                   	pop    %ebp
  800464:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800465:	8b 55 0c             	mov    0xc(%ebp),%edx
  800468:	89 54 24 04          	mov    %edx,0x4(%esp)
  80046c:	89 04 24             	mov    %eax,(%esp)
  80046f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800472:	0f b6 07             	movzbl (%edi),%eax
  800475:	83 c7 01             	add    $0x1,%edi
  800478:	83 f8 25             	cmp    $0x25,%eax
  80047b:	75 d2                	jne    80044f <vprintfmt+0xe>
  80047d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800481:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800488:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80048d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800494:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800499:	be 00 00 00 00       	mov    $0x0,%esi
  80049e:	eb 14                	jmp    8004b4 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8004a4:	eb 0e                	jmp    8004b4 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a6:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8004aa:	eb 08                	jmp    8004b4 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004ac:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004af:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	0f b6 07             	movzbl (%edi),%eax
  8004b7:	0f b6 c8             	movzbl %al,%ecx
  8004ba:	83 c7 01             	add    $0x1,%edi
  8004bd:	83 e8 23             	sub    $0x23,%eax
  8004c0:	3c 55                	cmp    $0x55,%al
  8004c2:	0f 87 ed 02 00 00    	ja     8007b5 <vprintfmt+0x374>
  8004c8:	0f b6 c0             	movzbl %al,%eax
  8004cb:	ff 24 85 d4 0f 80 00 	jmp    *0x800fd4(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  8004d5:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004d8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004db:	83 f9 09             	cmp    $0x9,%ecx
  8004de:	77 3c                	ja     80051c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004e3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8004e6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8004ea:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004ed:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004f0:	83 f9 09             	cmp    $0x9,%ecx
  8004f3:	76 eb                	jbe    8004e0 <vprintfmt+0x9f>
  8004f5:	eb 25                	jmp    80051c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 48 04             	lea    0x4(%eax),%ecx
  8004fd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800500:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  800502:	eb 18                	jmp    80051c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  800504:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800508:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050b:	0f 48 c6             	cmovs  %esi,%eax
  80050e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800511:	eb a1                	jmp    8004b4 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  800513:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80051a:	eb 98                	jmp    8004b4 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  80051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800520:	79 92                	jns    8004b4 <vprintfmt+0x73>
  800522:	eb 88                	jmp    8004ac <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800524:	83 c2 01             	add    $0x1,%edx
  800527:	eb 8b                	jmp    8004b4 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8d 50 04             	lea    0x4(%eax),%edx
  80052f:	89 55 14             	mov    %edx,0x14(%ebp)
  800532:	8b 55 0c             	mov    0xc(%ebp),%edx
  800535:	89 54 24 04          	mov    %edx,0x4(%esp)
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	89 04 24             	mov    %eax,(%esp)
  80053e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800541:	e9 2c ff ff ff       	jmp    800472 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8d 50 04             	lea    0x4(%eax),%edx
  80054c:	89 55 14             	mov    %edx,0x14(%ebp)
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 c2                	mov    %eax,%edx
  800553:	c1 fa 1f             	sar    $0x1f,%edx
  800556:	31 d0                	xor    %edx,%eax
  800558:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055a:	83 f8 06             	cmp    $0x6,%eax
  80055d:	7f 0b                	jg     80056a <vprintfmt+0x129>
  80055f:	8b 14 85 2c 11 80 00 	mov    0x80112c(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 23                	jne    80058d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80056a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056e:	c7 44 24 08 5e 0f 80 	movl   $0x800f5e,0x8(%esp)
  800575:	00 
  800576:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800579:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057d:	8b 45 08             	mov    0x8(%ebp),%eax
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	e8 91 fe ff ff       	call   800419 <printfmt>
  800588:	e9 e5 fe ff ff       	jmp    800472 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80058d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800591:	c7 44 24 08 67 0f 80 	movl   $0x800f67,0x8(%esp)
  800598:	00 
  800599:	8b 55 0c             	mov    0xc(%ebp),%edx
  80059c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005a3:	89 1c 24             	mov    %ebx,(%esp)
  8005a6:	e8 6e fe ff ff       	call   800419 <printfmt>
  8005ab:	e9 c2 fe ff ff       	jmp    800472 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 50 04             	lea    0x4(%eax),%edx
  8005bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c2:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005c4:	85 f6                	test   %esi,%esi
  8005c6:	ba 57 0f 80 00       	mov    $0x800f57,%edx
  8005cb:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005d2:	7e 06                	jle    8005da <vprintfmt+0x199>
  8005d4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005d8:	75 13                	jne    8005ed <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005da:	0f be 06             	movsbl (%esi),%eax
  8005dd:	83 c6 01             	add    $0x1,%esi
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	0f 85 a2 00 00 00    	jne    80068a <vprintfmt+0x249>
  8005e8:	e9 92 00 00 00       	jmp    80067f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f1:	89 34 24             	mov    %esi,(%esp)
  8005f4:	e8 82 02 00 00       	call   80087b <strnlen>
  8005f9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fc:	29 c2                	sub    %eax,%edx
  8005fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800601:	85 d2                	test   %edx,%edx
  800603:	7e d5                	jle    8005da <vprintfmt+0x199>
					putch(padc, putdat);
  800605:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800609:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80060c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80060f:	89 d3                	mov    %edx,%ebx
  800611:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800614:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800617:	89 c6                	mov    %eax,%esi
  800619:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061d:	89 34 24             	mov    %esi,(%esp)
  800620:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800623:	83 eb 01             	sub    $0x1,%ebx
  800626:	85 db                	test   %ebx,%ebx
  800628:	7f ef                	jg     800619 <vprintfmt+0x1d8>
  80062a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80062d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800630:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800633:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80063a:	eb 9e                	jmp    8005da <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800640:	74 1b                	je     80065d <vprintfmt+0x21c>
  800642:	8d 50 e0             	lea    -0x20(%eax),%edx
  800645:	83 fa 5e             	cmp    $0x5e,%edx
  800648:	76 13                	jbe    80065d <vprintfmt+0x21c>
					putch('?', putdat);
  80064a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80064d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800651:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800658:	ff 55 08             	call   *0x8(%ebp)
  80065b:	eb 0d                	jmp    80066a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80065d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800660:	89 54 24 04          	mov    %edx,0x4(%esp)
  800664:	89 04 24             	mov    %eax,(%esp)
  800667:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066a:	83 ef 01             	sub    $0x1,%edi
  80066d:	0f be 06             	movsbl (%esi),%eax
  800670:	85 c0                	test   %eax,%eax
  800672:	74 05                	je     800679 <vprintfmt+0x238>
  800674:	83 c6 01             	add    $0x1,%esi
  800677:	eb 17                	jmp    800690 <vprintfmt+0x24f>
  800679:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80067c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800683:	7f 1c                	jg     8006a1 <vprintfmt+0x260>
  800685:	e9 e8 fd ff ff       	jmp    800472 <vprintfmt+0x31>
  80068a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80068d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800690:	85 db                	test   %ebx,%ebx
  800692:	78 a8                	js     80063c <vprintfmt+0x1fb>
  800694:	83 eb 01             	sub    $0x1,%ebx
  800697:	79 a3                	jns    80063c <vprintfmt+0x1fb>
  800699:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80069c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80069f:	eb de                	jmp    80067f <vprintfmt+0x23e>
  8006a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a7:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006b5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b7:	83 eb 01             	sub    $0x1,%ebx
  8006ba:	85 db                	test   %ebx,%ebx
  8006bc:	7f ec                	jg     8006aa <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006c1:	e9 ac fd ff ff       	jmp    800472 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c9:	e8 f4 fc ff ff       	call   8003c2 <getint>
  8006ce:	89 c3                	mov    %eax,%ebx
  8006d0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8006d2:	85 d2                	test   %edx,%edx
  8006d4:	78 0a                	js     8006e0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006db:	e9 87 00 00 00       	jmp    800767 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ee:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f1:	89 d8                	mov    %ebx,%eax
  8006f3:	89 f2                	mov    %esi,%edx
  8006f5:	f7 d8                	neg    %eax
  8006f7:	83 d2 00             	adc    $0x0,%edx
  8006fa:	f7 da                	neg    %edx
			}
			base = 10;
  8006fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800701:	eb 64                	jmp    800767 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 7d fc ff ff       	call   800388 <getuint>
			base = 10;
  80070b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800710:	eb 55                	jmp    800767 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800712:	8d 45 14             	lea    0x14(%ebp),%eax
  800715:	e8 6e fc ff ff       	call   800388 <getuint>
      base = 8;
  80071a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80071f:	eb 46                	jmp    800767 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800721:	8b 55 0c             	mov    0xc(%ebp),%edx
  800724:	89 54 24 04          	mov    %edx,0x4(%esp)
  800728:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800732:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800735:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800739:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800740:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8d 50 04             	lea    0x4(%eax),%edx
  800749:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80074c:	8b 00                	mov    (%eax),%eax
  80074e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800753:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800758:	eb 0d                	jmp    800767 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
  80075d:	e8 26 fc ff ff       	call   800388 <getuint>
			base = 16;
  800762:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800767:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80076b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80076f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800772:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800776:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80077a:	89 04 24             	mov    %eax,(%esp)
  80077d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800781:	8b 55 0c             	mov    0xc(%ebp),%edx
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	e8 14 fb ff ff       	call   8002a0 <printnum>
			break;
  80078c:	e9 e1 fc ff ff       	jmp    800472 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800791:	8b 45 0c             	mov    0xc(%ebp),%eax
  800794:	89 44 24 04          	mov    %eax,0x4(%esp)
  800798:	89 0c 24             	mov    %ecx,(%esp)
  80079b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80079e:	e9 cf fc ff ff       	jmp    800472 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a6:	e8 17 fc ff ff       	call   8003c2 <getint>
			csa = num;
  8007ab:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  8007b0:	e9 bd fc ff ff       	jmp    800472 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007bc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c6:	83 ef 01             	sub    $0x1,%edi
  8007c9:	eb 02                	jmp    8007cd <vprintfmt+0x38c>
  8007cb:	89 c7                	mov    %eax,%edi
  8007cd:	8d 47 ff             	lea    -0x1(%edi),%eax
  8007d0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007d4:	75 f5                	jne    8007cb <vprintfmt+0x38a>
  8007d6:	e9 97 fc ff ff       	jmp    800472 <vprintfmt+0x31>

008007db <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	83 ec 28             	sub    $0x28,%esp
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ea:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ee:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f8:	85 c0                	test   %eax,%eax
  8007fa:	74 30                	je     80082c <vsnprintf+0x51>
  8007fc:	85 d2                	test   %edx,%edx
  8007fe:	7e 2c                	jle    80082c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800807:	8b 45 10             	mov    0x10(%ebp),%eax
  80080a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800811:	89 44 24 04          	mov    %eax,0x4(%esp)
  800815:	c7 04 24 fc 03 80 00 	movl   $0x8003fc,(%esp)
  80081c:	e8 20 fc ff ff       	call   800441 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800821:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800824:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800827:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082a:	eb 05                	jmp    800831 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80082c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800839:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800840:	8b 45 10             	mov    0x10(%ebp),%eax
  800843:	89 44 24 08          	mov    %eax,0x8(%esp)
  800847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	89 04 24             	mov    %eax,(%esp)
  800854:	e8 82 ff ff ff       	call   8007db <vsnprintf>
	va_end(ap);

	return rc;
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    
  80085b:	00 00                	add    %al,(%eax)
  80085d:	00 00                	add    %al,(%eax)
	...

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	80 3a 00             	cmpb   $0x0,(%edx)
  80086e:	74 09                	je     800879 <strlen+0x19>
		n++;
  800870:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800873:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800877:	75 f7                	jne    800870 <strlen+0x10>
		n++;
	return n;
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
  800889:	85 d2                	test   %edx,%edx
  80088b:	74 12                	je     80089f <strnlen+0x24>
  80088d:	80 39 00             	cmpb   $0x0,(%ecx)
  800890:	74 0d                	je     80089f <strnlen+0x24>
		n++;
  800892:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800895:	39 d0                	cmp    %edx,%eax
  800897:	74 06                	je     80089f <strnlen+0x24>
  800899:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80089d:	75 f3                	jne    800892 <strnlen+0x17>
		n++;
	return n;
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	53                   	push   %ebx
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008b4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008b7:	83 c2 01             	add    $0x1,%edx
  8008ba:	84 c9                	test   %cl,%cl
  8008bc:	75 f2                	jne    8008b0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	53                   	push   %ebx
  8008c5:	83 ec 08             	sub    $0x8,%esp
  8008c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008cb:	89 1c 24             	mov    %ebx,(%esp)
  8008ce:	e8 8d ff ff ff       	call   800860 <strlen>
	strcpy(dst + len, src);
  8008d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008da:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008dd:	89 04 24             	mov    %eax,(%esp)
  8008e0:	e8 bc ff ff ff       	call   8008a1 <strcpy>
	return dst;
}
  8008e5:	89 d8                	mov    %ebx,%eax
  8008e7:	83 c4 08             	add    $0x8,%esp
  8008ea:	5b                   	pop    %ebx
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	56                   	push   %esi
  8008f1:	53                   	push   %ebx
  8008f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fb:	85 f6                	test   %esi,%esi
  8008fd:	74 18                	je     800917 <strncpy+0x2a>
  8008ff:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800904:	0f b6 1a             	movzbl (%edx),%ebx
  800907:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090a:	80 3a 01             	cmpb   $0x1,(%edx)
  80090d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800910:	83 c1 01             	add    $0x1,%ecx
  800913:	39 ce                	cmp    %ecx,%esi
  800915:	77 ed                	ja     800904 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 75 08             	mov    0x8(%ebp),%esi
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
  800926:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800929:	89 f0                	mov    %esi,%eax
  80092b:	85 c9                	test   %ecx,%ecx
  80092d:	74 23                	je     800952 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  80092f:	83 e9 01             	sub    $0x1,%ecx
  800932:	74 1b                	je     80094f <strlcpy+0x34>
  800934:	0f b6 1a             	movzbl (%edx),%ebx
  800937:	84 db                	test   %bl,%bl
  800939:	74 14                	je     80094f <strlcpy+0x34>
			*dst++ = *src++;
  80093b:	88 18                	mov    %bl,(%eax)
  80093d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800940:	83 e9 01             	sub    $0x1,%ecx
  800943:	74 0a                	je     80094f <strlcpy+0x34>
			*dst++ = *src++;
  800945:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800948:	0f b6 1a             	movzbl (%edx),%ebx
  80094b:	84 db                	test   %bl,%bl
  80094d:	75 ec                	jne    80093b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  80094f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800952:	29 f0                	sub    %esi,%eax
}
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800961:	0f b6 01             	movzbl (%ecx),%eax
  800964:	84 c0                	test   %al,%al
  800966:	74 15                	je     80097d <strcmp+0x25>
  800968:	3a 02                	cmp    (%edx),%al
  80096a:	75 11                	jne    80097d <strcmp+0x25>
		p++, q++;
  80096c:	83 c1 01             	add    $0x1,%ecx
  80096f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800972:	0f b6 01             	movzbl (%ecx),%eax
  800975:	84 c0                	test   %al,%al
  800977:	74 04                	je     80097d <strcmp+0x25>
  800979:	3a 02                	cmp    (%edx),%al
  80097b:	74 ef                	je     80096c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097d:	0f b6 c0             	movzbl %al,%eax
  800980:	0f b6 12             	movzbl (%edx),%edx
  800983:	29 d0                	sub    %edx,%eax
}
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800991:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800999:	85 d2                	test   %edx,%edx
  80099b:	74 28                	je     8009c5 <strncmp+0x3e>
  80099d:	0f b6 01             	movzbl (%ecx),%eax
  8009a0:	84 c0                	test   %al,%al
  8009a2:	74 24                	je     8009c8 <strncmp+0x41>
  8009a4:	3a 03                	cmp    (%ebx),%al
  8009a6:	75 20                	jne    8009c8 <strncmp+0x41>
  8009a8:	83 ea 01             	sub    $0x1,%edx
  8009ab:	74 13                	je     8009c0 <strncmp+0x39>
		n--, p++, q++;
  8009ad:	83 c1 01             	add    $0x1,%ecx
  8009b0:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009b3:	0f b6 01             	movzbl (%ecx),%eax
  8009b6:	84 c0                	test   %al,%al
  8009b8:	74 0e                	je     8009c8 <strncmp+0x41>
  8009ba:	3a 03                	cmp    (%ebx),%al
  8009bc:	74 ea                	je     8009a8 <strncmp+0x21>
  8009be:	eb 08                	jmp    8009c8 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c8:	0f b6 01             	movzbl (%ecx),%eax
  8009cb:	0f b6 13             	movzbl (%ebx),%edx
  8009ce:	29 d0                	sub    %edx,%eax
  8009d0:	eb f3                	jmp    8009c5 <strncmp+0x3e>

008009d2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009dc:	0f b6 10             	movzbl (%eax),%edx
  8009df:	84 d2                	test   %dl,%dl
  8009e1:	74 20                	je     800a03 <strchr+0x31>
		if (*s == c)
  8009e3:	38 ca                	cmp    %cl,%dl
  8009e5:	75 0b                	jne    8009f2 <strchr+0x20>
  8009e7:	eb 1f                	jmp    800a08 <strchr+0x36>
  8009e9:	38 ca                	cmp    %cl,%dl
  8009eb:	90                   	nop
  8009ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009f0:	74 16                	je     800a08 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f2:	83 c0 01             	add    $0x1,%eax
  8009f5:	0f b6 10             	movzbl (%eax),%edx
  8009f8:	84 d2                	test   %dl,%dl
  8009fa:	75 ed                	jne    8009e9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800a01:	eb 05                	jmp    800a08 <strchr+0x36>
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a14:	0f b6 10             	movzbl (%eax),%edx
  800a17:	84 d2                	test   %dl,%dl
  800a19:	74 14                	je     800a2f <strfind+0x25>
		if (*s == c)
  800a1b:	38 ca                	cmp    %cl,%dl
  800a1d:	75 06                	jne    800a25 <strfind+0x1b>
  800a1f:	eb 0e                	jmp    800a2f <strfind+0x25>
  800a21:	38 ca                	cmp    %cl,%dl
  800a23:	74 0a                	je     800a2f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	0f b6 10             	movzbl (%eax),%edx
  800a2b:	84 d2                	test   %dl,%dl
  800a2d:	75 f2                	jne    800a21 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	83 ec 0c             	sub    $0xc,%esp
  800a37:	89 1c 24             	mov    %ebx,(%esp)
  800a3a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a42:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a48:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a4b:	85 c9                	test   %ecx,%ecx
  800a4d:	74 30                	je     800a7f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a55:	75 25                	jne    800a7c <memset+0x4b>
  800a57:	f6 c1 03             	test   $0x3,%cl
  800a5a:	75 20                	jne    800a7c <memset+0x4b>
		c &= 0xFF;
  800a5c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5f:	89 d3                	mov    %edx,%ebx
  800a61:	c1 e3 08             	shl    $0x8,%ebx
  800a64:	89 d6                	mov    %edx,%esi
  800a66:	c1 e6 18             	shl    $0x18,%esi
  800a69:	89 d0                	mov    %edx,%eax
  800a6b:	c1 e0 10             	shl    $0x10,%eax
  800a6e:	09 f0                	or     %esi,%eax
  800a70:	09 d0                	or     %edx,%eax
  800a72:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a74:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a77:	fc                   	cld    
  800a78:	f3 ab                	rep stos %eax,%es:(%edi)
  800a7a:	eb 03                	jmp    800a7f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7c:	fc                   	cld    
  800a7d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a7f:	89 f8                	mov    %edi,%eax
  800a81:	8b 1c 24             	mov    (%esp),%ebx
  800a84:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a88:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a8c:	89 ec                	mov    %ebp,%esp
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	83 ec 08             	sub    $0x8,%esp
  800a96:	89 34 24             	mov    %esi,(%esp)
  800a99:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa6:	39 c6                	cmp    %eax,%esi
  800aa8:	73 36                	jae    800ae0 <memmove+0x50>
  800aaa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aad:	39 d0                	cmp    %edx,%eax
  800aaf:	73 2f                	jae    800ae0 <memmove+0x50>
		s += n;
		d += n;
  800ab1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab4:	f6 c2 03             	test   $0x3,%dl
  800ab7:	75 1b                	jne    800ad4 <memmove+0x44>
  800ab9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800abf:	75 13                	jne    800ad4 <memmove+0x44>
  800ac1:	f6 c1 03             	test   $0x3,%cl
  800ac4:	75 0e                	jne    800ad4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac6:	83 ef 04             	sub    $0x4,%edi
  800ac9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800acc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800acf:	fd                   	std    
  800ad0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad2:	eb 09                	jmp    800add <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ad4:	83 ef 01             	sub    $0x1,%edi
  800ad7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ada:	fd                   	std    
  800adb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800add:	fc                   	cld    
  800ade:	eb 20                	jmp    800b00 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae6:	75 13                	jne    800afb <memmove+0x6b>
  800ae8:	a8 03                	test   $0x3,%al
  800aea:	75 0f                	jne    800afb <memmove+0x6b>
  800aec:	f6 c1 03             	test   $0x3,%cl
  800aef:	75 0a                	jne    800afb <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800af1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800af4:	89 c7                	mov    %eax,%edi
  800af6:	fc                   	cld    
  800af7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af9:	eb 05                	jmp    800b00 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800afb:	89 c7                	mov    %eax,%edi
  800afd:	fc                   	cld    
  800afe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b00:	8b 34 24             	mov    (%esp),%esi
  800b03:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b07:	89 ec                	mov    %ebp,%esp
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b11:	8b 45 10             	mov    0x10(%ebp),%eax
  800b14:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	89 04 24             	mov    %eax,(%esp)
  800b25:	e8 66 ff ff ff       	call   800a90 <memmove>
}
  800b2a:	c9                   	leave  
  800b2b:	c3                   	ret    

00800b2c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b38:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b40:	85 ff                	test   %edi,%edi
  800b42:	74 38                	je     800b7c <memcmp+0x50>
		if (*s1 != *s2)
  800b44:	0f b6 03             	movzbl (%ebx),%eax
  800b47:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4a:	83 ef 01             	sub    $0x1,%edi
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b52:	38 c8                	cmp    %cl,%al
  800b54:	74 1d                	je     800b73 <memcmp+0x47>
  800b56:	eb 11                	jmp    800b69 <memcmp+0x3d>
  800b58:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b5d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800b62:	83 c2 01             	add    $0x1,%edx
  800b65:	38 c8                	cmp    %cl,%al
  800b67:	74 0a                	je     800b73 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800b69:	0f b6 c0             	movzbl %al,%eax
  800b6c:	0f b6 c9             	movzbl %cl,%ecx
  800b6f:	29 c8                	sub    %ecx,%eax
  800b71:	eb 09                	jmp    800b7c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b73:	39 fa                	cmp    %edi,%edx
  800b75:	75 e1                	jne    800b58 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b87:	89 c2                	mov    %eax,%edx
  800b89:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b8c:	39 d0                	cmp    %edx,%eax
  800b8e:	73 15                	jae    800ba5 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b94:	38 08                	cmp    %cl,(%eax)
  800b96:	75 06                	jne    800b9e <memfind+0x1d>
  800b98:	eb 0b                	jmp    800ba5 <memfind+0x24>
  800b9a:	38 08                	cmp    %cl,(%eax)
  800b9c:	74 07                	je     800ba5 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9e:	83 c0 01             	add    $0x1,%eax
  800ba1:	39 c2                	cmp    %eax,%edx
  800ba3:	77 f5                	ja     800b9a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb3:	0f b6 02             	movzbl (%edx),%eax
  800bb6:	3c 20                	cmp    $0x20,%al
  800bb8:	74 04                	je     800bbe <strtol+0x17>
  800bba:	3c 09                	cmp    $0x9,%al
  800bbc:	75 0e                	jne    800bcc <strtol+0x25>
		s++;
  800bbe:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc1:	0f b6 02             	movzbl (%edx),%eax
  800bc4:	3c 20                	cmp    $0x20,%al
  800bc6:	74 f6                	je     800bbe <strtol+0x17>
  800bc8:	3c 09                	cmp    $0x9,%al
  800bca:	74 f2                	je     800bbe <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bcc:	3c 2b                	cmp    $0x2b,%al
  800bce:	75 0a                	jne    800bda <strtol+0x33>
		s++;
  800bd0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bd3:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd8:	eb 10                	jmp    800bea <strtol+0x43>
  800bda:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bdf:	3c 2d                	cmp    $0x2d,%al
  800be1:	75 07                	jne    800bea <strtol+0x43>
		s++, neg = 1;
  800be3:	83 c2 01             	add    $0x1,%edx
  800be6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bea:	85 db                	test   %ebx,%ebx
  800bec:	0f 94 c0             	sete   %al
  800bef:	74 05                	je     800bf6 <strtol+0x4f>
  800bf1:	83 fb 10             	cmp    $0x10,%ebx
  800bf4:	75 15                	jne    800c0b <strtol+0x64>
  800bf6:	80 3a 30             	cmpb   $0x30,(%edx)
  800bf9:	75 10                	jne    800c0b <strtol+0x64>
  800bfb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bff:	75 0a                	jne    800c0b <strtol+0x64>
		s += 2, base = 16;
  800c01:	83 c2 02             	add    $0x2,%edx
  800c04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c09:	eb 13                	jmp    800c1e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c0b:	84 c0                	test   %al,%al
  800c0d:	74 0f                	je     800c1e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c0f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c14:	80 3a 30             	cmpb   $0x30,(%edx)
  800c17:	75 05                	jne    800c1e <strtol+0x77>
		s++, base = 8;
  800c19:	83 c2 01             	add    $0x1,%edx
  800c1c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c23:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c25:	0f b6 0a             	movzbl (%edx),%ecx
  800c28:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c2b:	80 fb 09             	cmp    $0x9,%bl
  800c2e:	77 08                	ja     800c38 <strtol+0x91>
			dig = *s - '0';
  800c30:	0f be c9             	movsbl %cl,%ecx
  800c33:	83 e9 30             	sub    $0x30,%ecx
  800c36:	eb 1e                	jmp    800c56 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800c38:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c3b:	80 fb 19             	cmp    $0x19,%bl
  800c3e:	77 08                	ja     800c48 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c40:	0f be c9             	movsbl %cl,%ecx
  800c43:	83 e9 57             	sub    $0x57,%ecx
  800c46:	eb 0e                	jmp    800c56 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c48:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c4b:	80 fb 19             	cmp    $0x19,%bl
  800c4e:	77 15                	ja     800c65 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800c50:	0f be c9             	movsbl %cl,%ecx
  800c53:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c56:	39 f1                	cmp    %esi,%ecx
  800c58:	7d 0f                	jge    800c69 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800c5a:	83 c2 01             	add    $0x1,%edx
  800c5d:	0f af c6             	imul   %esi,%eax
  800c60:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c63:	eb c0                	jmp    800c25 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c65:	89 c1                	mov    %eax,%ecx
  800c67:	eb 02                	jmp    800c6b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c69:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6f:	74 05                	je     800c76 <strtol+0xcf>
		*endptr = (char *) s;
  800c71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c74:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c76:	89 ca                	mov    %ecx,%edx
  800c78:	f7 da                	neg    %edx
  800c7a:	85 ff                	test   %edi,%edi
  800c7c:	0f 45 c2             	cmovne %edx,%eax
}
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    
	...

00800c90 <__udivdi3>:
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	83 ec 10             	sub    $0x10,%esp
  800c98:	8b 75 14             	mov    0x14(%ebp),%esi
  800c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ca1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ca4:	85 f6                	test   %esi,%esi
  800ca6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ca9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800caf:	75 2f                	jne    800ce0 <__udivdi3+0x50>
  800cb1:	39 f9                	cmp    %edi,%ecx
  800cb3:	77 5b                	ja     800d10 <__udivdi3+0x80>
  800cb5:	85 c9                	test   %ecx,%ecx
  800cb7:	75 0b                	jne    800cc4 <__udivdi3+0x34>
  800cb9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cbe:	31 d2                	xor    %edx,%edx
  800cc0:	f7 f1                	div    %ecx
  800cc2:	89 c1                	mov    %eax,%ecx
  800cc4:	89 f8                	mov    %edi,%eax
  800cc6:	31 d2                	xor    %edx,%edx
  800cc8:	f7 f1                	div    %ecx
  800cca:	89 c7                	mov    %eax,%edi
  800ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ccf:	f7 f1                	div    %ecx
  800cd1:	89 fa                	mov    %edi,%edx
  800cd3:	83 c4 10             	add    $0x10,%esp
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    
  800cda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ce0:	31 d2                	xor    %edx,%edx
  800ce2:	31 c0                	xor    %eax,%eax
  800ce4:	39 fe                	cmp    %edi,%esi
  800ce6:	77 eb                	ja     800cd3 <__udivdi3+0x43>
  800ce8:	0f bd d6             	bsr    %esi,%edx
  800ceb:	83 f2 1f             	xor    $0x1f,%edx
  800cee:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800cf1:	75 2d                	jne    800d20 <__udivdi3+0x90>
  800cf3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800cf6:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  800cf9:	76 06                	jbe    800d01 <__udivdi3+0x71>
  800cfb:	39 fe                	cmp    %edi,%esi
  800cfd:	89 c2                	mov    %eax,%edx
  800cff:	73 d2                	jae    800cd3 <__udivdi3+0x43>
  800d01:	31 d2                	xor    %edx,%edx
  800d03:	b8 01 00 00 00       	mov    $0x1,%eax
  800d08:	eb c9                	jmp    800cd3 <__udivdi3+0x43>
  800d0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d10:	89 fa                	mov    %edi,%edx
  800d12:	f7 f1                	div    %ecx
  800d14:	31 d2                	xor    %edx,%edx
  800d16:	83 c4 10             	add    $0x10,%esp
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    
  800d1d:	8d 76 00             	lea    0x0(%esi),%esi
  800d20:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d24:	b8 20 00 00 00       	mov    $0x20,%eax
  800d29:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d2c:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800d2f:	d3 e6                	shl    %cl,%esi
  800d31:	89 c1                	mov    %eax,%ecx
  800d33:	d3 ea                	shr    %cl,%edx
  800d35:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d39:	09 f2                	or     %esi,%edx
  800d3b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  800d3e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d41:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d44:	d3 e2                	shl    %cl,%edx
  800d46:	89 c1                	mov    %eax,%ecx
  800d48:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800d4b:	89 fa                	mov    %edi,%edx
  800d4d:	d3 ea                	shr    %cl,%edx
  800d4f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d53:	d3 e7                	shl    %cl,%edi
  800d55:	89 c1                	mov    %eax,%ecx
  800d57:	d3 ee                	shr    %cl,%esi
  800d59:	09 fe                	or     %edi,%esi
  800d5b:	89 f0                	mov    %esi,%eax
  800d5d:	f7 75 e8             	divl   -0x18(%ebp)
  800d60:	89 d7                	mov    %edx,%edi
  800d62:	89 c6                	mov    %eax,%esi
  800d64:	f7 65 f0             	mull   -0x10(%ebp)
  800d67:	39 d7                	cmp    %edx,%edi
  800d69:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800d6c:	72 22                	jb     800d90 <__udivdi3+0x100>
  800d6e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d71:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800d75:	d3 e2                	shl    %cl,%edx
  800d77:	39 c2                	cmp    %eax,%edx
  800d79:	73 05                	jae    800d80 <__udivdi3+0xf0>
  800d7b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  800d7e:	74 10                	je     800d90 <__udivdi3+0x100>
  800d80:	89 f0                	mov    %esi,%eax
  800d82:	31 d2                	xor    %edx,%edx
  800d84:	e9 4a ff ff ff       	jmp    800cd3 <__udivdi3+0x43>
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	8d 46 ff             	lea    -0x1(%esi),%eax
  800d93:	31 d2                	xor    %edx,%edx
  800d95:	83 c4 10             	add    $0x10,%esp
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    
  800d9c:	00 00                	add    %al,(%eax)
	...

00800da0 <__umoddi3>:
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	83 ec 20             	sub    $0x20,%esp
  800da8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
  800dae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800db1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800db4:	85 ff                	test   %edi,%edi
  800db6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800db9:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800dbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800dbf:	89 f2                	mov    %esi,%edx
  800dc1:	75 15                	jne    800dd8 <__umoddi3+0x38>
  800dc3:	39 f1                	cmp    %esi,%ecx
  800dc5:	76 41                	jbe    800e08 <__umoddi3+0x68>
  800dc7:	f7 f1                	div    %ecx
  800dc9:	89 d0                	mov    %edx,%eax
  800dcb:	31 d2                	xor    %edx,%edx
  800dcd:	83 c4 20             	add    $0x20,%esp
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
  800dd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dd8:	39 f7                	cmp    %esi,%edi
  800dda:	77 4c                	ja     800e28 <__umoddi3+0x88>
  800ddc:	0f bd c7             	bsr    %edi,%eax
  800ddf:	83 f0 1f             	xor    $0x1f,%eax
  800de2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800de5:	75 51                	jne    800e38 <__umoddi3+0x98>
  800de7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800dea:	0f 87 e8 00 00 00    	ja     800ed8 <__umoddi3+0x138>
  800df0:	89 f2                	mov    %esi,%edx
  800df2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800df5:	29 ce                	sub    %ecx,%esi
  800df7:	19 fa                	sbb    %edi,%edx
  800df9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  800dfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dff:	83 c4 20             	add    $0x20,%esp
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    
  800e06:	66 90                	xchg   %ax,%ax
  800e08:	85 c9                	test   %ecx,%ecx
  800e0a:	75 0b                	jne    800e17 <__umoddi3+0x77>
  800e0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e11:	31 d2                	xor    %edx,%edx
  800e13:	f7 f1                	div    %ecx
  800e15:	89 c1                	mov    %eax,%ecx
  800e17:	89 f0                	mov    %esi,%eax
  800e19:	31 d2                	xor    %edx,%edx
  800e1b:	f7 f1                	div    %ecx
  800e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e20:	eb a5                	jmp    800dc7 <__umoddi3+0x27>
  800e22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e28:	89 f2                	mov    %esi,%edx
  800e2a:	83 c4 20             	add    $0x20,%esp
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    
  800e31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e38:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e3c:	89 f2                	mov    %esi,%edx
  800e3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e41:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  800e48:	29 45 f0             	sub    %eax,-0x10(%ebp)
  800e4b:	d3 e7                	shl    %cl,%edi
  800e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e50:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e54:	d3 e8                	shr    %cl,%eax
  800e56:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e5a:	09 f8                	or     %edi,%eax
  800e5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e62:	d3 e0                	shl    %cl,%eax
  800e64:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e6e:	d3 ea                	shr    %cl,%edx
  800e70:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e74:	d3 e6                	shl    %cl,%esi
  800e76:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800e7a:	d3 e8                	shr    %cl,%eax
  800e7c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800e80:	09 f0                	or     %esi,%eax
  800e82:	8b 75 e8             	mov    -0x18(%ebp),%esi
  800e85:	f7 75 e4             	divl   -0x1c(%ebp)
  800e88:	d3 e6                	shl    %cl,%esi
  800e8a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800e8d:	89 d6                	mov    %edx,%esi
  800e8f:	f7 65 f4             	mull   -0xc(%ebp)
  800e92:	89 d7                	mov    %edx,%edi
  800e94:	89 c2                	mov    %eax,%edx
  800e96:	39 fe                	cmp    %edi,%esi
  800e98:	89 f9                	mov    %edi,%ecx
  800e9a:	72 30                	jb     800ecc <__umoddi3+0x12c>
  800e9c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800e9f:	72 27                	jb     800ec8 <__umoddi3+0x128>
  800ea1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ea4:	29 d0                	sub    %edx,%eax
  800ea6:	19 ce                	sbb    %ecx,%esi
  800ea8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800eac:	89 f2                	mov    %esi,%edx
  800eae:	d3 e8                	shr    %cl,%eax
  800eb0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800eb4:	d3 e2                	shl    %cl,%edx
  800eb6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800eba:	09 d0                	or     %edx,%eax
  800ebc:	89 f2                	mov    %esi,%edx
  800ebe:	d3 ea                	shr    %cl,%edx
  800ec0:	83 c4 20             	add    $0x20,%esp
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    
  800ec7:	90                   	nop
  800ec8:	39 fe                	cmp    %edi,%esi
  800eca:	75 d5                	jne    800ea1 <__umoddi3+0x101>
  800ecc:	89 f9                	mov    %edi,%ecx
  800ece:	89 c2                	mov    %eax,%edx
  800ed0:	2b 55 f4             	sub    -0xc(%ebp),%edx
  800ed3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800ed6:	eb c9                	jmp    800ea1 <__umoddi3+0x101>
  800ed8:	39 f7                	cmp    %esi,%edi
  800eda:	0f 82 10 ff ff ff    	jb     800df0 <__umoddi3+0x50>
  800ee0:	e9 17 ff ff ff       	jmp    800dfc <__umoddi3+0x5c>
