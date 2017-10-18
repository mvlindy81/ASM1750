
procedure eval ( var sym_tbl : Symbol_Table;
                 var lit_tbl : Literal_Table;
                     str     : strtype;
                 var pos     : integer;
                 var value   : integer;
                 var rel     : reltype);

(* eval takes the input string starting at pos and evaluates the
   expression there, returning an integer and relocation value for
   the expression. *)

var
    literal   : strtype;    (* literal string if expression has one *)
    rel_sum,                     (* sum of rel terms. +1 on adds,
                                    -1 on subtracts. valid for rel_sum
                                    = 0 or 1 only *)
    p_value,                     (* primary value *)
    term_value : integer;        (* term value - for mult/div ops *)

    op,                          (* operation char = + or - *)
    term_op   : char;            (* term operator = * or / *)

    term_rel,                    (* term rel from term expr *)
    p_rel     : reltype;         (* p_rel from primary expr *)

    null      : boolean;         (* null for dummy function assign *)

begin
    if (str[pos] in [ ',', '(', ')']) or (pos > MAXSTR - 8) then begin
        value := 0;              (* default value = 0 on omitted op *)
        rel_sum := 0
    end
    else if (str[pos] = '=') then begin        (* literal pool entry *)
        null := get_lit( str, pos, literal);
        lit_tbl_retrieve( literal, value, lit_tbl);
        rel_sum := 1
    end (* else if *)

    else begin                           (* else other terms *)
        pos := pos - 1;
        value := 0;
        op := '+';
        rel_sum := 0;

        repeat                          (* add / subtract loop *)
            term_value := 1;
            term_op := '*';
            term_rel := ABSOLUT;

            repeat                      (* mult / div loop *)
                if (term_rel = RELOCAT) then
                    errflags := illegal_expr;

                pos := pos + 1;
                                      (* get next primary *)
                p_value := primary( sym_tbl, str, pos, p_rel);

                if (term_op = '*') then     (* mult or div *)
                    term_value := term_value * p_value
                else
                    term_value := term_value div p_value;

                term_rel := p_rel;
                term_op := str[pos]     (* get next operator *)

            until ((term_op <> '*') and (term_op <> '/'));

            if (op = '+') then begin               (* add op *)
                value := value + term_value;
                if (term_rel = RELOCAT) then
                    rel_sum := rel_sum + 1
            end
            else begin                            (* subtract op *)
                value := value - term_value;
                if (term_rel = RELOCAT) then
                    rel_sum := rel_sum - 1
            end;

            op := str[pos]                         (* get next op *)

        until (( op <> '+') and (op <> '-')) (* loop until not +/- *)
    end;

    if (rel_sum = 0) then
        rel := ABSOLUT

    else if (rel_sum = 1) then
        rel := RELOCAT

    else                           (* rel_sum < 0 or > 1 *)
        errflags := illegal_expr

end; (* eval *)


function reg_eval ( var sym_tbl : Symbol_Table;
                    var lit_tbl : Literal_Table;
                        str     : strtype;
                    var pos     : integer;
                    var value   : integer) : integer;

(* reg_eval takes the input string starting at pos and evaluates the
   expression there, returning an integer between 0 and 15 for
   the expression. *)

var
    literal   : strtype;    (* literal string if expression has one *)
    rel_sum,                     (* sum of rel terms. +1 on adds,
                                    -1 on subtracts. valid for rel_sum
                                    = 0  only *)
    p_value,                     (* primary value *)
    term_value : integer;        (* term value - for mult/div ops *)

    op,                          (* operation char = + or - *)
    term_op   : char;            (* term operator = * or / *)

    term_rel,                    (* term rel from term expr *)
    p_rel     : reltype;         (* p_rel from primary expr *)

begin
    if (str[pos] in [ ',', '(', ')']) or (pos > MAXSTR - 8) then begin
        value := 0;              (* default value = 0 on omitted op *)
        rel_sum := 0
    end

    else if (str[pos] = '=') then         (* can't have literal
                                                   in reg expr *)
        rel_sum := 1

    else begin                           (* else other terms *)
        pos := pos - 1;
        value := 0;
        op := '+';
        rel_sum := 0;

        repeat                          (* add / subtract loop *)
            term_value := 1;
            term_op := '*';
            term_rel := ABSOLUT;

            repeat                      (* mult / div loop *)
                if (term_rel = RELOCAT) then
                    errflags := illegal_expr;

                pos := pos + 1;
                                      (* get next primary *)
                p_value := primary( sym_tbl, str, pos, p_rel);

                if (term_op = '*') then     (* mult or div *)
                    term_value := term_value * p_value
                else
                    term_value := term_value div p_value;

                term_rel := p_rel;
                term_op := str[pos]     (* get next operator *)

            until ((term_op <> '*') and (term_op <> '/'));

            if (op = '+') then begin               (* add op *)
                value := value + term_value;
                if (term_rel = RELOCAT) then
                    rel_sum := rel_sum + 1
            end
            else begin                            (* subtract op *)
                value := value - term_value;
                if (term_rel = RELOCAT) then
                    rel_sum := rel_sum - 1
            end;

            op := str[pos]                         (* get next op *)

        until (( op <> '+') and (op <> '-')) (* loop until not +/- *)
    end;

    if (rel_sum = 0) and (value >= 0) and (value < 16) then
        reg_eval := value

    else begin
        reg_eval := 0;
        errflags := illegal_expr
    end

end; (* reg_eval *)
