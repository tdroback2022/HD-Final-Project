/* data section for buff */    
    .data
    .align 2
buff: .skip 100

/* formatting strings */
    .text
    .align 2
summary:
    .asciz "Summary: \n %d characters\n"

/* get_trans function */
    .text
    .align 2
get_trans:
    push {fp, lr}   @setup stack frame
    add fp, sp, #4
    sub sp, sp, #8 @one local var
    @[fp, #-8] holds buffP

    str r0, [fp, #-8]

    ldr r0, [fp, #-8]  @check if index 0 != 0
    mov r1, #0
    bl get_byte
    mov r1, #0
    cmp r0, r1
    beq if1

    ldr r0, [fp, #-8]  @check if index 1 == ' '
    mov r1, #1
    bl get_byte
    mov r1, #' '
    cmp r0, r1
    bne if1

    ldr r0, [fp, #-8]  @check if index 2 != 0
    mov r1, #2
    bl get_byte
    mov r1, #0
    cmp r0, r1
    beq if1

    ldr r0, [fp, #-8]  @check if index 3 == '\n'
    mov r1, #3
    bl get_byte
    mov r1, #'\n'
    cmp r0, r1
    bne if1

    ldr r0, [fp, #-8]  @check if index 4 == 0
    mov r1, #4
    bl get_byte
    mov r1, #0
    cmp r0, r1
    beq else1
if1:
    mov r0, #0   @return 0 if any of above are true
    b end1
else1:
    ldr r0, [fp, #-8]   @put index 0 in r4
    mov r1, #0
    bl get_byte
    mov r4, r0

    ldr r0, [fp, #-8]   @put index 2 in r5
    mov r1, #2
    bl get_byte
    mov r5, r0

    mov r0, #1   @return 1
end1:
    sub sp, fp, #4  @tear down stack frame
    pop {fp, pc}

/* translate function */
    .text
    .align 2
translate:
    push {fp, lr}   @setup stack frame
    add fp, sp, #4
    sub sp, sp, #8 @ 2 local var
    @[fp, #-8] holds buffP
    @[fp, #-12] holds i, accumulator

    str r0, [fp, #-8]

    mov r0, #0
    str r0, [fp, #-12]   @i = 0
guard2:
    ldr r0, [fp, #-8]
    ldr r1, [fp, #-12]   @if reaches null byte: end
    bl get_byte
    mov r1, #0
    cmp r0, r1
    beq end2

    ldr r0, [fp, #-8]
    ldr r1, [fp, #-12]   @if i == r4
    bl get_byte
    cmp r0, r4
    bne else2
    ldr r0, [fp, #-8]
    ldr r1, [fp, #-12]   @putbyte r5 at index i
    mov r2, r5
    bl put_byte
else2:
    ldr r1, [fp, #-12]   @add 1 to i
    add r1, r1, #1
    str r1, [fp, #-12]
    add r6, r6, #1       @add 1 to nchars
    b guard2
end2:
    ldr r0, [fp, #-8]  @r0 holds buffP
    sub sp, fp, #4  @tear down stack frame
    pop {fp, pc}

/* print_summary function */
    .text
    .align 2
print_summary:
    push {fp, lr}
    add fp, sp, #4
    sub sp, sp, #8 @0 local vars

    ldr r0, summaryP
    mov r1, r6
    bl printf

    sub sp, fp, #4
    pop {fp, pc}

/* string pointer for summary */
    .align 2
summaryP: .word summary

/* main function */
    .text
    .align 2
    .global main
main:
    push {fp, lr}     @setup stack frame
    add fp, sp, #4
    sub sp, sp, #8

    ldr r0, buffP     @get_line reads input
    mov r1, #100
    bl get_line

    ldr r0, buffP     @get_trans gets index 0 and 2 from buff and stores in r4 and r5
    bl get_trans

    ldr r0, buffP   @get a second line of input
    mov r1, #100
    bl get_line

    mov r6, #0   @initialize nchars to 0

    ldr r0, buffP
    bl translate  @returns buffP
    bl printf     @print translated buffP

    bl print_summary

    sub sp, fp, #4   @tear down stack frame
    pop {fp, pc}

/* pointer variables */
    .align 2
buffP: .word buff


