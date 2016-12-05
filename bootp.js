// a fragmentary decoder for BOOTP to gather the requested IP address (DHCP option 50)
exports.BOOTP = function(b, offset) {
  offset || (offset = 0);
  var i;
  var ret = {
    info: {
      clientmac: '',
      requestedip: ''
    },
    offset: undefined
  };

  ret.info.messagetype = b.readInt8(offset++, true);
  ret.info.hardwaretype = b.readInt8(offset++, true);
  ret.info.hardwareaddrlen = b.readInt8(offset++, true);
  ret.info.hops = b.readInt8(offset++, true);
  ret.info.transActionId = b.readUInt32BE(offset, true);
  // skip timer and address fields
  offset += 24;

  // 32-bit Destination MAC Address
  for (i = 0; i < 6; ++i) {
    if (b[offset] < 16)
      ret.info.clientmac += '0';
    ret.info.clientmac += b[offset++].toString(16);
    if (i < 5)
      ret.info.clientmac += ':';
  }
  //offset += 6
  // address padding
  offset+= 10;
  // server name
  offset+= 64;
  // boot filename
  offset+= 128;
  ret.info.cookie = b.toString('hex', offset, offset + 4);
  offset+= 4;
  var option;
  while ((option = b.readUInt8(offset++, true)) != 255) {
    var length = b.readUInt8(offset++, true);
    if (option == 50) {
      // requested ip address
      for (i = 0; i < 4; ++i) {
        ret.info.requestedip += b[offset++];
        if (i < 3)
          ret.info.requestedip += '.';
      }
    }
    else {
      offset+= length
    }
  }

  ret.offset = offset;
  return ret;
};