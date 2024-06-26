//
//  OnboardingViewController.swift
//  SeSACShopping
//
//  Created by 민지은 on 2024/01/19.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var onboardingImage: UIImageView!
    @IBOutlet var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
        setBackgroundColor()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        resetData()
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
        print(#function)
        
        let sb = UIStoryboard(name: "ProfileName", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: ProfileNameViewController.identifier) as! ProfileNameViewController
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func resetData() {
        UserDefaultManager.shared.profileIndex = Int.random(in: 0...13)
        UserDefaultManager.shared.nickName = ""
        UserDefaultManager.shared.searchItems.removeAll()
        UserDefaultManager.shared.likeItems.removeAll()
        UserDefaultManager.shared.newMember = true
    }
    
}


extension OnboardingViewController: ViewProtocol {
    func configureView() {
        logoImage.image = UIImage(named: "sesacShopping")
        onboardingImage.image = UIImage(named: "onboarding")
        
        startButton.pointButtonStyle(title: "시작하기")
    }
}
