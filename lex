swipl -s lexer.pl -g "lex('$1', X), maplist(writeln, X)." -t halt.
