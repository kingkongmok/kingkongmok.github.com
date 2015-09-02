# Prompting People
# http://learnpythonthehardway.org/book/ex12.html

age = raw_input("How old are you? ")
height = raw_input("How tall are you? ")
weight = raw_input("How much do you weigh? ")

print "So, you're %r old, %r tall and %r heavy." % (
    age, height, weight)

# Why can't I do print "How old are you?" , raw_input()?
# You'd think that'd work, but Python doesn't recognize that as valid. The only answer I can really give is, you just can't.
