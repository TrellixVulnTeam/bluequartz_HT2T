/*
 * This program is copyright Alec Muffett 1993. The author disclaims all 
 * responsibility or liability with respect to it's usage or its effect 
 * upon hardware or computer systems, and maintains copyright as set out 
 * in the "LICENCE" document which accompanies distributions of Crack v4.0 
 * and upwards.
 */

#include "../lib/cracklib.h"

int
main ()
{
    int32 i;
    CRACKLIB_PWDICT *pwp;
    char buffer[STRINGSIZE];

    if (!(pwp = cracklib_pw_open (CRACKLIB_DICTPATH, "r")))
    {
	perror ("PWOpen");
	return (-1);
    }

    printf("enter dictionary word numbers, one per line...\n");

    while (fgets (buffer, STRINGSIZE, stdin))
    {
	char *c;

	sscanf (buffer, "%lu", &i);

	printf ("(word %ld) ", i);

	if (!(c = (char *) cracklib_get_pw (pwp, i)))
	{
	    c = "(null)";
	}

	printf ("'%s'\n", c);
    }

    return (0);
}
