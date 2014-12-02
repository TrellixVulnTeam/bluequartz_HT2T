/* Generated by re2c 0.13.2 on Sat Oct 11 11:07:13 2014 */
#line 1 "txn/odb_txn_lexer.re2c"
/* $Id: odb_txn_lexer.re2c 259 2004-01-03 06:28:40Z shibuya $ */
/* Copyright 2001 Sun Microsystems, Inc.  All rights reserved. */

/* REMINDER: don't edit the .c version of this file, edit the
 * .re2c version of this file instead, hey?
 */

#include <cce_common.h>
#include "odb_txn_internal.h"
#include <odb_txn_lexer.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define BLOCKSIZE   32

struct txn_scanner_struct {
  FILE * f;
  char *buf;
  char *bufend;
  char *cursor;
  char *token;
  char *lasttoken;
  size_t bufsize;
};

txn_scanner 
txn_scanner_new(FILE *f)
{
  txn_scanner s;
  s = malloc(sizeof(struct txn_scanner_struct));
  if (!s) return NULL;
  
  s->f = f;
  s->buf = NULL;
  s->bufend = NULL;
  s->cursor = NULL;
  s->token = NULL;
  s->lasttoken = NULL;
  s->bufsize = 0;
  
  return s;
}

void
txn_scanner_destroy(txn_scanner s)
{
  free(s->buf);
  free(s);
}

char *
txn_scanner_duptoken(txn_scanner s)
{
  char * str;
  if (! s->lasttoken) { return NULL; }
  str = malloc(s->cursor - s->lasttoken + 1);
  memcpy(str, s->lasttoken, s->cursor - s->lasttoken);
  str[s->cursor - s->lasttoken] = '\0';
  return str;
}

unsigned long
txn_scanner_toktoul(txn_scanner s, int base)
{
  char *str;
  str = s->lasttoken;
  if (*str == '\"') str++;
  return strtoul(str, NULL, base);
}

static void
tok_fill(txn_scanner s, int n)
{
  // if (s->buf) { printf ("initial: [%s]\n", s->buf); }
  /* shift the buffer, preserving uneaten token chars */
  {
    unsigned int cnt = s->token - s->buf;
    if (cnt) {
      memcpy(s->buf, s->token, (s->bufend - s->token));
      s->token = s->buf;
      s->cursor -= cnt;
      s->bufend -= cnt;
    }
    // if (s->buf) { printf ("shifted: [%s]\n", s->buf); }
  }

  /* resize buffer if necessary */  
  {
    size_t reqsize = s->bufend - s->token + n;
    if ( s->bufsize < reqsize ) {
      char *buf;
      while (s->bufsize < reqsize) { s->bufsize += BLOCKSIZE; }
      buf = (char*)malloc(s->bufsize + 1);
      memcpy(buf, s->buf, s->bufend - s->buf);
      s->token += buf - s->buf;
      s->bufend += buf - s->buf;
      s->cursor += buf - s->buf;
      if (s->buf) free(s->buf);
      s->buf = buf;
      // if (s->buf) { printf ("resized: [%s]\n", s->buf); }
    }
  }
  
  /* fill buffer */
  {
    int cnt;
    size_t avail = s->bufsize - (s->bufend - s->token);
    
    cnt = fread( s->bufend, sizeof(char), avail, s->f);
    s->bufend += cnt;
    *(s->bufend) = '\0';
    // if (s->buf) { printf ("filled:  [%s]\n", s->buf); }
  }
  
}    
  
