//  ViewTermTableViewController.swift
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

class ViewTermTableViewController: UITableViewController {

    @IBOutlet weak var termTitleLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedTerm = GradeKeeper.currentUser.terms[GradeKeeper.selectedTermID] {
            self.title = selectedTerm.title
            self.view.tintColor = GradeKeeper.themeColor
            self.navigationController?.navigationBar.tintColor = GradeKeeper.themeColor
            termTitleLabel.text = selectedTerm.title
            
            if let startDate = selectedTerm.startDate {
                startDateLabel.text = GradeKeeper.calculate().dateSecsFormatted(startDate)
            } else {
                startDateLabel.text = "N/A"
            }
            
            if let endDate = selectedTerm.endDate {
                endDateLabel.text = GradeKeeper.calculate().dateSecsFormatted(endDate)
            } else {
                endDateLabel.text = "N/A"
            }
        } else {
            deleteButton.isEnabled = false
            editButton.isEnabled = false
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @IBAction func deleteButtonClicked(_ sender: Any) {
        confirmDeleteAlert() { action in
            GradeKeeper.terms().delete(termID: GradeKeeper.selectedTermID) { (success, error) in
                
                if success {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "deleteTermUnwind", sender: nil)
                    }
                } else {
                    GradeKeeper().errorAlert(self, error: error!)
                }
            }
        }
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func confirmDeleteAlert(callback: @escaping (_ action: UIAlertAction) -> Void) {
        if let selectedTerm = GradeKeeper.currentUser.terms[GradeKeeper.selectedTermID] {
            let alert = UIAlertController(title: "Delete Term", message: "Are you sure you want to delete term \"" + selectedTerm.title + "\"?" , preferredStyle: .alert)
            
            alert.view.tintColor = GradeKeeper.themeColor
            
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: callback))

            self.present(alert, animated: true)
        } else {
            deleteButton.isEnabled = false
            editButton.isEnabled = false
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
