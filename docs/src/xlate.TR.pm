=encoding utf-8

=head1 NAME

App::Greple::xlate - greple için çeviri destek modülü

=head1 SYNOPSIS

    greple -Mxlate::deepl --xlate pattern target-file

=head1 VERSION

Version 0.25

=head1 DESCRIPTION

B<Greple> B<xlate> modülü metin bloklarını bulur ve bunları çevrilmiş metinle değiştirir. Şu anda sadece DeepL servisi B<xlate::deepl> modülü tarafından desteklenmektedir.

L<pod> stili belgede normal metin bloğunu çevirmek istiyorsanız, B<greple> komutunu C<xlate::deepl> ve C<perl> modülü ile aşağıdaki gibi kullanın:

    greple -Mxlate::deepl -Mperl --pod --re '^(\w.*\n)+' --all foo.pm

C<^(\w.*\n)+> kalıbı alfa-nümerik harfle başlayan ardışık satırlar anlamına gelir. Bu komut çevrilecek alanı gösterir. B<--all> seçeneği tüm metni üretmek için kullanılır.

=for html <p>
<img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/select-area.png">
</p>

Daha sonra seçilen alanı çevirmek için C<--xlate> seçeneğini ekleyin. B<deepl> komut çıktısı ile bunları bulacak ve değiştirecektir.

Varsayılan olarak, orijinal ve çevrilmiş metin L<git(1)> ile uyumlu "conflict marker" formatında yazdırılır. C<ifdef> formatını kullanarak, L<unifdef(1)> komutu ile istediğiniz kısmı kolayca elde edebilirsiniz. Biçim B<--xlate-format> seçeneği ile belirtilebilir.

=for html <p>
<img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/format-conflict.png">
</p>

Metnin tamamını çevirmek istiyorsanız, B<--match-all> seçeneğini kullanın. Bu, kalıbın tüm metinle eşleştiğini belirtmek için kısa yoldur C<(?s).+>.

=head1 OPTIONS

=over 7

=item B<--xlate>

=item B<--xlate-color>

=item B<--xlate-fold>

=item B<--xlate-fold-width>=I<n> (Default: 70)

Eşleşen her alan için çeviri işlemini çağırın.

Bu seçenek olmadan, B<greple> normal bir arama komutu gibi davranır. Böylece, asıl işi çağırmadan önce dosyanın hangi bölümünün çeviriye tabi olacağını kontrol edebilirsiniz.

Komut sonucu standart çıkışa gider, bu nedenle gerekirse dosyaya yönlendirin veya L<App::Greple::update> modülünü kullanmayı düşünün.

B<--xlate> seçeneği B<--color=never> seçeneği ile B<--xlate-color> seçeneğini çağırır.

B<--xlate-fold> seçeneği ile, dönüştürülen metin belirtilen genişlikte katlanır. Varsayılan genişlik 70'tir ve B<--xlate-fold-width> seçeneği ile ayarlanabilir. Çalıştırma işlemi için dört sütun ayrılmıştır, bu nedenle her satır en fazla 74 karakter alabilir.

=item B<--xlate-engine>=I<engine>

Kullanılacak çeviri motorunu belirtin. Bu seçeneği kullanmak zorunda değilsiniz çünkü C<xlate::deepl> modülü bunu C<--xlate-engine=deepl> olarak bildirir.

=item B<--xlate-labor>

=item B<--xlabor>

Çeviri motorunu çağırmak yerine, sizin çalışmanız beklenir. Çevrilecek metin hazırlandıktan sonra panoya kopyalanır. Bunları forma yapıştırmanız, sonucu panoya kopyalamanız ve return tuşuna basmanız beklenir.

=item B<--xlate-to> (Default: C<EN-US>)

Hedef dili belirtin. B<DeepL> motorunu kullanırken C<deepl languages> komutu ile mevcut dilleri alabilirsiniz.

=item B<--xlate-format>=I<format> (Default: C<conflict>)

Orijinal ve çevrilmiş metin için çıktı formatını belirtin.

=over 4

=item B<conflict>, B<cm>

Orijinal ve çevrilmiş metni L<git(1)> çakışma işaretleyici biçiminde yazdırın.

    <<<<<<< ORIGINAL
    original text
    =======
    translated Japanese text
    >>>>>>> JA

Bir sonraki L<sed(1)> komutu ile orijinal dosyayı kurtarabilirsiniz.

    sed -e '/^<<<<<<< /d' -e '/^=======$/,/^>>>>>>> /d'

=item B<ifdef>

