//
//  DoubleRightDetailTableViewCell.swift
//  Courseman
//
//  Created by Noah Sadir on 3/4/22.
//

import UIKit

class DoubleRightDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topDetailLabel: UILabel!
    @IBOutlet weak var bottomDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
