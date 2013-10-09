
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	sys_cputs((char*)1, 1);
  80003a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800049:	e8 66 00 00 00       	call   8000b4 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800062:	e8 11 01 00 00       	call   800178 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 f6                	test   %esi,%esi
  80007b:	7e 07                	jle    800084 <libmain+0x34>
		binaryname = argv[0];
  80007d:	8b 03                	mov    (%ebx),%eax
  80007f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800088:	89 34 24             	mov    %esi,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0b 00 00 00       	call   8000a0 <exit>
}
  800095:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800098:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009b:	89 ec                	mov    %ebp,%esp
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 69 00 00 00       	call   80011b <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 0c             	sub    $0xc,%esp
  8000ba:	89 1c 24             	mov    %ebx,(%esp)
  8000bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c1:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d0:	89 c3                	mov    %eax,%ebx
  8000d2:	89 c7                	mov    %eax,%edi
  8000d4:	89 c6                	mov    %eax,%esi
  8000d6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d8:	8b 1c 24             	mov    (%esp),%ebx
  8000db:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000df:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000e3:	89 ec                	mov    %ebp,%esp
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 0c             	sub    $0xc,%esp
  8000ed:	89 1c 24             	mov    %ebx,(%esp)
  8000f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000f4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fd:	b8 01 00 00 00       	mov    $0x1,%eax
  800102:	89 d1                	mov    %edx,%ecx
  800104:	89 d3                	mov    %edx,%ebx
  800106:	89 d7                	mov    %edx,%edi
  800108:	89 d6                	mov    %edx,%esi
  80010a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010c:	8b 1c 24             	mov    (%esp),%ebx
  80010f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800113:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800117:	89 ec                	mov    %ebp,%esp
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	83 ec 38             	sub    $0x38,%esp
  800121:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800124:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800127:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012f:	b8 03 00 00 00       	mov    $0x3,%eax
  800134:	8b 55 08             	mov    0x8(%ebp),%edx
  800137:	89 cb                	mov    %ecx,%ebx
  800139:	89 cf                	mov    %ecx,%edi
  80013b:	89 ce                	mov    %ecx,%esi
  80013d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80013f:	85 c0                	test   %eax,%eax
  800141:	7e 28                	jle    80016b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800143:	89 44 24 10          	mov    %eax,0x10(%esp)
  800147:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80014e:	00 
  80014f:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  800156:	00 
  800157:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  800166:	e8 e1 02 00 00       	call   80044c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80016b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80016e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800171:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800174:	89 ec                	mov    %ebp,%esp
  800176:	5d                   	pop    %ebp
  800177:	c3                   	ret    

00800178 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	83 ec 0c             	sub    $0xc,%esp
  80017e:	89 1c 24             	mov    %ebx,(%esp)
  800181:	89 74 24 04          	mov    %esi,0x4(%esp)
  800185:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800189:	ba 00 00 00 00       	mov    $0x0,%edx
  80018e:	b8 02 00 00 00       	mov    $0x2,%eax
  800193:	89 d1                	mov    %edx,%ecx
  800195:	89 d3                	mov    %edx,%ebx
  800197:	89 d7                	mov    %edx,%edi
  800199:	89 d6                	mov    %edx,%esi
  80019b:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  80019d:	8b 1c 24             	mov    (%esp),%ebx
  8001a0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001a8:	89 ec                	mov    %ebp,%esp
  8001aa:	5d                   	pop    %ebp
  8001ab:	c3                   	ret    

008001ac <sys_yield>:

