with Ada.Text_IO,Ada.Numerics.Discrete_Random;
use Ada.Text_IO;

package body Helper is

   function RandInteger(A,B:Integer) return Integer is
      package Los_Liczby is new Ada.Numerics.Discrete_Random(Integer);
      use Los_Liczby;
      Gen : Los_Liczby.Generator;
   begin
      Reset(Gen);
      return (Random(Gen) mod B + A);
   end RandInteger;

end Helper;
