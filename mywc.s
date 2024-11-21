//mywc.s
//Authors: Rain Huang and Matthew Okechukwu
.section rodata
toPrintString:
    .string "%7ld %7ld %7ld\n"

.section .data
lLineCount:
    .quad 0
lWordCount:
    .quad 0
lCharCount:
    .quad 0
.section .bss
iChar:
    .skip 4
iInWord:
    .skip 4
.section .text
    .equ FALSE 0
    .equ TRUE 1
    .equ MAIN_STACK_BYTECOUNT 16
    .global main
main:
    sub sp, sp, MAIN_STACK_BYTECOUNT
charIntakeLoop:
        bl getchar
        cmp w0, -1
        beq charIntakeLoopEnd
        adr     x1, lCharCount
        ldr     x2, [x1]
        add     x2, x2, 1
        str     x2, [x1]
        cmp w0, ' '
        bne else1
        
else1:
    adr x3, iInWord
    ldr w2, [x3]
    cmp w2, FALSE
    beq endif1
    adr x4, lWordCount
    ldr x2, [x4]
    add x2, x2, 1
    b endif1


charIntakeLoopEnd:

endif1:
    str x2, [x4]
    str x3, FALSE