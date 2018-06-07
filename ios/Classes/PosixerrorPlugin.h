#import <Flutter/Flutter.h>

@interface PosixerrorPlugin : NSObject<FlutterPlugin, NSURLSessionDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, copy, nullable) void (^backgroundCompletionHandler)(void);
@end
