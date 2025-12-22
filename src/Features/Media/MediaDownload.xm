#import "../../InstagramHeaders.h"
#import "../../Manager.h"
#import "../../Utils.h"
#import "../../Downloader/Download.h"

static SCIDownloadDelegate *imageDownloadDelegate;
static SCIDownloadDelegate *videoDownloadDelegate;

static void initDownloaders () {
    // Init downloaders only once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageDownloadDelegate = [[SCIDownloadDelegate alloc] initWithAction:quickLook showProgress:NO];
        videoDownloadDelegate = [[SCIDownloadDelegate alloc] initWithAction:share showProgress:YES];
    });
}

/* * Feed * */

// Download feed images
%hook IGFeedPhotoView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIManager getBoolPref:@"dw_feed_posts"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new - (void)addLongPressGestureRecognizer {
    NSLog(@"[SCInsta] Adding feed photo download long press gesture recognizer");

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = [SCIManager getDoublePref:@"dw_finger_duration"];
    longPress.numberOfTouchesRequired = [SCIManager getDoublePref:@"dw_finger_count"];

    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    // Get photo instance
    IGPhoto *photo;

    if ([self.delegate isKindOfClass:%c(IGFeedItemPhotoCell)]) {
        IGFeedItemPhotoCellConfiguration *_configuration = MSHookIvar<IGFeedItemPhotoCellConfiguration *>(self.delegate, "_configuration");
        if (!_configuration) return;

        photo = MSHookIvar<IGPhoto *>(_configuration, "_photo");
    }
    else if ([self.delegate isKindOfClass:%c(IGFeedItemPagePhotoCell)]) {
        IGFeedItemPagePhotoCell *pagePhotoCell = self.delegate;

        photo = pagePhotoCell.pagePhotoPost.photo;
    }

    NSURL *photoUrl = [SCIUtils getPhotoUrl:photo];
    if (!photoUrl) {
        [SCIUtils showErrorHUDWithDescription:@"Could not extract photo url from post"];
        
        return;
    }

    // Download image & show in share menu
    initDownloaders();
    [imageDownloadDelegate downloadFileWithURL:photoUrl
                                 fileExtension:[[photoUrl lastPathComponent]pathExtension]
                                      hudLabel:nil];
}
%end

