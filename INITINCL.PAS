

procedure initialize;

(* initialize performs the initialization tasks of setting the symbol
   and literal tables to a predefined state. initialize will be called
   one time upon start of the assembly of a given program. *)

var
    indx1 : integer;
    blank80 : strtype;

begin
    for indx1 := 1 to MAXSYM do
    begin
        sym_tbl[indx1].name := blank8;  (* set label to blanks *)
        sym_tbl[indx1].rel := RELOCAT;
        sym_tbl[indx1].value := 0
    end (* for  *);

    for indx1 := 1 to MAXSTR do
        blank80[indx1] := blank;

    for indx1 := 1 to MAXLITS do begin
        lit_tbl[indx1].litstr := blank80; (* blank literal entry *)
        lit_tbl[indx1].located := false;
        lit_tbl[indx1].value := 0
    end;

    for indx1 := 1 to MAXLINES do      (* set errorlist = no errors *)
        errorlist[indx1] := 0;

               (* build uppercase letter set variable *)
    ucletters := ['A','B','C','D','E','F','G','H','I','J','K','L','M',
                'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];

               (* build lowercase letter set variable *)
    smletters := ['a','b','c','d','e','f','g','h','i','j','k','l','m',
                'n','o','p','q','r','s','t','u','v','w','x','y','z'];

               (* build digit set variable *)
    digits := ['0','1','2','3','4','5','6','7','8','9'];


end (* initialize *);

