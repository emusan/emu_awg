----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:55:57 04/02/2014 
-- Design Name: 
-- Module Name:    function_gen_struct - Structural 
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
 
entity function_gen_struct is
	port(
		SPI_SS_B: out std_logic;
		AMP_CS: out std_logic;
		AD_CONV: out std_logic;
		SF_CE0: out std_logic;
		FPGA_INIT_B: out std_logic;
		
		SPI_MOSI: out std_logic;
		DAC_CS: out std_logic;
		SPI_SCK: out std_logic;
		DAC_CLR: out std_logic;
		
		button_in: in std_logic_vector(3 downto 0); -- 0 = down, 1 = up, 2 = left, 3 = right
		rot_a: in std_logic;
		rot_b: in std_logic;
		current_mode: out std_logic_vector(1 downto 0);
		current_channel: out std_logic_vector(1 downto 0);
		
		switch: in std_logic_vector(3 downto 0);
		
		clk: in std_logic
	);
end function_gen_struct;

architecture Structural of function_gen_struct is
	component dac_spi is
		port(
			--- other devices on SPI BUS ---
			SPI_SS_B: out std_logic;  -- set to 1 when DAC in use
			AMP_CS: out std_logic;  -- set to 1 when DAC in use
			AD_CONV: out std_logic;  -- set to 0 when DAC in use
			SF_CE0: out std_logic;  -- set to 1 when DAC in use
			FPGA_INIT_B: out std_logic;  -- set to 1 when DAC in use
			--- this device ---
			SPI_MOSI: out std_logic;  -- Master output, slave (DAC) input
			DAC_CS: out std_logic;  -- chip select
			SPI_SCK: out std_logic;  -- spi clock
			DAC_CLR: out std_logic;  -- reset
			--SPI_MISO: in std_logic;  -- Master input, slave (DAC) output
			--- control ---
			ready_flag: out std_logic;  -- sending data flag
			channel: in std_logic_vector(1 downto 0);
			send_data: in std_logic;  -- send sine data over SPI
			sine_data: in std_logic_vector(11 downto 0);
			reset_dac: in std_logic;
			clk: in std_logic  -- master clock
		);
	end component;
	
	component buttonStructural is
		port(
			button_in: in std_logic_vector(3 downto 0); -- 0 = down, 1 = up, 2 = left, 3 = right
			rot_a: in std_logic;
			rot_b: in std_logic;
			button_out: out std_logic_vector(3 downto 0); -- 0 = down, 1 = up, 2 = left, 3 = right
			direction: out std_logic;
			pulse: out std_logic;
			clk: in std_logic
		);
	end component;
	
	component ramlut is
		generic(
			sine_length_bits: integer := 10
		);
		port(
			x_in: in std_logic_vector(sine_length_bits-1 downto 0);
			sine_out: out std_logic_vector(11 downto 0); -- 12 bit output for DAC
			clk: in std_logic
		);
	end component;
	
	component simple_control is
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
	end component;
	
	component amplitude_adjust is
		port(
			sine_in: in std_logic_vector(11 downto 0);
			sine_out: out std_logic_vector(11 downto 0);
			adjust: in std_logic_vector(5 downto 0);
			clk: in std_logic
		);
	end component;
	
	component spi_buffer is
		port(
			sine_in: in std_logic_vector(47 downto 0); -- ch1 (11 downto 0) ch2 (23 downto 12) ch3 (35 downto 24) ch4 (47 downto 36)
			square_in: in std_logic_vector(47 downto 0); -- ch1 (11 downto 0) ch2 (23 downto 12) ch3 (35 downto 24) ch4 (47 downto 36)
			ch_select: in std_logic_vector(3 downto 0);
			spi_sine_out: out std_logic_vector(11 downto 0);
			spi_ready: in std_logic;
			channel: in std_logic_vector(1 downto 0);
			clk: in std_logic
		);	
	end component;
	
	component phase_acc is
		generic(
			sine_length_bits: integer := 10
		);
		port(
			x_out: out std_logic_vector(sine_length_bits - 1 downto 0);
			freq_mult: in std_logic_vector(9 downto 0);
			phase_in: in std_logic_vector(7 downto 0);
			clk: in std_logic
		);
	end component;
	
	component square_wave is
		generic(
		square_wave_length: integer := 10
		);
		port(
		x_in: in std_logic_vector(square_wave_length - 1 downto 0);
		square_out: out std_logic_vector(11 downto 0);
		pwm_length: in std_logic_vector(square_wave_length - 1 downto 0)
		);
	end component;
	
	signal spi_ready: std_logic;
	signal spi_channel: std_logic_vector(1 downto 0);
	signal spi_send_data: std_logic;
	signal spi_sine_data: std_logic_vector(11 downto 0);
	
	signal amplified_sine: std_logic_vector(47 downto 0); -- ch1 (11 downto 0) ch2 (23 downto 12) ch3 (35 downto 24) ch4 (47 downto 36)
	signal amplified_square: std_logic_vector(47 downto 0); -- ch1 (11 downto 0) ch2 (23 downto 12) ch3 (35 downto 24) ch4 (47 downto 36)
	
	signal raw_sine: std_logic_vector(47 downto 0); -- ch1 (11 downto 0) ch2 (23 downto 12) ch3 (35 downto 24) ch4 (47 downto 36)
	signal raw_square: std_logic_vector(47 downto 0); -- ch1 (11 downto 0) ch2 (23 downto 12) ch3 (35 downto 24) ch4 (47 downto 36)
	signal amp_adjust: std_logic_vector(23 downto 0) := (others => '1'); -- ch1 (5 downto 0) ch2 (11 downto 6) ch3 (17 downto 12) ch4 (23 downto 18)
	
	signal x_sig: std_logic_vector(39 downto 0); -- ch 1 (9 downto 0) ch2 (19 downto 10) ch3 (29 downto 20) ch4 (39 downto 30)
	signal freq_adjust: std_logic_vector(39 downto 0); -- ch 1 (9 downto 0) ch2 (19 downto 10) ch3 (29 downto 20) ch4 (39 downto 30)
	signal phase_adjust: std_logic_vector(31 downto 0); -- ch 1 (7 downto 0) ch2 (15 downto 8) ch3 (23 downto 16) ch4 (31 downto 24)
	signal pwm_adjust: std_logic_vector(39 downto 0); -- ch 1 (9 downto 0) ch2 (19 downto 10) ch3 (29 downto 20) ch4 (39 downto 30)
	
	--signal current_mode: std_logic_vector(1 downto 0);
	signal button_sig: std_logic_vector(3 downto 0);
	signal rotary_direction: std_logic;
	signal rotary_pulse: std_logic;
	
