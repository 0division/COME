=begin comment
  come_plib::paser.pm - text parsing perl-library for COME
  
  This library provides subs to do the pure text parsing operations for COME.
  It is not using any elements of the mesh. Anything must be uebergeben to the spectific sub.
  
=cut

use v5.20;
use strict;
use feature qw(signatures);
no warnings qw(experimental::signatures);
use Data::Dumper;
use List::MoreUtils qw(uniq);
package come_plib::parser;


# P2C - transform pattern code into compiled (in this case perl) code
#  Arg: Pcode:string - such as "<<+|sum>> += <<0|a[*1*]> - <<-|a[*1*]>"
#  Arg: type:integer - 0: condition, 1: assignment
#  Ret: Ccode:string - Perl code, such as 'AsgmYarn("sum", "+=", "".GetYarn($tt, "a[$a1]")." - ".GetYarn($tt-1, "a[$a1]")."")'
sub P2C($Pcode, $type) {
  my $Ccode = $Pcode;
#  while ($Ccode =~ s/<<=\|([^>|^<<]+)>/\( GetYarn_Exact_TT\(\$tt, "$1"\)\)/) {}
  while ($Ccode =~ s/<<0\|([^>|^<<]+)>/\"\.GetYarn\(\$tt, "$1"\)\.\"/) {}
  while ($Ccode =~ s/<<-\|([^>|^<<]+)>/\"\.GetYarn\(\$tt-1, "$1"\)\.\"/) {}
  while ($Ccode =~ s/<<=\|([^>|^<<]+)>/\"\.\(GetYarn_Exact_TT\(\$tt, "$1"\)\)\.\"/) {}
  if ($type == 0) {
    $Ccode = "eval(\"".$Ccode."\")";
  }
  if ($type == 1) {
    $Ccode =~ s/\.*<<\+\|([^>|^<<]+)>.*([\:|\+|\-|\/|\*]\=)(.*)/AsgmYarn\(\$tt\+1, "$1", "$2", "$3"\)/g;
  }
  # print ">>>P2C($Pcode, $lvl)>>> $Ccode";
  $Ccode;
}

# cyarnwild2regexp - Returning a regexp finding all concrete values regrading a defined wild card
#  Arg: cknit_wild:reference to string array - containing yarn names with wild cards, such as "a[*1*]"
#  Ret: regexp:string                        - Regexp, which can be performend on real yarn names returning all wild card occurencies, such as 1, 2 if you have the yarns a[1] and a[2]
sub cyarnwild2regexp($cknit_wild) {
  our %m;
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

# ryarn2cknitargs - Returning all parameters for a given wildcard
#  Arg: cwild_regexp:string             - containing the regexp created with cyarnwild2regexp
#  Arg: yarn:reference to string array  - containing real yarn names, such as "a[1]", "a[2]", ...
#  Ret: rargs:reference to string array - containing real yarn wild card occurencies, such as 1, 2 in this simple example
sub ryarn2cknitargs($cwild_regexp, $yarn) {
  my @a;
  foreach my $ystar (@$yarn) {
    my $found = $ystar =~ m/${cwild_regexp}/g;
    if ($found) { push @a, "\"$+\""; }
  }
  @a = List::MoreUtils::uniq @a;
  @a;
}


1;