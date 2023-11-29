; Program to reverse a string

name 'reverse_string'

org 100h

.data
    string db "Hello world!", 0

.code    
    ; get string length to ch
    mov bx, offset string
    mov ch, 0
GET_STRING_LENGTH:
    cmp [bx], 0
    je END_GET_STRING_LENGTH
    
    inc ch
    inc bx
    
    jmp GET_STRING_LENGTH
END_GET_STRING_LENGTH:

    ; reverse string
    mov cl, 0
    dec ch
REVERSE_STRING:
    cmp cl, ch
    jge END_REVERSE_STRING
    
    mov bx, offset string
    add bl, ch
    mov dh, [bx] ; get right-most char to dh
    
    mov bx, offset string
    add bl, cl
    mov dl, [bx] ; get left-most char to dl
    
    mov bx, offset string
    add bl, ch
    mov [bx], dl ; copy dl (left-most char) to right-most char  
    
    mov bx, offset string
    add bl, cl
    mov [bx], dh ; copy dh (right-most char) to left-most char
    
    inc cl   
    dec ch

    jmp REVERSE_STRING
END_REVERSE_STRING:
    
    ; output string
    mov bx, offset string
PRINT_STRING: 
    mov dl, [bx]
    cmp dl, 0
    je END_PRINT_STRING
    
    mov ah, 2
    int 21h
    inc bx
    
    jmp PRINT_STRING    
END_PRINT_STRING:    
    .exit
   
end