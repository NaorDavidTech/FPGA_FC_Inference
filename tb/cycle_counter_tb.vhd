-- ============================================================================
-- cycle_counter_tb.vhd
-- ============================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cycle_counter_tb is
end entity;

architecture tb of cycle_counter_tb is
  constant CLK_PERIOD : time := 20 ns;
  signal clk, rst_n, start_in, done_in : std_logic := '0';
  signal led_o : std_logic_vector(17 downto 0);

  procedure tick is begin
    wait until rising_edge(clk);
  end procedure;

begin
  clk <= not clk after CLK_PERIOD/2;

  UUT: entity work.cycle_counter
    port map (
      clk      => clk,
      rst_n    => rst_n,
      start_in => start_in,
      done_in  => done_in,
      led_o    => led_o
    );

  stim: process
  begin
    -- reset
    rst_n <= '0'; tick; tick; rst_n <= '1'; tick;

    -- start counting
    start_in <= '1'; tick; start_in <= '0';

    -- let 10 cycles pass
    for i in 1 to 10 loop tick; end loop;

    -- done pulse
    done_in <= '1'; tick; done_in <= '0'; tick;

    assert unsigned(led_o) = 10
      report "Expected 10 cycles, got " & integer'image(to_integer(unsigned(led_o)))
      severity error;

    report "cycle_counter_tb: PASS" severity note;
    wait for 50 ns;
    std.env.stop;
  end process;
end architecture;
