library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity usb_transmitter_tb is
end entity;

architecture Behavioral of usb_transmitter_tb is

    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal input_data : std_logic_vector(7 downto 0) := (others => '0');
    signal input_valid : std_logic := '0';
    signal data_out : std_logic_vector(7 downto 0);
    signal buff_ready : std_logic := '0';

    component usb_transmitter is
        port (
            clk : in std_logic;
            reset : in std_logic;
            input_data : in std_logic_vector(7 downto 0);
            input_valid : in std_logic;
            data_out : out std_logic_vector(7 downto 0);
            buff_ready : in std_logic
        );
    end component;

    type data_array_type is array (0 to 1023) of std_logic_vector(7 downto 0);
    signal data_array : data_array_type;

begin
    uut: usb_transmitter
        port map (
            clk => clk,
            reset => reset,
            input_data => input_data,
            input_valid => input_valid,
            data_out => data_out,
            buff_ready => buff_ready
        );

    -- Clock generation
    clk <= not clk after 10 ns;

    -- Test procedure
    process
    begin
        -- Initialize the array with data
        for i in 0 to 1023 loop
            data_array(i) <= std_logic_vector(to_unsigned(i mod 256, 8));
        end loop;

        -- Reset the design
        reset <= '1';
        wait for 40 ns;
        reset <= '0';
        wait for 20 ns;

        -- Start sending data
        input_valid <= '1';
        buff_ready <= '1';
        for i in 0 to 1023 loop
            input_data <= data_array(i);
            wait until rising_edge(clk); 
        end loop;

        -- End simulation
        wait;
    end process;

end Behavioral;

