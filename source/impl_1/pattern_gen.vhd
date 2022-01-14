library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pattern_gen is
  port(
	btn : in std_logic;
	input : in std_logic;
	clk : in std_logic;
	valid : in std_logic;
	row : in unsigned(9 downto 0);
	col : in unsigned(9 downto 0);
	RGB : out unsigned(5 downto 0)
  );
end;


architecture synth of pattern_gen is

constant JUMP_HEIGHT : unsigned := 9d"220";

-- Default position of objects
constant PLAYER_DEF_POS_Y : unsigned := 10d"344"; -- y coord with larger dino
constant PLAYER_DEF_POS_X : unsigned := 10d"450"; -- x coord with larger dino
constant CACTUS_DEF_POS_Y : unsigned := 10d"1";
constant GROUND_TOP : unsigned := 10d"379";

-- Speed constants
constant CACTUS_SPEED : unsigned := 9d"10";
constant JUMP_SPEED : unsigned := 4d"15";
constant FALL_SPEED : unsigned :=  4d"15";

-- rom component for dinosaur sprite
component dino_1 is
port(
	rd_clk_i: in std_logic;
	rst_i: in std_logic;
	rd_en_i: in std_logic;
	rd_clk_en_i: in std_logic;
	rd_addr_i: in std_logic_vector(3 downto 0);
	rd_data_o: out std_logic_vector(15 downto 0)
);
end component;

-- rom component for cactus sprite
component CactusSprite is
    port(
        rd_clk_i: in std_logic;
        rst_i: in std_logic;
        rd_en_i: in std_logic;
        rd_clk_en_i: in std_logic;
        rd_addr_i: in std_logic_vector(3 downto 0);
        rd_data_o: out std_logic_vector(15 downto 0)
    );
end component;

-- Player
signal playerX : unsigned(9 downto 0) := PLAYER_DEF_POS_X;
signal playerY : unsigned(9 downto 0) := PLAYER_DEF_POS_Y;

-- Cactus
signal cactusX :  unsigned(9 downto 0) := 10d"600";
signal cactus2X :  unsigned(9 downto 0) := 10d"400";
signal cactus3X :  unsigned(9 downto 0) := 10d"200";
signal cactusY :  unsigned(9 downto 0) := 10d"348";

-- Diameters
constant player_diameter : unsigned(4 downto 0) := 5d"31";
constant cactus_diameter : unsigned(4 downto 0) := 5d"31";

-- Bool to change to jumping
signal jumping : std_logic := '0';
signal falling : std_logic := '1';
signal jump_count : unsigned(4 downto 0) := "00000";
signal counting : unsigned(30 downto 0);

-- Game logic
signal gameSpeed : unsigned(3 downto 0) := "0000";
signal gameOver : std_logic := '0';
signal start : std_logic := '0';

-- Bools for cactus position
signal cactus1 : std_logic;
signal cactus2 : std_logic;
signal cactus3 : std_logic;

-- Position holders
signal playerPos : std_logic;
signal groundPos : std_logic;

-- rom signals for dinosaur sprite
signal rom_i : std_logic_vector(3 downto 0) := "0000" ;
signal read_data : std_logic_vector(15 downto 0);

-- rom signals for cactus sprite
signal rom_i_cactus : std_logic_vector(3 downto 0) := "0000" ;
signal read_data_cactus : std_logic_vector(15 downto 0);

-- buttons for metastability
signal btn2 : std_logic;
signal btn3 : std_logic;
signal btn4 : std_logic;

-- placement signals for dino sprite
signal bitrow : unsigned(9 downto 0);
signal bitcol : unsigned(9 downto 0);

-- placement signals for cactus1 sprite
signal bitrowCactus : unsigned(9 downto 0);
signal bitcolCactus : unsigned(9 downto 0);

-- placement signals for cactus2 sprite
signal bitrowCactus2 : unsigned(9 downto 0);
signal bitcolCactus2 : unsigned(9 downto 0);

-- placement signals for cactus3 sprite
signal bitrowCactus3 : unsigned(9 downto 0);
signal bitcolCactus3 : unsigned(9 downto 0);

