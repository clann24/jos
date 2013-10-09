
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800049:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800052:	e8 11 01 00 00       	call   800168 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 f6                	test   %esi,%esi
  80006b:	7e 07                	jle    800074 <libmain+0x34>
		binaryname = argv[0];
  80006d:	8b 03                	mov    (%ebx),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800078:	89 34 24             	mov    %esi,(%esp)
  80007b:	e8 b4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800080:	e8 0b 00 00 00       	call   800090 <exit>
}
  800085:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800088:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80008b:	89 ec                	mov    %ebp,%esp
  80008d:	5d                   	pop    %ebp
  80008e:	c3                   	ret    
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800096:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009d:	e8 69 00 00 00       	call   80010b <sys_env_destroy>
}
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 0c             	sub    $0xc,%esp
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000b1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c0:	89 c3                	mov    %eax,%ebx
  8000c2:	89 c7                	mov    %eax,%edi
  8000c4:	89 c6                	mov    %eax,%esi
  8000c6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c8:	8b 1c 24             	mov    (%esp),%ebx
  8000cb:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000cf:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000d3:	89 ec                	mov    %ebp,%esp
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	89 1c 24             	mov    %ebx,(%esp)
  8000e0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000e4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f2:	89 d1                	mov    %edx,%ecx
  8000f4:	89 d3                	mov    %edx,%ebx
  8000f6:	89 d7                	mov    %edx,%edi
  8000f8:	89 d6                	mov    %edx,%esi
  8000fa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fc:	8b 1c 24             	mov    (%esp),%ebx
  8000ff:	8b 74 24 04          	mov    0x4(%esp),%esi
  800103:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800107:	89 ec                	mov    %ebp,%esp
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 38             	sub    $0x38,%esp
  800111:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800114:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800117:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011f:	b8 03 00 00 00       	mov    $0x3,%eax
  800124:	8b 55 08             	mov    0x8(%ebp),%edx
  800127:	89 cb                	mov    %ecx,%ebx
  800129:	89 cf                	mov    %ecx,%edi
  80012b:	89 ce                	mov    %ecx,%esi
  80012d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80012f:	85 c0                	test   %eax,%eax
  800131:	7e 28                	jle    80015b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800133:	89 44 24 10          	mov    %eax,0x10(%esp)
  800137:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80013e:	00 
  80013f:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  800146:	00 
  800147:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80014e:	00 
  80014f:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  800156:	e8 e1 02 00 00       	call   80043c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80015e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800161:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800164:	89 ec                	mov    %ebp,%esp
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	89 1c 24             	mov    %ebx,(%esp)
  800171:	89 74 24 04          	mov    %esi,0x4(%esp)
  800175:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	ba 00 00 00 00       	mov    $0x0,%edx
  80017e:	b8 02 00 00 00       	mov    $0x2,%eax
  800183:	89 d1                	mov    %edx,%ecx
  800185:	89 d3                	mov    %edx,%ebx
  800187:	89 d7                	mov    %edx,%edi
  800189:	89 d6                	mov    %edx,%esi
  80018b:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  80018d:	8b 1c 24             	mov    (%esp),%ebx
  800190:	8b 74 24 04          	mov    0x4(%esp),%esi
  800194:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800198:	89 ec                	mov    %ebp,%esp
  80019a:	5d                   	pop    %ebp
  80019b:	c3                   	ret    

0080019c <sys_yield>:

