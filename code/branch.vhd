library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.p_constants.all;
library processor;

entity branch is
    generic(
		counter_bits :integer:=2;
		control_word_width :integer:=32
    );
    port(
		clk, rst, z, c : in std_logic;
        offset: in std_logic_vector(7 downto 0);
        instruction: in std_logic_vector(2 downto 0);
        counter_rst, counter_enable : inout std_logic;
		control_word : out std_logic_vector(control_word_width-1 downto 0)
	);
end entity branch;

architecture behavorial of branch is
    type state_type is (check_flags, execute_state, finished_state);
    signal state : state_type := check_flags;
    signal count : std_logic_vector(counter_bits-1 downto 0);

    begin
        branch_seq : process (clk, rst, instruction, offset, z, c, count, counter_rst, counter_enable)
        begin
            if (rst='1') then
                state <= check_flags;
            elsif rising_edge(clk) then
                case state is
                    when check_flags =>
                        counter_rst <= '0';
                        if (instruction = "000") then
                            state <= execute_state;
                        elsif (instruction = "001" and z = '1') then
                            state <= execute_state;
                        elsif (instruction = "010" and z = '0') then
                            state <= execute_state;
                        elsif (instruction = "011" and c = '0') then
                            state <= execute_state;
                        elsif (instruction = "100" and (c = '0' or z = '1')) then
                            state <= execute_state;
                        elsif (instruction = "101" and c = '1') then
                            state <= execute_state;
                        elsif (instruction = "110" and (c = '1' or z = '1')) then
                            state <= execute_state;
                        else
                            state <= finished_state;
                            counter_rst <= '1';
                        end if;
                    when execute_state =>
                        if (counter_rst = '1') then
                            state <= finished_state;
                        elsif (to_integer(unsigned(count)) = 0) then
                            state <= execute_state;
                        elsif (to_integer(unsigned(count)) = 1) then
                            control_word <= PCout or F_A or TMP1in;
                            state <= execute_state;
                        elsif (to_integer(unsigned(count)) = 2) then
                            control_word <= BrIRout or F_ApB or PCin;
                            state <= finished_state;
                            counter_rst <= '1';
                        else
                            state <= finished_state;
                            counter_rst <= '1';
                        end if;
                    when finished_state =>
                        state <= finished_state;
                        counter_rst <= '1';
                end case;
            end if;
        end process;
        counter1 : entity processor.counter 
					generic map (n =>counter_bits) 
					port map (clk => clk, rst => counter_rst,enable =>counter_enable, count =>count);
end architecture;