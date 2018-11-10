#import "GatherioPlugin.h"
#import <gatherio/gatherio-Swift.h>

@implementation GatherioPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGatherioPlugin registerWithRegistrar:registrar];
}
@end
