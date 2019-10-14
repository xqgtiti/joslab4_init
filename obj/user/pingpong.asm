
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 33 0d 00 00       	call   800d74 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 4f                	jne    800097 <umain+0x64>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800048:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004b:	83 ec 04             	sub    $0x4,%esp
  80004e:	6a 00                	push   $0x0
  800050:	6a 00                	push   $0x0
  800052:	56                   	push   %esi
  800053:	e8 4a 0d 00 00       	call   800da2 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80005d:	e8 25 0b 00 00       	call   800b87 <sys_getenvid>
  800062:	57                   	push   %edi
  800063:	53                   	push   %ebx
  800064:	50                   	push   %eax
  800065:	68 b6 10 80 00       	push   $0x8010b6
  80006a:	e8 3e 01 00 00       	call   8001ad <cprintf>
		if (i == 10)
  80006f:	83 c4 20             	add    $0x20,%esp
  800072:	83 fb 0a             	cmp    $0xa,%ebx
  800075:	74 18                	je     80008f <umain+0x5c>
			return;
		i++;
  800077:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007a:	6a 00                	push   $0x0
  80007c:	6a 00                	push   $0x0
  80007e:	53                   	push   %ebx
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 32 0d 00 00       	call   800db9 <ipc_send>
		if (i == 10)
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	83 fb 0a             	cmp    $0xa,%ebx
  80008d:	75 bc                	jne    80004b <umain+0x18>
			return;
	}

}
  80008f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5f                   	pop    %edi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    
  800097:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800099:	e8 e9 0a 00 00       	call   800b87 <sys_getenvid>
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	53                   	push   %ebx
  8000a2:	50                   	push   %eax
  8000a3:	68 a0 10 80 00       	push   $0x8010a0
  8000a8:	e8 00 01 00 00       	call   8001ad <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ad:	6a 00                	push   $0x0
  8000af:	6a 00                	push   $0x0
  8000b1:	6a 00                	push   $0x0
  8000b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000b6:	e8 fe 0c 00 00       	call   800db9 <ipc_send>
  8000bb:	83 c4 20             	add    $0x20,%esp
  8000be:	eb 88                	jmp    800048 <umain+0x15>

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000cb:	e8 b7 0a 00 00       	call   800b87 <sys_getenvid>
  8000d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000dd:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e2:	85 db                	test   %ebx,%ebx
  8000e4:	7e 07                	jle    8000ed <libmain+0x2d>
		binaryname = argv[0];
  8000e6:	8b 06                	mov    (%esi),%eax
  8000e8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ed:	83 ec 08             	sub    $0x8,%esp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	e8 3c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f7:	e8 0a 00 00 00       	call   800106 <exit>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010c:	6a 00                	push   $0x0
  80010e:	e8 33 0a 00 00       	call   800b46 <sys_env_destroy>
}
  800113:	83 c4 10             	add    $0x10,%esp
  800116:	c9                   	leave  
  800117:	c3                   	ret    

00800118 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	53                   	push   %ebx
  80011c:	83 ec 04             	sub    $0x4,%esp
  80011f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800122:	8b 13                	mov    (%ebx),%edx
  800124:	8d 42 01             	lea    0x1(%edx),%eax
  800127:	89 03                	mov    %eax,(%ebx)
  800129:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800130:	3d ff 00 00 00       	cmp    $0xff,%eax
  800135:	74 09                	je     800140 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800137:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 b8 09 00 00       	call   800b09 <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	eb db                	jmp    800137 <putch+0x1f>

0080015c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800165:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016c:	00 00 00 
	b.cnt = 0;
  80016f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800176:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800179:	ff 75 0c             	pushl  0xc(%ebp)
  80017c:	ff 75 08             	pushl  0x8(%ebp)
  80017f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800185:	50                   	push   %eax
  800186:	68 18 01 80 00       	push   $0x800118
  80018b:	e8 1a 01 00 00       	call   8002aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800190:	83 c4 08             	add    $0x8,%esp
  800193:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800199:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019f:	50                   	push   %eax
  8001a0:	e8 64 09 00 00       	call   800b09 <sys_cputs>

	return b.cnt;
}
  8001a5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    

008001ad <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b6:	50                   	push   %eax
  8001b7:	ff 75 08             	pushl  0x8(%ebp)
  8001ba:	e8 9d ff ff ff       	call   80015c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	57                   	push   %edi
  8001c5:	56                   	push   %esi
  8001c6:	53                   	push   %ebx
  8001c7:	83 ec 1c             	sub    $0x1c,%esp
  8001ca:	89 c7                	mov    %eax,%edi
  8001cc:	89 d6                	mov    %edx,%esi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001da:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e8:	39 d3                	cmp    %edx,%ebx
  8001ea:	72 05                	jb     8001f1 <printnum+0x30>
  8001ec:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ef:	77 7a                	ja     80026b <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f1:	83 ec 0c             	sub    $0xc,%esp
  8001f4:	ff 75 18             	pushl  0x18(%ebp)
  8001f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fa:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001fd:	53                   	push   %ebx
  8001fe:	ff 75 10             	pushl  0x10(%ebp)
  800201:	83 ec 08             	sub    $0x8,%esp
  800204:	ff 75 e4             	pushl  -0x1c(%ebp)
  800207:	ff 75 e0             	pushl  -0x20(%ebp)
  80020a:	ff 75 dc             	pushl  -0x24(%ebp)
  80020d:	ff 75 d8             	pushl  -0x28(%ebp)
  800210:	e8 3b 0c 00 00       	call   800e50 <__udivdi3>
  800215:	83 c4 18             	add    $0x18,%esp
  800218:	52                   	push   %edx
  800219:	50                   	push   %eax
  80021a:	89 f2                	mov    %esi,%edx
  80021c:	89 f8                	mov    %edi,%eax
  80021e:	e8 9e ff ff ff       	call   8001c1 <printnum>
  800223:	83 c4 20             	add    $0x20,%esp
  800226:	eb 13                	jmp    80023b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	56                   	push   %esi
  80022c:	ff 75 18             	pushl  0x18(%ebp)
  80022f:	ff d7                	call   *%edi
  800231:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800234:	83 eb 01             	sub    $0x1,%ebx
  800237:	85 db                	test   %ebx,%ebx
  800239:	7f ed                	jg     800228 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	56                   	push   %esi
  80023f:	83 ec 04             	sub    $0x4,%esp
  800242:	ff 75 e4             	pushl  -0x1c(%ebp)
  800245:	ff 75 e0             	pushl  -0x20(%ebp)
  800248:	ff 75 dc             	pushl  -0x24(%ebp)
  80024b:	ff 75 d8             	pushl  -0x28(%ebp)
  80024e:	e8 1d 0d 00 00       	call   800f70 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 d3 10 80 00 	movsbl 0x8010d3(%eax),%eax
  80025d:	50                   	push   %eax
  80025e:	ff d7                	call   *%edi
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    
  80026b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026e:	eb c4                	jmp    800234 <printnum+0x73>

