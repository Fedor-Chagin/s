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
    mov x2, #0        // результат = 0
    mov x3, #0        // счётчик = 0
    
mult_loop:
    cmp x3, x1        // сравниваем счётчик с множителем
    b.ge mult_end     // если >=, заканчиваем
    
    add x2, x2, x0    // результат += множимое
    add x3, x3, #1    // счётчик += 1
    b mult_loop
    
mult_end:
    mov x0, x2        // возвращаем результат
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

// as -o multiply.o multiply.s
// ld -o multiply multiply.o -lSystem -syslibroot `xcrun --sdk macosx --show-sdk-path` -e _start -arch arm64
// ./multiply
