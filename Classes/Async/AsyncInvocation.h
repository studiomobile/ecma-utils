
@protocol AsyncInvocation
	-(void)cancel;
@end

@interface AsyncInvocationImpl : NSObject<AsyncInvocation>{
	NSOperation* op;
}

+(AsyncInvocationImpl*)asyncInvocationWithOperation: (NSOperation*)op;

@end
