with AUnit.Assertions;

with MCP9808_I2C; use MCP9808_I2C;
with Configuration; use Configuration;

with Shared_Code;

package body Resolution_Tests is
   Status : Op_Status;

   overriding
   procedure Set_Up
     (T : in out Resolution_Test)
   is
   begin
      Shared_Code.Initialize;
   end Set_Up;

   procedure Test_POR
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      R : Resolution;

      use AUnit.Assertions;
   begin
      Get_Resolution (This   => Temp_Sensor_Device,
                      Status => Status,
                      Res   => R);
      Assert (R = RESOLUTION_POR, "Resolution: POR /= "
              & RESOLUTION_POR'Image
              & ":"
              & R'Image);
   end Test_POR;

   procedure Test_Half
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      RESOLUTION_VAL : constant Resolution := Half;
      R_Prev         : Resolution;
      R              : Resolution;

      use AUnit.Assertions;
   begin
      --  make sure, that we are idempotent with the current setting
      --  fetch the previous temp setting
      Get_Resolution (This   => Temp_Sensor_Device,
                      Status => Status,
                      Res => R_Prev);

      --  set new limit
      Set_Resolution (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Res => RESOLUTION_VAL);

      Get_Resolution (This   => Temp_Sensor_Device,
                      Status => Status,
                      Res => R);

      --  make sure, that we are idempotent with the current setting
      --  set the previous temp again
      Set_Resolution (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Res => R_Prev);

      Assert (R = RESOLUTION_VAL,
              "Resolution: Get="
              & R'Image
              & " /= Resolution Set="
              & RESOLUTION_VAL'Image);
   end Test_Half;

   procedure Test_Quarter
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      RESOLUTION_VAL : constant Resolution := Quarter;
      R_Prev         : Resolution;
      R              : Resolution;

      use AUnit.Assertions;
   begin
      --  make sure, that we are idempotent with the current setting
      --  fetch the previous temp setting
      Get_Resolution (This   => Temp_Sensor_Device,
                      Status => Status,
                      Res => R_Prev);

      --  set new limit
      Set_Resolution (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Res => RESOLUTION_VAL);

      Get_Resolution (This   => Temp_Sensor_Device,
                      Status => Status,
                      Res => R);

      --  make sure, that we are idempotent with the current setting
      --  set the previous temp again
      Set_Resolution (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Res => R_Prev);

      Assert (R = RESOLUTION_VAL,
              "Resolution: Get="
              & R'Image
              & " /= Resolution Set="
              & RESOLUTION_VAL'Image);
   end Test_Quarter;

   procedure Test_Eighth
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      RESOLUTION_VAL : constant Resolution := Eighth;
      R_Prev         : Resolution;
      R              : Resolution;

      use AUnit.Assertions;
   begin
      --  make sure, that we are idempotent with the current setting
      --  fetch the previous temp setting
      Get_Resolution (This   => Temp_Sensor_Device,
                      Status => Status,
                      Res => R_Prev);

      --  set new limit
      Set_Resolution (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Res => RESOLUTION_VAL);

      Get_Resolution (This   => Temp_Sensor_Device,
                      Status => Status,
                      Res => R);

      --  make sure, that we are idempotent with the current setting
      --  set the previous temp again
      Set_Resolution (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Res => R_Prev);

      Assert (R = RESOLUTION_VAL,
              "Resolution: Get="
              & R'Image
              & " /= Resolution Set="
              & RESOLUTION_VAL'Image);
   end Test_Eighth;

   procedure Test_Sixteenth
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      RESOLUTION_VAL : constant Resolution := Sixteenth;
      R_Prev         : Resolution;
      R              : Resolution;

      use AUnit.Assertions;
   begin
      --  make sure, that we are idempotent with the current setting
      --  fetch the previous temp setting
      Get_Resolution (This   => Temp_Sensor_Device,
                      Status => Status,
                      Res => R_Prev);

      --  set new limit
      Set_Resolution (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Res => RESOLUTION_VAL);

      Get_Resolution (This   => Temp_Sensor_Device,
                      Status => Status,
                      Res => R);

      --  make sure, that we are idempotent with the current setting
      --  set the previous temp again
      Set_Resolution (This       => Temp_Sensor_Device,
                      Status     => Status,
                      Res => R_Prev);

      Assert (R = RESOLUTION_VAL,
              "Resolution: Get="
              & R'Image
              & " /= Resolution Set="
              & RESOLUTION_VAL'Image);
   end Test_Sixteenth;

   overriding
   procedure Register_Tests
     (T : in out Resolution_Test)
   is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_POR'Access, "Resolution POR");
      Register_Routine (T, Test_Half'Access, "Resolution Half");
      Register_Routine (T, Test_Quarter'Access, "Resolution Quarter");
      Register_Routine (T, Test_Eighth'Access, "Resolution Eighth");
      Register_Routine (T, Test_Sixteenth'Access, "Resolution Sixteenth");
   end Register_Tests;

   overriding
   function Name
     (T : Resolution_Test)
      return AUnit.Message_String
   is (AUnit.Format ("Resolution_Tests"));

end Resolution_Tests;