Orijinal ve çevrilmiş metni L<cpp(1)> C<#ifdef> biçiminde yazdırın.

    #ifdef ORIGINAL
    original text
    #endif
    #ifdef JA
    translated Japanese text
    #endif

B<unifdef> komutu ile sadece Japonca metni alabilirsiniz:

    unifdef -UORIGINAL -DJA foo.ja.pm

=item B<space>

Orijinal ve çevrilmiş metni tek bir boş satırla ayırarak yazdırın.

=item B<xtxt>

Biçim C<xtxt> (çevrilmiş metin) veya bilinmiyorsa, yalnızca çevrilmiş metin yazdırılır.

=back

=item B<--xlate-maxlen>=I<chars> (Default: 0)

API'ye bir kerede gönderilecek maksimum metin uzunluğunu belirtin. Varsayılan değer ücretsiz hesap hizmeti için ayarlanmıştır: API için 128K (B<--xlate>) ve pano arayüzü için 5000 (B<--xlate-labor>). Pro hizmeti kullanıyorsanız bu değerleri değiştirebilirsiniz.

=item B<-->[B<no->]B<xlate-progress> (Default: True)

Çeviri sonucunu STDERR çıktısında gerçek zamanlı olarak görün.

=item B<--match-all>

Dosyanın tüm metnini hedef alan olarak ayarlayın.

=back

=head1 CACHE OPTIONS

B<xlate> modülü her dosya için önbellekte çeviri metnini saklayabilir ve sunucuya sorma ek yükünü ortadan kaldırmak için yürütmeden önce okuyabilir. Varsayılan önbellek stratejisi C<auto> ile, önbellek verilerini yalnızca hedef dosya için önbellek dosyası mevcut olduğunda tutar.

=over 7

=item --cache-clear

B<--cache-clear> seçeneği önbellek yönetimini başlatmak veya mevcut tüm önbellek verilerini yenilemek için kullanılabilir. Bu seçenekle çalıştırıldığında, mevcut değilse yeni bir önbellek dosyası oluşturulacak ve daha sonra otomatik olarak korunacaktır.

=item --xlate-cache=I<strategy>

=over 4

=item C<auto> (Default)

Eğer varsa önbellek dosyasını koruyun.

=item C<create>

Boş önbellek dosyası oluştur ve çık.

=item C<always>, C<yes>, C<1>

Hedef normal dosya olduğu sürece önbelleği yine de korur.

=item C<clear>

Önce önbellek verilerini temizleyin.

=item C<never>, C<no>, C<0>

Var olsa bile önbellek dosyasını asla kullanmayın.

=item C<accumulate>

Varsayılan davranışa göre, kullanılmayan veriler önbellek dosyasından kaldırılır. Bunları kaldırmak ve dosyada tutmak istemiyorsanız, C<accumulate> kullanın.

=back

=back

=head1 COMMAND LINE INTERFACE

Bu modülü, depoda bulunan C<xlate> komutunu kullanarak komut satırından kolayca kullanabilirsiniz. Kullanım için C<xlate> yardım bilgisine bakın.

=head1 EMACS

Emacs editöründen C<xlate> komutunu kullanmak için depoda bulunan F<xlate.el> dosyasını yükleyin. C<xlate-region> fonksiyonu verilen bölgeyi çevirir. Varsayılan dil C<EN-US>'dir ve prefix argümanı ile çağırarak dili belirtebilirsiniz.

=head1 ENVIRONMENT

=over 7

=item DEEPL_AUTH_KEY

DeepL hizmeti için kimlik doğrulama anahtarınızı ayarlayın.

=back

=head1 INSTALL

=head2 CPANMINUS

    $ cpanm App::Greple::xlate

=head1 SEE ALSO

L<App::Greple::xlate>

=over 7

=item L<https://github.com/DeepLcom/deepl-python>

DeepL Python kütüphanesi ve CLI komutu.

=item L<App::Greple>

Hedef metin kalıbı hakkında ayrıntılı bilgi için B<greple> kılavuzuna bakın. Eşleşen alanı sınırlamak için B<--inside>, B<--outside>, B<--include>, B<--exclude> seçeneklerini kullanın.

=item L<App::Greple::update>

Dosyaları B<greple> komutunun sonucuna göre değiştirmek için C<-Mupdate> modülünü kullanabilirsiniz.

=item L<App::sdif>

B<-V> seçeneği ile çakışma işaretleyici formatını yan yana göstermek için B<sdif> kullanın.

=back

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright © 2023 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
