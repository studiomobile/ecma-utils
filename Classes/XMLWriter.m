#import "XMLWriter.h"

@implementation XMLWriter

+ (NSString*)cdata:(NSString*)content {
    return [NSString stringWithFormat:@"<![CDATA[%@]]>", content];
}

- (id)initWithIndentation:(NSString*)indent lineBreak:(NSString*)br {
    if(self = [super init]) {
        indentation = [indent retain];
        lineBreak = [br retain];
        
        result = [[NSMutableString alloc] init];
        tagStack = [[NSMutableArray alloc] init];
        indentationLevel = 0;
        indentsCache = [[NSMutableArray alloc] initWithObjects:@"", nil];
    }
    
    return self;
}

- (id)init {
    return [self initWithIndentation:@"" lineBreak:@""];
}

- (NSString*)result {
    while(tagStack.count) { // unwind 
        [self pop];
    }

    return [NSString stringWithString:result];
}

- (void)appendIndented:(NSString*)str {
    NSInteger level = tagStack.count;
    if(indentsCache.count < level + 1) {
        for(int i = indentsCache.count; i < level + 1; i++) {
            NSString *previous = i > 0 ? [indentsCache objectAtIndex:i-1] : @"";
            [indentsCache insertObject:[NSString stringWithFormat:@"%@%@", previous, indentation] atIndex:i];
        }
    }
    
    NSString *indent = [indentsCache objectAtIndex:level];
    
    [result appendFormat:@"%@%@%@", indent, str, lineBreak];
}

- (void)instruct {
    [self appendIndented:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
}

- (NSString*)attributesString:(NSDictionary*)attributes {
    if(!attributes) return @"";
    
    NSMutableString *attributesString = [NSMutableString string];
    
    for(NSObject *key in [attributes allKeys]) {
        [attributesString appendFormat:@" %@=\"%@\"", key, [attributes objectForKey:key]];
    }
    
    return attributesString;
}

- (void)tag:(NSString*)name content:(NSString*)content attributes:(NSDictionary*)attributes {
    if(!name) return;
    NSString *attributesString = [self attributesString:attributes];
    
    if(content && content.length > 0) {
        [self appendIndented:[NSString stringWithFormat:@"<%@%@>%@</%@>", name, attributesString, content, name]];
    } else {
        [self appendIndented:[NSString stringWithFormat:@"<%@%@/>", name, attributesString]];
    }
}

- (void)tag:(NSString*)name content:(NSString*)content {
    [self tag:name content:content attributes:nil];
}

- (void)push:(NSString*)name attributes:(NSDictionary*)attributes {
    if(!name) return;
    
    [self appendIndented:[NSString stringWithFormat:@"<%@%@>", name, [self attributesString:attributes]]];
    [tagStack addObject:name];
}

- (void)push:(NSString*)name {
    [self push:name attributes:nil];
}

- (void)pop {
    if(!tagStack.count) return;
    
    NSString *name = [tagStack objectAtIndex:tagStack.count - 1];
    [tagStack removeLastObject];
    [self appendIndented:[NSString stringWithFormat:@"</%@>", name]];
}

- (void)comment:(NSString*)comment {
    [self appendIndented:[NSString stringWithFormat:@"<!-- %@ -->", comment]];
}

- (void)dealloc {
    [lineBreak release];
    [indentation release];
    [result release];
    [tagStack release];
    [indentsCache release];
    
    [super dealloc];
}
@end
