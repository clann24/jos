
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 b2 01 00 00       	call   800208 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 17 03 00 00       	call   800381 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 75 08             	mov    0x8(%ebp),%esi
  800087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80008a:	e8 11 01 00 00       	call   8001a0 <sys_getenvid>
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009c:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a1:	85 f6                	test   %esi,%esi
  8000a3:	7e 07                	jle    8000ac <libmain+0x34>
		binaryname = argv[0];
  8000a5:	8b 03                	mov    (%ebx),%eax
  8000a7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b0:	89 34 24             	mov    %esi,(%esp)
  8000b3:	e8 7c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 0b 00 00 00       	call   8000c8 <exit>
}
  8000bd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000c0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c3:	89 ec                	mov    %ebp,%esp
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    
	...

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d5:	e8 69 00 00 00       	call   800143 <sys_env_destroy>
}
  8000da:	c9                   	leave  
  8000db:	c3                   	ret    

008000dc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 0c             	sub    $0xc,%esp
  8000e2:	89 1c 24             	mov    %ebx,(%esp)
  8000e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000e9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f8:	89 c3                	mov    %eax,%ebx
  8000fa:	89 c7                	mov    %eax,%edi
  8000fc:	89 c6                	mov    %eax,%esi
  8000fe:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800100:	8b 1c 24             	mov    (%esp),%ebx
  800103:	8b 74 24 04          	mov    0x4(%esp),%esi
  800107:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80010b:	89 ec                	mov    %ebp,%esp
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_cgetc>:

int
sys_cgetc(void)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	83 ec 0c             	sub    $0xc,%esp
  800115:	89 1c 24             	mov    %ebx,(%esp)
  800118:	89 74 24 04          	mov    %esi,0x4(%esp)
  80011c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800120:	ba 00 00 00 00       	mov    $0x0,%edx
  800125:	b8 01 00 00 00       	mov    $0x1,%eax
  80012a:	89 d1                	mov    %edx,%ecx
  80012c:	89 d3                	mov    %edx,%ebx
  80012e:	89 d7                	mov    %edx,%edi
  800130:	89 d6                	mov    %edx,%esi
  800132:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800134:	8b 1c 24             	mov    (%esp),%ebx
  800137:	8b 74 24 04          	mov    0x4(%esp),%esi
  80013b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80013f:	89 ec                	mov    %ebp,%esp
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 38             	sub    $0x38,%esp
  800149:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80014c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80014f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800152:	b9 00 00 00 00       	mov    $0x0,%ecx
  800157:	b8 03 00 00 00       	mov    $0x3,%eax
  80015c:	8b 55 08             	mov    0x8(%ebp),%edx
  80015f:	89 cb                	mov    %ecx,%ebx
  800161:	89 cf                	mov    %ecx,%edi
  800163:	89 ce                	mov    %ecx,%esi
  800165:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800167:	85 c0                	test   %eax,%eax
  800169:	7e 28                	jle    800193 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80016b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80016f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800176:	00 
  800177:	c7 44 24 08 ea 11 80 	movl   $0x8011ea,0x8(%esp)
  80017e:	00 
  80017f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800186:	00 
  800187:	c7 04 24 07 12 80 00 	movl   $0x801207,(%esp)
  80018e:	e8 e1 02 00 00       	call   800474 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800193:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800196:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800199:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80019c:	89 ec                	mov    %ebp,%esp
  80019e:	5d                   	pop    %ebp
  80019f:	c3                   	ret    

008001a0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	89 1c 24             	mov    %ebx,(%esp)
  8001a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001ad:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b6:	b8 02 00 00 00       	mov    $0x2,%eax
  8001bb:	89 d1                	mov    %edx,%ecx
  8001bd:	89 d3                	mov    %edx,%ebx
  8001bf:	89 d7                	mov    %edx,%edi
  8001c1:	89 d6                	mov    %edx,%esi
  8001c3:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  8001c5:	8b 1c 24             	mov    (%esp),%ebx
  8001c8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001cc:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001d0:	89 ec                	mov    %ebp,%esp
  8001d2:	5d                   	pop    %ebp
  8001d3:	c3                   	ret    

008001d4 <sys_yield>:

void
sys_yield(void)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	89 1c 24             	mov    %ebx,(%esp)
  8001dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001e1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001ef:	89 d1                	mov    %edx,%ecx
  8001f1:	89 d3                	mov    %edx,%ebx
  8001f3:	89 d7                	mov    %edx,%edi
  8001f5:	89 d6                	mov    %edx,%esi
  8001f7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001f9:	8b 1c 24             	mov    (%esp),%ebx
  8001fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800200:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800204:	89 ec                	mov    %ebp,%esp
  800206:	5d                   	pop    %ebp
  800207:	c3                   	ret    

