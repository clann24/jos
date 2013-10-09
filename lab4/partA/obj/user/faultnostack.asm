
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 58 04 80 	movl   $0x800458,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 17 03 00 00       	call   800365 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	83 ec 18             	sub    $0x18,%esp
  800062:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800065:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80006e:	e8 11 01 00 00       	call   800184 <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 f6                	test   %esi,%esi
  800087:	7e 07                	jle    800090 <libmain+0x34>
		binaryname = argv[0];
  800089:	8b 03                	mov    (%ebx),%eax
  80008b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800090:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800094:	89 34 24             	mov    %esi,(%esp)
  800097:	e8 98 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0b 00 00 00       	call   8000ac <exit>
}
  8000a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a7:	89 ec                	mov    %ebp,%esp
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 69 00 00 00       	call   800127 <sys_env_destroy>
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	89 1c 24             	mov    %ebx,(%esp)
  8000c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000cd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000dc:	89 c3                	mov    %eax,%ebx
  8000de:	89 c7                	mov    %eax,%edi
  8000e0:	89 c6                	mov    %eax,%esi
  8000e2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e4:	8b 1c 24             	mov    (%esp),%ebx
  8000e7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000eb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000ef:	89 ec                	mov    %ebp,%esp
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 0c             	sub    $0xc,%esp
  8000f9:	89 1c 24             	mov    %ebx,(%esp)
  8000fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800100:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800104:	ba 00 00 00 00       	mov    $0x0,%edx
  800109:	b8 01 00 00 00       	mov    $0x1,%eax
  80010e:	89 d1                	mov    %edx,%ecx
  800110:	89 d3                	mov    %edx,%ebx
  800112:	89 d7                	mov    %edx,%edi
  800114:	89 d6                	mov    %edx,%esi
  800116:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800118:	8b 1c 24             	mov    (%esp),%ebx
  80011b:	8b 74 24 04          	mov    0x4(%esp),%esi
  80011f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800123:	89 ec                	mov    %ebp,%esp
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 38             	sub    $0x38,%esp
  80012d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800130:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800133:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800136:	b9 00 00 00 00       	mov    $0x0,%ecx
  80013b:	b8 03 00 00 00       	mov    $0x3,%eax
  800140:	8b 55 08             	mov    0x8(%ebp),%edx
  800143:	89 cb                	mov    %ecx,%ebx
  800145:	89 cf                	mov    %ecx,%edi
  800147:	89 ce                	mov    %ecx,%esi
  800149:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80014b:	85 c0                	test   %eax,%eax
  80014d:	7e 28                	jle    800177 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80014f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800153:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80015a:	00 
  80015b:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  800162:	00 
  800163:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80016a:	00 
  80016b:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  800172:	e8 ed 02 00 00       	call   800464 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800177:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80017a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80017d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800180:	89 ec                	mov    %ebp,%esp
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    

00800184 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	89 1c 24             	mov    %ebx,(%esp)
  80018d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800191:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800195:	ba 00 00 00 00       	mov    $0x0,%edx
  80019a:	b8 02 00 00 00       	mov    $0x2,%eax
  80019f:	89 d1                	mov    %edx,%ecx
  8001a1:	89 d3                	mov    %edx,%ebx
  8001a3:	89 d7                	mov    %edx,%edi
  8001a5:	89 d6                	mov    %edx,%esi
  8001a7:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  8001a9:	8b 1c 24             	mov    (%esp),%ebx
  8001ac:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001b0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001b4:	89 ec                	mov    %ebp,%esp
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <sys_yield>:

void
sys_yield(void)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	89 1c 24             	mov    %ebx,(%esp)
  8001c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ce:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001d3:	89 d1                	mov    %edx,%ecx
  8001d5:	89 d3                	mov    %edx,%ebx
  8001d7:	89 d7                	mov    %edx,%edi
  8001d9:	89 d6                	mov    %edx,%esi
  8001db:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001dd:	8b 1c 24             	mov    (%esp),%ebx
  8001e0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001e8:	89 ec                	mov    %ebp,%esp
  8001ea:	5d                   	pop    %ebp
  8001eb:	c3                   	ret    

008001ec <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	83 ec 38             	sub    $0x38,%esp
  8001f2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001f5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001f8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fb:	be 00 00 00 00       	mov    $0x0,%esi
  800200:	b8 04 00 00 00       	mov    $0x4,%eax
  800205:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 f7                	mov    %esi,%edi
  800210:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800212:	85 c0                	test   %eax,%eax
  800214:	7e 28                	jle    80023e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800216:	89 44 24 10          	mov    %eax,0x10(%esp)
  80021a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800221:	00 
  800222:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  800229:	00 
  80022a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800231:	00 
  800232:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  800239:	e8 26 02 00 00       	call   800464 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80023e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800241:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800244:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800247:	89 ec                	mov    %ebp,%esp
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	83 ec 38             	sub    $0x38,%esp
  800251:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800254:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800257:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025a:	b8 05 00 00 00       	mov    $0x5,%eax
  80025f:	8b 75 18             	mov    0x18(%ebp),%esi
  800262:	8b 7d 14             	mov    0x14(%ebp),%edi
  800265:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800268:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026b:	8b 55 08             	mov    0x8(%ebp),%edx
  80026e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800270:	85 c0                	test   %eax,%eax
  800272:	7e 28                	jle    80029c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800274:	89 44 24 10          	mov    %eax,0x10(%esp)
  800278:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80027f:	00 
  800280:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  800287:	00 
  800288:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80028f:	00 
  800290:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  800297:	e8 c8 01 00 00       	call   800464 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80029c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80029f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002a2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002a5:	89 ec                	mov    %ebp,%esp
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	83 ec 38             	sub    $0x38,%esp
  8002af:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002b2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002b5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bd:	b8 06 00 00 00       	mov    $0x6,%eax
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c8:	89 df                	mov    %ebx,%edi
  8002ca:	89 de                	mov    %ebx,%esi
  8002cc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	7e 28                	jle    8002fa <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002d6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002dd:	00 
  8002de:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  8002e5:	00 
  8002e6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ed:	00 
  8002ee:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  8002f5:	e8 6a 01 00 00       	call   800464 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002fa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002fd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800300:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800303:	89 ec                	mov    %ebp,%esp
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    