00800270 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800276:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	3b 50 04             	cmp    0x4(%eax),%edx
  80027f:	73 0a                	jae    80028b <sprintputch+0x1b>
		*b->buf++ = ch;
  800281:	8d 4a 01             	lea    0x1(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	88 02                	mov    %al,(%edx)
}
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <printfmt>:
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800293:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800296:	50                   	push   %eax
  800297:	ff 75 10             	pushl  0x10(%ebp)
  80029a:	ff 75 0c             	pushl  0xc(%ebp)
  80029d:	ff 75 08             	pushl  0x8(%ebp)
  8002a0:	e8 05 00 00 00       	call   8002aa <vprintfmt>
}
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <vprintfmt>:
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 2c             	sub    $0x2c,%esp
  8002b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bc:	e9 c1 03 00 00       	jmp    800682 <vprintfmt+0x3d8>
		padc = ' ';
  8002c1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002c5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002cc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002d3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002da:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002df:	8d 47 01             	lea    0x1(%edi),%eax
  8002e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e5:	0f b6 17             	movzbl (%edi),%edx
  8002e8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002eb:	3c 55                	cmp    $0x55,%al
  8002ed:	0f 87 12 04 00 00    	ja     800705 <vprintfmt+0x45b>
  8002f3:	0f b6 c0             	movzbl %al,%eax
  8002f6:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
  8002fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800300:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800304:	eb d9                	jmp    8002df <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800309:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030d:	eb d0                	jmp    8002df <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80030f:	0f b6 d2             	movzbl %dl,%edx
  800312:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800315:	b8 00 00 00 00       	mov    $0x0,%eax
  80031a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80031d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800320:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800324:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800327:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80032a:	83 f9 09             	cmp    $0x9,%ecx
  80032d:	77 55                	ja     800384 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80032f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800332:	eb e9                	jmp    80031d <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800334:	8b 45 14             	mov    0x14(%ebp),%eax
  800337:	8b 00                	mov    (%eax),%eax
  800339:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80033c:	8b 45 14             	mov    0x14(%ebp),%eax
  80033f:	8d 40 04             	lea    0x4(%eax),%eax
  800342:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800348:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80034c:	79 91                	jns    8002df <vprintfmt+0x35>
				width = precision, precision = -1;
  80034e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800351:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800354:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80035b:	eb 82                	jmp    8002df <vprintfmt+0x35>
  80035d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800360:	85 c0                	test   %eax,%eax
  800362:	ba 00 00 00 00       	mov    $0x0,%edx
  800367:	0f 49 d0             	cmovns %eax,%edx
  80036a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800370:	e9 6a ff ff ff       	jmp    8002df <vprintfmt+0x35>
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800378:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80037f:	e9 5b ff ff ff       	jmp    8002df <vprintfmt+0x35>
  800384:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800387:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80038a:	eb bc                	jmp    800348 <vprintfmt+0x9e>
			lflag++;
  80038c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800392:	e9 48 ff ff ff       	jmp    8002df <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800397:	8b 45 14             	mov    0x14(%ebp),%eax
  80039a:	8d 78 04             	lea    0x4(%eax),%edi
  80039d:	83 ec 08             	sub    $0x8,%esp
  8003a0:	53                   	push   %ebx
  8003a1:	ff 30                	pushl  (%eax)
  8003a3:	ff d6                	call   *%esi
			break;
  8003a5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003a8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ab:	e9 cf 02 00 00       	jmp    80067f <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 78 04             	lea    0x4(%eax),%edi
  8003b6:	8b 00                	mov    (%eax),%eax
  8003b8:	99                   	cltd   
  8003b9:	31 d0                	xor    %edx,%eax
  8003bb:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bd:	83 f8 08             	cmp    $0x8,%eax
  8003c0:	7f 23                	jg     8003e5 <vprintfmt+0x13b>
  8003c2:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  8003c9:	85 d2                	test   %edx,%edx
  8003cb:	74 18                	je     8003e5 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003cd:	52                   	push   %edx
  8003ce:	68 f4 10 80 00       	push   $0x8010f4
  8003d3:	53                   	push   %ebx
  8003d4:	56                   	push   %esi
  8003d5:	e8 b3 fe ff ff       	call   80028d <printfmt>
  8003da:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003dd:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e0:	e9 9a 02 00 00       	jmp    80067f <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003e5:	50                   	push   %eax
  8003e6:	68 eb 10 80 00       	push   $0x8010eb
  8003eb:	53                   	push   %ebx
  8003ec:	56                   	push   %esi
  8003ed:	e8 9b fe ff ff       	call   80028d <printfmt>
  8003f2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f5:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f8:	e9 82 02 00 00       	jmp    80067f <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	83 c0 04             	add    $0x4,%eax
  800403:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80040b:	85 ff                	test   %edi,%edi
  80040d:	b8 e4 10 80 00       	mov    $0x8010e4,%eax
  800412:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800415:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800419:	0f 8e bd 00 00 00    	jle    8004dc <vprintfmt+0x232>
  80041f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800423:	75 0e                	jne    800433 <vprintfmt+0x189>
  800425:	89 75 08             	mov    %esi,0x8(%ebp)
  800428:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80042b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80042e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800431:	eb 6d                	jmp    8004a0 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	ff 75 d0             	pushl  -0x30(%ebp)
  800439:	57                   	push   %edi
  80043a:	e8 6e 03 00 00       	call   8007ad <strnlen>
  80043f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800442:	29 c1                	sub    %eax,%ecx
  800444:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800447:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80044a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80044e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800451:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800454:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800456:	eb 0f                	jmp    800467 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	53                   	push   %ebx
  80045c:	ff 75 e0             	pushl  -0x20(%ebp)
  80045f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800461:	83 ef 01             	sub    $0x1,%edi
  800464:	83 c4 10             	add    $0x10,%esp
  800467:	85 ff                	test   %edi,%edi
  800469:	7f ed                	jg     800458 <vprintfmt+0x1ae>
  80046b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800471:	85 c9                	test   %ecx,%ecx
  800473:	b8 00 00 00 00       	mov    $0x0,%eax
  800478:	0f 49 c1             	cmovns %ecx,%eax
  80047b:	29 c1                	sub    %eax,%ecx
  80047d:	89 75 08             	mov    %esi,0x8(%ebp)
  800480:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800483:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800486:	89 cb                	mov    %ecx,%ebx
  800488:	eb 16                	jmp    8004a0 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80048a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048e:	75 31                	jne    8004c1 <vprintfmt+0x217>
					putch(ch, putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	ff 75 0c             	pushl  0xc(%ebp)
  800496:	50                   	push   %eax
  800497:	ff 55 08             	call   *0x8(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049d:	83 eb 01             	sub    $0x1,%ebx
  8004a0:	83 c7 01             	add    $0x1,%edi
  8004a3:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004a7:	0f be c2             	movsbl %dl,%eax
  8004aa:	85 c0                	test   %eax,%eax
  8004ac:	74 59                	je     800507 <vprintfmt+0x25d>
  8004ae:	85 f6                	test   %esi,%esi
  8004b0:	78 d8                	js     80048a <vprintfmt+0x1e0>
  8004b2:	83 ee 01             	sub    $0x1,%esi
  8004b5:	79 d3                	jns    80048a <vprintfmt+0x1e0>
  8004b7:	89 df                	mov    %ebx,%edi
  8004b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004bf:	eb 37                	jmp    8004f8 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c1:	0f be d2             	movsbl %dl,%edx
  8004c4:	83 ea 20             	sub    $0x20,%edx
  8004c7:	83 fa 5e             	cmp    $0x5e,%edx
  8004ca:	76 c4                	jbe    800490 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	ff 75 0c             	pushl  0xc(%ebp)
  8004d2:	6a 3f                	push   $0x3f
  8004d4:	ff 55 08             	call   *0x8(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	eb c1                	jmp    80049d <vprintfmt+0x1f3>
  8004dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e8:	eb b6                	jmp    8004a0 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	53                   	push   %ebx
  8004ee:	6a 20                	push   $0x20
  8004f0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004f2:	83 ef 01             	sub    $0x1,%edi
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	85 ff                	test   %edi,%edi
  8004fa:	7f ee                	jg     8004ea <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004fc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800502:	e9 78 01 00 00       	jmp    80067f <vprintfmt+0x3d5>
  800507:	89 df                	mov    %ebx,%edi
  800509:	8b 75 08             	mov    0x8(%ebp),%esi
  80050c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050f:	eb e7                	jmp    8004f8 <vprintfmt+0x24e>
	if (lflag >= 2)
  800511:	83 f9 01             	cmp    $0x1,%ecx
  800514:	7e 3f                	jle    800555 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8b 50 04             	mov    0x4(%eax),%edx
  80051c:	8b 00                	mov    (%eax),%eax
  80051e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800521:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 40 08             	lea    0x8(%eax),%eax
  80052a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80052d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800531:	79 5c                	jns    80058f <vprintfmt+0x2e5>
				putch('-', putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	53                   	push   %ebx
  800537:	6a 2d                	push   $0x2d
  800539:	ff d6                	call   *%esi
				num = -(long long) num;
  80053b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800541:	f7 da                	neg    %edx
  800543:	83 d1 00             	adc    $0x0,%ecx
  800546:	f7 d9                	neg    %ecx
  800548:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80054b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800550:	e9 10 01 00 00       	jmp    800665 <vprintfmt+0x3bb>
	else if (lflag)
  800555:	85 c9                	test   %ecx,%ecx
  800557:	75 1b                	jne    800574 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8b 00                	mov    (%eax),%eax
  80055e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800561:	89 c1                	mov    %eax,%ecx
  800563:	c1 f9 1f             	sar    $0x1f,%ecx
  800566:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 40 04             	lea    0x4(%eax),%eax
  80056f:	89 45 14             	mov    %eax,0x14(%ebp)
  800572:	eb b9                	jmp    80052d <vprintfmt+0x283>
		return va_arg(*ap, long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	89 c1                	mov    %eax,%ecx
  80057e:	c1 f9 1f             	sar    $0x1f,%ecx
  800581:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 40 04             	lea    0x4(%eax),%eax
  80058a:	89 45 14             	mov    %eax,0x14(%ebp)
  80058d:	eb 9e                	jmp    80052d <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80058f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800592:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800595:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059a:	e9 c6 00 00 00       	jmp    800665 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80059f:	83 f9 01             	cmp    $0x1,%ecx
  8005a2:	7e 18                	jle    8005bc <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8b 10                	mov    (%eax),%edx
  8005a9:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ac:	8d 40 08             	lea    0x8(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b7:	e9 a9 00 00 00       	jmp    800665 <vprintfmt+0x3bb>
	else if (lflag)
  8005bc:	85 c9                	test   %ecx,%ecx
  8005be:	75 1a                	jne    8005da <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8b 10                	mov    (%eax),%edx
  8005c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ca:	8d 40 04             	lea    0x4(%eax),%eax
  8005cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d5:	e9 8b 00 00 00       	jmp    800665 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8b 10                	mov    (%eax),%edx
  8005df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e4:	8d 40 04             	lea    0x4(%eax),%eax
  8005e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ef:	eb 74                	jmp    800665 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005f1:	83 f9 01             	cmp    $0x1,%ecx
  8005f4:	7e 15                	jle    80060b <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8b 10                	mov    (%eax),%edx
  8005fb:	8b 48 04             	mov    0x4(%eax),%ecx
  8005fe:	8d 40 08             	lea    0x8(%eax),%eax
  800601:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800604:	b8 08 00 00 00       	mov    $0x8,%eax
  800609:	eb 5a                	jmp    800665 <vprintfmt+0x3bb>
	else if (lflag)
  80060b:	85 c9                	test   %ecx,%ecx
  80060d:	75 17                	jne    800626 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 10                	mov    (%eax),%edx
  800614:	b9 00 00 00 00       	mov    $0x0,%ecx
  800619:	8d 40 04             	lea    0x4(%eax),%eax
  80061c:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80061f:	b8 08 00 00 00       	mov    $0x8,%eax
  800624:	eb 3f                	jmp    800665 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8b 10                	mov    (%eax),%edx
  80062b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800630:	8d 40 04             	lea    0x4(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800636:	b8 08 00 00 00       	mov    $0x8,%eax
  80063b:	eb 28                	jmp    800665 <vprintfmt+0x3bb>
			putch('0', putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	53                   	push   %ebx
  800641:	6a 30                	push   $0x30
  800643:	ff d6                	call   *%esi
			putch('x', putdat);
  800645:	83 c4 08             	add    $0x8,%esp
  800648:	53                   	push   %ebx
  800649:	6a 78                	push   $0x78
  80064b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8b 10                	mov    (%eax),%edx
  800652:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800657:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80065a:	8d 40 04             	lea    0x4(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800660:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800665:	83 ec 0c             	sub    $0xc,%esp
  800668:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80066c:	57                   	push   %edi
  80066d:	ff 75 e0             	pushl  -0x20(%ebp)
  800670:	50                   	push   %eax
  800671:	51                   	push   %ecx
  800672:	52                   	push   %edx
  800673:	89 da                	mov    %ebx,%edx
  800675:	89 f0                	mov    %esi,%eax
  800677:	e8 45 fb ff ff       	call   8001c1 <printnum>
			break;
  80067c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80067f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800682:	83 c7 01             	add    $0x1,%edi
  800685:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800689:	83 f8 25             	cmp    $0x25,%eax
  80068c:	0f 84 2f fc ff ff    	je     8002c1 <vprintfmt+0x17>
			if (ch == '\0')
  800692:	85 c0                	test   %eax,%eax
  800694:	0f 84 8b 00 00 00    	je     800725 <vprintfmt+0x47b>
			putch(ch, putdat);
  80069a:	83 ec 08             	sub    $0x8,%esp
  80069d:	53                   	push   %ebx
  80069e:	50                   	push   %eax
  80069f:	ff d6                	call   *%esi
  8006a1:	83 c4 10             	add    $0x10,%esp
  8006a4:	eb dc                	jmp    800682 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006a6:	83 f9 01             	cmp    $0x1,%ecx
  8006a9:	7e 15                	jle    8006c0 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 10                	mov    (%eax),%edx
  8006b0:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b3:	8d 40 08             	lea    0x8(%eax),%eax
  8006b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b9:	b8 10 00 00 00       	mov    $0x10,%eax
  8006be:	eb a5                	jmp    800665 <vprintfmt+0x3bb>
	else if (lflag)
  8006c0:	85 c9                	test   %ecx,%ecx
  8006c2:	75 17                	jne    8006db <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 10                	mov    (%eax),%edx
  8006c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ce:	8d 40 04             	lea    0x4(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d9:	eb 8a                	jmp    800665 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8b 10                	mov    (%eax),%edx
  8006e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e5:	8d 40 04             	lea    0x4(%eax),%eax
  8006e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006eb:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f0:	e9 70 ff ff ff       	jmp    800665 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	53                   	push   %ebx
  8006f9:	6a 25                	push   $0x25
  8006fb:	ff d6                	call   *%esi
			break;
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	e9 7a ff ff ff       	jmp    80067f <vprintfmt+0x3d5>
			putch('%', putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	6a 25                	push   $0x25
  80070b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	89 f8                	mov    %edi,%eax
  800712:	eb 03                	jmp    800717 <vprintfmt+0x46d>
  800714:	83 e8 01             	sub    $0x1,%eax
  800717:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80071b:	75 f7                	jne    800714 <vprintfmt+0x46a>
  80071d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800720:	e9 5a ff ff ff       	jmp    80067f <vprintfmt+0x3d5>
}
  800725:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800728:	5b                   	pop    %ebx
  800729:	5e                   	pop    %esi
  80072a:	5f                   	pop    %edi
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	83 ec 18             	sub    $0x18,%esp
  800733:	8b 45 08             	mov    0x8(%ebp),%eax
  800736:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800739:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800740:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800743:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074a:	85 c0                	test   %eax,%eax
  80074c:	74 26                	je     800774 <vsnprintf+0x47>
  80074e:	85 d2                	test   %edx,%edx
  800750:	7e 22                	jle    800774 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800752:	ff 75 14             	pushl  0x14(%ebp)
  800755:	ff 75 10             	pushl  0x10(%ebp)
  800758:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075b:	50                   	push   %eax
  80075c:	68 70 02 80 00       	push   $0x800270
  800761:	e8 44 fb ff ff       	call   8002aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800766:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800769:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076f:	83 c4 10             	add    $0x10,%esp
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    
		return -E_INVAL;
  800774:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800779:	eb f7                	jmp    800772 <vsnprintf+0x45>

0080077b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800781:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800784:	50                   	push   %eax
  800785:	ff 75 10             	pushl  0x10(%ebp)
  800788:	ff 75 0c             	pushl  0xc(%ebp)
  80078b:	ff 75 08             	pushl  0x8(%ebp)
  80078e:	e8 9a ff ff ff       	call   80072d <vsnprintf>
	va_end(ap);

	return rc;
}
  800793:	c9                   	leave  
  800794:	c3                   	ret    

00800795 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079b:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a0:	eb 03                	jmp    8007a5 <strlen+0x10>
		n++;
  8007a2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007a5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a9:	75 f7                	jne    8007a2 <strlen+0xd>
	return n;
}
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	eb 03                	jmp    8007c0 <strnlen+0x13>
		n++;
  8007bd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c0:	39 d0                	cmp    %edx,%eax
  8007c2:	74 06                	je     8007ca <strnlen+0x1d>
  8007c4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c8:	75 f3                	jne    8007bd <strnlen+0x10>
	return n;
}
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d6:	89 c2                	mov    %eax,%edx
  8007d8:	83 c1 01             	add    $0x1,%ecx
  8007db:	83 c2 01             	add    $0x1,%edx
  8007de:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e5:	84 db                	test   %bl,%bl
  8007e7:	75 ef                	jne    8007d8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e9:	5b                   	pop    %ebx
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	53                   	push   %ebx
  8007f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f3:	53                   	push   %ebx
  8007f4:	e8 9c ff ff ff       	call   800795 <strlen>
  8007f9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007fc:	ff 75 0c             	pushl  0xc(%ebp)
  8007ff:	01 d8                	add    %ebx,%eax
  800801:	50                   	push   %eax
  800802:	e8 c5 ff ff ff       	call   8007cc <strcpy>
	return dst;
}
  800807:	89 d8                	mov    %ebx,%eax
  800809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    

0080080e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	56                   	push   %esi
  800812:	53                   	push   %ebx
  800813:	8b 75 08             	mov    0x8(%ebp),%esi
  800816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800819:	89 f3                	mov    %esi,%ebx
  80081b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081e:	89 f2                	mov    %esi,%edx
  800820:	eb 0f                	jmp    800831 <strncpy+0x23>
		*dst++ = *src;
  800822:	83 c2 01             	add    $0x1,%edx
  800825:	0f b6 01             	movzbl (%ecx),%eax
  800828:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082b:	80 39 01             	cmpb   $0x1,(%ecx)
  80082e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800831:	39 da                	cmp    %ebx,%edx
  800833:	75 ed                	jne    800822 <strncpy+0x14>
	}
	return ret;
}
  800835:	89 f0                	mov    %esi,%eax
  800837:	5b                   	pop    %ebx
  800838:	5e                   	pop    %esi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
  800840:	8b 75 08             	mov    0x8(%ebp),%esi
  800843:	8b 55 0c             	mov    0xc(%ebp),%edx
  800846:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800849:	89 f0                	mov    %esi,%eax
  80084b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084f:	85 c9                	test   %ecx,%ecx
  800851:	75 0b                	jne    80085e <strlcpy+0x23>
  800853:	eb 17                	jmp    80086c <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800855:	83 c2 01             	add    $0x1,%edx
  800858:	83 c0 01             	add    $0x1,%eax
  80085b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80085e:	39 d8                	cmp    %ebx,%eax
  800860:	74 07                	je     800869 <strlcpy+0x2e>
  800862:	0f b6 0a             	movzbl (%edx),%ecx
  800865:	84 c9                	test   %cl,%cl
  800867:	75 ec                	jne    800855 <strlcpy+0x1a>
		*dst = '\0';
  800869:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086c:	29 f0                	sub    %esi,%eax
}
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800878:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087b:	eb 06                	jmp    800883 <strcmp+0x11>
		p++, q++;
  80087d:	83 c1 01             	add    $0x1,%ecx
  800880:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800883:	0f b6 01             	movzbl (%ecx),%eax
  800886:	84 c0                	test   %al,%al
  800888:	74 04                	je     80088e <strcmp+0x1c>
  80088a:	3a 02                	cmp    (%edx),%al
  80088c:	74 ef                	je     80087d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088e:	0f b6 c0             	movzbl %al,%eax
  800891:	0f b6 12             	movzbl (%edx),%edx
  800894:	29 d0                	sub    %edx,%eax
}
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	53                   	push   %ebx
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a2:	89 c3                	mov    %eax,%ebx
  8008a4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a7:	eb 06                	jmp    8008af <strncmp+0x17>
		n--, p++, q++;
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008af:	39 d8                	cmp    %ebx,%eax
  8008b1:	74 16                	je     8008c9 <strncmp+0x31>
  8008b3:	0f b6 08             	movzbl (%eax),%ecx
  8008b6:	84 c9                	test   %cl,%cl
  8008b8:	74 04                	je     8008be <strncmp+0x26>
  8008ba:	3a 0a                	cmp    (%edx),%cl
  8008bc:	74 eb                	je     8008a9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008be:	0f b6 00             	movzbl (%eax),%eax
  8008c1:	0f b6 12             	movzbl (%edx),%edx
  8008c4:	29 d0                	sub    %edx,%eax
}
  8008c6:	5b                   	pop    %ebx
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    
		return 0;
  8008c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ce:	eb f6                	jmp    8008c6 <strncmp+0x2e>

008008d0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008da:	0f b6 10             	movzbl (%eax),%edx
  8008dd:	84 d2                	test   %dl,%dl
  8008df:	74 09                	je     8008ea <strchr+0x1a>
		if (*s == c)
  8008e1:	38 ca                	cmp    %cl,%dl
  8008e3:	74 0a                	je     8008ef <strchr+0x1f>
	for (; *s; s++)
  8008e5:	83 c0 01             	add    $0x1,%eax
  8008e8:	eb f0                	jmp    8008da <strchr+0xa>
			return (char *) s;
	return 0;
  8008ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fb:	eb 03                	jmp    800900 <strfind+0xf>
  8008fd:	83 c0 01             	add    $0x1,%eax
  800900:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800903:	38 ca                	cmp    %cl,%dl
  800905:	74 04                	je     80090b <strfind+0x1a>
  800907:	84 d2                	test   %dl,%dl
  800909:	75 f2                	jne    8008fd <strfind+0xc>
			break;
	return (char *) s;
}
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	57                   	push   %edi
  800911:	56                   	push   %esi
  800912:	53                   	push   %ebx
  800913:	8b 7d 08             	mov    0x8(%ebp),%edi
  800916:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800919:	85 c9                	test   %ecx,%ecx
  80091b:	74 13                	je     800930 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800923:	75 05                	jne    80092a <memset+0x1d>
  800925:	f6 c1 03             	test   $0x3,%cl
  800928:	74 0d                	je     800937 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092d:	fc                   	cld    
  80092e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800930:	89 f8                	mov    %edi,%eax
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5f                   	pop    %edi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    
		c &= 0xFF;
  800937:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093b:	89 d3                	mov    %edx,%ebx
  80093d:	c1 e3 08             	shl    $0x8,%ebx
  800940:	89 d0                	mov    %edx,%eax
  800942:	c1 e0 18             	shl    $0x18,%eax
  800945:	89 d6                	mov    %edx,%esi
  800947:	c1 e6 10             	shl    $0x10,%esi
  80094a:	09 f0                	or     %esi,%eax
  80094c:	09 c2                	or     %eax,%edx
  80094e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800950:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800953:	89 d0                	mov    %edx,%eax
  800955:	fc                   	cld    
  800956:	f3 ab                	rep stos %eax,%es:(%edi)
  800958:	eb d6                	jmp    800930 <memset+0x23>

