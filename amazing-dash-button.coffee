# The amazing dash-button plugin
module.exports = (env) ->

  Promise = env.require 'bluebird'
  net = require 'net'
  cap = require 'cap'
  bootp = require './bootp'
  commons = require('pimatic-plugin-commons')(env)


  # ###AmazingDashButtonPlugin class
  class AmazingDashButtonPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      @interfaceAddress = @config.interfaceAddress if @config.interfaceAddress?
      @ignoreMacAddresses = @config.ignoreMacAddresses ? []
      @debug = @config.debug || false
      @base = commons.base @, 'Plugin'
      @buffer = new Buffer(65536)
      # List of registered Mac addresses with IEEE as of 15 July 2017 for Amazon Technologies Inc.
      # source: https://regauth.standards.ieee.org/standards-ra-web/pub/view.html#registries
      # 00BB3A is marked as private and has been reported to be used for dash-buttons
      @amazonVendorIds = [
        "F0D2F1", "8871E5", "FCA183", "F0272D", "74C246",
        "6837E9", "78E103", "38F73D", "50DCE7", "A002DC",
        "0C47C9", "747548", "AC63BE", "FCA667", "18742E",
        "00FC8B", "FC65DE", "6C5697", "44650D", "50F5DA",
        "6854FD", "40B4CD", "4CEFC0", "007147", "84D6D0",
        "34D270", "B47C9C", "00BB3A"
      ]

      process.on "SIGINT", @_stop
      @_start()

      # register devices
      deviceConfigDef = require("./device-config-schema")
      @framework.deviceManager.registerDeviceClass("AmazingDashButton",
        prepareConfig: AmazingDashButton.prepareConfig
        configDef: deviceConfigDef.AmazingDashButton,
        createCallback: (@config, lastState) =>
          new AmazingDashButton(@config, @, lastState)
      )

      # auto-discovery
      @framework.deviceManager.on('discover', (eventData) =>
        if @noInterfacesFound?
          @framework.deviceManager.discoverMessage 'pimatic-amazing-dash-button', @noInterfacesFound
          @base.error @noInterfacesFound
          return
        else
          @framework.deviceManager.discoverMessage 'pimatic-amazing-dash-button', 'Searching for dash-buttons. Please press dash-button now!'

        @candidatesSeen = []
        @lastId = null

        @candidateInfoHandler = (info) =>
          candidateAddress = info.mac
          if candidateAddress not in @candidatesSeen
            @base.debug 'Amazon device detected: ' + candidateAddress
            @candidatesSeen.push candidateAddress
            @_probeChromeCastPort(info.ip).then (probeSucceeded) =>
              if probeSucceeded
                @base.debug 'Amazon device appears to be a Chromecast server: ' + candidateAddress
              else
                @lastId = @base.generateDeviceId @framework, "dash", @lastId

                deviceConfig =
                  id: @lastId
                  name: @lastId
                  class: 'AmazingDashButton'
                  macAddress: candidateAddress

                @framework.deviceManager.discoveredDevice(
                  'pimatic-amazing-dash-button',
                  "#{deviceConfig.name} (#{deviceConfig.macAddress}, #{info.ip})",
                  deviceConfig
                )

        @on 'candidateInfo', @candidateInfoHandler
        @timer = setTimeout( =>
          @removeListener 'candidateInfo', @candidateInfoHandler
        , eventData.time
        )
      )

    prepareConfig: (config) =>
      addresses = config.ignoreMacAddresses || []
      for address, index in addresses
        address = address.replace /\W/g, ''
        if address.length is 12
          addresses[index] =
            address.replace(/(.{2})/g, '$1:').toLowerCase().slice(0, -1)
        else
          env.logger.error "Invalid MAC address: #{address} in ignoreMacAddresses"

    _addMacToFilter: (mac) ->
      vendorId = mac.replace(/:/g, '').substring(0,6).toUpperCase()
      if @amazonVendorIds.indexOf(vendorId) is -1
        @_stop()
        @amazonVendorIds.push vendorId
        @base.debug "Adding vendor id #{vendorId} to packet filter"
        @_start()

    _start: () ->
      if @interfaceAddress?
        device = cap.findDevice @interfaceAddress
      else
        device = cap.findDevice()

      if device?
        @base.debug "Sniffing for ARP requests on device", device
      else
        @noInterfacesFound = "Error: No suitable network interface found for sniffing ARP requests"
        @base.error @noInterfacesFound
        return

      filter = @amazonVendorIds.map( (vendorId) ->
        "(ether[6:2] == 0x#{vendorId.substring 0,4} and ether[8:1] == 0x#{vendorId.substring 4,6})"
      ).reduce( (left, right) ->
        left + " or " + right
      )

      bootpFilter = "udp and src port 68 and dst port 67 and udp[247:4] == 0x63350103"
      pcapFilter = "src host 0.0.0.0 and (arp or (#{bootpFilter})) and (#{filter})"
      @capture = new cap.Cap()
      linkType = @capture.open device, pcapFilter, 10 * 65536, @buffer
      try
        @capture.setMinBytes 0
      catch e
        @base.debug e

      @capture.on "packet", @_rawPacketHandler

    _stop: () =>
      if @capture?
        @capture.removeListener "packet", @_rawPacketHandler
        @capture.close();
        @capture = null

    _rawPacketHandler: () =>
      ret = cap.decoders.Ethernet @buffer
      candidateInfo = {}
      if ret.info.type is cap.decoders.PROTOCOL.ETHERNET.IPV4
        r = cap.decoders.IPV4 @buffer, ret.offset
        dhcp = bootp.BOOTP @buffer, r.offset + 8
        if dhcp.info.clientmac not in @ignoreMacAddresses
          candidateInfo.mac = dhcp.info.clientmac
          candidateInfo.ip = dhcp.info.requestedip
          @base.debug "DHCP", candidateInfo
          @emit 'candidateInfo', candidateInfo
      else if ret.info.type is cap.decoders.PROTOCOL.ETHERNET.ARP
        arp = cap.decoders.ARP @buffer, ret.offset
        if arp.info.clientmac not in @ignoreMacAddresses
          candidateInfo.mac = arp.info.sendermac
          candidateInfo.ip = arp.info.senderip
          @base.debug "ARP", candidateInfo
          @emit 'candidateInfo', candidateInfo

    _probeChromeCastPort: (host, port=8008) ->
      if host?.length
        client = new net.Socket
        new Promise( (resolve) =>
          client.setTimeout 3000, =>
            @base.debug "Timeout"
            resolve false
          client.on "error", (error) =>
            @base.debug error
            resolve false
          client.connect port, host, =>
            @base.debug "Connected to device #{host}:#{port}"
            resolve true
        )
        .catch =>
          @base.debug "Exception"
          resolve false
        .finally =>
          client.destroy()
      else
        Promise.resolve false


  class AmazingDashButton extends env.devices.ContactSensor
    actions:
      trigger:
        description: "Closes the contact for the configured holdTime. Called when the dash button has been triggered"

    @prepareConfig: (config) =>
      address = (config.macAddress || '').replace /\W/g, ''
      if address.length is 12
        config.macAddress = address.replace(/(.{2})/g, '$1:').toLowerCase().slice(0, -1)
      else
        env.logger.error "Invalid MAC address: #{config.macAddress || 'Property "address" missing'}"

    # Initialize device by reading entity definition from middleware
    constructor: (@config, @plugin, lastState) ->
      @id = @config.id
      @name = @config.name
      @macAddress = @config.macAddress
      @_invert = @config.invert || false
      @_contact = @_invert
      @debug = @plugin.debug || false
      @base = commons.base @, @config.class
      @candidateInfoHandler = (info) =>
        if info.mac is @macAddress and not @callPending?
          @trigger()
          @callPending = setTimeout ( => @callPending = null), 3000

      super()
      @plugin._addMacToFilter @macAddress
      @plugin.on 'candidateInfo', @candidateInfoHandler

    destroy: () ->
      clearTimeout @timer if @timer?
      @plugin.removeListener 'candidateInfo', @candidateInfoHandler
      super()

    getContact: () -> Promise.resolve @_contact

    trigger: () ->
      # trigger contact for the configured holdTime, reset afterwards
      if not @timer?
        @base.debug "Amazon dash button triggered (#{@macAddress})"
        @_setContact not @_invert
        clearTimeout @timer if @timer?
        @timer = setTimeout( =>
          @_setContact @_invert
          @timer = null
        , @config.holdTime
        )
      Promise.resolve()

  # ###Finally
  # Create a instance of my plugin
  # and return it to the framework.
  return new AmazingDashButtonPlugin