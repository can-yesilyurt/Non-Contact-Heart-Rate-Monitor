# Non-Contact-Heart-Rate-Monitor

OSX Application implementing serial interface for Seeed-Studio 60GHz mmWave Module - Respiratory Heartbeat Detection.

## Implemented functions:   

- Non-contact detection of heart rate with around 2 m distance
- Distance of the target body (in cm)
- Detection of any movement of the target body (outputs a magnitude between 1-100)
- Position of the body (i.e., None | Stationary | Active)

## Setup

mmWave radar Module can be connected to Mac by using usb-serial converter or bluetooth-serial module

Tested in MacBook Pro M2 Max - connected with both of the above mentioned methods.

Documentation about the hardware can be found at [Seed-Studio Wiki](https://wiki.seeedstudio.com/Radar_MR60BHA1/).

## Dependencies:


[ORSSerialPort](https://github.com/armadsen/ORSSerialPort.git)

## License

Non-Contact-Heart-Rate-Monitor is released under an MIT license, meaning you're free to use it in both closed and open source projects. However, even in a closed source project, you must include a publicly-accessible copy of Non-Contact-Heart-Rate-Monitor's copyright notice, which you can find in the LICENSE file.

##App ScreenShot

![alt text](https://github.com/can-yesilyurt/Non-Contact-Heart-Rate-Monitor/blob/main/Non-Contact%20Heart%20Rate%20Monitor/App_SC.png?raw=true)


