library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity debounce_fsm is
   port(
      clk, reset : in  std_logic;
      sw         : in  std_logic;
      m_tick     : in  std_logic;
      db         : out std_logic
   );
end debounce_fsm;

architecture arch of debounce_fsm is
   type eg_state_type is 
     (zero, wait1_1, wait1_2, wait1_3, one, wait0_1, wait0_2, wait0_3);
   signal state_reg, state_next : eg_state_type;
begin
   -- state register
   process(clk, reset)
   begin
      if (reset = '1') then
         state_reg <= zero;
      elsif (clk'event and clk = '1') then
         state_reg <= state_next;
      end if;
   end process;
   -- next-state/output logic
   process(state_reg, sw, m_tick)
   begin
      state_next <= state_reg;   
      db         <= '0';       
      case state_reg is
         when zero =>
            if sw = '1' then
               state_next <= wait1_1;
            end if;
         when wait1_1 =>
            if sw = '0' then
               state_next <= zero;
            else
               if m_tick = '1' then
                  state_next <= wait1_2;
               end if;
            end if;
         when wait1_2 =>
            if sw = '0' then
               state_next <= zero;
            else
               if m_tick = '1' then
                  state_next <= wait1_3;
               end if;
            end if;
         when wait1_3 =>
            if sw = '0' then
               state_next <= zero;
            else
               if m_tick = '1' then
                  state_next <= one;
               end if;
            end if;
         when one =>
            db <= '1';
            if sw = '0' then
               state_next <= wait0_1;
            end if;
         when wait0_1 =>
            db <= '1';
            if sw = '1' then
               state_next <= one;
            else
               if m_tick = '1' then
                  state_next <= wait0_2;
               end if;
            end if;
         when wait0_2 =>
            db <= '1';
            if sw = '1' then
               state_next <= one;
            else
               if m_tick = '1' then
                  state_next <= wait0_3;
               end if;
            end if;
         when wait0_3 =>
            db <= '1';
            if sw = '1' then
               state_next <= one;
            else
               if m_tick = '1' then
                  state_next <= zero;
               end if;
            end if;
      end case;
   end process;
end arch;