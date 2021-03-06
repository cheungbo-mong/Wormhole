# Wormhole

Original author: [Mutual Mobile](https://github.com/mutualmobile/MMWormhole)

## Example

Example in `./Examples/UsingSwiftPackage.Xcode12` is **highly RECOMMENDED**, if you're using `Xcode 12`. Not need to pod install. Just open the `Example.xcworkspace`, then you're good to go.

If you prefer using Cocoapods, there is also a corresponding example lying in `./Examples/UsingCocoaPods`.

> Swift package for mac targets are not ready with 'neat' solution except duplicating codes or wrapping codes inside `#if !os(macOS) ... #endif` macro which isn't as elegant as the way Cocoapods handles cross-platform targets.
>
> So if you're planning using `Wormhole` with macOS targets, please go with Cocoapods anyway.

## Requirements

## Installation

### CocoaPods

```ruby
pod 'Wormhole', :git => 'https://github.com/vencewill/Wormhole.git'
```

### Swift Package Manager

```swift
.package(url: "https://github.com/vencewill/Wormhole.git", from: "0.1.0"),
```

## Author

Vance Will, vancewilll@icloud.com

## License

Wormhole is available under the MIT license. See the LICENSE file for more info.
