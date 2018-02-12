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

    FILE *fout = fopen("../../roms/vga_font_bitreversed.hex","wt");
    if (fout == NULL)
    {
        printf("Error: cannot open vga_font_bitreversed.hex for writing!\n");
        fclose(fin);
        return 1;
    }

    uint8_t count = 0;
    uint8_t byte = 0;
    uint32_t bytecount = 0;
    while(!feof(fin))
    {
        char c = fgetc(fin);
        if ((c == '0') || (c == '1'))
        {
            byte >>= 1;
            if (c == '1')
                byte |= 0x80;

            count++;
            if (count == 8)
            {
                fprintf(fout, "%c", hextbl[byte >> 4]);
                fprintf(fout, "%c", hextbl[byte & 0x0F]);
                fprintf(fout, "\n");
                count = 0;
                byte = 0;
                bytecount++;
            }
        }
    }

    // append zeros to 1024 bytes to keep Xilinx ISE webpack
    // happy.. *sigh*
    while(bytecount < 1024)
    {
        fprintf(fout,"00\n");
        bytecount++;
    }
    
    printf("Done: converted %d bytes\n", bytecount);

    fclose(fout);
    fclose(fin);
    return 0;
}