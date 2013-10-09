
obj/user/breakpoint:     file format elf32-i386


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
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    
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
  800042:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800045:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80004e:	e8 11 01 00 00       	call   800164 <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800060:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 f6                	test   %esi,%esi
  800067:	7e 07                	jle    800070 <libmain+0x34>
		binaryname = argv[0];
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800070:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800074:	89 34 24             	mov    %esi,(%esp)
  800077:	e8 b8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0b 00 00 00       	call   80008c <exit>
}
  800081:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800084:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800087:	89 ec                	mov    %ebp,%esp
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 69 00 00 00       	call   800107 <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 0c             	sub    $0xc,%esp
  8000a6:	89 1c 24             	mov    %ebx,(%esp)
  8000a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ad:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bc:	89 c3                	mov    %eax,%ebx
  8000be:	89 c7                	mov    %eax,%edi
  8000c0:	89 c6                	mov    %eax,%esi
  8000c2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c4:	8b 1c 24             	mov    (%esp),%ebx
  8000c7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000cb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000cf:	89 ec                	mov    %ebp,%esp
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	83 ec 0c             	sub    $0xc,%esp
  8000d9:	89 1c 24             	mov    %ebx,(%esp)
  8000dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000e0:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ee:	89 d1                	mov    %edx,%ecx
  8000f0:	89 d3                	mov    %edx,%ebx
  8000f2:	89 d7                	mov    %edx,%edi
  8000f4:	89 d6                	mov    %edx,%esi
  8000f6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f8:	8b 1c 24             	mov    (%esp),%ebx
  8000fb:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000ff:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800103:	89 ec                	mov    %ebp,%esp
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 38             	sub    $0x38,%esp
  80010d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800110:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800113:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800116:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011b:	b8 03 00 00 00       	mov    $0x3,%eax
  800120:	8b 55 08             	mov    0x8(%ebp),%edx
  800123:	89 cb                	mov    %ecx,%ebx
  800125:	89 cf                	mov    %ecx,%edi
  800127:	89 ce                	mov    %ecx,%esi
  800129:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80012b:	85 c0                	test   %eax,%eax
  80012d:	7e 28                	jle    800157 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800133:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80013a:	00 
  80013b:	c7 44 24 08 aa 11 80 	movl   $0x8011aa,0x8(%esp)
  800142:	00 
  800143:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80014a:	00 
  80014b:	c7 04 24 c7 11 80 00 	movl   $0x8011c7,(%esp)
  800152:	e8 e1 02 00 00       	call   800438 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800157:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80015a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80015d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800160:	89 ec                	mov    %ebp,%esp
  800162:	5d                   	pop    %ebp
  800163:	c3                   	ret    

00800164 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 0c             	sub    $0xc,%esp
  80016a:	89 1c 24             	mov    %ebx,(%esp)
  80016d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800171:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800175:	ba 00 00 00 00       	mov    $0x0,%edx
  80017a:	b8 02 00 00 00       	mov    $0x2,%eax
  80017f:	89 d1                	mov    %edx,%ecx
  800181:	89 d3                	mov    %edx,%ebx
  800183:	89 d7                	mov    %edx,%edi
  800185:	89 d6                	mov    %edx,%esi
  800187:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800189:	8b 1c 24             	mov    (%esp),%ebx
  80018c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800190:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800194:	89 ec                	mov    %ebp,%esp
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_yield>:

void
sys_yield(void)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	89 1c 24             	mov    %ebx,(%esp)
  8001a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001b3:	89 d1                	mov    %edx,%ecx
  8001b5:	89 d3                	mov    %edx,%ebx
  8001b7:	89 d7                	mov    %edx,%edi
  8001b9:	89 d6                	mov    %edx,%esi
  8001bb:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001bd:	8b 1c 24             	mov    (%esp),%ebx
  8001c0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001c4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001c8:	89 ec                	mov    %ebp,%esp
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 38             	sub    $0x38,%esp
  8001d2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001d8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001db:	be 00 00 00 00       	mov    $0x0,%esi
  8001e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	89 f7                	mov    %esi,%edi
  8001f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7e 28                	jle    80021e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800201:	00 
  800202:	c7 44 24 08 aa 11 80 	movl   $0x8011aa,0x8(%esp)
  800209:	00 
  80020a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800211:	00 
  800212:	c7 04 24 c7 11 80 00 	movl   $0x8011c7,(%esp)
  800219:	e8 1a 02 00 00       	call   800438 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80021e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800221:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800224:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800227:	89 ec                	mov    %ebp,%esp
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 38             	sub    $0x38,%esp
  800231:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800234:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800237:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	b8 05 00 00 00       	mov    $0x5,%eax
  80023f:	8b 75 18             	mov    0x18(%ebp),%esi
  800242:	8b 7d 14             	mov    0x14(%ebp),%edi
  800245:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800248:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024b:	8b 55 08             	mov    0x8(%ebp),%edx
  80024e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 28                	jle    80027c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	89 44 24 10          	mov    %eax,0x10(%esp)
  800258:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80025f:	00 
  800260:	c7 44 24 08 aa 11 80 	movl   $0x8011aa,0x8(%esp)
  800267:	00 
  800268:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026f:	00 
  800270:	c7 04 24 c7 11 80 00 	movl   $0x8011c7,(%esp)
  800277:	e8 bc 01 00 00       	call   800438 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80027c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80027f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800282:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800285:	89 ec                	mov    %ebp,%esp
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 38             	sub    $0x38,%esp
  80028f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800292:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800295:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029d:	b8 06 00 00 00       	mov    $0x6,%eax
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a8:	89 df                	mov    %ebx,%edi
  8002aa:	89 de                	mov    %ebx,%esi
  8002ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ae:	85 c0                	test   %eax,%eax
  8002b0:	7e 28                	jle    8002da <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002b6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002bd:	00 
  8002be:	c7 44 24 08 aa 11 80 	movl   $0x8011aa,0x8(%esp)
  8002c5:	00 
  8002c6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002cd:	00 
  8002ce:	c7 04 24 c7 11 80 00 	movl   $0x8011c7,(%esp)
  8002d5:	e8 5e 01 00 00       	call   800438 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002e3:	89 ec                	mov    %ebp,%esp
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	83 ec 38             	sub    $0x38,%esp
  8002ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fb:	b8 08 00 00 00       	mov    $0x8,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	89 df                	mov    %ebx,%edi
  800308:	89 de                	mov    %ebx,%esi
  80030a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80030c:	85 c0                	test   %eax,%eax
  80030e:	7e 28                	jle    800338 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800310:	89 44 24 10          	mov    %eax,0x10(%esp)
  800314:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80031b:	00 
  80031c:	c7 44 24 08 aa 11 80 	movl   $0x8011aa,0x8(%esp)
  800323:	00 
  800324:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80032b:	00 
  80032c:	c7 04 24 c7 11 80 00 	movl   $0x8011c7,(%esp)
  800333:	e8 00 01 00 00       	call   800438 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800338:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80033b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80033e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800341:	89 ec                	mov    %ebp,%esp
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 38             	sub    $0x38,%esp
  80034b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80034e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800351:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800354:	bb 00 00 00 00       	mov    $0x0,%ebx
  800359:	b8 09 00 00 00       	mov    $0x9,%eax
  80035e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800361:	8b 55 08             	mov    0x8(%ebp),%edx
  800364:	89 df                	mov    %ebx,%edi
  800366:	89 de                	mov    %ebx,%esi
  800368:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80036a:	85 c0                	test   %eax,%eax
  80036c:	7e 28                	jle    800396 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800372:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800379:	00 
  80037a:	c7 44 24 08 aa 11 80 	movl   $0x8011aa,0x8(%esp)
  800381:	00 
  800382:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800389:	00 
  80038a:	c7 04 24 c7 11 80 00 	movl   $0x8011c7,(%esp)
  800391:	e8 a2 00 00 00       	call   800438 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800396:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800399:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80039c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80039f:	89 ec                	mov    %ebp,%esp
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	83 ec 0c             	sub    $0xc,%esp
  8003a9:	89 1c 24             	mov    %ebx,(%esp)
  8003ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003b0:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b4:	be 00 00 00 00       	mov    $0x0,%esi
  8003b9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003be:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ca:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003cc:	8b 1c 24             	mov    (%esp),%ebx
  8003cf:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003d3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003d7:	89 ec                	mov    %ebp,%esp
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	83 ec 38             	sub    $0x38,%esp
  8003e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ef:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f7:	89 cb                	mov    %ecx,%ebx
  8003f9:	89 cf                	mov    %ecx,%edi
  8003fb:	89 ce                	mov    %ecx,%esi
  8003fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003ff:	85 c0                	test   %eax,%eax
  800401:	7e 28                	jle    80042b <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800403:	89 44 24 10          	mov    %eax,0x10(%esp)
  800407:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80040e:	00 
  80040f:	c7 44 24 08 aa 11 80 	movl   $0x8011aa,0x8(%esp)
  800416:	00 
  800417:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80041e:	00 
  80041f:	c7 04 24 c7 11 80 00 	movl   $0x8011c7,(%esp)
  800426:	e8 0d 00 00 00       	call   800438 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80042b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80042e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800431:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800434:	89 ec                	mov    %ebp,%esp
  800436:	5d                   	pop    %ebp
  800437:	c3                   	ret    

