
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 4f 02 00 00       	call   800280 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	// sys_page_alloc(envid_t envid, void *va, int perm)
	// sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
	// sys_page_unmap(envid_t envid, void *va)
	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 ba 0e 00 00       	call   800f10 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 e0 13 80 	movl   $0x8013e0,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 f3 13 80 00 	movl   $0x8013f3,(%esp)
  800075:	e8 6a 02 00 00       	call   8002e4 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 d1 0e 00 00       	call   800f6f <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 03 14 80 	movl   $0x801403,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 f3 13 80 00 	movl   $0x8013f3,(%esp)
  8000bd:	e8 22 02 00 00       	call   8002e4 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 16 0b 00 00       	call   800bf0 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 df 0e 00 00       	call   800fcd <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 14 14 80 	movl   $0x801414,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 f3 13 80 00 	movl   $0x8013f3,(%esp)
  80010d:	e8 d2 01 00 00       	call   8002e4 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800121:	be 07 00 00 00       	mov    $0x7,%esi
  800126:	89 f0                	mov    %esi,%eax
  800128:	cd 30                	int    $0x30
  80012a:	89 c6                	mov    %eax,%esi
  80012c:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	cprintf("envid: %x\n", envid);
  80012e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800132:	c7 04 24 27 14 80 00 	movl   $0x801427,(%esp)
  800139:	e8 a1 02 00 00       	call   8003df <cprintf>
	if (envid < 0)
  80013e:	85 f6                	test   %esi,%esi
  800140:	79 20                	jns    800162 <dumbfork+0x49>
		panic("sys_exofork: %e", envid);
  800142:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800146:	c7 44 24 08 32 14 80 	movl   $0x801432,0x8(%esp)
  80014d:	00 
  80014e:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  800155:	00 
  800156:	c7 04 24 f3 13 80 00 	movl   $0x8013f3,(%esp)
  80015d:	e8 82 01 00 00       	call   8002e4 <_panic>
	if (envid == 0) {
  800162:	85 f6                	test   %esi,%esi
  800164:	75 1c                	jne    800182 <dumbfork+0x69>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800166:	e8 3d 0d 00 00       	call   800ea8 <sys_getenvid>
  80016b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800170:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800173:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800178:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80017d:	e9 8a 00 00 00       	jmp    80020c <dumbfork+0xf3>
	}

	cprintf("parent\n");
  800182:	c7 04 24 42 14 80 00 	movl   $0x801442,(%esp)
  800189:	e8 51 02 00 00       	call   8003df <cprintf>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80018e:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800195:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  80019a:	3d 00 00 80 00       	cmp    $0x800000,%eax
  80019f:	76 23                	jbe    8001c4 <dumbfork+0xab>
  8001a1:	b8 00 00 80 00       	mov    $0x800000,%eax
		duppage(envid, addr);
  8001a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001aa:	89 1c 24             	mov    %ebx,(%esp)
  8001ad:	e8 82 fe ff ff       	call   800034 <duppage>

	cprintf("parent\n");
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8001b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001b5:	05 00 10 00 00       	add    $0x1000,%eax
  8001ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8001bd:	3d 0c 20 80 00       	cmp    $0x80200c,%eax
  8001c2:	72 e2                	jb     8001a6 <dumbfork+0x8d>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	89 34 24             	mov    %esi,(%esp)
  8001d3:	e8 5c fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001d8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001df:	00 
  8001e0:	89 34 24             	mov    %esi,(%esp)
  8001e3:	e8 43 0e 00 00       	call   80102b <sys_env_set_status>
  8001e8:	85 c0                	test   %eax,%eax
  8001ea:	79 20                	jns    80020c <dumbfork+0xf3>
		panic("sys_env_set_status: %e", r);
  8001ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f0:	c7 44 24 08 4a 14 80 	movl   $0x80144a,0x8(%esp)
  8001f7:	00 
  8001f8:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8001ff:	00 
  800200:	c7 04 24 f3 13 80 00 	movl   $0x8013f3,(%esp)
  800207:	e8 d8 00 00 00       	call   8002e4 <_panic>

	return envid;
}
  80020c:	89 f0                	mov    %esi,%eax
  80020e:	83 c4 20             	add    $0x20,%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    

00800215 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	57                   	push   %edi
  800219:	56                   	push   %esi
  80021a:	53                   	push   %ebx
  80021b:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80021e:	e8 f6 fe ff ff       	call   800119 <dumbfork>
  800223:	89 c3                	mov    %eax,%ebx
	cprintf("who am i: %x\n", who);
  800225:	89 44 24 04          	mov    %eax,0x4(%esp)
  800229:	c7 04 24 6e 14 80 00 	movl   $0x80146e,(%esp)
  800230:	e8 aa 01 00 00       	call   8003df <cprintf>
	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800235:	be 00 00 00 00       	mov    $0x0,%esi
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80023a:	bf 68 14 80 00       	mov    $0x801468,%edi

	// fork a child process
	who = dumbfork();
	cprintf("who am i: %x\n", who);
	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  80023f:	eb 26                	jmp    800267 <umain+0x52>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800241:	85 db                	test   %ebx,%ebx
  800243:	b8 61 14 80 00       	mov    $0x801461,%eax
  800248:	0f 44 c7             	cmove  %edi,%eax
  80024b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800253:	c7 04 24 7c 14 80 00 	movl   $0x80147c,(%esp)
  80025a:	e8 80 01 00 00       	call   8003df <cprintf>
		sys_yield();
  80025f:	e8 78 0c 00 00       	call   800edc <sys_yield>

	// fork a child process
	who = dumbfork();
	cprintf("who am i: %x\n", who);
	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800264:	83 c6 01             	add    $0x1,%esi
  800267:	83 fb 01             	cmp    $0x1,%ebx
  80026a:	19 c0                	sbb    %eax,%eax
  80026c:	83 e0 0a             	and    $0xa,%eax
  80026f:	83 c0 0a             	add    $0xa,%eax
  800272:	39 c6                	cmp    %eax,%esi
  800274:	7c cb                	jl     800241 <umain+0x2c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800276:	83 c4 1c             	add    $0x1c,%esp
  800279:	5b                   	pop    %ebx
  80027a:	5e                   	pop    %esi
  80027b:	5f                   	pop    %edi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    
	...

00800280 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 18             	sub    $0x18,%esp
  800286:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800289:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80028c:	8b 75 08             	mov    0x8(%ebp),%esi
  80028f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800292:	e8 11 0c 00 00       	call   800ea8 <sys_getenvid>
  800297:	25 ff 03 00 00       	and    $0x3ff,%eax
  80029c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80029f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002a4:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002a9:	85 f6                	test   %esi,%esi
  8002ab:	7e 07                	jle    8002b4 <libmain+0x34>
		binaryname = argv[0];
  8002ad:	8b 03                	mov    (%ebx),%eax
  8002af:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8002b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002b8:	89 34 24             	mov    %esi,(%esp)
  8002bb:	e8 55 ff ff ff       	call   800215 <umain>

	// exit gracefully
	exit();
  8002c0:	e8 0b 00 00 00       	call   8002d0 <exit>
}
  8002c5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002c8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8002cb:	89 ec                	mov    %ebp,%esp
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    
	...

008002d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002dd:	e8 69 0b 00 00       	call   800e4b <sys_env_destroy>
}
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
  8002e9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ec:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ef:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002f5:	e8 ae 0b 00 00       	call   800ea8 <sys_getenvid>
  8002fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002fd:	89 54 24 10          	mov    %edx,0x10(%esp)
  800301:	8b 55 08             	mov    0x8(%ebp),%edx
  800304:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800308:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80030c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800310:	c7 04 24 98 14 80 00 	movl   $0x801498,(%esp)
  800317:	e8 c3 00 00 00       	call   8003df <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80031c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800320:	8b 45 10             	mov    0x10(%ebp),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	e8 53 00 00 00       	call   80037e <vcprintf>
	cprintf("\n");
  80032b:	c7 04 24 8c 14 80 00 	movl   $0x80148c,(%esp)
  800332:	e8 a8 00 00 00       	call   8003df <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800337:	cc                   	int3   
  800338:	eb fd                	jmp    800337 <_panic+0x53>
	...

