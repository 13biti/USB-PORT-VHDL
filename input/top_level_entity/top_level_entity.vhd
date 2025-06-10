library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_level_entity is
    port (
        clk : in std_logic;
        reset : in std_logic;
        input_data : in std_logic_vector(7 downto 0);
        input_valid : in std_logic;
        buff_ready : in std_logic
    );
end top_level_entity;

architecture Behavioral of top_level_entity is
    signal data_out : std_logic_vector(7 downto 0);
    signal wr_en : std_logic;
    signal extended_data_out : std_logic_vector(31 downto 0);
    signal rd_en : std_logic := '0';
    signal rd_data : std_logic_vector(31 downto 0);
    signal empty : std_logic;
    signal full : std_logic;
    signal fill_count : integer range 0 to 7;

begin
    usb_trans_inst : entity work.usb_transmitter
        port map (
            clk => clk,
            reset => reset,
            input_data => input_data,
            input_valid => input_valid,
            data_out => data_out,
            buff_ready => buff_ready
        );

    ring_buff_inst : entity work.ring_buffer_entity
        generic map (
            RAM_size => 8,
            RAM_element_size => 32
        )
        port map (
            clk => clk,
            rst => reset,
            wr_en => wr_en,
            wr_data => extended_data_out,
            rd_en => rd_en,
            rd_valid => open,
            rd_data => rd_data,
            empty => empty,
            full => full,
            fill_count => fill_count
        );

    -- Extend data_out to 32 bits
    extended_data_out <= (23 downto 0 => '0') & data_out;

    wr_en <= '1' when (input_valid = '1') and (full = '0') else '0';
    rd_en <= '0';  -- Adjust as necessary for your application

end Behavioral;

