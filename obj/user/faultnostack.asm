
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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 17 03 80 00       	push   $0x800317
  80003e:	6a 00                	push   $0x0
  800040:	e8 2c 02 00 00       	call   800271 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7f 08                	jg     800113 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 ea 0f 80 00       	push   $0x800fea
  80011e:	6a 23                	push   $0x23
  800120:	68 07 10 80 00       	push   $0x801007
  800125:	e8 f8 01 00 00       	call   800322 <_panic>

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	8b 55 08             	mov    0x8(%ebp),%edx
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	b8 04 00 00 00       	mov    $0x4,%eax
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7f 08                	jg     800194 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018f:	5b                   	pop    %ebx
  800190:	5e                   	pop    %esi
  800191:	5f                   	pop    %edi
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 ea 0f 80 00       	push   $0x800fea
  80019f:	6a 23                	push   $0x23
  8001a1:	68 07 10 80 00       	push   $0x801007
  8001a6:	e8 77 01 00 00       	call   800322 <_panic>

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7f 08                	jg     8001d6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 ea 0f 80 00       	push   $0x800fea
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 07 10 80 00       	push   $0x801007
  8001e8:	e8 35 01 00 00       	call   800322 <_panic>

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	b8 06 00 00 00       	mov    $0x6,%eax
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7f 08                	jg     800218 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5f                   	pop    %edi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 ea 0f 80 00       	push   $0x800fea
  800223:	6a 23                	push   $0x23
  800225:	68 07 10 80 00       	push   $0x801007
  80022a:	e8 f3 00 00 00       	call   800322 <_panic>

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	8b 55 08             	mov    0x8(%ebp),%edx
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	b8 08 00 00 00       	mov    $0x8,%eax
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7f 08                	jg     80025a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 ea 0f 80 00       	push   $0x800fea
  800265:	6a 23                	push   $0x23
  800267:	68 07 10 80 00       	push   $0x801007
  80026c:	e8 b1 00 00 00       	call   800322 <_panic>

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	b8 09 00 00 00       	mov    $0x9,%eax
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7f 08                	jg     80029c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800297:	5b                   	pop    %ebx
  800298:	5e                   	pop    %esi
  800299:	5f                   	pop    %edi
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 ea 0f 80 00       	push   $0x800fea
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 07 10 80 00       	push   $0x801007
  8002ae:	e8 6f 00 00 00       	call   800322 <_panic>

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c4:	be 00 00 00 00       	mov    $0x0,%esi
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7f 08                	jg     800300 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800300:	83 ec 0c             	sub    $0xc,%esp
  800303:	50                   	push   %eax
  800304:	6a 0c                	push   $0xc
  800306:	68 ea 0f 80 00       	push   $0x800fea
  80030b:	6a 23                	push   $0x23
  80030d:	68 07 10 80 00       	push   $0x801007
  800312:	e8 0b 00 00 00       	call   800322 <_panic>

00800317 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800317:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800318:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80031d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80031f:	83 c4 04             	add    $0x4,%esp

00800322 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800327:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800330:	e8 f5 fd ff ff       	call   80012a <sys_getenvid>
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 0c             	pushl  0xc(%ebp)
  80033b:	ff 75 08             	pushl  0x8(%ebp)
  80033e:	56                   	push   %esi
  80033f:	50                   	push   %eax
  800340:	68 18 10 80 00       	push   $0x801018
  800345:	e8 b3 00 00 00       	call   8003fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034a:	83 c4 18             	add    $0x18,%esp
  80034d:	53                   	push   %ebx
  80034e:	ff 75 10             	pushl  0x10(%ebp)
  800351:	e8 56 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800356:	c7 04 24 3b 10 80 00 	movl   $0x80103b,(%esp)
  80035d:	e8 9b 00 00 00       	call   8003fd <cprintf>
  800362:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800365:	cc                   	int3   
  800366:	eb fd                	jmp    800365 <_panic+0x43>

00800368 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	53                   	push   %ebx
  80036c:	83 ec 04             	sub    $0x4,%esp
  80036f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800372:	8b 13                	mov    (%ebx),%edx
  800374:	8d 42 01             	lea    0x1(%edx),%eax
  800377:	89 03                	mov    %eax,(%ebx)
  800379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800380:	3d ff 00 00 00       	cmp    $0xff,%eax
  800385:	74 09                	je     800390 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800387:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80038b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800390:	83 ec 08             	sub    $0x8,%esp
  800393:	68 ff 00 00 00       	push   $0xff
  800398:	8d 43 08             	lea    0x8(%ebx),%eax
  80039b:	50                   	push   %eax
  80039c:	e8 0b fd ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a7:	83 c4 10             	add    $0x10,%esp
  8003aa:	eb db                	jmp    800387 <putch+0x1f>

008003ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bc:	00 00 00 
	b.cnt = 0;
  8003bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c9:	ff 75 0c             	pushl  0xc(%ebp)
  8003cc:	ff 75 08             	pushl  0x8(%ebp)
  8003cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	68 68 03 80 00       	push   $0x800368
  8003db:	e8 1a 01 00 00       	call   8004fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e0:	83 c4 08             	add    $0x8,%esp
  8003e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ef:	50                   	push   %eax
  8003f0:	e8 b7 fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  8003f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800403:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	e8 9d ff ff ff       	call   8003ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 1c             	sub    $0x1c,%esp
  80041a:	89 c7                	mov    %eax,%edi
  80041c:	89 d6                	mov    %edx,%esi
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800427:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80042d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800432:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800435:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800438:	39 d3                	cmp    %edx,%ebx
  80043a:	72 05                	jb     800441 <printnum+0x30>
  80043c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80043f:	77 7a                	ja     8004bb <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	ff 75 18             	pushl  0x18(%ebp)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 e4             	pushl  -0x1c(%ebp)
  800457:	ff 75 e0             	pushl  -0x20(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 2b 09 00 00       	call   800d90 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	e8 9e ff ff ff       	call   800411 <printnum>
  800473:	83 c4 20             	add    $0x20,%esp
  800476:	eb 13                	jmp    80048b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	ff 75 18             	pushl  0x18(%ebp)
  80047f:	ff d7                	call   *%edi
  800481:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800484:	83 eb 01             	sub    $0x1,%ebx
  800487:	85 db                	test   %ebx,%ebx
  800489:	7f ed                	jg     800478 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	56                   	push   %esi
  80048f:	83 ec 04             	sub    $0x4,%esp
  800492:	ff 75 e4             	pushl  -0x1c(%ebp)
  800495:	ff 75 e0             	pushl  -0x20(%ebp)
  800498:	ff 75 dc             	pushl  -0x24(%ebp)
  80049b:	ff 75 d8             	pushl  -0x28(%ebp)
  80049e:	e8 0d 0a 00 00       	call   800eb0 <__umoddi3>
  8004a3:	83 c4 14             	add    $0x14,%esp
  8004a6:	0f be 80 3d 10 80 00 	movsbl 0x80103d(%eax),%eax
  8004ad:	50                   	push   %eax
  8004ae:	ff d7                	call   *%edi
}
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b6:	5b                   	pop    %ebx
  8004b7:	5e                   	pop    %esi
  8004b8:	5f                   	pop    %edi
  8004b9:	5d                   	pop    %ebp
  8004ba:	c3                   	ret    
  8004bb:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004be:	eb c4                	jmp    800484 <printnum+0x73>

