#import "ESLogger.h"


@interface TagInfo : NSObject{
	LogVerbocityLevel level;
}
@property(nonatomic, assign) LogVerbocityLevel level;

- (id)initWithLevel:(LogVerbocityLevel)_level;

@end

@implementation TagInfo
@synthesize level;

- (id)initWithLevel:(LogVerbocityLevel)_level {
	self = [super init];
	if (self != nil) {
		level = _level;
	}
	return self;	
}


@end


/////////////////////////////////////////////////////////////////////////////////////////////////

@interface ESLogger ()
	- (LogVerbocityLevel)instLevelForTag:(NSString*)tag;
@end



static ESLogger *sharedLogger;

@implementation ESLogger

#pragma mark singleton

- (id)init{
	NSAssert(NO, @"should not call");
	return nil;
}

- (id) privateInit{
	self = [super init];
	if (self != nil) {
		tagInfo = [NSMutableDictionary new];				   
	}
	return self;
}


+ (ESLogger*)sharedLogger {
	@synchronized(self) {
		if(sharedLogger == nil) {
			[[self alloc] privateInit];
		}
	}
	return sharedLogger;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if(sharedLogger == nil) {
			sharedLogger = [super allocWithZone:zone];
			return sharedLogger;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone *)zone { return self; }
- (id)retain { return self; }
- (unsigned)retainCount { return UINT_MAX; }
- (void)release { }

- (void)dealloc {
	[tagInfo release];
	[super dealloc];
}

#pragma mark private

+ (NSString*)formatFunction:(char*)funcName line:(int)line {
	return [NSString stringWithFormat:@"{ %s : %d }", funcName, line];
}

- (BOOL)canLogTag:(NSString*)tag level:(LogVerbocityLevel)level {
	return level <= [self instLevelForTag:tag];
}

- (NSString*)finalFormat:(NSString*)format tag:(NSString*)tag source:(NSString*)srcLocationDescription{
	NSMutableString *finalFormat = [NSMutableString string];
	if(isShowTags) {
		[finalFormat appendFormat:@"<%@> ", tag];
	}
	if(srcLocationDescription && isShowSourceLocations) {
		[finalFormat appendFormat:@"%@ ", srcLocationDescription];
	}
	
	[finalFormat appendFormat:@"%@", format];
	return [[finalFormat copy] autorelease];
}

#pragma mark private - interface backend

- (void)instLogTag:(NSString*)tag level:(LogVerbocityLevel)level source:(NSString*)srcLocationDescription format:(NSString*)format varargs:(va_list)l  {
	if(![self canLogTag:tag level:level]) return;
	format = [self finalFormat:format tag:tag source:srcLocationDescription];
	NSLogv(format, l);
}

- (void)instSetLevel:(LogVerbocityLevel)level forTag:(NSString*)tag {
	@synchronized(self) {
		TagInfo *info = [tagInfo objectForKey:tag];
		if(!info) {
			info = [[TagInfo alloc] initWithLevel:level];
			[tagInfo setObject:info forKey:tag];
			[info release];
		}
		info.level = level;
	}
}

- (void)instEnableTag:(NSString*)tag {
	@synchronized(self) {
		[self instSetLevel:lvlNormal forTag:tag];
	}
}

- (void)instDisableTag:(NSString*)tag {
	@synchronized(self) {
		[self instSetLevel:lvlNone forTag:tag];
	}
}

- (LogVerbocityLevel)instLevelForTag:(NSString*)tag {
	TagInfo *info = [tagInfo objectForKey:tag];
	return info ? info.level : lvlError;
}

- (void)instShowSourceLocations:(BOOL)isShow {
	isShowSourceLocations = isShow;
}

- (void)instShowTags:(BOOL)isShow {
	isShowTags = isShow;
}

#pragma mark public

+ (void)logTag:(NSString*)tag level:(LogVerbocityLevel)level source:(NSString*)srcLocationDescription format:(NSString*)format, ...  {
	va_list l;
	va_start(l, format);
	[[self sharedLogger] instLogTag:tag level:level source:srcLocationDescription format:format varargs:l];
}

+ (void)enableTag:(NSString*)tag {
	[[self sharedLogger] instEnableTag:tag];
}

+ (void)disableTag:(NSString*)tag {
	[[self sharedLogger] instDisableTag:tag];
}

+ (void)setLevel:(LogVerbocityLevel)level forTag:(NSString*)tag {
	[[self sharedLogger] instSetLevel:level forTag:tag];
}

+ (LogVerbocityLevel)levelForTag:(NSString*)tag {
	return [[self sharedLogger] instLevelForTag:tag];
}

+ (void) setErrorLogging:(NSString*)tag {
	[[self sharedLogger] instSetLevel:lvlError forTag:tag];
}

+ (void) setNormalLogging:(NSString*)tag {
	[[self sharedLogger] instSetLevel:lvlNormal forTag:tag];
}

+ (void) setVerboseLogging:(NSString*)tag {
	[[self sharedLogger] instSetLevel:lvlVerbose forTag:tag];
}

+ (BOOL) isVerboseLogging:(NSString*)tag {
	return [[self sharedLogger] instLevelForTag:tag] >= lvlVerbose;
}

+ (void)showSourceLocations {
	[[self sharedLogger] instShowSourceLocations:YES];
}

+ (void)hideSourceLocations {
	[[self sharedLogger] instShowSourceLocations:NO];
}

+ (void)showTags {
	[[self sharedLogger] instShowTags:YES];
}

+ (void)hideTags {
	[[self sharedLogger] instShowTags:NO];
}


@end
