with AUnit.Assertions;

with MCP9808_I2C; use MCP9808_I2C;
with Configuration; use Configuration;

with Shared_Code;

package body Lower_Tests is
   Status : Op_Status;

   overriding
   procedure Set_Up
     (T : in out Lower_Test)
   is
   begin
      Shared_Code.Initialize;
   end Set_Up;

   procedure Test_POR
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      Temp : Celsius;

      use AUnit.Assertions;
   begin
      Get_Lower_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => Temp);
      Assert (Temp = LOWER_POR, "Lower: POR /= 0:" & Temp'Image);
   end Test_POR;

   procedure Test_Limit
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      Temp_Prev  : Celsius;
      Temp_Limit : Celsius;

      use AUnit.Assertions;
   begin
      --  make sure, that we are idempotent with the current setting
      --  fetch the previous temp setting
      Get_Lower_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => Temp_Prev);

      --  set new limit
      Set_Lower_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => LOWER_LIMIT);

      Get_Lower_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => Temp_Limit);

      --  make sure, that we are idempotent with the current setting
      --  set the previous temp again
      Set_Lower_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => Temp_Prev);

      Assert (Temp_Limit = LOWER_LIMIT,
              "Lower: Temp Limit Get="
              & Temp_Limit'Image
              & " /= Temp Limit Set="
              & LOWER_LIMIT'Image);
   end Test_Limit;

   overriding
   procedure Register_Tests
     (T : in out Lower_Test)
   is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_POR'Access, "Lower POR");
      Register_Routine (T, Test_Limit'Access, "Lower Limit");
   end Register_Tests;

   overriding
   function Name
     (T : Lower_Test)
      return AUnit.Message_String
   is (AUnit.Format ("Lower_Tests"));

end Lower_Tests;
