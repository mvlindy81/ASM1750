

(**********************************************************************)
(*                                                                    *)
(*                     PASS 2 PROCEDURES                              *)
(*                                                                    *)
(**********************************************************************)


procedure header_prep ( header_str : header_type);

(* header_prep copies the passed header_str into the current header
   line. header_line is the line to be printed as the header for
   pages *)

var i : integer;                                (* generic index *)

begin
    for i := 1 to HEADER_LEN do
        header_line[ i] := header_str[ i]      (* copy header_str to
                                                  header_line *)
end; (* header_prep *)


procedure page_num;

(* procedure page_num prints the page number line at the beginning
   of the page and increments the page number counter.  *)

begin
    writeln( src_lst,'                               ',
                     '                               ',
                     '                               ',
                     '                           PAGE ',page_no : 5);

    page_no := page_no + 1                  (* incr page_no *)

end; (* page_num *)



procedure print ( print_line : listing_type;
                  errflags   : flag_type);

(* print copies the print_line to the listing file, evaluates the errflags,
   and copies any error messages to the listing file. *)

begin
    if stmt_num < 62 then begin           (* not new page yet *)
        writeln( src_lst, print_line);
        stmt_num := stmt_num + 1
    end
    else begin
        writeln( src_lst, chr(12));       (* write form feed *)
        stmt_num := 8;                    (* init stmt_num at line 8 *)
        writeln( src_lst);                (* write blank line *)
        page_num;                         (* write page number line *)
        writeln( src_lst);                (* write two blank lines *)
        writeln( src_lst);
        writeln( src_lst, header_line);   (* write header line *)
        writeln( src_lst);                (* write blank line *)
        writeln( src_lst, print_line)
    end;

    if (errflags <> 0) then begin
        error( errflags);                 (* write error message     *)
        err_count := err_count + 1;       (* increment error counter *)
        stmt_num := stmt_num + 1
    end
    else if errorlist[line_no - 1] <> 0 then begin
        error( errorlist[line_no - 1]);   (* write error message     *)
        err_count := err_count + 1;       (* increment error counter *)
        stmt_num := stmt_num + 1          (* pass 1 error            *)
    end

end; (* print_line *)



procedure src_move ( src_stmt      : strtype;
                    var print_line : listing_type);

(* src_move copies the src_stmt to the proper place in the print
   line for eventual listing. sorrce stmt starts at col 40. *)

var
   i : integer;                                     (* index *)

begin
    for i := 1 to MAXSTR do
        print_line[i + 40] := src_stmt[i]   (* copy src_stmt *)

end; (* src_move *)


procedure lit_move ( literal       : strtype;
                    var print_line : listing_type);

(* lit_move copies the literal to the proper place in the print
   line for eventual listing for an END or LTORG statement. *)

var
   i : integer;                                     (* index *)

begin
    for i := 1 to MAXSTR - 40 do
        print_line[i + 55] := literal[i]   (* copy lit_stmt *)

end; (* lit_move *)




procedure clear (var print_line : listing_type);

(* clear blanks the print_line to clear any chars that may not be
   overwritten by other procedures *)

var
    i : integer;

begin
    for i := 1 to MAXLIST do
        print_line[ i] := blank

end; (* clear *)


procedure get_hex ( value : integer; var hex_str : char4);

(* get_hex converts the value into the hex_str. it calls the function
   hexchar to make the transform from integer to hex char   *)

var
   i,
   tvalue,
   hexdig : integer;

begin
    if value >= 0 then begin
        tvalue := value;

        for i := 4 downto 1 do begin               (* write len chars *)
            hexdig := tvalue mod 16;
            tvalue := tvalue div 16;
            hex_str[ i ] := hexchar( hexdig)
        end
    end
    else begin        (* negative value to write *)
        tvalue := - value - 1;

        for i := 4 downto 1 do begin               (* write len chars *)
            hexdig := 15 - tvalue mod 16;
            tvalue := tvalue div 16;
            hex_str[ i ] := hexchar( hexdig)
        end
    end

end; (* get_hex *)



procedure put_word_in_memory ( high_byte, low_byte : byte);

(* put_word_in_memory adds the passed bytes as words into the memory array,
   moving the mem_ptr to point to the next word. The subsequent word of
   is set to zero. *)

var local_ptr : 0..1023;

begin
    local_ptr := mem_ptr;

    with memory[local_ptr] do begin
        hi_byte := high_byte;
        lo_byte := low_byte
        end;

    mem_ptr := mem_ptr + 1;  local_ptr := local_ptr + 1;

    with memory[local_ptr] do begin
        hi_byte := 0;
        lo_byte := 0
        end

end;  (* put_word_in_memory *)


function char_hex ( ch : char) : integer;

begin
    if ch in digits then
        char_hex := ord (ch) - 48
    else if ch in ['A','B','C','D','E','F'] then
        char_hex := ord (ch) - 55
    else if ch in ['a','b','c','d','e','f'] then
        char_hex := ord (ch) - 87
    else
        char_hex := 0

end; (* char_hex *)



procedure put_str_in_memory ( hex_str : char4);

(* put_str_in_memory adds the passed ASCII hex string as one word of memory,
   moving the mem_ptr to point to the next word. The subsequent word of
   is set to zero. *)

var local_ptr : 0..1023;

begin
    local_ptr := mem_ptr;

    with memory[local_ptr] do begin
        hi_byte := 16 * char_hex( hex_str[1]) + char_hex( hex_str[2]);
        lo_byte := 16 * char_hex( hex_str[3]) + char_hex( hex_str[4]);
        end;

    mem_ptr := mem_ptr + 1;  local_ptr := local_ptr + 1;

    with memory[local_ptr] do begin
        hi_byte := 0;
        lo_byte := 0
        end

end;  (* put_word_in_memory *)



procedure dump_memory;

(* dump_memory copies the memory image to the object file. the stream of
   words is preceded by the obj_head, '/C00', the start address in ASCII,
   the word count in ASCII, followed by the stream of words.  the start
   address, word count, and each word is a set of four ASCII hex digits. *)

var value, i1 : integer;
    loc_str,
    hex_str   : char4;

begin

    if mem_ptr <> 0 then begin

        write( src_obj, obj_head);

        value := mem_start;
        get_hex( value, hex_str);
        write( src_obj, hex_str);

        value := mem_ptr;
        get_hex( value, hex_str);
        write( src_obj, hex_str);

        for i1 := 0 to mem_ptr-1 do begin
            with memory[i1] do
                value := 256 * hi_byte + lo_byte;
            get_hex( value, hex_str);
            get_hex( mem_start+i1,loc_str);
            write( src_obj, hex_str);
            writeln( src_obj1,' ',loc_str,' ',hex_str)   (* second obj file *)
        end
    end