void
sys_yield(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	89 1c 24             	mov    %ebx,(%esp)
  8001a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001b7:	89 d1                	mov    %edx,%ecx
  8001b9:	89 d3                	mov    %edx,%ebx
  8001bb:	89 d7                	mov    %edx,%edi
  8001bd:	89 d6                	mov    %edx,%esi
  8001bf:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001c1:	8b 1c 24             	mov    (%esp),%ebx
  8001c4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001c8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001cc:	89 ec                	mov    %ebp,%esp
  8001ce:	5d                   	pop    %ebp
  8001cf:	c3                   	ret    

008001d0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 38             	sub    $0x38,%esp
  8001d6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001dc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001df:	be 00 00 00 00       	mov    $0x0,%esi
  8001e4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f2:	89 f7                	mov    %esi,%edi
  8001f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7e 28                	jle    800222 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fe:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800205:	00 
  800206:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  80021d:	e8 1a 02 00 00       	call   80043c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800222:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800225:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800228:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80022b:	89 ec                	mov    %ebp,%esp
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	83 ec 38             	sub    $0x38,%esp
  800235:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800238:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80023b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023e:	b8 05 00 00 00       	mov    $0x5,%eax
  800243:	8b 75 18             	mov    0x18(%ebp),%esi
  800246:	8b 7d 14             	mov    0x14(%ebp),%edi
  800249:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80024c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024f:	8b 55 08             	mov    0x8(%ebp),%edx
  800252:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800254:	85 c0                	test   %eax,%eax
  800256:	7e 28                	jle    800280 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800258:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800263:	00 
  800264:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  80026b:	00 
  80026c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800273:	00 
  800274:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  80027b:	e8 bc 01 00 00       	call   80043c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800280:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800283:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800286:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800289:	89 ec                	mov    %ebp,%esp
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 38             	sub    $0x38,%esp
  800293:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800296:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800299:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	b8 06 00 00 00       	mov    $0x6,%eax
  8002a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	89 df                	mov    %ebx,%edi
  8002ae:	89 de                	mov    %ebx,%esi
  8002b0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	7e 28                	jle    8002de <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ba:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  8002c9:	00 
  8002ca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002d1:	00 
  8002d2:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  8002d9:	e8 5e 01 00 00       	call   80043c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002de:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002e1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002e4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002e7:	89 ec                	mov    %ebp,%esp
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	83 ec 38             	sub    $0x38,%esp
  8002f1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002f4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002f7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ff:	b8 08 00 00 00       	mov    $0x8,%eax
  800304:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800307:	8b 55 08             	mov    0x8(%ebp),%edx
  80030a:	89 df                	mov    %ebx,%edi
  80030c:	89 de                	mov    %ebx,%esi
  80030e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800310:	85 c0                	test   %eax,%eax
  800312:	7e 28                	jle    80033c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800314:	89 44 24 10          	mov    %eax,0x10(%esp)
  800318:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80031f:	00 
  800320:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  800327:	00 
  800328:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80032f:	00 
  800330:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  800337:	e8 00 01 00 00       	call   80043c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80033c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80033f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800342:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800345:	89 ec                	mov    %ebp,%esp
  800347:	5d                   	pop    %ebp
  800348:	c3                   	ret    

00800349 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	83 ec 38             	sub    $0x38,%esp
  80034f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800352:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800355:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800358:	bb 00 00 00 00       	mov    $0x0,%ebx
  80035d:	b8 09 00 00 00       	mov    $0x9,%eax
  800362:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800365:	8b 55 08             	mov    0x8(%ebp),%edx
  800368:	89 df                	mov    %ebx,%edi
  80036a:	89 de                	mov    %ebx,%esi
  80036c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80036e:	85 c0                	test   %eax,%eax
  800370:	7e 28                	jle    80039a <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800372:	89 44 24 10          	mov    %eax,0x10(%esp)
  800376:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80037d:	00 
  80037e:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  800385:	00 
  800386:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80038d:	00 
  80038e:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  800395:	e8 a2 00 00 00       	call   80043c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80039a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80039d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003a0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003a3:	89 ec                	mov    %ebp,%esp
  8003a5:	5d                   	pop    %ebp
  8003a6:	c3                   	ret    

008003a7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	83 ec 0c             	sub    $0xc,%esp
  8003ad:	89 1c 24             	mov    %ebx,(%esp)
  8003b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003b4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b8:	be 00 00 00 00       	mov    $0x0,%esi
  8003bd:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ce:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003d0:	8b 1c 24             	mov    (%esp),%ebx
  8003d3:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003d7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003db:	89 ec                	mov    %ebp,%esp
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	83 ec 38             	sub    $0x38,%esp
  8003e5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003e8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003eb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fb:	89 cb                	mov    %ecx,%ebx
  8003fd:	89 cf                	mov    %ecx,%edi
  8003ff:	89 ce                	mov    %ecx,%esi
  800401:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800403:	85 c0                	test   %eax,%eax
  800405:	7e 28                	jle    80042f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800407:	89 44 24 10          	mov    %eax,0x10(%esp)
  80040b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800412:	00 
  800413:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  80041a:	00 
  80041b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800422:	00 
  800423:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  80042a:	e8 0d 00 00 00       	call   80043c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80042f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800432:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800435:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800438:	89 ec                	mov    %ebp,%esp
  80043a:	5d                   	pop    %ebp
  80043b:	c3                   	ret    

0080043c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	56                   	push   %esi
  800440:	53                   	push   %ebx
  800441:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800444:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800447:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80044d:	e8 16 fd ff ff       	call   800168 <sys_getenvid>
  800452:	8b 55 0c             	mov    0xc(%ebp),%edx
  800455:	89 54 24 10          	mov    %edx,0x10(%esp)
  800459:	8b 55 08             	mov    0x8(%ebp),%edx
  80045c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800460:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800464:	89 44 24 04          	mov    %eax,0x4(%esp)
  800468:	c7 04 24 f8 11 80 00 	movl   $0x8011f8,(%esp)
  80046f:	e8 c3 00 00 00       	call   800537 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800474:	89 74 24 04          	mov    %esi,0x4(%esp)
  800478:	8b 45 10             	mov    0x10(%ebp),%eax
  80047b:	89 04 24             	mov    %eax,(%esp)
  80047e:	e8 53 00 00 00       	call   8004d6 <vcprintf>
	cprintf("\n");
  800483:	c7 04 24 1c 12 80 00 	movl   $0x80121c,(%esp)
  80048a:	e8 a8 00 00 00       	call   800537 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80048f:	cc                   	int3   
  800490:	eb fd                	jmp    80048f <_panic+0x53>
	...

00800494 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	53                   	push   %ebx
  800498:	83 ec 14             	sub    $0x14,%esp
  80049b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80049e:	8b 03                	mov    (%ebx),%eax
  8004a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004a7:	83 c0 01             	add    $0x1,%eax
  8004aa:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004b1:	75 19                	jne    8004cc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004b3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004ba:	00 
  8004bb:	8d 43 08             	lea    0x8(%ebx),%eax
  8004be:	89 04 24             	mov    %eax,(%esp)
  8004c1:	e8 de fb ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  8004c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004d0:	83 c4 14             	add    $0x14,%esp
  8004d3:	5b                   	pop    %ebx
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e6:	00 00 00 
	b.cnt = 0;
  8004e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800501:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050b:	c7 04 24 94 04 80 00 	movl   $0x800494,(%esp)
  800512:	e8 ea 01 00 00       	call   800701 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800517:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80051d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800521:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800527:	89 04 24             	mov    %eax,(%esp)
  80052a:	e8 75 fb ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  80052f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80053d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800540:	89 44 24 04          	mov    %eax,0x4(%esp)
  800544:	8b 45 08             	mov    0x8(%ebp),%eax
  800547:	89 04 24             	mov    %eax,(%esp)
  80054a:	e8 87 ff ff ff       	call   8004d6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80054f:	c9                   	leave  
  800550:	c3                   	ret    
	...

00800560 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	57                   	push   %edi
  800564:	56                   	push   %esi
  800565:	53                   	push   %ebx
  800566:	83 ec 4c             	sub    $0x4c,%esp
  800569:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056c:	89 d6                	mov    %edx,%esi
  80056e:	8b 45 08             	mov    0x8(%ebp),%eax
  800571:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800574:	8b 55 0c             	mov    0xc(%ebp),%edx
  800577:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80057a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80057d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800580:	b8 00 00 00 00       	mov    $0x0,%eax
  800585:	39 d0                	cmp    %edx,%eax
  800587:	72 11                	jb     80059a <printnum+0x3a>
  800589:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80058c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  80058f:	76 09                	jbe    80059a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800591:	83 eb 01             	sub    $0x1,%ebx
  800594:	85 db                	test   %ebx,%ebx
  800596:	7f 5d                	jg     8005f5 <printnum+0x95>
  800598:	eb 6c                	jmp    800606 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80059a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80059e:	83 eb 01             	sub    $0x1,%ebx
  8005a1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005ac:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005b0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8005b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005b7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005c1:	00 
  8005c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005c5:	89 14 24             	mov    %edx,(%esp)
  8005c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005cf:	e8 7c 09 00 00       	call   800f50 <__udivdi3>
  8005d4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005de:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005e2:	89 04 24             	mov    %eax,(%esp)
  8005e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005e9:	89 f2                	mov    %esi,%edx
  8005eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ee:	e8 6d ff ff ff       	call   800560 <printnum>
  8005f3:	eb 11                	jmp    800606 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f9:	89 3c 24             	mov    %edi,(%esp)
  8005fc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005ff:	83 eb 01             	sub    $0x1,%ebx
  800602:	85 db                	test   %ebx,%ebx
  800604:	7f ef                	jg     8005f5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800606:	89 74 24 04          	mov    %esi,0x4(%esp)
  80060a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80060e:	8b 45 10             	mov    0x10(%ebp),%eax
  800611:	89 44 24 08          	mov    %eax,0x8(%esp)
  800615:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80061c:	00 
  80061d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800620:	89 14 24             	mov    %edx,(%esp)
  800623:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800626:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80062a:	e8 31 0a 00 00       	call   801060 <__umoddi3>
  80062f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800633:	0f be 80 1e 12 80 00 	movsbl 0x80121e(%eax),%eax
  80063a:	89 04 24             	mov    %eax,(%esp)
  80063d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800640:	83 c4 4c             	add    $0x4c,%esp
  800643:	5b                   	pop    %ebx
  800644:	5e                   	pop    %esi
  800645:	5f                   	pop    %edi
  800646:	5d                   	pop    %ebp
  800647:	c3                   	ret    

00800648 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800648:	55                   	push   %ebp
  800649:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80064b:	83 fa 01             	cmp    $0x1,%edx
  80064e:	7e 0e                	jle    80065e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800650:	8b 10                	mov    (%eax),%edx
  800652:	8d 4a 08             	lea    0x8(%edx),%ecx
  800655:	89 08                	mov    %ecx,(%eax)
  800657:	8b 02                	mov    (%edx),%eax
  800659:	8b 52 04             	mov    0x4(%edx),%edx
  80065c:	eb 22                	jmp    800680 <getuint+0x38>
	else if (lflag)
  80065e:	85 d2                	test   %edx,%edx
  800660:	74 10                	je     800672 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800662:	8b 10                	mov    (%eax),%edx
  800664:	8d 4a 04             	lea    0x4(%edx),%ecx
  800667:	89 08                	mov    %ecx,(%eax)
  800669:	8b 02                	mov    (%edx),%eax
  80066b:	ba 00 00 00 00       	mov    $0x0,%edx
  800670:	eb 0e                	jmp    800680 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8d 4a 04             	lea    0x4(%edx),%ecx
  800677:	89 08                	mov    %ecx,(%eax)
  800679:	8b 02                	mov    (%edx),%eax
  80067b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800680:	5d                   	pop    %ebp
  800681:	c3                   	ret    

00800682 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800685:	83 fa 01             	cmp    $0x1,%edx
  800688:	7e 0e                	jle    800698 <getint+0x16>
		return va_arg(*ap, long long);
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80068f:	89 08                	mov    %ecx,(%eax)
  800691:	8b 02                	mov    (%edx),%eax
  800693:	8b 52 04             	mov    0x4(%edx),%edx
  800696:	eb 22                	jmp    8006ba <getint+0x38>
	else if (lflag)
  800698:	85 d2                	test   %edx,%edx
  80069a:	74 10                	je     8006ac <getint+0x2a>
		return va_arg(*ap, long);
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a1:	89 08                	mov    %ecx,(%eax)
  8006a3:	8b 02                	mov    (%edx),%eax
  8006a5:	89 c2                	mov    %eax,%edx
  8006a7:	c1 fa 1f             	sar    $0x1f,%edx
  8006aa:	eb 0e                	jmp    8006ba <getint+0x38>
	else
		return va_arg(*ap, int);
  8006ac:	8b 10                	mov    (%eax),%edx
  8006ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006b1:	89 08                	mov    %ecx,(%eax)
  8006b3:	8b 02                	mov    (%edx),%eax
  8006b5:	89 c2                	mov    %eax,%edx
  8006b7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8006ba:	5d                   	pop    %ebp
  8006bb:	c3                   	ret    

008006bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c6:	8b 10                	mov    (%eax),%edx
  8006c8:	3b 50 04             	cmp    0x4(%eax),%edx
  8006cb:	73 0a                	jae    8006d7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d0:	88 0a                	mov    %cl,(%edx)
  8006d2:	83 c2 01             	add    $0x1,%edx
  8006d5:	89 10                	mov    %edx,(%eax)
}
  8006d7:	5d                   	pop    %ebp
  8006d8:	c3                   	ret    

