#import "../YouTubeHeader/YTIElementRenderer.h"

%hook YTIPlayerResponse

- (BOOL)isMonetized { return NO; }

%end

%hook YTIPlayabilityStatus

- (BOOL)isPlayableInBackground { return YES; }

%end

%hook MLVideo

- (BOOL)playableInBackground { return YES; }

%end

%hook YTDataUtils

+ (id)spamSignalsDictionary { return nil; }

%end

%hook YTAdsInnerTubeContextDecorator

- (void)decorateContext:(id)context {}

%end

BOOL didLateHook = NO;

%group LateHook

%hook YTIElementRenderer

- (NSData *)elementData {
    if (self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData)
        return nil;
    return %orig;
}

%end

%end

%hook YTSectionListViewController

- (void)loadWithModel:(id)model {
    if (!didLateHook) {
        %init(LateHook);
        didLateHook = YES;
    }
    %orig;
}

%end

%ctor {
    %init;
}