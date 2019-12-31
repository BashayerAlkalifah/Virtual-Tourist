//
//  ShowPhotosViewController.swift
//  Virtual Tourist
//
//  Created by بشاير الخليفه on 12/04/1441 AH.
//  Copyright © 1441 -. All rights reserved.
//


import UIKit
import MapKit
import CoreData


private let reuseIdentifier = "imageCell"

class ShowPhotosViewController: UICollectionViewController{
    
    var pin: Pins!
    var insertIndexes = [IndexPath]()
    var deleteIndexes = [IndexPath]()
    var updateIndexes = [IndexPath]()
    var selectedPhotos = Set<PhotoData>()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var newCollection: UIButton!
    
    var fetchedResultsController: NSFetchedResultsController<PhotoData>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchResultsController()
        setupLayout()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLayout()
        if (fetchedResultsController.sections?[0].objects!.isEmpty)! {
            Api.requestPhotosUrl(lat: pin.latitude!, lon: pin.longitude!, completionHandler: urlsCompletionHandler(urls:error:))
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            let photo = fetchedResultsController.sections?[0].objects?[0] as! PhotoData
            let image = #imageLiteral(resourceName: "VirtualTourist_152")
            if image.jpegData(compressionQuality: 1) == photo.data {
                downloadImages()
            }
            try? context.save()
        }
    }
    
    @IBAction func newCollection(_ sender: Any) {
        if newCollection.currentTitle == "New Collection" {
            removePhotos()
            
        }else if newCollection.currentTitle == "Remove the selected photos" {
            for cell in collectionView.visibleCells {
                cell.contentView.backgroundColor = nil
            }
            deleteSelectedPhotos()
        }
        
    }
    fileprivate func deleteSelectedPhotos() {
        for photo in selectedPhotos  {
            context.delete(photo)
        }
        isSelected(selection: false)
        try? context.save()
        if fetchedResultsController.sections?[0].numberOfObjects == 0 {
            Api.requestPhotosUrl(lat: pin.latitude!, lon: pin.longitude!, completionHandler: urlsCompletionHandler(urls:error:))
        }
    }
    
    fileprivate func setupLayout() {
        let space: CGFloat = 1
        let width: CGFloat = (view.frame.size.width - (space * 2)) / 2
        let height: CGFloat = (view.frame.size.width - (space * 2)) / 2
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: width, height: height)

    }
    
    @objc func removePhotos() {
        activityIndicator.isHidden = false
        for object in fetchedResultsController.fetchedObjects! {
            context.delete(object)
        }
        try? context.save()
        Api.requestPhotosUrl(lat: pin.latitude!, lon: pin.longitude!, completionHandler: urlsCompletionHandler(urls:error:))
    }
    func isSelected(selection: Bool){
        if selection {
            newCollection.setTitle("Remove the selected photos", for: .normal)
            newCollection.setTitleColor(UIColor.red, for: UIControl.State.normal)

        } else {
            newCollection.setTitle("New Collection", for: .normal)
            newCollection.setTitleColor(UIColor.black, for: UIControl.State.normal)
        }
    }
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        if let data = photo.data {
            cell.imageView.image = UIImage(data: data)
            cell.imageView.widthAnchor.constraint(equalToConstant: (view.frame.size.width - 2 * 2) / 2).isActive = true
            cell.imageView.heightAnchor.constraint(equalToConstant: (view.frame.size.width - 2 * 2) / 2).isActive = true
            cell.imageView.contentMode = .scaleAspectFill
             cell.imageView.clipsToBounds = true
            cell.imageView.layer.cornerRadius = 50
        } else {
            let image = #imageLiteral(resourceName: "VirtualTourist_152")
            cell.imageView.image = image
            cell.imageView.widthAnchor.constraint(equalToConstant: (view.frame.size.width - 2 * 2) / 2).isActive = true
            cell.imageView.heightAnchor.constraint(equalToConstant: (view.frame.size.width - 2 * 2) / 2).isActive = true
            cell.imageView.contentMode = .scaleAspectFill
             cell.imageView.clipsToBounds = true
            cell.imageView.layer.cornerRadius = 50
            photo.data = cell.imageView.image?.jpegData(compressionQuality: 1)
            try? context.save()
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isSelected(selection: true)
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        let photo = fetchedResultsController!.object(at: indexPath)
        if selectedPhotos.contains(photo){
            repeat{isSelected(selection: true)} while(selectedPhotos.isEmpty)
            selectedPhotos.remove(photo)
            cell.contentView.backgroundColor = nil
            if(selectedPhotos.isEmpty){
                isSelected(selection: false)
            }
        } else {
            selectedPhotos.insert(photo)
            cell.contentView.backgroundColor =  #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            
        }
        if(selectedPhotos.isEmpty){
            isSelected(selection: false)
        }
    }
    
}

// MARK: FetchedResultControllerDelegate

extension ShowPhotosViewController: NSFetchedResultsControllerDelegate {
    fileprivate func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<PhotoData> = PhotoData.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptors]
        let predicate = NSPredicate(format: "pins == %@", pin)
        fetchRequest.predicate = predicate
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "pin: \(pin.latitude!)+\(pin.longitude!)")
        
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            debugPrint(error)
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        insertIndexes.removeAll()
        deleteIndexes.removeAll()
        updateIndexes.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            insertIndexes.append(newIndexPath!)
        case .delete:
            deleteIndexes.append(indexPath!)
        case .update:
            updateIndexes.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates( {
            self.collectionView.insertItems(at: insertIndexes)
            self.collectionView.deleteItems(at: deleteIndexes)
            self.collectionView.reloadItems(at: updateIndexes)
        }, completion: nil)
    }
}
extension ShowPhotosViewController {
    func urlsCompletionHandler(urls: [URL], error: Error?) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        if !urls.isEmpty {
            var index = 0
            var photos: [PhotoData] = []
            while index < urls.count {
                photos.append(PhotoData(context: context))
                photos[index].createdAt = Date()
                photos[index].url = urls[index]
                photos[index].pins = pin
                index = index + 1
                try? context.save()
            }
            downloadImages()
            
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            if error == nil {
                alert(title: "Failed", message: "There is No Images in This Location")
            } else {
                alert(title: "Failed", message: "You are not connected to the internet, Try Again")
            }
            
            
        }
    }
    
    
    func downloadImages() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        let length = fetchedResultsController.sections?[0].objects?.count
        var index = 0
        while index < length!{
            let photo = fetchedResultsController.object(at: IndexPath.init(item: index, section: 0))
            index += 1
            _ = Api.downloadImage(imageURL: photo.url!, completionHandler: { (imageData, error) in
                
                if (error == nil) {
                    photo.data = imageData as Data?
                }
                
            })}
        try? context.save()
        
        
    }
}




