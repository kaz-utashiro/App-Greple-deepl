=encoding utf-8

=head1 NAME

App::Greple::xlate - Greple tõlkimise tugimoodul

=head1 SYNOPSIS

    greple -Mxlate::deepl --xlate pattern target-file

=head1 VERSION

Version 0.25

=head1 DESCRIPTION

B<Greple> B<xlate> moodul leiab tekstiplokid ja asendab need tõlgitud tekstiga. Praegu toetab B<xlate::deepl> moodul ainult DeepL teenust.

Kui soovite L<pod> stiilis dokumendis tavalist tekstiplokki tõlkida, kasutage B<greple> käsku koos C<xlate::deepl> ja C<perl> mooduliga niimoodi:

    greple -Mxlate::deepl -Mperl --pod --re '^(\w.*\n)+' --all foo.pm

Muster C<^(\w.*\n)+> tähendab järjestikuseid ridu, mis algavad tähtnumbrilise tähega. See käsk näitab tõlgitavat ala. Valikut B<--all> kasutatakse kogu teksti koostamiseks.

=for html <p>
<img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/select-area.png">
</p>

Seejärel lisage valik C<--xlate>, et tõlkida valitud ala. See leiab ja asendab need käsu B<deepl> väljundiga.

Vaikimisi trükitakse originaal- ja tõlgitud tekst "konfliktimärkide" formaadis, mis on ühilduv L<git(1)>. Kasutades C<ifdef> formaati, saate soovitud osa hõlpsasti kätte käsuga L<unifdef(1)>. Formaat saab määrata B<--xlate-format> valikuga.

=for html <p>
<img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/format-conflict.png">
</p>

Kui soovite tõlkida kogu teksti, kasutage valikut B<--match-all>. See on otsetee, et määrata muster vastab kogu tekstile C<(?s).+>.

=head1 OPTIONS

=over 7

=item B<--xlate>

=item B<--xlate-color>

=item B<--xlate-fold>

=item B<--xlate-fold-width>=I<n> (Default: 70)

Käivitage tõlkimisprotsess iga sobitatud ala jaoks.

Ilma selle valikuta käitub B<greple> nagu tavaline otsingukäsklus. Seega saate enne tegeliku töö käivitamist kontrollida, millise faili osa kohta tehakse tõlge.

Käsu tulemus läheb standardväljundisse, nii et vajadusel suunake see faili ümber või kaaluge mooduli L<App::Greple::update> kasutamist.

Valik B<--xlate> kutsub B<--xlate-color> valiku B<--color=never> valikul.

Valikuga B<--xlate-fold> volditakse konverteeritud tekst määratud laiusega. Vaikimisi laius on 70 ja seda saab määrata valikuga B<--xlate-fold-width>. Neli veergu on reserveeritud sisselülitamiseks, nii et iga rida võib sisaldada maksimaalselt 74 märki.

=item B<--xlate-engine>=I<engine>

Määrake kasutatav tõlkemootor. Seda valikut ei pea kasutama, sest moodul C<xlate::deepl> deklareerib seda kui C<--xlate-engine=deepl>.

=item B<--xlate-labor>

=item B<--xlabor>

Insted kutsudes tõlkemootor, siis oodatakse tööd. Pärast tõlgitava teksti ettevalmistamist kopeeritakse need lõikelauale. Eeldatakse, et kleebite need vormi, kopeerite tulemuse lõikelauale ja vajutate return.

=item B<--xlate-to> (Default: C<EN-US>)

Määrake sihtkeel. B<DeepL> mootori kasutamisel saate saadaval olevad keeled kätte käsuga C<deepl languages>.

=item B<--xlate-format>=I<format> (Default: C<conflict>)

Määrake originaal- ja tõlgitud teksti väljundformaat.

=over 4

=item B<conflict>, B<cm>

Trükib originaal- ja tõlgitud teksti L<git(1)> konfliktimärgistuse formaadis.

    <<<<<<< ORIGINAL
    original text
    =======
    translated Japanese text
    >>>>>>> JA

Originaalfaili saate taastada järgmise käsuga L<sed(1)>.

    sed -e '/^<<<<<<< /d' -e '/^=======$/,/^>>>>>>> /d'

=item B<ifdef>

