--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:43:02 04/05/2014
-- Design Name:   
-- Module Name:   C:/Users/Tom/projs/code/phase_acc/phase_acc_test.vhd
-- Project Name:  phase_acc
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: phase_acc
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
 
ENTITY phase_acc_test IS
END phase_acc_test;
 
ARCHITECTURE behavior OF phase_acc_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT phase_acc
    PORT(
         x_out : OUT  std_logic_vector(9 downto 0);
         freq_mult : IN  std_logic_vector(9 downto 0);
         phase_in : IN  std_logic_vector(9 downto 0);
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal freq_mult : std_logic_vector(9 downto 0) := (others => '0');
   signal phase_in : std_logic_vector(9 downto 0) := (others => '0');
   signal clk : std_logic := '0';

 	--Outputs
   signal x_out : std_logic_vector(9 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	-- Test signals
	
	signal freq_mult_sig: integer range 0 to 1023 := 512;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: phase_acc PORT MAP (
          x_out => x_out,
          freq_mult => freq_mult,
          phase_in => phase_in,
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
		
		loop
			freq_mult_sig <= freq_mult_sig + 1;
			freq_mult <= std_logic_vector(to_unsigned(freq_mult_sig,10));
			wait for 1us; 
		end loop;

      wait;
   end process;

END;
