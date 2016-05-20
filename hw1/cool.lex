/*
 *  The scanner definition for COOL.
 */

import java_cup.runtime.Symbol;

%%

%{

/*  Stuff enclosed in %{ %} is copied verbatim to the lexer class
 *  definition, all the extra variables/functions you want to use in the
 *  lexer actions should go here.  Don't remove or modify anything that
 *  was there initially.  */

    // Max size of string constants
    static int MAX_STR_CONST = 1025;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();

	int nestedCommentCount = 0;
	
	boolean isEscaped = false;

    private int curr_lineno = 1;
    int get_curr_lineno() {
	return curr_lineno;
    }

    private AbstractSymbol filename;

    void set_filename(String fname) {
	filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
	return filename;
    }
%}

%init{

/*  Stuff enclosed in %init{ %init} is copied verbatim to the lexer
 *  class constructor, all the extra initialization you want to do should
 *  go here.  Don't remove or modify anything that was there initially. */

    // empty for now
%init}

%eofval{

/*  Stuff enclosed in %eofval{ %eofval} specifies java code that is
 *  executed when end-of-file is reached.  If you use multiple lexical
 *  states and want to do something special if an EOF is encountered in
 *  one of those states, place your code in the switch statement.
 *  Ultimately, you should return the EOF symbol, or your lexer won't
 *  work.  */

    switch(yy_lexical_state) {
    case YYINITIAL:
		/* nothing special to do in the initial state */
		break;
		/* If necessary, add code for other states here, e.g:
		   case COMMENT:
		   ...
		   break;
		*/
	case COMMENT:
		yybegin(EOF_ENCOUNTERED);
		return new Symbol(TokenConstants.ERROR, "Error: EOF in comment");
	case STRING:
		yybegin(EOF_ENCOUNTERED);
		return new Symbol(TokenConstants.ERROR, "Error: EOF in string constant");
	case EOF_ENCOUNTERED:
		break;
	default:
		break;
    }
    return new Symbol(TokenConstants.EOF);
%eofval}

%class CoolLexer
%cup

%state STRING
%state COMMENT
%state STRING_BACKSLASHESCAPED
%state STRING_NULLINSTRING
%state STRING_STRINGTOOLONG
%state EOF_ENCOUNTERED
%%

<YYINITIAL>"=>"	{ return new Symbol(TokenConstants.DARROW); }

<YYINITIAL> "*" { return new Symbol(TokenConstants.MULT); }

<YYINITIAL> ";" { return new Symbol(TokenConstants.SEMI); }

<YYINITIAL> ":" { return new Symbol(TokenConstants.COLON); }

<YYINITIAL> "<-" { return new Symbol(TokenConstants.ASSIGN); }

<YYINITIAL> "@" { return new Symbol(TokenConstants.AT); }

<YYINITIAL> "+" { return new Symbol(TokenConstants.PLUS); }

<YYINITIAL> "-" { return new Symbol(TokenConstants.MINUS); }

<YYINITIAL> "/" { return new Symbol(TokenConstants.DIV); }

<YYINITIAL> "~" { return new Symbol(TokenConstants.NEG); }

<YYINITIAL> "<" { return new Symbol(TokenConstants.LT); }

<YYINITIAL> "<=" { return new Symbol(TokenConstants.LE); }

<YYINITIAL> "=" { return new Symbol(TokenConstants.EQ); }

<YYINITIAL> "(" { return new Symbol(TokenConstants.LPAREN); }

<YYINITIAL> ")" { return new Symbol(TokenConstants.RPAREN); } 

<YYINITIAL> "{" { return new Symbol(TokenConstants.LBRACE); }

<YYINITIAL> "}" { return new Symbol(TokenConstants.RBRACE); }

<YYINITIAL> "," {return new Symbol(TokenConstants.COMMA); }

<YYINITIAL> "." {return new Symbol(TokenConstants.DOT); }

<YYINITIAL> [t][Rr][Uu][Ee] {return new Symbol(TokenConstants.BOOL_CONST, new Boolean(true));} 

<YYINITIAL> [f][Aa][Ll][Ss][Ee] {return new Symbol(TokenConstants.BOOL_CONST, new Boolean(false));}

<YYINITIAL> [Cc][Ll][Aa][Ss][Ss] {return new Symbol(TokenConstants.CLASS);}

<YYINITIAL> [Ee][Ll][Ss][Ee] {return new Symbol(TokenConstants.ELSE);}

<YYINITIAL> [Ff][Ii] {return new Symbol(TokenConstants.FI);}

<YYINITIAL> [Ii][Ff] {return new Symbol(TokenConstants.IF);}

<YYINITIAL> [Ii][Nn] {return new Symbol(TokenConstants.IN);}

<YYINITIAL> [Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss] {return new Symbol(TokenConstants.INHERITS);}

<YYINITIAL> [Ii][Ss][Vv][Oo][Ii][Dd] {return new Symbol(TokenConstants.ISVOID);}

<YYINITIAL> [Ll][Ee][Tt] {return new Symbol(TokenConstants.LET);}

<YYINITIAL> [Ll][Oo][Oo][Pp] {return new Symbol(TokenConstants.LOOP);}

<YYINITIAL> [Pp][Oo][Oo][Ll] {return new Symbol(TokenConstants.POOL);}

<YYINITIAL> [Tt][Hh][Ee][Nn] {return new Symbol(TokenConstants.THEN);}

<YYINITIAL> [Ww][Hh][Ii][Ll][Ee] {return new Symbol(TokenConstants.WHILE);}