008006d9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	89 04 24             	mov    %eax,(%esp)
  8006fa:	e8 02 00 00 00       	call   800701 <vprintfmt>
	va_end(ap);
}
  8006ff:	c9                   	leave  
  800700:	c3                   	ret    

00800701 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	57                   	push   %edi
  800705:	56                   	push   %esi
  800706:	53                   	push   %ebx
  800707:	83 ec 4c             	sub    $0x4c,%esp
  80070a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80070d:	eb 23                	jmp    800732 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80070f:	85 c0                	test   %eax,%eax
  800711:	75 12                	jne    800725 <vprintfmt+0x24>
				csa = 0x0700;
  800713:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80071a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80071d:	83 c4 4c             	add    $0x4c,%esp
  800720:	5b                   	pop    %ebx
  800721:	5e                   	pop    %esi
  800722:	5f                   	pop    %edi
  800723:	5d                   	pop    %ebp
  800724:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800725:	8b 55 0c             	mov    0xc(%ebp),%edx
  800728:	89 54 24 04          	mov    %edx,0x4(%esp)
  80072c:	89 04 24             	mov    %eax,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800732:	0f b6 07             	movzbl (%edi),%eax
  800735:	83 c7 01             	add    $0x1,%edi
  800738:	83 f8 25             	cmp    $0x25,%eax
  80073b:	75 d2                	jne    80070f <vprintfmt+0xe>
  80073d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800741:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800748:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80074d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800754:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800759:	be 00 00 00 00       	mov    $0x0,%esi
  80075e:	eb 14                	jmp    800774 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800760:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800764:	eb 0e                	jmp    800774 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800766:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80076a:	eb 08                	jmp    800774 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80076c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80076f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800774:	0f b6 07             	movzbl (%edi),%eax
  800777:	0f b6 c8             	movzbl %al,%ecx
  80077a:	83 c7 01             	add    $0x1,%edi
  80077d:	83 e8 23             	sub    $0x23,%eax
  800780:	3c 55                	cmp    $0x55,%al
  800782:	0f 87 ed 02 00 00    	ja     800a75 <vprintfmt+0x374>
  800788:	0f b6 c0             	movzbl %al,%eax
  80078b:	ff 24 85 e0 12 80 00 	jmp    *0x8012e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800792:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  800795:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800798:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80079b:	83 f9 09             	cmp    $0x9,%ecx
  80079e:	77 3c                	ja     8007dc <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007a0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8007a3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8007a6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8007aa:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8007ad:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007b0:	83 f9 09             	cmp    $0x9,%ecx
  8007b3:	76 eb                	jbe    8007a0 <vprintfmt+0x9f>
  8007b5:	eb 25                	jmp    8007dc <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8d 48 04             	lea    0x4(%eax),%ecx
  8007bd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007c0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  8007c2:	eb 18                	jmp    8007dc <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  8007c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007cb:	0f 48 c6             	cmovs  %esi,%eax
  8007ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d1:	eb a1                	jmp    800774 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  8007d3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8007da:	eb 98                	jmp    800774 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  8007dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007e0:	79 92                	jns    800774 <vprintfmt+0x73>
  8007e2:	eb 88                	jmp    80076c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e4:	83 c2 01             	add    $0x1,%edx
  8007e7:	eb 8b                	jmp    800774 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8d 50 04             	lea    0x4(%eax),%edx
  8007ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007f9:	8b 00                	mov    (%eax),%eax
  8007fb:	89 04 24             	mov    %eax,(%esp)
  8007fe:	ff 55 08             	call   *0x8(%ebp)
			break;
  800801:	e9 2c ff ff ff       	jmp    800732 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8d 50 04             	lea    0x4(%eax),%edx
  80080c:	89 55 14             	mov    %edx,0x14(%ebp)
  80080f:	8b 00                	mov    (%eax),%eax
  800811:	89 c2                	mov    %eax,%edx
  800813:	c1 fa 1f             	sar    $0x1f,%edx
  800816:	31 d0                	xor    %edx,%eax
  800818:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80081a:	83 f8 08             	cmp    $0x8,%eax
  80081d:	7f 0b                	jg     80082a <vprintfmt+0x129>
  80081f:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  800826:	85 d2                	test   %edx,%edx
  800828:	75 23                	jne    80084d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80082a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082e:	c7 44 24 08 36 12 80 	movl   $0x801236,0x8(%esp)
  800835:	00 
  800836:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800839:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80083d:	8b 45 08             	mov    0x8(%ebp),%eax
  800840:	89 04 24             	mov    %eax,(%esp)
  800843:	e8 91 fe ff ff       	call   8006d9 <printfmt>
  800848:	e9 e5 fe ff ff       	jmp    800732 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80084d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800851:	c7 44 24 08 3f 12 80 	movl   $0x80123f,0x8(%esp)
  800858:	00 
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800860:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800863:	89 1c 24             	mov    %ebx,(%esp)
  800866:	e8 6e fe ff ff       	call   8006d9 <printfmt>
  80086b:	e9 c2 fe ff ff       	jmp    800732 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800870:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800873:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800876:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800879:	8b 45 14             	mov    0x14(%ebp),%eax
  80087c:	8d 50 04             	lea    0x4(%eax),%edx
  80087f:	89 55 14             	mov    %edx,0x14(%ebp)
  800882:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800884:	85 f6                	test   %esi,%esi
  800886:	ba 2f 12 80 00       	mov    $0x80122f,%edx
  80088b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80088e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800892:	7e 06                	jle    80089a <vprintfmt+0x199>
  800894:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800898:	75 13                	jne    8008ad <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80089a:	0f be 06             	movsbl (%esi),%eax
  80089d:	83 c6 01             	add    $0x1,%esi
  8008a0:	85 c0                	test   %eax,%eax
  8008a2:	0f 85 a2 00 00 00    	jne    80094a <vprintfmt+0x249>
  8008a8:	e9 92 00 00 00       	jmp    80093f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b1:	89 34 24             	mov    %esi,(%esp)
  8008b4:	e8 82 02 00 00       	call   800b3b <strnlen>
  8008b9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008bc:	29 c2                	sub    %eax,%edx
  8008be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008c1:	85 d2                	test   %edx,%edx
  8008c3:	7e d5                	jle    80089a <vprintfmt+0x199>
					putch(padc, putdat);
  8008c5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8008c9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008cc:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8008cf:	89 d3                	mov    %edx,%ebx
  8008d1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8008d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008d7:	89 c6                	mov    %eax,%esi
  8008d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008dd:	89 34 24             	mov    %esi,(%esp)
  8008e0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008e3:	83 eb 01             	sub    $0x1,%ebx
  8008e6:	85 db                	test   %ebx,%ebx
  8008e8:	7f ef                	jg     8008d9 <vprintfmt+0x1d8>
  8008ea:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8008ed:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8008fa:	eb 9e                	jmp    80089a <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800900:	74 1b                	je     80091d <vprintfmt+0x21c>
  800902:	8d 50 e0             	lea    -0x20(%eax),%edx
  800905:	83 fa 5e             	cmp    $0x5e,%edx
  800908:	76 13                	jbe    80091d <vprintfmt+0x21c>
					putch('?', putdat);
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800911:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800918:	ff 55 08             	call   *0x8(%ebp)
  80091b:	eb 0d                	jmp    80092a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80091d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800920:	89 54 24 04          	mov    %edx,0x4(%esp)
  800924:	89 04 24             	mov    %eax,(%esp)
  800927:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80092a:	83 ef 01             	sub    $0x1,%edi
  80092d:	0f be 06             	movsbl (%esi),%eax
  800930:	85 c0                	test   %eax,%eax
  800932:	74 05                	je     800939 <vprintfmt+0x238>
  800934:	83 c6 01             	add    $0x1,%esi
  800937:	eb 17                	jmp    800950 <vprintfmt+0x24f>
  800939:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80093c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80093f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800943:	7f 1c                	jg     800961 <vprintfmt+0x260>
  800945:	e9 e8 fd ff ff       	jmp    800732 <vprintfmt+0x31>
  80094a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80094d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800950:	85 db                	test   %ebx,%ebx
  800952:	78 a8                	js     8008fc <vprintfmt+0x1fb>
  800954:	83 eb 01             	sub    $0x1,%ebx
  800957:	79 a3                	jns    8008fc <vprintfmt+0x1fb>
  800959:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80095c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80095f:	eb de                	jmp    80093f <vprintfmt+0x23e>
  800961:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800964:	8b 7d 08             	mov    0x8(%ebp),%edi
  800967:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80096a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80096e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800975:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800977:	83 eb 01             	sub    $0x1,%ebx
  80097a:	85 db                	test   %ebx,%ebx
  80097c:	7f ec                	jg     80096a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800981:	e9 ac fd ff ff       	jmp    800732 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800986:	8d 45 14             	lea    0x14(%ebp),%eax
  800989:	e8 f4 fc ff ff       	call   800682 <getint>
  80098e:	89 c3                	mov    %eax,%ebx
  800990:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800992:	85 d2                	test   %edx,%edx
  800994:	78 0a                	js     8009a0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800996:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80099b:	e9 87 00 00 00       	jmp    800a27 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009ae:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009b1:	89 d8                	mov    %ebx,%eax
  8009b3:	89 f2                	mov    %esi,%edx
  8009b5:	f7 d8                	neg    %eax
  8009b7:	83 d2 00             	adc    $0x0,%edx
  8009ba:	f7 da                	neg    %edx
			}
			base = 10;
  8009bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009c1:	eb 64                	jmp    800a27 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c6:	e8 7d fc ff ff       	call   800648 <getuint>
			base = 10;
  8009cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8009d0:	eb 55                	jmp    800a27 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8009d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d5:	e8 6e fc ff ff       	call   800648 <getuint>
      base = 8;
  8009da:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8009df:	eb 46                	jmp    800a27 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  8009e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009e8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009ef:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f9:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a00:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a03:	8b 45 14             	mov    0x14(%ebp),%eax
  800a06:	8d 50 04             	lea    0x4(%eax),%edx
  800a09:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a0c:	8b 00                	mov    (%eax),%eax
  800a0e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a13:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a18:	eb 0d                	jmp    800a27 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a1a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a1d:	e8 26 fc ff ff       	call   800648 <getuint>
			base = 16;
  800a22:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a27:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800a2b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800a2f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a32:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a36:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a3a:	89 04 24             	mov    %eax,(%esp)
  800a3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	e8 14 fb ff ff       	call   800560 <printnum>
			break;
  800a4c:	e9 e1 fc ff ff       	jmp    800732 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a58:	89 0c 24             	mov    %ecx,(%esp)
  800a5b:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a5e:	e9 cf fc ff ff       	jmp    800732 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800a63:	8d 45 14             	lea    0x14(%ebp),%eax
  800a66:	e8 17 fc ff ff       	call   800682 <getint>
			csa = num;
  800a6b:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  800a70:	e9 bd fc ff ff       	jmp    800732 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a78:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a7c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a83:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a86:	83 ef 01             	sub    $0x1,%edi
  800a89:	eb 02                	jmp    800a8d <vprintfmt+0x38c>
  800a8b:	89 c7                	mov    %eax,%edi
  800a8d:	8d 47 ff             	lea    -0x1(%edi),%eax
  800a90:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a94:	75 f5                	jne    800a8b <vprintfmt+0x38a>
  800a96:	e9 97 fc ff ff       	jmp    800732 <vprintfmt+0x31>

