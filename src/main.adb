with Ada.Text_IO, NT_Console, Helper,Ada.Strings.Unbounded,Ada.Strings.Fixed;

use Ada.Text_IO, NT_Console,Helper,Ada.Strings.Unbounded,Ada.Strings.Fixed;


procedure Main is


   -- GLOBAL VARIABLES --

   SimulationScreenInfo : FScreenInfo:= (X => 30,Y=> 9,PaddingLeft=>24,PaddingTop=>7); --WindowSize=79x24


   ScreenRefreshInterval : Duration := 1.0;

   Log : Unbounded_String;

   -- PROTECTED

   protected SimulationDataProtect is
      procedure AddCar(Index: in FMatrixIndex; Value : in Character; Dir : in EDirection);
      procedure RemoveCar(CarPointer: in PFCar);
      procedure InitNodesData;
      procedure InitTextsData;
      procedure UpdateTextsData;
      procedure MoveCars;


      function CheckIfCarExisted(Index : in FMatrixIndex) return Boolean;
      function GetCarPointer(Index : in FMatrixIndex) return PFCar;

      -- GETTERS&SETTERS
      function GetCarsData return TCarData.Vector;
      function GetNodesData return TNodeData.Vector;
      function GetTextsData return TTextData.Vector;
      function GetLastAddCar return PFCar;
      function GetLastAddNode return PFNode;
   private
      CarsData : TCarData.Vector;
      NodesData : TNodeData.Vector;
      TextsData : TTextData.Vector;

      LastAddCar : PFCar := null; -- temporary
      LastAddNode : PFNode := null; -- temporary
   end SimulationDataProtect;


   protected body SimulationDataProtect is
      procedure AddCar(Index: in FMatrixIndex; Value : in Character; Dir : in EDirection) is
      begin
         -- Check if car on index position not exist already
         if(CheckIfCarExisted(Index => Index) = False) then
            CarsData.Append(New_Item => new FCar'(X         => Index.X,
                                                  Y         => Index.Y,
                                                  CarColor  => White,
                                                  Sign      => 'X',
                                                  Direction => Dir));
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
         A : constant String := 30*'_';
         B : constant String := 30*'*';
      begin
         --Horizontal
         NodesData.Append(new FNode'(X         => 0,
                                     Y         => 0,
                                     NodeColor => Green,
                                     Data      => To_Unbounded_String(A)));

         NodesData.Append(new FNode'(X         => 0,
                                     Y         => 4,
                                     NodeColor => Green,
                                     Data      => To_Unbounded_String(B)));

         NodesData.Append(new FNode'(X         => 0,
                                     Y         => 5,
                                     NodeColor => Green,
                                     Data      => To_Unbounded_String(B)));

         NodesData.Append(new FNode'(X         => 0,
                                     Y         => 9,
                                     NodeColor => Green,
                                     Data      => To_Unbounded_String(A)));

         --Vertical
         for J in 1..9 loop
            NodesData.Append(new FNode'(X         => 0,
                                        Y         => J,
                                        NodeColor => Green,
                                        Data      => To_Unbounded_String("|")));
            NodesData.Append(new FNode'(X         => 30,
                                        Y         => J,
                                        NodeColor => Green,
                                        Data      => To_Unbounded_String("|")));
            if (J >= 1 and J <= 3) or (J >= 6 and J < 9) then
               NodesData.Append(new FNode'(X         => 15,
                                           Y         => J,
                                           NodeColor => Green,
                                           Data      => To_Unbounded_String("H")));
            end if;
         end loop;

      end InitNodesData;

      procedure InitTextsData is
      begin
         -- INDEX=0
         TextsData.Append(new FText'(X         => 8+SimulationScreenInfo.PaddingLeft,
                                     Y         => 4,
                                     TextColor => White,
                                     Text      => To_Unbounded_String("CAR SIMULATION")));

         -- INDEX=1
         TextsData.Append(new FText'(X         => 8+SimulationScreenInfo.PaddingLeft,
                                     Y         => SimulationScreenInfo.PaddingTop+SimulationScreenInfo.Y + 4,
                                     TextColor => White,
                                     Text      => To_Unbounded_String("LOG: ") & Log));
      end InitTextsData;

      procedure UpdateTextsData is
      begin
         --Update log values
         TextsData.Element(1).Text := To_Unbounded_String("LOG: ") & Log;
      end UpdateTextsData;

      procedure MoveCars is
      begin
         for I of CarsData loop
            if(I.Direction = D_LEFT) then
               if(CheckIfCarExisted(Index => (I.X-1,I.Y)) = False) then
                  I.X := I.X -1;
               end if;
            else
               if(CheckIfCarExisted(Index => (I.X+1,I.Y)) = False) then
                  I.X := I.X +1;
               end if;
            end if;
         end loop;
      exception
         when PROGRAM_ERROR =>
            Put("SPECIFY");
         when others =>
            Put("OTHERS");
      end MoveCars;

      function CheckIfCarExisted(Index : in FMatrixIndex) return Boolean is
      begin
         for I of CarsData loop
            if(I.X = Index.X and I.Y = Index.Y) then
               return True;
            end if;
         end loop;
         return False;
      end CheckIfCarExisted;

      function GetCarPointer(Index : in FMatrixIndex) return PFCar is
      begin
         for I of CarsData loop
            if(I.X = Index.X and I.Y = Index.Y) then
               return I;
            end if;
         end loop;
         return null;
      end GetCarPointer;

      -- GETTERS&SETTERS

      function GetCarsData return TCarData.Vector is
      begin
         return CarsData;
      end GetCarsData;

      function GetNodesData return TNodeData.Vector is
      begin
         return NodesData;
      end GetNodesData;

      function GetTextsData return TTextData.Vector is
      begin
         return TextsData;
      end GetTextsData;

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
         Goto_XY(I.X+SimulationScreenInfo.PaddingLeft,I.Y+SimulationScreenInfo.PaddingTop);
         Set_Foreground(I.CarColor);
         Put(I.Sign);
      end loop;
      --Nodes
      for I of SimulationDataProtect.GetNodesData loop
         Goto_XY(I.X+SimulationScreenInfo.PaddingLeft,I.Y+SimulationScreenInfo.PaddingTop);
         Set_Foreground(I.NodeColor);
         Put(To_String(I.Data));
      end loop;
      --Texts
      for I of SimulationDataProtect.GetTextsData loop
         Goto_XY(I.X,I.Y);
         Set_Foreground(I.TextColor);
         Put(To_String(I.Text));
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
      entry Start;
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
      SimulationDataProtect.InitTextsData;
      loop
         delay ScreenRefreshInterval;
         SimulationDataProtect.UpdateTextsData;
         SimulationDataProtect.MoveCars;
      end loop;
   end Simulation;


   task body CarGenerator is
      CarPositionY : Integer := 0;
      Temp : Integer := 0;
   begin
      accept Start;
      loop
         Temp := Temp +1;
         if(RandInteger(0,1) = 0) then
            -- Generate Left move
            CarPositionY := RandInteger(1,3);
            SimulationDataProtect.AddCar(Index => (X=>29,Y=>CarPositionY),
                                         Value => 'X',Dir => D_LEFT);
         else
            -- Generate Right move
            CarPositionY := RandInteger(6,8);
            SimulationDataProtect.AddCar(Index => (X=>1,Y=>CarPositionY),
                                         Value => 'X',Dir => D_RIGHT);
         end if;

         delay 2.0;
      end loop;
   end CarGenerator;


   task body CarHandler is
   begin
      accept Start;
      loop
         --Car remover
         for I of SimulationDataProtect.GetCarsData loop
            if(I.Direction = D_LEFT and I.X <= 0) or (I.Direction = D_RIGHT and I.X >= 30) then
               SimulationDataProtect.RemoveCar(SimulationDataProtect.GetCarPointer((X=>I.X,Y=>I.Y)));
            end if;
         end loop;
         delay ScreenRefreshInterval/2;
      end loop;
   end CarHandler;


   -- MAIN --

begin

   CarGenerator.Start;

   CarHandler.Start;

   Simulation.Start;

   Screen.Start;

   Keyboard.Start;



end Main;
