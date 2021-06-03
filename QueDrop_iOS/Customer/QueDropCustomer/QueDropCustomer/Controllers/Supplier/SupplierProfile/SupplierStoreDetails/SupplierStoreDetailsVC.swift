//
//  SupplierStoreDetailsVC.swift
//  QueDrop
//
//  Created by C100-105 on 11/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class SupplierStoreDetailsVC: SupplierBaseViewController {
    
    @IBOutlet weak var constraintsSaveHeight: NSLayoutConstraint!
    @IBOutlet weak var viewSaveBtnContainer: UIView!
    @IBOutlet weak var viewNav: GradientView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblNavTitle: UILabel!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    
    enum Enum_StoreDetails: Int {
        case StoreLogo = 0
        case Images
        case InputDetails
        case TimingHeader
        case Timings
    }
    
    var datePickerVC: SupplierOfferDateTimeSelectionVC?
    var storeObj = Struct_StoreDetails()
    var isEditStore = false
    var arrServiceCategory = [ServiceCategories]()
    var txtArr = ["Store Address"]
    var tableViewAlert: TableViewAlert?
    var imagePickerFor = -1
    var isAddStore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isAddStore {
            isEditStore = true
            lblNavTitle.text = "Create Store"
        } else {
            lblNavTitle.text = isEditStore ? "Edit Store details" : "Store details"
        }
        getServiceCategory()
        setupUI()
        bindDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isAddStore && !isEditStore {
            bindDetails()
        }
        
    }
    
    func bindDetails() {
        storeObj = Struct_StoreDetails()
        
        if isAddStore {
            var arrSchedule = [Schedule]()
            
            let arrWeekDay = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
            for strWeekDay in arrWeekDay {
                let obj = Schedule()
                obj.scheduleId = 0
                obj.weekday = strWeekDay
                obj.openingTime = "00:00:00"
                obj.closingTime = "23:59:59"
                obj.isClosed = 0
                arrSchedule.append(obj)
            }
            
            storeObj.schedule = arrSchedule
            tableView.reloadData()
            return
        }
        guard let store = storeDetailsObj else {
            tableView.reloadData()
            return
        }
        
        var urls: [String] = []
        if let sliderImages = store.sliderImages, sliderImages.count > 0 {
            for slider in sliderImages {
                let url = URL_STORE_SLIDER_IMAGES + slider.sliderImage.asString()
                urls.append(url)
            }
        }
        
        storeObj.imagesUrls = urls
        storeObj.name = store.storeName.asString()
        storeObj.address = store.storeAddress.asString()
        
        storeObj.loc_lat = store.latitude.asString()
        storeObj.loc_long = store.longitude.asString()
        
        storeObj.serviceCategoryId = store.serviceCategoryId.asInt()
        storeObj.serviceCategory = store.serviceCategoryName.asString()
        
        if let logo = store.storeLogo {
            storeObj.logo = URL_STORE_LOGO_IMAGES + logo
        }
        
        if let schedule = store.schedule {
            storeObj.schedule = schedule
        }
        
        tableView.reloadData()
    }
    
    func setupUI() {
        var btnTitle = "Save"
        var attrTitle = NSMutableAttributedString(string: btnTitle)
        attrTitle.setColorTo(text: btnTitle, withColor: .white)
        attrTitle.bold(btnTitle, 19)
        
        btnSave.setTitle(nil, for: .normal)
        btnSave.setAttributedTitle(attrTitle, for: .normal)
        
        btnSave.backgroundColor = .appColor
        btnSave.showBorder(.clear, 10)
        
        btnTitle = "Edit"
        attrTitle = NSMutableAttributedString(string: btnTitle)
        attrTitle.setColorTo(text: btnTitle, withColor: .white/*.appColor*/)
        attrTitle.bold(btnTitle, 19)
        
        btnEdit.setTitle(nil, for: .normal)
        btnEdit.setAttributedTitle(attrTitle, for: .normal)
        
     //   btnEdit.backgroundColor = .white
        
        view.backgroundColor = VIEW_BG_COLOR //.white
        setupTableView(tableView: tableView)
        
        if isEditStore {
            startUpdatingCurrentLocation(delegate: self)
        }
        
        btnEdit.isHidden = isEditStore
        btnSave.isHidden = !isEditStore
        viewSaveBtnContainer.isHidden = !isEditStore
        constraintsSaveHeight.constant = isEditStore ? 65 : 0
        
        
    }
    
    func getServiceCategory() {
        API_SupplierProfile.shared.getServiceCategories(responseData: { (arrCat, isLoadMore) in
            self.arrServiceCategory = arrCat
        }) { (isDone, message) in
            
        }
        
    }
    
    func openServiceCategoryAlert() {
        var arr: [String] = []
        var selectedIndex = -1
        for index in 0..<arrServiceCategory.count {
            let cat = arrServiceCategory[index]
            arr.append(cat.serviceCategoryName.asString())
            
            if cat.serviceCategoryId == storeObj.serviceCategoryId {
                selectedIndex = index
            }
        }
        
        openSelectionAlert(
            index: 0,
            arr: arr,
            selectedIndex: selectedIndex,
            response: { value, index in
                self.storeObj.serviceCategory = self.arrServiceCategory[index].serviceCategoryName ?? ""
                self.storeObj.serviceCategoryId = self.arrServiceCategory[index].serviceCategoryId ?? 0
                self.tableView.reloadData()
        })
    }
    
    func openSelectionAlert(
        index: Int,
        arr: [String],
        selectedIndex: Int,
        response: @escaping(_ value: String, _ index: Int) -> Void) {
        
        if self.tableViewAlert != nil {
            self.tableViewAlert?.view.removeFromSuperview()
            self.tableViewAlert = nil
        }
        
        let cellSize: CGFloat = 50
        
        let indexPath = IndexPath(row: index, section: Enum_StoreDetails.StoreLogo.rawValue)
        let cell = tableView.cellForRow(at: indexPath) as! SupplierStoreLogoCell
        
        let rows = CGFloat(arr.count)
        var tblHeight = CGFloat(rows * cellSize)
        if rows > 5 {
            tblHeight = CGFloat(4 * cellSize)
        }
        let tblSize = CGSize(width: cell.viewTextBox2.frame.width, height: tblHeight)
        
        
        var frame = tableView.getFrame(ofIndexPath: indexPath)
        var point = CGPoint.zero
        point = view.convert(frame.origin, to: view)
        point.y += cell.viewTextBox2.frame.height + viewNav.frame.height + 30
        
        point.x = cell.viewTextBox2.frame.minX + 138
        frame = CGRect(origin: point, size: tblSize)
        
        tableViewAlert = TableViewAlert()
        tableViewAlert?.cellSize = cellSize
        tableViewAlert?.showView(viewDisplay: view, frame: frame, data: arr, selectedIndex: selectedIndex)
        
        tableViewAlert?.callback = response
        
        tableViewAlert?.dismissCallback = {
            self.tableViewAlert = nil
        }
    }
    func setupTableView(tableView: UITableView) {
        
        let cellIdentifiers = [
            "SupplierStoreLogoCell",
            "SupplierStoreSliderImageTVC",
            "SupplierTextFieldCell",
            "SupplierStoreTimingHeaderCell",
            "SupplierStoreTimingTVC",
            "SupplierStoreUploadImagesCell"
        ]
        
        for ids in cellIdentifiers {
            tableView.register(ids)
        }
        
        //setupPullRefresh(tblView: tableView, delegate: self)
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        
        //tableView.contentInsetAdjustmentBehavior = .never
        tableView.setHeaderFootertView(headHeight: 15, footHeight: 15)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear //.tableViewBg
    }
    
    @IBAction func btnBackClick(_ sender: Any) {
        if isAddStore {
            let alert = UIAlertController(title: "QUEDROP", message: "Your current session will be expired, Are you sure you want to go back?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                if UserType == .Supplier {
                    UserDefaults.standard.removeCustomObject(forKey: kUserDetailsUdf)
                    self.navigateToHome()
                }
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            popVC()
        }
        
    }
    
    @IBAction func btnEditClick(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierStoreDetailsVC") as! SupplierStoreDetailsVC
        vc.isEditStore = true
        pushVC(vc)
    }
    
    @IBAction func btnSaveClick(_ sender: Any) {
        if isAddStore {
            API_SupplierProfile.shared.callCreateStoreDetailsApi(storeDetails: storeObj, responseData: { (store) in
                
            }, errorData: { (isDone, message) in
                if isDone {
                    let navVc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierTabBarNavigation") as! UINavigationController
                    navVc.navigationBar.isHidden = true
                    APP_DELEGATE.window?.rootViewController = navVc
                } else {
                    self.showDismissAlert(title: "", message: message)
                }
            })
        } else {
            API_SupplierProfile.shared.callEditStoreDetailsApi(
                storeDetails: storeObj,
                responseData: { store in
                    self.tableView.reloadData()
            },
                errorData: { isDone, message in
                    if isDone {
                        self.popVC()
                    } else {
                        self.showDismissAlert(title: "", message: message)
                    }
            })
        }
        
    }
    
    override func didFinishPickingMedia(selectedImage image: UIImage?) {
        if let image = image {
            if imagePickerFor == 1 {
                storeObj.logoImage = image
            } else {
                storeObj.images.append(image)
            }
            tableView.reloadData()
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SupplierStoreDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            guard let type = Enum_StoreDetails(rawValue: indexPath.section) else {
                return 0
            }
            switch type {
            case .Images:
                var count = storeObj.images.count + storeObj.imagesUrls.count
                if isEditStore {
                    count += 1
                    let itemInRow: CGFloat = 3
                    let lineSpacing: CGFloat = 10
                    
                    let singleCell = tableView.frame.width / itemInRow
                    let leftRightSpacing = singleCell - (singleCell / 1.3)
                    let width = CGFloat(Int(singleCell - leftRightSpacing)) + lineSpacing
                    let rows = (CGFloat(count) / itemInRow) + CGFloat(count % Int(itemInRow) > 0 ? 1 : 0)
                    return (width * CGFloat(Int(rows))) + lineSpacing + 33
                } else {
                    return tableView.frame.width / 1.5
                }
                
            default:
                return UITableView.automaticDimension
            }
        }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let type = Enum_StoreDetails(rawValue: section) else {
            return 0
        }
        switch type {
        case .Timings:
            return storeObj.schedule.count
            
        case .InputDetails:
            return txtArr.count
            
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = Enum_StoreDetails(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        let index = indexPath.row
        
        switch type {
        case .StoreLogo :
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierStoreLogoCell", for: indexPath) as! SupplierStoreLogoCell
            
            cell.txtValueName.isEnabled = isEditStore
            cell.txtValueCategory.isEnabled = isEditStore
            cell.btnPickStoreLogo.isHidden = !isEditStore
            cell.imgDownArrow.isHidden = !isEditStore
            cell.txtValueName.tag = 11
            cell.txtValueCategory.tag = 21
            cell.txtValueCategory.delegate = self
            cell.txtValueName.delegate = self
            cell.bindDetails(objStore: storeObj)
            cell.btnPickStoreLogo.addTarget(self, action: #selector(btnStoreLogoPicker(btn:)), for: .touchUpInside)
            if isEditStore {
                cell.txtValueName.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
                
            } else {
                
            }
        
            return cell
        case .Images:
            if !isEditStore {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierStoreSliderImageTVC", for: indexPath) as! SupplierStoreSliderImageTVC
                cell.bindDetails(ofURLs: storeObj.imagesUrls)
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierStoreUploadImagesCell") as! SupplierStoreUploadImagesCell
                
                cell.setImagesToCollection(images: storeObj.images, media: storeObj.imagesUrls)
                cell.collectionImages.reloadData()
                
                cell.callbackForAddImage = {
                    self.imagePickerFor = 2
                    self.openImagePickerClick()
                }
                
                cell.callbackForDeleteUIImage = { index in
                    self.storeObj.images.remove(at: index)
                    tableView.reloadData()
                }
                
                cell.callbackForDeleteSliderImage = { index in
                    self.storeObj.imagesUrls.remove(at: index)
                    let id = storeDetailsObj?.sliderImages?[index].sliderImageId
                    self.storeObj.removeImageIds.append(id.asInt())
                    tableView.reloadData()
                }
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.openImagePickerClick))
                cell.viewAddPhoto.addGestureRecognizer(tap)
                
                return cell
            }
            
        case .InputDetails:
            let title = txtArr[index]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierTextFieldCell", for: indexPath) as! SupplierTextFieldCell
            cell.txtValue.isEnabled = isEditStore
            cell.txtValue.tag = index
            cell.txtValue.delegate = self
            cell.txtValue.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
            
            cell.bindDetails(title: title)
            
            /*if index == 0 {
                cell.txtValue.text = storeObj.name
            } else if index == 1 {*/
                cell.txtValue.text = storeObj.address
                cell.setImage(image: #imageLiteral(resourceName: "pin_icon"))
            //}
            
            return cell
            
        case .TimingHeader:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierStoreTimingHeaderCell", for: indexPath) as! SupplierStoreTimingHeaderCell
            cell.setupUI()
            return cell
            
        case .Timings:
            let schedule = storeObj.schedule[index]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierStoreTimingTVC", for: indexPath) as! SupplierStoreTimingTVC
            cell.bindDetails(ofSchedule: schedule, isEdit: isEditStore)
            
            cell.txtCloseTime.tag = index + 200
            cell.txtStartTime.tag = index + 100
            
            cell.txtCloseTime.delegate = self
            cell.txtStartTime.delegate = self
            
            cell.txtCloseTime.isEnabled = isEditStore
            cell.txtStartTime.isEnabled = isEditStore
            
            cell.callbackForOnOffChange = {
                schedule.isClosed = schedule.isClosed.asInt() == 1 ? 0 : 1
                self.storeObj.schedule[index] = schedule
                tableView.reloadData()
            }
            return cell
            
        }
    }
    
    @objc func btnStoreLogoPicker(btn : UIButton) {
        imagePickerFor = 1
        self.openImagePickerClick()
    }
}

extension SupplierStoreDetailsVC: UITextFieldDelegate {
    
    @objc func textFieldValueChange(_ txt: UITextField) {
        let txtValue = txt.text.asString()
        storeObj.name = txtValue
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        /*let tag = textField.tag
        if tag == 1 {
            openLocationPicker()
        } else if tag >= 100 {
            openDateTimeSelectionAlert(index: tag)
        }
        return tag == 0*/
        textField.resignFirstResponder()
        let tag = textField.tag
        if tag == 0 {
            openLocationPicker()
        } else if tag == 21 {
            openServiceCategoryAlert()
        } else if tag >= 100 {
            openDateTimeSelectionAlert(index: tag)
        }
        return tag == 11
    }
    
    func openDateTimeSelectionAlert(index: Int) {
        view.endEditing(true)
        
        var title = ""
        let minDate: Date? = nil
        var selectedDate: Date? = nil
        let maxDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        
        let isOpeningTime = index < 200
        let scheduleIndex = index % 100
        let schedule = storeObj.schedule[scheduleIndex]
        var dbTime = ""
        
        if isOpeningTime {
            title = " Opening Time"
            dbTime = schedule.openingTime.asString()
            
        } else {
            title = " Closing Time"
            
            dbTime = schedule.closingTime.asString()
            
        }
        title = schedule.weekday.asString() + title
        
        dbTime = Date().toString(format: "yyyy-MM-dd") + " " + dbTime
        selectedDate = dbTime.toDate()
        
        datePickerVC = SupplierOfferDateTimeSelectionVC(nibName: "SupplierOfferDateTimeSelectionVC", bundle: nil)
        
        datePickerVC?.strTitle = title
        datePickerVC?.selectedDate = selectedDate
        datePickerVC?.minDate = minDate
        datePickerVC?.maxDate = maxDate
        
        datePickerVC?.showView(viewDisplay: view, inFrom: .BOTTOM, isAnimate: true)
        
        datePickerVC?.dtPicker.datePickerMode = .time
        
        datePickerVC?.callbackForSelectedDate = { datetime in
            
            let selectedTime = datetime.toString(format: Schedule.TimeFormatDb)
            print(selectedTime)

            if isOpeningTime {

                self.storeObj.schedule[scheduleIndex].openingTime = selectedTime

            } else {

                self.storeObj.schedule[scheduleIndex].closingTime = selectedTime
            }
            self.tableView.reloadData()
        }
        
        datePickerVC?.callbackForCancel = {
            self.datePickerVC = nil
        }
        
        datePickerVC?.dismissCallback = {
            self.datePickerVC = nil
        }
    }
    
}
//MARK:- Google Places
extension SupplierStoreDetailsVC: GMSAutocompleteViewControllerDelegate, CurrentLocationDelegate {
    
    func updatedCurrentLocation(location: CLLocation) {
        lastLocation = location
    }
    
    func openLocationPicker() {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        
        let fields = GMSPlaceField(
            rawValue: UInt(GMSPlaceField.name.rawValue) |
                UInt(GMSPlaceField.placeID.rawValue) |
                UInt(GMSPlaceField.coordinate.rawValue) |
                UInt(GMSPlaceField.formattedAddress.rawValue) )!
        acController.placeFields = fields
        
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        //filter.country = NSLocale.current.regionCode
        filter.origin = lastLocation
        
        acController.autocompleteFilter = filter
        present(acController, animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //let name = place.name.asString()
        let address = place.formattedAddress.asString()
        
        storeObj.address = address
        storeObj.loc_lat = place.coordinate.latitude.description
        storeObj.loc_long = place.coordinate.longitude.description
        tableView.reloadData()
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
