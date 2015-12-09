#include "simulator_bin.h"

int main(int argc, char* argv[])
{
	if(argc < 2)
	{
		cout << "No input file specified." << endl;
		return 0;
	}
	
	string inputFileName = argv[1];
	Simulator* simulator = new Simulator(inputFileName);
	
	/*cout << simulator->binaryConvert((unsigned int)((unsigned char)simulator->decimalConvert("10000011", true)), 8, true);
	
	
	
	
	system("pause");
	return 0;*/
	
	
	
	
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
		if (simulator->executeCommand() != 0)
			break;
	}
	delete simulator;
	
	system("pause");
	
	return 0;
}
