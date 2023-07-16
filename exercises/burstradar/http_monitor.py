#!/usr/bin/env python3
import sys
import struct
import os
from scapy.all import sniff, sendp, hexdump, get_if_list, get_if_hwaddr
from scapy.all import Packet, IPOption
from scapy.fields import ShortField, IntField, LongField, BitField, FieldListField, FieldLenField, SourceIPField, Emph, ShortEnumField, ByteEnumField, ByteField
from scapy.all import IP, TCP, UDP, Raw
from scapy.layers.inet import _IPOption_HDR, DestIPField
from scapy.data import IP_PROTOS, TCP_SERVICES
def get_if():
    ifs=get_if_list()
    iface=None
    for i in get_if_list():
        print(i) 
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print ("Cannot find eth0 interface")
        exit(1)
    return iface

class IPOption_TELEMETRY(IPOption):
    name = "TELEMETRY"
    option = 31
    fields_desc = [ _IPOption_HDR,
			ByteField("length", 2),
			Emph(SourceIPField("src", "dst")),
                   	Emph(DestIPField("dst", "127.0.0.1")),
			ShortEnumField("sport", 20, TCP_SERVICES),
			ShortEnumField("dport", 80, TCP_SERVICES),
            ByteEnumField("proto", 0, IP_PROTOS),
			BitField("ingress_timestamp", 0, 48),
			BitField("egress_timestamp", 0, 48),
			BitField("http_data", 0, 160),
			BitField("padding", 0, 16) ]

def handle_pkt(pkt):
    if TCP in pkt :
        print ("got a packet")
        pkt.show2()
    #    hexdump(pkt)
        sys.stdout.flush()


def main():
    ifaces = list(filter(lambda i: 'eth0' in i, os.listdir('/sys/class/net/')))
    iface = ifaces[0]
    print ("sniffing on %s" % iface)
    sys.stdout.flush()
    sniff(iface = iface,
          prn = lambda x: handle_pkt(x))

if __name__ == '__main__':
    main()
