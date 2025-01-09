.model small
.stack 100h
.data
    pagalbosTekstas db "Formatas: antra duomenufailas.txt rezultatufailas.txt", 10 , 13, '$'
    klaidaAtidarantDuom db "Klaida atidarant duomenu faila!", 10 , 13, '$'
    klaidaSukuriantRez db "Klaida sukuriant rezultato faila!", 10 , 13, '$'
    klaidaAtidarantRez db "Klaida atidarant rezultato faila!", 10 , 13, '$'
    klaidaSkaitantBuf db "Ivyko klaida skaitant bufferi!", 10 , 13, '$'
    duomPavadinimas db 40 dup(0)
    rezPavadinimas db 40 dup(0)
    skaitymoBufferis db 10 dup(?)
    rasymoBufferis db 10 dup(?)
    nuskaitytaSimboliu dw 0
    vietaSkaitymoBufferyje dw 0 ; bus naudojama suskaicuoti kelintas simbolis bufferyje
    vietaRasymoBufferyje dw 0   ; simbolis rasymo bufferyje
    deskriptoriusSkaitymui dw ?
    deskriptoriusRasymui dw ?
    simbolis db ?
    rasomSkaiciu db 0 ; naudosim kaip bool; 0 - jei nerasom 1 - jei rasom
    failoPabaiga db 0
    
    nulisr   db "nulis"
    vienasr  db "vienas"
    dur      db "du"
    trysr    db "trys"
    keturir  db "keturi"
    penkir   db "penki"
    sesir    db "sesi"
    septynir db "septyni"
    astuonir db "astuoni"
    devynir  db "devyni"
    
