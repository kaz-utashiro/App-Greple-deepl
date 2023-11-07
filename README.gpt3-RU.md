# NAME

App::Greple::xlate - модуль поддержки перевода для greple

# SYNOPSIS

    greple -Mxlate -e ENGINE --xlate pattern target-file

    greple -Mxlate::deepl --xlate pattern target-file

# VERSION

Version 0.26

# DESCRIPTION

**Greple** Модуль **xlate** находит текстовые блоки и заменяет их переведенным текстом. Включает модуль DeepL (`deepl.pm`) и модуль ChatGPT (`gpt3.pm`) для использования в качестве движка.

Если вы хотите перевести обычный текстовый блок в документе в стиле [pod](https://metacpan.org/pod/pod), используйте команду **greple** с модулем `xlate::deepl` и модулем `perl` следующим образом:

    greple -Mxlate::deepl -Mperl --pod --re '^(\w.*\n)+' --all foo.pm

Шаблон `^(\w.*\n)+` означает последовательные строки, начинающиеся с буквы или цифры. Эта команда показывает область, которую нужно перевести. Опция **--all** используется для вывода всего текста.

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/select-area.png">
    </p>
</div>

Затем добавьте опцию `--xlate`, чтобы перевести выбранную область. Она найдет и заменит их выводом команды **deepl**.

По умолчанию оригинальный и переведенный текст выводится в формате "конфликтного маркера", совместимого с [git(1)](http://man.he.net/man1/git). Используя формат `ifdef`, вы можете получить нужную часть с помощью команды [unifdef(1)](http://man.he.net/man1/unifdef). Формат можно указать с помощью опции **--xlate-format**.

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/format-conflict.png">
    </p>
</div>

Если вы хотите перевести весь текст, используйте опцию **--match-all**. Это сокращение для указания шаблона, который соответствует всему тексту `(?s).+`.

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

    Вместо вызова движка перевода ожидается, что вы будете работать с ним. После подготовки текста для перевода, они копируются в буфер обмена. Ожидается, что вы вставите их в форму, скопируете результат в буфер обмена и нажмете Enter.

- **--xlate-to** (Default: `EN-US`)

    Укажите целевой язык. Вы можете получить доступные языки с помощью команды `deepl languages`, когда используется движок **DeepL**.

- **--xlate-format**=_format_ (Default: `conflict`)

    Укажите формат вывода для оригинального и переведенного текста.

    - **conflict**, **cm**

        Вывести оригинальный и переведенный текст в формате конфликтного маркера [git(1)](http://man.he.net/man1/git).

            <<<<<<< ORIGINAL
            original text
            =======
            translated Japanese text
            >>>>>>> JA

        Вы можете восстановить исходный файл с помощью следующей команды [sed(1)](http://man.he.net/man1/sed).

            sed -e '/^<<<<<<< /d' -e '/^=======$/,/^>>>>>>> /d'

    - **ifdef**

        Вывести оригинальный и переведенный текст в формате [cpp(1)](http://man.he.net/man1/cpp) `#ifdef`.

            #ifdef ORIGINAL
            original text
            #endif
            #ifdef JA
            translated Japanese text
            #endif

        Вы можете получить только японский текст с помощью команды **unifdef**:

            unifdef -UORIGINAL -DJA foo.ja.pm

    - **space**

        Вывести оригинальный и переведенный текст, разделенные одной пустой строкой.

    - **xtxt**

        Если формат - `xtxt` (переведенный текст) или неизвестный, будет выведен только переведенный текст.

- **--xlate-maxlen**=_chars_ (Default: 0)

    Укажите максимальную длину текста, отправляемого в API за один раз. Значение по умолчанию установлено для бесплатного аккаунта: 128K для API (**--xlate**) и 5000 для интерфейса буфера обмена (**--xlate-labor**). Возможно, вы сможете изменить эти значения, если используете платный сервис.

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

Вы можете легко использовать этот модуль из командной строки, используя команду `xlate`, включенную в репозиторий. См. справочную информацию `xlate` для использования.

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

# AUTHOR

Kazumasa Utashiro

# LICENSE

Copyright © 2023 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
