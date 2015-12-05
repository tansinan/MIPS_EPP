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
	switch (simulator->initStatus)
	{
		case 0:
		break;
		case 1:
			cout << "Command length error.";
			return 1;
		break;
		case 2:
			cout << "Too much commands.";
			return 2;
		break;
	}
	
	while (true)
	{
		if (simulator->executeCommand())
			break;
	}
	
	delete simulator;
	return 0;
}
