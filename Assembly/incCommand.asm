;Program that recognises command INC r/m and prints it's machine code and all the info about it
.model small
.stack 100h
.data
	regAX dw ?
	regBX dw ?
	regCX dw ?
	regDX dw ?
	regSP dw ? 
	regBP dw ?
	regSI dw ?
	regDI dw ?	
	;komandu galimi variantai
	reg_bxsi db "BX + SI$"
	reg_bxdi db "BX + DI$"
	reg_bpsi db "BP + SI$"
	reg_bpdi db "BP + DI$"
	reg_si db "SI$" 
	reg_di db "DI$"
	reg_bp db "BP$"
	
	reg_ax db "AX$"
	reg_al db "AL$"
	reg_ah db "AH$"
	reg_bx db "BX$"
	reg_bl db "BL$"
	reg_bh db "BH$"
	reg_cx db "CX$"
	reg_cl db "CL$"
	reg_ch db "CH$"
	reg_dx db "DX$"
	reg_dl db "DL$"
	reg_dh db "DH$"
	reg_sp db "SP$"
	
	;Saugomos baitu reiksmes
	opk db ?
	adb db ?
	posl1 db ?
	posl2 db ?
	
	;Skaicius testavimui
	testinis db ?
	number dw 0FFFFh
	;w mod ir r/m reiksmes
	cw db ?
	cmod db ?
	crm db ?
	
	;komandu tekstas
	pranesimas db "Zingsnio rezimo pertraukimas! ", 13, 10, '$'
	inc_komanda db "INC $"
	byte_ptr db "byte ptr $"
	word_ptr db "word ptr $"	
	
	plius db " + $" 
	lygu db " = $"
	brac_open db "[$"
	brac_close db "]$"	
	dvitaskis db ":$"
	kablelis db ",$"	
	enteris db 13,10,"$"
	tarpas db " $"
	
.code
;Isspausdina paduota string'a
PrintString MACRO tekstas 
	push ax
	push dx
	mov dx, offset tekstas
	mov ah, 9
	int 21h
	pop dx
	pop ax
ENDM
;Macros'ai tikrina r/m reiksmes skirtingais variantais
TikrinkRM MACRO _rm, tekstas  
	mov al, _rm
	mov dx, offset tekstas
	call printRM
ENDM
TikrinkRM_value MACRO _rm, tekstas, reiksme 
	mov al, _rm
	mov dx, offset tekstas
	mov bx, reiksme
	call printRM
ENDM
TikrinkRM_1 MACRO _rm, tekstas1, reiksme1
	mov al, _rm
	mov dx, offset tekstas1
	mov bx, reiksme1
	call extra
ENDM

TikrinkRM_2 MACRO _rm, tekstas1, reiksme1, tekstas2, reiksme2
	push bx
	mov al, _rm
	mov dx, offset tekstas1
	mov bx, reiksme1
	call extra
	mov dx, offset tekstas2
	mov bx, reiksme2
	call extra
	pop bx
ENDM
pradzia:
	mov ax, @data
	mov ds, ax
	
	;es reiksme pasidarome nuliu, isivalome pakeitimui
	mov ax, 0
	mov es, ax
	
	;Pasiemame reiksmes is vektoriaus lenteles pagal INT 1
	mov ax, es:[4] 
	mov bx, es:[6]
	
	;Pasiemame dabartines cs ir pertraukimo proceduros reiksmes, padedame i vektoriu lentele
	mov ax, cs; 
	mov bx, offset pertraukimas
	
	;reiksmiu i vektoriu lentele padejimas
	mov es:[4], bx
	mov es:[6], ax
	
	;TRAP FLAG nustatymas = INT 1 vykdymas
	zingsninio_rez_aktyvavimas:
	pushf
	pop ax
	or ax, 100h
	push ax
	popf
	
	testavimo_kodas:
	mov bx, offset number
	inc word ptr [bx]

	;INT 1 isjungimas
	zingsninio_rez_isjungimas:
	pushf
	pop ax
	and ax, 0FEFFh
	push ax
	popf

	pabaiga:	
	mov ah, 4Ch
	mov al, 0
	int 21h
	
