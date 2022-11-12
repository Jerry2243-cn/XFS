//
//  FileHelper.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/11/10.
//

import Foundation
import AliyunOSSiOS

class FileHelper{
    
    static func uploadImages(images:[UIImage]) -> [Photo]?{
        var photos:[Photo] = []
        for i in 0 ..< images.count{
            if let uploadedName = uploadImage(image: images[i]){
                let photo = Photo(url:uploadedName,orderNumber: i)
                photos.append(photo)
            }else{
                return nil
            }
        }
        return photos
    }
    
    
    static func uploadImage(image:UIImage) -> String?{
        let name = "\(UUID()).jpg"
        let put = OSSPutObjectRequest()
        put.bucketName = "xfs-picture"
        put.objectKey = name
        put.uploadingData = image.getJpeg(.medium)!
        put.uploadProgress = { (a,b,c) in
            print("\(a),\(b),\(c)")
        }
        
        let putTask = appDelegate.client?.putObject(put)
        
        var succeed = false
        putTask?.continue({ task in
            if task.error == nil{
                succeed = true
            }
            return
        })
        
        putTask?.waitUntilFinished()
        return succeed ? name : nil
    }
    
    static func getRemoteImage(name:String) -> UIImage{
        let getReq = OSSGetObjectRequest()
        getReq.bucketName = "xfs-picture"
        getReq.objectKey = name
        getReq.downloadProgress = { (a,b,c) in
            print("\(a),\(b),\(c)")
        }
        
        let getTask = appDelegate.client?.getObject(getReq)
        
        var image = UIImage()
        getTask?.continue({ task in
            if task.error == nil {
                image = UIImage(task.result?.downloadedData) ?? imagePH
            }
            return
        })
        
        getTask?.waitUntilFinished()
        return image
    }
    
}
