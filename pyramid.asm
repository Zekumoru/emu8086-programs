; Print Pyramid
; \desc Program to print a pyramid on the screen

name "print_pyramid"
org 100h

.data
  height db ?
  prompt db "Enter height of the pyramid: $"
  newline db 10, 13, "$"

.code
  ; Ask user for pyramid's height
  lea dx, prompt
  mov ah, 9
  int 21h ; output prompt
  
  mov ah, 1
  int 21h ; get input
  sub al, 48
  mov height, al
  
  call printn
  
  mov bl, height
  call print_pyramid
  
  .exit

; =============================================================================
; \brief Function to print a new line 
printn proc
  lea dx, newline
  mov ah, 9
  int 21h
  ret   
printn endp
 
; =============================================================================
; \brief Function to print a pyramid based on height
; \param bl The height of the pyramid
print_pyramid proc
  mov cl, 0
START_PYRAMID_LOOP:
  cmp cl, bl
  je END_PYRAMID_LOOP
  
  ; dh contains how many spaces
  mov dh, bl
  sub dh, cl
  dec dh
  
  ; print left spaces
  mov ch, 0
START_LSPACES_LOOP:
  cmp ch, dh
  je END_LSPACES_LOOP
  
  mov ah, 2
  mov dl, ' '
  int 21h
  
  inc ch
  jmp START_LSPACES_LOOP
END_LSPACES_LOOP:
 
  ; print pyramid chars 
  mov ch, 0
START_PCHARS_LOOP:
  cmp ch, cl
  jg END_PCHARS_LOOP

  mov ah, 2
  mov dl, '#'
  int 21h
  
  cmp ch, cl
  je NO_ADJACENT_SPACE_PRINT
  mov ah, 2
  mov dl, ' '
  int 21h
NO_ADJACENT_SPACE_PRINT:       
        
  inc ch  
  jmp START_PCHARS_LOOP
END_PCHARS_LOOP:

  call printn  
  inc cl
jmp START_PYRAMID_LOOP
END_PYRAMID_LOOP: 
  ret   
print_pyramid endp
