import Foundation
import RxSwift
import RxDataSources

struct MultipleChoiceSectionModel {
  var items: [MultipleChoiceSectionItemModel]
}

extension MultipleChoiceSectionModel: SectionModelType {
  init(original: MultipleChoiceSectionModel,
       items: [MultipleChoiceSectionItemModel]) {
    self = original
    self.items = items
  }
}

enum MultipleChoiceSectionItemModel {
  case choice(viewModel: ChoiceTableViewModelType)
  case separator(viewModel: SeparatorTableViewModelType)
  case continueButton(viewModel: ContinueTableViewModelType)
}

extension MultipleChoiceSectionItemModel {
  
  var identifier: String {
    switch self {
      case .choice: return ChoiceTableViewCell.identifier
      case .separator: return SeparatorTableViewCell.identifier
      case .continueButton: return ContinueTableViewCell.identifier
    }
  }
  
  func viewModel<T>() -> T {
    switch self {
      case let .choice(viewModel):
        return viewModel as! T
      case let .separator(viewModel):
        return viewModel as! T
      case let .continueButton(viewModel):
        return viewModel as! T
    }
  }
}
