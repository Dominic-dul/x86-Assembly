;Program that transforms integers into words from a text file and prints it in the results file
.model small
skBufDydis	EQU 50		
raBufDydis	EQU 200			

.stack 100h
.data 
	duom	db 20 dup (0)		;duomenu failo pavadinimo bufferis, pasibaigiantis nuliniu simboliu
	rez	    db 20 dup (0)		    ;rezultatu failo pavadinimo bufferis, pasibaigiantis nuliniu simboliu
	skBuf	db skBufDydis dup (0)	;skaitymo buferis
	raBuf	db raBufDydis dup (0)	;rasymo buferis
	dFail	dw ?			;vieta, skirta saugoti duomenu failo deskriptoriaus numeri
	rFail	dw ?			;vieta, skirta saugoti rezultato failo deskriptoriaus numeri
	klaidaAtidarantS db 'Ivyko klaida atidarant faila skaitymui', 13, 10,'$'
	klaidaAtidarantR db 'Ivyko klaida atidarant faila rasymui', 13, 10,'$'
	klaidaUzdarantR db 'Ivyko klaida uzdarant faila rasymui', 13, 10, '$'
	klaidaUzdarantS db 'Ivyko klaida uzdarant faila skaitymui', 13, 10, '$'
	klaidaS db 'Ivyko klaida skaitant faila', 13, 10, '$'
	klaidaR db 'Ivyko klaida rasant i faila', 13, 10, '$' 
	dalinisI db 'Buvo irasyti ne visi duomenys', 13, 10, '$'
	pagalbos_pranesimas db 'Programa pavercia skaicius i zodzius. Iveskite duomenu ir rezultatu failu pavadinimus', 13, 10, '$'
	
	vienasz db 'vienas', '$'
	duz db 'du', '$'
	trysz db 'trys', '$'
	keturiz db 'keturi', '$'
	penkiz db 'penki', '$'
	sesiz db 'sesi', '$'
	septyniz db 'septyni', '$'
	astuoniz db 'astuoni', '$'
	devyniz db 'devyni', '$'
	
.code
  
  pradzia:
	
	mov	ax, @data		
	mov	ds, ax		

;cmd tikrinimas
    ;iesko klaustuko
	mov ch, 0
	mov cl, es:[80h]
	cmp cx, 0
	je klaida
	
	mov bx, 81h
	
	push cx
	
	klaustukas:
	cmp es:[bx], '?/'
	
	je klaida
	inc bx
	loop klaustukas
	;iesko failu vardu
	pop cx
	mov bx, 82h
	dec cx;
	
	mov si, offset duom
	mov di, offset rez
	
	ivedimas:
	xor ax,ax
	mov ax, es:[bx]

	cmp al, 20h
	je rezultatai 
	
	mov [si], al
	inc si

	inc bx
	
	loop ivedimas
	

	rezultatai:
	
	inc bx
	xor ax, ax
	mov ax, es:[bx]
	
	cmp al, 13
	je nuskaite
	
	cmp al, 20h
	je nuskaite
	
	mov [di], al
	inc di
	
	
	loop rezultatai
    
    jmp nuskaite
    
   klaida:
    mov ah, 09h
    mov dx, offset pagalbos_pranesimas
    int 21h
	jmp pabaiga
     

nuskaite: 

;Duomenu failo atidarymas skaitymui

	mov	ah, 3Dh				
	mov	al, 00				;00 - failas atidaromas skaitymui
	mov	dx, offset duom		
	int	21h                
	jnc t1
	jmp klaidaAtidarantSkaitymui	;jei atidarant faila skaitymui ivyksta klaida, nustatomas carry flag 
	t1:
	
	mov	dFail, ax			;atmintyje issisaugom duomenu failo deskriptoriaus numeri

