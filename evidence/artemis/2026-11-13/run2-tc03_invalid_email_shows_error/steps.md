# test_tc03_invalid_email_shows_error (run 2)

- Session: `a4ea8a3f-a429-45d2-850d-f231e7783766`
- Status: completed, 84.9s
- Output: `{"error_text": "Enter a valid email", "reached_classes": false}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=stop |
| 2 | ![](step-02.jpg) | `manage_app` action=launch, app_name=com.group6.teamup_exe |
| 3 | ![](step-03.jpg) | `click` target=4 |
| 4 | ![](step-04.jpg) | `input_text` clear_exist=True, text=abc, target=6 |
| 5 | ![](step-05.jpg) | `input_text` text=abc, target=44, clear_exist=True |
| 6 | ![](step-06.jpg) | `click` target=2 |
| 7 | ![](step-07.jpg) | `input_text` target=46, clear_exist=True, text=Passw0rd! |
| 8 | ![](step-08.jpg) | `click` target=2 |
| 9 | ![](step-09.jpg) | `click` target=50 |
| 10 | ![](step-10.jpg) | `report_task_status` completed: {"error_text": "Enter a valid email", "reached_classes": false} |

Final screen:

![](final.jpg)
