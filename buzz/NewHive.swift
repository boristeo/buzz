//
//  NewHive.swift
//  buzz
//
//  Created by Boris Teodorovich on 12/1/18.
//  Copyright © 2018 Boris Teodorovich. All rights reserved.
//

import UIKit
import Firebase

class NewHive: ViewController, UITableViewDelegate, UITableViewDataSource {
    var courses: [Course] = [] {
        didSet {
            self.tb.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tb.dequeueReusableCell(withIdentifier: "coursecell", for: indexPath) as! CourseTableCell
        cell.populate(with: courses[indexPath.row])
        return cell
    }
    
    override func viewDidLoad() {
        tb.delegate = self
        tb.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureViews()
        
        let ref = Firestore.firestore().collection("courses").limit(to: 100);
        
        ref.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.courses = []
                for document in querySnapshot!.documents {
                    let temp = Course(name: document.data()["name"] as! String,
                                      hives: document.data()["hives"] as! Int,
                                      id: document.documentID)
                    
                    self.courses.append(temp)
                }
            }
        }

    }
    
    
    @IBOutlet weak var tb: UITableView!
    
    // MARK: Firebase stuff
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
     
    }
    
    // Mark: UI
    let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let alphaSortButton = UIBarButtonItem(title: "Aa", style: .plain, target: self, action: nil)
    let dateSortButton = UIBarButtonItem(title: "Date", style: .plain, target: self, action: nil)
    let newNotificationButton = UIBarButtonItem(title: "Notify", style: .plain, target: self, action: nil)
    
    func configureViews() {
        tb.rowHeight = 80
        
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.hidesSearchBarWhenScrolling = false
        
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: -

class CourseTableCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hivesLabel: UILabel!

    func populate(with item: Course) {
        nameLabel.text = item.name
        hivesLabel.text = String(item.hives)
    }

    
}

