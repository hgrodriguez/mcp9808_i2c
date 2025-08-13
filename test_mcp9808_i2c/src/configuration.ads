with RP.Device;
with RP.GPIO;
with RP.I2C_Master;

with Pico;

with MCP9808_I2C; use MCP9808_I2C;

package Configuration is

   CRITICAL_POR   : constant Celsius := Celsius (0);
   CRITICAL_LIMIT : constant Celsius := Celsius (225);
   LOWER_CRITICAL_LIMIT : constant Celsius := CRITICAL_LIMIT / 2;

   LOWER_POR   : constant Celsius := Celsius (0);
   LOWER_LIMIT : constant Celsius := Celsius (-25.5);
   UPPER_LOWER_LIMIT          : constant Celsius := LOWER_LIMIT / 2;

   UPPER_POR   : constant Celsius := Celsius (0);
   UPPER_LIMIT : constant Celsius := Celsius (175);
   LOWER_UPPER_LIMIT : constant Celsius := UPPER_LIMIT / 2;

   Temp_Sensor_CLK : RP.GPIO.GPIO_Point := Pico.GP15;
   Temp_Sensor_SDA : RP.GPIO.GPIO_Point := Pico.GP14;

   Temp_Sensor_Device : MCP9808_I2C_Port;
   Temp_Sensor_Port   : aliased RP.I2C_Master.I2C_Master_Port
     := RP.Device.I2CM_1;

   RESOLUTION_POR : constant Resolution := Sixteenth;

   Alert_Pin : RP.GPIO.GPIO_Point renames Pico.GP6;
end Configuration;
