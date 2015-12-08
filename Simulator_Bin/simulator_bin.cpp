#include "simulator_bin.h"

using namespace std;

MemoryModule::MemoryModule()
{
	for (int i = 0; i < ramSize; i++)
		ram[i] = 0;
	for (int i = 0; i < romSize; i++)
		rom[i] = 0;
}

void Simulator::printCache(char output, int cache[])
{
	if (output == 'C')
	{
		for (int i = 0; i < 8; i++)
		{
			for (int j = 0; j < 4; j++)
			{
				cout << "Cache[" << i*4+j << "] = " << cache[i*4+j] << ' ';
			}
			cout << endl;
		}
		for (int i = 0; i < 32; i++)
		{
			cout << "Cache(Bin)[" << i << "] = " << binaryConvert((unsigned)cache[i], 32, true) <<endl;
		}
	}
}

int MemoryModule::write(int address, char value)
{
	if (address >= 0x80000000)
	{
		cout << "Error: Cannot write into ROM, this command will not be executed.\n";
		cout << "Continue anyway?(y/n)\n";
		char c;
		cin >> c;
		if (c == 'y')
			return 0;
		else
			return 1;
	}
	else
	{
		if (address >= ramSize || address < 0)
		{
			cout << "Error: Address illegal, this command will not be executed.\n";
			cout << "Continue anyway?(y/n)\n";
			char c;
			cin >> c;
			if (c == 'y')
				return 0;
			else
				return 1;
		}
		ram[address] = value;
	}
	return 0;
}
	
int MemoryModule::read(int address, char* value)
{
	if (address >= 0x80000000)
	{
		address -= 0x80000000;
		if (address >= romSize)
		{
			cout << "Error: Address illegal, this command will not be executed.\n";
			cout << "Continue anyway?(y/n)\n";
			char c;
			cin >> c;
			if (c == 'y')
				return 0;
			else
				return 1;
		}
		*value = rom[address];
	}
	else
	{
		if (address >= ramSize || address < 0)
		{
			cout << "Error: Address illegal, this command will not be executed.\n";
			cout << "Continue anyway?(y/n)\n";
			char c;
			cin >> c;
			if (c == 'y')
				return 0;
			else
				return 1;
		}
		*value = ram[address];
	}
	return 0;
}

Simulator::Simulator(string InputFileName)
{
	inputFileStream.open(InputFileName.c_str(), ios::in);
	string outputFileName = InputFileName;
	outputFileName += "_Testbench_Body.txt";
	testbench.open(outputFileName.c_str(), ios::out);
	commandNum = 0;
	for (int i = 0; i < 32; i++)
		cache[i] = 0;
	memory = new MemoryModule();
	programCounter = 0;
	loadCommand(inputFileStream, 0);
}

Simulator::~Simulator()
{
	inputFileStream.close();
	testbench.close();
	delete memory;
}

void Simulator::loadCommand(ifstream &inputFileStream, int address)
{
	string command;
	int ramCounter = 0;
	do
	{
		inputFileStream >> command;
		if (command.length() != 32)
		{
			initStatus = 1;
			return;
		}
		if (ramCounter >= memory->ramSize - 4)
		{
			initStatus = 2;
			return;
		}
		for (int i = 0; i < 4; ++i)
		{
			memory->write(ramCounter,(char)decimalConvert(command.substr(i*8,8), true));
			ramCounter++;
		}
	} while (command != "");
}

