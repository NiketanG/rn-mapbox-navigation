#import "React/RCTViewManager.h"

@interface RCT_EXTERN_MODULE(MapboxNavigationManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(onLocationChange, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onRouteProgressChange, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onCancelNavigation, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onArrive, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(origin, NSArray)
RCT_EXPORT_VIEW_PROPERTY(destination, NSArray)
RCT_EXPORT_VIEW_PROPERTY(shouldSimulateRoute, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showsEndOfRouteFeedback, BOOL)
RCT_EXPORT_VIEW_PROPERTY(hideStatusView, BOOL)
RCT_EXPORT_VIEW_PROPERTY(mute, BOOL)
RCT_EXPORT_VIEW_PROPERTY(locale, NSString)

RCT_EXTERN_METHOD(
  addMarker: (nonnull NSNumber *)node
  latitude: (nonnull NSNumber *)latitude
  longitude: (nonnull NSNumber *)longitude
  iconSize: (nonnull NSNumber *)iconSize
)

RCT_EXTERN_METHOD(
  clearMarkers: (nonnull NSNumber *)node
)

@end
