//
//  LoginViewController.swift
//  buzz
//
//  Created by Boris Teodorovich on 12/1/18.
//  Copyright © 2018 Boris Teodorovich. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var users: [User] = [] {
        didSet {
            tb.reloadData()
        }
    }
    
    @IBOutlet weak var tb: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tb.dequeueReusableCell(withIdentifier: "usercell", for: indexPath) as! UserCell
        cell.populate(with: users[indexPath.row])
        return cell
    }
    
    var mainView: ViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        tb.delegate = self
        tb.dataSource = self
        tb.rowHeight = 80
        
        getAvailableUsers()
        // Do any additional setup after loading the view.
    }
    
    func getAvailableUsers() {
        
        let ref = Firestore.firestore().collection("users");
        
        ref.addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.users = []
                
                for document in querySnapshot!.documents {
                    let temp = User(name: document.data()["name"] as! String,
                                    id: document.documentID)
                    
                    self.users.append(temp)
                    print("\(document.documentID) => \(document.data())")
                }
            }
            
        }
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainView.CURRENT_USER = users[indexPath.row]
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class UserCell: UITableViewCell{
    var user: User!
    @IBOutlet weak var nameLabel: UILabel!
    
    func populate(with user: User) {
        self.user = user
        self.nameLabel.text = user.name
    }
}