;Rezultato failo sukurimas ir atidarymas rasymui

	mov	ah, 3Ch				
	mov	cx, 0				;kuriamo failo atributai
	mov	dx, offset rez		
	int	21h				    
	jnc t2
	jmp klaidaAtidarantRasymui		;jei kuriant faila skaitymui ivyksta klaida, nustatomas carry flag
	t2:
	
	mov	rFail, ax			;atmintyje issisaugom rezultato failo deskriptoriaus numeri

;Duomenu nuskaitymas is failo

  skaityk:
	mov	bx, dFail			    ;i bx irasom duomenu failo deskriptoriaus numeri
	call	SkaitykBuf			;iskvieciame skaitymo is failo procedura
	cmp	ax, 0				    ;ax irasoma, kiek baitu buvo nuskaityta, jeigu 0 - pasiekta failo pabaiga
	jne t3
	jmp uzdarytiRasymui
	t3:

;Darbas su nuskaityta informacija
    
	mov	cx, ax 
	
	mov	si, offset skBuf
	mov	di, offset raBuf
	
  dirbk:
	mov	dl, [si]
	
	CMP dl, '0'
	jnb t4
	jmp tesk
	t4:
	
	CMP dl, '9'
	jna t5
	jmp tesk
	t5:
	
	SUB dl, 30h
	
	CMP dl, 1
	je vienas
	
	CMP dl, 2
	je du
	
	CMP dl, 3
	je trys
	
	CMP dl, 4
	jne p1 
	jmp keturi
	p1:
	
	CMP dl, 5
	jne t6
	jmp penki
	t6:
	
	CMP dl, 6
	jne t7
	jmp sesi
	t7:
	
	CMP dl, 7
	jne t8
	jmp septyni
	t8:
	
	CMP dl, 8
	jne t9
	jmp astuoni
	t9:
	
	CMP dl, 9
	jne t10
	jmp devyni
	t10:
  
  vienas:
  mov bx, offset vienasz
  call skaiciusIZodi
  jmp loopas
  
  du:
  mov bx, offset duz
  call skaiciusIZodi 
  jmp loopas
  
  trys:
  mov bx, offset trysz
  call skaiciusIZodi
  jmp loopas 
  
  keturi:
  mov bx, offset keturiz
  call skaiciusIZodi 
  jmp loopas
  
  penki:
  mov bx, offset penkiz
  call skaiciusIZodi
  jmp loopas 
  
  sesi:
  mov bx, offset sesiz
  call skaiciusIZodi 
  jmp loopas 
  
  septyni:
  mov bx, offset septyniz
  call skaiciusIZodi
  jmp loopas 
  
  astuoni:
  mov bx, offset astuoniz
  call skaiciusIZodi
  jmp loopas 
  
  devyni:
  mov bx, offset devyniz
  call skaiciusIZodi 
  jmp loopas  
    
    tesk:
	mov	[di], dl
	inc	si
	inc	di 
  
  loopas:
	dec cx
	cmp cx, 0
	jz finish
	jmp dirbk
	
  finish:

;Rezultato irasymas i faila

	mov	cx, ax				    ;cx - kiek baitu reikia irasyti
	mov	bx, rFail			    ;i bx irasom rezultato failo deskriptoriaus numeri
	call	RasykBuf			;iskvieèiame rasymo i faila procedura
	cmp	ax, skBufDydis			;jeigu vyko darbas su pilnu buferiu -> is duomenu failo buvo nuskaitytas pilnas buferis ->
	jne t11
	jmp skaityk	;-> reikia skaityti toliau
	t11:
;Rezultato failo uzdarymas

  uzdarytiRasymui:
	mov	ah, 3Eh				
	mov	bx, rFail			;i bx irasom rezultato failo deskriptoriaus numeri
	INT	21h				    
	JC	klaidaUzdarantRasymui		;jei uzdarant faila ivyksta klaida, nustatomas carry flag

