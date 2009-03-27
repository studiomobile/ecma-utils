@protocol SoapEntityProto

@property(readonly) NSString* soapNamespace;

-(Class)typeForKey: (NSString*)key;

@end
