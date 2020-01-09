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
