//
//  ViewController.swift
//  planner
//
//  Created by Taehoon Kim on 2021/08/27.
//

import UIKit
import Charts
import RealmSwift

class CustomAnalysisViewController: BaseViewController {
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var radioSectionView: UIView!
    // radius 필요없는데
    
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var infoSectionView: UIView!
    @IBOutlet weak var monthAnalysisView: UIView!
    @IBOutlet weak var monthBarChartView: BarChartView!
    @IBOutlet weak var dayAnalysisView: UIView!
    @IBOutlet weak var dayBarChartView: BarChartView!
    //@IBOutlet weak var fromDateLabel: UILabel!
    
    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var fromDateView: UIView!
    @IBOutlet weak var endDateView: UIView!
    @IBOutlet var radioButtons: [UIButton]!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var monthTitleLabel: UILabel!
    @IBOutlet weak var monthDescriptionLabel: UILabel!
    @IBOutlet weak var dayTitleLabel: UILabel!
    @IBOutlet weak var dayDescriptionLabel: UILabel!
    
    let realm = try! Realm()
    var todoItems:Results<Todo>?
    var sectionItems:Results<SectionTodo>?
    let dateHelper = DateHelper()
    
    var touchCalendarName: String?
    //    @IBOutlet weak var radioTagButton: UIButton!
    //    @IBOutlet weak var radioTodoButton: UIButton!
    // month
    var months:[String] = []
    var monthsValue:[Double] = []
    
    //day
    var days:[String] = []
    var daysValue:[Double] = []
    
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoTotalTime: UILabel!
    @IBOutlet weak var infoStartDate: UILabel!
    @IBOutlet weak var infoEndDate: UILabel!
    
    override func viewDidLoad() {
        setupBannerViewToBottom()
        super.viewDidLoad()
        searchTextField.delegate = self
        searchTextField.returnKeyType = .done
        
        initStyle()
        fromDateTextField.isEnabled = false
        endDateTextField.isEnabled = false
        setPicker(pickerTextField: fromDateTextField)
        setPicker(pickerTextField: endDateTextField)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.didTapFromDate))
        fromDateView.addGestureRecognizer(gesture)
        
        let gesture2 = UITapGestureRecognizer(target: self, action:  #selector(self.didTapEndDate))
        endDateView.addGestureRecognizer(gesture2)
        setMonthBarChart(dataPoints: months, values: monthsValue)
        setDayBarChart(dataPoints: days, values: daysValue)
    }
    
    @IBAction func didTapSearchButton(_ sender: UIButton) {
        loadTodo()
        loadSection()
        for button in radioButtons {
            if button.isSelected {
                print(button.currentTitle!)
                let selectSearchOption = button.currentTitle!.filter({$0 != " "})
                if selectSearchOption == "Todo" {
                    setTodoDataForChart()
                }
                else if selectSearchOption == "Tag"
                {
                    setTagDataForChart()
                }
            }
        }
        setMonthBarChart(dataPoints: months, values: monthsValue)
        setDayBarChart(dataPoints: days, values: daysValue)
        searchTextField.resignFirstResponder()
    }
    
    @objc func didTapFromDate(sender : UITapGestureRecognizer) {
        // endDateTextField 클릭안되게
        endDateTextField.isEnabled = false
        // Do what you want
        touchCalendarName = "fromDateView"
        fromDateTextField.isEnabled = true
        fromDateTextField.becomeFirstResponder()
        
        //addDatePicker()
    }
    
    @objc func didTapEndDate(sender : UITapGestureRecognizer) {
        // fromDateTextField 클릭안되게
        fromDateTextField.isEnabled = false
        // Do what you want
        touchCalendarName = "endDateView"
        endDateTextField.isEnabled = true
        endDateTextField.becomeFirstResponder()
    }
    
    
    ///
    
    func setPicker(pickerTextField: UITextField) {
        let screenWidth = UIScreen.main.bounds.width
        let picker = UIDatePicker(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 200.0))
