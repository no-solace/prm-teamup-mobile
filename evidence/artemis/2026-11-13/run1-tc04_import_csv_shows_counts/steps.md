# test_tc04_import_csv_shows_counts (run 1)

- Session: `95298ffc-b5f5-4d23-9cd0-d7cad2e9dc83`
- Status: completed, 47.5s
- Output: `{"preview_button": "Import 12 students", "imported": 12, "in_a_group": 9, "available": 3}`

| Step | Screen before | Action |
|---|---|---|
| 1 | ![](step-01.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=stop |
| 2 | ![](step-02.jpg) | `manage_app` app_name=com.group6.teamup_exe, action=launch |
| 3 | ![](step-03.jpg) | `wait_for_delay` time_in_ms=3000 |
| 4 | ![](step-04.jpg) | `click` target=4 |
| 5 | ![](step-05.jpg) | `click` target_description=Choose CSV button, target=[500, 240] |
| 6 | ![](step-06.jpg) | `click` target=11 |
| 7 | ![](step-07.jpg) | `click` target=6 |
| 8 | ![](step-08.jpg) | `report_task_status` completed: {"preview_button": "Import 12 students", "imported": 12, "in_a_group": 9, "available": 3} |

Final screen:

![](final.jpg)
