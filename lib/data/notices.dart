class Notice {
  final String title;
  final String date; // ISO-like string for now (prototype)

  Notice(this.title, this.date);
}

final noticeDb = [
  Notice('Course registration window: 10–14 Dec', '2025-12-10'),
  Notice('Mid-semester examination timetable released', '2025-12-05'),
  Notice('Fee payment last date: 15 Dec', '2025-12-02'),
  Notice('Hostel allocation results announced', '2025-11-28'),
];

