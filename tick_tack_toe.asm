section .data
    msg_y db "y coordinate b/w 0 and 2:",0
    msg_x db "x coordinate b/w 0 and 2:",0
    error_msg db 0ah,"Enter the correct x and y value",0ah,
    grid_error_msg db 0ah,"The cell is already filled",0ah
    grid db "---------",0ah,0ah
    X_round_msg db "--X Time--",0ah
    O_round_msg db "--O Time--",0ah
    new_line db 0ah
    x db 1 dup(?)
    y db 1 dup(?)
    winner db 1 dup(?)
    reset_sequence db 27,"c"
    winner_prompt db " is the winner",0
    draw_prompt db "Match is draw",0
    
section .text
    global _start

_start:
    call _main

    mov rax, 60
    mov rdi, 0
    syscall

_main:
    push rbp
    mov rbp,rsp

    call _process_input

    leave
    ret

_process_input:
    push rbp
    mov rbp,rsp
    
process_input_start:
    mov rax, 1             
    mov rdi, 1             
    lea rsi, [reset_sequence]
    mov rdx, 2             
    syscall

O_cell:

    lea rbx,[O_round_msg]
    call _find_cell
    lea rax,[O_cell]
    lea rbx,[O_fill]
    jmp _check_cell
O_fill:
    mov BYTE [rcx],'O'
    call _check_winner
    mov bl,BYTE[winner]
    cmp bl,'O'
    je print_winner_prompt
    cmp bl,'X'
    je print_winner_prompt
    cmp bl,'N'
    je print_draw_prompt
    
X_cell:

    lea rbx,[X_round_msg]
    call _find_cell
    lea rax,[X_cell]
    lea rbx,[X_fill]
    jmp _check_cell
X_fill:
    mov BYTE [rcx],'X'
    call _check_winner
    mov bl,BYTE[winner]
    cmp bl,'O'
    je print_winner_prompt
    cmp bl,'X'
    je print_winner_prompt
    cmp bl,'N'
    je print_draw_prompt
    jmp process_input_start

print_winner_prompt:
    mov rax, 1
    mov rdi, 1
    mov rsi, winner
    mov rdx, 1
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, winner_prompt
    mov rdx, 15
    syscall

    jmp process_input_end

print_draw_prompt:
    mov rax, 1
    mov rdi, 1
    mov rsi, draw_prompt
    mov rdx, 15
    syscall

process_input_end:
    leave
    ret

_find_cell:
    push rbp
    mov rbp,rsp

    call _get_input
    movzx rax,BYTE [x]
    movzx rbx,BYTE [y]
    sub rax,'0'
    sub rbx,'0'
    mov rcx,3
    mul rcx
    mov rcx,grid
    add rcx,rax
    add rcx,rbx
    
    leave
    ret

_get_input:
    push rbp
    mov rbp,rsp

input:
    call _print_grid
    mov rax, 1
    mov rdi, 1
    mov rsi, rbx
    mov rdx, 11
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_x
    mov rdx, 26
    syscall

    ; get x and y from the user
    mov rax,0
    mov rdi,0
    mov rsi,x
    mov rdx,2
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_y
    mov rdx, 26
    syscall

    mov rax,0
    mov rdi,0
    mov rsi,y
    mov rdi,2
    syscall

    ; out of bound check for x and y
    mov al,BYTE [x]
    cmp al,'2'
    jg _error
    cmp al,'0'
    jl _error
    
    mov al,BYTE [y]
    cmp al,'2'
    jg _error
    cmp al,'0'
    jl _error
    
    leave
    ret

_error:
    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, 33
    syscall

    jmp input

_check_cell:
    
    mov dl,BYTE [rcx]
    cmp dl,'X'
    je _fill_error
    cmp dl,'O'
    je _fill_error

    jmp rbx

_fill_error:
    mov rbx,rax
    mov rax, 1
    mov rdi, 1
    mov rsi, grid_error_msg
    mov rdx, 28
    syscall

    jmp rbx


