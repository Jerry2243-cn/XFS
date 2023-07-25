//
//  Constants.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/2.
//

import Foundation
import UIKit

let eachPageCount = 10
let userDefaultsTokenKey = "user_token"
let userDefaultslastOpenTime = "last_login_date"
let userDefaultsDraftNotesCount = "draftNotesCount"

//let serverAddress = "http://127.0.0.1:8080"
let serverAddress = "http://jerrys-macbook.local:8080"
//let serverAddress = "http://192.168.3.79:8080"


// MARK: Notification
let kLikeSucceed = "likeSucceed"
let kRefreshNotes = "refreshNotes"
let kUpdateLoaction = "updateLoaction"
let kUpdateuser = "updateUser"
let kDeleteNote = "deleteNote"
let kShowNoteDetail = "showNoteDetail"
let kFellow = "fellow"
let kGotoMine = "gotoMine"
let kUpdateFellow = "updateFellow"
let kNoDraftNote = "noDraftNote"
let khaveDraftNote = "haveDraftNote"

// MARK: StoaryBOardID
let kMainTabBar = "mainID"
let kFellowVCID = "fellowVCID"
let kDiscoverVCID = "discoverVCID"
let kNearbyVCID = "nearbyVCID"
let kWaterFallVCID = "waterFallVCID"
let kNoteEditingVC = "noteEditingVCID"
let kTopicTableVCID = "topicTableVCID"
let kNoteDetailVCID = "noteDetailVCID"
let kDraftNoteNaviVCID = "draftNoteNaviVCID"
let kMessageVCID = "messageVCID"
let kNotficationLIstVC = "notficationLIstVC"
let kMeVCID = "meVCID"
let kCommentViewID = "commentViewID"
let kCommentSectionFooterView = "commentSectionFooterView"

// MARK: CellID
let kWaterFallCellID = "waterFallCellID"
let kNearbyCellID = "nearbyCellID"
let kFellowCellID = "fellowCellID"
let kPhotoCellID = "photoCellID"
let kPhotoFooterID = "photoFooterID"
let kTopicCellID = "topicCellID"
let kPOICell = "POICellID"
let kLocationTagCellID = "locationTagCellID"
let kDraftNoteWaterfallID = "draftNoteWaterfallID"
let kMessageCellID = "messageCellID"
let kNearbyCodeCell = "nearbyCodeCellID"
let kWaterfallCodeCell = "waterfallCodeCellID"
let kReplayCellID = "replayCellID"
let kUserCellID = "userCellID"
let kDraftCellID = "draftCellID"

let kWaterFallpadding:CGFloat = 5
let kMaxPhotoCount = 9
let kMaxTitleCount = 20
let kMaxContentCount = 1000
let mainColor = UIColor(named: "main_color")
let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
let screenWidth = UIScreen.main.bounds.width
let navigationBarHeight:CGFloat = 54
let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext
let screenRect = UIScreen.main.bounds

let imagePH = UIImage(named: "loadFailedImage")!
let defaultAvatar = UIImage(named: "avatarDefault")!

let imageServerURL = "https://xfs-picture.oss-cn-hangzhou.aliyuncs.com/"

//测试占位数据
var kChannels = ["推荐","电影"]
let kTopics = [
    ["穿神马是神马", "就快瘦到50斤啦", "花5个小时修的靓图", "网红店入坑记"],
    ["魔都名媛会会长", "爬行西藏", "无边泳池只要9块9"],
    ["小鲜肉的魔幻剧", "国产动画雄起"],
    ["练舞20年", "还在玩小提琴吗,我已经尤克里里了哦", "巴西柔术", "听说拳击能减肥", "乖乖交智商税吧"],
    ["粉底没有最厚,只有更厚", "最近很火的法属xx岛的面霜"],
    ["我是白富美你是吗", "康一康瞧一瞧啦"],
    ["装x西餐厅", "网红店打卡"],
    ["我的猫儿子", "我的猫女儿", "我的兔兔"]
]

let kPOITypes = "汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风最名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附服设施|地名地址信息|公共设施"

