----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:25:40 04/04/2014 
-- Design Name: 
-- Module Name:    amplitude_adjust - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity amplitude_adjust is
	port(
		x_in: in std_logic_vector(11 downto 0);
		x_out: out std_logic_vector(11 downto 0);
		adjust: in std_logic_vector(5 downto 0)
	);
end amplitude_adjust;

architecture Behavioral of amplitude_adjust is

	signal one_shift: unsigned(11 downto 0);
	signal two_shift: unsigned(11 downto 0);
	signal three_shift: unsigned(11 downto 0);
	signal four_shift: unsigned(11 downto 0);
	signal five_shift: unsigned(11 downto 0);
	signal six_shift: unsigned(11 downto 0);
	
begin
	one_shift <= unsigned(x_in) srl 1 when adjust(5) = '1' else (others => '0');
	two_shift <= unsigned(x_in) srl 2 when adjust(4) = '1' else (others => '0');
	three_shift <= unsigned(x_in) srl 3 when adjust(3) = '1' else (others => '0');
	four_shift <= unsigned(x_in) srl 4 when adjust(2) = '1' else (others => '0');
	five_shift <= unsigned(x_in) srl 5 when adjust(1) = '1' else (others => '0');
	six_shift <= unsigned(x_in) srl 5 when adjust(0) = '1' else (others => '0');
	
	x_out <= x_in when adjust = "111111" else
				std_logic_vector(one_shift + two_shift + three_shift + four_shift + five_shift + six_shift);
	
end Behavioral;

