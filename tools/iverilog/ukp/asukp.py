#!/usr/bin/env python
"""
ukp compiler
"""

import re


def putline(pcnt, code):
    """
    output a line of verilog
    """
    return "\t\t\t10'h{:03x}: data = 4'h{:01x};\n".format(pcnt, code)


def main():
    """
    main
    """
    label_regex = re.compile(r'^\s*(\w+):')
    labels = {}
    pcnt = 0

    instructions = {
        'nop': 0,
        'ldi': 1,
        'start': 2,
        'out0': 4,
        'out1': 5,
        'out2': 6,
        'hiz': 7,
        'bz': 8,
        'bc': 9,
        'bnak': 10,
        'djnz': 11,
        'toggle': 12,
        'in': 13,
        'wait': 14
    }

    with open('ukp.s', 'r') as src:
        for line in src:
            lbl = label_regex.match(line)
            if lbl:
                # found label
                label = lbl.group(1)

                if label.startswith(';'):
                    # commented label
                    continue

                if label in labels:
                    print("{} already defined!".format(label))
                    exit(1)

                pcnt = pcnt + 3 & ~3
                labels[label] = pcnt

                print('pc={:03x}\t{}'.format(pcnt, label))
            else:
                tokens = line.split()
                if not tokens or tokens[0].startswith(';'):
                    # skip empty lines
                    continue

                if tokens[0] not in instructions:
                    print('syntax error: {}'.format(tokens[0]))
                    exit(1)

                inst = instructions[tokens[0].lower()]
                pcnt += 3 if (inst == 1 or inst >= 8 and inst < 12) else 1

        src.seek(0)

        pcnt = 0
        with open('ukprom2.v', 'w') as dst:
            dst.write("module ukprom(clk, adr, data);\n")
            dst.write("\tinput clk;\n")
            dst.write("\tinput [9:0] adr;\n")
            dst.write("\toutput [3:0] data;\n")
            dst.write("\treg [3:0] data;\n")
            dst.write("\talways @(posedge clk) begin\n")
            dst.write("\t\tcase (adr)\n")

            for line in src:
                lbl = label_regex.match(line)
                if lbl:
                    while pcnt & 3:
                        dst.write(putline(pcnt, 0))
                        pcnt += 1

                else:
                    tokens = line.split()
                    if not tokens or tokens[0].startswith(';'):
                        # skip empty lines
                        continue

                    code = instructions[tokens[0].lower()]

                    lbl = [k for k, v in labels.items() if v == pcnt]
                    if lbl:
                        dst.write("// >>>> {}\n".format(lbl.pop()))

                    if code >= 8 and code < 12:
                        dst.write("// {}\n".format(tokens[1]))

                    dst.write(putline(pcnt, code))
                    pcnt += 1

                    if code == 1:
                        dst.write(putline(pcnt, int(tokens[1]) & 15))
                        pcnt += 1
                        dst.write(putline(pcnt, int(tokens[1]) >> 4))
                        pcnt += 1

                    elif code >= 8 and code < 12:
                        if tokens[1] not in labels:
                            print("{} not defined".format(tokens[1]))
                            exit(1)

                        addr = labels[tokens[1]] >> 2
                        dst.write(putline(pcnt, addr & 15))
                        pcnt += 1
                        dst.write(putline(pcnt, addr >> 4))
                        pcnt += 1

            dst.write("\t\t\tdefault: data = 4'hX;\n")
            dst.write("\t\tendcase\n\tend\nendmodule\n")


if __name__ == "__main__":
    main()
