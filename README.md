# pimatic-amazing-dash-button

[![Npm Version](https://badge.fury.io/js/pimatic-amazing-dash-button.svg)](http://badge.fury.io/js/pimatic-amazing-dash-button)
[![Build Status](https://travis-ci.org/mwittig/pimatic-amazing-dash-button.svg?branch=master)](https://travis-ci.org/mwittig/pimatic-amazing-dash-button)
[![Dependency Status](https://david-dm.org/mwittig/pimatic-amazing-dash-button.svg)](https://david-dm.org/mwittig/pimatic-amazing-dash-button)

A pimatic plugin for Amazon's dash-buttons. It is a pretty light-weight implementation which uses a `ContactSensor` 
device abstraction for the dash-button. Auto-discovery of dash-buttons is supported.

The plugin sniffs for ARP probes which will be sent out by a dash-button when the 
button is pressed. The plugin is based on [cap](https://www.npmjs.com/package/cap), a
cross-platform binding for performing packet capturing with node.js. It can be used on *nix and Windows systems. 

## Installation

**This plugin requires libpcap to capture ARP requests on the network**. On Raspberry PI and comparable systems `libpcap` 
must be installed, i.e. `sudo apt-get install libpcap-dev`. 
On Windows, [WinPcap](http://www.winpcap.org/install/default.htm) must be installed.


## Plugin Configuration

    {
          "plugin": "amazing-dash-button",
          "interfaceAddress": "192.168.1.15",
    }

The plugin has the following configuration properties:

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| interfaceAddress  | -        | String  | IP address associated with the network interface which shall be used to listen to ARP requests (optional) |



## Device Configuration

As of pimatic v0.9 dash-button devices can be automatically discovered.

    {
          "id": "AmazingDashButton1",
          "name": "AmazingDashButton1",
          "class": "AmazingDashButton",
          "macAddress": "AC:63:BE:B3:BE:78"
    }

The plugin has the following configuration properties:

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| interfaceAddress  | -        | String  | MAC address of the device                   |
| invert            | false    | String  | If true, invert the contact state, i.e., contact is 'closed' if dash-button not pressed |
| holdTime          | 1500     | Integer | The number of milliseconds the contact shall enter the state indicating button pressed (closed if not inverted) |

## Contributions and Donations

[![PayPal donate button](https://img.shields.io/paypal/donate.png?color=blue)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=E44SSB34CVXP2)

Contributions to the project are welcome. You can simply fork the project and create a pull request with 
your contribution to start with. If you wish to support my work with a donation I'll highly appreciate this. 

## History

See [Release History](https://github.com/mwittig/pimatic-amazing-dash-button/blob/master/HISTORY.md).

## License 

Copyright (c) 2016, Marcus Wittig and contributors. All rights reserved.

[AGPL-3.0](https://github.com/mwittig/pimatic-amazing-dash-button/blob/master/LICENSE)