#import <Foundation/Foundation.h>

@protocol LocalisationManager
- (NSString*)localizeString:(NSString*)string;
@end


@interface NSString (Localisation)

+ (NSObject<LocalisationManager>*)localisationManager;
+ (void)setLocalisationManager:(NSObject<LocalisationManager>*)localisationManager;

- (NSString*)localize;

@end
