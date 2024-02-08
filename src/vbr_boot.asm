mov ah, 0x0e
mov bx, initialiseMsg
jmp print

print:
	mov al, [bx]
	cmp al, 0
	je End
	int 0x10
	inc bx
	jmp print

initialiseMsg:
	db "VBR Booted Successfully...", 0xa, 0xd, 0

End:
jmp $
