library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity Processor is
	port (
		reset : in std_logic;
		clock : in std_logic;
		register_file_debug : out mips_register_file_port;
		pcValueDebug : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		debugCP0RegisterFileData : out CP0RegisterFileOutput_t;
		debugInstructionToPrimary : out Instruction_t;
		primaryRAMControl : out HardwareRAMControl_t;
		primaryRAMResult : in RAMData_t;
		secondaryRAMControl : out HardwareRAMControl_t;
		secondaryRAMResult : in RAMData_t
	);
end entity;

architecture Behavioral of Processor is
	signal register_file_input: std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal register_file_operation: std_logic_vector (MIPS_CPU_REGISTER_COUNT - 1 downto 0);
	signal register_file_output : mips_register_file_port;
	signal registerFileControl1 : RegisterFileControl_t;
	signal registerFileControl2 : RegisterFileControl_t;

	signal pipelinePhaseIDEXInterface : PipelinePhaseIDEXInterface_t;
	signal pipelinePhaseEXMAInterface : PipelinePhaseEXMAInterface_t;
	signal pipelinePhaseMAWBInterface : PipelinePhaseMAWBInterface_t;

	signal instructionToCP0 : Instruction_t;
	signal instructionToPrimary : Instruction_t;
	signal instructionExecutionEnabledCP0 : EnablingControl_t;
	signal instruction_done : std_logic;

	signal current_pipeline_phase : std_logic_vector(3 downto 0) := "0000";

	signal primaryRAMData : std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);

	signal ramControl1 : RAMControl_t;
	signal ramControl2 : RAMControl_t;
	signal ramControl3 : RAMControl_t;
	signal memoryAccessResult : RAMData_t;

	signal pcControl1 : RegisterControl_t;
	signal pcControl2 : RegisterControl_t;
	signal pcControl3 : RegisterControl_t;
	signal pcValue : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);

	component SpecialRegister is
		port (
			reset : in std_logic;
			clock : in std_logic;
			control1 : in RegisterControl_t;
			control2 : in RegisterControl_t;
			control3 : in RegisterControl_t;
			output : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0)
		);
	end component;

	component RegisterFile is
    Port (
		reset : in std_logic;
		clock : in std_logic;
		input : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		operation : in std_logic_vector (MIPS_CPU_REGISTER_COUNT - 1 downto 0);
		output : out mips_register_file_port
	);
	end component;

	component PipelinePhaseInstructionDecode is
	port (
		reset : in std_logic;
		clock : in std_logic;
		register_file : in mips_register_file_port;
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		phaseExCtrlOutput : out PipelinePhaseIDEXInterface_t;
		pcValue : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		pcControl : out RegisterControl_t
	);
	end component;

	component PipelinePhaseExecute is
	port (
		reset : in std_logic;
		clock : in std_logic;
		phaseIDInput : in PipelinePhaseIDEXInterface_t;
		pcValue : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		pcControl : out RegisterControl_t;
		phaseMACtrlOutput : out PipelinePhaseEXMAInterface_t
	);
	end component;

	component PipelinePhaseMemoryAccess is
	port (
		clock : in std_logic;
		reset : in std_logic;
		phaseEXInput : in PipelinePhaseEXMAInterface_t;
		phaseWBCtrlOutput : out PipelinePhaseMAWBInterface_t;
		ramReadControl : out RAMReadControl_t;
		ramReadResult : in std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0)
	);
	end component;

