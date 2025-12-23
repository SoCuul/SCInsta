#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Utils.h"
#import "InstagramHeaders.h"

@implementation SCIUtils

// Colours
+ (UIColor *)SCIColour_Primary {
    return [UIColor colorWithRed:0/255.0 green:152/255.0 blue:254/255.0 alpha:1];
};

// Errors
+ (NSError *)errorWithDescription:(NSString *)errorDesc {
    return [self errorWithDescription:errorDesc code:1];
}
+ (NSError *)errorWithDescription:(NSString *)errorDesc code:(NSInteger)errorCode {
    NSError *error = [ NSError errorWithDomain:@"com.socuul.scinsta" code:errorCode userInfo:@{ NSLocalizedDescriptionKey: errorDesc } ];
    return error;
}

+ (JGProgressHUD *)showErrorHUDWithDescription:(NSString *)errorDesc {
    return [self showErrorHUDWithDescription:errorDesc dismissAfterDelay:4.0];
}
+ (JGProgressHUD *)showErrorHUDWithDescription:(NSString *)errorDesc dismissAfterDelay:(CGFloat)dismissDelay {
    JGProgressHUD *hud = [[JGProgressHUD alloc] init];
    hud.textLabel.text = errorDesc;
    hud.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];

    // Make HUD non-blocking so user can continue to interact
    hud.interactionType = JGProgressHUDInteractionTypeBlockNoTouches;
    
    [hud showInView:topMostController().view];
    [hud dismissAfterDelay:3.0]; // Reduced delay
    
    hud.tapOnHUDViewBlock = ^(JGProgressHUD * _Nonnull hud) {
        [hud dismiss];
    };

    return hud;
}

