# posixerror

This demonstrates an issue with NSURLSession's discretionary property and building with Android Studio vs XCode on the iOS simulator.

## Getting Started

### NSURLSessionConfiguration Discretionary property breaks redirects on iOS Simulators when running from Android Studio, but not XCode.

See the comments here: [PosixerrorPlugin.m](https://github.com/tomnewton/posixerror/blob/master/ios/Classes/PosixerrorPlugin.m#L27-L49).

```objectivec
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
    
    // When thing run properly you'll see PROGRESS!! and COMPLETE!! in the debug output.
    // When the issue is triggered, you'll see the following in the debug output in Android Studio.
    // ERROR: Error Domain=NSPOSIXErrorDomain Code=22 "Invalid argument" UserInfo={_kCFStreamErrorCodeKey=22, _kCFStreamErrorDomainKey=1}
    
    // To demonstrate:
    [config setDiscretionary:YES];
    
    //
    // Config 1: This url DOES redirect and demonstrates the strange issue I'm seeing.
    //
    // 1) Build and run from XCode and everything runs just fine.
    // 2) Build and run from Android Studio, Fails with NSPOSIXErrorDoman invalid argument.
    NSURL* url = [NSURL URLWithString:@"https://traffic.megaphone.fm/GLT8678602522.mp3"];
    // Could it be that the way the debugger is attached is causing an issue? I've seen some strange
    // recent discussion of something similar here on the Xamarin project:
    // https://bugzilla.xamarin.com/show_bug.cgi?id=59793
   
    
    // Config 2: This url does NOT redirect - so works whether or not you build and run from Android Studio
    // or XCode. If you want to prove it to yourself, just uncomment the url below.
    //NSURL* url = [NSURL URLWithString:@"https://dcs.megaphone.fm/GLT8678602522.mp3?key=c6acd2ee217fb8c6ab3fabb9be0920e0"];

    NSURLSession* session = [NSURLSession sessionWithConfiguration:config delegate:(id<NSURLSessionDelegate>)self delegateQueue:nil];
    
    
    NSLog(@"URL we're loading is: %@", url.absoluteString);
    
    
    NSURLSessionDownloadTask* task = [session downloadTaskWithURL:url];
    
    [task resume];
}
```