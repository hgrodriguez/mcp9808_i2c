--===========================================================================
--
--  This package is implementing the capability for the
--  temperature sensor MC9808 using the I2C protocol.
--
--===========================================================================
--
--  Copyright 2025 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--

with Ada.Unchecked_Conversion;

package body MCP9808_I2C is

   --------------------------------------------------------------------------
   --  all register pointers available, only used internally
   RP_CONFIG              : constant UInt8 := 2#0000_0001#;
   RP_MANUFACTURER_ID     : constant UInt8 := 2#0000_0110#;
   RP_DEVICE_ID_REVISION  : constant UInt8 := 2#0000_0111#;
   RP_RESOLUTION          : constant UInt8 := 2#0000_1000#;

   --------------------------------------------------------------------------
   --  definition of the configuration register
   type Alert_Control is (Disabled,
                          Enabled) with Size => 1;
   for Alert_Control use (Disabled => 0,
                          Enabled => 1);
   type Alert_Output_Select is (All_Limits,
                                TA_GT_TCRIT_ONLY) with Size => 1;
   for Alert_Output_Select use (All_Limits => 0,
                                TA_GT_TCRIT_ONLY => 1);
   type Alert_Polarity is (Active_Low,
                           Active_High) with Size => 1;
   for Alert_Polarity use (Active_Low => 0,
                           Active_High => 1);
   type Alert_Output_Mode is (Comparator,
                              Interrupt) with Size => 1;
   for Alert_Output_Mode use (Comparator => 0,
                              Interrupt => 1);
   type CONFIG_REGISTER is record
      UNIMPLEMENTED        : UInt5;
      CR_HYSTERESIS        : UInt2;
      CR_SHUTDOWN          : Bit;
      CR_CRIT_LOCK         : Bit;
      CR_WINDOW_LOCK       : Bit;
      CR_INTERRUPT_CLEAR   : Bit;
      CR_ALERT_STATUS      : Bit;
      CR_ALERT_CONTROL     : Alert_Control;
      CD_ALERT_SELECT      : Alert_Output_Select;
      CR_ALERT_POLARITY    : Alert_Polarity;
      CR_ALERT_OUTPUT_MODE : Alert_Output_Mode;
   end record;
   for CONFIG_REGISTER use record
      UNIMPLEMENTED        at 0 range 11 .. 15;
      CR_HYSTERESIS        at 0 range 9 .. 10;
      CR_SHUTDOWN          at 0 range 8 .. 8;
      CR_CRIT_LOCK         at 0 range 7 .. 7;
      CR_WINDOW_LOCK       at 0 range 6 .. 6;
      CR_INTERRUPT_CLEAR   at 0 range 5 .. 5;
      CR_ALERT_STATUS      at 0 range 4 .. 4;
      CR_ALERT_CONTROL     at 0 range 3 .. 3;
      CD_ALERT_SELECT      at 0 range 2 .. 2;
      CR_ALERT_POLARITY    at 0 range 1 .. 1;
      CR_ALERT_OUTPUT_MODE at 0 range 0 .. 0;
   end record;

   --------------------------------------------------------------------------
   --  definition of a temperature register.
   --  I silently ignore the difference between the
   --  register: Ambient Temperature
   --     TA_VS_T_CRIT
   --     TA_VS_T_UPPER
   --     TA_VS_T_LOWER
   --     Integer Part: UInt8
   --     Fraction: UInt4
   --  and
   --  all limit registers:
   --     UPPER
   --     LOWER
   --     CRITICAL
   --     Integer Part: UInt8
   --     Fraction: UInt2
   --  as the difference is very small and has no impact on any operation
   type TEMP_SIGN is (GREATER_OR_EQUAL_ZERO,
                      LESS_THAN_ZERO) with Size => 1;
   for TEMP_SIGN use (GREATER_OR_EQUAL_ZERO => 0,
                      LESS_THAN_ZERO => 1);

   type TA_TEMP_VS_T_CRIT is (TA_LESS_THAN_T_CRIT,
                              TA_GREATER_OR_EQUAL_T_CRIT) with Size => 1;
   for TA_TEMP_VS_T_CRIT use (TA_LESS_THAN_T_CRIT => 0,
                              TA_GREATER_OR_EQUAL_T_CRIT => 1);

   type TA_TEMP_VS_T_UPPER is (TA_LESS_OR_EQUAL_T_UPPER,
                               TA_GREATER_THAN_T_UPPER) with Size => 1;
   for TA_TEMP_VS_T_UPPER use (TA_LESS_OR_EQUAL_T_UPPER => 0,
                               TA_GREATER_THAN_T_UPPER => 1);

   type TA_TEMP_VS_T_LOWER is (TA_GREATER_OR_EQUAL_T_LOWER,
                               TA_LESS_THAN_T_LOWER) with Size => 1;
   for TA_TEMP_VS_T_LOWER use (TA_GREATER_OR_EQUAL_T_LOWER => 0,
                               TA_LESS_THAN_T_LOWER => 1);

   type TEMPERATURE_REGISTER is record
      TR_VS_T_CRIT                : TA_TEMP_VS_T_CRIT;
      TR_VS_T_UPPER               : TA_TEMP_VS_T_UPPER;
      TR_VS_T_LOWER               : TA_TEMP_VS_T_LOWER;
      TR_SIGN                     : TEMP_SIGN;
      TR_BINARY_NUMBER            : UInt8;
      TR_BINARY_FRACTION          : UInt4;
   end record with Size => 16;
   for TEMPERATURE_REGISTER use record
      TR_VS_T_CRIT       at 0 range 15 .. 15;
      TR_VS_T_UPPER      at 0 range 14 .. 14;
      TR_VS_T_LOWER      at 0 range 13 .. 13;
      TR_SIGN            at 0 range 12 .. 12;
      TR_BINARY_NUMBER   at 0 range 4 .. 11;
      TR_BINARY_FRACTION at 0 range 0 .. 3;
   end record;

   subtype Data_R_2_Type is I2C.I2C_Data (1 .. 2);
   procedure Read_Register_As_Data_R_2
     (RP_REGISTER           : UInt8;
      This                  : in out MCP9808_I2C_Port;
      Status                : out Op_Status;
      Data_R                : out Data_R_2_Type);
   procedure Get_Any_Temperature
     (RP_REGISTER       : UInt8;
      This              : in out MCP9808_I2C_Port;
      Status            : out Op_Status;
      Temp              : out Celsius);
   function Data_R_To_Celsius (Data_R : I2C_Data) return Celsius;
   function Celsius_To_Register (Temp_In_Celsius : Celsius)
                                 return TEMPERATURE_REGISTER;
   procedure Configure
     (This      : in out MCP9808_I2C_Port;
      Port      : Any_I2C_Port;
      Address   : I2C_Address := I2C_DEFAULT_ADDRESS;
      --    Alert_Pin : not null GPIO.Any_GPIO_Point;
      Status    : out Op_Status) is

   begin
      Status.I2C_Status := I2C.Ok;
      Status.E_Status := Ok;

      This.Port := Port;
      This.Address := Address;
   end Configure;

   procedure Get_Config_Register (This   : in out MCP9808_I2C_Port;
                                  Status : out Op_Status;
                                  C_R    : out CONFIG_REGISTER);

   procedure Get_Hysteresis (This   : in out MCP9808_I2C_Port;
                             Status : out Op_Status;
                             Hyst   : out Hysteresis) is

      C_R                   : CONFIG_REGISTER;

   begin
      Get_Config_Register (This   => This,
                           Status => Status,
                           C_R    => C_R);
      if Status.I2C_Status /= I2C.Ok then
         Hyst := Zero;
         return;
      end if;

      case C_R.CR_HYSTERESIS is
         when 2#00# => Hyst := Zero;
         when 2#01# => Hyst := One_Half;
         when 2#10# => Hyst := Three;
         when 2#11# => Hyst := Six;
      end case;
   end Get_Hysteresis;

   procedure Set_Hysteresis (This   : in out MCP9808_I2C_Port;
                             Status : out Op_Status;
                             Hyst   : Hysteresis) is

      Data_T                : I2C.I2C_Data (1 .. 3)
        := (1 => RP_CONFIG,
           others => 0);
      I2C_Status            : I2C.I2C_Status;
      LSB                   : UInt8;
      MSB                   : UInt8;
      Word : UInt16;
      C_R                   : CONFIG_REGISTER;

      function To_UInt16 is
        new Ada.Unchecked_Conversion (CONFIG_REGISTER, UInt16);

   begin
      Get_Config_Register (This   => This,
                           Status => Status,
                           C_R    => C_R);
      if Status.I2C_Status /= I2C.Ok then
         return;
      end if;

      case Hyst is
         when Zero => C_R.CR_HYSTERESIS := 2#00#;
         when One_Half => C_R.CR_HYSTERESIS := 2#01#;
         when Three => C_R.CR_HYSTERESIS := 2#10#;
         when Six => C_R.CR_HYSTERESIS := 2#11#;
      end case;
      Word := To_UInt16 (C_R);
      LSB := UInt8 (Word);
      MSB := UInt8 (Shift_Right (Word, 8));

      Data_T (2) := MSB;
      Data_T (3) := LSB;

      Status.I2C_Status := I2C.Ok;
      Status.E_Status := Ok;

      This.Port.all.Master_Transmit (Addr    => This.Address,
                                     Data    => Data_T,
                                     Status  => I2C_Status,
                                     Timeout => 1000);
      if I2C_Status /= I2C.Ok then
         Status.I2C_Status := I2C_Status;
         Status.E_Status := I2C_Not_Ok;
         return;
      end if;
   end Set_Hysteresis;

   procedure Set_Resolution
     (This       : in out MCP9808_I2C_Port;
      Res        : Resolution;
      Status     : out Op_Status) is

      Data_T     : I2C.I2C_Data (1 .. 2)
        := (1 => RP_RESOLUTION,
            others => 0);
      I2C_Status : I2C.I2C_Status;

      function To_UInt8 is new Ada.Unchecked_Conversion (Resolution, UInt8);

   begin
      Data_T (2) := To_UInt8 (Res);

      Status.I2C_Status := I2C.Ok;
      Status.E_Status := Ok;
      This.Port.all.Master_Transmit (Addr    => This.Address,
                                     Data    => Data_T,
                                     Status  => I2C_Status,
                                     Timeout => 1000);
      if I2C_Status /= I2C.Ok then
         Status.I2C_Status := I2C_Status;
         Status.E_Status := I2C_Not_Ok;
      end if;
   end Set_Resolution;

   procedure Get_Resolution
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Res    : out Resolution) is

      Data_T                : constant I2C.I2C_Data (1 .. 1)
        := (1 => RP_RESOLUTION);
      Data_R                : I2C.I2C_Data (1 .. 1) := (others => 0);
      I2C_Status            : I2C.I2C_Status;

      function To_Resolution is
        new Ada.Unchecked_Conversion (UInt8, Resolution);

   begin
      Status.I2C_Status := I2C.Ok;
      Status.E_Status := Ok;

      This.Port.all.Master_Transmit (Addr    => This.Address,
                                     Data    => Data_T,
                                     Status  => I2C_Status,
                                     Timeout => 1000);
      if I2C_Status /= I2C.Ok then
         Status.I2C_Status := I2C_Status;
         Status.E_Status := I2C_Not_Ok;
         Res := MCP9808_I2C.Half;
         return;
      end if;

      This.Port.all.Master_Receive (Addr    => This.Address,
                                    Data    => Data_R,
                                    Status  => I2C_Status,
                                    Timeout => 1000);

      if I2C_Status /= I2C.Ok then
         Status.I2C_Status := I2C_Status;
         Status.E_Status := I2C_Not_Ok;
         Res := MCP9808_I2C.Half;
         return;
      end if;

      Res := To_Resolution (Data_R (1));
   end Get_Resolution;

   procedure Set_Any_Temperature
     (RP_REGISTER : UInt8;
      This        : in out MCP9808_I2C_Port;
      Status      : out Op_Status;
      Temp        : Celsius) is

      Reg_Ptr_Data                : I2C.I2C_Data (1 .. 3)
        := (1 => RP_REGISTER,
            others => 0);
      Local_Register              : TEMPERATURE_REGISTER;
      Temp_16                     : UInt16;
      MSB                         : UInt8;
      LSB                         : UInt8;
      I2C_Status                  : I2C.I2C_Status;

      function To_UInt16 is
        new Ada.Unchecked_Conversion (TEMPERATURE_REGISTER, UInt16);

   begin
      Reg_Ptr_Data (1) := RP_REGISTER;

      Local_Register := Celsius_To_Register (Temp);
      Temp_16 := To_UInt16 (Local_Register);

      MSB := UInt8 (Shift_Right (Value  => Temp_16,
                                 Amount => 8));
      LSB := UInt8 (Temp_16);
      Reg_Ptr_Data (2) := MSB;
      Reg_Ptr_Data (3) := LSB;

      This.Port.all.Master_Transmit (Addr    => This.Address,
                                     Data    => Reg_Ptr_Data,
                                     Status  => I2C_Status,
                                     Timeout => 1000);

      if I2C_Status /= I2C.Ok then
         Status.I2C_Status := I2C_Status;
         Status.E_Status := I2C_Not_Ok;
         return;
      end if;
   end Set_Any_Temperature;

   procedure Set_Upper_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : Celsius) is
   begin
      Set_Any_Temperature (RP_REGISTER => RP_T_UPPER,
                           This        => This,
                           Status      => Status,
                           Temp        => Temp);
   end Set_Upper_Temperature;

   procedure Get_Upper_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : out Celsius) is
   begin
      Get_Any_Temperature (RP_REGISTER => RP_T_UPPER,
                           This              => This,
                           Status            => Status,
                           Temp              => Temp);
   end Get_Upper_Temperature;

   procedure Set_Lower_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : Celsius) is
   begin
      Set_Any_Temperature (RP_REGISTER => RP_T_LOWER,
                           This        => This,
                           Status      => Status,
                           Temp        => Temp);
   end Set_Lower_Temperature;

   procedure Get_Lower_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : out Celsius) is
   begin
      Get_Any_Temperature (RP_REGISTER => RP_T_LOWER,
                           This              => This,
                           Status            => Status,
                           Temp              => Temp);
   end Get_Lower_Temperature;

   procedure Lock_Lower_Upper_Window
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status) is

      Data_T                : I2C.I2C_Data (1 .. 3)
        := (1 => RP_CONFIG,
            others => 0);
      I2C_Status            : I2C.I2C_Status;
      LSB                   : UInt8;
      MSB                   : UInt8;
      Word                  : UInt16;
      C_R                   : CONFIG_REGISTER;

      function To_UInt16 is
        new Ada.Unchecked_Conversion (CONFIG_REGISTER, UInt16);

   begin
      Get_Config_Register (This   => This,
                           Status => Status,
                           C_R    => C_R);
      if Status.I2C_Status /= I2C.Ok then
         return;
      end if;

      C_R.CR_WINDOW_LOCK := 1;

      Word := To_UInt16 (C_R);
      LSB := UInt8 (Word);
      MSB := UInt8 (Shift_Right (Word, 8));

      Data_T (2) := MSB;
      Data_T (3) := LSB;

      Status.I2C_Status := I2C.Ok;
      Status.E_Status := Ok;

      This.Port.all.Master_Transmit (Addr    => This.Address,
                                     Data    => Data_T,
                                     Status  => I2C_Status,
                                     Timeout => 1000);
      if I2C_Status /= I2C.Ok then
         Status.I2C_Status := I2C_Status;
         Status.E_Status := I2C_Not_Ok;
         return;
      end if;
   end Lock_Lower_Upper_Window;

   procedure Set_Critical_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : Celsius) is
   begin
      Set_Any_Temperature (RP_REGISTER => RP_T_CRIT,
                           This        => This,
                           Status      => Status,
                           Temp        => Temp);
   end Set_Critical_Temperature;

   procedure Get_Critical_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : out Celsius) is
   begin
      Get_Any_Temperature (RP_REGISTER => RP_T_CRIT,
                           This              => This,
                           Status            => Status,
                           Temp              => Temp);
   end Get_Critical_Temperature;

   procedure Lock_Critical_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status) is

      Data_T                : I2C.I2C_Data (1 .. 3)
        := (1 => RP_CONFIG,
            others => 0);
      I2C_Status            : I2C.I2C_Status;
      LSB                   : UInt8;
      MSB                   : UInt8;
      Word                  : UInt16;
      C_R                   : CONFIG_REGISTER;

      function To_UInt16 is
        new Ada.Unchecked_Conversion (CONFIG_REGISTER, UInt16);

   begin
      Get_Config_Register (This   => This,
                           Status => Status,
                           C_R    => C_R);
      if Status.I2C_Status /= I2C.Ok then
         return;
      end if;

      C_R.CR_CRIT_LOCK := 1;

      Word := To_UInt16 (C_R);
      LSB := UInt8 (Word);
      MSB := UInt8 (Shift_Right (Word, 8));

      Data_T (2) := MSB;
      Data_T (3) := LSB;

      Status.I2C_Status := I2C.Ok;
      Status.E_Status := Ok;

      This.Port.all.Master_Transmit (Addr    => This.Address,
                                     Data    => Data_T,
                                     Status  => I2C_Status,
                                     Timeout => 1000);
      if I2C_Status /= I2C.Ok then
         Status.I2C_Status := I2C_Status;
         Status.E_Status := I2C_Not_Ok;
         return;
      end if;
   end Lock_Critical_Temperature;

   procedure Get_Ambient_Temperature
     (This     : in out MCP9808_I2C_Port;
      Status   : out Op_Status;
      A_Status : out Ambient_Status;
      Temp     : out Celsius) is

      Data_R                : I2C.I2C_Data (1 .. 2) := (others => 0);
      Data_R_As_UInt16      : UInt16;
      Temperature           : TEMPERATURE_REGISTER;

      function To_T_A_REGISTER is
        new Ada.Unchecked_Conversion (UInt16, TEMPERATURE_REGISTER);

   begin
      Read_Register_As_Data_R_2 (RP_REGISTER => RP_T_A,
                                 This        => This,
                                 Status      => Status,
                                 Data_R      => Data_R);
      if Status.I2C_Status /= I2C.Ok then
         return;
      end if;

      Data_R_As_UInt16 := Shift_Left (Value  => UInt16 (Data_R (1)),
                                      Amount => 8) or UInt16 (Data_R (2));
      Temperature := To_T_A_REGISTER (Data_R_As_UInt16);
      if Temperature.TR_VS_T_UPPER = TA_GREATER_THAN_T_UPPER then
         A_Status.GorE_Upper := True;
      else
         A_Status.GorE_Upper := False;
      end if;
      if Temperature.TR_VS_T_LOWER = TA_LESS_THAN_T_LOWER then
         A_Status.Less_Than_Lower := True;
      else
         A_Status.Less_Than_Lower := False;
      end if;
      if Temperature.TR_VS_T_CRIT = TA_GREATER_OR_EQUAL_T_CRIT then
         A_Status.GorE_Critical := True;
      else
         A_Status.GorE_Critical := False;
      end if;

      Temp := Data_R_To_Celsius (Data_R => Data_R);
   end Get_Ambient_Temperature;

   procedure Shutdown
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status) is

      Data_T                : I2C.I2C_Data (1 .. 3)
        := (1 => RP_CONFIG,
            others => 0);
      I2C_Status            : I2C.I2C_Status;
      LSB                   : UInt8;
      MSB                   : UInt8;
      Word                  : UInt16;
      C_R                   : CONFIG_REGISTER;

      function To_UInt16 is
        new Ada.Unchecked_Conversion (CONFIG_REGISTER, UInt16);

   begin
      Get_Config_Register (This   => This,
                           Status => Status,
                           C_R    => C_R);
      if Status.I2C_Status /= I2C.Ok then
         return;
      end if;

      C_R.CR_SHUTDOWN := 1;

      Word := To_UInt16 (C_R);
      LSB := UInt8 (Word);
      MSB := UInt8 (Shift_Right (Word, 8));

      Data_T (2) := MSB;
      Data_T (3) := LSB;

      Status.I2C_Status := I2C.Ok;
      Status.E_Status := Ok;

      This.Port.all.Master_Transmit (Addr    => This.Address,
                                     Data    => Data_T,
                                     Status  => I2C_Status,
                                     Timeout => 1000);
      if I2C_Status /= I2C.Ok then
         Status.I2C_Status := I2C_Status;
         Status.E_Status := I2C_Not_Ok;
         return;
      end if;
   end Shutdown;

   function Is_Shutdown
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status) return Boolean is

      C_R                   : CONFIG_REGISTER;

   begin
      Get_Config_Register (This   => This,
                           Status => Status,
                           C_R    => C_R);
      if Status.I2C_Status /= I2C.Ok then
         return False;
      end if;

      return C_R.CR_SHUTDOWN = 1;
   end Is_Shutdown;

   procedure Wakeup
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status) is

      Data_T                : I2C.I2C_Data (1 .. 3)
        := (1 => RP_CONFIG,
            others => 0);
      I2C_Status            : I2C.I2C_Status;
      LSB                   : UInt8;
      MSB                   : UInt8;
      Word                  : UInt16;
      C_R                   : CONFIG_REGISTER;

      function To_UInt16 is
        new Ada.Unchecked_Conversion (CONFIG_REGISTER, UInt16);

   begin
      Get_Config_Register (This   => This,
                           Status => Status,
                           C_R    => C_R);
      if Status.I2C_Status /= I2C.Ok then
         return;
      end if;

      C_R.CR_SHUTDOWN := 0;

      Word := To_UInt16 (C_R);
      LSB := UInt8 (Word);
      MSB := UInt8 (Shift_Right (Word, 8));

      Data_T (2) := MSB;
      Data_T (3) := LSB;

      Status.I2C_Status := I2C.Ok;
      Status.E_Status := Ok;

      This.Port.all.Master_Transmit (Addr    => This.Address,
                                     Data    => Data_T,
                                     Status  => I2C_Status,
                                     Timeout => 1000);
      if I2C_Status /= I2C.Ok then
         Status.I2C_Status := I2C_Status;
         Status.E_Status := I2C_Not_Ok;
         return;
      end if;
   end Wakeup;

   function Is_Awake
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status) return Boolean is

      C_R                   : CONFIG_REGISTER;

   begin
      Get_Config_Register (This   => This,
                           Status => Status,
                           C_R    => C_R);
      if Status.I2C_Status /= I2C.Ok then
         return True;
      end if;

      return C_R.CR_SHUTDOWN = 0;
   end Is_Awake;

   function Get_Manufacturer_Id
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status) return UInt16 is

      Data_R     : I2C.I2C_Data (1 .. 2) := (others => 0);
      Result     : UInt16;

   begin
      Read_Register_As_Data_R_2 (RP_REGISTER => RP_MANUFACTURER_ID,
                                 This        => This,
                                 Status      => Status,
                                 Data_R      => Data_R);
      if Status.I2C_Status /= I2C.Ok then
         return 0;
      end if;

      Result := Shift_Left (Value  => UInt16 (Data_R (1)),
                            Amount => 8)
        or  UInt16 (Data_R (2));
      return Result;
   end Get_Manufacturer_Id;

   function Get_Device_Id
     (This      : in out MCP9808_I2C_Port;
      Status    : out Op_Status) return UInt8 is

      Data_R                : I2C.I2C_Data (1 .. 2) := (others => 0);

   begin
      Read_Register_As_Data_R_2 (RP_REGISTER => RP_DEVICE_ID_REVISION,
                                 This        => This,
                                 Status      => Status,
                                 Data_R      => Data_R);

      if Status.I2C_Status /= I2C.Ok then
         return 0;
      end if;
      return Data_R (1);
   end Get_Device_Id;

   function Get_Device_Revision
     (This      : in out MCP9808_I2C_Port;
      Status    : out Op_Status) return UInt8 is

      Data_R                : I2C.I2C_Data (1 .. 2) := (others => 0);

   begin
      Read_Register_As_Data_R_2 (RP_REGISTER => RP_DEVICE_ID_REVISION,
                                 This        => This,
                                 Status      => Status,
                                 Data_R      => Data_R);

      if Status.I2C_Status /= I2C.Ok then
         return 0;
      end if;
      return Data_R (2);
   end Get_Device_Revision;

   --========================================================================
   function Data_R_To_Celsius (Data_R : I2C_Data) return Celsius is

      MSB                   : UInt16;
      LSB                   : UInt16;
      Data_R_As_UInt16      : UInt16;
      Temperature           : TEMPERATURE_REGISTER;
      Temp_Integer          : Celsius;
      Temp_Fraction         : Celsius;
      Temp                  : Celsius;

      function From_UInt16_To_Temp_Register is
        new Ada.Unchecked_Conversion (UInt16, TEMPERATURE_REGISTER);

   begin
      MSB := UInt16 (Data_R (1));
      LSB := UInt16 (Data_R (2));
      --  calculate temperature in Celsius
      Data_R_As_UInt16 := Shift_Left (Value  => MSB,
                                      Amount => 8) or LSB;

      Temperature := From_UInt16_To_Temp_Register (Data_R_As_UInt16);
      Temp_Integer := Celsius (Temperature.TR_BINARY_NUMBER);
      Temp_Fraction := Celsius (Temperature.TR_BINARY_FRACTION)
        * Temperature_Divider_Fraction;
      Temp := Temp_Integer + Temp_Fraction;
      if Temperature.TR_SIGN = LESS_THAN_ZERO then
         Temp := -256.0 + Temp;
      end if;
      return Temp;
   end Data_R_To_Celsius;

   procedure Get_Any_Temperature
     (RP_REGISTER : UInt8;
      This        : in out MCP9808_I2C_Port;
      Status      : out Op_Status;
      Temp        : out Celsius) is

      Data_R : Data_R_2_Type;

   begin
      Read_Register_As_Data_R_2 (RP_REGISTER => RP_REGISTER,
                                 This        => This,
                                 Status      => Status,
                                 Data_R      => Data_R);
      if Status.I2C_Status /= I2C.Ok then
         return;
      end if;
      Temp := Data_R_To_Celsius (Data_R => Data_R);
   end Get_Any_Temperature;

   function Celsius_To_Register (Temp_In_Celsius : Celsius)
                                 return TEMPERATURE_REGISTER is

      Local_Celsius : Celsius := Temp_In_Celsius;
      Temp_Binary   : UInt16;
      Temp_Sign     : Bit;
      L_Register    : TEMPERATURE_REGISTER;

   begin
      L_Register.TR_SIGN := GREATER_OR_EQUAL_ZERO;

      if Local_Celsius < Celsius (0) then
         L_Register.TR_SIGN := LESS_THAN_ZERO;
         Local_Celsius := Celsius (Celsius'Last)
           + Local_Celsius
           + Celsius (0.25);
      end if;
      L_Register.TR_BINARY_NUMBER := Div_Integer_C (Local_Celsius);
      L_Register.TR_BINARY_FRACTION := Div_Fraction_C (Local_Celsius);
      return L_Register;
   end Celsius_To_Register;

   procedure Read_Register_As_Data_R_2
     (RP_REGISTER           : UInt8;
      This                  : in out MCP9808_I2C_Port;
      Status                : out Op_Status;
      Data_R                : out Data_R_2_Type) is
      Data_T                : constant I2C.I2C_Data (1 .. 1)
        := (1 => RP_REGISTER);
      I2C_Status            : I2C.I2C_Status;
   begin
      Status.I2C_Status := I2C.Ok;
      Status.E_Status := Ok;

      This.Port.all.Master_Transmit (Addr    => This.Address,
                                     Data    => Data_T,
                                     Status  => I2C_Status,
                                     Timeout => 1000);
      if I2C_Status /= I2C.Ok then
         Status.I2C_Status := I2C_Status;
         Status.E_Status := I2C_Not_Ok;
         return;
      end if;

      This.Port.all.Master_Receive (Addr    => This.Address,
                                    Data    => Data_R,
                                    Status  => I2C_Status,
                                    Timeout => 1000);

      if I2C_Status /= I2C.Ok then
         Status.I2C_Status := I2C_Status;
         Status.E_Status := I2C_Not_Ok;
         return;
      end if;
   end Read_Register_As_Data_R_2;

   function Div_Integer_C (V : Celsius) return UInt8
   is
      I : constant Integer := Integer (V);
   begin
      if Celsius (I) > V then
         return UInt8 (I - 1);
      else
         return UInt8 (I);
      end if;
   end Div_Integer_C;

   function Div_Fraction_C (V : Celsius) return UInt4
   is (UInt4 ((V - Celsius (Div_Integer_C (V))) * 2 ** 4));

   procedure Get_Config_Register (This   : in out MCP9808_I2C_Port;
                                  Status : out Op_Status;
                                  C_R    : out CONFIG_REGISTER) is

      Data_T                : constant I2C.I2C_Data (1 .. 1)
        := (1 => RP_CONFIG);
      Data_R                : I2C.I2C_Data (1 .. 2) := (others => 0);
      I2C_Status            : I2C.I2C_Status;

      function To_Config is
        new Ada.Unchecked_Conversion (UInt16, CONFIG_REGISTER);

   begin
      Status.I2C_Status := I2C.Ok;
      Status.E_Status := Ok;

      This.Port.all.Master_Transmit (Addr    => This.Address,
                                     Data    => Data_T,
                                     Status  => I2C_Status,
                                     Timeout => 1000);
      if I2C_Status /= I2C.Ok then
         Status.I2C_Status := I2C_Status;
         Status.E_Status := I2C_Not_Ok;
         return;
      end if;

      This.Port.all.Master_Receive (Addr    => This.Address,
                                    Data    => Data_R,
                                    Status  => I2C_Status,
                                    Timeout => 1000);

      if I2C_Status /= I2C.Ok then
         Status.I2C_Status := I2C_Status;
         Status.E_Status := I2C_Not_Ok;
         return;
      end if;

      C_R := To_Config (Shift_Left (UInt16 (Data_R (1)), 8)
                        or UInt16 (Data_R (2)));
   end Get_Config_Register;

end MCP9808_I2C;
