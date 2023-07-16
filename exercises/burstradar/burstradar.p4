/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;
const bit<32> TYPE_EGRESS_CLONE = 2;
#define IS_E2E_CLONE(std_meta) (std_meta.instance_type == TYPE_EGRESS_CLONE)
const bit<32> E2E_CLONE_SESSION_ID = 11;


const bit<16> TCP_PORT = 3333;
#define THRESHOLD 1
#define SIZE_OF_ENTRY 320 // 34+6 bytes
#define SIZE_OF_HTTP_PAYLOAD 272 // 34 bytes
#define TYPE_TELEMETRY 31
#define MAX_ENTRIES  20


#define TCP_PAYLOAD_SIZE 512
/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t { // 48 + 48 + 16 = 14 bytes
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t { //4+4+8+16+16+3+13+8+8+16+32+32 = 16 bytes
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}


header telemetry20_t{
  bit<96> ipport; //12 bytes
  bit<SIZE_OF_ENTRY> msg1;
  bit<SIZE_OF_ENTRY> msg2;
  bit<SIZE_OF_ENTRY> msg3;
  bit<SIZE_OF_ENTRY> msg4;
  bit<SIZE_OF_ENTRY> msg5;
  bit<SIZE_OF_ENTRY> msg6;
  bit<SIZE_OF_ENTRY> msg7;
  bit<SIZE_OF_ENTRY> msg8;
  bit<SIZE_OF_ENTRY> msg9;
  bit<SIZE_OF_ENTRY> msg10;
  bit<SIZE_OF_ENTRY> msg11;
//   bit<SIZE_OF_ENTRY> msg12;
//   bit<SIZE_OF_ENTRY> msg13;
//   bit<SIZE_OF_ENTRY> msg14;
//   bit<SIZE_OF_ENTRY> msg15;
}

// 16+16+32+32+4+3+3+6+16+16+16=20bytes
header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<3>  res;
    bit<3>  ecn;
    bit<6>  ctrl;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
    bit<96> option;
}

header http_t{
    bit<SIZE_OF_HTTP_PAYLOAD> httpData;
}

struct metadata {
    bit<1> flag; // metadata for each packet
    bit<7> index;
}

struct headers {
    ethernet_t    ethernet;
    ipv4_t        ipv4;

    
    tcp_t    tcp;  
    telemetry20_t   tm20; 
    http_t    http;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start { 
        transition parse_ethernet; 
    }
    state parse_ethernet{
        packet.extract(hdr.ethernet);        
        transition select(hdr.ethernet.etherType){ 
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    } 
    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            6: parse_tcp;
            default: accept;
        }
    }    
    state parse_tcp {
        packet.extract(hdr.tcp);
        transition select(hdr.tcp.dstPort,hdr.tcp.srcPort){
            (TCP_PORT,_): parse_http;
            (_,TCP_PORT): parse_http;
            default : accept;
        }
    } 

    state parse_http{
        packet.extract(hdr.http);
        transition accept;
    }
}


