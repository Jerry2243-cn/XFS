//
//  AppDelegate.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/1.
//

import UIKit
import CoreData
import Alamofire
import AliyunOSSiOS

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var client:OSSClient?
    
    var user: User?

    var server = Server.shared()
    
    var myPOI:POI?
    
    var channels:[String]?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if server.token == ""{
            let nav = UINavigationController(rootViewController: LoginVC())
            UIApplication.shared.windows.first?.rootViewController = nav
        }
        
        config()
        loginTest()
        initAliyunOSS()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "XFS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate{
    func config(){
        AMapServices.shared().enableHTTPS = true
        AMapServices.shared().apiKey = "c00bb2456e7df9be0153258d26866353"
        //地图隐私合规
        AMapLocationManager.updatePrivacyAgree(.didAgree)
        AMapLocationManager.updatePrivacyShow(.didShow, privacyInfo: .didContain)
        AMapSearchAPI.updatePrivacyAgree(.didAgree)
        AMapSearchAPI.updatePrivacyShow(.didShow, privacyInfo: .didContain)
        
        UINavigationBar.appearance().tintColor = .label
    }
    
    func loginTest(){
        let lastDate = UserDefaults.standard.object(forKey: userDefaultslastOpenTime) as? Date
        if let date = lastDate{
            if !date.isToday{
                server.login{res in
                    if let resoult = res{
                        if resoult == "token无效"{
                            self.server.token = ""
                        }
                    }else{
                        self.server.token = ""
                    }
                }
            }
        }
        UserDefaults.standard.set(Date(), forKey: userDefaultslastOpenTime)
        if server.token != "" {
            server.fetchUser { res in
                 if let user = res {
                     self.user = user
                 }
             }
        }
        print("checkToken:\(server.token)")
    }
    
    func initAliyunOSS(){
         

//         client = OSSClient(endpoint: "oss-cn-hangzhou.aliyuncs.com", credentialProvider: credentialProvider)
       
        
    }
}
