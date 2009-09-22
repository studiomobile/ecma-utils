#import <Foundation/Foundation.h>

@interface NSDate(Utils) 

- (BOOL)isAfter:(NSDate*)other;
- (BOOL)isBefore:(NSDate*)other;
- (NSTimeInterval)minutesSinceDate:(NSDate*)date;
- (NSDate*)addMinutes:(NSTimeInterval)minutes;
- (NSTimeInterval)hoursSinceDate:(NSDate*)date;
- (NSTimeInterval)daysSinceDate:(NSDate*)date;
- (NSDate*)dayStart;

@end