00800438 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	56                   	push   %esi
  80043c:	53                   	push   %ebx
  80043d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800440:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800443:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800449:	e8 16 fd ff ff       	call   800164 <sys_getenvid>
  80044e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800451:	89 54 24 10          	mov    %edx,0x10(%esp)
  800455:	8b 55 08             	mov    0x8(%ebp),%edx
  800458:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800460:	89 44 24 04          	mov    %eax,0x4(%esp)
  800464:	c7 04 24 d8 11 80 00 	movl   $0x8011d8,(%esp)
  80046b:	e8 c3 00 00 00       	call   800533 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800470:	89 74 24 04          	mov    %esi,0x4(%esp)
  800474:	8b 45 10             	mov    0x10(%ebp),%eax
  800477:	89 04 24             	mov    %eax,(%esp)
  80047a:	e8 53 00 00 00       	call   8004d2 <vcprintf>
	cprintf("\n");
  80047f:	c7 04 24 fc 11 80 00 	movl   $0x8011fc,(%esp)
  800486:	e8 a8 00 00 00       	call   800533 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80048b:	cc                   	int3   
  80048c:	eb fd                	jmp    80048b <_panic+0x53>
	...

00800490 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	53                   	push   %ebx
  800494:	83 ec 14             	sub    $0x14,%esp
  800497:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80049a:	8b 03                	mov    (%ebx),%eax
  80049c:	8b 55 08             	mov    0x8(%ebp),%edx
  80049f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004a3:	83 c0 01             	add    $0x1,%eax
  8004a6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004a8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004ad:	75 19                	jne    8004c8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004af:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004b6:	00 
  8004b7:	8d 43 08             	lea    0x8(%ebx),%eax
  8004ba:	89 04 24             	mov    %eax,(%esp)
  8004bd:	e8 de fb ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  8004c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004c8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004cc:	83 c4 14             	add    $0x14,%esp
  8004cf:	5b                   	pop    %ebx
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004db:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e2:	00 00 00 
	b.cnt = 0;
  8004e5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004ec:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800503:	89 44 24 04          	mov    %eax,0x4(%esp)
  800507:	c7 04 24 90 04 80 00 	movl   $0x800490,(%esp)
  80050e:	e8 de 01 00 00       	call   8006f1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800513:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800523:	89 04 24             	mov    %eax,(%esp)
  800526:	e8 75 fb ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  80052b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800531:	c9                   	leave  
  800532:	c3                   	ret    

00800533 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800533:	55                   	push   %ebp
  800534:	89 e5                	mov    %esp,%ebp
  800536:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800539:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80053c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800540:	8b 45 08             	mov    0x8(%ebp),%eax
  800543:	89 04 24             	mov    %eax,(%esp)
  800546:	e8 87 ff ff ff       	call   8004d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80054b:	c9                   	leave  
  80054c:	c3                   	ret    
  80054d:	00 00                	add    %al,(%eax)
	...

00800550 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	57                   	push   %edi
  800554:	56                   	push   %esi
  800555:	53                   	push   %ebx
  800556:	83 ec 4c             	sub    $0x4c,%esp
  800559:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055c:	89 d6                	mov    %edx,%esi
  80055e:	8b 45 08             	mov    0x8(%ebp),%eax
  800561:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800564:	8b 55 0c             	mov    0xc(%ebp),%edx
  800567:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80056a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80056d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800570:	b8 00 00 00 00       	mov    $0x0,%eax
  800575:	39 d0                	cmp    %edx,%eax
  800577:	72 11                	jb     80058a <printnum+0x3a>
  800579:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80057c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  80057f:	76 09                	jbe    80058a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800581:	83 eb 01             	sub    $0x1,%ebx
  800584:	85 db                	test   %ebx,%ebx
  800586:	7f 5d                	jg     8005e5 <printnum+0x95>
  800588:	eb 6c                	jmp    8005f6 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80058a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80058e:	83 eb 01             	sub    $0x1,%ebx
  800591:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800595:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800598:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80059c:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005a0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8005a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005aa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005b1:	00 
  8005b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005b5:	89 14 24             	mov    %edx,(%esp)
  8005b8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005bf:	e8 7c 09 00 00       	call   800f40 <__udivdi3>
  8005c4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005c7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005ca:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005ce:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005d2:	89 04 24             	mov    %eax,(%esp)
  8005d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d9:	89 f2                	mov    %esi,%edx
  8005db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005de:	e8 6d ff ff ff       	call   800550 <printnum>
  8005e3:	eb 11                	jmp    8005f6 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e9:	89 3c 24             	mov    %edi,(%esp)
  8005ec:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005ef:	83 eb 01             	sub    $0x1,%ebx
  8005f2:	85 db                	test   %ebx,%ebx
  8005f4:	7f ef                	jg     8005e5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005fa:	8b 74 24 04          	mov    0x4(%esp),%esi
  8005fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800601:	89 44 24 08          	mov    %eax,0x8(%esp)
  800605:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80060c:	00 
  80060d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800610:	89 14 24             	mov    %edx,(%esp)
  800613:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800616:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80061a:	e8 31 0a 00 00       	call   801050 <__umoddi3>
  80061f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800623:	0f be 80 fe 11 80 00 	movsbl 0x8011fe(%eax),%eax
  80062a:	89 04 24             	mov    %eax,(%esp)
  80062d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800630:	83 c4 4c             	add    $0x4c,%esp
  800633:	5b                   	pop    %ebx
  800634:	5e                   	pop    %esi
  800635:	5f                   	pop    %edi
  800636:	5d                   	pop    %ebp
  800637:	c3                   	ret    

