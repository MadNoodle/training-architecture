import UIKit


class SecretDetailsViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var passwordLabel: UILabel!
    
    fileprivate var presenter: SecretDetailPresenter!
    weak var navigationCoordinator: NavigationCoordinator?
    
    init(with presenter: SecretDetailPresenter, navigationCoordinator: NavigationCoordinator) {
        self.presenter = presenter
        self.navigationCoordinator = navigationCoordinator
        
        super.init(nibName: "SecretDetailsViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showPassword()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingToParentViewController {
            self.navigationCoordinator!.movingBack()
        }
    }
    
    func showPassword() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        passwordLabel.text = presenter.password
    }

}
