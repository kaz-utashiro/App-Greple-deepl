# NAME

App::Greple::xlate - vertaalondersteuningsmodule voor greple

# SYNOPSIS

    greple -Mxlate::deepl --xlate pattern target-file

# DESCRIPTION

**Greple** **xlate** module vindt tekstblokken en vervangt ze door de vertaalde tekst. Momenteel wordt alleen DeepL service ondersteund door de **xlate::deepl** module.

Als je normale tekstblokken in [pod](https://metacpan.org/pod/pod) style document wilt vertalen, gebruik dan **greple** commando met `xlate::deepl` en `perl` module zoals dit:

    greple -Mxlate::deepl -Mperl --pod --re '^(\w.*\n)+' --all foo.pm

Patroon `^(\w.*\n)+` betekent opeenvolgende regels die beginnen met een alfa-numerieke letter. Dit commando toont het te vertalen gebied. Optie **--all** wordt gebruikt om de hele tekst te produceren.

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/select-area.png">
    </p>
</div>

Voeg dan de optie `--xlate` toe om het geselecteerde gebied te vertalen. Het zal ze vinden en vervangen door de uitvoer van het **deepl** commando.

Standaard worden originele en vertaalde tekst afgedrukt in het "conflict marker" formaat dat compatibel is met [git(1)](http://man.he.net/man1/git). Door `ifdef` formaat te gebruiken, kunt u gemakkelijk het gewenste deel krijgen met het [unifdef(1)](http://man.he.net/man1/unifdef) commando. Het formaat kan gespecificeerd worden met de optie **--xlate-format**.

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/format-conflict.png">
    </p>
</div>

Als u de hele tekst wilt vertalen, gebruik dan de optie **--match-entire**. Dit is een short-cut om aan te geven dat het patroon overeenkomt met de hele tekst `(?s).*`.

# OPTIONS

- **--xlate**
- **--xlate-color**
- **--xlate-fold**
- **--xlate-fold-width**=_n_ (Default: 70)

    Roep het vertaalproces op voor elk gematcht gebied.

    Zonder deze optie gedraagt **greple** zich als een normaal zoekcommando. U kunt dus controleren welk deel van het bestand zal worden vertaald voordat u het eigenlijke werk uitvoert.

    Commandoresultaat gaat naar standaard out, dus redirect naar bestand indien nodig, of overweeg [App::Greple::update](https://metacpan.org/pod/App%3A%3AGreple%3A%3Aupdate) module te gebruiken.

    Optie **--xlate** roept **--xlate-kleur** aan met **--color=never** optie.

    Met de optie **--xlate-fold** wordt geconverteerde tekst gevouwen met de opgegeven breedte. De standaardbreedte is 70 en kan worden ingesteld met de optie **--xlate-fold-width**. Vier kolommen zijn gereserveerd voor inloopoperaties, zodat elke regel maximaal 74 tekens kan bevatten.

- **--xlate-engine**=_engine_

    Specificeer de te gebruiken vertaalmachine. U hoeft deze optie niet te gebruiken omdat module `xlate::deepl` deze verklaart als `--xlate-engine=deepl`.

- **--xlate-to** (Default: `JA`)

    Geef de doeltaal op. U kunt de beschikbare talen krijgen met het commando `deepl languages` wanneer u de engine **DeepL** gebruikt.

- **--xlate-format**=_format_ (Default: conflict)

    Specificeer het uitvoerformaat voor originele en vertaalde tekst.

    - **conflict**

        Print originele en vertaalde tekst in [git(1)](http://man.he.net/man1/git) conflictmarker formaat.

            <<<<<<< ORIGINAL
            original text
            =======
            translated Japanese text
            >>>>>>> JA

        U kunt het originele bestand herstellen met de volgende [sed(1)](http://man.he.net/man1/sed) opdracht.

            sed -e '/^<<<<<<< /d' -e '/^=======$/,/^>>>>>>> /d'

    - **ifdef**

        Originele en vertaalde tekst afdrukken in [cpp(1)](http://man.he.net/man1/cpp) `#ifdef` formaat.

            #ifdef ORIGINAL
            original text
            #endif
            #ifdef JA
            translated Japanese text
            #endif

        U kunt alleen Japanse tekst terughalen met het commando **unifdef**:

            unifdef -UORIGINAL -DJA foo.ja.pm

    - **space**

        Originele en vertaalde tekst afdrukken, gescheiden door een enkele lege regel.

    - **none**

        Als het formaat `none` of onbekend is, wordt alleen de vertaalde tekst afgedrukt.

- **--**\[**no-**\]**xlate-progress** (Default: True)

    Zie het resultaat van de vertaling in real time in de STDERR uitvoer.

- **--match-entire**

    Stel de hele tekst van het bestand in als doelgebied.

# CACHE OPTIONS

De module **xlate** kan de tekst van de vertaling voor elk bestand in de cache opslaan en lezen vóór de uitvoering om de overhead van het vragen aan de server te elimineren. Met de standaard cachestrategie `auto` worden cachegegevens alleen onderhouden als het cachebestand voor het doelbestand bestaat. Als het corresponderende cachebestand niet bestaat, wordt het niet aangemaakt.

- --xlate-cache=_strategy_
    - `auto` (Default)

        Onderhoudt het cache bestand als het bestaat.

    - `create`

        Maak een leeg cache bestand en sluit af.

    - `always`, `yes`, `1`

        Cache-bestand toch behouden voor zover het doelbestand een normaal bestand is.

    - `never`, `no`, `0`

        Cache-bestand nooit gebruiken, zelfs niet als het bestaat.

    - `accumulate`

        Standaard gedrag, ongebruikte gegevens worden verwijderd uit cache bestand. Als u ze niet wilt verwijderen en in het bestand wilt houden, gebruik dan `accumuleren`.

# ENVIRONMENT

- DEEPL\_AUTH\_KEY

    Stel uw authenticatiesleutel in voor DeepL service.

# SEE ALSO

- [https://github.com/DeepLcom/deepl-python](https://github.com/DeepLcom/deepl-python)

    DeepL Python bibliotheek en CLI commando.

- [App::Greple](https://metacpan.org/pod/App%3A%3AGreple)

    Zie de **greple** handleiding voor de details over het doeltekstpatroon. Gebruik **--inside**, **--outside**, **--include**, **--exclude** opties om het overeenkomende gebied te beperken.

- [App::Greple::update](https://metacpan.org/pod/App%3A%3AGreple%3A%3Aupdate)

    U kunt de module `-Mupdate` gebruiken om bestanden te wijzigen door het resultaat van het commando **greple**.

- [App::sdif](https://metacpan.org/pod/App%3A%3Asdif)

    Gebruik **sdif** om het formaat van de conflictmarkering naast de optie **-V** te tonen.

# AUTHOR

Kazumasa Utashiro

# LICENSE

Copyright © 2023 Kazumasa Utashiro.

Deze bibliotheek is vrije software; u kunt hem herdistribueren en/of wijzigen onder dezelfde voorwaarden als Perl zelf.
