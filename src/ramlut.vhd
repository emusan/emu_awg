----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:10:50 03/29/2014 
-- Design Name: 
-- Module Name:    ramlut - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ramlut is
	generic(
		sine_length_bits: integer := 10
	);
	port(
		x_in: in std_logic_vector(sine_length_bits-1 downto 0);
		sine_out: out std_logic_vector(11 downto 0); -- 12 bit output for DAC
		clk: in std_logic
	);
end ramlut;

architecture Behavioral of ramlut is

	type sine_mem_type is array (0 to (2**sine_length_bits) - 1) of unsigned(11 downto 0);
	
	function initialize_ram return sine_mem_type is
		variable temp_mem: sine_mem_type;
		constant x_scale: real := 0.000976;
		constant y_adjust: real := 1.0;
		constant y_scale: real := 2047.0;
	begin
		for i in 0 to (2**sine_length_bits) - 1 loop
			temp_mem(i) := to_unsigned(integer((sin(real(i) * 2.0 * MATH_PI * x_scale) + y_adjust) * y_scale),12);
		end loop;
		return temp_mem;
	end;
	
	constant sine_mem: sine_mem_type := initialize_ram;
begin

	process(clk)
	begin
		if(rising_edge(clk)) then
			sine_out <= std_logic_vector(sine_mem(to_integer(unsigned(x_in))));
		end if;
	end process;

end Behavioral;

