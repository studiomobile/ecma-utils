#import <Foundation/Foundation.h>

@protocol ClassMetadata

+ (Class)propertyClass:(NSString*)prop;
+ (BOOL)isPrimitive;
+ (void)initMetadata;

@end