//
//  SearchViewController.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class SearchViewController: LLViewController, LoaderPresenting {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: DesignableTextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var hintsTableView: UITableView!
    @IBOutlet weak var showConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideConstraint: NSLayoutConstraint!
    
    private lazy var backgroundView = TableBackgroundView()
    lazy var loader = LoaderView()
    
    var searchHistory = [String]() {
        didSet {
            tableView.reloadData()
            backgroundView.alpha = searchHistory.isEmpty ? 1 : 0
        }
    }
    var hints = [String]() {
        didSet {
            hintsTableView.isHidden = hints.isEmpty
            hintsTableView.reloadData()
        }
    }
    
    var query = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView.set(image: #imageLiteral(resourceName: "icSearchFScreen"))
        backgroundView.setTitleText(NSLocalizedString("Вы еще ничего не искали", comment: ""))
        
        tableView.backgroundView = backgroundView
        tableView.backgroundColor = .white
        tableView.registerCell(for: HistoryTableViewCell.self)
        hintsTableView.registerCell(for: HintTableViewCell.self)
        hintsTableView.backgroundColor = .white
        
        cancelButton.isHidden = true
        hintsTableView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.isTranslucent = false
        
        getSearchHistory()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.isScrollEnabled = scrollView.contentSize.height > UIScreen.main.bounds.height
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    //=========================================================
    // MARK: - Actions
    //=========================================================
    
    @IBAction func cancelSearch(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    func search(query: String) {
        AnalyticsManager.shared.logEvent(name: Constants.Events.searchClicked)
        tableView.alpha = 0
        showLoader(text: "Идет поиск...\nПодождите, пожалуйста")
        NetworkManager.getEvents(query: query) { [weak self]  (events, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                if let events = events {
                    EventsManager.events = events
                    if let searchResultsVC = UIStoryboard.get(flow: .searchFlow).get(controller: .searchResultsVC) as? SearchResultsViewController {
                        searchResultsVC.events = events
                        searchResultsVC.query = query
                        self?.navigationController?.pushViewController(searchResultsVC, animated: false)
                    }
                }
                
                let empty = events?.isEmpty ?? true
                let params: [String: Any] = [Constants.Parameters.empty : empty]
                AnalyticsManager.shared.logEvent(name: Constants.Events.searchCompleted, parameters: params)
                self?.dismissLoader()
                self?.tableView.alpha = 1
            }
        }
    }
    
    func getSearchHistory() {
        if let history = RealmManager.getObjects(type: SearchResult.self, withFilter: nil) {
            let mappedHistory = history.map({ (result) -> String in
                return result.query
            })
            self.searchHistory = mappedHistory.reversed()
        }
    }
    
    func getHints(query: String) {
        hints = searchHistory.filter({$0.lowercased().contains(query.lowercased())})
    }
    
    //=========================================================
    // MARK: - Notifications
    //=========================================================
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        if let keyboardSize = keyboardFrame?.cgRectValue {
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
            let yPoint = titleLabel.frame.maxY + 10
            self.scrollView.setContentOffset(CGPoint(x: 0, y: yPoint), animated: true)
            UIView.animate({
                self.cancelButton.isHidden = false
                self.titleLabel.isHidden = true
                self.scrollView.contentInset = insets
                self.scrollView.scrollIndicatorInsets = insets
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate({
            self.searchTextField.text = ""
            self.hintsTableView.isHidden = true
            self.cancelButton.isHidden = true
            self.titleLabel.isHidden = false
            self.scrollView.contentInset = .zero
            self.scrollView.scrollIndicatorInsets = .zero
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.view.layoutIfNeeded()
        })
    }

    private func animateFloatingTitle(show: Bool) {
        view.layoutIfNeeded()
        
        if show {
            hideConstraint.isActive = false
            showConstraint.isActive = true
        } else {
            showConstraint.isActive = false
            hideConstraint.isActive = true
        }
        
        UIView.animate(withDecision: true,
                       animations: {
            self.view.layoutIfNeeded()
        })
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == hintsTableView ? hints.count : searchHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == hintsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HintTableViewCell.self)) as! HintTableViewCell
            cell.hint = hints[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HistoryTableViewCell.self)) as! HistoryTableViewCell
            cell.query = searchHistory[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == hintsTableView {
            query = hints[indexPath.row]
            hints = []
        } else {
            query = searchHistory[indexPath.row]
        }
        searchTextField.text = query
        searchTextField.becomeFirstResponder()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isNavigationTitleHidden = !scrollView.bounds.contains(titleLabel.frame)
        animateFloatingTitle(show: isNavigationTitleHidden)
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if let query = textField.text, !query.isEmpty {
            let searchResult = SearchResult(query: query)
            RealmManager.addOrUpdate(object: searchResult)
            searchTextField.text = ""
            search(query: query)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let query = text.replacingCharacters(in: textRange, with: string)
            getHints(query: query)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        AnalyticsManager.shared.logEvent(name: Constants.Events.startSearch)
    }
}
