library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity square_wave is
	generic(
	square_wave_length: integer := 10
	);
	port(
	x_in: in std_logic_vector(square_wave_length - 1 downto 0);
	square_out: out std_logic_vector(11 downto 0);
	pwm_length: in std_logic_vector(square_wave_length - 1 downto 0)
	);
end square_wave;

architecture Behavioral of square_wave is

begin

square_out <= (others => '1') when (to_integer(unsigned(x_in)) < to_integer(unsigned(pwm_length))) else (others => '0');

end Behavioral;