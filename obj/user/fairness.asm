
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 28 0b 00 00       	call   800b68 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 f7 0c 00 00       	call   800d55 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 60 10 80 00       	push   $0x801060
  80006a:	e8 1f 01 00 00       	call   80018e <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 71 10 80 00       	push   $0x801071
  800083:	e8 06 01 00 00       	call   80018e <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 d0 0c 00 00       	call   800d6c <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 b7 0a 00 00       	call   800b68 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	e8 33 0a 00 00       	call   800b27 <sys_env_destroy>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 04             	sub    $0x4,%esp
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800103:	8b 13                	mov    (%ebx),%edx
  800105:	8d 42 01             	lea    0x1(%edx),%eax
  800108:	89 03                	mov    %eax,(%ebx)
  80010a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800111:	3d ff 00 00 00       	cmp    $0xff,%eax
  800116:	74 09                	je     800121 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800118:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80011f:	c9                   	leave  
  800120:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800121:	83 ec 08             	sub    $0x8,%esp
  800124:	68 ff 00 00 00       	push   $0xff
  800129:	8d 43 08             	lea    0x8(%ebx),%eax
  80012c:	50                   	push   %eax
  80012d:	e8 b8 09 00 00       	call   800aea <sys_cputs>
		b->idx = 0;
  800132:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	eb db                	jmp    800118 <putch+0x1f>

0080013d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800146:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014d:	00 00 00 
	b.cnt = 0;
  800150:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800157:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015a:	ff 75 0c             	pushl  0xc(%ebp)
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800166:	50                   	push   %eax
  800167:	68 f9 00 80 00       	push   $0x8000f9
  80016c:	e8 1a 01 00 00       	call   80028b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800171:	83 c4 08             	add    $0x8,%esp
  800174:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	e8 64 09 00 00       	call   800aea <sys_cputs>

	return b.cnt;
}
  800186:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    

0080018e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800194:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800197:	50                   	push   %eax
  800198:	ff 75 08             	pushl  0x8(%ebp)
  80019b:	e8 9d ff ff ff       	call   80013d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	57                   	push   %edi
  8001a6:	56                   	push   %esi
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 1c             	sub    $0x1c,%esp
  8001ab:	89 c7                	mov    %eax,%edi
  8001ad:	89 d6                	mov    %edx,%esi
  8001af:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c9:	39 d3                	cmp    %edx,%ebx
  8001cb:	72 05                	jb     8001d2 <printnum+0x30>
  8001cd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d0:	77 7a                	ja     80024c <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	ff 75 18             	pushl  0x18(%ebp)
  8001d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8001db:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001de:	53                   	push   %ebx
  8001df:	ff 75 10             	pushl  0x10(%ebp)
  8001e2:	83 ec 08             	sub    $0x8,%esp
  8001e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f1:	e8 1a 0c 00 00       	call   800e10 <__udivdi3>
  8001f6:	83 c4 18             	add    $0x18,%esp
  8001f9:	52                   	push   %edx
  8001fa:	50                   	push   %eax
  8001fb:	89 f2                	mov    %esi,%edx
  8001fd:	89 f8                	mov    %edi,%eax
  8001ff:	e8 9e ff ff ff       	call   8001a2 <printnum>
  800204:	83 c4 20             	add    $0x20,%esp
  800207:	eb 13                	jmp    80021c <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	56                   	push   %esi
  80020d:	ff 75 18             	pushl  0x18(%ebp)
  800210:	ff d7                	call   *%edi
  800212:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800215:	83 eb 01             	sub    $0x1,%ebx
  800218:	85 db                	test   %ebx,%ebx
  80021a:	7f ed                	jg     800209 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	56                   	push   %esi
  800220:	83 ec 04             	sub    $0x4,%esp
  800223:	ff 75 e4             	pushl  -0x1c(%ebp)
  800226:	ff 75 e0             	pushl  -0x20(%ebp)
  800229:	ff 75 dc             	pushl  -0x24(%ebp)
  80022c:	ff 75 d8             	pushl  -0x28(%ebp)
  80022f:	e8 fc 0c 00 00       	call   800f30 <__umoddi3>
  800234:	83 c4 14             	add    $0x14,%esp
  800237:	0f be 80 92 10 80 00 	movsbl 0x801092(%eax),%eax
  80023e:	50                   	push   %eax
  80023f:	ff d7                	call   *%edi
}
  800241:	83 c4 10             	add    $0x10,%esp
  800244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800247:	5b                   	pop    %ebx
  800248:	5e                   	pop    %esi
  800249:	5f                   	pop    %edi
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    
  80024c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80024f:	eb c4                	jmp    800215 <printnum+0x73>

00800251 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800257:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025b:	8b 10                	mov    (%eax),%edx
  80025d:	3b 50 04             	cmp    0x4(%eax),%edx
  800260:	73 0a                	jae    80026c <sprintputch+0x1b>
		*b->buf++ = ch;
  800262:	8d 4a 01             	lea    0x1(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 45 08             	mov    0x8(%ebp),%eax
  80026a:	88 02                	mov    %al,(%edx)
}
  80026c:	5d                   	pop    %ebp
  80026d:	c3                   	ret    

