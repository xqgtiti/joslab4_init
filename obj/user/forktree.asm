
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 b2 00 00 00       	call   8000e3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 68 0b 00 00       	call   800baa <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 60 10 80 00       	push   $0x801060
  80004c:	e8 7f 01 00 00       	call   8001d0 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 35 07 00 00       	call   8007b8 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7e 07                	jle    800092 <forkchild+0x23>
}
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800092:	83 ec 0c             	sub    $0xc,%esp
  800095:	89 f0                	mov    %esi,%eax
  800097:	0f be f0             	movsbl %al,%esi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	68 71 10 80 00       	push   $0x801071
  8000a1:	6a 04                	push   $0x4
  8000a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a6:	50                   	push   %eax
  8000a7:	e8 f2 06 00 00       	call   80079e <snprintf>
	if (fork() == 0) {
  8000ac:	83 c4 20             	add    $0x20,%esp
  8000af:	e8 e3 0c 00 00       	call   800d97 <fork>
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	75 d3                	jne    80008b <forkchild+0x1c>
		forktree(nxt);
  8000b8:	83 ec 0c             	sub    $0xc,%esp
  8000bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000be:	50                   	push   %eax
  8000bf:	e8 6f ff ff ff       	call   800033 <forktree>
		exit();
  8000c4:	e8 60 00 00 00       	call   800129 <exit>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb bd                	jmp    80008b <forkchild+0x1c>

008000ce <umain>:

void
umain(int argc, char **argv)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d4:	68 70 10 80 00       	push   $0x801070
  8000d9:	e8 55 ff ff ff       	call   800033 <forktree>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ee:	e8 b7 0a 00 00       	call   800baa <sys_getenvid>
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x2d>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800110:	83 ec 08             	sub    $0x8,%esp
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
  800115:	e8 b4 ff ff ff       	call   8000ce <umain>

	// exit gracefully
	exit();
  80011a:	e8 0a 00 00 00       	call   800129 <exit>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80012f:	6a 00                	push   $0x0
  800131:	e8 33 0a 00 00       	call   800b69 <sys_env_destroy>
}
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	53                   	push   %ebx
  80013f:	83 ec 04             	sub    $0x4,%esp
  800142:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800145:	8b 13                	mov    (%ebx),%edx
  800147:	8d 42 01             	lea    0x1(%edx),%eax
  80014a:	89 03                	mov    %eax,(%ebx)
  80014c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800153:	3d ff 00 00 00       	cmp    $0xff,%eax
  800158:	74 09                	je     800163 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800163:	83 ec 08             	sub    $0x8,%esp
  800166:	68 ff 00 00 00       	push   $0xff
  80016b:	8d 43 08             	lea    0x8(%ebx),%eax
  80016e:	50                   	push   %eax
  80016f:	e8 b8 09 00 00       	call   800b2c <sys_cputs>
		b->idx = 0;
  800174:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	eb db                	jmp    80015a <putch+0x1f>

0080017f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800188:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018f:	00 00 00 
	b.cnt = 0;
  800192:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800199:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80019c:	ff 75 0c             	pushl  0xc(%ebp)
  80019f:	ff 75 08             	pushl  0x8(%ebp)
  8001a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a8:	50                   	push   %eax
  8001a9:	68 3b 01 80 00       	push   $0x80013b
  8001ae:	e8 1a 01 00 00       	call   8002cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b3:	83 c4 08             	add    $0x8,%esp
  8001b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c2:	50                   	push   %eax
  8001c3:	e8 64 09 00 00       	call   800b2c <sys_cputs>

	return b.cnt;
}
  8001c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d9:	50                   	push   %eax
  8001da:	ff 75 08             	pushl  0x8(%ebp)
  8001dd:	e8 9d ff ff ff       	call   80017f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e2:	c9                   	leave  
  8001e3:	c3                   	ret    

008001e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 1c             	sub    $0x1c,%esp
  8001ed:	89 c7                	mov    %eax,%edi
  8001ef:	89 d6                	mov    %edx,%esi
  8001f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800200:	bb 00 00 00 00       	mov    $0x0,%ebx
  800205:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800208:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80020b:	39 d3                	cmp    %edx,%ebx
  80020d:	72 05                	jb     800214 <printnum+0x30>
  80020f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800212:	77 7a                	ja     80028e <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800214:	83 ec 0c             	sub    $0xc,%esp
  800217:	ff 75 18             	pushl  0x18(%ebp)
  80021a:	8b 45 14             	mov    0x14(%ebp),%eax
  80021d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800220:	53                   	push   %ebx
  800221:	ff 75 10             	pushl  0x10(%ebp)
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 d8 0b 00 00       	call   800e10 <__udivdi3>
  800238:	83 c4 18             	add    $0x18,%esp
  80023b:	52                   	push   %edx
  80023c:	50                   	push   %eax
  80023d:	89 f2                	mov    %esi,%edx
  80023f:	89 f8                	mov    %edi,%eax
  800241:	e8 9e ff ff ff       	call   8001e4 <printnum>
  800246:	83 c4 20             	add    $0x20,%esp
  800249:	eb 13                	jmp    80025e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	56                   	push   %esi
  80024f:	ff 75 18             	pushl  0x18(%ebp)
  800252:	ff d7                	call   *%edi
  800254:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800257:	83 eb 01             	sub    $0x1,%ebx
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7f ed                	jg     80024b <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025e:	83 ec 08             	sub    $0x8,%esp
  800261:	56                   	push   %esi
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	ff 75 e4             	pushl  -0x1c(%ebp)
  800268:	ff 75 e0             	pushl  -0x20(%ebp)
  80026b:	ff 75 dc             	pushl  -0x24(%ebp)
  80026e:	ff 75 d8             	pushl  -0x28(%ebp)
  800271:	e8 ba 0c 00 00       	call   800f30 <__umoddi3>
  800276:	83 c4 14             	add    $0x14,%esp
  800279:	0f be 80 80 10 80 00 	movsbl 0x801080(%eax),%eax
  800280:	50                   	push   %eax
  800281:	ff d7                	call   *%edi
}
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800289:	5b                   	pop    %ebx
  80028a:	5e                   	pop    %esi
  80028b:	5f                   	pop    %edi
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    
  80028e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800291:	eb c4                	jmp    800257 <printnum+0x73>

