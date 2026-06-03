.global _start
.align 2

_start:
    // Инициализация кучи
    adrp x0, heap_start@PAGE
    add x0, x0, heap_start@PAGEOFF
    bl heap_init
    
    // Тест 1: выделяем 16 байт
    mov x0, #16
    bl my_malloc
    mov x19, x0  // сохраняем указатель
    
    // Тест 2: выделяем ещё 8 байт  
    mov x0, #8
    bl my_malloc
    mov x20, x0
    
    // Освобождаем первый блок
    mov x0, x19
    bl my_free
    
    // Выводим результат
    bl print_test_result
    
    // Завершаем
    mov x0, #0
    mov x16, #1
    svc #0x80

// ЗАДАЧИ:
    // Инициализировать кучу
    // Установить начальный указатель
heap_init:
    // x0 уже содержит адрес heap_start!
    
    // Сохраняем heap_ptr
    adrp x1, heap_ptr@PAGE
    add x1, x1, heap_ptr@PAGEOFF
    str x0, [x1]              // heap_ptr = heap_start
    
    // Вычисляем и сохраняем heap_end
    add x2, x0, #1024         // x2 = heap_start + 1024
    adrp x1, heap_end@PAGE
    add x1, x1, heap_end@PAGEOFF
    str x2, [x1]              // heap_end = heap_start + 1024
    ret

my_free:
    ret

my_malloc:
    adrp x1, heap_ptr@PAGE
    add x1, x1, heap_ptr@PAGEOFF
    ldr x3, [x1]              // текущий указатель
    mov x4, x3                // сохраняем для возврата
    
    add x3, x3, x0            // новый указатель
    adrp x5, heap_end@PAGE
    add x5, x5, heap_end@PAGEOFF
    ldr x5, [x5]              // heap_end
    
    cmp x3, x5
    b.gt no_memory            // если нет места
    
    str x3, [x1]              // обновляем heap_ptr
    mov x0, x4                // возвращаем адрес
    ret

print_test_result:
    mov x0, #1          // stdout
    adrp x1, result_msg@PAGE
    add x1, x1, result_msg@PAGEOFF
    mov x2, #16         // "Memory test: OK\n" = 16 байт
    mov x16, #4         // write
    svc #0x80
    ret

no_memory:
    mov x0, #0                // возвращаем NULL
    ret

.data
heap_ptr: .quad 0
heap_start: .space 1024  // 1КБ для кучи
heap_end: .quad 0  // место для хранения конца кучи
result_msg: .ascii "Memory test: OK\n"
no_memory_msg: .ascii "No memory\n"
// as -o task8.o task8.s
// ld -o task8 task8.o -lSystem -syslibroot `xcrun --sdk macosx --show-sdk-path` -e _start -arch arm64
// ./task8