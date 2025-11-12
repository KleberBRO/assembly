.text

cmd_conta_cadastrar:
    # prólogo: salvar $ra e $s registos (usa 12 bytes)
    addi $sp, $sp, -12
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)

    # source start = input_buffer + len("conta_cadastrar-") == 17
    la $t0, input_buffer
    addi $t0, $t0, 17

    # copiar CPF até '-'
    move $a0, $t0
    la $a1, temp_cpf
    jal copiar_ate_hifen

    # validar comprimento CPF == 11
    la $t1, temp_cpf
    li $t2, 0
cpf_len_loop:
    lb $t3, 0($t1)
    beqz $t3, cpf_len_done
    addi $t2, $t2, 1
    addi $t1, $t1, 1
    j cpf_len_loop
cpf_len_done:
    li $t3, 11
    bne $t2, $t3, err_invalid_params

    # avançar para inicio da conta: encontrar '-' a partir de t0
    move $a0, $t0
    li $a1, '-'
    jal encontrar_caracter
    beqz $v0, err_invalid_params
    addi $t0, $v0, 1         # t0 = inicio conta

    # copiar conta até '-'
    move $a0, $t0
    la $a1, temp_conta
    jal copiar_ate_hifen

    # validar comprimento conta == 6
    la $t1, temp_conta
    li $t2, 0
acct_len_loop:
    lb $t3, 0($t1)
    beqz $t3, acct_len_done
    addi $t2, $t2, 1
    addi $t1, $t1, 1
    j acct_len_loop
acct_len_done:
    li $t3, 6
    bne $t2, $t3, err_invalid_params

    # avançar para inicio do nome: encontrar '-' após conta
    move $a0, $t0
    li $a1, '-'
    jal encontrar_caracter
    beqz $v0, err_invalid_params
    addi $t0, $v0, 1         # t0 = inicio nome

    # copiar nome até fim
    move $a0, $t0
    la $a1, temp_nome
    jal copiar_ate_hifen

    # validar nome não vazio
    la $t1, temp_nome
    lb $t2, 0($t1)
    beqz $t2, err_invalid_params

    # percorre clientes para checar duplicatas
    la $t1, num_clientes
    lw $t2, 0($t1)           # t2 = num_clientes
    li $t3, 0                # idx = 0
    beqz $t2, add_new_client_start

client_loop:
    la $t4, clientes
    li $t5, 128
    mul $t6, $t3, $t5
    add $t6, $t4, $t6        # t6 = base cliente[idx]

    # comparar CPF (offset 0, len 11)
    move $a0, $t6
    la $a1, temp_cpf
    li $a2, 11
    jal strncmp
    beq $v0, $zero, cpf_exists

    # comparar conta (offset 11, len 6)
    addi $a0, $t6, 11
    la $a1, temp_conta
    li $a2, 6
    jal strncmp
    beq $v0, $zero, acc_in_use

    addi $t3, $t3, 1
    blt $t3, $t2, client_loop

add_new_client_start:
    # verificar espaço (<=50)
    la $t1, num_clientes
    lw $t2, 0($t1)
    li $t3, 50
    bge $t2, $t3, db_full

    # destino = clientes + num_clientes*128
    la $t4, clientes
    li $t5, 128
    mul $t6, $t2, $t5
    add $t7, $t4, $t6        # t7 = destino base (salvar em $s0)
    move $s0, $t7

    # copiar CPF para destino offset 0
    move $a0, $s0
    la $a1, temp_cpf
    jal strcpy

    # copiar conta para destino offset 11
    addi $a0, $s0, 11
    la $a1, temp_conta
    jal strcpy

    # calcular DV da conta
    la $t1, temp_conta
    li $t2, 0      # soma
    li $t3, 0      # j = 0
    li $s1, '0'    # constante '0' em $s1
dv_loop:
    lb $t4, 0($t1)
    beqz $t4, dv_done
    sub $t4, $t4, $s1
    li $t5, 7
    sub $t5, $t5, $t3
    mul $t6, $t4, $t5
    add $t2, $t2, $t6
    addi $t1, $t1, 1
    addi $t3, $t3, 1
    j dv_loop
dv_done:
    li $t4, 11
    div $t2, $t4
    mfhi $t5
    li $t6, 10
    beq $t5, $t6, dv_is_X
    addi $t5, $t5, '0'
    j dv_store
dv_is_X:
    li $t5, 'X'
dv_store:
    sb $t5, 17($s0)

    # copiar nome para destino offset 18
    addi $a0, $s0, 18
    la $a1, temp_nome
    jal strcpy

    # inicializar valores
    li $t2, 0
    sw $t2, 68($s0)
    sw $t2, 72($s0)
    li $t2, 150000
    sw $t2, 76($s0)
    li $t2, 1
    sb $t2, 80($s0)

    # incrementar num_clientes
    la $t1, num_clientes
    lw $t2, 0($t1)
    addi $t2, $t2, 1
    sw $t2, 0($t1)

    # imprimir mensagem de sucesso
    la $a0, msg_cliente_cadastrado_prefix
    li $v0, 4
    syscall
    addi $a0, $s0, 11
    li $v0, 4
    syscall
    li $a0, '-'
    li $v0, 11
    syscall
    lb $a0, 17($s0)
    li $v0, 11
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    j cc_return

cpf_exists:
    la $a0, msg_cpf_exists
    li $v0, 4
    syscall
    j cc_return

acc_in_use:
    la $a0, msg_acc_in_use
    li $v0, 4
    syscall
    j cc_return

err_invalid_params:
    la $a0, msg_invalid_params
    li $v0, 4
    syscall
    j cc_return

db_full:
    la $a0, msg_db_full
    li $v0, 4
    syscall
    j cc_return

# epílogo: restaurar $ra e $s regs e retornar
cc_return:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    addi $sp, $sp, 12
    jr   $ra