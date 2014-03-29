--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:09:46 03/29/2014
-- Design Name:   
-- Module Name:   C:/Users/Tom/projs/code/ramlut/ramlut_test.vhd
-- Project Name:  ramlut
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ramlut
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
USE ieee.numeric_std.ALL;
 
ENTITY ramlut_test IS
END ramlut_test;
 
ARCHITECTURE behavior OF ramlut_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ramlut
    PORT(
         x_in : IN  std_logic_vector(9 downto 0);
         sine_out : OUT  std_logic_vector(11 downto 0);
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal x_in : std_logic_vector(9 downto 0) := (others => '0');
	signal temp_x_in: integer := 0;
   signal clk : std_logic := '0';

 	--Outputs
   signal sine_out : std_logic_vector(11 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ramlut PORT MAP (
          x_in => x_in,
          sine_out => sine_out,
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

      loop
			temp_x_in <= temp_x_in + 1;
			x_in <= std_logic_vector(to_unsigned(temp_x_in,10));
			wait for 10ns;
		end loop;

      wait;
   end process;

END;