0080095a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	57                   	push   %edi
  80095e:	56                   	push   %esi
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 75 0c             	mov    0xc(%ebp),%esi
  800965:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800968:	39 c6                	cmp    %eax,%esi
  80096a:	73 35                	jae    8009a1 <memmove+0x47>
  80096c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096f:	39 c2                	cmp    %eax,%edx
  800971:	76 2e                	jbe    8009a1 <memmove+0x47>
		s += n;
		d += n;
  800973:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800976:	89 d6                	mov    %edx,%esi
  800978:	09 fe                	or     %edi,%esi
  80097a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800980:	74 0c                	je     80098e <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800982:	83 ef 01             	sub    $0x1,%edi
  800985:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800988:	fd                   	std    
  800989:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098b:	fc                   	cld    
  80098c:	eb 21                	jmp    8009af <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098e:	f6 c1 03             	test   $0x3,%cl
  800991:	75 ef                	jne    800982 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800993:	83 ef 04             	sub    $0x4,%edi
  800996:	8d 72 fc             	lea    -0x4(%edx),%esi
  800999:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80099c:	fd                   	std    
  80099d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099f:	eb ea                	jmp    80098b <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a1:	89 f2                	mov    %esi,%edx
  8009a3:	09 c2                	or     %eax,%edx
  8009a5:	f6 c2 03             	test   $0x3,%dl
  8009a8:	74 09                	je     8009b3 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009aa:	89 c7                	mov    %eax,%edi
  8009ac:	fc                   	cld    
  8009ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009af:	5e                   	pop    %esi
  8009b0:	5f                   	pop    %edi
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b3:	f6 c1 03             	test   $0x3,%cl
  8009b6:	75 f2                	jne    8009aa <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009bb:	89 c7                	mov    %eax,%edi
  8009bd:	fc                   	cld    
  8009be:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c0:	eb ed                	jmp    8009af <memmove+0x55>