0080026e <printfmt>:
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800274:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800277:	50                   	push   %eax
  800278:	ff 75 10             	pushl  0x10(%ebp)
  80027b:	ff 75 0c             	pushl  0xc(%ebp)
  80027e:	ff 75 08             	pushl  0x8(%ebp)
  800281:	e8 05 00 00 00       	call   80028b <vprintfmt>
}
  800286:	83 c4 10             	add    $0x10,%esp
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <vprintfmt>:
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	57                   	push   %edi
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 2c             	sub    $0x2c,%esp
  800294:	8b 75 08             	mov    0x8(%ebp),%esi
  800297:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029d:	e9 c1 03 00 00       	jmp    800663 <vprintfmt+0x3d8>
		padc = ' ';
  8002a2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002a6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002bb:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002c0:	8d 47 01             	lea    0x1(%edi),%eax
  8002c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002c6:	0f b6 17             	movzbl (%edi),%edx
  8002c9:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002cc:	3c 55                	cmp    $0x55,%al
  8002ce:	0f 87 12 04 00 00    	ja     8006e6 <vprintfmt+0x45b>
  8002d4:	0f b6 c0             	movzbl %al,%eax
  8002d7:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  8002de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002e1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002e5:	eb d9                	jmp    8002c0 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002ea:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002ee:	eb d0                	jmp    8002c0 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002f0:	0f b6 d2             	movzbl %dl,%edx
  8002f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002fe:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800301:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800305:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800308:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80030b:	83 f9 09             	cmp    $0x9,%ecx
  80030e:	77 55                	ja     800365 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800310:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800313:	eb e9                	jmp    8002fe <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800315:	8b 45 14             	mov    0x14(%ebp),%eax
  800318:	8b 00                	mov    (%eax),%eax
  80031a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80031d:	8b 45 14             	mov    0x14(%ebp),%eax
  800320:	8d 40 04             	lea    0x4(%eax),%eax
  800323:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800329:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80032d:	79 91                	jns    8002c0 <vprintfmt+0x35>
				width = precision, precision = -1;
  80032f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800332:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800335:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80033c:	eb 82                	jmp    8002c0 <vprintfmt+0x35>
  80033e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800341:	85 c0                	test   %eax,%eax
  800343:	ba 00 00 00 00       	mov    $0x0,%edx
  800348:	0f 49 d0             	cmovns %eax,%edx
  80034b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800351:	e9 6a ff ff ff       	jmp    8002c0 <vprintfmt+0x35>
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800359:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800360:	e9 5b ff ff ff       	jmp    8002c0 <vprintfmt+0x35>
  800365:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800368:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80036b:	eb bc                	jmp    800329 <vprintfmt+0x9e>
			lflag++;
  80036d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800373:	e9 48 ff ff ff       	jmp    8002c0 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8d 78 04             	lea    0x4(%eax),%edi
  80037e:	83 ec 08             	sub    $0x8,%esp
  800381:	53                   	push   %ebx
  800382:	ff 30                	pushl  (%eax)
  800384:	ff d6                	call   *%esi
			break;
  800386:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800389:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80038c:	e9 cf 02 00 00       	jmp    800660 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800391:	8b 45 14             	mov    0x14(%ebp),%eax
  800394:	8d 78 04             	lea    0x4(%eax),%edi
  800397:	8b 00                	mov    (%eax),%eax
  800399:	99                   	cltd   
  80039a:	31 d0                	xor    %edx,%eax
  80039c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80039e:	83 f8 08             	cmp    $0x8,%eax
  8003a1:	7f 23                	jg     8003c6 <vprintfmt+0x13b>
  8003a3:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  8003aa:	85 d2                	test   %edx,%edx
  8003ac:	74 18                	je     8003c6 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003ae:	52                   	push   %edx
  8003af:	68 b3 10 80 00       	push   $0x8010b3
  8003b4:	53                   	push   %ebx
  8003b5:	56                   	push   %esi
  8003b6:	e8 b3 fe ff ff       	call   80026e <printfmt>
  8003bb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003be:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003c1:	e9 9a 02 00 00       	jmp    800660 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003c6:	50                   	push   %eax
  8003c7:	68 aa 10 80 00       	push   $0x8010aa
  8003cc:	53                   	push   %ebx
  8003cd:	56                   	push   %esi
  8003ce:	e8 9b fe ff ff       	call   80026e <printfmt>
  8003d3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d6:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003d9:	e9 82 02 00 00       	jmp    800660 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003de:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e1:	83 c0 04             	add    $0x4,%eax
  8003e4:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ea:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003ec:	85 ff                	test   %edi,%edi
  8003ee:	b8 a3 10 80 00       	mov    $0x8010a3,%eax
  8003f3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fa:	0f 8e bd 00 00 00    	jle    8004bd <vprintfmt+0x232>
  800400:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800404:	75 0e                	jne    800414 <vprintfmt+0x189>
  800406:	89 75 08             	mov    %esi,0x8(%ebp)
  800409:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80040c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80040f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800412:	eb 6d                	jmp    800481 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800414:	83 ec 08             	sub    $0x8,%esp
  800417:	ff 75 d0             	pushl  -0x30(%ebp)
  80041a:	57                   	push   %edi
  80041b:	e8 6e 03 00 00       	call   80078e <strnlen>
  800420:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800423:	29 c1                	sub    %eax,%ecx
  800425:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800428:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80042f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800432:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800435:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800437:	eb 0f                	jmp    800448 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	53                   	push   %ebx
  80043d:	ff 75 e0             	pushl  -0x20(%ebp)
  800440:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800442:	83 ef 01             	sub    $0x1,%edi
  800445:	83 c4 10             	add    $0x10,%esp
  800448:	85 ff                	test   %edi,%edi
  80044a:	7f ed                	jg     800439 <vprintfmt+0x1ae>
  80044c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80044f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800452:	85 c9                	test   %ecx,%ecx
  800454:	b8 00 00 00 00       	mov    $0x0,%eax
  800459:	0f 49 c1             	cmovns %ecx,%eax
  80045c:	29 c1                	sub    %eax,%ecx
  80045e:	89 75 08             	mov    %esi,0x8(%ebp)
  800461:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800464:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800467:	89 cb                	mov    %ecx,%ebx
  800469:	eb 16                	jmp    800481 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80046b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046f:	75 31                	jne    8004a2 <vprintfmt+0x217>
					putch(ch, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	ff 75 0c             	pushl  0xc(%ebp)
  800477:	50                   	push   %eax
  800478:	ff 55 08             	call   *0x8(%ebp)
  80047b:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80047e:	83 eb 01             	sub    $0x1,%ebx
  800481:	83 c7 01             	add    $0x1,%edi
  800484:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800488:	0f be c2             	movsbl %dl,%eax
  80048b:	85 c0                	test   %eax,%eax
  80048d:	74 59                	je     8004e8 <vprintfmt+0x25d>
  80048f:	85 f6                	test   %esi,%esi
  800491:	78 d8                	js     80046b <vprintfmt+0x1e0>
  800493:	83 ee 01             	sub    $0x1,%esi
  800496:	79 d3                	jns    80046b <vprintfmt+0x1e0>
  800498:	89 df                	mov    %ebx,%edi
  80049a:	8b 75 08             	mov    0x8(%ebp),%esi
  80049d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a0:	eb 37                	jmp    8004d9 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a2:	0f be d2             	movsbl %dl,%edx
  8004a5:	83 ea 20             	sub    $0x20,%edx
  8004a8:	83 fa 5e             	cmp    $0x5e,%edx
  8004ab:	76 c4                	jbe    800471 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 0c             	pushl  0xc(%ebp)
  8004b3:	6a 3f                	push   $0x3f
  8004b5:	ff 55 08             	call   *0x8(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	eb c1                	jmp    80047e <vprintfmt+0x1f3>
  8004bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c9:	eb b6                	jmp    800481 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	53                   	push   %ebx
  8004cf:	6a 20                	push   $0x20
  8004d1:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004d3:	83 ef 01             	sub    $0x1,%edi
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	85 ff                	test   %edi,%edi
  8004db:	7f ee                	jg     8004cb <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004dd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e3:	e9 78 01 00 00       	jmp    800660 <vprintfmt+0x3d5>
  8004e8:	89 df                	mov    %ebx,%edi
  8004ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f0:	eb e7                	jmp    8004d9 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004f2:	83 f9 01             	cmp    $0x1,%ecx
  8004f5:	7e 3f                	jle    800536 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8b 50 04             	mov    0x4(%eax),%edx
  8004fd:	8b 00                	mov    (%eax),%eax
  8004ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800502:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8d 40 08             	lea    0x8(%eax),%eax
  80050b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80050e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800512:	79 5c                	jns    800570 <vprintfmt+0x2e5>
				putch('-', putdat);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	53                   	push   %ebx
  800518:	6a 2d                	push   $0x2d
  80051a:	ff d6                	call   *%esi
				num = -(long long) num;
  80051c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80051f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800522:	f7 da                	neg    %edx
  800524:	83 d1 00             	adc    $0x0,%ecx
  800527:	f7 d9                	neg    %ecx
  800529:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80052c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800531:	e9 10 01 00 00       	jmp    800646 <vprintfmt+0x3bb>
	else if (lflag)
  800536:	85 c9                	test   %ecx,%ecx
  800538:	75 1b                	jne    800555 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8b 00                	mov    (%eax),%eax
  80053f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800542:	89 c1                	mov    %eax,%ecx
  800544:	c1 f9 1f             	sar    $0x1f,%ecx
  800547:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 40 04             	lea    0x4(%eax),%eax
  800550:	89 45 14             	mov    %eax,0x14(%ebp)
  800553:	eb b9                	jmp    80050e <vprintfmt+0x283>
		return va_arg(*ap, long);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8b 00                	mov    (%eax),%eax
  80055a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055d:	89 c1                	mov    %eax,%ecx
  80055f:	c1 f9 1f             	sar    $0x1f,%ecx
  800562:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 40 04             	lea    0x4(%eax),%eax
  80056b:	89 45 14             	mov    %eax,0x14(%ebp)
  80056e:	eb 9e                	jmp    80050e <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800570:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800573:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800576:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057b:	e9 c6 00 00 00       	jmp    800646 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800580:	83 f9 01             	cmp    $0x1,%ecx
  800583:	7e 18                	jle    80059d <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8b 10                	mov    (%eax),%edx
  80058a:	8b 48 04             	mov    0x4(%eax),%ecx
  80058d:	8d 40 08             	lea    0x8(%eax),%eax
  800590:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800593:	b8 0a 00 00 00       	mov    $0xa,%eax
  800598:	e9 a9 00 00 00       	jmp    800646 <vprintfmt+0x3bb>
	else if (lflag)
  80059d:	85 c9                	test   %ecx,%ecx
  80059f:	75 1a                	jne    8005bb <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8b 10                	mov    (%eax),%edx
  8005a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ab:	8d 40 04             	lea    0x4(%eax),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b6:	e9 8b 00 00 00       	jmp    800646 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8b 10                	mov    (%eax),%edx
  8005c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c5:	8d 40 04             	lea    0x4(%eax),%eax
  8005c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d0:	eb 74                	jmp    800646 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005d2:	83 f9 01             	cmp    $0x1,%ecx
  8005d5:	7e 15                	jle    8005ec <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	8b 48 04             	mov    0x4(%eax),%ecx
  8005df:	8d 40 08             	lea    0x8(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8005e5:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ea:	eb 5a                	jmp    800646 <vprintfmt+0x3bb>
	else if (lflag)
  8005ec:	85 c9                	test   %ecx,%ecx
  8005ee:	75 17                	jne    800607 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8b 10                	mov    (%eax),%edx
  8005f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fa:	8d 40 04             	lea    0x4(%eax),%eax
  8005fd:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800600:	b8 08 00 00 00       	mov    $0x8,%eax
  800605:	eb 3f                	jmp    800646 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8b 10                	mov    (%eax),%edx
  80060c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800611:	8d 40 04             	lea    0x4(%eax),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800617:	b8 08 00 00 00       	mov    $0x8,%eax
  80061c:	eb 28                	jmp    800646 <vprintfmt+0x3bb>
			putch('0', putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	6a 30                	push   $0x30
  800624:	ff d6                	call   *%esi
			putch('x', putdat);
  800626:	83 c4 08             	add    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 78                	push   $0x78
  80062c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 10                	mov    (%eax),%edx
  800633:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800638:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80063b:	8d 40 04             	lea    0x4(%eax),%eax
  80063e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800641:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800646:	83 ec 0c             	sub    $0xc,%esp
  800649:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80064d:	57                   	push   %edi
  80064e:	ff 75 e0             	pushl  -0x20(%ebp)
  800651:	50                   	push   %eax
  800652:	51                   	push   %ecx
  800653:	52                   	push   %edx
  800654:	89 da                	mov    %ebx,%edx
  800656:	89 f0                	mov    %esi,%eax
  800658:	e8 45 fb ff ff       	call   8001a2 <printnum>
			break;
  80065d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800660:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800663:	83 c7 01             	add    $0x1,%edi
  800666:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066a:	83 f8 25             	cmp    $0x25,%eax
  80066d:	0f 84 2f fc ff ff    	je     8002a2 <vprintfmt+0x17>
			if (ch == '\0')
  800673:	85 c0                	test   %eax,%eax
  800675:	0f 84 8b 00 00 00    	je     800706 <vprintfmt+0x47b>
			putch(ch, putdat);
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	53                   	push   %ebx
  80067f:	50                   	push   %eax
  800680:	ff d6                	call   *%esi
  800682:	83 c4 10             	add    $0x10,%esp
  800685:	eb dc                	jmp    800663 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800687:	83 f9 01             	cmp    $0x1,%ecx
  80068a:	7e 15                	jle    8006a1 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	8b 48 04             	mov    0x4(%eax),%ecx
  800694:	8d 40 08             	lea    0x8(%eax),%eax
  800697:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069a:	b8 10 00 00 00       	mov    $0x10,%eax
  80069f:	eb a5                	jmp    800646 <vprintfmt+0x3bb>
	else if (lflag)
  8006a1:	85 c9                	test   %ecx,%ecx
  8006a3:	75 17                	jne    8006bc <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 10                	mov    (%eax),%edx
  8006aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006af:	8d 40 04             	lea    0x4(%eax),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b5:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ba:	eb 8a                	jmp    800646 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8b 10                	mov    (%eax),%edx
  8006c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c6:	8d 40 04             	lea    0x4(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cc:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d1:	e9 70 ff ff ff       	jmp    800646 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	6a 25                	push   $0x25
  8006dc:	ff d6                	call   *%esi
			break;
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	e9 7a ff ff ff       	jmp    800660 <vprintfmt+0x3d5>
			putch('%', putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	53                   	push   %ebx
  8006ea:	6a 25                	push   $0x25
  8006ec:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	89 f8                	mov    %edi,%eax
  8006f3:	eb 03                	jmp    8006f8 <vprintfmt+0x46d>
  8006f5:	83 e8 01             	sub    $0x1,%eax
  8006f8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006fc:	75 f7                	jne    8006f5 <vprintfmt+0x46a>
  8006fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800701:	e9 5a ff ff ff       	jmp    800660 <vprintfmt+0x3d5>
}
  800706:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800709:	5b                   	pop    %ebx
  80070a:	5e                   	pop    %esi
  80070b:	5f                   	pop    %edi
  80070c:	5d                   	pop    %ebp
  80070d:	c3                   	ret    

0080070e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	83 ec 18             	sub    $0x18,%esp
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800721:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800724:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072b:	85 c0                	test   %eax,%eax
  80072d:	74 26                	je     800755 <vsnprintf+0x47>
  80072f:	85 d2                	test   %edx,%edx
  800731:	7e 22                	jle    800755 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800733:	ff 75 14             	pushl  0x14(%ebp)
  800736:	ff 75 10             	pushl  0x10(%ebp)
  800739:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073c:	50                   	push   %eax
  80073d:	68 51 02 80 00       	push   $0x800251
  800742:	e8 44 fb ff ff       	call   80028b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800747:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800750:	83 c4 10             	add    $0x10,%esp
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    
		return -E_INVAL;
  800755:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075a:	eb f7                	jmp    800753 <vsnprintf+0x45>

0080075c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800765:	50                   	push   %eax
  800766:	ff 75 10             	pushl  0x10(%ebp)
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	ff 75 08             	pushl  0x8(%ebp)
  80076f:	e8 9a ff ff ff       	call   80070e <vsnprintf>
	va_end(ap);

	return rc;
}
  800774:	c9                   	leave  
  800775:	c3                   	ret    

00800776 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077c:	b8 00 00 00 00       	mov    $0x0,%eax
  800781:	eb 03                	jmp    800786 <strlen+0x10>
		n++;
  800783:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800786:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078a:	75 f7                	jne    800783 <strlen+0xd>
	return n;
}
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800794:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800797:	b8 00 00 00 00       	mov    $0x0,%eax
  80079c:	eb 03                	jmp    8007a1 <strnlen+0x13>
		n++;
  80079e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a1:	39 d0                	cmp    %edx,%eax
  8007a3:	74 06                	je     8007ab <strnlen+0x1d>
  8007a5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a9:	75 f3                	jne    80079e <strnlen+0x10>
	return n;
}
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	53                   	push   %ebx
  8007b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b7:	89 c2                	mov    %eax,%edx
  8007b9:	83 c1 01             	add    $0x1,%ecx
  8007bc:	83 c2 01             	add    $0x1,%edx
  8007bf:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c6:	84 db                	test   %bl,%bl
  8007c8:	75 ef                	jne    8007b9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ca:	5b                   	pop    %ebx
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	53                   	push   %ebx
  8007d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d4:	53                   	push   %ebx
  8007d5:	e8 9c ff ff ff       	call   800776 <strlen>
  8007da:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007dd:	ff 75 0c             	pushl  0xc(%ebp)
  8007e0:	01 d8                	add    %ebx,%eax
  8007e2:	50                   	push   %eax
  8007e3:	e8 c5 ff ff ff       	call   8007ad <strcpy>
	return dst;
}
  8007e8:	89 d8                	mov    %ebx,%eax
  8007ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    

008007ef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	56                   	push   %esi
  8007f3:	53                   	push   %ebx
  8007f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fa:	89 f3                	mov    %esi,%ebx
  8007fc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ff:	89 f2                	mov    %esi,%edx
  800801:	eb 0f                	jmp    800812 <strncpy+0x23>
		*dst++ = *src;
  800803:	83 c2 01             	add    $0x1,%edx
  800806:	0f b6 01             	movzbl (%ecx),%eax
  800809:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080c:	80 39 01             	cmpb   $0x1,(%ecx)
  80080f:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800812:	39 da                	cmp    %ebx,%edx
  800814:	75 ed                	jne    800803 <strncpy+0x14>
	}
	return ret;
}
  800816:	89 f0                	mov    %esi,%eax
  800818:	5b                   	pop    %ebx
  800819:	5e                   	pop    %esi
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	56                   	push   %esi
  800820:	53                   	push   %ebx
  800821:	8b 75 08             	mov    0x8(%ebp),%esi
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
  800827:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80082a:	89 f0                	mov    %esi,%eax
  80082c:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800830:	85 c9                	test   %ecx,%ecx
  800832:	75 0b                	jne    80083f <strlcpy+0x23>
  800834:	eb 17                	jmp    80084d <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	83 c0 01             	add    $0x1,%eax
  80083c:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80083f:	39 d8                	cmp    %ebx,%eax
  800841:	74 07                	je     80084a <strlcpy+0x2e>
  800843:	0f b6 0a             	movzbl (%edx),%ecx
  800846:	84 c9                	test   %cl,%cl
  800848:	75 ec                	jne    800836 <strlcpy+0x1a>
		*dst = '\0';
  80084a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084d:	29 f0                	sub    %esi,%eax
}
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085c:	eb 06                	jmp    800864 <strcmp+0x11>
		p++, q++;
  80085e:	83 c1 01             	add    $0x1,%ecx
  800861:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800864:	0f b6 01             	movzbl (%ecx),%eax
  800867:	84 c0                	test   %al,%al
  800869:	74 04                	je     80086f <strcmp+0x1c>
  80086b:	3a 02                	cmp    (%edx),%al
  80086d:	74 ef                	je     80085e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086f:	0f b6 c0             	movzbl %al,%eax
  800872:	0f b6 12             	movzbl (%edx),%edx
  800875:	29 d0                	sub    %edx,%eax
}
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
  800883:	89 c3                	mov    %eax,%ebx
  800885:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800888:	eb 06                	jmp    800890 <strncmp+0x17>
		n--, p++, q++;
  80088a:	83 c0 01             	add    $0x1,%eax
  80088d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800890:	39 d8                	cmp    %ebx,%eax
  800892:	74 16                	je     8008aa <strncmp+0x31>
  800894:	0f b6 08             	movzbl (%eax),%ecx
  800897:	84 c9                	test   %cl,%cl
  800899:	74 04                	je     80089f <strncmp+0x26>
  80089b:	3a 0a                	cmp    (%edx),%cl
  80089d:	74 eb                	je     80088a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089f:	0f b6 00             	movzbl (%eax),%eax
  8008a2:	0f b6 12             	movzbl (%edx),%edx
  8008a5:	29 d0                	sub    %edx,%eax
}
  8008a7:	5b                   	pop    %ebx
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    
		return 0;
  8008aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008af:	eb f6                	jmp    8008a7 <strncmp+0x2e>

