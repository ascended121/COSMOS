
require 'cosmos' # always require cosmos
require 'Cosmos::USERPATH/cosmos/interfaces/protocols/protocol'

module COSMOS
class CcsdsProtocol < Protocol
  def initialize()
      super()
  end

  def reset
      super()
  end

  def write_data(data)
    put "this is a test" 

    # update the packet checksum
    data = update_ccsds_checksum(data)

    return data

  end
  def update_ccsds_length(packet_data)

      # update the packet length
      # this is needed because the XB_FWDMSG and GND_FSWMSG commands are dynamic length
      # NOTE: packet.length returns the size of the packet in the database, not the actual length of the packet
      #   doesn't look like it can be used for dynamic length packets 
      packet_data[4..5] = [packet_data.length-7].pack("n")

      # return the data with the length field updated
      return packet_data
  end

  def update_ccsds_checksum(packet_data)

     # calculate the checksum
      checksum = 0xFF
      packet_data.each_byte {|x| checksum ^= x }
    
      # debug statement
      puts "checksum 0x#{checksum.to_s(16)}"
    
      # not sure why the pack is necessary for assigning into an element of the data array
      packet_data[7] = [checksum].pack("C")

      # return the data with the length field updated
      return packet_data
  end

  def get_CCSDSAPID(packet_data)

    # extract the APID from the StreamID field
    apid = ((packet_data[0].unpack("C").first * 256) + packet_data[1].unpack("C").first) & 2047

    return apid
  end

  def get_CCSDSFcnCode(packet_data)

    # extract the APID from the StreamID field
    apid = packet_data[6].unpack("C").first & 0x7F

    return apid
  end

  def get_CCSDSTlmSec(packet_data)

    # extract the APID from the StreamID field
    bytes = Array.new

    bytes[0] = packet_data[6].unpack("C").first
    bytes[1] = packet_data[7].unpack("C").first
    bytes[2] = packet_data[8].unpack("C").first
    bytes[3] = packet_data[9].unpack("C").first

    val =  bytes[3] + (bytes[2] << 8) + (bytes[1] << 16) + (bytes[0] << 24 )    
    return val
  end

  def get_CCSDSTlmSubSec(packet_data)

    bytes = Array.new

    bytes[0] = packet_data[10].unpack("C").first
    bytes[1] = packet_data[11].unpack("C").first

    val =  bytes[1] + (bytes[0] << 8)   

    return val
  end

  def getCCSDSCmdPayload(packet_data)

    return packet_data[8..-1]
  end

  def getCCSDSTlmPayload(packet_data)

    return packet_data[12..-1]
  end

end

end



