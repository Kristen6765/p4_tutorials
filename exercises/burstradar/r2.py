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

def handle_pkt(pkt):
    if TCP in pkt :
        print ("got a packet")
        pkt.show()
    #    hexdump(pkt)
        sys.stdout.flush()


def main():
    ifaces = list(filter(lambda i: 'eth' in i, os.listdir('/sys/class/net/')))
    iface = ifaces[0]
    print ("sniffing on %s" % iface)
    sys.stdout.flush()
    sniff(iface = iface,
          prn = lambda x: handle_pkt(x))

if __name__ == '__main__':
    main()
