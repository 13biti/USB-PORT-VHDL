library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity usb_transmitter_tb is
end entity;

architecture Behavioral of usb_transmitter_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component usb_transmitter is
        port (
            clk : in std_logic;
            reset : in std_logic;
            input_valid : in std_logic;
            input_data : in std_logic_vector(7 downto 0);
            pid : out std_logic_vector(7 downto 0);
            address : out std_logic_vector(6 downto 0);
            endpoint : out std_logic_vector(3 downto 0);
            data_out : out std_logic_vector(7 downto 0);
            send : out std_logic;
            ready_signal : inout std_logic
        );
    end component;

    -- Inputs
    signal clk , ready_signal : std_logic := '0';
    signal reset : std_logic := '0';
    signal input_valid : std_logic := '0';
    signal input_data : std_logic_vector(7 downto 0) := (others => '0');
    
    -- Outputs
    signal pid : std_logic_vector(7 downto 0);
    signal address : std_logic_vector(6 downto 0);
    signal endpoint : std_logic_vector(3 downto 0);
    signal data_out : std_logic_vector(7 downto 0);
    signal send : std_logic;

    -- Clock period definition
    constant clk_period : time := 10 ns;

    -- Test data array
    type data_array is array (0 to 1023) of std_logic_vector(7 downto 0);
    signal test_data : data_array := (
        others => (others => '0')
    );

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: usb_transmitter port map (
        clk => clk,
        reset => reset,
        input_valid => input_valid,
        input_data => input_data,
        pid => pid,
        address => address,
        endpoint => endpoint,
        data_out => data_out,
        send => send,
        ready_signal => ready_signal
    );

    -- Clock process definitions
    clk_process : process
    begin
        while True loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- Fill test data with example values
        for i in 0 to 1023 loop
            test_data(i) <= std_logic_vector(to_unsigned(192, 8));
        end loop;

        -- Send setup packet
        input_valid <= '1';
        wait for clk_period;

        -- Send bulk data
        for i in 0 to 1023 loop
          if ready_signal = '1' then 
            input_data <= test_data(i);
            wait for clk_period;
          end if ;
        end loop;

        input_valid <= '0';
        wait;
    end process;

end Behavioral;

