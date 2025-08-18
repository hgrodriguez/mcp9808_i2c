with AUnit.Assertions;

with MCP9808_I2C; use MCP9808_I2C;
with Configuration; use Configuration;

with Shared_Code;

package body Hysteresis_Tests is

   --------------------------------------------------------------------------
   --  all tests implemented
   --------------------------------------------------------------------------
   procedure Test_POR
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Zero
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_One_Half
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Three
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Six
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   Status : Op_Status;

   --------------------------------------------------------------------------
   overriding
   procedure Set_Up
     (T : in out Hysteresis_Test)
   is
   begin
      Shared_Code.Initialize;
   end Set_Up;

   --------------------------------------------------------------------------
   overriding
   procedure Register_Tests
     (T : in out Hysteresis_Test)
   is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_POR'Access, "Hysteresis POR");
      Register_Routine (T, Test_Zero'Access, "Hysteresis Test_Zero");
      Register_Routine (T, Test_One_Half'Access, "Hysteresis Test_One_Half");
      Register_Routine (T, Test_Three'Access, "Hysteresis Test_Three");
      Register_Routine (T, Test_Six'Access, "Hysteresis Test_Six");
   end Register_Tests;

   --------------------------------------------------------------------------
   overriding
   function Name
     (T : Hysteresis_Test)
      return AUnit.Message_String
   is (AUnit.Format ("Hysteresis_Tests"));

   --------------------------------------------------------------------------
   procedure Test_POR
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      H : Hysteresis;

      use AUnit.Assertions;
   begin
      Get_Hysteresis (This   => Temp_Sensor_Device,
                             Status => Status,
                             Hyst   => H);
      Assert (H = Zero, "Hysteresis: POR /= 0:" & H'Image);
   end Test_POR;

   --------------------------------------------------------------------------
   procedure Test_Zero
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      H_VAL : constant Hysteresis := Zero;
      H_Prev         : Hysteresis;
      H              : Hysteresis;

      use AUnit.Assertions;
   begin
      --  make sure, that we are idempotent with the current setting
      --  fetch the previous hysteresis setting
      Get_Hysteresis (This   => Temp_Sensor_Device,
                      Status => Status,
                      Hyst => H_Prev);

      --  set new hysteresis
      Set_Hysteresis (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Hyst => H_VAL);

      Get_Hysteresis (This   => Temp_Sensor_Device,
                      Status => Status,
                      Hyst => H);

      --  make sure, that we are idempotent with the current setting
      --  set the previous hysteresis again
      Set_Hysteresis (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Hyst => H_Prev);

      Assert (H = H_VAL,
              "Hysteresis: Get="
              & H'Image
              & " /= Hysteresis Set="
              & H_VAL'Image
             );
   end Test_Zero;

   --------------------------------------------------------------------------
   procedure Test_One_Half
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      H_VAL          : constant Hysteresis := One_Half;
      H_Prev         : Hysteresis;
      H              : Hysteresis;

      use AUnit.Assertions;
   begin
      --  make sure, that we are idempotent with the current setting
      --  fetch the previous hysteresis setting
      Get_Hysteresis (This   => Temp_Sensor_Device,
                      Status => Status,
                      Hyst => H_Prev);

      --  set new hysteresis
      Set_Hysteresis (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Hyst => H_VAL);

      Get_Hysteresis (This   => Temp_Sensor_Device,
                      Status => Status,
                      Hyst => H);

      --  make sure, that we are idempotent with the current setting
      --  set the previous hysteresis again
      Set_Hysteresis (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Hyst => H_Prev);

      Assert (H = H_VAL,
              "Hysteresis: Get="
              & H'Image
              & " /= Hysteresis Set="
              & H_VAL'Image
             );
   end Test_One_Half;

   --------------------------------------------------------------------------
   procedure Test_Three
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      H_VAL          : constant Hysteresis := Three;
      H_Prev         : Hysteresis;
      H              : Hysteresis;

      use AUnit.Assertions;
   begin
      --  make sure, that we are idempotent with the current setting
      --  fetch the previous hysteresis setting
      Get_Hysteresis (This   => Temp_Sensor_Device,
                      Status => Status,
                      Hyst => H_Prev);

      --  set new hysteresis
      Set_Hysteresis (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Hyst => H_VAL);

      Get_Hysteresis (This   => Temp_Sensor_Device,
                      Status => Status,
                      Hyst => H);

      --  make sure, that we are idempotent with the current setting
      --  set the previous hysteresis again
      Set_Hysteresis (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Hyst => H_Prev);

      Assert (H = H_VAL,
              "Hysteresis: Get="
              & H'Image
              & " /= Hysteresis Set="
              & H_VAL'Image
             );
   end Test_Three;

   --------------------------------------------------------------------------
   procedure Test_Six
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      H_VAL          : constant Hysteresis := Six;
      H_Prev         : Hysteresis;
      H              : Hysteresis;

      use AUnit.Assertions;
   begin
      --  make sure, that we are idempotent with the current setting
      --  fetch the previous hysteresis setting
      Get_Hysteresis (This   => Temp_Sensor_Device,
                      Status => Status,
                      Hyst => H_Prev);

      --  set new hysteresis
      Set_Hysteresis (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Hyst => H_VAL);

      Get_Hysteresis (This   => Temp_Sensor_Device,
                      Status => Status,
                      Hyst => H);

      --  make sure, that we are idempotent with the current setting
      --  set the previous hysteresis again
      Set_Hysteresis (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Hyst => H_Prev);

      Assert (H = H_VAL,
              "Hysteresis: Get="
              & H'Image
              & " /= Hysteresis Set="
              & H_VAL'Image
             );
   end Test_Six;

end Hysteresis_Tests;
