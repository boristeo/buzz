//
//  NewHive.swift
//  buzz
//
//  Created by Boris Teodorovich on 12/1/18.
//  Copyright © 2018 Boris Teodorovich. All rights reserved.
//

import UIKit
import Firebase

class NewHive: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var CURRENT_USER: User!
    
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
        cell.populate(with: courses[indexPath.row], in: self)
        cell.minimized = indexPath != selectedRowIndexPath
        return cell
    }
    
    override func viewDidLoad() {
        tb.delegate = self
        tb.dataSource = self
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let ref = Firestore.firestore().collection("courses").whereField("members", arrayContains: CURRENT_USER.id);
        
        ref.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.courses = []
                for document in querySnapshot!.documents {
                    let temp = Course(name: document.data()["name"] as! String,
                                      hives: document.data()["hives"] as! Int,
                                      description: document.data()["description"] as! String,
                                      members: document.data()["members"] as! [String],
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
        tb.estimatedRowHeight = 80
        tb.rowHeight = UITableView.automaticDimension
        
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.hidesSearchBarWhenScrolling = false
        
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var selectedRowIndexPath: IndexPath? = nil
    @IBOutlet weak var tableView: UITableView!
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == selectedRowIndex {
//            return 140 //Expanded
//        }
//        return 80 //Not expanded
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var rowsToReload = [indexPath]
        if let oldIndexPath = selectedRowIndexPath {
            rowsToReload.append(oldIndexPath)
        }
        selectedRowIndexPath = selectedRowIndexPath != indexPath ? indexPath : nil
        tableView.reloadRows(at: rowsToReload, with: .automatic)
    }

}

// MARK: -

class CourseTableCell: UITableViewCell {
    
    var course: Course!
    var tvc: NewHive!
    
    var minimized: Bool = true {
        didSet {
            descrField.isHidden = minimized
            inputSection.isHidden = minimized
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descrLabel: UILabel!
    @IBOutlet weak var hivesLabel: UILabel!
    @IBOutlet weak var descrField: UITextField!
    @IBOutlet weak var inputSection: UIStackView!
    
    func populate(with item: Course, in tvc: NewHive) {
        course = item
        
        nameLabel.text = item.name
        descrLabel.text = item.description
        hivesLabel.text = String(item.hives)
        
        self.minimized = true
        
        self.tvc = tvc
    }

    @IBAction func createHive(_ sender: Any) {
        guard let loc = CURRENT_LOCATION else {
            print("Can't make a hive at null location")
            return
        }
        Firestore.firestore().collection("hives").document(UUID().uuidString).setData([
            "courseID": course.id,
            "courseName": course.name,
            "queenID" : tvc.CURRENT_USER.id,
            "queenName": tvc.CURRENT_USER.name,
            "members" : 1,
            "coordinates" : GeoPoint(latitude: loc.coordinate.latitude,
                                     longitude: loc.coordinate.longitude),
            "availableTo" : course.members
            
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            } else {
                print("Document successfully written!")
            }
        }
        Firestore.firestore().collection("courses").document(course.id).updateData([
            "hives": course.hives + 1
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            } else {
                print("Document successfully written!")
            }
        }
        tvc.dismiss(animated: true)
    }
    
}