// Media
+ (NSURL *)getPhotoUrl:(IGPhoto *)photo {
    if (!photo) return nil;

    @try {
        // BHInstagram's method: access _originalImageVersions ivar
        // This contains an array of IGImageURL objects
        NSArray *originalImageVersions = [photo valueForKey:@"_originalImageVersions"];
        
        if (originalImageVersions && [originalImageVersions isKindOfClass:[NSArray class]] && originalImageVersions.count > 0) {
            // Iterate to find the highest resolution
            id bestImageVersion = nil;
            CGFloat maxPixels = 0;

            for (id version in originalImageVersions) {
                if ([version respondsToSelector:@selector(width)] && [version respondsToSelector:@selector(height)]) {
                    CGFloat w = [[version valueForKey:@"width"] floatValue];
                    CGFloat h = [[version valueForKey:@"height"] floatValue];
                    CGFloat pixels = w * h;
                    
                    if (pixels >= maxPixels) {
                        maxPixels = pixels;
                        bestImageVersion = version;
                    }
                }
            }
            
            // Fallback to first item if sort failed
            if (!bestImageVersion) {
                bestImageVersion = originalImageVersions[0];
            }

            // IGImageURL has a url property
            if ([bestImageVersion respondsToSelector:@selector(url)]) {
                NSURL *url = [bestImageVersion valueForKey:@"url"];
                if (url && [url isKindOfClass:[NSURL class]]) {
                    return url;
                }
            }
        }
        
        // Fallback: Try old method
        if ([photo respondsToSelector:@selector(imageURLForWidth:)]) {
            NSURL *photoUrl = [photo imageURLForWidth:100000.00];
            if (photoUrl) {
                NSLog(@"[SCInsta] Found photo URL via imageURLForWidth");
                return photoUrl;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"[SCInsta] Exception in getPhotoUrl: %@", exception);
    }

    NSLog(@"[SCInsta] Error: Could not extract photo URL.");
    return nil;
}
+ (NSURL *)getPhotoUrlForMedia:(IGMedia *)media {
    if (!media) return nil;

    IGPhoto *photo = media.photo;

    return [SCIUtils getPhotoUrl:photo];
}

+ (NSURL *)getVideoUrl:(IGVideo *)video {
    if (!video) return nil;
    
    // 1. Try BHInstagram Method (Ivar Access)
    @try {
        NSArray *videoVersionDictionaries = [video valueForKey:@"_videoVersionDictionaries"];
        if (videoVersionDictionaries && [videoVersionDictionaries isKindOfClass:[NSArray class]] && videoVersionDictionaries.count > 0) {
            id firstVersion = videoVersionDictionaries[0];
            if ([firstVersion isKindOfClass:[NSDictionary class]]) {
                id urlValue = ((NSDictionary *)firstVersion)[@"url"];
                if (urlValue && [urlValue isKindOfClass:[NSString class]]) {
                     return [NSURL URLWithString:(NSString *)urlValue];
                }
            }
        }
    } @catch (NSException *e) { /* Ignore */ }
    
    // 2. Try _allVideoURLs Ivar
    @try {
        NSSet *allVideoURLs = [video valueForKey:@"_allVideoURLs"];
        if (allVideoURLs && [allVideoURLs isKindOfClass:[NSSet class]]) {
            NSURL *url = [allVideoURLs anyObject];
            if (url) return url;
        }
    } @catch (NSException *e) { /* Ignore */ }
    
    // 3. Try known method names
    NSArray *methods = @[@"sortedVideoURLsBySize", @"videoVersions", @"videoURLs", @"versions", @"playbackURL"];
    for (NSString *method in methods) {
        @try {
            SEL selector = NSSelectorFromString(method);
            if ([video respondsToSelector:selector]) {
                // NSLog(@"[SCInsta] Trying method: %@", method);
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                id result = [video performSelector:selector];
                #pragma clang diagnostic pop
                
                if (result) {
                    // NSLog(@"[SCInsta] Method %@ returned: %@", method, result);
                    // Handle array result
                    if ([result isKindOfClass:[NSArray class]]) {
                         NSArray *arr = (NSArray *)result;
                         if (arr.count > 0) {
                             id first = arr[0];
                             // Check for dictionary with "url"
                             if ([first isKindOfClass:[NSDictionary class]]) {
                                 id url = first[@"url"];
                                 if ([url isKindOfClass:[NSString class]]) return [NSURL URLWithString:url];
                                 if ([url isKindOfClass:[NSURL class]]) return url;
                             }
                             // Check for object with "url" property
                             if ([first respondsToSelector:@selector(url)]) {
                                 id url = [first valueForKey:@"url"];
                                 if ([url isKindOfClass:[NSURL class]]) return url;
                                 if ([url isKindOfClass:[NSString class]]) return [NSURL URLWithString:url];
                             }
                             // Check if it IS a URL
                             if ([first isKindOfClass:[NSURL class]]) return first;
                         }
                    }
                    // Handle URL result
                    if ([result isKindOfClass:[NSURL class]]) return result;
                }
            }
        } @catch (NSException *e) { /* Ignore */ }
    }
    
    return nil;
}

// Helper method to extract URL from various result types
+ (NSURL *)extractURLFromVideoResult:(id)result {
    if (!result) return nil;
    
    // Case 1: Result is already an NSURL
    if ([result isKindOfClass:[NSURL class]]) {
        return result;
    }
    
    // Case 2: Result is a string URL
    if ([result isKindOfClass:[NSString class]]) {
        return [NSURL URLWithString:result];
    }
    
    // Case 3: Result is an array (like sortedVideoURLsBySize)
    if ([result isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)result;
        if (array.count < 1) return nil;
        
        // First element is usually highest quality
        id firstElement = array[0];
        
        // Could be a dictionary with "url" key
        if ([firstElement isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)firstElement;
            id urlValue = dict[@"url"];
            if ([urlValue isKindOfClass:[NSString class]]) {
                return [NSURL URLWithString:urlValue];
            }
            if ([urlValue isKindOfClass:[NSURL class]]) {
                return urlValue;
            }
        }
        
        // Could be a direct URL or string
        if ([firstElement isKindOfClass:[NSURL class]]) {
            return firstElement;
        }
        if ([firstElement isKindOfClass:[NSString class]]) {
            return [NSURL URLWithString:firstElement];
        }
        
        // Could be an object with "url" property
        if ([firstElement respondsToSelector:@selector(url)]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id urlResult = [firstElement performSelector:@selector(url)];
            #pragma clang diagnostic pop
            return [self extractURLFromVideoResult:urlResult];
        }
    }
    
    // Case 4: Result is a dictionary
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)result;
        id urlValue = dict[@"url"] ?: dict[@"playbackUrl"] ?: dict[@"videoUrl"];
        if (urlValue) {
            return [self extractURLFromVideoResult:urlValue];
        }
    }
    
    // Case 5: Result has a "url" property
    if ([result respondsToSelector:@selector(url)]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id urlResult = [result performSelector:@selector(url)];
        #pragma clang diagnostic pop
        return [self extractURLFromVideoResult:urlResult];
    }
    
    return nil;
}
+ (NSURL *)getVideoUrlForMedia:(IGMedia *)media {
    if (!media) return nil;

    IGVideo *video = media.video;
    if (!video) return nil;

    return [SCIUtils getVideoUrl:video];
}