00800307 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	83 ec 38             	sub    $0x38,%esp
  80030d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800310:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800313:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800316:	bb 00 00 00 00       	mov    $0x0,%ebx
  80031b:	b8 08 00 00 00       	mov    $0x8,%eax
  800320:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800323:	8b 55 08             	mov    0x8(%ebp),%edx
  800326:	89 df                	mov    %ebx,%edi
  800328:	89 de                	mov    %ebx,%esi
  80032a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 28                	jle    800358 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	89 44 24 10          	mov    %eax,0x10(%esp)
  800334:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80033b:	00 
  80033c:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  800343:	00 
  800344:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80034b:	00 
  80034c:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  800353:	e8 0c 01 00 00       	call   800464 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800358:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80035b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80035e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800361:	89 ec                	mov    %ebp,%esp
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	83 ec 38             	sub    $0x38,%esp
  80036b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80036e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800371:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800374:	bb 00 00 00 00       	mov    $0x0,%ebx
  800379:	b8 09 00 00 00       	mov    $0x9,%eax
  80037e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800381:	8b 55 08             	mov    0x8(%ebp),%edx
  800384:	89 df                	mov    %ebx,%edi
  800386:	89 de                	mov    %ebx,%esi
  800388:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80038a:	85 c0                	test   %eax,%eax
  80038c:	7e 28                	jle    8003b6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80038e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800392:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800399:	00 
  80039a:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  8003a1:	00 
  8003a2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003a9:	00 
  8003aa:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  8003b1:	e8 ae 00 00 00       	call   800464 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003b6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003b9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003bc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003bf:	89 ec                	mov    %ebp,%esp
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	83 ec 0c             	sub    $0xc,%esp
  8003c9:	89 1c 24             	mov    %ebx,(%esp)
  8003cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d0:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003d4:	be 00 00 00 00       	mov    $0x0,%esi
  8003d9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ea:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003ec:	8b 1c 24             	mov    (%esp),%ebx
  8003ef:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003f3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003f7:	89 ec                	mov    %ebp,%esp
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	83 ec 38             	sub    $0x38,%esp
  800401:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800404:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800407:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80040a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800414:	8b 55 08             	mov    0x8(%ebp),%edx
  800417:	89 cb                	mov    %ecx,%ebx
  800419:	89 cf                	mov    %ecx,%edi
  80041b:	89 ce                	mov    %ecx,%esi
  80041d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80041f:	85 c0                	test   %eax,%eax
  800421:	7e 28                	jle    80044b <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800423:	89 44 24 10          	mov    %eax,0x10(%esp)
  800427:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80042e:	00 
  80042f:	c7 44 24 08 0a 12 80 	movl   $0x80120a,0x8(%esp)
  800436:	00 
  800437:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80043e:	00 
  80043f:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  800446:	e8 19 00 00 00       	call   800464 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80044b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80044e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800451:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800454:	89 ec                	mov    %ebp,%esp
  800456:	5d                   	pop    %ebp
  800457:	c3                   	ret    

00800458 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800458:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800459:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80045e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800460:	83 c4 04             	add    $0x4,%esp
	...

00800464 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	56                   	push   %esi
  800468:	53                   	push   %ebx
  800469:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80046c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80046f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800475:	e8 0a fd ff ff       	call   800184 <sys_getenvid>
  80047a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800481:	8b 55 08             	mov    0x8(%ebp),%edx
  800484:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800488:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80048c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800490:	c7 04 24 38 12 80 00 	movl   $0x801238,(%esp)
  800497:	e8 c3 00 00 00       	call   80055f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80049c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a3:	89 04 24             	mov    %eax,(%esp)
  8004a6:	e8 53 00 00 00       	call   8004fe <vcprintf>
	cprintf("\n");
  8004ab:	c7 04 24 5b 12 80 00 	movl   $0x80125b,(%esp)
  8004b2:	e8 a8 00 00 00       	call   80055f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004b7:	cc                   	int3   
  8004b8:	eb fd                	jmp    8004b7 <_panic+0x53>
	...

008004bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	53                   	push   %ebx
  8004c0:	83 ec 14             	sub    $0x14,%esp
  8004c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004c6:	8b 03                	mov    (%ebx),%eax
  8004c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004cf:	83 c0 01             	add    $0x1,%eax
  8004d2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004d4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004d9:	75 19                	jne    8004f4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004db:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004e2:	00 
  8004e3:	8d 43 08             	lea    0x8(%ebx),%eax
  8004e6:	89 04 24             	mov    %eax,(%esp)
  8004e9:	e8 d2 fb ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  8004ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004f4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004f8:	83 c4 14             	add    $0x14,%esp
  8004fb:	5b                   	pop    %ebx
  8004fc:	5d                   	pop    %ebp
  8004fd:	c3                   	ret    

008004fe <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800507:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80050e:	00 00 00 
	b.cnt = 0;
  800511:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800518:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80051b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800522:	8b 45 08             	mov    0x8(%ebp),%eax
  800525:	89 44 24 08          	mov    %eax,0x8(%esp)
  800529:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80052f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800533:	c7 04 24 bc 04 80 00 	movl   $0x8004bc,(%esp)
  80053a:	e8 e2 01 00 00       	call   800721 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80053f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800545:	89 44 24 04          	mov    %eax,0x4(%esp)
  800549:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	e8 69 fb ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  800557:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80055d:	c9                   	leave  
  80055e:	c3                   	ret    

0080055f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800565:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800568:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056c:	8b 45 08             	mov    0x8(%ebp),%eax
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	e8 87 ff ff ff       	call   8004fe <vcprintf>
	va_end(ap);

	return cnt;
}
  800577:	c9                   	leave  
  800578:	c3                   	ret    
  800579:	00 00                	add    %al,(%eax)
  80057b:	00 00                	add    %al,(%eax)
  80057d:	00 00                	add    %al,(%eax)
	...

00800580 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	57                   	push   %edi
  800584:	56                   	push   %esi
  800585:	53                   	push   %ebx
  800586:	83 ec 4c             	sub    $0x4c,%esp
  800589:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058c:	89 d6                	mov    %edx,%esi
  80058e:	8b 45 08             	mov    0x8(%ebp),%eax
  800591:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800594:	8b 55 0c             	mov    0xc(%ebp),%edx
  800597:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80059a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80059d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a5:	39 d0                	cmp    %edx,%eax
  8005a7:	72 11                	jb     8005ba <printnum+0x3a>
  8005a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ac:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8005af:	76 09                	jbe    8005ba <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005b1:	83 eb 01             	sub    $0x1,%ebx
  8005b4:	85 db                	test   %ebx,%ebx
  8005b6:	7f 5d                	jg     800615 <printnum+0x95>
  8005b8:	eb 6c                	jmp    800626 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005ba:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8005be:	83 eb 01             	sub    $0x1,%ebx
  8005c1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005cc:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005d0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8005d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005d7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005e1:	00 
  8005e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005e5:	89 14 24             	mov    %edx,(%esp)
  8005e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ef:	e8 ac 09 00 00       	call   800fa0 <__udivdi3>
  8005f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800602:	89 04 24             	mov    %eax,(%esp)
  800605:	89 54 24 04          	mov    %edx,0x4(%esp)
  800609:	89 f2                	mov    %esi,%edx
  80060b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80060e:	e8 6d ff ff ff       	call   800580 <printnum>
  800613:	eb 11                	jmp    800626 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800615:	89 74 24 04          	mov    %esi,0x4(%esp)
  800619:	89 3c 24             	mov    %edi,(%esp)
  80061c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80061f:	83 eb 01             	sub    $0x1,%ebx
  800622:	85 db                	test   %ebx,%ebx
  800624:	7f ef                	jg     800615 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800626:	89 74 24 04          	mov    %esi,0x4(%esp)
  80062a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80062e:	8b 45 10             	mov    0x10(%ebp),%eax
  800631:	89 44 24 08          	mov    %eax,0x8(%esp)
  800635:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80063c:	00 
  80063d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800640:	89 14 24             	mov    %edx,(%esp)
  800643:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800646:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80064a:	e8 61 0a 00 00       	call   8010b0 <__umoddi3>
  80064f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800653:	0f be 80 5d 12 80 00 	movsbl 0x80125d(%eax),%eax
  80065a:	89 04 24             	mov    %eax,(%esp)
  80065d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800660:	83 c4 4c             	add    $0x4c,%esp
  800663:	5b                   	pop    %ebx
  800664:	5e                   	pop    %esi
  800665:	5f                   	pop    %edi
  800666:	5d                   	pop    %ebp
  800667:	c3                   	ret    

