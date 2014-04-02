--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:30:13 04/02/2014
-- Design Name:   
-- Module Name:   C:/Users/Tom/projs/code/function_gen_struct/function_gen_struct_test.vhd
-- Project Name:  function_gen_struct
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: function_gen_struct
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY function_gen_struct_test IS
END function_gen_struct_test;
 
ARCHITECTURE behavior OF function_gen_struct_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT function_gen_struct
    PORT(
         SPI_SS_B : OUT  std_logic;
         AMP_CS : OUT  std_logic;
         AD_CONV : OUT  std_logic;
         SF_CE0 : OUT  std_logic;
         FPGA_INIT_B : OUT  std_logic;
         SPI_MOSI : OUT  std_logic;
         DAC_CS : OUT  std_logic;
         SPI_SCK : OUT  std_logic;
         DAC_CLR : OUT  std_logic;
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';

 	--Outputs
   signal SPI_SS_B : std_logic;
   signal AMP_CS : std_logic;
   signal AD_CONV : std_logic;
   signal SF_CE0 : std_logic;
   signal FPGA_INIT_B : std_logic;
   signal SPI_MOSI : std_logic;
   signal DAC_CS : std_logic;
   signal SPI_SCK : std_logic;
   signal DAC_CLR : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: function_gen_struct PORT MAP (
          SPI_SS_B => SPI_SS_B,
          AMP_CS => AMP_CS,
          AD_CONV => AD_CONV,
          SF_CE0 => SF_CE0,
          FPGA_INIT_B => FPGA_INIT_B,
          SPI_MOSI => SPI_MOSI,
          DAC_CS => DAC_CS,
          SPI_SCK => SPI_SCK,
          DAC_CLR => DAC_CLR,
          clk => clk
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
