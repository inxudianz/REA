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
    var urlPicked: URL?
    var isEdit = false
    var selectedItem = [Int]()
    
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
    
    @objc func deleteButton() {
        navBar.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButton))
        navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButton))

        let cellAdd = cvCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! AddCollectionViewCell
        
        cellAdd.isUserInteractionEnabled = false
        
        isEdit = true
    }
    
    @objc func cancelButton() {
        let cell = cvCollectionView.visibleCells
        let clearSelectedItem = [Int]()
        
        self.navBar.leftBarButtonItem?.isEnabled = false
        self.navBar.leftBarButtonItem?.tintColor = UIColor.clear
        self.navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteButton))
        
        self.selectedItem = clearSelectedItem
        //setChecklist.checklistImg.image = UIImage(named: "CombinedShape")
        
        for editCell in cell {
            editCell.layer.backgroundColor = .none
        }
        
        let cellAdd = cvCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! AddCollectionViewCell
        cellAdd.isUserInteractionEnabled = true
        
        self.isEdit = false
    }
    
    @objc func doneButton() {
        if selectedItem.count == 0 {
            self.navBar.leftBarButtonItem?.isEnabled = false
            self.navBar.leftBarButtonItem?.tintColor = UIColor.clear
            self.navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteButton))
        } else {
            let cell = cvCollectionView.visibleCells
            
            
            let alert = UIAlertController(title: "Delete CV", message: "This CV will be deleted from iCloud Documents on all your devices.", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete CV", style: .default, handler: { action in
                print("Data Kehapus")
                
                for item in 0..<self.selectedItem.count {
                    //print(self.selectedItem[item])
                    self.contents.removeAll{$0.cvName == self.tempContents[self.selectedItem[item]-1].cvName}
                }
                
                self.selectedItem.removeAll()
                self.tempContents = self.contents
                self.cvCollectionView.reloadData()
                
                self.cvCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.navBar.leftBarButtonItem?.isEnabled = false
                self.navBar.leftBarButtonItem?.tintColor = UIColor.clear
                self.navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteButton))
                
                for editCell in cell {
                    editCell.layer.backgroundColor = .none
                }
                
                self.isEdit = false
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
            let cellAdd = cvCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! AddCollectionViewCell
            cellAdd.isUserInteractionEnabled = true
            
            self.isEdit = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 154.0, height: 277.0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cellAddCv = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCollectionViewCell", for: indexPath) as? AddCollectionViewCell
            
            cellAddCv?.addNewCvBtn.tag = indexPath.row
            cellAddCv?.addNewCvBtn.addTarget(self, action: #selector(importCV(sender:)), for: .touchUpInside)
            
            return cellAddCv!
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CVCollectionViewCell", for: indexPath) as? CVCollectionViewCell
            let content = contents[indexPath.row - 1]
            
            cell?.content = content
            
            if selectedItem.contains(indexPath.row){
                cell?.backgroundColor = .lightGray
            } else {
                cell?.backgroundColor = .clear
            }
            
            return cell!
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEdit == true {
            if !selectedItem.contains(indexPath.row){
                selectedItem.append(indexPath.row)
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
        
        let size = CGSize(width: 140, height: 211)
        let thumbnail = generatePdfThumbnail(of: size, for: urlPicked!, atPage: 0)
        let fileName = urlPicked!.lastPathComponent
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "dd-MM-yyyy"
        let formattedDate = format.string(from: date)
        
        contents.append(HomeContent(cvId: UUID(), cvImage: thumbnail!, cvName: fileName, cvCreated: formattedDate))
        tempContents = contents
        cvCollectionView.reloadData()
        
    }
    
    @objc func importCV(sender: UIButton!) {
        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    //view was cancelled
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
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
    
    //menampilkan pdf file
    func generatePdfThumbnail(of thumbnailSize: CGSize , for documentUrl: URL, atPage pageIndex: Int) -> UIImage? {
        let pdfDocument = PDFDocument(url: documentUrl)
        let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
        return pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
    }
    
}



