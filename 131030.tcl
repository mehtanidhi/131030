# Assignment 1

# Event scheduler
set ns [new Simulator]

#Assigning colors
$ns color 1 Blue
$ns color 2 Red

#opening files
set tracefile1 [open out.tr w]
set winfile [open winfile w]
$ns trace-all $tracefile1
set namfile [open out.nam w]
$ns namtrace-all $namfile

proc finish {} \
{
global ns tracefile1 namfile
$ns flush-trace
close $tracefile1
close $namfile
exec nam out.nam &
exit 0
}

# setting all the nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]

# setting links between nodes
$ns duplex-link $n0 $n1 2Mb 30ms DropTail
$ns duplex-link $n1 $n2 2Mb 30ms DropTail
$ns duplex-link $n0 $n3 2Mb 30ms DropTail
$ns duplex-link $n2 $n3 2Mb 30ms DropTail
$ns duplex-link $n4 $n6 2Mb 30ms DropTail
$ns duplex-link $n4 $n5 2Mb 30ms DropTail
$ns duplex-link $n5 $n6 2Mb 30ms DropTail
$ns duplex-link $n6 $n8 2Mb 30ms DropTail
$ns duplex-link $n6 $n7 2Mb 30ms DropTail
$ns duplex-link $n9 $n10 2Mb 30ms DropTail

# setting lan connection between 2,4 and 9
set lan [$ns newLan "$n2 $n4 $n9" 0.5Mb 40ms LL Queue/Droptail MAC/Csma/Cd Channel]

# designing the layout
$ns duplex-link-op $n0 $n1 orient left
$ns duplex-link-op $n1 $n2 orient down
$ns duplex-link-op $n3 $n2 orient left-down
$ns duplex-link-op $n0 $n3 orient right
$ns duplex-link-op $n4 $n5 orient left
$ns duplex-link-op $n4 $n6 orient left-down
$ns duplex-link-op $n6 $n5 orient left-up
$ns duplex-link-op $n6 $n7 orient left
$ns duplex-link-op $n6 $n8 orient right
$ns duplex-link-op $n9 $n10 orient right


#Seting TCP connection between node 2 and 7
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packet_size_ 552

#setting ftp
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#setting UDP connection between node 1 and 10
set udpa [new Agent/UDP]
$ns attach-agent $n1 $udpa
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udpa $null
$udpa set fid_ 2

#setting cbr
set cbra [new Application/Traffic/CBR]
$cbra attach-agent $udpa
$cbra set packet_size_ 1000
$cbra set rate_ 0.01Mb
$cbra set random_ false

#Setting UDP between nodes 8 and 0 
set udpb [new Agent/UDP]
$ns attach-agent $n8 $udpb
set null [new Agent/Null]
$ns attach-agent $n0 $null
$ns connect $udpb $null
$udpb set fid_ 3

#setting cbr
set cbrb [new Application/Traffic/CBR]
$cbrb attach-agent $udpb
$cbrb set packet_size_ 1000
$cbrb set rate_ 0.01Mb
$cbrb set random_ false

#scheduling the events

$ns at 0.1 "$cbra start"
$ns at 0.1 "$cbrb start"
$ns at 1.0 "$ftp start"
$ns at 124.0 "$cbra stop"
$ns at 125.5 "$cbrb stop"

proc plotWindow {tcpSource file} {
global ns
set time 0.1
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file"
}

$ns at 0.1 "plotWindow $tcp $winfile"
$ns at 125.0 "finish"
$ns run