00800668 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80066b:	83 fa 01             	cmp    $0x1,%edx
  80066e:	7e 0e                	jle    80067e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800670:	8b 10                	mov    (%eax),%edx
  800672:	8d 4a 08             	lea    0x8(%edx),%ecx
  800675:	89 08                	mov    %ecx,(%eax)
  800677:	8b 02                	mov    (%edx),%eax
  800679:	8b 52 04             	mov    0x4(%edx),%edx
  80067c:	eb 22                	jmp    8006a0 <getuint+0x38>
	else if (lflag)
  80067e:	85 d2                	test   %edx,%edx
  800680:	74 10                	je     800692 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800682:	8b 10                	mov    (%eax),%edx
  800684:	8d 4a 04             	lea    0x4(%edx),%ecx
  800687:	89 08                	mov    %ecx,(%eax)
  800689:	8b 02                	mov    (%edx),%eax
  80068b:	ba 00 00 00 00       	mov    $0x0,%edx
  800690:	eb 0e                	jmp    8006a0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800692:	8b 10                	mov    (%eax),%edx
  800694:	8d 4a 04             	lea    0x4(%edx),%ecx
  800697:	89 08                	mov    %ecx,(%eax)
  800699:	8b 02                	mov    (%edx),%eax
  80069b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006a0:	5d                   	pop    %ebp
  8006a1:	c3                   	ret    

008006a2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006a5:	83 fa 01             	cmp    $0x1,%edx
  8006a8:	7e 0e                	jle    8006b8 <getint+0x16>
		return va_arg(*ap, long long);
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 02                	mov    (%edx),%eax
  8006b3:	8b 52 04             	mov    0x4(%edx),%edx
  8006b6:	eb 22                	jmp    8006da <getint+0x38>
	else if (lflag)
  8006b8:	85 d2                	test   %edx,%edx
  8006ba:	74 10                	je     8006cc <getint+0x2a>
		return va_arg(*ap, long);
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006c1:	89 08                	mov    %ecx,(%eax)
  8006c3:	8b 02                	mov    (%edx),%eax
  8006c5:	89 c2                	mov    %eax,%edx
  8006c7:	c1 fa 1f             	sar    $0x1f,%edx
  8006ca:	eb 0e                	jmp    8006da <getint+0x38>
	else
		return va_arg(*ap, int);
  8006cc:	8b 10                	mov    (%eax),%edx
  8006ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006d1:	89 08                	mov    %ecx,(%eax)
  8006d3:	8b 02                	mov    (%edx),%eax
  8006d5:	89 c2                	mov    %eax,%edx
  8006d7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8006da:	5d                   	pop    %ebp
  8006db:	c3                   	ret    

008006dc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006e2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006e6:	8b 10                	mov    (%eax),%edx
  8006e8:	3b 50 04             	cmp    0x4(%eax),%edx
  8006eb:	73 0a                	jae    8006f7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f0:	88 0a                	mov    %cl,(%edx)
  8006f2:	83 c2 01             	add    $0x1,%edx
  8006f5:	89 10                	mov    %edx,(%eax)
}
  8006f7:	5d                   	pop    %ebp
  8006f8:	c3                   	ret    

008006f9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006ff:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800702:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800706:	8b 45 10             	mov    0x10(%ebp),%eax
  800709:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800710:	89 44 24 04          	mov    %eax,0x4(%esp)
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	89 04 24             	mov    %eax,(%esp)
  80071a:	e8 02 00 00 00       	call   800721 <vprintfmt>
	va_end(ap);
}
  80071f:	c9                   	leave  
  800720:	c3                   	ret    

