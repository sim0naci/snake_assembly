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

parede      STR  '#', FIM_TEXTO
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
; Mapa(Celling and Floor)
;------------------------------------------------------------------------------
Printlinha:         PUSH R1     ;recebe valor linha  
                PUSH R2     ;recebe endereço string
                PUSH R3
                PUSH R4
                PUSH R5

                MOV     M[print_text], R2       ;passando o endereço bruto da string para print_text


        
printflooplinha:     MOV     R2, M[print_text]       ;passando para R2 o endereço do primeiro caracter da string
                ADD     R2, M[text_index]       ;somando o index no endereço
                MOV     R2, M[R2]


                CMP     M[column_index], R5
                JMP.Z   printfEndLooplinha   

                MOV     R4, R1
                MOV     R3, M[column_index]
                SHL     R4, ROW_SHIFT
                OR      R4, R3
                MOV     M[CURSOR], R4

                MOV     M[IO_WRITE], R2

                INC     M[column_index]
                JMP     printflooplinha

printfEndLooplinha:  MOV     M[text_index], R0
                MOV     M[column_index], R0

                POP R5
                POP R4
                POP R3
                POP R2
                POP R1
                RET



;------------------------------------------------------------------------------
; Mapa(Walls)
;------------------------------------------------------------------------------
Printwall:      PUSH R1                         ;recebe valor linha  
                PUSH R2                         ;recebe endereço string
                PUSH R3
                PUSH R4
                PUSH R5

                MOV     M[print_text], R2       ;passando o endereço bruto da string para print_text


        
printfloopwall:     MOV     R2, M[print_text]   ;passando para R2 o endereço do primeiro caracter da string
                ADD     R2, M[text_index]       ;somando o index no endereço
                MOV     R2, M[R2]


                CMP     R1, R5
                JMP.Z   printfEndLoopwall       ;quando o numero de colunas/linhas atual(R1) for igual a R5, sai do looping

                MOV     R4, R1                  ;salvando a linha em R4
                MOV     R3, M[column_index]     ;salvando em R3 o atual numero de coluna
                SHL     R4, ROW_SHIFT           ;shiftlef no R4
                OR      R4, R3                  ;somando linha com coluna em R4
                MOV     M[CURSOR], R4           ;passando a linha+coluna para o cursor

                MOV     M[IO_WRITE], R2         ;passando para o IO_WRITE a estrutura da parede = "#"


                INC     R1                      ;incrementando a coluna
                JMP     printfloopwall

printfEndLoopwall:  MOV     M[text_index], R0   ;zera a variavel text_index
                MOV     M[column_index], R0     ;zera a variavel column_index

                POP R5
                POP R4
                POP R3
                POP R2
                POP R1
                RET


;------------------------------------------------------------------------------
; Snake Spawn
;------------------------------------------------------------------------------
spawn_snake:    PUSH R1 
                PUSH R2
                PUSH R3
                PUSH R4
                PUSH R5

                MOV     M[print_text], R2       ;passando o endereço bruto da string para print_text


mov_cima:    MOV     R2, M[print_text]       ;passando para R2 o endereço do primeiro caracter da string
                ADD     R2, M[text_index]       ;somando o index no endereço
                MOV     R2, M[R2]


                CMP     R1, R5
                JMP.Z   Endmov_cima  

                MOV     R4, R1
                MOV     R3, M[column_index]
                SHL     R4, ROW_SHIFT
                OR      R4, R3
                MOV     M[CURSOR], R4

                MOV     M[IO_WRITE], R2

                INC     R1
                JMP     mov_cima

Endmov_cima:  MOV     M[text_index], R0
        MOV     M[column_index], R0             ;zera a variavel column_index

        POP R5
        POP R4
        POP R3
        POP R2
        POP R1
        RET




EndLoopcima:

        POP R3
        POP R2
        POP R1
        RET



Main:	        ENI
		MOV	R1, INITIAL_SP
		MOV	SP, R1		 	; We need to initialize the stack
		MOV	R1, CURSOR_INIT		; We need to initialize the cursor 
		MOV	M[ CURSOR ], R1		; with value CURSOR_INIT


                ;--- parede de cima ---
                MOV     R1, 0d                  ;primeira linha da tela
                MOV     R2, parede
                MOV     R5, 80d                 ;ultima coluna da tela
                CALL Printlinha

                ;--- parede de baixo ---
                MOV R1, 23d                     ;ultima linha da tela
                CALL Printlinha

                ;--- parede esquerda ---
                MOV R1, 1d                      ;segunda linha da tela(ja existe o teto)
                MOV R5, 23d                     ;ultima linha da tela
                CALL Printwall

                ;--- parede direita ---
                MOV R1, 1d                      ;segunda linha da tela
                MOV R6, 79d                     ;ultima coluna da tela
                MOV M[column_index], R6         ;passando a coluna para column_index para que a funcao ja comece nessa coluna
                MOV R5, 23d                     ;ultima linha da tela
                CALL Printwall

                ;-- spawn da snake ---
                MOV R1, 12d                     ;linha que a snake vai spawnar
                MOV R6, 40d                     ;coluna que a snake vai spawnar
                MOV M[column_index], R6
                MOV R5, 15d                     ;tamanho maximo da snake no spawn
                CALL spawn_snake

                ;nessa cópia, vou testar ja usar a função spawn_snake
                ;para implementar o movimento da snake
                
                






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