008004c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ca:	8b 10                	mov    (%eax),%edx
  8004cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8004cf:	73 0a                	jae    8004db <sprintputch+0x1b>
		*b->buf++ = ch;
  8004d1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004d4:	89 08                	mov    %ecx,(%eax)
  8004d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d9:	88 02                	mov    %al,(%edx)
}
  8004db:	5d                   	pop    %ebp
  8004dc:	c3                   	ret    

008004dd <printfmt>:
{
  8004dd:	55                   	push   %ebp
  8004de:	89 e5                	mov    %esp,%ebp
  8004e0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004e3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004e6:	50                   	push   %eax
  8004e7:	ff 75 10             	pushl  0x10(%ebp)
  8004ea:	ff 75 0c             	pushl  0xc(%ebp)
  8004ed:	ff 75 08             	pushl  0x8(%ebp)
  8004f0:	e8 05 00 00 00       	call   8004fa <vprintfmt>
}
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    

008004fa <vprintfmt>:
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	57                   	push   %edi
  8004fe:	56                   	push   %esi
  8004ff:	53                   	push   %ebx
  800500:	83 ec 2c             	sub    $0x2c,%esp
  800503:	8b 75 08             	mov    0x8(%ebp),%esi
  800506:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800509:	8b 7d 10             	mov    0x10(%ebp),%edi
  80050c:	e9 c1 03 00 00       	jmp    8008d2 <vprintfmt+0x3d8>
		padc = ' ';
  800511:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800515:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80051c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800523:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80052a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	8d 47 01             	lea    0x1(%edi),%eax
  800532:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800535:	0f b6 17             	movzbl (%edi),%edx
  800538:	8d 42 dd             	lea    -0x23(%edx),%eax
  80053b:	3c 55                	cmp    $0x55,%al
  80053d:	0f 87 12 04 00 00    	ja     800955 <vprintfmt+0x45b>
  800543:	0f b6 c0             	movzbl %al,%eax
  800546:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
  80054d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800550:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800554:	eb d9                	jmp    80052f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800559:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80055d:	eb d0                	jmp    80052f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	0f b6 d2             	movzbl %dl,%edx
  800562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800565:	b8 00 00 00 00       	mov    $0x0,%eax
  80056a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80056d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800570:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800574:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800577:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80057a:	83 f9 09             	cmp    $0x9,%ecx
  80057d:	77 55                	ja     8005d4 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80057f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800582:	eb e9                	jmp    80056d <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 40 04             	lea    0x4(%eax),%eax
  800592:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800595:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800598:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80059c:	79 91                	jns    80052f <vprintfmt+0x35>
				width = precision, precision = -1;
  80059e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005ab:	eb 82                	jmp    80052f <vprintfmt+0x35>
  8005ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b0:	85 c0                	test   %eax,%eax
  8005b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005b7:	0f 49 d0             	cmovns %eax,%edx
  8005ba:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c0:	e9 6a ff ff ff       	jmp    80052f <vprintfmt+0x35>
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005c8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005cf:	e9 5b ff ff ff       	jmp    80052f <vprintfmt+0x35>
  8005d4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005da:	eb bc                	jmp    800598 <vprintfmt+0x9e>
			lflag++;
  8005dc:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005e2:	e9 48 ff ff ff       	jmp    80052f <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 78 04             	lea    0x4(%eax),%edi
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	ff 30                	pushl  (%eax)
  8005f3:	ff d6                	call   *%esi
			break;
  8005f5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005f8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005fb:	e9 cf 02 00 00       	jmp    8008cf <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 78 04             	lea    0x4(%eax),%edi
  800606:	8b 00                	mov    (%eax),%eax
  800608:	99                   	cltd   
  800609:	31 d0                	xor    %edx,%eax
  80060b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060d:	83 f8 08             	cmp    $0x8,%eax
  800610:	7f 23                	jg     800635 <vprintfmt+0x13b>
  800612:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  800619:	85 d2                	test   %edx,%edx
  80061b:	74 18                	je     800635 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80061d:	52                   	push   %edx
  80061e:	68 5e 10 80 00       	push   $0x80105e
  800623:	53                   	push   %ebx
  800624:	56                   	push   %esi
  800625:	e8 b3 fe ff ff       	call   8004dd <printfmt>
  80062a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80062d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800630:	e9 9a 02 00 00       	jmp    8008cf <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800635:	50                   	push   %eax
  800636:	68 55 10 80 00       	push   $0x801055
  80063b:	53                   	push   %ebx
  80063c:	56                   	push   %esi
  80063d:	e8 9b fe ff ff       	call   8004dd <printfmt>
  800642:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800645:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800648:	e9 82 02 00 00       	jmp    8008cf <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	83 c0 04             	add    $0x4,%eax
  800653:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80065b:	85 ff                	test   %edi,%edi
  80065d:	b8 4e 10 80 00       	mov    $0x80104e,%eax
  800662:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800665:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800669:	0f 8e bd 00 00 00    	jle    80072c <vprintfmt+0x232>
  80066f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800673:	75 0e                	jne    800683 <vprintfmt+0x189>
  800675:	89 75 08             	mov    %esi,0x8(%ebp)
  800678:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80067e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800681:	eb 6d                	jmp    8006f0 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	ff 75 d0             	pushl  -0x30(%ebp)
  800689:	57                   	push   %edi
  80068a:	e8 6e 03 00 00       	call   8009fd <strnlen>
  80068f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800692:	29 c1                	sub    %eax,%ecx
  800694:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800697:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80069a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80069e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006a4:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a6:	eb 0f                	jmp    8006b7 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8006af:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b1:	83 ef 01             	sub    $0x1,%edi
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	85 ff                	test   %edi,%edi
  8006b9:	7f ed                	jg     8006a8 <vprintfmt+0x1ae>
  8006bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006be:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006c1:	85 c9                	test   %ecx,%ecx
  8006c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c8:	0f 49 c1             	cmovns %ecx,%eax
  8006cb:	29 c1                	sub    %eax,%ecx
  8006cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d6:	89 cb                	mov    %ecx,%ebx
  8006d8:	eb 16                	jmp    8006f0 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006de:	75 31                	jne    800711 <vprintfmt+0x217>
					putch(ch, putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	ff 75 0c             	pushl  0xc(%ebp)
  8006e6:	50                   	push   %eax
  8006e7:	ff 55 08             	call   *0x8(%ebp)
  8006ea:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ed:	83 eb 01             	sub    $0x1,%ebx
  8006f0:	83 c7 01             	add    $0x1,%edi
  8006f3:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006f7:	0f be c2             	movsbl %dl,%eax
  8006fa:	85 c0                	test   %eax,%eax
  8006fc:	74 59                	je     800757 <vprintfmt+0x25d>
  8006fe:	85 f6                	test   %esi,%esi
  800700:	78 d8                	js     8006da <vprintfmt+0x1e0>
  800702:	83 ee 01             	sub    $0x1,%esi
  800705:	79 d3                	jns    8006da <vprintfmt+0x1e0>
  800707:	89 df                	mov    %ebx,%edi
  800709:	8b 75 08             	mov    0x8(%ebp),%esi
  80070c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80070f:	eb 37                	jmp    800748 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800711:	0f be d2             	movsbl %dl,%edx
  800714:	83 ea 20             	sub    $0x20,%edx
  800717:	83 fa 5e             	cmp    $0x5e,%edx
  80071a:	76 c4                	jbe    8006e0 <vprintfmt+0x1e6>
					putch('?', putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	ff 75 0c             	pushl  0xc(%ebp)
  800722:	6a 3f                	push   $0x3f
  800724:	ff 55 08             	call   *0x8(%ebp)
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	eb c1                	jmp    8006ed <vprintfmt+0x1f3>
  80072c:	89 75 08             	mov    %esi,0x8(%ebp)
  80072f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800732:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800735:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800738:	eb b6                	jmp    8006f0 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	53                   	push   %ebx
  80073e:	6a 20                	push   $0x20
  800740:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800742:	83 ef 01             	sub    $0x1,%edi
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	85 ff                	test   %edi,%edi
  80074a:	7f ee                	jg     80073a <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80074c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80074f:	89 45 14             	mov    %eax,0x14(%ebp)
  800752:	e9 78 01 00 00       	jmp    8008cf <vprintfmt+0x3d5>
  800757:	89 df                	mov    %ebx,%edi
  800759:	8b 75 08             	mov    0x8(%ebp),%esi
  80075c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80075f:	eb e7                	jmp    800748 <vprintfmt+0x24e>
	if (lflag >= 2)
  800761:	83 f9 01             	cmp    $0x1,%ecx
  800764:	7e 3f                	jle    8007a5 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8b 50 04             	mov    0x4(%eax),%edx
  80076c:	8b 00                	mov    (%eax),%eax
  80076e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800771:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8d 40 08             	lea    0x8(%eax),%eax
  80077a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80077d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800781:	79 5c                	jns    8007df <vprintfmt+0x2e5>
				putch('-', putdat);
  800783:	83 ec 08             	sub    $0x8,%esp
  800786:	53                   	push   %ebx
  800787:	6a 2d                	push   $0x2d
  800789:	ff d6                	call   *%esi
				num = -(long long) num;
  80078b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80078e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800791:	f7 da                	neg    %edx
  800793:	83 d1 00             	adc    $0x0,%ecx
  800796:	f7 d9                	neg    %ecx
  800798:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80079b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a0:	e9 10 01 00 00       	jmp    8008b5 <vprintfmt+0x3bb>
	else if (lflag)
  8007a5:	85 c9                	test   %ecx,%ecx
  8007a7:	75 1b                	jne    8007c4 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8007a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ac:	8b 00                	mov    (%eax),%eax
  8007ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b1:	89 c1                	mov    %eax,%ecx
  8007b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8d 40 04             	lea    0x4(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c2:	eb b9                	jmp    80077d <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8b 00                	mov    (%eax),%eax
  8007c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007cc:	89 c1                	mov    %eax,%ecx
  8007ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8d 40 04             	lea    0x4(%eax),%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
  8007dd:	eb 9e                	jmp    80077d <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007df:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ea:	e9 c6 00 00 00       	jmp    8008b5 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8007ef:	83 f9 01             	cmp    $0x1,%ecx
  8007f2:	7e 18                	jle    80080c <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8007f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f7:	8b 10                	mov    (%eax),%edx
  8007f9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007fc:	8d 40 08             	lea    0x8(%eax),%eax
  8007ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800802:	b8 0a 00 00 00       	mov    $0xa,%eax
  800807:	e9 a9 00 00 00       	jmp    8008b5 <vprintfmt+0x3bb>
	else if (lflag)
  80080c:	85 c9                	test   %ecx,%ecx
  80080e:	75 1a                	jne    80082a <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8b 10                	mov    (%eax),%edx
  800815:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081a:	8d 40 04             	lea    0x4(%eax),%eax
  80081d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800820:	b8 0a 00 00 00       	mov    $0xa,%eax
  800825:	e9 8b 00 00 00       	jmp    8008b5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80082a:	8b 45 14             	mov    0x14(%ebp),%eax
  80082d:	8b 10                	mov    (%eax),%edx
  80082f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800834:	8d 40 04             	lea    0x4(%eax),%eax
  800837:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80083a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80083f:	eb 74                	jmp    8008b5 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800841:	83 f9 01             	cmp    $0x1,%ecx
  800844:	7e 15                	jle    80085b <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8b 10                	mov    (%eax),%edx
  80084b:	8b 48 04             	mov    0x4(%eax),%ecx
  80084e:	8d 40 08             	lea    0x8(%eax),%eax
  800851:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800854:	b8 08 00 00 00       	mov    $0x8,%eax
  800859:	eb 5a                	jmp    8008b5 <vprintfmt+0x3bb>
	else if (lflag)
  80085b:	85 c9                	test   %ecx,%ecx
  80085d:	75 17                	jne    800876 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8b 10                	mov    (%eax),%edx
  800864:	b9 00 00 00 00       	mov    $0x0,%ecx
  800869:	8d 40 04             	lea    0x4(%eax),%eax
  80086c:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80086f:	b8 08 00 00 00       	mov    $0x8,%eax
  800874:	eb 3f                	jmp    8008b5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	8b 10                	mov    (%eax),%edx
  80087b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800880:	8d 40 04             	lea    0x4(%eax),%eax
  800883:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800886:	b8 08 00 00 00       	mov    $0x8,%eax
  80088b:	eb 28                	jmp    8008b5 <vprintfmt+0x3bb>
			putch('0', putdat);
  80088d:	83 ec 08             	sub    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	6a 30                	push   $0x30
  800893:	ff d6                	call   *%esi
			putch('x', putdat);
  800895:	83 c4 08             	add    $0x8,%esp
  800898:	53                   	push   %ebx
  800899:	6a 78                	push   $0x78
  80089b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8b 10                	mov    (%eax),%edx
  8008a2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008a7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008aa:	8d 40 04             	lea    0x4(%eax),%eax
  8008ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008b0:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008b5:	83 ec 0c             	sub    $0xc,%esp
  8008b8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008bc:	57                   	push   %edi
  8008bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c0:	50                   	push   %eax
  8008c1:	51                   	push   %ecx
  8008c2:	52                   	push   %edx
  8008c3:	89 da                	mov    %ebx,%edx
  8008c5:	89 f0                	mov    %esi,%eax
  8008c7:	e8 45 fb ff ff       	call   800411 <printnum>
			break;
  8008cc:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008d2:	83 c7 01             	add    $0x1,%edi
  8008d5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008d9:	83 f8 25             	cmp    $0x25,%eax
  8008dc:	0f 84 2f fc ff ff    	je     800511 <vprintfmt+0x17>
			if (ch == '\0')
  8008e2:	85 c0                	test   %eax,%eax
  8008e4:	0f 84 8b 00 00 00    	je     800975 <vprintfmt+0x47b>
			putch(ch, putdat);
  8008ea:	83 ec 08             	sub    $0x8,%esp
  8008ed:	53                   	push   %ebx
  8008ee:	50                   	push   %eax
  8008ef:	ff d6                	call   *%esi
  8008f1:	83 c4 10             	add    $0x10,%esp
  8008f4:	eb dc                	jmp    8008d2 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8008f6:	83 f9 01             	cmp    $0x1,%ecx
  8008f9:	7e 15                	jle    800910 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8008fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fe:	8b 10                	mov    (%eax),%edx
  800900:	8b 48 04             	mov    0x4(%eax),%ecx
  800903:	8d 40 08             	lea    0x8(%eax),%eax
  800906:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800909:	b8 10 00 00 00       	mov    $0x10,%eax
  80090e:	eb a5                	jmp    8008b5 <vprintfmt+0x3bb>
	else if (lflag)
  800910:	85 c9                	test   %ecx,%ecx
  800912:	75 17                	jne    80092b <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800914:	8b 45 14             	mov    0x14(%ebp),%eax
  800917:	8b 10                	mov    (%eax),%edx
  800919:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091e:	8d 40 04             	lea    0x4(%eax),%eax
  800921:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800924:	b8 10 00 00 00       	mov    $0x10,%eax
  800929:	eb 8a                	jmp    8008b5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80092b:	8b 45 14             	mov    0x14(%ebp),%eax
  80092e:	8b 10                	mov    (%eax),%edx
  800930:	b9 00 00 00 00       	mov    $0x0,%ecx
  800935:	8d 40 04             	lea    0x4(%eax),%eax
  800938:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80093b:	b8 10 00 00 00       	mov    $0x10,%eax
  800940:	e9 70 ff ff ff       	jmp    8008b5 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800945:	83 ec 08             	sub    $0x8,%esp
  800948:	53                   	push   %ebx
  800949:	6a 25                	push   $0x25
  80094b:	ff d6                	call   *%esi
			break;
  80094d:	83 c4 10             	add    $0x10,%esp
  800950:	e9 7a ff ff ff       	jmp    8008cf <vprintfmt+0x3d5>
			putch('%', putdat);
  800955:	83 ec 08             	sub    $0x8,%esp
  800958:	53                   	push   %ebx
  800959:	6a 25                	push   $0x25
  80095b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80095d:	83 c4 10             	add    $0x10,%esp
  800960:	89 f8                	mov    %edi,%eax
  800962:	eb 03                	jmp    800967 <vprintfmt+0x46d>
  800964:	83 e8 01             	sub    $0x1,%eax
  800967:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80096b:	75 f7                	jne    800964 <vprintfmt+0x46a>
  80096d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800970:	e9 5a ff ff ff       	jmp    8008cf <vprintfmt+0x3d5>
}
  800975:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5f                   	pop    %edi
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	83 ec 18             	sub    $0x18,%esp
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800989:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80098c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800990:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800993:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80099a:	85 c0                	test   %eax,%eax
  80099c:	74 26                	je     8009c4 <vsnprintf+0x47>
  80099e:	85 d2                	test   %edx,%edx
  8009a0:	7e 22                	jle    8009c4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a2:	ff 75 14             	pushl  0x14(%ebp)
  8009a5:	ff 75 10             	pushl  0x10(%ebp)
  8009a8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ab:	50                   	push   %eax
  8009ac:	68 c0 04 80 00       	push   $0x8004c0
  8009b1:	e8 44 fb ff ff       	call   8004fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009bf:	83 c4 10             	add    $0x10,%esp
}
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    
		return -E_INVAL;
  8009c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c9:	eb f7                	jmp    8009c2 <vsnprintf+0x45>

008009cb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009d1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d4:	50                   	push   %eax
  8009d5:	ff 75 10             	pushl  0x10(%ebp)
  8009d8:	ff 75 0c             	pushl  0xc(%ebp)
  8009db:	ff 75 08             	pushl  0x8(%ebp)
  8009de:	e8 9a ff ff ff       	call   80097d <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f0:	eb 03                	jmp    8009f5 <strlen+0x10>
		n++;
  8009f2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f9:	75 f7                	jne    8009f2 <strlen+0xd>
	return n;
}
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a03:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	eb 03                	jmp    800a10 <strnlen+0x13>
		n++;
  800a0d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a10:	39 d0                	cmp    %edx,%eax
  800a12:	74 06                	je     800a1a <strnlen+0x1d>
  800a14:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a18:	75 f3                	jne    800a0d <strnlen+0x10>
	return n;
}
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	53                   	push   %ebx
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a26:	89 c2                	mov    %eax,%edx
  800a28:	83 c1 01             	add    $0x1,%ecx
  800a2b:	83 c2 01             	add    $0x1,%edx
  800a2e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a32:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a35:	84 db                	test   %bl,%bl
  800a37:	75 ef                	jne    800a28 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	53                   	push   %ebx
  800a40:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a43:	53                   	push   %ebx
  800a44:	e8 9c ff ff ff       	call   8009e5 <strlen>
  800a49:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a4c:	ff 75 0c             	pushl  0xc(%ebp)
  800a4f:	01 d8                	add    %ebx,%eax
  800a51:	50                   	push   %eax
  800a52:	e8 c5 ff ff ff       	call   800a1c <strcpy>
	return dst;
}
  800a57:	89 d8                	mov    %ebx,%eax
  800a59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a5c:	c9                   	leave  
  800a5d:	c3                   	ret    