void
sys_yield(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	89 1c 24             	mov    %ebx,(%esp)
  8001b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001b9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001c7:	89 d1                	mov    %edx,%ecx
  8001c9:	89 d3                	mov    %edx,%ebx
  8001cb:	89 d7                	mov    %edx,%edi
  8001cd:	89 d6                	mov    %edx,%esi
  8001cf:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001d1:	8b 1c 24             	mov    (%esp),%ebx
  8001d4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001d8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001dc:	89 ec                	mov    %ebp,%esp
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    

008001e0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	83 ec 38             	sub    $0x38,%esp
  8001e6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001e9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001ec:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ef:	be 00 00 00 00       	mov    $0x0,%esi
  8001f4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	89 f7                	mov    %esi,%edi
  800204:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	7e 28                	jle    800232 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800215:	00 
  800216:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  80021d:	00 
  80021e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800225:	00 
  800226:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  80022d:	e8 1a 02 00 00       	call   80044c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800232:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800235:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800238:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80023b:	89 ec                	mov    %ebp,%esp
  80023d:	5d                   	pop    %ebp
  80023e:	c3                   	ret    

0080023f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	83 ec 38             	sub    $0x38,%esp
  800245:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800248:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80024b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024e:	b8 05 00 00 00       	mov    $0x5,%eax
  800253:	8b 75 18             	mov    0x18(%ebp),%esi
  800256:	8b 7d 14             	mov    0x14(%ebp),%edi
  800259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025f:	8b 55 08             	mov    0x8(%ebp),%edx
  800262:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800264:	85 c0                	test   %eax,%eax
  800266:	7e 28                	jle    800290 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800268:	89 44 24 10          	mov    %eax,0x10(%esp)
  80026c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800273:	00 
  800274:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  80027b:	00 
  80027c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800283:	00 
  800284:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  80028b:	e8 bc 01 00 00       	call   80044c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800290:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800293:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800296:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800299:	89 ec                	mov    %ebp,%esp
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	83 ec 38             	sub    $0x38,%esp
  8002a3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002a6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002a9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b1:	b8 06 00 00 00       	mov    $0x6,%eax
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	89 df                	mov    %ebx,%edi
  8002be:	89 de                	mov    %ebx,%esi
  8002c0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c2:	85 c0                	test   %eax,%eax
  8002c4:	7e 28                	jle    8002ee <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ca:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002d1:	00 
  8002d2:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  8002d9:	00 
  8002da:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002e1:	00 
  8002e2:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  8002e9:	e8 5e 01 00 00       	call   80044c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002f1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002f4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002f7:	89 ec                	mov    %ebp,%esp
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	83 ec 38             	sub    $0x38,%esp
  800301:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800304:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800307:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80030f:	b8 08 00 00 00       	mov    $0x8,%eax
  800314:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800317:	8b 55 08             	mov    0x8(%ebp),%edx
  80031a:	89 df                	mov    %ebx,%edi
  80031c:	89 de                	mov    %ebx,%esi
  80031e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800320:	85 c0                	test   %eax,%eax
  800322:	7e 28                	jle    80034c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800324:	89 44 24 10          	mov    %eax,0x10(%esp)
  800328:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80032f:	00 
  800330:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  800337:	00 
  800338:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80033f:	00 
  800340:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  800347:	e8 00 01 00 00       	call   80044c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80034c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80034f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800352:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800355:	89 ec                	mov    %ebp,%esp
  800357:	5d                   	pop    %ebp
  800358:	c3                   	ret    

00800359 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
  80035c:	83 ec 38             	sub    $0x38,%esp
  80035f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800362:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800365:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800368:	bb 00 00 00 00       	mov    $0x0,%ebx
  80036d:	b8 09 00 00 00       	mov    $0x9,%eax
  800372:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800375:	8b 55 08             	mov    0x8(%ebp),%edx
  800378:	89 df                	mov    %ebx,%edi
  80037a:	89 de                	mov    %ebx,%esi
  80037c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80037e:	85 c0                	test   %eax,%eax
  800380:	7e 28                	jle    8003aa <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800382:	89 44 24 10          	mov    %eax,0x10(%esp)
  800386:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80038d:	00 
  80038e:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  800395:	00 
  800396:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80039d:	00 
  80039e:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  8003a5:	e8 a2 00 00 00       	call   80044c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003aa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003ad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003b0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003b3:	89 ec                	mov    %ebp,%esp
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 0c             	sub    $0xc,%esp
  8003bd:	89 1c 24             	mov    %ebx,(%esp)
  8003c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c8:	be 00 00 00 00       	mov    $0x0,%esi
  8003cd:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003d2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003db:	8b 55 08             	mov    0x8(%ebp),%edx
  8003de:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003e0:	8b 1c 24             	mov    (%esp),%ebx
  8003e3:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003e7:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003eb:	89 ec                	mov    %ebp,%esp
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	83 ec 38             	sub    $0x38,%esp
  8003f5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003f8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003fb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800403:	b8 0c 00 00 00       	mov    $0xc,%eax
  800408:	8b 55 08             	mov    0x8(%ebp),%edx
  80040b:	89 cb                	mov    %ecx,%ebx
  80040d:	89 cf                	mov    %ecx,%edi
  80040f:	89 ce                	mov    %ecx,%esi
  800411:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800413:	85 c0                	test   %eax,%eax
  800415:	7e 28                	jle    80043f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800417:	89 44 24 10          	mov    %eax,0x10(%esp)
  80041b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800422:	00 
  800423:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  80042a:	00 
  80042b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800432:	00 
  800433:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  80043a:	e8 0d 00 00 00       	call   80044c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80043f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800442:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800445:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800448:	89 ec                	mov    %ebp,%esp
  80044a:	5d                   	pop    %ebp
  80044b:	c3                   	ret    

0080044c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	56                   	push   %esi
  800450:	53                   	push   %ebx
  800451:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800454:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800457:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80045d:	e8 16 fd ff ff       	call   800178 <sys_getenvid>
  800462:	8b 55 0c             	mov    0xc(%ebp),%edx
  800465:	89 54 24 10          	mov    %edx,0x10(%esp)
  800469:	8b 55 08             	mov    0x8(%ebp),%edx
  80046c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800470:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800474:	89 44 24 04          	mov    %eax,0x4(%esp)
  800478:	c7 04 24 f8 11 80 00 	movl   $0x8011f8,(%esp)
  80047f:	e8 c3 00 00 00       	call   800547 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800484:	89 74 24 04          	mov    %esi,0x4(%esp)
  800488:	8b 45 10             	mov    0x10(%ebp),%eax
  80048b:	89 04 24             	mov    %eax,(%esp)
  80048e:	e8 53 00 00 00       	call   8004e6 <vcprintf>
	cprintf("\n");
  800493:	c7 04 24 1c 12 80 00 	movl   $0x80121c,(%esp)
  80049a:	e8 a8 00 00 00       	call   800547 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80049f:	cc                   	int3   
  8004a0:	eb fd                	jmp    80049f <_panic+0x53>
	...

008004a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	53                   	push   %ebx
  8004a8:	83 ec 14             	sub    $0x14,%esp
  8004ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ae:	8b 03                	mov    (%ebx),%eax
  8004b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004b7:	83 c0 01             	add    $0x1,%eax
  8004ba:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004bc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c1:	75 19                	jne    8004dc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004c3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004ca:	00 
  8004cb:	8d 43 08             	lea    0x8(%ebx),%eax
  8004ce:	89 04 24             	mov    %eax,(%esp)
  8004d1:	e8 de fb ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8004d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004dc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004e0:	83 c4 14             	add    $0x14,%esp
  8004e3:	5b                   	pop    %ebx
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004ef:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004f6:	00 00 00 
	b.cnt = 0;
  8004f9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800500:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800503:	8b 45 0c             	mov    0xc(%ebp),%eax
  800506:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050a:	8b 45 08             	mov    0x8(%ebp),%eax
  80050d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800511:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800517:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051b:	c7 04 24 a4 04 80 00 	movl   $0x8004a4,(%esp)
  800522:	e8 ea 01 00 00       	call   800711 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800527:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80052d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800531:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800537:	89 04 24             	mov    %eax,(%esp)
  80053a:	e8 75 fb ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  80053f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800545:	c9                   	leave  
  800546:	c3                   	ret    

00800547 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80054d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800550:	89 44 24 04          	mov    %eax,0x4(%esp)
  800554:	8b 45 08             	mov    0x8(%ebp),%eax
  800557:	89 04 24             	mov    %eax,(%esp)
  80055a:	e8 87 ff ff ff       	call   8004e6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80055f:	c9                   	leave  
  800560:	c3                   	ret    
	...

00800570 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800570:	55                   	push   %ebp
  800571:	89 e5                	mov    %esp,%ebp
  800573:	57                   	push   %edi
  800574:	56                   	push   %esi
  800575:	53                   	push   %ebx
  800576:	83 ec 4c             	sub    $0x4c,%esp
  800579:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057c:	89 d6                	mov    %edx,%esi
  80057e:	8b 45 08             	mov    0x8(%ebp),%eax
  800581:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800584:	8b 55 0c             	mov    0xc(%ebp),%edx
  800587:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80058a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80058d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800590:	b8 00 00 00 00       	mov    $0x0,%eax
  800595:	39 d0                	cmp    %edx,%eax
  800597:	72 11                	jb     8005aa <printnum+0x3a>
  800599:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  80059f:	76 09                	jbe    8005aa <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005a1:	83 eb 01             	sub    $0x1,%ebx
  8005a4:	85 db                	test   %ebx,%ebx
  8005a6:	7f 5d                	jg     800605 <printnum+0x95>
  8005a8:	eb 6c                	jmp    800616 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005aa:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8005ae:	83 eb 01             	sub    $0x1,%ebx
  8005b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005bc:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005c0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8005c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005d1:	00 
  8005d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d5:	89 14 24             	mov    %edx,(%esp)
  8005d8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005df:	e8 7c 09 00 00       	call   800f60 <__udivdi3>
  8005e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005ee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005f2:	89 04 24             	mov    %eax,(%esp)
  8005f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f9:	89 f2                	mov    %esi,%edx
  8005fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005fe:	e8 6d ff ff ff       	call   800570 <printnum>
  800603:	eb 11                	jmp    800616 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800605:	89 74 24 04          	mov    %esi,0x4(%esp)
  800609:	89 3c 24             	mov    %edi,(%esp)
  80060c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80060f:	83 eb 01             	sub    $0x1,%ebx
  800612:	85 db                	test   %ebx,%ebx
  800614:	7f ef                	jg     800605 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800616:	89 74 24 04          	mov    %esi,0x4(%esp)
  80061a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80061e:	8b 45 10             	mov    0x10(%ebp),%eax
  800621:	89 44 24 08          	mov    %eax,0x8(%esp)
  800625:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80062c:	00 
  80062d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800630:	89 14 24             	mov    %edx,(%esp)
  800633:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800636:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80063a:	e8 31 0a 00 00       	call   801070 <__umoddi3>
  80063f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800643:	0f be 80 1e 12 80 00 	movsbl 0x80121e(%eax),%eax
  80064a:	89 04 24             	mov    %eax,(%esp)
  80064d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800650:	83 c4 4c             	add    $0x4c,%esp
  800653:	5b                   	pop    %ebx
  800654:	5e                   	pop    %esi
  800655:	5f                   	pop    %edi
  800656:	5d                   	pop    %ebp
  800657:	c3                   	ret    

00800658 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80065b:	83 fa 01             	cmp    $0x1,%edx
  80065e:	7e 0e                	jle    80066e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800660:	8b 10                	mov    (%eax),%edx
  800662:	8d 4a 08             	lea    0x8(%edx),%ecx
  800665:	89 08                	mov    %ecx,(%eax)
  800667:	8b 02                	mov    (%edx),%eax
  800669:	8b 52 04             	mov    0x4(%edx),%edx
  80066c:	eb 22                	jmp    800690 <getuint+0x38>
	else if (lflag)
  80066e:	85 d2                	test   %edx,%edx
  800670:	74 10                	je     800682 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8d 4a 04             	lea    0x4(%edx),%ecx
  800677:	89 08                	mov    %ecx,(%eax)
  800679:	8b 02                	mov    (%edx),%eax
  80067b:	ba 00 00 00 00       	mov    $0x0,%edx
  800680:	eb 0e                	jmp    800690 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800682:	8b 10                	mov    (%eax),%edx
  800684:	8d 4a 04             	lea    0x4(%edx),%ecx
  800687:	89 08                	mov    %ecx,(%eax)
  800689:	8b 02                	mov    (%edx),%eax
  80068b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800690:	5d                   	pop    %ebp
  800691:	c3                   	ret    

00800692 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800692:	55                   	push   %ebp
  800693:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800695:	83 fa 01             	cmp    $0x1,%edx
  800698:	7e 0e                	jle    8006a8 <getint+0x16>
		return va_arg(*ap, long long);
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80069f:	89 08                	mov    %ecx,(%eax)
  8006a1:	8b 02                	mov    (%edx),%eax
  8006a3:	8b 52 04             	mov    0x4(%edx),%edx
  8006a6:	eb 22                	jmp    8006ca <getint+0x38>
	else if (lflag)
  8006a8:	85 d2                	test   %edx,%edx
  8006aa:	74 10                	je     8006bc <getint+0x2a>
		return va_arg(*ap, long);
  8006ac:	8b 10                	mov    (%eax),%edx
  8006ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006b1:	89 08                	mov    %ecx,(%eax)
  8006b3:	8b 02                	mov    (%edx),%eax
  8006b5:	89 c2                	mov    %eax,%edx
  8006b7:	c1 fa 1f             	sar    $0x1f,%edx
  8006ba:	eb 0e                	jmp    8006ca <getint+0x38>
	else
		return va_arg(*ap, int);
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006c1:	89 08                	mov    %ecx,(%eax)
  8006c3:	8b 02                	mov    (%edx),%eax
  8006c5:	89 c2                	mov    %eax,%edx
  8006c7:	c1 fa 1f             	sar    $0x1f,%edx
}
  8006ca:	5d                   	pop    %ebp
  8006cb:	c3                   	ret    

