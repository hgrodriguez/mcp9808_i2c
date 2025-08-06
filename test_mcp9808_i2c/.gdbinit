file bin/test_mcp9808_i2c
target extended-remote localhost:3333
monitor arm semihosting enable
set remotetimeout 5000
load
break Test_Mcp9808_I2c

