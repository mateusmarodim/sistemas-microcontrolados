; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM		

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>

; -------------------------------------------------------------------------------
; Função main()
Start  
; Comece o código aqui <======================================================

lista EQU 0x20000200 
primos EQU 0x20000300

main
	LDR R0, =lista
	MOV R1, #50
	STRB R1, [R0], #2
	MOV R1, #65
	STRB R1, [R0], #2
	MOV R1, #229
	STRB R1, [R0], #2
	MOV R1, #201
	STRB R1, [R0], #2
	MOV R1, #101
	STRB R1, [R0], #2
	MOV R1, #43
	STRB R1, [R0], #2
	MOV R1, #27
	STRB R1, [R0], #2
	MOV R1, #2
	STRB R1, [R0], #2
	MOV R1, #5
	STRB R1, [R0], #2
	MOV R1, #210
	STRB R1, [R0], #2
	MOV R1, #101
	STRB R1, [R0], #2
	MOV R1, #239
	STRB R1, [R0], #2
	MOV R1, #73
	STRB R1, [R0], #2
	MOV R1, #29
	STRB R1, [R0], #2
	MOV R1, #207
	STRB R1, [R0], #2
	MOV R1, #135
	STRB R1, [R0], #2
	MOV R1, #33
	STRB R1, [R0], #2
	MOV R1, #227
	STRB R1, [R0], #2
	MOV R1, #13
	STRB R1, [R0], #2
	MOV R1, #9
	STRB R1, [R0]
	
	LDR R2, =primos 	; Endereco para inserir o proximo primo
	LDR R3, =lista  	; Endereco do proximo numero a ser lido da RAM
	MOV R1, #0		; Quantidade de primos encontrados
	
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
	MOV R6, #1              ; Quantas vezes varreu a lista
loopPai
	MOV R5, #1		; Quantas vezes comparou 2 elementos
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
	
	
    ALIGN                           ; Garante que o fim da seção está alinhada 
    END                             ; Fim do arquivo
