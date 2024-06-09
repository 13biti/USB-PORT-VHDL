library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity uart_rx_entity is 
    generic(clk_rate :integer := 1000000); -- set clock to 1MHz as default 
    port (
      RX_input , reset_sig , continue_sig : in std_logic ;
      input_ready : out std_logic ;
      RX_result : out std_logic_vector (7 downto 0) );
end uart_rx_entity ;
architecture uart_rx_arch of uart_rx_entity is 
  component baud_rate_entity 
    generic (clk_rate : integer := 1000000);
    port (
      input : in std_logic ;
      baud_rate : out integer);
  end component;
signal baud_rate : integer := 1000; 
signal sample_counter : integer := 0;
signal baud_clk , baud_input : std_logic := '1';
signal sample , tmpsmpl  : std_logic_vector (7 downto 0);
signal RX_buffer :  std_logic_vector(7 downto 0);
begin 
  
  baud_rate_generate : baud_rate_entity
  generic map (clk_rate => 1000000)
  port map (
    input => baud_input ,
    baud_rate => baud_rate );
  baud_rate_clk : process
    variable period : time := 0 ns;
  begin 
    if reset_sig = '1' then
      baud_clk <= '0';
      wait until baud_rate > 0 or reset_sig ='0';
    else
      wait until baud_rate > 0 or reset_sig = '1';
      if baud_rate > 0 then 
        period := 1 sec / baud_rate;
        while reset_sig /= '1' loop
          baud_clk <= '0';
          wait for period/2;
          baud_clk <= '1';
          wait for period/2;
        end loop;
      end if;
    end if;
  end process;
  
  RX : process (reset_sig, baud_clk )
    type state_type is (IDLE, RECEIVE, DONE);
    variable state : state_type := IDLE ;
  begin
    if reset_sig = '1' then
      RX_result <= X"00";
      --continue_sig <= '0';
      input_ready <= '0';
      sample_counter <= 0;
      sample <= X"00";
      baud_input <= '1';
      state := IDLE;
    else -- baud_rate /= 0 then
      --if rising_edge(baud_clk) then 
        case state is
           when IDLE =>
             if RX_input = '0' then  -- Detect start bit
               state := RECEIVE;
               baud_input <= '0';
               sample_counter <= 0;
             end if;
           when RECEIVE =>
             baud_input <= '1';
                if sample_counter < 8 and rising_edge(baud_clk) then 
                  baud_input <= not baud_input;
                  sample(sample_counter) <= RX_input;
                  sample_counter <= sample_counter + 1;
                elsif sample_counter = 8 then 
                  state := DONE;
                end if ;
           -- while sample_counter < 8 loop  
            --   if baud_clk = '1' then 
            --     sample(sample_counter) <= RX_input;
            --     sample_counter <= sample_counter + 1;
            --  --   for i in 6 downto 0 loop
            --  --     sample(i + 1) <= sample(i);
            --  --   end loop;
            --  --   sample(0) <= RX_input;
            --   --  for i in 7 downto 1 loop 
            --   --    sample(i) <= sample(i-1);
            --   --  end loop;
            --   --  sample(0) <= RX_input; 
            --     wait for period / 2; 
            --   end if ;
            -- end loop;
            -- state :=  DONE;
           when DONE =>
             RX_result <= sample;
             input_ready <= '1';
             baud_input <= '1';
             if continue_sig = '1' then
               state := IDLE;
               input_ready <= '0';
               sample_counter <= 0;
               sample <= X"00";
             end if;
        end case;
      --end if ; 
    end if;
  end process RX;
--    elsif continue_sig = '1' then
--      if sample_counter = 0 then
--        wait until rising_edge(input);
--      end if;
--
--      if sample_counter < 8 then
--        wait for baud_rate / 2;
--        sample_counter <= sample_counter + 1;
--        sample <= sample(6 downto 0) & input;
--      else
--        RX_input <= sample;
--        input_ready <= '1';
--        sample_counter <= 0;
--      end if;
--    else
--      input_ready <= '0';
--    end if;
--  end process RX;
 -- RX : process (input , reset_sig , continue_sig)
 -- begin
 --   while true loop 
 --     if  reset_sig = '1' then 
 --       RX_input <= X"00";
 --       continue_sig <= '0';
 --       input_ready <= '0';
 --     else if continue_sig = '1'
 --       while sample_counter < 8 loop  
 --         if sample_counter = '0' then 
 --           wait baud_rate /2 ;
 --         end if ; 
 --           sample_counter <= sample_counter +1;
 --           wait baud_rate;
 --           sample <= sample(7 downto 0) & input_sig;
 --       end loop ;
 --         RX_input <= sample ;
 --         input_ready <= '1';
 --     end if
 --   end loop ;
 -- end process ;
end uart_rx_arch; 


        

        
