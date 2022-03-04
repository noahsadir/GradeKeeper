//  ViewCourseDetailsTableViewController.swift
/*
 Copyright (c) 2021-2022 Noah Sadir

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class ViewCourseDetailsTableViewController: UITableViewController {

    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var courseCodeLabel: UILabel!
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var instructorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tintColor = GradeKeeper.themeColor
        self.navigationController?.navigationBar.tintColor = GradeKeeper.themeColor
        
        if let selectedCourse = GradeKeeper.currentUser.courses[GradeKeeper.selectedCourseID] {
            courseNameLabel.text = selectedCourse.courseName
            courseCodeLabel.text = selectedCourse.courseCode
            instructorLabel.text = selectedCourse.instructor ?? ""
            if let termForCourse = GradeKeeper.terms().forCourseID(courseID: GradeKeeper.selectedCourseID) {
                termLabel.text = termForCourse.title
            } else {
                
                termLabel.text = "None"
            }
            weightLabel.text = String(selectedCourse.weight)
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    @IBAction func courseDeleteClicked(_ sender: Any) {
        confirmDeleteAlert() { (action) in
            if let selectedCourse = GradeKeeper.currentUser.courses[GradeKeeper.selectedCourseID] {
                GradeKeeper.courses().delete(courseID: GradeKeeper.selectedCourseID) { (success, error) in
                    if success {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "deleteCourseUnwind", sender: nil)
                        }
                    } else {
                        GradeKeeper().errorAlert(self, error: error!)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    func confirmDeleteAlert(callback: @escaping (_ action: UIAlertAction) -> Void) {
        let alert = UIAlertController(title: "Delete Course", message: "Are you sure you want to delete this course?" , preferredStyle: .alert)
        
        alert.view.tintColor = GradeKeeper.themeColor
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: callback))

        self.present(alert, animated: true)
    }

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
