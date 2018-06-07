#import "PosixerrorPlugin.h"

@implementation PosixerrorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"posixerror"
            binaryMessenger:[registrar messenger]];
  PosixerrorPlugin* instance = [[PosixerrorPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    
      [self runBackgroundDownload];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

-(void)runBackgroundDownload {
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"MY_EXAMPLE_IDENTIFIER"];
    [config setSessionSendsLaunchEvents:YES];
    
    
    // NOTE: If you set [config setDiscretionary:NO]; you don't have any issues
    // whatsoever.
    
    //
    // THE ISSUE:
    //
    // If you set [config setDiscretionary:YES]; you get an NSPOSIXErrorDomain error
    // for any URL that REDIRECTS when you build and run from Android Studio?!?!?
    // If you build and run this from XCode - no error!
    
    // To demonstrate:
    [config setDiscretionary:YES];
    
    // Config 1: This url does NOT redirect - so works whether or not you build and run from Android Studio
    // or XCode.
    //NSURL* url = [NSURL URLWithString:@"https://dcs.megaphone.fm/GLT8678602522.mp3?key=c6acd2ee217fb8c6ab3fabb9be0920e0"];
    // END
    
    // Config 2: This url DOES redirect.
    // 1) Build and run from XCode and everything runs just fine.
    // 2) Build and run from Android Studio, Fails with NSPOSIXErrorDoman invalid argument.
    NSURL* url = [NSURL URLWithString:@"https://traffic.megaphone.fm/GLT8678602522.mp3"];
    // END Config 2.
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config delegate:(id<NSURLSessionDelegate>)self delegateQueue:nil];
    
    
    NSLog(@"URL we're loading is: %@", url.absoluteString);
    
    
    NSURLSessionDownloadTask* task = [session downloadTaskWithURL:url];
    
    [task resume];
}

- (void)URLSession:(nonnull NSURLSession *)session
      downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(nonnull NSURL *)location {
    NSLog(@"COMPLETE!");
}

-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    NSLog(@"Session became invalid %@", error.description);
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession*)session {
    // If we stored a backgroundCompletionHandler - call it.
    if ( self.backgroundCompletionHandler != nil ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.backgroundCompletionHandler();
        });
    }
}

-(void)URLSession:(NSURLSession*)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if ( error != nil ){
        NSLog(@"ERROR: %@", error.debugDescription);
        NSLog(@"Localized: %@", error.localizedDescription);
    }
}


- (void)URLSession:(NSURLSession*)session
      downloadTask:(nonnull NSURLSessionDownloadTask*)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"Progress!!");
}


- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"Download did resume for url: %@", downloadTask.originalRequest.URL.absoluteString);
}

@end