int Simulator::executeCommand()
{
	string commandBin = "";
	for (int i = 0; i < 4; i++)
	{
		char temp;
		memory->read(programCounter + i, &temp);
		commandBin += binaryConvert((int)temp, 8, true);
	}
	
	string op,rs,rt,rd,shamt,func;
	op = commandBin.substr(0,6);
	rs = commandBin.substr(6,5);
	rt = commandBin.substr(11,5);
	rd = commandBin.substr(16,5);
	shamt = commandBin.substr(21,5);
	func = commandBin.substr(26,6);

	if (func == "100000" && op == "000000" && shamt == "00000")
	{
		//add
		cache[decimalConvert(rd, true)] = cache[decimalConvert(rs, true)] + cache[decimalConvert(rt, true)];
		programCounter += 4;
	}
	else if (func == "100001" && op == "000000" && shamt == "00000")
	{
		//addu
		cache[decimalConvert(rd, true)] = (unsigned int)((unsigned int)cache[decimalConvert(rs, true)] + (unsigned int)cache[decimalConvert(rt, true)]);
		programCounter += 4;
	}
	else if (func == "100010" && op == "000000" && shamt == "00000")
	{
		//sub
		cache[decimalConvert(rd, true)] = cache[decimalConvert(rs, true)] - cache[decimalConvert(rt, true)];
		programCounter += 4;
	}
	else if (func == "100011" && op == "000000" && shamt == "00000")
	{
		//subu
		cache[decimalConvert(rd, true)] = (unsigned int)((unsigned int)cache[decimalConvert(rs, true)] - (unsigned int)cache[decimalConvert(rt, true)]);
		programCounter += 4;
	}
	else if (func == "100100" && op == "000000" && shamt == "00000")
	{
		//and
		cache[decimalConvert(rd, true)] = cache[decimalConvert(rs, true)] - cache[decimalConvert(rt, true)];
		programCounter += 4;
	}
	else if (func == "100101" && op == "000000" && shamt == "00000")
	{
		//or
		cache[decimalConvert(rd, true)] = cache[decimalConvert(rs, true)] | cache[decimalConvert(rt, true)];
		programCounter += 4;
	}
	else if (func == "100110" && op == "000000" && shamt == "00000")
	{
		//xor
		cache[decimalConvert(rd, true)] = cache[decimalConvert(rs, true)] ^ cache[decimalConvert(rt, true)];
		programCounter += 4;
	}
	else if (func == "100111" && op == "000000" && shamt == "00000")
	{
		//nor
		cache[decimalConvert(rd, true)] = ~(cache[decimalConvert(rs, true)] | cache[decimalConvert(rt, true)]);
		programCounter += 4;
	}
	else if (func == "101010" && op == "000000" && shamt == "00000")
	{
		//slt
		if (cache[decimalConvert(rs, true)] < cache[decimalConvert(rt, true)])
			cache[decimalConvert(rd, true)] = 1;
		else
			cache[decimalConvert(rd, true)] = 0;
		programCounter += 4;
	}
	else if (func == "101011" && op == "000000" && shamt == "00000")
	{
		//sltu
		if ((unsigned int)(cache[decimalConvert(rs, true)] < (unsigned int)cache[decimalConvert(rt, true)]))
			cache[decimalConvert(rd, true)] = 1;
		else
			cache[decimalConvert(rd, true)] = 0;
		programCounter += 4;
	}
	else if (func == "000000" && op == "000000" && rs == "00000")
	{
		//sll
		cache[decimalConvert(rd, true)] = cache[decimalConvert(rs, true)] << decimalConvert(shamt, true);
		programCounter += 4;
	}
	else if (func == "000010" && op == "000000" && rs == "00000")
	{
		//srl
		cache[decimalConvert(rd, true)] = (unsigned int)cache[decimalConvert(rs, true)] >> (unsigned int)decimalConvert(shamt, true);
		programCounter += 4;
	}
	else if (func == "000011" && op == "000000" && rs == "00000")
	{
		//sra
		cache[decimalConvert(rd, true)] = cache[decimalConvert(rs, true)] >> decimalConvert(shamt, true);
		programCounter += 4;
	}
	else if (func == "000100" && op == "000000" && shamt == "00000")
	{
		//sllv
		cache[decimalConvert(rd, true)] = cache[decimalConvert(rs, true)] << cache[decimalConvert(rs, true)];
		programCounter += 4;
	}
	else if (func == "000110" && op == "000000" && shamt == "00000")
	{
		//srlv
		cache[decimalConvert(rd, true)] = (unsigned int)cache[decimalConvert(rs, true)] >> (unsigned int)cache[decimalConvert(rs, true)];
		programCounter += 4;
	}
	else if (func == "000111" && op == "000000" && shamt == "00000")
	{
		//srav
		cache[decimalConvert(rd, true)] = cache[decimalConvert(rs, true)] >> cache[decimalConvert(rs, true)];
		programCounter += 4;
	}
	else if (func == "001000" && op == "000000" && rd == "00000" && rt == "00000" && shamt == "00000")
	{
		//jr
		programCounter = cache[decimalConvert(rs, true)];
	}
	else if (op == "001000")
	{
		//addi
		string imm = rd + shamt + func;
		cache[decimalConvert(rt, true)] = cache[decimalConvert(rs, true)] + decimalConvert(imm, false);
		programCounter += 4;
	}
	else if (op == "001001")
	{
		//addiu
		string imm = rd + shamt + func;
		cache[decimalConvert(rt, true)] = cache[decimalConvert(rs, true)] + (unsigned int)decimalConvert(imm, true);
		programCounter += 4;
	}
	else if (op == "001100")
	{
		//andi
		string imm = rd + shamt + func;
		cache[decimalConvert(rt, true)] = cache[decimalConvert(rs, true)] & (unsigned int)decimalConvert(imm, true);
		programCounter += 4;
	}
	else if (op == "001101")
	{
		//ori
		string imm = rd + shamt + func;
		cache[decimalConvert(rt, true)] = cache[decimalConvert(rs, true)] | (unsigned int)decimalConvert(imm, true);
		programCounter += 4;
	}
	else if (op == "001110")
	{
		//xori
		string imm = rd + shamt + func;
		cache[decimalConvert(rt, true)] = cache[decimalConvert(rs, true)] ^ (unsigned int)decimalConvert(imm, true);
		programCounter += 4;
	}
	else if (op == "001111" && rs == "00000")
	{
		//lui
		string imm = rd + shamt + func;
		cache[decimalConvert(rt, true)] = decimalConvert(imm, false) * 65536;
		programCounter += 4;
	}
	else if (op == "100011")
	{
		//lw
		string imm = rd + shamt + func;
		int address = cache[decimalConvert(rs, true)] + decimalConvert(imm, false);
		char word[4];
		for (unsigned int i = 0; i < 4; i++)
			memory->read(address + i, &word[i]);
		cache[decimalConvert(rt, true)] = *((int*)word);
		programCounter += 4;
	}
	else if (op == "101011")
	{
		//sw
		string imm = rd + shamt + func;
		int address = cache[decimalConvert(rs, true)] + decimalConvert(imm, false);
		char* word = (char*)&cache[decimalConvert(rt, true)];
		for (unsigned int i = 0; i < 4; i++)
			memory->write(address + i, word[i]);
		programCounter += 4;
	}
	else if (op == "000100")
	{
		//beq
		string imm = rd + shamt + func;
		if (cache[decimalConvert(rs, true)] == cache[decimalConvert(rt, true)])
			programCounter += (decimalConvert(imm, false) << 2);
		programCounter += 4;
	}
	else if (op == "000101")
	{
		//bne
		string imm = rd + shamt + func;
		if (cache[decimalConvert(rs, true)] != cache[decimalConvert(rt, true)])
			programCounter += (decimalConvert(imm, false) << 2);
		programCounter += 4;
	}
	else if (op == "001010")
	{
		//slti
		string imm = rd + shamt + func;
		if (cache[decimalConvert(rs, true)] < decimalConvert(imm, false))
			cache[decimalConvert(rt, true)] = 1;
		else
			cache[decimalConvert(rt, true)] = 0;
		programCounter += 4;
	}
	else if (op == "001011")
	{
		//sltiu
		string imm = rd + shamt + func;
		if (cache[decimalConvert(rs, true)] < (unsigned int)decimalConvert(imm, false))
			cache[decimalConvert(rt, true)] = 1;
		else
			cache[decimalConvert(rt, true)] = 0;
		programCounter += 4;
	}
	else if (op == "000010")
	{
		//j
		
	}
	else if (op == "000011")
	{
		//jal
	}
	
	cache[0] = 0;
	printTestbench(testbench, commandBin);
}

