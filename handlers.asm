.text
.globl parse_command, cmd_salvar, cmd_recarregar, cmd_formatar
.globl cmd_conta_cadastrar, cmd_data_hora, save_data, load_data

parse_command:
    # verifica "salvar"
    la $a0, input_buffer
    la $a1, cmd_salvar_label
    li $a2, 6
    jal strncmp
    beq $v0, $zero, cmd_salvar

    # verificar "recarregar"
    la $a0, input_buffer
    la $a1, cmd_recarregar_label
    li $a2, 9
    jal strncmp
    beq $v0, $zero, cmd_recarregar

    # verificar "formatar"
    la $a0, input_buffer
    la $a1, cmd_formatar_label
    li $a2, 8
    jal strncmp
    beq $v0, $zero, cmd_formatar

    # verificar prefixo "conta_cadastrar-"
    la $a0, input_buffer
    la $a1, cmd_conta_cadastrar_label
    li $a2, 17
    jal strncmp
    beq $v0, $zero, cmd_conta_cadastrar

    # verificar prefixo "data_hora-"
    la $a0, input_buffer
    la $a1, cmd_data_hora_label
    li $a2, 10
    jal strncmp
    beq $v0, $zero, cmd_data_hora

    # comando inválido
    la $a0, cmd_invalido
    li $v0, 4
    syscall
    jr $ra

cmd_salvar:
    jal save_data
    la $a0, msg_salvo
    li $v0, 4
    syscall
    jr $ra

cmd_recarregar:
    jal load_data
    la $a0, msg_recarregado
    li $v0, 4
    syscall
    jr $ra

cmd_formatar:
    # zera o contador e limpa a área de clientes
    la $t0, num_clientes
    sw $zero, 0($t0)
    la $t1, clientes
    li $t2, 6400
fc_loop:
    beqz $t2, fc_done
    sb $zero, 0($t1)
    addi $t1, $t1, 1
    addi $t2, $t2, -1
    j fc_loop
fc_done:
    la $a0, msg_formatado
    li $v0, 4
    syscall
    jr $ra

# Stubs para salvar/recarregar (implementação futura usando syscalls de arquivo)
save_data:
    # placeholder: implementar gravação em arquivo
    jr $ra

load_data:
    # placeholder: implementar leitura do arquivo filename
    jr $ra
