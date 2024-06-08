
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_rx_tb is
end uart_rx_tb;

architecture tb_arch of uart_rx_tb is

  signal input_signal, reset_signal, continue_signal, baud_clk : std_logic := '0';
  signal input_ready_signal : std_logic;
  signal RX_input_signal : std_logic_vector(7 downto 0);

begin

  dut: entity work.uart_rx_entity
    generic map (
      clk_rate => 1000000 -- 1 MHz clock rate
    )
    port map (
      input => input_signal,
      reset_sig => reset_signal,
      continue_sig => continue_signal,
      input_ready => input_ready_signal,
      RX_input => RX_input_signal
    );

  stimulus_process: process
  begin
    reset_signal <= '1';
    input_signal <= '0';
    continue_signal <= '0';
    wait for 1 ms;
    reset_signal <= '0';
    continue_signal <= '1';
    wait for 1 ms;
    input_signal <= '1';
    wait for 1 ms;
    input_signal <= '0';
    wait for 1 ms;
    input_signal <= '1';
    wait for 1 ms;
    input_signal <= '1';
    wait for 1 ms;
    input_signal <= '1';
    wait for 1 ms;
    input_signal <= '0';
    wait for 1 ms;
    input_signal <= '1';
    wait for 1 ms;
    continue_signal <= '0';
    wait for 1 ms;
    reset_signal <= '1';
    wait;
  end process;

end tb_arch;
