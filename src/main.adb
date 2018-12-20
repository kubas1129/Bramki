with Ada.Text_IO, NT_Console, Helper;

use Ada.Text_IO, NT_Console,Helper;


procedure Main is


   -- GLOBAL VARIABLES --

   SimulationScreenInfo : FScreenInfo:= (X => 30,Y=> 9,PaddingLeft=>0,PaddingTop=>0);


   ScreenRefreshInterval : Duration := 1.0;


   -- PROTECTED

   protected SimulationDataProtect is
      procedure AddCar(Index: in FMatrixIndex; Value : in Character);
      procedure RemoveCar(Index: in FMatrixIndex);
      procedure InitNodesData;
      function GetCarsData return TCarData.Vector;
      function GetNodesData return TNodeData.Vector;
   private
      --ScreenData : TScreenData(0..SimulationScreenInfo.X,0..SimulationScreenInfo.Y) := (others => (others => 'X'));
      CarsData : TCarData.Vector;
      NodesData : TNodeData.Vector;
   end SimulationDataProtect;


   protected body SimulationDataProtect is
      procedure AddCar(Index: in FMatrixIndex; Value : in Character) is
         ToAdd : PFCar := new FCar'(X        => Index.X,
                                   Y        => Index.Y,
                                   CarColor => White,
                                   Sign     => Value);
      begin
         CarsData.Append(New_Item => ToAdd);
      end AddCar;

      procedure RemoveCar(Index: in FMatrixIndex) is
      begin
         null;
      end RemoveCar;

      procedure InitNodesData is
      begin
         null;
      end InitNodesData;

      function GetCarsData return TCarData.Vector is
      begin
         return CarsData;
      end GetCarsData;

      function GetNodesData return TNodeData.Vector is
      begin
         return NodesData;
      end GetNodesData;

   end SimulationDataProtect;


    -- FUNCTIONS,PROCEDURES --


   procedure RefreshScreen is
      Tmp : TCarData.Vector := SimulationDataProtect.GetCarsData;
   begin
      for I of Tmp loop
         Goto_XY(I.X,I.Y);
         Set_Foreground(I.CarColor);
         Put(I.Sign);
      end loop;
   end RefreshScreen;


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
            RefreshScreen;
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

   --Simulation.Start;

   --Screen.Start;

   --Keyboard.Start;

   SimulationDataProtect.AddCar(Index => (X=>0,Y=>0),Value => 'X');

   Put_Line(SimulationDataProtect.GetCarsData.Length'Img & " i " & SimulationDataProtect.GetCarsData.Element(0).Sign);


end Main;
