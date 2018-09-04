//
//  LanguageTableViewCell.swift
//  Sandart
//
//  Created by Soohwan.Cho on 2018. 3. 24..
//  Copyright © 2018년 Joshua. All rights reserved.
//

import UIKit

class LanguageTableViewCell: UITableViewCell {

    @IBOutlet var LanguageLabel: UILabel!
    @IBOutlet var DownloadButton: UIButton!
    @IBOutlet var PurchaseButton: UIButton!
    @IBOutlet var Progress: UIProgressView!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
            preservesSuperviewLayoutMargins = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
