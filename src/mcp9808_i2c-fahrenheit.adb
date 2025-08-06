--===========================================================================
--
--  This package is implementing the capability for the
--  temperature sensor MC9808 using the I2C protocol.
--  Using Fahrenheit.
--
--===========================================================================
--
--  Copyright 2025 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--

package body MCP9808_I2C.Fahrenheit is

   function Celsius_2_Fahrenheit (C : Celsius) return Fahrenheit;
   function Fahrenheit_2_Celsius (F : Fahrenheit) return Celsius;

   function Div_Integer_F (V : Fahrenheit) return Integer;
   function Div_Fraction_F (V : Fahrenheit) return Integer;

   procedure Set_Upper_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : Fahrenheit) is

      Temp_C : Celsius;

   begin
      Temp_C := Fahrenheit_2_Celsius (Temp);
      Set_Any_Temperature (RP_REGISTER => RP_T_UPPER,
                           This        => This,
                           Status      => Status,
                           Temp        => Temp_C);
   end Set_Upper_Temperature;

   procedure Get_Upper_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : out Fahrenheit) is

      Temp_C : Celsius;

   begin
      Set_Any_Temperature (RP_REGISTER => RP_T_UPPER,
                           This        => This,
                           Status      => Status,
                           Temp        => Temp_C);
      Temp := Celsius_2_Fahrenheit (Temp_C);
   end Get_Upper_Temperature;

   procedure Set_Lower_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : Fahrenheit) is

      Temp_C : Celsius;

   begin
      Temp_C := Fahrenheit_2_Celsius (Temp);
      Set_Any_Temperature (RP_REGISTER => RP_T_LOWER,
                           This        => This,
                           Status      => Status,
                           Temp        => Temp_C);
   end Set_Lower_Temperature;

   procedure Get_Lower_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : out Fahrenheit) is

      Temp_C : Celsius;

   begin
      Set_Any_Temperature (RP_REGISTER => RP_T_LOWER,
                           This        => This,
                           Status      => Status,
                           Temp        => Temp_C);
      Temp := Celsius_2_Fahrenheit (Temp_C);
   end Get_Lower_Temperature;

   procedure Set_Critical_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : Fahrenheit) is

      Temp_C : Celsius;

   begin
      Temp_C := Fahrenheit_2_Celsius (Temp);
      Set_Any_Temperature (RP_REGISTER => RP_T_CRIT,
                           This        => This,
                           Status      => Status,
                           Temp        => Temp_C);
   end Set_Critical_Temperature;

   procedure Get_Critical_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : out Fahrenheit) is

      Temp_C : Celsius;

   begin
      Set_Any_Temperature (RP_REGISTER => RP_T_CRIT,
                           This        => This,
                           Status      => Status,
                           Temp        => Temp_C);
      Temp := Celsius_2_Fahrenheit (Temp_C);
   end Get_Critical_Temperature;

   procedure Get_Ambient_Temperature
     (This     : in out MCP9808_I2C_Port;
      Status   : out Op_Status;
      A_Status : out Ambient_Status;
      Temp     : out Fahrenheit) is

      Temp_C : Celsius;

   begin
      Get_Ambient_Temperature (This        => This,
                               Status      => Status,
                               A_Status => A_Status,
                           Temp        => Temp_C);
      Temp := Celsius_2_Fahrenheit (Temp_C);
   end Get_Ambient_Temperature;

   function Celsius_2_Fahrenheit (C : Celsius) return Fahrenheit is
      --  Celsius to Fahrenheit:
      --  °F = (°C * 9/5) + 32 or, equivalently, °F = (°C * 1.8) + 32
      C_I    : constant Integer := Integer (Div_Integer_C (C));
      C_R    : constant Integer := Integer (Div_Fraction_C (C));
      F_I    : Integer;
      F_R    : Integer;
      F_Rest : constant Fahrenheit := Fahrenheit (32);
      F_Temp : Fahrenheit;
   begin
      F_I := Integer (C_I * 9 / 5);
      F_R := Integer (C_R * 9 / 5);

      F_Temp := Fahrenheit (F_I)
        + Fahrenheit (F_R) * Temperature_Divider_Fraction;
      F_Temp := F_Temp + F_Rest;

      return F_Temp;
   end Celsius_2_Fahrenheit;

   function Fahrenheit_2_Celsius (F : Fahrenheit) return Celsius is
      --  Fahrenheit to Celsius
      --  °C = (°F - 32) * 5/9
      F_I    : constant Integer := Div_Integer_F (F);
      F_R    : constant Integer := Div_Fraction_F (F);
      C_I    : Integer;
      C_R    : Integer;
      C_Rest : constant Celsius := Celsius (32 * 5 / 9);
      C_Temp : Celsius;
   begin
      C_I := Integer (F_I * 5 / 9);
      C_R := Integer (F_R * 5 / 9);

      C_Temp := Celsius (C_I) + Celsius (C_R) * Temperature_Divider_Fraction;
      C_Temp := C_Temp - C_Rest;

      return C_Temp;
   end Fahrenheit_2_Celsius;

   function Div_Integer_F (V : Fahrenheit) return Integer
   is
      I : constant Integer := Integer (V);
   begin
      if Fahrenheit (I) > V then
         return Integer (I - 1);
      else
         return I;
      end if;
   end Div_Integer_F;

   function Div_Fraction_F (V : Fahrenheit) return Integer
   is (Integer ((V - Fahrenheit (Div_Integer_F (V))) * 2 ** 4));

end MCP9808_I2C.Fahrenheit;
