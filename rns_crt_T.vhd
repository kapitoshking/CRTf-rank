library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_CRT_frac_rang_pkg.ALL;

entity rns_crt_T is
    Generic (constant proj : natural);
    Port (input_rns : in set_mod_type;
          output_T : out T_type);
end rns_crt_T;

architecture Behavioral of rns_crt_T is

    signal b_mul_mod : array_b_mul_T_type;
    signal T_mod : T_type;
    
    Component const_mul_mod_T
        Generic (proj : natural;
                 num_mod_T : natural;
                 num_mod : natural);
        Port (X : in unsigned(mod_bc-1 downto 0);
              X_mod_p : out unsigned(mod_bc-1 downto 0));
    end component;
    
    Component add_mod_tree_T
        Generic (proj : natural;
                 num_mod_T : natural);
        Port (input : in b_mul_T_type;
              output : out unsigned(mod_bc-1 downto 0));
    end component;
       
begin

    b_mul_T : for i in 0 to count-k-1 generate
    begin
		b_mul : for j in 0 to k-1 generate
		begin
			constmulmodT : const_mul_mod_T 
				Generic map (proj => proj,
							 num_mod_T => i,
							 num_mod => j)
				Port map (X => input_rns(j),
						  X_mod_p => b_mul_mod(i)(j));
		end generate b_mul;
	end generate b_mul_T;
    
	add_tree_T : for i in 0 to count-k-1 generate
		begin
			tree : add_mod_tree_T
			Generic map (proj => proj,
						 num_mod_T => i)
			Port map (input => b_mul_mod(i),
					  output => T_mod(i));
	end generate add_tree_T;
	
	output_T <= T_mod;

end Behavioral;