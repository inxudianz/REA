//
//  ViewController.swift
//  Coba
//
//  Created by Evan Christian on 06/11/19.
//  Copyright © 2019 Evan Christian. All rights reserved.
//

import UIKit
import MobileCoreServices
import PDFKit

class ViewController: UIViewController, UIDocumentMenuDelegate,UIDocumentPickerDelegate,UINavigationControllerDelegate {
    var urlPicked:URL?
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        print("import result : \(myURL)")
        urlPicked = myURL
        print(urlPicked)
    }
    
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func testButtonTapped(_ sender: Any) {
        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    @IBAction func readButtonTapped(_ sender: Any) {
        if let pdf = PDFDocument(url: urlPicked!) {
            let pageCount = pdf.pageCount
            let documentContent = NSMutableAttributedString()
            print("aw")
            print(pageCount)
            for i in 0 ..< pageCount {
                guard let page = pdf.page(at: i) else { continue }
                guard let pageContent = page.attributedString else { continue }
                documentContent.append(pageContent)
            }
            print("\(documentContent)")
        }
    }
}

