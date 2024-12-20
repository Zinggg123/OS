# 缺页异常和页面置换

## 练习
### 练习1：理解基于FIFO的页面替换算法（思考题）
**调用函数过程：**
- pgfault_handler：Page Fault异常处理函数，调用do_pgfault处理页面故障。
- do_pgfault：进入页面缺失的处理。
- find_vma：判断访问出错的虚拟地址是否在该页表的合法虚拟地址集合（所有
可用的虚拟地址/虚拟页的集合，不论当前这个虚拟地址对应的页在内存上还是在硬盘
上）里。
- get_pte：获取对应虚拟地址的页表项（如果没有则创建）。
- pgdir_alloc_page：若找到的页表项是0，说明是刚刚创建的页表项。之前
不存在va和pa的映射关系，分配一个物理页。
- swap_in：分配一个内存页，然后根据PTE中的swap条目的addr，找到磁盘页
的地址，将磁盘页的内容读入这个内存页。
- swap_in->alloc_page：分配一个空页来读取硬盘中的内容。
- swap_in->alloc_page-->swap out：分配不到空页时需换出页。
- swap_in->swapfs_read：读取硬盘中相应的内容到一个内存的物理页，实现换入过程。
- page_insert：建立一个Page的phy addr与线性addr la的映射。
- page_insert->page_ref_inc/page_ref_dec:加减page的引用次数。
- page_insert->page_remove_pte：释放与线性地址la相关的Page结构，并清理（使无效）与线性地址la相关的页表项pte。
- page_insert->pte_create：根据一个页面和权限位构造PTE（页表项）。
- page_insert->tlb_invalidate：刷新TLB。
- swap_map_swappable：设置页面可交换并把页面加入swap所需链表中。

swap in () 函数只在do_pgfault()中被调用，来处理缺页异常，其中的刷新TLB的操作
是在之后的page_insert()中实现。而swap out ()函数随时可能会被调用，如换入页面
时、空闲页分配时等，只要满足消极策略时机，就会被调用。

### 练习2：深入理解不同分页模式的工作原理（思考题）
#### sv32，sv39，sv48的异同
- sv32：支持 32 位虚拟地址空间，地址分为两个虚拟页号（VPN）和一个偏移量。叶页表
条目（PTE）的物理页号（PPN）与偏移量相结合，形成物理地址。使用两级页表系统。
- sv39：支持 39 位虚拟地址空间。即本次实验中使用的sv39的三级页表模式。
- sv48：支持48 位虚拟地址空间，与sv39相比，sv48 增加了一个页表级别，因此具有四级页表系统。

get_pte函数的功能是根据给出的虚拟页表头与虚拟地址，在虚拟页表中创建
对应的各级页表项。其实现逻辑如下：

- 提取给出的虚拟地址la的前9位（通过PDX1右移处理实现），在给出的虚拟页表（第一级页表）中
获取其映射地址并判断该虚拟页号是否有效（已建立相应子页表），若不可用，则建
立相应页表并获取地址。
- 从刚刚获取的子页表（第二级页表）中获取la地址部分的中间9位的映射地址。仿照上一步判断是
否有效等步骤。
- 在上一步获取的子页表（第三级页表）中获取la地址部分的后9位的映射地址。该地址即为目标页表项地
址，返回该指针。

综上所述：两段代码相近本质上是因为二者都是依次按照多级页表的映射关系找到下一级的页目录或者页表项，
逻辑近似。如果是sv32则只需要进行一次pdep然后直接返回就可以得到页表项，这是因为其只有两层页表关系；
而sv48则还需要多一层页表递进关系，因此需要pdep2、pdep1和pdep0然后才能返回。

#### 页表项的查找和页表项的分配合并的合理性
我认为是合理的。

实际上最重要的会使用get_pte()的地方就是在的do_pgfault()中，即发生缺页异常时候的处理。此时即使没有
对应的页表项，也是一定需要新建一个的。所以没有必要拆开。如果拆开则不能进行针对性的分配和弥补缺失

### 练习3：给未被映射的地址映射上物理页（需要编程）

do_pgfault-处理页面错误异常的中断处理程序，给未被映射的地址映射上物理页。
- mm：控制结构，用于记录一组使用相同PDT的虚拟内存区域（VMA）
- error_code：记录tf-err错误代码，函数从不同标志位获取不同信息
- addr：内存访问异常的地址(CR2寄存器的内容)，使用该地址定位相应页目录和页表条目

**实现过程：** 首先判断该addr是否确实之前分配给了该进程，如果判断没有则输出相应提示并返回；接着判断
是否可读/可写，若不满足条件则输出相应提示并返回。之后，判断get_pte获得的页表项是否为空（即该页
是否在内存中），若为空则需从磁盘中进行交换：首先吧硬盘中的页交换至新建的
page页中，并在页表中建立一个相应的映射，最后设置该页面位可置换的、设置其虚拟页地址。

**PDE和PTE中组成部分对页替换算法的潜在用处：**
 sv39 里面的一个页表项大小为 64 位 8 字节。其中第 53-10 位共44位为一个物理页号，
