#!/usr/bin/perl -w
use strict;
use Math::BaseCalc;

#
# SEE-1111-2222-3333
# Buchstabenwuerfler: SEE-[2.1][1.2][3.2][2.4]-[2.3][3.1][3.4][1.1]-[1.3][3.3][1.4][2.2]
# 
# 1: Laufende Nummer zur Basis 36
# 2: Zufallszahl, durch 42 teilbar
# 3: Füllzahl fuer (SEE+1111+2222+3333) mod 42 = 0
#

my $calc36 = new Math::BaseCalc(digits=>[0..9,'A'..'Z']);


# 0-50000 reserved :
# 40000 ADA
# 48000-48999 : direct customers (see direct.txt)
# 49899 Omni cross-licencing (20 seats)
# 49900 iDive cross-licencing
# 49943 Ben Schwan (metamac tausch)
# 49944 tommy
# 49945 technorati (20 seats)
# 49946 wayne smallman (esellerate sucks)
# 49947 Volker Weber (gmail Account)
# 49948-49963 Laminierte Pappkameraden
# 49964 Aaron Hilton (Paypal)
# 49965 Atlassian (site)
# 49966 Panic
# 49967-49968 Isao und Kosake
# 49969-49999 Donations
# 50000-60000 eSellerate

for (my $i=49943;$i<49944;$i++) {
    print serialnumber($i)."\n";
}

sub serialnumber {
    (my $number) = @_;
    my $randomnumber = randomfortytwo();
    my $prefix = $calc36->from_base("SEE");
    my $chksum = chksum($prefix+$number+$randomnumber);
    
    my $group1 = leadingzero($calc36->to_base($number));
    my $group2 = $calc36->to_base($randomnumber);
    my $group3 = $calc36->to_base($chksum);
    
    return "SEE-".bithaecksler("$group1-$group2-$group3");
}

sub bithaecksler {
    (my $string) = @_;
    #               1  2  3  4   5  6  7  8   9  10 11 12   
    $string =~  s/^(.)(.)(.)(.)-(.)(.)(.)(.)-(.)(.)(.)(.)/$5$2$10$8-$7$9$12$1-$3$11$4$6/;
    return $string;
}

sub chksum {
    (my $sum) = @_;
    my $c = (1111 + int(rand(20000))) * 42; # be sure its 4 chars and random
    while ((($c+$sum)%4242) != 0) { $c++; }
    return $c;
}

sub randomfortytwo {
    my $result = (1111 + int(rand(38880))) * 42; # be sure its 4 chars and random
    return $result;
}

sub leadingzero {
    (my $s) = @_;
    if (length($s) == 1) {$s = "000$s";}
    if (length($s) == 2) {$s = "00$s";}
    if (length($s) == 3) {$s = "0$s";}
    return $s;
}
