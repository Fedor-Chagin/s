.global _start
.align 2

_start:
    adrp x0, array@PAGE
    add x0, x0, array@PAGEOFF  // x0 = адрес массива
    mov x1, #5                 // x1 = длина массива
    bl find_max
    // x0 = максимальное число
    
    // Сохраняем результат
    mov x5, x0
    
    // Выводим
    adrp x1, result@PAGE
    add x1, x1, result@PAGEOFF
    add x1, x1, #8             // "Max: XX"
    mov x0, x5
    bl number_to_string
    
    // Системный вызов write
    mov x0, #1
    adrp x1, result@PAGE
    add x1, x1, result@PAGEOFF
    mov x2, #10
    mov x16, #4
    svc #0x80
    
    // Завершение
    mov x0, #0
    mov x16, #1
    svc #0x80

find_max:
    ldr w2, [x0, #0]
    ldr w3, [x0, #4]
    cmp w2, w3
    b.gt label_0
    back_0:
    ldr w2, [x0, #8]
    cmp w2, w3
    b.gt label_1
    back_1:
    ldr w2, [x0, #12]
    cmp w2, w3
    b.gt label_2
    back_2:
    ldr w2, [x0, #16]
    cmp w2, w3
    b.gt label_3
    back_3:
    mov w0, w3
    ret

label_0:
mov w3, w2
b back_0

label_1:
mov w3, w2
b back_1

label_2:
mov w3, w2
b back_2

label_3:
mov w3, w2
b back_3

number_to_string:
    mov x2, #10
    udiv x3, x0, x2
    msub x4, x3, x2, x0
    add x3, x3, #48
    add x4, x4, #48
    strb w3, [x1]
    strb w4, [x1, #1]
    ret

.data
array: .word 3, 7, 2, 9, 1
result: .ascii "Max:    \n"

// as -o task6.o task6.s
// ld -o task6 task6.o -lSystem -syslibroot `xcrun --sdk macosx --show-sdk-path` -e _start -arch arm64
// ./task6


//ldr xn = [адрес, смещение]