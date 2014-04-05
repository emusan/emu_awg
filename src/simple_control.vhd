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
		-- spi control related
		spi_ready: in std_logic;
		spi_send_data: out std_logic;
		channel: out std_logic_vector(1 downto 0);
		
		-- sine wave control related
		freq_mult: out std_logic_vector(9 downto 0);
		phase_adjust: out std_logic_vector(9 downto 0);
		amplitude_adjust: out std_logic_vector(5 downto 0);
		
		-- control related
		current_mode: out std_logic_vector (1 downto 0); -- 00 = freq, 01 = phase, 10 = amplitude
		button: in std_logic_vector(3 downto 0); -- 0 = down, 1 = up, 2 = left, 3 = right
		rotary_direction: in std_logic;
		rotary_pulse: in std_logic;
		clk: in std_logic
	);
end simple_control;

architecture Behavioral of simple_control is
	signal ready: std_logic;
	signal spi_send_sig: std_logic;
	
	signal freq_mult_sig: std_logic_vector(9 downto 0);
	signal phase_adjust_sig: std_logic_vector(9 downto 0);
	signal amplitude_adjust_sig: std_logic_vector(5 downto 0);
	
	signal current_mode_sig: std_logic_vector(1 downto 0);
begin
	spi: process(clk)
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
				end if;
			end if;
		end if;
	end process;
	
	channel <= "00";
	spi_send_data <= spi_send_sig;
	
	button_handle: process(clk)
	begin
		if(rising_edge(clk)) then
			if(button = "0001") then
				if(to_integer(unsigned(current_mode_sig)) > 0) then
					current_mode_sig <= std_logic_vector(unsigned(current_mode_sig) - 1);
				end if;
			elsif(button = "0010") then
				if(to_integer(unsigned(current_mode_sig)) < 3) then
					current_mode_sig <= std_logic_vector(unsigned(current_mode_sig) + 1);
				end if;
			end if;
		end if;
	end process;
	
	current_mode <= current_mode_sig;
	
	mode_handle: process(clk)
	begin
		if(rising_edge(clk)) then
			if(current_mode_sig = "00") then -- freq adjust
				if(rotary_pulse = '1') then
					if(rotary_direction = '1') then
						freq_mult_sig <= std_logic_vector(unsigned(freq_mult_sig) + 1);
					else
						freq_mult_sig <= std_logic_vector(unsigned(freq_mult_sig) - 1);
					end if;
				end if;
			elsif(current_mode_sig = "01") then -- phase adjust
				if(rotary_pulse = '1') then
					if(rotary_direction = '1') then
						phase_adjust_sig <= std_logic_vector(unsigned(phase_adjust_sig) + 1);
					else
						phase_adjust_sig <= std_logic_vector(unsigned(phase_adjust_sig) - 1);
					end if;
				end if;
			elsif(current_mode_sig = "10") then -- amplitude adjust
				if(rotary_pulse = '1') then
					if(rotary_direction = '1') then
						amplitude_adjust_sig <= std_logic_vector(unsigned(amplitude_adjust_sig) + 1);
					else
						amplitude_adjust_sig <= std_logic_vector(unsigned(amplitude_adjust_sig) - 1);
					end if;
				end if;
			end if;
		end if;
	end process;
	
	freq_mult <= freq_mult_sig;
	phase_adjust <= phase_adjust_sig;
	amplitude_adjust <= amplitude_adjust_sig;

end Behavioral;

