# barom_me_app

A new Flutter project.

## Environments

Three flavors are available, selected via the entry-point target:

| Entry point | Command | API base URL |
|---|---|---|
| Local dev | `fvm flutter run -t lib/main_dev.dart` | `http://127.0.0.1:8000/api/v1` |
| Staging | `fvm flutter run -t lib/main_stage.dart` | `https://staging-api.barom.me/api/v1` |
| Production | `fvm flutter run -t lib/main_production.dart` | `https://barom.me/api/v1` |

`lib/main.dart` also runs the local dev flavor.

For a physical phone/device on the same LAN, point dev at your machine:

```bash
fvm flutter run -t lib/main_dev.dart --dart-define=API_HOST=192.168.1.10
```
# barom_me_app
