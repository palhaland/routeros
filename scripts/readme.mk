# Collection of Mikrotik Scripts

This is just some small nice to have Mikrotik RouterOS scripts.

## selectFrequency.rsc
Script to set the frequency of the main wlan interface if there is only one radio. 
This is usefull for devices that use the main wlan interface as an AP 
and a virtual station pseudobridge as the secondary interface.

One of the biggest usecases for this setup is the small Mikrotik RouterBOARD mAP L-2nD.
This is a quite poweful device that works nice as a travel router to share one connection
with all your wireless devices.

The biggest reason for having the main interface as the AP-Bridge is that network will be
broadcasted even if the virtual one has not connected to a network. That way you will be
able to use the ethernet plug as the external connection.

