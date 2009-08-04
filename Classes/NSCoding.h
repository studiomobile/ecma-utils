// Object
#define ENCODEOBJECTWITHCODER(obj, coder) [coder encodeObject:obj forKey:@#obj]
#define ENCODEOBJECT(obj) ENCODEOBJECTWITHCODER(obj, coder)

#define DECODEOBJECTWITHCODER(obj, decoder) obj = [[decoder decodeObjectForKey:@#obj] retain]
#define DECODEOBJECT(obj) DECODEOBJECTWITHCODER(obj, decoder)

// NSMutableArray
#define DECODEMUTABLEARRAYWITHDECODER(obj, decoder) obj = [[NSMutableArray alloc] initWithArray:[decoder decodeObjectForKey:@#obj]]
#define DECODEMUTABLEARRAY(obj) DECODEMUTABLEARRAYWITHDECODER(obj, decoder)

// int
#define ENCODEINTWITHCODER(i, coder) [coder encodeInt:i forKey:@#i]
#define ENCODEINT(i) ENCODEINTWITHCODER(i, coder)

#define DECODEINTWITHCODER(i, decoder) i = [decoder decodeIntForKey:@#i]
#define DECODEINT(i) DECODEINTWITHCODER(i, decoder)

// BOOL
#define ENCODEBOOLWITHCODER(b, coder) [coder encodeBool:b forKey:@#b]
#define ENCODEBOOL(b) ENCODEBOOLWITHCODER(b, coder)

#define DECODEBOOLWITHCODER(b, decoder) b = [decoder decodeBoolForKey:@#b]
#define DECODEBOOL(b) DECODEBOOLWITHCODER(b, decoder)

// float
#define ENCODEFLOATWITHCODER(f, coder) [coder encodeFloat:f forKey:@#f]
#define ENCODEFLOAT(f) ENCODEFLOATWITHCODER(f, coder)

#define DECODEFLOATWITHCODER(f, decoder) f = [decoder decodeFloatForKey:@#f]
#define DECODEFLOAT(f) DECODEFLOATWITHCODER(f, decoder)

// double
#define ENCODEDOUBLEWITHCODER(d, coder) [coder encodeDouble:d forKey:@#d]
#define ENCODEDOUBLE(d) ENCODEDOUBLEWITHCODER(d, coder)

#define DECODEDOUBLEWITHCODER(d, decoder) d = [decoder decodeDoubleForKey:@#d]
#define DECODEDOUBLE(d) DECODEDOUBLEWITHCODER(d, decoder)
