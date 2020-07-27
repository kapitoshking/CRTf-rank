-- ��������� ��������
--
-- ������: ������� �����, ������� ������, ������� ������
-- ������� ������������: �������� ������� ��������
-- ����: 13.11.2015

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_CRT_frac_rang_pkg.ALL;

entity Add_mod_pow2 is
	 Generic (constant proj : natural
	 );
    Port ( 
		A       : in   unsigned((N_i(proj)+Nr_bc)-1 downto 0);			 
		B       : in   unsigned((N_i(proj)+Nr_bc)-1 downto 0);			
		Sum_mod : out  unsigned((N_i(proj)+Nr_bc)-1 downto 0)
	 );
end Add_mod_pow2;

architecture Behavioral of Add_mod_pow2 is

	constant p_BC : natural := (N_i(proj)+Nr_bc);	-- ����������� ������
	
begin
	
	Sum_mod <= resize(A+B,p_BC);
	
end Behavioral;