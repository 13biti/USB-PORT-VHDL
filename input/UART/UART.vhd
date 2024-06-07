library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity uart_tx_entity is 
    generic(clk_rate :integer := 1000000); -- set clock to 1MHz as default 
    port (
      input , reset_sig , continue_sig : in std_logic ;
      output_ready : out std_logic ;
      output : out std_logic_vector (7 downto 0) );
end uart_tx_entity ;
architecture uart_tx_arch of uart_tx_entity is 
  component baud_rate_comp 
    generic (clk_rate : integer := 1000000);
    port (
      input : in std_logic ;
      baud_rate : out std_logic);
  end component;
signal baud_rate , sample_counter : integer := 0;
begin 
  baud_rate_generate : baud_rate_comp
  generic map (clk_rate : integer :=1000000);
  port map (
    input => input ;
    baud_rate => baud_rate );

  TX : process (input , reset_sig , continue_sig)
  begin 
    if reset_sig = '1' then 
      output <= X"00";
      continue_sig <= '0';
      output_ready <= '0';
    else 
      if continue_sig = '1' and sample_counter < 9 then 
        sample_counter <= sample_counter +1;