// Search recursively for a player in subviews (Wrapper)
+ (NSURL *)getCachedVideoUrlForView:(UIView *)view {
    return [self getCachedVideoUrlForView:view depth:0];
}

// Recursive implementation with depth limit
+ (NSURL *)getCachedVideoUrlForView:(UIView *)view depth:(NSInteger)depth {
    if (!view || depth > 15) return nil; // Increased depth to 15 to find deep Story players
    
    // 1. Check for AVPlayerLayer directly
    if ([view.layer isKindOfClass:[AVPlayerLayer class]]) {
        AVPlayerLayer *playerLayer = (AVPlayerLayer *)view.layer;
        AVPlayer *player = playerLayer.player;
        if (player) {
            NSURL *url = [self getUrlFromPlayer:player];
            if (url) {
                // NSLog(@"[SCInsta] Found URL in AVPlayerLayer: %@", url);
                return url;
            }
        }
    }
    
    // 2. Check common property names for players or wrappers
    // Reduced search keys for performance
    NSArray *playerKeys = @[@"player", @"videoPlayer", @"avPlayer"];
    
    for (NSString *key in playerKeys) {
        if ([view respondsToSelector:NSSelectorFromString(key)]) {
            id playerObj = [view valueForKey:key];
            
            // It might be an AVPlayer
            if (playerObj && [playerObj isKindOfClass:[AVPlayer class]]) {
                NSURL *url = [self getUrlFromPlayer:(AVPlayer *)playerObj];
                if (url) return url;
            }
            
            // It might be a wrapper
            if (playerObj && [playerObj respondsToSelector:@selector(avPlayer)]) {
                id innerPlayer = [playerObj valueForKey:@"avPlayer"];
                if (innerPlayer && [innerPlayer isKindOfClass:[AVPlayer class]]) {
                    NSURL *url = [self getUrlFromPlayer:(AVPlayer *)innerPlayer];
                    if (url) return url;
                }
            }
        }
    }
    
    // 3. Recursively check subviews
    for (UIView *subview in view.subviews) {
        NSURL *url = [self getCachedVideoUrlForView:subview depth:depth + 1];
        if (url) return url;
    }
    
    return nil;
}

+ (NSURL *)getUrlFromPlayer:(AVPlayer *)player {
    AVPlayerItem *currentItem = player.currentItem;
    if (!currentItem) return nil;
    
    AVAsset *asset = currentItem.asset;
    if ([asset isKindOfClass:[AVURLAsset class]]) {
        return [(AVURLAsset *)asset URL];
    }
    return nil;
}

