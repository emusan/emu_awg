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
--use IEEE.NUMERIC_STD.ALL;

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
			x_out: out std_logic_vector(sine_length_bits-1 downto 0);
			spi_ready: in std_logic;
			spi_send_data: out std_logic;
			channel: out std_logic_vector(1 downto 0);
			clk: in std_logic
		);
	end component;
	
	signal spi_ready: std_logic;
	signal spi_channel: std_logic_vector(1 downto 0);
	signal spi_send_data: std_logic;
	signal spi_sine_data: std_logic_vector(11 downto 0);
	signal x_sig: std_logic_vector(9 downto 0);
	
begin
	spi: dac_spi port map(SPI_SS_B,AMP_CS,AD_CONV,SF_CE0,FPGA_INIT_B,SPI_MOSI,DAC_CS,SPI_SCK,DAC_CLR,
								spi_ready,spi_channel,spi_send_data,spi_sine_data,'0',clk);
								
	sinelut: ramlut port map(x_sig,spi_sine_data,clk);
	
	controller: simple_control port map(x_sig,spi_ready,spi_send_data,spi_channel,clk);

end Structural;

