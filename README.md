Quick & dirty Integration von *batctl ping* in [smokeping](https://oss.oetiker.ch/smokeping/) auf einem Ubuntu Debian 11 (bullseye) auf einem Raspberry 3.

Als Basis wurde das perl Paket FPing.pm genommen und umgearbeitet.

Da batctl nicht mehrere Ziele gleichzeitig pingen kann wurde ein wrapper *Smokebatctl.py* drumherum gebaut der das �bernimmt.
Smokebatctl.py mu� ausf�hrbar sein
*batctl* ben�tigt sudo, daher in den sudoers f�r den Nutzer in meinem Falle smokeping sudo erm�glichen.

In /etc/smokeping/config.d/Probes ist die Probe SmokeBatctl konfiguriert.

Wer Fehler findet darf sie behalten oder fixen ;)
Verbesserungen sind stets willkommen.