0080033c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	53                   	push   %ebx
  800340:	83 ec 14             	sub    $0x14,%esp
  800343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800346:	8b 03                	mov    (%ebx),%eax
  800348:	8b 55 08             	mov    0x8(%ebp),%edx
  80034b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80034f:	83 c0 01             	add    $0x1,%eax
  800352:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800354:	3d ff 00 00 00       	cmp    $0xff,%eax
  800359:	75 19                	jne    800374 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80035b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800362:	00 
  800363:	8d 43 08             	lea    0x8(%ebx),%eax
  800366:	89 04 24             	mov    %eax,(%esp)
  800369:	e8 76 0a 00 00       	call   800de4 <sys_cputs>
		b->idx = 0;
  80036e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800374:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800378:	83 c4 14             	add    $0x14,%esp
  80037b:	5b                   	pop    %ebx
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800387:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80038e:	00 00 00 
	b.cnt = 0;
  800391:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800398:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80039b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80039e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b3:	c7 04 24 3c 03 80 00 	movl   $0x80033c,(%esp)
  8003ba:	e8 e2 01 00 00       	call   8005a1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003bf:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	e8 0d 0a 00 00       	call   800de4 <sys_cputs>

	return b.cnt;
}
  8003d7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003dd:	c9                   	leave  
  8003de:	c3                   	ret    

008003df <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ef:	89 04 24             	mov    %eax,(%esp)
  8003f2:	e8 87 ff ff ff       	call   80037e <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f7:	c9                   	leave  
  8003f8:	c3                   	ret    
  8003f9:	00 00                	add    %al,(%eax)
  8003fb:	00 00                	add    %al,(%eax)
  8003fd:	00 00                	add    %al,(%eax)
	...

00800400 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	57                   	push   %edi
  800404:	56                   	push   %esi
  800405:	53                   	push   %ebx
  800406:	83 ec 4c             	sub    $0x4c,%esp
  800409:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040c:	89 d6                	mov    %edx,%esi
  80040e:	8b 45 08             	mov    0x8(%ebp),%eax
  800411:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800414:	8b 55 0c             	mov    0xc(%ebp),%edx
  800417:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80041a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80041d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800420:	b8 00 00 00 00       	mov    $0x0,%eax
  800425:	39 d0                	cmp    %edx,%eax
  800427:	72 11                	jb     80043a <printnum+0x3a>
  800429:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80042c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  80042f:	76 09                	jbe    80043a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800431:	83 eb 01             	sub    $0x1,%ebx
  800434:	85 db                	test   %ebx,%ebx
  800436:	7f 5d                	jg     800495 <printnum+0x95>
  800438:	eb 6c                	jmp    8004a6 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80043a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80043e:	83 eb 01             	sub    $0x1,%ebx
  800441:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800445:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800448:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80044c:	8b 44 24 08          	mov    0x8(%esp),%eax
  800450:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800454:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800457:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80045a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800461:	00 
  800462:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800465:	89 14 24             	mov    %edx,(%esp)
  800468:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80046f:	e8 0c 0d 00 00       	call   801180 <__udivdi3>
  800474:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800477:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80047a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80047e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800482:	89 04 24             	mov    %eax,(%esp)
  800485:	89 54 24 04          	mov    %edx,0x4(%esp)
  800489:	89 f2                	mov    %esi,%edx
  80048b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80048e:	e8 6d ff ff ff       	call   800400 <printnum>
  800493:	eb 11                	jmp    8004a6 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800495:	89 74 24 04          	mov    %esi,0x4(%esp)
  800499:	89 3c 24             	mov    %edi,(%esp)
  80049c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80049f:	83 eb 01             	sub    $0x1,%ebx
  8004a2:	85 db                	test   %ebx,%ebx
  8004a4:	7f ef                	jg     800495 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004aa:	8b 74 24 04          	mov    0x4(%esp),%esi
  8004ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004bc:	00 
  8004bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8004c0:	89 14 24             	mov    %edx,(%esp)
  8004c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ca:	e8 c1 0d 00 00       	call   801290 <__umoddi3>
  8004cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d3:	0f be 80 bc 14 80 00 	movsbl 0x8014bc(%eax),%eax
  8004da:	89 04 24             	mov    %eax,(%esp)
  8004dd:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004e0:	83 c4 4c             	add    $0x4c,%esp
  8004e3:	5b                   	pop    %ebx
  8004e4:	5e                   	pop    %esi
  8004e5:	5f                   	pop    %edi
  8004e6:	5d                   	pop    %ebp
  8004e7:	c3                   	ret    

008004e8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004eb:	83 fa 01             	cmp    $0x1,%edx
  8004ee:	7e 0e                	jle    8004fe <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004f0:	8b 10                	mov    (%eax),%edx
  8004f2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004f5:	89 08                	mov    %ecx,(%eax)
  8004f7:	8b 02                	mov    (%edx),%eax
  8004f9:	8b 52 04             	mov    0x4(%edx),%edx
  8004fc:	eb 22                	jmp    800520 <getuint+0x38>
	else if (lflag)
  8004fe:	85 d2                	test   %edx,%edx
  800500:	74 10                	je     800512 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800502:	8b 10                	mov    (%eax),%edx
  800504:	8d 4a 04             	lea    0x4(%edx),%ecx
  800507:	89 08                	mov    %ecx,(%eax)
  800509:	8b 02                	mov    (%edx),%eax
  80050b:	ba 00 00 00 00       	mov    $0x0,%edx
  800510:	eb 0e                	jmp    800520 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800512:	8b 10                	mov    (%eax),%edx
  800514:	8d 4a 04             	lea    0x4(%edx),%ecx
  800517:	89 08                	mov    %ecx,(%eax)
  800519:	8b 02                	mov    (%edx),%eax
  80051b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800520:	5d                   	pop    %ebp
  800521:	c3                   	ret    

00800522 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800525:	83 fa 01             	cmp    $0x1,%edx
  800528:	7e 0e                	jle    800538 <getint+0x16>
		return va_arg(*ap, long long);
  80052a:	8b 10                	mov    (%eax),%edx
  80052c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80052f:	89 08                	mov    %ecx,(%eax)
  800531:	8b 02                	mov    (%edx),%eax
  800533:	8b 52 04             	mov    0x4(%edx),%edx
  800536:	eb 22                	jmp    80055a <getint+0x38>
	else if (lflag)
  800538:	85 d2                	test   %edx,%edx
  80053a:	74 10                	je     80054c <getint+0x2a>
		return va_arg(*ap, long);
  80053c:	8b 10                	mov    (%eax),%edx
  80053e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800541:	89 08                	mov    %ecx,(%eax)
  800543:	8b 02                	mov    (%edx),%eax
  800545:	89 c2                	mov    %eax,%edx
  800547:	c1 fa 1f             	sar    $0x1f,%edx
  80054a:	eb 0e                	jmp    80055a <getint+0x38>
	else
		return va_arg(*ap, int);
  80054c:	8b 10                	mov    (%eax),%edx
  80054e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800551:	89 08                	mov    %ecx,(%eax)
  800553:	8b 02                	mov    (%edx),%eax
  800555:	89 c2                	mov    %eax,%edx
  800557:	c1 fa 1f             	sar    $0x1f,%edx
}
  80055a:	5d                   	pop    %ebp
  80055b:	c3                   	ret    

0080055c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80055c:	55                   	push   %ebp
  80055d:	89 e5                	mov    %esp,%ebp
  80055f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800562:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800566:	8b 10                	mov    (%eax),%edx
  800568:	3b 50 04             	cmp    0x4(%eax),%edx
  80056b:	73 0a                	jae    800577 <sprintputch+0x1b>
		*b->buf++ = ch;
  80056d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800570:	88 0a                	mov    %cl,(%edx)
  800572:	83 c2 01             	add    $0x1,%edx
  800575:	89 10                	mov    %edx,(%eax)
}
  800577:	5d                   	pop    %ebp
  800578:	c3                   	ret    

