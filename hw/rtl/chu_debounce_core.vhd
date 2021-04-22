library ieee;
use ieee.std_logic_1164.all;
entity debounce_core is
   generic(
      W : integer := 1;    -- width of input port
      N : integer := 20    -- # bit for 10-ms tick 2^N * clk period
   );
   port(clk     : in  std_logic;
        reset   : in  std_logic;
        din     : in  std_logic_vector(W-1 downto 0);
        db_out  : out std_logic_vector(W-1 downto 0));
end debounce_core;

architecture arch of debounce_core is
   signal m_tick      : std_logic;
   
begin
  
   --******************************************************************
   -- instantiate one counter and W debouncing FSMs
   --******************************************************************
   db_counter_unit : entity work.debounce_counter
      generic map(N => N)
      port map(
         clk    => clk,
         reset  => reset,
         m_tick => m_tick
      );
   gen_fsm_cell : for i in 0 to W-1 generate
      db_fsm_unit : entity work.debounce_fsm
         port map(
            clk    => clk,
            reset  => reset,
            sw     => din(i),
            m_tick => m_tick,
            db     => db_out(i)
         );
   end generate;
   

end arch;