00800293 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800299:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a2:	73 0a                	jae    8002ae <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a7:	89 08                	mov    %ecx,(%eax)
  8002a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ac:	88 02                	mov    %al,(%edx)
}
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <printfmt>:
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002b6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b9:	50                   	push   %eax
  8002ba:	ff 75 10             	pushl  0x10(%ebp)
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	e8 05 00 00 00       	call   8002cd <vprintfmt>
}
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <vprintfmt>:
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
  8002d3:	83 ec 2c             	sub    $0x2c,%esp
  8002d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002dc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002df:	e9 c1 03 00 00       	jmp    8006a5 <vprintfmt+0x3d8>
		padc = ' ';
  8002e4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002e8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002ef:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002f6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002fd:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800302:	8d 47 01             	lea    0x1(%edi),%eax
  800305:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800308:	0f b6 17             	movzbl (%edi),%edx
  80030b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80030e:	3c 55                	cmp    $0x55,%al
  800310:	0f 87 12 04 00 00    	ja     800728 <vprintfmt+0x45b>
  800316:	0f b6 c0             	movzbl %al,%eax
  800319:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  800320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800323:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800327:	eb d9                	jmp    800302 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800329:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80032c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800330:	eb d0                	jmp    800302 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800332:	0f b6 d2             	movzbl %dl,%edx
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800338:	b8 00 00 00 00       	mov    $0x0,%eax
  80033d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800340:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800343:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800347:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80034a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034d:	83 f9 09             	cmp    $0x9,%ecx
  800350:	77 55                	ja     8003a7 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800352:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800355:	eb e9                	jmp    800340 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800357:	8b 45 14             	mov    0x14(%ebp),%eax
  80035a:	8b 00                	mov    (%eax),%eax
  80035c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80035f:	8b 45 14             	mov    0x14(%ebp),%eax
  800362:	8d 40 04             	lea    0x4(%eax),%eax
  800365:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80036b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036f:	79 91                	jns    800302 <vprintfmt+0x35>
				width = precision, precision = -1;
  800371:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800374:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800377:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037e:	eb 82                	jmp    800302 <vprintfmt+0x35>
  800380:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800383:	85 c0                	test   %eax,%eax
  800385:	ba 00 00 00 00       	mov    $0x0,%edx
  80038a:	0f 49 d0             	cmovns %eax,%edx
  80038d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800393:	e9 6a ff ff ff       	jmp    800302 <vprintfmt+0x35>
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80039b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a2:	e9 5b ff ff ff       	jmp    800302 <vprintfmt+0x35>
  8003a7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003ad:	eb bc                	jmp    80036b <vprintfmt+0x9e>
			lflag++;
  8003af:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b5:	e9 48 ff ff ff       	jmp    800302 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 78 04             	lea    0x4(%eax),%edi
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	53                   	push   %ebx
  8003c4:	ff 30                	pushl  (%eax)
  8003c6:	ff d6                	call   *%esi
			break;
  8003c8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003cb:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ce:	e9 cf 02 00 00       	jmp    8006a2 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8d 78 04             	lea    0x4(%eax),%edi
  8003d9:	8b 00                	mov    (%eax),%eax
  8003db:	99                   	cltd   
  8003dc:	31 d0                	xor    %edx,%eax
  8003de:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e0:	83 f8 08             	cmp    $0x8,%eax
  8003e3:	7f 23                	jg     800408 <vprintfmt+0x13b>
  8003e5:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  8003ec:	85 d2                	test   %edx,%edx
  8003ee:	74 18                	je     800408 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003f0:	52                   	push   %edx
  8003f1:	68 a1 10 80 00       	push   $0x8010a1
  8003f6:	53                   	push   %ebx
  8003f7:	56                   	push   %esi
  8003f8:	e8 b3 fe ff ff       	call   8002b0 <printfmt>
  8003fd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800400:	89 7d 14             	mov    %edi,0x14(%ebp)
  800403:	e9 9a 02 00 00       	jmp    8006a2 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800408:	50                   	push   %eax
  800409:	68 98 10 80 00       	push   $0x801098
  80040e:	53                   	push   %ebx
  80040f:	56                   	push   %esi
  800410:	e8 9b fe ff ff       	call   8002b0 <printfmt>
  800415:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800418:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80041b:	e9 82 02 00 00       	jmp    8006a2 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	83 c0 04             	add    $0x4,%eax
  800426:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80042e:	85 ff                	test   %edi,%edi
  800430:	b8 91 10 80 00       	mov    $0x801091,%eax
  800435:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800438:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043c:	0f 8e bd 00 00 00    	jle    8004ff <vprintfmt+0x232>
  800442:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800446:	75 0e                	jne    800456 <vprintfmt+0x189>
  800448:	89 75 08             	mov    %esi,0x8(%ebp)
  80044b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80044e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800451:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800454:	eb 6d                	jmp    8004c3 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	ff 75 d0             	pushl  -0x30(%ebp)
  80045c:	57                   	push   %edi
  80045d:	e8 6e 03 00 00       	call   8007d0 <strnlen>
  800462:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800465:	29 c1                	sub    %eax,%ecx
  800467:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80046a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800471:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800474:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800477:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	eb 0f                	jmp    80048a <vprintfmt+0x1bd>
					putch(padc, putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	53                   	push   %ebx
  80047f:	ff 75 e0             	pushl  -0x20(%ebp)
  800482:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800484:	83 ef 01             	sub    $0x1,%edi
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	85 ff                	test   %edi,%edi
  80048c:	7f ed                	jg     80047b <vprintfmt+0x1ae>
  80048e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800491:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800494:	85 c9                	test   %ecx,%ecx
  800496:	b8 00 00 00 00       	mov    $0x0,%eax
  80049b:	0f 49 c1             	cmovns %ecx,%eax
  80049e:	29 c1                	sub    %eax,%ecx
  8004a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a9:	89 cb                	mov    %ecx,%ebx
  8004ab:	eb 16                	jmp    8004c3 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b1:	75 31                	jne    8004e4 <vprintfmt+0x217>
					putch(ch, putdat);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	ff 75 0c             	pushl  0xc(%ebp)
  8004b9:	50                   	push   %eax
  8004ba:	ff 55 08             	call   *0x8(%ebp)
  8004bd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c0:	83 eb 01             	sub    $0x1,%ebx
  8004c3:	83 c7 01             	add    $0x1,%edi
  8004c6:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004ca:	0f be c2             	movsbl %dl,%eax
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	74 59                	je     80052a <vprintfmt+0x25d>
  8004d1:	85 f6                	test   %esi,%esi
  8004d3:	78 d8                	js     8004ad <vprintfmt+0x1e0>
  8004d5:	83 ee 01             	sub    $0x1,%esi
  8004d8:	79 d3                	jns    8004ad <vprintfmt+0x1e0>
  8004da:	89 df                	mov    %ebx,%edi
  8004dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e2:	eb 37                	jmp    80051b <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e4:	0f be d2             	movsbl %dl,%edx
  8004e7:	83 ea 20             	sub    $0x20,%edx
  8004ea:	83 fa 5e             	cmp    $0x5e,%edx
  8004ed:	76 c4                	jbe    8004b3 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	ff 75 0c             	pushl  0xc(%ebp)
  8004f5:	6a 3f                	push   $0x3f
  8004f7:	ff 55 08             	call   *0x8(%ebp)
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	eb c1                	jmp    8004c0 <vprintfmt+0x1f3>
  8004ff:	89 75 08             	mov    %esi,0x8(%ebp)
  800502:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800505:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800508:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050b:	eb b6                	jmp    8004c3 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	53                   	push   %ebx
  800511:	6a 20                	push   $0x20
  800513:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	85 ff                	test   %edi,%edi
  80051d:	7f ee                	jg     80050d <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80051f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800522:	89 45 14             	mov    %eax,0x14(%ebp)
  800525:	e9 78 01 00 00       	jmp    8006a2 <vprintfmt+0x3d5>
  80052a:	89 df                	mov    %ebx,%edi
  80052c:	8b 75 08             	mov    0x8(%ebp),%esi
  80052f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800532:	eb e7                	jmp    80051b <vprintfmt+0x24e>
	if (lflag >= 2)
  800534:	83 f9 01             	cmp    $0x1,%ecx
  800537:	7e 3f                	jle    800578 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8b 50 04             	mov    0x4(%eax),%edx
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800544:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 40 08             	lea    0x8(%eax),%eax
  80054d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800550:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800554:	79 5c                	jns    8005b2 <vprintfmt+0x2e5>
				putch('-', putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	53                   	push   %ebx
  80055a:	6a 2d                	push   $0x2d
  80055c:	ff d6                	call   *%esi
				num = -(long long) num;
  80055e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800561:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800564:	f7 da                	neg    %edx
  800566:	83 d1 00             	adc    $0x0,%ecx
  800569:	f7 d9                	neg    %ecx
  80056b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80056e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800573:	e9 10 01 00 00       	jmp    800688 <vprintfmt+0x3bb>
	else if (lflag)
  800578:	85 c9                	test   %ecx,%ecx
  80057a:	75 1b                	jne    800597 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800584:	89 c1                	mov    %eax,%ecx
  800586:	c1 f9 1f             	sar    $0x1f,%ecx
  800589:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 40 04             	lea    0x4(%eax),%eax
  800592:	89 45 14             	mov    %eax,0x14(%ebp)
  800595:	eb b9                	jmp    800550 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059f:	89 c1                	mov    %eax,%ecx
  8005a1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8d 40 04             	lea    0x4(%eax),%eax
  8005ad:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b0:	eb 9e                	jmp    800550 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005b2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bd:	e9 c6 00 00 00       	jmp    800688 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005c2:	83 f9 01             	cmp    $0x1,%ecx
  8005c5:	7e 18                	jle    8005df <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8b 10                	mov    (%eax),%edx
  8005cc:	8b 48 04             	mov    0x4(%eax),%ecx
  8005cf:	8d 40 08             	lea    0x8(%eax),%eax
  8005d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005da:	e9 a9 00 00 00       	jmp    800688 <vprintfmt+0x3bb>
	else if (lflag)
  8005df:	85 c9                	test   %ecx,%ecx
  8005e1:	75 1a                	jne    8005fd <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8b 10                	mov    (%eax),%edx
  8005e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ed:	8d 40 04             	lea    0x4(%eax),%eax
  8005f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f8:	e9 8b 00 00 00       	jmp    800688 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8b 10                	mov    (%eax),%edx
  800602:	b9 00 00 00 00       	mov    $0x0,%ecx
  800607:	8d 40 04             	lea    0x4(%eax),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800612:	eb 74                	jmp    800688 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800614:	83 f9 01             	cmp    $0x1,%ecx
  800617:	7e 15                	jle    80062e <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8b 10                	mov    (%eax),%edx
  80061e:	8b 48 04             	mov    0x4(%eax),%ecx
  800621:	8d 40 08             	lea    0x8(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800627:	b8 08 00 00 00       	mov    $0x8,%eax
  80062c:	eb 5a                	jmp    800688 <vprintfmt+0x3bb>
	else if (lflag)
  80062e:	85 c9                	test   %ecx,%ecx
  800630:	75 17                	jne    800649 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 10                	mov    (%eax),%edx
  800637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063c:	8d 40 04             	lea    0x4(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800642:	b8 08 00 00 00       	mov    $0x8,%eax
  800647:	eb 3f                	jmp    800688 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800659:	b8 08 00 00 00       	mov    $0x8,%eax
  80065e:	eb 28                	jmp    800688 <vprintfmt+0x3bb>
			putch('0', putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	6a 30                	push   $0x30
  800666:	ff d6                	call   *%esi
			putch('x', putdat);
  800668:	83 c4 08             	add    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 78                	push   $0x78
  80066e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 10                	mov    (%eax),%edx
  800675:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80067a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80067d:	8d 40 04             	lea    0x4(%eax),%eax
  800680:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800683:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800688:	83 ec 0c             	sub    $0xc,%esp
  80068b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068f:	57                   	push   %edi
  800690:	ff 75 e0             	pushl  -0x20(%ebp)
  800693:	50                   	push   %eax
  800694:	51                   	push   %ecx
  800695:	52                   	push   %edx
  800696:	89 da                	mov    %ebx,%edx
  800698:	89 f0                	mov    %esi,%eax
  80069a:	e8 45 fb ff ff       	call   8001e4 <printnum>
			break;
  80069f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006a5:	83 c7 01             	add    $0x1,%edi
  8006a8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ac:	83 f8 25             	cmp    $0x25,%eax
  8006af:	0f 84 2f fc ff ff    	je     8002e4 <vprintfmt+0x17>
			if (ch == '\0')
  8006b5:	85 c0                	test   %eax,%eax
  8006b7:	0f 84 8b 00 00 00    	je     800748 <vprintfmt+0x47b>
			putch(ch, putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	50                   	push   %eax
  8006c2:	ff d6                	call   *%esi
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	eb dc                	jmp    8006a5 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006c9:	83 f9 01             	cmp    $0x1,%ecx
  8006cc:	7e 15                	jle    8006e3 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d6:	8d 40 08             	lea    0x8(%eax),%eax
  8006d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006dc:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e1:	eb a5                	jmp    800688 <vprintfmt+0x3bb>
	else if (lflag)
  8006e3:	85 c9                	test   %ecx,%ecx
  8006e5:	75 17                	jne    8006fe <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f1:	8d 40 04             	lea    0x4(%eax),%eax
  8006f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
  8006fc:	eb 8a                	jmp    800688 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	b9 00 00 00 00       	mov    $0x0,%ecx
  800708:	8d 40 04             	lea    0x4(%eax),%eax
  80070b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070e:	b8 10 00 00 00       	mov    $0x10,%eax
  800713:	e9 70 ff ff ff       	jmp    800688 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	53                   	push   %ebx
  80071c:	6a 25                	push   $0x25
  80071e:	ff d6                	call   *%esi
			break;
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	e9 7a ff ff ff       	jmp    8006a2 <vprintfmt+0x3d5>
			putch('%', putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	53                   	push   %ebx
  80072c:	6a 25                	push   $0x25
  80072e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	89 f8                	mov    %edi,%eax
  800735:	eb 03                	jmp    80073a <vprintfmt+0x46d>
  800737:	83 e8 01             	sub    $0x1,%eax
  80073a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80073e:	75 f7                	jne    800737 <vprintfmt+0x46a>
  800740:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800743:	e9 5a ff ff ff       	jmp    8006a2 <vprintfmt+0x3d5>
}
  800748:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074b:	5b                   	pop    %ebx
  80074c:	5e                   	pop    %esi
  80074d:	5f                   	pop    %edi
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 18             	sub    $0x18,%esp
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800763:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800766:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076d:	85 c0                	test   %eax,%eax
  80076f:	74 26                	je     800797 <vsnprintf+0x47>
  800771:	85 d2                	test   %edx,%edx
  800773:	7e 22                	jle    800797 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800775:	ff 75 14             	pushl  0x14(%ebp)
  800778:	ff 75 10             	pushl  0x10(%ebp)
  80077b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077e:	50                   	push   %eax
  80077f:	68 93 02 80 00       	push   $0x800293
  800784:	e8 44 fb ff ff       	call   8002cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800789:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800792:	83 c4 10             	add    $0x10,%esp
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    
		return -E_INVAL;
  800797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079c:	eb f7                	jmp    800795 <vsnprintf+0x45>

0080079e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a7:	50                   	push   %eax
  8007a8:	ff 75 10             	pushl  0x10(%ebp)
  8007ab:	ff 75 0c             	pushl  0xc(%ebp)
  8007ae:	ff 75 08             	pushl  0x8(%ebp)
  8007b1:	e8 9a ff ff ff       	call   800750 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007be:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c3:	eb 03                	jmp    8007c8 <strlen+0x10>
		n++;
  8007c5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007c8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cc:	75 f7                	jne    8007c5 <strlen+0xd>
	return n;
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007de:	eb 03                	jmp    8007e3 <strnlen+0x13>
		n++;
  8007e0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	39 d0                	cmp    %edx,%eax
  8007e5:	74 06                	je     8007ed <strnlen+0x1d>
  8007e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007eb:	75 f3                	jne    8007e0 <strnlen+0x10>
	return n;
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f9:	89 c2                	mov    %eax,%edx
  8007fb:	83 c1 01             	add    $0x1,%ecx
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800805:	88 5a ff             	mov    %bl,-0x1(%edx)
  800808:	84 db                	test   %bl,%bl
  80080a:	75 ef                	jne    8007fb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080c:	5b                   	pop    %ebx
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800816:	53                   	push   %ebx
  800817:	e8 9c ff ff ff       	call   8007b8 <strlen>
  80081c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80081f:	ff 75 0c             	pushl  0xc(%ebp)
  800822:	01 d8                	add    %ebx,%eax
  800824:	50                   	push   %eax
  800825:	e8 c5 ff ff ff       	call   8007ef <strcpy>
	return dst;
}
  80082a:	89 d8                	mov    %ebx,%eax
  80082c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082f:	c9                   	leave  
  800830:	c3                   	ret    

00800831 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	56                   	push   %esi
  800835:	53                   	push   %ebx
  800836:	8b 75 08             	mov    0x8(%ebp),%esi
  800839:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083c:	89 f3                	mov    %esi,%ebx
  80083e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800841:	89 f2                	mov    %esi,%edx
  800843:	eb 0f                	jmp    800854 <strncpy+0x23>
		*dst++ = *src;
  800845:	83 c2 01             	add    $0x1,%edx
  800848:	0f b6 01             	movzbl (%ecx),%eax
  80084b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084e:	80 39 01             	cmpb   $0x1,(%ecx)
  800851:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800854:	39 da                	cmp    %ebx,%edx
  800856:	75 ed                	jne    800845 <strncpy+0x14>
	}
	return ret;
}
  800858:	89 f0                	mov    %esi,%eax
  80085a:	5b                   	pop    %ebx
  80085b:	5e                   	pop    %esi
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	56                   	push   %esi
  800862:	53                   	push   %ebx
  800863:	8b 75 08             	mov    0x8(%ebp),%esi
  800866:	8b 55 0c             	mov    0xc(%ebp),%edx
  800869:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80086c:	89 f0                	mov    %esi,%eax
  80086e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800872:	85 c9                	test   %ecx,%ecx
  800874:	75 0b                	jne    800881 <strlcpy+0x23>
  800876:	eb 17                	jmp    80088f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800878:	83 c2 01             	add    $0x1,%edx
  80087b:	83 c0 01             	add    $0x1,%eax
  80087e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800881:	39 d8                	cmp    %ebx,%eax
  800883:	74 07                	je     80088c <strlcpy+0x2e>
  800885:	0f b6 0a             	movzbl (%edx),%ecx
  800888:	84 c9                	test   %cl,%cl
  80088a:	75 ec                	jne    800878 <strlcpy+0x1a>
		*dst = '\0';
  80088c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088f:	29 f0                	sub    %esi,%eax
}
  800891:	5b                   	pop    %ebx
  800892:	5e                   	pop    %esi
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089e:	eb 06                	jmp    8008a6 <strcmp+0x11>
		p++, q++;
  8008a0:	83 c1 01             	add    $0x1,%ecx
  8008a3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008a6:	0f b6 01             	movzbl (%ecx),%eax
  8008a9:	84 c0                	test   %al,%al
  8008ab:	74 04                	je     8008b1 <strcmp+0x1c>
  8008ad:	3a 02                	cmp    (%edx),%al
  8008af:	74 ef                	je     8008a0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b1:	0f b6 c0             	movzbl %al,%eax
  8008b4:	0f b6 12             	movzbl (%edx),%edx
  8008b7:	29 d0                	sub    %edx,%eax
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c5:	89 c3                	mov    %eax,%ebx
  8008c7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ca:	eb 06                	jmp    8008d2 <strncmp+0x17>
		n--, p++, q++;
  8008cc:	83 c0 01             	add    $0x1,%eax
  8008cf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d2:	39 d8                	cmp    %ebx,%eax
  8008d4:	74 16                	je     8008ec <strncmp+0x31>
  8008d6:	0f b6 08             	movzbl (%eax),%ecx
  8008d9:	84 c9                	test   %cl,%cl
  8008db:	74 04                	je     8008e1 <strncmp+0x26>
  8008dd:	3a 0a                	cmp    (%edx),%cl
  8008df:	74 eb                	je     8008cc <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e1:	0f b6 00             	movzbl (%eax),%eax
  8008e4:	0f b6 12             	movzbl (%edx),%edx
  8008e7:	29 d0                	sub    %edx,%eax
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    
		return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f1:	eb f6                	jmp    8008e9 <strncmp+0x2e>

008008f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fd:	0f b6 10             	movzbl (%eax),%edx
  800900:	84 d2                	test   %dl,%dl
  800902:	74 09                	je     80090d <strchr+0x1a>
		if (*s == c)
  800904:	38 ca                	cmp    %cl,%dl
  800906:	74 0a                	je     800912 <strchr+0x1f>
	for (; *s; s++)
  800908:	83 c0 01             	add    $0x1,%eax
  80090b:	eb f0                	jmp    8008fd <strchr+0xa>
			return (char *) s;
	return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091e:	eb 03                	jmp    800923 <strfind+0xf>
  800920:	83 c0 01             	add    $0x1,%eax
  800923:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800926:	38 ca                	cmp    %cl,%dl
  800928:	74 04                	je     80092e <strfind+0x1a>
  80092a:	84 d2                	test   %dl,%dl
  80092c:	75 f2                	jne    800920 <strfind+0xc>
			break;
	return (char *) s;
}
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	57                   	push   %edi
  800934:	56                   	push   %esi
  800935:	53                   	push   %ebx
  800936:	8b 7d 08             	mov    0x8(%ebp),%edi
  800939:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093c:	85 c9                	test   %ecx,%ecx
  80093e:	74 13                	je     800953 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800940:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800946:	75 05                	jne    80094d <memset+0x1d>
  800948:	f6 c1 03             	test   $0x3,%cl
  80094b:	74 0d                	je     80095a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800950:	fc                   	cld    
  800951:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800953:	89 f8                	mov    %edi,%eax
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5f                   	pop    %edi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    
		c &= 0xFF;
  80095a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095e:	89 d3                	mov    %edx,%ebx
  800960:	c1 e3 08             	shl    $0x8,%ebx
  800963:	89 d0                	mov    %edx,%eax
  800965:	c1 e0 18             	shl    $0x18,%eax
  800968:	89 d6                	mov    %edx,%esi
  80096a:	c1 e6 10             	shl    $0x10,%esi
  80096d:	09 f0                	or     %esi,%eax
  80096f:	09 c2                	or     %eax,%edx
  800971:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800973:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800976:	89 d0                	mov    %edx,%eax
  800978:	fc                   	cld    
  800979:	f3 ab                	rep stos %eax,%es:(%edi)
  80097b:	eb d6                	jmp    800953 <memset+0x23>

0080097d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	57                   	push   %edi
  800981:	56                   	push   %esi
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 75 0c             	mov    0xc(%ebp),%esi
  800988:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098b:	39 c6                	cmp    %eax,%esi
  80098d:	73 35                	jae    8009c4 <memmove+0x47>
  80098f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800992:	39 c2                	cmp    %eax,%edx
  800994:	76 2e                	jbe    8009c4 <memmove+0x47>
		s += n;
		d += n;
  800996:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800999:	89 d6                	mov    %edx,%esi
  80099b:	09 fe                	or     %edi,%esi
  80099d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a3:	74 0c                	je     8009b1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a5:	83 ef 01             	sub    $0x1,%edi
  8009a8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ab:	fd                   	std    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ae:	fc                   	cld    
  8009af:	eb 21                	jmp    8009d2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 ef                	jne    8009a5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b6:	83 ef 04             	sub    $0x4,%edi
  8009b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009bf:	fd                   	std    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb ea                	jmp    8009ae <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c4:	89 f2                	mov    %esi,%edx
  8009c6:	09 c2                	or     %eax,%edx
  8009c8:	f6 c2 03             	test   $0x3,%dl
  8009cb:	74 09                	je     8009d6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009cd:	89 c7                	mov    %eax,%edi
  8009cf:	fc                   	cld    
  8009d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d2:	5e                   	pop    %esi
  8009d3:	5f                   	pop    %edi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d6:	f6 c1 03             	test   $0x3,%cl
  8009d9:	75 f2                	jne    8009cd <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009db:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009de:	89 c7                	mov    %eax,%edi
  8009e0:	fc                   	cld    
  8009e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e3:	eb ed                	jmp    8009d2 <memmove+0x55>

008009e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e8:	ff 75 10             	pushl  0x10(%ebp)
  8009eb:	ff 75 0c             	pushl  0xc(%ebp)
  8009ee:	ff 75 08             	pushl  0x8(%ebp)
  8009f1:	e8 87 ff ff ff       	call   80097d <memmove>
}
  8009f6:	c9                   	leave  
  8009f7:	c3                   	ret    

