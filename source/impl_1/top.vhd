library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top is
  port(
    ref_clk : in std_logic;
	btn : in std_logic;
	RGB : out unsigned(5 downto 0);
	hsyncout : out std_logic;	
	vsyncout : out std_logic;	
	testOut : out std_logic	
  );
end;



architecture synth of top is

component pattern_gen is
  port(
	btn : in std_logic; 
	clk : in std_logic;
	valid : in std_logic;
	row : in unsigned(9 downto 0);
	col : in unsigned(9 downto 0);
	RGB : out unsigned(5 downto 0)
  );
end component;

component vga is
  port(
	vgaclock : in std_logic;
	valid : out std_logic;
	row : out unsigned(9 downto 0);
	col : out unsigned(9 downto 0);
	HSYNC : out std_logic;
	VSYNC : out std_logic
  );
end component;

component mypll is
    port(
        ref_clk_i: in std_logic;
        rst_n_i: in std_logic;
        outcore_o: out std_logic; --output to pins
        outglobal_o: out std_logic
    );
end component;

signal outglobal : std_logic;
signal valid : std_logic;
signal row : unsigned(9 downto 0);
signal col : unsigned(9 downto 0);

begin 

dut : mypll port map (
	ref_clk_i => ref_clk,
	rst_n_i => '1',
	outcore_o => testOut, --output to pins
	outglobal_o => outglobal
);

dut2 : vga port map (
	vgaclock => outglobal,
	valid => valid,
	row => row,
	col => col,
	HSYNC => hsyncout,
	VSYNC => vsyncout
);

dut3 : pattern_gen port map (
	btn => btn,
	clk => ref_clk,
	valid => valid,
	row => row,
	col => col,
	RGB => RGB
);

end;

