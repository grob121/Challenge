import Foundation
import RxSwift

protocol MultipleChoiceBindableType: ChallengeIdentifiable {
  func bindItemModel(to itemModel: MultipleChoiceSectionItemModel)
}

extension MultipleChoiceBindableType where Self: UITableViewCell & BindableType {
  func bindItemModel(to itemModel: MultipleChoiceSectionItemModel) {
    guard let viewModel: ViewModelType = itemModel.viewModel() else {
      fatalError("viewmodel not match@")
    }
    
    var cell = self
    cell.bindViewModel(to: viewModel)
  }
}

extension MultipleChoiceBindableType where Self: UICollectionViewCell & BindableType {
  func bindItemModel(to itemModel: MultipleChoiceSectionItemModel) {
    guard let viewModel: ViewModelType = itemModel.viewModel() else {
      fatalError("viewmodel not match@")
    }
    var cell = self
    cell.bindViewModel(to: viewModel)
  }
}
