-- ============================================================================
--  mac10_tb.vhd  – Self-checking TB for mac10
--  Clock: 50 MHz, active-low synchronous reset
--  Checks: bias load + two accumulate steps with known numbers
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_pkg.all;


entity mac10_tb is end entity;

architecture tb of mac10_tb is
  signal clk, rst_n, load_bias, en : std_logic := '0';
  signal xq    : x_t := (others => '0');
  signal wq    : w_vec_t;
  signal bstar : acc_vec_t;
  signal acc   : acc_vec_t;

  constant CLK_PERIOD : time := 20 ns;

  -- type definition may be here
  type int_arr is array (0 to 9) of integer;

  procedure tick is begin wait until rising_edge(clk); end procedure;
begin
  clk <= not clk after CLK_PERIOD/2;

  UUT: entity work.mac10
    port map (
      clk=>clk, rst_n=>rst_n, load_bias=>load_bias, en=>en,
      xq=>xq, wq=>wq, bstar=>bstar, acc_out=>acc
    );

	 
  stim: process
    variable exp : int_arr := (others => 0);
  begin
    -- reset
    rst_n <= '0'; for n in 1 to 5 loop tick; end loop;
    rst_n <= '1'; for n in 1 to 2 loop tick; end loop;

    -- TC1: load biases
    for i in 0 to 9 loop
      bstar(i) <= to_signed(1000*i, 32);
      exp(i)   := 1000*i;
    end loop;
    load_bias <= '1'; tick; load_bias <= '0'; tick;

    for i in 0 to 9 loop
      assert acc(i) = to_signed(exp(i), 32)
        report "TC1 bias mismatch i=" & integer'image(i) severity error;
    end loop;

    -- TC2: one accumulate step
    xq <= to_unsigned(10, 8);
    for i in 0 to 9 loop wq(i) <= to_signed(i, 8); exp(i) := exp(i) + i*10; end loop;
    en <= '1'; tick; en <= '0'; tick;

    for i in 0 to 9 loop
      assert acc(i) = to_signed(exp(i), 32)
        report "TC2 acc#1 mismatch i=" & integer'image(i) severity error;
    end loop;

    -- TC3: another step
    xq <= to_unsigned(3, 8);
    for i in 0 to 9 loop wq(i) <= to_signed(2*i, 8); exp(i) := exp(i) + 6*i; end loop;
    en <= '1'; tick; en <= '0'; tick;

    for i in 0 to 9 loop
      assert acc(i) = to_signed(exp(i), 32)
        report "TC3 acc#2 mismatch i=" & integer'image(i) severity error;
    end loop;

    report "mac10_tb: ALL TESTS PASSED" severity note;
    wait;
  end process;
end architecture;



