#import "NSObject+Utils.h"
#import "NSMutableArray+Utils.h"
#import "NSArray+Utils.h"

@implementation NSArray(Randomization)

- (NSString*)joinWith:(NSString*)d selector:(SEL)s {
    if(!self.count) return @"";
    
    NSMutableString *result = [NSMutableString string];
    for(NSObject *item in self) {
        [result appendFormat:@"%@%@", [item performSelector:s], d];
    }
    
    if(result.length)
        [result replaceCharactersInRange:NSMakeRange(result.length - d.length, d.length) 
                              withString:@""];
    
    return [NSString stringWithString:result];
}

- (NSString*)joinWith:(NSString*)d {
    return [self joinWith:d selector:@selector(description)];
}

- (NSArray*)shuffle {
	NSMutableArray *shuffle = [NSMutableArray arrayWithArray:self];
	[shuffle inplaceShuffle];
	return [[shuffle copy] autorelease];
}

- (NSArray*)filterUsingSelector:(SEL)selector target:(id)target {
	NSMutableArray *filtered = [NSMutableArray arrayWithArray:self];
	[filtered removeAllUsingSelector:selector target:target];
	return [[filtered copy] autorelease];
}

@end





