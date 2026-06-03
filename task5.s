.global _start
.align 2

_start:
    mov x0, #8        
    mov x1, #7        
    bl add_numbers     // x0 = 15
    mov x5, x0        // сохраняем результат
    
    // ПОДГОТОВКА АРГУМЕНТОВ для number_to_string:
    adrp x1, result@PAGE      // 1. адрес строки в x1
    add x1, x1, result@PAGEOFF
    add x1, x1, #6            // 2. смещение к "Sum: XX"
    mov x0, x5                // 3. число 15 в x0
    bl number_to_string       // вызов!
    mov x1, x0
    // Вывод результата
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

add_numbers:
    add x2, x0, x1
    mov x0, x2
    ret

number_to_string:
    // (функция из прошлого задания)
    mov x2, #10
    udiv x3, x0, x2
    msub x4, x3, x2, x0
    add x3, x3, #48
    add x4, x4, #48
    strb w3, [x1]
    strb w4, [x1, #1]
    ret

.data
result: .ascii "Sum:    \n"

// as -o task5.o task5.s
// ld -o task5 task5.o -lSystem -syslibroot `xcrun --sdk macosx --show-sdk-path` -e _start -arch arm64
// ./task5
