
library ieee;
use ieee.std_logic_1164.all;

entity ring_buffer_entity_tb is
end entity ring_buffer_entity_tb;

architecture testbench of ring_buffer_entity_tb is
  signal clk, rst, wr_en, rd_en, rd_valid, empty, full: std_logic;
  signal wr_data, rd_data: std_logic_vector(31 downto 0);
  signal fill_count: integer range 7 downto 0;
  signal period : time := 1 ns ; 
  component ring_buffer_entity is
    generic (
      RAM_size : natural := 8;
      RAM_element_size : natural := 32
    );
    port (
      clk : in std_logic;
      rst : in std_logic;
      wr_en : in std_logic;
      wr_data : in std_logic_vector(RAM_element_size - 1 downto 0);
      rd_en : in std_logic;
      rd_valid : out std_logic;
      rd_data : out std_logic_vector(RAM_element_size - 1 downto 0);
      empty : out std_logic;
      full : out std_logic;
      fill_count : out integer range RAM_size - 1 downto 0
    );
  end component;

begin
  dut: ring_buffer_entity
    generic map (
      RAM_size => 8,
      RAM_element_size => 32
    )
    port map (
      clk => clk,
      rst => rst,
      wr_en => wr_en,
      wr_data => wr_data,
      rd_en => rd_en,
      rd_valid => rd_valid,
      rd_data => rd_data,
      empty => empty,
      full => full,
      fill_count => fill_count
    );

  stimulus: process
  begin
    rst <= '1';
    wr_en <= '0';
    wr_data <= (others => '0');
    rd_en <= '0';
    wait for 10 ns;

    rst <= '0';
    wait for 10 ns;

    wr_en <= '1';
    wr_data <= "10101010101010101010101010101010";
    wait for 10 ns;

    rd_en <= '1';
    wait for 10 ns;

    wr_en <= '1';
    wr_data <= "11110000111100001111000011110000";
    wait for 10 ns;

    rd_en <= '1';
    wait for 10 ns;

    wr_en <= '0';
    wait for 10 ns;

    rd_en <= '1';
    wait for 10 ns;

    wr_en <= '1';
    wr_data <= "01010101010101010101010101010101";
    wait for 10 ns;

    rd_en <= '1';
    wait for 10 ns;
    
    wr_en <= '1';
    wr_data <= "11111111000000001111111100000000";
    wait for 10 ns;

    wr_en <= '1';
    wr_data <= "00000000111111110000000011111111";
    wait for 10 ns;

    rd_en <= '1';
    wait for 10 ns;

    wr_en <= '1';
    wr_data <= "11001100110011001100110011001100";
    wait for 10 ns;

    rd_en <= '1';
    wait for 10 ns;

    
  end process stimulus;

  clk_generate : process 
    begin 
      clk <= '1';
      wait for period ;
      clk <= '0';
      wait for period ;
  end process ;
end architecture testbench;
