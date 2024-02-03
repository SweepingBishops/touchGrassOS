[bits 16]
[org 0x7c00]
mov ah, 0x0e
mov bx, successMessage
mov cx, end
printMsg:
    mov al, [bx]
    cmp al, 0
    je jumpToCx
    int 0x10
    inc bx
    jmp printMsg

jumpToCx:
    jmp cx
successMessage:
    db 0xa, 0xd, "VBR Booted Successfully", 0xa, 0xd, 0;
end:
    db 0
times 510-($-$$) db 0
db 0x55, 0xAA
