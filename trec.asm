.model small
.stack 100h
.data
	senasIP dw ?
	senasCS dw ?
	
	regAX dw ?
	regBX dw ?
	regCX dw ?
	regDX dw ?
	regSP dw ?
	regBP dw ?
	regSI dw ?
	regDI dw ?
	
	baitas1 db ?
	baitas2 db ?
	baitas3 db ?
	baitas4 db ?
	
	indeksas db ?
	baitai db "al$", "cl$", "dl$", "bl$", "ah$", "ch$", "dh$", "bh$"
	baitai_reiksmes db 8 dup (?)
	baitai_ilg db 3
	zodziai db "ax$", "cx$", "dx$", "bx$", "sp$", "bp$", "si$", "di$"
	zodziai_reiksmes dw 8 dup (?)
	zodziai_ilg db 3
	rmmod00 db "[bx+si]$", "[bx+di]$", "[bp+si]$", "[bp+di]$", "   [si]$", "   [di]$", "   ta$", "   [bx]$"
	rmmod00_ilg db 8
	rmmod01 db "[bx+si+$", "[bx+di+$", "[bp+si+$", "[bp+di+$", "   [si+$", "   [di+$", "   [bp+$", "   [bx+$"
	rmmod01_ilg db 8
	enteris db 10,13,"$"
	mult db "mul $"
	al_lygu db "al= $"
	ax_lygu db "ax= $"
	lygu db "= $"
	word_ptr db "word ptr $"
	byte_ptr db "byte ptr $"
	pertraukimo_pranesimas db "Zingsninio rezimo pertraukimas! $"
	
.code
	mov ax, @data
	mov ds, ax
	
	mov ax, 0
	mov es, ax
	
	mov ax, es:[4]
	mov bx, es:[6]
	mov senasCS, bx
	mov senasIP, ax 
	
	mov ax, cs
	mov bx, offset pertraukimas
	
	mov es:[4], bx
	mov es:[6], ax
	
	pushf
	pop ax
	or ax, 100h
	push ax
	popf
	
;----------------------------------------------------
	nop
	mul byte ptr ds:[1234h]
	mul word ptr ds:[1255h]
	mul byte ptr ds:[6441h]
	mov al, 30h
	mov cl, 32h
	mul cl
	mul dl
	mul byte ptr [si]
	mov ax, 0312h
	mul byte ptr [bx+si]
	mov ax, 0999h
	mul word ptr [bx+si]
	mul ah
	mov si, 30h
	mul byte ptr [bx+si+32h]
	mul word ptr [bx+si+32h]
	mul dh
	mul word ptr [bx+si+3242h]
	mul dx
;----------------------------------------------------

	pushf
	pop  ax
	and  ax, 0FEFFh 
	push ax
	popf
	
	mov ax, senasIP
	mov bx, senasCS
	mov es:[4], ax
	mov es:[6], bx
	
	uzdaryti_programa:
	mov ah, 4Ch
	int 21h
	
pertraukimas:
	mov regAX, ax				
	mov regBX, bx
	mov regCX, cx
	mov regDX, dx
	mov regSP, sp
	mov regBP, bp
	mov regSI, si
	mov regDI, di
	
	pop si
	pop di
	push di
	push si
	
	mov baitai_reiksmes[0], al
	mov baitai_reiksmes[1], cl
	mov baitai_reiksmes[2], dl
	mov baitai_reiksmes[3], bl
	mov baitai_reiksmes[4], ah
	mov baitai_reiksmes[5], ch
	mov baitai_reiksmes[6], dh
	mov baitai_reiksmes[7], bh
	
	mov zodziai_reiksmes[0], ax
	mov zodziai_reiksmes[1], cx
	mov zodziai_reiksmes[2], dx
	mov zodziai_reiksmes[3], bx
	mov zodziai_reiksmes[4], sp
	mov zodziai_reiksmes[5], bp
	mov zodziai_reiksmes[6], si
	mov zodziai_reiksmes[7], di
	
	mov ax, cs:[si]
	mov bx, cs:[si+2]
	
	mov baitas1, al
	mov baitas2, ah
	mov baitas3, bl
	mov baitas4, bh

	cmp al, 0F6h ; baitais
	je toliau
	cmp al, 0F7h ; zodziais
	je toliau

	jmp uzbaigiam_pertraukima
	
	toliau:
		and ah, 00111000b
		cmp ah, 20h
		jne uzbaigiam_pertraukima
		
		mov ah, 9
		lea dx, pertraukimo_pranesimas
		int 21h
		
		mov ax, di
		call rasomAX
		
		mov ah, 2
		mov dl, ":"
		int 21h
		
		mov ax,si
		call rasomAX
		call rasomTarpa
		
		mov ah, baitas1
		mov al, baitas2
		call rasomAX
		
		
		mov ah, baitas2
		and ah, 11000000b
		cmp ah, 0h
		je be_poslinkio_atmintyje ; mod 00
		cmp ah, 40h
		je baito_poslinkis_atmintyje ; mod 01
		cmp ah, 80h
		je zodzio_poslinkis_atmintyje ; mod 10
		cmp ah, 0C0h
		je registras ; mod 11
	
	zodzio_poslinkis_atmintyje:
		call zodzio_poslinkis_atmintyje_proc
		jmp uzbaigta
	
	baito_poslinkis_atmintyje:
		call baito_poslinkis_atmintyje_proc
		jmp uzbaigta
	
	be_poslinkio_atmintyje:
		call be_poslinkio_atmintyje_proc
		jmp uzbaigta
	
	registras:
		call rasomTarpa
		call rasomMul
		mov al, baitas1
		and al, 00000001h
		cmp al, 0h
		je baitais
		jmp zodziais
		baitais:
		call registras_baitais
		jmp uzbaigta
		zodziais:
		call registras_zodziais
		
	uzbaigta:
	
	mov ah, 9
	lea dx, enteris
	int 21h
	
	uzbaigiam_pertraukima:
	mov ax, regAX
	mov bx, regBX
	mov cx, regCX
	mov dx, regDX
	mov sp, regSP
	mov bp, regBP
	mov si, regSI
	mov di, regDI
