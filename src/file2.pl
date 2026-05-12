% ====================================================
% Rules
% ====================================================

startGame :-
	hapus_data,

	write(‘Masukkan jumlah pemain: ’),
	read(Jumlah),
	validasi(Jumlah),

	input_pemain(1, Jumlah, DaftarPemain),

	random_permutation(DaftarPemain, UrutanAcak),
	assertz(urutan(UrutanAcak)),

	write(‘Urutan pemain: ’), tampilkan_urutan(UrutanAcak), nl,

	write(‘Setiap pemain mendapatkan 7 kartu acak.’),

	write(‘Kartu discard top: ’), 

hapus_data :-
 	retractall(pemain(_)),
 	retractall(urutan(_)),
 	retractall(hand(_, _)),
 	retractall(discard_top(_)),
 	retractall(giliran(_)).



validasi(Jumlah) :- Jumlah >= 2, Jumlah =< 4.
validasi(Jumlah) :-
	(Jumlah < 2 ; Jumlah > 4),
	write(‘Mohon masukkan angka antara 2-4.’), nl,
	startGame.

% ====================================================
% Input Pemain
% ====================================================

input_pemain(N, Max, [Nama|Rest]) :-
	N =< Max,
	write(‘Masukkan nama pemain ‘), write(N), write(‘: ’),
	read(NamaAsli),

	% format semua input ke atom
	(atom(NamaAsli) ->
		Nama = NamaAsli
	;
		string(NamaAsli) ->
		atom_string(Nama, NamaAsli)
	),

% cek apakah nama sudah ada, jika belum tambah (assertz)
(pemain(Nama) -> 
	write(‘Nama sudah digunakan. Masukkan nama lain: ’), nl,
	input_pemain(N, Max, [Nama|Rest])
;
	assertz(pemain(Nama)),
	N1 is N + 1,
	input_pemain(N1, Max, Rest)
).

input_pemain(_, _, []).


tampilkan_urutan([]).
tampilkan_urutan([Nama]) :-
write(Nama).
tampilkan_urutan([Nama|Rest]) :-
 	write(Nama), write(' - '),
 	tampilkan_urutan(Rest).

% ====================================================
% Pembagian Kartu
% ====================================================

ambil_kartu(0, Deck, [], Deck). %kalau kartu yang diambil = 0 , decknya ya tetap

ambil_kartu(N, (H|T), (H|Cards), SisaDeck):-

	% selama masih ada kartu
	% kartu di deck akan berkurang 1
	% looping
	
	N>0,
	N1 is N - 1,
	ambil_kartu(N1, T, Cards, SisaDeck).

bagi_kartu([],_).  %kalau g ada pemain lagi, ga ngapa ngapain lagi

bagi_kartu([Pemain|Rest], DeckAwal):-

	% membagikan 7 kartu ke setiap pemain
	ambil_kartu(7, DeckAwal, KartuPemain, SisaDeck), 

	% tambahkan kartu yang di bagi ke urutan terakhir kartu pemain
	assertz(hand(Pemain,KartuPemain)),

	write(pemain),
	write(‘ mendapatkan kartu’),
	write(KartuPemain), nl,

	bagi_kartu(Rest, SisaDeck). % bagi kartu ke org selanjutnya

