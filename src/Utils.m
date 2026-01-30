#import "Utils.h"

@implementation SCIUtils

+ (BOOL)getBoolPref:(NSString *)key {
    if (![key length] || [[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) return false;

    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
+ (double)getDoublePref:(NSString *)key {
    if (![key length] || [[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) return 0;

    return [[NSUserDefaults standardUserDefaults] doubleForKey:key];
}
+ (NSString *)getStringPref:(NSString *)key {
    if (![key length] || [[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) return @"";

    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

+ (void)cleanCache {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray<NSError *> *deletionErrors = [NSMutableArray array];

    // Temp folder
    // * disabled bc app crashed trying to delete certain files inside it
    //NSError *tempFolderError;
    //[fileManager removeItemAtURL:[NSURL fileURLWithPath:NSTemporaryDirectory()] error:&tempFolderError];

    //if (tempFolderError) [deletionErrors addObject:tempFolderError];

    // Analytics folder
    NSError *analyticsFolderError;
    NSString *analyticsFolder = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Application Support/com.burbn.instagram/analytics"];
    [fileManager removeItemAtURL:[[NSURL alloc] initFileURLWithPath:analyticsFolder] error:&analyticsFolderError];

    if (analyticsFolderError) [deletionErrors addObject:analyticsFolderError];
    
    // Caches folder
    NSString *cachesFolder = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Caches"];
    NSArray *cachesFolderContents = [fileManager contentsOfDirectoryAtURL:[[NSURL alloc] initFileURLWithPath:cachesFolder] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    for (NSURL *fileURL in cachesFolderContents) {
        NSError *cacheItemDeletionError;
        [fileManager removeItemAtURL:fileURL error:&cacheItemDeletionError];

        if (cacheItemDeletionError) [deletionErrors addObject:cacheItemDeletionError];
    }

    // Log errors
    if (deletionErrors.count > 1) {

        for (NSError *error in deletionErrors) {
            NSLog(@"[SCInsta] File Deletion Error: %@", error);
        }

    }

}

// Displaying View Controllers
+ (void)showQuickLookVC:(NSArray<id> *)items {
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    QuickLookDelegate *quickLookDelegate = [[QuickLookDelegate alloc] initWithPreviewItemURLs:items];

    previewController.dataSource = quickLookDelegate;
    
    [topMostController() presentViewController:previewController animated:true completion:nil];
}
+ (void)showShareVC:(id)item {
    UIActivityViewController *acVC = [[UIActivityViewController alloc] initWithActivityItems:@[item] applicationActivities:nil];
    if (is_iPad()) {
        acVC.popoverPresentationController.sourceView = topMostController().view;
        acVC.popoverPresentationController.sourceRect = CGRectMake(topMostController().view.bounds.size.width / 2.0, topMostController().view.bounds.size.height / 2.0, 1.0, 1.0);
    }
    [topMostController() presentViewController:acVC animated:true completion:nil];
}

// Colours
+ (UIColor *)SCIColor_Primary {
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

    [hud showInView:topMostController().view];
    [hud dismissAfterDelay:4.0];

    return hud;
}

// Media
+ (NSURL *)getPhotoUrl:(IGPhoto *)photo {
    if (!photo) return nil;

    // Get highest quality photo link
    NSURL *photoUrl = [photo imageURLForWidth:100000.00];

    return photoUrl;
}
+ (NSURL *)getPhotoUrlForMedia:(IGMedia *)media {
    if (!media) return nil;

    IGPhoto *photo = media.photo;

    return [SCIUtils getPhotoUrl:photo];
}
+ (NSURL *)getVideoUrl:(IGVideo *)video {
    if (!video) return nil;

    // The past (pre v398)
    if ([video respondsToSelector:@selector(sortedVideoURLsBySize)]) {
        NSArray<NSDictionary *> *sorted = [video sortedVideoURLsBySize];
        NSString *urlString = sorted.firstObject[@"url"];
        return urlString.length ? [NSURL URLWithString:urlString] : nil;
    }

    // The present (post v398)
    if ([video respondsToSelector:@selector(allVideoURLs)]) {
        return [[video allVideoURLs] anyObject];
    }

    return nil;
}
+ (NSURL *)getVideoUrlForMedia:(IGMedia *)media {
    if (!media) return nil;

    IGVideo *video = media.video;
    if (!video) return nil;

    return [SCIUtils getVideoUrl:video];
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
+ (BOOL)showConfirmation:(void(^)(void))okHandler cancelHandler:(void(^)(void))cancelHandler {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        okHandler();
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"No!" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cancelHandler != nil) {
            cancelHandler();
        }
    }]];

    [topMostController() presentViewController:alert animated:YES completion:nil];

    return nil;
};
+ (void)showRestartConfirmation {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Restart required" message:@"You must restart the app to apply this change" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Restart" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        exit(0);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleCancel handler:nil]];

    [topMostController() presentViewController:alert animated:YES completion:nil];
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