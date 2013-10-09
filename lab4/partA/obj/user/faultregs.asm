
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 67 05 00 00       	call   800598 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	89 c3                	mov    %eax,%ebx
  80003f:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	8b 45 08             	mov    0x8(%ebp),%eax
  800044:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800048:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004c:	c7 44 24 04 71 17 80 	movl   $0x801771,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 40 17 80 00 	movl   $0x801740,(%esp)
  80005b:	e8 97 06 00 00       	call   8006f7 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 06                	mov    (%esi),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 50 17 80 	movl   $0x801750,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 54 17 80 00 	movl   $0x801754,(%esp)
  80007b:	e8 77 06 00 00       	call   8006f7 <cprintf>
  800080:	8b 06                	mov    (%esi),%eax
  800082:	39 03                	cmp    %eax,(%ebx)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 64 17 80 00 	movl   $0x801764,(%esp)
  80008d:	e8 65 06 00 00       	call   8006f7 <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800092:	bf 00 00 00 00       	mov    $0x0,%edi
  800097:	eb 11                	jmp    8000aa <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800099:	c7 04 24 68 17 80 00 	movl   $0x801768,(%esp)
  8000a0:	e8 52 06 00 00       	call   8006f7 <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 46 04             	mov    0x4(%esi),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 72 17 80 	movl   $0x801772,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 54 17 80 00 	movl   $0x801754,(%esp)
  8000c7:	e8 2b 06 00 00       	call   8006f7 <cprintf>
  8000cc:	8b 46 04             	mov    0x4(%esi),%eax
  8000cf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 64 17 80 00 	movl   $0x801764,(%esp)
  8000db:	e8 17 06 00 00       	call   8006f7 <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 68 17 80 00 	movl   $0x801768,(%esp)
  8000e9:	e8 09 06 00 00       	call   8006f7 <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 46 08             	mov    0x8(%esi),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 76 17 80 	movl   $0x801776,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 54 17 80 00 	movl   $0x801754,(%esp)
  800110:	e8 e2 05 00 00       	call   8006f7 <cprintf>
  800115:	8b 46 08             	mov    0x8(%esi),%eax
  800118:	39 43 08             	cmp    %eax,0x8(%ebx)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 64 17 80 00 	movl   $0x801764,(%esp)
  800124:	e8 ce 05 00 00       	call   8006f7 <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 68 17 80 00 	movl   $0x801768,(%esp)
  800132:	e8 c0 05 00 00       	call   8006f7 <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 46 10             	mov    0x10(%esi),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 43 10             	mov    0x10(%ebx),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 7a 17 80 	movl   $0x80177a,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 54 17 80 00 	movl   $0x801754,(%esp)
  800159:	e8 99 05 00 00       	call   8006f7 <cprintf>
  80015e:	8b 46 10             	mov    0x10(%esi),%eax
  800161:	39 43 10             	cmp    %eax,0x10(%ebx)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 64 17 80 00 	movl   $0x801764,(%esp)
  80016d:	e8 85 05 00 00       	call   8006f7 <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 68 17 80 00 	movl   $0x801768,(%esp)
  80017b:	e8 77 05 00 00       	call   8006f7 <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 46 14             	mov    0x14(%esi),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 43 14             	mov    0x14(%ebx),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 7e 17 80 	movl   $0x80177e,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 54 17 80 00 	movl   $0x801754,(%esp)
  8001a2:	e8 50 05 00 00       	call   8006f7 <cprintf>
  8001a7:	8b 46 14             	mov    0x14(%esi),%eax
  8001aa:	39 43 14             	cmp    %eax,0x14(%ebx)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 64 17 80 00 	movl   $0x801764,(%esp)
  8001b6:	e8 3c 05 00 00       	call   8006f7 <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 68 17 80 00 	movl   $0x801768,(%esp)
  8001c4:	e8 2e 05 00 00       	call   8006f7 <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 46 18             	mov    0x18(%esi),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 82 17 80 	movl   $0x801782,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 54 17 80 00 	movl   $0x801754,(%esp)
  8001eb:	e8 07 05 00 00       	call   8006f7 <cprintf>
  8001f0:	8b 46 18             	mov    0x18(%esi),%eax
  8001f3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 64 17 80 00 	movl   $0x801764,(%esp)
  8001ff:	e8 f3 04 00 00       	call   8006f7 <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 68 17 80 00 	movl   $0x801768,(%esp)
  80020d:	e8 e5 04 00 00       	call   8006f7 <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 86 17 80 	movl   $0x801786,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 54 17 80 00 	movl   $0x801754,(%esp)
  800234:	e8 be 04 00 00       	call   8006f7 <cprintf>
  800239:	8b 46 1c             	mov    0x1c(%esi),%eax
  80023c:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 64 17 80 00 	movl   $0x801764,(%esp)
  800248:	e8 aa 04 00 00       	call   8006f7 <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 68 17 80 00 	movl   $0x801768,(%esp)
  800256:	e8 9c 04 00 00       	call   8006f7 <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 46 20             	mov    0x20(%esi),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 43 20             	mov    0x20(%ebx),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 8a 17 80 	movl   $0x80178a,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 54 17 80 00 	movl   $0x801754,(%esp)
  80027d:	e8 75 04 00 00       	call   8006f7 <cprintf>
  800282:	8b 46 20             	mov    0x20(%esi),%eax
  800285:	39 43 20             	cmp    %eax,0x20(%ebx)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 64 17 80 00 	movl   $0x801764,(%esp)
  800291:	e8 61 04 00 00       	call   8006f7 <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 68 17 80 00 	movl   $0x801768,(%esp)
  80029f:	e8 53 04 00 00       	call   8006f7 <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 46 24             	mov    0x24(%esi),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 43 24             	mov    0x24(%ebx),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 8e 17 80 	movl   $0x80178e,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 54 17 80 00 	movl   $0x801754,(%esp)
  8002c6:	e8 2c 04 00 00       	call   8006f7 <cprintf>
  8002cb:	8b 46 24             	mov    0x24(%esi),%eax
  8002ce:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 64 17 80 00 	movl   $0x801764,(%esp)
  8002da:	e8 18 04 00 00       	call   8006f7 <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 68 17 80 00 	movl   $0x801768,(%esp)
  8002e8:	e8 0a 04 00 00       	call   8006f7 <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 46 28             	mov    0x28(%esi),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 43 28             	mov    0x28(%ebx),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 95 17 80 	movl   $0x801795,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 54 17 80 00 	movl   $0x801754,(%esp)
  80030f:	e8 e3 03 00 00       	call   8006f7 <cprintf>
  800314:	8b 46 28             	mov    0x28(%esi),%eax
  800317:	39 43 28             	cmp    %eax,0x28(%ebx)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 64 17 80 00 	movl   $0x801764,(%esp)
  800323:	e8 cf 03 00 00       	call   8006f7 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 99 17 80 00 	movl   $0x801799,(%esp)
  800336:	e8 bc 03 00 00       	call   8006f7 <cprintf>
	if (!mismatch)
  80033b:	85 ff                	test   %edi,%edi
  80033d:	74 23                	je     800362 <check_regs+0x32e>
  80033f:	eb 2f                	jmp    800370 <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800341:	c7 04 24 68 17 80 00 	movl   $0x801768,(%esp)
  800348:	e8 aa 03 00 00       	call   8006f7 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 99 17 80 00 	movl   $0x801799,(%esp)
  80035b:	e8 97 03 00 00       	call   8006f7 <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 64 17 80 00 	movl   $0x801764,(%esp)
  800369:	e8 89 03 00 00       	call   8006f7 <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 68 17 80 00 	movl   $0x801768,(%esp)
  800377:	e8 7b 03 00 00       	call   8006f7 <cprintf>
}
  80037c:	83 c4 1c             	add    $0x1c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 28             	sub    $0x28,%esp
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800395:	74 27                	je     8003be <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800397:	8b 40 28             	mov    0x28(%eax),%eax
  80039a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a2:	c7 44 24 08 00 18 80 	movl   $0x801800,0x8(%esp)
  8003a9:	00 
  8003aa:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b1:	00 
  8003b2:	c7 04 24 a7 17 80 00 	movl   $0x8017a7,(%esp)
  8003b9:	e8 3e 02 00 00       	call   8005fc <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003be:	8b 50 08             	mov    0x8(%eax),%edx
  8003c1:	89 15 a0 20 80 00    	mov    %edx,0x8020a0
  8003c7:	8b 50 0c             	mov    0xc(%eax),%edx
  8003ca:	89 15 a4 20 80 00    	mov    %edx,0x8020a4
  8003d0:	8b 50 10             	mov    0x10(%eax),%edx
  8003d3:	89 15 a8 20 80 00    	mov    %edx,0x8020a8
  8003d9:	8b 50 14             	mov    0x14(%eax),%edx
  8003dc:	89 15 ac 20 80 00    	mov    %edx,0x8020ac
  8003e2:	8b 50 18             	mov    0x18(%eax),%edx
  8003e5:	89 15 b0 20 80 00    	mov    %edx,0x8020b0
  8003eb:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003ee:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8003f4:	8b 50 20             	mov    0x20(%eax),%edx
  8003f7:	89 15 b8 20 80 00    	mov    %edx,0x8020b8
  8003fd:	8b 50 24             	mov    0x24(%eax),%edx
  800400:	89 15 bc 20 80 00    	mov    %edx,0x8020bc
	during.eip = utf->utf_eip;
  800406:	8b 50 28             	mov    0x28(%eax),%edx
  800409:	89 15 c0 20 80 00    	mov    %edx,0x8020c0
	during.eflags = utf->utf_eflags;
  80040f:	8b 50 2c             	mov    0x2c(%eax),%edx
  800412:	89 15 c4 20 80 00    	mov    %edx,0x8020c4
	during.esp = utf->utf_esp;
  800418:	8b 40 30             	mov    0x30(%eax),%eax
  80041b:	a3 c8 20 80 00       	mov    %eax,0x8020c8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800420:	c7 44 24 04 bf 17 80 	movl   $0x8017bf,0x4(%esp)
  800427:	00 
  800428:	c7 04 24 cd 17 80 00 	movl   $0x8017cd,(%esp)
  80042f:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  800434:	ba b8 17 80 00       	mov    $0x8017b8,%edx
  800439:	b8 20 20 80 00       	mov    $0x802020,%eax
  80043e:	e8 f1 fb ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800443:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80044a:	00 
  80044b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800452:	00 
  800453:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80045a:	e8 d1 0d 00 00       	call   801230 <sys_page_alloc>
  80045f:	85 c0                	test   %eax,%eax
  800461:	79 20                	jns    800483 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800463:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800467:	c7 44 24 08 d4 17 80 	movl   $0x8017d4,0x8(%esp)
  80046e:	00 
  80046f:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800476:	00 
  800477:	c7 04 24 a7 17 80 00 	movl   $0x8017a7,(%esp)
  80047e:	e8 79 01 00 00       	call   8005fc <_panic>
}
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <umain>:

