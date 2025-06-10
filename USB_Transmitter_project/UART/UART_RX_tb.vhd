
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_uart_rx_entity is
end tb_uart_rx_entity;

architecture sim of tb_uart_rx_entity is
    constant clk_rate : integer := 1000000; -- 1 MHz clock rate
    signal input_sig, reset_sig, continue_sig, baud_clk : std_logic := '0';
    signal input_ready : std_logic;
    signal RX_input : std_logic_vector (7 downto 0);

    component uart_rx_entity 
        generic(clk_rate : integer := 1000000); -- set clock to 1MHz as default 
        port (
            input, reset_sig, continue_sig : in std_logic;
            input_ready : out std_logic;
            RX_input : out std_logic_vector(7 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    constant clk_period : time := 1 sec / clk_rate;

begin
    uut: uart_rx_entity
        generic map (clk_rate => clk_rate)
        port map (
            input => input_sig,
            reset_sig => reset_sig,
            continue_sig => continue_sig,
            input_ready => input_ready,
            RX_input => RX_input
        );

    -- Clock generation process
    clk_gen_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Input signal generation process
    input_gen_process : process
    begin
        reset_sig <= '1';
        wait for 10 * clk_period;
        reset_sig <= '0';
        continue_sig <= '1';
        wait for 10 * clk_period;
        input_sig <= '0';
        wait for 10 * clk_period;
        input_sig <= '0';
        wait for 10 * clk_period;
        input_sig <= '1';
        wait for 10 * clk_period;
        input_sig <= '1';
        wait for 10 * clk_period;
        input_sig <= '0';
        wait for 10 * clk_period;
        input_sig <= '0';
        wait for 10 * clk_period;
        input_sig <= '1';
        continue_sig <= '0';
        wait;
    end process;

    -- Monitor process to print results
    monitor_process : process
    begin
        while true loop
            wait for 50 * clk_period;
            --report "RX Input: " & to_string(RX_input);
        end loop;
    end process;
end sim;
