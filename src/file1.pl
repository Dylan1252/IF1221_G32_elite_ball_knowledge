% FAKTA DINAMIS		
Jumlah pemain

:- dynamic
  	pemain/1.
	urutan/1.
	hand/2. % menyimpan kartu yang dimiliki setiap pemain
	discard_top/1.
	giliran/1.

% ========================================================
% Fakta 
% ========================================================

% Warna Kartu
warna(merah).
warna(biru).
warna(hijau).
warna(kuning).
warna(hitam).

% Jenis Kartu Angka
angka(0).
angka(1).
angka(2).
angka(3).
angka(4).
angka(5).
angka(6).
angka(7).
angka(8).
angka(9).

% Jenis Kartu Aksi
aksi(skip).
aksi(reverse). 
aksi(ambil2).
aksi(wild).
aksi(wild_ambil4).
