/* data section for buff */    
    .data
    .align 2
buff: .skip 100

/* formatting strings */
    .text
    .align 2
summary:
    .asciz "Summary: \n %d characters\n %d lines\n %d words\n"

/* get_trans function - stores letters to translate
    in r4 and r5
    1 Arg - buffP
    returns int: 0 if error and 1 if correct */
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
    cmp r0, #0
    beq if1

    ldr r0, [fp, #-8]  @check if index 1 == ' '
    mov r1, #1
    bl get_byte
    cmp r0, #' '
    bne if1

    ldr r0, [fp, #-8]  @check if index 2 != 0
    mov r1, #2
    bl get_byte
    cmp r0, #0
    beq if1

    ldr r0, [fp, #-8]  @check if index 3 == '\n'
    mov r1, #3
    bl get_byte
    cmp r0, #'\n'
    bne if1

    ldr r0, [fp, #-8]  @check if index 4 == 0
    mov r1, #4
    bl get_byte
    cmp r0, #0
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

/* translate function - replaces instances of 
    inchar with outchar
    1 Arg - buffP
    returns - buffP */
    .text
    .align 2
translate:
    push {fp, lr}   @setup stack frame
    add fp, sp, #4
    sub sp, sp, #16 @ 3 local var
    @[fp, #-8] holds buffP
    @[fp, #-12] holds i, accumulator var
    @[fp, #-16] holds in_word boolean var

    str r0, [fp, #-8]

    mov r0, #0
    str r0, [fp, #-12]   @i = 0

    mov r0, #0
    str r0, [fp, #-16]   @in_word = 0
guard2:
    ldr r0, [fp, #-8]
    ldr r1, [fp, #-12]   @if reaches null byte: end
    bl get_byte
    cmp r0, #0
    beq end2

    ldr r0, [fp, #-8]
    ldr r1, [fp, #-12]   @if i == inchar
    bl get_byte
    cmp r0, r4
    bne if2_1
    ldr r0, [fp, #-8]
    ldr r1, [fp, #-12]   @putbyte outchar at index i
    mov r2, r5
    bl put_byte
if2_1:
    ldr r0, [fp, #-8]  @if byte is newline nlines + 1
    ldr r1, [fp, #-12]
    bl get_byte
    cmp r0, #'\n'
    bne if2_2
    add r7, r7, #1
if2_2:
    ldr r0, [fp, #-8]   @if byte == ' '
    ldr r1, [fp, #-12]
    bl get_byte
    cmp r0, #' '
    bne if2_3
    ldr r0, [fp, #-16]   @if in_word == 1
    cmp r0, #1
    bne if2_3
    mov r0, #0
    str r0, [fp, #-16]   @in_word == 0
if2_3:
    ldr r0, [fp, #-8]  @if byte between 'a' and 'z'
    ldr r1, [fp, #-12]
    bl get_byte
    cmp r0, #'a'
    blt check_upper
    cmp r0, #'z'
    ble is_in_word
check_upper:
    ldr r0, [fp, #-8]   @if byte between 'A' and 'Z'
    ldr r1, [fp, #-12]
    bl get_byte
    cmp r0, #'A'
    blt else2
    cmp r0, #'Z'
    bgt else2
is_in_word:
    ldr r0, [fp, #-16]   @if in_word == 0
    cmp r0, #0
    bne else2
    add r8, r8, #1   @nwords + 1
    mov r0, #1
    str r0, [fp, #-16]  @in_word == 1
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

/* print_summary function - prints summary statement
    0 Args
    Return: None */
    .text
    .align 2
print_summary:
    push {fp, lr}
    add fp, sp, #4
    sub sp, sp, #8 @0 local vars

    ldr r0, summaryP
    mov r1, r6
    mov r2, r7
    mov r3, r8
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

    mov r6, #0   @initialize nchars to 0
    mov r7, #0   @initialize nlines to 0
    mov r8, #0   @initialize nwords to 0

while:
    ldr r0, buffP   @while the standard input line is not empty
    mov r1, #100
    bl get_line    @keep recieving standard inputs
    cmp r0, #2
    blt end_main
    ldr r0, buffP
    bl translate  @returns buffP
    bl printf     @print translated buffP
    b while
end_main:
    bl print_summary

    sub sp, fp, #4   @tear down stack frame
    pop {fp, pc}

/* pointer variables */
    .align 2
buffP: .word buff


