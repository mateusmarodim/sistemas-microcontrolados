; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 24/08/2020

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
; ========================
; Definições de Valores
BIT0	EQU 2_0001
BIT1	EQU 2_0010
; ========================
; Definições dos Registradores Gerais
SYSCTL_RCGCGPIO_R	 EQU	0x400FE608
SYSCTL_PRGPIO_R		 EQU    0x400FEA08
; ========================
; Definições dos Ports

; PORT A
GPIO_PORTA_AHB_DATA_BITS_R    EQU 0x40058000
GPIO_PORTA_AHB_DATA_R   EQU 0x400583FC
GPIO_PORTA_AHB_DIR_R    EQU 0x40058400
GPIO_PORTA_AHB_AFSEL_R  EQU 0x40058420
GPIO_PORTA_AHB_PUR_R    EQU 0x40058510
GPIO_PORTA_AHB_DEN_R    EQU 0x4005851C
GPIO_PORTA_AHB_LOCK_R   EQU 0x40058520
GPIO_PORTA_AHB_CR_R     EQU 0x40058524
GPIO_PORTA_AHB_AMSEL_R  EQU 0x40058528
GPIO_PORTA_AHB_PCTL_R   EQU 0x4005852C
GPIO_PORTA				EQU 2_000000000000001
; PORT B
GPIO_PORTB_AHB_DATA_BITS_R  EQU 0x40059000
GPIO_PORTB_AHB_DATA_R   EQU 0x400593FC
GPIO_PORTB_AHB_DIR_R    EQU 0x40059400
GPIO_PORTB_AHB_AFSEL_R  EQU 0x40059420
GPIO_PORTB_AHB_PUR_R    EQU 0x40059510
GPIO_PORTB_AHB_DEN_R    EQU 0x4005951C
GPIO_PORTB_AHB_LOCK_R   EQU 0x40059520
GPIO_PORTB_AHB_CR_R     EQU 0x40059524
GPIO_PORTB_AHB_AMSEL_R  EQU 0x40059528
GPIO_PORTB_AHB_PCTL_R   EQU 0x4005952C
GPIO_PORTB				EQU 2_000000000000010
;PORT D
GPIO_PORTD_AHB_DATA_BITS_R  EQU 0x4005B000
GPIO_PORTD_AHB_DATA_R   EQU 0x4005B3FC
GPIO_PORTD_AHB_DIR_R    EQU 0x4005B400
GPIO_PORTD_AHB_AFSEL_R  EQU 0x4005B420
GPIO_PORTD_AHB_PUR_R    EQU 0x4005B510
GPIO_PORTD_AHB_DEN_R    EQU 0x4005B51C
GPIO_PORTD_AHB_LOCK_R   EQU 0x4005B520
GPIO_PORTD_AHB_CR_R     EQU 0x4005B524
GPIO_PORTD_AHB_AMSEL_R  EQU 0x4005B528
GPIO_PORTD_AHB_PCTL_R   EQU 0x4005B52C
GPIO_PORTD				EQU 2_000000000001000
; PORT J
GPIO_PORTJ_AHB_LOCK_R    	EQU    0x40060520
GPIO_PORTJ_AHB_CR_R      	EQU    0x40060524
GPIO_PORTJ_AHB_AMSEL_R   	EQU    0x40060528
GPIO_PORTJ_AHB_PCTL_R    	EQU    0x4006052C
GPIO_PORTJ_AHB_DIR_R     	EQU    0x40060400
GPIO_PORTJ_AHB_AFSEL_R   	EQU    0x40060420
GPIO_PORTJ_AHB_DEN_R     	EQU    0x4006051C
GPIO_PORTJ_AHB_PUR_R     	EQU    0x40060510	
GPIO_PORTJ_AHB_DATA_R    	EQU    0x400603FC
GPIO_PORTJ_AHB_DATA_BITS_R  EQU    0x40060000
GPIO_PORTJ               	EQU    2_000000100000000
; PORT P
GPIO_PORTP_DATA_BITS_R  EQU 0x40065000
GPIO_PORTP_DATA_R       EQU 0x400653FC
GPIO_PORTP_DIR_R        EQU 0x40065400
GPIO_PORTP_AFSEL_R      EQU 0x40065420
GPIO_PORTP_PUR_R        EQU 0x40065510
GPIO_PORTP_DEN_R        EQU 0x4006551C
GPIO_PORTP_LOCK_R       EQU 0x40065520
GPIO_PORTP_CR_R         EQU 0x40065524
GPIO_PORTP_AMSEL_R      EQU 0x40065528
GPIO_PORTP_PCTL_R       EQU 0x4006552C
GPIO_PORTP             	EQU 2_010000000000000
; PORT Q
GPIO_PORTQ_DATA_BITS_R  EQU 0x40066000
GPIO_PORTQ_DATA_R       EQU 0x400663FC
GPIO_PORTQ_DIR_R        EQU 0x40066400
GPIO_PORTQ_AFSEL_R      EQU 0x40066420
GPIO_PORTQ_PUR_R        EQU 0x40066510
GPIO_PORTQ_DEN_R        EQU 0x4006651C
GPIO_PORTQ_LOCK_R       EQU 0x40066520
GPIO_PORTQ_CR_R         EQU 0x40066524
GPIO_PORTQ_AMSEL_R      EQU 0x40066528
GPIO_PORTQ_PCTL_R       EQU 0x4006652C
GPIO_PORTQ              EQU 2_100000000000000


; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		EXPORT PortB_Output			; Permite chamar PortN_Output de outro arquivo
		EXPORT PortP_Output			; Permite chamar PortN_Output de outro 
		EXPORT Seg7_Output			; Permite chamar PortN_Output de outro arquivo	
		EXPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo
		;EXPORT PortQ_Input          ; Permite chamar PortQ_Input de outro arquivo

;--------------------------------------------------------------------------------
; Função GPIO_Init
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
GPIO_Init
;=====================
; 1. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO,
; após isso verificar no PRGPIO se a porta está pronta para uso.
; enable clock to GPIOF at clock gating register
            LDR     R0, =SYSCTL_RCGCGPIO_R  		;Carrega o endereço do registrador RCGCGPIO
			MOV		R1, #GPIO_PORTA                 ;Seta o bit da porta A
			ORR     R1, #GPIO_PORTB					;Seta o bit da porta B, fazendo com OR
			ORR     R1, #GPIO_PORTD					;Seta o bit da porta D, fazendo com OR
			ORR     R1, #GPIO_PORTJ					;Seta o bit da porta J, fazendo com OR
			ORR     R1, #GPIO_PORTP					;Seta o bit da porta Q, fazendo com OR
			ORR     R1, #GPIO_PORTQ					;Seta o bit da porta Q, fazendo com OR
            STR     R1, [R0]						;Move para a memória os bits das portas no endereço do RCGCGPIO
 
            LDR     R0, =SYSCTL_PRGPIO_R			;Carrega o endereço do PRGPIO para esperar os GPIO ficarem prontos
EsperaGPIO  LDR     R1, [R0]						;Lê da memória o conteúdo do endereço do registrador
			MOV     R2, #GPIO_PORTA                 ;Seta os bits correspondentes às portas para fazer a comparação
			ORR     R2, #GPIO_PORTB                 ;Seta o bit da porta B, fazendo com OR
			ORR     R2, #GPIO_PORTD                 ;Seta o bit da porta D, fazendo com OR
			ORR     R2, #GPIO_PORTJ                 ;Seta o bit da porta J, fazendo com OR
			ORR     R1, #GPIO_PORTP					;Seta o bit da porta Q, fazendo com OR
			ORR     R2, #GPIO_PORTQ                 ;Seta o bit da porta Q, fazendo com OR
            TST     R1, R2							;Testa o R1 com R2 fazendo R1 & R2
            BEQ     EsperaGPIO					    ;Se o flag Z=1, volta para o laço. Senão continua executando
 
; 2. Limpar o AMSEL para desabilitar a analógica
            MOV     R1, #0x00						;Colocar 0 no registrador para desabilitar a função analógica
            LDR     R0, =GPIO_PORTJ_AHB_AMSEL_R     ;Carrega o R0 com o endereço do AMSEL para a porta J
            STR     R1, [R0]						;Guarda no registrador AMSEL da porta J da memória
            LDR     R0, =GPIO_PORTA_AHB_AMSEL_R			;Carrega o R0 com o endereço do AMSEL para a porta A
            STR     R1, [R0]					    ;Guarda no registrador AMSEL da porta A da memória
			LDR     R0, =GPIO_PORTB_AHB_AMSEL_R			;Carrega o R0 com o endereço do AMSEL para a porta B
            STR     R1, [R0]
			LDR     R0, =GPIO_PORTD_AHB_AMSEL_R			;Carrega o R0 com o endereço do AMSEL para a porta D
            STR     R1, [R0]
			LDR     R0, =GPIO_PORTP_AMSEL_R			;Carrega o R0 com o endereço do AMSEL para a porta Q
            STR     R1, [R0]
			LDR     R0, =GPIO_PORTQ_AMSEL_R			;Carrega o R0 com o endereço do AMSEL para a porta Q
            STR     R1, [R0]					    ;Guarda no registrador AMSEL da porta Q da memória
 
