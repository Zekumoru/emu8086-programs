; Sort Array
; \desc Asks user for n integer inputs which will be then
;       sorted using quick sort.

name "quicksort"

org 100h

.data
  prompt db "Enter number: $"
  
.code
  ; ask user for number
  lea dx, prompt
  mov ah, 9
  int 21h
  
  call get_num
  push dx          
  
  call print_newline
  
  pop dx
  call print_num
  
  .exit

; =============================================================================
; \brief Function to print a newline
print_newline proc
  ; print newline
  mov dl, 10
  mov ah, 2
  int 21h        
  ; print carriage return
  mov dl, 13
  mov ah, 2
  int 21h
  ret
print_newline endp

; =============================================================================
; \brief Function to print number
; \param DX The number to print
print_num proc
  ; handle if number is negative
  cmp dx, 0
  jge NOT_NEG_PRINT_NUM
    ; print negative symbol
    push dx
    mov dl, 45 ; '-'
    mov ah, 2
    int 21h
    
    ; negate dx for number printing
    pop dx
    neg dx
  NOT_NEG_PRINT_NUM:
  
  ; handle if number is 0
  cmp dx, 0
  jne NOT_ZERO_PRINT_NUM
    ; print negative symbol
    mov dl, 48 ; '0'
    mov ah, 2
    int 21h
    ret
  NOT_ZERO_PRINT_NUM:
  
  ; prepare stack for putting in digits
  push bp ; save bp value
  mov bp, sp ; move current sp to bp which will be used to know
             ; where digits start
             
  ; put each digit to stack           
  mov ax, dx 
  START_DIGITS_TO_STACK_PRINT_NUM: 
    mov dx, 0
    cmp ax, 0
    je END_DIGITS_TO_STACK_PRINT_NUM
    
    mov bx, 10
    div bx
    push dx ; put digit to stack 
    
    jmp START_DIGITS_TO_STACK_PRINT_NUM
  END_DIGITS_TO_STACK_PRINT_NUM:
  
  ; print each digit to screen
  START_PRINT_NUM:
    cmp bp, sp
    je END_PRINT_NUM
    
    pop dx
    add dx, 48 ; convert to char digit
    mov ah, 2
    int 21h
    
    jmp START_PRINT_NUM
  END_PRINT_NUM:
  
  pop bp
  ret
print_num endp

; =============================================================================
; \brief Function to get number input
; \return Number from user saved in DX register
get_num proc
  push bp ; save bp value
  mov bp, sp ; move current sp to bp which will be used to know
             ; where inputs start
  
  START_GET_NUM:
    mov ah, 7 ; get char input without echo
    int 21h
    
    ; if char == 'Enter' then stop input
    cmp al, 10 ; if char == '\n'
    je END_GET_NUM
    cmp al, 13 ; if char == '\r'
    je END_GET_NUM
    
    ; handle backspace input
    cmp al, 8 ; if char != '\b'
    jne SKIP_BACKSPACE_HANDLER_GET_NUM
      cmp bp, sp ; if there's no input yet then skip backspace
      je SKIP_BACKSPACE_HANDLER_GET_NUM
    
      ; remove char digit from stack
      pop ax
      
      ; print backspace
      mov dl, 8
      mov ah, 2
      int 21h   ; move cursor back
      mov dl, 0
      mov ah, 2
      int 21h   ; print null to replace whatever char there was
      mov dl, 8
      mov ah, 2
      int 21h   ; move cursor back again  
    SKIP_BACKSPACE_HANDLER_GET_NUM:
    
    ; prevent further '0' if first digit is zero
    cmp w.[bp-2], 48
    jne SKIP_ZERO_HANDLER_GET_NUM
      jmp START_GET_NUM
    SKIP_ZERO_HANDLER_GET_NUM:
    
    ; prevent further '0' even in negative number
    cmp w.[bp-2], 45 ; is first digit '-'?
    jne SKIP_ZERO_SECOND_HANDLER_GET_NUM
      cmp w.[bp-4], 48 ; is second digit '0'?
      je START_GET_NUM
    SKIP_ZERO_SECOND_HANDLER_GET_NUM:
    
    ; prevent '-' inputs if not start of number
    cmp al, 45
    jne SKIP_NEG_HANDLER_GET_NUM
      cmp bp, sp
      jne START_GET_NUM
    SKIP_NEG_HANDLER_GET_NUM:
    
    ; char must be between 0 and 9 and '-'
    cmp al, 45
    je MINUS_SIGN_GET_NUM
    cmp al, 48 ; if char < '0'
    jl START_GET_NUM
    cmp al, 57 ; if char > '9'
    jg START_GET_NUM
    MINUS_SIGN_GET_NUM:
    
    ; char is a digit, echo it
    mov dl, al
    mov ah, 2
    int 21h
    
    ; push char digit
    mov ah, 0
    push ax
    
    jmp START_GET_NUM
  END_GET_NUM:
  
  ; convert char digits to number from stack
  mov dx, 0 ; store number in dx
  mov cx, 0 ; cx is the digit place (tenth, hundreds, etc.)
  START_CONVERSION_GET_NUM:
    cmp bp, sp
    je END_CONVERSION_GET_NUM
    pop ax
    
    ; handle negative '-'
    cmp ax, 45
    jne NOT_NEGATIVE_INPUT_GET_NUM
      neg dx
      jmp END_CONVERSION_GET_NUM ; exit loop since '-' means end anyway
    NOT_NEGATIVE_INPUT_GET_NUM:
    
    ; convert digit char to digit
    sub ax, 48
    
    ; get the digit's place by multiplying by 10
    ; each time for up to cx (the current digit place)
    push cx
    START_PLACE_DIGIT_GET_NUM:
      cmp cx, 0
      je END_PLACE_DIGIT_GET_NUM 
      mov bl, 10
      mul bl
      loop START_PLACE_DIGIT_GET_NUM
    END_PLACE_DIGIT_GET_NUM:
    pop cx
    
    ; finally add the digit number to the actual number
    add dx, ax
    
    inc cx
    jmp START_CONVERSION_GET_NUM
  END_CONVERSION_GET_NUM:
  
  pop bp ; restore bp
  ret
get_num endp
                                                                                        