library ieee;
use ieee.std_logic_1164.all;
library processor;

entity reg_file_tb is
end reg_file_tb;

architecture tb of reg_file_tb is
    signal clk, src_en, dst_en, mdr_force_in : std_logic := 'Z';
    signal src_sel, dst_sel : std_logic_vector(5 downto 0) := (others => 'Z');
    signal data_1 : std_logic_vector(15 downto 0) := (others => '0');
    signal data_2, mar_data_out, mdr_data_in, mdr_data_out : std_logic_vector(15 downto 0) := (others => 'Z');
    constant period : time := 1 ns;

    begin
        reg_file_inst : entity processor.reg_file
            generic map ( 
                N => 16,
                num_reg => 6
            )
            port map (
                clk => clk,
                src_en => src_en,
                dst_en => dst_en,
                src_sel => src_sel,
                dst_sel => dst_sel,
                data_1 => data_1,
                data_2 => data_2,
                mdr_force_in => mdr_force_in,
                mdr_data_in => mdr_data_in,
                mdr_data_out => mdr_data_out,
                mar_data_out => mar_data_out
            );
        process is
            begin
                -- load r0 with 00AA
                dst_en <= '1';
                dst_sel <= "000001";
                data_1 <= x"00AA";
                wait for period;
                -- load r1 with 00BB
                dst_sel <= "000010";
                data_1 <= x"00BB";
                wait for period;
                -- load r2 with 00CC
                dst_sel <= "000100";
                data_1 <= x"00CC";
                wait for period;
                -- load r3 with 00DD
                dst_sel <= "001000";
                data_1 <= x"00DD";
                wait for period;
                data_1 <= (others => 'Z');
                -- force data on MDR manually
                src_en <= '0';
                dst_en <= '1';
                dst_sel <= "100000";
                mdr_data_in <= x"ABCD";
                mdr_force_in <= '1';
                wait for period;
                dst_en <= '0';
                data_2 <= (others => 'Z');
                mdr_data_in <= (others => 'Z');
                mdr_force_in <= 'Z';
                assert (mdr_data_out = x"ABCD") report "MDR forcing doesn't work!";
                wait for period;
                data_2 <= (others => 'Z');
            end process;

        process is
            begin
                clk <= '0';
                wait for period / 2;
                clk <= '1';
                wait for period / 2;
            end process;
end tb;