//
//  HistoryVC.swift
//  PokerDynamoPro
//
//  Created by jin fu on 2025/3/10.
//


import UIKit

class PokerDynamoHistoryVC: UIViewController {

    @IBOutlet weak var cv : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cv.delegate = self
        cv.dataSource = self
        
    }
    
}

extension PokerDynamoHistoryVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrHistory.isEmpty ? 1 : arrHistory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if arrHistory.isEmpty{
            return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HelperCell", for: indexPath)as! PokerDynamoHelperCell
        
        cell.img.image = UIImage(data: arrHistory[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if arrHistory.isEmpty{
            return collectionView.bounds.size
        }
        
        let w = collectionView.bounds.width/2
        return CGSize(width: w, height: w * 0.5)
    }
    
}
