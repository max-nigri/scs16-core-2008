//-----------------------------------------------------------
//	 MCU inputs and outputs
//-----------------------------------------------------------



// condition lines assignment
`define CONDITION_RSSI_LOW				c0
`define CONDITION_RSSI_RDY				c1
`define CONDITION_IF_COUNT_RDY			c2
`define CONDITION_RDS_RDY				c3
`define CONDITION_B_MATCH				c4
`define CONDITION_PI_MATCH				c5
`define CONDITION_SYNC_LOST				c6
`define CONDITION_PILOT_DETECT			c7
`define CONDITION_AUD_PAUSE_DETECT		c8
`define CONDITION_SYNTH_LOCK			c9
`define CONDITION_I2C_IRQ				c10
`define CONDITION_I2C_TX				c11
`define CONDITION_I2C_RX				c12
`define CONDITION_FAST_TIMER			c13
`define CONDITION_SLOW_TIMER			c14


// pulse lines assignment
`define PULSE_FAST_TIMER_LOAD			0
`define PULSE_SLOW_TIMER_LOAD			1
`define PULSE_SET_IRQ_MASK				2
`define PULSE_CLR_IRQ					3
`define PULSE_GENERAL_0					4
`define PULSE_GENERAL_1					5
`define PULSE_GENERAL_2					6
`define PULSE_GENERAL_3					7
`define PULSE_SLEEP						14


// device lines assignment
`define DEVICE_GPIO_0					0
`define DEVICE_GPIO_1					1
`define DEVICE_GPIO_2					2
`define DEVICE_GPIO_3					3
`define DEVICE_AWAKE					13
`define DEVICE_INTX						14
`define DEVICE_IMEM_CS					15