;Duomenu failo uzdarymas

  uzdarytiSkaitymui:
	mov	ah, 3Eh				
	mov	bx, dFail			;i bx irasom duomenu failo deskriptoriaus numeri
	int	21h				    
	jc	klaidaUzdarantSkaitymui		;jei uzdarant faila ivyksta klaida, nustatomas carry flag
 
  pabaiga:
	mov	ah, 4Ch				
	mov	al, 0				
	int	21h				    
 
;-----------------------------------------------------
;Klaidu apdorojimas

  klaidaAtidarantSkaitymui:
  
	mov ah, 09h	
    mov dx, offset klaidaAtidarantS
    int 21h
    
	JMP	pabaiga
	
  klaidaAtidarantRasymui:
  
	mov ah, 09h	
    mov dx, offset klaidaAtidarantR
    int 21h
    
	JMP	uzdarytiSkaitymui
	
  klaidaUzdarantRasymui:
	
	mov ah, 09h	
    mov dx, offset klaidaUzdarantR
    int 21h
    
	JMP	uzdarytiSkaitymui 
	
  klaidaUzdarantSkaitymui:
  
	mov ah, 09h	
    mov dx, offset klaidaUzdarantS
    int 21h 
    
	JMP	pabaiga
    
  klaidaSkaitant: 
  
	mov ah, 09h	
    mov dx, offset klaidaS     
    int 21h 
    
	mov ax, 0			;Pazymime registre ax, kad nebuvo nuskaityta nei vieno simbolio
	JMP	SkaitykBufPabaiga 
	
  dalinisIrasymas: 
  
	mov ah, 09h	
    mov dx, offset dalinisI     
    int 21h 
    
	JMP	RasykBufPabaiga 
	  
  klaidaRasant: 
  
	mov ah, 09h	
    mov dx, offset klaidaR     
    int 21h
    
	mov	ax, 0			;Pazymime registre ax, kad nebuvo irasytas nei vienas simbolis
	JMP	RasykBufPabaiga	  
 
;--------------------------------------------------
PROC skaiciusIZodi
    push dx
    
  loopinti:
     xor dx, dx
     mov dx, [bx]
     mov [di], dx
     inc di
     inc bx
     inc ax
     
     cmp ds:[bx], byte ptr '$'
     je pabaigiau
     jmp loopinti
 
 pabaigiau:
 inc si
 pop dx
 RET 
     
   SkaiciusiZodi ENDP
;Procedura nuskaitanti informacija is failo
PROC SkaitykBuf
;i BX paduodamas failo deskriptoriaus numeris
;i AX bus grazinta, kiek simboliu nuskaityta
	PUSH	cx
	PUSH	dx
 
	mov	ah, 3Fh			    ;21h pertraukimo duomenu nuskaitymo funkcijos numeris
	mov	cx, skBufDydis		;cx - kiek baitu reikia nuskaityti is failo
	mov	dx, offset skBuf	;vieta, i kuria irasoma nuskaityta informacija
	int	21h			        ;skaitymas is failo
	jc	klaidaSkaitant		;jei skaitant is failo ivyksta klaida, nustatomas carry flag
 
  SkaitykBufPabaiga:
	POP	dx
	POP	cx
	RET
 
SkaitykBuf ENDP
 
;Procedura, irasanti buferi i faila
PROC RasykBuf
;i BX paduodamas failo deskriptoriaus numeris
;i CX - kiek baitu irasyti
;i AX bus grazinta, kiek baitu buvo irasyta
	PUSH	dx
 
	mov	ah, 40h			    ;21h pertraukimo duomenu irasymo funkcijos numeris
	mov	dx, offset raBuf	;vieta, is kurios rasom i faila
	int	21h			        ;rasymas i faila
	jc	klaidaRasant		;jei rasant i faila ivyksta klaida, nustatomas carry flag
	cmp	cx, ax			    ;jei cx nelygus ax, vadinasi buvo irasyta tik dalis informacijos
	jne	dalinisIrasymas
 
  RasykBufPabaiga:
	POP	dx
	RET
 
RasykBuf ENDP	
END pradzia