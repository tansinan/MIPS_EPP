library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;

entity HighLatencyMathInstructionDecode is
	port
	(
		reset : in Reset_t;
		clock : in Clock_t;
		instruction : in Instruction_t;
		instructionExecutionEnabled : in EnablingControl_t;
		registerFileData : in mips_register_file_port;
		registerFileControl : out RegisterFileControl_t;
		hiRegisterData : in CPUData_t;
		hiRegisterControl: out RegisterControl_t;
		loRegisterData : in CPUData_t;
		loRegisterControl: out RegisterControl_t;
		ipCoreWrapperNumber1 : out CPUData_t;
		ipCoreWrapperNumber1Signed : out EnablingControl_t;
		ipCoreWrapperNumber2 : out CPUData_t;
		ipCoreWrapperNumber2Signed : out EnablingControl_t;
		ipCoreWrapperResultReady : in ReadyStatus_t;
		ipCoreWrapperOutput : in CPUDoubleWordData_t;
		ready : out ReadyStatus_t
	);
	type InstructionExecutationState_t is (
		STATE_IDLE,
		STATE_BUSY_MOVE,
		STATE_BUSY_MUL,
		STATE_BUSY_MUL_MOVE
	);
end entity;

architecture Behavioral of HighLatencyMathInstructionDecode is
	signal rs : std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal rt : std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal rd : std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal opcode : std_logic_vector (MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0);
	signal funct : std_logic_vector (MIPS_CPU_INSTRUCTION_FUNCT_WIDTH - 1 downto 0);
	signal shamt : std_logic_vector (MIPS_CPU_INSTRUCTION_SHAMT_WIDTH - 1 downto 0);
	signal state : InstructionExecutationState_t;
	signal ipCoreMulWaitCycleRemain : std_logic_vector(2 downto 0);
