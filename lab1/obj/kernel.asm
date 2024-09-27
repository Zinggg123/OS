
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	1dd000ef          	jal	ra,802009fe <memset>

    cons_init();  // init the console
    80200026:	154000ef          	jal	ra,8020017a <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	9e658593          	addi	a1,a1,-1562 # 80200a10 <etext>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	9fe50513          	addi	a0,a0,-1538 # 80200a30 <etext+0x20>
    8020003a:	03a000ef          	jal	ra,80200074 <cprintf>

    print_kerninfo();
    8020003e:	06c000ef          	jal	ra,802000aa <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	148000ef          	jal	ra,8020018a <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0f2000ef          	jal	ra,80200138 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	13a000ef          	jal	ra,80200184 <intr_enable>
    
    __asm__ volatile("ebreak");
    8020004e:	9002                	ebreak
    __asm__ volatile("mv s1,zero");
    80200050:	00000493          	li	s1,0
    __asm__ volatile("div s0,s0,s1");
    80200054:	02944433          	div	s0,s0,s1
    while (1){
    80200058:	a001                	j	80200058 <kern_init+0x4e>

000000008020005a <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    8020005a:	1141                	addi	sp,sp,-16
    8020005c:	e022                	sd	s0,0(sp)
    8020005e:	e406                	sd	ra,8(sp)
    80200060:	842e                	mv	s0,a1
    cons_putc(c);
    80200062:	11a000ef          	jal	ra,8020017c <cons_putc>
    (*cnt)++;
    80200066:	401c                	lw	a5,0(s0)
}
    80200068:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    8020006a:	2785                	addiw	a5,a5,1
    8020006c:	c01c                	sw	a5,0(s0)
}
    8020006e:	6402                	ld	s0,0(sp)
    80200070:	0141                	addi	sp,sp,16
    80200072:	8082                	ret

0000000080200074 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80200074:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200076:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    8020007a:	8e2a                	mv	t3,a0
    8020007c:	f42e                	sd	a1,40(sp)
    8020007e:	f832                	sd	a2,48(sp)
    80200080:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200082:	00000517          	auipc	a0,0x0
    80200086:	fd850513          	addi	a0,a0,-40 # 8020005a <cputch>
    8020008a:	004c                	addi	a1,sp,4
    8020008c:	869a                	mv	a3,t1
    8020008e:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    80200090:	ec06                	sd	ra,24(sp)
    80200092:	e0ba                	sd	a4,64(sp)
    80200094:	e4be                	sd	a5,72(sp)
    80200096:	e8c2                	sd	a6,80(sp)
    80200098:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    8020009a:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    8020009c:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020009e:	574000ef          	jal	ra,80200612 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    802000a2:	60e2                	ld	ra,24(sp)
    802000a4:	4512                	lw	a0,4(sp)
    802000a6:	6125                	addi	sp,sp,96
    802000a8:	8082                	ret

00000000802000aa <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000aa:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000ac:	00001517          	auipc	a0,0x1
    802000b0:	98c50513          	addi	a0,a0,-1652 # 80200a38 <etext+0x28>
void print_kerninfo(void) {
    802000b4:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000b6:	fbfff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000ba:	00000597          	auipc	a1,0x0
    802000be:	f5058593          	addi	a1,a1,-176 # 8020000a <kern_init>
    802000c2:	00001517          	auipc	a0,0x1
    802000c6:	99650513          	addi	a0,a0,-1642 # 80200a58 <etext+0x48>
    802000ca:	fabff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000ce:	00001597          	auipc	a1,0x1
    802000d2:	94258593          	addi	a1,a1,-1726 # 80200a10 <etext>
    802000d6:	00001517          	auipc	a0,0x1
    802000da:	9a250513          	addi	a0,a0,-1630 # 80200a78 <etext+0x68>
    802000de:	f97ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000e2:	00004597          	auipc	a1,0x4
    802000e6:	f2e58593          	addi	a1,a1,-210 # 80204010 <ticks>
    802000ea:	00001517          	auipc	a0,0x1
    802000ee:	9ae50513          	addi	a0,a0,-1618 # 80200a98 <etext+0x88>
    802000f2:	f83ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000f6:	00004597          	auipc	a1,0x4
    802000fa:	f3258593          	addi	a1,a1,-206 # 80204028 <end>
    802000fe:	00001517          	auipc	a0,0x1
    80200102:	9ba50513          	addi	a0,a0,-1606 # 80200ab8 <etext+0xa8>
    80200106:	f6fff0ef          	jal	ra,80200074 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    8020010a:	00004597          	auipc	a1,0x4
    8020010e:	31d58593          	addi	a1,a1,797 # 80204427 <end+0x3ff>
    80200112:	00000797          	auipc	a5,0x0
    80200116:	ef878793          	addi	a5,a5,-264 # 8020000a <kern_init>
    8020011a:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011e:	43f7d593          	srai	a1,a5,0x3f
}
    80200122:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200124:	3ff5f593          	andi	a1,a1,1023
    80200128:	95be                	add	a1,a1,a5
    8020012a:	85a9                	srai	a1,a1,0xa
    8020012c:	00001517          	auipc	a0,0x1
    80200130:	9ac50513          	addi	a0,a0,-1620 # 80200ad8 <etext+0xc8>
}
    80200134:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200136:	bf3d                	j	80200074 <cprintf>

0000000080200138 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200138:	1141                	addi	sp,sp,-16
    8020013a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    8020013c:	02000793          	li	a5,32
    80200140:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200144:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200148:	67e1                	lui	a5,0x18
    8020014a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020014e:	953e                	add	a0,a0,a5
    80200150:	05f000ef          	jal	ra,802009ae <sbi_set_timer>
}
    80200154:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200156:	00004797          	auipc	a5,0x4
    8020015a:	ea07bd23          	sd	zero,-326(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    8020015e:	00001517          	auipc	a0,0x1
    80200162:	9aa50513          	addi	a0,a0,-1622 # 80200b08 <etext+0xf8>
}
    80200166:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200168:	b731                	j	80200074 <cprintf>

000000008020016a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020016a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020016e:	67e1                	lui	a5,0x18
    80200170:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200174:	953e                	add	a0,a0,a5
    80200176:	0390006f          	j	802009ae <sbi_set_timer>

000000008020017a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    8020017a:	8082                	ret

000000008020017c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020017c:	0ff57513          	zext.b	a0,a0
    80200180:	0150006f          	j	80200994 <sbi_console_putchar>

