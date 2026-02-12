            TTL Program Title for Listing Header Goes Here
;****************************************************************
;Descriptive comment header goes here.
;(Unsigned division lab with data loading/testing)
;Name:  Arnav Gawas
;Date:  <Date completed here>
;Class:  CMPE-250
;Section:  <Your lab section, day, and time here>
;---------------------------------------------------------------
;Keil Simulator Template for KL05
;R. W. Melton
;August 21, 2025
;****************************************************************
            THUMB
            OPT    64
;****************************************************************
;EQUates
BYTE_MASK         EQU  0xFF
NIBBLE_MASK       EQU  0x0F
BYTE_BITS         EQU  8
NIBBLE_BITS       EQU  4
WORD_SIZE         EQU  4
HALFWORD_SIZE     EQU  2
HALFWORD_MASK     EQU  0xFFFF
RET_ADDR_T_MASK   EQU  1
VECTOR_TABLE_SIZE EQU 0x000000C0
VECTOR_SIZE       EQU 4
SSTACK_SIZE       EQU  0x00000100
;****************************************************************
            AREA    MyCode,CODE,READONLY
            ENTRY
            EXPORT  Reset_Handler
            IMPORT InitData
            IMPORT LoadData
            IMPORT TestData

Reset_Handler  PROC {}
main
            BL      RegInit

;================ MAIN PROGRAM ==================

            BL      InitData

MainLoop
            BL      LoadData
            BCS     ProgramEnd        ; no more data

            ; Load P and Q
            LDR     R2, =P
            LDR     R1, [R2]           ; R1 = P (dividend)

            LDR     R2, =Q
            LDR     R0, [R2]           ; R0 = Q (divisor)

            ; Call DIVU  → R1 ÷ R0
            BL      DIVU

            ; Check result validity
            BCC     StoreValid        ; C=0 valid

            ; ----- Invalid case -----
            LDR     R2, =P
            LDR     R3, =0xFFFFFFFF
            STR     R3, [R2]

            LDR     R2, =Q
            STR     R3, [R2]
            B       AfterStore

StoreValid
            ; Store quotient and remainder
            LDR     R2, =P
            STR     R0, [R2]           ; P = quotient

            LDR     R2, =Q
            STR     R1, [R2]           ; Q = remainder

AfterStore
            BL      TestData
            B       MainLoop

ProgramEnd
            B       .

            ENDP

;================================================
RegInit     PROC  {}
; Initializes registers safely for Cortex-M0+ Thumb-1
            PUSH    {LR}

            LDR     R1,=0x11111111
            ADDS    R2,R1,R1
            ADDS    R3,R2,R1
            ADDS    R4,R3,R1
            ADDS    R5,R4,R1
            ADDS    R6,R5,R1
            ADDS    R7,R6,R1

            ; ---- high register init (Thumb-1 safe) ----
            MOV     R0, R1
            ADD     R0, R0, R7
            MOV     R8, R0

            MOV     R0, R1
            ADD     R0, R0, R8
            MOV     R9, R0

            MOV     R0, R1
            ADD     R0, R0, R9
            MOV     R10, R0

            MOV     R0, R1
            ADD     R0, R0, R10
            MOV     R11, R0

            MOV     R0, R1
            ADD     R0, R0, R11
            MOV     R12, R0

            MOV     R0, R2
            ADD     R0, R0, R12
            MOV     R14, R0

            MOV     R0, R1
            ADD     R0, R0, R14

            MSR     APSR,R0
            LDR     R0,=0x05250821

            POP     {PC}
            ENDP

;================================================
; Unsigned Division Subroutine
; Input:
;   R1 = dividend
;   R0 = divisor
; Output:
;   R0 = quotient
;   R1 = remainder
;   C  = 0 valid, 1 invalid (divide by zero)
;================================================
DIVU        PROC {}
            PUSH    {R2,R3,LR}

            CMP     R0, #0
            BNE     DivStart

            ; ---- divide by zero ----
            MOVS    R2, #1
            SUBS    R2, R2, #1     ; sets C=1
            POP     {R2,R3,PC}

DivStart
            ; ---- valid case ----
            MOVS    R2, #0
            ADDS    R2, R2, #1     ; sets C=0

            MOVS    R2, #0         ; quotient
            MOV     R3, R1         ; remainder temp

DivLoop
            CMP     R3, R0
            BLO     DivDone
            SUBS    R3, R3, R0
            ADDS    R2, R2, #1
            B       DivLoop

DivDone
            MOV     R0, R2
            MOV     R1, R3

            POP     {R2,R3,PC}
            ENDP

            ALIGN
;****************************************************************
;Vector Table
            AREA    RESET, DATA, READONLY
            EXPORT  __Vectors
            EXPORT  __Vectors_End
            EXPORT  __Vectors_Size
__Vectors 
            DCD    __initial_sp
            DCD    Reset_Handler
            SPACE  (VECTOR_TABLE_SIZE - (2 * VECTOR_SIZE))
__Vectors_End
__Vectors_Size  EQU     __Vectors_End - __Vectors
            ALIGN
;****************************************************************
;Constants
            AREA    MyConst,DATA,READONLY
MAX_DATA    EQU 25

;****************************************************************
            AREA    |.ARM.__at_0x1FFFFC00|,DATA,READWRITE,ALIGN=3
            EXPORT  __initial_sp
Stack_Mem   SPACE   SSTACK_SIZE
__initial_sp

;****************************************************************
;Variables
            AREA    MyData,DATA,READWRITE
            EXPORT P
            EXPORT Q
            EXPORT Results

P           DCD 0
Q           DCD 0

Results     SPACE   (2*MAX_DATA*4)

            END
