import UIKit
import Toaster
import Foundation
import RxSwift
import RxDataSources
import RxCocoa

class SpyListViewController: UIViewController, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    weak var navigationCoordinator: NavigationCoordinator?
    
    fileprivate var presenter: SpyListPresenter!
    fileprivate var spyCellMaker: DependencyRegistry.SpyCellMaker!
    private var bag = DisposeBag()
    
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<SpySection> = {
        let dataSource = RxTableViewSectionedReloadDataSource<SpySection>(configureCell: {
        [weak self] ( _ , tableView, indexPath, spy) -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }
        return self.spyCellMaker(tableView, indexPath, spy)
        })
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
    return dataSource
        
    }()
    
    func configure(with presenter: SpyListPresenter,
                   navigationCoordinator: NavigationCoordinator,
                   spyCellMaker: @escaping DependencyRegistry.SpyCellMaker ) {
        self.presenter = presenter
        self.navigationCoordinator = navigationCoordinator
        self.spyCellMaker = spyCellMaker
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(updateData))
        SpyCell.register(with: tableView)
        bind()
        presenter.loadData { [weak self] source in
            self?.newDataReceived(from: source)
        }
    }
    
    func newDataReceived(from source: Source) {
        Toast(text: "New Data from \(source)").show()
        tableView.reloadData()
    }
    
    @IBAction func updateData(_ sender: Any) {
        presenter.transform()
    }
}

extension SpyListViewController {
    func bind() {
        presenter.sections.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        tableView.rx.itemSelected.map {
            indexpath in
            return (indexpath, self.dataSource[indexpath])
        }
        .subscribe(onNext: { [weak self] indexPath, spy in
            self?.navigationCoordinator!.next(arguments: ["spy": spy])
        })
        .disposed(by: bag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)
    }
}

//MARK: - UITableViewDelegate
extension SpyListViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 126
    }
    
}



