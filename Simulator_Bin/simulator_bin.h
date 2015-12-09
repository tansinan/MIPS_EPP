#include <iostream>
#include <fstream>
#include <string>
#include <stdlib.h>
#include <sstream>

using namespace std;

class MemoryModule
{
public:
	static const int ramSize = 8388608, romSize = 16777216;
	MemoryModule();
	int write(int address, unsigned char value);
	int read(int address, unsigned char* value);
	
protected:
	unsigned char ram[ramSize], rom[romSize];
};

class Simulator
{
protected:
	int cache[32];
	int commandNum;
	ifstream inputFileStream;
	ofstream testbench, cacheOutput;
	MemoryModule* memory;
	int programCounter;

public:
	int initStatus;
	Simulator(string InputFileName);
	~Simulator();
	void loadCommand(ifstream &inputFileStream, int address);
	int decimalConvert(string origin, bool trueForm);
	string binaryConvert(int origin, int width, bool trueForm);
	void printCache(string commandBin);
	void printTestbench(string commandBin);
	//void printCommandBin(ofstream &testbench, string command, int p1, int p2 = 0, int p3 = 0);
	int executeCommand();
};
