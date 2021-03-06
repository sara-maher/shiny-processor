library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library processor;

entity ram is
	generic ( 
		N : integer := 16;
		addr_size : integer := 5
	); 
	port (
		clk, read_in, write_out : in std_logic;
		address : in  std_logic_vector(addr_size-1 downto 0);
		data_in  : in  std_logic_vector(N-1 downto 0);
		data_out : out std_logic_vector(N-1 downto 0));
end entity ram;

architecture mixed_ram of ram is
	type ram_type is array (0 to (2**addr_size)-1) of std_logic_vector(N-1 downto 0);
    signal ram : ram_type := (
		--R0=0,...,R5=5
		0 => X"0000",
		19 => X"0015",
		24576 => X"0011",
		others => X"0000"
    );
	begin
		process(clk) is
			begin
				if falling_edge(clk) then  
					if read_in = '1' then
						ram(to_integer(unsigned(address))) <= data_in;
					end if;
				end if;
		end process;
		data_out <= ram(to_integer(unsigned(address))) when (write_out = '1') else (others => 'Z');
end mixed_ram;

