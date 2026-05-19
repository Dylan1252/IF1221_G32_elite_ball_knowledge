% ============================================================
%  AKSI UTAMA (a): mainkanKartu(NomorUrutKartuDiTangan)
% ============================================================
 
mainkanKartu(N) :-
    giliran_sekarang(Pemain),
    ( efek_pending(wild_draw_four)
        ->  write('Kartu wild draw four aktif. Gunakan tantang atau ambilKartu.'), nl, fail
        ;   true
    ),
    kartu_di_tangan(Pemain, Tangan),
    length(Tangan, Len),
    ( (N < 1 ; N > Len)
        ->  format('Nomor tidak valid. Pilih antara 1-~w.~n', [Len]), fail
        ;   true
    ),
    nth_element(N, Tangan, Kartu),
    ( kartu_valid_untuk_dimainkan(Kartu) -> true ; fail ),
    hapus_ke_n(N, Tangan, TanganBaru),
    retract(kartu_di_tangan(Pemain, Tangan)),
    assertz(kartu_di_tangan(Pemain, TanganBaru)),
    retract(discard_top(_)),
    assertz(discard_top(Kartu)),
    ( retract(status_uni(Pemain)) -> true ; true ),
    format('~w memainkan kartu: ', [Pemain]),
    tulis_kartu(Kartu), write('.'), nl,
    ( TanganBaru = []
        ->  endGame
        ;   terapkan_efek(Kartu)
    ).
 
% ============================================================
%  AKSI UTAMA (b): ambilKartu
% ============================================================
 
ambilKartu :-
    giliran_sekarang(Pemain),
    ( efek_pending(wild_draw_four)
        ->  % Pemain memilih tidak tantang → ambil 4 kartu + skip
            retractall(efek_pending(_)),
            retractall(pemain_wdf(_)),
            ambil_n_kartu_untuk(Pemain, 4),
            format('~w mengambil 4 kartu.~n', [Pemain]),
            pindah_giliran
        ;   % Normal: ambil 1 kartu
            ambil_n_kartu_untuk(Pemain, 1),
            kartu_di_tangan(Pemain, TanganBaru),
            last(TanganBaru, KartuBaru),
            format('~w mendapatkan kartu: ', [Pemain]),
            tulis_kartu(KartuBaru), write('.'), nl,
            pindah_giliran
    ).
 
% ============================================================
%  AKSI UTAMA (c): tantang
% ============================================================
 
tantang :-
    giliran_sekarang(Penantang),
    ( \+ efek_pending(wild_draw_four)
        ->  write('Tidak ada wild draw four yang bisa ditantang.'), nl, fail
        ;   true
    ),
    pemain_wdf(PemainWDF),
    write('Tantangan dilakukan!'), nl,
    format('Memeriksa kartu ~w...~n', [PemainWDF]),
    ( pemain_punya_kartu_cocok_sebelum_wdf(PemainWDF)
        ->  % Tantangan BERHASIL: PemainWDF ambil 4 kartu
            format('Tantangan berhasil! ~w mendapatkan 4 kartu acak.~n', [PemainWDF]),
            ambil_n_kartu_untuk(PemainWDF, 4),
            retractall(efek_pending(_)),
            retractall(pemain_wdf(_))
            % Penantang tetap di giliran dan bisa mainkan kartu
        ;   % Tantangan GAGAL: Penantang ambil 6 kartu + skip
            format('Tantangan gagal. ~w mendapatkan 6 kartu acak.~n', [Penantang]),
            ambil_n_kartu_untuk(Penantang, 6),
            retractall(efek_pending(_)),
            retractall(pemain_wdf(_)),
            pindah_giliran
    ).
 
% Cek apakah pemain WDF sebenarnya punya kartu yang cocok
% (kartu WDF sudah dibuang; cek tangan yang tersisa)
pemain_punya_kartu_cocok_sebelum_wdf(Pemain) :-
    kartu_di_tangan(Pemain, Tangan),
    warna_aktif(WA),
    discard_top(kartu(_, JD)),
    member(K, Tangan),
    K \= kartu(hitam, wild_draw_four),
    K \= kartu(hitam, wild),
    ( K = kartu(WA, _) ; K = kartu(_, JD) ).
 
% ============================================================
%  AKSI UTAMA (d): uni(NomorUrutKartuDiTangan)
% ============================================================
 
