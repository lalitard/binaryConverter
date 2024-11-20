.data
    menu: .asciiz "\nMenu:\n1. Convertir Decimal a Binario\n2. Convertir Binario a Decimal\n3. Generar un numero aleatorio\n4. Salir\nSeleccione una opcion: "
    prompt1: .asciiz "\nIngrese un numero decimal: "
    prompt2: .asciiz "\nIngrese un numero binario de 8 bits: "
    prompt3: .asciiz "\nEl numero binario es: "
    prompt4: .asciiz "\nEl numero decimal es: "
    prompt5: .asciiz "\nOpcion no valida. Intente de nuevo.\n"
    prompt6: .asciiz "\nNumero aleatorio en decimal: "
    newline: .asciiz "\n"
    binary: .space 8  # Espacio para los 8 bits del número binario
    invalid_input: .asciiz "\nEntrada invalida. Intente nuevamente.\n"
.text
    .globl main

main:
    # Mostrar menú y leer opción del usuario
    li $v0, 4
    la $a0, menu
    syscall

    li $v0, 5  # Leer entero
    syscall
    move $t0, $v0  # Guardar la opción en $t0

    # Opciones del menú
    beq $t0, 1, decimal_a_binario
    beq $t0, 2, binario_a_decimal
    beq $t0, 3, generar_aleatorio
    beq $t0, 4, salir

    # Opción no válida
    li $v0, 4
    la $a0, prompt5
    syscall
    j main  # Volver a mostrar el menú

decimal_a_binario:
    # Solicitar número decimal
    li $v0, 4
    la $a0, prompt1
    syscall

    li $v0, 5  # Leer número decimal
    syscall
    move $t1, $v0  # Guardar el número decimal en $t1

    # Convertir decimal a binario
    la $t2, binary          # Dirección base para almacenar los bits
    addi $t2, $t2, 7        # Apuntar al último byte del array (8 bits - 1)
    li $t3, 8               # Contador para 8 bits

dec_to_bin_loop:
    beqz $t3, print_binary  # Si el contador llega a 0, terminar
    sub $t3, $t3, 1         # Decrementar el contador
    rem $t4, $t1, 2         # Obtener el bit menos significativo
    sb $t4, 0($t2)          # Guardar el bit en la posición actual
    div $t1, $t1, 2         # Dividir el número entre 2
    subi $t2, $t2, 1        # Retroceder al siguiente byte
    j dec_to_bin_loop

print_binary:
    # Mostrar resultado binario
    li $v0, 4
    la $a0, prompt3
    syscall

    la $t2, binary
    li $t3, 8
print_binary_loop:
    beqz $t3, finish_binary
    lb $t4, 0($t2)
    addi $t4, $t4, 48  # Convertir a carácter ASCII ('0' o '1')
    li $v0, 11
    move $a0, $t4
    syscall
    addi $t2, $t2, 1
    subi $t3, $t3, 1
    j print_binary_loop

finish_binary:
    li $v0, 4
    la $a0, newline
    syscall
    j main

binario_a_decimal:
    # Solicitar número binario
    li $v0, 4
    la $a0, prompt2
    syscall

    # Leer cadena de binario
    li $v0, 8  # Leer hasta 8 caracteres
    la $a0, binary
    li $a1, 9  # Espacio para 8 caracteres + '\0'
    syscall

    # Asegurar terminación de cadena
    la $t2, binary
    addi $t2, $t2, 8  # Posición del carácter 9
    sb $zero, 0($t2)  # Escribir '\0'

    # Validar longitud de la entrada
    li $t3, 8  # Longitud esperada
    la $t2, binary
    li $t4, 0
validate_length:
    lb $t5, 0($t2)  # Leer un carácter
    beqz $t5, validate_end  # Si es '\0', salir
    addi $t4, $t4, 1
    addi $t2, $t2, 1
    j validate_length
validate_end:
    bne $t4, $t3, invalid_bin  # Si la longitud no es 8, error

    # Convertir cadena binaria a número decimal
    la $t2, binary  # Dirección base del array de bits
    li $t1, 0       # Resultado decimal inicializado en 0
    li $t3, 8       # Contador para 8 bits
bin_to_dec_loop:
    beqz $t3, print_decimal  # Si el contador llega a 0, terminar
    lb $t4, 0($t2)           # Leer un carácter (byte) de la cadena
    sub $t4, $t4, 48         # Convertir de ASCII a valor numérico ('0' o '1')
    bltz $t4, invalid_bin    # Si el valor es negativo, entrada inválida
    bgt $t4, 1, invalid_bin  # Si el valor es mayor a 1, entrada inválida
    mul $t1, $t1, 2          # Desplazar a la izquierda (multiplicar por 2)
    add $t1, $t1, $t4        # Sumar el bit actual
    addi $t2, $t2, 1         # Avanzar al siguiente carácter
    subi $t3, $t3, 1         # Decrementar el contador
    j bin_to_dec_loop

add_bit:
    mul $t1, $t1, 2  # Desplazar a la izquierda (multiplicar por 2)
    addi $t1, $t1, 1  # Sumar 1
    j continue_loop

skip_bit:
    mul $t1, $t1, 2  # Desplazar a la izquierda (multiplicar por 2)

continue_loop:
    addi $t2, $t2, 1  # Avanzar al siguiente carácter
    addi $t3, $t3, -1 # Decrementar el contador
    b bin_to_dec_loop

print_decimal:
    # Mostrar resultado decimal
    li $v0, 4
    la $a0, prompt4
    syscall
    li $v0, 1
    move $a0, $t1
    syscall
    j main  # Volver al menú

invalid_bin:
    li $v0, 4
    la $a0, invalid_input
    syscall
    j main  # Volver al menú

generar_aleatorio:
    # Inicializar la semilla con el tiempo actual
    li $v0, 30      # Syscall para obtener el tiempo en milisegundos
    syscall
    move $a1, $v0   # Usar el tiempo como semilla
    li $v0, 43      # Syscall para inicializar la semilla del generador aleatorio
    syscall

    # Generar un número aleatorio
    li $v0, 42      # Syscall para random
    syscall
    move $t0, $v0   # Guardar el número aleatorio generado

    # Asegurar que esté en el rango [10, 50]
    li $t1, 41      # Rango (50 - 10 + 1)
    rem $t0, $t0, $t1  # $t0 = $t0 % 41
    addi $t0, $t0, 10  # Desplazar al rango 10 - 50

    # Mostrar el número aleatorio en decimal
    li $v0, 4
    la $a0, prompt6
    syscall
    li $v0, 1
    move $a0, $t0
    syscall

    # Convertir el número aleatorio a binario
    move $t1, $t0   # Copiar el número para convertirlo
    la $t2, binary  # Dirección base para almacenar los bits
    li $t3, 8       # Contador para 8 bits

rand_to_bin_loop:
    beqz $t3, print_binary  # Si el contador llega a 0, terminar
    sub $t3, $t3, 1         # Decrementar el contador
    rem $t4, $t1, 2         # Obtener el bit menos significativo
    sb $t4, 0($t2)          # Guardar el bit en la posición actual
    div $t1, $t1, 2         # Dividir el número entre 2
    addi $t2, $t2, 1        # Avanzar al siguiente byte
    j rand_to_bin_loop


salir:
    li $v0, 10  # Syscall para terminar el programa
    syscall
