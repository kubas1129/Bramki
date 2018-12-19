

package Helper is

   -----Types and records-----
   
    type TScreenData is array (Natural range<>,Natural range<>) of Character;
   
   type FScreenInfo is record
      X,Y: Natural := 0;
   end record;
   
   type MatrixIndex is record
      X,Y: Natural := 0;
   end record;
      
   
   -----Methods------ 
   
   -- Rand integer from range A-B
   function RandInteger(A,B:Integer) return Integer;

end Helper;
