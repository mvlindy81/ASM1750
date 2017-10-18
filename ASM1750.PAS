
program assem_1750( input, output);

(**********************************************************************)
(*                                                                    *)
(*                                                                    *)
(*   MIL-STD-1750A Assembler for IBM PC                               *)
(*                                                                    *)
(*                                                                    *)
(*   Written by : Mark V. Lindberg                                    *)
(*   Date       : 05 November 1986                                    *)
(*   Version    : 2.7                                                 *)
(*                                                                    *)
(*   Version 2.7 Changes : Corrected a problem associated with        *)
(*               operand values for two word instructions. For a      *)
(*               second word of :FFFF to :8001 a value of + 1 was     *)
(*               added to the high byte.  The problem was fixed in    *)
(*               procedure put_D_obj which is in the pas2incl.pas     *)
(*               file.                                                *)
(*                                                                    *)
(*               Corrected a problem noticed in symol table dump,     *)
(*               that symbols with value < 0 did had a value of 0     *)
(*               output in symbol table. Fixed problem in main file's *)
(*               procedure called WriteHex.                           *)
(*                                                                    *)
(*               Corrected a problem with repeated Hex (H'nnnn')      *)
(*               constants. The second copy of the constant was being *)
(*               set to 0000. Fixed the problem in Pas2incl File's    *)
(*               procedure get_const                                  *)
(*                                                                    *)
(**********************************************************************)



(********** constant declarations *************************************)

const Mnem_Lgth = 4;                (*    len of mach operation mnems *)
      Number_of_ops = 197;          (* number of mach ops implemented *)
      MAXSTR = 80;                  (*                    card length *)
      MAXSYM = 100;                 (*          max number of symbols *)
      MAXLITS = 50;                 (*         max number of literals *)
      MAXLIST = 130;                (*         length of listing line *)
      HEADER_LEN = 60;              (*      length of variable header *)
      MAXLINES = 10240;             (* maximum number of source lines *)

      no_source = 1;                (* assembler error values *)
      invalid_op = 2;
      invalid_literal = 10;
      invalid_term = 11;
      invalid_expr = 12;
      lit_not_found = 13;
      sym_not_found = 14;
      invalid_sym = 15;
      invalid_delim = 16;
      illegal_expr = 17;
      invalid_immediate = 18;
      illegal_base = 19;

      blank = ' ';                                   (* single blank *)
      blank8 = '        ';          (* eight blanks for symbol names *)
      obj_head = '/C00';            (* leader for object strings     *)
      obj_tail = '/T00';            (* trailer for object files      *)
      version_label = 'MIL-STD-1750 Assembler Version 2.7';

(********** end of constant declarations *****************************)

(************* type declarations *************************************)

type
    strtype = array[1..MAXSTR] of char;          (* input card *)

    listing_type = array [1..MAXLIST] of char; (* listing line *)

    header_type = string[header_len]; (* header str *)

    DC_str = array[1..24] of char;       (* string for DC ops *)

    pseudo_op_type = array [1..6] of char;   (* pseudo op str *)

    char4 = array [1..4] of char;

    flag_type = 0..255;                                (* error flag *)

    labeltype    = array [1..8] of char;     (* eight letters *)

    string40 = string[40];
    string12 = string[12];
    str4     = array[1..4] of char;

    capletter = set of 'A'..'Z';                   (* cap letter set *)

    smallletters = set of 'a'..'z';             (* small letters set *)

    numbers = set of '0'..'9';                         (* number set *)

    reltype = (ABSOLUT,RELOCAT,EXTERN);       (* relocatability type *)

    Literal_Record = record                       (* Literal storage *)
        litstr : strtype;                      (* the literal string *)
        len : integer;                        (* its length in bytes *)
        value : integer;               (* its location counter value *)
        located : boolean               (* flag which tells if it is
                                               in a literal pool yet *)
    end; (* literal_record *)

    Symbol_Record = record                         (* Symbol storage *)
        name : labeltype;                       (* the 8 char symbol *)
        value : integer;                                (* its value *)
        rel : reltype                          (* its relocatability *)
    end; (* Symbol_record *)

    Op_Code_Type = 0..255;                         (* the opcode set *)

    Instruction_Length_Type = 1..2;    (* the instruction length set *)

    Operand_Type = ( rr1, rr2, rr3, d1, d2, d3, b, bx, im, icr,
                                 s1, s2, s3, s4);

             (*        the operand types                           *)

             (* rr1 = reg to reg RA, RB or equ                     *)
             (* rr2 = RA, RB with RA = n - 1 : shift instrs        *)
             (* rr3 = RA, RB with RB = n - 1 : isp, isn instrs     *)
             (* d1  = direct address, RA, RX                       *)
             (* d2  = dir. addr with RA = n - 1 : INCM, DECM       *)
             (* d3  = dir. addr with RA = 0  : LST, LSTI           *)
             (* b   = base reg. addressing                         *)
             (* bx  = base index addressing                        *)
             (* icr = instr counter relative : branch instrs       *)
             (* im  = immediate operand                            *)
             (* s1  = special type 1 : BEX                         *)
             (* s2  = spec type 2 : BIF                            *)
             (* s3  = spec type 3 : NOP, BPT                       *)
             (* s4  = spec type 4 : URS, XBR                       *)


    MOT_Record = RECORD         (* the machine operation table entry *)

        mnemonic: PACKED ARRAY[1..Mnem_Lgth] OF char; (* the mnemonic *)
        len: Instruction_Length_Type;             (* the instr length *)
        type_operand: Operand_Type;          (*    the operation type *)
        op_code: Op_Code_Type;               (* the opcode type field *)
        ext_op_value: 0..15;                 (* extended opcode value *)
    end;

    byte = 0..255;

    word = record
        hi_byte : byte;
        lo_byte : byte
        end;

    Symbol_Table = array[1..MAXSYM] of Symbol_Record;
                                                  (* the symbol table *)

    Literal_Table = array[1..MAXLITS] of Literal_Record;
                                                 (* the literal table *)

(**************** end of type declarations ***************************)

(****************** variable declarations ****************************)

var
    page_no,          (* current page number *)
    i,
    err_count,        (* error counter - Version 2.5 *)
    stmt_num,         (* statement number on current page *)
    line_no,          (* input line number *)
    index,            (* generic index *)
    value,            (* generic value integer *)
    length,           (* operand length *)
    align,            (* operand alignment value *)
    mem_start,        (* starting address of memory in memory array *)
    sym_tbl_len,      (* length of symbol table *)
    lit_tbl_len,      (* length of literal table *)
    opvalue,          (* value of MOT index *)
    op_len,           (* length of current mach operation *)
    loc_ctr,          (* current location counter *)
    posit       : integer;     (* position integer *)

    mem_ptr : 0..1024;

    memory : array[0..1023] of word;   (* memory object array *)

    sorted : boolean;       (* flag for symbol table being sorted.
                             not sorted for pass 1, sorted for pass 2 *)

    errflags : flag_type;        (* error flag - set by many routines *)

    errorlist : array[1..MAXLINES] of flag_type;     (* error flag set from
                                                         pass 1 *)

    ucletters : capletter;                        (* letter variables *)
    smletters : smallletters;

    digits : numbers;                             (* number character
                                                     variable         *)
    rel : reltype;                         (* relocatability variable *)

    pseudo_op : pseudo_op_type;                   (* pseudo op string *)

    mach_op_table : array[1..197] of MOT_Record;             (*  MOT  *)

    sym_tbl : Symbol_Table;                      (*  the symbol table *)

    lit_tbl : Literal_Table;                     (* the literal table *)

    f_temp,
    f_name3,
    f_name2,                                 (* the object file name  *)
    f_name1,                                 (* the listing file name *)
    f_name    : string[12];                  (*  the source file name *)

    command_line : string40;               (*   command line string *)

    src_obj1,                                (* the second object file *)
    src_obj,                                 (*  the first object file *)
    src_in,                                  (*        the source file *)
    src_lst   : text;                        (*          the list file *)

    head_str,                           (* the header for source code *)
    lit_head,                           (*   the literal table header *)
    sym_head : header_type;             (*    the symbol table header *)

    print_line  : listing_type;              (* the source print line *)
    header_line : string[MAXLIST];           (*  the page header line *)

    src_stmt,                          (*       the input source stmt *)
    labl,                              (*  the input stmt label field *)
    operation,                         (*   the input operation field *)
    operand,                           (*     the input operand field *)
    literal   : strtype;               (* the literal from oper field *)

(******************** end of variable declarations ********************)

(******************** start of procedure decl *************************)

{$I INITINCL.PAS }
{$I MOT_INC2.PAS }

procedure capitalize(var name : labeltype; var capreturn : labeltype);

(* this procedure takes an input name with upper and/or lower
   case letters and returns a name with all letters in upper case.
   other characters are not affected *)

var tempvalue,index : integer;

begin
    capreturn := name;
    for index := 1 to 8 do
    begin
        tempvalue := ord(capreturn[index]);
                                          (* copy ascii value to temp *)

        if (tempvalue >= 97) and (tempvalue <= 122) then
        begin               (* convert lower case to upper case ascii *)

            tempvalue := tempvalue - 32;         (* ascii diff is 32  *)
            capreturn[index] := chr(tempvalue)  (* store back in name *)
        end (* then begin *)

    end (* for begin *)

end (* capitalize *);


function hexchar ( hexvalue : integer) : char;

(* hexchar takes an input value of 0..15 and returns the character
   representation (in ascii)  *)

begin
    case hexvalue of
        0,1,2,3,4,5,6,7,8,9 : hexchar := chr((hexvalue+48));

        10,11,12,13,14,15 : hexchar := chr((hexvalue + 55));

        else
            hexchar := '%'    (* case for value < 0 or > 15 *)
    end (* case *)
end;


procedure writehex( value, len : integer);

(* writehex takes an input integer value and writes it to the source
   listing with length len as specified. writehex also puts leading
   zeros on the values *)

var
    tvalue,
    hexdig,
    i : integer;
    str4 : packed array [1..4] of char;      (* string vars - choose *)
    str5 : packed array [1..5] of char;      (* based on len *)
    str6 : packed array [1..6] of char;
    str8 : packed array [1..8] of char;

begin
    tvalue := value;
    case len of
        4 : begin                             (* four char field *)
            str4 := '0000';
            for i := 4 downto 1 do begin
                hexdig := tvalue mod 16;
                tvalue := tvalue div 16;
                if hexdig < 0 then hexdig := hexdig + 15;  (* V2.7 *)
                str4[i] := hexchar( hexdig)
            end;
            write(src_lst,str4)
        end;

        5 : begin                             (* five char field *)
            str5 := '00000';
            for i := 5 downto 1 do begin
                hexdig := tvalue mod 16;
                tvalue := tvalue div 16;
                if hexdig < 0 then hexdig := hexdig + 15;  (* V2.7 *)
                str5[i] := hexchar( hexdig)
            end;
            write(src_lst,str5)
        end;

        6 : begin                             (* six char field *)
            str6 := '000000';
            for i := 6 downto 1 do begin
                hexdig := tvalue mod 16;
                tvalue := tvalue div 16;
                if hexdig < 0 then hexdig := hexdig + 15;  (* V2.7 *)
                str6[i] := hexchar( hexdig)
            end;
            write(src_lst,str6)
        end;

        8 : begin                            (* eight char field *)
            str8 := '00000000';
            for i := 8 downto 1 do begin
                hexdig := tvalue mod 16;
                tvalue := tvalue div 16;
                if hexdig < 0 then hexdig := hexdig + 15;  (* V2.7 *)
                str8[i] := hexchar( hexdig)
            end;
            write(src_lst,str8)
        end;

        else
            write(src_lst,' ')              (* write a blank for
                                               unimplemented len *)
    end (* case *)
end;  (* writehex *)



function char_to_int(instr : strtype; var posit : integer) : integer;

(* char_to_int converts a char decimal field from char to integer.
   the end of string is a non-digit in the input *)

var temp : strtype;
    tempv, i, j : integer;

begin (* char_to_int *)

    i := 1;
    while (instr[posit] in digits) do begin
        temp[i] := instr[posit];            (* strip the string out *)
        i := i + 1;
        posit := posit + 1
    end; (* while *)

    tempv := 0;      (* initialize tempv *)

    for j := 1 to i - 1 do              (* convert to integer *)
        tempv := tempv * 10 + (ord(temp[j]) - 48);

    char_to_int := tempv        (* return integer value *)
end; (* char_to_int *)



function char_to_hex(instr : strtype; var posit : integer) : integer;

(* char_to_hex works the same as char_to_int except that the hex
   values A,B,C,D,E,F are recognized as valid digits, too. *)

var temp : strtype;
    tempv, i, j : integer;

begin (* char_to_hex *)

    i := 1;
    while (instr[posit] in digits)
               or (instr[posit] in ['A','B','C','D','E','F'])
                  or (instr[posit] in ['a','b','c','d','e','f']) do begin
        temp[i] := instr[posit];  (* get hex string out *)
        i := i + 1;
        posit := posit + 1
    end; (* while *)

    tempv := 0;      (* initialize tempv *)

    for j := 1 to i - 1 do              (* convert to integer *)
        if temp[j] in digits then
            tempv := tempv * 16 + (ord( temp[j]) - 48)
        else if temp[j] in ['A','B','C','D','E','F'] then
            tempv := tempv * 16 + (ord( temp[j]) - 55)
        else
            tempv := tempv * 16 + (ord( temp[j]) - 87);

    char_to_hex := tempv       (* return integer value *)
end; (* char_to_hex *)



procedure get_field (instr      : strtype;
                     var posit    : integer;
                     var retstr : strtype);

(*  function get_field does the following:
     1. starting at the position specified by the second argument,
        search for the first blank outside of matched quotes
     2. pick off the string between the starting position up to
        but not including the blank found above
     3. update the second argument to the index of the first non-blank
        following the blank found above: if none, update second argument
        to the index of the blank found above
     4. return the string found in (2) above; NOTE it may be null. *)

var
    indx : integer;
    endlit,
    endfield : boolean;

begin (* get_field *)

    indx := 1;
                         (* check for first char = blank or tab *)
    endfield := (instr[posit] = blank) or (instr[posit] = chr(9));

    while (posit <= MAXSTR - 8) and (not endfield) do begin

        if ((instr[posit] <> blank) and
                (instr[posit] <> chr(9))) then begin
            retstr[indx] := instr[posit];      (* copy non-blank *)

            if instr[posit] = '''' then begin
                endlit := false;            (* if ' found, search
                                               for end ' *)

                while not endlit do begin
                    indx := indx + 1;
                    posit := posit + 1;
                    retstr[indx] := instr[posit];  (* copy char *)
                    if instr[posit] = '''' then
                       (* ' found -- does it have another following ? *)

                        if instr[posit + 1] = '''' then begin
                      (* yes -- copy and continue search for endquote *)

                            indx := indx + 1;
                            posit := posit + 1;
                            retstr[indx] := instr[posit]
                        end (* if *)
                        else                  (* end of literal found *)
                            endlit := true
                end (* while *)

            end (* if for first ' *)
        end (* if *)

        else           (* char was blank or tab *)
            endfield := true;

        indx := indx + 1;
        posit := posit + 1
    end; (* while *)

    for indx := indx - 1 to MAXSTR do
        retstr[indx] := blank;             (* pad field with blanks *)

    while (posit <= MAXSTR - 8) and
          ((instr[posit] = blank) or (instr[posit] = chr(9))) do

        posit := posit + 1     (* advance to next non-blank *)

end; (* get_field *)



procedure get_label(     str : strtype;           (* input string *)
                     var posit : integer;           (* current position *)
                     var lab : labeltype);        (* return label *)

(* get_label copies the label from the passed string to an 8 char field
   getting only the first valid label chars. the first char is assumed
   to be a letter. following chars may be letters or digits *)

var
    index : integer;
    end_lab : boolean;

begin
    index := 1;
    lab[index] := str[posit];                       (* copy first char *)
    end_lab := false;
    index := index + 1;
    posit := posit + 1;

    while (index <= 8) and (not end_lab) do begin
                        (* search up to 7 more chars *)
        if (str[posit] in ucletters) or ( str[posit] in smletters)
                     or (str[posit] in digits) then begin
            lab[index] := str[posit];        (* get valid char *)
            index := index + 1;
            posit := posit + 1
        end
        else
            end_lab := true                (* break char found *)
    end; (* while *)

    while (index <= 8) do begin
        lab[index] := blank;              (* pad name with blanks *)
        index := index + 1
    end

end; (* get_label *)

{$I table.pas}


procedure sym_tbl_retrieve (var symbol  : labeltype;
                            var value   : integer;
                            var rel     : reltype;
                            var sym_tbl : Symbol_Table);

(* sym_tbl_retrieve takes the input symbol and searches the symbol table
   for it and returns the value and rel of the symbol. two search
   methods are used - a linear search if this is pass1 of the assembly,
   and a binary search if this is pass 2 and the table has been sorted.
   the 'sorted' flag is set to true following the sorting *)

var match : boolean;                                (* found flag *)

    low,                                          (* bin search vars *)
    upper,
    mid,
    tempindx : integer;                           (* lin search var *)

    tempsym : labeltype;                          (* temp symbol *)

begin
    capitalize(symbol,tempsym);               (* convert name to caps *)
    tempindx := 0;
    match := false;

    if sorted then begin    (* perform binary search on sorted table - pass2 *)
        low := 1;
        upper := sym_tbl_len - 1;

        while (low <= upper) and (not match) do begin
            mid := (low + upper) div 2;
            if sym_tbl[mid].name < tempsym then
                low := mid + 1

            else if sym_tbl[mid].name > tempsym then
                upper := mid - 1

            else begin                 (* sym_tbl[mid].name = tempsym *)
                match := true;
                tempindx := mid
            end
        end (* while *)
    end

    else        (* not sorted - perform linear search - during pass1 only!! *)

        while (tempindx < (sym_tbl_len - 1)) and (not match) do begin
            tempindx := tempindx + 1;
            if tempsym = sym_tbl[tempindx].name then
                match := true             (* name found *)
        end (* while *);

    if match then begin
        value := sym_tbl[tempindx].value;    (* set value and rel *)
        rel := sym_tbl[tempindx].rel
    end

    else begin
        errflags := sym_not_found;          (* else error - not found *)
        value := 0;
        rel := ABSOLUT
    end (* else *)

end; (* sym_tbl_retrieve *)



procedure lit_tbl_retrieve (literal     : strtype;
                            var value   : integer;
                            var lit_tbl : Literal_Table);

(* lit_tbl_retrieve will take an input literal string and search for
   it in the literal table, returning its location counter value.
   the search method is linear. *)

var match : boolean;
    tempindx : integer;

begin
    tempindx := 0;
    match := false;

    while (tempindx < (lit_tbl_len - 1)) and (not match) do
    begin
        tempindx := tempindx + 1;
        if literal = lit_tbl[tempindx].litstr then
            match := true           (* literal found *)
    end (* while *);

    if match then
        value := lit_tbl[tempindx].value     (* set lc value *)

    else begin
        errflags := lit_not_found;           (* else set error *)
        value := 0
    end (* else *)

end; (* lit_tbl_retrieve *)



procedure getaddress(var str     : strtype;
                     var posit     : integer;
                     var value   : integer;
                     var sym_tbl : Symbol_Table);

(* get_address gets the symbol in str and gets its value from the
   symbol table. this is used for address literals *)

var
   labl : labeltype;
   index : integer;
   end_lab : boolean;

begin
    if str[posit] = '(' then begin   (* get past first '(' *)
        posit := posit + 1;
        if (str[posit] in ucletters) or (str[posit] in smletters) then begin
            get_label(str,posit,labl);  (* use subroutine to get label *)
                                             (* get value *)
            sym_tbl_retrieve( labl, value, rel, sym_tbl);

            if str[posit] = ')' then       (* advance past end ')' *)
                posit := posit + 1
            else
                errflags := invalid_sym     (* last char not ')' *)
        end
        else begin
            value := 0;
            errflags := invalid_sym      (* first char not letter *)
        end
    end
    else begin
        value := 0;
        errflags := invalid_delim         (* lead char not '(' *)
    end
end; (* getaddress *)



procedure getstring (str       : strtype; var posit : integer;
                     var value : integer);

(* getstring gets the equivalent string value for a string in matched
   quotes and returns its integer value. it
   recognizes double quotes and double ampersands as single chars *)

var
    end_lit : boolean;

begin
    value := 0;                               (* for null string *)
    if str[posit] = '''' then begin             (* start quote *)
        end_lit := false;

        while not end_lit do begin
            posit := posit + 1;
            if str[posit] = '''' then           (* end quote ? *)

                if str[posit + 1] = '''' then begin  (* double quote *)
                    posit := posit + 1;
                    value := 256 * value + ord( str[posit])
                end

                else begin
                    posit := posit + 1;       (* advance past end ' *)
                    end_lit := true
                end

            else        (* get value update *)
                value := 256 * value + ord( str[posit])

        end (* while *)
    end
    else
        errflags := invalid_delim;    (* first char not ' *)

end; (* getstring *)

{$I realincl.pas}


procedure get_real  (    str     : strtype; var posit : integer;
                     var r_value : real);

(* get_real gets the equivalent real value for a real in matched
   quotes and returns its integer value. It recognizes double
   quotes and double ampersands as single chars *)

var
    end_real : boolean;

    prev_mul,
    new_mul,
    if_dec,
    mulp     : real;

    i1,
    exponent,
    mant_sign,
    exp_sign : integer;


begin
    r_value := 0.0;                           (* for null string *)
    prev_mul := 10.0;
    new_mul := 1.0;
    if_dec := 1.0;
    exp_sign := 0;
    mant_sign := 1;

    if str[posit] = '''' then begin             (* start quote *)
        end_real := false;

        if str[posit+1] = '-' then begin
            posit := posit + 1;
            mant_sign := -1
        end
        else if str[posit+1] = '+' then
            posit := posit + 1;

        while not end_real do begin
            posit := posit + 1;
            if str[posit] = '''' then           (* end quote *)
                end_real := true


            else if str[posit] = '.' then
                if_dec := 10.0

            else if str[posit] in ['E','e'] then begin
                posit := posit + 1;
                if str[posit] = '-' then begin
                    posit := posit + 1;
                    exp_sign := -1
                    end
                else if str[posit] = '+' then
                    posit := posit + 1;

                r_value := r_value / new_mul;    (* take care of mantissa *)
                new_mul := 1.0;

                exponent := char_to_int( str, posit);
                mulp := 1.0;
                for i1 := 1 to exponent do
                    mulp := 10 * mulp;

                if exp_sign = -1 then
                    r_value := r_value / mulp
                else
                    r_value := r_value * mulp;

                end_real := true
                end

            else begin       (* get value update *)
                r_value := prev_mul * r_value + (ord(str[posit])-48);
                new_mul := new_mul * if_dec
                end

        end; (* while *)

        r_value := r_value / new_mul;    (* take care of mantissa *)
                                         (* if exponent was found,
                                            new_mul = 1           *)

        if mant_sign = -1 then
            r_value := - (r_value)

    end
    else
        errflags := invalid_delim     (* first char not ' *)

end; (* get_real *)


procedure convert (var instr   : strtype; var posit    : integer;
                   var align   : integer; var length : integer;
                   var value   : integer;
                   var sym_tbl : Symbol_Table);

(* convert takes the input instr and converts it to an integer value.
   convert calls getaddress for address literals, getstring for char
   literals, and converts hex and decimal literals with the char_to_hex
   and char_to_int routines  *)

var
    ch :char;
    r_value : real;

begin (* convert *)
    ch := instr[posit];      (* get type char *)
    posit := posit + 1;        (* move posit *)

    case  ch    of
                                                   (* address literal *)
        'A','a' : getaddress( instr, posit, value, sym_tbl);

        'C','c' : getstring ( instr, posit, value);  (*    char literal *)

        'D','d' : begin                            (* decimal literal *)
            posit := posit + 1;
            value := char_to_int( instr, posit);
            posit := posit + 1
           end;

        'X','x' : begin                            (*     hex literal *)
            posit := posit + 1;
            value := char_to_hex( instr, posit);
            posit := posit + 1
          end;

        'F','f','E','e' : begin
            get_real( instr, posit, r_value);    (* float pt literal *)
            value := trunc( r_value)
          end

      end (* case *)

end; (* convert *)


function primary (var sym_tbl : Symbol_Table; x : strtype;
                  var posit : integer; var rel : reltype) : integer;

(* primary gets the value of the first element at posit - a symbol value,
   an integer, a literal (without =), or the location counter value.
   the resulting value is returned to the caller *)

var
    symbol : labeltype;
    value : integer;

begin
    rel := ABSOLUT;
    value := 0;
    if (x[posit] in ucletters) or (x[posit] in smletters) then

        if x[posit + 1] = '''' then                    (* a literal *)
            convert( x, posit, align, length, value, sym_tbl)

        else begin                                    (* a symbol *)
            get_label( x, posit, symbol);
            sym_tbl_retrieve( symbol, value, rel, sym_tbl)
        end (* else *)

    else if x[posit] in digits then                 (* an integer value *)
        if x[posit] = '0' then                      (* hex value if leading 0 *)
            value := char_to_hex( x, posit)
        else                                      (* else decimal value *)
            value := char_to_int( x, posit)

    else if x[posit] = ':' then begin               (* a hex constant value *)
        posit := posit + 1;
        value := char_to_hex( x, posit)
        end  (* then *)

    else if x[posit] = '-' then begin               (* a neg. constant value *)
        posit := posit + 1;
        value := - ( char_to_hex( x, posit))
        end  (* then *)

    else if x[posit] = '$' then begin      (* location counter value *)
        value := loc_ctr;
        rel := RELOCAT;
        posit := posit + 1
        end (* then *)

    else
        errflags := invalid_term;   (* set error flag - not a primary *)

    primary := value                 (* return value found *)

end; (* primary *)

{$I evalopnd.pas}


function op_type(op : strtype; var opvalue : integer) : boolean;

(* op_type checks the input string against the list of opcodes and
   returns true if a match is found. it sets opvalue with the match
   operation value if found. *)

var index : integer;
    temp_op : packed array[1..Mnem_Lgth] of char;

begin
    op_type := true;
    for index := 1 to Mnem_Lgth do      (* get mnemonic chars *)
        temp_op[index] := op[index];    (* copy to temp *)
    index := 0;
                                            (* do an optimized search *)
    if mach_op_table[128].mnemonic < temp_op then
        index := 197 + 1 - 128;
                            (* assert mach_op_table[index] < temp_op and
                               mach_op_table[index + 128] > temp_op *)
    if mach_op_table[index + 64].mnemonic < temp_op then
        index := index + 64;
    if mach_op_table[index + 32].mnemonic < temp_op then
        index := index + 32;
    if mach_op_table[index + 16].mnemonic < temp_op then
        index := index + 16;
    if mach_op_table[index + 8].mnemonic < temp_op then
        index := index + 8;
    if mach_op_table[index + 4].mnemonic < temp_op then
        index := index + 4;
    if mach_op_table[index + 2].mnemonic < temp_op then
        index := index + 2;
    if mach_op_table[index + 1].mnemonic < temp_op then
        index := index + 1;

    opvalue := index + 1;

    if ((index + 1) > 197) then begin   (* temp_op beyond end of table *)
        opvalue := 0;
        op_type := false
    end
    else if (mach_op_table[index + 1].mnemonic <> temp_op) then begin
        opvalue := 0;
        op_type := false              (* temp_op not in table *)
    end (* else if *)

end (* op_type *);



function get_rep (var posit : integer; var str : strtype) : integer;

(* get_rep gets the integer value at the start of a DATA/DW string,
   and returns it as the repetition count for the string. if no
   integer is there, get_rep returns 1 (default) *)

begin
    if str[posit] in digits then       (* if first char is a digit *)
        get_rep := char_to_int( str, posit)
    else                             (* else no digit - return 1 *)
        get_rep := 1
end; (* get_rep *)



function get_length(var posit : integer; str : strtype) : integer;

(* get_length takes the input str and determines its length.
   for address and full word values, length is returned as 1. char
   literals are checked and the length is the number of chars between
   the outer quotes, but '' counts as one char. the char count
   is the length. for hex values, the length = (number of digits + 1)
   div 4.  *)

var
    rel    : reltype;   (* not used *)
    value,
    length : integer;
    endstr : boolean;

begin
    if ((str[posit] in ['C','D','E','F','H','X','c','d','e','f','h','x']) and
              (str[posit + 1] = '''')) or
       ((str[posit] in ['A','a']) and (str[posit + 1] = '(')) or
        (str[posit] = ':') then begin

        case str[posit] of

          'D','A','H','d','a','h',':' : begin
                  get_length := 1; (* default *)
                  posit := posit + 2;
                  while (str[posit] <> ',') and (str[posit] <> ' ') do
                      posit := posit + 1
                  end;

          'F','f' : begin
                  get_length := 2;
                  posit := posit + 2;
                  while (str[posit] <> ',') and (str[posit] <> ' ') do
                      posit := posit + 1
                  end;

          'E','e' : begin
                  get_length := 3;
                  posit := posit + 2;
                  while (str[posit] <> ',') and (str[posit] <> ' ') do
                      posit := posit + 1
                  end;

          'C','c' : begin             (* char literal *)
              posit := posit + 2;  (* advance posit to first char *)
              endstr := false;
              length := 0;
              while not endstr do begin
                if str[posit] = '''' then
                    if str[posit + 1] = '''' then (* count '' as ' *)
                        posit := posit + 2
                    else begin                  (* end of str *)
                        length := length - 1;
                        endstr := true;
                        posit := posit + 1
                    end
                else                            (* count one char *)
                    posit := posit + 1;
                length := length + 1
              end; (* while *)

              get_length := (length + 1) div 2

            end; (* case for 'c' *)

        'X','x' : begin                (* count hex chars *)
            posit := posit + 2;
            endstr := false;
            length := 0;
            while not endstr do begin
                if str[posit] = '''' then
                    endstr := true
                else
                    length := length + 1;
                posit := posit + 1
            end;  (* while *)

            get_length := (length + 1) div 4

        end      (* case for 'x' *)

      end (* case *)
    end (* then *)

            (* symbolic data value - one word length. use eval to skip past *)
    else begin
        eval( sym_tbl, lit_tbl, str, posit, value, rel); (* get value *)
        get_length := 1
        end (* else *)

end;                   (* get_length *)



procedure lit_tbl_insert   (literal     : strtype;
                            var value   : integer;
                            var lit_tbl : Literal_Table);

(* lit_tbl_insert will take the input literal string, search the
   literal table for it, and add it to the end if it is not already
   there. the search is a linear search. *)

var match : boolean;
    tempindx : integer;

begin
    tempindx := 0;
    match := false;
    while (tempindx < (lit_tbl_len - 1)) and (not match) do
    begin
        tempindx := tempindx + 1;
        if literal = lit_tbl[tempindx].litstr then
            match := true              (* already there *)
    end (* while *);

    if  not match    then begin         (* need to add to table *)
        lit_tbl[lit_tbl_len].litstr := literal;
        lit_tbl[lit_tbl_len].value := value;
        tempindx := 2;
        lit_tbl[lit_tbl_len].len := get_length( tempindx, literal);

        lit_tbl_len := lit_tbl_len + 1   (* advance table pointer *)

    end (* then *)

end; (* lit_tbl_insert *)


procedure proc_EQU (var labl    : strtype;
                    var sym_tbl : Symbol_Table;
                    var lit_tbl : Literal_Table);

(*  proc_EQU -- process the EQU pseudo op. evaluate the operand field
    and set the symbol in labl with the evaluated value *)

var posit,value : integer;

begin     (* proc_EQU *)

    posit := 1;
    eval( sym_tbl, lit_tbl, operand, posit, value, rel); (* get value *)
    sym_tbl_insert( labl, value, rel, sym_tbl)    (* insert in S.T. *)

end;    (* proc_EQU *)



procedure proc_ORG (var loc_ctr : integer;
                    var sym_tbl : Symbol_Table;
                    var lit_tbl : Literal_Table);

(*  proc_ORG -- process the ORG pseudo op. evaluate the operand field
    and set the location counter with the evaluated value *)

var posit, value : integer;

begin     (* proc_ORG *)

    posit := 1;
    eval( sym_tbl, lit_tbl, operand, posit, value, rel); (* get value *)

    if rel = RELOCAT then           (* value should be absolute *)
        error( invalid_expr)
    else
        loc_ctr := value

end;    (* proc_ORG *)



procedure proc_DATA ( var operand : strtype; dw_flag : boolean);

(*  proc_DATA -- process DATA or DW pseudo ops. evaluate the operand
    field for the constants there, advancing the location counter
    by the length * rep of the constants. alignment is performed
    first. *)

var
    pass1 : boolean;
    fill,
    align,
    rep : integer;

begin    (* proc_DATA *)

    posit := 1;
    pass1 := true;                (* insert symbol into S.T. on pass1 only *)

    repeat                                           (*  get all constants *)
        rep := get_rep( posit, operand);               (*      get rep value *)

        if pass1 then begin
                                (* write label and loc_ctr for first value *)
            if labl[1] <> blank then
                sym_tbl_insert(labl, loc_ctr, RELOCAT, sym_tbl);

            pass1 := false
        end;

        if dw_flag then begin                 (* DW has only type and rep *)

            case operand[posit] of

                'a','A','d','D',
                        'h','H' : length := 1;    (* one word constants *)

                'c','C'      : begin              (* reserve one word for
                                                     each 2 chars *)
                                  rep := (rep + 1) div 2;
                                  length := 1
                               end;

                'x','X'      : begin              (* reserve one word for
                                                     each four chars *)
                                  rep := (rep + 3) div 4;
                                  length := 1
                               end;

                'f','F'         : length := 2;    (* float pt. storage     *)

                'e','E'         : length := 3;    (* ext float pt. storage *)

                else
                    length := 0                   (* unknown type *)
            end (* Case *)
        end

        else                                   (* DATA has rep and constant *)
            length := get_length( posit, operand);

        loc_ctr := loc_ctr + length * rep;             (* advance loc_ctr *)
        posit := posit + 1

    until (operand[posit - 1] <> ',')        (* repeat while list not empty *)

end;     (* proc_DATA *)



procedure proc_END(var loc_ctr : integer; var lit_tbl : Literal_Table);

(*  proc_END -- process the END pseudo op
    proc_END dumps any non-located literals into a literal pool.
    Note: if the pseudo op is LTORG, it also uses proc_END for pass 1 *)

var
    i : integer;

begin     (* proc_END *)

    for i := 1 to lit_tbl_len - 1 do     (* search lit_tbl *)

        if not (lit_tbl[i].located) then begin   (* if not in pool *)

            lit_tbl[i].value := loc_ctr;
            loc_ctr := loc_ctr + lit_tbl[i].len;
            line_no  := line_no + 1;     (* advance line nums
                                           on literal pool *)
            lit_tbl[i].located := true   (* don't place again *)
        end

end;   (* proc_END *)



procedure pass_one( var sym_tbl : Symbol_Table;
                    var lit_tbl : Literal_Table);

    (******  pass_one -- perform pass one of the assembly ***********)

begin    (* pass_one *)

    loc_ctr := 0;                           (*       init loc_ctr = 0 *)
    pseudo_op := '      ';                  (*     pseudo op = blanks *)
    sorted := false;                        (* sym_tbl not sorted yet *)
    line_no := 1;                           (*         input line = 1 *)

    if eof( src_in) then
        error(no_source)                         (* source file empty *)

    else repeat                              (* else read source file *)

        readln( src_in, src_stmt);                (*   get line input *)
        errflags := 0;                            (*     no error yet *)

        if (src_stmt[1] <> '*') and (src_stmt[1] <> '.') and
               (src_stmt[1] <> ';')  then begin      (* not comment line *)

                      (*  locate label, operation, and operand fields *)

            posit := 1;
            get_field( src_stmt, posit, labl);       (*     label field *)
            get_field( src_stmt, posit, operation);  (* operation field *)
            get_field( src_stmt, posit, operand);    (*   operand field *)

            if op_type(operation,opvalue) then begin     (* if in MOT *)

                op_len := mach_op_table[opvalue].len;    (*   get len *)

                if labl[1] <> blank then       (* place label in S.T. *)
                    sym_tbl_insert( labl, loc_ctr, RELOCAT, sym_tbl);

                loc_ctr := loc_ctr + op_len;    (* advance loc_ctr by
                                                     operation length *)

                posit := 1;                         (* set posit to start *)
                value := 0;
                while get_lit( operand, posit, literal) do
                              (* search for literals in operand field *)
                    lit_tbl_insert( literal, value, lit_tbl)

            end (* if for operation being in MOT *)

            else begin                     (* not a machine operation *)

                for index := 1 to 6 do
                    pseudo_op[index] := operation[index];

                if pseudo_op = 'EQU   ' then
                   proc_EQU(labl,sym_tbl,lit_tbl)  (* process EQU pseudo op *)

                else if pseudo_op = 'ORG   ' then
                   proc_ORG(loc_ctr,sym_tbl,lit_tbl)
                                                   (* process ORG pseudo op *)

                else if (pseudo_op = 'DATA  ') or
                      (pseudo_op = 'CONS  ') or (pseudo_op = 'DW    ') then

                    proc_DATA( operand, (pseudo_op = 'DW    '))

                else if pseudo_op = 'END   '  then
                    proc_END( loc_ctr, lit_tbl)       (* process END *)


                else if pseudo_op = 'START ' then begin
                    loc_ctr := 0;        (* put start symbol in S.T. *)
                    if labl[1] <> blank then
                        sym_tbl_insert( labl, loc_ctr, RELOCAT, sym_tbl)
                end


                else if pseudo_op = 'LTORG ' then
                               (* treat like END *)
                    proc_END( loc_ctr, lit_tbl)


                else if pseudo_op = 'EJECT ' then begin
                     (* null - no processing for EJECT *)
                end


                else
                    errflags := invalid_op   (* not a valid op *)

               end    (* else *)

        end (* if for non-comment line *);

        errorlist[ line_no] := errflags;
                                    (* copy error flag for this stmt *)
        line_no := line_no + 1                   (* incr line number *)


    until (pseudo_op = 'END   ') or ( eof(src_in)) or
                       ( line_no >= (MAXLINES + 1) )       (* end else *)


end;    (* pass_one *)


{$I QSORT.PAS}

{$I PAS2INCL.PAS}

procedure get_file ( var command_line : string40;
                         extension    : str4;
                     var file1        : string12);

var
    end_of_name : boolean;
    i,j,k,
    cmd_len,
    start, final,
    char_cnt : integer;

begin
    char_cnt := Ord( command_line[0]);

    if char_cnt <> 0 then begin         (* parameters present on cmd line *)

        if (command_line[char_cnt] <> ' ') and
           (command_line[char_cnt] <> ';') then

               command_line := command_line + ' ';

        start := 1;
        final := 2;
        end_of_name := false;

        while not end_of_name do

            if command_line[final] = ';' then begin     (* 'fname;' found *)

                file1 := Copy( command_line,start,(final-start));
                file1 := file1 + extension;
                end_of_name := true
                end

            else if command_line[final] = '.' then begin
                 final := final + 1;
                 while (command_line[final] <> ',') and
                       (command_line[final] <> ' ') do
                     final := final + 1;
                 file1 := Copy( command_line, start, (final-start));
                 end_of_name := true;
                 Delete( command_line, start, (final-start+1));
                 if command_line[start] = ' ' then
                     Delete( command_line, start, 1)
                 end

            else if (command_line[final] = ',') or
                    (command_line[final] = ' ') then begin
                 file1 := Copy( command_line, start,(final-start));
                 file1 := file1 + extension;
                 end_of_name := true;
                 Delete( command_line,start,(final-start+1))
                 end

            else final := final + 1

        end (* then *)
        else
            file1 := ''

end;


(*********************    main program body **************************)

begin    (* assem_1750 main routine *)

    writeln( output,version_label);
    writeln( output);

    (*  open file for source input *)

    if ParamCount <> 0 then begin
        command_line := ParamStr( 1);
        get_file( command_line, '.asm',f_name);
        get_file( command_line, '.lst',f_name1);

        if Ord( f_name1[0]) = 0 then begin
            f_name1 := f_name;
            i := Pos( '.',f_name1);
            if i <> 0 then
                Delete( f_name1, i, 4);
            f_name3 := f_name1 + '.SFH';
            f_name2 := f_name1 + '.SFO';
            f_name1 := f_name1 + '.LST';
            write( 'Name of List file [',f_name1,']:');
            readln( f_temp);
            if ord( f_temp[0]) <> 0 then
                f_name1 := f_temp;
            write( 'Name of First Object file [',f_name2,']:');
            readln( f_temp);
            if Ord( f_temp[0]) <> 0 then
                f_name2 := f_temp;
            write( 'Name of Second Object file [',f_name3,']:');
            readln( f_temp);
            if Ord( f_temp[0]) <> 0 then
                f_name3 := f_temp

        end (* then *)

        else begin
            get_file( command_line, '.sfo',f_name2);
            if Ord( f_name2[0]) = 0 then begin
                f_name2 := f_name;
                i := Pos( '.',f_name2);
                if i <> 0 then
                    Delete( f_name2, i, 4);
                f_name3 := f_name2 + '.SFH';
                f_name2 := f_name2 + '.SFO';
                write( 'Name of First Object file [',f_name2,']:');
                readln( f_temp);
                if Ord( f_temp[0]) <> 0 then
                    f_name2 := f_temp;
                write( 'Name of Second Object file [',f_name3,']:');
                readln( f_temp);
                if Ord( f_temp[0]) <> 0 then
                    f_name3 := f_temp
            end
            else begin
                get_file( command_line, '.sfh',f_name3);
                if Ord( f_name3[0]) = 0 then begin
                    f_name3 := f_name;
                    i := Pos( '.',f_name3);
                    if i <> 0 then
                        Delete( f_name3, i, 4);
                    f_name3 := f_name3 + '.SFH';
                    write( 'Name of Second Object file [',f_name3,']:');
                    readln( f_temp);
                    if Ord( f_temp[0]) <> 0 then
                        f_name3 := f_temp
                end
            end
        end
    end

    else begin
        write( 'Name of source file (no extension): ');
        readln( f_name);
        f_name1 := f_name + '.lst';
        f_name2 := f_name + '.sfo';
        f_name3 := f_name + '.sfh';
        f_name := f_name + '.asm'
        end;

    assign( src_in, f_name);
    reset( src_in);

    (*  open file for source listing output *)

    assign( src_lst, f_name1);
    rewrite( src_lst);

    (*  open file for first object output *)

    assign( src_obj, f_name2);
    rewrite( src_obj);

    (*  open file for second object output *)

    assign( src_obj1, f_name3);
    rewrite( src_obj1);

    sym_tbl_len := 1;
    lit_tbl_len := 1;

    initialize;                              (* perform general inits *)
    mot_init;                                (*        init MOT table *)

    pass_one( sym_tbl, lit_tbl);             (*        perform pass 1 *)

    close( src_in);                          (*      close input file *)

                                             (* sort the symbol table *)
    quicksort( sym_tbl, 1, (sym_tbl_len - 1));

    sorted := true;                     (* symbol table is now sorted *)

    pass_two( sym_tbl, lit_tbl, src_in, src_lst);   (* perform pass 2 *)

    close(src_obj1);
    close(src_obj);                                (* close obj file  *)
    close(src_lst)                                 (* close list file *)

end. (* assem_1750 *)

