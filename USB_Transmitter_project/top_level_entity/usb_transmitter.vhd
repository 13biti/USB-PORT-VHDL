library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity usb_transmitter is
    port (
        clk : in std_logic;
        reset : in std_logic;
        input_data : in std_logic_vector(7 downto 0);
        input_valid : in std_logic;
        data_out : out std_logic_vector(7 downto 0);
        buff_ready : in std_logic
    );
end usb_transmitter;

architecture Behavioral of usb_transmitter is
    type state_type is (IDLE, CONTROL, BULK);
    signal state : state_type := IDLE;
    signal byte_counter : integer range 0 to 1024 := 0;
    signal data_toggle : std_logic := '0';
    signal setup_step : integer range 0 to 9 := 0; 
    signal next_data_out : std_logic_vector(7 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            byte_counter <= 0;
            data_toggle <= '0';
            data_out <= (others => '0');
            setup_step <= 0;
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if input_valid = '1' then
                        state <= CONTROL;
                        setup_step <= 0;
                    end if;

                when CONTROL =>
                    case setup_step is
                        when 0 =>
                            next_data_out <= "11010010";  -- SETUP PID (1101 + check)
                        when 1 =>
                            next_data_out <= "0000" & "0001";  -- Address (7 bits) and Endpoint (4 bits)
                        when 2 =>
                            next_data_out <= "10000000";  -- bmRequestType (0x80)
                        when 3 =>
                            next_data_out <= "00000110";  -- bRequest (0x06)
                        when 4 =>
                            next_data_out <= "00000001";  -- wValue LSB (0x0100)
                        when 5 =>
                            next_data_out <= "00000000";  -- wValue MSB (0x0100)
                        when 6 =>
                            next_data_out <= "00000000";  -- wIndex LSB (0x0000)
                        when 7 =>
                            next_data_out <= "00000000";  -- wIndex MSB (0x0000)
                        when 8 =>
                            next_data_out <= "00010010";  -- wLength LSB (0x0012)
                        when 9 => 
                            next_data_out <= "00000000"; --idle 
                    end case;
                    if buff_ready = '1' then
                        data_out <= next_data_out;
                        if setup_step = 8 then
                            state <= BULK;
                            setup_step <= 9;
                        else  
                          setup_step <= setup_step + 1;
                        end if ;
                    end if;

                when BULK =>
                    if byte_counter < 1024 then
                        if input_valid = '1' and buff_ready = '1' then
                            if data_toggle = '0' then
                                data_out <= "11000000";  -- DATA0 PID
                            else
                                data_out <= "11001011";  -- DATA1 PID
                            end if;
                            data_out <= input_data;
                            if  byte_counter /= 1023 then 
                              byte_counter <= byte_counter + 1;
                            else 
                              byte_counter <= 1024;
                            end if ;
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