end;  (* dump_memory *)



(*********  pass_two -- perform pass two of the assembly *************)


procedure pass_two( var sym_tbl : Symbol_Table;
                    var lit_tbl : Literal_Table;
                    var src_in  : text;
                    var src_lst : text);

type
    datetimetype = string[8];                (* for date & time routines *)

    regtype = record
               ax,bx,cx,dx,bp,si,di,ds,es,flags : integer
              end;

var
    r1,                            (* register 1 value *)
    b1,                            (* base 1 value *)
    x1,                            (* index 1 value *)
    disp1,                         (* displacement 1 value *)
    disp2,                         (* displacement 2 value *)
    b2,                            (* base 2 value *)
    r2,                            (* register 2 value *)
    r3,                            (* register 3 value *)
    i2,                            (* immediate 2 value *)
    line_ptr,                      (* pointer into print line *)
    op_value,                      (* MOT index value *)
    op,                            (* opcode value *)
    ext_op,                        (* extended opcode *)
    pos       : integer;           (* string position value *)

    opr_type : Operand_Type;       (* operand value *)

    src_stmt,                      (* source statement *)
    labl,                          (* label field *)
    operation,                     (* operation field *)
    operand,                       (* operand field *)
    literal   : strtype;           (* literal string *)

    pseudo_op : pseudo_op_type;    (* pseudo op string *)

(********** end of pass2 variables ************************************)


(********** pass2 internal procedures *********************************)


procedure copy_hex ( var pos : integer;
                     len     : integer;
                     value   : integer);

(* copy_hex writes the value into the print_line at position pos with
   length len. it calls the function hexchar to make the transform from
   integer to hex char   *)

var
   i,
   tvalue,
   hexdig : integer;

begin
    if value >= 0 then begin
        tvalue := value;

        for i := len downto 1 do begin               (* write len chars *)
            hexdig := tvalue mod 16;
            tvalue := tvalue div 16;
            print_line[ pos + i - 1] := hexchar( hexdig)
        end
    end
    else begin        (* negative value to write *)
        tvalue := - value - 1;

        for i := len downto 1 do begin               (* write len chars *)
            hexdig := 15 - tvalue mod 16;
            tvalue := tvalue div 16;
            print_line[ pos + i - 1] := hexchar( hexdig)
        end
    end;

    pos := pos + len                             (* advance pos *)
end; (* copy_hex *)


procedure copy_dec ( var pos : integer;
                     len     : integer;
                     value   : integer);

(* copy_dec writes the value into the print_line at position pos with
   length len. it calls the function hexchar to make the transform from
   integer to hex char, although the char will be between 0 and 9.   *)

var
   i,
   tvalue,
   hexdig : integer;

begin
    tvalue := value;

    for i := len downto 1 do begin           (* write len chars *)
        hexdig := tvalue mod 10;
        tvalue := tvalue div 10;
        if (hexdig <> 0) or (tvalue <> 0) then
            print_line[ pos + i - 1] := hexchar( hexdig)
    end;

    pos := pos + len                 (* advance pos *)

end; (* copy_dec *)



procedure put_RR_obj ( loc_ctr : integer;
                       opcode  : integer;
                       reg1    : integer;
                       reg2    : integer);

(* put_RR_obj places the hex values in the print_line using the copy_hex
   procedure which incrementally copies the passed values based on their
   length. this is for RR type instructions only *)

var
   pos : integer;

begin
    pos := 3;
    copy_hex( pos, 4, loc_ctr);      (* put location counter value *)
    pos := pos + 1;                  (* skip a space *)
    copy_hex( pos, 2, opcode);       (* put opcode = 1 bytes *)
    copy_hex( pos, 1, reg1);         (* put reg1 = 1/2 byte *)
    copy_hex( pos, 1, reg2);         (* put reg2 = 1/2 byte *)

    put_word_in_memory( opcode, (16*reg1 + reg2))

end; (* put_RR_obj *)


procedure put_D_obj ( loc_ctr : integer;
                      opcode  : integer;
                      reg1    : integer;
                      index1  : integer;
                      disp1   : integer;
                      value   : integer);

(* put_D_obj places the hex values in the print_line using the copy_hex
   procedure which incrementally copies the passed values based on their
   length. this is for D1, D2, D3 and IM type instructions *)

var
    hi_byte,              (* Version 2.6 change *)
    lo_byte,
    pos : integer;

begin
    pos := 3;
    copy_hex( pos, 4, loc_ctr);      (* put location counter *)
    pos := pos + 1;                  (* skip a space *)
    copy_hex( pos, 2, opcode);       (* put opcode *)
    copy_hex( pos, 1, reg1);         (* put reg1 *)
    copy_hex( pos, 1, index1);       (* put index1 = 1/2 byte *)
    pos := pos + 1;                  (* skip a space *)
    copy_hex( pos, 4, disp1);        (* put displacement = 2 bytes *)
    pos := pos + 7;                  (* skip 7 spaces *)
    copy_hex( pos, 4, value);        (* put abs disp in addr1 field *)

    put_word_in_memory( opcode, (16*reg1 + index1));

    if (disp1 < 0) and (disp1 > $8000) then    (* Version 2.6 Change *)
        hi_byte := (disp1 div 256) - 1         (* Version 2.7 Change *)
    else                                       (* and (> $8000) test *)
        hi_byte := disp1 div 256;

    lo_byte := disp1 mod 256;

    put_word_in_memory( hi_byte, lo_byte)

end; (* put_D_obj *)


procedure put_ICR_obj ( loc_ctr : integer;
                       opcode  : integer;
                       disp2   : integer;
                       value   : integer);


(* put_ICR_obj places the hex values in the print_line using the copy_hex
   procedure which incrementally copies the passed values based on their
   length. this is for ICR type instructions only *)

var
   pos : integer;

begin
    pos := 3;
    copy_hex( pos, 4, loc_ctr);      (* put location counter *)
    pos := pos + 1;                  (* skip a space *)
    copy_hex( pos, 2, opcode);       (* put opcode *)
    copy_hex( pos, 2, disp2);        (* put disp2 value *)
    pos := pos + 12;                 (* skip 12 spaces *)
    copy_hex( pos, 4, value);        (* put abs displ value *)

    put_word_in_memory( opcode, disp2)

end; (* put_ICR_obj *)



procedure proc_RR1( op_value : integer;
                    var loc_ctr : integer);

(*  proc_RR1 -- process RR1-type operands *)

var
    r1, r2,
    value,
    pos   : integer;

