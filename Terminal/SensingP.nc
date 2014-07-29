#include <lib6lowpan/ip.h>
#include "sensing.h"

module SensingP {
	uses {
		interface Boot;
		interface Leds;
		interface SplitControl as RadioControl;

		interface UDP as Sender;
		interface UDP as Receiver;

		interface Timer<TMilli> as SensorParTimer;
		interface Read<uint16_t> as ReadPar;	// adding interface for light sensor reading

		interface GeneralIO as PinA;	//GIO3 port 26
		interface GeneralIO as PinB;    //GIO2 port 23
		interface GeneralIO as PinC;    //GIO1 port 21
		interface GeneralIO as PinD;    //GIO0 port 20
	}

} implementation {

	enum {
		SAMPLING_PERIOD = 128, // ms
		SAMPLE_RATE = 256,		//---- 		
		SAMPLE_SIZE = 20,
		NUM_SENSORS = 1,
		//DESIRED_value = 75,		// threshold/refernce value 
	};
	//uint16_t m_average_threshold; 
	//uint16_t value;	
	//uint16_t m_difference;
	//uint16_t m_diff_btw ; 
	uint16_t LEDs;
	nx_struct sensing_report stats;
	struct sockaddr_in6 multicast_sender;
	struct sockaddr_in6 multicast_receiver;
	
	// controlfunction declaration
	void Control(uint16_t LEDs) {
		// at start of Control Func we turn off All LEDS
		call PinD.makeOutput();
		call PinD.set();
		call PinC.makeInput();				
		call PinB.makeInput();	
		call PinA.makeInput();
		if(LEDs > 7){
			call PinA.makeOutput();	
			call PinA.clr();	
		}
		if (LEDs % 2 == 1 ){
			call PinD.makeOutput();
			call PinD.clr();		
		}
		if((LEDs > 3 && LEDs < 8) || LEDs > 11 ) {
			call PinB.makeOutput();		
			call PinB.clr();
		}
		if((LEDs > 1 && LEDs < 4) || (LEDs > 5 && LEDs < 8) || (LEDs > 9 && LEDs < 12) || (LEDs > 13)){
			call PinC.makeOutput();
			call PinC.clr();
		}		
	}




	event void Boot.booted() {
		call RadioControl.start();
		call PinA.makeInput();
		// to have 7 LEDS glowing at the start
		call PinD.makeOutput();// make 1 LED glow
		call PinB.makeOutput();// make 2 LED glow
		call PinC.makeOutput();// make 4 LED glow
		LEDs = 7;	
		//stats1.difference = 5;	// setting a value for difference so have it change only when it receivend a new value
		
	}

	event void RadioControl.startDone(error_t e) {
		//route_dest.sin6_port = htons(8000);
		//inet_pton6(REPORT_DEST, &route_dest.sin6_addr);

		multicast_receiver.sin6_port = htons(4000);
		inet_pton6(MULTICAST, &multicast_receiver.sin6_addr);

		call Sender.bind(7000);
		call Receiver.bind(4000);
	
		call SensorParTimer.startPeriodic(SAMPLING_PERIOD);	
	}

	event void Sender.recvfrom(struct sockaddr_in6 *from, void *data, uint16_t len, struct ip6_metadata *meta) {}

	event void Receiver.recvfrom(struct sockaddr_in6 *from, void *data, uint16_t len, struct ip6_metadata *meta) {
		nx_struct sensing_report stats1;
		memcpy(&stats1, data, sizeof(nx_struct sensing_report));
		
		if(stats1.difference == 0) {
			call Leds.led0Off();
			call Leds.led1On();	// GREEN Light ON when diff=0
			if(LEDs > 1) {
				LEDs-- ;
				Control(LEDs);
			}			
		} 
		
		if (stats1.difference == 1) {
			call Leds.led0On();	// RED light ON  
			call Leds.led1Off();
			if(LEDs<15) {			
				LEDs++;	
				Control(LEDs);
			}
		}				
	}

	event void SensorParTimer.fired() {
		/*stats.difference = m_difference;
		call Sender.sendto(&multicast_receiver, &stats, sizeof(stats));
		call Leds.led1Toggle();	*/
	}

	event void ReadPar.readDone(error_t e, uint16_t data)  {	
	}

	event void RadioControl.stopDone(error_t e) {}
}
