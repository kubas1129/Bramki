with Ada.Text_IO,Ada.Numerics.Discrete_Random,Ada.Numerics.Float_Random;
use Ada.Text_IO;


package body Helper is

   function RandInteger(A,B:Natural) return Natural is
      subtype Rand_Range is Natural range A..B;
      package Rand_Int is new Ada.Numerics.Discrete_Random(Rand_Range);
      use Rand_Int;
      G : Generator;
   begin
      Reset(G);
      return (Random(G));
   end RandInteger;


   function RandDuration(A,B: Float) return Duration is
      use Ada.Numerics.Float_Random;
      Z : Generator;
   begin
      Reset(Z);
      return Duration(Random(Z)*B + A);
   end RandDuration;



end Helper;
