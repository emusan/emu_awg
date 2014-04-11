----------------------------------------------------------------------------------
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
		spi_channel: out std_logic_vector(1 downto 0);
		
		-- sine wave control related
		ch1_freq_mult: out std_logic_vector(9 downto 0);
		ch1_phase_adjust: out std_logic_vector(7 downto 0);
		ch1_amplitude_adjust: out std_logic_vector(5 downto 0);
		ch1_pwm_adjust: out std_logic_vector(9 downto 0);
		--ch2
		ch2_freq_mult: out std_logic_vector(9 downto 0);
		ch2_phase_adjust: out std_logic_vector(7 downto 0);
		ch2_amplitude_adjust: out std_logic_vector(5 downto 0);
		ch2_pwm_adjust: out std_logic_vector(9 downto 0);
		--ch3
		ch3_freq_mult: out std_logic_vector(9 downto 0);
		ch3_phase_adjust: out std_logic_vector(7 downto 0);
		ch3_amplitude_adjust: out std_logic_vector(5 downto 0);
		ch3_pwm_adjust: out std_logic_vector(9 downto 0);
		--ch4
		ch4_freq_mult: out std_logic_vector(9 downto 0);
		ch4_phase_adjust: out std_logic_vector(7 downto 0);
		ch4_amplitude_adjust: out std_logic_vector(5 downto 0);
		ch4_pwm_adjust: out std_logic_vector(9 downto 0);
		
		-- control related
		current_mode: out std_logic_vector (1 downto 0); -- 00 = freq, 01 = phase, 10 = amplitude
		current_channel: out std_logic_vector(1 downto 0);
		button: in std_logic_vector(3 downto 0); -- 0 = down, 1 = up, 2 = left, 3 = right
		rotary_direction: in std_logic;
		rotary_pulse: in std_logic;
		clk: in std_logic
	);
end simple_control;

architecture Behavioral of simple_control is
	signal ready: std_logic;
	signal spi_send_sig: std_logic;
	signal spi_channel_sig: std_logic_vector(1 downto 0) := "00";
	signal spi_channel_incremented: std_logic;
	
	signal freq_mult_sig: std_logic_vector(9 downto 0);
	signal phase_adjust_sig: std_logic_vector(7 downto 0);
	signal amplitude_adjust_sig: std_logic_vector(5 downto 0) := (others => '1');
	signal pwm_adjust_sig: std_logic_vector(9 downto 0);
	
	-- stores last value for this channel (useful when switching channels)
	signal ch1_freq_mult_reg: std_logic_vector(9 downto 0);
	signal ch1_phase_adjust_reg: std_logic_vector(7 downto 0);
	signal ch1_amp_adjust_reg: std_logic_vector(5 downto 0) := (others => '1');
	signal ch1_pwm_adjust_reg: std_logic_vector(9 downto 0);
	-- ch2
	signal ch2_freq_mult_reg: std_logic_vector(9 downto 0);
	signal ch2_phase_adjust_reg: std_logic_vector(7 downto 0);
	signal ch2_amp_adjust_reg: std_logic_vector(5 downto 0) := (others => '1');
	signal ch2_pwm_adjust_reg: std_logic_vector(9 downto 0);
	-- ch3
	signal ch3_freq_mult_reg: std_logic_vector(9 downto 0);
	signal ch3_phase_adjust_reg: std_logic_vector(7 downto 0);
	signal ch3_amp_adjust_reg: std_logic_vector(5 downto 0) := (others => '1');
	signal ch3_pwm_adjust_reg: std_logic_vector(9 downto 0);
	-- ch4
	signal ch4_freq_mult_reg: std_logic_vector(9 downto 0);
	signal ch4_phase_adjust_reg: std_logic_vector(7 downto 0);
	signal ch4_amp_adjust_reg: std_logic_vector(5 downto 0) := (others => '1');
	signal ch4_pwm_adjust_reg: std_logic_vector(9 downto 0);
	
	signal current_mode_sig: std_logic_vector(1 downto 0);
	signal current_channel_sig: std_logic_vector(1 downto 0);
