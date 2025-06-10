library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_level_tb is
end top_level_tb;

architecture Behavioral of top_level_tb is
    -- Component Declaration for the Unit Under Test (UUT)
    component top_level_entity
        port (
            clk : in std_logic;
            reset : in std_logic;
            RX_input : in std_logic;
            uart_reset : in std_logic;
            continue_sig : in std_logic;
            buff_ready : in std_logic
        );
    end component;

    -- Signals for UUT
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal RX_input : std_logic := '0';
    signal uart_reset : std_logic := '0';
    signal continue_sig : std_logic := '0';
    signal buff_ready : std_logic := '1';

    -- Clock period definitions
    constant clk_period : time := 10 ns;

    type data_array_type is array (0 to 1023) of std_logic_vector(7 downto 0);
    signal data_array : data_array_type;
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: top_level_entity
        port map (
            clk => clk,
            reset => reset,
            RX_input => RX_input,
            uart_reset => uart_reset,
            continue_sig => continue_sig,
            buff_ready => buff_ready
        );

    -- Clock process definitions
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset state for 100 ns
        reset <= '1';
        uart_reset <= '1';
        wait for 100 ns;
        reset <= '0';
        uart_reset <= '0';

        -- Allow some time for the system to stabilize
        wait for clk_period * 10;

        -- Apply test vectors
        RX_input <= '1';
        wait for clk_period;
        RX_input <= '0';
        wait for clk_period;
        RX_input <= '1';
        wait for clk_period;
        RX_input <= '0';
        wait for clk_period;
        RX_input <= '1';
        wait for clk_period;
        RX_input <= '1';
        wait for clk_period;
        RX_input <= '1';
        wait for clk_period;
        RX_input <= '0';
        wait for clk_period;
        RX_input <= '1';
        wait for clk_period;
        RX_input <= '0';
        wait for clk_period;
        continue_sig <= '0';
        wait for clk_period;
        uart_reset <= '1';
        RX_input <= '1';
        wait;

        -- Initialize data array with test data
        for i in 0 to 1023 loop
            data_array(i) <= std_logic_vector(to_unsigned(i mod 256, 8));
        end loop;

        -- Apply data from the array to the RX_input signal
        for i in 0 to 1023 loop
            RX_input <= data_array(i)(0);
            wait for clk_period;
        end loop;

        -- Wait for a while to observe the output
        wait for 200 ns;

        -- Finish simulation
        wait;
    end process;
end Behavioral;

