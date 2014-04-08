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
		ch1_sine_in: in std_logic_vector(11 downto 0);
		ch1_square_in: in std_logic_vector(11 downto 0);
		ch1_select: in std_logic;
		--ch2_in: in std_logic_vector(11 downto 0);
		--ch3_in: in std_logic_vector(11 downto 0);
		--ch4_in: in std_logic_vector(11 downto 0);
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
				if(ch1_select = '0') then
					case channel is
						when "00" => spi_sine_out <= ch1_sine_in;
						--when "01" => spi_sine_out <= ch2_in;
						--when "10" => spi_sine_out <= ch3_in;
						--when "11" => spi_sine_out <= ch4_in;
						when others => spi_sine_out <= (others => '0');
					end case;
				else
					case channel is
						when "00" => spi_sine_out <= ch1_square_in;
						--when "01" => spi_sine_out <= ch2_in;
						--when "10" => spi_sine_out <= ch3_in;
						--when "11" => spi_sine_out <= ch4_in;
						when others => spi_sine_out <= (others => '0');
					end case;
				end if;
			end if;
		end if;
	end process;

end Behavioral;

