-----------------------------------------------------------------------
--
--  File:        demo.adb
--  Description: Win95/NT console support demonstration
--  Rev:         0.2
--  Date:        08-june-1999
--  Author:      Jerry van Dijk
--  Mail:        jdijk@acm.org
--
--  Copyright (c) Jerry van Dijk, 1997, 1998, 1999
--  Billie Holidaystraat 28
--  2324 LK  LEIDEN
--  THE NETHERLANDS
--  tel int + 31 71 531 43 65
--
--  Permission granted to use for any purpose, provided this copyright
--  remains attached and unmodified.
--
--  THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
--  IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
--  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
--
-----------------------------------------------------------------------

--          ***********************************************
--          ** WARNING: ALGORITHM DELIBERATELY CRIPPLED! **
--          ***********************************************

with NT_Console;              use NT_Console;
with Ada.Text_IO;             use Ada.Text_IO;
with Ada.Strings.Fixed;       use Ada.Strings.Fixed;
with Ada.Characters.Handling; use Ada.Characters.Handling;

procedure Demo is

   type Card_Company is (Unknown, Mastercard, Visa, Amex, Diners);

   type Credit_Card_Type is
      record
         Card          : Card_Company;
         Prefix_String : String (1 .. 3);
         Prefix_Length : Positive range 1 .. 3;
      end record;

   Max_Length : constant := 20;

   -- Do *NOT* change order of table
   Card_Table : constant array (1 .. 16) of Credit_Card_Type :=
     (Credit_Card_Type'(Diners,     "300", 3),
      Credit_Card_Type'(Diners,     "301", 3),
      Credit_Card_Type'(Diners,     "302", 3),
      Credit_Card_Type'(Diners,     "303", 3),
      Credit_Card_Type'(Diners,     "304", 3),
      Credit_Card_Type'(Diners,     "305", 3),
      Credit_Card_Type'(Amex,       "34 ", 2),
      Credit_Card_Type'(Diners,     "36 ", 2),
      Credit_Card_Type'(Amex,       "37 ", 2),
      Credit_Card_Type'(Diners,     "38 ", 2),
      Credit_Card_Type'(Mastercard, "51 ", 2),
      Credit_Card_Type'(Mastercard, "52 ", 2),
      Credit_Card_Type'(Mastercard, "53 ", 2),
      Credit_Card_Type'(Mastercard, "54 ", 2),
      Credit_Card_Type'(Mastercard, "55 ", 2),
      Credit_Card_Type'(Visa,       "4  ", 1)
      );

   Length  : Natural;
   Company : Card_Company;
   Again   : Boolean := True;
   Number  : String (1 .. Max_Length);

   procedure Display_Banner is
   begin
      Clear_Screen (Blue);
      Set_Foreground (Blue);
      Set_Background (Yellow);
      Goto_XY (27, 0);
      Put ("* CREDIT CARD VALIDATION *");
      Set_Background (Blue);
      Set_Foreground (Light_Red);
      Goto_XY (20, 2);
      Put ("WARNING: for demonstration purposes only!");
      Set_Foreground (Yellow);
      Goto_XY (12, 8);
      Put ("Please enter card number below, press <ENTER> when ready");
   end Display_Banner;

   function Ask_Again return Boolean is
      Result : Boolean;
      Key    : Character := 'X';
   begin
      Set_Foreground (White);
      Set_Background (Blue);
      Goto_XY (31, 20);
      Put ("Run again (Y/N) ?");
      while Key /= 'Y' and Key /= 'N' loop
         Key := To_Upper (Get_Key);
      end loop;
      if Key = 'Y' then
         Result := True;
      else
         Result := False;
      end if;
      return Result;
   end Ask_Again;

   procedure Get_Number
     (Line   : in     Y_Pos;
      Length : in     Positive;
      Number :    out String)
   is
      Index     : Positive  := 1;
      Key       : Character := 'X';
      X_Start   : X_Pos := (X_Pos'Last - Length + 1) / 2;
      X_Current : X_Pos := X_Start;
   begin
      Number := (others => '.');
      Set_Foreground (Light_Cyan);
      Goto_XY (X_Start, Line);
      for I in 1 .. Length loop
         Put ('.');
      end loop;
      Goto_XY (X_Current, Line);
      Set_Cursor (True);
      while Key /= ASCII.CR loop
         Key := Get_Key;
         if Key = ASCII.NUL then
            Key := Get_Key;
            case Key is
               when Key_Delete => Number (Index) := '.';
                  Put ('.');
                  Goto_XY (X_Current, Line);
               when Key_Right  => if Index < Length then
                  Index := Index + 1;
                  X_Current := X_Current + 1;
                  Goto_XY (X_Current, Line);
               end if;
               when Key_Left  => if Index > 1 then
                  Index := Index - 1;
                  X_Current := X_Current - 1;
                  Goto_XY (X_Current, Line);
               end if;
               when others     => Bleep;
            end case;
         else
            case Key is
               when ASCII.CR   => null;
               when ASCII.BS   => if Index > 1 then
                  Index := Index - 1;
                  X_Current := X_Current - 1;
                  Number (Index) := '.';
                  Goto_XY (X_Current, Line);
                  Put ('.');
                  Goto_XY (X_Current, Line);
               end if;
               when '0' .. '9' => Number (Index) := Key;
                  Put (Key);
                  Index := Index + 1;
                  X_Current := X_Current + 1;
                  if Index > Length then
                     Index := Index - 1;
                     X_Current := X_Current - 1;
                     Goto_XY (X_Current, Line);
                     Index := Length;
                  end if;
               when others     => Bleep;
            end case;
         end if;
      end loop;
      Set_Cursor (False);
   end Get_Number;

   procedure Remove_Spaces (Number : in out String) is
      I : Natural := Index (Number, ".");
   begin
      while I /= 0 loop
         Delete (Number, I, I);
         I := Index (Number, ".");
      end loop;
   end Remove_Spaces;

   function Number_Length (Number : String) return Natural is
      Result : Natural := Index (Number, " ");
   begin
      if Result /= 0 then
         Result := Result - 1;
      end if;
      return Result;
   end Number_Length;

   procedure Display_Centered (Line : in Y_Pos; Text : in String) is
      X : X_Pos := (X_Pos'Last - Text'Length) / 2;
   begin
      Goto_XY (X, Line);
      Put (Text);
   end Display_Centered;

   function Find_Company (Number : String) return Card_Company is
      Company : Card_Company := Unknown;
   begin
  Find_Card:
      for I in Card_Table'Range loop
         if Number (1 .. Card_Table(I).Prefix_Length) =
           Card_Table(I).Prefix_String (1 .. Card_Table(I).Prefix_Length)
         then
            Company := Card_Table(I).Card;
            exit Find_Card;
         end if;
      end loop Find_Card;
      return Company;
   end Find_Company;

   function Validate (S : in String; N : in Natural) return Boolean is
      Temp     : Natural;
      Checksum : Natural := 0;
      Double   : Boolean := False;
   begin
      for I in reverse 1 .. N loop
         Temp := Integer'Value (S(I .. I));
         if Double then
            Temp := 2 * Temp;
            if Temp > 9 then
               Temp := Temp - 9;
            end if;
         end if;
         Checksum := Checksum + Temp;
         Double := not Double;
      end loop;
      return (Checksum mod 10) = 0;
   end Validate;

begin
   while Again = True loop
      Set_Cursor (False);
      Display_Banner;
      Get_Number (10, Max_Length, Number);
      Remove_Spaces (Number);
      Length := Number_Length (Number);
      Company := Find_Company (Number);
      case Company is
         when Unknown    => Set_Foreground (White);
            Set_Background (Red);
            Display_Centered (12, "UNRECOGNIZED CARD NUMBER");
         when Mastercard => if Length /= 16 then
            Set_Foreground (White);
            Set_Background (Red);
            Display_Centered (12, "UNRECOGNIZED MASTERCARD NUMBER");
         elsif Validate (Number, Length) = False then
            Set_Foreground (White);
            Set_Background (Red);
            Display_Centered (12, "INVALID MASTERCARD");
         else
            Set_Foreground (White);
            Set_Foreground (Green);
            Display_Centered (12, "VALID MASTERCARD");
         end if;
         when Visa       => if Length /= 13 and Length /= 16 then
            Set_Foreground (White);
            Set_Background (Red);
            Goto_XY (28, 12);
            Put ("UNRECOGNIZED VISA NUMBER");
         elsif Validate (Number, Length) = False then
            Set_Foreground (White);
            Set_Background (Red);
            Display_Centered (12, "INVALID VISA CARD");
         else
            Set_Foreground (White);
            Set_Background (Green);
            Display_Centered (12, "VALID VISA CARD");
         end if;
         when Amex       => if Length /= 15 then
            Set_Foreground (White);
            Set_Background (Red);
            Goto_XY (22, 12);
            Put ("UNRECOGNIZED AMERICAN EXPRESS NUMBER");
         elsif Validate (Number, Length) = False then
            Set_Foreground (White);
            Set_Background (Red);
            Display_Centered (12, "INVALID AMERICAN EXPRESS CARD");
         else
            Set_Foreground (White);
            Set_Background (Green);
            Display_Centered (12, "VALID AMERICAN EXPRESS CARD");
         end if;
         when Diners     => if Length /= 14 then
            Set_Foreground (White);
            Set_Background (Red);
            Goto_XY (26, 12);
            Put ("UNRECOGNIZED DINERS NUMBER");
         elsif Validate (Number, Length) = False then
            Set_Foreground (White);
            Set_Background (Red);
            Display_Centered (12, "INVALID DINERS CARD");
         else
            Set_Foreground (White);
            Set_Background (Green);
            Display_Centered (12, "VALID DINERS CARD");
         end if;
      end case;
      Again := Ask_Again;
   end loop;
   Set_Foreground (Gray);
   Clear_Screen;
   Goto_XY;
   Set_Cursor (True);
end Demo;
