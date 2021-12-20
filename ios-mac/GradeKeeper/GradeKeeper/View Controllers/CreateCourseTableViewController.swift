//
//  CreateCourseTableViewController.swift
//  GradeKeeper
//
//  Created by Noah Sadir on 12/19/21.
//

import UIKit

class CreateCourseTableViewController: UITableViewController {

    @IBOutlet weak var cancelCreateCourseButton: UIBarButtonItem!
    @IBOutlet weak var createCourseButton: UIBarButtonItem!
    
    @IBOutlet weak var courseNameTextField: UITextField!
    @IBOutlet weak var courseCodeTextField: UITextField!
    @IBOutlet weak var instructorNameTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    static var termID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelCreateCourseButton.image = UIImage(systemName: "xmark")
        createCourseButton.image = UIImage(systemName: "checkmark")
        
        self.tableView.tintColor = GradeKeeper.themeColor
        self.navigationController?.navigationBar.tintColor = GradeKeeper.themeColor

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    @IBAction func createCourseButtonClicked(_ sender: Any) {
        if courseNameTextField.text != nil && courseNameTextField.text != "" {
            GradeKeeper.courses().create(courseName: courseNameTextField.text!, courseCode: courseCodeTextField.text, color: 1, weight: Double(weightTextField.text ?? "0")) { (success, error) in
                if success {
                    GradeKeeper.courses().load() { (loadSucc, loadErr) in
                        if loadSucc {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "createCourseUnwind", sender: nil)
                            }
                        } else {
                            GradeKeeper().errorAlert(self, error: loadErr!)
                        }
                    }
                } else {
                    GradeKeeper().errorAlert(self, error: error!)
                }
                
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
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
