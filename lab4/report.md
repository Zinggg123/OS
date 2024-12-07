## LAB4：进程管理
### 实验目的
- 了解内核线程创建/执行的管理过程
- 了解内核线程的切换和基本调度过程

### 实验内容
#### 练习1：分配并初始化一个进程控制块
函数设计过程：

在alloc_proc函数的实现过程中，对新创建的进程控制块结构体进行了初始化（通过复制与memset方法）。
```
proc->state = PROC_UNINIT;
proc->pid = -1;
proc->runs = 0;
proc->kstack = 0;
proc->need_resched = 0;
proc->parent = NULL;
proc->mm = NULL;
proc->tf == NULL;
proc->cr3 = boot_cr3;
proc->flags == 0;
memset(&(proc->context), 0, sizeof(struct context));
//memset(proc->name, 0, PROC_NAME_LEN);
memset(proc->name, 0, sizeof(proc->name));
```
`proc_struct`中`struct context context`和`struct trapframe *tf`成员变量含义及作用：
- `struct context context`
    - 含义：context中保存了进程执行的上下文，也就是几个关键的寄存器的值。
    - 作用：保存的寄存器的值用于在进程切换中还原之前进程的运行状态。
- `struct trapframe *tf`
    - 含义：tf里保存了进程的中断帧。
    - 作用：当进程从用户空间跳进内核空间的时候，进程的执行状态被保存在了中断帧中（注意这里需要保存的执行状态数量不同于上下文切换）。系统调用可能会改变用户寄存器的值，我们可以通过调整中断帧来使得系统调用返回特定的值。

#### 练习2：为新创建的内核线程分配资源（需要编码）
函数设计过程：

do_fork函数中对创建的内核线程进行了资源的分配和设置：
```
if ((proc = alloc_proc()) == NULL) {goto fork_out;}
proc->parent = current;
if (setup_kstack(proc) != 0) {goto bad_fork_cleanup_kstack;}
copy_mm(clone_flags, proc);
copy_thread(proc, stack ,tf);
proc->pid = get_pid();
hash_proc(proc);
list_add(&proc_list, &(proc->list_link));
proc->state = PROC_RUNNABLE;
ret = proc->pid;
```
具体步骤如下：
- 调用alloc_proc分配一块新的用户信息块
- 为进程分配一个内核栈。
- 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
- 复制原进程上下文到新进程
- 将新进程添加到进程列表
- 唤醒新进程
- 返回新进程号

ucore是否做到给每个新fork的线程一个唯一的id？

是的。get_pid函数通过遍历所有现存进程的列表来查找未被使用的 pid。函数从上一次分配的 pid 开始递增查找，确保新分配的 pid 在 1 到 MAX_PID - 1 范围内，并且不与任何现有进程的 pid 冲突。如果遇到冲突或达到 MAX_PID，它会循环回 1 继续查找，直到找到一个可用的 pid 并返回。静态变量 last_pid 和 next_safe 用来跟踪最近分配的 pid 和下一个安全分配点，以优化查找过程。

#### 练习3：编写proc_run 函数（需要编码）
函数设计如下：
```
bool x;
struct proc_struct *tmp = current;
local_intr_save(x);
current = proc;
lcr3(proc->cr3);
switch_to(&(tmp->context), &(proc->context));
local_intr_restore(x);
```

在本实验的执行过程中，创建且运行了几个内核线程？

两个。一个为idle，一个为执行init_main函数的init线程。
```
//idle线程
if ((idleproc = alloc_proc()) == NULL) { //此处初始化线程
    panic("cannot alloc idleproc.\n");
}
... //一些检查
idleproc->pid = 0;
idleproc->state = PROC_RUNNABLE;
idleproc->kstack = (uintptr_t)bootstack;
idleproc->need_resched = 1; //设置为可以被切换
set_proc_name(idleproc, "idle"); //命名为idle
nr_process ++;
current = idleproc;
//init线程
int pid = kernel_thread(init_main, "Hello world!!", 0); 
//此处创建了调用init_main函数的线程，因为上一线程被设为可被切换，cpu_idle函数会自动检测并调度
if (pid <= 0) {
    panic("create init_main failed.\n");
}
initproc = find_proc(pid);
set_proc_name(initproc, "init"); //为线程命名为init

```

![运行结果](./result.png)

#### 扩展练习 Challenge：说明语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`是如何实现开关中断的？
local_intr_save函数与local_intr_restore函数的定义与调用关系如下：
```
//sync.c
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}
static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

//intr.c
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }

//riscv.h
#define set_csr(reg, bit) ({ unsigned long __tmp; \
  asm volatile ("csrrs %0, " #reg ", %1" : "=r"(__tmp) : "rK"(bit)); \
  __tmp; })
#define clear_csr(reg, bit) ({ unsigned long __tmp; \
  asm volatile ("csrrc %0, " #reg ", %1" : "=r"(__tmp) : "rK"(bit)); \
  __tmp; })
```
在关闭中断时，先通过读取sstatus寄存器中的SSTATUS_SIE位检查当前是否启用了中断，若未启用则调用禁用中断的函数（intr_disable），返回1；反之就是本来就关闭着，返回0即可。

在启用中断时，根据_intr_restore返回的bool值判断是否关闭成功，若成功，调用intr_enable开启中断。

intr_disable通过将SSTATUS_SIE位清零从而禁用中断；intr_enable将SSTATUS_SIE位置为1从而启用中断。

### 知识点
#### 程序与进程、线程
进程与程序之间最大的不同在于进程是一个“正在运行”的实体，而程序只是一个不动的文件。进程包含程序的内容，也就是它的静态的代码部分，也包括一些在运行时在可以体现出来的信息，比如堆栈，寄存器等数据，这些组成了进程“正在运行”的特性。

同一进程的线程之间往往具有相同的代码，共享一块内存，但是却有不同的CPU执行状态。相比于线程，进程更多的作为一个资源管理的实体（因为操作系统分配网络等资源时往往是基于进程的），这样线程就作为可以被调度的最小单元，给了调度器更多的调度可能。

#### idleproc
idleproc是一个在操作系统中常见的概念，用于表示空闲进程。在操作系统中，空闲进程是一个特殊的进程，它的主要目的是在系统没有其他任务需要执行时，占用 CPU 时间，同时便于进程调度的统一化。idleproc内核线程的工作就是不停地查询，看是否有其他内核线程可以执行了，如果有，马上让调度器选择那个内核线程执行（如cpu_idle函数）。