// Download feed videos
%hook IGModernFeedVideoCell.IGModernFeedVideoCell
- (void)didMoveToSuperview {
    %orig;

    if ([SCIManager getBoolPref:@"dw_feed_posts"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new - (void)addLongPressGestureRecognizer {
    NSLog(@"[SCInsta] Adding feed video download long press gesture recognizer");

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = [SCIManager getDoublePref:@"dw_finger_duration"];
    longPress.numberOfTouchesRequired = [SCIManager getDoublePref:@"dw_finger_count"];

    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    NSURL *videoUrl = [SCIUtils getVideoUrlForMedia:[self mediaCellFeedItem]];
    if (!videoUrl) {
        [SCIUtils showErrorHUDWithDescription:@"Could not extract video url from post"];

        return;
    }

    // Download video & show in share menu
    initDownloaders();
    [videoDownloadDelegate downloadFileWithURL:videoUrl
                                 fileExtension:[[videoUrl lastPathComponent] pathExtension]
                                      hudLabel:nil];
}
%end


/* * Reels * */

// Download reels (photos)
%hook IGSundialViewerPhotoView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIManager getBoolPref:@"dw_reels"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new - (void)addLongPressGestureRecognizer {
    NSLog(@"[SCInsta] Adding reels photo download long press gesture recognizer");

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = [SCIManager getDoublePref:@"dw_finger_duration"];
    longPress.numberOfTouchesRequired = [SCIManager getDoublePref:@"dw_finger_count"];

    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    IGPhoto *_photo = MSHookIvar<IGPhoto *>(self, "_photo");

    NSURL *photoUrl = [SCIUtils getPhotoUrl:_photo];
    if (!photoUrl) {
        [SCIUtils showErrorHUDWithDescription:@"Could not extract photo url from reel"];

        return;
    }

    // Download image & show in share menu
    initDownloaders();
    [imageDownloadDelegate downloadFileWithURL:photoUrl
                                 fileExtension:[[photoUrl lastPathComponent]pathExtension]
                                      hudLabel:nil];
}
%end

// Download reels (videos)
%hook IGSundialViewerVideoCell
- (void)didMoveToSuperview {
    %orig;

    if ([SCIManager getBoolPref:@"dw_reels"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new - (void)addLongPressGestureRecognizer {
    NSLog(@"[SCInsta] Adding reels video download long press gesture recognizer");

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = [SCIManager getDoublePref:@"dw_finger_duration"];
    longPress.numberOfTouchesRequired = [SCIManager getDoublePref:@"dw_finger_count"];

    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;
    
    if (![self respondsToSelector:@selector(video)]) {
        [SCIUtils showErrorHUDWithDescription:@"Error: Reel media not found (unsupported version?)"];
        return;
    }

    NSURL *videoUrl = [SCIUtils getVideoUrlForMedia:self.video];
    
    // Helper block to start download
    void (^startDownload)(NSURL *) = ^(NSURL *url) {
        initDownloaders();
        [videoDownloadDelegate downloadFileWithURL:url
                                     fileExtension:[[url lastPathComponent] pathExtension]
                                          hudLabel:nil];
    };

    if (videoUrl) {
        startDownload(videoUrl);
        return;
    }
    
    // Fallback 1: Try Cache/Player (Immediate Check)
    // This is often faster and works for whatever is playing
    NSURL *cachedUrl = [SCIUtils getCachedVideoUrlForView:self];
    if (cachedUrl) {
        NSLog(@"[SCInsta] Found cached video URL: %@", cachedUrl);
        startDownload(cachedUrl);
        return;
    }
    
    // Fallback 2: Try fetching from web
    [SCIUtils showErrorHUDWithDescription:@"Fetching video info..."];
    [SCIUtils requestWebVideoUrlForMedia:self.video completion:^(NSURL *webUrl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (webUrl) {
                 startDownload(webUrl);
            } else {
                 [SCIUtils showErrorHUDWithDescription:@"Download failed. Enable FLEX to debug."];
            }
        });
    }];
}
%end


/* * Stories * */

// Download story (images)
%hook IGStoryPhotoView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIManager getBoolPref:@"dw_story"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new - (void)addLongPressGestureRecognizer {
    NSLog(@"[SCInsta] Adding story photo download long press gesture recognizer");

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = [SCIManager getDoublePref:@"dw_finger_duration"];
    longPress.numberOfTouchesRequired = [SCIManager getDoublePref:@"dw_finger_count"];

    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    NSURL *photoUrl = [SCIUtils getPhotoUrlForMedia:[self item]];
    if (!photoUrl) {
        [SCIUtils showErrorHUDWithDescription:@"Could not extract photo url from story"];
        
        return;
    }

    // Download image & show in share menu
    initDownloaders();
    [imageDownloadDelegate downloadFileWithURL:photoUrl
                                 fileExtension:[[photoUrl lastPathComponent]pathExtension]
                                      hudLabel:nil];
}
%end

// Download story (videos)
%hook IGStoryVideoView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIManager getBoolPref:@"dw_story"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new - (void)addLongPressGestureRecognizer {
    //NSLog(@"[SCInsta] Adding story video download long press gesture recognizer");

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = [SCIManager getDoublePref:@"dw_finger_duration"];
    longPress.numberOfTouchesRequired = [SCIManager getDoublePref:@"dw_finger_count"];

    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    NSURL *videoUrl;

    @try {
        IGStoryFullscreenSectionController *captionDelegate = nil;
        
        // Safety check for delegate
        if ([self respondsToSelector:@selector(captionDelegate)]) {
            captionDelegate = self.captionDelegate;
        }
        
        if (captionDelegate) {
            if ([captionDelegate respondsToSelector:@selector(currentStoryItem)]) {
                IGMedia *media = captionDelegate.currentStoryItem;
                if (media) {
                    videoUrl = [SCIUtils getVideoUrlForMedia:media];
                }
            }
        }
        else {
            // Direct messages video player logic remains same but safer
            id parentVC = [SCIUtils nearestViewControllerForView:self];
            if (parentVC && [parentVC isKindOfClass:%c(IGDirectVisualMessageViewerController)]) {
                // Use MSHookIvar safely? we can't try/catch hooks easily but we can check pointers
                IGDirectVisualMessageViewerViewModeAwareDataSource *_dataSource = MSHookIvar<IGDirectVisualMessageViewerViewModeAwareDataSource *>(parentVC, "_dataSource");
                if (_dataSource) {
                    IGDirectVisualMessage *_currentMessage = MSHookIvar<IGDirectVisualMessage *>(_dataSource, "_currentMessage");
                    if (_currentMessage && [_currentMessage respondsToSelector:@selector(rawVideo)]) {
                        IGVideo *rawVideo = _currentMessage.rawVideo;
                        if (rawVideo) {
                            videoUrl = [SCIUtils getVideoUrl:rawVideo];
                        }
                    }
                }
            }
        }
        
        // Helper block to start download
        void (^startDownload)(NSURL *) = ^(NSURL *url) {
            initDownloaders();
            [videoDownloadDelegate downloadFileWithURL:url
                                         fileExtension:[[url lastPathComponent] pathExtension]
                                              hudLabel:nil];
        };

        if (videoUrl) {
            startDownload(videoUrl);
            return;
        }
        
        // Fallback 1: Try Cache/Player
        NSURL *cachedUrl = [SCIUtils getCachedVideoUrlForView:self];
        if (cachedUrl) {
            NSLog(@"[SCInsta] Found cached story video URL: %@", cachedUrl);
            startDownload(cachedUrl);
            return;
        }
        
        // Fallback 2: Try Web
        if (captionDelegate && [captionDelegate respondsToSelector:@selector(currentStoryItem)]) {
            IGMedia *mediaItem = captionDelegate.currentStoryItem;
            if (mediaItem) {
                [SCIUtils showErrorHUDWithDescription:@"Fetching video info..."];
                [SCIUtils requestWebVideoUrlForMedia:mediaItem completion:^(NSURL *webUrl) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                         if (webUrl) {
                              startDownload(webUrl);
                         } else {
                              [SCIUtils showErrorHUDWithDescription:@"Could not extract video url from story"];
                         }
                    });
                }];
                return;
            }
        }
        
        [SCIUtils showErrorHUDWithDescription:@"Could not extract video url from story"];
        
    } @catch (NSException *exception) {
        NSLog(@"[SCInsta] Critical Error in Story Download: %@", exception);
        [SCIUtils showErrorHUDWithDescription:@"Error: Story download crashed (Log sent)"];
    }
}
%end


/* * Profile pictures * */

%hook IGProfilePictureImageView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIManager getBoolPref:@"save_profile"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new - (void)addLongPressGestureRecognizer {
    NSLog(@"[SCInsta] Adding profile picture long press gesture recognizer");

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    IGImageRequest *_imageRequest = MSHookIvar<IGImageRequest *>(self, "_imageRequest");
    if (!_imageRequest) return;
    
    NSURL *imageUrl = [_imageRequest url];
    if (!imageUrl) return;

    // Download image & preview in quick look
    initDownloaders();
    [imageDownloadDelegate downloadFileWithURL:imageUrl
                                 fileExtension:[[imageUrl lastPathComponent] pathExtension]
                                      hudLabel:@"Loading"];
}
%end