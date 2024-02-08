;mov ax, 0x7c0
;mov ss, ax
;mov bp, 0
;mov sp, 0
;mov ax, 0x7d0
;mov ds, ax
;mov ax, 0x7c0
;mov cs, ax
mov [diskNum], dl

section .data
diskNum:
	db 'Q'

GDT_Start:
	null_descriptor:
		dd 0
		dd 0
	code_descriptor:
		dw 0xffff 	; first 16 bits of limit
		dw 0 		; first 
		db 0 		;  24 bits of the base
		db 0b10011010 	; pres, priv, type
		db 0b11001111 	; other flags, last 4 bits of limit
		db 0 		; last 8 bits of the base
	data_descriptor:
		dw 0xffff 	; first 16 bits of limit
		dw 0 		; first 
		db 0 		;  24 bits of the base
		db 0b10010010 	; pres, priv, type
		db 0b11001111 	; other flags, last 4 bits of limit
		db 0 		; last 8 bits of the base
	
	GDT_Descriptor:
		dw GDT_End - GDT_Start - 1  ; size
		dd GDT_Start
	CODE_SEG equ code_descriptor - GDT_Start
	DATA_SEG equ data_descriptor - GDT_Start
GDT_End:


section .text
cli
lgdt[GDT_Descriptor]

mov ah, 0x0e
mov al, 'T'
int 0x10
jmp $
 
times 510 - ($-$$) db 0
db 0x55, 0xAA
