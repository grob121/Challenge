import RxSwift
import RxCocoa

class SeparatorTableViewCell: UITableViewCell,
                              BindableType,
                              MultipleChoiceBindableType {
  var viewModel: SeparatorTableViewModelType!
  
  func bindViewModel() { }
}
