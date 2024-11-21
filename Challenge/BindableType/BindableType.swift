import Foundation
import UIKit

protocol ChallengeIdentifiable {
  static var identifier: String { get }
}

extension ChallengeIdentifiable {
  static var identifier: String { String(describing: Self.self)}
}

protocol BindableType {
  associatedtype ViewModelType
  
  var viewModel: ViewModelType! { get set }
  
  func bindViewModel()
}

extension BindableType where Self: UITableViewCell {
  mutating func bindViewModel(to model: Self.ViewModelType) {
    viewModel = model
    bindViewModel()
  }
}

extension BindableType where Self: UICollectionViewCell {
  mutating func bindViewModel(to model: Self.ViewModelType) {
    viewModel = model
    bindViewModel()
  }
}