int Simulator::decimalConvert(string origin, bool trueForm)
{
	int ret = 0;
	if (!trueForm && origin[0] == '1')
	{
		for (int i = 0; i < origin.length(); i++)
			if (origin[i] == '0')
				origin[i] = '1';
			else origin[i] = '0';
		for (int i = origin.length() - 1; i >= 0; i--)
			if (origin[i] == '0')
			{
				origin[i] = '1';
				break;
			}
			else
				origin[i] = '0';
	}
		
	for (int i = 0; i < origin.length(); i++)
	{
		ret = ret * 2;
		if (origin[i] == '1')
			ret += 1;
	}
	
	if (trueForm)
		return ret;
	else
		return -ret;
}

string Simulator::binaryConvert(int origin, int width, bool trueForm)
{
	int o = origin;
	if (origin < 0)
		o = -o;
	string ret = "";
	while (o > 0)
	{
		if (o % 2 == 1)
			ret = "1" + ret;
		else
			ret = "0" + ret;
		o = o / 2;
	}
	if (ret == "")
		ret = "0";
	if (ret.length() > width)
		ret = ret.substr(ret.length() - width);
	else if (ret.length() < width)
	{
		while (ret.length() < width)
			ret = "0" + ret;
	}
	
	if (origin < 0 && !trueForm)
	{
		for (int i = 0; i < ret.length(); i++)
			if (ret[i] == '0')
				ret[i] = '1';
			else ret[i] = '0';
		for (int i = ret.length()-1; i >= 0; i--)
			if (ret[i] == '0')
			{
				ret[i] = '1';
				break;
			}
			else
				ret[i] = '0';
	}
		
	return ret;
}

