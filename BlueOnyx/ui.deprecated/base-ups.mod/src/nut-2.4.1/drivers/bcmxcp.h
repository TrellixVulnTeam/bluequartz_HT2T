/* 
 * bcmxcp.h -- header for BCM/XCP module
 */ 

#ifndef _POWERWARE_H
#define _POWERWARE_H

#include "timehead.h"

#define PW_MAX_TRY 3 /* How many times we try to send data. */

#define PW_COMMAND_START_BYTE (unsigned char)0xAB

/* No	Autorisation required	*/ 
#define PW_ID_BLOCK_REQ 	(unsigned char)0x31 /* Model name, ... length 1 */
#define PW_STATUS_REQ 		(unsigned char)0x33 /* On Line, On Bypass, ...  length 1-2 */
#define PW_METER_BLOCK_REQ	(unsigned char)0x34 /* Current UPS status (Load, utility,...) length 1 */
#define PW_CUR_ALARM_REQ	(unsigned char)0x35 /* Current alarm and event request.	length 1 */
#define PW_CONFIG_BLOC_REQ	(unsigned char)0x36 /* Model serial#, ... length 1 */
#define PW_BAT_TEST_REQ		(unsigned char)0x3B /* Charging, floating, ... length 1 */
#define PW_LIMIT_BLOCK_REQ	(unsigned char)0x3C /* Configuration (Bypass thresholds,...).	length 1 */
#define PW_TEST_RESULT_REQ	(unsigned char)0x3F /* ??. length 1 */
#define PW_COMMAND_LIST_REQ	(unsigned char)0x40 /* ??. length 1 */
#define PW_OUT_MON_BLOCK_REQ	(unsigned char)0x41 /* Outlet monitor request length 1 */
#define PW_COM_CAP_REQ		(unsigned char)0x42 /* Request communication capabilities. length 2	*/
#define PW_UPS_TOP_DATA_REQ	(unsigned char)0x43 /* Requsest ups topology data requset. length 1	*/

/* Need autorisation before this commands */
#define PW_UPS_ON		(unsigned char)0x89 /* UPS on command. length 1-2 */
#define PW_LOAD_OFF_RESTART	(unsigned char)0x8A /* Delayed LoadPowerOff & Restart command. length 2-4 */
#define PW_UPS_OFF		(unsigned char)0x8B /* UPS off command. length 1-2 */
#define PW_UPS_ON_TIME		(unsigned char)0x91 /* Scheduled UPS on in n minutes. length 3-4 */
#define PW_UPS_OFF_TIME		(unsigned char)0x93 /* Scheduled UPS off in n minutes. length 3-4 */
#define PW_SET_CONF_COMMAND	(unsigned char)0x95 /* Set configuration command. length 4 */
#define PW_SET_OUTLET_COMMAND	(unsigned char)0x97 /* Set outlet parameter command length 5. not in 5115 */
#define PW_SET_COM_COMMAND	(unsigned char)0x98 /* Set communication parameter command. length 5 */
#define PW_SET_REQ_ONLY_MODE	(unsigned char)0xA0 /* Set request only mode command. length 1 */
#define PW_INIT_BAT_TEST	(unsigned char)0xB1 /* Initiate battery test command. length 3 */
#define PW_INIT_SYS_TEST	(unsigned char)0xB2 /* Initiate general system test command. length 2 */

