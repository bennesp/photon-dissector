
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

-- Reliable types table
local reliable_types_arr = {
    [0x02] = "OperationRequest",
	[0x03] = "otherOperationResponse",
    [0x04] = "EventDataType",
    [0x06] = "ExchangeKeys",
	[0x07] = "OperationResponse",
}

-- Param types table
local param_types_arr = {
	[0x00] = "Unknown",
	[0x2a] = "NilType",
	[0x44] = "DictionaryType",
	[0x61] = "StringArrayType",
	[0x62] = "Int8Type",
	[0x63] = "Custom",
	[0x64] = "DoubleType",
	[0x65] = "EventDateType",
	[0x66] = "Float32Type",
	[0x68] = "Hashtable",
	[0x69] = "Int32Type",
	[0x6b] = "Int16Type",
	[0x6c] = "Int64Type",
	[0x6e] = "Int32ArrayType",
	[0x6f] = "BooleanType",
	[0x70] = "OperationResponseType",
	[0x71] = "OperationRequestType",
	[0x73] = "StringType",
	[0x78] = "Int8ArrayType",
	[0x79] = "ArrayType",
	[0x7a] = "ObjectArrayType",
}

photon_protocol = Proto("Photon", "Photon Protocol")

peer_id = ProtoField.uint16("photon.peer_id", "Peer ID", base.DEC)
crc_enabled = ProtoField.uint8("photon.crc_enabled", "CRC Enabled", base.DEC)
command_count = ProtoField.uint8("photon.command_count", "Command Count", base.DEC)
timestamp = ProtoField.uint32("photon.timestamp", "Timestamp", base.DEC)
challenge = ProtoField.uint32("photon.challenge", "Challenge", base.DEC)

command_type = ProtoField.uint8("photon.command.type", "Type", base.STRING, command_types_arr)
command_channel_id = ProtoField.uint8("photon.command.channel_id", "Channel ID", base.DEC)
command_flags = ProtoField.uint8("photon.command.flags", "Flags", base.DEC)
command_reserved_byte = ProtoField.uint8("photon.command.reserved_byte", "Reserved Byte", base.DEC)
command_length = ProtoField.uint32("photon.command.length", "Length", base.DEC)
command_reliable_seq_n = ProtoField.uint32("photon.command.reliable_seq_n", "Reliable Sequence Number", base.DEC)
command_data = ProtoField.bytes("photon.command.data", "Data", base.NONE)

command_reliable_signature = ProtoField.uint8("photon.command.reliable.signature", "Signature", base.DEC)
command_reliable_type = ProtoField.uint8("photon.command.reliable.type", "Type", base.STRING, reliable_types_arr)
operation_code = ProtoField.uint8("photon.command.reliable.operation_code", "Operation Code", base.DEC)
event_code = ProtoField.uint8("photon.command.reliable.event_code", "Event Code", base.DEC)
parameter_count = ProtoField.uint16("photon.command.reliable.parameter_count", "Parameter Count", base.DEC)
command_reliable_data = ProtoField.bytes("photon.command.reliable.data", "Data", base.NONE)
operation_response_code = ProtoField.uint8("photon.command.reliable.operation_response_code", "Operation Response Code", base.DEC)
param_type = ProtoField.uint8("photon.command.reliable.param_type", "Param Type", base.STRING, param_types_arr)

key_type_code = ProtoField.uint8("photon.command.reliable.key_type_code", "Key Type Code", base.DEC)
value_type_code = ProtoField.uint8("photon.command.reliable.value_type_code", "Value Type Code", base.DEC)
dictionary_size = ProtoField.uint8("photon.command.reliable.dictionary_size", "Dictionary Size", base.DEC)

