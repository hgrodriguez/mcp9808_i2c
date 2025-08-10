with AUnit.Assertions;

with MCP9808_I2C; use MCP9808_I2C;
with Configuration; use Configuration;

with Shared_Code;

package body Shutdown_Wakeup_Tests is

   --------------------------------------------------------------------------
   --  all tests implemented
   --------------------------------------------------------------------------
   procedure Test_POR
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Shutdown
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Wakeup
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   Status : Op_Status;

   overriding
   procedure Set_Up
     (T : in out Shutdown_Wakeup_Test)
   is
   begin
      Shared_Code.Initialize;
   end Set_Up;

   --------------------------------------------------------------------------
   overriding
   procedure Register_Tests
     (T : in out Shutdown_Wakeup_Test)
   is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_POR'Access,
                        "Shutdown_Wakeup POR");
      Register_Routine (T, Test_Shutdown'Access,
                        "Shutdown_Wakeup Test_Shutdown");
      Register_Routine (T, Test_Wakeup'Access,
                        "Shutdown_Wakeup Test_Wakeup");
   end Register_Tests;

   overriding
   function Name
     (T : Shutdown_Wakeup_Test)
      return AUnit.Message_String
   is (AUnit.Format ("Shutdown_Wakeup_Tests"));

   --------------------------------------------------------------------------
   procedure Test_POR
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      Flag : Boolean;

      use AUnit.Assertions;
   begin
      Flag := Is_Shutdown (This   => Temp_Sensor_Device,
                                    Status => Status);

      Assert (Flag = False, "Shutdown: POR /= False:" & Flag'Image);
   end Test_POR;

   --------------------------------------------------------------------------
   procedure Test_Shutdown
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      Flag : Boolean;

      use AUnit.Assertions;
   begin
      Shutdown (This   => Temp_Sensor_Device,
                Status => Status);

      Flag := Is_Shutdown (This   => Temp_Sensor_Device,
                           Status => Status);

      Assert (Flag, "Shutdown: On /= True:" & Flag'Image);
   end Test_Shutdown;

   --------------------------------------------------------------------------
   procedure Test_Wakeup
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      Flag : Boolean;

      use AUnit.Assertions;
   begin
      Wakeup (This   => Temp_Sensor_Device,
                Status => Status);

      Flag := Is_Awake (This   => Temp_Sensor_Device,
                           Status => Status);

      Assert (Flag, "Awake: On /= True:" & Flag'Image);
   end Test_Wakeup;

end Shutdown_Wakeup_Tests;
