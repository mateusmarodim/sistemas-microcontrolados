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
									
		EXPORT GPIOPortJ_Handler
									
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
		IMPORT Teclas_Input
		IMPORT LCD_Init
		IMPORT LCD_Caracter
		IMPORT LCD_Instrucao


; -------------------------------------------------------------------------------

NVIC_EN1_R				EQU 	0xE000E104
NVIC_PRI12_R			EQU 	0xE000E430

GPIO_PORTJ_AHB_IS_R		EQU 	0x40060404
GPIO_PORTJ_AHB_IBE_R	EQU 	0x40060408
GPIO_PORTJ_AHB_IEV_R	EQU		0x4006040C
GPIO_PORTJ_AHB_IM_R 	EQU		0x40060410
GPIO_PORTJ_AHB_RIS_R	EQU		0x40060414
GPIO_PORTJ_AHB_ICR_R	EQU 	0x4006041C

; -------------------------------------------------------------------------------
frase_inicio_1		DCB   'C', 'o', 'f', 'r', 'e', ' ', 'a', 'b', 'e', 'r', 't', 'o', 0
frase_inicio_2		DCB   'd', 'i', 'g', 'i', 't', 'e', ' ', 'n', 'o', 'v', 'a', ' ', 's', 'e', 'n', 'h', 'a', ' ', 'p', 'a', 'r', 'a', ' ', 'f', 'e', 'c', 'h', 'a', 'r', ' ', 'o', ' ', 'c', 'o', 'f', 'r', 'e', 0
fechado_msg				DCB   'C', 'o', 'f', 'r', 'e', ' ', 'f', 'e', 'c', 'h', 'a', 'd', 'o', 0
fechando			DCB   'C', 'o', 'f', 'r', 'e', ' ', 'f', 'e', 'c', 'h', 'a', 'n', 'd', 'o', 0
abrindo				DCB   'C', 'o', 'f', 'r', 'e', ' ', 'a', 'b', 'r', 'i', 'n', 'd', 'o', 0
travado				DCB   'C', 'o', 'f', 'r', 'e', ' ', 't', 'r', 'a', 'v', 'a', 'd', 'o', 0
senha_mestra_1		DCB   'D', 'i', 'g', 'i', 't', 'e', ' ', 'a', ' ', 's', 'e', 'n', 'h', 'a', 0
senha_mestra_2		DCB   'm', 'e', 's', 't', 'r', 'a', ':', ' ', 0
;
; R12 senha de segurança
; R11 senha do usuario
; R10 senha tentaiva
; R9 tentativas
; R8 1 para TRAVADO 0 para SENHA MESTRA
; R7 numero digitos

; Função main()
Start  		
	BL PLL_Init                  ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init
	BL GPIO_Init                 ;Chama a subrotina que inicializa os GPIO
	BL LCD_Init
	BL Int_Init
	
	MOV R12, #1234

MainLoop
	MOV R7, #0
	MOV R8, #0
	MOV R9, #0
	MOV R0, #0x01
	BL LCD_Instrucao
	LDR R4, =frase_inicio_1
	BL Imprime_Frase
	
	MOV R0, #0xC0
	BL LCD_Instrucao
	
espera_entrada
	BL Teclas_Input				 ;Chama a subrotina que lê o estado das teclas e coloca o resultado em R0
	
	CMP R0, #-1
	BEQ espera_entrada
espera_soltar
	MOV R6, R0
	BL Teclas_Input
	CMP R0, #-1
	BNE espera_soltar
	
	CMP R6, #10
	BEQ fechar_cofre
	
	CMP R7, #0
	ITT EQ
		MOVEQ R1, #1000
		MULEQ R11, R6, R1
	CMP R7, #1
	ITT EQ
		MOVEQ R1, #100
		MLAEQ R11, R6, R1, R11
	CMP R7, #2
	ITT EQ
		MOVEQ R1, #10
		MLAEQ R11, R6, R1, R11
	CMP R7, #3
	ITT EQ
		MOVEQ R1, #1
		MLAEQ R11, R6, R1, R11
	CMP R7, #4
	BEQ quatro_digitos
	ADD R6, #48
	MOV R0, R6
	BL LCD_Caracter
	B soma
quatro_digitos
	BL Manter_4_digitos
soma
	ADD R7, #1
	
	MOV R0, #500			; evitar o bounce
	BL SysTick_Wait1ms
	
	B espera_entrada
fechar_cofre
	MOV R0, #0x01
	BL LCD_Instrucao
	LDR R4, =fechando
	BL Imprime_Frase
	MOV R0, #5000
	BL SysTick_Wait1ms
	
fechado
	MOV R0, #0x01
	BL LCD_Instrucao
	LDR R4, =fechado_msg
	BL Imprime_Frase
	MOV R7, #0
	
	MOV R0, #0xC0
	BL LCD_Instrucao
	
espera_entrada_f
	BL Teclas_Input				 ;Chama a subrotina que lê o estado das teclas e coloca o resultado em R0
	
	CMP R0, #-1
	BEQ espera_entrada_f
espera_soltar_f
	MOV R6, R0
	BL Teclas_Input
	CMP R0, #-1
	BNE espera_soltar_f

	CMP R7, #0
	ITT EQ
		MOVEQ R1, #1000
		MULEQ R10, R6, R1
	CMP R7, #1
	ITT EQ
		MOVEQ R1, #100
		MLAEQ R10, R6, R1, R10
	CMP R7, #2
	ITT EQ
		MOVEQ R1, #10
		MLAEQ R10, R6, R1, R10
	CMP R7, #3
	ITTT EQ
		MOVEQ R1, #1
		MLAEQ R10, R6, R1, R10
		BLEQ Testa_Senha
		
	ADD R6, #48
	MOV R0, R6
	BL LCD_Caracter
	ADD R7, #1
	
	MOV R0, #500			; evitar o bounce
	BL SysTick_Wait1ms
	
	B espera_entrada_f
					
					
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
	
