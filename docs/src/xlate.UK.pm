=encoding utf-8

=head1 NAME

App::Greple::xlate - модуль підтримки перекладу для greple

=head1 SYNOPSIS

    greple -Mxlate::deepl --xlate pattern target-file

=head1 VERSION

Version 0.25

=head1 DESCRIPTION

Модуль B<Greple> B<xlate> знаходить текстові блоки і замінює їх перекладеним текстом. Наразі модулем B<xlate::deepl> підтримується лише сервіс DeepL.

Якщо ви хочете перекласти звичайний текстовий блок у документі в стилі L<pod>, використовуйте команду B<greple> з модулем C<xlate::deepl> і C<perl> таким чином:

    greple -Mxlate::deepl -Mperl --pod --re '^(\w.*\n)+' --all foo.pm

Шаблон C<^(\w.*\n)+> означає послідовні рядки, що починаються з буквено-цифрової літери. Ця команда показує область, яку потрібно перекласти. Параметр B<--all> використовується для перекладу всього тексту.

=for html <p>
<img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/select-area.png">
</p>

Потім додайте опцію C<--xlate> для перекладу виділеної області. Вона знайде і замінить їх на виведені командою B<deepl>.

За замовчуванням оригінальний і перекладений текст виводиться у форматі "конфліктний маркер", сумісному з L<git(1)>. Використовуючи формат C<ifdef>, ви можете легко отримати потрібну частину командою L<unifdef(1)>. Формат можна вказати за допомогою опції B<--xlate-format>.

=for html <p>
<img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/format-conflict.png">
</p>

Якщо ви хочете перекласти весь текст, використовуйте опцію B<--match-all>. Це швидкий спосіб вказати, що шаблон збігається з усім текстом C<(?s).+>.

=head1 OPTIONS

=over 7

=item B<--xlate>

=item B<--xlate-color>

=item B<--xlate-fold>

=item B<--xlate-fold-width>=I<n> (Default: 70)

Виклик процесу перекладу для кожної знайденої області.

Без цього параметра B<greple> поводиться як звичайна команда пошуку. Таким чином, ви можете перевірити, яку частину файлу буде перекладено, перш ніж викликати процес перекладу.

Результат команди буде виведено у стандартний вивід, тому за потреби переспрямуйте його на файл або скористайтеся модулем L<App::Greple::update>.

Опція B<--xlate> викликає опцію B<--xlate-color> з опцією B<--color=never>.

За допомогою опції B<--xlate-fold> перетворений текст буде згорнуто за вказаною шириною. За замовчуванням ширина складає 70 і може бути встановлена за допомогою параметра B<--xlate-fold-width>. Чотири стовпчики зарезервовано для обкатки, тому кожен рядок може містити не більше 74 символів.

=item B<--xlate-engine>=I<engine>

Вкажіть рушій перекладу, який буде використано. Вам не потрібно використовувати цей параметр, оскільки модуль C<xlate::deepl> оголошує його як C<--xlate-engine=deepl>.

=item B<--xlate-labor>

=item B<--xlabor>

Замість того, щоб викликати рушій перекладу, ви маєте працювати з ним. Після підготовки тексту для перекладу він копіюється в буфер обміну. Ви маєте вставити його у форму, скопіювати результат у буфер обміну і натиснути клавішу return.

=item B<--xlate-to> (Default: C<EN-US>)

Вкажіть цільову мову. Доступні мови можна отримати за допомогою команди C<deepl languages> у разі використання рушія B<DeepL>.

=item B<--xlate-format>=I<format> (Default: C<conflict>)

Вкажіть формат виведення оригінального та перекладеного тексту.

=over 4

=item B<conflict>, B<cm>

Вивести оригінальний і перекладений текст у форматі конфліктних маркерів L<git(1)>.

    <<<<<<< ORIGINAL
    original text
    =======
    translated Japanese text
    >>>>>>> JA

Відновити вихідний файл можна наступною командою L<sed(1)>.

    sed -e '/^<<<<<<< /d' -e '/^=======$/,/^>>>>>>> /d'