txn_parser_token
txn_scanner_scan(txn_scanner s)
{  
  char *q;
#define YYCTYPE   char
#define YYCURSOR  (s->cursor)
#define YYLIMIT   s->bufend
#define YYMARKER  q
#define YYFILL(n) tok_fill(s, n)
#define RET(i)    { s->lasttoken=s->token; s->token = s->cursor; return i; }

#line 133 "<stdout>"
{
	YYCTYPE yych;

	if ((YYLIMIT - YYCURSOR) < 12) YYFILL(12);
	yych = *YYCURSOR;
	switch (yych) {
	case 0x09:
	case 0x0A:
	case ' ':	goto yy2;
	case '"':	goto yy6;
	case '#':	goto yy4;
	case '/':	goto yy9;
	case '<':	goto yy7;
	case '=':	goto yy12;
	case '>':	goto yy10;
	case 'A':	goto yy20;
	case 'B':	goto yy21;
	case 'C':	goto yy17;
	case 'L':	goto yy19;
	case 'O':	goto yy16;
	case 'P':	goto yy18;
	case 'R':	goto yy22;
	case 'S':	goto yy15;
	case 'T':	goto yy14;
	default:	goto yy23;
	}
yy2:
	++YYCURSOR;
	yych = *YYCURSOR;
	goto yy122;
yy3:
#line 135 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_WHITESPACE) }
#line 167 "<stdout>"
yy4:
	yych = *(YYMARKER = ++YYCURSOR);
	switch (yych) {
	case '0':
	case '1':
	case '2':
	case '3':
	case '4':
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':	goto yy115;
	default:	goto yy5;
	}
yy5:
#line 157 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_OTHER) }
#line 186 "<stdout>"
yy6:
	yych = *(YYMARKER = ++YYCURSOR);
	switch (yych) {
	case 0x0A:
	case '\\':	goto yy5;
	default:	goto yy112;
	}
yy7:
	++YYCURSOR;
#line 138 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_OPENTAG) }
#line 198 "<stdout>"
yy9:
	yych = *(YYMARKER = ++YYCURSOR);
	switch (yych) {
	case '>':	goto yy88;
	case 'L':	goto yy85;
	case 'S':	goto yy86;
	case 'T':	goto yy87;
	default:	goto yy5;
	}
yy10:
	++YYCURSOR;
#line 140 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_CLOSETAG) }
#line 212 "<stdout>"
yy12:
	++YYCURSOR;
#line 141 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_EQUALS) }
#line 217 "<stdout>"
yy14:
	yych = *(YYMARKER = ++YYCURSOR);
	switch (yych) {
	case 'R':	goto yy74;
	default:	goto yy5;
	}
yy15:
	yych = *(YYMARKER = ++YYCURSOR);
	switch (yych) {
	case 'C':	goto yy63;
	case 'T':	goto yy64;
	default:	goto yy5;
	}
yy16:
	yych = *(YYMARKER = ++YYCURSOR);
	switch (yych) {
	case 'B':	goto yy55;
	case 'I':	goto yy54;
	default:	goto yy5;
	}
yy17:
	yych = *(YYMARKER = ++YYCURSOR);
	switch (yych) {
	case 'L':	goto yy49;
	default:	goto yy5;
	}
yy18:
	yych = *(YYMARKER = ++YYCURSOR);
	switch (yych) {
	case 'R':	goto yy45;
	default:	goto yy5;
	}
yy19:
	yych = *(YYMARKER = ++YYCURSOR);
	switch (yych) {
	case 'I':	goto yy41;
	default:	goto yy5;
	}
yy20:
	yych = *(YYMARKER = ++YYCURSOR);
	switch (yych) {
	case 'D':	goto yy34;
	case 'F':	goto yy33;
	default:	goto yy5;
	}
yy21:
	yych = *(YYMARKER = ++YYCURSOR);
	switch (yych) {
	case 'E':	goto yy26;
	default:	goto yy5;
	}
yy22:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'M':	goto yy24;
	default:	goto yy5;
	}
yy23:
	yych = *++YYCURSOR;
	goto yy5;
yy24:
	++YYCURSOR;
#line 156 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_RM) }
#line 282 "<stdout>"
yy26:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'F':	goto yy28;
	default:	goto yy27;
	}
yy27:
	YYCURSOR = YYMARKER;
	goto yy5;
yy28:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'O':	goto yy29;
	default:	goto yy27;
	}
yy29:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'R':	goto yy30;
	default:	goto yy27;
	}
yy30:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'E':	goto yy31;
	default:	goto yy27;
	}
yy31:
	++YYCURSOR;
#line 154 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_BEFORE) }
#line 314 "<stdout>"
yy33:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'T':	goto yy37;
	default:	goto yy27;
	}
yy34:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'D':	goto yy35;
	default:	goto yy27;
	}
yy35:
	++YYCURSOR;
#line 153 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_ADD) }
#line 331 "<stdout>"
yy37:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'E':	goto yy38;
	default:	goto yy27;
	}
yy38:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'R':	goto yy39;
	default:	goto yy27;
	}
yy39:
	++YYCURSOR;
