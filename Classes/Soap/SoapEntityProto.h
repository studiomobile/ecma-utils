@protocol SoapEntityProto

+(NSString*) soapNamespace;

@optional

+(NSString*) soapName;
+(Class)typeForKey: (NSString*)key;
+(BOOL)isManyForKey: (NSString*)key;

@end
