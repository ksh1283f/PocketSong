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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordSongTableView.delegate = self
        recordSongTableView.dataSource = self
        // Do any additional setup after loading the view.
        
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor.gray
//        self.tabBarController?.tabBar.standardAppearance = appearance;
//        self.tabBarController?.tabBar.scrollEdgeAppearance = self.tabBarController?.tabBar.standardAppearance
           
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("[SongVC] viewWillAppear")
        getRecordDataPerDaily()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = self.title
       
    }
    
    func getRecordDataPerDaily(){
        DataController.dbOpen(caller: String(describing: self)){ dataList in
            if !recordDataDic.isEmpty{
                recordDataDic.removeAll()
            }
            
            let createdTimeDataSet = Set(dataList.map{$0.locationData!}.map{$0.createdTimeString!.split(separator: " ")[0]})
            
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
}

extension SongsVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyRecordCell") as? DailyRecordCell else { return DailyRecordCell() }

        let dayList = recordDataDic.keys.sorted(by: <)

        let title = dayList[indexPath.item]
        let recordDataList = recordDataDic[title] ?? []
        cell.setCell(title: title, data: recordDataList)
        print("[SongVC] cellForRowAt: \(title)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("[SongVC] numberOfRowInSection \(recordDataDic.count)")
        return recordDataDic.count
    }
}
