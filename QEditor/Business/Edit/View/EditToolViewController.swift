//
//  EditToolViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

fileprivate let CELL_IDENTIFIER = "EditToolImageCell"
fileprivate let MIN_SCROLL_WIDTH = SCREEN_WIDTH + SCREEN_WIDTH / 2

class EditToolViewController: UIViewController {
    
    public var presenter: (EditViewPresenterInput & EditToolViewOutput)!
    
    private var duration: Int = 0
    
    private var playerStatus: PlayerViewStatus = .error
    
    private var isPlayingBeforeDragging = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        toolBarView.reloadData()
    }
    
    private func initView() {
        view.backgroundColor = .black
        view.addSubview(containerView)
        view.addSubview(verticalTimeLineView)
        view.addSubview(toolBarView)
        containerView.addSubview(contentView)
        contentView.addSubview(thumbView)
        contentView.addSubview(timeScaleView)
        
        containerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(self.toolBarView.snp.top)
        }
        
        verticalTimeLineView.snp.makeConstraints { (make) in
            make.center.equalTo(self.containerView)
            make.width.equalTo(4)
            make.height.equalTo(SCREEN_WIDTH / 3)
        }
        
        toolBarView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(50)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.containerView)
            make.height.equalTo(self.containerView)
            make.width.equalTo(self.containerView.contentSize.width)
        }
        
        thumbView.snp.makeConstraints { (make) in
            make.height.equalTo(EDIT_THUMB_CELL_SIZE)
            make.left.equalTo(self.contentView).offset(SCREEN_WIDTH / 2)
            make.width.equalTo(SCREEN_WIDTH)
            make.centerY.equalTo(self.contentView)
        }
        
        timeScaleView.snp.makeConstraints { (make) in
            make.height.equalTo(25)
            make.width.equalTo(SCREEN_WIDTH)
            make.left.equalTo(self.contentView).offset(SCREEN_WIDTH / 2)
            make.top.equalTo(self.contentView).offset(0)
        }
    }
    
    private func refreshContainerView() {
        //1.更新容器view的contentSize
        let itemCount = presenter.toolImageThumbViewItemsCount(self)
        containerView.contentSize = .init(width: CGFloat(itemCount) * EDIT_THUMB_CELL_SIZE, height: 0)
        let width = max(containerView.contentSize.width + SCREEN_WIDTH, MIN_SCROLL_WIDTH)
        contentView.snp.updateConstraints { (make) in
            make.width.equalTo(width)
        }
        view.layoutIfNeeded()
        //2.初始化第一个最大的框选view
        let chooseMaxWidth = (width - SCREEN_WIDTH) + 50
        let view = EditToolChooseBoxView(with: chooseMaxWidth)
        view.qe.left = SCREEN_WIDTH / 2 - 25
        view.qe.width = chooseMaxWidth
        view.qe.centerY = thumbView.qe.centerY
        view.initLeft = view.qe.left
        contentView.addSubview(view)
    }
    
    //MARK: 工具栏
    
    private func showEditBar() {
        let view = EditToolEditBar()
        view.selectedDelegate = self
        view.frame = .init(x: 0, y: 0, width: toolBarView.qe.width, height: toolBarView.qe.height)
        toolBarView.insertSubview(view, at: 99)
        view.backClosure = { [weak view] in
            view?.removeFromSuperview()
        }
        view.reloadData()
    }
    
    //MARK: Getter
    
    lazy var containerView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.contentSize = .init(width: MIN_SCROLL_WIDTH, height: 0)
        view.delegate = self
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var verticalTimeLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 2
        return view
    }()
    
    lazy var thumbView: EditToolImageThumbView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = EditToolImageThumbView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: EDIT_THUMB_CELL_SIZE), collectionViewLayout: layout)
        view.isScrollEnabled = false
        view.itemCountClosure = { [weak self] in
            if let ss = self {
                return ss.presenter.toolImageThumbViewItemsCount(ss)
            }
            return 0
        }
        view.itemModelClosure = { [weak self] (item: Int) -> EditToolImageCellModel in
            if let ss = self {
                return ss.presenter.toolView(ss, thumbModelAt: item)
            }
            return EditToolImageCellModel()
        }
        return view
    }()
    
    lazy var timeScaleView: EditToolTimeScaleView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = EditToolTimeScaleView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 25), collectionViewLayout: layout)
        view.itemCountClosure = { [weak self] in
            if let ss = self {
                return ss.presenter.toolImageThumbViewItemsCount(ss)
            }
            return 0
        }
        view.itemContentClosure = { [weak self] (item: Int) -> String in
            if let ss = self {
                return ss.presenter.toolView(ss, contentAt: item)
            }
            return ""
        }
        return view
    }()
    
    lazy var toolBarView: EditToolBar = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 15
        layout.itemSize = .init(width: 40, height: 50)
        let view = EditToolBar(frame: .zero, collectionViewLayout: layout)
        view.selectedClosure = { [weak self] (_ index: Int) in
            guard let ss = self else {
                return
            }
            switch index {
            case 0:
                ss.showEditBar()
            default:
                break
            }
        }
        return view
    }()

}