//        picker.preferredDatePickerStyle = .automatic
        picker.datePickerMode = .date
        
        picker.addTarget(self, action: #selector(updateDateField(sender:)), for: .valueChanged)
        
        //picker.minimumDate = getTwoWeekOldDateFormCurrentDate()
        picker.maximumDate = Date()
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKeyPath: "textColor")
        picker.preferredDatePickerStyle = .wheels
        if #available(iOS 13.4, *) {
           // picker.preferredDatePickerStyle = .compact

        } else {
            // Fallback on earlier versions
            picker.preferredDatePickerStyle = .wheels
          
        }
  
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 40.0))
        let cancel = UIBarButtonItem(title: "Done", style: .plain, target: pickerTextField, action: #selector(tapCancel))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
//            let done = UIBarButtonItem(title: "Done", style: .done, target: dateFilterTextField, action: #selector(tapCancel))
        //toolBar.setItems([cancel,flexibleSpace,done], animated: false)
        toolBar.setItems([flexibleSpace,cancel], animated: false)
        pickerTextField.inputAccessoryView = toolBar
        pickerTextField.inputView = picker
    }
    
    @objc func updateDateField(sender: UIDatePicker) {
        let dateLabel = formatDateForDisplay(date: sender.date)
        if touchCalendarName == "fromDateView" {
            fromDateTextField.text = dateLabel
        } else if touchCalendarName == "endDateView" {
            print("/>??????? \(dateLabel)")
            endDateTextField.text = dateLabel
        }
    }
    
    @objc func tapCancel() {
        fromDateTextField.isEnabled = false
        endDateTextField.isEnabled = false
        self.resignFirstResponder()
    }
    
