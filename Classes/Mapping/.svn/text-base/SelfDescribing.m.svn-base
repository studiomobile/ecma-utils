#import "SelfDescribing.h"
#import <objc/runtime.h>
#import "NSObject+Utils.h"

static NSMutableDictionary* metadata = nil;
static NSMutableSet *inited = nil;

static NSMutableSet* initedClasses() {
	@synchronized([SelfDescribing class]) {
		if(inited == nil) {
			inited = [[NSMutableSet alloc] init];
		}
	}
	return inited;
}

static NSMutableDictionary* md() {
	@synchronized([SelfDescribing class]) {
		if(metadata == nil) {
			metadata = [[NSMutableDictionary alloc] init];
		}
	}
	return metadata;
}

static NSString* key(Class self, NSString *prop) {
	return [NSString stringWithFormat:@"%s_%@", class_getName(self), prop];
}

static NSString* ckey(Class self, const char *prop) {
	return [NSString stringWithFormat:@"%s_%s", class_getName(self), prop];
}

@implementation SelfDescribing

+ (Class)propertyClass:(NSString*)prop {
	@synchronized([SelfDescribing class]) {
		NSMutableSet *inited = initedClasses();
		if(![inited containsObject:self]) {
			[self initMetadata];
		}
		return [md() objectForKey:key(self, prop)];
	}
	return nil;
}

+ (BOOL)isPrimitive {
	return NO;
}

+ (void)initMetadata {
	//do nothing here
}

+ (void)map:(SEL)sel to:(Class)klass {
	checkNotNil(klass, @"klass nil");
	@synchronized([SelfDescribing class]) {
		const char *constSelName = sel_getName(sel);
		int len = strlen(constSelName);
		char *selName = malloc(sizeof(char)*(len + 1));
		strcpy(selName, constSelName);
		if(isupper(selName[0])) {
			selName[0] = tolower(selName[0]);
		}
		[md() setObject:klass forKey:ckey(self, selName)];
		selName[0] = toupper(selName[0]);
		[md() setObject:klass forKey:ckey(self, selName)];	
		free(selName);
	}
}

@end