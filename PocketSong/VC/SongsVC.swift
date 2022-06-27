//
//  SongsVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 12/6/21.
//

import UIKit

class SongsVC: UIViewController {
    
    @IBOutlet weak var recordSongTableView: UITableView!
    var recordDataDic:[String:RecordData]=[:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordSongTableView.delegate = self
        recordSongTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func getRecordDataPerDaily(){
        
    }
}

extension SongsVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyRecordCell") as? DailyRecordCell else { return DailyRecordCell() }
//
        cell.titleLabel.text = "ss \(indexPath.item)"
        cell.testImageView.image = UIImage(systemName: "pencil")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataCount = 3
        return dataCount
    }

//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return nil
//    }

//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        <#code#>
//    }
}
