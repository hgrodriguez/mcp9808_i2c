with AUnit.Assertions;

with MCP9808_I2C; use MCP9808_I2C;
with Configuration; use Configuration;

with Shared_Code;

package body Critical_Tests is
   Status : Op_Status;

   overriding
   procedure Set_Up
     (T : in out Critical_Test)
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
      Get_Critical_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => Temp);
      Assert (Temp = CRITICAL_POR, "Critical: POR /= 0:" & Temp'Image);
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
      Get_Critical_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => Temp_Prev);

      --  set new limit
      Set_Critical_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => CRITICAL_LIMIT);

      Get_Critical_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => Temp_Limit);

      --  make sure, that we are idempotent with the current setting
      --  set the previous temp again
      Set_Critical_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => Temp_Prev);

      Assert (Temp_Limit = CRITICAL_LIMIT,
              "Critical: Temp Limit Get="
              & Temp_Limit'Image
              & " /= Temp Limit Set="
              & CRITICAL_LIMIT'Image);
   end Test_Limit;

   overriding
   procedure Register_Tests
     (T : in out Critical_Test)
   is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_POR'Access, "Critical POR");
      Register_Routine (T, Test_Limit'Access, "Critical Limit");
   end Register_Tests;

   overriding
   function Name
     (T : Critical_Test)
      return AUnit.Message_String
   is (AUnit.Format ("Critical_Tests"));

end Critical_Tests;
