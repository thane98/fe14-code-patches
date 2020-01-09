.arm.little

.open "codebase.bin","code.bin",0x100000

; Unused functions
debug_AddItem equ 0x421404

; Hooks
Butler_Table_Pointer equ 0x48CAA4
Butler_LoopCount equ 0x48C760

; Overwrite the pointer to the butler table.
; We'll make a new one at debug_AddItem
.org Butler_Table_Pointer
    .word debug_AddItem

; Adjust the loop that parses the butler table so it sees our new entries.
.org Butler_LoopCount
    cmp r4, #8

.org debug_AddItem
Butler_Table:
    .word 0x6A38D5
    .word 0x6A3EE4
    .word 0x6A3EF3
    .word 0x6A3F02
    .word Butler_Scarlet
    .word Butler_Saizo
    .word Butler_Kagero
    .word Butler_Anna

Butler_Data:
Butler_Scarlet:
    .sjis "PID_クリムゾン"
Butler_Saizo:
    .sjis "PID_サイゾウ"
Butler_Kagero:
    .sjis "PID_カゲロウ"
Butler_Anna:
    .sjis "PID_アンナ"

.Close


; Library functions
malloc equ 0x2fdd08
free equ 0x30129c
wcsncpy equ 0x125e24
wcsncat equ 0x11b170
TryOpenFile equ 0x11ff0c
MountExtSaveData equ 0x22e280
Unmount equ 0x10cad0

; Existing functions used for overwriting
DebugMoveToNext equ 0x421114

; Data
IsMount equ 0x6bd7c8


; Install the redirect
.org TryOpenFile+4
    b tryopen_payload

.org DebugMoveToNext
.area 376
tryopen_payload:
    mov r6, r0
    cmp r4, #0xBA
    beq exit
    push {r0-r12, lr}
        sub sp, sp, #0x20
        mov r7, r1
        mov r8, r2

        ; Filter saves and extdata
        ldrh r3, [r7, #0x0]
        cmp r3, #0x64
        beq abort
        cmp r3, #0x65
        beq abort

        ; Make sure extdata is mounted
        b mount_extdata
tryopen_continue:
        
        ; Allocate space for path string
        mov r0, #0x400
        bl malloc
        str r0, [sp, #0]

        ; Build path string
        ; First, add the SD directory
        ldr r1, =extmount_wchar
        mov r2, #14
        bl wcsncpy

        ; Now add the path in the SD directory
        ldr r0, [sp, #0]
        mov r1, r7
        ldrh r3, [r7, #0x6]
        cmp r3, #0x3A
        addeq r1, #0xA
        addne r1, #0xC
        ldr r2, =0x200-14
        bl wcsncat

        ; Run the TryOpenFile call with the new path
        mov r0, r6
        ldr r1, [sp, #0]
        mov r2, r8
        mov r4, #0xBA
        bl TryOpenFile
        mov r4, r0

        ; Free path string
        ldr r0, [sp, #0]
        bl free

        ; If we got back 0, the redirect worked
        ; If it didn't, abort
        cmp r4, #0x0
        beq success
abort:
        bl unmount_extdata
        add sp, sp, #0x20
    pop {r0-r12, lr}

exit:
    b TryOpenFile+8

success:
    bl unmount_extdata
    add sp, sp, #0x20
    pop {r0-r12, lr}
    b TryOpenFile+0x8C

mount_extdata:
    ldr r0, =extmount
    mov r1, #0
    ldr r2, =0x1794
    mov r3, #0
    bl MountExtSaveData
    b tryopen_continue
    
unmount_extdata:
    ; Is extdata supposed to be mounted right now?
    push {lr}
    ldr r0, =IsMount
    ldr r0, [r0]
    cmp r0, #1
    beq unmount_done
    
    ; If not, unmount it
    ldr r0, =extmount
    bl Unmount
unmount_done:
    pop {pc}
    
.pool

.align 4
extmount:
.ascii "ext:"
.byte 0

.align 4
extmount_wchar:
.byte 0x65, 0x00, 0x78, 0x00, 0x74, 0x00, 0x3a, 0x00 
.byte 0x2f, 0x00, 0x73, 0x00, 0x61, 0x00, 0x6c, 0x00 
.byte 0x74, 0x00, 0x79, 0x00, 0x66, 0x00, 0x65, 0x00
.byte 0x2f, 0x00, 0x00
    
.endarea
    
.Close
