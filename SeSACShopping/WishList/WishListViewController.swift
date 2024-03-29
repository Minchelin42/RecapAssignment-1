//
//  WishListViewController.swift
//  SeSACShopping
// Created by 민지은 on 2024/01/23.
//

import UIKit
import Toast
import RealmSwift

class WishListViewController: UIViewController {
    
    @IBOutlet var heartImage: UIImageView!
    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var clearButton: UIButton!
    
    @IBOutlet var wishCollectionView: UICollectionView!
    
    let realm = try! Realm()
    var wishList: Results<WishListTable>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundColor()
        
        navigationItem.title = "\(UserDefaultManager.shared.nickName)님의 위시리스트"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        heartImage.image = UIImage(systemName: "suit.heart.fill")
        heartImage.tintColor = .white
        
        likeCountLabel.text = "\(UserDefaultManager.shared.likeItems.count)"
        likeCountLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        
        clearButton.setTitle("모두 지우기", for: .normal)
        clearButton.setTitleColor(.pointColor, for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        
        wishList = realm.objects(WishListTable.self)
        
        print(realm.configuration.fileURL)
        
        configureCollectionView()
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        likeCountLabel.text = "\(UserDefaultManager.shared.likeItems.count)"
        wishCollectionView.reloadData()
    }
    
    @objc func clearButtonTapped() {
        
        let alert = UIAlertController(title: "전체 삭제", message: "위시리스트를 전부 삭제하시겠습니까?\n삭제 후 복구는 불가능합니다!", preferredStyle: .alert)

        let cancelButton = UIAlertAction(title: "취소", style: .cancel)
        let checkButton = UIAlertAction(title: "삭제", style: .destructive) { action in
                
            UserDefaultManager.shared.likeItems.removeAll()
            
            try! self.realm.write {
                self.realm.delete(self.wishList)
            }
            
            self.likeCountLabel.text = "\(UserDefaultManager.shared.likeItems.count)"
            self.wishCollectionView.reloadData()
            
            var style = ToastStyle()

            style.messageColor = .pointColor

            self.view.makeToast("위시리스트가 전부 삭제되었습니다", duration: 2.0, position: .bottom, style: style)
        }
        
        alert.addAction(cancelButton)
        alert.addAction(checkButton)
        
        present(alert, animated: true)
 
    }
    
}

extension WishListViewController {
    func configureCollectionView() {
        
        wishCollectionView.backgroundColor = .clear
        
        wishCollectionView.delegate = self
        wishCollectionView.dataSource = self
        
        let xib = UINib(nibName: ResultCollectionViewCell.identifier, bundle: nil)
        wishCollectionView.register(xib, forCellWithReuseIdentifier: ResultCollectionViewCell.identifier)
    }
    
    
    func setLayout() {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 15
        
        let cellWidth = (UIScreen.main.bounds.width - (spacing * 3)) / 2
        let cellHeight = cellWidth * 1.5
        
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.scrollDirection = .vertical
        
        wishCollectionView.collectionViewLayout = layout
    }
}
extension WishListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wishList.count //나중에 wishItem.count로 바꾸기
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ResultCollectionViewCell.identifier, for: indexPath) as! ResultCollectionViewCell
        
        let item = wishList[indexPath.row]
        
        cell.backgroundColor = .clear
        
        cell.resultImage.kf.setImage(with: URL(string: item.image))
        
        cell.heartButton.tag = indexPath.row

        cell.heartButton.configureView(isSelected: true)
        
        cell.companyLabel.text = "\(item.mallName)"
        
        var title = item.title.replacingOccurrences(of: "<b>", with: "")
        title = title.replacingOccurrences(of: "</b>", with: "")
        
        cell.productLabel.text = "\(title)"
        
        let price = (Int(item.lprice)?.prettyNumber)!
        
        cell.priceLabel.text = "\(price) 원"
        
        cell.heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
        
        return cell
    }
    
    @objc func heartButtonTapped(sender: UIButton) {
        print(#function)
        print(sender.tag)

        UserDefaultManager.shared.likeItems.remove(at: sender.tag)
        
        do {
            try realm.write {
                realm.delete(self.wishList[sender.tag])
            }
        } catch {
            print(error)
        }

        likeCountLabel.text = "\(UserDefaultManager.shared.likeItems.count)"
        wishCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "SearchDetail", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SearchDetailViewController") as! SearchDetailViewController
        
        let item = wishList[indexPath.row]
        
        let productItem = Item(title: item.title, link: item.link, image: item.image, lprice: item.lprice, mallName: item.mallName, productId: item.productId)
        
        vc.urlString = "https://msearch.shopping.naver.com/product/\(item.productId)"
        vc.productId = item.productId
        vc.productItem = productItem
        
        var title = item.title.replacingOccurrences(of: "<b>", with: "")
        title = title.replacingOccurrences(of: "</b>", with: "")
        
        vc.productName = title
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
