library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all;

entity sixteenbitxor is
port (M,N : in std_logic_vector(15 downto 0);
      Z: out  std_logic_vector(15 downto 0));
end sixteenbitxor;
		
architecture arch of sixteenbitxor is

component XOR_2 is
   port (A, B: in std_logic; Y: out std_logic);
  end component XOR_2;


begin
		
Chip15: XOR_2
port map(M(15), N(15), Z(15));

Chip14: XOR_2
port map(M(14), N(14), Z(14));

Chip13: XOR_2
port map(M(13), N(13), Z(13));

Chip12: XOR_2
port map(M(12), N(12), Z(12));

Chip11: XOR_2
port map(M(11), N(11), Z(11));

Chip10: XOR_2
port map(M(10), N(10), Z(10));

Chip9: XOR_2
port map(M(9), N(9), Z(9));

Chip8: XOR_2
port map(M(8), N(8), Z(8));

Chip7: XOR_2
port map(M(7), N(7), Z(7));

Chip6: XOR_2
port map(M(6), N(6), Z(6));

Chip5: XOR_2
port map(M(5), N(5), Z(5));

Chip4: XOR_2
port map(M(4), N(4), Z(4));

Chip3: XOR_2
port map(M(3), N(3), Z(3));

Chip2: XOR_2
port map(M(2), N(2), Z(2));

Chip1: XOR_2
port map(M(1), N(1), Z(1));

Chip0: XOR_2
port map(M(0), N(0), Z(0));


end arch;


