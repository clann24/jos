Report for lab1
====================

Installing gcc in Mac OS X
---------------------
Use brew to install gmp, mpfr, libmpc before configuring gcc:
```shell
brew install gmp
brew install mpfr
brew install libmpc
```

Build gcc outside of the source tree:
```shell
mkdir build 
cd build
../configure --target=i386-jos-elf --disable-nls --without-headers --with-newlib --disable-threads --disable-shared --disable-libmudflap --disable-libssp
```

Installing qemu 
---

```shell
./configure --target-list="i386-softmmu" --disable-kvm --disable-sdl
make
make install
```

Configuring JOS
---
Append the following line to `conf/env.mk`: `QEMU=/usr/local/bin/qemu-system-x86_64`

Then type `make` and `make qemu`

Struggling with gdb
---
Type `gdb` then `boot` is loaded but `kernel` can't be recognized

```shell
>> gdb
.gdbinit:30: Error in sourced command file:
"lab/obj/kern/kernel": can't read symbols: File format not recognized.
```

Check the `.gdbinit` and get:
> If this fails, it's probably because your GDB doesn't support ELF.
> Look at the tools page at
>  http://pdos.csail.mit.edu/6.828/2009/tools.html
> for instructions on building GDB with ELF support.

Goto `/usr/local/bin` and find `i386-jos-elf-gdb` 
Use `i386-jos-elf-gdb` rather than `gdb`:

```shell
  Clann$ i386-jos-elf-gdb
GNU gdb 6.8
Copyright (C) 2008 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "--host=i386-apple-darwin12.4.0 --target=i386-jos-elf".
+ target remote localhost:25501
[New Thread 1]
The target architecture is assumed to be i386
0xf01004c0: push   %ebp
0xf01004c0 in ?? ()
+ symbol-file obj/kern/kernel
(gdb) 
```
Exercise 3
---

>At what point does the processor start executing 32-bit code? What exactly causes the switch from 16- to 32-bit mode?

The `movl %eax, %cr0` causes the switch from 16- to 32-bit mode in the `boot.S`:
```assembly
  lgdt    gdtdesc
  movl    %cr0, %eax
  orl     $CR0_PE_ON, %eax
  movl    %eax, %cr0
  ljmp    $PROT_MODE_CSEG, $protcseg
```


>What is the last instruction of the boot loader executed, and what is the first instruction of the kernel it just loaded?

In `main.c`, it's
```c
  ((void (*)(void)) (ELFHDR->e_entry))();
```
In `boot.asm`, it's
```asm
    7d63: ff 15 18 00 01 00     call   *0x10018
```

>Where is the first instruction of the kernel?

Since the last instruction the boot loader executed is 
`call *0x10018`, the first instruction of the kernel should be at `0x10018`.


>How does the boot loader decide how many sectors it must read in order to fetch the entire kernel from disk? Where does it find this information?



























