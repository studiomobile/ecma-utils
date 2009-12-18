@protocol SoapEntityProto<NSObject>

+(NSString*) soapNamespace;
+(NSString*) soapName;

@optional

+(Class)typeForKey: (NSString*)key;
+(BOOL)isManyForKey: (NSString*)key;
-(id) soapClass;

@end
