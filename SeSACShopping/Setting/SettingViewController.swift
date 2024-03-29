//
//  SettingViewController.swift
//  SeSACShopping
//
//  Created by 민지은 on 2024/01/19.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet var settingTableView: UITableView!
    
    let viewModel = ProfileModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        setBackgroundColor()
        configureView()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        viewModel.selectImage.value = UserDefaultManager.shared.profileIndex
        viewModel.inputName.value = UserDefaultManager.shared.nickName
        viewModel.userLike.value = UserDefaultManager.shared.likeItems.count.prettyNumber
        settingTableView.reloadData()
    }

}

extension SettingViewController {
    func configureTableView() {
        settingTableView.delegate = self
        settingTableView.dataSource = self
        
        let xib = UINib(nibName: ProfileTableViewCell.identifier, bundle: nil)
        settingTableView.register(xib, forCellReuseIdentifier: ProfileTableViewCell.identifier)

        let xib2 = UINib(nibName: SettingTableViewCell.identifier, bundle: nil)
        settingTableView.register(xib2, forCellReuseIdentifier: SettingTableViewCell.identifier)

    }
}

extension SettingViewController: ViewProtocol {
    func configureView() {
        settingTableView.backgroundColor = .clear
        
        navigationItem.title = "설정"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 95
        } else {
            return 50
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.viewModel.settingList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell

            viewModel.selectImage.bind { value in
                cell.profileImage.image = UIImage(named: "profile\(value + 1)")
            }
            
            viewModel.inputName.bind { value in
                cell.nameLabel.text = "\(value)"
            }

            viewModel.userLike.bind { value in
                cell.countLabel.text = "\(value)개의 상품"
                cell.likeLabel.text = "을 좋아하고 있어요!"
            }

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as! SettingTableViewCell
            
            cell.settingLabel.text = "\(viewModel.settingList[indexPath.row])"

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let sb = UIStoryboard(name: "ProfileName", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: ProfileNameViewController.identifier) as! ProfileNameViewController
            
            vc.viewModel.editType.value = .edit
            navigationController?.pushViewController(vc, animated: true)
            
        }

        if self.viewModel.settingList[indexPath.row] == "처음부터 시작하기" {

            let alert = UIAlertController(title: "처음부터 시작하기", message: "데이터를 모두 초기화하시겠습니까?", preferredStyle: .alert)

            let cancelButton = UIAlertAction(title: "취소", style: .cancel)
            let checkButton = UIAlertAction(title: "확인", style: .destructive) { action in
                    
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                
                let sceneDelegate = windowScene?.delegate as? SceneDelegate
                
                let sb = UIStoryboard(name: "Onboarding", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: OnboardingViewController.identifier) as! OnboardingViewController
                
                let nav = UINavigationController(rootViewController: vc)

                sceneDelegate?.window?.rootViewController = nav
                sceneDelegate?.window?.makeKeyAndVisible()
                
            }

            alert.addAction(cancelButton)
            alert.addAction(checkButton)
            
            present(alert, animated: true)
        }
    }
}
