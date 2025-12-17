.model small
.stack 100h

; DATA
.data    
    welcome         db '            Welcome to MiniOS v3.2             $'
    
    ; MENU
    menu_header     db 0dh,0ah,0dh,0ah,'[ SELECT OPTION ]',0dh,0ah,'$'
    menu            db 0dh,0ah,'--- FILE OPERATIONS ---',0dh,0ah
                    db '1. Create File',0dh,0ah
                    db '2. Open File',0dh,0ah
                    db '3. Close File',0dh,0ah
                    db '4. Write to File',0dh,0ah
                    db '5. Read from File',0dh,0ah
                    db '6. Delete File',0dh,0ah    
                    db '7. List Directory',0dh,0ah 
                    db 0dh,0ah,'--- TOOLS ---',0dh,0ah
                    db '8. Calculator (Auto-Save)',0dh,0ah      
                    db '9. Date & Time',0dh,0ah
                    db '0. Exit',0dh,0ah
                    db '$'
       
    prompt          db 0dh,0ah,'User@MiniOS> $'
    
    ; STATUS MESSAGES
    status_ok       db 0dh,0ah,'Status: SUCCESS$',
    status_fail     db 0dh,0ah,'Status: FAILED - Access Denied/Error$',
    created_msg     db 0dh,0ah,'Status: File Created.$'
    deleted_msg     db 0dh,0ah,'Status: File Deleted.$'
    write_prompt    db 0dh,0ah,'Enter text: $'
    write_success   db 0dh,0ah,'Status: Text Written$'
    read_msg_header db 0dh,0ah,'--- File Content ---',0dh,0ah,'$'
    time_msg        db 0dh,0ah,'[ DATE & TIME ] $'

    ; CALCULATOR DATA
    calc_msg_1      db 0dh,0ah,'Digit 1: $'
    calc_msg_op     db 0dh,0ah,'Operator (+/-): $'
    calc_msg_2      db 0dh,0ah,'Digit 2: $'
    calc_res_msg    db 0dh,0ah,'Result: $'
    calc_save_msg   db ' (Saved to calculation.txt)$'
    
    calc_res_char   db ?  
    newline         db 0dh,0ah 

    ; FILE PATHS
    filename        db 'c:\testfile.txt',0 
    calc_filename   db 'c:\calculation.txt',0    
    wildcard        db 'c:\*.*',0   
    
    handle          dw 0
    calc_handle     dw 0
    
    ; BUFFERS
    input_buffer    db 102, ?, 102 dup('$')
    actual_length   dw ?
    read_buffer     db 100 dup('$') 
    dta_buffer      db 43 dup(0) 

; CODE
.code
main proc
    mov ax, @data
    mov ds, ax
    
    mov ah, 1Ah              ; set DTA
    mov dx, offset dta_buffer
    int 21h
    
    mov ah, 0                ; clear screen
    mov al, 3 
    int 10h
    
    mov dx, offset welcome   ; welcome message
    mov ah, 9h
    int 21h
    
main_loop:
    mov dx, offset menu_header
    mov ah, 9h
    int 21h

    mov dx, offset menu
    mov ah, 9h
    int 21h

    mov dx, offset prompt
    mov ah, 9h
    int 21h
    
    mov ah, 1h               ; read choice
    int 21h 
    
    ; MENU ROUTING
    cmp al, '1'
    je safe_create_check
    cmp al, '2'
    je open_file
    cmp al, '3'
    je close_file
    cmp al, '4'
    je write_file
    cmp al, '5'
    je read_file
    cmp al, '6'
    je delete_file_safe
    cmp al, '7'          
    je list_directory
    cmp al, '8'          
    je calculator
    cmp al, '9'          
    je show_date_time
    cmp al, '0'
    je exit_os
    
    jmp main_loop

; FILE OPERATIONS (testfile.txt)

safe_create_check:
    mov ah, 4Eh              ; check file exists
    mov cx, 0        
    mov dx, offset filename
    int 21h
    jnc file_exists_msg

    mov ah, 3Ch              ; create file
    mov cx, 0        
    mov dx, offset filename
    int 21h
    jc fail_ret      
    mov bx, ax       
    mov ah, 3Eh       
    int 21h
    mov dx, offset created_msg
    mov ah, 9h
    int 21h
    jmp main_loop

file_exists_msg:
    mov dx, offset status_ok
    mov ah, 9h
    int 21h
    jmp main_loop

open_file:
    mov ah, 3Dh
    mov al, 2        
    mov dx, offset filename
    int 21h
    jc fail_ret       
    mov handle, ax   
    jmp success_ret

close_file:
    mov bx, handle     
    mov ah, 3Eh
    int 21h
    jc fail_ret
    mov handle, 0    
    jmp success_ret

write_file:
    cmp handle, 0    
    je fail_ret
    mov dx, offset write_prompt
    mov ah, 9h
    int 21h
    
    mov dx, offset input_buffer 
    mov ah, 0Ah 
    int 21h
    
    mov al, input_buffer+1
    cbw                  
    mov actual_length, ax 
    
    mov cx, actual_length 
    mov dx, offset input_buffer+2 
    mov bx, handle       
    mov ah, 40h          
    int 21h
    
    mov dx, offset write_success
    mov ah, 9h
    int 21h
    jmp main_loop

