#import "POXMapping.h"
#import <objc/runtime.h>
#import "NSObject+Utils.h"
#import "ClassMetadata.h"
#import "POXMappingUtil.h"
#import "NSError+Utils.h"

static void skip(struct POXElement *element) {
	element->object = nil;
	element->elementType = kPOXElementSkip;
}

static struct POXElement* push_new(struct POXElement *root) {
	struct POXElement *element = (struct POXElement*)malloc(sizeof(struct POXElement));
	memset(element, 0, sizeof(struct POXElement));
	element->prev = root;
	return element;
}

static struct POXElement *pop(struct POXElement *root) {
	struct POXElement *prev;
	prev = root->prev;
	if(root->object) {
		[root->object release];
	}
	free(root);
	return prev;
}

static BOOL match(struct POXElement *root, NSUInteger n, ...) {
	checkNotNull(root, @"Cannot check NULL root");
	va_list elements;
	BOOL result = TRUE;
	va_start(elements, n);
	for(int i = 0; i < n; ++i) {
		POXElementType type = va_arg(elements, POXElementType);
		if(root == NULL || (type & root->elementType) == 0) {
			result = FALSE;
			break;
		}
		root = root->prev;
	}
	va_end(elements);
	return result;
}

static NSDictionary *primitivesStorage = nil;

static const NSDictionary *primitives() {
	@synchronized(primitivesStorage) {
		if(primitivesStorage == nil) {
			primitivesStorage = [[NSDictionary alloc] initWithObjectsAndKeys:
								 [POXPrimitiveHolder class], @"string",
								 [POXNumberHolder class], @"byte", 
								 [POXNumberHolder class], @"char", 
								 [POXNumberHolder class], @"short",
								 [POXNumberHolder class], @"int", 
								 [POXNumberHolder class], @"long", 
								 [POXNumberHolder class], @"float", 
								 [POXNumberHolder class], @"double",
								 nil];
		}
	}
	return primitivesStorage;
}


@implementation POXMapping

- (id)init {
	if (self = [super init]) {
		result = nil;
		top = push_new(NULL);
		top->elementType = kPOXElementRoot;
	}
	return self;
}

- (id)result {
	return result;
}

- (void)dealloc {
	while(top != NULL) {
		top = pop(top);
	}
	[result release];
	[super dealloc];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	struct POXElement *element = push_new(top);
	switch(top->elementType) {
		case kPOXElementArray:
		case kPOXElementProperty:
		case kPOXElementRoot: {
			if([elementName hasPrefix:@"ArrayOf"]) {
				element->object = [[NSMutableArray alloc] init];
				element->elementType = kPOXElementArray;
			} else {
				Class elementClass;
				if(elementClass = [primitives() objectForKey:elementName]) {
					element->object = [[elementClass alloc] init];
					element->elementType = kPOXElementPrimitive;
				} else if(elementClass = objc_lookUpClass([elementName cStringUsingEncoding:NSASCIIStringEncoding])) {
					element->object = [[elementClass alloc] init];
					element->elementType = kPOXElementObject;
				} else {
					skip(element);
				}
			}
			break;
		}
		case kPOXElementObject: {
			id obj = top->object;
			Class propClass = [[obj class] propertyClass:elementName];
			if(propClass) {
				element->object = [elementName retain];
				element->elementType = kPOXElementProperty;
			} else {
				skip(element);
			}
			break;
		}
		case kPOXElementSkip:
			skip(element);
			break;
		default: {
			LOG2(@"Unexpected element: %@", elementName);
			break;
		}
	}
	top = element;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if(top->elementType == kPOXElementPrimitive) {
		POXPrimitiveHolder *holder = top->object;
		holder.value = string;
	} else if(top->elementType == kPOXElementProperty) {
		top = push_new(top);
		top->object = [[POXPrimitiveHolder alloc] initWithvalue:string];
		top->elementType = kPOXElementPrimitive;
	} else {
		LOG2(@"Unexpected text: %@", string);
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if(result != nil) {
		LOG2(@"Result already created but '%@' element still not processed.", elementName);
	} else {
		if(match(top, 1, kPOXElementSkip)) {
			
			top = pop(top);
			
		} else if(match(top, 3, kPOXElementPrimitive | kPOXElementArray | kPOXElementObject, kPOXElementProperty, kPOXElementObject)) {
			
			id object = top->prev->prev->object;
			NSString *propertyName = (NSString*)top->prev->object;
			Class propClass = [[object class] propertyClass:propertyName];
			if(top->elementType == kPOXElementPrimitive) {
				[object setValue:[propClass objFromString:[top->object value]] forKey:propertyName];
				top = pop(top); //this compensates element created in foundCharacters method
			} else {
				[object setValue:top->object forKey:propertyName];
			}
			
			top = pop(top);
			
		} else if(match(top, 2, kPOXElementProperty, kPOXElementObject) ) {
			
			top = pop(top);
		
		} else if(match(top, 2, kPOXElementObject | kPOXElementPrimitive, kPOXElementArray) ) {
			
			NSMutableArray *array = top->prev->object;
			if(top->elementType == kPOXElementPrimitive) {
				[array addObject:[top->object realValue]];
			} else {
				[array addObject:top->object];
			}
			
			top = pop(top);
		
		} else if(match(top, 2, kPOXElementObject | kPOXElementArray | kPOXElementPrimitive, kPOXElementRoot)) {
			
			if(top->elementType == kPOXElementPrimitive) {
				result = [[top->object realValue] retain];
			} else {
				result = [top->object retain];	
			}
			top = pop(top);
		} else {
			//write detailed warning
		}
	}
}

@end