void
umain(int argc, char **argv)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  80048b:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  800492:	e8 05 10 00 00       	call   80149c <set_pgfault_handler>

	__asm __volatile(
  800497:	50                   	push   %eax
  800498:	9c                   	pushf  
  800499:	58                   	pop    %eax
  80049a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80049f:	50                   	push   %eax
  8004a0:	9d                   	popf   
  8004a1:	a3 44 20 80 00       	mov    %eax,0x802044
  8004a6:	8d 05 e1 04 80 00    	lea    0x8004e1,%eax
  8004ac:	a3 40 20 80 00       	mov    %eax,0x802040
  8004b1:	58                   	pop    %eax
  8004b2:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004b8:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004be:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004c4:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8004ca:	89 15 34 20 80 00    	mov    %edx,0x802034
  8004d0:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  8004d6:	a3 3c 20 80 00       	mov    %eax,0x80203c
  8004db:	89 25 48 20 80 00    	mov    %esp,0x802048
  8004e1:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e8:	00 00 00 
  8004eb:	89 3d 60 20 80 00    	mov    %edi,0x802060
  8004f1:	89 35 64 20 80 00    	mov    %esi,0x802064
  8004f7:	89 2d 68 20 80 00    	mov    %ebp,0x802068
  8004fd:	89 1d 70 20 80 00    	mov    %ebx,0x802070
  800503:	89 15 74 20 80 00    	mov    %edx,0x802074
  800509:	89 0d 78 20 80 00    	mov    %ecx,0x802078
  80050f:	a3 7c 20 80 00       	mov    %eax,0x80207c
  800514:	89 25 88 20 80 00    	mov    %esp,0x802088
  80051a:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  800520:	8b 35 24 20 80 00    	mov    0x802024,%esi
  800526:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  80052c:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  800532:	8b 15 34 20 80 00    	mov    0x802034,%edx
  800538:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  80053e:	a1 3c 20 80 00       	mov    0x80203c,%eax
  800543:	8b 25 48 20 80 00    	mov    0x802048,%esp
  800549:	50                   	push   %eax
  80054a:	9c                   	pushf  
  80054b:	58                   	pop    %eax
  80054c:	a3 84 20 80 00       	mov    %eax,0x802084
  800551:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800552:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800559:	74 0c                	je     800567 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80055b:	c7 04 24 34 18 80 00 	movl   $0x801834,(%esp)
  800562:	e8 90 01 00 00       	call   8006f7 <cprintf>
	after.eip = before.eip;
  800567:	a1 40 20 80 00       	mov    0x802040,%eax
  80056c:	a3 80 20 80 00       	mov    %eax,0x802080

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	c7 44 24 04 e7 17 80 	movl   $0x8017e7,0x4(%esp)
  800578:	00 
  800579:	c7 04 24 f8 17 80 00 	movl   $0x8017f8,(%esp)
  800580:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800585:	ba b8 17 80 00       	mov    $0x8017b8,%edx
  80058a:	b8 20 20 80 00       	mov    $0x802020,%eax
  80058f:	e8 a0 fa ff ff       	call   800034 <check_regs>
}
  800594:	c9                   	leave  
  800595:	c3                   	ret    
	...

00800598 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	83 ec 18             	sub    $0x18,%esp
  80059e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005a1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  8005aa:	e8 19 0c 00 00       	call   8011c8 <sys_getenvid>
  8005af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005bc:	a3 cc 20 80 00       	mov    %eax,0x8020cc
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005c1:	85 f6                	test   %esi,%esi
  8005c3:	7e 07                	jle    8005cc <libmain+0x34>
		binaryname = argv[0];
  8005c5:	8b 03                	mov    (%ebx),%eax
  8005c7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d0:	89 34 24             	mov    %esi,(%esp)
  8005d3:	e8 ad fe ff ff       	call   800485 <umain>

	// exit gracefully
	exit();
  8005d8:	e8 0b 00 00 00       	call   8005e8 <exit>
}
  8005dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005e0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8005e3:	89 ec                	mov    %ebp,%esp
  8005e5:	5d                   	pop    %ebp
  8005e6:	c3                   	ret    
	...

008005e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8005ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005f5:	e8 71 0b 00 00       	call   80116b <sys_env_destroy>
}
  8005fa:	c9                   	leave  
  8005fb:	c3                   	ret    

008005fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	56                   	push   %esi
  800600:	53                   	push   %ebx
  800601:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800604:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800607:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80060d:	e8 b6 0b 00 00       	call   8011c8 <sys_getenvid>
  800612:	8b 55 0c             	mov    0xc(%ebp),%edx
  800615:	89 54 24 10          	mov    %edx,0x10(%esp)
  800619:	8b 55 08             	mov    0x8(%ebp),%edx
  80061c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800620:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800624:	89 44 24 04          	mov    %eax,0x4(%esp)
  800628:	c7 04 24 60 18 80 00 	movl   $0x801860,(%esp)
  80062f:	e8 c3 00 00 00       	call   8006f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800634:	89 74 24 04          	mov    %esi,0x4(%esp)
  800638:	8b 45 10             	mov    0x10(%ebp),%eax
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	e8 53 00 00 00       	call   800696 <vcprintf>
	cprintf("\n");
  800643:	c7 04 24 70 17 80 00 	movl   $0x801770,(%esp)
  80064a:	e8 a8 00 00 00       	call   8006f7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80064f:	cc                   	int3   
  800650:	eb fd                	jmp    80064f <_panic+0x53>
	...

00800654 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
  800657:	53                   	push   %ebx
  800658:	83 ec 14             	sub    $0x14,%esp
  80065b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80065e:	8b 03                	mov    (%ebx),%eax
  800660:	8b 55 08             	mov    0x8(%ebp),%edx
  800663:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800667:	83 c0 01             	add    $0x1,%eax
  80066a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80066c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800671:	75 19                	jne    80068c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800673:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80067a:	00 
  80067b:	8d 43 08             	lea    0x8(%ebx),%eax
  80067e:	89 04 24             	mov    %eax,(%esp)
  800681:	e8 7e 0a 00 00       	call   801104 <sys_cputs>
		b->idx = 0;
  800686:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80068c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800690:	83 c4 14             	add    $0x14,%esp
  800693:	5b                   	pop    %ebx
  800694:	5d                   	pop    %ebp
  800695:	c3                   	ret    

00800696 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
  800699:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80069f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006a6:	00 00 00 
	b.cnt = 0;
  8006a9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006b0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cb:	c7 04 24 54 06 80 00 	movl   $0x800654,(%esp)
  8006d2:	e8 ea 01 00 00       	call   8008c1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006d7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006e7:	89 04 24             	mov    %eax,(%esp)
  8006ea:	e8 15 0a 00 00       	call   801104 <sys_cputs>

	return b.cnt;
}
  8006ef:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    

008006f7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800700:	89 44 24 04          	mov    %eax,0x4(%esp)
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	89 04 24             	mov    %eax,(%esp)
  80070a:	e8 87 ff ff ff       	call   800696 <vcprintf>
	va_end(ap);

	return cnt;
}
  80070f:	c9                   	leave  
  800710:	c3                   	ret    
	...