begin
	
	--- for dino sprite: ---
	
	--to get relative position for dino
	bitrow <= (row - playerY)/2;
	bitcol <= (col - PLAYER_DEF_POS_X)/2;

	rom_i <= std_logic_vector(bitrow(3 downto 0));
	-- instantiation
	rom : dino_1 port map (
		rd_clk_i => clk,
		rst_i  => '0',
		rd_en_i => '1',
		rd_clk_en_i => '0',
		rd_addr_i => rom_i,
		rd_data_o => read_data  
	);
	
	--- for cactus sprite: ---
	
	-- to get relative position for cactus1
	bitrowCactus <= (row - CACTUS_DEF_POS_Y)/2;
	bitcolCactus <= (col - cactusX)/2;

	-- to get relative position for cactus2
	bitrowCactus2 <= (row - CACTUS_DEF_POS_Y)/2;
	bitcolCactus2 <= (col - cactus2X)/2;
	
	rom_i_cactus <= std_logic_vector(bitrowCactus(3 downto 0));
	-- instantiation
	romCactus : CactusSprite port map (
		rd_clk_i => clk,
		rst_i => '0',
		rd_en_i => '1',
		rd_clk_en_i => '0',
		rd_addr_i => rom_i_cactus,
		rd_data_o => read_data_cactus
	);
	

	cactus1 <= '1' when (col >= cactusX and col <= cactusX + cactus_diameter and row >= cactusY and row <= cactusY + cactus_diameter) else '0';
	cactus2 <= '1' when (col > cactus2X and col < cactus2X + cactus_diameter and row > cactusY and row < cactusY + cactus_diameter) else '0';
	playerPos <= '1' when (col >= playerX and col <= playerX + player_diameter and row >= playerY and row <= playerY + player_diameter) else '0';
	groundPos <= '1' when (row > 379 and row < 385) else '0';

	rgb(5 downto 0) <= "000000" when valid = '0' else
					"000000" when (col < 32) or (col > 608) else -- black columns
					"001100" when cactus1 = '1' and read_data_cactus(to_integer(bitcolCactus(3 downto 0))) = '1' else
					"001100" when cactus2 = '1' and read_data_cactus(to_integer(bitcolCactus2(3 downto 0))) = '1' else
					"001100" when groundPos = '1' else -- ground
					"101101" when playerPos = '1' and read_data(to_integer(bitcol(3 downto 0))) = '1' else
					"000000" when playerPos = '1' else -- to see where dino is supposed to be
					"000000"; -- background
	
	
	-- Pushing button with flip flops
	process (clk) begin
	if rising_edge(clk) then
		btn2 <= btn;
	end if;

	if rising_edge(clk) then
		btn3 <= btn2;
	end if;

	if rising_edge(clk) then
		btn4 <= btn3;
	end if;

	--game stuff
	if (rising_edge(clk)) and (row = 10d"1") and (col = 10d"1") then


		-- Collision for cactus 1
		-- intersection of Y coordinates
		if ((playerY + player_diameter) >= cactusY) then 
			-- intersection of X coordinates
			if ((playerX - player_diameter) <= cactusX) and ((cactusX < playerX + player_diameter)) then
					gameOver <= '1';		
			-- collision for cactus 2
			-- intersection of X coordinates
			elsif ((playerX - player_diameter) <= cactus2X) and ((cactus2X < playerX + player_diameter)) then
					gameOver <= '1';
			end if;
		end if;

		-- Cactus movement 
		if (cactusX > 10d"640") then
			cactusX <= 10d"0";
		elsif (gameover = '0') then
			cactusX <= cactusX + CACTUS_SPEED;
		end if;
		
		 --Cactus2 movement
		if ((cactus2X > 10d"605") and (cactus2X = 10d"35")) then
			cactus2X <= 10d"0";
		elsif (gameover = '0') then
			cactus2X <= cactus2X + CACTUS_SPEED;
		end if;
		
		--Activating jump animation
		if (btn4 = '0') then
			-- restarts the game
			if (gameover = '0') then
				jumping <= '1';
			end if;
			
			-- restarts the game
		end if;

		 --Jumping animation
		if (jumping = '1' and falling = '0') then
			if ((playerY + (player_diameter)/2) > JUMP_HEIGHT) then
				playerY <= playerY - JUMP_SPEED;
			else
				jumping <= '0';
				falling <= '1';
			end if;
		-- Falling animation
		else
			if (falling = '1') then
				if ((playerY) < PLAYER_DEF_POS_Y) then
					playerY <= playerY + FALL_SPEED;
				else
					falling <= '0';
				end if;
			end if;
		end if;
		
	end if;
	end process;
end;