begin
	spi: process(clk)
	begin
		if(rising_edge(clk)) then
			if(spi_send_sig = '1') then
				spi_send_sig <= '0';
			end if;
			if(spi_ready = '1') then
				if(ready = '1') then
					if(spi_channel_incremented = '0') then
						spi_channel_incremented <= '1';
						spi_channel_sig <= std_logic_vector(unsigned(spi_channel_sig) + 1);
					end if;
					spi_send_sig <= '1';
					ready <= '0';
				else
					ready <= '1';
				end if;
			else
				spi_channel_incremented <= '0';
			end if;
		end if;
	end process;
	
	spi_channel <= spi_channel_sig;
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
			if(button = "0000") then
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
				elsif(current_mode_sig = "11") then -- pwm adjust (for square wave)
					if(rotary_pulse = '1') then
						if(rotary_direction = '1') then
							pwm_adjust_sig <= std_logic_vector(unsigned(pwm_adjust_sig) + 1);
						else
							pwm_adjust_sig <= std_logic_vector(unsigned(pwm_adjust_sig) - 1);
						end if;
					end if;
				end if;
			elsif(button = "1000") then
				current_channel_sig <= std_logic_vector(unsigned(current_channel_sig) + 1);
				case current_channel_sig is
					when "00" => freq_mult_sig <= ch2_freq_mult_reg;
									 ch1_freq_mult_reg <= freq_mult_sig;
									 
									 amplitude_adjust_sig <= ch2_amp_adjust_reg;
									 ch1_amp_adjust_reg <= amplitude_adjust_sig;
									 
									 phase_adjust_sig <= ch2_phase_adjust_reg;
									 ch1_phase_adjust_reg <= phase_adjust_sig;
									 
									 pwm_adjust_sig <= ch2_pwm_adjust_reg;
									 ch1_pwm_adjust_reg <= pwm_adjust_sig;
									 
					when "01" => freq_mult_sig <= ch3_freq_mult_reg;
									 ch2_freq_mult_reg <= freq_mult_sig;
									 
									 amplitude_adjust_sig <= ch3_amp_adjust_reg;
									 ch2_amp_adjust_reg <= amplitude_adjust_sig;
									 
									 phase_adjust_sig <= ch3_phase_adjust_reg;
									 ch2_phase_adjust_reg <= phase_adjust_sig;
									 
									 pwm_adjust_sig <= ch3_pwm_adjust_reg;
									 ch2_pwm_adjust_reg <= pwm_adjust_sig;
									 
					when "10" => freq_mult_sig <= ch4_freq_mult_reg;
									 ch3_freq_mult_reg <= freq_mult_sig;
									 
									 amplitude_adjust_sig <= ch4_amp_adjust_reg;
									 ch3_amp_adjust_reg <= amplitude_adjust_sig;
									 
									 phase_adjust_sig <= ch4_phase_adjust_reg;
									 ch3_phase_adjust_reg <= phase_adjust_sig;
									 
									 pwm_adjust_sig <= ch4_pwm_adjust_reg;
									 ch3_pwm_adjust_reg <= pwm_adjust_sig;
									 
					when "11" => freq_mult_sig <= ch1_freq_mult_reg;
									 ch4_freq_mult_reg <= freq_mult_sig;
									 
									 amplitude_adjust_sig <= ch1_amp_adjust_reg;
									 ch4_amp_adjust_reg <= amplitude_adjust_sig;
									 
									 phase_adjust_sig <= ch1_phase_adjust_reg;
									 ch4_phase_adjust_reg <= phase_adjust_sig;
									 
									 pwm_adjust_sig <= ch1_pwm_adjust_reg;
									 ch4_pwm_adjust_reg <= pwm_adjust_sig;
									 
					when others => freq_mult_sig <= ch1_freq_mult_reg;
										ch4_freq_mult_reg <= freq_mult_sig;
				end case;
