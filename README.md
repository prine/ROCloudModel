# ROCloudModel
[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
             )](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
             )](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
            )](http://mit-license.org)

Provides an abstract layer above the CloudKit and simplifies the mapping between CKRecord and Swift Data classes.

## Installation

ROCloudModel is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ROCloudModel"
```

## How to use
Use the ROCloudModel class as base class of your data classes. The mapping of the data is directly done in the getter/setter methods of the defined attribute.

Report
```Swift
class Report : ROCloudModel {

    required init() {
        super.init()
        self.recordType = "Reports"
        super.initializeRecord()
    }

    convenience init(name:String, title:String) {
        self.init()

        self.name = name
        self.title = title
    }

    var name:String {
        get {
            return self.record?["name"] as? String ?? ""
        }

        set(value) {
            self.record?["name"] = value
        }
    }

    var title:String {
        get {
            return self.record?["title"] as? String ?? ""
        }

        set(value) {
            self.record?["title"] = value
        }
    }
}```

Post
```

```

## License

```
The MIT License (MIT)

Copyright (c) 2016 Robin Oster (http://prine.ch)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

## Author

Robin Oster, robin.oster@rascor.com
