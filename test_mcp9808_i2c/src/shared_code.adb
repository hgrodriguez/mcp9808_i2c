with RP.Clock;
with RP.Device;
with RP.GPIO;
with RP.I2C_Master;

with Pico;

with MCP9808_I2C; use MCP9808_I2C;
with Configuration; use Configuration;

package body Shared_Code is

   procedure Initialize is
      Status : Op_Status;
   begin

      --  standard initialization
      RP.Clock.Initialize (Pico.XOSC_Frequency);
      RP.Clock.Enable (RP.Clock.PERI);
      RP.Device.Timer.Enable;
      RP.GPIO.Enable;

      --  configure the I2C port
      Temp_Sensor_CLK.Configure (Mode => RP.GPIO.Output,
                                 Pull => RP.GPIO.Pull_Up,
                                 Func => RP.GPIO.I2C);
      Temp_Sensor_SDA.Configure (Mode => RP.GPIO.Output,
                                 Pull => RP.GPIO.Pull_Up,
                                 Func => RP.GPIO.I2C);
      Temp_Sensor_Port.Configure (Baudrate => 400_000);

      MCP9808_I2C.Configure
        (This      => Temp_Sensor_Device,
         Port      => Temp_Sensor_Port'Unchecked_Access,
         Address   => I2C_DEFAULT_ADDRESS,
         --       Alert_Pin => Alert_Pin'Unchecked_Access,
         Status => Status);

   end Initialize;

end Shared_Code;
