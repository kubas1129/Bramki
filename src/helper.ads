with NT_Console,Ada.Unchecked_Deallocation,Ada.Containers.Vectors;

use NT_Console, Ada.Containers;


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
   
   -- Cars (moving objects)
   type FCar is record
      X,Y : Natural := 0;
      CarColor : Color_Type := Black;
      Sign : Character;
   end record;
   
   -- Pointer to FCar
   type PFCar is access FCar;
   
   -- Static node (construction, walls, etc)
   type FNode is record
      X,Y : Natural := 0;
      NodeColor : Color_Type := White;
   end record;
   
   -- Pointer to Node
   type PFNode is access FNode;
   
   -- propably to delete
   type TScreenData is array (Natural range<>,Natural range<>) of Character;
   
   --Cars array
   package TCarData is new Vectors (Index_Type   => Natural,
                                    Element_Type => PFCar);
   use TCarData;
     
   --Nodes array
   package TNodeData is new Vectors (Index_Type   => Natural,
                                     Element_Type => PFNode);
   use TNodeData;     
   
   
   -----Methods------ 
   
   -- Rand integer from range A-B
   function RandInteger(A,B:Integer) return Integer;
   
   
   -- Deallocate Car object
   procedure Delete_Car is new Ada.Unchecked_Deallocation
                                            (Object => FCar, Name => PFCar);

   -- Deallocate Node object
   procedure Delete_Node is new Ada.Unchecked_Deallocation
                                            (Object => FNode, Name => PFNode);

end Helper;
