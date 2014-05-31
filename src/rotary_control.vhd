library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rotary_control is
	port(
				rotary_a: in std_logic;
				rotary_b: in std_logic;
				out_pulse: out std_logic;
				direction: out std_logic;
				clk: in std_logic
			);
end rotary_control;

architecture Behavioral of rotary_control is

	type rotary_state is (ablow,abhigh,left,right);
	signal next_state: rotary_state;
	signal present_state: rotary_state;

	signal rotary_input: std_logic_vector(1 downto 0);

	signal direction_sig: std_logic;

begin
	sync_states: process(clk)
	begin
		if(rising_edge(clk)) then
			present_state <= next_state;
		end if;
	end process;

	combinatorial: process(present_state,rotary_input)
	begin
		out_pulse <= '0';
		direction_sig <= direction_sig;
		case present_state is
			when ablow =>
				out_pulse <= '0';
				direction_sig <= direction_sig;
				if(rotary_input = "10") then
					next_state <= left;
				elsif(rotary_input = "01") then
					next_state <= right; -- maybe left, untested
				else
					next_state <= ablow;
				end if;
			when abhigh =>
				out_pulse <= '0';
				direction_sig <= direction_sig;
				if(rotary_input = "10") then
					next_state <= left;
				elsif(rotary_input = "01") then
					next_state <= right; -- maybe left, untested
				else
					next_state <= abhigh;
				end if;
			when left =>
				out_pulse <= '0';
				direction_sig <= direction_sig;
				if(rotary_input = "11") then
					out_pulse <= '1';
					direction_sig <= '0';
					next_state <= abhigh;
				elsif(rotary_input = "00") then
					next_state <= ablow;
				else
					next_state <= left;
				end if;
			when right =>
				out_pulse <= '0';
				direction_sig <= direction_sig;
				if(rotary_input = "11") then
					out_pulse <= '1';
					direction_sig <= '1';
					next_state <= abhigh;
				elsif(rotary_input = "00") then
					next_state <= ablow;
				else
					next_state <= right;
				end if;
			when others => -- hopefully never happens
				next_state <= ablow;
				out_pulse <= '0';
				direction_sig <= direction_sig;
		end case;
	end process;

	rotary_input <= rotary_a & rotary_b;

	direction <= direction_sig;

end Behavioral;
