# yourTube
native objective-c wrapper for youtube get_video_info

Instantiate KBYourTube and get video streams in 2 lines of code;

    KBYourTube *tube = [[KBYourTube alloc] init];
    NSArray *streamArray = [tube getVideoStreamsForID:@"_7nYuyfkjCk"];
    

The links are immediately downloadable. If &title parameter is removed from URL the video will playback natively rather than download.
Heavily based on various clicktoplugin javascript code.