00800a5e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 75 08             	mov    0x8(%ebp),%esi
  800a66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a69:	89 f3                	mov    %esi,%ebx
  800a6b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a6e:	89 f2                	mov    %esi,%edx
  800a70:	eb 0f                	jmp    800a81 <strncpy+0x23>
		*dst++ = *src;
  800a72:	83 c2 01             	add    $0x1,%edx
  800a75:	0f b6 01             	movzbl (%ecx),%eax
  800a78:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a7b:	80 39 01             	cmpb   $0x1,(%ecx)
  800a7e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a81:	39 da                	cmp    %ebx,%edx
  800a83:	75 ed                	jne    800a72 <strncpy+0x14>
	}
	return ret;
}
  800a85:	89 f0                	mov    %esi,%eax
  800a87:	5b                   	pop    %ebx
  800a88:	5e                   	pop    %esi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	56                   	push   %esi
  800a8f:	53                   	push   %ebx
  800a90:	8b 75 08             	mov    0x8(%ebp),%esi
  800a93:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a96:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a99:	89 f0                	mov    %esi,%eax
  800a9b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a9f:	85 c9                	test   %ecx,%ecx
  800aa1:	75 0b                	jne    800aae <strlcpy+0x23>
  800aa3:	eb 17                	jmp    800abc <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aa5:	83 c2 01             	add    $0x1,%edx
  800aa8:	83 c0 01             	add    $0x1,%eax
  800aab:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800aae:	39 d8                	cmp    %ebx,%eax
  800ab0:	74 07                	je     800ab9 <strlcpy+0x2e>
  800ab2:	0f b6 0a             	movzbl (%edx),%ecx
  800ab5:	84 c9                	test   %cl,%cl
  800ab7:	75 ec                	jne    800aa5 <strlcpy+0x1a>
		*dst = '\0';
  800ab9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800abc:	29 f0                	sub    %esi,%eax
}
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800acb:	eb 06                	jmp    800ad3 <strcmp+0x11>
		p++, q++;
  800acd:	83 c1 01             	add    $0x1,%ecx
  800ad0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ad3:	0f b6 01             	movzbl (%ecx),%eax
  800ad6:	84 c0                	test   %al,%al
  800ad8:	74 04                	je     800ade <strcmp+0x1c>
  800ada:	3a 02                	cmp    (%edx),%al
  800adc:	74 ef                	je     800acd <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ade:	0f b6 c0             	movzbl %al,%eax
  800ae1:	0f b6 12             	movzbl (%edx),%edx
  800ae4:	29 d0                	sub    %edx,%eax
}
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	53                   	push   %ebx
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
  800aef:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af2:	89 c3                	mov    %eax,%ebx
  800af4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800af7:	eb 06                	jmp    800aff <strncmp+0x17>
		n--, p++, q++;
  800af9:	83 c0 01             	add    $0x1,%eax
  800afc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800aff:	39 d8                	cmp    %ebx,%eax
  800b01:	74 16                	je     800b19 <strncmp+0x31>
  800b03:	0f b6 08             	movzbl (%eax),%ecx
  800b06:	84 c9                	test   %cl,%cl
  800b08:	74 04                	je     800b0e <strncmp+0x26>
  800b0a:	3a 0a                	cmp    (%edx),%cl
  800b0c:	74 eb                	je     800af9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0e:	0f b6 00             	movzbl (%eax),%eax
  800b11:	0f b6 12             	movzbl (%edx),%edx
  800b14:	29 d0                	sub    %edx,%eax
}
  800b16:	5b                   	pop    %ebx
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    
		return 0;
  800b19:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1e:	eb f6                	jmp    800b16 <strncmp+0x2e>