/* Config block offsets */
#define BCMXCP_CONFIG_BLOCK_MACHINE_TYPE_CODE 		0
#define BCMXCP_CONFIG_BLOCK_MODEL_NUMBER	 	2
#define BCMXCP_CONFIG_BLOCK_MODEL_CONF_WORD 		4
#define BCMXCP_CONFIG_BLOCK_INPUT_FREQ_DEV_LIMIT 	6
#define BCMXCP_CONFIG_BLOCK_NOMINAL_OUTPUT_VOLTAGE 	8
#define BCMXCP_CONFIG_BLOCK_NOMINAL_OUTPUT_FREQ 	10
#define BCMXCP_CONFIG_BLOCK_OUTPUT_PHASE_ANGLE	 	12
#define BCMXCP_CONFIG_BLOCK_HW_MODULES_INSTALLED_WORD1 	14
#define BCMXCP_CONFIG_BLOCK_HW_MODULES_INSTALLED_BYTE3 	16 /* KEEP THIS UNTILL PARSING OK. USE THIS BYTE. */
#define BCMXCP_CONFIG_BLOCK_HW_MODULES_INSTALLED_WORD2 	16
#define BCMXCP_CONFIG_BLOCK_HW_MODULES_INSTALLED_WORD3 	18
#define BCMXCP_CONFIG_BLOCK_HW_MODULES_INSTALLED_WORD4 	20
#define BCMXCP_CONFIG_BLOCK_BATTERY_DATA_WORD1 		22 /* Undefined at this time.*/
#define BCMXCP_CONFIG_BLOCK_BATTERY_DATA_WORD2 		24 /* Per cell inverter shutdown voltage at full rated load. (volt/cell)* 100 */
#define BCMXCP_CONFIG_BLOCK_BATTERY_DATA_WORD3 		26 /* LOW BYTE Number of battery strings. HIGH BYTE undefined at this time.*/
#define BCMXCP_CONFIG_BLOCK_EXTENDED_BLOCK_LENGTH	47
#define BCMXCP_CONFIG_BLOCK_SERIAL_NUMBER		64

/* Index for Extende Limits block offsets */
#define BCMXCP_EXT_LIMITS_BLOCK_NOMINAL_INPUT_VOLTAGE	0
#define BCMXCP_EXT_LIMITS_BLOCK_NOMINAL_INPUT_FREQ	2
#define BCMXCP_EXT_LIMITS_BLOCK_NOMINAL_TRUE_POWER	4
#define BCMXCP_EXT_LIMITS_BLOCK_COMM_SPEC_VERSION	6
#define BCMXCP_EXT_LIMITS_BLOCK_FREQ_DEV_LIMIT		8
#define BCMXCP_EXT_LIMITS_BLOCK_VOLTAGE_LOW_DEV_LIMIT	10
#define BCMXCP_EXT_LIMITS_BLOCK_VOLTAGE_HIGE_DEV_LIMIT	12
#define BCMXCP_EXT_LIMITS_BLOCK_PHASE_DEV_LIMIT		14
#define BCMXCP_EXT_LIMITS_BLOCK_LOW_BATT_WARNING	16
#define BCMXCP_EXT_LIMITS_BLOCK_HORN_STATUS		17
#define BCMXCP_EXT_LIMITS_BLOCK_MIN_INPUT_VOLTAGE	18
#define BCMXCP_EXT_LIMITS_BLOCK_MAX_INPUT_VOLTAGE	20
#define BCMXCP_EXT_LIMITS_BLOCK_RETURN_STAB_DELAY	22
#define BCMXCP_EXT_LIMITS_BLOCK_BATT_CAPACITY_RETURN	24
#define BCMXCP_EXT_LIMITS_BLOCK_AMBIENT_TEMP_LOW	25
#define BCMXCP_EXT_LIMITS_BLOCK_AMBIENT_TEMP_HIGE	26

/* Meter map offsets used	*/
#define BCMXCP_METER_MAP_OUTPUT_VA			23
#define BCMXCP_METER_MAP_LOAD_CURR_PHASE_A		65
#define BCMXCP_METER_MAP_LOAD_CURR_PHASE_A_BAR_CHART	68
#define BCMXCP_METER_MAP_OUTPUT_VA_BAR_CHART		71

