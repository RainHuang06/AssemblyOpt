// bigintaddoptopt.s
// Authors: Matthew Okechukwu and Rain Huang

//Optimization list:
//Optimization 1: Replace ldr with ldp, and str to stp to reduce operation count
// enum {FALSE, TRUE};
.equ FALSE, 0
.equ TRUE, 1

// MAX_DIGITS
.equ MAX_DIGITS, 32768

.section .rodata

.section .data

.section .bss

.section .text

// Local Variable Stack Offsets:
    //.equ lLarger, 8
    lLarger .req x21 // Callee-saved
// Parameter stack offsets:
    //.equ lLength1, 24 
    //.equ lLength2, 16
    lLength1 .req x20 //Callee-saved
    lLength2 .req x19 //Callee-saved

.equ BIGINTLARGER_STACK_BYTECOUNT, 32

// * Return the larger of lLength1 and lLength2. *
// static long BigInt_larger(long lLength1, long lLength2)
BigInt_larger:
// prologue
sub sp, sp, BIGINTLARGER_STACK_BYTECOUNT
stp x30, x19, [sp]
stp x20, x21, [sp, 16]
// Move arguments into callee-saved registers
    mov lLength1, x0
    mov lLength2, x1
// long lLarger; 

// if (lLength2 > lLength1) goto l2Larger;
    cmp lLength2, lLength1
    bgt l2Larger

// lLarger = lLength1;
    mov lLarger, lLength1

//  goto returnLarger;
    b returnLarger

l2Larger:

// lLarger = lLength2;
    mov lLarger, lLength2

returnLarger:

// epilogue
// return lLarger;
    mov x0, lLarger 
    ldp x30, x19, [sp]
    ldp x20, x21, [sp, 16]
    add sp, sp, BIGINTLARGER_STACK_BYTECOUNT
    ret

    .size BigInt_larger, (. - BigInt_larger)



.equ BIGINTADD_STACK_BYTECOUNT, 64 
.global BigInt_add

// * Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
//  distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
//  overflow occurred, and 1 (TRUE) otherwise. *
// int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2, BigInt_T oSum)

BigInt_add:


// Parameter stack offsets:
    //.equ oAddend1, 56 
    oAddend1 .req x25
    oAddend2 .req x24
    oSum .req x23

// Local Variable Stack Offsets:
    ulCarry .req x22 
    ulSum .req x21
    lIndex .req x20
    lSumLength .req x19

// Struct Offsets:
    .equ lLength, 0
    .equ aulDigits, 8


// prologue
    sub sp, sp, BIGINTADD_STACK_BYTECOUNT
    stp x30, x19, [sp]
    stp x22, x23, [sp, 32]
    mov oSum, x2
    stp x24, x25, [sp, 48]
    mov oAddend1, x0
    mov oAddend2, x1
    stp x20, x21, [sp, 16]
// Move arguments into registers



// * Determine the larger length. *
// lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr x0, [oAddend1, lLength]
    ldr x1, [oAddend2, lLength]
    bl BigInt_larger
    mov lSumLength, x0

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

// ulCarry = 0;
    mov ulCarry, 0

// lIndex = 0;
    mov lIndex, 0

// *for (lIndex = 0; lIndex < lSumLength; lIndex++)*

loopStart:

// if(lIndex >= lSumLength) goto endOfLoop;

    cmp lIndex, lSumLength
    bge endOfLoop

// ulSum = ulCarry;
    mov ulSum, ulCarry

// ulCarry = 0;
    mov ulCarry, 0

// ulSum += oAddend1->aulDigits[lIndex];
    add x1, oAddend1, aulDigits
    ldr x1, [x1, lIndex, lsl 3]
    add ulSum, ulSum, x1

// if (ulSum >= oAddend1->aulDigits[lIndex]) goto carry1;
// x0 still has ulSum, x1 has aulDigits 
    cmp ulSum, x1
    bhs carry1

// ulCarry = 1;
    mov ulCarry, 1

carry1:

// ulSum += oAddend2->aulDigits[lIndex];
    add x1, oAddend2, aulDigits
    ldr x1, [x1, lIndex, lsl 3]
    add ulSum, ulSum, x1

// if (ulSum >= oAddend2->aulDigits[lIndex]) goto carry2;
// x0 still has ulSum, x1 has aulDigits 
    cmp ulSum, x1
    bhs carry2

// ulCarry = 1;
    mov ulCarry, 1

carry2:

// oSum->aulDigits[lIndex] = ulSum;
    add x1, oSum, aulDigits
    str ulSum, [x1, lIndex, lsl 3]

// lIndex++;
    add lIndex, lIndex, 1

// goto loopStart;
    b loopStart

endOfLoop:

// * Check for a carry out of the last "column" of the addition. *
// if (ulCarry != 1) goto noCarry;
    cmp ulCarry, 1
    bne noCarry

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





































   






 








