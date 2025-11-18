-- ============================================================================
--  types_pkg.vhd  
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_pkg.all;

package pack_utils is
  function slv80_to_wvec(s : std_logic_vector(79 downto 0)) return w_vec_t;
  function slv320_to_accvec(s : std_logic_vector(319 downto 0)) return acc_vec_t;
end;

package body pack_utils is
  -- [8*i+7 : 8*i] = weight of class i, i=0..9
  function slv80_to_wvec(s : std_logic_vector(79 downto 0)) return w_vec_t is
    variable r : w_vec_t;
  begin
    for i in 0 to 9 loop
      r(i) := signed(s(8*i+7 downto 8*i));
    end loop;
    return r;
  end;

  -- [32*i+31 : 32*i] = bias of class i, i=0..9
  function slv320_to_accvec(s : std_logic_vector(319 downto 0)) return acc_vec_t is
    variable r : acc_vec_t;
  begin
    for i in 0 to 9 loop
      r(i) := signed(s(32*i+31 downto 32*i));
    end loop;
    return r;
  end;
end;