<YYINITIAL> [Cc][Aa][Ss][Ee] {return new Symbol(TokenConstants.CASE);}

<YYINITIAL> [Ee][Ss][Aa][Cc] {return new Symbol(TokenConstants.ESAC);}

<YYINITIAL> [Nn][Ee][Ww] {return new Symbol(TokenConstants.NEW);}

<YYINITIAL> [Oo][Ff] {return new Symbol(TokenConstants.OF);}

<YYINITIAL> [Nn][Oo][Tt] {return new Symbol(TokenConstants.NOT);}

<YYINITIAL> \n { curr_lineno++; }

<YYINITIAL> [\040\f\r\t\013]+ {/* Get rid of white space */}

<YYINITIAL> [0-9]+ {return new Symbol(TokenConstants.INT_CONST, AbstractTable.inttable.addString(yytext())); }

<YYINITIAL> [A-Z][0-9a-zA-z_]* {return new Symbol(TokenConstants.TYPEID, AbstractTable.idtable.addString(yytext()));}

<YYINITIAL> [a-z][0-9a-zA-z_]* {return new Symbol(TokenConstants.OBJECTID, AbstractTable.idtable.addString(yytext()));}

<YYINITIAL> "--".* {/* ignore the comment line */}

<YYINITIAL> "(*" {yybegin(COMMENT);}

<YYINITIAL> "*)" { return new Symbol(TokenConstants.ERROR, "Mismatched '*)'"); }

<COMMENT> "*)" {
	if (nestedCommentCount != 0) {
		nestedCommentCount--;	
	} else {
		yybegin(YYINITIAL);	
	}
}


<COMMENT> "(*" { nestedCommentCount++; }

<COMMENT> \n { 
	curr_lineno++;
}

<COMMENT> [^*\n\)\(]+  { /* Do Nothing */ }

<COMMENT> "(" {}

<COMMENT> "*" {}

<COMMENT> ")" {}

<YYINITIAL> \" {
	string_buf.delete(0, string_buf.length());
	yybegin(STRING);
}

<STRING> \" {
	yybegin(YYINITIAL);
	return new Symbol(TokenConstants.STR_CONST, AbstractTable.stringtable.addString((string_buf.toString())));
} 

<STRING_STRINGTOOLONG> \" {
	yybegin(YYINITIAL);
	return new Symbol(TokenConstants.ERROR, "Error: String constant too long");
}

<STRING_NULLINSTRING> \" {
	yybegin(YYINITIAL);
	return new Symbol(TokenConstants.ERROR, "Error: String contains null character");
}

<STRING> \n {
	yybegin(YYINITIAL);
	curr_lineno++;
	return new Symbol(TokenConstants.ERROR, "Error: Unterminated string constant"); 
}

<STRING_NULLINSTRING> \n {
	curr_lineno++;

	if (isEscaped){
		isEscaped = false;	
	}
	else {
		yybegin(YYINITIAL);
		return new Symbol(TokenConstants.ERROR, "Error: Unterminated string constant by null string"); 
	}
}

<STRING_STRINGTOOLONG> \n {
	curr_lineno++;

	if (isEscaped){
		isEscaped = false;	
	}
	else {
		yybegin(YYINITIAL);
		return new Symbol(TokenConstants.ERROR, "Error: Unterminated string constant by too long"); 
	}

}


<STRING> [^\n\"] {
	if (yytext().charAt(0) == '\0'){
		yybegin(STRING_NULLINSTRING);
	} else {
		if (yytext().charAt(0) == '\\'){
			yybegin(STRING_BACKSLASHESCAPED);
			isEscaped = true;
		}
		string_buf.append(yytext());
		
		if (string_buf.length() >= MAX_STR_CONST) {
				yybegin(STRING_STRINGTOOLONG);
		}
	}
}

<STRING_NULLINSTRING> [^\n\"] { 
	if (yytext().charAt(0) == '\\')
	{
		isEscaped = true;
	}	
}

<STRING_STRINGTOOLONG> [^\n\"] { 
	if (yytext().charAt(0) == '\\'){
		isEscaped = true;
	}
}


<STRING_BACKSLASHESCAPED> . {
	int length = string_buf.length();
	switch(yytext().charAt(0)) {
		case 'b':
			string_buf.setCharAt(length-1, '\b');
			break;
		case 't':
			string_buf.setCharAt(length-1, '\t');
			break;
		case 'n':
			string_buf.setCharAt(length-1, '\n');
			break;
		case 'f':
			string_buf.setCharAt(length-1, '\f');
			break;
		default:
			string_buf.setCharAt(length-1, yytext().charAt(0));
	}			
	
	if (yytext().charAt(0) ==  '\0')
	{
		yybegin(STRING_NULLINSTRING);
	}
	else if (string_buf.length() >= MAX_STR_CONST) 
	{
		yybegin(STRING_STRINGTOOLONG);
	} 
	else 
	{
		yybegin(STRING);
	}
}

<STRING_BACKSLASHESCAPED> \n { 
	curr_lineno++;
	string_buf.setCharAt(string_buf.length()-1, yytext().charAt(0)); 

	if (string_buf.length() >= MAX_STR_CONST) {
		yybegin(STRING_STRINGTOOLONG);
	} else {
		yybegin(STRING);
	}

}
	
<YYINITIAL> . { return new Symbol(TokenConstants.ERROR, new String(yytext())); }


. { /* This rule should be the very last
       in your lexical specification and
       will match match everything not
       matched by other lexical rules. */
    System.err.println("LEXER BUG - UNMATCHED: " + yytext()); }
