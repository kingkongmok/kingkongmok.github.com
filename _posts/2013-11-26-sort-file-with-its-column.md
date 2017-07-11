---
layout: post
title: "how to sort an array or table by column in perl"
category: perl
tags: [perl, sort, cmp, column]
---

##方法一，之前抄的

```
#!/usr/bin/perl 
use strict;
use warnings;

open FILE, "<", "testinput.txt" or die "error: $!" ;
chomp (my @array = <FILE>) ;
my @sortedarray = map { $_->[0] } sort {$a->[1] <=> $b->[1]} map {[$_, (split)[1]]} @array ;


#use Data::Dumper;
#print Dumper(@sortedarray);

foreach my $line ( @sortedarray  ) {
    print "$line\n" ;
}

```

##方法二，依然调用map但直接拆数组。

```
open FILE, "<", "testinput.txt" ;
my @array = <FILE>;
my @splitedarray = sort {$a->[1] <=> $b->[1]} map { [(split) ] } @array; 

#use Data::Dumper;
#print Dumper(@splitedarray);
    

foreach my $aoa (@splitedarray  ) {
    foreach my $element (@{$aoa}  ) {
        print "$element\t" ;
    }
    print "\n";
}
```

##方法三，顺便测试push，臃肿的表现。

```
perl -lane ' push(@newarray, $_ ); END { foreach ( map {$_->[0]} sort { $a->[1] <=> $b->[1] } map {[$_, (split)[2]]} @newarray) { print } }' testinput.txt
```

##方法四，数组表现。

```
perl -ae 'print map {$_->[0]}  sort {$a->[1] <=> $b->[1]}  map {[ $_, (split)[2]]} <>'
```


### 另外一个范例使用index

```perl
$_="-6461_Pol2 5597_Pol2 1062_Pol2 8.5_Taf1 9210.5_Taf1 -9989_Taf1 1049_Taf1";
print  join " ", sort {substr($a,0,index($a,"_")) <=> substr($b,0,index($b,"_"))} split;
```

--- 

## [sort a array by column](http://stackoverflow.com/questions/27112465/how-to-sort-an-array-or-table-by-column-in-perl)

---

### sort by column

In case this helps folks dropping by in the future - here are some inelegant attempts to sort() the content of lines.txt (data from question), by its fifth column, with a perl one liner. This should work:

```
perl -E 'say "@$_" for sort {$a->[4] <=> $b->[4]} map {[(split)]} <>' file
```


This is more or less the same thing but with the split "automated" with the autosplit (-a) switch:

```
perl -anE 'push @t,[@F]}{say "@$_" for sort {$a->[4] <=> $b->[4]} @t' file
```

If the split pattern is not whitespace, you can substitute it for the default (\s+) shown here:

```
perl -E 'say sort {(split(/\s+/,$a))[4] <=> (split(/\s+/,$b))[4]} <>' file
```


This is the shortest way to sort and print the fifth column:

```
perl -E 'say for sort map{ (split)[4] }' file
```

---


### Transforming the sort

Can we map, split and sort in one pass? This is a short way to sort the fifth column:

```
perl -E 'say for sort map{ [(split)[4], $_]->[0] } <>' file
```

Dissecting this last example: perl first maps the STDIN to split() - making a list; takes the fifth element (i.e. [4]) of this split() list and wraps that list item and the whole line that was just read ($_) inside an array constructor []; then takes the first element of that anonymous array (i.e. the fifth column of each line) and passes it to sort(). Phew!

This just prints the fifth column since we only passed the first element ->[0] of the anonymous array to sort. To print the whole line sorted by the column in this way we need to pass the whole anonymous array to sort and tell sort to use the element which hold the column's contents to do its work, and then pass the other element of the anonymous array (the one that holds the entire line) to print - this way we can sort by the fifth column but print out the whole line:

```
perl -E 'say $_->[1] for sort{$a->[0] <=> $b->[0]} map{[(split)[4], $_]} <>' file
```

This is just like our very first example above. If, instead of running through the list that is created using for, we map the second element and pass it to print we get:

```
perl -E 'say map $_->[1], sort{$a->[0] <=> $b->[0]} map{[(split)[4],$_]} <>' file
```

We have reinvented the Schwartzian Transform which is such a great perl idiom that it is "built in" to perl6 ;-)
