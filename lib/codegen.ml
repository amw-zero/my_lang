open Core

let print_list l = String.concat "\n" l

let rec string_of_boolexp t = match t with
  | BTrue -> "true"
  | BFalse -> "false"
  | BIf (t1, t2, t3) -> Printf.sprintf "if %s then %s else %s" (string_of_boolexp t1) (string_of_boolexp t2) (string_of_boolexp t3)

let string_of_tstype tst = match tst with
  | TSTNumber -> "number"
  | TSTCustom c -> c

let string_of_tsclassdef cd = match cd with
  | TSClassProp(n, typ) -> Printf.sprintf "%s: %s" n (string_of_tstype typ)
  | CDSLExpr(_) -> "CDSLExpr remove"

let string_of_type t = match t with
  | STInt -> "Int"
  | STCustom s -> s

let string_of_typed_attr ta =
  Printf.sprintf "%s: %s" ta.name ta.typ

let rec string_of_ts_expr e = match e with
  | TSIden(i, t) -> (match t with
    | Some(t) -> Printf.sprintf "%s: %s" i (string_of_tstype t)
    | None -> Printf.sprintf "%s" i)
  | TSNum(n) -> string_of_int n
  | TSLet(v, ie) -> "let" ^ v ^ " = " ^ string_of_ts_expr ie
  | TSStmtList(ss) -> String.concat "\n" (List.map string_of_ts_expr ss)
  | TSClass(n, ds) -> Printf.sprintf "class %s{%s}" n (String.concat "\n" (List.map string_of_tsclassdef ds))
  | TSMethodCall(recv, m, args) -> Printf.sprintf "%s.%s(%s)" recv m (List.map string_of_ts_expr args |> print_list)
  | SLExpr(_) -> "SLExpr"

let rec string_of_expr e = match e with
  | TS(tse) -> String.concat "\n" (List.map string_of_ts_expr tse)
  | Let(name, body) -> "let " ^ name ^ " = " ^ string_of_expr body
  | Iden(i, too) -> (match too with
    | Some(t) -> Printf.sprintf "%s: %s" i (string_of_type t)
    | None -> i)
  | Num(n) -> string_of_int n
  | BoolExp(_) -> "boolexp"
  | StmtList(ss) -> string_of_stmt_list ss
  | Domain(n, defs) -> "domain " ^ n ^ String.concat "\n" (List.map string_of_domain_def defs) ^ "\nend\n"
  | Call(n, args) -> n ^ "(" ^ String.concat ", " (List.map string_of_expr args) ^ ")"
  | Env(es) -> String.concat "\n\n" (List.map (fun e -> "environment:\n\t" ^ Printf.sprintf "%s: %s\n" e.ename (string_of_stmt_list e.ebody)) es) ^ "\nend"
  | FuncDef(name, args, body) -> Printf.sprintf "def %s(%s):\n\t%s" name (String.concat ", " (List.map string_of_typed_attr args)) (string_of_stmt_list body)
  and string_of_domain_def def = match def with
  | DomainAttr({ name; typ }) -> Printf.sprintf "%s: %s" name typ
  | DomainAction({ aname; body; args}) -> Printf.sprintf "def %s(%s):\n\t%s" aname (String.concat ", " (List.map string_of_typed_attr args)) (string_of_expr body)
  and string_of_stmt_list sl = String.concat "\n" (List.map string_of_expr sl)