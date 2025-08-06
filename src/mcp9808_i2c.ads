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

with HAL; use HAL;
with HAL.I2C; use HAL.I2C;

package MCP9808_I2C is

   ---------------------------------------------------------------------------
   --  This is the default I2C address of the MCP 9808.
   I2C_DEFAULT_ADDRESS : constant HAL.I2C.I2C_Address := 2#0011_0000#;

   ---------------------------------------------------------------------------
   --  our type for the sensor
   type MCP9808_I2C_Port is private;

   ---------------------------------------------------------------------------
   --  MCP9808 status of last operation.
   type MCP9808_Status is (
                          --  all operations were successful
                          Ok,
                          --  Is set,
                          --  if anything is not OK with the I2C operation
                          I2C_Not_Ok
                          );

   ---------------------------------------------------------------------------
   --  Operation Status for every call
   type Op_Status is record
      I2C_Status : HAL.I2C.I2C_Status;
      E_Status   : MCP9808_Status;
   end record;

   procedure Configure
     (This      : in out MCP9808_I2C_Port;
      Port      : Any_I2C_Port;
      Address   : I2C_Address := I2C_DEFAULT_ADDRESS;
--    Alert_Pin : not null HAL.GPIO.Any_GPIO_Point;
      Status    : out Op_Status);

   ---------------------------------------------------------------------------
   --  Defines the possible resolutions the sensor is capable of.
   type Resolution is (Half,      -- +0.5 C
                       Quarter,   -- +0.25 C
                       Eighth,    -- +0.125 C
                       Sixteenth  -- +0.0625 C
                      );
   for Resolution use
     (Half => 2#00#,
      Quarter => 2#01#,
      Eighth => 2#10#,
      Sixteenth => 2#11#
     );
   for Resolution'Size use UInt8'Size;

   procedure Set_Resolution
     (This   : in out MCP9808_I2C_Port;
      Res    : Resolution;
      Status : out Op_Status);

   procedure Get_Resolution
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Res    : out Resolution);

   --------------------------------------------------------------------------
   --  Temperature definitions
   --  the range of degrees, which represent the register values possible
   Temperature_Divider_Fraction : constant := 1.0 / (2.0 ** 4);
   --  Celsius definition
   type Celsius is delta Temperature_Divider_Fraction
   --  this is the range, the registers in the sensor can represent
   range -256.0 .. (2.0 ** 8) - Temperature_Divider_Fraction;
   --  this is the range, what the sensor can read
   subtype Temperature_Range is Celsius range -20.0 .. +100.0;

   --------------------------------------------------------------------------
   --  Upper Temperature Limit procedures
   procedure Set_Upper_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : Celsius);

   procedure Get_Upper_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : out Celsius);

   --------------------------------------------------------------------------
   --  Lower Temperature Limit procedures
   procedure Set_Lower_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : Celsius);

   procedure Get_Lower_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : out Celsius);

   --------------------------------------------------------------------------
   --  Critical Temperature Limit procedures
   procedure Set_Critical_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : Celsius);

   procedure Get_Critical_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      Temp   : out Celsius);

   ---------------------------------------------------------------------------
   --  Flags for the ambient temperature values.
   --  GorE_Upper:
   --     ambient temperature is greater or equal the upper limit
   --  Less_Than_Lower:
   --     ambient temperature is lower than the lower limit
   --  GorE_Critical:
   --     ambient temperature is greater or equal the critical limit
   type Ambient_Status is record
      GorE_Upper         : Boolean;
      Less_Than_Lower    : Boolean;
      GorE_Critical      : Boolean;
   end record;

   procedure Get_Ambient_Temperature
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status;
      A_Status : out Ambient_Status;
      Temp   : out Celsius);

   ---------------------------------------------------------------------------
   --  Functions, which return some internal chip data.
   function Get_Manufacturer_Id
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status) return UInt16;

   function Get_Device_Id
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status) return UInt8;

   function Get_Device_Revision
     (This   : in out MCP9808_I2C_Port;
      Status : out Op_Status) return UInt8;

private
   type MCP9808_I2C_Port
   is record
      --  the I2C port where the temperature sensor is connected to
      Port      : Any_I2C_Port;
      --  the I2C address of the temperature sensor on Port
      Address   : I2C_Address;
      --  the GPIO pin to be used for the alerting
      --  Alert_Pin : HAL.GPIO.Any_GPIO_Point;
   end record;

   --------------------------------------------------------------------------
   --  all register pointers available
   --  this is reserved for future use.
   --  RP_RFU                 : constant UInt8 := 2#0000_0000#;

   RP_CONFIG              : constant UInt8 := 2#0000_0001#;
   pragma Warnings (Off, RP_CONFIG);

   RP_T_UPPER             : constant UInt8 := 2#0000_0010#;
   RP_T_LOWER             : constant UInt8 := 2#0000_0011#;
   RP_T_CRIT              : constant UInt8 := 2#0000_0100#;
   RP_T_A                 : constant UInt8 := 2#0000_0101#;
   RP_MANUFACTURER_ID     : constant UInt8 := 2#0000_0110#;
   RP_DEVICE_ID_REVISION  : constant UInt8 := 2#0000_0111#;
   RP_RESOLUTION          : constant UInt8 := 2#0000_1000#;

   function Div_Integer_C (V : Celsius) return UInt8;
   function Div_Fraction_C (V : Celsius) return UInt4;

   procedure Set_Any_Temperature
     (RP_REGISTER : UInt8;
      This        : in out MCP9808_I2C_Port;
      Status      : out Op_Status;
      Temp        : Celsius);

end MCP9808_I2C;
