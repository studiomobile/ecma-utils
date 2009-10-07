#import "NSString+Localisation.h"

@implementation NSString (Localisation)

static NSObject<LocalisationManager> *__string_localization_manager = nil;


+ (NSObject<LocalisationManager>*)localisationManager {
    return [[__string_localization_manager retain] autorelease];
}


+ (void)setLocalisationManager:(NSObject<LocalisationManager>*)localisationManager {
    @synchronized(__string_localization_manager) {
        [__string_localization_manager autorelease];
        __string_localization_manager = [localisationManager retain];
    }
}


- (NSString*)localize {
    NSObject<LocalisationManager> *manager = [self.class localisationManager];
    if (!manager) return self;
    NSString *localized = [manager localizeString:self];
    return localized ? localized : self;
}


@end
