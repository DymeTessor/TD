--------------------------------------------------------------
 --     Copyright (c) 2012-2023 Anlogic Inc.
 --  All Right Reserved.
--------------------------------------------------------------
 -- Log	:	This file is generated by Anlogic IP Generator.
 -- File	:	E:/Data/TD/al_ip/itcm.vhd
 -- Date	:	2024 03 08
 -- TD version	:	5.6.71036
--------------------------------------------------------------

LIBRARY ieee;
USE work.ALL;
	USE ieee.std_logic_1164.all;
LIBRARY eagle_macro;
	USE eagle_macro.EAGLE_COMPONENTS.all;

ENTITY itcm IS
PORT (
	doa	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

	dia	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	addra	: IN STD_LOGIC_VECTOR(13 DOWNTO 0);
	wea	: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	clka	: IN STD_LOGIC
	);
END itcm;

ARCHITECTURE struct OF itcm IS

	BEGIN
	inst : EG_LOGIC_BRAM
		GENERIC MAP (
			DATA_WIDTH_A	=> 32,
			ADDR_WIDTH_A	=> 14,
			DATA_DEPTH_A	=> 16384,
			DATA_WIDTH_B	=> 32,
			ADDR_WIDTH_B	=> 14,
			DATA_DEPTH_B	=> 16384,
			BYTE_ENABLE	=> 8,
			BYTE_A	=> 4,
			BYTE_B	=> 4,
			MODE			=> "SP",
			REGMODE_A	=> "NOREG",
			WRITEMODE_A	=> "NORMAL",
			RESETMODE	=> "SYNC",
			IMPLEMENT	=> "32K",
			DEBUGGABLE	=> "NO",
			PACKABLE		=> "NO",
			INIT_FILE	=> "NONE",
			FILL_ALL		=> "NONE"
		)
		PORT MAP (
			dia	=> dia,
			dib	=> (others=>'0'),
			addra	=> addra,
			addrb	=> (others=>'0'),
			cea	=> '1',
			ceb	=> '0',
			clka	=> clka,
			clkb	=> '0',
			wea	=> '0',
			bea	=> wea,
			web	=> '0',
			rsta	=> '0',
			rstb	=> '0',
			doa	=> doa,
			dob	=> OPEN,
			ocea	=> '0',
			oceb	=> '0'
		);

END struct;
