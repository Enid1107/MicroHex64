	org 0x7c00
BaseOfStack equ 0x7c00
BaseOfLoader equ 0x1000
OffsetOfLoader equ 0x00

RootDirSectors equ 14
SectorNumOfRootDirStart equ 19
SectorNumOfFAT1Start equ 1
SectorBalance equ 17

	jmp short Lable_Start
	nop
	BS_OEMName 		db 'MicroHex64'
	BPB_BytesPerSec dw 512
	BPB_SecPerClus  db 1
	BPB_RsvdSecCnt  dw 1
	BPB_NumFATs 	db 2
	BPB_RootEntCnt  dw 224
	BPB_TotSec16 	dw 2880
	BPB_Media 		db 0xf0
	BPB_FATSz16 	dw 9
	BPB_SecPerTrk 	dw 18
	BPB_NumHeads 	dw 2
	BPB_hiddSec 	dd 0
	BPB_TotSec32 	dd 0
	BS_DrvNum 		db 0
	BS_Reserved1 	db 0
	BS_BootSig 		db 29h
	BS_VolTD 		dd 0
	BS_VolLab 		db 'boot loader'
	BS_FileSysType  db 'FAT12'
	

Lable_Start :
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, BaseOfStack
	

;清屏
	mov ax, 0600h  
	mov bx, 0700h 
	mov cx, 0
	mov dx, 0184fh
	int 10h

	
;光标
	mov ax, 0200h
	mov bx, 0000h
	mov dx, 0000h
	int 10h
	

;初始屏幕
	mov ax, 1301h
	mov bx, 000fh
	mov dx, 0000h
	mov cx, 10
	push ax
	mov ax, ds
	mov es, ax
	pop ax
	mov bp, StartBootMessage 
	int 10h

;复位
	xor ah,ah
	xor dl,dl
	int 13h
	
	jmp $
	
StartBootMessage: db "Start Boot"
;填充
	times 510-($-$$) db 0
	dw 0xaa55
	
	
	
;软盘读取
Func_ReadOneSector:
	push bp
	mov bp, sp
	sub esp, 2 
	mov byte [bp-2], cl
	push bx 
	mov bl, [BPB_SecPerTrk]
	div bl
	inc ah
	mov cl, ah
	mov dh, al
	shr al, 1
	mov ch, al
	and dh, 1
	pop bx
	mov dl, [BS_DrvNum]
Label_Go_On_Reading:
	mov ah, 2
	mov al, byte [bp-2]
	int 13h
	jc Label_Go_On_Reading
	add esp, 2
	pop bp
	ret