00800720 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	57                   	push   %edi
  800724:	56                   	push   %esi
  800725:	53                   	push   %ebx
  800726:	83 ec 4c             	sub    $0x4c,%esp
  800729:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072c:	89 d6                	mov    %edx,%esi
  80072e:	8b 45 08             	mov    0x8(%ebp),%eax
  800731:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800734:	8b 55 0c             	mov    0xc(%ebp),%edx
  800737:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80073a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80073d:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800740:	b8 00 00 00 00       	mov    $0x0,%eax
  800745:	39 d0                	cmp    %edx,%eax
  800747:	72 11                	jb     80075a <printnum+0x3a>
  800749:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80074c:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  80074f:	76 09                	jbe    80075a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800751:	83 eb 01             	sub    $0x1,%ebx
  800754:	85 db                	test   %ebx,%ebx
  800756:	7f 5d                	jg     8007b5 <printnum+0x95>
  800758:	eb 6c                	jmp    8007c6 <printnum+0xa6>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80075a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80075e:	83 eb 01             	sub    $0x1,%ebx
  800761:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800765:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800768:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80076c:	8b 44 24 08          	mov    0x8(%esp),%eax
  800770:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800774:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800777:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80077a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800781:	00 
  800782:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800785:	89 14 24             	mov    %edx,(%esp)
  800788:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80078b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80078f:	e8 4c 0d 00 00       	call   8014e0 <__udivdi3>
  800794:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800797:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80079a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80079e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007a2:	89 04 24             	mov    %eax,(%esp)
  8007a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a9:	89 f2                	mov    %esi,%edx
  8007ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007ae:	e8 6d ff ff ff       	call   800720 <printnum>
  8007b3:	eb 11                	jmp    8007c6 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b9:	89 3c 24             	mov    %edi,(%esp)
  8007bc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007bf:	83 eb 01             	sub    $0x1,%ebx
  8007c2:	85 db                	test   %ebx,%ebx
  8007c4:	7f ef                	jg     8007b5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ca:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007dc:	00 
  8007dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007e0:	89 14 24             	mov    %edx,(%esp)
  8007e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007e6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007ea:	e8 01 0e 00 00       	call   8015f0 <__umoddi3>
  8007ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f3:	0f be 80 83 18 80 00 	movsbl 0x801883(%eax),%eax
  8007fa:	89 04 24             	mov    %eax,(%esp)
  8007fd:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800800:	83 c4 4c             	add    $0x4c,%esp
  800803:	5b                   	pop    %ebx
  800804:	5e                   	pop    %esi
  800805:	5f                   	pop    %edi
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80080b:	83 fa 01             	cmp    $0x1,%edx
  80080e:	7e 0e                	jle    80081e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800810:	8b 10                	mov    (%eax),%edx
  800812:	8d 4a 08             	lea    0x8(%edx),%ecx
  800815:	89 08                	mov    %ecx,(%eax)
  800817:	8b 02                	mov    (%edx),%eax
  800819:	8b 52 04             	mov    0x4(%edx),%edx
  80081c:	eb 22                	jmp    800840 <getuint+0x38>
	else if (lflag)
  80081e:	85 d2                	test   %edx,%edx
  800820:	74 10                	je     800832 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800822:	8b 10                	mov    (%eax),%edx
  800824:	8d 4a 04             	lea    0x4(%edx),%ecx
  800827:	89 08                	mov    %ecx,(%eax)
  800829:	8b 02                	mov    (%edx),%eax
  80082b:	ba 00 00 00 00       	mov    $0x0,%edx
  800830:	eb 0e                	jmp    800840 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800832:	8b 10                	mov    (%eax),%edx
  800834:	8d 4a 04             	lea    0x4(%edx),%ecx
  800837:	89 08                	mov    %ecx,(%eax)
  800839:	8b 02                	mov    (%edx),%eax
  80083b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800845:	83 fa 01             	cmp    $0x1,%edx
  800848:	7e 0e                	jle    800858 <getint+0x16>
		return va_arg(*ap, long long);
  80084a:	8b 10                	mov    (%eax),%edx
  80084c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80084f:	89 08                	mov    %ecx,(%eax)
  800851:	8b 02                	mov    (%edx),%eax
  800853:	8b 52 04             	mov    0x4(%edx),%edx
  800856:	eb 22                	jmp    80087a <getint+0x38>
	else if (lflag)
  800858:	85 d2                	test   %edx,%edx
  80085a:	74 10                	je     80086c <getint+0x2a>
		return va_arg(*ap, long);
  80085c:	8b 10                	mov    (%eax),%edx
  80085e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800861:	89 08                	mov    %ecx,(%eax)
  800863:	8b 02                	mov    (%edx),%eax
  800865:	89 c2                	mov    %eax,%edx
  800867:	c1 fa 1f             	sar    $0x1f,%edx
  80086a:	eb 0e                	jmp    80087a <getint+0x38>
	else
		return va_arg(*ap, int);
  80086c:	8b 10                	mov    (%eax),%edx
  80086e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800871:	89 08                	mov    %ecx,(%eax)
  800873:	8b 02                	mov    (%edx),%eax
  800875:	89 c2                	mov    %eax,%edx
  800877:	c1 fa 1f             	sar    $0x1f,%edx
}
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800882:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800886:	8b 10                	mov    (%eax),%edx
  800888:	3b 50 04             	cmp    0x4(%eax),%edx
  80088b:	73 0a                	jae    800897 <sprintputch+0x1b>
		*b->buf++ = ch;
  80088d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800890:	88 0a                	mov    %cl,(%edx)
  800892:	83 c2 01             	add    $0x1,%edx
  800895:	89 10                	mov    %edx,(%eax)
}
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80089f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8008a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	89 04 24             	mov    %eax,(%esp)
  8008ba:	e8 02 00 00 00       	call   8008c1 <vprintfmt>
	va_end(ap);
}
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	57                   	push   %edi
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	83 ec 4c             	sub    $0x4c,%esp
  8008ca:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008cd:	eb 23                	jmp    8008f2 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	75 12                	jne    8008e5 <vprintfmt+0x24>
				csa = 0x0700;
  8008d3:	c7 05 d0 20 80 00 00 	movl   $0x700,0x8020d0
  8008da:	07 00 00 
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8008dd:	83 c4 4c             	add    $0x4c,%esp
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5f                   	pop    %edi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
				csa = 0x0700;
				return;
			}
			putch(ch, putdat);
  8008e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ec:	89 04 24             	mov    %eax,(%esp)
  8008ef:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008f2:	0f b6 07             	movzbl (%edi),%eax
  8008f5:	83 c7 01             	add    $0x1,%edi
  8008f8:	83 f8 25             	cmp    $0x25,%eax
  8008fb:	75 d2                	jne    8008cf <vprintfmt+0xe>
  8008fd:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800901:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800908:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80090d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800914:	ba 00 00 00 00       	mov    $0x0,%edx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800919:	be 00 00 00 00       	mov    $0x0,%esi
  80091e:	eb 14                	jmp    800934 <vprintfmt+0x73>
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
  800920:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800924:	eb 0e                	jmp    800934 <vprintfmt+0x73>
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800926:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80092a:	eb 08                	jmp    800934 <vprintfmt+0x73>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80092c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80092f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800934:	0f b6 07             	movzbl (%edi),%eax
  800937:	0f b6 c8             	movzbl %al,%ecx
  80093a:	83 c7 01             	add    $0x1,%edi
  80093d:	83 e8 23             	sub    $0x23,%eax
  800940:	3c 55                	cmp    $0x55,%al
  800942:	0f 87 ed 02 00 00    	ja     800c35 <vprintfmt+0x374>
  800948:	0f b6 c0             	movzbl %al,%eax
  80094b:	ff 24 85 40 19 80 00 	jmp    *0x801940(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800952:	8d 59 d0             	lea    -0x30(%ecx),%ebx
				ch = *fmt;
  800955:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800958:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80095b:	83 f9 09             	cmp    $0x9,%ecx
  80095e:	77 3c                	ja     80099c <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800960:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800963:	8d 0c 9b             	lea    (%ebx,%ebx,4),%ecx
  800966:	8d 5c 48 d0          	lea    -0x30(%eax,%ecx,2),%ebx
				ch = *fmt;
  80096a:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80096d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800970:	83 f9 09             	cmp    $0x9,%ecx
  800973:	76 eb                	jbe    800960 <vprintfmt+0x9f>
  800975:	eb 25                	jmp    80099c <vprintfmt+0xdb>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800977:	8b 45 14             	mov    0x14(%ebp),%eax
  80097a:	8d 48 04             	lea    0x4(%eax),%ecx
  80097d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800980:	8b 18                	mov    (%eax),%ebx
			goto process_precision;
  800982:	eb 18                	jmp    80099c <vprintfmt+0xdb>

		case '.':
			if (width < 0)
				width = 0;
  800984:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800988:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80098b:	0f 48 c6             	cmovs  %esi,%eax
  80098e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800991:	eb a1                	jmp    800934 <vprintfmt+0x73>
			goto reswitch;

		case '#':
			altflag = 1;
  800993:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80099a:	eb 98                	jmp    800934 <vprintfmt+0x73>

		process_precision:
			if (width < 0)
  80099c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009a0:	79 92                	jns    800934 <vprintfmt+0x73>
  8009a2:	eb 88                	jmp    80092c <vprintfmt+0x6b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009a4:	83 c2 01             	add    $0x1,%edx
  8009a7:	eb 8b                	jmp    800934 <vprintfmt+0x73>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ac:	8d 50 04             	lea    0x4(%eax),%edx
  8009af:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009b9:	8b 00                	mov    (%eax),%eax
  8009bb:	89 04 24             	mov    %eax,(%esp)
  8009be:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009c1:	e9 2c ff ff ff       	jmp    8008f2 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c9:	8d 50 04             	lea    0x4(%eax),%edx
  8009cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8009cf:	8b 00                	mov    (%eax),%eax
  8009d1:	89 c2                	mov    %eax,%edx
  8009d3:	c1 fa 1f             	sar    $0x1f,%edx
  8009d6:	31 d0                	xor    %edx,%eax
  8009d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009da:	83 f8 08             	cmp    $0x8,%eax
  8009dd:	7f 0b                	jg     8009ea <vprintfmt+0x129>
  8009df:	8b 14 85 a0 1a 80 00 	mov    0x801aa0(,%eax,4),%edx
  8009e6:	85 d2                	test   %edx,%edx
  8009e8:	75 23                	jne    800a0d <vprintfmt+0x14c>
				printfmt(putch, putdat, "error %d", err);
  8009ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ee:	c7 44 24 08 9b 18 80 	movl   $0x80189b,0x8(%esp)
  8009f5:	00 
  8009f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	89 04 24             	mov    %eax,(%esp)
  800a03:	e8 91 fe ff ff       	call   800899 <printfmt>
  800a08:	e9 e5 fe ff ff       	jmp    8008f2 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800a0d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a11:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800a18:	00 
  800a19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a20:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a23:	89 1c 24             	mov    %ebx,(%esp)
  800a26:	e8 6e fe ff ff       	call   800899 <printfmt>
  800a2b:	e9 c2 fe ff ff       	jmp    8008f2 <vprintfmt+0x31>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a30:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a36:	89 45 d8             	mov    %eax,-0x28(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a39:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3c:	8d 50 04             	lea    0x4(%eax),%edx
  800a3f:	89 55 14             	mov    %edx,0x14(%ebp)
  800a42:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800a44:	85 f6                	test   %esi,%esi
  800a46:	ba 94 18 80 00       	mov    $0x801894,%edx
  800a4b:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800a4e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a52:	7e 06                	jle    800a5a <vprintfmt+0x199>
  800a54:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800a58:	75 13                	jne    800a6d <vprintfmt+0x1ac>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a5a:	0f be 06             	movsbl (%esi),%eax
  800a5d:	83 c6 01             	add    $0x1,%esi
  800a60:	85 c0                	test   %eax,%eax
  800a62:	0f 85 a2 00 00 00    	jne    800b0a <vprintfmt+0x249>
  800a68:	e9 92 00 00 00       	jmp    800aff <vprintfmt+0x23e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a71:	89 34 24             	mov    %esi,(%esp)
  800a74:	e8 82 02 00 00       	call   800cfb <strnlen>
  800a79:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800a7c:	29 c2                	sub    %eax,%edx
  800a7e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a81:	85 d2                	test   %edx,%edx
  800a83:	7e d5                	jle    800a5a <vprintfmt+0x199>
					putch(padc, putdat);
  800a85:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800a89:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800a8c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a8f:	89 d3                	mov    %edx,%ebx
  800a91:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a94:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a97:	89 c6                	mov    %eax,%esi
  800a99:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a9d:	89 34 24             	mov    %esi,(%esp)
  800aa0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800aa3:	83 eb 01             	sub    $0x1,%ebx
  800aa6:	85 db                	test   %ebx,%ebx
  800aa8:	7f ef                	jg     800a99 <vprintfmt+0x1d8>
  800aaa:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800aad:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800ab0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ab3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800aba:	eb 9e                	jmp    800a5a <vprintfmt+0x199>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800abc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ac0:	74 1b                	je     800add <vprintfmt+0x21c>
  800ac2:	8d 50 e0             	lea    -0x20(%eax),%edx
  800ac5:	83 fa 5e             	cmp    $0x5e,%edx
  800ac8:	76 13                	jbe    800add <vprintfmt+0x21c>
					putch('?', putdat);
  800aca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ad1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800ad8:	ff 55 08             	call   *0x8(%ebp)
  800adb:	eb 0d                	jmp    800aea <vprintfmt+0x229>
				else
					putch(ch, putdat);
  800add:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ae4:	89 04 24             	mov    %eax,(%esp)
  800ae7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800aea:	83 ef 01             	sub    $0x1,%edi
  800aed:	0f be 06             	movsbl (%esi),%eax
  800af0:	85 c0                	test   %eax,%eax
  800af2:	74 05                	je     800af9 <vprintfmt+0x238>
  800af4:	83 c6 01             	add    $0x1,%esi
  800af7:	eb 17                	jmp    800b10 <vprintfmt+0x24f>
  800af9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800afc:	8b 7d dc             	mov    -0x24(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800aff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b03:	7f 1c                	jg     800b21 <vprintfmt+0x260>
  800b05:	e9 e8 fd ff ff       	jmp    8008f2 <vprintfmt+0x31>
  800b0a:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800b0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b10:	85 db                	test   %ebx,%ebx
  800b12:	78 a8                	js     800abc <vprintfmt+0x1fb>
  800b14:	83 eb 01             	sub    $0x1,%ebx
  800b17:	79 a3                	jns    800abc <vprintfmt+0x1fb>
  800b19:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800b1c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800b1f:	eb de                	jmp    800aff <vprintfmt+0x23e>
  800b21:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800b24:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b27:	8b 75 0c             	mov    0xc(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b2e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b35:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b37:	83 eb 01             	sub    $0x1,%ebx
  800b3a:	85 db                	test   %ebx,%ebx
  800b3c:	7f ec                	jg     800b2a <vprintfmt+0x269>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b3e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800b41:	e9 ac fd ff ff       	jmp    8008f2 <vprintfmt+0x31>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b46:	8d 45 14             	lea    0x14(%ebp),%eax
  800b49:	e8 f4 fc ff ff       	call   800842 <getint>
  800b4e:	89 c3                	mov    %eax,%ebx
  800b50:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800b52:	85 d2                	test   %edx,%edx
  800b54:	78 0a                	js     800b60 <vprintfmt+0x29f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b56:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b5b:	e9 87 00 00 00       	jmp    800be7 <vprintfmt+0x326>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800b60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b67:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b6e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b71:	89 d8                	mov    %ebx,%eax
  800b73:	89 f2                	mov    %esi,%edx
  800b75:	f7 d8                	neg    %eax
  800b77:	83 d2 00             	adc    $0x0,%edx
  800b7a:	f7 da                	neg    %edx
			}
			base = 10;
  800b7c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b81:	eb 64                	jmp    800be7 <vprintfmt+0x326>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b83:	8d 45 14             	lea    0x14(%ebp),%eax
  800b86:	e8 7d fc ff ff       	call   800808 <getuint>
			base = 10;
  800b8b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b90:	eb 55                	jmp    800be7 <vprintfmt+0x326>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800b92:	8d 45 14             	lea    0x14(%ebp),%eax
  800b95:	e8 6e fc ff ff       	call   800808 <getuint>
      base = 8;
  800b9a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800b9f:	eb 46                	jmp    800be7 <vprintfmt+0x326>

		// pointer
		case 'p':
			putch('0', putdat);
  800ba1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba4:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ba8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800baf:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800bb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bb9:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800bc0:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bc3:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc6:	8d 50 04             	lea    0x4(%eax),%edx
  800bc9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bcc:	8b 00                	mov    (%eax),%eax
  800bce:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bd3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bd8:	eb 0d                	jmp    800be7 <vprintfmt+0x326>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bda:	8d 45 14             	lea    0x14(%ebp),%eax
  800bdd:	e8 26 fc ff ff       	call   800808 <getuint>
			base = 16;
  800be2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800be7:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800beb:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800bef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800bf2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800bf6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bfa:	89 04 24             	mov    %eax,(%esp)
  800bfd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c04:	8b 45 08             	mov    0x8(%ebp),%eax
  800c07:	e8 14 fb ff ff       	call   800720 <printnum>
			break;
  800c0c:	e9 e1 fc ff ff       	jmp    8008f2 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c18:	89 0c 24             	mov    %ecx,(%esp)
  800c1b:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c1e:	e9 cf fc ff ff       	jmp    8008f2 <vprintfmt+0x31>

		case 'm':
			num = getint(&ap, lflag);
  800c23:	8d 45 14             	lea    0x14(%ebp),%eax
  800c26:	e8 17 fc ff ff       	call   800842 <getint>
			csa = num;
  800c2b:	a3 d0 20 80 00       	mov    %eax,0x8020d0
			break;
  800c30:	e9 bd fc ff ff       	jmp    8008f2 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c38:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c3c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c43:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c46:	83 ef 01             	sub    $0x1,%edi
  800c49:	eb 02                	jmp    800c4d <vprintfmt+0x38c>
  800c4b:	89 c7                	mov    %eax,%edi
  800c4d:	8d 47 ff             	lea    -0x1(%edi),%eax
  800c50:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c54:	75 f5                	jne    800c4b <vprintfmt+0x38a>
  800c56:	e9 97 fc ff ff       	jmp    8008f2 <vprintfmt+0x31>

00800c5b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	83 ec 28             	sub    $0x28,%esp
  800c61:	8b 45 08             	mov    0x8(%ebp),%eax
  800c64:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c67:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c6a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c6e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	74 30                	je     800cac <vsnprintf+0x51>
  800c7c:	85 d2                	test   %edx,%edx
  800c7e:	7e 2c                	jle    800cac <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c80:	8b 45 14             	mov    0x14(%ebp),%eax
  800c83:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c87:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c95:	c7 04 24 7c 08 80 00 	movl   $0x80087c,(%esp)
  800c9c:	e8 20 fc ff ff       	call   8008c1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ca1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ca4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800caa:	eb 05                	jmp    800cb1 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cb1:	c9                   	leave  
  800cb2:	c3                   	ret    

00800cb3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cb9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cbc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cc0:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cce:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd1:	89 04 24             	mov    %eax,(%esp)
  800cd4:	e8 82 ff ff ff       	call   800c5b <vsnprintf>
	va_end(ap);

	return rc;
}
  800cd9:	c9                   	leave  
  800cda:	c3                   	ret    
  800cdb:	00 00                	add    %al,(%eax)
  800cdd:	00 00                	add    %al,(%eax)
	...

00800ce0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ce6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ceb:	80 3a 00             	cmpb   $0x0,(%edx)
  800cee:	74 09                	je     800cf9 <strlen+0x19>
		n++;
  800cf0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cf3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cf7:	75 f7                	jne    800cf0 <strlen+0x10>
		n++;
	return n;
}
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d01:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d04:	b8 00 00 00 00       	mov    $0x0,%eax
  800d09:	85 d2                	test   %edx,%edx
  800d0b:	74 12                	je     800d1f <strnlen+0x24>
  800d0d:	80 39 00             	cmpb   $0x0,(%ecx)
  800d10:	74 0d                	je     800d1f <strnlen+0x24>
		n++;
  800d12:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d15:	39 d0                	cmp    %edx,%eax
  800d17:	74 06                	je     800d1f <strnlen+0x24>
  800d19:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d1d:	75 f3                	jne    800d12 <strnlen+0x17>
		n++;
	return n;
}
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	53                   	push   %ebx
  800d25:	8b 45 08             	mov    0x8(%ebp),%eax
  800d28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d30:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d34:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800d37:	83 c2 01             	add    $0x1,%edx
  800d3a:	84 c9                	test   %cl,%cl
  800d3c:	75 f2                	jne    800d30 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	53                   	push   %ebx
  800d45:	83 ec 08             	sub    $0x8,%esp
  800d48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d4b:	89 1c 24             	mov    %ebx,(%esp)
  800d4e:	e8 8d ff ff ff       	call   800ce0 <strlen>
	strcpy(dst + len, src);
  800d53:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d56:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d5a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800d5d:	89 04 24             	mov    %eax,(%esp)
  800d60:	e8 bc ff ff ff       	call   800d21 <strcpy>
	return dst;
}
  800d65:	89 d8                	mov    %ebx,%eax
  800d67:	83 c4 08             	add    $0x8,%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	8b 45 08             	mov    0x8(%ebp),%eax
  800d75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d78:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d7b:	85 f6                	test   %esi,%esi
  800d7d:	74 18                	je     800d97 <strncpy+0x2a>
  800d7f:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800d84:	0f b6 1a             	movzbl (%edx),%ebx
  800d87:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d8a:	80 3a 01             	cmpb   $0x1,(%edx)
  800d8d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d90:	83 c1 01             	add    $0x1,%ecx
  800d93:	39 ce                	cmp    %ecx,%esi
  800d95:	77 ed                	ja     800d84 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	8b 75 08             	mov    0x8(%ebp),%esi
  800da3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800da9:	89 f0                	mov    %esi,%eax
  800dab:	85 c9                	test   %ecx,%ecx
  800dad:	74 23                	je     800dd2 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
  800daf:	83 e9 01             	sub    $0x1,%ecx
  800db2:	74 1b                	je     800dcf <strlcpy+0x34>
  800db4:	0f b6 1a             	movzbl (%edx),%ebx
  800db7:	84 db                	test   %bl,%bl
  800db9:	74 14                	je     800dcf <strlcpy+0x34>
			*dst++ = *src++;
  800dbb:	88 18                	mov    %bl,(%eax)
  800dbd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dc0:	83 e9 01             	sub    $0x1,%ecx
  800dc3:	74 0a                	je     800dcf <strlcpy+0x34>
			*dst++ = *src++;
  800dc5:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dc8:	0f b6 1a             	movzbl (%edx),%ebx
  800dcb:	84 db                	test   %bl,%bl
  800dcd:	75 ec                	jne    800dbb <strlcpy+0x20>
			*dst++ = *src++;
		*dst = '\0';
  800dcf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dd2:	29 f0                	sub    %esi,%eax
}
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dde:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800de1:	0f b6 01             	movzbl (%ecx),%eax
  800de4:	84 c0                	test   %al,%al
  800de6:	74 15                	je     800dfd <strcmp+0x25>
  800de8:	3a 02                	cmp    (%edx),%al
  800dea:	75 11                	jne    800dfd <strcmp+0x25>
		p++, q++;
  800dec:	83 c1 01             	add    $0x1,%ecx
  800def:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800df2:	0f b6 01             	movzbl (%ecx),%eax
  800df5:	84 c0                	test   %al,%al
  800df7:	74 04                	je     800dfd <strcmp+0x25>
  800df9:	3a 02                	cmp    (%edx),%al
  800dfb:	74 ef                	je     800dec <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dfd:	0f b6 c0             	movzbl %al,%eax
  800e00:	0f b6 12             	movzbl (%edx),%edx
  800e03:	29 d0                	sub    %edx,%eax
}
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	53                   	push   %ebx
  800e0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e11:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e14:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e19:	85 d2                	test   %edx,%edx
  800e1b:	74 28                	je     800e45 <strncmp+0x3e>
  800e1d:	0f b6 01             	movzbl (%ecx),%eax
  800e20:	84 c0                	test   %al,%al
  800e22:	74 24                	je     800e48 <strncmp+0x41>
  800e24:	3a 03                	cmp    (%ebx),%al
  800e26:	75 20                	jne    800e48 <strncmp+0x41>
  800e28:	83 ea 01             	sub    $0x1,%edx
  800e2b:	74 13                	je     800e40 <strncmp+0x39>
		n--, p++, q++;
  800e2d:	83 c1 01             	add    $0x1,%ecx
  800e30:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e33:	0f b6 01             	movzbl (%ecx),%eax
  800e36:	84 c0                	test   %al,%al
  800e38:	74 0e                	je     800e48 <strncmp+0x41>
  800e3a:	3a 03                	cmp    (%ebx),%al
  800e3c:	74 ea                	je     800e28 <strncmp+0x21>
  800e3e:	eb 08                	jmp    800e48 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e40:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e45:	5b                   	pop    %ebx
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e48:	0f b6 01             	movzbl (%ecx),%eax
  800e4b:	0f b6 13             	movzbl (%ebx),%edx
  800e4e:	29 d0                	sub    %edx,%eax
  800e50:	eb f3                	jmp    800e45 <strncmp+0x3e>

