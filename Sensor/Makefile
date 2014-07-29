COMPONENT=SensingC

BUILD_EXTRA_DEPS = Sensing.py
Sensing.py: sensing.h
	mkdir -p utils
	mig python -I$(TOSROOT)/tos/lib/net/blip \
	-I$(TOSROOT)/support/sdk/c/blip/lib6lowpan \
	-python-classname=Sensing sensing.h sensing_report \
	-o utils/Sensing.py


CFLAGS += -DCC2420_DEF_CHANNEL=$(TOS_CHANNEL)

# disables support for the AM stack, which somewhat reduces code size
# and compresses packet formats.  If you want to use other tinyos
# protocols which are AM-based, you should not include this.
CFLAGS += -DIEEE154FRAMES_ENABLED

#blip2.0
PFLAGS += -DRPL_ROUTING -DRPL_STORING_MODE -I$(TOSDIR)/lib/net/rpl
PFLAGS += -DBLIP_DERIVE_SHORTADDRS
PFLAGS += -DIN6_PREFIX=\"fec0::\"

include $(MAKERULES)