.code
	mov ax, @data
	mov ds, ax
    
    mov bx, 81h
    mov cx, 0
    lea si, duomPavadinimas
    
    cmp byte ptr es:[80h], 0
    je pagalbosPranesimas
    
    cmp es:[82h], '?/'
    jne randamDuomPavadinima
    
    pagalbosPranesimas:
        mov ah, 09h
        lea dx, pagalbosTekstas
        int 21h
		call uzbaigiamPrograma
        
      randamDuomPavadinima:
        cmp byte ptr es:[bx], 20h  
        je kitasBaitas
        mov dl, byte ptr es:[bx]   
        mov [si], dl
        inc si               
        inc bx                  
        cmp byte ptr es:[bx], 20h 
        je tarpinisRezultatas
        jne randamDuomPavadinima 
        
    
    tarpinisRezultatas:
        call paskutiniaiSimboliai
        lea si, rezPavadinimas
        jmp randamRezPavadinima

    randamRezPavadinima:
        cmp byte ptr es:[bx], 20h   
        je kitasBaitasRez
        mov dl, byte ptr es:[bx]    
        mov [si], dl
        inc si                      
        inc bx                       
        cmp byte ptr es:[bx], 0Dh  
        je tarpinisPavadinimams
        jne randamRezPavadinima
    
    tarpinisPavadinimams:
        call paskutiniaiSimboliai
        jmp tesiamProgramaNuskaicius
    
    kitasBaitas:
        inc bx                  
        jmp randamDuomPavadinima           

    kitasBaitasRez:
        inc bx                           
        jmp randamRezPavadinima          
    

	tesiamProgramaNuskaicius:
	call atidarom
	jc klaidaAtidarant
	call sukuriamRasymui
	jc klaidaSukuriant
    call atidaromRasymui
    jc klaidaAtidarantRasymui
    jmp rasomFaila
    
    klaidaSukuriant:
        mov ah, 09h
        lea dx, klaidaSukuriantRez
        int 21h
        call uzbaigiamPrograma
    klaidaAtidarant:
        mov ah, 09h
        lea dx, klaidaAtidarantDuom  
        int 21h
        call uzbaigiamPrograma
    klaidaAtidarantRasymui:
        mov ah, 09h
        lea dx, klaidaAtidarantRez  
        int 21h
        call uzbaigiamPrograma
            
    rasomFaila:
        call paimamIsBufferio ; grazina simbolis (priskyrem al)
        cmp failoPabaiga, 1
        je uzbaigiamTarpinis
        
        cmp simbolis, 30h
        je rasomNulis
        cmp simbolis, 31h
        je rasomVienas
        cmp simbolis, 32h
        je rasomDu
        cmp simbolis, 33h
        je rasomTrys
        cmp simbolis, 34h
        je rasomKeturi
        cmp simbolis, 35h
        je rasomPenki
        cmp simbolis, 36h
        je rasomSesi
        cmp simbolis, 37h
        je rasomSeptyni
        cmp simbolis, 38h
        je rasomAstuoni
        cmp simbolis, 39h
        je rasomDevyni
        
        isvedamSimboli:
        call rasomBufferin
        jmp rasomFaila
        
    rasomNulis:
        lea dx, nulisr
        mov cx, 5
        call rasomEiluteIBufferi
        jmp rasomFaila      
            
    rasomVienas:
        lea dx, vienasr
        mov cx, 6
        call rasomEiluteIBufferi
        jmp rasomFaila
        
    rasomDu:
        lea dx, dur
        mov cx, 2 
        call rasomEiluteIBufferi
        jmp rasomFaila
    
	uzbaigiamTarpinis:
		jmp uzbaigiam
    
    rasomTrys:
        lea dx, trysr
        mov cx, 4
        call rasomEiluteIBufferi
        jmp rasomFaila
        
    rasomKeturi:
        lea dx, keturir
        mov cx, 6
        call rasomEiluteIBufferi
        jmp rasomFaila
    
    rasomPenki:
        lea dx, penkir
        mov cx, 5
        call rasomEiluteIBufferi
        jmp rasomFaila
        
    rasomSesi:
        lea dx, sesir
        mov cx, 4
        call rasomEiluteIBufferi
        jmp rasomFaila
    
    rasomSeptyni:
        lea dx, septynir
        mov cx, 7
        call rasomEiluteIBufferi
        jmp rasomFaila
        
    rasomAstuoni:
        lea dx, astuonir
        mov cx, 7
        call rasomEiluteIBufferi
        jmp rasomFaila
        
    rasomDevyni:
        lea dx, devynir
        mov cx, 6
        call rasomEiluteIBufferi
        jmp rasomFaila         
        
    uzbaigiam:
        call rasomFailan
        call uzbaigiamPrograma
    
    PROC paskutiniaiSimboliai
        push bx
            dec bx
            cmp byte ptr es:[bx], 74h
            jne blogasFailoFormatas
            dec bx
            cmp byte ptr es:[bx], 78h
            jne blogasFailoFormatas
            dec bx
            cmp byte ptr es:[bx], 74h
            jne blogasFailoFormatas
            dec bx
            cmp byte ptr es:[bx], 2Eh
            jne blogasFailoFormatas
        pop bx
        RET
    ENDP paskutiniaiSimboliai
    
    blogasFailoFormatas:
        mov ah, 09h
        lea dx, pagalbosTekstas 
        int 21h
        call uzbaigiamPrograma
        
    
    PROC atidarom
            push ax
            push dx
                mov ax, 3D00h
                lea dx, duomPavadinimas
                int 21h
                jc atidaromPabaiga
                mov deskriptoriusSkaitymui, ax
    atidaromPabaiga:
        pop ax
        pop dx
        RET
    ENDP atidarom
    
    PROC sukuriamRasymui
        push ax
        push cx
            mov ah, 3Ch
            mov cx, 0
            lea dx, rezPavadinimas
            int 21h
        pop cx
        pop ax
        RET 
    ENDP sukuriamRasymui
    
    PROC paimamIsBufferio
        push ax
        push bx
        push cx
        push dx
            mov ax, vietaSkaitymoBufferyje
            mov bx, nuskaitytaSimboliu
            
            cmp ax, bx
            jb simbolisIsBufferio
            jmp skaitomBufferi
    
            simbolisIsBufferio:
                lea bx, skaitymoBufferis
                add bx, vietaSkaitymoBufferyje
                
                mov al, [bx]
                mov simbolis, al
                
                inc vietaSkaitymoBufferyje
            jmp paimamIsBufferioPabaiga
            
            SkaitomBufferi:
                mov ah, 3Fh
                mov bx, deskriptoriusSkaitymui
                mov cx, 10
                lea dx, skaitymoBufferis
                int 21h
                jc klaidaSkaitantBufferi ;; error here
                mov nuskaitytaSimboliu, ax
                mov vietaSkaitymoBufferyje, 0
                
                cmp nuskaitytaSimboliu, 0
                je failasPasibaige
            jmp simbolisIsBufferio
            
            failasPasibaige:
                mov failoPabaiga, 1
            jmp paimamIsBufferioPabaiga
            
            paimamIsBufferioPabaiga:
        pop dx
        pop cx
        pop bx
        pop ax
            mov al, simbolis
        RET
    ENDP paimamIsBufferio
    
    klaidaSkaitantBufferi:
        mov ah, 09h
        lea dx, klaidaSkaitantBuf
        int 21h
        call uzbaigiamPrograma
        
    
    PROC atidaromRasymui
        push ax
        push dx
            mov ax, 3D01h
            lea dx, rezPavadinimas
            int 21h
            jc atidaromRasymuiPabaiga
            mov deskriptoriusRasymui, ax
    atidaromRasymuiPabaiga:
        pop dx
        pop ax
        RET
    ENDP atidaromRasymui
    
    PROC rasomBufferin
        push ax
        push bx
        push cx
        push dx
            mov ax, vietaRasymoBufferyje
            mov bx, 10
            cmp ax, bx
            jb toliauRasom
          
            call rasomFailan
            
            toliauRasom:
                lea bx, rasymoBufferis
                add bx, vietaRasymoBufferyje
                
                cmp rasomSkaiciu, 1
                je rasomSkaiciuJump
                 
                mov cl, simbolis
                
                rasomSkaiciuJump:    
                mov [bx], cl
                
                inc vietaRasymoBufferyje
        pop dx
        pop cx
        pop bx
        pop ax
        RET
    ENDP rasomBufferin
    
    PROC rasomFailan
        push ax
        push bx
        push cx
        push dx
        
            mov ah, 40h
            mov bx, deskriptoriusRasymui
            lea dx, rasymoBufferis
            mov cx, vietaRasymoBufferyje
            int 21h
    
            mov vietaRasymoBufferyje, 0
    
        pop dx
        pop cx
        pop bx
        pop ax     
        RET
    ENDP rasomFailan
    
    PROC uzdaromSkaityma
        push ax
        push dx
            mov ah, 3Eh
            mov bx, deskriptoriusSkaitymui
            int 21h
        pop dx
        pop ax
        RET
    ENDP uzdaromSkaityma
    
    PROC uzdaromRasyma
        push ax
        push dx
            mov ah, 3Eh
            mov bx, deskriptoriusRasymui
            int 21h
        pop dx
        pop ax
        RET
    ENDP uzdaromRasyma
    
    PROC uzbaigiamPrograma
        mov ax, 4C00h
        int 21h
        RET
    ENDP uzbaigiamPrograma
    
    PROC rasomEiluteIBufferi
        push si
        push ax
        push cx
        push dx
        
        mov rasomSkaiciu, 1
        
        mov si, dx 
        mov bx, cx
        rasomCiklas:
            mov cl, [si]             
            call rasomBufferin       
            inc si
            dec bx
            jnz rasomCiklas          
            mov rasomSkaiciu, 0
        pop dx
        pop cx
        pop ax
        pop si
        ret
    ENDP rasomEiluteIBufferi
END
