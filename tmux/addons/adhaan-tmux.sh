# ~/.config/tmux/prayer_status.sh
#!/bin/bash

CACHE="$HOME/.cache/prayer_tmux.json"
CITY="Mansoura"  # أو اللي تحبه

# refresh cache once per day
if [ ! -f "$CACHE" ] || [ "$(date +%Y-%m-%d)" != "$(jq -r '.date' "$CACHE" 2>/dev/null)" ]; then
    response=$(curl -sL --max-time 5 \
        "https://api.aladhan.com/v1/timingsByCity?city=$CITY&country=EG&method=5")
    if [ -n "$response" ]; then
        echo "$response" | python3 -c "
import json, sys
data = json.load(sys.stdin)
timings = data['data']['timings']
import datetime
out = {'date': str(datetime.date.today()), 'timings': {}}
for p in ['Fajr','Dhuhr','Asr','Maghrib','Isha']:
    out['timings'][p] = timings[p][:5]  # strip timezone suffix
print(json.dumps(out))
" > "$CACHE"
    fi
fi

# find next prayer
python3 -c "
import json, datetime

with open('$CACHE') as f:
    data = json.load(f)

now = datetime.datetime.now()
prayers = data['timings']
next_name = None
next_diff = None

for name, t in prayers.items():
    pt = datetime.datetime.strptime(t, '%H:%M').replace(
        year=now.year, month=now.month, day=now.day)
    diff = (pt - now).total_seconds()
    if diff > 0 and (next_diff is None or diff < next_diff):
        next_diff = diff
        next_name = name

if next_name:
    mins = int(next_diff // 60)
    hrs  = mins // 60
    mins = mins % 60
    if hrs > 0:
        print(f'{next_name} {hrs}h{mins}m')
    else:
        print(f'{next_name} {mins}m')
else:
    print('Fajr tmr')
"
