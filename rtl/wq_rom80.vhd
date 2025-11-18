-- ============================================================================
--  wq_rom80.vhd 
-- ============================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wq_rom80 is
  generic ( DEPTH : integer := 784 );
  port(
    clk  : in  std_logic;
    addr : in  unsigned(9 downto 0);            -- 0..783
    q    : out std_logic_vector(79 downto 0)    -- packed: [w9|...|w0]
  );
end;

architecture rtl of wq_rom80 is
  type mem_t is array (0 to DEPTH-1) of std_logic_vector(79 downto 0);
  signal mem : mem_t;
  attribute ram_init_file : string;
  attribute ram_init_file of mem : signal is "wq80.mif";
  signal q_r : std_logic_vector(79 downto 0) := (others => '0');
begin
  process(clk) begin
    if rising_edge(clk) then
      q_r <= mem(to_integer(addr));             -- latency=1
    end if;
  end process;
  q <= q_r;
end;
