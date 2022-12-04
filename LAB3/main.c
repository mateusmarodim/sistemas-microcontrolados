// main.c
// Desenvolvido para a placa EK-TM4C1294XL
//Gabriel Godinho e Mateus Marodim

#include <stdint.h>
#include "tm4c1294ncpdt.h"

#define PASSOS_TOTAL 2048

void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);
void Int_Init(void);
void GPIOPortJ_Handler(void);
uint32_t PortJ_Input(void);
void PortA_Output(uint32_t entrada);
void PortF_Output(uint32_t leds);
void PortN_Output(uint32_t leds);
void PortH_Output(uint32_t parametro);
void PortP_Output(uint32_t entrada);
void PortQ_Output(uint32_t entrada);
void Pisca_leds(void);
void Imprime_Frase(uint8_t* frase);
void LCD_Init(void);
void LCD_Caracter(uint8_t caracter);
void LCD_Instrucao(uint32_t codigo);
uint32_t Teclas_Input(uint32_t* parametro,uint32_t* parametro2,uint32_t* parametro3);
void preencheFraseRotacao(void);
void rotacionaMotor(void);
void passoMotor(void);
void LEDScheck(void);
void Timer_Int_Init(void);
void Timer2A_Handler(void);

typedef enum estados{
	Espera,
	Voltas,
	Direcao,
	Velocidade,
	Rotaciona,
  FIM
}EstadosBobina;
EstadosBobina estadoAtual = Espera;
EstadosBobina proximo;

int32_t tecla = -1;
uint8_t voltas[] = "Informe o Numero de Voltas: #"; 
uint8_t direcao[] = "Digite 1 para hr2 para anti-hr: #"; 
uint8_t velocidade[] = "1:passo completo2: meio-passo#"; 
uint8_t rotaciona[33] = "Volta:0X Vel:2/2     horario#"; 
uint8_t final[] = "FIM#"; 

uint32_t nvoltas = 0;
uint8_t flag = 0; //sinaliza que o nvoltas foi digitado
uint32_t sentido = 0;
uint32_t passo = 0;
uint32_t passoAtual = 0;
uint32_t PassoCompleto[4] = { 0x03, 0x06, 0x0C, 0x09 }; //todos os 4 passos do ciclo do passo completo
uint32_t MeioPasso[8] = { 0x01, 0x03, 0x02, 0x06, 0x04, 0x0C, 0x08, 0x09 }; //todos os 8 passos do ciclo do meio passo
uint32_t limite = 8; // auxilia a funçao de passo
uint32_t contPassos = 0;
uint32_t vetorLEDS = 0; //quais leds devem ser acesos
uint8_t ledTimer = 0; // led do temporizador

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	Int_Init();
	LCD_Init();
	Timer_Int_Init();
	PortP_Output(0x20);
	while (1)
	{
		switch (estadoAtual){
			case Espera: //ler entrada do teclado e conferir se é '*'
				tecla = -1;
				while(tecla != 10){// enquanto n for *
					tecla = Teclas_Input(&GPIO_PORTL_DATA_R,&GPIO_PORTM_DIR_R,&GPIO_PORTM_DATA_R);
				}
				SysTick_Wait1ms(500);
				estadoAtual = Voltas;
			break;
			case Voltas:
				Imprime_Frase(voltas);
				while(flag == 0){
					tecla = -1;
					while(tecla <1 || tecla > 10){ //digita 1 numero
						tecla = Teclas_Input(&GPIO_PORTL_DATA_R,&GPIO_PORTM_DIR_R,&GPIO_PORTM_DATA_R);
					}
					if(tecla == 10 && nvoltas != 0)
						flag = 1;
					else
						nvoltas = tecla;
					
					if(tecla == 1){//se for 1 pode digitar 0 para virar 10
						while(tecla != -1){ //espera soltar o botao
						tecla = Teclas_Input(&GPIO_PORTL_DATA_R,&GPIO_PORTM_DIR_R,&GPIO_PORTM_DATA_R);
						}
						while(tecla <0 || tecla > 10){
							tecla = Teclas_Input(&GPIO_PORTL_DATA_R,&GPIO_PORTM_DIR_R,&GPIO_PORTM_DATA_R);
						}
						if(tecla == 0)
							nvoltas = 10;
						else if(tecla == 10)
							flag = 1;
						else
							nvoltas = tecla;
					}
				}
				estadoAtual = Direcao;
			break;
			case Direcao:
				Imprime_Frase(direcao);
				tecla = -1;
				while(tecla != 1 && tecla != 2){ // 1 para horario e 2 anti horario
					tecla = Teclas_Input(&GPIO_PORTL_DATA_R,&GPIO_PORTM_DIR_R,&GPIO_PORTM_DATA_R);
				}
				vetorLEDS = tecla == 1 ? 1 : 0x80;
				sentido = tecla;
				estadoAtual = Velocidade;
			break;
			case Velocidade:
				while(tecla != -1){ //espera soltar o botao
						tecla = Teclas_Input(&GPIO_PORTL_DATA_R,&GPIO_PORTM_DIR_R,&GPIO_PORTM_DATA_R);
				}
				Imprime_Frase(velocidade);
				tecla = -1;
				while(tecla != 1 && tecla != 2){//1 para passo completo e 2 meio passo
						tecla = Teclas_Input(&GPIO_PORTL_DATA_R,&GPIO_PORTM_DIR_R,&GPIO_PORTM_DATA_R);
				}
					passo = tecla;
					estadoAtual = Rotaciona;
			break;
			case Rotaciona:
				PortA_Output(vetorLEDS);//acende 0 1 LED
				PortQ_Output(vetorLEDS);
				GPIO_PORTJ_AHB_IM_R = 0x1; //ativa interrupcao
				preencheFraseRotacao();
				Imprime_Frase(rotaciona);
				while(nvoltas > 0){
					rotacionaMotor();
					LEDScheck();
				}
				estadoAtual = FIM;
			break;  
			case FIM:
				GPIO_PORTJ_AHB_IM_R = 0x0;
				PortA_Output(0);
				PortQ_Output(0);
				Imprime_Frase(final);
				nvoltas = 0;
				sentido = 0;
				passo = 0;
				contPassos = 0;
				passoAtual = 0;
				flag = 0;
				estadoAtual = Espera;
			break;
		}
	}
}
void GPIOPortJ_Handler(void){
	nvoltas = 0;
	GPIO_PORTJ_AHB_ICR_R = 0x1;
}