008008b1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bb:	0f b6 10             	movzbl (%eax),%edx
  8008be:	84 d2                	test   %dl,%dl
  8008c0:	74 09                	je     8008cb <strchr+0x1a>
		if (*s == c)
  8008c2:	38 ca                	cmp    %cl,%dl
  8008c4:	74 0a                	je     8008d0 <strchr+0x1f>
	for (; *s; s++)
  8008c6:	83 c0 01             	add    $0x1,%eax
  8008c9:	eb f0                	jmp    8008bb <strchr+0xa>
			return (char *) s;
	return 0;
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008dc:	eb 03                	jmp    8008e1 <strfind+0xf>
  8008de:	83 c0 01             	add    $0x1,%eax
  8008e1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e4:	38 ca                	cmp    %cl,%dl
  8008e6:	74 04                	je     8008ec <strfind+0x1a>
  8008e8:	84 d2                	test   %dl,%dl
  8008ea:	75 f2                	jne    8008de <strfind+0xc>
			break;
	return (char *) s;
}
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	57                   	push   %edi
  8008f2:	56                   	push   %esi
  8008f3:	53                   	push   %ebx
  8008f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fa:	85 c9                	test   %ecx,%ecx
  8008fc:	74 13                	je     800911 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800904:	75 05                	jne    80090b <memset+0x1d>
  800906:	f6 c1 03             	test   $0x3,%cl
  800909:	74 0d                	je     800918 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090e:	fc                   	cld    
  80090f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800911:	89 f8                	mov    %edi,%eax
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	5f                   	pop    %edi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    
		c &= 0xFF;
  800918:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091c:	89 d3                	mov    %edx,%ebx
  80091e:	c1 e3 08             	shl    $0x8,%ebx
  800921:	89 d0                	mov    %edx,%eax
  800923:	c1 e0 18             	shl    $0x18,%eax
  800926:	89 d6                	mov    %edx,%esi
  800928:	c1 e6 10             	shl    $0x10,%esi
  80092b:	09 f0                	or     %esi,%eax
  80092d:	09 c2                	or     %eax,%edx
  80092f:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800931:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800934:	89 d0                	mov    %edx,%eax
  800936:	fc                   	cld    
  800937:	f3 ab                	rep stos %eax,%es:(%edi)
  800939:	eb d6                	jmp    800911 <memset+0x23>

