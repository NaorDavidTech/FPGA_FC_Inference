-- ============================================================================
-- decoder_4to7.vhd
-- ============================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder_4to7 is
port ( A : in  STD_LOGIC_VECTOR(3 downto 0);  
       Y : out STD_LOGIC_VECTOR(6 downto 0));
end;

architecture Behavioral of decoder_4to7 is
begin
    process(A)
    begin
        
        case A is
            when "0000" => Y <= "1000000"; -- 0
            when "0001" => Y <= "1111001"; -- 1
            when "0010" => Y <= "0100100"; -- 2
            when "0011" => Y <= "0110000"; -- 3
            when "0100" => Y <= "0011001"; -- 4
            when "0101" => Y <= "0010010"; -- 5
            when "0110" => Y <= "0000010"; -- 6
            when "0111" => Y <= "1111000"; -- 7
            when "1000" => Y <= "0000000"; -- 8
            when "1001" => Y <= "0011000"; -- 9
            when others => Y <= "1111111"; -- BLANK

        end case;
    end process;
end Behavioral;