00800a9b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	83 ec 28             	sub    $0x28,%esp
  800aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aa7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aaa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800aae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ab8:	85 c0                	test   %eax,%eax
  800aba:	74 30                	je     800aec <vsnprintf+0x51>
  800abc:	85 d2                	test   %edx,%edx
  800abe:	7e 2c                	jle    800aec <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ac7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ace:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad5:	c7 04 24 bc 06 80 00 	movl   $0x8006bc,(%esp)
  800adc:	e8 20 fc ff ff       	call   800701 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ae1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ae4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aea:	eb 05                	jmp    800af1 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800aec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800af9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800afc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b00:	8b 45 10             	mov    0x10(%ebp),%eax
  800b03:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	89 04 24             	mov    %eax,(%esp)
  800b14:	e8 82 ff ff ff       	call   800a9b <vsnprintf>
	va_end(ap);

	return rc;
}
  800b19:	c9                   	leave  
  800b1a:	c3                   	ret    
  800b1b:	00 00                	add    %al,(%eax)
  800b1d:	00 00                	add    %al,(%eax)
	...

00800b20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b2e:	74 09                	je     800b39 <strlen+0x19>
		n++;
  800b30:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b33:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b37:	75 f7                	jne    800b30 <strlen+0x10>
		n++;
	return n;
}
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b41:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b44:	b8 00 00 00 00       	mov    $0x0,%eax
  800b49:	85 d2                	test   %edx,%edx
  800b4b:	74 12                	je     800b5f <strnlen+0x24>
  800b4d:	80 39 00             	cmpb   $0x0,(%ecx)
  800b50:	74 0d                	je     800b5f <strnlen+0x24>
		n++;
  800b52:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b55:	39 d0                	cmp    %edx,%eax
  800b57:	74 06                	je     800b5f <strnlen+0x24>
  800b59:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b5d:	75 f3                	jne    800b52 <strnlen+0x17>
		n++;
	return n;
}
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	53                   	push   %ebx
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b70:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b74:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b77:	83 c2 01             	add    $0x1,%edx
  800b7a:	84 c9                	test   %cl,%cl
  800b7c:	75 f2                	jne    800b70 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	53                   	push   %ebx
  800b85:	83 ec 08             	sub    $0x8,%esp
  800b88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b8b:	89 1c 24             	mov    %ebx,(%esp)
  800b8e:	e8 8d ff ff ff       	call   800b20 <strlen>
	strcpy(dst + len, src);
  800b93:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b96:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b9a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b9d:	89 04 24             	mov    %eax,(%esp)
  800ba0:	e8 bc ff ff ff       	call   800b61 <strcpy>
	return dst;
}
  800ba5:	89 d8                	mov    %ebx,%eax
  800ba7:	83 c4 08             	add    $0x8,%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bbb:	85 f6                	test   %esi,%esi
  800bbd:	74 18                	je     800bd7 <strncpy+0x2a>
  800bbf:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bc4:	0f b6 1a             	movzbl (%edx),%ebx
  800bc7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bca:	80 3a 01             	cmpb   $0x1,(%edx)
  800bcd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	39 ce                	cmp    %ecx,%esi
  800bd5:	77 ed                	ja     800bc4 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	8b 75 08             	mov    0x8(%ebp),%esi
  800be3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800be9:	89 f0                	mov    %esi,%eax
  800beb:	85 c9                	test   %ecx,%ecx
  800bed:	74 23                	je     800c12 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  800bef:	83 e9 01             	sub    $0x1,%ecx
  800bf2:	74 1b                	je     800c0f <strlcpy+0x34>
  800bf4:	0f b6 1a             	movzbl (%edx),%ebx
  800bf7:	84 db                	test   %bl,%bl
  800bf9:	74 14                	je     800c0f <strlcpy+0x34>
			*dst++ = *src++;
  800bfb:	88 18                	mov    %bl,(%eax)
  800bfd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c00:	83 e9 01             	sub    $0x1,%ecx
  800c03:	74 0a                	je     800c0f <strlcpy+0x34>
			*dst++ = *src++;
  800c05:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c08:	0f b6 1a             	movzbl (%edx),%ebx
  800c0b:	84 db                	test   %bl,%bl
  800c0d:	75 ec                	jne    800bfb <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  800c0f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c12:	29 f0                	sub    %esi,%eax
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c21:	0f b6 01             	movzbl (%ecx),%eax
  800c24:	84 c0                	test   %al,%al
  800c26:	74 15                	je     800c3d <strcmp+0x25>
  800c28:	3a 02                	cmp    (%edx),%al
  800c2a:	75 11                	jne    800c3d <strcmp+0x25>
		p++, q++;
  800c2c:	83 c1 01             	add    $0x1,%ecx
  800c2f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c32:	0f b6 01             	movzbl (%ecx),%eax
  800c35:	84 c0                	test   %al,%al
  800c37:	74 04                	je     800c3d <strcmp+0x25>
  800c39:	3a 02                	cmp    (%edx),%al
  800c3b:	74 ef                	je     800c2c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c3d:	0f b6 c0             	movzbl %al,%eax
  800c40:	0f b6 12             	movzbl (%edx),%edx
  800c43:	29 d0                	sub    %edx,%eax
}
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	53                   	push   %ebx
  800c4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c51:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c54:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c59:	85 d2                	test   %edx,%edx
  800c5b:	74 28                	je     800c85 <strncmp+0x3e>
  800c5d:	0f b6 01             	movzbl (%ecx),%eax
  800c60:	84 c0                	test   %al,%al
  800c62:	74 24                	je     800c88 <strncmp+0x41>
  800c64:	3a 03                	cmp    (%ebx),%al
  800c66:	75 20                	jne    800c88 <strncmp+0x41>
  800c68:	83 ea 01             	sub    $0x1,%edx
  800c6b:	74 13                	je     800c80 <strncmp+0x39>
		n--, p++, q++;
  800c6d:	83 c1 01             	add    $0x1,%ecx
  800c70:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c73:	0f b6 01             	movzbl (%ecx),%eax
  800c76:	84 c0                	test   %al,%al
  800c78:	74 0e                	je     800c88 <strncmp+0x41>
  800c7a:	3a 03                	cmp    (%ebx),%al
  800c7c:	74 ea                	je     800c68 <strncmp+0x21>
  800c7e:	eb 08                	jmp    800c88 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c80:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c85:	5b                   	pop    %ebx
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c88:	0f b6 01             	movzbl (%ecx),%eax
  800c8b:	0f b6 13             	movzbl (%ebx),%edx
  800c8e:	29 d0                	sub    %edx,%eax
  800c90:	eb f3                	jmp    800c85 <strncmp+0x3e>

