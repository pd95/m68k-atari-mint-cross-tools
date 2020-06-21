# m68k-atari-mint cross compiler scripts for macOS

This is a collection of `Makefile`s I'm using to build the m68k-atari-mint cross-compiler tools for macOS based on [Vincent Rivières cross-tools description](http://vincent.riviere.free.fr/soft/m68k-atari-mint/). The cross-compiler can be used to develop applications for the Atari ST and compatible systems. It is based on the works of the [FreeMiNT project](https://freemint.github.io)

The collection consists of the following:

**Host tools:**

- [GNU Binutils](https://www.gnu.org/software/binutils/): assembler and linker
- [MiNTbin](https://github.com/freemint/mintbin): supplemental MiNT specific tools for the GNU Binutils
- [GNU Compiler Collection (GCC)](https://gcc.gnu.org): the C and C++ compiler, which depends on the following libraries:
    - [GMP](https://gmplib.org) is the GNU Multiple Precision Arithmetic Library
    - [MPFR](https://www.mpfr.org) is the GNU Multiple-precision floating-point rounding library, which depends on GMP.
    - [MPC](http://www.multiprecision.org/mpc/) is the GNU Multiple-precision C library, which depends on GMP and MPFR.

**Target libraries and applications:**

- [MiNTLib](https://github.com/freemint/mintlib) which is the standard C library for FreeMiNT
- [PML](https://github.com/freemint/pml), portable math library for C programs for FreeMiNT
- [GEMlib](http://arnaud.bercegeay.free.fr/gemlib/) GEM bindings for writing GEM apps (=library to access AES and VDI layers)
- [CFLib](https://github.com/freemint/cflib) GEM utility library (used by QED)
- [QED](https://github.com/freemint/qed) GEM text editor, a good test application to check the cross-compiler


## Prerequisites
To use the Makefiles, you will have to install:

- [Xcode](https://developer.apple.com/xcode/) from Apple (download in the [AppStore](https://apps.apple.com/de/app/xcode/id497799835?mt=12))
- [Homebrew](https://brew.sh) (=the `brew` command)
- [GNU project tools](https://www.gnu.org/software/) autoconf, automake and libtool (using the command `brew install autoconf automake libtool`)

The scripts/Makefiles are automatically going to download the required sources and MiNT specific patches from [Vincents page](http://vincent.riviere.free.fr/soft/m68k-atari-mint/). For a few parts, I had to adjust the patches respectively write macOS specific patches.
Those are  stored in the `archive` folder.

GCC depends on three additional libraries (GMP, MPFR and MPC). As we want to statically link them to the compiler, they are also automatically built and stored in the `gcclibs` subfolder.

## Goal

The goal of this package/bundle of scripts is to have a single command to **build and install** the whole cross-compiler tools.

The tools are installed in the `/opt/cross-mint` folder. You need administration rights to create this directory on your system.

## Build
First, ensure that the `/opt/cross-mint` directory exists and is writable by your user.

To create the directory and take full ownership of it, you can use the following commands:

```bash
sudo mkdir -p /opt/cross-mint
sudo chown $USER /opt/cross-mint
```

To build and install the cross-compiler toolset, you should simply checkout this repository to a local folder and type `make`:

```bash
git clone https://github.com/pd95/m68k-atari-mint-cross-tools.git m68k-atari-mint
cd m68k-atari-mint
make
```

This will build and install the tool in `/opt/cross-mint` and will produce a "distribution package" in the `packages` directory.

## Usage

To use the cross-compiler, you will have to add the compiler binary/manual pages location to your search path:

```bash
export PATH=$PATH:/opt/cross-mint/bin
export MANPATH=$MANPATH:/opt/cross-mint/share/man
```

Here is a primitive TOS program

**hello.c**:

```c
#include <stdio.h>

int main(int argc, char* argv[])
{
    puts("Hello, world !");
    return 0;
}
```

It can be compiled with the command:

```bash
m68k-atari-mint-gcc hello.c -o hello.tos
```


Here is a simple AES test application:

**alert.c**:

```c
#include <gem.h>

int main()
{
    appl_init();
    form_alert( 1, "[1][Hi there!][[Hi!|B[ye!]" );
    appl_exit();
    return 0;
}
```

which can be compiled with

```bash
m68k-atari-mint-gcc alert.c -lgem -o alert.prg
```
