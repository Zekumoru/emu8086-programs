; Print string
; \desc Program to get string from user and print it out

name "print_string"

include 'emu8086.inc'

org 100h

.data
    length db 100
    string db length dup(?)

.code                    
    call pthis       
    db "Enter string (max ", 0 ; print start of prompt
    
    mov al, length
    call print_num

    call pthis
    db " chars): ", 0   ; print rest of prompt
    
    mov dl, length
    call get_string     ; get string
    
    call pthis
    db 13, 10, 0        ; print new line
               
               
               
    mov ax, offset string
    call move_string_to_var ; move input string to 'string' variable
               
               
               
    call pthis
    db "You entered: ", 0   ; start message
    
    mov si, offset string  
    call print_string       ; print entered string
    
    call pthis
    db 13, 10, 0            ; print new line

    .exit

; \brief Function to move input string to a variable.
; \param ax The base address of the variable to put the input string into.
move_string_to_var proc
    mov cx, 0 
COPY_STRING_LOOP:  
    mov bx, di
    mov si, cx
    cmp b.[bx + si], 0      ; check if null terminator
    je END_COPY_STRING_LOOP
 
    mov dl, b.[bx + si]     ; get current char from ds to dl
    mov bx, ax              ; move var base address to bx
    add bx, cx              ; get current index's address of the variable
    mov [bx], dl            ; move char from dl to the string variable
 
    inc cx
        
    jmp COPY_STRING_LOOP
END_COPY_STRING_LOOP:
    ret
move_string_to_var endp    

; Declerations to use specific functions in the emu8086.inc library 
DEFINE_PTHIS
DEFINE_PRINT_STRING
DEFINE_GET_STRING
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS

end
