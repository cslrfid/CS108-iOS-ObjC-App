# CslCs108iOsApp
Library and demo app for CS108 handheld reader

Initial version: 1.0.1 (tested against Bluetooth FW 1.0.11, RFID FW 2.6.14, SiliconLab FW 1.0.9)

- Developed the communication and packet exchange over BLE for device discovery, connection and configurations.
- Created three parallel workstreams for the basic operations: (1) Collecting notifications over the Characterister ID 9901 and put data into a buffer (2) decode the incoming notifications and packetize the data.  All packets being stored in a circular buffer (3) User application and interactions
- Prioritize the BLE interface class at the Global Central Dispatch queues so that the BLE communication is on the separate high priority queue and running on a separate thread in the background.  The UI and main program would be running on the main thread.  Tag reading to the buffer is on its own thread
- EnableTag inventory in compact mode.  
- Duplicate elimination in inventory mode.  Tested against 1000 tag read
- UI for reader selection, connection and tag inventory listing.
