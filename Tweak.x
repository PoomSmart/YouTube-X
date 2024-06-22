#import <YouTubeHeader/ASCollectionElement.h>
#import <YouTubeHeader/ELMCellNode.h>
#import <YouTubeHeader/ELMNodeController.h>
#import <YouTubeHeader/YTIElementRenderer.h>
#import <YouTubeHeader/YTISectionListRenderer.h>
#import <YouTubeHeader/YTReelModel.h>
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

%hook YTReelInfinitePlaybackDataSource

- (void)setReels:(NSMutableOrderedSet <YTReelModel *> *)reels {
    [reels removeObjectsAtIndexes:[reels indexesOfObjectsPassingTest:^BOOL(YTReelModel *obj, NSUInteger idx, BOOL *stop) {
        return [obj respondsToSelector:@selector(videoType)] ? obj.videoType == 3 : NO;
    }]];
    %orig;
}

%end

BOOL isAdString(NSString *description) {
    if ([description containsString:@"brand_promo"]
        || [description containsString:@"carousel_footered_layout"]
        || [description containsString:@"carousel_headered_layout"]
        || [description containsString:@"feed_ad_metadata"]
        || [description containsString:@"full_width_portrait_image_layout"]
        || [description containsString:@"full_width_square_image_layout"]
        || [description containsString:@"home_video_with_context"]
        || [description containsString:@"landscape_image_wide_button_layout"]
        || [description containsString:@"post_shelf"]
        || [description containsString:@"product_carousel"]
        || [description containsString:@"product_engagement_panel"]
        || [description containsString:@"product_item"]
        || [description containsString:@"shelf_header"]
        || [description containsString:@"statement_banner"]
        || [description containsString:@"square_image_layout"] // install app ad
        || [description containsString:@"text_image_button_layout"]
        || [description containsString:@"text_search_ad"]
        || [description containsString:@"video_display_full_layout"]
        || [description containsString:@"video_display_full_buttoned_layout"])
        return YES;
    return NO;
}

#define cellDividerDataBytesLength 720
static __strong NSData *cellDividerData;
static uint8_t cellDividerDataBytes[] = {
    0xa, 0x8d, 0x5, 0xca, 0xeb, 0xea, 0x83, 0x5, 0x86, 0x5,
    0x1a, 0x29, 0x92, 0xcb, 0xa1, 0x90, 0x5, 0x23, 0xa, 0x21,
    0x63, 0x65, 0x6c, 0x6c, 0x5f, 0x64, 0x69, 0x76, 0x69, 0x64,
    0x65, 0x72, 0x2e, 0x65, 0x6d, 0x6c, 0x7c, 0x39, 0x33, 0x62,
    0x65, 0x63, 0x30, 0x39, 0x37, 0x37, 0x63, 0x66, 0x64, 0x33,
    0x61, 0x31, 0x37, 0x2a, 0xef, 0x3, 0xea, 0x84, 0xef, 0xab,
    0xa, 0xe8, 0x3, 0x8, 0x3, 0x12, 0x0, 0x2d, 0x0, 0x0,
    0x0, 0x41, 0x32, 0xdc, 0x3, 0xfa, 0x3e, 0x4, 0x8, 0x5,
    0x10, 0x1, 0x92, 0x3f, 0x4, 0xa, 0x2, 0x8, 0x1, 0xc2,
    0xb8, 0x89, 0xbe, 0xa, 0x86, 0x1, 0xa, 0x81, 0x1, 0x38,
    0x1, 0x40, 0x1, 0x50, 0x1, 0x58, 0x1, 0x60, 0x5, 0x78,
    0x1, 0x80, 0x1, 0x1, 0x90, 0x1, 0x1, 0x98, 0x1, 0x1,
    0xa0, 0x1, 0x1, 0xa8, 0x1, 0x1, 0xe0, 0x1, 0x1, 0x88,
    0x2, 0x1, 0xa0, 0x2, 0x1, 0xd0, 0x2, 0x1, 0x98, 0x3,
    0x1, 0xa0, 0x3, 0x1, 0xb0, 0x3, 0x1, 0xd0, 0x3, 0x1,
    0xd8, 0x3, 0x1, 0xe8, 0x3, 0x1, 0xf0, 0x3, 0x1, 0x98,
    0x4, 0x1, 0xd0, 0x4, 0x1, 0xe8, 0x4, 0x1, 0xf0, 0x4,
    0x1, 0xf8, 0x4, 0x1, 0xd8, 0x5, 0x1, 0xe5, 0x5, 0xcd,
    0xcc, 0x4c, 0x3f, 0xed, 0x5, 0xcd, 0xcc, 0x4c, 0x3f, 0xf5,
};

%hook YTIElementRenderer

- (NSData *)elementData {
    // NSString *description = [self description];
    if ([self respondsToSelector:@selector(hasCompatibilityOptions)] && self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData && cellDividerData) return cellDividerData;
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
            return isAdString(description);
        }];
        [contentsArray removeObjectsAtIndexes:removeIndexes];
    }
    %orig;
}

%end

%ctor {
    cellDividerData = [NSData dataWithBytes:cellDividerDataBytes length:cellDividerDataBytesLength];
    %init;
}
