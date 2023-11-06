# NAME

App::Greple::xlate - module de support de traduction pour greple

# SYNOPSIS

    greple -Mxlate -e ENGINE --xlate pattern target-file

    greple -Mxlate::deepl --xlate pattern target-file

# VERSION

Version 0.25

# DESCRIPTION

Le module **Greple** **xlate** trouve des blocs de texte et les remplace par le texte traduit. Incluez les modules DeepL (`deepl.pm`) et ChatGPT (`gpt3.pm`) pour le moteur en arrière-plan.

Si vous souhaitez traduire un bloc de texte normal dans un document de style [pod](https://metacpan.org/pod/pod), utilisez la commande **greple** avec les modules `xlate::deepl` et `perl` comme ceci :

    greple -Mxlate::deepl -Mperl --pod --re '^(\w.*\n)+' --all foo.pm

Le motif `^(\w.*\n)+` signifie des lignes consécutives commençant par une lettre alphanumérique. Cette commande affiche la zone à traduire. L'option **--all** est utilisée pour produire l'intégralité du texte.

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/select-area.png">
    </p>
</div>

Ensuite, ajoutez l'option `--xlate` pour traduire la zone sélectionnée. Il la trouvera et la remplacera par la sortie de la commande **deepl**.

Par défaut, le texte original et traduit est imprimé dans le format "conflict marker" compatible avec [git(1)](http://man.he.net/man1/git). En utilisant le format `ifdef`, vous pouvez obtenir la partie souhaitée avec la commande [unifdef(1)](http://man.he.net/man1/unifdef) facilement. Le format peut être spécifié par l'option **--xlate-format**.

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/format-conflict.png">
    </p>
</div>

Si vous souhaitez traduire l'intégralité du texte, utilisez l'option **--match-all**. Il s'agit d'un raccourci pour spécifier le motif correspondant à l'intégralité du texte `(?s).+`.

# OPTIONS

- **--xlate**
- **--xlate-color**
- **--xlate-fold**
- **--xlate-fold-width**=_n_ (Default: 70)

    Lancez le processus de traduction pour chaque zone correspondante.

    Sans cette option, **greple** se comporte comme une commande de recherche normale. Vous pouvez donc vérifier quelle partie du fichier sera soumise à la traduction avant de lancer le travail réel.

    Le résultat de la commande est renvoyé sur la sortie standard, donc redirigez-le vers un fichier si nécessaire, ou envisagez d'utiliser le module [App::Greple::update](https://metacpan.org/pod/App%3A%3AGreple%3A%3Aupdate).

    L'option **--xlate** appelle l'option **--xlate-color** avec l'option **--color=never**.

    Avec l'option **--xlate-fold**, le texte converti est plié selon la largeur spécifiée. La largeur par défaut est de 70 et peut être définie par l'option **--xlate-fold-width**. Quatre colonnes sont réservées pour l'opération run-in, donc chaque ligne peut contenir au maximum 74 caractères.

- **--xlate-engine**=_engine_

    Spécifie le moteur de traduction à utiliser. Si vous spécifiez directement le module du moteur, tel que `-Mxlate::deepl`, vous n'avez pas besoin d'utiliser cette option.

- **--xlate-labor**
- **--xlabor**

    Au lieu d'appeler le moteur de traduction, vous êtes censé travailler pour lui. Après avoir préparé le texte à traduire, il est copié dans le presse-papiers. Vous êtes censé le coller dans le formulaire, copier le résultat dans le presse-papiers et appuyer sur Entrée.

- **--xlate-to** (Default: `EN-US`)

    Spécifiez la langue cible. Vous pouvez obtenir les langues disponibles avec la commande `deepl languages` lorsque vous utilisez le moteur **DeepL**.

- **--xlate-format**=_format_ (Default: `conflict`)

    Spécifiez le format de sortie pour le texte original et traduit.

    - **conflict**, **cm**

        Affichez le texte original et traduit dans le format de marqueur de conflit [git(1)](http://man.he.net/man1/git).

            <<<<<<< ORIGINAL
            original text
            =======
            translated Japanese text
            >>>>>>> JA

        Vous pouvez récupérer le fichier original avec la commande [sed(1)](http://man.he.net/man1/sed) suivante.

            sed -e '/^<<<<<<< /d' -e '/^=======$/,/^>>>>>>> /d'

    - **ifdef**

        Affichez le texte original et traduit dans le format [cpp(1)](http://man.he.net/man1/cpp) `#ifdef`.

            #ifdef ORIGINAL
            original text
            #endif
            #ifdef JA
            translated Japanese text
            #endif

        Vous pouvez récupérer uniquement le texte japonais avec la commande **unifdef** :

            unifdef -UORIGINAL -DJA foo.ja.pm

    - **space**

        Affichez le texte original et traduit séparés par une seule ligne vide.

    - **xtxt**

        Si le format est `xtxt` (texte traduit) ou inconnu, seul le texte traduit est imprimé.

- **--xlate-maxlen**=_chars_ (Default: 0)

    Spécifiez la longueur maximale du texte à envoyer à l'API en une seule fois. La valeur par défaut est définie pour le service gratuit : 128K pour l'API (**--xlate**) et 5000 pour l'interface du presse-papiers (**--xlate-labor**). Vous pouvez peut-être modifier ces valeurs si vous utilisez le service Pro.

- **--**\[**no-**\]**xlate-progress** (Default: True)

    Voyez le résultat de la traduction en temps réel dans la sortie STDERR.

- **--match-all**

    Définissez l'intégralité du texte du fichier comme zone cible.

# CACHE OPTIONS

Le module **xlate** peut stocker le texte traduit en cache pour chaque fichier et le lire avant l'exécution pour éliminer les frais généraux de demande au serveur. Avec la stratégie de cache par défaut `auto`, il ne conserve les données en cache que lorsque le fichier de cache existe pour le fichier cible.

- --cache-clear

    L'option **--cache-clear** peut être utilisée pour initier la gestion du cache ou pour rafraîchir toutes les données de cache existantes. Une fois exécutée avec cette option, un nouveau fichier de cache sera créé s'il n'existe pas, puis automatiquement maintenu par la suite.

- --xlate-cache=_strategy_
    - `auto` (Default)

        Maintenez le fichier de cache s'il existe.

    - `create`

        Créez un fichier de cache vide et quittez.

    - `always`, `yes`, `1`

        Maintenez le cache de toute façon tant que la cible est un fichier normal.

    - `clear`

        Effacez d'abord les données du cache.

    - `never`, `no`, `0`

        N'utilisez jamais le fichier de cache même s'il existe.

    - `accumulate`

        Par défaut, les données inutilisées sont supprimées du fichier de cache. Si vous ne souhaitez pas les supprimer et les conserver dans le fichier, utilisez `accumulate`.

# COMMAND LINE INTERFACE

Vous pouvez facilement utiliser ce module depuis la ligne de commande en utilisant la commande `xlate` incluse dans le référentiel. Consultez les informations d'aide de `xlate` pour connaître son utilisation.

# EMACS

Chargez le fichier `xlate.el` inclus dans le référentiel pour utiliser la commande `xlate` depuis l'éditeur Emacs. La fonction `xlate-region` traduit la région donnée. La langue par défaut est `EN-US` et vous pouvez spécifier la langue en l'appelant avec un argument préfixe.

# ENVIRONMENT

- DEEPL\_AUTH\_KEY

    Définissez votre clé d'authentification pour le service DeepL.

- OPENAI\_API\_KEY

    Clé d'authentification OpenAI.

# INSTALL

## CPANMINUS

    $ cpanm App::Greple::xlate

## TOOLS

Vous devez installer les outils en ligne de commande pour DeepL et ChatGPT.

[https://github.com/DeepLcom/deepl-python](https://github.com/DeepLcom/deepl-python)

[https://github.com/tecolicom/App-gpty](https://github.com/tecolicom/App-gpty)

# SEE ALSO

[App::Greple::xlate](https://metacpan.org/pod/App%3A%3AGreple%3A%3Axlate)

[App::Greple::xlate::deepl](https://metacpan.org/pod/App%3A%3AGreple%3A%3Axlate%3A%3Adeepl)

[App::Greple::xlate::gpt3](https://metacpan.org/pod/App%3A%3AGreple%3A%3Axlate%3A%3Agpt3)

- [https://github.com/DeepLcom/deepl-python](https://github.com/DeepLcom/deepl-python)

    Bibliothèque DeepL Python et commande CLI.

- [https://github.com/openai/openai-python](https://github.com/openai/openai-python)

    Bibliothèque Python OpenAI

- [https://github.com/tecolicom/App-gpty](https://github.com/tecolicom/App-gpty)

    Interface en ligne de commande OpenAI

- [App::Greple](https://metacpan.org/pod/App%3A%3AGreple)

    Consultez le manuel **greple** pour plus de détails sur le motif de texte cible. Utilisez les options **--inside**, **--outside**, **--include**, **--exclude** pour limiter la zone de correspondance.

- [App::Greple::update](https://metacpan.org/pod/App%3A%3AGreple%3A%3Aupdate)

    Vous pouvez utiliser le module `-Mupdate` pour modifier les fichiers en fonction du résultat de la commande **greple**.

- [App::sdif](https://metacpan.org/pod/App%3A%3Asdif)

    Utilisez **sdif** pour afficher le format des marqueurs de conflit côte à côte avec l'option **-V**.

# AUTHOR

Kazumasa Utashiro

# LICENSE

Copyright © 2023 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