--			elsif (button = "0100") then
--				current_channel_sig <= std_logic_vector(unsigned(current_channel_sig) - 1);
--				case current_channel_sig is
--					when "00" => freq_mult_sig <= ch4_freq_mult_reg;
--									 ch1_freq_mult_reg <= freq_mult_sig;
--					when "01" => freq_mult_sig <= ch1_freq_mult_reg;
--									 ch2_freq_mult_reg <= freq_mult_sig;
--					when "10" => freq_mult_sig <= ch2_freq_mult_reg;
--									 ch3_freq_mult_reg <= freq_mult_sig;
--					when "11" => freq_mult_sig <= ch3_freq_mult_reg;
--									 ch4_freq_mult_reg <= freq_mult_sig;
--					when others => freq_mult_sig <= ch1_freq_mult_reg;
--										ch4_freq_mult_reg <= freq_mult_sig;
--				end case;
			end if;
		end if;
	end process;
	
	ch1_freq_mult <= freq_mult_sig when current_channel_sig = "00" else ch1_freq_mult_reg;
	ch1_phase_adjust <= phase_adjust_sig when current_channel_sig = "00" else ch1_phase_adjust_reg;
	ch1_amplitude_adjust <= amplitude_adjust_sig when current_channel_sig = "00" else ch1_amp_adjust_reg;
	ch1_pwm_adjust <= pwm_adjust_sig when current_channel_sig = "00" else ch1_pwm_adjust_reg;
	
	ch2_freq_mult <= freq_mult_sig when current_channel_sig = "01" else ch2_freq_mult_reg;
	ch2_phase_adjust <= phase_adjust_sig when current_channel_sig = "01" else ch2_phase_adjust_reg;
	ch2_amplitude_adjust <= amplitude_adjust_sig when current_channel_sig = "01" else ch2_amp_adjust_reg;
	ch2_pwm_adjust <= pwm_adjust_sig when current_channel_sig = "01" else ch2_pwm_adjust_reg;
	
	ch3_freq_mult <= freq_mult_sig when current_channel_sig = "10" else ch3_freq_mult_reg;
	ch3_phase_adjust <= phase_adjust_sig when current_channel_sig = "10" else ch3_phase_adjust_reg; 
	ch3_amplitude_adjust <= amplitude_adjust_sig when current_channel_sig = "10" else ch3_amp_adjust_reg;
	ch3_pwm_adjust <= pwm_adjust_sig when current_channel_sig = "10" else ch3_pwm_adjust_reg;
	
	ch4_freq_mult <= freq_mult_sig when current_channel_sig = "11" else ch4_freq_mult_reg;
	ch4_phase_adjust <= phase_adjust_sig when current_channel_sig = "11" else ch4_phase_adjust_reg;
	ch4_amplitude_adjust <= amplitude_adjust_sig when current_channel_sig = "11" else ch4_amp_adjust_reg;
	ch4_pwm_adjust <= pwm_adjust_sig when current_channel_sig = "11" else ch4_pwm_adjust_reg;
	
--	channel_handle: process(clk)
--	begin
--		if(rising_edge(clk)) then
--			if(button = "1000") then
--				current_channel_sig <= std_logic_vector(unsigned(current_channel_sig) + 1);
--				case current_channel_sig is
--					when "00" => freq_mult_sig <= ch2_freq_mult_reg;
--									 ch1_freq_mult_reg <= freq_mult_sig;
--					when "01" => freq_mult_sig <= ch3_freq_mult_reg;
--									 ch2_freq_mult_reg <= freq_mult_sig;
--					when "10" => freq_mult_sig <= ch4_freq_mult_reg;
--									 ch3_freq_mult_reg <= freq_mult_sig;
--					when "11" => freq_mult_sig <= ch1_freq_mult_reg;
--									 ch4_freq_mult_reg <= freq_mult_sig;
--					when others => freq_mult_sig <= ch1_freq_mult_reg;
--										ch4_freq_mult_reg <= freq_mult_sig;
--				end case;
--			elsif (button = "0100") then
--				current_channel_sig <= std_logic_vector(unsigned(current_channel_sig) - 1);
--				case current_channel_sig is
--					when "00" => freq_mult_sig <= ch4_freq_mult_reg;
--									 ch1_freq_mult_reg <= freq_mult_sig;
--					when "01" => freq_mult_sig <= ch1_freq_mult_reg;
--									 ch2_freq_mult_reg <= freq_mult_sig;
--					when "10" => freq_mult_sig <= ch2_freq_mult_reg;
--									 ch3_freq_mult_reg <= freq_mult_sig;
--					when "11" => freq_mult_sig <= ch3_freq_mult_reg;
--									 ch4_freq_mult_reg <= freq_mult_sig;
--					when others => freq_mult_sig <= ch1_freq_mult_reg;
--										ch4_freq_mult_reg <= freq_mult_sig;
--				end case;
--			end if;
--		end if;
--	end process;
	
	current_channel <= current_channel_sig;

end Behavioral;

