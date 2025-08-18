with RP.Clock;
with RP.Device;
with RP.GPIO;
with RP.I2C_Master;

with Pico;

with MCP9808_I2C; use MCP9808_I2C;
with Configuration; use Configuration;

package body Shared_Code is

   Status : Op_Status;

   --------------------------------------------------------------------------
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
         Status => Status);

      RP.GPIO.Configure (This      => Alert_Pin,
                         Mode      => RP.GPIO.Input,
                         Pull      => RP.GPIO.Pull_Up,
                         Func      => RP.GPIO.SIO);
   end Initialize;

   --------------------------------------------------------------------------
   procedure Set_No_Alert_Limits is
   begin
      Set_Critical_Temperature (This   => Temp_Sensor_Device,
                                Status => Status,
                                Temp   => NO_ALERT_CRITICAL_HIGH);
      Set_Upper_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => NO_ALERT_T_HIGHER);
      Set_Lower_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => NO_ALERT_T_LOWER);
   end Set_No_Alert_Limits;

   --------------------------------------------------------------------------
   procedure Set_Limits_Back_to_POR is
   begin
      --  back to POR to not disturb any other tests
      Set_Critical_Temperature (This   => Temp_Sensor_Device,
                                Status => Status,
                                Temp   => POR_ALERT_CRITICAL_HIGH);
      Set_Upper_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => POR_ALERT_T_HIGHER);
      Set_Lower_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => POR_ALERT_T_LOWER);
   end Set_Limits_Back_to_POR;

end Shared_Code;
