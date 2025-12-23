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
    
    @try {
        if (![self respondsToSelector:@selector(video)]) {
            [SCIUtils showErrorHUDWithDescription:@"Error: Reel media not found"];
            return;
        }

        // 1. Try Primary Extraction (Ivar/Method)
        NSURL *videoUrl = [SCIUtils getVideoUrlForMedia:self.video];
        
        // 2. Try Cache Fallback if primary failed
        if (!videoUrl) {
            NSLog(@"[SCInsta] Primary extraction failed. Trying cache...");
            videoUrl = [SCIUtils getCachedVideoUrlForView:self];
        }

        if (!videoUrl) {
            [SCIUtils showErrorHUDWithDescription:@"Could not extract video URL"];
            return;
        }

        initDownloaders();
        [videoDownloadDelegate downloadFileWithURL:videoUrl
                                     fileExtension:@"mp4"
                                          hudLabel:nil];
    } @catch (NSException *exception) {
        NSLog(@"[SCInsta] Crash in Reel download: %@", exception);
        [SCIUtils showErrorHUDWithDescription:@"Download crashed - check logs"];
    }
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

    @try {
        NSURL *videoUrl = nil;

        // Try to get video URL from story item
        // 0. Quick Check: Does the view itself have the item?
        if ([self respondsToSelector:@selector(item)]) {
             id item = [self performSelector:@selector(item)];
             // Unwrap if needed
             if (item && [item respondsToSelector:@selector(media)]) {
                 id inner = [item performSelector:@selector(media)];
                 if (inner) item = inner;
             }
             if (item) {
                 videoUrl = [SCIUtils getVideoUrlForMedia:item];
             }
        }
        
        // 1. Try to get video URL from story item via Controller Traversal (Duck Typing)
        if (!videoUrl) {
            UIResponder *responder = self;
            while (responder) {
                // Check for known controller class OR just the property we need (Duck Typing)
                if ([responder isKindOfClass:%c(IGStoryFullscreenSectionController)] || 
                    [responder respondsToSelector:@selector(currentStoryItem)] ||
                    [responder respondsToSelector:@selector(item)]) {
                    
                    id result = nil;
                    if ([responder respondsToSelector:@selector(currentStoryItem)]) {
                        result = [responder performSelector:@selector(currentStoryItem)];
                    } else if ([responder respondsToSelector:@selector(item)]) {
                        result = [responder performSelector:@selector(item)];
                    }
                    
                    // Unwrap if the result contains a .media property (e.g. IGStoryItem wrapping IGMedia)
                    if (result && [result respondsToSelector:@selector(media)]) {
                        id innerMedia = [result performSelector:@selector(media)];
                        if (innerMedia) result = innerMedia;
                    }

                    // Try to get URL from the result (whether it's IGMedia or safe to treat as such)
                    if (result) {
                        videoUrl = [SCIUtils getVideoUrlForMedia:result];
                        if (videoUrl) break;
                    }
                }
                responder = [responder nextResponder];
            }
        }

        // Keep captionDelegate as a backup if traversal fails
        if (!videoUrl && [self respondsToSelector:@selector(captionDelegate)]) {
            id captionDelegate = self.captionDelegate;
            if (captionDelegate && [captionDelegate respondsToSelector:@selector(currentStoryItem)]) {
                id result = [captionDelegate performSelector:@selector(currentStoryItem)];
                
                // Unwrap if needed
                if (result && [result respondsToSelector:@selector(media)]) {
                    id innerMedia = [result performSelector:@selector(media)];
                    if (innerMedia) result = innerMedia;
                }
                
                if (result) {
                    videoUrl = [SCIUtils getVideoUrlForMedia:result];
                }
            }
        }
        
        // Fallback: Direct messages video player
        if (!videoUrl) {
            id parentVC = [SCIUtils nearestViewControllerForView:self];
            if (parentVC && [parentVC isKindOfClass:%c(IGDirectVisualMessageViewerController)]) {
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

        // Fallback: Try Cache/Player (Subviews)
        if (!videoUrl) {
             videoUrl = [SCIUtils getCachedVideoUrlForView:self];
        }

        // Fallback: Try Cache/Player (Siblings/Parent)
        // If we are an overlay, the player is likely a sibling. Search the superview.
        if (!videoUrl && self.superview) {
             videoUrl = [SCIUtils getCachedVideoUrlForView:self.superview];
        }
        
        // Fallback: Try Cache/Player (Grandparent)
        if (!videoUrl && self.superview && self.superview.superview) {
             videoUrl = [SCIUtils getCachedVideoUrlForView:self.superview.superview];
        }

        // Fallback: Try Cache/Player (Entire View Controller Hierarchy)
        // This is the "Nuclear Option". Find the owning VC and search its whole view tree.
        if (!videoUrl) {
            UIViewController *vc = [SCIUtils nearestViewControllerForView:self];
            if (vc && vc.view) {
                 videoUrl = [SCIUtils getCachedVideoUrlForView:vc.view];
            }
        }

        if (!videoUrl) {
            [SCIUtils showErrorHUDWithDescription:@"Could not extract video URL from story"];
            return;
        }

        initDownloaders();
        [videoDownloadDelegate downloadFileWithURL:videoUrl
                                     fileExtension:@"mp4"
                                          hudLabel:nil];
    } @catch (NSException *exception) {
        [SCIUtils showErrorHUDWithDescription:@"Download crashed - check logs"];
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