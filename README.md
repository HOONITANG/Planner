## Planner

# **💡 Background**

### 목적 및 계기

- 할일을 달성하는데 걸린 시간을 알기 위해 만들게 되었다.
- 기존 TodoList에 시간을 측정하여 보다 구체적으로 목표를 완수하기 위해 만들게 되었다.

### 필수 기능

- 큰 틀로 년, 월, 일간 계획이 있어야한다.
- 할 일에 대한 표시가 있어야한다.
- 시간 별로 계획을 작성 할 수 있어야 한다.
- 할 일을 뒤로 미룰 수 있어야 한다.
- 목표에 대한 달성률을 볼 수 있어야 한다.

---

# **🛠 Development**

- Back-end
    - 해당하는 부분 없음
- Front-end
    - StoryBoard을 통해 뷰를 구성하였습니다.
    - Realm을 통해 데이터를 관리하였습니다.
    - MVC 패턴으로 구성하였으나, 많은 부분이 수정이 필요합니다.
    - Charts 라이브러리를 통해 대시보드를 표현하였습니다.
    - CalendarKit 라이브러리를 통해 스케쥴을 표현하였습니다.

- realm 구조
    - EventDay
        - Todo에 관한 시간측정을 위해 사용되는 데이터
            - title: 제목,
            - startDate: 시작 시간
            - endDate: 끝낸 시간
            - calendarColor: 표시할 색
            - backgroundColor: 표시할 백그라운드 색
            - editedEvent: 수정 여부
            - startEndDiffSecond: 걸린 시간
            - activedEvent: 시작 여부
    - SectionTodo
        - Todo의 그룹을 담당하고 있는 데이터
            - title: 제목
            - createDate: 생성 날짜
            - sort: 정렬 순서
            - todos : todo 데이터
    - todo
        - Todo에 관한 개별 데이터
            - title: 제목
            - date: 생성날짜
            - status: 시작,종료,미룸,완료, 미완료에 관한 상태값
            - sort: 정렬 순서
            - totalSeconds: 총 걸린 시간
            - isFix: 고정 유무
            - dayEvents: EventDay 데이터
    - WeekMemo
        - 주간 메모에 관한 데이터
            - title: 제목
            - date: 생성 일자
            - status: 완료, 미완료에 관한 상태값
            - sort: 정렬 순서

---

## **Features & Screens**

### HomePage

- 주간메모
- Todo를 관리하는 페이지

### DailyPage

- 측정된 시간을 확인할 수 있는 페이지

### DashBoardPage

- 주,월 별로 총 사용된 시간을 확인 할 수 있는 페이지

### TagPage

- todo Tag를 관리하는 페이지

---

# **🛫 Result**

- Swift를 학습하면서, 개발을 진행하였는데 ReactNative처럼 기본기를 갖추고 개발한 것이 아니라 기능을 추가하거나 수정하는데 매우 힘들었다.
- 사용 할 수 있는 앱을 만들기 위해서 생각을 많이 했는데, 기획과 디자인이 쉽지 않음을 알게되었다.