008009f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a03:	89 c6                	mov    %eax,%esi
  800a05:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a08:	39 f0                	cmp    %esi,%eax
  800a0a:	74 1c                	je     800a28 <memcmp+0x30>
		if (*s1 != *s2)
  800a0c:	0f b6 08             	movzbl (%eax),%ecx
  800a0f:	0f b6 1a             	movzbl (%edx),%ebx
  800a12:	38 d9                	cmp    %bl,%cl
  800a14:	75 08                	jne    800a1e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a16:	83 c0 01             	add    $0x1,%eax
  800a19:	83 c2 01             	add    $0x1,%edx
  800a1c:	eb ea                	jmp    800a08 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a1e:	0f b6 c1             	movzbl %cl,%eax
  800a21:	0f b6 db             	movzbl %bl,%ebx
  800a24:	29 d8                	sub    %ebx,%eax
  800a26:	eb 05                	jmp    800a2d <memcmp+0x35>
	}

	return 0;
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3a:	89 c2                	mov    %eax,%edx
  800a3c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3f:	39 d0                	cmp    %edx,%eax
  800a41:	73 09                	jae    800a4c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a43:	38 08                	cmp    %cl,(%eax)
  800a45:	74 05                	je     800a4c <memfind+0x1b>
	for (; s < ends; s++)
  800a47:	83 c0 01             	add    $0x1,%eax
  800a4a:	eb f3                	jmp    800a3f <memfind+0xe>
			break;
	return (void *) s;
}
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	57                   	push   %edi
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
  800a54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5a:	eb 03                	jmp    800a5f <strtol+0x11>
		s++;
  800a5c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a5f:	0f b6 01             	movzbl (%ecx),%eax
  800a62:	3c 20                	cmp    $0x20,%al
  800a64:	74 f6                	je     800a5c <strtol+0xe>
  800a66:	3c 09                	cmp    $0x9,%al
  800a68:	74 f2                	je     800a5c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a6a:	3c 2b                	cmp    $0x2b,%al
  800a6c:	74 2e                	je     800a9c <strtol+0x4e>
	int neg = 0;
  800a6e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a73:	3c 2d                	cmp    $0x2d,%al
  800a75:	74 2f                	je     800aa6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a77:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a7d:	75 05                	jne    800a84 <strtol+0x36>
  800a7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a82:	74 2c                	je     800ab0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a84:	85 db                	test   %ebx,%ebx
  800a86:	75 0a                	jne    800a92 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a88:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a8d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a90:	74 28                	je     800aba <strtol+0x6c>
		base = 10;
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a9a:	eb 50                	jmp    800aec <strtol+0x9e>
		s++;
  800a9c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a9f:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa4:	eb d1                	jmp    800a77 <strtol+0x29>
		s++, neg = 1;
  800aa6:	83 c1 01             	add    $0x1,%ecx
  800aa9:	bf 01 00 00 00       	mov    $0x1,%edi
  800aae:	eb c7                	jmp    800a77 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab4:	74 0e                	je     800ac4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab6:	85 db                	test   %ebx,%ebx
  800ab8:	75 d8                	jne    800a92 <strtol+0x44>
		s++, base = 8;
  800aba:	83 c1 01             	add    $0x1,%ecx
  800abd:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ac2:	eb ce                	jmp    800a92 <strtol+0x44>
		s += 2, base = 16;
  800ac4:	83 c1 02             	add    $0x2,%ecx
  800ac7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acc:	eb c4                	jmp    800a92 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ace:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad1:	89 f3                	mov    %esi,%ebx
  800ad3:	80 fb 19             	cmp    $0x19,%bl
  800ad6:	77 29                	ja     800b01 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ad8:	0f be d2             	movsbl %dl,%edx
  800adb:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ade:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae1:	7d 30                	jge    800b13 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ae3:	83 c1 01             	add    $0x1,%ecx
  800ae6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aea:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aec:	0f b6 11             	movzbl (%ecx),%edx
  800aef:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af2:	89 f3                	mov    %esi,%ebx
  800af4:	80 fb 09             	cmp    $0x9,%bl
  800af7:	77 d5                	ja     800ace <strtol+0x80>
			dig = *s - '0';
  800af9:	0f be d2             	movsbl %dl,%edx
  800afc:	83 ea 30             	sub    $0x30,%edx
  800aff:	eb dd                	jmp    800ade <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b01:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b04:	89 f3                	mov    %esi,%ebx
  800b06:	80 fb 19             	cmp    $0x19,%bl
  800b09:	77 08                	ja     800b13 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b0b:	0f be d2             	movsbl %dl,%edx
  800b0e:	83 ea 37             	sub    $0x37,%edx
  800b11:	eb cb                	jmp    800ade <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b13:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b17:	74 05                	je     800b1e <strtol+0xd0>
		*endptr = (char *) s;
  800b19:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b1e:	89 c2                	mov    %eax,%edx
  800b20:	f7 da                	neg    %edx
  800b22:	85 ff                	test   %edi,%edi
  800b24:	0f 45 c2             	cmovne %edx,%eax
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
  800b37:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3d:	89 c3                	mov    %eax,%ebx
  800b3f:	89 c7                	mov    %eax,%edi
  800b41:	89 c6                	mov    %eax,%esi
  800b43:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b50:	ba 00 00 00 00       	mov    $0x0,%edx
  800b55:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5a:	89 d1                	mov    %edx,%ecx
  800b5c:	89 d3                	mov    %edx,%ebx
  800b5e:	89 d7                	mov    %edx,%edi
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b77:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7f:	89 cb                	mov    %ecx,%ebx
  800b81:	89 cf                	mov    %ecx,%edi
  800b83:	89 ce                	mov    %ecx,%esi
  800b85:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b87:	85 c0                	test   %eax,%eax
  800b89:	7f 08                	jg     800b93 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b93:	83 ec 0c             	sub    $0xc,%esp
  800b96:	50                   	push   %eax
  800b97:	6a 03                	push   $0x3
  800b99:	68 c4 12 80 00       	push   $0x8012c4
  800b9e:	6a 23                	push   $0x23
  800ba0:	68 e1 12 80 00       	push   $0x8012e1
  800ba5:	e8 1b 02 00 00       	call   800dc5 <_panic>