0080093b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	57                   	push   %edi
  80093f:	56                   	push   %esi
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 75 0c             	mov    0xc(%ebp),%esi
  800946:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800949:	39 c6                	cmp    %eax,%esi
  80094b:	73 35                	jae    800982 <memmove+0x47>
  80094d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800950:	39 c2                	cmp    %eax,%edx
  800952:	76 2e                	jbe    800982 <memmove+0x47>
		s += n;
		d += n;
  800954:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800957:	89 d6                	mov    %edx,%esi
  800959:	09 fe                	or     %edi,%esi
  80095b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800961:	74 0c                	je     80096f <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800963:	83 ef 01             	sub    $0x1,%edi
  800966:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800969:	fd                   	std    
  80096a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096c:	fc                   	cld    
  80096d:	eb 21                	jmp    800990 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096f:	f6 c1 03             	test   $0x3,%cl
  800972:	75 ef                	jne    800963 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800974:	83 ef 04             	sub    $0x4,%edi
  800977:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80097d:	fd                   	std    
  80097e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800980:	eb ea                	jmp    80096c <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800982:	89 f2                	mov    %esi,%edx
  800984:	09 c2                	or     %eax,%edx
  800986:	f6 c2 03             	test   $0x3,%dl
  800989:	74 09                	je     800994 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098b:	89 c7                	mov    %eax,%edi
  80098d:	fc                   	cld    
  80098e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800990:	5e                   	pop    %esi
  800991:	5f                   	pop    %edi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800994:	f6 c1 03             	test   $0x3,%cl
  800997:	75 f2                	jne    80098b <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800999:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80099c:	89 c7                	mov    %eax,%edi
  80099e:	fc                   	cld    
  80099f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a1:	eb ed                	jmp    800990 <memmove+0x55>

