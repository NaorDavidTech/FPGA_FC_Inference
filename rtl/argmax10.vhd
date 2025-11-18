-- ============================================================================
--  argmax10.vhd  (synchronous reset)
--  Clocked (iterative) argmax over 10 signed accumulators (int32).
--  - Scans acc_in(0..9) across 10 cycles and returns the index of the maximum.
--  - Tie policy: FIRST MAX WINS (uses '>' and not '>='). Index with lower
--    number is selected if values are equal.
--  - Outputs a single-cycle 'done' pulse when digit_idx is valid.
--  - Keep acc_in stable between 'start' and 'done'.
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_pkg.all;  -- acc_t, acc_vec_t

entity argmax10 is
  port(
    clk       : in  std_logic;
    rst_n     : in  std_logic;            -- active-low synchronous reset
    start     : in  std_logic;            -- 1-cycle pulse to start a search
    acc_in    : in  acc_vec_t;            -- 10 signed values (stable during run)
    done      : out std_logic;            -- 1-cycle pulse when result is ready
    digit_idx : out unsigned(3 downto 0)  -- result: 0..9
  );
end entity;

architecture rtl of argmax10 is
  signal busy  : std_logic := '0';
  signal i     : unsigned(3 downto 0) := (others => '0');  -- current index [0..9]
  signal maxv  : acc_t := (others => '0');                 -- current max value
  signal maxi  : unsigned(3 downto 0) := (others => '0');  -- current max index
begin
  process(clk)
    variable nxt_idx_int : integer;  -- helper for i+1 to index the array
  begin
    if rising_edge(clk) then
      -- default outputs every cycle
      done <= '0';

      -- synchronous active-low reset
      if rst_n = '0' then
        busy      <= '0';
        i         <= (others => '0');
        maxv      <= (others => '0');
        maxi      <= (others => '0');
        digit_idx <= (others => '0');

      else
        -- START: latch first value and begin scan
        if (start = '1') and (busy = '0') then
          busy <= '1';
          i    <= to_unsigned(0, 4);
          maxv <= acc_in(0);
          maxi <= to_unsigned(0, 4);

        -- RUN: compare next entries until we reach index 9
        elsif busy = '1' then
          if i < to_unsigned(9, 4) then
            -- compare acc_in(i+1) vs current max
            nxt_idx_int := to_integer(i) + 1;
            if signed(acc_in(nxt_idx_int)) > signed(maxv) then
              maxv <= acc_in(nxt_idx_int);
              maxi <= to_unsigned(nxt_idx_int, 4);
            end if;
            -- advance to next index
            i <= i + 1;

          else
            -- DONE: all entries [0..9] scanned
            digit_idx <= maxi;  -- register result
            done      <= '1';   -- one-cycle pulse
            busy      <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture;