extension EditToolViewController: EditToolEditBarDelegate {
    
    func viewDidSelectedCut(_ view: EditToolEditBar) {
        //[剪辑][分割]
        //todo:
    }
    
}

extension EditToolViewController: EditToolViewInput {
    
}

extension EditToolViewController: EditViewPresenterOutput {
    
    func presenterViewShouldReload(_ presenter: EditViewPresenterInput) {
        refreshContainerView()
        thumbView.reloadData()
    }
    
    func presenter(_ presenter: EditViewPresenterInput, playerDidLoadVideoWith duration: Int64) {
        self.duration = Int(duration)
    }
    
    func presenter(_ presenter: EditViewPresenterInput, playerPlayAt time: Double) {
        guard duration > 0 else {
            return
        }
        let percent = CGFloat(time) / CGFloat(duration)
        guard percent <= 1 else {
            return
        }
        let totalWidth = thumbView.contentSize.width
        let offsetX = totalWidth * percent
        containerView.contentOffset = .init(x: offsetX, y: 0)
    }
    
    func presenter(_ presenter: EditViewPresenterInput, playerStatusDidChange status: PlayerViewStatus) {
        playerStatus = status
    }
    
    func presenter(_ presenter: EditViewPresenterInput, didLoadVideo model: MediaVideoModel) {
        thumbView.videoModel = model
    }
    
}

extension EditToolViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let totalWidth = scrollView.contentSize.width
        
        if totalWidth - SCREEN_WIDTH > 0 && playerStatus != .playing {
            let percent = min(Float(offsetX / (totalWidth - SCREEN_WIDTH)), 1)
            presenter.toolView(self, onDragWith: percent)
        }
        
        if offsetX < SCREEN_WIDTH / 2 {
            //在左侧
            thumbView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(SCREEN_WIDTH / 2)
            }
            timeScaleView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(SCREEN_WIDTH / 2)
            }
            thumbView.contentOffset = .zero
            timeScaleView.contentOffset = .zero
        } else if offsetX >= totalWidth - SCREEN_WIDTH * 1.5 {
            //在右侧
            thumbView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(totalWidth - SCREEN_WIDTH * 1.5)
            }
            timeScaleView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(totalWidth - SCREEN_WIDTH * 1.5)
            }
            thumbView.contentOffset = .init(x: thumbView.contentSize.width - SCREEN_WIDTH, y: 0)
            timeScaleView.contentOffset = .init(x: timeScaleView.contentSize.width - SCREEN_WIDTH, y: 0)
        } else if offsetX >= SCREEN_WIDTH / 2 {
            thumbView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(offsetX)
            }
            timeScaleView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(offsetX)
            }
            let newOffsetX = offsetX - SCREEN_WIDTH / 2
            thumbView.contentOffset = .init(x: newOffsetX, y: 0)
            timeScaleView.contentOffset = .init(x: newOffsetX, y: 0)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let totalWidth = scrollView.contentSize.width
        if totalWidth - SCREEN_WIDTH > 0 {
            let percent = Float(offsetX / (totalWidth - SCREEN_WIDTH))
            presenter.toolView(self, onDragWith: percent)
        }
        if isPlayingBeforeDragging {
            isPlayingBeforeDragging = false
            presenter.playerShouldPlay()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isPlayingBeforeDragging = playerStatus == .playing
        presenter.playerShouldPause()
    }
    
}