#line 155 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_AFTER) }
#line 348 "<stdout>"
yy41:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'S':	goto yy42;
	default:	goto yy27;
	}
yy42:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'T':	goto yy43;
	default:	goto yy27;
	}
yy43:
	++YYCURSOR;
#line 151 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_LIST) }
#line 365 "<stdout>"
yy45:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'O':	goto yy46;
	default:	goto yy27;
	}
yy46:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'P':	goto yy47;
	default:	goto yy27;
	}
yy47:
	++YYCURSOR;
#line 150 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_PROP) }
#line 382 "<stdout>"
yy49:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'A':	goto yy50;
	default:	goto yy27;
	}
yy50:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'S':	goto yy51;
	default:	goto yy27;
	}
yy51:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'S':	goto yy52;
	default:	goto yy27;
	}
yy52:
	++YYCURSOR;
#line 146 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_CLASS) }
#line 405 "<stdout>"
yy54:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'D':	goto yy61;
	default:	goto yy27;
	}
yy55:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'J':	goto yy56;
	default:	goto yy27;
	}
yy56:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'E':	goto yy57;
	default:	goto yy27;
	}
yy57:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'C':	goto yy58;
	default:	goto yy27;
	}
yy58:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'T':	goto yy59;
	default:	goto yy27;
	}
yy59:
	++YYCURSOR;
#line 145 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_OBJECT) }
#line 440 "<stdout>"
yy61:
	++YYCURSOR;
#line 149 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_OID) }
#line 445 "<stdout>"
yy63:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'A':	goto yy69;
	default:	goto yy27;
	}
yy64:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'A':	goto yy65;
	default:	goto yy27;
	}
yy65:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'T':	goto yy66;
	default:	goto yy27;
	}
yy66:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'E':	goto yy67;
	default:	goto yy27;
	}
yy67:
	++YYCURSOR;
#line 144 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_STATE) }
#line 474 "<stdout>"
yy69:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'L':	goto yy70;
	default:	goto yy27;
	}
yy70:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'A':	goto yy71;
	default:	goto yy27;
	}
yy71:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'R':	goto yy72;
	default:	goto yy27;
	}
yy72:
	++YYCURSOR;
#line 147 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_SCALAR) }
#line 497 "<stdout>"
yy74:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'A':	goto yy75;
	default:	goto yy27;
	}
yy75:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'N':	goto yy76;
	default:	goto yy27;
	}
yy76:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'S':	goto yy77;
	default:	goto yy27;
	}
yy77:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'A':	goto yy78;
	default:	goto yy27;
	}
yy78:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'C':	goto yy79;
	default:	goto yy27;
	}
yy79:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'T':	goto yy80;
	default:	goto yy27;
	}
yy80:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'I':	goto yy81;
	default:	goto yy27;
	}
yy81:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'O':	goto yy82;
	default:	goto yy27;
	}
yy82:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'N':	goto yy83;
	default:	goto yy27;
	}
yy83:
	++YYCURSOR;
#line 142 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_TRANSACTION) }
#line 556 "<stdout>"
yy85:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'I':	goto yy107;
	default:	goto yy27;
	}
yy86:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'C':	goto yy101;
	default:	goto yy27;
	}
yy87:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'R':	goto yy90;
	default:	goto yy27;
	}
yy88:
	++YYCURSOR;
#line 139 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_CLOSETAGEND) }
#line 579 "<stdout>"
yy90:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'A':	goto yy91;
	default:	goto yy27;
	}
yy91:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'N':	goto yy92;
	default:	goto yy27;
	}
yy92:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'S':	goto yy93;
	default:	goto yy27;
	}
yy93:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'A':	goto yy94;
	default:	goto yy27;
	}
yy94:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'C':	goto yy95;
	default:	goto yy27;
	}
yy95:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'T':	goto yy96;
	default:	goto yy27;
	}
yy96:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'I':	goto yy97;
	default:	goto yy27;
	}
yy97:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'O':	goto yy98;
	default:	goto yy27;
	}
yy98:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'N':	goto yy99;
	default:	goto yy27;
	}
yy99:
	++YYCURSOR;
#line 143 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_ETRANSACTION) }
#line 638 "<stdout>"
yy101:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'A':	goto yy102;
	default:	goto yy27;
	}
yy102:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'L':	goto yy103;
	default:	goto yy27;
	}
