//
//  SKSene.swift
//  PokerDynamoPro
//
//  Created by jin fu on 2025/3/10.
//

import SpriteKit
import UIKit

extension SKScene {
    func captureSceneImage() -> UIImage? {
        guard let view = self.view else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { context in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        
        return image
    }
}
