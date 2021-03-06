with Ada.Text_IO, NT_Console, Helper,Ada.Strings.Unbounded,Ada.Strings.Fixed;

use Ada.Text_IO, NT_Console,Helper,Ada.Strings.Unbounded,Ada.Strings.Fixed;

with GNAT.OS_Lib;




-- obiekty cykliczne


procedure Main is


   -- GLOBAL VARIABLES --

   SimulationScreenInfo : FScreenInfo:= (X => 30,Y=> 9,PaddingLeft=>24,PaddingTop=>7); --WindowSize=79x24


   ScreenRefreshInterval : Duration := 1.0;

   -- Log variable
   Log : Unbounded_String;

   -- Predefine Gate task
   task type Gate is
      entry Start;
      entry HandleCar(CX,CY : in Natural);
   end Gate;

   -- Gates handler array
   type Gates is array (1..6) of Gate;
   GatesHandler : Gates;


   -- PROTECTED

   protected SimulationDataProtect is
      procedure AddCar(Index: in FMatrixIndex; CarSign : in Character; Dir : in EDirection; CarT: in ECarType; MoneyValue : in Integer; CarColorVal : in Color_Type);
      procedure RemoveCar(CarPointer: in PFCar);
      procedure InitNodesData;
      procedure InitTextsData;
      procedure UpdateTextsData;
      procedure UpdateGatesData;
      procedure MoveCars;
      procedure GateMoveCar(X,Y : Natural);
      procedure SetGateState(GateIndex : Positive; Value : Boolean);
      procedure SetCarGenerationSpeed(Value : in Positive);
      procedure AddCollectedMoney(Value : in Integer);


      function CheckIfCarExisted(Index : in FMatrixIndex) return Boolean;
      function GetCarPointer(Index : in FMatrixIndex) return PFCar;
      function GetGateState(GateIndex : in Positive) return Boolean;

      -- GETTERS&SETTERS
      function GetCarsData return TCarData.Vector;
      function GetNodesData return TNodeData.Vector;
      function GetTextsData return TTextData.Vector;
      function GetLastAddCar return PFCar;
      function GetLastAddNode return PFNode;
      function GetCarGenerationSpeed return Positive;
   private
      CarsData : TCarData.Vector;
      NodesData : TNodeData.Vector;
      TextsData : TTextData.Vector;
      GatesState: TGate := (others => True);
      CarGenerationSpeed : Positive := 1;
      CollectedMoney: Integer :=0;

      LastAddCar : PFCar := null; -- temporary
      LastAddNode : PFNode := null; -- temporary
   end SimulationDataProtect;


   protected body SimulationDataProtect is
      procedure AddCar(Index: in FMatrixIndex; CarSign : in Character; Dir : in EDirection; CarT: in ECarType; MoneyValue : in Integer; CarColorVal : in Color_Type) is
      begin
         -- Check if car on index position not exist already
         if(CheckIfCarExisted(Index => Index) = False) then
            CarsData.Append(New_Item => new FCar'(X         => Index.X,
                                                  Y         => Index.Y,
                                                  CarColor  => CarColorVal,
                                                  Sign      => CarSign,
                                                  Direction => Dir,
                                                  CarType => CarT,
                                                  Money => MoneyValue));
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
         TextsData.Append(new FText'(X         => 4+SimulationScreenInfo.PaddingLeft,
                                     Y         => 4,
                                     TextColor => White,
                                     Text      => To_Unbounded_String("HIGHWAY GATES SIMULATION")));

         -- INDEX=1
         TextsData.Append(new FText'(X         => 6+SimulationScreenInfo.PaddingLeft,
                                     Y         => 6,
                                     TextColor => Light_Blue,
                                     Text      => To_Unbounded_String("Collected money:") & CollectedMoney'Img & To_Unbounded_String(" zl")));

         -- INDEX=2
         TextsData.Append(new FText'(X         => 4+SimulationScreenInfo.PaddingLeft,
                                     Y         => SimulationScreenInfo.PaddingTop+SimulationScreenInfo.Y + 2,
                                     TextColor => White,
                                     Text      => To_Unbounded_String("Legend:")));

         -- INDEX=3
         TextsData.Append(new FText'(X         => 4+SimulationScreenInfo.PaddingLeft,
                                     Y         => SimulationScreenInfo.PaddingTop+SimulationScreenInfo.Y + 3,
                                     TextColor => Light_Green,
                                     Text      => To_Unbounded_String("Green Car - personal car (10 zl)")));

         -- INDEX=4
         TextsData.Append(new FText'(X         => 4+SimulationScreenInfo.PaddingLeft,
                                     Y         => SimulationScreenInfo.PaddingTop+SimulationScreenInfo.Y + 4,
                                     TextColor => Light_Cyan,
                                     Text      => To_Unbounded_String("Cyan Car - truck (20 zl)")));

         -- INDEX=5
         TextsData.Append(new FText'(X         => 4+SimulationScreenInfo.PaddingLeft,
                                     Y         => SimulationScreenInfo.PaddingTop+SimulationScreenInfo.Y + 6,
                                     TextColor => White,
                                     Text      => To_Unbounded_String("Click Q to quit or 1/2/3 to adjust intensity") & CarGenerationSpeed'Img));


         -- INDEX=6
         TextsData.Append(new FText'(X         => 4+SimulationScreenInfo.PaddingLeft,
                                     Y         => SimulationScreenInfo.PaddingTop+SimulationScreenInfo.Y + 7,
                                     TextColor => White,
                                     Text      => To_Unbounded_String("TrafficIntensity: ") & CarGenerationSpeed'Img));


      end InitTextsData;

      procedure UpdateTextsData is
      begin
         --Update log values
         TextsData.Element(1).Text := To_Unbounded_String("Collected money:") & CollectedMoney'Img & To_Unbounded_String(" zl");
         TextsData.Element(6).Text := To_Unbounded_String("TrafficIntensity: ") & CarGenerationSpeed'Img;
      end UpdateTextsData;

      procedure UpdateGatesData is
      begin
         for I of NodesData loop
            if(I.X = 15) then
               if(I.Y > 0 and I.Y < 4) or (I.Y = 6 or I.Y = 7 or I.Y = 8) then
                  if(GetCarPointer((X=>15,Y=>I.Y)) = null) then
                     I.NodeColor := Green;
                  else
                     I.NodeColor := Red;
                  end if;
               end if;
            end if;
         end loop;
      end UpdateGatesData;

      procedure MoveCars is
      begin
         for I of CarsData loop
            if(I.Direction = D_LEFT) then
               if(CheckIfCarExisted(Index => (I.X-1,I.Y)) = False) then
                  if(I.X /= 15) then
                     I.X := I.X -1;
                  end if;
               end if;
            else
               if(CheckIfCarExisted(Index => (I.X+1,I.Y)) = False) then
                  if(I.X /= 15) then
                     I.X := I.X +1;
                  end if;
               end if;
            end if;
         end loop;

      exception
         when PROGRAM_ERROR =>
            Put("PROGRAM_ERROR");
         when others =>
            Put("EXCEPTION");
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

      procedure GateMoveCar(X,Y : Natural) is
      begin
         if(GetCarPointer((X=>X,Y=>Y)).Direction = D_LEFT) then
            GetCarPointer((X=>X,Y=>Y)).X := 14;
         else
            GetCarPointer((X=>X,Y=>Y)).X := 16;
         end if;
      end GateMoveCar;

      procedure SetGateState(GateIndex : Positive; Value : Boolean) is
      begin
         GatesState(GateIndex) := Value;
      end SetGateState;

      function GetGateState(GateIndex : in Positive) return Boolean is
      begin
         return GatesState(GateIndex);
      end GetGateState;

      procedure SetCarGenerationSpeed(Value : in Positive) is
      begin
         CarGenerationSpeed := Value;
      end SetCarGenerationSpeed;

      procedure AddCollectedMoney(Value : in Integer) is
      begin
         CollectedMoney := CollectedMoney + Value;
      end AddCollectedMoney;


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

      function GetCarGenerationSpeed return Positive is
      begin
         return CarGenerationSpeed;
      end GetCarGenerationSpeed;

   end SimulationDataProtect;


    -- FUNCTIONS,PROCEDURES --



   procedure RefreshScreen is
   begin
      --Cars
      for I of SimulationDataProtect.GetCarsData loop
         if(I.X /= 15) then
            Goto_XY(I.X+SimulationScreenInfo.PaddingLeft,I.Y+SimulationScreenInfo.PaddingTop);
            Set_Foreground(I.CarColor);
            Put(I.Sign);
         end if;
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
      accept Start;
      loop
         Clear_Screen(Black);
         RefreshScreen;
         delay ScreenRefreshInterval;
      end loop;
   end Screen;


   task body Keyboard is
   begin
      accept Start;
      loop
         Set_Cursor(True);

         --Key recognision
         case Get_Key is
         when '1' => SimulationDataProtect.SetCarGenerationSpeed(1);
         when '2' => SimulationDataProtect.SetCarGenerationSpeed(2);
         when '3' => SimulationDataProtect.SetCarGenerationSpeed(3);
         when 'q' =>
            abort Screen;
            abort Simulation;
            abort CarHandler;
            abort CarGenerator;
            NT_Console.Clear_Screen(Black);
            NT_Console.Goto_XY(0,0);
            NT_Console.Set_Foreground(White);
            Put("Simulation terminated, close manually by ALT+F4...");
            GNAT.OS_Lib.OS_Exit(0);
         when others => null;
         end case;

         Set_Cursor(False);
      end loop;
   end Keyboard;


   task body Simulation is
   begin
      accept Start;
      SimulationDataProtect.InitNodesData; -- init static nodes (not moveable)
      SimulationDataProtect.InitTextsData;

      -- Init task loop
      for J of GatesHandler loop
         J.Start;
      end loop;

      loop
         delay ScreenRefreshInterval;
         SimulationDataProtect.UpdateTextsData;
         SimulationDataProtect.MoveCars;
         SimulationDataProtect.UpdateGatesData;

         --Gate handler
         for I of SimulationDataProtect.GetCarsData loop
            if(I.X = 15) then
               if(I.Y = 1 and SimulationDataProtect.GetGateState(1) = True) then
                  SimulationDataProtect.SetGateState(1,False);
                  GatesHandler(1).HandleCar(15,1);
               elsif(I.Y = 2 and SimulationDataProtect.GetGateState(2) = True) then
                  SimulationDataProtect.SetGateState(2,False);
                  GatesHandler(2).HandleCar(15,2);
               elsif(I.Y = 3 and SimulationDataProtect.GetGateState(3) = True) then
                  SimulationDataProtect.SetGateState(3,False);
                  GatesHandler(3).HandleCar(15,3);
               elsif(I.Y = 6 and SimulationDataProtect.GetGateState(4) = True) then
                  SimulationDataProtect.SetGateState(4,False);
                  GatesHandler(4).HandleCar(15,6);
               elsif(I.Y = 7 and SimulationDataProtect.GetGateState(5) = True) then
                  SimulationDataProtect.SetGateState(5,False);
                  GatesHandler(5).HandleCar(15,7);
               elsif(I.Y = 8 and SimulationDataProtect.GetGateState(6) = True) then
                  SimulationDataProtect.SetGateState(6,False);
                  GatesHandler(6).HandleCar(15,8);
               end if;
            end if;

         end loop;

      end loop;
   end Simulation;


   task body CarGenerator is
      CarPositionY : Integer := 0;
      CarTypeRand : ECarType := CT_Car;
      MoneyV : Integer := 10;
      CarCol : Color_Type;
   begin
      accept Start;
      loop
         --Rand car type
         if(RandInteger(0,3) /= 1) then
            CarTypeRand := CT_Car;
            MoneyV := 10;
            CarCol := Light_Green;
         else
            CarTypeRand := CT_Truck;
            MoneyV := 20;
            CarCol := Light_Cyan;
         end if;


         if(RandInteger(0,1) = 0) then
            -- Generate Left move
            CarPositionY := RandInteger(1,3);
            SimulationDataProtect.AddCar(Index => (X=>29,Y=>CarPositionY),
                                         CarSign => '<',Dir => D_LEFT,CarT => CarTypeRand,MoneyValue => MoneyV,CarColorVal => CarCol);
         else
            -- Generate Right move
            CarPositionY := RandInteger(6,8);
            SimulationDataProtect.AddCar(Index => (X=>1,Y=>CarPositionY),
                                         CarSign => '>',Dir => D_RIGHT,CarT => CarTypeRand,MoneyValue => MoneyV,CarColorVal => CarCol);
         end if;
         delay 2.0/SimulationDataProtect.GetCarGenerationSpeed;
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


   task body Gate is
      XX,YY : Natural;
      GateWait : Duration;
      MoneyVal : Integer;
   begin
      accept Start;
      loop
         accept HandleCar(CX,CY : in Natural) do
            XX := CX;
            YY := CY;
         end HandleCar;

         --Wait delay in gate
         if (SimulationDataProtect.GetCarPointer((X=>XX,Y=>YY)).CarType = CT_Car) then
            GateWait := 0.0;
         else
            GateWait := 2.0;
         end if;
         --Money set
         MoneyVal := SimulationDataProtect.GetCarPointer((X=>XX,Y=>YY)).Money;
        -- delay
         delay RandDuration(1.0,3.0)+GateWait;
         -- Move Car out of gate
         SimulationDataProtect.GateMoveCar(X => XX,
                                           Y => YY);


         --Set gate state to True
         if(YY = 1) then
            SimulationDataProtect.SetGateState(1,True);
         elsif(YY = 2) then
            SimulationDataProtect.SetGateState(2,True);
         elsif(YY = 3) then
            SimulationDataProtect.SetGateState(3,True);
         elsif(YY = 6) then
            SimulationDataProtect.SetGateState(4,True);
         elsif(YY = 7) then
            SimulationDataProtect.SetGateState(5,True);
         elsif(YY = 8) then
            SimulationDataProtect.SetGateState(6,True);
         end if;

         -- add money for car/truck
         SimulationDataProtect.AddCollectedMoney(Value => MoneyVal);

      end loop;
   end Gate;


   -- MAIN --

begin

   CarGenerator.Start;

   CarHandler.Start;

   Simulation.Start;

   Keyboard.Start;

   Screen.Start;



end Main;
