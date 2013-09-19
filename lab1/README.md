Report for lab1
====================

Installing gcc in Mac OS X
---------------------
Using brew to install gmp, mpfr, libmpc before configuring gcc:
  brew install gmp
  brew install mpfr
  brew install libmpc
build outside of the source tree of gcc:
  mkdir build 
  cd build
  ../configure --target=i386-jos-elf --disable-nls --without-headers --with-newlib --disable-threads --disable-shared --disable-libmudflap --disable-libssp