0000000080200184 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200184:	100167f3          	csrrsi	a5,sstatus,2
    80200188:	8082                	ret

000000008020018a <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    8020018a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020018e:	00000797          	auipc	a5,0x0
    80200192:	36278793          	addi	a5,a5,866 # 802004f0 <__alltraps>
    80200196:	10579073          	csrw	stvec,a5
}
    8020019a:	8082                	ret

000000008020019c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020019e:	1141                	addi	sp,sp,-16
    802001a0:	e022                	sd	s0,0(sp)
    802001a2:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a4:	00001517          	auipc	a0,0x1
    802001a8:	98450513          	addi	a0,a0,-1660 # 80200b28 <etext+0x118>
void print_regs(struct pushregs *gpr) {
    802001ac:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001ae:	ec7ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001b2:	640c                	ld	a1,8(s0)
    802001b4:	00001517          	auipc	a0,0x1
    802001b8:	98c50513          	addi	a0,a0,-1652 # 80200b40 <etext+0x130>
    802001bc:	eb9ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001c0:	680c                	ld	a1,16(s0)
    802001c2:	00001517          	auipc	a0,0x1
    802001c6:	99650513          	addi	a0,a0,-1642 # 80200b58 <etext+0x148>
    802001ca:	eabff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001ce:	6c0c                	ld	a1,24(s0)
    802001d0:	00001517          	auipc	a0,0x1
    802001d4:	9a050513          	addi	a0,a0,-1632 # 80200b70 <etext+0x160>
    802001d8:	e9dff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001dc:	700c                	ld	a1,32(s0)
    802001de:	00001517          	auipc	a0,0x1
    802001e2:	9aa50513          	addi	a0,a0,-1622 # 80200b88 <etext+0x178>
    802001e6:	e8fff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001ea:	740c                	ld	a1,40(s0)
    802001ec:	00001517          	auipc	a0,0x1
    802001f0:	9b450513          	addi	a0,a0,-1612 # 80200ba0 <etext+0x190>
    802001f4:	e81ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f8:	780c                	ld	a1,48(s0)
    802001fa:	00001517          	auipc	a0,0x1
    802001fe:	9be50513          	addi	a0,a0,-1602 # 80200bb8 <etext+0x1a8>
    80200202:	e73ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200206:	7c0c                	ld	a1,56(s0)
    80200208:	00001517          	auipc	a0,0x1
    8020020c:	9c850513          	addi	a0,a0,-1592 # 80200bd0 <etext+0x1c0>
    80200210:	e65ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200214:	602c                	ld	a1,64(s0)
    80200216:	00001517          	auipc	a0,0x1
    8020021a:	9d250513          	addi	a0,a0,-1582 # 80200be8 <etext+0x1d8>
    8020021e:	e57ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200222:	642c                	ld	a1,72(s0)
    80200224:	00001517          	auipc	a0,0x1
    80200228:	9dc50513          	addi	a0,a0,-1572 # 80200c00 <etext+0x1f0>
    8020022c:	e49ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200230:	682c                	ld	a1,80(s0)
    80200232:	00001517          	auipc	a0,0x1
    80200236:	9e650513          	addi	a0,a0,-1562 # 80200c18 <etext+0x208>
    8020023a:	e3bff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020023e:	6c2c                	ld	a1,88(s0)
    80200240:	00001517          	auipc	a0,0x1
    80200244:	9f050513          	addi	a0,a0,-1552 # 80200c30 <etext+0x220>
    80200248:	e2dff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020024c:	702c                	ld	a1,96(s0)
    8020024e:	00001517          	auipc	a0,0x1
    80200252:	9fa50513          	addi	a0,a0,-1542 # 80200c48 <etext+0x238>
    80200256:	e1fff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020025a:	742c                	ld	a1,104(s0)
    8020025c:	00001517          	auipc	a0,0x1
    80200260:	a0450513          	addi	a0,a0,-1532 # 80200c60 <etext+0x250>
    80200264:	e11ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200268:	782c                	ld	a1,112(s0)
    8020026a:	00001517          	auipc	a0,0x1
    8020026e:	a0e50513          	addi	a0,a0,-1522 # 80200c78 <etext+0x268>
    80200272:	e03ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200276:	7c2c                	ld	a1,120(s0)
    80200278:	00001517          	auipc	a0,0x1
    8020027c:	a1850513          	addi	a0,a0,-1512 # 80200c90 <etext+0x280>
    80200280:	df5ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200284:	604c                	ld	a1,128(s0)
    80200286:	00001517          	auipc	a0,0x1
    8020028a:	a2250513          	addi	a0,a0,-1502 # 80200ca8 <etext+0x298>
    8020028e:	de7ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200292:	644c                	ld	a1,136(s0)
    80200294:	00001517          	auipc	a0,0x1
    80200298:	a2c50513          	addi	a0,a0,-1492 # 80200cc0 <etext+0x2b0>
    8020029c:	dd9ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    802002a0:	684c                	ld	a1,144(s0)
    802002a2:	00001517          	auipc	a0,0x1
    802002a6:	a3650513          	addi	a0,a0,-1482 # 80200cd8 <etext+0x2c8>
    802002aa:	dcbff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002ae:	6c4c                	ld	a1,152(s0)
    802002b0:	00001517          	auipc	a0,0x1
    802002b4:	a4050513          	addi	a0,a0,-1472 # 80200cf0 <etext+0x2e0>
    802002b8:	dbdff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002bc:	704c                	ld	a1,160(s0)
    802002be:	00001517          	auipc	a0,0x1
    802002c2:	a4a50513          	addi	a0,a0,-1462 # 80200d08 <etext+0x2f8>
    802002c6:	dafff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002ca:	744c                	ld	a1,168(s0)
    802002cc:	00001517          	auipc	a0,0x1
    802002d0:	a5450513          	addi	a0,a0,-1452 # 80200d20 <etext+0x310>
    802002d4:	da1ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d8:	784c                	ld	a1,176(s0)
    802002da:	00001517          	auipc	a0,0x1
    802002de:	a5e50513          	addi	a0,a0,-1442 # 80200d38 <etext+0x328>
    802002e2:	d93ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e6:	7c4c                	ld	a1,184(s0)
    802002e8:	00001517          	auipc	a0,0x1
    802002ec:	a6850513          	addi	a0,a0,-1432 # 80200d50 <etext+0x340>
    802002f0:	d85ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002f4:	606c                	ld	a1,192(s0)
    802002f6:	00001517          	auipc	a0,0x1
    802002fa:	a7250513          	addi	a0,a0,-1422 # 80200d68 <etext+0x358>
    802002fe:	d77ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    80200302:	646c                	ld	a1,200(s0)
    80200304:	00001517          	auipc	a0,0x1
    80200308:	a7c50513          	addi	a0,a0,-1412 # 80200d80 <etext+0x370>
    8020030c:	d69ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200310:	686c                	ld	a1,208(s0)
    80200312:	00001517          	auipc	a0,0x1
    80200316:	a8650513          	addi	a0,a0,-1402 # 80200d98 <etext+0x388>
    8020031a:	d5bff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020031e:	6c6c                	ld	a1,216(s0)
    80200320:	00001517          	auipc	a0,0x1
    80200324:	a9050513          	addi	a0,a0,-1392 # 80200db0 <etext+0x3a0>
    80200328:	d4dff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020032c:	706c                	ld	a1,224(s0)
    8020032e:	00001517          	auipc	a0,0x1
    80200332:	a9a50513          	addi	a0,a0,-1382 # 80200dc8 <etext+0x3b8>
    80200336:	d3fff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020033a:	746c                	ld	a1,232(s0)
    8020033c:	00001517          	auipc	a0,0x1
    80200340:	aa450513          	addi	a0,a0,-1372 # 80200de0 <etext+0x3d0>
    80200344:	d31ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200348:	786c                	ld	a1,240(s0)
    8020034a:	00001517          	auipc	a0,0x1
    8020034e:	aae50513          	addi	a0,a0,-1362 # 80200df8 <etext+0x3e8>
    80200352:	d23ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	7c6c                	ld	a1,248(s0)
}
    80200358:	6402                	ld	s0,0(sp)
    8020035a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035c:	00001517          	auipc	a0,0x1
    80200360:	ab450513          	addi	a0,a0,-1356 # 80200e10 <etext+0x400>
}
    80200364:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200366:	b339                	j	80200074 <cprintf>

