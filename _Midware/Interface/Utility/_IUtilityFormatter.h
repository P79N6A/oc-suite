#import <Foundation/Foundation.h>

// ----------------------------------
// MARK: 类型定义
// ----------------------------------

typedef enum : NSUInteger {
    FileFormatKeyedArchive = 0, //default
    FileFormatXMLPropertyList,
    FileFormatBinaryPropertyList,
    FileFormatJSON,
    FileFormatUserDefaults,
    FileFormatKeychain, //requires FXKeychain library
    FileFormatCryptoCoding, //requires CryptoCoding library
    FileFormatHRCodedXML, //requires HRCoder library
    FileFormatHRCodedJSON, //requires HRCoder library
    FileFormatHRCodedBinary, //requires HRCoder library
    FileFormatFastCoding, //requires FastCoding library
} FileFormat;
// ----------------------------------
// MARK: 类声明
// ----------------------------------

@protocol _IUtilityFormatter <NSObject>

- (id)process:(id)data by:(FileFormat)format;

@end
