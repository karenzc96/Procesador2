library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity PSR is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           NZVC : in  STD_LOGIC_VECTOR(3 DOWNTO 0);
           nCWP : in  STD_LOGIC;
           CWP : out  STD_LOGIC;
           carry : out  STD_LOGIC);
end PSR;
architecture Behavioral of PSR is
begin
	process(rst,clk,nCWP,NZVC)
		begin
			if (rst = '1') then 
				CWP <= '0';
				carry <= '0';
			elsif (rising_edge(clk)) then
				CWP <= nCWP;
				carry <= NZVC(0);
		end if;
	end process;
end Behavioral;