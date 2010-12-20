#import "NSBundle+Utils.h"

@implementation NSBundle(Utils)

- (id)loadPlist:(NSString*)name errorDescription:(NSString**)errorDescription {
    NSPropertyListFormat format;
    NSString *path = [self pathForResource:name ofType:@"plist"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    id result = [NSPropertyListSerialization propertyListFromData:data
                                                 mutabilityOption:NSPropertyListImmutable
                                                           format:&format
                                                 errorDescription:errorDescription];
    return result;
}

@end
