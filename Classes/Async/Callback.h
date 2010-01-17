@interface Callback : NSObject {
    id handler;
	BOOL isHandlerRetained;
    SEL selector;	
}
@property(assign) id delegate;
@property(retain) id observer;
@property(assign) SEL selector;

+(Callback*) callbackWithDelegate: delegate selector: (SEL)selector;
+(Callback*) callbackWithObserver: observer selector: (SEL)selector;


-(void)call;
-(void)callWith: arg;
-(void)callWith: arg1 with: arg2;
-(void)callWithArguments: (NSArray*)args;

@end