00800721 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800721:	55                   	push   %ebp
  800722:	89 e5                	mov    %esp,%ebp
  800724:	57                   	push   %edi
  800725:	56                   	push   %esi
  800726:	53                   	push   %ebx
  800727:	83 ec 4c             	sub    $0x4c,%esp
  80072a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80072d:	eb 23                	jmp    800752 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80072f:	85 c0                	test   %eax,%eax
  800731:	75 12                	jne    800745 <vprintfmt+0x24>
				csa = 0x0700;
  800733:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80073a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80073d:	83 c4 4c             	add    $0x4c,%esp
  800740:	5b                   	pop    %ebx
  800741:	5e                   	pop    %esi
  800742:	5f                   	pop    %edi
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800745:	8b 55 0c             	mov    0xc(%ebp),%edx
  800748:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074c:	89 04 24             	mov    %eax,(%esp)
  80074f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800752:	0f b6 07             	movzbl (%edi),%eax
  800755:	83 c7 01             	add    $0x1,%edi
  800758:	83 f8 25             	cmp    $0x25,%eax
  80075b:	75 d2                	jne    80072f <vprintfmt+0xe>
  80075d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800761:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800768:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80076d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800774:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800779:	be 00 00 00 00       	mov    $0x0,%esi
  80077e:	eb 14                	jmp    800794 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800780:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800784:	eb 0e                	jmp    800794 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800786:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80078a:	eb 08                	jmp    800794 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80078c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80078f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800794:	0f b6 07             	movzbl (%edi),%eax
  800797:	0f b6 c8             	movzbl %al,%ecx
  80079a:	83 c7 01             	add    $0x1,%edi
  80079d:	83 e8 23             	sub    $0x23,%eax
  8007a0:	3c 55                	cmp    $0x55,%al
  8007a2:	0f 87 ed 02 00 00    	ja     800a95 <vprintfmt+0x374>
  8007a8:	0f b6 c0             	movzbl %al,%eax
  8007ab:	ff 24 85 20 13 80 00 	jmp    *0x801320(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007b2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  8007b5:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8007b8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007bb:	83 f9 09             	cmp    $0x9,%ecx
  8007be:	77 3c                	ja     8007fc <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007c0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8007c3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8007c6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8007ca:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8007cd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007d0:	83 f9 09             	cmp    $0x9,%ecx
  8007d3:	76 eb                	jbe    8007c0 <vprintfmt+0x9f>
  8007d5:	eb 25                	jmp    8007fc <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 48 04             	lea    0x4(%eax),%ecx
  8007dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007e0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  8007e2:	eb 18                	jmp    8007fc <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  8007e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007eb:	0f 48 c6             	cmovs  %esi,%eax
  8007ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007f1:	eb a1                	jmp    800794 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  8007f3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8007fa:	eb 98                	jmp    800794 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  8007fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800800:	79 92                	jns    800794 <vprintfmt+0x73>
  800802:	eb 88                	jmp    80078c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800804:	83 c2 01             	add    $0x1,%edx
  800807:	eb 8b                	jmp    800794 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8d 50 04             	lea    0x4(%eax),%edx
  80080f:	89 55 14             	mov    %edx,0x14(%ebp)
  800812:	8b 55 0c             	mov    0xc(%ebp),%edx
  800815:	89 54 24 04          	mov    %edx,0x4(%esp)
  800819:	8b 00                	mov    (%eax),%eax
  80081b:	89 04 24             	mov    %eax,(%esp)
  80081e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800821:	e9 2c ff ff ff       	jmp    800752 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800826:	8b 45 14             	mov    0x14(%ebp),%eax
  800829:	8d 50 04             	lea    0x4(%eax),%edx
  80082c:	89 55 14             	mov    %edx,0x14(%ebp)
  80082f:	8b 00                	mov    (%eax),%eax
  800831:	89 c2                	mov    %eax,%edx
  800833:	c1 fa 1f             	sar    $0x1f,%edx
  800836:	31 d0                	xor    %edx,%eax
  800838:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80083a:	83 f8 08             	cmp    $0x8,%eax
  80083d:	7f 0b                	jg     80084a <vprintfmt+0x129>
  80083f:	8b 14 85 80 14 80 00 	mov    0x801480(,%eax,4),%edx
  800846:	85 d2                	test   %edx,%edx
  800848:	75 23                	jne    80086d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80084a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084e:	c7 44 24 08 75 12 80 	movl   $0x801275,0x8(%esp)
  800855:	00 
  800856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800859:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085d:	8b 45 08             	mov    0x8(%ebp),%eax
  800860:	89 04 24             	mov    %eax,(%esp)
  800863:	e8 91 fe ff ff       	call   8006f9 <printfmt>
  800868:	e9 e5 fe ff ff       	jmp    800752 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80086d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800871:	c7 44 24 08 7e 12 80 	movl   $0x80127e,0x8(%esp)
  800878:	00 
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800880:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800883:	89 1c 24             	mov    %ebx,(%esp)
  800886:	e8 6e fe ff ff       	call   8006f9 <printfmt>
  80088b:	e9 c2 fe ff ff       	jmp    800752 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800890:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800893:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800896:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800899:	8b 45 14             	mov    0x14(%ebp),%eax
  80089c:	8d 50 04             	lea    0x4(%eax),%edx
  80089f:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a2:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8008a4:	85 f6                	test   %esi,%esi
  8008a6:	ba 6e 12 80 00       	mov    $0x80126e,%edx
  8008ab:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8008ae:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008b2:	7e 06                	jle    8008ba <vprintfmt+0x199>
  8008b4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8008b8:	75 13                	jne    8008cd <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008ba:	0f be 06             	movsbl (%esi),%eax
  8008bd:	83 c6 01             	add    $0x1,%esi
  8008c0:	85 c0                	test   %eax,%eax
  8008c2:	0f 85 a2 00 00 00    	jne    80096a <vprintfmt+0x249>
  8008c8:	e9 92 00 00 00       	jmp    80095f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d1:	89 34 24             	mov    %esi,(%esp)
  8008d4:	e8 82 02 00 00       	call   800b5b <strnlen>
  8008d9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008dc:	29 c2                	sub    %eax,%edx
  8008de:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008e1:	85 d2                	test   %edx,%edx
  8008e3:	7e d5                	jle    8008ba <vprintfmt+0x199>
					putch(padc, putdat);
  8008e5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8008e9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008ec:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8008ef:	89 d3                	mov    %edx,%ebx
  8008f1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8008f4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008f7:	89 c6                	mov    %eax,%esi
  8008f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008fd:	89 34 24             	mov    %esi,(%esp)
  800900:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800903:	83 eb 01             	sub    $0x1,%ebx
  800906:	85 db                	test   %ebx,%ebx
  800908:	7f ef                	jg     8008f9 <vprintfmt+0x1d8>
  80090a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80090d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800910:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800913:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80091a:	eb 9e                	jmp    8008ba <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80091c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800920:	74 1b                	je     80093d <vprintfmt+0x21c>
  800922:	8d 50 e0             	lea    -0x20(%eax),%edx
  800925:	83 fa 5e             	cmp    $0x5e,%edx
  800928:	76 13                	jbe    80093d <vprintfmt+0x21c>
					putch('?', putdat);
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800931:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800938:	ff 55 08             	call   *0x8(%ebp)
  80093b:	eb 0d                	jmp    80094a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80093d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800940:	89 54 24 04          	mov    %edx,0x4(%esp)
  800944:	89 04 24             	mov    %eax,(%esp)
  800947:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80094a:	83 ef 01             	sub    $0x1,%edi
  80094d:	0f be 06             	movsbl (%esi),%eax
  800950:	85 c0                	test   %eax,%eax
  800952:	74 05                	je     800959 <vprintfmt+0x238>
  800954:	83 c6 01             	add    $0x1,%esi
  800957:	eb 17                	jmp    800970 <vprintfmt+0x24f>
  800959:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80095c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800963:	7f 1c                	jg     800981 <vprintfmt+0x260>
  800965:	e9 e8 fd ff ff       	jmp    800752 <vprintfmt+0x31>
  80096a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80096d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800970:	85 db                	test   %ebx,%ebx
  800972:	78 a8                	js     80091c <vprintfmt+0x1fb>
  800974:	83 eb 01             	sub    $0x1,%ebx
  800977:	79 a3                	jns    80091c <vprintfmt+0x1fb>
  800979:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80097c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80097f:	eb de                	jmp    80095f <vprintfmt+0x23e>
  800981:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800984:	8b 7d 08             	mov    0x8(%ebp),%edi
  800987:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80098a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80098e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800995:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800997:	83 eb 01             	sub    $0x1,%ebx
  80099a:	85 db                	test   %ebx,%ebx
  80099c:	7f ec                	jg     80098a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009a1:	e9 ac fd ff ff       	jmp    800752 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8009a9:	e8 f4 fc ff ff       	call   8006a2 <getint>
  8009ae:	89 c3                	mov    %eax,%ebx
  8009b0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8009b2:	85 d2                	test   %edx,%edx
  8009b4:	78 0a                	js     8009c0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009bb:	e9 87 00 00 00       	jmp    800a47 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8009c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009ce:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009d1:	89 d8                	mov    %ebx,%eax
  8009d3:	89 f2                	mov    %esi,%edx
  8009d5:	f7 d8                	neg    %eax
  8009d7:	83 d2 00             	adc    $0x0,%edx
  8009da:	f7 da                	neg    %edx
			}
			base = 10;
  8009dc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009e1:	eb 64                	jmp    800a47 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e6:	e8 7d fc ff ff       	call   800668 <getuint>
			base = 10;
  8009eb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8009f0:	eb 55                	jmp    800a47 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8009f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f5:	e8 6e fc ff ff       	call   800668 <getuint>
      base = 8;
  8009fa:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8009ff:	eb 46                	jmp    800a47 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800a01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a04:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a08:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a0f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a15:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a19:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a20:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	8d 50 04             	lea    0x4(%eax),%edx
  800a29:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2c:	8b 00                	mov    (%eax),%eax
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a33:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a38:	eb 0d                	jmp    800a47 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a3d:	e8 26 fc ff ff       	call   800668 <getuint>
			base = 16;
  800a42:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a47:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800a4b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800a4f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a52:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a56:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a5a:	89 04 24             	mov    %eax,(%esp)
  800a5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a61:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	e8 14 fb ff ff       	call   800580 <printnum>
			break;
  800a6c:	e9 e1 fc ff ff       	jmp    800752 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a78:	89 0c 24             	mov    %ecx,(%esp)
  800a7b:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a7e:	e9 cf fc ff ff       	jmp    800752 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800a83:	8d 45 14             	lea    0x14(%ebp),%eax
  800a86:	e8 17 fc ff ff       	call   8006a2 <getint>
			csa = num;
  800a8b:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  800a90:	e9 bd fc ff ff       	jmp    800752 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a98:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a9c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800aa3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aa6:	83 ef 01             	sub    $0x1,%edi
  800aa9:	eb 02                	jmp    800aad <vprintfmt+0x38c>
  800aab:	89 c7                	mov    %eax,%edi
  800aad:	8d 47 ff             	lea    -0x1(%edi),%eax
  800ab0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ab4:	75 f5                	jne    800aab <vprintfmt+0x38a>
  800ab6:	e9 97 fc ff ff       	jmp    800752 <vprintfmt+0x31>

