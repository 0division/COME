use v5.20;
use strict;
use feature qw(signatures);
no warnings qw(experimental::signatures);
use Data::Dumper;
package come_plib::io;


sub DumpAll($mesh) {
  my $x=Data::Dumper::Dumper($mesh);
#  $x =~ s/  / /g; $x =~ s/([\[|\{]) *\n */$1/g;$x =~ s/\n *([\]|\}]\,?)\n*/$1\n/g;
  $x =~ s/  / /g; $x =~ s/(\[) *\n */$1/g;$x =~ s/\n *([\]|\}]\,?)\n*/$1\n/g;
  $x;
}


sub DumpCodeTxt($mesh, $btag=0) {
  my $code_arr = $$mesh{"code"};
  #print $code_arr;
  my $str = $btag ? "\n<_tt_>\t<_code_>" : "\ntt\tcode";
  foreach my $i (0 .. $#$code_arr) {
    $str .= "\n$i".$$code_arr[$i];
  }
  $str =~ s/\n\n/\n/g;
  $str;
}

sub DumpYarnTxt($mesh, $btag=0) {
  my $yarnhash = $$mesh{"yarn*"};
  my @yarn_arr = sort keys %$yarnhash;
  my $str = $btag ? "\n<_Name_>\t<_*_>" : "\n".('.'x18)."Name\t*";
  for (my $i=$$mesh{"tt"}; $i >= 0; $i--) { 
    $str.= ($btag ? "\t<_tt=$i"."_>" : "\ttt=$i");
  }
  foreach my $y (@yarn_arr) {
    $str.="\n".(' ' x (22-length($y)))."$y\t".$$mesh{"yarn*"}{$y};
    for (my $i=$$mesh{"tt"}; $i >= 0; $i--) {
      my $v=$$mesh{"yarn"}[$i]{$y};	
      $str.="\t".($v?$v:"");
    }
  }
  $str.="\n";
  #print Data::Dumper::Dumper($yarns);
}


sub DumpHTMLtab($strTxt, $bfirstCol=0) {
  $strTxt =~ s/<</\&lt;\&lt;/g;
  #$strTxt =~ s/>/\&gt;/g;
  $strTxt =~ s/<_/<b>/g;
  $strTxt =~ s/_>/<\/b>/g;
  $strTxt =~ s/^\n/<table bgcolor='#222222'><tr><td>/g;
  if (!$bfirstCol) { $strTxt =~ s/\n/<\/code><\/td><\/tr>\n<tr><td><code>/g; }
  else {   $strTxt =~ s/\n/<\/td><\/tr>\n<tr><td bgcolor='white'><code>/g; }
  $strTxt =~ s/\t/<\/code><\/td><td><code>/g;
  $strTxt . "</table>";
}

sub DumpHTMLKnit($mesh) {
  my $strTxt = "\n<table bgcolor='#222222'>";
  my $knithash = $$mesh{"pknit"};
  my @knit_arr = sort keys %$knithash;
  foreach my $knit (@knit_arr) {
    my ($pcode, $ccode) = ($$mesh{pknit}{$knit}{code}, $$mesh{cknit}{$knit}{code});
    $pcode =~ s/\;/\;<br>/g; $pcode =~ s/\:\:/\:\:<br>/g;  $pcode =~ s/<</\&lt;\&lt;/g; 
    $ccode =~ s/</\&lt;/g; $ccode =~ s/>/\&gt;/g;          $ccode =~ s/\;/\;<br>/g; $ccode =~ s/\{/\{<br>/g; $ccode =~ s/\}/\}<br>/g;
    $strTxt .= "<tr><td><code>$knit</code></td><td><code>".$pcode."</code></td><td><code>".$ccode."</code></td></tr>";
  }
  $strTxt . "</table>";
}

sub DumpHTMLfile($mesh, $file) {
  my ( $sec, $min, $hour, $mday, $mon, $year ) = localtime;
  open(my $fh, '>', $file) or die "cant open $file";
  print $fh "<!DOCTYPE html><html><body style='background-color:lightgrey;'><font face='verdana' color='black'>";
  print $fh "<style>td {background-color:grey;};</style>"; #th {background-color:lightgrey;}
  print $fh "\n<h4>Code</h4>".come_plib::io::DumpHTMLtab(come_plib::io::DumpCodeTxt($mesh, 1), 1)."<br>";
  print $fh "\n<h4>Yarn</h4>".come_plib::io::DumpHTMLtab(come_plib::io::DumpYarnTxt($mesh, 1), 1)."<br>";
  print $fh "\n<h4>Knit</h4>".come_plib::io::DumpHTMLKnit($mesh)."<br>";
  print $fh "\n<small><br><br><br><b>COME</b> (Condition Mesh v.01, (c) 2018, Daniel Mueller) / ";
  printf $fh "%04d.%02d.%02d %02d:%02d:%02d", $year+1900, $mon+1, $mday, $hour, $min, $sec;
  printf $fh " / $file </small></body></html>";
  close $fh;
}

1;