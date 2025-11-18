-- ============================================================================
-- cycle_counter.vhd
-- ============================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cycle_counter is
  port (
    clk      : in  std_logic;
    rst_n    : in  std_logic;                -- active-low, synchronous
    start_in : in  std_logic;                -- 1-cycle pulse
    done_in  : in  std_logic;                -- 1-cycle pulse
    led_o    : out std_logic_vector(17 downto 0)
  );
end entity;

architecture rtl of cycle_counter is
  signal counting  : std_logic := '0';
  signal cycle_cnt : unsigned(17 downto 0) := (others => '0');
begin

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        counting  <= '0';
        cycle_cnt <= (others => '0');

      elsif start_in = '1' then
        -- start measuring on the cycle AFTER start_in
        counting  <= '1';
        cycle_cnt <= (others => '0');

      elsif counting = '1' then
        if done_in = '1' then
          counting <= '0';            -- stop measuring (done cycle not counted)
        else
          cycle_cnt <= cycle_cnt + 1; -- count cycles between start and done
        end if;
      end if;
    end if;
  end process;
  led_o <= std_logic_vector(cycle_cnt);
end architecture;

