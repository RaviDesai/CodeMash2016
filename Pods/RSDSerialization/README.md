# RSDSerialization

[![CI Status](http://img.shields.io/travis/RaviDesai/RSDSerialization.svg?style=flat)](https://travis-ci.org/RaviDesai/RSDSerialization)
[![Version](https://img.shields.io/cocoapods/v/RSDSerialization.svg?style=flat)](http://cocoapods.org/pods/RSDSerialization)
[![License](https://img.shields.io/cocoapods/l/RSDSerialization.svg?style=flat)](http://cocoapods.org/pods/RSDSerialization)
[![Platform](https://img.shields.io/cocoapods/p/RSDSerialization.svg?style=flat)](http://cocoapods.org/pods/RSDSerialization)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Discussion

This Pod provides a small library that makes defining serializable structs in Swift a little more palatable to define and work with.  It uses NSJSONSerialization from the Foundation library to serialize JSON into NSData objects (and deserialize NSData objects into JSON).  NSJSONSerialization serializes to and from references type in the Foundation library like NSString, NSNumber, NSArray, and NSDictionary (based on AnyObject).  This pod seeks to allow you to succinctly and safely convert from Foundation library types to Swift types.

### Defining Model objects

RSDSerialization defines a protocol called JSONSerializable, which is composed of two other protocols: SerializableToJSON and SerializableFromJSON.  SerializableToJSON defines a function called convertToJSON and SerializableFromJSON defines a function called convertFromJSON.  The tricky part, of course is implementing these two functions, and this library attempts to help you do this with concise and safe code.

Please note that in the following code JSON is a typealias for AnyObject and JSONDictionary is a typealias for [String, AnyObject]

For example consider the very simple JSON string:
```javascript
[ { 'intValue': 7, 'stringValue': 'hello', 'dateValue': '2010-01-05T22:19:50Z' },
  { 'intValue': 7, 'stringValue': 'hello' } ]
```

It would be reasonable to want to model the data in Swift using a struct where the Int and String values are required, but the Date value is optional:
```swift
struct MyModelObject {
   var IntValue: Int
   var StringValue: String
   var DateValue: NSDate?
}
```

The RSDSerialization library allows you to do so like this:
```swift
struct MyModelObject: JSONSerialization {
   var IntValue: Int
   var StringValue: String
   var DateValue: Date?
   
   // define init because only some of the values will be allowed to be nil
   init(intValue: Int, stringValue: String, dateValue: NSDate?) {
      self.IntValue = intValue
      self.StringValue = stringValue
      self.DateValue = dateValue
   }
   
   // define a curried create function that calls init.  Used by createFromJSON
   static func create(intValue: Int)(stringValue: String)(dateValue: NSDate?) -> MyModelObject {
      return MyModelObject(intValue, stringValue, dateValue)
   }
   
   func convertToJSON() -> JSON {
      var dict = JSONDictionary()
      addTuplesIf(&dict,
        ("intValue", self.IntValue),
        ("stringValue", self.StringValue),
        ("dateValue", toStringFromDate("yyyy-MM-dd'T'HH:mm:ssX", self.ReleaseDate))
      )
      return dict
   }
   
   func createFromJSON(json: JSON) -> MyModelObject? {
      if let record = json as? JSONDictionary {
        return MyModelObject.create
            <*> record["intValue"] >>- asInt
            <*> record["stringValue"] >>- asString
            <**> record["dateValue"] >>- asDate("yyyy-MM-dd'T'HH:mm:ssX")
      }
      return nil
   }
}
```

In convertToJSON, the ```addTuplesIf``` function is a concise way of adding a value to a JSONDictionary only if the object being passed in is not nil (it omits it from the dictionary if the value is nil).  

In createFromJSON, the complexity level rises a little, there are some advanced functional concepts going on here. The RSDSerialization framework defines three new operators ```>>-```, ```<*>```, and ```<**>```.  The ```>>-``` operator has higher precedence than the other two, so it is executed first.  But before I get to the functioning of these operators let's examine the JSON/JSONDictionary interaction.

When run on the JSON string above, the result of the NSJSONSerialization function in the Foundation library is to produce an NSArray object that contains two NSDictionary objects.  The first NSDictionary object has three entries (intValue, stringValue, and dateValue) and the second NSDictionary object has two entries (just intValue and stringValue).  Swift can interoperate with the Foundation library NSDictionary type in surprising ways, one of the ways is that it you can cast from an NSDictionary object into a Swift generic dictionary of type [String: AnyObject] using as simple ```as?``` cast.  If it succeeds I have a Swift generic dictionary that I can dereference to get AnyObject types.  The problem is that record["intValue"] returns and AnyObject? (optional) not an AnyObject because the "intValue" key may not exist in the dictionary.  So there is a complex interplay between ```>>-``` and the function following it ```asInt``` that converts any AnyObject? into an Int?.   The same is true for >>- asString and >>- asDate which convert to AnyObject? to String? and NSDate? types respectively.

The RSDSerialization framework supplies helper functions for conversion to optional Int, String, Double, Bool, Date, and URL types.  It is also generally quite easy to create your own 'as' helper functions, and I do so for Enum types in the Example project and tests that ship with this Pod.

The ```<*>``` and ```<**>``` operators interoperate with the optional types produced by the ```>>-``` operator and the curried 'create' function.  The ```<*>``` operator requires the value NOT to be null before calling the curry, but the ```<**>``` operator allows the value to be null and still call the curry function.  Thus, for IntValue and StringValue I use the ```<*>``` operator, but for DateValue I use the ```<**>``` operator.  If a ```<*>``` operator is handed a nil value, the result of the entire curried create method is also nil.

Note that despite possible appearances, these operators are completely type-safe.  They make extensive use of generics; so code attempting to pass a double into a function expecting an integer won't even compile.  Model objects should only allow optional properties if a properly constructed object can make sense without the property existing.  Above, the dateValue can sometimes be nil, so the DateValue property is described as Optional, but intValue and stringValue can NEVER be nil, so a properly constructed MyObjectObject MUST contain those two values.  Beyond type and optional safety, the secondary goal of this library was to make it possible to produce model objects that can convert to and from JSON with as little boilerplate as possible.  I wasn't able to eliminate boilerplate altogether, but it is significantly smaller than it otherwise might have been.

### Using Model objects
Model objects all inherit from the JSONSerialization protocol.  This allows for the construction of a generic ModelFactory class that can encapsulate the code to serialize arrays of JSON into arrays of object.  The following code could be used to that effect:

```swift
let data = NSData(contentsOfFile: fileContainingJSON)!
var error: NSError?
if let json: JSON = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error) {
   var modelObjects: [MyModelObject] = ModelFactory<MyModelObject>.createFromJSONArray(json)
}
```

## Requirements

This very simple Pod is entirely written in Swift and only depends on the Foundation framework.

## Installation

RSDSerialization is available as a [CocoaPod](http://cocoapods.org).  It is not, however submitted to the standard CocoaPods repository.  If you wish to use it from my repo, you can issue the following command from the terminal prompt (which will add my CocoaPods repo to your installation).  Note if you don't wish to add my spec repo to your installation there are other ways of referencing this pod, check the documentation above.

```ruby
pod repo add RSDSpecs https://github.com/RaviDesai/RSDSpecs.git
```

Then add the following line to the top of your to your Podfile to point your local Podfile to the newly added spec repository

```ruby
source 'https://github.com/RaviDesai/RSDSpecs.git'
```

And then add this line further down to enable this Pod in your app

```ruby
pod "RSDSerialization"
```

## Author

RaviDesai, ravidesai@me.com

## License

RSDSerialization is available under the MIT license. See the LICENSE file for more info.