00800e52 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	8b 45 08             	mov    0x8(%ebp),%eax
  800e58:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e5c:	0f b6 10             	movzbl (%eax),%edx
  800e5f:	84 d2                	test   %dl,%dl
  800e61:	74 20                	je     800e83 <strchr+0x31>
		if (*s == c)
  800e63:	38 ca                	cmp    %cl,%dl
  800e65:	75 0b                	jne    800e72 <strchr+0x20>
  800e67:	eb 1f                	jmp    800e88 <strchr+0x36>
  800e69:	38 ca                	cmp    %cl,%dl
  800e6b:	90                   	nop
  800e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e70:	74 16                	je     800e88 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e72:	83 c0 01             	add    $0x1,%eax
  800e75:	0f b6 10             	movzbl (%eax),%edx
  800e78:	84 d2                	test   %dl,%dl
  800e7a:	75 ed                	jne    800e69 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800e7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e81:	eb 05                	jmp    800e88 <strchr+0x36>
  800e83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    

00800e8a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e94:	0f b6 10             	movzbl (%eax),%edx
  800e97:	84 d2                	test   %dl,%dl
  800e99:	74 14                	je     800eaf <strfind+0x25>
		if (*s == c)
  800e9b:	38 ca                	cmp    %cl,%dl
  800e9d:	75 06                	jne    800ea5 <strfind+0x1b>
  800e9f:	eb 0e                	jmp    800eaf <strfind+0x25>
  800ea1:	38 ca                	cmp    %cl,%dl
  800ea3:	74 0a                	je     800eaf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ea5:	83 c0 01             	add    $0x1,%eax
  800ea8:	0f b6 10             	movzbl (%eax),%edx
  800eab:	84 d2                	test   %dl,%dl
  800ead:	75 f2                	jne    800ea1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	83 ec 0c             	sub    $0xc,%esp
  800eb7:	89 1c 24             	mov    %ebx,(%esp)
  800eba:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ebe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ec2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ec5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ecb:	85 c9                	test   %ecx,%ecx
  800ecd:	74 30                	je     800eff <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ecf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ed5:	75 25                	jne    800efc <memset+0x4b>
  800ed7:	f6 c1 03             	test   $0x3,%cl
  800eda:	75 20                	jne    800efc <memset+0x4b>
		c &= 0xFF;
  800edc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800edf:	89 d3                	mov    %edx,%ebx
  800ee1:	c1 e3 08             	shl    $0x8,%ebx
  800ee4:	89 d6                	mov    %edx,%esi
  800ee6:	c1 e6 18             	shl    $0x18,%esi
  800ee9:	89 d0                	mov    %edx,%eax
  800eeb:	c1 e0 10             	shl    $0x10,%eax
  800eee:	09 f0                	or     %esi,%eax
  800ef0:	09 d0                	or     %edx,%eax
  800ef2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ef4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ef7:	fc                   	cld    
  800ef8:	f3 ab                	rep stos %eax,%es:(%edi)
  800efa:	eb 03                	jmp    800eff <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800efc:	fc                   	cld    
  800efd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800eff:	89 f8                	mov    %edi,%eax
  800f01:	8b 1c 24             	mov    (%esp),%ebx
  800f04:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f08:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f0c:	89 ec                	mov    %ebp,%esp
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	83 ec 08             	sub    $0x8,%esp
  800f16:	89 34 24             	mov    %esi,(%esp)
  800f19:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f26:	39 c6                	cmp    %eax,%esi
  800f28:	73 36                	jae    800f60 <memmove+0x50>
  800f2a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f2d:	39 d0                	cmp    %edx,%eax
  800f2f:	73 2f                	jae    800f60 <memmove+0x50>
		s += n;
		d += n;
  800f31:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f34:	f6 c2 03             	test   $0x3,%dl
  800f37:	75 1b                	jne    800f54 <memmove+0x44>
  800f39:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f3f:	75 13                	jne    800f54 <memmove+0x44>
  800f41:	f6 c1 03             	test   $0x3,%cl
  800f44:	75 0e                	jne    800f54 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f46:	83 ef 04             	sub    $0x4,%edi
  800f49:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f4c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f4f:	fd                   	std    
  800f50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f52:	eb 09                	jmp    800f5d <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f54:	83 ef 01             	sub    $0x1,%edi
  800f57:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f5a:	fd                   	std    
  800f5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f5d:	fc                   	cld    
  800f5e:	eb 20                	jmp    800f80 <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f60:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f66:	75 13                	jne    800f7b <memmove+0x6b>
  800f68:	a8 03                	test   $0x3,%al
  800f6a:	75 0f                	jne    800f7b <memmove+0x6b>
  800f6c:	f6 c1 03             	test   $0x3,%cl
  800f6f:	75 0a                	jne    800f7b <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f71:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f74:	89 c7                	mov    %eax,%edi
  800f76:	fc                   	cld    
  800f77:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f79:	eb 05                	jmp    800f80 <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f7b:	89 c7                	mov    %eax,%edi
  800f7d:	fc                   	cld    
  800f7e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f80:	8b 34 24             	mov    (%esp),%esi
  800f83:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f87:	89 ec                	mov    %ebp,%esp
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    