008009a3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a6:	ff 75 10             	pushl  0x10(%ebp)
  8009a9:	ff 75 0c             	pushl  0xc(%ebp)
  8009ac:	ff 75 08             	pushl  0x8(%ebp)
  8009af:	e8 87 ff ff ff       	call   80093b <memmove>
}
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    

008009b6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c1:	89 c6                	mov    %eax,%esi
  8009c3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c6:	39 f0                	cmp    %esi,%eax
  8009c8:	74 1c                	je     8009e6 <memcmp+0x30>
		if (*s1 != *s2)
  8009ca:	0f b6 08             	movzbl (%eax),%ecx
  8009cd:	0f b6 1a             	movzbl (%edx),%ebx
  8009d0:	38 d9                	cmp    %bl,%cl
  8009d2:	75 08                	jne    8009dc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009d4:	83 c0 01             	add    $0x1,%eax
  8009d7:	83 c2 01             	add    $0x1,%edx
  8009da:	eb ea                	jmp    8009c6 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009dc:	0f b6 c1             	movzbl %cl,%eax
  8009df:	0f b6 db             	movzbl %bl,%ebx
  8009e2:	29 d8                	sub    %ebx,%eax
  8009e4:	eb 05                	jmp    8009eb <memcmp+0x35>
	}

	return 0;
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f8:	89 c2                	mov    %eax,%edx
  8009fa:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009fd:	39 d0                	cmp    %edx,%eax
  8009ff:	73 09                	jae    800a0a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a01:	38 08                	cmp    %cl,(%eax)
  800a03:	74 05                	je     800a0a <memfind+0x1b>
	for (; s < ends; s++)
  800a05:	83 c0 01             	add    $0x1,%eax
  800a08:	eb f3                	jmp    8009fd <memfind+0xe>
			break;
	return (void *) s;
}
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a18:	eb 03                	jmp    800a1d <strtol+0x11>
		s++;
  800a1a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a1d:	0f b6 01             	movzbl (%ecx),%eax
  800a20:	3c 20                	cmp    $0x20,%al
  800a22:	74 f6                	je     800a1a <strtol+0xe>
  800a24:	3c 09                	cmp    $0x9,%al
  800a26:	74 f2                	je     800a1a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a28:	3c 2b                	cmp    $0x2b,%al
  800a2a:	74 2e                	je     800a5a <strtol+0x4e>
	int neg = 0;
  800a2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a31:	3c 2d                	cmp    $0x2d,%al
  800a33:	74 2f                	je     800a64 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a35:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3b:	75 05                	jne    800a42 <strtol+0x36>
  800a3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a40:	74 2c                	je     800a6e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a42:	85 db                	test   %ebx,%ebx
  800a44:	75 0a                	jne    800a50 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a46:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a4b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4e:	74 28                	je     800a78 <strtol+0x6c>
		base = 10;
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
  800a55:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a58:	eb 50                	jmp    800aaa <strtol+0x9e>
		s++;
  800a5a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a5d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a62:	eb d1                	jmp    800a35 <strtol+0x29>
		s++, neg = 1;
  800a64:	83 c1 01             	add    $0x1,%ecx
  800a67:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6c:	eb c7                	jmp    800a35 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a72:	74 0e                	je     800a82 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a74:	85 db                	test   %ebx,%ebx
  800a76:	75 d8                	jne    800a50 <strtol+0x44>
		s++, base = 8;
  800a78:	83 c1 01             	add    $0x1,%ecx
  800a7b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a80:	eb ce                	jmp    800a50 <strtol+0x44>
		s += 2, base = 16;
  800a82:	83 c1 02             	add    $0x2,%ecx
  800a85:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8a:	eb c4                	jmp    800a50 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a8c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8f:	89 f3                	mov    %esi,%ebx
  800a91:	80 fb 19             	cmp    $0x19,%bl
  800a94:	77 29                	ja     800abf <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a96:	0f be d2             	movsbl %dl,%edx
  800a99:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a9c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a9f:	7d 30                	jge    800ad1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aa1:	83 c1 01             	add    $0x1,%ecx
  800aa4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aaa:	0f b6 11             	movzbl (%ecx),%edx
  800aad:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab0:	89 f3                	mov    %esi,%ebx
  800ab2:	80 fb 09             	cmp    $0x9,%bl
  800ab5:	77 d5                	ja     800a8c <strtol+0x80>
			dig = *s - '0';
  800ab7:	0f be d2             	movsbl %dl,%edx
  800aba:	83 ea 30             	sub    $0x30,%edx
  800abd:	eb dd                	jmp    800a9c <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800abf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac2:	89 f3                	mov    %esi,%ebx
  800ac4:	80 fb 19             	cmp    $0x19,%bl
  800ac7:	77 08                	ja     800ad1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ac9:	0f be d2             	movsbl %dl,%edx
  800acc:	83 ea 37             	sub    $0x37,%edx
  800acf:	eb cb                	jmp    800a9c <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad5:	74 05                	je     800adc <strtol+0xd0>
		*endptr = (char *) s;
  800ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ada:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800adc:	89 c2                	mov    %eax,%edx
  800ade:	f7 da                	neg    %edx
  800ae0:	85 ff                	test   %edi,%edi
  800ae2:	0f 45 c2             	cmovne %edx,%eax
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af0:	b8 00 00 00 00       	mov    $0x0,%eax
  800af5:	8b 55 08             	mov    0x8(%ebp),%edx
  800af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afb:	89 c3                	mov    %eax,%ebx
  800afd:	89 c7                	mov    %eax,%edi
  800aff:	89 c6                	mov    %eax,%esi
  800b01:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5f                   	pop    %edi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b13:	b8 01 00 00 00       	mov    $0x1,%eax
  800b18:	89 d1                	mov    %edx,%ecx
  800b1a:	89 d3                	mov    %edx,%ebx
  800b1c:	89 d7                	mov    %edx,%edi
  800b1e:	89 d6                	mov    %edx,%esi
  800b20:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b35:	8b 55 08             	mov    0x8(%ebp),%edx
  800b38:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3d:	89 cb                	mov    %ecx,%ebx
  800b3f:	89 cf                	mov    %ecx,%edi
  800b41:	89 ce                	mov    %ecx,%esi
  800b43:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b45:	85 c0                	test   %eax,%eax
  800b47:	7f 08                	jg     800b51 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	50                   	push   %eax
  800b55:	6a 03                	push   $0x3
  800b57:	68 e4 12 80 00       	push   $0x8012e4
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 01 13 80 00       	push   $0x801301
  800b63:	e8 54 02 00 00       	call   800dbc <_panic>

