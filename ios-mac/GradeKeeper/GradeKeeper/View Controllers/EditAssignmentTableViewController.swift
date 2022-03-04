//  EditAssignmentTableViewController.swift
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

class EditAssignmentTableViewController: UITableViewController, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var maxScoreTextField: UITextField!
    @IBOutlet weak var rawScoreTextField: UITextField!
    @IBOutlet weak var penaltyTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var dueDateTableViewCell: UITableViewCell!
    @IBOutlet weak var assignDateTableViewCell: UITableViewCell!
    @IBOutlet weak var gradedDateTableViewCell: UITableViewCell!
    var selectedRow = 0
    
    @IBOutlet weak var dueDatePickerCell: UITableViewCell!
    @IBOutlet weak var assignDatePickerCell: UITableViewCell!
    @IBOutlet weak var gradedDatePickerCell: UITableViewCell!
    
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var assignDatePicker: UIDatePicker!
    @IBOutlet weak var gradedDatePicker: UIDatePicker!
    
    @IBOutlet weak var dueDateSwitch: UISwitch!
    @IBOutlet weak var assignDateSwitch: UISwitch!
    @IBOutlet weak var gradedDateSwitch: UISwitch!
    
    static var categoryID = ""
    
    @IBOutlet weak var categoryTableViewCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.image = UIImage(systemName: "xmark")
        doneButton.image = UIImage(systemName: "checkmark")
        
        self.tableView.estimatedRowHeight = 45
        
        self.tableView.tintColor = GradeKeeper.themeColor
        self.navigationController?.navigationBar.tintColor = GradeKeeper.themeColor
        
        if let course = GradeKeeper.currentUser.courses[GradeKeeper.selectedCourseID] {
            var currentLargestWeight: Double? = 0
            
            if let assignmentItem = GradeKeeper.currentUser.assignments[GradeKeeper.selectedAssignmentID] {
                
                titleTextField.text = assignmentItem.title
                descriptionTextField.text = assignmentItem.description
                EditAssignmentTableViewController.categoryID = GradeKeeper.selectedCategoryID
                if let act = assignmentItem.actScore {
                    rawScoreTextField.text = String(act)
                }
                
                if let max = assignmentItem.maxScore {
                    maxScoreTextField.text = String(max)
                }
                
                if assignmentItem.penalty != 0 {
                    penaltyTextField.text = String(assignmentItem.penalty)
                }
                
                weightTextField.text = String(assignmentItem.weight)
                
                if let dueDate = assignmentItem.dueDate {
                    dueDateSwitch.isOn = true
                    dueDatePicker.date = Date(timeIntervalSince1970: TimeInterval(dueDate))
                } else {
                    dueDateSwitch.isOn = false
                }
                
                if let assignDate = assignmentItem.assignDate {
                    assignDateSwitch.isOn = true
                    assignDatePicker.date = Date(timeIntervalSince1970: TimeInterval(assignDate))
                } else {
                    assignDateSwitch.isOn = false
                }
                
                if let gradedDate = assignmentItem.gradedDate {
                    gradedDateSwitch.isOn = true
                    gradedDatePicker.date = Date(timeIntervalSince1970: TimeInterval(gradedDate))
                } else {
                    gradedDateSwitch.isOn = false
                }
            } else if let defaultCategoryID = course.defaultCategoryID {
                EditAssignmentTableViewController.categoryID = defaultCategoryID
            } else {
                for categoryItem in course.categories {
                    if let weight = currentLargestWeight {
                        if categoryItem.value.weight > weight {
                            EditAssignmentTableViewController.categoryID = categoryItem.key
                            currentLargestWeight = categoryItem.value.weight
                        }
                    } else {
                        EditAssignmentTableViewController.categoryID = categoryItem.key
                        currentLargestWeight = categoryItem.value.weight
                    }
                    
                }
            }
            
            categoryTableViewCell.textLabel?.text = course.categories[EditAssignmentTableViewController.categoryID]?.name
        }
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func unwindFromCategorySelection(unwindSegue: UIStoryboardSegue) {
        if let course = GradeKeeper.currentUser.courses[GradeKeeper.selectedCourseID] {
            
            categoryTableViewCell.textLabel?.text = course.categories[EditAssignmentTableViewController.categoryID]?.name
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 4 {
            if indexPath.row == 0 {
                dueDateSwitch.isOn = !dueDateSwitch.isOn
                dueDateSwitchChanged(tableView)
            } else if indexPath.row == 2 {
                assignDateSwitch.isOn = !assignDateSwitch.isOn
                assignDateSwitchChanged(tableView)
            } else if indexPath.row == 4 {
                gradedDateSwitch.isOn = !gradedDateSwitch.isOn
                gradedDateSwitchChanged(tableView)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func dueDateSwitchChanged(_ sender: Any) {
        tableView.reloadData()
    }
    
    @IBAction func assignDateSwitchChanged(_ sender: Any) {
        tableView.reloadData()
    }
    
    @IBAction func gradedDateSwitchChanged(_ sender: Any) {
        tableView.reloadData()
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        let dueDate = dueDateSwitch.isOn ? UInt64(dueDatePicker.date.timeIntervalSince1970) : nil
        let assignDate = assignDateSwitch.isOn ? UInt64(assignDatePicker.date.timeIntervalSince1970) : nil
        
        let gradedDate = gradedDateSwitch.isOn ? UInt64(gradedDatePicker.date.timeIntervalSince1970) : nil
        
        var actScore: Double?
        var maxScore: Double?
        var weight: Double?
        var penalty: Double?
        
        if let text = rawScoreTextField.text {
            actScore = Double(text)
        }
        
        if let text = maxScoreTextField.text {
            maxScore = Double(text)
        }
        
        if let text = weightTextField.text {
            weight = Double(text)
        }
        
        if let text = penaltyTextField.text {
            penalty = Double(text)
        }
        
        if GradeKeeper.selectedAssignmentID != "" {
            GradeKeeper.assignments().modify(courseID: GradeKeeper.selectedCourseID, categoryID: EditAssignmentTableViewController.categoryID, assignmentID: GradeKeeper.selectedAssignmentID, title: titleTextField.text, description: descriptionTextField.text, gradeID: nil, actScore: actScore, maxScore: maxScore, weight: weight, penalty: penalty, dueDate: dueDate, assignDate: assignDate, gradedDate: gradedDate) { (success, error) in
                
                if success {
                    DispatchQueue.main.async {
                        print("successfully edited assignment")
                        self.performSegue(withIdentifier: "finishEditAssignmentUnwindSegue", sender: nil)
                    }
                } else {
                    GradeKeeper().errorAlert(self, error: error!)
                }
            }
        } else {
            GradeKeeper.assignments().create(courseID: GradeKeeper.selectedCourseID, categoryID: EditAssignmentTableViewController.categoryID, title: titleTextField.text, description: descriptionTextField.text, gradeID: nil, actScore: actScore, maxScore: maxScore, weight: weight, penalty: penalty, dueDate: dueDate, assignDate: assignDate, gradedDate: gradedDate) { (success, error) in
                
                if success {
                    DispatchQueue.main.async {
                        print("successfully added assignment")
                        self.performSegue(withIdentifier: "finishEditAssignmentUnwindSegue", sender: nil)
                    }
                } else {
                    GradeKeeper().errorAlert(self, error: error!)
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 4 {
            if indexPath.row == 1 && !dueDateSwitch.isOn {
                return 0
            } else if indexPath.row == 3 && !assignDateSwitch.isOn {
                return 0
            } else if indexPath.row == 5 && !gradedDateSwitch.isOn {
                return 0
            }
        }
        return 45
    }
    // MARK: - Table view data source
    
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }*/
    
    
    /*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }*/

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
