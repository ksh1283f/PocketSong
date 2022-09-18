//
//  DailyRecordCell.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 6/19/22.
//

import UIKit
import Kingfisher


class DailyRecordCell: UITableViewCell {
    static let id = "DailyRecordCell"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var songItemCollectionView: UICollectionView!
    var recordDataList:[RecordData] = []
    var songImageList:[UIImage] = []
    
    var clickEvent:PostProcessCellClickEvent?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        print("[DailyRecordCell] override init:  \(self.hash)")
        
    }
    
    // xib나 스토리보드에서 생성이 될때에는 해당 메소드를 통해서 객채가 생성됨
    // ex. let cell = tableView.dequeueReusableCell(withIdentifier: "id")
    required init?(coder: NSCoder) {
        // 이 함수 내에서 IBOutlet 을 통한 view를 접근하면 안된다. 해당 생성자는 IBOutlet과 같은 처리를 하는 시점이므로 해당 객체는 nil이다.
        super.init(coder: coder)
        print("[DailyRecordCell] required init:  \(self.hash)")
    }
    
    //인터페이스 블더에서 객체가 init?(code:NSDecoder)로 초기화 된 후 호출된다.
    // 즉 IBOutlet과 같은 구성요소들이 모두 설정된 후 호출된다. 뷰의 초기작업을 여기서 해주면된다.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("[DailyRecordCell] awakeFromNib:  \(self.hash)")
        songItemCollectionView.delegate = self
        songItemCollectionView.dataSource = self
        songItemCollectionView.showsHorizontalScrollIndicator = false
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        print("setSelected")
//        // Configure the view for the selected state
//    }
    
    func setCell(title:String, data:[RecordData], clickEvent: PostProcessCellClickEvent) {
        // title preprocess
        var resultTitle = getResultTitle(title: title)
        self.clickEvent = clickEvent
        
        
        titleLabel.text = resultTitle
        recordDataList = data
        
        DispatchQueue.main.async {
            self.songItemCollectionView.reloadData()
        }
    }
    
    func getResultTitle(title:String) -> String{
    
        // 1. split title according to preset rule
        let splitted = title.components(separatedBy: "-")
        if splitted.count != 3 {
            return "split error!"
        }
        
        // 2. preprocess of title
        var result = TitleDate(year:splitted[0], month: splitted[1], day: splitted[2]).convertDate()
        
        // 3. add emoji at the front of string
        result = EmojiType.getRandomEmoji() + " " + result
        
        
        return result
    }
}

extension DailyRecordCell : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recordDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecordSongCell", for: indexPath) as! RecordSongCell
        let targetRecordData = recordDataList[indexPath.item]
        let titleStr = targetRecordData.shazamData!.title!
        let artworkUrl = targetRecordData.shazamData!.artworkURL!
        let str = artworkUrl.absoluteString
        print(" ---------------- :: \(str)")
        
        cell.setCellData(imageUrl: str, title: titleStr)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let targetRecordData = recordDataList[indexPath.row]
        clickEvent?.onClickedBtnCell(recordData:targetRecordData)
    }
    
}


struct TitleDate{
    let year: String
    let month: String
    let day: String
    
    
    init(year:String , month:String, day:String) {
        self.year = year
        self.month = month
        self.day = day
    }
    
    func convertDate()->String{
        var result = ""
        
        // 1. month case
        func convertMonth(month:String) -> String{
            switch month {
            case "01":
                return "Jan"
            case "02":
                return "Feb"
            case "03":
                return "Mar"
            case "04":
                return "Apr"
            case "05":
                return "May"
            case "06":
                return "Jun"
            case "07":
                return "Jul"
            case "08":
                return "Aug"
            case "09":
                return "Sep"
            case "10":
                return "Oct"
            case "11":
                return "Nov"
            case "12":
                return "Dec"
                
            default:
                return "error"
            }
        }
        
        result += convertMonth(month: self.month)
        result += " "
        
        // 2. day case
        func convertDay(day:String) -> String{
            if let num = Int(day){
                let remain = num % 10
                switch remain{
                case 1:
                    return String(num) + "st"
                case 2:
                    return String(num) + "nd"
                case 3:
                    return String(num) + "rd"
                    
                default:
                    return String(num) + "th"
                }
            }
            
            return "error"
        }
        
        result += convertDay(day: day)
        
        // 3. add year
        result += ", " + year
        
        return result
    }
}
