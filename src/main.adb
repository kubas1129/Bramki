with Ada.Text_IO, NT_Console, Helper,Ada.Strings.Unbounded;

use Ada.Text_IO, NT_Console,Helper,Ada.Strings.Unbounded;


procedure Main is


   -- GLOBAL VARIABLES --

   SimulationScreenInfo : FScreenInfo:= (X => 30,Y=> 9,PaddingLeft=>0,PaddingTop=>0);


   ScreenRefreshInterval : Duration := 1.0;


   -- PROTECTED

   protected SimulationDataProtect is
      procedure AddCar(Index: in FMatrixIndex; Value : in Character);
      procedure RemoveCar(CarPointer: in PFCar);
      procedure InitNodesData;

      function CheckIfCarExisted(Index : in FMatrixIndex) return Boolean;

      -- GETTERS&SETTERS
      function GetCarsData return TCarData.Vector;
      function GetNodesData return TNodeData.Vector;
      function GetLastAddCar return PFCar;
      function GetLastAddNode return PFNode;
   private
      CarsData : TCarData.Vector;
      NodesData : TNodeData.Vector;

      LastAddCar : PFCar := null; -- temporary
      LastAddNode : PFNode := null; -- temporary
   end SimulationDataProtect;


   protected body SimulationDataProtect is
      procedure AddCar(Index: in FMatrixIndex; Value : in Character) is
      begin
         -- Check if car on index position not exist already
         if(CheckIfCarExisted(Index => Index) = False) then
            CarsData.Append(New_Item => new FCar'(X        => Index.X,
                                                  Y        => Index.Y,
                                                  CarColor => White,
                                                  Sign     => 'X'));
            LastAddCar := CarsData.Last_Element;
         else
            LastAddCar := null;
         end if;

      end AddCar;

      procedure RemoveCar(CarPointer: in PFCar) is
      begin
         if(CarPointer /= null) then
            CarsData.Delete(Index => CarsData.Find_Index(CarPointer),
                            Count => 1);
         end if;
      end RemoveCar;

      procedure InitNodesData is
      begin
         NodesData.Append(new FNode'(X         => 0,
                                     Y         => 0,
                                     NodeColor => Green,
                                     Data      => To_Unbounded_String("__________")));
      end InitNodesData;

      function CheckIfCarExisted(Index : in FMatrixIndex) return Boolean is
      begin
         for I of CarsData loop
            if(I.X = Index.X and I.Y = Index.Y) then
               return True;
            end if;
         end loop;
         return False;
      end CheckIfCarExisted;

      -- GETTERS&SETTERS

      function GetCarsData return TCarData.Vector is
      begin
         return CarsData;
      end GetCarsData;

      function GetNodesData return TNodeData.Vector is
      begin
         return NodesData;
      end GetNodesData;

      function GetLastAddCar return PFCar is
      begin
         return LastAddCar;
      end GetLastAddCar;

      function GetLastAddNode return PFNode is
      begin
         return LastAddNode;
      end GetLastAddNode;

   end SimulationDataProtect;


    -- FUNCTIONS,PROCEDURES --



   procedure RefreshScreen is
   begin
      --Cars
      for I of SimulationDataProtect.GetCarsData loop
         Goto_XY(I.X,I.Y);
         Set_Foreground(I.CarColor);
         Put(I.Sign);
      end loop;
      --Nodes
      for I of SimulationDataProtect.GetNodesData loop
         Goto_XY(I.X,I.Y);
         Set_Foreground(I.NodeColor);
         Put(To_String(I.Data));
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
      entry Start;
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
      SimulationDataProtect.InitNodesData; -- init static nodes (not moveable)
      loop
         delay ScreenRefreshInterval;

      end loop;
   end Simulation;


   task body CarGenerator is
   begin
      accept Start;
      loop
         SimulationDataProtect.AddCar(Index => (X=>RandInteger(0,SimulationScreenInfo.X),Y=>RandInteger(0,SimulationScreenInfo.Y)),
                                      Value => 'X');
         delay 2.0;
      end loop;
   end CarGenerator;


   task body CarHandler is
   begin
      null;
   end CarHandler;


   -- MAIN --
   S: PFCar:= null;

begin

   --CarGenerator.Start;

   Simulation.Start;

   Screen.Start;

   Keyboard.Start;




end Main;