00800b68 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b73:	b8 02 00 00 00       	mov    $0x2,%eax
  800b78:	89 d1                	mov    %edx,%ecx
  800b7a:	89 d3                	mov    %edx,%ebx
  800b7c:	89 d7                	mov    %edx,%edi
  800b7e:	89 d6                	mov    %edx,%esi
  800b80:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <sys_yield>:

void
sys_yield(void)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b97:	89 d1                	mov    %edx,%ecx
  800b99:	89 d3                	mov    %edx,%ebx
  800b9b:	89 d7                	mov    %edx,%edi
  800b9d:	89 d6                	mov    %edx,%esi
  800b9f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800baf:	be 00 00 00 00       	mov    $0x0,%esi
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	b8 04 00 00 00       	mov    $0x4,%eax
  800bbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc2:	89 f7                	mov    %esi,%edi
  800bc4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	7f 08                	jg     800bd2 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 04                	push   $0x4
  800bd8:	68 e4 12 80 00       	push   $0x8012e4
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 01 13 80 00       	push   $0x801301
  800be4:	e8 d3 01 00 00       	call   800dbc <_panic>

00800be9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c03:	8b 75 18             	mov    0x18(%ebp),%esi
  800c06:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7f 08                	jg     800c14 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 05                	push   $0x5
  800c1a:	68 e4 12 80 00       	push   $0x8012e4
  800c1f:	6a 23                	push   $0x23
  800c21:	68 01 13 80 00       	push   $0x801301
  800c26:	e8 91 01 00 00       	call   800dbc <_panic>

00800c2b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c44:	89 df                	mov    %ebx,%edi
  800c46:	89 de                	mov    %ebx,%esi
  800c48:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7f 08                	jg     800c56 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 06                	push   $0x6
  800c5c:	68 e4 12 80 00       	push   $0x8012e4
  800c61:	6a 23                	push   $0x23
  800c63:	68 01 13 80 00       	push   $0x801301
  800c68:	e8 4f 01 00 00       	call   800dbc <_panic>

00800c6d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	b8 08 00 00 00       	mov    $0x8,%eax
  800c86:	89 df                	mov    %ebx,%edi
  800c88:	89 de                	mov    %ebx,%esi
  800c8a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7f 08                	jg     800c98 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 08                	push   $0x8
  800c9e:	68 e4 12 80 00       	push   $0x8012e4
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 01 13 80 00       	push   $0x801301
  800caa:	e8 0d 01 00 00       	call   800dbc <_panic>

00800caf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc8:	89 df                	mov    %ebx,%edi
  800cca:	89 de                	mov    %ebx,%esi
  800ccc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7f 08                	jg     800cda <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 09                	push   $0x9
  800ce0:	68 e4 12 80 00       	push   $0x8012e4
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 01 13 80 00       	push   $0x801301
  800cec:	e8 cb 00 00 00       	call   800dbc <_panic>

00800cf1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d02:	be 00 00 00 00       	mov    $0x0,%esi
  800d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2a:	89 cb                	mov    %ecx,%ebx
  800d2c:	89 cf                	mov    %ecx,%edi
  800d2e:	89 ce                	mov    %ecx,%esi
  800d30:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7f 08                	jg     800d3e <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	50                   	push   %eax
  800d42:	6a 0c                	push   $0xc
  800d44:	68 e4 12 80 00       	push   $0x8012e4
  800d49:	6a 23                	push   $0x23
  800d4b:	68 01 13 80 00       	push   $0x801301
  800d50:	e8 67 00 00 00       	call   800dbc <_panic>

