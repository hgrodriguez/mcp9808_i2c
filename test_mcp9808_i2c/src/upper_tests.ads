with AUnit.Test_Cases;
with AUnit;

package Upper_Tests is

   type Upper_Test is new AUnit.Test_Cases.Test_Case with null record;

   overriding
   procedure Set_Up
     (T : in out Upper_Test);

   overriding
   procedure Register_Tests
      (T : in out Upper_Test);

   overriding
   function Name
      (T : Upper_Test)
      return AUnit.Message_String;

end Upper_Tests;