00800208 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 38             	sub    $0x38,%esp
  80020e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800211:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800214:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800217:	be 00 00 00 00       	mov    $0x0,%esi
  80021c:	b8 04 00 00 00       	mov    $0x4,%eax
  800221:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800224:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800227:	8b 55 08             	mov    0x8(%ebp),%edx
  80022a:	89 f7                	mov    %esi,%edi
  80022c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80022e:	85 c0                	test   %eax,%eax
  800230:	7e 28                	jle    80025a <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800232:	89 44 24 10          	mov    %eax,0x10(%esp)
  800236:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80023d:	00 
  80023e:	c7 44 24 08 ea 11 80 	movl   $0x8011ea,0x8(%esp)
  800245:	00 
  800246:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80024d:	00 
  80024e:	c7 04 24 07 12 80 00 	movl   $0x801207,(%esp)
  800255:	e8 1a 02 00 00       	call   800474 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80025a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80025d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800260:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800263:	89 ec                	mov    %ebp,%esp
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	83 ec 38             	sub    $0x38,%esp
  80026d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800270:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800273:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800276:	b8 05 00 00 00       	mov    $0x5,%eax
  80027b:	8b 75 18             	mov    0x18(%ebp),%esi
  80027e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800281:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028c:	85 c0                	test   %eax,%eax
  80028e:	7e 28                	jle    8002b8 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800290:	89 44 24 10          	mov    %eax,0x10(%esp)
  800294:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80029b:	00 
  80029c:	c7 44 24 08 ea 11 80 	movl   $0x8011ea,0x8(%esp)
  8002a3:	00 
  8002a4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ab:	00 
  8002ac:	c7 04 24 07 12 80 00 	movl   $0x801207,(%esp)
  8002b3:	e8 bc 01 00 00       	call   800474 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002b8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002bb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002be:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002c1:	89 ec                	mov    %ebp,%esp
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	83 ec 38             	sub    $0x38,%esp
  8002cb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002ce:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002d1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d9:	b8 06 00 00 00       	mov    $0x6,%eax
  8002de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e4:	89 df                	mov    %ebx,%edi
  8002e6:	89 de                	mov    %ebx,%esi
  8002e8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	7e 28                	jle    800316 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002f9:	00 
  8002fa:	c7 44 24 08 ea 11 80 	movl   $0x8011ea,0x8(%esp)
  800301:	00 
  800302:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800309:	00 
  80030a:	c7 04 24 07 12 80 00 	movl   $0x801207,(%esp)
  800311:	e8 5e 01 00 00       	call   800474 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800316:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800319:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80031c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80031f:	89 ec                	mov    %ebp,%esp
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	83 ec 38             	sub    $0x38,%esp
  800329:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80032c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80032f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800332:	bb 00 00 00 00       	mov    $0x0,%ebx
  800337:	b8 08 00 00 00       	mov    $0x8,%eax
  80033c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033f:	8b 55 08             	mov    0x8(%ebp),%edx
  800342:	89 df                	mov    %ebx,%edi
  800344:	89 de                	mov    %ebx,%esi
  800346:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800348:	85 c0                	test   %eax,%eax
  80034a:	7e 28                	jle    800374 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800350:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800357:	00 
  800358:	c7 44 24 08 ea 11 80 	movl   $0x8011ea,0x8(%esp)
  80035f:	00 
  800360:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800367:	00 
  800368:	c7 04 24 07 12 80 00 	movl   $0x801207,(%esp)
  80036f:	e8 00 01 00 00       	call   800474 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800374:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800377:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80037a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80037d:	89 ec                	mov    %ebp,%esp
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	83 ec 38             	sub    $0x38,%esp
  800387:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80038a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80038d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800390:	bb 00 00 00 00       	mov    $0x0,%ebx
  800395:	b8 09 00 00 00       	mov    $0x9,%eax
  80039a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80039d:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a0:	89 df                	mov    %ebx,%edi
  8003a2:	89 de                	mov    %ebx,%esi
  8003a4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	7e 28                	jle    8003d2 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003ae:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8003b5:	00 
  8003b6:	c7 44 24 08 ea 11 80 	movl   $0x8011ea,0x8(%esp)
  8003bd:	00 
  8003be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003c5:	00 
  8003c6:	c7 04 24 07 12 80 00 	movl   $0x801207,(%esp)
  8003cd:	e8 a2 00 00 00       	call   800474 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003d2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003d5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003db:	89 ec                	mov    %ebp,%esp
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	83 ec 0c             	sub    $0xc,%esp
  8003e5:	89 1c 24             	mov    %ebx,(%esp)
  8003e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003ec:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003f0:	be 00 00 00 00       	mov    $0x0,%esi
  8003f5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003fa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800400:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800403:	8b 55 08             	mov    0x8(%ebp),%edx
  800406:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800408:	8b 1c 24             	mov    (%esp),%ebx
  80040b:	8b 74 24 04          	mov    0x4(%esp),%esi
  80040f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800413:	89 ec                	mov    %ebp,%esp
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 38             	sub    $0x38,%esp
  80041d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800420:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800423:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800426:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800430:	8b 55 08             	mov    0x8(%ebp),%edx
  800433:	89 cb                	mov    %ecx,%ebx
  800435:	89 cf                	mov    %ecx,%edi
  800437:	89 ce                	mov    %ecx,%esi
  800439:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80043b:	85 c0                	test   %eax,%eax
  80043d:	7e 28                	jle    800467 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80043f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800443:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80044a:	00 
  80044b:	c7 44 24 08 ea 11 80 	movl   $0x8011ea,0x8(%esp)
  800452:	00 
  800453:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80045a:	00 
  80045b:	c7 04 24 07 12 80 00 	movl   $0x801207,(%esp)
  800462:	e8 0d 00 00 00       	call   800474 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800467:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80046a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80046d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800470:	89 ec                	mov    %ebp,%esp
  800472:	5d                   	pop    %ebp
  800473:	c3                   	ret    

00800474 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800474:	55                   	push   %ebp
  800475:	89 e5                	mov    %esp,%ebp
  800477:	56                   	push   %esi
  800478:	53                   	push   %ebx
  800479:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80047c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80047f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800485:	e8 16 fd ff ff       	call   8001a0 <sys_getenvid>
  80048a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800491:	8b 55 08             	mov    0x8(%ebp),%edx
  800494:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800498:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80049c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a0:	c7 04 24 18 12 80 00 	movl   $0x801218,(%esp)
  8004a7:	e8 c3 00 00 00       	call   80056f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b3:	89 04 24             	mov    %eax,(%esp)
  8004b6:	e8 53 00 00 00       	call   80050e <vcprintf>
	cprintf("\n");
  8004bb:	c7 04 24 3c 12 80 00 	movl   $0x80123c,(%esp)
  8004c2:	e8 a8 00 00 00       	call   80056f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004c7:	cc                   	int3   
  8004c8:	eb fd                	jmp    8004c7 <_panic+0x53>
	...

008004cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	53                   	push   %ebx
  8004d0:	83 ec 14             	sub    $0x14,%esp
  8004d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004d6:	8b 03                	mov    (%ebx),%eax
  8004d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004df:	83 c0 01             	add    $0x1,%eax
  8004e2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004e9:	75 19                	jne    800504 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004eb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004f2:	00 
  8004f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8004f6:	89 04 24             	mov    %eax,(%esp)
  8004f9:	e8 de fb ff ff       	call   8000dc <sys_cputs>
		b->idx = 0;
  8004fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800504:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800508:	83 c4 14             	add    $0x14,%esp
  80050b:	5b                   	pop    %ebx
  80050c:	5d                   	pop    %ebp
  80050d:	c3                   	ret    

0080050e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
  800511:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800517:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80051e:	00 00 00 
	b.cnt = 0;
  800521:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800528:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80052b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80052e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800532:	8b 45 08             	mov    0x8(%ebp),%eax
  800535:	89 44 24 08          	mov    %eax,0x8(%esp)
  800539:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80053f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800543:	c7 04 24 cc 04 80 00 	movl   $0x8004cc,(%esp)
  80054a:	e8 e2 01 00 00       	call   800731 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80054f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800555:	89 44 24 04          	mov    %eax,0x4(%esp)
  800559:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80055f:	89 04 24             	mov    %eax,(%esp)
  800562:	e8 75 fb ff ff       	call   8000dc <sys_cputs>

	return b.cnt;
}
  800567:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80056d:	c9                   	leave  
  80056e:	c3                   	ret    

0080056f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80056f:	55                   	push   %ebp
  800570:	89 e5                	mov    %esp,%ebp
  800572:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800575:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800578:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057c:	8b 45 08             	mov    0x8(%ebp),%eax
  80057f:	89 04 24             	mov    %eax,(%esp)
  800582:	e8 87 ff ff ff       	call   80050e <vcprintf>
	va_end(ap);

	return cnt;
}
  800587:	c9                   	leave  
  800588:	c3                   	ret    
  800589:	00 00                	add    %al,(%eax)
  80058b:	00 00                	add    %al,(%eax)
  80058d:	00 00                	add    %al,(%eax)
	...

