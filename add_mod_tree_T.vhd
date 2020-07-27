-- Вычисление остатка от деления числа X на модуль p
--	с настраиваемыми параметрами разрядности
--
-- Авторы: Назаров Антон, Дерябин Максим, Бабенко Михаил
-- Научный руководитель: Червяков Николай Иванович
-- Дата: 13.11.2015

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_CRT_frac_rang_pkg.ALL;

entity add_mod_tree_T is
	Generic (constant proj : natural;
			   constant num_mod_T : natural);
    Port (input	: in   b_mul_T_type;
          output : out  unsigned(mod_bc-1 downto 0));
end add_mod_tree_T;

architecture Behavioral of add_mod_tree_T is

	constant p_bc   : natural := output'length;	-- разрядность модуля
	
	-- количество элементов разбиения (входов первого слоя)
	constant dc : natural := k;
	
	-- количество элементов на входе слоя с номером layer_num
	function LayerInputSize (layer_num: natural; digit_count: natural) return natural is
		variable result : natural;
	begin
		result := digit_count;
		for i in 2 to layer_num loop
			result := (result / 2) + (result mod 2);
		end loop;
		return result;
	end LayerInputSize;
	
	-- начальная позиция элементов слоя layer_num в в общем массиве сигналов
	function LayerStart (layer_num: natural; digit_count: natural) return natural is
		variable result : natural;
	begin
		result := 0;
		for i in 1 to layer_num-1 loop
			result := result + LayerInputSize(i, digit_count);
		end loop;
		return result;
	end LayerStart;
	
	-- количество слоев - натуральный логарифм от количества элементов первого слоя (разбиения)
	-- с округлением вверх
	function LayersCount(digit_count: in natural) return natural is
		variable res : natural;
		variable vn  : unsigned(31 downto 0);	-- число, учитывающее границы типа natural
	begin
		res := 0;
		
		vn := to_unsigned(digit_count-1, 32);		-- digit_count-1 чтобы верно считать log(2^t)
		
		-- считаем количество бит в числе vn
		while to_integer(vn) /= 0 loop
			res := res + 1;
			vn := vn srl 1;
		end loop;
		
		return res;
	end function LayersCount;
	
	-- общее количество элементов на всех слоях, включая выходной
	function AllLayersSize(layers_count, digit_count : in natural) return natural is
		variable res : natural;
	begin
		res := 0;
		
		-- складываются количества элеметов на всех слоях плюс выходной элемент
		for ln in 1 to layers_count+1 loop
			res := res + LayerInputSize(ln, digit_count);
		end loop;
		
		return res;
	end function AllLayersSize;
	
	
	-- блок констант, требуемых в вычислениях
	
	constant lc : natural := LayersCount(dc);					-- количество слоев
	
	constant als : natural := AllLayersSize(lc, dc);		-- количество элементов на всех слоях
	
	-- массив элементов, требуемых в вычислениях на всех слоях
	-- связывает предыдущий и следующий слои
	-- является массивом, формируемым последовательно из выходов каждого слоя
	type digits_array is array (0 to als-1) of unsigned(p_bc-1 downto 0); 
	signal digits : digits_array;	
	
	-- Подключение компонетна для модульного сложения двух чисел
	COMPONENT Add_mod
	GENERIC (
		p : unsigned
	);
	PORT(
		A : IN  unsigned (p_bc-1 downto 0);
		B : IN  unsigned (p_bc-1 downto 0);          
		Sum_mod : OUT unsigned (p_bc-1 downto 0)
	);
	END COMPONENT;
	
begin

	-- генерирование последовательности слоев
	layers: for i in 1 to lc generate
    begin
		
        level_1: for i in 0 to dc-1 generate
        begin
            digits(i) <= input(i);
        end generate level_1;
		-- уровень 2: сложение элементов бинарным сдваиванием
		level_2: for j in 0 to LayerInputSize(i,dc)/2 - 1  generate
		begin
			Add_mod_inst: Add_mod 
			GENERIC MAP (
				p => m((f-proj-1)*k+num_mod_T)
			)
			PORT MAP(
				A => digits(LayerStart(i, dc) + j),
				B => digits(LayerStart(i, dc) + LayerInputSize(i,dc) - 1 - j),
				Sum_mod => digits(LayerStart(i + 1, dc) + j)
			);
		end generate level_2;
		
		-- перенос несдвоенного элемента в случае нечетного числа элеменов на слое
		if_odd: if ((LayerInputSize(i,dc) mod 2) = 1) generate
			digits(LayerStart(i+1,dc) + LayerInputSize(i+1,dc)-1) <= digits(LayerStart(i,dc) + LayerInputSize(i,dc)/2);
		end generate if_odd;
		
	end generate layers;

	-- формирование выходного сигнала
	output <= digits(AllLayersSize(lc, dc)-1);
	
end Behavioral;