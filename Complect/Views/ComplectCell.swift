//
//
// ComplectCell.swift
// Complect
//
// Created by sinezeleuny on 31.05.2022
//
        

import UIKit

class ComplectCell: UITableViewCell {
    
    var item: ComplectItem? = nil

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch!
    
    @IBAction func switchItem(_ sender: UISwitch) {
        if let complectsVC = self.findViewController() as? ComplectsVC {
            complectsVC.switchItem(item: item)
            if sender.isOn {
                titleLabel.textColor = UIColor.label
            } else {
                titleLabel.textColor = UIColor.secondaryLabel
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        switcher.onTintColor = #colorLiteral(red: 0.402333498, green: 0.2628500462, blue: 0.7797088027, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