00800b20 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	8b 45 08             	mov    0x8(%ebp),%eax
  800b26:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b2a:	0f b6 10             	movzbl (%eax),%edx
  800b2d:	84 d2                	test   %dl,%dl
  800b2f:	74 09                	je     800b3a <strchr+0x1a>
		if (*s == c)
  800b31:	38 ca                	cmp    %cl,%dl
  800b33:	74 0a                	je     800b3f <strchr+0x1f>
	for (; *s; s++)
  800b35:	83 c0 01             	add    $0x1,%eax
  800b38:	eb f0                	jmp    800b2a <strchr+0xa>
			return (char *) s;
	return 0;
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	8b 45 08             	mov    0x8(%ebp),%eax
  800b47:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b4b:	eb 03                	jmp    800b50 <strfind+0xf>
  800b4d:	83 c0 01             	add    $0x1,%eax
  800b50:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b53:	38 ca                	cmp    %cl,%dl
  800b55:	74 04                	je     800b5b <strfind+0x1a>
  800b57:	84 d2                	test   %dl,%dl
  800b59:	75 f2                	jne    800b4d <strfind+0xc>
			break;
	return (char *) s;
}
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b66:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b69:	85 c9                	test   %ecx,%ecx
  800b6b:	74 13                	je     800b80 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b73:	75 05                	jne    800b7a <memset+0x1d>
  800b75:	f6 c1 03             	test   $0x3,%cl
  800b78:	74 0d                	je     800b87 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7d:	fc                   	cld    
  800b7e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b80:	89 f8                	mov    %edi,%eax
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    
		c &= 0xFF;
  800b87:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b8b:	89 d3                	mov    %edx,%ebx
  800b8d:	c1 e3 08             	shl    $0x8,%ebx
  800b90:	89 d0                	mov    %edx,%eax
  800b92:	c1 e0 18             	shl    $0x18,%eax
  800b95:	89 d6                	mov    %edx,%esi
  800b97:	c1 e6 10             	shl    $0x10,%esi
  800b9a:	09 f0                	or     %esi,%eax
  800b9c:	09 c2                	or     %eax,%edx
  800b9e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ba0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ba3:	89 d0                	mov    %edx,%eax
  800ba5:	fc                   	cld    
  800ba6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba8:	eb d6                	jmp    800b80 <memset+0x23>

