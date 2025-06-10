library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity usb_transmitter is
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
end usb_transmitter;

architecture Behavioral of usb_transmitter is
    type state_type is (IDLE, CONTROL, BULK);
    signal state : state_type := IDLE;
    signal byte_counter : integer range 0 to 1023 := 0;
    signal data_toggle : std_logic := '0';
    signal setup_data : std_logic_vector(7 downto 0) := (others => '0');
    signal setup_byte : integer range 0 to 7 := 0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            byte_counter <= 0;
            data_toggle <= '0';
            pid <= (others => '0');
            address <= (others => '0');
            endpoint <= (others => '0');
            data_out <= (others => '0');
            send <= '0';
            setup_byte <= 0;
            ready_signal <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if input_valid = '1' then
                        state <= CONTROL;
                        setup_byte <= 0;
                        ready_signal <= '0';
                    end if;

                when CONTROL =>
                    pid <= "11010001";  -- SETUP PID with field (1101 for setup + 0001 check)
                    address <= "0000000";  -- Host address (0)
                    endpoint <= "0001";  -- Endpoint (1)
                    send <= '1';
                    case setup_byte is
                        when 0 =>
                            setup_data <= "10000000";  -- bmRequestType specifies the direction of data transfer
                        when 1 =>
                            setup_data <= "00000110";  -- bRequest 
                        when 2 =>
                            setup_data <= "00000001";  -- wValue LSB (0x0100, low byte)
                        when 3 =>
                            setup_data <= "00000000";  -- wValue MSB (0x0100, high byte)
                        when 4 =>
                            setup_data <= "00000000";  -- wIndex LSB (0x0000, low byte)
                        when 5 =>
                            setup_data <= "00000000";  -- wIndex MSB (0x0000, high byte)
                        when 6 =>
                            setup_data <= "00010010";  -- wLength LSB (0x0012, low byte)
                        when 7 =>
                            setup_data <= "00000000";  -- wLength MSB (0x0012, high byte)
                            send <= '0';
                            state <= BULK;
                            setup_byte <= 0;
                    end case;
                    data_out <= setup_data;
                    setup_byte <= setup_byte + 1;

                when BULK =>
                    -- Implement bulk data transfer here
                    if byte_counter < 1024 then
                        ready_signal <= '1';
                        if input_valid = '1' then
                            if data_toggle = '0' then
                                pid <= "11000000";  -- DATA0 PID with correct check field
                            else
                                pid <= "11001011";  -- DATA1 PID with correct check field
                            end if;
                            data_out <= input_data;
                            send <= '1';
                            ready_signal <= '0';
                            byte_counter <= byte_counter + 1;
                            data_toggle <= not data_toggle;
                        end if;
                    else
                        state <= IDLE;
                        byte_counter <= 0;
                        data_toggle <= '0';
                    end if;
            end case;
        end if;
    end process;
end Behavioral; 

