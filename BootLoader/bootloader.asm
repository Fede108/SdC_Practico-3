bits 16
org 0x7c00


;setup stack 
entry: 
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 7c00h
    
    ; switch to protected mode
    cli                         ; disable interrupts
    call EnableA20              ; enable A20 gate
    lgdt [GDT_Descriptor]       ; load GDT 

    ;set protection enable flag in CR0
    mov eax, cr0
    or al, 1
    mov cr0, eax

    ;far jump into protected mode
    jmp CODE_SEG:pmode


pmode:
            ; we are now in protected mode!
            [bits 32]

            ; setup segment registers
            mov ax, DATA_SEG
            mov ds, ax
            mov ss, ax

            ; setup stack
            mov ebp, 0x90000    
            mov esp, ebp

            ; call kernel
            mov al, 'A'
            mov ah, 0x0f
            mov [0xb8000], ax

EnableA20:
            [bits 16]
            ; disable keyboard
            call A20WaitInput
            mov al, KbdControllerDisableKeyboard
            out KbdControllerCommandPort, al

            ; read control output port
            call A20WaitInput
            mov al, KbdControllerReadCtrlOutputPort
            out KbdControllerCommandPort, al

            call A20WaitOutput
            in al, KbdControllerDataPort
            push eax

            ; write control output port
            call A20WaitInput
            mov al, KbdControllerWriteCtrlOutputPort
            out KbdControllerCommandPort, al

            call A20WaitInput
            pop eax
            or al, 2                                    ; bit 2 = A20 bit
            out KbdControllerDataPort, al

            ; enable keyboard
            call A20WaitInput
            mov al, KbdControllerEnableKeyboard
            out KbdControllerCommandPort, al

            call A20WaitInput
            ret


A20WaitInput:
            ; wait until status bit 2 (input buffer) is 0
            ; by reading from command port, we read status byte
            in al, KbdControllerCommandPort
            test al, 2
            jnz A20WaitInput
            ret
    
A20WaitOutput:
            ; wait until status bit 1 (output buffer) is 1 so it can be read
            in al, KbdControllerCommandPort
            test al, 1
            jz A20WaitOutput
            ret


g_GDT:      ; NULL descriptor
            dq 0

gdt_code:
            ; 32-bit code segment
            dw 0FFFFh                   ; limit (bits 0-15) = 0xFFFFF for full 32-bit range
            dw 0                        ; base (bits 0-15) = 0x0
            db 0                        ; base (bits 16-23)
            db 10011010b                ; access (present, ring 0, code segment, executable, direction 0, readable)
            db 11001111b                ; granularity (4k pages, 32-bit pmode) + limit (bits 16-19)
            db 0                        ; base high

gdt_data:
            ; 32-bit data segment
            dw 0FFFFh                   ; limit (bits 0-15) = 0xFFFFF for full 32-bit range
            dw 0                        ; base (bits 0-15) = 0x0
            db 0                        ; base (bits 16-23)
            db 10010010b                ; access (present, ring 0, data segment, executable, direction 0, writable)
            db 11001111b                ; granularity (4k pages, 32-bit pmode) + limit (bits 16-19)
            db 0                        ; base high

; GDT descriptor
GDT_Descriptor:
            dw GDT_Descriptor - g_GDT - 1    ; limit = size of GDT
            dd g_GDT                    ; address of GDT

CODE_SEG equ gdt_code - g_GDT
DATA_SEG equ gdt_data - g_GDT

KbdControllerDataPort               equ 0x60
KbdControllerCommandPort            equ 0x64
KbdControllerDisableKeyboard        equ 0xAD
KbdControllerEnableKeyboard         equ 0xAE
KbdControllerReadCtrlOutputPort     equ 0xD0
KbdControllerWriteCtrlOutputPort    equ 0xD1


times 510- ($ - $$) db 0
dw 0xAA55