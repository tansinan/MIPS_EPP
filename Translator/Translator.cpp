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

void printCommandBin(ofstream &outputFileStream, string command, int p1, int p2 = 0, int p3 = 0)
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
	
	outputFileStream << commandBin << endl;
}


int main(int argc, char* argv[])
{
	int commandNum = 0;
	ifstream inputFileStream;
	ofstream outputFileStream;
	if(argc < 2)
	{
		cout << "No input file specified.";
		return 0;
	}
	inputFileStream.open(argv[1], ios::in);
	string outputFileName = argv[1];
	outputFileName += "_Machine_Code.txt";
	outputFileStream.open(outputFileName.c_str(), ios::out);
	string command;
	
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
			printCommandBin(outputFileStream, command, c1, c2, c3);
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
			printCommandBin(outputFileStream, command, c1, c2, c3);
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
			printCommandBin(outputFileStream, command, c1, c2, c3);
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
			printCommandBin(outputFileStream, command, c1, c2, c3);
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
			printCommandBin(outputFileStream, command, c1, c2, c3);
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
			printCommandBin(outputFileStream, command, c1, c2, c3);
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
			printCommandBin(outputFileStream, command, c1, c2, c3);
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
			printCommandBin(outputFileStream, command, c1, c2, c3);
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
			printCommandBin(outputFileStream, command, c1, c2, c3);
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
			printCommandBin(outputFileStream, command, c1, c2, c3);
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
			printCommandBin(outputFileStream, command, c1, c2, shamt);
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
			printCommandBin(outputFileStream, command, c1, c2, shamt);
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
			printCommandBin(outputFileStream, command, c1, c2, shamt);
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
			printCommandBin(outputFileStream, command, c1, c2, c3);
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
			printCommandBin(outputFileStream, command, c1, c2, c3);
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
			printCommandBin(outputFileStream, command, c1, c2, c3);
		}
		else if (command == "jr")
		{
			string s1;
			int c1;
			inputFileStream >> s1;
			s1 = s1.substr(1);
			c1 = atoi(s1.c_str());
			printCommandBin(outputFileStream, command, c1);
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
			printCommandBin(outputFileStream, command, c1, c2, imm);
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
			printCommandBin(outputFileStream, command, c1, c2, imm);
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
			printCommandBin(outputFileStream, command, c1, c2, imm);
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
			printCommandBin(outputFileStream, command, c1, c2, imm);
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
			printCommandBin(outputFileStream, command, c1, c2, imm);
		}
		else if (command == "lui")
		{
			string s1,s2;
			int c1,imm;
			inputFileStream >> s1 >> s2;
			s1 = s1.substr(1);
			c1 = atoi(s1.c_str());
			imm = atoi(s2.c_str());
			printCommandBin(outputFileStream, command, c1, imm);
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
			printCommandBin(outputFileStream, command, c1, c2, imm);
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
			printCommandBin(outputFileStream, command, c1, c2, imm);
		}
		else if (command == "beq")
		{
			string s1,s2,s3;
			int c1,c2,imm;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			imm = atoi(s3.c_str());
			printCommandBin(outputFileStream, command, c1, c2, imm);
		}
		else if (command == "bne")
		{
			string s1,s2,s3;
			int c1,c2,imm;
			inputFileStream >> s1 >> s2 >> s3;
			s1 = s1.substr(1);
			s2 = s2.substr(1);
			c1 = atoi(s1.c_str());
			c2 = atoi(s2.c_str());
			imm = atoi(s3.c_str());
			printCommandBin(outputFileStream, command, c1, c2, imm);
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
			printCommandBin(outputFileStream, command, c1, c2, imm);
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
			printCommandBin(outputFileStream, command, c1, c2, imm);
		}
		else if (command == "j")
		{
			string s1;
			int imm;
			inputFileStream >> s1;
			imm = atoi(s1.c_str());
			printCommandBin(outputFileStream, command, imm);
		}
		else if (command == "jal")
		{
			string s1;
			int imm;
			inputFileStream >> s1;
			imm = atoi(s1.c_str());
			printCommandBin(outputFileStream, command, imm);
		}
		else ;
	}
	inputFileStream.close();
	outputFileStream.close();
	return 0;
}
