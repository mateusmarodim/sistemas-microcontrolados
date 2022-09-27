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
		IMPORT  SysTick_Wait1ms			
		IMPORT  GPIO_Init
		IMPORT PortB_Output			; Permite chamar PortN_Output de outro arquivo
		IMPORT PortP_Output			; Permite chamar PortN_Output de outro 
		IMPORT Seg7_Output			; Permite chamar PortN_Output de outro arquivo	
		IMPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo


; -------------------------------------------------------------------------------
;
; R12 passo  (1 a 9)
; R11 unidade (0 a 9)
; R10 dezena  (0 a 9)
; R9  sinal (1 ou -1)
; R8  posicao dos leds (1 a 8)
; R6 sinal dos LEDs ( 1 ou -1)

; Função main()
Start  		
	BL PLL_Init                  ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init
	BL GPIO_Init                 ;Chama a subrotina que inicializa os GPIO
	
	MOV R12, #1
	MOV R11, #0
	MOV R10, #0
	MOV R9, #1
	MOV R8, #1
	MOV R6, #1
	MOV R3, #0

MainLoop
	PUSH {R3}
	BL PortJ_Input				 ;Chama a subrotina que lê o estado das chaves e coloca o resultado em R0
Verifica_Nenhuma
	CMP	R0, #2
	IT EQ
		BLEQ SW1_Pressionado			 ;Se o teste viu que tem pelo menos alguma chave pressionada pula
	CMP	R0, #1
	IT EQ
		BLEQ SW2_Pressionado
	CMP	R0, #0
	IT EQ
		BLEQ SW1_Pressionado
	CMP	R0, #0
	IT EQ
		BLEQ SW2_Pressionado
		
	MOV R5, R11
	BL ImprimeDisplay
	MOV R5, #2_100000
	BL AcionaTransistorPB
	
	MOV R5, R10
	BL ImprimeDisplay
	MOV R5, #2_10000
	BL AcionaTransistorPB
	
	MOV R5, R8
	BL AcenderLEDs
	MOV R5, #2_100000
	BL AcionaTransistorPP
		
	POP {R3}
	ADD R3, #1
	CMP R3, #50
	IT EQ
		BLEQ Passo
	
	B MainLoop					 
	


;--------------------------------------------------------------------------------
; Função Pisca_LED
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
SW1_Pressionado
	PUSH {LR}
	
SW1Loop
	BL PortJ_Input
	CMP R0, #3
	BNE SW1Loop
	
	ADD R12, #1
	CMP R12, #9
	IT GT
		MOVGT R12, #1
		
		POP {LR}
	
	BX LR						 ;return
	
	
SW2_Pressionado
		PUSH {LR}
	
SW2Loop
	BL PortJ_Input
	CMP R0, #3
	BNE SW2Loop


	MOV R1, #-1
	MUL R9, R1
	
	POP {LR}
	
	BX LR						 ;return
	
AcionaTransistorPB
	PUSH {LR}
	MOV R0, #1
	BL SysTick_Wait1ms
	
	BL PortB_Output
	
	MOV R0, #1
	BL SysTick_Wait1ms
	
	MOV R5, #0
	BL PortB_Output
	
	POP {LR}
	BX LR						 ;return
	

AcionaTransistorPP
	PUSH {LR}
	MOV R0, #1
	BL SysTick_Wait1ms
	
	BL PortP_Output
	
	MOV R0, #1
	BL SysTick_Wait1ms
	
	MOV R5, #0
	BL PortP_Output
	
	POP {LR}
	BX LR						 ;return
	
	
AcenderLEDs
	MOV R7, #1
	PUSH {LR}
	CMP R5, R7
	ITT EQ
		MOVEQ R4, #2_10000001
		BLEQ Seg7_Output
	ADD R7, #1
	CMP R5, R7
	ITT EQ
		MOVEQ R4, #2_01000010
		BLEQ Seg7_Output
	ADD R7, #1
	CMP R5, R7
	ITT EQ
		MOVEQ R4, #2_00100100
		BLEQ Seg7_Output
	ADD R7, #1
	CMP R5, R7
	ITT EQ
		MOVEQ R4, #2_00011000
		BLEQ Seg7_Output

	POP {LR}
	BX LR						 ;return

SomaDezena
	SUB R11, #10
	ADD R10, #1
	CMP R10, #9
	IT GT
		MOVGT R10, #0
	
	BX LR						 ;return
	
	
DiminuiDezena
	ADD R11, #10
	SUB R10, #1
	CMP R10, #0
	IT LT
		MOVLT R10, #9
	
	BX LR						 ;return
	
Passo
	PUSH {LR}
	MLA R11, R12, R9, R11
	CMP R11, #9
	IT GT
		BLGT SomaDezena
	CMP R11, #0
	IT LT
		BLLT DiminuiDezena
	
	ADD R8, R6 
	CMP R8, #5
	ITTT EQ
		MOVEQ R8, #4
		MOVEQ R5, #-1
		MULEQ R6, R5
	
	CMP R8, #0
	ITTT EQ
		MOVEQ R8, #1
		MOVEQ R5, #-1
		MULEQ R6, R5
		
	MOV R3, #0
	
	POP {LR}
	BX LR

ImprimeDisplay
	MOV R7, #0
	PUSH {LR}
	CMP R5, R7
	ITT EQ
		MOVEQ R4, #2_0111111
		BLEQ Seg7_Output
	ADD R7, #1
	CMP R5, R7
	ITT EQ
		MOVEQ R4, #2_110
		BLEQ Seg7_Output
	ADD R7, #1
	CMP R5, R7
	ITT EQ
		MOVEQ R4, #2_1011011
		BLEQ Seg7_Output
	ADD R7, #1
	CMP R5, R7
	ITT EQ
		MOVEQ R4, #2_1001111
		BLEQ Seg7_Output
	ADD R7, #1
	CMP R5, R7
	ITT EQ
		MOVEQ R4, #2_1100110
		BLEQ Seg7_Output
	ADD R7, #1
	CMP R5, R7
	ITT EQ
		MOVEQ R4, #2_1101101
		BLEQ Seg7_Output
	ADD R7, #1
	CMP R5, R7
	ITT EQ
		MOVEQ R4, #2_1111101
		BLEQ Seg7_Output
	ADD R7, #1
	CMP R5, R7
	ITT EQ
		MOVEQ R4, #2_0000111
		BLEQ Seg7_Output
	ADD R7, #1
	CMP R5, R7
	ITT EQ
		MOVEQ R4, #2_1111111
		BLEQ Seg7_Output
	ADD R7, #1
	CMP R5, R7
	ITT EQ
		MOVEQ R4, #2_1101111
		BLEQ Seg7_Output
	
	POP {LR}
	
	BX LR						 ;return
; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