00800f8b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f91:	8b 45 10             	mov    0x10(%ebp),%eax
  800f94:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa2:	89 04 24             	mov    %eax,(%esp)
  800fa5:	e8 66 ff ff ff       	call   800f10 <memmove>
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    

00800fac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	57                   	push   %edi
  800fb0:	56                   	push   %esi
  800fb1:	53                   	push   %ebx
  800fb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fb8:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fbb:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fc0:	85 ff                	test   %edi,%edi
  800fc2:	74 38                	je     800ffc <memcmp+0x50>
		if (*s1 != *s2)
  800fc4:	0f b6 03             	movzbl (%ebx),%eax
  800fc7:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fca:	83 ef 01             	sub    $0x1,%edi
  800fcd:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800fd2:	38 c8                	cmp    %cl,%al
  800fd4:	74 1d                	je     800ff3 <memcmp+0x47>
  800fd6:	eb 11                	jmp    800fe9 <memcmp+0x3d>
  800fd8:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800fdd:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  800fe2:	83 c2 01             	add    $0x1,%edx
  800fe5:	38 c8                	cmp    %cl,%al
  800fe7:	74 0a                	je     800ff3 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  800fe9:	0f b6 c0             	movzbl %al,%eax
  800fec:	0f b6 c9             	movzbl %cl,%ecx
  800fef:	29 c8                	sub    %ecx,%eax
  800ff1:	eb 09                	jmp    800ffc <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ff3:	39 fa                	cmp    %edi,%edx
  800ff5:	75 e1                	jne    800fd8 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ff7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ffc:	5b                   	pop    %ebx
  800ffd:	5e                   	pop    %esi
  800ffe:	5f                   	pop    %edi
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801007:	89 c2                	mov    %eax,%edx
  801009:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80100c:	39 d0                	cmp    %edx,%eax
  80100e:	73 15                	jae    801025 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801010:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801014:	38 08                	cmp    %cl,(%eax)
  801016:	75 06                	jne    80101e <memfind+0x1d>
  801018:	eb 0b                	jmp    801025 <memfind+0x24>
  80101a:	38 08                	cmp    %cl,(%eax)
  80101c:	74 07                	je     801025 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80101e:	83 c0 01             	add    $0x1,%eax
  801021:	39 c2                	cmp    %eax,%edx
  801023:	77 f5                	ja     80101a <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	57                   	push   %edi
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	8b 55 08             	mov    0x8(%ebp),%edx
  801030:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801033:	0f b6 02             	movzbl (%edx),%eax
  801036:	3c 20                	cmp    $0x20,%al
  801038:	74 04                	je     80103e <strtol+0x17>
  80103a:	3c 09                	cmp    $0x9,%al
  80103c:	75 0e                	jne    80104c <strtol+0x25>
		s++;
  80103e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801041:	0f b6 02             	movzbl (%edx),%eax
  801044:	3c 20                	cmp    $0x20,%al
  801046:	74 f6                	je     80103e <strtol+0x17>
  801048:	3c 09                	cmp    $0x9,%al
  80104a:	74 f2                	je     80103e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  80104c:	3c 2b                	cmp    $0x2b,%al
  80104e:	75 0a                	jne    80105a <strtol+0x33>
		s++;
  801050:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801053:	bf 00 00 00 00       	mov    $0x0,%edi
  801058:	eb 10                	jmp    80106a <strtol+0x43>
  80105a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80105f:	3c 2d                	cmp    $0x2d,%al
  801061:	75 07                	jne    80106a <strtol+0x43>
		s++, neg = 1;
  801063:	83 c2 01             	add    $0x1,%edx
  801066:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80106a:	85 db                	test   %ebx,%ebx
  80106c:	0f 94 c0             	sete   %al
  80106f:	74 05                	je     801076 <strtol+0x4f>
  801071:	83 fb 10             	cmp    $0x10,%ebx
  801074:	75 15                	jne    80108b <strtol+0x64>
  801076:	80 3a 30             	cmpb   $0x30,(%edx)
  801079:	75 10                	jne    80108b <strtol+0x64>
  80107b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80107f:	75 0a                	jne    80108b <strtol+0x64>
		s += 2, base = 16;
  801081:	83 c2 02             	add    $0x2,%edx
  801084:	bb 10 00 00 00       	mov    $0x10,%ebx
  801089:	eb 13                	jmp    80109e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  80108b:	84 c0                	test   %al,%al
  80108d:	74 0f                	je     80109e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80108f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801094:	80 3a 30             	cmpb   $0x30,(%edx)
  801097:	75 05                	jne    80109e <strtol+0x77>
		s++, base = 8;
  801099:	83 c2 01             	add    $0x1,%edx
  80109c:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80109e:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a3:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010a5:	0f b6 0a             	movzbl (%edx),%ecx
  8010a8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8010ab:	80 fb 09             	cmp    $0x9,%bl
  8010ae:	77 08                	ja     8010b8 <strtol+0x91>
			dig = *s - '0';
  8010b0:	0f be c9             	movsbl %cl,%ecx
  8010b3:	83 e9 30             	sub    $0x30,%ecx
  8010b6:	eb 1e                	jmp    8010d6 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  8010b8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8010bb:	80 fb 19             	cmp    $0x19,%bl
  8010be:	77 08                	ja     8010c8 <strtol+0xa1>
			dig = *s - 'a' + 10;
  8010c0:	0f be c9             	movsbl %cl,%ecx
  8010c3:	83 e9 57             	sub    $0x57,%ecx
  8010c6:	eb 0e                	jmp    8010d6 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  8010c8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8010cb:	80 fb 19             	cmp    $0x19,%bl
  8010ce:	77 15                	ja     8010e5 <strtol+0xbe>
			dig = *s - 'A' + 10;
  8010d0:	0f be c9             	movsbl %cl,%ecx
  8010d3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8010d6:	39 f1                	cmp    %esi,%ecx
  8010d8:	7d 0f                	jge    8010e9 <strtol+0xc2>
			break;
		s++, val = (val * base) + dig;
  8010da:	83 c2 01             	add    $0x1,%edx
  8010dd:	0f af c6             	imul   %esi,%eax
  8010e0:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8010e3:	eb c0                	jmp    8010a5 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8010e5:	89 c1                	mov    %eax,%ecx
  8010e7:	eb 02                	jmp    8010eb <strtol+0xc4>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8010e9:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8010eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010ef:	74 05                	je     8010f6 <strtol+0xcf>
		*endptr = (char *) s;
  8010f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010f4:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8010f6:	89 ca                	mov    %ecx,%edx
  8010f8:	f7 da                	neg    %edx
  8010fa:	85 ff                	test   %edi,%edi
  8010fc:	0f 45 c2             	cmovne %edx,%eax
}
  8010ff:	5b                   	pop    %ebx
  801100:	5e                   	pop    %esi
  801101:	5f                   	pop    %edi
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    

