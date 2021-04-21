library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity stream_generator is
Port (clk : in std_logic;
      rst_n: in std_logic;
      start : in std_logic;
      --AXI Stream Ports
      axi_t_valid : out std_logic;
      axi_t_ready : in  std_logic;
      axi_t_last  : out std_logic;
      axi_t_sdata : out std_logic_vector(31 downto 0)   
);
end stream_generator;

architecture Behavioral of stream_generator is

signal count_next, count_reg   : unsigned(10 downto 0);

type state_type is (INIT, BURST, LAST);
signal state_next, state_reg : state_type;
begin

process(clk)
begin
    if(rising_edge(clk)) then
        state_reg <= state_next after 1 ns;
        count_reg <= count_next after 1 ns;
    end if;
end process;

process(start, state_reg, axi_t_ready, rst_n)
begin
    --default
    axi_t_valid <= '0';
    count_next <= count_reg;
    state_next <= state_reg;
    if(rst_n = '0') then
        state_next <= INIT;
        count_next <= (others => '0');
    else
        case state_reg is
            when INIT => 
                count_next <= (others => '0');
                if(start = '1') then
                    state_next <= BURST;
                end if;
            when BURST =>
                axi_t_valid <= '1';
                if(axi_t_ready = '1') then
                    count_next <= count_reg + 1;
                    if(count_reg = to_unsigned(2046,11)) then 
                        state_next <= LAST;
                    end if;
                end if;
            when LAST =>
                axi_t_valid <= '1';
                axi_t_last  <= '1';
                state_next <= INIT;
            
            when others =>
                state_next <= INIT;
                
        end case;
    end if;
end process;

end Behavioral;
