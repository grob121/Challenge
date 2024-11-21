import Foundation
import RxSwift
import RxDataSources

class MultipleChoiceViewController: UIViewController,
                                    UIScrollViewDelegate,
                                    BindableType  {
  @IBOutlet private weak var questionLabel: UILabel!
  @IBOutlet private weak var selectLabel: UILabel!
  @IBOutlet private weak var choicesTableView: UITableView!
  @IBOutlet private weak var choicesTableViewHeightConstraint: NSLayoutConstraint!
  
  var viewModel: MultipleChoiceViewModel!
  
  private var dataSource: RxTableViewSectionedReloadDataSource<MultipleChoiceSectionModel>!
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    registerCells()
    configureDataSource()
    bindViewModel()
  }
  
  override func viewDidLayoutSubviews() {
    self.choicesTableViewHeightConstraint.constant = self.choicesTableView.contentSize.height + 168
  }
  
  func bindViewModel() {
    viewModel?
      .output
      .question
      .asObservable()
      .bind(to: questionLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel?
      .output
      .hideSelectMessage
      .asObservable()
      .bind(to: selectLabel.rx.isHidden)
      .disposed(by: disposeBag)
  }
  
  private func configureDataSource() {
    dataSource = RxTableViewSectionedReloadDataSource<MultipleChoiceSectionModel>(
      configureCell: { _, tableView, indexPath, item in
        
        let cell = tableView.dequeueReusableCell(withIdentifier: item.identifier, for: indexPath)
        if let cell = cell as? MultipleChoiceBindableType {
          cell.bindItemModel(to: item)
        }
        
        cell.selectionStyle = .none
        return cell
      })
    
    choicesTableView
      .rx
      .setDelegate(self)
      .disposed(by: disposeBag)
    
    choicesTableView
      .rx
      .modelSelected(MultipleChoiceSectionItemModel.self)
      .bind(to: viewModel.input.didSelectItem)
      .disposed(by: disposeBag)
    
    viewModel?
      .output
      .sectionModels
      .asObservable()
      .bind(to: choicesTableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
  
  private func registerCells() {
    var registerCells: [String] = []
    
    registerCells.append(ChoiceTableViewCell.identifier)
    registerCells.append(SeparatorTableViewCell.identifier)
    registerCells.append(ContinueTableViewCell.identifier)
    
    registerCells.forEach { [weak self] identifier in
      guard let self = self else { return }
      
      self.choicesTableView.register(UINib(nibName: identifier, bundle: nil),
                                     forCellReuseIdentifier: identifier)
    }
  }
}
