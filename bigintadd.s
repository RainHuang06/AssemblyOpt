// bigintadd.s
// Authors: Matthew Okechukwu and Rain Huang

// enum {FALSE, TRUE};
.equ FALSE, 0
.equ TRUE, 1

.section .rodata

.section .data

.section .bss

.section .text

.equ BIGINTADD_STACK_BYTECOUNT, 80

// Local Variable Stack Offsets:
    // BigInt_larger
    .equ lLarger, 8

    // BigInt_add
    .equ ulCarry, 16
    .equ ulSum, 24 
    .equ lIndex, 32
    .equ lSumLength, 40 

// Parameter stack offsets:
    // BigInt_larger
    .equ lLength1, 48 
    .equ lLength2, 56

    // BigInt_add
    .equ oAddend1, 64
    .equ oAddend2, 72
    .equ oSum, 80

BigInt_larger:
// prologue
sub sp, sp, BIGINTADD_STACK_BYTECOUNT
str x30, [sp]
 
// Store parameters in registers
        mov     lLength1, x0
        mov     lLength2, x1

// long lLarger;

// if (lLength2 > lLength1) goto l2Larger;
ldr x0, [sp, lLength1]
ldr x1, [sp, lLength2]
cmp x0, x1
bgt l2Larger





BigInt_add:










