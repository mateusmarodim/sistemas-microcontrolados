// gpio.c
// Desenvolvido para a placa EK-TM4C1294XL
// Inicializa as portas J e N
// Prof. Guilherme Peron


#include <stdint.h>

#include "tm4c1294ncpdt.h"

#define GPIO_PORTA  (0x001) //bit 0
#define GPIO_PORTH  (0x080) //bit 7
#define GPIO_PORTJ  (0x0100) //bit 8
#define GPIO_PORTK  (0x0200) //bit 9
#define GPIO_PORTL  (0x400) //bit 10
#define GPIO_PORTM  (0x800) //bit 11
#define GPIO_PORTN  (0x1000) //bit 12
#define GPIO_PORTP  (0x2000) //bit 13
#define GPIO_PORTQ  (0x4000) //bit 14

uint32_t* teste;


void SysTick_Wait1ms(uint32_t delay);
// -------------------------------------------------------------------------------
// Função GPIO_Init
// Inicializa os ports J e N
// Parâmetro de entrada: Não tem
// Parâmetro de saída: Não tem
void GPIO_Init(void)
{
	//1a. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO
	SYSCTL_RCGCGPIO_R = (GPIO_PORTA | GPIO_PORTH | GPIO_PORTJ | GPIO_PORTK | GPIO_PORTN | GPIO_PORTL | GPIO_PORTM | GPIO_PORTP | GPIO_PORTQ);
	//1b.   após isso verificar no PRGPIO se a porta está pronta para uso.
  while((SYSCTL_PRGPIO_R & (GPIO_PORTA | GPIO_PORTH | GPIO_PORTJ | GPIO_PORTK | GPIO_PORTN | GPIO_PORTL | GPIO_PORTM | GPIO_PORTN | GPIO_PORTP | GPIO_PORTQ) ) != (GPIO_PORTA | GPIO_PORTH | GPIO_PORTJ | GPIO_PORTK | GPIO_PORTN | GPIO_PORTL | GPIO_PORTM | GPIO_PORTN | GPIO_PORTP | GPIO_PORTQ) ){};
	
	// 2. Limpar o AMSEL para desabilitar a analógica
	GPIO_PORTA_AHB_AMSEL_R = 0x00;
	GPIO_PORTH_AHB_AMSEL_R = 0x00;
	GPIO_PORTJ_AHB_AMSEL_R = 0x00;
	GPIO_PORTK_AMSEL_R = 0x00;
	GPIO_PORTL_AMSEL_R = 0x00;
	GPIO_PORTM_AMSEL_R = 0x00;
	GPIO_PORTN_AMSEL_R = 0x00;
	GPIO_PORTP_AMSEL_R = 0x00;
	GPIO_PORTQ_AMSEL_R = 0x00;
		
	// 3. Limpar PCTL para selecionar o GPIO
	GPIO_PORTA_AHB_PCTL_R = 0x00;
	GPIO_PORTH_AHB_PCTL_R = 0x00;
	GPIO_PORTJ_AHB_PCTL_R = 0x00;
	GPIO_PORTK_PCTL_R = 0x00;
	GPIO_PORTL_PCTL_R = 0x00;
	GPIO_PORTM_PCTL_R = 0x00;
	GPIO_PORTN_PCTL_R = 0x00;
	GPIO_PORTP_AMSEL_R = 0x00;
	GPIO_PORTQ_PCTL_R = 0x00;

	// 4. DIR para 0 se for entrada, 1 se for saída
	GPIO_PORTA_AHB_DIR_R = 0xF0;
	GPIO_PORTH_AHB_DIR_R = 0x0F;
	GPIO_PORTJ_AHB_DIR_R = 0x00;
	GPIO_PORTK_DIR_R = 0xFF; //BIT0 | BIT1
	GPIO_PORTN_DIR_R = 0x03; //BIT0 | BIT1
	GPIO_PORTL_DIR_R = 0x00;
	GPIO_PORTM_DIR_R = 0x07;
	GPIO_PORTP_DIR_R = 0x20;
	GPIO_PORTQ_DIR_R = 0x0F;
		
	// 5. Limpar os bits AFSEL para 0 para selecionar GPIO sem função alternativa	
	GPIO_PORTA_AHB_AFSEL_R = 0x00;
	GPIO_PORTH_AHB_AFSEL_R = 0x00;
	GPIO_PORTJ_AHB_AFSEL_R = 0x00;
	GPIO_PORTK_AFSEL_R = 0x00; 
	GPIO_PORTL_AFSEL_R = 0x00; 
	GPIO_PORTM_AFSEL_R = 0x00;
	GPIO_PORTN_AFSEL_R = 0x00;
	GPIO_PORTP_AFSEL_R = 0x00;
	GPIO_PORTQ_AFSEL_R = 0x00;
		
	// 6. Setar os bits de DEN para habilitar I/O digital	
	GPIO_PORTA_AHB_DEN_R = 0xF0;
	GPIO_PORTH_AHB_DEN_R = 0x0F;
	GPIO_PORTJ_AHB_DEN_R = 0x03;   //Bit0 e bit1
	GPIO_PORTK_DEN_R = 0xFF; 		   //Bit0 e bit1
	GPIO_PORTN_DEN_R = 0x03;
	GPIO_PORTL_DEN_R = 0x0F;
	GPIO_PORTM_DEN_R = 0xF7;
	GPIO_PORTP_DEN_R = 0x20;
	GPIO_PORTQ_DEN_R = 0x0F;
	
	// 7. Habilitar resistor de pull-up interno, setar PUR para 1
	GPIO_PORTJ_AHB_PUR_R = 0x01;   //Bit0
	GPIO_PORTL_PUR_R = 0x0F;

}	