00800579 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800579:	55                   	push   %ebp
  80057a:	89 e5                	mov    %esp,%ebp
  80057c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80057f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800582:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800586:	8b 45 10             	mov    0x10(%ebp),%eax
  800589:	89 44 24 08          	mov    %eax,0x8(%esp)
  80058d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800590:	89 44 24 04          	mov    %eax,0x4(%esp)
  800594:	8b 45 08             	mov    0x8(%ebp),%eax
  800597:	89 04 24             	mov    %eax,(%esp)
  80059a:	e8 02 00 00 00       	call   8005a1 <vprintfmt>
	va_end(ap);
}
  80059f:	c9                   	leave  
  8005a0:	c3                   	ret    

008005a1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005a1:	55                   	push   %ebp
  8005a2:	89 e5                	mov    %esp,%ebp
  8005a4:	57                   	push   %edi
  8005a5:	56                   	push   %esi
  8005a6:	53                   	push   %ebx
  8005a7:	83 ec 4c             	sub    $0x4c,%esp
  8005aa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005ad:	eb 23                	jmp    8005d2 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	75 12                	jne    8005c5 <vprintfmt+0x24>
				csa = 0x0700;
  8005b3:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  8005ba:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8005bd:	83 c4 4c             	add    $0x4c,%esp
  8005c0:	5b                   	pop    %ebx
  8005c1:	5e                   	pop    %esi
  8005c2:	5f                   	pop    %edi
  8005c3:	5d                   	pop    %ebp
  8005c4:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  8005c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005c8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005cc:	89 04 24             	mov    %eax,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005d2:	0f b6 07             	movzbl (%edi),%eax
  8005d5:	83 c7 01             	add    $0x1,%edi
  8005d8:	83 f8 25             	cmp    $0x25,%eax
  8005db:	75 d2                	jne    8005af <vprintfmt+0xe>
  8005dd:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8005e1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005e8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8005ed:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005f4:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005f9:	be 00 00 00 00       	mov    $0x0,%esi
  8005fe:	eb 14                	jmp    800614 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800600:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800604:	eb 0e                	jmp    800614 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800606:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80060a:	eb 08                	jmp    800614 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80060c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80060f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800614:	0f b6 07             	movzbl (%edi),%eax
  800617:	0f b6 c8             	movzbl %al,%ecx
  80061a:	83 c7 01             	add    $0x1,%edi
  80061d:	83 e8 23             	sub    $0x23,%eax
  800620:	3c 55                	cmp    $0x55,%al
  800622:	0f 87 ed 02 00 00    	ja     800915 <vprintfmt+0x374>
  800628:	0f b6 c0             	movzbl %al,%eax
  80062b:	ff 24 85 80 15 80 00 	jmp    *0x801580(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800632:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  800635:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800638:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80063b:	83 f9 09             	cmp    $0x9,%ecx
  80063e:	77 3c                	ja     80067c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800640:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800643:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  800646:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  80064a:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80064d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800650:	83 f9 09             	cmp    $0x9,%ecx
  800653:	76 eb                	jbe    800640 <vprintfmt+0x9f>
  800655:	eb 25                	jmp    80067c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 48 04             	lea    0x4(%eax),%ecx
  80065d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800660:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  800662:	eb 18                	jmp    80067c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  800664:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800668:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80066b:	0f 48 c6             	cmovs  %esi,%eax
  80066e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800671:	eb a1                	jmp    800614 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  800673:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80067a:	eb 98                	jmp    800614 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  80067c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800680:	79 92                	jns    800614 <vprintfmt+0x73>
  800682:	eb 88                	jmp    80060c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800684:	83 c2 01             	add    $0x1,%edx
  800687:	eb 8b                	jmp    800614 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8d 50 04             	lea    0x4(%eax),%edx
  80068f:	89 55 14             	mov    %edx,0x14(%ebp)
  800692:	8b 55 0c             	mov    0xc(%ebp),%edx
  800695:	89 54 24 04          	mov    %edx,0x4(%esp)
  800699:	8b 00                	mov    (%eax),%eax
  80069b:	89 04 24             	mov    %eax,(%esp)
  80069e:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006a1:	e9 2c ff ff ff       	jmp    8005d2 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 00                	mov    (%eax),%eax
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	c1 fa 1f             	sar    $0x1f,%edx
  8006b6:	31 d0                	xor    %edx,%eax
  8006b8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006ba:	83 f8 08             	cmp    $0x8,%eax
  8006bd:	7f 0b                	jg     8006ca <vprintfmt+0x129>
  8006bf:	8b 14 85 e0 16 80 00 	mov    0x8016e0(,%eax,4),%edx
  8006c6:	85 d2                	test   %edx,%edx
  8006c8:	75 23                	jne    8006ed <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  8006ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ce:	c7 44 24 08 d4 14 80 	movl   $0x8014d4,0x8(%esp)
  8006d5:	00 
  8006d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e0:	89 04 24             	mov    %eax,(%esp)
  8006e3:	e8 91 fe ff ff       	call   800579 <printfmt>
  8006e8:	e9 e5 fe ff ff       	jmp    8005d2 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8006ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006f1:	c7 44 24 08 dd 14 80 	movl   $0x8014dd,0x8(%esp)
  8006f8:	00 
  8006f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800700:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800703:	89 1c 24             	mov    %ebx,(%esp)
  800706:	e8 6e fe ff ff       	call   800579 <printfmt>
  80070b:	e9 c2 fe ff ff       	jmp    8005d2 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800710:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800713:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800716:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8d 50 04             	lea    0x4(%eax),%edx
  80071f:	89 55 14             	mov    %edx,0x14(%ebp)
  800722:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800724:	85 f6                	test   %esi,%esi
  800726:	ba cd 14 80 00       	mov    $0x8014cd,%edx
  80072b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80072e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800732:	7e 06                	jle    80073a <vprintfmt+0x199>
  800734:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800738:	75 13                	jne    80074d <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073a:	0f be 06             	movsbl (%esi),%eax
  80073d:	83 c6 01             	add    $0x1,%esi
  800740:	85 c0                	test   %eax,%eax
  800742:	0f 85 a2 00 00 00    	jne    8007ea <vprintfmt+0x249>
  800748:	e9 92 00 00 00       	jmp    8007df <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800751:	89 34 24             	mov    %esi,(%esp)
  800754:	e8 82 02 00 00       	call   8009db <strnlen>
  800759:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80075c:	29 c2                	sub    %eax,%edx
  80075e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800761:	85 d2                	test   %edx,%edx
  800763:	7e d5                	jle    80073a <vprintfmt+0x199>
					putch(padc, putdat);
  800765:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800769:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80076c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80076f:	89 d3                	mov    %edx,%ebx
  800771:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800774:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800777:	89 c6                	mov    %eax,%esi
  800779:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077d:	89 34 24             	mov    %esi,(%esp)
  800780:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800783:	83 eb 01             	sub    $0x1,%ebx
  800786:	85 db                	test   %ebx,%ebx
  800788:	7f ef                	jg     800779 <vprintfmt+0x1d8>
  80078a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80078d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800790:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800793:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80079a:	eb 9e                	jmp    80073a <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80079c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007a0:	74 1b                	je     8007bd <vprintfmt+0x21c>
  8007a2:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007a5:	83 fa 5e             	cmp    $0x5e,%edx
  8007a8:	76 13                	jbe    8007bd <vprintfmt+0x21c>
					putch('?', putdat);
  8007aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007b8:	ff 55 08             	call   *0x8(%ebp)
  8007bb:	eb 0d                	jmp    8007ca <vprintfmt+0x229>
				else
					putch(ch, putdat);
  8007bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c4:	89 04 24             	mov    %eax,(%esp)
  8007c7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ca:	83 ef 01             	sub    $0x1,%edi
  8007cd:	0f be 06             	movsbl (%esi),%eax
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	74 05                	je     8007d9 <vprintfmt+0x238>
  8007d4:	83 c6 01             	add    $0x1,%esi
  8007d7:	eb 17                	jmp    8007f0 <vprintfmt+0x24f>
  8007d9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007dc:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007df:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007e3:	7f 1c                	jg     800801 <vprintfmt+0x260>
  8007e5:	e9 e8 fd ff ff       	jmp    8005d2 <vprintfmt+0x31>
  8007ea:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8007ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	78 a8                	js     80079c <vprintfmt+0x1fb>
  8007f4:	83 eb 01             	sub    $0x1,%ebx
  8007f7:	79 a3                	jns    80079c <vprintfmt+0x1fb>
  8007f9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007fc:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8007ff:	eb de                	jmp    8007df <vprintfmt+0x23e>
  800801:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800804:	8b 7d 08             	mov    0x8(%ebp),%edi
  800807:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80080a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80080e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800815:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800817:	83 eb 01             	sub    $0x1,%ebx
  80081a:	85 db                	test   %ebx,%ebx
  80081c:	7f ec                	jg     80080a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800821:	e9 ac fd ff ff       	jmp    8005d2 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800826:	8d 45 14             	lea    0x14(%ebp),%eax
  800829:	e8 f4 fc ff ff       	call   800522 <getint>
  80082e:	89 c3                	mov    %eax,%ebx
  800830:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800832:	85 d2                	test   %edx,%edx
  800834:	78 0a                	js     800840 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800836:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80083b:	e9 87 00 00 00       	jmp    8008c7 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800840:	8b 45 0c             	mov    0xc(%ebp),%eax
  800843:	89 44 24 04          	mov    %eax,0x4(%esp)
  800847:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80084e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800851:	89 d8                	mov    %ebx,%eax
  800853:	89 f2                	mov    %esi,%edx
  800855:	f7 d8                	neg    %eax
  800857:	83 d2 00             	adc    $0x0,%edx
  80085a:	f7 da                	neg    %edx
			}
			base = 10;
  80085c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800861:	eb 64                	jmp    8008c7 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800863:	8d 45 14             	lea    0x14(%ebp),%eax
  800866:	e8 7d fc ff ff       	call   8004e8 <getuint>
			base = 10;
  80086b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800870:	eb 55                	jmp    8008c7 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800872:	8d 45 14             	lea    0x14(%ebp),%eax
  800875:	e8 6e fc ff ff       	call   8004e8 <getuint>
      base = 8;
  80087a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80087f:	eb 46                	jmp    8008c7 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
  800884:	89 54 24 04          	mov    %edx,0x4(%esp)
  800888:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80088f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800892:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800895:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800899:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008a0:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a6:	8d 50 04             	lea    0x4(%eax),%edx
  8008a9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008ac:	8b 00                	mov    (%eax),%eax
  8008ae:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008b3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008b8:	eb 0d                	jmp    8008c7 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8008bd:	e8 26 fc ff ff       	call   8004e8 <getuint>
			base = 16;
  8008c2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008c7:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8008cb:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8008cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008da:	89 04 24             	mov    %eax,(%esp)
  8008dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	e8 14 fb ff ff       	call   800400 <printnum>
			break;
  8008ec:	e9 e1 fc ff ff       	jmp    8005d2 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f8:	89 0c 24             	mov    %ecx,(%esp)
  8008fb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008fe:	e9 cf fc ff ff       	jmp    8005d2 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800903:	8d 45 14             	lea    0x14(%ebp),%eax
  800906:	e8 17 fc ff ff       	call   800522 <getint>
			csa = num;
  80090b:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  800910:	e9 bd fc ff ff       	jmp    8005d2 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800915:	8b 55 0c             	mov    0xc(%ebp),%edx
  800918:	89 54 24 04          	mov    %edx,0x4(%esp)
  80091c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800923:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800926:	83 ef 01             	sub    $0x1,%edi
  800929:	eb 02                	jmp    80092d <vprintfmt+0x38c>
  80092b:	89 c7                	mov    %eax,%edi
  80092d:	8d 47 ff             	lea    -0x1(%edi),%eax
  800930:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800934:	75 f5                	jne    80092b <vprintfmt+0x38a>
  800936:	e9 97 fc ff ff       	jmp    8005d2 <vprintfmt+0x31>

