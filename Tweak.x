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

BOOL didLateHook = NO;

%group LateHook

%hook YTIElementRenderer

- (NSData *)elementData {
    if (self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData)
        return nil;
    // NSString *description = [self description];
    // if ([description containsString:@"product_carousel.eml"] || [description containsString:@"product_engagement_panel.eml"] || [description containsString:@"product_item.eml"])
    //     return [NSData data];
    return %orig;
}

%end

%end

%hook YTSectionListViewController

- (void)loadWithModel:(YTISectionListRenderer *)model {
    if (!didLateHook) {
        %init(LateHook);
        didLateHook = YES;
    }
    NSMutableArray <YTISectionListSupportedRenderers *> *contentsArray = model.contentsArray;
    NSIndexSet *removeIndexes = [contentsArray indexesOfObjectsPassingTest:^BOOL(YTISectionListSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
        YTIItemSectionRenderer *sectionRenderer = renderers.itemSectionRenderer;
        YTIItemSectionSupportedRenderers *firstObject = [sectionRenderer.contentsArray firstObject];
        return firstObject.hasPromotedVideoRenderer || firstObject.hasCompactPromotedVideoRenderer || firstObject.hasPromotedVideoInlineMutedRenderer;
    }];
    [contentsArray removeObjectsAtIndexes:removeIndexes];
    %orig;
}

%end

%ctor {
    %init;
}