00801104 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	83 ec 0c             	sub    $0xc,%esp
  80110a:	89 1c 24             	mov    %ebx,(%esp)
  80110d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801111:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801115:	b8 00 00 00 00       	mov    $0x0,%eax
  80111a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111d:	8b 55 08             	mov    0x8(%ebp),%edx
  801120:	89 c3                	mov    %eax,%ebx
  801122:	89 c7                	mov    %eax,%edi
  801124:	89 c6                	mov    %eax,%esi
  801126:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801128:	8b 1c 24             	mov    (%esp),%ebx
  80112b:	8b 74 24 04          	mov    0x4(%esp),%esi
  80112f:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801133:	89 ec                	mov    %ebp,%esp
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <sys_cgetc>:

int
sys_cgetc(void)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	83 ec 0c             	sub    $0xc,%esp
  80113d:	89 1c 24             	mov    %ebx,(%esp)
  801140:	89 74 24 04          	mov    %esi,0x4(%esp)
  801144:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801148:	ba 00 00 00 00       	mov    $0x0,%edx
  80114d:	b8 01 00 00 00       	mov    $0x1,%eax
  801152:	89 d1                	mov    %edx,%ecx
  801154:	89 d3                	mov    %edx,%ebx
  801156:	89 d7                	mov    %edx,%edi
  801158:	89 d6                	mov    %edx,%esi
  80115a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80115c:	8b 1c 24             	mov    (%esp),%ebx
  80115f:	8b 74 24 04          	mov    0x4(%esp),%esi
  801163:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801167:	89 ec                	mov    %ebp,%esp
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	83 ec 38             	sub    $0x38,%esp
  801171:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801174:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801177:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80117f:	b8 03 00 00 00       	mov    $0x3,%eax
  801184:	8b 55 08             	mov    0x8(%ebp),%edx
  801187:	89 cb                	mov    %ecx,%ebx
  801189:	89 cf                	mov    %ecx,%edi
  80118b:	89 ce                	mov    %ecx,%esi
  80118d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80118f:	85 c0                	test   %eax,%eax
  801191:	7e 28                	jle    8011bb <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801193:	89 44 24 10          	mov    %eax,0x10(%esp)
  801197:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80119e:	00 
  80119f:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  8011a6:	00 
  8011a7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011ae:	00 
  8011af:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  8011b6:	e8 41 f4 ff ff       	call   8005fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8011bb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011be:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011c4:	89 ec                	mov    %ebp,%esp
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	83 ec 0c             	sub    $0xc,%esp
  8011ce:	89 1c 24             	mov    %ebx,(%esp)
  8011d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011d5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011de:	b8 02 00 00 00       	mov    $0x2,%eax
  8011e3:	89 d1                	mov    %edx,%ecx
  8011e5:	89 d3                	mov    %edx,%ebx
  8011e7:	89 d7                	mov    %edx,%edi
  8011e9:	89 d6                	mov    %edx,%esi
  8011eb:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  8011ed:	8b 1c 24             	mov    (%esp),%ebx
  8011f0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011f4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011f8:	89 ec                	mov    %ebp,%esp
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <sys_yield>:

