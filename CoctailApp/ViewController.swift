//
//  ViewController.swift
//  CoctailApp
//
//  Created by Жеребцов Данил on 29.03.2022.
//

import UIKit
import Alamofire
import SnapKit
import AlignedCollectionViewFlowLayout

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Private Properties
    private let layout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
    private let url = URL(string: "https://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Non_Alcoholic")!
    private let myQueue = DispatchQueue(label: "com.com.my-work.personalQueue", qos: .userInteractive)
    private var collectionView: UICollectionView!
    private var textField: UITextField!
    
    private var dataSource: [Coctail] = []
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardWillHideNotification()
        keyboardWillShowNotification()
        setUpCollectionView()
        setUpsearchBar()
        collectionView.register(MyCell.self, forCellWithReuseIdentifier: "MyCell")
        request {
            DispatchQueue.main.async { [unowned self] in
                self.collectionView.reloadData()
            }
        }
        createTapGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makeInitialConstraints()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    private func createTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setUpCollectionView() {
        self.collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: self.layout)
        self.view.addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.backgroundColor = .clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    
    private func setUpsearchBar() {
        self.textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.textField.placeholder = "Coctail name"
        self.textField.font = UIFont.systemFont(ofSize: 15)
        self.textField.borderStyle = .roundedRect
        self.textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        self.textField.keyboardType = UIKeyboardType.default
        self.textField.returnKeyType = UIReturnKeyType.done
        self.textField.clearButtonMode = .whileEditing
        self.textField.backgroundColor = .systemBackground
        view.addSubview(self.textField)
        view.bringSubviewToFront(self.textField)
        self.textField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        self.addShaddow()
    }
    
    @objc private func textFieldDidChange() {
        guard let text = textField.text else { return }
        for index in 0..<dataSource.count {
            let indexPath = IndexPath(item: index, section: 0)
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? MyCell else { return }
            if dataSource[index].strDrink.contains(text) {
                let gradientMaskLayer = CAGradientLayer()
                gradientMaskLayer.frame = cell.myView.bounds
                gradientMaskLayer.colors = [UIColor.red.cgColor, UIColor.purple.cgColor]
                gradientMaskLayer.locations = [0, 0.7]
                cell.myView.layer.insertSublayer(gradientMaskLayer, at: 0)
            } else {
                guard let sublayers = cell.myView.layer.sublayers else { return }
                sublayers.filter{ $0 is CAGradientLayer }.forEach{ $0.removeFromSuperlayer()}
            }
        }
    }
    
    private func makeInitialConstraints() {
        self.collectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
        self.textField.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(30)
            make.bottom.equalToSuperview().offset(-200)
            make.centerX.equalToSuperview()
        }
    }
    
    private func addShaddow() {
        self.textField.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.textField.layer.shadowRadius = 5
        self.textField.layer.shadowColor = UIColor.black.cgColor
        self.textField.layer.shadowOpacity = 1
    }
    
    private func removeShadow() {
        self.textField.layer.shadowColor = UIColor.clear.cgColor
    }
    
    private func moveSearchBarUp(keyboardFrame: CGRect) {
        self.textField.snp.removeConstraints()
        self.textField.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-keyboardFrame.height)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(keyboardFrame.width)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
    private func moveSearchBarDown() {
        self.textField.snp.removeConstraints()
        self.textField.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-200)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
    private func request(completion: @escaping (()->Void)) {
        AF.request(url, method: .get, parameters: nil).validate().responseData(queue: self.myQueue) { [unowned self] response in
            print(response)
            switch response.result {
            case .success(_):
                if let data = response.data {
                    let drinks: Drinks = try! JSONDecoder().decode(Drinks.self, from: data)
                    self.dataSource = drinks.drinks
                    print(drinks)
                    completion()
                }
            case .failure(let error):
                print("Request error: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - KeyBoard Notification
    private func keyboardWillShowNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func keyboardWillHideNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func handleKeyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrame.cgRectValue
            textField.borderStyle = .none
            moveSearchBarUp(keyboardFrame: keyboardFrame)
            removeShadow()
        }
        if let keyboardAnimationDaration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            UIView.animate(withDuration: keyboardAnimationDaration, delay: 0) { [unowned self] in
                self.view.layoutSubviews()
            }
        }
    }
    
    @objc private func handleKeyboardWillHide(notification: NSNotification) {
        self.textField.borderStyle = .roundedRect
        addShaddow()
        self.moveSearchBarDown()
        if let keyboardAnimationDaration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            UIView.animate(withDuration: keyboardAnimationDaration, delay: 0) { [unowned self] in
                self.view.layoutSubviews()
                
            }
        }
    }
}

//MARK: - CollectionView Protocols
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! MyCell
        cell.label.text = dataSource[indexPath.row].strDrink
        cell.setUpLabel()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}



