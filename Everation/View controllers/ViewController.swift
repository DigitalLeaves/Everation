//
//  ViewController.swift
//  Everation
//
//  Created by Ignacio Nieto Carvajal on 23/07/2017.
//  Copyright © 2017 Digital Leaves. All rights reserved.
//

import UIKit
import MobileCoreServices

private let kEverationSpan: CGFloat = 10.0
private let kEverationAspectRatio: CGFloat = 120.0/100.0

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIDragInteractionDelegate, UIDropInteractionDelegate {
    // outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // data
    var everitems: [EverItem] = arrayOfSampleItems()
    var cellSize = CGSize.zero
    var originIndexPath: IndexPath?
    var destinationIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // load cells for our collection view
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        collectionView.register(UINib(nibName: "TextCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TextCollectionViewCell")
        
        // calculate cell width
        calculateCellWidth()
        
        // Set drag and drop interactions
        pasteConfiguration = UIPasteConfiguration(acceptableTypeIdentifiers: [kUTTypeText as String, kUTTypePlainText as String, kUTTypeImage as String])
        collectionView.addInteraction(UIDragInteraction(delegate: self))
        collectionView.addInteraction(UIDropInteraction(delegate: self))
    }

    // MARK: - UICollectionView Delegate / Data Source methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return everitems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = everitems[indexPath.row]
        
        switch item {
        case .text(let content):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCollectionViewCell", for: indexPath) as! TextCollectionViewCell
            cell.configureWithText(content)
            cell.layer.cornerRadius = 8.0
            cell.layer.masksToBounds = true
            return cell
        case .image(let content):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
            cell.layer.cornerRadius = 8.0
            cell.layer.masksToBounds = true
            cell.configureWithImage(content)
            return cell
        }
    }
    
    // MARK: - Cell size methods
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func calculateCellWidth(_ size: CGSize? = nil) {
        let frameWidth = size?.width ?? self.view.frame.width
        let columns = round(frameWidth / 200.0)
        let width = (frameWidth - (CGFloat(columns + 1.0) * kEverationSpan)) / CGFloat(columns) - 1
        let height = width * kEverationAspectRatio
        self.cellSize = CGSize(width: width, height: height)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        calculateCellWidth(size)
        self.collectionView.reloadData()
    }
    
    // MARK: - Dragging interactions
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let point = session.location(in: interaction.view!)
        
        if let indexPath = collectionView.indexPathForItem(at: point) {
            // store our origin index path
            originIndexPath = indexPath
            
            let item = everitems[indexPath.row]
            let itemProvider: NSItemProvider
            switch item {
            case .image(let content):
                itemProvider = NSItemProvider(object: content)
            case .text(let content):
                itemProvider = NSItemProvider(object: content as NSString)
            }
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = indexPath
            return [dragItem]
        } else {
            originIndexPath = nil
            return []
        }
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        if let indexPath = item.localObject as? IndexPath {
            return UITargetedDragPreview(view: collectionView.cellForItem(at: indexPath)!)
        } else { return nil }
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, willAnimateLiftWith animator: UIDragAnimating, session: UIDragSession) {
        animator.addCompletion { position in // during dragging, show semi-transparent image of cell being dragged.
            if position == .end {
                self.setAlpha(0.5, forCellAtItems: session.items)
            }
        }
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, item: UIDragItem, willAnimateCancelWith animator: UIDragAnimating) {
        animator.addAnimations { // cancel animation should get original cell image back to alpha = 1
            self.setAlpha(1.0, forCellAtItems: [item])
        }
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, willEndWith operation: UIDropOperation) {
        if operation == .copy { // items being copied from another app. Set dragged items alpha to 1.
            setAlpha(1.0, forCellAtItems: session.items)
        }
    }

    // MARK: - Paste interactions
    
    override func paste(itemProviders: [NSItemProvider]) {
        for itemProvider in itemProviders { loadContent(itemProvider) }
    }
    
    @IBAction func performPaste(_ sender: Any) {
        for itemProvider in UIPasteboard.general.itemProviders { loadContent(itemProvider) }
    }
    
    // MARK: - Drop interactions
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self) || session.canLoadObjects(ofClass: NSString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let operation: UIDropOperation
        if session.localDragSession == nil { // drag from an external app initializing. Copy.
            operation = .copy
        } else { // local drag from our own app (collection view). Just move.
            operation = .move
        }
        // upate indexpath if needed.
        let hitPoint = session.location(in: interaction.view!)
        destinationIndexPath = collectionView.indexPathForItem(at: hitPoint) ?? nil

        return UIDropProposal(operation: operation)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        // calculate destination index path
        let hitPoint = session.location(in: interaction.view!)
        destinationIndexPath = collectionView.indexPathForItem(at: hitPoint) ?? nil

        for dragItem in session.items {
            // TODO: change this
            loadContent(dragItem.itemProvider)
        }
    }

    
    // MARK: - Utility functions
    
    func loadContent(_ itemProvider: NSItemProvider) {
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if error != nil { print("Error loading image. \(error!.localizedDescription)"); return }
                DispatchQueue.main.async {
                    // add item
                    let image = object as! UIImage
                    let newEveritem = EverItem.image(content: image)
                    self.addNewItem(newEveritem)
                    // clear paths
                    self.clearPaths()
                }
            }
        } else if itemProvider.canLoadObject(ofClass: NSString.self) {
            itemProvider.loadObject(ofClass: NSString.self) { object, error in
                if error != nil { print("Error loading text. \(error!.localizedDescription)"); return }
                DispatchQueue.main.async {
                    // add item
                    let text = object as! NSString
                    let newEveritem = EverItem.text(content: text as String)
                    self.addNewItem(newEveritem)
                }
            }
        }
    }
    
    func addNewItem(_ item: EverItem) {
        collectionView.performBatchUpdates({
            // update data
            if let originRow = originIndexPath?.row { everitems.remove(at: originRow) }
            if let destinationRow = destinationIndexPath?.row { everitems.insert(item, at: destinationRow) }
            else { everitems.append(item) }

            // remove origin cell (if any)
            if originIndexPath != nil { collectionView.deleteItems(at: [originIndexPath!]) }
            // add cell at destination (if any) or at the end (otherwise)
            var destinationIndexPaths: [IndexPath]
            if destinationIndexPath != nil { destinationIndexPaths = [destinationIndexPath!] }
            else { destinationIndexPaths = [IndexPath(item: self.everitems.count - 1, section: 0)] }
            collectionView.insertItems(at: destinationIndexPaths)

        }) { (success) in
            // fallback to reload data if an error happened
            if !success { self.collectionView.reloadData() }
        }
        // clear paths
        self.clearPaths()
    }
    
    func setAlpha(_ alpha: CGFloat, forCellAtItems items: [UIDragItem]) {
        for item in items {
            if let indexPath = item.localObject as? IndexPath {
                if let cell = collectionView.cellForItem(at: indexPath) { cell.alpha = alpha }
            }
        }
    }
    
    func clearPaths() {
        originIndexPath = nil
        destinationIndexPath = nil
    }
}

