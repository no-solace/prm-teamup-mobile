# test_tc11_export_pdf_and_upload (run 2)

- Session: `b07b7cf9-fcd6-4c52-86e0-49d1fa23224c`
- Status: completed, 184.5s
- Output: `{"saw_progress": true, "status_text": "Uploaded 13 KB. Opening the PDF share dialog.", "saved_reports_visible": true}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` action=stop, app_name=com.group6.teamup_exe |
| 2 | ![](step-02.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=launch |
| 3 | ![](step-03.jpg) | `wait_for_delay` time_in_ms=2000 |
| 4 | ![](step-04.jpg) | `swipe` direction=up |
| 5 | ![](step-05.jpg) | `swipe` direction=up |
| 6 | ![](step-06.jpg) | `swipe` direction=up, target_description=scroll down list, start=[500, 700], end=[500, 200] |
| 7 | ![](step-07.jpg) | `click` target=12 |
| 8 | ![](step-08.jpg) | `click` target=3 |
| 9 | ![](step-09.jpg) | `click` target_description=Choose CSV button, target=[500, 240] |
| 10 | ![](step-10.jpg) | `click` target=9 |
| 11 | ![](step-11.jpg) | `click` target=6 |
| 12 | ![](step-12.jpg) | `wait_for_delay` time_in_ms=2000 |
| 13 | ![](step-13.jpg) | `click` target=9 |
| 14 | ![](step-14.jpg) | `click` target=1 |
| 15 | ![](step-15.jpg) | `click` target=16 |
| 16 | ![](step-16.jpg) | `swipe` direction=up |
| 17 | ![](step-17.jpg) | `click` target=7 |
| 18 | ![](step-18.jpg) | `click` target=6 |
| 19 | ![](step-19.jpg) | `click` target=8 |
| 20 | ![](step-20.jpg) | `report_task_status` completed: {"saw_progress": true, "status_text": "Uploaded 13 KB. Opening the PDF share dialog.", "saved_reports_visible": true} |

Final screen:

![](final.jpg)