008009c2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c5:	ff 75 10             	pushl  0x10(%ebp)
  8009c8:	ff 75 0c             	pushl  0xc(%ebp)
  8009cb:	ff 75 08             	pushl  0x8(%ebp)
  8009ce:	e8 87 ff ff ff       	call   80095a <memmove>
}
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	56                   	push   %esi
  8009d9:	53                   	push   %ebx
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e0:	89 c6                	mov    %eax,%esi
  8009e2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e5:	39 f0                	cmp    %esi,%eax
  8009e7:	74 1c                	je     800a05 <memcmp+0x30>
		if (*s1 != *s2)
  8009e9:	0f b6 08             	movzbl (%eax),%ecx
  8009ec:	0f b6 1a             	movzbl (%edx),%ebx
  8009ef:	38 d9                	cmp    %bl,%cl
  8009f1:	75 08                	jne    8009fb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	83 c2 01             	add    $0x1,%edx
  8009f9:	eb ea                	jmp    8009e5 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009fb:	0f b6 c1             	movzbl %cl,%eax
  8009fe:	0f b6 db             	movzbl %bl,%ebx
  800a01:	29 d8                	sub    %ebx,%eax
  800a03:	eb 05                	jmp    800a0a <memcmp+0x35>
	}

	return 0;
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0a:	5b                   	pop    %ebx
  800a0b:	5e                   	pop    %esi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a17:	89 c2                	mov    %eax,%edx
  800a19:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1c:	39 d0                	cmp    %edx,%eax
  800a1e:	73 09                	jae    800a29 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a20:	38 08                	cmp    %cl,(%eax)
  800a22:	74 05                	je     800a29 <memfind+0x1b>
	for (; s < ends; s++)
  800a24:	83 c0 01             	add    $0x1,%eax
  800a27:	eb f3                	jmp    800a1c <memfind+0xe>
			break;
	return (void *) s;
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	57                   	push   %edi
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
  800a31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a34:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a37:	eb 03                	jmp    800a3c <strtol+0x11>
		s++;
  800a39:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a3c:	0f b6 01             	movzbl (%ecx),%eax
  800a3f:	3c 20                	cmp    $0x20,%al
  800a41:	74 f6                	je     800a39 <strtol+0xe>
  800a43:	3c 09                	cmp    $0x9,%al
  800a45:	74 f2                	je     800a39 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a47:	3c 2b                	cmp    $0x2b,%al
  800a49:	74 2e                	je     800a79 <strtol+0x4e>
	int neg = 0;
  800a4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a50:	3c 2d                	cmp    $0x2d,%al
  800a52:	74 2f                	je     800a83 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a54:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5a:	75 05                	jne    800a61 <strtol+0x36>
  800a5c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5f:	74 2c                	je     800a8d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a61:	85 db                	test   %ebx,%ebx
  800a63:	75 0a                	jne    800a6f <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a65:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a6a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6d:	74 28                	je     800a97 <strtol+0x6c>
		base = 10;
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a74:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a77:	eb 50                	jmp    800ac9 <strtol+0x9e>
		s++;
  800a79:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a7c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a81:	eb d1                	jmp    800a54 <strtol+0x29>
		s++, neg = 1;
  800a83:	83 c1 01             	add    $0x1,%ecx
  800a86:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8b:	eb c7                	jmp    800a54 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a91:	74 0e                	je     800aa1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a93:	85 db                	test   %ebx,%ebx
  800a95:	75 d8                	jne    800a6f <strtol+0x44>
		s++, base = 8;
  800a97:	83 c1 01             	add    $0x1,%ecx
  800a9a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a9f:	eb ce                	jmp    800a6f <strtol+0x44>
		s += 2, base = 16;
  800aa1:	83 c1 02             	add    $0x2,%ecx
  800aa4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa9:	eb c4                	jmp    800a6f <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aab:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aae:	89 f3                	mov    %esi,%ebx
  800ab0:	80 fb 19             	cmp    $0x19,%bl
  800ab3:	77 29                	ja     800ade <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ab5:	0f be d2             	movsbl %dl,%edx
  800ab8:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800abb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800abe:	7d 30                	jge    800af0 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ac0:	83 c1 01             	add    $0x1,%ecx
  800ac3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ac9:	0f b6 11             	movzbl (%ecx),%edx
  800acc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800acf:	89 f3                	mov    %esi,%ebx
  800ad1:	80 fb 09             	cmp    $0x9,%bl
  800ad4:	77 d5                	ja     800aab <strtol+0x80>
			dig = *s - '0';
  800ad6:	0f be d2             	movsbl %dl,%edx
  800ad9:	83 ea 30             	sub    $0x30,%edx
  800adc:	eb dd                	jmp    800abb <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ade:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae1:	89 f3                	mov    %esi,%ebx
  800ae3:	80 fb 19             	cmp    $0x19,%bl
  800ae6:	77 08                	ja     800af0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ae8:	0f be d2             	movsbl %dl,%edx
  800aeb:	83 ea 37             	sub    $0x37,%edx
  800aee:	eb cb                	jmp    800abb <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800af0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af4:	74 05                	je     800afb <strtol+0xd0>
		*endptr = (char *) s;
  800af6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800afb:	89 c2                	mov    %eax,%edx
  800afd:	f7 da                	neg    %edx
  800aff:	85 ff                	test   %edi,%edi
  800b01:	0f 45 c2             	cmovne %edx,%eax
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1a:	89 c3                	mov    %eax,%ebx
  800b1c:	89 c7                	mov    %eax,%edi
  800b1e:	89 c6                	mov    %eax,%esi
  800b20:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b32:	b8 01 00 00 00       	mov    $0x1,%eax
  800b37:	89 d1                	mov    %edx,%ecx
  800b39:	89 d3                	mov    %edx,%ebx
  800b3b:	89 d7                	mov    %edx,%edi
  800b3d:	89 d6                	mov    %edx,%esi
  800b3f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
  800b4c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b54:	8b 55 08             	mov    0x8(%ebp),%edx
  800b57:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5c:	89 cb                	mov    %ecx,%ebx
  800b5e:	89 cf                	mov    %ecx,%edi
  800b60:	89 ce                	mov    %ecx,%esi
  800b62:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b64:	85 c0                	test   %eax,%eax
  800b66:	7f 08                	jg     800b70 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b70:	83 ec 0c             	sub    $0xc,%esp
  800b73:	50                   	push   %eax
  800b74:	6a 03                	push   $0x3
  800b76:	68 24 13 80 00       	push   $0x801324
  800b7b:	6a 23                	push   $0x23
  800b7d:	68 41 13 80 00       	push   $0x801341
  800b82:	e8 82 02 00 00       	call   800e09 <_panic>

