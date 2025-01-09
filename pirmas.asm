.MODEL small
.STACK 100h
.DATA
    explanation db 'Programa pavercia ivesta desimtaini numeri i dvejetaini$'
    prompt      db 'Iveskite desimtaini numeri (0 - 65535): $'
    dvejetainis db 'Ivestas skaicius dvejetaine forma: $'
    invalid     db 'Ivestas skaicius turi buti desimtainis$'
    input       db 6, 0, 6 dup ('$')
    newline     db 0dh, 0ah, '$'
    two         dw 2
.CODE
strt:
    mov ax, @data
    mov ds, ax
    
    mov ah, 09h
    lea dx, explanation
    int 21h
    lea dx, newline
    int 21h
    lea dx, prompt
    int 21h                     ; teksto isvedimas
    
    mov ah, 0Ah
    lea dx, input
    int 21h                     ; input gavimas
    
    lea si, input+2             ; si - pointeris i input pradzia
    lea di, input+1             ; di - pointeris i ivestu simboliu kieki
    
    mov cl, [di]
    mov ah, 0
    mov ch, 0
    
    jmp check1
    
    check1:                     ; patikriname ar duoti simboliai yra (0-9)
        mov al, [si]
        inc si          
        cmp al, 30h
        jb error
        cmp al, 39h
        ja error
        dec cl
        cmp cl, 0
        jne check1
        je setup
        
    setup:                      
        mov cl, [di]
        mov bx, 0
        mov ch, 0
        mov sp, 1               ; sp - bus naudojamas dauginti skaiciui        V * 1 = 7 
        add di, cx              ; di - pointeris i paskutini skaiciu pvz. 123567 -> 7
        jmp stringIntoNumber    
        
    stringIntoNumber:        
        mov al, [di]
        mov ah, 0
        sub al, 30h
        mul sp
        add bx, ax
        
        mov ax, sp              ; sp padauginame is 10 kiekviena perejima pvz.  V * 100 = 500 (kai loopinama 3 karta)
        mov sp, 10              ;                                           1234567
        mul sp
        mov sp, ax
        
        dec di                  ; pamazinam di kad imtu skaiciu mazesniajame indexe  zr. virsutini komentara
        dec cl                  ; cl setup buvo issaugotas kaip keitamasis kuriame laikoma ivestu simboliu kiekis
        cmp cl, 0
        jne stringIntoNumber
        mov ax, bx
        mov cx, 0
        mov dx, 0
        je convert
        
    convert:
        div two
        push dx
        inc cx
        mov dx, 0
        cmp ax, 0
        jne convert
        mov ax, 0
        je setupPrint
        
    setupPrint:
        mov ah, 09h
        lea dx, newline
        int 21h
        lea dx, dvejetainis
        int 21h
    
    print:
        mov ah, 02h
        pop dx
        add dl, 30h
        int 21h
        dec cx
        cmp cx, 0
        jne print
        je finished
        
                    
    error:
        mov ah, 09h
        lea dx, newline
        int 21h
        lea dx, invalid
        int 21h
        mov ax, 4C00h
        int 21h
    finished:    
        mov ax, 4C00h
        int 21h
end strt