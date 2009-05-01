#import "XMLWriter.h"

@interface NSString (XMLAdditions)

- (NSString*)xmlEscapedString;

@end


@implementation NSString (XMLAdditions)

- (NSString*)xmlEscapedString {
    // TODO refactor, this is too slow & ugly
    NSMutableString *result = [[self mutableCopy] autorelease];
    [result replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"<" withString:@"&lt;" options:0 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@">" withString:@"&gt;" options:0 range:NSMakeRange(0, result.length)];
    return [[result copy] autorelease];
}

@end


@implementation XMLWriter

- (id)initWithIndentation:(NSString*)indent lineBreak:(NSString*)br {
    if(self = [super init]) {
        indentation = [indent retain];
        lineBreak = [br retain];
        
        resultMutable = [[NSMutableString alloc] init];
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
        [self closeTag];
    }

    return [NSString stringWithString:resultMutable];
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
    
    [resultMutable appendFormat:@"%@%@%@", indent, str, lineBreak];
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


- (void)tag:(NSString*)name content:(NSString*)content attributes:(NSDictionary*)attributes escape:(BOOL)escape {
    if(!name) return;
    NSString *attributesString = [self attributesString:attributes];
    
    if(content && content.length > 0) {
        if(escape) {
            content = [content xmlEscapedString];
        }
        
        [self appendIndented:[NSString stringWithFormat:@"<%@%@>%@</%@>", name, attributesString, content, name]];
    } else {
        [self appendIndented:[NSString stringWithFormat:@"<%@%@/>", name, attributesString]];
    }
}


- (void)tag:(NSString*)name content:(NSString*)content attributes:(NSDictionary*)attributes {
    [self tag:name content:content attributes:attributes escape:YES];
}


- (void)tag:(NSString*)name content:(NSString*)content {
    [self tag:name content:content attributes:nil];
}


- (void)tag:(NSString*)name cdata:(NSString*)content attributes:(NSDictionary*)attributes {
    [self tag:name content:[NSString stringWithFormat:@"<![CDATA[%@]]>", content] attributes:attributes escape:NO];
}


- (void)tag:(NSString*)name cdata:(NSString*)content {
    [self tag:name cdata:content attributes:nil];
}


- (void)openTag:(NSString*)name attributes:(NSDictionary*)attributes {
    if(!name) return;
    
    [self appendIndented:[NSString stringWithFormat:@"<%@%@>", name, [self attributesString:attributes]]];
    [tagStack addObject:name];
}


- (void)openTag:(NSString*)name {
    [self openTag:name attributes:nil];
}


- (void)closeTag {
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
    [resultMutable release];
    [tagStack release];
    [indentsCache release];
    
    [super dealloc];
}
@end
