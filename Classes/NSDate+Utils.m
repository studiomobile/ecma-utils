@implementation NSDate(ChronologicAdditions)

- (BOOL)isAfter:(NSDate*)other {
	return [self compare:other] == NSOrderedDescending;
}

- (BOOL)isBefore:(NSDate*)other {
	return [self compare:other] == NSOrderedAscending;
}

- (CGFloat)minutesSinceDate:(NSDate*)date {
	return [self timeIntervalSinceDate:date]/60;
}

- (NSDate*)addMinutes:(CGFloat)minutes {
	return [self addTimeInterval:60*minutes];
}

- (CGFloat)hoursSinceDate:(NSDate*)date {
	return [self timeIntervalSinceDate:date]/3600;
}

- (NSDate*)dayStart {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
	return [calendar dateFromComponents:components];
}

@end
