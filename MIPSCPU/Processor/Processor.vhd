library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;

entity Processor is
	port (
		reset : in std_logic;
		clock : in std_logic;
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		phyRAMEnable : out std_logic;
		phyRAMWriteEnable : out std_logic;
		phyRAMReadEnable : out std_logic;
		phyAddressBus : out std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
		phyDataBus : inout std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);
		register_file_debug : out mips_register_file_port
	);
end entity;

architecture Behavioral of Processor is
	signal register_file_input: std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal register_file_operation: std_logic_vector (MIPS_CPU_REGISTER_COUNT - 1 downto 0);
	signal register_file_output : mips_register_file_port;

	signal phase_idex_operand1 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal phase_idex_operand2 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal phase_idex_operation : std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0);
	signal phase_idex_register_destination : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal phase_idex_useRAMAddr : std_logic;
	signal phase_idex_writeBackToRAM : std_logic;
	signal phase_idex_extraData : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);

	signal pipelinePhaseEXMAInterface : PipelinePhaseEXMAInterface_t;
	signal pipelinePhaseMAWBInterface : PipelinePhaseMAWBInterface_t;

	signal actual_instruction : std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
	signal instruction_done : std_logic;

	signal current_pipeline_phase : std_logic_vector(3 downto 0) := "0000";

	signal primaryRAMData : std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);

	signal ramReadControl1 : RAMReadControl_t;
	signal ramWriteControl : RAMWriteControl_t;

	signal pcControl1 : RegisterControl_t;
	signal pcControl2 : RegisterControl_t;
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

	component RAMController_c is
	port (
		clock : in std_logic;
		reset : in std_logic;
		readControl1 : in RAMReadControl_t;
		readControl2 : in RAMReadControl_t;
		writeControl : in RAMWriteControl_t;
		result : out std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);
		phyRAMEnable : out std_logic;
		phyRAMWriteEnable : out std_logic;
		phyRAMReadEnable : out std_logic;
		phyAddressBus : out std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
		phyDataBus : inout std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0)
	);
	end component;

	component PipelinePhaseInstructionDecode is
	port (
		reset : in std_logic;
		clock : in std_logic;
		register_file : in mips_register_file_port;
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		alu_operand1_output : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		alu_operand2_output : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		alu_operation_output : out std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0);
		register_destination_output :
			out std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
		use_ram_addr : out std_logic;
		writeBackToRamAddr : out std_logic;
		extraData : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0)
	);
	end component;

	component PipelinePhaseExecute is
	port (
		reset : in std_logic;
		clock : in std_logic;
		operand1 : in std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		operand2 : in std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		operation : in std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0);
		register_destination : in std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
		phaseMACtrlOutput : out PipelinePhaseEXMAInterface_t;
		writeBackToRAM : in std_logic;
		extraData : in std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		useRAMAddr : in std_logic
	);
	end component;

	component PipelinePhaseMemoryAccess is
	port (
		clock : in std_logic;
		reset : in std_logic;
		phaseEXInput : in PipelinePhaseEXMAInterface_t;
		phaseWBCtrlOutput : out PipelinePhaseMAWBInterface_t;
		ramReadControl : out RAMReadControl_t;
		ramWriteControl : out RAMWriteControl_t;
		ramReadResult : in std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0)
	);
	end component;

	component PipelinePhaseWriteBack is
    port (
		reset : in std_logic;
		clock : in std_logic;
		register_file_input : out std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		register_file_operation : out std_logic_vector (MIPS_CPU_REGISTER_COUNT - 1 downto 0);
		phaseMAInput : in PipelinePhaseMAWBInterface_t;
		instruction_done : out std_logic
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
		control3 => (
			operation => REGISTER_OPERATION_READ,
			data => (others => '0')
		),
		output => pcValue
	);

	pipeline_phase_instruction_decode: PipelinePhaseInstructionDecode port map (
		reset => reset,
		clock => clock,
		register_file => register_file_output,
		instruction => actual_instruction,
		alu_operand1_output => phase_idex_operand1,
		alu_operand2_output => phase_idex_operand2,
		alu_operation_output => phase_idex_operation,
		register_destination_output => phase_idex_register_destination,
		use_ram_addr => phase_idex_useRamAddr,
		writeBackToRAMAddr => phase_idex_writeBackToRAM,
		extraData => phase_idex_extraData
	);

	pipeline_phase_execute: PipelinePhaseExecute
	port map (
		reset => reset,
		clock => clock,
		operand1 => phase_idex_operand1,
		operand2 => phase_idex_operand2,
		operation => phase_idex_operation,
		register_destination => phase_idex_register_destination,
		useRamAddr => phase_idex_useRamAddr,
		phaseMACtrlOutput => pipelinePhaseEXMAInterface,
		writeBackToRAM => phase_idex_writeBackToRAM,
		extraData => phase_idex_extraData
	);

	pipelinePhaseMemoryAccess_e: PipelinePhaseMemoryAccess
	port map (
		reset => reset,
		clock => clock,
		phaseEXInput => pipelinePhaseEXMAInterface,
		phaseWBCtrlOutput => pipelinePhaseMAWBInterface,
		ramReadControl => ramReadControl1,
		ramWriteControl => ramWriteControl,
		ramReadResult => primaryRAMData
	);

	pipeline_phase_write_back: PipelinePhaseWriteBack
	port map (
		reset => reset,
		clock => clock,
		register_file_input => register_file_input,
		register_file_operation => register_file_operation,
		phaseMAInput => pipelinePhaseMAWBInterface,
		instruction_done => instruction_done
	);

	primaryRamController_e: RAMController_c
	port map (
		clock => clock,
		reset => reset,
		readControl1 => ramReadControl1,
		readControl2 => (
			enable => FUNC_DISABLED,
			address => (others => '0')
		),
		writeControl => ramWriteControl,
		result => primaryRAMData,
		phyRAMEnable => phyRAMEnable,
		phyRAMWriteEnable => phyRAMWriteEnable,
		phyRAMReadEnable => phyRAMReadEnable,
		phyAddressBus => phyAddressBus,
		phyDataBus => phyDataBus
	);

	register_file_debug <= register_file_output;

	Processor_Process : process (clock, reset)
	begin
		if reset = '0' then
			actual_instruction <= MIPS_CPU_INSTRUCTION_NOP;
		elsif rising_edge(clock) then
			if current_pipeline_phase = "0000" then
				actual_instruction <= instruction;
				current_pipeline_phase <= current_pipeline_phase + 1;
			elsif current_pipeline_phase = "0100" then
				current_pipeline_phase <= "0000";
			else
				actual_instruction <= MIPS_CPU_INSTRUCTION_NOP;
				current_pipeline_phase <= current_pipeline_phase + 1;
			end if;
		end if;
	end process;
end architecture;