begin    (* proc_RR1 *)

    pos := 1;

             (* get reg1 field value *)
    r1 := reg_eval( sym_tbl, lit_tbl, operand, pos, value);
    pos := pos + 1;    (* skip comma *)

            (* get reg2 field value *)
    r2 := reg_eval( sym_tbl, lit_tbl, operand, pos, value);

            (* put obj into printline  *)
    put_RR_obj( loc_ctr, op, r1, r2);

    loc_ctr := loc_ctr + 1          (* advance loc_ctr *)

end;    (* proc_RR1 *)



procedure proc_RR2(     op_value : integer;
                    var loc_ctr  : integer);

(*  proc_RR2 -- process RR2-type operands. same as RR1 except that the
    value for R1 is within 1 to 16 instead of 0 to 15. Also, r1 and r2
    are exchanged in the operand field. *)

var
    r1, r2,
    value,
    pos   : integer;
    rel   : reltype;

begin    (* proc_RR2 *)

    pos := 1;

            (* get reg2 field value *)
    r2 := reg_eval( sym_tbl, lit_tbl, operand, pos, value);

    pos := pos + 1;         (* skip comma *)

             (* get reg1 field value *)
    eval( sym_tbl, lit_tbl, operand, pos, value, rel);
    r1 := value;

    if ((r1 < 1) or (r1 > 16)) then begin    (*   1 <= r1 <= 16   *)
        r1 := 0;
        errflags := invalid_expr
    end
    else
        r1 := r1 - 1;        (* r1 stored as n-1 *)

            (* put obj into printline  *)
    put_RR_obj( loc_ctr, op, r1, r2);

    loc_ctr := loc_ctr + 1          (* advance loc_ctr *)

end;    (* proc_RR2 *)



procedure proc_RR3( op_value : integer;
                    var loc_ctr : integer);

(*  proc_RR3 -- process RR3-type operands. same as RR1 except that the
    value for R2 is within 1 to 16 instead of 0 to 15 *)

var
    r1, r2,
    value,
    pos   : integer;
    rel   : reltype;

begin    (* proc_RR3 *)

    pos := 1;

             (* get reg1 field value *)
    r1 := reg_eval( sym_tbl, lit_tbl, operand, pos, value);
    pos := pos + 1;    (* skip comma *)


            (* get reg2 field value *)
    eval( sym_tbl, lit_tbl, operand, pos, value, rel);
    r2 := value;

    if (r2 < 1) or (r2 > 16) then begin   (*   1 <= r2 <= 16 *)
        r2 := 0;
        errflags := invalid_expr
    end
    else
        r2 := r2 - 1;

            (* put obj into printline  *)
    put_RR_obj( loc_ctr, op, r1, r2);

    loc_ctr := loc_ctr + 1          (* advance loc_ctr *)

end;    (* proc_RR3 *)



procedure proc_D1 ( op_value    : integer;
                    var loc_ctr : integer);

(*  proc_D1 -- process D1-type operands *)

var
    pos,
    tvalue,
    value : integer;

begin    (* proc_D1 *)

    pos := 1;

               (* get reg1 value *)
    r1 := reg_eval( sym_tbl, lit_tbl, operand, pos, tvalue);
    pos := pos + 1;

               (* get operand value *)
    eval( sym_tbl, lit_tbl, operand, pos, value, rel);

    disp1 := value;
    if operand[pos] = ',' then begin       (* get index *)
        pos := pos + 1;               (* skip ',' *)

        x1 := reg_eval( sym_tbl, lit_tbl, operand, pos, tvalue);

    end
    else
        x1 := 0;             (* no index *)

                  (* put object *)
    put_D_obj( loc_ctr, op, r1, x1, disp1, value);

    loc_ctr := loc_ctr + 2        (* advance location counter *)

end;    (* proc_D1 *)



procedure proc_D2 ( op_value    : integer;
                    var loc_ctr : integer);

(*  proc_D2 -- process D2-type operands *)

var
    pos,
    tvalue,
    value : integer;

begin    (* proc_D2 *)

    pos := 1;

               (* get reg1 value *)
    eval( sym_tbl, lit_tbl, operand, pos, tvalue, rel);
    r1 := tvalue;

    if ((r1 < 1) or (r1 > 16)) then begin
        r1 := 0;
        errflags := invalid_expr
    end
    else
        r1 := r1 - 1;

    pos := pos + 1;            (* skip comma *)

               (* get operand value *)
    eval( sym_tbl, lit_tbl, operand, pos, value, rel);

    disp1 := value;
    if operand[pos] = ',' then begin       (* get index *)
        pos := pos + 1;               (* skip ',' *)

        x1 := reg_eval( sym_tbl, lit_tbl, operand, pos, tvalue);

    end
    else
        x1 := 0;             (* no index *)

                  (* put object *)
    put_D_obj( loc_ctr, op, r1, x1, disp1, value);

    loc_ctr := loc_ctr + 2        (* advance location counter *)

end;    (* proc_D2 *)



procedure proc_D3 ( op_value    : integer;
                    var loc_ctr : integer);

(*  proc_D3 -- process D3-type operands *)

var
    pos,
    tvalue,
    value : integer;

begin    (* proc_D3 *)

    pos := 1;
    r1 := 0;             (* RA = 0 for LST, LSTI *)

               (* get operand value *)
    eval( sym_tbl, lit_tbl, operand, pos, value, rel);

    disp1 := value;
    if operand[pos] = ',' then begin       (* get index *)
        pos := pos + 1;               (* skip ',' *)

        x1 := reg_eval( sym_tbl, lit_tbl, operand, pos, tvalue);

    end
    else
        x1 := 0;             (* no index *)

                  (* put object *)
    put_D_obj( loc_ctr, op, r1, x1, disp1, value);

    loc_ctr := loc_ctr + 2        (* advance location counter *)

end;    (* proc_D3 *)



procedure proc_IM ( op_value     : integer;
                    ext_op_value : integer;
                    var loc_ctr  : integer);

(*  proc_IM -- process IM-type operands. like D1 but no index is
    possible. extended opcode value replaces x1. *)

var
    pos,
    tvalue,
    value : integer;

begin    (* proc_IM *)

    pos := 1;
                     (* get reg1 value *)
    r1 := reg_eval( sym_tbl, lit_tbl, operand, pos, tvalue);
    pos := pos + 1;
                     (* get operand value *)
    eval( sym_tbl, lit_tbl, operand, pos, value, rel);
    disp1 := value;
                      (* put object *)
    put_D_obj( loc_ctr, op, r1, ext_op_value, disp1, value);

    loc_ctr := loc_ctr + 2        (* advance location counter *)

end;    (* proc_IM *)



procedure proc_B ( op_value     : integer;
                   var loc_ctr  : integer);

