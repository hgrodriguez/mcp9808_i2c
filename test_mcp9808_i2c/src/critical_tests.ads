with AUnit.Test_Cases;
with AUnit;

package Critical_Tests is
   type Critical_Test is new AUnit.Test_Cases.Test_Case with null record;

   overriding
   procedure Set_Up
     (T : in out Critical_Test);

   overriding
   procedure Register_Tests
     (T : in out Critical_Test);

   overriding
   function Name
     (T : Critical_Test)
      return AUnit.Message_String;
end Critical_Tests;
