//
//  CoolTableViewCellExtension.swift
//  KCKField
//
//  Created by Kemal Can Kaynak on 13.11.2018.
//  Copyright © 2018 Kemal Can Kaynak. All rights reserved.
//

import UIKit

public protocol Reusable: class {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

public extension Reusable {
    static var reuseIdentifier: String { return String(describing: self) }
    static var nib: UINib? { return nil }
}

public extension UITableView {
    final func createCell<T: Reusable>(_ indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}

public extension UIDevice {
    var hasNotch: Bool {
        return UIApplication.shared.statusBarFrame.height > 20 ? true : false
    }
}
