import Foundation
import UIKit
import WebKit
class SearchViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate, UIScrollViewDelegate, CanReload {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var searchInput: UITextField!
    @IBOutlet weak var Activity: UIActivityIndicatorView!
    
    @IBAction func buttonTapped(_ sender: Any) {
        if self.webView.canGoBack {
            self.webView.scrollView.setContentOffset(self.webView.scrollView.contentOffset, animated: false)
            self.webView.goBack()
		}
    }


    func reload() {
        webView.reload()
    }    

    override func viewDidLoad() {
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.backForwardList.perform(Selector(("_removeAllItems")))
		webView.scrollView.delegate = self
        webView.addObserver(self, forKeyPath: "URL", options: [.new, .old], context: nil)
        webView.customUserAgent = "DEV-Native-iOS"
        if let url = URL(string: "https://dev.to/search?rand="+MainHelper.randomString(length: 10)) {
            webView.load(URLRequest.init(url: url))
        }
        searchInput.delegate = self
        searchInput.returnKeyType = .search
        searchInput.text = ""
        self.Activity.startAnimating()
        self.Activity.hidesWhenStopped = true
        webView.backForwardList.perform(Selector(("_removeAllItems")))
		
    }
	    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        manageBackButton()
    }
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.searchInput.endEditing(true)
	}
    
    func manageBackButton(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { //race condition hack
            self.leftButton?.isEnabled = self.webView.canGoBack
            self.leftButton?.tintColor = self.webView.canGoBack ? .black : .clear
            if (!self.webView.canGoBack) {
                self.searchInput.text = ""
            }

        }
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        guard let searchKeywordText = textField.text,
            !searchKeywordText.isEmpty
        else {
            // do not perform any search if text file is nil or empty
            textField.resignFirstResponder()
            return true
        }
        
        searchInput.endEditing(true)
       
        if let searchURL = DevServiceURL.search(parameter: searchKeywordText).fullURL {
			Activity.startAnimating()
            webView.load(URLRequest.init(url: searchURL))
            manageBackButton()
        }
        
        textField.resignFirstResponder()

        manageBackButton()
       
        return true
    }
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.searchInput.endEditing(true)
	}
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Activity.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Activity.stopAnimating()
    }

}