00800baa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bb8:	39 c6                	cmp    %eax,%esi
  800bba:	73 35                	jae    800bf1 <memmove+0x47>
  800bbc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bbf:	39 c2                	cmp    %eax,%edx
  800bc1:	76 2e                	jbe    800bf1 <memmove+0x47>
		s += n;
		d += n;
  800bc3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc6:	89 d6                	mov    %edx,%esi
  800bc8:	09 fe                	or     %edi,%esi
  800bca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bd0:	74 0c                	je     800bde <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bd2:	83 ef 01             	sub    $0x1,%edi
  800bd5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bd8:	fd                   	std    
  800bd9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bdb:	fc                   	cld    
  800bdc:	eb 21                	jmp    800bff <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bde:	f6 c1 03             	test   $0x3,%cl
  800be1:	75 ef                	jne    800bd2 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800be3:	83 ef 04             	sub    $0x4,%edi
  800be6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bec:	fd                   	std    
  800bed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bef:	eb ea                	jmp    800bdb <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf1:	89 f2                	mov    %esi,%edx
  800bf3:	09 c2                	or     %eax,%edx
  800bf5:	f6 c2 03             	test   $0x3,%dl
  800bf8:	74 09                	je     800c03 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bfa:	89 c7                	mov    %eax,%edi
  800bfc:	fc                   	cld    
  800bfd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c03:	f6 c1 03             	test   $0x3,%cl
  800c06:	75 f2                	jne    800bfa <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c08:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c0b:	89 c7                	mov    %eax,%edi
  800c0d:	fc                   	cld    
  800c0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c10:	eb ed                	jmp    800bff <memmove+0x55>

