/*
 * powercom.h - defines for the newpowercom.c driver
 *
 * $Id: powercom.h 1240 2008-01-26 16:43:38Z clepple-guest $
 *
 * Copyrights:
 * (C) 2002 Simon Rozman <simon@rozman.net>
 * (C) 1999  Peter Bieringer <pb@bieringer.de>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 *
 */

/* C-libary includes */
#include <sys/file.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include "serial.h"
#include <limits.h>

/* nut includes */
#include "timehead.h"


/* supported types */
struct type {
	const char    *name;
	unsigned char num_of_bytes_from_ups;
	
	struct method_of_flow_control {
	    char *name;
	    void (*setup_flow_control)(void);
	} flowControl;
	
	struct validation_byte {
	    unsigned int index_of_byte, required_value;
	    /* An example might explain the intention better then prose.
	     * Suppose we want to validate the data with:
	     *     powercom_raw_data[5] == 0x80
	     * then we will set index_of_byte to 5U and required_value to
	     * 0x80U: { 5U, 0x80U }.
	     */
	} validation[3];
	/* The validation array is of length 3 because 3 is longest 
	 * validation sequence for any type.
	 */
	
	/* Some UPSs must have a minutes and a seconds arguments for 
	 * the COUNTER commands while others are known to work with the
	 * seconds argument alone.
	 */
	struct deley_for_power_kill {
	    unsigned int  delay[2];   /* { minutes, seconds } */
	    unsigned char minutesShouldBeUsed;
	    /* 'n' in case the minutes value, which is deley[0], should
		 * be skipped and not sent to the UPS. 
		 */
	} shutdown_arguments;
	
	/* parameters to calculate input and output freq., one pair for
	 * each type:
	 *  Each pair defines parameters for 1/(A*x+B) to calculate freq.
	 *  from raw data
	 */
	float         freq[2];
	
	/* parameters to calculate load %, two pairs for each type:
	 *  First pair defines the parameters for A*x+B to calculate load
	 *  from raw data when offline and the second pair is used when
	 *  online
	 */
	float         loadpct[4];
	
	/* parameters to calculate battery %, five parameters for each type:
	 *  First three params defines the parameters for A*x+B*y+C to calculate
	 *  battery % (x is raw data, y is load %) when offline.
	 *  Fourth and fifth parameters are used to calculate D*y+E when online.
	 */
	float         battpct[5];

	/* parameters to calculate utility and output voltage, two pairs for
	 * each type:
	 *  First pair defines the parameters for A*x+B to calculate utility
	 *  from raw data when line voltage is >=220 and the second pair
	 *  is used otherwise.
	 */
	float         voltage[4];
};
