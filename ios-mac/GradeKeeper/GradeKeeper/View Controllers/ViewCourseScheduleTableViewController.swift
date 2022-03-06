//
//  CourseScheduleTableViewController.swift
//  Courseman
//
//  Created by Noah Sadir on 3/4/22.
//

import UIKit

class ViewCourseScheduleTableViewController: UITableViewController {
    
    var timeslots = [Timeslot]()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedCourse = GradeKeeper.currentUser.courses[GradeKeeper.selectedCourseID] {
            self.timeslots = selectedCourse.schedule
            self.tableView.reloadData()
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return timeslots.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeslotCell", for: indexPath) as! DoubleRightDetailTableViewCell
        
        let dayOfWeek = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        
        let timeslot = timeslots[indexPath.row]
        
        cell.titleLabel.text = dayOfWeek[timeslot.dayOfWeek % 7]
        
        let midnight: UInt64 = (UInt64(Date().timeIntervalSince1970) - (UInt64(Date().timeIntervalSince1970) % 86400)) * 1000
        
        let startInterval = midnight + UInt64(timeslot.startTime)
        
        let endInterval = midnight + UInt64(timeslot.endTime)
        
        cell.topDetailLabel.text = GradeKeeper.calculate().timeMillisFormatted(startInterval) + " - " + GradeKeeper.calculate().timeMillisFormatted(endInterval)
        
        cell.bottomDetailLabel.text = timeslot.description
        
        print(GradeKeeper.calculate().dateSecsFormatted(midnight))
        
        // Configure the cell...

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        GradeKeeper.selectedTimeslotIndex = indexPath.row
        performSegue(withIdentifier: "editScheduleSegue", sender: nil)
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
