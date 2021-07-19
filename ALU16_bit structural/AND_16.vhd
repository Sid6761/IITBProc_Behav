library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all;

entity AND_16 is
Port (
	a_vec : in  STD_LOGIC_VECTOR(15 downto 0 );
	b_vec : in  STD_LOGIC_VECTOR(15 downto 0);
	out_vec : out  STD_LOGIC_VECTOR(15 downto 0));
end entity AND_16;

architecture struct of AND_16 is

 
  component AND_2 is
   port (A, B: in std_logic; Y: out std_logic);
  end component AND_2;

begin

u0: AND_2 port map (a_vec(0),b_vec(0),out_vec(0));
u1: AND_2 port map (a_vec(1),b_vec(1),out_vec(1));
u2: AND_2 port map (a_vec(2),b_vec(2),out_vec(2));
u3: AND_2 port map (a_vec(3),b_vec(3),out_vec(3));
u4: AND_2 port map (a_vec(4),b_vec(4),out_vec(4));
u5: AND_2 port map (a_vec(5),b_vec(5),out_vec(5));
u6: AND_2 port map (a_vec(6),b_vec(6),out_vec(6));
u7: AND_2 port map (a_vec(7),b_vec(7),out_vec(7));
u8: AND_2 port map (a_vec(8),b_vec(8),out_vec(8));
u9: AND_2 port map (a_vec(9),b_vec(9),out_vec(9));
u10: AND_2 port map (a_vec(10),b_vec(10),out_vec(10));
u11: AND_2 port map (a_vec(11),b_vec(11),out_vec(11));
u12: AND_2 port map (a_vec(12),b_vec(12),out_vec(12));
u13: AND_2 port map (a_vec(13),b_vec(13),out_vec(13));
u14: AND_2 port map (a_vec(14),b_vec(14),out_vec(14));
u15: AND_2 port map (a_vec(15),b_vec(15),out_vec(15));

end struct;
