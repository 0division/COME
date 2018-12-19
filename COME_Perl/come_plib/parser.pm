use v5.20;
use strict;
use feature qw(signatures);
no warnings qw(experimental::signatures);
use Data::Dumper;
use List::MoreUtils qw(uniq);
package come_plib::parser;


# P2C - transform pattern code into compiled (in this case perl) code
#TODO1: 
sub P2C($P, $lvl) {
  my $C = $P;
  while ($C =~ s/<<=\|([^>|^<<]+)>/\( GetYarn_Exact_TT\(\$tt, "$1"\)\)/) { }
  while ($C =~ s/<<0\|([^>|^<<]+)>/\"\.GetYarn\(\$tt, "$1"\)\.\"/)   { }
  while ($C =~ s/<<-\|([^>|^<<]+)>/\"\.GetYarn\(\$tt-1, "$1"\)\.\"/) { }
  if ($lvl == 1) {
    while ($C =~ s/\.*<<\+\|([^>|^<<]+)>.*([\:|\+|\-|\/|\*]\=)(.*)/AsgmYarn\(\$tt\+1, "$1", "$2", "$3"\)/) { }
  }
  $C;
}

sub cyarnwild2regexp($cknit_wild) {
  our %m;
  #print ">>>cyarnwild2regexp>>>".Data::Dumper::Dumper($m{"cknit"}{"k1"}{"wild"});
  #print ">>>cyarnwild2regexp>>>".Data::Dumper::Dumper($cknit_wild);
  my $regexp = "";
  my $set    = qw{\\[\(\\d+\)\\]};
    foreach my $cwy (@$cknit_wild) {
    $cwy =~ s/\./\\\./;
    $cwy =~ s/\[\*\d+\*\]/\\[([\\d|\\w]\+)\\\]/;
    $regexp .= (length($regexp) == 0 ? "" : "|").$cwy;
  }
  $regexp;
}

sub ryarn2cknitargs($cwild_regexp, $yarn) {
#  print "\n>>>cyarnwild2regexp>>>cwild_regexp: ".$cwild_regexp; 
  my @a;
  foreach my $ystar (@$yarn) {
 	my $ystar2 = $ystar;
    my $found = $ystar2 =~ m/${cwild_regexp}/g;
#    print "\n>>>cyarnwild2regexp>>>yarn: ".$ystar." -->  $found: $+"; 
    if ($found) { push @a, "\"$+\""; }
  }
  @a = List::MoreUtils::uniq @a;
  @a;
}


1;