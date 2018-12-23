with NT_Console,Ada.Unchecked_Deallocation,Ada.Containers.Vectors,Ada.Strings.Unbounded;

use NT_Console, Ada.Containers,Ada.Strings.Unbounded;


package Helper is

   -----Types and records-----
   
   -- Screen info (width and height)
   type FScreenInfo is record
      X,Y: Natural := 0;
      PaddingLeft : Natural := 0;
      PaddingTop : Natural := 0;
   end record;
   
   -- Index of matrix 
   type FMatrixIndex is record
      X,Y: Natural := 0;
   end record;
   
   -- Car move direction
   type EDirection is (D_LEFT,D_RIGHT);
   
   -- Cars (moving objects)
   type FCar is record
      X,Y : Natural := 0;
      CarColor : Color_Type := Black;
      Sign : Character;
      Direction : EDirection;
   end record;
   
   -- Pointer to FCar
   type PFCar is access FCar;
   
   -- Static node (construction, walls, etc)
   type FNode is record
      X,Y : Natural := 0;
      NodeColor : Color_Type := White;
      Data : Unbounded_String;
   end record;
   
   -- Pointer to Node
   type PFNode is access FNode;
   
   -- Text static
   type FText is record
      X,Y : Natural := 0;
      TextColor : Color_Type := White;
      Text : Unbounded_String;
   end record;
   
   -- Pointer to text
   type PFText is access FText;
   
   
   
   --Gate array : True - free, False - working
   type TGate is array (1..6) of Boolean; 
   
   --Cars array
   package TCarData is new Vectors (Index_Type   => Natural,
                                    Element_Type => PFCar);
   use TCarData;
     
   --Nodes array
   package TNodeData is new Vectors (Index_Type   => Natural,
                                     Element_Type => PFNode);
   use TNodeData; 
   
   -- Texts array
   package TTextData is new Vectors(Index_Type   => Natural,
                                    Element_Type => PFText);
   use TTextData;
   
   
   -----Methods------ 
   
   -- Rand integer from range A-B
   function RandInteger(A,B:Natural) return Natural;
   
   
   -- Deallocate Car object
   procedure Delete_Car is new Ada.Unchecked_Deallocation
                                            (Object => FCar, Name => PFCar);

   -- Deallocate Node object
   procedure Delete_Node is new Ada.Unchecked_Deallocation
                                            (Object => FNode, Name => PFNode);

   
   --Deallocate Text object
   procedure Delete_Text is new Ada.Unchecked_Deallocation(Object => FText,
                                                           Name   => PFText);
   
   
end Helper;
