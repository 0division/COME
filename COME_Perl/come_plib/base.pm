=begin comment

pknit - knit pattern
cknit - compiled knit
 cwy  - compiled wild yarn 
 
 
Todo: 1. parser::P2C macht eine Zeichenkettenzusammensetzung immer bei 0 und -, allerdings ist diese immer und nur bei verschachtelt zu un 
=cut

use v5.20;
use strict;
use feature qw(signatures);
no warnings qw(experimental::signatures);
use Data::Dumper;
use lib 'C:\Users\Lydia\Desktop\Daniel\COME\COME_Perl';
use come_plib::parser;
use come_plib::help;
#use Sub::Identify qw/sub_fullname/;
use List::MoreUtils qw(uniq);
package come_plib::base;
our %m;
#$m{debug} = 2;


sub Debug_Out($text, $newline=1, $delnewline=1, $deldouplespace=1, $delVAR=1) {
  #http://perldoc.perl.org/functions/caller.html
  my @c = caller(1);
  our %m;
  #$m{kfg}{debug} = 1;

  if (    $m{kfg}{debug} != 0
    #  and $c[3] !~ /GetYarn/ 
      and $c[3] !~ /SetCode/
      ) {
    if ($newline)        { print "\n>>>DBG>>>$c[3]"; }
    if ($delnewline)     { $text =~ s/\n//g;      }
    if ($deldouplespace) { $text =~ s/  //g;      }
    if ($delVAR)         { $text =~ s/\$VAR\d \= //g;      }
    print $text;
  }
}
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

sub SetYarn($yarn, $op, $value) {
  Debug_Out("($yarn, $op, $value) / m{tt}=$m{tt} ");
  our %m;
  if ($op eq ":=") {
    Debug_Out(" executed!", 0);
    $m{"yarn"}[$m{"tt"}]{$yarn} = $value; 
    $m{"yarn*"}{$yarn} = $value; 
  }
}

sub GetYarn_Exact_TT($tt, $yarn) {
  our %m;
  $m{"yarn"}[$tt]{$yarn}
}

sub GetYarn($tt, $yarn) {
  our %m;
  my $v = 0;
  Debug_Out("($tt, $yarn)");
  if ($tt >= 0) {
    $v = GetYarn_Exact_TT($tt, $yarn);
    Debug_Out(" / found $v", 0);
    if (!$v and $tt > 0) {
      $v = GetYarn($tt-1, $yarn);
    }
  } 
  Debug_Out(" / Returning: $v", 0);
  if (!$v) { 0; } else { $v; }
}

sub AsgmYarn($tt, $yarn, $asgmOP, $value) {
  our %m;
  my $v = GetYarn($tt, $yarn) ? GetYarn($tt, $yarn) : 0;
  my $e = '$v '.$asgmOP.$value;
  my $r = eval $e;
  Debug_Out("($tt, $yarn, $asgmOP, $value) { :=($e):=$r; }");
  $m{"yarn"}[$tt]{$yarn} = $v;
  $m{"yarn*"}{$yarn} = $v;
}




################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################


sub SetPKnitCode($knit, $code) {
  our %m;
  $m{"pknit"}{$knit}{code} = $code;
}

sub SetPKnitCond($knit, $num, $cond) {
  our %m;
  $m{"pknit"}{$knit}{"cond"}[$num] = $cond;
}
sub SetPKnitAsgm($knit, $num, $asgm) {
  our %m;
  $m{"pknit"}{$knit}{"asgm"}[$num] = $asgm;
}
sub SetCKnitYarn($knit, $yarn, $ymod, $yocc) {
  our %m;
  $m{"Cyarn2knit"}{$yarn}{$knit} .= "<$yocc,$ymod>";    
  $m{"Cknit2yarn"}{$knit}{$yarn} .= "<$yocc,$ymod>";    
}
sub PCode2CLink($knit, $code, $occr) {
  while ($code =~ /<<(.)\|([^|^<<>]+)>/g) {
    SetCKnitYarn($knit, $2, $1, $occr);
  }
}

sub SetCKnit($knit)  {
  our %m;
  my $Pcond  = $m{"pknit"}{$knit}{"cond"}[0];
  $m{"cknit"}{$knit}{"cond"}[0] = come_plib::parser::P2C($Pcond,0);
  PCode2CLink($knit, $Pcond, "c");
  my $asgms = $m{"pknit"}{$knit}{"asgm"};
  foreach my $i (0 .. $#$asgms) {
    my $Pasgm = $m{"pknit"}{$knit}{"asgm"}[$i];
    PCode2CLink($knit, $Pasgm, "a");
    $m{"cknit"}{$knit}{"asgm"}[$i] = come_plib::parser::P2C($m{"pknit"}{$knit}{"asgm"}[$i] ,1);
  }

  $m{"cknit"}{$knit}{"wild"}    = GetCKnitWild($knit, ".");
  my @args = keys %{$m{"cknit"}{$knit}{"wild"}};
  my $_code = "\nsub CKnitCode_$knit(\$tt, \$a".join(", \$a", @args).") {";
  $_code .= "\n if (".$m{"cknit"}{$knit}{"cond"}[0].") {";
  foreach my $i (0 .. $#$asgms) {
     $_code .= "\n  ".$m{"cknit"}{$knit}{"asgm"}[$i].";";
  }
  $_code .= "\n }\n}";
  foreach my $arg (@args) {
    $_code =~ s/\[\*$arg\*\]/\[\$a$arg\]/g;
  }

  $m{"cknit"}{$knit}{"code"} = $_code;
  eval $_code;# or die "ERROR: SetCKnit($knit) ERROR: Knit konnte nicht kompiliert werden: \n$@\n".$_code;
  Debug_Out("($knit): $@");

  #print "\nRETURN: $@";
}

sub GetCKnitYarn($knit, $type, $withwild=0, $wild=1) {
  our %m;
  my $a = $m{"Cknit2yarn"}{$knit};
  my @yarns;
  foreach my $y (keys %$a) {
    #$1 = undefined;
    if ((!$wild or $y =~ /(\[\*\d+\*\])/) and $$a{$y} =~ /<$type\,/) {
      if ($withwild) {
        $y =~ /\[\*(\d+)\*\]/;
        push(@yarns, [$y, $1]);
      } else {
        push(@yarns, $y) 
      }      
    }
  }
  @yarns;
}
sub GetCKnitWild($knit, $type) {
  my @a = GetCKnitYarn($knit, $type, 1);
  my %w;
  foreach my $aa (@a) {
    if (!exists($w{$$aa[1]})) { 
      $w{$$aa[1]} = [$$aa[0]];
    } else {
      push @{$w{$$aa[1]}}, $$aa[0];
    }
  }
  \%w;
}


sub tick() {
  our %m;
  my $tt = $m{"tt"};
  Debug_Out("(m{tt}:=$m{tt})");
  
  foreach my $cknit (keys %{$m{cknit}}) {
    my @wild_cartesian;
    foreach my $wild (keys %{$m{cknit}{$cknit}{wild}}) {
      Debug_Out(" knit $cknit / wild $wild #wc".$#wild_cartesian);		
      my $reg = come_plib::parser::cyarnwild2regexp($m{cknit}{$cknit}{wild}{$wild});
      Debug_Out(" -> ryarn2cknitargs($reg) ->", 0);	
      my @ryarns = keys %{$m{"yarn*"}};	
      my @warg = come_plib::parser::ryarn2cknitargs($reg, \@ryarns);
      Debug_Out(Data::Dumper::Dumper(\@warg), 0);
      if ($#wild_cartesian == -1) {
        @wild_cartesian = map { ", ".$_ } @warg;
      } else {
        print "\nWhat?";
      # map{ my $x = $_; map { [$x, $_] } @ys } @xs;
      }
      Debug_Out(" wild_cartesian: ".Data::Dumper::Dumper(\@wild_cartesian));
    }
    foreach my $args (@wild_cartesian) {
      my $e = "CKnitCode_$cknit($tt $args)";
      Debug_Out(" calling $e");
      eval $e;
      Debug_Out(Data::Dumper::Dumper(\$@));
    }
  }
  $m{"tt"}++;
}

sub SetCode($code) {
  our %m;
  my ($mode, $err, $i) = (0, 0, 0);
  $m{code}[$m{tt}] .= "\t$code\n";
  Debug_Out("$code");
  while (length($code) > 0 and $err == 0 and $mode >= 0) {
    $i++;
    if ($i==100) { return; }
    my ($kS, $kE, $yS, $yE) = (index($code, "/#"), index($code, "#\\"), index($code, "<#"), index($code, "#>"));
    Debug_Out("(kS, kE, yS, yE) = $kS, $kE, $yS, $yE");

    # next is a knit
    if ($kS >= 0 and ($yS == -1 or $kS < $yS)) {
      my $knit = substr($code, $kS, $kE);
      Debug_Out(" k:=$knit");
      if ($knit =~ /(\w[\w|\d]+)\|([^:^:]+)\:\:(.*)/) {
        my $k = $1;
        SetPKnitCode($k, $knit);
        SetPKnitCond($k, 0, $2);
        my $j=0;
        foreach my $asgm (split /;/, $3) {
          SetPKnitAsgm($k, $j++, $asgm);
        }
        SetCKnit($k);
      }
      $code = substr($code, $kE);
    }

  # next are assignments "<#y1?=v1;...;yN?=vN#>"
  if ($yS >= 0 and ($kS == -1 or $yS < $yE)) {	
      $code =~ /<#([^#>]+)#>/;
      my $asgms = $1;
      if ($m{"debug"}) { print " / asgms = $asgms"; }
      foreach my $asgm (split /;/, $asgms) {
      $asgm =~ s/^\s+|\s+$//g;
      Debug_Out("Asgm: (".$asgm.")");
          $asgm =~ /([^:]*):=(.*)/;
      if (index($asgm, '_') == 0)  {
        if (index($asgm, '_tt+') == 0) { tick(); }
        elsif (index($asgm, '_out0') == 0) {
          if ($2 eq "code")     { print come_plib::io::DumpCodeTxt(\%come_plib::base::m); } 
          if ($2 eq "yarn")     { print come_plib::io::DumpYarnTxt(\%come_plib::base::m); }
          if ($2 eq "dump_all") { print "\n".come_plib::io::DumpAll(\%come_plib::base::m); }		
          if ($2 =~ /help(\d*)/)     { come_plib::help::help($1); }		
        }
        elsif (index($asgm, '_exit') == 0) { exit; }
        elsif (index($asgm, '_html_dump') == 0) { 
          come_plib::io::DumpHTMLfile(\%come_plib::base::m, $2);
        }
        else { print "\nERROR: unknown System-Command or Variable: $asgm"; }
      } else {
        $asgm =~ /([^:]*):=(.*)/;
        #print "\nSetYarn mit $asgm $1, $2";
        SetYarn($1, ":=", eval($2));
      }
    }
    $code = substr($code, $yE);
    }
    if ($kS + $yS == -2) { $mode=-1; }
  }
  Debug_Out("SetCode-end\n");
}

sub InitMesh() {
  our %m;
  $m{kfg}{version} = ".01.20181216";
  $m{kfg}{debug} = 0;
  $m{kfg}{time}  = "EXPLICIT";
  $m{kfg}{asgms} = "IMMEDIATE";
  print "/#\\ COME-Condition Mesh v$m{kfg}{version} | (c) 2018, Daniel Mueller | for help type <#_out0:=help#> |";
  print " running in debug mode: NO DEBUG, time tick mode: $m{kfg}{time}, assignment mode: $m{kfg}{asgms}\n";
  $m{"tt"} = 0;
}

1;