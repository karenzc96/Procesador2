library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity PSRM is
    Port ( rst : in  STD_LOGIC;
           crs1 : in  STD_LOGIC;
           crs2 : in  STD_LOGIC;
           Aluop : in  STD_LOGIC_VECTOR (5 downto 0);
           Aluout : in  STD_LOGIC_VECTOR (31 downto 0);
           nzvc : out  STD_LOGIC_VECTOR (3 downto 0):=(others=>'0'));
end PSRM;
architecture Behavioral of PSRM is
begin
	process (rst, Aluop, Aluout, crs1, crs2)
		begin
			if rst = '1' then 
				nzvc <= "0000";
			else	
				--Logicas   andcc						nandcc					orcc					norcc						xorcc						xnorcc
				if Aluop = "010001" or Aluop = "010101" or Aluop = "010010" or ALuop = "010110" or Aluop = "010011" or ALuop = "010111" then 
					nzvc(3) <= Aluout(31);
					if Aluout = "00000000000000000000000000000000" then 
						nzvc(2) <= '1';
					else
						nzvc(2) <= '0';
					end if;
					nzvc(1) <= '0';
					nzvc(0) <= '0';
				end if;
				--Aritmeticas
								--Addcc				--AddXcc
				if Aluop = "010000" or Aluop = "011000" then
					nzvc(3) <= Aluout(31);
					if Aluout = "00000000000000000000000000000000" then 
						nzvc(2) <= '1';
					else
						nzvc(2) <= '0';
					end if;
					nzvc(1) <= (crs1 and crs2 and (not Aluout(31))) or ((not crs1) and (not crs2) and Aluout(31));
					nzvc(0) <= (crs1 and crs2) or ((not Aluout(31)) and (crs1 or crs2));
				end if;
								--Subcc				Subxcc
				if ALuop = "010100" or Aluop = "011100" then
					nzvc(3) <= Aluout(31);
					if Aluout = "00000000000000000000000000000000" then 
						nzvc(2) <= '1';
					else
						nzvc(2) <= '0';
					end if;
					nzvc(1) <= (crs1 and (not crs2) and (not Aluout(31))) or ((not crs1) and crs2 and Aluout(31));
					nzvc(0) <= ((not crs1) and crs2) or (Aluout(31) and ((not crs1) or crs2));
				end if;
			end if;
	end process;
end Behavioral;
