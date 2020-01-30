//
//  ImageViewController.swift
//  PlayerView
//
//  Created by 杨志远 on 2020/1/8.
//  Copyright © 2020 BaQiWL. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let cellID = "ImageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let nib = UINib(nibName: cellID, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
        tableView.tableFooterView = UIView()
    }

}

extension ImageViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! ImageCell
        cell.urlString = dataSource[indexPath.row]
        return cell
    }
}



let dataSource = [
//    "http://lessimore.cn/images/658x529.gif",

//    "http://lessimore.cn/images/569x356.gif",
//    "http://lessimore.cn/images/560x291.gif",
//    "http://lessimore.cn/images/535x274.gif",
//    "http://lessimore.cn/images/512x288.gif",
    "http://lessimore.cn/tajikistan-4747639_1920.jpg",
//"http://lessimore.cn/tajikistan-4747639_1920.jpg",
//"http://lessimore.cn/tajikistan-4747639_1920.jpg",
//"http://lessimore.cn/tajikistan-4747639_1920.jpg",
//"http://lessimore.cn/tajikistan-4747639_1920.jpg",
//"http://lessimore.cn/tajikistan-4747639_1920.jpg",
//"http://lessimore.cn/tajikistan-4747639_1920.jpg",
//"http://lessimore.cn/tajikistan-4747639_1920.jpg",
    "http://lessimore.cn/business-792113_1920.jpg",
////    "https://srv4.imgonline.com.ua/result_img/imgonline-com-ua-compressed-eEWDfrmZoYeMRM5.jpg",
//    
//    "http://lessimore.cn/image_progressive3.jpg",
//    "http://lessimore.cn/image_progressive2.jpg",
//
//    "https://eoimages.gsfc.nasa.gov/images/imagerecords/78000/78314/VIIRS_3Feb2012_lrg.jpg",
    "https://cdn.pixabay.com/photo/2019/12/18/14/04/christmas-4704083_1280.jpg",
    "https://cdn.pixabay.com/photo/2020/01/01/18/31/coffee-4734151_1280.jpg",
    "https://cdn.pixabay.com/photo/2019/12/02/16/37/snow-4668099_1280.jpg",
    "https://cdn.pixabay.com/photo/2020/01/04/16/51/sunset-4741140__480.jpg",
//    "https://cdn.pixabay.com/photo/2019/12/08/01/08/winter-4680354__480.jpg",
//    "https://cdn.pixabay.com/photo/2019/12/29/15/45/paragliding-4727377__480.jpg",
//    "https://cdn.pixabay.com/photo/2020/01/05/14/02/fallow-deer-4743241__480.jpg",
//    "https://cdn.pixabay.com/photo/2019/11/25/17/05/new-years-eve-4652544__480.jpg",
//    "https://cdn.pixabay.com/photo/2019/12/05/16/54/blackbird-4675637__480.jpg",
//    "https://cdn.pixabay.com/photo/2020/01/04/20/08/helenium-waltraut-4741559__480.jpg",
//    "https://cdn.pixabay.com/photo/2019/12/10/10/53/architecture-4685608__480.jpg",
//    "https://cdn.pixabay.com/photo/2019/12/17/14/08/landscape-4701725__480.jpg",
//    "https://cdn.pixabay.com/photo/2020/01/04/12/16/cake-4740451__480.jpg",
//    "https://cdn.pixabay.com/photo/2020/01/02/21/59/away-4736917__480.jpg",
//    "https://cdn.pixabay.com/photo/2020/01/05/17/43/tacmahal-4743690__480.jpg",
//    "https://cdn.pixabay.com/photo/2019/12/20/23/07/landscape-4709500__480.jpg",
//    "https://cdn.pixabay.com/photo/2019/12/24/09/48/sunset-4716378__480.jpg",
//    "https://cdn.pixabay.com/photo/2020/01/03/15/46/sunset-4738453__480.jpg",
//    "https://pixabay.com/get/52e3d645425ab114b2d98075c32d337f1522dfe05459754e70287bd0/styggkarret-433688.jpg",
]
