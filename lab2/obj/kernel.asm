
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area1>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	43660613          	addi	a2,a2,1078 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	17f010ef          	jal	ra,ffffffffc02019c8 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	98e50513          	addi	a0,a0,-1650 # ffffffffc02019e0 <etext+0x6>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	274010ef          	jal	ra,ffffffffc02012da <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	44c010ef          	jal	ra,ffffffffc02014f2 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	416010ef          	jal	ra,ffffffffc02014f2 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00002517          	auipc	a0,0x2
ffffffffc0200140:	8c450513          	addi	a0,a0,-1852 # ffffffffc0201a00 <etext+0x26>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0201a20 <etext+0x46>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	87c58593          	addi	a1,a1,-1924 # ffffffffc02019da <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	8da50513          	addi	a0,a0,-1830 # ffffffffc0201a40 <etext+0x66>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area1>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	8e650513          	addi	a0,a0,-1818 # ffffffffc0201a60 <etext+0x86>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2ea58593          	addi	a1,a1,746 # ffffffffc0206470 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	8f250513          	addi	a0,a0,-1806 # ffffffffc0201a80 <etext+0xa6>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6d558593          	addi	a1,a1,1749 # ffffffffc020686f <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00002517          	auipc	a0,0x2
ffffffffc02001c0:	8e450513          	addi	a0,a0,-1820 # ffffffffc0201aa0 <etext+0xc6>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00002617          	auipc	a2,0x2
ffffffffc02001ce:	90660613          	addi	a2,a2,-1786 # ffffffffc0201ad0 <etext+0xf6>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	91250513          	addi	a0,a0,-1774 # ffffffffc0201ae8 <etext+0x10e>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00002617          	auipc	a2,0x2
ffffffffc02001ea:	91a60613          	addi	a2,a2,-1766 # ffffffffc0201b00 <etext+0x126>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	93258593          	addi	a1,a1,-1742 # ffffffffc0201b20 <etext+0x146>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	93250513          	addi	a0,a0,-1742 # ffffffffc0201b28 <etext+0x14e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	93460613          	addi	a2,a2,-1740 # ffffffffc0201b38 <etext+0x15e>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	95458593          	addi	a1,a1,-1708 # ffffffffc0201b60 <etext+0x186>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	91450513          	addi	a0,a0,-1772 # ffffffffc0201b28 <etext+0x14e>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	95060613          	addi	a2,a2,-1712 # ffffffffc0201b70 <etext+0x196>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	96858593          	addi	a1,a1,-1688 # ffffffffc0201b90 <etext+0x1b6>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	8f850513          	addi	a0,a0,-1800 # ffffffffc0201b28 <etext+0x14e>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00002517          	auipc	a0,0x2
ffffffffc020026e:	93650513          	addi	a0,a0,-1738 # ffffffffc0201ba0 <etext+0x1c6>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	93c50513          	addi	a0,a0,-1732 # ffffffffc0201bc8 <etext+0x1ee>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	996c0c13          	addi	s8,s8,-1642 # ffffffffc0201c38 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	94690913          	addi	s2,s2,-1722 # ffffffffc0201bf0 <etext+0x216>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	94648493          	addi	s1,s1,-1722 # ffffffffc0201bf8 <etext+0x21e>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	944b0b13          	addi	s6,s6,-1724 # ffffffffc0201c00 <etext+0x226>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	85ca0a13          	addi	s4,s4,-1956 # ffffffffc0201b20 <etext+0x146>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	5a4010ef          	jal	ra,ffffffffc0201874 <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00002d17          	auipc	s10,0x2
ffffffffc02002ea:	952d0d13          	addi	s10,s10,-1710 # ffffffffc0201c38 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	6a0010ef          	jal	ra,ffffffffc0201994 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	68c010ef          	jal	ra,ffffffffc0201994 <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	66c010ef          	jal	ra,ffffffffc02019b2 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	62e010ef          	jal	ra,ffffffffc02019b2 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	88250513          	addi	a0,a0,-1918 # ffffffffc0201c20 <etext+0x246>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	07c30313          	addi	t1,t1,124 # ffffffffc0206428 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	8a650513          	addi	a0,a0,-1882 # ffffffffc0201c80 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	6d850513          	addi	a0,a0,1752 # ffffffffc0201ac8 <etext+0xee>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	522010ef          	jal	ra,ffffffffc0201942 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	87250513          	addi	a0,a0,-1934 # ffffffffc0201ca0 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	4fc0106f          	j	ffffffffc0201942 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	4d80106f          	j	ffffffffc0201928 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	5080106f          	j	ffffffffc020195c <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	84250513          	addi	a0,a0,-1982 # ffffffffc0201cc0 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	84a50513          	addi	a0,a0,-1974 # ffffffffc0201cd8 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	85450513          	addi	a0,a0,-1964 # ffffffffc0201cf0 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	85e50513          	addi	a0,a0,-1954 # ffffffffc0201d08 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	86850513          	addi	a0,a0,-1944 # ffffffffc0201d20 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	87250513          	addi	a0,a0,-1934 # ffffffffc0201d38 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	87c50513          	addi	a0,a0,-1924 # ffffffffc0201d50 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	88650513          	addi	a0,a0,-1914 # ffffffffc0201d68 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	89050513          	addi	a0,a0,-1904 # ffffffffc0201d80 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	89a50513          	addi	a0,a0,-1894 # ffffffffc0201d98 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	8a450513          	addi	a0,a0,-1884 # ffffffffc0201db0 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0201dc8 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	8b850513          	addi	a0,a0,-1864 # ffffffffc0201de0 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	8c250513          	addi	a0,a0,-1854 # ffffffffc0201df8 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0201e10 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	8d650513          	addi	a0,a0,-1834 # ffffffffc0201e28 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	8e050513          	addi	a0,a0,-1824 # ffffffffc0201e40 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0201e58 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	8f450513          	addi	a0,a0,-1804 # ffffffffc0201e70 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0201e88 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	90850513          	addi	a0,a0,-1784 # ffffffffc0201ea0 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	91250513          	addi	a0,a0,-1774 # ffffffffc0201eb8 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	91c50513          	addi	a0,a0,-1764 # ffffffffc0201ed0 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	92650513          	addi	a0,a0,-1754 # ffffffffc0201ee8 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	93050513          	addi	a0,a0,-1744 # ffffffffc0201f00 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	93a50513          	addi	a0,a0,-1734 # ffffffffc0201f18 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	94450513          	addi	a0,a0,-1724 # ffffffffc0201f30 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	94e50513          	addi	a0,a0,-1714 # ffffffffc0201f48 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	95850513          	addi	a0,a0,-1704 # ffffffffc0201f60 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	96250513          	addi	a0,a0,-1694 # ffffffffc0201f78 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	96c50513          	addi	a0,a0,-1684 # ffffffffc0201f90 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	97250513          	addi	a0,a0,-1678 # ffffffffc0201fa8 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	97650513          	addi	a0,a0,-1674 # ffffffffc0201fc0 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	97650513          	addi	a0,a0,-1674 # ffffffffc0201fd8 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	97e50513          	addi	a0,a0,-1666 # ffffffffc0201ff0 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	98650513          	addi	a0,a0,-1658 # ffffffffc0202008 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	98a50513          	addi	a0,a0,-1654 # ffffffffc0202020 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	a5070713          	addi	a4,a4,-1456 # ffffffffc0202100 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	9d650513          	addi	a0,a0,-1578 # ffffffffc0202098 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0202078 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	96250513          	addi	a0,a0,-1694 # ffffffffc0202038 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	9d850513          	addi	a0,a0,-1576 # ffffffffc02020b8 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206430 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00002517          	auipc	a0,0x2
ffffffffc0200714:	9d050513          	addi	a0,a0,-1584 # ffffffffc02020e0 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0202058 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	9a450513          	addi	a0,a0,-1628 # ffffffffc02020d0 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <free_area1>
ffffffffc020080a:	e79c                	sd	a5,8(a5)
ffffffffc020080c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area1.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020080e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	80c56503          	lwu	a0,-2036(a0) # ffffffffc0206020 <free_area1+0x10>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc020081e:	715d                	addi	sp,sp,-80
ffffffffc0200820:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200822:	00005417          	auipc	s0,0x5
ffffffffc0200826:	7ee40413          	addi	s0,s0,2030 # ffffffffc0206010 <free_area1>
ffffffffc020082a:	641c                	ld	a5,8(s0)
ffffffffc020082c:	e486                	sd	ra,72(sp)
ffffffffc020082e:	fc26                	sd	s1,56(sp)
ffffffffc0200830:	f84a                	sd	s2,48(sp)
ffffffffc0200832:	f44e                	sd	s3,40(sp)
ffffffffc0200834:	f052                	sd	s4,32(sp)
ffffffffc0200836:	ec56                	sd	s5,24(sp)
ffffffffc0200838:	e85a                	sd	s6,16(sp)
ffffffffc020083a:	e45e                	sd	s7,8(sp)
ffffffffc020083c:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020083e:	26878b63          	beq	a5,s0,ffffffffc0200ab4 <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc0200842:	4481                	li	s1,0
ffffffffc0200844:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200846:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020084a:	8b09                	andi	a4,a4,2
ffffffffc020084c:	26070863          	beqz	a4,ffffffffc0200abc <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc0200850:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200854:	679c                	ld	a5,8(a5)
ffffffffc0200856:	2905                	addiw	s2,s2,1
ffffffffc0200858:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020085a:	fe8796e3          	bne	a5,s0,ffffffffc0200846 <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc020085e:	89a6                	mv	s3,s1
ffffffffc0200860:	241000ef          	jal	ra,ffffffffc02012a0 <nr_free_pages>
ffffffffc0200864:	33351c63          	bne	a0,s3,ffffffffc0200b9c <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200868:	4505                	li	a0,1
ffffffffc020086a:	1b9000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc020086e:	8a2a                	mv	s4,a0
ffffffffc0200870:	36050663          	beqz	a0,ffffffffc0200bdc <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200874:	4505                	li	a0,1
ffffffffc0200876:	1ad000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc020087a:	89aa                	mv	s3,a0
ffffffffc020087c:	34050063          	beqz	a0,ffffffffc0200bbc <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200880:	4505                	li	a0,1
ffffffffc0200882:	1a1000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc0200886:	8aaa                	mv	s5,a0
ffffffffc0200888:	2c050a63          	beqz	a0,ffffffffc0200b5c <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020088c:	253a0863          	beq	s4,s3,ffffffffc0200adc <best_fit_check+0x2be>
ffffffffc0200890:	24aa0663          	beq	s4,a0,ffffffffc0200adc <best_fit_check+0x2be>
ffffffffc0200894:	24a98463          	beq	s3,a0,ffffffffc0200adc <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200898:	000a2783          	lw	a5,0(s4)
ffffffffc020089c:	26079063          	bnez	a5,ffffffffc0200afc <best_fit_check+0x2de>
ffffffffc02008a0:	0009a783          	lw	a5,0(s3)
ffffffffc02008a4:	24079c63          	bnez	a5,ffffffffc0200afc <best_fit_check+0x2de>
ffffffffc02008a8:	411c                	lw	a5,0(a0)
ffffffffc02008aa:	24079963          	bnez	a5,ffffffffc0200afc <best_fit_check+0x2de>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008ae:	00006797          	auipc	a5,0x6
ffffffffc02008b2:	b927b783          	ld	a5,-1134(a5) # ffffffffc0206440 <pages>
ffffffffc02008b6:	40fa0733          	sub	a4,s4,a5
ffffffffc02008ba:	870d                	srai	a4,a4,0x3
ffffffffc02008bc:	00002597          	auipc	a1,0x2
ffffffffc02008c0:	f9c5b583          	ld	a1,-100(a1) # ffffffffc0202858 <error_string+0x38>
ffffffffc02008c4:	02b70733          	mul	a4,a4,a1
ffffffffc02008c8:	00002617          	auipc	a2,0x2
ffffffffc02008cc:	f9863603          	ld	a2,-104(a2) # ffffffffc0202860 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02008d0:	00006697          	auipc	a3,0x6
ffffffffc02008d4:	b686b683          	ld	a3,-1176(a3) # ffffffffc0206438 <npage>
ffffffffc02008d8:	06b2                	slli	a3,a3,0xc
ffffffffc02008da:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02008dc:	0732                	slli	a4,a4,0xc
ffffffffc02008de:	22d77f63          	bgeu	a4,a3,ffffffffc0200b1c <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008e2:	40f98733          	sub	a4,s3,a5
ffffffffc02008e6:	870d                	srai	a4,a4,0x3
ffffffffc02008e8:	02b70733          	mul	a4,a4,a1
ffffffffc02008ec:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02008ee:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02008f0:	3ed77663          	bgeu	a4,a3,ffffffffc0200cdc <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008f4:	40f507b3          	sub	a5,a0,a5
ffffffffc02008f8:	878d                	srai	a5,a5,0x3
ffffffffc02008fa:	02b787b3          	mul	a5,a5,a1
ffffffffc02008fe:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200900:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200902:	3ad7fd63          	bgeu	a5,a3,ffffffffc0200cbc <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc0200906:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200908:	00043c03          	ld	s8,0(s0)
ffffffffc020090c:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200910:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200914:	e400                	sd	s0,8(s0)
ffffffffc0200916:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200918:	00005797          	auipc	a5,0x5
ffffffffc020091c:	7007a423          	sw	zero,1800(a5) # ffffffffc0206020 <free_area1+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200920:	103000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc0200924:	36051c63          	bnez	a0,ffffffffc0200c9c <best_fit_check+0x47e>
    free_page(p0);
