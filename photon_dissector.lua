
-- Command types table
local command_types_arr = {
    [0x01] = "Acknowledge",
    [0x02] = "Connect",
    [0x03] = "VerifyConnect",
    [0x04] = "Disconnect",
    [0x05] = "Ping",
    [0x06] = "SendReliable",
    [0x07] = "SendUnreliable",
    [0x08] = "SendReliableFragment",
}

photon_protocol = Proto("Photon", "Photon Protocol")

peer_id = ProtoField.uint16("photon.peer_id", "Peer ID", base.DEC)
crc_enabled = ProtoField.uint8("photon.crc_enabled", "CRC Enabled", base.DEC)
command_count = ProtoField.uint8("photon.command_count", "Command Count", base.DEC)
timestamp = ProtoField.uint32("photon.timestamp", "Timestamp", base.DEC)
challenge = ProtoField.uint32("photon.challenge", "Challenge", base.DEC)

command_type = ProtoField.uint8("photon.command_type", "Command Type", base.STRING, command_types_arr)
command_channel_id = ProtoField.uint8("photon.command_channel_id", "Command Channel ID", base.DEC)
command_flags = ProtoField.uint8("photon.command_flags", "Command Flags", base.DEC)
command_reserved_byte = ProtoField.uint8("photon.command_reserved_byte", "Reserved Byte", base.DEC)
command_length = ProtoField.uint32("photon.command_length", "Command Length", base.DEC)
command_reliable_seq_n = ProtoField.uint32("photon.command_reliable_seq_n", "Command Reliable Sequence Number", base.DEC)
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

function add_command(buffer, pinfo, tree, offset)
    tree:add(command_type, buffer(offset,1))
    tree:add(command_channel_id, buffer(offset+1,1))
    tree:add(command_flags, buffer(offset+2,1))
    tree:add(command_reserved_byte, buffer(offset+3,1))
    tree:add(command_length, buffer(offset+4,4))
    local command_length_uint = buffer(offset+4,4):uint() - 12
    tree:add(command_reliable_seq_n, buffer(offset+8,4))
    tree:add(command_data, buffer(offset+12, command_length_uint))

    return 12 + command_length_uint
end

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

    local offset = 12
    for i=1, buffer(3,1):uint(), 1 do
        local cmd_subtree = subtree:add(photon_protocol, buffer(), "Command "..i)
        offset = offset + add_command(buffer, pinfo, cmd_subtree, offset)
    end
end

local udp_port = DissectorTable.get("udp.port")
udp_port:add(5055, photon_protocol)