008006cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006d2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006d6:	8b 10                	mov    (%eax),%edx
  8006d8:	3b 50 04             	cmp    0x4(%eax),%edx
  8006db:	73 0a                	jae    8006e7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e0:	88 0a                	mov    %cl,(%edx)
  8006e2:	83 c2 01             	add    $0x1,%edx
  8006e5:	89 10                	mov    %edx,(%eax)
}
  8006e7:	5d                   	pop    %ebp
  8006e8:	c3                   	ret    

008006e9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006ef:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800700:	89 44 24 04          	mov    %eax,0x4(%esp)
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	89 04 24             	mov    %eax,(%esp)
  80070a:	e8 02 00 00 00       	call   800711 <vprintfmt>
	va_end(ap);
}
  80070f:	c9                   	leave  
  800710:	c3                   	ret    

00800711 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	57                   	push   %edi
  800715:	56                   	push   %esi
  800716:	53                   	push   %ebx
  800717:	83 ec 4c             	sub    $0x4c,%esp
  80071a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80071d:	eb 23                	jmp    800742 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80071f:	85 c0                	test   %eax,%eax
  800721:	75 12                	jne    800735 <vprintfmt+0x24>
				csa = 0x0700;
  800723:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80072a:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80072d:	83 c4 4c             	add    $0x4c,%esp
  800730:	5b                   	pop    %ebx
  800731:	5e                   	pop    %esi
  800732:	5f                   	pop    %edi
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  800735:	8b 55 0c             	mov    0xc(%ebp),%edx
  800738:	89 54 24 04          	mov    %edx,0x4(%esp)
  80073c:	89 04 24             	mov    %eax,(%esp)
  80073f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800742:	0f b6 07             	movzbl (%edi),%eax
  800745:	83 c7 01             	add    $0x1,%edi
  800748:	83 f8 25             	cmp    $0x25,%eax
  80074b:	75 d2                	jne    80071f <vprintfmt+0xe>
  80074d:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800751:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800758:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80075d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800764:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800769:	be 00 00 00 00       	mov    $0x0,%esi
  80076e:	eb 14                	jmp    800784 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800770:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800774:	eb 0e                	jmp    800784 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800776:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80077a:	eb 08                	jmp    800784 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80077c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80077f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800784:	0f b6 07             	movzbl (%edi),%eax
  800787:	0f b6 c8             	movzbl %al,%ecx
  80078a:	83 c7 01             	add    $0x1,%edi
  80078d:	83 e8 23             	sub    $0x23,%eax
  800790:	3c 55                	cmp    $0x55,%al
  800792:	0f 87 ed 02 00 00    	ja     800a85 <vprintfmt+0x374>
  800798:	0f b6 c0             	movzbl %al,%eax
  80079b:	ff 24 85 e0 12 80 00 	jmp    *0x8012e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007a2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  8007a5:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8007a8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007ab:	83 f9 09             	cmp    $0x9,%ecx
  8007ae:	77 3c                	ja     8007ec <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007b0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8007b3:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  8007b6:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  8007ba:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8007bd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007c0:	83 f9 09             	cmp    $0x9,%ecx
  8007c3:	76 eb                	jbe    8007b0 <vprintfmt+0x9f>
  8007c5:	eb 25                	jmp    8007ec <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8d 48 04             	lea    0x4(%eax),%ecx
  8007cd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007d0:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  8007d2:	eb 18                	jmp    8007ec <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  8007d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007db:	0f 48 c6             	cmovs  %esi,%eax
  8007de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007e1:	eb a1                	jmp    800784 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  8007e3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8007ea:	eb 98                	jmp    800784 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  8007ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007f0:	79 92                	jns    800784 <vprintfmt+0x73>
  8007f2:	eb 88                	jmp    80077c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007f4:	83 c2 01             	add    $0x1,%edx
  8007f7:	eb 8b                	jmp    800784 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8d 50 04             	lea    0x4(%eax),%edx
  8007ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800802:	8b 55 0c             	mov    0xc(%ebp),%edx
  800805:	89 54 24 04          	mov    %edx,0x4(%esp)
  800809:	8b 00                	mov    (%eax),%eax
  80080b:	89 04 24             	mov    %eax,(%esp)
  80080e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800811:	e9 2c ff ff ff       	jmp    800742 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	89 c2                	mov    %eax,%edx
  800823:	c1 fa 1f             	sar    $0x1f,%edx
  800826:	31 d0                	xor    %edx,%eax
  800828:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80082a:	83 f8 08             	cmp    $0x8,%eax
  80082d:	7f 0b                	jg     80083a <vprintfmt+0x129>
  80082f:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  800836:	85 d2                	test   %edx,%edx
  800838:	75 23                	jne    80085d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  80083a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083e:	c7 44 24 08 36 12 80 	movl   $0x801236,0x8(%esp)
  800845:	00 
  800846:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800849:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084d:	8b 45 08             	mov    0x8(%ebp),%eax
  800850:	89 04 24             	mov    %eax,(%esp)
  800853:	e8 91 fe ff ff       	call   8006e9 <printfmt>
  800858:	e9 e5 fe ff ff       	jmp    800742 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80085d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800861:	c7 44 24 08 3f 12 80 	movl   $0x80123f,0x8(%esp)
  800868:	00 
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800870:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800873:	89 1c 24             	mov    %ebx,(%esp)
  800876:	e8 6e fe ff ff       	call   8006e9 <printfmt>
  80087b:	e9 c2 fe ff ff       	jmp    800742 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800880:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800883:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800886:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800889:	8b 45 14             	mov    0x14(%ebp),%eax
  80088c:	8d 50 04             	lea    0x4(%eax),%edx
  80088f:	89 55 14             	mov    %edx,0x14(%ebp)
  800892:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800894:	85 f6                	test   %esi,%esi
  800896:	ba 2f 12 80 00       	mov    $0x80122f,%edx
  80089b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80089e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008a2:	7e 06                	jle    8008aa <vprintfmt+0x199>
  8008a4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8008a8:	75 13                	jne    8008bd <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008aa:	0f be 06             	movsbl (%esi),%eax
  8008ad:	83 c6 01             	add    $0x1,%esi
  8008b0:	85 c0                	test   %eax,%eax
  8008b2:	0f 85 a2 00 00 00    	jne    80095a <vprintfmt+0x249>
  8008b8:	e9 92 00 00 00       	jmp    80094f <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c1:	89 34 24             	mov    %esi,(%esp)
  8008c4:	e8 82 02 00 00       	call   800b4b <strnlen>
  8008c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008cc:	29 c2                	sub    %eax,%edx
  8008ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008d1:	85 d2                	test   %edx,%edx
  8008d3:	7e d5                	jle    8008aa <vprintfmt+0x199>
					putch(padc, putdat);
  8008d5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8008d9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008dc:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8008df:	89 d3                	mov    %edx,%ebx
  8008e1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8008e4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008e7:	89 c6                	mov    %eax,%esi
  8008e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ed:	89 34 24             	mov    %esi,(%esp)
  8008f0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008f3:	83 eb 01             	sub    $0x1,%ebx
  8008f6:	85 db                	test   %ebx,%ebx
  8008f8:	7f ef                	jg     8008e9 <vprintfmt+0x1d8>
  8008fa:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8008fd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800900:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800903:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80090a:	eb 9e                	jmp    8008aa <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80090c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800910:	74 1b                	je     80092d <vprintfmt+0x21c>
  800912:	8d 50 e0             	lea    -0x20(%eax),%edx
  800915:	83 fa 5e             	cmp    $0x5e,%edx
  800918:	76 13                	jbe    80092d <vprintfmt+0x21c>
					putch('?', putdat);
  80091a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800921:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800928:	ff 55 08             	call   *0x8(%ebp)
  80092b:	eb 0d                	jmp    80093a <vprintfmt+0x229>
				else
					putch(ch, putdat);
  80092d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800930:	89 54 24 04          	mov    %edx,0x4(%esp)
  800934:	89 04 24             	mov    %eax,(%esp)
  800937:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80093a:	83 ef 01             	sub    $0x1,%edi
  80093d:	0f be 06             	movsbl (%esi),%eax
  800940:	85 c0                	test   %eax,%eax
  800942:	74 05                	je     800949 <vprintfmt+0x238>
  800944:	83 c6 01             	add    $0x1,%esi
  800947:	eb 17                	jmp    800960 <vprintfmt+0x24f>
  800949:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80094c:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80094f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800953:	7f 1c                	jg     800971 <vprintfmt+0x260>
  800955:	e9 e8 fd ff ff       	jmp    800742 <vprintfmt+0x31>
  80095a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80095d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800960:	85 db                	test   %ebx,%ebx
  800962:	78 a8                	js     80090c <vprintfmt+0x1fb>
  800964:	83 eb 01             	sub    $0x1,%ebx
  800967:	79 a3                	jns    80090c <vprintfmt+0x1fb>
  800969:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80096c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80096f:	eb de                	jmp    80094f <vprintfmt+0x23e>
  800971:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800974:	8b 7d 08             	mov    0x8(%ebp),%edi
  800977:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80097a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80097e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800985:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800987:	83 eb 01             	sub    $0x1,%ebx
  80098a:	85 db                	test   %ebx,%ebx
  80098c:	7f ec                	jg     80097a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800991:	e9 ac fd ff ff       	jmp    800742 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800996:	8d 45 14             	lea    0x14(%ebp),%eax
  800999:	e8 f4 fc ff ff       	call   800692 <getint>
  80099e:	89 c3                	mov    %eax,%ebx
  8009a0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8009a2:	85 d2                	test   %edx,%edx
  8009a4:	78 0a                	js     8009b0 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009a6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009ab:	e9 87 00 00 00       	jmp    800a37 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8009b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009be:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009c1:	89 d8                	mov    %ebx,%eax
  8009c3:	89 f2                	mov    %esi,%edx
  8009c5:	f7 d8                	neg    %eax
  8009c7:	83 d2 00             	adc    $0x0,%edx
  8009ca:	f7 da                	neg    %edx
			}
			base = 10;
  8009cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009d1:	eb 64                	jmp    800a37 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d6:	e8 7d fc ff ff       	call   800658 <getuint>
			base = 10;
  8009db:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8009e0:	eb 55                	jmp    800a37 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8009e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e5:	e8 6e fc ff ff       	call   800658 <getuint>
      base = 8;
  8009ea:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8009ef:	eb 46                	jmp    800a37 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  8009f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009f8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009ff:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a09:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a10:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a13:	8b 45 14             	mov    0x14(%ebp),%eax
  800a16:	8d 50 04             	lea    0x4(%eax),%edx
  800a19:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a1c:	8b 00                	mov    (%eax),%eax
  800a1e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a23:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a28:	eb 0d                	jmp    800a37 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a2a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a2d:	e8 26 fc ff ff       	call   800658 <getuint>
			base = 16;
  800a32:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a37:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800a3b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800a3f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a42:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a46:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a4a:	89 04 24             	mov    %eax,(%esp)
  800a4d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a51:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	e8 14 fb ff ff       	call   800570 <printnum>
			break;
  800a5c:	e9 e1 fc ff ff       	jmp    800742 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a68:	89 0c 24             	mov    %ecx,(%esp)
  800a6b:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a6e:	e9 cf fc ff ff       	jmp    800742 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800a73:	8d 45 14             	lea    0x14(%ebp),%eax
  800a76:	e8 17 fc ff ff       	call   800692 <getint>
			csa = num;
  800a7b:	a3 08 20 80 00       	mov    %eax,0x802008
			break;
  800a80:	e9 bd fc ff ff       	jmp    800742 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a88:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a8c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a93:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a96:	83 ef 01             	sub    $0x1,%edi
  800a99:	eb 02                	jmp    800a9d <vprintfmt+0x38c>
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	8d 47 ff             	lea    -0x1(%edi),%eax
  800aa0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800aa4:	75 f5                	jne    800a9b <vprintfmt+0x38a>
  800aa6:	e9 97 fc ff ff       	jmp    800742 <vprintfmt+0x31>