00800590 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800590:	55                   	push   %ebp
  800591:	89 e5                	mov    %esp,%ebp
  800593:	57                   	push   %edi
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	83 ec 4c             	sub    $0x4c,%esp
  800599:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80059c:	89 d6                	mov    %edx,%esi
  80059e:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005ad:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b5:	39 d0                	cmp    %edx,%eax
  8005b7:	72 11                	jb     8005ca <printnum+0x3a>
  8005b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005bc:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8005bf:	76 09                	jbe    8005ca <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005c1:	83 eb 01             	sub    $0x1,%ebx
  8005c4:	85 db                	test   %ebx,%ebx
  8005c6:	7f 5d                	jg     800625 <printnum+0x95>
  8005c8:	eb 6c                	jmp    800636 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005ca:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8005ce:	83 eb 01             	sub    $0x1,%ebx
  8005d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005dc:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005e0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8005e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005f1:	00 
  8005f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005f5:	89 14 24             	mov    %edx,(%esp)
  8005f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ff:	e8 7c 09 00 00       	call   800f80 <__udivdi3>
  800604:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800607:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80060a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80060e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800612:	89 04 24             	mov    %eax,(%esp)
  800615:	89 54 24 04          	mov    %edx,0x4(%esp)
  800619:	89 f2                	mov    %esi,%edx
  80061b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80061e:	e8 6d ff ff ff       	call   800590 <printnum>
  800623:	eb 11                	jmp    800636 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800625:	89 74 24 04          	mov    %esi,0x4(%esp)
  800629:	89 3c 24             	mov    %edi,(%esp)
  80062c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80062f:	83 eb 01             	sub    $0x1,%ebx
  800632:	85 db                	test   %ebx,%ebx
  800634:	7f ef                	jg     800625 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800636:	89 74 24 04          	mov    %esi,0x4(%esp)
  80063a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80063e:	8b 45 10             	mov    0x10(%ebp),%eax
  800641:	89 44 24 08          	mov    %eax,0x8(%esp)
  800645:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80064c:	00 
  80064d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800650:	89 14 24             	mov    %edx,(%esp)
  800653:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800656:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80065a:	e8 31 0a 00 00       	call   801090 <__umoddi3>
  80065f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800663:	0f be 80 3e 12 80 00 	movsbl 0x80123e(%eax),%eax
  80066a:	89 04 24             	mov    %eax,(%esp)
  80066d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800670:	83 c4 4c             	add    $0x4c,%esp
  800673:	5b                   	pop    %ebx
  800674:	5e                   	pop    %esi
  800675:	5f                   	pop    %edi
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80067b:	83 fa 01             	cmp    $0x1,%edx
  80067e:	7e 0e                	jle    80068e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800680:	8b 10                	mov    (%eax),%edx
  800682:	8d 4a 08             	lea    0x8(%edx),%ecx
  800685:	89 08                	mov    %ecx,(%eax)
  800687:	8b 02                	mov    (%edx),%eax
  800689:	8b 52 04             	mov    0x4(%edx),%edx
  80068c:	eb 22                	jmp    8006b0 <getuint+0x38>
	else if (lflag)
  80068e:	85 d2                	test   %edx,%edx
  800690:	74 10                	je     8006a2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800692:	8b 10                	mov    (%eax),%edx
  800694:	8d 4a 04             	lea    0x4(%edx),%ecx
  800697:	89 08                	mov    %ecx,(%eax)
  800699:	8b 02                	mov    (%edx),%eax
  80069b:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a0:	eb 0e                	jmp    8006b0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a7:	89 08                	mov    %ecx,(%eax)
  8006a9:	8b 02                	mov    (%edx),%eax
  8006ab:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006b5:	83 fa 01             	cmp    $0x1,%edx
  8006b8:	7e 0e                	jle    8006c8 <getint+0x16>
		return va_arg(*ap, long long);
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006bf:	89 08                	mov    %ecx,(%eax)
  8006c1:	8b 02                	mov    (%edx),%eax
  8006c3:	8b 52 04             	mov    0x4(%edx),%edx
  8006c6:	eb 22                	jmp    8006ea <getint+0x38>
	else if (lflag)
  8006c8:	85 d2                	test   %edx,%edx
  8006ca:	74 10                	je     8006dc <getint+0x2a>
		return va_arg(*ap, long);
  8006cc:	8b 10                	mov    (%eax),%edx
  8006ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006d1:	89 08                	mov    %ecx,(%eax)
  8006d3:	8b 02                	mov    (%edx),%eax
  8006d5:	89 c2                	mov    %eax,%edx
  8006d7:	c1 fa 1f             	sar    $0x1f,%edx
  8006da:	eb 0e                	jmp    8006ea <getint+0x38>
	else
		return va_arg(*ap, int);
  8006dc:	8b 10                	mov    (%eax),%edx
  8006de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006e1:	89 08                	mov    %ecx,(%eax)
  8006e3:	8b 02                	mov    (%edx),%eax
  8006e5:	89 c2                	mov    %eax,%edx
  8006e7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8006ea:	5d                   	pop    %ebp
  8006eb:	c3                   	ret    

008006ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006f2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006f6:	8b 10                	mov    (%eax),%edx
  8006f8:	3b 50 04             	cmp    0x4(%eax),%edx
  8006fb:	73 0a                	jae    800707 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800700:	88 0a                	mov    %cl,(%edx)
  800702:	83 c2 01             	add    $0x1,%edx
  800705:	89 10                	mov    %edx,(%eax)
}
  800707:	5d                   	pop    %ebp
  800708:	c3                   	ret    

00800709 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80070f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800712:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800716:	8b 45 10             	mov    0x10(%ebp),%eax
  800719:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800720:	89 44 24 04          	mov    %eax,0x4(%esp)
  800724:	8b 45 08             	mov    0x8(%ebp),%eax
  800727:	89 04 24             	mov    %eax,(%esp)
  80072a:	e8 02 00 00 00       	call   800731 <vprintfmt>
	va_end(ap);
}
  80072f:	c9                   	leave  
  800730:	c3                   	ret    