//    private lazy var datePicker : UIDatePicker = {
//        let datePicker = UIDatePicker()
//
//        datePicker.datePickerMode = .date
//        datePicker.maximumDate = Date()
//        datePicker.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
//
//        datePicker.translatesAutoresizingMaskIntoConstraints = false
//        datePicker.autoresizingMask = .flexibleWidth
//        if #available(iOS 13, *) {
//            datePicker.backgroundColor = .label
//        } else {
//            datePicker.backgroundColor = .white
//        }
//        //datePicker.backgroundColor = UIColor.white
//        //datePicker.backgroundColor = UIColor.white
//        datePicker.setValue(UIColor.black, forKeyPath: "textColor")
//        datePicker.preferredDatePickerStyle = .wheels
//        return datePicker
//    }()
//
//    private lazy var toolBar : UIToolbar = {
//        let toolBar = UIToolbar()
//        toolBar.translatesAutoresizingMaskIntoConstraints = false
//        toolBar.barStyle = .default
//        toolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.onDoneClicked))]
//        toolBar.sizeToFit()
//        return toolBar
//    }()
//
//    @objc private func onDoneClicked(picker : UIDatePicker) {
//        self.datePicker.isHidden = true
//        self.toolBar.isHidden = true
//        //        /self.datePicker.heightAnchor.constraint(equalToConstant: 0).isActive = true
//        // print(picker.date)
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    @objc private func dateChanged(picker : UIDatePicker) {
//        print(picker.date)
//        let dateLabel = formatDateForDisplay(date: picker.date)
//        if touchCalendarName == "fromDateView" {
//            fromDateTextField.text = dateLabel
//        } else if touchCalendarName == "endDateView" {
//            print("/>??????? \(dateLabel)")
//            endDateLabel.text = dateLabel
//        }
//    }
//    private func addDatePicker() {
//        self.datePicker.isHidden = false
//        self.toolBar.isHidden = false
//        self.view.addSubview(self.datePicker)
//        self.view.addSubview(self.toolBar)
//
//        NSLayoutConstraint.activate([
//            self.datePicker.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//            self.datePicker.leftAnchor.constraint(equalTo: self.view.leftAnchor),
//            self.datePicker.rightAnchor.constraint(equalTo: self.view.rightAnchor),
//            self.datePicker.heightAnchor.constraint(equalToConstant: 200)
//        ])
//
//        NSLayoutConstraint.activate([
//            self.toolBar.bottomAnchor.constraint(equalTo: self.datePicker.topAnchor),
//            self.toolBar.leftAnchor.constraint(equalTo: self.view.leftAnchor),
//            self.toolBar.rightAnchor.constraint(equalTo: self.view.rightAnchor),
//            self.toolBar.heightAnchor.constraint(equalToConstant: 40)
//        ])
//    }
    
    // Formats the date chosen with the date picker.
    fileprivate func formatDateForDisplay(date: Date) -> String {
        let formatter = DateFormatter()
        // locale 설정마다 다름 https://stackoverflow.com/questions/13952063/how-to-change-the-format-of-date-in-date-picker/13952239#13952239
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    

    
    func initStyle() {
        monthTitleLabel.text = S.customStaticMonth
        monthDescriptionLabel.isHidden = true
        
        dayTitleLabel.text = S.customStaicMonthDetail
        dayDescriptionLabel.isHidden = true
        
        filterView.layer.cornerRadius = 15
        radioSectionView.layer.cornerRadius = 15
        //        radioTagButton.layer.cornerRadius = 15
        //        radioTodoButton.layer.cornerRadius = 15
        //        radioTagButton.layer.borderWidth = 0.5
        //        radioTodoButton.layer.borderColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1).cgColor
        showButton.layer.cornerRadius = 15
        infoSectionView.layer.cornerRadius = 15
        monthAnalysisView.layer.cornerRadius = 15
        dayAnalysisView.layer.cornerRadius = 15
        
        fromDateTextField.text = formatDateForDisplay(date: Date())
        endDateTextField.text = formatDateForDisplay(date: Date())
        
        radioButtons[0].isSelected = true
        updateRadioButton()
    }
    @IBAction func didTapRadioButton(_ sender: UIButton) {
        if !sender.isSelected {
            for index in radioButtons.indices {
                radioButtons[index].isSelected = false
            }
            sender.isSelected = true
            updateRadioButton()
        }
    }
    
    func updateRadioButton() {
        for button in radioButtons {
            button.layer.cornerRadius = 15
            if button.isSelected {
                button.backgroundColor = .systemBlue
                button.layer.borderWidth = 0
                button.setTitleColor(.white, for: .normal)
                button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                button.tintColor = .white
            } else {
                button.backgroundColor = .white
                button.layer.borderWidth = 0.5
                button.layer.borderColor = UIColor.systemGray.cgColor
                
                button.setTitleColor(.systemGray, for: .normal)
                button.setImage(UIImage(systemName: "circle"), for: .normal)
                button.tintColor = .systemGray
            }
        }
    }
    
    func setTagDataForChart() {
        months = []
        monthsValue = []
        
        days = []
        daysValue = []
        var infoDate = Set<Date>()
        var monthDic:[String : Int] = [:]
        var monthXvalue = Set<String>()
        
        var dayDic:[String : Int] = [:]
        var dayXvalue = Set<String>()
        
        sectionItems?.forEach({ (section) in
            section.todos.forEach { (item) in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM"
                let date = formatter.string(from: item.date)
                monthXvalue.insert(date)
                
                formatter.dateFormat = "MM-dd"
                let dayDate = formatter.string(from: item.date)
                dayXvalue.insert(dayDate)
                
                infoDate.insert(item.date)
            }
        })
        
        // dictionary 초기화
        monthXvalue.forEach { (date) in
            monthDic[date] = 0
        }
        dayXvalue.forEach { (date) in
            dayDic[date] = 0
        }
        
        var total = 0
        
        // totalSecond 저장
        sectionItems?.forEach({ (section) in
            section.todos.forEach { (item) in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM"
                let date = formatter.string(from: item.date)
                
                if monthDic[date] != nil {
                    monthDic[date] = monthDic[date]! + item.totalSeconds
                }
                
                formatter.dateFormat = "MM-dd"
                let dayDate = formatter.string(from: item.date)
                
                if dayDic[dayDate] != nil {
                    dayDic[dayDate] = dayDic[dayDate]! + item.totalSeconds
                }
                total += item.totalSeconds
            }
        })
        
        // chart데이터 삽입
        let sortedMonthKeys = Array(monthDic.keys).sorted(by: <)
        let sortedDayKeys = Array(dayDic.keys).sorted(by: <)
        sortedMonthKeys.forEach { (key) in
            months.append(key)
            monthsValue.append(secondsToHoursMinute(seconds: monthDic[key] ?? 0))
        }
        sortedDayKeys.forEach { (key) in
            days.append(key)
            daysValue.append(secondsToHoursMinute(seconds: dayDic[key] ?? 0))
        }
        
        // info Label 설정
        let infoDateArray = Array(infoDate).sorted(by: <)
        if infoDateArray.count == 0 {
            infoTitle.text = S.noResult
            infoStartDate.text = fromDateTextField.text
            infoEndDate.text = endDateTextField.text
        } else {
            infoTitle.text = S.customStaticTagTitle(with: [searchTextField.text ?? "nil"])
            infoStartDate.text = dateHelper.dateToString(date: infoDateArray.first ?? Date())
            infoEndDate.text = dateHelper.dateToString(date: infoDateArray.last ?? Date())
        }
        infoTotalTime.text = makeTimeString(seconds: total)
        
       
    }
    
    func setTodoDataForChart() {
        months = []
        monthsValue = []
        
        days = []
        daysValue = []
        
        var dic:[String : Int] = [:]
        
        var monthXvalue = Set<String>()
        // month format
        todoItems?.forEach({ (item) in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            let date = formatter.string(from: item.date)
            monthXvalue.insert(date)
            
            formatter.dateFormat = "MM-dd"
            let dayDate = formatter.string(from: item.date)
            
            days.append(dayDate)
            daysValue.append(secondsToHoursMinute(seconds: item.totalSeconds))
        })
        
        // dictionary 초기화
        monthXvalue.forEach { (date) in
            dic[date] = 0
        }
        
        var total = 0
        
        // totalSecond 저장
        todoItems?.forEach({ (item) in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            let date = formatter.string(from: item.date)
            
            if dic[date] != nil {
                dic[date] = dic[date]! + item.totalSeconds
            }
            
            total += item.totalSeconds
        })
        
        // chart데이터 삽입
        let sortedKeys = Array(dic.keys).sorted(by: <)
        sortedKeys.forEach { (key) in
            months.append(key)
            monthsValue.append(secondsToHoursMinute(seconds: dic[key] ?? 0))
        }
        
        // info Label 설정
        
        infoTitle.text = S.customStaticTaskTitle(with: [searchTextField.text ?? "nil"])
        infoTotalTime.text = makeTimeString(seconds: total)
        infoStartDate.text = dateHelper.dateToString(date: todoItems?.first?.date ?? Date())
        infoEndDate.text = dateHelper.dateToString(date: todoItems?.last?.date ?? Date())
        
    }
    
    //MARK: - Second 출력 마스킹
    func makeTimeString(seconds:Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600 )/60
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += " hours "
        timeString += String(format: "%02d", minutes)
        timeString += " minutes "
        return timeString
    }
    // seconds 마스킹
    func secondsToHoursMinute(seconds:Int) -> (Double) {
        let hours = Double(seconds / 3600)
        let minutes = Double(((seconds % 3600 )/60))/60
        
        let result = String(format: "%.1f",  hours + minutes)
        return Double(result)!
    }
    
    
    func setMonthBarChart(dataPoints:[String], values:[Double]) {
        if dataPoints.count > 0 {
            // 데이터 생성
            var dataEntries: [BarChartDataEntry] = []
            for i in 0..<dataPoints.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
                dataEntries.append(dataEntry)
            }
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "월 시간")
            
            // 차트 컬러
            chartDataSet.colors = [.systemBlue]
            
            // 데이터 삽입
            let chartData = BarChartData(dataSet: chartDataSet)
            monthBarChartView.data = chartData
            // 선택 안되게
            chartDataSet.highlightEnabled = false
            // 줌 안되게
            monthBarChartView.doubleTapToZoomEnabled = false
            
            // X축 레이블 위치 조정
            monthBarChartView.xAxis.labelPosition = .bottom
            // X축 레이블 포맷 지정
            monthBarChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
            
            // Value 포맷지정
            monthBarChartView.data?.setValueFormatter(DefaultValueFormatter(decimals: 1))
            
            // 오른쪽 레이블 제거
            monthBarChartView.rightAxis.enabled = false
            monthBarChartView.legend.enabled = false
            
            //기본 애니메이션
            // barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
            //옵션 애니메이션
            //barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
            
            // 리미트라인
            //let ll = ChartLimitLine(limit: 10.0, label: "타겟")
            //barChartView.leftAxis.addLimitLine(ll)
            
            // 맥시멈
            // barChartView.leftAxis.axisMaximum = 24
            // 미니멈
            monthBarChartView.leftAxis.axisMinimum = 0
            
            
            monthBarChartView.backgroundColor = .white
            
            
            monthBarChartView.xAxis.drawGridLinesEnabled = false
            monthBarChartView.rightAxis.enabled = false
            
            
            monthBarChartView.leftAxis.axisLineColor = .gray
            monthBarChartView.leftAxis.gridColor = .gray
            monthBarChartView.leftAxis.zeroLineColor = .gray
            monthBarChartView.leftAxis.labelTextColor = .gray
            monthBarChartView.leftAxis.labelCount = 3
            monthBarChartView.xAxis.labelTextColor = .gray
            monthBarChartView.barData?.barWidth = 0.7
            monthBarChartView.xAxis.granularity = 1
            // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
            if months.count < 7 {
                monthBarChartView.xAxis.setLabelCount(months.count, force: false)
                monthBarChartView.setVisibleXRangeMaximum(Double(months.count))
            }
            else {
                monthBarChartView.xAxis.setLabelCount(7, force: false)
                monthBarChartView.setVisibleXRangeMaximum(7)
            }
            
            monthBarChartView.leftAxis.enabled = true
            
            monthBarChartView.drawBordersEnabled = false
            monthBarChartView.chartDescription?.enabled = true
            monthBarChartView.xAxis.drawLabelsEnabled = true
            monthBarChartView.xAxis.drawAxisLineEnabled = true
            
            
            monthBarChartView.layer.cornerRadius = 15
            
            // 테스트
            monthBarChartView.borderLineWidth = 15
            
            monthBarChartView.legend.form = .none
        }
    }
    
    func setDayBarChart(dataPoints:[String], values:[Double]) {
        // 데이터 생성
        if dataPoints.count > 0 {
            var dataEntries: [BarChartDataEntry] = []
            for i in 0..<dataPoints.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
                dataEntries.append(dataEntry)
            }
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "월 시간")
            
            // 차트 컬러
            chartDataSet.colors = [.systemBlue]
            
            // 데이터 삽입
            let chartData = BarChartData(dataSet: chartDataSet)
            dayBarChartView.data = chartData
            // 선택 안되게
            chartDataSet.highlightEnabled = false
            
            // 줌 안되게
            dayBarChartView.doubleTapToZoomEnabled = false
            
            // X축 레이블 위치 조정
            dayBarChartView.xAxis.labelPosition = .bottom
            // X축 레이블 포맷 지정
            dayBarChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
            // Value 포맷지정
            dayBarChartView.data?.setValueFormatter(DefaultValueFormatter(decimals: 1))
            
            // 오른쪽 레이블 제거
            dayBarChartView.rightAxis.enabled = false
            dayBarChartView.legend.enabled = false
            
            //기본 애니메이션
            // barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
            //옵션 애니메이션
            //barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
            
            // 리미트라인
            //let ll = ChartLimitLine(limit: 10.0, label: "타겟")
            //barChartView.leftAxis.addLimitLine(ll)
            
            // 맥시멈
            // barChartView.leftAxis.axisMaximum = 24
            // 미니멈
            dayBarChartView.leftAxis.axisMinimum = 0
            
            
            dayBarChartView.backgroundColor = .white
            
            
            dayBarChartView.xAxis.drawGridLinesEnabled = false
            dayBarChartView.rightAxis.enabled = false
            
            
            dayBarChartView.leftAxis.axisLineColor = .gray
            dayBarChartView.leftAxis.gridColor = .gray
            dayBarChartView.leftAxis.zeroLineColor = .gray
            dayBarChartView.leftAxis.labelTextColor = .gray
            dayBarChartView.leftAxis.labelCount = 3
            dayBarChartView.xAxis.labelTextColor = .gray
            
            
            dayBarChartView.barData?.barWidth = 0.7
            dayBarChartView.xAxis.granularity = 1
            // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
            if days.count < 7 {
                dayBarChartView.xAxis.setLabelCount(days.count, force: false)
                dayBarChartView.setVisibleXRangeMaximum(Double(days.count))
            }
            else {
                dayBarChartView.xAxis.setLabelCount(7, force: false)
                dayBarChartView.setVisibleXRangeMaximum(7)
            }
            
            dayBarChartView.leftAxis.enabled = true
            
            dayBarChartView.drawBordersEnabled = false
            dayBarChartView.chartDescription?.enabled = true
            dayBarChartView.xAxis.drawLabelsEnabled = true
            dayBarChartView.xAxis.drawAxisLineEnabled = true
            
            
            dayBarChartView.layer.cornerRadius = 15
            
            // 테스트
            dayBarChartView.borderLineWidth = 15
            
            dayBarChartView.legend.form = .none
           
        }
    }
    
}

