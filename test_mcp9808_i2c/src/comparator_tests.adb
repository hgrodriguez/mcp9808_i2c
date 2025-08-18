with AUnit.Assertions;

with MCP9808_I2C; use MCP9808_I2C;
with Configuration; use Configuration;

with Shared_Code;

package body Comparator_Tests is

   --------------------------------------------------------------------------
   --  all tests implemented
   --------------------------------------------------------------------------
   procedure Test_POR
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   --
   procedure Test_No_Alert
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_TA_Too_Low
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_TA_Too_High
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_TA_Above_Critical
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   --
   procedure Test_CriticalOnly_TA_Above_Lower
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_CriticalOnly_TA_Above_Higher
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_CriticalOnly_TA_Above_Critical
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   Status : Op_Status;

   --------------------------------------------------------------------------
   overriding
   procedure Set_Up
     (T : in out Comparator_Test)
   is
   begin
      Shared_Code.Initialize;
      --  make sure the limits do not create any noise
      Shared_Code.Set_No_Alert_Limits;

      --  enable output of alert
      Enable_Alert_Output (This   => Temp_Sensor_Device,
                           Status => Status);
   end Set_Up;

   --------------------------------------------------------------------------
   overriding
   procedure Tear_Down
     (T : in out Comparator_Test) is
   begin
      Shared_Code.Set_Limits_Back_to_POR;
      Disable_Alert_Output (This   => Temp_Sensor_Device,
                           Status => Status);
   end Tear_Down;

   --------------------------------------------------------------------------
   overriding
   procedure Register_Tests
     (T : in out Comparator_Test)
   is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_POR'Access,
                        "Comparator POR");
      Register_Routine (T, Test_No_Alert'Access,
                        "Comparator No_Alert");
      Register_Routine (T, Test_TA_Too_Low'Access,
                        "Comparator Test_TA_Too_Low");
      Register_Routine (T, Test_TA_Too_High'Access,
                        "Comparator Test_TA_Too_High");
      Register_Routine (T, Test_TA_Above_Critical'Access,
                        "Comparator Test_TA_Above_Critical");
      Register_Routine (T, Test_CriticalOnly_TA_Above_Lower'Access,
                        "Comparator Test_CriticalOnly_TA_Above_Lower");
      Register_Routine (T, Test_CriticalOnly_TA_Above_Higher'Access,
                        "Comparator Test_CriticalOnly_TA_Above_Higher");
      Register_Routine (T, Test_CriticalOnly_TA_Above_Critical'Access,
                        "Comparator Test_CriticalOnly_TA_Above_Critical");
   end Register_Tests;

   --------------------------------------------------------------------------
   overriding
   function Name
     (T : Comparator_Test)
      return AUnit.Message_String
   is (AUnit.Format ("Comparator_Test"));

   --------------------------------------------------------------------------
   procedure Test_POR
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      Temp : Celsius;

      use AUnit.Assertions;
   begin
      Assert (Is_Alert_Comparator (This   => Temp_Sensor_Device,
                                   Status => Status),
              "Comparator: POR /= True");
   end Test_POR;

   --------------------------------------------------------------------------
   --     type Alert_Output_Select is (All_Limits)
   --        T_CRITICAL > T_HIGHER > __TA__ > T_LOWER -> high
   procedure Test_No_Alert
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      Temp : Celsius;
      A_Status : Ambient_Status;

      use AUnit.Assertions;
   begin
      Get_Ambient_Temperature (This   => Temp_Sensor_Device,
                               Status => Status,
                               A_Status => A_Status,
                               Temp     => Temp);

      Assert (Alert_Pin.Get,
              "Comparator: Test_No_Alert.Alert_Pin = Low, Active");
   end Test_No_Alert;

   --------------------------------------------------------------------------
   --        T_CRITICAL > T_HIGHER > T_LOWER > __TA__ -> low
   procedure Test_TA_Too_Low
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp : Celsius;
      A_Status : Ambient_Status;

      use AUnit.Assertions;
   begin
      Set_Lower_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => YES_ALERT_T_LOWER);

      Get_Ambient_Temperature (This   => Temp_Sensor_Device,
                               Status => Status,
                               A_Status => A_Status,
                               Temp     => Temp);

      Assert (Alert_Pin.Get = False,
              "Comparator: Test_TA_Too_Low.Alert_Pin = High, Inactive");
   end Test_TA_Too_Low;

   --------------------------------------------------------------------------
   --        T_CRITICAL > __TA__ > T_HIGHER > T_LOWER -> low
   procedure Test_TA_Too_High
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp : Celsius;
      A_Status : Ambient_Status;

      use AUnit.Assertions;
   begin
      Set_Upper_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => YES_ALERT_T_UPPER);

      Get_Ambient_Temperature (This   => Temp_Sensor_Device,
                               Status => Status,
                               A_Status => A_Status,
                               Temp     => Temp);

      Assert (Alert_Pin.Get = False,
              "Comparator: Test_TA_Too_High.Alert_Pin = High, Inactive");
   end Test_TA_Too_High;

   --------------------------------------------------------------------------
   --        __TA__ > T_CRITICAL > T_HIGHER > T_LOWER -> low
   procedure Test_TA_Above_Critical
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp : Celsius;
      A_Status : Ambient_Status;

      use AUnit.Assertions;
   begin
      Set_Upper_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => YES_ALERT_T_UPPER);
      Set_Critical_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => YES_ALERT_CRITICAL_HIGH);

      Get_Ambient_Temperature (This   => Temp_Sensor_Device,
                               Status => Status,
                               A_Status => A_Status,
                               Temp     => Temp);

      Assert (Alert_Pin.Get = False,
              "Comparator: Test_TA_Above_Critical.Alert_Pin = High, Inactive");
   end Test_TA_Above_Critical;

   --------------------------------------------------------------------------
   --        T_CRITICAL > T_HIGHER > __TA__ > T_LOWER -> high
   procedure Test_CriticalOnly_TA_Above_Lower
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp : Celsius;
      A_Status : Ambient_Status;

      use AUnit.Assertions;
   begin
      Alert_Only_Critical (This   => Temp_Sensor_Device,
                           Status => Status);
      Get_Ambient_Temperature (This   => Temp_Sensor_Device,
                               Status => Status,
                               A_Status => A_Status,
                               Temp     => Temp);
      --  back to POR
      Alert_All_Limits (This   => Temp_Sensor_Device,
                           Status => Status);

      Assert (Alert_Pin.Get,
              "Comparator: "
              & "Test_CriticalOnly_TA_Above_Lower.Alert_Pin = Low, Active");
   end Test_CriticalOnly_TA_Above_Lower;

   --------------------------------------------------------------------------
   --        T_CRITICAL > __TA__ > T_HIGHER > T_LOWER -> high
   procedure Test_CriticalOnly_TA_Above_Higher
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp : Celsius;
      A_Status : Ambient_Status;

      use AUnit.Assertions;
   begin
      Alert_Only_Critical (This   => Temp_Sensor_Device,
                           Status => Status);
      Set_Upper_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => YES_ALERT_T_UPPER);

      Get_Ambient_Temperature (This   => Temp_Sensor_Device,
                               Status => Status,
                               A_Status => A_Status,
                               Temp     => Temp);
      --  back to POR
      Alert_All_Limits (This   => Temp_Sensor_Device,
                        Status => Status);

      Assert (Alert_Pin.Get = False,
              "Comparator: "
              & "Test_CriticalOnly_TA_Above_Higher.Alert_Pin = High Inactive");
   end Test_CriticalOnly_TA_Above_Higher;

   --------------------------------------------------------------------------
   --        __TA__ > T_CRITICAL > T_HIGHER > T_LOWER -> low
   procedure Test_CriticalOnly_TA_Above_Critical
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp : Celsius;
      A_Status : Ambient_Status;

      use AUnit.Assertions;
   begin
      Alert_Only_Critical (This   => Temp_Sensor_Device,
                           Status => Status);
      Set_Upper_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => YES_ALERT_T_UPPER);
      Set_Critical_Temperature (This   => Temp_Sensor_Device,
                                Status => Status,
                                Temp   => YES_ALERT_CRITICAL_HIGH);

      Get_Ambient_Temperature (This   => Temp_Sensor_Device,
                               Status => Status,
                               A_Status => A_Status,
                               Temp     => Temp);
      --  back to POR
      Alert_All_Limits (This   => Temp_Sensor_Device,
                        Status => Status);

      Assert (Alert_Pin.Get = False,
              "Comparator: "
              & "Test_CriticalOnly_TA_Above_Critical."
              & "Alert_Pin = High, Inactive");
   end Test_CriticalOnly_TA_Above_Critical;

end Comparator_Tests;