00800731 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	57                   	push   %edi
  800735:	56                   	push   %esi
  800736:	53                   	push   %ebx
  800737:	83 ec 4c             	sub    $0x4c,%esp
  80073a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80073d:	eb 23                	jmp    800762 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80073f:	85 c0                	test   %eax,%eax
  800741:	75 12                	jne    800755 <vprintfmt+0x24>
				csa = 0x0700;
  800743:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80074a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80074d:	83 c4 4c             	add    $0x4c,%esp
  800750:	5b                   	pop    %ebx
  800751:	5e                   	pop    %esi
  800752:	5f                   	pop    %edi
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800755:	8b 55 0c             	mov    0xc(%ebp),%edx
  800758:	89 54 24 04          	mov    %edx,0x4(%esp)
  80075c:	89 04 24             	mov    %eax,(%esp)
  80075f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800762:	0f b6 07             	movzbl (%edi),%eax
  800765:	83 c7 01             	add    $0x1,%edi
  800768:	83 f8 25             	cmp    $0x25,%eax
  80076b:	75 d2                	jne    80073f <vprintfmt+0xe>
  80076d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800771:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800778:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80077d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800784:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800789:	be 00 00 00 00       	mov    $0x0,%esi
  80078e:	eb 14                	jmp    8007a4 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800790:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800794:	eb 0e                	jmp    8007a4 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800796:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80079a:	eb 08                	jmp    8007a4 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80079c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80079f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a4:	0f b6 07             	movzbl (%edi),%eax
  8007a7:	0f b6 c8             	movzbl %al,%ecx
  8007aa:	83 c7 01             	add    $0x1,%edi
  8007ad:	83 e8 23             	sub    $0x23,%eax
  8007b0:	3c 55                	cmp    $0x55,%al
  8007b2:	0f 87 ed 02 00 00    	ja     800aa5 <vprintfmt+0x374>
  8007b8:	0f b6 c0             	movzbl %al,%eax
  8007bb:	ff 24 85 00 13 80 00 	jmp    *0x801300(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007c2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  8007c5:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8007c8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007cb:	83 f9 09             	cmp    $0x9,%ecx
  8007ce:	77 3c                	ja     80080c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007d0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8007d3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8007d6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8007da:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8007dd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007e0:	83 f9 09             	cmp    $0x9,%ecx
  8007e3:	76 eb                	jbe    8007d0 <vprintfmt+0x9f>
  8007e5:	eb 25                	jmp    80080c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	8d 48 04             	lea    0x4(%eax),%ecx
  8007ed:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007f0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  8007f2:	eb 18                	jmp    80080c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  8007f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007fb:	0f 48 c6             	cmovs  %esi,%eax
  8007fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800801:	eb a1                	jmp    8007a4 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  800803:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80080a:	eb 98                	jmp    8007a4 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  80080c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800810:	79 92                	jns    8007a4 <vprintfmt+0x73>
  800812:	eb 88                	jmp    80079c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800814:	83 c2 01             	add    $0x1,%edx
  800817:	eb 8b                	jmp    8007a4 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800819:	8b 45 14             	mov    0x14(%ebp),%eax
  80081c:	8d 50 04             	lea    0x4(%eax),%edx
  80081f:	89 55 14             	mov    %edx,0x14(%ebp)
  800822:	8b 55 0c             	mov    0xc(%ebp),%edx
  800825:	89 54 24 04          	mov    %edx,0x4(%esp)
  800829:	8b 00                	mov    (%eax),%eax
  80082b:	89 04 24             	mov    %eax,(%esp)
  80082e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800831:	e9 2c ff ff ff       	jmp    800762 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800836:	8b 45 14             	mov    0x14(%ebp),%eax
  800839:	8d 50 04             	lea    0x4(%eax),%edx
  80083c:	89 55 14             	mov    %edx,0x14(%ebp)
  80083f:	8b 00                	mov    (%eax),%eax
  800841:	89 c2                	mov    %eax,%edx
  800843:	c1 fa 1f             	sar    $0x1f,%edx
  800846:	31 d0                	xor    %edx,%eax
  800848:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80084a:	83 f8 08             	cmp    $0x8,%eax
  80084d:	7f 0b                	jg     80085a <vprintfmt+0x129>
  80084f:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  800856:	85 d2                	test   %edx,%edx
  800858:	75 23                	jne    80087d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80085a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085e:	c7 44 24 08 56 12 80 	movl   $0x801256,0x8(%esp)
  800865:	00 
  800866:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800869:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	89 04 24             	mov    %eax,(%esp)
  800873:	e8 91 fe ff ff       	call   800709 <printfmt>
  800878:	e9 e5 fe ff ff       	jmp    800762 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80087d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800881:	c7 44 24 08 5f 12 80 	movl   $0x80125f,0x8(%esp)
  800888:	00 
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800890:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800893:	89 1c 24             	mov    %ebx,(%esp)
  800896:	e8 6e fe ff ff       	call   800709 <printfmt>
  80089b:	e9 c2 fe ff ff       	jmp    800762 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ac:	8d 50 04             	lea    0x4(%eax),%edx
  8008af:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b2:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8008b4:	85 f6                	test   %esi,%esi
  8008b6:	ba 4f 12 80 00       	mov    $0x80124f,%edx
  8008bb:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8008be:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008c2:	7e 06                	jle    8008ca <vprintfmt+0x199>
  8008c4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8008c8:	75 13                	jne    8008dd <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008ca:	0f be 06             	movsbl (%esi),%eax
  8008cd:	83 c6 01             	add    $0x1,%esi
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	0f 85 a2 00 00 00    	jne    80097a <vprintfmt+0x249>
  8008d8:	e9 92 00 00 00       	jmp    80096f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e1:	89 34 24             	mov    %esi,(%esp)
  8008e4:	e8 82 02 00 00       	call   800b6b <strnlen>
  8008e9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008ec:	29 c2                	sub    %eax,%edx
  8008ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008f1:	85 d2                	test   %edx,%edx
  8008f3:	7e d5                	jle    8008ca <vprintfmt+0x199>
					putch(padc, putdat);
  8008f5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8008f9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008fc:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8008ff:	89 d3                	mov    %edx,%ebx
  800901:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800904:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800907:	89 c6                	mov    %eax,%esi
  800909:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80090d:	89 34 24             	mov    %esi,(%esp)
  800910:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800913:	83 eb 01             	sub    $0x1,%ebx
  800916:	85 db                	test   %ebx,%ebx
  800918:	7f ef                	jg     800909 <vprintfmt+0x1d8>
  80091a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80091d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800920:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800923:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80092a:	eb 9e                	jmp    8008ca <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80092c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800930:	74 1b                	je     80094d <vprintfmt+0x21c>
  800932:	8d 50 e0             	lea    -0x20(%eax),%edx
  800935:	83 fa 5e             	cmp    $0x5e,%edx
  800938:	76 13                	jbe    80094d <vprintfmt+0x21c>
					putch('?', putdat);
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800941:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800948:	ff 55 08             	call   *0x8(%ebp)
  80094b:	eb 0d                	jmp    80095a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800950:	89 54 24 04          	mov    %edx,0x4(%esp)
  800954:	89 04 24             	mov    %eax,(%esp)
  800957:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80095a:	83 ef 01             	sub    $0x1,%edi
  80095d:	0f be 06             	movsbl (%esi),%eax
  800960:	85 c0                	test   %eax,%eax
  800962:	74 05                	je     800969 <vprintfmt+0x238>
  800964:	83 c6 01             	add    $0x1,%esi
  800967:	eb 17                	jmp    800980 <vprintfmt+0x24f>
  800969:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80096c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80096f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800973:	7f 1c                	jg     800991 <vprintfmt+0x260>
  800975:	e9 e8 fd ff ff       	jmp    800762 <vprintfmt+0x31>
  80097a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80097d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800980:	85 db                	test   %ebx,%ebx
  800982:	78 a8                	js     80092c <vprintfmt+0x1fb>
  800984:	83 eb 01             	sub    $0x1,%ebx
  800987:	79 a3                	jns    80092c <vprintfmt+0x1fb>
  800989:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80098c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80098f:	eb de                	jmp    80096f <vprintfmt+0x23e>
  800991:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800994:	8b 7d 08             	mov    0x8(%ebp),%edi
  800997:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80099a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80099e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009a5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009a7:	83 eb 01             	sub    $0x1,%ebx
  8009aa:	85 db                	test   %ebx,%ebx
  8009ac:	7f ec                	jg     80099a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ae:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009b1:	e9 ac fd ff ff       	jmp    800762 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8009b9:	e8 f4 fc ff ff       	call   8006b2 <getint>
  8009be:	89 c3                	mov    %eax,%ebx
  8009c0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8009c2:	85 d2                	test   %edx,%edx
  8009c4:	78 0a                	js     8009d0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009c6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009cb:	e9 87 00 00 00       	jmp    800a57 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8009d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009de:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009e1:	89 d8                	mov    %ebx,%eax
  8009e3:	89 f2                	mov    %esi,%edx
  8009e5:	f7 d8                	neg    %eax
  8009e7:	83 d2 00             	adc    $0x0,%edx
  8009ea:	f7 da                	neg    %edx
			}
			base = 10;
  8009ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009f1:	eb 64                	jmp    800a57 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f6:	e8 7d fc ff ff       	call   800678 <getuint>
			base = 10;
  8009fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a00:	eb 55                	jmp    800a57 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800a02:	8d 45 14             	lea    0x14(%ebp),%eax
  800a05:	e8 6e fc ff ff       	call   800678 <getuint>
      base = 8;
  800a0a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800a0f:	eb 46                	jmp    800a57 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800a11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a14:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a18:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a1f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a25:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a29:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a30:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a33:	8b 45 14             	mov    0x14(%ebp),%eax
  800a36:	8d 50 04             	lea    0x4(%eax),%edx
  800a39:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a3c:	8b 00                	mov    (%eax),%eax
  800a3e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a43:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a48:	eb 0d                	jmp    800a57 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a4a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a4d:	e8 26 fc ff ff       	call   800678 <getuint>
			base = 16;
  800a52:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a57:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800a5b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800a5f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a62:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a66:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a6a:	89 04 24             	mov    %eax,(%esp)
  800a6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a71:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	e8 14 fb ff ff       	call   800590 <printnum>
			break;
  800a7c:	e9 e1 fc ff ff       	jmp    800762 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a88:	89 0c 24             	mov    %ecx,(%esp)
  800a8b:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a8e:	e9 cf fc ff ff       	jmp    800762 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800a93:	8d 45 14             	lea    0x14(%ebp),%eax
  800a96:	e8 17 fc ff ff       	call   8006b2 <getint>
			csa = num;
  800a9b:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  800aa0:	e9 bd fc ff ff       	jmp    800762 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aac:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ab3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ab6:	83 ef 01             	sub    $0x1,%edi
  800ab9:	eb 02                	jmp    800abd <vprintfmt+0x38c>
  800abb:	89 c7                	mov    %eax,%edi
  800abd:	8d 47 ff             	lea    -0x1(%edi),%eax
  800ac0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ac4:	75 f5                	jne    800abb <vprintfmt+0x38a>
  800ac6:	e9 97 fc ff ff       	jmp    800762 <vprintfmt+0x31>

