photon_protocol = Proto("Photon", "Photon Protocol")

peer_id = ProtoField.uint16("photon.peer_id", "Peer ID", base.DEC)
crc_enabled = ProtoField.uint8("photon.crc_enabled", "CRC Enabled", base.DEC)
command_count = ProtoField.uint8("photon.command_count", "Command Count", base.DEC)
timestamp = ProtoField.uint8("photon.timestamp", "Timestamp", base.DEC)
challenge = ProtoField.uint8("photon.challenge", "Challenge", base.DEC)

command_type = ProtoField.uint8("photon.command_type", "Command Type", base.DEC)
command_channel_id = ProtoField.uint8("photon.command_channel_id", "Command Channel ID", base.DEC)
command_flags = ProtoField.uint8("photon.command_flags", "Command Flags", base.DEC)
command_reserved_byte = ProtoField.uint8("photon.command_reserved_byte", "Reserved Byte", base.DEC)
command_length = ProtoField.uint8("photon.command_length", "Command Length", base.DEC)
command_reliable_seq_n = ProtoField.uint8("photon.command_reliable_seq_n", "Command Reliable Sequence Number", base.DEC)
command_data = ProtoField.bytes("photon.command_data", "Command Data", base.NONE)

photon_protocol.fields = {
    peer_id,
    crc_enabled,
    command_count,
    timestamp,
    challenge,
    command_type,
    command_channel_id,
    command_flags,
    command_reserved_byte,
    command_length,
    command_reliable_seq_n,
    command_data
}

function photon_protocol.dissector(buffer, pinfo, tree)
    length = buffer:len()
    if length == 0 then return end

    pinfo.cols.protocol = photon_protocol.name

    local subtree = tree:add(photon_protocol, buffer(), "Photon Protocol Data")
    subtree:add(peer_id, buffer(0,2))
    subtree:add(crc_enabled, buffer(2,1))
    subtree:add(command_count, buffer(3,1))
    subtree:add(timestamp, buffer(4,4))
    subtree:add(challenge, buffer(8,4))

    local j = 12
    for i=1, buffer(3,1):uint(), 1 do
        local cmd_subtree = subtree:add(photon_protocol, buffer(), "Command "..i)
        cmd_subtree:add(command_type, buffer(j,1))
        cmd_subtree:add(command_channel_id, buffer(j+1,1))
        cmd_subtree:add(command_flags, buffer(j+2,1))
        cmd_subtree:add(command_reserved_byte, buffer(j+3,1))
        cmd_subtree:add(command_length, buffer(j+4,4))
        local command_length_uint = buffer(j+4,4):uint() - 12
        cmd_subtree:add(command_reliable_seq_n, buffer(j+8,4))
        cmd_subtree:add(command_data, buffer(j+12, command_length_uint))

        j = j + command_length_uint + 12
        -- todo
    end
end

local udp_port = DissectorTable.get("udp.port")
udp_port:add(5055, photon_protocol)

