library IEEE;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all;

-- Top module entity description
entity ALU_16bit is 
port(s1,s0:in std_logic;
A, B: in std_logic_vector(15 downto 0);
Y: out std_logic_vector(15 downto 0);
C_out,Z: out std_logic);
end entity ALU_16bit;

architecture struct of ALU_16bit is

--Components declaration

component mux4 is 
port(s1,s0:in std_logic;
I0, I1, I2, I3: in std_logic;
Y: out std_logic);
 end component mux4;

component addr_subtr is
port(A,B :in std_logic_vector(15 downto 0);
      Control: in std_logic;
		 Y: out std_logic_vector(15 downto 0);
		 c_out: out std_logic);
end component addr_subtr;

component NAND_16 is
Port (
	a_vec : in  STD_LOGIC_VECTOR(15 downto 0 );
	b_vec : in  STD_LOGIC_VECTOR(15 downto 0);
	out_vec : out  STD_LOGIC_VECTOR(15 downto 0));
end component NAND_16;

component sixteenbitxor is
port (M,N : in std_logic_vector(15 downto 0);
      Z: out  std_logic_vector(15 downto 0));
end component sixteenbitxor;

component OR_2 is
   port (A, B: in std_logic; Y: out std_logic);
  end component OR_2;
  
component NOR_16 is
Port (
	a_vec : in  STD_LOGIC_VECTOR(15 downto 0 );
	Y : out  STD_LOGIC);
end component NOR_16;

--Signal declaration-----
signal Adder_subtr_out,Nand_out, XOR_out: std_logic_vector(15 downto 0); -- 16 bit computation from individual blocks
signal Adder_subtr_cout: std_logic;    -- C_out in case of XOR and NAND operation is always zero
signal I0,I1,I2,I3 : std_logic_vector(16 downto 0); -- Vectors corresponding inputs of MUX4 ladder
signal Out_17bit: std_logic_vector(16 downto 0); -- Output vector comprising of carry bit and rest computation bit (MSB is carry) 
signal addr_subtr_control : std_logic; -- Control signal for addr_subtr block

begin 

-- Component instantaniation
Or2_1: OR_2 port map (s1,s0,addr_subtr_control); --Control will depend on s1,s0
ADDER_Subtr: addr_subtr port map (A,B, addr_subtr_control, Adder_subtr_out,Adder_subtr_cout);
NAND16: NAND_16     port map (A,B, Nand_out);
XOR16:sixteenbitxor port map (A,B,XOR_out);

-- Setting up input vectors of mux4 ladder (MSB is carry bit and rest is computation bits from blocks)
I0(16) <= Adder_subtr_cout;
I0(15 downto 0) <= Adder_subtr_out;
I1 <= I0; -- I1 will be selected in case of subtractor (I1 and I0 both are connected to addr_subtr block)
I2(16)<= '0';
I2(15 downto 0) <= Nand_out; --I2 connected to NAND block
I3(16) <= '0';
I3(15 downto 0) <= XOR_out; -- I3 connected to  XOR block

--MUX4 ladder for select operation
GEN_MUX_4: 
for i in 0 to 16 generate
MUX4_X: mux4 port map
(s1,s0,I0(i),I1(i),I2(i),I3(i),Out_17bit(i));
end generate GEN_MUX_4;

-- structure of out_17bit (Carry_bit, 16 Computation bits)
Y <= Out_17bit(15 downto 0);
C_out <= Out_17bit(16);

NOR16_1: NOR_16 port map (out_17bit(15 downto 0), Z); -- checking if computation bits are all zeroes 
end struct;
     