0000000080200368 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200368:	1141                	addi	sp,sp,-16
    8020036a:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020036c:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036e:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200370:	00001517          	auipc	a0,0x1
    80200374:	ab850513          	addi	a0,a0,-1352 # 80200e28 <etext+0x418>
void print_trapframe(struct trapframe *tf) {
    80200378:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020037a:	cfbff0ef          	jal	ra,80200074 <cprintf>
    print_regs(&tf->gpr);
    8020037e:	8522                	mv	a0,s0
    80200380:	e1dff0ef          	jal	ra,8020019c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200384:	10043583          	ld	a1,256(s0)
    80200388:	00001517          	auipc	a0,0x1
    8020038c:	ab850513          	addi	a0,a0,-1352 # 80200e40 <etext+0x430>
    80200390:	ce5ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200394:	10843583          	ld	a1,264(s0)
    80200398:	00001517          	auipc	a0,0x1
    8020039c:	ac050513          	addi	a0,a0,-1344 # 80200e58 <etext+0x448>
    802003a0:	cd5ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a4:	11043583          	ld	a1,272(s0)
    802003a8:	00001517          	auipc	a0,0x1
    802003ac:	ac850513          	addi	a0,a0,-1336 # 80200e70 <etext+0x460>
    802003b0:	cc5ff0ef          	jal	ra,80200074 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b4:	11843583          	ld	a1,280(s0)
}
    802003b8:	6402                	ld	s0,0(sp)
    802003ba:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003bc:	00001517          	auipc	a0,0x1
    802003c0:	acc50513          	addi	a0,a0,-1332 # 80200e88 <etext+0x478>
}
    802003c4:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c6:	b17d                	j	80200074 <cprintf>