00800acb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	83 ec 28             	sub    $0x28,%esp
  800ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ad7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ada:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ade:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ae1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ae8:	85 c0                	test   %eax,%eax
  800aea:	74 30                	je     800b1c <vsnprintf+0x51>
  800aec:	85 d2                	test   %edx,%edx
  800aee:	7e 2c                	jle    800b1c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800af0:	8b 45 14             	mov    0x14(%ebp),%eax
  800af3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800af7:	8b 45 10             	mov    0x10(%ebp),%eax
  800afa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800afe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b01:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b05:	c7 04 24 ec 06 80 00 	movl   $0x8006ec,(%esp)
  800b0c:	e8 20 fc ff ff       	call   800731 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b11:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b14:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b1a:	eb 05                	jmp    800b21 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b21:	c9                   	leave  
  800b22:	c3                   	ret    

00800b23 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b29:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b30:	8b 45 10             	mov    0x10(%ebp),%eax
  800b33:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	89 04 24             	mov    %eax,(%esp)
  800b44:	e8 82 ff ff ff       	call   800acb <vsnprintf>
	va_end(ap);

	return rc;
}
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    
  800b4b:	00 00                	add    %al,(%eax)
  800b4d:	00 00                	add    %al,(%eax)
	...

00800b50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b5e:	74 09                	je     800b69 <strlen+0x19>
		n++;
  800b60:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b63:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b67:	75 f7                	jne    800b60 <strlen+0x10>
		n++;
	return n;
}
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b71:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
  800b79:	85 d2                	test   %edx,%edx
  800b7b:	74 12                	je     800b8f <strnlen+0x24>
  800b7d:	80 39 00             	cmpb   $0x0,(%ecx)
  800b80:	74 0d                	je     800b8f <strnlen+0x24>
		n++;
  800b82:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b85:	39 d0                	cmp    %edx,%eax
  800b87:	74 06                	je     800b8f <strnlen+0x24>
  800b89:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b8d:	75 f3                	jne    800b82 <strnlen+0x17>
		n++;
	return n;
}
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	53                   	push   %ebx
  800b95:	8b 45 08             	mov    0x8(%ebp),%eax
  800b98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800ba4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ba7:	83 c2 01             	add    $0x1,%edx
  800baa:	84 c9                	test   %cl,%cl
  800bac:	75 f2                	jne    800ba0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bae:	5b                   	pop    %ebx
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 08             	sub    $0x8,%esp
  800bb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bbb:	89 1c 24             	mov    %ebx,(%esp)
  800bbe:	e8 8d ff ff ff       	call   800b50 <strlen>
	strcpy(dst + len, src);
  800bc3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc6:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bca:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bcd:	89 04 24             	mov    %eax,(%esp)
  800bd0:	e8 bc ff ff ff       	call   800b91 <strcpy>
	return dst;
}
  800bd5:	89 d8                	mov    %ebx,%eax
  800bd7:	83 c4 08             	add    $0x8,%esp
  800bda:	5b                   	pop    %ebx
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
  800be5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800beb:	85 f6                	test   %esi,%esi
  800bed:	74 18                	je     800c07 <strncpy+0x2a>
  800bef:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bf4:	0f b6 1a             	movzbl (%edx),%ebx
  800bf7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bfa:	80 3a 01             	cmpb   $0x1,(%edx)
  800bfd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c00:	83 c1 01             	add    $0x1,%ecx
  800c03:	39 ce                	cmp    %ecx,%esi
  800c05:	77 ed                	ja     800bf4 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	8b 75 08             	mov    0x8(%ebp),%esi
  800c13:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c16:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c19:	89 f0                	mov    %esi,%eax
  800c1b:	85 c9                	test   %ecx,%ecx
  800c1d:	74 23                	je     800c42 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  800c1f:	83 e9 01             	sub    $0x1,%ecx
  800c22:	74 1b                	je     800c3f <strlcpy+0x34>
  800c24:	0f b6 1a             	movzbl (%edx),%ebx
  800c27:	84 db                	test   %bl,%bl
  800c29:	74 14                	je     800c3f <strlcpy+0x34>
			*dst++ = *src++;
  800c2b:	88 18                	mov    %bl,(%eax)
  800c2d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c30:	83 e9 01             	sub    $0x1,%ecx
  800c33:	74 0a                	je     800c3f <strlcpy+0x34>
			*dst++ = *src++;
  800c35:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c38:	0f b6 1a             	movzbl (%edx),%ebx
  800c3b:	84 db                	test   %bl,%bl
  800c3d:	75 ec                	jne    800c2b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  800c3f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c42:	29 f0                	sub    %esi,%eax
}
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c51:	0f b6 01             	movzbl (%ecx),%eax
  800c54:	84 c0                	test   %al,%al
  800c56:	74 15                	je     800c6d <strcmp+0x25>
  800c58:	3a 02                	cmp    (%edx),%al
  800c5a:	75 11                	jne    800c6d <strcmp+0x25>
		p++, q++;
  800c5c:	83 c1 01             	add    $0x1,%ecx
  800c5f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c62:	0f b6 01             	movzbl (%ecx),%eax
  800c65:	84 c0                	test   %al,%al
  800c67:	74 04                	je     800c6d <strcmp+0x25>
  800c69:	3a 02                	cmp    (%edx),%al
  800c6b:	74 ef                	je     800c5c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c6d:	0f b6 c0             	movzbl %al,%eax
  800c70:	0f b6 12             	movzbl (%edx),%edx
  800c73:	29 d0                	sub    %edx,%eax
}
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	53                   	push   %ebx
  800c7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c81:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c84:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c89:	85 d2                	test   %edx,%edx
  800c8b:	74 28                	je     800cb5 <strncmp+0x3e>
  800c8d:	0f b6 01             	movzbl (%ecx),%eax
  800c90:	84 c0                	test   %al,%al
  800c92:	74 24                	je     800cb8 <strncmp+0x41>
  800c94:	3a 03                	cmp    (%ebx),%al
  800c96:	75 20                	jne    800cb8 <strncmp+0x41>
  800c98:	83 ea 01             	sub    $0x1,%edx
  800c9b:	74 13                	je     800cb0 <strncmp+0x39>
		n--, p++, q++;
  800c9d:	83 c1 01             	add    $0x1,%ecx
  800ca0:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ca3:	0f b6 01             	movzbl (%ecx),%eax
  800ca6:	84 c0                	test   %al,%al
  800ca8:	74 0e                	je     800cb8 <strncmp+0x41>
  800caa:	3a 03                	cmp    (%ebx),%al
  800cac:	74 ea                	je     800c98 <strncmp+0x21>
  800cae:	eb 08                	jmp    800cb8 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cb0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb8:	0f b6 01             	movzbl (%ecx),%eax
  800cbb:	0f b6 13             	movzbl (%ebx),%edx
  800cbe:	29 d0                	sub    %edx,%eax
  800cc0:	eb f3                	jmp    800cb5 <strncmp+0x3e>

