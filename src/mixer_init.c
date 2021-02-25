
#include <stdint.h>

typedef int8_t      s8;
typedef int16_t     s16;
typedef int32_t     s32;
typedef int64_t     s64;
typedef uint8_t     u8;
typedef uint16_t    u16;
typedef uint32_t    u32;
typedef uint64_t    u64;

#define reg8(y) (*((volatile u8 *)(y)))
#define reg16(y) (*((volatile u16 *)(y)))
#define reg32(y) (*((volatile u32 *)(y)))

#define SAMPLING_RATE        12500
#define SAMPLING_PER_FRAME   250 //SAMPLING_RATE / 50  //12500 / 50 = 250 point samples

#define MAX_PCM_VOICES  4

#define pcm_dummy_size 4

extern void *timera_irq_new;

//sound samples need to be dividible by SAMPLING_PER_FRAMES (250), due to the pcm mixer only allow entire frames (of 250 bytes) to be dma fetched
volatile u32 sample1;
volatile u32 sample2;
volatile u32 sample3;
volatile u32 sample4;

volatile signed char *sample_test;


//250 bytes per stream, for 12.5 KHz at 50 Hz, 12500 / 50 Hz = 250 Bytes per Hz
//signed char dma_frame[3][SAMPLING_PER_FRAME + 6] = {{ 0 }} ;                  //Example: start_frame_address = dma_frame[0][0]
signed char dma_frame[1024] __attribute__((aligned(2))) = { 0 };//2048   | a 12,5 KHz; 0 - 249 primer dma
                 //DMA position and bytes per stream     //                          end_frame_address = dma_frame[0][249]

volatile u8 dma_position = 0;//DMA position start at 0, and reach up to 2; next return to 0


//Empty sound, when there are no sound samples pending
signed char pcm_dummy[1024] __attribute__((aligned(2))) = { 0 };

//This size is measured in terms of SAMPLING_PER_FRAME
volatile unsigned char sample1_size;
volatile unsigned char sample2_size;
volatile unsigned char sample3_size;
volatile unsigned char sample4_size;

volatile unsigned char sample1_len;
volatile unsigned char sample2_len;
volatile unsigned char sample3_len;
volatile unsigned char sample4_len;

volatile unsigned char sample1_qlen;
volatile unsigned char sample2_qlen;
volatile unsigned char sample3_qlen;
volatile unsigned char sample4_qlen;

volatile unsigned char sample1_queue;
volatile unsigned char sample2_queue;
volatile unsigned char sample3_queue;
volatile unsigned char sample4_queue;

volatile unsigned char sample1_loop;
volatile unsigned char sample2_loop;
volatile unsigned char sample3_loop;
volatile unsigned char sample4_loop;

volatile unsigned char sample1_playing;
volatile unsigned char sample2_playing;
volatile unsigned char sample3_playing;
volatile unsigned char sample4_playing;

//a 16 bits value as array index, more appropiate than a 32 bits value for a 16 bits wide bus system such ST/STE
//leads to a maximun of 65536 bytes per .wav file, 65536 / 12517 = 5,23 seconds per .wav



//Functions

//A value of 0 indicates that the pcm_sample couldnt be mixed
unsigned char play_wav(signed char *pcm_sample, unsigned char pcm_sample_size);



volatile u8 pcm_mix;
volatile u16 dma_irq;


/***************************************************
            STE DMA SOUND FUNCTIONS
***************************************************/

u32 old_timera = 0;

void set_LMC1992();
//extern "C" void timera_irq_new();

//extern "C" u8 g_seek;

//These variable would be previously calculated, prior to enable Timer A IRQ
volatile u8 dma0_start_high;
volatile u8 dma0_start_med;
volatile u8 dma0_start_low;

volatile u8 dma1_start_high;
volatile u8 dma1_start_med;
volatile u8 dma1_start_low;

volatile u8 dma2_start_high;
volatile u8 dma2_start_med;
volatile u8 dma2_start_low;

volatile u8 dma0_end_high;
volatile u8 dma0_end_med;
volatile u8 dma0_end_low;

volatile u8 dma1_end_high;
volatile u8 dma1_end_med;
volatile u8 dma1_end_low;

volatile u8 dma2_end_high;
volatile u8 dma2_end_med;
volatile u8 dma2_end_low;

volatile u32 sample1_mix;
volatile u32 sample2_mix;
volatile u32 sample3_mix;
volatile u32 sample4_mix;

volatile u32 sample1_qmix;
volatile u32 sample2_qmix;
volatile u32 sample3_qmix;
volatile u32 sample4_qmix;

volatile u32 sample_frame;

//A variable to pass data to LMC1992 asm function
volatile u16 LMC1992_data = 0;

void stop_ste_dma_sound()
{
    //printf("device:: stop STE DMA sound\n");
    
    reg8(0xffff8901) = 0;						// stop DMA
    reg8(0xfffffa07) &= ~0b00100000;	// timera
    reg8(0xfffffa13) &= ~0b00100000;	// timera mask
    
    reg32(134) = old_timera;

}//End of stop_ste_dma_sound()

