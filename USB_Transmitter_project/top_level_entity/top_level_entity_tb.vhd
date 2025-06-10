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
            input_data : in std_logic_vector(7 downto 0);
            input_valid : in std_logic;
            buff_ready : in std_logic
        );
    end component;

    -- Signals for UUT
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal input_data : std_logic_vector(7 downto 0) := (others => '0');
    signal input_valid : std_logic := '0';
    signal buff_ready : std_logic := '1';

    -- Clock period definitions
    constant clk_period : time := 10 ns;

    type data_array_type is array (0 to 1023) of std_logic_vector(7 downto 0);
    signal data_array : data_array_type := (others => (others => '0'));

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: top_level_entity
        port map (
            clk => clk,
            reset => reset,
            input_data => input_data,
            input_valid => input_valid,
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
        wait for 100 ns;
        reset <= '0';

        -- Allow some time for the system to stabilize
        wait for clk_period * 10;

        -- Apply test vectors
        input_data <= "00000001";
        input_valid <= '1';
        wait for clk_period;
        input_data <= "00000010";
        wait for clk_period;
        input_data <= "00000011";
        wait for clk_period;
        input_data <= "00000100";
        wait for clk_period;
        input_valid <= '0';

        -- Initialize data array with test data
        for i in 0 to 1023 loop
            data_array(i) <= std_logic_vector(to_unsigned(i mod 256, 8));
        end loop;

        -- Apply data from the array to the input_data signal
        input_valid <= '1';
        for i in 0 to 1023 loop
            input_data <= data_array(i);
            wait until rising_edge(clk); 
        end loop;
        input_valid <= '0';

        -- Wait for a while to observe the output
        wait for 200 ns;

        -- Finish simulation
        wait;
    end process;
end Behavioral;