+ (void)requestWebVideoUrlForMedia:(IGMedia *)media completion:(void(^)(NSURL *url))completion {
    if (!media) {
        if (completion) completion(nil);
        return;
    }

    // Try to get the shortcode (usually "code" property)
    NSString *shortcode = nil;
    if ([media respondsToSelector:@selector(code)]) {
        shortcode = [media valueForKey:@"code"]; // IGMedia often has this
    } else if ([media respondsToSelector:@selector(pk)]) {
         // PK is numeric ID, converting to shortcode is complex, skip for now or try to use direct link if possible
         // But often "pk" is all we have. For now if no code, fail.
    }
    
    if (!shortcode || ![shortcode isKindOfClass:[NSString class]] || shortcode.length == 0) {
        NSLog(@"[SCInsta] Web Fallback: Could not find shortcode for media.");
        if (completion) completion(nil);
        return;
    }
    
    NSLog(@"[SCInsta] Web Fallback: Found shortcode: %@", shortcode);
    NSURL *webUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.instagram.com/p/%@/", shortcode]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:webUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || !data) {
            NSLog(@"[SCInsta] Web Fallback: Request failed: %@", error);
            if (completion) completion(nil);
            return;
        }
        
        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!html) {
             if (completion) completion(nil);
             return;
        }
        
        // Regex to find og:video
        // <meta property="og:video" content="https://..." />
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"property=\"og:video\" content=\"([^\"]+)\"" options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:html options:0 range:NSMakeRange(0, html.length)];
        
        if (match && match.range.location != NSNotFound) {
            NSString *videoUrlString = [html substringWithRange:[match rangeAtIndex:1]];
            
            // Decode HTML entities if needed (usually not for og:video content but good practice)
            // For now assume standard URL
            
            NSLog(@"[SCInsta] Web Fallback: Found video URL: %@", videoUrlString);
            if (completion) completion([NSURL URLWithString:videoUrlString]);
        } else {
            NSLog(@"[SCInsta] Web Fallback: No og:video tag found.");
            
            // Try searching for "video_url" in JSON
            NSRegularExpression *jsonRegex = [NSRegularExpression regularExpressionWithPattern:@"\"video_url\":\"([^\"]+)\"" options:0 error:nil];
            NSTextCheckingResult *jsonMatch = [jsonRegex firstMatchInString:html options:0 range:NSMakeRange(0, html.length)];
            
            if (jsonMatch && jsonMatch.range.location != NSNotFound) {
                 NSString *jsonUrlString = [html substringWithRange:[jsonMatch rangeAtIndex:1]];
                 // JSON URLs often have \u0026 instead of &
                 jsonUrlString = [jsonUrlString stringByReplacingOccurrencesOfString:@"\\u0026" withString:@"&"];
                 
                 NSLog(@"[SCInsta] Web Fallback: Found JSON video URL: %@", jsonUrlString);
                 if (completion) completion([NSURL URLWithString:jsonUrlString]);
            } else {
                 if (completion) completion(nil);
            }
        }
    }] resume];
}

// View Controllers
+ (UIViewController *)viewControllerForView:(UIView *)view {
    NSString *viewDelegate = @"viewDelegate";
    if ([view respondsToSelector:NSSelectorFromString(viewDelegate)]) {
        return [view valueForKey:viewDelegate];
    }

    return nil;
}

+ (UIViewController *)viewControllerForAncestralView:(UIView *)view {
    NSString *_viewControllerForAncestor = @"_viewControllerForAncestor";
    if ([view respondsToSelector:NSSelectorFromString(_viewControllerForAncestor)]) {
        return [view valueForKey:_viewControllerForAncestor];
    }

    return nil;
}

+ (UIViewController *)nearestViewControllerForView:(UIView *)view {
    return [self viewControllerForView:view] ?: [self viewControllerForAncestralView:view];
}

// Functions
+ (NSString *)IGVersionString {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
};
+ (BOOL)isNotch {
    return [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom > 0;
};

+ (BOOL)existingLongPressGestureRecognizerForView:(UIView *)view {
    NSArray *allRecognizers = view.gestureRecognizers;

    for (UIGestureRecognizer *recognizer in allRecognizers) {
        if ([[recognizer class] isSubclassOfClass:[UILongPressGestureRecognizer class]]) {
            return YES;
        }
    }

    return NO;
}
+ (BOOL)showConfirmation:(void(^)(void))okHandler {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        okHandler();
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"No!" style:UIAlertActionStyleCancel handler:nil]];

    [topMostController() presentViewController:alert animated:YES completion:nil];

    return nil;
};
+ (void)prepareAlertPopoverIfNeeded:(UIAlertController*)alert inView:(UIView*)view {
    if (alert.popoverPresentationController) {
        // UIAlertController is a popover on iPad. Display it in the center of a view.
        alert.popoverPresentationController.sourceView = view;
        alert.popoverPresentationController.sourceRect = CGRectMake(view.bounds.size.width / 2.0, view.bounds.size.height / 2.0, 1.0, 1.0);
        alert.popoverPresentationController.permittedArrowDirections = 0;
    }
};

// Math
+ (NSUInteger)decimalPlacesInDouble:(double)value {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:15]; // Allow enough digits for double precision
    [formatter setMinimumFractionDigits:0];
    [formatter setDecimalSeparator:@"."]; // Force dot for internal logic, then respect locale for final display if needed

    NSString *stringValue = [formatter stringFromNumber:@(value)];

    // Find decimal separator
    NSRange decimalRange = [stringValue rangeOfString:formatter.decimalSeparator];

    if (decimalRange.location == NSNotFound) {
        return 0;
    } else {
        return stringValue.length - (decimalRange.location + decimalRange.length);
    }
}

@end