void start_ste_dma_sound()
{
    signed char *aux;
    unsigned int aux2;

    aux = &pcm_dummy[0];
    sample1_mix = (u32)(void*)aux;

    aux = &pcm_dummy[0];
    sample2_mix = (u32)(void*)aux;

    aux = &pcm_dummy[0];
    sample3_mix = (u32)(void*)aux;

    aux = &pcm_dummy[0];
    sample4_mix = (u32)(void*)aux;

    aux = &dma_frame[0];
    sample_frame = (u32)(void*)aux;		

    sample1 = (u32)(void*)pcm_dummy;
    sample2 = (u32)(void*)pcm_dummy;
    sample3 = (u32)(void*)pcm_dummy;
    sample4 = (u32)(void*)pcm_dummy;

    sample1_size = pcm_dummy_size;
    sample2_size = pcm_dummy_size; 
    sample3_size = pcm_dummy_size;
    sample4_size = pcm_dummy_size;
		
    sample1_len = pcm_dummy_size;
    sample2_len = pcm_dummy_size; 
    sample3_len = pcm_dummy_size;
    sample4_len = pcm_dummy_size;
    
    sample1_loop = 0;
    sample2_loop = 0;
    sample3_loop = 0;
    sample4_loop = 250;//Selected as music
    
    sample1_playing = 0;
    sample2_playing = 0;
    sample3_playing = 0;
    sample4_playing = 0;
    
    pcm_mix = 0;
    
   
       		
		//printf("device:: init STE DMA Sound\n");
		
		//At start, there is nothing to mix
		pcm_mix = (unsigned char)0;
		dma_irq = (unsigned short)0;//Debug
		
			aux = &dma_frame[250];//250
			aux2 = (u32)(void*)aux;
			
			//Start adress
			dma1_start_high = (aux2 >> 16);
			
			dma1_start_med = (aux2 >> 8);
			
			dma1_start_low = aux2;
			
			aux = &dma_frame[500];//499
			aux2 = (u32)(void*)aux;
			
			//End address
			 dma1_end_high = (aux2 >> 16);
			 dma1_end_med = (aux2 >> 8);
			 dma1_end_low = aux2;
			
			//2
			aux = &dma_frame[500];//500
			aux2 = (u32)(void*)aux;
			
			//Start adress
			 dma2_start_high = (aux2 >> 16);
			 dma2_start_med = (aux2 >> 8);
			 dma2_start_low = aux2;
			
			aux = &dma_frame[750];//749
			aux2 = (u32)(void*)aux;
			//End address
			 dma2_end_high = (aux2 >> 16);
			 dma2_end_med = (aux2 >> 8);
			 dma2_end_low = aux2;
			 
			aux = &dma_frame[0];
			aux2 = (u32)(void*)aux;
			//Start adress
			 dma0_start_high = (aux2 >> 16);
			 dma0_start_med = (aux2 >> 8);
			 dma0_start_low = aux2;
			
			aux = &dma_frame[250];//249
			aux2 = (u32)(void*)aux;
			//End address
			 dma0_end_high = (aux2 >> 16);
			 dma0_end_med = (aux2 >> 8);
			 dma0_end_low = aux2;
			
		
		old_timera = reg32(134);
		reg32(134) = (u32)((void*)&timera_irq_new);	
		
	//printf("device:: playback...\n");

	// configure microwire mixer/filter
	LMC1992_data = 0b10000000001; set_LMC1992();
	LMC1992_data = 0b10001000110; set_LMC1992();
	LMC1992_data = 0b10010000110; set_LMC1992();
	LMC1992_data = 0b10011101000; set_LMC1992();
	LMC1992_data = 0b10100010100; set_LMC1992();
	LMC1992_data = 0b10101010100; set_LMC1992();

	// enable TimerA interrupt handler
	reg8(0xfffffa07) |=  0b00100000;	// timera enable     binary(00100000)    GPI7  binary(10000000);
	reg8(0xfffffa13) |=  0b00100000;	// timera mask OFF   binary(00100000)    GPI7  binary(10000000);
	
	reg8(0xfffffa03) &=  0b01111111;
	
	reg8(0xfffffa19) =   0;                   // timera function stop, configura and start it at next sentences
	reg8(0xfffffa1f) =   1;					// timera event count
	reg8(0xfffffa19) =   8;					// timera event count mode
	
	
	// for STE
	reg8(0xffff8901) = 0b00000000;// binary(00000000) Disabled until base and end addesses are written
	reg8(0xffff8921) = 0b10000001;//Mono at 12.5 KHz  binary(10000001)
	
	// starts DMA playback, sends base and end adresses
			//Loads 0
			
			//Start adress
			reg16(0xffff8902) = dma0_start_high;
			reg16(0xffff8904) = dma0_start_med;
			reg16(0xffff8906) = dma0_start_low;
			
			
			//End address
			reg16(0xffff890E) = dma0_end_high;
			reg16(0xffff8910) = dma0_end_med;
			reg16(0xffff8912) = dma0_end_low;
			
			//Enable DMA sound
			reg8(0xffff8901) = 0b00000011;//Enabled, loop mode
			
			//Wait a bit until proceed writing dma frame 1 addresses
			asm(" nop; ");
			asm(" nop; ");
			asm(" nop; ");
			
			//Loads 1
			
			//Start adress
			reg16(0xffff8902) = dma1_start_high;
			reg16(0xffff8904) = dma1_start_med;
			reg16(0xffff8906) = dma1_start_low;
			
			//End address
			reg16(0xffff890E) = dma1_end_high;
			reg16(0xffff8910) = dma1_end_med;
			reg16(0xffff8912) = dma1_end_low;
			
			
			

	         dma_position = 2;
		
}//End of start_ste_dma_sound()