param_array_length_32bit = ProtoField.uint32("photon.command.reliable.param_array_length_32bit", "Array Length", base.DEC)
param_array_length_16bit = ProtoField.uint16("photon.command.reliable.param_array_length_16bit", "Array Length", base.DEC)
param_array_data = ProtoField.bytes("photon.command.reliable.param_array_data", "Array Data", base.NONE)
param_id = ProtoField.uint8("photon.command.reliable.param_id", "Param ID", base.DEC)
param_string = ProtoField.string("photon.command.reliable.param_string", "String", base.STRING)
param_string_length = ProtoField.uint16("photon.command.reliable.param_string_length", "String Length", base.DEC)
value8bit = ProtoField.uint8("photon.command.reliable.value8bit", "Value", base.DEC)
value16bit = ProtoField.uint16("photon.command.reliable.value16bit", "Value", base.DEC)
valuebytes = ProtoField.bytes("photon.command.reliable.valuebytes", "Value", base.NONE)
encrypted = ProtoField.string("photon.command.reliable.encrypted", "Encrypted", base.STRING)

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
    command_data,

    command_reliable_signature,
    command_reliable_type,
    operation_code,
    event_code,
    parameter_count,
    command_reliable_data,
    operation_response_code,
    param_type,

    key_type_code,
    value_type_code,
    dictionary_size,
    param_array_length_32bit,
    param_array_length_16bit,
    param_array_data,
    param_id,
    param_string,
    param_string_length,
    value8bit,
    value16bit,
    valuebytes
}

function add_value_from_type(tree, buffer, param_type_num)
    local total_length = 0

    if param_type_num == 0x00 or param_type_num == 0x2a then
        return 0
    elseif param_type_num == 0x44 then
        -- tree:add(key_type_code, buffer(1, 1))
        -- tree:add(value_type_code, buffer(2, 1))
        -- tree:add(dictionary_size, buffer(3, 1))

        -- TODO see https://github.com/broderickhyman/photon_spectator/blob/master/decode_reliable_message.go#L290-L297
    elseif param_type_num == 0x61 then
        -- TODO
        total_length = 0
    elseif param_type_num == 0x61 then
        -- TODO
        total_length = 0
    elseif param_type_num == 0x62 then
        tree:add(value8bit, buffer(0, 1))
        total_length = 1
    elseif param_type_num == 0x63 then
        -- TODO
        total_length = 0
    elseif param_type_num == 0x64 then
        -- TODO
        total_length = 0
    elseif param_type_num == 0x65 then
        -- TODO
        total_length = 0
    elseif param_type_num == 0x66 then
        -- TODO
        total_length = 4
    elseif param_type_num == 0x68 then
        -- TODO
        total_length = 0
    elseif param_type_num == 0x69 then
        -- TODO
        total_length = 4
    elseif param_type_num == 0x6b then
        tree:add(value16bit, buffer(0, 2))
        total_length = 2
    elseif param_type_num == 0x6c then
        -- TODO
        total_length = 8
    elseif param_type_num == 0x6e then
        -- TODO
        total_length = 0
    elseif param_type_num == 0x6f then
        -- TODO
        total_length = 0
    elseif param_type_num == 0x70 then
        -- TODO
        total_length = 0
    elseif param_type_num == 0x71 then
        -- TODO
        total_length = 0
    elseif param_type_num == 0x73 then
        tree:add(param_string_length, buffer(0, 2))
        local length_concrete = buffer(0, 2):uint()
        tree:add(param_string, buffer(2, length_concrete))

        total_length = 2 + length_concrete
    elseif param_type_num == 0x78 then
        tree:add(param_array_length_32bit, buffer(0, 4))
        local param_array_length_concrete = buffer(0, 4):uint()
        tree:add(param_array_data, buffer(4, param_array_length_concrete))

        total_length = 4 + param_array_length_concrete
    elseif param_type_num == 0x79 then
        tree:add(param_array_length_16bit, buffer(0, 2))
        tree:add(param_type, buffer(2, 1))
        local param_type_concrete = buffer(2, 1):uint()
        local param_array_length_16bit_concrete = buffer(0, 2):uint()
        total_length = 3
        
        for i=1,param_array_length_16bit_concrete,1 do
            total_length = total_length + add_value_from_type(tree, buffer(total_length), param_type_concrete)            
        end
    elseif param_type_num == 0x7a then
        -- TODO
    end

    tree:set_len(total_length + 2)
    return total_length
end

function add_reliable_message(buffer, pinfo, tree, param_count)
    -- tree:add(command_reliable_data, buffer(0))
    local offset = 0
    for i=1, param_count, 1 do
        local subtree = tree:add(photon_protocol, buffer(offset), "Param "..i)
        subtree:add(param_id, buffer(offset, 1))
        subtree:add(param_type, buffer(offset + 1, 1))
        local param_type_concrete = buffer(offset + 1, 1):uint()
        offset = offset + 2 + add_value_from_type(subtree, buffer(offset + 2), param_type_concrete)
    end