/* Indexes for alarm map */
#define BCMXCP_ALARM_INVERTER_AC_OVER_VOLTAGE		0
#define BCMXCP_ALARM_INVERTER_AC_UNDER_VOLTAGE		1
#define BCMXCP_ALARM_INVERTER_OVER_OR_UNDER_FREQ	2
#define BCMXCP_ALARM_BYPASS_AC_OVER_VOLTAGE		3
#define BCMXCP_ALARM_BYPASS_AC_UNDER_VOLTAGE		4
#define BCMXCP_ALARM_BYPASS_OVER_OR_UNDER_FREQ		5
#define BCMXCP_ALARM_INPUT_AC_OVER_VOLTAGE		6
#define BCMXCP_ALARM_INPUT_AC_UNDER_VOLTAGE		7
#define BCMXCP_ALARM_INPUT_UNDER_OR_OVER_FREQ		8
#define BCMXCP_ALARM_OUTPUT_OVER_VOLTAGE		9
#define BCMXCP_ALARM_OUTPUT_UNDER_VOLTAGE		10
#define BCMXCP_ALARM_OUTPUT_UNDER_OR_OVER_FREQ		11
#define BCMXCP_ALARM_REMOTE_EMERGENCY_PWR_OFF		12
#define BCMXCP_ALARM_REMOTE_GO_TO_BYPASS		13
#define BCMXCP_ALARM_BUILDING_ALARM_6			14
#define BCMXCP_ALARM_BUILDING_ALARM_5			15
#define BCMXCP_ALARM_BUILDING_ALARM_4			16
#define BCMXCP_ALARM_BUILDING_ALARM_3			17
#define BCMXCP_ALARM_BUILDING_ALARM_2			18
#define BCMXCP_ALARM_BUILDING_ALARM_1			19
#define BCMXCP_ALARM_STATIC_SWITCH_OVER_TEMP		20
#define BCMXCP_ALARM_CHARGER_OVER_TEMP			21
#define BCMXCP_ALARM_CHARGER_LOGIC_PWR_FAIL		22
#define BCMXCP_ALARM_CHARGER_OVER_VOLTAGE_OR_CURRENT	23
#define BCMXCP_ALARM_INVERTER_OVER_TEMP			24
#define BCMXCP_ALARM_OUTPUT_OVERLOAD			25
#define BCMXCP_ALARM_RECTIFIER_INPUT_OVER_CURRENT	26
#define BCMXCP_ALARM_INVERTER_OUTPUT_OVER_CURRENT	27
#define BCMXCP_ALARM_DC_LINK_OVER_VOLTAGE		28
#define BCMXCP_ALARM_DC_LINK_UNDER_VOLTAGE		29
#define BCMXCP_ALARM_RECTIFIER_FAILED			30
#define BCMXCP_ALARM_INVERTER_FAULT			31
#define BCMXCP_ALARM_BATTERY_CONNECTOR_FAIL		32
#define BCMXCP_ALARM_BYPASS_BREAKER_FAIL		33
#define BCMXCP_ALARM_CHARGER_FAIL			34
#define BCMXCP_ALARM_RAMP_UP_FAILED			35
#define BCMXCP_ALARM_STATIC_SWITCH_FAILED		36
#define BCMXCP_ALARM_ANALOG_AD_REF_FAIL			37
#define BCMXCP_ALARM_BYPASS_UNCALIBRATED		38
#define BCMXCP_ALARM_RECTIFIER_UNCALIBRATED		39
#define BCMXCP_ALARM_OUTPUT_UNCALIBRATED		40
#define BCMXCP_ALARM_INVERTER_UNCALIBRATED		41
#define BCMXCP_ALARM_DC_VOLT_UNCALIBRATED		42
#define BCMXCP_ALARM_OUTPUT_CURRENT_UNCALIBRATED	43
#define BCMXCP_ALARM_RECTIFIER_CURRENT_UNCALIBRATED	44
#define BCMXCP_ALARM_BATTERY_CURRENT_UNCALIBRATED	45
#define BCMXCP_ALARM_INVERTER_ON_OFF_STAT_FAIL		46
#define BCMXCP_ALARM_BATTERY_CURRENT_LIMIT		47
#define BCMXCP_ALARM_INVERTER_STARTUP_FAIL		48
#define BCMXCP_ALARM_ANALOG_BOARD_AD_STAT_FAIL		49
#define BCMXCP_ALARM_OUTPUT_CURRENT_OVER_100		50
#define BCMXCP_ALARM_BATTERY_GROUND_FAULT		51
#define BCMXCP_ALARM_WAITING_FOR_CHARGER_SYNC		52
#define BCMXCP_ALARM_NV_RAM_FAIL			53
#define BCMXCP_ALARM_ANALOG_BOARD_AD_TIMEOUT		54
#define BCMXCP_ALARM_SHUTDOWN_IMMINENT			55
#define BCMXCP_ALARM_BATTERY_LOW			56
#define BCMXCP_ALARM_UTILITY_FAIL			57
#define BCMXCP_ALARM_OUTPUT_SHORT_CIRCUIT		58
#define BCMXCP_ALARM_UTILITY_NOT_PRESENT		59
#define BCMXCP_ALARM_FULL_TIME_CHARGING			60
#define BCMXCP_ALARM_FAST_BYPASS_COMMAND		61
#define BCMXCP_ALARM_AD_ERROR				62
#define BCMXCP_ALARM_INTERNAL_COM_FAIL			63
#define BCMXCP_ALARM_RECTIFIER_SELFTEST_FAIL		64
#define BCMXCP_ALARM_RECTIFIER_EEPROM_FAIL		65
#define BCMXCP_ALARM_RECTIFIER_EPROM_FAIL		66
#define BCMXCP_ALARM_INPUT_LINE_VOLTAGE_LOSS		67
#define BCMXCP_ALARM_BATTERY_DC_OVER_VOLTAGE		68
#define BCMXCP_ALARM_POWER_SUPPLY_OVER_TEMP		69
#define BCMXCP_ALARM_POWER_SUPPLY_FAIL			70
#define BCMXCP_ALARM_POWER_SUPPLY_5V_FAIL		71
#define BCMXCP_ALARM_POWER_SUPPLY_12V_FAIL		72
#define BCMXCP_ALARM_HEATSINK_OVER_TEMP			73
#define BCMXCP_ALARM_HEATSINK_TEMP_SENSOR_FAIL		74
#define BCMXCP_ALARM_RECTIFIER_CURRENT_OVER_125		75
#define BCMXCP_ALARM_RECTIFIER_FAULT_INTERRUPT_FAIL	76
#define BCMXCP_ALARM_RECTIFIER_POWER_CAPASITOR_FAIL	77
#define BCMXCP_ALARM_INVERTER_PROGRAM_STACK_ERROR	78
#define BCMXCP_ALARM_INVERTER_BOARD_SELFTEST_FAIL	79
#define BCMXCP_ALARM_INVERTER_AD_SELFTEST_FAIL		80
#define BCMXCP_ALARM_INVERTER_RAM_SELFTEST_FAIL		81
#define BCMXCP_ALARM_NV_MEMORY_CHECKSUM_FAIL		82
#define BCMXCP_ALARM_PROGRAM_CHECKSUM_FAIL		83
#define BCMXCP_ALARM_INVERTER_CPU_SELFTEST_FAIL		84
#define BCMXCP_ALARM_NETWORK_NOT_RESPONDING		85
#define BCMXCP_ALARM_FRONT_PANEL_SELFTEST_FAIL		86
#define BCMXCP_ALARM_NODE_EEPROM_VERIFICATION_ERROR	87
#define BCMXCP_ALARM_OUTPUT_AC_OVER_VOLT_TEST_FAIL	88
#define BCMXCP_ALARM_OUTPUT_DC_OVER_VOLTAGE		89
#define BCMXCP_ALARM_INPUT_PHASE_ROTATION_ERROR		90
#define BCMXCP_ALARM_INVERTER_RAMP_UP_TEST_FAILED	91
#define BCMXCP_ALARM_INVERTER_OFF_COMMAND		92
#define BCMXCP_ALARM_INVERTER_ON_COMMAND		93
#define BCMXCP_ALARM_TO_BYPASS_COMMAND			94
#define BCMXCP_ALARM_FROM_BYPASS_COMMAND		95
#define BCMXCP_ALARM_AUTO_MODE_COMMAND			96
#define BCMXCP_ALARM_EMERGENCY_SHUTDOWN_COMMAND		97
#define BCMXCP_ALARM_SETUP_SWITCH_OPEN			98
#define BCMXCP_ALARM_INVERTER_OVER_VOLT_INT		99
#define BCMXCP_ALARM_INVERTER_UNDER_VOLT_INT		100
#define BCMXCP_ALARM_ABSOLUTE_DCOV_ACOV			101
#define BCMXCP_ALARM_PHASE_A_CURRENT_LIMIT		102
#define BCMXCP_ALARM_PHASE_B_CURRENT_LIMIT		103
#define BCMXCP_ALARM_PHASE_C_CURRENT_LIMIT		104
#define BCMXCP_ALARM_BYPASS_NOT_AVAILABLE		105
#define BCMXCP_ALARM_RECTIFIER_BREAKER_OPEN		106
#define BCMXCP_ALARM_BATTERY_CONTACTOR_OPEN		107
#define BCMXCP_ALARM_INVERTER_CONTACTOR_OPEN		108
#define BCMXCP_ALARM_BYPASS_BREAKER_OPEN		109
#define BCMXCP_ALARM_INV_BOARD_ACOV_INT_TEST_FAIL	110
#define BCMXCP_ALARM_INVERTER_OVER_TEMP_TRIP		111
#define BCMXCP_ALARM_INV_BOARD_ACUV_INT_TEST_FAIL	112
#define BCMXCP_ALARM_INVERTER_VOLTAGE_FEEDBACK_ERROR	113
#define BCMXCP_ALARM_DC_UNDER_VOLTAGE_TIMEOUT		114
#define BCMXCP_ALARM_AC_UNDER_VOLTAGE_TIMEOUT		115
#define BCMXCP_ALARM_DC_UNDER_VOLTAGE_WHILE_CHARGE	116
#define BCMXCP_ALARM_INVERTER_VOLTAGE_BIAS_ERROR	117
#define BCMXCP_ALARM_RECTIFIER_PHASE_ROTATION		118
#define BCMXCP_ALARM_BYPASS_PHASER_ROTATION		119
#define BCMXCP_ALARM_SYSTEM_INTERFACE_BOARD_FAIL	120
#define BCMXCP_ALARM_PARALLEL_BOARD_FAIL		121
#define BCMXCP_ALARM_LOST_LOAD_SHARING_PHASE_A		122
#define BCMXCP_ALARM_LOST_LOAD_SHARING_PHASE_B		123
#define BCMXCP_ALARM_LOST_LOAD_SHARING_PHASE_C		124
#define BCMXCP_ALARM_DC_OVER_VOLTAGE_TIMEOUT		125
#define BCMXCP_ALARM_BATTERY_TOTALLY_DISCHARGED		126
#define BCMXCP_ALARM_INVERTER_PHASE_BIAS_ERROR		127
#define BCMXCP_ALARM_INVERTER_VOLTAGE_BIAS_ERROR_2	128
#define BCMXCP_ALARM_DC_LINK_BLEED_COMPLETE		129
#define BCMXCP_ALARM_LARGE_CHARGER_INPUT_CURRENT	130
#define BCMXCP_ALARM_INV_VOLT_TOO_LOW_FOR_RAMP_LEVEL	131
#define BCMXCP_ALARM_LOSS_OF_REDUNDANCY			132
#define BCMXCP_ALARM_LOSS_OF_SYNC_BUS			133 
#define BCMXCP_ALARM_RECTIFIER_BREAKER_SHUNT_TRIP	134
#define BCMXCP_ALARM_LOSS_OF_CHARGER_SYNC		135
#define BCMXCP_ALARM_INVERTER_LOW_LEVEL_TEST_TIMEOUT	136
#define BCMXCP_ALARM_OUTPUT_BREAKER_OPEN		137
#define BCMXCP_ALARM_CONTROL_POWER_ON			138
#define BCMXCP_ALARM_INVERTER_ON			139
#define BCMXCP_ALARM_CHARGER_ON				140
#define BCMXCP_ALARM_BYPASS_ON				141
#define BCMXCP_ALARM_BYPASS_POWER_LOSS			142
#define BCMXCP_ALARM_ON_MANUAL_BYPASS			143
#define BCMXCP_ALARM_BYPASS_MANUAL_TURN_OFF		144
#define BCMXCP_ALARM_INVERTER_BLEEDING_DC_LINK_VOLT	145
#define BCMXCP_ALARM_CPU_ISR_ERROR			146
#define BCMXCP_ALARM_SYSTEM_ISR_RESTART			147
#define BCMXCP_ALARM_PARALLEL_DC			148
#define BCMXCP_ALARM_BATTERY_NEEDS_SERVICE		149
#define BCMXCP_ALARM_BATTERY_CHARGING			150
#define BCMXCP_ALARM_BATTERY_NOT_CHARGED		151
#define BCMXCP_ALARM_DISABLED_BATTERY_TIME		152
#define BCMXCP_ALARM_SERIES_7000_ENABLE			153
#define BCMXCP_ALARM_OTHER_UPS_ON			154
#define BCMXCP_ALARM_PARALLEL_INVERTER			155
#define BCMXCP_ALARM_UPS_IN_PARALLEL			156
#define BCMXCP_ALARM_OUTPUT_BREAKER_REALY_FAIL		157
#define BCMXCP_ALARM_CONTROL_POWER_OFF			158
#define BCMXCP_ALARM_LEVEL_2_OVERLOAD_PHASE_A		159
#define BCMXCP_ALARM_LEVEL_2_OVERLOAD_PHASE_B		160
#define BCMXCP_ALARM_LEVEL_2_OVERLOAD_PHASE_C		161
#define BCMXCP_ALARM_LEVEL_3_OVERLOAD_PHASE_A		162
#define BCMXCP_ALARM_LEVEL_3_OVERLOAD_PHASE_B		163
#define BCMXCP_ALARM_LEVEL_3_OVERLOAD_PHASE_C		164
#define BCMXCP_ALARM_LEVEL_4_OVERLOAD_PHASE_A		165
#define BCMXCP_ALARM_LEVEL_4_OVERLOAD_PHASE_B		166
#define BCMXCP_ALARM_LEVEL_4_OVERLOAD_PHASE_C		167
#define BCMXCP_ALARM_UPS_ON_BATTERY			168
#define BCMXCP_ALARM_UPS_ON_BYPASS			169
#define BCMXCP_ALARM_LOAD_DUMPED			170
#define BCMXCP_ALARM_LOAD_ON_INVERTER			171
#define BCMXCP_ALARM_UPS_ON_COMMAND			172
#define BCMXCP_ALARM_UPS_OFF_COMMAND			173
#define BCMXCP_ALARM_LOW_BATTERY_SHUTDOWN		174
#define BCMXCP_ALARM_AUTO_ON_ENABLED			175
#define BCMXCP_ALARM_SOFTWARE_INCOMPABILITY_DETECTED	176
#define BCMXCP_ALARM_INVERTER_TEMP_SENSOR_FAILED	177
#define BCMXCP_ALARM_DC_START_OCCURED			178
#define BCMXCP_ALARM_IN_PARALLEL_OPERATION		179
#define BCMXCP_ALARM_SYNCING_TO_BYPASS			180
#define BCMXCP_ALARM_RAMPING_UPS_UP			181
#define BCMXCP_ALARM_INVERTER_ON_DELAY			182
#define BCMXCP_ALARM_CHARGER_ON_DELAY			183
#define BCMXCP_ALARM_WAITING_FOR_UTIL_INPUT		184
#define BCMXCP_ALARM_CLOSE_BYPASS_BREAKER		185
#define BCMXCP_ALARM_TEMPORARY_BYPASS_OPERATION		186
#define BCMXCP_ALARM_SYNCING_TO_OUTPUT			187
#define BCMXCP_ALARM_BYPASS_FAILURE			188
#define BCMXCP_ALARM_AUTO_OFF_COMMAND_EXECUTED		189
#define BCMXCP_ALARM_AUTO_ON_COMMAND_EXECUTED		190
#define BCMXCP_ALARM_BATTERY_TEST_FAILED		191
#define BCMXCP_ALARM_FUSE_FAIL				192
#define BCMXCP_ALARM_FAN_FAIL				193
#define BCMXCP_ALARM_SITE_WIRING_FAULT			194
#define BCMXCP_ALARM_BACKFEED_CONTACTOR_FAIL		195
#define BCMXCP_ALARM_ON_BUCK				196
#define BCMXCP_ALARM_ON_BOOST				197
#define BCMXCP_ALARM_ON_DOUBLE_BOOST			198
#define BCMXCP_ALARM_BATTERIES_DISCONNECTED		199
#define BCMXCP_ALARM_UPS_CABINET_OVER_TEMP		200
#define BCMXCP_ALARM_TRANSFORMER_OVER_TEMP		201
#define BCMXCP_ALARM_AMBIENT_UNDER_TEMP			202
#define BCMXCP_ALARM_AMBIENT_OVER_TEMP			203
#define BCMXCP_ALARM_CABINET_DOOR_OPEN			204
#define BCMXCP_ALARM_CABINET_DOOR_OPEN_VOLT_PRESENT	205
#define BCMXCP_ALARM_AUTO_SHUTDOWN_PENDING		206
#define BCMXCP_ALARM_TAP_SWITCHING_REALY_PENDING	207
#define BCMXCP_ALARM_UNABLE_TO_CHARGE_BATTERIES		208
#define BCMXCP_ALARM_STARTUP_FAILURE_CHECK_EPO		209
#define BCMXCP_ALARM_AUTOMATIC_STARTUP_PENDING		210
#define BCMXCP_ALARM_MODEM_FAILED			211
#define BCMXCP_ALARM_INCOMING_MODEM_CALL_STARTED	212
#define BCMXCP_ALARM_OUTGOING_MODEM_CALL_STARTED	213
#define BCMXCP_ALARM_MODEM_CONNECTION_ESTABLISHED	214
#define BCMXCP_ALARM_MODEM_CALL_COMPLETED_SUCCESS	215
#define BCMXCP_ALARM_MODEM_CALL_COMPLETED_FAIL		216
#define BCMXCP_ALARM_INPUT_BREAKER_FAIL			217
#define BCMXCP_ALARM_SYSINIT_IN_PROGRESS		218
#define BCMXCP_ALARM_AUTOCALIBRATION_FAIL		219
#define BCMXCP_ALARM_SELECTIVE_TRIP_OF_MODULE		220
#define BCMXCP_ALARM_INVERTER_OUTPUT_FAILURE		221
#define BCMXCP_ALARM_ABNORMAL_OUTPUT_VOLT_AT_STARTUP	222
#define BCMXCP_ALARM_RECTIFIER_OVER_TEMP		223
#define BCMXCP_ALARM_CONFIG_ERROR			224
#define BCMXCP_ALARM_REDUNDANCY_LOSS_DUE_TO_OVERLOAD	225
#define BCMXCP_ALARM_ON_ALTERNATE_AC_SOURCE		226

