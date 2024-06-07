library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity uart_rx_entity is 
    generic(clk_rate :integer := 1000000); -- set clock to 1MHz as default 
    port (
      input , reset_sig , continue_sig : in std_logic ;
      input_ready : out std_logic ;
      RX_input : out std_logic_vector (7 downto 0) );
end uart_rx_entity ;
architecture uart_rx_arch of uart_rx_entity is 
  component baud_rate_comp 
    generic (clk_rate : integer := 1000000);
    port (
      input : in std_logic ;
      baud_rate : out std_logic);
  end component;
signal baud_rate , sample_counter : integer := 0;
signal sample : std_logic_vector (0 to 7)
begin 
  baud_rate_generate : baud_rate_comp
  generic map (clk_rate : integer :=1000000);
  port map (
    input => input ;
    baud_rate => baud_rate );

  RX : process (input , reset_sig , continue_sig)
  begin
    while true loop 
      if  reset_sig = '1' then 
        RX_input <= X"00";
        continue_sig <= '0';
        input_ready <= '0';
      else if continue_sig = '1'
        while sample_counter < 8 loop  
          if sample_counter = '0' then 
            wait baud_rate /2 ;
          end if ; 
            sample_counter <= sample_counter +1;
            wait baud_rate;
            sample <= sample(7 downto 0) & input_sig;
        end loop ;
          RX_input <= sample ;
          input_ready <= '1';
      end if
    end loop ;
  end process ;
end uart_rx_arch; 


        

        