0080093b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	83 ec 28             	sub    $0x28,%esp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800947:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80094a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80094e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800951:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800958:	85 c0                	test   %eax,%eax
  80095a:	74 30                	je     80098c <vsnprintf+0x51>
  80095c:	85 d2                	test   %edx,%edx
  80095e:	7e 2c                	jle    80098c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800960:	8b 45 14             	mov    0x14(%ebp),%eax
  800963:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800967:	8b 45 10             	mov    0x10(%ebp),%eax
  80096a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800971:	89 44 24 04          	mov    %eax,0x4(%esp)
  800975:	c7 04 24 5c 05 80 00 	movl   $0x80055c,(%esp)
  80097c:	e8 20 fc ff ff       	call   8005a1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800981:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800984:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800987:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80098a:	eb 05                	jmp    800991 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80098c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800991:	c9                   	leave  
  800992:	c3                   	ret    

00800993 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800999:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80099c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	89 04 24             	mov    %eax,(%esp)
  8009b4:	e8 82 ff ff ff       	call   80093b <vsnprintf>
	va_end(ap);

	return rc;
}
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    
  8009bb:	00 00                	add    %al,(%eax)
  8009bd:	00 00                	add    %al,(%eax)
	...

008009c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8009ce:	74 09                	je     8009d9 <strlen+0x19>
		n++;
  8009d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009d7:	75 f7                	jne    8009d0 <strlen+0x10>
		n++;
	return n;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e9:	85 d2                	test   %edx,%edx
  8009eb:	74 12                	je     8009ff <strnlen+0x24>
  8009ed:	80 39 00             	cmpb   $0x0,(%ecx)
  8009f0:	74 0d                	je     8009ff <strnlen+0x24>
		n++;
  8009f2:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f5:	39 d0                	cmp    %edx,%eax
  8009f7:	74 06                	je     8009ff <strnlen+0x24>
  8009f9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009fd:	75 f3                	jne    8009f2 <strnlen+0x17>
		n++;
	return n;
}
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	53                   	push   %ebx
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a10:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a14:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a17:	83 c2 01             	add    $0x1,%edx
  800a1a:	84 c9                	test   %cl,%cl
  800a1c:	75 f2                	jne    800a10 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	53                   	push   %ebx
  800a25:	83 ec 08             	sub    $0x8,%esp
  800a28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a2b:	89 1c 24             	mov    %ebx,(%esp)
  800a2e:	e8 8d ff ff ff       	call   8009c0 <strlen>
	strcpy(dst + len, src);
  800a33:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a36:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a3a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a3d:	89 04 24             	mov    %eax,(%esp)
  800a40:	e8 bc ff ff ff       	call   800a01 <strcpy>
	return dst;
}
  800a45:	89 d8                	mov    %ebx,%eax
  800a47:	83 c4 08             	add    $0x8,%esp
  800a4a:	5b                   	pop    %ebx
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a58:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a5b:	85 f6                	test   %esi,%esi
  800a5d:	74 18                	je     800a77 <strncpy+0x2a>
  800a5f:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a64:	0f b6 1a             	movzbl (%edx),%ebx
  800a67:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a6a:	80 3a 01             	cmpb   $0x1,(%edx)
  800a6d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a70:	83 c1 01             	add    $0x1,%ecx
  800a73:	39 ce                	cmp    %ecx,%esi
  800a75:	77 ed                	ja     800a64 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 75 08             	mov    0x8(%ebp),%esi
  800a83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a89:	89 f0                	mov    %esi,%eax
  800a8b:	85 c9                	test   %ecx,%ecx
  800a8d:	74 23                	je     800ab2 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  800a8f:	83 e9 01             	sub    $0x1,%ecx
  800a92:	74 1b                	je     800aaf <strlcpy+0x34>
  800a94:	0f b6 1a             	movzbl (%edx),%ebx
  800a97:	84 db                	test   %bl,%bl
  800a99:	74 14                	je     800aaf <strlcpy+0x34>
			*dst++ = *src++;
  800a9b:	88 18                	mov    %bl,(%eax)
  800a9d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aa0:	83 e9 01             	sub    $0x1,%ecx
  800aa3:	74 0a                	je     800aaf <strlcpy+0x34>
			*dst++ = *src++;
  800aa5:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aa8:	0f b6 1a             	movzbl (%edx),%ebx
  800aab:	84 db                	test   %bl,%bl
  800aad:	75 ec                	jne    800a9b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  800aaf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ab2:	29 f0                	sub    %esi,%eax
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5d                   	pop    %ebp
  800ab7:	c3                   	ret    

