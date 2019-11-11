//
//  HomeViewController.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 07/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import UIKit
import MobileCoreServices
import PDFKit

class HomeViewController: UIViewController {
    
    var contents: [HomeContent] = HomeContent.createHomeContent()
    var tempContents : [HomeContent] = HomeContent.createHomeContent()
    var itemsSelected = [IndexPath]()
    var urlPicked: URL?
    var cellColour = true
    var isDelete = false
    var tesDelete = false
    var selectedItem = [Int]() // yang bener
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var cvCollectionView: UICollectionView! {
        didSet {
            cvCollectionView?.allowsMultipleSelection = true
        }
    }
    @IBOutlet weak var navBar: UINavigationItem! {
        didSet {
            navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButton))
        }
    }
    @IBAction func addNewBtn(_ sender: Any) {
        importCV()
    }
    @objc func deleteButton() {
        navBar.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButton))
        navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButton))
        isDelete = true
    }
    @objc func cancelButton() {
        let cell = cvCollectionView.visibleCells
        navBar.leftBarButtonItem?.isEnabled = false
        navBar.leftBarButtonItem?.tintColor = UIColor.clear
        navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButton))
        
        for editCell in cell {
            editCell.layer.backgroundColor = .none
        }
        
        isDelete = false
    }
    @objc func doneButton() {
//        itemsSelected.forEach {
//            contents.remove(at: $0.row)
//
//        }
//
//        cvCollectionView.deleteItems(at: itemsSelected)
//        itemsSelected.removeAll()
        
        let cell = cvCollectionView.visibleCells
        
//        if let selectedCells = cvCollectionView.indexPathsForSelectedItems {
//          // 1
//          let items = selectedCells.map { $0.item }.sorted().reversed()
//          // 2
//          for item in items {
//              contents.remove(at: item)
//          }
//          // 3
//          cvCollectionView.deleteItems(at: selectedCells)
//            isDelete = false
//        }
        for item in 0..<selectedItem.count{
            print(selectedItem[item])
            contents.removeAll{$0.cvName == tempContents[selectedItem[item]].cvName}
        }
        selectedItem.removeAll()
        tempContents = contents
        isDelete = false
        cvCollectionView.reloadData()
        cvCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        navBar.leftBarButtonItem?.isEnabled = false
        navBar.leftBarButtonItem?.tintColor = UIColor.clear
        navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButton))
        
        for editCell in cell {
            editCell.layer.backgroundColor = .none
        }
        
        //isDelete = false
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    func removeFromArray(indexPath : IndexPath){
        for array in 0..<selectedItem.count{
            if indexPath.row == selectedItem[array]{
                selectedItem.remove(at: array)
                self.cvCollectionView.reloadData()
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 154.0, height: 277.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CVCollectionViewCell", for: indexPath) as? CVCollectionViewCell
        
//        if indexPath.row == 0 {
//            cell?.cvNameLbl.text = ""
//            cell?.cvDateLbl.text = ""
//        } else {
        let content = contents[indexPath.row]
        cell?.content = content
        if selectedItem.contains(indexPath.row){
            cell?.backgroundColor = .lightGray
        } else {
            cell?.backgroundColor = .clear
        }
//        }
        
        return cell!
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isDelete == true {
            if !selectedItem.contains(indexPath.row){
                selectedItem.append(indexPath.row)
                print(indexPath.row)
                collectionView.reloadData()
            } else {
                selectedItem.removeAll{$0 == indexPath.row}
                collectionView.reloadData()
            }
        } else {
            print("Delete button not selected")
        }
    }
    
}


extension HomeViewController: UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    
    //mengambil url file
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        urlPicked = myURL
        print(urlPicked)
        //showPDFThumbnail()
        //readPDFFile()
        
    }
    
    func importCV() {
        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    //menampilkan pdf file
    func generatePdfThumbnail(of thumbnailSize: CGSize , for documentUrl: URL, atPage pageIndex: Int) -> UIImage? {
        let pdfDocument = PDFDocument(url: documentUrl)
        let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
        return pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
    }
    
    //menampilkan thumbnail pdf ke view controller
    func showPDFThumbnail() {
         let thumbnailSize = CGSize(width: 100, height: 100)
         let thumbnail = generatePdfThumbnail(of: thumbnailSize, for: urlPicked!, atPage: 0)
         thumbnailImage.image = thumbnail
    }
    
    //ubah pdf ke string
    func readPDFFile(){
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



