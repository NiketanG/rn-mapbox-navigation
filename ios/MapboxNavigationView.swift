import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import MapboxMaps

// // adapted from https://pspdfkit.com/blog/2017/native-view-controllers-and-react-native/ and https://github.com/mslabenyak/rn-mapbox-navigation/blob/master/ios/Mapbox/MapboxNavigationView.swift
extension UIView {
  var parentViewController: UIViewController? {
    var parentResponder: UIResponder? = self
    while parentResponder != nil {
      parentResponder = parentResponder!.next
      if let viewController = parentResponder as? UIViewController {
        return viewController
      }
    }
    return nil
  }
}

class MapboxNavigationView: UIView, NavigationMapViewDelegate, NavigationViewControllerDelegate {
  var navigationMapView: NavigationMapView!
  var navigationRouteOptions: NavigationRouteOptions!
  var pointAnnotationManager: PointAnnotationManager? = nil

  var embedded: Bool
  var embedding: Bool
  
  @objc var origin: NSArray = []
  @objc var destination: NSArray = []
  @objc var shouldSimulateRoute: Bool = false
  @objc var showsEndOfRouteFeedback: Bool = false
  @objc var hideStatusView: Bool = false
  @objc var mute: Bool = false
  @objc var locale: NSString = "en_US"
  
  @objc var onLocationChange: RCTDirectEventBlock?
  @objc var onRouteProgressChange: RCTDirectEventBlock?
  @objc var onError: RCTDirectEventBlock?
  @objc var onCancelNavigation: RCTDirectEventBlock?
  @objc var onArrive: RCTDirectEventBlock?

  @objc func addMarker(latitude: NSNumber, longitude: NSNumber, iconSize: NSNumber) {
    if (self.pointAnnotationManager != nil) {
      let pointCoordinate = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
      var customPointAnnotation = PointAnnotation(coordinate: pointCoordinate)
//      customPointAnnotation.image = .init(image: UIImage(named: "default_marker")!, name: "red_pin")
      
      let image = UIImage(named: "default_marker", in: .mapboxNavigation, compatibleWith: nil)!
      customPointAnnotation.image = .init(image: image, name: "red_pin")
            
      pointAnnotationManager?.annotations.append(customPointAnnotation)
    }
  }
    
  @objc func clearMarkers() {
    if (self.pointAnnotationManager != nil) {
      pointAnnotationManager?.annotations = []
      pointAnnotationManager?.annotations.removeAll()
    }
  }
  
  override init(frame: CGRect) {
    self.embedded = false
    self.embedding = false
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if (navigationMapView == nil && !embedding && !embedded) {
      embed()
    } else {
      navigationMapView?.frame = bounds
    }
  }
  
  override func removeFromSuperview() {
    super.removeFromSuperview()
    // cleanup and teardown any existing resources
    navigationMapView?.removeFromSuperview()
  }
  
  private func embed() {
    //guard let parentVC = parentViewController else {
      //return
    //}

    embedding = true

    navigationMapView = NavigationMapView(frame: bounds)
    navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    navigationMapView.delegate = self
    navigationMapView.userLocationStyle = .puck2D()

    let navigationViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
    navigationViewportDataSource.options.followingCameraOptions.zoomUpdatesAllowed = false
    navigationViewportDataSource.followingMobileCamera.zoom = 13.0
    navigationMapView.navigationCamera.viewportDataSource = navigationViewportDataSource
    navigationMapView.localizeLabels();

    //parentVC.addChild(navigationMapView)
    addSubview(navigationMapView)
    //navigationMapView.frame = bounds
    //navigationMapView.didMove(toParentViewController: parentVC)

//    embedding = false
//    embedded = true

    guard origin.count == 2 && destination.count == 2 else { return }
    
    //embedding = true

    let originWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: origin[1] as! CLLocationDegrees, longitude: origin[0] as! CLLocationDegrees))
    let destinationWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: destination[1] as! CLLocationDegrees, longitude: destination[0] as! CLLocationDegrees))

    let options = NavigationRouteOptions(waypoints: [originWaypoint, destinationWaypoint])

    options.locale = Locale(identifier: self.locale as String)

    Directions.shared.calculate(options) { [weak self] (_, result) in
      guard let strongSelf = self, let parentVC = strongSelf.parentViewController else {
        return
      }
      
      switch result {
        case .failure(let error):
          strongSelf.onError!(["message": error.localizedDescription])
        case .success(let response):
          guard let weakSelf = self else {
            return
          }
          
          let navigationService = MapboxNavigationService(routeResponse: response, routeIndex: 0, routeOptions: options, simulating: strongSelf.shouldSimulateRoute ? .always : .never)
          
          let navigationOptions = NavigationOptions(
            styles: [DayStyle()],
            navigationService: navigationService)
          
          let vc = NavigationViewController(for: response, routeIndex: 0, routeOptions: options, navigationOptions: navigationOptions)
          
          vc.showsEndOfRouteFeedback = strongSelf.showsEndOfRouteFeedback
          StatusView.appearance().isHidden = strongSelf.hideStatusView

          options.self.locale = Locale(identifier: strongSelf.locale as String);
          NavigationSettings.shared.voiceMuted = strongSelf.mute;

          vc.delegate = strongSelf
          
          vc.modalPresentationStyle = .fullScreen
          
          parentVC.present(vc, animated: true, completion: nil)

//          parentVC.addChild(vc)
//          strongSelf.addSubview(vc.view)
//          vc.view.frame = strongSelf.bounds
//          vc.didMove(toParent: parentVC)
//          strongSelf.navViewController = vc
      }
      
      strongSelf.embedded = false
      strongSelf.embedding = false
    }
    navigationMapView?.mapView.mapboxMap.onNext(.mapLoaded) { _ in
      do {
          try self.navigationMapView.mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: self.locale as String))
      } catch {
        print("[localizeLabels] Ran into an error updating the layer: \(error)")
      }
    }
  }
  
  func navigationViewController(_ navigationViewController: NavigationViewController, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
    onLocationChange?(["longitude": location.coordinate.longitude, "latitude": location.coordinate.latitude])
    onRouteProgressChange?(["distanceTraveled": progress.distanceTraveled,
                            "durationRemaining": progress.durationRemaining,
                            "fractionTraveled": progress.fractionTraveled,
                            "distanceRemaining": progress.distanceRemaining])
  }
  
  func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
      if (!canceled) {
        return;
      }
      onCancelNavigation?(["message": ""]);
      navigationViewController.navigationService.stop()
      navigationViewController.dismiss(animated: true)
      self.parentViewController?.dismiss(animated: true)
      
      navigationMapView.parentViewController?.dismiss(animated: true)
      self.parentViewController?.navigationController?.popViewController(animated: true)
  }
  
  func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
    onArrive?(["message": ""]);
    return true;
  }

  // Delegate method, which is called whenever final destination `PointAnnotation` is added on
  // `MapView`.
  func navigationMapView(_ navigationMapView: NavigationMapView, didAdd finalDestinationAnnotation: PointAnnotation, pointAnnotationManager: PointAnnotationManager) {
      self.pointAnnotationManager = pointAnnotationManager
  }

  func navigationViewController(_ navigationViewController: NavigationViewController, didAdd finalDestinationAnnotation: PointAnnotation, pointAnnotationManager: PointAnnotationManager) {
      self.pointAnnotationManager = pointAnnotationManager
  }
}
