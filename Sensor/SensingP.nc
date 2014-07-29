#include <lib6lowpan/ip.h>
#include "sensing.h"
#include <UserButton.h>

module SensingP {
	uses {
		interface Boot;
		interface Leds;
		interface SplitControl as RadioControl;
		
		interface UDP as Sender;
		interface UDP as Receiver;

		interface Timer<TMilli> as SensorParTimer;
		interface Read<uint16_t> as ReadPar;	// adding interface for light sensor reading
	}

} implementation {

	enum {
		SAMPLING_PERIOD = 128, // ms
		SAMPLE_RATE = 128,		//---- 	sampling perid  from 256	
		SAMPLE_SIZE = 20,
		NUM_SENSORS = 1,
		DESIRED_value = 75,		// threshold/refernce value 
	};
	uint16_t m_average_threshold; 
	uint16_t value;	
	uint16_t m_difference;
	uint16_t m_diff_btw ; 
	nx_struct sensing_report stats;
	struct sockaddr_in6 multicast_sender;
	struct sockaddr_in6 multicast_receiver;

	event void Boot.booted() {
		call RadioControl.start();
	}

	event void RadioControl.startDone(error_t e) {
		
		multicast_receiver.sin6_port = htons(4000);
		inet_pton6(MULTICAST, &multicast_receiver.sin6_addr);

		call Sender.bind(7000);
		call Receiver.bind(4000);

		call SensorParTimer.startPeriodic(SAMPLING_PERIOD);	
	}

	event void Sender.recvfrom(struct sockaddr_in6 *from, void *data, uint16_t len, struct ip6_metadata *meta) {}

	event void Receiver.recvfrom(struct sockaddr_in6 *from, void *data, uint16_t len, struct ip6_metadata *meta) {
	}
	
	event void SensorParTimer.fired() {
		call ReadPar.read();
		stats.difference = m_difference;
		if (m_difference != 3) {
		call Sender.sendto(&multicast_receiver, &stats, sizeof(stats));
		}	
	}

	event void ReadPar.readDone(error_t e, uint16_t data)  {
		uint8_t i;
		m_difference = 3;			
		if (e == SUCCESS ) { 
			value = 0;
			for (i = 0; i <= SAMPLE_SIZE; i++) {
				value +=  data;
				 }
			m_average_threshold = value / SAMPLE_SIZE ;
		}
		if (m_average_threshold < DESIRED_value-5) {
			m_difference = 1;
			call Leds.led0On();	// red light ON when diff=1
			call Leds.led1Off();		
			call Leds.led2Off();		
		} 
		 if (m_average_threshold > DESIRED_value+5) {
			m_difference = 0;
			call Leds.led0Off();		
			call Leds.led1On();	// Green Light ON when diff=0
			call Leds.led2Off();
		}
		 if (m_average_threshold < 15) {
			m_difference = 2;	// check for if all LEDs glown or LEDs off 
			call Leds.led2On();
			call Leds.led0Off();
			call Leds.led1Off();	
		}
	}	
	

	event void RadioControl.stopDone(error_t e) {}
}