//MARK: - TextField Delegate
extension CustomAnalysisViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            textField.becomeFirstResponder()
            textField.endEditing(true)
            return true
        }
        else {
            textField.endEditing(true)
            return false
        }
    }
}

//MARK: - Realm Data Manipulation Methods
extension CustomAnalysisViewController {
    
    // 년도의 합산.
    // 1. 기간내의 Todo 가져옴.
    // 2. year 기준으로 묶음
    // 3. 날짜 기준으로 묶음. 걍 전부 뿌림
    
    // 1. section일 경우 section안에 있는 모든 todo 데이터를 합산해야함.
    // 2. todo 일경우 todo에 포함된 모든 todo 데이터를 합산해야함.
    func loadTodo() {
        guard let startDate = fromDateTextField.text, let endDate = endDateTextField.text, let title = searchTextField.text else {
            return
        }
        print(startDate)
        print(endDate)
        let start = dateHelper.stringToDate(date: startDate)
        let end = dateHelper.stringToDate(date: endDate)
        todoItems = realm.objects(Todo.self).filter("date BETWEEN %@", [start, end]).filter("title CONTAINS[cd] %@", title)
    }
    
    func loadSection() {
        guard let startDate = fromDateTextField.text, let endDate = endDateTextField.text, let title = searchTextField.text else {
            return
        }
        let start = dateHelper.stringToDate(date: startDate)
        let end = dateHelper.stringToDate(date: endDate)
        
        sectionItems = realm.objects(SectionTodo.self).filter("createDate BETWEEN %@", [start, end]).filter("title CONTAINS[cd] %@", title)
    }
    
}
