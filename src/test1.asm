Start:
	mov ax, 0x7c0
	mov ds, ax

Loop:
	mov di, bootMessage
	mov cx, Relocate
	jmp print

	Relocate:
		cli
		mov cx, 256
		mov si, 0x7c00
		mov di, 0x0600
		rep movsw 	; Relocating this code from 0x7c00 to 0x0600
		sti

		mov di, endMessage
		mov bx, End
		jmp print

print:
	mov ah, 0x0e
	mov al, [di]
	cmp al, 0
	je debug
	.continue:
	int 0x10
	inc di
	jmp print

debug:
	jmp cx

bootMessage:
	db "MBR Booted...", 0x0a, 0x0d, 0

endMessage:
	db "Ended...", 0x0a, 0x0d, 0

End:
times 510 - ($-$$) db 0
db 0x55, 0xaa
