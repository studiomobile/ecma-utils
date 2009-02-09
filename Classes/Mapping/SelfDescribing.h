#import "ClassMetadata.h"

#define PROP_MAPPING +(NSString*)__propertyNameFromExternalProp:(NSString*)prop { NSUInteger propHash = [prop hash];

#define MAP(externalName, propName) \
static NSUInteger hash##externalName = 0; \
if(hash##externalName == 0) { hash##externalName = [@# externalName hash]; } \
if(propHash == hash##externalName && [prop isEqualToString:@# externalName]) { return @# propName; }

#define END_PROP_MAPPING return prop; }

@interface SelfDescribing : NSObject<ClassMetadata>

- (void)setValue:(id)val forMappedKey:(NSString*)key;
- (id)valueForMappedKey:(NSString*)key;

@end
