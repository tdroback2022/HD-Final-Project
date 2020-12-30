/* data section for buff */    
    .data
    .align 2
buff: .skip 100

/* formatting strings */
    .text
    .align 2
prompt:
    .asciz "Enter two characters seperated by a space:\n"
    .align 2
char:
    .asciz "%c"
    .align 2
n:
    .asciz "\n"
    .align 2
summary:
    .asciz "Summary: \n"

/* get_trans function */
    .text
    .align 2
get_trans:
    push {fp, lr}   @setup stack frame
    add fp, sp, #4
    sub sp, sp, #8 @one local var
    @[fp, #-8] holds buffP

    str r0, [fp, #-8]

    ldr r0, [fp, #-8]  @check if index 1 == ' '
    mov r1, #1
    bl get_byte
    mov r1, #' '
    cmp r0, r1
    bne if

    ldr r0, [fp, #-8]  @check if index 3 == '\n'
    mov r1, #3
    bl get_byte
    mov r1, #'\n'
    cmp r0, r1
    bne if

    ldr r0, [fp, #-8]  @check if index 4 == 0
    mov r1, #4
    bl get_byte
    mov r1, #0
    cmp r0, r1
    beq else
if:
    mov r0, #0   @return 0 if any of above are true
    b end
else:
    ldr r0, [fp, #-8]   @put index 0 in r4
    mov r1, #0
    bl get_byte
    mov r4, r0

    ldr r0, [fp, #-8]   @put index 2 in r5
    mov r1, #2
    bl get_byte
    mov r5, r0

    mov r0, #1   @return 1
end:
    sub sp, fp, #4  @tear down stack frame
    pop {fp, pc}

/* translate function */
    .text
    .align 2
translate:
    push {fp, lr}   @setup stack frame
    add fp, sp, #4
    sub sp, sp, #8 @ 1 local var
    @[fp, #-8] holds buffP

    str r0, [fp, #-8]

    ldr r0, [fp, #-8]   @change the 7th byte to 'X'
    mov r1, #6
    mov r2, #'X'
    bl put_byte
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

    ldr r0, promptP   @print prompt
    bl printf

    ldr r0, buffP     @get_line reads input
    mov r1, #100
    bl get_line

    ldr r0, buffP     @get_trans gets index 0 and 2 from buff and stores in r4 and r5
    bl get_trans

    ldr r0, charP     @print r4 and r5 follwed by a newline
    mov r1, r4
    bl printf
    ldr r0, charP
    mov r1, r5
    bl printf
    ldr r0, nP
    bl printf

    ldr r0, buffP   @get a second line of input
    mov r1, #100
    bl get_line

    ldr r0, buffP
    bl translate  @returns buffP
    bl printf     @print translated buffP

    bl print_summary

    sub sp, fp, #4   @tear down stack frame
    pop {fp, pc}

/* pointer variables */
    .align 2
buffP: .word buff
promptP: .word prompt
charP: .word char
nP: .word n

