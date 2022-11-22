	THUMB
	AREA    |.text|, CODE, READONLY, ALIGN=2
		
	EXPORT Teclas_Input
	
	IMPORT  SysTick_Wait1us
	IMPORT  SysTick_Wait1ms

;Retorna a multiplicação de A que está na
;memória pelo parâmetro recebido em R0 e
;retorna em R0 para a AAPCS
Teclas_Input
	PUSH {LR}

	MOV R4, R1
	MOV	R1, R0		    ;Carrega o valor do offset do data register
	MOV R5, R2
	LDR R2, [R4]
	
	MOV R2, #2_01000111						;transforma em saida
	STR R2, [R4]
	
	LDR R2, [R5]					;COLOCA 0 NA COLUNA
	BIC R2, #2_01000000
	STR R2, [R5]
	
	MOV R0, #1
	BL SysTick_Wait1ms
	
	LDR R2, [R1]
	
	CMP R2,#2_1110
	ITTT EQ
		MOVEQ R0, #3
		POPEQ {LR}
		BXEQ LR
	CMP R2,#2_1101
	ITTT EQ
		MOVEQ R0, #6
		POPEQ {LR}
		BXEQ LR
	CMP R2,#2_1011
	ITTT EQ
		MOVEQ R0, #9
		POPEQ {LR}
		BXEQ LR
	CMP R2,#2_0111
	ITTT EQ
		MOVEQ R0, #11
		POPEQ {LR}
		BXEQ LR
	
	MOV R2, #2_00010111					;PRIMEIRA COLUNA SAIDA
	STR R2, [R4]
	
	LDR R2, [R5]					;COLOCA 0 NA COLUNA
	BIC R2, R2, #2_00010000
	STR R2, [R5]
	
	MOV R0, #1
	BL SysTick_Wait1ms
	
	LDR R2, [R1]                            ;Lê no barramento de dados dos pinos [J0]
	
	CMP R2,#2_1110
	ITTT EQ
		MOVEQ R0, #1
		POPEQ {LR}
		BXEQ LR
	CMP R2,#2_1101
	ITTT EQ
		MOVEQ R0, #4
		POPEQ {LR}
		BXEQ LR
	CMP R2,#2_1011
	ITTT EQ
		MOVEQ R0, #7
		POPEQ {LR}
		BXEQ LR
	CMP R2,#2_0111
	ITTT EQ
		MOVEQ R0, #10
		POPEQ {LR}
		BXEQ LR
		
	MOV R2, #2_00100111						;transforma em saida
	STR R2, [R4]
	
	LDR R2, [R5]					;COLOCA 0 NA COLUNA
	BIC R2, #2_00100000
	STR R2, [R5]
	
	MOV R0, #1
	BL SysTick_Wait1ms
	
	LDR R2, [R1]
	
	CMP R2,#2_1110
	ITTT EQ
		MOVEQ R0, #2
		POPEQ {LR}
		BXEQ LR
	CMP R2,#2_1101
	ITTT EQ
		MOVEQ R0, #5
		POPEQ {LR}
		BXEQ LR
	CMP R2,#2_1011
	ITTT EQ
		MOVEQ R0, #8
		POPEQ {LR}
		BXEQ LR
	CMP R2,#2_0111
	ITTT EQ
		MOVEQ R0, #0
		POPEQ {LR}
		BXEQ LR
		
	
		
	MOV R0, #-1
	
	POP{LR}
	
	BX LR

ALIGN
END