00800aab <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	83 ec 28             	sub    $0x28,%esp
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ab7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aba:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800abe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ac1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ac8:	85 c0                	test   %eax,%eax
  800aca:	74 30                	je     800afc <vsnprintf+0x51>
  800acc:	85 d2                	test   %edx,%edx
  800ace:	7e 2c                	jle    800afc <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ad0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ad7:	8b 45 10             	mov    0x10(%ebp),%eax
  800ada:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ade:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae5:	c7 04 24 cc 06 80 00 	movl   $0x8006cc,(%esp)
  800aec:	e8 20 fc ff ff       	call   800711 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800af1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800af4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800afa:	eb 05                	jmp    800b01 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800afc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b01:	c9                   	leave  
  800b02:	c3                   	ret    

00800b03 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b09:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b10:	8b 45 10             	mov    0x10(%ebp),%eax
  800b13:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	89 04 24             	mov    %eax,(%esp)
  800b24:	e8 82 ff ff ff       	call   800aab <vsnprintf>
	va_end(ap);

	return rc;
}
  800b29:	c9                   	leave  
  800b2a:	c3                   	ret    
  800b2b:	00 00                	add    %al,(%eax)
  800b2d:	00 00                	add    %al,(%eax)
	...

00800b30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b36:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b3e:	74 09                	je     800b49 <strlen+0x19>
		n++;
  800b40:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b47:	75 f7                	jne    800b40 <strlen+0x10>
		n++;
	return n;
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b51:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b54:	b8 00 00 00 00       	mov    $0x0,%eax
  800b59:	85 d2                	test   %edx,%edx
  800b5b:	74 12                	je     800b6f <strnlen+0x24>
  800b5d:	80 39 00             	cmpb   $0x0,(%ecx)
  800b60:	74 0d                	je     800b6f <strnlen+0x24>
		n++;
  800b62:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b65:	39 d0                	cmp    %edx,%eax
  800b67:	74 06                	je     800b6f <strnlen+0x24>
  800b69:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b6d:	75 f3                	jne    800b62 <strnlen+0x17>
		n++;
	return n;
}
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	53                   	push   %ebx
  800b75:	8b 45 08             	mov    0x8(%ebp),%eax
  800b78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b80:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b84:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b87:	83 c2 01             	add    $0x1,%edx
  800b8a:	84 c9                	test   %cl,%cl
  800b8c:	75 f2                	jne    800b80 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	53                   	push   %ebx
  800b95:	83 ec 08             	sub    $0x8,%esp
  800b98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b9b:	89 1c 24             	mov    %ebx,(%esp)
  800b9e:	e8 8d ff ff ff       	call   800b30 <strlen>
	strcpy(dst + len, src);
  800ba3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba6:	89 54 24 04          	mov    %edx,0x4(%esp)
  800baa:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bad:	89 04 24             	mov    %eax,(%esp)
  800bb0:	e8 bc ff ff ff       	call   800b71 <strcpy>
	return dst;
}
  800bb5:	89 d8                	mov    %ebx,%eax
  800bb7:	83 c4 08             	add    $0x8,%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc8:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bcb:	85 f6                	test   %esi,%esi
  800bcd:	74 18                	je     800be7 <strncpy+0x2a>
  800bcf:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bd4:	0f b6 1a             	movzbl (%edx),%ebx
  800bd7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bda:	80 3a 01             	cmpb   $0x1,(%edx)
  800bdd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800be0:	83 c1 01             	add    $0x1,%ecx
  800be3:	39 ce                	cmp    %ecx,%esi
  800be5:	77 ed                	ja     800bd4 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bf9:	89 f0                	mov    %esi,%eax
  800bfb:	85 c9                	test   %ecx,%ecx
  800bfd:	74 23                	je     800c22 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  800bff:	83 e9 01             	sub    $0x1,%ecx
  800c02:	74 1b                	je     800c1f <strlcpy+0x34>
  800c04:	0f b6 1a             	movzbl (%edx),%ebx
  800c07:	84 db                	test   %bl,%bl
  800c09:	74 14                	je     800c1f <strlcpy+0x34>
			*dst++ = *src++;
  800c0b:	88 18                	mov    %bl,(%eax)
  800c0d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c10:	83 e9 01             	sub    $0x1,%ecx
  800c13:	74 0a                	je     800c1f <strlcpy+0x34>
			*dst++ = *src++;
  800c15:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c18:	0f b6 1a             	movzbl (%edx),%ebx
  800c1b:	84 db                	test   %bl,%bl
  800c1d:	75 ec                	jne    800c0b <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  800c1f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c22:	29 f0                	sub    %esi,%eax
}
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c31:	0f b6 01             	movzbl (%ecx),%eax
  800c34:	84 c0                	test   %al,%al
  800c36:	74 15                	je     800c4d <strcmp+0x25>
  800c38:	3a 02                	cmp    (%edx),%al
  800c3a:	75 11                	jne    800c4d <strcmp+0x25>
		p++, q++;
  800c3c:	83 c1 01             	add    $0x1,%ecx
  800c3f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c42:	0f b6 01             	movzbl (%ecx),%eax
  800c45:	84 c0                	test   %al,%al
  800c47:	74 04                	je     800c4d <strcmp+0x25>
  800c49:	3a 02                	cmp    (%edx),%al
  800c4b:	74 ef                	je     800c3c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c4d:	0f b6 c0             	movzbl %al,%eax
  800c50:	0f b6 12             	movzbl (%edx),%edx
  800c53:	29 d0                	sub    %edx,%eax
}
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	53                   	push   %ebx
  800c5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c61:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c69:	85 d2                	test   %edx,%edx
  800c6b:	74 28                	je     800c95 <strncmp+0x3e>
  800c6d:	0f b6 01             	movzbl (%ecx),%eax
  800c70:	84 c0                	test   %al,%al
  800c72:	74 24                	je     800c98 <strncmp+0x41>
  800c74:	3a 03                	cmp    (%ebx),%al
  800c76:	75 20                	jne    800c98 <strncmp+0x41>
  800c78:	83 ea 01             	sub    $0x1,%edx
  800c7b:	74 13                	je     800c90 <strncmp+0x39>
		n--, p++, q++;
  800c7d:	83 c1 01             	add    $0x1,%ecx
  800c80:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c83:	0f b6 01             	movzbl (%ecx),%eax
  800c86:	84 c0                	test   %al,%al
  800c88:	74 0e                	je     800c98 <strncmp+0x41>
  800c8a:	3a 03                	cmp    (%ebx),%al
  800c8c:	74 ea                	je     800c78 <strncmp+0x21>
  800c8e:	eb 08                	jmp    800c98 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c90:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c95:	5b                   	pop    %ebx
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c98:	0f b6 01             	movzbl (%ecx),%eax
  800c9b:	0f b6 13             	movzbl (%ebx),%edx
  800c9e:	29 d0                	sub    %edx,%eax
  800ca0:	eb f3                	jmp    800c95 <strncmp+0x3e>

