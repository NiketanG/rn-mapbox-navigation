@objc(MapboxNavigationManager)
class MapboxNavigationManager: RCTViewManager {
  override func view() -> UIView! {
    return MapboxNavigationView();
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
        
  @objc func addMarker(_ node: NSNumber, latitude: NSNumber, longitude: NSNumber, iconSize: NSNumber) {
    DispatchQueue.main.async {
      let mapboxNavigationView = self.bridge.uiManager.view(forReactTag: node) as! MapboxNavigationView
      mapboxNavigationView.addMarker(latitude: latitude, longitude: longitude, iconSize: iconSize)
    }
  }
    
  @objc func clearMarkers(_ node: NSNumber) {
    DispatchQueue.main.async {
      let mapboxNavigationView = self.bridge.uiManager.view(forReactTag: node) as! MapboxNavigationView
      mapboxNavigationView.clearMarkers()
    }
  }
}