00000000802003c8 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c8:	11853783          	ld	a5,280(a0)
    802003cc:	472d                	li	a4,11
    802003ce:	0786                	slli	a5,a5,0x1
    802003d0:	8385                	srli	a5,a5,0x1
    802003d2:	08f76163          	bltu	a4,a5,80200454 <interrupt_handler+0x8c>
    802003d6:	00001717          	auipc	a4,0x1
    802003da:	b7a70713          	addi	a4,a4,-1158 # 80200f50 <etext+0x540>
    802003de:	078a                	slli	a5,a5,0x2
    802003e0:	97ba                	add	a5,a5,a4
    802003e2:	439c                	lw	a5,0(a5)
    802003e4:	97ba                	add	a5,a5,a4
    802003e6:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	b1850513          	addi	a0,a0,-1256 # 80200f00 <etext+0x4f0>
    802003f0:	b151                	j	80200074 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003f2:	00001517          	auipc	a0,0x1
    802003f6:	aee50513          	addi	a0,a0,-1298 # 80200ee0 <etext+0x4d0>
    802003fa:	b9ad                	j	80200074 <cprintf>
            cprintf("User software interrupt\n");
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	aa450513          	addi	a0,a0,-1372 # 80200ea0 <etext+0x490>
    80200404:	b985                	j	80200074 <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200406:	00001517          	auipc	a0,0x1
    8020040a:	aba50513          	addi	a0,a0,-1350 # 80200ec0 <etext+0x4b0>
    8020040e:	b19d                	j	80200074 <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200410:	1141                	addi	sp,sp,-16
    80200412:	e022                	sd	s0,0(sp)
    80200414:	e406                	sd	ra,8(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
    80200416:	d55ff0ef          	jal	ra,8020016a <clock_set_next_event>
            ticks += 1;
    8020041a:	00004797          	auipc	a5,0x4
    8020041e:	bf678793          	addi	a5,a5,-1034 # 80204010 <ticks>
    80200422:	6398                	ld	a4,0(a5)
            if(ticks == TICK_NUM){
    80200424:	06400693          	li	a3,100
    80200428:	00004417          	auipc	s0,0x4
    8020042c:	bf040413          	addi	s0,s0,-1040 # 80204018 <num>
            ticks += 1;
    80200430:	0705                	addi	a4,a4,1
    80200432:	e398                	sd	a4,0(a5)
            if(ticks == TICK_NUM){
    80200434:	639c                	ld	a5,0(a5)
    80200436:	02d78063          	beq	a5,a3,80200456 <interrupt_handler+0x8e>
            	print_ticks();
            	num+=1;
            	ticks = 0;
            }
            if(num==10){
    8020043a:	6018                	ld	a4,0(s0)
    8020043c:	47a9                	li	a5,10
    8020043e:	02f70c63          	beq	a4,a5,80200476 <interrupt_handler+0xae>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200442:	60a2                	ld	ra,8(sp)
    80200444:	6402                	ld	s0,0(sp)
    80200446:	0141                	addi	sp,sp,16
    80200448:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    8020044a:	00001517          	auipc	a0,0x1
    8020044e:	ae650513          	addi	a0,a0,-1306 # 80200f30 <etext+0x520>
    80200452:	b10d                	j	80200074 <cprintf>
            print_trapframe(tf);
    80200454:	bf11                	j	80200368 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200456:	06400593          	li	a1,100
    8020045a:	00001517          	auipc	a0,0x1
    8020045e:	ac650513          	addi	a0,a0,-1338 # 80200f20 <etext+0x510>
    80200462:	c13ff0ef          	jal	ra,80200074 <cprintf>
            	num+=1;
    80200466:	601c                	ld	a5,0(s0)
    80200468:	0785                	addi	a5,a5,1
    8020046a:	e01c                	sd	a5,0(s0)
            	ticks = 0;
    8020046c:	00004797          	auipc	a5,0x4
    80200470:	ba07b223          	sd	zero,-1116(a5) # 80204010 <ticks>
    80200474:	b7d9                	j	8020043a <interrupt_handler+0x72>
}
    80200476:	6402                	ld	s0,0(sp)
    80200478:	60a2                	ld	ra,8(sp)
    8020047a:	0141                	addi	sp,sp,16
            	sbi_shutdown();  //guanjihanshu ?
    8020047c:	a3b1                	j	802009c8 <sbi_shutdown>

000000008020047e <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020047e:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    80200482:	1141                	addi	sp,sp,-16
    80200484:	e022                	sd	s0,0(sp)
    80200486:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
    80200488:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    8020048a:	842a                	mv	s0,a0
    switch (tf->cause) {
    8020048c:	04e78663          	beq	a5,a4,802004d8 <exception_handler+0x5a>
    80200490:	02f76c63          	bltu	a4,a5,802004c8 <exception_handler+0x4a>
    80200494:	4709                	li	a4,2
             /* LAB1 CHALLENGE3   YOUR CODE :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception Type: Illegal instruction\n"); //(1)
    80200496:	00001517          	auipc	a0,0x1
    8020049a:	aea50513          	addi	a0,a0,-1302 # 80200f80 <etext+0x570>
    switch (tf->cause) {
    8020049e:	02e79163          	bne	a5,a4,802004c0 <exception_handler+0x42>
            /* LAB1 CHALLLENGE3   YOUR CODE :  */
            /*(1)输出指令异常类型（ breakpoint）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception Type: Breakpoint\n"); //(1)
    802004a2:	bd3ff0ef          	jal	ra,80200074 <cprintf>
            cprintf("  epc      0x%08x\n", tf->epc);
    802004a6:	10843583          	ld	a1,264(s0)
    802004aa:	00001517          	auipc	a0,0x1
    802004ae:	9ae50513          	addi	a0,a0,-1618 # 80200e58 <etext+0x448>
    802004b2:	bc3ff0ef          	jal	ra,80200074 <cprintf>
            tf->epc += 4;
    802004b6:	10843783          	ld	a5,264(s0)
    802004ba:	0791                	addi	a5,a5,4
    802004bc:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004c0:	60a2                	ld	ra,8(sp)
    802004c2:	6402                	ld	s0,0(sp)
    802004c4:	0141                	addi	sp,sp,16
    802004c6:	8082                	ret
    switch (tf->cause) {
    802004c8:	17f1                	addi	a5,a5,-4
    802004ca:	471d                	li	a4,7
    802004cc:	fef77ae3          	bgeu	a4,a5,802004c0 <exception_handler+0x42>
}
    802004d0:	6402                	ld	s0,0(sp)
    802004d2:	60a2                	ld	ra,8(sp)
    802004d4:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004d6:	bd49                	j	80200368 <print_trapframe>
            cprintf("Exception Type: Breakpoint\n"); //(1)
    802004d8:	00001517          	auipc	a0,0x1
    802004dc:	ad050513          	addi	a0,a0,-1328 # 80200fa8 <etext+0x598>
    802004e0:	b7c9                	j	802004a2 <exception_handler+0x24>

00000000802004e2 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004e2:	11853783          	ld	a5,280(a0)
    802004e6:	0007c363          	bltz	a5,802004ec <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802004ea:	bf51                	j	8020047e <exception_handler>
        interrupt_handler(tf);
    802004ec:	bdf1                	j	802003c8 <interrupt_handler>
	...

00000000802004f0 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    802004f0:	14011073          	csrw	sscratch,sp
    802004f4:	712d                	addi	sp,sp,-288
    802004f6:	e002                	sd	zero,0(sp)
    802004f8:	e406                	sd	ra,8(sp)
    802004fa:	ec0e                	sd	gp,24(sp)
    802004fc:	f012                	sd	tp,32(sp)
    802004fe:	f416                	sd	t0,40(sp)
    80200500:	f81a                	sd	t1,48(sp)
    80200502:	fc1e                	sd	t2,56(sp)
    80200504:	e0a2                	sd	s0,64(sp)
    80200506:	e4a6                	sd	s1,72(sp)
    80200508:	e8aa                	sd	a0,80(sp)
    8020050a:	ecae                	sd	a1,88(sp)
    8020050c:	f0b2                	sd	a2,96(sp)
    8020050e:	f4b6                	sd	a3,104(sp)
    80200510:	f8ba                	sd	a4,112(sp)
    80200512:	fcbe                	sd	a5,120(sp)
    80200514:	e142                	sd	a6,128(sp)
    80200516:	e546                	sd	a7,136(sp)
    80200518:	e94a                	sd	s2,144(sp)
    8020051a:	ed4e                	sd	s3,152(sp)
    8020051c:	f152                	sd	s4,160(sp)
    8020051e:	f556                	sd	s5,168(sp)
    80200520:	f95a                	sd	s6,176(sp)
    80200522:	fd5e                	sd	s7,184(sp)
    80200524:	e1e2                	sd	s8,192(sp)
    80200526:	e5e6                	sd	s9,200(sp)
    80200528:	e9ea                	sd	s10,208(sp)
    8020052a:	edee                	sd	s11,216(sp)
    8020052c:	f1f2                	sd	t3,224(sp)
    8020052e:	f5f6                	sd	t4,232(sp)
    80200530:	f9fa                	sd	t5,240(sp)
    80200532:	fdfe                	sd	t6,248(sp)
    80200534:	14001473          	csrrw	s0,sscratch,zero
    80200538:	100024f3          	csrr	s1,sstatus
    8020053c:	14102973          	csrr	s2,sepc
    80200540:	143029f3          	csrr	s3,stval
    80200544:	14202a73          	csrr	s4,scause
    80200548:	e822                	sd	s0,16(sp)
    8020054a:	e226                	sd	s1,256(sp)
    8020054c:	e64a                	sd	s2,264(sp)
    8020054e:	ea4e                	sd	s3,272(sp)
    80200550:	ee52                	sd	s4,280(sp)

    move  a0, sp
    80200552:	850a                	mv	a0,sp
    jal trap
    80200554:	f8fff0ef          	jal	ra,802004e2 <trap>

0000000080200558 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200558:	6492                	ld	s1,256(sp)
    8020055a:	6932                	ld	s2,264(sp)
    8020055c:	10049073          	csrw	sstatus,s1
    80200560:	14191073          	csrw	sepc,s2
    80200564:	60a2                	ld	ra,8(sp)
    80200566:	61e2                	ld	gp,24(sp)
    80200568:	7202                	ld	tp,32(sp)
    8020056a:	72a2                	ld	t0,40(sp)
    8020056c:	7342                	ld	t1,48(sp)
    8020056e:	73e2                	ld	t2,56(sp)
    80200570:	6406                	ld	s0,64(sp)
    80200572:	64a6                	ld	s1,72(sp)
    80200574:	6546                	ld	a0,80(sp)
    80200576:	65e6                	ld	a1,88(sp)
    80200578:	7606                	ld	a2,96(sp)
    8020057a:	76a6                	ld	a3,104(sp)
    8020057c:	7746                	ld	a4,112(sp)
    8020057e:	77e6                	ld	a5,120(sp)
    80200580:	680a                	ld	a6,128(sp)
    80200582:	68aa                	ld	a7,136(sp)
    80200584:	694a                	ld	s2,144(sp)
    80200586:	69ea                	ld	s3,152(sp)
    80200588:	7a0a                	ld	s4,160(sp)
    8020058a:	7aaa                	ld	s5,168(sp)
    8020058c:	7b4a                	ld	s6,176(sp)
    8020058e:	7bea                	ld	s7,184(sp)
    80200590:	6c0e                	ld	s8,192(sp)
    80200592:	6cae                	ld	s9,200(sp)
    80200594:	6d4e                	ld	s10,208(sp)
    80200596:	6dee                	ld	s11,216(sp)
    80200598:	7e0e                	ld	t3,224(sp)
    8020059a:	7eae                	ld	t4,232(sp)
    8020059c:	7f4e                	ld	t5,240(sp)
    8020059e:	7fee                	ld	t6,248(sp)
    802005a0:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005a2:	10200073          	sret

00000000802005a6 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005a6:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005aa:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005ac:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005b0:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005b2:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005b6:	f022                	sd	s0,32(sp)
    802005b8:	ec26                	sd	s1,24(sp)
    802005ba:	e84a                	sd	s2,16(sp)
    802005bc:	f406                	sd	ra,40(sp)
    802005be:	e44e                	sd	s3,8(sp)
    802005c0:	84aa                	mv	s1,a0
    802005c2:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005c4:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005c8:	2a01                	sext.w	s4,s4
    if (num >= base) {
    802005ca:	03067e63          	bgeu	a2,a6,80200606 <printnum+0x60>
    802005ce:	89be                	mv	s3,a5
        while (-- width > 0)
    802005d0:	00805763          	blez	s0,802005de <printnum+0x38>
    802005d4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802005d6:	85ca                	mv	a1,s2
    802005d8:	854e                	mv	a0,s3
    802005da:	9482                	jalr	s1
        while (-- width > 0)
    802005dc:	fc65                	bnez	s0,802005d4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802005de:	1a02                	slli	s4,s4,0x20
    802005e0:	00001797          	auipc	a5,0x1
    802005e4:	9e878793          	addi	a5,a5,-1560 # 80200fc8 <etext+0x5b8>
    802005e8:	020a5a13          	srli	s4,s4,0x20
    802005ec:	9a3e                	add	s4,s4,a5
}
    802005ee:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005f0:	000a4503          	lbu	a0,0(s4)
}
    802005f4:	70a2                	ld	ra,40(sp)
    802005f6:	69a2                	ld	s3,8(sp)
    802005f8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005fa:	85ca                	mv	a1,s2
    802005fc:	87a6                	mv	a5,s1
}
    802005fe:	6942                	ld	s2,16(sp)
    80200600:	64e2                	ld	s1,24(sp)
    80200602:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200604:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    80200606:	03065633          	divu	a2,a2,a6
    8020060a:	8722                	mv	a4,s0
    8020060c:	f9bff0ef          	jal	ra,802005a6 <printnum>
    80200610:	b7f9                	j	802005de <printnum+0x38>

0000000080200612 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200612:	7119                	addi	sp,sp,-128
    80200614:	f4a6                	sd	s1,104(sp)
    80200616:	f0ca                	sd	s2,96(sp)
    80200618:	ecce                	sd	s3,88(sp)
    8020061a:	e8d2                	sd	s4,80(sp)
    8020061c:	e4d6                	sd	s5,72(sp)
    8020061e:	e0da                	sd	s6,64(sp)
    80200620:	fc5e                	sd	s7,56(sp)
    80200622:	f06a                	sd	s10,32(sp)
    80200624:	fc86                	sd	ra,120(sp)
    80200626:	f8a2                	sd	s0,112(sp)
    80200628:	f862                	sd	s8,48(sp)
    8020062a:	f466                	sd	s9,40(sp)
    8020062c:	ec6e                	sd	s11,24(sp)
    8020062e:	892a                	mv	s2,a0
    80200630:	84ae                	mv	s1,a1
    80200632:	8d32                	mv	s10,a2
    80200634:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200636:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020063a:	5b7d                	li	s6,-1
    8020063c:	00001a97          	auipc	s5,0x1
    80200640:	9c0a8a93          	addi	s5,s5,-1600 # 80200ffc <etext+0x5ec>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200644:	00001b97          	auipc	s7,0x1
    80200648:	b94b8b93          	addi	s7,s7,-1132 # 802011d8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020064c:	000d4503          	lbu	a0,0(s10)
    80200650:	001d0413          	addi	s0,s10,1
    80200654:	01350a63          	beq	a0,s3,80200668 <vprintfmt+0x56>
            if (ch == '\0') {
    80200658:	c121                	beqz	a0,80200698 <vprintfmt+0x86>
            putch(ch, putdat);
    8020065a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020065c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    8020065e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200660:	fff44503          	lbu	a0,-1(s0)
    80200664:	ff351ae3          	bne	a0,s3,80200658 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    80200668:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    8020066c:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200670:	4c81                	li	s9,0
    80200672:	4881                	li	a7,0
        width = precision = -1;
    80200674:	5c7d                	li	s8,-1
    80200676:	5dfd                	li	s11,-1
    80200678:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    8020067c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    8020067e:	fdd6059b          	addiw	a1,a2,-35
    80200682:	0ff5f593          	zext.b	a1,a1
    80200686:	00140d13          	addi	s10,s0,1
    8020068a:	04b56263          	bltu	a0,a1,802006ce <vprintfmt+0xbc>
    8020068e:	058a                	slli	a1,a1,0x2
    80200690:	95d6                	add	a1,a1,s5
    80200692:	4194                	lw	a3,0(a1)
    80200694:	96d6                	add	a3,a3,s5
    80200696:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200698:	70e6                	ld	ra,120(sp)
    8020069a:	7446                	ld	s0,112(sp)
    8020069c:	74a6                	ld	s1,104(sp)
    8020069e:	7906                	ld	s2,96(sp)
    802006a0:	69e6                	ld	s3,88(sp)
    802006a2:	6a46                	ld	s4,80(sp)
    802006a4:	6aa6                	ld	s5,72(sp)
    802006a6:	6b06                	ld	s6,64(sp)
    802006a8:	7be2                	ld	s7,56(sp)
    802006aa:	7c42                	ld	s8,48(sp)
    802006ac:	7ca2                	ld	s9,40(sp)
    802006ae:	7d02                	ld	s10,32(sp)
    802006b0:	6de2                	ld	s11,24(sp)
    802006b2:	6109                	addi	sp,sp,128
    802006b4:	8082                	ret
            padc = '0';
    802006b6:	87b2                	mv	a5,a2
            goto reswitch;
    802006b8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802006bc:	846a                	mv	s0,s10
    802006be:	00140d13          	addi	s10,s0,1
    802006c2:	fdd6059b          	addiw	a1,a2,-35
    802006c6:	0ff5f593          	zext.b	a1,a1
    802006ca:	fcb572e3          	bgeu	a0,a1,8020068e <vprintfmt+0x7c>
            putch('%', putdat);
    802006ce:	85a6                	mv	a1,s1
    802006d0:	02500513          	li	a0,37
    802006d4:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802006d6:	fff44783          	lbu	a5,-1(s0)
    802006da:	8d22                	mv	s10,s0
    802006dc:	f73788e3          	beq	a5,s3,8020064c <vprintfmt+0x3a>
    802006e0:	ffed4783          	lbu	a5,-2(s10)
    802006e4:	1d7d                	addi	s10,s10,-1
    802006e6:	ff379de3          	bne	a5,s3,802006e0 <vprintfmt+0xce>
    802006ea:	b78d                	j	8020064c <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    802006ec:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    802006f0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802006f4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802006f6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802006fa:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    802006fe:	02d86463          	bltu	a6,a3,80200726 <vprintfmt+0x114>
                ch = *fmt;
    80200702:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    80200706:	002c169b          	slliw	a3,s8,0x2
    8020070a:	0186873b          	addw	a4,a3,s8
    8020070e:	0017171b          	slliw	a4,a4,0x1
    80200712:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    80200714:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    80200718:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020071a:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    8020071e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200722:	fed870e3          	bgeu	a6,a3,80200702 <vprintfmt+0xf0>
            if (width < 0)
    80200726:	f40ddce3          	bgez	s11,8020067e <vprintfmt+0x6c>
                width = precision, precision = -1;
    8020072a:	8de2                	mv	s11,s8
    8020072c:	5c7d                	li	s8,-1
    8020072e:	bf81                	j	8020067e <vprintfmt+0x6c>
            if (width < 0)
    80200730:	fffdc693          	not	a3,s11
    80200734:	96fd                	srai	a3,a3,0x3f
    80200736:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    8020073a:	00144603          	lbu	a2,1(s0)
    8020073e:	2d81                	sext.w	s11,s11
    80200740:	846a                	mv	s0,s10
            goto reswitch;
    80200742:	bf35                	j	8020067e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    80200744:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    80200748:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    8020074c:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020074e:	846a                	mv	s0,s10
            goto process_precision;
    80200750:	bfd9                	j	80200726 <vprintfmt+0x114>
    if (lflag >= 2) {
    80200752:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200754:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200758:	01174463          	blt	a4,a7,80200760 <vprintfmt+0x14e>
    else if (lflag) {
    8020075c:	1a088e63          	beqz	a7,80200918 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    80200760:	000a3603          	ld	a2,0(s4)
    80200764:	46c1                	li	a3,16
    80200766:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    80200768:	2781                	sext.w	a5,a5
    8020076a:	876e                	mv	a4,s11
    8020076c:	85a6                	mv	a1,s1
    8020076e:	854a                	mv	a0,s2
    80200770:	e37ff0ef          	jal	ra,802005a6 <printnum>
            break;
    80200774:	bde1                	j	8020064c <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    80200776:	000a2503          	lw	a0,0(s4)
    8020077a:	85a6                	mv	a1,s1
    8020077c:	0a21                	addi	s4,s4,8
    8020077e:	9902                	jalr	s2
            break;
    80200780:	b5f1                	j	8020064c <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200782:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200784:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200788:	01174463          	blt	a4,a7,80200790 <vprintfmt+0x17e>
    else if (lflag) {
    8020078c:	18088163          	beqz	a7,8020090e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    80200790:	000a3603          	ld	a2,0(s4)
    80200794:	46a9                	li	a3,10
    80200796:	8a2e                	mv	s4,a1
    80200798:	bfc1                	j	80200768 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    8020079a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    8020079e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007a0:	846a                	mv	s0,s10
            goto reswitch;
    802007a2:	bdf1                	j	8020067e <vprintfmt+0x6c>
            putch(ch, putdat);
    802007a4:	85a6                	mv	a1,s1
    802007a6:	02500513          	li	a0,37
    802007aa:	9902                	jalr	s2
            break;
    802007ac:	b545                	j	8020064c <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    802007ae:	00144603          	lbu	a2,1(s0)
            lflag ++;
    802007b2:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007b4:	846a                	mv	s0,s10
            goto reswitch;
    802007b6:	b5e1                	j	8020067e <vprintfmt+0x6c>
    if (lflag >= 2) {
    802007b8:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007ba:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802007be:	01174463          	blt	a4,a7,802007c6 <vprintfmt+0x1b4>
    else if (lflag) {
    802007c2:	14088163          	beqz	a7,80200904 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    802007c6:	000a3603          	ld	a2,0(s4)
    802007ca:	46a1                	li	a3,8
    802007cc:	8a2e                	mv	s4,a1
    802007ce:	bf69                	j	80200768 <vprintfmt+0x156>
            putch('0', putdat);
    802007d0:	03000513          	li	a0,48
    802007d4:	85a6                	mv	a1,s1
    802007d6:	e03e                	sd	a5,0(sp)
    802007d8:	9902                	jalr	s2
            putch('x', putdat);
    802007da:	85a6                	mv	a1,s1
    802007dc:	07800513          	li	a0,120
    802007e0:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007e2:	0a21                	addi	s4,s4,8
            goto number;
    802007e4:	6782                	ld	a5,0(sp)
    802007e6:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    802007e8:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    802007ec:	bfb5                	j	80200768 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007ee:	000a3403          	ld	s0,0(s4)
    802007f2:	008a0713          	addi	a4,s4,8
    802007f6:	e03a                	sd	a4,0(sp)
    802007f8:	14040263          	beqz	s0,8020093c <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    802007fc:	0fb05763          	blez	s11,802008ea <vprintfmt+0x2d8>
    80200800:	02d00693          	li	a3,45
    80200804:	0cd79163          	bne	a5,a3,802008c6 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200808:	00044783          	lbu	a5,0(s0)
    8020080c:	0007851b          	sext.w	a0,a5
    80200810:	cf85                	beqz	a5,80200848 <vprintfmt+0x236>
    80200812:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200816:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020081a:	000c4563          	bltz	s8,80200824 <vprintfmt+0x212>
    8020081e:	3c7d                	addiw	s8,s8,-1
    80200820:	036c0263          	beq	s8,s6,80200844 <vprintfmt+0x232>
                    putch('?', putdat);
    80200824:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200826:	0e0c8e63          	beqz	s9,80200922 <vprintfmt+0x310>
    8020082a:	3781                	addiw	a5,a5,-32
    8020082c:	0ef47b63          	bgeu	s0,a5,80200922 <vprintfmt+0x310>
                    putch('?', putdat);
    80200830:	03f00513          	li	a0,63
    80200834:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200836:	000a4783          	lbu	a5,0(s4)
    8020083a:	3dfd                	addiw	s11,s11,-1
    8020083c:	0a05                	addi	s4,s4,1
    8020083e:	0007851b          	sext.w	a0,a5
    80200842:	ffe1                	bnez	a5,8020081a <vprintfmt+0x208>
            for (; width > 0; width --) {
    80200844:	01b05963          	blez	s11,80200856 <vprintfmt+0x244>
    80200848:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020084a:	85a6                	mv	a1,s1
    8020084c:	02000513          	li	a0,32
    80200850:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200852:	fe0d9be3          	bnez	s11,80200848 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200856:	6a02                	ld	s4,0(sp)
    80200858:	bbd5                	j	8020064c <vprintfmt+0x3a>
    if (lflag >= 2) {
    8020085a:	4705                	li	a4,1
            precision = va_arg(ap, int);
    8020085c:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    80200860:	01174463          	blt	a4,a7,80200868 <vprintfmt+0x256>
    else if (lflag) {
    80200864:	08088d63          	beqz	a7,802008fe <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    80200868:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    8020086c:	0a044d63          	bltz	s0,80200926 <vprintfmt+0x314>
            num = getint(&ap, lflag);
    80200870:	8622                	mv	a2,s0
    80200872:	8a66                	mv	s4,s9
    80200874:	46a9                	li	a3,10
    80200876:	bdcd                	j	80200768 <vprintfmt+0x156>
            err = va_arg(ap, int);
    80200878:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020087c:	4719                	li	a4,6
            err = va_arg(ap, int);
    8020087e:	0a21                	addi	s4,s4,8
            if (err < 0) {
    80200880:	41f7d69b          	sraiw	a3,a5,0x1f
    80200884:	8fb5                	xor	a5,a5,a3
    80200886:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020088a:	02d74163          	blt	a4,a3,802008ac <vprintfmt+0x29a>
    8020088e:	00369793          	slli	a5,a3,0x3
    80200892:	97de                	add	a5,a5,s7
    80200894:	639c                	ld	a5,0(a5)
    80200896:	cb99                	beqz	a5,802008ac <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    80200898:	86be                	mv	a3,a5
    8020089a:	00000617          	auipc	a2,0x0
    8020089e:	75e60613          	addi	a2,a2,1886 # 80200ff8 <etext+0x5e8>
    802008a2:	85a6                	mv	a1,s1
    802008a4:	854a                	mv	a0,s2
    802008a6:	0ce000ef          	jal	ra,80200974 <printfmt>
    802008aa:	b34d                	j	8020064c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802008ac:	00000617          	auipc	a2,0x0
    802008b0:	73c60613          	addi	a2,a2,1852 # 80200fe8 <etext+0x5d8>
    802008b4:	85a6                	mv	a1,s1
    802008b6:	854a                	mv	a0,s2
    802008b8:	0bc000ef          	jal	ra,80200974 <printfmt>
    802008bc:	bb41                	j	8020064c <vprintfmt+0x3a>
                p = "(null)";
    802008be:	00000417          	auipc	s0,0x0
    802008c2:	72240413          	addi	s0,s0,1826 # 80200fe0 <etext+0x5d0>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008c6:	85e2                	mv	a1,s8
    802008c8:	8522                	mv	a0,s0
    802008ca:	e43e                	sd	a5,8(sp)
    802008cc:	116000ef          	jal	ra,802009e2 <strnlen>
    802008d0:	40ad8dbb          	subw	s11,s11,a0
    802008d4:	01b05b63          	blez	s11,802008ea <vprintfmt+0x2d8>
                    putch(padc, putdat);
    802008d8:	67a2                	ld	a5,8(sp)
    802008da:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008de:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    802008e0:	85a6                	mv	a1,s1
    802008e2:	8552                	mv	a0,s4
    802008e4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008e6:	fe0d9ce3          	bnez	s11,802008de <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008ea:	00044783          	lbu	a5,0(s0)
    802008ee:	00140a13          	addi	s4,s0,1
    802008f2:	0007851b          	sext.w	a0,a5
    802008f6:	d3a5                	beqz	a5,80200856 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    802008f8:	05e00413          	li	s0,94
    802008fc:	bf39                	j	8020081a <vprintfmt+0x208>
        return va_arg(*ap, int);
    802008fe:	000a2403          	lw	s0,0(s4)
    80200902:	b7ad                	j	8020086c <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    80200904:	000a6603          	lwu	a2,0(s4)
    80200908:	46a1                	li	a3,8
    8020090a:	8a2e                	mv	s4,a1
    8020090c:	bdb1                	j	80200768 <vprintfmt+0x156>
    8020090e:	000a6603          	lwu	a2,0(s4)
    80200912:	46a9                	li	a3,10
    80200914:	8a2e                	mv	s4,a1
    80200916:	bd89                	j	80200768 <vprintfmt+0x156>
    80200918:	000a6603          	lwu	a2,0(s4)
    8020091c:	46c1                	li	a3,16
    8020091e:	8a2e                	mv	s4,a1
    80200920:	b5a1                	j	80200768 <vprintfmt+0x156>
                    putch(ch, putdat);
    80200922:	9902                	jalr	s2
    80200924:	bf09                	j	80200836 <vprintfmt+0x224>
                putch('-', putdat);
    80200926:	85a6                	mv	a1,s1
    80200928:	02d00513          	li	a0,45
    8020092c:	e03e                	sd	a5,0(sp)
    8020092e:	9902                	jalr	s2
                num = -(long long)num;
    80200930:	6782                	ld	a5,0(sp)
    80200932:	8a66                	mv	s4,s9
    80200934:	40800633          	neg	a2,s0
    80200938:	46a9                	li	a3,10
    8020093a:	b53d                	j	80200768 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    8020093c:	03b05163          	blez	s11,8020095e <vprintfmt+0x34c>
    80200940:	02d00693          	li	a3,45
    80200944:	f6d79de3          	bne	a5,a3,802008be <vprintfmt+0x2ac>
                p = "(null)";
    80200948:	00000417          	auipc	s0,0x0
    8020094c:	69840413          	addi	s0,s0,1688 # 80200fe0 <etext+0x5d0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200950:	02800793          	li	a5,40
    80200954:	02800513          	li	a0,40
    80200958:	00140a13          	addi	s4,s0,1
    8020095c:	bd6d                	j	80200816 <vprintfmt+0x204>
    8020095e:	00000a17          	auipc	s4,0x0
    80200962:	683a0a13          	addi	s4,s4,1667 # 80200fe1 <etext+0x5d1>
    80200966:	02800513          	li	a0,40
    8020096a:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    8020096e:	05e00413          	li	s0,94
    80200972:	b565                	j	8020081a <vprintfmt+0x208>

0000000080200974 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200974:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200976:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020097a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020097c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020097e:	ec06                	sd	ra,24(sp)
    80200980:	f83a                	sd	a4,48(sp)
    80200982:	fc3e                	sd	a5,56(sp)
    80200984:	e0c2                	sd	a6,64(sp)
    80200986:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200988:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020098a:	c89ff0ef          	jal	ra,80200612 <vprintfmt>
}
    8020098e:	60e2                	ld	ra,24(sp)
    80200990:	6161                	addi	sp,sp,80
    80200992:	8082                	ret

0000000080200994 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    80200994:	4781                	li	a5,0
    80200996:	00003717          	auipc	a4,0x3
    8020099a:	66a73703          	ld	a4,1642(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    8020099e:	88ba                	mv	a7,a4
    802009a0:	852a                	mv	a0,a0
    802009a2:	85be                	mv	a1,a5
    802009a4:	863e                	mv	a2,a5
    802009a6:	00000073          	ecall
    802009aa:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    802009ac:	8082                	ret

00000000802009ae <sbi_set_timer>:
    __asm__ volatile (
    802009ae:	4781                	li	a5,0
    802009b0:	00003717          	auipc	a4,0x3
    802009b4:	67073703          	ld	a4,1648(a4) # 80204020 <SBI_SET_TIMER>
    802009b8:	88ba                	mv	a7,a4
    802009ba:	852a                	mv	a0,a0
    802009bc:	85be                	mv	a1,a5
    802009be:	863e                	mv	a2,a5
    802009c0:	00000073          	ecall
    802009c4:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    802009c6:	8082                	ret

00000000802009c8 <sbi_shutdown>:
    __asm__ volatile (
    802009c8:	4781                	li	a5,0
    802009ca:	00003717          	auipc	a4,0x3
    802009ce:	63e73703          	ld	a4,1598(a4) # 80204008 <SBI_SHUTDOWN>
    802009d2:	88ba                	mv	a7,a4
    802009d4:	853e                	mv	a0,a5
    802009d6:	85be                	mv	a1,a5
    802009d8:	863e                	mv	a2,a5
    802009da:	00000073          	ecall
    802009de:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    802009e0:	8082                	ret

00000000802009e2 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    802009e2:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    802009e4:	e589                	bnez	a1,802009ee <strnlen+0xc>
    802009e6:	a811                	j	802009fa <strnlen+0x18>
        cnt ++;
    802009e8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    802009ea:	00f58863          	beq	a1,a5,802009fa <strnlen+0x18>
    802009ee:	00f50733          	add	a4,a0,a5
    802009f2:	00074703          	lbu	a4,0(a4)
    802009f6:	fb6d                	bnez	a4,802009e8 <strnlen+0x6>
    802009f8:	85be                	mv	a1,a5
    }
    return cnt;
}
    802009fa:	852e                	mv	a0,a1
    802009fc:	8082                	ret

00000000802009fe <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    802009fe:	ca01                	beqz	a2,80200a0e <memset+0x10>
    80200a00:	962a                	add	a2,a2,a0
    char *p = s;
    80200a02:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a04:	0785                	addi	a5,a5,1
    80200a06:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a0a:	fec79de3          	bne	a5,a2,80200a04 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a0e:	8082                	ret
