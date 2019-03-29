
import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class AttendeeViewController: BaseController {
    // MARK: Global Constants
    let url = "https://core.craigproctor.com/ipad/attendees/all"
    
    // MARK: varbal Vars
    var attendeesArray : [Attendee] = [Attendee]()
    var filteredAttendees : [Attendee] = [Attendee]()
    var tableData : [Attendee] = [Attendee]()
    
    // MARK: Outlets
    @IBOutlet weak var searchBtn: UIButtonX!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var attendeesTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextFieldX!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var BuildLabel: UILabel!
    
    // MARK: Main Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        BuildLabel.text = "BUILD: 1903.26"
        configureView()
        getAttendees()
    }
    
    func getAttendees() {
        attendeesArray = []
        toggleNetworkIndicator(show: true)
        titleLabel.text = "Loading Registrants..."
        SVProgressHUD.show(withStatus: "Loading Registrants")
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                let attendeesJson : JSON = JSON(response.result.value!)
                for (_, attendeeData) in attendeesJson {
                    let attendeeModel = Attendee(data: attendeeData)
                    self.attendeesArray.append(attendeeModel)
                }
                self.tableData = self.attendeesArray
                self.reloadData()
                self.updateUI()
            } else {
                if let error = response.result.error {
                   SVProgressHUD.showError(withStatus: "Connection Issues - \(error)")
                }
            }
        }
    }
    
    func configureView() {
        attendeesTableView.delegate = self
        attendeesTableView.dataSource = self
        searchTextField.delegate = self
        
        searchTextField.alpha = 0
        attendeesTableView.alpha = 0
        searchBtn.alpha = 1
        loadingIndicator.alpha = 1
        searchTextField.setBottomBorder()
    }
    
    func updateUI() {
        UIView.animate(withDuration: 0.75, animations: {
            self.searchTextField.alpha = 1
            self.attendeesTableView.alpha = 1
            self.searchBtn.alpha = 1
            self.loadingIndicator.alpha = 0
        })
        SVProgressHUD.dismiss()
        toggleNetworkIndicator(show: false)
        titleLabel.text = "Search Registrants"
    }    


    // MARK: Segue Preform
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "selectAttendeeSegue") {
            let modal = segue.destination as! SignatureViewController
            let attendeeIndex = (attendeesTableView.indexPathForSelectedRow as IndexPath?)?.row
            
            //Deselect Row
            self.attendeesTableView.deselectRow(at: attendeesTableView.indexPathForSelectedRow!, animated: false)
            
            modal.attendee = tableData[attendeeIndex!]
        }
    }
}

// MARK: Tableview Delegate / Datasource
extension AttendeeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attendeeCell", for: indexPath)
        let data = tableData[indexPath.row]
        cell.textLabel?.text = data.name
        cell.detailTextLabel?.text = "\(data.city), \(data.state) - \(data.seatType)"
        
        return cell
    }
    
    func reloadData() {
        attendeesTableView.reloadData()
    }
}

// MARK: Textfield Search & Delegate
extension AttendeeViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let string2 = searchTextField.text {
            let string1 = string
            var finalString = ""
            if (string.count > 0) { // if it was not delete character
                finalString = string2 + string1
            } else if (string2.count > 0) { // if it was a delete character
                finalString = String(string2.dropLast())
            }
            searchAttendees(query: finalString)
        }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func searchAttendees(query: String = "") {
        if(query != ""){
            filteredAttendees = attendeesArray.filter { attendee in
                return attendee.name.lowercased().contains(query.lowercased())
            }
            tableData = filteredAttendees
            if(filteredAttendees.count == 0) {
                SVProgressHUD.showError(withStatus: "No Results Found")
            }
        } else {
            tableData = attendeesArray
        }
        
        self.reloadData()
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        
        searchTextField.resignFirstResponder()
        searchTextField.text = ""
        getAttendees()
        UIView.animate(withDuration: 0.5, animations: {
            self.searchTextField.alpha = 0
            self.attendeesTableView.alpha = 0
            
            self.loadingIndicator.alpha = 1
        })
    }
}

// MARK: Textfield Custom Styling
extension UITextFieldX {
    func setBottomBorder() {
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.gray.cgColor
        border.frame = CGRect(x:25, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.opacity = 0.25
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
