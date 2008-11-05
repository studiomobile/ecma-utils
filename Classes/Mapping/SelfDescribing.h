#import "ClassMetadata.h"

@interface SelfDescribing : NSObject<ClassMetadata>

+ (void)map:(SEL)sel to:(Class)klass;

@end
