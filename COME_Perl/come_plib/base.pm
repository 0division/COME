﻿=begin comment

 20181229 DM Implemented Asgm-Mode SPOOLING, even it makes no sence at all, in any case slower ;)


pknit - knit pattern
cknit - compiled knit
 cwy  - compiled wild yarn 
 


Separator generated with http://www.patorjk.com/software/taag/#p=display&f=Mini&t=YARN
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

################################################################################################
#### | \ |_ |_) | | /__  #######################################################################
#### |_/ |_ |_) |_| \_|  #######################################################################
################################################################################################
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
#### \_/ /\  |_) |\ |   ########################################################################
####  | /--\ | \ | \|   ########################################################################
################################################################################################

sub SetYarn($yarn, $value) {
  Debug_Out("($yarn, $value) / m{tt}=$m{tt} ");
  our %m;
  $m{"yarn*"}{$yarn} = $m{"yarn"}[$m{"tt"}]{$yarn} = $value; 
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
  Debug_Out("($tt, $yarn, $asgmOP, $value) / $m{kfg}{asgms}");
  if ($m{kfg}{asgms} eq "IMMEDIATE") {
    my $v = GetYarn($tt, $yarn); 
    if (not $v) { $v = 0; }
    my $e = '$v '.$asgmOP.$value;
    my $r = eval $e;
  	Debug_Out(" $e --> $r", 0);
    $m{"yarn"}[$tt]{$yarn} = $v;
    $m{"yarn*"}{$yarn} = $v;
  } elsif ($m{kfg}{asgms} eq "SPOOLING") {
  	if (not $m{"asgm"}[$tt]{$yarn}{$asgmOP}) {
  		@{$m{"asgm"}[$tt]{$yarn}{$asgmOP}} = eval $value; 
  	} else {
  		push @{$m{"asgm"}[$tt]{$yarn}{$asgmOP}}, eval $value
  	}  	
  } else {
  	die "unknown Asgm-Mode $m{kfg}{asgms}, it is only IMMEDIATE allowed";
  }
}




########################################################################################
###  _          ___ ___ ################################################################
### |_) |/ |\ |  |   |  ################################################################
### |   |\ | \| _|_  |  ################################################################
########################################################################################


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

########################################################################################
###  _         ___ ___  ################################################################
### /  |/ |\ |  |   |   ################################################################
### \_ |\ | \| _|_  |   ################################################################
########################################################################################

sub SetCKnitYarn($knit, $yarn, $ymod, $yocc) {
  our %m;    
  if ($m{kfg}{run} ne "BRUTEFORCE") { $m{"Cyarn2knit"}{$yarn}{$knit} .= "<$yocc,$ymod>"; } 
  $m{"Cknit2yarn"}{$knit}{$yarn} .= "<$yocc,$ymod>";    
}
sub PCode2CLink($knit, $code, $occr) {
  while ($code =~ /<<(.)\|([^|^<<>]+)>/g) {
    SetCKnitYarn($knit, $2, $1, $occr);
  }
}

