library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;
entity Procesador2 is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           AluOut : out  STD_LOGIC_VECTOR (31 downto 0):= (others => '0'));
			  
end Procesador2;
architecture Behavioral of Procesador2 is

	COMPONENT ALU
	PORT(
		Aluin1 : IN std_logic_vector(31 downto 0);
		Aluin2 : IN std_logic_vector(31 downto 0);
		Carry : IN std_logic;
		Aluop : IN std_logic_vector(5 downto 0);          
		Aluout : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	COMPONENT ControlUnit
	PORT(
		op : IN std_logic_vector(1 downto 0);
		op3 : IN std_logic_vector(5 downto 0);          
		cuout : OUT std_logic_vector(5 downto 0)
		);
	END COMPONENT;
	
	COMPONENT InstructionMemory
	PORT(
		rst : IN std_logic;
		address : IN std_logic_vector(31 downto 0);          
		imout : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	COMPONENT MUX1
	PORT(
		Muxin1 : IN std_logic_vector(31 downto 0);
		Muxin2 : IN std_logic_vector(31 downto 0);
		Selector : IN std_logic;          
		Muxout : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	COMPONENT ProgramCounter
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		Datain : IN std_logic_vector(31 downto 0);          
		Dataout : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	COMPONENT RegisterFile
	PORT(
		rs1 : IN std_logic_vector(5 downto 0);
		rs2 : IN std_logic_vector(5 downto 0);
		rd : IN std_logic_vector(5 downto 0);
		rst : IN std_logic;
		dwr : IN std_logic_vector(31 downto 0);          
		crs1 : OUT std_logic_vector(31 downto 0);
		crs2 : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	COMPONENT SEU1
	PORT(
		Imm : IN std_logic_vector(12 downto 0);          
		Seuout : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	COMPONENT Sumador
	PORT(
		Datain : IN std_logic_vector(31 downto 0);          
		Dataout : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	COMPONENT nProgramCounter
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		Datain1 : IN std_logic_vector(31 downto 0);          
		Dataout1 : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	COMPONENT PSRM
	PORT(
		rst : IN std_logic;
		crs1 : IN std_logic;
		crs2 : IN std_logic;
		Aluop : IN std_logic_vector(5 downto 0);
		Aluout : IN std_logic_vector(31 downto 0);          
		nzvc : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
	COMPONENT PSR
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		NZVC : IN std_logic_vector(3 downto 0);
		nCWP : IN std_logic;          
		CWP : OUT std_logic;
		carry : OUT std_logic
		);
	END COMPONENT;

	COMPONENT WindowsManager
	PORT(
		cwp : IN std_logic;
		rs1 : IN std_logic_vector(4 downto 0);
		rs2 : IN std_logic_vector(4 downto 0);
		rd : IN std_logic_vector(4 downto 0);
		op : IN std_logic_vector(1 downto 0);
		op3 : IN std_logic_vector(5 downto 0);          
		cwpout : OUT std_logic;
		rs1out : OUT std_logic_vector(5 downto 0);
		rs2out : OUT std_logic_vector(5 downto 0);
		rdout : OUT std_logic_vector(5 downto 0)
		);
	END COMPONENT;

signal npctopc,sumtonpc,pctoim,regim,seutomux,crs1toalu,crs2tomux,muxtoalu,aluresult : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal cutoalu : std_logic_vector(5 downto 0) := "000000";	
signal rs1wmtorf,rs2wmtorf,rdwmtorf : std_logic_vector(5 downto 0) := "000000";
signal icctopsr : std_logic_vector(3 downto 0) := "0000";	
signal cwptowm,cwptopsr,carrytoalu : std_logic := '0';
	
begin


	Inst_ALU: ALU PORT MAP(
		Aluin1 => crs1toalu,
		Aluin2 => muxtoalu,
		Carry => carrytoalu,
		Aluop => cutoalu,
		Aluout => aluresult
	);
	
	Inst_ControlUnit: ControlUnit PORT MAP(
		op => regim(31 downto 30),
		op3 => regim(24 downto 19),
		cuout => cutoalu
	);

	Inst_InstructionMemory: InstructionMemory PORT MAP(
		rst => rst,
		address => pctoim,
		imout => regim
	);
	
	Inst_MUX1: MUX1 PORT MAP(
		Muxin1 => crs2tomux,
		Muxin2 => seutomux,
		Selector => regim(13),
		Muxout => muxtoalu
	);

	Inst_ProgramCounter: ProgramCounter PORT MAP(
		rst => rst,
		clk => clk,
		Datain => npctopc,
		Dataout => pctoim
	);

	Inst_RegisterFile: RegisterFile PORT MAP(
		rs1 => rs1wmtorf,
		rs2 => rs2wmtorf,
		rd => rdwmtorf,
		rst => rst,
		dwr => aluresult,
		crs1 => crs1toalu,
		crs2 => crs2tomux
	);
	
	Inst_SEU1: SEU1 PORT MAP(
		Imm => regim(12 downto 0),
		Seuout => seutomux
	);
	
	Inst_Sumador: Sumador PORT MAP(
		Datain => npctopc,
		Dataout => sumtonpc
	);
	
	Inst_nProgramCounter: nProgramCounter PORT MAP(
		rst => rst,
		clk => clk,
		Datain1 => sumtonpc,
		Dataout1 => npctopc
	);
	
	Inst_PSRM: PSRM PORT MAP(
		rst => rst,
		crs1 => crs1toalu(31),
		crs2 => muxtoalu(31),
		Aluop => cutoalu,
		Aluout => aluresult,
		nzvc => icctopsr
	);
	
	Inst_PSR: PSR PORT MAP(
		rst => rst,
		clk => clk,
		NZVC => icctopsr,
		nCWP => cwptopsr,
		CWP => cwptowm,
		carry => carrytoalu
	);
	
	Inst_WindowsManager: WindowsManager PORT MAP(
		cwp => cwptowm,
		rs1 => regim(18 downto 14),
		rs2 => regim(4 downto 0),
		rd => regim(29 downto 25),
		op => regim(31 downto 30),
		op3 => regim(24 downto 19),
		cwpout => cwptopsr,
		rs1out => rs1wmtorf,
		rs2out => rs2wmtorf,
		rdout => rdwmtorf
	);
	AluOut<=aluresult;
end Behavioral;