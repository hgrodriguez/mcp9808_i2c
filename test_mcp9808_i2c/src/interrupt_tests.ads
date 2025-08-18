with AUnit.Test_Cases;
with AUnit;

package Interrupt_Tests is
   type Interrupt_Test is new AUnit.Test_Cases.Test_Case with null record;

   overriding
   procedure Set_Up
     (T : in out Interrupt_Test);

   overriding
   procedure Tear_Down
     (T : in out Interrupt_Test);

   overriding
   procedure Register_Tests
     (T : in out Interrupt_Test);

   overriding
   function Name
     (T : Interrupt_Test)
      return AUnit.Message_String;
end Interrupt_Tests;
