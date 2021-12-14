//
//  ViewController.swift
//  planner
//
//  Created by Taehoon Kim on 2021/08/27.
//

import UIKit
import Charts
import RealmSwift

class AnalysisViewController: BaseViewController {
    @IBOutlet weak var dayChartViewWrapper: UIView!
    @IBOutlet weak var dayPieChartView: PieChartView!
    @IBOutlet weak var weekChartViewWrapper: UIView!
    @IBOutlet weak var weekBarChartView: BarChartView!
    
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var todayTitle: UILabel!
    @IBOutlet weak var todayGraphDescription: UILabel!
    @IBOutlet weak var weekGraphTitle: UILabel!
    @IBOutlet weak var weekGraphDescription: UILabel!
    @IBOutlet weak var monthGraphTitle: UILabel!
    @IBOutlet weak var monthGraphDescription: UILabel!
    
    
    @IBOutlet weak var dateFilterView: UIView!
    @IBOutlet weak var dateFilterTextField: UITextField!
    @IBOutlet weak var monthChartViewWrapper: UIView!
    @IBOutlet weak var monthBarChartView: BarChartView!
    
    @IBOutlet weak var todoAnalysisButton: UIButton!
    @IBOutlet weak var analysisDateButton: UIButton!
    
    let realm = try! Realm()
    var todoDayItems:Results<Todo>?
    var todoWeekItems:Results<Todo>?
    var todoMonthItems:Results<Todo>?
    var eventDayItems:Results<EventDay>?
    var todoSections:Results<SectionTodo>?
    var weekMemo:Results<WeekMemo>?
    let dateHelper = DateHelper()
    var selectedDate:Date?
    
    // Sample dayPie Data
    var dayPieData = ["ios공부", "운동", "주식강의", "알고리즘 코테 연습"]
    var dayPieHours = [2.2, 2.3, 2.5, 3.7]
    var dayPieCenterText = 0.0
    
    // Week Data
    var weeks = ["S","M","T","W","T","F","S"]
    var weeksValue = [2.2, 2.3, 2.5, 3.7, 3.4, 5.5, 2.1]
    var weekAvg = 0.0
    
