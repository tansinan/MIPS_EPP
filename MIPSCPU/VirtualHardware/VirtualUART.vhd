library ieee;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;
use ieee.std_logic_unsigned.all;

entity VirtualUART is
    Port (uart, clk: in  STD_LOGIC);
end entity;

architecture behavioral of VirtualUART is
	signal cnt: integer :=8;
	signal ascii: std_logic_vector(7 downto 0);
	signal reportflag: std_logic := '0';
begin
	process (uart, cnt, clk)
	begin
		if (falling_edge(uart) and cnt=8) then
			cnt <= 0;
			reportflag <= 0;
		elsif (0 <= cnt and cnt <= 7 and rising_edge(clk)) then
			ascii(cnt) <= uart;
			cnt <= cnt + 1;
		elsif (cnt = 8 and reportflag = '0') then
			reportflag <= 1;
			case ascii is
				when x"41" => report "a";
				when X"42" => report "b";
				when X"43" => report "c";
				when X"44" => report "d";
				when X"45" => report "e";
				when X"46" => report "f";
				when X"47" => report "g";
				when X"48" => report "h";
				when X"49" => report "i";
				when X"4A" => report "j";
				when X"4B" => report "k";
				when X"4C" => report "l";
				when X"4D" => report "m";
				when X"4E" => report "n";
				when X"4F" => report "o";
				when X"50" => report "p";
				when X"51" => report "q";
				when X"52" => report "r";
				when X"53" => report "s";
				when X"54" => report "t";
				when X"55" => report "u";
				when X"56" => report "v";
				when X"57" => report "w";
				when X"58" => report "x";
				when X"59" => report "y";
				when X"5A" => report "z";				
			end case;
		end if;
	end process;
end architecture;
