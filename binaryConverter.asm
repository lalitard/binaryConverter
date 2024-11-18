.data
    prompt1: .asciiz "Ingrese un numero decimal: "
    prompt2: .asciiz "Ingrese un numero binario de 8 bits: "
    prompt3: .asciiz "El numero binario es: "
    prompt4: .asciiz "El numero decimal es: "
    prompt5: .asciiz "Opcion no valida.\n"
    prompt6: .asciiz "Numero aleatorio en decimal: "
    newline: .asciiz "\n"
    binary: .space 9  # Espacio para almacenar un binario de 8 bits
    random_num: .word 0
    invalid_input: .asciiz "Entrada invalida. Intente nuevamente.\n"
.text
    .globl main

main:
    # Mostrar menú
    li $v0, 4
    la $a0, prompt1  # "Elija una opcion"
    syscall

menu:
    # Mostrar el menú
    li $v0, 4
    la $a0, prompt1  # "Elija una opción"
    syscall
    li $v0, 5  # Leer entero
    syscall
    move $t0, $v0  # Almacenar la opción

    # Si la opción es 1 (Decimal a Binario)
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
    # Solicitar número decimal
    li $v0, 4
    la $a0, prompt1
    syscall
    li $v0, 5  # Leer entero
    syscall
    move $t1, $v0  # Almacenar el número decimal

    # Convertir a binario y mostrar
    li $t2, 0  # Contador para bits
    li $t3, 0  # Usado para almacenar el bit

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
    li $v0, 8  # Leer cadena de binario
    la $a0, binary
    syscall

    # Validar que el binario tenga exactamente 8 bits
    li $t2, 0  # Contador de caracteres leídos
    li $t3, 8  # Límite de 8 bits
    validate_bin:
        lb $t4, binary($t2)  # Cargar el carácter binario
        beqz $t4, end_of_string  # Si llegamos al final de la cadena, salir
        li $t5, 48  # '0' en ASCII
        li $t6, 49  # '1' en ASCII
        beq $t4, $t5, valid_char
        beq $t4, $t6, valid_char
        li $v0, 4
        la $a0, invalid_input  # Mensaje de entrada inválida
        syscall
        j binario_a_decimal  # Volver a pedir entrada

    valid_char:
        addi $t2, $t2, 1  # Incrementar el contador de caracteres
        bne $t2, $t3, validate_bin  # Continuar validando hasta 8 bits

    # Imprimir mensaje de validación exitosa y convertir a decimal
    li $v0, 4
    la $a0, prompt4
    syscall

    # Convertir binario a decimal
    li $t1, 0  # Decimal resultante
    li $t2, 0  # Contador de posición
    li $t3, 8  # Asumimos 8 bits

bin_to_dec_loop:
    lb $t4, binary($t2)  # Cargar el carácter binario
    beqz $t4, end_of_string
    li $t5, 48  # '0' en ASCII
    li $t6, 49  # '1' en ASCII
    sub $t4, $t4, $t5  # Convertir '0'/'1' a 0/1
    mul $t1, $t1, 2  # Multiplicar por 2 (shifting)
    add $t1, $t1, $t4  # Sumar el bit
    addi $t2, $t2, 1
    bne $t2, $t3, bin_to_dec_loop

end_of_string:
    li $v0, 4
    la $a0, prompt4
    syscall

    li $v0, 1
    move $a0, $t1
    syscall
    j menu

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