00800ca2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cac:	0f b6 10             	movzbl (%eax),%edx
  800caf:	84 d2                	test   %dl,%dl
  800cb1:	74 20                	je     800cd3 <strchr+0x31>
		if (*s == c)
  800cb3:	38 ca                	cmp    %cl,%dl
  800cb5:	75 0b                	jne    800cc2 <strchr+0x20>
  800cb7:	eb 1f                	jmp    800cd8 <strchr+0x36>
  800cb9:	38 ca                	cmp    %cl,%dl
  800cbb:	90                   	nop
  800cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cc0:	74 16                	je     800cd8 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cc2:	83 c0 01             	add    $0x1,%eax
  800cc5:	0f b6 10             	movzbl (%eax),%edx
  800cc8:	84 d2                	test   %dl,%dl
  800cca:	75 ed                	jne    800cb9 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800ccc:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd1:	eb 05                	jmp    800cd8 <strchr+0x36>
  800cd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ce4:	0f b6 10             	movzbl (%eax),%edx
  800ce7:	84 d2                	test   %dl,%dl
  800ce9:	74 14                	je     800cff <strfind+0x25>
		if (*s == c)
  800ceb:	38 ca                	cmp    %cl,%dl
  800ced:	75 06                	jne    800cf5 <strfind+0x1b>
  800cef:	eb 0e                	jmp    800cff <strfind+0x25>
  800cf1:	38 ca                	cmp    %cl,%dl
  800cf3:	74 0a                	je     800cff <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cf5:	83 c0 01             	add    $0x1,%eax
  800cf8:	0f b6 10             	movzbl (%eax),%edx
  800cfb:	84 d2                	test   %dl,%dl
  800cfd:	75 f2                	jne    800cf1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	89 1c 24             	mov    %ebx,(%esp)
  800d0a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d0e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d12:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d1b:	85 c9                	test   %ecx,%ecx
  800d1d:	74 30                	je     800d4f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d25:	75 25                	jne    800d4c <memset+0x4b>
  800d27:	f6 c1 03             	test   $0x3,%cl
  800d2a:	75 20                	jne    800d4c <memset+0x4b>
		c &= 0xFF;
  800d2c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d2f:	89 d3                	mov    %edx,%ebx
  800d31:	c1 e3 08             	shl    $0x8,%ebx
  800d34:	89 d6                	mov    %edx,%esi
  800d36:	c1 e6 18             	shl    $0x18,%esi
  800d39:	89 d0                	mov    %edx,%eax
  800d3b:	c1 e0 10             	shl    $0x10,%eax
  800d3e:	09 f0                	or     %esi,%eax
  800d40:	09 d0                	or     %edx,%eax
  800d42:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d44:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d47:	fc                   	cld    
  800d48:	f3 ab                	rep stos %eax,%es:(%edi)
  800d4a:	eb 03                	jmp    800d4f <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d4c:	fc                   	cld    
  800d4d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d4f:	89 f8                	mov    %edi,%eax
  800d51:	8b 1c 24             	mov    (%esp),%ebx
  800d54:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d58:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d5c:	89 ec                	mov    %ebp,%esp
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 08             	sub    $0x8,%esp
  800d66:	89 34 24             	mov    %esi,(%esp)
  800d69:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d73:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d76:	39 c6                	cmp    %eax,%esi
  800d78:	73 36                	jae    800db0 <memmove+0x50>
  800d7a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d7d:	39 d0                	cmp    %edx,%eax
  800d7f:	73 2f                	jae    800db0 <memmove+0x50>
		s += n;
		d += n;
  800d81:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d84:	f6 c2 03             	test   $0x3,%dl
  800d87:	75 1b                	jne    800da4 <memmove+0x44>
  800d89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d8f:	75 13                	jne    800da4 <memmove+0x44>
  800d91:	f6 c1 03             	test   $0x3,%cl
  800d94:	75 0e                	jne    800da4 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d96:	83 ef 04             	sub    $0x4,%edi
  800d99:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d9c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d9f:	fd                   	std    
  800da0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800da2:	eb 09                	jmp    800dad <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800da4:	83 ef 01             	sub    $0x1,%edi
  800da7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800daa:	fd                   	std    
  800dab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dad:	fc                   	cld    
  800dae:	eb 20                	jmp    800dd0 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800db0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800db6:	75 13                	jne    800dcb <memmove+0x6b>
  800db8:	a8 03                	test   $0x3,%al
  800dba:	75 0f                	jne    800dcb <memmove+0x6b>
  800dbc:	f6 c1 03             	test   $0x3,%cl
  800dbf:	75 0a                	jne    800dcb <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800dc1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800dc4:	89 c7                	mov    %eax,%edi
  800dc6:	fc                   	cld    
  800dc7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dc9:	eb 05                	jmp    800dd0 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dcb:	89 c7                	mov    %eax,%edi
  800dcd:	fc                   	cld    
  800dce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dd0:	8b 34 24             	mov    (%esp),%esi
  800dd3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dd7:	89 ec                	mov    %ebp,%esp
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800de1:	8b 45 10             	mov    0x10(%ebp),%eax
  800de4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800de8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800deb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800def:	8b 45 08             	mov    0x8(%ebp),%eax
  800df2:	89 04 24             	mov    %eax,(%esp)
  800df5:	e8 66 ff ff ff       	call   800d60 <memmove>
}
  800dfa:	c9                   	leave  
  800dfb:	c3                   	ret    

