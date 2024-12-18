// bigintadd.s
// Authors: Matthew Okechukwu and Rain Huang

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
    .equ lLarger, 8

// Parameter stack offsets:
    .equ lLength1, 24 
    .equ lLength2, 16

.equ BIGINTLARGER_STACK_BYTECOUNT, 32

// * Return the larger of lLength1 and lLength2. *
// static long BigInt_larger(long lLength1, long lLength2)
BigInt_larger:
// prologue
sub sp, sp, BIGINTLARGER_STACK_BYTECOUNT
str x30, [sp]
 
// Store arguments into stack
    str x0, [sp, lLength1]
    str x1, [sp, lLength2]

// long lLarger; 

// if (lLength2 > lLength1) goto l2Larger;
    ldr x0, [sp, lLength1]
    ldr x1, [sp, lLength2]
    cmp x1, x0
    bgt l2Larger

// lLarger = lLength1;
    ldr x0, [sp, lLength1]
    str x0, [sp, lLarger]

//  goto returnLarger;
    b returnLarger

l2Larger:

// lLarger = lLength2;
    ldr x0, [sp, lLength2]
    str x0, [sp, lLarger]

returnLarger:

// epilogue
// return lLarger;
    ldr x0, [sp, lLarger]
    ldr x30, [sp]
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
    .equ oAddend1, 56 
    .equ oAddend2, 48
    .equ oSum, 40

// Local Variable Stack Offsets:
    .equ ulCarry, 32 
    .equ ulSum, 24
    .equ lIndex, 16
    .equ lSumLength, 8

// Struct Offsets:
    .equ lLength, 0
    .equ aulDigits, 8


// prologue
sub sp, sp, BIGINTADD_STACK_BYTECOUNT
str x30, [sp]

// Store arguments into stack
    str x0, [sp, oAddend1]
    str x1, [sp, oAddend2]
    str x2, [sp, oSum]

// * Determine the larger length. *
// lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr x0, [sp, oAddend1]
    ldr x0, [x0, lLength]
    ldr x1, [sp, oAddend2]
    ldr x1, [x1, lLength]
    bl BigInt_larger
    str x0, [sp, lSumLength]

// * Clear oSum's array if necessary. *
// if (oSum->lLength <= lSumLength) goto noMemset;
    ldr x0, [sp, oSum]
    ldr x0, [x0, lLength]
    ldr x1, [sp, lSumLength]
    cmp x0, x1
    ble noMemset

// memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    ldr x0, [sp, oSum]
    add x0, x0, aulDigits
    mov w1, 0
    mov x2, MAX_DIGITS
    lsl x2, x2, 3
    bl memset

noMemset:

// ulCarry = 0;
    str xzr, [sp, ulCarry]

// lIndex = 0;
    str xzr, [sp, lIndex]

// *for (lIndex = 0; lIndex < lSumLength; lIndex++)*

loopStart:

// if(lIndex >= lSumLength) goto endOfLoop;

    ldr x0, [sp, lIndex]
    ldr x1, [sp, lSumLength]
    cmp x0, x1
    bge endOfLoop

// ulSum = ulCarry;
    ldr x0, [sp, ulCarry]
    str x0, [sp, ulSum]

// ulCarry = 0;
    str xzr, [sp, ulCarry]

// ulSum += oAddend1->aulDigits[lIndex];
    ldr x0, [sp, ulSum]
    ldr x1, [sp, oAddend1]
    add x1, x1, aulDigits
    ldr x2, [sp, lIndex]
    ldr x1, [x1, x2, lsl 3]
    add x0, x0, x1
    str x0, [sp, ulSum]

// if (ulSum >= oAddend1->aulDigits[lIndex]) goto carry1;
// x0 still has ulSum, x1 has aulDigits 
    cmp x0, x1
    bhs carry1

// ulCarry = 1;
    mov x0, 1
    str x0, [sp, ulCarry]

carry1:

// ulSum += oAddend2->aulDigits[lIndex];
    ldr x0, [sp, ulSum]
    ldr x1, [sp, oAddend2]
    add x1, x1, aulDigits
    ldr x2, [sp, lIndex]
    ldr x1, [x1, x2, lsl 3]
    add x0, x0, x1
    str x0, [sp, ulSum]

// if (ulSum >= oAddend2->aulDigits[lIndex]) goto carry2;
// x0 still has ulSum, x1 has aulDigits 
    cmp x0, x1
    bhs carry2

// ulCarry = 1;
    mov x0, 1
    str x0, [sp, ulCarry]

carry2:

// oSum->aulDigits[lIndex] = ulSum;
    ldr x0, [sp, ulSum]
    ldr x1, [sp, oSum]
    add x1, x1, aulDigits
    ldr x2, [sp, lIndex]
    str x0, [x1, x2, lsl 3]

// lIndex++;
    ldr x0, [sp, lIndex]
    add x0, x0, 1
    str x0, [sp, lIndex]

// goto loopStart;
    b loopStart

endOfLoop:

// * Check for a carry out of the last "column" of the addition. *
// if (ulCarry != 1) goto noCarry;
    ldr x0, [sp, ulCarry]
    cmp x0, 1
    bne noCarry

// if (lSumLength != MAX_DIGITS) goto notMax;
    ldr x0, [sp, lSumLength]
    cmp x0, MAX_DIGITS
    bne notMax

// return FALSE;
    mov w0, FALSE
    b epilogue

notMax:

// oSum->aulDigits[lSumLength] = 1;
    ldr x0, [sp, oSum]
    add x0, x0, aulDigits
    ldr x1, [sp, lSumLength]
    mov x2, 1
    str x2, [x0, x1, lsl 3]

// lSumLength++
    ldr x0, [sp, lSumLength]
    add x0, x0, 1
    str x0, [sp, lSumLength]

noCarry:

// *Set the length of the sum.*
// oSum->lLength = lSumLength;
    ldr x0, [sp, oSum]
    ldr x1, [sp, lSumLength]
    str x1, [x0, lLength]

// return TRUE;
    mov w0, TRUE

epilogue:
    ldr x30, [sp]
    add sp, sp, BIGINTADD_STACK_BYTECOUNT
    ret

    .size BigInt_add, (. - BigInt_add)





































   






 