00800c12 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c15:	ff 75 10             	pushl  0x10(%ebp)
  800c18:	ff 75 0c             	pushl  0xc(%ebp)
  800c1b:	ff 75 08             	pushl  0x8(%ebp)
  800c1e:	e8 87 ff ff ff       	call   800baa <memmove>
}
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c30:	89 c6                	mov    %eax,%esi
  800c32:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c35:	39 f0                	cmp    %esi,%eax
  800c37:	74 1c                	je     800c55 <memcmp+0x30>
		if (*s1 != *s2)
  800c39:	0f b6 08             	movzbl (%eax),%ecx
  800c3c:	0f b6 1a             	movzbl (%edx),%ebx
  800c3f:	38 d9                	cmp    %bl,%cl
  800c41:	75 08                	jne    800c4b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c43:	83 c0 01             	add    $0x1,%eax
  800c46:	83 c2 01             	add    $0x1,%edx
  800c49:	eb ea                	jmp    800c35 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c4b:	0f b6 c1             	movzbl %cl,%eax
  800c4e:	0f b6 db             	movzbl %bl,%ebx
  800c51:	29 d8                	sub    %ebx,%eax
  800c53:	eb 05                	jmp    800c5a <memcmp+0x35>
	}

	return 0;
  800c55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	8b 45 08             	mov    0x8(%ebp),%eax
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c67:	89 c2                	mov    %eax,%edx
  800c69:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c6c:	39 d0                	cmp    %edx,%eax
  800c6e:	73 09                	jae    800c79 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c70:	38 08                	cmp    %cl,(%eax)
  800c72:	74 05                	je     800c79 <memfind+0x1b>
	for (; s < ends; s++)
  800c74:	83 c0 01             	add    $0x1,%eax
  800c77:	eb f3                	jmp    800c6c <memfind+0xe>
			break;
	return (void *) s;
}
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c87:	eb 03                	jmp    800c8c <strtol+0x11>
		s++;
  800c89:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c8c:	0f b6 01             	movzbl (%ecx),%eax
  800c8f:	3c 20                	cmp    $0x20,%al
  800c91:	74 f6                	je     800c89 <strtol+0xe>
  800c93:	3c 09                	cmp    $0x9,%al
  800c95:	74 f2                	je     800c89 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c97:	3c 2b                	cmp    $0x2b,%al
  800c99:	74 2e                	je     800cc9 <strtol+0x4e>
	int neg = 0;
  800c9b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ca0:	3c 2d                	cmp    $0x2d,%al
  800ca2:	74 2f                	je     800cd3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800caa:	75 05                	jne    800cb1 <strtol+0x36>
  800cac:	80 39 30             	cmpb   $0x30,(%ecx)
  800caf:	74 2c                	je     800cdd <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb1:	85 db                	test   %ebx,%ebx
  800cb3:	75 0a                	jne    800cbf <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cb5:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800cba:	80 39 30             	cmpb   $0x30,(%ecx)
  800cbd:	74 28                	je     800ce7 <strtol+0x6c>
		base = 10;
  800cbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cc7:	eb 50                	jmp    800d19 <strtol+0x9e>
		s++;
  800cc9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ccc:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd1:	eb d1                	jmp    800ca4 <strtol+0x29>
		s++, neg = 1;
  800cd3:	83 c1 01             	add    $0x1,%ecx
  800cd6:	bf 01 00 00 00       	mov    $0x1,%edi
  800cdb:	eb c7                	jmp    800ca4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cdd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ce1:	74 0e                	je     800cf1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ce3:	85 db                	test   %ebx,%ebx
  800ce5:	75 d8                	jne    800cbf <strtol+0x44>
		s++, base = 8;
  800ce7:	83 c1 01             	add    $0x1,%ecx
  800cea:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cef:	eb ce                	jmp    800cbf <strtol+0x44>
		s += 2, base = 16;
  800cf1:	83 c1 02             	add    $0x2,%ecx
  800cf4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cf9:	eb c4                	jmp    800cbf <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cfb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cfe:	89 f3                	mov    %esi,%ebx
  800d00:	80 fb 19             	cmp    $0x19,%bl
  800d03:	77 29                	ja     800d2e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d05:	0f be d2             	movsbl %dl,%edx
  800d08:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d0b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d0e:	7d 30                	jge    800d40 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d10:	83 c1 01             	add    $0x1,%ecx
  800d13:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d17:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d19:	0f b6 11             	movzbl (%ecx),%edx
  800d1c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d1f:	89 f3                	mov    %esi,%ebx
  800d21:	80 fb 09             	cmp    $0x9,%bl
  800d24:	77 d5                	ja     800cfb <strtol+0x80>
			dig = *s - '0';
  800d26:	0f be d2             	movsbl %dl,%edx
  800d29:	83 ea 30             	sub    $0x30,%edx
  800d2c:	eb dd                	jmp    800d0b <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d2e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d31:	89 f3                	mov    %esi,%ebx
  800d33:	80 fb 19             	cmp    $0x19,%bl
  800d36:	77 08                	ja     800d40 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d38:	0f be d2             	movsbl %dl,%edx
  800d3b:	83 ea 37             	sub    $0x37,%edx
  800d3e:	eb cb                	jmp    800d0b <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d44:	74 05                	je     800d4b <strtol+0xd0>
		*endptr = (char *) s;
  800d46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d49:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d4b:	89 c2                	mov    %eax,%edx
  800d4d:	f7 da                	neg    %edx
  800d4f:	85 ff                	test   %edi,%edi
  800d51:	0f 45 c2             	cmovne %edx,%eax
}
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d5f:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d66:	74 0a                	je     800d72 <set_pgfault_handler+0x19>
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d68:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6b:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d70:	c9                   	leave  
  800d71:	c3                   	ret    
		panic("set_pgfault_handler not implemented");
  800d72:	83 ec 04             	sub    $0x4,%esp
  800d75:	68 84 12 80 00       	push   $0x801284
  800d7a:	6a 20                	push   $0x20
  800d7c:	68 a8 12 80 00       	push   $0x8012a8
  800d81:	e8 9c f5 ff ff       	call   800322 <_panic>
  800d86:	66 90                	xchg   %ax,%ax
  800d88:	66 90                	xchg   %ax,%ax
  800d8a:	66 90                	xchg   %ax,%ax
  800d8c:	66 90                	xchg   %ax,%ax
  800d8e:	66 90                	xchg   %ax,%ax

