module.exports = {
  title: "pimatic-amazing-dash-button plugin configuration config options"
  type: "object"
  properties:
    debug:
      description: "Debug mode. Writes debug messages to the pimatic log, if set to true."
      type: "boolean"
      default: false
    interfaceAddress:
      description: "
        the IP address associated with the network interface which shall be used to listen to ARP requests.
        If omitted the interface with a bound IP address will be used.
        "
      type: "string"
      required: false
}