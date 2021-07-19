----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.07.2021 16:18:34
-- Design Name: 
-- Module Name: IITBProc - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IITBProc is
end IITBProc;

architecture Behavioral of IITBProc is
signal clk, rst: std_logic;
--16 bit ALU
component ALU_16bit is 
port(s1,s0:in std_logic;
A, B: in std_logic_vector(15 downto 0);
Y: out std_logic_vector(15 downto 0);
C_out,Z: out std_logic);
end component ALU_16bit;
type myfsm is (IFtch, Dec, R_type,Jmp, jmp_imm, jmp_r, BEQ, WB_R, LHI, LW_SW, SW, LW, WB_L, WB_ADI);
 type i_mem is array (0 to 15) of std_logic_vector(15 downto 0);
 signal imem: i_mem:=( X"4041", -- LW r0,r1,#1
 Others=>(others=>'1')); -- initailise with test code
 type d_mem is array(0 to 31) of std_logic_vector(15 downto 0);
 signal dmem: d_mem:=(X"0000",X"1111", X"2222",X"3333",X"4444",X"5555",
 X"6666",X"7777",X"8888",X"9999",X"AAAA",X"BBBB",X"CCCC",X"DDDD",X"EEEE",X"FFFF",Others=>(others=>'0')); -- Initialize data memory
 
 signal PC,Instr,mem_data_out,A_reg, B_reg,local_IR, local_data:std_logic_vector(15 downto 0);
 signal next_pc: std_logic_vector(15 downto 0):=X"0000";
 signal PC_en: std_logic;
 --signals in decode state
 type regfile is array (0 to 7) of std_logic_vector(15 downto 0);
 signal WA3: std_logic_vector(2 downto 0);
 signal write_data,reg_1,reg_2: std_logic_vector(15 downto 0);
 signal RF: regfile;
 -- signals in execute state
 signal Ain,B_in: std_logic_vector(15 downto 0);
 signal ALU_internal, ALU_out: std_logic_vector(15 downto 0);
 signal c_out,Z: std_logic;
 signal AluSrcA,Zero, carry: std_logic; --reg for storing previous carry,zero flag
 signal ALUsrcB, ALU_control, dst_data_control: std_logic_vector(1 downto 0);
 signal opcode: std_logic_vector(3 downto 0);
 signal fn_code: std_logic_vector(1 downto 0);
 signal Dst_data_write, B_Jmp_imm: std_logic_vector(15 downto 0);
 signal shifted_imm, SE6,SE9: std_logic_vector(15 downto 0);
 -- signals for control
 signal IorD,mem_w,mem_r,IRwrite,BorJ:std_logic;
 signal rf_w, memtoReg,RegDst:std_logic;
 signal PcSrc: std_logic_vector(1 downto 0);
 signal ctrl_state:myfsm;
 shared variable v_AlusrcA,v_pc_en,v_IorD,V_mem_w,v_IRwrite,v_mem_r,v_BorJ,v_rf_w,v_memtoreg,v_RegDst:std_logic ;
  shared variable v_AlusrcB,v_ALU_control,v_dst_data_control,v_pcSrc:std_logic_vector(1 downto 0);
 
 begin
 ALU_control<=v_ALU_control;
  
ALU: ALU_16bit port map(alu_control(1),alu_control(0),Ain,B_in,ALU_internal,c_out,Z);

 -- Clk and reset process
process
     begin
     clk<='0','1' after 100ns;
     wait for 100ns; -- process happening indefinitely
 end process;
 rst<='1','0' after 150 ns;
 -- Fetch cyclen datapath
 -- Get instruction in local_IR,since instruction width is 2 bytes and memory is 16x16, 4 down to 1 bits of PC
 Local_IR<=imem(Conv_integer(PC(4 downto 1))) when IorD='0' 
            else X"00FF";
Local_data<=dmem(Conv_integer(ALU_out(5 downto 1))) when IorD='1'
            else X"0000";  
--Update PC
Next_pc<= ALU_internal when (PCsrc="00" and PC_en='1') else
         Alu_out when (Pcsrc="01" and Pc_en='1') else
         A_reg when (Pcsrc="10" and Pc_en='1') else
         next_pc;
   
