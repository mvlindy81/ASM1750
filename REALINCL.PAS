
type
    real_hex = array [1..8] of char;   (* string to represent a four
                                          byte real number. structured as
                                          three bytes of mantissa and one
                                          byte of exponent. *)

    ext_real_hex = array [1..12] of char;   (* string to represent a four
                                               byte real number. structured as
                                               three bytes of mantissa, one
                                               byte of exponent,and two more
                                               bytes of mantissa. *)


procedure create_exponent (     exponent : integer;
                            var real_str : real_hex);

(* create_exponent takes the passed exponent (integer) and places it into the
   returned string as the exponent for a floating point number represented
   in hex. the conversion from integer to hex character is done by hexchar
   function *)

var dig1, dig2 : integer;

begin

    dig1 := exponent;              (* copy passed exponent to local variable *)

    if dig1 >= 0 then begin        (* positive exponent case *)
        dig2 := dig1 div 16;
        dig1 := dig1 mod 16
    end

    else begin                   (* negative exponent case *)
        dig1 := - (dig1 + 1);
        dig2 := 15 - (dig1 div 16);
        dig1 := 15 - (dig1 mod 16)
    end;

    real_str[ 7] := hexchar ( dig2);
    real_str[ 8] := hexchar ( dig1)

end;  (* create_exponent *)



procedure real_to_hex ( in_val : real; var ret_str : real_hex);

(* real_to_hex converts the input real number to the hex representation
   used by MIL-STD-1750A. The converted string is returned by the
   procedure in ret_str *)

const
    zero_string = '00000000';

var
    i1,                      (* loop counter     *)
    i2,                      (* exponent counter *)
    i3 : integer;
    temp1, temp2 : real;
    temp_str : real_hex;

begin
    temp1 := in_val;

    if temp1 = 0.0 then                     (* 0 is special case *)
        ret_str := zero_string

    else if temp1 > 0.0 then
    begin                                   (* positive input value *)

        if temp1 >= 1.0 then begin          (* input value >= 1.0 *)
            i2 := 0;
            while temp1 >= 1.0 do begin
                temp1 := temp1 / 2.0;
                i2 := i2 + 1
            end
        end
        else begin                          (* input value < 1.0
                                                         and > 0.0 *)
            i2 := 0;
            while temp1 < 0.5 do begin
                temp1 := temp1 * 2.0;
                i2 := i2 - 1
            end
        end;

        create_exponent ( i2, temp_str); (* move exponent to temp string *)

           (* now, input value has been scaled to 1.0 < temp1 <= 0.5
              multiply value by 16 six times to get six hex digits *)

        temp1 := temp1 / 2.0;             (* adjust the value first to
                                             be in range 0.5 < temp1 <= 0.25
                                             so that first digit is 4,5,6, or
                                             7, which is a normalized
                                             real number. *)

        for i1 := 1 to 6 do begin
                                           (* fill six digits *)
            temp2 := 16 * temp1;
            i3    := Trunc( temp2);
            temp1 := Frac ( temp2);
            temp_str[ i1] := hexchar ( i3)

        end (* for loop *);

        ret_str := temp_str        (* assign temp string to returned string *)

    end        (* else for positive input *)


    else begin                              (* negative input value *)

        if temp1 < -1.0 then begin          (* input value < -1.0 *)
            i2 := 0;
            while temp1 < -1.0 do begin
                temp1 := temp1 / 2.0;
                i2 := i2 + 1
            end
        end
        else begin                          (* input value >= -1.0
                                                         and < 0.0 *)
            i2 := 0;
            while temp1 >= -0.5 do begin
                temp1 := temp1 * 2.0;
                i2 := i2 - 1
            end
        end;

        create_exponent ( i2, temp_str);   (* move exponent to temp string *)

            (* now, input value has been scaled to -0.5 < temp1 <= -1.0
               since negative values are equivalent to -1 + positive
               part, convert value to a positive number and make the
               first hex digit of the converted value negative by adding
               8 to it. then multiply value by 16 five times to get
               the other five hex digits *)

        temp1 := (1.0 + temp1) / 2.0;       (* make value  >= 0.0 and < 0.25 *)

        temp2 := 16 * temp1;                (* scale first digit value *)
        i3    := 8 + Trunc( temp2);   (* adding 8 makes first digit negative *)
        temp1 := Frac ( temp2);             (* adjust for next value *)
        temp_str[ 1] := hexchar ( i3);   (* copy first digit *)


        for i1 := 2 to 6 do begin           (* copy other digits - same as
                                               positive value case *)
            temp2 := 16 * temp1;
            i3    := Trunc( temp2);
            temp1 := Frac ( temp2);
            temp_str[ i1] := hexchar ( i3)
        end;

        ret_str := temp_str

    end (* else for negative value *)


end (* real_to_hex *);



procedure ext_create_exponent (     exponent : integer;
                                var real_str : ext_real_hex);

