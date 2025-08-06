with AUnit.Test_Cases;
with AUnit;

package Lower_Tests is

   type Lower_Test is new AUnit.Test_Cases.Test_Case with null record;

   overriding
   procedure Set_Up
     (T : in out Lower_Test);

   overriding
   procedure Register_Tests
     (T : in out Lower_Test);

   overriding
   function Name
     (T : Lower_Test)
       return AUnit.Message_String;

end Lower_Tests;
