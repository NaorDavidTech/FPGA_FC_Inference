-- ============================================================================
-- top_level.vhd
-- ============================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_pkg.all;
use work.pack_utils.all;


entity top_level is
  port (
    CLOCK_50 : in  std_logic;
    KEY      : in  std_logic_vector(0 downto 0); -- reset
	 LEDG     : out std_logic_vector(0 downto 0);
    HEX0     : out std_logic_vector(6 downto 0);
	 LEDR     : out std_logic_vector(17 downto 0)
  );
end entity;

architecture rtl of top_level is

begin


  -- instantiate the MNIST top-level core
  U_CORE: entity work.top_mnist_fc 
    port map (
      clk        => CLOCK_50,
      rst_n      => KEY(0),
      done_out   => LEDG(0),
      hex0       => HEX0,
		cycles_out => LEDR
    );

end architecture;