library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_CRT_frac_rang_pkg.ALL;

entity rns_crt_frac_rang is
    Generic (constant proj : natural);
    Port (input_rns : in set_mod_type;
          output_rang : out unsigned(Nr_bc-1 downto 0);
		  output_crt_F : out unsigned(N_bc-1 downto 0));
end rns_crt_frac_rang;

architecture Behavioral of rns_crt_frac_rang is

    signal k_mul : array_Fr_type;
    signal num_ctr_frac_rang : unsigned((N_bc+Nr_bc)-1 downto 0);
       
    Component const_mul_mod_Fr
        Generic (constant proj : natural;
                 constant num_mod : natural);
        Port (X : in unsigned(mod_bc-1 downto 0);
              X_mod_p : out unsigned((N_bc+Nr_bc)-1 downto 0));
    end component;
       
    Component add_tree_frac_rang
        Port (input : in array_Fr_type;
              output : out unsigned((N_bc+Nr_bc)-1 downto 0));
    end component;
       
begin

    mul_const : for i in 0 to k-1 generate
        begin
			constmulmodFr: const_mul_mod_Fr 
			GENERIC MAP (
				proj => proj,
				num_mod => i
			)
			PORT MAP(
				X => input_rns(i),
				X_mod_p => k_mul(i)
			);
    end generate mul_const;
	
--    mul_const : for i in 0 to k-1 generate
--        begin
--            k_mul(i) <= resize(input_rns(i)*bas(proj)(i),(N_bc+Nr_bc));
--    end generate mul_const;
    
    tree : add_tree_frac_rang
        Port map (input => k_mul,
                  output => num_ctr_frac_rang);
    
    output_rang <= resize(num_ctr_frac_rang(N_i(proj)+Nr_bc-1 downto N_i(proj)),output_rang'length);
    output_crt_F <= resize(num_ctr_frac_rang(N_i(proj)-1 downto 0),output_crt_F'length);
    
end Behavioral;