void Imprime_Frase(uint8_t* frase){
	LCD_Instrucao(0x01);
	int i = 0;
	while(frase[i] != '#'){// '#' sinalzia fim da string
		LCD_Caracter(frase[i]);
		i++;
		if(i == 16)
			LCD_Instrucao(0xC0);
	}
	
	return;
}

void preencheFraseRotacao(void){
	if (nvoltas == 10){
		rotaciona[6] = '1';
		rotaciona[7] = '0';
	}
	else{
		rotaciona[7] = (char)(nvoltas + 48);
	}
	
	if(passo == 1)
		rotaciona[13] = '2';
	
	if(sentido == 2){
		rotaciona[16] = 'a';
		rotaciona[17] = 'n';
		rotaciona[18] = 't';
		rotaciona[19] = 'i';
		rotaciona[20] = '-';
	}
}

void rotacionaMotor(void){
	SysTick_Wait1ms(2);
	passoMotor();
}

void passoMotor(void) {
	
	if(passo == 2){
		PortH_Output(MeioPasso[passoAtual]);
		limite = 8;
	}
	else{
		PortH_Output(PassoCompleto[passoAtual]);
		limite = 4;
	}
	if (sentido == 1) {
		++passoAtual;
		if (passoAtual >= limite) {
			passoAtual = 0;
		}
	} else {
		if (passoAtual == 0) {
			passoAtual = (limite - 1);
		} else {
			--passoAtual;
		}
	}
	contPassos++;
}

void LEDScheck(void){
	if(contPassos == PASSOS_TOTAL / 8 * passo){//45 graus
		if(vetorLEDS == 255){//se tiver completado 1 volta
			vetorLEDS = 0;
			--nvoltas;
			rotaciona[6] = '0';
			rotaciona[7] = (char)(nvoltas + 48); // numero int pra char
			Imprime_Frase(rotaciona);
		}
		if(sentido == 1){
			vetorLEDS <<= 1;
			vetorLEDS += 1;
		}	else {
			vetorLEDS >>= 1;
			vetorLEDS += 0x80;
		}
		PortA_Output(vetorLEDS);
		PortQ_Output(vetorLEDS);
		
		contPassos = 0;
	}
}


void Timer_Int_Init(void) {
	SYSCTL_RCGCTIMER_R |= 0x04;
	while ((SYSCTL_PRTIMER_R & 0x04) == 0) {
		
	}

	TIMER2_CTL_R &= ~(0x01u);
	TIMER2_CFG_R &= ~(0x07u);
	TIMER2_TAMR_R = (TIMER2_TAMR_R & ~(0x03u)) | 0x02;
	TIMER2_TAILR_R = 3999999;
	TIMER2_TAPR_R = 0;
	TIMER2_ICR_R |= 0x01;
	TIMER2_IMR_R |= 0x01;
	NVIC_PRI5_R = 4u << 29;
	NVIC_EN0_R = 1u << 23;
	TIMER2_CTL_R |= 0x01;
}

void Timer2A_Handler(void) {
	ledTimer ^= 0x01;
	ledTimer &= (estadoAtual == Rotaciona);
	PortN_Output(ledTimer);
	TIMER2_ICR_R |= 0x01;
}