// -------------------------------------------------------------------------------
// Função PortJ_Input
// Lê os valores de entrada do port J
// Parâmetro de entrada: Não tem
// Parâmetro de saída: o valor da leitura do port
uint32_t PortJ_Input(void)
{
	return GPIO_PORTJ_AHB_DATA_R;
}

void Int_Init(void){
	GPIO_PORTJ_AHB_IM_R = 0x0;
	GPIO_PORTJ_AHB_IS_R = 0x0;
	GPIO_PORTJ_AHB_IBE_R = 0x0;
	GPIO_PORTJ_AHB_IEV_R = 0x0;
	GPIO_PORTJ_AHB_ICR_R = 0x1;
	NVIC_EN1_R = 0x80000;
	NVIC_PRI12_R = (5<<29);
}

// -------------------------------------------------------------------------------
// Função PortN_Output
// Escreve os valores no port N
// Parâmetro de entrada: Valor a ser escrito
// Parâmetro de saída: não tem
void PortN_Output(uint32_t valor)
{
    uint32_t temp;
    //vamos zerar somente os bits menos significativos
    //para uma escrita amigável nos bits 0 e 1
    temp = GPIO_PORTN_DATA_R & 0xFC;
    //agora vamos fazer o OR com o valor recebido na função
    temp = temp | valor;
    GPIO_PORTN_DATA_R = temp; 
}
	
void LCD_Instrucao(uint32_t codigo){
	uint32_t mascara = GPIO_PORTK_DIR_R & 0xFF;
	uint32_t valor = codigo & mascara;

	GPIO_PORTK_DATA_R = (GPIO_PORTK_DATA_R & ~(mascara)) | valor; 

	GPIO_PORTM_DATA_R = ((GPIO_PORTM_DATA_R | 0x04u) & ~(0x01u));

	SysTick_Wait1ms(1);
	
	GPIO_PORTM_DATA_R = GPIO_PORTM_DATA_R & ~(0x04u);
	
	SysTick_Wait1ms(2);
	
}
	
void LCD_Caracter(uint8_t caracter){
	GPIO_PORTK_DATA_R = caracter;
	
	GPIO_PORTM_DATA_R = GPIO_PORTM_DATA_R | 0x05u;

	SysTick_Wait1ms(1);
	
	GPIO_PORTM_DATA_R = GPIO_PORTM_DATA_R & 0xFBu;
	
	SysTick_Wait1ms(2);
}

void LCD_Init(void){
	LCD_Instrucao(0x38);
	
	LCD_Instrucao(0x06);
	
	LCD_Instrucao(0x0E);
	
	LCD_Instrucao(0x01);
}

void PortH_Output(uint32_t parametro) {
    uint32_t valor = (parametro) & 0x0F;
	
    GPIO_PORTH_AHB_DATA_R = (GPIO_PORTH_AHB_DATA_R & ~(0x0Fu)) | valor; 
}

void PortA_Output(uint32_t entrada) {
    uint32_t valor = entrada & 0xF0;
	
    GPIO_PORTA_AHB_DATA_R = (GPIO_PORTA_AHB_DATA_R & ~(0xF0u)) | valor; 
}


void PortQ_Output(uint32_t entrada) {
    uint32_t valor = entrada & 0x0F;

    GPIO_PORTQ_DATA_R = (GPIO_PORTQ_DATA_R & ~(0x0Fu)) | valor; 
}

void PortP_Output(uint32_t entrada) {
    uint32_t valor = entrada & 0x20;

    GPIO_PORTP_DATA_R = (GPIO_PORTQ_DATA_R & ~(0x0Fu)) | valor; 
}
