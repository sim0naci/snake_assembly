;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CR              EQU     0Ah
FIM_TEXTO       EQU     '@'
IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
INITIAL_SP      EQU     FDFFh
CURSOR		EQU     FFFCh
CURSOR_INIT	EQU	FFFFh
ROW_POSITION	EQU	0d
COL_POSITION	EQU	0d
ROW_SHIFT	EQU	8d
COLUMN_SHIFT	EQU	8d


;TIMER_UNIT

;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------
ORIG 8000h

teste_str   STR  'HELLO WORLD!', FIM_TEXTO
varivel    WORD 5

print_text      WORD    0h      ;recebe endereço da string pára ser empressa em pritnf
text_index      WORD    0d
column_index    WORD    0d

;------------------------------------------------------------------------------
; ZONA II: definicao de tabela de interrupções
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
ORIG    0000h
JMP     Main


;------------------------------------------------------------------------------
; Printf
;------------------------------------------------------------------------------
Printf:         PUSH R1     ;recebe valor linha  
                PUSH R2     ;recebe endereço string
                PUSH R3
                PUSH R4

                MOV     M[print_text], R2       ;passando o endereço bruto da string para print_text


        
printfloop:     MOV     R2, M[print_text]       ;passando para R2 o endereço do primeiro caracter da string
                ADD     R2, M[text_index]       ;somando o index no endereço
                MOV     R2, M[R2]

                CMP     R2, FIM_TEXTO
                JMP.Z   printfEndLoop   

                MOV     R4, R1
                MOV     R3, M[column_index]
                SHL     R4, ROW_SHIFT
                OR      R4, R3
                MOV     M[CURSOR], R4

                MOV     M[IO_WRITE], R2

                INC     M[text_index]
                INC     M[column_index]
                JMP     printfloop

printfEndLoop:  MOV     M[text_index], R0
                MOV     M[column_index], R0

                POP R4
                POP R3
                POP R2
                POP R1
                RET


Main:	        ENI
		MOV	R1, INITIAL_SP
		MOV	SP, R1		 	; We need to initialize the stack
		MOV	R1, CURSOR_INIT		; We need to initialize the cursor 
		MOV	M[ CURSOR ], R1		; with value CURSOR_INIT

                MOV     R1, 0d
                MOV     R2, teste_str 
                CALL Printf




Cycle: 			BR		Cycle	
Halt:           BR		Halt



;------------------------------------------------------------------------------
; Esqueleto função
;------------------------------------------------------------------------------
funcao: PUSH R1 
        PUSH R2
        PUSH R3



        POP R3
        POP R2
        POP R1
        RET

;------------------------------------------------------------------------------
; Esqueleto  INTERRUPÇÃO
;------------------------------------------------------------------------------
interrupcao:    PUSH R1 
                PUSH R2
                PUSH R3



                POP R3
                POP R2
                POP R1
                RTI