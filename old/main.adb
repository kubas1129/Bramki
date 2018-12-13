with Ada.Text_IO,Ada.Numerics.Real_Arrays;
use Ada.Text_IO,Ada.Numerics.Real_Arrays;

with TerminalDrawHandler;
use TerminalDrawHandler;

procedure Main is

   --Main variables

   TInfo : TerminalInfo :=(X => 11,
                         Y => 6);

   TScreen : CharMatrix(1..TInfo.X,1..TInfo.Y) := (others =>(others => 'X'));  -- Zmienna dzielona


   -- Main body

   task Simulation is
      entry Start;
   end Simulation;

   task DrawTask is
      entry Start;
      entry Draw;
   end DrawTask;


   task body Simulation is
      RandX : Integer := 1;
      RandY : Integer := 1;
   begin
      accept Start;
      loop
         RandX := RandInteger(1,10);
         RandY := RandInteger(1,6);
         TScreen(RandX,RandY) := 'o';
         DrawTask.Draw;
         delay 1.0;
      end loop;
      Put_Line("koniec");
   end Simulation;


   task body DrawTask is
   begin
      accept Start;
      loop
         select
            accept Draw do
               DrawOnTerminal(TScreen,TInfo);
            end Draw;
         end select;
      end loop;
   end DrawTask;



begin

   -- Starting tasks
   Simulation.Start;

   --Start Draw task
   DrawTask.Start;

end Main;