begin
	spi: dac_spi port map(SPI_SS_B,AMP_CS,AD_CONV,SF_CE0,FPGA_INIT_B,SPI_MOSI,DAC_CS,SPI_SCK,DAC_CLR,
								spi_ready,spi_channel,spi_send_data,spi_sine_data,'0',clk);
	spi_buffer_thing: spi_buffer port map(amplified_sine,amplified_square,switch,spi_sine_data,spi_ready,spi_channel,clk);
	
	----------------------------------------------------------------------------------------------
	ch1_phase_accumulator: phase_acc port map(x_sig(9 downto 0),freq_adjust(9 downto 0),phase_adjust(7 downto 0),clk);
	ch1_sinelut: ramlut port map(x_sig(9 downto 0),raw_sine(11 downto 0),clk);
	ch1_square: square_wave port map (x_sig(9 downto 0),raw_square(11 downto 0),pwm_adjust(9 downto 0));
	ch1_sine_amplitude: amplitude_adjust port map(raw_sine(11 downto 0),amplified_sine(11 downto 0),amp_adjust(5 downto 0),clk);
	ch1_square_amplitude: amplitude_adjust port map(raw_square(11 downto 0),amplified_square(11 downto 0),amp_adjust(5 downto 0),clk);
	
	-- ch2 stuff
	ch2_phase_accumulator: phase_acc port map(x_sig(19 downto 10),freq_adjust(19 downto 10),phase_adjust(15 downto 8),clk);
	ch2_sinelut: ramlut port map(x_sig(19 downto 10),raw_sine(23 downto 12),clk);
	ch2_square: square_wave port map (x_sig(19 downto 10),raw_square(23 downto 12),pwm_adjust(19 downto 10));
	ch2_sine_amplitude: amplitude_adjust port map(raw_sine(23 downto 12),amplified_sine(23 downto 12),amp_adjust(11 downto 6),clk);
	ch2_square_amplitude: amplitude_adjust port map(raw_square(23 downto 12),amplified_square(23 downto 12),amp_adjust(11 downto 6),clk);
	-- ch3 stuff
	ch3_phase_accumulator: phase_acc port map(x_sig(29 downto 20),freq_adjust(29 downto 20),phase_adjust(23 downto 16),clk);
	ch3_sinelut: ramlut port map(x_sig(29 downto 20),raw_sine(35 downto 24),clk);
	ch3_square: square_wave port map (x_sig(29 downto 20),raw_square(35 downto 24),pwm_adjust(29 downto 20));
	ch3_sine_amplitude: amplitude_adjust port map(raw_sine(35 downto 24),amplified_sine(35 downto 24),amp_adjust(17 downto 12),clk);
	ch3_square_amplitude: amplitude_adjust port map(raw_square(35 downto 24),amplified_square(35 downto 24),amp_adjust(17 downto 12),clk);
	-- ch4 stuff
	ch4_phase_accumulator: phase_acc port map(x_sig(39 downto 30),freq_adjust(39 downto 30),phase_adjust(31 downto 24),clk);
	ch4_sinelut: ramlut port map(x_sig(39 downto 30),raw_sine(47 downto 36),clk);
	ch4_square: square_wave port map (x_sig(39 downto 30),raw_square(47 downto 36),pwm_adjust(39 downto 30));
	ch4_sine_amplitude: amplitude_adjust port map(raw_sine(47 downto 36),amplified_sine(47 downto 36),amp_adjust(23 downto 18),clk);
	ch4_square_amplitude: amplitude_adjust port map(raw_square(47 downto 36),amplified_square(47 downto 36),amp_adjust(23 downto 18),clk);
	----------------------------------------------------------------------------------------------
	
	
	controller: simple_control port map(spi_ready,spi_send_data,spi_channel,
													freq_adjust(9 downto 0),phase_adjust(7 downto 0),amp_adjust(5 downto 0),pwm_adjust(9 downto 0),
													freq_adjust(19 downto 10),phase_adjust(15 downto 8),amp_adjust(11 downto 6),pwm_adjust(19 downto 10),
													freq_adjust(29 downto 20),phase_adjust(23 downto 16),amp_adjust(17 downto 12),pwm_adjust(29 downto 20),
													freq_adjust(39 downto 30),phase_adjust(31 downto 24),amp_adjust(23 downto 18),pwm_adjust(39 downto 30),
													current_mode,current_channel,button_sig,rotary_direction,rotary_pulse,clk);