00800b87 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 02 00 00 00       	mov    $0x2,%eax
  800b97:	89 d1                	mov    %edx,%ecx
  800b99:	89 d3                	mov    %edx,%ebx
  800b9b:	89 d7                	mov    %edx,%edi
  800b9d:	89 d6                	mov    %edx,%esi
  800b9f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_yield>:

void
sys_yield(void)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bac:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb6:	89 d1                	mov    %edx,%ecx
  800bb8:	89 d3                	mov    %edx,%ebx
  800bba:	89 d7                	mov    %edx,%edi
  800bbc:	89 d6                	mov    %edx,%esi
  800bbe:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bce:	be 00 00 00 00       	mov    $0x0,%esi
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bde:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be1:	89 f7                	mov    %esi,%edi
  800be3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7f 08                	jg     800bf1 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	50                   	push   %eax
  800bf5:	6a 04                	push   $0x4
  800bf7:	68 24 13 80 00       	push   $0x801324
  800bfc:	6a 23                	push   $0x23
  800bfe:	68 41 13 80 00       	push   $0x801341
  800c03:	e8 01 02 00 00       	call   800e09 <_panic>

00800c08 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c22:	8b 75 18             	mov    0x18(%ebp),%esi
  800c25:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7f 08                	jg     800c33 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	50                   	push   %eax
  800c37:	6a 05                	push   $0x5
  800c39:	68 24 13 80 00       	push   $0x801324
  800c3e:	6a 23                	push   $0x23
  800c40:	68 41 13 80 00       	push   $0x801341
  800c45:	e8 bf 01 00 00       	call   800e09 <_panic>

