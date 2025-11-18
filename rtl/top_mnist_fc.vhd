-- ============================================================================
-- top_mnist_fc.vhd
-- Top-level: ROMs + MAC10 + ARGMAX + FSM + decoder_4to7 (7-seg display)
-- clk/rst/start -> FSM -> ROMs/MAC -> ARGMAX -> decoder -> hex0
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_pkg.all;
use work.pack_utils.all;

entity top_mnist_fc is
  port(
    clk        : in  std_logic;
    rst_n      : in  std_logic;               -- active-low synchronous reset
    done_out   : out std_logic;               -- pulse when result ready
    hex0       : out std_logic_vector(6 downto 0); -- 7-seg segments
	 cycles_out  : out std_logic_vector(17 downto 0)
  );
end entity;

architecture rtl of top_mnist_fc is
  --------------------------------------------------------------------------
  -- Control signals
  --------------------------------------------------------------------------
  signal addr       : unsigned(9 downto 0);
  signal load_bias  : std_logic;
  signal en         : std_logic;
  signal arg_start  : std_logic;
  signal arg_done   : std_logic;

  --------------------------------------------------------------------------
  -- ROM outputs
  --------------------------------------------------------------------------
  signal xq_q      : std_logic_vector(7 downto 0);
  signal wq_q      : std_logic_vector(79 downto 0);
  signal bstar_q   : std_logic_vector(319 downto 0);

  -- typed views
  signal xq_s      : x_t;
  signal wq_vec    : w_vec_t;
  signal bstar_vec : acc_vec_t;

  --------------------------------------------------------------------------
  -- Computation results
  --------------------------------------------------------------------------
  signal acc       : acc_vec_t;
   --------------------------------------------------------------------------
	
  -- Internal signals
  --------------------------------------------------------------------------
  signal digit_idx_s : unsigned(3 downto 0);  -- internal copy of digit index
  signal done_pulse_s : std_logic;                          
  signal start_pulse : std_logic := '0';
  signal rst_n_d     : std_logic := '0';
  
begin

 process(clk)
  begin
    if rising_edge(clk) then
      rst_n_d <= rst_n;
      if (rst_n_d = '0' and rst_n = '1') then
        start_pulse <= '1';          
      else
        start_pulse <= '0';
      end if;
    end if;
  end process;
  
  --------------------------------------------------------------------------
  -- ROMs
  --------------------------------------------------------------------------
  U_XQ: entity work.xq_rom8
    generic map ( DEPTH => 784 )
    port map (
      clk  => clk,
      addr => addr,
      q    => xq_q
    );

  U_WQ: entity work.wq_rom80
    generic map ( DEPTH => 784 )
    port map (
      clk  => clk,
      addr => addr,
      q    => wq_q
    );

  U_BIAS: entity work.bstar_rom320
    port map (
      clk => clk,
      q   => bstar_q
    );

  -- cast to typed
  xq_s      <= unsigned(xq_q);
  wq_vec    <= slv80_to_wvec(wq_q);
  bstar_vec <= slv320_to_accvec(bstar_q);

  --------------------------------------------------------------------------
  -- MAC (streaming)
  --------------------------------------------------------------------------
  U_MAC: entity work.mac10
    port map (
      clk        => clk,
      rst_n      => rst_n,
      load_bias  => load_bias,
      en         => en,
      xq         => xq_s,
      wq         => wq_vec,
      bstar      => bstar_vec,
      acc_out    => acc
    );

  --------------------------------------------------------------------------
  -- ARGMAX
  --------------------------------------------------------------------------
  U_AM: entity work.argmax10
    port map (
      clk        => clk,
      rst_n      => rst_n,
      start      => arg_start,
      acc_in     => acc,
      done       => arg_done,
      digit_idx  => digit_idx_s   -- connect to internal signal
    );

  --------------------------------------------------------------------------
  -- Controller FSM
  --------------------------------------------------------------------------
  U_CTRL: entity work.controller_fsm
    generic map ( DEPTH => 784 )
    port map (
      clk        => clk,
      rst_n      => rst_n,
      start_in   => start_pulse,
      addr       => addr,
      load_bias  => load_bias,
      en         => en,
      arg_start  => arg_start,
      arg_done   => arg_done,
      done_out   => done_pulse_s
    );
	 
    done_out <= done_pulse_s;
	 
  --------------------------------------------------------------------------
  -- Cycle Counter
  -------------------------------------------------------------------------
  U_CC: entity work.cycle_counter
    port map (
      clk       => clk,
      rst_n     => rst_n,
      start_in  => start_pulse,      -- connect start pulse
      done_in   => done_pulse_s,      -- connect done pulse
      led_o     => cycles_out
    );
    
	 
  --------------------------------------------------------------------------
  -- Decoder to 7-segment
  --------------------------------------------------------------------------
  U_DEC: entity work.decoder_4to7
    port map (
      A => std_logic_vector(digit_idx_s),  -- convert unsigned -> std_logic_vector
      Y => hex0
    );

end architecture;