IRET

zodzio_poslinkis_atmintyje_proc:
	push ax
	push bx
	push dx
	push cx
		mov al, baitas3
		mov ah, baitas4
		call rasomAX
		call rasomTarpa
		call rasomMul
		mov cl, baitas1
		and cl, 00000001b
		cmp cl, 0h
		
		je rasom_byte_ptr_zodzio
		mov ah, 09h
		lea dx, word_ptr
		int 21h
		jmp jau_parasem_zodzio
		
		rasom_byte_ptr_zodzio:
		mov ah, 09h
		lea dx, byte_ptr
		int 21h
		jau_parasem_zodzio:
		mov bl, baitas2
		and bl, 00000111b
		mov bh, 0h
		mov indeksas, bl
		mov ax, bx
		mul rmmod01_ilg
		mov bx, ax
		lea dx, rmmod01[bx]
		mov ah, 09h
		int 21h
		mov al, baitas3
		mov ah, baitas4
		call rasomAX
		mov ah, 02h
		mov dl, "]"
		int 21h
		
		mov dl, ";"
		int 21h
		
		call rasomTarpa
		
		mov cl, baitas1
		and cl, 00000001b
		cmp al, 0h
		je rasom_al_lygu_zodzio
		mov ah, 09h
		lea dx, ax_lygu
		int 21h
		mov ax, regAX
		call rasomAX
		jmp uzbaigem_zodzio

		rasom_al_lygu_zodzio:
		mov ah, 09h
		lea dx, al_lygu
		int 21h
		mov ax, regAX
		call rasomAL
		
		uzbaigem_zodzio:
		call rasomTarpa
		call rmmod00_reiksmes
	pop cx
	pop dx
	pop bx
	pop ax	
RET

baito_poslinkis_atmintyje_proc:
	push ax
	push bx
	push dx
	push cx
		mov al, baitas3
		call rasomAL
		call rasomTarpa
		call rasomMul
		mov cl, baitas1
		and cl, 00000001b
		cmp cl, 0h
		
		je rasom_byte_ptr
		mov ah, 09h
		lea dx, word_ptr
		int 21h
		jmp jau_parasem
		
		rasom_byte_ptr:
		mov ah, 09h
		lea dx, byte_ptr
		int 21h
		jau_parasem:
		mov bl, baitas2
		and bl, 00000111b
		mov bh, 0h
		mov indeksas, bl
		mov ax, bx
		mul rmmod01_ilg
		mov bx, ax
		lea dx, rmmod01[bx]
		mov ah, 09h
		int 21h
		mov al, baitas3
		call rasomAL
		mov ah, 02h
		mov dl, "]"
		int 21h
		
		mov dl, ";"
		int 21h
		
		call rasomTarpa
		
		mov cl, baitas1
		and cl, 00000001b
		cmp al, 0h
		je rasom_al_lygu
		mov ah, 09h
		lea dx, ax_lygu
		int 21h
		mov ax, regAX
		call rasomAX
		jmp uzbaigem

		rasom_al_lygu:
		mov ah, 09h
		lea dx, al_lygu
		int 21h
		mov ax, regAX
		call rasomAL
		
		uzbaigem:
		call rasomTarpa
		call rmmod00_reiksmes
	pop cx
	pop dx
	pop bx
	pop ax
