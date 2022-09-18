//
//  ClusteredSongListVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 9/13/22.
//

import UIKit
import BottomHalfModal
import Kingfisher

protocol PostProcessCellClickEvent{
    func onClickedBtnCell(recordData: RecordData)
}

class ClusteredSongListVC: UIViewController, SheetContentHeightModifiable {
    var sheetContentHeightToModify: CGFloat = SheetContentHeight.default
    var postProcessEvent:PostProcessCellClickEvent?

    var cellDataList:[RecordData]!
    
    var songTableView:UITableView!
    var viewTranslation = CGPoint(x:0, y:0)
    var viewVelocity = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(onClickedBtnClose))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(hex: 0x009051)
        
        let contentView = UIView()
        contentView.frame = self.view.bounds
        self.view.addSubview(contentView)
        contentView.backgroundColor = UIColor(hex: 0x009051)
        contentView.snp.makeConstraints{ make in
            make.edges.equalTo(self.view)
        }
        
        print("===[ClusteredSongListVC] contentView.frame: \(contentView.frame.width) \(contentView.frame.height) ===")
        
        songTableView = UITableView()
        songTableView.backgroundColor = UIColor(hex: 0x009051)
        contentView.addSubview(songTableView)
        songTableView.snp.makeConstraints{ make in
            make.width.equalTo(contentView)
            make.height.equalTo(contentView.bounds.height * 0.5 - 50)
        }
        
        songTableView.delegate = self
        songTableView.dataSource = self
        songTableView.register(ClusteredSongCell.self, forCellReuseIdentifier: ClusteredSongCell.id)
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(close)))
        
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        adjustFrameToSheetContentHeightIfNeeded()
        songTableView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        adjustFrameToSheetContentHeightIfNeeded(with: coordinator)
    }
    
    @objc func onClickedBtnClose(){
        dismiss(animated: true)
    }
    
    @objc func close(_ sender: UIPanGestureRecognizer){
        viewTranslation = sender.translation(in: view)
        viewVelocity = sender.velocity(in: view)
        
        switch sender.state{
        case .changed:
            // 상하로 스와이프 할 때 위로 스와이프가 안되게 해주기 위해서 조건 설정
            if abs(viewVelocity.y) > abs(viewVelocity.x){
                if viewVelocity.y > 0 {
                    UIView.animate(withDuration: 0.1, animations: {
                        self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                    })
                }
            }
            
        case .ended:
            // 해당 뷰의 y값이 200보다 작으면(작게 이동 시) 뷰의 위치를 다시 원상복구한다. 즉, 다시 y=0 인 지점으로 리셋
            print("===[ClusteredSongListVC] viewTranslation.y : \(viewTranslation.y) ===")
            if viewTranslation.y < 180 {
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.transform = .identity
                })
            }else {
                dismiss(animated: true)
            }
            
        default:
            break
        }
    }
    
    func setCellData(recordDataList: [RecordData], clickEvent:PostProcessCellClickEvent){
        cellDataList = recordDataList
        self.postProcessEvent = clickEvent
    }
}

extension ClusteredSongListVC : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ClusteredSongCell.id, for: indexPath) as? ClusteredSongCell else{
            print("--- [ClusteredSongListVC] cell is invalid type ---")
            return UITableViewCell()
        }
//        cell.textLabel?.text = cells[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        
        cell.backgroundColor = UIColor(hex: 0x009051)
        let targetRecordData = cellDataList[indexPath.row]
        if let shazamData = targetRecordData.shazamData, let title = shazamData.title, let artist = shazamData.artist, let coverUrl = shazamData.artworkURL{
            cell.setCell(title: title, artist: artist, artwork: coverUrl.absoluteString)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetData = cellDataList[indexPath.row]
        dismiss(animated: true){
            self.postProcessEvent?.onClickedBtnCell(recordData: targetData)
        }
    }
}

class ClusteredSongCell: UITableViewCell{
    static let id = "ClusteredSongCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        print("[ClusterredSongListVC] override init")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("[ClusteredSongListVC] required init: ")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("[ClusteredSongListVC] awakeFromNib: ")
    }
    
    func setCell(title: String, artist:String, artwork:String){
        self.textLabel?.text = title
        self.textLabel?.textColor = .white
        self.detailTextLabel?.text = artist
        self.detailTextLabel?.textColor = .white
        
        self.imageView?.kf.indicatorType = .activity
        let resource = ImageResource(downloadURL: URL(string: artwork)!, cacheKey: artwork)
        let scale = UIScreen.main.scale
        let resizingProcessor = ResizingImageProcessor(referenceSize: CGSize(width: 50*scale*0.5, height: 50*scale*0.5))
        if let imageView = self.imageView{
            self.imageView?.layer.masksToBounds = true
            self.imageView?.layer.cornerRadius = 4
            self.imageView?.kf.setImage(with: resource,  options: [ .processor(resizingProcessor),.forceTransition,.transition(.fade(0.5)), .keepCurrentImageWhileLoading, .scaleFactor(2.0)]) { result in
                switch result{
                case .failure(let error):
                    print("[ClusteredSongCell] retrieving image failed \(error.localizedDescription)")
                        
                    self.imageView?.image = UIImage(systemName: "music.note")
                case .success(_):
                    break
                }
            }
        }
    }
}
