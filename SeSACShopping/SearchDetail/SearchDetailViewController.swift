//
//  SearchDetailViewController.swift
//  SeSACShopping
//
//  Created by 민지은 on 2024/01/19.
//

import UIKit
import WebKit
import RealmSwift

class SearchDetailViewController: UIViewController {

    @IBOutlet var resultView: WKWebView!
    
    var urlString = ""
    var productId = ""
    var productName = ""
    var productItem: Item = Item(title: "", link: "", image: "", lprice: "", mallName: "", productId: "")
    
    let realm = try! Realm()
    var wishList: Results<WishListTable>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackgroundColor()
        configureView()
        
        wishList = realm.objects(WishListTable.self)
        
        print(realm.configuration.fileURL)

        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(leftBarButtonItemClicked))
        leftButton.tintColor = .white
        navigationItem.leftBarButtonItem = leftButton
        
        let rightButton = UIBarButtonItem(image: UIImage(systemName: setLike()), style: .plain, target: self, action: #selector(rightBarButtonItemClicked))
        rightButton.tintColor = .white
        navigationItem.rightBarButtonItem = rightButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let rightButton = UIBarButtonItem(image: UIImage(systemName: setLike()), style: .plain, target: self, action: #selector(rightBarButtonItemClicked))
        rightButton.tintColor = .white
        navigationItem.rightBarButtonItem = rightButton
    }
    
    func setLike() -> String{
        let hasLike = UserDefaultManager.shared.likeItems.contains { element -> Bool in
            if element as! String == productId {
                return true
            } else {
                return false
            }
        }
        
        return hasLike ? "suit.heart.fill" : "suit.heart"
    }

    @objc func leftBarButtonItemClicked() {
        print(#function)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func rightBarButtonItemClicked() {
        print(#function)
        
        let hasLike = UserDefaultManager.shared.likeItems.contains { element -> Bool in
            if element as! String == productId {
                return true
            } else {
                return false
            }
        }
        
        if !hasLike {
            UserDefaultManager.shared.likeItems.append(productId)

            let data = WishListTable(title: productItem.title, link: productItem.link, image: productItem.image, lprice: productItem.lprice, mallName: productItem.mallName, productId: productItem.productId)
            
            try! realm.write {
                realm.add(data)
                print("Realm Create")
            }

        } else {
            if let index = UserDefaultManager.shared.likeItems.firstIndex(where: { $0 as! String == productId }) {
                UserDefaultManager.shared.likeItems.remove(at: index)
                
                do {
                    try realm.write {
                        realm.delete(self.wishList[index])
                    }
                } catch {
                    print(error)
                }

            }
        }
        
        let rightButton = UIBarButtonItem(image: UIImage(systemName: setLike()), style: .plain, target: self, action: #selector(rightBarButtonItemClicked))
        rightButton.tintColor = .white
        navigationItem.rightBarButtonItem = rightButton
    }
}

extension SearchDetailViewController: ViewProtocol {
    func configureView() {
        navigationItem.title = "\(productName)"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        if let url = URL(string: urlString) {
            
            let request = URLRequest(url: url)
            
            resultView.load(request)
        }
    }
}
