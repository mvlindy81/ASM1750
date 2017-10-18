
(**********************************************************************)
(*                                                                    *)
(*                    Quick Sort Procedures                           *)
(*                                                                    *)
(*     From: PASCAL Programming and Problem Solving                   *)
(*       By: Sanford Leestma and Larry Nyhoff                         *)
(*           Adapted for the assembler by Mark V. Lindberg            *)
(*                                                                    *)
(**********************************************************************)


procedure Split (var x    : Symbol_Table;
                 low,high : integer;
                 var mid  : integer);

(* procedure to rearrange x[low],. . .,x[high] so that one item
   is properly postitioned; it returns the rearranged list and the
   final position mid of that item                                  *)

var
    left,                       (* index for searching from the left *)
    right : integer;           (* index for searching from the right *)
    tempitem : Symbol_Record;    (* temporary item used for interchanging *)

begin   (*  Split *)
  (* initialize indices for left and right searches *)
    left := low;
    right := high;

    (* carry out the searches *)
    while left < right do begin       (* while searches have not met *)

                (* search from the right *)
        while x[right].name > x[low].name do
            right := right - 1;

                (* search from the left *)
        while (left < right) and (x[left].name <= x[low].name) do
            left := left + 1;

                (* interchange items if searches have not met *)
        if left < right then begin
            tempitem := x[left];
            x[left] := x[right];
            x[right] := tempitem
        end (* if *)
    end (* while *);

    (* end of searches; place selected item in proper position *)
    mid := right;
    tempitem := x[mid];
    x[mid] := x[low];
    x[low] := tempitem

end; (* Split *)


procedure quicksort ( var x : Symbol_Table; low,high : integer);

(* procedure to quicksort x[low], . . ., x[high] *)

var
    mid : integer;               (* final position of selected item *)

begin (* QuickSort *)

    if low < high then begin         (* list has more than one item *)

        split( x, low, high, mid);       (* split into two sublists *)

        quicksort( x, low, mid - 1);          (* sort first sublist *)

        quicksort( x, mid + 1, high)         (* sort second sublist *)

    end (* if *)

end; (* QuickSort *)

