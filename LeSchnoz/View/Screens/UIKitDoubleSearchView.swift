//
//  UIKitDoubleSearchView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/20/23.
//

import UIKit

class UIKitDoubleSearchView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var placeSearchBar: UISearchBar!
    @IBOutlet weak var areaSearchBar: UISearchBar!
    
    private var currentBar: SearchBarType?
    
    var delegate: DoubleSearchDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//        commonInit()
//    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("UIKitDoubleSearchView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        placeSearchBar.delegate = self
        areaSearchBar.delegate = self
    }
}

extension UIKitDoubleSearchView: UISearchBarDelegate {
    
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      
      if searchBar == placeSearchBar {
          delegate?.placeSourceTextChanged(searchText)
      } else {
          delegate?.areaSearchTextChanged(searchText)
      }
  }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar == placeSearchBar {
            self.currentBar = .place
        } else if searchBar == areaSearchBar {
            self.currentBar = .area
        }
    }
    
}


protocol DoubleSearchDelegate {
    func placeSourceTextChanged(_ text: String)
    func areaSearchTextChanged(_ text: String)
    func currentBar(bar: SearchBarType)
}

enum SearchBarType {
    case place, area
}