void
sys_yield(void)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	83 ec 0c             	sub    $0xc,%esp
  801202:	89 1c 24             	mov    %ebx,(%esp)
  801205:	89 74 24 04          	mov    %esi,0x4(%esp)
  801209:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80120d:	ba 00 00 00 00       	mov    $0x0,%edx
  801212:	b8 0a 00 00 00       	mov    $0xa,%eax
  801217:	89 d1                	mov    %edx,%ecx
  801219:	89 d3                	mov    %edx,%ebx
  80121b:	89 d7                	mov    %edx,%edi
  80121d:	89 d6                	mov    %edx,%esi
  80121f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801221:	8b 1c 24             	mov    (%esp),%ebx
  801224:	8b 74 24 04          	mov    0x4(%esp),%esi
  801228:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80122c:	89 ec                	mov    %ebp,%esp
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	83 ec 38             	sub    $0x38,%esp
  801236:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801239:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80123c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80123f:	be 00 00 00 00       	mov    $0x0,%esi
  801244:	b8 04 00 00 00       	mov    $0x4,%eax
  801249:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80124c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124f:	8b 55 08             	mov    0x8(%ebp),%edx
  801252:	89 f7                	mov    %esi,%edi
  801254:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801256:	85 c0                	test   %eax,%eax
  801258:	7e 28                	jle    801282 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80125e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801265:	00 
  801266:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  80126d:	00 
  80126e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801275:	00 
  801276:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  80127d:	e8 7a f3 ff ff       	call   8005fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801282:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801285:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801288:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80128b:	89 ec                	mov    %ebp,%esp
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 38             	sub    $0x38,%esp
  801295:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801298:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80129b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80129e:	b8 05 00 00 00       	mov    $0x5,%eax
  8012a3:	8b 75 18             	mov    0x18(%ebp),%esi
  8012a6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012af:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	7e 28                	jle    8012e0 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012bc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012c3:	00 
  8012c4:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  8012cb:	00 
  8012cc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012d3:	00 
  8012d4:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  8012db:	e8 1c f3 ff ff       	call   8005fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8012e0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012e3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012e6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012e9:	89 ec                	mov    %ebp,%esp
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	83 ec 38             	sub    $0x38,%esp
  8012f3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012f6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012f9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801301:	b8 06 00 00 00       	mov    $0x6,%eax
  801306:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801309:	8b 55 08             	mov    0x8(%ebp),%edx
  80130c:	89 df                	mov    %ebx,%edi
  80130e:	89 de                	mov    %ebx,%esi
  801310:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801312:	85 c0                	test   %eax,%eax
  801314:	7e 28                	jle    80133e <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801316:	89 44 24 10          	mov    %eax,0x10(%esp)
  80131a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801321:	00 
  801322:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  801329:	00 
  80132a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801331:	00 
  801332:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  801339:	e8 be f2 ff ff       	call   8005fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80133e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801341:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801344:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801347:	89 ec                	mov    %ebp,%esp
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    

0080134b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	83 ec 38             	sub    $0x38,%esp
  801351:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801354:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801357:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80135a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80135f:	b8 08 00 00 00       	mov    $0x8,%eax
  801364:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801367:	8b 55 08             	mov    0x8(%ebp),%edx
  80136a:	89 df                	mov    %ebx,%edi
  80136c:	89 de                	mov    %ebx,%esi
  80136e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801370:	85 c0                	test   %eax,%eax
  801372:	7e 28                	jle    80139c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801374:	89 44 24 10          	mov    %eax,0x10(%esp)
  801378:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80137f:	00 
  801380:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  801387:	00 
  801388:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80138f:	00 
  801390:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  801397:	e8 60 f2 ff ff       	call   8005fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80139c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80139f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013a2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013a5:	89 ec                	mov    %ebp,%esp
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    

008013a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	83 ec 38             	sub    $0x38,%esp
  8013af:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013b2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013b5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013bd:	b8 09 00 00 00       	mov    $0x9,%eax
  8013c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c8:	89 df                	mov    %ebx,%edi
  8013ca:	89 de                	mov    %ebx,%esi
  8013cc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	7e 28                	jle    8013fa <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013d6:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8013dd:	00 
  8013de:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  8013e5:	00 
  8013e6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013ed:	00 
  8013ee:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  8013f5:	e8 02 f2 ff ff       	call   8005fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8013fa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013fd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801400:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801403:	89 ec                	mov    %ebp,%esp
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    

00801407 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	83 ec 0c             	sub    $0xc,%esp
  80140d:	89 1c 24             	mov    %ebx,(%esp)
  801410:	89 74 24 04          	mov    %esi,0x4(%esp)
  801414:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801418:	be 00 00 00 00       	mov    $0x0,%esi
  80141d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801422:	8b 7d 14             	mov    0x14(%ebp),%edi
  801425:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801428:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80142b:	8b 55 08             	mov    0x8(%ebp),%edx
  80142e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801430:	8b 1c 24             	mov    (%esp),%ebx
  801433:	8b 74 24 04          	mov    0x4(%esp),%esi
  801437:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80143b:	89 ec                	mov    %ebp,%esp
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	83 ec 38             	sub    $0x38,%esp
  801445:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801448:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80144b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80144e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801453:	b8 0c 00 00 00       	mov    $0xc,%eax
  801458:	8b 55 08             	mov    0x8(%ebp),%edx
  80145b:	89 cb                	mov    %ecx,%ebx
  80145d:	89 cf                	mov    %ecx,%edi
  80145f:	89 ce                	mov    %ecx,%esi
  801461:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801463:	85 c0                	test   %eax,%eax
  801465:	7e 28                	jle    80148f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801467:	89 44 24 10          	mov    %eax,0x10(%esp)
  80146b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801472:	00 
  801473:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  80147a:	00 
  80147b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801482:	00 
  801483:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  80148a:	e8 6d f1 ff ff       	call   8005fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80148f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801492:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801495:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801498:	89 ec                	mov    %ebp,%esp
  80149a:	5d                   	pop    %ebp
  80149b:	c3                   	ret    

0080149c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8014a2:	83 3d d4 20 80 00 00 	cmpl   $0x0,0x8020d4
  8014a9:	75 1c                	jne    8014c7 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  8014ab:	c7 44 24 08 f0 1a 80 	movl   $0x801af0,0x8(%esp)
  8014b2:	00 
  8014b3:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8014ba:	00 
  8014bb:	c7 04 24 14 1b 80 00 	movl   $0x801b14,(%esp)
  8014c2:	e8 35 f1 ff ff       	call   8005fc <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8014c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ca:	a3 d4 20 80 00       	mov    %eax,0x8020d4
}
  8014cf:	c9                   	leave  
  8014d0:	c3                   	ret    
	...

