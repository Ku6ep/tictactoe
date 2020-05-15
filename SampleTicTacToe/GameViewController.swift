//
//  GameViewController.swift
//  SampleTicTacToe
//
//  Created by Anton Umnitsyn on 12.05.2020.
//  Copyright © 2020 Anton Umnitsyn. All rights reserved.
//

import UIKit

class GameViewController: BaseViewController {
    
    public var cells: Int!
    public var selectedSymbol: Int!
    
    private var selectedImage: UIImage!
    private var secondImage: UIImage!
    private var stepCounter: Int!
    private var turnX: Bool!
    private let turnLabel = UILabel()
    private var turnsArray: Array<Array<String>>!
    private let defaults = UserDefaults.standard
    private var restoreState = false
    private var xImage: UIImage!
    private var oImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepCounter = 0
        setupImages()
        
        switch selectedSymbol {
        case 0:
            selectedImage = xImage
            secondImage = oImage
            turnX = true
        default:
            selectedImage = oImage
            secondImage = xImage
            turnX = false
        }
        turnLabel.text = turnX ? ("Turn X") : ("Turn O")
        
        defaults.set(cells, forKey: kCellsCountStore)
        defaults.synchronize()
        if let data = defaults.data(forKey: kArrayStore) {
            do {
                let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
                turnsArray = array as? Array<Array<String>>
                restoreState = true
            }
            catch {
                print("Can't resore data")
            }
        }
        setupViews()
    }
    
    private func setupImages() {
        if let tmpXimage = UIImage(contentsOfFile: getDocumentsDirectory().appendingPathComponent("file0.png").path)?.withRenderingMode(.alwaysTemplate) {
            xImage = tmpXimage
        }
        else {
            xImage = UIImage(named: "x_mark")?.withRenderingMode(.alwaysTemplate)
        }
        
        if let tmpOimage = UIImage(contentsOfFile: getDocumentsDirectory().appendingPathComponent("file1.png").path)?.withRenderingMode(.alwaysTemplate) {
            oImage = tmpOimage
        }
        else {
            oImage = UIImage(named: "o_mark")?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    private func setupViews() {
        let containerVertical = UIStackView()
        containerVertical.addBackground(color: .systemGray)
        containerVertical.axis = .vertical
        containerVertical.alignment = .fill
        containerVertical.distribution = .fillEqually
        containerVertical.spacing = 10.0
        self.view.addSubview(containerVertical)
        containerVertical.snp.makeConstraints { (make) in
            make.width.height.equalTo(300.0)
            make.center.equalTo(self.view)
        }
        if !restoreState {
            turnsArray = Array()
        }
        for x in 0..<cells  {
            let containerHorizontal = UIStackView()
            containerHorizontal.addBackground(color: .systemGray)
            containerHorizontal.axis = .horizontal
            containerHorizontal.alignment = .fill
            containerHorizontal.distribution = .fillEqually
            containerHorizontal.spacing = 10.0
            containerHorizontal.tag = x
            var tmpArray: Array<String> = Array()
            for y in 0..<cells {
                let button = UIButton(type: .custom)
                button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                button.backgroundColor = .systemBackground
                button.tintColor = .systemGray
                button.tag = 10*x+y
                containerHorizontal.addArrangedSubview(button)
                if !restoreState {
                    tmpArray.append("")
                }
                else {
                    let storedSymbol = turnsArray[x][y]
                    if storedSymbol != "" {
                        button.setImage(storedSymbol == "x" ? xImage : oImage, for: .normal)
                        button.isEnabled = false
                        stepCounter += 1
                    }
                }
            }
            containerVertical.addArrangedSubview(containerHorizontal)
            if !restoreState {
                turnsArray.append(tmpArray)
            }
        }
        
        self.view.addSubview(turnLabel)
        turnLabel.textAlignment = .center
        turnLabel.textColor = .darkText
        turnLabel.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(40)
            make.top.equalTo(containerVertical.snp.bottom).offset(20.0)
            make.centerX.equalTo(self.view)
        }
    }
    
    @objc func buttonTapped(sender: UIButton) {
        sender.alpha = 0
        sender.setImage(selectedImage, for: .normal)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            sender.alpha = 1.0
        }, completion: nil)
        sender.isEnabled = false
        turnsArray[abs(sender.tag/10)][sender.tag%10] = turnX ? "x" : "o"
        if checkResult() {
            showAlert(message: "\(turnX ? "X" : "O") win!", isWin: true)
        }
        else if stepCounter == Int(pow(Double(turnsArray.count),Double(2))) - 1 {
            showAlert(message: "A drow!", isWin: false)
        }
        else {
            storeState()
            turnX = !turnX
            turnLabel.text = turnX ? ("Turn X") : ("Turn O")
            togleImage()
        }
    }
    
    private func takeScreenShot()->UIImage? {
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func showAlert(message: String, isWin:Bool) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "New game", style: .destructive) { (action) in
            self.clearStoredData()
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        if isWin {
            let shareAction = UIAlertAction(title: "Share", style: .default) { (action) in
                self.showActionView(message: message)
            }
            alert.addAction(shareAction)
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showActionView(message: String) {
        if let screenshotImage = self.takeScreenShot() {
            let activityVC = UIActivityViewController(activityItems: [screenshotImage], applicationActivities: nil)
            activityVC.excludedActivityTypes = [.saveToCameraRoll]
            activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                if !completed {
                    self.showAlert(message: message, isWin: true)
                }
                else {
                    self.clearStoredData()
                    self.dismiss(animated: true, completion: nil)
                }
            }
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    /// Function to save current game state in UserDefault
    private func storeState() {
        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: turnsArray as Any, requiringSecureCoding: false)
            defaults.set(encodedData, forKey:kArrayStore)
            defaults.set(turnX, forKey:kNextTurn)
            defaults.synchronize()
        }
        catch {
            print("Can't store")
        }
    }
    
    /// Function for switch current symdol to insert
    private func togleImage() {
        let tmpImage = selectedImage
        selectedImage = secondImage
        secondImage = tmpImage
        stepCounter += 1
    }
    
    /// checkResult - function for check result of each turn
    /// - Returns: bool value: true if it was win turn and false if not
    private func checkResult() -> Bool {
        if stepCounter < 4 { return false }
        var winner = ""
        if turnX {
            winner = checkColAndRowsForSymbol(symbol: "x") ?
                "x" : checkDiagonaleForSymbol(symbol: "x") ?
                    "x" : ""
        }
        else {
            winner = checkColAndRowsForSymbol(symbol: "o") ?
                "o" : checkDiagonaleForSymbol(symbol: "o") ?
                    "o" : ""
        }
        if winner != "" {
            return true
        }
        return false
    }
    
    /// Function to check diagonales
    ///- Parameter symbol: String value with symbol to check
    ///- Returns:bool value. True if find filled diagonale
    private func checkDiagonaleForSymbol(symbol: String) -> Bool {
        var toleft = true
        var toright = true
        let count = turnsArray.count
        for index in 0..<count {
            toright = toright && turnsArray[index][index] == symbol
            toleft = toleft && turnsArray[count - index - 1][index] == symbol
        }
        return toleft || toright
    }
    
    /// Function to check rows and columns
    ///- Parameter symbol:String value with symbol to check
    ///- Returns:bool value. True if find filled row or column
    private func checkColAndRowsForSymbol(symbol: String) -> Bool {
        var cols: Bool!
        var rows: Bool!
        for col in 0..<turnsArray.count {
            cols = true
            rows = true
            for row in 0..<turnsArray.count {
                cols = cols && turnsArray[col][row] == symbol
                rows = rows && turnsArray[row][col] == symbol
            }
            if cols || rows {
                return true
            }
        }
        return false
    }
}
