-- ============================================================================
--  types_pkg.vhd
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package types_pkg is
constant CLASSES : integer := 10;
constant PIXELS : integer := 784; -- 28*28


subtype x_t is unsigned(7 downto 0); -- input pixel: 0..255
subtype w_t is signed(7 downto 0); -- weight: -128..127 (int8)
subtype acc_t is signed(31 downto 0); -- accumulator (int32)


type w_vec_t is array (0 to CLASSES-1) of w_t;
type acc_vec_t is array (0 to CLASSES-1) of acc_t;


end package;


package body types_pkg is end package body;