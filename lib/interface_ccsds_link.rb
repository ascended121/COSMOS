require 'cosmos' # always require cosmos
require 'cosmos/interfaces/serial_interface' # original interface being extended
require 'int_fcn.rb'


module Cosmos
class InterfaceCcsdsLink < SerialInterface
  def pre_write_packet(packet)
  
    # packet.buffer appears to be a string and is hard to manipulate
    data = packet.buffer
    
    # if the packet is not a link message, prepend a LINK command to foward
    # the message to the appropriate payload
    if(!isLinkPkt(data))
      puts "Found non-link packet!"
      
      # update the packet length for the LINK forward command
      data = update_ccsds_length(data)
    
      # update the packet checksum for the LINK forward command
      data = update_ccsds_checksum(data)
      
      # prepend the link command to forward the data if its not a link command
      data = prepend_fwdmsgcmd(data)
      
    else
      puts "Found link packet!"
    end
   
    # update the packet length for the packet being sent
    data = update_ccsds_length(data)
    
    # update the packet checksum for the packet being sent
    data = update_ccsds_checksum(data)
            
    p data
    
    return data
  end

  def post_read_data(packet_data)

    # loop through the packet to calculate the checksum
    #packet_data.each_byte {|x| calc_checksum ^= x }
    p "Received: "
    p packet_data
    
    if packet_data.include?("pkts") && packet_data.include?("txe") && packet_data.include?("rxe") && packet_data.include?("stx")

      nodeid = ["%02x" % packet_data[/\[(\d+)\] pkts: (\d+) txe=(\d+) rxe=(\d+) stx=(\d+) srx=(\d+) ecc=(\d+)\/(\d+) temp=(\d+) dco=(\d+)/,1].to_i].pack("H*")
      pkts = ["%02x" % packet_data[/\[(\d+)\] pkts: (\d+) txe=(\d+) rxe=(\d+) stx=(\d+) srx=(\d+) ecc=(\d+)\/(\d+) temp=(\d+) dco=(\d+)/,2].to_i].pack("H*")
      txe = ["%02x" % packet_data[/\[(\d+)\] pkts: (\d+) txe=(\d+) rxe=(\d+) stx=(\d+) srx=(\d+) ecc=(\d+)\/(\d+) temp=(\d+) dco=(\d+)/,3].to_i].pack("H*")
      rxe = ["%02x" % packet_data[/\[(\d+)\] pkts: (\d+) txe=(\d+) rxe=(\d+) stx=(\d+) srx=(\d+) ecc=(\d+)\/(\d+) temp=(\d+) dco=(\d+)/,4].to_i].pack("H*")
      stx = ["%02x" % packet_data[/\[(\d+)\] pkts: (\d+) txe=(\d+) rxe=(\d+) stx=(\d+) srx=(\d+) ecc=(\d+)\/(\d+) temp=(\d+) dco=(\d+)/,5].to_i].pack("H*")
      srx = ["%02x" % packet_data[/\[(\d+)\] pkts: (\d+) txe=(\d+) rxe=(\d+) stx=(\d+) srx=(\d+) ecc=(\d+)\/(\d+) temp=(\d+) dco=(\d+)/,6].to_i].pack("H*")
      ecc1 = ["%02x" % packet_data[/\[(\d+)\] pkts: (\d+) txe=(\d+) rxe=(\d+) stx=(\d+) srx=(\d+) ecc=(\d+)\/(\d+) temp=(\d+) dco=(\d+)/,7].to_i].pack("H*")
      ecc2 = ["%02x" % packet_data[/\[(\d+)\] pkts: (\d+) txe=(\d+) rxe=(\d+) stx=(\d+) srx=(\d+) ecc=(\d+)\/(\d+) temp=(\d+) dco=(\d+)/,8].to_i].pack("H*")
      temp = ["%02x" % packet_data[/\[(\d+)\] pkts: (\d+) txe=(\d+) rxe=(\d+) stx=(\d+) srx=(\d+) ecc=(\d+)\/(\d+) temp=(\d+) dco=(\d+)/,9].to_i].pack("H*")
      dco = ["%02x" % packet_data[/\[(\d+)\] pkts: (\d+) txe=(\d+) rxe=(\d+) stx=(\d+) srx=(\d+) ecc=(\d+)\/(\d+) temp=(\d+) dco=(\d+)/,10].to_i].pack("H*")
      puts "Found Radio HK msg1!"
      
      # create the forward message command including the destination address
      rtn_pkt = "\x08\x65\x00\x00\x00\x2D\x38\x6D\x58\x47\x00\x00".force_encoding('ASCII-8BIT') << nodeid << pkts << txe << rxe << stx << srx << ecc1 << ecc1 << temp << dco
      return rtn_pkt
    elsif packet_data.include?("RSSI") && packet_data.include?("noise")
    
      nodeid = ["%02x" % packet_data[/\[(\d+)\] L\/R RSSI: (\d+)\/(\d+)  L\/R noise: (\d+)\/(\d+)/,1].to_i].pack("H*")
      local_rssi = ["%02x" % packet_data[/\[(\d+)\] L\/R RSSI: (\d+)\/(\d+)  L\/R noise: (\d+)\/(\d+)/,2].to_i].pack("H*")
      remote_rssi = ["%02x" % packet_data[/\[(\d+)\] L\/R RSSI: (\d+)\/(\d+)  L\/R noise: (\d+)\/(\d+)/,3].to_i].pack("H*")
      local_noise = ["%02x" % packet_data[/\[(\d+)\] L\/R RSSI: (\d+)\/(\d+)  L\/R noise: (\d+)\/(\d+)/,4].to_i].pack("H*")
      remote_noise = ["%02x" % packet_data[/\[(\d+)\] L\/R RSSI: (\d+)\/(\d+)  L\/R noise: (\d+)\/(\d+)/,5].to_i].pack("H*")
      puts "Found Radio RSSI msg!"
      
      # create the forward message command including the destination address
      rtn_pkt = "\x08\x66\x00\x00\x00\x2D\x38\x6D\x58\x47\x00\x00".force_encoding('ASCII-8BIT') << nodeid << local_rssi << remote_rssi << local_noise << remote_noise
      return rtn_pkt
    else
      return packet_data
    end
    return packet_data
  end

end
end