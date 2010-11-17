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

@implementation NSArray (Utils)

-(id)detect: (NSPredicate*)predicate{
	for (id each in self) if([predicate evaluateWithObject:each]) return each;	
	return nil;	
}

-(NSArray*)select: (NSPredicate*)predicate{
	NSMutableArray* result = [NSMutableArray array];
	for(id each in self) if([predicate evaluateWithObject:each]) [result addObject:each];
	return [[result copy] autorelease];
}

-(NSArray*)reject: (NSPredicate*)predicate{
	NSArray* toReject = [self select:predicate];
	return [self filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"not self in %@", toReject]];
}

-(NSArray*)collect: (NSString*)keyPath{
	NSString* path = [@"@unionOfObjects." stringByAppendingString: keyPath];
	return [self valueForKeyPath: path];
}

- (NSArray *)take:(NSUInteger)count {
	if(!count) return [NSArray array];
	if(count >= self.count) {
		return [[self copy] autorelease];
	}
	
	NSRange range;
	range.location = 0;
	range.length = MAX(self.count, count);
	return [self objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
}

- (NSArray *)splitUsingSelector:(SEL)selector {
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
	id lastTestObject = nil;
	NSMutableArray *curSlice = nil;
	for (id curElement  in self) {
		id curTestObject = [curElement performSelector:selector];
		if(![lastTestObject isEqual:curTestObject]) {
			curSlice = [NSMutableArray array];
			[result addObject:curSlice];
		}
		lastTestObject = curTestObject;
		[curSlice addObject:curElement];
	}

	for (int i = 0; i < result.count; i++) {
		NSArray *slice = [result objectAtIndex:i];
		[result replaceObjectAtIndex:i withObject:[[slice copy] autorelease]];
	}
	
	return [[result copy] autorelease];
}

@end