00800c4a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c63:	89 df                	mov    %ebx,%edi
  800c65:	89 de                	mov    %ebx,%esi
  800c67:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7f 08                	jg     800c75 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	83 ec 0c             	sub    $0xc,%esp
  800c78:	50                   	push   %eax
  800c79:	6a 06                	push   $0x6
  800c7b:	68 24 13 80 00       	push   $0x801324
  800c80:	6a 23                	push   $0x23
  800c82:	68 41 13 80 00       	push   $0x801341
  800c87:	e8 7d 01 00 00       	call   800e09 <_panic>

00800c8c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca5:	89 df                	mov    %ebx,%edi
  800ca7:	89 de                	mov    %ebx,%esi
  800ca9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7f 08                	jg     800cb7 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	6a 08                	push   $0x8
  800cbd:	68 24 13 80 00       	push   $0x801324
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 41 13 80 00       	push   $0x801341
  800cc9:	e8 3b 01 00 00       	call   800e09 <_panic>

00800cce <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce7:	89 df                	mov    %ebx,%edi
  800ce9:	89 de                	mov    %ebx,%esi
  800ceb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ced:	85 c0                	test   %eax,%eax
  800cef:	7f 08                	jg     800cf9 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf9:	83 ec 0c             	sub    $0xc,%esp
  800cfc:	50                   	push   %eax
  800cfd:	6a 09                	push   $0x9
  800cff:	68 24 13 80 00       	push   $0x801324
  800d04:	6a 23                	push   $0x23
  800d06:	68 41 13 80 00       	push   $0x801341
  800d0b:	e8 f9 00 00 00       	call   800e09 <_panic>

00800d10 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d21:	be 00 00 00 00       	mov    $0x0,%esi
  800d26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d49:	89 cb                	mov    %ecx,%ebx
  800d4b:	89 cf                	mov    %ecx,%edi
  800d4d:	89 ce                	mov    %ecx,%esi
  800d4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7f 08                	jg     800d5d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	6a 0c                	push   $0xc
  800d63:	68 24 13 80 00       	push   $0x801324
  800d68:	6a 23                	push   $0x23
  800d6a:	68 41 13 80 00       	push   $0x801341
  800d6f:	e8 95 00 00 00       	call   800e09 <_panic>

