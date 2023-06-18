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
+ (id)spamSignalsDictionaryWithoutIDFA { return nil; }

%end

%hook YTAdsInnerTubeContextDecorator

- (void)decorateContext:(id)context {}

%end

%hook YTAccountScopedAdsInnerTubeContextDecorator

- (void)decorateContext:(id)context {}

%end

BOOL isAd(YTIElementRenderer *self) {
    if (self == nil) return NO;
    if (self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData) return YES;
    NSString *description = [self description];
    if ([description containsString:@"brand_promo"]
        || [description containsString:@"statement_banner"]
        || [description containsString:@"product_carousel"]
        || [description containsString:@"product_engagement_panel"]
        || [description containsString:@"product_item"])
        return YES;
    return NO;
}

%hook YTSectionListViewController

- (void)loadWithModel:(YTISectionListRenderer *)model {
    NSMutableArray <YTISectionListSupportedRenderers *> *contentsArray = model.contentsArray;
    NSIndexSet *removeIndexes = [contentsArray indexesOfObjectsPassingTest:^BOOL(YTISectionListSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
        YTIItemSectionRenderer *sectionRenderer = renderers.itemSectionRenderer;
        YTIItemSectionSupportedRenderers *firstObject = [sectionRenderer.contentsArray firstObject];
        return firstObject.hasPromotedVideoRenderer || firstObject.hasCompactPromotedVideoRenderer || firstObject.hasPromotedVideoInlineMutedRenderer || isAd(firstObject.elementRenderer);
    }];
    [contentsArray removeObjectsAtIndexes:removeIndexes];
    %orig;
}

%end