00800dfc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e08:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e0b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e10:	85 ff                	test   %edi,%edi
  800e12:	74 38                	je     800e4c <memcmp+0x50>
		if (*s1 != *s2)
  800e14:	0f b6 03             	movzbl (%ebx),%eax
  800e17:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e1a:	83 ef 01             	sub    $0x1,%edi
  800e1d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800e22:	38 c8                	cmp    %cl,%al
  800e24:	74 1d                	je     800e43 <memcmp+0x47>
  800e26:	eb 11                	jmp    800e39 <memcmp+0x3d>
  800e28:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e2d:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800e32:	83 c2 01             	add    $0x1,%edx
  800e35:	38 c8                	cmp    %cl,%al
  800e37:	74 0a                	je     800e43 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800e39:	0f b6 c0             	movzbl %al,%eax
  800e3c:	0f b6 c9             	movzbl %cl,%ecx
  800e3f:	29 c8                	sub    %ecx,%eax
  800e41:	eb 09                	jmp    800e4c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e43:	39 fa                	cmp    %edi,%edx
  800e45:	75 e1                	jne    800e28 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e57:	89 c2                	mov    %eax,%edx
  800e59:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e5c:	39 d0                	cmp    %edx,%eax
  800e5e:	73 15                	jae    800e75 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e64:	38 08                	cmp    %cl,(%eax)
  800e66:	75 06                	jne    800e6e <memfind+0x1d>
  800e68:	eb 0b                	jmp    800e75 <memfind+0x24>
  800e6a:	38 08                	cmp    %cl,(%eax)
  800e6c:	74 07                	je     800e75 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e6e:	83 c0 01             	add    $0x1,%eax
  800e71:	39 c2                	cmp    %eax,%edx
  800e73:	77 f5                	ja     800e6a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e83:	0f b6 02             	movzbl (%edx),%eax
  800e86:	3c 20                	cmp    $0x20,%al
  800e88:	74 04                	je     800e8e <strtol+0x17>
  800e8a:	3c 09                	cmp    $0x9,%al
  800e8c:	75 0e                	jne    800e9c <strtol+0x25>
		s++;
  800e8e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e91:	0f b6 02             	movzbl (%edx),%eax
  800e94:	3c 20                	cmp    $0x20,%al
  800e96:	74 f6                	je     800e8e <strtol+0x17>
  800e98:	3c 09                	cmp    $0x9,%al
  800e9a:	74 f2                	je     800e8e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e9c:	3c 2b                	cmp    $0x2b,%al
  800e9e:	75 0a                	jne    800eaa <strtol+0x33>
		s++;
  800ea0:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ea3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ea8:	eb 10                	jmp    800eba <strtol+0x43>
  800eaa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800eaf:	3c 2d                	cmp    $0x2d,%al
  800eb1:	75 07                	jne    800eba <strtol+0x43>
		s++, neg = 1;
  800eb3:	83 c2 01             	add    $0x1,%edx
  800eb6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eba:	85 db                	test   %ebx,%ebx
  800ebc:	0f 94 c0             	sete   %al
  800ebf:	74 05                	je     800ec6 <strtol+0x4f>
  800ec1:	83 fb 10             	cmp    $0x10,%ebx
  800ec4:	75 15                	jne    800edb <strtol+0x64>
  800ec6:	80 3a 30             	cmpb   $0x30,(%edx)
  800ec9:	75 10                	jne    800edb <strtol+0x64>
  800ecb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ecf:	75 0a                	jne    800edb <strtol+0x64>
		s += 2, base = 16;
  800ed1:	83 c2 02             	add    $0x2,%edx
  800ed4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ed9:	eb 13                	jmp    800eee <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800edb:	84 c0                	test   %al,%al
  800edd:	74 0f                	je     800eee <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800edf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ee4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ee7:	75 05                	jne    800eee <strtol+0x77>
		s++, base = 8;
  800ee9:	83 c2 01             	add    $0x1,%edx
  800eec:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800eee:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef3:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ef5:	0f b6 0a             	movzbl (%edx),%ecx
  800ef8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800efb:	80 fb 09             	cmp    $0x9,%bl
  800efe:	77 08                	ja     800f08 <strtol+0x91>
			dig = *s - '0';
  800f00:	0f be c9             	movsbl %cl,%ecx
  800f03:	83 e9 30             	sub    $0x30,%ecx
  800f06:	eb 1e                	jmp    800f26 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800f08:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f0b:	80 fb 19             	cmp    $0x19,%bl
  800f0e:	77 08                	ja     800f18 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800f10:	0f be c9             	movsbl %cl,%ecx
  800f13:	83 e9 57             	sub    $0x57,%ecx
  800f16:	eb 0e                	jmp    800f26 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800f18:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f1b:	80 fb 19             	cmp    $0x19,%bl
  800f1e:	77 15                	ja     800f35 <strtol+0xbe>
			dig = *s - 'A' + 10;
  800f20:	0f be c9             	movsbl %cl,%ecx
  800f23:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f26:	39 f1                	cmp    %esi,%ecx
  800f28:	7d 0f                	jge    800f39 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  800f2a:	83 c2 01             	add    $0x1,%edx
  800f2d:	0f af c6             	imul   %esi,%eax
  800f30:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f33:	eb c0                	jmp    800ef5 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f35:	89 c1                	mov    %eax,%ecx
  800f37:	eb 02                	jmp    800f3b <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f39:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f3b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f3f:	74 05                	je     800f46 <strtol+0xcf>
		*endptr = (char *) s;
  800f41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f44:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f46:	89 ca                	mov    %ecx,%edx
  800f48:	f7 da                	neg    %edx
  800f4a:	85 ff                	test   %edi,%edi
  800f4c:	0f 45 c2             	cmovne %edx,%eax
}
  800f4f:	5b                   	pop    %ebx
  800f50:	5e                   	pop    %esi
  800f51:	5f                   	pop    %edi
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    
	...

