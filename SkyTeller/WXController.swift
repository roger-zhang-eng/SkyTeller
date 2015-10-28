//
//  WXController.swift
//  SkyTeller
//
//  Created by Roger Zhang on 14/06/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

import UIKit

class WXController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, WXMangerAPIDelegate
{
    var backgroundImageView = UIImageView()
    var blurredImageView = UIImageView()
    var tableView = UITableView()
    var screenHeight: CGFloat?
    var temperatureLabel: UILabel?
    var hiloLabel: UILabel?
    var cityLabel: UILabel?
    var windSpeedLabel: UILabel?
    var conditionsLabel: UILabel?
    var sunriseLabel: UILabel?
    var sunsetLabel: UILabel?
    var iconView: UIImageView?
    var hourlyFormatter: NSDateFormatter?
    var dailyFormatter: NSDateFormatter?
    var windSpeedView: UIImageView?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.hourlyFormatter = NSDateFormatter()
        self.hourlyFormatter!.dateFormat = "h a"
        
        self.dailyFormatter = NSDateFormatter()
        self.dailyFormatter!.dateFormat = "EEEE"
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.redColor()
        
        self.screenHeight = UIScreen.mainScreen().bounds.height
        
        //set background image in the lowest view
        let background: UIImage = UIImage(named: "bg")!
        self.backgroundImageView.image = background
        self.backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.view.addSubview(self.backgroundImageView)
        
        //set blurring effect into the 2nd view layer
        self.blurredImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.blurredImageView.alpha = 0
        self.blurredImageView.setImageToBlur(background, blurRadius: 10, completionBlock: nil)
        self.view.addSubview(self.blurredImageView)
        
        //set tableview, and add it into the top view layer
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = UIColor(white: 1, alpha: 0.2)
        self.tableView.pagingEnabled = true
        self.view.addSubview(self.tableView)
        
        //Create header view for the tableView to display cell detailed information
        //1. the header of your table to be the same size of your screen
        let headerFrame = UIScreen.mainScreen().bounds
        let header = UIView(frame: headerFrame)
        header.backgroundColor = UIColor.clearColor()
        self.tableView.tableHeaderView = header;
        
        // 2 padding variable so that all your labels are evenly spaced and centered
        let inset:CGFloat = 20;
        // 3
        let temperatureHeight: CGFloat = 80;
        let hiloHeight: CGFloat = 40;
        let iconHeight: CGFloat = 40;
        let conditionWidth: CGFloat = 80
        let hiloWidth: CGFloat = 100
        let windspeedWidth: CGFloat = 80
        let sunriseTextWidth: CGFloat = 80
        
        // 4
        //hilow frame
        let hiloFrame = CGRectMake(inset,
            headerFrame.size.height - hiloHeight,
            //headerFrame.size.width - (2 * inset),
            hiloWidth,
            hiloHeight)

        //set sunrise and sunset icon frame
        let sunriseIconFrame = CGRectMake(inset,
            65,
            iconHeight,
            iconHeight);
        let sunriseTextFrame = CGRectMake(inset + hiloHeight + 10,
            65,
            sunriseTextWidth,
            hiloHeight);
        
        let sunsetTextFrame = CGRectMake(headerFrame.size.width - (sunriseTextWidth + 10),
            65,
            sunriseTextWidth,
            hiloHeight);
        let sunsetIconFrame = CGRectMake(headerFrame.size.width - (sunriseTextWidth + 10 + hiloHeight + 10),
            65,
            iconHeight,
            iconHeight);

        

        //temperature frame
        let temperatureWidth:CGFloat = 100
        
        let temperatureFrame = CGRectMake(inset,
        headerFrame.size.height - (temperatureHeight + hiloHeight - 10),
        temperatureWidth,
        temperatureHeight);
        
        //centidegree frame
        let centidegree_x: CGFloat = inset + temperatureWidth - 30
        let centidegree_y: CGFloat = headerFrame.size.height - (temperatureHeight + hiloHeight - 25)
        let centidegreeFrame = CGRectMake(centidegree_x,centidegree_y,
            35,
            30);
        
        //weather icon frame
        let iconFrame_x = self.view.bounds.size.width - conditionWidth - 10 - 10 - iconHeight;
        let iconFrame = CGRectMake(iconFrame_x, centidegree_y,
        iconHeight,
        iconHeight);
        
