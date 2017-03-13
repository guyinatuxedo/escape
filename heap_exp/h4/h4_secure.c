#include <stdlib.h>
#include <stdio.h>

struct nova
{
	char pulsar[50];
	int  cluster;
	int *ion;
};

int main()
{
	int solar_wind;

	int ran;
	ran = fopen("/dev/urandom", "rb");
	char rbuf[50];
	fread(rbuf, sizeof(rbuf), 1, ran);
	srand(rbuf);

	struct nova *centari, *castor, *vega;
	
	centari = malloc(sizeof(struct nova));
	centari->ion = malloc(9);
	centari->cluster = 0;

	castor = malloc(sizeof(struct nova));
	castor->ion = malloc(9);
	castor->cluster = 0;
		

	vega = malloc(sizeof(struct nova));
	vega->ion = malloc(9);
	vega->cluster = 0;

	centari->cluster = rand() % 100;
	solar_wind = centari->cluster;
	free(centari->ion);
	memset(centari->ion, '0', sizeof(centari->ion));_
	memset(centari, '0', sizeof(struct nova));
	free(centari);
	free(centari->ion);
	centari = NULL;	

	fgets(castor->ion, sizeof(castor->ion), stdin);
	
	puts("Where do you want to point the James Webb Space Telescope?");
	if (*vega->ion == solar_wind)
	{
		puts("Wow while managine to not do your research, you discovered life on another planet. I am genuinely surprised. Level Cleared!");
	}
	else
	{
		printf("You see %p.\n", vega->ion);
	}
}
