--[[
ONVIF Streaming Specification: 6.2 RTP header extension
 0xABAC length=3
 NTP timestamp
 NTP timestamp
 C E D mbz CSeq padding
--]]

local onvif_replay_proto = Proto("onvif", "ONVIF Replay")

-- ProtoField.new(name, abbr, type, [voidstring], [base], [mask], [descr])
-- base: one of BASE_, or field bit-width if FT_BOOLEAN and non-zero bitmask (_header_field_info)
local ntp_sec = ProtoField.new("NTP Second", "onvif.sec", ftypes.UINT32, nil, base.DEC_HEX)
local ntp_nsec = ProtoField.new("NTP Nanosecond", "onvif.nsec", ftypes.UINT32, nil, base.DEC_HEX)
local ntp_clean = ProtoField.new("Clean", "onvif.c", ftypes.BOOLEAN, nil, 8, 0x80)
local ntp_end = ProtoField.new("End", "onvif.e", ftypes.BOOLEAN, nil, 8, 0x40)
local ntp_discon = ProtoField.new("Discon", "onvif.d", ftypes.BOOLEAN, nil, 8, 0x20)
local ntp_mbz = ProtoField.new("MBZ", "onvif.mbz", ftypes.UINT8, nil, base.DEC, 0x1F)
local ntp_seq = ProtoField.new("Seq", "onvif.seq", ftypes.UINT8)
local ntp_pad = ProtoField.new("Pad", "onvif.pad", ftypes.UINT16)

onvif_replay_proto.fields = {
	ntp_sec, ntp_nsec,
	ntp_clean, ntp_end, ntp_discon, ntp_mbz,
	ntp_seq, ntp_pad,
}

function onvif_replay_proto.dissector(buf, pinfo, tree)
	if buf:len() ~= 12 then return end

	local subtree = tree:add(onvif_replay_proto, buf())

	subtree:add(ntp_sec, buf(0,4))
	subtree:add(ntp_nsec, buf(4,4))

	subtree:add(ntp_clean, buf(8,1))
	subtree:add(ntp_end, buf(8,1))
	subtree:add(ntp_discon, buf(8,1))
	subtree:add(ntp_mbz, buf(8,1))

	subtree:add(ntp_seq, buf(9,1))

	subtree:add(ntp_pad, buf(10,2))
end

local rtp_hdr_ext_table = DissectorTable.get("rtp.hdr_ext")
rtp_hdr_ext_table:add(0xABAC, onvif_replay_proto)

