# test_tc11_export_pdf_and_upload (run 1)

- Session: `f8d4337d-7af1-4647-b967-2f764b4b8633`
- Status: completed, 95.2s
- Output: `{"saw_progress": true, "status_text": "Uploaded 13 KB. Opening the PDF share dialog.", "saved_reports_visible": true}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` action=stop, app_name=com.group6.teamup_exe |
| 2 | ![](step-02.jpg) | `manage_app` action=launch, app_name=com.group6.teamup_exe |
| 3 | ![](step-03.jpg) | `wait_for_delay` time_in_ms=2000 |
| 4 | ![](step-04.jpg) | `swipe` direction=up |
| 5 | ![](step-05.jpg) | `click` target=12 |
| 6 | ![](step-06.jpg) | `click` target=[500, 240], target_description=Choose CSV button |
| 7 | ![](step-07.jpg) | `click` target=11 |
| 8 | ![](step-08.jpg) | `click` target=5 |
| 9 | ![](step-09.jpg) | `click` target=6 |
| 10 | ![](step-10.jpg) | `click` target=1 |
| 11 | ![](step-11.jpg) | `click` target=16 |
| 12 | ![](step-12.jpg) | `swipe` direction=up |
| 13 | ![](step-13.jpg) | `click` target=7 |
| 14 | ![](step-14.jpg) | `click` target=1 |
| 15 | ![](step-15.jpg) | `click` target=8 |
| 16 | ![](step-16.jpg) | `report_task_status` completed: {"saw_progress": true, "status_text": "Uploaded 13 KB. Opening the PDF share dialog.", "saved_reports_visible": true} |

Final screen:

![](final.jpg)
