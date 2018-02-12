/* Converts vga_font.bin into vga_font.hex

   Author: Niels A. Moseley

*/

#include<stdio.h>
#include<stdint.h>

const char hextbl[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

uint8_t isWhiteSpace(char c)
{
    if ((c==' ') || (c=='\t'))
    {
        return 1;
    }
    return 0;
}

uint8_t isHex(char c)
{
    if ((c>='0') && (c<='9'))
    {
        return 1;
    }
    if ((c>='a') && (c<='f'))
    {
        return 1;
    }
    if ((c>='A') && (c<='F'))
    {
        return 1;
    }
    return 0;
}

uint8_t convert(const char *infilename, const char *outfilename)
{
    FILE *fin = fopen(infilename,"rt");
    if (fin == NULL)
    {
        printf("Error: cannot open %s!\n", infilename);
        return 1;
    }

    FILE *fout = fopen(outfilename,"wt");
    if (fout == NULL)
    {
        printf("Error: cannot open %s for writing!\n", outfilename);
        fclose(fin);
        return 1;
    }
    
    uint8_t inWhiteSpace = 1;
    while(!feof(fin))
    {
        char c = fgetc(fin);
        if (inWhiteSpace == 0)
        {
            if (isWhiteSpace(c))
            {
                inWhiteSpace = 1;
                fprintf(fout, "\n");
            }
            else
            {
                if ((isHex(c)) || (c==10) || (c==13))
                {
                    fprintf(fout,"%c", c);
                }
            }
        }
        else
        {
            if (!isWhiteSpace(c))
            {
                fprintf(fout,"%c", c);
                inWhiteSpace = 0;
            }
            else
            {
                // still in white space .. do nothing
            }
        }
    }
    fclose(fin);
    fclose(fout);
}

int main(int argc, char *argv[])
{
    printf("ISE_HEXER v1.0\n");

    convert("..\\..\\roms\\basic.hex", "..\\..\\roms\\basic_ise.hex");
    convert("..\\..\\roms\\ram.hex", "..\\..\\roms\\ram_ise.hex");
    convert("..\\..\\roms\\wozmon.hex", "..\\..\\roms\\wozmon_ise.hex");

    printf("Done\n");
    return 0;
}