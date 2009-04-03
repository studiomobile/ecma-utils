#define ENCODEOBJECT(obj) [coder encodeObject:obj forKey:@#obj]
#define ENCODEOBJECTWITHCODER(obj, coder) [coder encodeObject:obj forKey:@#obj]

#define DECODEOBJECT(obj) obj = [[decoder decodeObjectForKey:@#obj] retain]
#define DECODEOBJECTWITHCODER(obj, decoder) obj = [[decoder decodeObjectForKey:@#obj] retain]

#define DECODEMUTABLEARRAYWITHDECODER(obj, deocder)   \
do {                                                  \
  NSArray *tmp =  [decoder decodeObjectForKey:@#obj]; \
  obj = [[NSMutableArray alloc] initWithArray:tmp];   \
} while(FALSE);                                       \
 
#define DECODEMUTABLEARRAY(obj) DECODEMUTABLEARRAYWITHDECODER(obj, decoder)

#define ENCODEINT(i) [coder encodeInt:i forKey:@#i]
#define ENCODEINTWITHCODER(i, coder) [coder encodeInt:i forKey:@#i]

#define DECODEINT(i) i = [decoder decodeIntForKey:@#i]
#define DECODEINTWITHCODER(i, decoder) i = [decoder decodeIntForKey:@#i]

#define ENCODEBOOL(i) [coder encodeBool:i forKey:@#i]
#define ENCODEBOOLWITHCODER(i, coder) [coder encodeBool:i forKey:@#i]

#define DECODEBOOL(i) i = [decoder decodeBoolForKey:@#i]
#define DECODEBOOLWITHCODER(i, decoder) i = [decoder decodeBoolForKey:@#i]

#define ENCODEFLOAT(i) [coder encodeFloat:i forKey:@#i]
#define ENCODEFLOATWITHCODER(i, coder) [coder encodeFloat:i forKey:@#i]

#define DECODEFLOAT(i) i = [decoder decodeFloatForKey:@#i]
#define DECODEFLOATWITHCODER(i, decoder) i = [decoder decodeFloatForKey:@#i]
