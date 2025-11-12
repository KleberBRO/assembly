.data
    # ===== BANCO DE DADOS DE CLIENTES =====
    # cada cliente tem 128 bytes
    # CPF (11 bytes) | Conta (6 bytes) | DV (1 byte) | Nome (50 bytes) | Saldo (4 bytes) | 
    # CreditoDevido (4 bytes) | LimiteCredito (4 bytes) | ativo (1 byte) | padding

    clientes: .space 6400          # 50 clientes * 128 bytes
    num_clientes: .word 0          # Contador de clientes cadastrados

    # ===== DATA E HORA =====
    data_hora_str: .space 20       # "DD/MM/AAAA-HH:MM:SS\0"
    dia: .word 0
    mes: .word 0
    ano: .word 0
    hora: .word 0
    minuto: .word 0
    segundo: .word 0

    # ===== BUFFERS =====
    input_buffer: .space 256       # Buffer para entrada do usuário
    output_buffer: .space 512      # Buffer para output

    # ===== STRINGS DO SISTEMA =====
    banner: .asciiz "greenbank-shell>> "
    cmd_invalido: .asciiz "Comando invalido\n"
    newline: .asciiz "\n"

    # ===== ARQUIVO =====
    filename: .asciiz "dados_banco.dat"

    # Mensagens do sistema adicionadas
    msg_formatado: .asciiz "Todas as contas foram formatadas\n"
    msg_salvo: .asciiz "Dados salvos (stub)\n"
    msg_recarregado: .asciiz "Dados recarregados (stub)\n"

    # Buffers temporários para parsing de comandos
    temp_cpf: .space 12        # CPF + term
    temp_conta: .space 7       # conta (6) + term
    temp_nome: .space 64       # nome + term

    # Mensagens para conta_cadastrar
    msg_cliente_cadastrado_prefix: .asciiz "Cliente cadastrado com sucesso. Número da conta "
    msg_cpf_exists: .asciiz "Já existe conta neste CPF\n"
    msg_acc_in_use: .asciiz "Número da conta já em uso\n"
    msg_invalid_params: .asciiz "Parâmetros inválidos para conta_cadastrar\n"
    msg_db_full: .asciiz "Falha: limite de clientes atingido\n"

    # Buffers e mensagens para data_hora
    temp_date: .space 9        # DDMMAAAA + term
    temp_time: .space 7        # HHMMSS + term
    msg_data_set: .asciiz "Data e hora configuradas\n"
    msg_data_invalid: .asciiz "Data/hora inválida\n"

    # Labels de comparação (strings usadas apenas para strncmp)
    cmd_salvar_label: .asciiz "salvar"
    cmd_recarregar_label: .asciiz "recarregar"
    cmd_formatar_label: .asciiz "formatar"
    cmd_conta_cadastrar_label: .asciiz "conta_cadastrar-"
    cmd_data_hora_label: .asciiz "data_hora-"
