----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:43:10 04/02/2014 
-- Design Name: 
-- Module Name:    simple_control - Behavioral 
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

entity simple_control is
	generic(
		sine_length_bits: integer := 10
	);
	port(
		x_out: out std_logic_vector(sine_length_bits-1 downto 0);
		spi_ready: in std_logic;
		spi_send_data: out std_logic;
		channel: out std_logic_vector(1 downto 0);
		clk: in std_logic
	);
end simple_control;

architecture Behavioral of simple_control is
	signal ready: std_logic;
	signal spi_send_sig: std_logic;
	signal x_sig: integer range 0 to ((2**sine_length_bits) - 1);
begin
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(spi_send_sig <= '1') then
				spi_send_sig <= '0';
			end if;
			if(spi_ready = '1') then
				if(ready = '1') then
					spi_send_sig <= '1';
					ready <= '0';
				else
					ready <= '1';
					x_sig <= x_sig + 1;
				end if;
			end if;
		end if;
	end process;
	
	channel <= "00";
	spi_send_data <= spi_send_sig;
	x_out <= std_logic_vector(to_unsigned(x_sig,10));

end Behavioral;

