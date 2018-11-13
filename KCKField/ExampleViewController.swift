//
//  ViewController.swift
//  KCKField
//
//  Created by Kemal Can Kaynak on 13.11.2018.
//  Copyright © 2018 Kemal Can Kaynak. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {

    @IBOutlet weak var exampleTableView: UITableView!
    
    fileprivate lazy var genericPickerView: UIPickerView = {
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIDevice.current.hasNotch ? 213 : 180))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = .white
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.showsSelectionIndicator = true
        return pickerView
    }()
    fileprivate final let pickerData = ["München", "Berlin", "Oslo", "London", "İstanbul"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exampleTableView.tableFooterView = UIView()
    }
    
    func pushThis() {
        let secondVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondPage")
        self.navigationController?.pushViewController(secondVC, animated: true)
    }
}

// MARK: - UIPickerView Data Source -

extension ExampleViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
}

// MARK: - UIPickerView Delegate -

extension ExampleViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if let exampleCell = exampleTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ExampleTableCell {
            exampleCell.pickerField.text = pickerData[row]
        }
    }
}

// MARK: - UITableView Data Source -

extension ExampleViewController: UITableViewDataSource, Reusable {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let exampleCell: ExampleTableCell = tableView.createCell(indexPath)
        exampleCell.pickerField.delegate = self
        exampleCell.multiLineField.delegate = self
        exampleCell.passwordField.delegate = self
        exampleCell.pickerField.fieldInputView = genericPickerView
        exampleCell.selectField.tapAction = { [unowned self] in
            self.pushThis()
        }
        return exampleCell
    }
}
    
// MARK: - KCKField Delegate -

extension ExampleViewController: KCKFieldDelegate {
    
    func fieldDidChange(_ field: KCKField) {
        if field.tag == 30 {
            UIView.performWithoutAnimation {
                self.exampleTableView.beginUpdates()
                self.exampleTableView.endUpdates()
            }
        }
    }
}

// MARK: - Custom Example Cell -

class ExampleTableCell: UITableViewCell, Reusable {
    @IBOutlet weak var pickerField: KCKField!
    @IBOutlet weak var selectField: KCKField!
    @IBOutlet weak var multiLineField: KCKField!
    @IBOutlet weak var passwordField: KCKField!
    
    override func awakeFromNib() {
        multiLineField.maxCharacter = 50
    }
}
