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

=begin comment
/#k1|<<s|a[*1*]>::
  <<+|a_sum[<<0|a[*1*]cy>]> += <<0|a[*1*]> - <<-|a[*1*]>;
  <<+|a_sum_eur>            += <<0|a[*1*]> * <<0|cy[<<0|a[*1*]cy>] - <<-|a[*1*]>> * <<-|cy[<<0|a[*1*]cy>]>
#\
<#cy[EUR]:=1;cy[USD]:=1.2;#>
<#a[0]cy:='EUR';a[0]cy:='EUR';a[0]:=3;_tt+;_out0:=yarn#>
<#_html_dump:=example\come_a_sum2.html#>
=cut

#print come_plib::io::DumpAll(\%come_plib::base::m);
#$come_plib::base::m{debug}=1;

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


print "\nGood bye, Knitting Tycoon. Have a nice day!";

#print "\n\nCKnitCode_k1(0, 0);\n";
#come_plib::base::CKnitCode_k1(0, 0);

#my $c_wild = \@{$come_plib::base::m{"cknit"}{"k1"}{"wild"}{"1"}};
#my @yarn = keys %{$come_plib::base::m{"yarn*"}};
#print "\n\n\n>>>COME_exe.pl>>>come_plib::parser::cyarnwild2regexp(\n".Data::Dumper::Dumper($c_wild);
#my $regexp=come_plib::parser::cyarnwild2regexp($c_wild);
#print "\n); := ".($regexp);
#print "\n\n\n>>>COME_exe.pl>>>come_plib::parser::ryarn2cknitargs($regexp, \n".Data::Dumper::Dumper(\@yarn);
#my @rargs=come_plib::parser::ryarn2cknitargs($regexp, \@yarn);
#print "\n); := ".Data::Dumper::Dumper(\@rargs);

#come_plib::base::KnitDebug();
#my @a = come_plib::base::GetCKnitYarn("k1",".", 1);
#foreach my $aa (@a) { print "\nGetCKnitYarn/aa = $$aa[0] / $$aa[1]"; }
#my %a = come_plib::base::GetCKnitWild("k1",".");
#print Data::Dumper::Dumper(\%a);


#come_plib::base::SetCode("/#k1|<<s|a[*1*]>::<<+|a_sum> += <<0|a[*1*]> - <<-|a[*1*]>#\\");
#come_plib::base::SetCode("<#a[0]:=3;a[1]:=9;a[2]:=6;_tt+#>");
#come_plib::base::SetCode("<#a[1]:=3;a[3]:=10;_tt+#>");
#come_plib::base::SetCode("<#_html_dump:=come_a_sum.html;_out0:=yarn;_out0:=code;_exit#>");
#print come_plib::io::DumpAll(\%come_plib::base::m);
#print Dumper($come_plib::base::m{"yarn"});
#print come_plib::io::DumpCodeTxt(\%come_plib::base::m);
#print come_plib::io::DumpYarnTxt(\%come_plib::base::m);

#come_plib::io::DumpHTMLfile(\%come_plib::base::m, "come.html");#C:/Users/Lydia/Desktop/Daniel/COME/COME_Perl/come.html");
#open(my $fh, '>', "C:/Users/Lydia/Desktop/Daniel/COME/COME_Perl/come.html") or die "cant open";
#print $fh come_plib::io::DumpHTMLtab(come_plib::io::DumpYarnTxt(\%come_plib::base::m));
#close $fh;