        //wind speed Icon frame is in the same level of hilo frame
        let windIconFrame = CGRectMake(self.view.bounds.size.width - (windspeedWidth + 10 + 30 + 15),
            headerFrame.size.height - hiloHeight + 5,
            30,
            30)
        //wind speed frame
        let windspeedFrame = CGRectMake(self.view.bounds.size.width - (windspeedWidth + 10),
            headerFrame.size.height - hiloHeight,
            windspeedWidth,
            hiloHeight)
        
        // 5 This conditionsFrame is in the same level of iconFrame, but has 10 padding as seperator
        var conditionsFrame = iconFrame;
        conditionsFrame.size.width = conditionWidth;
        conditionsFrame.origin.x = self.view.bounds.size.width - (conditionWidth + 10);
        
        // set temperature
        temperatureLabel = UILabel(frame: temperatureFrame)
        temperatureLabel!.backgroundColor = UIColor.clearColor()
        temperatureLabel!.textColor = UIColor.whiteColor()
        temperatureLabel!.text = "0"
        temperatureLabel!.font = UIFont(name: "HelveticaNeue-UltraLight", size: 60)
        header.addSubview(temperatureLabel!)
    
        
        // set hilo
        hiloLabel = UILabel(frame: hiloFrame)
        hiloLabel!.backgroundColor = UIColor.clearColor()
        hiloLabel!.textColor = UIColor.whiteColor()
        hiloLabel!.text = "0 / 0";
        hiloLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        header.addSubview(hiloLabel!)
        