00800ab8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800abe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ac1:	0f b6 01             	movzbl (%ecx),%eax
  800ac4:	84 c0                	test   %al,%al
  800ac6:	74 15                	je     800add <strcmp+0x25>
  800ac8:	3a 02                	cmp    (%edx),%al
  800aca:	75 11                	jne    800add <strcmp+0x25>
		p++, q++;
  800acc:	83 c1 01             	add    $0x1,%ecx
  800acf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ad2:	0f b6 01             	movzbl (%ecx),%eax
  800ad5:	84 c0                	test   %al,%al
  800ad7:	74 04                	je     800add <strcmp+0x25>
  800ad9:	3a 02                	cmp    (%edx),%al
  800adb:	74 ef                	je     800acc <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800add:	0f b6 c0             	movzbl %al,%eax
  800ae0:	0f b6 12             	movzbl (%edx),%edx
  800ae3:	29 d0                	sub    %edx,%eax
}
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	53                   	push   %ebx
  800aeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800af9:	85 d2                	test   %edx,%edx
  800afb:	74 28                	je     800b25 <strncmp+0x3e>
  800afd:	0f b6 01             	movzbl (%ecx),%eax
  800b00:	84 c0                	test   %al,%al
  800b02:	74 24                	je     800b28 <strncmp+0x41>
  800b04:	3a 03                	cmp    (%ebx),%al
  800b06:	75 20                	jne    800b28 <strncmp+0x41>
  800b08:	83 ea 01             	sub    $0x1,%edx
  800b0b:	74 13                	je     800b20 <strncmp+0x39>
		n--, p++, q++;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b13:	0f b6 01             	movzbl (%ecx),%eax
  800b16:	84 c0                	test   %al,%al
  800b18:	74 0e                	je     800b28 <strncmp+0x41>
  800b1a:	3a 03                	cmp    (%ebx),%al
  800b1c:	74 ea                	je     800b08 <strncmp+0x21>
  800b1e:	eb 08                	jmp    800b28 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b20:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b25:	5b                   	pop    %ebx
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b28:	0f b6 01             	movzbl (%ecx),%eax
  800b2b:	0f b6 13             	movzbl (%ebx),%edx
  800b2e:	29 d0                	sub    %edx,%eax
  800b30:	eb f3                	jmp    800b25 <strncmp+0x3e>

00800b32 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b3c:	0f b6 10             	movzbl (%eax),%edx
  800b3f:	84 d2                	test   %dl,%dl
  800b41:	74 20                	je     800b63 <strchr+0x31>
		if (*s == c)
  800b43:	38 ca                	cmp    %cl,%dl
  800b45:	75 0b                	jne    800b52 <strchr+0x20>
  800b47:	eb 1f                	jmp    800b68 <strchr+0x36>
  800b49:	38 ca                	cmp    %cl,%dl
  800b4b:	90                   	nop
  800b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b50:	74 16                	je     800b68 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b52:	83 c0 01             	add    $0x1,%eax
  800b55:	0f b6 10             	movzbl (%eax),%edx
  800b58:	84 d2                	test   %dl,%dl
  800b5a:	75 ed                	jne    800b49 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b61:	eb 05                	jmp    800b68 <strchr+0x36>
  800b63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b74:	0f b6 10             	movzbl (%eax),%edx
  800b77:	84 d2                	test   %dl,%dl
  800b79:	74 14                	je     800b8f <strfind+0x25>
		if (*s == c)
  800b7b:	38 ca                	cmp    %cl,%dl
  800b7d:	75 06                	jne    800b85 <strfind+0x1b>
  800b7f:	eb 0e                	jmp    800b8f <strfind+0x25>
  800b81:	38 ca                	cmp    %cl,%dl
  800b83:	74 0a                	je     800b8f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b85:	83 c0 01             	add    $0x1,%eax
  800b88:	0f b6 10             	movzbl (%eax),%edx
  800b8b:	84 d2                	test   %dl,%dl
  800b8d:	75 f2                	jne    800b81 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 0c             	sub    $0xc,%esp
  800b97:	89 1c 24             	mov    %ebx,(%esp)
  800b9a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b9e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ba2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bab:	85 c9                	test   %ecx,%ecx
  800bad:	74 30                	je     800bdf <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800baf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb5:	75 25                	jne    800bdc <memset+0x4b>
  800bb7:	f6 c1 03             	test   $0x3,%cl
  800bba:	75 20                	jne    800bdc <memset+0x4b>
		c &= 0xFF;
  800bbc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bbf:	89 d3                	mov    %edx,%ebx
  800bc1:	c1 e3 08             	shl    $0x8,%ebx
  800bc4:	89 d6                	mov    %edx,%esi
  800bc6:	c1 e6 18             	shl    $0x18,%esi
  800bc9:	89 d0                	mov    %edx,%eax
  800bcb:	c1 e0 10             	shl    $0x10,%eax
  800bce:	09 f0                	or     %esi,%eax
  800bd0:	09 d0                	or     %edx,%eax
  800bd2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bd4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bd7:	fc                   	cld    
  800bd8:	f3 ab                	rep stos %eax,%es:(%edi)
  800bda:	eb 03                	jmp    800bdf <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bdc:	fc                   	cld    
  800bdd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bdf:	89 f8                	mov    %edi,%eax
  800be1:	8b 1c 24             	mov    (%esp),%ebx
  800be4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800be8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bec:	89 ec                	mov    %ebp,%esp
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	83 ec 08             	sub    $0x8,%esp
  800bf6:	89 34 24             	mov    %esi,(%esp)
  800bf9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800c00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c03:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c06:	39 c6                	cmp    %eax,%esi
  800c08:	73 36                	jae    800c40 <memmove+0x50>
  800c0a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c0d:	39 d0                	cmp    %edx,%eax
  800c0f:	73 2f                	jae    800c40 <memmove+0x50>
		s += n;
		d += n;
  800c11:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c14:	f6 c2 03             	test   $0x3,%dl
  800c17:	75 1b                	jne    800c34 <memmove+0x44>
  800c19:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c1f:	75 13                	jne    800c34 <memmove+0x44>
  800c21:	f6 c1 03             	test   $0x3,%cl
  800c24:	75 0e                	jne    800c34 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c26:	83 ef 04             	sub    $0x4,%edi
  800c29:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c2c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c2f:	fd                   	std    
  800c30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c32:	eb 09                	jmp    800c3d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c34:	83 ef 01             	sub    $0x1,%edi
  800c37:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c3a:	fd                   	std    
  800c3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c3d:	fc                   	cld    
  800c3e:	eb 20                	jmp    800c60 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c40:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c46:	75 13                	jne    800c5b <memmove+0x6b>
  800c48:	a8 03                	test   $0x3,%al
  800c4a:	75 0f                	jne    800c5b <memmove+0x6b>
  800c4c:	f6 c1 03             	test   $0x3,%cl
  800c4f:	75 0a                	jne    800c5b <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c51:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c54:	89 c7                	mov    %eax,%edi
  800c56:	fc                   	cld    
  800c57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c59:	eb 05                	jmp    800c60 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c5b:	89 c7                	mov    %eax,%edi
  800c5d:	fc                   	cld    
  800c5e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c60:	8b 34 24             	mov    (%esp),%esi
  800c63:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c67:	89 ec                	mov    %ebp,%esp
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c71:	8b 45 10             	mov    0x10(%ebp),%eax
  800c74:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	89 04 24             	mov    %eax,(%esp)
  800c85:	e8 66 ff ff ff       	call   800bf0 <memmove>
}
  800c8a:	c9                   	leave  
  800c8b:	c3                   	ret    