00800abb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	83 ec 28             	sub    $0x28,%esp
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ac7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aca:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ace:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ad1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	74 30                	je     800b0c <vsnprintf+0x51>
  800adc:	85 d2                	test   %edx,%edx
  800ade:	7e 2c                	jle    800b0c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ae0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ae7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aea:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aee:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800af1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af5:	c7 04 24 dc 06 80 00 	movl   $0x8006dc,(%esp)
  800afc:	e8 20 fc ff ff       	call   800721 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b01:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b04:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b0a:	eb 05                	jmp    800b11 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b19:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b20:	8b 45 10             	mov    0x10(%ebp),%eax
  800b23:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b31:	89 04 24             	mov    %eax,(%esp)
  800b34:	e8 82 ff ff ff       	call   800abb <vsnprintf>
	va_end(ap);

	return rc;
}
  800b39:	c9                   	leave  
  800b3a:	c3                   	ret    
  800b3b:	00 00                	add    %al,(%eax)
  800b3d:	00 00                	add    %al,(%eax)
	...

00800b40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b4e:	74 09                	je     800b59 <strlen+0x19>
		n++;
  800b50:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b53:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b57:	75 f7                	jne    800b50 <strlen+0x10>
		n++;
	return n;
}
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b61:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b64:	b8 00 00 00 00       	mov    $0x0,%eax
  800b69:	85 d2                	test   %edx,%edx
  800b6b:	74 12                	je     800b7f <strnlen+0x24>
  800b6d:	80 39 00             	cmpb   $0x0,(%ecx)
  800b70:	74 0d                	je     800b7f <strnlen+0x24>
		n++;
  800b72:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b75:	39 d0                	cmp    %edx,%eax
  800b77:	74 06                	je     800b7f <strnlen+0x24>
  800b79:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b7d:	75 f3                	jne    800b72 <strnlen+0x17>
		n++;
	return n;
}
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	53                   	push   %ebx
  800b85:	8b 45 08             	mov    0x8(%ebp),%eax
  800b88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b94:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b97:	83 c2 01             	add    $0x1,%edx
  800b9a:	84 c9                	test   %cl,%cl
  800b9c:	75 f2                	jne    800b90 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 08             	sub    $0x8,%esp
  800ba8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bab:	89 1c 24             	mov    %ebx,(%esp)
  800bae:	e8 8d ff ff ff       	call   800b40 <strlen>
	strcpy(dst + len, src);
  800bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb6:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bba:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bbd:	89 04 24             	mov    %eax,(%esp)
  800bc0:	e8 bc ff ff ff       	call   800b81 <strcpy>
	return dst;
}
  800bc5:	89 d8                	mov    %ebx,%eax
  800bc7:	83 c4 08             	add    $0x8,%esp
  800bca:	5b                   	pop    %ebx
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bdb:	85 f6                	test   %esi,%esi
  800bdd:	74 18                	je     800bf7 <strncpy+0x2a>
  800bdf:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800be4:	0f b6 1a             	movzbl (%edx),%ebx
  800be7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bea:	80 3a 01             	cmpb   $0x1,(%edx)
  800bed:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf0:	83 c1 01             	add    $0x1,%ecx
  800bf3:	39 ce                	cmp    %ecx,%esi
  800bf5:	77 ed                	ja     800be4 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	8b 75 08             	mov    0x8(%ebp),%esi
  800c03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c09:	89 f0                	mov    %esi,%eax
  800c0b:	85 c9                	test   %ecx,%ecx
  800c0d:	74 23                	je     800c32 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  800c0f:	83 e9 01             	sub    $0x1,%ecx
  800c12:	74 1b                	je     800c2f <strlcpy+0x34>
  800c14:	0f b6 1a             	movzbl (%edx),%ebx
  800c17:	84 db                	test   %bl,%bl
  800c19:	74 14                	je     800c2f <strlcpy+0x34>
			*dst++ = *src++;
  800c1b:	88 18                	mov    %bl,(%eax)
  800c1d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c20:	83 e9 01             	sub    $0x1,%ecx
  800c23:	74 0a                	je     800c2f <strlcpy+0x34>
			*dst++ = *src++;
  800c25:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c28:	0f b6 1a             	movzbl (%edx),%ebx
  800c2b:	84 db                	test   %bl,%bl
  800c2d:	75 ec                	jne    800c1b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  800c2f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c32:	29 f0                	sub    %esi,%eax
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c41:	0f b6 01             	movzbl (%ecx),%eax
  800c44:	84 c0                	test   %al,%al
  800c46:	74 15                	je     800c5d <strcmp+0x25>
  800c48:	3a 02                	cmp    (%edx),%al
  800c4a:	75 11                	jne    800c5d <strcmp+0x25>
		p++, q++;
  800c4c:	83 c1 01             	add    $0x1,%ecx
  800c4f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c52:	0f b6 01             	movzbl (%ecx),%eax
  800c55:	84 c0                	test   %al,%al
  800c57:	74 04                	je     800c5d <strcmp+0x25>
  800c59:	3a 02                	cmp    (%edx),%al
  800c5b:	74 ef                	je     800c4c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c5d:	0f b6 c0             	movzbl %al,%eax
  800c60:	0f b6 12             	movzbl (%edx),%edx
  800c63:	29 d0                	sub    %edx,%eax
}
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	53                   	push   %ebx
  800c6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c71:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c74:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c79:	85 d2                	test   %edx,%edx
  800c7b:	74 28                	je     800ca5 <strncmp+0x3e>
  800c7d:	0f b6 01             	movzbl (%ecx),%eax
  800c80:	84 c0                	test   %al,%al
  800c82:	74 24                	je     800ca8 <strncmp+0x41>
  800c84:	3a 03                	cmp    (%ebx),%al
  800c86:	75 20                	jne    800ca8 <strncmp+0x41>
  800c88:	83 ea 01             	sub    $0x1,%edx
  800c8b:	74 13                	je     800ca0 <strncmp+0x39>
		n--, p++, q++;
  800c8d:	83 c1 01             	add    $0x1,%ecx
  800c90:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c93:	0f b6 01             	movzbl (%ecx),%eax
  800c96:	84 c0                	test   %al,%al
  800c98:	74 0e                	je     800ca8 <strncmp+0x41>
  800c9a:	3a 03                	cmp    (%ebx),%al
  800c9c:	74 ea                	je     800c88 <strncmp+0x21>
  800c9e:	eb 08                	jmp    800ca8 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ca0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca8:	0f b6 01             	movzbl (%ecx),%eax
  800cab:	0f b6 13             	movzbl (%ebx),%edx
  800cae:	29 d0                	sub    %edx,%eax
  800cb0:	eb f3                	jmp    800ca5 <strncmp+0x3e>

