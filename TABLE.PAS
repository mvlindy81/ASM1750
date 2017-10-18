
procedure sym_tbl_insert ( labl : strtype; value : integer;
                            rel : reltype; var sym_tbl : Symbol_Table);

(* sym_tbl_insert places the passed label at the end of the symbol
   table, sets the value and rel fields to the passed items and label
   as the name for that entry. global variable sym_tbl_len is used
   to denote the next available table entry. *)

var
    tbl_index,
    index     : integer;
    symbolin,
    symbolout : labeltype;

begin
    index := 1;                                       (* init indices *)
    tbl_index := sym_tbl_len;

    (* copy passed label up to the first eight chars *)

    for index := 1 to 8 do
        symbolin[index] := labl[index];

    capitalize(symbolin,symbolout);

    sym_tbl[tbl_index].name := symbolout;                 (* set name *)
    sym_tbl[tbl_index].value := value;                  (* copy value *)
    sym_tbl[tbl_index].rel := rel;                       (* copy rel  *)

    sym_tbl_len := sym_tbl_len + 1           (* advance table pointer *)

end; (* sym_tbl_insert *)


procedure error (errornum : integer);

(* error prints a message for the passed error value *)

begin
    case errornum of
        invalid_literal : writeln(src_lst,' Invalid literal');
        invalid_term    : writeln(src_lst,' Invalid term');
        no_source       : writeln(src_lst,' Empty source file');
        invalid_op      : writeln(src_lst,' Invalid op code field');
        invalid_expr    : writeln(src_lst,' Invalid expression');
        lit_not_found   : writeln(src_lst,' Literal not found in table');
        sym_not_found   : writeln(src_lst,' Symbol not defined');
        invalid_sym     : writeln(src_lst,' Symbol did not start with letter');
        invalid_delim   : writeln(src_lst,' Invalid delimiter for this',
                                          ' literal type');
        illegal_expr    : writeln(src_lst,' Invalid expression in operand',
                                          ' field');
        invalid_immediate : writeln(src_lst, ' Immediate value out of range ',
                                             'or not absolute');
        else writeln(src_lst,' Error detected')
    end (* case *)

end; (* error *)


function get_lit ( var op_field : strtype; var pos : integer;
                    var retlit : strtype) : boolean;

(* get_lit reads the op_field until a literal of the form =t'  ' is
   found. the text portion including the = is returned. get_lit returns
   pos at the char following the final unmatched quote. if no
   literal is found, the first char of get_lit will be blank *)

var
    index,
    postemp : integer;
    endlit  : boolean;

begin
    postemp := pos;
    retlit[1] := blank;
    get_lit := true;

    (* search until a blank,tab,=, or end of string *)

    while ((postemp <= MAXSTR - 8) and (op_field[postemp] <> blank)
            and (op_field[postemp] <> chr(9))
            and (op_field[postemp] <> '=')) do
        postemp := postemp + 1;

    if op_field[postemp] = '=' then begin      (* literal encountered *)
        index := 1;
        retlit[index] := op_field[postemp];       (* copy = char *)
        retlit[index+1] := op_field[postemp+1];   (* copy type char *)
        index := index + 2;
        postemp := postemp + 2;

        if op_field[postemp] = '''' then begin    (* ' should be next *)
            retlit[index] := op_field[postemp];
            endlit := false;

            while not endlit do begin
                index := index + 1;
                postemp := postemp + 1;
                retlit[index] := op_field[postemp];

                if op_field[postemp] = '''' then
                    (* ' found -- does it have another following ? *)

                    if (op_field[postemp + 1] = '''') and
                              (retlit[2] in ['C','c'])      then begin

                      (* yes -- copy and continue search for endquote *)

                        index := index + 1;
                        postemp := postemp + 1;
                        retlit[index] := op_field[postemp]
                    end (* if *)

                    else                      (* end of literal found *)
                        endlit := true
                else begin
                end
            end (* while *);

            for index := index + 1 to MAXSTR do
                retlit[index] := blank    (* pad with blanks *)

        end (* if for first ' *)

        else if op_field[postemp] = '(' then begin
            retlit[index] := op_field[postemp];
            endlit := false;

            while not endlit do begin
                index := index + 1;
                postemp := postemp + 1;
                retlit[index] := op_field[postemp];
                if op_field[postemp] = ')' then
                                    (* ')' found -- end of address literal *)
                        endlit := true
            end (* while *);

            for index := index + 1 to MAXSTR do
                retlit[index] := blank    (* pad with blanks *)

        end (* if for '(' *)

        else begin
            postemp := postemp + 1;
            get_lit := false;
            errflags := invalid_literal       (* literal did not have ' *)
        end                                   (* or ) after type char   *)

    end (* if for '=' *)

    else
        get_lit := false;

    pos := postemp + 1


end; (* get_lit *)


