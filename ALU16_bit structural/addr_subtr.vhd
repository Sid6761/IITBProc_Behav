
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.Gates.all;

entity addr_subtr is
port(A,B :in std_logic_vector(15 downto 0);
      Control: in std_logic; -- control signal (0 => ADDR, 1 => Subtr)
		 Y: out std_logic_vector(15 downto 0);
		 c_out: out std_logic);
end entity addr_subtr;

architecture struct of addr_subtr is

--Component declaration
component Kogge_Stone is 
  Port(a :in STD_LOGIC_VECTOR(15 downto 0);
          b    :in STD_LOGIC_VECTOR(15 downto 0);
          c_in :in STD_LOGIC;
          sum  :out STD_LOGIC_VECTOR(15 downto 0);      
          c_out:out STD_LOGIC); 
end component Kogge_Stone;

component sixteenbitxor is
port (M,N : in std_logic_vector(15 downto 0);
      Z: out  std_logic_vector(15 downto 0));
end component sixteenbitxor;

--signal declaration
signal B_xored: std_logic_vector(15 downto 0);
signal Control_vec: std_logic_vector(15 downto 0);

begin

Control_vec <= (others => Control); -- To be xored with input B ( Thus will give inverted B incase of control=='1')

XOR_16: sixteenbitxor port map (B, Control_vec, B_xored);
Addr: Kogge_Stone port map (A,B_xored, Control,Y,c_out);

end struct; 