procedure mot_init;

begin

    with mach_op_table[1] do begin
        mnemonic := 'A   ';
        len := 2;
        type_operand := d1;
        op_code := 160;
        ext_op_value := 0
    end;

    with mach_op_table[2] do begin
        mnemonic := 'AB  ';
        len := 1;
        type_operand := b;
        op_code := 16;
        ext_op_value := 0
    end;

    with mach_op_table[3] do begin
        mnemonic := 'ABS ';
        len := 1;
        type_operand := rr1;
        op_code := 164;
        ext_op_value := 0
    end;

    with mach_op_table[4] do begin
        mnemonic := 'ABX ';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 4
    end;

    with mach_op_table[5] do begin
        mnemonic := 'AIM ';
        len := 2;
        type_operand := im;
        op_code := 74;
        ext_op_value := 1
    end;

    with mach_op_table[6] do begin
        mnemonic := 'AISP';
        len := 1;
        type_operand := rr3;
        op_code := 162;
        ext_op_value := 0
    end;

    with mach_op_table[7] do begin
        mnemonic := 'AND ';
        len := 2;
        type_operand := d1;
        op_code := 226;
        ext_op_value := 0
    end;

    with mach_op_table[8] do begin
        mnemonic := 'ANDB';
        len := 1;
        type_operand := b;
        op_code := 52;
        ext_op_value := 0
    end;

    with mach_op_table[9] do begin
        mnemonic := 'ANDM';
        len := 2;
        type_operand := im;
        op_code := 74;
        ext_op_value := 7
    end;

    with mach_op_table[10] do begin
        mnemonic := 'ANDR';
        len := 1;
        type_operand := rr1;
        op_code := 227;
        ext_op_value := 0
    end;

    with mach_op_table[11] do begin
        mnemonic := 'ANDX';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 14
    end;

    with mach_op_table[12] do begin
        mnemonic := 'AR  ';
        len := 1;
        type_operand := rr1;
        op_code := 161;
        ext_op_value := 0
    end;

    with mach_op_table[13] do begin
        mnemonic := 'BEX ';
        len := 1;
        type_operand := s1;
        op_code := 119;
        ext_op_value := 0
    end;

    with mach_op_table[14] do begin
        mnemonic := 'BEZ ';
        len := 1;
        type_operand := icr;
        op_code := 117;
        ext_op_value := 0
    end;

    with mach_op_table[15] do begin
        mnemonic := 'BGE ';
        len := 1;
        type_operand := icr;
        op_code := 123;
        ext_op_value := 0
    end;

    with mach_op_table[16] do begin
        mnemonic := 'BGT ';
        len := 1;
        type_operand := icr;
        op_code := 121;
        ext_op_value := 0
    end;

    with mach_op_table[17] do begin
        mnemonic := 'BIF ';
        len := 1;
        type_operand := s2;
        op_code := 79;
        ext_op_value := 0
    end;

    with mach_op_table[18] do begin
        mnemonic := 'BLE ';
        len := 1;
        type_operand := icr;
        op_code := 120;
        ext_op_value := 0
    end;

    with mach_op_table[19] do begin
        mnemonic := 'BLT ';
        len := 1;
        type_operand := icr;
        op_code := 118;
        ext_op_value := 0
    end;

    with mach_op_table[20] do begin
        mnemonic := 'BNZ ';
        len := 1;
        type_operand := icr;
        op_code := 122;
        ext_op_value := 0
    end;

    with mach_op_table[21] do begin
        mnemonic := 'BPT ';
        len := 1;
        type_operand := s3;
        op_code := 255;
        ext_op_value := 15
    end;

    with mach_op_table[22] do begin
        mnemonic := 'BR  ';
        len := 1;
        type_operand := icr;
        op_code := 116;
        ext_op_value := 0
    end;

    with mach_op_table[23] do begin
        mnemonic := 'C   ';
        len := 2;
        type_operand := d1;
        op_code := 240;
        ext_op_value := 0
    end;

    with mach_op_table[24] do begin
        mnemonic := 'CB  ';
        len := 1;
        type_operand := b;
        op_code := 56;
        ext_op_value := 0
    end;

    with mach_op_table[25] do begin
        mnemonic := 'CBL ';
        len := 2;
        type_operand := d1;
        op_code := 244;
        ext_op_value := 0
    end;

    with mach_op_table[26] do begin
        mnemonic := 'CBX ';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 12
    end;

    with mach_op_table[27] do begin
        mnemonic := 'CIM ';
        len := 2;
        type_operand := im;
        op_code := 74;
        ext_op_value := 10
    end;

    with mach_op_table[28] do begin
        mnemonic := 'CISN';
        len := 1;
        type_operand := rr3;
        op_code := 243;
        ext_op_value := 0
    end;

    with mach_op_table[29] do begin
        mnemonic := 'CISP';
        len := 1;
        type_operand := rr3;
        op_code := 242;
        ext_op_value := 0
    end;

    with mach_op_table[30] do begin
        mnemonic := 'CR  ';
        len := 1;
        type_operand := rr1;
        op_code := 241;
        ext_op_value := 0
    end;

    with mach_op_table[31] do begin
        mnemonic := 'D   ';
        len := 2;
        type_operand := d1;
        op_code := 212;
        ext_op_value := 0
    end;

    with mach_op_table[32] do begin
        mnemonic := 'DA  ';
        len := 2;
        type_operand := d1;
        op_code := 166;
        ext_op_value := 0
    end;

    with mach_op_table[33] do begin
        mnemonic := 'DABS';
        len := 1;
        type_operand := rr1;
        op_code := 165;
        ext_op_value := 0
    end;

    with mach_op_table[34] do begin
        mnemonic := 'DAR ';
        len := 1;
        type_operand := rr1;
        op_code := 167;
        ext_op_value := 0
    end;

    with mach_op_table[35] do begin
        mnemonic := 'DB  ';
        len := 1;
        type_operand := b;
        op_code := 28;
        ext_op_value := 0
    end;

    with mach_op_table[36] do begin
        mnemonic := 'DBX ';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 7
    end;

    with mach_op_table[37] do begin
        mnemonic := 'DC  ';
        len := 2;
        type_operand := d1;
        op_code := 246;
        ext_op_value := 0
    end;

    with mach_op_table[38] do begin
        mnemonic := 'DCR ';
        len := 1;
        type_operand := rr1;
        op_code := 247;
        ext_op_value := 0
    end;

    with mach_op_table[39] do begin
        mnemonic := 'DD  ';
        len := 2;
        type_operand := d1;
        op_code := 214;
        ext_op_value := 0
    end;

    with mach_op_table[40] do begin
        mnemonic := 'DDR ';
        len := 1;
        type_operand := rr1;
        op_code := 215;
        ext_op_value := 0
    end;

    with mach_op_table[41] do begin
        mnemonic := 'DECM';
        len := 2;
        type_operand := d2;
        op_code := 179;
        ext_op_value := 0
    end;

    with mach_op_table[42] do begin
        mnemonic := 'DIM ';
        len := 2;
        type_operand := im;
        op_code := 74;
        ext_op_value := 5
    end;

    with mach_op_table[43] do begin
        mnemonic := 'DISN';
        len := 1;
        type_operand := rr3;
        op_code := 211;
        ext_op_value := 0
    end;

    with mach_op_table[44] do begin
        mnemonic := 'DISP';
        len := 1;
        type_operand := rr3;
        op_code := 210;
        ext_op_value := 0
    end;

    with mach_op_table[45] do begin
        mnemonic := 'DL  ';
        len := 2;
        type_operand := d1;
        op_code := 134;
        ext_op_value := 0
    end;

    with mach_op_table[46] do begin
        mnemonic := 'DLB ';
        len := 1;
        type_operand := b;
        op_code := 4;
        ext_op_value := 0
    end;

    with mach_op_table[47] do begin
        mnemonic := 'DLBX';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 1
    end;

    with mach_op_table[48] do begin
        mnemonic := 'DLI ';
        len := 2;
        type_operand := d1;
        op_code := 136;
        ext_op_value := 0
    end;

    with mach_op_table[49] do begin
        mnemonic := 'DLR ';
        len := 1;
        type_operand := rr1;
        op_code := 135;
        ext_op_value := 0
    end;

    with mach_op_table[50] do begin
        mnemonic := 'DM  ';
        len := 2;
        type_operand := d1;
        op_code := 198;
        ext_op_value := 0
    end;

    with mach_op_table[51] do begin
        mnemonic := 'DMR ';
        len := 1;
        type_operand := rr1;
        op_code := 199;
        ext_op_value := 0
    end;

    with mach_op_table[52] do begin
        mnemonic := 'DNEG';
        len := 1;
        type_operand := rr1;
        op_code := 181;
        ext_op_value := 0
    end;

    with mach_op_table[53] do begin
        mnemonic := 'DR  ';
        len := 1;
        type_operand := rr1;
        op_code := 213;
        ext_op_value := 0
    end;

    with mach_op_table[54] do begin
        mnemonic := 'DS  ';
        len := 2;
        type_operand := d1;
        op_code := 182;
        ext_op_value := 0
    end;

    with mach_op_table[55] do begin
        mnemonic := 'DSAR';
        len := 1;
        type_operand := rr1;
        op_code := 110;
        ext_op_value := 0
    end;

    with mach_op_table[56] do begin
        mnemonic := 'DSCR';
        len := 1;
        type_operand := rr1;
        op_code := 111;
        ext_op_value := 0
    end;

    with mach_op_table[57] do begin
        mnemonic := 'DSLC';
        len := 1;
        type_operand := rr2;
        op_code := 104;
        ext_op_value := 0
    end;

    with mach_op_table[58] do begin
        mnemonic := 'DSLL';
        len := 1;
        type_operand := rr2;
        op_code := 101;
        ext_op_value := 0
    end;

    with mach_op_table[59] do begin
        mnemonic := 'DSLR';
        len := 1;
        type_operand := rr1;
        op_code := 109;
        ext_op_value := 0
    end;

    with mach_op_table[60] do begin
        mnemonic := 'DSR ';
        len := 1;
        type_operand := rr1;
        op_code := 183;
        ext_op_value := 0
    end;

    with mach_op_table[61] do begin
        mnemonic := 'DSRA';
        len := 1;
        type_operand := rr3;
        op_code := 103;
        ext_op_value := 0
    end;

    with mach_op_table[62] do begin
        mnemonic := 'DSRL';
        len := 1;
        type_operand := rr2;
        op_code := 102;
        ext_op_value := 0
    end;

    with mach_op_table[63] do begin
        mnemonic := 'DST ';
        len := 2;
        type_operand := d1;
        op_code := 150;
        ext_op_value := 0
    end;

    with mach_op_table[64] do begin
        mnemonic := 'DSTB';
        len := 1;
        type_operand := b;
        op_code := 12;
        ext_op_value := 0
    end;

    with mach_op_table[65] do begin
        mnemonic := 'DSTI';
        len := 2;
        type_operand := d1;
        op_code := 152;
        ext_op_value := 0
    end;

    with mach_op_table[66] do begin
        mnemonic := 'DSTX';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 3
    end;

    with mach_op_table[67] do begin
        mnemonic := 'DV  ';
        len := 2;
        type_operand := d1;
        op_code := 208;
        ext_op_value := 0
    end;

    with mach_op_table[68] do begin
        mnemonic := 'DVIM';
        len := 2;
        type_operand := im;
        op_code := 74;
        ext_op_value := 6
    end;

    with mach_op_table[69] do begin
        mnemonic := 'DVR ';
        len := 1;
        type_operand := rr1;
        op_code := 209;
        ext_op_value := 0
    end;

    with mach_op_table[70] do begin
        mnemonic := 'EFA ';
        len := 2;
        type_operand := d1;
        op_code := 170;
        ext_op_value := 0
    end;

    with mach_op_table[71] do begin
        mnemonic := 'EFAR';
        len := 1;
        type_operand := rr1;
        op_code := 171;
        ext_op_value := 0
    end;

    with mach_op_table[72] do begin
        mnemonic := 'EFC ';
        len := 2;
        type_operand := d1;
        op_code := 250;
        ext_op_value := 0
    end;

    with mach_op_table[73] do begin
        mnemonic := 'EFCR';
        len := 1;
        type_operand := rr1;
        op_code := 251;
        ext_op_value := 0
    end;

    with mach_op_table[74] do begin
        mnemonic := 'EFD ';
        len := 2;
        type_operand := d1;
        op_code := 218;
        ext_op_value := 0
    end;

    with mach_op_table[75] do begin
        mnemonic := 'EFDR';
        len := 1;
        type_operand := rr1;
        op_code := 219;
        ext_op_value := 0
    end;

    with mach_op_table[76] do begin
        mnemonic := 'EFIX';
        len := 1;
        type_operand := rr1;
        op_code := 234;
        ext_op_value := 0
    end;

    with mach_op_table[77] do begin
        mnemonic := 'EFL ';
        len := 2;
        type_operand := d1;
        op_code := 138;
        ext_op_value := 0
    end;

    with mach_op_table[78] do begin
        mnemonic := 'EFLT';
        len := 1;
        type_operand := rr1;
        op_code := 235;
        ext_op_value := 0
    end;

    with mach_op_table[79] do begin
        mnemonic := 'EFM ';
        len := 2;
        type_operand := d1;
        op_code := 202;
        ext_op_value := 0
    end;

    with mach_op_table[80] do begin
        mnemonic := 'EFMR';
        len := 1;
        type_operand := rr1;
        op_code := 203;
        ext_op_value := 0
    end;

    with mach_op_table[81] do begin
        mnemonic := 'EFS ';
        len := 2;
        type_operand := d1;
        op_code := 186;
        ext_op_value := 0
    end;

    with mach_op_table[82] do begin
        mnemonic := 'EFSR';
        len := 1;
        type_operand := rr1;
        op_code := 187;
        ext_op_value := 0
    end;

    with mach_op_table[83] do begin
        mnemonic := 'EFST';
        len := 2;
        type_operand := d1;
        op_code := 154;
        ext_op_value := 0
    end;

    with mach_op_table[84] do begin
        mnemonic := 'FA  ';
        len := 2;
        type_operand := d1;
        op_code := 168;
        ext_op_value := 0
    end;

    with mach_op_table[85] do begin
        mnemonic := 'FAB ';
        len := 1;
        type_operand := b;
        op_code := 32;
        ext_op_value := 0
    end;

    with mach_op_table[86] do begin
        mnemonic := 'FABS';
        len := 1;
        type_operand := rr1;
        op_code := 172;
        ext_op_value := 0
    end;

    with mach_op_table[87] do begin
        mnemonic := 'FABX';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 8
    end;

    with mach_op_table[88] do begin
        mnemonic := 'FAR ';
        len := 1;
        type_operand := rr1;
        op_code := 169;
        ext_op_value := 0
    end;

    with mach_op_table[89] do begin
        mnemonic := 'FC  ';
        len := 2;
        type_operand := d1;
        op_code := 248;
        ext_op_value := 0
    end;

    with mach_op_table[90] do begin
        mnemonic := 'FCB ';
        len := 1;
        type_operand := b;
        op_code := 60;
        ext_op_value := 0
    end;

    with mach_op_table[91] do begin
        mnemonic := 'FCBX';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 13
    end;

    with mach_op_table[92] do begin
        mnemonic := 'FCR ';
        len := 1;
        type_operand := rr1;
        op_code := 249;
        ext_op_value := 0
    end;

    with mach_op_table[93] do begin
        mnemonic := 'FD  ';
        len := 2;
        type_operand := d1;
        op_code := 216;
        ext_op_value := 0
    end;

    with mach_op_table[94] do begin
        mnemonic := 'FDB ';
        len := 1;
        type_operand := b;
        op_code := 44;
        ext_op_value := 0
    end;

    with mach_op_table[95] do begin
        mnemonic := 'FDBX';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 11
    end;

    with mach_op_table[96] do begin
        mnemonic := 'FDR ';
        len := 1;
        type_operand := rr1;
        op_code := 217;
        ext_op_value := 0
    end;

    with mach_op_table[97] do begin
        mnemonic := 'FIX ';
        len := 1;
        type_operand := rr1;
        op_code := 232;
        ext_op_value := 0
    end;

    with mach_op_table[98] do begin
        mnemonic := 'FLT ';
        len := 1;
        type_operand := rr1;
        op_code := 233;
        ext_op_value := 0
    end;

    with mach_op_table[99] do begin
        mnemonic := 'FM  ';
        len := 2;
        type_operand := d1;
        op_code := 200;
        ext_op_value := 0
    end;

    with mach_op_table[100] do begin
        mnemonic := 'FMB ';
        len := 1;
        type_operand := b;
        op_code := 40;
        ext_op_value := 0
    end;

    with mach_op_table[101] do begin
        mnemonic := 'FMBX';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 10
    end;

    with mach_op_table[102] do begin
        mnemonic := 'FMR ';
        len := 1;
        type_operand := rr1;
        op_code := 201;
        ext_op_value := 0
    end;

    with mach_op_table[103] do begin
        mnemonic := 'FNEG';
        len := 1;
        type_operand := rr1;
        op_code := 188;
        ext_op_value := 0
    end;

    with mach_op_table[104] do begin
        mnemonic := 'FS  ';
        len := 2;
        type_operand := d1;
        op_code := 184;
        ext_op_value := 0
    end;

    with mach_op_table[105] do begin
        mnemonic := 'FSB ';
        len := 1;
        type_operand := b;
        op_code := 36;
        ext_op_value := 0
    end;

    with mach_op_table[106] do begin
        mnemonic := 'FSBX';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 9
    end;

    with mach_op_table[107] do begin
        mnemonic := 'FSR ';
        len := 1;
        type_operand := rr1;
        op_code := 185;
        ext_op_value := 0
    end;

    with mach_op_table[108] do begin
        mnemonic := 'INCM';
        len := 2;
        type_operand := d2;
        op_code := 163;
        ext_op_value := 0
    end;

    with mach_op_table[109] do begin
        mnemonic := 'JC  ';
        len := 2;
        type_operand := d1;
        op_code := 112;
        ext_op_value := 0
    end;

    with mach_op_table[110] do begin
        mnemonic := 'JCI ';
        len := 2;
        type_operand := d1;
        op_code := 113;
        ext_op_value := 0
    end;

    with mach_op_table[111] do begin
        mnemonic := 'JS  ';
        len := 2;
        type_operand := d1;
        op_code := 114;
        ext_op_value := 0
    end;

    with mach_op_table[112] do begin
        mnemonic := 'L   ';
        len := 2;
        type_operand := d1;
        op_code := 128;
        ext_op_value := 0
    end;

    with mach_op_table[113] do begin
        mnemonic := 'LB  ';
        len := 1;
        type_operand := b;
        op_code := 0;
        ext_op_value := 0
    end;

    with mach_op_table[114] do begin
        mnemonic := 'LBX ';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 0
    end;

    with mach_op_table[115] do begin
        mnemonic := 'LI  ';
        len := 2;
        type_operand := d1;
        op_code := 132;
        ext_op_value := 0
    end;

    with mach_op_table[116] do begin
        mnemonic := 'LIM ';
        len := 2;
        type_operand := d1;
        op_code := 133;
        ext_op_value := 0
    end;

    with mach_op_table[117] do begin
        mnemonic := 'LISN';
        len := 1;
        type_operand := rr3;
        op_code := 131;
        ext_op_value := 0
    end;

    with mach_op_table[118] do begin
        mnemonic := 'LISP';
        len := 1;
        type_operand := rr3;
        op_code := 130;
        ext_op_value := 0
    end;

    with mach_op_table[119] do begin
        mnemonic := 'LLB ';
        len := 2;
        type_operand := d1;
        op_code := 140;
        ext_op_value := 0
    end;

    with mach_op_table[120] do begin
        mnemonic := 'LLBI';
        len := 2;
        type_operand := d1;
        op_code := 142;
        ext_op_value := 0
    end;

    with mach_op_table[121] do begin
        mnemonic := 'LM  ';
        len := 2;
        type_operand := d1;
        op_code := 137;
        ext_op_value := 0
    end;

    with mach_op_table[122] do begin
        mnemonic := 'LR  ';
        len := 1;
        type_operand := rr1;
        op_code := 129;
        ext_op_value := 0
    end;

    with mach_op_table[123] do begin
        mnemonic := 'LST ';
        len := 2;
        type_operand := d3;
        op_code := 125;
        ext_op_value := 0
    end;

    with mach_op_table[124] do begin
        mnemonic := 'LSTI';
        len := 2;
        type_operand := d3;
        op_code := 124;
        ext_op_value := 0
    end;

    with mach_op_table[125] do begin
        mnemonic := 'LUB ';
        len := 2;
        type_operand := d1;
        op_code := 139;
        ext_op_value := 0
    end;

    with mach_op_table[126] do begin
        mnemonic := 'LUBI';
        len := 2;
        type_operand := d1;
        op_code := 141;
        ext_op_value := 0
    end;

    with mach_op_table[127] do begin
        mnemonic := 'M   ';
        len := 2;
        type_operand := d1;
        op_code := 196;
        ext_op_value := 0
    end;

    with mach_op_table[128] do begin
        mnemonic := 'MB  ';
        len := 1;
        type_operand := b;
        op_code := 24;
        ext_op_value := 0
    end;

    with mach_op_table[129] do begin
        mnemonic := 'MBX ';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 6
    end;

    with mach_op_table[130] do begin
        mnemonic := 'MIM ';
        len := 2;
        type_operand := im;
        op_code := 74;
        ext_op_value := 3
    end;

    with mach_op_table[131] do begin
        mnemonic := 'MISN';
        len := 1;
        type_operand := rr3;
        op_code := 195;
        ext_op_value := 0
    end;

    with mach_op_table[132] do begin
        mnemonic := 'MISP';
        len := 1;
        type_operand := rr3;
        op_code := 194;
        ext_op_value := 0
    end;

    with mach_op_table[133] do begin
        mnemonic := 'MOV ';
        len := 2;
        type_operand := rr1;
        op_code := 147;
        ext_op_value := 0
    end;

    with mach_op_table[134] do begin
        mnemonic := 'MR  ';
        len := 1;
        type_operand := rr1;
        op_code := 197;
        ext_op_value := 0
    end;

    with mach_op_table[135] do begin
        mnemonic := 'MS  ';
        len := 2;
        type_operand := d1;
        op_code := 192;
        ext_op_value := 0
    end;

    with mach_op_table[136] do begin
        mnemonic := 'MSIM';
        len := 2;
        type_operand := im;
        op_code := 74;
        ext_op_value := 4
    end;

    with mach_op_table[137] do begin
        mnemonic := 'MSR ';
        len := 1;
        type_operand := rr1;
        op_code := 193;
        ext_op_value := 0
    end;

    with mach_op_table[138] do begin
        mnemonic := 'N   ';
        len := 2;
        type_operand := d1;
        op_code := 230;
        ext_op_value := 0
    end;

    with mach_op_table[139] do begin
        mnemonic := 'NEG ';
        len := 1;
        type_operand := rr1;
        op_code := 180;
        ext_op_value := 0
    end;

    with mach_op_table[140] do begin
        mnemonic := 'NIM ';
        len := 2;
        type_operand := im;
        op_code := 74;
        ext_op_value := 11
    end;

    with mach_op_table[141] do begin
        mnemonic := 'NOP ';
        len := 1;
        type_operand := s3;
        op_code := 255;
        ext_op_value := 0
    end;

    with mach_op_table[142] do begin
        mnemonic := 'NR  ';
        len := 1;
        type_operand := rr1;
        op_code := 231;
        ext_op_value := 0
    end;

    with mach_op_table[143] do begin
        mnemonic := 'OR  ';
        len := 2;
        type_operand := d1;
        op_code := 224;
        ext_op_value := 0
    end;

    with mach_op_table[144] do begin
        mnemonic := 'ORB ';
        len := 1;
        type_operand := b;
        op_code := 48;
        ext_op_value := 0
    end;

    with mach_op_table[145] do begin
        mnemonic := 'ORBX';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 15
    end;

    with mach_op_table[146] do begin
        mnemonic := 'ORIM';
        len := 2;
        type_operand := im;
        op_code := 74;
        ext_op_value := 8
    end;

    with mach_op_table[147] do begin
        mnemonic := 'ORR ';
        len := 1;
        type_operand := rr1;
        op_code := 225;
        ext_op_value := 0
    end;

    with mach_op_table[148] do begin
        mnemonic := 'POPM';
        len := 1;
        type_operand := rr1;
        op_code := 143;
        ext_op_value := 0
    end;

    with mach_op_table[149] do begin
        mnemonic := 'PSHM';
        len := 1;
        type_operand := rr1;
        op_code := 159;
        ext_op_value := 0
    end;

    with mach_op_table[150] do begin
        mnemonic := 'RB  ';
        len := 2;
        type_operand := d1;
        op_code := 83;
        ext_op_value := 0
    end;

    with mach_op_table[151] do begin
        mnemonic := 'RBI ';
        len := 2;
        type_operand := d1;
        op_code := 85;
        ext_op_value := 0
    end;

    with mach_op_table[152] do begin
        mnemonic := 'RBR ';
        len := 1;
        type_operand := rr1;
        op_code := 84;
        ext_op_value := 0
    end;

    with mach_op_table[153] do begin
        mnemonic := 'RVBR';
        len := 1;
        type_operand := rr1;
        op_code := 92;
        ext_op_value := 0
    end;

    with mach_op_table[154] do begin
        mnemonic := 'S   ';
        len := 2;
        type_operand := d1;
        op_code := 176;
        ext_op_value := 0
    end;

    with mach_op_table[155] do begin
        mnemonic := 'SAR ';
        len := 1;
        type_operand := rr1;
        op_code := 107;
        ext_op_value := 0
    end;

    with mach_op_table[156] do begin
        mnemonic := 'SB  ';
        len := 2;
        type_operand := d1;
        op_code := 80;
        ext_op_value := 0
    end;

    with mach_op_table[157] do begin
        mnemonic := 'SBB ';
        len := 1;
        type_operand := b;
        op_code := 20;
        ext_op_value := 0
    end;

    with mach_op_table[158] do begin
        mnemonic := 'SBBX';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 5
    end;

    with mach_op_table[159] do begin
        mnemonic := 'SBI ';
        len := 2;
        type_operand := d1;
        op_code := 82;
        ext_op_value := 0
    end;

    with mach_op_table[160] do begin
        mnemonic := 'SBR ';
        len := 1;
        type_operand := rr1;
        op_code := 81;
        ext_op_value := 0
    end;

    with mach_op_table[161] do begin
        mnemonic := 'SCR ';
        len := 1;
        type_operand := rr1;
        op_code := 108;
        ext_op_value := 0
    end;

    with mach_op_table[162] do begin
        mnemonic := 'SIM ';
        len := 2;
        type_operand := im;
        op_code := 74;
        ext_op_value := 2
    end;

    with mach_op_table[163] do begin
        mnemonic := 'SISP';
        len := 1;
        type_operand := rr3;
        op_code := 178;
        ext_op_value := 0
    end;

    with mach_op_table[164] do begin
        mnemonic := 'SJS ';
        len := 2;
        type_operand := d1;
        op_code := 126;
        ext_op_value := 0
    end;

    with mach_op_table[165] do begin
        mnemonic := 'SLBI';
        len := 2;
        type_operand := d1;
        op_code := 158;
        ext_op_value := 0
    end;

    with mach_op_table[166] do begin
        mnemonic := 'SLC ';
        len := 1;
        type_operand := rr3;
        op_code := 99;
        ext_op_value := 0
    end;

    with mach_op_table[167] do begin
        mnemonic := 'SLL ';
        len := 1;
        type_operand := rr2;
        op_code := 96;
        ext_op_value := 0
    end;

    with mach_op_table[168] do begin
        mnemonic := 'SLR ';
        len := 1;
        type_operand := rr1;
        op_code := 106;
        ext_op_value := 0
    end;

    with mach_op_table[169] do begin
        mnemonic := 'SOJ ';
        len := 2;
        type_operand := d1;
        op_code := 115;
        ext_op_value := 0
    end;

    with mach_op_table[170] do begin
        mnemonic := 'SR  ';
        len := 1;
        type_operand := rr1;
        op_code := 177;
        ext_op_value := 0
    end;

    with mach_op_table[171] do begin
        mnemonic := 'SRA ';
        len := 1;
        type_operand := rr2;
        op_code := 98;
        ext_op_value := 0
    end;

    with mach_op_table[172] do begin
        mnemonic := 'SRL ';
        len := 1;
        type_operand := rr2;
        op_code := 97;
        ext_op_value := 0
    end;

    with mach_op_table[173] do begin
        mnemonic := 'SRM ';
        len := 1;
        type_operand := d1;
        op_code := 151;
        ext_op_value := 0
    end;

    with mach_op_table[174] do begin
        mnemonic := 'ST  ';
        len := 2;
        type_operand := d1;
        op_code := 144;
        ext_op_value := 0
    end;

    with mach_op_table[175] do begin
        mnemonic := 'STB ';
        len := 1;
        type_operand := b;
        op_code := 8;
        ext_op_value := 0
    end;

    with mach_op_table[176] do begin
        mnemonic := 'STBX';
        len := 1;
        type_operand := bx;
        op_code := 64;
        ext_op_value := 2
    end;

    with mach_op_table[177] do begin
        mnemonic := 'STC ';
        len := 2;
        type_operand := d1;
        op_code := 145;
        ext_op_value := 0
    end;

    with mach_op_table[178] do begin
        mnemonic := 'STCI';
        len := 2;
        type_operand := d1;
        op_code := 146;
        ext_op_value := 0
    end;

    with mach_op_table[179] do begin
        mnemonic := 'STI ';
        len := 2;
        type_operand := d1;
        op_code := 148;
        ext_op_value := 0
    end;

    with mach_op_table[180] do begin
        mnemonic := 'STLB';
        len := 2;
        type_operand := d1;
        op_code := 156;
        ext_op_value := 0
    end;

    with mach_op_table[181] do begin
        mnemonic := 'STM ';
        len := 2;
        type_operand := d1;
        op_code := 153;
        ext_op_value := 0
    end;

    with mach_op_table[182] do begin
        mnemonic := 'STUB';
        len := 2;
        type_operand := d1;
        op_code := 155;
        ext_op_value := 0
    end;

    with mach_op_table[183] do begin
        mnemonic := 'SUBI';
        len := 1;
        type_operand := d1;
        op_code := 157;
        ext_op_value := 0
    end;

    with mach_op_table[184] do begin
        mnemonic := 'SVBR';
        len := 1;
        type_operand := rr1;
        op_code := 90;
        ext_op_value := 0
    end;

    with mach_op_table[185] do begin
        mnemonic := 'TB  ';
        len := 2;
        type_operand := d1;
        op_code := 86;
        ext_op_value := 0
    end;

    with mach_op_table[186] do begin
        mnemonic := 'TBI ';
        len := 2;
        type_operand := d1;
        op_code := 88;
        ext_op_value := 0
    end;

    with mach_op_table[187] do begin
        mnemonic := 'TBR ';
        len := 1;
        type_operand := rr1;
        op_code := 87;
        ext_op_value := 0
    end;

    with mach_op_table[188] do begin
        mnemonic := 'TSB ';
        len := 2;
        type_operand := d1;
        op_code := 89;
        ext_op_value := 0
    end;

    with mach_op_table[189] do begin
        mnemonic := 'TVBR';
        len := 1;
        type_operand := rr1;
        op_code := 94;
        ext_op_value := 0
    end;

    with mach_op_table[190] do begin
        mnemonic := 'URS ';
        len := 1;
        type_operand := s4;
        op_code := 127;
        ext_op_value := 0
    end;

    with mach_op_table[191] do begin
        mnemonic := 'VIO ';
        len := 2;
        type_operand := d1;
        op_code := 73;
        ext_op_value := 0
    end;

    with mach_op_table[192] do begin
        mnemonic := 'XBR ';
        len := 1;
        type_operand := s4;    (* corrected for version 2.5 *)
        op_code := 236;
        ext_op_value := 0
    end;

    with mach_op_table[193] do begin
        mnemonic := 'XIO ';
        len := 2;
        type_operand := d1;
        op_code := 72;
        ext_op_value := 0
    end;

    with mach_op_table[194] do begin
        mnemonic := 'XOR ';
        len := 2;
        type_operand := d1;
        op_code := 228;
        ext_op_value := 0
    end;

    with mach_op_table[195] do begin
        mnemonic := 'XORM';
        len := 2;
        type_operand := im;
        op_code := 74;
        ext_op_value := 9
    end;

    with mach_op_table[196] do begin
        mnemonic := 'XORR';
        len := 1;
        type_operand := rr1;
        op_code := 229;
        ext_op_value := 0
    end;

    with mach_op_table[197] do begin
        mnemonic := 'XWR ';
        len := 1;
        type_operand := rr1;
        op_code := 237;
        ext_op_value := 0
    end;

end;

