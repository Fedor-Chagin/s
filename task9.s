.global _start
.align 4

uart_init:
    // TODO: настроить делитель 115200
    // TODO: включить UART
    ret

uart_putc:
    // w0 = символ для отправки (байт)
    ldr x1, =0x09000018      // адрес UARTFR
    
    // Ждём готовности (бит 5 = 0)
    1: ldrb w2, [x1]         // читаем флаги
       tst w2, #0x20         // проверяем бит 5 (TXFF)
       b.ne 1b               // если 1 (FIFO полон) — ждём
    
        // Отправляем символ
        ldr x1, =0x09000000      // адрес UARTDR
        strb w0, [x1]            // записываем символ
    
        ret
    ret

uart_puts:
    // TODO: цикл по строке
    // TODO: вызывать uart_putc
    ret






.global _start
.align 4

_start:
    // 1. Пробуем записать в UART (если он есть)
    ldr x0, =0x09000000  // UARTDR регистр данных
    
    // Проверяем флаг "готов к передаче" (бит 5 в UARTFR)
    ldr x1, =0x09000018  // UARTFR регистр флагов
    ldrb w2, [x1]
    and w2, w2, #0x20    // маска бита 5
    // Если w2 != 0, UART готов
    
    // Отправляем тестовый байт
    mov w3, #'X'
    strb w3, [x0]
    
    // 2. Выход через семихостинг
    ldr x0, =msg
    bl puts
    mov x0, #0
    mov x1, #0x18
    hlt #0xf000

puts: // (функция вывода через семихостинг)
    mov x1, x0
    1: ldrb w2, [x1], #1
        cbnz w2, 1b
    sub x2, x1, x0
    sub x2, x2, #1
    mov x1, x0
    mov x0, #4
    hlt #0xf000
    ret

msg: .asciz "UART test completed\n"