#define BCMXCP_METER_MAP_MAX 91 /* Max no of entries in BCM/XCP meter map */
#define	BCMXCP_ALARM_MAP_MAX 232 /* Max no of entries in BCM/XCP alarm map (adjusted upwards to nearest multi of 8 */

typedef struct { /* Entry in BCM/XCP - UPS - NUT mapping table */
	char *nut_entity;				/* The NUT variable name */
	unsigned char format;				/* The format of the data - float, long etc */
	unsigned int meter_block_index;			/* The position of this meter in the UPS meter block */
}	BCMXCP_METER_MAP_ENTRY_t;

BCMXCP_METER_MAP_ENTRY_t
	bcmxcp_meter_map[BCMXCP_METER_MAP_MAX];

typedef	struct { /* Entry in BCM/XCP - UPS mapping table */
	int alarm_block_index;			/* Index of this alarm in alarm block. -1 = not existing */
	char *alarm_desc;			/* Description of this alarm */
}	BCMXCP_ALARM_MAP_ENTRY_t;

BCMXCP_ALARM_MAP_ENTRY_t
	bcmxcp_alarm_map[BCMXCP_ALARM_MAP_MAX];

typedef	struct {				/* A place to store status info and other data not for NUT */
	unsigned char topology_mask;	 	/* Configuration block byte 16, masks valid status bits */
	unsigned int lowbatt;			/* Seconds of runtime left left when LB alarm is set */
	unsigned int shutdowndelay;	 	/* Shutdown delay in seconds, from ups.conf */
	int alarm_on_battery;			/* On Battery alarm active? */
	int alarm_low_battery;			/* Battery Low alarm active? */
}	BCMXCP_STATUS_t;

BCMXCP_STATUS_t
	bcmxcp_status;

int checksum_test(const unsigned char*);
unsigned char calc_checksum(const unsigned char *buf);
	
#endif /*_POWERWARE_H */

