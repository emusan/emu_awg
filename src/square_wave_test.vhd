--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:05:59 04/06/2014
-- Design Name:   
-- Module Name:   C:/Users/Tom/projs/code/square_wave/square_wave_test.vhd
-- Project Name:  square_wave
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: square_wave
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
 
ENTITY square_wave_test IS
END square_wave_test;
 
ARCHITECTURE behavior OF square_wave_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT square_wave
    PORT(
         x_in : IN  std_logic_vector(9 downto 0);
         enable : IN  std_logic;
         square_out : OUT  std_logic_vector(11 downto 0);
         pwm_length : IN  std_logic_vector(9 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal x_in : std_logic_vector(9 downto 0) := (others => '0');
   signal enable : std_logic := '0';
   signal pwm_length : std_logic_vector(9 downto 0) := (others => '0');

 	--Outputs
   signal square_out : std_logic_vector(11 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
	
	signal x_sig: unsigned(9 downto 0);
	
	signal pwm_sig: unsigned(9 downto 0);
 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: square_wave PORT MAP (
          x_in => x_in,
          enable => enable,
          square_out => square_out,
          pwm_length => pwm_length
        );

 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		enable <= '1';
      -- insert stimulus here 
		loop
			pwm_sig <= to_unsigned(to_integer(pwm_sig) + 1,10);
			pwm_length <= std_logic_vector(pwm_sig);
			for i in 0 to 2 ** x_sig'length loop
				x_sig <= to_unsigned(to_integer(x_sig) + 1,10);
				
				x_in <= std_logic_vector(x_sig);
				wait for 10 ns;
			end loop;
						
			wait for 10 ns;
		end loop;

      wait;
   end process;

END;
