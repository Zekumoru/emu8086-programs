; Float Multiplication
; \desc Program to multiply two floating point numbers.

name "float_multiplication"

include "emu8086.inc"

org 100h

.data
    a dw ?
    b dw ?
    
    ; get_float variables
    dpFlag db ?     ; flag to check if decimal point is inputted
    zrFlag db ?     ; flag to check if first digit is 0
    input dw 0
    temp dw ?
    multiplier dw ?

.code
    ; get two float numbers from user
    print "Enter first number: "
    call get_float
    mov a, ax
    
    print "Enter second number: "
    call get_float
    mov b, ax
    
    printn
    
    ; print result
    mov ax, a
    call print_float
    
    print " * "
    
    mov ax, b
    call print_float
    
    mov ax, a
    mov bx, b
    call fmul
    
    print " = "
    call print_float
    
    printn
        
    .exit                   
 
; ===========================================================
; \brief Multiplies two fixed-point 2-decimal places floating values.
; \param ax The multiplicand.
; \param bx The multiplier.
; \return ax The product or multiplicand*multiplier.
; \warning It sets ax to 0FFFFh if the product is too large.
; \note 0FFFFh is the convention to denote Infinity
fmul proc
    mul bx   
    mov bx, 100
    cmp dx, bx
    jg NO_DIVIDE
    div bx
    jmp DONE_DIVIDE
NO_DIVIDE:
    mov ax, 0FFFFh
DONE_DIVIDE:
    ret    
fmul endp
; ===========================================================

; ===========================================================
; \brief Gets a float from the user.
; \return ax The float entered by the user. 
get_float proc
    mov dpFlag, 0
    mov zrFlag, 0
    mov cl, 0       ; initialize decimal places counter
    mov ch, 0       ; initialize character stack counter
START_INPUT:
    ; convert stack to float
    mov temp, cx
    mov input, 0
    mov multiplier, 0

STACK_LOOP:
    cmp ch, 0
    je END_STACK_LOOP

    pop ax          ; get character from stack
    mov [di], ax
    inc di
    dec ch

    cmp ax, 46      ; check if character is decimal point
    je STACK_LOOP   ; ignore decimal point character

    sub ax, 48      ; convert digit character to number
    mov bx, 100
    mul bx          ; digit * 100
    
    ; handle decimal values part
    push cx
DECIMAL_VALUES_LOOP:
    cmp cl, 0
    je END_DECIMAL_VALUES_LOOP
    mov bx, 10
    mov dx, 0
    div bx
    dec cl
    jmp DECIMAL_VALUES_LOOP
END_DECIMAL_VALUES_LOOP:
    pop cx
    
    ; prevent cl turning to 0FFh
    cmp cl, 0
    je DONT_DEC_CL
    dec cl
DONT_DEC_CL:

    cmp cl, 0
    jne IGNORE_WHOLE_NUMBERS  ; ignore whole numbers if there are still decimal numbers
    
    ; handle whole numbers part
    push cx
    mov cx, 1
WHOLE_NUMBERS_LOOP:
    cmp cx, multiplier
    jge END_WHOLE_NUMBERS_LOOP
    mov bx, 10
    mov dx, 0
    mul bx
    inc cx
    jmp WHOLE_NUMBERS_LOOP
END_WHOLE_NUMBERS_LOOP:    
    pop cx
    inc multiplier

IGNORE_WHOLE_NUMBERS:
    add input, ax

    jmp STACK_LOOP
END_STACK_LOOP:
    mov cx, temp

    ; return previous stack
COPY_STACK_LOOP:
    cmp ch, 0
    je END_COPY_STACK_LOOP
    dec di
    mov ah, 0
    mov al, [di]
    push ax
    dec ch
    jmp COPY_STACK_LOOP
END_COPY_STACK_LOOP:
    mov cx, temp

    ; get character input
    mov ah, 7
    int 21h
    
    ; handle enter input
    cmp al, 10
    je END_INPUT
    cmp al, 13
    je END_INPUT
    
    ; handle backspace input
    cmp al, 8
    jne NO_BACKSPACE
    cmp ch, 0
    je NO_BACKSPACE
    
    pop dx          ; get char from stack
    
    cmp dx, 46      ; check if char is decimal point char
    jne NOT_POINT_CHAR
    mov dpFlag, 0       ; set dpFlag flag that decimal point is removed
