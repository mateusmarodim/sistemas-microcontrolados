// gpio.c
// Desenvolvido para a placa EK-TM4C1294XL
// Inicializa as portas J e N
// Prof. Guilherme Peron


#include <stdint.h>

#include "tm4c1294ncpdt.h"

#define GPIO_PORTA  (0x00000001)
#define GPIO_PORTE  (0x00000010)
#define GPIO_PORTF  (0x00000020)

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
	SYSCTL_RCGCGPIO_R = (GPIO_PORTA | GPIO_PORTE | GPIO_PORTF );
	//1b.   após isso verificar no PRGPIO se a porta está pronta para uso.
  while((SYSCTL_PRGPIO_R & (GPIO_PORTA | GPIO_PORTE | GPIO_PORTF) ) != (GPIO_PORTA | GPIO_PORTE | GPIO_PORTF) ){};
	
	// 2. Limpar o AMSEL para desabilitar a analógica
	GPIO_PORTA_AHB_AMSEL_R = 0x00;
	GPIO_PORTE_AHB_AMSEL_R = 0x10;
	GPIO_PORTF_AHB_AMSEL_R = 0x00;
		
	// 3. Limpar PCTL para selecionar o GPIO
	GPIO_PORTA_AHB_PCTL_R = 0x11;
	GPIO_PORTE_AHB_PCTL_R = 0x00;
	GPIO_PORTF_AHB_PCTL_R = 0x00;

	// 4. DIR para 0 se for entrada, 1 se for saída
	GPIO_PORTE_AHB_DIR_R = 0x03;
	GPIO_PORTF_AHB_DIR_R = 0x04;
		
	// 5. Limpar os bits AFSEL para 0 para selecionar GPIO sem função alternativa	
	GPIO_PORTA_AHB_AFSEL_R = 0x03;
	GPIO_PORTE_AHB_AFSEL_R = 0x10;
	GPIO_PORTF_AHB_AFSEL_R = 0x00;

		
	// 6. Setar os bits de DEN para habilitar I/O digital	
	GPIO_PORTA_AHB_DEN_R = 0x03;
	GPIO_PORTE_AHB_DEN_R = 0x03; 
	GPIO_PORTF_AHB_DIR_R = 0x04; 
	
	// 7. Habilitar resistor de pull-up interno, setar PUR para 1


}	

// -------------------------------------------------------------------------------

void PortE_Output(uint32_t parametro) {
    uint32_t val = parametro & 0x03;

    GPIO_PORTE_AHB_DATA_R = (GPIO_PORTE_AHB_DATA_R & ~(0x03)) | val; 
}

void PortF_Output(uint32_t parametro) {
    uint32_t val = parametro & 0x04;

    GPIO_PORTF_AHB_DATA_R = (GPIO_PORTF_AHB_DATA_R & ~(0x04)) | val; 
}
