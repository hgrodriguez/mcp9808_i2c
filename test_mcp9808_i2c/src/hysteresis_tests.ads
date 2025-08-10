with AUnit.Test_Cases;
with AUnit;

package Hysteresis_Tests is

   type Hysteresis_Test is new AUnit.Test_Cases.Test_Case with null record;

   overriding
   procedure Set_Up
     (T : in out Hysteresis_Test);

   overriding
   procedure Register_Tests
     (T : in out Hysteresis_Test);

   overriding
   function Name
     (T : Hysteresis_Test)
       return AUnit.Message_String;

end Hysteresis_Tests;
