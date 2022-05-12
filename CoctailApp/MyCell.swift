//
//  MyCell.swift
//  CoctailApp
//
//  Created by Жеребцов Данил on 29.03.2022.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MyCell: UICollectionViewCell {
    
    var label: UILabel!
    var myView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel()
        myView = UIView()
        contentView.addSubview(myView)
        //contentView.addSubview(label)
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpContentView() {
        
    }
    
    func setUpLabel() {
        contentView.backgroundColor = .clear
        myView.backgroundColor = UIColor(named: "CellBackgroundColor")!
        myView.layer.cornerRadius = 8
        
        myView.translatesAutoresizingMaskIntoConstraints = false
        myView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        myView.clipsToBounds = true
        myView.addSubview(label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.backgroundColor = .clear
        self.label.numberOfLines = 1
        self.label.textAlignment = .center
        self.label.textColor = .white
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(25)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
    }
}