00800c92 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	8b 45 08             	mov    0x8(%ebp),%eax
  800c98:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c9c:	0f b6 10             	movzbl (%eax),%edx
  800c9f:	84 d2                	test   %dl,%dl
  800ca1:	74 20                	je     800cc3 <strchr+0x31>
		if (*s == c)
  800ca3:	38 ca                	cmp    %cl,%dl
  800ca5:	75 0b                	jne    800cb2 <strchr+0x20>
  800ca7:	eb 1f                	jmp    800cc8 <strchr+0x36>
  800ca9:	38 ca                	cmp    %cl,%dl
  800cab:	90                   	nop
  800cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb0:	74 16                	je     800cc8 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cb2:	83 c0 01             	add    $0x1,%eax
  800cb5:	0f b6 10             	movzbl (%eax),%edx
  800cb8:	84 d2                	test   %dl,%dl
  800cba:	75 ed                	jne    800ca9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800cbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc1:	eb 05                	jmp    800cc8 <strchr+0x36>
  800cc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd4:	0f b6 10             	movzbl (%eax),%edx
  800cd7:	84 d2                	test   %dl,%dl
  800cd9:	74 14                	je     800cef <strfind+0x25>
		if (*s == c)
  800cdb:	38 ca                	cmp    %cl,%dl
  800cdd:	75 06                	jne    800ce5 <strfind+0x1b>
  800cdf:	eb 0e                	jmp    800cef <strfind+0x25>
  800ce1:	38 ca                	cmp    %cl,%dl
  800ce3:	74 0a                	je     800cef <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ce5:	83 c0 01             	add    $0x1,%eax
  800ce8:	0f b6 10             	movzbl (%eax),%edx
  800ceb:	84 d2                	test   %dl,%dl
  800ced:	75 f2                	jne    800ce1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	89 1c 24             	mov    %ebx,(%esp)
  800cfa:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cfe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d02:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d0b:	85 c9                	test   %ecx,%ecx
  800d0d:	74 30                	je     800d3f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d15:	75 25                	jne    800d3c <memset+0x4b>
  800d17:	f6 c1 03             	test   $0x3,%cl
  800d1a:	75 20                	jne    800d3c <memset+0x4b>
		c &= 0xFF;
  800d1c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d1f:	89 d3                	mov    %edx,%ebx
  800d21:	c1 e3 08             	shl    $0x8,%ebx
  800d24:	89 d6                	mov    %edx,%esi
  800d26:	c1 e6 18             	shl    $0x18,%esi
  800d29:	89 d0                	mov    %edx,%eax
  800d2b:	c1 e0 10             	shl    $0x10,%eax
  800d2e:	09 f0                	or     %esi,%eax
  800d30:	09 d0                	or     %edx,%eax
  800d32:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d34:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d37:	fc                   	cld    
  800d38:	f3 ab                	rep stos %eax,%es:(%edi)
  800d3a:	eb 03                	jmp    800d3f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d3c:	fc                   	cld    
  800d3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d3f:	89 f8                	mov    %edi,%eax
  800d41:	8b 1c 24             	mov    (%esp),%ebx
  800d44:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d48:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d4c:	89 ec                	mov    %ebp,%esp
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	83 ec 08             	sub    $0x8,%esp
  800d56:	89 34 24             	mov    %esi,(%esp)
  800d59:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d63:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d66:	39 c6                	cmp    %eax,%esi
  800d68:	73 36                	jae    800da0 <memmove+0x50>
  800d6a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d6d:	39 d0                	cmp    %edx,%eax
  800d6f:	73 2f                	jae    800da0 <memmove+0x50>
		s += n;
		d += n;
  800d71:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d74:	f6 c2 03             	test   $0x3,%dl
  800d77:	75 1b                	jne    800d94 <memmove+0x44>
  800d79:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d7f:	75 13                	jne    800d94 <memmove+0x44>
  800d81:	f6 c1 03             	test   $0x3,%cl
  800d84:	75 0e                	jne    800d94 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d86:	83 ef 04             	sub    $0x4,%edi
  800d89:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d8c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d8f:	fd                   	std    
  800d90:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d92:	eb 09                	jmp    800d9d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d94:	83 ef 01             	sub    $0x1,%edi
  800d97:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d9a:	fd                   	std    
  800d9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d9d:	fc                   	cld    
  800d9e:	eb 20                	jmp    800dc0 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800da0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800da6:	75 13                	jne    800dbb <memmove+0x6b>
  800da8:	a8 03                	test   $0x3,%al
  800daa:	75 0f                	jne    800dbb <memmove+0x6b>
  800dac:	f6 c1 03             	test   $0x3,%cl
  800daf:	75 0a                	jne    800dbb <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800db1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800db4:	89 c7                	mov    %eax,%edi
  800db6:	fc                   	cld    
  800db7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800db9:	eb 05                	jmp    800dc0 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dbb:	89 c7                	mov    %eax,%edi
  800dbd:	fc                   	cld    
  800dbe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dc0:	8b 34 24             	mov    (%esp),%esi
  800dc3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dc7:	89 ec                	mov    %ebp,%esp
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800dd1:	8b 45 10             	mov    0x10(%ebp),%eax
  800dd4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	89 04 24             	mov    %eax,(%esp)
  800de5:	e8 66 ff ff ff       	call   800d50 <memmove>
}
  800dea:	c9                   	leave  
  800deb:	c3                   	ret    