00800638 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800638:	55                   	push   %ebp
  800639:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80063b:	83 fa 01             	cmp    $0x1,%edx
  80063e:	7e 0e                	jle    80064e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800640:	8b 10                	mov    (%eax),%edx
  800642:	8d 4a 08             	lea    0x8(%edx),%ecx
  800645:	89 08                	mov    %ecx,(%eax)
  800647:	8b 02                	mov    (%edx),%eax
  800649:	8b 52 04             	mov    0x4(%edx),%edx
  80064c:	eb 22                	jmp    800670 <getuint+0x38>
	else if (lflag)
  80064e:	85 d2                	test   %edx,%edx
  800650:	74 10                	je     800662 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800652:	8b 10                	mov    (%eax),%edx
  800654:	8d 4a 04             	lea    0x4(%edx),%ecx
  800657:	89 08                	mov    %ecx,(%eax)
  800659:	8b 02                	mov    (%edx),%eax
  80065b:	ba 00 00 00 00       	mov    $0x0,%edx
  800660:	eb 0e                	jmp    800670 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800662:	8b 10                	mov    (%eax),%edx
  800664:	8d 4a 04             	lea    0x4(%edx),%ecx
  800667:	89 08                	mov    %ecx,(%eax)
  800669:	8b 02                	mov    (%edx),%eax
  80066b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800670:	5d                   	pop    %ebp
  800671:	c3                   	ret    

00800672 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800675:	83 fa 01             	cmp    $0x1,%edx
  800678:	7e 0e                	jle    800688 <getint+0x16>
		return va_arg(*ap, long long);
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80067f:	89 08                	mov    %ecx,(%eax)
  800681:	8b 02                	mov    (%edx),%eax
  800683:	8b 52 04             	mov    0x4(%edx),%edx
  800686:	eb 22                	jmp    8006aa <getint+0x38>
	else if (lflag)
  800688:	85 d2                	test   %edx,%edx
  80068a:	74 10                	je     80069c <getint+0x2a>
		return va_arg(*ap, long);
  80068c:	8b 10                	mov    (%eax),%edx
  80068e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800691:	89 08                	mov    %ecx,(%eax)
  800693:	8b 02                	mov    (%edx),%eax
  800695:	89 c2                	mov    %eax,%edx
  800697:	c1 fa 1f             	sar    $0x1f,%edx
  80069a:	eb 0e                	jmp    8006aa <getint+0x38>
	else
		return va_arg(*ap, int);
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a1:	89 08                	mov    %ecx,(%eax)
  8006a3:	8b 02                	mov    (%edx),%eax
  8006a5:	89 c2                	mov    %eax,%edx
  8006a7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8006aa:	5d                   	pop    %ebp
  8006ab:	c3                   	ret    

008006ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006b2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	3b 50 04             	cmp    0x4(%eax),%edx
  8006bb:	73 0a                	jae    8006c7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c0:	88 0a                	mov    %cl,(%edx)
  8006c2:	83 c2 01             	add    $0x1,%edx
  8006c5:	89 10                	mov    %edx,(%eax)
}
  8006c7:	5d                   	pop    %ebp
  8006c8:	c3                   	ret    

008006c9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006cf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e7:	89 04 24             	mov    %eax,(%esp)
  8006ea:	e8 02 00 00 00       	call   8006f1 <vprintfmt>
	va_end(ap);
}
  8006ef:	c9                   	leave  
  8006f0:	c3                   	ret    