ffffffffc0200928:	4585                	li	a1,1
ffffffffc020092a:	8552                	mv	a0,s4
ffffffffc020092c:	135000ef          	jal	ra,ffffffffc0201260 <free_pages>
    free_page(p1);
ffffffffc0200930:	4585                	li	a1,1
ffffffffc0200932:	854e                	mv	a0,s3
ffffffffc0200934:	12d000ef          	jal	ra,ffffffffc0201260 <free_pages>
    free_page(p2);
ffffffffc0200938:	4585                	li	a1,1
ffffffffc020093a:	8556                	mv	a0,s5
ffffffffc020093c:	125000ef          	jal	ra,ffffffffc0201260 <free_pages>
    assert(nr_free == 3);
ffffffffc0200940:	4818                	lw	a4,16(s0)
ffffffffc0200942:	478d                	li	a5,3
ffffffffc0200944:	32f71c63          	bne	a4,a5,ffffffffc0200c7c <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200948:	4505                	li	a0,1
ffffffffc020094a:	0d9000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc020094e:	89aa                	mv	s3,a0
ffffffffc0200950:	30050663          	beqz	a0,ffffffffc0200c5c <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200954:	4505                	li	a0,1
ffffffffc0200956:	0cd000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc020095a:	8aaa                	mv	s5,a0
ffffffffc020095c:	2e050063          	beqz	a0,ffffffffc0200c3c <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200960:	4505                	li	a0,1
ffffffffc0200962:	0c1000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc0200966:	8a2a                	mv	s4,a0
ffffffffc0200968:	2a050a63          	beqz	a0,ffffffffc0200c1c <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc020096c:	4505                	li	a0,1
ffffffffc020096e:	0b5000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc0200972:	28051563          	bnez	a0,ffffffffc0200bfc <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200976:	4585                	li	a1,1
ffffffffc0200978:	854e                	mv	a0,s3
ffffffffc020097a:	0e7000ef          	jal	ra,ffffffffc0201260 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020097e:	641c                	ld	a5,8(s0)
ffffffffc0200980:	1a878e63          	beq	a5,s0,ffffffffc0200b3c <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200984:	4505                	li	a0,1
ffffffffc0200986:	09d000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc020098a:	52a99963          	bne	s3,a0,ffffffffc0200ebc <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc020098e:	4505                	li	a0,1
ffffffffc0200990:	093000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc0200994:	50051463          	bnez	a0,ffffffffc0200e9c <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200998:	481c                	lw	a5,16(s0)
ffffffffc020099a:	4e079163          	bnez	a5,ffffffffc0200e7c <best_fit_check+0x65e>
    free_page(p);
ffffffffc020099e:	854e                	mv	a0,s3
ffffffffc02009a0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02009a2:	01843023          	sd	s8,0(s0)
ffffffffc02009a6:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02009aa:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02009ae:	0b3000ef          	jal	ra,ffffffffc0201260 <free_pages>
    free_page(p1);
ffffffffc02009b2:	4585                	li	a1,1
ffffffffc02009b4:	8556                	mv	a0,s5
ffffffffc02009b6:	0ab000ef          	jal	ra,ffffffffc0201260 <free_pages>
    free_page(p2);
ffffffffc02009ba:	4585                	li	a1,1
ffffffffc02009bc:	8552                	mv	a0,s4
ffffffffc02009be:	0a3000ef          	jal	ra,ffffffffc0201260 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02009c2:	4515                	li	a0,5
ffffffffc02009c4:	05f000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc02009c8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02009ca:	48050963          	beqz	a0,ffffffffc0200e5c <best_fit_check+0x63e>
ffffffffc02009ce:	651c                	ld	a5,8(a0)
ffffffffc02009d0:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02009d2:	8b85                	andi	a5,a5,1
ffffffffc02009d4:	46079463          	bnez	a5,ffffffffc0200e3c <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02009d8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009da:	00043a83          	ld	s5,0(s0)
ffffffffc02009de:	00843a03          	ld	s4,8(s0)
ffffffffc02009e2:	e000                	sd	s0,0(s0)
ffffffffc02009e4:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02009e6:	03d000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc02009ea:	42051963          	bnez	a0,ffffffffc0200e1c <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc02009ee:	4589                	li	a1,2
ffffffffc02009f0:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc02009f4:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc02009f8:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc02009fc:	00005797          	auipc	a5,0x5
ffffffffc0200a00:	6207a223          	sw	zero,1572(a5) # ffffffffc0206020 <free_area1+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200a04:	05d000ef          	jal	ra,ffffffffc0201260 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200a08:	8562                	mv	a0,s8
ffffffffc0200a0a:	4585                	li	a1,1
ffffffffc0200a0c:	055000ef          	jal	ra,ffffffffc0201260 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200a10:	4511                	li	a0,4
ffffffffc0200a12:	011000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc0200a16:	3e051363          	bnez	a0,ffffffffc0200dfc <best_fit_check+0x5de>
ffffffffc0200a1a:	0309b783          	ld	a5,48(s3)
ffffffffc0200a1e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200a20:	8b85                	andi	a5,a5,1
ffffffffc0200a22:	3a078d63          	beqz	a5,ffffffffc0200ddc <best_fit_check+0x5be>
ffffffffc0200a26:	0389a703          	lw	a4,56(s3)
ffffffffc0200a2a:	4789                	li	a5,2
ffffffffc0200a2c:	3af71863          	bne	a4,a5,ffffffffc0200ddc <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200a30:	4505                	li	a0,1
ffffffffc0200a32:	7f0000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc0200a36:	8baa                	mv	s7,a0
ffffffffc0200a38:	38050263          	beqz	a0,ffffffffc0200dbc <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200a3c:	4509                	li	a0,2
ffffffffc0200a3e:	7e4000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc0200a42:	34050d63          	beqz	a0,ffffffffc0200d9c <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0200a46:	337c1b63          	bne	s8,s7,ffffffffc0200d7c <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200a4a:	854e                	mv	a0,s3
ffffffffc0200a4c:	4595                	li	a1,5
ffffffffc0200a4e:	013000ef          	jal	ra,ffffffffc0201260 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200a52:	4515                	li	a0,5
ffffffffc0200a54:	7ce000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc0200a58:	89aa                	mv	s3,a0
ffffffffc0200a5a:	30050163          	beqz	a0,ffffffffc0200d5c <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0200a5e:	4505                	li	a0,1
ffffffffc0200a60:	7c2000ef          	jal	ra,ffffffffc0201222 <alloc_pages>
ffffffffc0200a64:	2c051c63          	bnez	a0,ffffffffc0200d3c <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200a68:	481c                	lw	a5,16(s0)
ffffffffc0200a6a:	2a079963          	bnez	a5,ffffffffc0200d1c <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200a6e:	4595                	li	a1,5
ffffffffc0200a70:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200a72:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200a76:	01543023          	sd	s5,0(s0)
ffffffffc0200a7a:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200a7e:	7e2000ef          	jal	ra,ffffffffc0201260 <free_pages>
    return listelm->next;
