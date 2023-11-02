=encoding utf-8

=head1 NAME

App::Greple::xlate - modul dukungan penerjemahan untuk greple

=head1 SYNOPSIS

    greple -Mxlate::deepl --xlate pattern target-file

=head1 VERSION

Version 0.25

=head1 DESCRIPTION

Modul B<Greple> B<xlate> menemukan blok teks dan menggantinya dengan teks yang telah diterjemahkan. Saat ini hanya layanan DeepL yang didukung oleh modul B<xlate::deepl>.

Jika Anda ingin menerjemahkan blok teks normal dalam dokumen gaya L<pod>, gunakan perintah B<greple> dengan modul C<xlate::deepl> dan C<perl> seperti ini:

    greple -Mxlate::deepl -Mperl --pod --re '^(\w.*\n)+' --all foo.pm

Pola C<^(\w.*\n)+> berarti baris berurutan yang dimulai dengan huruf alfanumerik. Perintah ini menunjukkan area yang akan diterjemahkan. Opsi B<--all> digunakan untuk menghasilkan seluruh teks.

=for html <p>
<img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/select-area.png">
</p>

Kemudian tambahkan opsi C<--xlate> untuk menerjemahkan area yang dipilih. Ini akan menemukan dan menggantinya dengan keluaran perintah B<deepl>.

Secara default, teks asli dan terjemahan dicetak dalam format "penanda konflik" yang kompatibel dengan L<git(1)>. Dengan menggunakan format C<ifdef>, Anda dapat memperoleh bagian yang diinginkan dengan perintah L<unifdef(1)> dengan mudah. Format dapat ditentukan dengan opsi B<--xlate-format>.

=for html <p>
<img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/App-Greple-xlate/main/images/format-conflict.png">
</p>

Jika Anda ingin menerjemahkan seluruh teks, gunakan opsi B<--match-all>. Ini adalah jalan pintas untuk menentukan pola yang cocok dengan seluruh teks C<(?).+>.

=head1 OPTIONS

=over 7

=item B<--xlate>

=item B<--xlate-color>

=item B<--xlate-fold>

=item B<--xlate-fold-width>=I<n> (Default: 70)

Memanggil proses penerjemahan untuk setiap area yang cocok.

Tanpa opsi ini, B<greple> berperilaku sebagai perintah pencarian biasa. Jadi, Anda dapat memeriksa bagian mana dari file yang akan menjadi subjek terjemahan sebelum memanggil pekerjaan yang sebenarnya.

Hasil perintah akan keluar ke standar, jadi alihkan ke file jika perlu, atau pertimbangkan untuk menggunakan modul L<App::Greple::update>.

Opsi B<--xlate> memanggil opsi B<--xlate-color> dengan opsi B<--color=never>.

Dengan opsi B<--xlate-fold>, teks yang dikonversi akan dilipat dengan lebar yang ditentukan. Lebar default adalah 70 dan dapat diatur dengan opsi B<--xlate-fold-width>. Empat kolom dicadangkan untuk operasi run-in, sehingga setiap baris dapat menampung paling banyak 74 karakter.

=item B<--xlate-engine>=I<engine>

Tentukan mesin penerjemahan yang akan digunakan. Anda tidak perlu menggunakan opsi ini karena modul C<xlate::deepl> mendeklarasikannya sebagai C<--xlate-engine=deepl>.

=item B<--xlate-labor>

=item B<--xlabor>

Setelah memanggil mesin penerjemahan, Anda diharapkan untuk bekerja. Setelah menyiapkan teks yang akan diterjemahkan, teks tersebut disalin ke clipboard. Anda diharapkan untuk menempelkannya ke formulir, menyalin hasilnya ke clipboard, dan menekan return.

=item B<--xlate-to> (Default: C<EN-US>)

Tentukan bahasa target. Anda bisa mendapatkan bahasa yang tersedia dengan perintah C<deepl languages> ketika menggunakan mesin B<DeepL>.

=item B<--xlate-format>=I<format> (Default: C<conflict>)

Tentukan format output untuk teks asli dan terjemahan.

=over 4

=item B<conflict>, B<cm>

Mencetak teks asli dan teks terjemahan dalam format penanda konflik L<git(1)>.

    <<<<<<< ORIGINAL
    original text
    =======
    translated Japanese text
    >>>>>>> JA