00800cb2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cbc:	0f b6 10             	movzbl (%eax),%edx
  800cbf:	84 d2                	test   %dl,%dl
  800cc1:	74 20                	je     800ce3 <strchr+0x31>
		if (*s == c)
  800cc3:	38 ca                	cmp    %cl,%dl
  800cc5:	75 0b                	jne    800cd2 <strchr+0x20>
  800cc7:	eb 1f                	jmp    800ce8 <strchr+0x36>
  800cc9:	38 ca                	cmp    %cl,%dl
  800ccb:	90                   	nop
  800ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	74 16                	je     800ce8 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cd2:	83 c0 01             	add    $0x1,%eax
  800cd5:	0f b6 10             	movzbl (%eax),%edx
  800cd8:	84 d2                	test   %dl,%dl
  800cda:	75 ed                	jne    800cc9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800cdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce1:	eb 05                	jmp    800ce8 <strchr+0x36>
  800ce3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf4:	0f b6 10             	movzbl (%eax),%edx
  800cf7:	84 d2                	test   %dl,%dl
  800cf9:	74 14                	je     800d0f <strfind+0x25>
		if (*s == c)
  800cfb:	38 ca                	cmp    %cl,%dl
  800cfd:	75 06                	jne    800d05 <strfind+0x1b>
  800cff:	eb 0e                	jmp    800d0f <strfind+0x25>
  800d01:	38 ca                	cmp    %cl,%dl
  800d03:	74 0a                	je     800d0f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d05:	83 c0 01             	add    $0x1,%eax
  800d08:	0f b6 10             	movzbl (%eax),%edx
  800d0b:	84 d2                	test   %dl,%dl
  800d0d:	75 f2                	jne    800d01 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	83 ec 0c             	sub    $0xc,%esp
  800d17:	89 1c 24             	mov    %ebx,(%esp)
  800d1a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d22:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d2b:	85 c9                	test   %ecx,%ecx
  800d2d:	74 30                	je     800d5f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d2f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d35:	75 25                	jne    800d5c <memset+0x4b>
  800d37:	f6 c1 03             	test   $0x3,%cl
  800d3a:	75 20                	jne    800d5c <memset+0x4b>
		c &= 0xFF;
  800d3c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d3f:	89 d3                	mov    %edx,%ebx
  800d41:	c1 e3 08             	shl    $0x8,%ebx
  800d44:	89 d6                	mov    %edx,%esi
  800d46:	c1 e6 18             	shl    $0x18,%esi
  800d49:	89 d0                	mov    %edx,%eax
  800d4b:	c1 e0 10             	shl    $0x10,%eax
  800d4e:	09 f0                	or     %esi,%eax
  800d50:	09 d0                	or     %edx,%eax
  800d52:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d54:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d57:	fc                   	cld    
  800d58:	f3 ab                	rep stos %eax,%es:(%edi)
  800d5a:	eb 03                	jmp    800d5f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d5c:	fc                   	cld    
  800d5d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d5f:	89 f8                	mov    %edi,%eax
  800d61:	8b 1c 24             	mov    (%esp),%ebx
  800d64:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d68:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d6c:	89 ec                	mov    %ebp,%esp
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	83 ec 08             	sub    $0x8,%esp
  800d76:	89 34 24             	mov    %esi,(%esp)
  800d79:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d83:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d86:	39 c6                	cmp    %eax,%esi
  800d88:	73 36                	jae    800dc0 <memmove+0x50>
  800d8a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d8d:	39 d0                	cmp    %edx,%eax
  800d8f:	73 2f                	jae    800dc0 <memmove+0x50>
		s += n;
		d += n;
  800d91:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d94:	f6 c2 03             	test   $0x3,%dl
  800d97:	75 1b                	jne    800db4 <memmove+0x44>
  800d99:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d9f:	75 13                	jne    800db4 <memmove+0x44>
  800da1:	f6 c1 03             	test   $0x3,%cl
  800da4:	75 0e                	jne    800db4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800da6:	83 ef 04             	sub    $0x4,%edi
  800da9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800dac:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800daf:	fd                   	std    
  800db0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800db2:	eb 09                	jmp    800dbd <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800db4:	83 ef 01             	sub    $0x1,%edi
  800db7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dba:	fd                   	std    
  800dbb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dbd:	fc                   	cld    
  800dbe:	eb 20                	jmp    800de0 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dc0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dc6:	75 13                	jne    800ddb <memmove+0x6b>
  800dc8:	a8 03                	test   $0x3,%al
  800dca:	75 0f                	jne    800ddb <memmove+0x6b>
  800dcc:	f6 c1 03             	test   $0x3,%cl
  800dcf:	75 0a                	jne    800ddb <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800dd1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800dd4:	89 c7                	mov    %eax,%edi
  800dd6:	fc                   	cld    
  800dd7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dd9:	eb 05                	jmp    800de0 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ddb:	89 c7                	mov    %eax,%edi
  800ddd:	fc                   	cld    
  800dde:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800de0:	8b 34 24             	mov    (%esp),%esi
  800de3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800de7:	89 ec                	mov    %ebp,%esp
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800df1:	8b 45 10             	mov    0x10(%ebp),%eax
  800df4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800df8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dff:	8b 45 08             	mov    0x8(%ebp),%eax
  800e02:	89 04 24             	mov    %eax,(%esp)
  800e05:	e8 66 ff ff ff       	call   800d70 <memmove>
}
  800e0a:	c9                   	leave  
  800e0b:	c3                   	ret    

00800e0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
  800e12:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e18:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e20:	85 ff                	test   %edi,%edi
  800e22:	74 38                	je     800e5c <memcmp+0x50>
		if (*s1 != *s2)
  800e24:	0f b6 03             	movzbl (%ebx),%eax
  800e27:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e2a:	83 ef 01             	sub    $0x1,%edi
  800e2d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800e32:	38 c8                	cmp    %cl,%al
  800e34:	74 1d                	je     800e53 <memcmp+0x47>
  800e36:	eb 11                	jmp    800e49 <memcmp+0x3d>
  800e38:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e3d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800e42:	83 c2 01             	add    $0x1,%edx
  800e45:	38 c8                	cmp    %cl,%al
  800e47:	74 0a                	je     800e53 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800e49:	0f b6 c0             	movzbl %al,%eax
  800e4c:	0f b6 c9             	movzbl %cl,%ecx
  800e4f:	29 c8                	sub    %ecx,%eax
  800e51:	eb 09                	jmp    800e5c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e53:	39 fa                	cmp    %edi,%edx
  800e55:	75 e1                	jne    800e38 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e67:	89 c2                	mov    %eax,%edx
  800e69:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e6c:	39 d0                	cmp    %edx,%eax
  800e6e:	73 15                	jae    800e85 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e74:	38 08                	cmp    %cl,(%eax)
  800e76:	75 06                	jne    800e7e <memfind+0x1d>
  800e78:	eb 0b                	jmp    800e85 <memfind+0x24>
  800e7a:	38 08                	cmp    %cl,(%eax)
  800e7c:	74 07                	je     800e85 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e7e:	83 c0 01             	add    $0x1,%eax
  800e81:	39 c2                	cmp    %eax,%edx
  800e83:	77 f5                	ja     800e7a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    