00800cc2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ccc:	0f b6 10             	movzbl (%eax),%edx
  800ccf:	84 d2                	test   %dl,%dl
  800cd1:	74 20                	je     800cf3 <strchr+0x31>
		if (*s == c)
  800cd3:	38 ca                	cmp    %cl,%dl
  800cd5:	75 0b                	jne    800ce2 <strchr+0x20>
  800cd7:	eb 1f                	jmp    800cf8 <strchr+0x36>
  800cd9:	38 ca                	cmp    %cl,%dl
  800cdb:	90                   	nop
  800cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce0:	74 16                	je     800cf8 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ce2:	83 c0 01             	add    $0x1,%eax
  800ce5:	0f b6 10             	movzbl (%eax),%edx
  800ce8:	84 d2                	test   %dl,%dl
  800cea:	75 ed                	jne    800cd9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800cec:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf1:	eb 05                	jmp    800cf8 <strchr+0x36>
  800cf3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800d00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d04:	0f b6 10             	movzbl (%eax),%edx
  800d07:	84 d2                	test   %dl,%dl
  800d09:	74 14                	je     800d1f <strfind+0x25>
		if (*s == c)
  800d0b:	38 ca                	cmp    %cl,%dl
  800d0d:	75 06                	jne    800d15 <strfind+0x1b>
  800d0f:	eb 0e                	jmp    800d1f <strfind+0x25>
  800d11:	38 ca                	cmp    %cl,%dl
  800d13:	74 0a                	je     800d1f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d15:	83 c0 01             	add    $0x1,%eax
  800d18:	0f b6 10             	movzbl (%eax),%edx
  800d1b:	84 d2                	test   %dl,%dl
  800d1d:	75 f2                	jne    800d11 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	89 1c 24             	mov    %ebx,(%esp)
  800d2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d2e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d32:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d38:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d3b:	85 c9                	test   %ecx,%ecx
  800d3d:	74 30                	je     800d6f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d3f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d45:	75 25                	jne    800d6c <memset+0x4b>
  800d47:	f6 c1 03             	test   $0x3,%cl
  800d4a:	75 20                	jne    800d6c <memset+0x4b>
		c &= 0xFF;
  800d4c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d4f:	89 d3                	mov    %edx,%ebx
  800d51:	c1 e3 08             	shl    $0x8,%ebx
  800d54:	89 d6                	mov    %edx,%esi
  800d56:	c1 e6 18             	shl    $0x18,%esi
  800d59:	89 d0                	mov    %edx,%eax
  800d5b:	c1 e0 10             	shl    $0x10,%eax
  800d5e:	09 f0                	or     %esi,%eax
  800d60:	09 d0                	or     %edx,%eax
  800d62:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d64:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d67:	fc                   	cld    
  800d68:	f3 ab                	rep stos %eax,%es:(%edi)
  800d6a:	eb 03                	jmp    800d6f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d6c:	fc                   	cld    
  800d6d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d6f:	89 f8                	mov    %edi,%eax
  800d71:	8b 1c 24             	mov    (%esp),%ebx
  800d74:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d78:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d7c:	89 ec                	mov    %ebp,%esp
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	83 ec 08             	sub    $0x8,%esp
  800d86:	89 34 24             	mov    %esi,(%esp)
  800d89:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d96:	39 c6                	cmp    %eax,%esi
  800d98:	73 36                	jae    800dd0 <memmove+0x50>
  800d9a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d9d:	39 d0                	cmp    %edx,%eax
  800d9f:	73 2f                	jae    800dd0 <memmove+0x50>
		s += n;
		d += n;
  800da1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800da4:	f6 c2 03             	test   $0x3,%dl
  800da7:	75 1b                	jne    800dc4 <memmove+0x44>
  800da9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800daf:	75 13                	jne    800dc4 <memmove+0x44>
  800db1:	f6 c1 03             	test   $0x3,%cl
  800db4:	75 0e                	jne    800dc4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800db6:	83 ef 04             	sub    $0x4,%edi
  800db9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800dbc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800dbf:	fd                   	std    
  800dc0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dc2:	eb 09                	jmp    800dcd <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800dc4:	83 ef 01             	sub    $0x1,%edi
  800dc7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dca:	fd                   	std    
  800dcb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dcd:	fc                   	cld    
  800dce:	eb 20                	jmp    800df0 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dd0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dd6:	75 13                	jne    800deb <memmove+0x6b>
  800dd8:	a8 03                	test   $0x3,%al
  800dda:	75 0f                	jne    800deb <memmove+0x6b>
  800ddc:	f6 c1 03             	test   $0x3,%cl
  800ddf:	75 0a                	jne    800deb <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800de1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800de4:	89 c7                	mov    %eax,%edi
  800de6:	fc                   	cld    
  800de7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800de9:	eb 05                	jmp    800df0 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800deb:	89 c7                	mov    %eax,%edi
  800ded:	fc                   	cld    
  800dee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800df0:	8b 34 24             	mov    (%esp),%esi
  800df3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800df7:	89 ec                	mov    %ebp,%esp
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e01:	8b 45 10             	mov    0x10(%ebp),%eax
  800e04:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	89 04 24             	mov    %eax,(%esp)
  800e15:	e8 66 ff ff ff       	call   800d80 <memmove>
}
  800e1a:	c9                   	leave  
  800e1b:	c3                   	ret    

