![Amazing Dash-Button](https://github.com/mwittig/pimatic-amazing-dash-button/raw/master/assets/images/dash-buttons.jpg)
# pimatic-amazing-dash-button

[![Npm Version](https://badge.fury.io/js/pimatic-amazing-dash-button.svg)](http://badge.fury.io/js/pimatic-amazing-dash-button)
[![Build Status](https://travis-ci.org/mwittig/pimatic-amazing-dash-button.svg?branch=master)](https://travis-ci.org/mwittig/pimatic-amazing-dash-button)
[![Dependency Status](https://david-dm.org/mwittig/pimatic-amazing-dash-button.svg)](https://david-dm.org/mwittig/pimatic-amazing-dash-button)


A pimatic plugin for Amazon's dash-buttons. It is a pretty light-weight implementation which uses a `ContactSensor` 
device abstraction for the dash-button. Auto-discovery of dash-buttons is supported.

The plugin sniffs for ARP probes which will be sent out by a dash-button when the 
button is pressed. The plugin is based on [cap](https://www.npmjs.com/package/cap), a
cross-platform `libpcap` binding for performing packet capturing with node.js. It can be used 
on *nix and Windows systems. 

### Contributions

If you like this plugin, please consider &#x2605; starring 
[the project on github](https://github.com/mwittig/pimatic-amazing-dash-button). Contributions to the project are  welcome. You can simply fork the project and create a pull request with 
your contribution to start with. 

### Stickers and Donations

Happy with pimatic and using it everyday? If you like to obtain one of these amazing dash-button stickers, please 
[consider a donation](https://pimatic.org/pages/donate/) to support the pimatic development and 
the operation of the website and user forum.

## Installation

**This plugin requires libpcap to capture ARP requests on the network**. On Raspberry PI and comparable systems 
`libpcap` must be installed, i.e. `sudo apt-get install libpcap-dev`. 
On Windows, [WinPcap](http://www.winpcap.org/install/default.htm) must be installed.

### Dash-Button Installation

Follow the instructions given in the Amazon Mobile App, to pair the dash-button with your WiFi network. However, **don't 
select a product as requested in the last configuration step**. Now, when the dash-button is pressed, the indicator 
LED of the dash-button should blink white for about three seconds. Following this, the LED will turn to solid red for 
a few seconds and might blink red (depending on the type of dash-button you have, apparently there are different 
makes). This indicates the device is not setup as there is no product setup, but this does not matter. 

As an additional line of defense you may consider restricting internet access for the device as part 
of your router configuration.  


## Plugin Configuration

The "interfaceAddress" property may be omitted if your system only has a single network interface or the interface to 
choose is the first one on the list returned by the `ifconfig` command on the host. If the device 
discovery or the interaction with dash-button does not work as expected, provide the IP address associated with the 
network interface which shall be used to listen to ARP requests needs to be set.

    {
          "plugin": "amazing-dash-button",
          "interfaceAddress": "192.168.1.15",
    }

The plugin has the following configuration properties:

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| interfaceAddress  | -        | String  | IP address associated with the network interface which shall be used to listen to ARP requests (optional) |


## Device Configuration

As of pimatic v0.9, dash-button devices can be automatically discovered. Simply open the "Devices" view of 
the pimatic web frontend and click on "Discover Devices". When the discovery has started, press the dash-button and 
the device should show up as a discovered device in pimatic after a few seconds.

You can also add the device manually by adding it to the "devices" section of the configuration or by creating the 
device using the device editor.

    {
          "id": "AmazingDashButton1",
          "name": "AmazingDashButton1",
          "class": "AmazingDashButton",
          "macAddress": "AC:63:BE:B3:BE:78"
    }

The device has the following configuration properties:

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| macAddress        | -        | String  | MAC address of the device                   |
| invert            | false    | String  | If true, invert the contact state, i.e., contact is 'closed' if dash-button not pressed |
| holdTime          | 1500     | Integer | The number of milliseconds the contact shall enter the state indicating button pressed (closed if not inverted) |


## Trigger Another Device

The dash-button device is derived from `ContactSensor` and provides the following 
predicate: `{device} is opened|closed`. For example, if you wish to toggle a `PowerSwitch` device when the dash-button 
is pressed you can create a rule as follows: 

    when AmazingDashButton1 is closed then toggle {PowerSwitch Device}

## Trigger Action

It is also possible to trigger an `AmazingDashButton` device using the pimatic REST or WebSocket API as shown 
in the example below for a given device with id `dash-1`. Calling the  device action will 
close the contact for the `holdTime`configured set as part of device configuration.

```bash
curl --user "username:password" /api/device/dash-1/trigger
```


## History

See [Release History](https://github.com/mwittig/pimatic-amazing-dash-button/blob/master/HISTORY.md).

## License 

Copyright (c) 2016, Marcus Wittig and contributors. All rights reserved.

[AGPL-3.0](https://github.com/mwittig/pimatic-amazing-dash-button/blob/master/LICENSE)