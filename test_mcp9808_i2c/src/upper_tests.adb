with AUnit.Assertions;

with MCP9808_I2C; use MCP9808_I2C;
with Configuration; use Configuration;

with Shared_Code;

package body Upper_Tests is

   --------------------------------------------------------------------------
   --  all tests implemented
   --------------------------------------------------------------------------
   procedure Test_POR
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Limit
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Limit_And_Lock
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   --  this needs to be tested in a very special way:
   --  this package can only be run on itself, and all other
   --  tests must be disabled/commented
   --  this test sets hardware flags, which are not mutable!
   pragma Warnings (Off, Test_Limit_And_Lock);

   Status : Op_Status;

   overriding
   procedure Set_Up
     (T : in out Upper_Test)
   is
   begin
      Shared_Code.Initialize;
   end Set_Up;

   --------------------------------------------------------------------------
   overriding
   procedure Register_Tests
     (T : in out Upper_Test)
   is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_POR'Access,
                        "Upper POR");
      Register_Routine (T, Test_Limit'Access,
                        "Upper Limit");
--        Register_Routine (T, Test_Limit_And_Lock'Access,
--                          "Upper Test_Limit_And_Lock");
   end Register_Tests;

   overriding
   function Name
     (T : Upper_Test)
      return AUnit.Message_String
   is (AUnit.Format ("Upper_Tests"));

   --------------------------------------------------------------------------
   procedure Test_POR
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      Temp : Celsius;

      use AUnit.Assertions;
   begin
      Get_Upper_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => Temp);
      Assert (Temp = UPPER_POR, "Upper: POR /= 0:" & Temp'Image);
   end Test_POR;

   --------------------------------------------------------------------------
   procedure Test_Limit
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      Temp_Prev : Celsius;
      Temp_Limit : Celsius;

      use AUnit.Assertions;
   begin
      --  make sure, that we are idempotent with the current setting
      --  fetch the previous temp setting
      Get_Upper_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => Temp_Prev);

      --  set new limit
      Set_Upper_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => UPPER_LIMIT);

      Get_Upper_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => Temp_Limit);

      --  make sure, that we are idempotent with the current setting
      --  set the previous temp again
      Set_Upper_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => Temp_Prev);

      Assert (Temp_Limit = UPPER_LIMIT,
              "Upper: Temp Limit Get="
              & Temp_Limit'Image
              & " /= Temp Limit Set="
              & UPPER_LIMIT'Image);
   end Test_Limit;

   --------------------------------------------------------------------------
   procedure Test_Limit_And_Lock
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp_Prev  : Celsius;
      Temp_Limit : Celsius;

      use AUnit.Assertions;
   begin
      --  set new limit
      Set_Upper_Temperature (This   => Temp_Sensor_Device,
                                Status => Status,
                                Temp   => LOWER_UPPER_LIMIT);

      Lock_Lower_Upper_Window (This   => Temp_Sensor_Device,
                                 Status => Status);

      --  try again and it should not change
      Set_Upper_Temperature (This   => Temp_Sensor_Device,
                                Status => Status,
                                Temp   => UPPER_LIMIT);

      Get_Upper_Temperature (This   => Temp_Sensor_Device,
                                Status => Status,
                                Temp   => Temp_Prev);

      Assert (Temp_Prev = LOWER_UPPER_LIMIT,
              "Upper.Test_Limit_And_Lock: Temp Limit Get="
              & Temp_Prev'Image
              & " /= Temp Limit Set="
              & LOWER_UPPER_LIMIT'Image);
   end Test_Limit_And_Lock;

end Upper_Tests;
