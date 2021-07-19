----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/30/2020 06:15:09 PM
-- Design Name: 
-- Module Name: Kogge_Stone - Structural
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This is a 16 bit fast adder. Generate statements have been used to exploit the pattern and to avoid tedious signal assignments.
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.Gates.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Kogge_Stone is
    Port (a    :in STD_LOGIC_VECTOR(15 downto 0);
          b    :in STD_LOGIC_VECTOR(15 downto 0);
          c_in :in STD_LOGIC;
          sum  :out STD_LOGIC_VECTOR(15 downto 0);      
          c_out:out STD_LOGIC); 
end Kogge_Stone;


architecture Structural of Kogge_Stone is
-- declare intereconnect/helper signals
    signal G_1 : STD_LOGIC_VECTOR(15 downto 0);
    signal G_2 : STD_LOGIC_VECTOR(15 downto 0);
    signal G_3 : STD_LOGIC_VECTOR(15 downto 0);
    signal G_4 : STD_LOGIC_VECTOR(15 downto 0);
    signal G_5 : STD_LOGIC_VECTOR(15 downto 0);
    
    signal P_1 : STD_LOGIC_VECTOR(15 downto 0);
    signal P_2 : STD_LOGIC_VECTOR(15 downto 0);
    signal P_3 : STD_LOGIC_VECTOR(15 downto 0);
    signal P_4 : STD_LOGIC_VECTOR(15 downto 0);
    signal P_5 : STD_LOGIC_VECTOR(15 downto 0);
    signal M,L,Q : std_logic_vector(15 downto 0);
    signal e,f,g : std_logic;     
-- component from other file is defined here
    component Merger is
        Port (G_ij,P_ij,G_jk,P_jk : in STD_LOGIC;
              G_ik,P_ik : out STD_LOGIC );
    end component;

   component AND_16 is
      Port (a_vec : in  STD_LOGIC_VECTOR(15 downto 0 );
	         b_vec : in  STD_LOGIC_VECTOR(15 downto 0);
	         out_vec : out  STD_LOGIC_VECTOR(15 downto 0));
    end component AND_16;
	 
	component sixteenbitxor is
      Port (M,N : in std_logic_vector(15 downto 0);
            Z: out  std_logic_vector(15 downto 0));
    end component sixteenbitxor;
		
   component XOR_2 is
     port (A, B: in std_logic; Y: out std_logic);
   end component XOR_2;
 
   component OR_2 is
     port (A, B: in std_logic; Y: out std_logic);
   end component OR_2;
	
  component AND_2 is
    port (A, B: in std_logic; Y: out std_logic);
  end component AND_2;



	
begin
--     mux_X4_1 : MUX_2_1 Port Map ('1','0',x4,X4_1);
    -- Level 1
	 A16_1: AND_16 port map (a_vec => a, b_vec => b, out_vec => M );
    X16_1: sixteenbitxor port map (M => a, N => b, Z => L);
												
	G_1(15 downto 1) <= M(14 downto 0);
	P_1(15 downto 1) <= L(14 downto 0);
	 --G_1(15 downto 1) <= a(14 downto 0) and b(14 downto 0);       -- ADD CUSTOM BLOCK HERE
    --P_1(15 downto 1) <= a(14 downto 0) xor b(14 downto 0);       -- ADD CUSTOM BLOCK HERE
    G_1(0) <= c_in;
    P_1(0) <= '0';
    
    -- Level 2
    G_2(0) <= G_1(0);
    
    GEN_Merger_1:
    for i in 1 to 15 generate
        MergeX: Merger Port Map 
        (G_1(i),P_1(i),G_1(i-1),P_1(i-1),G_2(i),P_2(i));
    end generate GEN_Merger_1;        
    
    -- Level 3
    G_3(0) <= G_2(0);
    G_3(1)  <= G_2(1);
    
    GEN_Merger_2:
    for i in 2 to 15 generate
        MergeX: Merger Port Map 
        (G_2(i),P_2(i),G_2(i-2),P_2(i-2),G_3(i),P_3(i));
    end generate GEN_Merger_2;        

    -- Level 4
    G_4(0)  <= G_3(0);
    G_4(1)  <= G_3(1);
    G_4(2)  <= G_3(2);
    G_4(3)  <= G_3(3);
    GEN_Merger_3:
    for i in 4 to 15 generate
        MergeX: Merger Port Map 
        (G_3(i),P_3(i),G_3(i-4),P_3(i-4),G_4(i),P_4(i));
    end generate GEN_Merger_3;        

    -- Level 5
    G_5(0)  <= G_4(0);
    G_5(1)  <= G_4(1);
    G_5(2)  <= G_4(2);
    G_5(3)  <= G_4(3);
    G_5(4)  <= G_4(4);
    G_5(5)  <= G_4(5);
    G_5(6)  <= G_4(6);
    G_5(7)  <= G_4(7);
    GEN_Merger_4:
    for i in 8 to 15 generate
        MergeX: Merger Port Map 
        (G_4(i),P_4(i),G_4(i-8),P_4(i-8),G_5(i),P_5(i));
    end generate GEN_Merger_4;        
   
   -- Final Output Assignment
	X16_2 : sixteenbitxor port map (a,b,Q);
	X16_3: sixteenbitxor port map (Q,G_5,sum);
  --sum <= a xor b xor G_5; 
  
  A2_1 : AND_2 port map (a(15),b(15),e);  
  X2_1: XOR_2 port map (a(15),b(15),f);
  A2_2: AND_2 port map (f,G_4(15),g);
  O2_1: OR_2 port map (e,g,c_out);
  
   --c_out <= (a(15) and b(15)) or ((a(15) xor b(15)) and G_4(15));
end Structural;