00800baa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 d3                	mov    %edx,%ebx
  800bbe:	89 d7                	mov    %edx,%edi
  800bc0:	89 d6                	mov    %edx,%esi
  800bc2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_yield>:

void
sys_yield(void)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd9:	89 d1                	mov    %edx,%ecx
  800bdb:	89 d3                	mov    %edx,%ebx
  800bdd:	89 d7                	mov    %edx,%edi
  800bdf:	89 d6                	mov    %edx,%esi
  800be1:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf1:	be 00 00 00 00       	mov    $0x0,%esi
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfc:	b8 04 00 00 00       	mov    $0x4,%eax
  800c01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c04:	89 f7                	mov    %esi,%edi
  800c06:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7f 08                	jg     800c14 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800c18:	6a 04                	push   $0x4
  800c1a:	68 c4 12 80 00       	push   $0x8012c4
  800c1f:	6a 23                	push   $0x23
  800c21:	68 e1 12 80 00       	push   $0x8012e1
  800c26:	e8 9a 01 00 00       	call   800dc5 <_panic>

00800c2b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c45:	8b 75 18             	mov    0x18(%ebp),%esi
  800c48:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7f 08                	jg     800c56 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
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
  800c5a:	6a 05                	push   $0x5
  800c5c:	68 c4 12 80 00       	push   $0x8012c4
  800c61:	6a 23                	push   $0x23
  800c63:	68 e1 12 80 00       	push   $0x8012e1
  800c68:	e8 58 01 00 00       	call   800dc5 <_panic>