Fetch: process(Clk)
    begin
     if(rising_edge(clk)) then
     if(rst='1') then
     PC<=X"0000";
     Instr<=X"ffff";
     mem_data_out<=X"0000";
  else 
  if(Pc_en='1') then
      PC<=next_pc;
   end if;
  if(Irwrite='1') then Instr<=Local_IR;  end if;
  if(mem_r='1') then mem_data_out<=Local_data; end if;
  if(mem_w='1') then dmem(Conv_integer(Alu_out(5 downto 1))) <= B_reg; end if;
  end if;
  end if;
  end process;
 
 --Decode data path
    reg_1<= rf(Conv_integer(Instr(8 downto 6)));
    reg_2 <= rf(Conv_integer(Instr(11 downto 9)));
    opcode<= Instr(15 downto 12);
    fn_code<= Instr(1 downto 0);
    
    WA3<= Instr(5 downto 3) when Regdst='0' else
          INSTR(11 downto 9);
          
     shifted_imm<= Instr(8 downto 0) & "0000000"; 
         
    dst_data_write <= ALU_out when dst_data_control="00" else
                      shifted_imm when dst_data_control="10" else
                      PC when dst_data_control="11" else
                      X"0000";
    SE6<="0000000000" & Instr(5 downto 0) when  Instr(15)='0' else
          "1111111111" & Instr(5 downto 0);
     SE9<= "0000000" & Instr(8 downto 0) when  (Instr(15)='0') else
                 "1111111" & Instr(8 downto 0);
                 
     B_jmp_imm<= SE6 when (BorJ='0') else
                 SE9;
                 
    write_data<= mem_data_out when Memtoreg='1' else
                 dst_data_write;

Decode: process(clk)
begin
    if(rising_edge(Clk)) then
     if(rst='1') then
     -- at initialisation all reg have values as reg number
      for i in 0 to 7 loop
      rf(i)<=Conv_std_logic_vector(i,16);
      end loop;
    else
    if(rf_w='1') then 
       rf(Conv_integer(WA3))<= write_data;
    end if;
     A_reg<= reg_1;
     B_reg<= reg_2;
     
  end if;    
 end if;  
 end process;             
 
-- Execute datapath
Ain<= A_reg when ALUsrcA='1' else
     PC when ALUsrcA='0' else
     X"1111"; --Indicates the problem in alusrcA value

