.include "data.asm"

.text
.globl main

main:
    # Carregar dados salvos (se existirem)
    jal load_data

    # Loop principal do terminal
main_loop:
    jal print_banner        # imprime banner
    jal read_input          # lê linha para input_buffer
    la $a0, input_buffer
    jal strip_newline       # remove '\n' final
    la $a0, input_buffer
    jal parse_command       # interpreta e executa comando
    j main_loop

    # Nunca chega aqui normalmente; exit placeholder
    li $v0, 10
    syscall

.include "utils.asm"
.include "handlers.asm"
.include "cmd_conta_cadastrar.asm"
.include "cmd_data_hora.asm"