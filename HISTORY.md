# Release History

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