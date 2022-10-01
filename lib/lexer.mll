{
open Parser

class lexer_context =
object
  val lexers = Stack.create ()

  method push_lexer (lexer : Lexing.lexbuf -> Parser.token) =
    Stack.push lexer lexers

  method pop_lexer =
    (* We've a stack of functions, so we don't want to apply the result. *)
    ignore (Stack.pop lexers) [@warning "-5"]

  method next_lexer =
    Stack.top lexers
end

let fresh_context () = new lexer_context

exception SyntaxError of string
}

let whitespace = [' ' '\t' '\r' '\n']
let iden = ['_' 'a'-'z' 'A'-'Z'] ['_' 'a'-'z' 'A'-'Z' '0'-'9']*
let num = ['0'-'9']

rule read ctx = parse
  | eof               { EOF }
  | whitespace+       { read ctx lexbuf }
  | "true"            { TRUE }
  | "false"           { FALSE }
  | "if"              { IF }
  | "then"            { THEN }
  | "else"            { ELSE }
  | '('               { LPAREN }
  | ')'               { RPAREN }
  | ':'               { COLON }
  | "="               { EQUALS }
  | "let"             { LET }
  | "end"             { END }  
  | "typescript"      { print_endline "pushing TS context"; ctx#push_lexer (read_ts ctx); TYPESCRIPT }
  | num               { NUMBER (Lexing.lexeme lexbuf |> int_of_string) }
  | iden              { IDEN (Lexing.lexeme lexbuf) }
  | _                 { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
and read_ts ctx = parse
  | eof               { EOF }
  | whitespace+       { read_ts ctx lexbuf }
  | ':'               { print_endline "TS Parsing :"; COLON }
  | "="               { EQUALS }
  | "let"             { LET }
  | "tsend"            { print_endline "popping ts ctx tsend"; ctx#pop_lexer; TSEND }
  | "end"             { print_endline "popping ts ctx"; ctx#pop_lexer; END }
  | num               { print_endline "TS num"; NUMBER (Lexing.lexeme lexbuf |> int_of_string) }
  | iden              { IDEN (Lexing.lexeme lexbuf) }
  | _                 { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }

{
 let lexer : lexer_context
         -> (Lexing.lexbuf -> Parser.token) =
  fun ctxt ->
   fun lexbuf -> print_endline "Next context?"; ctxt#next_lexer lexbuf
}
