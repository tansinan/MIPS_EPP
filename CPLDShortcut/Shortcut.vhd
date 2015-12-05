library ieee;
use ieee.std_logic_1164.all;

entity Shortcut is
	port
	(
		txd : out std_logic;
		rxd : in std_logic;
		interconnect0 : in std_logic;
		interconnect1 : out std_logic
	);
end entity;

architecture Behavioral of Shortcut is
begin
	txd <= interconnect0;
	interconnect1 <= rxd;
end architecture;

