with AUnit.Test_Cases;
with AUnit;

package Shutdown_Wakeup_Tests is

   type Shutdown_Wakeup_Test is
     new AUnit.Test_Cases.Test_Case with null record;

   overriding
   procedure Set_Up
     (T : in out Shutdown_Wakeup_Test);

   overriding
   procedure Register_Tests
     (T : in out Shutdown_Wakeup_Test);

   overriding
   function Name
     (T : Shutdown_Wakeup_Test)
      return AUnit.Message_String;

end Shutdown_Wakeup_Tests;
