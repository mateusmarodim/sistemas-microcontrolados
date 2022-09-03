; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>
; -------------------------------------------------------------------------------
; �rea de Dados - Declara��es de vari�veis
		AREA  DATA, ALIGN=2
		; Se alguma vari�vel for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a vari�vel <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma vari�vel de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posi��o da RAM		

; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a fun��o Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>

; -------------------------------------------------------------------------------
; Fun��o main()
Start  
; Comece o c�digo aqui <======================================================

lista EQU 0x20000200 
primos EQU 0x20000300

main
	LDR R0, =lista
	MOV R2, #0           ;Arnazena o tamanho da lista
	MOV R1, #50
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #65
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #229
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #201
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #101
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #43
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #27
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #2
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #5
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #210
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #101
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #239
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #73
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #29
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #207
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #135
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #33
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #227
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #13
	STRB R1, [R0], #2
	ADD R2, #1
	MOV R1, #9
	STRB R1, [R0]
	ADD R2, #1
	
	LDR R2, =primos
	LDR R3, =lista
	MOV R1, #0
	
	B percorreLista
	NOP
	
percorreLista
	LDRB R4, [R3], #2
	BL verificaPrimo
	CMP R3, R0
	BNE percorreLista
	B bubbleSort
	NOP
	
verificaPrimo
	MOV R5, #2
loop
	UDIV R6, R4, R5
	MLS R7, R5, R6, R4
	CMP R7, #0
	IT EQ
		BXEQ LR
	ADD R5, #1
	CMP R5, R4
	BNE loop
	B inserePrimo
	NOP
		
inserePrimo
	STRB R4, [R2], #2
	ADD R1, #1
	BX LR
	NOP
	
bubbleSort
	MOV R6, #1                   ;Quantas vezes varreu a lista
loopPai
	MOV R5, #1					;Quantas vezes comparou 2 elementos
	LDR R2, =primos
loopFilho
	LDRB R3, [R2], #2
	LDRB R4, [R2]
	CMP R3, R4
	ITT HI
		STRBHI R4, [R2, #-2]
		STRBHI R3, [R2]
	ADD R5, #1
	CMP R5, R1
	BNE loopFilho
	ADD R6, #1
	CMP R6, R1
	BNE loopPai
fim
	B fim
	
	
    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
