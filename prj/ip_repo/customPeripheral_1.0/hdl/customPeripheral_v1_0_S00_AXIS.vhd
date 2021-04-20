library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity customPeripheral_v1_0_S00_AXIS is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
        fifo_data_out : out std_logic_vector(31 downto 0);
        fifo_data_count : out std_logic_vector(12 downto 0);
        fifo_rd_en      : in std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end customPeripheral_v1_0_S00_AXIS;

architecture arch_imp of customPeripheral_v1_0_S00_AXIS is

	signal axis_tready	: std_logic;
	
	signal axis_tvalid : std_logic;
	
	-- FIFO write enable
	signal fifo_wr_en : std_logic;
	
	-- FIFO full flag
	signal fifo_full_flag : std_logic;
	
begin	
    
  fifo0: entity work.fifo_generator_0
  port map (
    clk => S_AXIS_ACLK,
    din => S_AXIS_TDATA,
    wr_en => fifo_wr_en,
    rd_en => fifo_rd_en,
    dout  => fifo_data_out,
    full  => fifo_full_flag,
    empty => open,
    data_count => fifo_data_count
  );

  fifo_wr_en <= axis_tready and axis_tvalid;
  axis_tvalid <= S_AXIS_TVALID;
  axis_tready <= '0' when fifo_full_flag = '1' else
                  '1';
  
    -- Add user logic here

	-- User logic ends

end arch_imp;
