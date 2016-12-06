var Cap = require('cap').Cap,
  devices = Cap.deviceList(),
  filter = 'arp',
  bufSize = 10 * 65535,
  buffer = new Buffer(65535);


var buffer = new Buffer ([
    // ETHERNET
    0xff, 0xff, 0xff, 0xff, 0xff,0xff,                  // 0    = Destination MAC
    0xac, 0x63, 0xbe, 0xb7, 0x3d, 0x92,                 // 6    = Source MAC
    0x08, 0x06,                                         // 12   = EtherType = ARP
    // ARP
    0x00, 0x01,                                         // 14/0   = Hardware Type = Ethernet (or wifi)
    0x08, 0x00,                                         // 16/2   = Protocol type = ipv4 (request ipv4 route info)
    0x06, 0x04,                                         // 18/4   = Hardware Addr Len (Ether/MAC = 6), Protocol Addr Len (ipv4 = 4)
    0x00, 0x01,                                         // 20/6   = Operation (ARP, who-has)
    0xac, 0x63, 0xbe, 0xb7, 0x3d, 0x92,                 // 22/8   = Sender Hardware Addr (MAC)
    0xc0, 0xa8, 0x01, 0xc8,                             // 28/14  = Sender Protocol address (ipv4)
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,                 // 32/18  = Target Hardware Address (Blank/nulls for who-has)
    0xc0, 0xa8, 0x01, 0xc9                              // 38/24  = Target Protocol address (ipv4)
]);

devices.forEach(function (deviceInfo) {
    var c = new Cap();
    try {
        var linkType = c.open(deviceInfo.name, filter, bufSize, buffer);

        // send will not work if pcap_sendpacket is not supported by underlying `device`
        try {
            c.send(buffer, buffer.length);
        }
        finally{
            c.close();
        }
        console.log("Sent ARP request on device", deviceInfo.name);
    } catch (e) {
        console.log("Error sending packet:", e, "on device", deviceInfo.name);
    }
    setTimeout(function() {
        delete(c)
    }, 2000)
});
