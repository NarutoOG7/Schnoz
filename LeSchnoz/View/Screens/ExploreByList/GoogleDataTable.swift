//
//  GoogleDataTable.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/16/23.
//

import SwiftUI
import GooglePlaces

struct GoogleDataTable: UIViewRepresentable {
    
    let tableView = UITableView()
        
    var coordinator: GoogleCoordinator?
    
    func makeUIView(context: Context) -> UITableView {
        
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        
        return tableView
    }
    
    func updateUIView(_ uiView: UITableView, context: Context) {
        
    }
    
    func makeCoordinator() -> GoogleCoordinator {
        .init()
    }
    
    
    //MARK: - COordinator
    
    final class GoogleCoordinator:
        GMSAutocompleteTableDataSource,  GMSAutocompleteTableDataSourceDelegate, UISearchBarDelegate {
                
        
        
        func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
            
            
        }
        
        func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
            
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            sourceTextHasChanged(searchText)
        }
        
        
//        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            
//            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HostingCell
//
//                       let view = Text(rows[indexPath.row])
//                               .frame(height: 50).background(Color.blue)
//                       
//                       // create & setup hosting controller only once
//                       if tableViewCell.host == nil {
//                           let controller = UIHostingController(rootView: AnyView(view))
//                           tableViewCell.host = controller
//                           
//                           let tableCellViewContent = controller.view!
//                           tableCellViewContent.translatesAutoresizingMaskIntoConstraints = false
//                           tableViewCell.contentView.addSubview(tableCellViewContent)
//                           tableCellViewContent.topAnchor.constraint(equalTo: tableViewCell.contentView.topAnchor).isActive = true
//                           tableCellViewContent.leftAnchor.constraint(equalTo: tableViewCell.contentView.leftAnchor).isActive = true
//                           tableCellViewContent.bottomAnchor.constraint(equalTo: tableViewCell.contentView.bottomAnchor).isActive = true
//                           tableCellViewContent.rightAnchor.constraint(equalTo: tableViewCell.contentView.rightAnchor).isActive = true
//                       } else {
//                           // reused cell, so just set other SwiftUI root view
//                           tableViewCell.host?.rootView = AnyView(view)
//                       }
//                       tableViewCell.setNeedsLayout()
//                       return tableViewCell
//        }
    }
}