00800d90 <__udivdi3>:
  800d90:	55                   	push   %ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 1c             	sub    $0x1c,%esp
  800d97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d9b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800da3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800da7:	85 d2                	test   %edx,%edx
  800da9:	75 35                	jne    800de0 <__udivdi3+0x50>
  800dab:	39 f3                	cmp    %esi,%ebx
  800dad:	0f 87 bd 00 00 00    	ja     800e70 <__udivdi3+0xe0>
  800db3:	85 db                	test   %ebx,%ebx
  800db5:	89 d9                	mov    %ebx,%ecx
  800db7:	75 0b                	jne    800dc4 <__udivdi3+0x34>
  800db9:	b8 01 00 00 00       	mov    $0x1,%eax
  800dbe:	31 d2                	xor    %edx,%edx
  800dc0:	f7 f3                	div    %ebx
  800dc2:	89 c1                	mov    %eax,%ecx
  800dc4:	31 d2                	xor    %edx,%edx
  800dc6:	89 f0                	mov    %esi,%eax
  800dc8:	f7 f1                	div    %ecx
  800dca:	89 c6                	mov    %eax,%esi
  800dcc:	89 e8                	mov    %ebp,%eax
  800dce:	89 f7                	mov    %esi,%edi
  800dd0:	f7 f1                	div    %ecx
  800dd2:	89 fa                	mov    %edi,%edx
  800dd4:	83 c4 1c             	add    $0x1c,%esp
  800dd7:	5b                   	pop    %ebx
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    
  800ddc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800de0:	39 f2                	cmp    %esi,%edx
  800de2:	77 7c                	ja     800e60 <__udivdi3+0xd0>
  800de4:	0f bd fa             	bsr    %edx,%edi
  800de7:	83 f7 1f             	xor    $0x1f,%edi
  800dea:	0f 84 98 00 00 00    	je     800e88 <__udivdi3+0xf8>
  800df0:	89 f9                	mov    %edi,%ecx
  800df2:	b8 20 00 00 00       	mov    $0x20,%eax
  800df7:	29 f8                	sub    %edi,%eax
  800df9:	d3 e2                	shl    %cl,%edx
  800dfb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800dff:	89 c1                	mov    %eax,%ecx
  800e01:	89 da                	mov    %ebx,%edx
  800e03:	d3 ea                	shr    %cl,%edx
  800e05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e09:	09 d1                	or     %edx,%ecx
  800e0b:	89 f2                	mov    %esi,%edx
  800e0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e11:	89 f9                	mov    %edi,%ecx
  800e13:	d3 e3                	shl    %cl,%ebx
  800e15:	89 c1                	mov    %eax,%ecx
  800e17:	d3 ea                	shr    %cl,%edx
  800e19:	89 f9                	mov    %edi,%ecx
  800e1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e1f:	d3 e6                	shl    %cl,%esi
  800e21:	89 eb                	mov    %ebp,%ebx
  800e23:	89 c1                	mov    %eax,%ecx
  800e25:	d3 eb                	shr    %cl,%ebx
  800e27:	09 de                	or     %ebx,%esi
  800e29:	89 f0                	mov    %esi,%eax
  800e2b:	f7 74 24 08          	divl   0x8(%esp)
  800e2f:	89 d6                	mov    %edx,%esi
  800e31:	89 c3                	mov    %eax,%ebx
  800e33:	f7 64 24 0c          	mull   0xc(%esp)
  800e37:	39 d6                	cmp    %edx,%esi
  800e39:	72 0c                	jb     800e47 <__udivdi3+0xb7>
  800e3b:	89 f9                	mov    %edi,%ecx
  800e3d:	d3 e5                	shl    %cl,%ebp
  800e3f:	39 c5                	cmp    %eax,%ebp
  800e41:	73 5d                	jae    800ea0 <__udivdi3+0x110>
  800e43:	39 d6                	cmp    %edx,%esi
  800e45:	75 59                	jne    800ea0 <__udivdi3+0x110>
  800e47:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e4a:	31 ff                	xor    %edi,%edi
  800e4c:	89 fa                	mov    %edi,%edx
  800e4e:	83 c4 1c             	add    $0x1c,%esp
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    
  800e56:	8d 76 00             	lea    0x0(%esi),%esi
  800e59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e60:	31 ff                	xor    %edi,%edi
  800e62:	31 c0                	xor    %eax,%eax
  800e64:	89 fa                	mov    %edi,%edx
  800e66:	83 c4 1c             	add    $0x1c,%esp
  800e69:	5b                   	pop    %ebx
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    
  800e6e:	66 90                	xchg   %ax,%ax
  800e70:	31 ff                	xor    %edi,%edi
  800e72:	89 e8                	mov    %ebp,%eax
  800e74:	89 f2                	mov    %esi,%edx
  800e76:	f7 f3                	div    %ebx
  800e78:	89 fa                	mov    %edi,%edx
  800e7a:	83 c4 1c             	add    $0x1c,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
  800e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e88:	39 f2                	cmp    %esi,%edx
  800e8a:	72 06                	jb     800e92 <__udivdi3+0x102>
  800e8c:	31 c0                	xor    %eax,%eax
  800e8e:	39 eb                	cmp    %ebp,%ebx
  800e90:	77 d2                	ja     800e64 <__udivdi3+0xd4>
  800e92:	b8 01 00 00 00       	mov    $0x1,%eax
  800e97:	eb cb                	jmp    800e64 <__udivdi3+0xd4>
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	89 d8                	mov    %ebx,%eax
  800ea2:	31 ff                	xor    %edi,%edi
  800ea4:	eb be                	jmp    800e64 <__udivdi3+0xd4>
  800ea6:	66 90                	xchg   %ax,%ax
  800ea8:	66 90                	xchg   %ax,%ax
  800eaa:	66 90                	xchg   %ax,%ax
  800eac:	66 90                	xchg   %ax,%ax
  800eae:	66 90                	xchg   %ax,%ax

