use v5.20;
use strict;
use feature qw(signatures);
no warnings qw(experimental::signatures);
use Data::Dumper;
use List::MoreUtils qw(uniq);
package come_plib::help;

sub help($page=0) {
  print "HELP / page: $page (COME-Condition Mesh v.01.20181216 | (c) 2018, Daniel Mueller)";
  if ($page eq "STORY") {
	print <<EOM
My name is Daniel Mueller and today I want to introduce a new computing system called condition mesh: COME.

Usually computing systems pulling data and perform a desired computation on it. This leads for example to summing all the time the same data again and again.

 Condition Mesh is designed to write programs where the data is pushed through the algorithm and is not accessing all the data over and over again.

COME 

EOM
  } else { 
	print <<EOM
	


Let us start with a very short program continuously summing the values of an array a into the scalar sum by defining the following knit k1:
/#k1|<<=,a[*1*]>::
  <<+,sum> += <<0,a[*1*]> - <<-,a[*1*]>
#\\
, where on any set value in the array a (<<=,a[*1*]>) change the next sum (<<+,sum>) by adding to the previous sum (+=) the actual value of the a element (<<0,a[*1*]>) and subtracting the previous a element in time (<<-,a[*1*]>).
At next you can start assigning values to the array:
<#a[0] := 3;  a[1] := 2; _tt+#>
<#a[0] := 10; a[2] := 5; _tt+#>
, which leads to the following a_sum in time:
a_sum = 5
a_sum = 17

Ok, to summarize: a knit is an if-then-assignment statement with the following syntax:
  /#knitname|if-condition::assignments#\ 
, where the values of variables can be accessed from the past and from now and can be set only in the future (where else...).
*1* is used as a wildcard, which makes a knit like an template applicable for any variable which fits the specific name pattern (COME do not have any data structures: it just might look like...).

All computation based on a single element are done in parallel and in this case is no locking issue, because of the incremental addition by using +=.
EOM
  }
}
1;