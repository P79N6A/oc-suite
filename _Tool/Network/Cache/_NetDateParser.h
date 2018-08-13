//
//  _net_date_parser.h
//  consumer
//
//  Created by fallen.ink on 9/22/16.
//
//

#import <Foundation/Foundation.h>

@interface _NetDateParser : NSDate {
    NSDateFormatter *gh_rfc1123DateFormatter;
    NSDateFormatter *gh_rfc850DateFormatter;
    NSDateFormatter *gh_ascTimeDateFormatter;
    NSDateFormatter *gh_is8601DateFormatter;
    NSDateFormatter *gh_rfc822DateFormatter;
}

- (NSDate *)gh_parseISO8601:(NSString *) dateString;
+ (NSDate *)gh_parseISO8601:(NSString *) dateString;

/*!
 @method gh_parseRFC822
 @abstract Parse RFC822 encoded date
 @param dateString Date string to parse, eg. 'Wed, 01 Mar 2006 12:00:00 -0400'
 @result Date
 */
- (NSDate *)gh_parseRFC822:(NSString *) dateString;
+ (NSDate *)gh_parseRFC822:(NSString *) dateString;

/*!
 @method gh_parseHTTP
 @abstract Parse http date, currently only handles RFC1123 date
 @param dateString Date string to parse
 
 HTTP-date    = rfc1123-date | rfc850-date | asctime-date
 
 Sun, 06 Nov 1994 08:49:37 GMT  ; RFC 822, updated by RFC 1123
 Sunday, 06-Nov-94 08:49:37 GMT ; RFC 850, obsoleted by RFC 1036
 Sun Nov  6 08:49:37 1994       ; ANSI C's asctime() format
 */
- (NSDate *)gh_parseHTTP:(NSString *) dateString;
+ (NSDate *)gh_parseHTTP:(NSString *) dateString;

/*!
 Parse time since epoch.
 @param timeSinceEpoch An NSNumber or NSString (responds to longLongValue)
 @result NSDate or nil if timeSinceEpoch was nil
 */
- (NSDate *)gh_parseTimeSinceEpoch:(id)timeSinceEpoch;
+ (NSDate *)gh_parseTimeSinceEpoch:(id)timeSinceEpoch;

- (NSDate *)gh_parseTimeSinceEpoch:(id)timeSinceEpoch withDefault:(id)value;
+ (NSDate *)gh_parseTimeSinceEpoch:(id)timeSinceEpoch withDefault:(id)value;

/*!
 @method gh_formatRFC822
 @abstract Get date formatted for RFC822
 @result The date string, like "Wed, 01 Mar 2006 12:00:00 -0400"
 */
- (NSString *)gh_formatRFC822;

/*!
 @method gh_formatHTTP
 @abstract Get date formatted for RFC1123 (HTTP date)
 @result The date string, like "Sun, 06 Nov 1994 08:49:37 GMT"
 */
- (NSString *)gh_formatHTTP;

/*!
 @method gh_formatISO8601
 @abstract Get date formatted for ISO8601 (XML date)
 @result The date string, like ... TODO(gabe)
 */
- (NSString *)gh_formatISO8601;

/*!
 @method gh_iso8601DateFormatter
 @abstract For example, '2007-10-18T16:05:10.000Z'. Returns a new autoreleased formatter since NSDateFormatter is not thread-safe.
 @result Date formatter for ISO8601
 */
- (NSDateFormatter *)gh_iso8601DateFormatter;
+ (NSDateFormatter *)gh_iso8601DateFormatter;

/*!
 @method gh_rfc822DateFormatter
 @abstract For example, 'Wed, 01 Mar 2006 12:00:00 -0400'. Returns a new autoreleased formatter since NSDateFormatter is not thread-safe.
 @result Date formatter for RFC822
 */
- (NSDateFormatter *)gh_rfc822DateFormatter;
+ (NSDateFormatter *)gh_rfc822DateFormatter;

/*!
 @method gh_rfc1123DateFormatter
 @abstract For example, 'Wed, 01 Mar 2006 12:00:00 GMT'. Returns a new autoreleased formatter since NSDateFormatter is not thread-safe.
 @result Date formatter for RFC1123
 */
- (NSDateFormatter *)gh_rfc1123DateFormatter;
+ (NSDateFormatter *)gh_rfc1123DateFormatter;

/*!
 @method gh_rfc850DateFormatter
 @abstract For example, 'Sunday, 06-Nov-94 08:49:37 GMT'. Returns a new autoreleased formatter since NSDateFormatter is not thread-safe.
 @result Date formatter for RFC850
 */
- (NSDateFormatter *)gh_rfc850DateFormatter;
+ (NSDateFormatter *)gh_rfc850DateFormatter;

/*!
 @method gh_ascTimeDateFormatter
 @abstract For example, 'Sun Nov  6 08:49:37 1994'. Returns a new autoreleased formatter since NSDateFormatter is not thread-safe.
 @result Date formatter for asctime
 */
- (NSDateFormatter *)gh_ascTimeDateFormatter;
+ (NSDateFormatter *)gh_ascTimeDateFormatter;

- (NSString *)formatHTTPDate:(NSDate*)date;
+ (NSString *)formatHTTPDate:(NSDate*)date;

@end
