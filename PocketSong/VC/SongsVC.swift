//
//  SongsVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 12/6/21.
//

import UIKit

class SongsVC: UIViewController {
    
    @IBOutlet weak var recordSongTableView: UITableView!
    // todo convert dic's type [String:RecordData] to [String:[RecordData]]
    var recordDataDic:[String:[RecordData]]=[:]
    var dayList:[String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordSongTableView.delegate = self
        recordSongTableView.dataSource = self
        self.navigationItem.title = self.title
        
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor.gray
//        self.tabBarController?.tabBar.standardAppearance = appearance;
//        self.tabBarController?.tabBar.scrollEdgeAppearance = self.tabBarController?.tabBar.standardAppearance
           
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        recordSongTableView.
        getRecordDataPerDaily()
        dayList = recordDataDic.keys.sorted(by: <)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func getRecordDataPerDaily(){
        DataController.dbOpen(caller: String(describing: self)){ dataList in
            if !recordDataDic.isEmpty{
                recordDataDic.removeAll()
            }
            
            // todo check values
            let createdTimeDataSet = Set(dataList.map{$0.locationData!}
                .map{$0.createdTimeString!.split(separator: " ")[0]})
            
            let unwrappedLocationData = dataList.map{$0.locationData!}
            
            for key in createdTimeDataSet {
                // 1. 키에 맞는 값을 로케이션에서 찾고
                // 2. 찾은 값을 기준으로 다른 모든 값들을 조립해서
                // 3. 새로운 레코드 데이터 생성 및 삽입
                
                let mainKey = String(key)
                let newRecordData = dataList.filter{$0.locationData!.createdTimeString!.contains(mainKey)}
//                print("------------------------")
//                print("[SongVC] key =\(key)")
                
                for record in newRecordData{
                    if !recordDataDic.keys.contains(mainKey){
                        recordDataDic[mainKey] = []
                    }
                    
                    recordDataDic[mainKey]?.append(record)
                }
            }
            
            DispatchQueue.main.async {
                self.recordSongTableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let recordData = sender as? RecordData else { return }
        if let id = segue.identifier, id == "segueToMyMemoryDetail"{
            if let detailVC = segue.destination as? MyInformationDetailVC{
                detailVC.setRecordData(recordData: recordData)
                detailVC.removalDelegate = self
            }
        }
    }
}

extension SongsVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyRecordCell") as? DailyRecordCell else {
            return DailyRecordCell()
        }
        cell.backgroundColor = UIColor(hex: 0x009051)
        let title = dayList[indexPath.row]
        let recordDataList = recordDataDic[title] ?? []
        
        cell.setCell(title: title, data: recordDataList, clickEvent: self)
        cell.songItemCollectionView.scrollToItem(at: IndexPath(item: -1, section: 0), at: .init(rawValue: 0), animated: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordDataDic.count
    }
}

extension SongsVC : PostProcessCellClickEvent {
    func onClickedBtnCell(recordData: RecordData) {
        self.performSegue(withIdentifier: "segueToMyMemoryDetail", sender: recordData)
        
        // todo implement
    }
}

extension SongsVC:PostProcessOfRemoveRecord{
    func updateRemoval(isRemoval:Bool) {
        getRecordDataPerDaily()
        dayList = recordDataDic.keys.sorted(by: <)
    }
}
