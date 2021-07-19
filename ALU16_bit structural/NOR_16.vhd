library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all;

entity NOR_16 is
Port (
	a_vec : in  STD_LOGIC_VECTOR(15 downto 0 );
	Y : out  STD_LOGIC);
end entity NOR_16;

architecture struct of NOR_16 is

 
  component NOR_2 is
   port (A, B: in std_logic; Y: out std_logic);
  end component NOR_2;
  
  component OR_2 is
   port (A, B: in std_logic; Y: out std_logic);
  end component OR_2;
  
 signal w : std_logic_vector(13 downto 0);

begin

u0: OR_2 port map (a_vec(0),a_vec(1),w(0));
u1: OR_2 port map (a_vec(2),a_vec(3),w(1));
u2: OR_2 port map (a_vec(4),a_vec(5),w(2));
u3: OR_2 port map (a_vec(6),a_vec(7),w(3));
u4: OR_2 port map (a_vec(8),a_vec(9),w(4));
u5: OR_2 port map (a_vec(10),a_vec(11),w(5));
u6: OR_2 port map (a_vec(12),a_vec(13),w(6));
u7: OR_2 port map (a_vec(14),a_vec(15),w(7));
u8: OR_2 port map (w(0),w(1),w(8));
u9: OR_2 port map (w(2),w(3),w(9));
u10: OR_2 port map (w(4),w(5),w(10));
u11: OR_2 port map (w(6),w(7),w(11));
u12: OR_2 port map (w(8),w(9),w(12));
u13: OR_2 port map (w(10),w(11),w(13));
u14: NOR_2 port map (w(12),w(13),Y);

end struct;
