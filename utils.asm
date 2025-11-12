.text
.globl strncmp, strcpy, encontrar_caracter, copiar_ate_hifen, string_to_int
.globl print_banner, read_input, strip_newline

# strncmp(a0=ptr1,a1=ptr2,a2=maxlen) -> v0 = 0 if equal up to a2
strncmp:
    beq     $a2, $zero, finish_strncmp
loop_strncmp:
    lb      $t0, 0($a0)
    lb      $t1, 0($a1)
    bne     $t0, $t1, diferentes_strncmp
    beq     $t0, $zero, finish_strncmp
    addi    $a2, $a2, -1
    beq     $a2, $zero, finish_strncmp
    addi    $a0, $a0, 1
    addi    $a1, $a1, 1
    j       loop_strncmp
diferentes_strncmp:
    sub     $v0, $t0, $t1
    jr      $ra
finish_strncmp:
    li      $v0, 0
    jr      $ra

# strcpy(dest=a0, src=a1) -> returns dest in v0
strcpy:
    move $v0, $a0
strcpy_loop:
    lb $t1, 0($a1)
    sb $t1, 0($a0)
    beq $t1, $zero, strcpy_done
    addiu $a0, $a0, 1
    addiu $a1, $a1, 1
    j strcpy_loop
strcpy_done:
    jr $ra

# encontrar_caracter(a0=ptr, a1=char) -> v0 = addr of char or 0
encontrar_caracter:
    li $v0, 0
loop_encontrar:
    lb $t0, 0($a0)
    beq $t0, $zero, nao_encontrado
    beq $t0, $a1, encontrado
    addi $a0, $a0, 1
    j loop_encontrar
encontrado:
    move $v0, $a0
    jr $ra
nao_encontrado:
    li $v0, 0
    jr $ra

# copiar_ate_hifen(a0=src,a1=dest) copies until '-' or 0
copiar_ate_hifen:
    lb $t2, 0($a0)
    beq $t2, $zero, copiar_ate_hifen_fim
    beq $t2, '-', copiar_ate_hifen_fim
    sb $t2, 0($a1)
    addi $a0, $a0, 1
    addi $a1, $a1, 1
    j copiar_ate_hifen
copiar_ate_hifen_fim:
    sb $zero, 0($a1)
    jr $ra

# string_to_int(a0=ptr) -> v0 = integer (stops at non-digit)
string_to_int:
    addi $sp, $sp, -12
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    li $v0, 0
    move $t0, $a0
sti_loop:
    lb $t1, 0($t0)
    beqz $t1, sti_end
    li $t2, '0'
    blt $t1, $t2, sti_end
    li $t2, '9'
    bgt $t1, $t2, sti_end
    sub $t1, $t1, '0'
    mul $v0, $v0, 10
    add $v0, $v0, $t1
    addi $t0, $t0, 1
    j sti_loop
sti_end:
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    addi $sp, $sp, 12
    jr $ra

# I/O helpers
print_banner:
    la $a0, banner
    li $v0, 4
    syscall
    jr $ra

read_input:
    la $a0, input_buffer
    li $a1, 256
    li $v0, 8
    syscall
    jr $ra

strip_newline:
    move $t0, $a0
sn_loop:
    lb $t1, 0($t0)
    beqz $t1, sn_done
    li $t2, 10
    beq $t1, $t2, sn_replace
    addi $t0, $t0, 1
    j sn_loop
sn_replace:
    sb $zero, 0($t0)
    j sn_done
sn_done:
    jr $ra
