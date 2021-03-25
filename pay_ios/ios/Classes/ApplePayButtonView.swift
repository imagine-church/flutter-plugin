import Flutter
import UIKit
import PassKit

class ApplePayButtonViewFactory: NSObject, FlutterPlatformViewFactory {
  private var messenger: FlutterBinaryMessenger
  
  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }
  
  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return ApplePayButtonView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args,
      binaryMessenger: messenger)
  }
  
  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}

class ApplePayButtonView: NSObject, FlutterPlatformView {
  private var view: UIView
  var type: NSNumber?
  var style: NSNumber?
  
  private var applePayButton: PKPaymentButton?
  
  private let channel: FlutterMethodChannel
  
  @objc func handleApplePayButtonTapped() {
    channel.invokeMethod("onPressed", arguments: nil)
  }
  
  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger
  ) {
    channel = FlutterMethodChannel(name: "plugins.flutter.io/pay/apple_pay_button/\(viewId)",
                                   binaryMessenger: messenger)
    view = UIView()
    super.init()
    channel.setMethodCallHandler(handle)
    
    if let arguments = args as? Dictionary<String, AnyObject> {
      type = arguments["type"] as? NSNumber
      style = arguments["style"] as? NSNumber
    }
    createApplePayView()
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  func view() -> UIView {
    return view
  }
  
  func createApplePayView(){
    if let applePayButton = self.applePayButton {
      applePayButton.removeFromSuperview()
    }
    
    let paymentButtonType = PKPaymentButtonType(rawValue: self.type as? Int ?? 0) ?? .plain
    let paymentButtonStyle = PKPaymentButtonStyle(rawValue: self.style as? Int ?? 2) ?? .black
    self.applePayButton = PKPaymentButton(paymentButtonType: paymentButtonType, paymentButtonStyle: paymentButtonStyle)
    
    if let applePayButton = self.applePayButton {
      applePayButton.translatesAutoresizingMaskIntoConstraints = false
      applePayButton.addTarget(self, action: #selector(handleApplePayButtonTapped), for: .touchUpInside)
      view.addSubview(applePayButton)
      
      applePayButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
      applePayButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
      applePayButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
      applePayButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
  }
}