Anda dapat memulihkan file asli dengan perintah L<sed(1)> berikutnya.

    sed -e '/^<<<<<<< /d' -e '/^=======$/,/^>>>>>>> /d'

=item B<ifdef>

Mencetak teks asli dan teks terjemahan dalam format L<cpp(1)> C<#ifdef>.

    #ifdef ORIGINAL
    original text
    #endif
    #ifdef JA
    translated Japanese text
    #endif

Anda hanya dapat mengambil teks bahasa Jepang dengan perintah B<unifdef>:

    unifdef -UORIGINAL -DJA foo.ja.pm

=item B<space>

Mencetak teks asli dan teks terjemahan yang dipisahkan oleh satu baris kosong.

=item B<xtxt>

Jika formatnya adalah C<xtxt> (teks terjemahan) atau tidak diketahui, hanya teks terjemahan yang dicetak.

=back

=item B<--xlate-maxlen>=I<chars> (Default: 0)

Tentukan panjang maksimum teks yang akan dikirim ke API sekaligus. Nilai default ditetapkan untuk layanan akun gratis: 128K untuk API (B<--xlate>) dan 5000 untuk antarmuka clipboard (B<--xlate-labor>). Anda mungkin dapat mengubah nilai ini jika Anda menggunakan layanan Pro.

=item B<-->[B<no->]B<xlate-progress> (Default: True)

Lihat hasil terjemahan secara real time dalam output STDERR.

=item B<--match-all>

Mengatur seluruh teks file sebagai area target.

=back

=head1 CACHE OPTIONS

Modul B<xlate> dapat menyimpan teks terjemahan dalam cache untuk setiap file dan membacanya sebelum eksekusi untuk menghilangkan overhead dari permintaan ke server. Dengan strategi cache default C<auto>, modul ini mempertahankan data cache hanya ketika file cache ada untuk file target.

=over 7

=item --cache-clear

Opsi B<--cache-clear> dapat digunakan untuk memulai manajemen cache atau untuk menyegarkan semua data cache yang ada. Setelah dieksekusi dengan opsi ini, file cache baru akan dibuat jika belum ada dan kemudian secara otomatis dipelihara setelahnya.

=item --xlate-cache=I<strategy>

=over 4

=item C<auto> (Default)

Mempertahankan file cache jika sudah ada.

=item C<create>

Buat file cache kosong dan keluar.

=item C<always>, C<yes>, C<1>

Pertahankan cache sejauh targetnya adalah file normal.

=item C<clear>

Hapus data cache terlebih dahulu.

=item C<never>, C<no>, C<0>

Jangan pernah menggunakan file cache meskipun ada.

=item C<accumulate>

Secara default, data yang tidak digunakan akan dihapus dari file cache. Jika Anda tidak ingin menghapusnya dan menyimpannya di dalam file, gunakan C<accumulate>.

=back

=back

=head1 COMMAND LINE INTERFACE

Anda dapat dengan mudah menggunakan modul ini dari baris perintah dengan menggunakan perintah C<xlate> yang disertakan dalam repositori. Lihat informasi bantuan C<xlate> untuk penggunaan.

=head1 EMACS

Muat file F<xlate.el> yang disertakan dalam repositori untuk menggunakan perintah C<xlate> dari editor Emacs. Fungsi C<xlate-region> menerjemahkan wilayah tertentu. Bahasa default adalah C<EN-US> dan Anda dapat menentukan bahasa yang digunakan dengan argumen awalan.

=head1 ENVIRONMENT

=over 7

=item DEEPL_AUTH_KEY

Tetapkan kunci autentikasi Anda untuk layanan DeepL.

=back

=head1 INSTALL

=head2 CPANMINUS

    $ cpanm App::Greple::xlate

=head1 SEE ALSO

L <App::Greple::xlate>

=over 7

=item L<https://github.com/DeepLcom/deepl-python>

DeepL pustaka Python dan perintah CLI.

=item L<App::Greple>

Lihat manual B<greple> untuk detail tentang pola teks target. Gunakan opsi B<--inside>, B<--outside>, B<--include>, B<--exclude> untuk membatasi area pencocokan.

=item L<App::Greple::update>

Anda dapat menggunakan modul C<-Mupdate> untuk memodifikasi file berdasarkan hasil perintah B<greple>.

=item L<App::sdif>

Gunakan B<sdif> untuk menampilkan format penanda konflik berdampingan dengan opsi B<-V>.

=back

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright © 2023 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
