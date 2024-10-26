#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>


list_entry_t free_list[20];
unsigned int nr_free;
struct Page* addr;

static unsigned fixsize(unsigned size) {
  size |= size >> 1;
  size |= size >> 2;
  size |= size >> 4;
  size |= size >> 8;
  size |= size >> 16;
  return size+1;
}

static unsigned mi(unsigned size){
    int index = 0;
    while(size!=0){
        size>>=1;
        index++;
    }
    return index;
}

static void
buddy_init(void) {
    for(int i = 0; i<20; i++){
        list_init(&free_list[i]);
        //cprintf("after init: ind=%d, size=%d\n", i, list_size(&free_list[i]));
    }
    nr_free = 0;
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    //cprintf("origin n = %d\n", n);
    int es = 0;
    if ((n&(n-1))!=0){
        es = n - fixsize(n)/2;
        n = fixsize(n)/2;
    }//n是最大块数，es是剩的
    //cprintf("n=%d, es=%d\n", n, es);
    
    int index = mi(n);
    //cprintf("index = %d\n", index);
    
    struct Page *p = base;
    for (; p != base + n + es; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    
    base->property = n;
    SetPageProperty(base);
    (base+n)->property = es;
    SetPageProperty(base+n);
    nr_free += n+es;
    addr = base;
    //cprintf("nr_free = %d\n", nr_free);
    
    list_add(&free_list[index-1], &(base->page_link));
    list_add(&free_list[index], &((base+n)->page_link));
    //直接当是初始状态了
    return;
}


static struct Page *
buddy_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) { //空间不足
        return NULL;
    }
    
    int nn = n;
    if((n&(n-1))!=0){ nn = fixsize(n); }
    int ind = mi(nn)-1;
    //cprintf("n=%d, nn=%d, ind=%d\n", n, nn, ind);
    
    struct Page *page = NULL;
    list_entry_t *l = &free_list[ind];
    while (list_empty(l) && ind<20) {
        //cprintf("found it empty %d\n", ind);
        ind++;
        l = &free_list[ind];
        
    }
    if(ind==20){return NULL;}
    page = le2page(l->next, page_link);

    //cprintf("here ind = %d\n", ind);
    if (page->property > nn){ //要拆分
        struct Page *p1 = page;
        struct Page *p2 = NULL;
        while (p1->property > nn && p1->property !=1){
            p2 = p1 + p1->property/2;
            p1->property /=2;
            p2->property = p1->property;
            SetPageProperty(p2);
            ind--;
            //cprintf("chaifen before add to ind=%d, size = %d\n", ind, list_size(&free_list[ind]));
            list_add_before(&free_list[ind], &(p2->page_link));
            //cprintf("chaifen add to ind=%d, size = %d\n", ind, list_size(&free_list[ind]));
        }
    } 
    
    if (page != NULL) {
        //cprintf("page != NULL\n");
        list_del(&(page->page_link));
        nr_free -= nn;
        ClearPageProperty(page);
    }

    return page;
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    if(n < 0 || (n&(n-1))!=0){return;}
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    int ind = mi(n)-1;
    int tp = (base-addr)%(n*2);
    
    //一：对应阶的链表为空
    list_entry_t* l = &(free_list[ind]);
    if (list_empty(l)){
        list_add(l, &(base->page_link));
        //cprintf("%d kong \n", ind);
        return;
    }
    
    int disc = 2147483647;//找个巨大的数
    struct Page *dis = NULL;
    while((l = list_next(l)) != &(free_list[ind])){
        p = le2page(l, page_link);
        int tmp = p-base;
        //cprintf("tmp:%d  ", tmp);
        
        //二：能合并
        if (tmp==n && tp==0){
             // 递归
             ClearPageProperty(p);// 记得再写处理的代码
             ClearPageProperty(base);
             list_del(l);
             nr_free -= 2*n;
             //cprintf("merge digui %d\n", 2*n);
             buddy_free_pages(base, 2*n);
             return;
        }
        if (tmp==-n && tp!=0){
             // 递归
             ClearPageProperty(p);// 记得再写处理的代码
             ClearPageProperty(base);
             list_del(l);
             nr_free -= 2*n;
             //cprintf("merge digui %d\n", 2*n);
             buddy_free_pages(p, 2*n);
             return;
        }
        
        //三：不能合并，要插入
        if (tmp<disc && tmp>0){
            disc = tmp;
            dis = p;
        }
        if(-tmp<disc && tmp<0){
            disc = -tmp;
            dis = p;
        }
    }
    //cprintf("cannot merge, add in %d,  %d\n", dis->property, disc);
    if(p-base>0){ list_add_before(&(p->page_link), &(base->page_link)); }
    else { list_add_after(&(p->page_link), &(base->page_link)); }
    return;

}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}

static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);


    list_entry_t free_list_store[20];
    for(int i=0;i<20;i++){
        free_list_store[i] = free_list[i]; 
        list_init(&free_list[i]);
    }

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);
    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list[0]));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    for(int i=0;i<20;i++){
        free_list[i] = free_list_store[i];
    }
    nr_free = nr_free_store;
    assert(!list_empty(&free_list[0]));

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
buddy_check(void) {
    int count = 0, total = 0;
    for(int i=0; i<20; i++){
        if(!list_empty(&(free_list[i]))){
            list_entry_t *le = &(free_list[i]);
            while ((le = le->next) != &(free_list[i])) {
                struct Page *p = le2page(le, page_link);
                assert(PageProperty(p));
                count ++, total += p->property;
            }
        }
    }
    assert(total == nr_free_pages());

    basic_check();

    struct Page *p0 = alloc_pages(4), *p1, *p2, *p3;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    list_entry_t free_list_store[20];
    for(int i=0;i<20;i++){
        free_list_store[i] = free_list[i]; 
        list_init(&free_list[i]);
    }
    for(int i=0;i<20;i++){
        assert(list_empty(&free_list[i]));
    }
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;
    
    free_pages(p0, 3);
    assert(alloc_pages(3) == NULL);//在buddy_system里不会释放成功的
    free_pages(p0, 4);
    assert((p1 = alloc_pages(2)) != NULL);
    assert(alloc_pages(3) == NULL);
    assert(p0 == p1);

    assert((p2 = alloc_page()) != NULL);
    assert((p3 = alloc_page()) != NULL);
    assert(p1+2==p2 && p2+1==p3);
    free_page(p2);
    assert(PageProperty(p2) && p2->property == 1);
    free_page(p3);
    assert(PageProperty(p2) && p2->property == 2);//会合并

    free_page(p1+1);
    assert(PageProperty(p2) && p2->property == 2);//不会合并

    free_page(p1);
    assert(PageProperty(p1) && p1->property == 4);

    assert((p0 = alloc_pages(3)) != NULL);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;

    for(int i=0;i<20;i++){
        free_list[i] = free_list_store[i];
    }
    free_pages(p0, 4);

    for(int i=0; i<20; i++){
        if(!list_empty(&(free_list[i]))){
            list_entry_t *le = &(free_list[i]);
            while ((le = le->next) != &(free_list[i])) {
                struct Page *p = le2page(le, page_link);
                assert(PageProperty(p));
                count --, total -= p->property;
            }
        }
    }
    assert(count == 0);
    assert(total == 0);
}
//这个结构体在
const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};

