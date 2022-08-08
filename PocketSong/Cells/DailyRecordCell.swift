//
//  DailyRecordCell.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 6/19/22.
//

import UIKit


class DailyRecordCell: UITableViewCell {
    static let id = "DailyRecordCell"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var songItemCollectionView: UICollectionView!
    var recordDataList:[RecordData] = []
    var songImageList:[UIImage] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        print("override init")
        
    }
    
    // xib나 스토리보드에서 생성이 될때에는 해당 메소드를 통해서 객채가 생성됨
    // ex. let cell = tableView.dequeueReusableCell(withIdentifier: "id")
    required init?(coder: NSCoder) {
        // 이 함수 내에서 IBOutlet 을 통한 view를 접근하면 안된다. 해당 생성자는 IBOutlet과 같은 처리를 하는 시점이므로 해당 객체는 nil이다.
        print("required init")
        super.init(coder: coder)
    
    }
    
    //인터페이스 블더에서 객체가 init?(code:NSDecoder)로 초기화 된 후 호출된다.
    // 즉 IBOutlet과 같은 구성요소들이 모두 설정된 후 호출된다. 뷰의 초기작업을 여기서 해주면된다.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("awakeFromNib")
        songItemCollectionView.delegate = self
        songItemCollectionView.dataSource = self
        songItemCollectionView.showsHorizontalScrollIndicator = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        print("setSelected")
        // Configure the view for the selected state
    }
    
    func setCell(title:String, data:[RecordData]) {
        titleLabel.text = title
        recordDataList = data
        
    }
}

extension DailyRecordCell : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recordDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecordSongCell", for: indexPath) as! RecordSongCell
        var image : UIImage?
        let targetRecordData = recordDataList[indexPath.row]
        if let coverImageData = try? Data(contentsOf: targetRecordData.shazamData!.artworkURL!){
           image = UIImage(data: coverImageData)
        }else{
            image = UIImage(systemName: "music.mic.circle.fill")
        }
        
        cell.setCell(image: image!, title: targetRecordData.shazamData!.title!)
        
        return cell
    }
}
