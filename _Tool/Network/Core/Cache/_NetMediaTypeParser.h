//
//  _net_media_type_parser.h
//  consumer
//
//  Created by fallen.ink on 9/22/16.
//
//

#import <Foundation/Foundation.h>

/**
 * Implements a RFC 2616 confirming parser for extracting the
 * content type and the character encoding from Internet Media
 * Types
 */
@interface _NetMediaTypeParser : NSObject {
    NSString *mimeType;
    __unsafe_unretained NSString *_textEncoding;
    __unsafe_unretained NSString *_contentType;
}

@property (unsafe_unretained, nonatomic, readonly) NSString *textEncoding;
@property (unsafe_unretained, nonatomic, readonly) NSString *contentType;

- (id)initWithMIMEType:(NSString*)theMIMEType;

@end
