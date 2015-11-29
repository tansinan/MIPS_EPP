#include "simulator.h"

int main(int argc, char* argv[])
{
	if(argc < 2)
	{
		cout << "No input file specified." << endl;
		return 0;
	}
	
	string inputFileName = argv[1];
	Simulator* simulator = new Simulator(inputFileName);
	
	while (true)
	{
		simulator->executeCommand();
	}
	
	delete simulator;
	return 0;
}
