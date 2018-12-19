with Ada.Text_IO, NT_Console, Helper;

use Ada.Text_IO, NT_Console,Helper;


procedure Main is


   -- GLOBAL VARIABLES --

   ScreenInfo : FScreenInfo:= (X => 3,Y=> 3);

   ScreenRefreshInterval : Duration := 1.0;


   -- FUNCTIONS,PROCEDURES --


   procedure RefreshScreen(S: in TScreenData) is
   begin
      for X in 0..ScreenInfo.X loop
         for Y in 0..ScreenInfo.Y loop
            Goto_XY(X,Y);
            Put(S(X,Y));
         end loop;
      end loop;
   end RefreshScreen;


   -- PROTECTED

   protected ScreenDataProtect is
      procedure SetValue(Index: in MatrixIndex; Value : in Character);
      procedure Remove(Index: in MatrixIndex);
      function GetScreenData return TScreenData;
   private
      ScreenData : TScreenData(0..ScreenInfo.X,0..ScreenInfo.Y) := (others => (others => 'X'));
   end ScreenDataProtect;


   protected body ScreenDataProtect is
      procedure SetValue(Index: in MatrixIndex; Value : in Character) is
      begin
         ScreenData(Index.X,Index.Y) := Value;
      end SetValue;

      procedure Remove(Index: in MatrixIndex) is
      begin
         null;
      end Remove;

      function GetScreenData return TScreenData is
      begin
         return ScreenData;
      end GetScreenData;

   end ScreenDataProtect;


   -- TASKS DECLARATIONS --


   task Screen is
      entry Start;
   end Screen;

   task Keyboard is
      entry Start;
   end Keyboard;

   task Simulation is
      entry Start;
   end Simulation;

   task CarGenerator is
   end CarGenerator;

   task CarHandler is
   end CarHandler;


   -- TASKS BODIES --


   task body Screen is
   begin
      accept Start  do
         loop
            Clear_Screen(Blue);
            RefreshScreen(ScreenDataProtect.GetScreenData);
            delay ScreenRefreshInterval;
         end loop;
      end Start;
   end Screen;


   task body Keyboard is
   begin
      accept Start  do
         loop
            Set_Cursor(True);
            delay ScreenRefreshInterval;
            Set_Cursor(False);
         end loop;
      end Start;
   end Keyboard;


   task body Simulation is
   begin
      accept Start;
      loop
         delay ScreenRefreshInterval;
         ScreenDataProtect.SetValue(Index => (1,1),
                                 Value => 'O');
      end loop;
   end Simulation;


   task body CarGenerator is
   begin
      null;
   end CarGenerator;


   task body CarHandler is
   begin
      null;
   end CarHandler;


   -- MAIN --

begin

   Simulation.Start;

   Screen.Start;

   Keyboard.Start;


end Main;
