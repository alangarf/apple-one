/* Converts vga_font.bin into vga_font.hex 
   
   Author: Niels A. Moseley
   
*/

#include<stdio.h>
#include<stdint.h>

const char hextbl[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

int main(int argc, char *argv[])
{
    printf("VGAROMGEN v1.0\n");
    
    FILE *fin = fopen("../../roms/vga_font.bin","rt");
    if (fin == NULL)
    {
        printf("Error: cannot open vga_font.bin!\n");        
        return 1;
    }
    
    FILE *fout = fopen("../../roms/vga_font.hex","wt");
    if (fout == NULL)
    {
        printf("Error: cannot open vga_font.hex for writing!\n");        
        fclose(fin);
        return 1;        
    }
    
    uint8_t count = 0;
    uint8_t nibble = 0;
    uint32_t bitcount = 0;
    while(!feof(fin))
    {
        char c = fgetc(fin);
        if ((c == '0') || (c == '1'))
        {
            nibble <<= 1;
            nibble = nibble | (c - '0');
            count++;
            if (count == 4)
            {
                fprintf(fout, "%c", hextbl[nibble]);
                count = 0;
                nibble = 0;
                if ((bitcount % 8) == 7)
                {
                    fprintf(fout, "\n");
                }
            }
            bitcount++;
        }
    }
    
    printf("Done: converted %d bits\n", bitcount);
    
    fclose(fout);
    fclose(fin);
    return 0;
}