=begin comment

COME_exe.pl - The executable of the COME-Perl-Prototype

This prototype of the COME language is implemented very very poor; just to get the fist examples run. 
The runtime performance is very very bad, but it is about to check, wether the idea could work out or not.
The COME-language is interpreted as descriped in COME_paper.rtf.

Install Perl v5.20 or newer and start the this programm beeing in the same folder and type the following code into the console:

/#k1|<<s|a[*1*]>::
  <<+|a_sum[<<0|a[*1*]cy>]> += <<0|a[*1*]> - <<-|a[*1*]>;
  <<+|a_sum_eur>            += <<0|a[*1*]> * <<0|cy[<<0|a[*1*]cy>] - <<-|a[*1*]>> * <<-|cy[<<0|a[*1*]cy>]>
#\
<#cy[EUR]:=1;cy[USD]:=1.2#>
<#a[0]cy:='EUR';a[0]:=3;a[1]cy:='USD';a[1]:=10;_tt+#>
<#a[1]:=15;a[2]cy:='EUR';a[2]:=30;_tt+#>
<#_html_dump:=come_a_curr_sum.html#>
<#_exit#>

, or just use examples/come_a_sum2.bat and if anythings works out: you should have created come_a_curr_sum.html.

=cut

use v5.20;
use strict;
use feature qw(signatures);
no warnings qw(experimental::signatures);
use Data::Dumper;
use Data::Dumper;
use lib '.';
use come_plib::parser;
use come_plib::base;
use come_plib::io;

come_plib::base::InitMesh();

my $i = 0;
my $block = <STDIN>;
while ($block) {
  chomp $block;
  $i++; #print "\n$i.\t".index($block, "/#")."\t$block"; if ($i==20) { exit; }
  if (index($block, "/#") >= 0) {
    while (index($block,"#\\") == -1) {
	  $block .= <STDIN>;
	  chomp $block;
	  $i++; #print "\n/#$i#\\\t$block"; if ($i==20) { exit; }
	}
  }
  #$block =~ s/^\s+|\s+$|\n|\t//g;
  #$block =~ s/^\s+|\s+$|\t//g;
  come_plib::base::SetCode($block);
  $block = <STDIN>;
}


print "\nGood bye, Knitting Tycoon. Have a X-Mas!";
