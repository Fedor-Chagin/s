.global _start
.align 2

_start:
    mov x0, #5        // множимое
    mov x1, #3        // множитель
    bl multiply       // вызываем функцию умножения
    // результат в x0 (15)
    
    // Подготовка вызова number_to_string
    adrp x1, result@PAGE
    add x1, x1, result@PAGEOFF
    add x1, x1, #8    // позиция для цифр в "Result: XX"
    bl number_to_string
    
    // Выводим результат
    mov x0, #1        // stdout
    adrp x1, result@PAGE
    add x1, x1, result@PAGEOFF
    mov x2, #10       // длина строки
    mov x16, #4       // write
    svc #0x80
    
    // Завершаем
    mov x0, #0
    mov x16, #1
    svc #0x80

multiply:
    mov x2, #0      // результат
    mov x3, #0      // счётчик битов
mult_loop:
    tst x1, #1      // проверяем младший бит множителя
    beq skip_add    // если 0 – не прибавляем
    add x2, x2, x0  // прибавляем множимое
skip_add:
    lsl x0, x0, #1  // сдвигаем множимое влево (умножаем на 2)
    lsr x1, x1, #1  // сдвигаем множитель вправо (делим на 2)
    add x3, x3, #1
    cmp x3, #64     // 64 бита в регистре
    b.lt mult_loop
    mov x0, x2
    ret

number_to_string:
    // x0 = число (0-99), x1 = адрес буфера
    mov x2, #10           // делитель = 10
    
    // Получаем десятки: x3 = x0 / 10
    udiv x3, x0, x2       // x3 = десятки
    
    // Получаем единицы: x4 = x0 % 10  
    msub x4, x3, x2, x0   // x4 = x0 - (x3 * 10)
    
    // Преобразуем в ASCII
    add x3, x3, #48       // десятки -> ASCII
    add x4, x4, #48       // единицы -> ASCII
    
    // Сохраняем в буфер
    strb w3, [x1]         // сохраняем десятки
    strb w4, [x1, #1]     // сохраняем единицы (+1 байт)
    
    ret

.data
result: .ascii "Result:  \n"

// as -o task4.o task4.s
// ld -o task4 task4.o -lSystem -syslibroot `xcrun --sdk macosx --show-sdk-path` -e _start -arch arm64
// ./task4