        // top, the frame is set here
        cityLabel = UILabel(frame: CGRectMake(0, 20, self.view.bounds.size.width, 40))
        cityLabel!.backgroundColor = UIColor.clearColor()
        cityLabel!.textColor = UIColor.whiteColor()
        cityLabel!.text = "Locating...";
        cityLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 24)
        cityLabel!.textAlignment = NSTextAlignment.Center
        header.addSubview(cityLabel!)
        
        let sunriseIconView = UIImageView(frame: sunriseIconFrame)
        sunriseIconView.contentMode = UIViewContentMode.ScaleAspectFill
        sunriseIconView.backgroundColor = UIColor.clearColor()
        header.addSubview(sunriseIconView)
        sunriseIconView.image = UIImage(named: "weather-sunrise")
        
        let sunsetIconView = UIImageView(frame: sunsetIconFrame)
        sunsetIconView.contentMode = UIViewContentMode.ScaleAspectFill
        sunsetIconView.backgroundColor = UIColor.clearColor()
        header.addSubview(sunsetIconView)
        sunsetIconView.image = UIImage(named: "weather-sunset")
        
        sunriseLabel = UILabel(frame: sunriseTextFrame)
        sunriseLabel!.backgroundColor = UIColor.clearColor()
        sunriseLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        sunriseLabel!.textColor = UIColor.whiteColor()
        header.addSubview(sunriseLabel!)
        
        sunsetLabel = UILabel(frame: sunsetTextFrame)
        sunsetLabel!.backgroundColor = UIColor.clearColor()
        sunsetLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        sunsetLabel!.textColor = UIColor.whiteColor()
        header.addSubview(sunsetLabel!)
        
        conditionsLabel = UILabel(frame: conditionsFrame)
        conditionsLabel!.backgroundColor = UIColor.clearColor()
        conditionsLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        conditionsLabel!.textColor = UIColor.whiteColor()
        header.addSubview(conditionsLabel!)
        
        // bottom left
        iconView = UIImageView(frame: iconFrame)
        iconView!.contentMode = UIViewContentMode.ScaleAspectFill
        iconView!.backgroundColor = UIColor.clearColor()
        header.addSubview(iconView!)
        
        let centidegreeView = UIImageView(frame: centidegreeFrame)
        centidegreeView.contentMode = UIViewContentMode.ScaleAspectFill
        centidegreeView.backgroundColor = UIColor.clearColor()
        header.addSubview(centidegreeView)
        centidegreeView.image = UIImage(named: "centi_degree")
        
        windSpeedView = UIImageView(frame: windIconFrame)
        windSpeedView!.contentMode = UIViewContentMode.Center
        windSpeedView!.backgroundColor = UIColor.clearColor()
        header.addSubview(windSpeedView!)
        windSpeedView!.image = UIImage(named: "weather-wind_0")
        
        windSpeedLabel = UILabel(frame: windspeedFrame)
        windSpeedLabel!.backgroundColor = UIColor.clearColor()
        windSpeedLabel!.textColor = UIColor.whiteColor()
        windSpeedLabel!.text = "0 km/h";
        windSpeedLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        header.addSubview(windSpeedLabel!)
        
        WXManager.sharedManager().delegate = self
        WXManager.sharedManager().findCurrentLocation()
    }

    func conditionUpdate(temperText: String, conditionText: String, city: String, icon: String, hilowtemp:String, windspeed:String, windgrade:String, sunrisetime:String, sunsettime:String) {
        self.temperatureLabel!.text = temperText
        self.conditionsLabel!.text = conditionText
        self.cityLabel!.text = city
        self.iconView!.image = UIImage(named: icon)
        self.hiloLabel?.text = hilowtemp
        self.windSpeedLabel?.text = windspeed
        self.sunriseLabel?.text = sunrisetime
        self.sunsetLabel?.text = sunsettime
        
        let windimage:String = "weather-wind_\(windgrade)"
        windSpeedView!.image = UIImage(named: windimage)
    }
    
    func temperUpdate(text:String) {
        
    }
    
    func dailyUpdate() {
        self.tableView.reloadData()
    }
    
    func hourlyUpdate() {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //view controller calls this method in order to lay out its subviews
    override func viewWillLayoutSubviews() {
        let bounds = self.view.bounds
        
        //The below one sentence is wrong. the View's Bounds only means itself system.
        //self.backgroundImageView.bounds = bounds
        
        //the View's frame mean its size and position in its super view.
        self.backgroundImageView.frame = bounds
        self.blurredImageView.frame = bounds
        self.tableView.frame = bounds
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //#pragma mark - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //two sections, one for hourly forecasts and one for daily. You always return 2 for the number of table view sections
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "CellIdentifier"
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as? UITableViewCell
        
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: CellIdentifier)
        }
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        cell!.backgroundColor = UIColor(white: 0, alpha: 0.2)
        cell!.textLabel?.textColor = UIColor.whiteColor()
        cell!.detailTextLabel?.textColor = UIColor.whiteColor()
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                self.configureHeaderCell(cell!, title: "Hourly Forecast")
            }
            else {
                let weather = WXManager.sharedManager().hourlyForecast[indexPath.row - 1] as! WXCondition
                self.configureHourlyCell(cell!, weather: weather)
            }
        }
        else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                self.configureHeaderCell(cell!, title: "Daily Forecast")
            }
            else {
                let weather = WXManager.sharedManager().dailyForecast[indexPath.row - 1] as! WXCondition
                self.configureDailyCell(cell!, weather:weather)
            }
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            if(WXManager.sharedManager().hourlyForecast != nil) {
                return min(WXManager.sharedManager().hourlyForecast.count, 7) + 1
            }
        } else {
        
            if(WXManager.sharedManager().dailyForecast != nil) {
                return min(WXManager.sharedManager().dailyForecast.count, 7) + 1
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellCount = self.tableView(tableView, numberOfRowsInSection:indexPath.section)
        
        if(cellCount != 0) {
            return (self.screenHeight! / CGFloat(cellCount))
        } else {
            return 20
        }
    }
    
    func configureHeaderCell(cell:UITableViewCell, title:String) {
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = ""
        cell.imageView?.image = nil
    }
    
    func configureHourlyCell(cell:UITableViewCell,weather:WXCondition) {
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        cell.detailTextLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        cell.textLabel?.text = self.hourlyFormatter?.stringFromDate(weather.date)
        cell.detailTextLabel?.text = String(format: "%.0f°", weather.temperature.floatValue)
        
        //stringWithFormat:@"%.0f°",weather.temperature.floatValue];
        cell.imageView?.image = UIImage(named: weather.imageName())
        cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        //UIViewContentModeScaleAspectFit;
    }
    
    func configureDailyCell(cell:UITableViewCell,weather:WXCondition) {
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        cell.detailTextLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        cell.textLabel?.text = self.dailyFormatter?.stringFromDate(weather.date)
        cell.detailTextLabel?.text = String(format: "%.0f° / %.0f°",weather.tempHigh.floatValue,weather.tempLow.floatValue)
        cell.imageView?.image = UIImage(named: weather.imageName())
        cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
//pragma mark - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //println("scrollView DidScroll is triggered!")
        let height = scrollView.bounds.size.height
        let position = max(scrollView.contentOffset.y, 0.0)
        let percent = min(position/height, 1.0)
        self.blurredImageView.alpha = percent
    }

}
