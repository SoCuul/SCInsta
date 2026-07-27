#import "../../InstagramHeaders.h"
#import "../../Utils.h"
#import "../../Downloader/Download.h"

static SCIDownloadDelegate *imageDownloadDelegate;
static SCIDownloadDelegate *videoDownloadDelegate;
static char SCILongPressGestureKey;

static void initDownloaders () {
    // Init downloaders only once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageDownloadDelegate = [[SCIDownloadDelegate alloc] initWithAction:quickLook showProgress:NO];
        videoDownloadDelegate = [[SCIDownloadDelegate alloc] initWithAction:share showProgress:YES];
    });
}
static void SCIAddLongPressGestureRecognizer(UIView *view) {

	if (!view || objc_getAssociatedObject(view, &SCILongPressGestureKey)) return;
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:view action:@selector(handleLongPress:)];
	longPress.minimumPressDuration = [SCIUtils getDoublePref:@"dw_finger_duration"];
	longPress.numberOfTouchesRequired = (NSUInteger)[SCIUtils getDoublePref:@"dw_finger_count"];
	longPress.cancelsTouchesInView = NO;
	[view addGestureRecognizer:longPress];
	objc_setAssociatedObject(view, &SCILongPressGestureKey, longPress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

/* * Feed * */

// Download feed images
%hook IGFeedPhotoView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIUtils getBoolPref:@"dw_feed_posts"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new
- (void)addLongPressGestureRecognizer {SCIAddLongPressGestureRecognizer((UIView *)self);}
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

    if ([SCIUtils getBoolPref:@"dw_feed_posts"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new
- (void)addLongPressGestureRecognizer {SCIAddLongPressGestureRecognizer((UIView *)self);}
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

    if ([SCIUtils getBoolPref:@"dw_reels"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new
- (void)addLongPressGestureRecognizer {SCIAddLongPressGestureRecognizer((UIView *)self);}
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

	if ([SCIUtils getBoolPref:@"dw_reels"]) {
		[self addLongPressGestureRecognizer];
	}
}

%new
- (void)addLongPressGestureRecognizer {SCIAddLongPressGestureRecognizer((UIView *)self);}

%new
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
	if (sender.state != UIGestureRecognizerStateBegan) return;

	id media = nil;

	@try {
		media = [self valueForKey:@"_mediaPassthrough"];
	} @catch (NSException *exception) {
		media = nil;
	}

	if (!media) {
		@try {
			id mediaInfo = [self valueForKey:@"_mediaInfo"];
			if ([mediaInfo respondsToSelector:@selector(media)]) {
				media = [mediaInfo performSelector:@selector(media)];
			}
		} @catch (NSException *exception) {
			media = nil;
		}
	}

	if (!media) {
		[SCIUtils showErrorHUDWithDescription:@"Could not find reel media object"];
		return;
	}

	NSURL *videoUrl = [SCIUtils getVideoUrlForMedia:media];

	if (!videoUrl) {
		[SCIUtils showErrorHUDWithDescription:@"Could not extract video url from reel"];
		return;
	}

	initDownloaders();

	[videoDownloadDelegate downloadFileWithURL:videoUrl fileExtension:[[videoUrl lastPathComponent] pathExtension] hudLabel:nil];
}

%end


/* * Stories * */

// Download story (images)
%hook IGStoryPhotoView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIUtils getBoolPref:@"dw_story"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new
- (void)addLongPressGestureRecognizer {SCIAddLongPressGestureRecognizer((UIView *)self);}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    NSURL *photoUrl = [SCIUtils getPhotoUrlForMedia:[self item]];
    if (!photoUrl) {
        [SCIUtils showErrorHUDWithDescription:@"Could not extract photo url from story"];
        
        return;
    }

    // Download image & show in share menu
    initDownloaders();
    [imageDownloadDelegate downloadFileWithURL:photoUrl fileExtension:[[photoUrl lastPathComponent]pathExtension] hudLabel:nil];
}
%end

// Download story (videos)
%hook IGStoryModernVideoView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIUtils getBoolPref:@"dw_story"]) {
        [self addLongPressGestureRecognizer];
    }

    return;
}
%new
- (void)addLongPressGestureRecognizer {SCIAddLongPressGestureRecognizer((UIView *)self);}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;

    NSURL *videoUrl = [SCIUtils getVideoUrlForMedia:self.item];
    
    if (!videoUrl) {
        [SCIUtils showErrorHUDWithDescription:@"Could not extract video url from story"];

        return;
    }

    // Download video & show in share menu
    initDownloaders();
    [videoDownloadDelegate downloadFileWithURL:videoUrl fileExtension:[[videoUrl lastPathComponent] pathExtension] hudLabel:nil];
}
%end

// Download story (videos, legacy)
%hook IGStoryVideoView

- (void)didMoveToSuperview {
	%orig;

	if ([SCIUtils getBoolPref:@"dw_story"]) {
		[self addLongPressGestureRecognizer];
	}
}
%new
- (void)addLongPressGestureRecognizer {SCIAddLongPressGestureRecognizer((UIView *)self);}

%new
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
	if (sender.state != UIGestureRecognizerStateBegan) return;
	NSURL *videoUrl = nil;
	id item = nil;
	if ([self respondsToSelector:@selector(item)]) {
		item = [self item];
	}
	if (item) {
		videoUrl = [SCIUtils getVideoUrlForMedia:item];
	}
	if (!videoUrl) {
		id provider = nil;

		if ([self respondsToSelector:@selector(videoURLProvider)]) {
			provider = [self videoURLProvider];
		}

		if (provider) {
			videoUrl = [SCIUtils getVideoUrlForMedia:provider];
		}
	}
	if (!videoUrl) {
		[SCIUtils showErrorHUDWithDescription:@"Could not extract video url from story"];
		return;
	}

	initDownloaders();

	[videoDownloadDelegate downloadFileWithURL:videoUrl fileExtension:[[videoUrl lastPathComponent] pathExtension] hudLabel:nil];
}

%end


/* * Profile pictures * */

%hook IGProfilePictureImageView
- (void)didMoveToSuperview {
    %orig;

    if ([SCIUtils getBoolPref:@"save_profile"]) {
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

    IGImageView *_imageView = MSHookIvar<IGImageView *>(self, "_imageView");
    if (!_imageView) return;
    
    IGImageSpecifier *imageSpecifier = _imageView.imageSpecifier;
    if (!imageSpecifier) return;

    NSURL *imageUrl = imageSpecifier.url;
    if (!imageUrl) return;

    // Download image & preview in quick look
    initDownloaders();
    [imageDownloadDelegate downloadFileWithURL:imageUrl fileExtension:[[imageUrl lastPathComponent] pathExtension] hudLabel:@"Loading"];
}
%end