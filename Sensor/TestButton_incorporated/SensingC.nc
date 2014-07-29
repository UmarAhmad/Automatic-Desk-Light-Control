configuration SensingC {
} implementation {
	components MainC, LedsC, SensingP;
	SensingP.Boot -> MainC;
	SensingP.Leds -> LedsC;

	components IPStackC;
	components IPDispatchC;
	components UdpC;
	components UDPShellC;
	components RPLRoutingC;
	components StaticIPAddressTosIdC;
	
	// User Button
	components UserButtonC;		// using the USER button on Tmote to start the sensing application on it, 
	SensingP.Get -> UserButtonC;
	SensingP.Notify -> UserButtonC;

	SensingP.RadioControl -> IPStackC;

	components new TimerMilliC() as SensorParTimer;
	SensingP.SensorParTimer -> SensorParTimer;

	components new HamamatsuS1087ParC() as SensorPar;	//----- LIGHT sensor reading taken
	SensingP.ReadPar -> SensorPar.Read;

	components new UdpSocketC() as Sender;
	SensingP.Sender -> Sender;

	components new UdpSocketC() as Receiver;
	SensingP.Receiver -> Receiver;
}
