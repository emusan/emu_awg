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
		sine_in: in std_logic_vector(11 downto 0);
		sine_out: out std_logic_vector(11 downto 0);
		adjust: in std_logic_vector(5 downto 0);
		clk: in std_logic
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

	process(clk)
	begin
		if(rising_edge(clk)) then
			if adjust(5) = '1' then
				one_shift <= unsigned(sine_in) srl 1;
			else 
				one_shift <= (others => '0');
			end if;
			if adjust(4) = '1' then
				two_shift <= unsigned(sine_in) srl 2;
			else 
				two_shift <= (others => '0');
			end if;
			if adjust(3) = '1' then
				three_shift <= unsigned(sine_in) srl 3;
			else 
				three_shift <= (others => '0');
			end if;
			if adjust(2) = '1' then
				four_shift <= unsigned(sine_in) srl 4;
			else 
				four_shift <= (others => '0');
			end if;
			if adjust(1) = '1' then
				five_shift <= unsigned(sine_in) srl 5;
			else 
				five_shift <= (others => '0');
			end if;
			if adjust(0) = '1' then
				six_shift <= unsigned(sine_in) srl 5;
			else 
				six_shift <= (others => '0');
			end if;
--			
--				four_shift <= unsigned(sine_in) srl 4 if adjust(2) = '1' else (others => '0');
--				five_shift <= unsigned(sine_in) srl 5 if adjust(1) = '1' else (others => '0');
--				six_shift <= unsigned(sine_in) srl 5 if adjust(0) = '1' else (others => '0');
			
			if(adjust = "111111") then
				sine_out <= sine_in;
			else
				sine_out <= std_logic_vector(one_shift + two_shift + three_shift + four_shift + five_shift + six_shift);
			end if;
						
		end if;
	end process;
	
end Behavioral;

