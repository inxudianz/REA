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
    var cellColour = true

    var isEdit = false
    var selectedItem = [Int]()
    var name: String?
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var cvCollectionView: UICollectionView!
    @IBOutlet weak var navBar: UINavigationItem! {
        didSet {
            navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButton))
        }
    }
    
    @objc func deleteButton() {
        navBar.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButton))
        navBar.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .done, target: self, action: #selector(doneButton))
        
        isEdit = true
        cvCollectionView.reloadData()
    }
    
    @objc func cancelButton() {
        let clearSelectedItem = [Int]()
        
        self.navBar.leftBarButtonItem?.isEnabled = false
        self.navBar.leftBarButtonItem?.tintColor = UIColor.clear
        self.navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteButton))
        
        self.selectedItem = clearSelectedItem
        
        self.isEdit = false
        cvCollectionView.reloadData()
    }
    
    @objc func doneButton() {
        let clearSelectedItem = [Int]()
        
        if selectedItem.count == 0 {
            self.navBar.leftBarButtonItem?.isEnabled = false
            self.navBar.leftBarButtonItem?.tintColor = UIColor.clear
            self.navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteButton))
            
            self.isEdit = false
            cvCollectionView.reloadData()
        } else {

            let alert = UIAlertController(title: "Delete CV", message: "This CV will be deleted from iCloud Documents on all your devices.", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete CV", style: .default, handler: { action in
                
                for item in 0..<self.selectedItem.count {
                    self.contents.removeAll{$0.cvName == self.tempContents[self.selectedItem[item]-1].cvName}
                }
                
                self.selectedItem.removeAll()
                self.tempContents = self.contents
                self.cvCollectionView.reloadData()
                
                self.cvCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.navBar.leftBarButtonItem?.isEnabled = false
                self.navBar.leftBarButtonItem?.tintColor = UIColor.clear
                self.navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteButton))
                
                self.isEdit = false
                self.cvCollectionView.reloadData()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                self.selectedItem = clearSelectedItem
                self.isEdit = true
                self.cvCollectionView.reloadData()
            }))
            
            present(alert, animated: true, completion: nil)
            
            self.isEdit = false
            cvCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        cvCollectionView.register(UINib(nibName: "HomeCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HomeCollectionReusableViewID")
        cvCollectionView.register(UINib(nibName: "AddNewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AddNewCollectionViewCellID")
        cvCollectionView.register(UINib(nibName: "CVNewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CVNewCollectionViewCellID")
    }
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOverview" {
            if let overviewViewController = segue.destination as? OverviewViewController {
                    overviewViewController.nama = name
            }
        }
    }
        
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count + 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeCollectionReusableViewID", for: indexPath) as? HomeCollectionReusableView {
        
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cellAddCv = collectionView.dequeueReusableCell(withReuseIdentifier: "AddNewCollectionViewCellID", for: indexPath) as? AddNewCollectionViewCell
            
            cellAddCv?.addNewCvBtn.tag = indexPath.row
            cellAddCv?.addNewCvBtn.addTarget(self, action: #selector(importCV(sender:)), for: .touchUpInside)
            
            if isEdit == true {
                cellAddCv?.isUserInteractionEnabled = false
            } else {
                cellAddCv?.isUserInteractionEnabled = true
            }
            
            return cellAddCv!
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CVNewCollectionViewCellID", for: indexPath) as? CVNewCollectionViewCell
            let content = contents[indexPath.row - 1]
            
            cell?.content = content
            
            if isEdit == true {
                if selectedItem.contains(indexPath.row){
                    cell?.backgroundColor = .lightGray
                    cell?.checklistImg.image = UIImage(named: "Checklist")
                } else {
                    cell?.backgroundColor = .clear
                    cell?.checklistImg.image = UIImage(named: "CombinedShape")
                }
            } else {
                cell?.checklistImg.image = .none
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
            let content = contents[indexPath.row - 1]
            name =
                content.cvName
            print(name)
            performSegue(withIdentifier: "goToOverview", sender: self)
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
        
        contents.insert(HomeContent(cvId: UUID(), cvImage: thumbnail!, cvName: fileName, cvCreated: formattedDate), at: 0)
        tempContents = contents
        cvCollectionView.reloadData()
        performSegue(withIdentifier: "gotoprocess", sender: self)

        
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
    
    //menampilkan pdf file
    func generatePdfThumbnail(of thumbnailSize: CGSize , for documentUrl: URL, atPage pageIndex: Int) -> UIImage? {
        let pdfDocument = PDFDocument(url: documentUrl)
        let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
        return pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
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