; 3. Limpar PCTL para selecionar o GPIO
            MOV     R1, #0x00					    ;Colocar 0 no registrador para selecionar o modo GPIO
            LDR     R0, =GPIO_PORTJ_AHB_PCTL_R		;Carrega o R0 com o endereço do PCTL para a porta J
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta J da memória
            LDR     R0, =GPIO_PORTA_AHB_PCTL_R      	;Carrega o R0 com o endereço do PCTL para a porta N
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta N da memória
			LDR     R0, =GPIO_PORTB_AHB_PCTL_R      	;Carrega o R0 com o endereço do PCTL para a porta N
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta N da memória
			LDR     R0, =GPIO_PORTD_AHB_PCTL_R      	;Carrega o R0 com o endereço do PCTL para a porta N
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta N da memória
			LDR     R0, =GPIO_PORTP_AMSEL_R			;Carrega o R0 com o endereço do AMSEL para a porta Q
            STR     R1, [R0]
			LDR     R0, =GPIO_PORTQ_PCTL_R      	;Carrega o R0 com o endereço do PCTL para a porta Q
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta Q da memória
; 4. DIR para 0 se for entrada, 1 se for saída
            LDR     R0, =GPIO_PORTA_AHB_DIR_R			;Carrega o R0 com o endereço do DIR para a porta N
			MOV     R1, #2_11110000						;PN1
            STR     R1, [R0]						;Guarda no registrador
			LDR     R0, =GPIO_PORTB_AHB_DIR_R			;Carrega o R0 com o endereço do DIR para a porta N
			MOV     R1, #2_110000						;PN1
            STR     R1, [R0]						;Guarda no registrador
			LDR     R0, =GPIO_PORTD_AHB_DIR_R			;Carrega o R0 com o endereço do DIR para a porta N
			MOV     R1, #2_0010						;PN1
            STR     R1, [R0]
			LDR     R0, =GPIO_PORTP_DIR_R			;Carrega o R0 com o endereço do DIR para a porta Q
			MOV     R1, #2_100000						;PQ0 a PQ3
            STR     R1, [R0]			;Guarda no registrador
			LDR     R0, =GPIO_PORTQ_DIR_R			;Carrega o R0 com o endereço do DIR para a porta Q
			MOV     R1, #2_01111						;PQ0 a PQ3
            STR     R1, [R0]						;Guarda no registrador
			; O certo era verificar os outros bits da PJ para não transformar entradas em saídas desnecessárias
            LDR     R0, =GPIO_PORTJ_AHB_DIR_R		;Carrega o R0 com o endereço do DIR para a porta J
            MOV     R1, #0x00               		;Colocar 0 no registrador DIR para funcionar com saída
            STR     R1, [R0]						;Guarda no registrador PCTL da porta J da memória
; 5. Limpar os bits AFSEL para 0 para selecionar GPIO 
;    Sem função alternativa
            MOV     R1, #0x00						;Colocar o valor 0 para não setar função alternativa
            LDR     R0, =GPIO_PORTA_AHB_AFSEL_R			;Carrega o endereço do AFSEL da porta N
            STR     R1, [R0]						;Escreve na porta
			LDR     R0, =GPIO_PORTB_AHB_AFSEL_R			;Carrega o endereço do AFSEL da porta N
            STR     R1, [R0]
			LDR     R0, =GPIO_PORTD_AHB_AFSEL_R			;Carrega o endereço do AFSEL da porta N
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTJ_AHB_AFSEL_R     ;Carrega o endereço do AFSEL da porta J
            STR     R1, [R0]                        ;Escreve na porta
			LDR     R0, =GPIO_PORTP_AFSEL_R     ;Carrega o endereço do AFSEL da porta Q
            STR     R1, [R0] 
			LDR     R0, =GPIO_PORTQ_AFSEL_R     ;Carrega o endereço do AFSEL da porta Q
            STR     R1, [R0]                        ;Escreve na porta
