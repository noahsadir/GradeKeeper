//
//  GradeScaleTableViewCell.swift
//  GradeKeeper
//
//  Created by Noah Sadir on 12/19/21.
//

import UIKit

class GradeScaleTableViewCell: UITableViewCell {

    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
