# NAME

App::Greple::xlate - модуль поддержки перевода для greple

# SYNOPSIS

    greple -Mxlate -e ENGINE --xlate pattern target-file

    greple -Mxlate::deepl --xlate pattern target-file

# VERSION

Version 0.33

# DESCRIPTION

Модуль **xlate** **Greple** находит нужные текстовые блоки и заменяет их переведенным текстом. В настоящее время в качестве движка используются DeepL (модуль `deepl.pm`) и ChatGPT (модуль `gpt3.pm`). Также включена экспериментальная поддержка gpt-4.

Если вы хотите перевести обычные текстовые блоки в документе, написанном в стиле Perl's pod, используйте команду **greple** с модулем `xlate::deepl` и `perl` следующим образом:

    greple -Mxlate::deepl -Mperl --pod --re '^(\w.*\n)+' --all foo.pm

В этой команде строка шаблона `^(\w.*\n)+` означает последовательные строки, начинающиеся с буквы или цифры. Эта команда показывает выделенную область, которую нужно перевести. Опция **--all** используется для вывода всего текста.

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/select-area.png">
    </p>
</div>

Затем добавьте опцию `--xlate`, чтобы перевести выбранную область. Затем он найдет нужные разделы и заменит их выводом команды **deepl**.

По умолчанию оригинальный и переведенный текст выводится в формате "конфликтного маркера", совместимого с [git(1)](http://man.he.net/man1/git). Используя формат `ifdef`, вы можете легко получить нужную часть с помощью команды [unifdef(1)](http://man.he.net/man1/unifdef). Формат вывода можно указать с помощью опции **--xlate-format**.

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/format-conflict.png">
    </p>
</div>

Если вы хотите перевести весь текст, используйте опцию **--match-all**. Это сокращение для указания шаблона `(?s).+`, который соответствует всему тексту.

Формат данных маркера конфликта можно просмотреть в стиле "рядом" с помощью команды `sdif` с опцией `-V`. Поскольку сравнивать строки по отдельности не имеет смысла, рекомендуется использовать опцию `--no-cdif`. Если вам не нужно раскрашивать текст, укажите `--no-textcolor` (или `--no-tc`).

    sdif -V --no-tc --no-cdif data_shishin.deepl-EN-US.cm

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/sdif-cm-view.png">
    </p>
</div>

# NORMALIZATION

Обработка выполняется в указанных единицах, но в случае последовательности нескольких строк непустого текста они объединяются вместе в одну строку. Эта операция выполняется следующим образом:

- Удалить пробелы в начале и в конце каждой строки.
- Если строка заканчивается полноширинным символом, а следующая строка начинается с полноширинного символа, объединить строки.
- Если конец или начало строки не является полноширинным символом, объединить их, вставив пробел.

Данные кэша управляются на основе нормализованного текста, поэтому даже если вносятся изменения, не влияющие на результаты нормализации, кэшированные данные перевода останутся действительными.

Этот процесс нормализации выполняется только для первого (0-го) и четных шаблонов. Таким образом, если два шаблона указаны следующим образом, текст, соответствующий первому шаблону, будет обработан после нормализации, и никакой процесс нормализации не будет выполнен для текста, соответствующего второму шаблону.

    greple -Mxlate -E normalized -E not-normalized

Следовательно, используйте первый шаблон для текста, который должен быть обработан путем объединения нескольких строк в одну строку, и используйте второй шаблон для предварительно отформатированного текста. Если в первом шаблоне нет текста для сопоставления, то используйте шаблон, который ничего не сопоставляет, например, `(?!)`.

# MASKING

Иногда бывают части текста, которые вы не хотите переводить. Например, теги в файлах разметки. DeepL предлагает, что в таких случаях часть текста, которую нужно исключить, должна быть преобразована в XML-теги, переведена, а затем восстановлена после завершения перевода. Для поддержки этого можно указать части, которые нужно скрыть от перевода.

    --xlate-setopt maskfile=MASKPATTERN

Это будет интерпретировать каждую строку файла \`MASKPATTERN\` как регулярное выражение, переводить строки, соответствующие ему, и возвращать после обработки. Строки, начинающиеся с `#`, игнорируются.

Этот интерфейс является экспериментальным и может быть изменен в будущем.

# OPTIONS

- **--xlate**
- **--xlate-color**
- **--xlate-fold**
- **--xlate-fold-width**=_n_ (Default: 70)

    Вызывайте процесс перевода для каждой совпавшей области.

    Без этой опции **greple** ведет себя как обычная команда поиска. Таким образом, вы можете проверить, какая часть файла будет подвергаться переводу, прежде чем вызывать фактическую работу.

    Результат команды выводится в стандартный вывод, поэтому, при необходимости, перенаправьте его в файл или рассмотрите использование модуля [App::Greple::update](https://metacpan.org/pod/App%3A%3AGreple%3A%3Aupdate).

    Опция **--xlate** вызывает опцию **--xlate-color** с опцией **--color=never**.

    С опцией **--xlate-fold** преобразованный текст складывается с указанной шириной. Ширина по умолчанию - 70 и может быть установлена с помощью опции **--xlate-fold-width**. Четыре столбца зарезервированы для операции run-in, поэтому каждая строка может содержать не более 74 символов.

- **--xlate-engine**=_engine_

    Указывает используемый движок перевода. Если вы указываете модуль движка напрямую, например, `-Mxlate::deepl`, вам не нужно использовать эту опцию.

- **--xlate-labor**
- **--xlabor**

    Вместо вызова движка перевода, от вас ожидается выполнение работы. После подготовки текста для перевода, он копируется в буфер обмена. Ожидается, что вы вставите его в форму, скопируете результат в буфер обмена и нажмете Enter.

- **--xlate-to** (Default: `EN-US`)

    Укажите целевой язык. Вы можете получить доступные языки с помощью команды `deepl languages`, когда используется движок **DeepL**.

- **--xlate-format**=_format_ (Default: `conflict`)

    Укажите формат вывода для оригинального и переведенного текста.

    Следующие форматы, отличные от `xtxt`, предполагают, что часть, которую нужно перевести, представляет собой набор строк. Фактически, можно перевести только часть строки, и указание формата, отличного от `xtxt`, не приведет к осмысленным результатам.

    - **conflict**, **cm**

        Оригинальный и преобразованный тексты печатаются в формате маркера конфликта [git(1)](http://man.he.net/man1/git).

            <<<<<<< ORIGINAL
            original text
            =======
            translated Japanese text
            >>>>>>> JA

        Вы можете восстановить исходный файл с помощью следующей команды [sed(1)](http://man.he.net/man1/sed).

            sed -e '/^<<<<<<< /d' -e '/^=======$/,/^>>>>>>> /d'

    - **ifdef**

        Оригинальный и преобразованный тексты печатаются в формате [cpp(1)](http://man.he.net/man1/cpp) `#ifdef`.

            #ifdef ORIGINAL
            original text
            #endif
            #ifdef JA
            translated Japanese text
            #endif

        Вы можете получить только японский текст с помощью команды **unifdef**:

            unifdef -UORIGINAL -DJA foo.ja.pm

    - **space**

        Оригинальный и преобразованный тексты печатаются, разделенные одной пустой строкой.

    - **xtxt**

        Если формат - `xtxt` (переведенный текст) или неизвестный, будет выведен только переведенный текст.

- **--xlate-maxlen**=_chars_ (Default: 0)

    Переведите следующий текст на русский язык, построчно.

- **--xlate-maxline**=_n_ (Default: 0)

    Укажите максимальное количество строк текста, отправляемых в API за один раз.

    Установите это значение равным 1, если хотите переводить по одной строке за раз. Этот параметр имеет приоритет над опцией `--xlate-maxlen`.

- **--**\[**no-**\]**xlate-progress** (Default: True)

    Смотрите результат перевода в реальном времени в выводе STDERR.

- **--match-all**

    Установите весь текст файла в качестве целевой области.

# CACHE OPTIONS

Модуль **xlate** может хранить кэшированный текст перевода для каждого файла и считывать его перед выполнением, чтобы устранить накладные расходы на запросы к серверу. Стратегия кэширования по умолчанию `auto` поддерживает кэширование данных только при наличии файла кэша для целевого файла.

- --cache-clear

    Опцию **--cache-clear** можно использовать для инициирования управления кэшем или обновления всех существующих данных кэша. После выполнения с этой опцией будет создан новый файл кэша, если он не существует, и затем автоматически поддерживаться.

- --xlate-cache=_strategy_
    - `auto` (Default)

        Поддерживайте файл кэша, если он существует.

    - `create`

        Создайте пустой файл кэша и выйдите.

    - `always`, `yes`, `1`

        Поддерживайте кэш в любом случае, если цель - обычный файл.

    - `clear`

        Сначала очистите данные кэша.

    - `never`, `no`, `0`

        Никогда не используйте файл кэша, даже если он существует.

    - `accumulate`

        По умолчанию неиспользуемые данные удаляются из файла кэша. Если вы не хотите удалять их и хранить в файле, используйте `accumulate`.

# COMMAND LINE INTERFACE

Вы можете легко использовать этот модуль из командной строки, используя команду `xlate`, включенную в дистрибутив. См. справочную информацию по команде `xlate` для использования.

Команда `xlate` работает вместе с средой Docker, поэтому вы можете использовать ее, даже если у вас ничего не установлено на руках, при условии наличия Docker. Используйте опцию `-D` или `-C`.

Также, поскольку предоставляются make-файлы для различных стилей документов, перевод на другие языки возможен без особых указаний. Используйте опцию `-M`.

Вы также можете комбинировать опции Docker и make, чтобы запустить make в среде Docker.

Запуск, например, как `xlate -GC`, запустит оболочку с текущим рабочим репозиторием git.

Прочтите японскую статью в разделе "СМОТРИТЕ ТАКЖЕ" для получения подробной информации.

    xlate [ options ] -t lang file [ greple options ]
        -h   help
        -v   show version
        -d   debug
        -n   dry-run
        -a   use API
        -c   just check translation area
        -r   refresh cache
        -s   silent mode
        -e # translation engine (default "deepl")
        -p # pattern to determine translation area
        -w # wrap line by # width
        -o # output format (default "xtxt", or "cm", "ifdef")
        -f # from lang (ignored)
        -t # to lang (required, no default)
        -m # max length per API call
        -l # show library files (XLATE.mk, xlate.el)
        --   terminate option parsing
    Make options
        -M   run make
        -n   dry-run
    Docker options
        -G   mount git top-level directory
        -B   run in non-interactive (batch) mode
        -R   mount read-only
        -E * specify environment variable to be inherited
        -I * specify altanative docker image (default: tecolicom/xlate:version)
        -D * run xlate on the container with the rest parameters
        -C * run following command on the container, or run shell

    Control Files:
        *.LANG    translation languates
        *.FORMAT  translation foramt (xtxt, cm, ifdef)
        *.ENGINE  translation engine (deepl or gpt3)

# EMACS

Загрузите файл `xlate.el`, включенный в репозиторий, чтобы использовать команду `xlate` из редактора Emacs. Функция `xlate-region` переводит указанную область. Язык по умолчанию - `EN-US`, и вы можете указать язык, вызывая его с аргументом-префиксом.

# ENVIRONMENT

- DEEPL\_AUTH\_KEY

    Установите ваш ключ аутентификации для сервиса DeepL.

- OPENAI\_API\_KEY

    Ключ аутентификации OpenAI.

# INSTALL

## CPANMINUS

    $ cpanm App::Greple::xlate

## TOOLS

Необходимо установить командные инструменты для DeepL и ChatGPT.

[https://github.com/DeepLcom/deepl-python](https://github.com/DeepLcom/deepl-python)

[https://github.com/tecolicom/App-gpty](https://github.com/tecolicom/App-gpty)

# SEE ALSO

[App::Greple::xlate](https://metacpan.org/pod/App%3A%3AGreple%3A%3Axlate)

[App::Greple::xlate::deepl](https://metacpan.org/pod/App%3A%3AGreple%3A%3Axlate%3A%3Adeepl)

[App::Greple::xlate::gpt3](https://metacpan.org/pod/App%3A%3AGreple%3A%3Axlate%3A%3Agpt3)

[https://hub.docker.com/r/tecolicom/xlate](https://hub.docker.com/r/tecolicom/xlate)

- [https://github.com/DeepLcom/deepl-python](https://github.com/DeepLcom/deepl-python)

    Библиотека DeepL для Python и командная строка.

- [https://github.com/openai/openai-python](https://github.com/openai/openai-python)

    Библиотека OpenAI для Python

- [https://github.com/tecolicom/App-gpty](https://github.com/tecolicom/App-gpty)

    Командный интерфейс OpenAI

- [App::Greple](https://metacpan.org/pod/App%3A%3AGreple)

    См. руководство по **greple** для получения подробной информации о шаблоне целевого текста. Используйте опции **--inside**, **--outside**, **--include**, **--exclude**, чтобы ограничить область совпадения.

- [App::Greple::update](https://metacpan.org/pod/App%3A%3AGreple%3A%3Aupdate)

    Вы можете использовать модуль `-Mupdate`, чтобы изменять файлы на основе результата команды **greple**.

- [App::sdif](https://metacpan.org/pod/App%3A%3Asdif)

    Используйте **sdif**, чтобы показать формат маркера конфликта рядом с опцией **-V**.

## ARTICLES

- [https://qiita.com/kaz-utashiro/items/1c1a51a4591922e18250](https://qiita.com/kaz-utashiro/items/1c1a51a4591922e18250)

    Модуль Greple для перевода и замены только необходимых частей с использованием API DeepL (на японском)

- [https://qiita.com/kaz-utashiro/items/a5e19736416ca183ecf6](https://qiita.com/kaz-utashiro/items/a5e19736416ca183ecf6)

    Генерация документов на 15 языках с помощью модуля DeepL API (на японском)

- [https://qiita.com/kaz-utashiro/items/1b9e155d6ae0620ab4dd](https://qiita.com/kaz-utashiro/items/1b9e155d6ae0620ab4dd)

    Автоматическая среда Docker для перевода с использованием API DeepL (на японском)

# AUTHOR

Kazumasa Utashiro

# LICENSE

Copyright © 2023-2024 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
