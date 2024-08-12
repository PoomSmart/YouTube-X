#import <YouTubeHeader/YTIElementRenderer.h>
#import <YouTubeHeader/YTInnerTubeCollectionViewController.h>
#import <YouTubeHeader/YTISectionListRenderer.h>
#import <YouTubeHeader/YTReelModel.h>
#import <HBLog.h>

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

%hook YTAdShieldUtils

+ (id)spamSignalsDictionary { return @{}; }
+ (id)spamSignalsDictionaryWithoutIDFA { return @{}; }

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

%hook YTLocalPlaybackController

- (id)createAdsPlaybackCoordinator { return nil; }

%end

%hook MDXSession

- (void)adPlaying:(id)ad {}

%end

%hook YTReelInfinitePlaybackDataSource

- (void)setReels:(NSMutableOrderedSet <YTReelModel *> *)reels {
    [reels removeObjectsAtIndexes:[reels indexesOfObjectsPassingTest:^BOOL(YTReelModel *obj, NSUInteger idx, BOOL *stop) {
        return [obj respondsToSelector:@selector(videoType)] ? obj.videoType == 3 : NO;
    }]];
    %orig;
}

%end

NSString *getAdString(NSString *description) {
    if ([description containsString:@"brand_promo"])
        return @"brand_promo";
    if ([description containsString:@"carousel_footered_layout"])
        return @"carousel_footered_layout";
    if ([description containsString:@"carousel_headered_layout"])
        return @"carousel_headered_layout";
    if ([description containsString:@"feed_ad_metadata"])
        return @"feed_ad_metadata";
    if ([description containsString:@"full_width_portrait_image_layout"])
        return @"full_width_portrait_image_layout";
    if ([description containsString:@"full_width_square_image_layout"])
        return @"full_width_square_image_layout";
    if ([description containsString:@"landscape_image_wide_button_layout"])
        return @"landscape_image_wide_button_layout";
    if ([description containsString:@"post_shelf"])
        return @"post_shelf";
    if ([description containsString:@"product_carousel"])
        return @"product_carousel";
    if ([description containsString:@"product_engagement_panel"])
        return @"product_engagement_panel";
    if ([description containsString:@"product_item"])
        return @"product_item";
    if ([description containsString:@"shopping_carousel"])
        return @"shopping_carousel";
    if ([description containsString:@"statement_banner"])
        return @"statement_banner";
    if ([description containsString:@"square_image_layout"])
        return @"square_image_layout";
    if ([description containsString:@"text_image_button_layout"])
        return @"text_image_button_layout";
    if ([description containsString:@"text_search_ad"])
        return @"text_search_ad";
    if ([description containsString:@"video_display_full_layout"])
        return @"video_display_full_layout";
    if ([description containsString:@"video_display_full_buttoned_layout"])
        return @"video_display_full_buttoned_layout";
    return nil;
}

static BOOL isAdRenderer(YTIElementRenderer *elementRenderer, int kind) {
    if ([elementRenderer respondsToSelector:@selector(hasCompatibilityOptions)] && elementRenderer.hasCompatibilityOptions && elementRenderer.compatibilityOptions.hasAdLoggingData) {
        HBLogDebug(@"YTX adLogging %d %@", kind, elementRenderer);
        return YES;
    }
    NSString *description = [elementRenderer description];
    NSString *adString = getAdString(description);
    if (adString) {
        HBLogDebug(@"YTX getAdString %d %@ %@", kind, adString, elementRenderer);
        return YES;
    }
    return NO;
}

static NSMutableArray <YTIItemSectionRenderer *> *filteredArray(NSArray <YTIItemSectionRenderer *> *array) {
    NSMutableArray <YTIItemSectionRenderer *> *newArray = [array mutableCopy];
    NSIndexSet *removeIndexes = [newArray indexesOfObjectsPassingTest:^BOOL(YTIItemSectionRenderer *sectionRenderer, NSUInteger idx, BOOL *stop) {
        if (![sectionRenderer isKindOfClass:%c(YTIItemSectionRenderer)])
            return NO;
        NSMutableArray <YTIItemSectionSupportedRenderers *> *contentsArray = sectionRenderer.contentsArray;
        if (contentsArray.count > 1) {
            NSIndexSet *removeContentsArrayIndexes = [contentsArray indexesOfObjectsPassingTest:^BOOL(YTIItemSectionSupportedRenderers *sectionSupportedRenderers, NSUInteger idx2, BOOL *stop2) {
                YTIElementRenderer *elementRenderer = sectionSupportedRenderers.elementRenderer;
                return isAdRenderer(elementRenderer, 3);
            }];
            [contentsArray removeObjectsAtIndexes:removeContentsArrayIndexes];
        }
        YTIItemSectionSupportedRenderers *firstObject = [contentsArray firstObject];
        YTIElementRenderer *elementRenderer = firstObject.elementRenderer;
        return isAdRenderer(elementRenderer, 2);
    }];
    [newArray removeObjectsAtIndexes:removeIndexes];
    return newArray;
}

%hook YTInnerTubeCollectionViewController

- (void)displaySectionsWithReloadingSectionControllerByRenderer:(id)renderer {
    NSMutableArray *sectionRenderers = [self valueForKey:@"_sectionRenderers"];
    [self setValue:filteredArray(sectionRenderers) forKey:@"_sectionRenderers"];
    %orig;
}

- (void)addSectionsFromArray:(NSArray <YTIItemSectionRenderer *> *)array {
    %orig(filteredArray(array));
}

%end