Prindi originaal- ja tõlgitud tekst L<cpp(1)> C<#ifdef>-vormingus.

    #ifdef ORIGINAL
    original text
    #endif
    #ifdef JA
    translated Japanese text
    #endif

Saate ainult jaapani teksti taastada käsuga B<unifdef>:

    unifdef -UORIGINAL -DJA foo.ja.pm

=item B<space>

Prindi originaal- ja tõlgitud tekst ühe tühja reaga eraldatud.

=item B<xtxt>

Kui formaat on C<xtxt> (tõlgitud tekst) või tundmatu, trükitakse ainult tõlgitud tekst.

=back

=item B<--xlate-maxlen>=I<chars> (Default: 0)

Määrake API-le korraga saadetava teksti maksimaalne pikkus. Vaikeväärtus on määratud nagu tasuta kontoteenuse puhul: 128K API jaoks (B<--xlate>) ja 5000 lõikelaua liidesele (B<--xlate-labor>). Kui kasutate Pro teenust, võite neid väärtusi muuta.

=item B<-->[B<no->]B<xlate-progress> (Default: True)

Näete tõlkimise tulemust reaalajas STDERR-väljundist.

=item B<--match-all>

Määrake kogu faili tekst sihtkohaks.

=back

=head1 CACHE OPTIONS

B<xlate> moodul võib salvestada iga faili tõlketeksti vahemällu ja lugeda seda enne täitmist, et kõrvaldada serveri küsimisega kaasnev koormus. Vaikimisi vahemälustrateegia C<auto> puhul säilitab ta vahemälu andmeid ainult siis, kui vahemälufail on sihtfaili jaoks olemas.

=over 7

=item --cache-clear

Valikut B<--cache-clear> saab kasutada vahemälu haldamise alustamiseks või kõigi olemasolevate vahemälu andmete värskendamiseks. Selle valikuga käivitamisel luuakse uus vahemälufail, kui seda ei ole veel olemas, ja seejärel hooldatakse seda automaatselt.

=item --xlate-cache=I<strategy>

=over 4

=item C<auto> (Default)

Säilitada vahemälufaili, kui see on olemas.

=item C<create>

Loob tühja vahemälufaili ja väljub.

=item C<always>, C<yes>, C<1>

Säilitab vahemälu andmed niikuinii, kui sihtfail on tavaline fail.

=item C<clear>

Tühjendage esmalt vahemälu andmed.

=item C<never>, C<no>, C<0>

Ei kasuta kunagi vahemälufaili, isegi kui see on olemas.

=item C<accumulate>

Vaikimisi käitumise kohaselt eemaldatakse kasutamata andmed vahemälufailist. Kui te ei soovi neid eemaldada ja failis hoida, kasutage C<accumulate>.

=back

=back

=head1 COMMAND LINE INTERFACE

Seda moodulit saab hõlpsasti kasutada käsurealt, kasutades repositooriumis sisalduvat käsku C<xlate>. Kasutamise kohta vaata C<xlate> abiinfot.

=head1 EMACS

Laadige repositooriumis sisalduv fail F<xlate.el>, et kasutada C<xlate> käsku Emacs redaktorist. C<xlate-region> funktsioon tõlkida antud piirkonda. Vaikimisi keel on C<EN-US> ja te võite määrata keele, kutsudes seda prefix-argumendiga.

=head1 ENVIRONMENT

=over 7

=item DEEPL_AUTH_KEY

Määrake oma autentimisvõti DeepL teenuse jaoks.

=back

=head1 INSTALL

=head2 CPANMINUS

    $ cpanm App::Greple::xlate

=head1 SEE ALSO

L<App::Greple::xlate>

=over 7

=item L<https://github.com/DeepLcom/deepl-python>

DeepL Pythoni raamatukogu ja CLI käsk.

=item L<App::Greple>

Vt B<greple> käsiraamatust üksikasjalikult sihttekstimustri kohta. Kasutage B<--inside>, B<--outside>, B<--include>, B<--exclude> valikuid, et piirata sobitusala.

=item L<App::Greple::update>

Saate kasutada C<-Mupdate> moodulit, et muuta faile B<greple> käsu tulemuse järgi.

=item L<App::sdif>

Kasutage B<sdif>, et näidata konfliktimärkide formaati kõrvuti valikuga B<-V>.

=back

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright © 2023 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
