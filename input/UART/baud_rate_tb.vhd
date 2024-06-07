library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_baud_rate is
end tb_baud_rate;

architecture sim of tb_baud_rate is
    constant clk_rate : integer := 1000000; -- 1 kHz clock rate
    signal input_sig : std_logic := '0';
    signal baud_rate : integer;

    component baud_rate_entity
        generic(clk_rate : integer := 1000000);
        port (
            input : in std_logic;
            baud_rate : out integer
        );
    end component;

    signal clk : std_logic := '0';
    constant clk_period : time := 1 sec / clk_rate;
begin
    uut: baud_rate_entity
        generic map (clk_rate => clk_rate)
        port map (
            input => input_sig,
            baud_rate => baud_rate
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
      input_sig<= '0';
      wait for 100 us;
      input_sig<= '1';
      wait for 50 us;
      input_sig<= '0';
      wait for 25 us;
      input_sig<= '1';
      wait for 75 us;
      input_sig<= '0';
    wait;
    end process;
   -- begin
   --     input_sig <= '0';
   --     wait for 10 * clk_period;
   --     input_sig <= '1';
   --     wait for 20 * clk_period;
   --     input_sig <= '1';
   --     wait for 10 * clk_period;
   --     input_sig <= '1';
   --     wait for 30 * clk_period;
   --     input_sig <= '0';
   --     wait for 10 * clk_period;
   --     input_sig <= '1';
   --     wait for 20 * clk_period;
   --     input_sig <= '0';
   -- end process;

    -- Monitor process to print results
    monitor_process : process
    begin
      while true loop 
        wait for 50 *clk_period;
          report "Baud rate calculated: " & integer'image(baud_rate);
      end loop; 
    end process;
end sim;

