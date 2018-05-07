//
//  LanguageTableViewCell.swift
//  Sandart
//
//  Created by Soohwan.Cho on 2018. 3. 24..
//  Copyright © 2018년 Joshua. All rights reserved.
//

import UIKit

class LanguageTableViewCell: UITableViewCell {

    @IBOutlet weak var LanguageLabel: UILabel!
    @IBOutlet weak var DownloadButton: UIButton!
    @IBOutlet weak var PurchaseButton: UIButton!
    @IBOutlet weak var Progress: UIProgressView!
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