/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    action drop() {
        mark_to_drop(standard_metadata); 
    }
    
    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr; 
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
        standard_metadata.egress_spec = port;  
    }
    
    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = NoAction();
    }
    
    apply {
        if(hdr.ipv4.isValid()){
        ipv4_lpm.apply();
        }
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
 
 
//  register<bit<SIZE_OF_ENTRY_MAX_ENTRIES>>(6) ring_buffer; 
 bit<SIZE_OF_ENTRY> data; // to move data to register 
//  bit<SIZE_OF_ENTRY_MAX_ENTRIES> data_clone; // to extract data from register and transfer it to cloned packet
//  register<bit<1024>>(1) counter;
 bit<1024> curCounter;

 register<bit<1>>(1) isInitialized; // indicate if nessary registers are set
 register<bit<32>>(1) index_flow1;
 register<bit<(SIZE_OF_ENTRY)>>(11) registerFlow1;
 register<bit<16>>(1) currentSize; // total tcp payload saved for a flow, 0 <= currentSize <= maxSizeForTcpPayload
 register<bit<16>>(1) maxSizeForTcpPayload;
 bit<SIZE_OF_ENTRY> mirror_data;
 register<bit<96>>(1) sRDstPortIp; 
 bit<96> data0;

 
 action initialize(){
    isInitialized.write(0,1);
    index_flow1.write(0,0);
    currentSize.write(0,0);
    // bit<16> tmp = (1500-50-16)*8;
    // bit<16> tmp = 1280;
    bit<16> tmp = 320*11+96;
    maxSizeForTcpPayload.write(0,tmp);
 }

 action do_clone_e2e(){
  clone_preserving_field_list(CloneType.E2E,E2E_CLONE_SESSION_ID,1);
 } 

 action assemble_packet() {
    hdr.tm20.setValid();
    bit<96> tmp;
    sRDstPortIp.read(tmp,0);
    hdr.tm20.ipport=tmp;
    registerFlow1.read(mirror_data, 0);
    hdr.tm20.msg1=mirror_data;
    registerFlow1.read(mirror_data, 1);
    hdr.tm20.msg2=mirror_data;
    registerFlow1.read(mirror_data, 2);
    hdr.tm20.msg3=mirror_data;
    registerFlow1.read(mirror_data, 3);
    hdr.tm20.msg4=mirror_data;
     registerFlow1.read(mirror_data, 4);
    hdr.tm20.msg5=mirror_data;
     registerFlow1.read(mirror_data, 5);
    hdr.tm20.msg6=mirror_data;
     registerFlow1.read(mirror_data, 6);
    hdr.tm20.msg7=mirror_data;
     registerFlow1.read(mirror_data, 7);
    hdr.tm20.msg8=mirror_data;
     registerFlow1.read(mirror_data, 8);
    hdr.tm20.msg9=mirror_data;
     registerFlow1.read(mirror_data, 9);
    hdr.tm20.msg10=mirror_data;
     registerFlow1.read(mirror_data, 10);
    hdr.tm20.msg11=mirror_data;
    // registerFlow1.read(mirror_data, 11);
    // hdr.tm20.msg12=mirror_data;
    // registerFlow1.read(mirror_data, 12);
    // hdr.tm20.msg13=mirror_data;
    // registerFlow1.read(mirror_data, 13);
    // hdr.tm20.msg14=mirror_data;
    // need to hard code more...
        truncate(1000);

 }
 action mark_packet(){
        // hdr.ipv4.srcAddr
        // hdr.ipv4.dstAddr
        // hdr.tcp.srcPort
        // hdr.tcp.dstPort
        // standard_metadata.ingress_global_timestamp
        // standard_metadata.egress_global_timestamp
        // hdr.http.httpData
        // 32 + 32 + 16 + 16 + 48 + 48 + 160*2 = 512
        // data = hdr.ipv4.srcAddr ++ hdr.ipv4.dstAddr ++ hdr.tcp.srcPort ++ hdr.tcp.dstPort ++ standard_metadata.ingress_global_timestamp ++
        // standard_metadata.egress_global_timestamp ++ hdr.http.httpData; // concatenate all required fields into one bitstring 
       data = hdr.http.httpData ++ standard_metadata.egress_global_timestamp; // concatenate all required fields into one bitstring 
    
        // add data to regiter array
        bit<32> index;
        index_flow1.read(index,0);
        registerFlow1.write(index, data);
        index_flow1.write(0,index+1);

        // update currentSize
        bit<16> tmp3;
        currentSize.read(tmp3,0);
        tmp3 = tmp3 + SIZE_OF_ENTRY;
        currentSize.write(0,tmp3);
 }

 action assemble_port_ip(){
        data0 = hdr.ipv4.srcAddr ++ hdr.ipv4.dstAddr ++ hdr.tcp.srcPort ++ hdr.tcp.dstPort;
        sRDstPortIp.write(0,data0);

        // update currentSize
        bit<16> tmp3;
        currentSize.read(tmp3,0);
        tmp3 = tmp3 + 96;
        currentSize.write(0,tmp3);
 }

 table generate_clone{
  actions = {
   do_clone_e2e;
   NoAction;
  }
  default_action = NoAction();
 }

 apply {  // index and bytesRemaining register values are initialized to 0 from the control plane (simple_switch_CLI)
  if(!IS_E2E_CLONE(standard_metadata)){ 
     if(hdr.http.isValid() && hdr.ipv4.totalLen>100 && hdr.tcp.srcPort==3333){
        bit<1> tmp0;
        isInitialized.read(tmp0,0);
        if(tmp0 == 0){
            // if a 100 flow only need n packets, the initialize funciton will only be called n times
            initialize();
        }

        bit<16> tmp;
        currentSize.read(tmp,0);
        bit<16> tmp2; 
        maxSizeForTcpPayload.read(tmp2,0);
        if(tmp == 0) {
            assemble_port_ip();
        }else if(tmp + SIZE_OF_ENTRY > tmp2 ) {
            generate_clone.apply();
            currentSize.write(0,0);
            isInitialized.write(0,0);
        }else{
            mark_packet();
        }
      }  
  }else{
        assemble_packet();
  }
 }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
     apply {

 update_checksum(
     hdr.ipv4.isValid(),
            { hdr.ipv4.version,
       hdr.ipv4.ihl,
              hdr.ipv4.diffserv,
              hdr.ipv4.totalLen,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.fragOffset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.srcAddr,
              hdr.ipv4.dstAddr },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16);
    }
}


/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        /* TODO: add deparser logic */
    packet.emit(hdr.ethernet); 
    packet.emit(hdr.ipv4);
    packet.emit(hdr.tcp);
    packet.emit(hdr.tm20);
    packet.emit(hdr.http);
    log_msg(" dpasser: tm20 valid: {}", {hdr.tm20.isValid()});
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;