read_file:
    cmp handle, 0
    je fail_ret
    
    mov bx, handle
    mov cx, 0
    mov dx, 0
    mov al, 0
    mov ah, 42h
    int 21h

    mov bx, handle
    mov cx, 100
    mov dx, offset read_buffer
    mov ah, 3Fh
    int 21h
    jc fail_ret
    
    mov bx, ax
    mov al, '$'
    mov read_buffer[bx], al
    
    mov dx, offset read_msg_header
    mov ah, 9h
    int 21h
    mov dx, offset read_buffer
    mov ah, 9h
    int 21h
    jmp main_loop

delete_file_safe:
    cmp handle, 0
    je do_delete     
    mov bx, handle
    mov ah, 3Eh      
    int 21h
    mov handle, 0    
    
do_delete:
    mov ah, 41h              
    mov dx, offset filename 
    int 21h
    jc fail_ret              
    mov dx, offset deleted_msg
    mov ah, 9h
    int 21h
    jmp main_loop

list_directory:
    mov dx, offset read_msg_header 
    mov ah, 9h
    int 21h

    mov ah, 4Eh
    mov cx, 0                
    mov dx, offset wildcard 
    int 21h
    jc fail_ret              

print_filename_loop:
    mov si, offset dta_buffer + 30
    
print_char:
    lodsb                    
    cmp al, 0                
    je next_file
    
    mov dl, al
    mov ah, 2h               
    int 21h
    jmp print_char
    
next_file:
    mov dl, 0dh
    mov ah, 2
    int 21h
    mov dl, 0ah
    int 21h

    mov ah, 4Fh 
    int 21h
    jnc print_filename_loop 
    
    jmp main_loop

; CALCULATOR

calculator:
    mov dx, offset calc_msg_1
    mov ah, 9h
    int 21h
    
    mov ah, 1h       
    int 21h
    sub al, 30h      
    mov bl, al       
    
    mov dx, offset calc_msg_op
    mov ah, 9h
    int 21h
    
    mov ah, 1h
    int 21h
    mov bh, al       
    
    mov dx, offset calc_msg_2
    mov ah, 9h
    int 21h
    
    mov ah, 1h
    int 21h
    sub al, 30h      
    mov cl, al       
    
    cmp bh, '+'
    je do_add
    cmp bh, '-'
    je do_sub
    jmp fail_ret     

do_add:
    add bl, cl       
    jmp print_res

do_sub:
    sub bl, cl       
    jmp print_res

print_res:
    mov dx, offset calc_res_msg
    mov ah, 9h
    int 21h
    
    mov al, bl       
    add al, 30h      
    mov calc_res_char, al 
    
    mov dl, al
    mov ah, 2h       
    int 21h

    ; SAVE RESULT TO FILE
    mov ah, 4Eh
    mov cx, 0
    mov dx, offset calc_filename
    int 21h
    jc create_calc_file_new

    mov ah, 3Dh
    mov al, 2
    mov dx, offset calc_filename
    int 21h
    mov calc_handle, ax
    jmp append_calc

create_calc_file_new:
    mov ah, 3Ch
    mov cx, 0
    mov dx, offset calc_filename
    int 21h
    mov calc_handle, ax

append_calc:
    mov bx, calc_handle
    mov al, 2           
    mov cx, 0
    mov dx, 0
    mov ah, 42h         
    int 21h
    
    mov ah, 40h
    mov bx, calc_handle
    mov cx, 1           
    mov dx, offset calc_res_char
    int 21h
    
    mov ah, 40h
    mov bx, calc_handle
    mov cx, 2
    mov dx, offset newline
    int 21h

    mov ah, 3Eh
    mov bx, calc_handle
    int 21h

    mov dx, offset calc_save_msg
    mov ah, 9h
    int 21h
    
    jmp main_loop

; DATE AND TIME

show_date_time:
    mov dx, offset time_msg
    mov ah, 9h
    int 21h

    mov ah, 2Ah      
    int 21h          
    
    push dx          
    push cx          

    mov al, dl
    call print_2digits
    
    mov dl, '-'      
    mov ah, 2h
    int 21h
    
    pop cx           
    pop dx           
    
    mov al, dh
    call print_2digits
    
    mov dl, '-'      
    mov ah, 2h
    int 21h
    
    mov ax, cx
    mov bl, 100
    div bl           
    push ax          
    
    call print_2digits 
    
    pop ax
    mov al, ah       
    call print_2digits
    
    mov dl, ' '      
    mov ah, 2h
    int 21h

    mov ah, 2Ch       
    int 21h           
    
    mov al, ch        
    call print_2digits 
    mov dl, ':'
    mov ah, 2h
    int 21h
    
    mov al, cl        
    call print_2digits
    mov dl, ':'
    mov ah, 2h
    int 21h
    
    mov al, dh
    call print_2digits
    
    jmp main_loop

; COMMON RETURNS

success_ret:
    mov dx, offset status_ok
    mov ah, 9h
    int 21h
    jmp main_loop

fail_ret:
    mov dx, offset status_fail
    mov ah, 9h
    int 21h
    jmp main_loop

exit_os:
    mov ah, 4Ch       
    int 21h

; PRINT TWO DIGITS
print_2digits proc
    aam               
    add ax, 3030h     
    push ax           
    mov dl, ah        
    mov ah, 2h        
    int 21h
    pop ax            
    mov dl, al        
    mov ah, 2h        
    int 21h
    ret
print_2digits endp

end main