00800dec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
  800df2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800df5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800df8:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dfb:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e00:	85 ff                	test   %edi,%edi
  800e02:	74 38                	je     800e3c <memcmp+0x50>
		if (*s1 != *s2)
  800e04:	0f b6 03             	movzbl (%ebx),%eax
  800e07:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e0a:	83 ef 01             	sub    $0x1,%edi
  800e0d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800e12:	38 c8                	cmp    %cl,%al
  800e14:	74 1d                	je     800e33 <memcmp+0x47>
  800e16:	eb 11                	jmp    800e29 <memcmp+0x3d>
  800e18:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e1d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800e22:	83 c2 01             	add    $0x1,%edx
  800e25:	38 c8                	cmp    %cl,%al
  800e27:	74 0a                	je     800e33 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800e29:	0f b6 c0             	movzbl %al,%eax
  800e2c:	0f b6 c9             	movzbl %cl,%ecx
  800e2f:	29 c8                	sub    %ecx,%eax
  800e31:	eb 09                	jmp    800e3c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e33:	39 fa                	cmp    %edi,%edx
  800e35:	75 e1                	jne    800e18 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e47:	89 c2                	mov    %eax,%edx
  800e49:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e4c:	39 d0                	cmp    %edx,%eax
  800e4e:	73 15                	jae    800e65 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e54:	38 08                	cmp    %cl,(%eax)
  800e56:	75 06                	jne    800e5e <memfind+0x1d>
  800e58:	eb 0b                	jmp    800e65 <memfind+0x24>
  800e5a:	38 08                	cmp    %cl,(%eax)
  800e5c:	74 07                	je     800e65 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e5e:	83 c0 01             	add    $0x1,%eax
  800e61:	39 c2                	cmp    %eax,%edx
  800e63:	77 f5                	ja     800e5a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e73:	0f b6 02             	movzbl (%edx),%eax
  800e76:	3c 20                	cmp    $0x20,%al
  800e78:	74 04                	je     800e7e <strtol+0x17>
  800e7a:	3c 09                	cmp    $0x9,%al
  800e7c:	75 0e                	jne    800e8c <strtol+0x25>
		s++;
  800e7e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e81:	0f b6 02             	movzbl (%edx),%eax
  800e84:	3c 20                	cmp    $0x20,%al
  800e86:	74 f6                	je     800e7e <strtol+0x17>
  800e88:	3c 09                	cmp    $0x9,%al
  800e8a:	74 f2                	je     800e7e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e8c:	3c 2b                	cmp    $0x2b,%al
  800e8e:	75 0a                	jne    800e9a <strtol+0x33>
		s++;
  800e90:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e93:	bf 00 00 00 00       	mov    $0x0,%edi
  800e98:	eb 10                	jmp    800eaa <strtol+0x43>
  800e9a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e9f:	3c 2d                	cmp    $0x2d,%al
  800ea1:	75 07                	jne    800eaa <strtol+0x43>
		s++, neg = 1;
  800ea3:	83 c2 01             	add    $0x1,%edx
  800ea6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eaa:	85 db                	test   %ebx,%ebx
  800eac:	0f 94 c0             	sete   %al
  800eaf:	74 05                	je     800eb6 <strtol+0x4f>
  800eb1:	83 fb 10             	cmp    $0x10,%ebx
  800eb4:	75 15                	jne    800ecb <strtol+0x64>
  800eb6:	80 3a 30             	cmpb   $0x30,(%edx)
  800eb9:	75 10                	jne    800ecb <strtol+0x64>
  800ebb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ebf:	75 0a                	jne    800ecb <strtol+0x64>
		s += 2, base = 16;
  800ec1:	83 c2 02             	add    $0x2,%edx
  800ec4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ec9:	eb 13                	jmp    800ede <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800ecb:	84 c0                	test   %al,%al
  800ecd:	74 0f                	je     800ede <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ecf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ed4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ed7:	75 05                	jne    800ede <strtol+0x77>
		s++, base = 8;
  800ed9:	83 c2 01             	add    $0x1,%edx
  800edc:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ede:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee3:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ee5:	0f b6 0a             	movzbl (%edx),%ecx
  800ee8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800eeb:	80 fb 09             	cmp    $0x9,%bl
  800eee:	77 08                	ja     800ef8 <strtol+0x91>
			dig = *s - '0';
  800ef0:	0f be c9             	movsbl %cl,%ecx
  800ef3:	83 e9 30             	sub    $0x30,%ecx
  800ef6:	eb 1e                	jmp    800f16 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800ef8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800efb:	80 fb 19             	cmp    $0x19,%bl
  800efe:	77 08                	ja     800f08 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800f00:	0f be c9             	movsbl %cl,%ecx
  800f03:	83 e9 57             	sub    $0x57,%ecx
  800f06:	eb 0e                	jmp    800f16 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800f08:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f0b:	80 fb 19             	cmp    $0x19,%bl
  800f0e:	77 15                	ja     800f25 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800f10:	0f be c9             	movsbl %cl,%ecx
  800f13:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f16:	39 f1                	cmp    %esi,%ecx
  800f18:	7d 0f                	jge    800f29 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800f1a:	83 c2 01             	add    $0x1,%edx
  800f1d:	0f af c6             	imul   %esi,%eax
  800f20:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f23:	eb c0                	jmp    800ee5 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f25:	89 c1                	mov    %eax,%ecx
  800f27:	eb 02                	jmp    800f2b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f29:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f2b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f2f:	74 05                	je     800f36 <strtol+0xcf>
		*endptr = (char *) s;
  800f31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f34:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f36:	89 ca                	mov    %ecx,%edx
  800f38:	f7 da                	neg    %edx
  800f3a:	85 ff                	test   %edi,%edi
  800f3c:	0f 45 c2             	cmovne %edx,%eax
}
  800f3f:	5b                   	pop    %ebx
  800f40:	5e                   	pop    %esi
  800f41:	5f                   	pop    %edi
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    
	...

