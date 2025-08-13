with AUnit.Assertions;

with MCP9808_I2C; use MCP9808_I2C;
with Configuration; use Configuration;

with Shared_Code;

package body Comparator_Tests is

   --------------------------------------------------------------------------
   --  constants for the temperature tests
   --------------------------------------------------------------------------
   POR_ALERT_CRITICAL_HIGH : constant Celsius := Celsius (0);
   POR_ALERT_T_HIGHER      : constant Celsius := Celsius (0);
   POR_ALERT_T_LOWER       : constant Celsius := Celsius (0);

   NO_ALERT_CRITICAL_HIGH : constant Celsius := Celsius (225);
   NO_ALERT_T_HIGHER      : constant Celsius := Celsius (200);
   NO_ALERT_T_LOWER       : constant Celsius := Celsius (-40);
   --------------------------------------------------------------------------
   --  these are the ones which must alert
   --  assuming, that the ambient temperature is inside the normal range of
   --  +15 .. +30
   YES_ALERT_CRITICAL_HIGH : constant Celsius := Celsius (10);
   YES_ALERT_T_HIGHER      : constant Celsius := Celsius (5);
   YES_ALERT_T_LOWER       : constant Celsius := Celsius (35);

   --------------------------------------------------------------------------
   --  all tests implemented
   --------------------------------------------------------------------------
   procedure Test_POR
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   --
   --  SET COMPARATOR OUTPUT TO ACTIVE LOW
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

   --  helpers for setup/tear down the tests
   procedure Set_No_Alert_Limits;
   procedure Set_Limits_Back_to_POR;

   overriding
   procedure Set_Up
     (T : in out Comparator_Test)
   is
   begin
      Shared_Code.Initialize;
      --  we set the hysteresis to 0, as we do not test the
      --  hysteresis capabilty at all
      Set_Hysteresis (This   => Temp_Sensor_Device,
                      Status => Status,
                      Hyst   => Zero);
      --  make sure the limits do not create any noise
      Set_No_Alert_Limits;
      --  enable output of alert
      Enable_Alert_Output (This   => Temp_Sensor_Device,
                           Status => Status);
   end Set_Up;

   overriding
   procedure Tear_Down
     (T : in out Comparator_Test) is
   begin
      Set_Limits_Back_to_POR;
      Disable_Alert_Output (This   => Temp_Sensor_Device,
                           Status => Status);
   end Tear_Down;

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

      Assert (A_Status.GorE_Upper = False,
             "Comparator: Test_No_Alert.GorE_Upper /= False");
      Assert (A_Status.Less_Than_Lower = False,
              "Comparator: Test_No_Alert.Less_Than_Lower /= False");
      Assert (A_Status.GorE_Critical = False,
              "Comparator: Test_No_Alert.GorE_Critical /= False");
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

      Assert (A_Status.GorE_Upper = False,
              "Comparator: Test_No_Alert.GorE_Upper /= False");
      Assert (A_Status.Less_Than_Lower,
              "Comparator: Test_No_Alert.Less_Than_Lower /= True");
      Assert (A_Status.GorE_Critical = False,
              "Comparator: Test_No_Alert.GorE_Critical /= False");
      Assert (Alert_Pin.Get = False,
              "Comparator: Test_No_Alert.Alert_Pin = High, Inactive");
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
                             Temp   => YES_ALERT_T_HIGHER);

      Get_Ambient_Temperature (This   => Temp_Sensor_Device,
                               Status => Status,
                               A_Status => A_Status,
                               Temp     => Temp);

      Assert (A_Status.GorE_Upper,
              "Comparator: Test_No_Alert.GorE_Upper /= True");
      Assert (A_Status.Less_Than_Lower = False,
              "Comparator: Test_No_Alert.Less_Than_Lower /= False");
      Assert (A_Status.GorE_Critical = False,
              "Comparator: Test_No_Alert.GorE_Critical /= False");
      Assert (Alert_Pin.Get = False,
              "Comparator: Test_No_Alert.Alert_Pin = High, Inactive");
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
                             Temp   => YES_ALERT_T_HIGHER);
      Set_Critical_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => YES_ALERT_CRITICAL_HIGH);

      Get_Ambient_Temperature (This   => Temp_Sensor_Device,
                               Status => Status,
                               A_Status => A_Status,
                               Temp     => Temp);

      Assert (A_Status.GorE_Upper,
              "Comparator: Test_No_Alert.GorE_Upper /= True");
      Assert (A_Status.Less_Than_Lower = False,
              "Comparator: Test_No_Alert.Less_Than_Lower /= False");
      Assert (A_Status.GorE_Critical,
              "Comparator: Test_No_Alert.GorE_Critical /= True");
      Assert (Alert_Pin.Get = False,
              "Comparator: Test_No_Alert.Alert_Pin = High, Inactive");
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

      Assert (A_Status.GorE_Upper = False,
              "Comparator: Test_No_Alert.GorE_Upper /= False");
      Assert (A_Status.Less_Than_Lower = False,
              "Comparator: Test_No_Alert.Less_Than_Lower /= False");
      Assert (A_Status.GorE_Critical = False,
              "Comparator: Test_No_Alert.GorE_Critical /= False");
      Assert (Alert_Pin.Get,
              "Comparator: Test_No_Alert.Alert_Pin = Low, Active");
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
                             Temp   => YES_ALERT_T_HIGHER);

      Get_Ambient_Temperature (This   => Temp_Sensor_Device,
                               Status => Status,
                               A_Status => A_Status,
                               Temp     => Temp);
      --  back to POR
      Alert_All_Limits (This   => Temp_Sensor_Device,
                        Status => Status);

      Assert (A_Status.GorE_Upper,
              "Comparator: Test_No_Alert.GorE_Upper /= True");
      Assert (A_Status.Less_Than_Lower = False,
              "Comparator: Test_No_Alert.Less_Than_Lower /= False");
      Assert (A_Status.GorE_Critical = False,
              "Comparator: Test_No_Alert.GorE_Critical /= False");
      Assert (Alert_Pin.Get = False,
              "Comparator: Test_No_Alert.Alert_Pin = High Inactive");
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
                             Temp   => YES_ALERT_T_HIGHER);
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

      Assert (A_Status.GorE_Upper,
              "Comparator: Test_No_Alert.GorE_Upper /= True");
      Assert (A_Status.Less_Than_Lower = False,
              "Comparator: Test_No_Alert.Less_Than_Lower /= False");
      Assert (A_Status.GorE_Critical,
              "Comparator: Test_No_Alert.GorE_Critical /= True");
      Assert (Alert_Pin.Get = False,
              "Comparator: Test_No_Alert.Alert_Pin = High, Inactive");
   end Test_CriticalOnly_TA_Above_Critical;

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

end Comparator_Tests;
