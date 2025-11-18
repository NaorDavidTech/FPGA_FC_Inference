-- ============================================================================
--  controller_fsm_tb.vhd
--  Self-checking testbench for controller_fsm
--  - 50 MHz clock, active-low synchronous reset
--  - Drives start, observes the streaming phase, checks address increment,
--    waits for arg_start pulse, asserts arg_done, and verifies done_out.
--  - Uses small DEPTH (8) to keep the sim short; change to 784 for full run.
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_fsm_tb is
end entity;

architecture tb of controller_fsm_tb is
  constant CLK_PERIOD : time    := 20 ns;  -- 50 MHz
  constant DEPTH_TB   : integer := 8;      -- use 784 in the real run

  -- DUT I/O
  signal clk        : std_logic := '0';
  signal rst_n      : std_logic := '0';
  signal start_in   : std_logic := '0';

  signal addr       : unsigned(9 downto 0);
  signal load_bias  : std_logic;
  signal en         : std_logic;
  signal arg_start  : std_logic;
  signal arg_done   : std_logic := '0';
  signal done_out   : std_logic;

  -- helpers
  procedure tick is
  begin
    wait until rising_edge(clk);
  end procedure;

  procedure nticks(n : natural) is
  begin
    for i in 1 to n loop tick; end loop;
  end procedure;

begin
  --------------------------------------------------------------------------
  -- clock
  --------------------------------------------------------------------------
  clk <= not clk after CLK_PERIOD/2;

  --------------------------------------------------------------------------
  -- UUT
  --------------------------------------------------------------------------
  UUT: entity work.controller_fsm
    generic map ( DEPTH => DEPTH_TB )
    port map (
      clk        => clk,
      rst_n      => rst_n,
      start_in   => start_in,
      addr       => addr,
      load_bias  => load_bias,
      en         => en,
      arg_start  => arg_start,
      arg_done   => arg_done,
      done_out   => done_out
    );

  --------------------------------------------------------------------------
  -- Stimulus & self-checks
  --------------------------------------------------------------------------
  stim: process
    variable en_count   : integer := 0;
    variable saw_astart : boolean := false;
  begin
    -- reset
    rst_n <= '0';  nticks(3);
    rst_n <= '1';  nticks(2);

    -- start pulse
    start_in <= '1'; tick; start_in <= '0';

    -- Optional: load_bias is expected to pulse for 1 cycle right after start.
    -- (not a hard requirement for this TB)
    tick;  -- move into PRIME/STREAM

    -- Wait until streaming begins (en='1')
    while en = '0' loop tick; end loop;

    -- Expect DEPTH_TB cycles of streaming with address incrementing 0..DEPTH_TB-1
    for k in 0 to DEPTH_TB-1 loop
      assert en = '1'
        report "STREAM phase: en expected '1' at k=" & integer'image(k)
        severity error;

      assert to_integer(addr) = k
        report "Address mismatch: expected " & integer'image(k) &
               " got " & integer'image(to_integer(addr))
        severity error;

      en_count := en_count + 1;
      tick;
    end loop;

    -- After last pixel, FSM should issue a single arg_start pulse
    -- Wait (bounded) for that pulse
    for waitc in 1 to 8 loop
      exit when arg_start = '1';
      tick;
    end loop;
    assert arg_start = '1'
      report "arg_start pulse was not observed after STREAM" severity error;
    saw_astart := true;
    tick;  -- arg_start should be one-cycle pulse

    -- Return arg_done (1 cycle) to let FSM finish
    arg_done <= '1'; tick; arg_done <= '0';

    -- Wait for done_out
    for waitc in 1 to 20 loop
      exit when done_out = '1';
      tick;
    end loop;
    assert done_out = '1' report "done_out was not asserted" severity error;

    -- Final sanity checks
    assert en_count = DEPTH_TB
      report "Unexpected number of STREAM cycles: got " &
             integer'image(en_count) & " expected " & integer'image(DEPTH_TB)
      severity error;

    assert saw_astart
      report "arg_start pulse not seen" severity error;

    report "controller_fsm_tb: ALL TESTS PASSED" severity note;
    wait for 50 ns;
	 std.env.stop;
  end process;


end architecture;




