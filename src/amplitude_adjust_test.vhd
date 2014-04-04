--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:57:08 04/04/2014
-- Design Name:   
-- Module Name:   C:/Users/Tom/projs/code/amplitude_adjust/amplitude_adjust_test.vhd
-- Project Name:  amplitude_adjust
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: amplitude_adjust
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
 
ENTITY amplitude_adjust_test IS
END amplitude_adjust_test;
 
ARCHITECTURE behavior OF amplitude_adjust_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT amplitude_adjust
    PORT(
         x_in : IN  std_logic_vector(11 downto 0);
         x_out : OUT  std_logic_vector(11 downto 0);
         adjust : IN  std_logic_vector(5 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal x_in : std_logic_vector(11 downto 0) := (others => '0');
   signal adjust : std_logic_vector(5 downto 0) := (others => '0');

 	--Outputs
   signal x_out : std_logic_vector(11 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
	
	signal temp_adj: unsigned(5 downto 0) := "111111";
 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: amplitude_adjust PORT MAP (
          x_in => x_in,
          x_out => x_out,
          adjust => adjust
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		x_in <= (others => '1');
      loop
			temp_adj <= temp_adj - 1;
			adjust <= std_logic_vector(temp_adj);
			wait for 10ns;
		end loop;
      wait;
   end process;

END;
