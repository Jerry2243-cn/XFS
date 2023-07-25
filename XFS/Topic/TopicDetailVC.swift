//
//  TopicDetailVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2023/1/5.
//

import UIKit
import SegementSlide

class TopicDetailVC: SegementSlideDefaultViewController {
    
    var topic:Topic?
    
    let nav = BaseNavigationBar()
    
    lazy var topicHeaderView: UIView = {
        let view = UIView(frame: CGRect(x: .zero, y: .zero, width: view.bounds.width, height: 150))
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        topicLabel.text = "# \(topic?.name ?? "话题")"
        view.addSubview(topicLabel)
      
        topicLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(navigationBarHeight + 10)
        }
        
        viewsLabel.text = "\(topic?.views ?? 0) 次浏览"
        view.addSubview(viewsLabel)
        viewsLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(topicLabel.snp.bottom).offset(10)
        }
        let sv = UIView()
        sv.backgroundColor = .systemGray6
        view.addSubview(sv)
        sv.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        return view
    }()
    
    lazy var topicLabel: UILabel = {
        let Label = UILabel()
        Label.font = UIFont.systemFont(ofSize: 24)
        Label.textColor = .label
        Label.textAlignment = .left
        return Label
    }()
    
    lazy var viewsLabel: UILabel = {
        let Label = UILabel()
        Label.font = UIFont.systemFont(ofSize: 15)
        Label.textColor = .secondaryLabel
        Label.textAlignment = .left
        return Label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(nav)
        scrollView.backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        switcherView.backgroundColor = .systemBackground
        nav.backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        defaultSelectedIndex = 0
        reloadData()
    }
    
    override func segementSlideHeaderView() -> UIView? {
        topicHeaderView
    }
    
    override var titlesInSwitcher: [String] {
        return ["笔记"]
    }
    
    override var bouncesType: BouncesType {
        return .child
    }

    override var switcherConfig: SegementSlideDefaultSwitcherConfig{
        var congfig = super.switcherConfig
        congfig.type = .tab
        congfig.selectedTitleColor = .label
        congfig.indicatorColor = mainColor!
        return congfig
    }
    
    override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: kWaterFallVCID) as! WaterFallVC
        vc.cellType = .topic
        vc.topic = topic?.name
        return vc
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView, isParent: Bool) {
        super.scrollViewDidScroll(scrollView, isParent: isParent)
        guard isParent else {
            return
        }
        updateNavigationBarStyle(scrollView)
    }
    
    private func updateNavigationBarStyle(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 50{
            nav.titleLabel.text = topic?.name
        } else {
            nav.titleLabel.text = ""
        }
    }
    
    @objc func goBack(){
        dismiss(animated: true)
    }
}