    // month
    var months = ["8.2", "8.3", "8.4", "8.5", "8.6", "8.7", "8.8", "8.9", "8.10", "8.11", "8.12", "8.13","8.14", "8.15", "8.16", "8.17", "8.18", "8.19", "8.20", "8.21", "8.22", "8.28", "8.29", "8.30"]
    var monthsValue = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0,20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0,]
    var monthAvg = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBannerViewToBottom()
        selectedDate = dateHelper.dateInit()
        initStyle()
        setPicker()
        
        //loadData
        loadDayTodo()
        loadWeekTodo()
        loadMonthTodo()
        
        setDataForChart()
        
        // pie
        setDayPieChart(dataPoints: dayPieData, values: dayPieHours.map{ Double($0) })
        // weekBar
        setWeekBarChart(dataPoints: weeks, values: weeksValue)
        
        // monthBar
        setMonthBarChart(dataPoints: months, values: monthsValue)
        
        print(todoDayItems)
    }
    
    
    @IBAction func didTapSearchAnalysisButton(_ sender: UIButton) {
        //loadData
        loadDayTodo()
        loadWeekTodo()
        loadMonthTodo()
        
        setDataForChart()
        
        // pie
        setDayPieChart(dataPoints: dayPieData, values: dayPieHours.map{ Double($0) })
        // weekBar
        setWeekBarChart(dataPoints: weeks, values: weeksValue)

        // monthBar
        setMonthBarChart(dataPoints: months, values: monthsValue)
        
        dateFilterTextField.resignFirstResponder()
//        dayPieChartView.notifyDataSetChanged()
//        dayPieChartView.data?.notifyDataChanged()
//        weekBarChartView.notifyDataSetChanged()
//        weekBarChartView.data?.notifyDataChanged()
//        monthBarChartView.notifyDataSetChanged()
//        monthBarChartView.data?.notifyDataChanged()
//
//        dayPieChartView.setNeedsDisplay()
//        weekBarChartView.setNeedsDisplay()
//        monthBarChartView.setNeedsDisplay()
//
//        view.setNeedsDisplay()
    }
    @IBAction func didTapTodoAnalysisButton(_ sender: UIButton) {
        //goToCustomAnalysis
        self.performSegue(withIdentifier: "goToCustomAnalysis", sender: self)
    }
    
    func calculateWeekDay() -> [Date] {
        var calendar = Calendar.autoupdatingCurrent
        calendar.firstWeekday = 1 // Start on Monday (or 1 for Sunday)
        let standardDay = calendar.startOfDay(for: selectedDate!)
        var week = [Date]()
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: standardDay) {
            for i in 0...6 {
                if let day = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
                    week += [day]
                }
            }
        }
        return week
    }
    
    func caculateBetweendates(from fromDate: Date, to toDate: Date) -> [Date] {
       var dates: [Date] = []
       var date = fromDate
       
       while date <= toDate {
           dates.append(date)
           guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
           date = newDate
       }
       return dates
   }
    
    
    
    
    func setDataForChart() {
        dayPieData = []
        dayPieHours = []
        var hours = 0.0
        var dayPieTotal = 0.0
        todoDayItems?.forEach({ (item) in
            dayPieData.append(item.title)
            hours = secondsToHoursMinute(seconds: item.totalSeconds)
            dayPieTotal += hours
            dayPieHours.append(hours)
        })
        
        dayPieCenterText = dayPieTotal
  
        // Week Data
        let weekAllday = calculateWeekDay()
        weeks = []
        weeksValue = []
        
        // todoWeekItems
        var weekTotal = 0.0
        // Week 데이터 Formatt
        weekAllday.forEach { (date) in
            // x축 데이터
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            let formatDate = formatter.string(from: date)
            weeks.append(formatDate)
            
            // 하루 총 시간 계산하기
            let day = todoWeekItems?.filter("date == %@", date)
            var totalSeconds = 0
            day?.forEach { (item) in
                totalSeconds += item.totalSeconds
            }
            
            // y축 데이터
            hours = secondsToHoursMinute(seconds: totalSeconds)
            weekTotal += hours
            weeksValue.append(hours)
        }
       
        weekAvg = Double(String(format: "%.2f",  weekTotal / Double(weekAllday.count)))!
        weekGraphDescription.text = S.weekDescription(with: [weekAvg, weekTotal])
        // todoMonthItems
        // Week Data
        
        
        months = []
        monthsValue = []
        var monthTotal = 0.0
        
        // Week 날짜 얻기
        let start = Calendar.current.monthBoundary(for: selectedDate!)!.startOfMonth!
        let end = Calendar.current.monthBoundary(for: selectedDate!)!.endOfMonth!
        
        let monthAllday = caculateBetweendates(from: start, to: end)
       
        monthAllday.forEach { (date) in
            // x축 데이터
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            let formatDate = formatter.string(from: date)
            months.append(formatDate)
            
            // 하루 총 시간 계산하기
            let day = todoMonthItems?.filter("date == %@", date)
            var totalSeconds = 0
            day?.forEach { (item) in
                totalSeconds += item.totalSeconds
            }
            
            // y축 데이터
            hours = secondsToHoursMinute(seconds: totalSeconds)
            monthTotal += hours
            monthsValue.append(hours)
        }
        
        monthAvg = Double(String(format: "%.2f",  monthTotal / Double(monthAllday.count)))!
        monthGraphDescription.text = S.monthDescription(with: [monthAvg,monthTotal])
//        "이번달 평균 시간은 \(monthAvg)시간입니다.\n총 시간은 \(monthTotal)시간입니다."
        
    }
    
    // seconds 마스킹
    func secondsToHoursMinute(seconds:Int) -> (Double) {
        let hours = Double(seconds / 3600)
        let minutes = Double(((seconds % 3600 )/60))/60
        
        let result = String(format: "%.1f",  hours + minutes)
        return Double(result)!
    }
    
    func setPicker() {
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
        let cancel = UIBarButtonItem(title: "Done", style: .plain, target: dateFilterTextField, action: #selector(tapCancel))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
//            let done = UIBarButtonItem(title: "Done", style: .done, target: dateFilterTextField, action: #selector(tapCancel))
        //toolBar.setItems([cancel,flexibleSpace,done], animated: false)
        toolBar.setItems([flexibleSpace,cancel], animated: false)
        dateFilterTextField.inputAccessoryView = toolBar
        
        dateFilterTextField.inputView = picker
        
    }
    
    
    @objc func updateDateField(sender: UIDatePicker) {
        dateFilterTextField?.text = formatDateForDisplay(date: sender.date)
        selectedDate = sender.date
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }

    // Formats the date chosen with the date picker.
    fileprivate func formatDateForDisplay(date: Date) -> String {
        let formatter = DateFormatter()
        // locale 설정마다 다름 https://stackoverflow.com/questions/13952063/how-to-change-the-format-of-date-in-date-picker/13952239#13952239
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    
    func initStyle() {
        
        dateTitleLabel.text = S.staticFilterTitle
        todayTitle.text = S.staticToday
        todayGraphDescription.text = S.staticTodayDescription
        weekGraphTitle.text = S.staticWeek
        weekGraphDescription.text = S.staticWeekDescription
        monthGraphTitle.text = S.staticMonth
        monthGraphDescription.text = S.staticMonthDescription
        todoAnalysisButton.setTitle(S.staticCustomButton, for: .normal)
        
        dateFilterView.layer.cornerRadius = 15
        analysisDateButton.layer.cornerRadius = 15
        dayChartViewWrapper.backgroundColor = .white
        dayChartViewWrapper.layer.cornerRadius = 15
        
        weekChartViewWrapper.backgroundColor = .white
        weekChartViewWrapper.layer.cornerRadius = 15
        weekBarChartView.noDataText =  S.noData 
        weekBarChartView.noDataFont = .systemFont(ofSize: 20)
        weekBarChartView.noDataTextColor = .lightGray
        
        monthChartViewWrapper.backgroundColor = .white
        monthChartViewWrapper.layer.cornerRadius = 15
        
        todoAnalysisButton.layer.cornerRadius = 15
        
        dateFilterTextField.text = formatDateForDisplay(date: Date())
    }
    
    func setDayPieChart(dataPoints: [String], values: [Double]) {
        if dataPoints.count > 0 {
            // 1. Set ChartDataEntry
            var dataEntries: [ChartDataEntry] = []
            
            for i in 0..<dataPoints.count {
                let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
                dataEntries.append(dataEntry)
            }
            
            // 2. Set ChartDataSet
            let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
            //pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
            pieChartDataSet.colors =  ChartColorTemplates.pastel()
            
            // 3. Set ChartData Format
            let pieChartData = PieChartData(dataSet: pieChartDataSet)
            let format = NumberFormatter()
            // 소숫점 표현
            format.numberStyle = .decimal
            let formatter = DefaultValueFormatter(formatter: format)
            pieChartData.setValueFormatter(formatter)
            
            pieChartDataSet.valueTextColor = .black
            pieChartDataSet.entryLabelColor = .black
            
            // 4. Assign it to the chart’s data
            dayPieChartView.data = pieChartData
            
            // 5. 부가적인 설정
            
            // 투명 새도우
            dayPieChartView.transparentCircleRadiusPercent = 0.0
            
            // legend
            dayPieChartView.legend.horizontalAlignment = .center
            dayPieChartView.legend.verticalAlignment = .bottom
            dayPieChartView.legend.orientation = .horizontal
            dayPieChartView.legend.xEntrySpace = 7
            dayPieChartView.legend.yEntrySpace = 0
            dayPieChartView.legend.yOffset = 10
            dayPieChartView.legend.xOffset = 10
            
            // center text 설정
            let attributedString = NSAttributedString(string:"\(dayPieCenterText) hour",
                                                      attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                                                  NSAttributedString.Key.font: UIFont(name: "Arial", size: 18.0) as Any])
            dayPieChartView.centerAttributedText = attributedString
        }
    }
    
    func setWeekBarChart(dataPoints: [String], values: [Double])  {
        // 데이터 설정
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "요일")
        
        // 차트 컬러
        chartDataSet.colors = [.systemBlue]
        
        // 데이터 삽입
        let chartData = BarChartData(dataSet: chartDataSet)
        weekBarChartView.data = chartData
        
        
        // 옵션 설정
        // 선택 안되게
        chartDataSet.highlightEnabled = false
        
        // 줌 안되게
        weekBarChartView.doubleTapToZoomEnabled = false
        
        // X축 레이블 위치 조정
        weekBarChartView.xAxis.labelPosition = .bottom
        // X축 레이블 포맷 지정
        weekBarChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: weeks)
        weekBarChartView.data?.setValueFormatter(DefaultValueFormatter(decimals: 1))
        // 오른쪽 레이블 제거
        weekBarChartView.rightAxis.enabled = false
        weekBarChartView.legend.enabled = false
        
        // 리미트라인
        //let ll = ChartLimitLine(limit: 10.0, label: "타겟")
        //barChartView.leftAxis.addLimitLine(ll)
        
        // 맥시멈
        // weekBarChartView.leftAxis.axisMaximum = 24
        // 미니멈
        weekBarChartView.leftAxis.axisMinimum = 0
        weekBarChartView.backgroundColor = .white
        
        weekBarChartView.xAxis.drawGridLinesEnabled = false
        weekBarChartView.rightAxis.enabled = false
        
        weekBarChartView.leftAxis.axisLineColor = .gray
        weekBarChartView.leftAxis.gridColor = .gray
        weekBarChartView.leftAxis.zeroLineColor = .gray
        weekBarChartView.leftAxis.labelTextColor = .gray
        weekBarChartView.leftAxis.labelCount = 3
        weekBarChartView.xAxis.labelTextColor = .gray
        
        
        
        weekBarChartView.barData?.barWidth = 0.7
        