008006f1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	57                   	push   %edi
  8006f5:	56                   	push   %esi
  8006f6:	53                   	push   %ebx
  8006f7:	83 ec 4c             	sub    $0x4c,%esp
  8006fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006fd:	eb 23                	jmp    800722 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  8006ff:	85 c0                	test   %eax,%eax
  800701:	75 12                	jne    800715 <vprintfmt+0x24>
				csa = 0x0700;
  800703:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80070a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80070d:	83 c4 4c             	add    $0x4c,%esp
  800710:	5b                   	pop    %ebx
  800711:	5e                   	pop    %esi
  800712:	5f                   	pop    %edi
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800715:	8b 55 0c             	mov    0xc(%ebp),%edx
  800718:	89 54 24 04          	mov    %edx,0x4(%esp)
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800722:	0f b6 07             	movzbl (%edi),%eax
  800725:	83 c7 01             	add    $0x1,%edi
  800728:	83 f8 25             	cmp    $0x25,%eax
  80072b:	75 d2                	jne    8006ff <vprintfmt+0xe>
  80072d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800731:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800738:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80073d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800744:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800749:	be 00 00 00 00       	mov    $0x0,%esi
  80074e:	eb 14                	jmp    800764 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800750:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800754:	eb 0e                	jmp    800764 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800756:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80075a:	eb 08                	jmp    800764 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80075c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80075f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800764:	0f b6 07             	movzbl (%edi),%eax
  800767:	0f b6 c8             	movzbl %al,%ecx
  80076a:	83 c7 01             	add    $0x1,%edi
  80076d:	83 e8 23             	sub    $0x23,%eax
  800770:	3c 55                	cmp    $0x55,%al
  800772:	0f 87 ed 02 00 00    	ja     800a65 <vprintfmt+0x374>
  800778:	0f b6 c0             	movzbl %al,%eax
  80077b:	ff 24 85 c0 12 80 00 	jmp    *0x8012c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800782:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  800785:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800788:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80078b:	83 f9 09             	cmp    $0x9,%ecx
  80078e:	77 3c                	ja     8007cc <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800790:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800793:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  800796:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  80079a:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80079d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007a0:	83 f9 09             	cmp    $0x9,%ecx
  8007a3:	76 eb                	jbe    800790 <vprintfmt+0x9f>
  8007a5:	eb 25                	jmp    8007cc <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007aa:	8d 48 04             	lea    0x4(%eax),%ecx
  8007ad:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007b0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  8007b2:	eb 18                	jmp    8007cc <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  8007b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007bb:	0f 48 c6             	cmovs  %esi,%eax
  8007be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007c1:	eb a1                	jmp    800764 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  8007c3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8007ca:	eb 98                	jmp    800764 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  8007cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007d0:	79 92                	jns    800764 <vprintfmt+0x73>
  8007d2:	eb 88                	jmp    80075c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007d4:	83 c2 01             	add    $0x1,%edx
  8007d7:	eb 8b                	jmp    800764 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dc:	8d 50 04             	lea    0x4(%eax),%edx
  8007df:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e9:	8b 00                	mov    (%eax),%eax
  8007eb:	89 04 24             	mov    %eax,(%esp)
  8007ee:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007f1:	e9 2c ff ff ff       	jmp    800722 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8d 50 04             	lea    0x4(%eax),%edx
  8007fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ff:	8b 00                	mov    (%eax),%eax
  800801:	89 c2                	mov    %eax,%edx
  800803:	c1 fa 1f             	sar    $0x1f,%edx
  800806:	31 d0                	xor    %edx,%eax
  800808:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80080a:	83 f8 08             	cmp    $0x8,%eax
  80080d:	7f 0b                	jg     80081a <vprintfmt+0x129>
  80080f:	8b 14 85 20 14 80 00 	mov    0x801420(,%eax,4),%edx
  800816:	85 d2                	test   %edx,%edx
  800818:	75 23                	jne    80083d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80081a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081e:	c7 44 24 08 16 12 80 	movl   $0x801216,0x8(%esp)
  800825:	00 
  800826:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800829:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	89 04 24             	mov    %eax,(%esp)
  800833:	e8 91 fe ff ff       	call   8006c9 <printfmt>
  800838:	e9 e5 fe ff ff       	jmp    800722 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80083d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800841:	c7 44 24 08 1f 12 80 	movl   $0x80121f,0x8(%esp)
  800848:	00 
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800850:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800853:	89 1c 24             	mov    %ebx,(%esp)
  800856:	e8 6e fe ff ff       	call   8006c9 <printfmt>
  80085b:	e9 c2 fe ff ff       	jmp    800722 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800860:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800863:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800866:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800869:	8b 45 14             	mov    0x14(%ebp),%eax
  80086c:	8d 50 04             	lea    0x4(%eax),%edx
  80086f:	89 55 14             	mov    %edx,0x14(%ebp)
  800872:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800874:	85 f6                	test   %esi,%esi
  800876:	ba 0f 12 80 00       	mov    $0x80120f,%edx
  80087b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80087e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800882:	7e 06                	jle    80088a <vprintfmt+0x199>
  800884:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800888:	75 13                	jne    80089d <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80088a:	0f be 06             	movsbl (%esi),%eax
  80088d:	83 c6 01             	add    $0x1,%esi
  800890:	85 c0                	test   %eax,%eax
  800892:	0f 85 a2 00 00 00    	jne    80093a <vprintfmt+0x249>
  800898:	e9 92 00 00 00       	jmp    80092f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80089d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a1:	89 34 24             	mov    %esi,(%esp)
  8008a4:	e8 82 02 00 00       	call   800b2b <strnlen>
  8008a9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008ac:	29 c2                	sub    %eax,%edx
  8008ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008b1:	85 d2                	test   %edx,%edx
  8008b3:	7e d5                	jle    80088a <vprintfmt+0x199>
					putch(padc, putdat);
  8008b5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8008b9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008bc:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8008bf:	89 d3                	mov    %edx,%ebx
  8008c1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8008c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008c7:	89 c6                	mov    %eax,%esi
  8008c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008cd:	89 34 24             	mov    %esi,(%esp)
  8008d0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008d3:	83 eb 01             	sub    $0x1,%ebx
  8008d6:	85 db                	test   %ebx,%ebx
  8008d8:	7f ef                	jg     8008c9 <vprintfmt+0x1d8>
  8008da:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8008dd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008e3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8008ea:	eb 9e                	jmp    80088a <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008f0:	74 1b                	je     80090d <vprintfmt+0x21c>
  8008f2:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008f5:	83 fa 5e             	cmp    $0x5e,%edx
  8008f8:	76 13                	jbe    80090d <vprintfmt+0x21c>
					putch('?', putdat);
  8008fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800901:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800908:	ff 55 08             	call   *0x8(%ebp)
  80090b:	eb 0d                	jmp    80091a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 54 24 04          	mov    %edx,0x4(%esp)
  800914:	89 04 24             	mov    %eax,(%esp)
  800917:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80091a:	83 ef 01             	sub    $0x1,%edi
  80091d:	0f be 06             	movsbl (%esi),%eax
  800920:	85 c0                	test   %eax,%eax
  800922:	74 05                	je     800929 <vprintfmt+0x238>
  800924:	83 c6 01             	add    $0x1,%esi
  800927:	eb 17                	jmp    800940 <vprintfmt+0x24f>
  800929:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80092c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80092f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800933:	7f 1c                	jg     800951 <vprintfmt+0x260>
  800935:	e9 e8 fd ff ff       	jmp    800722 <vprintfmt+0x31>
  80093a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80093d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800940:	85 db                	test   %ebx,%ebx
  800942:	78 a8                	js     8008ec <vprintfmt+0x1fb>
  800944:	83 eb 01             	sub    $0x1,%ebx
  800947:	79 a3                	jns    8008ec <vprintfmt+0x1fb>
  800949:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80094c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80094f:	eb de                	jmp    80092f <vprintfmt+0x23e>
  800951:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800954:	8b 7d 08             	mov    0x8(%ebp),%edi
  800957:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80095a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80095e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800965:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800967:	83 eb 01             	sub    $0x1,%ebx
  80096a:	85 db                	test   %ebx,%ebx
  80096c:	7f ec                	jg     80095a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800971:	e9 ac fd ff ff       	jmp    800722 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800976:	8d 45 14             	lea    0x14(%ebp),%eax
  800979:	e8 f4 fc ff ff       	call   800672 <getint>
  80097e:	89 c3                	mov    %eax,%ebx
  800980:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800982:	85 d2                	test   %edx,%edx
  800984:	78 0a                	js     800990 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800986:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80098b:	e9 87 00 00 00       	jmp    800a17 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800990:	8b 45 0c             	mov    0xc(%ebp),%eax
  800993:	89 44 24 04          	mov    %eax,0x4(%esp)
  800997:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80099e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009a1:	89 d8                	mov    %ebx,%eax
  8009a3:	89 f2                	mov    %esi,%edx
  8009a5:	f7 d8                	neg    %eax
  8009a7:	83 d2 00             	adc    $0x0,%edx
  8009aa:	f7 da                	neg    %edx
			}
			base = 10;
  8009ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009b1:	eb 64                	jmp    800a17 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8009b6:	e8 7d fc ff ff       	call   800638 <getuint>
			base = 10;
  8009bb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8009c0:	eb 55                	jmp    800a17 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8009c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c5:	e8 6e fc ff ff       	call   800638 <getuint>
      base = 8;
  8009ca:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8009cf:	eb 46                	jmp    800a17 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  8009d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009d8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009df:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e9:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009f0:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f6:	8d 50 04             	lea    0x4(%eax),%edx
  8009f9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009fc:	8b 00                	mov    (%eax),%eax
  8009fe:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a03:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a08:	eb 0d                	jmp    800a17 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a0a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0d:	e8 26 fc ff ff       	call   800638 <getuint>
			base = 16;
  800a12:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a17:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800a1b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800a1f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a22:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a26:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a2a:	89 04 24             	mov    %eax,(%esp)
  800a2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a31:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	e8 14 fb ff ff       	call   800550 <printnum>
			break;
  800a3c:	e9 e1 fc ff ff       	jmp    800722 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a48:	89 0c 24             	mov    %ecx,(%esp)
  800a4b:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a4e:	e9 cf fc ff ff       	jmp    800722 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800a53:	8d 45 14             	lea    0x14(%ebp),%eax
  800a56:	e8 17 fc ff ff       	call   800672 <getint>
			csa = num;
  800a5b:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  800a60:	e9 bd fc ff ff       	jmp    800722 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a68:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a6c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a73:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a76:	83 ef 01             	sub    $0x1,%edi
  800a79:	eb 02                	jmp    800a7d <vprintfmt+0x38c>
  800a7b:	89 c7                	mov    %eax,%edi
  800a7d:	8d 47 ff             	lea    -0x1(%edi),%eax
  800a80:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a84:	75 f5                	jne    800a7b <vprintfmt+0x38a>
  800a86:	e9 97 fc ff ff       	jmp    800722 <vprintfmt+0x31>

