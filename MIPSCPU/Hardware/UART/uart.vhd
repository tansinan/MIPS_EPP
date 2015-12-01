-- file Name: uart.vhd
-- Version: 1.1
-- Date: January 22, 2000
-- Model: Uart Chip
-- Dependencies: txmit.hd, rcvr.vhd
--
-- Company: Xilinx
--
--
-- Disclaimer: THESE DESIGNS ARE PROVIDED "AS is" with NO WARRANTY
-- WHATSOEVER and XILINX SPECIFICALLY DISCLAIMS ANY
-- IMPLIED WARRANTIES of MERCHANTABILITY, FITNESS for
-- A PARTICULAR PURPOSE, or AGAINST INFRINGEMENT.
--
-- Copyright (c) 2000 Xilinx, Inc.
-- all rights reserved
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart is
	port (
		rst, clk, rxd, rdn, wrn  : in std_logic;
		data                     : inout std_logic_vector(7 downto 0);
		data_ready               : out std_logic;
		parity_error             : out std_logic;
		framing_error            : out std_logic;
		tbre                     : out std_logic;
		tsre                     : out std_logic;
		sdo                      : out std_logic
	);
end uart;

architecture v1 of uart is
	signal sclk : std_logic;
	component txmit
		port (
			rst, clk16x, wrn  : in std_logic;
			din               : in std_logic_vector(7 downto 0);
			tbre, tsre, sdo   : out std_logic
		);
	end component;

	component rcvr
		port (
			rst, clk16x, rxd, rdn                    : in std_logic;
			data_ready, parity_error, framing_error  : out std_logic;
			dout                                     : out std_logic_vector(7 downto 0)
		);
	end component;

	component clkcon
		port (
			rst, clk0  : in STD_LOGIC;
			clk        : out STD_LOGIC
		);
	end component;

begin
	u1 : txmit
	port map(rst  => rst,
		clk16x        => sclk,
		wrn           => wrn,
		din           => data,
		tbre          => tbre,
		tsre          => tsre,
		sdo           => sdo);

	u2 : rcvr
	port map(rst   => rst,
		clk16x         => sclk,
		rxd            => rxd,
		rdn            => rdn,
		data_ready     => data_ready,
		framing_error  => framing_error,
		parity_error   => parity_error,
		dout           => data);

	u3 : clkcon
	port map(rst  => rst,
		clk0          => clk,
		clk           => sclk);
	end v1;