00800e1c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
  800e22:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e28:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e2b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e30:	85 ff                	test   %edi,%edi
  800e32:	74 38                	je     800e6c <memcmp+0x50>
		if (*s1 != *s2)
  800e34:	0f b6 03             	movzbl (%ebx),%eax
  800e37:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e3a:	83 ef 01             	sub    $0x1,%edi
  800e3d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800e42:	38 c8                	cmp    %cl,%al
  800e44:	74 1d                	je     800e63 <memcmp+0x47>
  800e46:	eb 11                	jmp    800e59 <memcmp+0x3d>
  800e48:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e4d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800e52:	83 c2 01             	add    $0x1,%edx
  800e55:	38 c8                	cmp    %cl,%al
  800e57:	74 0a                	je     800e63 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800e59:	0f b6 c0             	movzbl %al,%eax
  800e5c:	0f b6 c9             	movzbl %cl,%ecx
  800e5f:	29 c8                	sub    %ecx,%eax
  800e61:	eb 09                	jmp    800e6c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e63:	39 fa                	cmp    %edi,%edx
  800e65:	75 e1                	jne    800e48 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e77:	89 c2                	mov    %eax,%edx
  800e79:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e7c:	39 d0                	cmp    %edx,%eax
  800e7e:	73 15                	jae    800e95 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e84:	38 08                	cmp    %cl,(%eax)
  800e86:	75 06                	jne    800e8e <memfind+0x1d>
  800e88:	eb 0b                	jmp    800e95 <memfind+0x24>
  800e8a:	38 08                	cmp    %cl,(%eax)
  800e8c:	74 07                	je     800e95 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e8e:	83 c0 01             	add    $0x1,%eax
  800e91:	39 c2                	cmp    %eax,%edx
  800e93:	77 f5                	ja     800e8a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	57                   	push   %edi
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
  800e9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ea3:	0f b6 02             	movzbl (%edx),%eax
  800ea6:	3c 20                	cmp    $0x20,%al
  800ea8:	74 04                	je     800eae <strtol+0x17>
  800eaa:	3c 09                	cmp    $0x9,%al
  800eac:	75 0e                	jne    800ebc <strtol+0x25>
		s++;
  800eae:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eb1:	0f b6 02             	movzbl (%edx),%eax
  800eb4:	3c 20                	cmp    $0x20,%al
  800eb6:	74 f6                	je     800eae <strtol+0x17>
  800eb8:	3c 09                	cmp    $0x9,%al
  800eba:	74 f2                	je     800eae <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ebc:	3c 2b                	cmp    $0x2b,%al
  800ebe:	75 0a                	jne    800eca <strtol+0x33>
		s++;
  800ec0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ec3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ec8:	eb 10                	jmp    800eda <strtol+0x43>
  800eca:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ecf:	3c 2d                	cmp    $0x2d,%al
  800ed1:	75 07                	jne    800eda <strtol+0x43>
		s++, neg = 1;
  800ed3:	83 c2 01             	add    $0x1,%edx
  800ed6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eda:	85 db                	test   %ebx,%ebx
  800edc:	0f 94 c0             	sete   %al
  800edf:	74 05                	je     800ee6 <strtol+0x4f>
  800ee1:	83 fb 10             	cmp    $0x10,%ebx
  800ee4:	75 15                	jne    800efb <strtol+0x64>
  800ee6:	80 3a 30             	cmpb   $0x30,(%edx)
  800ee9:	75 10                	jne    800efb <strtol+0x64>
  800eeb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800eef:	75 0a                	jne    800efb <strtol+0x64>
		s += 2, base = 16;
  800ef1:	83 c2 02             	add    $0x2,%edx
  800ef4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ef9:	eb 13                	jmp    800f0e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800efb:	84 c0                	test   %al,%al
  800efd:	74 0f                	je     800f0e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800eff:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f04:	80 3a 30             	cmpb   $0x30,(%edx)
  800f07:	75 05                	jne    800f0e <strtol+0x77>
		s++, base = 8;
  800f09:	83 c2 01             	add    $0x1,%edx
  800f0c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800f0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f13:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f15:	0f b6 0a             	movzbl (%edx),%ecx
  800f18:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f1b:	80 fb 09             	cmp    $0x9,%bl
  800f1e:	77 08                	ja     800f28 <strtol+0x91>
			dig = *s - '0';
  800f20:	0f be c9             	movsbl %cl,%ecx
  800f23:	83 e9 30             	sub    $0x30,%ecx
  800f26:	eb 1e                	jmp    800f46 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800f28:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f2b:	80 fb 19             	cmp    $0x19,%bl
  800f2e:	77 08                	ja     800f38 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800f30:	0f be c9             	movsbl %cl,%ecx
  800f33:	83 e9 57             	sub    $0x57,%ecx
  800f36:	eb 0e                	jmp    800f46 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800f38:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f3b:	80 fb 19             	cmp    $0x19,%bl
  800f3e:	77 15                	ja     800f55 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800f40:	0f be c9             	movsbl %cl,%ecx
  800f43:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f46:	39 f1                	cmp    %esi,%ecx
  800f48:	7d 0f                	jge    800f59 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800f4a:	83 c2 01             	add    $0x1,%edx
  800f4d:	0f af c6             	imul   %esi,%eax
  800f50:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f53:	eb c0                	jmp    800f15 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f55:	89 c1                	mov    %eax,%ecx
  800f57:	eb 02                	jmp    800f5b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f59:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f5f:	74 05                	je     800f66 <strtol+0xcf>
		*endptr = (char *) s;
  800f61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f64:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f66:	89 ca                	mov    %ecx,%edx
  800f68:	f7 da                	neg    %edx
  800f6a:	85 ff                	test   %edi,%edi
  800f6c:	0f 45 c2             	cmovne %edx,%eax
}
  800f6f:	5b                   	pop    %ebx
  800f70:	5e                   	pop    %esi
  800f71:	5f                   	pop    %edi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    
	...

00800f80 <__udivdi3>:
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	57                   	push   %edi
  800f84:	56                   	push   %esi
  800f85:	83 ec 10             	sub    $0x10,%esp
  800f88:	8b 75 14             	mov    0x14(%ebp),%esi
  800f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f91:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f94:	85 f6                	test   %esi,%esi
  800f96:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f99:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f9f:	75 2f                	jne    800fd0 <__udivdi3+0x50>
  800fa1:	39 f9                	cmp    %edi,%ecx
  800fa3:	77 5b                	ja     801000 <__udivdi3+0x80>
  800fa5:	85 c9                	test   %ecx,%ecx
  800fa7:	75 0b                	jne    800fb4 <__udivdi3+0x34>
  800fa9:	b8 01 00 00 00       	mov    $0x1,%eax
  800fae:	31 d2                	xor    %edx,%edx
  800fb0:	f7 f1                	div    %ecx
  800fb2:	89 c1                	mov    %eax,%ecx
  800fb4:	89 f8                	mov    %edi,%eax
  800fb6:	31 d2                	xor    %edx,%edx
  800fb8:	f7 f1                	div    %ecx
  800fba:	89 c7                	mov    %eax,%edi
  800fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fbf:	f7 f1                	div    %ecx
  800fc1:	89 fa                	mov    %edi,%edx
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    
  800fca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fd0:	31 d2                	xor    %edx,%edx
  800fd2:	31 c0                	xor    %eax,%eax
  800fd4:	39 fe                	cmp    %edi,%esi
  800fd6:	77 eb                	ja     800fc3 <__udivdi3+0x43>
  800fd8:	0f bd d6             	bsr    %esi,%edx
  800fdb:	83 f2 1f             	xor    $0x1f,%edx
  800fde:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fe1:	75 2d                	jne    801010 <__udivdi3+0x90>
  800fe3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800fe6:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  800fe9:	76 06                	jbe    800ff1 <__udivdi3+0x71>
  800feb:	39 fe                	cmp    %edi,%esi
  800fed:	89 c2                	mov    %eax,%edx
  800fef:	73 d2                	jae    800fc3 <__udivdi3+0x43>
  800ff1:	31 d2                	xor    %edx,%edx
  800ff3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff8:	eb c9                	jmp    800fc3 <__udivdi3+0x43>
  800ffa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801000:	89 fa                	mov    %edi,%edx
  801002:	f7 f1                	div    %ecx
  801004:	31 d2                	xor    %edx,%edx
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801014:	b8 20 00 00 00       	mov    $0x20,%eax
  801019:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80101c:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80101f:	d3 e6                	shl    %cl,%esi
  801021:	89 c1                	mov    %eax,%ecx
  801023:	d3 ea                	shr    %cl,%edx
  801025:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801029:	09 f2                	or     %esi,%edx
  80102b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  80102e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801031:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801034:	d3 e2                	shl    %cl,%edx
  801036:	89 c1                	mov    %eax,%ecx
  801038:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80103b:	89 fa                	mov    %edi,%edx
  80103d:	d3 ea                	shr    %cl,%edx
  80103f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801043:	d3 e7                	shl    %cl,%edi
  801045:	89 c1                	mov    %eax,%ecx
  801047:	d3 ee                	shr    %cl,%esi
  801049:	09 fe                	or     %edi,%esi
  80104b:	89 f0                	mov    %esi,%eax
  80104d:	f7 75 e8             	divl   -0x18(%ebp)
  801050:	89 d7                	mov    %edx,%edi
  801052:	89 c6                	mov    %eax,%esi
  801054:	f7 65 f0             	mull   -0x10(%ebp)
  801057:	39 d7                	cmp    %edx,%edi
  801059:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80105c:	72 22                	jb     801080 <__udivdi3+0x100>
  80105e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801061:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801065:	d3 e2                	shl    %cl,%edx
  801067:	39 c2                	cmp    %eax,%edx
  801069:	73 05                	jae    801070 <__udivdi3+0xf0>
  80106b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80106e:	74 10                	je     801080 <__udivdi3+0x100>
  801070:	89 f0                	mov    %esi,%eax
  801072:	31 d2                	xor    %edx,%edx
  801074:	e9 4a ff ff ff       	jmp    800fc3 <__udivdi3+0x43>
  801079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801080:	8d 46 ff             	lea    -0x1(%esi),%eax
  801083:	31 d2                	xor    %edx,%edx
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	5e                   	pop    %esi
  801089:	5f                   	pop    %edi
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    
  80108c:	00 00                	add    %al,(%eax)
	...

