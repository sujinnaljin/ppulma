//
//  CartVC.swift
//  Ppulma
//
//  Created by 강수진 on 2018. 10. 18..
//  Copyright © 2018년 강수진. All rights reserved.
//

import UIKit

struct SampleCartStruct {
    let name : String
    var value : Int
    let price : Int
}

struct SampleUserStruct {
    let name : String
    var point : Double
}


var sampleUser = SampleUserStruct(name: "sujin", point: 2100)

enum SalePercent : Double {
    case zero = 0.0
    case five = 0.05
    case ten = 0.1
    case fifteen = 0.15
    
    var percentString : String {
        switch self {
        case .zero:
            return "0%"
        case .five:
            return "5%"
        case .ten:
            return "10%"
        case .fifteen:
            return "15%"
        }
    }
}


class CartVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var purpleTopView: RoundShadowView!
    //첫 통신에서 유저 포인트 전역변수로 박아놓고, 결제할때 접근해서 차감
    @IBOutlet weak var salePercentLbl : UILabel!
    @IBOutlet weak var decreasePointLbl: UILabel!
    @IBOutlet weak var afterDecreaseLbl: UILabel!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var selectAllLbl: UILabel!
    
    var sampleArr : [SampleCartStruct] = []
    var isSelectedArr : [Bool] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        purpleTopView.layoutSubviews()
       // purpleTopView.makeRounded(cornerRadius: 7)
        let a = SampleCartStruct(name: "할로윈모자", value: 1, price: 1000)
        let b = SampleCartStruct(name: "호박사탕", value: 2, price: 2000)
        let c = SampleCartStruct(name: "분장", value: 3, price: 3000)
        let d = SampleCartStruct(name: "술", value: 1, price: 4000)
        sampleArr.append(contentsOf: [a,b,c,d])
    
        selectAllLbl.text = "전체선택 \(sampleArr.count)개"
        selectAllLbl.sizeToFit()
        selectAllBtn.setImage(UIImage(named: "aimg"), for: .normal)
        selectAllBtn.setImage(
            UIImage(named: "bimg"), for: .selected)
        selectAllBtn.addTarget(self, action: #selector(selectAllAction(_:)), for: .touchUpInside)
        
        //처음에 전체 선택
        selectAllBtn.isSelected = true
        sampleArr.forEach { (_) in
            isSelectedArr.append(true)
        }
        setPriceLbl()
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        var deleteArr : [SampleCartStruct] = []
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                if isSelectedArr[row] {
                   deleteArr.append(sampleArr[row])
                }
            }
        }
        print(deleteArr)
    }
    
    @objc func selectAllAction(_ sender : UIButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            selectAllRows(selected: true)
        } else {
            selectAllRows(selected: false)
        }
        setPriceLbl()
    }
    
    func selectAllRows(selected : Bool) {
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                isSelectedArr[row] = selected
                tableView.reloadData()
            }
        }
    }
}

//테이블뷰 delegate, datasource
extension CartVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartTVCell.reuseIdentifier) as! CartTVCell
        cell.configure(data: sampleArr[indexPath.row], row : indexPath.row)
        if isSelectedArr.count > 0 {
           cell.selectedConfig(isSelected : isSelectedArr[indexPath.row])
        }
        
        cell.delegate = self
        cell.checkDelegate = self
        return cell
    }
}

//select Delegate
extension CartVC : SelectRowDelegate, CheckDelegate{
    //1. stepper클릭시
    func tap(row: Int, selected: Int) {
        //selected 에 stepper value 담겨져있음. 모델 변경
        sampleArr[row].value = selected
        setPriceLbl()
    }
    
    //2. check 버튼 클릭시
    func check(selected: Int?) {
        //deselect 이면 -, select이면 +
        if selected! > 0 {
            isSelectedArr[selected!-1] = true
        } else {
            isSelectedArr[(-(selected!)-1)] = false
        }
        //tap할때마다 통신 성공하면 개수 label 도 바꾸고 totalPrice도 바꿔줌
        setPriceLbl()
    }
}

//가격 구하고 lbl 세팅하는 함수
extension CartVC {
    
    func setPriceLbl(){
        let currentTotal = getSelectedTotalPrice()
        let totalPrice = currentTotal.price
        let salePercent = currentTotal.salePercent
 
        //유저가 들고 있는 포인트보다 더 커지면 안됨
        var willDecrease = Double(totalPrice)*salePercent.rawValue
        if willDecrease > sampleUser.point {
            willDecrease = sampleUser.point
        }
        
        let afterDecrease = Double(totalPrice)-(willDecrease)
       
        salePercentLbl.text = salePercent.percentString
        decreasePointLbl.text = String(format: "%.0f", willDecrease)+"원"
        afterDecreaseLbl.text = String(format: "%.0f", afterDecrease)+"원"
        afterDecreaseLbl.sizeToFit()
    }
    
    func getSelectedTotalPrice() -> (price : Int, salePercent : SalePercent) {
        struct tempStruct {
            let price : Int
            let count : Int
        }
        var selectedItem : [tempStruct] = []
        var selectedCount = 0
        //선택된 아이템들 고름
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            if isSelectedArr[row] {
                selectedCount += 1
                let tempItem = tempStruct(price: sampleArr[row].price, count: Int(sampleArr[row].value))
                selectedItem.append(tempItem)
            }
        }
        let price = selectedItem.map({ (item) in
            item.price*item.count
        }).reduce(0, +)
        
        /*
         2개 품목: 5%
         3개 품목: 10%
         5개 품목 이상: 15%
         */
        var salePercent : SalePercent = .zero
        if selectedCount >= 5 {
            salePercent = .fifteen
        } else if selectedCount >= 3 {
            salePercent = .ten
        } else if selectedCount >= 2 {
            salePercent = .five
        }
        return (price, salePercent)
    }
}