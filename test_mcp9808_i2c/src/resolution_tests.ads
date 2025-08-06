with AUnit.Test_Cases;
with AUnit;

package Resolution_Tests is
   type Resolution_Test is new AUnit.Test_Cases.Test_Case with null record;

   overriding
   procedure Set_Up
     (T : in out Resolution_Test);

   overriding
   procedure Register_Tests
     (T : in out Resolution_Test);

   overriding
   function Name
     (T : Resolution_Test)
      return AUnit.Message_String;
end Resolution_Tests;
