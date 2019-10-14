
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 c0 11 00       	mov    $0x11c000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 c0 11 f0       	mov    $0xf011c000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5e 00 00 00       	call   f010009c <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 00 9f 22 f0 00 	cmpl   $0x0,0xf0229f00
f010004f:	74 0f                	je     f0100060 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100051:	83 ec 0c             	sub    $0xc,%esp
f0100054:	6a 00                	push   $0x0
f0100056:	e8 aa 08 00 00       	call   f0100905 <monitor>
f010005b:	83 c4 10             	add    $0x10,%esp
f010005e:	eb f1                	jmp    f0100051 <_panic+0x11>
	panicstr = fmt;
f0100060:	89 35 00 9f 22 f0    	mov    %esi,0xf0229f00
	asm volatile("cli; cld");
f0100066:	fa                   	cli    
f0100067:	fc                   	cld    
	va_start(ap, fmt);
f0100068:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006b:	e8 d3 46 00 00       	call   f0104743 <cpunum>
f0100070:	ff 75 0c             	pushl  0xc(%ebp)
f0100073:	ff 75 08             	pushl  0x8(%ebp)
f0100076:	50                   	push   %eax
f0100077:	68 80 4d 10 f0       	push   $0xf0104d80
f010007c:	e8 14 2b 00 00       	call   f0102b95 <cprintf>
	vcprintf(fmt, ap);
f0100081:	83 c4 08             	add    $0x8,%esp
f0100084:	53                   	push   %ebx
f0100085:	56                   	push   %esi
f0100086:	e8 e4 2a 00 00       	call   f0102b6f <vcprintf>
	cprintf("\n");
f010008b:	c7 04 24 4d 4e 10 f0 	movl   $0xf0104e4d,(%esp)
f0100092:	e8 fe 2a 00 00       	call   f0102b95 <cprintf>
f0100097:	83 c4 10             	add    $0x10,%esp
f010009a:	eb b5                	jmp    f0100051 <_panic+0x11>

f010009c <i386_init>:
{
f010009c:	55                   	push   %ebp
f010009d:	89 e5                	mov    %esp,%ebp
f010009f:	53                   	push   %ebx
f01000a0:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000a3:	e8 82 05 00 00       	call   f010062a <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a8:	83 ec 08             	sub    $0x8,%esp
f01000ab:	68 ac 1a 00 00       	push   $0x1aac
f01000b0:	68 ec 4d 10 f0       	push   $0xf0104dec
f01000b5:	e8 db 2a 00 00       	call   f0102b95 <cprintf>
	mem_init();
f01000ba:	e8 4b 0e 00 00       	call   f0100f0a <mem_init>
	env_init();
f01000bf:	e8 32 23 00 00       	call   f01023f6 <env_init>
	trap_init();
f01000c4:	e8 46 2b 00 00       	call   f0102c0f <trap_init>
	mp_init();
f01000c9:	e8 63 43 00 00       	call   f0104431 <mp_init>
	lapic_init();
f01000ce:	e8 8a 46 00 00       	call   f010475d <lapic_init>
	pic_init();
f01000d3:	e8 e0 29 00 00       	call   f0102ab8 <pic_init>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000d8:	83 c4 10             	add    $0x10,%esp
f01000db:	83 3d 08 9f 22 f0 07 	cmpl   $0x7,0xf0229f08
f01000e2:	76 27                	jbe    f010010b <i386_init+0x6f>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000e4:	83 ec 04             	sub    $0x4,%esp
f01000e7:	b8 96 43 10 f0       	mov    $0xf0104396,%eax
f01000ec:	2d 1c 43 10 f0       	sub    $0xf010431c,%eax
f01000f1:	50                   	push   %eax
f01000f2:	68 1c 43 10 f0       	push   $0xf010431c
f01000f7:	68 00 70 00 f0       	push   $0xf0007000
f01000fc:	e8 6c 40 00 00       	call   f010416d <memmove>
f0100101:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f0100104:	bb 20 a0 22 f0       	mov    $0xf022a020,%ebx
f0100109:	eb 19                	jmp    f0100124 <i386_init+0x88>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010010b:	68 00 70 00 00       	push   $0x7000
f0100110:	68 a4 4d 10 f0       	push   $0xf0104da4
f0100115:	6a 4c                	push   $0x4c
f0100117:	68 07 4e 10 f0       	push   $0xf0104e07
f010011c:	e8 1f ff ff ff       	call   f0100040 <_panic>
f0100121:	83 c3 74             	add    $0x74,%ebx
f0100124:	6b 05 c4 a3 22 f0 74 	imul   $0x74,0xf022a3c4,%eax
f010012b:	05 20 a0 22 f0       	add    $0xf022a020,%eax
f0100130:	39 c3                	cmp    %eax,%ebx
f0100132:	73 4c                	jae    f0100180 <i386_init+0xe4>
		if (c == cpus + cpunum())  // We've started already.
f0100134:	e8 0a 46 00 00       	call   f0104743 <cpunum>
f0100139:	6b c0 74             	imul   $0x74,%eax,%eax
f010013c:	05 20 a0 22 f0       	add    $0xf022a020,%eax
f0100141:	39 c3                	cmp    %eax,%ebx
f0100143:	74 dc                	je     f0100121 <i386_init+0x85>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100145:	89 d8                	mov    %ebx,%eax
f0100147:	2d 20 a0 22 f0       	sub    $0xf022a020,%eax
f010014c:	c1 f8 02             	sar    $0x2,%eax
f010014f:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100155:	c1 e0 0f             	shl    $0xf,%eax
f0100158:	05 00 30 23 f0       	add    $0xf0233000,%eax
f010015d:	a3 04 9f 22 f0       	mov    %eax,0xf0229f04
		lapic_startap(c->cpu_id, PADDR(code));
f0100162:	83 ec 08             	sub    $0x8,%esp
f0100165:	68 00 70 00 00       	push   $0x7000
f010016a:	0f b6 03             	movzbl (%ebx),%eax
f010016d:	50                   	push   %eax
f010016e:	e8 3b 47 00 00       	call   f01048ae <lapic_startap>
f0100173:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f0100176:	8b 43 04             	mov    0x4(%ebx),%eax
f0100179:	83 f8 01             	cmp    $0x1,%eax
f010017c:	75 f8                	jne    f0100176 <i386_init+0xda>
f010017e:	eb a1                	jmp    f0100121 <i386_init+0x85>
	ENV_CREATE(user_primes, ENV_TYPE_USER);
f0100180:	83 ec 08             	sub    $0x8,%esp
f0100183:	6a 00                	push   $0x0
f0100185:	68 d8 f8 21 f0       	push   $0xf021f8d8
f010018a:	e8 3c 24 00 00       	call   f01025cb <env_create>
	sched_yield();
f010018f:	e8 38 33 00 00       	call   f01034cc <sched_yield>

f0100194 <mp_main>:
{
f0100194:	55                   	push   %ebp
f0100195:	89 e5                	mov    %esp,%ebp
f0100197:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f010019a:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
	if ((uint32_t)kva < KERNBASE)
f010019f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001a4:	77 12                	ja     f01001b8 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001a6:	50                   	push   %eax
f01001a7:	68 c8 4d 10 f0       	push   $0xf0104dc8
f01001ac:	6a 63                	push   $0x63
f01001ae:	68 07 4e 10 f0       	push   $0xf0104e07
f01001b3:	e8 88 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01001b8:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001bd:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001c0:	e8 7e 45 00 00       	call   f0104743 <cpunum>
f01001c5:	83 ec 08             	sub    $0x8,%esp
f01001c8:	50                   	push   %eax
f01001c9:	68 13 4e 10 f0       	push   $0xf0104e13
f01001ce:	e8 c2 29 00 00       	call   f0102b95 <cprintf>
	lapic_init();
f01001d3:	e8 85 45 00 00       	call   f010475d <lapic_init>
	env_init_percpu();
f01001d8:	e8 e9 21 00 00       	call   f01023c6 <env_init_percpu>
	trap_init_percpu();
f01001dd:	e8 c7 29 00 00       	call   f0102ba9 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001e2:	e8 5c 45 00 00       	call   f0104743 <cpunum>
f01001e7:	6b d0 74             	imul   $0x74,%eax,%edx
f01001ea:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001ed:	b8 01 00 00 00       	mov    $0x1,%eax
f01001f2:	f0 87 82 20 a0 22 f0 	lock xchg %eax,-0xfdd5fe0(%edx)
f01001f9:	83 c4 10             	add    $0x10,%esp
f01001fc:	eb fe                	jmp    f01001fc <mp_main+0x68>

f01001fe <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01001fe:	55                   	push   %ebp
f01001ff:	89 e5                	mov    %esp,%ebp
f0100201:	53                   	push   %ebx
f0100202:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100205:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100208:	ff 75 0c             	pushl  0xc(%ebp)
f010020b:	ff 75 08             	pushl  0x8(%ebp)
f010020e:	68 29 4e 10 f0       	push   $0xf0104e29
f0100213:	e8 7d 29 00 00       	call   f0102b95 <cprintf>
	vcprintf(fmt, ap);
f0100218:	83 c4 08             	add    $0x8,%esp
f010021b:	53                   	push   %ebx
f010021c:	ff 75 10             	pushl  0x10(%ebp)
f010021f:	e8 4b 29 00 00       	call   f0102b6f <vcprintf>
	cprintf("\n");
f0100224:	c7 04 24 4d 4e 10 f0 	movl   $0xf0104e4d,(%esp)
f010022b:	e8 65 29 00 00       	call   f0102b95 <cprintf>
	va_end(ap);
}
f0100230:	83 c4 10             	add    $0x10,%esp
f0100233:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100236:	c9                   	leave  
f0100237:	c3                   	ret    

f0100238 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100238:	55                   	push   %ebp
f0100239:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010023b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100240:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100241:	a8 01                	test   $0x1,%al
f0100243:	74 0b                	je     f0100250 <serial_proc_data+0x18>
f0100245:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010024a:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010024b:	0f b6 c0             	movzbl %al,%eax
}
f010024e:	5d                   	pop    %ebp
f010024f:	c3                   	ret    
		return -1;
f0100250:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100255:	eb f7                	jmp    f010024e <serial_proc_data+0x16>

f0100257 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100257:	55                   	push   %ebp
f0100258:	89 e5                	mov    %esp,%ebp
f010025a:	53                   	push   %ebx
f010025b:	83 ec 04             	sub    $0x4,%esp
f010025e:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100260:	ff d3                	call   *%ebx
f0100262:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100265:	74 2d                	je     f0100294 <cons_intr+0x3d>
		if (c == 0)
f0100267:	85 c0                	test   %eax,%eax
f0100269:	74 f5                	je     f0100260 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f010026b:	8b 0d 24 92 22 f0    	mov    0xf0229224,%ecx
f0100271:	8d 51 01             	lea    0x1(%ecx),%edx
f0100274:	89 15 24 92 22 f0    	mov    %edx,0xf0229224
f010027a:	88 81 20 90 22 f0    	mov    %al,-0xfdd6fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100280:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100286:	75 d8                	jne    f0100260 <cons_intr+0x9>
			cons.wpos = 0;
f0100288:	c7 05 24 92 22 f0 00 	movl   $0x0,0xf0229224
f010028f:	00 00 00 
f0100292:	eb cc                	jmp    f0100260 <cons_intr+0x9>
	}
}
f0100294:	83 c4 04             	add    $0x4,%esp
f0100297:	5b                   	pop    %ebx
f0100298:	5d                   	pop    %ebp
f0100299:	c3                   	ret    

f010029a <kbd_proc_data>:
{
f010029a:	55                   	push   %ebp
f010029b:	89 e5                	mov    %esp,%ebp
f010029d:	53                   	push   %ebx
f010029e:	83 ec 04             	sub    $0x4,%esp
f01002a1:	ba 64 00 00 00       	mov    $0x64,%edx
f01002a6:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002a7:	a8 01                	test   $0x1,%al
f01002a9:	0f 84 fa 00 00 00    	je     f01003a9 <kbd_proc_data+0x10f>
	if (stat & KBS_TERR)
f01002af:	a8 20                	test   $0x20,%al
f01002b1:	0f 85 f9 00 00 00    	jne    f01003b0 <kbd_proc_data+0x116>
f01002b7:	ba 60 00 00 00       	mov    $0x60,%edx
f01002bc:	ec                   	in     (%dx),%al
f01002bd:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002bf:	3c e0                	cmp    $0xe0,%al
f01002c1:	0f 84 8e 00 00 00    	je     f0100355 <kbd_proc_data+0xbb>
	} else if (data & 0x80) {
f01002c7:	84 c0                	test   %al,%al
f01002c9:	0f 88 99 00 00 00    	js     f0100368 <kbd_proc_data+0xce>
	} else if (shift & E0ESC) {
f01002cf:	8b 0d 00 90 22 f0    	mov    0xf0229000,%ecx
f01002d5:	f6 c1 40             	test   $0x40,%cl
f01002d8:	74 0e                	je     f01002e8 <kbd_proc_data+0x4e>
		data |= 0x80;
f01002da:	83 c8 80             	or     $0xffffff80,%eax
f01002dd:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002df:	83 e1 bf             	and    $0xffffffbf,%ecx
f01002e2:	89 0d 00 90 22 f0    	mov    %ecx,0xf0229000
	shift |= shiftcode[data];
f01002e8:	0f b6 d2             	movzbl %dl,%edx
f01002eb:	0f b6 82 a0 4f 10 f0 	movzbl -0xfefb060(%edx),%eax
f01002f2:	0b 05 00 90 22 f0    	or     0xf0229000,%eax
	shift ^= togglecode[data];
f01002f8:	0f b6 8a a0 4e 10 f0 	movzbl -0xfefb160(%edx),%ecx
f01002ff:	31 c8                	xor    %ecx,%eax
f0100301:	a3 00 90 22 f0       	mov    %eax,0xf0229000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100306:	89 c1                	mov    %eax,%ecx
f0100308:	83 e1 03             	and    $0x3,%ecx
f010030b:	8b 0c 8d 80 4e 10 f0 	mov    -0xfefb180(,%ecx,4),%ecx
f0100312:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100316:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100319:	a8 08                	test   $0x8,%al
f010031b:	74 0d                	je     f010032a <kbd_proc_data+0x90>
		if ('a' <= c && c <= 'z')
f010031d:	89 da                	mov    %ebx,%edx
f010031f:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100322:	83 f9 19             	cmp    $0x19,%ecx
f0100325:	77 74                	ja     f010039b <kbd_proc_data+0x101>
			c += 'A' - 'a';
f0100327:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010032a:	f7 d0                	not    %eax
f010032c:	a8 06                	test   $0x6,%al
f010032e:	75 31                	jne    f0100361 <kbd_proc_data+0xc7>
f0100330:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100336:	75 29                	jne    f0100361 <kbd_proc_data+0xc7>
		cprintf("Rebooting!\n");
f0100338:	83 ec 0c             	sub    $0xc,%esp
f010033b:	68 43 4e 10 f0       	push   $0xf0104e43
f0100340:	e8 50 28 00 00       	call   f0102b95 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100345:	b8 03 00 00 00       	mov    $0x3,%eax
f010034a:	ba 92 00 00 00       	mov    $0x92,%edx
f010034f:	ee                   	out    %al,(%dx)
f0100350:	83 c4 10             	add    $0x10,%esp
f0100353:	eb 0c                	jmp    f0100361 <kbd_proc_data+0xc7>
		shift |= E0ESC;
f0100355:	83 0d 00 90 22 f0 40 	orl    $0x40,0xf0229000
		return 0;
f010035c:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100361:	89 d8                	mov    %ebx,%eax
f0100363:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100366:	c9                   	leave  
f0100367:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100368:	8b 0d 00 90 22 f0    	mov    0xf0229000,%ecx
f010036e:	89 cb                	mov    %ecx,%ebx
f0100370:	83 e3 40             	and    $0x40,%ebx
f0100373:	83 e0 7f             	and    $0x7f,%eax
f0100376:	85 db                	test   %ebx,%ebx
f0100378:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010037b:	0f b6 d2             	movzbl %dl,%edx
f010037e:	0f b6 82 a0 4f 10 f0 	movzbl -0xfefb060(%edx),%eax
f0100385:	83 c8 40             	or     $0x40,%eax
f0100388:	0f b6 c0             	movzbl %al,%eax
f010038b:	f7 d0                	not    %eax
f010038d:	21 c8                	and    %ecx,%eax
f010038f:	a3 00 90 22 f0       	mov    %eax,0xf0229000
		return 0;
f0100394:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100399:	eb c6                	jmp    f0100361 <kbd_proc_data+0xc7>
		else if ('A' <= c && c <= 'Z')
f010039b:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010039e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003a1:	83 fa 1a             	cmp    $0x1a,%edx
f01003a4:	0f 42 d9             	cmovb  %ecx,%ebx
f01003a7:	eb 81                	jmp    f010032a <kbd_proc_data+0x90>
		return -1;
f01003a9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003ae:	eb b1                	jmp    f0100361 <kbd_proc_data+0xc7>
		return -1;
f01003b0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003b5:	eb aa                	jmp    f0100361 <kbd_proc_data+0xc7>

f01003b7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003b7:	55                   	push   %ebp
f01003b8:	89 e5                	mov    %esp,%ebp
f01003ba:	57                   	push   %edi
f01003bb:	56                   	push   %esi
f01003bc:	53                   	push   %ebx
f01003bd:	83 ec 1c             	sub    $0x1c,%esp
f01003c0:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003c2:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003c7:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003cc:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003d1:	eb 09                	jmp    f01003dc <cons_putc+0x25>
f01003d3:	89 ca                	mov    %ecx,%edx
f01003d5:	ec                   	in     (%dx),%al
f01003d6:	ec                   	in     (%dx),%al
f01003d7:	ec                   	in     (%dx),%al
f01003d8:	ec                   	in     (%dx),%al
	     i++)
f01003d9:	83 c3 01             	add    $0x1,%ebx
f01003dc:	89 f2                	mov    %esi,%edx
f01003de:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003df:	a8 20                	test   $0x20,%al
f01003e1:	75 08                	jne    f01003eb <cons_putc+0x34>
f01003e3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003e9:	7e e8                	jle    f01003d3 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f01003eb:	89 f8                	mov    %edi,%eax
f01003ed:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003f0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003f5:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003f6:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003fb:	be 79 03 00 00       	mov    $0x379,%esi
f0100400:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100405:	eb 09                	jmp    f0100410 <cons_putc+0x59>
f0100407:	89 ca                	mov    %ecx,%edx
f0100409:	ec                   	in     (%dx),%al
f010040a:	ec                   	in     (%dx),%al
f010040b:	ec                   	in     (%dx),%al
f010040c:	ec                   	in     (%dx),%al
f010040d:	83 c3 01             	add    $0x1,%ebx
f0100410:	89 f2                	mov    %esi,%edx
f0100412:	ec                   	in     (%dx),%al
f0100413:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100419:	7f 04                	jg     f010041f <cons_putc+0x68>
f010041b:	84 c0                	test   %al,%al
f010041d:	79 e8                	jns    f0100407 <cons_putc+0x50>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100424:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100428:	ee                   	out    %al,(%dx)
f0100429:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010042e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100433:	ee                   	out    %al,(%dx)
f0100434:	b8 08 00 00 00       	mov    $0x8,%eax
f0100439:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f010043a:	89 fa                	mov    %edi,%edx
f010043c:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100442:	89 f8                	mov    %edi,%eax
f0100444:	80 cc 07             	or     $0x7,%ah
f0100447:	85 d2                	test   %edx,%edx
f0100449:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f010044c:	89 f8                	mov    %edi,%eax
f010044e:	0f b6 c0             	movzbl %al,%eax
f0100451:	83 f8 09             	cmp    $0x9,%eax
f0100454:	0f 84 b6 00 00 00    	je     f0100510 <cons_putc+0x159>
f010045a:	83 f8 09             	cmp    $0x9,%eax
f010045d:	7e 73                	jle    f01004d2 <cons_putc+0x11b>
f010045f:	83 f8 0a             	cmp    $0xa,%eax
f0100462:	0f 84 9b 00 00 00    	je     f0100503 <cons_putc+0x14c>
f0100468:	83 f8 0d             	cmp    $0xd,%eax
f010046b:	0f 85 d6 00 00 00    	jne    f0100547 <cons_putc+0x190>
		crt_pos -= (crt_pos % CRT_COLS);
f0100471:	0f b7 05 28 92 22 f0 	movzwl 0xf0229228,%eax
f0100478:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010047e:	c1 e8 16             	shr    $0x16,%eax
f0100481:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100484:	c1 e0 04             	shl    $0x4,%eax
f0100487:	66 a3 28 92 22 f0    	mov    %ax,0xf0229228
	if (crt_pos >= CRT_SIZE) {
f010048d:	66 81 3d 28 92 22 f0 	cmpw   $0x7cf,0xf0229228
f0100494:	cf 07 
f0100496:	0f 87 ce 00 00 00    	ja     f010056a <cons_putc+0x1b3>
	outb(addr_6845, 14);
f010049c:	8b 0d 30 92 22 f0    	mov    0xf0229230,%ecx
f01004a2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004a7:	89 ca                	mov    %ecx,%edx
f01004a9:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004aa:	0f b7 1d 28 92 22 f0 	movzwl 0xf0229228,%ebx
f01004b1:	8d 71 01             	lea    0x1(%ecx),%esi
f01004b4:	89 d8                	mov    %ebx,%eax
f01004b6:	66 c1 e8 08          	shr    $0x8,%ax
f01004ba:	89 f2                	mov    %esi,%edx
f01004bc:	ee                   	out    %al,(%dx)
f01004bd:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004c2:	89 ca                	mov    %ecx,%edx
f01004c4:	ee                   	out    %al,(%dx)
f01004c5:	89 d8                	mov    %ebx,%eax
f01004c7:	89 f2                	mov    %esi,%edx
f01004c9:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004cd:	5b                   	pop    %ebx
f01004ce:	5e                   	pop    %esi
f01004cf:	5f                   	pop    %edi
f01004d0:	5d                   	pop    %ebp
f01004d1:	c3                   	ret    
	switch (c & 0xff) {
f01004d2:	83 f8 08             	cmp    $0x8,%eax
f01004d5:	75 70                	jne    f0100547 <cons_putc+0x190>
		if (crt_pos > 0) {
f01004d7:	0f b7 05 28 92 22 f0 	movzwl 0xf0229228,%eax
f01004de:	66 85 c0             	test   %ax,%ax
f01004e1:	74 b9                	je     f010049c <cons_putc+0xe5>
			crt_pos--;
f01004e3:	83 e8 01             	sub    $0x1,%eax
f01004e6:	66 a3 28 92 22 f0    	mov    %ax,0xf0229228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004ec:	0f b7 c0             	movzwl %ax,%eax
f01004ef:	66 81 e7 00 ff       	and    $0xff00,%di
f01004f4:	83 cf 20             	or     $0x20,%edi
f01004f7:	8b 15 2c 92 22 f0    	mov    0xf022922c,%edx
f01004fd:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100501:	eb 8a                	jmp    f010048d <cons_putc+0xd6>
		crt_pos += CRT_COLS;
f0100503:	66 83 05 28 92 22 f0 	addw   $0x50,0xf0229228
f010050a:	50 
f010050b:	e9 61 ff ff ff       	jmp    f0100471 <cons_putc+0xba>
		cons_putc(' ');
f0100510:	b8 20 00 00 00       	mov    $0x20,%eax
f0100515:	e8 9d fe ff ff       	call   f01003b7 <cons_putc>
		cons_putc(' ');
f010051a:	b8 20 00 00 00       	mov    $0x20,%eax
f010051f:	e8 93 fe ff ff       	call   f01003b7 <cons_putc>
		cons_putc(' ');
f0100524:	b8 20 00 00 00       	mov    $0x20,%eax
f0100529:	e8 89 fe ff ff       	call   f01003b7 <cons_putc>
		cons_putc(' ');
f010052e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100533:	e8 7f fe ff ff       	call   f01003b7 <cons_putc>
		cons_putc(' ');
f0100538:	b8 20 00 00 00       	mov    $0x20,%eax
f010053d:	e8 75 fe ff ff       	call   f01003b7 <cons_putc>
f0100542:	e9 46 ff ff ff       	jmp    f010048d <cons_putc+0xd6>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100547:	0f b7 05 28 92 22 f0 	movzwl 0xf0229228,%eax
f010054e:	8d 50 01             	lea    0x1(%eax),%edx
f0100551:	66 89 15 28 92 22 f0 	mov    %dx,0xf0229228
f0100558:	0f b7 c0             	movzwl %ax,%eax
f010055b:	8b 15 2c 92 22 f0    	mov    0xf022922c,%edx
f0100561:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100565:	e9 23 ff ff ff       	jmp    f010048d <cons_putc+0xd6>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010056a:	a1 2c 92 22 f0       	mov    0xf022922c,%eax
f010056f:	83 ec 04             	sub    $0x4,%esp
f0100572:	68 00 0f 00 00       	push   $0xf00
f0100577:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010057d:	52                   	push   %edx
f010057e:	50                   	push   %eax
f010057f:	e8 e9 3b 00 00       	call   f010416d <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100584:	8b 15 2c 92 22 f0    	mov    0xf022922c,%edx
f010058a:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100590:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100596:	83 c4 10             	add    $0x10,%esp
f0100599:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010059e:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005a1:	39 d0                	cmp    %edx,%eax
f01005a3:	75 f4                	jne    f0100599 <cons_putc+0x1e2>
		crt_pos -= CRT_COLS;
f01005a5:	66 83 2d 28 92 22 f0 	subw   $0x50,0xf0229228
f01005ac:	50 
f01005ad:	e9 ea fe ff ff       	jmp    f010049c <cons_putc+0xe5>

f01005b2 <serial_intr>:
	if (serial_exists)
f01005b2:	80 3d 34 92 22 f0 00 	cmpb   $0x0,0xf0229234
f01005b9:	75 02                	jne    f01005bd <serial_intr+0xb>
f01005bb:	f3 c3                	repz ret 
{
f01005bd:	55                   	push   %ebp
f01005be:	89 e5                	mov    %esp,%ebp
f01005c0:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005c3:	b8 38 02 10 f0       	mov    $0xf0100238,%eax
f01005c8:	e8 8a fc ff ff       	call   f0100257 <cons_intr>
}
f01005cd:	c9                   	leave  
f01005ce:	c3                   	ret    

f01005cf <kbd_intr>:
{
f01005cf:	55                   	push   %ebp
f01005d0:	89 e5                	mov    %esp,%ebp
f01005d2:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005d5:	b8 9a 02 10 f0       	mov    $0xf010029a,%eax
f01005da:	e8 78 fc ff ff       	call   f0100257 <cons_intr>
}
f01005df:	c9                   	leave  
f01005e0:	c3                   	ret    

f01005e1 <cons_getc>:
{
f01005e1:	55                   	push   %ebp
f01005e2:	89 e5                	mov    %esp,%ebp
f01005e4:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01005e7:	e8 c6 ff ff ff       	call   f01005b2 <serial_intr>
	kbd_intr();
f01005ec:	e8 de ff ff ff       	call   f01005cf <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005f1:	8b 15 20 92 22 f0    	mov    0xf0229220,%edx
	return 0;
f01005f7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005fc:	3b 15 24 92 22 f0    	cmp    0xf0229224,%edx
f0100602:	74 18                	je     f010061c <cons_getc+0x3b>
		c = cons.buf[cons.rpos++];
f0100604:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100607:	89 0d 20 92 22 f0    	mov    %ecx,0xf0229220
f010060d:	0f b6 82 20 90 22 f0 	movzbl -0xfdd6fe0(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100614:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f010061a:	74 02                	je     f010061e <cons_getc+0x3d>
}
f010061c:	c9                   	leave  
f010061d:	c3                   	ret    
			cons.rpos = 0;
f010061e:	c7 05 20 92 22 f0 00 	movl   $0x0,0xf0229220
f0100625:	00 00 00 
f0100628:	eb f2                	jmp    f010061c <cons_getc+0x3b>

f010062a <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010062a:	55                   	push   %ebp
f010062b:	89 e5                	mov    %esp,%ebp
f010062d:	57                   	push   %edi
f010062e:	56                   	push   %esi
f010062f:	53                   	push   %ebx
f0100630:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100633:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010063a:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100641:	5a a5 
	if (*cp != 0xA55A) {
f0100643:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010064a:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010064e:	0f 84 d4 00 00 00    	je     f0100728 <cons_init+0xfe>
		addr_6845 = MONO_BASE;
f0100654:	c7 05 30 92 22 f0 b4 	movl   $0x3b4,0xf0229230
f010065b:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010065e:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100663:	8b 3d 30 92 22 f0    	mov    0xf0229230,%edi
f0100669:	b8 0e 00 00 00       	mov    $0xe,%eax
f010066e:	89 fa                	mov    %edi,%edx
f0100670:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100671:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100674:	89 ca                	mov    %ecx,%edx
f0100676:	ec                   	in     (%dx),%al
f0100677:	0f b6 c0             	movzbl %al,%eax
f010067a:	c1 e0 08             	shl    $0x8,%eax
f010067d:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010067f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100684:	89 fa                	mov    %edi,%edx
f0100686:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100687:	89 ca                	mov    %ecx,%edx
f0100689:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010068a:	89 35 2c 92 22 f0    	mov    %esi,0xf022922c
	pos |= inb(addr_6845 + 1);
f0100690:	0f b6 c0             	movzbl %al,%eax
f0100693:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f0100695:	66 a3 28 92 22 f0    	mov    %ax,0xf0229228
	kbd_intr();
f010069b:	e8 2f ff ff ff       	call   f01005cf <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006a0:	83 ec 0c             	sub    $0xc,%esp
f01006a3:	0f b7 05 88 e3 11 f0 	movzwl 0xf011e388,%eax
f01006aa:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006af:	50                   	push   %eax
f01006b0:	e8 85 23 00 00       	call   f0102a3a <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006b5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006ba:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01006bf:	89 d8                	mov    %ebx,%eax
f01006c1:	89 ca                	mov    %ecx,%edx
f01006c3:	ee                   	out    %al,(%dx)
f01006c4:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006c9:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006ce:	89 fa                	mov    %edi,%edx
f01006d0:	ee                   	out    %al,(%dx)
f01006d1:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006d6:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006db:	ee                   	out    %al,(%dx)
f01006dc:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006e1:	89 d8                	mov    %ebx,%eax
f01006e3:	89 f2                	mov    %esi,%edx
f01006e5:	ee                   	out    %al,(%dx)
f01006e6:	b8 03 00 00 00       	mov    $0x3,%eax
f01006eb:	89 fa                	mov    %edi,%edx
f01006ed:	ee                   	out    %al,(%dx)
f01006ee:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006f3:	89 d8                	mov    %ebx,%eax
f01006f5:	ee                   	out    %al,(%dx)
f01006f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01006fb:	89 f2                	mov    %esi,%edx
f01006fd:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fe:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100703:	ec                   	in     (%dx),%al
f0100704:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100706:	83 c4 10             	add    $0x10,%esp
f0100709:	3c ff                	cmp    $0xff,%al
f010070b:	0f 95 05 34 92 22 f0 	setne  0xf0229234
f0100712:	89 ca                	mov    %ecx,%edx
f0100714:	ec                   	in     (%dx),%al
f0100715:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010071a:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010071b:	80 fb ff             	cmp    $0xff,%bl
f010071e:	74 23                	je     f0100743 <cons_init+0x119>
		cprintf("Serial port does not exist!\n");
}
f0100720:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100723:	5b                   	pop    %ebx
f0100724:	5e                   	pop    %esi
f0100725:	5f                   	pop    %edi
f0100726:	5d                   	pop    %ebp
f0100727:	c3                   	ret    
		*cp = was;
f0100728:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010072f:	c7 05 30 92 22 f0 d4 	movl   $0x3d4,0xf0229230
f0100736:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100739:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010073e:	e9 20 ff ff ff       	jmp    f0100663 <cons_init+0x39>
		cprintf("Serial port does not exist!\n");
f0100743:	83 ec 0c             	sub    $0xc,%esp
f0100746:	68 4f 4e 10 f0       	push   $0xf0104e4f
f010074b:	e8 45 24 00 00       	call   f0102b95 <cprintf>
f0100750:	83 c4 10             	add    $0x10,%esp
}
f0100753:	eb cb                	jmp    f0100720 <cons_init+0xf6>

f0100755 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100755:	55                   	push   %ebp
f0100756:	89 e5                	mov    %esp,%ebp
f0100758:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010075b:	8b 45 08             	mov    0x8(%ebp),%eax
f010075e:	e8 54 fc ff ff       	call   f01003b7 <cons_putc>
}
f0100763:	c9                   	leave  
f0100764:	c3                   	ret    

f0100765 <getchar>:

int
getchar(void)
{
f0100765:	55                   	push   %ebp
f0100766:	89 e5                	mov    %esp,%ebp
f0100768:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010076b:	e8 71 fe ff ff       	call   f01005e1 <cons_getc>
f0100770:	85 c0                	test   %eax,%eax
f0100772:	74 f7                	je     f010076b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100774:	c9                   	leave  
f0100775:	c3                   	ret    

f0100776 <iscons>:

int
iscons(int fdnum)
{
f0100776:	55                   	push   %ebp
f0100777:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100779:	b8 01 00 00 00       	mov    $0x1,%eax
f010077e:	5d                   	pop    %ebp
f010077f:	c3                   	ret    

f0100780 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100780:	55                   	push   %ebp
f0100781:	89 e5                	mov    %esp,%ebp
f0100783:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100786:	68 a0 50 10 f0       	push   $0xf01050a0
f010078b:	68 be 50 10 f0       	push   $0xf01050be
f0100790:	68 c3 50 10 f0       	push   $0xf01050c3
f0100795:	e8 fb 23 00 00       	call   f0102b95 <cprintf>
f010079a:	83 c4 0c             	add    $0xc,%esp
f010079d:	68 78 51 10 f0       	push   $0xf0105178
f01007a2:	68 cc 50 10 f0       	push   $0xf01050cc
f01007a7:	68 c3 50 10 f0       	push   $0xf01050c3
f01007ac:	e8 e4 23 00 00       	call   f0102b95 <cprintf>
f01007b1:	83 c4 0c             	add    $0xc,%esp
f01007b4:	68 d5 50 10 f0       	push   $0xf01050d5
f01007b9:	68 ec 50 10 f0       	push   $0xf01050ec
f01007be:	68 c3 50 10 f0       	push   $0xf01050c3
f01007c3:	e8 cd 23 00 00       	call   f0102b95 <cprintf>
	return 0;
}
f01007c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01007cd:	c9                   	leave  
f01007ce:	c3                   	ret    

f01007cf <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007cf:	55                   	push   %ebp
f01007d0:	89 e5                	mov    %esp,%ebp
f01007d2:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d5:	68 f6 50 10 f0       	push   $0xf01050f6
f01007da:	e8 b6 23 00 00       	call   f0102b95 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007df:	83 c4 08             	add    $0x8,%esp
f01007e2:	68 0c 00 10 00       	push   $0x10000c
f01007e7:	68 a0 51 10 f0       	push   $0xf01051a0
f01007ec:	e8 a4 23 00 00       	call   f0102b95 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f1:	83 c4 0c             	add    $0xc,%esp
f01007f4:	68 0c 00 10 00       	push   $0x10000c
f01007f9:	68 0c 00 10 f0       	push   $0xf010000c
f01007fe:	68 c8 51 10 f0       	push   $0xf01051c8
f0100803:	e8 8d 23 00 00       	call   f0102b95 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100808:	83 c4 0c             	add    $0xc,%esp
f010080b:	68 79 4d 10 00       	push   $0x104d79
f0100810:	68 79 4d 10 f0       	push   $0xf0104d79
f0100815:	68 ec 51 10 f0       	push   $0xf01051ec
f010081a:	e8 76 23 00 00       	call   f0102b95 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010081f:	83 c4 0c             	add    $0xc,%esp
f0100822:	68 00 90 22 00       	push   $0x229000
f0100827:	68 00 90 22 f0       	push   $0xf0229000
f010082c:	68 10 52 10 f0       	push   $0xf0105210
f0100831:	e8 5f 23 00 00       	call   f0102b95 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100836:	83 c4 0c             	add    $0xc,%esp
f0100839:	68 08 b0 26 00       	push   $0x26b008
f010083e:	68 08 b0 26 f0       	push   $0xf026b008
f0100843:	68 34 52 10 f0       	push   $0xf0105234
f0100848:	e8 48 23 00 00       	call   f0102b95 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010084d:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100850:	b8 07 b4 26 f0       	mov    $0xf026b407,%eax
f0100855:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085a:	c1 f8 0a             	sar    $0xa,%eax
f010085d:	50                   	push   %eax
f010085e:	68 58 52 10 f0       	push   $0xf0105258
f0100863:	e8 2d 23 00 00       	call   f0102b95 <cprintf>
	return 0;
}
f0100868:	b8 00 00 00 00       	mov    $0x0,%eax
f010086d:	c9                   	leave  
f010086e:	c3                   	ret    

f010086f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010086f:	55                   	push   %ebp
f0100870:	89 e5                	mov    %esp,%ebp
f0100872:	57                   	push   %edi
f0100873:	56                   	push   %esi
f0100874:	53                   	push   %ebx
f0100875:	83 ec 3c             	sub    $0x3c,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100878:	89 ee                	mov    %ebp,%esi
	// Your code here.
	int i;
	uint32_t eip;
	uint32_t* ebp = (uint32_t *)read_ebp();

	while (ebp) {
f010087a:	eb 78                	jmp    f01008f4 <mon_backtrace+0x85>
		eip = *(ebp + 1);
f010087c:	8b 46 04             	mov    0x4(%esi),%eax
f010087f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		cprintf("ebp %x eip %x args", ebp, eip);
f0100882:	83 ec 04             	sub    $0x4,%esp
f0100885:	50                   	push   %eax
f0100886:	56                   	push   %esi
f0100887:	68 0f 51 10 f0       	push   $0xf010510f
f010088c:	e8 04 23 00 00       	call   f0102b95 <cprintf>
f0100891:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100894:	8d 7e 1c             	lea    0x1c(%esi),%edi
f0100897:	83 c4 10             	add    $0x10,%esp
		uint32_t *args = ebp + 2;
		for (i = 0; i < 5; i++) {
			uint32_t argi = args[i];
			cprintf(" %08x ", argi);
f010089a:	83 ec 08             	sub    $0x8,%esp
f010089d:	ff 33                	pushl  (%ebx)
f010089f:	68 22 51 10 f0       	push   $0xf0105122
f01008a4:	e8 ec 22 00 00       	call   f0102b95 <cprintf>
f01008a9:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 5; i++) {
f01008ac:	83 c4 10             	add    $0x10,%esp
f01008af:	39 fb                	cmp    %edi,%ebx
f01008b1:	75 e7                	jne    f010089a <mon_backtrace+0x2b>
		}
		cprintf("\n");
f01008b3:	83 ec 0c             	sub    $0xc,%esp
f01008b6:	68 4d 4e 10 f0       	push   $0xf0104e4d
f01008bb:	e8 d5 22 00 00       	call   f0102b95 <cprintf>

		struct Eipdebuginfo debug_info;
		debuginfo_eip(eip, &debug_info);
f01008c0:	83 c4 08             	add    $0x8,%esp
f01008c3:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008c6:	50                   	push   %eax
f01008c7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01008ca:	57                   	push   %edi
f01008cb:	e8 13 2d 00 00       	call   f01035e3 <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n",
f01008d0:	83 c4 08             	add    $0x8,%esp
f01008d3:	89 f8                	mov    %edi,%eax
f01008d5:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008d8:	50                   	push   %eax
f01008d9:	ff 75 d8             	pushl  -0x28(%ebp)
f01008dc:	ff 75 dc             	pushl  -0x24(%ebp)
f01008df:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008e2:	ff 75 d0             	pushl  -0x30(%ebp)
f01008e5:	68 29 51 10 f0       	push   $0xf0105129
f01008ea:	e8 a6 22 00 00       	call   f0102b95 <cprintf>
			debug_info.eip_file, debug_info.eip_line, debug_info.eip_fn_namelen,
			debug_info.eip_fn_name, eip - debug_info.eip_fn_addr);

		ebp = (uint32_t *) *ebp;
f01008ef:	8b 36                	mov    (%esi),%esi
f01008f1:	83 c4 20             	add    $0x20,%esp
	while (ebp) {
f01008f4:	85 f6                	test   %esi,%esi
f01008f6:	75 84                	jne    f010087c <mon_backtrace+0xd>
		
	}
	return 0;
}
f01008f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01008fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100900:	5b                   	pop    %ebx
f0100901:	5e                   	pop    %esi
f0100902:	5f                   	pop    %edi
f0100903:	5d                   	pop    %ebp
f0100904:	c3                   	ret    

f0100905 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100905:	55                   	push   %ebp
f0100906:	89 e5                	mov    %esp,%ebp
f0100908:	57                   	push   %edi
f0100909:	56                   	push   %esi
f010090a:	53                   	push   %ebx
f010090b:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010090e:	68 84 52 10 f0       	push   $0xf0105284
f0100913:	e8 7d 22 00 00       	call   f0102b95 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100918:	c7 04 24 a8 52 10 f0 	movl   $0xf01052a8,(%esp)
f010091f:	e8 71 22 00 00       	call   f0102b95 <cprintf>

	if (tf != NULL)
f0100924:	83 c4 10             	add    $0x10,%esp
f0100927:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010092b:	74 57                	je     f0100984 <monitor+0x7f>
		print_trapframe(tf);
f010092d:	83 ec 0c             	sub    $0xc,%esp
f0100930:	ff 75 08             	pushl  0x8(%ebp)
f0100933:	e8 1f 26 00 00       	call   f0102f57 <print_trapframe>
f0100938:	83 c4 10             	add    $0x10,%esp
f010093b:	eb 47                	jmp    f0100984 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f010093d:	83 ec 08             	sub    $0x8,%esp
f0100940:	0f be c0             	movsbl %al,%eax
f0100943:	50                   	push   %eax
f0100944:	68 3e 51 10 f0       	push   $0xf010513e
f0100949:	e8 95 37 00 00       	call   f01040e3 <strchr>
f010094e:	83 c4 10             	add    $0x10,%esp
f0100951:	85 c0                	test   %eax,%eax
f0100953:	74 0a                	je     f010095f <monitor+0x5a>
			*buf++ = 0;
f0100955:	c6 03 00             	movb   $0x0,(%ebx)
f0100958:	89 f7                	mov    %esi,%edi
f010095a:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010095d:	eb 6b                	jmp    f01009ca <monitor+0xc5>
		if (*buf == 0)
f010095f:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100962:	74 73                	je     f01009d7 <monitor+0xd2>
		if (argc == MAXARGS-1) {
f0100964:	83 fe 0f             	cmp    $0xf,%esi
f0100967:	74 09                	je     f0100972 <monitor+0x6d>
		argv[argc++] = buf;
f0100969:	8d 7e 01             	lea    0x1(%esi),%edi
f010096c:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100970:	eb 39                	jmp    f01009ab <monitor+0xa6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100972:	83 ec 08             	sub    $0x8,%esp
f0100975:	6a 10                	push   $0x10
f0100977:	68 43 51 10 f0       	push   $0xf0105143
f010097c:	e8 14 22 00 00       	call   f0102b95 <cprintf>
f0100981:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100984:	83 ec 0c             	sub    $0xc,%esp
f0100987:	68 3a 51 10 f0       	push   $0xf010513a
f010098c:	e8 35 35 00 00       	call   f0103ec6 <readline>
f0100991:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100993:	83 c4 10             	add    $0x10,%esp
f0100996:	85 c0                	test   %eax,%eax
f0100998:	74 ea                	je     f0100984 <monitor+0x7f>
	argv[argc] = 0;
f010099a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009a1:	be 00 00 00 00       	mov    $0x0,%esi
f01009a6:	eb 24                	jmp    f01009cc <monitor+0xc7>
			buf++;
f01009a8:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f01009ab:	0f b6 03             	movzbl (%ebx),%eax
f01009ae:	84 c0                	test   %al,%al
f01009b0:	74 18                	je     f01009ca <monitor+0xc5>
f01009b2:	83 ec 08             	sub    $0x8,%esp
f01009b5:	0f be c0             	movsbl %al,%eax
f01009b8:	50                   	push   %eax
f01009b9:	68 3e 51 10 f0       	push   $0xf010513e
f01009be:	e8 20 37 00 00       	call   f01040e3 <strchr>
f01009c3:	83 c4 10             	add    $0x10,%esp
f01009c6:	85 c0                	test   %eax,%eax
f01009c8:	74 de                	je     f01009a8 <monitor+0xa3>
			*buf++ = 0;
f01009ca:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f01009cc:	0f b6 03             	movzbl (%ebx),%eax
f01009cf:	84 c0                	test   %al,%al
f01009d1:	0f 85 66 ff ff ff    	jne    f010093d <monitor+0x38>
	argv[argc] = 0;
f01009d7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009de:	00 
	if (argc == 0)
f01009df:	85 f6                	test   %esi,%esi
f01009e1:	74 a1                	je     f0100984 <monitor+0x7f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009e3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f01009e8:	83 ec 08             	sub    $0x8,%esp
f01009eb:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009ee:	ff 34 85 e0 52 10 f0 	pushl  -0xfefad20(,%eax,4)
f01009f5:	ff 75 a8             	pushl  -0x58(%ebp)
f01009f8:	e8 88 36 00 00       	call   f0104085 <strcmp>
f01009fd:	83 c4 10             	add    $0x10,%esp
f0100a00:	85 c0                	test   %eax,%eax
f0100a02:	74 20                	je     f0100a24 <monitor+0x11f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a04:	83 c3 01             	add    $0x1,%ebx
f0100a07:	83 fb 03             	cmp    $0x3,%ebx
f0100a0a:	75 dc                	jne    f01009e8 <monitor+0xe3>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a0c:	83 ec 08             	sub    $0x8,%esp
f0100a0f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a12:	68 60 51 10 f0       	push   $0xf0105160
f0100a17:	e8 79 21 00 00       	call   f0102b95 <cprintf>
f0100a1c:	83 c4 10             	add    $0x10,%esp
f0100a1f:	e9 60 ff ff ff       	jmp    f0100984 <monitor+0x7f>
			return commands[i].func(argc, argv, tf);
f0100a24:	83 ec 04             	sub    $0x4,%esp
f0100a27:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a2a:	ff 75 08             	pushl  0x8(%ebp)
f0100a2d:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a30:	52                   	push   %edx
f0100a31:	56                   	push   %esi
f0100a32:	ff 14 85 e8 52 10 f0 	call   *-0xfefad18(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a39:	83 c4 10             	add    $0x10,%esp
f0100a3c:	85 c0                	test   %eax,%eax
f0100a3e:	0f 89 40 ff ff ff    	jns    f0100984 <monitor+0x7f>
				break;
	}
}
f0100a44:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a47:	5b                   	pop    %ebx
f0100a48:	5e                   	pop    %esi
f0100a49:	5f                   	pop    %edi
f0100a4a:	5d                   	pop    %ebp
f0100a4b:	c3                   	ret    

f0100a4c <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a4c:	55                   	push   %ebp
f0100a4d:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a4f:	83 3d 38 92 22 f0 00 	cmpl   $0x0,0xf0229238
f0100a56:	74 25                	je     f0100a7d <boot_alloc+0x31>
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
		return nextfree;
f0100a58:	8b 15 38 92 22 f0    	mov    0xf0229238,%edx
	if(n==0)
f0100a5e:	85 c0                	test   %eax,%eax
f0100a60:	74 17                	je     f0100a79 <boot_alloc+0x2d>
	result = nextfree;
f0100a62:	8b 15 38 92 22 f0    	mov    0xf0229238,%edx
	nextfree += n;
	nextfree = ROUNDUP( (char*)nextfree, PGSIZE);	
f0100a68:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100a6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a74:	a3 38 92 22 f0       	mov    %eax,0xf0229238
	 return result;
//	return NULL;
}
f0100a79:	89 d0                	mov    %edx,%eax
f0100a7b:	5d                   	pop    %ebp
f0100a7c:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a7d:	ba 07 c0 26 f0       	mov    $0xf026c007,%edx
f0100a82:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a88:	89 15 38 92 22 f0    	mov    %edx,0xf0229238
f0100a8e:	eb c8                	jmp    f0100a58 <boot_alloc+0xc>

f0100a90 <nvram_read>:
{
f0100a90:	55                   	push   %ebp
f0100a91:	89 e5                	mov    %esp,%ebp
f0100a93:	56                   	push   %esi
f0100a94:	53                   	push   %ebx
f0100a95:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a97:	83 ec 0c             	sub    $0xc,%esp
f0100a9a:	50                   	push   %eax
f0100a9b:	e8 6c 1f 00 00       	call   f0102a0c <mc146818_read>
f0100aa0:	89 c3                	mov    %eax,%ebx
f0100aa2:	83 c6 01             	add    $0x1,%esi
f0100aa5:	89 34 24             	mov    %esi,(%esp)
f0100aa8:	e8 5f 1f 00 00       	call   f0102a0c <mc146818_read>
f0100aad:	c1 e0 08             	shl    $0x8,%eax
f0100ab0:	09 d8                	or     %ebx,%eax
}
f0100ab2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ab5:	5b                   	pop    %ebx
f0100ab6:	5e                   	pop    %esi
f0100ab7:	5d                   	pop    %ebp
f0100ab8:	c3                   	ret    

f0100ab9 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ab9:	2b 05 10 9f 22 f0    	sub    0xf0229f10,%eax
f0100abf:	c1 f8 03             	sar    $0x3,%eax
f0100ac2:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100ac5:	89 c2                	mov    %eax,%edx
f0100ac7:	c1 ea 0c             	shr    $0xc,%edx
f0100aca:	39 15 08 9f 22 f0    	cmp    %edx,0xf0229f08
f0100ad0:	76 06                	jbe    f0100ad8 <page2kva+0x1f>
	return (void *)(pa + KERNBASE);
f0100ad2:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f0100ad7:	c3                   	ret    
{
f0100ad8:	55                   	push   %ebp
f0100ad9:	89 e5                	mov    %esp,%ebp
f0100adb:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ade:	50                   	push   %eax
f0100adf:	68 a4 4d 10 f0       	push   $0xf0104da4
f0100ae4:	6a 58                	push   $0x58
f0100ae6:	68 f5 58 10 f0       	push   $0xf01058f5
f0100aeb:	e8 50 f5 ff ff       	call   f0100040 <_panic>

f0100af0 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100af0:	89 d1                	mov    %edx,%ecx
f0100af2:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100af5:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100af8:	a8 01                	test   $0x1,%al
f0100afa:	74 4f                	je     f0100b4b <check_va2pa+0x5b>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100afc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100b01:	89 c1                	mov    %eax,%ecx
f0100b03:	c1 e9 0c             	shr    $0xc,%ecx
f0100b06:	3b 0d 08 9f 22 f0    	cmp    0xf0229f08,%ecx
f0100b0c:	72 1b                	jb     f0100b29 <check_va2pa+0x39>
{
f0100b0e:	55                   	push   %ebp
f0100b0f:	89 e5                	mov    %esp,%ebp
f0100b11:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b14:	50                   	push   %eax
f0100b15:	68 a4 4d 10 f0       	push   $0xf0104da4
f0100b1a:	68 8b 03 00 00       	push   $0x38b
f0100b1f:	68 03 59 10 f0       	push   $0xf0105903
f0100b24:	e8 17 f5 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100b29:	c1 ea 0c             	shr    $0xc,%edx
f0100b2c:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b32:	8b 94 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%edx
		return ~0;
f0100b39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	if (!(p[PTX(va)] & PTE_P))
f0100b3e:	f6 c2 01             	test   $0x1,%dl
f0100b41:	74 0d                	je     f0100b50 <check_va2pa+0x60>
	return PTE_ADDR(p[PTX(va)]);
f0100b43:	89 d0                	mov    %edx,%eax
f0100b45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b4a:	c3                   	ret    
		return ~0;
f0100b4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b50:	c3                   	ret    

f0100b51 <page_init>:
{
f0100b51:	55                   	push   %ebp
f0100b52:	89 e5                	mov    %esp,%ebp
f0100b54:	53                   	push   %ebx
	for (i = 0; i < npages; i++) {
f0100b55:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100b5a:	eb 33                	jmp    f0100b8f <page_init+0x3e>
		else if(i>=1 && i<npages_basemem)
f0100b5c:	39 1d 44 92 22 f0    	cmp    %ebx,0xf0229244
f0100b62:	76 4e                	jbe    f0100bb2 <page_init+0x61>
f0100b64:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
			pages[i].pp_ref = 0;
f0100b6b:	89 c2                	mov    %eax,%edx
f0100b6d:	03 15 10 9f 22 f0    	add    0xf0229f10,%edx
f0100b73:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list; 
f0100b79:	8b 0d 40 92 22 f0    	mov    0xf0229240,%ecx
f0100b7f:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100b81:	03 05 10 9f 22 f0    	add    0xf0229f10,%eax
f0100b87:	a3 40 92 22 f0       	mov    %eax,0xf0229240
	for (i = 0; i < npages; i++) {
f0100b8c:	83 c3 01             	add    $0x1,%ebx
f0100b8f:	39 1d 08 9f 22 f0    	cmp    %ebx,0xf0229f08
f0100b95:	0f 86 99 00 00 00    	jbe    f0100c34 <page_init+0xe3>
		if(i == 0)
f0100b9b:	85 db                	test   %ebx,%ebx
f0100b9d:	75 bd                	jne    f0100b5c <page_init+0xb>
			{	pages[i].pp_ref = 1;
f0100b9f:	a1 10 9f 22 f0       	mov    0xf0229f10,%eax
f0100ba4:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100baa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100bb0:	eb da                	jmp    f0100b8c <page_init+0x3b>
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100bb2:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0100bb8:	83 f8 5f             	cmp    $0x5f,%eax
f0100bbb:	77 16                	ja     f0100bd3 <page_init+0x82>
			pages[i].pp_ref = 1;
f0100bbd:	a1 10 9f 22 f0       	mov    0xf0229f10,%eax
f0100bc2:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100bc5:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100bcb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100bd1:	eb b9                	jmp    f0100b8c <page_init+0x3b>
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100bd3:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100bd9:	77 2a                	ja     f0100c05 <page_init+0xb4>
f0100bdb:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
			pages[i].pp_ref = 0;
f0100be2:	89 c2                	mov    %eax,%edx
f0100be4:	03 15 10 9f 22 f0    	add    0xf0229f10,%edx
f0100bea:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100bf0:	8b 0d 40 92 22 f0    	mov    0xf0229240,%ecx
f0100bf6:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100bf8:	03 05 10 9f 22 f0    	add    0xf0229f10,%eax
f0100bfe:	a3 40 92 22 f0       	mov    %eax,0xf0229240
f0100c03:	eb 87                	jmp    f0100b8c <page_init+0x3b>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
f0100c05:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c0a:	e8 3d fe ff ff       	call   f0100a4c <boot_alloc>
f0100c0f:	05 00 00 00 10       	add    $0x10000000,%eax
f0100c14:	c1 e8 0c             	shr    $0xc,%eax
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100c17:	39 d8                	cmp    %ebx,%eax
f0100c19:	76 c0                	jbe    f0100bdb <page_init+0x8a>
			pages[i].pp_ref = 1;
f0100c1b:	a1 10 9f 22 f0       	mov    0xf0229f10,%eax
f0100c20:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100c23:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link =NULL;
f0100c29:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100c2f:	e9 58 ff ff ff       	jmp    f0100b8c <page_init+0x3b>
}
f0100c34:	5b                   	pop    %ebx
f0100c35:	5d                   	pop    %ebp
f0100c36:	c3                   	ret    

f0100c37 <page_alloc>:
{
f0100c37:	55                   	push   %ebp
f0100c38:	89 e5                	mov    %esp,%ebp
f0100c3a:	53                   	push   %ebx
f0100c3b:	83 ec 04             	sub    $0x4,%esp
	if(page_free_list == NULL)
f0100c3e:	8b 1d 40 92 22 f0    	mov    0xf0229240,%ebx
f0100c44:	85 db                	test   %ebx,%ebx
f0100c46:	74 13                	je     f0100c5b <page_alloc+0x24>
	page_free_list = page->pp_link;
f0100c48:	8b 03                	mov    (%ebx),%eax
f0100c4a:	a3 40 92 22 f0       	mov    %eax,0xf0229240
	page->pp_link = 0;
f0100c4f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO)
f0100c55:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100c59:	75 07                	jne    f0100c62 <page_alloc+0x2b>
}
f0100c5b:	89 d8                	mov    %ebx,%eax
f0100c5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c60:	c9                   	leave  
f0100c61:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100c62:	89 d8                	mov    %ebx,%eax
f0100c64:	2b 05 10 9f 22 f0    	sub    0xf0229f10,%eax
f0100c6a:	c1 f8 03             	sar    $0x3,%eax
f0100c6d:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100c70:	89 c2                	mov    %eax,%edx
f0100c72:	c1 ea 0c             	shr    $0xc,%edx
f0100c75:	3b 15 08 9f 22 f0    	cmp    0xf0229f08,%edx
f0100c7b:	73 1a                	jae    f0100c97 <page_alloc+0x60>
		memset(page2kva(page), 0, PGSIZE);
f0100c7d:	83 ec 04             	sub    $0x4,%esp
f0100c80:	68 00 10 00 00       	push   $0x1000
f0100c85:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100c87:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c8c:	50                   	push   %eax
f0100c8d:	e8 8e 34 00 00       	call   f0104120 <memset>
f0100c92:	83 c4 10             	add    $0x10,%esp
f0100c95:	eb c4                	jmp    f0100c5b <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c97:	50                   	push   %eax
f0100c98:	68 a4 4d 10 f0       	push   $0xf0104da4
f0100c9d:	6a 58                	push   $0x58
f0100c9f:	68 f5 58 10 f0       	push   $0xf01058f5
f0100ca4:	e8 97 f3 ff ff       	call   f0100040 <_panic>

f0100ca9 <page_free>:
{
f0100ca9:	55                   	push   %ebp
f0100caa:	89 e5                	mov    %esp,%ebp
f0100cac:	83 ec 08             	sub    $0x8,%esp
f0100caf:	8b 45 08             	mov    0x8(%ebp),%eax
	if(pp->pp_link != 0  || pp->pp_ref != 0)
f0100cb2:	83 38 00             	cmpl   $0x0,(%eax)
f0100cb5:	75 16                	jne    f0100ccd <page_free+0x24>
f0100cb7:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100cbc:	75 0f                	jne    f0100ccd <page_free+0x24>
	pp->pp_link = page_free_list;
f0100cbe:	8b 15 40 92 22 f0    	mov    0xf0229240,%edx
f0100cc4:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100cc6:	a3 40 92 22 f0       	mov    %eax,0xf0229240
}
f0100ccb:	c9                   	leave  
f0100ccc:	c3                   	ret    
		panic("page_free is not right");
f0100ccd:	83 ec 04             	sub    $0x4,%esp
f0100cd0:	68 0f 59 10 f0       	push   $0xf010590f
f0100cd5:	68 88 01 00 00       	push   $0x188
f0100cda:	68 03 59 10 f0       	push   $0xf0105903
f0100cdf:	e8 5c f3 ff ff       	call   f0100040 <_panic>

f0100ce4 <page_decref>:
{
f0100ce4:	55                   	push   %ebp
f0100ce5:	89 e5                	mov    %esp,%ebp
f0100ce7:	83 ec 08             	sub    $0x8,%esp
f0100cea:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100ced:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100cf1:	83 e8 01             	sub    $0x1,%eax
f0100cf4:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100cf8:	66 85 c0             	test   %ax,%ax
f0100cfb:	74 02                	je     f0100cff <page_decref+0x1b>
}
f0100cfd:	c9                   	leave  
f0100cfe:	c3                   	ret    
		page_free(pp);
f0100cff:	83 ec 0c             	sub    $0xc,%esp
f0100d02:	52                   	push   %edx
f0100d03:	e8 a1 ff ff ff       	call   f0100ca9 <page_free>
f0100d08:	83 c4 10             	add    $0x10,%esp
}
f0100d0b:	eb f0                	jmp    f0100cfd <page_decref+0x19>

f0100d0d <pgdir_walk>:
{
f0100d0d:	55                   	push   %ebp
f0100d0e:	89 e5                	mov    %esp,%ebp
f0100d10:	56                   	push   %esi
f0100d11:	53                   	push   %ebx
f0100d12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int pte_index = PTX(va);
f0100d15:	89 de                	mov    %ebx,%esi
f0100d17:	c1 ee 0c             	shr    $0xc,%esi
f0100d1a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	int pde_index = PDX(va);
f0100d20:	c1 eb 16             	shr    $0x16,%ebx
    pde_t *pde = &pgdir[pde_index];
f0100d23:	c1 e3 02             	shl    $0x2,%ebx
f0100d26:	03 5d 08             	add    0x8(%ebp),%ebx
    if (!(*pde & PTE_P)) {
f0100d29:	f6 03 01             	testb  $0x1,(%ebx)
f0100d2c:	75 2d                	jne    f0100d5b <pgdir_walk+0x4e>
        if (create) {
f0100d2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100d32:	74 5e                	je     f0100d92 <pgdir_walk+0x85>
            struct PageInfo *page = page_alloc(ALLOC_ZERO);
f0100d34:	83 ec 0c             	sub    $0xc,%esp
f0100d37:	6a 01                	push   $0x1
f0100d39:	e8 f9 fe ff ff       	call   f0100c37 <page_alloc>
            if (!page) return NULL;
f0100d3e:	83 c4 10             	add    $0x10,%esp
f0100d41:	85 c0                	test   %eax,%eax
f0100d43:	74 54                	je     f0100d99 <pgdir_walk+0x8c>
            page->pp_ref++;
f0100d45:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0100d4a:	2b 05 10 9f 22 f0    	sub    0xf0229f10,%eax
f0100d50:	c1 f8 03             	sar    $0x3,%eax
f0100d53:	c1 e0 0c             	shl    $0xc,%eax
            *pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
f0100d56:	83 c8 07             	or     $0x7,%eax
f0100d59:	89 03                	mov    %eax,(%ebx)
    pte_t *p = (pte_t *) KADDR(PTE_ADDR(*pde));
f0100d5b:	8b 03                	mov    (%ebx),%eax
f0100d5d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100d62:	89 c2                	mov    %eax,%edx
f0100d64:	c1 ea 0c             	shr    $0xc,%edx
f0100d67:	3b 15 08 9f 22 f0    	cmp    0xf0229f08,%edx
f0100d6d:	73 0e                	jae    f0100d7d <pgdir_walk+0x70>
    return &p[pte_index];
f0100d6f:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
}
f0100d76:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100d79:	5b                   	pop    %ebx
f0100d7a:	5e                   	pop    %esi
f0100d7b:	5d                   	pop    %ebp
f0100d7c:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d7d:	50                   	push   %eax
f0100d7e:	68 a4 4d 10 f0       	push   $0xf0104da4
f0100d83:	68 c2 01 00 00       	push   $0x1c2
f0100d88:	68 03 59 10 f0       	push   $0xf0105903
f0100d8d:	e8 ae f2 ff ff       	call   f0100040 <_panic>
            return NULL;
f0100d92:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d97:	eb dd                	jmp    f0100d76 <pgdir_walk+0x69>
            if (!page) return NULL;
f0100d99:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d9e:	eb d6                	jmp    f0100d76 <pgdir_walk+0x69>

f0100da0 <page_lookup>:
{
f0100da0:	55                   	push   %ebp
f0100da1:	89 e5                	mov    %esp,%ebp
f0100da3:	53                   	push   %ebx
f0100da4:	83 ec 08             	sub    $0x8,%esp
f0100da7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0100daa:	6a 00                	push   $0x0
f0100dac:	ff 75 0c             	pushl  0xc(%ebp)
f0100daf:	ff 75 08             	pushl  0x8(%ebp)
f0100db2:	e8 56 ff ff ff       	call   f0100d0d <pgdir_walk>
    if (!pte || !(*pte & PTE_P)) {
f0100db7:	83 c4 10             	add    $0x10,%esp
f0100dba:	85 c0                	test   %eax,%eax
f0100dbc:	74 3a                	je     f0100df8 <page_lookup+0x58>
f0100dbe:	f6 00 01             	testb  $0x1,(%eax)
f0100dc1:	74 3c                	je     f0100dff <page_lookup+0x5f>
    if (pte_store) {
f0100dc3:	85 db                	test   %ebx,%ebx
f0100dc5:	74 02                	je     f0100dc9 <page_lookup+0x29>
        *pte_store = pte;
f0100dc7:	89 03                	mov    %eax,(%ebx)
f0100dc9:	8b 00                	mov    (%eax),%eax
f0100dcb:	c1 e8 0c             	shr    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100dce:	39 05 08 9f 22 f0    	cmp    %eax,0xf0229f08
f0100dd4:	76 0e                	jbe    f0100de4 <page_lookup+0x44>
	return &pages[PGNUM(pa)];
f0100dd6:	8b 15 10 9f 22 f0    	mov    0xf0229f10,%edx
f0100ddc:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0100ddf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100de2:	c9                   	leave  
f0100de3:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0100de4:	83 ec 04             	sub    $0x4,%esp
f0100de7:	68 04 53 10 f0       	push   $0xf0105304
f0100dec:	6a 51                	push   $0x51
f0100dee:	68 f5 58 10 f0       	push   $0xf01058f5
f0100df3:	e8 48 f2 ff ff       	call   f0100040 <_panic>
        return NULL;
f0100df8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dfd:	eb e0                	jmp    f0100ddf <page_lookup+0x3f>
f0100dff:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e04:	eb d9                	jmp    f0100ddf <page_lookup+0x3f>

f0100e06 <tlb_invalidate>:
{
f0100e06:	55                   	push   %ebp
f0100e07:	89 e5                	mov    %esp,%ebp
f0100e09:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0100e0c:	e8 32 39 00 00       	call   f0104743 <cpunum>
f0100e11:	6b c0 74             	imul   $0x74,%eax,%eax
f0100e14:	83 b8 28 a0 22 f0 00 	cmpl   $0x0,-0xfdd5fd8(%eax)
f0100e1b:	74 16                	je     f0100e33 <tlb_invalidate+0x2d>
f0100e1d:	e8 21 39 00 00       	call   f0104743 <cpunum>
f0100e22:	6b c0 74             	imul   $0x74,%eax,%eax
f0100e25:	8b 80 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%eax
f0100e2b:	8b 55 08             	mov    0x8(%ebp),%edx
f0100e2e:	39 50 60             	cmp    %edx,0x60(%eax)
f0100e31:	75 06                	jne    f0100e39 <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100e33:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e36:	0f 01 38             	invlpg (%eax)
}
f0100e39:	c9                   	leave  
f0100e3a:	c3                   	ret    

f0100e3b <page_remove>:
{
f0100e3b:	55                   	push   %ebp
f0100e3c:	89 e5                	mov    %esp,%ebp
f0100e3e:	56                   	push   %esi
f0100e3f:	53                   	push   %ebx
f0100e40:	83 ec 14             	sub    $0x14,%esp
f0100e43:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100e46:	8b 75 0c             	mov    0xc(%ebp),%esi
    	struct PageInfo *page = page_lookup(pgdir, va, &pte);
f0100e49:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100e4c:	50                   	push   %eax
f0100e4d:	56                   	push   %esi
f0100e4e:	53                   	push   %ebx
f0100e4f:	e8 4c ff ff ff       	call   f0100da0 <page_lookup>
    	if (!page || !(*pte & PTE_P)) {
f0100e54:	83 c4 10             	add    $0x10,%esp
f0100e57:	85 c0                	test   %eax,%eax
f0100e59:	74 08                	je     f0100e63 <page_remove+0x28>
f0100e5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100e5e:	f6 02 01             	testb  $0x1,(%edx)
f0100e61:	75 07                	jne    f0100e6a <page_remove+0x2f>
}
f0100e63:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e66:	5b                   	pop    %ebx
f0100e67:	5e                   	pop    %esi
f0100e68:	5d                   	pop    %ebp
f0100e69:	c3                   	ret    
    	*pte = 0;
f0100e6a:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    	page_decref(page);
f0100e70:	83 ec 0c             	sub    $0xc,%esp
f0100e73:	50                   	push   %eax
f0100e74:	e8 6b fe ff ff       	call   f0100ce4 <page_decref>
    	tlb_invalidate(pgdir, va);
f0100e79:	83 c4 08             	add    $0x8,%esp
f0100e7c:	56                   	push   %esi
f0100e7d:	53                   	push   %ebx
f0100e7e:	e8 83 ff ff ff       	call   f0100e06 <tlb_invalidate>
f0100e83:	83 c4 10             	add    $0x10,%esp
f0100e86:	eb db                	jmp    f0100e63 <page_remove+0x28>

f0100e88 <page_insert>:
{
f0100e88:	55                   	push   %ebp
f0100e89:	89 e5                	mov    %esp,%ebp
f0100e8b:	57                   	push   %edi
f0100e8c:	56                   	push   %esi
f0100e8d:	53                   	push   %ebx
f0100e8e:	83 ec 10             	sub    $0x10,%esp
f0100e91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100e94:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0100e97:	6a 01                	push   $0x1
f0100e99:	57                   	push   %edi
f0100e9a:	ff 75 08             	pushl  0x8(%ebp)
f0100e9d:	e8 6b fe ff ff       	call   f0100d0d <pgdir_walk>
   	if (!pte) {
f0100ea2:	83 c4 10             	add    $0x10,%esp
f0100ea5:	85 c0                	test   %eax,%eax
f0100ea7:	74 40                	je     f0100ee9 <page_insert+0x61>
f0100ea9:	89 c6                	mov    %eax,%esi
    	pp->pp_ref++;
f0100eab:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
    	if (*pte & PTE_P) {
f0100eb0:	f6 00 01             	testb  $0x1,(%eax)
f0100eb3:	75 23                	jne    f0100ed8 <page_insert+0x50>
	return (pp - pages) << PGSHIFT;
f0100eb5:	2b 1d 10 9f 22 f0    	sub    0xf0229f10,%ebx
f0100ebb:	c1 fb 03             	sar    $0x3,%ebx
f0100ebe:	c1 e3 0c             	shl    $0xc,%ebx
   	*pte = page2pa(pp) | perm | PTE_P;
f0100ec1:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ec4:	83 c8 01             	or     $0x1,%eax
f0100ec7:	09 c3                	or     %eax,%ebx
f0100ec9:	89 1e                	mov    %ebx,(%esi)
    	return 0;
f0100ecb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ed0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ed3:	5b                   	pop    %ebx
f0100ed4:	5e                   	pop    %esi
f0100ed5:	5f                   	pop    %edi
f0100ed6:	5d                   	pop    %ebp
f0100ed7:	c3                   	ret    
        	page_remove(pgdir, va);
f0100ed8:	83 ec 08             	sub    $0x8,%esp
f0100edb:	57                   	push   %edi
f0100edc:	ff 75 08             	pushl  0x8(%ebp)
f0100edf:	e8 57 ff ff ff       	call   f0100e3b <page_remove>
f0100ee4:	83 c4 10             	add    $0x10,%esp
f0100ee7:	eb cc                	jmp    f0100eb5 <page_insert+0x2d>
       	return -E_NO_MEM;
f0100ee9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0100eee:	eb e0                	jmp    f0100ed0 <page_insert+0x48>

f0100ef0 <mmio_map_region>:
{
f0100ef0:	55                   	push   %ebp
f0100ef1:	89 e5                	mov    %esp,%ebp
f0100ef3:	83 ec 0c             	sub    $0xc,%esp
	panic("mmio_map_region not implemented");
f0100ef6:	68 24 53 10 f0       	push   $0xf0105324
f0100efb:	68 71 02 00 00       	push   $0x271
f0100f00:	68 03 59 10 f0       	push   $0xf0105903
f0100f05:	e8 36 f1 ff ff       	call   f0100040 <_panic>

f0100f0a <mem_init>:
{
f0100f0a:	55                   	push   %ebp
f0100f0b:	89 e5                	mov    %esp,%ebp
f0100f0d:	57                   	push   %edi
f0100f0e:	56                   	push   %esi
f0100f0f:	53                   	push   %ebx
f0100f10:	83 ec 2c             	sub    $0x2c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0100f13:	b8 15 00 00 00       	mov    $0x15,%eax
f0100f18:	e8 73 fb ff ff       	call   f0100a90 <nvram_read>
f0100f1d:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100f1f:	b8 17 00 00 00       	mov    $0x17,%eax
f0100f24:	e8 67 fb ff ff       	call   f0100a90 <nvram_read>
f0100f29:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100f2b:	b8 34 00 00 00       	mov    $0x34,%eax
f0100f30:	e8 5b fb ff ff       	call   f0100a90 <nvram_read>
f0100f35:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f0100f38:	85 c0                	test   %eax,%eax
f0100f3a:	75 0e                	jne    f0100f4a <mem_init+0x40>
		totalmem = basemem;
f0100f3c:	89 d8                	mov    %ebx,%eax
	else if (extmem)
f0100f3e:	85 f6                	test   %esi,%esi
f0100f40:	74 0d                	je     f0100f4f <mem_init+0x45>
		totalmem = 1 * 1024 + extmem;
f0100f42:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0100f48:	eb 05                	jmp    f0100f4f <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
f0100f4a:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0100f4f:	89 c2                	mov    %eax,%edx
f0100f51:	c1 ea 02             	shr    $0x2,%edx
f0100f54:	89 15 08 9f 22 f0    	mov    %edx,0xf0229f08
	npages_basemem = basemem / (PGSIZE / 1024);
f0100f5a:	89 da                	mov    %ebx,%edx
f0100f5c:	c1 ea 02             	shr    $0x2,%edx
f0100f5f:	89 15 44 92 22 f0    	mov    %edx,0xf0229244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100f65:	89 c2                	mov    %eax,%edx
f0100f67:	29 da                	sub    %ebx,%edx
f0100f69:	52                   	push   %edx
f0100f6a:	53                   	push   %ebx
f0100f6b:	50                   	push   %eax
f0100f6c:	68 44 53 10 f0       	push   $0xf0105344
f0100f71:	e8 1f 1c 00 00       	call   f0102b95 <cprintf>
	pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);
f0100f76:	a1 08 9f 22 f0       	mov    0xf0229f08,%eax
f0100f7b:	c1 e0 03             	shl    $0x3,%eax
f0100f7e:	e8 c9 fa ff ff       	call   f0100a4c <boot_alloc>
f0100f83:	a3 10 9f 22 f0       	mov    %eax,0xf0229f10
	memset(pages, 0, npages*sizeof(struct PageInfo));
f0100f88:	83 c4 0c             	add    $0xc,%esp
f0100f8b:	8b 35 08 9f 22 f0    	mov    0xf0229f08,%esi
f0100f91:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f0100f98:	52                   	push   %edx
f0100f99:	6a 00                	push   $0x0
f0100f9b:	50                   	push   %eax
f0100f9c:	e8 7f 31 00 00       	call   f0104120 <memset>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100fa1:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100fa6:	e8 a1 fa ff ff       	call   f0100a4c <boot_alloc>
f0100fab:	a3 0c 9f 22 f0       	mov    %eax,0xf0229f0c
	memset(kern_pgdir, 0, PGSIZE);
f0100fb0:	83 c4 0c             	add    $0xc,%esp
f0100fb3:	68 00 10 00 00       	push   $0x1000
f0100fb8:	6a 00                	push   $0x0
f0100fba:	50                   	push   %eax
f0100fbb:	e8 60 31 00 00       	call   f0104120 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100fc0:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0100fc5:	83 c4 10             	add    $0x10,%esp
f0100fc8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100fcd:	77 15                	ja     f0100fe4 <mem_init+0xda>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100fcf:	50                   	push   %eax
f0100fd0:	68 c8 4d 10 f0       	push   $0xf0104dc8
f0100fd5:	68 98 00 00 00       	push   $0x98
f0100fda:	68 03 59 10 f0       	push   $0xf0105903
f0100fdf:	e8 5c f0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100fe4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100fea:	83 ca 05             	or     $0x5,%edx
f0100fed:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f0100ff3:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0100ff8:	e8 4f fa ff ff       	call   f0100a4c <boot_alloc>
f0100ffd:	a3 48 92 22 f0       	mov    %eax,0xf0229248
	memset(envs, 0, sizeof(struct Env) * NENV);
f0101002:	83 ec 04             	sub    $0x4,%esp
f0101005:	68 00 f0 01 00       	push   $0x1f000
f010100a:	6a 00                	push   $0x0
f010100c:	50                   	push   %eax
f010100d:	e8 0e 31 00 00       	call   f0104120 <memset>
	page_init();
f0101012:	e8 3a fb ff ff       	call   f0100b51 <page_init>
	if (!page_free_list)
f0101017:	a1 40 92 22 f0       	mov    0xf0229240,%eax
f010101c:	83 c4 10             	add    $0x10,%esp
f010101f:	85 c0                	test   %eax,%eax
f0101021:	74 4c                	je     f010106f <mem_init+0x165>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101023:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0101026:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101029:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010102c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f010102f:	89 c2                	mov    %eax,%edx
f0101031:	2b 15 10 9f 22 f0    	sub    0xf0229f10,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101037:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f010103d:	0f 95 c2             	setne  %dl
f0101040:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101043:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101047:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101049:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010104d:	8b 00                	mov    (%eax),%eax
f010104f:	85 c0                	test   %eax,%eax
f0101051:	75 dc                	jne    f010102f <mem_init+0x125>
		*tp[1] = 0;
f0101053:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101056:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010105c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010105f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101062:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101064:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0101067:	89 1d 40 92 22 f0    	mov    %ebx,0xf0229240
f010106d:	eb 2b                	jmp    f010109a <mem_init+0x190>
		panic("'page_free_list' is a null pointer!");
f010106f:	83 ec 04             	sub    $0x4,%esp
f0101072:	68 80 53 10 f0       	push   $0xf0105380
f0101077:	68 be 02 00 00       	push   $0x2be
f010107c:	68 03 59 10 f0       	push   $0xf0105903
f0101081:	e8 ba ef ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101086:	52                   	push   %edx
f0101087:	68 a4 4d 10 f0       	push   $0xf0104da4
f010108c:	6a 58                	push   $0x58
f010108e:	68 f5 58 10 f0       	push   $0xf01058f5
f0101093:	e8 a8 ef ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101098:	8b 1b                	mov    (%ebx),%ebx
f010109a:	85 db                	test   %ebx,%ebx
f010109c:	74 42                	je     f01010e0 <mem_init+0x1d6>
	return (pp - pages) << PGSHIFT;
f010109e:	89 d8                	mov    %ebx,%eax
f01010a0:	2b 05 10 9f 22 f0    	sub    0xf0229f10,%eax
f01010a6:	c1 f8 03             	sar    $0x3,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01010a9:	89 c2                	mov    %eax,%edx
f01010ab:	c1 e2 0c             	shl    $0xc,%edx
f01010ae:	a9 00 fc 0f 00       	test   $0xffc00,%eax
f01010b3:	75 e3                	jne    f0101098 <mem_init+0x18e>
	if (PGNUM(pa) >= npages)
f01010b5:	89 d0                	mov    %edx,%eax
f01010b7:	c1 e8 0c             	shr    $0xc,%eax
f01010ba:	3b 05 08 9f 22 f0    	cmp    0xf0229f08,%eax
f01010c0:	73 c4                	jae    f0101086 <mem_init+0x17c>
			memset(page2kva(pp), 0x97, 128);
f01010c2:	83 ec 04             	sub    $0x4,%esp
f01010c5:	68 80 00 00 00       	push   $0x80
f01010ca:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01010cf:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01010d5:	52                   	push   %edx
f01010d6:	e8 45 30 00 00       	call   f0104120 <memset>
f01010db:	83 c4 10             	add    $0x10,%esp
f01010de:	eb b8                	jmp    f0101098 <mem_init+0x18e>
	first_free_page = (char *) boot_alloc(0);
f01010e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01010e5:	e8 62 f9 ff ff       	call   f0100a4c <boot_alloc>
f01010ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010ed:	8b 15 40 92 22 f0    	mov    0xf0229240,%edx
		assert(pp >= pages);
f01010f3:	8b 0d 10 9f 22 f0    	mov    0xf0229f10,%ecx
		assert(pp < pages + npages);
f01010f9:	a1 08 9f 22 f0       	mov    0xf0229f08,%eax
f01010fe:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101101:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0101104:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101107:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f010110a:	be 00 00 00 00       	mov    $0x0,%esi
f010110f:	e9 04 01 00 00       	jmp    f0101218 <mem_init+0x30e>
		assert(pp >= pages);
f0101114:	68 26 59 10 f0       	push   $0xf0105926
f0101119:	68 32 59 10 f0       	push   $0xf0105932
f010111e:	68 d8 02 00 00       	push   $0x2d8
f0101123:	68 03 59 10 f0       	push   $0xf0105903
f0101128:	e8 13 ef ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f010112d:	68 47 59 10 f0       	push   $0xf0105947
f0101132:	68 32 59 10 f0       	push   $0xf0105932
f0101137:	68 d9 02 00 00       	push   $0x2d9
f010113c:	68 03 59 10 f0       	push   $0xf0105903
f0101141:	e8 fa ee ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101146:	68 a4 53 10 f0       	push   $0xf01053a4
f010114b:	68 32 59 10 f0       	push   $0xf0105932
f0101150:	68 da 02 00 00       	push   $0x2da
f0101155:	68 03 59 10 f0       	push   $0xf0105903
f010115a:	e8 e1 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f010115f:	68 5b 59 10 f0       	push   $0xf010595b
f0101164:	68 32 59 10 f0       	push   $0xf0105932
f0101169:	68 dd 02 00 00       	push   $0x2dd
f010116e:	68 03 59 10 f0       	push   $0xf0105903
f0101173:	e8 c8 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101178:	68 6c 59 10 f0       	push   $0xf010596c
f010117d:	68 32 59 10 f0       	push   $0xf0105932
f0101182:	68 de 02 00 00       	push   $0x2de
f0101187:	68 03 59 10 f0       	push   $0xf0105903
f010118c:	e8 af ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101191:	68 d8 53 10 f0       	push   $0xf01053d8
f0101196:	68 32 59 10 f0       	push   $0xf0105932
f010119b:	68 df 02 00 00       	push   $0x2df
f01011a0:	68 03 59 10 f0       	push   $0xf0105903
f01011a5:	e8 96 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01011aa:	68 85 59 10 f0       	push   $0xf0105985
f01011af:	68 32 59 10 f0       	push   $0xf0105932
f01011b4:	68 e0 02 00 00       	push   $0x2e0
f01011b9:	68 03 59 10 f0       	push   $0xf0105903
f01011be:	e8 7d ee ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f01011c3:	89 c7                	mov    %eax,%edi
f01011c5:	c1 ef 0c             	shr    $0xc,%edi
f01011c8:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f01011cb:	76 1b                	jbe    f01011e8 <mem_init+0x2de>
	return (void *)(pa + KERNBASE);
f01011cd:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011d3:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01011d6:	77 22                	ja     f01011fa <mem_init+0x2f0>
		assert(page2pa(pp) != MPENTRY_PADDR);
f01011d8:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01011dd:	0f 84 98 00 00 00    	je     f010127b <mem_init+0x371>
			++nfree_extmem;
f01011e3:	83 c3 01             	add    $0x1,%ebx
f01011e6:	eb 2e                	jmp    f0101216 <mem_init+0x30c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011e8:	50                   	push   %eax
f01011e9:	68 a4 4d 10 f0       	push   $0xf0104da4
f01011ee:	6a 58                	push   $0x58
f01011f0:	68 f5 58 10 f0       	push   $0xf01058f5
f01011f5:	e8 46 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011fa:	68 fc 53 10 f0       	push   $0xf01053fc
f01011ff:	68 32 59 10 f0       	push   $0xf0105932
f0101204:	68 e1 02 00 00       	push   $0x2e1
f0101209:	68 03 59 10 f0       	push   $0xf0105903
f010120e:	e8 2d ee ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0101213:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101216:	8b 12                	mov    (%edx),%edx
f0101218:	85 d2                	test   %edx,%edx
f010121a:	74 78                	je     f0101294 <mem_init+0x38a>
		assert(pp >= pages);
f010121c:	39 d1                	cmp    %edx,%ecx
f010121e:	0f 87 f0 fe ff ff    	ja     f0101114 <mem_init+0x20a>
		assert(pp < pages + npages);
f0101224:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101227:	0f 83 00 ff ff ff    	jae    f010112d <mem_init+0x223>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010122d:	89 d0                	mov    %edx,%eax
f010122f:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101232:	a8 07                	test   $0x7,%al
f0101234:	0f 85 0c ff ff ff    	jne    f0101146 <mem_init+0x23c>
	return (pp - pages) << PGSHIFT;
f010123a:	c1 f8 03             	sar    $0x3,%eax
f010123d:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0101240:	85 c0                	test   %eax,%eax
f0101242:	0f 84 17 ff ff ff    	je     f010115f <mem_init+0x255>
		assert(page2pa(pp) != IOPHYSMEM);
f0101248:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010124d:	0f 84 25 ff ff ff    	je     f0101178 <mem_init+0x26e>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101253:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101258:	0f 84 33 ff ff ff    	je     f0101191 <mem_init+0x287>
		assert(page2pa(pp) != EXTPHYSMEM);
f010125e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101263:	0f 84 41 ff ff ff    	je     f01011aa <mem_init+0x2a0>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101269:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010126e:	0f 87 4f ff ff ff    	ja     f01011c3 <mem_init+0x2b9>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101274:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101279:	75 98                	jne    f0101213 <mem_init+0x309>
f010127b:	68 9f 59 10 f0       	push   $0xf010599f
f0101280:	68 32 59 10 f0       	push   $0xf0105932
f0101285:	68 e3 02 00 00       	push   $0x2e3
f010128a:	68 03 59 10 f0       	push   $0xf0105903
f010128f:	e8 ac ed ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f0101294:	85 f6                	test   %esi,%esi
f0101296:	7e 3e                	jle    f01012d6 <mem_init+0x3cc>
	assert(nfree_extmem > 0);
f0101298:	85 db                	test   %ebx,%ebx
f010129a:	7e 53                	jle    f01012ef <mem_init+0x3e5>
	cprintf("check_page_free_list() succeeded!\n");
f010129c:	83 ec 0c             	sub    $0xc,%esp
f010129f:	68 44 54 10 f0       	push   $0xf0105444
f01012a4:	e8 ec 18 00 00       	call   f0102b95 <cprintf>
	if (!pages)
f01012a9:	83 c4 10             	add    $0x10,%esp
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012ac:	a1 40 92 22 f0       	mov    0xf0229240,%eax
f01012b1:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (!pages)
f01012b6:	83 3d 10 9f 22 f0 00 	cmpl   $0x0,0xf0229f10
f01012bd:	75 4e                	jne    f010130d <mem_init+0x403>
		panic("'pages' is a null pointer!");
f01012bf:	83 ec 04             	sub    $0x4,%esp
f01012c2:	68 df 59 10 f0       	push   $0xf01059df
f01012c7:	68 ff 02 00 00       	push   $0x2ff
f01012cc:	68 03 59 10 f0       	push   $0xf0105903
f01012d1:	e8 6a ed ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f01012d6:	68 bc 59 10 f0       	push   $0xf01059bc
f01012db:	68 32 59 10 f0       	push   $0xf0105932
f01012e0:	68 eb 02 00 00       	push   $0x2eb
f01012e5:	68 03 59 10 f0       	push   $0xf0105903
f01012ea:	e8 51 ed ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f01012ef:	68 ce 59 10 f0       	push   $0xf01059ce
f01012f4:	68 32 59 10 f0       	push   $0xf0105932
f01012f9:	68 ec 02 00 00       	push   $0x2ec
f01012fe:	68 03 59 10 f0       	push   $0xf0105903
f0101303:	e8 38 ed ff ff       	call   f0100040 <_panic>
		++nfree;
f0101308:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010130b:	8b 00                	mov    (%eax),%eax
f010130d:	85 c0                	test   %eax,%eax
f010130f:	75 f7                	jne    f0101308 <mem_init+0x3fe>
	assert((pp0 = page_alloc(0)));
f0101311:	83 ec 0c             	sub    $0xc,%esp
f0101314:	6a 00                	push   $0x0
f0101316:	e8 1c f9 ff ff       	call   f0100c37 <page_alloc>
f010131b:	89 c7                	mov    %eax,%edi
f010131d:	83 c4 10             	add    $0x10,%esp
f0101320:	85 c0                	test   %eax,%eax
f0101322:	0f 84 d5 01 00 00    	je     f01014fd <mem_init+0x5f3>
	assert((pp1 = page_alloc(0)));
f0101328:	83 ec 0c             	sub    $0xc,%esp
f010132b:	6a 00                	push   $0x0
f010132d:	e8 05 f9 ff ff       	call   f0100c37 <page_alloc>
f0101332:	89 c6                	mov    %eax,%esi
f0101334:	83 c4 10             	add    $0x10,%esp
f0101337:	85 c0                	test   %eax,%eax
f0101339:	0f 84 d7 01 00 00    	je     f0101516 <mem_init+0x60c>
	assert((pp2 = page_alloc(0)));
f010133f:	83 ec 0c             	sub    $0xc,%esp
f0101342:	6a 00                	push   $0x0
f0101344:	e8 ee f8 ff ff       	call   f0100c37 <page_alloc>
f0101349:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010134c:	83 c4 10             	add    $0x10,%esp
f010134f:	85 c0                	test   %eax,%eax
f0101351:	0f 84 d8 01 00 00    	je     f010152f <mem_init+0x625>
	assert(pp1 && pp1 != pp0);
f0101357:	39 f7                	cmp    %esi,%edi
f0101359:	0f 84 e9 01 00 00    	je     f0101548 <mem_init+0x63e>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010135f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101362:	39 c7                	cmp    %eax,%edi
f0101364:	0f 84 f7 01 00 00    	je     f0101561 <mem_init+0x657>
f010136a:	39 c6                	cmp    %eax,%esi
f010136c:	0f 84 ef 01 00 00    	je     f0101561 <mem_init+0x657>
f0101372:	8b 0d 10 9f 22 f0    	mov    0xf0229f10,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101378:	8b 15 08 9f 22 f0    	mov    0xf0229f08,%edx
f010137e:	c1 e2 0c             	shl    $0xc,%edx
f0101381:	89 f8                	mov    %edi,%eax
f0101383:	29 c8                	sub    %ecx,%eax
f0101385:	c1 f8 03             	sar    $0x3,%eax
f0101388:	c1 e0 0c             	shl    $0xc,%eax
f010138b:	39 d0                	cmp    %edx,%eax
f010138d:	0f 83 e7 01 00 00    	jae    f010157a <mem_init+0x670>
f0101393:	89 f0                	mov    %esi,%eax
f0101395:	29 c8                	sub    %ecx,%eax
f0101397:	c1 f8 03             	sar    $0x3,%eax
f010139a:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010139d:	39 c2                	cmp    %eax,%edx
f010139f:	0f 86 ee 01 00 00    	jbe    f0101593 <mem_init+0x689>
f01013a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013a8:	29 c8                	sub    %ecx,%eax
f01013aa:	c1 f8 03             	sar    $0x3,%eax
f01013ad:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01013b0:	39 c2                	cmp    %eax,%edx
f01013b2:	0f 86 f4 01 00 00    	jbe    f01015ac <mem_init+0x6a2>
	fl = page_free_list;
f01013b8:	a1 40 92 22 f0       	mov    0xf0229240,%eax
f01013bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01013c0:	c7 05 40 92 22 f0 00 	movl   $0x0,0xf0229240
f01013c7:	00 00 00 
	assert(!page_alloc(0));
f01013ca:	83 ec 0c             	sub    $0xc,%esp
f01013cd:	6a 00                	push   $0x0
f01013cf:	e8 63 f8 ff ff       	call   f0100c37 <page_alloc>
f01013d4:	83 c4 10             	add    $0x10,%esp
f01013d7:	85 c0                	test   %eax,%eax
f01013d9:	0f 85 e6 01 00 00    	jne    f01015c5 <mem_init+0x6bb>
	page_free(pp0);
f01013df:	83 ec 0c             	sub    $0xc,%esp
f01013e2:	57                   	push   %edi
f01013e3:	e8 c1 f8 ff ff       	call   f0100ca9 <page_free>
	page_free(pp1);
f01013e8:	89 34 24             	mov    %esi,(%esp)
f01013eb:	e8 b9 f8 ff ff       	call   f0100ca9 <page_free>
	page_free(pp2);
f01013f0:	83 c4 04             	add    $0x4,%esp
f01013f3:	ff 75 d4             	pushl  -0x2c(%ebp)
f01013f6:	e8 ae f8 ff ff       	call   f0100ca9 <page_free>
	assert((pp0 = page_alloc(0)));
f01013fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101402:	e8 30 f8 ff ff       	call   f0100c37 <page_alloc>
f0101407:	89 c6                	mov    %eax,%esi
f0101409:	83 c4 10             	add    $0x10,%esp
f010140c:	85 c0                	test   %eax,%eax
f010140e:	0f 84 ca 01 00 00    	je     f01015de <mem_init+0x6d4>
	assert((pp1 = page_alloc(0)));
f0101414:	83 ec 0c             	sub    $0xc,%esp
f0101417:	6a 00                	push   $0x0
f0101419:	e8 19 f8 ff ff       	call   f0100c37 <page_alloc>
f010141e:	89 c7                	mov    %eax,%edi
f0101420:	83 c4 10             	add    $0x10,%esp
f0101423:	85 c0                	test   %eax,%eax
f0101425:	0f 84 cc 01 00 00    	je     f01015f7 <mem_init+0x6ed>
	assert((pp2 = page_alloc(0)));
f010142b:	83 ec 0c             	sub    $0xc,%esp
f010142e:	6a 00                	push   $0x0
f0101430:	e8 02 f8 ff ff       	call   f0100c37 <page_alloc>
f0101435:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101438:	83 c4 10             	add    $0x10,%esp
f010143b:	85 c0                	test   %eax,%eax
f010143d:	0f 84 cd 01 00 00    	je     f0101610 <mem_init+0x706>
	assert(pp1 && pp1 != pp0);
f0101443:	39 fe                	cmp    %edi,%esi
f0101445:	0f 84 de 01 00 00    	je     f0101629 <mem_init+0x71f>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010144b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010144e:	39 c6                	cmp    %eax,%esi
f0101450:	0f 84 ec 01 00 00    	je     f0101642 <mem_init+0x738>
f0101456:	39 c7                	cmp    %eax,%edi
f0101458:	0f 84 e4 01 00 00    	je     f0101642 <mem_init+0x738>
	assert(!page_alloc(0));
f010145e:	83 ec 0c             	sub    $0xc,%esp
f0101461:	6a 00                	push   $0x0
f0101463:	e8 cf f7 ff ff       	call   f0100c37 <page_alloc>
f0101468:	83 c4 10             	add    $0x10,%esp
f010146b:	85 c0                	test   %eax,%eax
f010146d:	0f 85 e8 01 00 00    	jne    f010165b <mem_init+0x751>
	memset(page2kva(pp0), 1, PGSIZE);
f0101473:	89 f0                	mov    %esi,%eax
f0101475:	e8 3f f6 ff ff       	call   f0100ab9 <page2kva>
f010147a:	83 ec 04             	sub    $0x4,%esp
f010147d:	68 00 10 00 00       	push   $0x1000
f0101482:	6a 01                	push   $0x1
f0101484:	50                   	push   %eax
f0101485:	e8 96 2c 00 00       	call   f0104120 <memset>
	page_free(pp0);
f010148a:	89 34 24             	mov    %esi,(%esp)
f010148d:	e8 17 f8 ff ff       	call   f0100ca9 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101492:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101499:	e8 99 f7 ff ff       	call   f0100c37 <page_alloc>
f010149e:	83 c4 10             	add    $0x10,%esp
f01014a1:	85 c0                	test   %eax,%eax
f01014a3:	0f 84 cb 01 00 00    	je     f0101674 <mem_init+0x76a>
	assert(pp && pp0 == pp);
f01014a9:	39 c6                	cmp    %eax,%esi
f01014ab:	0f 85 dc 01 00 00    	jne    f010168d <mem_init+0x783>
	c = page2kva(pp);
f01014b1:	e8 03 f6 ff ff       	call   f0100ab9 <page2kva>
f01014b6:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		assert(c[i] == 0);
f01014bc:	80 38 00             	cmpb   $0x0,(%eax)
f01014bf:	0f 85 e1 01 00 00    	jne    f01016a6 <mem_init+0x79c>
f01014c5:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f01014c8:	39 c2                	cmp    %eax,%edx
f01014ca:	75 f0                	jne    f01014bc <mem_init+0x5b2>
	page_free_list = fl;
f01014cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01014cf:	a3 40 92 22 f0       	mov    %eax,0xf0229240
	page_free(pp0);
f01014d4:	83 ec 0c             	sub    $0xc,%esp
f01014d7:	56                   	push   %esi
f01014d8:	e8 cc f7 ff ff       	call   f0100ca9 <page_free>
	page_free(pp1);
f01014dd:	89 3c 24             	mov    %edi,(%esp)
f01014e0:	e8 c4 f7 ff ff       	call   f0100ca9 <page_free>
	page_free(pp2);
f01014e5:	83 c4 04             	add    $0x4,%esp
f01014e8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01014eb:	e8 b9 f7 ff ff       	call   f0100ca9 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01014f0:	a1 40 92 22 f0       	mov    0xf0229240,%eax
f01014f5:	83 c4 10             	add    $0x10,%esp
f01014f8:	e9 c7 01 00 00       	jmp    f01016c4 <mem_init+0x7ba>
	assert((pp0 = page_alloc(0)));
f01014fd:	68 fa 59 10 f0       	push   $0xf01059fa
f0101502:	68 32 59 10 f0       	push   $0xf0105932
f0101507:	68 07 03 00 00       	push   $0x307
f010150c:	68 03 59 10 f0       	push   $0xf0105903
f0101511:	e8 2a eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101516:	68 10 5a 10 f0       	push   $0xf0105a10
f010151b:	68 32 59 10 f0       	push   $0xf0105932
f0101520:	68 08 03 00 00       	push   $0x308
f0101525:	68 03 59 10 f0       	push   $0xf0105903
f010152a:	e8 11 eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010152f:	68 26 5a 10 f0       	push   $0xf0105a26
f0101534:	68 32 59 10 f0       	push   $0xf0105932
f0101539:	68 09 03 00 00       	push   $0x309
f010153e:	68 03 59 10 f0       	push   $0xf0105903
f0101543:	e8 f8 ea ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101548:	68 3c 5a 10 f0       	push   $0xf0105a3c
f010154d:	68 32 59 10 f0       	push   $0xf0105932
f0101552:	68 0c 03 00 00       	push   $0x30c
f0101557:	68 03 59 10 f0       	push   $0xf0105903
f010155c:	e8 df ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101561:	68 68 54 10 f0       	push   $0xf0105468
f0101566:	68 32 59 10 f0       	push   $0xf0105932
f010156b:	68 0d 03 00 00       	push   $0x30d
f0101570:	68 03 59 10 f0       	push   $0xf0105903
f0101575:	e8 c6 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010157a:	68 4e 5a 10 f0       	push   $0xf0105a4e
f010157f:	68 32 59 10 f0       	push   $0xf0105932
f0101584:	68 0e 03 00 00       	push   $0x30e
f0101589:	68 03 59 10 f0       	push   $0xf0105903
f010158e:	e8 ad ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101593:	68 6b 5a 10 f0       	push   $0xf0105a6b
f0101598:	68 32 59 10 f0       	push   $0xf0105932
f010159d:	68 0f 03 00 00       	push   $0x30f
f01015a2:	68 03 59 10 f0       	push   $0xf0105903
f01015a7:	e8 94 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01015ac:	68 88 5a 10 f0       	push   $0xf0105a88
f01015b1:	68 32 59 10 f0       	push   $0xf0105932
f01015b6:	68 10 03 00 00       	push   $0x310
f01015bb:	68 03 59 10 f0       	push   $0xf0105903
f01015c0:	e8 7b ea ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01015c5:	68 a5 5a 10 f0       	push   $0xf0105aa5
f01015ca:	68 32 59 10 f0       	push   $0xf0105932
f01015cf:	68 17 03 00 00       	push   $0x317
f01015d4:	68 03 59 10 f0       	push   $0xf0105903
f01015d9:	e8 62 ea ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01015de:	68 fa 59 10 f0       	push   $0xf01059fa
f01015e3:	68 32 59 10 f0       	push   $0xf0105932
f01015e8:	68 1e 03 00 00       	push   $0x31e
f01015ed:	68 03 59 10 f0       	push   $0xf0105903
f01015f2:	e8 49 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015f7:	68 10 5a 10 f0       	push   $0xf0105a10
f01015fc:	68 32 59 10 f0       	push   $0xf0105932
f0101601:	68 1f 03 00 00       	push   $0x31f
f0101606:	68 03 59 10 f0       	push   $0xf0105903
f010160b:	e8 30 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101610:	68 26 5a 10 f0       	push   $0xf0105a26
f0101615:	68 32 59 10 f0       	push   $0xf0105932
f010161a:	68 20 03 00 00       	push   $0x320
f010161f:	68 03 59 10 f0       	push   $0xf0105903
f0101624:	e8 17 ea ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101629:	68 3c 5a 10 f0       	push   $0xf0105a3c
f010162e:	68 32 59 10 f0       	push   $0xf0105932
f0101633:	68 22 03 00 00       	push   $0x322
f0101638:	68 03 59 10 f0       	push   $0xf0105903
f010163d:	e8 fe e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101642:	68 68 54 10 f0       	push   $0xf0105468
f0101647:	68 32 59 10 f0       	push   $0xf0105932
f010164c:	68 23 03 00 00       	push   $0x323
f0101651:	68 03 59 10 f0       	push   $0xf0105903
f0101656:	e8 e5 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010165b:	68 a5 5a 10 f0       	push   $0xf0105aa5
f0101660:	68 32 59 10 f0       	push   $0xf0105932
f0101665:	68 24 03 00 00       	push   $0x324
f010166a:	68 03 59 10 f0       	push   $0xf0105903
f010166f:	e8 cc e9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101674:	68 b4 5a 10 f0       	push   $0xf0105ab4
f0101679:	68 32 59 10 f0       	push   $0xf0105932
f010167e:	68 29 03 00 00       	push   $0x329
f0101683:	68 03 59 10 f0       	push   $0xf0105903
f0101688:	e8 b3 e9 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010168d:	68 d2 5a 10 f0       	push   $0xf0105ad2
f0101692:	68 32 59 10 f0       	push   $0xf0105932
f0101697:	68 2a 03 00 00       	push   $0x32a
f010169c:	68 03 59 10 f0       	push   $0xf0105903
f01016a1:	e8 9a e9 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f01016a6:	68 e2 5a 10 f0       	push   $0xf0105ae2
f01016ab:	68 32 59 10 f0       	push   $0xf0105932
f01016b0:	68 2d 03 00 00       	push   $0x32d
f01016b5:	68 03 59 10 f0       	push   $0xf0105903
f01016ba:	e8 81 e9 ff ff       	call   f0100040 <_panic>
		--nfree;
f01016bf:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016c2:	8b 00                	mov    (%eax),%eax
f01016c4:	85 c0                	test   %eax,%eax
f01016c6:	75 f7                	jne    f01016bf <mem_init+0x7b5>
	assert(nfree == 0);
f01016c8:	85 db                	test   %ebx,%ebx
f01016ca:	75 75                	jne    f0101741 <mem_init+0x837>
	cprintf("check_page_alloc() succeeded!\n");
f01016cc:	83 ec 0c             	sub    $0xc,%esp
f01016cf:	68 88 54 10 f0       	push   $0xf0105488
f01016d4:	e8 bc 14 00 00       	call   f0102b95 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016e0:	e8 52 f5 ff ff       	call   f0100c37 <page_alloc>
f01016e5:	89 c3                	mov    %eax,%ebx
f01016e7:	83 c4 10             	add    $0x10,%esp
f01016ea:	85 c0                	test   %eax,%eax
f01016ec:	74 6c                	je     f010175a <mem_init+0x850>
	assert((pp1 = page_alloc(0)));
f01016ee:	83 ec 0c             	sub    $0xc,%esp
f01016f1:	6a 00                	push   $0x0
f01016f3:	e8 3f f5 ff ff       	call   f0100c37 <page_alloc>
f01016f8:	89 c6                	mov    %eax,%esi
f01016fa:	83 c4 10             	add    $0x10,%esp
f01016fd:	85 c0                	test   %eax,%eax
f01016ff:	74 72                	je     f0101773 <mem_init+0x869>
	assert((pp2 = page_alloc(0)));
f0101701:	83 ec 0c             	sub    $0xc,%esp
f0101704:	6a 00                	push   $0x0
f0101706:	e8 2c f5 ff ff       	call   f0100c37 <page_alloc>
f010170b:	89 c7                	mov    %eax,%edi
f010170d:	83 c4 10             	add    $0x10,%esp
f0101710:	85 c0                	test   %eax,%eax
f0101712:	74 78                	je     f010178c <mem_init+0x882>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101714:	39 f3                	cmp    %esi,%ebx
f0101716:	0f 84 89 00 00 00    	je     f01017a5 <mem_init+0x89b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010171c:	39 c3                	cmp    %eax,%ebx
f010171e:	74 08                	je     f0101728 <mem_init+0x81e>
f0101720:	39 c6                	cmp    %eax,%esi
f0101722:	0f 85 96 00 00 00    	jne    f01017be <mem_init+0x8b4>
f0101728:	68 68 54 10 f0       	push   $0xf0105468
f010172d:	68 32 59 10 f0       	push   $0xf0105932
f0101732:	68 a6 03 00 00       	push   $0x3a6
f0101737:	68 03 59 10 f0       	push   $0xf0105903
f010173c:	e8 ff e8 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f0101741:	68 ec 5a 10 f0       	push   $0xf0105aec
f0101746:	68 32 59 10 f0       	push   $0xf0105932
f010174b:	68 3a 03 00 00       	push   $0x33a
f0101750:	68 03 59 10 f0       	push   $0xf0105903
f0101755:	e8 e6 e8 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010175a:	68 fa 59 10 f0       	push   $0xf01059fa
f010175f:	68 32 59 10 f0       	push   $0xf0105932
f0101764:	68 a0 03 00 00       	push   $0x3a0
f0101769:	68 03 59 10 f0       	push   $0xf0105903
f010176e:	e8 cd e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101773:	68 10 5a 10 f0       	push   $0xf0105a10
f0101778:	68 32 59 10 f0       	push   $0xf0105932
f010177d:	68 a1 03 00 00       	push   $0x3a1
f0101782:	68 03 59 10 f0       	push   $0xf0105903
f0101787:	e8 b4 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010178c:	68 26 5a 10 f0       	push   $0xf0105a26
f0101791:	68 32 59 10 f0       	push   $0xf0105932
f0101796:	68 a2 03 00 00       	push   $0x3a2
f010179b:	68 03 59 10 f0       	push   $0xf0105903
f01017a0:	e8 9b e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01017a5:	68 3c 5a 10 f0       	push   $0xf0105a3c
f01017aa:	68 32 59 10 f0       	push   $0xf0105932
f01017af:	68 a5 03 00 00       	push   $0x3a5
f01017b4:	68 03 59 10 f0       	push   $0xf0105903
f01017b9:	e8 82 e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017be:	a1 40 92 22 f0       	mov    0xf0229240,%eax
f01017c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01017c6:	c7 05 40 92 22 f0 00 	movl   $0x0,0xf0229240
f01017cd:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01017d0:	83 ec 0c             	sub    $0xc,%esp
f01017d3:	6a 00                	push   $0x0
f01017d5:	e8 5d f4 ff ff       	call   f0100c37 <page_alloc>
f01017da:	83 c4 10             	add    $0x10,%esp
f01017dd:	85 c0                	test   %eax,%eax
f01017df:	74 19                	je     f01017fa <mem_init+0x8f0>
f01017e1:	68 a5 5a 10 f0       	push   $0xf0105aa5
f01017e6:	68 32 59 10 f0       	push   $0xf0105932
f01017eb:	68 ad 03 00 00       	push   $0x3ad
f01017f0:	68 03 59 10 f0       	push   $0xf0105903
f01017f5:	e8 46 e8 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01017fa:	83 ec 04             	sub    $0x4,%esp
f01017fd:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101800:	50                   	push   %eax
f0101801:	6a 00                	push   $0x0
f0101803:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f0101809:	e8 92 f5 ff ff       	call   f0100da0 <page_lookup>
f010180e:	83 c4 10             	add    $0x10,%esp
f0101811:	85 c0                	test   %eax,%eax
f0101813:	74 19                	je     f010182e <mem_init+0x924>
f0101815:	68 a8 54 10 f0       	push   $0xf01054a8
f010181a:	68 32 59 10 f0       	push   $0xf0105932
f010181f:	68 b0 03 00 00       	push   $0x3b0
f0101824:	68 03 59 10 f0       	push   $0xf0105903
f0101829:	e8 12 e8 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010182e:	6a 02                	push   $0x2
f0101830:	6a 00                	push   $0x0
f0101832:	56                   	push   %esi
f0101833:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f0101839:	e8 4a f6 ff ff       	call   f0100e88 <page_insert>
f010183e:	83 c4 10             	add    $0x10,%esp
f0101841:	85 c0                	test   %eax,%eax
f0101843:	78 19                	js     f010185e <mem_init+0x954>
f0101845:	68 e0 54 10 f0       	push   $0xf01054e0
f010184a:	68 32 59 10 f0       	push   $0xf0105932
f010184f:	68 b3 03 00 00       	push   $0x3b3
f0101854:	68 03 59 10 f0       	push   $0xf0105903
f0101859:	e8 e2 e7 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010185e:	83 ec 0c             	sub    $0xc,%esp
f0101861:	53                   	push   %ebx
f0101862:	e8 42 f4 ff ff       	call   f0100ca9 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101867:	6a 02                	push   $0x2
f0101869:	6a 00                	push   $0x0
f010186b:	56                   	push   %esi
f010186c:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f0101872:	e8 11 f6 ff ff       	call   f0100e88 <page_insert>
f0101877:	83 c4 20             	add    $0x20,%esp
f010187a:	85 c0                	test   %eax,%eax
f010187c:	74 19                	je     f0101897 <mem_init+0x98d>
f010187e:	68 10 55 10 f0       	push   $0xf0105510
f0101883:	68 32 59 10 f0       	push   $0xf0105932
f0101888:	68 b7 03 00 00       	push   $0x3b7
f010188d:	68 03 59 10 f0       	push   $0xf0105903
f0101892:	e8 a9 e7 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101897:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
f010189c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010189f:	8b 0d 10 9f 22 f0    	mov    0xf0229f10,%ecx
f01018a5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01018a8:	8b 00                	mov    (%eax),%eax
f01018aa:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01018ad:	89 c2                	mov    %eax,%edx
f01018af:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018b5:	89 d8                	mov    %ebx,%eax
f01018b7:	29 c8                	sub    %ecx,%eax
f01018b9:	c1 f8 03             	sar    $0x3,%eax
f01018bc:	c1 e0 0c             	shl    $0xc,%eax
f01018bf:	39 c2                	cmp    %eax,%edx
f01018c1:	74 19                	je     f01018dc <mem_init+0x9d2>
f01018c3:	68 40 55 10 f0       	push   $0xf0105540
f01018c8:	68 32 59 10 f0       	push   $0xf0105932
f01018cd:	68 b8 03 00 00       	push   $0x3b8
f01018d2:	68 03 59 10 f0       	push   $0xf0105903
f01018d7:	e8 64 e7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01018dc:	ba 00 00 00 00       	mov    $0x0,%edx
f01018e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018e4:	e8 07 f2 ff ff       	call   f0100af0 <check_va2pa>
f01018e9:	89 f2                	mov    %esi,%edx
f01018eb:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01018ee:	c1 fa 03             	sar    $0x3,%edx
f01018f1:	c1 e2 0c             	shl    $0xc,%edx
f01018f4:	39 d0                	cmp    %edx,%eax
f01018f6:	74 19                	je     f0101911 <mem_init+0xa07>
f01018f8:	68 68 55 10 f0       	push   $0xf0105568
f01018fd:	68 32 59 10 f0       	push   $0xf0105932
f0101902:	68 b9 03 00 00       	push   $0x3b9
f0101907:	68 03 59 10 f0       	push   $0xf0105903
f010190c:	e8 2f e7 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101911:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101916:	74 19                	je     f0101931 <mem_init+0xa27>
f0101918:	68 f7 5a 10 f0       	push   $0xf0105af7
f010191d:	68 32 59 10 f0       	push   $0xf0105932
f0101922:	68 ba 03 00 00       	push   $0x3ba
f0101927:	68 03 59 10 f0       	push   $0xf0105903
f010192c:	e8 0f e7 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101931:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101936:	74 19                	je     f0101951 <mem_init+0xa47>
f0101938:	68 08 5b 10 f0       	push   $0xf0105b08
f010193d:	68 32 59 10 f0       	push   $0xf0105932
f0101942:	68 bb 03 00 00       	push   $0x3bb
f0101947:	68 03 59 10 f0       	push   $0xf0105903
f010194c:	e8 ef e6 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101951:	6a 02                	push   $0x2
f0101953:	68 00 10 00 00       	push   $0x1000
f0101958:	57                   	push   %edi
f0101959:	ff 75 d4             	pushl  -0x2c(%ebp)
f010195c:	e8 27 f5 ff ff       	call   f0100e88 <page_insert>
f0101961:	83 c4 10             	add    $0x10,%esp
f0101964:	85 c0                	test   %eax,%eax
f0101966:	74 19                	je     f0101981 <mem_init+0xa77>
f0101968:	68 98 55 10 f0       	push   $0xf0105598
f010196d:	68 32 59 10 f0       	push   $0xf0105932
f0101972:	68 be 03 00 00       	push   $0x3be
f0101977:	68 03 59 10 f0       	push   $0xf0105903
f010197c:	e8 bf e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101981:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101986:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
f010198b:	e8 60 f1 ff ff       	call   f0100af0 <check_va2pa>
f0101990:	89 fa                	mov    %edi,%edx
f0101992:	2b 15 10 9f 22 f0    	sub    0xf0229f10,%edx
f0101998:	c1 fa 03             	sar    $0x3,%edx
f010199b:	c1 e2 0c             	shl    $0xc,%edx
f010199e:	39 d0                	cmp    %edx,%eax
f01019a0:	74 19                	je     f01019bb <mem_init+0xab1>
f01019a2:	68 d4 55 10 f0       	push   $0xf01055d4
f01019a7:	68 32 59 10 f0       	push   $0xf0105932
f01019ac:	68 bf 03 00 00       	push   $0x3bf
f01019b1:	68 03 59 10 f0       	push   $0xf0105903
f01019b6:	e8 85 e6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01019bb:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01019c0:	74 19                	je     f01019db <mem_init+0xad1>
f01019c2:	68 19 5b 10 f0       	push   $0xf0105b19
f01019c7:	68 32 59 10 f0       	push   $0xf0105932
f01019cc:	68 c0 03 00 00       	push   $0x3c0
f01019d1:	68 03 59 10 f0       	push   $0xf0105903
f01019d6:	e8 65 e6 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01019db:	83 ec 0c             	sub    $0xc,%esp
f01019de:	6a 00                	push   $0x0
f01019e0:	e8 52 f2 ff ff       	call   f0100c37 <page_alloc>
f01019e5:	83 c4 10             	add    $0x10,%esp
f01019e8:	85 c0                	test   %eax,%eax
f01019ea:	74 19                	je     f0101a05 <mem_init+0xafb>
f01019ec:	68 a5 5a 10 f0       	push   $0xf0105aa5
f01019f1:	68 32 59 10 f0       	push   $0xf0105932
f01019f6:	68 c3 03 00 00       	push   $0x3c3
f01019fb:	68 03 59 10 f0       	push   $0xf0105903
f0101a00:	e8 3b e6 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a05:	6a 02                	push   $0x2
f0101a07:	68 00 10 00 00       	push   $0x1000
f0101a0c:	57                   	push   %edi
f0101a0d:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f0101a13:	e8 70 f4 ff ff       	call   f0100e88 <page_insert>
f0101a18:	83 c4 10             	add    $0x10,%esp
f0101a1b:	85 c0                	test   %eax,%eax
f0101a1d:	74 19                	je     f0101a38 <mem_init+0xb2e>
f0101a1f:	68 98 55 10 f0       	push   $0xf0105598
f0101a24:	68 32 59 10 f0       	push   $0xf0105932
f0101a29:	68 c6 03 00 00       	push   $0x3c6
f0101a2e:	68 03 59 10 f0       	push   $0xf0105903
f0101a33:	e8 08 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a38:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a3d:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
f0101a42:	e8 a9 f0 ff ff       	call   f0100af0 <check_va2pa>
f0101a47:	89 fa                	mov    %edi,%edx
f0101a49:	2b 15 10 9f 22 f0    	sub    0xf0229f10,%edx
f0101a4f:	c1 fa 03             	sar    $0x3,%edx
f0101a52:	c1 e2 0c             	shl    $0xc,%edx
f0101a55:	39 d0                	cmp    %edx,%eax
f0101a57:	74 19                	je     f0101a72 <mem_init+0xb68>
f0101a59:	68 d4 55 10 f0       	push   $0xf01055d4
f0101a5e:	68 32 59 10 f0       	push   $0xf0105932
f0101a63:	68 c7 03 00 00       	push   $0x3c7
f0101a68:	68 03 59 10 f0       	push   $0xf0105903
f0101a6d:	e8 ce e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101a72:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a77:	74 19                	je     f0101a92 <mem_init+0xb88>
f0101a79:	68 19 5b 10 f0       	push   $0xf0105b19
f0101a7e:	68 32 59 10 f0       	push   $0xf0105932
f0101a83:	68 c8 03 00 00       	push   $0x3c8
f0101a88:	68 03 59 10 f0       	push   $0xf0105903
f0101a8d:	e8 ae e5 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a92:	83 ec 0c             	sub    $0xc,%esp
f0101a95:	6a 00                	push   $0x0
f0101a97:	e8 9b f1 ff ff       	call   f0100c37 <page_alloc>
f0101a9c:	83 c4 10             	add    $0x10,%esp
f0101a9f:	85 c0                	test   %eax,%eax
f0101aa1:	74 19                	je     f0101abc <mem_init+0xbb2>
f0101aa3:	68 a5 5a 10 f0       	push   $0xf0105aa5
f0101aa8:	68 32 59 10 f0       	push   $0xf0105932
f0101aad:	68 cc 03 00 00       	push   $0x3cc
f0101ab2:	68 03 59 10 f0       	push   $0xf0105903
f0101ab7:	e8 84 e5 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101abc:	8b 15 0c 9f 22 f0    	mov    0xf0229f0c,%edx
f0101ac2:	8b 02                	mov    (%edx),%eax
f0101ac4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101ac9:	89 c1                	mov    %eax,%ecx
f0101acb:	c1 e9 0c             	shr    $0xc,%ecx
f0101ace:	3b 0d 08 9f 22 f0    	cmp    0xf0229f08,%ecx
f0101ad4:	72 15                	jb     f0101aeb <mem_init+0xbe1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ad6:	50                   	push   %eax
f0101ad7:	68 a4 4d 10 f0       	push   $0xf0104da4
f0101adc:	68 cf 03 00 00       	push   $0x3cf
f0101ae1:	68 03 59 10 f0       	push   $0xf0105903
f0101ae6:	e8 55 e5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101aeb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101af0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101af3:	83 ec 04             	sub    $0x4,%esp
f0101af6:	6a 00                	push   $0x0
f0101af8:	68 00 10 00 00       	push   $0x1000
f0101afd:	52                   	push   %edx
f0101afe:	e8 0a f2 ff ff       	call   f0100d0d <pgdir_walk>
f0101b03:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101b06:	8d 51 04             	lea    0x4(%ecx),%edx
f0101b09:	83 c4 10             	add    $0x10,%esp
f0101b0c:	39 d0                	cmp    %edx,%eax
f0101b0e:	74 19                	je     f0101b29 <mem_init+0xc1f>
f0101b10:	68 04 56 10 f0       	push   $0xf0105604
f0101b15:	68 32 59 10 f0       	push   $0xf0105932
f0101b1a:	68 d0 03 00 00       	push   $0x3d0
f0101b1f:	68 03 59 10 f0       	push   $0xf0105903
f0101b24:	e8 17 e5 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b29:	6a 06                	push   $0x6
f0101b2b:	68 00 10 00 00       	push   $0x1000
f0101b30:	57                   	push   %edi
f0101b31:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f0101b37:	e8 4c f3 ff ff       	call   f0100e88 <page_insert>
f0101b3c:	83 c4 10             	add    $0x10,%esp
f0101b3f:	85 c0                	test   %eax,%eax
f0101b41:	74 19                	je     f0101b5c <mem_init+0xc52>
f0101b43:	68 44 56 10 f0       	push   $0xf0105644
f0101b48:	68 32 59 10 f0       	push   $0xf0105932
f0101b4d:	68 d3 03 00 00       	push   $0x3d3
f0101b52:	68 03 59 10 f0       	push   $0xf0105903
f0101b57:	e8 e4 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b5c:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
f0101b61:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b64:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b69:	e8 82 ef ff ff       	call   f0100af0 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101b6e:	89 fa                	mov    %edi,%edx
f0101b70:	2b 15 10 9f 22 f0    	sub    0xf0229f10,%edx
f0101b76:	c1 fa 03             	sar    $0x3,%edx
f0101b79:	c1 e2 0c             	shl    $0xc,%edx
f0101b7c:	39 d0                	cmp    %edx,%eax
f0101b7e:	74 19                	je     f0101b99 <mem_init+0xc8f>
f0101b80:	68 d4 55 10 f0       	push   $0xf01055d4
f0101b85:	68 32 59 10 f0       	push   $0xf0105932
f0101b8a:	68 d4 03 00 00       	push   $0x3d4
f0101b8f:	68 03 59 10 f0       	push   $0xf0105903
f0101b94:	e8 a7 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b99:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b9e:	74 19                	je     f0101bb9 <mem_init+0xcaf>
f0101ba0:	68 19 5b 10 f0       	push   $0xf0105b19
f0101ba5:	68 32 59 10 f0       	push   $0xf0105932
f0101baa:	68 d5 03 00 00       	push   $0x3d5
f0101baf:	68 03 59 10 f0       	push   $0xf0105903
f0101bb4:	e8 87 e4 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101bb9:	83 ec 04             	sub    $0x4,%esp
f0101bbc:	6a 00                	push   $0x0
f0101bbe:	68 00 10 00 00       	push   $0x1000
f0101bc3:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bc6:	e8 42 f1 ff ff       	call   f0100d0d <pgdir_walk>
f0101bcb:	83 c4 10             	add    $0x10,%esp
f0101bce:	f6 00 04             	testb  $0x4,(%eax)
f0101bd1:	75 19                	jne    f0101bec <mem_init+0xce2>
f0101bd3:	68 84 56 10 f0       	push   $0xf0105684
f0101bd8:	68 32 59 10 f0       	push   $0xf0105932
f0101bdd:	68 d6 03 00 00       	push   $0x3d6
f0101be2:	68 03 59 10 f0       	push   $0xf0105903
f0101be7:	e8 54 e4 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101bec:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
f0101bf1:	f6 00 04             	testb  $0x4,(%eax)
f0101bf4:	75 19                	jne    f0101c0f <mem_init+0xd05>
f0101bf6:	68 2a 5b 10 f0       	push   $0xf0105b2a
f0101bfb:	68 32 59 10 f0       	push   $0xf0105932
f0101c00:	68 d7 03 00 00       	push   $0x3d7
f0101c05:	68 03 59 10 f0       	push   $0xf0105903
f0101c0a:	e8 31 e4 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c0f:	6a 02                	push   $0x2
f0101c11:	68 00 10 00 00       	push   $0x1000
f0101c16:	57                   	push   %edi
f0101c17:	50                   	push   %eax
f0101c18:	e8 6b f2 ff ff       	call   f0100e88 <page_insert>
f0101c1d:	83 c4 10             	add    $0x10,%esp
f0101c20:	85 c0                	test   %eax,%eax
f0101c22:	74 19                	je     f0101c3d <mem_init+0xd33>
f0101c24:	68 98 55 10 f0       	push   $0xf0105598
f0101c29:	68 32 59 10 f0       	push   $0xf0105932
f0101c2e:	68 da 03 00 00       	push   $0x3da
f0101c33:	68 03 59 10 f0       	push   $0xf0105903
f0101c38:	e8 03 e4 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c3d:	83 ec 04             	sub    $0x4,%esp
f0101c40:	6a 00                	push   $0x0
f0101c42:	68 00 10 00 00       	push   $0x1000
f0101c47:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f0101c4d:	e8 bb f0 ff ff       	call   f0100d0d <pgdir_walk>
f0101c52:	83 c4 10             	add    $0x10,%esp
f0101c55:	f6 00 02             	testb  $0x2,(%eax)
f0101c58:	75 19                	jne    f0101c73 <mem_init+0xd69>
f0101c5a:	68 b8 56 10 f0       	push   $0xf01056b8
f0101c5f:	68 32 59 10 f0       	push   $0xf0105932
f0101c64:	68 db 03 00 00       	push   $0x3db
f0101c69:	68 03 59 10 f0       	push   $0xf0105903
f0101c6e:	e8 cd e3 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c73:	83 ec 04             	sub    $0x4,%esp
f0101c76:	6a 00                	push   $0x0
f0101c78:	68 00 10 00 00       	push   $0x1000
f0101c7d:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f0101c83:	e8 85 f0 ff ff       	call   f0100d0d <pgdir_walk>
f0101c88:	83 c4 10             	add    $0x10,%esp
f0101c8b:	f6 00 04             	testb  $0x4,(%eax)
f0101c8e:	74 19                	je     f0101ca9 <mem_init+0xd9f>
f0101c90:	68 ec 56 10 f0       	push   $0xf01056ec
f0101c95:	68 32 59 10 f0       	push   $0xf0105932
f0101c9a:	68 dc 03 00 00       	push   $0x3dc
f0101c9f:	68 03 59 10 f0       	push   $0xf0105903
f0101ca4:	e8 97 e3 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ca9:	6a 02                	push   $0x2
f0101cab:	68 00 00 40 00       	push   $0x400000
f0101cb0:	53                   	push   %ebx
f0101cb1:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f0101cb7:	e8 cc f1 ff ff       	call   f0100e88 <page_insert>
f0101cbc:	83 c4 10             	add    $0x10,%esp
f0101cbf:	85 c0                	test   %eax,%eax
f0101cc1:	78 19                	js     f0101cdc <mem_init+0xdd2>
f0101cc3:	68 24 57 10 f0       	push   $0xf0105724
f0101cc8:	68 32 59 10 f0       	push   $0xf0105932
f0101ccd:	68 df 03 00 00       	push   $0x3df
f0101cd2:	68 03 59 10 f0       	push   $0xf0105903
f0101cd7:	e8 64 e3 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101cdc:	6a 02                	push   $0x2
f0101cde:	68 00 10 00 00       	push   $0x1000
f0101ce3:	56                   	push   %esi
f0101ce4:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f0101cea:	e8 99 f1 ff ff       	call   f0100e88 <page_insert>
f0101cef:	83 c4 10             	add    $0x10,%esp
f0101cf2:	85 c0                	test   %eax,%eax
f0101cf4:	74 19                	je     f0101d0f <mem_init+0xe05>
f0101cf6:	68 5c 57 10 f0       	push   $0xf010575c
f0101cfb:	68 32 59 10 f0       	push   $0xf0105932
f0101d00:	68 e2 03 00 00       	push   $0x3e2
f0101d05:	68 03 59 10 f0       	push   $0xf0105903
f0101d0a:	e8 31 e3 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d0f:	83 ec 04             	sub    $0x4,%esp
f0101d12:	6a 00                	push   $0x0
f0101d14:	68 00 10 00 00       	push   $0x1000
f0101d19:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f0101d1f:	e8 e9 ef ff ff       	call   f0100d0d <pgdir_walk>
f0101d24:	83 c4 10             	add    $0x10,%esp
f0101d27:	f6 00 04             	testb  $0x4,(%eax)
f0101d2a:	74 19                	je     f0101d45 <mem_init+0xe3b>
f0101d2c:	68 ec 56 10 f0       	push   $0xf01056ec
f0101d31:	68 32 59 10 f0       	push   $0xf0105932
f0101d36:	68 e3 03 00 00       	push   $0x3e3
f0101d3b:	68 03 59 10 f0       	push   $0xf0105903
f0101d40:	e8 fb e2 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d45:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
f0101d4a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d4d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d52:	e8 99 ed ff ff       	call   f0100af0 <check_va2pa>
f0101d57:	89 c1                	mov    %eax,%ecx
f0101d59:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d5c:	89 f0                	mov    %esi,%eax
f0101d5e:	2b 05 10 9f 22 f0    	sub    0xf0229f10,%eax
f0101d64:	c1 f8 03             	sar    $0x3,%eax
f0101d67:	c1 e0 0c             	shl    $0xc,%eax
f0101d6a:	39 c1                	cmp    %eax,%ecx
f0101d6c:	74 19                	je     f0101d87 <mem_init+0xe7d>
f0101d6e:	68 98 57 10 f0       	push   $0xf0105798
f0101d73:	68 32 59 10 f0       	push   $0xf0105932
f0101d78:	68 e6 03 00 00       	push   $0x3e6
f0101d7d:	68 03 59 10 f0       	push   $0xf0105903
f0101d82:	e8 b9 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d87:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d8c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d8f:	e8 5c ed ff ff       	call   f0100af0 <check_va2pa>
f0101d94:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101d97:	74 19                	je     f0101db2 <mem_init+0xea8>
f0101d99:	68 c4 57 10 f0       	push   $0xf01057c4
f0101d9e:	68 32 59 10 f0       	push   $0xf0105932
f0101da3:	68 e7 03 00 00       	push   $0x3e7
f0101da8:	68 03 59 10 f0       	push   $0xf0105903
f0101dad:	e8 8e e2 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101db2:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0101db7:	74 19                	je     f0101dd2 <mem_init+0xec8>
f0101db9:	68 40 5b 10 f0       	push   $0xf0105b40
f0101dbe:	68 32 59 10 f0       	push   $0xf0105932
f0101dc3:	68 e9 03 00 00       	push   $0x3e9
f0101dc8:	68 03 59 10 f0       	push   $0xf0105903
f0101dcd:	e8 6e e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101dd2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101dd7:	74 19                	je     f0101df2 <mem_init+0xee8>
f0101dd9:	68 51 5b 10 f0       	push   $0xf0105b51
f0101dde:	68 32 59 10 f0       	push   $0xf0105932
f0101de3:	68 ea 03 00 00       	push   $0x3ea
f0101de8:	68 03 59 10 f0       	push   $0xf0105903
f0101ded:	e8 4e e2 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101df2:	83 ec 0c             	sub    $0xc,%esp
f0101df5:	6a 00                	push   $0x0
f0101df7:	e8 3b ee ff ff       	call   f0100c37 <page_alloc>
f0101dfc:	83 c4 10             	add    $0x10,%esp
f0101dff:	85 c0                	test   %eax,%eax
f0101e01:	74 04                	je     f0101e07 <mem_init+0xefd>
f0101e03:	39 c7                	cmp    %eax,%edi
f0101e05:	74 19                	je     f0101e20 <mem_init+0xf16>
f0101e07:	68 f4 57 10 f0       	push   $0xf01057f4
f0101e0c:	68 32 59 10 f0       	push   $0xf0105932
f0101e11:	68 ed 03 00 00       	push   $0x3ed
f0101e16:	68 03 59 10 f0       	push   $0xf0105903
f0101e1b:	e8 20 e2 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e20:	83 ec 08             	sub    $0x8,%esp
f0101e23:	6a 00                	push   $0x0
f0101e25:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f0101e2b:	e8 0b f0 ff ff       	call   f0100e3b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e30:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
f0101e35:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101e38:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e3d:	e8 ae ec ff ff       	call   f0100af0 <check_va2pa>
f0101e42:	83 c4 10             	add    $0x10,%esp
f0101e45:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e48:	74 19                	je     f0101e63 <mem_init+0xf59>
f0101e4a:	68 18 58 10 f0       	push   $0xf0105818
f0101e4f:	68 32 59 10 f0       	push   $0xf0105932
f0101e54:	68 f1 03 00 00       	push   $0x3f1
f0101e59:	68 03 59 10 f0       	push   $0xf0105903
f0101e5e:	e8 dd e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e63:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e68:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e6b:	e8 80 ec ff ff       	call   f0100af0 <check_va2pa>
f0101e70:	89 f2                	mov    %esi,%edx
f0101e72:	2b 15 10 9f 22 f0    	sub    0xf0229f10,%edx
f0101e78:	c1 fa 03             	sar    $0x3,%edx
f0101e7b:	c1 e2 0c             	shl    $0xc,%edx
f0101e7e:	39 d0                	cmp    %edx,%eax
f0101e80:	74 19                	je     f0101e9b <mem_init+0xf91>
f0101e82:	68 c4 57 10 f0       	push   $0xf01057c4
f0101e87:	68 32 59 10 f0       	push   $0xf0105932
f0101e8c:	68 f2 03 00 00       	push   $0x3f2
f0101e91:	68 03 59 10 f0       	push   $0xf0105903
f0101e96:	e8 a5 e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101e9b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ea0:	74 19                	je     f0101ebb <mem_init+0xfb1>
f0101ea2:	68 f7 5a 10 f0       	push   $0xf0105af7
f0101ea7:	68 32 59 10 f0       	push   $0xf0105932
f0101eac:	68 f3 03 00 00       	push   $0x3f3
f0101eb1:	68 03 59 10 f0       	push   $0xf0105903
f0101eb6:	e8 85 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101ebb:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101ec0:	74 19                	je     f0101edb <mem_init+0xfd1>
f0101ec2:	68 51 5b 10 f0       	push   $0xf0105b51
f0101ec7:	68 32 59 10 f0       	push   $0xf0105932
f0101ecc:	68 f4 03 00 00       	push   $0x3f4
f0101ed1:	68 03 59 10 f0       	push   $0xf0105903
f0101ed6:	e8 65 e1 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101edb:	6a 00                	push   $0x0
f0101edd:	68 00 10 00 00       	push   $0x1000
f0101ee2:	56                   	push   %esi
f0101ee3:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ee6:	e8 9d ef ff ff       	call   f0100e88 <page_insert>
f0101eeb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101eee:	83 c4 10             	add    $0x10,%esp
f0101ef1:	85 c0                	test   %eax,%eax
f0101ef3:	74 19                	je     f0101f0e <mem_init+0x1004>
f0101ef5:	68 3c 58 10 f0       	push   $0xf010583c
f0101efa:	68 32 59 10 f0       	push   $0xf0105932
f0101eff:	68 f7 03 00 00       	push   $0x3f7
f0101f04:	68 03 59 10 f0       	push   $0xf0105903
f0101f09:	e8 32 e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0101f0e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f13:	75 19                	jne    f0101f2e <mem_init+0x1024>
f0101f15:	68 62 5b 10 f0       	push   $0xf0105b62
f0101f1a:	68 32 59 10 f0       	push   $0xf0105932
f0101f1f:	68 f8 03 00 00       	push   $0x3f8
f0101f24:	68 03 59 10 f0       	push   $0xf0105903
f0101f29:	e8 12 e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0101f2e:	83 3e 00             	cmpl   $0x0,(%esi)
f0101f31:	74 19                	je     f0101f4c <mem_init+0x1042>
f0101f33:	68 6e 5b 10 f0       	push   $0xf0105b6e
f0101f38:	68 32 59 10 f0       	push   $0xf0105932
f0101f3d:	68 f9 03 00 00       	push   $0x3f9
f0101f42:	68 03 59 10 f0       	push   $0xf0105903
f0101f47:	e8 f4 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f4c:	83 ec 08             	sub    $0x8,%esp
f0101f4f:	68 00 10 00 00       	push   $0x1000
f0101f54:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f0101f5a:	e8 dc ee ff ff       	call   f0100e3b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f5f:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
f0101f64:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f67:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f6c:	e8 7f eb ff ff       	call   f0100af0 <check_va2pa>
f0101f71:	83 c4 10             	add    $0x10,%esp
f0101f74:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f77:	74 19                	je     f0101f92 <mem_init+0x1088>
f0101f79:	68 18 58 10 f0       	push   $0xf0105818
f0101f7e:	68 32 59 10 f0       	push   $0xf0105932
f0101f83:	68 fd 03 00 00       	push   $0x3fd
f0101f88:	68 03 59 10 f0       	push   $0xf0105903
f0101f8d:	e8 ae e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f92:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f9a:	e8 51 eb ff ff       	call   f0100af0 <check_va2pa>
f0101f9f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fa2:	74 19                	je     f0101fbd <mem_init+0x10b3>
f0101fa4:	68 74 58 10 f0       	push   $0xf0105874
f0101fa9:	68 32 59 10 f0       	push   $0xf0105932
f0101fae:	68 fe 03 00 00       	push   $0x3fe
f0101fb3:	68 03 59 10 f0       	push   $0xf0105903
f0101fb8:	e8 83 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0101fbd:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fc2:	74 19                	je     f0101fdd <mem_init+0x10d3>
f0101fc4:	68 83 5b 10 f0       	push   $0xf0105b83
f0101fc9:	68 32 59 10 f0       	push   $0xf0105932
f0101fce:	68 ff 03 00 00       	push   $0x3ff
f0101fd3:	68 03 59 10 f0       	push   $0xf0105903
f0101fd8:	e8 63 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101fdd:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101fe2:	74 19                	je     f0101ffd <mem_init+0x10f3>
f0101fe4:	68 51 5b 10 f0       	push   $0xf0105b51
f0101fe9:	68 32 59 10 f0       	push   $0xf0105932
f0101fee:	68 00 04 00 00       	push   $0x400
f0101ff3:	68 03 59 10 f0       	push   $0xf0105903
f0101ff8:	e8 43 e0 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101ffd:	83 ec 0c             	sub    $0xc,%esp
f0102000:	6a 00                	push   $0x0
f0102002:	e8 30 ec ff ff       	call   f0100c37 <page_alloc>
f0102007:	83 c4 10             	add    $0x10,%esp
f010200a:	39 c6                	cmp    %eax,%esi
f010200c:	75 04                	jne    f0102012 <mem_init+0x1108>
f010200e:	85 c0                	test   %eax,%eax
f0102010:	75 19                	jne    f010202b <mem_init+0x1121>
f0102012:	68 9c 58 10 f0       	push   $0xf010589c
f0102017:	68 32 59 10 f0       	push   $0xf0105932
f010201c:	68 03 04 00 00       	push   $0x403
f0102021:	68 03 59 10 f0       	push   $0xf0105903
f0102026:	e8 15 e0 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010202b:	83 ec 0c             	sub    $0xc,%esp
f010202e:	6a 00                	push   $0x0
f0102030:	e8 02 ec ff ff       	call   f0100c37 <page_alloc>
f0102035:	83 c4 10             	add    $0x10,%esp
f0102038:	85 c0                	test   %eax,%eax
f010203a:	74 19                	je     f0102055 <mem_init+0x114b>
f010203c:	68 a5 5a 10 f0       	push   $0xf0105aa5
f0102041:	68 32 59 10 f0       	push   $0xf0105932
f0102046:	68 06 04 00 00       	push   $0x406
f010204b:	68 03 59 10 f0       	push   $0xf0105903
f0102050:	e8 eb df ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102055:	8b 0d 0c 9f 22 f0    	mov    0xf0229f0c,%ecx
f010205b:	8b 11                	mov    (%ecx),%edx
f010205d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102063:	89 d8                	mov    %ebx,%eax
f0102065:	2b 05 10 9f 22 f0    	sub    0xf0229f10,%eax
f010206b:	c1 f8 03             	sar    $0x3,%eax
f010206e:	c1 e0 0c             	shl    $0xc,%eax
f0102071:	39 c2                	cmp    %eax,%edx
f0102073:	74 19                	je     f010208e <mem_init+0x1184>
f0102075:	68 40 55 10 f0       	push   $0xf0105540
f010207a:	68 32 59 10 f0       	push   $0xf0105932
f010207f:	68 09 04 00 00       	push   $0x409
f0102084:	68 03 59 10 f0       	push   $0xf0105903
f0102089:	e8 b2 df ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010208e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102094:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102099:	74 19                	je     f01020b4 <mem_init+0x11aa>
f010209b:	68 08 5b 10 f0       	push   $0xf0105b08
f01020a0:	68 32 59 10 f0       	push   $0xf0105932
f01020a5:	68 0b 04 00 00       	push   $0x40b
f01020aa:	68 03 59 10 f0       	push   $0xf0105903
f01020af:	e8 8c df ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01020b4:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01020ba:	83 ec 0c             	sub    $0xc,%esp
f01020bd:	53                   	push   %ebx
f01020be:	e8 e6 eb ff ff       	call   f0100ca9 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01020c3:	83 c4 0c             	add    $0xc,%esp
f01020c6:	6a 01                	push   $0x1
f01020c8:	68 00 10 40 00       	push   $0x401000
f01020cd:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f01020d3:	e8 35 ec ff ff       	call   f0100d0d <pgdir_walk>
f01020d8:	89 c1                	mov    %eax,%ecx
f01020da:	89 45 e0             	mov    %eax,-0x20(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01020dd:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
f01020e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01020e5:	8b 40 04             	mov    0x4(%eax),%eax
f01020e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01020ed:	89 c2                	mov    %eax,%edx
f01020ef:	c1 ea 0c             	shr    $0xc,%edx
f01020f2:	83 c4 10             	add    $0x10,%esp
f01020f5:	3b 15 08 9f 22 f0    	cmp    0xf0229f08,%edx
f01020fb:	72 15                	jb     f0102112 <mem_init+0x1208>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020fd:	50                   	push   %eax
f01020fe:	68 a4 4d 10 f0       	push   $0xf0104da4
f0102103:	68 12 04 00 00       	push   $0x412
f0102108:	68 03 59 10 f0       	push   $0xf0105903
f010210d:	e8 2e df ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102112:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102117:	39 c1                	cmp    %eax,%ecx
f0102119:	74 19                	je     f0102134 <mem_init+0x122a>
f010211b:	68 94 5b 10 f0       	push   $0xf0105b94
f0102120:	68 32 59 10 f0       	push   $0xf0105932
f0102125:	68 13 04 00 00       	push   $0x413
f010212a:	68 03 59 10 f0       	push   $0xf0105903
f010212f:	e8 0c df ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102134:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102137:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010213e:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102144:	89 d8                	mov    %ebx,%eax
f0102146:	e8 6e e9 ff ff       	call   f0100ab9 <page2kva>
f010214b:	83 ec 04             	sub    $0x4,%esp
f010214e:	68 00 10 00 00       	push   $0x1000
f0102153:	68 ff 00 00 00       	push   $0xff
f0102158:	50                   	push   %eax
f0102159:	e8 c2 1f 00 00       	call   f0104120 <memset>
	page_free(pp0);
f010215e:	89 1c 24             	mov    %ebx,(%esp)
f0102161:	e8 43 eb ff ff       	call   f0100ca9 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102166:	83 c4 0c             	add    $0xc,%esp
f0102169:	6a 01                	push   $0x1
f010216b:	6a 00                	push   $0x0
f010216d:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f0102173:	e8 95 eb ff ff       	call   f0100d0d <pgdir_walk>
	ptep = (pte_t *) page2kva(pp0);
f0102178:	89 d8                	mov    %ebx,%eax
f010217a:	e8 3a e9 ff ff       	call   f0100ab9 <page2kva>
f010217f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102182:	83 c4 10             	add    $0x10,%esp
f0102185:	8b 55 cc             	mov    -0x34(%ebp),%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102188:	f6 04 90 01          	testb  $0x1,(%eax,%edx,4)
f010218c:	74 19                	je     f01021a7 <mem_init+0x129d>
f010218e:	68 ac 5b 10 f0       	push   $0xf0105bac
f0102193:	68 32 59 10 f0       	push   $0xf0105932
f0102198:	68 1d 04 00 00       	push   $0x41d
f010219d:	68 03 59 10 f0       	push   $0xf0105903
f01021a2:	e8 99 de ff ff       	call   f0100040 <_panic>
	for(i=0; i<NPTENTRIES; i++)
f01021a7:	83 c2 01             	add    $0x1,%edx
f01021aa:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f01021b0:	75 d6                	jne    f0102188 <mem_init+0x127e>
	kern_pgdir[0] = 0;
f01021b2:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
f01021b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01021bd:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// give free list back
	page_free_list = fl;
f01021c3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01021c6:	a3 40 92 22 f0       	mov    %eax,0xf0229240

	// free the pages we took
	page_free(pp0);
f01021cb:	83 ec 0c             	sub    $0xc,%esp
f01021ce:	53                   	push   %ebx
f01021cf:	e8 d5 ea ff ff       	call   f0100ca9 <page_free>
	page_free(pp1);
f01021d4:	89 34 24             	mov    %esi,(%esp)
f01021d7:	e8 cd ea ff ff       	call   f0100ca9 <page_free>
	page_free(pp2);
f01021dc:	89 3c 24             	mov    %edi,(%esp)
f01021df:	e8 c5 ea ff ff       	call   f0100ca9 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01021e4:	83 c4 08             	add    $0x8,%esp
f01021e7:	68 01 10 00 00       	push   $0x1001
f01021ec:	6a 00                	push   $0x0
f01021ee:	e8 fd ec ff ff       	call   f0100ef0 <mmio_map_region>

f01021f3 <user_mem_check>:
{
f01021f3:	55                   	push   %ebp
f01021f4:	89 e5                	mov    %esp,%ebp
f01021f6:	57                   	push   %edi
f01021f7:	56                   	push   %esi
f01021f8:	53                   	push   %ebx
f01021f9:	83 ec 0c             	sub    $0xc,%esp
	uint32_t begin = (uint32_t)ROUNDDOWN(va, PGSIZE), end = (uint32_t)ROUNDUP(va + len, PGSIZE);
f01021fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01021ff:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102205:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102208:	03 7d 10             	add    0x10(%ebp),%edi
f010220b:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0102211:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    int check_perm = (perm | PTE_P);
f0102217:	8b 75 14             	mov    0x14(%ebp),%esi
f010221a:	83 ce 01             	or     $0x1,%esi
    for (; begin < end; begin += PGSIZE) {
f010221d:	39 fb                	cmp    %edi,%ebx
f010221f:	73 4a                	jae    f010226b <user_mem_check+0x78>
        pte_t *pte = pgdir_walk(env->env_pgdir, (void *)begin, 0);
f0102221:	83 ec 04             	sub    $0x4,%esp
f0102224:	6a 00                	push   $0x0
f0102226:	53                   	push   %ebx
f0102227:	8b 45 08             	mov    0x8(%ebp),%eax
f010222a:	ff 70 60             	pushl  0x60(%eax)
f010222d:	e8 db ea ff ff       	call   f0100d0d <pgdir_walk>
        if ((begin >= ULIM) || !pte || (*pte & check_perm) != check_perm) {
f0102232:	83 c4 10             	add    $0x10,%esp
f0102235:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010223b:	77 14                	ja     f0102251 <user_mem_check+0x5e>
f010223d:	85 c0                	test   %eax,%eax
f010223f:	74 10                	je     f0102251 <user_mem_check+0x5e>
f0102241:	89 f2                	mov    %esi,%edx
f0102243:	23 10                	and    (%eax),%edx
f0102245:	39 d6                	cmp    %edx,%esi
f0102247:	75 08                	jne    f0102251 <user_mem_check+0x5e>
    for (; begin < end; begin += PGSIZE) {
f0102249:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010224f:	eb cc                	jmp    f010221d <user_mem_check+0x2a>
            user_mem_check_addr = (begin >= check_va ? begin : check_va);
f0102251:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102254:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102258:	89 1d 3c 92 22 f0    	mov    %ebx,0xf022923c
            return -E_FAULT;
f010225e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102263:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102266:	5b                   	pop    %ebx
f0102267:	5e                   	pop    %esi
f0102268:	5f                   	pop    %edi
f0102269:	5d                   	pop    %ebp
f010226a:	c3                   	ret    
    return 0;
f010226b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102270:	eb f1                	jmp    f0102263 <user_mem_check+0x70>

f0102272 <user_mem_assert>:
{
f0102272:	55                   	push   %ebp
f0102273:	89 e5                	mov    %esp,%ebp
f0102275:	53                   	push   %ebx
f0102276:	83 ec 04             	sub    $0x4,%esp
f0102279:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010227c:	8b 45 14             	mov    0x14(%ebp),%eax
f010227f:	83 c8 04             	or     $0x4,%eax
f0102282:	50                   	push   %eax
f0102283:	ff 75 10             	pushl  0x10(%ebp)
f0102286:	ff 75 0c             	pushl  0xc(%ebp)
f0102289:	53                   	push   %ebx
f010228a:	e8 64 ff ff ff       	call   f01021f3 <user_mem_check>
f010228f:	83 c4 10             	add    $0x10,%esp
f0102292:	85 c0                	test   %eax,%eax
f0102294:	78 05                	js     f010229b <user_mem_assert+0x29>
}
f0102296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102299:	c9                   	leave  
f010229a:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f010229b:	83 ec 04             	sub    $0x4,%esp
f010229e:	ff 35 3c 92 22 f0    	pushl  0xf022923c
f01022a4:	ff 73 48             	pushl  0x48(%ebx)
f01022a7:	68 c0 58 10 f0       	push   $0xf01058c0
f01022ac:	e8 e4 08 00 00       	call   f0102b95 <cprintf>
		env_destroy(env);	// may not return
f01022b1:	89 1c 24             	mov    %ebx,(%esp)
f01022b4:	e8 ef 05 00 00       	call   f01028a8 <env_destroy>
f01022b9:	83 c4 10             	add    $0x10,%esp
}
f01022bc:	eb d8                	jmp    f0102296 <user_mem_assert+0x24>

f01022be <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01022be:	55                   	push   %ebp
f01022bf:	89 e5                	mov    %esp,%ebp
f01022c1:	57                   	push   %edi
f01022c2:	56                   	push   %esi
f01022c3:	53                   	push   %ebx
f01022c4:	83 ec 0c             	sub    $0xc,%esp
f01022c7:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va + len, PGSIZE);
f01022c9:	89 d3                	mov    %edx,%ebx
f01022cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01022d1:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f01022d8:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    	for (; begin < end; begin += PGSIZE) {
f01022de:	39 f3                	cmp    %esi,%ebx
f01022e0:	73 3f                	jae    f0102321 <region_alloc+0x63>
        	struct PageInfo *p = page_alloc(0);
f01022e2:	83 ec 0c             	sub    $0xc,%esp
f01022e5:	6a 00                	push   $0x0
f01022e7:	e8 4b e9 ff ff       	call   f0100c37 <page_alloc>
        	if (!p) panic("env region_alloc failed");
f01022ec:	83 c4 10             	add    $0x10,%esp
f01022ef:	85 c0                	test   %eax,%eax
f01022f1:	74 17                	je     f010230a <region_alloc+0x4c>
        	page_insert(e->env_pgdir, p, begin, PTE_W | PTE_U);
f01022f3:	6a 06                	push   $0x6
f01022f5:	53                   	push   %ebx
f01022f6:	50                   	push   %eax
f01022f7:	ff 77 60             	pushl  0x60(%edi)
f01022fa:	e8 89 eb ff ff       	call   f0100e88 <page_insert>
    	for (; begin < end; begin += PGSIZE) {
f01022ff:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102305:	83 c4 10             	add    $0x10,%esp
f0102308:	eb d4                	jmp    f01022de <region_alloc+0x20>
        	if (!p) panic("env region_alloc failed");
f010230a:	83 ec 04             	sub    $0x4,%esp
f010230d:	68 c3 5b 10 f0       	push   $0xf0105bc3
f0102312:	68 26 01 00 00       	push   $0x126
f0102317:	68 db 5b 10 f0       	push   $0xf0105bdb
f010231c:	e8 1f dd ff ff       	call   f0100040 <_panic>
    	}   
}
f0102321:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102324:	5b                   	pop    %ebx
f0102325:	5e                   	pop    %esi
f0102326:	5f                   	pop    %edi
f0102327:	5d                   	pop    %ebp
f0102328:	c3                   	ret    

f0102329 <envid2env>:
{
f0102329:	55                   	push   %ebp
f010232a:	89 e5                	mov    %esp,%ebp
f010232c:	56                   	push   %esi
f010232d:	53                   	push   %ebx
f010232e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102331:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f0102334:	85 c0                	test   %eax,%eax
f0102336:	74 2e                	je     f0102366 <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f0102338:	89 c3                	mov    %eax,%ebx
f010233a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102340:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102343:	03 1d 48 92 22 f0    	add    0xf0229248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102349:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010234d:	74 31                	je     f0102380 <envid2env+0x57>
f010234f:	39 43 48             	cmp    %eax,0x48(%ebx)
f0102352:	75 2c                	jne    f0102380 <envid2env+0x57>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102354:	84 d2                	test   %dl,%dl
f0102356:	75 38                	jne    f0102390 <envid2env+0x67>
	*env_store = e;
f0102358:	8b 45 0c             	mov    0xc(%ebp),%eax
f010235b:	89 18                	mov    %ebx,(%eax)
	return 0;
f010235d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102362:	5b                   	pop    %ebx
f0102363:	5e                   	pop    %esi
f0102364:	5d                   	pop    %ebp
f0102365:	c3                   	ret    
		*env_store = curenv;
f0102366:	e8 d8 23 00 00       	call   f0104743 <cpunum>
f010236b:	6b c0 74             	imul   $0x74,%eax,%eax
f010236e:	8b 80 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%eax
f0102374:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102377:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102379:	b8 00 00 00 00       	mov    $0x0,%eax
f010237e:	eb e2                	jmp    f0102362 <envid2env+0x39>
		*env_store = 0;
f0102380:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102383:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102389:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010238e:	eb d2                	jmp    f0102362 <envid2env+0x39>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102390:	e8 ae 23 00 00       	call   f0104743 <cpunum>
f0102395:	6b c0 74             	imul   $0x74,%eax,%eax
f0102398:	39 98 28 a0 22 f0    	cmp    %ebx,-0xfdd5fd8(%eax)
f010239e:	74 b8                	je     f0102358 <envid2env+0x2f>
f01023a0:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01023a3:	e8 9b 23 00 00       	call   f0104743 <cpunum>
f01023a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01023ab:	8b 80 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%eax
f01023b1:	3b 70 48             	cmp    0x48(%eax),%esi
f01023b4:	74 a2                	je     f0102358 <envid2env+0x2f>
		*env_store = 0;
f01023b6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01023b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01023bf:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01023c4:	eb 9c                	jmp    f0102362 <envid2env+0x39>

f01023c6 <env_init_percpu>:
{
f01023c6:	55                   	push   %ebp
f01023c7:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f01023c9:	b8 00 e3 11 f0       	mov    $0xf011e300,%eax
f01023ce:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01023d1:	b8 23 00 00 00       	mov    $0x23,%eax
f01023d6:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01023d8:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01023da:	b8 10 00 00 00       	mov    $0x10,%eax
f01023df:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01023e1:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01023e3:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01023e5:	ea ec 23 10 f0 08 00 	ljmp   $0x8,$0xf01023ec
	asm volatile("lldt %0" : : "r" (sel));
f01023ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01023f1:	0f 00 d0             	lldt   %ax
}
f01023f4:	5d                   	pop    %ebp
f01023f5:	c3                   	ret    

f01023f6 <env_init>:
{
f01023f6:	55                   	push   %ebp
f01023f7:	89 e5                	mov    %esp,%ebp
f01023f9:	56                   	push   %esi
f01023fa:	53                   	push   %ebx
        	struct Env *e = &envs[i];
f01023fb:	8b 35 48 92 22 f0    	mov    0xf0229248,%esi
f0102401:	8b 15 4c 92 22 f0    	mov    0xf022924c,%edx
f0102407:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f010240d:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102410:	89 c1                	mov    %eax,%ecx
        	e->env_id = 0;
f0102412:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        	e->env_status = ENV_FREE;
f0102419:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
        	e->env_link = env_free_list;
f0102420:	89 50 44             	mov    %edx,0x44(%eax)
f0102423:	83 e8 7c             	sub    $0x7c,%eax
        	env_free_list = e;
f0102426:	89 ca                	mov    %ecx,%edx
	for (int i = NENV-1; i >= 0; i--) {
f0102428:	39 d8                	cmp    %ebx,%eax
f010242a:	75 e4                	jne    f0102410 <env_init+0x1a>
f010242c:	89 35 4c 92 22 f0    	mov    %esi,0xf022924c
	env_init_percpu();
f0102432:	e8 8f ff ff ff       	call   f01023c6 <env_init_percpu>
}
f0102437:	5b                   	pop    %ebx
f0102438:	5e                   	pop    %esi
f0102439:	5d                   	pop    %ebp
f010243a:	c3                   	ret    

f010243b <env_alloc>:
{
f010243b:	55                   	push   %ebp
f010243c:	89 e5                	mov    %esp,%ebp
f010243e:	53                   	push   %ebx
f010243f:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f0102442:	8b 1d 4c 92 22 f0    	mov    0xf022924c,%ebx
f0102448:	85 db                	test   %ebx,%ebx
f010244a:	0f 84 6d 01 00 00    	je     f01025bd <env_alloc+0x182>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102450:	83 ec 0c             	sub    $0xc,%esp
f0102453:	6a 01                	push   $0x1
f0102455:	e8 dd e7 ff ff       	call   f0100c37 <page_alloc>
f010245a:	83 c4 10             	add    $0x10,%esp
f010245d:	85 c0                	test   %eax,%eax
f010245f:	0f 84 5f 01 00 00    	je     f01025c4 <env_alloc+0x189>
	p->pp_ref++;
f0102465:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010246a:	2b 05 10 9f 22 f0    	sub    0xf0229f10,%eax
f0102470:	c1 f8 03             	sar    $0x3,%eax
f0102473:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102476:	89 c2                	mov    %eax,%edx
f0102478:	c1 ea 0c             	shr    $0xc,%edx
f010247b:	3b 15 08 9f 22 f0    	cmp    0xf0229f08,%edx
f0102481:	0f 83 0f 01 00 00    	jae    f0102596 <env_alloc+0x15b>
	return (void *)(pa + KERNBASE);
f0102487:	2d 00 00 00 10       	sub    $0x10000000,%eax
    	e->env_pgdir = (pde_t *)page2kva(p);
f010248c:	89 43 60             	mov    %eax,0x60(%ebx)
    	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f010248f:	83 ec 04             	sub    $0x4,%esp
f0102492:	68 00 10 00 00       	push   $0x1000
f0102497:	ff 35 0c 9f 22 f0    	pushl  0xf0229f0c
f010249d:	50                   	push   %eax
f010249e:	e8 32 1d 00 00       	call   f01041d5 <memcpy>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01024a3:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01024a6:	83 c4 10             	add    $0x10,%esp
f01024a9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01024ae:	0f 86 f4 00 00 00    	jbe    f01025a8 <env_alloc+0x16d>
	return (physaddr_t)kva - KERNBASE;
f01024b4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01024ba:	83 ca 05             	or     $0x5,%edx
f01024bd:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01024c3:	8b 43 48             	mov    0x48(%ebx),%eax
f01024c6:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01024cb:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01024d0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024d5:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01024d8:	89 da                	mov    %ebx,%edx
f01024da:	2b 15 48 92 22 f0    	sub    0xf0229248,%edx
f01024e0:	c1 fa 02             	sar    $0x2,%edx
f01024e3:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01024e9:	09 d0                	or     %edx,%eax
f01024eb:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f01024ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01024f1:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01024f4:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01024fb:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102502:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102509:	83 ec 04             	sub    $0x4,%esp
f010250c:	6a 44                	push   $0x44
f010250e:	6a 00                	push   $0x0
f0102510:	53                   	push   %ebx
f0102511:	e8 0a 1c 00 00       	call   f0104120 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0102516:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010251c:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102522:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102528:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010252f:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_pgfault_upcall = 0;
f0102535:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f010253c:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f0102540:	8b 43 44             	mov    0x44(%ebx),%eax
f0102543:	a3 4c 92 22 f0       	mov    %eax,0xf022924c
	*newenv_store = e;
f0102548:	8b 45 08             	mov    0x8(%ebp),%eax
f010254b:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010254d:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0102550:	e8 ee 21 00 00       	call   f0104743 <cpunum>
f0102555:	6b c0 74             	imul   $0x74,%eax,%eax
f0102558:	83 c4 10             	add    $0x10,%esp
f010255b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102560:	83 b8 28 a0 22 f0 00 	cmpl   $0x0,-0xfdd5fd8(%eax)
f0102567:	74 11                	je     f010257a <env_alloc+0x13f>
f0102569:	e8 d5 21 00 00       	call   f0104743 <cpunum>
f010256e:	6b c0 74             	imul   $0x74,%eax,%eax
f0102571:	8b 80 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%eax
f0102577:	8b 50 48             	mov    0x48(%eax),%edx
f010257a:	83 ec 04             	sub    $0x4,%esp
f010257d:	53                   	push   %ebx
f010257e:	52                   	push   %edx
f010257f:	68 e6 5b 10 f0       	push   $0xf0105be6
f0102584:	e8 0c 06 00 00       	call   f0102b95 <cprintf>
	return 0;
f0102589:	83 c4 10             	add    $0x10,%esp
f010258c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102591:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102594:	c9                   	leave  
f0102595:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102596:	50                   	push   %eax
f0102597:	68 a4 4d 10 f0       	push   $0xf0104da4
f010259c:	6a 58                	push   $0x58
f010259e:	68 f5 58 10 f0       	push   $0xf01058f5
f01025a3:	e8 98 da ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025a8:	50                   	push   %eax
f01025a9:	68 c8 4d 10 f0       	push   $0xf0104dc8
f01025ae:	68 c5 00 00 00       	push   $0xc5
f01025b3:	68 db 5b 10 f0       	push   $0xf0105bdb
f01025b8:	e8 83 da ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f01025bd:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01025c2:	eb cd                	jmp    f0102591 <env_alloc+0x156>
		return -E_NO_MEM;
f01025c4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01025c9:	eb c6                	jmp    f0102591 <env_alloc+0x156>

f01025cb <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01025cb:	55                   	push   %ebp
f01025cc:	89 e5                	mov    %esp,%ebp
f01025ce:	57                   	push   %edi
f01025cf:	56                   	push   %esi
f01025d0:	53                   	push   %ebx
f01025d1:	83 ec 24             	sub    $0x24,%esp
	// LAB 3: Your code here.
	struct Env *e;
    env_alloc(&e, 0);
f01025d4:	6a 00                	push   $0x0
f01025d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01025d9:	50                   	push   %eax
f01025da:	e8 5c fe ff ff       	call   f010243b <env_alloc>
    e->env_type = type;
f01025df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01025e2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01025e5:	89 47 50             	mov    %eax,0x50(%edi)
    ph = (struct Proghdr*)((uint8_t*)(env_elf) + env_elf->e_phoff);
f01025e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01025eb:	89 c3                	mov    %eax,%ebx
f01025ed:	03 58 1c             	add    0x1c(%eax),%ebx
    eph = ph + env_elf->e_phnum;
f01025f0:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f01025f4:	c1 e6 05             	shl    $0x5,%esi
f01025f7:	01 de                	add    %ebx,%esi
    lcr3(PADDR(e->env_pgdir));
f01025f9:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f01025fc:	83 c4 10             	add    $0x10,%esp
f01025ff:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102604:	76 0a                	jbe    f0102610 <env_create+0x45>
	return (physaddr_t)kva - KERNBASE;
f0102606:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010260b:	0f 22 d8             	mov    %eax,%cr3
f010260e:	eb 18                	jmp    f0102628 <env_create+0x5d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102610:	50                   	push   %eax
f0102611:	68 c8 4d 10 f0       	push   $0xf0104dc8
f0102616:	68 6c 01 00 00       	push   $0x16c
f010261b:	68 db 5b 10 f0       	push   $0xf0105bdb
f0102620:	e8 1b da ff ff       	call   f0100040 <_panic>
    for (; ph < eph; ph++) {
f0102625:	83 c3 20             	add    $0x20,%ebx
f0102628:	39 de                	cmp    %ebx,%esi
f010262a:	76 43                	jbe    f010266f <env_create+0xa4>
        if(ph->p_type == ELF_PROG_LOAD) {
f010262c:	83 3b 01             	cmpl   $0x1,(%ebx)
f010262f:	75 f4                	jne    f0102625 <env_create+0x5a>
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102631:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102634:	8b 53 08             	mov    0x8(%ebx),%edx
f0102637:	89 f8                	mov    %edi,%eax
f0102639:	e8 80 fc ff ff       	call   f01022be <region_alloc>
            memcpy((void*)ph->p_va, (void *)(binary+ph->p_offset), ph->p_filesz);
f010263e:	83 ec 04             	sub    $0x4,%esp
f0102641:	ff 73 10             	pushl  0x10(%ebx)
f0102644:	8b 45 08             	mov    0x8(%ebp),%eax
f0102647:	03 43 04             	add    0x4(%ebx),%eax
f010264a:	50                   	push   %eax
f010264b:	ff 73 08             	pushl  0x8(%ebx)
f010264e:	e8 82 1b 00 00       	call   f01041d5 <memcpy>
            memset((void*)(ph->p_va + ph->p_filesz), 0, ph->p_memsz-ph->p_filesz);
f0102653:	8b 43 10             	mov    0x10(%ebx),%eax
f0102656:	83 c4 0c             	add    $0xc,%esp
f0102659:	8b 53 14             	mov    0x14(%ebx),%edx
f010265c:	29 c2                	sub    %eax,%edx
f010265e:	52                   	push   %edx
f010265f:	6a 00                	push   $0x0
f0102661:	03 43 08             	add    0x8(%ebx),%eax
f0102664:	50                   	push   %eax
f0102665:	e8 b6 1a 00 00       	call   f0104120 <memset>
f010266a:	83 c4 10             	add    $0x10,%esp
f010266d:	eb b6                	jmp    f0102625 <env_create+0x5a>
    e->env_tf.tf_eip = env_elf->e_entry;
f010266f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102672:	8b 40 18             	mov    0x18(%eax),%eax
f0102675:	89 47 30             	mov    %eax,0x30(%edi)
    lcr3(PADDR(kern_pgdir));
f0102678:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
	if ((uint32_t)kva < KERNBASE)
f010267d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102682:	76 21                	jbe    f01026a5 <env_create+0xda>
	return (physaddr_t)kva - KERNBASE;
f0102684:	05 00 00 00 10       	add    $0x10000000,%eax
f0102689:	0f 22 d8             	mov    %eax,%cr3
    region_alloc(e, (void *)(USTACKTOP-PGSIZE), PGSIZE);
f010268c:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102691:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102696:	89 f8                	mov    %edi,%eax
f0102698:	e8 21 fc ff ff       	call   f01022be <region_alloc>
    load_icode(e, binary);
}
f010269d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01026a0:	5b                   	pop    %ebx
f01026a1:	5e                   	pop    %esi
f01026a2:	5f                   	pop    %edi
f01026a3:	5d                   	pop    %ebp
f01026a4:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026a5:	50                   	push   %eax
f01026a6:	68 c8 4d 10 f0       	push   $0xf0104dc8
f01026ab:	68 77 01 00 00       	push   $0x177
f01026b0:	68 db 5b 10 f0       	push   $0xf0105bdb
f01026b5:	e8 86 d9 ff ff       	call   f0100040 <_panic>

f01026ba <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01026ba:	55                   	push   %ebp
f01026bb:	89 e5                	mov    %esp,%ebp
f01026bd:	57                   	push   %edi
f01026be:	56                   	push   %esi
f01026bf:	53                   	push   %ebx
f01026c0:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01026c3:	e8 7b 20 00 00       	call   f0104743 <cpunum>
f01026c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01026cb:	8b 55 08             	mov    0x8(%ebp),%edx
f01026ce:	39 90 28 a0 22 f0    	cmp    %edx,-0xfdd5fd8(%eax)
f01026d4:	75 14                	jne    f01026ea <env_free+0x30>
		lcr3(PADDR(kern_pgdir));
f01026d6:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
	if ((uint32_t)kva < KERNBASE)
f01026db:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026e0:	76 56                	jbe    f0102738 <env_free+0x7e>
	return (physaddr_t)kva - KERNBASE;
f01026e2:	05 00 00 00 10       	add    $0x10000000,%eax
f01026e7:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01026ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01026ed:	8b 58 48             	mov    0x48(%eax),%ebx
f01026f0:	e8 4e 20 00 00       	call   f0104743 <cpunum>
f01026f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01026f8:	ba 00 00 00 00       	mov    $0x0,%edx
f01026fd:	83 b8 28 a0 22 f0 00 	cmpl   $0x0,-0xfdd5fd8(%eax)
f0102704:	74 11                	je     f0102717 <env_free+0x5d>
f0102706:	e8 38 20 00 00       	call   f0104743 <cpunum>
f010270b:	6b c0 74             	imul   $0x74,%eax,%eax
f010270e:	8b 80 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%eax
f0102714:	8b 50 48             	mov    0x48(%eax),%edx
f0102717:	83 ec 04             	sub    $0x4,%esp
f010271a:	53                   	push   %ebx
f010271b:	52                   	push   %edx
f010271c:	68 fb 5b 10 f0       	push   $0xf0105bfb
f0102721:	e8 6f 04 00 00       	call   f0102b95 <cprintf>
f0102726:	83 c4 10             	add    $0x10,%esp
f0102729:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0102730:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102733:	e9 8f 00 00 00       	jmp    f01027c7 <env_free+0x10d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102738:	50                   	push   %eax
f0102739:	68 c8 4d 10 f0       	push   $0xf0104dc8
f010273e:	68 9d 01 00 00       	push   $0x19d
f0102743:	68 db 5b 10 f0       	push   $0xf0105bdb
f0102748:	e8 f3 d8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010274d:	50                   	push   %eax
f010274e:	68 a4 4d 10 f0       	push   $0xf0104da4
f0102753:	68 ac 01 00 00       	push   $0x1ac
f0102758:	68 db 5b 10 f0       	push   $0xf0105bdb
f010275d:	e8 de d8 ff ff       	call   f0100040 <_panic>
f0102762:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102765:	39 f3                	cmp    %esi,%ebx
f0102767:	74 21                	je     f010278a <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f0102769:	f6 03 01             	testb  $0x1,(%ebx)
f010276c:	74 f4                	je     f0102762 <env_free+0xa8>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010276e:	83 ec 08             	sub    $0x8,%esp
f0102771:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102774:	01 d8                	add    %ebx,%eax
f0102776:	c1 e0 0a             	shl    $0xa,%eax
f0102779:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010277c:	50                   	push   %eax
f010277d:	ff 77 60             	pushl  0x60(%edi)
f0102780:	e8 b6 e6 ff ff       	call   f0100e3b <page_remove>
f0102785:	83 c4 10             	add    $0x10,%esp
f0102788:	eb d8                	jmp    f0102762 <env_free+0xa8>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010278a:	8b 47 60             	mov    0x60(%edi),%eax
f010278d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102790:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0102797:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010279a:	3b 05 08 9f 22 f0    	cmp    0xf0229f08,%eax
f01027a0:	73 6a                	jae    f010280c <env_free+0x152>
		page_decref(pa2page(pa));
f01027a2:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01027a5:	a1 10 9f 22 f0       	mov    0xf0229f10,%eax
f01027aa:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01027ad:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01027b0:	50                   	push   %eax
f01027b1:	e8 2e e5 ff ff       	call   f0100ce4 <page_decref>
f01027b6:	83 c4 10             	add    $0x10,%esp
f01027b9:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f01027bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01027c0:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01027c5:	74 59                	je     f0102820 <env_free+0x166>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01027c7:	8b 47 60             	mov    0x60(%edi),%eax
f01027ca:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01027cd:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01027d0:	a8 01                	test   $0x1,%al
f01027d2:	74 e5                	je     f01027b9 <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01027d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01027d9:	89 c2                	mov    %eax,%edx
f01027db:	c1 ea 0c             	shr    $0xc,%edx
f01027de:	89 55 d8             	mov    %edx,-0x28(%ebp)
f01027e1:	39 15 08 9f 22 f0    	cmp    %edx,0xf0229f08
f01027e7:	0f 86 60 ff ff ff    	jbe    f010274d <env_free+0x93>
	return (void *)(pa + KERNBASE);
f01027ed:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01027f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01027f6:	c1 e2 14             	shl    $0x14,%edx
f01027f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01027fc:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f0102802:	f7 d8                	neg    %eax
f0102804:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102807:	e9 5d ff ff ff       	jmp    f0102769 <env_free+0xaf>
		panic("pa2page called with invalid pa");
f010280c:	83 ec 04             	sub    $0x4,%esp
f010280f:	68 04 53 10 f0       	push   $0xf0105304
f0102814:	6a 51                	push   $0x51
f0102816:	68 f5 58 10 f0       	push   $0xf01058f5
f010281b:	e8 20 d8 ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102820:	8b 45 08             	mov    0x8(%ebp),%eax
f0102823:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102826:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010282b:	76 52                	jbe    f010287f <env_free+0x1c5>
	e->env_pgdir = 0;
f010282d:	8b 55 08             	mov    0x8(%ebp),%edx
f0102830:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
	return (physaddr_t)kva - KERNBASE;
f0102837:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f010283c:	c1 e8 0c             	shr    $0xc,%eax
f010283f:	3b 05 08 9f 22 f0    	cmp    0xf0229f08,%eax
f0102845:	73 4d                	jae    f0102894 <env_free+0x1da>
	page_decref(pa2page(pa));
f0102847:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010284a:	8b 15 10 9f 22 f0    	mov    0xf0229f10,%edx
f0102850:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102853:	50                   	push   %eax
f0102854:	e8 8b e4 ff ff       	call   f0100ce4 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102859:	8b 45 08             	mov    0x8(%ebp),%eax
f010285c:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0102863:	a1 4c 92 22 f0       	mov    0xf022924c,%eax
f0102868:	8b 55 08             	mov    0x8(%ebp),%edx
f010286b:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f010286e:	89 15 4c 92 22 f0    	mov    %edx,0xf022924c
}
f0102874:	83 c4 10             	add    $0x10,%esp
f0102877:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010287a:	5b                   	pop    %ebx
f010287b:	5e                   	pop    %esi
f010287c:	5f                   	pop    %edi
f010287d:	5d                   	pop    %ebp
f010287e:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010287f:	50                   	push   %eax
f0102880:	68 c8 4d 10 f0       	push   $0xf0104dc8
f0102885:	68 ba 01 00 00       	push   $0x1ba
f010288a:	68 db 5b 10 f0       	push   $0xf0105bdb
f010288f:	e8 ac d7 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f0102894:	83 ec 04             	sub    $0x4,%esp
f0102897:	68 04 53 10 f0       	push   $0xf0105304
f010289c:	6a 51                	push   $0x51
f010289e:	68 f5 58 10 f0       	push   $0xf01058f5
f01028a3:	e8 98 d7 ff ff       	call   f0100040 <_panic>

f01028a8 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01028a8:	55                   	push   %ebp
f01028a9:	89 e5                	mov    %esp,%ebp
f01028ab:	53                   	push   %ebx
f01028ac:	83 ec 04             	sub    $0x4,%esp
f01028af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01028b2:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01028b6:	74 21                	je     f01028d9 <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f01028b8:	83 ec 0c             	sub    $0xc,%esp
f01028bb:	53                   	push   %ebx
f01028bc:	e8 f9 fd ff ff       	call   f01026ba <env_free>

	if (curenv == e) {
f01028c1:	e8 7d 1e 00 00       	call   f0104743 <cpunum>
f01028c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01028c9:	83 c4 10             	add    $0x10,%esp
f01028cc:	39 98 28 a0 22 f0    	cmp    %ebx,-0xfdd5fd8(%eax)
f01028d2:	74 1e                	je     f01028f2 <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f01028d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01028d7:	c9                   	leave  
f01028d8:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01028d9:	e8 65 1e 00 00       	call   f0104743 <cpunum>
f01028de:	6b c0 74             	imul   $0x74,%eax,%eax
f01028e1:	39 98 28 a0 22 f0    	cmp    %ebx,-0xfdd5fd8(%eax)
f01028e7:	74 cf                	je     f01028b8 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f01028e9:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01028f0:	eb e2                	jmp    f01028d4 <env_destroy+0x2c>
		curenv = NULL;
f01028f2:	e8 4c 1e 00 00       	call   f0104743 <cpunum>
f01028f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01028fa:	c7 80 28 a0 22 f0 00 	movl   $0x0,-0xfdd5fd8(%eax)
f0102901:	00 00 00 
		sched_yield();
f0102904:	e8 c3 0b 00 00       	call   f01034cc <sched_yield>

f0102909 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102909:	55                   	push   %ebp
f010290a:	89 e5                	mov    %esp,%ebp
f010290c:	53                   	push   %ebx
f010290d:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0102910:	e8 2e 1e 00 00       	call   f0104743 <cpunum>
f0102915:	6b c0 74             	imul   $0x74,%eax,%eax
f0102918:	8b 98 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%ebx
f010291e:	e8 20 1e 00 00       	call   f0104743 <cpunum>
f0102923:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0102926:	8b 65 08             	mov    0x8(%ebp),%esp
f0102929:	61                   	popa   
f010292a:	07                   	pop    %es
f010292b:	1f                   	pop    %ds
f010292c:	83 c4 08             	add    $0x8,%esp
f010292f:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102930:	83 ec 04             	sub    $0x4,%esp
f0102933:	68 11 5c 10 f0       	push   $0xf0105c11
f0102938:	68 f1 01 00 00       	push   $0x1f1
f010293d:	68 db 5b 10 f0       	push   $0xf0105bdb
f0102942:	e8 f9 d6 ff ff       	call   f0100040 <_panic>

f0102947 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102947:	55                   	push   %ebp
f0102948:	89 e5                	mov    %esp,%ebp
f010294a:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

//	panic("env_run not yet implemented");
	if (curenv && curenv->env_status == ENV_RUNNING) {
f010294d:	e8 f1 1d 00 00       	call   f0104743 <cpunum>
f0102952:	6b c0 74             	imul   $0x74,%eax,%eax
f0102955:	83 b8 28 a0 22 f0 00 	cmpl   $0x0,-0xfdd5fd8(%eax)
f010295c:	74 14                	je     f0102972 <env_run+0x2b>
f010295e:	e8 e0 1d 00 00       	call   f0104743 <cpunum>
f0102963:	6b c0 74             	imul   $0x74,%eax,%eax
f0102966:	8b 80 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%eax
f010296c:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0102970:	74 65                	je     f01029d7 <env_run+0x90>
        curenv->env_status = ENV_RUNNABLE;
    }
    curenv = e;
f0102972:	e8 cc 1d 00 00       	call   f0104743 <cpunum>
f0102977:	6b c0 74             	imul   $0x74,%eax,%eax
f010297a:	8b 55 08             	mov    0x8(%ebp),%edx
f010297d:	89 90 28 a0 22 f0    	mov    %edx,-0xfdd5fd8(%eax)
    curenv->env_status = ENV_RUNNING;
f0102983:	e8 bb 1d 00 00       	call   f0104743 <cpunum>
f0102988:	6b c0 74             	imul   $0x74,%eax,%eax
f010298b:	8b 80 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%eax
f0102991:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f0102998:	e8 a6 1d 00 00       	call   f0104743 <cpunum>
f010299d:	6b c0 74             	imul   $0x74,%eax,%eax
f01029a0:	8b 80 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%eax
f01029a6:	83 40 58 01          	addl   $0x1,0x58(%eax)
    lcr3(PADDR(curenv->env_pgdir));
f01029aa:	e8 94 1d 00 00       	call   f0104743 <cpunum>
f01029af:	6b c0 74             	imul   $0x74,%eax,%eax
f01029b2:	8b 80 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%eax
f01029b8:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01029bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029c0:	77 2c                	ja     f01029ee <env_run+0xa7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029c2:	50                   	push   %eax
f01029c3:	68 c8 4d 10 f0       	push   $0xf0104dc8
f01029c8:	68 17 02 00 00       	push   $0x217
f01029cd:	68 db 5b 10 f0       	push   $0xf0105bdb
f01029d2:	e8 69 d6 ff ff       	call   f0100040 <_panic>
        curenv->env_status = ENV_RUNNABLE;
f01029d7:	e8 67 1d 00 00       	call   f0104743 <cpunum>
f01029dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01029df:	8b 80 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%eax
f01029e5:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f01029ec:	eb 84                	jmp    f0102972 <env_run+0x2b>
	return (physaddr_t)kva - KERNBASE;
f01029ee:	05 00 00 00 10       	add    $0x10000000,%eax
f01029f3:	0f 22 d8             	mov    %eax,%cr3
    env_pop_tf(&curenv->env_tf);
f01029f6:	e8 48 1d 00 00       	call   f0104743 <cpunum>
f01029fb:	83 ec 0c             	sub    $0xc,%esp
f01029fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0102a01:	ff b0 28 a0 22 f0    	pushl  -0xfdd5fd8(%eax)
f0102a07:	e8 fd fe ff ff       	call   f0102909 <env_pop_tf>

f0102a0c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102a0c:	55                   	push   %ebp
f0102a0d:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102a0f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a12:	ba 70 00 00 00       	mov    $0x70,%edx
f0102a17:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102a18:	ba 71 00 00 00       	mov    $0x71,%edx
f0102a1d:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102a1e:	0f b6 c0             	movzbl %al,%eax
}
f0102a21:	5d                   	pop    %ebp
f0102a22:	c3                   	ret    

f0102a23 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102a23:	55                   	push   %ebp
f0102a24:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102a26:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a29:	ba 70 00 00 00       	mov    $0x70,%edx
f0102a2e:	ee                   	out    %al,(%dx)
f0102a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a32:	ba 71 00 00 00       	mov    $0x71,%edx
f0102a37:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102a38:	5d                   	pop    %ebp
f0102a39:	c3                   	ret    

f0102a3a <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0102a3a:	55                   	push   %ebp
f0102a3b:	89 e5                	mov    %esp,%ebp
f0102a3d:	56                   	push   %esi
f0102a3e:	53                   	push   %ebx
f0102a3f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0102a42:	66 a3 88 e3 11 f0    	mov    %ax,0xf011e388
	if (!didinit)
f0102a48:	80 3d 50 92 22 f0 00 	cmpb   $0x0,0xf0229250
f0102a4f:	75 07                	jne    f0102a58 <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0102a51:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102a54:	5b                   	pop    %ebx
f0102a55:	5e                   	pop    %esi
f0102a56:	5d                   	pop    %ebp
f0102a57:	c3                   	ret    
f0102a58:	89 c6                	mov    %eax,%esi
f0102a5a:	ba 21 00 00 00       	mov    $0x21,%edx
f0102a5f:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0102a60:	66 c1 e8 08          	shr    $0x8,%ax
f0102a64:	ba a1 00 00 00       	mov    $0xa1,%edx
f0102a69:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0102a6a:	83 ec 0c             	sub    $0xc,%esp
f0102a6d:	68 1d 5c 10 f0       	push   $0xf0105c1d
f0102a72:	e8 1e 01 00 00       	call   f0102b95 <cprintf>
f0102a77:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0102a7a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0102a7f:	0f b7 f6             	movzwl %si,%esi
f0102a82:	f7 d6                	not    %esi
f0102a84:	eb 08                	jmp    f0102a8e <irq_setmask_8259A+0x54>
	for (i = 0; i < 16; i++)
f0102a86:	83 c3 01             	add    $0x1,%ebx
f0102a89:	83 fb 10             	cmp    $0x10,%ebx
f0102a8c:	74 18                	je     f0102aa6 <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f0102a8e:	0f a3 de             	bt     %ebx,%esi
f0102a91:	73 f3                	jae    f0102a86 <irq_setmask_8259A+0x4c>
			cprintf(" %d", i);
f0102a93:	83 ec 08             	sub    $0x8,%esp
f0102a96:	53                   	push   %ebx
f0102a97:	68 94 60 10 f0       	push   $0xf0106094
f0102a9c:	e8 f4 00 00 00       	call   f0102b95 <cprintf>
f0102aa1:	83 c4 10             	add    $0x10,%esp
f0102aa4:	eb e0                	jmp    f0102a86 <irq_setmask_8259A+0x4c>
	cprintf("\n");
f0102aa6:	83 ec 0c             	sub    $0xc,%esp
f0102aa9:	68 4d 4e 10 f0       	push   $0xf0104e4d
f0102aae:	e8 e2 00 00 00       	call   f0102b95 <cprintf>
f0102ab3:	83 c4 10             	add    $0x10,%esp
f0102ab6:	eb 99                	jmp    f0102a51 <irq_setmask_8259A+0x17>

f0102ab8 <pic_init>:
{
f0102ab8:	55                   	push   %ebp
f0102ab9:	89 e5                	mov    %esp,%ebp
f0102abb:	57                   	push   %edi
f0102abc:	56                   	push   %esi
f0102abd:	53                   	push   %ebx
f0102abe:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0102ac1:	c6 05 50 92 22 f0 01 	movb   $0x1,0xf0229250
f0102ac8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102acd:	bb 21 00 00 00       	mov    $0x21,%ebx
f0102ad2:	89 da                	mov    %ebx,%edx
f0102ad4:	ee                   	out    %al,(%dx)
f0102ad5:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0102ada:	89 ca                	mov    %ecx,%edx
f0102adc:	ee                   	out    %al,(%dx)
f0102add:	bf 11 00 00 00       	mov    $0x11,%edi
f0102ae2:	be 20 00 00 00       	mov    $0x20,%esi
f0102ae7:	89 f8                	mov    %edi,%eax
f0102ae9:	89 f2                	mov    %esi,%edx
f0102aeb:	ee                   	out    %al,(%dx)
f0102aec:	b8 20 00 00 00       	mov    $0x20,%eax
f0102af1:	89 da                	mov    %ebx,%edx
f0102af3:	ee                   	out    %al,(%dx)
f0102af4:	b8 04 00 00 00       	mov    $0x4,%eax
f0102af9:	ee                   	out    %al,(%dx)
f0102afa:	b8 03 00 00 00       	mov    $0x3,%eax
f0102aff:	ee                   	out    %al,(%dx)
f0102b00:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0102b05:	89 f8                	mov    %edi,%eax
f0102b07:	89 da                	mov    %ebx,%edx
f0102b09:	ee                   	out    %al,(%dx)
f0102b0a:	b8 28 00 00 00       	mov    $0x28,%eax
f0102b0f:	89 ca                	mov    %ecx,%edx
f0102b11:	ee                   	out    %al,(%dx)
f0102b12:	b8 02 00 00 00       	mov    $0x2,%eax
f0102b17:	ee                   	out    %al,(%dx)
f0102b18:	b8 01 00 00 00       	mov    $0x1,%eax
f0102b1d:	ee                   	out    %al,(%dx)
f0102b1e:	bf 68 00 00 00       	mov    $0x68,%edi
f0102b23:	89 f8                	mov    %edi,%eax
f0102b25:	89 f2                	mov    %esi,%edx
f0102b27:	ee                   	out    %al,(%dx)
f0102b28:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102b2d:	89 c8                	mov    %ecx,%eax
f0102b2f:	ee                   	out    %al,(%dx)
f0102b30:	89 f8                	mov    %edi,%eax
f0102b32:	89 da                	mov    %ebx,%edx
f0102b34:	ee                   	out    %al,(%dx)
f0102b35:	89 c8                	mov    %ecx,%eax
f0102b37:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0102b38:	0f b7 05 88 e3 11 f0 	movzwl 0xf011e388,%eax
f0102b3f:	66 83 f8 ff          	cmp    $0xffff,%ax
f0102b43:	74 0f                	je     f0102b54 <pic_init+0x9c>
		irq_setmask_8259A(irq_mask_8259A);
f0102b45:	83 ec 0c             	sub    $0xc,%esp
f0102b48:	0f b7 c0             	movzwl %ax,%eax
f0102b4b:	50                   	push   %eax
f0102b4c:	e8 e9 fe ff ff       	call   f0102a3a <irq_setmask_8259A>
f0102b51:	83 c4 10             	add    $0x10,%esp
}
f0102b54:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b57:	5b                   	pop    %ebx
f0102b58:	5e                   	pop    %esi
f0102b59:	5f                   	pop    %edi
f0102b5a:	5d                   	pop    %ebp
f0102b5b:	c3                   	ret    

f0102b5c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102b5c:	55                   	push   %ebp
f0102b5d:	89 e5                	mov    %esp,%ebp
f0102b5f:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102b62:	ff 75 08             	pushl  0x8(%ebp)
f0102b65:	e8 eb db ff ff       	call   f0100755 <cputchar>
	*cnt++;
}
f0102b6a:	83 c4 10             	add    $0x10,%esp
f0102b6d:	c9                   	leave  
f0102b6e:	c3                   	ret    

f0102b6f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102b6f:	55                   	push   %ebp
f0102b70:	89 e5                	mov    %esp,%ebp
f0102b72:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102b75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102b7c:	ff 75 0c             	pushl  0xc(%ebp)
f0102b7f:	ff 75 08             	pushl  0x8(%ebp)
f0102b82:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102b85:	50                   	push   %eax
f0102b86:	68 5c 2b 10 f0       	push   $0xf0102b5c
f0102b8b:	e8 4b 0e 00 00       	call   f01039db <vprintfmt>
	return cnt;
}
f0102b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102b93:	c9                   	leave  
f0102b94:	c3                   	ret    

f0102b95 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102b95:	55                   	push   %ebp
f0102b96:	89 e5                	mov    %esp,%ebp
f0102b98:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102b9b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102b9e:	50                   	push   %eax
f0102b9f:	ff 75 08             	pushl  0x8(%ebp)
f0102ba2:	e8 c8 ff ff ff       	call   f0102b6f <vcprintf>
	va_end(ap);

	return cnt;
}
f0102ba7:	c9                   	leave  
f0102ba8:	c3                   	ret    

f0102ba9 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0102ba9:	55                   	push   %ebp
f0102baa:	89 e5                	mov    %esp,%ebp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0102bac:	b8 80 9a 22 f0       	mov    $0xf0229a80,%eax
f0102bb1:	c7 05 84 9a 22 f0 00 	movl   $0xf0000000,0xf0229a84
f0102bb8:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0102bbb:	66 c7 05 88 9a 22 f0 	movw   $0x10,0xf0229a88
f0102bc2:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0102bc4:	66 c7 05 e6 9a 22 f0 	movw   $0x68,0xf0229ae6
f0102bcb:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0102bcd:	66 c7 05 48 e3 11 f0 	movw   $0x67,0xf011e348
f0102bd4:	67 00 
f0102bd6:	66 a3 4a e3 11 f0    	mov    %ax,0xf011e34a
f0102bdc:	89 c2                	mov    %eax,%edx
f0102bde:	c1 ea 10             	shr    $0x10,%edx
f0102be1:	88 15 4c e3 11 f0    	mov    %dl,0xf011e34c
f0102be7:	c6 05 4e e3 11 f0 40 	movb   $0x40,0xf011e34e
f0102bee:	c1 e8 18             	shr    $0x18,%eax
f0102bf1:	a2 4f e3 11 f0       	mov    %al,0xf011e34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0102bf6:	c6 05 4d e3 11 f0 89 	movb   $0x89,0xf011e34d
	asm volatile("ltr %0" : : "r" (sel));
f0102bfd:	b8 28 00 00 00       	mov    $0x28,%eax
f0102c02:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0102c05:	b8 8c e3 11 f0       	mov    $0xf011e38c,%eax
f0102c0a:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0102c0d:	5d                   	pop    %ebp
f0102c0e:	c3                   	ret    

f0102c0f <trap_init>:
{
f0102c0f:	55                   	push   %ebp
f0102c10:	89 e5                	mov    %esp,%ebp
    SETGATE(idt[T_DIVIDE], 0, GD_KT, handler0, 0); 
f0102c12:	b8 94 33 10 f0       	mov    $0xf0103394,%eax
f0102c17:	66 a3 60 92 22 f0    	mov    %ax,0xf0229260
f0102c1d:	66 c7 05 62 92 22 f0 	movw   $0x8,0xf0229262
f0102c24:	08 00 
f0102c26:	c6 05 64 92 22 f0 00 	movb   $0x0,0xf0229264
f0102c2d:	c6 05 65 92 22 f0 8e 	movb   $0x8e,0xf0229265
f0102c34:	c1 e8 10             	shr    $0x10,%eax
f0102c37:	66 a3 66 92 22 f0    	mov    %ax,0xf0229266
    SETGATE(idt[T_DEBUG], 0, GD_KT, handler1, 0); 
f0102c3d:	b8 9a 33 10 f0       	mov    $0xf010339a,%eax
f0102c42:	66 a3 68 92 22 f0    	mov    %ax,0xf0229268
f0102c48:	66 c7 05 6a 92 22 f0 	movw   $0x8,0xf022926a
f0102c4f:	08 00 
f0102c51:	c6 05 6c 92 22 f0 00 	movb   $0x0,0xf022926c
f0102c58:	c6 05 6d 92 22 f0 8e 	movb   $0x8e,0xf022926d
f0102c5f:	c1 e8 10             	shr    $0x10,%eax
f0102c62:	66 a3 6e 92 22 f0    	mov    %ax,0xf022926e
    SETGATE(idt[T_NMI], 0, GD_KT, handler2, 0); 
f0102c68:	b8 a0 33 10 f0       	mov    $0xf01033a0,%eax
f0102c6d:	66 a3 70 92 22 f0    	mov    %ax,0xf0229270
f0102c73:	66 c7 05 72 92 22 f0 	movw   $0x8,0xf0229272
f0102c7a:	08 00 
f0102c7c:	c6 05 74 92 22 f0 00 	movb   $0x0,0xf0229274
f0102c83:	c6 05 75 92 22 f0 8e 	movb   $0x8e,0xf0229275
f0102c8a:	c1 e8 10             	shr    $0x10,%eax
f0102c8d:	66 a3 76 92 22 f0    	mov    %ax,0xf0229276
    SETGATE(idt[T_BRKPT], 0, GD_KT, handler3, 3); 
f0102c93:	b8 a6 33 10 f0       	mov    $0xf01033a6,%eax
f0102c98:	66 a3 78 92 22 f0    	mov    %ax,0xf0229278
f0102c9e:	66 c7 05 7a 92 22 f0 	movw   $0x8,0xf022927a
f0102ca5:	08 00 
f0102ca7:	c6 05 7c 92 22 f0 00 	movb   $0x0,0xf022927c
f0102cae:	c6 05 7d 92 22 f0 ee 	movb   $0xee,0xf022927d
f0102cb5:	c1 e8 10             	shr    $0x10,%eax
f0102cb8:	66 a3 7e 92 22 f0    	mov    %ax,0xf022927e
    SETGATE(idt[T_OFLOW], 0, GD_KT, handler4, 0); 
f0102cbe:	b8 ac 33 10 f0       	mov    $0xf01033ac,%eax
f0102cc3:	66 a3 80 92 22 f0    	mov    %ax,0xf0229280
f0102cc9:	66 c7 05 82 92 22 f0 	movw   $0x8,0xf0229282
f0102cd0:	08 00 
f0102cd2:	c6 05 84 92 22 f0 00 	movb   $0x0,0xf0229284
f0102cd9:	c6 05 85 92 22 f0 8e 	movb   $0x8e,0xf0229285
f0102ce0:	c1 e8 10             	shr    $0x10,%eax
f0102ce3:	66 a3 86 92 22 f0    	mov    %ax,0xf0229286
    SETGATE(idt[T_BOUND], 0, GD_KT, handler5, 0); 
f0102ce9:	b8 b2 33 10 f0       	mov    $0xf01033b2,%eax
f0102cee:	66 a3 88 92 22 f0    	mov    %ax,0xf0229288
f0102cf4:	66 c7 05 8a 92 22 f0 	movw   $0x8,0xf022928a
f0102cfb:	08 00 
f0102cfd:	c6 05 8c 92 22 f0 00 	movb   $0x0,0xf022928c
f0102d04:	c6 05 8d 92 22 f0 8e 	movb   $0x8e,0xf022928d
f0102d0b:	c1 e8 10             	shr    $0x10,%eax
f0102d0e:	66 a3 8e 92 22 f0    	mov    %ax,0xf022928e
    SETGATE(idt[T_ILLOP], 0, GD_KT, handler6, 0); 
f0102d14:	b8 b8 33 10 f0       	mov    $0xf01033b8,%eax
f0102d19:	66 a3 90 92 22 f0    	mov    %ax,0xf0229290
f0102d1f:	66 c7 05 92 92 22 f0 	movw   $0x8,0xf0229292
f0102d26:	08 00 
f0102d28:	c6 05 94 92 22 f0 00 	movb   $0x0,0xf0229294
f0102d2f:	c6 05 95 92 22 f0 8e 	movb   $0x8e,0xf0229295
f0102d36:	c1 e8 10             	shr    $0x10,%eax
f0102d39:	66 a3 96 92 22 f0    	mov    %ax,0xf0229296
    SETGATE(idt[T_DEVICE], 0, GD_KT, handler7, 0); 
f0102d3f:	b8 be 33 10 f0       	mov    $0xf01033be,%eax
f0102d44:	66 a3 98 92 22 f0    	mov    %ax,0xf0229298
f0102d4a:	66 c7 05 9a 92 22 f0 	movw   $0x8,0xf022929a
f0102d51:	08 00 
f0102d53:	c6 05 9c 92 22 f0 00 	movb   $0x0,0xf022929c
f0102d5a:	c6 05 9d 92 22 f0 8e 	movb   $0x8e,0xf022929d
f0102d61:	c1 e8 10             	shr    $0x10,%eax
f0102d64:	66 a3 9e 92 22 f0    	mov    %ax,0xf022929e
    SETGATE(idt[T_DBLFLT], 0, GD_KT, handler8, 0); 
f0102d6a:	b8 c2 33 10 f0       	mov    $0xf01033c2,%eax
f0102d6f:	66 a3 a0 92 22 f0    	mov    %ax,0xf02292a0
f0102d75:	66 c7 05 a2 92 22 f0 	movw   $0x8,0xf02292a2
f0102d7c:	08 00 
f0102d7e:	c6 05 a4 92 22 f0 00 	movb   $0x0,0xf02292a4
f0102d85:	c6 05 a5 92 22 f0 8e 	movb   $0x8e,0xf02292a5
f0102d8c:	c1 e8 10             	shr    $0x10,%eax
f0102d8f:	66 a3 a6 92 22 f0    	mov    %ax,0xf02292a6
    SETGATE(idt[T_TSS], 0, GD_KT, handler10, 0); 
f0102d95:	b8 c8 33 10 f0       	mov    $0xf01033c8,%eax
f0102d9a:	66 a3 b0 92 22 f0    	mov    %ax,0xf02292b0
f0102da0:	66 c7 05 b2 92 22 f0 	movw   $0x8,0xf02292b2
f0102da7:	08 00 
f0102da9:	c6 05 b4 92 22 f0 00 	movb   $0x0,0xf02292b4
f0102db0:	c6 05 b5 92 22 f0 8e 	movb   $0x8e,0xf02292b5
f0102db7:	c1 e8 10             	shr    $0x10,%eax
f0102dba:	66 a3 b6 92 22 f0    	mov    %ax,0xf02292b6
    SETGATE(idt[T_SEGNP], 0, GD_KT, handler11, 0); 
f0102dc0:	b8 cc 33 10 f0       	mov    $0xf01033cc,%eax
f0102dc5:	66 a3 b8 92 22 f0    	mov    %ax,0xf02292b8
f0102dcb:	66 c7 05 ba 92 22 f0 	movw   $0x8,0xf02292ba
f0102dd2:	08 00 
f0102dd4:	c6 05 bc 92 22 f0 00 	movb   $0x0,0xf02292bc
f0102ddb:	c6 05 bd 92 22 f0 8e 	movb   $0x8e,0xf02292bd
f0102de2:	c1 e8 10             	shr    $0x10,%eax
f0102de5:	66 a3 be 92 22 f0    	mov    %ax,0xf02292be
    SETGATE(idt[T_STACK], 0, GD_KT, handler12, 0); 
f0102deb:	b8 d0 33 10 f0       	mov    $0xf01033d0,%eax
f0102df0:	66 a3 c0 92 22 f0    	mov    %ax,0xf02292c0
f0102df6:	66 c7 05 c2 92 22 f0 	movw   $0x8,0xf02292c2
f0102dfd:	08 00 
f0102dff:	c6 05 c4 92 22 f0 00 	movb   $0x0,0xf02292c4
f0102e06:	c6 05 c5 92 22 f0 8e 	movb   $0x8e,0xf02292c5
f0102e0d:	c1 e8 10             	shr    $0x10,%eax
f0102e10:	66 a3 c6 92 22 f0    	mov    %ax,0xf02292c6
    SETGATE(idt[T_GPFLT], 0, GD_KT, handler13, 0); 
f0102e16:	b8 d4 33 10 f0       	mov    $0xf01033d4,%eax
f0102e1b:	66 a3 c8 92 22 f0    	mov    %ax,0xf02292c8
f0102e21:	66 c7 05 ca 92 22 f0 	movw   $0x8,0xf02292ca
f0102e28:	08 00 
f0102e2a:	c6 05 cc 92 22 f0 00 	movb   $0x0,0xf02292cc
f0102e31:	c6 05 cd 92 22 f0 8e 	movb   $0x8e,0xf02292cd
f0102e38:	c1 e8 10             	shr    $0x10,%eax
f0102e3b:	66 a3 ce 92 22 f0    	mov    %ax,0xf02292ce
    SETGATE(idt[T_PGFLT], 0, GD_KT, handler14, 0); 
f0102e41:	b8 d8 33 10 f0       	mov    $0xf01033d8,%eax
f0102e46:	66 a3 d0 92 22 f0    	mov    %ax,0xf02292d0
f0102e4c:	66 c7 05 d2 92 22 f0 	movw   $0x8,0xf02292d2
f0102e53:	08 00 
f0102e55:	c6 05 d4 92 22 f0 00 	movb   $0x0,0xf02292d4
f0102e5c:	c6 05 d5 92 22 f0 8e 	movb   $0x8e,0xf02292d5
f0102e63:	c1 e8 10             	shr    $0x10,%eax
f0102e66:	66 a3 d6 92 22 f0    	mov    %ax,0xf02292d6
    SETGATE(idt[T_FPERR], 0, GD_KT, handler16, 0); 
f0102e6c:	b8 dc 33 10 f0       	mov    $0xf01033dc,%eax
f0102e71:	66 a3 e0 92 22 f0    	mov    %ax,0xf02292e0
f0102e77:	66 c7 05 e2 92 22 f0 	movw   $0x8,0xf02292e2
f0102e7e:	08 00 
f0102e80:	c6 05 e4 92 22 f0 00 	movb   $0x0,0xf02292e4
f0102e87:	c6 05 e5 92 22 f0 8e 	movb   $0x8e,0xf02292e5
f0102e8e:	c1 e8 10             	shr    $0x10,%eax
f0102e91:	66 a3 e6 92 22 f0    	mov    %ax,0xf02292e6
    SETGATE(idt[T_SYSCALL], 0, GD_KT, handler48, 3); 
f0102e97:	b8 e2 33 10 f0       	mov    $0xf01033e2,%eax
f0102e9c:	66 a3 e0 93 22 f0    	mov    %ax,0xf02293e0
f0102ea2:	66 c7 05 e2 93 22 f0 	movw   $0x8,0xf02293e2
f0102ea9:	08 00 
f0102eab:	c6 05 e4 93 22 f0 00 	movb   $0x0,0xf02293e4
f0102eb2:	c6 05 e5 93 22 f0 ee 	movb   $0xee,0xf02293e5
f0102eb9:	c1 e8 10             	shr    $0x10,%eax
f0102ebc:	66 a3 e6 93 22 f0    	mov    %ax,0xf02293e6
	trap_init_percpu();
f0102ec2:	e8 e2 fc ff ff       	call   f0102ba9 <trap_init_percpu>
}
f0102ec7:	5d                   	pop    %ebp
f0102ec8:	c3                   	ret    

f0102ec9 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0102ec9:	55                   	push   %ebp
f0102eca:	89 e5                	mov    %esp,%ebp
f0102ecc:	53                   	push   %ebx
f0102ecd:	83 ec 0c             	sub    $0xc,%esp
f0102ed0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0102ed3:	ff 33                	pushl  (%ebx)
f0102ed5:	68 31 5c 10 f0       	push   $0xf0105c31
f0102eda:	e8 b6 fc ff ff       	call   f0102b95 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0102edf:	83 c4 08             	add    $0x8,%esp
f0102ee2:	ff 73 04             	pushl  0x4(%ebx)
f0102ee5:	68 40 5c 10 f0       	push   $0xf0105c40
f0102eea:	e8 a6 fc ff ff       	call   f0102b95 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0102eef:	83 c4 08             	add    $0x8,%esp
f0102ef2:	ff 73 08             	pushl  0x8(%ebx)
f0102ef5:	68 4f 5c 10 f0       	push   $0xf0105c4f
f0102efa:	e8 96 fc ff ff       	call   f0102b95 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0102eff:	83 c4 08             	add    $0x8,%esp
f0102f02:	ff 73 0c             	pushl  0xc(%ebx)
f0102f05:	68 5e 5c 10 f0       	push   $0xf0105c5e
f0102f0a:	e8 86 fc ff ff       	call   f0102b95 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0102f0f:	83 c4 08             	add    $0x8,%esp
f0102f12:	ff 73 10             	pushl  0x10(%ebx)
f0102f15:	68 6d 5c 10 f0       	push   $0xf0105c6d
f0102f1a:	e8 76 fc ff ff       	call   f0102b95 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0102f1f:	83 c4 08             	add    $0x8,%esp
f0102f22:	ff 73 14             	pushl  0x14(%ebx)
f0102f25:	68 7c 5c 10 f0       	push   $0xf0105c7c
f0102f2a:	e8 66 fc ff ff       	call   f0102b95 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0102f2f:	83 c4 08             	add    $0x8,%esp
f0102f32:	ff 73 18             	pushl  0x18(%ebx)
f0102f35:	68 8b 5c 10 f0       	push   $0xf0105c8b
f0102f3a:	e8 56 fc ff ff       	call   f0102b95 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0102f3f:	83 c4 08             	add    $0x8,%esp
f0102f42:	ff 73 1c             	pushl  0x1c(%ebx)
f0102f45:	68 9a 5c 10 f0       	push   $0xf0105c9a
f0102f4a:	e8 46 fc ff ff       	call   f0102b95 <cprintf>
}
f0102f4f:	83 c4 10             	add    $0x10,%esp
f0102f52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f55:	c9                   	leave  
f0102f56:	c3                   	ret    

f0102f57 <print_trapframe>:
{
f0102f57:	55                   	push   %ebp
f0102f58:	89 e5                	mov    %esp,%ebp
f0102f5a:	56                   	push   %esi
f0102f5b:	53                   	push   %ebx
f0102f5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0102f5f:	e8 df 17 00 00       	call   f0104743 <cpunum>
f0102f64:	83 ec 04             	sub    $0x4,%esp
f0102f67:	50                   	push   %eax
f0102f68:	53                   	push   %ebx
f0102f69:	68 fe 5c 10 f0       	push   $0xf0105cfe
f0102f6e:	e8 22 fc ff ff       	call   f0102b95 <cprintf>
	print_regs(&tf->tf_regs);
f0102f73:	89 1c 24             	mov    %ebx,(%esp)
f0102f76:	e8 4e ff ff ff       	call   f0102ec9 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0102f7b:	83 c4 08             	add    $0x8,%esp
f0102f7e:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0102f82:	50                   	push   %eax
f0102f83:	68 1c 5d 10 f0       	push   $0xf0105d1c
f0102f88:	e8 08 fc ff ff       	call   f0102b95 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0102f8d:	83 c4 08             	add    $0x8,%esp
f0102f90:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0102f94:	50                   	push   %eax
f0102f95:	68 2f 5d 10 f0       	push   $0xf0105d2f
f0102f9a:	e8 f6 fb ff ff       	call   f0102b95 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0102f9f:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0102fa2:	83 c4 10             	add    $0x10,%esp
f0102fa5:	83 f8 13             	cmp    $0x13,%eax
f0102fa8:	76 1f                	jbe    f0102fc9 <print_trapframe+0x72>
		return "System call";
f0102faa:	ba a9 5c 10 f0       	mov    $0xf0105ca9,%edx
	if (trapno == T_SYSCALL)
f0102faf:	83 f8 30             	cmp    $0x30,%eax
f0102fb2:	74 1c                	je     f0102fd0 <print_trapframe+0x79>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0102fb4:	8d 50 e0             	lea    -0x20(%eax),%edx
	return "(unknown trap)";
f0102fb7:	83 fa 10             	cmp    $0x10,%edx
f0102fba:	ba b5 5c 10 f0       	mov    $0xf0105cb5,%edx
f0102fbf:	b9 c8 5c 10 f0       	mov    $0xf0105cc8,%ecx
f0102fc4:	0f 43 d1             	cmovae %ecx,%edx
f0102fc7:	eb 07                	jmp    f0102fd0 <print_trapframe+0x79>
		return excnames[trapno];
f0102fc9:	8b 14 85 c0 5f 10 f0 	mov    -0xfefa040(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0102fd0:	83 ec 04             	sub    $0x4,%esp
f0102fd3:	52                   	push   %edx
f0102fd4:	50                   	push   %eax
f0102fd5:	68 42 5d 10 f0       	push   $0xf0105d42
f0102fda:	e8 b6 fb ff ff       	call   f0102b95 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0102fdf:	83 c4 10             	add    $0x10,%esp
f0102fe2:	39 1d 60 9a 22 f0    	cmp    %ebx,0xf0229a60
f0102fe8:	0f 84 a6 00 00 00    	je     f0103094 <print_trapframe+0x13d>
	cprintf("  err  0x%08x", tf->tf_err);
f0102fee:	83 ec 08             	sub    $0x8,%esp
f0102ff1:	ff 73 2c             	pushl  0x2c(%ebx)
f0102ff4:	68 63 5d 10 f0       	push   $0xf0105d63
f0102ff9:	e8 97 fb ff ff       	call   f0102b95 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0102ffe:	83 c4 10             	add    $0x10,%esp
f0103001:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103005:	0f 85 ac 00 00 00    	jne    f01030b7 <print_trapframe+0x160>
			tf->tf_err & 1 ? "protection" : "not-present");
f010300b:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f010300e:	89 c2                	mov    %eax,%edx
f0103010:	83 e2 01             	and    $0x1,%edx
f0103013:	b9 d7 5c 10 f0       	mov    $0xf0105cd7,%ecx
f0103018:	ba e2 5c 10 f0       	mov    $0xf0105ce2,%edx
f010301d:	0f 44 ca             	cmove  %edx,%ecx
f0103020:	89 c2                	mov    %eax,%edx
f0103022:	83 e2 02             	and    $0x2,%edx
f0103025:	be ee 5c 10 f0       	mov    $0xf0105cee,%esi
f010302a:	ba f4 5c 10 f0       	mov    $0xf0105cf4,%edx
f010302f:	0f 45 d6             	cmovne %esi,%edx
f0103032:	83 e0 04             	and    $0x4,%eax
f0103035:	b8 f9 5c 10 f0       	mov    $0xf0105cf9,%eax
f010303a:	be 47 5e 10 f0       	mov    $0xf0105e47,%esi
f010303f:	0f 44 c6             	cmove  %esi,%eax
f0103042:	51                   	push   %ecx
f0103043:	52                   	push   %edx
f0103044:	50                   	push   %eax
f0103045:	68 71 5d 10 f0       	push   $0xf0105d71
f010304a:	e8 46 fb ff ff       	call   f0102b95 <cprintf>
f010304f:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103052:	83 ec 08             	sub    $0x8,%esp
f0103055:	ff 73 30             	pushl  0x30(%ebx)
f0103058:	68 80 5d 10 f0       	push   $0xf0105d80
f010305d:	e8 33 fb ff ff       	call   f0102b95 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103062:	83 c4 08             	add    $0x8,%esp
f0103065:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103069:	50                   	push   %eax
f010306a:	68 8f 5d 10 f0       	push   $0xf0105d8f
f010306f:	e8 21 fb ff ff       	call   f0102b95 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103074:	83 c4 08             	add    $0x8,%esp
f0103077:	ff 73 38             	pushl  0x38(%ebx)
f010307a:	68 a2 5d 10 f0       	push   $0xf0105da2
f010307f:	e8 11 fb ff ff       	call   f0102b95 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103084:	83 c4 10             	add    $0x10,%esp
f0103087:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010308b:	75 3c                	jne    f01030c9 <print_trapframe+0x172>
}
f010308d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103090:	5b                   	pop    %ebx
f0103091:	5e                   	pop    %esi
f0103092:	5d                   	pop    %ebp
f0103093:	c3                   	ret    
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103094:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103098:	0f 85 50 ff ff ff    	jne    f0102fee <print_trapframe+0x97>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010309e:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01030a1:	83 ec 08             	sub    $0x8,%esp
f01030a4:	50                   	push   %eax
f01030a5:	68 54 5d 10 f0       	push   $0xf0105d54
f01030aa:	e8 e6 fa ff ff       	call   f0102b95 <cprintf>
f01030af:	83 c4 10             	add    $0x10,%esp
f01030b2:	e9 37 ff ff ff       	jmp    f0102fee <print_trapframe+0x97>
		cprintf("\n");
f01030b7:	83 ec 0c             	sub    $0xc,%esp
f01030ba:	68 4d 4e 10 f0       	push   $0xf0104e4d
f01030bf:	e8 d1 fa ff ff       	call   f0102b95 <cprintf>
f01030c4:	83 c4 10             	add    $0x10,%esp
f01030c7:	eb 89                	jmp    f0103052 <print_trapframe+0xfb>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01030c9:	83 ec 08             	sub    $0x8,%esp
f01030cc:	ff 73 3c             	pushl  0x3c(%ebx)
f01030cf:	68 b1 5d 10 f0       	push   $0xf0105db1
f01030d4:	e8 bc fa ff ff       	call   f0102b95 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01030d9:	83 c4 08             	add    $0x8,%esp
f01030dc:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01030e0:	50                   	push   %eax
f01030e1:	68 c0 5d 10 f0       	push   $0xf0105dc0
f01030e6:	e8 aa fa ff ff       	call   f0102b95 <cprintf>
f01030eb:	83 c4 10             	add    $0x10,%esp
}
f01030ee:	eb 9d                	jmp    f010308d <print_trapframe+0x136>

f01030f0 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01030f0:	55                   	push   %ebp
f01030f1:	89 e5                	mov    %esp,%ebp
f01030f3:	57                   	push   %edi
f01030f4:	56                   	push   %esi
f01030f5:	53                   	push   %ebx
f01030f6:	83 ec 0c             	sub    $0xc,%esp
f01030f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01030fc:	0f 20 d6             	mov    %cr2,%esi
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01030ff:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103102:	e8 3c 16 00 00       	call   f0104743 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103107:	57                   	push   %edi
f0103108:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103109:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010310c:	8b 80 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%eax
f0103112:	ff 70 48             	pushl  0x48(%eax)
f0103115:	68 94 5f 10 f0       	push   $0xf0105f94
f010311a:	e8 76 fa ff ff       	call   f0102b95 <cprintf>
	print_trapframe(tf);
f010311f:	89 1c 24             	mov    %ebx,(%esp)
f0103122:	e8 30 fe ff ff       	call   f0102f57 <print_trapframe>
	env_destroy(curenv);
f0103127:	e8 17 16 00 00       	call   f0104743 <cpunum>
f010312c:	83 c4 04             	add    $0x4,%esp
f010312f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103132:	ff b0 28 a0 22 f0    	pushl  -0xfdd5fd8(%eax)
f0103138:	e8 6b f7 ff ff       	call   f01028a8 <env_destroy>
}
f010313d:	83 c4 10             	add    $0x10,%esp
f0103140:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103143:	5b                   	pop    %ebx
f0103144:	5e                   	pop    %esi
f0103145:	5f                   	pop    %edi
f0103146:	5d                   	pop    %ebp
f0103147:	c3                   	ret    

f0103148 <trap>:
{
f0103148:	55                   	push   %ebp
f0103149:	89 e5                	mov    %esp,%ebp
f010314b:	57                   	push   %edi
f010314c:	56                   	push   %esi
f010314d:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0103150:	fc                   	cld    
	if (panicstr)
f0103151:	83 3d 00 9f 22 f0 00 	cmpl   $0x0,0xf0229f00
f0103158:	74 01                	je     f010315b <trap+0x13>
		asm volatile("hlt");
f010315a:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010315b:	e8 e3 15 00 00       	call   f0104743 <cpunum>
f0103160:	6b d0 74             	imul   $0x74,%eax,%edx
f0103163:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0103166:	b8 01 00 00 00       	mov    $0x1,%eax
f010316b:	f0 87 82 20 a0 22 f0 	lock xchg %eax,-0xfdd5fe0(%edx)
f0103172:	83 f8 02             	cmp    $0x2,%eax
f0103175:	0f 84 b1 00 00 00    	je     f010322c <trap+0xe4>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010317b:	9c                   	pushf  
f010317c:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f010317d:	f6 c4 02             	test   $0x2,%ah
f0103180:	0f 85 bb 00 00 00    	jne    f0103241 <trap+0xf9>
	if ((tf->tf_cs & 3) == 3) {
f0103186:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010318a:	83 e0 03             	and    $0x3,%eax
f010318d:	66 83 f8 03          	cmp    $0x3,%ax
f0103191:	0f 84 c3 00 00 00    	je     f010325a <trap+0x112>
	last_tf = tf;
f0103197:	89 35 60 9a 22 f0    	mov    %esi,0xf0229a60
	if ((tf->tf_cs & 3) == 0) {
f010319d:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f01031a1:	0f 84 48 01 00 00    	je     f01032ef <trap+0x1a7>
	if (tf->tf_trapno == T_SYSCALL) {
f01031a7:	8b 46 28             	mov    0x28(%esi),%eax
f01031aa:	83 f8 30             	cmp    $0x30,%eax
f01031ad:	0f 84 51 01 00 00    	je     f0103304 <trap+0x1bc>
	if (tf->tf_trapno == T_PGFLT) {
f01031b3:	83 f8 0e             	cmp    $0xe,%eax
f01031b6:	0f 84 6c 01 00 00    	je     f0103328 <trap+0x1e0>
    	if (tf->tf_trapno == T_BRKPT) {
f01031bc:	83 f8 03             	cmp    $0x3,%eax
f01031bf:	0f 84 74 01 00 00    	je     f0103339 <trap+0x1f1>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01031c5:	83 f8 27             	cmp    $0x27,%eax
f01031c8:	0f 84 7c 01 00 00    	je     f010334a <trap+0x202>
	print_trapframe(tf);
f01031ce:	83 ec 0c             	sub    $0xc,%esp
f01031d1:	56                   	push   %esi
f01031d2:	e8 80 fd ff ff       	call   f0102f57 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01031d7:	83 c4 10             	add    $0x10,%esp
f01031da:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01031df:	0f 84 82 01 00 00    	je     f0103367 <trap+0x21f>
		env_destroy(curenv);
f01031e5:	e8 59 15 00 00       	call   f0104743 <cpunum>
f01031ea:	83 ec 0c             	sub    $0xc,%esp
f01031ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01031f0:	ff b0 28 a0 22 f0    	pushl  -0xfdd5fd8(%eax)
f01031f6:	e8 ad f6 ff ff       	call   f01028a8 <env_destroy>
f01031fb:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f01031fe:	e8 40 15 00 00       	call   f0104743 <cpunum>
f0103203:	6b c0 74             	imul   $0x74,%eax,%eax
f0103206:	83 b8 28 a0 22 f0 00 	cmpl   $0x0,-0xfdd5fd8(%eax)
f010320d:	74 18                	je     f0103227 <trap+0xdf>
f010320f:	e8 2f 15 00 00       	call   f0104743 <cpunum>
f0103214:	6b c0 74             	imul   $0x74,%eax,%eax
f0103217:	8b 80 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%eax
f010321d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103221:	0f 84 57 01 00 00    	je     f010337e <trap+0x236>
		sched_yield();
f0103227:	e8 a0 02 00 00       	call   f01034cc <sched_yield>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010322c:	83 ec 0c             	sub    $0xc,%esp
f010322f:	68 a0 e3 11 f0       	push   $0xf011e3a0
f0103234:	e8 7a 17 00 00       	call   f01049b3 <spin_lock>
f0103239:	83 c4 10             	add    $0x10,%esp
f010323c:	e9 3a ff ff ff       	jmp    f010317b <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0103241:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0103246:	68 32 59 10 f0       	push   $0xf0105932
f010324b:	68 19 01 00 00       	push   $0x119
f0103250:	68 ec 5d 10 f0       	push   $0xf0105dec
f0103255:	e8 e6 cd ff ff       	call   f0100040 <_panic>
		assert(curenv);
f010325a:	e8 e4 14 00 00       	call   f0104743 <cpunum>
f010325f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103262:	83 b8 28 a0 22 f0 00 	cmpl   $0x0,-0xfdd5fd8(%eax)
f0103269:	74 3e                	je     f01032a9 <trap+0x161>
		if (curenv->env_status == ENV_DYING) {
f010326b:	e8 d3 14 00 00       	call   f0104743 <cpunum>
f0103270:	6b c0 74             	imul   $0x74,%eax,%eax
f0103273:	8b 80 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%eax
f0103279:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010327d:	74 43                	je     f01032c2 <trap+0x17a>
		curenv->env_tf = *tf;
f010327f:	e8 bf 14 00 00       	call   f0104743 <cpunum>
f0103284:	6b c0 74             	imul   $0x74,%eax,%eax
f0103287:	8b 80 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%eax
f010328d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103292:	89 c7                	mov    %eax,%edi
f0103294:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0103296:	e8 a8 14 00 00       	call   f0104743 <cpunum>
f010329b:	6b c0 74             	imul   $0x74,%eax,%eax
f010329e:	8b b0 28 a0 22 f0    	mov    -0xfdd5fd8(%eax),%esi
f01032a4:	e9 ee fe ff ff       	jmp    f0103197 <trap+0x4f>
		assert(curenv);
f01032a9:	68 f8 5d 10 f0       	push   $0xf0105df8
f01032ae:	68 32 59 10 f0       	push   $0xf0105932
f01032b3:	68 20 01 00 00       	push   $0x120
f01032b8:	68 ec 5d 10 f0       	push   $0xf0105dec
f01032bd:	e8 7e cd ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f01032c2:	e8 7c 14 00 00       	call   f0104743 <cpunum>
f01032c7:	83 ec 0c             	sub    $0xc,%esp
f01032ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01032cd:	ff b0 28 a0 22 f0    	pushl  -0xfdd5fd8(%eax)
f01032d3:	e8 e2 f3 ff ff       	call   f01026ba <env_free>
			curenv = NULL;
f01032d8:	e8 66 14 00 00       	call   f0104743 <cpunum>
f01032dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01032e0:	c7 80 28 a0 22 f0 00 	movl   $0x0,-0xfdd5fd8(%eax)
f01032e7:	00 00 00 
			sched_yield();
f01032ea:	e8 dd 01 00 00       	call   f01034cc <sched_yield>
        	panic("kernel page fault at:%x\n", tf);
f01032ef:	56                   	push   %esi
f01032f0:	68 ff 5d 10 f0       	push   $0xf0105dff
f01032f5:	68 da 00 00 00       	push   $0xda
f01032fa:	68 ec 5d 10 f0       	push   $0xf0105dec
f01032ff:	e8 3c cd ff ff       	call   f0100040 <_panic>
        	tf->tf_regs.reg_eax = syscall(
f0103304:	83 ec 08             	sub    $0x8,%esp
f0103307:	ff 76 04             	pushl  0x4(%esi)
f010330a:	ff 36                	pushl  (%esi)
f010330c:	ff 76 10             	pushl  0x10(%esi)
f010330f:	ff 76 18             	pushl  0x18(%esi)
f0103312:	ff 76 14             	pushl  0x14(%esi)
f0103315:	ff 76 1c             	pushl  0x1c(%esi)
f0103318:	e8 bc 01 00 00       	call   f01034d9 <syscall>
f010331d:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103320:	83 c4 20             	add    $0x20,%esp
f0103323:	e9 d6 fe ff ff       	jmp    f01031fe <trap+0xb6>
        	return page_fault_handler(tf);
f0103328:	83 ec 0c             	sub    $0xc,%esp
f010332b:	56                   	push   %esi
f010332c:	e8 bf fd ff ff       	call   f01030f0 <page_fault_handler>
f0103331:	83 c4 10             	add    $0x10,%esp
f0103334:	e9 c5 fe ff ff       	jmp    f01031fe <trap+0xb6>
        	return monitor(tf);
f0103339:	83 ec 0c             	sub    $0xc,%esp
f010333c:	56                   	push   %esi
f010333d:	e8 c3 d5 ff ff       	call   f0100905 <monitor>
f0103342:	83 c4 10             	add    $0x10,%esp
f0103345:	e9 b4 fe ff ff       	jmp    f01031fe <trap+0xb6>
		cprintf("Spurious interrupt on irq 7\n");
f010334a:	83 ec 0c             	sub    $0xc,%esp
f010334d:	68 18 5e 10 f0       	push   $0xf0105e18
f0103352:	e8 3e f8 ff ff       	call   f0102b95 <cprintf>
		print_trapframe(tf);
f0103357:	89 34 24             	mov    %esi,(%esp)
f010335a:	e8 f8 fb ff ff       	call   f0102f57 <print_trapframe>
f010335f:	83 c4 10             	add    $0x10,%esp
f0103362:	e9 97 fe ff ff       	jmp    f01031fe <trap+0xb6>
		panic("unhandled trap in kernel");
f0103367:	83 ec 04             	sub    $0x4,%esp
f010336a:	68 35 5e 10 f0       	push   $0xf0105e35
f010336f:	68 ff 00 00 00       	push   $0xff
f0103374:	68 ec 5d 10 f0       	push   $0xf0105dec
f0103379:	e8 c2 cc ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f010337e:	e8 c0 13 00 00       	call   f0104743 <cpunum>
f0103383:	83 ec 0c             	sub    $0xc,%esp
f0103386:	6b c0 74             	imul   $0x74,%eax,%eax
f0103389:	ff b0 28 a0 22 f0    	pushl  -0xfdd5fd8(%eax)
f010338f:	e8 b3 f5 ff ff       	call   f0102947 <env_run>

f0103394 <handler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f0103394:	6a 00                	push   $0x0
f0103396:	6a 00                	push   $0x0
f0103398:	eb 4e                	jmp    f01033e8 <_alltraps>

f010339a <handler1>:
TRAPHANDLER_NOEC(handler1, T_DEBUG)
f010339a:	6a 00                	push   $0x0
f010339c:	6a 01                	push   $0x1
f010339e:	eb 48                	jmp    f01033e8 <_alltraps>

f01033a0 <handler2>:
TRAPHANDLER_NOEC(handler2, T_NMI)
f01033a0:	6a 00                	push   $0x0
f01033a2:	6a 02                	push   $0x2
f01033a4:	eb 42                	jmp    f01033e8 <_alltraps>

f01033a6 <handler3>:
TRAPHANDLER_NOEC(handler3, T_BRKPT)
f01033a6:	6a 00                	push   $0x0
f01033a8:	6a 03                	push   $0x3
f01033aa:	eb 3c                	jmp    f01033e8 <_alltraps>

f01033ac <handler4>:
TRAPHANDLER_NOEC(handler4, T_OFLOW)
f01033ac:	6a 00                	push   $0x0
f01033ae:	6a 04                	push   $0x4
f01033b0:	eb 36                	jmp    f01033e8 <_alltraps>

f01033b2 <handler5>:
TRAPHANDLER_NOEC(handler5, T_BOUND)
f01033b2:	6a 00                	push   $0x0
f01033b4:	6a 05                	push   $0x5
f01033b6:	eb 30                	jmp    f01033e8 <_alltraps>

f01033b8 <handler6>:
TRAPHANDLER_NOEC(handler6, T_ILLOP)
f01033b8:	6a 00                	push   $0x0
f01033ba:	6a 06                	push   $0x6
f01033bc:	eb 2a                	jmp    f01033e8 <_alltraps>

f01033be <handler7>:
TRAPHANDLER(handler7, T_DEVICE)
f01033be:	6a 07                	push   $0x7
f01033c0:	eb 26                	jmp    f01033e8 <_alltraps>

f01033c2 <handler8>:
TRAPHANDLER_NOEC(handler8, T_DBLFLT)
f01033c2:	6a 00                	push   $0x0
f01033c4:	6a 08                	push   $0x8
f01033c6:	eb 20                	jmp    f01033e8 <_alltraps>

f01033c8 <handler10>:
TRAPHANDLER(handler10, T_TSS)
f01033c8:	6a 0a                	push   $0xa
f01033ca:	eb 1c                	jmp    f01033e8 <_alltraps>

f01033cc <handler11>:
TRAPHANDLER(handler11, T_SEGNP)
f01033cc:	6a 0b                	push   $0xb
f01033ce:	eb 18                	jmp    f01033e8 <_alltraps>

f01033d0 <handler12>:
TRAPHANDLER(handler12, T_STACK)
f01033d0:	6a 0c                	push   $0xc
f01033d2:	eb 14                	jmp    f01033e8 <_alltraps>

f01033d4 <handler13>:
TRAPHANDLER(handler13, T_GPFLT)
f01033d4:	6a 0d                	push   $0xd
f01033d6:	eb 10                	jmp    f01033e8 <_alltraps>

f01033d8 <handler14>:
TRAPHANDLER(handler14, T_PGFLT)
f01033d8:	6a 0e                	push   $0xe
f01033da:	eb 0c                	jmp    f01033e8 <_alltraps>

f01033dc <handler16>:
TRAPHANDLER_NOEC(handler16, T_FPERR)
f01033dc:	6a 00                	push   $0x0
f01033de:	6a 10                	push   $0x10
f01033e0:	eb 06                	jmp    f01033e8 <_alltraps>

f01033e2 <handler48>:
TRAPHANDLER_NOEC(handler48, T_SYSCALL)
f01033e2:	6a 00                	push   $0x0
f01033e4:	6a 30                	push   $0x30
f01033e6:	eb 00                	jmp    f01033e8 <_alltraps>

f01033e8 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
        pushl %ds 
f01033e8:	1e                   	push   %ds
        pushl %es 
f01033e9:	06                   	push   %es
        pushal
f01033ea:	60                   	pusha  
        movw $GD_KD, %ax
f01033eb:	66 b8 10 00          	mov    $0x10,%ax
        movw %ax, %ds 
f01033ef:	8e d8                	mov    %eax,%ds
        movw %ax, %es 
f01033f1:	8e c0                	mov    %eax,%es
        pushl %esp
f01033f3:	54                   	push   %esp
        call trap /*never return*/
f01033f4:	e8 4f fd ff ff       	call   f0103148 <trap>

1:jmp 1b
f01033f9:	eb fe                	jmp    f01033f9 <_alltraps+0x11>

f01033fb <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01033fb:	55                   	push   %ebp
f01033fc:	89 e5                	mov    %esp,%ebp
f01033fe:	83 ec 08             	sub    $0x8,%esp
f0103401:	a1 48 92 22 f0       	mov    0xf0229248,%eax
f0103406:	83 c0 54             	add    $0x54,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103409:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f010340e:	8b 10                	mov    (%eax),%edx
f0103410:	83 ea 01             	sub    $0x1,%edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0103413:	83 fa 02             	cmp    $0x2,%edx
f0103416:	76 2d                	jbe    f0103445 <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f0103418:	83 c1 01             	add    $0x1,%ecx
f010341b:	83 c0 7c             	add    $0x7c,%eax
f010341e:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103424:	75 e8                	jne    f010340e <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0103426:	83 ec 0c             	sub    $0xc,%esp
f0103429:	68 10 60 10 f0       	push   $0xf0106010
f010342e:	e8 62 f7 ff ff       	call   f0102b95 <cprintf>
f0103433:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0103436:	83 ec 0c             	sub    $0xc,%esp
f0103439:	6a 00                	push   $0x0
f010343b:	e8 c5 d4 ff ff       	call   f0100905 <monitor>
f0103440:	83 c4 10             	add    $0x10,%esp
f0103443:	eb f1                	jmp    f0103436 <sched_halt+0x3b>
	if (i == NENV) {
f0103445:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010344b:	74 d9                	je     f0103426 <sched_halt+0x2b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010344d:	e8 f1 12 00 00       	call   f0104743 <cpunum>
f0103452:	6b c0 74             	imul   $0x74,%eax,%eax
f0103455:	c7 80 28 a0 22 f0 00 	movl   $0x0,-0xfdd5fd8(%eax)
f010345c:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010345f:	a1 0c 9f 22 f0       	mov    0xf0229f0c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103464:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103469:	76 4f                	jbe    f01034ba <sched_halt+0xbf>
	return (physaddr_t)kva - KERNBASE;
f010346b:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103470:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0103473:	e8 cb 12 00 00       	call   f0104743 <cpunum>
f0103478:	6b d0 74             	imul   $0x74,%eax,%edx
f010347b:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f010347e:	b8 02 00 00 00       	mov    $0x2,%eax
f0103483:	f0 87 82 20 a0 22 f0 	lock xchg %eax,-0xfdd5fe0(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010348a:	83 ec 0c             	sub    $0xc,%esp
f010348d:	68 a0 e3 11 f0       	push   $0xf011e3a0
f0103492:	e8 b9 15 00 00       	call   f0104a50 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103497:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0103499:	e8 a5 12 00 00       	call   f0104743 <cpunum>
f010349e:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f01034a1:	8b 80 30 a0 22 f0    	mov    -0xfdd5fd0(%eax),%eax
f01034a7:	bd 00 00 00 00       	mov    $0x0,%ebp
f01034ac:	89 c4                	mov    %eax,%esp
f01034ae:	6a 00                	push   $0x0
f01034b0:	6a 00                	push   $0x0
f01034b2:	f4                   	hlt    
f01034b3:	eb fd                	jmp    f01034b2 <sched_halt+0xb7>
}
f01034b5:	83 c4 10             	add    $0x10,%esp
f01034b8:	c9                   	leave  
f01034b9:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034ba:	50                   	push   %eax
f01034bb:	68 c8 4d 10 f0       	push   $0xf0104dc8
f01034c0:	6a 3d                	push   $0x3d
f01034c2:	68 39 60 10 f0       	push   $0xf0106039
f01034c7:	e8 74 cb ff ff       	call   f0100040 <_panic>

f01034cc <sched_yield>:
{
f01034cc:	55                   	push   %ebp
f01034cd:	89 e5                	mov    %esp,%ebp
f01034cf:	83 ec 08             	sub    $0x8,%esp
	sched_halt();
f01034d2:	e8 24 ff ff ff       	call   f01033fb <sched_halt>
}
f01034d7:	c9                   	leave  
f01034d8:	c3                   	ret    

f01034d9 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01034d9:	55                   	push   %ebp
f01034da:	89 e5                	mov    %esp,%ebp
f01034dc:	83 ec 0c             	sub    $0xc,%esp
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	panic("syscall not implemented");
f01034df:	68 46 60 10 f0       	push   $0xf0106046
f01034e4:	68 12 01 00 00       	push   $0x112
f01034e9:	68 5e 60 10 f0       	push   $0xf010605e
f01034ee:	e8 4d cb ff ff       	call   f0100040 <_panic>

f01034f3 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01034f3:	55                   	push   %ebp
f01034f4:	89 e5                	mov    %esp,%ebp
f01034f6:	57                   	push   %edi
f01034f7:	56                   	push   %esi
f01034f8:	53                   	push   %ebx
f01034f9:	83 ec 14             	sub    $0x14,%esp
f01034fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01034ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103502:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103505:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103508:	8b 32                	mov    (%edx),%esi
f010350a:	8b 01                	mov    (%ecx),%eax
f010350c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010350f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103516:	eb 2f                	jmp    f0103547 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103518:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f010351b:	39 c6                	cmp    %eax,%esi
f010351d:	7f 49                	jg     f0103568 <stab_binsearch+0x75>
f010351f:	0f b6 0a             	movzbl (%edx),%ecx
f0103522:	83 ea 0c             	sub    $0xc,%edx
f0103525:	39 f9                	cmp    %edi,%ecx
f0103527:	75 ef                	jne    f0103518 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103529:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010352c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010352f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103533:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103536:	73 35                	jae    f010356d <stab_binsearch+0x7a>
			*region_left = m;
f0103538:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010353b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f010353d:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0103540:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103547:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f010354a:	7f 4e                	jg     f010359a <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f010354c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010354f:	01 f0                	add    %esi,%eax
f0103551:	89 c3                	mov    %eax,%ebx
f0103553:	c1 eb 1f             	shr    $0x1f,%ebx
f0103556:	01 c3                	add    %eax,%ebx
f0103558:	d1 fb                	sar    %ebx
f010355a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010355d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103560:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103564:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0103566:	eb b3                	jmp    f010351b <stab_binsearch+0x28>
			l = true_m + 1;
f0103568:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f010356b:	eb da                	jmp    f0103547 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f010356d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103570:	76 14                	jbe    f0103586 <stab_binsearch+0x93>
			*region_right = m - 1;
f0103572:	83 e8 01             	sub    $0x1,%eax
f0103575:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103578:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010357b:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f010357d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103584:	eb c1                	jmp    f0103547 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103586:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103589:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010358b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010358f:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0103591:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103598:	eb ad                	jmp    f0103547 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f010359a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010359e:	74 16                	je     f01035b6 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01035a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035a3:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01035a5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01035a8:	8b 0e                	mov    (%esi),%ecx
f01035aa:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01035ad:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01035b0:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f01035b4:	eb 12                	jmp    f01035c8 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f01035b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035b9:	8b 00                	mov    (%eax),%eax
f01035bb:	83 e8 01             	sub    $0x1,%eax
f01035be:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01035c1:	89 07                	mov    %eax,(%edi)
f01035c3:	eb 16                	jmp    f01035db <stab_binsearch+0xe8>
		     l--)
f01035c5:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01035c8:	39 c1                	cmp    %eax,%ecx
f01035ca:	7d 0a                	jge    f01035d6 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f01035cc:	0f b6 1a             	movzbl (%edx),%ebx
f01035cf:	83 ea 0c             	sub    $0xc,%edx
f01035d2:	39 fb                	cmp    %edi,%ebx
f01035d4:	75 ef                	jne    f01035c5 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f01035d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01035d9:	89 07                	mov    %eax,(%edi)
	}
}
f01035db:	83 c4 14             	add    $0x14,%esp
f01035de:	5b                   	pop    %ebx
f01035df:	5e                   	pop    %esi
f01035e0:	5f                   	pop    %edi
f01035e1:	5d                   	pop    %ebp
f01035e2:	c3                   	ret    

f01035e3 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01035e3:	55                   	push   %ebp
f01035e4:	89 e5                	mov    %esp,%ebp
f01035e6:	57                   	push   %edi
f01035e7:	56                   	push   %esi
f01035e8:	53                   	push   %ebx
f01035e9:	83 ec 4c             	sub    $0x4c,%esp
f01035ec:	8b 7d 08             	mov    0x8(%ebp),%edi
f01035ef:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01035f2:	c7 06 6d 60 10 f0    	movl   $0xf010606d,(%esi)
	info->eip_line = 0;
f01035f8:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01035ff:	c7 46 08 6d 60 10 f0 	movl   $0xf010606d,0x8(%esi)
	info->eip_fn_namelen = 9;
f0103606:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f010360d:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0103610:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103617:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010361d:	0f 86 2c 01 00 00    	jbe    f010374f <debuginfo_eip+0x16c>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103623:	c7 45 b8 1f 37 11 f0 	movl   $0xf011371f,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f010362a:	c7 45 b4 a1 00 11 f0 	movl   $0xf01100a1,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0103631:	bb a0 00 11 f0       	mov    $0xf01100a0,%ebx
		stabs = __STAB_BEGIN__;
f0103636:	c7 45 bc 54 65 10 f0 	movl   $0xf0106554,-0x44(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
    		return -1;
	}	

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010363d:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0103640:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f0103643:	0f 83 80 02 00 00    	jae    f01038c9 <debuginfo_eip+0x2e6>
f0103649:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f010364d:	0f 85 7d 02 00 00    	jne    f01038d0 <debuginfo_eip+0x2ed>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103653:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010365a:	2b 5d bc             	sub    -0x44(%ebp),%ebx
f010365d:	c1 fb 02             	sar    $0x2,%ebx
f0103660:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f0103666:	83 e8 01             	sub    $0x1,%eax
f0103669:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010366c:	83 ec 08             	sub    $0x8,%esp
f010366f:	57                   	push   %edi
f0103670:	6a 64                	push   $0x64
f0103672:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0103675:	89 d1                	mov    %edx,%ecx
f0103677:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010367a:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f010367d:	89 d8                	mov    %ebx,%eax
f010367f:	e8 6f fe ff ff       	call   f01034f3 <stab_binsearch>
	if (lfile == 0)
f0103684:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103687:	83 c4 10             	add    $0x10,%esp
f010368a:	85 c0                	test   %eax,%eax
f010368c:	0f 84 45 02 00 00    	je     f01038d7 <debuginfo_eip+0x2f4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103692:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103695:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103698:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010369b:	83 ec 08             	sub    $0x8,%esp
f010369e:	57                   	push   %edi
f010369f:	6a 24                	push   $0x24
f01036a1:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01036a4:	89 d1                	mov    %edx,%ecx
f01036a6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01036a9:	89 d8                	mov    %ebx,%eax
f01036ab:	e8 43 fe ff ff       	call   f01034f3 <stab_binsearch>

	if (lfun <= rfun) {
f01036b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01036b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01036b6:	83 c4 10             	add    $0x10,%esp
f01036b9:	39 d0                	cmp    %edx,%eax
f01036bb:	0f 8f 3b 01 00 00    	jg     f01037fc <debuginfo_eip+0x219>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01036c1:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01036c4:	8d 1c 8b             	lea    (%ebx,%ecx,4),%ebx
f01036c7:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f01036ca:	8b 1b                	mov    (%ebx),%ebx
f01036cc:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f01036cf:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f01036d2:	39 cb                	cmp    %ecx,%ebx
f01036d4:	73 06                	jae    f01036dc <debuginfo_eip+0xf9>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01036d6:	03 5d b4             	add    -0x4c(%ebp),%ebx
f01036d9:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01036dc:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01036df:	8b 4b 08             	mov    0x8(%ebx),%ecx
f01036e2:	89 4e 10             	mov    %ecx,0x10(%esi)
		addr -= info->eip_fn_addr;
f01036e5:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f01036e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01036ea:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01036ed:	83 ec 08             	sub    $0x8,%esp
f01036f0:	6a 3a                	push   $0x3a
f01036f2:	ff 76 08             	pushl  0x8(%esi)
f01036f5:	e8 0a 0a 00 00       	call   f0104104 <strfind>
f01036fa:	2b 46 08             	sub    0x8(%esi),%eax
f01036fd:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103700:	83 c4 08             	add    $0x8,%esp
f0103703:	57                   	push   %edi
f0103704:	6a 44                	push   $0x44
f0103706:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103709:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010370c:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010370f:	89 f8                	mov    %edi,%eax
f0103711:	e8 dd fd ff ff       	call   f01034f3 <stab_binsearch>
	if (lline <= rline) {
f0103716:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103719:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010371c:	83 c4 10             	add    $0x10,%esp
f010371f:	39 c2                	cmp    %eax,%edx
f0103721:	0f 8f b7 01 00 00    	jg     f01038de <debuginfo_eip+0x2fb>
    		info->eip_line = stabs[rline].n_desc;
f0103727:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010372a:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f010372f:	89 46 04             	mov    %eax,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103732:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103735:	89 d0                	mov    %edx,%eax
f0103737:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010373a:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f010373e:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0103742:	bf 01 00 00 00       	mov    $0x1,%edi
f0103747:	89 75 0c             	mov    %esi,0xc(%ebp)
f010374a:	e9 cc 00 00 00       	jmp    f010381b <debuginfo_eip+0x238>
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010374f:	e8 ef 0f 00 00       	call   f0104743 <cpunum>
f0103754:	6a 04                	push   $0x4
f0103756:	6a 10                	push   $0x10
f0103758:	68 00 00 20 00       	push   $0x200000
f010375d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103760:	ff b0 28 a0 22 f0    	pushl  -0xfdd5fd8(%eax)
f0103766:	e8 88 ea ff ff       	call   f01021f3 <user_mem_check>
f010376b:	83 c4 10             	add    $0x10,%esp
f010376e:	85 c0                	test   %eax,%eax
f0103770:	0f 85 45 01 00 00    	jne    f01038bb <debuginfo_eip+0x2d8>
		stabs = usd->stabs;
f0103776:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f010377c:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stab_end = usd->stab_end;
f010377f:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f0103785:	a1 08 00 20 00       	mov    0x200008,%eax
f010378a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f010378d:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0103793:	89 55 b8             	mov    %edx,-0x48(%ebp)
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U))
f0103796:	e8 a8 0f 00 00       	call   f0104743 <cpunum>
f010379b:	6a 04                	push   $0x4
f010379d:	89 da                	mov    %ebx,%edx
f010379f:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f01037a2:	29 ca                	sub    %ecx,%edx
f01037a4:	c1 fa 02             	sar    $0x2,%edx
f01037a7:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01037ad:	52                   	push   %edx
f01037ae:	51                   	push   %ecx
f01037af:	6b c0 74             	imul   $0x74,%eax,%eax
f01037b2:	ff b0 28 a0 22 f0    	pushl  -0xfdd5fd8(%eax)
f01037b8:	e8 36 ea ff ff       	call   f01021f3 <user_mem_check>
f01037bd:	83 c4 10             	add    $0x10,%esp
f01037c0:	85 c0                	test   %eax,%eax
f01037c2:	0f 85 fa 00 00 00    	jne    f01038c2 <debuginfo_eip+0x2df>
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
f01037c8:	e8 76 0f 00 00       	call   f0104743 <cpunum>
f01037cd:	6a 04                	push   $0x4
f01037cf:	8b 55 b8             	mov    -0x48(%ebp),%edx
f01037d2:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f01037d5:	29 ca                	sub    %ecx,%edx
f01037d7:	52                   	push   %edx
f01037d8:	51                   	push   %ecx
f01037d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01037dc:	ff b0 28 a0 22 f0    	pushl  -0xfdd5fd8(%eax)
f01037e2:	e8 0c ea ff ff       	call   f01021f3 <user_mem_check>
f01037e7:	83 c4 10             	add    $0x10,%esp
f01037ea:	85 c0                	test   %eax,%eax
f01037ec:	0f 84 4b fe ff ff    	je     f010363d <debuginfo_eip+0x5a>
    		return -1;
f01037f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037f7:	e9 ee 00 00 00       	jmp    f01038ea <debuginfo_eip+0x307>
		info->eip_fn_addr = addr;
f01037fc:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f01037ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103802:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103805:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103808:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010380b:	e9 dd fe ff ff       	jmp    f01036ed <debuginfo_eip+0x10a>
f0103810:	83 e8 01             	sub    $0x1,%eax
f0103813:	83 ea 0c             	sub    $0xc,%edx
f0103816:	89 f9                	mov    %edi,%ecx
f0103818:	88 4d c4             	mov    %cl,-0x3c(%ebp)
f010381b:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f010381e:	39 c3                	cmp    %eax,%ebx
f0103820:	7f 24                	jg     f0103846 <debuginfo_eip+0x263>
	       && stabs[lline].n_type != N_SOL
f0103822:	0f b6 0a             	movzbl (%edx),%ecx
f0103825:	80 f9 84             	cmp    $0x84,%cl
f0103828:	74 46                	je     f0103870 <debuginfo_eip+0x28d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010382a:	80 f9 64             	cmp    $0x64,%cl
f010382d:	75 e1                	jne    f0103810 <debuginfo_eip+0x22d>
f010382f:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0103833:	74 db                	je     f0103810 <debuginfo_eip+0x22d>
f0103835:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103838:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010383c:	74 3b                	je     f0103879 <debuginfo_eip+0x296>
f010383e:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103841:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103844:	eb 33                	jmp    f0103879 <debuginfo_eip+0x296>
f0103846:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103849:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010384c:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010384f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0103854:	39 da                	cmp    %ebx,%edx
f0103856:	0f 8d 8e 00 00 00    	jge    f01038ea <debuginfo_eip+0x307>
		for (lline = lfun + 1;
f010385c:	83 c2 01             	add    $0x1,%edx
f010385f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103862:	89 d0                	mov    %edx,%eax
f0103864:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103867:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010386a:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f010386e:	eb 32                	jmp    f01038a2 <debuginfo_eip+0x2bf>
f0103870:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103873:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103877:	75 1d                	jne    f0103896 <debuginfo_eip+0x2b3>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103879:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010387c:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010387f:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103882:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0103885:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0103888:	29 f8                	sub    %edi,%eax
f010388a:	39 c2                	cmp    %eax,%edx
f010388c:	73 bb                	jae    f0103849 <debuginfo_eip+0x266>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010388e:	89 f8                	mov    %edi,%eax
f0103890:	01 d0                	add    %edx,%eax
f0103892:	89 06                	mov    %eax,(%esi)
f0103894:	eb b3                	jmp    f0103849 <debuginfo_eip+0x266>
f0103896:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103899:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010389c:	eb db                	jmp    f0103879 <debuginfo_eip+0x296>
			info->eip_fn_narg++;
f010389e:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f01038a2:	39 c3                	cmp    %eax,%ebx
f01038a4:	7e 3f                	jle    f01038e5 <debuginfo_eip+0x302>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01038a6:	0f b6 0a             	movzbl (%edx),%ecx
f01038a9:	83 c0 01             	add    $0x1,%eax
f01038ac:	83 c2 0c             	add    $0xc,%edx
f01038af:	80 f9 a0             	cmp    $0xa0,%cl
f01038b2:	74 ea                	je     f010389e <debuginfo_eip+0x2bb>
	return 0;
f01038b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01038b9:	eb 2f                	jmp    f01038ea <debuginfo_eip+0x307>
    			return -1; 
f01038bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01038c0:	eb 28                	jmp    f01038ea <debuginfo_eip+0x307>
    		return -1;
f01038c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01038c7:	eb 21                	jmp    f01038ea <debuginfo_eip+0x307>
		return -1;
f01038c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01038ce:	eb 1a                	jmp    f01038ea <debuginfo_eip+0x307>
f01038d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01038d5:	eb 13                	jmp    f01038ea <debuginfo_eip+0x307>
		return -1;
f01038d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01038dc:	eb 0c                	jmp    f01038ea <debuginfo_eip+0x307>
    		return -1;
f01038de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01038e3:	eb 05                	jmp    f01038ea <debuginfo_eip+0x307>
	return 0;
f01038e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01038ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01038ed:	5b                   	pop    %ebx
f01038ee:	5e                   	pop    %esi
f01038ef:	5f                   	pop    %edi
f01038f0:	5d                   	pop    %ebp
f01038f1:	c3                   	ret    

f01038f2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01038f2:	55                   	push   %ebp
f01038f3:	89 e5                	mov    %esp,%ebp
f01038f5:	57                   	push   %edi
f01038f6:	56                   	push   %esi
f01038f7:	53                   	push   %ebx
f01038f8:	83 ec 1c             	sub    $0x1c,%esp
f01038fb:	89 c7                	mov    %eax,%edi
f01038fd:	89 d6                	mov    %edx,%esi
f01038ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0103902:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103905:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103908:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010390b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010390e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103913:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103916:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103919:	39 d3                	cmp    %edx,%ebx
f010391b:	72 05                	jb     f0103922 <printnum+0x30>
f010391d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103920:	77 7a                	ja     f010399c <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103922:	83 ec 0c             	sub    $0xc,%esp
f0103925:	ff 75 18             	pushl  0x18(%ebp)
f0103928:	8b 45 14             	mov    0x14(%ebp),%eax
f010392b:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010392e:	53                   	push   %ebx
f010392f:	ff 75 10             	pushl  0x10(%ebp)
f0103932:	83 ec 08             	sub    $0x8,%esp
f0103935:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103938:	ff 75 e0             	pushl  -0x20(%ebp)
f010393b:	ff 75 dc             	pushl  -0x24(%ebp)
f010393e:	ff 75 d8             	pushl  -0x28(%ebp)
f0103941:	e8 fa 11 00 00       	call   f0104b40 <__udivdi3>
f0103946:	83 c4 18             	add    $0x18,%esp
f0103949:	52                   	push   %edx
f010394a:	50                   	push   %eax
f010394b:	89 f2                	mov    %esi,%edx
f010394d:	89 f8                	mov    %edi,%eax
f010394f:	e8 9e ff ff ff       	call   f01038f2 <printnum>
f0103954:	83 c4 20             	add    $0x20,%esp
f0103957:	eb 13                	jmp    f010396c <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103959:	83 ec 08             	sub    $0x8,%esp
f010395c:	56                   	push   %esi
f010395d:	ff 75 18             	pushl  0x18(%ebp)
f0103960:	ff d7                	call   *%edi
f0103962:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103965:	83 eb 01             	sub    $0x1,%ebx
f0103968:	85 db                	test   %ebx,%ebx
f010396a:	7f ed                	jg     f0103959 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010396c:	83 ec 08             	sub    $0x8,%esp
f010396f:	56                   	push   %esi
f0103970:	83 ec 04             	sub    $0x4,%esp
f0103973:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103976:	ff 75 e0             	pushl  -0x20(%ebp)
f0103979:	ff 75 dc             	pushl  -0x24(%ebp)
f010397c:	ff 75 d8             	pushl  -0x28(%ebp)
f010397f:	e8 dc 12 00 00       	call   f0104c60 <__umoddi3>
f0103984:	83 c4 14             	add    $0x14,%esp
f0103987:	0f be 80 77 60 10 f0 	movsbl -0xfef9f89(%eax),%eax
f010398e:	50                   	push   %eax
f010398f:	ff d7                	call   *%edi
}
f0103991:	83 c4 10             	add    $0x10,%esp
f0103994:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103997:	5b                   	pop    %ebx
f0103998:	5e                   	pop    %esi
f0103999:	5f                   	pop    %edi
f010399a:	5d                   	pop    %ebp
f010399b:	c3                   	ret    
f010399c:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010399f:	eb c4                	jmp    f0103965 <printnum+0x73>

f01039a1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01039a1:	55                   	push   %ebp
f01039a2:	89 e5                	mov    %esp,%ebp
f01039a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01039a7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01039ab:	8b 10                	mov    (%eax),%edx
f01039ad:	3b 50 04             	cmp    0x4(%eax),%edx
f01039b0:	73 0a                	jae    f01039bc <sprintputch+0x1b>
		*b->buf++ = ch;
f01039b2:	8d 4a 01             	lea    0x1(%edx),%ecx
f01039b5:	89 08                	mov    %ecx,(%eax)
f01039b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01039ba:	88 02                	mov    %al,(%edx)
}
f01039bc:	5d                   	pop    %ebp
f01039bd:	c3                   	ret    

f01039be <printfmt>:
{
f01039be:	55                   	push   %ebp
f01039bf:	89 e5                	mov    %esp,%ebp
f01039c1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01039c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01039c7:	50                   	push   %eax
f01039c8:	ff 75 10             	pushl  0x10(%ebp)
f01039cb:	ff 75 0c             	pushl  0xc(%ebp)
f01039ce:	ff 75 08             	pushl  0x8(%ebp)
f01039d1:	e8 05 00 00 00       	call   f01039db <vprintfmt>
}
f01039d6:	83 c4 10             	add    $0x10,%esp
f01039d9:	c9                   	leave  
f01039da:	c3                   	ret    

f01039db <vprintfmt>:
{
f01039db:	55                   	push   %ebp
f01039dc:	89 e5                	mov    %esp,%ebp
f01039de:	57                   	push   %edi
f01039df:	56                   	push   %esi
f01039e0:	53                   	push   %ebx
f01039e1:	83 ec 2c             	sub    $0x2c,%esp
f01039e4:	8b 75 08             	mov    0x8(%ebp),%esi
f01039e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01039ea:	8b 7d 10             	mov    0x10(%ebp),%edi
f01039ed:	e9 c1 03 00 00       	jmp    f0103db3 <vprintfmt+0x3d8>
		padc = ' ';
f01039f2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f01039f6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01039fd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0103a04:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0103a0b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0103a10:	8d 47 01             	lea    0x1(%edi),%eax
f0103a13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103a16:	0f b6 17             	movzbl (%edi),%edx
f0103a19:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103a1c:	3c 55                	cmp    $0x55,%al
f0103a1e:	0f 87 12 04 00 00    	ja     f0103e36 <vprintfmt+0x45b>
f0103a24:	0f b6 c0             	movzbl %al,%eax
f0103a27:	ff 24 85 40 61 10 f0 	jmp    *-0xfef9ec0(,%eax,4)
f0103a2e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0103a31:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0103a35:	eb d9                	jmp    f0103a10 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0103a37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0103a3a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103a3e:	eb d0                	jmp    f0103a10 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0103a40:	0f b6 d2             	movzbl %dl,%edx
f0103a43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0103a46:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a4b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0103a4e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103a51:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0103a55:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0103a58:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0103a5b:	83 f9 09             	cmp    $0x9,%ecx
f0103a5e:	77 55                	ja     f0103ab5 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
f0103a60:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0103a63:	eb e9                	jmp    f0103a4e <vprintfmt+0x73>
			precision = va_arg(ap, int);
f0103a65:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a68:	8b 00                	mov    (%eax),%eax
f0103a6a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103a6d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a70:	8d 40 04             	lea    0x4(%eax),%eax
f0103a73:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103a76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0103a79:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103a7d:	79 91                	jns    f0103a10 <vprintfmt+0x35>
				width = precision, precision = -1;
f0103a7f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103a82:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103a85:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103a8c:	eb 82                	jmp    f0103a10 <vprintfmt+0x35>
f0103a8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a91:	85 c0                	test   %eax,%eax
f0103a93:	ba 00 00 00 00       	mov    $0x0,%edx
f0103a98:	0f 49 d0             	cmovns %eax,%edx
f0103a9b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103a9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103aa1:	e9 6a ff ff ff       	jmp    f0103a10 <vprintfmt+0x35>
f0103aa6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0103aa9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103ab0:	e9 5b ff ff ff       	jmp    f0103a10 <vprintfmt+0x35>
f0103ab5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103ab8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103abb:	eb bc                	jmp    f0103a79 <vprintfmt+0x9e>
			lflag++;
f0103abd:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0103ac0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0103ac3:	e9 48 ff ff ff       	jmp    f0103a10 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0103ac8:	8b 45 14             	mov    0x14(%ebp),%eax
f0103acb:	8d 78 04             	lea    0x4(%eax),%edi
f0103ace:	83 ec 08             	sub    $0x8,%esp
f0103ad1:	53                   	push   %ebx
f0103ad2:	ff 30                	pushl  (%eax)
f0103ad4:	ff d6                	call   *%esi
			break;
f0103ad6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0103ad9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0103adc:	e9 cf 02 00 00       	jmp    f0103db0 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
f0103ae1:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ae4:	8d 78 04             	lea    0x4(%eax),%edi
f0103ae7:	8b 00                	mov    (%eax),%eax
f0103ae9:	99                   	cltd   
f0103aea:	31 d0                	xor    %edx,%eax
f0103aec:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103aee:	83 f8 08             	cmp    $0x8,%eax
f0103af1:	7f 23                	jg     f0103b16 <vprintfmt+0x13b>
f0103af3:	8b 14 85 a0 62 10 f0 	mov    -0xfef9d60(,%eax,4),%edx
f0103afa:	85 d2                	test   %edx,%edx
f0103afc:	74 18                	je     f0103b16 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
f0103afe:	52                   	push   %edx
f0103aff:	68 44 59 10 f0       	push   $0xf0105944
f0103b04:	53                   	push   %ebx
f0103b05:	56                   	push   %esi
f0103b06:	e8 b3 fe ff ff       	call   f01039be <printfmt>
f0103b0b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103b0e:	89 7d 14             	mov    %edi,0x14(%ebp)
f0103b11:	e9 9a 02 00 00       	jmp    f0103db0 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
f0103b16:	50                   	push   %eax
f0103b17:	68 8f 60 10 f0       	push   $0xf010608f
f0103b1c:	53                   	push   %ebx
f0103b1d:	56                   	push   %esi
f0103b1e:	e8 9b fe ff ff       	call   f01039be <printfmt>
f0103b23:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103b26:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0103b29:	e9 82 02 00 00       	jmp    f0103db0 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
f0103b2e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b31:	83 c0 04             	add    $0x4,%eax
f0103b34:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103b37:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b3a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103b3c:	85 ff                	test   %edi,%edi
f0103b3e:	b8 88 60 10 f0       	mov    $0xf0106088,%eax
f0103b43:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103b46:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103b4a:	0f 8e bd 00 00 00    	jle    f0103c0d <vprintfmt+0x232>
f0103b50:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103b54:	75 0e                	jne    f0103b64 <vprintfmt+0x189>
f0103b56:	89 75 08             	mov    %esi,0x8(%ebp)
f0103b59:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103b5c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103b5f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103b62:	eb 6d                	jmp    f0103bd1 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103b64:	83 ec 08             	sub    $0x8,%esp
f0103b67:	ff 75 d0             	pushl  -0x30(%ebp)
f0103b6a:	57                   	push   %edi
f0103b6b:	e8 50 04 00 00       	call   f0103fc0 <strnlen>
f0103b70:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103b73:	29 c1                	sub    %eax,%ecx
f0103b75:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103b78:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103b7b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103b7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103b82:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103b85:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0103b87:	eb 0f                	jmp    f0103b98 <vprintfmt+0x1bd>
					putch(padc, putdat);
f0103b89:	83 ec 08             	sub    $0x8,%esp
f0103b8c:	53                   	push   %ebx
f0103b8d:	ff 75 e0             	pushl  -0x20(%ebp)
f0103b90:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0103b92:	83 ef 01             	sub    $0x1,%edi
f0103b95:	83 c4 10             	add    $0x10,%esp
f0103b98:	85 ff                	test   %edi,%edi
f0103b9a:	7f ed                	jg     f0103b89 <vprintfmt+0x1ae>
f0103b9c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103b9f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103ba2:	85 c9                	test   %ecx,%ecx
f0103ba4:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ba9:	0f 49 c1             	cmovns %ecx,%eax
f0103bac:	29 c1                	sub    %eax,%ecx
f0103bae:	89 75 08             	mov    %esi,0x8(%ebp)
f0103bb1:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103bb4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103bb7:	89 cb                	mov    %ecx,%ebx
f0103bb9:	eb 16                	jmp    f0103bd1 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
f0103bbb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103bbf:	75 31                	jne    f0103bf2 <vprintfmt+0x217>
					putch(ch, putdat);
f0103bc1:	83 ec 08             	sub    $0x8,%esp
f0103bc4:	ff 75 0c             	pushl  0xc(%ebp)
f0103bc7:	50                   	push   %eax
f0103bc8:	ff 55 08             	call   *0x8(%ebp)
f0103bcb:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103bce:	83 eb 01             	sub    $0x1,%ebx
f0103bd1:	83 c7 01             	add    $0x1,%edi
f0103bd4:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0103bd8:	0f be c2             	movsbl %dl,%eax
f0103bdb:	85 c0                	test   %eax,%eax
f0103bdd:	74 59                	je     f0103c38 <vprintfmt+0x25d>
f0103bdf:	85 f6                	test   %esi,%esi
f0103be1:	78 d8                	js     f0103bbb <vprintfmt+0x1e0>
f0103be3:	83 ee 01             	sub    $0x1,%esi
f0103be6:	79 d3                	jns    f0103bbb <vprintfmt+0x1e0>
f0103be8:	89 df                	mov    %ebx,%edi
f0103bea:	8b 75 08             	mov    0x8(%ebp),%esi
f0103bed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103bf0:	eb 37                	jmp    f0103c29 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
f0103bf2:	0f be d2             	movsbl %dl,%edx
f0103bf5:	83 ea 20             	sub    $0x20,%edx
f0103bf8:	83 fa 5e             	cmp    $0x5e,%edx
f0103bfb:	76 c4                	jbe    f0103bc1 <vprintfmt+0x1e6>
					putch('?', putdat);
f0103bfd:	83 ec 08             	sub    $0x8,%esp
f0103c00:	ff 75 0c             	pushl  0xc(%ebp)
f0103c03:	6a 3f                	push   $0x3f
f0103c05:	ff 55 08             	call   *0x8(%ebp)
f0103c08:	83 c4 10             	add    $0x10,%esp
f0103c0b:	eb c1                	jmp    f0103bce <vprintfmt+0x1f3>
f0103c0d:	89 75 08             	mov    %esi,0x8(%ebp)
f0103c10:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103c13:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103c16:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103c19:	eb b6                	jmp    f0103bd1 <vprintfmt+0x1f6>
				putch(' ', putdat);
f0103c1b:	83 ec 08             	sub    $0x8,%esp
f0103c1e:	53                   	push   %ebx
f0103c1f:	6a 20                	push   $0x20
f0103c21:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0103c23:	83 ef 01             	sub    $0x1,%edi
f0103c26:	83 c4 10             	add    $0x10,%esp
f0103c29:	85 ff                	test   %edi,%edi
f0103c2b:	7f ee                	jg     f0103c1b <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
f0103c2d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103c30:	89 45 14             	mov    %eax,0x14(%ebp)
f0103c33:	e9 78 01 00 00       	jmp    f0103db0 <vprintfmt+0x3d5>
f0103c38:	89 df                	mov    %ebx,%edi
f0103c3a:	8b 75 08             	mov    0x8(%ebp),%esi
f0103c3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103c40:	eb e7                	jmp    f0103c29 <vprintfmt+0x24e>
	if (lflag >= 2)
f0103c42:	83 f9 01             	cmp    $0x1,%ecx
f0103c45:	7e 3f                	jle    f0103c86 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
f0103c47:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c4a:	8b 50 04             	mov    0x4(%eax),%edx
f0103c4d:	8b 00                	mov    (%eax),%eax
f0103c4f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103c52:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103c55:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c58:	8d 40 08             	lea    0x8(%eax),%eax
f0103c5b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0103c5e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103c62:	79 5c                	jns    f0103cc0 <vprintfmt+0x2e5>
				putch('-', putdat);
f0103c64:	83 ec 08             	sub    $0x8,%esp
f0103c67:	53                   	push   %ebx
f0103c68:	6a 2d                	push   $0x2d
f0103c6a:	ff d6                	call   *%esi
				num = -(long long) num;
f0103c6c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103c6f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103c72:	f7 da                	neg    %edx
f0103c74:	83 d1 00             	adc    $0x0,%ecx
f0103c77:	f7 d9                	neg    %ecx
f0103c79:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0103c7c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103c81:	e9 10 01 00 00       	jmp    f0103d96 <vprintfmt+0x3bb>
	else if (lflag)
f0103c86:	85 c9                	test   %ecx,%ecx
f0103c88:	75 1b                	jne    f0103ca5 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
f0103c8a:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c8d:	8b 00                	mov    (%eax),%eax
f0103c8f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103c92:	89 c1                	mov    %eax,%ecx
f0103c94:	c1 f9 1f             	sar    $0x1f,%ecx
f0103c97:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103c9a:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c9d:	8d 40 04             	lea    0x4(%eax),%eax
f0103ca0:	89 45 14             	mov    %eax,0x14(%ebp)
f0103ca3:	eb b9                	jmp    f0103c5e <vprintfmt+0x283>
		return va_arg(*ap, long);
f0103ca5:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ca8:	8b 00                	mov    (%eax),%eax
f0103caa:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103cad:	89 c1                	mov    %eax,%ecx
f0103caf:	c1 f9 1f             	sar    $0x1f,%ecx
f0103cb2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103cb5:	8b 45 14             	mov    0x14(%ebp),%eax
f0103cb8:	8d 40 04             	lea    0x4(%eax),%eax
f0103cbb:	89 45 14             	mov    %eax,0x14(%ebp)
f0103cbe:	eb 9e                	jmp    f0103c5e <vprintfmt+0x283>
			num = getint(&ap, lflag);
f0103cc0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103cc3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0103cc6:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ccb:	e9 c6 00 00 00       	jmp    f0103d96 <vprintfmt+0x3bb>
	if (lflag >= 2)
f0103cd0:	83 f9 01             	cmp    $0x1,%ecx
f0103cd3:	7e 18                	jle    f0103ced <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
f0103cd5:	8b 45 14             	mov    0x14(%ebp),%eax
f0103cd8:	8b 10                	mov    (%eax),%edx
f0103cda:	8b 48 04             	mov    0x4(%eax),%ecx
f0103cdd:	8d 40 08             	lea    0x8(%eax),%eax
f0103ce0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103ce3:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ce8:	e9 a9 00 00 00       	jmp    f0103d96 <vprintfmt+0x3bb>
	else if (lflag)
f0103ced:	85 c9                	test   %ecx,%ecx
f0103cef:	75 1a                	jne    f0103d0b <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
f0103cf1:	8b 45 14             	mov    0x14(%ebp),%eax
f0103cf4:	8b 10                	mov    (%eax),%edx
f0103cf6:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103cfb:	8d 40 04             	lea    0x4(%eax),%eax
f0103cfe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103d01:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103d06:	e9 8b 00 00 00       	jmp    f0103d96 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f0103d0b:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d0e:	8b 10                	mov    (%eax),%edx
f0103d10:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103d15:	8d 40 04             	lea    0x4(%eax),%eax
f0103d18:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103d1b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103d20:	eb 74                	jmp    f0103d96 <vprintfmt+0x3bb>
	if (lflag >= 2)
f0103d22:	83 f9 01             	cmp    $0x1,%ecx
f0103d25:	7e 15                	jle    f0103d3c <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
f0103d27:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d2a:	8b 10                	mov    (%eax),%edx
f0103d2c:	8b 48 04             	mov    0x4(%eax),%ecx
f0103d2f:	8d 40 08             	lea    0x8(%eax),%eax
f0103d32:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f0103d35:	b8 08 00 00 00       	mov    $0x8,%eax
f0103d3a:	eb 5a                	jmp    f0103d96 <vprintfmt+0x3bb>
	else if (lflag)
f0103d3c:	85 c9                	test   %ecx,%ecx
f0103d3e:	75 17                	jne    f0103d57 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
f0103d40:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d43:	8b 10                	mov    (%eax),%edx
f0103d45:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103d4a:	8d 40 04             	lea    0x4(%eax),%eax
f0103d4d:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f0103d50:	b8 08 00 00 00       	mov    $0x8,%eax
f0103d55:	eb 3f                	jmp    f0103d96 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f0103d57:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d5a:	8b 10                	mov    (%eax),%edx
f0103d5c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103d61:	8d 40 04             	lea    0x4(%eax),%eax
f0103d64:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f0103d67:	b8 08 00 00 00       	mov    $0x8,%eax
f0103d6c:	eb 28                	jmp    f0103d96 <vprintfmt+0x3bb>
			putch('0', putdat);
f0103d6e:	83 ec 08             	sub    $0x8,%esp
f0103d71:	53                   	push   %ebx
f0103d72:	6a 30                	push   $0x30
f0103d74:	ff d6                	call   *%esi
			putch('x', putdat);
f0103d76:	83 c4 08             	add    $0x8,%esp
f0103d79:	53                   	push   %ebx
f0103d7a:	6a 78                	push   $0x78
f0103d7c:	ff d6                	call   *%esi
			num = (unsigned long long)
f0103d7e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d81:	8b 10                	mov    (%eax),%edx
f0103d83:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0103d88:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0103d8b:	8d 40 04             	lea    0x4(%eax),%eax
f0103d8e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103d91:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0103d96:	83 ec 0c             	sub    $0xc,%esp
f0103d99:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103d9d:	57                   	push   %edi
f0103d9e:	ff 75 e0             	pushl  -0x20(%ebp)
f0103da1:	50                   	push   %eax
f0103da2:	51                   	push   %ecx
f0103da3:	52                   	push   %edx
f0103da4:	89 da                	mov    %ebx,%edx
f0103da6:	89 f0                	mov    %esi,%eax
f0103da8:	e8 45 fb ff ff       	call   f01038f2 <printnum>
			break;
f0103dad:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0103db0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103db3:	83 c7 01             	add    $0x1,%edi
f0103db6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103dba:	83 f8 25             	cmp    $0x25,%eax
f0103dbd:	0f 84 2f fc ff ff    	je     f01039f2 <vprintfmt+0x17>
			if (ch == '\0')
f0103dc3:	85 c0                	test   %eax,%eax
f0103dc5:	0f 84 8b 00 00 00    	je     f0103e56 <vprintfmt+0x47b>
			putch(ch, putdat);
f0103dcb:	83 ec 08             	sub    $0x8,%esp
f0103dce:	53                   	push   %ebx
f0103dcf:	50                   	push   %eax
f0103dd0:	ff d6                	call   *%esi
f0103dd2:	83 c4 10             	add    $0x10,%esp
f0103dd5:	eb dc                	jmp    f0103db3 <vprintfmt+0x3d8>
	if (lflag >= 2)
f0103dd7:	83 f9 01             	cmp    $0x1,%ecx
f0103dda:	7e 15                	jle    f0103df1 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
f0103ddc:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ddf:	8b 10                	mov    (%eax),%edx
f0103de1:	8b 48 04             	mov    0x4(%eax),%ecx
f0103de4:	8d 40 08             	lea    0x8(%eax),%eax
f0103de7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103dea:	b8 10 00 00 00       	mov    $0x10,%eax
f0103def:	eb a5                	jmp    f0103d96 <vprintfmt+0x3bb>
	else if (lflag)
f0103df1:	85 c9                	test   %ecx,%ecx
f0103df3:	75 17                	jne    f0103e0c <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
f0103df5:	8b 45 14             	mov    0x14(%ebp),%eax
f0103df8:	8b 10                	mov    (%eax),%edx
f0103dfa:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103dff:	8d 40 04             	lea    0x4(%eax),%eax
f0103e02:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103e05:	b8 10 00 00 00       	mov    $0x10,%eax
f0103e0a:	eb 8a                	jmp    f0103d96 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f0103e0c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e0f:	8b 10                	mov    (%eax),%edx
f0103e11:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103e16:	8d 40 04             	lea    0x4(%eax),%eax
f0103e19:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103e1c:	b8 10 00 00 00       	mov    $0x10,%eax
f0103e21:	e9 70 ff ff ff       	jmp    f0103d96 <vprintfmt+0x3bb>
			putch(ch, putdat);
f0103e26:	83 ec 08             	sub    $0x8,%esp
f0103e29:	53                   	push   %ebx
f0103e2a:	6a 25                	push   $0x25
f0103e2c:	ff d6                	call   *%esi
			break;
f0103e2e:	83 c4 10             	add    $0x10,%esp
f0103e31:	e9 7a ff ff ff       	jmp    f0103db0 <vprintfmt+0x3d5>
			putch('%', putdat);
f0103e36:	83 ec 08             	sub    $0x8,%esp
f0103e39:	53                   	push   %ebx
f0103e3a:	6a 25                	push   $0x25
f0103e3c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103e3e:	83 c4 10             	add    $0x10,%esp
f0103e41:	89 f8                	mov    %edi,%eax
f0103e43:	eb 03                	jmp    f0103e48 <vprintfmt+0x46d>
f0103e45:	83 e8 01             	sub    $0x1,%eax
f0103e48:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0103e4c:	75 f7                	jne    f0103e45 <vprintfmt+0x46a>
f0103e4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103e51:	e9 5a ff ff ff       	jmp    f0103db0 <vprintfmt+0x3d5>
}
f0103e56:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103e59:	5b                   	pop    %ebx
f0103e5a:	5e                   	pop    %esi
f0103e5b:	5f                   	pop    %edi
f0103e5c:	5d                   	pop    %ebp
f0103e5d:	c3                   	ret    

f0103e5e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103e5e:	55                   	push   %ebp
f0103e5f:	89 e5                	mov    %esp,%ebp
f0103e61:	83 ec 18             	sub    $0x18,%esp
f0103e64:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e67:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103e6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103e6d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103e71:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103e74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103e7b:	85 c0                	test   %eax,%eax
f0103e7d:	74 26                	je     f0103ea5 <vsnprintf+0x47>
f0103e7f:	85 d2                	test   %edx,%edx
f0103e81:	7e 22                	jle    f0103ea5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103e83:	ff 75 14             	pushl  0x14(%ebp)
f0103e86:	ff 75 10             	pushl  0x10(%ebp)
f0103e89:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103e8c:	50                   	push   %eax
f0103e8d:	68 a1 39 10 f0       	push   $0xf01039a1
f0103e92:	e8 44 fb ff ff       	call   f01039db <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103e97:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103e9a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ea0:	83 c4 10             	add    $0x10,%esp
}
f0103ea3:	c9                   	leave  
f0103ea4:	c3                   	ret    
		return -E_INVAL;
f0103ea5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103eaa:	eb f7                	jmp    f0103ea3 <vsnprintf+0x45>

f0103eac <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103eac:	55                   	push   %ebp
f0103ead:	89 e5                	mov    %esp,%ebp
f0103eaf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103eb2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103eb5:	50                   	push   %eax
f0103eb6:	ff 75 10             	pushl  0x10(%ebp)
f0103eb9:	ff 75 0c             	pushl  0xc(%ebp)
f0103ebc:	ff 75 08             	pushl  0x8(%ebp)
f0103ebf:	e8 9a ff ff ff       	call   f0103e5e <vsnprintf>
	va_end(ap);

	return rc;
}
f0103ec4:	c9                   	leave  
f0103ec5:	c3                   	ret    

f0103ec6 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103ec6:	55                   	push   %ebp
f0103ec7:	89 e5                	mov    %esp,%ebp
f0103ec9:	57                   	push   %edi
f0103eca:	56                   	push   %esi
f0103ecb:	53                   	push   %ebx
f0103ecc:	83 ec 0c             	sub    $0xc,%esp
f0103ecf:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103ed2:	85 c0                	test   %eax,%eax
f0103ed4:	74 11                	je     f0103ee7 <readline+0x21>
		cprintf("%s", prompt);
f0103ed6:	83 ec 08             	sub    $0x8,%esp
f0103ed9:	50                   	push   %eax
f0103eda:	68 44 59 10 f0       	push   $0xf0105944
f0103edf:	e8 b1 ec ff ff       	call   f0102b95 <cprintf>
f0103ee4:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103ee7:	83 ec 0c             	sub    $0xc,%esp
f0103eea:	6a 00                	push   $0x0
f0103eec:	e8 85 c8 ff ff       	call   f0100776 <iscons>
f0103ef1:	89 c7                	mov    %eax,%edi
f0103ef3:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103ef6:	be 00 00 00 00       	mov    $0x0,%esi
f0103efb:	eb 3f                	jmp    f0103f3c <readline+0x76>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0103efd:	83 ec 08             	sub    $0x8,%esp
f0103f00:	50                   	push   %eax
f0103f01:	68 c4 62 10 f0       	push   $0xf01062c4
f0103f06:	e8 8a ec ff ff       	call   f0102b95 <cprintf>
			return NULL;
f0103f0b:	83 c4 10             	add    $0x10,%esp
f0103f0e:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103f13:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f16:	5b                   	pop    %ebx
f0103f17:	5e                   	pop    %esi
f0103f18:	5f                   	pop    %edi
f0103f19:	5d                   	pop    %ebp
f0103f1a:	c3                   	ret    
			if (echoing)
f0103f1b:	85 ff                	test   %edi,%edi
f0103f1d:	75 05                	jne    f0103f24 <readline+0x5e>
			i--;
f0103f1f:	83 ee 01             	sub    $0x1,%esi
f0103f22:	eb 18                	jmp    f0103f3c <readline+0x76>
				cputchar('\b');
f0103f24:	83 ec 0c             	sub    $0xc,%esp
f0103f27:	6a 08                	push   $0x8
f0103f29:	e8 27 c8 ff ff       	call   f0100755 <cputchar>
f0103f2e:	83 c4 10             	add    $0x10,%esp
f0103f31:	eb ec                	jmp    f0103f1f <readline+0x59>
			buf[i++] = c;
f0103f33:	88 9e 00 9b 22 f0    	mov    %bl,-0xfdd6500(%esi)
f0103f39:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0103f3c:	e8 24 c8 ff ff       	call   f0100765 <getchar>
f0103f41:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103f43:	85 c0                	test   %eax,%eax
f0103f45:	78 b6                	js     f0103efd <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103f47:	83 f8 08             	cmp    $0x8,%eax
f0103f4a:	0f 94 c2             	sete   %dl
f0103f4d:	83 f8 7f             	cmp    $0x7f,%eax
f0103f50:	0f 94 c0             	sete   %al
f0103f53:	08 c2                	or     %al,%dl
f0103f55:	74 04                	je     f0103f5b <readline+0x95>
f0103f57:	85 f6                	test   %esi,%esi
f0103f59:	7f c0                	jg     f0103f1b <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103f5b:	83 fb 1f             	cmp    $0x1f,%ebx
f0103f5e:	7e 1a                	jle    f0103f7a <readline+0xb4>
f0103f60:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103f66:	7f 12                	jg     f0103f7a <readline+0xb4>
			if (echoing)
f0103f68:	85 ff                	test   %edi,%edi
f0103f6a:	74 c7                	je     f0103f33 <readline+0x6d>
				cputchar(c);
f0103f6c:	83 ec 0c             	sub    $0xc,%esp
f0103f6f:	53                   	push   %ebx
f0103f70:	e8 e0 c7 ff ff       	call   f0100755 <cputchar>
f0103f75:	83 c4 10             	add    $0x10,%esp
f0103f78:	eb b9                	jmp    f0103f33 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f0103f7a:	83 fb 0a             	cmp    $0xa,%ebx
f0103f7d:	74 05                	je     f0103f84 <readline+0xbe>
f0103f7f:	83 fb 0d             	cmp    $0xd,%ebx
f0103f82:	75 b8                	jne    f0103f3c <readline+0x76>
			if (echoing)
f0103f84:	85 ff                	test   %edi,%edi
f0103f86:	75 11                	jne    f0103f99 <readline+0xd3>
			buf[i] = 0;
f0103f88:	c6 86 00 9b 22 f0 00 	movb   $0x0,-0xfdd6500(%esi)
			return buf;
f0103f8f:	b8 00 9b 22 f0       	mov    $0xf0229b00,%eax
f0103f94:	e9 7a ff ff ff       	jmp    f0103f13 <readline+0x4d>
				cputchar('\n');
f0103f99:	83 ec 0c             	sub    $0xc,%esp
f0103f9c:	6a 0a                	push   $0xa
f0103f9e:	e8 b2 c7 ff ff       	call   f0100755 <cputchar>
f0103fa3:	83 c4 10             	add    $0x10,%esp
f0103fa6:	eb e0                	jmp    f0103f88 <readline+0xc2>

f0103fa8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103fa8:	55                   	push   %ebp
f0103fa9:	89 e5                	mov    %esp,%ebp
f0103fab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103fae:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fb3:	eb 03                	jmp    f0103fb8 <strlen+0x10>
		n++;
f0103fb5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0103fb8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103fbc:	75 f7                	jne    f0103fb5 <strlen+0xd>
	return n;
}
f0103fbe:	5d                   	pop    %ebp
f0103fbf:	c3                   	ret    

f0103fc0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103fc0:	55                   	push   %ebp
f0103fc1:	89 e5                	mov    %esp,%ebp
f0103fc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103fc6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103fc9:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fce:	eb 03                	jmp    f0103fd3 <strnlen+0x13>
		n++;
f0103fd0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103fd3:	39 d0                	cmp    %edx,%eax
f0103fd5:	74 06                	je     f0103fdd <strnlen+0x1d>
f0103fd7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103fdb:	75 f3                	jne    f0103fd0 <strnlen+0x10>
	return n;
}
f0103fdd:	5d                   	pop    %ebp
f0103fde:	c3                   	ret    

f0103fdf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103fdf:	55                   	push   %ebp
f0103fe0:	89 e5                	mov    %esp,%ebp
f0103fe2:	53                   	push   %ebx
f0103fe3:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fe6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103fe9:	89 c2                	mov    %eax,%edx
f0103feb:	83 c1 01             	add    $0x1,%ecx
f0103fee:	83 c2 01             	add    $0x1,%edx
f0103ff1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103ff5:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103ff8:	84 db                	test   %bl,%bl
f0103ffa:	75 ef                	jne    f0103feb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103ffc:	5b                   	pop    %ebx
f0103ffd:	5d                   	pop    %ebp
f0103ffe:	c3                   	ret    

f0103fff <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103fff:	55                   	push   %ebp
f0104000:	89 e5                	mov    %esp,%ebp
f0104002:	53                   	push   %ebx
f0104003:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104006:	53                   	push   %ebx
f0104007:	e8 9c ff ff ff       	call   f0103fa8 <strlen>
f010400c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010400f:	ff 75 0c             	pushl  0xc(%ebp)
f0104012:	01 d8                	add    %ebx,%eax
f0104014:	50                   	push   %eax
f0104015:	e8 c5 ff ff ff       	call   f0103fdf <strcpy>
	return dst;
}
f010401a:	89 d8                	mov    %ebx,%eax
f010401c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010401f:	c9                   	leave  
f0104020:	c3                   	ret    

f0104021 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104021:	55                   	push   %ebp
f0104022:	89 e5                	mov    %esp,%ebp
f0104024:	56                   	push   %esi
f0104025:	53                   	push   %ebx
f0104026:	8b 75 08             	mov    0x8(%ebp),%esi
f0104029:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010402c:	89 f3                	mov    %esi,%ebx
f010402e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104031:	89 f2                	mov    %esi,%edx
f0104033:	eb 0f                	jmp    f0104044 <strncpy+0x23>
		*dst++ = *src;
f0104035:	83 c2 01             	add    $0x1,%edx
f0104038:	0f b6 01             	movzbl (%ecx),%eax
f010403b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010403e:	80 39 01             	cmpb   $0x1,(%ecx)
f0104041:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0104044:	39 da                	cmp    %ebx,%edx
f0104046:	75 ed                	jne    f0104035 <strncpy+0x14>
	}
	return ret;
}
f0104048:	89 f0                	mov    %esi,%eax
f010404a:	5b                   	pop    %ebx
f010404b:	5e                   	pop    %esi
f010404c:	5d                   	pop    %ebp
f010404d:	c3                   	ret    

f010404e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010404e:	55                   	push   %ebp
f010404f:	89 e5                	mov    %esp,%ebp
f0104051:	56                   	push   %esi
f0104052:	53                   	push   %ebx
f0104053:	8b 75 08             	mov    0x8(%ebp),%esi
f0104056:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104059:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010405c:	89 f0                	mov    %esi,%eax
f010405e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104062:	85 c9                	test   %ecx,%ecx
f0104064:	75 0b                	jne    f0104071 <strlcpy+0x23>
f0104066:	eb 17                	jmp    f010407f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104068:	83 c2 01             	add    $0x1,%edx
f010406b:	83 c0 01             	add    $0x1,%eax
f010406e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0104071:	39 d8                	cmp    %ebx,%eax
f0104073:	74 07                	je     f010407c <strlcpy+0x2e>
f0104075:	0f b6 0a             	movzbl (%edx),%ecx
f0104078:	84 c9                	test   %cl,%cl
f010407a:	75 ec                	jne    f0104068 <strlcpy+0x1a>
		*dst = '\0';
f010407c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010407f:	29 f0                	sub    %esi,%eax
}
f0104081:	5b                   	pop    %ebx
f0104082:	5e                   	pop    %esi
f0104083:	5d                   	pop    %ebp
f0104084:	c3                   	ret    

f0104085 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104085:	55                   	push   %ebp
f0104086:	89 e5                	mov    %esp,%ebp
f0104088:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010408b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010408e:	eb 06                	jmp    f0104096 <strcmp+0x11>
		p++, q++;
f0104090:	83 c1 01             	add    $0x1,%ecx
f0104093:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0104096:	0f b6 01             	movzbl (%ecx),%eax
f0104099:	84 c0                	test   %al,%al
f010409b:	74 04                	je     f01040a1 <strcmp+0x1c>
f010409d:	3a 02                	cmp    (%edx),%al
f010409f:	74 ef                	je     f0104090 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01040a1:	0f b6 c0             	movzbl %al,%eax
f01040a4:	0f b6 12             	movzbl (%edx),%edx
f01040a7:	29 d0                	sub    %edx,%eax
}
f01040a9:	5d                   	pop    %ebp
f01040aa:	c3                   	ret    

f01040ab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01040ab:	55                   	push   %ebp
f01040ac:	89 e5                	mov    %esp,%ebp
f01040ae:	53                   	push   %ebx
f01040af:	8b 45 08             	mov    0x8(%ebp),%eax
f01040b2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01040b5:	89 c3                	mov    %eax,%ebx
f01040b7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01040ba:	eb 06                	jmp    f01040c2 <strncmp+0x17>
		n--, p++, q++;
f01040bc:	83 c0 01             	add    $0x1,%eax
f01040bf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01040c2:	39 d8                	cmp    %ebx,%eax
f01040c4:	74 16                	je     f01040dc <strncmp+0x31>
f01040c6:	0f b6 08             	movzbl (%eax),%ecx
f01040c9:	84 c9                	test   %cl,%cl
f01040cb:	74 04                	je     f01040d1 <strncmp+0x26>
f01040cd:	3a 0a                	cmp    (%edx),%cl
f01040cf:	74 eb                	je     f01040bc <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01040d1:	0f b6 00             	movzbl (%eax),%eax
f01040d4:	0f b6 12             	movzbl (%edx),%edx
f01040d7:	29 d0                	sub    %edx,%eax
}
f01040d9:	5b                   	pop    %ebx
f01040da:	5d                   	pop    %ebp
f01040db:	c3                   	ret    
		return 0;
f01040dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01040e1:	eb f6                	jmp    f01040d9 <strncmp+0x2e>

f01040e3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01040e3:	55                   	push   %ebp
f01040e4:	89 e5                	mov    %esp,%ebp
f01040e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01040e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01040ed:	0f b6 10             	movzbl (%eax),%edx
f01040f0:	84 d2                	test   %dl,%dl
f01040f2:	74 09                	je     f01040fd <strchr+0x1a>
		if (*s == c)
f01040f4:	38 ca                	cmp    %cl,%dl
f01040f6:	74 0a                	je     f0104102 <strchr+0x1f>
	for (; *s; s++)
f01040f8:	83 c0 01             	add    $0x1,%eax
f01040fb:	eb f0                	jmp    f01040ed <strchr+0xa>
			return (char *) s;
	return 0;
f01040fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104102:	5d                   	pop    %ebp
f0104103:	c3                   	ret    

f0104104 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104104:	55                   	push   %ebp
f0104105:	89 e5                	mov    %esp,%ebp
f0104107:	8b 45 08             	mov    0x8(%ebp),%eax
f010410a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010410e:	eb 03                	jmp    f0104113 <strfind+0xf>
f0104110:	83 c0 01             	add    $0x1,%eax
f0104113:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104116:	38 ca                	cmp    %cl,%dl
f0104118:	74 04                	je     f010411e <strfind+0x1a>
f010411a:	84 d2                	test   %dl,%dl
f010411c:	75 f2                	jne    f0104110 <strfind+0xc>
			break;
	return (char *) s;
}
f010411e:	5d                   	pop    %ebp
f010411f:	c3                   	ret    

f0104120 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104120:	55                   	push   %ebp
f0104121:	89 e5                	mov    %esp,%ebp
f0104123:	57                   	push   %edi
f0104124:	56                   	push   %esi
f0104125:	53                   	push   %ebx
f0104126:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104129:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010412c:	85 c9                	test   %ecx,%ecx
f010412e:	74 13                	je     f0104143 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104130:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104136:	75 05                	jne    f010413d <memset+0x1d>
f0104138:	f6 c1 03             	test   $0x3,%cl
f010413b:	74 0d                	je     f010414a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010413d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104140:	fc                   	cld    
f0104141:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104143:	89 f8                	mov    %edi,%eax
f0104145:	5b                   	pop    %ebx
f0104146:	5e                   	pop    %esi
f0104147:	5f                   	pop    %edi
f0104148:	5d                   	pop    %ebp
f0104149:	c3                   	ret    
		c &= 0xFF;
f010414a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010414e:	89 d3                	mov    %edx,%ebx
f0104150:	c1 e3 08             	shl    $0x8,%ebx
f0104153:	89 d0                	mov    %edx,%eax
f0104155:	c1 e0 18             	shl    $0x18,%eax
f0104158:	89 d6                	mov    %edx,%esi
f010415a:	c1 e6 10             	shl    $0x10,%esi
f010415d:	09 f0                	or     %esi,%eax
f010415f:	09 c2                	or     %eax,%edx
f0104161:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0104163:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0104166:	89 d0                	mov    %edx,%eax
f0104168:	fc                   	cld    
f0104169:	f3 ab                	rep stos %eax,%es:(%edi)
f010416b:	eb d6                	jmp    f0104143 <memset+0x23>

f010416d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010416d:	55                   	push   %ebp
f010416e:	89 e5                	mov    %esp,%ebp
f0104170:	57                   	push   %edi
f0104171:	56                   	push   %esi
f0104172:	8b 45 08             	mov    0x8(%ebp),%eax
f0104175:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104178:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010417b:	39 c6                	cmp    %eax,%esi
f010417d:	73 35                	jae    f01041b4 <memmove+0x47>
f010417f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104182:	39 c2                	cmp    %eax,%edx
f0104184:	76 2e                	jbe    f01041b4 <memmove+0x47>
		s += n;
		d += n;
f0104186:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104189:	89 d6                	mov    %edx,%esi
f010418b:	09 fe                	or     %edi,%esi
f010418d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104193:	74 0c                	je     f01041a1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104195:	83 ef 01             	sub    $0x1,%edi
f0104198:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010419b:	fd                   	std    
f010419c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010419e:	fc                   	cld    
f010419f:	eb 21                	jmp    f01041c2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01041a1:	f6 c1 03             	test   $0x3,%cl
f01041a4:	75 ef                	jne    f0104195 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01041a6:	83 ef 04             	sub    $0x4,%edi
f01041a9:	8d 72 fc             	lea    -0x4(%edx),%esi
f01041ac:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01041af:	fd                   	std    
f01041b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01041b2:	eb ea                	jmp    f010419e <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01041b4:	89 f2                	mov    %esi,%edx
f01041b6:	09 c2                	or     %eax,%edx
f01041b8:	f6 c2 03             	test   $0x3,%dl
f01041bb:	74 09                	je     f01041c6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01041bd:	89 c7                	mov    %eax,%edi
f01041bf:	fc                   	cld    
f01041c0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01041c2:	5e                   	pop    %esi
f01041c3:	5f                   	pop    %edi
f01041c4:	5d                   	pop    %ebp
f01041c5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01041c6:	f6 c1 03             	test   $0x3,%cl
f01041c9:	75 f2                	jne    f01041bd <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01041cb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01041ce:	89 c7                	mov    %eax,%edi
f01041d0:	fc                   	cld    
f01041d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01041d3:	eb ed                	jmp    f01041c2 <memmove+0x55>

f01041d5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01041d5:	55                   	push   %ebp
f01041d6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01041d8:	ff 75 10             	pushl  0x10(%ebp)
f01041db:	ff 75 0c             	pushl  0xc(%ebp)
f01041de:	ff 75 08             	pushl  0x8(%ebp)
f01041e1:	e8 87 ff ff ff       	call   f010416d <memmove>
}
f01041e6:	c9                   	leave  
f01041e7:	c3                   	ret    

f01041e8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01041e8:	55                   	push   %ebp
f01041e9:	89 e5                	mov    %esp,%ebp
f01041eb:	56                   	push   %esi
f01041ec:	53                   	push   %ebx
f01041ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01041f0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01041f3:	89 c6                	mov    %eax,%esi
f01041f5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01041f8:	39 f0                	cmp    %esi,%eax
f01041fa:	74 1c                	je     f0104218 <memcmp+0x30>
		if (*s1 != *s2)
f01041fc:	0f b6 08             	movzbl (%eax),%ecx
f01041ff:	0f b6 1a             	movzbl (%edx),%ebx
f0104202:	38 d9                	cmp    %bl,%cl
f0104204:	75 08                	jne    f010420e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0104206:	83 c0 01             	add    $0x1,%eax
f0104209:	83 c2 01             	add    $0x1,%edx
f010420c:	eb ea                	jmp    f01041f8 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f010420e:	0f b6 c1             	movzbl %cl,%eax
f0104211:	0f b6 db             	movzbl %bl,%ebx
f0104214:	29 d8                	sub    %ebx,%eax
f0104216:	eb 05                	jmp    f010421d <memcmp+0x35>
	}

	return 0;
f0104218:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010421d:	5b                   	pop    %ebx
f010421e:	5e                   	pop    %esi
f010421f:	5d                   	pop    %ebp
f0104220:	c3                   	ret    

f0104221 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104221:	55                   	push   %ebp
f0104222:	89 e5                	mov    %esp,%ebp
f0104224:	8b 45 08             	mov    0x8(%ebp),%eax
f0104227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010422a:	89 c2                	mov    %eax,%edx
f010422c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010422f:	39 d0                	cmp    %edx,%eax
f0104231:	73 09                	jae    f010423c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104233:	38 08                	cmp    %cl,(%eax)
f0104235:	74 05                	je     f010423c <memfind+0x1b>
	for (; s < ends; s++)
f0104237:	83 c0 01             	add    $0x1,%eax
f010423a:	eb f3                	jmp    f010422f <memfind+0xe>
			break;
	return (void *) s;
}
f010423c:	5d                   	pop    %ebp
f010423d:	c3                   	ret    

f010423e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010423e:	55                   	push   %ebp
f010423f:	89 e5                	mov    %esp,%ebp
f0104241:	57                   	push   %edi
f0104242:	56                   	push   %esi
f0104243:	53                   	push   %ebx
f0104244:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104247:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010424a:	eb 03                	jmp    f010424f <strtol+0x11>
		s++;
f010424c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010424f:	0f b6 01             	movzbl (%ecx),%eax
f0104252:	3c 20                	cmp    $0x20,%al
f0104254:	74 f6                	je     f010424c <strtol+0xe>
f0104256:	3c 09                	cmp    $0x9,%al
f0104258:	74 f2                	je     f010424c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010425a:	3c 2b                	cmp    $0x2b,%al
f010425c:	74 2e                	je     f010428c <strtol+0x4e>
	int neg = 0;
f010425e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0104263:	3c 2d                	cmp    $0x2d,%al
f0104265:	74 2f                	je     f0104296 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104267:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010426d:	75 05                	jne    f0104274 <strtol+0x36>
f010426f:	80 39 30             	cmpb   $0x30,(%ecx)
f0104272:	74 2c                	je     f01042a0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104274:	85 db                	test   %ebx,%ebx
f0104276:	75 0a                	jne    f0104282 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104278:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f010427d:	80 39 30             	cmpb   $0x30,(%ecx)
f0104280:	74 28                	je     f01042aa <strtol+0x6c>
		base = 10;
f0104282:	b8 00 00 00 00       	mov    $0x0,%eax
f0104287:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010428a:	eb 50                	jmp    f01042dc <strtol+0x9e>
		s++;
f010428c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f010428f:	bf 00 00 00 00       	mov    $0x0,%edi
f0104294:	eb d1                	jmp    f0104267 <strtol+0x29>
		s++, neg = 1;
f0104296:	83 c1 01             	add    $0x1,%ecx
f0104299:	bf 01 00 00 00       	mov    $0x1,%edi
f010429e:	eb c7                	jmp    f0104267 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01042a0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01042a4:	74 0e                	je     f01042b4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01042a6:	85 db                	test   %ebx,%ebx
f01042a8:	75 d8                	jne    f0104282 <strtol+0x44>
		s++, base = 8;
f01042aa:	83 c1 01             	add    $0x1,%ecx
f01042ad:	bb 08 00 00 00       	mov    $0x8,%ebx
f01042b2:	eb ce                	jmp    f0104282 <strtol+0x44>
		s += 2, base = 16;
f01042b4:	83 c1 02             	add    $0x2,%ecx
f01042b7:	bb 10 00 00 00       	mov    $0x10,%ebx
f01042bc:	eb c4                	jmp    f0104282 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01042be:	8d 72 9f             	lea    -0x61(%edx),%esi
f01042c1:	89 f3                	mov    %esi,%ebx
f01042c3:	80 fb 19             	cmp    $0x19,%bl
f01042c6:	77 29                	ja     f01042f1 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01042c8:	0f be d2             	movsbl %dl,%edx
f01042cb:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01042ce:	3b 55 10             	cmp    0x10(%ebp),%edx
f01042d1:	7d 30                	jge    f0104303 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01042d3:	83 c1 01             	add    $0x1,%ecx
f01042d6:	0f af 45 10          	imul   0x10(%ebp),%eax
f01042da:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01042dc:	0f b6 11             	movzbl (%ecx),%edx
f01042df:	8d 72 d0             	lea    -0x30(%edx),%esi
f01042e2:	89 f3                	mov    %esi,%ebx
f01042e4:	80 fb 09             	cmp    $0x9,%bl
f01042e7:	77 d5                	ja     f01042be <strtol+0x80>
			dig = *s - '0';
f01042e9:	0f be d2             	movsbl %dl,%edx
f01042ec:	83 ea 30             	sub    $0x30,%edx
f01042ef:	eb dd                	jmp    f01042ce <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f01042f1:	8d 72 bf             	lea    -0x41(%edx),%esi
f01042f4:	89 f3                	mov    %esi,%ebx
f01042f6:	80 fb 19             	cmp    $0x19,%bl
f01042f9:	77 08                	ja     f0104303 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01042fb:	0f be d2             	movsbl %dl,%edx
f01042fe:	83 ea 37             	sub    $0x37,%edx
f0104301:	eb cb                	jmp    f01042ce <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104303:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104307:	74 05                	je     f010430e <strtol+0xd0>
		*endptr = (char *) s;
f0104309:	8b 75 0c             	mov    0xc(%ebp),%esi
f010430c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010430e:	89 c2                	mov    %eax,%edx
f0104310:	f7 da                	neg    %edx
f0104312:	85 ff                	test   %edi,%edi
f0104314:	0f 45 c2             	cmovne %edx,%eax
}
f0104317:	5b                   	pop    %ebx
f0104318:	5e                   	pop    %esi
f0104319:	5f                   	pop    %edi
f010431a:	5d                   	pop    %ebp
f010431b:	c3                   	ret    

f010431c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010431c:	fa                   	cli    

	xorw    %ax, %ax
f010431d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010431f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104321:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104323:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0104325:	0f 01 16             	lgdtl  (%esi)
f0104328:	74 70                	je     f010439a <mpsearch1+0x3>
	movl    %cr0, %eax
f010432a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010432d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0104331:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0104334:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010433a:	08 00                	or     %al,(%eax)

f010433c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010433c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0104340:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104342:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104344:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0104346:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010434a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010434c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010434e:	b8 00 c0 11 00       	mov    $0x11c000,%eax
	movl    %eax, %cr3
f0104353:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0104356:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0104359:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010435e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0104361:	8b 25 04 9f 22 f0    	mov    0xf0229f04,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0104367:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010436c:	b8 94 01 10 f0       	mov    $0xf0100194,%eax
	call    *%eax
f0104371:	ff d0                	call   *%eax

f0104373 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0104373:	eb fe                	jmp    f0104373 <spin>
f0104375:	8d 76 00             	lea    0x0(%esi),%esi

f0104378 <gdt>:
	...
f0104380:	ff                   	(bad)  
f0104381:	ff 00                	incl   (%eax)
f0104383:	00 00                	add    %al,(%eax)
f0104385:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010438c:	00                   	.byte 0x0
f010438d:	92                   	xchg   %eax,%edx
f010438e:	cf                   	iret   
	...

f0104390 <gdtdesc>:
f0104390:	17                   	pop    %ss
f0104391:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0104396 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0104396:	90                   	nop

f0104397 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0104397:	55                   	push   %ebp
f0104398:	89 e5                	mov    %esp,%ebp
f010439a:	57                   	push   %edi
f010439b:	56                   	push   %esi
f010439c:	53                   	push   %ebx
f010439d:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f01043a0:	8b 0d 08 9f 22 f0    	mov    0xf0229f08,%ecx
f01043a6:	89 c3                	mov    %eax,%ebx
f01043a8:	c1 eb 0c             	shr    $0xc,%ebx
f01043ab:	39 cb                	cmp    %ecx,%ebx
f01043ad:	73 1a                	jae    f01043c9 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f01043af:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01043b5:	8d 34 02             	lea    (%edx,%eax,1),%esi
	if (PGNUM(pa) >= npages)
f01043b8:	89 f0                	mov    %esi,%eax
f01043ba:	c1 e8 0c             	shr    $0xc,%eax
f01043bd:	39 c8                	cmp    %ecx,%eax
f01043bf:	73 1a                	jae    f01043db <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f01043c1:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01043c7:	eb 27                	jmp    f01043f0 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01043c9:	50                   	push   %eax
f01043ca:	68 a4 4d 10 f0       	push   $0xf0104da4
f01043cf:	6a 57                	push   $0x57
f01043d1:	68 61 64 10 f0       	push   $0xf0106461
f01043d6:	e8 65 bc ff ff       	call   f0100040 <_panic>
f01043db:	56                   	push   %esi
f01043dc:	68 a4 4d 10 f0       	push   $0xf0104da4
f01043e1:	6a 57                	push   $0x57
f01043e3:	68 61 64 10 f0       	push   $0xf0106461
f01043e8:	e8 53 bc ff ff       	call   f0100040 <_panic>
f01043ed:	83 c3 10             	add    $0x10,%ebx
f01043f0:	39 f3                	cmp    %esi,%ebx
f01043f2:	73 2e                	jae    f0104422 <mpsearch1+0x8b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01043f4:	83 ec 04             	sub    $0x4,%esp
f01043f7:	6a 04                	push   $0x4
f01043f9:	68 71 64 10 f0       	push   $0xf0106471
f01043fe:	53                   	push   %ebx
f01043ff:	e8 e4 fd ff ff       	call   f01041e8 <memcmp>
f0104404:	83 c4 10             	add    $0x10,%esp
f0104407:	85 c0                	test   %eax,%eax
f0104409:	75 e2                	jne    f01043ed <mpsearch1+0x56>
f010440b:	89 da                	mov    %ebx,%edx
f010440d:	8d 7b 10             	lea    0x10(%ebx),%edi
		sum += ((uint8_t *)addr)[i];
f0104410:	0f b6 0a             	movzbl (%edx),%ecx
f0104413:	01 c8                	add    %ecx,%eax
f0104415:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0104418:	39 fa                	cmp    %edi,%edx
f010441a:	75 f4                	jne    f0104410 <mpsearch1+0x79>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010441c:	84 c0                	test   %al,%al
f010441e:	75 cd                	jne    f01043ed <mpsearch1+0x56>
f0104420:	eb 05                	jmp    f0104427 <mpsearch1+0x90>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0104422:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0104427:	89 d8                	mov    %ebx,%eax
f0104429:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010442c:	5b                   	pop    %ebx
f010442d:	5e                   	pop    %esi
f010442e:	5f                   	pop    %edi
f010442f:	5d                   	pop    %ebp
f0104430:	c3                   	ret    

f0104431 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0104431:	55                   	push   %ebp
f0104432:	89 e5                	mov    %esp,%ebp
f0104434:	57                   	push   %edi
f0104435:	56                   	push   %esi
f0104436:	53                   	push   %ebx
f0104437:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010443a:	c7 05 c0 a3 22 f0 20 	movl   $0xf022a020,0xf022a3c0
f0104441:	a0 22 f0 
	if (PGNUM(pa) >= npages)
f0104444:	83 3d 08 9f 22 f0 00 	cmpl   $0x0,0xf0229f08
f010444b:	0f 84 87 00 00 00    	je     f01044d8 <mp_init+0xa7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0104451:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0104458:	85 c0                	test   %eax,%eax
f010445a:	0f 84 8e 00 00 00    	je     f01044ee <mp_init+0xbd>
		p <<= 4;	// Translate from segment to PA
f0104460:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0104463:	ba 00 04 00 00       	mov    $0x400,%edx
f0104468:	e8 2a ff ff ff       	call   f0104397 <mpsearch1>
f010446d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104470:	85 c0                	test   %eax,%eax
f0104472:	0f 84 9a 00 00 00    	je     f0104512 <mp_init+0xe1>
	if (mp->physaddr == 0 || mp->type != 0) {
f0104478:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010447b:	8b 41 04             	mov    0x4(%ecx),%eax
f010447e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104481:	85 c0                	test   %eax,%eax
f0104483:	0f 84 a8 00 00 00    	je     f0104531 <mp_init+0x100>
f0104489:	80 79 0b 00          	cmpb   $0x0,0xb(%ecx)
f010448d:	0f 85 9e 00 00 00    	jne    f0104531 <mp_init+0x100>
f0104493:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104496:	c1 e8 0c             	shr    $0xc,%eax
f0104499:	3b 05 08 9f 22 f0    	cmp    0xf0229f08,%eax
f010449f:	0f 83 a1 00 00 00    	jae    f0104546 <mp_init+0x115>
	return (void *)(pa + KERNBASE);
f01044a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01044a8:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01044ae:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01044b0:	83 ec 04             	sub    $0x4,%esp
f01044b3:	6a 04                	push   $0x4
f01044b5:	68 76 64 10 f0       	push   $0xf0106476
f01044ba:	53                   	push   %ebx
f01044bb:	e8 28 fd ff ff       	call   f01041e8 <memcmp>
f01044c0:	83 c4 10             	add    $0x10,%esp
f01044c3:	85 c0                	test   %eax,%eax
f01044c5:	0f 85 92 00 00 00    	jne    f010455d <mp_init+0x12c>
f01044cb:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f01044cf:	01 df                	add    %ebx,%edi
	sum = 0;
f01044d1:	89 c2                	mov    %eax,%edx
f01044d3:	e9 a2 00 00 00       	jmp    f010457a <mp_init+0x149>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01044d8:	68 00 04 00 00       	push   $0x400
f01044dd:	68 a4 4d 10 f0       	push   $0xf0104da4
f01044e2:	6a 6f                	push   $0x6f
f01044e4:	68 61 64 10 f0       	push   $0xf0106461
f01044e9:	e8 52 bb ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01044ee:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01044f5:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01044f8:	2d 00 04 00 00       	sub    $0x400,%eax
f01044fd:	ba 00 04 00 00       	mov    $0x400,%edx
f0104502:	e8 90 fe ff ff       	call   f0104397 <mpsearch1>
f0104507:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010450a:	85 c0                	test   %eax,%eax
f010450c:	0f 85 66 ff ff ff    	jne    f0104478 <mp_init+0x47>
	return mpsearch1(0xF0000, 0x10000);
f0104512:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104517:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010451c:	e8 76 fe ff ff       	call   f0104397 <mpsearch1>
f0104521:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if ((mp = mpsearch()) == 0)
f0104524:	85 c0                	test   %eax,%eax
f0104526:	0f 85 4c ff ff ff    	jne    f0104478 <mp_init+0x47>
f010452c:	e9 a8 01 00 00       	jmp    f01046d9 <mp_init+0x2a8>
		cprintf("SMP: Default configurations not implemented\n");
f0104531:	83 ec 0c             	sub    $0xc,%esp
f0104534:	68 d4 62 10 f0       	push   $0xf01062d4
f0104539:	e8 57 e6 ff ff       	call   f0102b95 <cprintf>
f010453e:	83 c4 10             	add    $0x10,%esp
f0104541:	e9 93 01 00 00       	jmp    f01046d9 <mp_init+0x2a8>
f0104546:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104549:	68 a4 4d 10 f0       	push   $0xf0104da4
f010454e:	68 90 00 00 00       	push   $0x90
f0104553:	68 61 64 10 f0       	push   $0xf0106461
f0104558:	e8 e3 ba ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010455d:	83 ec 0c             	sub    $0xc,%esp
f0104560:	68 04 63 10 f0       	push   $0xf0106304
f0104565:	e8 2b e6 ff ff       	call   f0102b95 <cprintf>
f010456a:	83 c4 10             	add    $0x10,%esp
f010456d:	e9 67 01 00 00       	jmp    f01046d9 <mp_init+0x2a8>
		sum += ((uint8_t *)addr)[i];
f0104572:	0f b6 0b             	movzbl (%ebx),%ecx
f0104575:	01 ca                	add    %ecx,%edx
f0104577:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f010457a:	39 fb                	cmp    %edi,%ebx
f010457c:	75 f4                	jne    f0104572 <mp_init+0x141>
	if (sum(conf, conf->length) != 0) {
f010457e:	84 d2                	test   %dl,%dl
f0104580:	75 16                	jne    f0104598 <mp_init+0x167>
	if (conf->version != 1 && conf->version != 4) {
f0104582:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0104586:	80 fa 01             	cmp    $0x1,%dl
f0104589:	74 05                	je     f0104590 <mp_init+0x15f>
f010458b:	80 fa 04             	cmp    $0x4,%dl
f010458e:	75 1d                	jne    f01045ad <mp_init+0x17c>
f0104590:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0104594:	01 d9                	add    %ebx,%ecx
f0104596:	eb 36                	jmp    f01045ce <mp_init+0x19d>
		cprintf("SMP: Bad MP configuration checksum\n");
f0104598:	83 ec 0c             	sub    $0xc,%esp
f010459b:	68 38 63 10 f0       	push   $0xf0106338
f01045a0:	e8 f0 e5 ff ff       	call   f0102b95 <cprintf>
f01045a5:	83 c4 10             	add    $0x10,%esp
f01045a8:	e9 2c 01 00 00       	jmp    f01046d9 <mp_init+0x2a8>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01045ad:	83 ec 08             	sub    $0x8,%esp
f01045b0:	0f b6 d2             	movzbl %dl,%edx
f01045b3:	52                   	push   %edx
f01045b4:	68 5c 63 10 f0       	push   $0xf010635c
f01045b9:	e8 d7 e5 ff ff       	call   f0102b95 <cprintf>
f01045be:	83 c4 10             	add    $0x10,%esp
f01045c1:	e9 13 01 00 00       	jmp    f01046d9 <mp_init+0x2a8>
		sum += ((uint8_t *)addr)[i];
f01045c6:	0f b6 13             	movzbl (%ebx),%edx
f01045c9:	01 d0                	add    %edx,%eax
f01045cb:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f01045ce:	39 d9                	cmp    %ebx,%ecx
f01045d0:	75 f4                	jne    f01045c6 <mp_init+0x195>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01045d2:	02 46 2a             	add    0x2a(%esi),%al
f01045d5:	75 29                	jne    f0104600 <mp_init+0x1cf>
	if ((conf = mpconfig(&mp)) == 0)
f01045d7:	81 7d e4 00 00 00 10 	cmpl   $0x10000000,-0x1c(%ebp)
f01045de:	0f 84 f5 00 00 00    	je     f01046d9 <mp_init+0x2a8>
		return;
	ismp = 1;
f01045e4:	c7 05 00 a0 22 f0 01 	movl   $0x1,0xf022a000
f01045eb:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01045ee:	8b 46 24             	mov    0x24(%esi),%eax
f01045f1:	a3 00 b0 26 f0       	mov    %eax,0xf026b000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01045f6:	8d 7e 2c             	lea    0x2c(%esi),%edi
f01045f9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01045fe:	eb 4d                	jmp    f010464d <mp_init+0x21c>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0104600:	83 ec 0c             	sub    $0xc,%esp
f0104603:	68 7c 63 10 f0       	push   $0xf010637c
f0104608:	e8 88 e5 ff ff       	call   f0102b95 <cprintf>
f010460d:	83 c4 10             	add    $0x10,%esp
f0104610:	e9 c4 00 00 00       	jmp    f01046d9 <mp_init+0x2a8>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0104615:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0104619:	74 11                	je     f010462c <mp_init+0x1fb>
				bootcpu = &cpus[ncpu];
f010461b:	6b 05 c4 a3 22 f0 74 	imul   $0x74,0xf022a3c4,%eax
f0104622:	05 20 a0 22 f0       	add    $0xf022a020,%eax
f0104627:	a3 c0 a3 22 f0       	mov    %eax,0xf022a3c0
			if (ncpu < NCPU) {
f010462c:	a1 c4 a3 22 f0       	mov    0xf022a3c4,%eax
f0104631:	83 f8 07             	cmp    $0x7,%eax
f0104634:	7f 2f                	jg     f0104665 <mp_init+0x234>
				cpus[ncpu].cpu_id = ncpu;
f0104636:	6b d0 74             	imul   $0x74,%eax,%edx
f0104639:	88 82 20 a0 22 f0    	mov    %al,-0xfdd5fe0(%edx)
				ncpu++;
f010463f:	83 c0 01             	add    $0x1,%eax
f0104642:	a3 c4 a3 22 f0       	mov    %eax,0xf022a3c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0104647:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010464a:	83 c3 01             	add    $0x1,%ebx
f010464d:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0104651:	39 d8                	cmp    %ebx,%eax
f0104653:	76 4b                	jbe    f01046a0 <mp_init+0x26f>
		switch (*p) {
f0104655:	0f b6 07             	movzbl (%edi),%eax
f0104658:	84 c0                	test   %al,%al
f010465a:	74 b9                	je     f0104615 <mp_init+0x1e4>
f010465c:	3c 04                	cmp    $0x4,%al
f010465e:	77 1c                	ja     f010467c <mp_init+0x24b>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0104660:	83 c7 08             	add    $0x8,%edi
			continue;
f0104663:	eb e5                	jmp    f010464a <mp_init+0x219>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0104665:	83 ec 08             	sub    $0x8,%esp
f0104668:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f010466c:	50                   	push   %eax
f010466d:	68 ac 63 10 f0       	push   $0xf01063ac
f0104672:	e8 1e e5 ff ff       	call   f0102b95 <cprintf>
f0104677:	83 c4 10             	add    $0x10,%esp
f010467a:	eb cb                	jmp    f0104647 <mp_init+0x216>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010467c:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f010467f:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0104682:	50                   	push   %eax
f0104683:	68 d4 63 10 f0       	push   $0xf01063d4
f0104688:	e8 08 e5 ff ff       	call   f0102b95 <cprintf>
			ismp = 0;
f010468d:	c7 05 00 a0 22 f0 00 	movl   $0x0,0xf022a000
f0104694:	00 00 00 
			i = conf->entry;
f0104697:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f010469b:	83 c4 10             	add    $0x10,%esp
f010469e:	eb aa                	jmp    f010464a <mp_init+0x219>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01046a0:	a1 c0 a3 22 f0       	mov    0xf022a3c0,%eax
f01046a5:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01046ac:	83 3d 00 a0 22 f0 00 	cmpl   $0x0,0xf022a000
f01046b3:	75 2c                	jne    f01046e1 <mp_init+0x2b0>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01046b5:	c7 05 c4 a3 22 f0 01 	movl   $0x1,0xf022a3c4
f01046bc:	00 00 00 
		lapicaddr = 0;
f01046bf:	c7 05 00 b0 26 f0 00 	movl   $0x0,0xf026b000
f01046c6:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01046c9:	83 ec 0c             	sub    $0xc,%esp
f01046cc:	68 f4 63 10 f0       	push   $0xf01063f4
f01046d1:	e8 bf e4 ff ff       	call   f0102b95 <cprintf>
		return;
f01046d6:	83 c4 10             	add    $0x10,%esp
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01046d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01046dc:	5b                   	pop    %ebx
f01046dd:	5e                   	pop    %esi
f01046de:	5f                   	pop    %edi
f01046df:	5d                   	pop    %ebp
f01046e0:	c3                   	ret    
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01046e1:	83 ec 04             	sub    $0x4,%esp
f01046e4:	ff 35 c4 a3 22 f0    	pushl  0xf022a3c4
f01046ea:	0f b6 00             	movzbl (%eax),%eax
f01046ed:	50                   	push   %eax
f01046ee:	68 7b 64 10 f0       	push   $0xf010647b
f01046f3:	e8 9d e4 ff ff       	call   f0102b95 <cprintf>
	if (mp->imcrp) {
f01046f8:	83 c4 10             	add    $0x10,%esp
f01046fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01046fe:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0104702:	74 d5                	je     f01046d9 <mp_init+0x2a8>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0104704:	83 ec 0c             	sub    $0xc,%esp
f0104707:	68 20 64 10 f0       	push   $0xf0106420
f010470c:	e8 84 e4 ff ff       	call   f0102b95 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104711:	b8 70 00 00 00       	mov    $0x70,%eax
f0104716:	ba 22 00 00 00       	mov    $0x22,%edx
f010471b:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010471c:	ba 23 00 00 00       	mov    $0x23,%edx
f0104721:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0104722:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104725:	ee                   	out    %al,(%dx)
f0104726:	83 c4 10             	add    $0x10,%esp
f0104729:	eb ae                	jmp    f01046d9 <mp_init+0x2a8>

f010472b <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010472b:	55                   	push   %ebp
f010472c:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010472e:	8b 0d 04 b0 26 f0    	mov    0xf026b004,%ecx
f0104734:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104737:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0104739:	a1 04 b0 26 f0       	mov    0xf026b004,%eax
f010473e:	8b 40 20             	mov    0x20(%eax),%eax
}
f0104741:	5d                   	pop    %ebp
f0104742:	c3                   	ret    

f0104743 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0104743:	55                   	push   %ebp
f0104744:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0104746:	8b 15 04 b0 26 f0    	mov    0xf026b004,%edx
		return lapic[ID] >> 24;
	return 0;
f010474c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0104751:	85 d2                	test   %edx,%edx
f0104753:	74 06                	je     f010475b <cpunum+0x18>
		return lapic[ID] >> 24;
f0104755:	8b 42 20             	mov    0x20(%edx),%eax
f0104758:	c1 e8 18             	shr    $0x18,%eax
}
f010475b:	5d                   	pop    %ebp
f010475c:	c3                   	ret    

f010475d <lapic_init>:
	if (!lapicaddr)
f010475d:	a1 00 b0 26 f0       	mov    0xf026b000,%eax
f0104762:	85 c0                	test   %eax,%eax
f0104764:	75 02                	jne    f0104768 <lapic_init+0xb>
f0104766:	f3 c3                	repz ret 
{
f0104768:	55                   	push   %ebp
f0104769:	89 e5                	mov    %esp,%ebp
f010476b:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f010476e:	68 00 10 00 00       	push   $0x1000
f0104773:	50                   	push   %eax
f0104774:	e8 77 c7 ff ff       	call   f0100ef0 <mmio_map_region>
f0104779:	a3 04 b0 26 f0       	mov    %eax,0xf026b004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010477e:	ba 27 01 00 00       	mov    $0x127,%edx
f0104783:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0104788:	e8 9e ff ff ff       	call   f010472b <lapicw>
	lapicw(TDCR, X1);
f010478d:	ba 0b 00 00 00       	mov    $0xb,%edx
f0104792:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0104797:	e8 8f ff ff ff       	call   f010472b <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010479c:	ba 20 00 02 00       	mov    $0x20020,%edx
f01047a1:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01047a6:	e8 80 ff ff ff       	call   f010472b <lapicw>
	lapicw(TICR, 10000000); 
f01047ab:	ba 80 96 98 00       	mov    $0x989680,%edx
f01047b0:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01047b5:	e8 71 ff ff ff       	call   f010472b <lapicw>
	if (thiscpu != bootcpu)
f01047ba:	e8 84 ff ff ff       	call   f0104743 <cpunum>
f01047bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01047c2:	05 20 a0 22 f0       	add    $0xf022a020,%eax
f01047c7:	83 c4 10             	add    $0x10,%esp
f01047ca:	39 05 c0 a3 22 f0    	cmp    %eax,0xf022a3c0
f01047d0:	74 0f                	je     f01047e1 <lapic_init+0x84>
		lapicw(LINT0, MASKED);
f01047d2:	ba 00 00 01 00       	mov    $0x10000,%edx
f01047d7:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01047dc:	e8 4a ff ff ff       	call   f010472b <lapicw>
	lapicw(LINT1, MASKED);
f01047e1:	ba 00 00 01 00       	mov    $0x10000,%edx
f01047e6:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01047eb:	e8 3b ff ff ff       	call   f010472b <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01047f0:	a1 04 b0 26 f0       	mov    0xf026b004,%eax
f01047f5:	8b 40 30             	mov    0x30(%eax),%eax
f01047f8:	c1 e8 10             	shr    $0x10,%eax
f01047fb:	3c 03                	cmp    $0x3,%al
f01047fd:	77 7c                	ja     f010487b <lapic_init+0x11e>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01047ff:	ba 33 00 00 00       	mov    $0x33,%edx
f0104804:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0104809:	e8 1d ff ff ff       	call   f010472b <lapicw>
	lapicw(ESR, 0);
f010480e:	ba 00 00 00 00       	mov    $0x0,%edx
f0104813:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0104818:	e8 0e ff ff ff       	call   f010472b <lapicw>
	lapicw(ESR, 0);
f010481d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104822:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0104827:	e8 ff fe ff ff       	call   f010472b <lapicw>
	lapicw(EOI, 0);
f010482c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104831:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0104836:	e8 f0 fe ff ff       	call   f010472b <lapicw>
	lapicw(ICRHI, 0);
f010483b:	ba 00 00 00 00       	mov    $0x0,%edx
f0104840:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0104845:	e8 e1 fe ff ff       	call   f010472b <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010484a:	ba 00 85 08 00       	mov    $0x88500,%edx
f010484f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0104854:	e8 d2 fe ff ff       	call   f010472b <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0104859:	8b 15 04 b0 26 f0    	mov    0xf026b004,%edx
f010485f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0104865:	f6 c4 10             	test   $0x10,%ah
f0104868:	75 f5                	jne    f010485f <lapic_init+0x102>
	lapicw(TPR, 0);
f010486a:	ba 00 00 00 00       	mov    $0x0,%edx
f010486f:	b8 20 00 00 00       	mov    $0x20,%eax
f0104874:	e8 b2 fe ff ff       	call   f010472b <lapicw>
}
f0104879:	c9                   	leave  
f010487a:	c3                   	ret    
		lapicw(PCINT, MASKED);
f010487b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104880:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0104885:	e8 a1 fe ff ff       	call   f010472b <lapicw>
f010488a:	e9 70 ff ff ff       	jmp    f01047ff <lapic_init+0xa2>

f010488f <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f010488f:	83 3d 04 b0 26 f0 00 	cmpl   $0x0,0xf026b004
f0104896:	74 14                	je     f01048ac <lapic_eoi+0x1d>
{
f0104898:	55                   	push   %ebp
f0104899:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f010489b:	ba 00 00 00 00       	mov    $0x0,%edx
f01048a0:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01048a5:	e8 81 fe ff ff       	call   f010472b <lapicw>
}
f01048aa:	5d                   	pop    %ebp
f01048ab:	c3                   	ret    
f01048ac:	f3 c3                	repz ret 

f01048ae <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01048ae:	55                   	push   %ebp
f01048af:	89 e5                	mov    %esp,%ebp
f01048b1:	56                   	push   %esi
f01048b2:	53                   	push   %ebx
f01048b3:	8b 75 08             	mov    0x8(%ebp),%esi
f01048b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01048b9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01048be:	ba 70 00 00 00       	mov    $0x70,%edx
f01048c3:	ee                   	out    %al,(%dx)
f01048c4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01048c9:	ba 71 00 00 00       	mov    $0x71,%edx
f01048ce:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f01048cf:	83 3d 08 9f 22 f0 00 	cmpl   $0x0,0xf0229f08
f01048d6:	74 7e                	je     f0104956 <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01048d8:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01048df:	00 00 
	wrv[1] = addr >> 4;
f01048e1:	89 d8                	mov    %ebx,%eax
f01048e3:	c1 e8 04             	shr    $0x4,%eax
f01048e6:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01048ec:	c1 e6 18             	shl    $0x18,%esi
f01048ef:	89 f2                	mov    %esi,%edx
f01048f1:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01048f6:	e8 30 fe ff ff       	call   f010472b <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01048fb:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0104900:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0104905:	e8 21 fe ff ff       	call   f010472b <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010490a:	ba 00 85 00 00       	mov    $0x8500,%edx
f010490f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0104914:	e8 12 fe ff ff       	call   f010472b <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0104919:	c1 eb 0c             	shr    $0xc,%ebx
f010491c:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f010491f:	89 f2                	mov    %esi,%edx
f0104921:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0104926:	e8 00 fe ff ff       	call   f010472b <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010492b:	89 da                	mov    %ebx,%edx
f010492d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0104932:	e8 f4 fd ff ff       	call   f010472b <lapicw>
		lapicw(ICRHI, apicid << 24);
f0104937:	89 f2                	mov    %esi,%edx
f0104939:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010493e:	e8 e8 fd ff ff       	call   f010472b <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0104943:	89 da                	mov    %ebx,%edx
f0104945:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010494a:	e8 dc fd ff ff       	call   f010472b <lapicw>
		microdelay(200);
	}
}
f010494f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104952:	5b                   	pop    %ebx
f0104953:	5e                   	pop    %esi
f0104954:	5d                   	pop    %ebp
f0104955:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104956:	68 67 04 00 00       	push   $0x467
f010495b:	68 a4 4d 10 f0       	push   $0xf0104da4
f0104960:	68 98 00 00 00       	push   $0x98
f0104965:	68 98 64 10 f0       	push   $0xf0106498
f010496a:	e8 d1 b6 ff ff       	call   f0100040 <_panic>

f010496f <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010496f:	55                   	push   %ebp
f0104970:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0104972:	8b 55 08             	mov    0x8(%ebp),%edx
f0104975:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010497b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0104980:	e8 a6 fd ff ff       	call   f010472b <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0104985:	8b 15 04 b0 26 f0    	mov    0xf026b004,%edx
f010498b:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0104991:	f6 c4 10             	test   $0x10,%ah
f0104994:	75 f5                	jne    f010498b <lapic_ipi+0x1c>
		;
}
f0104996:	5d                   	pop    %ebp
f0104997:	c3                   	ret    

f0104998 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0104998:	55                   	push   %ebp
f0104999:	89 e5                	mov    %esp,%ebp
f010499b:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010499e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01049a4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01049a7:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01049aa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01049b1:	5d                   	pop    %ebp
f01049b2:	c3                   	ret    

f01049b3 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01049b3:	55                   	push   %ebp
f01049b4:	89 e5                	mov    %esp,%ebp
f01049b6:	56                   	push   %esi
f01049b7:	53                   	push   %ebx
f01049b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f01049bb:	83 3b 00             	cmpl   $0x0,(%ebx)
f01049be:	75 07                	jne    f01049c7 <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f01049c0:	ba 01 00 00 00       	mov    $0x1,%edx
f01049c5:	eb 34                	jmp    f01049fb <spin_lock+0x48>
f01049c7:	8b 73 08             	mov    0x8(%ebx),%esi
f01049ca:	e8 74 fd ff ff       	call   f0104743 <cpunum>
f01049cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01049d2:	05 20 a0 22 f0       	add    $0xf022a020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01049d7:	39 c6                	cmp    %eax,%esi
f01049d9:	75 e5                	jne    f01049c0 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01049db:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01049de:	e8 60 fd ff ff       	call   f0104743 <cpunum>
f01049e3:	83 ec 0c             	sub    $0xc,%esp
f01049e6:	53                   	push   %ebx
f01049e7:	50                   	push   %eax
f01049e8:	68 a8 64 10 f0       	push   $0xf01064a8
f01049ed:	6a 41                	push   $0x41
f01049ef:	68 0c 65 10 f0       	push   $0xf010650c
f01049f4:	e8 47 b6 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01049f9:	f3 90                	pause  
f01049fb:	89 d0                	mov    %edx,%eax
f01049fd:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0104a00:	85 c0                	test   %eax,%eax
f0104a02:	75 f5                	jne    f01049f9 <spin_lock+0x46>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0104a04:	e8 3a fd ff ff       	call   f0104743 <cpunum>
f0104a09:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a0c:	05 20 a0 22 f0       	add    $0xf022a020,%eax
f0104a11:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0104a14:	83 c3 0c             	add    $0xc,%ebx
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0104a17:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0104a19:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a1e:	eb 0b                	jmp    f0104a2b <spin_lock+0x78>
		pcs[i] = ebp[1];          // saved %eip
f0104a20:	8b 4a 04             	mov    0x4(%edx),%ecx
f0104a23:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0104a26:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0104a28:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0104a2b:	83 f8 09             	cmp    $0x9,%eax
f0104a2e:	7f 14                	jg     f0104a44 <spin_lock+0x91>
f0104a30:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0104a36:	77 e8                	ja     f0104a20 <spin_lock+0x6d>
f0104a38:	eb 0a                	jmp    f0104a44 <spin_lock+0x91>
		pcs[i] = 0;
f0104a3a:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f0104a41:	83 c0 01             	add    $0x1,%eax
f0104a44:	83 f8 09             	cmp    $0x9,%eax
f0104a47:	7e f1                	jle    f0104a3a <spin_lock+0x87>
#endif
}
f0104a49:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104a4c:	5b                   	pop    %ebx
f0104a4d:	5e                   	pop    %esi
f0104a4e:	5d                   	pop    %ebp
f0104a4f:	c3                   	ret    

f0104a50 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0104a50:	55                   	push   %ebp
f0104a51:	89 e5                	mov    %esp,%ebp
f0104a53:	57                   	push   %edi
f0104a54:	56                   	push   %esi
f0104a55:	53                   	push   %ebx
f0104a56:	83 ec 4c             	sub    $0x4c,%esp
f0104a59:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0104a5c:	83 3e 00             	cmpl   $0x0,(%esi)
f0104a5f:	75 35                	jne    f0104a96 <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0104a61:	83 ec 04             	sub    $0x4,%esp
f0104a64:	6a 28                	push   $0x28
f0104a66:	8d 46 0c             	lea    0xc(%esi),%eax
f0104a69:	50                   	push   %eax
f0104a6a:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0104a6d:	53                   	push   %ebx
f0104a6e:	e8 fa f6 ff ff       	call   f010416d <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0104a73:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0104a76:	0f b6 38             	movzbl (%eax),%edi
f0104a79:	8b 76 04             	mov    0x4(%esi),%esi
f0104a7c:	e8 c2 fc ff ff       	call   f0104743 <cpunum>
f0104a81:	57                   	push   %edi
f0104a82:	56                   	push   %esi
f0104a83:	50                   	push   %eax
f0104a84:	68 d4 64 10 f0       	push   $0xf01064d4
f0104a89:	e8 07 e1 ff ff       	call   f0102b95 <cprintf>
f0104a8e:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0104a91:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0104a94:	eb 61                	jmp    f0104af7 <spin_unlock+0xa7>
	return lock->locked && lock->cpu == thiscpu;
f0104a96:	8b 5e 08             	mov    0x8(%esi),%ebx
f0104a99:	e8 a5 fc ff ff       	call   f0104743 <cpunum>
f0104a9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa1:	05 20 a0 22 f0       	add    $0xf022a020,%eax
	if (!holding(lk)) {
f0104aa6:	39 c3                	cmp    %eax,%ebx
f0104aa8:	75 b7                	jne    f0104a61 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0104aaa:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0104ab1:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0104ab8:	b8 00 00 00 00       	mov    $0x0,%eax
f0104abd:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0104ac0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ac3:	5b                   	pop    %ebx
f0104ac4:	5e                   	pop    %esi
f0104ac5:	5f                   	pop    %edi
f0104ac6:	5d                   	pop    %ebp
f0104ac7:	c3                   	ret    
					pcs[i] - info.eip_fn_addr);
f0104ac8:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0104aca:	83 ec 04             	sub    $0x4,%esp
f0104acd:	89 c2                	mov    %eax,%edx
f0104acf:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0104ad2:	52                   	push   %edx
f0104ad3:	ff 75 b0             	pushl  -0x50(%ebp)
f0104ad6:	ff 75 b4             	pushl  -0x4c(%ebp)
f0104ad9:	ff 75 ac             	pushl  -0x54(%ebp)
f0104adc:	ff 75 a8             	pushl  -0x58(%ebp)
f0104adf:	50                   	push   %eax
f0104ae0:	68 1c 65 10 f0       	push   $0xf010651c
f0104ae5:	e8 ab e0 ff ff       	call   f0102b95 <cprintf>
f0104aea:	83 c4 20             	add    $0x20,%esp
f0104aed:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0104af0:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0104af3:	39 c3                	cmp    %eax,%ebx
f0104af5:	74 2d                	je     f0104b24 <spin_unlock+0xd4>
f0104af7:	89 de                	mov    %ebx,%esi
f0104af9:	8b 03                	mov    (%ebx),%eax
f0104afb:	85 c0                	test   %eax,%eax
f0104afd:	74 25                	je     f0104b24 <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0104aff:	83 ec 08             	sub    $0x8,%esp
f0104b02:	57                   	push   %edi
f0104b03:	50                   	push   %eax
f0104b04:	e8 da ea ff ff       	call   f01035e3 <debuginfo_eip>
f0104b09:	83 c4 10             	add    $0x10,%esp
f0104b0c:	85 c0                	test   %eax,%eax
f0104b0e:	79 b8                	jns    f0104ac8 <spin_unlock+0x78>
				cprintf("  %08x\n", pcs[i]);
f0104b10:	83 ec 08             	sub    $0x8,%esp
f0104b13:	ff 36                	pushl  (%esi)
f0104b15:	68 33 65 10 f0       	push   $0xf0106533
f0104b1a:	e8 76 e0 ff ff       	call   f0102b95 <cprintf>
f0104b1f:	83 c4 10             	add    $0x10,%esp
f0104b22:	eb c9                	jmp    f0104aed <spin_unlock+0x9d>
		panic("spin_unlock");
f0104b24:	83 ec 04             	sub    $0x4,%esp
f0104b27:	68 3b 65 10 f0       	push   $0xf010653b
f0104b2c:	6a 67                	push   $0x67
f0104b2e:	68 0c 65 10 f0       	push   $0xf010650c
f0104b33:	e8 08 b5 ff ff       	call   f0100040 <_panic>
f0104b38:	66 90                	xchg   %ax,%ax
f0104b3a:	66 90                	xchg   %ax,%ax
f0104b3c:	66 90                	xchg   %ax,%ax
f0104b3e:	66 90                	xchg   %ax,%ax

f0104b40 <__udivdi3>:
f0104b40:	55                   	push   %ebp
f0104b41:	57                   	push   %edi
f0104b42:	56                   	push   %esi
f0104b43:	53                   	push   %ebx
f0104b44:	83 ec 1c             	sub    $0x1c,%esp
f0104b47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0104b4b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0104b4f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104b53:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0104b57:	85 d2                	test   %edx,%edx
f0104b59:	75 35                	jne    f0104b90 <__udivdi3+0x50>
f0104b5b:	39 f3                	cmp    %esi,%ebx
f0104b5d:	0f 87 bd 00 00 00    	ja     f0104c20 <__udivdi3+0xe0>
f0104b63:	85 db                	test   %ebx,%ebx
f0104b65:	89 d9                	mov    %ebx,%ecx
f0104b67:	75 0b                	jne    f0104b74 <__udivdi3+0x34>
f0104b69:	b8 01 00 00 00       	mov    $0x1,%eax
f0104b6e:	31 d2                	xor    %edx,%edx
f0104b70:	f7 f3                	div    %ebx
f0104b72:	89 c1                	mov    %eax,%ecx
f0104b74:	31 d2                	xor    %edx,%edx
f0104b76:	89 f0                	mov    %esi,%eax
f0104b78:	f7 f1                	div    %ecx
f0104b7a:	89 c6                	mov    %eax,%esi
f0104b7c:	89 e8                	mov    %ebp,%eax
f0104b7e:	89 f7                	mov    %esi,%edi
f0104b80:	f7 f1                	div    %ecx
f0104b82:	89 fa                	mov    %edi,%edx
f0104b84:	83 c4 1c             	add    $0x1c,%esp
f0104b87:	5b                   	pop    %ebx
f0104b88:	5e                   	pop    %esi
f0104b89:	5f                   	pop    %edi
f0104b8a:	5d                   	pop    %ebp
f0104b8b:	c3                   	ret    
f0104b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104b90:	39 f2                	cmp    %esi,%edx
f0104b92:	77 7c                	ja     f0104c10 <__udivdi3+0xd0>
f0104b94:	0f bd fa             	bsr    %edx,%edi
f0104b97:	83 f7 1f             	xor    $0x1f,%edi
f0104b9a:	0f 84 98 00 00 00    	je     f0104c38 <__udivdi3+0xf8>
f0104ba0:	89 f9                	mov    %edi,%ecx
f0104ba2:	b8 20 00 00 00       	mov    $0x20,%eax
f0104ba7:	29 f8                	sub    %edi,%eax
f0104ba9:	d3 e2                	shl    %cl,%edx
f0104bab:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104baf:	89 c1                	mov    %eax,%ecx
f0104bb1:	89 da                	mov    %ebx,%edx
f0104bb3:	d3 ea                	shr    %cl,%edx
f0104bb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104bb9:	09 d1                	or     %edx,%ecx
f0104bbb:	89 f2                	mov    %esi,%edx
f0104bbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104bc1:	89 f9                	mov    %edi,%ecx
f0104bc3:	d3 e3                	shl    %cl,%ebx
f0104bc5:	89 c1                	mov    %eax,%ecx
f0104bc7:	d3 ea                	shr    %cl,%edx
f0104bc9:	89 f9                	mov    %edi,%ecx
f0104bcb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104bcf:	d3 e6                	shl    %cl,%esi
f0104bd1:	89 eb                	mov    %ebp,%ebx
f0104bd3:	89 c1                	mov    %eax,%ecx
f0104bd5:	d3 eb                	shr    %cl,%ebx
f0104bd7:	09 de                	or     %ebx,%esi
f0104bd9:	89 f0                	mov    %esi,%eax
f0104bdb:	f7 74 24 08          	divl   0x8(%esp)
f0104bdf:	89 d6                	mov    %edx,%esi
f0104be1:	89 c3                	mov    %eax,%ebx
f0104be3:	f7 64 24 0c          	mull   0xc(%esp)
f0104be7:	39 d6                	cmp    %edx,%esi
f0104be9:	72 0c                	jb     f0104bf7 <__udivdi3+0xb7>
f0104beb:	89 f9                	mov    %edi,%ecx
f0104bed:	d3 e5                	shl    %cl,%ebp
f0104bef:	39 c5                	cmp    %eax,%ebp
f0104bf1:	73 5d                	jae    f0104c50 <__udivdi3+0x110>
f0104bf3:	39 d6                	cmp    %edx,%esi
f0104bf5:	75 59                	jne    f0104c50 <__udivdi3+0x110>
f0104bf7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0104bfa:	31 ff                	xor    %edi,%edi
f0104bfc:	89 fa                	mov    %edi,%edx
f0104bfe:	83 c4 1c             	add    $0x1c,%esp
f0104c01:	5b                   	pop    %ebx
f0104c02:	5e                   	pop    %esi
f0104c03:	5f                   	pop    %edi
f0104c04:	5d                   	pop    %ebp
f0104c05:	c3                   	ret    
f0104c06:	8d 76 00             	lea    0x0(%esi),%esi
f0104c09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0104c10:	31 ff                	xor    %edi,%edi
f0104c12:	31 c0                	xor    %eax,%eax
f0104c14:	89 fa                	mov    %edi,%edx
f0104c16:	83 c4 1c             	add    $0x1c,%esp
f0104c19:	5b                   	pop    %ebx
f0104c1a:	5e                   	pop    %esi
f0104c1b:	5f                   	pop    %edi
f0104c1c:	5d                   	pop    %ebp
f0104c1d:	c3                   	ret    
f0104c1e:	66 90                	xchg   %ax,%ax
f0104c20:	31 ff                	xor    %edi,%edi
f0104c22:	89 e8                	mov    %ebp,%eax
f0104c24:	89 f2                	mov    %esi,%edx
f0104c26:	f7 f3                	div    %ebx
f0104c28:	89 fa                	mov    %edi,%edx
f0104c2a:	83 c4 1c             	add    $0x1c,%esp
f0104c2d:	5b                   	pop    %ebx
f0104c2e:	5e                   	pop    %esi
f0104c2f:	5f                   	pop    %edi
f0104c30:	5d                   	pop    %ebp
f0104c31:	c3                   	ret    
f0104c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104c38:	39 f2                	cmp    %esi,%edx
f0104c3a:	72 06                	jb     f0104c42 <__udivdi3+0x102>
f0104c3c:	31 c0                	xor    %eax,%eax
f0104c3e:	39 eb                	cmp    %ebp,%ebx
f0104c40:	77 d2                	ja     f0104c14 <__udivdi3+0xd4>
f0104c42:	b8 01 00 00 00       	mov    $0x1,%eax
f0104c47:	eb cb                	jmp    f0104c14 <__udivdi3+0xd4>
f0104c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104c50:	89 d8                	mov    %ebx,%eax
f0104c52:	31 ff                	xor    %edi,%edi
f0104c54:	eb be                	jmp    f0104c14 <__udivdi3+0xd4>
f0104c56:	66 90                	xchg   %ax,%ax
f0104c58:	66 90                	xchg   %ax,%ax
f0104c5a:	66 90                	xchg   %ax,%ax
f0104c5c:	66 90                	xchg   %ax,%ax
f0104c5e:	66 90                	xchg   %ax,%ax

f0104c60 <__umoddi3>:
f0104c60:	55                   	push   %ebp
f0104c61:	57                   	push   %edi
f0104c62:	56                   	push   %esi
f0104c63:	53                   	push   %ebx
f0104c64:	83 ec 1c             	sub    $0x1c,%esp
f0104c67:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0104c6b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0104c6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0104c73:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104c77:	85 ed                	test   %ebp,%ebp
f0104c79:	89 f0                	mov    %esi,%eax
f0104c7b:	89 da                	mov    %ebx,%edx
f0104c7d:	75 19                	jne    f0104c98 <__umoddi3+0x38>
f0104c7f:	39 df                	cmp    %ebx,%edi
f0104c81:	0f 86 b1 00 00 00    	jbe    f0104d38 <__umoddi3+0xd8>
f0104c87:	f7 f7                	div    %edi
f0104c89:	89 d0                	mov    %edx,%eax
f0104c8b:	31 d2                	xor    %edx,%edx
f0104c8d:	83 c4 1c             	add    $0x1c,%esp
f0104c90:	5b                   	pop    %ebx
f0104c91:	5e                   	pop    %esi
f0104c92:	5f                   	pop    %edi
f0104c93:	5d                   	pop    %ebp
f0104c94:	c3                   	ret    
f0104c95:	8d 76 00             	lea    0x0(%esi),%esi
f0104c98:	39 dd                	cmp    %ebx,%ebp
f0104c9a:	77 f1                	ja     f0104c8d <__umoddi3+0x2d>
f0104c9c:	0f bd cd             	bsr    %ebp,%ecx
f0104c9f:	83 f1 1f             	xor    $0x1f,%ecx
f0104ca2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104ca6:	0f 84 b4 00 00 00    	je     f0104d60 <__umoddi3+0x100>
f0104cac:	b8 20 00 00 00       	mov    $0x20,%eax
f0104cb1:	89 c2                	mov    %eax,%edx
f0104cb3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104cb7:	29 c2                	sub    %eax,%edx
f0104cb9:	89 c1                	mov    %eax,%ecx
f0104cbb:	89 f8                	mov    %edi,%eax
f0104cbd:	d3 e5                	shl    %cl,%ebp
f0104cbf:	89 d1                	mov    %edx,%ecx
f0104cc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104cc5:	d3 e8                	shr    %cl,%eax
f0104cc7:	09 c5                	or     %eax,%ebp
f0104cc9:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104ccd:	89 c1                	mov    %eax,%ecx
f0104ccf:	d3 e7                	shl    %cl,%edi
f0104cd1:	89 d1                	mov    %edx,%ecx
f0104cd3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104cd7:	89 df                	mov    %ebx,%edi
f0104cd9:	d3 ef                	shr    %cl,%edi
f0104cdb:	89 c1                	mov    %eax,%ecx
f0104cdd:	89 f0                	mov    %esi,%eax
f0104cdf:	d3 e3                	shl    %cl,%ebx
f0104ce1:	89 d1                	mov    %edx,%ecx
f0104ce3:	89 fa                	mov    %edi,%edx
f0104ce5:	d3 e8                	shr    %cl,%eax
f0104ce7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104cec:	09 d8                	or     %ebx,%eax
f0104cee:	f7 f5                	div    %ebp
f0104cf0:	d3 e6                	shl    %cl,%esi
f0104cf2:	89 d1                	mov    %edx,%ecx
f0104cf4:	f7 64 24 08          	mull   0x8(%esp)
f0104cf8:	39 d1                	cmp    %edx,%ecx
f0104cfa:	89 c3                	mov    %eax,%ebx
f0104cfc:	89 d7                	mov    %edx,%edi
f0104cfe:	72 06                	jb     f0104d06 <__umoddi3+0xa6>
f0104d00:	75 0e                	jne    f0104d10 <__umoddi3+0xb0>
f0104d02:	39 c6                	cmp    %eax,%esi
f0104d04:	73 0a                	jae    f0104d10 <__umoddi3+0xb0>
f0104d06:	2b 44 24 08          	sub    0x8(%esp),%eax
f0104d0a:	19 ea                	sbb    %ebp,%edx
f0104d0c:	89 d7                	mov    %edx,%edi
f0104d0e:	89 c3                	mov    %eax,%ebx
f0104d10:	89 ca                	mov    %ecx,%edx
f0104d12:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0104d17:	29 de                	sub    %ebx,%esi
f0104d19:	19 fa                	sbb    %edi,%edx
f0104d1b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0104d1f:	89 d0                	mov    %edx,%eax
f0104d21:	d3 e0                	shl    %cl,%eax
f0104d23:	89 d9                	mov    %ebx,%ecx
f0104d25:	d3 ee                	shr    %cl,%esi
f0104d27:	d3 ea                	shr    %cl,%edx
f0104d29:	09 f0                	or     %esi,%eax
f0104d2b:	83 c4 1c             	add    $0x1c,%esp
f0104d2e:	5b                   	pop    %ebx
f0104d2f:	5e                   	pop    %esi
f0104d30:	5f                   	pop    %edi
f0104d31:	5d                   	pop    %ebp
f0104d32:	c3                   	ret    
f0104d33:	90                   	nop
f0104d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104d38:	85 ff                	test   %edi,%edi
f0104d3a:	89 f9                	mov    %edi,%ecx
f0104d3c:	75 0b                	jne    f0104d49 <__umoddi3+0xe9>
f0104d3e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104d43:	31 d2                	xor    %edx,%edx
f0104d45:	f7 f7                	div    %edi
f0104d47:	89 c1                	mov    %eax,%ecx
f0104d49:	89 d8                	mov    %ebx,%eax
f0104d4b:	31 d2                	xor    %edx,%edx
f0104d4d:	f7 f1                	div    %ecx
f0104d4f:	89 f0                	mov    %esi,%eax
f0104d51:	f7 f1                	div    %ecx
f0104d53:	e9 31 ff ff ff       	jmp    f0104c89 <__umoddi3+0x29>
f0104d58:	90                   	nop
f0104d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104d60:	39 dd                	cmp    %ebx,%ebp
f0104d62:	72 08                	jb     f0104d6c <__umoddi3+0x10c>
f0104d64:	39 f7                	cmp    %esi,%edi
f0104d66:	0f 87 21 ff ff ff    	ja     f0104c8d <__umoddi3+0x2d>
f0104d6c:	89 da                	mov    %ebx,%edx
f0104d6e:	89 f0                	mov    %esi,%eax
f0104d70:	29 f8                	sub    %edi,%eax
f0104d72:	19 ea                	sbb    %ebp,%edx
f0104d74:	e9 14 ff ff ff       	jmp    f0104c8d <__umoddi3+0x2d>
