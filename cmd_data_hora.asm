.text

cmd_data_hora:
    # data_hora handler (implementação extraída de handlers.asm)
    la $t0, input_buffer
    addi $t0, $t0, 10
    move $a0, $t0
    la $a1, temp_date
    jal copiar_ate_hifen

    move $a0, $t0
    li $a1, '-'
    jal encontrar_caracter
    beqz $v0, datahora_err
    addi $t0, $v0, 1

    move $a0, $t0
    la $a1, temp_time
    jal copiar_ate_hifen

    # validar len date==8 time==6
    la $t1, temp_date
    li $t2, 0
dh_date_len:
    lb $t3, 0($t1)
    beqz $t3, dh_date_done
    addi $t2, $t2, 1
    addi $t1, $t1, 1
    j dh_date_len
dh_date_done:
    li $t4, 8
    bne $t2, $t4, datahora_err

    la $t1, temp_time
    li $t2, 0
dh_time_len:
    lb $t3, 0($t1)
    beqz $t3, dh_time_done
    addi $t2, $t2, 1
    addi $t1, $t1, 1
    j dh_time_len
dh_time_done:
    li $t4, 6
    bne $t2, $t4, datahora_err

    # parse date/time components using s0/s1 for constants
    # s2 will be used to store year separately to avoid conflicts
    li $s0, '0'
    li $s1, 10

    # parse day (DD)
    la $t1, temp_date
    lb $t5, 0($t1)
    lb $t6, 1($t1)
    sub $t5, $t5, $s0
    sub $t6, $t6, $s0
    mul $t7, $t5, $s1
    add $t7, $t7, $t6     # day in $t7

    # parse month (MM)
    lb $t5, 2($t1)
    lb $t6, 3($t1)
    sub $t5, $t5, $s0
    sub $t6, $t6, $s0
    mul $t8, $t5, $s1
    add $t8, $t8, $t6     # month in $t8

    # parse year (AAAA) into $s2
    lb $t2, 4($t1)
    lb $t3, 5($t1)
    lb $t4, 6($t1)
    lb $t9, 7($t1)
    sub $t2, $t2, $s0
    sub $t3, $t3, $s0
    sub $t4, $t4, $s0
    sub $t9, $t9, $s0
    li $s1, 1000
    mul $t5, $t2, $s1
    li $s1, 100
    mul $t6, $t3, $s1
    li $s1, 10
    mul $t2, $t4, $s1
    add $s2, $t5, $t6
    add $s2, $s2, $t2
    add $s2, $s2, $t9     # year in $s2 (separate register)

    # parse hour (HH)
    la $t1, temp_time
    lb $t2, 0($t1)
    lb $t3, 1($t1)
    li $s0, '0'
    sub $t2, $t2, $s0
    sub $t3, $t3, $s0
    li $s1, 10
    mul $t4, $t2, $s1
    add $t4, $t4, $t3     # hour in $t4

    # parse minute (MM)
    lb $t2, 2($t1)
    lb $t3, 3($t1)
    sub $t2, $t2, $s0
    sub $t3, $t3, $s0
    mul $t5, $t2, $s1
    add $t5, $t5, $t3     # minute in $t5

    # parse second (SS)
    lb $t2, 4($t1)
    lb $t3, 5($t1)
    sub $t2, $t2, $s0
    sub $t3, $t3, $s0
    mul $t6, $t2, $s1
    add $t6, $t6, $t3     # second in $t6

    # validate ranges: day 1..31, month 1..12, hour 0..23, min/sec 0..59, year >= 0
    li $t9, 1
    blt $t7, $t9, datahora_err
    li $t9, 31
    bgt $t7, $t9, datahora_err

    li $t9, 1
    blt $t8, $t9, datahora_err
    li $t9, 12
    bgt $t8, $t9, datahora_err

    li $t9, 0
    blt $s2, $t9, datahora_err

    li $t9, 23
    bgt $t4, $t9, datahora_err

    li $t9, 59
    bgt $t5, $t9, datahora_err
    bgt $t6, $t9, datahora_err

    # store dia, mes, ano, hora, minuto, segundo
    # values: day=$t7, month=$t8, year=$s2, hour=$t4, minute=$t5, second=$t6
    la $t0, dia
    sw $t7, 0($t0)
    la $t0, mes
    sw $t8, 0($t0)
    la $t0, ano
    sw $s2, 0($t0)
    la $t0, hora
    sw $t4, 0($t0)
    la $t0, minuto
    sw $t5, 0($t0)
    la $t0, segundo
    sw $t6, 0($t0)

    la $a0, msg_data_set
    li $v0, 4
    syscall
    jr $ra

datahora_err:
    la $a0, msg_data_invalid
    li $v0, 4
    syscall
    jr $ra
