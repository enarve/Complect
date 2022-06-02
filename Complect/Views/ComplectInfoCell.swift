//
//
// ComplectInfoCell.swift
// Complect
//
// Created by sinezeleuny on 31.05.2022
//
        

import UIKit

class ComplectInfoCell: UITableViewCell {

    var complect: Complect? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    @IBAction func buyButton(_ sender: UIButton) {
        if let complectsVC = self.findViewController() as? ComplectsVC {
            complectsVC.collect(complect: complect)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
