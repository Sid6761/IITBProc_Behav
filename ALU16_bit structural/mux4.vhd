library IEEE;
use ieee.std_logic_1164.all;


entity mux4 is   
port(s1,s0:in std_logic;
I0, I1, I2, I3: in std_logic;
Y: out std_logic);
end mux4;

architecture struct of mux4 is

signal I_s0, I_s1 : std_logic;
component mux2 is
port(s:in std_logic;
I0, I1: in std_logic;
Y: out std_logic);
end component mux2;

begin

mux2_1 : mux2
port map (s0, I0, I1, I_s0);

mux2_2 : mux2
port map (s0, I2, I3, I_s1);

mux2_3 : mux2
port map (s1, I_s0, I_s1, Y);

end struct;

