/* data section for buff and global vars */    
    .data
    .align 2
buff: .skip 100
    .align 2
inchar: .skip 3
    .align 2
outchar: .skip 3
    .align 2
nchars:
    .word nchars
    .align 2
nlines:
    .word nlines
    .align 2
nwords:
    .word nwords
    .align 2
nsubs:
    .word nsubs


/* formatting strings */
    .text
    .align 2
summary:
    .asciz "Summary: \n %d characters\n %d lines\n %d words\n"
    .align 2
summary2:
    .asciz " %d substitutions\n"
    .align 2
test:
    .asciz "%d\n"


/* get_trans function - stores letters to translate
    in inchar and outchar
    1 Arg - buffP
    returns int: 0 if error and 1 if correct */
    .text
    .align 2
get_trans:
    push {fp, lr}   @setup stack frame
    add fp, sp, #4
    sub sp, sp, #8 @1 local vars
    @[fp, #-8] holds buffP

    str r0, [fp, #-8]

    ldr r0, [fp, #-8]  @check if index 1 == ' '
    mov r1, #1
    bl get_byte
    cmp r0, #' '
    bne double

    ldr r0, [fp, #-8]  @check if index 0 != 0
    mov r1, #0
    bl get_byte
    cmp r0, #0
    beq if1

    ldr r0, [fp, #-8]  @check if index 2 != 0
    mov r1, #2
    bl get_byte
    cmp r0, #0
    beq if1

    ldr r0, [fp, #-8]  @check if index 3 == \n
    mov r1, #3
    bl get_byte
    cmp r0, #'\n'
    bne if1

    ldr r0, [fp, #-8]  @check if index 4 == 0
    mov r1, #4
    bl get_byte
    cmp r0, #0
    beq else1
double:
    ldr r0, [fp, #-8]  @check if index 0 != 0
    mov r1, #0
    bl get_byte
    cmp r0, #0
    beq if1

    ldr r0, [fp, #-8]  @check if index 1 != 0
    mov r1, #1
    bl get_byte
    cmp r0, #0
    beq if1

    ldr r0, [fp, #-8]  @check if index 2 == ' '
    mov r1, #2
    bl get_byte
    cmp r0, #' '
    bne if1

    ldr r0, [fp, #-8]  @check if index 3 != 0
    mov r1, #3
    bl get_byte
    cmp r0, #0
    beq if1

    ldr r0, [fp, #-8]  @check if index 5 == \n
    mov r1, #5
    bl get_byte
    cmp r0, #'\n'
    bne if1

    ldr r0, [fp, #-8]  @check if index 6 == 0
    mov r1, #6
    bl get_byte
    cmp r0, #0
    beq else1_2
if1:
    mov r0, #0   @return 0 if any of above are true
    b end1
else1:
    ldr r0, [fp, #-8]   @put index 0 in inchar
    mov r1, #0
    bl get_byte
    mov r2, r0
    ldr r0, incharP
    mov r1, #0
    bl put_byte

    ldr r0, [fp, #-8]   @put index 2 in outchar
    mov r1, #2
    bl get_byte
    mov r2, r0
    ldr r0, outcharP
    mov r1, #0
    bl put_byte

    ldr r0, incharP  @place null bytes at the end of inchar and outchar
    mov r1, #1
    mov r2, #0
    bl put_byte
    ldr r0, outcharP
    mov r1, #1
    mov r2, #0
    bl put_byte
    mov r0, #1   @return 1
    b end1
else1_2:    @for if it is a double
    ldr r0, [fp, #-8]   @put index 0 and 1 in inchar
    mov r1, #0
    bl get_byte
    mov r2, r0
    ldr r0, incharP
    mov r1, #0
    bl put_byte
    ldr r0, [fp, #-8]
    mov r1, #1
    bl get_byte
    mov r2, r0
    ldr r0, incharP
    mov r1, #1
    bl put_byte

    ldr r0, [fp, #-8]   @put index 3 and 4 in outchar
    mov r1, #3
    bl get_byte
    mov r2, r0
    ldr r0, outcharP
    mov r1, #0
    bl put_byte
    ldr r0, [fp, #-8]
    mov r1, #4
    bl get_byte
    mov r2, r0
    ldr r0, outcharP
    mov r1, #1
    bl put_byte

    ldr r0, incharP  @place null bytes at the end of inchar and outchar
    mov r1, #2
    mov r2, #0
    bl put_byte
    ldr r0, outcharP
    mov r1, #2
    mov r2, #0
    bl put_byte

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
    sub sp, sp, #16 @ 4 local var
    @[fp, #-8] holds buffP
    @[fp, #-12] holds i, accumulator
    @[fp, #-16] holds in_word boolean var
    @[fp, #-20] holds is_double indicator (0 = single, 1 and 2 for double cycle)

    str r0, [fp, #-8]

    mov r0, #0
    str r0, [fp, #-12]   @i = 0

    mov r0, #0
    str r0, [fp, #-16]   @in_word = 0

    mov r0, #0
    str r0, [fp, #-20]  @is_double = 0

    ldr r0, incharP   @initialize r4 and r5 as the first trans char
    mov r1, #0
    bl get_byte
    mov r4, r0
    ldr r0, outcharP
    mov r1, #0
    bl get_byte
    mov r5, r0

    ldr r0, incharP  @check if there are two inchars or not
    mov r1, #1
    bl get_byte
    mov r1, #0
    cmp r0, r1
    beq guard2
    mov r1, #2
    str r1, [fp, #-20]
    b guard2
round1:
    ldr r0, incharP   @change to second trans if double
    mov r1, #0
    bl get_byte
    mov r4, r0
    ldr r0, outcharP
    mov r1, #0
    bl get_byte
    mov r5, r0
    mov r1, #2   @ change is_double to 2 to continue cycle
    str r1, [fp, #-20]
    b guard2
round2:
    ldr r0, incharP   @change to second trans if double
    mov r1, #1
    bl get_byte
    mov r4, r0
    ldr r0, outcharP
    mov r1, #1
    bl get_byte
    mov r5, r0
    mov r1, #1   @ change is_double to 1 to continue cycle
    str r1, [fp, #-20]
guard2:
    ldr r0, [fp, #-8]
    ldr r1, [fp, #-12]   @if reaches null byte: end
    bl get_byte
    cmp r0, #0
    beq end2

    ldr r0, [fp, #-8]
    ldr r1, [fp, #-12]   @if i == r4
    bl get_byte
    cmp r0, r4
    bne if2_1
    ldr r0, [fp, #-8]
    ldr r1, [fp, #-12]   @putbyte r5 at index i
    mov r2, r5
    bl put_byte
    ldr r0, nsubsP   @nsubs + 1
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]
if2_1:
    ldr r0, [fp, #-8]  @if byte is newline nlines + 1
    ldr r1, [fp, #-12]
    bl get_byte
    cmp r0, #'\n'
    bne if2_2
    
    ldr r0, [fp, #-20]   @to not double count newlines during double
    mov r1, #1
    cmp r0, r1
    beq if2_2
    ldr r0, nlinesP   @nlines + 1
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]
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
    ldr r0, nwordsP   @nwords + 1
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]
    mov r0, #1
    str r0, [fp, #-16]  @in_word == 1
else2:
    ldr r0, [fp, #-20]  @check is_double for whether to loop back
    mov r1, #2
    cmp r0, r1
    beq round2
    ldr r1, [fp, #-12]   @add 1 to i
    add r1, r1, #1
    str r1, [fp, #-12]      

    ldr r0, ncharsP   @add 1 to nchars
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]
    ldr r0, [fp, #-20]   @check if in double loop or not
    mov r1, #1
    cmp r0, r1
    beq round1    @if in double loop and make it to here go back to round1
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

    ldr r0, ncharsP   @print 1st part of summary
    ldr r1, [r0]
    ldr r0, nlinesP
    ldr r2, [r0]
    ldr r0, nwordsP
    ldr r3, [r0]
    ldr r0, summaryP
    bl printf

    ldr r0, nsubsP  @print second part of summary
    ldr r1, [r0]
    ldr r0, summary2P
    bl printf

    sub sp, fp, #4
    pop {fp, pc}

/* string pointer for summary */
    .align 2
summaryP: .word summary
summary2P: .word summary2

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
/*TEST*/
    /*ldr r0, incharP
    bl printf
    ldr r0, outcharP
    bl printf*/

    ldr r0, ncharsP  @initialize nchars to 0
    mov r1, #0
    str r1, [r0]
    ldr r0, nlinesP  @initialize nlines to 0
    mov r1, #0
    str r1, [r0]
    ldr r0, nwordsP  @initialize nwords to 0
    mov r1, #0
    str r1, [r0]
    ldr r0, nsubsP  @initialize nsubs to 0
    mov r1, #0
    str r1, [r0]

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
ncharsP: .word nchars
nlinesP: .word nlines
nwordsP: .word nwords
nsubsP: .word nsubs
incharP: .word inchar
outcharP: .word outchar
testP: .word test



