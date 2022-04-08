Quick & dirty Integration von *batctl ping* in [smokeping](https://oss.oetiker.ch/smokeping/) auf einem Ubuntu Debian 11 (bullseye) auf einem Raspberry 3.

Als Basis wurde das perl Paket FPing.pm genommen und umgearbeitet.

Da batctl nicht mehrere Ziele gleichzeitig pingen kann wurde ein wrapper *Smokebatctl.py* drumherum gebaut der das übernimmt.
Smokebatctl.py muß ausführbar sein
*batctl* benötigt sudo, daher in den sudoers für den Nutzer in meinem Falle smokeping sudo ermöglichen.

In /etc/smokeping/config.d/Probes ist die Probe SmokeBatctl konfiguriert.

Wer Fehler findet darf sie behalten oder fixen ;)
Verbesserungen sind stets willkommen.
