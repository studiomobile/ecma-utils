#import <Foundation/Foundation.h>

@interface Callback : NSObject {
    id handler;
	BOOL isHandlerRetained;
    SEL selector;
	NSMutableDictionary* boundArguments;
}
@property(assign) id delegate;
@property(retain) id observer;
@property(assign) SEL selector;

-(id) initWithHandler: (id)_handler retained: (BOOL)_isHandlerRetained selector: (SEL)_selector;
+(Callback*) callbackWithDelegate: delegate selector: (SEL)selector;
+(Callback*) callbackWithObserver: observer selector: (SEL)selector;

-(void)call;
-(void)callWith: arg;
-(void)callWith: arg1 with: arg2;
-(void)callWith: arg1 with: arg2 with: arg3;
-(void)callWithArguments: (NSArray*)args;

-(void)bind0: value;
-(void)bind1: value;
-(void)bind2: value;
-(void)bindArgument: (int)number with: (id)value;

@end
