//
//  SearchVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/12.
//

import UIKit

class SearchVC: UIViewController, UISearchBarDelegate {

    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //搜索操作
        searchBar.resignFirstResponder()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