00800c6d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c81:	b8 06 00 00 00       	mov    $0x6,%eax
  800c86:	89 df                	mov    %ebx,%edi
  800c88:	89 de                	mov    %ebx,%esi
  800c8a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7f 08                	jg     800c98 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800c9c:	6a 06                	push   $0x6
  800c9e:	68 c4 12 80 00       	push   $0x8012c4
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 e1 12 80 00       	push   $0x8012e1
  800caa:	e8 16 01 00 00       	call   800dc5 <_panic>

00800caf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800cc3:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc8:	89 df                	mov    %ebx,%edi
  800cca:	89 de                	mov    %ebx,%esi
  800ccc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7f 08                	jg     800cda <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  800cde:	6a 08                	push   $0x8
  800ce0:	68 c4 12 80 00       	push   $0x8012c4
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 e1 12 80 00       	push   $0x8012e1
  800cec:	e8 d4 00 00 00       	call   800dc5 <_panic>

00800cf1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d05:	b8 09 00 00 00       	mov    $0x9,%eax
  800d0a:	89 df                	mov    %ebx,%edi
  800d0c:	89 de                	mov    %ebx,%esi
  800d0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d10:	85 c0                	test   %eax,%eax
  800d12:	7f 08                	jg     800d1c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 09                	push   $0x9
  800d22:	68 c4 12 80 00       	push   $0x8012c4
  800d27:	6a 23                	push   $0x23
  800d29:	68 e1 12 80 00       	push   $0x8012e1
  800d2e:	e8 92 00 00 00       	call   800dc5 <_panic>