=item B<ifdef>

Вивести оригінальний та перекладений текст у форматі L<cpp(1)> C<#ifdef>.

    #ifdef ORIGINAL
    original text
    #endif
    #ifdef JA
    translated Japanese text
    #endif

За допомогою команди B<unifdef> можна отримати лише японський текст:

    unifdef -UORIGINAL -DJA foo.ja.pm

=item B<space>

Вивести текст оригіналу та перекладу, розділені одним порожнім рядком.

=item B<xtxt>

Якщо формат C<xtxt> (перекладений текст) або невідомий, друкується лише перекладений текст.

=back

=item B<--xlate-maxlen>=I<chars> (Default: 0)

Вкажіть максимальну довжину тексту, що надсилається до API за один раз. Значення за замовчуванням встановлено як для безкоштовного сервісу: 128K для API (B<--xlate>) і 5000 для інтерфейсу буфера обміну (B<--xlate-labor>). Ви можете змінити ці значення, якщо ви використовуєте Pro сервіс.

=item B<-->[B<no->]B<xlate-progress> (Default: True)

Результат перекладу у реальному часі можна побачити у виводі STDERR.

=item B<--match-all>

Встановити весь текст файлу як цільову область.

=back

=head1 CACHE OPTIONS

Модуль B<xlate> може зберігати кешований текст перекладу для кожного файлу і зчитувати його перед виконанням, щоб усунути накладні витрати на запити до сервера. За замовчуванням стратегія кешування C<auto> зберігає кешовані дані лише тоді, коли для цільового файлу існує файл кешу.

=over 7

=item --cache-clear

Параметр B<--cache-clear> може бути використано для ініціювання керування кешем або для оновлення усіх наявних даних кешу. Після виконання цього параметра буде створено новий файл кешу, якщо його не існує, а потім автоматично підтримуватиметься.

=item --xlate-cache=I<strategy>

=over 4

=item C<auto> (Default)

Обслуговувати файл кешу, якщо він існує.

=item C<create>

Створити порожній файл кешу і вийти.

=item C<always>, C<yes>, C<1>

Зберігати кеш у будь-якому випадку, якщо цільовий файл є нормальним.

=item C<clear>

Спочатку очистити дані кешу.

=item C<never>, C<no>, C<0>

Ніколи не використовувати файл кешу, навіть якщо він існує.

=item C<accumulate>

За замовчуванням, невикористані дані буде видалено з файлу кешу. Якщо ви не хочете видаляти їх і зберігати у файлі, скористайтеся командою C<accumulate>.

=back

=back

=head1 COMMAND LINE INTERFACE

Ви можете легко використовувати цей модуль з командного рядка за допомогою команди C<xlate>, що входить до складу репозиторію. Див. довідкову інформацію щодо використання C<xlate>.

=head1 EMACS

Для використання команди C<xlate> з редактора Emacs завантажте файл F<xlate.el>, що входить до складу репозиторію. Функція C<xlate-region> перекладає заданий регіон. За замовчуванням використовується мова C<EN-US>, але ви можете вказати мову виклику за допомогою аргументу префікса.

=head1 ENVIRONMENT

=over 7

=item DEEPL_AUTH_KEY

Встановіть свій ключ автентифікації для сервісу DeepL.

=back

=head1 INSTALL

=head2 CPANMINUS

    $ cpanm App::Greple::xlate

=head1 SEE ALSO

L<App::Greple::xlate>

=over 7

=item L<https://github.com/DeepLcom/deepl-python>

DeepL Бібліотека Python і команда CLI.

=item L<App::Greple>

Детальніше про шаблон цільового тексту див. у посібнику B<greple>. Використовуйте опції B<--inside>, B<--outside>, B<--include>, B<--exclude> для обмеження області пошуку.

=item L<App::Greple::update>

Ви можете скористатися модулем C<-Mupdate> для модифікації файлів за результатами виконання команди B<greple>.

=item L<App::sdif>

Використовуйте B<sdif> для відображення формату конфліктних маркерів поряд з опцією B<-V>.

=back

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright © 2023 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