sub SetCKnit($knit)  {
  our %m;
  
  # converting all the pcode into ccode (in this case perl code using subs in this library)
  my $Pcond  = $m{"pknit"}{$knit}{"cond"}[0];
  $m{"cknit"}{$knit}{"cond"}[0] = come_plib::parser::P2C($Pcond,0);
  PCode2CLink($knit, $Pcond, "c");
  my $asgms = $m{"pknit"}{$knit}{"asgm"};
  foreach my $i (0 .. $#$asgms) {
    my $Pasgm = $m{"pknit"}{$knit}{"asgm"}[$i];
    PCode2CLink($knit, $Pasgm, "a");
    $m{"cknit"}{$knit}{"asgm"}[$i] = come_plib::parser::P2C($m{"pknit"}{$knit}{"asgm"}[$i] ,1);
  }

  # creating the final perl-sub for this specific knit
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

# GetCKnitWild - Creates an array with wild card and corresponing regexp-yarn-names
#  arg:knit:string - 
#  arg:type:string - ".", "c" or "a" as type of yarn usage: c for condition, a for assignment and . for both 
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


########################################################################################
###            ___        ##############################################################
###  |\/|  /\   |  |\ |   ##############################################################
###  |  | /--\ _|_ | \|   ##############################################################
########################################################################################
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
  
  # do the asgm-SPOOLING if switched on
  if ($m{kfg}{asgms} eq "SPOOLING") {
    $tt = $m{"tt"};
   	my @yarns = keys %{$m{"asgm"}[$tt]};
  	foreach my $y (@yarns) {
  		my @ops = keys %{$m{"asgm"}[$tt]{$y}};
  		my ($op_plus, $op_minus, $op_mul, $op_div, $op_set) = (0, 0, 0, 0, 0);
  		foreach my $op (@ops) {
  			if ($op eq "+=") { $op_plus  = 1; }
  			if ($op eq "-=") { $op_minus = 1; }
  			if ($op eq "*=") { $op_mul   = 1; }
  			if ($op eq "/=") { $op_div   = 1; }
  			if ($op eq ":=") { $op_set   = 1; }
  	  }
  	  if ($op_set == 1) {
  	  	die "Assignment Operator := is NOT IMPLEMENTED YET in SPOOLING-Mode";
  	  } else {
  	  	my $v2 = GetYarn($tt, $y); 
  	  	if (not $v2) { $v2 = 0; }
  	    my $asgm_str = "";
  	  	if ($op_mul)   { $asgm_str .= "*".join ("*", @{$m{"asgm"}[$tt]{$y}{"*="}});  }
  			if ($op_div)   { $asgm_str .= "/(".join("*", @{$m{"asgm"}[$tt]{$y}{"/="}}).")"; }
   			if ($op_plus)  { $asgm_str .= "+".join ("+", @{$m{"asgm"}[$tt]{$y}{"+="}});  }
  			if ($op_minus) { $asgm_str .= "-".join ("+", @{$m{"asgm"}[$tt]{$y}{"-="}});  }
  	    Debug_Out("Asgm ".'$v2 = $v2 '.$asgm_str.";";
  			my $r = eval '$v2 = $v2 '.$asgm_str;
        $m{"yarn"}[$tt]{$y} = $v2;
        $m{"yarn*"}{$y} = $v2;
  	  }
  		print "\n\nSPOOLinG-asgm-ops:". Data::Dumper::Dumper(\@ops);
    }
  	print "\n\nSPOOLinG:". Data::Dumper::Dumper($m{"asgm"});
  }
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
        elsif (index($asgm, '_mode') == 0) {
        	if ($asgm eq "asgm_mode" and ($2 eq "IMMEDIATE" or $2 eq "SPOOLING")) {
        		$m{kfg}{asgms} = $2;
        	}
        }
        elsif (index($asgm, '_html_dump') == 0) { 
          come_plib::io::DumpHTMLfile(\%come_plib::base::m, $2);
        }
        else { print "\nERROR: unknown System-Command or Variable: $asgm"; }
      } else {
        $asgm =~ /([^:]*):=(.*)/;
        #print "\nSetYarn mit $asgm $1, $2";
        SetYarn($1, eval($2));
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
  $m{kfg}{version} = ".01.20181224";
  $m{kfg}{debug} = 0;
  $m{kfg}{time}  = "EXPLICIT";
  $m{kfg}{asgms} = "IMMEDIATE";  
  $m{kfg}{run} = "BRUTEFORCE";  
  print "/#\\ COME-Condition Mesh v$m{kfg}{version} | (c) 2018, Daniel Mueller | for help type <#_out0:=help#>";
  print "\n running in debug mode: NO DEBUG, time tick mode: $m{kfg}{time}, assignment mode: $m{kfg}{asgms}, run-mode: $m{kfg}{run}\n";
  $m{"tt"} = 0;
}

1;