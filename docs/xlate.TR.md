# NAME

App::Greple::xlate - greple için çeviri destek modülü

# SYNOPSIS

    greple -Mxlate::deepl --xlate pattern target-file

# DESCRIPTION

**Greple** **xlate** modülü metin bloklarını bulur ve bunları çevrilmiş metinle değiştirir. Şu anda sadece DeepL servisi **xlate::deepl** modülü tarafından desteklenmektedir.

[pod](https://metacpan.org/pod/pod) stili belgede normal metin bloğunu çevirmek istiyorsanız, **greple** komutunu `xlate::deepl` ve `perl` modülü ile aşağıdaki gibi kullanın:

    greple -Mxlate::deepl -Mperl --pod --re '^(\w.*\n)+' --all foo.pm

`^(\w.*\n)+` kalıbı alfa-nümerik harfle başlayan ardışık satırlar anlamına gelir. Bu komut çevrilecek alanı gösterir. **--all** seçeneği tüm metni üretmek için kullanılır.

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/select-area.png">
    </p>
</div>

Daha sonra seçilen alanı çevirmek için `--xlate` seçeneğini ekleyin. **deepl** komut çıktısı ile bunları bulacak ve değiştirecektir.

Varsayılan olarak, orijinal ve çevrilmiş metin [git(1)](http://man.he.net/man1/git) ile uyumlu "conflict marker" formatında yazdırılır. `ifdef` formatını kullanarak, [unifdef(1)](http://man.he.net/man1/unifdef) komutu ile istediğiniz kısmı kolayca elde edebilirsiniz. Biçim **--xlate-format** seçeneği ile belirtilebilir.

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/format-conflict.png">
    </p>
</div>

Eğer metnin tamamını çevirmek istiyorsanız, **--match-entire** seçeneğini kullanın. Bu, `(?s).*` metninin tamamıyla eşleşen kalıbı belirtmek için bir kısa yoldur.

# OPTIONS

- **--xlate**
- **--xlate-color**
- **--xlate-fold**
- **--xlate-fold-width**=_n_ (Default: 70)

    Eşleşen her alan için çeviri işlemini çağırın.

    Bu seçenek olmadan, **greple** normal bir arama komutu gibi davranır. Böylece, asıl işi çağırmadan önce dosyanın hangi bölümünün çeviriye tabi olacağını kontrol edebilirsiniz.

    Komut sonucu standart çıkışa gider, bu nedenle gerekirse dosyaya yönlendirin veya [App::Greple::update](https://metacpan.org/pod/App%3A%3AGreple%3A%3Aupdate) modülünü kullanmayı düşünün.

    **--xlate** seçeneği **--color=never** seçeneği ile **--xlate-color** seçeneğini çağırır.

    **--xlate-fold** seçeneği ile, dönüştürülen metin belirtilen genişlikte katlanır. Varsayılan genişlik 70'tir ve **--xlate-fold-width** seçeneği ile ayarlanabilir. Çalıştırma işlemi için dört sütun ayrılmıştır, bu nedenle her satır en fazla 74 karakter alabilir.

- **--xlate-engine**=_engine_

    Kullanılacak çeviri motorunu belirtin. Bu seçeneği kullanmak zorunda değilsiniz çünkü `xlate::deepl` modülü bunu `--xlate-engine=deepl` olarak bildirir.

- **--xlate-to** (Default: `JA`)

    Hedef dili belirtin. **DeepL** motorunu kullanırken `deepl languages` komutu ile mevcut dilleri alabilirsiniz.

- **--xlate-format**=_format_ (Default: conflict)

    Orijinal ve çevrilmiş metin için çıktı formatını belirtin.

    - **conflict**

        Orijinal ve çevrilmiş metni [git(1)](http://man.he.net/man1/git) çakışma işaretleyici biçiminde yazdırın.

            <<<<<<< ORIGINAL
            original text
            =======
            translated Japanese text
            >>>>>>> JA

        Bir sonraki [sed(1)](http://man.he.net/man1/sed) komutu ile orijinal dosyayı kurtarabilirsiniz.

            sed -e '/^<<<<<<< /d' -e '/^=======$/,/^>>>>>>> /d'

    - **ifdef**

        Orijinal ve çevrilmiş metni [cpp(1)](http://man.he.net/man1/cpp) `#ifdef` biçiminde yazdırın.

            #ifdef ORIGINAL
            original text
            #endif
            #ifdef JA
            translated Japanese text
            #endif

        **unifdef** komutu ile sadece Japonca metni alabilirsiniz:

            unifdef -UORIGINAL -DJA foo.ja.pm

    - **space**

        Orijinal ve çevrilmiş metni tek bir boş satırla ayırarak yazdırın.

    - **none**

        Eğer format `none` veya unkown ise, sadece çevrilmiş metin yazdırılır.

- **--**\[**no-**\]**xlate-progress** (Default: True)

    Çeviri sonucunu STDERR çıktısında gerçek zamanlı olarak görün.

- **--match-entire**

    Dosyanın tüm metnini hedef alan olarak ayarlayın.

# CACHE OPTIONS

**xlate** modülü her dosya için önbelleğe alınmış çeviri metnini saklayabilir ve sunucuya sorma ek yükünü ortadan kaldırmak için yürütmeden önce okuyabilir. Varsayılan önbellek stratejisi `auto` ile, önbellek verilerini yalnızca hedef dosya için önbellek dosyası mevcut olduğunda tutar. İlgili önbellek dosyası mevcut değilse, oluşturmaz.

- --xlate-cache=_strategy_
    - `auto` (Default)

        Eğer varsa önbellek dosyasını korur.

    - `create`

        Boş önbellek dosyası oluştur ve çık.

    - `always`, `yes`, `1`

        Hedef normal dosya olduğu sürece önbelleği yine de korur.

    - `never`, `no`, `0`

        Var olsa bile önbellek dosyasını asla kullanmayın.

    - `accumulate`

        Varsayılan davranış olarak, kullanılmayan veriler önbellek dosyasından kaldırılır. Bunları kaldırmak ve dosyada tutmak istemiyorsanız, `accumulate` kullanın.

# ENVIRONMENT

- DEEPL\_AUTH\_KEY

    DeepL hizmeti için kimlik doğrulama anahtarınızı ayarlayın.

# SEE ALSO

- [https://github.com/DeepLcom/deepl-python](https://github.com/DeepLcom/deepl-python)

    DeepL Python kütüphanesi ve CLI komutu.

- [App::Greple](https://metacpan.org/pod/App%3A%3AGreple)

    Hedef metin kalıbı hakkında ayrıntılı bilgi için **greple** kılavuzuna bakın. Eşleşen alanı sınırlamak için **--inside**, **--outside**, **--include**, **--exclude** seçeneklerini kullanın.

- [App::Greple::update](https://metacpan.org/pod/App%3A%3AGreple%3A%3Aupdate)

    Dosyaları **greple** komutunun sonucuna göre değiştirmek için `-Mupdate` modülünü kullanabilirsiniz.

- [App::sdif](https://metacpan.org/pod/App%3A%3Asdif)

    **-V** seçeneği ile çakışma işaretleyici formatını yan yana göstermek için **sdif** kullanın.

# AUTHOR

Kazumasa Utashiro

# LICENSE

Telif Hakkı © 2023 Kazumasa Utashiro.

Bu kütüphane özgür yazılımdır; Perl'ün kendisi ile aynı koşullar altında yeniden dağıtabilir ve/veya değiştirebilirsiniz.