00800d55 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800d5b:	68 0f 13 80 00       	push   $0x80130f
  800d60:	6a 1a                	push   $0x1a
  800d62:	68 28 13 80 00       	push   $0x801328
  800d67:	e8 50 00 00 00       	call   800dbc <_panic>

00800d6c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800d72:	68 32 13 80 00       	push   $0x801332
  800d77:	6a 2a                	push   $0x2a
  800d79:	68 28 13 80 00       	push   $0x801328
  800d7e:	e8 39 00 00 00       	call   800dbc <_panic>

00800d83 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800d89:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800d8e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800d91:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800d97:	8b 52 50             	mov    0x50(%edx),%edx
  800d9a:	39 ca                	cmp    %ecx,%edx
  800d9c:	74 11                	je     800daf <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  800d9e:	83 c0 01             	add    $0x1,%eax
  800da1:	3d 00 04 00 00       	cmp    $0x400,%eax
  800da6:	75 e6                	jne    800d8e <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800da8:	b8 00 00 00 00       	mov    $0x0,%eax
  800dad:	eb 0b                	jmp    800dba <ipc_find_env+0x37>
			return envs[i].env_id;
  800daf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800db2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800db7:	8b 40 48             	mov    0x48(%eax),%eax
}
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dc1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dc4:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dca:	e8 99 fd ff ff       	call   800b68 <sys_getenvid>
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	ff 75 0c             	pushl  0xc(%ebp)
  800dd5:	ff 75 08             	pushl  0x8(%ebp)
  800dd8:	56                   	push   %esi
  800dd9:	50                   	push   %eax
  800dda:	68 4c 13 80 00       	push   $0x80134c
  800ddf:	e8 aa f3 ff ff       	call   80018e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800de4:	83 c4 18             	add    $0x18,%esp
  800de7:	53                   	push   %ebx
  800de8:	ff 75 10             	pushl  0x10(%ebp)
  800deb:	e8 4d f3 ff ff       	call   80013d <vcprintf>
	cprintf("\n");
  800df0:	c7 04 24 6f 10 80 00 	movl   $0x80106f,(%esp)
  800df7:	e8 92 f3 ff ff       	call   80018e <cprintf>
  800dfc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dff:	cc                   	int3   
  800e00:	eb fd                	jmp    800dff <_panic+0x43>
  800e02:	66 90                	xchg   %ax,%ax
  800e04:	66 90                	xchg   %ax,%ax
  800e06:	66 90                	xchg   %ax,%ax
  800e08:	66 90                	xchg   %ax,%ax
  800e0a:	66 90                	xchg   %ax,%ax
  800e0c:	66 90                	xchg   %ax,%ax
  800e0e:	66 90                	xchg   %ax,%ax

00800e10 <__udivdi3>:
  800e10:	55                   	push   %ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 1c             	sub    $0x1c,%esp
  800e17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e1b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e23:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e27:	85 d2                	test   %edx,%edx
  800e29:	75 35                	jne    800e60 <__udivdi3+0x50>
  800e2b:	39 f3                	cmp    %esi,%ebx
  800e2d:	0f 87 bd 00 00 00    	ja     800ef0 <__udivdi3+0xe0>
  800e33:	85 db                	test   %ebx,%ebx
  800e35:	89 d9                	mov    %ebx,%ecx
  800e37:	75 0b                	jne    800e44 <__udivdi3+0x34>
  800e39:	b8 01 00 00 00       	mov    $0x1,%eax
  800e3e:	31 d2                	xor    %edx,%edx
  800e40:	f7 f3                	div    %ebx
  800e42:	89 c1                	mov    %eax,%ecx
  800e44:	31 d2                	xor    %edx,%edx
  800e46:	89 f0                	mov    %esi,%eax
  800e48:	f7 f1                	div    %ecx
  800e4a:	89 c6                	mov    %eax,%esi
  800e4c:	89 e8                	mov    %ebp,%eax
  800e4e:	89 f7                	mov    %esi,%edi
  800e50:	f7 f1                	div    %ecx
  800e52:	89 fa                	mov    %edi,%edx
  800e54:	83 c4 1c             	add    $0x1c,%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    
  800e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e60:	39 f2                	cmp    %esi,%edx
  800e62:	77 7c                	ja     800ee0 <__udivdi3+0xd0>
  800e64:	0f bd fa             	bsr    %edx,%edi
  800e67:	83 f7 1f             	xor    $0x1f,%edi
  800e6a:	0f 84 98 00 00 00    	je     800f08 <__udivdi3+0xf8>
  800e70:	89 f9                	mov    %edi,%ecx
  800e72:	b8 20 00 00 00       	mov    $0x20,%eax
  800e77:	29 f8                	sub    %edi,%eax
  800e79:	d3 e2                	shl    %cl,%edx
  800e7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	89 da                	mov    %ebx,%edx
  800e83:	d3 ea                	shr    %cl,%edx
  800e85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e89:	09 d1                	or     %edx,%ecx
  800e8b:	89 f2                	mov    %esi,%edx
  800e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e91:	89 f9                	mov    %edi,%ecx
  800e93:	d3 e3                	shl    %cl,%ebx
  800e95:	89 c1                	mov    %eax,%ecx
  800e97:	d3 ea                	shr    %cl,%edx
  800e99:	89 f9                	mov    %edi,%ecx
  800e9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e9f:	d3 e6                	shl    %cl,%esi
  800ea1:	89 eb                	mov    %ebp,%ebx
  800ea3:	89 c1                	mov    %eax,%ecx
  800ea5:	d3 eb                	shr    %cl,%ebx
  800ea7:	09 de                	or     %ebx,%esi
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	f7 74 24 08          	divl   0x8(%esp)
  800eaf:	89 d6                	mov    %edx,%esi
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	f7 64 24 0c          	mull   0xc(%esp)
  800eb7:	39 d6                	cmp    %edx,%esi
  800eb9:	72 0c                	jb     800ec7 <__udivdi3+0xb7>
  800ebb:	89 f9                	mov    %edi,%ecx
  800ebd:	d3 e5                	shl    %cl,%ebp
  800ebf:	39 c5                	cmp    %eax,%ebp
  800ec1:	73 5d                	jae    800f20 <__udivdi3+0x110>
  800ec3:	39 d6                	cmp    %edx,%esi
  800ec5:	75 59                	jne    800f20 <__udivdi3+0x110>
  800ec7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800eca:	31 ff                	xor    %edi,%edi
  800ecc:	89 fa                	mov    %edi,%edx
  800ece:	83 c4 1c             	add    $0x1c,%esp
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    
  800ed6:	8d 76 00             	lea    0x0(%esi),%esi
  800ed9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ee0:	31 ff                	xor    %edi,%edi
  800ee2:	31 c0                	xor    %eax,%eax
  800ee4:	89 fa                	mov    %edi,%edx
  800ee6:	83 c4 1c             	add    $0x1c,%esp
  800ee9:	5b                   	pop    %ebx
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    
  800eee:	66 90                	xchg   %ax,%ax
  800ef0:	31 ff                	xor    %edi,%edi
  800ef2:	89 e8                	mov    %ebp,%eax
  800ef4:	89 f2                	mov    %esi,%edx
  800ef6:	f7 f3                	div    %ebx
  800ef8:	89 fa                	mov    %edi,%edx
  800efa:	83 c4 1c             	add    $0x1c,%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    
  800f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f08:	39 f2                	cmp    %esi,%edx
  800f0a:	72 06                	jb     800f12 <__udivdi3+0x102>
  800f0c:	31 c0                	xor    %eax,%eax
  800f0e:	39 eb                	cmp    %ebp,%ebx
  800f10:	77 d2                	ja     800ee4 <__udivdi3+0xd4>
  800f12:	b8 01 00 00 00       	mov    $0x1,%eax
  800f17:	eb cb                	jmp    800ee4 <__udivdi3+0xd4>
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	89 d8                	mov    %ebx,%eax
  800f22:	31 ff                	xor    %edi,%edi
  800f24:	eb be                	jmp    800ee4 <__udivdi3+0xd4>
  800f26:	66 90                	xchg   %ax,%ax
  800f28:	66 90                	xchg   %ax,%ax
  800f2a:	66 90                	xchg   %ax,%ax
  800f2c:	66 90                	xchg   %ax,%ax
  800f2e:	66 90                	xchg   %ax,%ax

