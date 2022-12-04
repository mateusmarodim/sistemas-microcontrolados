// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Gabriel Godinho e Mateus Marodim

#include <stdint.h>
#include <stdlib.h>
#include "tm4c1294ncpdt.h"

#define CLOCK 800

void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);
void PortF_Output(uint32_t parametro);
void PortE_Output(uint32_t parametro);
void funcSentido(void);
void funcControle(void);
void funcRotacionaTer(void);
void funcRotacionaPot(void);
void UART_Init(void);
void ADC_Init(void);
void Timer_Int_Init(void);
void uartChar(uint32_t caractere);
void uartClear(void);
void uartFrase(const char *frase);
void uartNumero(uint32_t numero);
void uartGetChar(void);
void imprimeStatus(void);
void ativaDesativaMotor(uint8_t flag);
uint32_t verificaPot(void);

typedef enum estados{
	Sentido,
	Controle,
	RotacionaPot,
	RotacionaTer
}EstadosMotor;
EstadosMotor estadoAtual = Sentido;

uint32_t tecla = 0;
uint32_t sentido = 0;
uint32_t controle = 0;
uint8_t busy = 0;
uint8_t busyPot = 0;
uint32_t data = '*';
uint32_t velocidade = 0;
uint8_t flagPWM = 0;
uint32_t potenciometro = 0;

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	UART_Init();
	ADC_Init();
	Timer_Int_Init();
	while (1){
		switch (estadoAtual){
			break;
			case Sentido:
				funcSentido();
			break;
			case Controle:
				funcControle();
			break;
			case RotacionaPot:
				funcRotacionaPot();
			break;
			case RotacionaTer:
				funcRotacionaTer();
			break;
		}
	}
}

void funcSentido(void){
	uartClear();
	uartFrase("MOTOR PARADO\n");
	uartFrase("Selecione o sentido de rotacao:\n");
	uartFrase("1 - Horario\n");
	uartFrase("2 - Anti-Horario\n");
	while(data == '*'){
		uartGetChar();
		if(busy == 1)
			busy = 0;
		switch(data){
			case '1':
				sentido = 1;
				estadoAtual = Controle;
			break;
			case '2':
				sentido = 2;
				estadoAtual = Controle;
			break;
			case '*':
				continue;
			break;
			default:
				uartClear();
				uartFrase("MOTOR PARADO\n");
				uartFrase("Selecione o sentido de rotacao:\n");
				uartFrase("1 - Horario\n");
				uartFrase("2 - Anti-Horario\n");
				data = '*';
			break;
		}
	}
	data = '*';
}

void funcControle(void){
	uartClear();
	uartFrase("MOTOR PARADO\n");
	uartFrase("Selecione a forma de controle:\n");
	uartFrase("1 - Terminal\n");
	uartFrase("2 - Potenciometro\n");
	while(data == '*'){
		uartGetChar();
		if(busy == 1)
			busy = 0;
		switch(data){
			case '1':
				controle = 1;
				estadoAtual = RotacionaTer;
			break;
			case '2':
				controle = 2;
				estadoAtual = RotacionaPot;
			break;
			case '*':
				continue;
			break;
			default:
				uartClear();
				uartFrase("MOTOR PARADO\n");
				uartFrase("Selecione o sentido de rotacao:\n");
				uartFrase("1 - Horario\n");
				uartFrase("2 - Anti-Horario\n");
				data = '*';
			break;
		}
	}
	data = '*';
	ativaDesativaMotor(1);
}

void funcRotacionaTer(void){
	imprimeStatus();
	
	while(1){
		uartGetChar();
		if(busy == 1)
			busy = 0;
		switch(data){
			case '0':
				velocidade = 0;
				imprimeStatus();
			break;
			case '1':
				velocidade = 50;
				imprimeStatus();
			break;
			case '2':
				velocidade = 60;
				imprimeStatus();
			break;
			case '3':
				velocidade = 70;
				imprimeStatus();
			break;
			case '4':
				velocidade = 80;
				imprimeStatus();
			break;
			case '5':
				velocidade = 90;
				imprimeStatus();
			break;
			case '6':
				velocidade = 100;
				imprimeStatus();
			break;
			case 'h':
				sentido = 1;
				imprimeStatus();
			break;
			case 'a':
				sentido = 2;
				imprimeStatus();
			break;
			default:
				continue;
			break;
		}
	}

}

void funcRotacionaPot(void){
	imprimeStatus();
	
	velocidade = (potenciometro * 100)/4096;
	
	while(1){
		uartGetChar();
		
		if(verificaPot()){
			velocidade = (potenciometro * 100)/4096;
			imprimeStatus();			
		}
		
		if(busy == 1)
			busy = 0;
		switch(data){
			case 'h':
				sentido = 1;
				imprimeStatus();
			break;
			case 'a':
				sentido = 2;
				imprimeStatus();
			break;
			default:
				continue;
			break;
		}
	}
}