00800d74 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d7a:	68 5b 13 80 00       	push   $0x80135b
  800d7f:	6a 51                	push   $0x51
  800d81:	68 4f 13 80 00       	push   $0x80134f
  800d86:	e8 7e 00 00 00       	call   800e09 <_panic>

00800d8b <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d91:	68 5a 13 80 00       	push   $0x80135a
  800d96:	6a 58                	push   $0x58
  800d98:	68 4f 13 80 00       	push   $0x80134f
  800d9d:	e8 67 00 00 00       	call   800e09 <_panic>

00800da2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800da8:	68 70 13 80 00       	push   $0x801370
  800dad:	6a 1a                	push   $0x1a
  800daf:	68 89 13 80 00       	push   $0x801389
  800db4:	e8 50 00 00 00       	call   800e09 <_panic>

00800db9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800dbf:	68 93 13 80 00       	push   $0x801393
  800dc4:	6a 2a                	push   $0x2a
  800dc6:	68 89 13 80 00       	push   $0x801389
  800dcb:	e8 39 00 00 00       	call   800e09 <_panic>

00800dd0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800dd6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800ddb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800dde:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800de4:	8b 52 50             	mov    0x50(%edx),%edx
  800de7:	39 ca                	cmp    %ecx,%edx
  800de9:	74 11                	je     800dfc <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  800deb:	83 c0 01             	add    $0x1,%eax
  800dee:	3d 00 04 00 00       	cmp    $0x400,%eax
  800df3:	75 e6                	jne    800ddb <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800df5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfa:	eb 0b                	jmp    800e07 <ipc_find_env+0x37>
			return envs[i].env_id;
  800dfc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800dff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e04:	8b 40 48             	mov    0x48(%eax),%eax
}
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e0e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e11:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e17:	e8 6b fd ff ff       	call   800b87 <sys_getenvid>
  800e1c:	83 ec 0c             	sub    $0xc,%esp
  800e1f:	ff 75 0c             	pushl  0xc(%ebp)
  800e22:	ff 75 08             	pushl  0x8(%ebp)
  800e25:	56                   	push   %esi
  800e26:	50                   	push   %eax
  800e27:	68 ac 13 80 00       	push   $0x8013ac
  800e2c:	e8 7c f3 ff ff       	call   8001ad <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e31:	83 c4 18             	add    $0x18,%esp
  800e34:	53                   	push   %ebx
  800e35:	ff 75 10             	pushl  0x10(%ebp)
  800e38:	e8 1f f3 ff ff       	call   80015c <vcprintf>
	cprintf("\n");
  800e3d:	c7 04 24 c7 10 80 00 	movl   $0x8010c7,(%esp)
  800e44:	e8 64 f3 ff ff       	call   8001ad <cprintf>
  800e49:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e4c:	cc                   	int3   
  800e4d:	eb fd                	jmp    800e4c <_panic+0x43>
  800e4f:	90                   	nop

00800e50 <__udivdi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e5b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e63:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e67:	85 d2                	test   %edx,%edx
  800e69:	75 35                	jne    800ea0 <__udivdi3+0x50>
  800e6b:	39 f3                	cmp    %esi,%ebx
  800e6d:	0f 87 bd 00 00 00    	ja     800f30 <__udivdi3+0xe0>
  800e73:	85 db                	test   %ebx,%ebx
  800e75:	89 d9                	mov    %ebx,%ecx
  800e77:	75 0b                	jne    800e84 <__udivdi3+0x34>
  800e79:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7e:	31 d2                	xor    %edx,%edx
  800e80:	f7 f3                	div    %ebx
  800e82:	89 c1                	mov    %eax,%ecx
  800e84:	31 d2                	xor    %edx,%edx
  800e86:	89 f0                	mov    %esi,%eax
  800e88:	f7 f1                	div    %ecx
  800e8a:	89 c6                	mov    %eax,%esi
  800e8c:	89 e8                	mov    %ebp,%eax
  800e8e:	89 f7                	mov    %esi,%edi
  800e90:	f7 f1                	div    %ecx
  800e92:	89 fa                	mov    %edi,%edx
  800e94:	83 c4 1c             	add    $0x1c,%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    
  800e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	39 f2                	cmp    %esi,%edx
  800ea2:	77 7c                	ja     800f20 <__udivdi3+0xd0>
  800ea4:	0f bd fa             	bsr    %edx,%edi
  800ea7:	83 f7 1f             	xor    $0x1f,%edi
  800eaa:	0f 84 98 00 00 00    	je     800f48 <__udivdi3+0xf8>
  800eb0:	89 f9                	mov    %edi,%ecx
  800eb2:	b8 20 00 00 00       	mov    $0x20,%eax
  800eb7:	29 f8                	sub    %edi,%eax
  800eb9:	d3 e2                	shl    %cl,%edx
  800ebb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ebf:	89 c1                	mov    %eax,%ecx
  800ec1:	89 da                	mov    %ebx,%edx
  800ec3:	d3 ea                	shr    %cl,%edx
  800ec5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ec9:	09 d1                	or     %edx,%ecx
  800ecb:	89 f2                	mov    %esi,%edx
  800ecd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ed1:	89 f9                	mov    %edi,%ecx
  800ed3:	d3 e3                	shl    %cl,%ebx
  800ed5:	89 c1                	mov    %eax,%ecx
  800ed7:	d3 ea                	shr    %cl,%edx
  800ed9:	89 f9                	mov    %edi,%ecx
  800edb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800edf:	d3 e6                	shl    %cl,%esi
  800ee1:	89 eb                	mov    %ebp,%ebx
  800ee3:	89 c1                	mov    %eax,%ecx
  800ee5:	d3 eb                	shr    %cl,%ebx
  800ee7:	09 de                	or     %ebx,%esi
  800ee9:	89 f0                	mov    %esi,%eax
  800eeb:	f7 74 24 08          	divl   0x8(%esp)
  800eef:	89 d6                	mov    %edx,%esi
  800ef1:	89 c3                	mov    %eax,%ebx
  800ef3:	f7 64 24 0c          	mull   0xc(%esp)
  800ef7:	39 d6                	cmp    %edx,%esi
  800ef9:	72 0c                	jb     800f07 <__udivdi3+0xb7>
  800efb:	89 f9                	mov    %edi,%ecx
  800efd:	d3 e5                	shl    %cl,%ebp
  800eff:	39 c5                	cmp    %eax,%ebp
  800f01:	73 5d                	jae    800f60 <__udivdi3+0x110>
  800f03:	39 d6                	cmp    %edx,%esi
  800f05:	75 59                	jne    800f60 <__udivdi3+0x110>
  800f07:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f0a:	31 ff                	xor    %edi,%edi
  800f0c:	89 fa                	mov    %edi,%edx
  800f0e:	83 c4 1c             	add    $0x1c,%esp
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5f                   	pop    %edi
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    
  800f16:	8d 76 00             	lea    0x0(%esi),%esi
  800f19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f20:	31 ff                	xor    %edi,%edi
  800f22:	31 c0                	xor    %eax,%eax
  800f24:	89 fa                	mov    %edi,%edx
  800f26:	83 c4 1c             	add    $0x1c,%esp
  800f29:	5b                   	pop    %ebx
  800f2a:	5e                   	pop    %esi
  800f2b:	5f                   	pop    %edi
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    
  800f2e:	66 90                	xchg   %ax,%ax
  800f30:	31 ff                	xor    %edi,%edi
  800f32:	89 e8                	mov    %ebp,%eax
  800f34:	89 f2                	mov    %esi,%edx
  800f36:	f7 f3                	div    %ebx
  800f38:	89 fa                	mov    %edi,%edx
  800f3a:	83 c4 1c             	add    $0x1c,%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    
  800f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f48:	39 f2                	cmp    %esi,%edx
  800f4a:	72 06                	jb     800f52 <__udivdi3+0x102>
  800f4c:	31 c0                	xor    %eax,%eax
  800f4e:	39 eb                	cmp    %ebp,%ebx
  800f50:	77 d2                	ja     800f24 <__udivdi3+0xd4>
  800f52:	b8 01 00 00 00       	mov    $0x1,%eax
  800f57:	eb cb                	jmp    800f24 <__udivdi3+0xd4>
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f60:	89 d8                	mov    %ebx,%eax
  800f62:	31 ff                	xor    %edi,%edi
  800f64:	eb be                	jmp    800f24 <__udivdi3+0xd4>
  800f66:	66 90                	xchg   %ax,%ax
  800f68:	66 90                	xchg   %ax,%ax
  800f6a:	66 90                	xchg   %ax,%ax
  800f6c:	66 90                	xchg   %ax,%ax
  800f6e:	66 90                	xchg   %ax,%ax