begin

	register_file : RegisterFile port map (
		reset => reset,
		clock => clock,
		input => register_file_input,
		operation => register_file_operation,
		output => register_file_output
	);

	pcRegister : SpecialRegister port map (
		reset => reset,
		clock => clock,
		control1 => pcControl1,
		control2 => pcControl2,
		control3 => pcControl3,
		output => pcValue
	);

	pipeline_phase_instruction_decode: PipelinePhaseInstructionDecode port map (
		reset => reset,
		clock => clock,
		register_file => register_file_output,
		instruction => instructionToPrimary,
		phaseExCtrlOutput => pipelinePhaseIDEXInterface,
		pcValue => pcValue,
		pcControl => pcControl1
	);

	pipeline_phase_execute: PipelinePhaseExecute
	port map (
		reset => reset,
		clock => clock,
		phaseIDInput => pipelinePhaseIDEXInterface,
		pcValue => pcValue,
		pcControl => pcControl3,
		phaseMACtrlOutput => pipelinePhaseEXMAInterface
	);

	pipelinePhaseMemoryAccess_e: PipelinePhaseMemoryAccess
	port map (
		reset => reset,
		clock => clock,
		phaseEXInput => pipelinePhaseEXMAInterface,
		phaseWBCtrlOutput => pipelinePhaseMAWBInterface,
		ramReadControl => ramReadControl1,
		ramReadResult => primaryRAMData
	);

	pipelinePhaseWirteBack_i: entity work.PipelinePhaseWriteBack
	port map (
		reset => reset,
		clock => clock,
		ramWriteControl => ramWriteControl,
		registerFileControl => registerFileControl1,
		phaseMAInput => pipelinePhaseMAWBInterface,
		instruction_done => instruction_done
	);
	
	registerFileWriter_i: entity work.RegisterFileWriter
	port map
	(
		control1 => registerFileControl1,
		control2 => (
			address => (others => '0'),
			data => (others => '0')
		),
		operation_output => register_file_operation,
		data_output => register_file_input
	);

	process(register_file_output, pcValue)
	begin
		register_file_debug <= register_file_output;
		pcValueDebug <= pcValue;
		debugInstructionToPrimary <= instructionToPrimary;
		ramReadControl2.address <= pcValue(PHYSICS_RAM_ADDRESS_WIDTH + 1 downto 2);
	end process;
	
	Coprocessor0_i : entity work.Coprocessor0_e
	port map
	(
		reset => reset,
		clock => clock,
		instruction => instructionToCP0,
		instructionExecutionEnabled => instructionExecutionEnabledCP0,
		primaryRegisterFileData => register_file_output,
		primaryRegisterFileControl => registerFileControl2,
		debugCP0RegisterFileData => debugCP0RegisterFileData
	);
	
	hardwareAddressMapper : entity work.HardwareAddressMapper
	port map
	(
		clock => clock,
		reset => reset,
		ramControl1 => ramControl1,
		ramControl2 => ramControl2,
		ramControl3 => ramControl3,
		result => memoryAccessResult,
		primaryRAMHardwareControl => primaryRAMControl,
		primaryRAMResult => primaryRAMResult,
		secondaryRAMHardwareControl => secondaryRAMControl,
		secondaryRAMResult => secondaryRAMResult
	);

	Processor_Process : process (clock, reset, phyDataBus)
		variable opcode : InstructionOpcode_t;
		variable instruction : Instruction_t;
	begin
		if reset = '0' then
			instructionToPrimary <= MIPS_CPU_INSTRUCTION_NOP;
			current_pipeline_phase <= "0100";
		elsif rising_edge(clock) then
			if current_pipeline_phase = "0000" then
				instruction := primaryRAMData;
				opcode :=
					instruction(MIPS_CPU_INSTRUCTION_OPCODE_HI downto MIPS_CPU_INSTRUCTION_OPCODE_LO);
				if opcode = MIPS_CPU_INSTRUCTION_OPCODE_CP0 then
					instructionToPrimary <= MIPS_CPU_INSTRUCTION_NOP;
					instructionToCP0 <= instruction;
					instructionExecutionEnabledCP0 <= FUNC_ENABLED;
				else
					instructionToPrimary <= instruction;
					instructionToCP0 <= MIPS_CPU_INSTRUCTION_NOP;
					instructionExecutionEnabledCP0 <= FUNC_DISABLED;
				end if;
				pcControl2.operation <= REGISTER_OPERATION_READ;
				current_pipeline_phase <= current_pipeline_phase + 1;
				ramReadControl2.enable <= FUNC_DISABLED;
			elsif current_pipeline_phase = "0100" then
				pcControl2.operation <= REGISTER_OPERATION_WRITE;
				pcControl2.data <= pcValue + 4;
				current_pipeline_phase <= "0000";
				ramReadControl2.enable <= FUNC_ENABLED;
			else
				pcControl2.operation <= REGISTER_OPERATION_READ;
				instructionToPrimary <= MIPS_CPU_INSTRUCTION_NOP;
				current_pipeline_phase <= current_pipeline_phase + 1;
				ramReadControl2.enable <= FUNC_DISABLED;
			end if;
		end if;
	end process;
end architecture;
