.data
    prompt1: .asciiz "Ingrese una opcion 1) Convetir Dec-Bin | 2) Convertir Bin-Dec | 3) Generar Aleatorio: "
    prompt2: .asciiz "Ingrese un numero binario de 8 bits: "
    error_msg: .asciiz "\nError: Debe ingresar exactamente 8 dígitos binarios (0 o 1)\n"
    prompt3: .asciiz "El numero binario es: "
    prompt4: .asciiz "El numero decimal es: "
    prompt5: .asciiz "Opcion no valida.\n"
    prompt6: .asciiz "Numero aleatorio en decimal: "
    prompt7: .asciiz "Ingrese un numero decimal: "
    input: .space 9     # 8 bits + null terminator
    newline: .asciiz "\n"
    binary: .space 9  # Espacio para almacenar un binario de 8 bits
    random_num: .word 0
    invalid_input: .asciiz "Entrada invalida. Intente nuevamente.\n"
.text
    .globl main

main:
    # Mostrar menú
    j menu

menu:
    li $v0, 4
    la $a0, prompt1  # "Elija una opcion"
    syscall
    li $v0, 5  # Leer entero
    syscall
    move $t0, $v0  # Almacenar la opción

    # Si la opción es 1 (Decimal a Binario
    beq $t0, 1, decimal_a_binario

    # Si la opción es 2 (Binario a Decimal)
    beq $t0, 2, binario_a_decimal

    # Si la opción es 3 (Generar número aleatorio)
    beq $t0, 3, generar_aleatorio

    # Si no es ninguna opción válida
    li $v0, 4
    la $a0, prompt5
    syscall
    j menu

decimal_a_binario:
    # Solicitar número decimal al usuario
    li $v0, 4           # Imprimir mensaje
    la $a0, prompt7
    syscall

decimal_to_bin_loop:
    div $t1, $t1, 2  # Dividir entre 2
    mfhi $t3  # Obtener el residuo (bit)
    addi $t2, $t2, 1
    # Guardar el bit
    sw $t3, binary($t2)

    # Repetir hasta que el número sea 0
    bnez $t1, decimal_to_bin_loop

    # Imprimir el número binario
    li $v0, 4
    la $a0, prompt3
    syscall

    # Imprimir el binario (invertido)
    li $t2, 7  # Imprimir los 8 bits
    print_bin:
        lw $t3, binary($t2)
        li $v0, 1
        move $a0, $t3
        syscall
        sub $t2, $t2, 1
        bgez $t2, print_bin
    j menu

binario_a_decimal:
# Solicitar número binario
    li $v0, 4
    la $a0, prompt2
    syscall
    
    # Leer string binario
    li $v0, 8
    la $a0, input
    li $a1, 9           # 8 caracteres + null
    syscall
    
    # Inicializar registros
    li $t0, 0          # Contador de dígitos
    li $t1, 0          # Resultado decimal
    la $t2, input      # Puntero al input
    
    # Verificar longitud y validar dígitos
check_length:
    lb $t3, ($t2)      # Cargar byte actual
    beq $t3, 10, end_check  # Si es newline (\n), terminar check
    beq $t3, 0, end_check   # Si es null terminator, terminar check
    
    # Verificar si es 0 o 1
    li $t4, 48         # ASCII '0'
    blt $t3, $t4, error
    li $t4, 49         # ASCII '1'
    bgt $t3, $t4, error
    
    # Incrementar contador y puntero
    addi $t0, $t0, 1
    addi $t2, $t2, 1
    
    j check_length

end_check:
    # Verificar si son exactamente 8 bits
    li $t4, 8
    bne $t0, $t4, error
    
    # Convertir a decimal
    la $t2, input      # Resetear puntero al inicio
    li $t0, 0          # Resetear contador
    li $t1, 0          # Resetear resultado
    
convert_loop:
    lb $t3, ($t2)      # Cargar byte actual
    beq $t3, 10, print_result  # Si es newline, terminar
    beq $t3, 0, print_result   # Si es null, terminar
    
    # Multiplicar resultado actual por 2
    sll $t1, $t1, 1
    
    # Convertir ASCII a valor numérico y sumar
    subi $t3, $t3, 48  # Convertir '0'/'1' a 0/1
    add $t1, $t1, $t3  # Sumar al resultado
    
    # Siguiente dígito
    addi $t2, $t2, 1
    addi $t0, $t0, 1
    j convert_loop

print_result:
    # Imprimir mensaje de resultado
    li $v0, 4
    la $a0, prompt4
    syscall
    
    # Imprimir número decimal
    li $v0, 1
    move $a0, $t1
    syscall
    
    # Imprimir newline
    li $v0, 4
    la $a0, newline
    syscall
    
    # Terminar programa
    j menu
error:
    # Mostrar mensaje de error
    li $v0, 4
    la $a0, error_msg
    syscall
    
    # Volver al main
    j main
    
    
    
    

generar_aleatorio:
    li $v0, 42  # Función para generar número aleatorio
    li $a0, 10  # Límite inferior
    li $a1, 50  # Límite superior
    syscall
    move $t1, $v0  # Número aleatorio
    li $v0, 4
    la $a0, prompt6
    syscall

    # Mostrar el número aleatorio en decimal
    li $v0, 1
    move $a0, $t1
    syscall

    # Mostrar el número aleatorio en binario
    li $t2, 0
    jal decimal_a_binario  # Llamada a la función de decimal a binario

    j menu