00800d33 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d44:	be 00 00 00 00       	mov    $0x0,%esi
  800d49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
  800d5c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6c:	89 cb                	mov    %ecx,%ebx
  800d6e:	89 cf                	mov    %ecx,%edi
  800d70:	89 ce                	mov    %ecx,%esi
  800d72:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	7f 08                	jg     800d80 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 0c                	push   $0xc
  800d86:	68 c4 12 80 00       	push   $0x8012c4
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 e1 12 80 00       	push   $0x8012e1
  800d92:	e8 2e 00 00 00       	call   800dc5 <_panic>

00800d97 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d9d:	68 fb 12 80 00       	push   $0x8012fb
  800da2:	6a 51                	push   $0x51
  800da4:	68 ef 12 80 00       	push   $0x8012ef
  800da9:	e8 17 00 00 00       	call   800dc5 <_panic>

00800dae <sfork>:
}

// Challenge!
int
sfork(void)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800db4:	68 fa 12 80 00       	push   $0x8012fa
  800db9:	6a 58                	push   $0x58
  800dbb:	68 ef 12 80 00       	push   $0x8012ef
  800dc0:	e8 00 00 00 00       	call   800dc5 <_panic>

00800dc5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dca:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dcd:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dd3:	e8 d2 fd ff ff       	call   800baa <sys_getenvid>
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	ff 75 0c             	pushl  0xc(%ebp)
  800dde:	ff 75 08             	pushl  0x8(%ebp)
  800de1:	56                   	push   %esi
  800de2:	50                   	push   %eax
  800de3:	68 10 13 80 00       	push   $0x801310
  800de8:	e8 e3 f3 ff ff       	call   8001d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ded:	83 c4 18             	add    $0x18,%esp
  800df0:	53                   	push   %ebx
  800df1:	ff 75 10             	pushl  0x10(%ebp)
  800df4:	e8 86 f3 ff ff       	call   80017f <vcprintf>
	cprintf("\n");
  800df9:	c7 04 24 6f 10 80 00 	movl   $0x80106f,(%esp)
  800e00:	e8 cb f3 ff ff       	call   8001d0 <cprintf>
  800e05:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e08:	cc                   	int3   
  800e09:	eb fd                	jmp    800e08 <_panic+0x43>
  800e0b:	66 90                	xchg   %ax,%ax
  800e0d:	66 90                	xchg   %ax,%ax
  800e0f:	90                   	nop

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
