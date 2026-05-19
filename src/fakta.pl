% ----- Pencocokan Kartu -----
 
kartu_cocok(kartu(hitam, wild)) :- !.
kartu_cocok(kartu(hitam, wild_draw_four)) :- !.
kartu_cocok(kartu(W, _)) :-
    warna_aktif(WA), W = WA, !.
kartu_cocok(kartu(_, J)) :-
    discard_top(kartu(_, J)), !.
 
% Wild Draw Four hanya boleh dimainkan jika tidak ada kartu lain yang cocok
wdf_valid :-
    giliran_sekarang(Pemain),
    kartu_di_tangan(Pemain, Tangan),
    warna_aktif(WA),
    discard_top(kartu(_, JD)),
    \+ (
        member(K, Tangan),
        K \= kartu(hitam, wild_draw_four),
        K \= kartu(hitam, wild),
        ( K = kartu(WA, _) ; K = kartu(_, JD) )
    ).
 
kartu_valid_untuk_dimainkan(kartu(hitam, wild_draw_four)) :- !,
    ( wdf_valid -> true
    ; write('Tidak valid: masih ada kartu lain yang cocok.'), nl, fail
    ).
kartu_valid_untuk_dimainkan(K) :-
    ( kartu_cocok(K) -> true
    ; write('Kartu tidak cocok dengan discard pile.'), nl, fail
    ).
 
% ----- Pilih & Set Warna Aktif -----
 
pilih_warna(Warna) :-
    write('Pilih warna (merah/kuning/hijau/biru): '),
    read(Input),
    ( member(Input, [merah, kuning, hijau, biru])
        ->  Warna = Input
        ;   write('Warna tidak valid. Coba lagi.'), nl,
            pilih_warna(Warna)
    ).
 
set_warna_aktif(W) :-
    retractall(warna_aktif(_)),
    assertz(warna_aktif(W)).
 
% ----- Efek Kartu -----
 
terapkan_efek(kartu(W, N)) :-
    angka(N), !,
    set_warna_aktif(W),
    pindah_giliran.
 
terapkan_efek(kartu(W, skip)) :- !,
    set_warna_aktif(W),
    pindah_giliran_skip.
 
terapkan_efek(kartu(W, reverse)) :- !,
    set_warna_aktif(W),
    arah_giliran(Arah),
    retract(arah_giliran(Arah)),
    ( Arah = kanan -> ArahBaru = kiri ; ArahBaru = kanan ),
    assertz(arah_giliran(ArahBaru)),
    write('Arah permainan dibalik.'), nl,
    pindah_giliran.
 
terapkan_efek(kartu(W, draw_two)) :- !,
    set_warna_aktif(W),
    pemain_berikutnya(Berikutnya),
    ambil_n_kartu_untuk(Berikutnya, 2),
    format('~w harus mengambil 2 kartu.~n', [Berikutnya]),
    pindah_giliran_skip.
 
terapkan_efek(kartu(hitam, wild)) :- !,
    pilih_warna(Warna),
    set_warna_aktif(Warna),
    format('Warna aktif sekarang: ~w.~n', [Warna]),
    pindah_giliran.
 
% Wild Draw Four: set efek pending, giliran pindah ke pemain berikutnya
% (yang wajib memilih: tantang atau ambilKartu)
terapkan_efek(kartu(hitam, wild_draw_four)) :- !,
    giliran_sekarang(Pemain),
    retractall(pemain_wdf(_)),
    assertz(pemain_wdf(Pemain)),
    pilih_warna(Warna),
    set_warna_aktif(Warna),
    format('Warna aktif sekarang: ~w.~n', [Warna]),
    retractall(efek_pending(_)),
    assertz(efek_pending(wild_draw_four)),
    pindah_giliran.
