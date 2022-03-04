//  MainTableViewController.swift
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

// Pretty much the central view of the application.
// Contains all the courses and relevant links (schedule, profile, etc.)

import UIKit

class MainTableViewController: UITableViewController{
    
    var courseIDs = [[String]]()
    var termIDs = [String]()
    
    @IBOutlet weak var accountButton: UIBarButtonItem!
    @IBOutlet weak var addCourseButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tintColor = GradeKeeper.themeColor
        self.navigationController?.navigationBar.tintColor = GradeKeeper.themeColor
        
        initialLoad()
        
    }
    
    func initialLoad() {
        GradeKeeper.storage.user().load()
        GradeKeeper.courses().load() { (success, error) in
            if success {
                self.loadGradebook()
                GradeKeeper.storage.user().save()
            } else if error!.code == 401 {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "promptLoginSegue", sender: nil)
                }
            } else {
                GradeKeeper().errorAlert(self, error: error!, allowsCancel: false) { (action) in
                    DispatchQueue.main.async {
                        self.initialLoad()
                    }
                }
            }
        }
    }
    
    // I know the purpose of unwind functions, but my goodness does this look ugly.
    @IBAction func accountButtonClicked(_ sender: Any) {
        
    }
    
    @IBAction func loginUnwind(unwindSegue: UIStoryboardSegue) {
        initialLoad()
    }
    
    @IBAction func createCourseUnwind(unwindSegue: UIStoryboardSegue) {
        loadGradebook()
    }
    
    @IBAction func createTermUnwind(unwindSegue: UIStoryboardSegue) {
        loadGradebook()
    }
    
    @IBAction func deleteTermUnwind(unwindSegue: UIStoryboardSegue) {
        loadGradebook()
    }
    
    @IBAction func deleteCourseUnwind(unwindSegue: UIStoryboardSegue) {
        loadGradebook()
    }
    
    @IBAction func cancelCreateCourseUnwind(unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func cancelCreateTermUnwind(unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func cancelViewTermUnwind(unwindSegue: UIStoryboardSegue) {
        
    }
    
    /// 
    func loadGradebook() {
        self.courseIDs = [[String]]()
        var sortedCourseIDs = GradeKeeper.courses().sorted(courses: GradeKeeper.currentUser.courses)
        self.termIDs = GradeKeeper.terms().sorted(terms: GradeKeeper.currentUser.terms)
        
        
        for termID in self.termIDs {
            self.courseIDs.append([String]())
            let term = GradeKeeper.currentUser.terms[termID]!
            
            var i = 0
            while i < sortedCourseIDs.count {
                if term.courseIDs.contains(sortedCourseIDs[i]) {
                    self.courseIDs[self.courseIDs.count - 1].append(sortedCourseIDs[i])
                    sortedCourseIDs.remove(at: i)
                    i -= 1
                }
                i += 1
            }
        }
        
        if sortedCourseIDs.count > 0 {
            self.courseIDs.append([String]())
            self.courseIDs[self.courseIDs.count - 1] = sortedCourseIDs
        }
        
        DispatchQueue.main.async {
            //print(GradeKeeper().userToJSON())
            self.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.courseIDs.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (self.courseIDs[section].count + 1)
    }

    /**/
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = CourseSelectionTableViewCell()
        
        var termHeaderCell = TermHeaderTableViewCell()
        
        if indexPath.row == 0 {
            termHeaderCell = tableView.dequeueReusableCell(withIdentifier: "termHeaderCell", for: indexPath) as! TermHeaderTableViewCell
            termHeaderCell.infoButton.tag = -1
            if indexPath.section < termIDs.count {
                
                if let term = GradeKeeper.currentUser.terms[termIDs[indexPath.section]] {
                    termHeaderCell.infoButton.isHidden = false
                    termHeaderCell.title.text = term.title
                    termHeaderCell.infoButton.tag = indexPath.section
                    termHeaderCell.infoButton.addTarget(self, action: #selector(viewTermButtonClicked), for: .touchUpInside)

                } else {
                    termHeaderCell.title.text = "Unknown Term"
                }
            } else {
                termHeaderCell.infoButton.isHidden = true
                termHeaderCell.title.text = "Miscellaneous"
            }
            
            return termHeaderCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCourseCell", for: indexPath) as! CourseSelectionTableViewCell
            let courseID = courseIDs[indexPath.section][indexPath.row - 1]
            if let selectedCourse = GradeKeeper.currentUser.courses[courseID] {
                cell.titleLabel.text = selectedCourse.courseName
                cell.subtitleLabel.text = selectedCourse.courseCode
            }

            // Configure the cell...

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 45
        }
        return 60
    }
    
    
    @objc func viewTermButtonClicked(sender: UIButton?) {
        if let sender = sender {
            if sender.tag >= 0 && sender.tag < termIDs.count {
                GradeKeeper.selectedTermID = termIDs[sender.tag]
                viewTerm()
            }
        }
    }
    
    func viewTerm() {
        self.performSegue(withIdentifier: "viewTermSegue", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isUserInteractionEnabled = false
        if indexPath.row == 0 {
            tableView.isUserInteractionEnabled = true
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            GradeKeeper.selectedCourseID = courseIDs[indexPath.section][indexPath.row - 1]
            GradeKeeper.assignments().load(courseID: GradeKeeper.selectedCourseID) { (success, error) in
                DispatchQueue.main.async {
                    tableView.isUserInteractionEnabled = true
                    if success {
                        self.performSegue(withIdentifier: "showAssignmentsDetailSegue", sender: nil)
                    } else {
                        GradeKeeper().errorAlert(self, error: error!)
                    }
                }
            }
        }
    }
    
    @IBAction func presentActionSheet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.barButtonItem = addCourseButton
        alert.popoverPresentationController?.sourceView = self.view
        
        
        alert.view.tintColor = GradeKeeper.themeColor
            
            alert.addAction(UIAlertAction(title: "New Course", style: .default , handler:{ (UIAlertAction)in
                GradeKeeper.selectedCourseID = ""
                self.performSegue(withIdentifier: "newCourseSegue", sender: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "New Term", style: .default , handler:{ (UIAlertAction)in
                GradeKeeper.selectedTermID = ""
                self.performSegue(withIdentifier: "newTermSegue", sender: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            
            //uncomment for iPad Support
            //alert.popoverPresentationController?.sourceView = self.view

            self.present(alert, animated: true, completion: {
                print("completion block")
            })
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
