----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:54:36 04/11/2014 
-- Design Name: 
-- Module Name:    lcd_controller - Behavioral 
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

entity lcd_controller is
	port(
		amp_adjust: in std_logic_vector(23 downto 0); -- ch1 (5 downto 0) ch2 (11 downto 6) ch3 (17 downto 12) ch4 (23 downto 18)
		freq_adjust: in std_logic_vector(39 downto 0); -- ch 1 (9 downto 0) ch2 (19 downto 10) ch3 (29 downto 20) ch4 (39 downto 30)
		phase_adjust: in std_logic_vector(31 downto 0); -- ch 1 (7 downto 0) ch2 (15 downto 8) ch3 (23 downto 16) ch4 (31 downto 24)
		pwm_adjust: in std_logic_vector(39 downto 0); -- ch 1 (9 downto 0) ch2 (19 downto 10) ch3 (29 downto 20) ch4 (39 downto 30)
		
		current_channel: in std_logic_vector(1 downto 0);
		current_mode: in std_logic_vector(1 downto 0);
		
		lcd_data: out std_logic_vector(3 downto 0);
		lcd_e: out std_logic;
		lcd_rw: out std_logic;
		lcd_rs: out std_logic;
		
		clk: in std_logic
	);
end lcd_controller;

architecture Behavioral of lcd_controller is

	signal initialization_step: integer range 0 to 100;
	signal running_step: integer range 0 to 98;
	signal running: std_logic := '0';
	
	signal delay_small: std_logic;
	signal delay_small_count: unsigned(2 downto 0); -- used between rs,rw,data, and en. approx 80ns
	
	signal delay_mid: std_logic;
	signal delay_mid_count: unsigned(4 downto 0); -- used between en high and low. approx over 250ns
	
	signal delay_large: std_logic;
	signal delay_large_count: unsigned(7 downto 0); -- used between each set of 4-bits. approx over 1us
	
	signal delay_btw_sigs: std_logic;
	signal delay_btw_sigs_count: unsigned(11 downto 0); -- used between packets of data. approx over 40us
	
	signal delay_huge: std_logic;
	signal delay_huge_count: unsigned(19 downto 0); -- used twice in init approx 41ms
	
	signal is_delay: std_logic;
	
	signal upper_mode: std_logic_vector(3 downto 0);
	signal lower_mode: std_logic_vector(3 downto 0);
	
	signal upper_val1: std_logic_vector(3 downto 0);
	signal upper_val2: std_logic_vector(3 downto 0);
	signal upper_val3: std_logic_vector(3 downto 0);
	signal lower_val1: std_logic_vector(3 downto 0);
	signal lower_val2: std_logic_vector(3 downto 0);
	signal lower_val3: std_logic_vector(3 downto 0);
	
	signal current_value: std_logic_vector(9 downto 0);

