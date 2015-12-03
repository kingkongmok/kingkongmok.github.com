#!/usr/bin/python

# http://learnpythonthehardway.org/book/ex44.html
# Inheritance Versus Composition

class Parent(object):
    def implicit(self):
        print "%s PARENT implicit() which from parents" % type(self)
    def override(self):
        print "%s override() which from parents" % type(self)
    def altered(self):
        print "PARENT altered() is called"

class Child(Parent):
    def override(self):
        print "%s override()" % type(self)
    def altered(self):
            print "CHILD, BEFORE PARENT altered() is called"
            super(Child, self).altered()
            print "CHILD, AFTER PARENT altered() is called"

dad = Parent()
son = Child()

dad.implicit()
son.implicit()

dad.override()
son.override()

dad.altered()
son.altered()
