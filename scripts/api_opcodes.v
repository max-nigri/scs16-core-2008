//-----------------------------------------------------------
//	 API Opcodes
//-----------------------------------------------------------

// OpCodes for read commands (from HW)
`define OPCODE_STEREO_GET				0
`define OPCODE_RSSI_LVL_GET				1
`define OPCODE_IF_COUNT_GET				2
`define OPCODE_FLAG_GET					3
`define OPCODE_RDS_SYNC_GET				4
`define OPDODE_RDS_DATA_GET				5


// OpCodes for read/write commands
`define OPCODE_FREQ_SET_GET				10
`define MIN_READ_OPCODE					`OPCODE_FREQ_SET_GET
`define MIN_WRITE_OPCODE				`OPCODE_FREQ_SET_GET
`define OPDODE_AF_FREQ_SET_GET			11
`define OPDODE_MOST_MODE_SET_GET		12
`define OPDODE_MOST_BLEND_SET_GET		13
`define OPDODE_DEMPH_MODE_SET_GET		14
`define OPDODE_SEARCH_LVL_SET_GET		15
`define OPDODE_BAND_SET_GET				16
`define OPDODE_MUTE_STATUS_SET_GET		17
`define OPDODE_RDS_PAUSE_LVL_SET_GET	18
`define OPDODE_RDS_PAUSE_DUR_SET_GET	19
`define OPDODE_RDS_MEM_SET_GET			20
`define OPDODE_RDS_BLK_B_SET_GET		21
`define OPDODE_RDS_MSK_B_SET_GET		22
`define OPDODE_RDS_PI_MASK_SET_GET		23
`define OPDODE_RDS_PI_SET_GET			24
`define OPDODE_RDS_SYSTEM_SET_GET		25
`define OPDODE_INT_MASK_SET_GET			26
`define OPDODE_SEARCH_DIR_SET_GET		27
`define MAX_WRITE_OPCODE				`OPDODE_SEARCH_DIR_SET_GET

// OpCodes for read commands (from HW)
`define OPCODE_FIRM_VER_GET				28
`define OPCODE_ASIC_VER_GET				29
`define OPCODE_ASIC_ID_GET				30
`define OPCODE_MAN_ID_GET				31
`define MAX_READ_OPCODE					`OPCODE_MAN_ID_GET


// OpCodes for write commands
`define OPDODE_TUNER_MODE_SET			35
`define OPDODE_STOP_SEARCH				36
`define OPDODE_POWER_SET				37

`define OPDODE_HW_REGISTER_SET_GET		100
`define OPDODE_CODE_DOWNLOAD			101
`define OPDODE_RESET					102
`define OPDODE_

// parameters of OPDODE_BAND_SET_GET
`define BAND_SET_EUROPE_US				0
`define BAND_SET_JAPAN					1
`define BAND_LIMIT_EUROPE_US_LOW		16'h1234
`define BAND_LIMIT_EUROPE_US_HIGH		16'hc000
`define BAND_LIMIT_JAPAN_LOW			16'h0000
`define BAND_LIMIT_JAPAN_HIGH			16'h9150
