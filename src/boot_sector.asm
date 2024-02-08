Start:
	xor ax, ax  	; Making the registers zero
	mov es, ax
	mov ss, ax
	mov sp, ax
	mov bp, ax
	mov dx, ax
	mov ax, 0x7c0
	mov cs, ax
	mov ds, ax

	mov bx, bootMessage
	mov cx, Relocate
	jmp print

	Relocate:
		cli
		mov cx, 256
		mov si, 0x7c00
		mov di, 0x7800
		rep movsw 	; Relocating this code from 0x7c00 to 0x0600

		mov ax, 0x780
		mov cs, ax
		mov ds, ax
	dbg1:
		mov bx, unsupportedLBAMsg
		mov cx, MBRBootStart
		jmp 0:print
		jmp MBRBootStart

MBRBootStart:
	sti;
	mov [bootDrive], dl

FindVBR:
	mov bx, bootPartition 		; move the pointer to the first pointer
	mov cl, 1 		;  sets up a counter
	mov al, [bx]
	.search_loop:
		test al, 0x80 	;  checks if the 7th bit is high or not
		jnz VBRFound 	; if the 7th bit is high the current partition is the active partition
		cmp cl, 4 		; there can be a maximum of 4 partitions
		jge NoBootFound
		inc cl
		add bx, 0x10 	;shifts the pointer by 16 bytes, i.e one partition
		mov al, [bx]
		jmp .search_loop

VBRFound:
	mov bx, VBRFoundMessage
	mov cx, check_LBA_support
	jmp print

LoadVBR_LBA:
	mov si, VBRDataPacket
	mov ah, 0x42
	mov dl, [bootDrive]
	int 0x13
	jc DiskReadError
	cmp ah, 0
	jne DiskReadError
	jmp 0x7c00

LoadVBR_CHS:
	jmp End

DiskReadError:
	mov bx, [diskReadErrorMsg]
	mov cx, End
	jmp print

NoBootFound:
	mov bx, [bootNotFound]
	mov cx, End
	jmp print

print:
	mov ah, 0x0e
	mov al, [bx]
	cmp al, 0
	je jump_to_cx
	int 0x10
	inc bx
	jmp print

jump_to_cx:
	jmp cx

check_LBA_support:
	clc
	mov ah, 0x41
	mov bx, 0x55aa
	mov dl, 0x80
	int 0x13            ; the carry bit is set if LBA is not available
	jc LoadVBR_CHS 	; use CHS in that case
	jmp LoadVBR_LBA


bootNotFound:
	db "Couldn't find VBR Boot partition...", 0x0a, 0x0d, 0

unsupportedLBAMsg:
	db "LBA not supported, switching to CHS...", 0x0a, 0x0d, 0

diskReadErrorMsg:
	db "Couldn't read from disk.", 0x0a, 0x0d, 0

bootMessage:
	db "MBR booted...", 0xa, 0xd, 0

VBRFoundMessage:
	db "VBR Found...", 0x0a, 0x0d, 0

bootDrive:
	db 0

VBRDataPacket:
	db 0x10 	;  size of packet (16 bytes)
	db 0 		;  always 0
	dw 1 		;  no of sectors to read
	dw 0x7c00 	;  where to store the data
	dw 0 		;  which memory page
	dd 1 		;  lower 32 bits of LBA address
	dd 0 		;  upper 16 buts of LBA address

bootPartition:
	db 0x80 			;  Active (bootable)
	db 0, 2, 0 			;  H C S of first sector in partition
	db 0x7f 			;  Custom filesystem
	db 0, 11, 0 		;  H C S of last sector in partition
	db 0, 0, 0, 1 		;  LBA of first sector
	db 0, 0, 0, 10 		;  number of sectors in partition

kernelPartition:
	times 16 db 0

devicePartition:
	times 16 db 0

unusedPartition:
	times 16 db 0

End:
times 510 - ($-$$) db 0
db 0x55, 0xaa