pertraukimas:
	;Issisaugomos registru reiksmes
	mov regAX, ax				
	mov regBX, bx
	mov regCX, cx
	mov regDX, dx
	mov regSP, sp
	mov regBP, bp
	mov regSI, si
	mov regDI, di

	;Pasiimame komandos poslinki (AA)
	pop si
	pop di
	push di
	push si

	mov ax, cs:[si]
	mov bx, cs:[si+2]
	
	;Issaugome 4 komandos baitus
	mov opk, al
	mov adb, ah
	mov posl1, bl
	mov posl2, bh
		
	tikrinimas:
	mov al, opk
	mov ah, adb
	
	;Tikriname, ar komanda yra inc
	;Pagal opk
	push ax
	and al, 0FEh
	cmp al, 0FEh 
	jne pert_pabaiga_jump 
	;Pagal adb
	and ah, 38h 
	cmp ah, 0 
	jne pert_pabaiga_jump
	pop ax
	
	;Issisaugom w, mod, rm reiksmes
	push ax
	and al, 01h
	mov cw, al 
	pop ax
	
	push ax
	and ah, 0C0h
	mov cmod, ah
	pop ax
	
	push ax
	and ah, 07h
	mov crm, ah
	pop ax
		
	jmp komandos_analize
	pert_pabaiga_jump:
	jmp pert_pabaiga
	
	komandos_analize:
	;Spausdiname masinini koda
	PrintString pranesimas
	
	mov ax, di
	call printZodinisRegistras
	PrintString dvitaskis
	mov ax, si
	call printZodinisRegistras
	PrintString tarpas
	
	mov al, opk
	call printBaitinisRegistras
	mov al, adb
	call printBaitinisRegistras

	;Tikriname, ar reikia dar spausdinti poslinki po adb
	cmp cmod, 0C0h
	je incMOD11
	
	cmp cmod, 0
	jne test_kiek_offset_print
	
	cmp crm, 06h
	je print_2_offset_bytes ; atskiras atvejism kai mod = 00, rm = 110
	jmp no_print_offset_bytes
	
	test_kiek_offset_print:
		cmp cmod, 040h
		je print_1_offset_byte
	print_2_offset_bytes:
		mov al, posl2
		call printBaitinisRegistras
		mov al, posl1
		call printBaitinisRegistras
		jmp no_print_offset_bytes
	print_1_offset_byte:
		mov al, posl1
		call printBaitinisRegistras

	no_print_offset_bytes:
		PrintString tarpas
		
	jmp komandos_isvedimas
	;Kai mod = 11	
	incMOD11:
	PrintString tarpas
	PrintString inc_komanda
	cmp cw, 0
	jne w_1
	PrintString tarpas
	jmp tikrinu_rm_w_0
	
	w_1:
	PrintString word_ptr
	
	TikrinkRM_value 00h, reg_ax,regAX
	TikrinkRM_value 01h, reg_cx,regCX
	TikrinkRM_value 02h, reg_dx,regDX
	TikrinkRM_value 03h, reg_bx,regBX
	TikrinkRM_value 04h, reg_sp,regSP
	TikrinkRM_value 05h, reg_bp,regBP
	TikrinkRM_value 06h, reg_si,regSI
	TikrinkRM_value 07h, reg_di,regDI
	PrintString enteris
	jmp pert_pabaiga
		
	tikrinu_rm_w_0:
	
	TikrinkRM_value 00h, reg_al,regAX
	TikrinkRM_value 01h, reg_cl,regCX
	TikrinkRM_value 02h, reg_dl,regDX
	TikrinkRM_value 03h, reg_bl,regBX
	TikrinkRM_value 04h, reg_ah,regSP
	TikrinkRM_value 05h, reg_ch,regBP
	TikrinkRM_value 06h, reg_dh,regSI
	TikrinkRM_value 07h, reg_bh,regDI
	PrintString enteris
	jmp pert_pabaiga
	
	;Inc komandos isvedimas su argumentais
	komandos_isvedimas:
	PrintString inc_komanda
	cmp cw, 0
	je w0
	PrintString word_ptr
	jmp mod_rm_analize
	
	w0:
	PrintString byte_ptr

	mod_rm_analize:
	PrintString brac_open
		
	cmp cmod, 0
	jne rm_analize
	cmp crm, 06h
	je su_2_b_offset ; atskiras atvejis, kai mod = 00, rm = 110
	
	;Kas inc'reasinama
	rm_analize:
	TikrinkRM 00h, reg_bxsi
	TikrinkRM 01h, reg_bxdi
	TikrinkRM 02h, reg_bpsi
	TikrinkRM 03h, reg_bpdi
	TikrinkRM 04h, reg_si
	TikrinkRM 05h, reg_di
	TikrinkRM 06h, reg_bp
	TikrinkRM 07h, reg_bx
					
	tikr_offset:
		cmp cmod, 0
		je be_offset
	su_offset:
		PrintString plius
		cmp cmod, 80h
		je su_2_b_offset
	su_1_b_offset:
		mov al, posl1
		call printBaitinisRegistras
		jmp be_offset
	su_2_b_offset:
		mov al, posl2
		call printBaitinisRegistras
		mov al, posl1
		call printBaitinisRegistras
	PrintString brac_close
	PrintString kablelis
			
	;atskiras atvejis baigimui  (kai mod = 00 , r/m = 110)
	cmp cmod, 0
	jne value
	cmp crm, 06h
	je pert_pabaiga_temp
	jmp value
	pert_pabaiga_temp:
	jmp pert_pabaiga_NL

	be_offset:
	PrintString brac_close
	PrintString kablelis
	value:
	
	;Ka inc'reasinom
	TikrinkRM_2 00h, reg_bx, regBX, reg_si, regSI
	TikrinkRM_2 01h, reg_bx, regBX, reg_di, regDI
	TikrinkRM_2 02h, reg_bp, regBP, reg_si, regSI
	TikrinkRM_2 03h, reg_bp, regBP, reg_di,regDI
	TikrinkRM_1 04h, reg_si, regSI
	TikrinkRM_1 05h, reg_di, regDI
	TikrinkRM_1 06h, reg_bp, regBP
	TikrinkRM_1 07h, reg_bx, regBX	
		
	pert_pabaiga_NL:
	PrintString enteris
	pert_pabaiga:
		
	mov ax, regAX
	mov bx, regBX
	mov cx, regCX
	mov dx, regDX
	mov sp, regSP
	mov bp, regBP
	mov si, regSI
	mov di, regDI