uni(N) :-
    giliran_sekarang(Pemain),
    ( efek_pending(wild_draw_four)
        ->  write('Kartu wild draw four aktif. Gunakan tantang atau ambilKartu.'), nl, fail
        ;   true
    ),
    kartu_di_tangan(Pemain, Tangan),
    length(Tangan, Len),
    ( (N < 1 ; N > Len)
        ->  format('Nomor tidak valid. Pilih antara 1-~w.~n', [Len]), fail
        ;   true
    ),
    nth_element(N, Tangan, Kartu),
    % Validasi: setelah memainkan kartu ini, harus tersisa tepat 1 kartu
    LenSetelah is Len - 1,
    ( LenSetelah =\= 1
        ->  write('Perintah uni tidak valid: kartu tidak akan tersisa satu.'), nl,
            write('Anda mendapatkan 1 kartu penalti.'), nl,
            ambil_n_kartu_untuk(Pemain, 1),
            pindah_giliran, fail
        ;   true
    ),
    ( kartu_valid_untuk_dimainkan(Kartu) -> true ; fail ),
    hapus_ke_n(N, Tangan, TanganBaru),
    retract(kartu_di_tangan(Pemain, Tangan)),
    assertz(kartu_di_tangan(Pemain, TanganBaru)),
    retract(discard_top(_)),
    assertz(discard_top(Kartu)),
    % Tandai pemain sudah menyerukan UNI
    ( retract(status_uni(Pemain)) -> true ; true ),
    assertz(status_uni(Pemain)),
    format('~w memainkan kartu: ', [Pemain]),
    tulis_kartu(Kartu), write('.'), nl,
    format('~w menyerukan UNI!~n', [Pemain]),
    ( TanganBaru = []
        ->  endGame
        ;   terapkan_efek(Kartu)
    ).
 
% ============================================================
%  AKSI UTAMA (e): tangkap(NamaPemain)
% ============================================================
 
tangkap(NamaPemain) :-
    giliran_sekarang(Penangkap),
    kartu_di_tangan(NamaPemain, TanganTarget),
    length(TanganTarget, JmlKartu),
    % Tangkap valid jika: target punya tepat 1 kartu DAN belum menyerukan UNI
    ( ( JmlKartu =:= 1, \+ status_uni(NamaPemain) )
        ->  format('~w tertangkap tidak menyerukan UNI.~n', [NamaPemain]),
            format('~w mendapatkan 2 kartu penalti.~n', [NamaPemain]),
            ambil_n_kartu_untuk(NamaPemain, 2),
            pindah_giliran
        ;   ( JmlKartu =\= 1
                ->  format('Perintah tidak valid: ~w tidak memiliki satu kartu.~n', [NamaPemain])
                ;   format('Perintah tidak valid: ~w sudah menyerukan UNI.~n', [NamaPemain])
            ),
            format('~w mendapatkan 1 kartu penalti.~n', [Penangkap]),
            ambil_n_kartu_untuk(Penangkap, 1),
            pindah_giliran
    ).
 
% ============================================================
%  AKSI PENDUKUNG
% ============================================================
 
lihatKartu :-
    giliran_sekarang(Pemain),
    kartu_di_tangan(Pemain, Tangan),
    write('Berikut kartu yang anda miliki.'), nl,
    tampilkan_kartu_bernomor(Tangan, 1).
 
lihatCommand :-
    ( efek_pending(wild_draw_four)
        ->  write('Aksi utama yang tersedia:'), nl,
            write('1. tantang'), nl,
            write('2. ambilKartu'), nl
        ;   write('Aksi utama yang tersedia:'), nl,
            write('1. mainkanKartu(NomorUrut)'), nl,
            write('2. uni(NomorUrut)'), nl,
            write('3. ambilKartu'), nl
    ), nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl.
 
cekInfo :-
    discard_top(DT),
    warna_aktif(WA),
    write('Kartu discard top: '), tulis_kartu(DT), write('.'), nl,
    format('Warna aktif: ~w.~n', [WA]),
    arah_giliran(Arah),
    format('Arah giliran: ~w.~n', [Arah]),
    urutan_pemain(Urutan),
    write('Urutan pemain: '), tampilkan_list(Urutan),
    nl, cetak_info_semua_pemain(Urutan, 1).
 
cetak_info_semua_pemain([], _).
cetak_info_semua_pemain([P|Rest], N) :-
    kartu_di_tangan(P, K),
    length(K, Jml),
    format('Nama pemain ~w: ~w~n', [N, P]),
    format('Jumlah kartu : ~w~n~n', [Jml]),
    N1 is N + 1,
    cetak_info_semua_pemain(Rest, N1).
