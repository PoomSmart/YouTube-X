#import "../YouTubeHeader/YTISectionListRenderer.h"

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

%hook YTSectionListViewController

- (void)loadWithModel:(YTISectionListRenderer *)model {
    NSMutableArray <YTISectionListSupportedRenderers *> *contentsArray = model.contentsArray;
    NSIndexSet *removeIndexes = [contentsArray indexesOfObjectsPassingTest:^BOOL(YTISectionListSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
        YTIItemSectionRenderer *sectionRenderer = renderers.itemSectionRenderer;
        YTIItemSectionSupportedRenderers *firstObject = [sectionRenderer.contentsArray firstObject];
        YTIElementRenderer *objectRenderer = firstObject.elementRenderer;
        // BOOL isShorts = [[objectRenderer description] containsString:@"shorts_shelf"];
        BOOL isSearchAd = objectRenderer.hasCompatibilityOptions && objectRenderer.compatibilityOptions.hasAdLoggingData;
        BOOL isPromotedVideo = firstObject.hasPromotedVideoRenderer || firstObject.hasCompactPromotedVideoRenderer || firstObject.hasPromotedVideoInlineMutedRenderer;
        BOOL isValid = isSearchAd || isPromotedVideo;
        return isValid;
    }];
    [contentsArray removeObjectsAtIndexes:removeIndexes];
    %orig;
}

%end