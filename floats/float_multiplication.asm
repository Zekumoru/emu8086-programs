; Float Multiplication
; \desc Program to multiply two floating point numbers.

name "float_multiplication"

include "emu8086.inc"

org 100h

.data
    a dw 150
    b dw 150

.code
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

end