00800f60 <__udivdi3>:
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	57                   	push   %edi
  800f64:	56                   	push   %esi
  800f65:	83 ec 10             	sub    $0x10,%esp
  800f68:	8b 75 14             	mov    0x14(%ebp),%esi
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f71:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f74:	85 f6                	test   %esi,%esi
  800f76:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f79:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f7f:	75 2f                	jne    800fb0 <__udivdi3+0x50>
  800f81:	39 f9                	cmp    %edi,%ecx
  800f83:	77 5b                	ja     800fe0 <__udivdi3+0x80>
  800f85:	85 c9                	test   %ecx,%ecx
  800f87:	75 0b                	jne    800f94 <__udivdi3+0x34>
  800f89:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8e:	31 d2                	xor    %edx,%edx
  800f90:	f7 f1                	div    %ecx
  800f92:	89 c1                	mov    %eax,%ecx
  800f94:	89 f8                	mov    %edi,%eax
  800f96:	31 d2                	xor    %edx,%edx
  800f98:	f7 f1                	div    %ecx
  800f9a:	89 c7                	mov    %eax,%edi
  800f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9f:	f7 f1                	div    %ecx
  800fa1:	89 fa                	mov    %edi,%edx
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    
  800faa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fb0:	31 d2                	xor    %edx,%edx
  800fb2:	31 c0                	xor    %eax,%eax
  800fb4:	39 fe                	cmp    %edi,%esi
  800fb6:	77 eb                	ja     800fa3 <__udivdi3+0x43>
  800fb8:	0f bd d6             	bsr    %esi,%edx
  800fbb:	83 f2 1f             	xor    $0x1f,%edx
  800fbe:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fc1:	75 2d                	jne    800ff0 <__udivdi3+0x90>
  800fc3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800fc6:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  800fc9:	76 06                	jbe    800fd1 <__udivdi3+0x71>
  800fcb:	39 fe                	cmp    %edi,%esi
  800fcd:	89 c2                	mov    %eax,%edx
  800fcf:	73 d2                	jae    800fa3 <__udivdi3+0x43>
  800fd1:	31 d2                	xor    %edx,%edx
  800fd3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd8:	eb c9                	jmp    800fa3 <__udivdi3+0x43>
  800fda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fe0:	89 fa                	mov    %edi,%edx
  800fe2:	f7 f1                	div    %ecx
  800fe4:	31 d2                	xor    %edx,%edx
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    
  800fed:	8d 76 00             	lea    0x0(%esi),%esi
  800ff0:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800ff4:	b8 20 00 00 00       	mov    $0x20,%eax
  800ff9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ffc:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800fff:	d3 e6                	shl    %cl,%esi
  801001:	89 c1                	mov    %eax,%ecx
  801003:	d3 ea                	shr    %cl,%edx
  801005:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801009:	09 f2                	or     %esi,%edx
  80100b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  80100e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801011:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801014:	d3 e2                	shl    %cl,%edx
  801016:	89 c1                	mov    %eax,%ecx
  801018:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80101b:	89 fa                	mov    %edi,%edx
  80101d:	d3 ea                	shr    %cl,%edx
  80101f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801023:	d3 e7                	shl    %cl,%edi
  801025:	89 c1                	mov    %eax,%ecx
  801027:	d3 ee                	shr    %cl,%esi
  801029:	09 fe                	or     %edi,%esi
  80102b:	89 f0                	mov    %esi,%eax
  80102d:	f7 75 e8             	divl   -0x18(%ebp)
  801030:	89 d7                	mov    %edx,%edi
  801032:	89 c6                	mov    %eax,%esi
  801034:	f7 65 f0             	mull   -0x10(%ebp)
  801037:	39 d7                	cmp    %edx,%edi
  801039:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80103c:	72 22                	jb     801060 <__udivdi3+0x100>
  80103e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801041:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801045:	d3 e2                	shl    %cl,%edx
  801047:	39 c2                	cmp    %eax,%edx
  801049:	73 05                	jae    801050 <__udivdi3+0xf0>
  80104b:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  80104e:	74 10                	je     801060 <__udivdi3+0x100>
  801050:	89 f0                	mov    %esi,%eax
  801052:	31 d2                	xor    %edx,%edx
  801054:	e9 4a ff ff ff       	jmp    800fa3 <__udivdi3+0x43>
  801059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801060:	8d 46 ff             	lea    -0x1(%esi),%eax
  801063:	31 d2                	xor    %edx,%edx
  801065:	83 c4 10             	add    $0x10,%esp
  801068:	5e                   	pop    %esi
  801069:	5f                   	pop    %edi
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    
  80106c:	00 00                	add    %al,(%eax)
	...

