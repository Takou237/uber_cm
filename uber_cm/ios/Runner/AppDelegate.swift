import Flutter
import UIKit
import GoogleMaps // Ajoute l'import
// ...
GMSServices.provideAPIKey("AIzaSyDqJtH6hpF1i1ct9qHzKsqHh4wzMwZTzfw")

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