00800c8c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c95:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c98:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c9b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca0:	85 ff                	test   %edi,%edi
  800ca2:	74 38                	je     800cdc <memcmp+0x50>
		if (*s1 != *s2)
  800ca4:	0f b6 03             	movzbl (%ebx),%eax
  800ca7:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800caa:	83 ef 01             	sub    $0x1,%edi
  800cad:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800cb2:	38 c8                	cmp    %cl,%al
  800cb4:	74 1d                	je     800cd3 <memcmp+0x47>
  800cb6:	eb 11                	jmp    800cc9 <memcmp+0x3d>
  800cb8:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800cbd:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800cc2:	83 c2 01             	add    $0x1,%edx
  800cc5:	38 c8                	cmp    %cl,%al
  800cc7:	74 0a                	je     800cd3 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800cc9:	0f b6 c0             	movzbl %al,%eax
  800ccc:	0f b6 c9             	movzbl %cl,%ecx
  800ccf:	29 c8                	sub    %ecx,%eax
  800cd1:	eb 09                	jmp    800cdc <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cd3:	39 fa                	cmp    %edi,%edx
  800cd5:	75 e1                	jne    800cb8 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ce7:	89 c2                	mov    %eax,%edx
  800ce9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cec:	39 d0                	cmp    %edx,%eax
  800cee:	73 15                	jae    800d05 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800cf4:	38 08                	cmp    %cl,(%eax)
  800cf6:	75 06                	jne    800cfe <memfind+0x1d>
  800cf8:	eb 0b                	jmp    800d05 <memfind+0x24>
  800cfa:	38 08                	cmp    %cl,(%eax)
  800cfc:	74 07                	je     800d05 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cfe:	83 c0 01             	add    $0x1,%eax
  800d01:	39 c2                	cmp    %eax,%edx
  800d03:	77 f5                	ja     800cfa <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d13:	0f b6 02             	movzbl (%edx),%eax
  800d16:	3c 20                	cmp    $0x20,%al
  800d18:	74 04                	je     800d1e <strtol+0x17>
  800d1a:	3c 09                	cmp    $0x9,%al
  800d1c:	75 0e                	jne    800d2c <strtol+0x25>
		s++;
  800d1e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d21:	0f b6 02             	movzbl (%edx),%eax
  800d24:	3c 20                	cmp    $0x20,%al
  800d26:	74 f6                	je     800d1e <strtol+0x17>
  800d28:	3c 09                	cmp    $0x9,%al
  800d2a:	74 f2                	je     800d1e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d2c:	3c 2b                	cmp    $0x2b,%al
  800d2e:	75 0a                	jne    800d3a <strtol+0x33>
		s++;
  800d30:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d33:	bf 00 00 00 00       	mov    $0x0,%edi
  800d38:	eb 10                	jmp    800d4a <strtol+0x43>
  800d3a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d3f:	3c 2d                	cmp    $0x2d,%al
  800d41:	75 07                	jne    800d4a <strtol+0x43>
		s++, neg = 1;
  800d43:	83 c2 01             	add    $0x1,%edx
  800d46:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d4a:	85 db                	test   %ebx,%ebx
  800d4c:	0f 94 c0             	sete   %al
  800d4f:	74 05                	je     800d56 <strtol+0x4f>
  800d51:	83 fb 10             	cmp    $0x10,%ebx
  800d54:	75 15                	jne    800d6b <strtol+0x64>
  800d56:	80 3a 30             	cmpb   $0x30,(%edx)
  800d59:	75 10                	jne    800d6b <strtol+0x64>
  800d5b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d5f:	75 0a                	jne    800d6b <strtol+0x64>
		s += 2, base = 16;
  800d61:	83 c2 02             	add    $0x2,%edx
  800d64:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d69:	eb 13                	jmp    800d7e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d6b:	84 c0                	test   %al,%al
  800d6d:	74 0f                	je     800d7e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d6f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d74:	80 3a 30             	cmpb   $0x30,(%edx)
  800d77:	75 05                	jne    800d7e <strtol+0x77>
		s++, base = 8;
  800d79:	83 c2 01             	add    $0x1,%edx
  800d7c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d83:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d85:	0f b6 0a             	movzbl (%edx),%ecx
  800d88:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d8b:	80 fb 09             	cmp    $0x9,%bl
  800d8e:	77 08                	ja     800d98 <strtol+0x91>
			dig = *s - '0';
  800d90:	0f be c9             	movsbl %cl,%ecx
  800d93:	83 e9 30             	sub    $0x30,%ecx
  800d96:	eb 1e                	jmp    800db6 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d98:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d9b:	80 fb 19             	cmp    $0x19,%bl
  800d9e:	77 08                	ja     800da8 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800da0:	0f be c9             	movsbl %cl,%ecx
  800da3:	83 e9 57             	sub    $0x57,%ecx
  800da6:	eb 0e                	jmp    800db6 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800da8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800dab:	80 fb 19             	cmp    $0x19,%bl
  800dae:	77 15                	ja     800dc5 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800db0:	0f be c9             	movsbl %cl,%ecx
  800db3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800db6:	39 f1                	cmp    %esi,%ecx
  800db8:	7d 0f                	jge    800dc9 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800dba:	83 c2 01             	add    $0x1,%edx
  800dbd:	0f af c6             	imul   %esi,%eax
  800dc0:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800dc3:	eb c0                	jmp    800d85 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800dc5:	89 c1                	mov    %eax,%ecx
  800dc7:	eb 02                	jmp    800dcb <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dc9:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dcb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dcf:	74 05                	je     800dd6 <strtol+0xcf>
		*endptr = (char *) s;
  800dd1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dd4:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dd6:	89 ca                	mov    %ecx,%edx
  800dd8:	f7 da                	neg    %edx
  800dda:	85 ff                	test   %edi,%edi
  800ddc:	0f 45 c2             	cmovne %edx,%eax
}
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	89 1c 24             	mov    %ebx,(%esp)
  800ded:	89 74 24 04          	mov    %esi,0x4(%esp)
  800df1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	89 c3                	mov    %eax,%ebx
  800e02:	89 c7                	mov    %eax,%edi
  800e04:	89 c6                	mov    %eax,%esi
  800e06:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e08:	8b 1c 24             	mov    (%esp),%ebx
  800e0b:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e0f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e13:	89 ec                	mov    %ebp,%esp
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	83 ec 0c             	sub    $0xc,%esp
  800e1d:	89 1c 24             	mov    %ebx,(%esp)
  800e20:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e24:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e32:	89 d1                	mov    %edx,%ecx
  800e34:	89 d3                	mov    %edx,%ebx
  800e36:	89 d7                	mov    %edx,%edi
  800e38:	89 d6                	mov    %edx,%esi
  800e3a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e3c:	8b 1c 24             	mov    (%esp),%ebx
  800e3f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e43:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e47:	89 ec                	mov    %ebp,%esp
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800e5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800e64:	8b 55 08             	mov    0x8(%ebp),%edx
  800e67:	89 cb                	mov    %ecx,%ebx
  800e69:	89 cf                	mov    %ecx,%edi
  800e6b:	89 ce                	mov    %ecx,%esi
  800e6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	7e 28                	jle    800e9b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e77:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e7e:	00 
  800e7f:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800e86:	00 
  800e87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8e:	00 
  800e8f:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800e96:	e8 49 f4 ff ff       	call   8002e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e9b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e9e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea4:	89 ec                	mov    %ebp,%esp
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	83 ec 0c             	sub    $0xc,%esp
  800eae:	89 1c 24             	mov    %ebx,(%esp)
  800eb1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eb5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ebe:	b8 02 00 00 00       	mov    $0x2,%eax
  800ec3:	89 d1                	mov    %edx,%ecx
  800ec5:	89 d3                	mov    %edx,%ebx
  800ec7:	89 d7                	mov    %edx,%edi
  800ec9:	89 d6                	mov    %edx,%esi
  800ecb:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800ecd:	8b 1c 24             	mov    (%esp),%ebx
  800ed0:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ed4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ed8:	89 ec                	mov    %ebp,%esp
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_yield>:

void
sys_yield(void)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 0c             	sub    $0xc,%esp
  800ee2:	89 1c 24             	mov    %ebx,(%esp)
  800ee5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ee9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eed:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef7:	89 d1                	mov    %edx,%ecx
  800ef9:	89 d3                	mov    %edx,%ebx
  800efb:	89 d7                	mov    %edx,%edi
  800efd:	89 d6                	mov    %edx,%esi
  800eff:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f01:	8b 1c 24             	mov    (%esp),%ebx
  800f04:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f08:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f0c:	89 ec                	mov    %ebp,%esp
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	83 ec 38             	sub    $0x38,%esp
  800f16:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f19:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f1c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1f:	be 00 00 00 00       	mov    $0x0,%esi
  800f24:	b8 04 00 00 00       	mov    $0x4,%eax
  800f29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f32:	89 f7                	mov    %esi,%edi
  800f34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f36:	85 c0                	test   %eax,%eax
  800f38:	7e 28                	jle    800f62 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f45:	00 
  800f46:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800f4d:	00 
  800f4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f55:	00 
  800f56:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800f5d:	e8 82 f3 ff ff       	call   8002e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f62:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f65:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f68:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f6b:	89 ec                	mov    %ebp,%esp
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 38             	sub    $0x38,%esp
  800f75:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f78:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f7b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7e:	b8 05 00 00 00       	mov    $0x5,%eax
  800f83:	8b 75 18             	mov    0x18(%ebp),%esi
  800f86:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f94:	85 c0                	test   %eax,%eax
  800f96:	7e 28                	jle    800fc0 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f98:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800fab:	00 
  800fac:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb3:	00 
  800fb4:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800fbb:	e8 24 f3 ff ff       	call   8002e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc9:	89 ec                	mov    %ebp,%esp
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	83 ec 38             	sub    $0x38,%esp
  800fd3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe1:	b8 06 00 00 00       	mov    $0x6,%eax
  800fe6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fec:	89 df                	mov    %ebx,%edi
  800fee:	89 de                	mov    %ebx,%esi
  800ff0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	7e 28                	jle    80101e <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ffa:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801001:	00 
  801002:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  801009:	00 
  80100a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801011:	00 
  801012:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  801019:	e8 c6 f2 ff ff       	call   8002e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80101e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801021:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801024:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801027:	89 ec                	mov    %ebp,%esp
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    

0080102b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 38             	sub    $0x38,%esp
  801031:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801034:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801037:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103f:	b8 08 00 00 00       	mov    $0x8,%eax
  801044:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801047:	8b 55 08             	mov    0x8(%ebp),%edx
  80104a:	89 df                	mov    %ebx,%edi
  80104c:	89 de                	mov    %ebx,%esi
  80104e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801050:	85 c0                	test   %eax,%eax
  801052:	7e 28                	jle    80107c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801054:	89 44 24 10          	mov    %eax,0x10(%esp)
  801058:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80105f:	00 
  801060:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  801067:	00 
  801068:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106f:	00 
  801070:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  801077:	e8 68 f2 ff ff       	call   8002e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80107c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80107f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801082:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801085:	89 ec                	mov    %ebp,%esp
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    

00801089 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	83 ec 38             	sub    $0x38,%esp
  80108f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801092:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801095:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801098:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109d:	b8 09 00 00 00       	mov    $0x9,%eax
  8010a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a8:	89 df                	mov    %ebx,%edi
  8010aa:	89 de                	mov    %ebx,%esi
  8010ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	7e 28                	jle    8010da <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b6:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8010bd:	00 
  8010be:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  8010c5:	00 
  8010c6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010cd:	00 
  8010ce:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  8010d5:	e8 0a f2 ff ff       	call   8002e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e3:	89 ec                	mov    %ebp,%esp
  8010e5:	5d                   	pop    %ebp
  8010e6:	c3                   	ret    

008010e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	83 ec 0c             	sub    $0xc,%esp
  8010ed:	89 1c 24             	mov    %ebx,(%esp)
  8010f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010f4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f8:	be 00 00 00 00       	mov    $0x0,%esi
  8010fd:	b8 0b 00 00 00       	mov    $0xb,%eax
  801102:	8b 7d 14             	mov    0x14(%ebp),%edi
  801105:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801108:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110b:	8b 55 08             	mov    0x8(%ebp),%edx
  80110e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801110:	8b 1c 24             	mov    (%esp),%ebx
  801113:	8b 74 24 04          	mov    0x4(%esp),%esi
  801117:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80111b:	89 ec                	mov    %ebp,%esp
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    

0080111f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	83 ec 38             	sub    $0x38,%esp
  801125:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801128:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80112b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801133:	b8 0c 00 00 00       	mov    $0xc,%eax
  801138:	8b 55 08             	mov    0x8(%ebp),%edx
  80113b:	89 cb                	mov    %ecx,%ebx
  80113d:	89 cf                	mov    %ecx,%edi
  80113f:	89 ce                	mov    %ecx,%esi
  801141:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801143:	85 c0                	test   %eax,%eax
  801145:	7e 28                	jle    80116f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801147:	89 44 24 10          	mov    %eax,0x10(%esp)
  80114b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801152:	00 
  801153:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  80115a:	00 
  80115b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801162:	00 
  801163:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  80116a:	e8 75 f1 ff ff       	call   8002e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80116f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801172:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801175:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801178:	89 ec                	mov    %ebp,%esp
  80117a:	5d                   	pop    %ebp
  80117b:	c3                   	ret    
  80117c:	00 00                	add    %al,(%eax)
	...

