.global _start
.align 2

_start:
    // 1. Печатаем приглашение
    mov x0, #1          // stdout
    adrp x1, prompt@PAGE
    add x1, x1, prompt@PAGEOFF
    mov x2, #prompt_len
    mov x16, #4         // write
    svc #0x80

    // 2. Читаем имя
    mov x0, #0
    adrp x1, name@PAGE
    add x1, x1, name@PAGEOFF
    mov x2, #32
    mov x16, #3
    svc #0x80
    mov x19, x0          // СОХРАНИЛИ реальную длину в x19!

    // 3. Печатаем приветствие
    mov x0, #1
    adrp x1, hello@PAGE
    add x1, x1, hello@PAGEOFF
    mov x2, #hello_len
    mov x16, #4
    svc #0x80

    // 4. Печатаем введённое имя
    mov x0, #1
    adrp x1, name@PAGE
    add x1, x1, name@PAGEOFF
    mov x2, x19          // ИСПОЛЬЗУЕМ реальную длину вместо #32!
    mov x16, #4
    svc #0x80
    
    // Печатаем перевод строки
mov x0, #1
adrp x1, newline@PAGE
add x1, x1, newline@PAGEOFF
mov x2, #1
mov x16, #4
svc #0x80

    // 5. Завершаем
    mov x0, #0
    mov x16, #1
    svc #0x80

.data
prompt: .ascii "Enter your name: "
prompt_len = . - prompt

hello: .ascii "Hello, "
hello_len = . - hello
newline: .ascii "\n"

name: .space 32         // резервируем 32 байта под имя