uint32_t verificaPot(void){
	if (!busyPot) {
		ADC0_PSSI_R = 8;
		busyPot = 1;
	}
	if (ADC0_RIS_R != 8) {
		return 0;
	}
	busyPot = 0;
	uint32_t valor = ADC0_SSFIFO3_R;
	ADC0_ISC_R = 8;
	if (valor - potenciometro < 20) {
		return 0;
	}
	potenciometro = valor;
	return 1;
}

void imprimeStatus(void){
	uartClear();
	if(sentido == 1)
		uartFrase("Sentido Horario  Velocidade:");
	else
		uartFrase("Sentido Anti-Horario  Velocidade:");
	
	uartNumero(velocidade);
	uartFrase("% ");
	data = '*';
}

void ativaDesativaMotor(uint8_t flag){
	flagPWM = 0;
	PortE_Output(0x00);
	
	if(flag){
		PortF_Output(0x04);

		TIMER1_TAILR_R = 100 * CLOCK;
		TIMER1_ICR_R |= 0x01;
		TIMER1_CTL_R |= 0x01;
	}
	else{
		PortF_Output(0x00);

		TIMER1_CTL_R &= ~(0x01);
	}
}

void Timer_Int_Init(void) {
	SYSCTL_RCGCTIMER_R |= 0x02;
	while ((SYSCTL_PRTIMER_R & 0x02) == 0) {
		
	}

	TIMER1_CTL_R &= ~(0x01u);
	TIMER1_CFG_R &= ~(0x07u);
	TIMER1_TAMR_R = (TIMER1_TAMR_R & ~(0x03u)) | 0x02;
	TIMER1_TAILR_R = 100 * CLOCK;
	TIMER1_TAPR_R = 0;
	TIMER1_ICR_R |= 0x01;
	TIMER1_IMR_R |= 0x01;
	NVIC_PRI5_R = 4u << 13;
	NVIC_EN0_R = 1u << 21;

}

void Timer1A_Handler(void) {
	uint32_t contagem = 0;
	if (velocidade == 0) {
		flagPWM = 0;
		contagem = 100 * CLOCK;
	} else if (velocidade == 100) {
		flagPWM = 1;
		contagem = 100 * CLOCK;
	} else {
		if (flagPWM == 0) {
			flagPWM = 1;
			contagem = velocidade * CLOCK;
		} else {
			flagPWM = 0;
			contagem = (100 - velocidade) * CLOCK;
		}
	}

	if (sentido == 1) {
		PortE_Output(flagPWM);
	} else {
		PortE_Output(flagPWM << 1);
	}
	TIMER1_TAILR_R = contagem;
	TIMER1_ICR_R |= 0x01;
}

void UART_Init(void) {
	uint32_t UART0 = SYSCTL_RCGCUART_R0;
	SYSCTL_RCGCUART_R = UART0;
	while ( (SYSCTL_RCGCUART_R & UART0) != UART0 ) {
		
	}
	
	UART0_CTL_R = 0;
	UART0_IBRD_R = 260;
	UART0_FBRD_R = 27;
	UART0_LCRH_R = 0x72;
	UART0_CC_R = 0;
	UART0_CTL_R = 0x301;

}

void uartChar(uint32_t caractere) {

	while ((UART0_FR_R & 0x20) == 0x20) {
		continue;
	}
	
	UART0_DR_R = caractere;
}

void uartClear(void) {

	uartChar(0x1B);//limpa terminal
	uartChar('[');
	uartChar('2');
	uartChar('J');
	
	uartChar(0x1B);//reseta cursor
	uartChar('[');
	//uartChar(';');
	uartChar('H');
}

void uartFrase(const char *frase) {
	while (*frase != '\0') {
		uartChar(*frase);
		++frase;
	}
}

void uartNumero(uint32_t numero) {
	char digitos[16] = {'0'};
	uint32_t tamanho = 0;
	
	while (numero > 0) {
		digitos[tamanho++] = 48 + numero % 10;
		numero /= 10;
	}
	if (tamanho == 0) {
		tamanho = 1;
	}
	
	while (tamanho > 0) {
		uartChar(digitos[--tamanho]);
	}
}

void uartGetChar(void) {
	if (busy) {
		return;
	}

	if ((UART0_FR_R & 0x10) == 0x10) {
		return;
	}
	
	busy = 1;
	data = UART0_DR_R;
}

void ADC_Init(void) {
	uint32_t adc0 = SYSCTL_RCGCADC_R0;
	SYSCTL_RCGCADC_R = adc0;
	while ( (SYSCTL_PRADC_R & adc0) != adc0 ) {
		
	}
	
	ADC0_PC_R = 0x07;
	ADC0_SSPRI_R = (0 << 12) | (1 << 8) | (2 << 4) | 3;
	ADC0_ACTSS_R = 0;
	ADC0_EMUX_R = 0;
	ADC0_SSMUX3_R = 9;
	ADC0_SSCTL3_R = 6;
	ADC0_ACTSS_R = 8;
}