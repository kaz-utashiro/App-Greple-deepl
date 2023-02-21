# NAME

App::Greple::xlate - Übersetzungsunterstützungsmodul für Greple

# SYNOPSIS

    greple -Mxlate::deepl --xlate pattern target-file

# DESCRIPTION

**Greple** **xlate** Modul findet Textblöcke und ersetzt sie durch den übersetzten Text. Derzeit wird nur der DeepL Service vom **xlate::deepl** Modul unterstützt.

Wenn Sie einen normalen Textblock in einem Dokument im Stil von [pod](https://metacpan.org/pod/pod) übersetzen wollen, verwenden Sie den Befehl **greple** mit dem Modul `xlate::deepl` und `perl` wie folgt:

    greple -Mxlate::deepl -Mperl --pod --re '^(\w.*\n)+' --all foo.pm

Pattern `^(\w.*\n)+` bedeutet aufeinanderfolgende Zeilen, die mit einem alphanumerischen Buchstaben beginnen. Dieser Befehl zeigt den zu übersetzenden Bereich an. Die Option **--all** wird verwendet, um den gesamten Text zu übersetzen.

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/select-area.png">
    </p>
</div>

Fügen Sie dann die Option `--xlate` hinzu, um den ausgewählten Bereich zu übersetzen. Sie werden gefunden und durch die Ausgabe des Befehls **deepl** ersetzt.

Standardmäßig werden der ursprüngliche und der übersetzte Text im Format der "Konfliktmarkierung" ausgegeben, das mit [git(1)](http://man.he.net/man1/git) kompatibel ist. Wenn Sie das Format `ifdef` verwenden, können Sie den gewünschten Teil mit dem Befehl [unifdef(1)](http://man.he.net/man1/unifdef) leicht erhalten. Das Format kann mit der Option **--xlate-format** angegeben werden.

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/format-conflict.png">
    </p>
</div>

Wenn Sie den gesamten Text übersetzen wollen, verwenden Sie die Option **--match-entire**. Dies ist eine Abkürzung, um das Muster für den gesamten Text `(?s).*` anzugeben.

# OPTIONS

- **--xlate**
- **--xlate-color**
- **--xlate-fold**
- **--xlate-fold-width**=_n_ (Default: 70)

    Rufen Sie den Übersetzungsprozess für jeden übereinstimmenden Bereich auf.

    Ohne diese Option verhält sich **greple** wie ein normaler Suchbefehl. Sie können also prüfen, welcher Teil der Datei Gegenstand der Übersetzung sein wird, bevor Sie die eigentliche Arbeit aufrufen.

    Das Ergebnis des Befehls wird im Standard-Output ausgegeben, also leiten Sie es bei Bedarf in eine Datei um oder verwenden Sie das Modul [App::Greple::update](https://metacpan.org/pod/App%3A%3AGreple%3A%3Aupdate).

    Die Option **--xlate** ruft die Option **--xlate-color** mit der Option **--color=never** auf.

    Mit der Option **--xlate-fold** wird der konvertierte Text um die angegebene Breite gefaltet. Die Standardbreite ist 70 und kann mit der Option **--xlate-fold-width** eingestellt werden. Vier Spalten sind für den Einlaufvorgang reserviert, so dass jede Zeile maximal 74 Zeichen enthalten kann.

- **--xlate-engine**=_engine_

    Geben Sie die zu verwendende Übersetzungsmaschine an. Sie brauchen diese Option nicht zu verwenden, da das Modul `xlate::deepl` sie als `--xlate-engine=deepl` deklariert.

- **--xlate-to** (Default: `JA`)

    Geben Sie die Zielsprache an. Sie können die verfügbaren Sprachen mit dem Befehl `deepl languages` abrufen, wenn Sie die Engine **DeepL** verwenden.

- **--xlate-format**=_format_ (Default: conflict)

    Geben Sie das Ausgabeformat für den Originaltext und den übersetzten Text an.

    - **conflict**

        Drucken Sie den Originaltext und den übersetzten Text im Format [git(1)](http://man.he.net/man1/git) conflict marker.

            <<<<<<< ORIGINAL
            original text
            =======
            translated Japanese text
            >>>>>>> JA

        Sie können die Originaldatei mit dem nächsten Befehl [sed(1)](http://man.he.net/man1/sed) wiederherstellen.

            sed -e '/^<<<<<<< /d' -e '/^=======$/,/^>>>>>>> /d'

    - **ifdef**

        Druckt den originalen und übersetzten Text im Format [cpp(1)](http://man.he.net/man1/cpp) `#ifdef`.

            #ifdef ORIGINAL
            original text
            #endif
            #ifdef JA
            translated Japanese text
            #endif

        Mit dem Befehl **unifdef** können Sie nur den japanischen Text wiederherstellen:

            unifdef -UORIGINAL -DJA foo.ja.pm

    - **space**

        Original und übersetzten Text durch eine einzelne Leerzeile getrennt ausgeben.

    - **none**

        Wenn das Format `none` oder unbekannt ist, wird nur der übersetzte Text gedruckt.

- **--**\[**no-**\]**xlate-progress** (Default: True)

    Sehen Sie das Ergebnis der Übersetzung in Echtzeit in der STDERR-Ausgabe.

- **--match-entire**

    Legen Sie den gesamten Text der Datei als Zielbereich fest.

# CACHE OPTIONS

Das Modul **xlate** kann den übersetzten Text für jede Datei im Cache speichern und vor der Ausführung lesen, um den Overhead durch Anfragen an den Server zu vermeiden. Bei der Standard-Cache-Strategie `auto` werden Cache-Daten nur dann beibehalten, wenn die Cache-Datei für die Zieldatei existiert. Wenn die entsprechende Cachedatei nicht existiert, wird sie nicht erstellt.

- --xlate-cache=_strategy_
    - `auto` (Default)

        Cache-Datei beibehalten, wenn sie existiert.

    - `create`

        Leere Cachedatei erstellen und beenden.

    - `always`, `yes`, `1`

        Cache trotzdem beibehalten, sofern das Ziel eine normale Datei ist.

    - `never`, `no`, `0`

        Niemals die Cache-Datei verwenden, selbst wenn sie vorhanden ist.

    - `accumulate`

        Standardmäßig werden ungenutzte Daten aus der Cache-Datei entfernt. Wenn Sie sie nicht entfernen und in der Datei behalten wollen, verwenden Sie `accumulate`.

# ENVIRONMENT

- DEEPL\_AUTH\_KEY

    Legen Sie Ihren Authentifizierungsschlüssel für den Dienst DeepL fest.

# SEE ALSO

- [https://github.com/DeepLcom/deepl-python](https://github.com/DeepLcom/deepl-python)

    DeepL Python-Bibliothek und CLI-Befehl.

- [App::Greple](https://metacpan.org/pod/App%3A%3AGreple)

    Lesen Sie das Handbuch **greple** für Details über Zieltextmuster. Verwenden Sie die Optionen **--inside**, **--outside**, **--include**, **--exclude**, um den Suchbereich einzuschränken.

- [App::Greple::update](https://metacpan.org/pod/App%3A%3AGreple%3A%3Aupdate)

    Sie können das Modul `-Mupdate` verwenden, um Dateien anhand des Ergebnisses des Befehls **greple** zu ändern.

- [App::sdif](https://metacpan.org/pod/App%3A%3Asdif)

    Verwenden Sie **sdif**, um das Format der Konfliktmarkierung zusammen mit der Option **-V** anzuzeigen.

# AUTHOR

Kazumasa Utashiro

# LICENSE

Urheberrecht ©︎ 2023 Kazumasa Utashiro.

Diese Bibliothek ist freie Software; Sie können sie unter den gleichen Bedingungen wie Perl selbst weitergeben und/oder verändern.