(*  proc_B -- process B-type operands. like ICR but offset in range
    0 <= offset <= 255.  Base reg must be R12, R13, R14, or R15. *)

var
    br1,disp,
    pos,
    tvalue,
    value : integer;

begin    (* proc_B *)

    pos := 1;
               (* get base reg value *)
    br1 := reg_eval( sym_tbl, lit_tbl, operand, pos, tvalue);

    case br1 of
          0..11  : begin
                  errflags := illegal_base;
                  br1 := 0
                  end;

          12..15 : br1 := br1 - 12

        end; (* case for base reg value *)

    op := op + br1;       (* for base rel instructions, add br to op *)

    pos := pos + 1;

               (* get operand value *)
    eval( sym_tbl, lit_tbl, operand, pos, value, rel);
    disp := value;
    if ((disp < 0) or (disp > 255)) then begin
        errflags := invalid_expr;
        disp := 0
    end;
                  (* put object *)
    put_ICR_obj( loc_ctr, op, disp, value);

    loc_ctr := loc_ctr + 1        (* advance location counter *)

end;    (* proc_B *)



procedure proc_BX ( op_value     : integer;
                    ext_op_value : integer;
                    var loc_ctr  : integer);

(*  proc_BX -- process BX-type operands. like RR1 but R1 replaced by
    extended opcode. Base reg value must be added to opcode.  *)

var
    br1,x1,
    pos,
    tvalue,
    value : integer;

begin    (* proc_BX *)

    pos := 1;
               (* get base reg value *)
    br1 := reg_eval( sym_tbl, lit_tbl, operand, pos, tvalue);

    case br1 of
          0..11  : begin
                  errflags := illegal_base;
                  br1 := 0
                  end;

          12..15 : br1 := br1 - 12

       end; (* case for base reg value *)

    op := op + br1;       (* for base rel instructions, add br to op *)

    pos := pos + 1;
                           (* get operand value *)
    x1 := reg_eval( sym_tbl, lit_tbl, operand, pos, value);

                           (* put object *)
    put_RR_obj( loc_ctr, op, ext_op_value, x1);

    loc_ctr := loc_ctr + 1        (* advance location counter *)

end;    (* proc_BX *)




procedure proc_ICR ( op_value    : integer;
                     var loc_ctr : integer);

(*  proc_ICR -- process ICR-type operands *)

var
    pos,
    tvalue,
    value : integer;
    rel : reltype;

begin    (* proc_ICR *)

    pos := 1;
                (* get displacement value *)
    eval( sym_tbl, lit_tbl, operand, pos, value, rel);

    if rel = RELOCAT then begin            (* if reloc, offset is
                                              from current loc_ctr *)
        disp2 := value - loc_ctr;

               (* disp 2 should be in range -128< disp2 <127 *)
        if ((disp2 < -128) or (disp2 > 127)) then begin
            errflags := invalid_expr;
            disp2 := 0
        end
    end

    else begin                (* else absolute address value *)
        disp2 := value - loc_ctr;

               (* disp 2 should be in range -128< disp2 <127 *)
        if ((disp2 < -128) or (disp2 > 127)) then begin
            errflags := invalid_expr;
            disp2 := 0
        end
    end;
                     (* put object into print line *)
    put_ICR_obj( loc_ctr, op, disp2, value);

    loc_ctr := loc_ctr + 1        (* advance location counter *)

end;    (* proc_ICR *)



procedure proc_S1( op_value : integer;
                   var loc_ctr : integer);

(*  proc_S1 -- process S1-type operands : BEX instruction *)

var
    bex,
    value,
    pos   : integer;

begin    (* proc_S1 *)

    pos := 1;

             (* get bex field value *)
    bex := reg_eval( sym_tbl, lit_tbl, operand, pos, value);

            (* put obj into printline  *)
    put_RR_obj( loc_ctr, op, 0, bex);

    loc_ctr := loc_ctr + 1          (* advance loc_ctr *)

end;    (* proc_S1 *)


procedure proc_S2( op_value : integer;
                   var loc_ctr : integer);

(*  proc_S2 -- process S2-type operands : BIF instruction *)

var
    bif,
    value,
    pos   : integer;

begin    (* proc_S2 *)

    pos := 1;

             (* get bif value *)
    eval( sym_tbl, lit_tbl, operand, pos, value, rel);
    bif := value;

            (* put obj into printline  *)
    put_ICR_obj( loc_ctr, op, bif, value);

    loc_ctr := loc_ctr + 1          (* advance loc_ctr *)

end;    (* proc_S2 *)


procedure proc_S3( op_value : integer;
                   ext_op   : integer;
                   var loc_ctr : integer);

(*  proc_S3 -- process S3-type operands : NOP, BPT instruction.
    the ext_op passed forms the end of the instruction. *)

begin    (* proc_S3 *)

            (* put obj into printline  *)
    put_RR_obj( loc_ctr, op, ext_op, ext_op);

    loc_ctr := loc_ctr + 1          (* advance loc_ctr *)

end;    (* proc_S3 *)


procedure proc_S4(    op_value : integer;
                   var loc_ctr : integer);

(*  proc_S4 -- process S4-type operands : URS, XBR instructions *)

var
    r1,
    value,
    pos   : integer;
begin    (* proc_S4 *)
    pos := 1;
                    (* get r1 value *)
    eval( sym_tbl, lit_tbl, operand, pos, value, rel);
    r1 := value;
                   (* put obj into printline  *)
    put_RR_obj( loc_ctr, op, r1, 0);

    loc_ctr := loc_ctr + 1          (* advance loc_ctr *)
end;    (* proc_S4 *)



procedure get_const( var pos     : integer;
                     operand     : strtype;
                     rep         : integer;
                     var con_pos : integer;
                     var con_str : DC_str);

(* get_const fills con_str with characters which represent the constant
   being evaluated *)

var
    temp_pos,
    tvalue,
    hexdig,
    high_byte,
    low_byte,
    i2,
    i1,
    i         : integer;
    r_value   : real;
    ch,
    ch1       : char;
    hex_obj   : char4;
    temp_str  : string[80];
    r_string  : real_hex;
    er_string : ext_real_hex;
    high_ent,
    cons_end  : boolean;

begin
    ch := operand[ pos];       (* get type character *)
    pos := pos + 1;            (* advance to start of literal value *)
    temp_pos := pos;           (* save start pos *)

