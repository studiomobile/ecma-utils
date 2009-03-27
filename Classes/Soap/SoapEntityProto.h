@protocol SoapEntityProto

@property(readonly) NSString* soapNamespace;

-(Class)typeForKey: (NSString*)key;

@optional

@property(readonly) NSString* soapName;

@end