end

function add_reliable(buffer, pinfo, tree)
    tree:add(command_reliable_signature, buffer(0, 1))

    local offset = 2
    local command_reliable_type_concrete = buffer(1, 1):uint()
    if command_reliable_type_concrete > 0x80 then
        pinfo.cols.protocol = "ENCRYPTED PHOTON"
        tree:add(command_reliable_type, buffer(1, 1))
        tree:add(encrypted, "Encrypted: Yes, Type: " .. tostring(reliable_types_arr[buffer(1, 1):uint()-0x80]) .. " ("..tostring(buffer(1, 1):uint()-0x80)..")")
        tree:add(valuebytes, buffer(2))
        return
    else
        tree:add(command_reliable_type, buffer(1, 1))
    end
    
    if command_reliable_type_concrete == 0x02 or command_reliable_type_concrete == 0x06 then
        tree:add(operation_code, buffer(2, 1))
        offset = offset + 1
    elseif command_reliable_type_concrete == 0x04 then
        tree:add(event_code, buffer(2, 1))
        offset = offset + 1
    elseif command_reliable_type_concrete == 0x03 or command_reliable_type_concrete == 0x07 then
        tree:add(operation_code, buffer(2, 1))
        tree:add(operation_response_code, buffer(3, 2))
        tree:add(param_type, buffer(5, 1))
        local param_type_concrete = buffer(5, 1):uint()

        offset = offset + 4

        offset = offset + add_value_from_type(tree, buffer(offset), param_type_concrete)
    end

    tree:add(parameter_count, buffer(offset, 2))
    local parameter_count_concrete = buffer(offset, 2):uint()

    offset = offset + 2
    local subtree = tree:add(photon_protocol, buffer(offset), "Reliable Command Data")
    add_reliable_message(buffer(offset), pinfo, subtree, parameter_count_concrete)
end

function add_command(buffer, pinfo, tree)
    tree:add(command_type, buffer(0, 1))

    if (command_types_arr[buffer(0, 1):uint()] ~= nil) then
        pinfo.cols.info = tostring(pinfo.cols.info) .. " " .. tostring(command_types_arr[buffer(0, 1):uint()])
    end

    tree:add(command_channel_id, buffer(1, 1))
    tree:add(command_flags, buffer(2, 1))
    tree:add(command_reserved_byte, buffer(3, 1))
    tree:add(command_length, buffer(4, 4))
    tree:add(command_reliable_seq_n, buffer(8, 4))

    local command_type_concrete = buffer(0, 1):uint()
    local command_length_concrete = buffer(4, 4):uint() - 12 -- 12 bytes are just headers

    if command_type_concrete == 0x06 then -- SendReliable
        local subBuff = buffer(12, command_length_concrete)
        local subtree = tree:add(photon_protocol, subBuff, "Reliable Command")
        add_reliable(subBuff, pinfo, subtree)
    elseif command_length_concrete - 12 > 0 then
        tree:add(command_data, buffer(12, command_length_concrete))
    end

    return 12 + command_length_concrete
end

function photon_protocol.dissector(buffer, pinfo, tree)
    local length = buffer:len()
    if length == 0 then return end

    pinfo.cols.protocol = photon_protocol.name

    local subtree = tree:add(photon_protocol, buffer(), "Photon Protocol Data")
    subtree:add(peer_id, buffer(0, 2))
    subtree:add(crc_enabled, buffer(2, 1))
    subtree:add(command_count, buffer(3, 1))
    subtree:add(timestamp, buffer(4, 4))
    subtree:add(challenge, buffer(8, 4))

    local offset = 12
    for i=1, buffer(3, 1):uint(), 1 do
        local cmd_subtree = subtree:add(photon_protocol, buffer(offset), "Command "..i)
        offset = offset + add_command(buffer(offset), pinfo, cmd_subtree)
    end
end

local udp_port = DissectorTable.get("udp.port")
udp_port:add(5055, photon_protocol)
udp_port:add(5056, photon_protocol)
udp_port:add(4535, photon_protocol)
