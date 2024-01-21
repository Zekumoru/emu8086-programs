; Sort Array
; \desc Asks user for n integer inputs which will be then
;       sorted using quick sort.
; \author Zekumoru
; \version 1.0.240121

name "quicksort"

org 100h

.data
  array dw ?
  length dw ?
  prompt_length db "Enter length of array: $"
  prompt_length_invalid db "Invalid length! Must be a positive number!", 10, 13, "$"
  prompt_number db "Enter number $"
  prompt_number_end db ": $"
  msg_array_entered db "The array you entered: $"
  msg_sort_loading db "Sorting array...", 10, 13, "$"
  msg_array_sorted db "The array sorted: $"
  
.code    
  ; ask user for the length of the array
  START_LENGTH_PROMPT:
    lea dx, prompt_length
    mov ah, 9
    int 21h
    
    ; get length
    call get_num
    mov length, dx
    
    call print_newline
    
    ; if length <= 0, re-ask user for length
    cmp length, 0
    jg END_LENGTH_PROMPT
      lea dx, prompt_length_invalid
      mov ah, 9
      int 21h
      call print_newline
      jmp START_LENGTH_PROMPT        
  END_LENGTH_PROMPT:
  
  ; allocate space for array
  mov cx, length
  ALLOCATE_ARRAY:
    push 0
    loop ALLOCATE_ARRAY
  mov array, sp ; remember: to access element, do array+2i where i is the index
  
  ; ask user numbers for array
  mov cx, 0 ; index for array
  mov bp, array ; put array address to bp
  START_NUMBERS_PROMPT:
    cmp cx, length
    jge END_NUMBERS_PROMPT
    lea dx, prompt_number
    mov ah, 9
    int 21h
    mov dx, cx  ; print current index
    inc dx
    call print_num
    lea dx, prompt_number_end
    mov ah, 9
    int 21h
    
    ; get number
    call get_num
    
    ; calculate actual array index
    call get_actual_index
    mov w.[si], dx
    
    call print_newline
    
    inc cx
    jmp START_NUMBERS_PROMPT
  END_NUMBERS_PROMPT:
  
  ; Show to user their array
  lea dx, msg_array_entered
  mov ah, 9
  int 21h
  
  mov bp, array
  mov cx, length
  call print_array
  call print_newline
  
  ; Sort array
  lea dx, msg_sort_loading
  mov ah, 9
  int 21h
  call quicksort
  
  ; Show sorted array to user
  lea dx, msg_array_sorted
  mov ah, 9
  int 21h
  
  mov bp, array
  mov cx, length
  call print_array
  call print_newline 
  
  .exit

; =============================================================================
; \brief Sort array using quicksort
; \param cx Size of the array
; \param bp Base pointer of the array
quicksort proc
  push ax ; save ax value
  push bx ; save bx value
  push dx ; save dx value
  
  mov ax, 0
  mov bx, cx
  dec bx
  call quicksort_int
  
  pop dx ; restore dx
  pop bx ; restore bx
  pop ax ; restore ax
  ret
quicksort endp

; \brief Internal quicksort helper
; \param bp Base pointer of the array
; \param ax Start index
; \param bx End index
quicksort_int proc
  ; if (start >= end) return
  cmp ax, bx
  jl NO_EARLY_RET_QUICKSORT
    ret
  NO_EARLY_RET_QUICKSORT:
  
  ; local variables
  mov si, bp ; since bp has address of array, move it to si
  mov bp, sp ; get local variables' base address
  push si ; address of array [bp-2], this will be restored as bp later
  push ax ; start index [bp-4], this will be restored after function call
  push bx ; end index [bp-6], this will be restored after function call
  push cx ; save cx value
  
  ; get mid index to ax
  ; mid = (start + end) / 2
  mov dx, 0
  add ax, bx
  shr ax, 1 ; divide by 2
  
  ; get pivot to dx
  push bp
  mov bp, w.[bp-2] ; get array address to bp
  mov cx, ax
  call get_actual_index
  mov dx, w.[si] ; pivot = array[mid] 
  pop bp ; restore to local vars' address
  
  ; partition(array, start, end, pivot)
  ; |= partition(bp, ax, bx, dx)
  push bp
  mov ax, w.[bp-4] ; get start index  
  mov bx, w.[bp-6] ; get end index
  mov bp, w.[bp-2] ; get array address to bp
  call partition   
  
  ; recurse left partition
  ; ax and bx still hold start and end indices respectively
  ; because the partition function restores them
  ; quicksort_int(array, start, index - 1)
  ; |= quicksort_int(bp, ax, cx-1)
  mov dx, cx ; move index to dx
  dec dx ; index--
  push bx ; save bx which contains end
  mov bx, dx
  call quicksort_int
  pop bx  ; restore end to bx

  ; recurse right partition
  ; ax and bx still hold start and end indices respectively
  ; because ax is restored by the partition function and
  ; bx is saved from the stack
  ; quicksort_int(array, index, end)
  ; |= quicksort_int(bp, cx, bx)
  mov ax, cx ; set ax to index
  call quicksort_int
                            
  pop bp ; restore to local vars' address
  
  pop cx ; restore cx
  pop bx ; restore bx
  pop ax ; restore ax
  pop bp ; restore original bp
  
  ret