_print_grid:
    push rbp
    mov rbp,rsp
    
    mov rax, 1
    mov rdi, 1
    mov rsi, new_line
    mov rdx, 1
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, [grid]
    mov rdx, 3
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, new_line
    mov rdx, 1
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, [grid+3]
    mov rdx, 3
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, new_line
    mov rdx, 1
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, [grid+6]
    mov rdx, 5
    syscall

    leave
    ret

_check_winner:

    push rbp 
    mov rbp,rsp
    lea rax,[grid]
    
    ; first row
    mov rbx,0
    mov rdx,0
    mov cl,BYTE[grid+rdx]
    call _row_check
    mov cl,BYTE[winner]
    cmp cl,'O'
    je check_winner_end
    cmp cl,'X'
    je check_winner_end

    ; second row
    mov rbx,0
    mov rdx,3
    mov cl,BYTE[grid+rdx]
    call _row_check
    mov cl,BYTE[winner]
    cmp cl,'O'
    je check_winner_end
    cmp cl,'X'
    je check_winner_end

    ; third row
    mov rbx,0
    mov rdx,6
    mov cl,BYTE[grid+rdx]
    call _row_check
    mov cl,BYTE[winner]
    cmp cl,'O'
    je check_winner_end
    cmp cl,'X'
    je check_winner_end

    ; first column
    mov rbx,0
    mov rdx,0
    mov cl,BYTE[grid+rbx]
    call _column_check
    mov cl,BYTE[winner]
    cmp cl,'O'
    je check_winner_end
    cmp cl,'X'
    je check_winner_end

    ; second column
    mov rbx,1
    mov rdx,0
    mov cl,BYTE[grid+rbx]
    call _column_check
    mov cl,BYTE[winner]
    cmp cl,'O'
    je check_winner_end
    cmp cl,'X'
    je check_winner_end

    ; third column
    mov rbx,2
    mov rdx,0
    mov cl,BYTE[grid+rbx]
    call _column_check
    mov cl,BYTE[winner]
    cmp cl,'O'
    je check_winner_end
    cmp cl,'X'
    je check_winner_end

    ; L-R column
    mov rbx,0
    mov rdx,0
    mov cl,BYTE[grid+rbx]
    mov rdi,1
    call _diagonal_check
    mov cl,BYTE[winner]
    cmp cl,'O'
    je check_winner_end
    cmp cl,'X'
    je check_winner_end

    ; R-L column
    mov rbx,2
    mov rdx,0
    mov cl,BYTE[grid+rbx]
    mov rdi,-1
    call _diagonal_check
    mov cl,BYTE[winner]
    cmp cl,'O'
    je check_winner_end
    cmp cl,'X'
    je check_winner_end

    ; grid fill_end
    call _fill_check
    
check_winner_end:
    leave
    ret

_row_check:
    push rbp
    mov rbp,rsp

row_start:
    
    mov rsi,rdx
    add rsi,rbx
    cmp cl,BYTE[grid+rsi]
    jne row_end

    add rbx,1
    cmp rbx,3
    jne row_start
    
    mov BYTE [winner],cl
    
row_end:
    leave
    ret

_column_check:
    push rbp
    mov rbp,rsp

column_start:

    mov rsi,rbx
    add rsi,rdx
    cmp cl,BYTE[grid+rsi]
    jne column_end
    
    add rdx,3
    cmp rdx,9
    jne column_start

    mov BYTE [winner],cl

column_end:
    leave
    ret

_diagonal_check:
    push rbp
    mov rbp,rsp
    
diagonal_start:

    mov rsi,rdx
    add rsi,rbx
    cmp cl,BYTE[grid+rsi]
    jne diagonal_end

    add rbx,rdi
    add rdx,3
    cmp rdx,9
    jne diagonal_start

    mov BYTE [winner],cl

diagonal_end:
    leave
    ret

_fill_check:
    push rbp
    mov rbp,rsp
    mov rax,-1
fill_start:
    add rax,1
    cmp rax,9
    je no_winner_flag_set
    
    mov bl,BYTE[grid+rax]
    
    cmp bl,'-'
    jne fill_start
    je fill_end

no_winner_flag_set:
    mov BYTE [winner],'N'

fill_end:
    leave
    ret
    