00801090 <__umoddi3>:
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	83 ec 20             	sub    $0x20,%esp
  801098:	8b 7d 14             	mov    0x14(%ebp),%edi
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
  80109e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010a4:	85 ff                	test   %edi,%edi
  8010a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8010a9:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8010ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8010af:	89 f2                	mov    %esi,%edx
  8010b1:	75 15                	jne    8010c8 <__umoddi3+0x38>
  8010b3:	39 f1                	cmp    %esi,%ecx
  8010b5:	76 41                	jbe    8010f8 <__umoddi3+0x68>
  8010b7:	f7 f1                	div    %ecx
  8010b9:	89 d0                	mov    %edx,%eax
  8010bb:	31 d2                	xor    %edx,%edx
  8010bd:	83 c4 20             	add    $0x20,%esp
  8010c0:	5e                   	pop    %esi
  8010c1:	5f                   	pop    %edi
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    
  8010c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	39 f7                	cmp    %esi,%edi
  8010ca:	77 4c                	ja     801118 <__umoddi3+0x88>
  8010cc:	0f bd c7             	bsr    %edi,%eax
  8010cf:	83 f0 1f             	xor    $0x1f,%eax
  8010d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010d5:	75 51                	jne    801128 <__umoddi3+0x98>
  8010d7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8010da:	0f 87 e8 00 00 00    	ja     8011c8 <__umoddi3+0x138>
  8010e0:	89 f2                	mov    %esi,%edx
  8010e2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8010e5:	29 ce                	sub    %ecx,%esi
  8010e7:	19 fa                	sbb    %edi,%edx
  8010e9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8010ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ef:	83 c4 20             	add    $0x20,%esp
  8010f2:	5e                   	pop    %esi
  8010f3:	5f                   	pop    %edi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    
  8010f6:	66 90                	xchg   %ax,%ax
  8010f8:	85 c9                	test   %ecx,%ecx
  8010fa:	75 0b                	jne    801107 <__umoddi3+0x77>
  8010fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801101:	31 d2                	xor    %edx,%edx
  801103:	f7 f1                	div    %ecx
  801105:	89 c1                	mov    %eax,%ecx
  801107:	89 f0                	mov    %esi,%eax
  801109:	31 d2                	xor    %edx,%edx
  80110b:	f7 f1                	div    %ecx
  80110d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801110:	eb a5                	jmp    8010b7 <__umoddi3+0x27>
  801112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801118:	89 f2                	mov    %esi,%edx
  80111a:	83 c4 20             	add    $0x20,%esp
  80111d:	5e                   	pop    %esi
  80111e:	5f                   	pop    %edi
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    
  801121:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801128:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80112c:	89 f2                	mov    %esi,%edx
  80112e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801131:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801138:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80113b:	d3 e7                	shl    %cl,%edi
  80113d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801140:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801144:	d3 e8                	shr    %cl,%eax
  801146:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80114a:	09 f8                	or     %edi,%eax
  80114c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80114f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801152:	d3 e0                	shl    %cl,%eax
  801154:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801158:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80115b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80115e:	d3 ea                	shr    %cl,%edx
  801160:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801164:	d3 e6                	shl    %cl,%esi
  801166:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80116a:	d3 e8                	shr    %cl,%eax
  80116c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801170:	09 f0                	or     %esi,%eax
  801172:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801175:	f7 75 e4             	divl   -0x1c(%ebp)
  801178:	d3 e6                	shl    %cl,%esi
  80117a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80117d:	89 d6                	mov    %edx,%esi
  80117f:	f7 65 f4             	mull   -0xc(%ebp)
  801182:	89 d7                	mov    %edx,%edi
  801184:	89 c2                	mov    %eax,%edx
  801186:	39 fe                	cmp    %edi,%esi
  801188:	89 f9                	mov    %edi,%ecx
  80118a:	72 30                	jb     8011bc <__umoddi3+0x12c>
  80118c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80118f:	72 27                	jb     8011b8 <__umoddi3+0x128>
  801191:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801194:	29 d0                	sub    %edx,%eax
  801196:	19 ce                	sbb    %ecx,%esi
  801198:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80119c:	89 f2                	mov    %esi,%edx
  80119e:	d3 e8                	shr    %cl,%eax
  8011a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011a4:	d3 e2                	shl    %cl,%edx
  8011a6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011aa:	09 d0                	or     %edx,%eax
  8011ac:	89 f2                	mov    %esi,%edx
  8011ae:	d3 ea                	shr    %cl,%edx
  8011b0:	83 c4 20             	add    $0x20,%esp
  8011b3:	5e                   	pop    %esi
  8011b4:	5f                   	pop    %edi
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    
  8011b7:	90                   	nop
  8011b8:	39 fe                	cmp    %edi,%esi
  8011ba:	75 d5                	jne    801191 <__umoddi3+0x101>
  8011bc:	89 f9                	mov    %edi,%ecx
  8011be:	89 c2                	mov    %eax,%edx
  8011c0:	2b 55 f4             	sub    -0xc(%ebp),%edx
  8011c3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011c6:	eb c9                	jmp    801191 <__umoddi3+0x101>
  8011c8:	39 f7                	cmp    %esi,%edi
  8011ca:	0f 82 10 ff ff ff    	jb     8010e0 <__umoddi3+0x50>
  8011d0:	e9 17 ff ff ff       	jmp    8010ec <__umoddi3+0x5c>
