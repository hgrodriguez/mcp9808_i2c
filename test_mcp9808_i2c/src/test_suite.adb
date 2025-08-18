with Comparator_Tests;
with Critical_Tests;
with Hysteresis_Tests;
with Interrupt_Tests;
with Lower_Tests;
with Resolution_Tests;
with Upper_Tests;

with Shutdown_Wakeup_Tests;

package body Test_Suite is
   Result : aliased AUnit.Test_Suites.Test_Suite;

   Comparator_Case      : aliased Comparator_Tests.Comparator_Test;
   Critical_Case        : aliased Critical_Tests.Critical_Test;
   Hysteresis_Case      : aliased Hysteresis_Tests.Hysteresis_Test;
   Interrupt_Case       : aliased Interrupt_Tests.Interrupt_Test;
   Lower_Case           : aliased Lower_Tests.Lower_Test;
   Resolution_Case      : aliased Resolution_Tests.Resolution_Test;
   Upper_Case           : aliased Upper_Tests.Upper_Test;
   Shutdown_Wakeup_Case : aliased Shutdown_Wakeup_Tests.Shutdown_Wakeup_Test;

   function Suite
      return AUnit.Test_Suites.Access_Test_Suite
   is
      use AUnit.Test_Suites;
   begin
      Add_Test (Result'Access, Comparator_Case'Access);
      Add_Test (Result'Access, Critical_Case'Access);
      Add_Test (Result'Access, Hysteresis_Case'Access);
      Add_Test (Result'Access, Interrupt_Case'Access);
      Add_Test (Result'Access, Lower_Case'Access);
      Add_Test (Result'Access, Resolution_Case'Access);
      Add_Test (Result'Access, Upper_Case'Access);
      Add_Test (Result'Access, Shutdown_Wakeup_Case'Access);
      return Result'Access;
   end Suite;
end Test_Suite;
