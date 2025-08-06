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

package MCP9808_I2C.Fahrenheit is

   --  Fahrenheit definition
   type Fahrenheit is delta Temperature_Divider_Fraction
   range -429.0 .. 493.0 - Temperature_Divider_Fraction;

   procedure Set_Upper_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : Fahrenheit);

   procedure Get_Upper_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : out Fahrenheit);

   procedure Set_Lower_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : Fahrenheit);

   procedure Get_Lower_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : out Fahrenheit);

   procedure Set_Critical_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : Fahrenheit);

   procedure Get_Critical_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : out Fahrenheit);

   procedure Get_Ambient_Temperature
     (This     : in out MCP9808_I2C_Port;
      Status   : out Op_Status;
      A_Status : out Ambient_Status;
      Temp     : out Fahrenheit);

end MCP9808_I2C.Fahrenheit;
