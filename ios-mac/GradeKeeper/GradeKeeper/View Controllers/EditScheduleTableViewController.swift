//
//  EditScheduleTableViewController.swift
//  Courseman
//
//  Created by Noah Sadir on 3/6/22.
//

import UIKit

class EditScheduleTableViewController: UITableViewController {

    @IBOutlet weak var dayOfWeekPicker: UIButton!
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var customDateSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dayOfWeekMenu = UIMenu(title: "", children: [
            UIAction(title: "Monday", handler: {(_) in }),
            UIAction(title: "Tuesday", handler: {(_) in }),
            UIAction(title: "Wednesday", handler: {(_) in }),
            UIAction(title: "Thursday", handler: {(_) in }),
            UIAction(title: "Friday", handler: {(_) in }),
            UIAction(title: "Saturday", handler: {(_) in }),
            UIAction(title: "Sunday", handler: {(_) in })
        ])
        
        dayOfWeekPicker.menu = dayOfWeekMenu
        
        if let timeslot = GradeKeeper.currentUser.courses[GradeKeeper.selectedCourseID]?.schedule[GradeKeeper.selectedTimeslotIndex] {
            let selectedAction = dayOfWeekMenu.children[3] as! UIAction
            selectedAction.state = .on
        
            
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 3
        } else if section == 1 {
            if customDateSwitch.isOn {
                return 4
            } else {
                return 3
            }
        }
        return 0
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