(* Version 2.7 Change : in WHILE conditions, changed 'pos' to 'temp_pos' *)

    while (rep > 0) and ( con_pos < 17) do begin
        if ((ch in ['C','D','E','F','H','X','c','d','e','f','h','x']) and
                     (operand [temp_pos] = '''')) or
           ((ch in ['A','a']) and (operand[temp_pos] = '(' )) or
            (ch = ':') then begin

        pos := temp_pos;               (* restore start pos - for repeat *)

        case   ch   of           (* check type and get value for string *)

            'D','d' : begin                   (* Decimal constant *)
                  pos := pos + 1;    (* skip quote *)
                  value := char_to_int( operand, pos); (* get integer *)
                  tvalue := value;
                  for i := con_pos + 3 downto con_pos do begin
                      hexdig := tvalue mod 16;
                      tvalue := tvalue div 16;       (* fill 4 chars *)
                      con_str[ i] := hexchar( hexdig)
                  end;
                  put_word_in_memory( (value div 256), (value mod 256));
                  con_pos := con_pos + 4;     (* advance con_pos *)
                  pos := pos + 1

              end; (* case for 'D' *)

            'H','h' : begin                   (* hex constant *)
                  pos := pos + 1;
                  value := char_to_hex( operand, pos); (* get integer *)
                  tvalue := value;
                  for i := con_pos + 3 downto con_pos do begin
                      hexdig := tvalue mod 16;
                      tvalue := tvalue div 16;       (* fill 4 chars *)
                      con_str[ i] := hexchar( hexdig)
                  end;
                  put_word_in_memory( (value div 256), (value mod 256));
                  con_pos := con_pos + 4;     (* advance con_pos *)
                  pos := pos + 1
                  end; (* case for 'H' *)

            'A','a' : begin                (* address constant *)
                  getaddress( operand, pos, value, sym_tbl);
                  tvalue := value;      (* copy value *)
                  for i := con_pos + 3 downto con_pos do begin
                      hexdig := tvalue mod 16;          (* fill 4 chars *)
                      tvalue := tvalue div 16;
                      con_str[ i] := hexchar( hexdig);
                  end;
                  put_word_in_memory( (value div 256), (value mod 256));
                  con_pos := con_pos + 4;          (* advance con_pos *)
                  pos := pos + 1
                  end; (* case for 'A' *)

            'X','x' : begin       (* hex string *)
                  cons_end := false;
                  pos := pos + 1;
                  temp_str := '';
                        (* copy chars until end of string or
                             constant full *)
                  while (con_pos < 17) and (not cons_end) do begin
                      con_str[ con_pos] := operand [pos];
                      temp_str := temp_str + operand[ pos];
                      con_pos := con_pos + 1;
                      pos := pos + 1;
                      if operand[pos] = '''' then
                          cons_end := true
                  end; (* while *)
                  while not cons_end do begin  (* move to end of str *)
                      temp_str := temp_str + operand[pos];
                      pos := pos + 1;
                      cons_end := ( operand[pos] = '''')
                  end; (* while *)
                  i2 := ord(temp_str[0]);
                  for i := 0 to ((i2 div 4) - 1) do begin
                      for i1 := 1 to 4 do
                          hex_obj[i1] := temp_str[i1 + i*4];
                      put_str_in_memory( hex_obj)
                  end; (* for *)
                  hex_obj := '0000';
                  if (i2 mod 4) <> 0 then begin
                      i := (i2 div 4) * 4;
                      for i1 := 1 to (i2 mod 4) do
                          hex_obj[i1] := temp_str[i1 + i];
                      put_str_in_memory( hex_obj)
                  end; (* if *)
                  pos := pos + 1
                  end; (* case for 'X'*)

            'F','f' : begin    (* floating point const *)
                  get_real( operand, pos, r_value);
                  real_to_hex( r_value, r_string);
                  for i1 := 0 to 7 do
                      con_str[con_pos + i1] := r_string[i1 + 1];
                  for i1 := 0 to 1 do begin
                      for i := 1 to 4 do
                          hex_obj[ i] := r_string[ i + 4 * i1];
                      put_str_in_memory( hex_obj)
                  end; (* for *)
                  con_pos := con_pos + 8;          (* advance con_pos *)
                  pos := pos + 1
                  end; (* case for 'F' *)

            'E','e' : begin   (* EFP const *)
                  get_real( operand, pos, r_value);
                  ext_real_to_hex( r_value, er_string);
                  for i1 := 0 to 11 do
                      con_str[con_pos + i1] := er_string[i1 + 1];
                  for i1 := 0 to 2 do begin
                      for i := 1 to 4 do
                          hex_obj[ i] := er_string[ i + 4 * i1];
                      put_str_in_memory( hex_obj)
                  end; (* for *)
                  con_pos := con_pos + 11;          (* advance con_pos *)
                  pos := pos + 1
                  end; (* case for 'E' *)

            'C','c' : begin
                  cons_end := false;
                  pos := pos + 1;         (* skip quote char *)
                  high_ent := false;      (* high byte not set yet *)
                  while (con_pos < 17) and (not cons_end) do begin
                      ch1 := operand[ pos];
                               (* get char not = to ' *)
                      if (ch1 <> '''') then begin
                          value := ord( ch1);
                          if high_ent then
                              low_byte := value        (* low byte *)
                          else
                              high_byte := value;      (* high_byte *)
                          high_ent := not( high_ent);  (* invert flag *)
                          con_str[con_pos] := hexchar( (value div 16));
                          con_str[con_pos + 1] := hexchar( (value mod 16));
                          con_pos := con_pos + 2;
                          pos := pos + 1
                      end
                                 (* check for end of string *)
                      else if operand[pos + 1] <> '''' then
                          cons_end := true
                      else begin     (* else  '' => ' *)
                          value := ord( ch1);
                          if high_ent then
                              low_byte := value        (* low byte *)
                          else
                              high_byte := value;      (* high_byte *)

                          high_ent := not( high_ent);  (* invert flag *)
                          con_str[con_pos] := hexchar( (value div 16));
                          con_str[con_pos + 1] := hexchar( (value mod 16));
                          con_pos := con_pos + 2;
                          pos := pos + 2               (* skip extra ' *)
                      end;
                      if ((not high_ent) and (not cons_end)) then
                          put_word_in_memory( high_byte, low_byte)
                  end; (* while *)
                  while not cons_end do begin   (* move to end of str *)
                      value := ord( operand[pos]);
                      if high_ent then
                          low_byte := value        (* low byte *)
                      else
                          high_byte := value;      (* high_byte *)
                      high_ent := not( high_ent);  (* invert flag *)
                      if not high_ent then
                          put_word_in_memory( high_byte, low_byte);
                      pos := pos + 1;
                      cons_end := ( operand[pos] = '''')
                  end; (* while *)
                  if high_ent then            (* odd number of chars *)
                      put_word_in_memory( high_byte, 0);
                  pos := pos + 1
                  end; (* case for 'C'*)

            ':'    : begin         (* hex integer constant *)
                  value := char_to_hex( operand, pos); (* get integer *)
                  tvalue := value;
                  for i := con_pos + 3 downto con_pos do begin
                      hexdig := tvalue mod 16;
                      tvalue := tvalue div 16;       (* fill 4 chars *)
                      con_str[ i] := hexchar( hexdig)
                  end;
                  put_word_in_memory( (value div 256), (value mod 256));
                  con_pos := con_pos + 4;     (* advance con_pos *)
                  pos := pos + 1
              end; (* case for ':' *)

            else              (* undefined type *)
                rep := 0

            end (* case *)
        end (* then *)

        else begin
            pos := temp_pos - 1;
            eval( sym_tbl, lit_tbl, operand, pos, value, rel);
            tvalue := value;
            for i := con_pos + 3 downto con_pos do begin
                hexdig := tvalue mod 16;
                tvalue := tvalue div 16;       (* fill 4 chars *)
                con_str[ i] := hexchar( hexdig)
            end;
            put_word_in_memory( (value div 256), (value mod 256));
            con_pos := con_pos + 4      (* advance con_pos *)
        end; (* else *)

        rep := rep - 1        (* decrement rep value *)

    end (* while rep > 0 or not full constant *)

end; (* get_const *)


procedure assem_DC( var operand : strtype;
                    var loc_ctr : integer);

(*  assem_DC -- assemble DC constants *)

var
    fill,
    align,
    rep,
    pos,
    con_pos,
    i,
    n,
    k       : integer;
    con_str : DC_str;
    pass1,
    put     : boolean;

begin    (* assem_DC *)

    pos := 1;
    con_pos := 1;
    put := true;
    pass1 := true;                     (* write loc_ctr once only *)

    for k := 1 to 24 do                (* blank constant string *)
        con_str[ k] := blank;

    repeat
        rep := get_rep( pos, operand);

        if pass1 then begin
            i := 3;
            copy_hex( i, 4, loc_ctr);        (* write loc_ctr once *)
            i := i + 1;
            pass1 := false
        end;

        k := pos;                            (* copy pos *)
        length := get_length( k, operand);   (* get len and advance
                                                loc_ctr *)
        loc_ctr := loc_ctr + length * rep;

                 (* fill constant string *)
        get_const( pos, operand, rep, con_pos, con_str);
        pos := pos + 1                     (* skip comma *)

    until (operand[pos - 1] <> ',');     (* loop until no comma *)

    for k := 1 to 16 do
        print_line[ i + k - 1] := con_str[ k]   (* copy str to print line *)

end;    (* assem_DC *)

procedure res_DS( var operand : strtype;
                  var loc_ctr : integer);
                                         (*  res_DS -- reserve DS storage *)
var
    pos,
    rep,
    fill,
    align,
    i,
    k    : integer;
    pass1,
    put  : boolean;

begin    (* res_DS *)

    pos := 1;
    put := true;
    pass1 := true;          (* write loc_ctr once *)

    repeat
        rep := get_rep( pos, operand);         (* get rep *)
        if pass1 then begin
            i := 3;
            copy_hex( i, 4, loc_ctr);          (* place loc_ctr *)
            i := i + 1;
            pass1 := false
        end;

        case operand[pos] of

            'C','c' : begin
                      rep := (rep + 1) div 2;
                      length := 1
                    end;

            'X','x' : begin
                      rep := (rep + 3) div 4;
                      length := 1
                    end;

            'D','d','A','a',
                    'H','h' : length := 1;

            'F','f'         : length := 2;

            'E','e'         : length := 3;

            else
                length := 0

        end; (* case *)

        loc_ctr := loc_ctr + length * rep;    (* advance loc_ctr *)

        for i := 1 to (length * rep) do
            put_word_in_memory ( 0, 0);       (* fill memory with 0000 *)

        pos := pos + 1                        (* skip comma *)

    until (operand[pos - 1] <> ',')

end;    (* res_DS *)



procedure proc_EQU ( var labl : strtype; var operand : strtype;
                     var sym_tbl : Symbol_Table);

(* proc_EQU gets the value of the passed label and places it as the
   addr2 field in the source listing. no other processing is required *)

var
    value,
    pos  : integer;
    rel  : reltype;
    name : labeltype;

begin
    pos := 1;
    get_label( labl, pos, name);             (* get label isolated *)
    sym_tbl_retrieve( name, value, rel, sym_tbl); (* get its value *)
    pos := 30;
    copy_hex( pos, 4, value)         (* place value in addr2 field *)

end; (* proc_EQU *)



procedure proc_ORG ( var loc_ctr : integer; operand : strtype;
                     var sym_tbl : Symbol_Table;
                     var lit_tbl : Literal_Table);

(* proc_ORG advances the loc_ctr to the value derived from the operand
   field. The derived value is written as the addr1 field in the source
   listing. no other processing is required *)

var
    value,
    pos : integer;
    rel  : reltype;

begin
    dump_memory;

    mem_ptr := 0;
    with memory[0] do begin
        hi_byte := 0;
        lo_byte := 0
        end;

    pos := 1;
    eval( sym_tbl, lit_tbl, operand, pos, value, rel);
    if rel = RELOCAT then
        errflags := invalid_expr
    else
        loc_ctr := value;
    pos := 24;
    copy_hex( pos, 4, value);        (* place value in addr1 field *)
    mem_start := value

end; (* proc_ORG *)



procedure proc_Eject;

(* print copies the print_line to the listing file, evaluates the errflags,
   and copies any error messages to the listing file. *)

begin
    clear( print_line);               (* blank print line *)
    writeln( src_lst, chr( 12));      (* write form feed *)
    stmt_num := 6;                    (* init stmt_num at line 8 *)
    writeln( src_lst);                (* write blank line *)
    page_num;                         (* write page number line *)
    writeln( src_lst);                (* write two blank lines *)
    writeln( src_lst);
    writeln( src_lst, header_line)    (* write header line *)

end; (* proc_Eject *)



procedure proc_LTORG(var loc_ctr : integer);

(* proc_LTORG performs the pass2 functions associated with the LTORG
   pseudo-op : aligns the loc_ctr onto a double word boundary, searches
   the literal table for the literals to be placed into the literal pool,
   and lists them in their order in the pool. *)

var
    i,j,
    pos,
    con_pos,
    align,
    fill      : integer;
    found,
    more_lits : boolean;
    con_str   : DC_str;

begin

    j := 3;
    copy_hex( j, 4, loc_ctr);   (* copy aligned loc_ctr to LTORG line *)

    more_lits := true;

    while more_lits do begin            (* search for lit on current
                                           loc_ctr value *)
        print( print_line, errflags);   (* print print line *)
        clear( print_line);

        found := false;                 (* for literal not found *)

        for i := 1 to lit_tbl_len - 1 do begin  (* search table *)

            if lit_tbl[ i].located then       (* if not dumped *)

                if lit_tbl[ i].value = loc_ctr then begin
                                            (* literal found with
                                               value = loc_ctr *)
                    for j := 1 to 24 do
                        con_str[ j] := blank;   (* blank con_str *)

                    found := true;          (* search once more *)

                                    (* copy literal to print_line *)
                    lit_move( lit_tbl[ i].litstr, print_line);

                    lit_tbl[ i].located := false; (* don't check again *)

                    j := 3;
                    copy_hex( j, 4, loc_ctr); (* write loc_ctr to line *)

                    pos := 2;
                    con_pos := 1;     (* get literal constant *)
                    get_const( pos, lit_tbl[ i].litstr, 1, con_pos, con_str);

                    pos := 8;         (* move to print line *)
                    for j := 1 to 16 do
                        print_line[ pos + j - 1] := con_str[ j];

                    pos := 36;                  (* copy line num *)
                    copy_dec( pos, 4, line_no);
                    line_no := line_no + 1;
                    j := i                   (* j := found lit *)

                end (* then *)

        end; (* for *)

        if found then
            loc_ctr := loc_ctr + lit_tbl[ j].len;  (* advance lc *)

        more_lits := found        (* continue if found *)

    end (* while *)

end; (* proc_LTORG *)


procedure end_assembly ( var loc_ctr : integer);

(*  end_assembly -- expand "end assembly" into: *)

var
    i,j,
    pos,
    con_pos,
    value,
    align,
    fill      : integer;
    found,
    more_lits : boolean;
    con_str   : DC_str;
    rel       : reltype;
    name      : labeltype;

begin    (* end_assem *)

    j := 1;                  (* look for start label in operand field *)
    if (operand[1] <> blank) then begin
        get_label( operand, j, name);    (* get value if there is one *)
        sym_tbl_retrieve( name, value, rel, sym_tbl)
    end

    else
        value := loc_ctr;             (* else value = current loc_ctr *)

    j := 3;
    copy_hex( j, 4, value);

    more_lits := true;
    while more_lits do begin              (* dump literals after END *)
        print( print_line, errflags);
        clear( print_line);
        found := false;

        for i := 1 to lit_tbl_len - 1 do begin  (* search table *)

            if lit_tbl[ i].located then        (* if not dumped *)

                if lit_tbl[ i].value = loc_ctr then begin
                                            (* literal found *)
                    for j := 1 to 24 do
                        con_str[ j] := blank;   (* blank con_str *)

                    found := true;          (* search once more *)

                                    (* copy literal to print_line *)
                    lit_move( lit_tbl[ i].litstr, print_line);

                    lit_tbl[ i].located := false; (* don't check again *)

                    j := 3;
                    copy_hex( j, 4, loc_ctr); (* write loc_ctr to line *)

                    pos := 2;
                    con_pos := 1;     (* get literal constant *)
                    get_const( pos, lit_tbl[ i].litstr, 1, con_pos, con_str);

                    pos := 8;         (* move to print line *)
                    for j := 1 to 16 do
                        print_line[ pos + j - 1] := con_str[ j];

                    pos := 36;                  (* copy line num *)
                    copy_dec( pos, 4, line_no);
                    line_no := line_no + 1;
                    j := i                   (* j := found lit *)

                end (* then *)

        end; (* for *)

        if found then
            loc_ctr := loc_ctr + lit_tbl[ j].len;  (* advance lc *)

        more_lits := found        (* continue if found *)

    end; (* while *)

    dump_memory;
    write(src_obj, obj_tail);

                (* write symbol table page *)

    writeln( src_lst, chr( 12));                   (* write form feed *)
    writeln( src_lst);                            (* write blank line *)
                           (* write page number line for symbol table *)
    writeln( src_lst,'                               ',
                     '                    SYMBOL TABL',
                     'E                              ',
                     '                           PAGE ',page_no : 5);
    page_no := page_no + 1;                           (* incr page_no *)
    writeln( src_lst);                       (* write two blank lines *)
    writeln( src_lst);
    header_prep( sym_head);                       (* prep header line *)
    writeln( src_lst, header_line);              (* write header line *)
    writeln( src_lst);                            (* write blank line *)

    for i := 1 to sym_tbl_len - 1 do begin

        write(src_lst, sym_tbl[i].name,'  ');      (* write symbol *)
        writehex( sym_tbl[i].value, 4);       (* write symbol's value *)
        writeln(src_lst)
    end;

                 (* write literal table page *)

    writeln( src_lst, chr( 12));      (* form feed *)

    if lit_tbl_len > 1 then begin     (* write only if literals found *)

        writeln( src_lst);                        (* write blank line *)
                          (* write page number line for literal table *)
        writeln( src_lst,'                               ',
                         '                   LITERAL TABL',
                         'E                              ',
                         '                           PAGE ',page_no : 5);
        page_no := page_no + 1;                       (* incr page_no *)
        writeln( src_lst);                   (* write two blank lines *)
        writeln( src_lst);
        header_prep( lit_head);                   (* prep header line *)
        writeln( src_lst, header_line);          (* write header line *)
        writeln( src_lst);                        (* write blank line *)

        for i := 1 to (lit_tbl_len - 1) do begin
            writeln(src_lst, lit_tbl[i].litstr);
            write(src_lst,'          ');
            writehex( lit_tbl[i].len, 4);
            write( src_lst, '     ');
            writehex( lit_tbl[i].value, 4);
            writeln(src_lst)
        end;

        writeln(src_lst, chr(12))
    end (* then for lit_tbl_len *);

    if err_count = 0 then
        writeln(' Assembly completed. No errors detected')
    else
        writeln(' Assembly completed. Error count = ', err_count:3)


end;    (* end_assembly *)


function date : datetimetype;

(* returns the date in the form '08/31/84'. performs a function call
   to MSDOS to get the value. *)

var
   reg      : regtype;
   y,m,d,w  : datetimetype;
   i        : integer;

begin
    reg.ax := $2A00;
    intr( $21, reg);
    str( reg.cx:4, y);            (* get year value *)
    delete( y, 1, 2);             (* delete century value *)
    str( hi( reg.dx):2, m);       (* get month value *)
    str( lo( reg.dx):2, d);       (* get day value *)
    w := m + '/' + d + '/' + y;
    for i := 1 to 8 do
        if w[i] = ' ' then        (* write 0 for blanks *)
            w[i] := '0';
    date := w
end; (* date *)


function time : datetimetype;

(* returns current time in form '08:13:59'. calls MSDOS to get the
   value. *)

var
   reg      : regtype;
   h,m,s,w  : datetimetype;
   i        : integer;

begin
    reg.ax := $2C00;
    intr( $21, reg);
    str( hi( reg.cx):2, h);         (* get hour value *)
    str( lo( reg.cx):2, m);         (* get minute value *)
    str( hi( reg.dx):2, s);         (* get second value *)
    w := h + ':' + m + ':' + s;
    for i := 1 to 8 do
        if w[i] = ' ' then         (* write 0 for blanks *)
            w[i] := '0';
    time := w
end; (* date *)



procedure init_reg_tbl;

var
    i : integer;
    clock,
    today : datetimetype;


begin

    page_no := 1;               (* start on page 1 *)
    stmt_num := 62;             (* 62 lines per page *)
    line_no := 1;               (* start at input line = 1 *)

    head_str := '  LOC  OBJECT CODE    ADDR1 ADDR2' + '  STMT   SOURCE ' +
                'STATEMENT  ';

    sym_head := 'SYMBOL    VALUE ';
    for i := 17 to 60 do
        sym_head := SYM_HEAD + blank;

    lit_head := 'SYMBOL    LEN   VALUE ';
    for i := 23 to 60 do
        lit_head := lit_head + blank;

    header_line := ' ';
    for i := 2 to 102 do                       (* header line string *)
        header_line := header_line + blank;
    header_line := header_line + 'MVLASM1750-2' + '               ';
    clock := time;                      (* get current time from DOS *)
    for i := 1 to 5 do
        header_line[117 + i - 1] := clock[i];      (* move to header *)
    today := date;                      (* get current date from DOS *)
    for i := 1 to 8 do
        header_line[123 + i - 1] := today[i]       (* move to header *)

end; (* init_reg_tbl *)


begin    (**************    pass_two    **************************)

    loc_ctr := 0;                      (* init loc_ctr *)
    err_count := 0;                    (* zero errors detected yet *)
    reset( src_in);                    (* open source file *)
    init_reg_tbl;                      (* perform inits for pass 2 *)
    header_prep( head_str);            (* put src head into headline *)
    writeln( src_lst);                 (* put blank line *)

    repeat
        readln( src_in, src_stmt); (* read next src_stmt and err_flags
                                         from file( src_cpy) *)
        clear( print_line);           (* blank print line *)
        pseudo_op := '      ';        (* blank pseudo op *)
        errflags := 0;                     (* no errors yet *)
        src_move( src_stmt, print_line);   (* move source *)
        line_ptr := 36;
        copy_dec( line_ptr, 4, line_no);   (* place stmt number *)
        line_no := line_no + 1;

        if (src_stmt[1] <> '*') and (src_stmt[1] <> '.') and
             (src_stmt[1] <> ';')  then begin
                                              (* not a comment line *)
            pos := 1;
            get_field( src_stmt, pos, labl);      (* get label *)
            get_field( src_stmt, pos, operation); (* get operation *)
            get_field( src_stmt, pos, operand);   (* get operand *)

            if op_type( operation, op_value) then begin  (* if MOT *)
                with mach_op_table[op_value] do begin
                    op := op_code;                  (* get opcode *)
                    opr_type := type_operand;     (* get opr type *)
                    ext_op := ext_op_value  (* get ext op *)
                end;
                pos := 1;
                case opr_type of

                    rr1  :  proc_RR1( op_value, loc_ctr);
                                       (* process RR1-type operands *)

                    rr2  :  proc_RR2( op_value, loc_ctr);
                                       (* process RR2-type operands *)

                    rr3  :  proc_RR3( op_value, loc_ctr);
                                       (* process RR3-type operands *)

                    d1   :  proc_D1( op_value, loc_ctr);
                                       (* process D1-type operands *)

                    d2   :  proc_D2( op_value, loc_ctr);
                                       (* process D2-type operands *)

                    d3   :  proc_D3( op_value, loc_ctr);
                                       (* process D3-type operands *)

                    im   :  proc_IM( op_value, ext_op, loc_ctr);
                                       (* process IM-type operands *)

                    icr  :  proc_ICR( op_value, loc_ctr);
                                       (* process ICR-type operands *)

                    b    :  proc_B( op_value, loc_ctr);
                                       (* process B-type operands *)

                    bx   :  proc_BX( op_value, ext_op, loc_ctr);
                                        (* process BX-type operands *)

                    s1   :  proc_S1( op_value, loc_ctr);
                                      (* process S1-type operands *)

                    s2   :  proc_S2( op_value, loc_ctr);
                                      (* process S2-type operands *)

                    s3   :  proc_S3( op_value, ext_op, loc_ctr);
                                      (* process S3-type operands *)

                    s4   :  proc_S4( op_value, loc_ctr)
                                      (* process S4-type operands *)

                end;     (* case *)

            end (* if for in MOT *)

            else begin           (* not in MOT *)

                for index := 1 to 6 do
                    pseudo_op[index] := operation[index];

                if pseudo_op = 'EQU   ' then
                    proc_EQU( labl, operand, sym_tbl)   (* process EQU stmt *)

                else if pseudo_op = 'ORG   ' then
                    proc_ORG( loc_ctr, operand,
                              sym_tbl, lit_tbl)    (* process ORG stmt *)


                else if (pseudo_op = 'DATA  ') or
                        (pseudo_op = 'CONS  ')  then
                    assem_DC( operand, loc_ctr) (* assemble DC constants *)


                else if pseudo_op = 'DW    ' then
                    res_DS( operand, loc_ctr)  (* reserve DS storage *)


                else if pseudo_op = 'END   ' then
                    end_assembly( loc_ctr)   (* end assembly *)


                else if pseudo_op = 'START ' then begin
                    mem_start := 0;
                    mem_ptr   := 0;
                    line_ptr := 3;
                    loc_ctr := 0;  (* reset loc_ctr *)
                    copy_hex( line_ptr, 4, loc_ctr)  (* write to line *)
                end


                else if pseudo_op = 'EJECT ' then
                    proc_Eject  (* process EJECT statement *)


                else if pseudo_op = 'LTORG ' then
                    proc_LTORG( loc_ctr)  (* process LTORG statement *)


                else
                    errflags := invalid_op

            end (* else *)
        end;

        if (pseudo_op <> 'END    ') and (pseudo_op <> 'LTORG ') then
            print( print_line, errflags)

    until ((pseudo_op = 'END   ') or (eof( src_in)) or
           (line_no >= (MAXLINES + 1)))

end;    (* pass_two *)

(************************ end of procedures ***************************)