void Simulator::printTestbench(ofstream &testbench, string commandBin)
{
	testbench << "current_test_success <= true;\nreset <= '1';\ninstruction <= \""
	<< commandBin << "\";\nwait for clock_period * 5;\n\n";
	for (int i = 0; i < 32; i++)
	{
		testbench << "if current_test_success = true then\n"
		<< "  if register_file_debug(" << i << ") /= \"" << binaryConvert((unsigned)cache[i], 32, true) << "\" then\n"
		<< "    report \"Test case " << commandNum << " failed\";\n"
		<< "  current_test_success <= false;\n"
		<< "  end if;\nend if;\n\n";
	}
	testbench << "if current_test_success = true then\n"
	<< "  report \"Test case " << commandNum << " succeeded\";\n"
	<< "end if;\n";
	testbench << '\n';
}

//Wasted code, do not use.
/*
void Simulator::printCommandBin(ofstream &testbench, string command, int p1, int p2, int p3)
{
	string commandBin = "";
	if (command == "add")
	{
		commandBin += "000000";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p3, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += "00000100000";
	}
	else if (command == "addu")
	{
		commandBin += "000000";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p3, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += "00000100001";
	}
	else if (command == "sub")
	{
		commandBin += "000000";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p3, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += "00000100010";
	}
	else if (command == "subu")
	{
		commandBin += "000000";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p3, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += "00000100011";
	}
	else if (command == "and")
	{
		commandBin += "000000";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p3, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += "00000100100";
	}
	else if (command == "or")
	{
		commandBin += "000000";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p3, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += "00000100101";
	}
	else if (command == "xor")
	{
		commandBin += "000000";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p3, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += "00000100110";
	}
	else if (command == "nor")
	{
		commandBin += "000000";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p3, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += "00000100111";
	}
	else if (command == "slt")
	{
		commandBin += "000000";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p3, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += "00000101010";
	}
	else if (command == "sltu")
	{
		commandBin += "000000";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p3, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += "00000101011";
	}
	else if (command == "sll")
	{
		commandBin += "00000000000";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p3, 5, true);
		commandBin += "000000";
	}
	else if (command == "srl")
	{
		commandBin += "00000000000";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p3, 5, true);
		commandBin += "0000010";
	}
	else if (command == "sra")
	{
		commandBin += "00000000000";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p3, 5, true);
		commandBin += "0000011";
	}
	else if (command == "sllv")
	{
		commandBin += "000000";
		commandBin += binaryConvert(p3, 5, true);
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += "00000000100";
	}
	else if (command == "srlv")
	{
		commandBin += "000000";
		commandBin += binaryConvert(p3, 5, true);
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += "00000000110";
	}
	else if (command == "srav")
	{
		commandBin += "000000";
		commandBin += binaryConvert(p3, 5, true);
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += "00000000111";
	}
	else if (command == "jr")
	{
		commandBin += "000000";
		commandBin += binaryConvert(p1, 5, true);
		commandBin += "000000000000000001000";
	}
	else if (command == "addi")
	{
		commandBin += "001000";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p3, 16, false);
	}
	else if (command == "addiu")
	{
		commandBin += "001001";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p3, 16, true);
	}
	else if (command == "andi")
	{
		commandBin += "001100";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p3, 16, true);
	}
	else if (command == "ori")
	{
		commandBin += "001101";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p3, 16, true);
	}
	else if (command == "xori")
	{
		commandBin += "001110";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p3, 16, true);
	}
	else if (command == "lui")
	{
		commandBin += "00111100000";
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p2, 16, true);
	}
	else if (command == "lw")
	{
		commandBin += "100011";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p3, 16, false);
	}
	else if (command == "sw")
	{
		commandBin += "101011";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p3, 16, false);
	}
	else if (command == "beq")
	{
		commandBin += "000100";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p3, 16, false);
	}
	else if (command == "bne")
	{
		commandBin += "000101";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p3, 16, false);
	}
	else if (command == "slti")
	{
		commandBin += "001010";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p3, 16, false);
	}
	else if (command == "sltiu")
	{
		commandBin += "001011";
		commandBin += binaryConvert(p2, 5, true);
		commandBin += binaryConvert(p1, 5, true);
		commandBin += binaryConvert(p3, 16, true);
	}
	else if (command == "j")
	{
		commandBin += "000010";
		commandBin += binaryConvert(p1/4, 26, true);
	}
	else if (command == "jal")
	{
		commandBin += "000011";
		commandBin += binaryConvert(p1/4, 26, true);
	}
	printTestbench(testbench, commandBin);
}
*/

