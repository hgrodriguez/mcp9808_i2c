with AUnit.Reporter.Text;
with AUnit.Run;
with Ada.Text_IO;
with Test_Suite;

procedure Test_Mcp9808_I2c is

   procedure Run is new AUnit.Run.Test_Runner (Test_Suite.Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;

begin
   Ada.Text_IO.Put_Line ("Testing...");
   Run (Reporter);
   loop
      null;
   end loop;
end Test_Mcp9808_I2c;
