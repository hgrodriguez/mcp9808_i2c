with Critical_Tests;
with Lower_Tests;
with Resolution_Tests;
with Upper_Tests;

package body Test_Suite is
   Result : aliased AUnit.Test_Suites.Test_Suite;

   Critical_Case : aliased Critical_Tests.Critical_Test;
   Lower_Case    : aliased Lower_Tests.Lower_Test;
   Resolution_Case : aliased Resolution_Tests.Resolution_Test;
   Upper_Case    : aliased Upper_Tests.Upper_Test;

   function Suite
      return AUnit.Test_Suites.Access_Test_Suite
   is
      use AUnit.Test_Suites;
   begin
      Add_Test (Result'Access, Critical_Case'Access);
      Add_Test (Result'Access, Lower_Case'Access);
      Add_Test (Result'Access, Resolution_Case'Access);
      Add_Test (Result'Access, Upper_Case'Access);
      return Result'Access;
   end Suite;
end Test_Suite;
