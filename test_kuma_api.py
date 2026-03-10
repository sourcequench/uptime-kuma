import os
from uptime_kuma_api import UptimeKumaApi

KUMA_URL = "https://status.sourcequench.org"
user = os.getenv("KUMA_USER")
password = os.getenv("KUMA_PASSWORD")

with UptimeKumaApi(KUMA_URL) as api:
    api.login(user, password)
    monitors = api.get_monitors()
    if monitors:
        m_id = monitors[0]['id']
        print(f"Testing tags for monitor ID {m_id} ({monitors[0]['name']})")
        tags = api.get_monitor_tags(m_id)
        print(f"Current tags: {tags}")