begin

	is_delay <= delay_small or delay_mid or delay_large or delay_btw_sigs or delay_huge;
	
	with current_mode select
		upper_mode <= "0100" when "00",
						  "0101" when "01",
					     "0100" when "10",
					     "0101" when "11",
					     "0100" when others;
					  
	with current_mode select
		lower_mode <= "0110" when "00",
					     "0000" when "01",
					     "0001" when "10",
					     "0111" when "11",
					     "0001" when others;
					
	upper_val1 <= "0011";
	lower_val1 <= "00" & current_value(9 downto 8);
	
	upper_val2 <= "0011" when (unsigned(current_value(7 downto 4)) < 10) else "0100";
	lower_val2 <= current_value(7 downto 4) when (unsigned(current_value(7 downto 4)) < 10) else std_logic_vector(unsigned(current_value(7 downto 4)) - 9);
	
	upper_val3 <= "0011" when (unsigned(current_value(3 downto 0)) < 10) else "0100";
	lower_val3 <= current_value(3 downto 0) when (unsigned(current_value(3 downto 0)) < 10) else std_logic_vector(unsigned(current_value(3 downto 0)) - 9);
	
	process(clk)
	begin
		if(rising_edge(clk)) then
			case current_mode is
				when "00" =>
					case current_channel is
						when "00" => current_value <= freq_adjust(9 downto 0);
						when "01" => current_value <= freq_adjust(19 downto 10);
						when "10" => current_value <= freq_adjust(29 downto 20);
						when "11" => current_value <= freq_adjust(39 downto 30);
						when others => current_value <= freq_adjust(9 downto 0);
					end case;
				when "01" =>
					case current_channel is
						when "00" => current_value <= "00" & phase_adjust(7 downto 0);
						when "01" => current_value <= "00" & phase_adjust(15 downto 8);
						when "10" => current_value <= "00" & phase_adjust(23 downto 16);
						when "11" => current_value <= "00" & phase_adjust(31 downto 24);
						when others => current_value <= "00" & phase_adjust(7 downto 0);
					end case;
				when "10" =>
					case current_channel is
						when "00" => current_value <= "0000" & amp_adjust(5 downto 0);
						when "01" => current_value <= "0000" & amp_adjust(11 downto 6);
						when "10" => current_value <= "0000" & amp_adjust(17 downto 12);
						when "11" => current_value <= "0000" & amp_adjust(23 downto 18);
						when others => current_value <= "0000" & amp_adjust(5 downto 0);
					end case;
				when "11" =>
					case current_channel is
						when "00" => current_value <= pwm_adjust(9 downto 0);
						when "01" => current_value <= pwm_adjust(19 downto 10);
						when "10" => current_value <= pwm_adjust(29 downto 20);
						when "11" => current_value <= pwm_adjust(39 downto 30);
						when others => current_value <= pwm_adjust(9 downto 0);
					end case;
				when others =>
					case current_channel is
						when "00" => current_value <= freq_adjust(9 downto 0);
						when "01" => current_value <= freq_adjust(19 downto 10);
						when "10" => current_value <= freq_adjust(29 downto 20);
						when "11" => current_value <= freq_adjust(39 downto 30);
						when others => current_value <= freq_adjust(9 downto 0);
					end case;
			end case;
			if(is_delay = '0' and running = '0') then
				initialization_step <= initialization_step + 1;
				case initialization_step is
					when 0 => delay_huge <= '1'; -- wait 15ms or longer
								 lcd_e <= '0';
								 lcd_rw <= '1';
								 lcd_rs <= '1';
					when 1 => lcd_data <= "0011"; -- write 0x3
								 delay_small <= '1';
					when 2 => lcd_e <= '1'; -- pulse LCD_E high for 12 clock cycles
								 delay_mid <= '1';
					when 3 => lcd_e <= '0'; -- end pulse
								 delay_huge <= '1'; -- wait 4.1ms or more
					when 4 => lcd_e <= '1'; -- pulse LCD_E high for 12 clock cycles
								 delay_mid <= '1';
					when 5 => lcd_e <= '0'; -- end pulse
								 delay_huge <= '1'; -- wait 100us or more
					when 6 => lcd_e <= '1'; -- pulse LCD_E high for 12 clock cycles
								 delay_mid <= '1';
					when 7 => lcd_e <= '0'; -- end pulse
								 delay_huge <= '1'; -- wait 40us or more
					when 8 => lcd_data <= "0010"; -- write 0x2
								 delay_small <= '1';
					when 9 => lcd_e <= '1'; -- pulse LCD_E high for 12 clock cycles
								 delay_mid <= '1'; 
					when 10 => lcd_e <= '0';
								 lcd_rw <= '0';
								 lcd_rs <= '0';
								 delay_huge <= '1'; -- wait 40us or longer
					----------------------------------------------------------
					-- send function set 0x28
					----------------------------------------------------------
					when 11 => lcd_data <= "0010";
								  lcd_rs <= '0';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 12 => lcd_e <= '1';
								  delay_mid <= '1';
					when 13 => lcd_e <= '0';
								  delay_small <= '1';
					when 14 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 15 => lcd_data <= "1000";
								  lcd_rs <= '0';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 16 => lcd_e <= '1';
								  delay_mid <= '1';
					when 17 => lcd_e <= '0';
								  delay_small <= '1';
					when 18 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_huge <= '1';
					----------------------------------------------------------
					-- send entry mode set 0x06
					----------------------------------------------------------
