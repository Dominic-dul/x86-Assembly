;Program fins all the letters in the given string
.MODEL small        ; atminties modelis
.STACK 100h         ; steko dydis
.DATA           ; duomenu segmentas

 
masyvas db 100,?, 100 dup('$') 

n db 0 

kita_eilute db 13,10,'$'

.CODE           ; kodo segmentas
strt:
mov ax,@data      ; ds registro inicializavimas
mov ds,ax 
;-------------------------------------------------


mov ah, 0ah 

mov dx, offset masyvas 
 
int 21h  

 
mov si, 2 
 

jmp start:


ciklas:

mov bl, [masyvas+si] 

inc si

cmp bl, '$'
je pabaiga

cmp bl, 41h
jb ciklas

cmp bl, 7Ah
ja ciklas

cmp bl, 5Ah
ja reziai:

testi:

prideti:
inc n
 


start:
jmp ciklas: 


reziai:
cmp bl, 61h
jb ciklas
cmp bl, 60h
ja testi: 



pabaiga: 
     
     
mov ah, 09h
mov dx, offset kita_eilute
int 21h


cmp n, 9h
ja jei_dvizenklis:
cmp n, 10h
jb vienzenklis:
 
 
jei_dvizenklis:
mov ah, 0
mov al, n


mov bl, 10

DIV bl



mov bh, ah
mov bl, al


add bh, 30h
add bl, 30h


mov ah, 02h

mov dl, bl 

int 21h



mov ah, 02h

mov dl, bh

int 21h

jmp galas:




vienzenklis:

mov dl, n

mov ah, 02h

add dl, 30h

int 21h

galas:

;------------------------------------------------
mov ax,4C00h      ; programos darbo pabaiga
int 21h
end strt