NOT_POINT_CHAR:

    cmp dpFlag, 1       ; check if dpFlag is still set then decrement decimal places counter
    jne dpFlag_NOT_SET_ANYMORE
    dec cl
dpFlag_NOT_SET_ANYMORE:
   
    dec ch
    
    cmp ch, 0       ; check if counter is zero
    jne NOT_COUNTER_ZERO
    mov zrFlag, 0       ; reset first digit zero flag
NOT_COUNTER_ZERO:
    
    mov ah, 2       ; start backspacing one char
    mov dl, 8
    int 21h
    mov dl, 0
    int 21h         ; print empty character
    mov dl, 8
    int 21h         ; print backspace
NO_BACKSPACE:
    
    ; Check if point character
    cmp al, 46
    jne NO_POINT_CHAR
    cmp dpFlag, 1
    je NO_POINT_CHAR
    mov ah, 0
    push ax         ; push point char to stack
    mov dpFlag, 1       ; set flag that a decimal point is inserted
    inc ch
    
    jmp PRINT_CHAR
NO_POINT_CHAR:

    cmp zrFlag, 1       ; check if digit is zero
    jne zrFlag_NOT_SET
    cmp ch, 1       ; check if that zero is the first digit
    jne zrFlag_NOT_SET
    jmp START_INPUT ; jump to start to avoid 00, 04, etc. inputs
zrFlag_NOT_SET:
    
    ; check if digit character
    cmp al, 48
    jl NOT_DIGIT_CHAR
    cmp al, 57
    jg NOT_DIGIT_CHAR
    
    cmp cl, 2
    jge START_INPUT ; ignore any decimal places of more than 2
    
    cmp al, 48      ; check if first digit is zero
    jne NOT_ZERO_FIRST
    cmp ch, 0
    jne NOT_ZERO_FIRST
    mov zrFlag, 1       ; set flag that first digit is zero
NOT_ZERO_FIRST:
    
    cmp dpFlag, 1       ; check if decimal point flag is set
    jne dpFlag_NOT_SET
    inc cl
dpFlag_NOT_SET:
       
    mov ah, 0      
    push ax         ; push digit to stack
    inc ch

PRINT_CHAR:    
    mov dl, al
    mov ah, 2
    int 21h         ; print char
        
NOT_DIGIT_CHAR:    
    
    jmp START_INPUT
END_INPUT:
    
EMPTY_STACK_LOOP:
    cmp ch, 0
    je END_EMPTY_STACK_LOOP
    pop ax
    dec ch
    jmp EMPTY_STACK_LOOP
END_EMPTY_STACK_LOOP:
    
    mov ax, input
    printn
    ret
get_float endp
; ===========================================================
 
; ===========================================================
; \brief Prints fixed-point 2-decimal places floating values.
; \param ax The float to print.
; \note Prints "Inf" if ax is set to 0FFFFh
print_float proc
    cmp ax, 0FFFFh
    jne NOT_INFINITY
    print "Inf"
    ret
NOT_INFINITY:
    
    mov cx, 0   ; initialize digit counter
NUM_STACK_LOOP:
    cmp ax, 0
    je END_NUM_STACK_LOOP    
    mov bx, 10
    mov dx, 0
    div bx      ; get right-most digit to dx
    
    push dx     ; push to stack each digit
    inc cx      ; increment digit counter
    
    jmp NUM_STACK_LOOP
END_NUM_STACK_LOOP:

DECIMAL_LOOP:
    cmp cx, 2   ; if there are less than 3 digits then
                ; that means we need to populate it with
                ; zeroes until we have at least 3 digits
                ; because of numbers like 0.05
    jg END_DECIMAL_LOOP
    
    push 0      ; populate stack with zero
    inc cx      ; increment digit counter
    
    jmp DECIMAL_LOOP
END_DECIMAL_LOOP:    

PRINT_LOOP:
    cmp cx, 2
    jne NOT_DECIMAL_POINT
    mov dl, 46
    mov ah, 2
    int 21h     ; print decimal point when there are two
                ; digits left
NOT_DECIMAL_POINT:    
    pop dx
    add dx, 48  
    mov ah, 2
    int 21h     ; print digit
    loop PRINT_LOOP
    
    ret
print_float endp
; ===========================================================    

end
