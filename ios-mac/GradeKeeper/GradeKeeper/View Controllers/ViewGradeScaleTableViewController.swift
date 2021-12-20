//
//  ViewGradeScaleTableViewController.swift
//  GradeKeeper
//
//  Created by Noah Sadir on 12/19/21.
//

import UIKit

class ViewGradeScaleTableViewController: UITableViewController {

    @IBOutlet weak var addGradeButton: UIBarButtonItem!
    
    var selectedCourse: Course?
    var gradeIDs = [String]()
    
    static var selectedGradeID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tintColor = GradeKeeper.themeColor
        self.navigationController?.navigationBar.tintColor = GradeKeeper.themeColor
        
        loadGrades()
       
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func addGradeButtonClicked(_ sender: Any) {
        ViewGradeScaleTableViewController.selectedGradeID = nil
        performSegue(withIdentifier: "editGradeScale", sender: nil)
    }
    
    func loadGrades() {
        gradeIDs = [String]()
        selectedCourse = GradeKeeper.currentUser.courses[GradeKeeper.selectedCourseID]
        if let selectedCourse = selectedCourse {
            for grade in selectedCourse.gradeScale {
                gradeIDs.append(grade.key)
                gradeIDs = gradeIDs.sorted { (first, second) -> Bool in
                    if let firstGrd = selectedCourse.gradeScale[first], let secondGrd = selectedCourse.gradeScale[second] {
                        return firstGrd.minScore > secondGrd.minScore
                    }
                    return first < second
                }
            }
        }
    }
    
    @IBAction func cancelGradeEditUnwind(unwindSegue: UIStoryboardSegue) {
        ViewGradeScaleTableViewController.selectedGradeID = nil
    }
    
    @IBAction func finishGradeEditUnwind(unwindSegue: UIStoryboardSegue) {
        loadGrades()
        tableView.reloadData()
        ViewGradeScaleTableViewController.selectedGradeID = nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return gradeIDs.count
    }

    /**/
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gradeCell", for: indexPath) as! GradeScaleTableViewCell
        
        if let selectedCourse = selectedCourse {
            cell.gradeLabel.text = gradeIDs[indexPath.row]
            let grade = selectedCourse.gradeScale[gradeIDs[indexPath.row]]!
            if let maxScore = grade.maxScore {
                cell.rangeLabel.text = String(grade.minScore) + " - " + String(maxScore)
            } else {
                cell.rangeLabel.text = String(grade.minScore) + "+"
            }
            
            cell.creditLabel.text = "Credit: " + String(grade.credit)
        }

        // Configure the cell...

        return cell
    }
    /**/

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ViewGradeScaleTableViewController.selectedGradeID = gradeIDs[indexPath.row]
        performSegue(withIdentifier: "editGradeScale", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
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
