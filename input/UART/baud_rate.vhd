library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity baud_rate_entity is 
  generic(clk_rate :integer := 1000000); -- set clock to 1MHz as default 
  port (
    input : in std_logic;
    baud_rate : out integer
  );
end baud_rate_entity;
architecture baud_rate_arch of baud_rate_entity is 
  signal counter , period : integer := 0;
  signal prev_input_status : std_logic := input;
  signal clk : std_logic := '0';
  signal timer : time := 1 sec /clk_rate;
begin 
    clk_gen_process : process
    begin 
        while true loop
            clk <= '0';
            wait for timer/2 ;
            clk <= '1';
            wait for timer/2 ;
        end loop;
    end process;

  period_counter : process(clk,input)
  begin 
    if rising_edge(clk) then
      if input /= prev_input_status then 
        period <= counter ;
        counter <= 0;
      else 
        counter <= counter + 1 ;
      end if; 
      prev_input_status <= input ;
    end if ;
  end process ;
  colculate_baud : process(period)
  begin 
    if period > 0 then 
      baud_rate <= clk_rate / period;
    end if ;
  end process ;
end baud_rate_arch;
  