--					when 19 => lcd_data <= "0000";
--								  lcd_rs <= '0';
--								  lcd_rw <= '0';
--								  delay_small <= '1';
--					when 20 => lcd_e <= '1';
--								  delay_mid <= '1';
--					when 21 => lcd_e <= '0';
--								  delay_small <= '1';
--					when 22 => lcd_rs <= '1';
--								  lcd_rw <= '1';
--								  delay_large <= '1';
--								  
--					when 23 => lcd_data <= "0110";
--								  lcd_rs <= '0';
--								  lcd_rw <= '0';
--								  delay_small <= '1';
--					when 24 => lcd_e <= '1';
--								  delay_mid <= '1';
--					when 25 => lcd_e <= '0';
--								  delay_small <= '1';
--					when 26 => lcd_rs <= '1';
--								  lcd_rw <= '1';
--								  delay_huge <= '1';
					----------------------------------------------------------
					-- send power on
					----------------------------------------------------------
					when 19 => lcd_data <= "0000";
								  lcd_rs <= '0';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 20 => lcd_e <= '1';
								  delay_mid <= '1';
					when 21 => lcd_e <= '0';
								  delay_small <= '1';
					when 22 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 23 => lcd_data <= "1111";
								  lcd_rs <= '0';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 24 => lcd_e <= '1';
								  delay_mid <= '1';
					when 25 => lcd_e <= '0';
								  delay_small <= '1';
					when 26 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_btw_sigs <= '1';
					----------------------------------------------------------
					-- clear display 0x01
					----------------------------------------------------------
					when 35 => lcd_data <= "0000";
								  lcd_rs <= '0';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 36 => lcd_e <= '1';
								  delay_mid <= '1';
					when 37 => lcd_e <= '0';
								  delay_small <= '1';
					when 38 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 39 => lcd_data <= "0001";
								  lcd_rs <= '0';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 40 => lcd_e <= '1';
								  delay_mid <= '1';
					when 41 => lcd_e <= '0';
								  delay_small <= '1';
					when 42 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_huge <= '1';
					when 43 => delay_huge <= '1';
					
					when 44 => running <= '1';
					when others => lcd_data <= "0000";
										delay_huge <= '1';
										--running <= '1';
				end case;	-- initialization steps
			elsif(is_delay = '0' and running = '1') then
				running_step <= running_step + 1;
				case running_step is
					----------------------------------------------------------
					-- clear display 0x01
					----------------------------------------------------------
					when 0 => lcd_data <= "0000";
								  lcd_rs <= '0';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 1 => lcd_e <= '1';
								  delay_mid <= '1';
					when 2 => lcd_e <= '0';
								  delay_small <= '1';
					when 3 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 4 => lcd_data <= "0001";
								  lcd_rs <= '0';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 5 => lcd_e <= '1';
								  delay_mid <= '1';
					when 6 => lcd_e <= '0';
								  delay_small <= '1';
					when 7 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_btw_sigs <= '1';
					----------------------------------------------------------
					-- C
					----------------------------------------------------------
					when 10 => lcd_data <= "0100";
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 11 => lcd_e <= '1';
								  delay_mid <= '1';
					when 12 => lcd_e <= '0';
								  delay_small <= '1';
					when 13 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 14 => lcd_data <= "0011";
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 15 => lcd_e <= '1';
								  delay_mid <= '1';
					when 16 => lcd_e <= '0';
								  delay_small <= '1';
					when 17 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_btw_sigs <= '1';
					----------------------------------------------------------
					-- h
					----------------------------------------------------------
					when 18 => lcd_data <= "0110";
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 19 => lcd_e <= '1';
								  delay_mid <= '1';
					when 20 => lcd_e <= '0';
								  delay_small <= '1';
					when 21 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 22 => lcd_data <= "1000";
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 23 => lcd_e <= '1';
								  delay_mid <= '1';
					when 24 => lcd_e <= '0';
								  delay_small <= '1';
					when 25 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_btw_sigs <= '1';
					----------------------------------------------------------
					-- :
					----------------------------------------------------------
					when 26 => lcd_data <= "0011";
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 27 => lcd_e <= '1';
								  delay_mid <= '1';
					when 28 => lcd_e <= '0';
								  delay_small <= '1';
					when 29 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 30 => lcd_data <= "1010";
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 31 => lcd_e <= '1';
								  delay_mid <= '1';
					when 32 => lcd_e <= '0';
								  delay_small <= '1';
					when 33 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_btw_sigs <= '1';
					----------------------------------------------------------
					-- <space>
					----------------------------------------------------------
					when 34 => lcd_data <= "0010";
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 35 => lcd_e <= '1';
								  delay_mid <= '1';
					when 36 => lcd_e <= '0';
								  delay_small <= '1';
					when 37 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 38 => lcd_data <= "0000";
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 39 => lcd_e <= '1';
								  delay_mid <= '1';
					when 40 => lcd_e <= '0';
								  delay_small <= '1';
					when 41 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_btw_sigs <= '1';
					----------------------------------------------------------
					-- channel num
					----------------------------------------------------------
					when 42 => lcd_data <= "0011";
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 43 => lcd_e <= '1';
								  delay_mid <= '1';
					when 44 => lcd_e <= '0';
								  delay_small <= '1';
					when 45 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 46 => lcd_data <= "00" & current_channel;
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 47 => lcd_e <= '1';
								  delay_mid <= '1';
					when 48 => lcd_e <= '0';
								  delay_small <= '1';
					when 49 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_btw_sigs <= '1';
					----------------------------------------------------------
					-- newline
					----------------------------------------------------------
					when 50 => lcd_data <= "1100";
								  lcd_rs <= '0';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 51 => lcd_e <= '1';
								  delay_mid <= '1';
					when 52 => lcd_e <= '0';
								  delay_small <= '1';
					when 53 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 54 => lcd_data <= "0000";
								  lcd_rs <= '0';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 55 => lcd_e <= '1';
								  delay_mid <= '1';
					when 56 => lcd_e <= '0';
								  delay_small <= '1';
					when 57 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_btw_sigs <= '1';
					----------------------------------------------------------
					-- mode
					----------------------------------------------------------
					when 58 => lcd_data <= upper_mode;
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 59 => lcd_e <= '1';
								  delay_mid <= '1';
					when 60 => lcd_e <= '0';
								  delay_small <= '1';
					when 61 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 62 => lcd_data <= lower_mode;
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 63 => lcd_e <= '1';
								  delay_mid <= '1';
					when 64 => lcd_e <= '0';
								  delay_small <= '1';
					when 65 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_btw_sigs <= '1';
					----------------------------------------------------------
					-- =
					----------------------------------------------------------
					when 66 => lcd_data <= "0011";
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 67 => lcd_e <= '1';
								  delay_mid <= '1';
					when 68 => lcd_e <= '0';
								  delay_small <= '1';
					when 69 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 70 => lcd_data <= "1101";
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 71 => lcd_e <= '1';
								  delay_mid <= '1';
					when 72 => lcd_e <= '0';
								  delay_small <= '1';
					when 73 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_btw_sigs <= '1';
					----------------------------------------------------------
					-- <p1>
					----------------------------------------------------------
					when 74 => lcd_data <= upper_val1;
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 75 => lcd_e <= '1';
								  delay_mid <= '1';
					when 76 => lcd_e <= '0';
								  delay_small <= '1';
					when 77 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 78 => lcd_data <= lower_val1;
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 79 => lcd_e <= '1';
								  delay_mid <= '1';
					when 80 => lcd_e <= '0';
								  delay_small <= '1';
					when 81 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_btw_sigs <= '1';
					----------------------------------------------------------
					-- <p2>
					----------------------------------------------------------
					when 82 => lcd_data <= upper_val2;
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 83 => lcd_e <= '1';
								  delay_mid <= '1';
					when 84 => lcd_e <= '0';
								  delay_small <= '1';
					when 85 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 86 => lcd_data <= lower_val2;
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 87 => lcd_e <= '1';
								  delay_mid <= '1';
					when 88 => lcd_e <= '0';
								  delay_small <= '1';
					when 89 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_btw_sigs <= '1';
					----------------------------------------------------------
					-- <p3>
					----------------------------------------------------------
					when 90 => lcd_data <= upper_val3;
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 91 => lcd_e <= '1';
								  delay_mid <= '1';
					when 92 => lcd_e <= '0';
								  delay_small <= '1';
					when 93 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_large <= '1';
								  
					when 94 => lcd_data <= lower_val3;
								  lcd_rs <= '1';
								  lcd_rw <= '0';
								  delay_small <= '1';
					when 95 => lcd_e <= '1';
								  delay_mid <= '1';
					when 96 => lcd_e <= '0';
								  delay_small <= '1';
					when 97 => lcd_rs <= '1';
								  lcd_rw <= '1';
								  delay_btw_sigs <= '1';
					----------------------------------------------------------
					when others => lcd_data <= "0000";
										delay_huge <= '1';
					----------------------------------------------------------
				end case;
			elsif(delay_small = '1') then
				delay_small_count <= delay_small_count + 1;
				if(delay_small_count = "111") then
					delay_small <= '0';
				end if;
			elsif(delay_mid = '1') then
				delay_mid_count <= delay_mid_count + 1;
				if(delay_mid_count = "11111") then
					delay_mid <= '0';
				end if;
			elsif(delay_large = '1') then
				delay_large_count <= delay_large_count + 1;
				if(delay_large_count = "11111111") then
					delay_large <= '0';
				end if;
			elsif(delay_btw_sigs = '1') then
				delay_btw_sigs_count <= delay_btw_sigs_count + 1;
				if(delay_btw_sigs_count = "111111111111") then
					delay_btw_sigs <= '0';
				end if;
			elsif(delay_huge <= '1') then
				delay_huge_count <= delay_huge_count + 1;
				if(delay_huge_count = "111111111111111111") then
					delay_huge <= '0';
				end if;
			else
				delay_small <= '0';
				delay_mid <= '0';
				delay_large <= '0';
				delay_btw_sigs <= '0';
				delay_huge <= '0';
			end if;
		end if;
	end process;
	

end Behavioral;