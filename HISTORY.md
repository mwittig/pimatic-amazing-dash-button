# Release History

* 20190531, V0.9.15
    * Important Note: Make sure, you have node version 4.5 or greater 
      installed. Otherwise, a "TypeError: Buffer.alloc is not a function" 
      may occur
    * Added feature "ignoreMacAddresses" to plugin configuration to 
      filter out requests from the given list of MAC addresses
    * Added source host IP filter to filtering string to further limit
      the number of matching packages
    * Merged DashButtonDevice from pimatic-dash-button, thanks @michbeck100
    * Added discovery of DashButtonDevice candidates
    * Now using fork of cap to avoid assertion error during capture
    * Updated dependencies
      
* 20171226, V0.9.14
    * Updated list of Amazon Vendor Ids
    * Devices with proprietary MAC addresses are now detected as part 
      of the capture filter, issue #4
      
* 20170902, V0.9.13
    * Added debounce logic to avoid contact changing its state multiple times, issue #9
    * Added trigger device action, issue #10
    * Updated documentation
    
* 20170716, V0.9.12
    * Updated list of Amazon Vendor Ids, issue #8
    
* 20161205, V0.9.11
    * Added support for DHCP-based detection of dash buttons, issue #6
    
* 20161106, V0.9.10
    * Added vendor id 00BB3A as reported by @kiwikern, issue #3
    
* 20161016, V0.9.9
    * Added validation and normalization for `macAddress` property
    * Added dash-button image
    * Revised README, added section on Stickers and Donations

* 20161007, V0.9.8
    * Improved error handling if no network devices found to capturing ARP requests
    * Updated dependencies to cap@0.1.2 which contains the contributed ARP decode function 
    
* 20161003, V0.9.7
    * Improved auto-discovery: Chromecast devices should no longer be discovered as dash-button devices 
    
* 20160930, V0.9.6
    * Added missing MAC vendor id 
    
* 20160908, V0.9.5
    * Updated README to provide a more comprehensive documentation
    * Minor changes
    
* 20160907, V0.9.4
    * Performance Improvement: Now using PCAP capture filter for ARP requests where source MAC address matches one of 
      the given vendor ids. This results in lesser context switches and reduces memory consumption.

* 20160906, V0.9.3
    * Reduced requested PCAP buffer size to 1 MB
    * Fixed some typos in README
    * Fixed travis build descriptor

* 20160905, V0.9.2
    * Added missing `description` property to package descriptor
    
* 20160905, V0.9.1
    * Bug fixture & clean-up
    
* 20160905, V0.9.0
    * Initial Version