00801180 <__udivdi3>:
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	57                   	push   %edi
  801184:	56                   	push   %esi
  801185:	83 ec 10             	sub    $0x10,%esp
  801188:	8b 75 14             	mov    0x14(%ebp),%esi
  80118b:	8b 45 08             	mov    0x8(%ebp),%eax
  80118e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801191:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801194:	85 f6                	test   %esi,%esi
  801196:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801199:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80119c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80119f:	75 2f                	jne    8011d0 <__udivdi3+0x50>
  8011a1:	39 f9                	cmp    %edi,%ecx
  8011a3:	77 5b                	ja     801200 <__udivdi3+0x80>
  8011a5:	85 c9                	test   %ecx,%ecx
  8011a7:	75 0b                	jne    8011b4 <__udivdi3+0x34>
  8011a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ae:	31 d2                	xor    %edx,%edx
  8011b0:	f7 f1                	div    %ecx
  8011b2:	89 c1                	mov    %eax,%ecx
  8011b4:	89 f8                	mov    %edi,%eax
  8011b6:	31 d2                	xor    %edx,%edx
  8011b8:	f7 f1                	div    %ecx
  8011ba:	89 c7                	mov    %eax,%edi
  8011bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011bf:	f7 f1                	div    %ecx
  8011c1:	89 fa                	mov    %edi,%edx
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	5e                   	pop    %esi
  8011c7:	5f                   	pop    %edi
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    
  8011ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011d0:	31 d2                	xor    %edx,%edx
  8011d2:	31 c0                	xor    %eax,%eax
  8011d4:	39 fe                	cmp    %edi,%esi
  8011d6:	77 eb                	ja     8011c3 <__udivdi3+0x43>
  8011d8:	0f bd d6             	bsr    %esi,%edx
  8011db:	83 f2 1f             	xor    $0x1f,%edx
  8011de:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011e1:	75 2d                	jne    801210 <__udivdi3+0x90>
  8011e3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  8011e6:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  8011e9:	76 06                	jbe    8011f1 <__udivdi3+0x71>
  8011eb:	39 fe                	cmp    %edi,%esi
  8011ed:	89 c2                	mov    %eax,%edx
  8011ef:	73 d2                	jae    8011c3 <__udivdi3+0x43>
  8011f1:	31 d2                	xor    %edx,%edx
  8011f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f8:	eb c9                	jmp    8011c3 <__udivdi3+0x43>
  8011fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801200:	89 fa                	mov    %edi,%edx
  801202:	f7 f1                	div    %ecx
  801204:	31 d2                	xor    %edx,%edx
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	5e                   	pop    %esi
  80120a:	5f                   	pop    %edi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    
  80120d:	8d 76 00             	lea    0x0(%esi),%esi
  801210:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801214:	b8 20 00 00 00       	mov    $0x20,%eax
  801219:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80121c:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80121f:	d3 e6                	shl    %cl,%esi
  801221:	89 c1                	mov    %eax,%ecx
  801223:	d3 ea                	shr    %cl,%edx
  801225:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801229:	09 f2                	or     %esi,%edx
  80122b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  80122e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801231:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801234:	d3 e2                	shl    %cl,%edx
  801236:	89 c1                	mov    %eax,%ecx
  801238:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80123b:	89 fa                	mov    %edi,%edx
  80123d:	d3 ea                	shr    %cl,%edx
  80123f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801243:	d3 e7                	shl    %cl,%edi
  801245:	89 c1                	mov    %eax,%ecx
  801247:	d3 ee                	shr    %cl,%esi
  801249:	09 fe                	or     %edi,%esi
  80124b:	89 f0                	mov    %esi,%eax
  80124d:	f7 75 e8             	divl   -0x18(%ebp)
  801250:	89 d7                	mov    %edx,%edi
  801252:	89 c6                	mov    %eax,%esi
  801254:	f7 65 f0             	mull   -0x10(%ebp)
  801257:	39 d7                	cmp    %edx,%edi
  801259:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80125c:	72 22                	jb     801280 <__udivdi3+0x100>
  80125e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801261:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801265:	d3 e2                	shl    %cl,%edx
  801267:	39 c2                	cmp    %eax,%edx
  801269:	73 05                	jae    801270 <__udivdi3+0xf0>
  80126b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80126e:	74 10                	je     801280 <__udivdi3+0x100>
  801270:	89 f0                	mov    %esi,%eax
  801272:	31 d2                	xor    %edx,%edx
  801274:	e9 4a ff ff ff       	jmp    8011c3 <__udivdi3+0x43>
  801279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801280:	8d 46 ff             	lea    -0x1(%esi),%eax
  801283:	31 d2                	xor    %edx,%edx
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	5e                   	pop    %esi
  801289:	5f                   	pop    %edi
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    
  80128c:	00 00                	add    %al,(%eax)
	...

00801290 <__umoddi3>:
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	57                   	push   %edi
  801294:	56                   	push   %esi
  801295:	83 ec 20             	sub    $0x20,%esp
  801298:	8b 7d 14             	mov    0x14(%ebp),%edi
  80129b:	8b 45 08             	mov    0x8(%ebp),%eax
  80129e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012a4:	85 ff                	test   %edi,%edi
  8012a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8012a9:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8012ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8012af:	89 f2                	mov    %esi,%edx
  8012b1:	75 15                	jne    8012c8 <__umoddi3+0x38>
  8012b3:	39 f1                	cmp    %esi,%ecx
  8012b5:	76 41                	jbe    8012f8 <__umoddi3+0x68>
  8012b7:	f7 f1                	div    %ecx
  8012b9:	89 d0                	mov    %edx,%eax
  8012bb:	31 d2                	xor    %edx,%edx
  8012bd:	83 c4 20             	add    $0x20,%esp
  8012c0:	5e                   	pop    %esi
  8012c1:	5f                   	pop    %edi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	39 f7                	cmp    %esi,%edi
  8012ca:	77 4c                	ja     801318 <__umoddi3+0x88>
  8012cc:	0f bd c7             	bsr    %edi,%eax
  8012cf:	83 f0 1f             	xor    $0x1f,%eax
  8012d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8012d5:	75 51                	jne    801328 <__umoddi3+0x98>
  8012d7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8012da:	0f 87 e8 00 00 00    	ja     8013c8 <__umoddi3+0x138>
  8012e0:	89 f2                	mov    %esi,%edx
  8012e2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012e5:	29 ce                	sub    %ecx,%esi
  8012e7:	19 fa                	sbb    %edi,%edx
  8012e9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8012ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ef:	83 c4 20             	add    $0x20,%esp
  8012f2:	5e                   	pop    %esi
  8012f3:	5f                   	pop    %edi
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    
  8012f6:	66 90                	xchg   %ax,%ax
  8012f8:	85 c9                	test   %ecx,%ecx
  8012fa:	75 0b                	jne    801307 <__umoddi3+0x77>
  8012fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801301:	31 d2                	xor    %edx,%edx
  801303:	f7 f1                	div    %ecx
  801305:	89 c1                	mov    %eax,%ecx
  801307:	89 f0                	mov    %esi,%eax
  801309:	31 d2                	xor    %edx,%edx
  80130b:	f7 f1                	div    %ecx
  80130d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801310:	eb a5                	jmp    8012b7 <__umoddi3+0x27>
  801312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801318:	89 f2                	mov    %esi,%edx
  80131a:	83 c4 20             	add    $0x20,%esp
  80131d:	5e                   	pop    %esi
  80131e:	5f                   	pop    %edi
  80131f:	5d                   	pop    %ebp
  801320:	c3                   	ret    
  801321:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801328:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80132c:	89 f2                	mov    %esi,%edx
  80132e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801331:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801338:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80133b:	d3 e7                	shl    %cl,%edi
  80133d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801340:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801344:	d3 e8                	shr    %cl,%eax
  801346:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80134a:	09 f8                	or     %edi,%eax
  80134c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80134f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801352:	d3 e0                	shl    %cl,%eax
  801354:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801358:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80135b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80135e:	d3 ea                	shr    %cl,%edx
  801360:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801364:	d3 e6                	shl    %cl,%esi
  801366:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80136a:	d3 e8                	shr    %cl,%eax
  80136c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801370:	09 f0                	or     %esi,%eax
  801372:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801375:	f7 75 e4             	divl   -0x1c(%ebp)
  801378:	d3 e6                	shl    %cl,%esi
  80137a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80137d:	89 d6                	mov    %edx,%esi
  80137f:	f7 65 f4             	mull   -0xc(%ebp)
  801382:	89 d7                	mov    %edx,%edi
  801384:	89 c2                	mov    %eax,%edx
  801386:	39 fe                	cmp    %edi,%esi
  801388:	89 f9                	mov    %edi,%ecx
  80138a:	72 30                	jb     8013bc <__umoddi3+0x12c>
  80138c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80138f:	72 27                	jb     8013b8 <__umoddi3+0x128>
  801391:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801394:	29 d0                	sub    %edx,%eax
  801396:	19 ce                	sbb    %ecx,%esi
  801398:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80139c:	89 f2                	mov    %esi,%edx
  80139e:	d3 e8                	shr    %cl,%eax
  8013a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013a4:	d3 e2                	shl    %cl,%edx
  8013a6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013aa:	09 d0                	or     %edx,%eax
  8013ac:	89 f2                	mov    %esi,%edx
  8013ae:	d3 ea                	shr    %cl,%edx
  8013b0:	83 c4 20             	add    $0x20,%esp
  8013b3:	5e                   	pop    %esi
  8013b4:	5f                   	pop    %edi
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    
  8013b7:	90                   	nop
  8013b8:	39 fe                	cmp    %edi,%esi
  8013ba:	75 d5                	jne    801391 <__umoddi3+0x101>
  8013bc:	89 f9                	mov    %edi,%ecx
  8013be:	89 c2                	mov    %eax,%edx
  8013c0:	2b 55 f4             	sub    -0xc(%ebp),%edx
  8013c3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8013c6:	eb c9                	jmp    801391 <__umoddi3+0x101>
  8013c8:	39 f7                	cmp    %esi,%edi
  8013ca:	0f 82 10 ff ff ff    	jb     8012e0 <__umoddi3+0x50>
  8013d0:	e9 17 ff ff ff       	jmp    8012ec <__umoddi3+0x5c>
