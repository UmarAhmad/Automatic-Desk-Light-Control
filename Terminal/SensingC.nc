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

	SensingP.RadioControl -> IPStackC;

	//GPIO wiring-------------------------
	components HplMsp430GeneralIOC;
	components new Msp430GpioC() as PinA;
	PinA -> HplMsp430GeneralIOC.Port26;
	SensingP.PinA -> PinA;

	components new Msp430GpioC() as PinB;
	PinB -> HplMsp430GeneralIOC.Port23;
	SensingP.PinB -> PinB;

	components new Msp430GpioC() as PinC;
	PinC -> HplMsp430GeneralIOC.Port21;
	SensingP.PinC -> PinC;

	components new Msp430GpioC() as PinD;
	PinD -> HplMsp430GeneralIOC.Port20;
	SensingP.PinD -> PinD;
	//--------------------------------------

	components new TimerMilliC() as SensorParTimer;
	SensingP.SensorParTimer -> SensorParTimer;

	components new HamamatsuS1087ParC() as SensorPar;	//----- LIGHT sensor reading taken
	SensingP.ReadPar -> SensorPar.Read;

	components new UdpSocketC() as Sender;
	SensingP.Sender -> Sender;

	components new UdpSocketC() as Receiver;
	SensingP.Receiver -> Receiver;
}
