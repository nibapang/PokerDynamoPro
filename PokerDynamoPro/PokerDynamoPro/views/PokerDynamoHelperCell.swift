//
//  HelperCell.swift
//  PokerDynamoPro
//
//  Created by jin fu on 2025/3/10.
//

import UIKit


class PokerDynamoHelperCell: UICollectionViewCell{
    
    @IBOutlet weak var img: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGesture()
    }
    
    private func setupGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.2 // Adjust for quicker or slower response
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            // Scale up the cell to 2x
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            })
            
        case .ended, .cancelled, .failed:
            // Scale back to normal size
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = .identity
            })
            
        default:
            break
        }
    }
}
