----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/30/2020 06:00:33 PM
-- Design Name: 
-- Module Name: Merger - Structural
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This module is a building block for any fast adder
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Merger is
    Port (G_ij,P_ij,G_jk,P_jk : in STD_LOGIC;
          G_ik,P_ik : out STD_LOGIC );
end Merger;

architecture Structural of Merger is

  component OR_2 is
   port (A, B: in std_logic; Y: out std_logic);
  end component OR_2;
  
  component AND_2 is
   port (A, B: in std_logic; Y: out std_logic);
  end component AND_2;
  
  signal m: std_logic; --intermediate wire
  
begin
A2_1: AND_2 port map (P_ij, G_jk, m);
O2_1: OR_2 port map (G_ij,m,G_ik);
A2_3: AND_2 port map (P_ij, P_jk, P_ik);
    --G_ik <= G_ij or (P_ij and G_jk);
    --P_ik <= P_ij and P_jk;

end Structural;
