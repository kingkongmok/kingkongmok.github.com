#!/usr/bin/python
# http://learnpythonthehardway.org/book/ex42.html
# Is-A, Has-A, Objects, and Classes

## Animal is-a object (yes, sort of confusing) look at the extra credit
class Animal(object):
    pass

## Dog is-a Animal, has a function named __init__ that taks self, name parameters.
class Dog(Animal):

    def __init__(self, name):
        ## Class Dog has-a __init__ that taks self and name as parameters
        self.name = name

## make a new class named Cat that is-a Animal
class Cat(Animal):

    def __init__(self, name):
        ## Class Cat has-a __init__ that takes self, name as parameters
        self.name = name

## make a new class named Person that is-a object
class Person(object):

    def __init__(self, name):
        ## from Person.this set the attribute of name as parameter name
        self.name = name

        ## Person has-a pet of some kind
        self.pet = None

## ??
class Employee(Person):

    def __init__(self, name, salary):
        """
        That's how you can run the __init__ method of a parent class reliably.
        Search for "python super" and read the various advice on it being evil
        and good for you.
        """
        ## ?? hmm what is this strange magic?
        super(Employee, self).__init__(name)
        ## set the attribute of this.salary as salary parameters
        self.salary = salary

## Fish is-a object 
class Fish(object):
    pass

## make a class Salmon is-a Fish
class Salmon(Fish):
    pass

## make a class Halibut is-a Fish
class Halibut(Fish):
    pass


## rover is-a Dog
rover = Dog("Rover")

## ??
satan = Cat("Satan")

## ??
mary = Person("Mary")

## from mary get pet attribute and set it to satan
mary.pet = satan

## ??
frank = Employee("Frank", 120000)

## ??
frank.pet = rover

## ??
flipper = Fish()

## ??
crouse = Salmon()

## ??
harry = Halibut()
