.global _start
.section .data
prompt:     .ascii "RISC-V Terminal> "
prompt_len: .word   16
newline:    .ascii "\n"
nl_len:     .word   1
error_msg:  .ascii "Unknown command\n"
error_len:  .word   15
exit_msg:   .ascii "Exiting...\n"
exit_len:   .word   11
help_msg:   .ascii "Available commands:\n  help    - show this message\n  exit    - exit terminal\n   sysinfo - show system info\n\n"
help_len:   .word   108

exit_cmd:    .asciz "exit"
help_cmd:    .asciz "help"
sysinfo_cmd: .asciz "sysinfo"

meminfo_path: .asciz "/proc/meminfo"
cpuinfo_path: .asciz "/proc/cpuinfo"
sysinfo_header: .ascii "\nSystem Information:\n"
sysinfo_header_len: .word 19
cpu_header:     .ascii "\nCPU Information:\n"
cpu_header_len: .word 17
mem_header:     .ascii "\nMemory Information:\n"
mem_header_len: .word 20
.section .bss
.align 8
buffer:         .zero 4096   
uname_buffer:   .zero 390    
file_buffer:    .zero 8192   
number_buffer:  .zero 32     
.section .text
_start:
 la sp, stack_end
 j main_loop
main_loop:
 li a7, 64 
 li a0, 1
 la a1, prompt
 lw a2, prompt_len
 ecall
li a7, 63
li a0, 0
la a1, buffer
li a2, 4096
ecall

mv t2, a0
la t0, buffer
add t1, t0, t2
addi t1, t1, -1
sb zero, (t1)      
la a0, buffer
la a1, exit_cmd
call strcmp
beqz a0, do_exit

 la a0, buffer
la a1, help_cmd
call strcmp
beqz a0, do_help
la a0, buffer
la a1, sysinfo_cmd
call strcmp
beqz a0, do_sysinfo

beqz t2, main_loop
li a7, 64
li a0, 1
la a1, error_msg
lw a2, error_len
ecall
j main_loop
strcmp:
lb t0, (a0)
lb t1, (a1)
bne t0, t1, strcmp_ne
beqz t0, strcmp_eq
addi a0, a0, 1
addi a1, a1, 1
j strcmp              
strcmp_ne:
li a0, 1
ret
strcmp_eq:
li a0, 0
ret
read_file:
addi sp, sp, -16
sw ra, 0(sp)
sw s0, 4(sp)
sw s1, 8(sp)
mv s0, a0
mv s1, a1      

li a7, 56
li a0, -100
mv a1, s0
li a2, 0
li a3, 0
ecall

bltz a0, read_file_error
mv t0, a0
li a7, 63
mv a0, t0
mv a1, s1
li a2, 8192
ecall
mv t1, a0

li a7, 57
mv a0, t0
 ecall
 mv a0, t1
j read_file_end

read_file_error:
li a0, 0           
read_file_end:
lw ra, 0(sp)
lw s0, 4(sp)
lw s1, 8(sp)
addi sp, sp, 16
ret

do_help:
li a7, 64
li a0, 1
la a1, help_msg
lw a2, help_len
ecall
j main_loop
do_exit:
li a7, 64
li a0, 1
la a1, exit_msg
lw a2, exit_len
ecall
li a7, 93
li a0, 0
ecall
li a7, 64
li a0, 1
la a1, newline
lw a2, nl_len
ecall

j main_loop
do_sysinfo:
 li a7, 64
li a0, 1
la a1, sysinfo_header
lw a2, sysinfo_header_len
ecall
li a7, 160
la a0, uname_buffer
ecall

li a7, 64
li a0, 1
la a1, uname_buffer
li a2, 65
ecall
li a7, 64
li a0, 1
la a1, newline
lw a2, nl_len
ecall
li a7, 64
li a0, 1
la a1, cpu_header
lw a2, cpu_header_len
ecall
la a0, cpuinfo_path
la a1, file_buffer
call read_file

beqz a0, sysinfo_error
mv t0, a0
li a7, 64
li a0, 1
la a1, file_buffer
mv a2, t0
ecall

li a7, 64
li a0, 1
la a1, mem_header
lw a2, mem_header_len
ecall

la a0, meminfo_path
la a1, file_buffer
call read_file

beqz a0, sysinfo_error
mv t0, a0
li a7, 64
li a0, 1
la a1, file_buffer
 mv a2, t0
ecall

 j main_loop

sysinfo_error:
li a7, 64
li a0, 1
la a1, error_msg
lw a2, error_len
ecall
j main_loop
itoa:
addi sp, sp, -16
sw ra, 0(sp)
sw s0, 4(sp)
sw s1, 8(sp)
mv s0, a0
mv s1, a1

bnez s0, not_zero
li t0, '0'
sb t0, (s1)
addi s1, s1, 1
j itoa_end
not_zero:
convert_loop:
beqz s0, reverse_string
li t0, 10
rem t1, s0, t0     
div s0, s0, t0     
addi t1, t1, '0'   
sb t1, (s1)         
addi s1, s1, 1
 j convert_loop
reverse_string:
sb zero, (s1)      
mv a0, a1          
addi s1, s1, -1    
reverse_loop:
bge a0, s1, itoa_end
lb t0, (a0)
lb t1, (s1)
sb t1, (a0)
sb t0, (s1)
addi a0, a0, 1
addi s1, s1, -1
j reverse_loop

itoa_end:
mv a0, s1
sub a0, a0, a1
addi a0, a0, 1
 lw ra, 0(sp)
lw s0, 4(sp)
lw s1, 8(sp)
addi sp, sp, 16
ret
.section .bss
.align 16
.space 8192
stack_end:
