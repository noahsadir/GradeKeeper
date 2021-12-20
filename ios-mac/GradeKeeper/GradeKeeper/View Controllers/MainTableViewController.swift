//
//  MainTableViewController.swift
//  GradeKeeper
//
//  Created by Noah Sadir on 10/27/21.
//

import UIKit

class MainTableViewController: UITableViewController{
    
    var courseIDs = [String]()
    
    @IBOutlet weak var accountButton: UIBarButtonItem!
    
    @IBOutlet weak var addCourseButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountButton.image = UIImage(systemName: "person.crop.circle")
        addCourseButton.image = UIImage(systemName: "plus")
        
        GradeKeeper.courses().load() { (success, error) in
            if success {
                self.loadGradebook()
            } else if error!.code == 401 {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "promptLoginSegue", sender: nil)
                }
            } else {
                GradeKeeper().errorAlert(self, error: error!, allowsCancel: false) { (action) in
                    DispatchQueue.main.async {
                        self.loadGradebook()
                    }
                }
            }
        }
        
        self.tableView.tintColor = GradeKeeper.themeColor
        self.navigationController?.navigationBar.tintColor = GradeKeeper.themeColor
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func accountButtonClicked(_ sender: Any) {
        
    }
    
    func loadGradebook() {
        self.courseIDs = [String]()
        for course in GradeKeeper.currentUser.courses {
            self.courseIDs.append(course.key)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func loginUnwind(unwindSegue: UIStoryboardSegue) {
        loadGradebook()
    }
    
    @IBAction func createCourseUnwind(unwindSegue: UIStoryboardSegue) {
        loadGradebook()
    }
    
    @IBAction func cancelCreateCourseUnwind(unwindSegue: UIStoryboardSegue) {
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return courseIDs.count
    }

    /**/
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCourseCell", for: indexPath) as UITableViewCell
        
        let courseID = courseIDs[indexPath.row]
        if let selectedCourse = GradeKeeper.currentUser.courses[courseID] {
            cell.textLabel?.text = selectedCourse.courseName
            cell.detailTextLabel?.text = selectedCourse.courseCode
        }
        
        

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    /**/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isUserInteractionEnabled = false
        GradeKeeper.selectedCourseID = courseIDs[indexPath.row]
        GradeKeeper.assignments().load(courseID: GradeKeeper.selectedCourseID) { (success, error) in
            DispatchQueue.main.async {
                tableView.isUserInteractionEnabled = true
                if success {
                    self.performSegue(withIdentifier: "showAssignmentsDetailSegue", sender: nil)
                } else {
                    GradeKeeper().errorAlert(self, error: error!)
                }
            }
        }
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
