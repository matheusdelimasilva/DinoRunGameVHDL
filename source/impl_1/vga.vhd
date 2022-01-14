library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga is
  port(
	vgaclock : in std_logic;
	valid : out std_logic;
	row : out unsigned(9 downto 0);
	col : out unsigned(9 downto 0);
	HSYNC : out std_logic;
	VSYNC : out std_logic
  );
end;

architecture synth of vga is

signal rows : unsigned(9 downto 0);
signal columns : unsigned(9 downto 0); 



--constant width1 := 640;
--constant height1 := 480; 
--constant width2 := 800;
--constant height2 := 525;

begin
	process(vgaclock) is 
		begin
		
		--every rising edge we update the column, when column value goes pass 
		if rising_edge(vgaclock) then
		
			-- increment column every clock
			columns <= columns + to_unsigned(1,10);
		
			--increment rows after 800px
			if (columns >= 800) then
				columns <= to_unsigned(0,10);
				rows <= rows + to_unsigned(1,10);
			end if;
			
			--reset rows if its greater than 525
			if (rows >= 525) then
				rows <= to_unsigned(0,10);
			end if;
		end if;
	end process;
	
	valid <= '1' when (columns < 10d"640" and rows < 10d"480") else '0'; -- rows <= to_unsigned(480,10) else '0'; --row is within visible (480
	HSYNC <= '1' when (columns >= 10d"656" and columns < 10d"752") else '0';
	VSYNC <= '1' when (rows >= 10d"490" and rows < 10d"492") else '0';
	
	row <= rows;
	col <= columns;
end;
