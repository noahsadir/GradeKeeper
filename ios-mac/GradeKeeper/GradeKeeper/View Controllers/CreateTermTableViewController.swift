//  CreateTermTableViewController.swift
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

class CreateTermTableViewController: UITableViewController, UITextFieldDelegate {

    
    @IBOutlet weak var termTitleTextField: UITextField!
    
    @IBOutlet weak var startDateSwitch: UISwitch!
    @IBOutlet weak var endDateSwitch: UISwitch!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        termTitleTextField.delegate = self
        
        GradeKeeper().tapToDismissKeyboard(view)
        
        self.view.tintColor = GradeKeeper.themeColor
        self.navigationController?.navigationBar.tintColor = GradeKeeper.themeColor
        
        if let selectedTerm = GradeKeeper.currentUser.terms[GradeKeeper.selectedTermID] {
            self.title = "Edit Term"
            
            termTitleTextField.text = selectedTerm.title
            
            if let startDate = selectedTerm.startDate {
                startDateSwitch.isOn = true;
                startDatePicker.date = Date(timeIntervalSince1970: TimeInterval(startDate))
            } else {
                startDateSwitch.isOn = false;
            }
            
            if let endDate = selectedTerm.endDate {
                endDateSwitch.isOn = true;
                endDatePicker.date = Date(timeIntervalSince1970: TimeInterval(endDate))
            } else {
                endDateSwitch.isOn = false;
            }
            
            
            
        } else {
            self.title = "New Term"
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func createTermButtonClicked(_ sender: Any) {
        if let title = termTitleTextField.text {
            let startDate = startDateSwitch.isOn ? UInt64(startDatePicker.date.timeIntervalSince1970) : nil
            let endDate = endDateSwitch.isOn ? UInt64(endDatePicker.date.timeIntervalSince1970) : nil
            
            if let selectedTerm = GradeKeeper.currentUser.terms[GradeKeeper.selectedTermID] {
                
                GradeKeeper.terms().modify(termID: GradeKeeper.selectedTermID, termTitle: title, startDate: startDate, endDate: endDate) { (success, error) in
                    if success {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "createTermUnwind", sender: nil)
                        }
                        
                    } else {
                        GradeKeeper().errorAlert(self, error: error!)
                    }
                }
                
            } else {
                GradeKeeper.terms().create(termTitle: title, startDate: startDate, endDate: endDate) { (success, error) in
                    if success {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "createTermUnwind", sender: nil)
                        }
                        
                    } else {
                        GradeKeeper().errorAlert(self, error: error!)
                    }
                }
            }
        } else {
            
        }
    }

    @IBAction func startDateSwitchChanged(_ sender: Any) {
        tableView.reloadData()
    }
    
    @IBAction func endDateSwitchChanged(_ sender: Any) {
        tableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of section
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        } else if section == 1 {
            if endDateSwitch.isOn {
                return 4
            }
            return 3
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if indexPath.row == 1 && !startDateSwitch.isOn {
                return 0
            } else if indexPath.row == 3 && !endDateSwitch.isOn {
                return 0
            }
        }
        return 45
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
