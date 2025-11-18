-- ============================================================================
--  bstar_rom320.vhd 
-- ============================================================================


library ieee;
use ieee.std_logic_1164.all;

entity bstar_rom320 is
  port(
    clk : in  std_logic;
    q   : out std_logic_vector(319 downto 0)    -- packed: [b9|...|b0]
  );
end;

architecture rtl of bstar_rom320 is
  type mem_t is array (0 to 0) of std_logic_vector(319 downto 0);
  signal mem : mem_t;
  attribute ram_init_file : string;
  attribute ram_init_file of mem : signal is "bstar320.mif";
  signal q_r : std_logic_vector(319 downto 0) := (others => '0');
begin
  process(clk) begin
    if rising_edge(clk) then
      q_r <= mem(0);                            -- latency=1
    end if;
  end process;
  q <= q_r;
end;
