//
//  ViewAssignmentTableViewController.swift
//  GradeKeeper
//
//  Created by Noah Sadir on 11/6/21.
//

import UIKit

class ViewAssignmentTableViewController: UITableViewController {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var assignmentGradeLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var rawScoreLabel: UILabel!
    @IBOutlet weak var penaltyLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var adjustedScoreLabel: UILabel!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var assignDateLabel: UILabel!
    @IBOutlet weak var gradedDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tintColor = GradeKeeper.themeColor
        self.navigationController?.navigationBar.tintColor = GradeKeeper.themeColor
        
        backButton.image = UIImage(systemName: "xmark")
        trashButton.image = UIImage(systemName: "trash")
        editButton.image = UIImage(systemName: "pencil")
        
        if let assignmentItem = GradeKeeper.currentUser.assignments[GradeKeeper.selectedAssignmentID] {
            self.title = assignmentItem.title
            descriptionLabel.text = assignmentItem.description
            rawScoreLabel.text = GradeKeeper.calculate().rawScoreRatioString(assignmentItem)
            penaltyLabel.text = String(assignmentItem.penalty)
            weightLabel.text = String(assignmentItem.weight)
            adjustedScoreLabel.text = GradeKeeper.calculate().adjustedScoreRatioString(assignmentItem)
            if let dateSecs = assignmentItem.dueDate {
                dueDateLabel.text = GradeKeeper.calculate().dateSecsFormatted(dateSecs)
            } else {
                dueDateLabel.text = "Not Specified"
            }
            if let dateSecs = assignmentItem.assignDate {
                assignDateLabel.text = GradeKeeper.calculate().dateSecsFormatted(dateSecs)
            } else {
                assignDateLabel.text = "Not Specified"
            }
            if let dateSecs = assignmentItem.gradedDate {
                gradedDateLabel.text = GradeKeeper.calculate().dateSecsFormatted(dateSecs)
            } else {
                gradedDateLabel.text = "Not Specified"
            }
            
            if let selectedCourse = GradeKeeper.currentUser.courses[GradeKeeper.selectedCourseID] {
                courseNameLabel.text = selectedCourse.courseName
                if let selectedCategory = selectedCourse.categories[GradeKeeper.selectedCategoryID] {
                    categoryNameLabel.text = selectedCategory.name
                }
                assignmentGradeLabel.text = GradeKeeper.calculate().gradeRecieved(assignmentItem, gradeScale: selectedCourse.gradeScale)
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            if indexPath.row == 0 {
                tableView.deselectRow(at: indexPath, animated: true)
                confirmDeleteAlert(callback: deleteAssignment);
            }
        }
    }
    
    func deleteAssignment(action: UIAlertAction) {
        GradeKeeper.assignments().delete(courseID: GradeKeeper.selectedCourseID, assignmentID: GradeKeeper.selectedAssignmentID) { (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "deleteAssignmentUnwindSegue", sender: nil)
                }
            } else {
                DispatchQueue.main.async {
                    GradeKeeper().errorAlert(self, error: error!)
                }
            }
            
        }
    }
    
    func confirmDeleteAlert(callback: @escaping (_ action: UIAlertAction) -> Void) {
        let alert = UIAlertController(title: "Delete Assignment", message: "Are you sure you want to delete this assignment?" , preferredStyle: .alert)
        
        alert.view.tintColor = GradeKeeper.themeColor
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: callback))

        self.present(alert, animated: true)
    }
    
    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
