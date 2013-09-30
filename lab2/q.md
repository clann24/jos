1
```c
enum {
	// For page_alloc, zero the returned physical page.
	ALLOC_ZERO = 1<<0,
};
```

2
mmu里的地址翻译和page_*有什么关系？

3
where is tlb_validate?

4
pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U;
why PTE_U?