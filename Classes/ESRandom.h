#import <Foundation/Foundation.h>

@interface ESRandom : NSObject {

}

+(double)random; // uniform [0:1]
+(int) from:(int)from to:(int)to;
+(int) to:(int)to;
+(BOOL) isOccured:(double)probability; 

@end
