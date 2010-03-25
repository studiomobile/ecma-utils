typedef enum LogVerbocityLevel_tag {
	lvlNone = 0,
	lvlError = 1,
	lvlNormal = 2,
	lvlVerbose = 3	
} LogVerbocityLevel;

@interface ESLogger : NSObject {
	NSMutableDictionary *tagInfo;
	BOOL isShowTags;
	BOOL isShowSourceLocations;
}

+ (void)logTag:(NSString*)tag level:(LogVerbocityLevel)level source:(NSString*)srcLocationDescription format:(NSString*)format, ...;

+ (void)enableTag:(NSString*)tag;
+ (void)disableTag:(NSString*)tag;

+ (void)showSourceLocations;
+ (void)hideSourceLocations;
+ (void)showTags;
+ (void)hideTags;

+ (void)setLevel:(LogVerbocityLevel)level forTag:(NSString*)tag;
+ (LogVerbocityLevel)levelForTag:(NSString*)tag;
+ (void) setErrorLogging:(NSString*)tag;
+ (void) setNormalLogging:(NSString*)tag;
+ (void) setVerboseLogging:(NSString*)tag;
+ (BOOL) isVerboseLogging:(NSString*)tag;

#pragma mark private

+ (NSString*)formatFunction:(const char*)funcName line:(int)line;

@end

#define ESLog(tag, fmt, ...) [ESLogger logTag:tag level:lvlNormal source:[ESLogger formatFunction:__PRETTY_FUNCTION__ line:__LINE__] format:fmt, ##__VA_ARGS__]
#define ESLogVerbose(tag, fmt, ...) [ESLogger logTag:tag level:lvlVerbose source:[ESLogger formatFunction:__PRETTY_FUNCTION__ line:__LINE__] format:fmt, ##__VA_ARGS__]
#define ESLogError(tag, fmt, ...) [ESLogger logTag:tag level:lvlError source:[ESLogger formatFunction:__PRETTY_FUNCTION__ line:__LINE__] format:fmt, ##__VA_ARGS__]

