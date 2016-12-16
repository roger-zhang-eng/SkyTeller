# SkyTeller 

`SkyTeller` is a small objective C programm, running on iOS platform. And finally published on apple store.




## Demo	
![Exercise1](https://github.com/roger-zhang-eng/SkyTeller/tree/master/demo/1.png)

## Requirements
- iOS 8.0+
- Xcode 6.1+
- Pod 0.38.0+

## Installation Steps
Please use pod to install [CocoaPods](https://cocoapods.org) workspace, based on Podfile.

1) After download source code package, run 'pod install' in the same directory of 'Podfile'

2) Use Xcode 7.3 or 8.1 to open 'SkyTeller.xcworkspace'

3) In the Xcode 8.3, build and run the application. If select Simulator, please use Simulator -> Debug -> Location -> custom Location to set position, like Sydney lat: -33.8734 lng: 151.206894.

Note: Simulator location sometimes is not stable, if App detect long time cannot get location, please manuall change Simulator's Location position, that trick can let App get the location data. 
 
## SW description
This is one example app with swift and ObjC mix, under Reactive signal driving. 
Only WXController.swift draw the UI, and all the logical code designed by objective C code.
