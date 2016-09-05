module.exports = {
  title: "pimatic-amazing-dash-button device config schemas"
  AmazingDashButton:
    title: "AmazingDashButton config"
    type: "object"
    extensions: ["xLink"]
    properties: {
      macAddress:
        description: "MAC address of the dash-button"
        type: "string"
      invert:
        description: "If true, invert the contact state, i.e., contact is 'closed' if dash-button not pressed."
        type: "boolean"
        default: false
      holdTime:
        description: "The number of milliseconds the contact shall enter the state indicating button pressed (closed if not inverted)."
        type: "integer"
        default: 1500
    }
}