00801070 <__umoddi3>:
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	83 ec 20             	sub    $0x20,%esp
  801078:	8b 7d 14             	mov    0x14(%ebp),%edi
  80107b:	8b 45 08             	mov    0x8(%ebp),%eax
  80107e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801081:	8b 75 0c             	mov    0xc(%ebp),%esi
  801084:	85 ff                	test   %edi,%edi
  801086:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801089:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80108c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80108f:	89 f2                	mov    %esi,%edx
  801091:	75 15                	jne    8010a8 <__umoddi3+0x38>
  801093:	39 f1                	cmp    %esi,%ecx
  801095:	76 41                	jbe    8010d8 <__umoddi3+0x68>
  801097:	f7 f1                	div    %ecx
  801099:	89 d0                	mov    %edx,%eax
  80109b:	31 d2                	xor    %edx,%edx
  80109d:	83 c4 20             	add    $0x20,%esp
  8010a0:	5e                   	pop    %esi
  8010a1:	5f                   	pop    %edi
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    
  8010a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010a8:	39 f7                	cmp    %esi,%edi
  8010aa:	77 4c                	ja     8010f8 <__umoddi3+0x88>
  8010ac:	0f bd c7             	bsr    %edi,%eax
  8010af:	83 f0 1f             	xor    $0x1f,%eax
  8010b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010b5:	75 51                	jne    801108 <__umoddi3+0x98>
  8010b7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8010ba:	0f 87 e8 00 00 00    	ja     8011a8 <__umoddi3+0x138>
  8010c0:	89 f2                	mov    %esi,%edx
  8010c2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8010c5:	29 ce                	sub    %ecx,%esi
  8010c7:	19 fa                	sbb    %edi,%edx
  8010c9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  8010cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cf:	83 c4 20             	add    $0x20,%esp
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    
  8010d6:	66 90                	xchg   %ax,%ax
  8010d8:	85 c9                	test   %ecx,%ecx
  8010da:	75 0b                	jne    8010e7 <__umoddi3+0x77>
  8010dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e1:	31 d2                	xor    %edx,%edx
  8010e3:	f7 f1                	div    %ecx
  8010e5:	89 c1                	mov    %eax,%ecx
  8010e7:	89 f0                	mov    %esi,%eax
  8010e9:	31 d2                	xor    %edx,%edx
  8010eb:	f7 f1                	div    %ecx
  8010ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f0:	eb a5                	jmp    801097 <__umoddi3+0x27>
  8010f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010f8:	89 f2                	mov    %esi,%edx
  8010fa:	83 c4 20             	add    $0x20,%esp
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    
  801101:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801108:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80110c:	89 f2                	mov    %esi,%edx
  80110e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801111:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801118:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80111b:	d3 e7                	shl    %cl,%edi
  80111d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801120:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801124:	d3 e8                	shr    %cl,%eax
  801126:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80112a:	09 f8                	or     %edi,%eax
  80112c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80112f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801132:	d3 e0                	shl    %cl,%eax
  801134:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801138:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80113b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80113e:	d3 ea                	shr    %cl,%edx
  801140:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801144:	d3 e6                	shl    %cl,%esi
  801146:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80114a:	d3 e8                	shr    %cl,%eax
  80114c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801150:	09 f0                	or     %esi,%eax
  801152:	8b 75 e8             	mov    -0x18(%ebp),%esi
  801155:	f7 75 e4             	divl   -0x1c(%ebp)
  801158:	d3 e6                	shl    %cl,%esi
  80115a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80115d:	89 d6                	mov    %edx,%esi
  80115f:	f7 65 f4             	mull   -0xc(%ebp)
  801162:	89 d7                	mov    %edx,%edi
  801164:	89 c2                	mov    %eax,%edx
  801166:	39 fe                	cmp    %edi,%esi
  801168:	89 f9                	mov    %edi,%ecx
  80116a:	72 30                	jb     80119c <__umoddi3+0x12c>
  80116c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80116f:	72 27                	jb     801198 <__umoddi3+0x128>
  801171:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801174:	29 d0                	sub    %edx,%eax
  801176:	19 ce                	sbb    %ecx,%esi
  801178:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80117c:	89 f2                	mov    %esi,%edx
  80117e:	d3 e8                	shr    %cl,%eax
  801180:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801184:	d3 e2                	shl    %cl,%edx
  801186:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80118a:	09 d0                	or     %edx,%eax
  80118c:	89 f2                	mov    %esi,%edx
  80118e:	d3 ea                	shr    %cl,%edx
  801190:	83 c4 20             	add    $0x20,%esp
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    
  801197:	90                   	nop
  801198:	39 fe                	cmp    %edi,%esi
  80119a:	75 d5                	jne    801171 <__umoddi3+0x101>
  80119c:	89 f9                	mov    %edi,%ecx
  80119e:	89 c2                	mov    %eax,%edx
  8011a0:	2b 55 f4             	sub    -0xc(%ebp),%edx
  8011a3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011a6:	eb c9                	jmp    801171 <__umoddi3+0x101>
  8011a8:	39 f7                	cmp    %esi,%edi
  8011aa:	0f 82 10 ff ff ff    	jb     8010c0 <__umoddi3+0x50>
  8011b0:	e9 17 ff ff ff       	jmp    8010cc <__umoddi3+0x5c>
