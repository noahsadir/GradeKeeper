//
//  EditGradeTableViewController.swift
//  GradeKeeper
//
//  Created by Noah Sadir on 12/19/21.
//

import UIKit

class EditGradeTableViewController: UITableViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var editGradeButton: UIBarButtonItem!
    
    @IBOutlet weak var gradeIDTextField: UITextField!
    @IBOutlet weak var minScoreTextField: UITextField!
    @IBOutlet weak var maxScoreTextField: UITextField!
    @IBOutlet weak var creditTextField: UITextField!
    
    var selectedGradeID: String?
    var selectedGrade: Grade?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tintColor = GradeKeeper.themeColor
        self.navigationController?.navigationBar.tintColor = GradeKeeper.themeColor
        
        selectedGradeID = ViewGradeScaleTableViewController.selectedGradeID
        
        
        if let selectedGradeID = selectedGradeID {
            self.title = "Edit Grade"
            gradeIDTextField.isEnabled = false
            gradeIDTextField.textColor = .secondaryLabel
            selectedGrade = GradeKeeper.currentUser.courses[GradeKeeper.selectedCourseID]?.gradeScale[selectedGradeID]
            if let selectedGrade = selectedGrade {
                gradeIDTextField.text = selectedGradeID
                minScoreTextField.text = String(selectedGrade.minScore)
                if let maxScore = selectedGrade.maxScore {
                    maxScoreTextField.text = String(maxScore)
                } else {
                    maxScoreTextField.text = ""
                }
                creditTextField.text = String(selectedGrade.credit)
            }
        } else {
            self.title = "New Grade"
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @IBAction func editGradeButtonClicked(_ sender: Any) {
        if let gradeID = gradeIDTextField.text, let minScoreString = minScoreTextField.text {
            var maxScore: Double?
            var credit: Double?
            if let maxScoreString = maxScoreTextField.text {
                if maxScoreString != "" {
                    maxScore = Double(maxScoreString)
                }
            }
            
            if let creditString = creditTextField.text {
                if creditString != "" {
                    credit = Double(creditString)
                }
            }
            
            if let credit = credit, let minScore = Double(minScoreString), gradeID != "" && minScoreString != "" {
                
                if let selectedGradeID = selectedGradeID {
                    GradeKeeper.grade().modify(courseID: GradeKeeper.selectedCourseID, gradeID: gradeID, minScore: minScore, maxScore: maxScore, credit: credit) { (success, error) in
                        if success {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "finishGradeEditUnwind", sender: nil)
                            }
                        } else {
                            GradeKeeper().errorAlert(self, error: error!)
                        }
                        
                    }
                } else {
                    GradeKeeper.grade().create(courseID: GradeKeeper.selectedCourseID, gradeID: gradeID, minScore: minScore, maxScore: maxScore, credit: credit) { (success, error) in
                        if success {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "finishGradeEditUnwind", sender: nil)
                            }
                        } else {
                            GradeKeeper().errorAlert(self, error: error!)
                        }
                        
                    }
                }
                
            }
            
            
        } else {
            print("missing fields for grade")
        }
        if gradeIDTextField.text != "" && gradeIDTextField.text != nil && minScoreTextField.text != "" && minScoreTextField.text != nil {
            
        }
    }
    // MARK: - Table view data source


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
