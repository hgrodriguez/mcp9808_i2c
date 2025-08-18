with AUnit.Assertions;

with MCP9808_I2C; use MCP9808_I2C;
with Configuration; use Configuration;

with Shared_Code;

package body Interrupt_Tests is

   --------------------------------------------------------------------------
   --  all tests implemented
   --------------------------------------------------------------------------
   procedure Test_Init
     (T : in out AUnit.Test_Cases.Test_Case'Class);
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
     (T : in out Interrupt_Test) is
   begin
      Shared_Code.Initialize;
      --  make sure the limits do not create any noise
      Shared_Code.Set_No_Alert_Limits;

      --  enable output of alert
      Enable_Alert_Output (This   => Temp_Sensor_Device,
                           Status => Status);
      --  active low
      Set_Alert_Polarity_Low (This   => Temp_Sensor_Device,
                              Status => Status);
      --  enable interrupt
      Set_Alert_As_Interrupt (This   => Temp_Sensor_Device,
                              Status => Status);
      Clear_Interrupt (This   => Temp_Sensor_Device,
                       Status => Status);
   end Set_Up;

   --------------------------------------------------------------------------
   overriding
   procedure Tear_Down
     (T : in out Interrupt_Test) is
   begin
      Shared_Code.Set_Limits_Back_to_POR;
      --  set POR status
      Set_Alert_As_Comparator (This   => Temp_Sensor_Device,
                               Status => Status);
      Disable_Alert_Output (This   => Temp_Sensor_Device,
                            Status => Status);
   end Tear_Down;

   --------------------------------------------------------------------------
   overriding
   procedure Register_Tests
     (T : in out Interrupt_Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Init'Access,
                        "Interrupt Init");
      Register_Routine (T, Test_No_Alert'Access,
                        "Interrupt No_Alert");
      Register_Routine (T, Test_TA_Too_Low'Access,
                        "Interrupt Test_TA_Too_Low");
      Register_Routine (T, Test_TA_Too_High'Access,
                        "Interrupt Test_TA_Too_High");
      Register_Routine (T, Test_TA_Above_Critical'Access,
                        "Interrupt Test_TA_Above_Critical");
      Register_Routine (T, Test_CriticalOnly_TA_Above_Lower'Access,
                        "Interrupt Test_CriticalOnly_TA_Above_Lower");
      Register_Routine (T, Test_CriticalOnly_TA_Above_Higher'Access,
                        "Interrupt Test_CriticalOnly_TA_Above_Higher");
      Register_Routine (T, Test_CriticalOnly_TA_Above_Critical'Access,
                        "Interrupt Test_CriticalOnly_TA_Above_Critical");
   end Register_Tests;

   --------------------------------------------------------------------------
   overriding
   function Name
     (T : Interrupt_Test)
      return AUnit.Message_String is
     (AUnit.Format ("Interrupt_Test"));

   --------------------------------------------------------------------------
   procedure Test_Init
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp : Celsius;

      use AUnit.Assertions;
   begin
      Assert (Is_Alert_Interrupt (This   => Temp_Sensor_Device,
                                  Status => Status),
              "Interrupt: Init /= True");
   end Test_Init;

   --------------------------------------------------------------------------
   --        T_CRITICAL > T_HIGHER > __TA__ > T_LOWER -> high
   procedure Test_No_Alert
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp     : Celsius;
      A_Status : Ambient_Status;
      Pin_Status : Boolean;

      use AUnit.Assertions;
   begin
      Get_Ambient_Temperature (This   => Temp_Sensor_Device,
                               Status => Status,
                               A_Status => A_Status,
                               Temp     => Temp);
      Pin_Status := Alert_Pin.Get;
      Assert (Pin_Status,
              "Interrupt: Test_No_Alert.Alert_Pin = Low, Active");
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

      Assert (Alert_Pin.Get = False,
              "Interrupt: Test_TA_Too_Low.Alert_Pin = High, Inactive");
      Clear_Interrupt (This   => Temp_Sensor_Device,
                       Status => Status);
      Assert (Alert_Pin.Get,
              "Interrupt: Test_TA_Too_Low.Alert_Pin = Low, Active");
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
                             Temp   => YES_ALERT_T_UPPER);

      Get_Ambient_Temperature (This   => Temp_Sensor_Device,
                               Status => Status,
                               A_Status => A_Status,
                               Temp     => Temp);

      Clear_Interrupt (This   => Temp_Sensor_Device,
                       Status => Status);
      Assert (Alert_Pin.Get,
              "Interrupt: Test_TA_Too_High.Alert_Pin = Low, Active");
   end Test_TA_Too_High;

   --------------------------------------------------------------------------
   --        __TA__ > T_CRITICAL > T_HIGHER > T_LOWER -> low
   procedure Test_TA_Above_Critical
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp     : Celsius;
      A_Status : Ambient_Status;
      Pin_Status : Boolean;

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

      Clear_Interrupt (This   => Temp_Sensor_Device,
                       Status => Status);
      Set_Critical_Temperature (This   => Temp_Sensor_Device,
                                Status => Status,
                                Temp   => NO_ALERT_CRITICAL_HIGH);
      Set_Upper_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => NO_ALERT_T_UPPER);
      Pin_Status := Alert_Pin.Get;
      Assert (Pin_Status,
              "Interrupt: Test_TA_Above_Critical.Alert_Pin = Low, Active");
   end Test_TA_Above_Critical;

   --------------------------------------------------------------------------
   --        T_CRITICAL > T_HIGHER > __TA__ > T_LOWER -> high
   procedure Test_CriticalOnly_TA_Above_Lower
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp     : Celsius;
      A_Status : Ambient_Status;
      Pin_Status : Boolean;

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

      Clear_Interrupt (This   => Temp_Sensor_Device,
                       Status => Status);
      Pin_Status := Alert_Pin.Get;
      Assert (Pin_Status,
              "Interrupt: "
              & "Test_CriticalOnly_TA_Above_Lower.Alert_Pin = Low, Active");
   end Test_CriticalOnly_TA_Above_Lower;

   --------------------------------------------------------------------------
   --        T_CRITICAL > __TA__ > T_HIGHER > T_LOWER -> high
   procedure Test_CriticalOnly_TA_Above_Higher
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp     : Celsius;
      A_Status : Ambient_Status;
      Pin_Status : Boolean;

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

      Clear_Interrupt (This   => Temp_Sensor_Device,
                       Status => Status);
      Set_Upper_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => NO_ALERT_T_UPPER);
      Pin_Status := Alert_Pin.Get;
      Assert (Pin_Status,
              "Interrupt: "
              & "Test_CriticalOnly_TA_Above_Higher.Alert_Pin = Low, Active");
   end Test_CriticalOnly_TA_Above_Higher;

   --------------------------------------------------------------------------
   --        __TA__ > T_CRITICAL > T_HIGHER > T_LOWER -> low
   procedure Test_CriticalOnly_TA_Above_Critical
     (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Warnings (Off, T);

      Temp     : Celsius;
      A_Status : Ambient_Status;
      Pin_Status : Boolean;

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

      Set_Critical_Temperature (This   => Temp_Sensor_Device,
                                Status => Status,
                                Temp   => NO_ALERT_CRITICAL_HIGH);
      Set_Upper_Temperature (This   => Temp_Sensor_Device,
                             Status => Status,
                             Temp   => NO_ALERT_T_UPPER);
      Clear_Interrupt (This   => Temp_Sensor_Device,
                       Status => Status);
      Pin_Status := Alert_Pin.Get;
      Assert (Pin_Status,
              "Interrupt: "
              & "Test_CriticalOnly_TA_Above_Critical."
              & "Alert_Pin = Low, Active");
   end Test_CriticalOnly_TA_Above_Critical;

end Interrupt_Tests;
