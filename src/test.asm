[org 0x7c00]

mov bp, 0x8000
mov sp, bp
mov [diskNum], dl


start:
	mov bx, string
	call print_string


print_string:
	mov ah, 0x0e
	mov al, [bx]
	cmp al, 0
	je read
	cmp al, 0x0D
	int 0x10
	je next_line
	inc bx
	jmp print_string

string:
	db "Type Smthng: ", 0

char:
	db 0,0

next_line:
	push ax
	mov ah, 0x0e
	mov al, 0x0A
	int 0x10
	pop ax
	ret

read:
	mov ah, 0
	int 0x16
	mov [char], al
	mov bx, char
	call print_string

diskNum:
	db 0

out:
mov ah, 2  ; Disk read
mov al, 1  ; Read 1 sector
mov ch, 0  ; Cylinder no
mov cl, 2  ; Sector Number
mov dh, 0  ; Head Number
mov dl, [diskNum]
mov bx, 0
mov es, bx
mov bx, 0x7e00 ; es:bx pointer to where we want the data to be loaded
int 0x13
call print_string
times 510 - ($-$$) db 0
db 0x55, 0xaa
times 511 db '$'
db 0
db "THIS SHOULD NOT BE SEEN"
