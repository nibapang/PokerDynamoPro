//
//  GameVC.swift
//  PokerDynamoPro
//
//  Created by jin fu on 2025/3/10.
//


import UIKit
import SpriteKit

class PokerDynamoGameVC: UIViewController {
    
    @IBOutlet weak var viewGame: UIView!
    @IBOutlet var bvAdd: UIVisualEffectView!
    
    var scene: PokerDynamoGameScene?
    
    var isPaused: Bool = false{
        didSet{
            scene?.isPaused = isPaused
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGame()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isPaused = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isPaused = true
        bvAdd.removeFromSuperview()
    }
    
    private func setupGame() {
        
        scene = PokerDynamoGameScene(size: viewGame.bounds.size)
        scene?.scaleMode = .aspectFill
        
        scene?.setGameOver = {
            
            if let sceneImage = self.scene?.captureSceneImage(),
               let pngData = sceneImage.pngData() {
                arrHistory.append(pngData)
            }
            
        }
        
        if let view = viewGame as? SKView {
            
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            
        }
        
    }
    
    @IBAction func btnMenu(_ sender: UIButton) {
        
        if sender.tag == 0{
            
            isPaused = false
            bvAdd.removeFromSuperview()
            
        }else{
            
            isPaused = true
            
            let size = UIScreen.main.bounds.size
            
            bvAdd.frame.size = size
            
            bvAdd.center = CGPoint(x: size.width/2, y: size.height/2)
            
            view.addSubview(bvAdd)
            
        }
        
    }
    
    @IBAction func btnSave(_ sender: UIButton) {
        bvAdd.removeFromSuperview()
        
        scene?.setGameOver = {
            if let sceneImage = self.scene?.captureSceneImage(),
               let pngData = sceneImage.pngData() {
                arrHistory.append(pngData)
                
                // Create and show checkmark animation
                let checkmark = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
                checkmark.center = self.view.center
                checkmark.tintColor = .green
                checkmark.image = UIImage(systemName: "checkmark.circle.fill")
                checkmark.alpha = 0
                self.view.addSubview(checkmark)
                
                // Animate checkmark
                UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: [], animations: {
                    // Pop in
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                        checkmark.alpha = 1
                        checkmark.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    }
                    
                    // Settle
                    UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.2) {
                        checkmark.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }
                    
                    // Wait and fade out
                    UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                        checkmark.alpha = 0
                        checkmark.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    }
                    
                }) { completed in
                    checkmark.removeFromSuperview()
                }
            }
        }
    }
    
    
}