yy103:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'A':	goto yy104;
	default:	goto yy27;
	}
yy104:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'R':	goto yy105;
	default:	goto yy27;
	}
yy105:
	++YYCURSOR;
#line 148 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_ESCALAR) }
#line 667 "<stdout>"
yy107:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'S':	goto yy108;
	default:	goto yy27;
	}
yy108:
	yych = *++YYCURSOR;
	switch (yych) {
	case 'T':	goto yy109;
	default:	goto yy27;
	}
yy109:
	++YYCURSOR;
#line 152 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_ELIST) }
#line 684 "<stdout>"
yy111:
	++YYCURSOR;
	if (YYLIMIT == YYCURSOR) YYFILL(1);
	yych = *YYCURSOR;
yy112:
	switch (yych) {
	case 0x0A:
	case '\\':	goto yy27;
	case '"':	goto yy113;
	default:	goto yy111;
	}
yy113:
	++YYCURSOR;
#line 137 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_QSTR) }
#line 700 "<stdout>"
yy115:
	++YYCURSOR;
	if ((YYLIMIT - YYCURSOR) < 2) YYFILL(2);
	yych = *YYCURSOR;
	switch (yych) {
	case '#':	goto yy117;
	case '0':
	case '1':
	case '2':
	case '3':
	case '4':
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':	goto yy115;
	default:	goto yy27;
	}
yy117:
	yych = *++YYCURSOR;
	switch (yych) {
	case '+':
	case '/':
	case '0':
	case '1':
	case '2':
	case '3':
	case '4':
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':
	case '=':
	case 'A':
	case 'B':
	case 'C':
	case 'D':
	case 'E':
	case 'F':
	case 'G':
	case 'H':
	case 'I':
	case 'J':
	case 'K':
	case 'L':
	case 'M':
	case 'N':
	case 'O':
	case 'P':
	case 'Q':
	case 'R':
	case 'S':
	case 'T':
	case 'U':
	case 'V':
	case 'W':
	case 'X':
	case 'Y':
	case 'Z':
	case 'a':
	case 'b':
	case 'c':
	case 'd':
	case 'e':
	case 'f':
	case 'g':
	case 'h':
	case 'i':
	case 'j':
	case 'k':
	case 'l':
	case 'm':
	case 'n':
	case 'o':
	case 'p':
	case 'q':
	case 'r':
	case 's':
	case 't':
	case 'u':
	case 'v':
	case 'w':
	case 'x':
	case 'y':
	case 'z':	goto yy118;
	default:	goto yy27;
	}
yy118:
	++YYCURSOR;
	if (YYLIMIT == YYCURSOR) YYFILL(1);
	yych = *YYCURSOR;
	switch (yych) {
	case '+':
	case '/':
	case '0':
	case '1':
	case '2':
	case '3':
	case '4':
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':
	case '=':
	case 'A':
	case 'B':
	case 'C':
	case 'D':
	case 'E':
	case 'F':
	case 'G':
	case 'H':
	case 'I':
	case 'J':
	case 'K':
	case 'L':
	case 'M':
	case 'N':
	case 'O':
	case 'P':
	case 'Q':
	case 'R':
	case 'S':
	case 'T':
	case 'U':
	case 'V':
	case 'W':
	case 'X':
	case 'Y':
	case 'Z':
	case 'a':
	case 'b':
	case 'c':
	case 'd':
	case 'e':
	case 'f':
	case 'g':
	case 'h':
	case 'i':
	case 'j':
	case 'k':
	case 'l':
	case 'm':
	case 'n':
	case 'o':
	case 'p':
	case 'q':
	case 'r':
	case 's':
	case 't':
	case 'u':
	case 'v':
	case 'w':
	case 'x':
	case 'y':
	case 'z':	goto yy118;
	default:	goto yy120;
	}
yy120:
#line 136 "txn/odb_txn_lexer.re2c"
	{ RET(TXN_TOK_BINSTR) }
#line 864 "<stdout>"
yy121:
	++YYCURSOR;
	if (YYLIMIT == YYCURSOR) YYFILL(1);
	yych = *YYCURSOR;
yy122:
	switch (yych) {
	case 0x09:
	case 0x0A:
	case ' ':	goto yy121;
	default:	goto yy3;
	}
}
#line 158 "txn/odb_txn_lexer.re2c"

  return TXN_TOK_OTHER;
}