00800e87 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	57                   	push   %edi
  800e8b:	56                   	push   %esi
  800e8c:	53                   	push   %ebx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e93:	0f b6 02             	movzbl (%edx),%eax
  800e96:	3c 20                	cmp    $0x20,%al
  800e98:	74 04                	je     800e9e <strtol+0x17>
  800e9a:	3c 09                	cmp    $0x9,%al
  800e9c:	75 0e                	jne    800eac <strtol+0x25>
		s++;
  800e9e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ea1:	0f b6 02             	movzbl (%edx),%eax
  800ea4:	3c 20                	cmp    $0x20,%al
  800ea6:	74 f6                	je     800e9e <strtol+0x17>
  800ea8:	3c 09                	cmp    $0x9,%al
  800eaa:	74 f2                	je     800e9e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800eac:	3c 2b                	cmp    $0x2b,%al
  800eae:	75 0a                	jne    800eba <strtol+0x33>
		s++;
  800eb0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800eb3:	bf 00 00 00 00       	mov    $0x0,%edi
  800eb8:	eb 10                	jmp    800eca <strtol+0x43>
  800eba:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ebf:	3c 2d                	cmp    $0x2d,%al
  800ec1:	75 07                	jne    800eca <strtol+0x43>
		s++, neg = 1;
  800ec3:	83 c2 01             	add    $0x1,%edx
  800ec6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eca:	85 db                	test   %ebx,%ebx
  800ecc:	0f 94 c0             	sete   %al
  800ecf:	74 05                	je     800ed6 <strtol+0x4f>
  800ed1:	83 fb 10             	cmp    $0x10,%ebx
  800ed4:	75 15                	jne    800eeb <strtol+0x64>
  800ed6:	80 3a 30             	cmpb   $0x30,(%edx)
  800ed9:	75 10                	jne    800eeb <strtol+0x64>
  800edb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800edf:	75 0a                	jne    800eeb <strtol+0x64>
		s += 2, base = 16;
  800ee1:	83 c2 02             	add    $0x2,%edx
  800ee4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ee9:	eb 13                	jmp    800efe <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800eeb:	84 c0                	test   %al,%al
  800eed:	74 0f                	je     800efe <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800eef:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ef4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ef7:	75 05                	jne    800efe <strtol+0x77>
		s++, base = 8;
  800ef9:	83 c2 01             	add    $0x1,%edx
  800efc:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800efe:	b8 00 00 00 00       	mov    $0x0,%eax
  800f03:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f05:	0f b6 0a             	movzbl (%edx),%ecx
  800f08:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f0b:	80 fb 09             	cmp    $0x9,%bl
  800f0e:	77 08                	ja     800f18 <strtol+0x91>
			dig = *s - '0';
  800f10:	0f be c9             	movsbl %cl,%ecx
  800f13:	83 e9 30             	sub    $0x30,%ecx
  800f16:	eb 1e                	jmp    800f36 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800f18:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f1b:	80 fb 19             	cmp    $0x19,%bl
  800f1e:	77 08                	ja     800f28 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800f20:	0f be c9             	movsbl %cl,%ecx
  800f23:	83 e9 57             	sub    $0x57,%ecx
  800f26:	eb 0e                	jmp    800f36 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800f28:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f2b:	80 fb 19             	cmp    $0x19,%bl
  800f2e:	77 15                	ja     800f45 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800f30:	0f be c9             	movsbl %cl,%ecx
  800f33:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f36:	39 f1                	cmp    %esi,%ecx
  800f38:	7d 0f                	jge    800f49 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800f3a:	83 c2 01             	add    $0x1,%edx
  800f3d:	0f af c6             	imul   %esi,%eax
  800f40:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f43:	eb c0                	jmp    800f05 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f45:	89 c1                	mov    %eax,%ecx
  800f47:	eb 02                	jmp    800f4b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f49:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f4b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f4f:	74 05                	je     800f56 <strtol+0xcf>
		*endptr = (char *) s;
  800f51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f54:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f56:	89 ca                	mov    %ecx,%edx
  800f58:	f7 da                	neg    %edx
  800f5a:	85 ff                	test   %edi,%edi
  800f5c:	0f 45 c2             	cmovne %edx,%eax
}
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f6a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800f71:	75 1c                	jne    800f8f <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800f73:	c7 44 24 08 a4 14 80 	movl   $0x8014a4,0x8(%esp)
  800f7a:	00 
  800f7b:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800f82:	00 
  800f83:	c7 04 24 c8 14 80 00 	movl   $0x8014c8,(%esp)
  800f8a:	e8 d5 f4 ff ff       	call   800464 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f92:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  800f97:	c9                   	leave  
  800f98:	c3                   	ret    
  800f99:	00 00                	add    %al,(%eax)
  800f9b:	00 00                	add    %al,(%eax)
  800f9d:	00 00                	add    %al,(%eax)
	...

00800fa0 <__udivdi3>:
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	57                   	push   %edi
  800fa4:	56                   	push   %esi
  800fa5:	83 ec 10             	sub    $0x10,%esp
  800fa8:	8b 75 14             	mov    0x14(%ebp),%esi
  800fab:	8b 45 08             	mov    0x8(%ebp),%eax
  800fae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fb1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fb4:	85 f6                	test   %esi,%esi
  800fb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fb9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800fbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800fbf:	75 2f                	jne    800ff0 <__udivdi3+0x50>
  800fc1:	39 f9                	cmp    %edi,%ecx
  800fc3:	77 5b                	ja     801020 <__udivdi3+0x80>
  800fc5:	85 c9                	test   %ecx,%ecx
  800fc7:	75 0b                	jne    800fd4 <__udivdi3+0x34>
  800fc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800fce:	31 d2                	xor    %edx,%edx
  800fd0:	f7 f1                	div    %ecx
  800fd2:	89 c1                	mov    %eax,%ecx
  800fd4:	89 f8                	mov    %edi,%eax
  800fd6:	31 d2                	xor    %edx,%edx
  800fd8:	f7 f1                	div    %ecx
  800fda:	89 c7                	mov    %eax,%edi
  800fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdf:	f7 f1                	div    %ecx
  800fe1:	89 fa                	mov    %edi,%edx
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	5e                   	pop    %esi
  800fe7:	5f                   	pop    %edi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    
  800fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ff0:	31 d2                	xor    %edx,%edx
  800ff2:	31 c0                	xor    %eax,%eax
  800ff4:	39 fe                	cmp    %edi,%esi
  800ff6:	77 eb                	ja     800fe3 <__udivdi3+0x43>
  800ff8:	0f bd d6             	bsr    %esi,%edx
  800ffb:	83 f2 1f             	xor    $0x1f,%edx
  800ffe:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801001:	75 2d                	jne    801030 <__udivdi3+0x90>
  801003:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801006:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  801009:	76 06                	jbe    801011 <__udivdi3+0x71>
  80100b:	39 fe                	cmp    %edi,%esi
  80100d:	89 c2                	mov    %eax,%edx
  80100f:	73 d2                	jae    800fe3 <__udivdi3+0x43>
  801011:	31 d2                	xor    %edx,%edx
  801013:	b8 01 00 00 00       	mov    $0x1,%eax
  801018:	eb c9                	jmp    800fe3 <__udivdi3+0x43>
  80101a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801020:	89 fa                	mov    %edi,%edx
  801022:	f7 f1                	div    %ecx
  801024:	31 d2                	xor    %edx,%edx
  801026:	83 c4 10             	add    $0x10,%esp
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    
  80102d:	8d 76 00             	lea    0x0(%esi),%esi
  801030:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801034:	b8 20 00 00 00       	mov    $0x20,%eax
  801039:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80103c:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80103f:	d3 e6                	shl    %cl,%esi
  801041:	89 c1                	mov    %eax,%ecx
  801043:	d3 ea                	shr    %cl,%edx
  801045:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801049:	09 f2                	or     %esi,%edx
  80104b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  80104e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801051:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801054:	d3 e2                	shl    %cl,%edx
  801056:	89 c1                	mov    %eax,%ecx
  801058:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80105b:	89 fa                	mov    %edi,%edx
  80105d:	d3 ea                	shr    %cl,%edx
  80105f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801063:	d3 e7                	shl    %cl,%edi
  801065:	89 c1                	mov    %eax,%ecx
  801067:	d3 ee                	shr    %cl,%esi
  801069:	09 fe                	or     %edi,%esi
  80106b:	89 f0                	mov    %esi,%eax
  80106d:	f7 75 e8             	divl   -0x18(%ebp)
  801070:	89 d7                	mov    %edx,%edi
  801072:	89 c6                	mov    %eax,%esi
  801074:	f7 65 f0             	mull   -0x10(%ebp)
  801077:	39 d7                	cmp    %edx,%edi
  801079:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80107c:	72 22                	jb     8010a0 <__udivdi3+0x100>
  80107e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801081:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801085:	d3 e2                	shl    %cl,%edx
  801087:	39 c2                	cmp    %eax,%edx
  801089:	73 05                	jae    801090 <__udivdi3+0xf0>
  80108b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80108e:	74 10                	je     8010a0 <__udivdi3+0x100>
  801090:	89 f0                	mov    %esi,%eax
  801092:	31 d2                	xor    %edx,%edx
  801094:	e9 4a ff ff ff       	jmp    800fe3 <__udivdi3+0x43>
  801099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010a0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8010a3:	31 d2                	xor    %edx,%edx
  8010a5:	83 c4 10             	add    $0x10,%esp
  8010a8:	5e                   	pop    %esi
  8010a9:	5f                   	pop    %edi
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    
  8010ac:	00 00                	add    %al,(%eax)
	...