B_in<=B_reg when ALUsrcB="00" else
     x"0002" when ALUsrcB="01" else
     SE6 when ALUsrcB="10" else
     (B_jmp_imm(14 downto 0)&'0') when ALUsrcB="11" else
     X"2222"; --indicates problem in alusrcB value
 
                   
 -- reg update process
 
 process(clk)
 begin
 
 if(rising_edge(clk)) then
 if(rst='1') then
 ALU_out<=X"0000";
 Carry<='0';
 Zero<='1';
 else
 ALU_out<= ALU_internal;
 carry<=c_out;
 Zero<=z;
 end if;
 end if;
 end process;
 
 -- Controller FSM
  process(clk,ctrl_state)
  variable nxt_state:myfsm:=ctrl_state;

  begin
  
   case ctrl_state is 
    when Iftch => V_AlusrcA:='0';
                  V_AlusrcB:="01";
                  V_ALU_control:="00";
                  v_dst_data_control:="00";
                  v_Pc_en:='1';
                  v_IorD:='0';
                  v_mem_w:='0';
                  v_mem_r:='1';
                  v_IRwrite:='1';
                  v_BorJ:='0';
                  v_rf_w:='0';
                  v_memtoReg:='0';
                  v_RegDst:='0';
                  v_PcSrc:="00";
                  nxt_state:= Dec;
      
     when Dec => -- calculates PC+imm6bit*2
                
                v_AlusrcA:='0';
                  v_AlusrcB:="11";
                  v_ALU_control:="00";
                  v_dst_data_control:="00";
                  v_Pc_en:='0';
                  v_IorD:='0';
                  v_mem_w:='0';
                  v_mem_r:='0';
                  v_IRwrite:='0';
                  v_BorJ:='0';
                  v_rf_w:='0';
                  v_memtoReg:='0';
                  v_RegDst:='0';
                  v_PcSrc:="00";
                case opcode is
                 when "0010" | "0000"=> nxt_state:=R_type;
                 when "0100" | "0101" | "0001" => nxt_state:=LW_SW;
                 when "0011" => nxt_state:=LW_SW;
                 when "1000" | "1001" => nxt_state:=Jmp;
                 when "1100" => nxt_state := BEQ;
                 when others => nxt_state:= Iftch;
                end case;
     when R_type => 
                  v_AlusrcA:='1';
                  v_AlusrcB:="00";
                  v_dst_data_control:="00";
                  v_Pc_en:='0';
                  v_IorD:='0';
                  v_mem_w:='0';
                  v_mem_r:='0';
                  v_IRwrite:='0';
                  v_BorJ:='0';
                  v_rf_w:='0';
                  v_memtoReg:='0';
                  v_RegDst:='0';
                  v_PcSrc:="00";
             case opcode(1 downto 0) is
             when "00"=> if((fn_code="00") or ((fn_code="10") and (carry='1')) or ((fn_code="01") and (zero='1')))then
                          v_ALU_control:="00";
                          nxt_state:= WB_R;
                          else
                          nxt_state:= Iftch;
                          end if;
             when "10" => if((fn_code="00") or ((fn_code="10") and (carry='1')) or ((fn_code="01") and (zero='1')))then
                          v_ALU_control:="10";
                          nxt_state:= WB_R;
                          else
                          nxt_state:= Iftch;
                          end if;
             when others=> nxt_state:=Iftch;
             end case;
        When WB_R=>  v_AlusrcA:='0';
                  v_AlusrcB:="00";
                  v_ALU_control:="00";
                  v_dst_data_control:="00"; -- ALU_Out as destination data
                  v_Pc_en:='0';
                  v_IorD:='0';
                  V_mem_w:='0';
                  v_mem_r:='0';
                  v_IRwrite:='0';
                  v_BorJ:='0';
                  v_rf_w:='1';
                  v_memtoReg:='0';
                  v_RegDst:='0';
                  v_PcSrc:="00";
               nxt_state:=Iftch;
     when LW_SW => v_AlusrcA:='1';
                  v_AlusrcB:="10";
                  v_ALU_control:="00";
                  v_dst_data_control:="00"; -- ALU_Out as destination data
                  v_Pc_en:='0';
                  v_IorD:='0';
                  v_mem_w:='0';
                  v_mem_r:='0';
                  v_IRwrite:='0';
                  v_BorJ:='0';
                  v_rf_w:='0';
                  v_memtoReg:='0';
                  v_RegDst:='0';
                  v_PcSrc:="00";
             case opcode(3 downto 2) is
             when "01" => if(opcode(1 downto 0)="00") then nxt_state:= LW;
                          elsif(opcode(1 downto 0)="01") then nxt_state:= SW;
                          else nxt_state:=Iftch;
                          end if;
             when "00" => nxt_state:=WB_ADI;
             when others => nxt_state := Iftch;
             end case;
     
     when LW=> v_AlusrcA:='1';
                  v_AlusrcB:="10";
                  v_ALU_control:="00";
                  v_dst_data_control:="00"; -- ALU_Out as destination data
                  v_Pc_en:='0';
                  v_IorD:='1';
                  v_mem_w:='0';
                  v_mem_r:='1';
                  v_IRwrite:='0';
                  v_BorJ:='0';
                  v_rf_w:='0';
                  v_memtoReg:='1';
                  v_RegDst:='0';
                  v_PcSrc:="00";
           nxt_state:= WB_L;
   when WB_L => v_AlusrcA:='0';
                  v_AlusrcB:="00";
                  v_ALU_control:="00";
                  v_dst_data_control:="00"; -- ALU_Out as destination data
                  v_Pc_en:='0';
                  v_IorD:='0';
                  v_mem_w:='0';
                  v_mem_r:='0';
                  v_IRwrite:='0';
                  v_BorJ:='0';
                  v_rf_w:='1';
                  v_memtoReg:='1';
                  v_RegDst:='1';
                  v_PcSrc:="00";
                  nxt_state:= Iftch;
   when SW => v_AlusrcA:='0';
                  v_AlusrcB:="00";
                  v_ALU_control:="00";
                  V_dst_data_control:="00"; -- ALU_Out as destination data
                  v_Pc_en:='0';
                  v_IorD:='1';
                  v_mem_w:='1';
                  v_mem_r:='0';
                  v_IRwrite:='0';
                  v_BorJ:='0';
                  v_rf_w:='0';
                  v_memtoReg:='0';
                  v_RegDst:='0';
                  v_PcSrc:="00";
                  nxt_state:= Iftch;
     
     when WB_ADI => v_AlusrcA:='0';
                  v_AlusrcB:="00";
                  v_ALU_control:="00";
                  v_dst_data_control:="00"; -- ALU_Out as destination data
                  v_Pc_en:='0';
                  v_IorD:='0';
                  v_mem_w:='0';
                  v_mem_r:='0';
                  v_IRwrite:='0';
                  v_BorJ:='0';
                  v_rf_w:='1';
                  v_memtoReg:='0';
                  v_RegDst:='1';
                  v_PcSrc:="00";
                  nxt_state:= Iftch;
    when LHI => v_AlusrcA:='0';
                  v_AlusrcB:="00";
                  v_ALU_control:="00";
                  v_dst_data_control:="10"; -- shifted immediate value
                 v_Pc_en:='0';
                 v_IorD:='0';
                  v_mem_w:='0';
                  v_mem_r:='0';
                  v_IRwrite:='0';
                  v_BorJ:='0';
                  v_rf_w:='1';
                  v_memtoReg:='0';
                  v_RegDst:='1';
                  v_PcSrc:="00";
            nxt_state:= Iftch;
 when Jmp => v_AlusrcA:='0';
                  v_AlusrcB:="11";
                  v_ALU_control:="00";
                  v_dst_data_control:="11"; -- PC is stored in reg A
                  v_Pc_en:='0';
                  v_IorD:='0';
                  v_mem_w:='0';
                  v_mem_r:='0';
                  v_IRwrite:='0';
                  v_BorJ:='1';
                  v_rf_w:='1';
                  v_memtoReg:='0';
                  v_RegDst:='0';
                  v_PcSrc:="00";
                case opcode(1 downto 0) is
                when "00" => nxt_state:=jmp_imm;
                when "01" => nxt_state:=jmp_r;
                when others => nxt_state:= Iftch;
                end case;
      when jmp_imm => v_AlusrcA:='0';
                  v_AlusrcB:="00";
                  v_ALU_control:="00";
                  v_dst_data_control:="00";
                  v_Pc_en:='1';
                  v_IorD:='0';
                  v_mem_w:='0';
                  v_mem_r:='0';
                  v_IRwrite:='0';
                  v_BorJ:='0';
                  v_rf_w:='0';
                  v_memtoReg:='0';
                  v_RegDst:='0';
                  v_PcSrc:="01";
                  nxt_state:=Iftch;
        when jmp_r => v_AlusrcA:='0';
                  v_AlusrcB:="00";
                  v_ALU_control:="00";
                  v_dst_data_control:="00";
                  v_Pc_en:='1';
                  v_IorD:='0';
                  v_mem_w:='0';
                  v_mem_r:='0';
                  v_IRwrite:='0';
                  v_BorJ:='0';
                  v_rf_w:='0';
                  v_memtoReg:='0';
                  v_RegDst:='0';
                  v_PcSrc:="10"; -- address in reg1
              nxt_state:=Iftch;
       when BEQ=> v_AlusrcA:='1';
                  v_AlusrcB:="00";
                  v_ALU_control:="01";
                  v_dst_data_control:="00";
                  v_IorD:='0';
                  v_mem_w:='0';
                  v_mem_r:='0';
                  v_IRwrite:='0';
                  v_BorJ:='0';
                  v_rf_w:='0';
                  v_memtoReg:='0';
                  v_RegDst:='0';
                 if(Z ='1') then --here Z is immediate zero signal
                 v_Pc_en:='1';
                 v_PcSrc:="01";
                 else 
                 V_pc_en:='0';
                 V_PcSrc:="00";
                 end if;
        when others=> nxt_state:=Iftch;
        end case;
        if(rising_edge(clk)) then
        if(rst='1') then
        ctrl_state<=Iftch;
       AlusrcA<='0';
        AlusrcB<="00";
        ALU_control<="00";
        dst_data_control<="00";
        pc_en<='0';
        IorD<='0';
        mem_w<='0';
        mem_r<='0';
        IRwrite<='0';
        BorJ<='0';
        rf_w<='0';
        memtoReg<='0';
        RegDst<='0';
        PcSrc<="00";
        else
        ctrl_state<=nxt_state;
       
        end if;
        end if;
   AlusrcA<=v_AlusrcA;
        AlusrcB<=v_AlusrcB;
        dst_data_control<=v_dst_data_control;
        pc_en<=v_pc_en;
        IorD<=v_IorD;
        mem_w<=v_mem_w;
        mem_r<=v_mem_r;
        IRwrite<=v_IRwrite;
        BorJ<=v_BorJ;
        rf_w<=v_rf_w;
        memtoReg<=v_memtoReg;
        RegDst<=v_RegDst;
        PcSrc<=v_Pcsrc;
        end process;
        
           
            
                  
  end Behavioral;
 