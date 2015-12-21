#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
int main()
{
		int fd = open("/tmp/MIPS_EPP/UART_Output.pipe", O_RDONLY);
for(;;)
{
		char c;
		int r = read(fd, &c, 1);
		if(r > 0)
			printf("%c",c);
	}
	close(fd);
	return 0;
}
