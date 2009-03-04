@implementation NSDate(ChronologicAdditions)
- (bool)isAfter:(NSDate*)other {
	return [self compare:other] == NSOrderedDescending;
}

- (bool)isBefore:(NSDate*)other {
	return [self compare:other] == NSOrderedAscending;
}

- (CGFloat)minutesSinceDate:(NSDate*)date {
	return [self timeIntervalSinceDate:date]/60;
}

- (NSDate*)addMinutes:(CGFloat)minutes {
	return [self addTimeInterval:60*minutes];
}

- (CGFloat)hoursSinceDate:(NSDate*)date {
	return [self minutesSinceDate:date]/60.0;
}

- (NSDate*)dayStart {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
	return [calendar dateFromComponents:components];
}
@end