00800a8b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	83 ec 28             	sub    $0x28,%esp
  800a91:	8b 45 08             	mov    0x8(%ebp),%eax
  800a94:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a97:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a9a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a9e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800aa1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800aa8:	85 c0                	test   %eax,%eax
  800aaa:	74 30                	je     800adc <vsnprintf+0x51>
  800aac:	85 d2                	test   %edx,%edx
  800aae:	7e 2c                	jle    800adc <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ab0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ab7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac5:	c7 04 24 ac 06 80 00 	movl   $0x8006ac,(%esp)
  800acc:	e8 20 fc ff ff       	call   8006f1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ad1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ad4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ada:	eb 05                	jmp    800ae1 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800adc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ae1:	c9                   	leave  
  800ae2:	c3                   	ret    

00800ae3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ae9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800af0:	8b 45 10             	mov    0x10(%ebp),%eax
  800af3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	89 04 24             	mov    %eax,(%esp)
  800b04:	e8 82 ff ff ff       	call   800a8b <vsnprintf>
	va_end(ap);

	return rc;
}
  800b09:	c9                   	leave  
  800b0a:	c3                   	ret    
  800b0b:	00 00                	add    %al,(%eax)
  800b0d:	00 00                	add    %al,(%eax)
	...

00800b10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b1e:	74 09                	je     800b29 <strlen+0x19>
		n++;
  800b20:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b27:	75 f7                	jne    800b20 <strlen+0x10>
		n++;
	return n;
}
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b31:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b34:	b8 00 00 00 00       	mov    $0x0,%eax
  800b39:	85 d2                	test   %edx,%edx
  800b3b:	74 12                	je     800b4f <strnlen+0x24>
  800b3d:	80 39 00             	cmpb   $0x0,(%ecx)
  800b40:	74 0d                	je     800b4f <strnlen+0x24>
		n++;
  800b42:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b45:	39 d0                	cmp    %edx,%eax
  800b47:	74 06                	je     800b4f <strnlen+0x24>
  800b49:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b4d:	75 f3                	jne    800b42 <strnlen+0x17>
		n++;
	return n;
}
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	53                   	push   %ebx
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b60:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b64:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b67:	83 c2 01             	add    $0x1,%edx
  800b6a:	84 c9                	test   %cl,%cl
  800b6c:	75 f2                	jne    800b60 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	53                   	push   %ebx
  800b75:	83 ec 08             	sub    $0x8,%esp
  800b78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b7b:	89 1c 24             	mov    %ebx,(%esp)
  800b7e:	e8 8d ff ff ff       	call   800b10 <strlen>
	strcpy(dst + len, src);
  800b83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b86:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b8a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b8d:	89 04 24             	mov    %eax,(%esp)
  800b90:	e8 bc ff ff ff       	call   800b51 <strcpy>
	return dst;
}
  800b95:	89 d8                	mov    %ebx,%eax
  800b97:	83 c4 08             	add    $0x8,%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bab:	85 f6                	test   %esi,%esi
  800bad:	74 18                	je     800bc7 <strncpy+0x2a>
  800baf:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bb4:	0f b6 1a             	movzbl (%edx),%ebx
  800bb7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bba:	80 3a 01             	cmpb   $0x1,(%edx)
  800bbd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bc0:	83 c1 01             	add    $0x1,%ecx
  800bc3:	39 ce                	cmp    %ecx,%esi
  800bc5:	77 ed                	ja     800bb4 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
  800bd0:	8b 75 08             	mov    0x8(%ebp),%esi
  800bd3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bd9:	89 f0                	mov    %esi,%eax
  800bdb:	85 c9                	test   %ecx,%ecx
  800bdd:	74 23                	je     800c02 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  800bdf:	83 e9 01             	sub    $0x1,%ecx
  800be2:	74 1b                	je     800bff <strlcpy+0x34>
  800be4:	0f b6 1a             	movzbl (%edx),%ebx
  800be7:	84 db                	test   %bl,%bl
  800be9:	74 14                	je     800bff <strlcpy+0x34>
			*dst++ = *src++;
  800beb:	88 18                	mov    %bl,(%eax)
  800bed:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bf0:	83 e9 01             	sub    $0x1,%ecx
  800bf3:	74 0a                	je     800bff <strlcpy+0x34>
			*dst++ = *src++;
  800bf5:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bf8:	0f b6 1a             	movzbl (%edx),%ebx
  800bfb:	84 db                	test   %bl,%bl
  800bfd:	75 ec                	jne    800beb <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  800bff:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c02:	29 f0                	sub    %esi,%eax
}
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c11:	0f b6 01             	movzbl (%ecx),%eax
  800c14:	84 c0                	test   %al,%al
  800c16:	74 15                	je     800c2d <strcmp+0x25>
  800c18:	3a 02                	cmp    (%edx),%al
  800c1a:	75 11                	jne    800c2d <strcmp+0x25>
		p++, q++;
  800c1c:	83 c1 01             	add    $0x1,%ecx
  800c1f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c22:	0f b6 01             	movzbl (%ecx),%eax
  800c25:	84 c0                	test   %al,%al
  800c27:	74 04                	je     800c2d <strcmp+0x25>
  800c29:	3a 02                	cmp    (%edx),%al
  800c2b:	74 ef                	je     800c1c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c2d:	0f b6 c0             	movzbl %al,%eax
  800c30:	0f b6 12             	movzbl (%edx),%edx
  800c33:	29 d0                	sub    %edx,%eax
}
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	53                   	push   %ebx
  800c3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c41:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c44:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c49:	85 d2                	test   %edx,%edx
  800c4b:	74 28                	je     800c75 <strncmp+0x3e>
  800c4d:	0f b6 01             	movzbl (%ecx),%eax
  800c50:	84 c0                	test   %al,%al
  800c52:	74 24                	je     800c78 <strncmp+0x41>
  800c54:	3a 03                	cmp    (%ebx),%al
  800c56:	75 20                	jne    800c78 <strncmp+0x41>
  800c58:	83 ea 01             	sub    $0x1,%edx
  800c5b:	74 13                	je     800c70 <strncmp+0x39>
		n--, p++, q++;
  800c5d:	83 c1 01             	add    $0x1,%ecx
  800c60:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c63:	0f b6 01             	movzbl (%ecx),%eax
  800c66:	84 c0                	test   %al,%al
  800c68:	74 0e                	je     800c78 <strncmp+0x41>
  800c6a:	3a 03                	cmp    (%ebx),%al
  800c6c:	74 ea                	je     800c58 <strncmp+0x21>
  800c6e:	eb 08                	jmp    800c78 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c70:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c75:	5b                   	pop    %ebx
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c78:	0f b6 01             	movzbl (%ecx),%eax
  800c7b:	0f b6 13             	movzbl (%ebx),%edx
  800c7e:	29 d0                	sub    %edx,%eax
  800c80:	eb f3                	jmp    800c75 <strncmp+0x3e>

