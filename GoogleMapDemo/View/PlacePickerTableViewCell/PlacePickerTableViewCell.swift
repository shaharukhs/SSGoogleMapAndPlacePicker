//
//  PlacePickerTableViewCell.swift
//  PayBankUber
//
//  Created by Ascratech on 03/11/17.
//  Copyright © 2017 Ascracom.ascratech. All rights reserved.
//

import UIKit

class PlacePickerTableViewCell: UITableViewCell {

    @IBOutlet weak var locationIconImageView: UIImageView!
    @IBOutlet weak var nearByPlaceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
