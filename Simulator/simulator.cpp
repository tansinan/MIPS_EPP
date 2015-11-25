#include <iostream>
#include <fstream>
#include <string>
#include <stdlib.h>

using namespace std;

string binaryConvert(int origin, int width, bool trueForm)
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

void printCache(char output, int cache[])
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

void printTestbench(ofstream &testbench, string commandBin, int commandNum, int cache[])
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

void printCommandBin(ofstream &testbench, int commandNum, string command, int cache[], int p1, int p2 = 0, int p3 = 0)
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
	printTestbench(testbench, commandBin, commandNum, cache);
}

class memoryModule
{
protected:
	static const int ramSize = 8388608, romSize = 16777216;
	char ram[ramSize], rom[romSize];

public:
	int write(unsigned int address, char value)
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
	
	int read(unsigned int address, char* value)
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
};

int main(int argc, char* argv[])
{
	memoryModule* memory = new memoryModule();	
	int commandNum = 0;
	ifstream inputFileStream;
	if(argc < 2)
	{
		cout << "No input file specified." << endl;
		return 0;
	}
	ofstream testbench;
	string outputFileName = argv[1];
	outputFileName += "_Testbench_Body.txt";
	testbench.open(outputFileName.c_str(), ios::out);
	inputFileStream.open(argv[1], ios::in);
	string command;
	int cache[32];
	for (int i = 0; i < 32; i++)
	{
		cache[i] = 0;
	}
	
	while (true)
	{
		commandNum ++;
		command = "";
		inputFileStream >> command;
		if (command == "E" || command == "")
			break;
		else if (command == "add")
		{
			string s1,s2,s3;
			int c1,c2,c3;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			s3 = s3.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			c3 = atoi(s3.c_str());
			cache[c1] = cache[c2] + cache[c3];
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, c3);
		}
		else if (command == "addu")
		{
			string s1,s2,s3;
			int c1,c2,c3;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			s3 = s3.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			c3 = atoi(s3.c_str());
			cache[c1] = (unsigned int)(((unsigned int)cache[c2]) + ((unsigned int)cache[c3]));
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, c3);
		}
		else if (command == "sub")
		{
			string s1,s2,s3;
			int c1,c2,c3;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			s3 = s3.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			c3 = atoi(s3.c_str());
			cache[c1] = cache[c2] - cache[c3];
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, c3);
		}
		else if (command == "subu")
		{
			string s1,s2,s3;
			int c1,c2,c3;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			s3 = s3.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			c3 = atoi(s3.c_str());
			cache[c1] = (unsigned int)(((unsigned int)cache[c2]) - ((unsigned int)cache[c3]));
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, c3);
		}
		else if (command == "and")
		{
			string s1,s2,s3;
			int c1,c2,c3;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			s3 = s3.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			c3 = atoi(s3.c_str());
			cache[c1] = cache[c2] & cache[c3];
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, c3);
		}
		else if (command == "or")
		{
			string s1,s2,s3;
			int c1,c2,c3;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			s3 = s3.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			c3 = atoi(s3.c_str());
			cache[c1] = cache[c2] | cache[c3];
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, c3);
		}
		else if (command == "xor")
		{
			string s1,s2,s3;
			int c1,c2,c3;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			s3 = s3.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			c3 = atoi(s3.c_str());
			cache[c1] = cache[c2] ^ cache[c3];
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, c3);
		}
		else if (command == "nor")
		{
			string s1,s2,s3;
			int c1,c2,c3;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			s3 = s3.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			c3 = atoi(s3.c_str());
			cache[c1] = ~(cache[c2] | cache[c3]);
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, c3);
		}
		else if (command == "slt")
		{
			string s1,s2,s3;
			int c1,c2,c3;
			inputFileStream >> s1 >> s2 >> s3;
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
			printCommandBin(testbench, commandNum, command, cache, c1, c2, c3);
		}
		else if (command == "sltu")
		{
			string s1,s2,s3;
			int c1,c2,c3;
			inputFileStream >> s1 >> s2 >> s3;
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
			printCommandBin(testbench, commandNum, command, cache, c1, c2, c3);
		}
		else if (command == "sll")
		{
			string s1,s2,s3;
			int c1,c2,shamt;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			shamt = atoi(s3.c_str());
			cache[c1] = cache[c2] << shamt;
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, shamt);
		}
		else if (command == "srl")
		{
			string s1,s2,s3;
			int c1,c2,shamt;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			shamt = atoi(s3.c_str());
			cache[c1] = (unsigned int)cache[c2] >> (unsigned int)shamt;
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, shamt);
		}
		else if (command == "sra")
		{
			string s1,s2,s3;
			int c1,c2,shamt;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			shamt = atoi(s3.c_str());
			cache[c1] = cache[c2] >> shamt;
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, shamt);
		}
		else if (command == "sllv")
		{
			string s1,s2,s3;
			int c1,c2,c3;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			s3 = s3.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			c3 = atoi(s3.c_str());
			cache[c1] = cache[c2] << cache[c3];
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, c3);
		}
		else if (command == "srlv")
		{
			string s1,s2,s3;
			int c1,c2,c3;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			s3 = s3.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			c3 = atoi(s3.c_str());
			cache[c1] = (unsigned int)cache[c2] >> (unsigned int)cache[c3];
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, c3);
		}
		else if (command == "srav")
		{
			string s1,s2,s3;
			int c1,c2,c3;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			s3 = s3.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			c3 = atoi(s3.c_str());
			cache[c1] = cache[c2] >> cache[c3];
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, c3);
		}
		else if (command == "jr")
		{
			
		}
		else if (command == "addi")
		{
			string s1,s2,s3;
			int c1,c2,imm;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			imm = atoi(s3.c_str());
			cache[c1] = cache[c2] + imm;
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, imm);
		}
		else if (command == "addiu")
		{
			string s1,s2,s3;
			int c1,c2,imm;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			imm = atoi(s3.c_str());
			cache[c1] = (unsigned int)(((unsigned int)cache[c2]) + ((unsigned int)imm));
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, imm);
		}
		else if (command == "andi")
		{
			string s1,s2,s3;
			int c1,c2,imm;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			imm = atoi(s3.c_str());
			cache[c1] = (unsigned int)(((unsigned int)cache[c2]) & ((unsigned int)imm));
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, imm);
		}
		else if (command == "ori")
		{
			string s1,s2,s3;
			int c1,c2,imm;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			imm = atoi(s3.c_str());
			cache[c1] = (unsigned int)(((unsigned int)cache[c2]) | ((unsigned int)imm));
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, imm);
		}
		else if (command == "xori")
		{
			string s1,s2,s3;
			int c1,c2,imm;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			imm = atoi(s3.c_str());
			cache[c1] = (unsigned int)(((unsigned int)cache[c2]) ^ ((unsigned int)imm));
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, c2, imm);
		}
		else if (command == "lui")
		{
			string s1,s2;
			int c1,imm;
			inputFileStream >> s1 >> s2;
			s1 = s1.substr(1);
			c1 = atoi(s1.c_str());
			imm = atoi(s2.c_str());
			cache[c1] = ((unsigned int)imm) * 65536;
			cache[0] = 0;
			printCommandBin(testbench, commandNum, command, cache, c1, imm);
		}
		else if (command == "lw")
		{
			string s1,s2,s3;
			int c1,c2,imm;
			inputFileStream >> s1 >> s2 >> s3;
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
			printCommandBin(testbench, commandNum, command, cache, c1, c2, imm);
		}
		else if (command == "sw")
		{
			string s1,s2,s3;
			int c1,c2,imm;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			imm = atoi(s3.c_str());
			unsigned int address = (unsigned int)(cache[c2] + imm);
			char* word = (char*)&cache[c1];
			for (unsigned int i = 0; i < 4; i++)
				memory->write(address + i, word[i]);
			printCommandBin(testbench, commandNum, command, cache, c1, c2, imm);
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
			inputFileStream >> s1 >> s2 >> s3;
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
			printCommandBin(testbench, commandNum, command, cache, c1, c2, imm);
		}
		else if (command == "sltiu")
		{
			string s1,s2,s3;
			int c1,c2,imm;
			inputFileStream >> s1 >> s2 >> s3;
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
			printCommandBin(testbench, commandNum, command, cache, c1, c2, imm);
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
	}
	inputFileStream.close();
	testbench.close();
	return 0;
}
