#import <Foundation/Foundation.h>

@protocol AsyncCallbackProtocol<NSObject>

@optional
-(void)asyncOperationStarted;
-(void)asyncOperationCanceled;
-(void)asyncOperationFinishedWithResult:	(id)result;
-(void)asyncOperationFinishedWithError:		(NSError*)error;

@end