.global _start
.align 2

_start:
    adrp x0, array@PAGE
    add x0, x0, array@PAGEOFF  // адрес массива
    mov x1, #5                 // длина
    bl sum_array               // ТВОЯ ЗАДАЧА: написать эту функцию
    
    // сохранение результата
    mov x5, x0
    
    // вывод
    adrp x1, result@PAGE
    add x1, x1, result@PAGEOFF
    add x1, x1, #6             // "Sum: XX"
    mov x0, x5
    bl number_to_string
    
    // системный вызов
    mov x0, #1
    adrp x1, result@PAGE
    add x1, x1, result@PAGEOFF
    mov w2, #10
    mov x16, #4
    svc #0x80
    
    mov x0, #0
    mov x16, #1
    svc #0x80

sum_array:
    mov x10, x0          // x10 = адрес массива
    mov w11, #0          // w11 = сумма (аккумулятор) = 0
    mov x12, #0          // x12 = индекс = 0
    mov x13, #0          // x13 = смещение в байтах = 0
    
sum_loop:
    cmp x12, x1          // индекс < длины?
    b.ge sum_end         // если нет — выходим
    
    ldr w14, [x10, x13]  // w14 = array[смещение]
    add w11, w11, w14    // сумма += элемент
    
    add x12, x12, #1     // индекс++
    add x13, x13, #4     // смещение += 4 байта
    b sum_loop
    
sum_end:
    mov w0, w11          // возвращаем сумму в w0
    ret


number_to_string:
    mov x2, #10
    udiv x3, x0, x2      // x0 = число (22), x2 = 10
    msub x4, x3, x2, x0  // x4 = x0 - (x3 * 10)
    add x3, x3, #48
    add x4, x4, #48
    strb w3, [x1]
    strb w4, [x1, #1]
    ret

.data
array: .word 3, 7, 2, 9, 1  // сумма = 22
result: .ascii "Sum:    \n"

// as -o task7.o task7.s
// ld -o task7 task7.o -lSystem -syslibroot `xcrun --sdk macosx --show-sdk-path` -e _start -arch arm64
// ./task7