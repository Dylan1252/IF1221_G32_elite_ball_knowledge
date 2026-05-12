startGame :-
  hapus_data,

	write('Masukkan jumlah pemain: '),
	read(Jumlah),
	validasi(Jumlah),

  input_pemain(1, Jumlah, DaftarPemain),

  random_permutation(DaftarPemain, UrutanAcak),
  assertz(urutan(UrutanAcak)),

  write(‘Urutan pemain: ’), tampilkan_urutan(UrutanAcak), nl,

  write(‘Setiap pemain mendapatkan 7 kartu acak.’),

  write(‘Kartu discard top: ’), 