//        barChartView.dragXEnabled = true
        // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
        weekBarChartView.xAxis.setLabelCount(7, force: false)
        weekBarChartView.setVisibleXRangeMaximum(7)
        
        weekBarChartView.leftAxis.enabled = false
        
        weekBarChartView.drawBordersEnabled = false
        weekBarChartView.chartDescription?.enabled = true
        weekBarChartView.xAxis.drawLabelsEnabled = true
        weekBarChartView.xAxis.drawAxisLineEnabled = true
       
        
        weekBarChartView.layer.cornerRadius = 15
        
        // 테스트
        weekBarChartView.borderLineWidth = 15
       
        weekBarChartView.legend.form = .none
        
    }
    
    func setMonthBarChart(dataPoints: [String], values: [Double]) {
        // 데이터 생성
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "날짜")
        
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
        // value 포맷 지정
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
//        barChartView.dragXEnabled = true
        // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
        if months.count < 7 {
            monthBarChartView.xAxis.setLabelCount(months.count, force: false)
            monthBarChartView.setVisibleXRangeMaximum(Double(months.count))
        }
        else {
            monthBarChartView.xAxis.setLabelCount(7, force: false)
            monthBarChartView.setVisibleXRangeMaximum(7)
        }
      
        
        monthBarChartView.leftAxis.enabled = false
        
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


//MARK: - Realm Data Manipulation Methods
extension AnalysisViewController {
    func loadDayTodo() {
        let start = Calendar.current.startOfDay(for: selectedDate!)
        let end: Date = {
            let components = DateComponents(day: 1, second: -1)
            return Calendar.current.date(byAdding: components, to: start)!
        }()
        
        todoDayItems = realm.objects(Todo.self).filter("date BETWEEN %@", [start, end]).filter("totalSeconds != 0")
    }
    
    func loadWeekTodo() {
        let start = Calendar.current.weekBoundary(for: selectedDate!)!.startOfWeek!
        let end = Calendar.current.weekBoundary(for: selectedDate!)!.endOfWeek!
        
       
        todoWeekItems = realm.objects(Todo.self).filter("date BETWEEN %@", [start, end]).sorted(byKeyPath: "date", ascending: true)
    }
    
    func loadMonthTodo() {
        let start = Calendar.current.monthBoundary(for: selectedDate!)!.startOfMonth!
        let end = Calendar.current.monthBoundary(for: selectedDate!)!.endOfMonth!
        todoMonthItems = realm.objects(Todo.self).filter("date BETWEEN %@", [start, end])
    }
    
    
    
}

