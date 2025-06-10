library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_level_entity is
    port (
        clk : in std_logic;
        reset : in std_logic;
        RX_input : in std_logic;
        uart_reset : in std_logic;
        continue_sig : in std_logic;
        buff_ready : in std_logic
    );
end top_level_entity;

architecture Behavioral of top_level_entity is

    -- UART receiver signals
    signal uart_data_out : std_logic_vector(7 downto 0);
    signal uart_data_valid : std_logic;

    -- Initial ring buffer signals
    signal init_wr_en : std_logic;
    signal init_wr_data : std_logic_vector(7 downto 0);
    signal init_rd_en : std_logic;
    signal init_rd_data : std_logic_vector(7 downto 0);
    signal init_rd_data_valid : std_logic;
    signal init_empty : std_logic;
    signal init_full : std_logic;
    signal init_fill_count : integer range 0 to 7;

    -- USB transmitter signals
    signal usb_data_out : std_logic_vector(7 downto 0);
    signal usb_data_valid : std_logic;

    -- Final ring buffer signals
    signal final_wr_en : std_logic;
    signal final_wr_data : std_logic_vector(7 downto 0);
    signal final_rd_en : std_logic;
    signal final_rd_data : std_logic_vector(7 downto 0);
    signal final_rd_data_valid : std_logic;
    signal final_empty : std_logic;
    signal final_full : std_logic;
    signal final_fill_count : integer range 0 to 7;

begin

    -- UART Receiver Instance
    uart_rx_inst : entity work.uart_rx_entity
        port map (
            RX_input => RX_input,
            reset_sig => uart_reset,
            continue_sig => continue_sig,
            input_ready => uart_data_valid,
            RX_result => uart_data_out
        );

    -- Initial Ring Buffer Instance
    init_ring_buffer_inst : entity work.ring_buffer_entity
        generic map (
            RAM_size => 8,
            RAM_element_size => 8
        )
        port map (
            clk => clk,
            rst => reset,
            wr_en => uart_data_valid,
            wr_data => uart_data_out,
            rd_en => init_rd_en,
            rd_valid => init_rd_data_valid,
            rd_data => init_rd_data,
            empty => init_empty,
            full => init_full,
            fill_count => init_fill_count
        );

    -- USB Transmitter Instance
    usb_trans_inst : entity work.usb_transmitter
        port map (
            clk => clk,
            reset => reset,
            input_data => init_rd_data,
            input_valid => init_rd_data_valid,
            data_out => usb_data_out,
            buff_ready => buff_ready
        );

    -- Final Ring Buffer Instance
    final_ring_buffer_inst : entity work.ring_buffer_entity
        generic map (
            RAM_size => 8,
            RAM_element_size => 8
        )
        port map (
            clk => clk,
            rst => reset,
            wr_en => usb_data_valid,
            wr_data => usb_data_out,
            rd_en => final_rd_en,
            rd_valid => final_rd_data_valid,
            rd_data => final_rd_data,
            empty => final_empty,
            full => final_full,
            fill_count => final_fill_count
        );

    -- Control logic for reading from the initial buffer and writing to the final buffer
    process(clk, reset)
    begin
        if reset = '1' then
            init_rd_en <= '0';
            usb_data_valid <= '0';
            final_wr_en <= '0';
        elsif rising_edge(clk) then
            -- Read from initial buffer if not empty
            if init_empty = '0' then
                init_rd_en <= '1';
            else
                init_rd_en <= '0';
            end if;

            -- Write to final buffer if USB data is valid
            if usb_data_valid = '1' and final_full = '0' then
                final_wr_en <= '1';
                final_wr_data <= usb_data_out;
            else
                final_wr_en <= '0';
            end if;

            -- USB data valid signal generation
            usb_data_valid <= init_rd_data_valid;
        end if;
    end process;

end Behavioral;

