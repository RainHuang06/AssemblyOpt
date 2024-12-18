// bigintaddoptopt.s
// Authors: Matthew Okechukwu and Rain Huang

//Optimization list:
//Optimization 1: Replace ldr with ldp, and str to stp to reduce operation count
//Optimization 2: Created guarded loop to reduce iterations spent
//Optimization 3: Inlined BigInt_larger to increase performance
//Optimization 4: Used adcs and carry condition to no longer rely on Variable
//Optimization 5: Used csel in order to prevent branching

// enum {FALSE, TRUE};
.equ FALSE, 0
.equ TRUE, 1

//For overflow capabilities
.equ LONG_MAX, 0xFFFFFFFFFFFFFFFF

// MAX_DIGITS
.equ MAX_DIGITS, 32768

.section .rodata

.section .data

.section .bss

.section .text





.equ BIGINTADD_STACK_BYTECOUNT, 64 
.global BigInt_add

// * Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
//  distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
//  overflow occurred, and 1 (TRUE) otherwise. *
// int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2, BigInt_T oSum)

BigInt_add:


// Parameter callee-saved registers:
    oAddend1 .req x25
    oAddend2 .req x24
    oSum .req x23

// Local Variable callee-saved registers:
    ulCarry .req x22 
    ulSum .req x21
    lIndex .req x20
    lSumLength .req x19

// Struct Offsets:
    .equ lLength, 0
    .equ aulDigits, 8


// prologue
    //Set up stack while moving parameters into registers
    sub sp, sp, BIGINTADD_STACK_BYTECOUNT
    stp x30, x19, [sp]
    stp x22, x23, [sp, 32]
    mov oSum, x2
    stp x24, x25, [sp, 48]
    mov oAddend1, x0
    mov oAddend2, x1
    stp x20, x21, [sp, 16]


// * Determine the larger length. *
// lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr x0, [oAddend1, lLength]
    ldr x1, [oAddend2, lLength]
    cmp x1, x0
    csel lSumLength, x1, x0, HI // equivalent to lSumLength = x1 > x0 ? x1 : x0
// * Clear oSum's array if necessary. *
// if (oSum->lLength <= lSumLength) goto noMemset;
    ldr x0, [oSum, lLength]
    cmp x0, lSumLength
    ble noMemset

// memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    add x0, oSum, aulDigits
    mov w1, 0
    mov x2, MAX_DIGITS
    lsl x2, x2, 3
    bl memset

noMemset:


// lIndex = 0;
    mov lIndex, 0

// *for (lIndex = 0; lIndex < lSumLength; lIndex++)*
do:
    cmp lIndex, lSumLength
    bge endOfLoop
    mov x4, 0 //Reset register to prevent bugs
    mov x5, LONG_MAX //used to propagate carries
loopStart:
    adds x10, x4, x5 //If x4 has a carry from last loop, adding this to LONG_MAX produces a carry for adcs later.
    add x1, oAddend1, aulDigits
    ldr x1, [x1, lIndex, lsl 3]
    add x2, oAddend2, aulDigits
    ldr x2, [x2, lIndex, lsl 3]
    adcs ulSum, x1, x2
    adc x4, xzr, xzr //Storing carry for next iteration
// oSum->aulDigits[lIndex] = ulSum;
    add x3, oSum, aulDigits
    str ulSum, [x3, lIndex, lsl 3]

// lIndex++;
    add lIndex, lIndex, #1
// goto loopStart;
    cmp lIndex, lSumLength
    blt loopStart

endOfLoop:

// * Check for a carry out of the last "column" of the addition. *
    adds x10, x4, x5 //This instruction replicates the last addition, setting the flag
// if (ulCarry != 1) goto noCarry;
    bcc noCarry

// if (lSumLength != MAX_DIGITS) goto notMax;
    cmp lSumLength, MAX_DIGITS
    bne notMax

// return FALSE;
    mov w0, FALSE
    b epilogue

notMax:

// oSum->aulDigits[lSumLength] = 1;
    add x0, oSum, aulDigits
    mov x2, 1
    str x2, [x0, lSumLength, lsl 3]

// lSumLength++
    add lSumLength, lSumLength, 1

noCarry:

// *Set the length of the sum.*
// oSum->lLength = lSumLength;
    str lSumLength, [oSum, lLength]

// return TRUE;
    mov w0, TRUE

epilogue:
    ldp x30, x19, [sp]
    ldp x20, x21, [sp, 16]
    ldp x22, x23, [sp, 32]
    ldp x24, x25, [sp, 48]
    add sp, sp, BIGINTADD_STACK_BYTECOUNT
    ret

    .size BigInt_add, (. - BigInt_add)