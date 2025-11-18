-- ============================================================================
--  mac10.vhd
--  Ten-lane multiply-accumulate with bias load.
--  - load_bias='1' : acc <= bstar (one cycle)
--  - en='1'        : acc <= acc + (wq(i) * xq)  (one pixel per cycle)
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_pkg.all;

entity mac10 is
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;    -- active-low synchronous reset
    load_bias : in  std_logic;    -- pulse: load bstar into acc
    en        : in  std_logic;    -- when '1', do one accumulate step
    xq        : in  x_t;          -- current pixel (0..255)
    wq        : in  w_vec_t;      -- 10 weights for this pixel
    bstar     : in  acc_vec_t;    -- 10 pre-computed biases (int32)
    acc_out   : out acc_vec_t     -- registered accumulators
  );
end entity;

architecture rtl of mac10 is
  signal acc : acc_vec_t := (others => (others => '0'));
begin
  process(clk)
    variable xq16   : signed(15 downto 0);
    variable w16    : signed(15 downto 0);
    variable prod32 : signed(31 downto 0);
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        acc <= (others => (others => '0'));

      elsif load_bias = '1' then
        acc <= bstar;

      elsif en = '1' then
        xq16 := signed(resize(unsigned(xq), 16));     -- 8→16
        for i in 0 to CLASSES-1 loop
          w16    := resize(wq(i), 16);      -- 8→16
          prod32 := w16 * xq16;             -- 16×16 → 32
          acc(i) <= acc(i) + prod32;        -- 32 + 32 → 32
        end loop;
      end if;
    end if;
  end process;

  acc_out <= acc;
end architecture;

