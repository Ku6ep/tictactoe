//
//  ViewController.swift
//  SampleTicTacToe
//
//  Created by Anton Umnitsyn on 12.05.2020.
//  Copyright © 2020 Anton Umnitsyn. All rights reserved.
//

import UIKit

class ViewController: BaseViewController {

    let dimensionTextField = UITextField()
    let picker = UIPickerView()
    let pickerData = ["3 X 3", "4 X 4", "5 X 5"]
    var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DLog("#########\n\(getDocumentsDirectory().path)\n#########")
        setupView()
        checkStoredData()
        self.preloadImages(urlStringsArray: ["http://d.michd.me/aa-lab/x_mark.png","http://d.michd.me/aa-lab/o_mark.png"])
    }
    
    private func setupView() {
        view.backgroundColor = .secondarySystemBackground
        let xButton = UIButton(type: .custom)
        xButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        xButton.tag = 0
        self.view.addSubview(xButton)
        xButton.setTitle("Start on X", for: .normal)
        xButton.setTitleColor(.systemGray2, for: .normal)
        xButton.layer.borderColor = UIColor.systemGray2.cgColor
        xButton.layer.borderWidth = 1.0
        xButton.snp.makeConstraints { (make) in
            make.width.equalTo(140)
            make.height.equalTo(40)
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).offset(-30)
        }
        
        let oButton = UIButton(type: .custom)
        oButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        oButton.tag = 1
        self.view.addSubview(oButton)
        oButton.setTitle("Start on O", for: .normal)
        oButton.setTitleColor(.systemGray2, for: .normal)
        oButton.layer.borderColor = UIColor.systemGray2.cgColor
        oButton.layer.borderWidth = 1.0
        oButton.snp.makeConstraints { (make) in
            make.width.equalTo(xButton.snp.width)
            make.height.equalTo(xButton.snp.height)
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).offset(30)
        }
        
        picker.delegate = self
        picker.dataSource = self
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .systemGray2
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicker))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.view.addSubview(dimensionTextField)
        dimensionTextField.placeholder = pickerData[0]
        dimensionTextField.delegate = self
        dimensionTextField.inputView = picker
        dimensionTextField.inputAccessoryView = toolBar
        dimensionTextField.textAlignment = .center
        dimensionTextField.tintColor = .clear
        dimensionTextField.layer.borderColor = UIColor.systemGray2.cgColor
        dimensionTextField.layer.borderWidth = 1.0
        dimensionTextField.snp.makeConstraints { (make) in
            make.width.equalTo(xButton.snp.width)
            make.height.equalTo(xButton.snp.height)
            make.top.equalTo(oButton.snp.bottom).offset(20.0)
            make.centerX.equalTo(self.view)
        }
    }
    
    @objc func donePicker(sender: Any) {
        dimensionTextField.resignFirstResponder()
    }
    
    @objc func buttonPressed(sender: UIButton) {
        let gameViewController = GameViewController()
               gameViewController.selectedSymbol = sender.tag
               gameViewController.cells = selectedRow + 3
               gameViewController.transitioningDelegate = self
               gameViewController.modalPresentationStyle = .custom
               gameViewController.modalPresentationCapturesStatusBarAppearance = true
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (success) in
            sender.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.present(gameViewController, animated: true, completion: nil)
        }
    }
    
    /// checkStoreData function to check if was stored data in UserDefaults and show alert
    private func checkStoredData () {
        if let data = UserDefaults.standard.data(forKey: kArrayStore) {
            do {
                let a = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
                print(a ?? "Nothing")
            }
            catch {
                print("Oops")
            }
            let alert = UIAlertController(title: "Continue", message: "Do you want to continue game?", preferredStyle: .alert)
            let actionYes = UIAlertAction(title: "Yes", style: .default) { (action) in
                let button = UIButton()
                button.tag = UserDefaults.standard.bool(forKey: self.kNextTurn) ? 1 : 0
                self.buttonPressed(sender: button)
            }
            let actionNo = UIAlertAction(title: "No", style: .cancel) { (action) in
                self.clearStoredData()
            }
            alert.addAction(actionYes)
            alert.addAction(actionNo)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            let row = UserDefaults.standard.integer(forKey: kCellsCountStore) - 3
            if row != 0 {
                picker.selectRow(row, inComponent: 0, animated: true)
            }
        }
    }
}

extension ViewController :  UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    // MARK: Picker deleghate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        3
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.text = pickerData[row]
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dimensionTextField.text = pickerData[row]
        selectedRow = row
    }
    
    // MARK: TextField delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == dimensionTextField {
            return false
        }
        return true
    }
}
