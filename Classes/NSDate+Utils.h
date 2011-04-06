#import <Foundation/Foundation.h>

@interface NSDate(Utils) 

+ (NSDate*)today;

- (BOOL)isAfter:(NSDate*)other;
- (BOOL)isBefore:(NSDate*)other;
- (NSDate*)minWith:(NSDate*)other;
- (NSDate*)maxWith:(NSDate*)other;
- (NSTimeInterval)minutesSinceDate:(NSDate*)date;
- (NSDate*)addMinutes:(NSTimeInterval)minutes;
- (NSTimeInterval)hoursSinceDate:(NSDate*)date;
- (NSTimeInterval)daysSinceDate:(NSDate*)date;
- (NSDate*)dayStart;

@end

