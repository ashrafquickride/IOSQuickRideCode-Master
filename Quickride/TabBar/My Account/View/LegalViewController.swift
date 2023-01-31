//
//  LegalViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 09/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class LegalViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var backButton: CustomUIButton!
    private var legalTerms = [LegalTerm]()
    static let LEGAL_TERMS_URL = "https://quickride.in/privacy-policy.php"

    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }

    private func prepareView() {
        backButton.changeBackgroundColorBasedOnSelection()
        legalTerms = [LegalTerm(title: "Privacy Policy", url: LegalViewController.LEGAL_TERMS_URL), LegalTerm(title: "Terms & Condition", url: HelpViewController.TERMSURL)]

    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
}

//MARK: UITableViewDataSource
extension LegalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         legalTerms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NeedHelpTableViewCell", for: indexPath) as! NeedHelpTableViewCell
        cell.titleLabel.text = legalTerms[indexPath.row].title
        return cell
    }
}

//MARK: UITableViewDataSource
extension LegalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moveToWeb(title: legalTerms[indexPath.row].title ?? "", url: legalTerms[indexPath.row].url ?? "")
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func moveToWeb(title: String, url: String) {
        let queryItems = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string: url)
        urlcomps?.queryItems = [queryItems]
        if urlcomps?.url != nil {
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: title, url: urlcomps!.url!, actionComplitionHandler: nil)
            self.navigationController?.pushViewController(webViewController, animated: false)
        } else {
            UIApplication.shared.keyWindow?.makeToast(Strings.cant_open_this_web_page)
        }
    }
}

struct LegalTerm {
    var title: String?
    var url: String?

    init(title: String, url: String) {
        self.title = title
        self.url = url
    }
}
