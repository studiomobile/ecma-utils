@interface NSDate(ChronologicAdditions) 
- (bool)isAfter:(NSDate*)other;
- (bool)isBefore:(NSDate*)other;
- (CGFloat)minutesSinceDate:(NSDate*)date;
- (NSDate*)addMinutes:(CGFloat)minutes;
- (CGFloat)hoursSinceDate:(NSDate*)date;
- (NSDate*)dayStart;
@end

