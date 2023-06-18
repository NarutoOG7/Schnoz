//
//  FMUsers.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 6/16/23.
//

import Foundation

struct FirestoreUser: Identifiable {
    var id: String
    var username: String
    
}

extension FirebaseManager {
    
    func doesUserExist(id: String, _ exists: @escaping(Bool) -> Void) {
    
        guard let db = db else { exists(false)
            return }
            let usersCollection = db.collection("Users")
        
        usersCollection.whereField("id", isEqualTo: id).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error checking username availability: \(error.localizedDescription)")
                    exists(false)
                } else {
                    let usernameExists = !snapshot!.isEmpty
                    exists(usernameExists)
                }
            }
    }
    
    func addUserToFirestore(_ user: FirestoreUser, withcCompletion completion: @escaping(Error?) -> () = {_ in}) {
        
        guard let db = db else { return }
                        
        db.collection("Users").document(user.id).setData([
            "id" : user.id,
            "username" : user.username,
            
        ]) { error in
            
            if let error = error {
                print(error.localizedDescription)
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}
