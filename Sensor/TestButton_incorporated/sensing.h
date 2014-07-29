#ifndef SENSING_H_
#define SENSING_H_

#include <IPDispatch.h>		// for multicast

enum {
      AM_SENSING_REPORT = -1
};

nx_struct sensing_report {
  //nx_uint16_t seqno;
  //nx_uint16_t sender;
  //nx_uint16_t par_average_value;
  nx_uint16_t difference;
} ;

#define REPORT_DEST "fec0::5"
#define MULTICAST "ff02::1"

#endif