00800f50 <__udivdi3>:
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	57                   	push   %edi
  800f54:	56                   	push   %esi
  800f55:	83 ec 10             	sub    $0x10,%esp
  800f58:	8b 75 14             	mov    0x14(%ebp),%esi
  800f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f61:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f64:	85 f6                	test   %esi,%esi
  800f66:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f69:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f6f:	75 2f                	jne    800fa0 <__udivdi3+0x50>
  800f71:	39 f9                	cmp    %edi,%ecx
  800f73:	77 5b                	ja     800fd0 <__udivdi3+0x80>
  800f75:	85 c9                	test   %ecx,%ecx
  800f77:	75 0b                	jne    800f84 <__udivdi3+0x34>
  800f79:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7e:	31 d2                	xor    %edx,%edx
  800f80:	f7 f1                	div    %ecx
  800f82:	89 c1                	mov    %eax,%ecx
  800f84:	89 f8                	mov    %edi,%eax
  800f86:	31 d2                	xor    %edx,%edx
  800f88:	f7 f1                	div    %ecx
  800f8a:	89 c7                	mov    %eax,%edi
  800f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8f:	f7 f1                	div    %ecx
  800f91:	89 fa                	mov    %edi,%edx
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    
  800f9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa0:	31 d2                	xor    %edx,%edx
  800fa2:	31 c0                	xor    %eax,%eax
  800fa4:	39 fe                	cmp    %edi,%esi
  800fa6:	77 eb                	ja     800f93 <__udivdi3+0x43>
  800fa8:	0f bd d6             	bsr    %esi,%edx
  800fab:	83 f2 1f             	xor    $0x1f,%edx
  800fae:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fb1:	75 2d                	jne    800fe0 <__udivdi3+0x90>
  800fb3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800fb6:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  800fb9:	76 06                	jbe    800fc1 <__udivdi3+0x71>
  800fbb:	39 fe                	cmp    %edi,%esi
  800fbd:	89 c2                	mov    %eax,%edx
  800fbf:	73 d2                	jae    800f93 <__udivdi3+0x43>
  800fc1:	31 d2                	xor    %edx,%edx
  800fc3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc8:	eb c9                	jmp    800f93 <__udivdi3+0x43>
  800fca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fd0:	89 fa                	mov    %edi,%edx
  800fd2:	f7 f1                	div    %ecx
  800fd4:	31 d2                	xor    %edx,%edx
  800fd6:	83 c4 10             	add    $0x10,%esp
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    
  800fdd:	8d 76 00             	lea    0x0(%esi),%esi
  800fe0:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fe4:	b8 20 00 00 00       	mov    $0x20,%eax
  800fe9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fec:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800fef:	d3 e6                	shl    %cl,%esi
  800ff1:	89 c1                	mov    %eax,%ecx
  800ff3:	d3 ea                	shr    %cl,%edx
  800ff5:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800ff9:	09 f2                	or     %esi,%edx
  800ffb:	8b 75 ec             	mov    -0x14(%ebp),%esi
  800ffe:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801001:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801004:	d3 e2                	shl    %cl,%edx
  801006:	89 c1                	mov    %eax,%ecx
  801008:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80100b:	89 fa                	mov    %edi,%edx
  80100d:	d3 ea                	shr    %cl,%edx
  80100f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801013:	d3 e7                	shl    %cl,%edi
  801015:	89 c1                	mov    %eax,%ecx
  801017:	d3 ee                	shr    %cl,%esi
  801019:	09 fe                	or     %edi,%esi
  80101b:	89 f0                	mov    %esi,%eax
  80101d:	f7 75 e8             	divl   -0x18(%ebp)
  801020:	89 d7                	mov    %edx,%edi
  801022:	89 c6                	mov    %eax,%esi
  801024:	f7 65 f0             	mull   -0x10(%ebp)
  801027:	39 d7                	cmp    %edx,%edi
  801029:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80102c:	72 22                	jb     801050 <__udivdi3+0x100>
  80102e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801031:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801035:	d3 e2                	shl    %cl,%edx
  801037:	39 c2                	cmp    %eax,%edx
  801039:	73 05                	jae    801040 <__udivdi3+0xf0>
  80103b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80103e:	74 10                	je     801050 <__udivdi3+0x100>
  801040:	89 f0                	mov    %esi,%eax
  801042:	31 d2                	xor    %edx,%edx
  801044:	e9 4a ff ff ff       	jmp    800f93 <__udivdi3+0x43>
  801049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801050:	8d 46 ff             	lea    -0x1(%esi),%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	83 c4 10             	add    $0x10,%esp
  801058:	5e                   	pop    %esi
  801059:	5f                   	pop    %edi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    
  80105c:	00 00                	add    %al,(%eax)
	...

