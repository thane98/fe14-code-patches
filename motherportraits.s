.arm.little

.open "codebase.bin","code.bin",0x100000

; Unused functions
debugTick equ 0x42128c

; Hooks
GetFaceData_Hook equ 0x1DFF00
GetFaceData_Resume equ 0x1DFF04
GetFaceData_Epilogue equ 0x1DFF4C
GetFaceData equ 0x1DFE88

.org GetFaceData_Hook
    b append_if_mother

.org debugTick
append_if_mother:
    ; First, perform the copy like the original code.
    ; r0 = destination buffer
    ; r1 = FID
    ; r4 = portrait type
	push	{r4-r8, lr}
    mov r8, r4
	mov	r4, r1
	adr	r6, strncpy
	mov	r2, #64
	ldr	r3, [r6]
	mov	r5, r0
	blx	r3

    ; Get the target person struct from the FID.
    ; r4 = FID
    ; r5 = destination buffer
    ; r6 = start of function pointers
	ldr r3, [r6, #12]
    mov r0, r4
    blx r3

    ; If no person struct exists, abort.
    cmp r0, #0
    beq	append_if_mother_abort

    ; Use the person struct to get the unit from the unit pool.
    ldr r3, [r6, #16]
    blx r3

    ; If no unit struct exists, abort.
    cmp r0, #0
    beq append_if_mother_abort

    ; Does the unit have a marriage pointer?
    ldr r0, [r0, #0xb4]
    cmp r0, #0
    beq append_if_mother_abort

    ; Does the mother pointer exist?
    ldr r0, [r0, #0x14]
    cmp r0, #0
    beq append_if_mother_abort

    ; Found the mother struct. Does it have a FID?
    ldr r4, [r0, #12]
    cmp r4, #0
    beq append_if_mother_abort

    ; Found an FID. Chop off everything before the underscore.
    add r4, r4, #3

    ; Determine the max number of characters we can add to the FID.
	ldr	r3, [r6, #4]
	mov	r0, r5
	blx	r3
    mov r7, r0
	rsb	r2, r0, #63

    ; Concatenate the prefix.
	mov r1, r4
	mov	r0, r5
    ldr	r3, [r6, #8]
	blx	r3

    ; Attempt to get FaceData using this new FID.
    mov r1, r8
    bl GetFaceData
    cmp r0, #0
    beq append_if_mother_failure

    ; Success - the face data is in r0.
    ; Proceed to the end of the original GetFaceData call.
    pop	{r4-r8, lr}
    b GetFaceData_Epilogue

append_if_mother_failure:
    str r0, [r5, r7]

append_if_mother_abort:
    pop	{r4-r8, lr}
    b GetFaceData_Resume

.align 4
strncpy:
	.word	1159388
strlen:
	.word	3828704
strncat:
	.word	3829096
Person_GetFromFID:
    .word   0x449fb8
UnitPool_GetFromPerson:
    .word   0x4f5d24

.Close
