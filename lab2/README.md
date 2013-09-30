Report for lab2, Shian Chen
===
```
running JOS: (4.4s) 
  Physical page allocator: OK 
  Page management: OK 
  Kernel page directory: OK 
  Page management 2: OK 
Score: 70/70
```
Part 1: Physical Page Management
===
Exercise 1
---
```
Exercise 1. In the file kern/pmap.c, you must implement code for the following functions (probably in the order given).

boot_alloc()
mem_init() (only up to the call to check_page_free_list(1))
page_init()
page_alloc()
page_free()

check_page_free_list() and check_page_alloc() test your physical page allocator. You should boot JOS and see whether check_page_alloc() reports success. Fix your code so that it passes. You may find it helpful to add your own assert()s to verify that your assumptions are correct.
```
boot_alloc:
```c
	// ROUNDUP to make sure nextfree is kept aligned
	// to a multiple of PGSIZE
	cprintf("boot_alloc memory at %x\n", nextfree);
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
	if (n != 0) {
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
		return next;
	} else return nextfree;
```
page_init:

>Q: Then extended memory [EXTPHYSMEM, ...).
	Some of it is in use, some is free. Where is the kernel
	in physical memory?  Which pages are already in use for
	page tables and other data structures?

Memory after `(int)ROUNDUP(((char*)pages) + (sizeof(struct PageInfo) * npages) - 0xf0000000, PGSIZE)/PGSIZE;` is free.
```
void
page_init(void)
{
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	int med = (int)ROUNDUP(((char*)pages) + (sizeof(struct PageInfo) * npages) - 0xf0000000, PGSIZE)/PGSIZE;
	cprintf("%d\n", ((char*)pages) + (sizeof(struct PageInfo) * npages));
	cprintf("med=%d\n", med);
	for (i = med; i < npages; i++) {
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
```

page_alloc:
```c
struct PageInfo *
page_alloc(int alloc_flags)
{
	if (page_free_list) {
		struct PageInfo *ret = page_free_list;
		page_free_list = page_free_list->pp_link;
		if (alloc_flags & ALLOC_ZERO) 
			memset(page2kva(ret), 0, PGSIZE);
		return ret;
	}
	return NULL;
}
```

page_free:
```c
void
page_free(struct PageInfo *pp)
{
	pp->pp_link = page_free_list;
	page_free_list = pp;
}
```

```
$ make qemu-nox
6828 decimal is 15254 octal!
Physical memory: 66556K available, base = 640K, extended = 65532K
boot_alloc memory at f0116000
Next memory at f0117000
boot_alloc memory at f0117000
Next memory at f0138000
npages: 16639
npages_basemem: 160
pages: f0117000
-267159560
med=312
boot_alloc memory at f0138000
Next memory at f0138000
check_page_free_list done
check_page_alloc() succeeded!
```



Part 2: Virtual Memory
===

```
Question:
Assuming that the following JOS kernel code is correct, what type should variable x have, uintptr_t or physaddr_t?
	mystery_t x;
	char* value = return_a_pointer();
	*value = 10;
	x = (mystery_t) value;
```
Answer: uintptr_t, because va is used in applications.

The following code in `pmap.c` is very informative:
```c
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
```

Exercise 4
---
```
In the file kern/pmap.c, you must implement code for the following functions.

        pgdir_walk()
        boot_map_region()
        page_lookup()
        page_remove()
        page_insert()
	
check_page(), called from mem_init(), tests your page table management routines. You should make sure it reports success before proceeding.
```
pgdr_walk, the comments is between codes:
```c
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
			pg->pp_ref++;
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;	
			//we should use PTE_U and PTE_W to pass checkings
		} else return NULL;
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));

	//THESE CODE COMMENTED IS NOT NEEDED 
	// if (!(p[tindex] & PTE_P))	//if pte not exist
	// 	if (create) {
	// 		struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
}
```
boot_map_region, the comments is between codes:
```c
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
	}
}
```
page_lookup, the comments is between codes:
```c
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
	if (pte_store)
		*pte_store = pte;	//found and set
	return pa2page(PTE_ADDR(*pte));		
}
```
page_remove, the comments is between codes:
```c
void
page_remove(pde_t *pgdir, void *va)
{
	pte_t *pte;
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
	if (!pg || !(*pte & PTE_P)) return;	//page not exist
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
	page_decref(pg);
//   - The pg table entry corresponding to 'va' should be set to 0.
	*pte = 0;
//   - The TLB must be invalidated if you remove an entry from
//     the page table.
	tlb_invalidate(pgdir, va);
}
```
page_insert, be aware of how corner-case is avoided, the comments is between codes:
```c
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
	if (!pte) 	//page table not allocated
		return -E_NO_MEM;	
	//increase ref count beforehand to avoid the corner case that pp is freed before it is inserted.
	pp->pp_ref++;	
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
		page_remove(pgdir, va);
	*pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
```


Part 3: Kernel Address Space
===
Exercise 5.
---
```
Fill in the missing code in mem_init() after the call to check_page().
```
UPAGES:
```c
	boot_map_region(kern_pgdir, 
		UPAGES, 
		PTSIZE, 
		PADDR(pages), 
		PTE_U);
```
BOOTSTACK:
```c
	boot_map_region(kern_pgdir, 
		KSTACKTOP-KSTKSIZE, 
		KSTKSIZE, 
		PADDR(bootstack), 
		PTE_W);
```
KERNBASE, be aware that -KERNBASE is 0x10000000 positive:
```
	boot_map_region(kern_pgdir, 
		KERNBASE, 
		-KERNBASE, 
		0, 
		PTE_W);
```

Questions
---



Challenges
---















