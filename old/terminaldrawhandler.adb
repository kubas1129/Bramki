with Ada.Text_IO,Ada.Numerics.Discrete_Random;
use Ada.Text_IO;

package body TerminalDrawHandler is

   procedure DrawOnTerminal(T : in CharMatrix; I : in TerminalInfo) is
   begin
      Put(ASCII.ESC & "[2J");
      for Row in 1..I.Y loop
         New_Line(1);
         for Column in 1..I.X loop
            Put(T(Column,Row));
         end loop;
      end loop;
   end DrawOnTerminal;

   function RandInteger(A,B:Integer) return Integer is
      package Los_Liczby is new Ada.Numerics.Discrete_Random(Integer);
      use Los_Liczby;
      Gen : Los_Liczby.Generator;
   begin
      Reset(Gen);
      return (Random(Gen) mod B + A);
   end RandInteger;

end TerminalDrawHandler;