00800c82 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
  800c88:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c8c:	0f b6 10             	movzbl (%eax),%edx
  800c8f:	84 d2                	test   %dl,%dl
  800c91:	74 20                	je     800cb3 <strchr+0x31>
		if (*s == c)
  800c93:	38 ca                	cmp    %cl,%dl
  800c95:	75 0b                	jne    800ca2 <strchr+0x20>
  800c97:	eb 1f                	jmp    800cb8 <strchr+0x36>
  800c99:	38 ca                	cmp    %cl,%dl
  800c9b:	90                   	nop
  800c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ca0:	74 16                	je     800cb8 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ca2:	83 c0 01             	add    $0x1,%eax
  800ca5:	0f b6 10             	movzbl (%eax),%edx
  800ca8:	84 d2                	test   %dl,%dl
  800caa:	75 ed                	jne    800c99 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800cac:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb1:	eb 05                	jmp    800cb8 <strchr+0x36>
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cc4:	0f b6 10             	movzbl (%eax),%edx
  800cc7:	84 d2                	test   %dl,%dl
  800cc9:	74 14                	je     800cdf <strfind+0x25>
		if (*s == c)
  800ccb:	38 ca                	cmp    %cl,%dl
  800ccd:	75 06                	jne    800cd5 <strfind+0x1b>
  800ccf:	eb 0e                	jmp    800cdf <strfind+0x25>
  800cd1:	38 ca                	cmp    %cl,%dl
  800cd3:	74 0a                	je     800cdf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cd5:	83 c0 01             	add    $0x1,%eax
  800cd8:	0f b6 10             	movzbl (%eax),%edx
  800cdb:	84 d2                	test   %dl,%dl
  800cdd:	75 f2                	jne    800cd1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	89 1c 24             	mov    %ebx,(%esp)
  800cea:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cf2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cfb:	85 c9                	test   %ecx,%ecx
  800cfd:	74 30                	je     800d2f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cff:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d05:	75 25                	jne    800d2c <memset+0x4b>
  800d07:	f6 c1 03             	test   $0x3,%cl
  800d0a:	75 20                	jne    800d2c <memset+0x4b>
		c &= 0xFF;
  800d0c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d0f:	89 d3                	mov    %edx,%ebx
  800d11:	c1 e3 08             	shl    $0x8,%ebx
  800d14:	89 d6                	mov    %edx,%esi
  800d16:	c1 e6 18             	shl    $0x18,%esi
  800d19:	89 d0                	mov    %edx,%eax
  800d1b:	c1 e0 10             	shl    $0x10,%eax
  800d1e:	09 f0                	or     %esi,%eax
  800d20:	09 d0                	or     %edx,%eax
  800d22:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d24:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d27:	fc                   	cld    
  800d28:	f3 ab                	rep stos %eax,%es:(%edi)
  800d2a:	eb 03                	jmp    800d2f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d2c:	fc                   	cld    
  800d2d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d2f:	89 f8                	mov    %edi,%eax
  800d31:	8b 1c 24             	mov    (%esp),%ebx
  800d34:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d38:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d3c:	89 ec                	mov    %ebp,%esp
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 08             	sub    $0x8,%esp
  800d46:	89 34 24             	mov    %esi,(%esp)
  800d49:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d53:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d56:	39 c6                	cmp    %eax,%esi
  800d58:	73 36                	jae    800d90 <memmove+0x50>
  800d5a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d5d:	39 d0                	cmp    %edx,%eax
  800d5f:	73 2f                	jae    800d90 <memmove+0x50>
		s += n;
		d += n;
  800d61:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d64:	f6 c2 03             	test   $0x3,%dl
  800d67:	75 1b                	jne    800d84 <memmove+0x44>
  800d69:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d6f:	75 13                	jne    800d84 <memmove+0x44>
  800d71:	f6 c1 03             	test   $0x3,%cl
  800d74:	75 0e                	jne    800d84 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d76:	83 ef 04             	sub    $0x4,%edi
  800d79:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d7c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d7f:	fd                   	std    
  800d80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d82:	eb 09                	jmp    800d8d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d84:	83 ef 01             	sub    $0x1,%edi
  800d87:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d8a:	fd                   	std    
  800d8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d8d:	fc                   	cld    
  800d8e:	eb 20                	jmp    800db0 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d90:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d96:	75 13                	jne    800dab <memmove+0x6b>
  800d98:	a8 03                	test   $0x3,%al
  800d9a:	75 0f                	jne    800dab <memmove+0x6b>
  800d9c:	f6 c1 03             	test   $0x3,%cl
  800d9f:	75 0a                	jne    800dab <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800da1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800da4:	89 c7                	mov    %eax,%edi
  800da6:	fc                   	cld    
  800da7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800da9:	eb 05                	jmp    800db0 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dab:	89 c7                	mov    %eax,%edi
  800dad:	fc                   	cld    
  800dae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800db0:	8b 34 24             	mov    (%esp),%esi
  800db3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800db7:	89 ec                	mov    %ebp,%esp
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800dc1:	8b 45 10             	mov    0x10(%ebp),%eax
  800dc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd2:	89 04 24             	mov    %eax,(%esp)
  800dd5:	e8 66 ff ff ff       	call   800d40 <memmove>
}
  800dda:	c9                   	leave  
  800ddb:	c3                   	ret    

