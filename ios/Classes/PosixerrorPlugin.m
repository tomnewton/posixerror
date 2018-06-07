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
    [config setDiscretionary:NO];
    [config setSessionSendsLaunchEvents:YES];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config delegate:(id<NSURLSessionDelegate>)self delegateQueue:nil];
    
    // works
    // @"https://ia800500.us.archive.org/5/items/aesop_fables_volume_one_librivox/fables_01_00_aesop.mp3"
    
    // redirects - doesn't work
    // @"https://traffic.megaphone.fm/GLT8678602522.mp3";
    // 10 MB file
    
    NSURL* url = [NSURL URLWithString:@"https://traffic.megaphone.fm/GLT8678602522.mp3"];
    
    NSLog(@"URL we're trying is: %@", url.absoluteString);
    
    
    NSURLSessionDownloadTask* task = [session downloadTaskWithURL:url];
    
    if (@available(iOS 11, *)){
        //iOS 11 on we can let the system know how much data to expect.
        
        //Build a URL HEAD request so we can quickly fetch the headers...
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        request.HTTPMethod = @"HEAD";
        [request addValue:@"identity" forHTTPHeaderField:@"Accept-Encoding"]; //force apache to send content-length
        
        NSURLSession* sSession = [NSURLSession sharedSession];
        
        [[sSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            // handle response
            if ([response respondsToSelector:@selector(allHeaderFields)]) {
                NSDictionary *dictionary = [(NSHTTPURLResponse*)response allHeaderFields];
                //NSLog([dictionary description]);
                NSLog(@"Content-length: %@", [dictionary objectForKey:@"Content-Length"]);
                
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                formatter.numberStyle = NSNumberFormatterDecimalStyle;
                NSNumber* size = [formatter numberFromString:[dictionary objectForKey:@"Content-Length"]];
                
                [task setCountOfBytesClientExpectsToReceive:[size longLongValue]];
                /// kick it off.
                NSLog(@"kicking off job");
                [task resume];
            }
        }] resume];
    } else {
        [task resume];
    }
    
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