RET

rmmod00_reiksmes:
	push ax
	push bx
	push cx
	push dx
		mov bl, baitas2
		and bl, 00000111b
		cmp bl, 0h
		je bx_si
		cmp bl, 1h
		je bx_di
		cmp bl, 2h
		je bp_si
		cmp bl, 3h
		je bp_di
		cmp bl, 4h
		je rasom_si
		cmp bl, 5h
		je rasom_di
		cmp bl, 6h
		je rasom_bx
		bx_si:
			call rasomBXteksta
			call rasomSIteksta
			jmp surasem
		bx_di:
			call rasomBXteksta
			call rasomDIteksta
			jmp surasem
		bp_si:
			call rasomBPteksta
			call rasomSIteksta
			jmp surasem
		bp_di:
			call rasomDIteksta
			jmp surasem
		rasom_si:
			call rasomSIteksta
			jmp surasem
		rasom_di:
			call rasomDIteksta
			jmp surasem
		rasom_bx:
			call rasomBXteksta
			jmp surasem
		surasem:
	pop dx
	pop cx
	pop bx
	pop ax
RET

rasomBXteksta:
	push ax
	push dx
	push bx
		mov ah, 09h
		lea dx, zodziai[9]
		int 21h
		mov ah, 02h
		mov dl, "="
		int 21h
		call rasomTarpa
		mov ax, regBX
		call rasomAX
		call rasomTarpa
	pop bx
	pop dx
	pop ax
RET

rasomBPteksta:
	push ax
	push dx
	push bx
		mov ah, 09h
		lea dx, zodziai[15]
		int 21h
		mov ah, 02h
		mov dl, "="
		int 21h
		call rasomTarpa
		mov ax, regBP
		call rasomAX
		call rasomTarpa
	pop bx
	pop dx
	pop ax
RET

rasomSIteksta:
	push ax
	push dx
	push bx
		mov ah, 09h
		lea dx, zodziai[18]
		int 21h
		mov ah, 02h
		mov dl, "="
		int 21h
		call rasomTarpa
		mov ax, regSI
		call rasomAX
		call rasomTarpa
	pop bx
	pop dx
	pop ax
RET

rasomDIteksta:
	push ax
	push dx
	push bx
		mov ah, 09h
		lea dx, zodziai[21]
		int 21h
		mov ah, 02h
		mov dl, "="
		int 21h
		call rasomTarpa
		mov ax, regDI
		call rasomAX
		call rasomTarpa
	pop bx
	pop dx
	pop ax
RET

be_poslinkio_atmintyje_proc:
	push ax
	push bx
	push dx
	push cx
		mov cl, baitas1
		and cl, 00000001b
		cmp cl, 0h
		je baito
		
		zodzio:
			mov bl, baitas2
			and bl, 00000111b
			cmp bl, 6h
			je ilgas_masininis
			jmp praleidziam_ilga_mas
			ilgas_masininis:
				mov ah, baitas3 
				mov al, baitas4
				call rasomAX
				call rasomTarpa
				call rasomMul
				mov ah, 9h
				lea dx, word_ptr
				int 21h
				jmp praleidziam
			praleidziam_ilga_mas:
			call rasomTarpa
			call rasomMul
			mov ah, 9h
			lea dx, word_ptr
			int 21h
			jmp praleidziam
			
		baito:
			mov bl, baitas2
			and bl, 00000111b
			cmp bl, 6h
			je ilgas_masininis_bai
			jmp praleidziam_ilga_mas_bai
			ilgas_masininis_bai:
				mov ah, baitas3 
				mov al, baitas4
				call rasomAX
				call rasomTarpa
				call rasomMul
				mov ah, 9h
				lea dx, byte_ptr
				int 21h
				jmp praleidziam
			praleidziam_ilga_mas_bai:
			call rasomTarpa
			call rasomMul
			mov ah, 9h
			lea dx, byte_ptr
			int 21h
			
		praleidziam:
		mov bl, baitas2
		and bl, 00000111b
		cmp bl, 6h
		je tiesioginis
		
		
		mov bh, 0h
		mov indeksas, bl
		mov ax, bx
		mul rmmod00_ilg
		mov bx, ax
		lea dx, rmmod00[bx]
		mov ah, 9h
		int 21h
		mov ah, 2h
		mov dl, ";"
		int 21h
				
		jmp pabaiga
		tiesioginis:
			call tiesioginis_ad
			mov ah, 2h
			mov dl, ";"
			int 21h
		pabaiga:
		mov cl, baitas1
		and cl, 00000001b
		cmp cl, 0h
		je al_bus
		ax_bus:
		call rasomTarpa
		mov ah, 9h
		lea dx, ax_lygu 
		int 21h
		mov ax, regAX
		call rasomAX
		
		jmp pabaiga_tikr
		al_bus:
		call rasomTarpa
		mov ah, 9h
		lea dx, al_lygu
		int 21h
		mov ax, regAX
		call rasomAL
		
		
		pabaiga_tikr:
		call rasomTarpa
		call rmmod00_reiksmes
	pop cx
	pop dx
	pop bx
	pop ax
