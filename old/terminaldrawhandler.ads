

package TerminalDrawHandler is

   -----Types and records-----
   
   type CharMatrix is array (Natural range <>, Natural range <>) of Character;
   
   type TerminalInfo is record 
      X : Natural := 11;
      Y : Natural := 6;
   end record;
   
   
   -----Methods------ 
   
   -- Drawing on terminal screen
   procedure DrawOnTerminal(T : in CharMatrix; I : in TerminalInfo);
   
   -- Rand integer from range A-B
   function RandInteger(A,B:Integer) return Integer;

end TerminalDrawHandler;
