#import "Download.h"

@implementation SCIDownloadDelegate

- (instancetype)initWithAction:(DownloadAction)action showProgress:(BOOL)showProgress {
    self = [super init];
    
    if (self) {
        // Read-only properties
        _action = action;
        _showProgress = showProgress;

        // Properties
        self.downloadManager = [[SCIDownloadManager alloc] initWithDelegate:self];
        self.hud = [[JGProgressHUD alloc] init];
    }

    return self;
}
- (void)downloadFileWithURL:(NSURL *)url fileExtension:(NSString *)fileExtension hudLabel:(NSString *)hudLabel {
    // Show progress gui
    self.hud = [[JGProgressHUD alloc] init];
    self.hud.textLabel.text = hudLabel != nil ? hudLabel : @"Downloading";
    
    // Allow user to interact with app while downloading (Background Download)
    self.hud.interactionType = JGProgressHUDInteractionTypeBlockNoTouches;

    if (self.showProgress) {
        JGProgressHUDRingIndicatorView *indicatorView = [[JGProgressHUDRingIndicatorView alloc] init ];
        indicatorView.roundProgressLine = YES;
        indicatorView.ringWidth = 3.5;

        self.hud.indicatorView = indicatorView;
        self.hud.detailTextLabel.text = [NSString stringWithFormat:@"00%% Complete"];

        // Allow dismissing longer downloads (requiring progress updates)
        __weak typeof(self) weakSelf = self;
        self.hud.tapOutsideBlock = ^(JGProgressHUD * _Nonnull HUD) {
            // Optional: Ask for confirmation before cancelling?
            // For now, simple tap won't mistakenly cancel since touches pass through.
            // But if they tap ON the HUD it might trigger.
            // Actually with BlockNoTouches, tapOutsideBlock might not trigger as expected on the window.
            // Let's rely on explicit cancel or completed.
        };
        
        // Allow tap on HUD to cancel
        self.hud.tapOnHUDViewBlock = ^(JGProgressHUD * _Nonnull HUD) {
             [weakSelf.downloadManager cancelDownload];
        };
    }

    [self.hud showInView:topMostController().view];

    NSLog(@"[SCInsta] Download: Will start download for url \"%@\" with file extension: \".%@\"", url, fileExtension);

    // Start download using manager
    [self.downloadManager downloadFileWithURL:url fileExtension:fileExtension];
}

// Delegate methods
- (void)downloadDidStart {
    NSLog(@"[SCInsta] Download: Download started");
}
- (void)downloadDidCancel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hud dismiss];
    });

    NSLog(@"[SCInsta] Download: Download cancelled");
}
- (void)downloadDidProgress:(float)progress {
    NSLog(@"[SCInsta] Download: Download progress: %f", progress);
    
    if (self.showProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hud setProgress:progress animated:false];
            self.hud.detailTextLabel.text = [NSString stringWithFormat:@"%02d%% Complete", (int)(progress * 100)];
        });
    }
}
- (void)downloadDidFinishWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Check if it actually errored (not cancelled)
        if (error && error.code != NSURLErrorCancelled) {
            NSLog(@"[SCInsta] Download: Download failed with error: \"%@\"", error);
            [SCIUtils showErrorHUDWithDescription:@"Error, try again later"];
        }
    });
}
- (void)downloadDidFinishWithFileURL:(NSURL *)fileURL {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hud dismiss];

        NSLog(@"[SCInsta] Download: Download finished with url: \"%@\"", [fileURL absoluteString]);
        NSLog(@"[SCInsta] Download: Completed with action %d", (int)self.action);

        switch (self.action) {
            case share:
                [SCIManager showShareVC:fileURL];
                break;
            
            case quickLook:
                [SCIManager showQuickLookVC:@[fileURL]];
                break;
        }
    });
}

@end