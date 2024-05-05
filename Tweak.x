#import <YouTubeHeader/ASCollectionElement.h>
#import <YouTubeHeader/ELMCellNode.h>
#import <YouTubeHeader/ELMNodeController.h>
#import <YouTubeHeader/YTIElementRenderer.h>
#import <YouTubeHeader/YTISectionListRenderer.h>
#import <YouTubeHeader/YTVideoWithContextNode.h>

%hook YTVersionUtils

// Works down to 16.29.4
+ (NSString *)appVersion {
    NSString *appVersion = %orig;
    if ([appVersion compare:@"17.33.2" options:NSNumericSearch] == NSOrderedAscending)
        return @"17.33.2";
    return appVersion;
}

%end

%hook YTGlobalConfig

- (BOOL)shouldBlockUpgradeDialog { return YES; }

%end

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

+ (id)spamSignalsDictionary { return @{}; }
+ (id)spamSignalsDictionaryWithoutIDFA { return @{}; }

%end

%hook YTAdsInnerTubeContextDecorator

- (void)decorateContext:(id)context { %orig(nil); }

%end

%hook YTAccountScopedAdsInnerTubeContextDecorator

- (void)decorateContext:(id)context { %orig(nil); }

%end

BOOL isAdString(NSString *description) {
    if ([description containsString:@"brand_promo"]
        // || [description containsString:@"statement_banner"]
        // || [description containsString:@"product_carousel"]
        || [description containsString:@"shelf_header"]
        || [description containsString:@"product_engagement_panel"]
        || [description containsString:@"product_item"]
        || [description containsString:@"text_search_ad"]
        || [description containsString:@"text_image_button_layout"]
        || [description containsString:@"carousel_headered_layout"]
        || [description containsString:@"carousel_footered_layout"]
        || [description containsString:@"full_width_square_image_layout"]
        || [description containsString:@"full_width_portrait_image_layout"]
        || [description containsString:@"square_image_layout"] // install app ad
        || [description containsString:@"landscape_image_wide_button_layout"]
        || [description containsString:@"video_display_full_buttoned_layout"]
        || [description containsString:@"home_video_with_context"]
        || [description containsString:@"feed_ad_metadata"])
        return YES;
    return NO;
}

NSData *cellDividerData;

%hook YTIElementRenderer

- (NSData *)elementData {
    NSString *description = [self description];
    if ([description containsString:@"cell_divider"]) {
        if (!cellDividerData) cellDividerData = %orig;
        return cellDividerData;
    }
    if (self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData) return cellDividerData;
    // if (isAdString(description)) return cellDividerData;
    return %orig;
}

%end

%hook YTInnerTubeCollectionViewController

- (void)loadWithModel:(YTISectionListRenderer *)model {
    if ([model isKindOfClass:%c(YTISectionListRenderer)]) {
        NSMutableArray <YTISectionListSupportedRenderers *> *contentsArray = model.contentsArray;
        NSIndexSet *removeIndexes = [contentsArray indexesOfObjectsPassingTest:^BOOL(YTISectionListSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            if (![renderers isKindOfClass:%c(YTISectionListSupportedRenderers)])
                return NO;
            YTIItemSectionRenderer *sectionRenderer = renderers.itemSectionRenderer;
            YTIItemSectionSupportedRenderers *firstObject = [sectionRenderer.contentsArray firstObject];
            YTIElementRenderer *elementRenderer = firstObject.elementRenderer;
            NSString *description = [elementRenderer description];
            return isAdString(description)
                || [description containsString:@"product_carousel"]
                || [description containsString:@"post_shelf"]
                || [description containsString:@"statement_banner"];
        }];
        [contentsArray removeObjectsAtIndexes:removeIndexes];
    }
    %orig;
}

%end