-- spi control related
--			spi_ready: in std_logic;
--			spi_send_data: out std_logic;
--			spi_channel: out std_logic_vector(1 downto 0);
--			
--			-- sine wave control related
--			ch1_freq_mult: out std_logic_vector(9 downto 0);
--			ch1_phase_adjust: out std_logic_vector(7 downto 0);
--			ch1_amplitude_adjust: out std_logic_vector(5 downto 0);
--			ch1_pwm_adjust: out std_logic_vector(9 downto 0);
--			--ch2
--			ch2_freq_mult: out std_logic_vector(9 downto 0);
--			ch2_phase_adjust: out std_logic_vector(7 downto 0);
--			ch2_amplitude_adjust: out std_logic_vector(5 downto 0);
--			ch2_pwm_adjust: out std_logic_vector(9 downto 0);
--			--ch3
--			ch3_freq_mult: out std_logic_vector(9 downto 0);
--			ch3_phase_adjust: out std_logic_vector(7 downto 0);
--			ch3_amplitude_adjust: out std_logic_vector(5 downto 0);
--			ch3_pwm_adjust: out std_logic_vector(9 downto 0);
--			--ch4
--			ch4_freq_mult: out std_logic_vector(9 downto 0);
--			ch4_phase_adjust: out std_logic_vector(7 downto 0);
--			ch4_amplitude_adjust: out std_logic_vector(5 downto 0);
--			ch4_pwm_adjust: out std_logic_vector(9 downto 0);
--			
--			-- control related
--			current_mode: out std_logic_vector (1 downto 0); -- 00 = freq, 01 = phase, 10 = amplitude
--			current_channel: out std_logic_vector(1 downto 0);
--			button: in std_logic_vector(3 downto 0); -- 0 = down, 1 = up, 2 = left, 3 = right
--			rotary_direction: in std_logic;
--			rotary_pulse: in std_logic;
--			clk: in std_logic

	controls: buttonStructural port map(button_in,rot_a,rot_b,button_sig,rotary_direction,rotary_pulse,clk);
--			button_in: in std_logic_vector(3 downto 0); -- 0 = down, 1 = up, 2 = left, 3 = right
--			rot_a: in std_logic;
--			rot_b: in std_logic;
--			button_out: out std_logic_vector(3 downto 0); -- 0 = down, 1 = up, 2 = left, 3 = right
--			direction: out std_logic;
--			pulse: out std_logic;
--			clk: in std_logic
end Structural;