008014e0 <__udivdi3>:
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	57                   	push   %edi
  8014e4:	56                   	push   %esi
  8014e5:	83 ec 10             	sub    $0x10,%esp
  8014e8:	8b 75 14             	mov    0x14(%ebp),%esi
  8014eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014f4:	85 f6                	test   %esi,%esi
  8014f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8014f9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8014fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8014ff:	75 2f                	jne    801530 <__udivdi3+0x50>
  801501:	39 f9                	cmp    %edi,%ecx
  801503:	77 5b                	ja     801560 <__udivdi3+0x80>
  801505:	85 c9                	test   %ecx,%ecx
  801507:	75 0b                	jne    801514 <__udivdi3+0x34>
  801509:	b8 01 00 00 00       	mov    $0x1,%eax
  80150e:	31 d2                	xor    %edx,%edx
  801510:	f7 f1                	div    %ecx
  801512:	89 c1                	mov    %eax,%ecx
  801514:	89 f8                	mov    %edi,%eax
  801516:	31 d2                	xor    %edx,%edx
  801518:	f7 f1                	div    %ecx
  80151a:	89 c7                	mov    %eax,%edi
  80151c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151f:	f7 f1                	div    %ecx
  801521:	89 fa                	mov    %edi,%edx
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	5e                   	pop    %esi
  801527:	5f                   	pop    %edi
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    
  80152a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801530:	31 d2                	xor    %edx,%edx
  801532:	31 c0                	xor    %eax,%eax
  801534:	39 fe                	cmp    %edi,%esi
  801536:	77 eb                	ja     801523 <__udivdi3+0x43>
  801538:	0f bd d6             	bsr    %esi,%edx
  80153b:	83 f2 1f             	xor    $0x1f,%edx
  80153e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801541:	75 2d                	jne    801570 <__udivdi3+0x90>
  801543:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  801546:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  801549:	76 06                	jbe    801551 <__udivdi3+0x71>
  80154b:	39 fe                	cmp    %edi,%esi
  80154d:	89 c2                	mov    %eax,%edx
  80154f:	73 d2                	jae    801523 <__udivdi3+0x43>
  801551:	31 d2                	xor    %edx,%edx
  801553:	b8 01 00 00 00       	mov    $0x1,%eax
  801558:	eb c9                	jmp    801523 <__udivdi3+0x43>
  80155a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801560:	89 fa                	mov    %edi,%edx
  801562:	f7 f1                	div    %ecx
  801564:	31 d2                	xor    %edx,%edx
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	5e                   	pop    %esi
  80156a:	5f                   	pop    %edi
  80156b:	5d                   	pop    %ebp
  80156c:	c3                   	ret    
  80156d:	8d 76 00             	lea    0x0(%esi),%esi
  801570:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801574:	b8 20 00 00 00       	mov    $0x20,%eax
  801579:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80157c:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80157f:	d3 e6                	shl    %cl,%esi
  801581:	89 c1                	mov    %eax,%ecx
  801583:	d3 ea                	shr    %cl,%edx
  801585:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801589:	09 f2                	or     %esi,%edx
  80158b:	8b 75 ec             	mov    -0x14(%ebp),%esi
  80158e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801591:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801594:	d3 e2                	shl    %cl,%edx
  801596:	89 c1                	mov    %eax,%ecx
  801598:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80159b:	89 fa                	mov    %edi,%edx
  80159d:	d3 ea                	shr    %cl,%edx
  80159f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015a3:	d3 e7                	shl    %cl,%edi
  8015a5:	89 c1                	mov    %eax,%ecx
  8015a7:	d3 ee                	shr    %cl,%esi
  8015a9:	09 fe                	or     %edi,%esi
  8015ab:	89 f0                	mov    %esi,%eax
  8015ad:	f7 75 e8             	divl   -0x18(%ebp)
  8015b0:	89 d7                	mov    %edx,%edi
  8015b2:	89 c6                	mov    %eax,%esi
  8015b4:	f7 65 f0             	mull   -0x10(%ebp)
  8015b7:	39 d7                	cmp    %edx,%edi
  8015b9:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8015bc:	72 22                	jb     8015e0 <__udivdi3+0x100>
  8015be:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8015c1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015c5:	d3 e2                	shl    %cl,%edx
  8015c7:	39 c2                	cmp    %eax,%edx
  8015c9:	73 05                	jae    8015d0 <__udivdi3+0xf0>
  8015cb:	3b 7d f0             	cmp    -0x10(%ebp),%edi
  8015ce:	74 10                	je     8015e0 <__udivdi3+0x100>
  8015d0:	89 f0                	mov    %esi,%eax
  8015d2:	31 d2                	xor    %edx,%edx
  8015d4:	e9 4a ff ff ff       	jmp    801523 <__udivdi3+0x43>
  8015d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8015e0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8015e3:	31 d2                	xor    %edx,%edx
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	5e                   	pop    %esi
  8015e9:	5f                   	pop    %edi
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    
  8015ec:	00 00                	add    %al,(%eax)
	...

008015f0 <__umoddi3>:
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	57                   	push   %edi
  8015f4:	56                   	push   %esi
  8015f5:	83 ec 20             	sub    $0x20,%esp
  8015f8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801601:	8b 75 0c             	mov    0xc(%ebp),%esi
  801604:	85 ff                	test   %edi,%edi
  801606:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801609:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80160c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80160f:	89 f2                	mov    %esi,%edx
  801611:	75 15                	jne    801628 <__umoddi3+0x38>
  801613:	39 f1                	cmp    %esi,%ecx
  801615:	76 41                	jbe    801658 <__umoddi3+0x68>
  801617:	f7 f1                	div    %ecx
  801619:	89 d0                	mov    %edx,%eax
  80161b:	31 d2                	xor    %edx,%edx
  80161d:	83 c4 20             	add    $0x20,%esp
  801620:	5e                   	pop    %esi
  801621:	5f                   	pop    %edi
  801622:	5d                   	pop    %ebp
  801623:	c3                   	ret    
  801624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801628:	39 f7                	cmp    %esi,%edi
  80162a:	77 4c                	ja     801678 <__umoddi3+0x88>
  80162c:	0f bd c7             	bsr    %edi,%eax
  80162f:	83 f0 1f             	xor    $0x1f,%eax
  801632:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801635:	75 51                	jne    801688 <__umoddi3+0x98>
  801637:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80163a:	0f 87 e8 00 00 00    	ja     801728 <__umoddi3+0x138>
  801640:	89 f2                	mov    %esi,%edx
  801642:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801645:	29 ce                	sub    %ecx,%esi
  801647:	19 fa                	sbb    %edi,%edx
  801649:	89 75 f0             	mov    %esi,-0x10(%ebp)
  80164c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164f:	83 c4 20             	add    $0x20,%esp
  801652:	5e                   	pop    %esi
  801653:	5f                   	pop    %edi
  801654:	5d                   	pop    %ebp
  801655:	c3                   	ret    
  801656:	66 90                	xchg   %ax,%ax
  801658:	85 c9                	test   %ecx,%ecx
  80165a:	75 0b                	jne    801667 <__umoddi3+0x77>
  80165c:	b8 01 00 00 00       	mov    $0x1,%eax
  801661:	31 d2                	xor    %edx,%edx
  801663:	f7 f1                	div    %ecx
  801665:	89 c1                	mov    %eax,%ecx
  801667:	89 f0                	mov    %esi,%eax
  801669:	31 d2                	xor    %edx,%edx
  80166b:	f7 f1                	div    %ecx
  80166d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801670:	eb a5                	jmp    801617 <__umoddi3+0x27>
  801672:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801678:	89 f2                	mov    %esi,%edx
  80167a:	83 c4 20             	add    $0x20,%esp
  80167d:	5e                   	pop    %esi
  80167e:	5f                   	pop    %edi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    
  801681:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801688:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80168c:	89 f2                	mov    %esi,%edx
  80168e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801691:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  801698:	29 45 f0             	sub    %eax,-0x10(%ebp)
  80169b:	d3 e7                	shl    %cl,%edi
  80169d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016a4:	d3 e8                	shr    %cl,%eax
  8016a6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016aa:	09 f8                	or     %edi,%eax
  8016ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b2:	d3 e0                	shl    %cl,%eax
  8016b4:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8016bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8016be:	d3 ea                	shr    %cl,%edx
  8016c0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016c4:	d3 e6                	shl    %cl,%esi
  8016c6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016ca:	d3 e8                	shr    %cl,%eax
  8016cc:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016d0:	09 f0                	or     %esi,%eax
  8016d2:	8b 75 e8             	mov    -0x18(%ebp),%esi
  8016d5:	f7 75 e4             	divl   -0x1c(%ebp)
  8016d8:	d3 e6                	shl    %cl,%esi
  8016da:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8016dd:	89 d6                	mov    %edx,%esi
  8016df:	f7 65 f4             	mull   -0xc(%ebp)
  8016e2:	89 d7                	mov    %edx,%edi
  8016e4:	89 c2                	mov    %eax,%edx
  8016e6:	39 fe                	cmp    %edi,%esi
  8016e8:	89 f9                	mov    %edi,%ecx
  8016ea:	72 30                	jb     80171c <__umoddi3+0x12c>
  8016ec:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8016ef:	72 27                	jb     801718 <__umoddi3+0x128>
  8016f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8016f4:	29 d0                	sub    %edx,%eax
  8016f6:	19 ce                	sbb    %ecx,%esi
  8016f8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016fc:	89 f2                	mov    %esi,%edx
  8016fe:	d3 e8                	shr    %cl,%eax
  801700:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801704:	d3 e2                	shl    %cl,%edx
  801706:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  80170a:	09 d0                	or     %edx,%eax
  80170c:	89 f2                	mov    %esi,%edx
  80170e:	d3 ea                	shr    %cl,%edx
  801710:	83 c4 20             	add    $0x20,%esp
  801713:	5e                   	pop    %esi
  801714:	5f                   	pop    %edi
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    
  801717:	90                   	nop
  801718:	39 fe                	cmp    %edi,%esi
  80171a:	75 d5                	jne    8016f1 <__umoddi3+0x101>
  80171c:	89 f9                	mov    %edi,%ecx
  80171e:	89 c2                	mov    %eax,%edx
  801720:	2b 55 f4             	sub    -0xc(%ebp),%edx
  801723:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801726:	eb c9                	jmp    8016f1 <__umoddi3+0x101>
  801728:	39 f7                	cmp    %esi,%edi
  80172a:	0f 82 10 ff ff ff    	jb     801640 <__umoddi3+0x50>
  801730:	e9 17 ff ff ff       	jmp    80164c <__umoddi3+0x5c>
