#import "NSDate+Utils.h"

@implementation NSDate(Utils)

- (BOOL)isAfter:(NSDate*)other {
	return [self compare:other] == NSOrderedDescending;
}


- (BOOL)isBefore:(NSDate*)other {
	return [self compare:other] == NSOrderedAscending;
}


- (NSDate*)minWith:(NSDate*)other {
    return [other isBefore:self] ? other : self;
}


- (NSDate*)maxWith:(NSDate*)other {
    return [other isAfter:self] ? other : self;
}


- (NSTimeInterval)minutesSinceDate:(NSDate*)date {
	return [self timeIntervalSinceDate:date]/60;
}


- (NSDate*)addMinutes:(NSTimeInterval)minutes {
	return [self addTimeInterval:60*minutes];
}


- (NSTimeInterval)hoursSinceDate:(NSDate*)date {
	return [self timeIntervalSinceDate:date]/3600;
}


- (NSTimeInterval)daysSinceDate: (NSDate*)date{
	return [self hoursSinceDate:date]/24;
}


- (NSDate*)dayStart {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
	return [calendar dateFromComponents:components];
}

@end
