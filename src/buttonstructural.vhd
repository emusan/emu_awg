library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity buttonStructural is

	port(
		button_in: in std_logic_vector(3 downto 0); -- 0 = down, 1 = up, 2 = left, 3 = right
		rot_a: in std_logic;
		rot_b: in std_logic;
		button_out: out std_logic_vector(3 downto 0); -- 0 = down, 1 = up, 2 = left, 3 = right
		direction: out std_logic;
		pulse: out std_logic;
		clk: in std_logic
		);
		
end buttonStructural;

architecture Structural of buttonStructural is

	component rotary_control
	port(
		rotary_a: in std_logic;
		rotary_b: in std_logic;
		out_pulse: out std_logic;
		direction: out std_logic;
		clk: in std_logic
		);
	end component;

	component pulse_sync
	port(
			A: in std_logic;
			output: out std_logic;
			clk: in std_logic
		);
	end component;

begin

	rotary: rotary_control port map (rot_a,rot_b,pulse,direction,clk);
	buttonw: pulse_sync port map (button_in(3),button_out(3),clk);
	buttonn: pulse_sync port map (button_in(1),button_out(1),clk);
	buttone: pulse_sync port map (button_in(2),button_out(2),clk);
	buttons: pulse_sync port map (button_in(0),button_out(0),clk);
end Structural;
