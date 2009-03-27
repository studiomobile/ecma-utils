@protocol SoapEntityProto

-(NSString*) soapNamespace;
-(Class)typeForKey: (NSString*)key;

@optional

-(NSString*) soapName;

@end
