control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
 
 
 bit<SIZE_OF_ENTRY> data; // to move data to register 
 register<bit<1>>(1) isInitialized; // indicate if nessary registers are set
 register<bit<32>>(1) index_flow1; // index of the register array
 register<bit<(SIZE_OF_ENTRY)>>(11) registerFlow1;
 register<bit<16>>(1) currentSize; // total tcp payload saved for a flow, 0 <= currentSize <= maxSizeForTcpPayload
 #define MAX_SIZE_TCP_PAYLOAD 3616 //320*11+96
 register<bit<96>>(1) sdportIP; 

 
 action initialize(){
    isInitialized.write(0,1);
    index_flow1.write(0,0);
    currentSize.write(0,0);
    // bit<16> tmp = 320*11+96;
    // maxSizeForTcpPayload.write(0,tmp);
 }

 action do_clone_e2e(){
  clone_preserving_field_list(CloneType.E2E,E2E_CLONE_SESSION_ID,1);
 } 

 action assemble_packet() {
    hdr.tm20.setValid();
    bit<96> tmp;
    sdportIP.read(tmp,0);
    hdr.tm20.ipport=tmp;
    bit<SIZE_OF_ENTRY> mirror_data;
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
    truncate(1000);
 }
 action mark_packet(){
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
        bit<96> data0;
        data0 = hdr.ipv4.srcAddr ++ hdr.ipv4.dstAddr ++ hdr.tcp.srcPort ++ hdr.tcp.dstPort;
        sdportIP.write(0,data0);

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

 action flow1() {  // index and bytesRemaining register values are initialized to 0 from the control plane (simple_switch_CLI)
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
     //   maxSizeForTcpPayload.read(tmp2,0);
        if(tmp == 0) {
            assemble_port_ip();
        }else if(tmp + SIZE_OF_ENTRY > MAX_SIZE_TCP_PAYLOAD) {
            generate_clone.apply();
            currentSize.write(0,0);
            isInitialized.write(0,0);
        }else{
            mark_packet();
        }
  }else{
        assemble_packet();
  }
  }
 }
/////////////////////////////////////////////////////////////////////////////
////////////////////////////////flow2////////////////////////////////////////
bit<SIZE_OF_ENTRY> data_flow2; // to move data to register 
 register<bit<1>>(1) isInitialized_flow2; // indicate if nessary registers are set
 register<bit<32>>(1) index_flow2; // index of the register array
 register<bit<(SIZE_OF_ENTRY)>>(11) registerFlow2;
 register<bit<16>>(1) currentSize_flow2; // total tcp payload saved for a flow, 0 <= currentSize <= maxSizeForTcpPayload
 #define MAX_SIZE_TCP_PAYLOAD 3616 //320*11+96
 register<bit<96>>(1) sdportIP_flow2; 

 
 action initialize_f2(){
    isInitialized_flow2.write(0,1);
    index_flow2.write(0,0);
    currentSize_flow2.write(0,0);
    // bit<16> tmp = 320*11+96;
    // maxSizeForTcpPayload.write(0,tmp);
 }


 action assemble_packet_f2() {
    hdr.tm20.setValid();
    bit<96> tmp;
    sdportIP_flow2.read(tmp,0);
    hdr.tm20.ipport=tmp;
    bit<SIZE_OF_ENTRY> mirror_data;
    registerFlow2.read(mirror_data, 0);
    hdr.tm20.msg1=mirror_data;
    registerFlow2.read(mirror_data, 1);
    hdr.tm20.msg2=mirror_data;
    registerFlow2.read(mirror_data, 2);
    hdr.tm20.msg3=mirror_data;
    registerFlow2.read(mirror_data, 3);
    hdr.tm20.msg4=mirror_data;
    registerFlow2.read(mirror_data, 4);
    hdr.tm20.msg5=mirror_data;
    registerFlow2.read(mirror_data, 5);
    hdr.tm20.msg6=mirror_data;
    registerFlow2.read(mirror_data, 6);
    hdr.tm20.msg7=mirror_data;
    registerFlow2.read(mirror_data, 7);
    hdr.tm20.msg8=mirror_data;
    registerFlow2.read(mirror_data, 8);
    hdr.tm20.msg9=mirror_data;
    registerFlow2.read(mirror_data, 9);
    hdr.tm20.msg10=mirror_data;
    registerFlow2.read(mirror_data, 10);
    hdr.tm20.msg11=mirror_data;
    truncate(1000);

 }
 action mark_packet_f2(){
       data_flow2 = hdr.http.httpData ++ standard_metadata.egress_global_timestamp; // concatenate all required fields into one bitstring 
    
        // add data to regiter array
        bit<32> index;
        index_flow2.read(index,0);
        registerFlow2.write(index, data_flow2);
        index_flow2.write(0,index+1);

        // update currentSize
        bit<16> tmp3;
        currentSize_flow2.read(tmp3,0);
        tmp3 = tmp3 + SIZE_OF_ENTRY;
        currentSize_flow2.write(0,tmp3);
 }

 action assemble_port_ip_f2(){
        bit<96> data0;
        data0 = hdr.ipv4.srcAddr ++ hdr.ipv4.dstAddr ++ hdr.tcp.srcPort ++ hdr.tcp.dstPort;
        sdportIP_flow2.write(0,data0);

        // update currentSize
        bit<16> tmp3;
        currentSize_flow2.read(tmp3,0);
        tmp3 = tmp3 + 96;
        currentSize_flow2.write(0,tmp3);
 }

 action flow2() {  // index and bytesRemaining register values are initialized to 0 from the control plane (simple_switch_CLI)
  if(!IS_E2E_CLONE(standard_metadata)){ 
     if(hdr.http.isValid() && hdr.ipv4.totalLen>100 && hdr.tcp.srcPort==3333){
        bit<1> tmp0;
        isInitialized_flow2.read(tmp0,0);
        if(tmp0 == 0){
            // if a 100 flow only need n packets, the initialize funciton will only be called n times
            initialize_f2();
        }

        bit<16> tmp;
        currentSize_flow2.read(tmp,0);
        bit<16> tmp2; 
     //   maxSizeForTcpPayload.read(tmp2,0);
        if(tmp == 0) {
            assemble_port_ip_f2();
        }else if(tmp + SIZE_OF_ENTRY > MAX_SIZE_TCP_PAYLOAD) {
            generate_clone.apply();
            currentSize_flow2.write(0,0);
            isInitialized_flow2.write(0,0);
        }else{
            mark_packet_f2();
        }
      }  
  }else{
        assemble_packet_f2();
  }
 }

////////////////////////////////start////////////////////////////////////////
action registerFlowAction(bit<4> flowID) {
    if(flowID == 1) {
        flow1();
    } else if (flowID == 2) {
        flow2();
    }
}
//table_add flow_register registerFlowAction 10.0.1.1&&&255.255.255.255 10.0.3.3&&&255.255.255.255 0&&&0 3333&&&0 => 1


//table_add flow_register registerFlowAction 10.0.3.3&&&255.255.255.255 10.0.1.1&&&255.255.255.255 3333&&&0 0&&&0 => 1
//table_add flow_register registerFlowAction 10.0.3.3&&&255.255.255.255 10.0.2.2&&&255.255.255.255 3333&&&0 0&&&0 => 2

 table flow_register {
    key = {
        hdr.ipv4.srcAddr: ternary;
        hdr.ipv4.dstAddr: ternary;
        hdr.tcp.srcPort : ternary;
        hdr.tcp.dstPort : ternary;
    }
    actions = {
        registerFlowAction;
    }
 }
}