; 6. Setar os bits de DEN para habilitar I/O digital
            LDR     R0, =GPIO_PORTA_AHB_DEN_R			    ;Carrega o endereço do DEN
            MOV     R1, #2_11110000                     ;N1
            STR     R1, [R0]							;Escreve no registrador da memória funcionalidade digital 
			
			LDR     R0, =GPIO_PORTB_AHB_DEN_R			    ;Carrega o endereço do DEN
            MOV     R1, #2_0110000                     ;N1
            STR     R1, [R0]							;Escreve no registrador da memória funcionalidade digital 
			
			LDR     R0, =GPIO_PORTD_AHB_DEN_R			    ;Carrega o endereço do DEN
            MOV     R1, #2_00000010                     ;N1
            STR     R1, [R0]							;Escreve no registrador da memória funcionalidade digital 
 
            LDR     R0, =GPIO_PORTJ_AHB_DEN_R			;Carrega o endereço do DEN
			MOV     R1, #2_00000011                     ;J0     
            STR     R1, [R0] 			;Escreve no registrador da memória funcionalidade digital
			
			LDR     R0, =GPIO_PORTP_DEN_R			;Carrega o endereço do DEN
			MOV     R1, #2_000100000                     ;Q0 - Q3     
            STR     R1, [R0]
			
			LDR     R0, =GPIO_PORTQ_DEN_R			;Carrega o endereço do DEN
			MOV     R1, #2_00001111                     ;Q0 - Q3     
            STR     R1, [R0]                            ;Escreve no registrador da memória funcionalidade digital
; 7. Para habilitar resistor de pull-up interno, setar PUR para 1
			LDR     R0, =GPIO_PORTJ_AHB_PUR_R			;Carrega o endereço do PUR para a porta J
			MOV     R1, #2_11							;Habilitar funcionalidade digital de resistor de pull-up 
            STR     R1, [R0]							;Escreve no registrador da memória do resistor de pull-up
			BX      LR

; -------------------------------------------------------------------------------
; Função PortN_Output
; Parâmetro de entrada: R0 --> se o BIT1 está ligado ou desligado
; Parâmetro de saída: Não tem
Seg7_Output
	LDR	R1, =GPIO_PORTQ_DATA_R		    ;Carrega o valor do offset do data register
	
	AND R0, R4, #2_00001111
	
	LDR R2, [R1]
	BIC R2, #2_1111                     ;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 11111101
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o parâmetro de entrada
	STR R0, [R1]                            ;Escreve na porta N o barramento de dados do pino N1
	
	LDR	R1, =GPIO_PORTA_AHB_DATA_R		    ;Carrega o valor do offset do data register
	
	AND R0, R4, #2_11110000
	
	LDR R2, [R1]
	BIC R2, #2_11110000                     ;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 11111101
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o parâmetro de entrada
	STR R0, [R1]                            ;Escreve na porta N o barramento de dados do pino N1
	
	BX LR									;Retorno
	
; -------------------------------------------------------------------------------
; Função PortN_Output
; Parâmetro de entrada: R0 --> se o BIT1 está ligado ou desligado
; Parâmetro de saída: Não tem
PortB_Output	
	LDR R1, =GPIO_PORTB_AHB_DATA_R
	LDR R2, [R1]
	BIC R2, #2_110000
	ORR R0, R2, R5
	STR R0, [R1]                            ;Escreve na porta N o barramento de dados do pino N1
	
	BX LR									;Retorno
	
; -------------------------------------------------------------------------------
; Função PortN_Output
; Parâmetro de entrada: R0 --> se o BIT1 está ligado ou desligado
; Parâmetro de saída: Não tem
PortP_Output
	LDR R1, =GPIO_PORTP_DATA_R
	LDR R2, [R1]
	BIC R2, #2_100000
	ORR R0, R2, R5
	STR R0, [R1]                            ;Escreve na porta N o barramento de dados do pino N1
	
	BX LR									;Retorno

; -------------------------------------------------------------------------------
; Função PortJ_Input
; Parâmetro de entrada: Não tem
; Parâmetro de saída: R0 --> o valor da leitura
PortJ_Input
	LDR	R1, =GPIO_PORTJ_AHB_DATA_R		    ;Carrega o valor do offset do data register
	LDR R0, [R1]                            ;Lê no barramento de dados dos pinos [J0]
	BX LR									;Retorno



    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo