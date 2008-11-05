#import <Foundation/Foundation.h>

@interface POXPrimitiveHolder : NSObject {
	NSString *value;
}

@property (nonatomic, retain, readwrite) NSString *value;
- (id)initWithvalue:(NSString*)val;
- (id)realValue;
@end

@interface POXNumberHolder : POXPrimitiveHolder
@end


@interface NSNumber(PrimitiveMapping)
+ (id)objFromString:(NSString*)str;
@end

@interface NSString(PrimitiveMapping)
+ (id)objFromString:(NSString*)str;
@end
