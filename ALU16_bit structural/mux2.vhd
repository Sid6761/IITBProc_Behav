library IEEE;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all; --adding gates file to use its components


entity mux2 is   
port(s:in std_logic;
I0, I1: in std_logic;
Y: out std_logic);
end mux2;

architecture struct of mux2 is --structural architecture, thus connecting different blocks of gates

signal n_s,a,b : std_logic; --signal for wires

component INVERTER is
   port (A: in std_logic; Y: out std_logic);
  end component INVERTER;

  component AND_2 is
   port (A, B: in std_logic; Y: out std_logic);
  end component AND_2;
  
 component OR_2 is
   port (A, B: in std_logic; Y: out std_logic);
  end component OR_2;
  
begin

inv_1 : inverter   --inverter instance
port map (A => s,Y => n_s); --mapping signals to ports

and_comp1 : and_2    --and gate
port map (A => I0,B => n_s, Y => a);

and_comp2 : and_2  --and gate
port map (A => I1, B => s,Y => b);

or_comp1 : or_2 --or gate
port map (A => a, B => b, Y => Y);

end struct;

