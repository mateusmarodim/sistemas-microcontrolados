; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 24/08/2020
; Este programa espera o usuário apertar a chave USR_SW1.
; Caso o usuário pressione a chave, o LED1 piscará a cada 0,5 segundo.

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
		
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; ========================

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
		IMPORT  PLL_Init
		IMPORT  SysTick_Init	
		IMPORT  GPIO_Init
		IMPORT PortB_Output			; Permite chamar PortN_Output de outro arquivo
		IMPORT PortP_Output			; Permite chamar PortN_Output de outro 
		IMPORT Seg7_Output			; Permite chamar PortN_Output de outro arquivo	
		IMPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo
		IMPORT Teclas_Input
		IMPORT LCD_Init
		IMPORT LCD_Caracter
		IMPORT LCD_Instrucao


; -------------------------------------------------------------------------------

frase_inicio_1				DCB   'C', 'o', 'f', 'r', 'e', ' ', 'a', 'b', 'e', 'r', 't', 'o', ',', 0
frase_inicio_2				DCB   'd', 'i', 'g', 'i', 't', 'e', ' ', 'n', 'o', 'v', 'a', ' ', 's', 'e', 'n', 'h', 'a', ' ', 'p', 'a', 'r', 'a', ' ', 'f', 'e', 'c', 'h', 'a', 'r', ' ', 'o', ' ', 'c', 'o', 'f', 'r', 'e', 0
fechado				DCB   'C', 'o', 'f', 'r', 'e', ' ', 'f', 'e', 'c', 'h', 'a', 'd', 'o', 0
fechando				DCB   'C', 'o', 'f', 'r', 'e', ' ', 'f', 'e', 'c', 'h', 'a', 'n', 'd', 'o', 0
abrindo				DCB   'C', 'o', 'f', 'r', 'e', ' ', 'a', 'b', 'r', 'i', 'n', 'd', 'o', 0
travado				DCB   'C', 'o', 'f', 'r', 'e', ' ', 't', 'r', 'a', 'v', 'a', 'd', 'o', 0
;
; R12 senha de segurança
; R11 senha do usuario
; R10 senha tentaiva
; R9 tentativas
; R8 1 para fechado 0 para aberto
; R7 numero digitos

; Função main()
Start  		
	BL PLL_Init                  ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init
	BL GPIO_Init                 ;Chama a subrotina que inicializa os GPIO
	BL LCD_Init
	
	MOV R12, #1234
	MOV R7, #0
	MOV R8, #0
	MOV R9, #0

MainLoop
	LDR R4, =frase_inicio_1
	BL Imprime_Frase
	
	MOV R0, #0xC0
	BL LCD_Instrucao
	
espera_entrada
	BL Teclas_Input				 ;Chama a subrotina que lê o estado das teclas e coloca o resultado em R0
	
	CMP R0, #-1
	BEQ espera_entrada
	
	CMP R7, #0
	ITT EQ
		MOVEQ R1, #1000
		MULEQ R11, R0, R1
	CMP R7, #1
	ITT EQ
		MOVEQ R1, #100
		MLAEQ R11, R0, R1, R11
	CMP R7, #2
	ITT EQ
		MOVEQ R1, #10
		MLAEQ R11, R0, R1, R11
	CMP R7, #3
	ITT EQ
		MOVEQ R1, #1
		MLAEQ R11, R0, R1, R11
	CMP R7, #4
	BEQ quatro_digitos
	ADD R0, #48
	BL LCD_Caracter
	B soma
quatro_digitos
	BL Manter_4_digitos
soma
	ADD R7, #1
	
	
	
	B espera_entrada
					
Imprime_Frase
	PUSH {LR}
proximo_caracter
	LDRB R0, [R4], #1
	CMP R0, #0
	BEQ fim
	BL LCD_Caracter
	B proximo_caracter
fim
	POP {LR}
	BX LR
	
Manter_4_digitos
	PUSH {LR}
	
	MOV R1, #1000
	MOV R3, #10
	UDIV R2,R11, R1
	MLS R11, R2, R1, R11
	MLA R11, R3,R11, R0
	SUB R7,#1
	
	MOV R0, #0xC0
	BL LCD_Instrucao
	
	MOV R1, #1000
	UDIV R2,R11, R1
	ADD R0, R2, #48
	PUSH {R1, R2, R3}
	BL LCD_Caracter
	POP {R1, R2, R3}
	
	MOV R3, R11
	
	MLS R3, R2, R1, R3
	MOV R1, #100
	UDIV R2,R3, R1
	ADD R0, R2, #48
	PUSH {R1, R2, R3}
	BL LCD_Caracter
	POP {R1, R2, R3}
	
	MLS R3, R2, R1, R3
	MOV R1, #10
	UDIV R2,R3, R1
	ADD R0, R2, #48
	PUSH {R1, R2, R3}
	BL LCD_Caracter
	POP {R1, R2, R3}
	
	MLS R3, R2, R1, R3
	MOV R1, #1
	UDIV R2,R3, R1
	ADD R0, R2, #48
	BL LCD_Caracter


	
	POP {LR}
	BX LR
; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
