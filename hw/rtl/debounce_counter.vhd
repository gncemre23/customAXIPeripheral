library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity debounce_counter is
   generic(N : integer := 20);  -- 2^N * 10ns = 10ms tick
   port(
      clk, reset : in  std_logic;
      m_tick     : out std_logic
   );
end debounce_counter;

architecture arch of debounce_counter is
   signal q_reg, q_next : unsigned(N - 1 downto 0);
begin
   process(clk, reset)
   begin
      if (reset = '1') then
         q_reg <= (others => '0');
      elsif (clk'event and clk = '1') then
         q_reg <= q_next;
      end if;
   end process;
   q_next <= q_reg + 1;
   --output tick
   m_tick <= '1' when q_reg = 0 else '0';
end arch;