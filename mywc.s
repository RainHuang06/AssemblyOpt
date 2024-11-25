// mywc.s
// Authors: Rain Huang and Matthew Okechukwu

.equ FALSE, 0
.equ TRUE, 1

.section .rodata
toPrintString:
 .string "%7ld %7ld %7ld\n"

.section .data
iInWord:
    .word FALSE

lLineCount:
    .quad 0

lWordCount:
    .quad 0

lCharCount:
    .quad 0

.section .bss
iChar:
    .skip 4

.section .text

    .equ MAIN_STACK_BYTECOUNT, 16
    .global main
    .equ EOF, -1

main:
// prologue: To create main stack frame, and return store address
    sub sp, sp, MAIN_STACK_BYTECOUNT
    str x30, [sp]

charIntakeLoop:
// if(((iChar = getchar()) == EOF)) goto charIntakeLoopEnd;

        bl getchar
        cmp w0, EOF
        beq charIntakeLoopEnd
        adr x1, iChar
        str w0, [x1]

// lCharCount++;

        adr     x1, lCharCount
        ldr     x2, [x1]
        add     x2, x2, 1
        str     x2, [x1]

// if (!isspace(iChar)) goto else1;
 
        adr x1, iChar
        ldr w0, [x1]
        bl isspace
        cmp w0, FALSE
        beq else1

// if (!iInWord) goto endif1;

        adr x1, iInWord
        ldr w0, [x1]
        cmp w0, FALSE
        beq endif1

// lWordCount++;
        adr     x1, lWordCount
        ldr     x2, [x1]
        add     x2, x2, 1
        str     x2, [x1]

// iInWord = FALSE;
        adr x1, iInWord
        mov w0, FALSE
        str w0, [x1]

// goto endif1;
        b endif1

else1:
// if (iInWord) goto endif1;
    adr x3, iInWord
    ldr w2, [x3]
    cmp w2, TRUE
    beq endif1

// iInWord = TRUE;
        adr x1, iInWord
        mov w0, TRUE
        str w0, [x1]

endif1:
// if (iChar != '\n')

    adr x1, iChar
    ldr w0, [x1]
    cmp w0, '\n'
    bne charIntakeLoop

// lLineCount++;
        adr     x1, lLineCount
        ldr     x2, [x1]
        add     x2, x2, 1
        str     x2, [x1]

// goto charIntakeLoop;
        b charIntakeLoop

charIntakeLoopEnd:
// if (!iInWord) goto endif2;
    adr x3, iInWord
    ldr w2, [x3]
    cmp w2, FALSE
    beq endif2

// lWordCount++;
        adr     x1, lWordCount
        ldr     x2, [x1]
        add     x2, x2, 1
        str     x2, [x1]

endif2:
// printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        adr x0, toPrintString
        adr x1, lLineCount
        ldr x1, [x1]
        adr x2, lWordCount
        ldr x2, [x2]
        adr x3, lCharCount
        ldr x3, [x3]
        bl printf

// Epilogue: return 0;
        mov w0, 0
        ldr x30, [sp]
        add sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size main, (.-main)
    

 

    