00800ddc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
  800de2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800de5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de8:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800deb:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800df0:	85 ff                	test   %edi,%edi
  800df2:	74 38                	je     800e2c <memcmp+0x50>
		if (*s1 != *s2)
  800df4:	0f b6 03             	movzbl (%ebx),%eax
  800df7:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dfa:	83 ef 01             	sub    $0x1,%edi
  800dfd:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800e02:	38 c8                	cmp    %cl,%al
  800e04:	74 1d                	je     800e23 <memcmp+0x47>
  800e06:	eb 11                	jmp    800e19 <memcmp+0x3d>
  800e08:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e0d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800e12:	83 c2 01             	add    $0x1,%edx
  800e15:	38 c8                	cmp    %cl,%al
  800e17:	74 0a                	je     800e23 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800e19:	0f b6 c0             	movzbl %al,%eax
  800e1c:	0f b6 c9             	movzbl %cl,%ecx
  800e1f:	29 c8                	sub    %ecx,%eax
  800e21:	eb 09                	jmp    800e2c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e23:	39 fa                	cmp    %edi,%edx
  800e25:	75 e1                	jne    800e08 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e37:	89 c2                	mov    %eax,%edx
  800e39:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e3c:	39 d0                	cmp    %edx,%eax
  800e3e:	73 15                	jae    800e55 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e44:	38 08                	cmp    %cl,(%eax)
  800e46:	75 06                	jne    800e4e <memfind+0x1d>
  800e48:	eb 0b                	jmp    800e55 <memfind+0x24>
  800e4a:	38 08                	cmp    %cl,(%eax)
  800e4c:	74 07                	je     800e55 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e4e:	83 c0 01             	add    $0x1,%eax
  800e51:	39 c2                	cmp    %eax,%edx
  800e53:	77 f5                	ja     800e4a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	57                   	push   %edi
  800e5b:	56                   	push   %esi
  800e5c:	53                   	push   %ebx
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e63:	0f b6 02             	movzbl (%edx),%eax
  800e66:	3c 20                	cmp    $0x20,%al
  800e68:	74 04                	je     800e6e <strtol+0x17>
  800e6a:	3c 09                	cmp    $0x9,%al
  800e6c:	75 0e                	jne    800e7c <strtol+0x25>
		s++;
  800e6e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e71:	0f b6 02             	movzbl (%edx),%eax
  800e74:	3c 20                	cmp    $0x20,%al
  800e76:	74 f6                	je     800e6e <strtol+0x17>
  800e78:	3c 09                	cmp    $0x9,%al
  800e7a:	74 f2                	je     800e6e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e7c:	3c 2b                	cmp    $0x2b,%al
  800e7e:	75 0a                	jne    800e8a <strtol+0x33>
		s++;
  800e80:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e83:	bf 00 00 00 00       	mov    $0x0,%edi
  800e88:	eb 10                	jmp    800e9a <strtol+0x43>
  800e8a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e8f:	3c 2d                	cmp    $0x2d,%al
  800e91:	75 07                	jne    800e9a <strtol+0x43>
		s++, neg = 1;
  800e93:	83 c2 01             	add    $0x1,%edx
  800e96:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e9a:	85 db                	test   %ebx,%ebx
  800e9c:	0f 94 c0             	sete   %al
  800e9f:	74 05                	je     800ea6 <strtol+0x4f>
  800ea1:	83 fb 10             	cmp    $0x10,%ebx
  800ea4:	75 15                	jne    800ebb <strtol+0x64>
  800ea6:	80 3a 30             	cmpb   $0x30,(%edx)
  800ea9:	75 10                	jne    800ebb <strtol+0x64>
  800eab:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800eaf:	75 0a                	jne    800ebb <strtol+0x64>
		s += 2, base = 16;
  800eb1:	83 c2 02             	add    $0x2,%edx
  800eb4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800eb9:	eb 13                	jmp    800ece <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800ebb:	84 c0                	test   %al,%al
  800ebd:	74 0f                	je     800ece <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ebf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ec4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ec7:	75 05                	jne    800ece <strtol+0x77>
		s++, base = 8;
  800ec9:	83 c2 01             	add    $0x1,%edx
  800ecc:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ece:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed3:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ed5:	0f b6 0a             	movzbl (%edx),%ecx
  800ed8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800edb:	80 fb 09             	cmp    $0x9,%bl
  800ede:	77 08                	ja     800ee8 <strtol+0x91>
			dig = *s - '0';
  800ee0:	0f be c9             	movsbl %cl,%ecx
  800ee3:	83 e9 30             	sub    $0x30,%ecx
  800ee6:	eb 1e                	jmp    800f06 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800ee8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800eeb:	80 fb 19             	cmp    $0x19,%bl
  800eee:	77 08                	ja     800ef8 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800ef0:	0f be c9             	movsbl %cl,%ecx
  800ef3:	83 e9 57             	sub    $0x57,%ecx
  800ef6:	eb 0e                	jmp    800f06 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800ef8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800efb:	80 fb 19             	cmp    $0x19,%bl
  800efe:	77 15                	ja     800f15 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800f00:	0f be c9             	movsbl %cl,%ecx
  800f03:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f06:	39 f1                	cmp    %esi,%ecx
  800f08:	7d 0f                	jge    800f19 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800f0a:	83 c2 01             	add    $0x1,%edx
  800f0d:	0f af c6             	imul   %esi,%eax
  800f10:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f13:	eb c0                	jmp    800ed5 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f15:	89 c1                	mov    %eax,%ecx
  800f17:	eb 02                	jmp    800f1b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f19:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f1f:	74 05                	je     800f26 <strtol+0xcf>
		*endptr = (char *) s;
  800f21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f24:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f26:	89 ca                	mov    %ecx,%edx
  800f28:	f7 da                	neg    %edx
  800f2a:	85 ff                	test   %edi,%edi
  800f2c:	0f 45 c2             	cmovne %edx,%eax
}
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    
	...

00800f40 <__udivdi3>:
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	83 ec 10             	sub    $0x10,%esp
  800f48:	8b 75 14             	mov    0x14(%ebp),%esi
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f51:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f54:	85 f6                	test   %esi,%esi
  800f56:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f59:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f5f:	75 2f                	jne    800f90 <__udivdi3+0x50>
  800f61:	39 f9                	cmp    %edi,%ecx
  800f63:	77 5b                	ja     800fc0 <__udivdi3+0x80>
  800f65:	85 c9                	test   %ecx,%ecx
  800f67:	75 0b                	jne    800f74 <__udivdi3+0x34>
  800f69:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6e:	31 d2                	xor    %edx,%edx
  800f70:	f7 f1                	div    %ecx
  800f72:	89 c1                	mov    %eax,%ecx
  800f74:	89 f8                	mov    %edi,%eax
  800f76:	31 d2                	xor    %edx,%edx
  800f78:	f7 f1                	div    %ecx
  800f7a:	89 c7                	mov    %eax,%edi
  800f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f7f:	f7 f1                	div    %ecx
  800f81:	89 fa                	mov    %edi,%edx
  800f83:	83 c4 10             	add    $0x10,%esp
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    
  800f8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f90:	31 d2                	xor    %edx,%edx
  800f92:	31 c0                	xor    %eax,%eax
  800f94:	39 fe                	cmp    %edi,%esi
  800f96:	77 eb                	ja     800f83 <__udivdi3+0x43>
  800f98:	0f bd d6             	bsr    %esi,%edx
  800f9b:	83 f2 1f             	xor    $0x1f,%edx
  800f9e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fa1:	75 2d                	jne    800fd0 <__udivdi3+0x90>
  800fa3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800fa6:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  800fa9:	76 06                	jbe    800fb1 <__udivdi3+0x71>
  800fab:	39 fe                	cmp    %edi,%esi
  800fad:	89 c2                	mov    %eax,%edx
  800faf:	73 d2                	jae    800f83 <__udivdi3+0x43>
  800fb1:	31 d2                	xor    %edx,%edx
  800fb3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb8:	eb c9                	jmp    800f83 <__udivdi3+0x43>
  800fba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc0:	89 fa                	mov    %edi,%edx
  800fc2:	f7 f1                	div    %ecx
  800fc4:	31 d2                	xor    %edx,%edx
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    
  800fcd:	8d 76 00             	lea    0x0(%esi),%esi
  800fd0:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fd4:	b8 20 00 00 00       	mov    $0x20,%eax
  800fd9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fdc:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800fdf:	d3 e6                	shl    %cl,%esi
  800fe1:	89 c1                	mov    %eax,%ecx
  800fe3:	d3 ea                	shr    %cl,%edx
  800fe5:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fe9:	09 f2                	or     %esi,%edx
  800feb:	8b 75 ec             	mov    -0x14(%ebp),%esi
  800fee:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800ff1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ff4:	d3 e2                	shl    %cl,%edx
  800ff6:	89 c1                	mov    %eax,%ecx
  800ff8:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800ffb:	89 fa                	mov    %edi,%edx
  800ffd:	d3 ea                	shr    %cl,%edx
  800fff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801003:	d3 e7                	shl    %cl,%edi
  801005:	89 c1                	mov    %eax,%ecx
  801007:	d3 ee                	shr    %cl,%esi
  801009:	09 fe                	or     %edi,%esi
  80100b:	89 f0                	mov    %esi,%eax
  80100d:	f7 75 e8             	divl   -0x18(%ebp)
  801010:	89 d7                	mov    %edx,%edi
  801012:	89 c6                	mov    %eax,%esi
  801014:	f7 65 f0             	mull   -0x10(%ebp)
  801017:	39 d7                	cmp    %edx,%edi
  801019:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80101c:	72 22                	jb     801040 <__udivdi3+0x100>
  80101e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801021:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801025:	d3 e2                	shl    %cl,%edx
  801027:	39 c2                	cmp    %eax,%edx
  801029:	73 05                	jae    801030 <__udivdi3+0xf0>
  80102b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80102e:	74 10                	je     801040 <__udivdi3+0x100>
  801030:	89 f0                	mov    %esi,%eax
  801032:	31 d2                	xor    %edx,%edx
  801034:	e9 4a ff ff ff       	jmp    800f83 <__udivdi3+0x43>
  801039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801040:	8d 46 ff             	lea    -0x1(%esi),%eax
  801043:	31 d2                	xor    %edx,%edx
  801045:	83 c4 10             	add    $0x10,%esp
  801048:	5e                   	pop    %esi
  801049:	5f                   	pop    %edi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    
  80104c:	00 00                	add    %al,(%eax)
	...

