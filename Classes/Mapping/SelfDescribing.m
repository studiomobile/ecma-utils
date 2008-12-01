#import "SelfDescribing.h"
#import <objc/runtime.h>
#import "NSObject+Utils.h"

static char *skip(char *str, int n) {
	return str + n;
}

@implementation SelfDescribing

+ (NSString*)__propertyNameFromExternalProp:(NSString*)prop {
	return prop;
}

+ (Class)propertyClass:(NSString*)prop {
	prop = [self __propertyNameFromExternalProp:prop];
	objc_property_t objcProp = class_getProperty(self, [prop cStringUsingEncoding:NSASCIIStringEncoding]);
	if(objcProp) {
		const char* cpropTypeStr = property_getAttributes(objcProp);	
		NSInteger cpropTypeStrLen = strlen(cpropTypeStr);
		if(cpropTypeStr && cpropTypeStrLen < 512) {
			char propTypeStr[512];
			char *head = propTypeStr;
			strcpy(propTypeStr, cpropTypeStr);
			head = skip(propTypeStr, 1);
			switch(head[0]) {
				case 'c': 
				case 'i': 
				case 's':
				case 'l': 
				case 'q':
				case 'C':
				case 'I':
				case 'S':
				case 'L':
				case 'Q':
				case 'f':
				case 'd':
				case 'B':
					return objc_lookUpClass("NSNumber");
				case '@':
					if(cpropTypeStrLen > 3) {
						head = skip(head, 2);
						char *lastQuote = strstr(head, "\"");
						if(lastQuote) {
							lastQuote[0] = '\0';
							return objc_lookUpClass(head);
						}
					} 
					return nil;
				case 'v': 
				case '*': 
				case '#': 
				case ':': 
				case '[': 
				case '(': 
				case '{': 
				case 'b': 
				case '^': 
				case '?':
				default: 
					NSLog(@"propertyClass failed because client requested property with unknown type encoding ");
					return nil;
			}			
		}
	}
	return nil;
}

+ (BOOL)isPrimitive {
	return NO;
}

- (void)setValue:(id)val forMappedKey:(NSString*)key {
	key = [[self class] __propertyNameFromExternalProp:key];
	[self setValue:val forKey:key];
}

- (id)valueForMappedKey:(NSString*)key {
	key = [[self class] __propertyNameFromExternalProp:key];
	return [self valueForKey:key];
}

@end