ffffffffc0200a82:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a84:	00878963          	beq	a5,s0,ffffffffc0200a96 <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200a88:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200a8c:	679c                	ld	a5,8(a5)
ffffffffc0200a8e:	397d                	addiw	s2,s2,-1
ffffffffc0200a90:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a92:	fe879be3          	bne	a5,s0,ffffffffc0200a88 <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0200a96:	26091363          	bnez	s2,ffffffffc0200cfc <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0200a9a:	e0ed                	bnez	s1,ffffffffc0200b7c <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200a9c:	60a6                	ld	ra,72(sp)
ffffffffc0200a9e:	6406                	ld	s0,64(sp)
ffffffffc0200aa0:	74e2                	ld	s1,56(sp)
ffffffffc0200aa2:	7942                	ld	s2,48(sp)
ffffffffc0200aa4:	79a2                	ld	s3,40(sp)
ffffffffc0200aa6:	7a02                	ld	s4,32(sp)
ffffffffc0200aa8:	6ae2                	ld	s5,24(sp)
ffffffffc0200aaa:	6b42                	ld	s6,16(sp)
ffffffffc0200aac:	6ba2                	ld	s7,8(sp)
ffffffffc0200aae:	6c02                	ld	s8,0(sp)
ffffffffc0200ab0:	6161                	addi	sp,sp,80
ffffffffc0200ab2:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ab4:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200ab6:	4481                	li	s1,0
ffffffffc0200ab8:	4901                	li	s2,0
ffffffffc0200aba:	b35d                	j	ffffffffc0200860 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200abc:	00001697          	auipc	a3,0x1
ffffffffc0200ac0:	67468693          	addi	a3,a3,1652 # ffffffffc0202130 <commands+0x4f8>
ffffffffc0200ac4:	00001617          	auipc	a2,0x1
ffffffffc0200ac8:	67c60613          	addi	a2,a2,1660 # ffffffffc0202140 <commands+0x508>
ffffffffc0200acc:	10f00593          	li	a1,271
ffffffffc0200ad0:	00001517          	auipc	a0,0x1
ffffffffc0200ad4:	68850513          	addi	a0,a0,1672 # ffffffffc0202158 <commands+0x520>
ffffffffc0200ad8:	8d5ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200adc:	00001697          	auipc	a3,0x1
ffffffffc0200ae0:	71468693          	addi	a3,a3,1812 # ffffffffc02021f0 <commands+0x5b8>
ffffffffc0200ae4:	00001617          	auipc	a2,0x1
ffffffffc0200ae8:	65c60613          	addi	a2,a2,1628 # ffffffffc0202140 <commands+0x508>
ffffffffc0200aec:	0db00593          	li	a1,219
ffffffffc0200af0:	00001517          	auipc	a0,0x1
ffffffffc0200af4:	66850513          	addi	a0,a0,1640 # ffffffffc0202158 <commands+0x520>
ffffffffc0200af8:	8b5ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200afc:	00001697          	auipc	a3,0x1
ffffffffc0200b00:	71c68693          	addi	a3,a3,1820 # ffffffffc0202218 <commands+0x5e0>
ffffffffc0200b04:	00001617          	auipc	a2,0x1
ffffffffc0200b08:	63c60613          	addi	a2,a2,1596 # ffffffffc0202140 <commands+0x508>
ffffffffc0200b0c:	0dc00593          	li	a1,220
ffffffffc0200b10:	00001517          	auipc	a0,0x1
ffffffffc0200b14:	64850513          	addi	a0,a0,1608 # ffffffffc0202158 <commands+0x520>
ffffffffc0200b18:	895ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b1c:	00001697          	auipc	a3,0x1
ffffffffc0200b20:	73c68693          	addi	a3,a3,1852 # ffffffffc0202258 <commands+0x620>
ffffffffc0200b24:	00001617          	auipc	a2,0x1
ffffffffc0200b28:	61c60613          	addi	a2,a2,1564 # ffffffffc0202140 <commands+0x508>
ffffffffc0200b2c:	0de00593          	li	a1,222
ffffffffc0200b30:	00001517          	auipc	a0,0x1
ffffffffc0200b34:	62850513          	addi	a0,a0,1576 # ffffffffc0202158 <commands+0x520>
ffffffffc0200b38:	875ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200b3c:	00001697          	auipc	a3,0x1
ffffffffc0200b40:	7a468693          	addi	a3,a3,1956 # ffffffffc02022e0 <commands+0x6a8>
ffffffffc0200b44:	00001617          	auipc	a2,0x1
ffffffffc0200b48:	5fc60613          	addi	a2,a2,1532 # ffffffffc0202140 <commands+0x508>
ffffffffc0200b4c:	0f700593          	li	a1,247
ffffffffc0200b50:	00001517          	auipc	a0,0x1
ffffffffc0200b54:	60850513          	addi	a0,a0,1544 # ffffffffc0202158 <commands+0x520>
ffffffffc0200b58:	855ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b5c:	00001697          	auipc	a3,0x1
ffffffffc0200b60:	67468693          	addi	a3,a3,1652 # ffffffffc02021d0 <commands+0x598>
ffffffffc0200b64:	00001617          	auipc	a2,0x1
ffffffffc0200b68:	5dc60613          	addi	a2,a2,1500 # ffffffffc0202140 <commands+0x508>
ffffffffc0200b6c:	0d900593          	li	a1,217
ffffffffc0200b70:	00001517          	auipc	a0,0x1
ffffffffc0200b74:	5e850513          	addi	a0,a0,1512 # ffffffffc0202158 <commands+0x520>
ffffffffc0200b78:	835ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200b7c:	00002697          	auipc	a3,0x2
ffffffffc0200b80:	89468693          	addi	a3,a3,-1900 # ffffffffc0202410 <commands+0x7d8>
ffffffffc0200b84:	00001617          	auipc	a2,0x1
ffffffffc0200b88:	5bc60613          	addi	a2,a2,1468 # ffffffffc0202140 <commands+0x508>
ffffffffc0200b8c:	15100593          	li	a1,337
ffffffffc0200b90:	00001517          	auipc	a0,0x1
ffffffffc0200b94:	5c850513          	addi	a0,a0,1480 # ffffffffc0202158 <commands+0x520>
ffffffffc0200b98:	815ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200b9c:	00001697          	auipc	a3,0x1
ffffffffc0200ba0:	5d468693          	addi	a3,a3,1492 # ffffffffc0202170 <commands+0x538>
ffffffffc0200ba4:	00001617          	auipc	a2,0x1
ffffffffc0200ba8:	59c60613          	addi	a2,a2,1436 # ffffffffc0202140 <commands+0x508>
ffffffffc0200bac:	11200593          	li	a1,274
ffffffffc0200bb0:	00001517          	auipc	a0,0x1
ffffffffc0200bb4:	5a850513          	addi	a0,a0,1448 # ffffffffc0202158 <commands+0x520>
ffffffffc0200bb8:	ff4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bbc:	00001697          	auipc	a3,0x1
ffffffffc0200bc0:	5f468693          	addi	a3,a3,1524 # ffffffffc02021b0 <commands+0x578>
ffffffffc0200bc4:	00001617          	auipc	a2,0x1
ffffffffc0200bc8:	57c60613          	addi	a2,a2,1404 # ffffffffc0202140 <commands+0x508>
ffffffffc0200bcc:	0d800593          	li	a1,216
ffffffffc0200bd0:	00001517          	auipc	a0,0x1
ffffffffc0200bd4:	58850513          	addi	a0,a0,1416 # ffffffffc0202158 <commands+0x520>
ffffffffc0200bd8:	fd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bdc:	00001697          	auipc	a3,0x1
ffffffffc0200be0:	5b468693          	addi	a3,a3,1460 # ffffffffc0202190 <commands+0x558>
ffffffffc0200be4:	00001617          	auipc	a2,0x1
ffffffffc0200be8:	55c60613          	addi	a2,a2,1372 # ffffffffc0202140 <commands+0x508>
ffffffffc0200bec:	0d700593          	li	a1,215
ffffffffc0200bf0:	00001517          	auipc	a0,0x1
ffffffffc0200bf4:	56850513          	addi	a0,a0,1384 # ffffffffc0202158 <commands+0x520>
ffffffffc0200bf8:	fb4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200bfc:	00001697          	auipc	a3,0x1
ffffffffc0200c00:	6bc68693          	addi	a3,a3,1724 # ffffffffc02022b8 <commands+0x680>
ffffffffc0200c04:	00001617          	auipc	a2,0x1
ffffffffc0200c08:	53c60613          	addi	a2,a2,1340 # ffffffffc0202140 <commands+0x508>
ffffffffc0200c0c:	0f400593          	li	a1,244
ffffffffc0200c10:	00001517          	auipc	a0,0x1
ffffffffc0200c14:	54850513          	addi	a0,a0,1352 # ffffffffc0202158 <commands+0x520>
ffffffffc0200c18:	f94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c1c:	00001697          	auipc	a3,0x1
ffffffffc0200c20:	5b468693          	addi	a3,a3,1460 # ffffffffc02021d0 <commands+0x598>
ffffffffc0200c24:	00001617          	auipc	a2,0x1
ffffffffc0200c28:	51c60613          	addi	a2,a2,1308 # ffffffffc0202140 <commands+0x508>
ffffffffc0200c2c:	0f200593          	li	a1,242
ffffffffc0200c30:	00001517          	auipc	a0,0x1
ffffffffc0200c34:	52850513          	addi	a0,a0,1320 # ffffffffc0202158 <commands+0x520>
ffffffffc0200c38:	f74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c3c:	00001697          	auipc	a3,0x1
ffffffffc0200c40:	57468693          	addi	a3,a3,1396 # ffffffffc02021b0 <commands+0x578>
ffffffffc0200c44:	00001617          	auipc	a2,0x1
ffffffffc0200c48:	4fc60613          	addi	a2,a2,1276 # ffffffffc0202140 <commands+0x508>
ffffffffc0200c4c:	0f100593          	li	a1,241
ffffffffc0200c50:	00001517          	auipc	a0,0x1
ffffffffc0200c54:	50850513          	addi	a0,a0,1288 # ffffffffc0202158 <commands+0x520>
ffffffffc0200c58:	f54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c5c:	00001697          	auipc	a3,0x1
ffffffffc0200c60:	53468693          	addi	a3,a3,1332 # ffffffffc0202190 <commands+0x558>
ffffffffc0200c64:	00001617          	auipc	a2,0x1
ffffffffc0200c68:	4dc60613          	addi	a2,a2,1244 # ffffffffc0202140 <commands+0x508>
ffffffffc0200c6c:	0f000593          	li	a1,240
ffffffffc0200c70:	00001517          	auipc	a0,0x1
ffffffffc0200c74:	4e850513          	addi	a0,a0,1256 # ffffffffc0202158 <commands+0x520>
ffffffffc0200c78:	f34ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200c7c:	00001697          	auipc	a3,0x1
ffffffffc0200c80:	65468693          	addi	a3,a3,1620 # ffffffffc02022d0 <commands+0x698>
ffffffffc0200c84:	00001617          	auipc	a2,0x1
ffffffffc0200c88:	4bc60613          	addi	a2,a2,1212 # ffffffffc0202140 <commands+0x508>
ffffffffc0200c8c:	0ee00593          	li	a1,238
ffffffffc0200c90:	00001517          	auipc	a0,0x1
ffffffffc0200c94:	4c850513          	addi	a0,a0,1224 # ffffffffc0202158 <commands+0x520>
ffffffffc0200c98:	f14ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c9c:	00001697          	auipc	a3,0x1
ffffffffc0200ca0:	61c68693          	addi	a3,a3,1564 # ffffffffc02022b8 <commands+0x680>
ffffffffc0200ca4:	00001617          	auipc	a2,0x1
ffffffffc0200ca8:	49c60613          	addi	a2,a2,1180 # ffffffffc0202140 <commands+0x508>
ffffffffc0200cac:	0e900593          	li	a1,233
ffffffffc0200cb0:	00001517          	auipc	a0,0x1
ffffffffc0200cb4:	4a850513          	addi	a0,a0,1192 # ffffffffc0202158 <commands+0x520>
ffffffffc0200cb8:	ef4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200cbc:	00001697          	auipc	a3,0x1
ffffffffc0200cc0:	5dc68693          	addi	a3,a3,1500 # ffffffffc0202298 <commands+0x660>
ffffffffc0200cc4:	00001617          	auipc	a2,0x1
ffffffffc0200cc8:	47c60613          	addi	a2,a2,1148 # ffffffffc0202140 <commands+0x508>
ffffffffc0200ccc:	0e000593          	li	a1,224
ffffffffc0200cd0:	00001517          	auipc	a0,0x1
ffffffffc0200cd4:	48850513          	addi	a0,a0,1160 # ffffffffc0202158 <commands+0x520>
ffffffffc0200cd8:	ed4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200cdc:	00001697          	auipc	a3,0x1
ffffffffc0200ce0:	59c68693          	addi	a3,a3,1436 # ffffffffc0202278 <commands+0x640>
ffffffffc0200ce4:	00001617          	auipc	a2,0x1
ffffffffc0200ce8:	45c60613          	addi	a2,a2,1116 # ffffffffc0202140 <commands+0x508>
ffffffffc0200cec:	0df00593          	li	a1,223
ffffffffc0200cf0:	00001517          	auipc	a0,0x1
ffffffffc0200cf4:	46850513          	addi	a0,a0,1128 # ffffffffc0202158 <commands+0x520>
ffffffffc0200cf8:	eb4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200cfc:	00001697          	auipc	a3,0x1
ffffffffc0200d00:	70468693          	addi	a3,a3,1796 # ffffffffc0202400 <commands+0x7c8>
ffffffffc0200d04:	00001617          	auipc	a2,0x1
ffffffffc0200d08:	43c60613          	addi	a2,a2,1084 # ffffffffc0202140 <commands+0x508>
ffffffffc0200d0c:	15000593          	li	a1,336
ffffffffc0200d10:	00001517          	auipc	a0,0x1
ffffffffc0200d14:	44850513          	addi	a0,a0,1096 # ffffffffc0202158 <commands+0x520>
ffffffffc0200d18:	e94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200d1c:	00001697          	auipc	a3,0x1
ffffffffc0200d20:	5fc68693          	addi	a3,a3,1532 # ffffffffc0202318 <commands+0x6e0>
ffffffffc0200d24:	00001617          	auipc	a2,0x1
ffffffffc0200d28:	41c60613          	addi	a2,a2,1052 # ffffffffc0202140 <commands+0x508>
ffffffffc0200d2c:	14500593          	li	a1,325
ffffffffc0200d30:	00001517          	auipc	a0,0x1
ffffffffc0200d34:	42850513          	addi	a0,a0,1064 # ffffffffc0202158 <commands+0x520>
ffffffffc0200d38:	e74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d3c:	00001697          	auipc	a3,0x1
ffffffffc0200d40:	57c68693          	addi	a3,a3,1404 # ffffffffc02022b8 <commands+0x680>
ffffffffc0200d44:	00001617          	auipc	a2,0x1
ffffffffc0200d48:	3fc60613          	addi	a2,a2,1020 # ffffffffc0202140 <commands+0x508>
ffffffffc0200d4c:	13f00593          	li	a1,319
ffffffffc0200d50:	00001517          	auipc	a0,0x1
ffffffffc0200d54:	40850513          	addi	a0,a0,1032 # ffffffffc0202158 <commands+0x520>
ffffffffc0200d58:	e54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d5c:	00001697          	auipc	a3,0x1
ffffffffc0200d60:	68468693          	addi	a3,a3,1668 # ffffffffc02023e0 <commands+0x7a8>
ffffffffc0200d64:	00001617          	auipc	a2,0x1
ffffffffc0200d68:	3dc60613          	addi	a2,a2,988 # ffffffffc0202140 <commands+0x508>
ffffffffc0200d6c:	13e00593          	li	a1,318
ffffffffc0200d70:	00001517          	auipc	a0,0x1
ffffffffc0200d74:	3e850513          	addi	a0,a0,1000 # ffffffffc0202158 <commands+0x520>
ffffffffc0200d78:	e34ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200d7c:	00001697          	auipc	a3,0x1
ffffffffc0200d80:	65468693          	addi	a3,a3,1620 # ffffffffc02023d0 <commands+0x798>
ffffffffc0200d84:	00001617          	auipc	a2,0x1
ffffffffc0200d88:	3bc60613          	addi	a2,a2,956 # ffffffffc0202140 <commands+0x508>
ffffffffc0200d8c:	13600593          	li	a1,310
ffffffffc0200d90:	00001517          	auipc	a0,0x1
ffffffffc0200d94:	3c850513          	addi	a0,a0,968 # ffffffffc0202158 <commands+0x520>
ffffffffc0200d98:	e14ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200d9c:	00001697          	auipc	a3,0x1
ffffffffc0200da0:	61c68693          	addi	a3,a3,1564 # ffffffffc02023b8 <commands+0x780>
ffffffffc0200da4:	00001617          	auipc	a2,0x1
ffffffffc0200da8:	39c60613          	addi	a2,a2,924 # ffffffffc0202140 <commands+0x508>
ffffffffc0200dac:	13500593          	li	a1,309
ffffffffc0200db0:	00001517          	auipc	a0,0x1
ffffffffc0200db4:	3a850513          	addi	a0,a0,936 # ffffffffc0202158 <commands+0x520>
ffffffffc0200db8:	df4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200dbc:	00001697          	auipc	a3,0x1
ffffffffc0200dc0:	5dc68693          	addi	a3,a3,1500 # ffffffffc0202398 <commands+0x760>
ffffffffc0200dc4:	00001617          	auipc	a2,0x1
ffffffffc0200dc8:	37c60613          	addi	a2,a2,892 # ffffffffc0202140 <commands+0x508>
ffffffffc0200dcc:	13400593          	li	a1,308
ffffffffc0200dd0:	00001517          	auipc	a0,0x1
ffffffffc0200dd4:	38850513          	addi	a0,a0,904 # ffffffffc0202158 <commands+0x520>
ffffffffc0200dd8:	dd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200ddc:	00001697          	auipc	a3,0x1
ffffffffc0200de0:	58c68693          	addi	a3,a3,1420 # ffffffffc0202368 <commands+0x730>
ffffffffc0200de4:	00001617          	auipc	a2,0x1
ffffffffc0200de8:	35c60613          	addi	a2,a2,860 # ffffffffc0202140 <commands+0x508>
ffffffffc0200dec:	13200593          	li	a1,306
ffffffffc0200df0:	00001517          	auipc	a0,0x1
ffffffffc0200df4:	36850513          	addi	a0,a0,872 # ffffffffc0202158 <commands+0x520>
ffffffffc0200df8:	db4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200dfc:	00001697          	auipc	a3,0x1
ffffffffc0200e00:	55468693          	addi	a3,a3,1364 # ffffffffc0202350 <commands+0x718>
ffffffffc0200e04:	00001617          	auipc	a2,0x1
ffffffffc0200e08:	33c60613          	addi	a2,a2,828 # ffffffffc0202140 <commands+0x508>
ffffffffc0200e0c:	13100593          	li	a1,305
ffffffffc0200e10:	00001517          	auipc	a0,0x1
ffffffffc0200e14:	34850513          	addi	a0,a0,840 # ffffffffc0202158 <commands+0x520>
ffffffffc0200e18:	d94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e1c:	00001697          	auipc	a3,0x1
ffffffffc0200e20:	49c68693          	addi	a3,a3,1180 # ffffffffc02022b8 <commands+0x680>
ffffffffc0200e24:	00001617          	auipc	a2,0x1
ffffffffc0200e28:	31c60613          	addi	a2,a2,796 # ffffffffc0202140 <commands+0x508>
ffffffffc0200e2c:	12500593          	li	a1,293
ffffffffc0200e30:	00001517          	auipc	a0,0x1
ffffffffc0200e34:	32850513          	addi	a0,a0,808 # ffffffffc0202158 <commands+0x520>
ffffffffc0200e38:	d74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200e3c:	00001697          	auipc	a3,0x1
ffffffffc0200e40:	4fc68693          	addi	a3,a3,1276 # ffffffffc0202338 <commands+0x700>
ffffffffc0200e44:	00001617          	auipc	a2,0x1
ffffffffc0200e48:	2fc60613          	addi	a2,a2,764 # ffffffffc0202140 <commands+0x508>
ffffffffc0200e4c:	11c00593          	li	a1,284
ffffffffc0200e50:	00001517          	auipc	a0,0x1
ffffffffc0200e54:	30850513          	addi	a0,a0,776 # ffffffffc0202158 <commands+0x520>
ffffffffc0200e58:	d54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200e5c:	00001697          	auipc	a3,0x1
ffffffffc0200e60:	4cc68693          	addi	a3,a3,1228 # ffffffffc0202328 <commands+0x6f0>
ffffffffc0200e64:	00001617          	auipc	a2,0x1
ffffffffc0200e68:	2dc60613          	addi	a2,a2,732 # ffffffffc0202140 <commands+0x508>
ffffffffc0200e6c:	11b00593          	li	a1,283
ffffffffc0200e70:	00001517          	auipc	a0,0x1
ffffffffc0200e74:	2e850513          	addi	a0,a0,744 # ffffffffc0202158 <commands+0x520>
ffffffffc0200e78:	d34ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200e7c:	00001697          	auipc	a3,0x1
ffffffffc0200e80:	49c68693          	addi	a3,a3,1180 # ffffffffc0202318 <commands+0x6e0>
ffffffffc0200e84:	00001617          	auipc	a2,0x1
ffffffffc0200e88:	2bc60613          	addi	a2,a2,700 # ffffffffc0202140 <commands+0x508>
ffffffffc0200e8c:	0fd00593          	li	a1,253
ffffffffc0200e90:	00001517          	auipc	a0,0x1
ffffffffc0200e94:	2c850513          	addi	a0,a0,712 # ffffffffc0202158 <commands+0x520>
ffffffffc0200e98:	d14ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e9c:	00001697          	auipc	a3,0x1
ffffffffc0200ea0:	41c68693          	addi	a3,a3,1052 # ffffffffc02022b8 <commands+0x680>
ffffffffc0200ea4:	00001617          	auipc	a2,0x1
ffffffffc0200ea8:	29c60613          	addi	a2,a2,668 # ffffffffc0202140 <commands+0x508>
ffffffffc0200eac:	0fb00593          	li	a1,251
ffffffffc0200eb0:	00001517          	auipc	a0,0x1
ffffffffc0200eb4:	2a850513          	addi	a0,a0,680 # ffffffffc0202158 <commands+0x520>
ffffffffc0200eb8:	cf4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200ebc:	00001697          	auipc	a3,0x1
ffffffffc0200ec0:	43c68693          	addi	a3,a3,1084 # ffffffffc02022f8 <commands+0x6c0>
ffffffffc0200ec4:	00001617          	auipc	a2,0x1
ffffffffc0200ec8:	27c60613          	addi	a2,a2,636 # ffffffffc0202140 <commands+0x508>
ffffffffc0200ecc:	0fa00593          	li	a1,250
ffffffffc0200ed0:	00001517          	auipc	a0,0x1
ffffffffc0200ed4:	28850513          	addi	a0,a0,648 # ffffffffc0202158 <commands+0x520>
ffffffffc0200ed8:	cd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200edc <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200edc:	1141                	addi	sp,sp,-16
ffffffffc0200ede:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200ee0:	14058a63          	beqz	a1,ffffffffc0201034 <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0200ee4:	00259693          	slli	a3,a1,0x2
ffffffffc0200ee8:	96ae                	add	a3,a3,a1
ffffffffc0200eea:	068e                	slli	a3,a3,0x3
ffffffffc0200eec:	96aa                	add	a3,a3,a0
ffffffffc0200eee:	87aa                	mv	a5,a0
ffffffffc0200ef0:	02d50263          	beq	a0,a3,ffffffffc0200f14 <best_fit_free_pages+0x38>
ffffffffc0200ef4:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200ef6:	8b05                	andi	a4,a4,1
ffffffffc0200ef8:	10071e63          	bnez	a4,ffffffffc0201014 <best_fit_free_pages+0x138>
ffffffffc0200efc:	6798                	ld	a4,8(a5)
ffffffffc0200efe:	8b09                	andi	a4,a4,2
ffffffffc0200f00:	10071a63          	bnez	a4,ffffffffc0201014 <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc0200f04:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200f08:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200f0c:	02878793          	addi	a5,a5,40
ffffffffc0200f10:	fed792e3          	bne	a5,a3,ffffffffc0200ef4 <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc0200f14:	2581                	sext.w	a1,a1
ffffffffc0200f16:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0200f18:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200f1c:	4789                	li	a5,2
ffffffffc0200f1e:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0200f22:	00005697          	auipc	a3,0x5
ffffffffc0200f26:	0ee68693          	addi	a3,a3,238 # ffffffffc0206010 <free_area1>
ffffffffc0200f2a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200f2c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0200f2e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0200f32:	9db9                	addw	a1,a1,a4
ffffffffc0200f34:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0200f36:	0ad78863          	beq	a5,a3,ffffffffc0200fe6 <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0200f3a:	fe878713          	addi	a4,a5,-24
ffffffffc0200f3e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0200f42:	4581                	li	a1,0
            if (base < page) {
ffffffffc0200f44:	00e56a63          	bltu	a0,a4,ffffffffc0200f58 <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc0200f48:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0200f4a:	06d70263          	beq	a4,a3,ffffffffc0200fae <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0200f4e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200f50:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200f54:	fee57ae3          	bgeu	a0,a4,ffffffffc0200f48 <best_fit_free_pages+0x6c>
ffffffffc0200f58:	c199                	beqz	a1,ffffffffc0200f5e <best_fit_free_pages+0x82>
ffffffffc0200f5a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200f5e:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200f60:	e390                	sd	a2,0(a5)
ffffffffc0200f62:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0200f64:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200f66:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0200f68:	02d70063          	beq	a4,a3,ffffffffc0200f88 <best_fit_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0200f6c:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0200f70:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc0200f74:	02081613          	slli	a2,a6,0x20
ffffffffc0200f78:	9201                	srli	a2,a2,0x20
ffffffffc0200f7a:	00261793          	slli	a5,a2,0x2
ffffffffc0200f7e:	97b2                	add	a5,a5,a2
ffffffffc0200f80:	078e                	slli	a5,a5,0x3
ffffffffc0200f82:	97ae                	add	a5,a5,a1
ffffffffc0200f84:	02f50f63          	beq	a0,a5,ffffffffc0200fc2 <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc0200f88:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0200f8a:	00d70f63          	beq	a4,a3,ffffffffc0200fa8 <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0200f8e:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0200f90:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0200f94:	02059613          	slli	a2,a1,0x20
ffffffffc0200f98:	9201                	srli	a2,a2,0x20
ffffffffc0200f9a:	00261793          	slli	a5,a2,0x2
ffffffffc0200f9e:	97b2                	add	a5,a5,a2
ffffffffc0200fa0:	078e                	slli	a5,a5,0x3
ffffffffc0200fa2:	97aa                	add	a5,a5,a0
ffffffffc0200fa4:	04f68863          	beq	a3,a5,ffffffffc0200ff4 <best_fit_free_pages+0x118>
}
ffffffffc0200fa8:	60a2                	ld	ra,8(sp)
ffffffffc0200faa:	0141                	addi	sp,sp,16
ffffffffc0200fac:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0200fae:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200fb0:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0200fb2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200fb4:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200fb6:	02d70563          	beq	a4,a3,ffffffffc0200fe0 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0200fba:	8832                	mv	a6,a2
ffffffffc0200fbc:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0200fbe:	87ba                	mv	a5,a4
ffffffffc0200fc0:	bf41                	j	ffffffffc0200f50 <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc0200fc2:	491c                	lw	a5,16(a0)
ffffffffc0200fc4:	0107883b          	addw	a6,a5,a6
ffffffffc0200fc8:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200fcc:	57f5                	li	a5,-3
ffffffffc0200fce:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200fd2:	6d10                	ld	a2,24(a0)
ffffffffc0200fd4:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc0200fd6:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200fd8:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0200fda:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0200fdc:	e390                	sd	a2,0(a5)
ffffffffc0200fde:	b775                	j	ffffffffc0200f8a <best_fit_free_pages+0xae>
ffffffffc0200fe0:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200fe2:	873e                	mv	a4,a5
ffffffffc0200fe4:	b761                	j	ffffffffc0200f6c <best_fit_free_pages+0x90>
}
ffffffffc0200fe6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0200fe8:	e390                	sd	a2,0(a5)
ffffffffc0200fea:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200fec:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200fee:	ed1c                	sd	a5,24(a0)
ffffffffc0200ff0:	0141                	addi	sp,sp,16
ffffffffc0200ff2:	8082                	ret
            base->property += p->property;
