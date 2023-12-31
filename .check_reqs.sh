#!/bin/bash

MACOS_TOOLCHAIN="\
PROBLEM:
Need i386 ELF GNU toolchain, GCC, and GDB on macOS.
  $ brew install x86_64-elf-gcc x86_64-elf-gdb x86_64-elf-binutils
\n"

MACOS_GSED="\
PROBLEM:
Need gsed on macOS.
  $ brew install gnu-sed
\n"

LINUX_TOOLCHAIN="\
PROBLEM:
Need GNU binutils.
  $ sudo apt-get install binutils
\n"

UNSUPPORTED="\
PROBLEM:
Unsupported OS.
\n"

GCC_OUTDATED="\
PROBLEM:
Need GCC 3.3 or newer.
\n"

QEMU_NOT_FOUND="\
PROBLEM:
Need qemu for i386.
  $ sudo apt-get install qemu
  (or, using Homebrew)
  $ brew install qemu
\n"

PERL_OUTDATED="\
PROBLEM:
Need minimum of Perl 5.6.1.
"

{
    STATUS=0

    OS=$(uname -s)
    if [[ $OS = "Darwin" ]]; then
        which x86_64-elf-gcc > /dev/null; GCC=$?
        which x86_64-elf-gdb > /dev/null; GDB=$?
        which x86_64-elf-objcopy > /dev/null; OBJCOPY=$?
        which gsed > /dev/null; GSED=$?;
        if [[ $GCC != 0 || $GDB != 0 || $OBJCOPY != 0 ]]; then
            printf "$MACOS_TOOLCHAIN"
            STATUS=1
        fi
        if [[ $GSED != 0 ]]; then
            printf "$MACOS_GSED"
            STATUS=1
        fi
    elif [[ $OS = "Linux" ]]; then
        # Check binutils
        which ld > /dev/null; LD=$?
        which objcopy > /dev/null; OBJCOPY=$?
        if [[ $LD != 0 || $OBJCOPY != 0 ]]; then
            printf "$LINUX_TOOLCHAIN"
            STATUS=1
        fi

        # Check gcc
        GCCVER=$(gcc-9 -dumpversion)
        if [[ $? != 0 ]]; then
            printf "$GCC_OUTDATED"
            STATUS=1
        else
            MAJ=$(echo $GCCVER | cut -d '.' -f 1)
            MIN=$(echo $GCCVER | cut -d '.' -f 2)
            if [[ ($MAJ == 3 && $MIN < 3) || ($MAJ < 3) ]]; then
                printf "$GCC_OUTDATED"
                STATUS=1
            fi
        fi
    else
        printf "$UNSUPPORTED"
        exit 1
    fi

    # Check qemu-system-i386
    which qemu-system-i386 > /dev/null
    if [[ $? != 0 ]]; then
        printf "$QEMU_NOT_FOUND"
        STATUS=1
    fi

    # Check Perl
    $(perl -e 'use 5.6.1')
    if [[ $? != 0 ]]; then
        printf "$PERL_OUTDATED"
        STATUS=1
    fi

    exit $STATUS
} 2> /dev/null
