----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:53:27 04/04/2014 
-- Design Name: 
-- Module Name:    spi_buffer - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_buffer is
	port(
		sine_in: in std_logic_vector(47 downto 0); -- ch1 (11 downto 0) ch2 (23 downto 12) ch3 (35 downto 24) ch4 (47 downto 36)
		square_in: in std_logic_vector(47 downto 0); -- ch1 (11 downto 0) ch2 (23 downto 12) ch3 (35 downto 24) ch4 (47 downto 36)
		ch_select: in std_logic_vector(3 downto 0);
		spi_sine_out: out std_logic_vector(11 downto 0);
		spi_ready: in std_logic;
		channel: in std_logic_vector(1 downto 0);
		clk: in std_logic
	);	
end spi_buffer;

architecture Behavioral of spi_buffer is

begin

	process(clk)
	begin
		if(rising_edge(clk)) then
			if(spi_ready = '1') then
				case channel is
					when "00" => 
						if(ch_select(0) = '0') then
							spi_sine_out <= sine_in(11 downto 0);
						else 
							spi_sine_out <= square_in(11 downto 0);
						end if;
					when "01" =>
						if(ch_select(1) = '0') then
							spi_sine_out <= sine_in(23 downto 12);
						else 
							spi_sine_out <= square_in(23 downto 12);
						end if;
					when "10" => 
						if(ch_select(2) = '0') then
							spi_sine_out <= sine_in(35 downto 24);
						else 
							spi_sine_out <= square_in(35 downto 24);
						end if;
					when "11" => 
						if(ch_select(3) = '0') then
							spi_sine_out <= sine_in(47 downto 36);
						else 
							spi_sine_out <= square_in(47 downto 36);
						end if;
					when others => spi_sine_out <= (others => '0');
				end case;
			end if;
		end if;
	end process;

end Behavioral;

