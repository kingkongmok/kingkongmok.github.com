#!/usr/bin/python
import ex25
print "Let's practice everything."
print 'You\'d need to know \'bout escapes with \\ that do \n newlines and \t tabs.'

poem = """
\tThe lovely world
with logic so firmly planted
cannot discern \n the needs of love
nor comprehend passion from intuition
and requires an explantion
\n\t\twhere there is none.
"""


print "--------------"
print poem
print "--------------"

five = 10 - 2 + 3 - 5
print "This should be five: %s" % five

def secret_formula(started):
    jelly_beans = started * 500
    jars = jelly_beans / 1000
    crates = jars / 100
    return jelly_beans, jars, crates


start_point = 10000
beans, jars, crates = secret_formula(start_point)

print "With a starting point of: %d" % start_point
print "We'd have %d jeans, %d jars, and %d crates." % (beans, jars, crates)

start_point = start_point / 10

print "We can also do that this way:"
print "We'd have %d beans, %d jars, and %d crabapples." % secret_formula(start_point)


sentence = "All god\tthings come to those who weight."


words = ex25.break_words(sentence)
sorted_words = ex25.sort_words(words)

# print_first_word(words)
# print_last_word(words)
# print_first_word(sorted_words)
# print_last_word(sorted_words)
sorted_words = ex25.sort_sentence(sentence)

print sorted_words

print ex25.print_first_and_last(sentence)

print ex25.print_first_and_last_sorted(sentence)