00800f30 <__umoddi3>:
  800f30:	55                   	push   %ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	83 ec 1c             	sub    $0x1c,%esp
  800f37:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f47:	85 ed                	test   %ebp,%ebp
  800f49:	89 f0                	mov    %esi,%eax
  800f4b:	89 da                	mov    %ebx,%edx
  800f4d:	75 19                	jne    800f68 <__umoddi3+0x38>
  800f4f:	39 df                	cmp    %ebx,%edi
  800f51:	0f 86 b1 00 00 00    	jbe    801008 <__umoddi3+0xd8>
  800f57:	f7 f7                	div    %edi
  800f59:	89 d0                	mov    %edx,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	83 c4 1c             	add    $0x1c,%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    
  800f65:	8d 76 00             	lea    0x0(%esi),%esi
  800f68:	39 dd                	cmp    %ebx,%ebp
  800f6a:	77 f1                	ja     800f5d <__umoddi3+0x2d>
  800f6c:	0f bd cd             	bsr    %ebp,%ecx
  800f6f:	83 f1 1f             	xor    $0x1f,%ecx
  800f72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f76:	0f 84 b4 00 00 00    	je     801030 <__umoddi3+0x100>
  800f7c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f81:	89 c2                	mov    %eax,%edx
  800f83:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f87:	29 c2                	sub    %eax,%edx
  800f89:	89 c1                	mov    %eax,%ecx
  800f8b:	89 f8                	mov    %edi,%eax
  800f8d:	d3 e5                	shl    %cl,%ebp
  800f8f:	89 d1                	mov    %edx,%ecx
  800f91:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f95:	d3 e8                	shr    %cl,%eax
  800f97:	09 c5                	or     %eax,%ebp
  800f99:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f9d:	89 c1                	mov    %eax,%ecx
  800f9f:	d3 e7                	shl    %cl,%edi
  800fa1:	89 d1                	mov    %edx,%ecx
  800fa3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fa7:	89 df                	mov    %ebx,%edi
  800fa9:	d3 ef                	shr    %cl,%edi
  800fab:	89 c1                	mov    %eax,%ecx
  800fad:	89 f0                	mov    %esi,%eax
  800faf:	d3 e3                	shl    %cl,%ebx
  800fb1:	89 d1                	mov    %edx,%ecx
  800fb3:	89 fa                	mov    %edi,%edx
  800fb5:	d3 e8                	shr    %cl,%eax
  800fb7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fbc:	09 d8                	or     %ebx,%eax
  800fbe:	f7 f5                	div    %ebp
  800fc0:	d3 e6                	shl    %cl,%esi
  800fc2:	89 d1                	mov    %edx,%ecx
  800fc4:	f7 64 24 08          	mull   0x8(%esp)
  800fc8:	39 d1                	cmp    %edx,%ecx
  800fca:	89 c3                	mov    %eax,%ebx
  800fcc:	89 d7                	mov    %edx,%edi
  800fce:	72 06                	jb     800fd6 <__umoddi3+0xa6>
  800fd0:	75 0e                	jne    800fe0 <__umoddi3+0xb0>
  800fd2:	39 c6                	cmp    %eax,%esi
  800fd4:	73 0a                	jae    800fe0 <__umoddi3+0xb0>
  800fd6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800fda:	19 ea                	sbb    %ebp,%edx
  800fdc:	89 d7                	mov    %edx,%edi
  800fde:	89 c3                	mov    %eax,%ebx
  800fe0:	89 ca                	mov    %ecx,%edx
  800fe2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800fe7:	29 de                	sub    %ebx,%esi
  800fe9:	19 fa                	sbb    %edi,%edx
  800feb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800fef:	89 d0                	mov    %edx,%eax
  800ff1:	d3 e0                	shl    %cl,%eax
  800ff3:	89 d9                	mov    %ebx,%ecx
  800ff5:	d3 ee                	shr    %cl,%esi
  800ff7:	d3 ea                	shr    %cl,%edx
  800ff9:	09 f0                	or     %esi,%eax
  800ffb:	83 c4 1c             	add    $0x1c,%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    
  801003:	90                   	nop
  801004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801008:	85 ff                	test   %edi,%edi
  80100a:	89 f9                	mov    %edi,%ecx
  80100c:	75 0b                	jne    801019 <__umoddi3+0xe9>
  80100e:	b8 01 00 00 00       	mov    $0x1,%eax
  801013:	31 d2                	xor    %edx,%edx
  801015:	f7 f7                	div    %edi
  801017:	89 c1                	mov    %eax,%ecx
  801019:	89 d8                	mov    %ebx,%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	f7 f1                	div    %ecx
  80101f:	89 f0                	mov    %esi,%eax
  801021:	f7 f1                	div    %ecx
  801023:	e9 31 ff ff ff       	jmp    800f59 <__umoddi3+0x29>
  801028:	90                   	nop
  801029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801030:	39 dd                	cmp    %ebx,%ebp
  801032:	72 08                	jb     80103c <__umoddi3+0x10c>
  801034:	39 f7                	cmp    %esi,%edi
  801036:	0f 87 21 ff ff ff    	ja     800f5d <__umoddi3+0x2d>
  80103c:	89 da                	mov    %ebx,%edx
  80103e:	89 f0                	mov    %esi,%eax
  801040:	29 f8                	sub    %edi,%eax
  801042:	19 ea                	sbb    %ebp,%edx
  801044:	e9 14 ff ff ff       	jmp    800f5d <__umoddi3+0x2d>