00801050 <__umoddi3>:
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	83 ec 20             	sub    $0x20,%esp
  801058:	8b 7d 14             	mov    0x14(%ebp),%edi
  80105b:	8b 45 08             	mov    0x8(%ebp),%eax
  80105e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801061:	8b 75 0c             	mov    0xc(%ebp),%esi
  801064:	85 ff                	test   %edi,%edi
  801066:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801069:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80106c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80106f:	89 f2                	mov    %esi,%edx
  801071:	75 15                	jne    801088 <__umoddi3+0x38>
  801073:	39 f1                	cmp    %esi,%ecx
  801075:	76 41                	jbe    8010b8 <__umoddi3+0x68>
  801077:	f7 f1                	div    %ecx
  801079:	89 d0                	mov    %edx,%eax
  80107b:	31 d2                	xor    %edx,%edx
  80107d:	83 c4 20             	add    $0x20,%esp
  801080:	5e                   	pop    %esi
  801081:	5f                   	pop    %edi
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    
  801084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801088:	39 f7                	cmp    %esi,%edi
  80108a:	77 4c                	ja     8010d8 <__umoddi3+0x88>
  80108c:	0f bd c7             	bsr    %edi,%eax
  80108f:	83 f0 1f             	xor    $0x1f,%eax
  801092:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801095:	75 51                	jne    8010e8 <__umoddi3+0x98>
  801097:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80109a:	0f 87 e8 00 00 00    	ja     801188 <__umoddi3+0x138>
  8010a0:	89 f2                	mov    %esi,%edx
  8010a2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8010a5:	29 ce                	sub    %ecx,%esi
  8010a7:	19 fa                	sbb    %edi,%edx
  8010a9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8010ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010af:	83 c4 20             	add    $0x20,%esp
  8010b2:	5e                   	pop    %esi
  8010b3:	5f                   	pop    %edi
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    
  8010b6:	66 90                	xchg   %ax,%ax
  8010b8:	85 c9                	test   %ecx,%ecx
  8010ba:	75 0b                	jne    8010c7 <__umoddi3+0x77>
  8010bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c1:	31 d2                	xor    %edx,%edx
  8010c3:	f7 f1                	div    %ecx
  8010c5:	89 c1                	mov    %eax,%ecx
  8010c7:	89 f0                	mov    %esi,%eax
  8010c9:	31 d2                	xor    %edx,%edx
  8010cb:	f7 f1                	div    %ecx
  8010cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d0:	eb a5                	jmp    801077 <__umoddi3+0x27>
  8010d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010d8:	89 f2                	mov    %esi,%edx
  8010da:	83 c4 20             	add    $0x20,%esp
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    
  8010e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010e8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8010ec:	89 f2                	mov    %esi,%edx
  8010ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8010f1:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  8010f8:	29 45 f0             	sub    %eax,-0x10(%ebp)
  8010fb:	d3 e7                	shl    %cl,%edi
  8010fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801100:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801104:	d3 e8                	shr    %cl,%eax
  801106:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80110a:	09 f8                	or     %edi,%eax
  80110c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80110f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801112:	d3 e0                	shl    %cl,%eax
  801114:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801118:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80111b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80111e:	d3 ea                	shr    %cl,%edx
  801120:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801124:	d3 e6                	shl    %cl,%esi
  801126:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80112a:	d3 e8                	shr    %cl,%eax
  80112c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801130:	09 f0                	or     %esi,%eax
  801132:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801135:	f7 75 e4             	divl   -0x1c(%ebp)
  801138:	d3 e6                	shl    %cl,%esi
  80113a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80113d:	89 d6                	mov    %edx,%esi
  80113f:	f7 65 f4             	mull   -0xc(%ebp)
  801142:	89 d7                	mov    %edx,%edi
  801144:	89 c2                	mov    %eax,%edx
  801146:	39 fe                	cmp    %edi,%esi
  801148:	89 f9                	mov    %edi,%ecx
  80114a:	72 30                	jb     80117c <__umoddi3+0x12c>
  80114c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80114f:	72 27                	jb     801178 <__umoddi3+0x128>
  801151:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801154:	29 d0                	sub    %edx,%eax
  801156:	19 ce                	sbb    %ecx,%esi
  801158:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80115c:	89 f2                	mov    %esi,%edx
  80115e:	d3 e8                	shr    %cl,%eax
  801160:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801164:	d3 e2                	shl    %cl,%edx
  801166:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80116a:	09 d0                	or     %edx,%eax
  80116c:	89 f2                	mov    %esi,%edx
  80116e:	d3 ea                	shr    %cl,%edx
  801170:	83 c4 20             	add    $0x20,%esp
  801173:	5e                   	pop    %esi
  801174:	5f                   	pop    %edi
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    
  801177:	90                   	nop
  801178:	39 fe                	cmp    %edi,%esi
  80117a:	75 d5                	jne    801151 <__umoddi3+0x101>
  80117c:	89 f9                	mov    %edi,%ecx
  80117e:	89 c2                	mov    %eax,%edx
  801180:	2b 55 f4             	sub    -0xc(%ebp),%edx
  801183:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801186:	eb c9                	jmp    801151 <__umoddi3+0x101>
  801188:	39 f7                	cmp    %esi,%edi
  80118a:	0f 82 10 ff ff ff    	jb     8010a0 <__umoddi3+0x50>
  801190:	e9 17 ff ff ff       	jmp    8010ac <__umoddi3+0x5c>