quicksort_int endp

; =============================================================================
; \brief Partition array using Hoare's algorithm which splits the array into
;        two parts where elements less than the pivot are all on the left 
;        and vice versa
; \param bp Base address of the array
; \param ax Left pointer
; \param bx Right pointer
; \param dx Pivot
; \return cx The index where to split the array
partition proc
  push ax ; save ax value
  push bx ; save bx value
  
  ; while (lp <= rp)
  START_PARTITION:
    cmp ax, bx        
    jg END_PARTITION
    
    ; while (array[lp] < pivot) lp++;
    WHILE_LT_PIVOT_PARTITION:
      mov cx, ax
      call get_actual_index
      cmp w.[si], dx ; array[lp] < pivot
      jge NOT_LT_PIVOT_PARTITION
        inc ax ; lp++
        jmp WHILE_LT_PIVOT_PARTITION
    NOT_LT_PIVOT_PARTITION:
    
    ; while (array[rp] > pivot) rp--;
    WHILE_GT_PIVOT_PARTITION:
      mov cx, bx
      call get_actual_index
      cmp w.[si], dx ; array[rp] > pivot
      jle NOT_GT_PIVOT_PARTITION
        dec bx ; rp--
        jmp WHILE_GT_PIVOT_PARTITION
    NOT_GT_PIVOT_PARTITION:
    
    ; if (lp <= rp) then swap array[lp] and array[rp]
    cmp ax, bx
    jg NO_SWAP_PARTITION
      ; push array[lp] for temp storage
      mov cx, ax
      call get_actual_index
      push w.[si]
      ; array[lp] <- array[rp]
      mov cx, bx
      call get_actual_index
      push w.[si]
      mov cx, ax
      call get_actual_index
      pop w.[si]
      ; array[rp] <- temp (from stack)
      mov cx, bx
      call get_actual_index
      pop w.[si]
      
      ; increment lp and decrement rp
      inc ax ; lp++
      dec bx ; rp--
    NO_SWAP_PARTITION:
    
    jmp START_PARTITION
  END_PARTITION:
  
  mov cx, ax ; move lp to cx (which is the index)
  pop bx ; restore bx
  pop ax ; restore ax
  ret
partition endp

; =============================================================================
; \brief Function to print array
; \param cx Size of the array
; \param bp Base pointer of the array       
print_array proc
  mov ah, 2
  mov dl, '['
  int 21h
  
  mov ax, cx ; move length to ax register                
  mov cx, 0 ; cx is the index of the current element
  START_PRINT_ARRAY:
    cmp cx, ax
    jge END_PRINT_ARRAY
    
    call get_actual_index
    mov dx, w.[si]  ; get current element to dx
    call print_num
    
    ; print comma
    push ax
    mov dx, ax
    dec dx
    cmp cx, dx ; where dx = length - 1
    jge SKIP_COMMA_PRINT_ARRAY
      mov dl, ','
      mov ah, 2
      int 21h
      mov dl, ' '
      int 21h
    SKIP_COMMA_PRINT_ARRAY:
    
    pop ax
    inc cx
    jmp START_PRINT_ARRAY
  END_PRINT_ARRAY:
  
  mov ah, 2
  mov dl, ']'
  int 21h
  ret
print_array endp

; =============================================================================
; \brief Function to calculate actual index
; \param bp Base pointer of the array
; \param cx Index of element to calculate
; \return si 
get_actual_index proc
  push ax ; save ax value
  push bx ; save bx value
  
  mov ax, cx
  mov bl, 2
  mul bl
  add ax, bp
  mov si, ax
  
  pop bx ; restore bx
  pop ax ; restore ax
  ret
get_actual_index endp

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
  push ax ; save ax value
  push bx ; save bx value
  push cx ; save cx value
  push dx ; save dx value
  mov bp, sp ; move current sp to bp which will be used to know
             ; where digits start
  
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
                     
  pop dx ; restore dx
  pop cx ; restore cx
  pop bx ; restore bx
  pop ax ; restore ax
  pop bp
  ret
print_num endp

; =============================================================================
; \brief Function to get number input
; \return Number from user saved in DX register
get_num proc
  push bp ; save bp value
  push ax ; save ax value
  push bx ; save bx value
  push cx ; save cx value
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
                     
  pop cx ; restore cx
  pop bx ; restore bx
  pop ax ; restore ax
  pop bp ; restore bp
  ret
get_num endp
                                                                                        