00800eb0 <__umoddi3>:
  800eb0:	55                   	push   %ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 1c             	sub    $0x1c,%esp
  800eb7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ebb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ebf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ec3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ec7:	85 ed                	test   %ebp,%ebp
  800ec9:	89 f0                	mov    %esi,%eax
  800ecb:	89 da                	mov    %ebx,%edx
  800ecd:	75 19                	jne    800ee8 <__umoddi3+0x38>
  800ecf:	39 df                	cmp    %ebx,%edi
  800ed1:	0f 86 b1 00 00 00    	jbe    800f88 <__umoddi3+0xd8>
  800ed7:	f7 f7                	div    %edi
  800ed9:	89 d0                	mov    %edx,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	83 c4 1c             	add    $0x1c,%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi
  800ee8:	39 dd                	cmp    %ebx,%ebp
  800eea:	77 f1                	ja     800edd <__umoddi3+0x2d>
  800eec:	0f bd cd             	bsr    %ebp,%ecx
  800eef:	83 f1 1f             	xor    $0x1f,%ecx
  800ef2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ef6:	0f 84 b4 00 00 00    	je     800fb0 <__umoddi3+0x100>
  800efc:	b8 20 00 00 00       	mov    $0x20,%eax
  800f01:	89 c2                	mov    %eax,%edx
  800f03:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f07:	29 c2                	sub    %eax,%edx
  800f09:	89 c1                	mov    %eax,%ecx
  800f0b:	89 f8                	mov    %edi,%eax
  800f0d:	d3 e5                	shl    %cl,%ebp
  800f0f:	89 d1                	mov    %edx,%ecx
  800f11:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f15:	d3 e8                	shr    %cl,%eax
  800f17:	09 c5                	or     %eax,%ebp
  800f19:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f1d:	89 c1                	mov    %eax,%ecx
  800f1f:	d3 e7                	shl    %cl,%edi
  800f21:	89 d1                	mov    %edx,%ecx
  800f23:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f27:	89 df                	mov    %ebx,%edi
  800f29:	d3 ef                	shr    %cl,%edi
  800f2b:	89 c1                	mov    %eax,%ecx
  800f2d:	89 f0                	mov    %esi,%eax
  800f2f:	d3 e3                	shl    %cl,%ebx
  800f31:	89 d1                	mov    %edx,%ecx
  800f33:	89 fa                	mov    %edi,%edx
  800f35:	d3 e8                	shr    %cl,%eax
  800f37:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f3c:	09 d8                	or     %ebx,%eax
  800f3e:	f7 f5                	div    %ebp
  800f40:	d3 e6                	shl    %cl,%esi
  800f42:	89 d1                	mov    %edx,%ecx
  800f44:	f7 64 24 08          	mull   0x8(%esp)
  800f48:	39 d1                	cmp    %edx,%ecx
  800f4a:	89 c3                	mov    %eax,%ebx
  800f4c:	89 d7                	mov    %edx,%edi
  800f4e:	72 06                	jb     800f56 <__umoddi3+0xa6>
  800f50:	75 0e                	jne    800f60 <__umoddi3+0xb0>
  800f52:	39 c6                	cmp    %eax,%esi
  800f54:	73 0a                	jae    800f60 <__umoddi3+0xb0>
  800f56:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f5a:	19 ea                	sbb    %ebp,%edx
  800f5c:	89 d7                	mov    %edx,%edi
  800f5e:	89 c3                	mov    %eax,%ebx
  800f60:	89 ca                	mov    %ecx,%edx
  800f62:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f67:	29 de                	sub    %ebx,%esi
  800f69:	19 fa                	sbb    %edi,%edx
  800f6b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f6f:	89 d0                	mov    %edx,%eax
  800f71:	d3 e0                	shl    %cl,%eax
  800f73:	89 d9                	mov    %ebx,%ecx
  800f75:	d3 ee                	shr    %cl,%esi
  800f77:	d3 ea                	shr    %cl,%edx
  800f79:	09 f0                	or     %esi,%eax
  800f7b:	83 c4 1c             	add    $0x1c,%esp
  800f7e:	5b                   	pop    %ebx
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    
  800f83:	90                   	nop
  800f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f88:	85 ff                	test   %edi,%edi
  800f8a:	89 f9                	mov    %edi,%ecx
  800f8c:	75 0b                	jne    800f99 <__umoddi3+0xe9>
  800f8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f93:	31 d2                	xor    %edx,%edx
  800f95:	f7 f7                	div    %edi
  800f97:	89 c1                	mov    %eax,%ecx
  800f99:	89 d8                	mov    %ebx,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	f7 f1                	div    %ecx
  800f9f:	89 f0                	mov    %esi,%eax
  800fa1:	f7 f1                	div    %ecx
  800fa3:	e9 31 ff ff ff       	jmp    800ed9 <__umoddi3+0x29>
  800fa8:	90                   	nop
  800fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	39 dd                	cmp    %ebx,%ebp
  800fb2:	72 08                	jb     800fbc <__umoddi3+0x10c>
  800fb4:	39 f7                	cmp    %esi,%edi
  800fb6:	0f 87 21 ff ff ff    	ja     800edd <__umoddi3+0x2d>
  800fbc:	89 da                	mov    %ebx,%edx
  800fbe:	89 f0                	mov    %esi,%eax
  800fc0:	29 f8                	sub    %edi,%eax
  800fc2:	19 ea                	sbb    %ebp,%edx
  800fc4:	e9 14 ff ff ff       	jmp    800edd <__umoddi3+0x2d>
