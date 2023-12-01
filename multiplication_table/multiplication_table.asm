; Multiplication table
; \desc Program to print a multiplication table

name "multiplication_table"

include "emu8086.inc"

org 100h

.data
    num dw ?
    x db 0
    y db 0

.code 
    ; get input from user
    call get_num
    mov num, cx

    call clear_screen
      
    ; print header
    print "X"
    
    mov cl, 1
PRINT_HEADER_LOOP:
    cmp cl, b.num
    jg END_PRINT_HEADER_LOOP
    
    mov x, cl
    call move_cursor
    
    print "|"
    
    mov ah, 0
    mov al, cl
    call print_num
    inc cl

    jmp PRINT_HEADER_LOOP
END_PRINT_HEADER_LOOP:
    
    inc y
         
    ; print divider line
    mov cl, 0
PRINT_DIVIDER_LOOP:
    cmp cl, b.num
    jg END_PRINT_DIVIDER_LOOP
    
    mov x, cl
    call move_cursor
    
    print "-----"
    inc cl
    
    jmp PRINT_DIVIDER_LOOP
END_PRINT_DIVIDER_LOOP:         
    
    inc y
         
    ; print rows
    mov ch, 1   ; row number (not table coord)
PRINT_TABLE_LOOP:
    mov cl, 0   ; column number
    cmp ch, b.num
    jg END_PRINT_TABLE_LOOP

    mov x, cl
    call move_cursor
    
    ; print row number
    mov ah, 0
    mov al, ch
    call print_num
    
    inc cl
    mov x, cl
    call move_cursor
    
    ; start printing multiplication table row
PRINT_ROW_LOOP:
    cmp cl, b.num
    jg END_PRINT_ROW_LOOP
    print "|"
    mov ah, 0
    mov al, ch
    mov bl, cl
    mul bl
    ; print cell
    call print_num
    
    inc cl
    mov x, cl
    call move_cursor
    jmp PRINT_ROW_LOOP
END_PRINT_ROW_LOOP:
    
    inc ch
    inc y
    
    jmp PRINT_TABLE_LOOP
END_PRINT_TABLE_LOOP: 
    
    
    .exit

; ==========================================
; \brief Moves cursor to a table coordinate
; \note Set the 'x' and 'y' variables     
move_cursor proc
    ; get x position
    mov al, x
    mov bl, 6
    mul bl
    mov x, al   
    
    ; get x position
    mov al, y
    mov bl, 1
    mul bl
    mov y, al
    
    gotoxy x, y
    ret  
move_cursor endp    
; ==========================================     
                                            
; ==========================================     
; \brief Gets a number from 0-10 from the user.
; \return cx The input number.
get_num proc
INPUT_LOOP: 
    print "Enter number (max 10): "
    call scan_num
    printn
       
    cmp cx, 0
    jl WRONG_INPUT
    cmp cx, 10
    jg WRONG_INPUT
    
    jmp END_INPUT_LOOP

WRONG_INPUT:
    printn "Invalid input!"    
    jmp INPUT_LOOP
END_INPUT_LOOP:
    ret   
get_num endp                                                         
; ==========================================

; declarations for emu8086 functions
DEFINE_SCAN_NUM
DEFINE_CLEAR_SCREEN 
DEFINE_PRINT_NUM 
DEFINE_PRINT_NUM_UNS 

end
