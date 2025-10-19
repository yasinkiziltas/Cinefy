//
//  NotifyVC.swift
//  Cinefy
//
//  Created by Yasin Kızıltaş on 5.08.2025.
//

import UIKit

class NotifyVC: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnDeleteLog: UIButton!
    var moviesFavoritesLogs: [MoviesLogs] = []
    let darkColor = UIColor(red: 8/255, green: 14/255, blue: 36/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = darkColor
        view.backgroundColor = darkColor
        fetchLogs()
        
        let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        emptyLabel.text = "Henüz bildirim yok.."
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        tableView.backgroundView = emptyLabel
        tableView.backgroundView?.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLogs()
        updateEmptyState()
        
        if moviesFavoritesLogs.count > 0 {
            btnDeleteLog.isHidden = false
        } else {
            btnDeleteLog.isHidden = true
        }
        

    }
    
    func fetchLogs() {
        moviesFavoritesLogs = CoreDataManager.shared.getFavoriteMovieLogs()
        tableView.reloadData()
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
        cell.logTitle.text = movieLog.movieName
        cell.selectionStyle = .none
        cell.backgroundColor = darkColor
        cell.logTitle.textColor = .white
        
        if movieLog.isDeletion {
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
            CoreDataManager.shared.deleteAllFavoriteMovieLogs(from: self)
            fetchLogs()
        } else {
            UIHelper.makeAlert(on: self, title: "Uyarı!", message: "Bildirim bulunmamaktadır..")
        }
    }
}