ffffffffc0200ff4:	ff872783          	lw	a5,-8(a4)
ffffffffc0200ff8:	ff070693          	addi	a3,a4,-16
ffffffffc0200ffc:	9dbd                	addw	a1,a1,a5
ffffffffc0200ffe:	c90c                	sw	a1,16(a0)
ffffffffc0201000:	57f5                	li	a5,-3
ffffffffc0201002:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201006:	6314                	ld	a3,0(a4)
ffffffffc0201008:	671c                	ld	a5,8(a4)
}
ffffffffc020100a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020100c:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc020100e:	e394                	sd	a3,0(a5)
ffffffffc0201010:	0141                	addi	sp,sp,16
ffffffffc0201012:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201014:	00001697          	auipc	a3,0x1
ffffffffc0201018:	41468693          	addi	a3,a3,1044 # ffffffffc0202428 <commands+0x7f0>
ffffffffc020101c:	00001617          	auipc	a2,0x1
ffffffffc0201020:	12460613          	addi	a2,a2,292 # ffffffffc0202140 <commands+0x508>
ffffffffc0201024:	09700593          	li	a1,151
ffffffffc0201028:	00001517          	auipc	a0,0x1
ffffffffc020102c:	13050513          	addi	a0,a0,304 # ffffffffc0202158 <commands+0x520>
ffffffffc0201030:	b7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201034:	00001697          	auipc	a3,0x1
ffffffffc0201038:	3ec68693          	addi	a3,a3,1004 # ffffffffc0202420 <commands+0x7e8>
ffffffffc020103c:	00001617          	auipc	a2,0x1
ffffffffc0201040:	10460613          	addi	a2,a2,260 # ffffffffc0202140 <commands+0x508>
ffffffffc0201044:	09400593          	li	a1,148
ffffffffc0201048:	00001517          	auipc	a0,0x1
ffffffffc020104c:	11050513          	addi	a0,a0,272 # ffffffffc0202158 <commands+0x520>
ffffffffc0201050:	b5cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201054 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0201054:	c95d                	beqz	a0,ffffffffc020110a <best_fit_alloc_pages+0xb6>
    if (n > nr_free) {
ffffffffc0201056:	00005817          	auipc	a6,0x5
ffffffffc020105a:	fba80813          	addi	a6,a6,-70 # ffffffffc0206010 <free_area1>
ffffffffc020105e:	01082303          	lw	t1,16(a6)
ffffffffc0201062:	862a                	mv	a2,a0
ffffffffc0201064:	02031793          	slli	a5,t1,0x20
ffffffffc0201068:	9381                	srli	a5,a5,0x20
ffffffffc020106a:	08a7ee63          	bltu	a5,a0,ffffffffc0201106 <best_fit_alloc_pages+0xb2>
    return listelm->next;
ffffffffc020106e:	00883783          	ld	a5,8(a6)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201072:	09078a63          	beq	a5,a6,ffffffffc0201106 <best_fit_alloc_pages+0xb2>
    struct Page *page = NULL;
ffffffffc0201076:	4e01                	li	t3,0
    int tmp = -1; // 记录当前最合适的页数
ffffffffc0201078:	55fd                	li	a1,-1
        else if ((tmp == -1||p->property < tmp) && p->property >=n) {
ffffffffc020107a:	58fd                	li	a7,-1
        if (p->property == n) { // 如果相等就已经很合适了
ffffffffc020107c:	ff87a703          	lw	a4,-8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201080:	fe878513          	addi	a0,a5,-24
        if (p->property == n) { // 如果相等就已经很合适了
ffffffffc0201084:	02071693          	slli	a3,a4,0x20
ffffffffc0201088:	9281                	srli	a3,a3,0x20
ffffffffc020108a:	02d60363          	beq	a2,a3,ffffffffc02010b0 <best_fit_alloc_pages+0x5c>
        else if ((tmp == -1||p->property < tmp) && p->property >=n) {
ffffffffc020108e:	01158463          	beq	a1,a7,ffffffffc0201096 <best_fit_alloc_pages+0x42>
ffffffffc0201092:	00b77763          	bgeu	a4,a1,ffffffffc02010a0 <best_fit_alloc_pages+0x4c>
ffffffffc0201096:	00c6e563          	bltu	a3,a2,ffffffffc02010a0 <best_fit_alloc_pages+0x4c>
            tmp = p->property;
ffffffffc020109a:	0007059b          	sext.w	a1,a4
        struct Page *p = le2page(le, page_link);
ffffffffc020109e:	8e2a                	mv	t3,a0
ffffffffc02010a0:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010a2:	fd079de3          	bne	a5,a6,ffffffffc020107c <best_fit_alloc_pages+0x28>
        return NULL;
ffffffffc02010a6:	4501                	li	a0,0
    if (page != NULL) {
ffffffffc02010a8:	000e1363          	bnez	t3,ffffffffc02010ae <best_fit_alloc_pages+0x5a>
}
ffffffffc02010ac:	8082                	ret
ffffffffc02010ae:	8572                	mv	a0,t3
    __list_del(listelm->prev, listelm->next);
ffffffffc02010b0:	711c                	ld	a5,32(a0)
    return listelm->prev;
ffffffffc02010b2:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc02010b4:	4914                	lw	a3,16(a0)
            p->property = page->property - n;
ffffffffc02010b6:	0006059b          	sext.w	a1,a2
    prev->next = next;
ffffffffc02010ba:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02010bc:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc02010be:	02069793          	slli	a5,a3,0x20
ffffffffc02010c2:	9381                	srli	a5,a5,0x20
ffffffffc02010c4:	02f67763          	bgeu	a2,a5,ffffffffc02010f2 <best_fit_alloc_pages+0x9e>
            struct Page *p = page + n;
ffffffffc02010c8:	00261793          	slli	a5,a2,0x2
ffffffffc02010cc:	97b2                	add	a5,a5,a2
ffffffffc02010ce:	078e                	slli	a5,a5,0x3
ffffffffc02010d0:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc02010d2:	9e8d                	subw	a3,a3,a1
ffffffffc02010d4:	cb94                	sw	a3,16(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02010d6:	00878613          	addi	a2,a5,8
ffffffffc02010da:	4689                	li	a3,2
ffffffffc02010dc:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02010e0:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc02010e2:	01878613          	addi	a2,a5,24
        nr_free -= n;
ffffffffc02010e6:	01082303          	lw	t1,16(a6)
    prev->next = next->prev = elm;
ffffffffc02010ea:	e290                	sd	a2,0(a3)
ffffffffc02010ec:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02010ee:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc02010f0:	ef98                	sd	a4,24(a5)
ffffffffc02010f2:	40b3033b          	subw	t1,t1,a1
ffffffffc02010f6:	00682823          	sw	t1,16(a6)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02010fa:	57f5                	li	a5,-3
ffffffffc02010fc:	00850713          	addi	a4,a0,8
ffffffffc0201100:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0201104:	8082                	ret
        return NULL;
ffffffffc0201106:	4501                	li	a0,0
}
ffffffffc0201108:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc020110a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020110c:	00001697          	auipc	a3,0x1
ffffffffc0201110:	31468693          	addi	a3,a3,788 # ffffffffc0202420 <commands+0x7e8>
ffffffffc0201114:	00001617          	auipc	a2,0x1
ffffffffc0201118:	02c60613          	addi	a2,a2,44 # ffffffffc0202140 <commands+0x508>
ffffffffc020111c:	06a00593          	li	a1,106
ffffffffc0201120:	00001517          	auipc	a0,0x1
ffffffffc0201124:	03850513          	addi	a0,a0,56 # ffffffffc0202158 <commands+0x520>
best_fit_alloc_pages(size_t n) {
ffffffffc0201128:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020112a:	a82ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020112e <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020112e:	1141                	addi	sp,sp,-16
ffffffffc0201130:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201132:	c9e1                	beqz	a1,ffffffffc0201202 <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201134:	00259693          	slli	a3,a1,0x2
ffffffffc0201138:	96ae                	add	a3,a3,a1
ffffffffc020113a:	068e                	slli	a3,a3,0x3
ffffffffc020113c:	96aa                	add	a3,a3,a0
ffffffffc020113e:	87aa                	mv	a5,a0
ffffffffc0201140:	00d50f63          	beq	a0,a3,ffffffffc020115e <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201144:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201146:	8b05                	andi	a4,a4,1
ffffffffc0201148:	cf49                	beqz	a4,ffffffffc02011e2 <best_fit_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc020114a:	0007a823          	sw	zero,16(a5)
ffffffffc020114e:	0007b423          	sd	zero,8(a5)
ffffffffc0201152:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201156:	02878793          	addi	a5,a5,40
ffffffffc020115a:	fed795e3          	bne	a5,a3,ffffffffc0201144 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc020115e:	2581                	sext.w	a1,a1
ffffffffc0201160:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201162:	4789                	li	a5,2
ffffffffc0201164:	00850713          	addi	a4,a0,8
ffffffffc0201168:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020116c:	00005697          	auipc	a3,0x5
ffffffffc0201170:	ea468693          	addi	a3,a3,-348 # ffffffffc0206010 <free_area1>
ffffffffc0201174:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201176:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201178:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020117c:	9db9                	addw	a1,a1,a4
ffffffffc020117e:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201180:	04d78a63          	beq	a5,a3,ffffffffc02011d4 <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0201184:	fe878713          	addi	a4,a5,-24
ffffffffc0201188:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020118c:	4581                	li	a1,0
            if (base < page) {
ffffffffc020118e:	00e56a63          	bltu	a0,a4,ffffffffc02011a2 <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc0201192:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201194:	02d70263          	beq	a4,a3,ffffffffc02011b8 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0201198:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020119a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020119e:	fee57ae3          	bgeu	a0,a4,ffffffffc0201192 <best_fit_init_memmap+0x64>
ffffffffc02011a2:	c199                	beqz	a1,ffffffffc02011a8 <best_fit_init_memmap+0x7a>
ffffffffc02011a4:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02011a8:	6398                	ld	a4,0(a5)
}
ffffffffc02011aa:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02011ac:	e390                	sd	a2,0(a5)
ffffffffc02011ae:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02011b0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011b2:	ed18                	sd	a4,24(a0)
ffffffffc02011b4:	0141                	addi	sp,sp,16
ffffffffc02011b6:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02011b8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011ba:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02011bc:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02011be:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02011c0:	00d70663          	beq	a4,a3,ffffffffc02011cc <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02011c4:	8832                	mv	a6,a2
ffffffffc02011c6:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02011c8:	87ba                	mv	a5,a4
ffffffffc02011ca:	bfc1                	j	ffffffffc020119a <best_fit_init_memmap+0x6c>
}
ffffffffc02011cc:	60a2                	ld	ra,8(sp)
ffffffffc02011ce:	e290                	sd	a2,0(a3)
ffffffffc02011d0:	0141                	addi	sp,sp,16
ffffffffc02011d2:	8082                	ret
ffffffffc02011d4:	60a2                	ld	ra,8(sp)
ffffffffc02011d6:	e390                	sd	a2,0(a5)
ffffffffc02011d8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011da:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011dc:	ed1c                	sd	a5,24(a0)
ffffffffc02011de:	0141                	addi	sp,sp,16
ffffffffc02011e0:	8082                	ret
        assert(PageReserved(p));
ffffffffc02011e2:	00001697          	auipc	a3,0x1
ffffffffc02011e6:	26e68693          	addi	a3,a3,622 # ffffffffc0202450 <commands+0x818>
ffffffffc02011ea:	00001617          	auipc	a2,0x1
ffffffffc02011ee:	f5660613          	addi	a2,a2,-170 # ffffffffc0202140 <commands+0x508>
ffffffffc02011f2:	04a00593          	li	a1,74
ffffffffc02011f6:	00001517          	auipc	a0,0x1
ffffffffc02011fa:	f6250513          	addi	a0,a0,-158 # ffffffffc0202158 <commands+0x520>
ffffffffc02011fe:	9aeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201202:	00001697          	auipc	a3,0x1
ffffffffc0201206:	21e68693          	addi	a3,a3,542 # ffffffffc0202420 <commands+0x7e8>
ffffffffc020120a:	00001617          	auipc	a2,0x1
ffffffffc020120e:	f3660613          	addi	a2,a2,-202 # ffffffffc0202140 <commands+0x508>
ffffffffc0201212:	04700593          	li	a1,71
ffffffffc0201216:	00001517          	auipc	a0,0x1
ffffffffc020121a:	f4250513          	addi	a0,a0,-190 # ffffffffc0202158 <commands+0x520>
ffffffffc020121e:	98eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201222 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201222:	100027f3          	csrr	a5,sstatus
ffffffffc0201226:	8b89                	andi	a5,a5,2
ffffffffc0201228:	e799                	bnez	a5,ffffffffc0201236 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020122a:	00005797          	auipc	a5,0x5
ffffffffc020122e:	21e7b783          	ld	a5,542(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201232:	6f9c                	ld	a5,24(a5)
ffffffffc0201234:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0201236:	1141                	addi	sp,sp,-16
ffffffffc0201238:	e406                	sd	ra,8(sp)
ffffffffc020123a:	e022                	sd	s0,0(sp)
ffffffffc020123c:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020123e:	a20ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201242:	00005797          	auipc	a5,0x5
ffffffffc0201246:	2067b783          	ld	a5,518(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020124a:	6f9c                	ld	a5,24(a5)
ffffffffc020124c:	8522                	mv	a0,s0
ffffffffc020124e:	9782                	jalr	a5
ffffffffc0201250:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201252:	a06ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201256:	60a2                	ld	ra,8(sp)
ffffffffc0201258:	8522                	mv	a0,s0
ffffffffc020125a:	6402                	ld	s0,0(sp)
ffffffffc020125c:	0141                	addi	sp,sp,16
ffffffffc020125e:	8082                	ret

ffffffffc0201260 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201260:	100027f3          	csrr	a5,sstatus
ffffffffc0201264:	8b89                	andi	a5,a5,2
ffffffffc0201266:	e799                	bnez	a5,ffffffffc0201274 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201268:	00005797          	auipc	a5,0x5
ffffffffc020126c:	1e07b783          	ld	a5,480(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201270:	739c                	ld	a5,32(a5)
ffffffffc0201272:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201274:	1101                	addi	sp,sp,-32
ffffffffc0201276:	ec06                	sd	ra,24(sp)
ffffffffc0201278:	e822                	sd	s0,16(sp)
ffffffffc020127a:	e426                	sd	s1,8(sp)
ffffffffc020127c:	842a                	mv	s0,a0
ffffffffc020127e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201280:	9deff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201284:	00005797          	auipc	a5,0x5
ffffffffc0201288:	1c47b783          	ld	a5,452(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020128c:	739c                	ld	a5,32(a5)
ffffffffc020128e:	85a6                	mv	a1,s1
ffffffffc0201290:	8522                	mv	a0,s0
ffffffffc0201292:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201294:	6442                	ld	s0,16(sp)
ffffffffc0201296:	60e2                	ld	ra,24(sp)
ffffffffc0201298:	64a2                	ld	s1,8(sp)
ffffffffc020129a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020129c:	9bcff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc02012a0 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012a0:	100027f3          	csrr	a5,sstatus
ffffffffc02012a4:	8b89                	andi	a5,a5,2
ffffffffc02012a6:	e799                	bnez	a5,ffffffffc02012b4 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02012a8:	00005797          	auipc	a5,0x5
ffffffffc02012ac:	1a07b783          	ld	a5,416(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012b0:	779c                	ld	a5,40(a5)
ffffffffc02012b2:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02012b4:	1141                	addi	sp,sp,-16
ffffffffc02012b6:	e406                	sd	ra,8(sp)
ffffffffc02012b8:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02012ba:	9a4ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02012be:	00005797          	auipc	a5,0x5
ffffffffc02012c2:	18a7b783          	ld	a5,394(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012c6:	779c                	ld	a5,40(a5)
ffffffffc02012c8:	9782                	jalr	a5
ffffffffc02012ca:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02012cc:	98cff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02012d0:	60a2                	ld	ra,8(sp)
ffffffffc02012d2:	8522                	mv	a0,s0
ffffffffc02012d4:	6402                	ld	s0,0(sp)
ffffffffc02012d6:	0141                	addi	sp,sp,16
ffffffffc02012d8:	8082                	ret

ffffffffc02012da <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012da:	00001797          	auipc	a5,0x1
ffffffffc02012de:	19e78793          	addi	a5,a5,414 # ffffffffc0202478 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012e2:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02012e4:	1101                	addi	sp,sp,-32
ffffffffc02012e6:	e822                	sd	s0,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012e8:	00001517          	auipc	a0,0x1
ffffffffc02012ec:	1c850513          	addi	a0,a0,456 # ffffffffc02024b0 <best_fit_pmm_manager+0x38>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012f0:	00005417          	auipc	s0,0x5
ffffffffc02012f4:	15840413          	addi	s0,s0,344 # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc02012f8:	ec06                	sd	ra,24(sp)
ffffffffc02012fa:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012fc:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012fe:	db5fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0201302:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201304:	00005497          	auipc	s1,0x5
ffffffffc0201308:	15c48493          	addi	s1,s1,348 # ffffffffc0206460 <va_pa_offset>
    pmm_manager->init();
ffffffffc020130c:	679c                	ld	a5,8(a5)
ffffffffc020130e:	9782                	jalr	a5
    // So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    // First we should init a physical memory manager(pmm) based on the framework.
    // Then pmm can alloc/free the physical memory.
    // Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
    cprintf("init_pmm_managersuccess\n");
ffffffffc0201310:	00001517          	auipc	a0,0x1
ffffffffc0201314:	1b850513          	addi	a0,a0,440 # ffffffffc02024c8 <best_fit_pmm_manager+0x50>
ffffffffc0201318:	d9bfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020131c:	57f5                	li	a5,-3
ffffffffc020131e:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201320:	00001517          	auipc	a0,0x1
ffffffffc0201324:	1c850513          	addi	a0,a0,456 # ffffffffc02024e8 <best_fit_pmm_manager+0x70>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201328:	e09c                	sd	a5,0(s1)
    cprintf("physcial memory map:\n");
ffffffffc020132a:	d89fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020132e:	46c5                	li	a3,17
ffffffffc0201330:	06ee                	slli	a3,a3,0x1b
ffffffffc0201332:	40100613          	li	a2,1025
ffffffffc0201336:	16fd                	addi	a3,a3,-1
ffffffffc0201338:	07e005b7          	lui	a1,0x7e00
ffffffffc020133c:	0656                	slli	a2,a2,0x15
ffffffffc020133e:	00001517          	auipc	a0,0x1
ffffffffc0201342:	1c250513          	addi	a0,a0,450 # ffffffffc0202500 <best_fit_pmm_manager+0x88>
ffffffffc0201346:	d6dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020134a:	777d                	lui	a4,0xfffff
ffffffffc020134c:	00006797          	auipc	a5,0x6
ffffffffc0201350:	12378793          	addi	a5,a5,291 # ffffffffc020746f <end+0xfff>
ffffffffc0201354:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201356:	00005517          	auipc	a0,0x5
ffffffffc020135a:	0e250513          	addi	a0,a0,226 # ffffffffc0206438 <npage>
ffffffffc020135e:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201362:	00005597          	auipc	a1,0x5
ffffffffc0201366:	0de58593          	addi	a1,a1,222 # ffffffffc0206440 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020136a:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020136c:	e19c                	sd	a5,0(a1)
ffffffffc020136e:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201370:	4701                	li	a4,0
ffffffffc0201372:	4885                	li	a7,1
ffffffffc0201374:	fff80837          	lui	a6,0xfff80
ffffffffc0201378:	a011                	j	ffffffffc020137c <pmm_init+0xa2>
        SetPageReserved(pages + i);
ffffffffc020137a:	619c                	ld	a5,0(a1)
ffffffffc020137c:	97b6                	add	a5,a5,a3
ffffffffc020137e:	07a1                	addi	a5,a5,8
ffffffffc0201380:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201384:	611c                	ld	a5,0(a0)
ffffffffc0201386:	0705                	addi	a4,a4,1
ffffffffc0201388:	02868693          	addi	a3,a3,40
ffffffffc020138c:	01078633          	add	a2,a5,a6
ffffffffc0201390:	fec765e3          	bltu	a4,a2,ffffffffc020137a <pmm_init+0xa0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201394:	6190                	ld	a2,0(a1)
ffffffffc0201396:	00279693          	slli	a3,a5,0x2
ffffffffc020139a:	96be                	add	a3,a3,a5
ffffffffc020139c:	fec00737          	lui	a4,0xfec00
ffffffffc02013a0:	9732                	add	a4,a4,a2
ffffffffc02013a2:	068e                	slli	a3,a3,0x3
ffffffffc02013a4:	96ba                	add	a3,a3,a4
ffffffffc02013a6:	c0200737          	lui	a4,0xc0200
ffffffffc02013aa:	0ae6e563          	bltu	a3,a4,ffffffffc0201454 <pmm_init+0x17a>
ffffffffc02013ae:	6098                	ld	a4,0(s1)
    if (freemem < mem_end) {
ffffffffc02013b0:	45c5                	li	a1,17
ffffffffc02013b2:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02013b4:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02013b6:	04b6ee63          	bltu	a3,a1,ffffffffc0201412 <pmm_init+0x138>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
    cprintf("page_init success\n");
ffffffffc02013ba:	00001517          	auipc	a0,0x1
ffffffffc02013be:	1de50513          	addi	a0,a0,478 # ffffffffc0202598 <best_fit_pmm_manager+0x120>
ffffffffc02013c2:	cf1fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02013c6:	601c                	ld	a5,0(s0)
ffffffffc02013c8:	7b9c                	ld	a5,48(a5)
ffffffffc02013ca:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02013cc:	00001517          	auipc	a0,0x1
ffffffffc02013d0:	1e450513          	addi	a0,a0,484 # ffffffffc02025b0 <best_fit_pmm_manager+0x138>
ffffffffc02013d4:	cdffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02013d8:	00004597          	auipc	a1,0x4
ffffffffc02013dc:	c2858593          	addi	a1,a1,-984 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02013e0:	00005797          	auipc	a5,0x5
ffffffffc02013e4:	06b7bc23          	sd	a1,120(a5) # ffffffffc0206458 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02013e8:	c02007b7          	lui	a5,0xc0200
ffffffffc02013ec:	08f5e063          	bltu	a1,a5,ffffffffc020146c <pmm_init+0x192>
ffffffffc02013f0:	6090                	ld	a2,0(s1)
}
ffffffffc02013f2:	6442                	ld	s0,16(sp)
ffffffffc02013f4:	60e2                	ld	ra,24(sp)
ffffffffc02013f6:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02013f8:	40c58633          	sub	a2,a1,a2
ffffffffc02013fc:	00005797          	auipc	a5,0x5
ffffffffc0201400:	04c7ba23          	sd	a2,84(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201404:	00001517          	auipc	a0,0x1
ffffffffc0201408:	1cc50513          	addi	a0,a0,460 # ffffffffc02025d0 <best_fit_pmm_manager+0x158>
}
ffffffffc020140c:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020140e:	ca5fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201412:	6705                	lui	a4,0x1
ffffffffc0201414:	177d                	addi	a4,a4,-1
ffffffffc0201416:	96ba                	add	a3,a3,a4
ffffffffc0201418:	777d                	lui	a4,0xfffff
ffffffffc020141a:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020141c:	00c6d513          	srli	a0,a3,0xc
ffffffffc0201420:	00f57e63          	bgeu	a0,a5,ffffffffc020143c <pmm_init+0x162>
    pmm_manager->init_memmap(base, n);
ffffffffc0201424:	601c                	ld	a5,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201426:	982a                	add	a6,a6,a0
ffffffffc0201428:	00281513          	slli	a0,a6,0x2
ffffffffc020142c:	9542                	add	a0,a0,a6
ffffffffc020142e:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201430:	8d95                	sub	a1,a1,a3
ffffffffc0201432:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201434:	81b1                	srli	a1,a1,0xc
ffffffffc0201436:	9532                	add	a0,a0,a2
ffffffffc0201438:	9782                	jalr	a5
}
ffffffffc020143a:	b741                	j	ffffffffc02013ba <pmm_init+0xe0>
        panic("pa2page called with invalid pa");
ffffffffc020143c:	00001617          	auipc	a2,0x1
ffffffffc0201440:	12c60613          	addi	a2,a2,300 # ffffffffc0202568 <best_fit_pmm_manager+0xf0>
ffffffffc0201444:	06b00593          	li	a1,107
ffffffffc0201448:	00001517          	auipc	a0,0x1
ffffffffc020144c:	14050513          	addi	a0,a0,320 # ffffffffc0202588 <best_fit_pmm_manager+0x110>
ffffffffc0201450:	f5dfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201454:	00001617          	auipc	a2,0x1
ffffffffc0201458:	0dc60613          	addi	a2,a2,220 # ffffffffc0202530 <best_fit_pmm_manager+0xb8>
ffffffffc020145c:	06f00593          	li	a1,111
ffffffffc0201460:	00001517          	auipc	a0,0x1
ffffffffc0201464:	0f850513          	addi	a0,a0,248 # ffffffffc0202558 <best_fit_pmm_manager+0xe0>
ffffffffc0201468:	f45fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020146c:	86ae                	mv	a3,a1
ffffffffc020146e:	00001617          	auipc	a2,0x1
ffffffffc0201472:	0c260613          	addi	a2,a2,194 # ffffffffc0202530 <best_fit_pmm_manager+0xb8>
ffffffffc0201476:	08d00593          	li	a1,141
ffffffffc020147a:	00001517          	auipc	a0,0x1
ffffffffc020147e:	0de50513          	addi	a0,a0,222 # ffffffffc0202558 <best_fit_pmm_manager+0xe0>
ffffffffc0201482:	f2bfe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201486 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201486:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020148a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020148c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201490:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201492:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201496:	f022                	sd	s0,32(sp)
ffffffffc0201498:	ec26                	sd	s1,24(sp)
ffffffffc020149a:	e84a                	sd	s2,16(sp)
ffffffffc020149c:	f406                	sd	ra,40(sp)
ffffffffc020149e:	e44e                	sd	s3,8(sp)
ffffffffc02014a0:	84aa                	mv	s1,a0
ffffffffc02014a2:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02014a4:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02014a8:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02014aa:	03067e63          	bgeu	a2,a6,ffffffffc02014e6 <printnum+0x60>
ffffffffc02014ae:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02014b0:	00805763          	blez	s0,ffffffffc02014be <printnum+0x38>
ffffffffc02014b4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02014b6:	85ca                	mv	a1,s2
ffffffffc02014b8:	854e                	mv	a0,s3
ffffffffc02014ba:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02014bc:	fc65                	bnez	s0,ffffffffc02014b4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014be:	1a02                	slli	s4,s4,0x20
ffffffffc02014c0:	00001797          	auipc	a5,0x1
ffffffffc02014c4:	15078793          	addi	a5,a5,336 # ffffffffc0202610 <best_fit_pmm_manager+0x198>
ffffffffc02014c8:	020a5a13          	srli	s4,s4,0x20
ffffffffc02014cc:	9a3e                	add	s4,s4,a5
}
ffffffffc02014ce:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014d0:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02014d4:	70a2                	ld	ra,40(sp)
ffffffffc02014d6:	69a2                	ld	s3,8(sp)
ffffffffc02014d8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014da:	85ca                	mv	a1,s2
ffffffffc02014dc:	87a6                	mv	a5,s1
}
ffffffffc02014de:	6942                	ld	s2,16(sp)
ffffffffc02014e0:	64e2                	ld	s1,24(sp)
ffffffffc02014e2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014e4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02014e6:	03065633          	divu	a2,a2,a6
ffffffffc02014ea:	8722                	mv	a4,s0
ffffffffc02014ec:	f9bff0ef          	jal	ra,ffffffffc0201486 <printnum>
ffffffffc02014f0:	b7f9                	j	ffffffffc02014be <printnum+0x38>

ffffffffc02014f2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02014f2:	7119                	addi	sp,sp,-128
ffffffffc02014f4:	f4a6                	sd	s1,104(sp)
ffffffffc02014f6:	f0ca                	sd	s2,96(sp)
ffffffffc02014f8:	ecce                	sd	s3,88(sp)
ffffffffc02014fa:	e8d2                	sd	s4,80(sp)
ffffffffc02014fc:	e4d6                	sd	s5,72(sp)
ffffffffc02014fe:	e0da                	sd	s6,64(sp)
ffffffffc0201500:	fc5e                	sd	s7,56(sp)
ffffffffc0201502:	f06a                	sd	s10,32(sp)
ffffffffc0201504:	fc86                	sd	ra,120(sp)
ffffffffc0201506:	f8a2                	sd	s0,112(sp)
ffffffffc0201508:	f862                	sd	s8,48(sp)
ffffffffc020150a:	f466                	sd	s9,40(sp)
ffffffffc020150c:	ec6e                	sd	s11,24(sp)
ffffffffc020150e:	892a                	mv	s2,a0
ffffffffc0201510:	84ae                	mv	s1,a1
ffffffffc0201512:	8d32                	mv	s10,a2
ffffffffc0201514:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201516:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020151a:	5b7d                	li	s6,-1
ffffffffc020151c:	00001a97          	auipc	s5,0x1
ffffffffc0201520:	128a8a93          	addi	s5,s5,296 # ffffffffc0202644 <best_fit_pmm_manager+0x1cc>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201524:	00001b97          	auipc	s7,0x1
ffffffffc0201528:	2fcb8b93          	addi	s7,s7,764 # ffffffffc0202820 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020152c:	000d4503          	lbu	a0,0(s10)
ffffffffc0201530:	001d0413          	addi	s0,s10,1
ffffffffc0201534:	01350a63          	beq	a0,s3,ffffffffc0201548 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201538:	c121                	beqz	a0,ffffffffc0201578 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020153a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020153c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020153e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201540:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201544:	ff351ae3          	bne	a0,s3,ffffffffc0201538 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201548:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020154c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201550:	4c81                	li	s9,0
ffffffffc0201552:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201554:	5c7d                	li	s8,-1
ffffffffc0201556:	5dfd                	li	s11,-1
ffffffffc0201558:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020155c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020155e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201562:	0ff5f593          	zext.b	a1,a1
ffffffffc0201566:	00140d13          	addi	s10,s0,1
ffffffffc020156a:	04b56263          	bltu	a0,a1,ffffffffc02015ae <vprintfmt+0xbc>
ffffffffc020156e:	058a                	slli	a1,a1,0x2
ffffffffc0201570:	95d6                	add	a1,a1,s5
ffffffffc0201572:	4194                	lw	a3,0(a1)
ffffffffc0201574:	96d6                	add	a3,a3,s5
ffffffffc0201576:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201578:	70e6                	ld	ra,120(sp)
ffffffffc020157a:	7446                	ld	s0,112(sp)
ffffffffc020157c:	74a6                	ld	s1,104(sp)
ffffffffc020157e:	7906                	ld	s2,96(sp)
ffffffffc0201580:	69e6                	ld	s3,88(sp)
ffffffffc0201582:	6a46                	ld	s4,80(sp)
ffffffffc0201584:	6aa6                	ld	s5,72(sp)
ffffffffc0201586:	6b06                	ld	s6,64(sp)
ffffffffc0201588:	7be2                	ld	s7,56(sp)
ffffffffc020158a:	7c42                	ld	s8,48(sp)
ffffffffc020158c:	7ca2                	ld	s9,40(sp)
ffffffffc020158e:	7d02                	ld	s10,32(sp)
ffffffffc0201590:	6de2                	ld	s11,24(sp)
ffffffffc0201592:	6109                	addi	sp,sp,128
ffffffffc0201594:	8082                	ret
            padc = '0';
ffffffffc0201596:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201598:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020159c:	846a                	mv	s0,s10
ffffffffc020159e:	00140d13          	addi	s10,s0,1
ffffffffc02015a2:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02015a6:	0ff5f593          	zext.b	a1,a1
ffffffffc02015aa:	fcb572e3          	bgeu	a0,a1,ffffffffc020156e <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02015ae:	85a6                	mv	a1,s1
ffffffffc02015b0:	02500513          	li	a0,37
ffffffffc02015b4:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02015b6:	fff44783          	lbu	a5,-1(s0)
ffffffffc02015ba:	8d22                	mv	s10,s0
ffffffffc02015bc:	f73788e3          	beq	a5,s3,ffffffffc020152c <vprintfmt+0x3a>
ffffffffc02015c0:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02015c4:	1d7d                	addi	s10,s10,-1
ffffffffc02015c6:	ff379de3          	bne	a5,s3,ffffffffc02015c0 <vprintfmt+0xce>
ffffffffc02015ca:	b78d                	j	ffffffffc020152c <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02015cc:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02015d0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015d4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02015d6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02015da:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015de:	02d86463          	bltu	a6,a3,ffffffffc0201606 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02015e2:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02015e6:	002c169b          	slliw	a3,s8,0x2
ffffffffc02015ea:	0186873b          	addw	a4,a3,s8
ffffffffc02015ee:	0017171b          	slliw	a4,a4,0x1
ffffffffc02015f2:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02015f4:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02015f8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02015fa:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02015fe:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201602:	fed870e3          	bgeu	a6,a3,ffffffffc02015e2 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201606:	f40ddce3          	bgez	s11,ffffffffc020155e <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020160a:	8de2                	mv	s11,s8
ffffffffc020160c:	5c7d                	li	s8,-1
ffffffffc020160e:	bf81                	j	ffffffffc020155e <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201610:	fffdc693          	not	a3,s11
ffffffffc0201614:	96fd                	srai	a3,a3,0x3f
ffffffffc0201616:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020161a:	00144603          	lbu	a2,1(s0)
ffffffffc020161e:	2d81                	sext.w	s11,s11
ffffffffc0201620:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201622:	bf35                	j	ffffffffc020155e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201624:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201628:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020162c:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020162e:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201630:	bfd9                	j	ffffffffc0201606 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201632:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201634:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201638:	01174463          	blt	a4,a7,ffffffffc0201640 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020163c:	1a088e63          	beqz	a7,ffffffffc02017f8 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201640:	000a3603          	ld	a2,0(s4)
ffffffffc0201644:	46c1                	li	a3,16
ffffffffc0201646:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201648:	2781                	sext.w	a5,a5
ffffffffc020164a:	876e                	mv	a4,s11
ffffffffc020164c:	85a6                	mv	a1,s1
ffffffffc020164e:	854a                	mv	a0,s2
ffffffffc0201650:	e37ff0ef          	jal	ra,ffffffffc0201486 <printnum>
            break;
ffffffffc0201654:	bde1                	j	ffffffffc020152c <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201656:	000a2503          	lw	a0,0(s4)
ffffffffc020165a:	85a6                	mv	a1,s1
ffffffffc020165c:	0a21                	addi	s4,s4,8
ffffffffc020165e:	9902                	jalr	s2
            break;
ffffffffc0201660:	b5f1                	j	ffffffffc020152c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201662:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201664:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201668:	01174463          	blt	a4,a7,ffffffffc0201670 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020166c:	18088163          	beqz	a7,ffffffffc02017ee <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201670:	000a3603          	ld	a2,0(s4)
ffffffffc0201674:	46a9                	li	a3,10
ffffffffc0201676:	8a2e                	mv	s4,a1
ffffffffc0201678:	bfc1                	j	ffffffffc0201648 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020167a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020167e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201680:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201682:	bdf1                	j	ffffffffc020155e <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201684:	85a6                	mv	a1,s1
ffffffffc0201686:	02500513          	li	a0,37
ffffffffc020168a:	9902                	jalr	s2
            break;
ffffffffc020168c:	b545                	j	ffffffffc020152c <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020168e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201692:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201694:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201696:	b5e1                	j	ffffffffc020155e <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201698:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020169a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020169e:	01174463          	blt	a4,a7,ffffffffc02016a6 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02016a2:	14088163          	beqz	a7,ffffffffc02017e4 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02016a6:	000a3603          	ld	a2,0(s4)
ffffffffc02016aa:	46a1                	li	a3,8
ffffffffc02016ac:	8a2e                	mv	s4,a1
ffffffffc02016ae:	bf69                	j	ffffffffc0201648 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02016b0:	03000513          	li	a0,48
ffffffffc02016b4:	85a6                	mv	a1,s1
ffffffffc02016b6:	e03e                	sd	a5,0(sp)
ffffffffc02016b8:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02016ba:	85a6                	mv	a1,s1
ffffffffc02016bc:	07800513          	li	a0,120
ffffffffc02016c0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02016c2:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02016c4:	6782                	ld	a5,0(sp)
ffffffffc02016c6:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02016c8:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02016cc:	bfb5                	j	ffffffffc0201648 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02016ce:	000a3403          	ld	s0,0(s4)
ffffffffc02016d2:	008a0713          	addi	a4,s4,8
ffffffffc02016d6:	e03a                	sd	a4,0(sp)
ffffffffc02016d8:	14040263          	beqz	s0,ffffffffc020181c <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02016dc:	0fb05763          	blez	s11,ffffffffc02017ca <vprintfmt+0x2d8>
ffffffffc02016e0:	02d00693          	li	a3,45
ffffffffc02016e4:	0cd79163          	bne	a5,a3,ffffffffc02017a6 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016e8:	00044783          	lbu	a5,0(s0)
ffffffffc02016ec:	0007851b          	sext.w	a0,a5
ffffffffc02016f0:	cf85                	beqz	a5,ffffffffc0201728 <vprintfmt+0x236>
ffffffffc02016f2:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016f6:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016fa:	000c4563          	bltz	s8,ffffffffc0201704 <vprintfmt+0x212>
ffffffffc02016fe:	3c7d                	addiw	s8,s8,-1
ffffffffc0201700:	036c0263          	beq	s8,s6,ffffffffc0201724 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201704:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201706:	0e0c8e63          	beqz	s9,ffffffffc0201802 <vprintfmt+0x310>
ffffffffc020170a:	3781                	addiw	a5,a5,-32
ffffffffc020170c:	0ef47b63          	bgeu	s0,a5,ffffffffc0201802 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201710:	03f00513          	li	a0,63
ffffffffc0201714:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201716:	000a4783          	lbu	a5,0(s4)
ffffffffc020171a:	3dfd                	addiw	s11,s11,-1
ffffffffc020171c:	0a05                	addi	s4,s4,1
ffffffffc020171e:	0007851b          	sext.w	a0,a5
ffffffffc0201722:	ffe1                	bnez	a5,ffffffffc02016fa <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201724:	01b05963          	blez	s11,ffffffffc0201736 <vprintfmt+0x244>
ffffffffc0201728:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020172a:	85a6                	mv	a1,s1
ffffffffc020172c:	02000513          	li	a0,32
ffffffffc0201730:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201732:	fe0d9be3          	bnez	s11,ffffffffc0201728 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201736:	6a02                	ld	s4,0(sp)
ffffffffc0201738:	bbd5                	j	ffffffffc020152c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020173a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020173c:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201740:	01174463          	blt	a4,a7,ffffffffc0201748 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201744:	08088d63          	beqz	a7,ffffffffc02017de <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201748:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020174c:	0a044d63          	bltz	s0,ffffffffc0201806 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201750:	8622                	mv	a2,s0
ffffffffc0201752:	8a66                	mv	s4,s9
ffffffffc0201754:	46a9                	li	a3,10
ffffffffc0201756:	bdcd                	j	ffffffffc0201648 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201758:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020175c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020175e:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201760:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201764:	8fb5                	xor	a5,a5,a3
ffffffffc0201766:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020176a:	02d74163          	blt	a4,a3,ffffffffc020178c <vprintfmt+0x29a>
ffffffffc020176e:	00369793          	slli	a5,a3,0x3
ffffffffc0201772:	97de                	add	a5,a5,s7
ffffffffc0201774:	639c                	ld	a5,0(a5)
ffffffffc0201776:	cb99                	beqz	a5,ffffffffc020178c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201778:	86be                	mv	a3,a5
ffffffffc020177a:	00001617          	auipc	a2,0x1
ffffffffc020177e:	ec660613          	addi	a2,a2,-314 # ffffffffc0202640 <best_fit_pmm_manager+0x1c8>
ffffffffc0201782:	85a6                	mv	a1,s1
ffffffffc0201784:	854a                	mv	a0,s2
ffffffffc0201786:	0ce000ef          	jal	ra,ffffffffc0201854 <printfmt>
ffffffffc020178a:	b34d                	j	ffffffffc020152c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020178c:	00001617          	auipc	a2,0x1
ffffffffc0201790:	ea460613          	addi	a2,a2,-348 # ffffffffc0202630 <best_fit_pmm_manager+0x1b8>
ffffffffc0201794:	85a6                	mv	a1,s1
ffffffffc0201796:	854a                	mv	a0,s2
ffffffffc0201798:	0bc000ef          	jal	ra,ffffffffc0201854 <printfmt>
ffffffffc020179c:	bb41                	j	ffffffffc020152c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020179e:	00001417          	auipc	s0,0x1
ffffffffc02017a2:	e8a40413          	addi	s0,s0,-374 # ffffffffc0202628 <best_fit_pmm_manager+0x1b0>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017a6:	85e2                	mv	a1,s8
ffffffffc02017a8:	8522                	mv	a0,s0
ffffffffc02017aa:	e43e                	sd	a5,8(sp)
ffffffffc02017ac:	1cc000ef          	jal	ra,ffffffffc0201978 <strnlen>
ffffffffc02017b0:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02017b4:	01b05b63          	blez	s11,ffffffffc02017ca <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02017b8:	67a2                	ld	a5,8(sp)
ffffffffc02017ba:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017be:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02017c0:	85a6                	mv	a1,s1
ffffffffc02017c2:	8552                	mv	a0,s4
ffffffffc02017c4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017c6:	fe0d9ce3          	bnez	s11,ffffffffc02017be <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017ca:	00044783          	lbu	a5,0(s0)
ffffffffc02017ce:	00140a13          	addi	s4,s0,1
ffffffffc02017d2:	0007851b          	sext.w	a0,a5
ffffffffc02017d6:	d3a5                	beqz	a5,ffffffffc0201736 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017d8:	05e00413          	li	s0,94
ffffffffc02017dc:	bf39                	j	ffffffffc02016fa <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02017de:	000a2403          	lw	s0,0(s4)
ffffffffc02017e2:	b7ad                	j	ffffffffc020174c <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02017e4:	000a6603          	lwu	a2,0(s4)
ffffffffc02017e8:	46a1                	li	a3,8
ffffffffc02017ea:	8a2e                	mv	s4,a1
ffffffffc02017ec:	bdb1                	j	ffffffffc0201648 <vprintfmt+0x156>
ffffffffc02017ee:	000a6603          	lwu	a2,0(s4)
ffffffffc02017f2:	46a9                	li	a3,10
ffffffffc02017f4:	8a2e                	mv	s4,a1
ffffffffc02017f6:	bd89                	j	ffffffffc0201648 <vprintfmt+0x156>
ffffffffc02017f8:	000a6603          	lwu	a2,0(s4)
ffffffffc02017fc:	46c1                	li	a3,16
ffffffffc02017fe:	8a2e                	mv	s4,a1
ffffffffc0201800:	b5a1                	j	ffffffffc0201648 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201802:	9902                	jalr	s2
ffffffffc0201804:	bf09                	j	ffffffffc0201716 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201806:	85a6                	mv	a1,s1
ffffffffc0201808:	02d00513          	li	a0,45
ffffffffc020180c:	e03e                	sd	a5,0(sp)
ffffffffc020180e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201810:	6782                	ld	a5,0(sp)
ffffffffc0201812:	8a66                	mv	s4,s9
ffffffffc0201814:	40800633          	neg	a2,s0
ffffffffc0201818:	46a9                	li	a3,10
ffffffffc020181a:	b53d                	j	ffffffffc0201648 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020181c:	03b05163          	blez	s11,ffffffffc020183e <vprintfmt+0x34c>
ffffffffc0201820:	02d00693          	li	a3,45
ffffffffc0201824:	f6d79de3          	bne	a5,a3,ffffffffc020179e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201828:	00001417          	auipc	s0,0x1
ffffffffc020182c:	e0040413          	addi	s0,s0,-512 # ffffffffc0202628 <best_fit_pmm_manager+0x1b0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201830:	02800793          	li	a5,40
ffffffffc0201834:	02800513          	li	a0,40
ffffffffc0201838:	00140a13          	addi	s4,s0,1
ffffffffc020183c:	bd6d                	j	ffffffffc02016f6 <vprintfmt+0x204>
ffffffffc020183e:	00001a17          	auipc	s4,0x1
ffffffffc0201842:	deba0a13          	addi	s4,s4,-533 # ffffffffc0202629 <best_fit_pmm_manager+0x1b1>
ffffffffc0201846:	02800513          	li	a0,40
ffffffffc020184a:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020184e:	05e00413          	li	s0,94
ffffffffc0201852:	b565                	j	ffffffffc02016fa <vprintfmt+0x208>

ffffffffc0201854 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201854:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201856:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020185a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020185c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020185e:	ec06                	sd	ra,24(sp)
ffffffffc0201860:	f83a                	sd	a4,48(sp)
ffffffffc0201862:	fc3e                	sd	a5,56(sp)
ffffffffc0201864:	e0c2                	sd	a6,64(sp)
ffffffffc0201866:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201868:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020186a:	c89ff0ef          	jal	ra,ffffffffc02014f2 <vprintfmt>
}
ffffffffc020186e:	60e2                	ld	ra,24(sp)
ffffffffc0201870:	6161                	addi	sp,sp,80
ffffffffc0201872:	8082                	ret

ffffffffc0201874 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201874:	715d                	addi	sp,sp,-80
ffffffffc0201876:	e486                	sd	ra,72(sp)
ffffffffc0201878:	e0a6                	sd	s1,64(sp)
ffffffffc020187a:	fc4a                	sd	s2,56(sp)
ffffffffc020187c:	f84e                	sd	s3,48(sp)
ffffffffc020187e:	f452                	sd	s4,40(sp)
ffffffffc0201880:	f056                	sd	s5,32(sp)
ffffffffc0201882:	ec5a                	sd	s6,24(sp)
ffffffffc0201884:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201886:	c901                	beqz	a0,ffffffffc0201896 <readline+0x22>
ffffffffc0201888:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020188a:	00001517          	auipc	a0,0x1
ffffffffc020188e:	db650513          	addi	a0,a0,-586 # ffffffffc0202640 <best_fit_pmm_manager+0x1c8>
ffffffffc0201892:	821fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201896:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201898:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020189a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020189c:	4aa9                	li	s5,10
ffffffffc020189e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02018a0:	00004b97          	auipc	s7,0x4
ffffffffc02018a4:	788b8b93          	addi	s7,s7,1928 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018a8:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02018ac:	87ffe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018b0:	00054a63          	bltz	a0,ffffffffc02018c4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018b4:	00a95a63          	bge	s2,a0,ffffffffc02018c8 <readline+0x54>
ffffffffc02018b8:	029a5263          	bge	s4,s1,ffffffffc02018dc <readline+0x68>
        c = getchar();
ffffffffc02018bc:	86ffe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018c0:	fe055ae3          	bgez	a0,ffffffffc02018b4 <readline+0x40>
            return NULL;
ffffffffc02018c4:	4501                	li	a0,0
ffffffffc02018c6:	a091                	j	ffffffffc020190a <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02018c8:	03351463          	bne	a0,s3,ffffffffc02018f0 <readline+0x7c>
ffffffffc02018cc:	e8a9                	bnez	s1,ffffffffc020191e <readline+0xaa>
        c = getchar();
ffffffffc02018ce:	85dfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018d2:	fe0549e3          	bltz	a0,ffffffffc02018c4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018d6:	fea959e3          	bge	s2,a0,ffffffffc02018c8 <readline+0x54>
ffffffffc02018da:	4481                	li	s1,0
            cputchar(c);
ffffffffc02018dc:	e42a                	sd	a0,8(sp)
ffffffffc02018de:	80bfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02018e2:	6522                	ld	a0,8(sp)
ffffffffc02018e4:	009b87b3          	add	a5,s7,s1
ffffffffc02018e8:	2485                	addiw	s1,s1,1
ffffffffc02018ea:	00a78023          	sb	a0,0(a5)
ffffffffc02018ee:	bf7d                	j	ffffffffc02018ac <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02018f0:	01550463          	beq	a0,s5,ffffffffc02018f8 <readline+0x84>
ffffffffc02018f4:	fb651ce3          	bne	a0,s6,ffffffffc02018ac <readline+0x38>
            cputchar(c);
ffffffffc02018f8:	ff0fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02018fc:	00004517          	auipc	a0,0x4
ffffffffc0201900:	72c50513          	addi	a0,a0,1836 # ffffffffc0206028 <buf>
ffffffffc0201904:	94aa                	add	s1,s1,a0
ffffffffc0201906:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020190a:	60a6                	ld	ra,72(sp)
ffffffffc020190c:	6486                	ld	s1,64(sp)
ffffffffc020190e:	7962                	ld	s2,56(sp)
ffffffffc0201910:	79c2                	ld	s3,48(sp)
ffffffffc0201912:	7a22                	ld	s4,40(sp)
ffffffffc0201914:	7a82                	ld	s5,32(sp)
ffffffffc0201916:	6b62                	ld	s6,24(sp)
ffffffffc0201918:	6bc2                	ld	s7,16(sp)
ffffffffc020191a:	6161                	addi	sp,sp,80
ffffffffc020191c:	8082                	ret
            cputchar(c);
ffffffffc020191e:	4521                	li	a0,8
ffffffffc0201920:	fc8fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201924:	34fd                	addiw	s1,s1,-1
ffffffffc0201926:	b759                	j	ffffffffc02018ac <readline+0x38>

ffffffffc0201928 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201928:	4781                	li	a5,0
ffffffffc020192a:	00004717          	auipc	a4,0x4
ffffffffc020192e:	6de73703          	ld	a4,1758(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201932:	88ba                	mv	a7,a4
ffffffffc0201934:	852a                	mv	a0,a0
ffffffffc0201936:	85be                	mv	a1,a5
ffffffffc0201938:	863e                	mv	a2,a5
ffffffffc020193a:	00000073          	ecall
ffffffffc020193e:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201940:	8082                	ret

ffffffffc0201942 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201942:	4781                	li	a5,0
ffffffffc0201944:	00005717          	auipc	a4,0x5
ffffffffc0201948:	b2473703          	ld	a4,-1244(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc020194c:	88ba                	mv	a7,a4
ffffffffc020194e:	852a                	mv	a0,a0
ffffffffc0201950:	85be                	mv	a1,a5
ffffffffc0201952:	863e                	mv	a2,a5
ffffffffc0201954:	00000073          	ecall
ffffffffc0201958:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc020195a:	8082                	ret

ffffffffc020195c <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc020195c:	4501                	li	a0,0
ffffffffc020195e:	00004797          	auipc	a5,0x4
ffffffffc0201962:	6a27b783          	ld	a5,1698(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201966:	88be                	mv	a7,a5
ffffffffc0201968:	852a                	mv	a0,a0
ffffffffc020196a:	85aa                	mv	a1,a0
ffffffffc020196c:	862a                	mv	a2,a0
ffffffffc020196e:	00000073          	ecall
ffffffffc0201972:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201974:	2501                	sext.w	a0,a0
ffffffffc0201976:	8082                	ret

ffffffffc0201978 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201978:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020197a:	e589                	bnez	a1,ffffffffc0201984 <strnlen+0xc>
ffffffffc020197c:	a811                	j	ffffffffc0201990 <strnlen+0x18>
        cnt ++;
ffffffffc020197e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201980:	00f58863          	beq	a1,a5,ffffffffc0201990 <strnlen+0x18>
ffffffffc0201984:	00f50733          	add	a4,a0,a5
ffffffffc0201988:	00074703          	lbu	a4,0(a4)
ffffffffc020198c:	fb6d                	bnez	a4,ffffffffc020197e <strnlen+0x6>
ffffffffc020198e:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201990:	852e                	mv	a0,a1
ffffffffc0201992:	8082                	ret

ffffffffc0201994 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201994:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201998:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020199c:	cb89                	beqz	a5,ffffffffc02019ae <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020199e:	0505                	addi	a0,a0,1
ffffffffc02019a0:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019a2:	fee789e3          	beq	a5,a4,ffffffffc0201994 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02019a6:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02019aa:	9d19                	subw	a0,a0,a4
ffffffffc02019ac:	8082                	ret
ffffffffc02019ae:	4501                	li	a0,0
ffffffffc02019b0:	bfed                	j	ffffffffc02019aa <strcmp+0x16>

ffffffffc02019b2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02019b2:	00054783          	lbu	a5,0(a0)
ffffffffc02019b6:	c799                	beqz	a5,ffffffffc02019c4 <strchr+0x12>
        if (*s == c) {
ffffffffc02019b8:	00f58763          	beq	a1,a5,ffffffffc02019c6 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02019bc:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02019c0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02019c2:	fbfd                	bnez	a5,ffffffffc02019b8 <strchr+0x6>
    }
    return NULL;
ffffffffc02019c4:	4501                	li	a0,0
}
ffffffffc02019c6:	8082                	ret

ffffffffc02019c8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02019c8:	ca01                	beqz	a2,ffffffffc02019d8 <memset+0x10>
ffffffffc02019ca:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02019cc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02019ce:	0785                	addi	a5,a5,1
ffffffffc02019d0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02019d4:	fec79de3          	bne	a5,a2,ffffffffc02019ce <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02019d8:	8082                	ret