begin
	process(clock, reset)
	begin
		if reset = FUNC_ENABLED then
			state <= STATE_IDLE;
		elsif rising_edge(clock) then
			if state = STATE_IDLE then
				if instructionExecutionEnabled = FUNC_ENABLED then
					rs <= instruction(MIPS_CPU_INSTRUCTION_RS_HI downto MIPS_CPU_INSTRUCTION_RS_LO);
					rt <= instruction(MIPS_CPU_INSTRUCTION_RT_HI downto MIPS_CPU_INSTRUCTION_RT_LO);
					rd <= instruction(MIPS_CPU_INSTRUCTION_RD_HI downto MIPS_CPU_INSTRUCTION_RD_LO);
					opcode <= instruction(MIPS_CPU_INSTRUCTION_OPCODE_HI downto MIPS_CPU_INSTRUCTION_OPCODE_LO);
					funct <= instruction(MIPS_CPU_INSTRUCTION_FUNCT_HI downto MIPS_CPU_INSTRUCTION_FUNCT_LO);
					shamt <= instruction(MIPS_CPU_INSTRUCTION_SHAMT_HI downto MIPS_CPU_INSTRUCTION_SHAMT_LO);
					case funct is
						when MIPS_CPU_INSTRUCTION_FUNCT_MFHI |
						MIPS_CPU_INSTRUCTION_FUNCT_MFLO |
						MIPS_CPU_INSTRUCTION_FUNCT_MTHI |
						MIPS_CPU_INSTRUCTION_FUNCT_MTLO =>
							state <= STATE_BUSY_MOVE;
						when MIPS_CPU_INSTRUCTION_FUNCT_MULT |
						MIPS_CPU_INSTRUCTION_FUNCT_MULTU =>
							state <= STATE_BUSY_MUL;
							ipCoreMulWaitCycleRemain <= "011";
						when others =>
							state <= STATE_IDLE;
					end case;
				end if;
			elsif state = STATE_BUSY_MOVE then
				state <= STATE_IDLE;
			elsif state = STATE_BUSY_MUL then
				if ipCoreMulWaitCycleRemain /= "000" then
					ipCoreMulWaitCycleRemain <= ipCoreMulWaitCycleRemain - 1;
					state <= STATE_BUSY_MUL;
				else
					state <= STATE_BUSY_MUL_MOVE;
				end if;
			elsif state = STATE_BUSY_MUL_MOVE then
				state <= STATE_IDLE;
			end if;
		end if;
	end process;
	
	process(state, rs, rt, rd, opcode, funct, shamt)
	begin
		if state = STATE_BUSY_MOVE then
			case funct is
				when MIPS_CPU_INSTRUCTION_FUNCT_MFHI =>
					hiRegisterControl.operation <= REGISTER_OPERATION_READ;
					loRegisterControl.operation <= REGISTER_OPERATION_READ;
					registerFileControl.address <= rd;
					registerFileControl.data <= hiRegisterData;
				when MIPS_CPU_INSTRUCTION_FUNCT_MFLO =>
					hiRegisterControl.operation <= REGISTER_OPERATION_READ;
					loRegisterControl.operation <= REGISTER_OPERATION_READ;
					registerFileControl.address <= rd;
					registerFileControl.data <= loRegisterData;
				when MIPS_CPU_INSTRUCTION_FUNCT_MTHI =>
					hiRegisterControl.operation <= REGISTER_OPERATION_WRITE;
					hiRegisterControl.data <=
						registerFileData(to_integer(unsigned(rs)));
					loRegisterControl.operation <= REGISTER_OPERATION_READ;
					registerFileControl.address <= (others => '0');
				when MIPS_CPU_INSTRUCTION_FUNCT_MTLO =>
					loRegisterControl.operation <= REGISTER_OPERATION_WRITE;
					loRegisterControl.data <=
						registerFileData(to_integer(unsigned(rs)));
					hiRegisterControl.operation <= REGISTER_OPERATION_READ;
					registerFileControl.address <= (others => '0');
				when others =>
					hiRegisterControl.operation <= REGISTER_OPERATION_READ;
					loRegisterControl.operation <= REGISTER_OPERATION_READ;
					registerFileControl.address <= "00000";
					registerFileControl.data <= (others => '0');
			end case;
		elsif state = STATE_BUSY_MUL then
			hiRegisterControl.operation <= REGISTER_OPERATION_READ;
			loRegisterControl.operation <= REGISTER_OPERATION_READ;
			registerFileControl.address <= "00000";
			registerFileControl.data <= (others => '0');
			case funct is
				when MIPS_CPU_INSTRUCTION_FUNCT_MULT =>
					ipCoreWrapperNumber1 <= 
						registerFileData(to_integer(unsigned(rs)));
					ipCoreWrapperNumber2 <= 
						registerFileData(to_integer(unsigned(rs)));
					ipCoreWrapperNumber1Signed <= FUNC_ENABLED;
					ipCoreWrapperNumber2Signed <= FUNC_ENABLED;
				when MIPS_CPU_INSTRUCTION_FUNCT_MULTU =>
					ipCoreWrapperNumber1 <= 
						registerFileData(to_integer(unsigned(rs)));
					ipCoreWrapperNumber2 <= 
						registerFileData(to_integer(unsigned(rs)));
					ipCoreWrapperNumber1Signed <= FUNC_DISABLED;
					ipCoreWrapperNumber2Signed <= FUNC_DISABLED;
				when others =>
			end case;
		elsif state = STATE_BUSY_MUL_MOVE then
			hiRegisterControl.operation <= REGISTER_OPERATION_WRITE;
			hiRegisterControl.data <= ipCoreWrapperOutput
				(MIPS_CPU_DATA_WIDTH * 2 - 1 downto MIPS_CPU_DATA_WIDTH);
			loRegisterControl.operation <= REGISTER_OPERATION_WRITE;
			loRegisterControl.data <= ipCoreWrapperOutput
				(MIPS_CPU_DATA_WIDTH - 1 downto 0);
			registerFileControl.address <= "00000";
		else
			hiRegisterControl.operation <= REGISTER_OPERATION_READ;
			loRegisterControl.operation <= REGISTER_OPERATION_READ;
			registerFileControl.address <= "00000";
			registerFileControl.data <= (others => '0');
		end if;
	end process;

	process(state)
	begin
		if state = STATE_IDLE then
			ready <= STATUS_READY;
		else
			ready <= STATUS_BUSY;
		end if;
	end process;
end architecture;

