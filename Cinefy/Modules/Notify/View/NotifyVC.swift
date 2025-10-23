//
//  NotifyVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 5.08.2025.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class NotifyVC: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnDeleteLog: UIButton!
    
    let firebaseModel = FirebaseModel()
    let db = Firestore.firestore()
    let userId = Auth.auth().currentUser?.uid ?? ""
    
    var moviesFavoritesLogs: [[String: Any]] = []
    let darkColor = UIColor(red: 8/255, green: 14/255, blue: 36/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = darkColor
        view.backgroundColor = darkColor
        fetchLogs()
        
        let emptyLabel = UILabel()
        emptyLabel.text = "Henüz bildirim yok.."
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        let bgView = UIView(frame: tableView.bounds)
        bgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bgView.addSubview(emptyLabel)
        tableView.backgroundView = bgView

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: tableView.backgroundView!.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.backgroundView!.centerYAnchor)
        ])
        
        tableView.backgroundView?.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLogs()
        updateEmptyState()
    }
    
    func fetchLogs() {
        db.collection("users")
            .document(userId)
            .collection("notifications")
            .order(by: "createDate", descending: true)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("Bildirimler alınamadı: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                // 🔹 Bildirimleri diziye çevir
                self.moviesFavoritesLogs = documents.map { $0.data() }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateEmptyState()
                    self.btnDeleteLog.isHidden = self.moviesFavoritesLogs.isEmpty
                }
            }
    }
    
    func updateEmptyState() {
        if moviesFavoritesLogs.count > 0 {
            tableView.backgroundView?.isHidden = true
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView?.isHidden = false
            tableView.separatorStyle = .singleLine
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesFavoritesLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logsCell", for: indexPath) as! LogsTableCell
        let movieLog = moviesFavoritesLogs[indexPath.row]
        cell.logTitle.text = movieLog["notifyText"] as? String ?? (movieLog["title"] as? String ?? "")
        cell.selectionStyle = .none
        cell.backgroundColor = darkColor
        cell.logTitle.textColor = .white
        
        if movieLog["isDeletion"] as? Bool ?? false {
            cell.logImg.image = UIImage(systemName: "minus")
            cell.logImg.tintColor = .red
        } else {
            cell.logImg.image = UIImage(systemName: "plus")
            cell.logImg.tintColor = .green
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    @IBAction func btnDeleteLogs(_ sender: Any) {
        if moviesFavoritesLogs.count > 0 {
            firebaseModel.deleteAllNotifications(userId: userId) { success in
                if success {
                    DispatchQueue.main.async {
                        self.moviesFavoritesLogs.removeAll()
                        self.tableView.reloadData()
                        self.updateEmptyState()
                        self.btnDeleteLog.isHidden = true
                    }
                }
            }
        } else {
            UIHelper.makeAlert(on: self, title: "Uyarı!", message: "Bildirim bulunmamaktadır..")
        }
    }
}