iret
printRM proc
	;al -> rm reiksme, dx - string'o adresas
	cmp al, crm 
	jne netinka 
	push ax
	mov ah, 9
	int 21h
	pop ax
	cmp cmod, 0C0h
	jne netinka
		;Jeigu mod = 11
		PrintString kablelis
		PrintString tarpas
		push ax
		push bx
		mov ah, 9
		int 21h
		PrintString lygu
		cmp cw, 1
		je w_didesnis
		mov ax, bx
		call printBaitinisRegistras
		jmp pabaigti_spausdinima
		w_didesnis:
		mov ax, bx
		call printBaitinisRegistras
		mov al, ah
		call printBaitinisRegistras
		pabaigti_spausdinima:
		pop bx
		pop ax
	netinka:
		ret
endp
;Spausdina zodini registra, kuris saugomas AX
printZodinisRegistras proc
	push ax
	mov al, ah
	call printBaitinisRegistras
	pop ax
	call printBaitinisRegistras
	RET
endp
;Spausdina baitini registra, kuris yra saugomas AL
printBaitinisRegistras proc
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
endp
;Spausdina hex skaitmeni pagal AL jaunesniji pusbaiti
printHexSkaitmuo proc
	push ax
	push dx
	;nunulinam vyresniji pusbaiti
	and al, 0Fh 
	cmp al, 9
	jbe PrintHexSkaitmuo_0_9
	jmp PrintHexSkaitmuo_A_F
	
	PrintHexSkaitmuo_A_F: 
	sub al, 10 
	add al, 41h
	mov dl, al
	mov ah, 2
	int 21h
	jmp PrintHexSkaitmuo_grizti
	
	
	PrintHexSkaitmuo_0_9: 
	mov dl, al
	add dl, 30h
	mov ah, 2 
	int 21h
	
	printHexSkaitmuo_grizti:
	pop dx
	pop ax
	RET
endp	
extra proc
	push ax
	cmp al, crm 
	jne netinka2
	PrintString tarpas
	push ax
	call printRM
	PrintString lygu
	mov ax, bx
	call printZodinisRegistras
		PrintString kablelis
		pop ax
		PrintString brac_open
		call printRM
		PrintString brac_close
		PrintString lygu
		mov ax, [bx]
		call PrintZodinisRegistras
	netinka2:
	pop ax
	ret
endp
END