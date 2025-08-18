with AUnit.Assertions;

with MCP9808_I2C; use MCP9808_I2C;
with Configuration; use Configuration;

with Shared_Code;

package body AmbientStatus_Tests is

   --------------------------------------------------------------------------
   --  all tests implemented
   --------------------------------------------------------------------------
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

   overriding
   procedure Set_Up
     (T : in out AmbientStatus_Test)
   is
   begin
      Shared_Code.Initialize;
      --  we set the hysteresis to 0, as we do not test the
      --  hysteresis capabilty at all
      Set_Hysteresis (This   => Temp_Sensor_Device,
                      Status => Status,
                      Hyst   => Zero);
      --  make sure the limits do not create any noise
      Shared_Code.Set_No_Alert_Limits;
   end Set_Up;

   overriding
   procedure Tear_Down
     (T : in out AmbientStatus_Test) is
   begin
      Shared_Code.Set_Limits_Back_to_POR;
   end Tear_Down;

   overriding
   procedure Register_Tests
     (T : in out AmbientStatus_Test)
   is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_No_Alert'Access,
                        "AmbientStatus No_Alert");
      Register_Routine (T, Test_TA_Too_Low'Access,
                        "AmbientStatus Test_TA_Too_Low");
      Register_Routine (T, Test_TA_Too_High'Access,
                        "AmbientStatus Test_TA_Too_High");
      Register_Routine (T, Test_TA_Above_Critical'Access,
                        "AmbientStatus Test_TA_Above_Critical");
      Register_Routine (T, Test_CriticalOnly_TA_Above_Lower'Access,
                        "AmbientStatus Test_CriticalOnly_TA_Above_Lower");
      Register_Routine (T, Test_CriticalOnly_TA_Above_Higher'Access,
                        "AmbientStatus Test_CriticalOnly_TA_Above_Higher");
      Register_Routine (T, Test_CriticalOnly_TA_Above_Critical'Access,
                        "AmbientStatus Test_CriticalOnly_TA_Above_Critical");
   end Register_Tests;

   overriding
   function Name
     (T : AmbientStatus_Test)
      return AUnit.Message_String
   is (AUnit.Format ("AmbientStatus_Tests"));

   --------------------------------------------------------------------------
   --     type Alert_Output_Select is (All_Limits)
   --        T_CRITICAL > T_HIGHER > __TA__ > T_LOWER -> high
   procedure Test_No_Alert
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Warnings (Off, T);

      Temp     : Celsius;
      A_Status : Ambient_Status;

      use AUnit.Assertions;
   begin
      Get_Ambient_Temperature (This   => Temp_Sensor_Device,
                               Status => Status,
                               A_Status => A_Status,
                               Temp     => Temp);

      Assert (A_Status.GorE_Upper = False,
              "AmbientStatus: Test_No_Alert.GorE_Upper /= False");
      Assert (A_Status.Less_Than_Lower = False,
              "AmbientStatus: Test_No_Alert.Less_Than_Lower /= False");
      Assert (A_Status.GorE_Critical = False,
              "AmbientStatus: Test_No_Alert.GorE_Critical /= False");
   end Test_No_Alert;

   --------------------------------------------------------------------------
   --        T_CRITICAL > T_HIGHER > T_LOWER > __TA__ -> low
   procedure Test_TA_Too_Low
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp     : Celsius;
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
              "AmbientStatus: Test_TA_Too_Low.GorE_Upper /= False");
      Assert (A_Status.Less_Than_Lower,
              "AmbientStatus: Test_TA_Too_Low.Less_Than_Lower /= True");
      Assert (A_Status.GorE_Critical = False,
              "AmbientStatus: Test_TA_Too_Low.GorE_Critical /= False");
   end Test_TA_Too_Low;

   --------------------------------------------------------------------------
   --        T_CRITICAL > __TA__ > T_HIGHER > T_LOWER -> low
   procedure Test_TA_Too_High
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp     : Celsius;
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
              "AmbientStatus: Test_TA_Too_High.GorE_Upper /= True");
      Assert (A_Status.Less_Than_Lower = False,
              "AmbientStatus: Test_TA_Too_High.Less_Than_Lower /= False");
      Assert (A_Status.GorE_Critical = False,
              "AmbientStatus: Test_TA_Too_High.GorE_Critical /= False");
   end Test_TA_Too_High;

   --------------------------------------------------------------------------
   --        __TA__ > T_CRITICAL > T_HIGHER > T_LOWER -> low
   procedure Test_TA_Above_Critical
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp     : Celsius;
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
              "AmbientStatus: Test_TA_Above_Critical.GorE_Upper /= True");
      Assert (A_Status.Less_Than_Lower = False,
              "AmbientStatus: "
              & "Test_TA_Above_Critical.Less_Than_Lower /= False");
      Assert (A_Status.GorE_Critical,
              "AmbientStatus: Test_TA_Above_Critical.GorE_Critical /= True");
   end Test_TA_Above_Critical;

   --------------------------------------------------------------------------
   --        T_CRITICAL > T_HIGHER > __TA__ > T_LOWER -> high
   procedure Test_CriticalOnly_TA_Above_Lower
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp     : Celsius;
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
              "AmbientStatus: "
              & "Test_CriticalOnly_TA_Above_Lower.GorE_Upper /= False");
      Assert (A_Status.Less_Than_Lower = False,
              "AmbientStatus: "
              & "Test_CriticalOnly_TA_Above_Lower.Less_Than_Lower /= False");
      Assert (A_Status.GorE_Critical = False,
              "AmbientStatus: "
              & "Test_CriticalOnly_TA_Above_Lower.GorE_Critical /= False");
   end Test_CriticalOnly_TA_Above_Lower;

   --------------------------------------------------------------------------
   --        T_CRITICAL > __TA__ > T_HIGHER > T_LOWER -> high
   procedure Test_CriticalOnly_TA_Above_Higher
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp     : Celsius;
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
              "AmbientStatus: "
              & "Test_CriticalOnly_TA_Above_Higher.GorE_Upper /= True");
      Assert (A_Status.Less_Than_Lower = False,
              "AmbientStatus: "
              & "Test_CriticalOnly_TA_Above_Higher.Less_Than_Lower /= False");
      Assert (A_Status.GorE_Critical = False,
              "AmbientStatus: "
              & "Test_CriticalOnly_TA_Above_Higher.GorE_Critical /= False");
   end Test_CriticalOnly_TA_Above_Higher;

   --------------------------------------------------------------------------
   --        __TA__ > T_CRITICAL > T_HIGHER > T_LOWER -> low
   procedure Test_CriticalOnly_TA_Above_Critical
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp     : Celsius;
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
              "AmbientStatus: "
              & "Test_CriticalOnly_TA_Above_Critical.GorE_Upper /= True");
      Assert (A_Status.Less_Than_Lower = False,
              "AmbientStatus: "
              & "Test_CriticalOnly_TA_Above_Critical.Less_Than_Lower/=False");
      Assert (A_Status.GorE_Critical,
              "AmbientStatus: "
              & "Test_CriticalOnly_TA_Above_Critical.GorE_Critical /= True");
   end Test_CriticalOnly_TA_Above_Critical;

end AmbientStatus_Tests;
