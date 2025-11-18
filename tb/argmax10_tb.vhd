-- ============================================================================
--  argmax10_tb.vhd
--  Self-checking testbench for argmax10 (synchronous reset)
--  - 50 MHz clock, active-low synchronous reset
--  - Feeds multiple test vectors into acc_in and verifies digit_idx on 'done'
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_pkg.all;  -- acc_t, acc_vec_t

entity argmax10_tb is
end entity;

architecture tb of argmax10_tb is
  -- DUT signals
  signal clk       : std_logic := '0';
  signal rst_n     : std_logic := '0';
  signal start     : std_logic := '0';
  signal acc_in    : acc_vec_t := (others => (others => '0'));
  signal done      : std_logic;
  signal digit_idx : unsigned(3 downto 0);

  constant CLK_PERIOD : time := 20 ns;  -- 50 MHz

  -- helpers
  procedure set_all(signal v : out acc_vec_t; val : integer) is
  begin
    for k in 0 to 9 loop v(k) <= to_signed(val, 32); end loop;
  end procedure;

  procedure set_inc(signal v : out acc_vec_t; base : integer) is
  begin
    for k in 0 to 9 loop v(k) <= to_signed(base + k, 32); end loop;
  end procedure;

  procedure set_zero(signal v : out acc_vec_t) is
  begin
    for k in 0 to 9 loop v(k) <= to_signed(0, 32); end loop;
  end procedure;

  procedure tick is begin wait until rising_edge(clk); end procedure;

begin
  -- clock
  clk <= not clk after CLK_PERIOD/2;

  -- DUT
  UUT: entity work.argmax10
    port map (
      clk       => clk,
      rst_n     => rst_n,
      start     => start,
      acc_in    => acc_in,
      done      => done,
      digit_idx => digit_idx
    );

  -- Stimulus
  stim: process
    variable got : integer;
  begin
    -- reset (synchronous, active-low)
    rst_n <= '0';
    for n in 1 to 5 loop tick; end loop;
    rst_n <= '1';
    for n in 1 to 2 loop tick; end loop;

    --------------------------------------------------------------------------
    -- TC1: clear tie-breaking with unique maximum at index 1
    --------------------------------------------------------------------------
    set_zero(acc_in);
    acc_in(0) <= to_signed(10, 32);
    acc_in(1) <= to_signed(50, 32);  -- maximum here
    acc_in(2) <= to_signed(-100, 32);
    start <= '1'; tick; start <= '0';
    while done = '0' loop tick; end loop;
    got := to_integer(digit_idx);
    assert got = 1 report "TC1 failed: expected 1, got " & integer'image(got) severity error;

    --------------------------------------------------------------------------
    -- TC2: all negative, index 7 is least negative (max)
    --------------------------------------------------------------------------
    for k in 0 to 9 loop acc_in(k) <= to_signed(-100, 32); end loop;
    acc_in(7) <= to_signed(-3, 32);   -- this should win
    start <= '1'; tick; start <= '0';
    while done = '0' loop tick; end loop;
    got := to_integer(digit_idx);
    assert got = 7 report "TC2 failed: expected 7, got " & integer'image(got) severity error;

    --------------------------------------------------------------------------
    -- TC3: strictly increasing 0..9 -> index 9 should win
    --------------------------------------------------------------------------
    set_inc(acc_in, 0);  -- acc_in(k) = k
    start <= '1'; tick; start <= '0';
    while done = '0' loop tick; end loop;
    got := to_integer(digit_idx);
    assert got = 9 report "TC3 failed: expected 9, got " & integer'image(got) severity error;

    --------------------------------------------------------------------------
    -- TC4: tie between index 3 and 7 (both 100) -> FIRST MAX WINS -> expect 3
    --------------------------------------------------------------------------
    set_all(acc_in, 0);
    acc_in(3) <= to_signed(100, 32);
    acc_in(7) <= to_signed(100, 32);  -- equal to index 3
    start <= '1'; tick; start <= '0';
    while done = '0' loop tick; end loop;
    got := to_integer(digit_idx);
    assert got = 3 report "TC4 failed (tie): expected 3, got " & integer'image(got) severity error;

    report "argmax10_iter_tb: ALL TESTS PASSED" severity note;
    wait;
  end process;
end architecture;