(* ext_create_exponent takes the passed exponent (integer) and places it into
   the returned string as the exponent for a floating point number represented
   in hex. the conversion from integer to hex character is done by hexchar
   function *)

var dig1, dig2 : integer;

begin

    dig1 := exponent;              (* copy passed exponent to local variable *)

    if dig1 >= 0 then begin        (* positive exponent case *)
        dig2 := dig1 div 16;
        dig1 := dig1 mod 16
    end

    else begin                   (* negative exponent case *)
        dig1 := - (dig1 + 1);
        dig2 := 15 - (dig1 div 16);
        dig1 := 15 - (dig1 mod 16)
    end;

    real_str[ 7] := hexchar ( dig2);
    real_str[ 8] := hexchar ( dig1)

end;  (* ext_create_exponent *)



procedure ext_real_to_hex ( in_val : real; var ret_str : ext_real_hex);

(* ext_real_to_hex converts the input real number to the hex representation
   used by MIL-STD-1750A for extended precision floating point numbers.
   The converted string is returned by the procedure in ret_str *)

const
    zero_string = '000000000000';

var
    i1,                      (* loop counter     *)
    i2,                      (* exponent counter *)
    i3 : integer;
    temp1, temp2 : real;
    temp_str : ext_real_hex;

begin
    temp1 := in_val;

    if temp1 = 0.0 then                     (* 0 is special case *)
        ret_str := zero_string

    else if temp1 > 0.0 then
    begin                                   (* positive input value *)

        if temp1 >= 1.0 then begin          (* input value >= 1.0 *)
            i2 := 0;
            while temp1 >= 1.0 do begin
                temp1 := temp1 / 2.0;
                i2 := i2 + 1
            end
        end
        else begin                          (* input value < 1.0
                                                         and > 0.0 *)
            i2 := 0;
            while temp1 < 0.5 do begin
                temp1 := temp1 * 2.0;
                i2 := i2 - 1
            end
        end;

        ext_create_exponent ( i2, temp_str); (* move exponent to temp string *)

           (* now, input value has been scaled to 1.0 < temp1 <= 0.5
              multiply value by 16 ten times to get ten hex digits *)

        temp1 := temp1 / 2.0;             (* adjust the value first to
                                             be in range 0.5 < temp1 <= 0.25
                                             so that first digit is 4,5,6, or
                                             7, which is a normalized
                                             real number. *)

        for i1 := 1 to 6 do begin
                                           (* fill six digits *)
            temp2 := 16 * temp1;
            i3    := Trunc( temp2);
            temp1 := Frac ( temp2);
            temp_str[ i1] := hexchar ( i3)

        end (* for loop *);

        for i1 := 9 to 12 do begin
                                           (* fill last four digits *)
            temp2 := 16 * temp1;
            i3    := Trunc( temp2);
            temp1 := Frac ( temp2);
            temp_str[ i1] := hexchar ( i3)

        end (* for loop *);


        ret_str := temp_str        (* assign temp string to returned string *)

    end        (* else for positive input *)


    else begin                              (* negative input value *)

        if temp1 < -1.0 then begin          (* input value < -1.0 *)
            i2 := 0;
            while temp1 < -1.0 do begin
                temp1 := temp1 / 2.0;
                i2 := i2 + 1
            end
        end
        else begin                          (* input value >= -1.0
                                                         and < 0.0 *)
            i2 := 0;
            while temp1 >= -0.5 do begin
                temp1 := temp1 * 2.0;
                i2 := i2 - 1
            end
        end;

        ext_create_exponent ( i2, temp_str); (* move exponent to temp string *)

            (* now, input value has been scaled to -0.5 < temp1 <= -1.0
               since negative values are equivalent to -1 + positive
               part, convert value to a positive number and make the
               first hex digit of the converted value negative by adding
               8 to it. then multiply value by 16 five times to get
               the other five hex digits *)

        temp1 := (1.0 + temp1) / 2.0;       (* make value  >= 0.0 and < 0.25 *)

        temp2 := 16 * temp1;                (* scale first digit value *)
        i3    := 8 + Trunc( temp2);   (* adding 8 makes first digit negative *)
        temp1 := Frac ( temp2);             (* adjust for next value *)
        temp_str[ 1] := hexchar ( i3);   (* copy first digit *)


        for i1 := 2 to 6 do begin           (* copy other digits - same as
                                               positive value case *)
            temp2 := 16 * temp1;
            i3    := Trunc( temp2);
            temp1 := Frac ( temp2);
            temp_str[ i1] := hexchar ( i3)
        end;

        for i1 := 9 to 12 do begin
                                           (* fill last four digits *)
            temp2 := 16 * temp1;
            i3    := Trunc( temp2);
            temp1 := Frac ( temp2);
            temp_str[ i1] := hexchar ( i3)

        end (* for loop *);

        ret_str := temp_str

    end (* else for negative value *)


end (* ext_real_to_hex *);