00800f70 <__umoddi3>:
  800f70:	55                   	push   %ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	53                   	push   %ebx
  800f74:	83 ec 1c             	sub    $0x1c,%esp
  800f77:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f87:	85 ed                	test   %ebp,%ebp
  800f89:	89 f0                	mov    %esi,%eax
  800f8b:	89 da                	mov    %ebx,%edx
  800f8d:	75 19                	jne    800fa8 <__umoddi3+0x38>
  800f8f:	39 df                	cmp    %ebx,%edi
  800f91:	0f 86 b1 00 00 00    	jbe    801048 <__umoddi3+0xd8>
  800f97:	f7 f7                	div    %edi
  800f99:	89 d0                	mov    %edx,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	83 c4 1c             	add    $0x1c,%esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    
  800fa5:	8d 76 00             	lea    0x0(%esi),%esi
  800fa8:	39 dd                	cmp    %ebx,%ebp
  800faa:	77 f1                	ja     800f9d <__umoddi3+0x2d>
  800fac:	0f bd cd             	bsr    %ebp,%ecx
  800faf:	83 f1 1f             	xor    $0x1f,%ecx
  800fb2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fb6:	0f 84 b4 00 00 00    	je     801070 <__umoddi3+0x100>
  800fbc:	b8 20 00 00 00       	mov    $0x20,%eax
  800fc1:	89 c2                	mov    %eax,%edx
  800fc3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fc7:	29 c2                	sub    %eax,%edx
  800fc9:	89 c1                	mov    %eax,%ecx
  800fcb:	89 f8                	mov    %edi,%eax
  800fcd:	d3 e5                	shl    %cl,%ebp
  800fcf:	89 d1                	mov    %edx,%ecx
  800fd1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fd5:	d3 e8                	shr    %cl,%eax
  800fd7:	09 c5                	or     %eax,%ebp
  800fd9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fdd:	89 c1                	mov    %eax,%ecx
  800fdf:	d3 e7                	shl    %cl,%edi
  800fe1:	89 d1                	mov    %edx,%ecx
  800fe3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fe7:	89 df                	mov    %ebx,%edi
  800fe9:	d3 ef                	shr    %cl,%edi
  800feb:	89 c1                	mov    %eax,%ecx
  800fed:	89 f0                	mov    %esi,%eax
  800fef:	d3 e3                	shl    %cl,%ebx
  800ff1:	89 d1                	mov    %edx,%ecx
  800ff3:	89 fa                	mov    %edi,%edx
  800ff5:	d3 e8                	shr    %cl,%eax
  800ff7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ffc:	09 d8                	or     %ebx,%eax
  800ffe:	f7 f5                	div    %ebp
  801000:	d3 e6                	shl    %cl,%esi
  801002:	89 d1                	mov    %edx,%ecx
  801004:	f7 64 24 08          	mull   0x8(%esp)
  801008:	39 d1                	cmp    %edx,%ecx
  80100a:	89 c3                	mov    %eax,%ebx
  80100c:	89 d7                	mov    %edx,%edi
  80100e:	72 06                	jb     801016 <__umoddi3+0xa6>
  801010:	75 0e                	jne    801020 <__umoddi3+0xb0>
  801012:	39 c6                	cmp    %eax,%esi
  801014:	73 0a                	jae    801020 <__umoddi3+0xb0>
  801016:	2b 44 24 08          	sub    0x8(%esp),%eax
  80101a:	19 ea                	sbb    %ebp,%edx
  80101c:	89 d7                	mov    %edx,%edi
  80101e:	89 c3                	mov    %eax,%ebx
  801020:	89 ca                	mov    %ecx,%edx
  801022:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801027:	29 de                	sub    %ebx,%esi
  801029:	19 fa                	sbb    %edi,%edx
  80102b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80102f:	89 d0                	mov    %edx,%eax
  801031:	d3 e0                	shl    %cl,%eax
  801033:	89 d9                	mov    %ebx,%ecx
  801035:	d3 ee                	shr    %cl,%esi
  801037:	d3 ea                	shr    %cl,%edx
  801039:	09 f0                	or     %esi,%eax
  80103b:	83 c4 1c             	add    $0x1c,%esp
  80103e:	5b                   	pop    %ebx
  80103f:	5e                   	pop    %esi
  801040:	5f                   	pop    %edi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    
  801043:	90                   	nop
  801044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801048:	85 ff                	test   %edi,%edi
  80104a:	89 f9                	mov    %edi,%ecx
  80104c:	75 0b                	jne    801059 <__umoddi3+0xe9>
  80104e:	b8 01 00 00 00       	mov    $0x1,%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	f7 f7                	div    %edi
  801057:	89 c1                	mov    %eax,%ecx
  801059:	89 d8                	mov    %ebx,%eax
  80105b:	31 d2                	xor    %edx,%edx
  80105d:	f7 f1                	div    %ecx
  80105f:	89 f0                	mov    %esi,%eax
  801061:	f7 f1                	div    %ecx
  801063:	e9 31 ff ff ff       	jmp    800f99 <__umoddi3+0x29>
  801068:	90                   	nop
  801069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801070:	39 dd                	cmp    %ebx,%ebp
  801072:	72 08                	jb     80107c <__umoddi3+0x10c>
  801074:	39 f7                	cmp    %esi,%edi
  801076:	0f 87 21 ff ff ff    	ja     800f9d <__umoddi3+0x2d>
  80107c:	89 da                	mov    %ebx,%edx
  80107e:	89 f0                	mov    %esi,%eax
  801080:	29 f8                	sub    %edi,%eax
  801082:	19 ea                	sbb    %ebp,%edx
  801084:	e9 14 ff ff ff       	jmp    800f9d <__umoddi3+0x2d>
