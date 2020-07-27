library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_CRT_frac_rang_pkg.ALL;

entity R_code_64_bit_CRT_frac_rang is
    Port (input : in mod_type;
          output : out unsigned(num_bc-1 downto 0));
end R_code_64_bit_CRT_frac_rang;

architecture Behavioral of R_code_64_bit_CRT_frac_rang is
    signal num_rns : array_set_mod_type;
    signal num_crt_rang : rang_proj_type;
    signal num_crt_F : F_proj_type;
    signal num_crt_T : array_T_type;
    signal mul_r : array_T_type;
    signal hd_projections : hd_type;
    signal projections : unsigned(f-1 downto 0);
    signal proj_rns : array_mod_type;
    signal projection : natural;
    
    Component rns_crt_frac_rang
        Generic (proj : natural);
        Port (input_rns : in set_mod_type;
              output_rang : out unsigned(Nr_bc-1 downto 0);
			     output_crt_F : out unsigned(N_bc-1 downto 0));
    end component;    
	
	Component rns_crt_T
        Generic (proj : natural);
        Port (input_rns : in set_mod_type;
              output_T : out T_type);
    end component;	
	
	Component const_mul_mod_rang
        Generic (proj : natural;
				 num_mod_T : natural);
        Port (X : in unsigned(Nr_bc-1 downto 0);
              X_mod_p : out unsigned(mod_bc-1 downto 0));
    end component;
	
    Component Add_mod
        Generic (p : unsigned(mod_bc-1 downto 0));
        Port (A : in unsigned(mod_bc-1 downto 0);
              B : in unsigned(mod_bc-1 downto 0);
              Sum_mod : out unsigned(mod_bc-1 downto 0));
    end component;

    Component HD
        Port (input : in mod_type;
              input_proj_rns : in mod_type;
              output_hd : out unsigned);
    end component;

    Component select_projection
        Port (proj : in unsigned(f-1 downto 0);
              output : out natural);
    end component;
    
begin

    localization_proj : for i in 0 to f-1 generate
    begin
        rns_i : for j in 0 to k-1 generate
        begin
            num_rns(i)(j) <= input(i*k+j);
        end generate rns_i;
    end generate localization_proj;
    
    calc_proj : for i in 0 to f-1 generate
    begin
		  rnscrtT : rns_crt_T
				 Generic map (proj => i)
				 Port map (input_rns => num_rns(i),
							output_T => num_crt_T(i));

	 	 rnscrtfracrang : rns_crt_frac_rang
             Generic map (proj => i)
             Port map (input_rns => num_rns(i),
                       output_rang => num_crt_rang(i),
							  output_crt_F => num_crt_F(i));

    end generate calc_proj;
	
    mul_rang : for i in 0 to f-1 generate
    begin
	    mul_rang_mod : for j in 0 to count-k-1 generate
		begin
			constmulmodrang : const_mul_mod_rang
				 Generic map (proj => i,
							  num_mod_T => j)
				 Port map (X => num_crt_rang(i),
						   X_mod_p => mul_r(i)(j));  
		end generate mul_rang_mod;
    end generate mul_rang;
	
    projection_rns : for i in 0 to f-1 generate
    begin
        proj_1 : for j in 0 to i*k-1 generate
        begin
        Addmod : Add_mod
            Generic map (p => m(j))
            Port map (A => num_crt_T(i)(j),
                      B => mul_r(i)(j),
                      Sum_mod => proj_rns(i)(j));
        end generate proj_1;
        
        proj_i : for j in i*k to (i+1)*k-1 generate
        begin
            proj_rns(i)(j) <= input(j);
        end generate proj_i;
        
        proj_n : for j in (i+1)*k to count-1 generate
        begin
        Addmod : Add_mod
            Generic map (p => m(j))
            Port map (A => num_crt_T(i)(j-k),
                      B => mul_r(i)(j-k),
                      Sum_mod => proj_rns(i)(j));
        end generate proj_n;
    end generate projection_rns;
    
    hd_proj : for i in 0 to f-1 generate
    begin
       hdproj : HD
             Port map (input => input,
                       input_proj_rns => proj_rns(i),
                       output_hd => hd_projections(i));
    end generate hd_proj;

    process (num_crt_F, hd_projections)
    variable pr : unsigned(f-1 downto 0);
    begin
        for i in 0 to f-1 loop
           if (num_crt_F(i) < M_work_F(i)) and (hd_projections(i) <= t) then 
               pr(i) := '1';
           else
               pr(i) := '0';
           end if;
        end loop;
    projections <= pr;
    end process;

    select_proj : select_projection
            Port map (proj => projections,
                      output => projection);
                      
    output <= resize(num_crt_F(projection)*M_i(projection) srl N_i(projection),num_bc); 

end Behavioral;