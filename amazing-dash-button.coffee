# The amazing dash-button plugin
module.exports = (env) ->

  Promise = env.require 'bluebird'
  net = require 'net'
  cap = require 'cap'
  commons = require('pimatic-plugin-commons')(env)


  # ###AmazingDashButtonPlugin class
  class AmazingDashButtonPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      @interfaceAddress = @config.interfaceAddress if @config.interfaceAddress?
      @debug = @config.debug || false
      @base = commons.base @, 'Plugin'
      @capture = new cap.Cap()
      @buffer = new Buffer(65536)

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

        @arpPacketHandler = (arp) =>
          candidateArpAddress = arp.info.sendermac
          if candidateArpAddress not in @candidatesSeen
            @base.debug 'Amazon device detected: ' + candidateArpAddress
            @candidatesSeen.push candidateArpAddress
            @_probeChromeCastPort(arp.info.senderip).then (probeSucceeded) =>
              if probeSucceeded
                @base.debug 'Amazon device appears to be a Chromecast server: ' + candidateArpAddress
              else
                @lastId = @base.generateDeviceId @framework, "dash", @lastId

                deviceConfig =
                  id: @lastId
                  name: @lastId
                  class: 'AmazingDashButton'
                  macAddress: candidateArpAddress

                @framework.deviceManager.discoveredDevice(
                  'pimatic-amazing-dash-button',
                  "#{deviceConfig.name} (#{deviceConfig.macAddress}, #{arp.info.senderip})",
                  deviceConfig
                )

        @on 'arpPacket', @arpPacketHandler
        @timer = setTimeout( =>
          @removeListener 'arpPacket', @arpPacketHandler
        , eventData.time
        )
      )

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

      # List of registered Mac addresses with IEEE as of 18 July 2016 for Amazon Technologies Inc.
      # source: https://regauth.standards.ieee.org/standards-ra-web/pub/view.html#registries
      # 00BB3A is marked as private and has been reported to be used for dash-buttons
      amazonVendorIds = [
        "F0D2F1", "8871E5", "74C246", "F0272D", "0C47C9",
        "A002DC", "747548", "AC63BE", "44650D", "50F5DA",
        "84D6D0", "34D270", "00BB3A"
      ]
      filter = amazonVendorIds.map( (vendorId) ->
        "(ether[6:2] == 0x#{vendorId.substring 0,4} and ether[8:1] == 0x#{vendorId.substring 4,6})"
      ).reduce( (left, right) ->
        left + " or " + right
      )

      linkType = @capture.open device, "arp and (#{filter})", 10 * 65536, @buffer
      try
        @capture.setMinBytes 0
      catch e
        @base.debug e

      @capture.on "packet", @_rawPacketHandler

    _stop: () =>
      @capture.removeListener "packet", @_rawPacketHandler
      @capture.close();

    _rawPacketHandler: () =>
      ret = cap.decoders.Ethernet @buffer
      if ret.info.type is cap.decoders.PROTOCOL.ETHERNET.ARP
        @emit 'arpPacket', cap.decoders.ARP @buffer, ret.offset

    _probeChromeCastPort: (host, port=8008) ->
      client = new net.Socket
      return new Promise( (resolve) =>
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
        resove false
      .finally =>
        client.destroy()


  class AmazingDashButton extends env.devices.ContactSensor

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
      @arpPacketHandler = (arp) =>
        if arp.info.sendermac is @macAddress
          @_setContact not @_invert
          clearTimeout @timer if @timer?
          @timer = setTimeout( =>
            @_setContact @_invert
            @timer = null
          , @config.holdTime
          )
      super()
      @plugin.on 'arpPacket', @arpPacketHandler

    destroy: () ->
      clearTimeout @timer if @timer?
      @plugin.removeListener 'arpPacket', @arpPacketHandler
      super()

    getContact: () -> Promise.resolve @_contact

  # ###Finally
  # Create a instance of my plugin
  # and return it to the framework.
  return new AmazingDashButtonPlugin