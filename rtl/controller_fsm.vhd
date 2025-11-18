-- ============================================================================
--  controller_fsm.vhd
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_fsm is
  generic (
    DEPTH : integer := 784   -- number of pixels to stream
  );
  port(
    clk       : in  std_logic;
    rst_n     : in  std_logic;        -- active-low synchronous reset
    start_in  : in  std_logic;        -- one-cycle start pulse

    -- ROM interface
    addr      : out unsigned(9 downto 0);

    -- MAC10 control
    load_bias : out std_logic;        -- one-cycle at the start
    en        : out std_logic;        -- asserted for each pixel

    -- ARGMAX handshake
    arg_start : out std_logic;        -- one-cycle pulse to start argmax
    arg_done  : in  std_logic;         -- asserted when argmax finished

    -- global done flag
    done_out  : out std_logic
  );
end;

architecture rtl of controller_fsm is

  -- Define states of the FSM
  type state_t is (S_IDLE, S_LOAD_BIAS, S_PRIME, S_STREAM, S_ARG_KICK, S_ARG_WAIT, S_DONE);
  signal st, st_next : state_t := S_IDLE;

  -- Internal registers
  signal addr_r : unsigned(9 downto 0) := (others => '0');
  signal cnt    : unsigned(9 downto 0) := (others => '0');

  -- Output registers
  signal lb_r, en_r, arg_start_r, done_r : std_logic := '0';

begin
  -- Connect registers to outputs
  addr      <= addr_r;
  load_bias <= lb_r;
  en        <= en_r;
  arg_start <= arg_start_r;
  done_out  <= done_r;

  ------------------------------------------------------------------------
  -- COMBINATIONAL: next-state logic and default outputs
  ------------------------------------------------------------------------
  process(st, cnt, arg_done, start_in)
    variable next_lb, next_en, next_astart, next_done : std_logic := '0';
    variable next_state : state_t := st;
  begin
    -- default outputs
    next_lb := '0'; next_en := '0'; next_astart := '0'; next_done := '0';
    next_state := st;

    case st is
      when S_IDLE =>
        if start_in = '1' then
          next_state := S_LOAD_BIAS;
        end if;

      when S_LOAD_BIAS =>
        next_lb := '1';               -- preload bias values
        next_state := S_PRIME;

      when S_PRIME =>
        next_state := S_STREAM;         -- wait 1 cycle for ROM to output first data

      when S_STREAM =>
        next_en := '1';                -- enable MAC for this pixel
        if cnt = to_unsigned(DEPTH-1, cnt'length) then
          next_state := S_ARG_KICK;     -- after last pixel
        end if;

      when S_ARG_KICK =>
        next_astart := '1';            -- start argmax
        next_state := S_ARG_WAIT;

      when S_ARG_WAIT =>
        if arg_done = '1' then
          next_state := S_DONE;
        end if;

      when S_DONE =>
        next_done := '1';               -- signal overall done
        next_state := S_IDLE;             -- return to idle for next run
    end case;

    -- latch to signals
    lb_r         <= next_lb;
    en_r         <= next_en;
    arg_start_r  <= next_astart;
    done_r       <= next_done;
    st_next      <= next_state;
  end process;

  ------------------------------------------------------------------------
  -- SEQUENTIAL: update state, address and pixel counter
  ------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        st      <= S_IDLE;
        addr_r  <= (others => '0');
        cnt     <= (others => '0');
      else
        st <= st_next;

        case st is
          when S_IDLE =>
            addr_r <= (others => '0');
            cnt    <= (others => '0');

          when S_LOAD_BIAS =>
            null; -- nothing to count

          when S_PRIME =>
            addr_r <= (others => '0');
            cnt    <= (others => '0');

          when S_STREAM =>
            -- advance ROM address and count pixels
            if addr_r < to_unsigned(DEPTH-1, addr_r'length) then
              addr_r <= addr_r + 1;
            end if;
            cnt <= cnt + 1;

          when S_ARG_KICK | S_ARG_WAIT | S_DONE =>
            null;
        end case;
      end if;
    end if;
  end process;

end architecture;