//Wasted code, do not use.
/*
int Simulator::executeCommand()
{
	stringstream commandStream;
	commandStream.str("");
	commandStream << decodeCommand(programCounter);
	commandNum ++;
	string command = "";
	commandStream >> command;
	if (command == "E" || command == "")
		return 1;
	else if (command == "add")
	{
		string s1,s2,s3;
		int c1,c2,c3;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		s3 = s3.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		c3 = atoi(s3.c_str());
		cache[c1] = cache[c2] + cache[c3];
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, c3);
		programCounter += 4;
	}
	else if (command == "addu")
	{
		string s1,s2,s3;
		int c1,c2,c3;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		s3 = s3.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		c3 = atoi(s3.c_str());
		cache[c1] = (unsigned int)(((unsigned int)cache[c2]) + ((unsigned int)cache[c3]));
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, c3);
		programCounter += 4;
	}
	else if (command == "sub")
	{
		string s1,s2,s3;
		int c1,c2,c3;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		s3 = s3.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		c3 = atoi(s3.c_str());
		cache[c1] = cache[c2] - cache[c3];
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, c3);
		programCounter += 4;
	}
	else if (command == "subu")
	{
		string s1,s2,s3;
		int c1,c2,c3;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		s3 = s3.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		c3 = atoi(s3.c_str());
		cache[c1] = (unsigned int)(((unsigned int)cache[c2]) - ((unsigned int)cache[c3]));
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, c3);
		programCounter += 4;
	}
	else if (command == "and")
	{
		string s1,s2,s3;
		int c1,c2,c3;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		s3 = s3.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		c3 = atoi(s3.c_str());
		cache[c1] = cache[c2] & cache[c3];
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, c3);
		programCounter += 4;
	}
	else if (command == "or")
	{
		string s1,s2,s3;
		int c1,c2,c3;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		s3 = s3.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		c3 = atoi(s3.c_str());
		cache[c1] = cache[c2] | cache[c3];
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, c3);
		programCounter += 4;
	}
	else if (command == "xor")
	{
		string s1,s2,s3;
		int c1,c2,c3;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		s3 = s3.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		c3 = atoi(s3.c_str());
		cache[c1] = cache[c2] ^ cache[c3];
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, c3);
		programCounter += 4;
	}
	else if (command == "nor")
	{
		string s1,s2,s3;
		int c1,c2,c3;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		s3 = s3.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		c3 = atoi(s3.c_str());
		cache[c1] = ~(cache[c2] | cache[c3]);
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, c3);
		programCounter += 4;
	}
	else if (command == "slt")
	{
		string s1,s2,s3;
		int c1,c2,c3;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		s3 = s3.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		c3 = atoi(s3.c_str());
		if (cache[c2] < cache[c3])
			cache[c1] = 1;
		else
			cache[c1] = 0;
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, c3);
		programCounter += 4;
	}
	else if (command == "sltu")
	{
		string s1,s2,s3;
		int c1,c2,c3;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		s3 = s3.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		c3 = atoi(s3.c_str());
		if ((unsigned int)cache[c2] < (unsigned int)cache[c3])
			cache[c1] = 1;
		else
			cache[c1] = 0;
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, c3);
		programCounter += 4;
	}
	else if (command == "sll")
	{
		string s1,s2,s3;
		int c1,c2,shamt;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		shamt = atoi(s3.c_str());
		cache[c1] = cache[c2] << shamt;
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, shamt);
		programCounter += 4;
	}
	else if (command == "srl")
	{
		string s1,s2,s3;
		int c1,c2,shamt;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		shamt = atoi(s3.c_str());
		cache[c1] = (unsigned int)cache[c2] >> (unsigned int)shamt;
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, shamt);
		programCounter += 4;
	}
	else if (command == "sra")
	{
		string s1,s2,s3;
		int c1,c2,shamt;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		shamt = atoi(s3.c_str());
		cache[c1] = cache[c2] >> shamt;
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, shamt);
		programCounter += 4;
	}
	else if (command == "sllv")
	{
		string s1,s2,s3;
		int c1,c2,c3;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		s3 = s3.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		c3 = atoi(s3.c_str());
		cache[c1] = cache[c2] << cache[c3];
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, c3);
		programCounter += 4;
	}
	else if (command == "srlv")
	{
		string s1,s2,s3;
		int c1,c2,c3;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		s3 = s3.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		c3 = atoi(s3.c_str());
		cache[c1] = (unsigned int)cache[c2] >> (unsigned int)cache[c3];
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, c3);
		programCounter += 4;
	}
	else if (command == "srav")
	{
		string s1,s2,s3;
		int c1,c2,c3;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		s3 = s3.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		c3 = atoi(s3.c_str());
		cache[c1] = cache[c2] >> cache[c3];
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, c3);
		programCounter += 4;
	}
	else if (command == "jr")
	{
		
	}
	else if (command == "addi")
	{
		string s1,s2,s3;
		int c1,c2,imm;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		imm = atoi(s3.c_str());
		cache[c1] = cache[c2] + imm;
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, imm);
		programCounter += 4;
	}
	else if (command == "addiu")
	{
		string s1,s2,s3;
		int c1,c2,imm;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		imm = atoi(s3.c_str());
		cache[c1] = (unsigned int)(((unsigned int)cache[c2]) + ((unsigned int)imm));
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, imm);
		programCounter += 4;
	}
	else if (command == "andi")
	{
		string s1,s2,s3;
		int c1,c2,imm;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		imm = atoi(s3.c_str());
		cache[c1] = (unsigned int)(((unsigned int)cache[c2]) & ((unsigned int)imm));
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, imm);
		programCounter += 4;
	}
	else if (command == "ori")
	{
		string s1,s2,s3;
		int c1,c2,imm;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		imm = atoi(s3.c_str());
		cache[c1] = (unsigned int)(((unsigned int)cache[c2]) | ((unsigned int)imm));
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, imm);
		programCounter += 4;
	}
	else if (command == "xori")
	{
		string s1,s2,s3;
		int c1,c2,imm;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		imm = atoi(s3.c_str());
		cache[c1] = (unsigned int)(((unsigned int)cache[c2]) ^ ((unsigned int)imm));
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, imm);
		programCounter += 4;
	}
	else if (command == "lui")
	{
		string s1,s2;
		int c1,imm;
		commandStream >> s1 >> s2;
		s1 = s1.substr(1);
		c1 = atoi(s1.c_str());
		imm = atoi(s2.c_str());
		cache[c1] = ((unsigned int)imm) * 65536;
		cache[0] = 0;
		printCommandBin(testbench, command, c1, imm);
		programCounter += 4;
	}
	else if (command == "lw")
	{
		string s1,s2,s3;
		int c1,c2,imm;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		imm = atoi(s3.c_str());
		unsigned int address = (unsigned int)(cache[c2] + imm);
		char word[4];
		for (unsigned int i = 0; i < 4; i++)
			memory->read(address + i, &word[i]);
		cache[c1] = *((int*)word);
		printCommandBin(testbench, command, c1, c2, imm);
		programCounter += 4;
	}
	else if (command == "sw")
	{
		string s1,s2,s3;
		int c1,c2,imm;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		imm = atoi(s3.c_str());
		unsigned int address = (unsigned int)(cache[c2] + imm);
		char* word = (char*)&cache[c1];
		for (unsigned int i = 0; i < 4; i++)
			memory->write(address + i, word[i]);
		printCommandBin(testbench, command, c1, c2, imm);
		programCounter += 4;
	}
	else if (command == "beq")
	{
		
	}
	else if (command == "bne")
	{
		
	}
	else if (command == "slti")
	{
		string s1,s2,s3;
		int c1,c2,imm;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		imm = atoi(s3.c_str());
		if (cache[c2] < imm)
			cache[c1] = 1;
		else
			cache[c1] = 0;
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, imm);
		programCounter += 4;
	}
	else if (command == "sltiu")
	{
		string s1,s2,s3;
		int c1,c2,imm;
		commandStream >> s1 >> s2 >> s3;
		s1 = s1.substr(1);
		s2 = s2.substr(1);
		c1 = atoi(s1.c_str());
		c2 = atoi(s2.c_str());
		imm = atoi(s3.c_str());
		if (cache[c2] < (unsigned int)imm)
			cache[c1] = 1;
		else
			cache[c1] = 0;
		cache[0] = 0;
		printCommandBin(testbench, command, c1, c2, imm);
		programCounter += 4;
	}
	else if (command == "j")
	{
		
	}
	else if (command == "jal")
	{
		
	}
	else ;
	
	cache[0] = 0;
	printCache('C', cache);
	return 0;
}
*/
