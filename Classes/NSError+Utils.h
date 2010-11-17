#import <UIKit/UIKit.h>

#ifdef DEBUG_LOG
#define LOG1(a) NSLog(a)
#define LOG2(a, b) NSLog(a, b)
#else
#define LOG2(a,b)
#define LOG1(a)
#endif

@interface NSError(Utils)

+ (NSError *)errorWithDomain:(NSString*)domain code:(NSInteger)code description:(NSString*)description;
+ (NSError *)errorWithValue:(id)value forKey:(NSString *)keyName;
+ (NSError *)errorWithValue:(id)value forKey:(NSString *)keyName fromError:(NSError *)error;

- (void)display;
- (void)display:(NSString*)actionDescription;


@end

@interface NSError(DetailedDescription)
- (NSString*)detailedDescription;
- (void)displayDetailedDescription;

// Will show localizedDescription on device and detailedDescription on simulator or if DEBUG_DETAILED_ERROR_DESCRIPTION defined
- (NSString*)platformDependentDescription;
- (void)displayPlatformDependentDescription;
@end