008010b0 <__umoddi3>:
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	57                   	push   %edi
  8010b4:	56                   	push   %esi
  8010b5:	83 ec 20             	sub    $0x20,%esp
  8010b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010c4:	85 ff                	test   %edi,%edi
  8010c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8010c9:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8010cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8010cf:	89 f2                	mov    %esi,%edx
  8010d1:	75 15                	jne    8010e8 <__umoddi3+0x38>
  8010d3:	39 f1                	cmp    %esi,%ecx
  8010d5:	76 41                	jbe    801118 <__umoddi3+0x68>
  8010d7:	f7 f1                	div    %ecx
  8010d9:	89 d0                	mov    %edx,%eax
  8010db:	31 d2                	xor    %edx,%edx
  8010dd:	83 c4 20             	add    $0x20,%esp
  8010e0:	5e                   	pop    %esi
  8010e1:	5f                   	pop    %edi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    
  8010e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e8:	39 f7                	cmp    %esi,%edi
  8010ea:	77 4c                	ja     801138 <__umoddi3+0x88>
  8010ec:	0f bd c7             	bsr    %edi,%eax
  8010ef:	83 f0 1f             	xor    $0x1f,%eax
  8010f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010f5:	75 51                	jne    801148 <__umoddi3+0x98>
  8010f7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8010fa:	0f 87 e8 00 00 00    	ja     8011e8 <__umoddi3+0x138>
  801100:	89 f2                	mov    %esi,%edx
  801102:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801105:	29 ce                	sub    %ecx,%esi
  801107:	19 fa                	sbb    %edi,%edx
  801109:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80110c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80110f:	83 c4 20             	add    $0x20,%esp
  801112:	5e                   	pop    %esi
  801113:	5f                   	pop    %edi
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    
  801116:	66 90                	xchg   %ax,%ax
  801118:	85 c9                	test   %ecx,%ecx
  80111a:	75 0b                	jne    801127 <__umoddi3+0x77>
  80111c:	b8 01 00 00 00       	mov    $0x1,%eax
  801121:	31 d2                	xor    %edx,%edx
  801123:	f7 f1                	div    %ecx
  801125:	89 c1                	mov    %eax,%ecx
  801127:	89 f0                	mov    %esi,%eax
  801129:	31 d2                	xor    %edx,%edx
  80112b:	f7 f1                	div    %ecx
  80112d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801130:	eb a5                	jmp    8010d7 <__umoddi3+0x27>
  801132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801138:	89 f2                	mov    %esi,%edx
  80113a:	83 c4 20             	add    $0x20,%esp
  80113d:	5e                   	pop    %esi
  80113e:	5f                   	pop    %edi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    
  801141:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801148:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80114c:	89 f2                	mov    %esi,%edx
  80114e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801151:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801158:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80115b:	d3 e7                	shl    %cl,%edi
  80115d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801160:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801164:	d3 e8                	shr    %cl,%eax
  801166:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80116a:	09 f8                	or     %edi,%eax
  80116c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80116f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801172:	d3 e0                	shl    %cl,%eax
  801174:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801178:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80117b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80117e:	d3 ea                	shr    %cl,%edx
  801180:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801184:	d3 e6                	shl    %cl,%esi
  801186:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80118a:	d3 e8                	shr    %cl,%eax
  80118c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801190:	09 f0                	or     %esi,%eax
  801192:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801195:	f7 75 e4             	divl   -0x1c(%ebp)
  801198:	d3 e6                	shl    %cl,%esi
  80119a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80119d:	89 d6                	mov    %edx,%esi
  80119f:	f7 65 f4             	mull   -0xc(%ebp)
  8011a2:	89 d7                	mov    %edx,%edi
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	39 fe                	cmp    %edi,%esi
  8011a8:	89 f9                	mov    %edi,%ecx
  8011aa:	72 30                	jb     8011dc <__umoddi3+0x12c>
  8011ac:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8011af:	72 27                	jb     8011d8 <__umoddi3+0x128>
  8011b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8011b4:	29 d0                	sub    %edx,%eax
  8011b6:	19 ce                	sbb    %ecx,%esi
  8011b8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011bc:	89 f2                	mov    %esi,%edx
  8011be:	d3 e8                	shr    %cl,%eax
  8011c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011c4:	d3 e2                	shl    %cl,%edx
  8011c6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011ca:	09 d0                	or     %edx,%eax
  8011cc:	89 f2                	mov    %esi,%edx
  8011ce:	d3 ea                	shr    %cl,%edx
  8011d0:	83 c4 20             	add    $0x20,%esp
  8011d3:	5e                   	pop    %esi
  8011d4:	5f                   	pop    %edi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    
  8011d7:	90                   	nop
  8011d8:	39 fe                	cmp    %edi,%esi
  8011da:	75 d5                	jne    8011b1 <__umoddi3+0x101>
  8011dc:	89 f9                	mov    %edi,%ecx
  8011de:	89 c2                	mov    %eax,%edx
  8011e0:	2b 55 f4             	sub    -0xc(%ebp),%edx
  8011e3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011e6:	eb c9                	jmp    8011b1 <__umoddi3+0x101>
  8011e8:	39 f7                	cmp    %esi,%edi
  8011ea:	0f 82 10 ff ff ff    	jb     801100 <__umoddi3+0x50>
  8011f0:	e9 17 ff ff ff       	jmp    80110c <__umoddi3+0x5c>
