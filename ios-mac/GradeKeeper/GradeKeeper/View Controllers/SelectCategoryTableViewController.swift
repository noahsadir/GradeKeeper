//
//  SelectCategoryTableViewController.swift
//  GradeKeeper
//
//  Created by Noah Sadir on 11/1/21.
//

import UIKit

class SelectCategoryTableViewController: UITableViewController {

    var selectedCourse: Course?
    var categoryIDs = [String]()
    var weights = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeCategories()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func initializeCategories() {
        if let course = GradeKeeper.currentUser.courses[GradeKeeper.selectedCourseID] {
            categoryIDs = [String]()
            for categoryItem in course.categories {
                weights = [Double]()
                categoryIDs.append(categoryItem.key)
            }
            selectedCourse = course
            tableView.reloadData()
            
        } else {
            self.removeFromParent()
            print("error retrieving class")
        }
    }
    
    @IBAction func cancelCreateCategoryUnwind(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func finishCreateCategoryUnwind(segue: UIStoryboardSegue) {
        initializeCategories()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryIDs.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        if let selectedCourse = selectedCourse {
            cell.textLabel?.text = selectedCourse.categories[categoryIDs[indexPath.row]]?.name
            if let weight = selectedCourse.categories[categoryIDs[indexPath.row]]?.weight {
                cell.detailTextLabel?.text = "Weight: " + String(weight)
            } else {
                cell.detailTextLabel?.text = "Weight: Unknown"
            }
            
        }

        // Configure the cell...

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        EditAssignmentTableViewController.categoryID = categoryIDs[indexPath.row]
        performSegue(withIdentifier: "categorySelectionUnwindSegue", sender: nil)
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