表示这个虚拟页号映射到的物理页号。后面的第 9-0 位共10位则描述映射的状态信息。状态
信息各位含义如下：
- RSW：两位留给 S Mode 的应用程序，我们可以用来进行拓展。
- D：即 Dirty ，如果 D=1 表示自从上次 D 被清零后，有虚拟地址通过这个页表项进行写入。
- A，即 Accessed，如果 A=1 表示自从上次 A 被清零后，有虚拟地址通过这个页表项进行读、
或者写、或者取指。
- G，即 Global，如果 G=1 表示这个页表项是”全局"的，也就是所有的地址空间（所有的页表）
都包含这一项
- U，即 user，U为 1 表示用户态 (U Mode)的程序可以通过该页表项进映射。
- R,W,X 为许可位，分别表示是否可读 (Readable)，可写 (Writable)，可执行 (Executable)。

在改进的时钟算法中，会结合D与A判断是否置换该页（在时钟算法中直接根据page->visited判断）。


**页访问异常的硬件处理过程：**如果出现了页访问异常，那么硬件将引发页访问异常的地址将被
保存在 cr2 寄存器中，设置错误代码，然后触发 Page Fault 异常，进入do_pgdefault函数处理。

**数据结构Page与页目录项、页表项的对应关系：** page结构体如下：
```
struct Page {
    int ref;                        // page frame's reference counter
    uint_t flags;                 // array of flags that describe the status of the page frame
    uint_t visited;
    unsigned int property;          // the num of free block, used in first fit pm manager
    list_entry_t page_link;         // free list link
    list_entry_t pra_page_link;     // used for pra (page replace algorithm)
    uintptr_t pra_vaddr;            // used for pra (page replace algorithm)
};
```
其中使用了一个visited变量，用来记录页面是否被访问。在map_swappable函数会把换
入的页面加入到FIFO的交换页队列中，此时页面已经被访问，visited置为1；在
clock_swap_out_victim函数中可根据算法筛选出可用来交换的页面。

PTE中的PTE_A表示内存页是否被访问过，page中的visited与其对应。pra_vaddr记录了
可找到PDE、PTE的虚拟地址。

### 练习4：补充完成Clock页替换算法（需要编程）

#### 页替换算法比较
- **FIFO页替换算法**：总是淘汰最先进入内存的页。在算法中，把新加入的页放入链表
的头部，使最先进入内存的页保持在链表尾部。
- **Clock页替换算法**：淘汰最早进入的未被访问的页面。本质上与 FIFO 算法是类似
的，不同之处是在Clock页替换算法中跳过了访问位为1的页。该算法近似地体现了 LRU 
的思想，且易于实现，开销少，需要硬件支持来设置访问位。

### 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）
**“一个大页”的页表映射方式的优劣势：**
- 优势
    - 简单性：使用一个大页的页表映射方式更为简单和直观。
    - 快速访问：由于只有一个页表，页表查找速度通常更快，从而可以减少内存访问的延迟。
    - 连续内存分配：大页可以为需要大量连续内存的应用程序提供更好的性能，因为它们减少了页表条目的数量和TLB缺失的可能性。
    - 减少TLB缺失：由于大页涵盖的物理内存范围更大，TLB中的一个条目可以映射更大的内存范围，所以
    TLB总计可以映射更多的内存范围，从而可能减少TLB缺失的次数。
- 劣势
    - 浪费内存：如果应用程序只需要小部分的大页，则剩余的部分将被浪费，导致内存碎片。
    - 不灵活：大页不适合小内存需求的应用程序。
    - 增加内存压力：由于每个大页都需要大量的连续内存，因此可能会增加内存分配的压力和碎片化。
    - 置换代价较大：直接置换大页会导致较大的资源和性能浪费。

### Challenge：实现不考虑实现开销和效率的LRU页替换算法（需要编程）
最久未使用(least recently used, LRU)算法：利用局部性，通过过去的访问情况预测
未来的访问情况，我们可以认为最近还被访问过的页面将来被访问的可能性大，而很久没
访问过的页面将来不太可能被访问。于是我们比较当前内存里的页面最近一次被访问的时
间，把上一次访问时间离现在最久的页面置换出去。

## 知识点
- 调用vmm_init函数进行虚拟内存管理机制的初始化。在此阶段，主要是建立虚拟地址
到物理地址的映射关系，为虚拟内存提供管理支持。继续执行初始化过程，接下来调用
ide_init函数完成对用于页面换入和换出的硬盘（通常称为swap硬盘）的初始化工作。
在这个阶段，ucore准备好了对硬盘数据块的读写操作，以便后续页面置换算法的实现。
最后，完成整个初始化过程，调用swap_init函数用于初始化页面置换算法，这其中包括
Clock页替换算法的相关数据结构和初始化步骤。通过swap_init，ucore确保页面置换算
法准备就绪，可以在需要时执行页面换入和换出操作，以优化内存的利用。

- 当前采用消极替换策略