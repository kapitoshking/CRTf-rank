library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
--[[4294967296],[4294967297],[4294967299],[4294967301]]
package R_code_64_bit_CRT_frac_rang_pkg is

	constant count : natural := 4;    -- n
	constant mod_bc : natural := 33;
	constant num_bc : natural := 64;
    constant N_bc : natural := 163;    -- точность округленных констант
    constant Nr_bc : natural := 34;    -- кол-во разрядов для ранга
    constant f : natural := 2; -- количество проекций
    constant k : natural := 2; -- количество рабочих оснований
    constant t : unsigned(count-1 downto 0) := "0001"; -- количество исправляемых ошибок
    type N_type is array (0 to f-1) of natural;
    type mod_type is array (0 to count-1) of unsigned(mod_bc-1 downto 0);
    type T_type is array (0 to count-k-1) of unsigned(mod_bc-1 downto 0);
    type array_T_type is array (0 to f-1) of T_type;
    type b_mul_T_type is array (0 to k-1) of unsigned(mod_bc-1 downto 0);
    type array_b_mul_T_type is array (0 to count-k-1) of b_mul_T_type;
    type array_proj_b_mul_T_type is array (0 to f-1) of array_b_mul_T_type;
    type r_mul_T_type is array (0 to count-k-1) of unsigned(mod_bc-1 downto 0);
    type array_r_mul_T_type is array (0 to f-1) of r_mul_T_type;
    type hd_type is array (0 to f-1) of unsigned(count-1 downto 0);
    type array_hd_type is array (0 to count-1) of unsigned(0 downto 0);
    type set_mod_type is array (0 to k-1) of unsigned(mod_bc-1 downto 0);
    type array_set_mod_type is array (0 to f-1) of set_mod_type;
    type array_mod_type is array (0 to f-1) of mod_type;
    type array_Fr_type is array (0 to k-1) of unsigned((N_bc+Nr_bc)-1 downto 0);
    type rang_proj_type is array (0 to f-1) of unsigned(Nr_bc-1 downto 0);
    type F_proj_type is array (0 to f-1) of unsigned(N_bc-1 downto 0);
    type M_proj_type is array (0 to f-1) of unsigned(k*mod_bc-1 downto 0);
    type basis_type is array (0 to k-1) of unsigned(N_bc-1 downto 0);
    type array_basis_type is array (0 to f-1) of basis_type;
	 
    constant M_work_F : F_proj_type := ("0000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
										"0000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111111001000000000000000000000000001010001111111111111111111111110010000100");

    constant N_i : N_type := (98,98);

    constant m : mod_type := ("100000000000000000000000000000000",
                              "100000000000000000000000000000001",
                              "100000000000000000000000000000011",
                              "100000000000000000000000000000101");

    constant M_i : M_proj_type := ("010000000000000000000000000000000100000000000000000000000000000000",
                                   "010000000000000000000000000000100000000000000000000000000000001111");
                                  
    constant bas : array_basis_type := (
         ("0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000","0000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111111111000000000000000000000000000000001111111111111111111111111111111101"),
         ("0000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000011111111111111111111111111111101000000000000000000000000000010010","0000000000000000000000000000000000000000000000000000000000000000001111111111111111111111111111111100000000000000000000000000000100111111111111111111111111111001111")
         );   
		 
	 constant bas_T : array_proj_b_mul_T_type := (
         (("100000000000000000000000000000001","000000000000000000000000000001001"),("100000000000000000000000000000001","000000000000000000000000000011001")),
         (("010000000000000000000000000001010","010000000000000000000000000000110"),("000000000000000000000000000000110","000000000000000000000000000000011"))
         );	
		 
	 constant bas_rang : array_r_mul_T_type := (
         ("011111111111111111111111111111101","011111111111111111111111111110001"),
         ("011111111111111111111111111110001","011111111111111111111111111111001")
         );

end R_code_64_bit_CRT_frac_rang_pkg;

package body R_code_64_bit_CRT_frac_rang_pkg is

end R_code_64_bit_CRT_frac_rang_pkg;
