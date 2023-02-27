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
    
    var parent: SearchViewController?
    
    var width: CGFloat?
    
    init(parent: SearchViewController, width: CGFloat) {
        let frame = CGRect(x: 0, y: 65, width: width, height: 100)
        super.init(frame: frame)
        self.parent = parent
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    
    private func commonInit() {
        Bundle.main.loadNibNamed("UIKitDoubleSearchView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        placeSearchBar.delegate = self
        areaSearchBar.delegate = self
        parent?.delegate = self
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
            delegate?.currentBar(bar: .place)
        } else if searchBar == areaSearchBar {
            delegate?.currentBar(bar: .area)
        }
    }
        
}

extension UIKitDoubleSearchView: SearchControllerDelegate {
    
    func placeSelected(name: String, selectedBar: SearchBarType) {
        if selectedBar == .place {
            placeSearchBar.text = name
        } else {
            areaSearchBar.text = name
            areaSearchBar.endEditing(true)
            delegate?.currentBar(bar: .place)
            delegate?.placeSourceTextChanged(name)
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
