with AUnit.Test_Cases;
with AUnit;

package AmbientStatus_Tests is
   type AmbientStatus_Test is new AUnit.Test_Cases.Test_Case with null record;

   overriding
   procedure Set_Up
     (T : in out AmbientStatus_Test);

   overriding
   procedure Tear_Down
     (T : in out AmbientStatus_Test);

   overriding
   procedure Register_Tests
     (T : in out AmbientStatus_Test);

   overriding
   function Name
     (T : AmbientStatus_Test)
      return AUnit.Message_String;
end AmbientStatus_Tests;
