with AUnit.Test_Cases;
with AUnit;

package Comparator_Tests is
   type Comparator_Test is new AUnit.Test_Cases.Test_Case with null record;

   overriding
   procedure Set_Up
     (T : in out Comparator_Test);

   overriding
   procedure Tear_Down
     (T : in out Comparator_Test);

   overriding
   procedure Register_Tests
     (T : in out Comparator_Test);

   overriding
   function Name
     (T : Comparator_Test)
      return AUnit.Message_String;
end Comparator_Tests;