Testa_Senha	
	CMP R10, R11
	BEQ abre
	
	ADD R9, #1
	MOV R10, #0
	CMP R9, #3
	BNE fechado
	
	BL Trava_Cofre
abre
	MOV R0, #0x01
	BL LCD_Instrucao
	LDR R4, =abrindo
	BL Imprime_Frase
	MOV R0, #5000
	BL SysTick_Wait1ms
	
	B MainLoop
	
Trava_Cofre
	MOV R8, #1
	MOV R0, #0x01
	BL LCD_Instrucao
	LDR R4, =travado
	BL Imprime_Frase
	
	LDR R0, =GPIO_PORTJ_AHB_ICR_R
	MOV R1, #0x01
	STR R1, [R0]
	
	LDR R0, =GPIO_PORTJ_AHB_IM_R
	MOV R1, #0x01
	STR R1, [R0]
	
	MOV R11, #0
	MOV R9, #1
loop
	
	ADD R11, #1
	MOV R2, #-1
	CMP R11, #100
	ITT EQ
		MULEQ R9, R2
		MOVEQ R11, #0
	BL Pisca_LED
	
	CMP R8, #0
	BEQ Destrava
	B loop
	
Destrava
	LDR R0, =GPIO_PORTJ_AHB_IM_R
	MOV R1, #0x00
	STR R1, [R0]
	
inicio
	MOV R0, #0x01
	MOV R7, #0
	BL LCD_Instrucao
	LDR R4, =senha_mestra_1
	BL Imprime_Frase
	
	MOV R0, #0xC0
	BL LCD_Instrucao
	
	LDR R4, =senha_mestra_2
	BL Imprime_Frase
	
espera_entrada_i
	ADD R11, #1
	MOV R2, #-1
	CMP R11, #50
	ITT EQ
		MULEQ R9, R2
		MOVEQ R11, #0
	BL Pisca_LED
	
	BL Teclas_Input				 ;Chama a subrotina que lê o estado das teclas e coloca o resultado em R0
	
	CMP R0, #-1
	BEQ espera_entrada_i
	MOV R6, R0
espera_soltar_i
	ADD R11, #1
	MOV R2, #-1
	CMP R11, #50
	ITT EQ
		MULEQ R9, R2
		MOVEQ R11, #0
		
	BL Pisca_LED

	BL Teclas_Input
	CMP R0, #-1
	BNE espera_soltar_i

	CMP R7, #0
	ITT EQ
		MOVEQ R1, #1000
		MULEQ R10, R6, R1
	CMP R7, #1
	ITT EQ
		MOVEQ R1, #100
		MLAEQ R10, R6, R1, R10
	CMP R7, #2
	ITT EQ
		MOVEQ R1, #10
		MLAEQ R10, R6, R1, R10
	CMP R7, #3
	ITTT EQ
		MOVEQ R1, #1
		MLAEQ R10, R6, R1, R10
		BEQ testa
		
	ADD R6, #48
	MOV R0, R6
	BL LCD_Caracter
	ADD R7, #1
	
	MOV R0, #500			; evitar o bounce
	BL SysTick_Wait1ms
	
	B espera_entrada_i
testa
	CMP R10, R12
	BNE inicio
	
	B abre
	
Pisca_LED
	PUSH {LR}
	
	CMP R9, #-1
	ITE EQ
		MOVEQ R4, #2_11111111
		MOVNE R4, #2_00000000
	
	BL Seg7_Output
	
	MOV R0, #1
	BL SysTick_Wait1ms
	
	MOV R5, #2_100000
	BL PortP_Output
	
	MOV R0, #1
	BL SysTick_Wait1ms
	
	MOV R5, #0
	BL PortP_Output

	POP {LR}
	BX LR
		
	
Manter_4_digitos
	PUSH {LR}
	
	MOV R1, #1000
	MOV R3, #10
	UDIV R2,R11, R1
	MLS R11, R2, R1, R11
	MLA R11, R3,R11, R6
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
Int_Init
	LDR R0, =GPIO_PORTJ_AHB_IM_R
	MOV R1, #0x00
	STR R1, [R0]
	
	LDR R0, =GPIO_PORTJ_AHB_IS_R
	MOV R1, #0x00
	STR R1, [R0]
	
	LDR R0, =GPIO_PORTJ_AHB_IBE_R
	MOV R1, #0x00
	STR R1, [R0]
	
	LDR R0, =GPIO_PORTJ_AHB_IEV_R
	MOV R1, #0x00
	STR R1, [R0]
	
	LDR R0, =GPIO_PORTJ_AHB_ICR_R
	MOV R1, #0x01
	STR R1, [R0]
	
	LDR R0, =NVIC_EN1_R
	MOV R1, #0x80000
	STR R1, [R0]
	
	LDR R0, =NVIC_PRI12_R
	MOV R1, #5
	LSL R1, #29
	STR R1, [R0]

	BX LR

GPIOPortJ_Handler
	LDR R0, =GPIO_PORTJ_AHB_ICR_R
	MOV R1, #0x01
	STR R1, [R0]
	
	MOV R8, #0
	
	BX LR
	

; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