00801060 <__umoddi3>:
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	83 ec 20             	sub    $0x20,%esp
  801068:	8b 7d 14             	mov    0x14(%ebp),%edi
  80106b:	8b 45 08             	mov    0x8(%ebp),%eax
  80106e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801071:	8b 75 0c             	mov    0xc(%ebp),%esi
  801074:	85 ff                	test   %edi,%edi
  801076:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801079:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80107c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80107f:	89 f2                	mov    %esi,%edx
  801081:	75 15                	jne    801098 <__umoddi3+0x38>
  801083:	39 f1                	cmp    %esi,%ecx
  801085:	76 41                	jbe    8010c8 <__umoddi3+0x68>
  801087:	f7 f1                	div    %ecx
  801089:	89 d0                	mov    %edx,%eax
  80108b:	31 d2                	xor    %edx,%edx
  80108d:	83 c4 20             	add    $0x20,%esp
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    
  801094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801098:	39 f7                	cmp    %esi,%edi
  80109a:	77 4c                	ja     8010e8 <__umoddi3+0x88>
  80109c:	0f bd c7             	bsr    %edi,%eax
  80109f:	83 f0 1f             	xor    $0x1f,%eax
  8010a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010a5:	75 51                	jne    8010f8 <__umoddi3+0x98>
  8010a7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8010aa:	0f 87 e8 00 00 00    	ja     801198 <__umoddi3+0x138>
  8010b0:	89 f2                	mov    %esi,%edx
  8010b2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8010b5:	29 ce                	sub    %ecx,%esi
  8010b7:	19 fa                	sbb    %edi,%edx
  8010b9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8010bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010bf:	83 c4 20             	add    $0x20,%esp
  8010c2:	5e                   	pop    %esi
  8010c3:	5f                   	pop    %edi
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    
  8010c6:	66 90                	xchg   %ax,%ax
  8010c8:	85 c9                	test   %ecx,%ecx
  8010ca:	75 0b                	jne    8010d7 <__umoddi3+0x77>
  8010cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d1:	31 d2                	xor    %edx,%edx
  8010d3:	f7 f1                	div    %ecx
  8010d5:	89 c1                	mov    %eax,%ecx
  8010d7:	89 f0                	mov    %esi,%eax
  8010d9:	31 d2                	xor    %edx,%edx
  8010db:	f7 f1                	div    %ecx
  8010dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e0:	eb a5                	jmp    801087 <__umoddi3+0x27>
  8010e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010e8:	89 f2                	mov    %esi,%edx
  8010ea:	83 c4 20             	add    $0x20,%esp
  8010ed:	5e                   	pop    %esi
  8010ee:	5f                   	pop    %edi
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    
  8010f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8010fc:	89 f2                	mov    %esi,%edx
  8010fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801101:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801108:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80110b:	d3 e7                	shl    %cl,%edi
  80110d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801110:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801114:	d3 e8                	shr    %cl,%eax
  801116:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80111a:	09 f8                	or     %edi,%eax
  80111c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80111f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801122:	d3 e0                	shl    %cl,%eax
  801124:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801128:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80112b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80112e:	d3 ea                	shr    %cl,%edx
  801130:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801134:	d3 e6                	shl    %cl,%esi
  801136:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80113a:	d3 e8                	shr    %cl,%eax
  80113c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801140:	09 f0                	or     %esi,%eax
  801142:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801145:	f7 75 e4             	divl   -0x1c(%ebp)
  801148:	d3 e6                	shl    %cl,%esi
  80114a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80114d:	89 d6                	mov    %edx,%esi
  80114f:	f7 65 f4             	mull   -0xc(%ebp)
  801152:	89 d7                	mov    %edx,%edi
  801154:	89 c2                	mov    %eax,%edx
  801156:	39 fe                	cmp    %edi,%esi
  801158:	89 f9                	mov    %edi,%ecx
  80115a:	72 30                	jb     80118c <__umoddi3+0x12c>
  80115c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80115f:	72 27                	jb     801188 <__umoddi3+0x128>
  801161:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801164:	29 d0                	sub    %edx,%eax
  801166:	19 ce                	sbb    %ecx,%esi
  801168:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80116c:	89 f2                	mov    %esi,%edx
  80116e:	d3 e8                	shr    %cl,%eax
  801170:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801174:	d3 e2                	shl    %cl,%edx
  801176:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80117a:	09 d0                	or     %edx,%eax
  80117c:	89 f2                	mov    %esi,%edx
  80117e:	d3 ea                	shr    %cl,%edx
  801180:	83 c4 20             	add    $0x20,%esp
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    
  801187:	90                   	nop
  801188:	39 fe                	cmp    %edi,%esi
  80118a:	75 d5                	jne    801161 <__umoddi3+0x101>
  80118c:	89 f9                	mov    %edi,%ecx
  80118e:	89 c2                	mov    %eax,%edx
  801190:	2b 55 f4             	sub    -0xc(%ebp),%edx
  801193:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801196:	eb c9                	jmp    801161 <__umoddi3+0x101>
  801198:	39 f7                	cmp    %esi,%edi
  80119a:	0f 82 10 ff ff ff    	jb     8010b0 <__umoddi3+0x50>
  8011a0:	e9 17 ff ff ff       	jmp    8010bc <__umoddi3+0x5c>
