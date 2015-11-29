#include <iostream>
#include <fstream>
#include <string>
#include <stdlib.h>

using namespace std;

class MemoryModule
{
protected:
	static const int ramSize = 8388608, romSize = 16777216;
	char ram[ramSize], rom[romSize];

public:
	MemoryModule();
	int write(unsigned int address, char value);
	int read(unsigned int address, char* value);
};

class Simulator
{
protected:
	int cache[32];
	int commandNum;
	ifstream inputFileStream;
	ofstream testbench;
	MemoryModule* memory;

public:
	Simulator(string InputFileName);
	~Simulator();
	string binaryConvert(int origin, int width, bool trueForm);
	void printCache(char output, int cache[]);
	void printTestbench(ofstream &testbench, string commandBin);
	void printCommandBin(ofstream &testbench, string command, int p1, int p2 = 0, int p3 = 0);
	void executeCommand();
};
