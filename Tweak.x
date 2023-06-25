#import "../YouTubeHeader/_ASCollectionViewCell.h"
#import "../YouTubeHeader/YTAsyncCollectionView.h"
#import "../YouTubeHeader/ELMCellNode.h"
#import "../YouTubeHeader/ELMNodeController.h"

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

BOOL isAd(ELMCellNode *node) {
    ELMNodeController *controller = [node controller];
    NSString *description = [controller description];
    if ([description containsString:@"brand_promo"]
        || [description containsString:@"statement_banner"]
        || [description containsString:@"product_carousel"]
        || [description containsString:@"product_engagement_panel"]
        || [description containsString:@"product_item"]
        || [description containsString:@"text_search_ad"]
        || [description containsString:@"feed_ad_metadata"])
        return YES;
    return NO;
}

%hook YTAsyncCollectionView

- (id)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _ASCollectionViewCell *cell = %orig;
    if ([cell isKindOfClass:NSClassFromString(@"_ASCollectionViewCell")]
        && [cell respondsToSelector:@selector(node)]
        && [cell isKindOfClass:NSClassFromString(@"ELMCellNode")]
        && isAd((ELMCellNode *)[cell node]))
            [self deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    return cell;
}

%end