RET

tiesioginis_ad:
	push ax
	push dx
		mov ah, 2h
		mov dl, "["
		int 21h
		
		mov ah, baitas4
		mov al, baitas3
		call rasomAX
		
		mov ah, 2h
		mov dl, "]"
		int 21h
	pop dx
	pop ax
RET
registras_baitais:
	push ax
	push bx
	push dx
			mov bl, baitas2
			and bl, 00000111b
			mov bh, 0h
			mov indeksas, bl
			mov ax, bx
			mul baitai_ilg
			mov bx, ax
			lea dx, baitai[bx]
			mov ah, 9h
			int 21h
			
			mov ah, 2h
			mov dl, ";"
			int 21h
			call rasomTarpa
			call informacija_baito
	pop dx
	pop bx
	pop ax
RET

registras_zodziais:
	push ax
	push bx
	push dx
			mov bl, baitas2
			and bl, 00000111b
			mov bh, 0h
			mov indeksas, bl
			mov ax, bx
			mul zodziai_ilg
			mov bx, ax
			lea dx, zodziai[bx]
			mov ah, 9h
			int 21h
			
			mov ah, 2h
			mov dl, ";"
			int 21h
			call rasomTarpa
			call informacija_zodzio
	pop dx
	pop bx
	pop ax
RET

informacija_baito:
	lea dx, al_lygu
	mov ah, 9h
	int 21h
		
	mov ax, regAX
	call rasomAL
	
	call rasomTarpa
	
	lea dx, baitai[bx]
	mov ah, 9h
	int 21h
	
	mov ah, 2h
	mov dl, "="
	int 21h
	call rasomTarpa
	
	mov bl, indeksas
	mov bh, 0h
	mov al, baitai_reiksmes[bx]
	call rasomAL
	
RET

informacija_zodzio:
	lea dx, ax_lygu
	mov ah, 9h
	int 21h
		
	mov ax, regAX
	call rasomAX

	call rasomTarpa
	
	lea dx, zodziai[bx]
	mov ah, 9h
	int 21h
	
	mov ah, 2h
	mov dl, "="
	int 21h
	call rasomTarpa
	
	mov bl, indeksas
	mov bh, 0h
	mov ax, zodziai_reiksmes[bx]
	call rasomAX
	
RET

rasomAX:
	push ax
	mov al, ah
	call rasomAL
	pop ax
	call rasomAL
RET

rasomMul:
	push ax
	push dx
		mov ah, 9h
		lea dx, mult
		int 21h
	pop dx
	pop ax
RET

rasomAL:
	push ax
	push cx
		push ax
		mov cl, 4
		shr al, cl
		call printHexSkaitmuo
		pop ax
		call printHexSkaitmuo
	pop cx
	pop ax
RET

printHexSkaitmuo:
	push ax
	push dx
	
	and al, 0Fh ;nunulinam vyresniji pusbaiti AND al, 00001111b
	cmp al, 9
	jbe PrintHexSkaitmuo_0_9
	jmp PrintHexSkaitmuo_A_F
	
	PrintHexSkaitmuo_A_F: 
	sub al, 10 ;10-15 ===> 0-5
	add al, 41h
	mov dl, al
	mov ah, 2; spausdiname simboli (A-F) is DL'o
	int 21h
	jmp PrintHexSkaitmuo_grizti
	
	
	PrintHexSkaitmuo_0_9: ;0-9
	mov dl, al
	add dl, 30h
	mov ah, 2 ;spausdiname simboli (0-9) is DL'o
	int 21h
	jmp printHexSkaitmuo_grizti
	
	printHexSkaitmuo_grizti:
	pop dx
	pop ax
RET

rasomTarpa:
	push ax
	push dx
		mov ah, 2
		mov dl, " "
		int 21h
	pop dx
	pop ax
RET

END