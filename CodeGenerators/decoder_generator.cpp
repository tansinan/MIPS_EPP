#include <iostream>
using namespace std;
int main(int argc, char* argv[])
{
	cout << "with <val1> select <val2> <=" << endl;
	for (int i = 0; i<32; i++)
	{
		cout << "\"";
		for (int j = 0; j<32; j++)
		{
			if (j == 31 - i) cout << '1';
			else cout << '0';
		}
		cout << "\" when \"";
		int temp = i;
		for (int j = 16; j > 0; j /= 2)
		{
			if (temp >= j)
			{
				temp -= j;
				cout << '1';
			}
			else cout << '0';
		}
		cout << "\"," << endl;
	}
	cout << "others => 'X' when others;" << endl;
	return 0;
}