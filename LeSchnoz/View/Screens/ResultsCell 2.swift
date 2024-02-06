//
//  ResultsCell.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/11/23.
//

import UIKit

class ResultsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel?
    
    func updateUI(schnozPlace: SchnozPlace) {
        print(schnozPlace.primaryText)
        titleLabel?.text = schnozPlace.primaryText
//        titleLabel.text = schnozPlace.gmsPlace?.name ?? "blank"
    }
    
}
