
A simple diff of two strings:

    > require("diff")
    > for _, token in ipairs(diff.diff("This is a test", "This was a test!")) do 
    >> print(token[1], token[2])
    >> end
    This    same
    is      out
    was     in
            same
    a       same
            same
    test    out
    test!   in
            same

That is, diff.diff(old, new) returns a table of pairs, each consisting of a string
and it's status: "same" (the string is present in both), "in" (the string appeared
in <i>new</i>, or "out" (the string was present in <i>old</i> but was removed).

Alternatively, you can just generate an HTML for this diff:

    > = diff.diff("This is a test", "This was a test!"):to_html()
    This <del>is</del><ins>was</ins> a <del>test</del><ins>test!</ins>

